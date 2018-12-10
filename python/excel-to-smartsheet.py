# Install the smartsheet sdk with the command: pip install smartsheet-python-sdk
import smartsheet
import logging
import os.path

# TODO: Set your API access token here, or leave as None and set as environment variable "SMARTSHEET_ACCESS_TOKEN"
access_token = "5ms2rnrh8djnm1vt4pyv6e2klp"

_dir = os.path.dirname(os.path.abspath(__file__))

sourcefile = '/CX Asks and Requisitions Master File.xlsx'
sheetname = "CX Asks and Requisitions (list)"
foldername = "CX Requisitions"

# The API identifies columns by Id, but it's more convenient to refer to column names. Store a map here
column_map = {}

# Helper function to find cell in a row
def get_cell_by_column_name(row, column_name):
    column_id = column_map[column_name]
    return row.get_column(column_id)

# Return a new Row with updated cell values, else None to leave unchanged
def evaluate_row_and_build_updates(source_row):
    # Build the row to update
    newRow = ss.models.Row()
    newRow.id = source_row.id
    for source in source_row.columns:
        newCell = ss.models.Cell()
        newCell.column_id = source.column_id
        newCell.value = source.value
        newRow.cells.append(newCell)
            
    return newRow

print("Starting ...")

# Initialize client
ss = smartsheet.Smartsheet(access_token)
# Make sure we don't miss any error
ss.errors_as_exceptions(True)

# Log all calls
logging.basicConfig(filename='excel-to-smartsheet.log', level=logging.INFO)

# Import the sheet and load the entire sheet
response = ss.Home.list_folders()
folderid = 0
for data in response.data:
    if data.name == foldername:
        folderid = data.id
        break

if folderid == 0:
    result = ss.Sheets.import_xlsx_sheet(_dir + sourcefile, header_row_index=0)
else:
    result = ss.Folders.import_xlsx_sheet(folder, _dir + sourcefile, header_row_index=0)

newsheet = ss.Sheets.get_sheet(result.data.id)
print ("Loaded " + str(len(newsheet.rows)) + " rows from spreadsheet: " + sourcefile + " in sheet: " + newsheet.name + " with id " + str(newsheet.id))

# Load the existing sheet
response = ss.Sheets.list_sheets()
updating = False
for data in response.data:
    if data.name == sheetname:
        updating = True
        break

if updating:
    sheet = ss.Sheets.get_sheet(data.id)
    print ("Loaded " + str(len(sheet.rows)) + " rows from sheet: " + sheet.name + " with id " + str(sheet.id))

    # Build column map for later reference - translates column names to column id
    for column in sheet.columns:
        column_map[column.title] = column.id

    # Accumulate rows needing update here
    rowsToUpdate = []

    for row in sheet.rows:
        print("now writing in sheet: " + sheet.name + " with id " + str(sheet.id))
        rowToUpdate = evaluate_row_and_build_updates(row)
        rowsToUpdate.append(rowToUpdate)
        result = ss.Sheets.update_rows(sheet.id, rowsToUpdate)
        rowsToUpdate = []

    result = ss.Sheets.delete_sheet(newsheet.id)

else:
    print("Creating " + str(len(newsheet.rows)) + " rows in sheet: " + newsheet.name)


print ("Done")




