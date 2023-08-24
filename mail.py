import imaplib
import sys, traceback, os
import pandas as pd
import numpy as np
import re
import openpyxl

from tabulate import tabulate

def parse_imap( src, host, user, password ):
    # http://tech.franzone.blog/2012/11/29/counting-messages-in-imap-folders-in-python/

    imap = None
    df = pd.DataFrame()

    try:
        folders = []
        # Create the IMAP Client
        imap = imaplib.IMAP4_SSL(host)
        print("Connection Object : {}".format(imap))

        # Login to the IMAP server
        resp, data = imap.login(user, password)
        print("Response Code : {}".format(resp))
        print("Response      : {}\n".format(data[0].decode()))

        if resp == 'OK':
            # Get a list of mailboxes
            resp, data = imap.list()
            if resp == 'OK':
                for mbox in data:
                    # Parse mailboxes
                    try:
                        #print( mbox )

                        name = re.match(r'\((.*)\) "(.*)" (.*)', bytes.decode(mbox)).group(3)
                        #print('  - name: {}'.format(name))

                        # Get mail count
                        resp, msgnums = imap.select(name, True)
                        mycount = int(msgnums[0].decode())
                        #print('  - count: {}'.format(mycount))

                        # Get size
                        size = 0
                        OVER = 20*1024*1024 # 20MB
                        typ, messages = imap.search(None, 'ALL')

                        # Find the first and last messages
                        if messages[0]:
                            m = [int(x) for x in messages[0].split()]
                            m.sort()
                            if m:
                                message_set = "%d:%d" % (m[0], m[-1])
                                result, sizes_response = imap.fetch(message_set, "(UID RFC822.SIZE)")

                                for i in range(m[-1]):
                                    msg_size = int(re.match(r'.*SIZE (.*)\).*', bytes.decode(sizes_response[i])).group(1))
                                    size += msg_size
                                    #if msg_size > OVER: print( '  !! {} is oversized'.format(i))
                                #print('  - size: {:.1f} MB'.format(size/1024/1024))

                        # Add to list
                        print('[{}] {} - {} msg - {:.1f} MB'.format(src, name, mycount, size/1024/1024))
                        folders += [[ name, mycount, size ]]

                    except Exception as e:
                        print("{} - ErrorType : {}, Error : {}".format(name, type(e).__name__, e))
                        folders += [[ name, -1, -1 ]]

                df = pd.DataFrame( folders, columns=['Folder', 'Count', 'Size' ])

    except:
        print('Unexpected error : {0}'.format(sys.exc_info()[0]))
        traceback.print_exc()
    finally:
        if imap != None:
            imap.logout()
        imap = None

    return df

# ICLOUD

df_dicloud= parse_imap( 'iCloud D', 'imap.mail.me.com', 'dburais@icloud.com', 'nhgf-pncn-vcuv-hzwl' )
df_dicloud['Folder'] = df_dicloud['Folder'].str.replace("/", ".")
df_dicloud['Folder'] = df_dicloud['Folder'].str.replace('"', '')
df_dicloud.rename( columns={ 'Count': '# iCloud Domi', 'Size': 'iCloud Domi'}, inplace=True )

df_licloud= parse_imap( 'iCloud L', 'imap.mail.me.com', 'lburais@icloud.com', 'wrfe-tpdj-ebtt-bwel' )
df_licloud['Folder'] = df_licloud['Folder'].str.replace("/", ".")
df_licloud['Folder'] = df_licloud['Folder'].str.replace('"', '')
df_licloud.rename( columns={ 'Count': '# iCloud Laurent', 'Size': 'iCloud Laurent'}, inplace=True )

df_icloud = df_licloud.merge( df_dicloud, on=["Folder"], how="outer" )

df_icloud['# iCloud'] = np.NaN
df_icloud.loc[df_icloud['# iCloud'].isna() & ~df_icloud['# iCloud Laurent'].isna(), '# iCloud'] = df_icloud['# iCloud Laurent']
df_icloud.loc[df_icloud['# iCloud'].isna() & ~df_icloud['# iCloud Domi'].isna(), '# iCloud'] = df_icloud['# iCloud Domi']

df_icloud['iCloud'] = np.NaN
df_icloud.loc[df_icloud['# iCloud Pharaoh'] == df_icloud['# iCloud Laurent'].isna(), 'iCloud'] = df_icloud['iCloud Laurent']
df_icloud.loc[df_icloud['# iCloud Pharaoh'] == df_icloud['# iCloud Domi'].isna(), 'iCloud'] = df_icloud['iCloud Domi']

# PHARAOH

