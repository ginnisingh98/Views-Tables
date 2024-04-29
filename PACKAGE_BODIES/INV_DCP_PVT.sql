--------------------------------------------------------
--  DDL for Package Body INV_DCP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DCP_PVT" as
/* $Header: INVDCPPB.pls 120.13 2006/12/06 13:21:41 amohamme noship $ */


G_PKG_NAME CONSTANT VARCHAR2(50) := 'INV_DCP_PVT';
g_userid            NUMBER;
g_user_email        VARCHAR2(32767);
g_user_name         VARCHAR2(32767);
g_env               VARCHAR2(32767);
G_DEBUG_ON          NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
G_DCP_MSG           VARCHAR2(32767);

Function get_email_server RETURN VARCHAR2
IS
l_debug_on             BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) :=G_PKG_NAME || '.' || 'GET_EMAIL_SERVER';

BEGIN
  --
  --
  IF g_debug_on = 1  THEN
     l_debug_on :=TRUE;
  else
     l_debug_on :=FALSE;
  END IF;
  --
 IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('Entering '||l_module_name,l_module_name,'9');
 END IF;
IF INV_DCP_PVT.g_email_server IS NOT NULL THEN
 IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('server name cache:'||INV_DCP_PVT.g_email_server,l_module_name,'9');
 END IF;
   RETURN INV_DCP_PVT.g_email_server;
END IF;
  INV_DCP_PVT.g_email_server := fnd_profile.value('INV_DCP_EMAIL_SERVER');
 IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('server name profile :'||INV_DCP_PVT.g_email_server,'9');
 END IF;
RETURN INV_DCP_PVT.g_email_server;

EXCEPTION
WHEN OTHERS THEN
 IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('When others error has occured. Oracle error message is '|| SQLERRM, l_module_name,'9');
 END IF;
  RETURN NULL;
END Get_email_server;

Function get_email_address RETURN VARCHAR2
IS
l_debug_on             BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) :=G_PKG_NAME || '.' || 'GET_EMAIL_ADDRESS';
BEGIN
  --
  IF g_debug_on = 1  THEN
     l_debug_on :=TRUE;
  else
     l_debug_on :=FALSE;
  END IF;
  --
 IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('Entering :'||l_module_name,'l_module_name','9');
 END IF;
IF INV_DCP_PVT.g_email_address IS NOT NULL THEN
  IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('Email Address cache :'||INV_DCP_PVT.g_email_address,l_module_name,'9');
  END IF;
   RETURN INV_DCP_PVT.g_email_address;
END IF;
INV_DCP_PVT.g_email_address := fnd_profile.value('INV_DCP_EMAIL_ADDRESSES');
  IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('Email Address profile :'||INV_DCP_PVT.g_email_address,l_module_name,'9');
  END IF;
RETURN INV_DCP_PVT.g_email_address;
EXCEPTION
WHEN OTHERS THEN
  IF l_debug_on THEN
   INV_LOG_UTIL.TRACE('When others error has occured. Oracle error message is ' || SQLERRM,l_module_name,'9');
  END IF;
  RETURN NULL;
END Get_email_address;


Procedure Send_Mail(sender     IN VARCHAR2,
                    recipient1 IN VARCHAR2,
                    recipient2 IN VARCHAR2,
                    recipient3 IN VARCHAR2,
                    recipient4 IN VARCHAR2,
                    message    IN VARCHAR2)
IS
l_mailhost             VARCHAR2(32767);
l_mail_conn            UTL_SMTP.CONNECTION;
l_email_addrs          VARCHAR2(32767);
l_spr                  VARCHAR2(30) := ',';
l_start_pos            NUMBER;
l_end_pos              NUMBER;
j                      NUMBER;
l_recipient1           VARCHAR2(32767);
l_recipient2           VARCHAR2(32767);
l_recipient3           VARCHAR2(32767);
l_recipient4           VARCHAR2(32767);
l_recipient5           VARCHAR2(32767);
l_sender               VARCHAR2(32767) := 'Oracle-Logistics-Data-Integrity-Check@oraclelogistics';
l_debug_on             BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) :=G_PKG_NAME || '.' || 'SEND_MAIL';

CURSOR c_env IS
SELECT name from v$database;

BEGIN
  --
  IF g_debug_on = 1  THEN
     l_debug_on :=TRUE;
  else
     l_debug_on :=FALSE;
  END IF;
  --
  --
 FOR c_env_rec in c_env loop
  l_sender := l_sender||'-'||c_env_rec.name;
 END LOOP;

 IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('Entering :'||l_module_name,l_module_name,'9');
    INV_LOG_UTIL.TRACE('sender: '||sender,l_module_name,'9');
    INV_LOG_UTIL.TRACE('recipient1: '||recipient1,l_module_name,'9');
    INV_LOG_UTIL.TRACE('recipient2: '||recipient2,l_module_name,'9');
    INV_LOG_UTIL.TRACE('recipient3: '||recipient3,l_module_name,'9');
    INV_LOG_UTIL.TRACE('recipient4: '||recipient4,l_module_name,'9');
 END IF;

 --Call function that will return the email server name
 l_mailhost := get_email_server;
 --Call function that will return the email addresses
 l_email_addrs := get_email_address;
 --Parse to get individual recipients
  IF l_debug_on THEN
     INV_LOG_UTIL.TRACE('l_mailhost: '||l_mailhost,l_module_name,'9');
     INV_LOG_UTIL.TRACE('l_email_addrs: '||l_email_addrs,l_module_name,'9');
  END IF;
 IF l_mailhost IS NOT NULL
   AND l_email_addrs IS NOT NULL
 THEN
 --{
 l_mail_conn := utl_smtp.open_connection(l_mailhost, 25);
 j := 1;  l_start_pos := 1;  l_end_pos := instrb(l_email_addrs, l_spr, 1, j);
 if l_end_pos = 0 then
    l_end_pos := lengthb(l_email_addrs) + 1;
 end if;
 l_recipient1 := substrb(l_email_addrs, l_start_pos, l_end_pos-l_start_pos);
 j := j+1;  l_start_pos := l_end_pos + 1;  l_end_pos := instrb(l_email_addrs, l_spr, 1, j);
 if l_end_pos = 0 then
    l_end_pos := lengthb(l_email_addrs) + 1;
 end if;
 l_recipient2 := substrb(l_email_addrs, l_start_pos, l_end_pos-l_start_pos);
 j := j+1;  l_start_pos := l_end_pos + 1;  l_end_pos := instrb(l_email_addrs, l_spr, 1, j);
 if l_end_pos = 0 then
    l_end_pos := lengthb(l_email_addrs) + 1;
 end if;
 l_recipient3 := substrb(l_email_addrs, l_start_pos, l_end_pos-l_start_pos);
 j := j+1;  l_start_pos := l_end_pos + 1;  l_end_pos := instrb(l_email_addrs, l_spr, 1, j);
 if l_end_pos = 0 then
    l_end_pos := lengthb(l_email_addrs) + 1;
 end if;
 l_recipient4 := substrb(l_email_addrs, l_start_pos, l_end_pos-l_start_pos);
 j := j+1;  l_start_pos := l_end_pos + 1;
l_end_pos := instrb(l_email_addrs, l_spr, 1, j);
 if l_end_pos = 0 then
    l_end_pos := lengthb(l_email_addrs) + 1;
 end if;
 l_recipient5 := substrb(l_email_addrs, l_start_pos, l_end_pos-l_start_pos);
   IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('Now sender :'||l_sender,l_module_name,'9');
    INV_LOG_UTIL.TRACE('Now recipient1: '||l_recipient1,l_module_name,'9');
    INV_LOG_UTIL.TRACE('Now recipient2: '||l_recipient2,l_module_name,'9');
    INV_LOG_UTIL.TRACE('Now recipient3: '||l_recipient3,l_module_name,'9');
    INV_LOG_UTIL.TRACE('Now recipient4: '||l_recipient4,l_module_name,'9');
    INV_LOG_UTIL.TRACE('Now recipient5: '||l_recipient5,l_module_name,'9');
   END IF;
   utl_smtp.helo(l_mail_conn, l_mailhost);
   utl_smtp.mail(l_mail_conn, l_sender);
  IF l_recipient1 IS NOT NULL THEN
    utl_smtp.rcpt(l_mail_conn,l_recipient1);
  END IF;
  IF l_recipient2 IS NOT NULL THEN
    utl_smtp.rcpt(l_mail_conn,l_recipient2);
  END IF;
  IF l_recipient3 IS NOT NULL THEN
    utl_smtp.rcpt(l_mail_conn,l_recipient3);
  END IF;
  IF l_recipient4 IS NOT NULL THEN
   utl_smtp.rcpt(l_mail_conn,l_recipient4);
  END IF;
  IF l_recipient5 IS NOT NULL THEN
   utl_smtp.rcpt(l_mail_conn,l_recipient5);
  END IF;
  utl_smtp.data(l_mail_conn,message);
  utl_smtp.quit(l_mail_conn);
ELSE
  IF l_debug_on THEN
     INV_LOG_UTIL.TRACE('Not sending mail. Server Name or Email id is null',l_module_name,'9');
  END IF;
--}
END IF;
  IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('Exiting :'||l_module_name,l_module_name,'9');
  END IF;
EXCEPTION
WHEN others THEN
  IF l_debug_on THEN
     INV_LOG_UTIL.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM,l_module_name,'9');
     INV_LOG_UTIL.TRACE('EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR',l_module_name,'9');
  END IF;
END Send_Mail;


/*====================================================================================
FUNCTION NAME:	add_serial_data

DESCRIPTION:   	This function adds Serial status/Action related data to global table

=====================================================================================*/

FUNCTION add_serial_data(trx_qty IN NUMBER,
                         serial_control_code IN NUMBER,
                         xfer_org NUMBER,
                         inv_item_id NUMBER
                         ) RETURN BOOLEAN
IS
xfer_ser_num_code number :=0;
BEGIN
/*
for 21 if serial_number_control_code in transfer_org is in 2,5 then expected serial_status=5 else serial_status=4
for 3 if serial_number_control_code in transfer_org is in 2,5 then expected serial_status=3 else serial_status=4
*/
BEGIN
 if (xfer_org is not null and inv_item_id is not null) then
  select SERIAL_NUMBER_CONTROL_CODE
  into   xfer_ser_num_code
  from mtl_system_items
  where organization_id = xfer_org
  and inventory_item_id = inv_item_id;
 end if;
EXCEPTION
 WHEN OTHERS THEN
   return FALSE;
END;

g_ser_check_tab(1).serial_status := 4;
g_ser_check_tab(2).serial_status := 3;
if xfer_ser_num_code in (2,5) then
  g_ser_check_tab(3).serial_status := 3;
else
  g_ser_check_tab(3).serial_status := 3;
end if;
if (trx_qty > 0) then
  g_ser_check_tab(4).serial_status := 3;
else
  g_ser_check_tab(4).serial_status := 4;
end if;
g_ser_check_tab(5).serial_status := 3;
g_ser_check_tab(6).serial_status := 3;
g_ser_check_tab(7).serial_status := 3;
if (trx_qty > 0) then
 g_ser_check_tab(8).serial_status := 3;
else
 g_ser_check_tab(8).serial_status := 4;
end if;
g_ser_check_tab(9).serial_status := 3;
g_ser_check_tab(10).serial_status := 3;
g_ser_check_tab(11).serial_status := 3;
g_ser_check_tab(12).serial_status := 3;
g_ser_check_tab(13).serial_status := 3;
g_ser_check_tab(14).serial_status := 3;
g_ser_check_tab(15).serial_status := 3;
g_ser_check_tab(17).serial_status := 3;

if xfer_ser_num_code in (2,5,6) then
 g_ser_check_tab(21).serial_status := 5;
else
 g_ser_check_tab(21).serial_status := 4;
end if;

g_ser_check_tab(22).serial_status := 3;
g_ser_check_tab(24).serial_status := 3;
g_ser_check_tab(25).serial_status := 3;
g_ser_check_tab(26).serial_status := 3;
if (serial_control_code = 6) then
 g_ser_check_tab(27).serial_status := 1;
else
 g_ser_check_tab(27).serial_status := 3;
end if;
g_ser_check_tab(28).serial_status := 3;
if (trx_qty > 0) then
  g_ser_check_tab(29).serial_status := 3;
else
  g_ser_check_tab(29).serial_status := 4;
