import subprocess
import clickhouse_connect
from datetime import datetime
import re  # Import the 're' module for regular expressions
import socket  # Import socket to get the hostname

# Connect to ClickHouse using clickhouse_connect with username 'default' and password 'admin'
#client = clickhouse_connect.get_client(host='localhost', username='default', password='admin')
client = clickhouse_connect.get_client(host='192.168.3.22', username='default', password='admin')

# Function to clean and convert a value to an integer, handling cases where it's not valid
def safe_int(value):
    cleaned_value = value.replace(',', '').strip()
    try:
        return int(float(cleaned_value))  # Handle values that might be floats
    except ValueError:
        return 0  # Return 0 if the value cannot be converted to an integer

# Function to parse datetime from DCGM output (assuming the format)
def parse_datetime(value):
    try:
        return datetime.strptime(value, '%a %b %d %H:%M:%S %Y')
    except ValueError:
        return None  # Return None if the value cannot be parsed

# Function to parse DCGM job stats output for multiple GPUs, using a stateful approach
def parse_dcgm_output(output):
    stats = []
    gpu_stats = None  # Initialize as None
    gpu_counter = 0  # Initialize GPU counter

    # Split the output into lines for iteration
    lines = output.splitlines()

    for line in lines:
        line = line.strip()
        print("Processing line:", line)  # Debugging statement

        # Detect the start of a new GPU section
        gpu_id_match = re.match(r'\| GPU ID:\s*(\d+)\s*\|', line)
        if gpu_id_match:
            if gpu_stats:
                # Before starting a new GPU, append the previous one
                # Provide default values for missing datetime fields
                if gpu_stats['start_time'] is None:
                    gpu_stats['start_time'] = datetime.now()
                if gpu_stats['end_time'] is None:
                    gpu_stats['end_time'] = datetime.now()
                stats.append(gpu_stats)
                gpu_counter += 1

            # Initialize a new gpu_stats dictionary
            gpu_stats = {
                'job_id': None,
                'gpu_group_id': None,
                'gpu_id': int(gpu_id_match.group(1)),  # Extracted GPU ID
                'start_time': None,
                'end_time': None,
                'gpu_memory_used': 0,          # Default value (int)
                'energy_consumed': '0',        # Default value (string)
                'sm_utilization': 0,           # Default value (int)
                'memory_utilization': 0,       # Default value (int)
                'pcie_rx_bandwidth': 0,        # Default value (int)
                'pcie_tx_bandwidth': 0,        # Default value (int)
                'overall_health': 'Unknown',   # Default value (string)
                'hostname': socket.gethostname()  # Add hostname
            }
            continue  # Move to the next line

        if not gpu_stats:
            continue  # Skip lines until a GPU section is found

        # Parsing different metrics
        # Start Time
        if 'Start Time' in line and ':' in line:
            parts = line.split(":", 1)
            if len(parts) > 1:
                gpu_stats['start_time'] = parse_datetime(parts[1].strip())
            continue

        # End Time
        elif 'End Time' in line and ':' in line:
            parts = line.split(":", 1)
            if len(parts) > 1:
                gpu_stats['end_time'] = parse_datetime(parts[1].strip())
            continue

        # Max GPU Memory Used
        elif 'Max GPU Memory Used' in line and ':' in line:
            parts = line.split(":", 1)
            if len(parts) > 1:
                gpu_stats['gpu_memory_used'] = safe_int(parts[1].strip())
            continue

        # Energy Consumed
        elif 'Energy Consumed' in line:
            # Handle both 'Energy Consumed (Joules)' and other possible formats
            match = re.search(r'Energy Consumed.*?([\d,\.]+)', line)
            if match:
                gpu_stats['energy_consumed'] = match.group(1).replace(',', '').strip()
            else:
                gpu_stats['energy_consumed'] = '0'
            continue

        # SM Utilization
        elif 'SM Utilization' in line:
            # Attempt to match both patterns
            # Pattern 1: | SM Utilization (%)                 | Avg: 38, Max: 100, Min: 0               |
            match1 = re.search(r'SM Utilization.*Avg:\s*(\d+)', line)
            # Pattern 2: |     Avg SM Utilization (%)         | 38                                      |
            match2 = re.search(r'Avg SM Utilization.*\|\s*(\d+)', line)
            if match1:
                gpu_stats['sm_utilization'] = safe_int(match1.group(1))
            elif match2:
                gpu_stats['sm_utilization'] = safe_int(match2.group(1))
            else:
                gpu_stats['sm_utilization'] = 0
            continue

        # Memory Utilization
        elif 'Memory Utilization' in line:
            # Attempt to match both patterns
            # Pattern 1: | Memory Utilization (%)             | Avg: 14, Max: 72, Min: 0                |
            match1 = re.search(r'Memory Utilization.*Avg:\s*(\d+)', line)
            # Pattern 2: |     Avg Memory Utilization (%)     | 12                                      |
            match2 = re.search(r'Avg Memory Utilization.*\|\s*(\d+)', line)
            if match1:
                gpu_stats['memory_utilization'] = safe_int(match1.group(1))
            elif match2:
                gpu_stats['memory_utilization'] = safe_int(match2.group(1))
            else:
                gpu_stats['memory_utilization'] = 0
            continue

        # PCIe Rx Bandwidth
        elif 'PCIe Rx Bandwidth' in line:
            match = re.search(r'Avg:\s*([\d\.]+|N/A)', line)
            if match and match.group(1) != 'N/A':
                gpu_stats['pcie_rx_bandwidth'] = safe_int(match.group(1))
            else:
                gpu_stats['pcie_rx_bandwidth'] = 0
            continue

        # PCIe Tx Bandwidth
        elif 'PCIe Tx Bandwidth' in line:
            match = re.search(r'Avg:\s*([\d\.]+|N/A)', line)
            if match and match.group(1) != 'N/A':
                gpu_stats['pcie_tx_bandwidth'] = safe_int(match.group(1))
            else:
                gpu_stats['pcie_tx_bandwidth'] = 0
            continue

        # Overall Health
        elif 'Overall Health' in line and ':' in line:
            parts = line.split(":", 1)
            if len(parts) > 1:
                gpu_stats['overall_health'] = parts[1].strip()
            continue

        # You can add more elif blocks if needed for other metrics

    # After processing all lines, don't forget to append the last GPU's stats
    if gpu_stats:
        if gpu_stats['start_time'] is None:
            gpu_stats['start_time'] = datetime.now()
        if gpu_stats['end_time'] is None:
            gpu_stats['end_time'] = datetime.now()
        stats.append(gpu_stats)

    return stats

