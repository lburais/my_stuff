from pyicloud import PyiCloudService
import os
from shutil import copyfileobj
import pprint

#os.system( 'icloud --username=laurent@burais.fr')

api = PyiCloudService('laurent@burais.fr')

if api.requires_2fa:
    print("Two-factor authentication required.")
    code = input("Enter the code you received of one of your approved devices: ")
    result = api.validate_2fa_code(code)
    print("Code validation result: %s" % result)

    if not result:
        print("Failed to verify security code")
        sys.exit(1)

    if not api.is_trusted_session:
        print("Session is not trusted. Requesting trust...")
        result = api.trust_session()
        print("Session trust result %s" % result)

        if not result:
            print("Failed to request trust. You will likely be prompted for the code again in the coming weeks")
elif api.requires_2sa:
    import click
    print("Two-step authentication required. Your trusted devices are:")

    devices = api.trusted_devices
    for i, device in enumerate(devices):
        print(
            "  %s: %s" % (i, device.get('deviceName',
            "SMS to %s" % device.get('phoneNumber')))
        )

    device = click.prompt('Which device would you like to use?', default=0)
    device = devices[device]
    if not api.send_verification_code(device):
        print("Failed to send verification code")
        sys.exit(1)

    code = click.prompt('Please enter validation code')
    if not api.validate_verification_code(device, code):
        print("Failed to verify verification code")
        sys.exit(1)

def drive_processing( node, dir, level ):
    if node:
        if node.type.lower() != 'file':
            print('{}- create and parse folder {}'.format('  '*level, node.name))
            if not os.path.isdir(os.path.join(dir, node.name)):
                os.makedirs(os.path.join(dir, node.name))
            for element in node.dir():
                drive_processing( node[element], os.path.join(dir, node.name), level+1 )
        else:
            print('{}- process file {} - {} - {} - {}'.format('  '*level, node.name, node.size, node.date_modified, node.type))
            with node.open(stream=True) as response:
                with open(os.path.join(dir, node.name), 'wb') as file_out:
                    copyfileobj(response.raw, file_out)
    else:
        for element in api.drive.dir():
            drive_processing(api.drive[dir], dir, 0)

# drive_processing(None, os.path.join(os.path.dirname(__file__), 'Drive'), 0)
# contacts_processing
# notes_processing
# photos_processing

#pprint.pprint(api.__dict__)
#pprint.pprint(api.drive.__dict__)
#pprint.pprint(api.contacts.__dict__)
pprint.pprint(api.photos.__dict__)
#pprint.pprint(api.__dict__)
# pprint.pprint(api.notes.__dict__)