end if;
g_ser_check_tab(30).serial_status := 4;
g_ser_check_tab(31).serial_status := 3;
g_ser_check_tab(32).serial_status := 4;
g_ser_check_tab(33).serial_status := 3;
g_ser_check_tab(34).serial_status := 4;
g_ser_check_tab(35).serial_status := 3;
g_ser_check_tab(36).serial_status := 3;
g_ser_check_tab(40).serial_status := 3;
g_ser_check_tab(41).serial_status := 3;
g_ser_check_tab(42).serial_status := 3;
g_ser_check_tab(43).serial_status := 3;
g_ser_check_tab(50).serial_status := 3;
g_ser_check_tab(51).serial_status := 3;
g_ser_check_tab(52).serial_status := 3;
g_ser_check_tab(55).serial_status := 3;
g_ser_check_tab(56).serial_status := 3;
g_ser_check_tab(57).serial_status := 3;
RETURN TRUE;
END add_serial_data;




/*===========================================================================
FUNCTION NAME:	is_dcp_enabled

DESCRIPTION:   	This function returns the DCP profile

===========================================================================*/

FUNCTION is_dcp_enabled RETURN NUMBER
IS
BEGIN

  IF INV_DCP_PVT.g_check_dcp IS NOT NULL
  THEN
     RETURN(INV_DCP_PVT.g_check_dcp);
  END IF;
  --
  INV_DCP_PVT.g_check_dcp := nvl(fnd_profile.value('INV_ENABLE_DCP'), 0);
  --
  RETURN INV_DCP_PVT.g_check_dcp;

EXCEPTION
when others then
RETURN 0;
END is_dcp_enabled;

PROCEDURE Post_Process(p_action_code IN VARCHAR2,
                       p_raise_exception IN VARCHAR2)
IS
l_call_stack           VARCHAR2(32767);
l_message              VARCHAR2(32767);
l_debug_file           VARCHAR2(32767);
l_debug_dir            VARCHAR2(32767);
l_debug_on             BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) :=G_PKG_NAME || '.' || 'POST_PROCESS';
k                      NUMBER;
l_rollback_allowed     VARCHAR2(1);
l_return_status        VARCHAR2(30);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(32767);
l_conc_request_id      NUMBER;
l_utl_file_locns       VARCHAR2(32767);
l_dbg_file             VARCHAR2(2000);
l_module               VARCHAR2(32767);
l_level                NUMBER;
l_dir                  VARCHAR2(32767);
l_comma_pos            NUMBER;
l_curr_msg_count       NUMBER := 0;
l_recipient1           VARCHAR2(32767);
l_recipient2           VARCHAR2(32767);
l_recipient3           VARCHAR2(32767);
l_temp_message         VARCHAR2(32767);
L_NDX                  VARCHAR2(1);
crlf       CONSTANT VARCHAR2 (2)        := fnd_global.local_chr(13) || fnd_global.local_chr(10);

CURSOR c_user_info(p_user_id IN NUMBER) IS
SELECT user_name, email_address
FROM fnd_user
WHERE user_id = p_user_id;

CURSOR c_utl_file IS
SELECT rtrim(ltrim(value)) from v$parameter
WHERE lower(name) = 'utl_file_dir';

CURSOR c_env IS
SELECT name from v$database;

l_om_debug_enabled VARCHAR2(30);
l_file_name varchar2(2000);
l_dir_separator varchar2(1);
BEGIN

/***
 a) Check if debug is ON
 b) If rollback is allowed and debug is off then Turn debug ON and Raise Exception
 c) If rollback is allowed and debug is ON then Collect all information and Finally Send email. If debug was turned on by DCP then turn it off.
 d) If rollback is NOT allowed then Collect information, put the information in a new debug file and Send email
*****/

  --
  IF g_debug_on = 1  THEN
     l_debug_on :=TRUE;
  else
     l_debug_on :=FALSE;
  END IF;
  --
 IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('Entering :'||l_module_name,l_module_name,'9');
    INV_LOG_UTIL.TRACE('p_action_code'||p_action_code,l_module_name,'9');
    INV_LOG_UTIL.TRACE('p_raise_exception'||p_raise_Exception,l_module_name,'9');
 END IF;
 l_rollback_allowed := nvl(p_raise_exception, 'Y');
 IF g_userid IS NULL THEN
    fnd_profile.get('USER_ID',g_userid);
    OPEN c_user_info(g_userid);
    FETCH c_user_info INTO g_user_name, g_user_email;
    CLOSE c_user_info;
 END IF;
 IF g_env IS NULL THEN
    OPEN c_env;
    FETCH c_env INTO g_env;
    CLOSE c_env;
 END IF;
 l_conc_request_id := fnd_global.conc_request_id;
if (l_conc_request_id=0) then
  l_conc_request_id := NULL;
end if;
 IF l_debug_on THEN
       INV_LOG_UTIL.TRACE('User Id'||g_userid,l_module_name,'9');
       INV_LOG_UTIL.TRACE('User Name'||g_user_name,l_module_name,'9');
       INV_LOG_UTIL.TRACE('Env'||g_env,l_module_name,'9');
 END IF;
IF (g_dc_table.count > 0) THEN
---{
     -- Turn debug on
     -- Changes - Get INV Debug Directory and if it is valid use it with new filename. If it is not then use from utl_file_dir paramater
    fnd_profile.get('INV_DEBUG_FILE',l_dbg_file);
    OPEN c_utl_file;
    FETCH c_utl_file INTO l_utl_file_locns;
    CLOSE c_utl_file;
      l_dir_separator := '/';
      l_ndx := instr(l_dbg_file,l_dir_separator);
      IF (l_ndx = 0) then
       l_dir_separator := '\';
      END IF;
   ----Validate that Filename in profile is correct
      l_debug_dir := nvl(substr(l_dbg_file,1,instr(l_dbg_file,l_dir_separator,-1,1)-1),'-999');
     IF (l_utl_file_locns <> '*') THEN  --{
      IF (INSTRB(l_utl_file_locns,l_debug_dir) = 0) THEN  ---{
   --- Filename in profile is incorrect, generate a new one.
	l_comma_pos := INSTRB(l_utl_file_locns, ',');
	if (l_comma_pos <> 0) then
		l_debug_dir := SUBSTRB(l_utl_file_locns, 1, l_comma_pos-1);
	else
		l_debug_dir := l_utl_file_locns;
	end if;
	l_dir_separator := '/';
	l_ndx := instr(l_debug_dir,l_dir_separator);
	if (l_ndx = 0) then
	 l_dir_separator := '\';
	end if;
	l_file_name := l_debug_dir||l_dir_separator||'INV_DCP'||userenv('SESSIONID')||'.dbg';
        fnd_profile.put('INV_DEBUG_FILE',l_file_name);
      ELSE  ---}{
       IF NOT l_debug_on THEN
       --- Filename in profile is correct but debug is off, Lets generate a new filename
         l_file_name := l_debug_dir||l_dir_separator||'INV_DCP'||userenv('SESSIONID')||'.dbg';
       ELSE
         --- Filename in profile is correct, Lets use it
         l_file_name :=l_dbg_file;
       END IF;
     END IF;  ---}
    ELSE ----}{
     IF NOT l_debug_on THEN
         l_file_name :=l_dir_separator||'tmp'||l_dir_separator||'INV_DCP'||userenv('SESSIONID')||'.dbg';
     ELSE
       l_file_name :=l_dbg_file;
     END IF;
    END IF;  ---}
   IF NOT l_debug_on THEN
     fnd_profile.put('INV_DEBUG_FILE',l_file_name);
     fnd_profile.put('INV_DEBUG_LEVEL','9');
     fnd_profile.put('INV_DEBUG_TRACE','1');
     G_DEBUG_STARTED :='Y';
     l_debug_on :=TRUE;
     G_DEBUG_ON := 1;
     IF l_debug_on THEN
       INV_LOG_UTIL.TRACE('DCP - Started Debugger',l_module_name,'9');
     END IF;
    END IF;
IF l_debug_on THEN
 INV_LOG_UTIL.TRACE('l_debug_file :'||l_file_name,l_module_name,'9');
END IF;
--}
IF l_debug_on THEN
 INV_LOG_UTIL.TRACE('==========================================',l_module_name,'9');
 INV_LOG_UTIL.TRACE(G_DCP_MSG,l_module_name,'9');
 INV_LOG_UTIL.TRACE('==========================================',l_module_name,'9');
 INV_LOG_UTIL.TRACE('l_debug_dir :'||l_debug_dir,l_module_name,'9');
 INV_LOG_UTIL.TRACE('g_dc_table count :'|| g_dc_table.count,l_module_name,'9');
 INV_LOG_UTIL.TRACE('l_rollback_allowed :'||l_rollback_allowed,l_module_name,'9');
 INV_LOG_UTIL.TRACE('conc request id :'||l_conc_request_id,l_module_name,'9');
END IF;
 IF (l_rollback_allowed = 'Y') THEN
    raise dcp_caught;
 END IF;
 --{
    --Get CallStack
   l_message := 'Subject: INV Data inconsistency detected for '||g_user_name||' in '||g_env||crlf||crlf;
   l_message := l_message ||crlf||'Action Performed:'||p_action_code;
   if nvl(l_conc_request_id, -1) <> -1 then
     l_message := l_message ||'
Data Inconsistency found in environment ' || g_env || ' for concurrent request id ' || l_conc_request_id || ' submitted by user ' || g_user_name||'.
Debug file for this transaction= '||l_file_name||'.';
   else
         l_message := l_message || '
Data Inconsistency found in environment ' || g_env || ' for a transaction run by user ' || g_user_name || '
Debug file for this transaction= ' || l_file_name||'. ';
   end if;
       --
       -- dump the call stack and pl/sql table
       -- if global was set , turn debug off
       -- Put CallStack in debug file
       if l_debug_on then
          l_call_stack := dbms_utility.format_call_stack;
          INV_LOG_UTIL.TRACE('**********Begining of Call Stack**********',l_module_name,'9');
          INV_LOG_UTIL.TRACE(l_call_stack,l_module_name,'9');
          INV_LOG_UTIL.TRACE('**********End of Call Stack**********',l_module_name,'9');
       end if;
       l_message := l_message||'
 ';
       l_message := l_message||'
********** Here are the Details **********';
       k := g_dc_table.first;
       WHILE k is not null LOOP
       --{
           l_temp_message := k||'. Data Mismatch #'||g_dc_table(k).msg||'.
(Org:'||g_dc_table(k).organization_code||', Item:'||g_dc_table(k).item_name||', Source:'||g_dc_table(k).source_type||', Action:'||g_dc_table(k).action_code||',';
           l_temp_message:= l_temp_message||' Trx Type:'||g_dc_table(k).trx_type||', header No: '||g_dc_table(k).trx_hdr_id ||', Trx Temp Id:'||g_dc_table(k).trx_temp_id||', Transfer org:'||g_dc_table(k).xfer_org_code||')';
           IF length(l_message) < 31900 THEN
              l_message := l_message ||'
 '|| l_temp_message||'. ';
           END IF;
          IF l_debug_on THEN
             INV_LOG_UTIL.TRACE(l_temp_message,l_module_name,'9');
          END IF;
          k := g_dc_table.next(k);
       --}
       END LOOP;
       l_message := l_message||'
********** End of the Details **********';
      --Send Email
          Send_Mail(sender => l_recipient1,
              recipient1 => l_recipient1,
              recipient2 => l_recipient2,
              recipient3 => l_recipient3,
              message => l_message);
  dump_mmtt;
  g_dc_table.delete;
   --}
--}
END IF;
-- Stop the debugger if it was started earlier
IF G_DEBUG_STARTED ='Y' THEN
 IF l_debug_on THEN
   INV_LOG_UTIL.TRACE('DCP - Stopped Debugger',l_module_name,'9');
   l_debug_on := FALSE;
 END IF;
   INV_debug_interface.stop_inv_debugger();
   G_DEBUG_STARTED :='N';
END IF;

EXCEPTION
WHEN dcp_caught THEN
   IF l_debug_on THEN
      INV_LOG_UTIL.TRACE('DCP Caught: Post Process',l_module_name,'9');
      INV_LOG_UTIL.TRACE('Exception: dcp_caught',l_module_name,'9');
   END IF;
   RAISE dcp_caught;
WHEN others THEN
  IF l_debug_on THEN
     INV_LOG_UTIL.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM,l_module_name,'9');
     INV_LOG_UTIL.TRACE('EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR',l_module_name,'9');
  END IF;
END Post_Process;

Procedure dump_mmtt is
l_debug_on             BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) :=G_PKG_NAME || '.' || 'DUMP_MMTT';
i NUMBER :=0;
CURSOR c1(trx_hdr_id in NUMBER,trx_temp_id IN NUMBER) is
  SELECT *
  FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
  WHERE TRANSACTION_HEADER_ID=trx_hdr_id
  AND TRANSACTION_TEMP_ID = trx_temp_id;
