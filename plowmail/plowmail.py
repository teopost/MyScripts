#!/usr/bin/env python

#
# Plowmail is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Plowmail is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Plowmail.  If not, see <http://www.gnu.org/licenses/>.
#
# Check mail from gmail account and download files link extracted from mail body
# This script work only with plowshare software (http://code.google.com/p/plowshare/)
# Many thanks to Tokland

# Crontab schedule sample
# 0,15,36,45 * * * * /stage/plowmail/plowmail.py >> /dev/null 2>&1

# rel. 1.0, 30 april 2010 - Author: Stefano Teodorani - teopost@gmail.com
# please visit www.uielinux.org

import os
import sys
import shutil
import imaplib
import string
import email
import tempfile
import smtplib
import subprocess
import datetime
import ConfigParser
import time

from email.MIMEText import MIMEText
#from subprocess import Popen, PIPE

v_LOG_FILE='plowmail.log'

# Extract plowmail.py path
AppPath=os.path.realpath(os.path.dirname(sys.argv[0]))


# Check for single instance script execution
# ------------------------------------------
class SingleInstance:
    def __init__(self):
        import sys
        self.lockfile = os.path.normpath(tempfile.gettempdir() + '/' + os.path.basename(__file__) + '.lock')
        if sys.platform == 'win32':
            try:
                # file already exists, we try to remove (in case previous execution was interrupted)
                if(os.path.exists(self.lockfile)):
                    os.unlink(self.lockfile)
                self.fd =  os.open(self.lockfile, os.O_CREAT|os.O_EXCL|os.O_RDWR)
            except OSError, e:
                if e.errno == 13:
                    print "Another instance is already running, quitting."
                    sys.exit(-1)
                print e.errno
                raise
        else: # non Windows
            import fcntl, sys
            self.fp = open(self.lockfile, 'w')
            try:
                fcntl.lockf(self.fp, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except IOError:
                print "Another instance is already running, quitting."
                sys.exit(-1)

    def __del__(self):
        import sys
        if sys.platform == 'win32':
            if hasattr(self, 'fd'):
                os.close(self.fd)
                os.unlink(self.lockfile)

class p2p_check_account:
    def __init__(self, link):
        self.ulink = link

    def registered(self):
        retvalue=False
        if self.ulink == 'MEGAUPLOAD':
            if v_MU_PASSWORD != '':
                retvalue=True
        if self.ulink == 'RAPIDSHARE':
            if v_RS_PASSWORD != '':
                retvalue=True
        return retvalue

    def user(self):
        retvalue=''
        if self.ulink == 'MEGAUPLOAD':
            if v_MU_USER != '':
                retvalue=v_MU_USER
        if self.ulink == 'RAPIDSHARE':
            if v_RS_USER != '':
                retvalue=v_RS_USER
        return retvalue

    def password(self):
        retvalue=''
        if self.ulink == 'MEGAUPLOAD':
            if v_MU_PASSWORD != '':
                retvalue=v_MU_PASSWORD
        if self.ulink == 'RAPIDSHARE':
            if v_RS_PASSWORD != '':
                retvalue=v_RS_PASSWORD
        return retvalue


def runCmd(cmd, timeout=None):
    '''
    Will execute a command, read the output and return it back.

    @param cmd: command to execute
    @param timeout: process timeout in seconds
    @return: a tuple of three: first stdout, then stderr, then exit code
    @raise OSError: on missing command or if a timeout was reached
    '''

    ph_out = None # process output
    ph_err = None # stderr
    ph_ret = None # return code

    p = subprocess.Popen(cmd, shell=True,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    # if timeout is not set wait for process to complete
    if not timeout:
        ph_ret = p.wait()
    else:
        fin_time = time.time() + timeout
        while p.poll() == None and fin_time > time.time():
            time.sleep(1)

        # if timeout reached, raise an exception
        if fin_time < time.time():

            # starting 2.6 subprocess has a kill() method which is preferable
            # p.kill()
            os.kill(p.pid, signal.SIGKILL)
            raise OSError("Process timeout has been reached")

        ph_ret = p.returncode


    ph_out, ph_err = p.communicate()

    return (ph_out, ph_err, ph_ret)

# Analyze link string. Return link type (eg: MEGAUPLOAD), and FILE or FOLDER string
def analyze_link(link_string):
    RetValue=''
    RetValue2=''

    link_string=link_string.upper().strip()
    if link_string.find('MEGAUPLOAD.COM') > 0:
        RetValue='MEGAUPLOAD'
        
        if link_string.find('/?F=') > 0:
           RetValue2='FOLDER'
        else:
           RetValue2='FILE'

    if link_string.find('RAPIDSHARE.COM') > 0:
        RetValue='RAPIDSHARE'
        RetValue2='FILE'

    return RetValue, RetValue2


# Read configuration file
# If not found create it and exit
# -------------------------------------------------------
def read_config_file():
    if not os.path.exists(AppPath + '/plowmail.conf'):
       create_config_file()
       print "Creating config file..."
       sys.exit(-1)

    global v_DNL_TAG
    global v_DEBUG_LEVEL
    global v_ARCHIVE_MAIL
    global v_SEND_MAIL
    global v_PLOWSHARE_PATH

    global v_GMAIL_LOGIN
    global v_GMAIL_PASSWORD

    global v_MU_USER
    global v_MU_PASSWORD

    global v_RS_USER
    global v_RS_PASSWORD

    config = ConfigParser.RawConfigParser()
    config.read(AppPath + '/plowmail.conf')

    v_DNL_TAG=config.get('parameters', 'tag')
    v_DEBUG_LEVEL=config.getint('parameters', 'debug_level')
    v_ARCHIVE_MAIL=config.getint('parameters', 'archive_processed_mail')
    v_SEND_MAIL=config.getint('parameters', 'send_mail')

    v_PLOWSHARE_PATH=config.get('parameters', 'plowshare_path')

    v_GMAIL_LOGIN = config.get('gmail_account', 'login')
    v_GMAIL_PASSWORD = config.get('gmail_account', 'password')

    v_MU_USER = config.get('megaupload_account', 'mu_user')
    v_MU_PASSWORD = config.get('megaupload_account', 'mu_password')

    v_RS_USER = config.get('rapidshare_account', 'rs_user')
    v_RS_PASSWORD = config.get('rapidshare_account', 'rs_password')


# Create a template configurazion file
# ---------------------------------------
def create_config_file():
    config = ConfigParser.ConfigParser()

    config.add_section("parameters")
    config.set("parameters", "tag", "[UIEBOX]")
    config.set("parameters", "debug_level", "1")
    config.set("parameters", "archive_processed_mail", "1")
    config.set("parameters", "send_mail", "0")
    config.set("parameters", "plowshare_path", "/usr/local/bin")

    config.add_section("gmail_account")
    config.set("gmail_account", "login", "<Enter yout gmail username (es: john_doe@gmail.com)>")
    config.set("gmail_account", "password", "<Enter your gmail password>")

    config.add_section("megaupload_account")
    config.set("megaupload_account", "mu_user", "<Enter here you megaupload username>")
    config.set("megaupload_account", "mu_password", "<Enter here you megaupload password>")


    config.add_section("rapidshare_account")
    config.set("rapidshare_account", "rs_user", "<Enter here you rapidshare username>")
    config.set("rapidshare_account", "rs_password", "<Enter here you rapidshare password>")

    j = open(AppPath + '/' + 'plowmail.conf', 'wb')
    config.write(j)
    j.close()

# Send an email
# -------------
def send_email(subject, message, to_addr, from_addr):
    msg = MIMEText(message)
    msg['Subject'] = subject
    msg['From'] = from_addr
    msg['To'] = to_addr

    server = smtplib.SMTP('smtp.gmail.com',587) #port 465 or 587
    server.ehlo()
    # server.set_debuglevel(1)
    server.starttls()
    server.login(v_GMAIL_LOGIN, v_GMAIL_PASSWORD)
    server.sendmail(from_addr, to_addr, msg.as_string())
    server.quit()
    server.close()


# Extract text from email body message. Check if multipart
# --------------------------------------------------------
def decode_body(msg):
    RetValue=''

    if not msg.is_multipart():
        RetValue = msg.get_payload(decode=True)
    else:
        for part in msg.walk():
            if part.get_content_type() == 'application/msword':
                name = part.get_param('name') or 'MyDoc.doc'
                f = open(name, 'wb')
                f.write(part.get_payload(None, True))
                f.close()
            if part.get_content_type() == 'text/plain':
                RetValue = part.get_payload(decode=True)


    return RetValue


# Write log file
# --------------
def log(Message):
    # 1 = file, 2 = standard output
    l_out = 1
    if not os.path.exists(AppPath + '/' + v_LOG_FILE):
        if l_out == 1:
           h = open(AppPath + '/' + v_LOG_FILE, 'a')
           h.write('UIELINUX plowmail starting up\n')
           h.write('=============================\n')
           h.close()
        if l_out == 2:
           print 'UIELINUX plowmail starting up'
           print '============================='

    h = open(AppPath + '/' + v_LOG_FILE, 'a')
    if Message == '':
        h.write('\n')
    else:
        if l_out == 1:
           h.write(datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S") + ': ' + Message + '\n')
        if l_out == 2:
           print datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S") + ': ' + Message 
    h.close()

# ------------------------
# MAIN
# ------------------------
if __name__ == "__main__":
    me = SingleInstance()  
    read_config_file()
    Flagged=0
    
    v_plowlist = v_PLOWSHARE_PATH + '/' + 'plowlist'
    v_plowdown = v_PLOWSHARE_PATH + '/' + 'plowdown'

    # Open gmail connection
    M=imaplib.IMAP4_SSL('imap.gmail.com', 993)

    if v_DEBUG_LEVEL == 1:
        log('Check mail')

    try:
        M.login(v_GMAIL_LOGIN, v_GMAIL_PASSWORD)
    except Exception,e:
        log('ERROR: Login failed. Error: ' + e)
        sys.exit()

    M.select() 
    #status, count = M.select() 
    status, count = M.search(None, '(UNSEEN SUBJECT "' + v_DNL_TAG + '")')
 
    log('Total mail count: ' + str(count[0]))
    
    if count[0] == 0:
        if v_DEBUG_LEVEL == 1:
            log('No mail found')
    else:
        if v_DEBUG_LEVEL == 1:
            log(str(count[0]) + ' mail(s) found')

    if status == 'OK':
        # for i in range(1, string.atoi(count[0])+1):
        
        for i in count[0].split():
            
            status, mailstring = M.fetch(i, '(RFC822)')
            msg = email.message_from_string(mailstring[0][1])

            # If object contain TAG string and it start from begin position...
            if msg.get('subject').upper().strip().find(v_DNL_TAG)==0:
                emailSender=msg.get('from')[msg.get('from').find("<")+1:msg.get('from').find(">")]

                log('Processing mail ' + str(i) + ' of ' + str(count[0]) + ' received from: ' + msg.get('from'))
                log('..Found tag %s on subject' % v_DNL_TAG)

                log("..I'm working on: " + AppPath)

                # print 'Processing mail: %i' % i
                # print '========================'
                # print 'From: %s' %  (msg.get('from'))

                # print 'Sender email: %s' %  (emailSender)
                # print 'Sender: %s' %  (msg.get('sender'))
                # print 'To: %s' %  (msg.get('to'))
                # print 'Subject: %s' %  (msg.get('subject'))
                # print 'Cc: %s' %  (msg.get('cc'))
                # print 'Bcc: %s' %  (msg.get('bcc'))
                # print 'Date: %s' %  (msg.get('date'))
                # print 'Headers: %s' %  (msg.get('Delivered-To'))
                # print 'In-reply-to: %s' %  (msg.get('in-reply-to'))
                # print 'Message-id: %s' %  (msg.get('message-id'))
                # print 'Reply-to: %s' %  (msg.get('reply-to'))
                # print 'Received: %s' % (msg.get('received'))
                # print 'Is multipart: %s' % (msg.is_multipart())
                # print 'Body: \n%s' %  decode_body(msg)

                # Folder name creation. Remove junk characters
                mygui = '_' + msg.get('subject').replace(' ', '_')
                mygui = mygui.replace('[','')
                mygui = mygui.replace(']','')
                mygui = mygui.replace('_-_','_')
                mygui = mygui.replace("'",'')
                mygui1 = mygui + '_source'
                mygui2 = mygui + '_expanded'

                os.chdir(AppPath)

                # If exist, remove directory
                # shutil.rmtree('./' + mygui, True)

                # If folder not exist create it
                if not os.path.exists('./' + mygui):
                    os.mkdir('./' + mygui)

                os.chdir('./' + mygui)

                # Write extracted mail body
                # -------------------------
                f = open(mygui1 + '.txt', 'wb')
                f.write(decode_body(msg).replace(' ','').replace('\r',''))
                f.close()

                # Write mail dump (for debug purpose)
                # -----------------------------------
                f = open('email.eml', 'wb')
                f.write(mailstring[0][1].replace('\r',''))
                f.close()

                # Check if file contain folder link and expand it with plowlist
                # -------------------------------------------------------------
                rr = open(mygui1 + '.txt', 'rb')
                rw = open(mygui2 + '.txt', 'wb')
                for link in rr.readlines():
                    link_type,link_type2=analyze_link(link)
                    if link_type != '':
                        link = link.replace('\n','').replace('\r','')
                        if link_type2 == 'FOLDER':
                            log('..Detected folder on link ' + link)
                            try:
                               ph_out, ph_err, ph_ret = runCmd(v_plowlist + ' -q ' + link)

                               if ph_ret != 0:
                                   log('Error calling plowlist: ' + ph_out)
                                   log(v_plowlist + ' -q ' + link)
                                   sys.exit()

                               rw.write(ph_out)

                            except OSError, e:
                               log('....ERROR: Execution Check link failed:' + str(e))


                        if link_type2 == 'FILE':
                            log('..Detected file link (no folder) on ' + link)
                            rw.write(link+'\n')

                rr.close()
                rw.close()


                # Now, I check if links exists
                # ----------------------------
                log('..Check link(s)')
                rr = open(mygui2 + '.txt', 'rb')
                for link in rr.readlines():
                    link_type,link_type2=analyze_link(link)
                    if link_type != '':
                        link = link.replace('\n','').replace('\r','')
                        #log('..Detected ' + link_type + ' link type')
                        #log('....Verify of: ' + link)

                        try:
                            ph_out, ph_err, ph_ret = runCmd(v_plowdown + ' -c -v1 ' + link + '| wc -l')

                            if ph_ret != 0:
                               log('Failure %s:%s:%i' % (ph_out, ph_err, ph_ret))
                               sys.exit(-1)

                            lnk = int(ph_out)

                            if lnk == 0:
                               log('Link check error :%i for %s' % (lnk, link))
                               send_email(mygui2 + ': Link check error!', 'Link check error', emailSender, v_GMAIL_LOGIN)

                        except OSError, e:
                               log('....ERROR: Execution Check link failed:' + str(e))

                rr.close()

                # So, now read last expanded file for download
                # --------------------------------------------
                rr = open(mygui2 + '.txt', 'rb')
                for link in rr.readlines():
                    link_type,link_type2=analyze_link(link)
                    if link_type != '':
                        #link = link.replace('\n','').replace('\r','')

                        log('..Detected ' + link_type + ' link type')
                        log('....Start download of: ' + link)
                        try:
                            p2p = p2p_check_account(link_type)

                            if p2p.registered():
                                log('....Download WITH account')
                                ph_out, ph_err, ph_ret = runCmd(v_plowdown + ' -a '+ p2p.user() + ':' + p2p.password() + ' ' + link)
                            else:
                                log('....Download WITHOUT account')
                                ph_out, ph_err, ph_ret = runCmd(v_plowdown + ' ' + link)

                            if ph_ret != 0:
                               log('....Error calling plowdown, sterr: ' + ph_err)
                               sys.exit()

                        except OSError, e:
                            log('....ERROR: Execution failed:' + str(e))

                        log('....Download of ' + link + ' passed, retcode: ' + str(ph_ret))
                        log('Send noop. Keep alive?')
                        M.noop()
                        time.sleep(10)
                rr.close()

                log("..Plowdown system call passed")
                os.chdir("..")

                if v_SEND_MAIL==1:
                    log("Send mail to: " + emailSender)
                    send_email(mygui2 + ': Download finished!', 'Download finished', emailSender, v_GMAIL_LOGIN)
                
                M.store(i, '+FLAGS', '\\Seen')
                
            #if status == 'OK':
                try:
                    if v_ARCHIVE_MAIL==1:
                        M.store(i, '+FLAGS', '\\Deleted')
                        log('Mail flagged for archiving')
                        Flagged=1
                except Exception,e:
                    log('ERROR: Mail exception ' + str(e))
                    continue
            #else:
            #   M.store(i, '+FLAGS', '\\Seen')
            

    if Flagged==1:
        log('Archive flagged mail')
    M.expunge()
    M.close()
    M.logout()
