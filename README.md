# collect-server-info.bat

This repository contains a batch script for Windows servers to collect:
- Domain NetBIOS Name (or Workgroup for non-domain servers)
- Computer Name
- IP Address

## Usage
Run `collect-server-info.bat` on a Windows server. The script will display the required information and indicate whether the server is domain-joined or not.

**Disclaimer:**
ONLY WINDOWS SERVERS ARE SUPPORTED. FOR WINDOWS SERVERS THAT ARE NOT PART OF DOMAIN, THEIR WORKGROUP IS USED AS DOMAIN NETBIOS NAME.

## Output Example
```
################################################
      ONLY WINDOWS SERVERS ARE SUPPORTED!
FOR WINDOWS SERVERS THAT ARE NOT PART OF DOMAIN,
 THEIR WORKGROUP IS USED AS DOMAIN NETBIOS NAME
################################################

IS THIS SERVER PART OF A DOMAIN: YES/NO

USE THE FOLLOWING INFORMATION TO CONFIGURE
    REMOTE OFFICE IN PATCH MANAGER PLUS

Domain NetBios Name: MITEL
Computer Name: SESAP
IP Address: 10.10.10.10
## Debug Output

The script now supports a debug output flag. To enable debug output, set the following line near the top of `collect-server-info.bat`:

```
set "DEBUG=1"
```

When `DEBUG=1`, raw values for domain, NetBIOS domain, computer name, IP address, and USERDOMAIN will be printed. Set `DEBUG=0` to suppress debug output.
```