begin
IF g_debug_on = 1  THEN
  l_debug_on :=TRUE;
else
  l_debug_on :=FALSE;
END IF;
  IF l_debug_on THEN
   INV_LOG_UTIL.TRACE('=============Start of MMTT Data===============',l_module_name,'9');
  END IF;
FOR i in g_dc_table.FIRST..g_dc_table.LAST LOOP  ---{
 For c1_rec in c1(g_dc_table(i).trx_hdr_id,g_dc_table(i).trx_temp_id) loop
  IF l_debug_on THEN
   INV_LOG_UTIL.TRACE('===>Start of MMTT Record:'||i,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ACCT_PERIOD_ID:'||c1_rec.ACCT_PERIOD_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ALLOCATED_LPN_ID:'||c1_rec.ALLOCATED_LPN_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ALLOWED_UNITS_LOOKUP_CODE:'||c1_rec.ALLOWED_UNITS_LOOKUP_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ALTERNATE_BOM_DESIGNATOR:'||c1_rec.ALTERNATE_BOM_DESIGNATOR,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ALTERNATE_ROUTING_DESIGNATOR:'||c1_rec.ALTERNATE_ROUTING_DESIGNATOR,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE1:'||c1_rec.ATTRIBUTE1,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE10:'||c1_rec.ATTRIBUTE10,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE11:'||c1_rec.ATTRIBUTE11,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE12:'||c1_rec.ATTRIBUTE12,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE13:'||c1_rec.ATTRIBUTE13,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE14:'||c1_rec.ATTRIBUTE14,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE15:'||c1_rec.ATTRIBUTE15,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE2:'||c1_rec.ATTRIBUTE2,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE3:'||c1_rec.ATTRIBUTE3,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE4:'||c1_rec.ATTRIBUTE4,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE5:'||c1_rec.ATTRIBUTE5,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE6:'||c1_rec.ATTRIBUTE6,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE7:'||c1_rec.ATTRIBUTE7,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE8:'||c1_rec.ATTRIBUTE8,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE9:'||c1_rec.ATTRIBUTE9,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ATTRIBUTE_CATEGORY:'||c1_rec.ATTRIBUTE_CATEGORY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('BOM_REVISION:'||c1_rec.BOM_REVISION,l_module_name,'9');
   INV_LOG_UTIL.TRACE('BOM_REVISION_DATE:'||c1_rec.BOM_REVISION_DATE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('BUILD_SEQUENCE:'||c1_rec.BUILD_SEQUENCE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CARTONIZATION_ID:'||c1_rec.CARTONIZATION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CLASS_CODE:'||c1_rec.CLASS_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('COMMON_BOM_SEQ_ID:'||c1_rec.COMMON_BOM_SEQ_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('COMMON_ROUTING_SEQ_ID:'||c1_rec.COMMON_ROUTING_SEQ_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('COMPLETION_TRANSACTION_ID:'||c1_rec.COMPLETION_TRANSACTION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CONTAINERS:'||c1_rec.CONTAINERS,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CONTAINER_ITEM_ID:'||c1_rec.CONTAINER_ITEM_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CONTENT_LPN_ID:'||c1_rec.CONTENT_LPN_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('COST_GROUP_ID:'||c1_rec.COST_GROUP_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('COST_TYPE_ID:'||c1_rec.COST_TYPE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CREATED_BY:'||c1_rec.CREATED_BY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CREATION_DATE:'||c1_rec.CREATION_DATE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CURRENCY_CODE:'||c1_rec.CURRENCY_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CURRENCY_CONVERSION_DATE:'||c1_rec.CURRENCY_CONVERSION_DATE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CURRENCY_CONVERSION_RATE:'||c1_rec.CURRENCY_CONVERSION_RATE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CURRENCY_CONVERSION_TYPE:'||c1_rec.CURRENCY_CONVERSION_TYPE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CURRENT_LOCATOR_CONTROL_CODE:'||c1_rec.CURRENT_LOCATOR_CONTROL_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CUSTOMER_SHIP_ID:'||c1_rec.CUSTOMER_SHIP_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('CYCLE_COUNT_ID:'||c1_rec.CYCLE_COUNT_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('DEMAND_CLASS:'||c1_rec.DEMAND_CLASS,l_module_name,'9');
   INV_LOG_UTIL.TRACE('DEMAND_ID:'||c1_rec.DEMAND_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('DEMAND_SOURCE_DELIVERY:'||c1_rec.DEMAND_SOURCE_DELIVERY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('DEMAND_SOURCE_HEADER_ID:'||c1_rec.DEMAND_SOURCE_HEADER_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('DEMAND_SOURCE_LINE:'||c1_rec.DEMAND_SOURCE_LINE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('DEPARTMENT_CODE:'||c1_rec.DEPARTMENT_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('DEPARTMENT_ID:'||c1_rec.DEPARTMENT_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('DISTRIBUTION_ACCOUNT_ID:'||c1_rec.DISTRIBUTION_ACCOUNT_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('EMPLOYEE_CODE:'||c1_rec.EMPLOYEE_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ENCUMBRANCE_ACCOUNT:'||c1_rec.ENCUMBRANCE_ACCOUNT,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ENCUMBRANCE_AMOUNT:'||c1_rec.ENCUMBRANCE_AMOUNT,l_module_name,'9');
   INV_LOG_UTIL.TRACE('END_ITEM_UNIT_NUMBER:'||c1_rec.END_ITEM_UNIT_NUMBER,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ERROR_CODE:'||c1_rec.ERROR_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ERROR_EXPLANATION:'||c1_rec.ERROR_EXPLANATION,l_module_name,'9');
   INV_LOG_UTIL.TRACE('EXPECTED_ARRIVAL_DATE:'||c1_rec.EXPECTED_ARRIVAL_DATE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('EXPENDITURE_TYPE:'||c1_rec.EXPENDITURE_TYPE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('FINAL_COMPLETION_FLAG:'||c1_rec.FINAL_COMPLETION_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('FLOW_SCHEDULE:'||c1_rec.FLOW_SCHEDULE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('FOB_POINT:'||c1_rec.FOB_POINT,l_module_name,'9');
   INV_LOG_UTIL.TRACE('FREIGHT_CODE:'||c1_rec.FREIGHT_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('INTRANSIT_ACCOUNT:'||c1_rec.INTRANSIT_ACCOUNT,l_module_name,'9');
   INV_LOG_UTIL.TRACE('INVENTORY_ITEM_ID:'||c1_rec.INVENTORY_ITEM_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_DESCRIPTION:'||c1_rec.ITEM_DESCRIPTION,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_INVENTORY_ASSET_FLAG:'||c1_rec.ITEM_INVENTORY_ASSET_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_LOCATION_CONTROL_CODE:'||c1_rec.ITEM_LOCATION_CONTROL_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_LOT_CONTROL_CODE:'||c1_rec.ITEM_LOT_CONTROL_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_ORDERING:'||c1_rec.ITEM_ORDERING,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_PRIMARY_UOM_CODE:'||c1_rec.ITEM_PRIMARY_UOM_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_RESTRICT_LOCATORS_CODE:'||c1_rec.ITEM_RESTRICT_LOCATORS_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_RESTRICT_SUBINV_CODE:'||c1_rec.ITEM_RESTRICT_SUBINV_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_REVISION_QTY_CONTROL_CODE:'||c1_rec.ITEM_REVISION_QTY_CONTROL_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_SEGMENTS:'||c1_rec.ITEM_SEGMENTS,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_SERIAL_CONTROL_CODE:'||c1_rec.ITEM_SERIAL_CONTROL_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_SHELF_LIFE_CODE:'||c1_rec.ITEM_SHELF_LIFE_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_SHELF_LIFE_DAYS:'||c1_rec.ITEM_SHELF_LIFE_DAYS,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_TRX_ENABLED_FLAG:'||c1_rec.ITEM_TRX_ENABLED_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ITEM_UOM_CLASS:'||c1_rec.ITEM_UOM_CLASS,l_module_name,'9');
   INV_LOG_UTIL.TRACE('KANBAN_CARD_ID:'||c1_rec.KANBAN_CARD_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('LAST_UPDATED_BY:'||c1_rec.LAST_UPDATED_BY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('LAST_UPDATE_DATE:'||c1_rec.LAST_UPDATE_DATE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('LAST_UPDATE_LOGIN:'||c1_rec.LAST_UPDATE_LOGIN,l_module_name,'9');
   INV_LOG_UTIL.TRACE('LINE_TYPE_CODE:'||c1_rec.LINE_TYPE_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('LOCATOR_ID:'||c1_rec.LOCATOR_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('LOCATOR_SEGMENTS:'||c1_rec.LOCATOR_SEGMENTS,l_module_name,'9');
   INV_LOG_UTIL.TRACE('LOCK_FLAG:'||c1_rec.LOCK_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('LOGICAL_TRX_TYPE_CODE:'||c1_rec.LOGICAL_TRX_TYPE_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('LOT_ALPHA_PREFIX:'||c1_rec.LOT_ALPHA_PREFIX,l_module_name,'9');
   INV_LOG_UTIL.TRACE('LOT_EXPIRATION_DATE:'||c1_rec.LOT_EXPIRATION_DATE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('LOT_NUMBER:'||c1_rec.LOT_NUMBER,l_module_name,'9');
   INV_LOG_UTIL.TRACE('LPN_ID:'||c1_rec.LPN_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('MATERIAL_ACCOUNT:'||c1_rec.MATERIAL_ACCOUNT,l_module_name,'9');
   INV_LOG_UTIL.TRACE('MATERIAL_ALLOCATION_TEMP_ID:'||c1_rec.MATERIAL_ALLOCATION_TEMP_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('MATERIAL_OVERHEAD_ACCOUNT:'||c1_rec.MATERIAL_OVERHEAD_ACCOUNT,l_module_name,'9');
   INV_LOG_UTIL.TRACE('MOVEMENT_ID:'||c1_rec.MOVEMENT_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('MOVE_ORDER_HEADER_ID:'||c1_rec.MOVE_ORDER_HEADER_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('MOVE_ORDER_LINE_ID:'||c1_rec.MOVE_ORDER_LINE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('MOVE_TRANSACTION_ID:'||c1_rec.MOVE_TRANSACTION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('NEGATIVE_REQ_FLAG:'||c1_rec.NEGATIVE_REQ_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('NEW_AVERAGE_COST:'||c1_rec.NEW_AVERAGE_COST,l_module_name,'9');
   INV_LOG_UTIL.TRACE('NEXT_LOT_NUMBER:'||c1_rec.NEXT_LOT_NUMBER,l_module_name,'9');
   INV_LOG_UTIL.TRACE('NEXT_SERIAL_NUMBER:'||c1_rec.NEXT_SERIAL_NUMBER,l_module_name,'9');
   INV_LOG_UTIL.TRACE('NUMBER_OF_LOTS_ENTERED:'||c1_rec.NUMBER_OF_LOTS_ENTERED,l_module_name,'9');
   INV_LOG_UTIL.TRACE('OPERATION_PLAN_ID:'||c1_rec.OPERATION_PLAN_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('OPERATION_SEQ_NUM:'||c1_rec.OPERATION_SEQ_NUM,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ORGANIZATION_ID:'||c1_rec.ORGANIZATION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ORGANIZATION_TYPE:'||c1_rec.ORGANIZATION_TYPE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ORG_COST_GROUP_ID:'||c1_rec.ORG_COST_GROUP_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ORIGINAL_TRANSACTION_TEMP_ID:'||c1_rec.ORIGINAL_TRANSACTION_TEMP_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('OUTSIDE_PROCESSING_ACCOUNT:'||c1_rec.OUTSIDE_PROCESSING_ACCOUNT,l_module_name,'9');
   INV_LOG_UTIL.TRACE('OVERCOMPLETION_PRIMARY_QTY:'||c1_rec.OVERCOMPLETION_PRIMARY_QTY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('OVERCOMPLETION_TRANSACTION_ID:'||c1_rec.OVERCOMPLETION_TRANSACTION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('OVERCOMPLETION_TRANSACTION_QTY:'||c1_rec.OVERCOMPLETION_TRANSACTION_QTY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('OVERHEAD_ACCOUNT:'||c1_rec.OVERHEAD_ACCOUNT,l_module_name,'9');
   INV_LOG_UTIL.TRACE('OWNING_ORGANIZATION_ID:'||c1_rec.OWNING_ORGANIZATION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('OWNING_TP_TYPE:'||c1_rec.OWNING_TP_TYPE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PARENT_LINE_ID:'||c1_rec.PARENT_LINE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PARENT_TRANSACTION_TEMP_ID:'||c1_rec.PARENT_TRANSACTION_TEMP_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PA_EXPENDITURE_ORG_ID:'||c1_rec.PA_EXPENDITURE_ORG_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PERCENTAGE_CHANGE:'||c1_rec.PERCENTAGE_CHANGE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PHYSICAL_ADJUSTMENT_ID:'||c1_rec.PHYSICAL_ADJUSTMENT_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PICKING_LINE_ID:'||c1_rec.PICKING_LINE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PICK_RULE_ID:'||c1_rec.PICK_RULE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PICK_SLIP_DATE:'||c1_rec.PICK_SLIP_DATE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PICK_SLIP_NUMBER:'||c1_rec.PICK_SLIP_NUMBER,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PICK_STRATEGY_ID:'||c1_rec.PICK_STRATEGY_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PLANNING_ORGANIZATION_ID:'||c1_rec.PLANNING_ORGANIZATION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PLANNING_TP_TYPE:'||c1_rec.PLANNING_TP_TYPE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('POSTING_FLAG:'||c1_rec.POSTING_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PRIMARY_QUANTITY:'||c1_rec.PRIMARY_QUANTITY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PRIMARY_SWITCH:'||c1_rec.PRIMARY_SWITCH,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PROCESS_FLAG:'||c1_rec.PROCESS_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PROGRAM_APPLICATION_ID:'||c1_rec.PROGRAM_APPLICATION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PROGRAM_ID:'||c1_rec.PROGRAM_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PROGRAM_UPDATE_DATE:'||c1_rec.PROGRAM_UPDATE_DATE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PROJECT_ID:'||c1_rec.PROJECT_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PUT_AWAY_RULE_ID:'||c1_rec.PUT_AWAY_RULE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('PUT_AWAY_STRATEGY_ID:'||c1_rec.PUT_AWAY_STRATEGY_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('QA_COLLECTION_ID:'||c1_rec.QA_COLLECTION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('RCV_TRANSACTION_ID:'||c1_rec.RCV_TRANSACTION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('REASON_ID:'||c1_rec.REASON_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('REBUILD_ACTIVITY_ID:'||c1_rec.REBUILD_ACTIVITY_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('REBUILD_ITEM_ID:'||c1_rec.REBUILD_ITEM_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('REBUILD_JOB_NAME:'||c1_rec.REBUILD_JOB_NAME,l_module_name,'9');
   INV_LOG_UTIL.TRACE('REBUILD_SERIAL_NUMBER:'||c1_rec.REBUILD_SERIAL_NUMBER,l_module_name,'9');
   INV_LOG_UTIL.TRACE('RECEIVING_DOCUMENT:'||c1_rec.RECEIVING_DOCUMENT,l_module_name,'9');
   INV_LOG_UTIL.TRACE('RELIEVE_HIGH_LEVEL_RSV_FLAG:'||c1_rec.RELIEVE_HIGH_LEVEL_RSV_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('RELIEVE_RESERVATIONS_FLAG:'||c1_rec.RELIEVE_RESERVATIONS_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('REPETITIVE_LINE_ID:'||c1_rec.REPETITIVE_LINE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('REQUEST_ID:'||c1_rec.REQUEST_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('REQUIRED_FLAG:'||c1_rec.REQUIRED_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('REQUISITION_DISTRIBUTION_ID:'||c1_rec.REQUISITION_DISTRIBUTION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('REQUISITION_LINE_ID:'||c1_rec.REQUISITION_LINE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('RESERVATION_ID:'||c1_rec.RESERVATION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('RESERVATION_QUANTITY:'||c1_rec.RESERVATION_QUANTITY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('RESOURCE_ACCOUNT:'||c1_rec.RESOURCE_ACCOUNT,l_module_name,'9');
   INV_LOG_UTIL.TRACE('REVISION:'||c1_rec.REVISION,l_module_name,'9');
   INV_LOG_UTIL.TRACE('RMA_LINE_ID:'||c1_rec.RMA_LINE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ROUTING_REVISION:'||c1_rec.ROUTING_REVISION,l_module_name,'9');
   INV_LOG_UTIL.TRACE('ROUTING_REVISION_DATE:'||c1_rec.ROUTING_REVISION_DATE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SCHEDULED_FLAG:'||c1_rec.SCHEDULED_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SCHEDULED_PAYBACK_DATE:'||c1_rec.SCHEDULED_PAYBACK_DATE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SCHEDULE_GROUP:'||c1_rec.SCHEDULE_GROUP,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SCHEDULE_ID:'||c1_rec.SCHEDULE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SCHEDULE_NUMBER:'||c1_rec.SCHEDULE_NUMBER,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SCHEDULE_UPDATE_CODE:'||c1_rec.SCHEDULE_UPDATE_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SECONDARY_TRANSACTION_QUANTITY:'||c1_rec.SECONDARY_TRANSACTION_QUANTITY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SECONDARY_UOM_CODE:'||c1_rec.SECONDARY_UOM_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SERIAL_ALLOCATED_FLAG:'||c1_rec.SERIAL_ALLOCATED_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SERIAL_ALPHA_PREFIX:'||c1_rec.SERIAL_ALPHA_PREFIX,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SERIAL_NUMBER:'||c1_rec.SERIAL_NUMBER,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SETUP_TEARDOWN_CODE:'||c1_rec.SETUP_TEARDOWN_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SHIPMENT_NUMBER:'||c1_rec.SHIPMENT_NUMBER,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SHIPPABLE_FLAG:'||c1_rec.SHIPPABLE_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SHIPPED_QUANTITY:'||c1_rec.SHIPPED_QUANTITY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SHIP_TO_LOCATION:'||c1_rec.SHIP_TO_LOCATION,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SOURCE_CODE:'||c1_rec.SOURCE_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SOURCE_LINE_ID:'||c1_rec.SOURCE_LINE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SOURCE_LOT_NUMBER:'||c1_rec.SOURCE_LOT_NUMBER,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SOURCE_PROJECT_ID:'||c1_rec.SOURCE_PROJECT_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SOURCE_TASK_ID:'||c1_rec.SOURCE_TASK_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('STANDARD_OPERATION_ID:'||c1_rec.STANDARD_OPERATION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SUBINVENTORY_CODE:'||c1_rec.SUBINVENTORY_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SUPPLY_LOCATOR_ID:'||c1_rec.SUPPLY_LOCATOR_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('SUPPLY_SUBINVENTORY:'||c1_rec.SUPPLY_SUBINVENTORY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TASK_GROUP_ID:'||c1_rec.TASK_GROUP_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TASK_ID:'||c1_rec.TASK_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TASK_PRIORITY:'||c1_rec.TASK_PRIORITY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TO_PROJECT_ID:'||c1_rec.TO_PROJECT_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TO_TASK_ID:'||c1_rec.TO_TASK_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_ACTION_ID:'||c1_rec.TRANSACTION_ACTION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_BATCH_ID:'||c1_rec.TRANSACTION_BATCH_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_BATCH_SEQ:'||c1_rec.TRANSACTION_BATCH_SEQ,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_COST:'||c1_rec.TRANSACTION_COST,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_DATE:'||c1_rec.TRANSACTION_DATE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_HEADER_ID:'||c1_rec.TRANSACTION_HEADER_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_LINE_NUMBER:'||c1_rec.TRANSACTION_LINE_NUMBER,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_MODE:'||c1_rec.TRANSACTION_MODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_QUANTITY:'||c1_rec.TRANSACTION_QUANTITY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_REFERENCE:'||c1_rec.TRANSACTION_REFERENCE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_SEQUENCE_ID:'||c1_rec.TRANSACTION_SEQUENCE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_SOURCE_ID:'||c1_rec.TRANSACTION_SOURCE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_SOURCE_NAME:'||c1_rec.TRANSACTION_SOURCE_NAME,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_SOURCE_TYPE_ID:'||c1_rec.TRANSACTION_SOURCE_TYPE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_STATUS:'||c1_rec.TRANSACTION_STATUS,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_TEMP_ID:'||c1_rec.TRANSACTION_TEMP_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_TYPE_ID:'||c1_rec.TRANSACTION_TYPE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSACTION_UOM:'||c1_rec.TRANSACTION_UOM,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSFER_COST:'||c1_rec.TRANSFER_COST,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSFER_COST_GROUP_ID:'||c1_rec.TRANSFER_COST_GROUP_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSFER_LPN_ID:'||c1_rec.TRANSFER_LPN_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSFER_ORGANIZATION:'||c1_rec.TRANSFER_ORGANIZATION,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSFER_ORGANIZATION_TYPE:'||c1_rec.TRANSFER_ORGANIZATION_TYPE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSFER_OWNING_TP_TYPE:'||c1_rec.TRANSFER_OWNING_TP_TYPE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSFER_PERCENTAGE:'||c1_rec.TRANSFER_PERCENTAGE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSFER_PLANNING_TP_TYPE:'||c1_rec.TRANSFER_PLANNING_TP_TYPE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSFER_PRICE:'||c1_rec.TRANSFER_PRICE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSFER_SECONDARY_QUANTITY:'||c1_rec.TRANSFER_SECONDARY_QUANTITY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSFER_SECONDARY_UOM:'||c1_rec.TRANSFER_SECONDARY_UOM,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSFER_SUBINVENTORY:'||c1_rec.TRANSFER_SUBINVENTORY,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSFER_TO_LOCATION:'||c1_rec.TRANSFER_TO_LOCATION,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSPORTATION_ACCOUNT:'||c1_rec.TRANSPORTATION_ACCOUNT,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRANSPORTATION_COST:'||c1_rec.TRANSPORTATION_COST,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRX_FLOW_HEADER_ID:'||c1_rec.TRX_FLOW_HEADER_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRX_SOURCE_DELIVERY_ID:'||c1_rec.TRX_SOURCE_DELIVERY_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('TRX_SOURCE_LINE_ID:'||c1_rec.TRX_SOURCE_LINE_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('USSGL_TRANSACTION_CODE:'||c1_rec.USSGL_TRANSACTION_CODE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('VALID_LOCATOR_FLAG:'||c1_rec.VALID_LOCATOR_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('VALID_SUBINVENTORY_FLAG:'||c1_rec.VALID_SUBINVENTORY_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('VALUE_CHANGE:'||c1_rec.VALUE_CHANGE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('VENDOR_LOT_NUMBER:'||c1_rec.VENDOR_LOT_NUMBER,l_module_name,'9');
   INV_LOG_UTIL.TRACE('WAYBILL_AIRBILL:'||c1_rec.WAYBILL_AIRBILL,l_module_name,'9');
   INV_LOG_UTIL.TRACE('WIP_COMMIT_FLAG:'||c1_rec.WIP_COMMIT_FLAG,l_module_name,'9');
   INV_LOG_UTIL.TRACE('WIP_ENTITY_TYPE:'||c1_rec.WIP_ENTITY_TYPE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('WIP_SUPPLY_TYPE:'||c1_rec.WIP_SUPPLY_TYPE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('WMS_TASK_STATUS:'||c1_rec.WMS_TASK_STATUS,l_module_name,'9');
   INV_LOG_UTIL.TRACE('WMS_TASK_TYPE:'||c1_rec.WMS_TASK_TYPE,l_module_name,'9');
   INV_LOG_UTIL.TRACE('XFR_OWNING_ORGANIZATION_ID:'||c1_rec.XFR_OWNING_ORGANIZATION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('XFR_PLANNING_ORGANIZATION_ID:'||c1_rec.XFR_PLANNING_ORGANIZATION_ID,l_module_name,'9');
   INV_LOG_UTIL.TRACE('===>End of MMTT Record:'||i,l_module_name,'9');
  ELSE
   null;
  END IF;
 END LOOP;
END LOOP; ---}
  IF l_debug_on THEN
   INV_LOG_UTIL.TRACE('=============End of MMTT Data===============',l_module_name,'9');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  IF l_debug_on THEN
   INV_LOG_UTIL.TRACE('Error in Dumping MMTT',l_module_name,'9');
   INV_LOG_UTIL.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM,l_module_name,'9');
  END IF;
end  dump_mmtt;


Procedure Check_Scripts(p_action_code in VARCHAR2,
                        p_trx_hdr_id IN NUMBER,
                        p_trx_temp_id IN NUMBER,
                        p_batch_id IN NUMBER)

IS

/*** Look for Data Mismatch and Add information to g_dc_table if found
Checks For Validation - Sub Locator Combination, Valid Revision for Item
                      - Dump Complete MMTT record

Checks for Java TM at the End - Check if records have been deleted from MMTT, MTI and check Serial Status
                              - Dump data from MSNI, MTLI, MSNI, MTLT
***/
CURSOR C1 is
       SELECT TRANSACTION_TEMP_ID,TRANSACTION_TYPE_ID,
              TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_ACTION_ID,
              ORGANIZATION_ID,TRANSFER_ORGANIZATION,INVENTORY_ITEM_ID
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       WHERE TRANSACTION_HEADER_ID = p_trx_hdr_id
         AND PROCESS_FLAG = 'Y'
         AND ((TRANSACTION_ACTION_ID in (1,2,3,30,31,5)
	 AND inventory_item_id <> -1
         AND EXISTS (
           SELECT 'X'
           FROM MTL_SECONDARY_INVENTORIES MSI
           WHERE MSI.SECONDARY_INVENTORY_NAME = MMTT.SUBINVENTORY_CODE
           AND MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
           AND MSI.QUANTITY_TRACKED = 2))
           OR (TRANSACTION_ACTION_ID = 21
             AND EXISTS (
              SELECT 'X'
                FROM MTL_SECONDARY_INVENTORIES MSI,
                MTL_SYSTEM_ITEMS ITM
                WHERE MSI.SECONDARY_INVENTORY_NAME = MMTT.SUBINVENTORY_CODE
                AND MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
                AND ITM.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
                AND ITM.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
                AND ITM.ORGANIZATION_ID =  MSI.ORGANIZATION_ID
                AND ITM.INVENTORY_ASSET_FLAG = 'Y'
                AND MSI.ASSET_INVENTORY = 2)));


CURSOR C2 is
       SELECT TRANSACTION_TEMP_ID,TRANSACTION_TYPE_ID,
              TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_ACTION_ID,
              ORGANIZATION_ID,TRANSFER_ORGANIZATION,INVENTORY_ITEM_ID
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       WHERE TRANSACTION_HEADER_ID = p_trx_hdr_id
         AND PROCESS_FLAG = 'Y'
         AND TRANSACTION_ACTION_ID in (2,5)
	 AND inventory_item_id <> -1
         AND EXISTS (
           SELECT 'X'
           FROM MTL_SECONDARY_INVENTORIES MSI,
           MTL_SYSTEM_ITEMS ITM
           WHERE MSI.SECONDARY_INVENTORY_NAME = MMTT.SUBINVENTORY_CODE
             AND MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND ITM.ORGANIZATION_ID = MSI.ORGANIZATION_ID
             AND ITM.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND ITM.INVENTORY_ASSET_FLAG = 'Y'
             AND MSI.ASSET_INVENTORY = 2)
             AND EXISTS (
               SELECT 'X'
                 FROM MTL_SECONDARY_INVENTORIES MSI,
                 MTL_SYSTEM_ITEMS ITM
                 WHERE MSI.SECONDARY_INVENTORY_NAME = MMTT.TRANSFER_SUBINVENTORY
                   AND MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
                   AND ITM.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                   AND ITM.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
                   AND ITM.INVENTORY_ASSET_FLAG = 'Y'
                   AND MSI.ASSET_INVENTORY = 1);

CURSOR C3 is
       SELECT TRANSACTION_TEMP_ID,TRANSACTION_TYPE_ID,
              TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_ACTION_ID,
              ORGANIZATION_ID,TRANSFER_ORGANIZATION,INVENTORY_ITEM_ID
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       WHERE TRANSACTION_HEADER_ID = p_trx_hdr_id
         AND PROCESS_FLAG = 'Y'
         AND TRANSACTION_ACTION_ID = 3
	 AND inventory_item_id <> -1
         AND EXISTS (
           SELECT 'X'
           FROM MTL_SECONDARY_INVENTORIES MSI
           WHERE MSI.SECONDARY_INVENTORY_NAME = MMTT.SUBINVENTORY_CODE
             AND MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND MSI.ASSET_INVENTORY = 2)
             AND EXISTS (
               SELECT 'X'
               FROM MTL_SECONDARY_INVENTORIES MSI
               WHERE MSI.SECONDARY_INVENTORY_NAME = MMTT.TRANSFER_SUBINVENTORY
                AND MSI.ORGANIZATION_ID = MMTT.TRANSFER_ORGANIZATION
                AND MSI.ASSET_INVENTORY = 1);

CURSOR c4 is
       SELECT TRANSACTION_TEMP_ID,TRANSACTION_TYPE_ID,
              TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_ACTION_ID,
              ORGANIZATION_ID,TRANSFER_ORGANIZATION,INVENTORY_ITEM_ID
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       WHERE TRANSACTION_HEADER_ID = p_trx_hdr_id
         AND PROCESS_FLAG = 'Y'
	 AND inventory_item_id <> -1
         AND ((TRANSACTION_ACTION_ID in (1,2,3,30,31,5)
         AND EXISTS (
           SELECT 'X'
             FROM MTL_SECONDARY_INVENTORIES MSI
             WHERE MSI.SECONDARY_INVENTORY_NAME = MMTT.SUBINVENTORY_CODE
             AND MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND MSI.QUANTITY_TRACKED = 2)
            )) ;
CURSOR C5 is
       SELECT TRANSACTION_TEMP_ID,TRANSACTION_TYPE_ID,
              TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_ACTION_ID,
              ORGANIZATION_ID,TRANSFER_ORGANIZATION,INVENTORY_ITEM_ID
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       WHERE TRANSACTION_HEADER_ID = p_trx_hdr_id
       AND PROCESS_FLAG = 'Y'
       AND LOCATOR_ID IS NOT NULL
       AND transaction_action_id not in (24,30)
       AND inventory_item_id <> -1
       AND EXISTS (
           SELECT 'x'
   	   FROM MTL_PARAMETERS P,MTL_SECONDARY_INVENTORIES S,MTL_SYSTEM_ITEMS I
	   WHERE I.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
	   AND S.SECONDARY_INVENTORY_NAME = MMTT.SUBINVENTORY_CODE
	   AND P.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
	   AND I.ORGANIZATION_ID = S.ORGANIZATION_ID
	   AND P.ORGANIZATION_ID = S.ORGANIZATION_ID
	   AND P.ORGANIZATION_ID = I.ORGANIZATION_ID
	   AND (decode(P.STOCK_LOCATOR_CONTROL_CODE,4, decode(S.LOCATOR_TYPE,5,I.LOCATION_CONTROL_CODE, S.LOCATOR_TYPE) ,P.STOCK_LOCATOR_CONTROL_CODE) <> 1 ))
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_ITEM_LOCATIONS MIL
           WHERE MIL.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
           AND MIL.SUBINVENTORY_CODE = MMTT.SUBINVENTORY_CODE
           AND MIL.INVENTORY_LOCATION_ID = MMTT.LOCATOR_ID);

CURSOR C5_1 is
       SELECT TRANSACTION_TEMP_ID,TRANSACTION_TYPE_ID,
              TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_ACTION_ID,
              ORGANIZATION_ID,TRANSFER_ORGANIZATION,INVENTORY_ITEM_ID
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       WHERE TRANSACTION_HEADER_ID = p_trx_hdr_id
       AND PROCESS_FLAG = 'Y'
       AND LOCATOR_ID IS NULL
       AND inventory_item_id <> -1
       AND transaction_action_id not in (24,30)
       AND EXISTS (
           SELECT 'x'
   	   FROM MTL_PARAMETERS P,MTL_SECONDARY_INVENTORIES S,MTL_SYSTEM_ITEMS I
	   WHERE I.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
	   AND S.SECONDARY_INVENTORY_NAME = MMTT.SUBINVENTORY_CODE
	   AND P.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
	   AND I.ORGANIZATION_ID = S.ORGANIZATION_ID
	   AND P.ORGANIZATION_ID = S.ORGANIZATION_ID
	   AND P.ORGANIZATION_ID = I.ORGANIZATION_ID
	   AND (decode(P.STOCK_LOCATOR_CONTROL_CODE,4, decode(S.LOCATOR_TYPE,5,I.LOCATION_CONTROL_CODE, S.LOCATOR_TYPE) ,P.STOCK_LOCATOR_CONTROL_CODE) <> 1 ))
      UNION ALL
       SELECT TRANSACTION_TEMP_ID,TRANSACTION_TYPE_ID,
              TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_ACTION_ID,
              ORGANIZATION_ID,TRANSFER_ORGANIZATION,INVENTORY_ITEM_ID
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       WHERE TRANSACTION_HEADER_ID = p_trx_hdr_id
       AND PROCESS_FLAG = 'Y'
       AND LOCATOR_ID IS NOT NULL
       AND transaction_action_id not in (24,30)
       AND inventory_item_id <> -1
       AND EXISTS (
           SELECT 'x'
   	   FROM MTL_PARAMETERS P,MTL_SECONDARY_INVENTORIES S,MTL_SYSTEM_ITEMS I
	   WHERE I.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
	   AND S.SECONDARY_INVENTORY_NAME = MMTT.SUBINVENTORY_CODE
	   AND P.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
	   AND I.ORGANIZATION_ID = S.ORGANIZATION_ID
	   AND P.ORGANIZATION_ID = S.ORGANIZATION_ID
	   AND P.ORGANIZATION_ID = I.ORGANIZATION_ID
	   AND (decode(P.STOCK_LOCATOR_CONTROL_CODE,4, decode(S.LOCATOR_TYPE,5,I.LOCATION_CONTROL_CODE, S.LOCATOR_TYPE) ,P.STOCK_LOCATOR_CONTROL_CODE) =1));

CURSOR c6 is
       SELECT TRANSACTION_TEMP_ID,TRANSACTION_TYPE_ID,
              TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_ACTION_ID,
              ORGANIZATION_ID,TRANSFER_ORGANIZATION,INVENTORY_ITEM_ID
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       WHERE TRANSACTION_HEADER_ID = p_trx_hdr_id
       AND PROCESS_FLAG = 'Y'
       AND LOCATOR_ID IS NOT NULL
       AND transaction_action_id not in (24,30)
       AND inventory_item_id <> -1
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_SECONDARY_LOCATORS MSL,
                MTL_SYSTEM_ITEMS MSI
           WHERE MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSI.RESTRICT_LOCATORS_CODE = 1
             AND MSL.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND MSL.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSL.ORGANIZATION_ID = MSI.ORGANIZATION_ID
             AND MSL.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
             AND MSL.SUBINVENTORY_CODE = MMTT.SUBINVENTORY_CODE
             AND MSL.SECONDARY_LOCATOR = MMTT.LOCATOR_ID
           UNION
           SELECT NULL
             FROM MTL_SYSTEM_ITEMS ITM
            WHERE ITM.RESTRICT_LOCATORS_CODE = 2
              AND ITM.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
              AND ITM.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID);

CURSOR c7 is
       SELECT TRANSACTION_TEMP_ID,TRANSACTION_TYPE_ID,
              TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_ACTION_ID,
              ORGANIZATION_ID,TRANSFER_ORGANIZATION,INVENTORY_ITEM_ID
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       WHERE TRANSACTION_HEADER_ID = p_trx_hdr_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_ACTION_ID IN (2,3,5)
       AND TRANSFER_TO_LOCATION IS NOT NULL
       AND inventory_item_id <> -1
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_ITEM_LOCATIONS MIL
           WHERE MIL.ORGANIZATION_ID = decode(MMTT.TRANSACTION_ACTION_ID,3,
                 MMTT.TRANSFER_ORGANIZATION,MMTT.ORGANIZATION_ID)
             AND MIL.SUBINVENTORY_CODE = MMTT.TRANSFER_SUBINVENTORY
             AND MIL.INVENTORY_LOCATION_ID = MMTT.TRANSFER_TO_LOCATION
             AND TRUNC(MMTT.TRANSACTION_DATE) <= NVL(MIL.DISABLE_DATE,
                                                    MMTT.TRANSACTION_DATE + 1));

CURSOR c8 is
       SELECT TRANSACTION_TEMP_ID,TRANSACTION_TYPE_ID,
              TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_ACTION_ID,
              ORGANIZATION_ID,TRANSFER_ORGANIZATION,INVENTORY_ITEM_ID
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       WHERE TRANSACTION_HEADER_ID = p_trx_hdr_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_ACTION_ID in (2,21,3,5)
       AND TRANSFER_TO_LOCATION IS NOT NULL
       AND inventory_item_id <> -1
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_SECONDARY_LOCATORS MSL,
                MTL_SYSTEM_ITEMS MSI
           WHERE MSI.ORGANIZATION_ID = decode(MMTT.TRANSACTION_ACTION_ID,2,
                MMTT.ORGANIZATION_ID,5,MMTT.ORGANIZATION_ID, MMTT.TRANSFER_ORGANIZATION)
             AND MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSI.RESTRICT_LOCATORS_CODE = 1
             AND MSL.ORGANIZATION_ID = decode(MMTT.TRANSACTION_ACTION_ID,2,
                MMTT.ORGANIZATION_ID,5,MMTT.ORGANIZATION_ID, MMTT.TRANSFER_ORGANIZATION)
             AND MSL.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSL.ORGANIZATION_ID = MSI.ORGANIZATION_ID
             AND MSL.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
             AND MSL.SUBINVENTORY_CODE = MMTT.TRANSFER_SUBINVENTORY
             AND MSL.SECONDARY_LOCATOR = MMTT.TRANSFER_TO_LOCATION
           UNION
           SELECT NULL
           FROM MTL_SYSTEM_ITEMS MSI
           WHERE MSI.ORGANIZATION_ID = decode(MMTT.TRANSACTION_ACTION_ID,2,
                MMTT.ORGANIZATION_ID,5,MMTT.ORGANIZATION_ID,MMTT.TRANSFER_ORGANIZATION)
             AND MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSI.RESTRICT_LOCATORS_CODE = 2);

CURSOR c9 is
       SELECT TRANSACTION_TEMP_ID,TRANSACTION_TYPE_ID,
              TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_ACTION_ID,
              ORGANIZATION_ID,TRANSFER_ORGANIZATION,INVENTORY_ITEM_ID
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       WHERE TRANSACTION_HEADER_ID = p_trx_hdr_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_ACTION_ID NOT IN (24,33,34,30)
       AND inventory_item_id <> -1
       AND NOT EXISTS (
           SELECT NULL
             FROM MTL_ITEM_REVISIONS MIR,
                  MTL_SYSTEM_ITEMS MSI
            WHERE MSI.REVISION_QTY_CONTROL_CODE = 2
              AND MIR.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
              AND MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
              AND MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
              AND MIR.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MSI.ORGANIZATION_ID
              AND MIR.REVISION = MMTT.REVISION
             UNION
              SELECT NULL
                FROM MTL_SYSTEM_ITEMS ITM
               WHERE ITM.REVISION_QTY_CONTROL_CODE = 1
                 AND MMTT.REVISION IS NULL
                 AND ITM.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
                 AND ITM.ORGANIZATION_ID = MMTT.ORGANIZATION_ID);


CURSOR c10 is
       SELECT TRANSACTION_TEMP_ID,TRANSACTION_TYPE_ID,
              TRANSACTION_SOURCE_TYPE_ID,TRANSACTION_ACTION_ID,
              ORGANIZATION_ID,TRANSFER_ORGANIZATION,INVENTORY_ITEM_ID
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       WHERE TRANSACTION_HEADER_ID = p_trx_hdr_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_ACTION_ID = 3
       AND inventory_item_id <> -1
       AND NOT EXISTS (
            SELECT NULL
             FROM MTL_ITEM_REVISIONS MIR,
                  MTL_SYSTEM_ITEMS MSI
            WHERE MSI.REVISION_QTY_CONTROL_CODE = 2
              AND MIR.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MMTT.TRANSFER_ORGANIZATION
              AND MIR.REVISION = MMTT.REVISION
              AND MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
              AND MSI.ORGANIZATION_ID = MMTT.TRANSFER_ORGANIZATION
              AND MIR.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MSI.ORGANIZATION_ID
            UNION
              SELECT NULL
              FROM MTL_SYSTEM_ITEMS ITM
              WHERE ITM.REVISION_QTY_CONTROL_CODE = 1
              AND ITM.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
              AND ITM.ORGANIZATION_ID = MMTT.TRANSFER_ORGANIZATION);

CURSOR c_org(p_org_id in NUMBER) IS
         SELECT organization_code
 	 FROM  org_organization_definitions
	 WHERE organization_id = p_org_id;

CURSOR c_trx_type(p_trx_type_id IN NUMBER) IS
  	SELECT TRANSACTION_TYPE_NAME
	FROM mtl_transaction_types
	WHERE TRANSACTION_TYPE_ID=p_trx_type_id;

CURSOR c_source_type(p_source_type_id IN NUMBER) IS
  	SELECT transaction_source_type_name
	FROM mtl_txn_source_types
	WHERE transaction_source_type_id=p_source_type_id;

CURSOR c_action(p_action_id IN NUMBER) IS
  	SELECT meaning
	FROM mfg_lookups
	WHERE lookup_code=p_action_id
	AND   lookup_type='MTL_TRANSACTION_ACTION';

CURSOR c_item(p_org_id in number, p_item_id in number) IS
	SELECT concatenated_segments
      	FROM   mtl_system_items_kfv
      	WHERE  inventory_item_id = p_item_id
	AND organization_id = p_org_id;

CURSOR c21 is
---- First Part is to Select For Non Lot controlled Items
---- Second Part is to Select for Lot Controlled Items

       	SELECT a.TRANSACTION_TEMP_ID,a.TRANSACTION_TYPE_ID,a.TRANSACTIOn_QUANTITY,
               a.TRANSACTION_SOURCE_TYPE_ID,a.TRANSACTION_ACTION_ID,
               a.ORGANIZATION_ID,a.TRANSFER_ORGANIZATION,a.INVENTORY_ITEM_ID,
	       A.SUBINVENTORY_CODE,A.LOCATOR_ID,A.REVISION,A.LOT_NUMBER,
	       A.TRANSFER_SUBINVENTORY,a.TRANSFER_TO_LOCATION,
	       b.CURRENT_SUBINVENTORY_CODE,b.CURRENT_LOCATOR_ID,b.REVISION current_revision,
	       b.CURRENT_STATUS,b.SERIAL_NUMBER,b.current_organization_id,d.SERIAL_NUMBER_CONTROL_CODE
       	FROM MTL_MATERIAL_TRANSACTIONS_TEMP a,MTL_SERIAL_NUMBERS b,
             MTL_SERIAL_NUMBERS_TEMP c,MTL_SYSTEM_ITEMS d
       	WHERE A.TRANSACTION_TEMP_ID = C.TRANSACTION_TEMP_ID
	AND   LPAD(B.SERIAL_NUMBER,30) >= LPAD(C.FM_SERIAL_NUMBER,30)
	AND   LPAD(NVL(B.SERIAL_NUMBER,'-99'),30) <= LPAD(NVL(C.TO_SERIAL_NUMBER,'-99'),30)
	AND   A.ORGANIZATION_ID = nvl(B.CURRENT_ORGANIZATION_ID,A.ORGANIZATION_ID)
	AND   A.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
	AND   A.TRANSACTION_HEADER_ID=P_TRX_HDR_ID
	AND   A.TRANSACTION_TEMP_ID=nvl(P_TRX_TEMP_ID,A.TRANSACTION_TEMP_ID)
        AND   A.ORGANIZATION_ID = d.ORGANIZATION_ID
        AND   A.INVENTORY_ITEM_ID = d.INVENTORY_ITEM_ID
       	AND   A.PROCESS_FLAG = 'Y'
        AND   A.INVENTORY_ITEM_ID <> -1
        AND   ((d.SERIAL_NUMBER_CONTROL_CODE =6 and ((a.TRANSACTION_ACTION_ID =1 and a.transaction_source_type_id=2) or (a.transaction_action_id in (3,21) and a.transaction_source_type_id=8)))
              OR d.SERIAL_NUMBER_CONTROL_CODE in (2,5));
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) :=G_PKG_NAME || '.' || 'CHECK_SCRIPTS';
l_profile VARCHAR2(2000);
exp_to_ast_allowed NUMBER :=0;
i number :=1;
BEGIN

/*----------------------------------------------------------------------+
| Validate Subinventory for the following:
|    You cannot issue from non tracked
|    You cannot issue from expense sub for intransit shipment
|    You cannot transfer from expense sub to asset sub for asset items
|    If the expense to asset transfer allowed profiel is set then
|    You cannot issue from a non-tracked sub
|    All other transfers are valid
|    exp_to_ast_allowed = 1 means that the exp to ast trx are not alowed
------------------------------------------------------------------------+*/

IF g_debug_on = 1  THEN
  l_debug_on :=TRUE;
else
  l_debug_on :=FALSE;
END IF;

IF (p_action_code='Validate MMTT') then ---{
 SELECT FND_PROFILE.VALUE('INV:EXPENSE_TO_ASSET_TRANSFER')
 INTO l_profile
 FROM dual;

 IF SQL%FOUND THEN
  IF l_profile = '2' THEN
   exp_to_ast_allowed := 1;
  ELSE
   exp_to_ast_allowed := 2;
  END IF;
 ELSE
   exp_to_ast_allowed := 1;
 END IF;
 IF exp_to_ast_allowed = 1  THEN ---{
  FOR c1_rec in C1 loop
   g_dc_table(i).trx_hdr_id := p_trx_hdr_id;
   g_dc_table(i).msg := 'C1=>Invalid Subinventory: The subinventories have incompatible types with respect to transaction type and item type' ;
   g_dc_table(i).trx_temp_id := c1_rec.transaction_temp_id;

   if (c1_rec.organization_id is not null) then
    for c_org_rec in c_org (c1_rec.organization_id) loop
     g_dc_table(i).organization_code := c_org_rec.organization_code;
    end loop;
   end if;
   if (c1_rec.transfer_organization is not null) then
    for c_org_rec in c_org (c1_rec.transfer_organization) loop
     g_dc_table(i).xfer_org_code := c_org_rec.organization_code;
    end loop;
   end if;
   if (c1_rec.transaction_type_id is not null) then
    for c_trx_type_rec in c_trx_type (c1_rec.transaction_type_id) loop
     g_dc_table(i).trx_type := c_trx_type_rec.transaction_type_name;
    end loop;
   end if;
   if (c1_rec.transaction_source_type_id is not null) then
    for c_source_type_rec in c_source_type (c1_rec.transaction_source_type_id) loop
     g_dc_table(i).source_type := c_source_type_rec.transaction_source_type_name;
    end loop;
   end if;
   if (c1_rec.transaction_action_id is not null) then
    for c_action_rec in c_action(c1_rec.transaction_action_id) loop
     g_dc_table(i).action_code := c_action_rec.meaning;
    end loop;
   end if;
   if (c1_rec.organization_id is not null and c1_rec.inventory_item_id is not null) then
    for c_item_rec in c_item(c1_rec.organization_id,c1_rec.inventory_item_id) loop
     g_dc_table(i).item_name := c_item_rec.concatenated_segments;
    end loop;
   end if;
   i :=i+1;
  END LOOP;
  FOR c2_rec in C2 loop
   g_dc_table(i).trx_hdr_id := p_trx_hdr_id;
   g_dc_table(i).msg := 'C2=>Invalid Subinventory: The subinventories have incompatible types with respect to transaction type and item type' ;
   g_dc_table(i).trx_temp_id := c2_rec.transaction_temp_id;
   if (c2_rec.organization_id is not null) then
    for c_org_rec in c_org (c2_rec.organization_id) loop
     g_dc_table(i).organization_code := c_org_rec.organization_code;
    end loop;
   end if;
  if (c2_rec.transfer_organization is not null) then
   for c_org_rec in c_org (c2_rec.transfer_organization) loop
    g_dc_table(i).xfer_org_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c2_rec.transaction_type_id is not null) then
   for c_trx_type_rec in c_trx_type (c2_rec.transaction_type_id) loop
    g_dc_table(i).trx_type := c_trx_type_rec.transaction_type_name;
   end loop;
  end if;
  if (c2_rec.transaction_source_type_id is not null) then
   for c_source_type_rec in c_source_type (c2_rec.transaction_source_type_id) loop
    g_dc_table(i).source_type := c_source_type_rec.transaction_source_type_name;
   end loop;
  end if;
  if (c2_rec.transaction_action_id is not null) then
   for c_action_rec in c_action(c2_rec.transaction_action_id) loop
    g_dc_table(i).action_code := c_action_rec.meaning;
   end loop;
  end if;
  if (c2_rec.organization_id is not null and c2_rec.inventory_item_id is not null) then
   for c_item_rec in c_item(c2_rec.organization_id,c2_rec.inventory_item_id) loop
    g_dc_table(i).item_name := c_item_rec.concatenated_segments;
   end loop;
  end if;
  i :=i+1;
 END LOOP;
 FOR c3_rec in c3 loop
  g_dc_table(i).trx_hdr_id := p_trx_hdr_id;
  g_dc_table(i).msg := 'C3=>Invalid Subinventory: The subinventories have incompatible types with respect to transaction type and item type' ;
  g_dc_table(i).trx_temp_id := c3_rec.transaction_temp_id;
  if (c3_rec.organization_id is not null) then
   for c_org_rec in c_org (c3_rec.organization_id) loop
    g_dc_table(i).organization_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c3_rec.transfer_organization is not null) then
   for c_org_rec in c_org (c3_rec.transfer_organization) loop
    g_dc_table(i).xfer_org_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c3_rec.transaction_type_id is not null) then
   for c_trx_type_rec in c_trx_type (c3_rec.transaction_type_id) loop
    g_dc_table(i).trx_type := c_trx_type_rec.transaction_type_name;
   end loop;
  end if;
  if (c3_rec.transaction_source_type_id is not null) then
   for c_source_type_rec in c_source_type (c3_rec.transaction_source_type_id) loop
    g_dc_table(i).source_type := c_source_type_rec.transaction_source_type_name;
   end loop;
  end if;
  if (c3_rec.transaction_action_id is not null) then
   for c_action_rec in c_action(c3_rec.transaction_action_id) loop
    g_dc_table(i).action_code := c_action_rec.meaning;
   end loop;
  end if;
  if (c3_rec.organization_id is not null and c3_rec.inventory_item_id is not null) then
   for c_item_rec in c_item(c3_rec.organization_id,c3_rec.inventory_item_id) loop
    g_dc_table(i).item_name := c_item_rec.concatenated_segments;
   end loop;
  end if;
  i :=i+1;
 END LOOP;
 ----}
ELSE
---{
 FOR c4_rec in c4 loop
  g_dc_table(i).trx_hdr_id := p_trx_hdr_id;
  g_dc_table(i).msg := 'C4=>Invalid Subinventory: The subinventories have incompatible types with respect to transaction type and item type' ;
  g_dc_table(i).trx_temp_id := c4_rec.transaction_temp_id;
  if (c4_rec.organization_id is not null) then
   for c_org_rec in c_org (c4_rec.organization_id) loop
    g_dc_table(i).organization_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c4_rec.transfer_organization is not null) then
   for c_org_rec in c_org (c4_rec.transfer_organization) loop
    g_dc_table(i).xfer_org_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c4_rec.transaction_type_id is not null) then
   for c_trx_type_rec in c_trx_type (c4_rec.transaction_type_id) loop
    g_dc_table(i).trx_type := c_trx_type_rec.transaction_type_name;
   end loop;
  end if;
  if (c4_rec.transaction_source_type_id is not null) then
   for c_source_type_rec in c_source_type (c4_rec.transaction_source_type_id) loop
    g_dc_table(i).source_type := c_source_type_rec.transaction_source_type_name;
   end loop;
  end if;
  if (c4_rec.transaction_action_id is not null) then
   for c_action_rec in c_action(c4_rec.transaction_action_id) loop
    g_dc_table(i).action_code := c_action_rec.meaning;
   end loop;
  end if;
  if (c4_rec.organization_id is not null and c4_rec.inventory_item_id is not null) then
   for c_item_rec in c_item(c4_rec.organization_id,c4_rec.inventory_item_id) loop
    g_dc_table(i).item_name := c_item_rec.concatenated_segments;
   end loop;
  end if;
  i :=i+1;
 END LOOP;
END IF; ----}

/*-------------------------------------------------------------+
| Validating locators
+-------------------------------------------------------------*/
FOR c5_rec in C5 loop
  g_dc_table(i).trx_hdr_id := p_trx_hdr_id;
  g_dc_table(i).msg := 'C5=>Invalid Locator: Locator is not valid.  Please re-enter' ;
  g_dc_table(i).trx_temp_id := c5_rec.transaction_temp_id;
  if (c5_rec.organization_id is not null) then
   for c_org_rec in c_org (c5_rec.organization_id) loop
    g_dc_table(i).organization_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c5_rec.transfer_organization is not null) then
   for c_org_rec in c_org (c5_rec.transfer_organization) loop
    g_dc_table(i).xfer_org_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c5_rec.transaction_type_id is not null) then
   for c_trx_type_rec in c_trx_type (c5_rec.transaction_type_id) loop
    g_dc_table(i).trx_type := c_trx_type_rec.transaction_type_name;
   end loop;
  end if;
  if (c5_rec.transaction_source_type_id is not null) then
   for c_source_type_rec in c_source_type (c5_rec.transaction_source_type_id) loop
    g_dc_table(i).source_type := c_source_type_rec.transaction_source_type_name;
   end loop;
  end if;
  if (c5_rec.transaction_action_id is not null) then
   for c_action_rec in c_action(c5_rec.transaction_action_id) loop
    g_dc_table(i).action_code := c_action_rec.meaning;
   end loop;
  end if;
  if (c5_rec.organization_id is not null and c5_rec.inventory_item_id is not null) then
   for c_item_rec in c_item(c5_rec.organization_id,c5_rec.inventory_item_id) loop
    g_dc_table(i).item_name := c_item_rec.concatenated_segments;
   end loop;
  end if;
  i :=i+1;
END LOOP;
FOR c5_1_rec in C5_1 loop
  g_dc_table(i).trx_hdr_id := p_trx_hdr_id;
  g_dc_table(i).msg := 'c5_1=>Invalid Locator: Locator is null or Locator is being passed when not expected' ;
  g_dc_table(i).trx_temp_id := c5_1_rec.transaction_temp_id;
  if (c5_1_rec.organization_id is not null) then
   for c_org_rec in c_org (c5_1_rec.organization_id) loop
    g_dc_table(i).organization_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c5_1_rec.transfer_organization is not null) then
   for c_org_rec in c_org (c5_1_rec.transfer_organization) loop
    g_dc_table(i).xfer_org_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c5_1_rec.transaction_type_id is not null) then
   for c_trx_type_rec in c_trx_type (c5_1_rec.transaction_type_id) loop
    g_dc_table(i).trx_type := c_trx_type_rec.transaction_type_name;
   end loop;
  end if;
  if (c5_1_rec.transaction_source_type_id is not null) then
   for c_source_type_rec in c_source_type (c5_1_rec.transaction_source_type_id) loop
    g_dc_table(i).source_type := c_source_type_rec.transaction_source_type_name;
   end loop;
  end if;
  if (c5_1_rec.transaction_action_id is not null) then
   for c_action_rec in c_action(c5_1_rec.transaction_action_id) loop
    g_dc_table(i).action_code := c_action_rec.meaning;
   end loop;
  end if;
  if (c5_1_rec.organization_id is not null and c5_1_rec.inventory_item_id is not null) then
   for c_item_rec in c_item(c5_1_rec.organization_id,c5_1_rec.inventory_item_id) loop
    g_dc_table(i).item_name := c_item_rec.concatenated_segments;
   end loop;
  end if;
  i :=i+1;
END LOOP;
FOR c6_rec in c6 loop
  g_dc_table(i).trx_hdr_id := p_trx_hdr_id;
  g_dc_table(i).msg := 'C6=>Invalid Locator: Locator is not in the restricted list of locators for the item' ;
  g_dc_table(i).trx_temp_id := c6_rec.transaction_temp_id;
  if (c6_rec.organization_id is not null) then
   for c_org_rec in c_org (c6_rec.organization_id) loop
    g_dc_table(i).organization_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c6_rec.transfer_organization is not null) then
   for c_org_rec in c_org (c6_rec.transfer_organization) loop
    g_dc_table(i).xfer_org_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c6_rec.transaction_type_id is not null) then
   for c_trx_type_rec in c_trx_type (c6_rec.transaction_type_id) loop
    g_dc_table(i).trx_type := c_trx_type_rec.transaction_type_name;
   end loop;
  end if;
  if (c6_rec.transaction_source_type_id is not null) then
   for c_source_type_rec in c_source_type (c6_rec.transaction_source_type_id) loop
    g_dc_table(i).source_type := c_source_type_rec.transaction_source_type_name;
   end loop;
  end if;
  if (c6_rec.transaction_action_id is not null) then
   for c_action_rec in c_action(c6_rec.transaction_action_id) loop
    g_dc_table(i).action_code := c_action_rec.meaning;
   end loop;
  end if;
  if (c6_rec.organization_id is not null and c6_rec.inventory_item_id is not null) then
   for c_item_rec in c_item(c6_rec.organization_id,c6_rec.inventory_item_id) loop
    g_dc_table(i).item_name := c_item_rec.concatenated_segments;
   end loop;
  end if;
  i :=i+1;
END LOOP;

/*-----------------------------------------------------------+
| Validating transfer locators against transfer organization
+-----------------------------------------------------------*/
FOR c7_rec in c7 loop
  g_dc_table(i).trx_hdr_id := p_trx_hdr_id;
  g_dc_table(i).msg := 'C7=>Invalid transfer locator: Transfer locator is not valid for the item in the transfer organization' ;
  g_dc_table(i).trx_temp_id := c7_rec.transaction_temp_id;
  if (c7_rec.organization_id is not null) then
   for c_org_rec in c_org (c7_rec.organization_id) loop
    g_dc_table(i).organization_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c7_rec.transfer_organization is not null) then
   for c_org_rec in c_org (c7_rec.transfer_organization) loop
    g_dc_table(i).xfer_org_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c7_rec.transaction_type_id is not null) then
   for c_trx_type_rec in c_trx_type (c7_rec.transaction_type_id) loop
    g_dc_table(i).trx_type := c_trx_type_rec.transaction_type_name;
   end loop;
  end if;
  if (c7_rec.transaction_source_type_id is not null) then
   for c_source_type_rec in c_source_type (c7_rec.transaction_source_type_id) loop
    g_dc_table(i).source_type := c_source_type_rec.transaction_source_type_name;
   end loop;
  end if;
  if (c7_rec.transaction_action_id is not null) then
   for c_action_rec in c_action(c7_rec.transaction_action_id) loop
    g_dc_table(i).action_code := c_action_rec.meaning;
   end loop;
  end if;
  if (c7_rec.organization_id is not null and c7_rec.inventory_item_id is not null) then
   for c_item_rec in c_item(c7_rec.organization_id,c7_rec.inventory_item_id) loop
    g_dc_table(i).item_name := c_item_rec.concatenated_segments;
   end loop;
  end if;
  i :=i+1;
END LOOP;

/*------------------------------------------------------+
| Validating transfer locators for restricted list
+------------------------------------------------------*/
FOR c8_rec in c8 loop
  g_dc_table(i).trx_hdr_id := p_trx_hdr_id;
  g_dc_table(i).msg := 'C8=>Invalid transfer locator: Transfer locator is not in the restricted list for the given item in transfer organization' ;
  g_dc_table(i).trx_temp_id := c8_rec.transaction_temp_id;
  if (c8_rec.organization_id is not null) then
   for c_org_rec in c_org (c8_rec.organization_id) loop
    g_dc_table(i).organization_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c8_rec.transfer_organization is not null) then
   for c_org_rec in c_org (c8_rec.transfer_organization) loop
    g_dc_table(i).xfer_org_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c8_rec.transaction_type_id is not null) then
   for c_trx_type_rec in c_trx_type (c8_rec.transaction_type_id) loop
    g_dc_table(i).trx_type := c_trx_type_rec.transaction_type_name;
   end loop;
  end if;
  if (c8_rec.transaction_source_type_id is not null) then
   for c_source_type_rec in c_source_type (c8_rec.transaction_source_type_id) loop
    g_dc_table(i).source_type := c_source_type_rec.transaction_source_type_name;
   end loop;
  end if;
  if (c8_rec.transaction_action_id is not null) then
   for c_action_rec in c_action(c8_rec.transaction_action_id) loop
    g_dc_table(i).action_code := c_action_rec.meaning;
   end loop;
  end if;
  if (c8_rec.organization_id is not null and c8_rec.inventory_item_id is not null) then
   for c_item_rec in c_item(c8_rec.organization_id,c8_rec.inventory_item_id) loop
    g_dc_table(i).item_name := c_item_rec.concatenated_segments;
   end loop;
  end if;
  i :=i+1;
END LOOP;

/*--------------------------------------------------+
| Validating item revisions
+--------------------------------------------------*/
FOR c9_rec in c9 loop
  g_dc_table(i).trx_hdr_id := p_trx_hdr_id;
  g_dc_table(i).msg := 'C9=>Invalid item revision: The item revision is not valid.  Please re-enter' ;
  g_dc_table(i).trx_temp_id := c9_rec.transaction_temp_id;
  if (c9_rec.organization_id is not null) then
   for c_org_rec in c_org (c9_rec.organization_id) loop
    g_dc_table(i).organization_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c9_rec.transfer_organization is not null) then
   for c_org_rec in c_org (c9_rec.transfer_organization) loop
    g_dc_table(i).xfer_org_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c9_rec.transaction_type_id is not null) then
   for c_trx_type_rec in c_trx_type (c9_rec.transaction_type_id) loop
    g_dc_table(i).trx_type := c_trx_type_rec.transaction_type_name;
   end loop;
  end if;
  if (c9_rec.transaction_source_type_id is not null) then
   for c_source_type_rec in c_source_type (c9_rec.transaction_source_type_id) loop
    g_dc_table(i).source_type := c_source_type_rec.transaction_source_type_name;
   end loop;
  end if;
  if (c9_rec.transaction_action_id is not null) then
   for c_action_rec in c_action(c9_rec.transaction_action_id) loop
    g_dc_table(i).action_code := c_action_rec.meaning;
   end loop;
  end if;
  if (c9_rec.organization_id is not null and c9_rec.inventory_item_id is not null) then
   for c_item_rec in c_item(c9_rec.organization_id,c9_rec.inventory_item_id) loop
    g_dc_table(i).item_name := c_item_rec.concatenated_segments;
   end loop;
  end if;
  i :=i+1;
END LOOP;
FOR c10_rec in c10 loop
 g_dc_table(i).trx_hdr_id := p_trx_hdr_id;
 g_dc_table(i).msg := 'C10=>Invalid item revision: The item revision specified must be defined in both Source and Destination organizations for direct inter-org transfers.' ;
 g_dc_table(i).trx_temp_id := c10_rec.transaction_temp_id;
  if (c10_rec.organization_id is not null) then
   for c_org_rec in c_org (c10_rec.organization_id) loop
    g_dc_table(i).organization_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c10_rec.transfer_organization is not null) then
   for c_org_rec in c_org (c10_rec.transfer_organization) loop
    g_dc_table(i).xfer_org_code := c_org_rec.organization_code;
   end loop;
  end if;
  if (c10_rec.transaction_type_id is not null) then
   for c_trx_type_rec in c_trx_type (c10_rec.transaction_type_id) loop
    g_dc_table(i).trx_type := c_trx_type_rec.transaction_type_name;
   end loop;
  end if;
  if (c10_rec.transaction_source_type_id is not null) then
   for c_source_type_rec in c_source_type (c10_rec.transaction_source_type_id) loop
    g_dc_table(i).source_type := c_source_type_rec.transaction_source_type_name;
   end loop;
  end if;
  if (c10_rec.transaction_action_id is not null) then
   for c_action_rec in c_action(c10_rec.transaction_action_id) loop
    g_dc_table(i).action_code := c_action_rec.meaning;
   end loop;
  end if;
  if (c10_rec.organization_id is not null and c10_rec.inventory_item_id is not null) then
   for c_item_rec in c_item(c10_rec.organization_id,c10_rec.inventory_item_id) loop
    g_dc_table(i).item_name := c_item_rec.concatenated_segments;
   end loop;
  end if;
 i :=i+1;
END LOOP;
end if; ---}

IF (p_action_code='Validate Serial') then ---{
 FOR c21_rec IN c21 LOOP
 IF (c21_rec.TRANSACTION_ACTION_ID in (2,3,28) and (c21_rec.transaction_quantity < 0)) THEN ---{
    G_DCP_MSG:= G_DCP_MSG||'DCP-Skipping DCP Check (for 2,3,28 and qty < 0)
';
 ELSE --}{
  if (add_serial_data(c21_rec.transaction_quantity,
                      c21_rec.serial_number_control_code,
                      c21_rec.transfer_organization,
                      c21_rec.inventory_item_id)) then --{
    IF (c21_rec.TRANSACTION_ACTION_ID not in (2,28)) THEN ---{
       IF (nvl(c21_rec.subinventory_code,'-A')  <> nvl(c21_rec.current_subinventory_code,'-A')
       OR   nvl(c21_rec.organization_id,-999)   <> nvl(c21_rec.current_organization_id,-999)
       OR   nvl(c21_rec.locator_id,-999)        <> nvl(c21_rec.current_locator_id,-999)
       OR   nvl(c21_rec.revision,'@@@')         <> nvl(c21_rec.current_revision,'@@@')
       OR   ((c21_rec.current_status  <> g_ser_check_tab(c21_rec.transaction_action_id).serial_status)
         AND (c21_rec.current_status <> 6 ))) THEN
         g_dc_table(i).trx_hdr_id := p_trx_hdr_id;
         g_dc_table(i).msg := 'C21=> Invalid Serial Attribute: One or More Serial Attributes for Serial#'||c21_rec.serial_number||' mismatch.';
         g_dc_table(i).trx_temp_id := c21_rec.transaction_temp_id;
   if (c21_rec.organization_id is not null) then
    for c_org_rec in c_org (c21_rec.organization_id) loop
     g_dc_table(i).organization_code := c_org_rec.organization_code;
    end loop;
   end if;
   if (c21_rec.transfer_organization is not null) then
    for c_org_rec in c_org (c21_rec.transfer_organization) loop
     g_dc_table(i).xfer_org_code := c_org_rec.organization_code;
    end loop;
   end if;
   if (c21_rec.transaction_type_id is not null) then
    for c_trx_type_rec in c_trx_type (c21_rec.transaction_type_id) loop
     g_dc_table(i).trx_type := c_trx_type_rec.transaction_type_name;
    end loop;
   end if;
   if (c21_rec.transaction_source_type_id is not null) then
    for c_source_type_rec in c_source_type (c21_rec.transaction_source_type_id) loop
     g_dc_table(i).source_type := c_source_type_rec.transaction_source_type_name;
    end loop;
   end if;
   if (c21_rec.transaction_action_id is not null) then
    for c_action_rec in c_action(c21_rec.transaction_action_id) loop
     g_dc_table(i).action_code := c_action_rec.meaning;
    end loop;
   end if;
   if (c21_rec.organization_id is not null and c21_rec.inventory_item_id is not null) then
    for c_item_rec in c_item(c21_rec.organization_id,c21_rec.inventory_item_id) loop
     g_dc_table(i).item_name := c_item_rec.concatenated_segments;
    end loop;
   end if;
     i :=i+1;

    G_DCP_MSG:= G_DCP_MSG||'Org - Current Org:'||c21_rec.organization_id||'-'||c21_rec.current_organization_id||'
';
    G_DCP_MSG :=G_DCP_MSG||'sub - Current sub:'||c21_rec.subinventory_code||'-'||c21_rec.current_subinventory_code||'
';
    G_DCP_MSG :=G_DCP_MSG||'Loc - Current Loc:'||c21_rec.locator_id||'-'||c21_rec.current_locator_id||'
';
    G_DCP_MSG :=G_DCP_MSG||'Rev - Current Rev:'||c21_rec.revision||'-'||c21_rec.current_revision||'
';
    G_DCP_MSG :=G_DCP_MSG||'Status - Expected Status:'||c21_rec.current_status||'-'||g_ser_check_tab(c21_rec.transaction_action_id).serial_status||'
';

       END IF;
    ELSE  ---}{
       IF (nvl(c21_rec.transfer_subinventory,'-A')  <> nvl(c21_rec.current_subinventory_code,'-A')
       OR   nvl(c21_rec.transfer_organization,c21_rec.current_organization_id) <> nvl(c21_rec.current_organization_id,-999)
       OR   nvl(c21_rec.transfer_to_location,-999)  <> nvl(c21_rec.current_locator_id,-999)
       OR   nvl(c21_rec.revision,'@@@')             <> nvl(c21_rec.current_revision,'@@@')
       OR   ((c21_rec.current_status  <> g_ser_check_tab(c21_rec.transaction_action_id).serial_status)
         AND (c21_rec.current_status <> 6))) THEN
         g_dc_table(i).trx_hdr_id := p_trx_hdr_id;
         g_dc_table(i).msg := 'C21=> Invalid Serial Attribute: One or More Serial Attributes for Serial#'||c21_rec.serial_number||' mismatch.';
         g_dc_table(i).trx_temp_id := c21_rec.transaction_temp_id;
   if (c21_rec.organization_id is not null) then
    for c_org_rec in c_org (c21_rec.organization_id) loop
     g_dc_table(i).organization_code := c_org_rec.organization_code;
    end loop;
   end if;
   if (c21_rec.transfer_organization is not null) then
    for c_org_rec in c_org (c21_rec.transfer_organization) loop
     g_dc_table(i).xfer_org_code := c_org_rec.organization_code;
    end loop;
   end if;
   if (c21_rec.transaction_type_id is not null) then
    for c_trx_type_rec in c_trx_type (c21_rec.transaction_type_id) loop
     g_dc_table(i).trx_type := c_trx_type_rec.transaction_type_name;
    end loop;
   end if;
   if (c21_rec.transaction_source_type_id is not null) then
    for c_source_type_rec in c_source_type (c21_rec.transaction_source_type_id) loop
     g_dc_table(i).source_type := c_source_type_rec.transaction_source_type_name;
    end loop;
   end if;
   if (c21_rec.transaction_action_id is not null) then
    for c_action_rec in c_action(c21_rec.transaction_action_id) loop
     g_dc_table(i).action_code := c_action_rec.meaning;
    end loop;
   end if;
   if (c21_rec.organization_id is not null and c21_rec.inventory_item_id is not null) then
    for c_item_rec in c_item(c21_rec.organization_id,c21_rec.inventory_item_id) loop
     g_dc_table(i).item_name := c_item_rec.concatenated_segments;
    end loop;
   end if;
   i :=i+1;
    G_DCP_MSG :=G_DCP_MSG||'Transfer Org - Current Org:'||c21_rec.transfer_organization||' - '||c21_rec.current_organization_id||'
' ;
    G_DCP_MSG :=G_DCP_MSG||'Transfer Sub - Current Sub:'||c21_rec.transfer_subinventory||' - '||c21_rec.current_subinventory_code||'
';
    G_DCP_MSG :=G_DCP_MSG||'Transfer Loc - Current Loc:'||c21_rec.transfer_to_location||' - '||c21_rec.current_locator_id||'
';
    G_DCP_MSG :=G_DCP_MSG||'Rev - Current Rev:'||c21_rec.revision||' - '||c21_rec.current_revision||'
';
    G_DCP_MSG :=G_DCP_MSG||'Status - Expected Status:'||c21_rec.current_status||' - '||g_ser_check_tab(c21_rec.transaction_action_id).serial_status||'
';
       END IF;
    END IF;  ---}
  ELSE  ---}{
   IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('DCP-Error loading Serial Checks data',l_module_name,'9');
   END IF;
  END IF; --}
 END IF; --}
 END LOOP;
END IF; ---}

IF (i > 1) THEN
  IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('Data is inconsistent',l_module_name,'9');
  END IF;
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF l_debug_on THEN
     INV_LOG_UTIL.TRACE('Unexpected error has occured. Oracle error message is '|| substr(SQLERRM,1,180),l_module_name,'9');
     INV_LOG_UTIL.TRACE('EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR',l_module_name,'9');
  END IF;
END Check_Scripts;

Procedure Validate_data(p_dcp_event IN VARCHAR2,
                        p_trx_hdr_id IN VARCHAR2,
                        p_temp_id IN NUMBER,
		        p_batch_id IN NUMBER,
                        p_raise_exception IN VARCHAR2,
			x_return_status OUT NOCOPY VARCHAR2)
IS
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) :=G_PKG_NAME || '.' || 'Validate_data';
i NUMBER;
l_header_id NUMBER := 0;
BEGIN
  IF g_debug_on = 1  THEN
     l_debug_on :=TRUE;
  else
     l_debug_on :=FALSE;
  END IF;
  --inv_log_util.TRACE
 IF l_debug_on THEN
    INV_LOG_UTIL.TRACE('p_trx_hdr_id='||p_trx_hdr_id,l_module_name,9);
    INV_LOG_UTIL.TRACE('p_raise_exception'||p_raise_Exception,l_module_name,9);
 END IF;
 check_scripts(p_action_code => p_dcp_event,
               p_trx_hdr_id => p_trx_hdr_id,
               p_trx_temp_id => p_temp_id);

 Post_Process(p_action_code => p_dcp_event,
              p_raise_exception => p_raise_exception);

x_return_status :='S';
EXCEPTION
  WHEN dcp_caught THEN
    IF l_debug_on THEN
       INV_LOG_UTIL.TRACE('dcp_caught exception: Validate_data',l_module_name,9);
       INV_LOG_UTIL.TRACE('EXCEPTION:DCP_CAUGHT: Validate_data',l_module_name,9);
    END IF;
    x_return_status :='S';
    RAISE data_inconsistency_exception;
  WHEN others THEN
   IF l_debug_on THEN
     INV_LOG_UTIL.TRACE('Unexpected error has occured. Oracle error message is '|| substr(SQLERRM,1,180),l_module_name,9);
     INV_LOG_UTIL.TRACE('EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR',l_module_name,9);
     x_return_status :='E';
   END IF;
END Validate_data;
END INV_DCP_PVT;

/
