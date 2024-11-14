def format_size(size, unit):
    """Format the size with a comma for GB and GiB, and dots for other units."""
    if unit in ['GB', 'GiB']:
        # For GB and GiB, use comma as thousand separator
        return f"{size:,.2f}".replace(",", ".")  # Use dot as thousand separator
    else:
        # For other units like bytes, use dot as thousand separator
        return f"{size:,.2f}".replace(",", ".")  # Use dot as thousand separator

def calculate_final_size(tier_from, tier_to, begin_size):
    # Starting size in bytes
    size_in_bytes = begin_size
    current_unit = "GB"  # Start with GB and GiB for the first conversion

    # Calculate size at each tier and log the conversion
    for tier in range(tier_from, tier_to + 1):
        size_in_bytes *= 16  # Each tier increases the size by a factor of 16

        # Prepare conversion details for the current unit
        if current_unit == "GB":
            size_in_GB = size_in_bytes / (1000**3)  # Convert bytes to GB
            size_in_GiB = size_in_bytes / (1024**3)  # Convert bytes to GiB

            if size_in_GB >= 1000:  # Convert to TB and TiB if it's >= 1000 GB
                size_in_TB = size_in_GB / 1000
                size_in_TiB = size_in_GiB / 1024
                line = f"{format_size(size_in_TB, 'TB')} TB = {format_size(size_in_TiB, 'TiB')} TiB = {format_size(size_in_bytes, 'bytes')} bytes"
                current_unit = "TB"  # Now use TB and TiB for the next conversion
            else:
                line = f"{format_size(size_in_GB, 'GB')} GB = {format_size(size_in_GiB, 'GiB')} GiB = {format_size(size_in_bytes, 'bytes')} bytes"

        elif current_unit == "TB":
            size_in_TB = size_in_bytes / (1000**4)
            size_in_TiB = size_in_bytes / (1024**4)

            if size_in_TB >= 1000:  # Convert to PB and PiB if it's >= 1000 TB
                size_in_PB = size_in_TB / 1000
                size_in_PiB = size_in_TiB / 1024
                line = f"{format_size(size_in_PB, 'PB')} PB = {format_size(size_in_PiB, 'PiB')} PiB = {format_size(size_in_bytes, 'bytes')} bytes"
                current_unit = "PB"  # Now use PB and PiB for the next conversion
            else:
                line = f"{format_size(size_in_TB, 'TB')} TB = {format_size(size_in_TiB, 'TiB')} TiB = {format_size(size_in_bytes, 'bytes')} bytes"

        elif current_unit == "PB":
            size_in_PB = size_in_bytes / (1000**5)
            size_in_PiB = size_in_bytes / (1024**5)

            if size_in_PB >= 1000:  # Convert to EB and EiB if it's >= 1000 PB
                size_in_EB = size_in_PB / 1000
                size_in_EiB = size_in_PiB / 1024
                line = f"{format_size(size_in_EB, 'EB')} EB = {format_size(size_in_EiB, 'EiB')} EiB = {format_size(size_in_bytes, 'bytes')} bytes"
                current_unit = "EB"  # Now use EB and EiB for the next conversion
            else:
                line = f"{format_size(size_in_PB, 'PB')} PB = {format_size(size_in_PiB, 'PiB')} PiB = {format_size(size_in_bytes, 'bytes')} bytes"

        elif current_unit == "EB":
            size_in_EB = size_in_bytes / (1000**6)
            size_in_EiB = size_in_bytes / (1024**6)

            if size_in_EB >= 1000:  # Convert to ZB and ZiB if it's >= 1000 EB
                size_in_ZB = size_in_EB / 1000
                size_in_ZiB = size_in_EiB / 1024
                line = f"{format_size(size_in_ZB, 'ZB')} ZB = {format_size(size_in_ZiB, 'ZiB')} ZiB = {format_size(size_in_bytes, 'bytes')} bytes"
                current_unit = "ZB"  # Now use ZB and ZiB for the next conversion
            else:
                line = f"{format_size(size_in_EB, 'EB')} EB = {format_size(size_in_EiB, 'EiB')} EiB = {format_size(size_in_bytes, 'bytes')} bytes"

        elif current_unit == "ZB":
            size_in_ZB = size_in_bytes / (1000**7)
            size_in_ZiB = size_in_bytes / (1024**7)

            if size_in_ZB >= 1000:  # Convert to YB and YiB if it's >= 1000 ZB
                size_in_YB = size_in_ZB / 1000
                size_in_YiB = size_in_ZiB / 1024
                line = f"{format_size(size_in_YB, 'YB')} YB = {format_size(size_in_YiB, 'YiB')} YiB = {format_size(size_in_bytes, 'bytes')} bytes"
                current_unit = "YB"  # Now use YB and YiB for the next conversion
            else:
                line = f"{format_size(size_in_ZB, 'ZB')} ZB = {format_size(size_in_ZiB, 'ZiB')} ZiB = {format_size(size_in_bytes, 'bytes')} bytes"

        # Log the line to output.log
        log_conversion_to_file(line)

def log_conversion_to_file(line):
    """Log the conversion line to output.log."""
    with open("output.log", "a") as log_file:
        log_file.write(line + "\n")

# Example usage:
begin_size = 10 * 10**9  # Begin with 10 GB in bytes
tier_from = 0
tier_to = 18

calculate_final_size(tier_from, tier_to, begin_size)