df_laurent = parse_imap( 'Laurent', 'horus.local', 'Laurent', 'Jrdl6468$' )
df_laurent['Folder'] = df_laurent['Folder'].str.replace('"', '')
df_laurent.rename( columns={ 'Count': '# Laurent', 'Size': 'Laurent'}, inplace=True )

df_famille = parse_imap( 'Famille', 'horus.local', 'Famille', 'Burais12345!!' )
df_famille['Folder'] = df_famille['Folder'].str.replace('"', '')
df_famille.rename( columns={ 'Count': '# Famille', 'Size': 'Famille'}, inplace=True )

df_domi = parse_imap( 'Dominique', 'horus.local', 'Dominique', 'Dburais68' )
df_domi['Folder'] = df_domi['Folder'].str.replace('"', '')
df_domi.rename( columns={ 'Count': '# Domi', 'Size': 'Domi'}, inplace=True )

df_summary = df_laurent.merge( df_famille, on=["Folder"], how="outer" )
df_summary = df_summary.merge( df_domi, on=["Folder"], how="outer" )

df_summary['# Pharaoh'] = np.NaN
df_summary.loc[df_summary['# Pharaoh'].isna() & ~df_summary['# Famille'].isna(), '# Pharaoh'] = df_summary['# Famille']
df_summary.loc[df_summary['# Pharaoh'].isna() & ~df_summary['# Laurent'].isna(), '# Pharaoh'] = df_summary['# Laurent']
df_summary.loc[df_summary['# Pharaoh'].isna() & ~df_summary['# Domi'].isna(), '# Pharaoh'] = df_summary['# Domi']

df_summary['Pharaoh'] = np.NaN
df_summary.loc[df_summary['# Pharaoh'] == df_summary['# Famille'].isna(), 'Pharaoh'] = df_summary['Famille']
df_summary.loc[df_summary['# Pharaoh'] == df_summary['# Laurent'].isna(), 'Pharaoh'] = df_summary['Laurent']
df_summary.loc[df_summary['# Pharaoh'] == df_summary['# Domi'].isna(), 'Pharaoh'] = df_summary['Domi']

df_summary = df_summary.merge( df_icloud, on=["Folder"], how="outer" )

# STATUS

df_summary['Status'] = np.NaN

cond = df_summary['Status'].isna()
cond &= ~df_summary['# iCloud'].isna()
cond &= ~df_summary['# Pharaoh'].isna()
cond &= ((df_summary['Pharaoh'] + (2 * df_summary['# iCloud'])) == df_summary['iCloud'])
df_summary.loc[cond, 'Status'] = 'Transfer OK'

cond = df_summary['Status'].isna()
cond &= ~df_summary['# iCloud'].isna()
cond &= ((df_summary['# Pharaoh'] == 0) | (df_summary['# Pharaoh'].isna()))
df_summary.loc[cond, 'Status'] = 'Transferred'

cond = df_summary['Status'].isna()
cond &= df_summary['# Pharaoh'] == 0
df_summary.loc[cond, 'Status'] = 'No Transfer'

cond = df_summary['Status'].isna()
cond &= ~df_summary['# iCloud'].isna()
cond &= ~df_summary['# Pharaoh'].isna()
cond &= ~(df_summary['# Pharaoh'] == df_summary['# iCloud'])
cond &= ((df_summary['# Pharaoh'] < df_summary['# iCloud']) | (df_summary['Pharaoh'] < df_summary['iCloud']))
df_summary.loc[cond, 'Status'] = 'Transfer KO ?'

cond = df_summary['Status'].isna()
cond &= ~df_summary['# iCloud'].isna()
cond &= ~df_summary['# Pharaoh'].isna()
cond &= ~(df_summary['# Pharaoh'] == df_summary['# iCloud'])
df_summary.loc[cond, 'Status'] = 'Transfer KO'

cond = df_summary['Status'].isna()
cond &= ~df_summary['# iCloud'].isna()
cond &= ~df_summary['# Pharaoh'].isna()
cond &= ~(df_summary['# Pharaoh'] == df_summary['# iCloud'])
cond &= ~((df_summary['# Pharaoh'] < df_summary['# iCloud']) | (df_summary['Pharaoh'] < df_summary['iCloud']))
df_summary.loc[cond, 'Status'] = 'Transfer KO ?'

cond = df_summary['Status'].isna()
cond &= df_summary['# iCloud'].isna()
cond &= ~df_summary['# Pharaoh'].isna()
df_summary.loc[cond, 'Status'] = 'To be transferred'

df_summary.sort_values( by=['Folder'], inplace=True )
df_summary.to_excel("imap.xlsx")  

print( len(df_summary[df_summary['Status'].isin(['Transfer KO ?', 'To be transferred', 'Transfer KO' ])]))

os.system(f'open "imap.xlsx"')

print("completed")