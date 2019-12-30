# Install the smartsheet sdk with the command: pip install smartsheet-python-sdk
import smartsheet
import logging
import os.path

# TODO: Set your API access token here, or leave as None and set as environment variable "SMARTSHEET_ACCESS_TOKEN"
access_token = "5ms2rnrh8djnm1vt4pyv6e2klp"

_dir = os.path.dirname(os.path.abspath(__file__))

sourcefile = '/CX HC Impact Model scrubbed.xlsx'
sheetname = "CX HC Impact Model"
foldername = "CX Budget Realignment"

print("Starting ...")

# Initialize client
ss = smartsheet.Smartsheet(access_token)
# Make sure we don't miss any error
ss.errors_as_exceptions(True)

# Log all calls
logging.basicConfig(filename='upload_HC_impact.log', level=logging.INFO)

# Import the sheet and load the entire sheet
response = ss.Home.list_folders()
folderid = 0
for data in response.data:
    if data.name == foldername:
        folderid = data.id
        print ("Found folder " + data.name)
        break

if folderid == 0:
    result = ss.Sheets.import_xlsx_sheet(_dir + sourcefile, header_row_index=0)
else:
    result = ss.Folders.import_xlsx_sheet(folder, _dir + sourcefile, header_row_index=0)

newsheet = ss.Sheets.get_sheet(result.data.id)
print ("Loaded " + str(len(newsheet.rows)) + " rows from spreadsheet: " + sourcefile + " in sheet: " + newsheet.name + " with id " + str(newsheet.id))

print ("Done")