# Function to collect stats from DCGM and insert into ClickHouse
def collect_and_insert_stats(group_id, job_id):
    # Run dcgmi command to get job stats for all GPUs
    try:
        result = subprocess.run(
            ['dcgmi', 'stats', '-g', str(group_id), '-j', job_id, '-v'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True
        )
    except subprocess.CalledProcessError as e:
        print(f"Error running dcgmi command: {e.stderr.decode('utf-8')}")
        return

    output = result.stdout.decode('utf-8')

    # Print the raw output for debugging (optional)
    print("Raw DCGM Output:\n", output)

    # Parse the output for multiple GPUs
    stats_list = parse_dcgm_output(output)

    # Prepare the data to insert into ClickHouse
    data_to_insert = []
    for stats in stats_list:
        row = [
            job_id,                             # 'job_id' as string
            group_id,                           # 'gpu_group_id' as int
            stats['gpu_id'],                    # 'gpu_id' as int
            stats['start_time'],                # 'start_time' as datetime
            stats['end_time'],                  # 'end_time' as datetime
            stats['gpu_memory_used'],           # 'gpu_memory_used' as int
            stats['energy_consumed'],           # 'energy_consumed' as string
            stats['sm_utilization'],            # 'sm_utilization' as int
            stats['memory_utilization'],        # 'memory_utilization' as int
            stats['pcie_rx_bandwidth'],         # 'pcie_rx_bandwidth' as int
            stats['pcie_tx_bandwidth'],         # 'pcie_tx_bandwidth' as int
            stats['overall_health'],            # 'overall_health' as string
            stats['hostname']                   # 'hostname' as string
        ]
        data_to_insert.append(row)

    # Insert data into ClickHouse
    print("Data to Insert:\n", data_to_insert)
    try:
        client.insert('gpu_job_stats', data_to_insert, column_names=[
            'job_id',
            'gpu_group_id',
            'gpu_id',
            'start_time',
            'end_time',
            'gpu_memory_used',
            'energy_consumed',
            'sm_utilization',
            'memory_utilization',
            'pcie_rx_bandwidth',
            'pcie_tx_bandwidth',
            'overall_health',
            'hostname'  # Add hostname to column names
        ])
        print("Data inserted successfully.")
    except Exception as e:
        print(f"Failed to insert data into ClickHouse: {e}")

# Example usage:

# Collect and insert new GPU stats without cleaning the table
collect_and_insert_stats(0, '12')

# Close the client connection
client.close()

