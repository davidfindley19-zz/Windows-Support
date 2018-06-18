# Windows-Support
A small collection of scripts I used daily. 

# AD Account Creation.ps1
Written to simplify the account creation process for an enterprise environment. This takes the first and last name and generates a "standard" username of first initial and last name. You can also hard code in the address and a few other details. These variables are used to create a hashtable and then it creates the account. Since the company I work for is small, we have a finite number of teams in our environment. So, you're prompted for a team name and it'll add that account to the proper base distribution/security groups. The script wraps up by initiating a remote Powershell session to your Exchange server and enabling the new users mailbox. 

# AD Account GUI.ps1
An alpha GUI version of the above tool. Keep checking for updates. 

# Driver_Install.ps1
A short script written to determine if a machine was running Windows 10 or Windows 7. It would then install the necessary driver pack. This was mostly to solve some issues with the Dell WD15 dock in our environment. 

# HTML Signature Update.ps1
This was created to allow IT to generate an HTML signature for a new users. Existing, if necessary. We all have a standard signature with the same formatting, so we just needed to create some variables and plug in the user's information. This outputs a customized HTML signature for Outlook. 

# List_Printers.ps1
This was written to get a list of printers installed on a remote machine. You input a computer name and username and it'll generate a list of installed printers. If nothing is entered for the prompts, it'll search the local machine. 
