import xml.etree.ElementTree as ET
import csv

# Path to your XML file
file_path = './data/export.xml'

# Parse the XML file
tree = ET.parse(file_path)
root = tree.getroot()

# Open a CSV file for writing
with open('step_count_raw.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    # Write the header
    writer.writerow(['StartDate', 'EndDate', 'StepCount'])

    # Iterate over each Record element in the XML
    for record in root.findall('.//Record[@type="HKQuantityTypeIdentifierStepCount"]'):
        start_date = record.get('startDate')
        end_date = record.get('endDate')
        step_count = record.get('value')
        # Write data rows
        writer.writerow([start_date, end_date, step_count])

with open('step_speed_raw.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    # Write the header
    writer.writerow(['StartDate', 'EndDate', 'Speed'])

    # Iterate over each Record element in the XML
    for record in root.findall('.//Record[@type="HKQuantityTypeIdentifierWalkingSpeed"]'):
        start_date = record.get('startDate')
        end_date = record.get('endDate')
        speed = record.get('value')
        # Write data rows
        writer.writerow([start_date, end_date, speed])

