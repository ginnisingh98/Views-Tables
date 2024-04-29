--------------------------------------------------------
--  DDL for Package Body WSH_DCP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DCP_PVT" as
/* $Header: WSHDCPPB.pls 120.0 2005/05/26 17:09:47 appldev noship $ */


G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DCP_PVT';
g_userid                 NUMBER;
g_user_email              VARCHAR2(32767);
g_user_name               VARCHAR2(32767);
g_env     VARCHAR2(32767);


Function get_email_server RETURN VARCHAR2
IS
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_EMAIL_SERVER';

BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
 IF l_debug_on THEN
    wsh_debug_sv.push(l_module_name);
 END IF;

IF wsh_dcp_pvt.g_email_server IS NOT NULL THEN

 IF l_debug_on THEN
    WSH_DEBUG_SV.LOG(l_module_name, 'server name cache', wsh_dcp_pvt.g_email_server);
    wsh_debug_sv.pop(l_module_name);
 END IF;

   RETURN wsh_dcp_pvt.g_email_server;
END IF;

  wsh_dcp_pvt.g_email_server := fnd_profile.value('WSH_DCP_EMAIL_SERVER');

 IF l_debug_on THEN
    WSH_DEBUG_SV.LOG(l_module_name, 'server name profile', wsh_dcp_pvt.g_email_server);
    wsh_debug_sv.pop(l_module_name);
 END IF;
RETURN wsh_dcp_pvt.g_email_server;


EXCEPTION
WHEN OTHERS THEN
 IF l_debug_on THEN
    wsh_debug_sv.logmsg(l_module_name, 'When others error has occured. Oracle error message is ' || SQLERRM, wsh_debug_sv.c_unexpec_err_level);
    wsh_debug_sv.pop(l_module_name);
 END IF;
  RETURN NULL;
END Get_email_server;

Function get_email_address RETURN VARCHAR2
IS
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_EMAIL_ADDRESS';
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
 IF l_debug_on THEN
    wsh_debug_sv.push(l_module_name);
 END IF;

IF wsh_dcp_pvt.g_email_address IS NOT NULL THEN
  IF l_debug_on THEN
    WSH_DEBUG_SV.LOG(l_module_name, 'Email Address cache', wsh_dcp_pvt.g_email_address);
    wsh_debug_sv.pop(l_module_name);
  END IF;
   RETURN wsh_dcp_pvt.g_email_address;
END IF;

wsh_dcp_pvt.g_email_address := fnd_profile.value('WSH_DCP_EMAIL_ADDRESSES');

  IF l_debug_on THEN
    WSH_DEBUG_SV.LOG(l_module_name, 'Email Address profile', wsh_dcp_pvt.g_email_address);
    wsh_debug_sv.pop(l_module_name);
  END IF;
RETURN wsh_dcp_pvt.g_email_address;

EXCEPTION
WHEN OTHERS THEN
  IF l_debug_on THEN
   wsh_debug_sv.logmsg(l_module_name, 'When others error has occured. Oracle error message is ' || SQLERRM, wsh_debug_sv.c_unexpec_err_level);
   wsh_debug_sv.pop(l_module_name);
  END IF;
  RETURN NULL;
END Get_email_address;


Procedure Send_Mail(sender IN VARCHAR2,
                    recipient1 IN VARCHAR2,
                    recipient2 IN VARCHAR2,
                    recipient3 IN VARCHAR2,
                    recipient4 IN VARCHAR2,
                    message IN VARCHAR2)
IS
l_mailhost VARCHAR2(32767);
l_mail_conn utl_smtp.connection;
l_email_addrs VARCHAR2(32767);
l_spr VARCHAR2(30) := ',';
l_start_pos NUMBER;
l_end_pos NUMBER;
j NUMBER;

l_recipient1 VARCHAR2(32767);
l_recipient2 VARCHAR2(32767);
l_recipient3 VARCHAR2(32767);
l_recipient4 VARCHAR2(32767);
l_recipient5 VARCHAR2(32767);

l_sender VARCHAR2(32767) := 'Oracle-Order-Fulfillment-Data-Integrity-Check@oracleorderfulfillment';
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SEND_MAIL';

BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name, 'sender', sender);
    WSH_DEBUG_SV.log(l_module_name, 'recipient1', recipient1);
    WSH_DEBUG_SV.log(l_module_name, 'recipient2', recipient2);
    WSH_DEBUG_SV.log(l_module_name, 'recipient3', recipient3);
    WSH_DEBUG_SV.log(l_module_name, 'recipient4', recipient4);
 END IF;

 --Call function that will return the email server name
 l_mailhost := get_email_server;

 --Call function that will return the email addresses
 l_email_addrs := get_email_address;

 --Parse to get individual recipients
  IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'l_mailhost', l_mailhost);
     wsh_debug_sv.log(l_module_name, 'l_email_addrs', l_email_addrs);
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
    WSH_DEBUG_SV.log(l_module_name, 'sender', l_sender);
    WSH_DEBUG_SV.log(l_module_name, 'recipient1', l_recipient1);
    WSH_DEBUG_SV.log(l_module_name, 'recipient2', l_recipient2);
    WSH_DEBUG_SV.log(l_module_name, 'recipient3', l_recipient3);
    WSH_DEBUG_SV.log(l_module_name, 'recipient4', l_recipient4);
    WSH_DEBUG_SV.log(l_module_name, 'recipient5', l_recipient5);
   END IF;

   utl_smtp.helo(l_mail_conn, l_mailhost);

   utl_smtp.mail(l_mail_conn, l_sender);

  IF l_recipient1 IS NOT NULL THEN
    utl_smtp.rcpt(l_mail_conn, l_recipient1);
  END IF;


  IF l_recipient2 IS NOT NULL THEN
    utl_smtp.rcpt(l_mail_conn, l_recipient2);
  END IF;

  IF l_recipient3 IS NOT NULL THEN
    utl_smtp.rcpt(l_mail_conn, l_recipient3);
  END IF;

  IF l_recipient4 IS NOT NULL THEN
   utl_smtp.rcpt(l_mail_conn, l_recipient4);
  END IF;

  IF l_recipient5 IS NOT NULL THEN
   utl_smtp.rcpt(l_mail_conn, l_recipient5);
  END IF;

  utl_smtp.data(l_mail_conn, message);

  utl_smtp.quit(l_mail_conn);
ELSE
  IF l_debug_on THEN
     wsh_debug_sv.logmsg(l_module_name, 'Not sending mail. Server Name or Email id is null');
  END IF;

--}
END IF;

  IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
  END IF;

EXCEPTION
WHEN others THEN
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
  END IF;
END Send_Mail;

/*===========================================================================
FUNCTION NAME:	is_dcp_enabled

DESCRIPTION:   	This function returns the DCP profile

===========================================================================*/

FUNCTION is_dcp_enabled RETURN NUMBER
IS
BEGIN

  IF wsh_dcp_pvt.g_check_dcp IS NOT NULL
  THEN
     RETURN(wsh_dcp_pvt.g_check_dcp);
  END IF;
  --
  wsh_dcp_pvt.g_check_dcp := nvl(fnd_profile.value('WSH_ENABLE_DCP'), 0);
  --
  RETURN wsh_dcp_pvt.g_check_dcp;

EXCEPTION
when others then
RETURN 0;
END is_dcp_enabled;

PROCEDURE Post_Process(p_action_code IN VARCHAR2,
                       p_raise_exception IN VARCHAR2)
IS
l_call_stack VARCHAR2(32767);
l_message VARCHAR2(32767);
l_debug_file Varchar2(32767);
l_debug_dir Varchar2(32767);
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'POST_PROCESS';
k NUMBER;
l_rollback_allowed VARCHAR2(1);
l_return_status VARCHAR2(30);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_conc_request_id NUMBER;
l_utl_file_locns VARCHAR2(32767);
l_module VARCHAR2(32767);
l_level NUMBER;
l_dir VARCHAR2(32767);
l_comma_pos NUMBER;
l_curr_msg_count NUMBER := 0;
l_debug_reset VARCHAR2(1) := 'N';
l_recipient1 VARCHAR2(32767);
l_recipient2 VARCHAR2(32767);
l_recipient3 VARCHAR2(32767);
l_temp_message VARCHAR2(32767);
CURSOR c_user_info(p_user_id IN NUMBER) IS
SELECT user_name, email_address
FROM fnd_user
WHERE user_id = p_user_id;

CURSOR c_utl_file IS
SELECT value from v$parameter
WHERE lower(name) = 'utl_file_dir';

CURSOR c_env IS
SELECT name from v$database;

l_om_debug_enabled VARCHAR2(30);

BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name, 'p_action_code', p_action_code);
    WSH_DEBUG_SV.log(l_module_name, 'p_raise_exception', p_raise_Exception);
 END IF;

-- NO NEED TO CHECK USER EMAIL. USING HARDCODED EMAIL IDS
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

 IF p_action_code NOT IN ('SPLIT-LINE', 'CYCLE-COUNT', 'PACK') THEN
   l_conc_request_id := fnd_global.conc_request_id;
 END IF;

 IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name, 'User Id', g_userid);
       wsh_debug_sv.log(l_module_name, 'User Name', g_user_name);
       wsh_debug_sv.log(l_module_name, 'Env', g_env);
 END IF;


  IF p_action_code IN('ITS', 'SPLIT-LINE', 'CYCLE-COUNT', 'PACK', 'AUTO-PACK', 'CONFIRM', 'OM') THEN
    IF g_add_to_debug = 0 THEN
      IF nvl(p_raise_exception, 'Y') = 'Y' THEN
         l_rollback_allowed := 'Y';
      ELSE
         --Cases where ITS cannot be rerun.
         l_rollback_allowed := 'N';
         g_add_to_debug := 1;
      END IF;
    ELSE
       l_rollback_allowed := 'N';
    END IF;
 ELSE
    l_rollback_allowed := 'N';
    g_add_to_debug := 1;
 END IF;

 l_debug_dir := WSH_DEBUG_SV.g_dir;

 IF g_dc_table.count > 0
   AND l_rollback_allowed = 'Y' THEN
 --{
    fnd_profile.get('WSH_DEBUG_MODULE',l_module);
    --
    fnd_profile.get('WSH_DEBUG_LEVEL', l_level);
    --
    fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_dir);


    -- Check Debug directory is a valid location
    -- Check Debug level is set to maximum i.e statement level
    -- Check Debug module is set to %.

    OPEN c_utl_file;
    FETCH c_utl_file INTO l_utl_file_locns;
    CLOSE c_utl_file;

    --Check if debug directory is a valid directory for non-concurrent request transactions
    IF INSTRB(l_utl_file_locns, l_debug_dir) = 0
     AND nvl(l_conc_request_id, -1) = -1
    THEN
       --Debug directory is not a utl file location. Set debug directory.
      l_comma_pos := INSTRB(l_utl_file_locns, ',');
      l_debug_dir := SUBSTRB(l_utl_file_locns, 1, l_comma_pos-1);
      fnd_profile.put('WSH_DEBUG_LOG_DIRECTORY', l_debug_dir);
      IF l_debug_on THEN
         l_debug_reset := 'Y';
      END IF;
      l_debug_on := FALSE;
    END IF;

    IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name, 'l_comma_pos', l_comma_pos);
    END IF;

    IF nvl(l_level, 9999)  > WSH_DEBUG_SV.C_STMT_LEVEL THEN
      --Debug level is either not set or is set to a higher level
      --Need to set to statement level.
      fnd_profile.put('WSH_DEBUG_LEVEL', WSH_DEBUG_SV.C_STMT_LEVEL);
      IF l_debug_on THEN
         l_debug_reset := 'Y';
      END IF;
      l_debug_on := FALSE;

    END IF;
--}
END IF;

 IF p_action_code NOT IN ('SPLIT-LINE', 'CYCLE-COUNT', 'PACK') THEN
   l_conc_request_id := fnd_global.conc_request_id;
 END IF;

 IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name, 'l_debug_dir', l_debug_dir);
    wsh_debug_sv.log(l_module_name, 'g_dc_table count' , g_dc_table.count);
    wsh_debug_sv.log(l_module_name, 'l_rollback_allowed', l_rollback_allowed);
    wsh_debug_sv.log(l_module_name, 'conc request id', l_conc_request_id);
    WSH_DEBUG_SV.log(l_module_name, 'g_add_to_debug', g_add_to_debug);
 END IF;

 IF g_dc_table.count > 0
 THEN
 --{
    --Get CallStack
    l_call_stack := dbms_utility.format_call_stack;

    IF NOT oe_debug_pub.ISDebugOn THEN
       l_om_debug_enabled := 'N';
    ELSE
       l_om_debug_enabled := 'Y';
    END IF;

   IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'l_om_debug_enabled', l_om_debug_enabled);
   END IF;

    -- turn debug on
    IF NOT l_debug_on THEN
       wsh_debug_sv.start_debugger(
              x_file_name => l_debug_file,
	      x_return_status => l_return_status,
	      x_msg_count     => l_msg_count,
	      x_msg_data    => l_msg_data);

        IF l_debug_reset = 'Y' THEN
           G_DEBUG_STARTED := 'R';
        ELSE
           IF l_om_debug_enabled = 'N' THEN
              --OM debug was not on initially, starting WSH debugger starts OM debug too
              -- Set g_debug_started to B meaning Both.
              G_DEBUG_STARTED := 'B';
           ELSE
              --only shipping debug has been started.
              G_DEBUG_STARTED := 'W';
           END IF;
        END IF;

        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    ELSE
      --WSH debug is already ON. Check if OM debug is ON.

       IF l_om_debug_enabled = 'N' THEN

          IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name, 'Starting OM DEBUG');
             wsh_debug_sv.log(l_module_name, 'Directory', wsh_debug_sv.g_dir);
             wsh_debug_sv.log(l_module_name, 'File', wsh_debug_sv.g_file);
          END IF;
          oe_debug_pub.start_ont_debugger(
             p_directory => wsh_debug_sv.g_dir,
             p_filename  => wsh_debug_sv.g_file,
             p_file_handle => null);
          --Only OM debug is being started
          G_DEBUG_STARTED := 'O';
       ELSE
          g_add_to_debug := 1;
          l_debug_file := WSH_DEBUG_SV.g_file;
       END IF;

    END IF;


   IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'G_DEBUG_STARTED', G_DEBUG_STARTED);
      wsh_Debug_sv.log(l_module_name, 'g_add_to_debug', g_add_to_debug);
      WSH_DEBUG_SV.log(l_module_name, 'p_action_code', p_action_code);
   END IF;

   IF g_add_to_debug > 0 THEN
   --{

      IF p_action_code IN ('SPLIT-LINE', 'CYCLE-COUNT', 'PICK-RELEASE', 'PACK',
        'AUTO-PACK', 'ITS', 'CONFIRM')
      THEN
         l_message := 'Action performed : ' || p_action_code;
      ELSIF p_action_code = 'OM' THEN
          l_message := 'Action performed : ' || 'OM call to Shipping';
      END IF;



      if nvl(l_conc_request_id, -1) <> -1 then
         l_message := l_message ||'
Data Inconsistency found in environment ' || g_env || ' for concurrent request id ' || l_conc_request_id || ' submitted by user ' || g_user_name;
      else
         l_message := l_message || '
Data Inconsistency found in environment ' || g_env || ' for a transaction run by user ' || g_user_name || ' Debug Dir = ' || l_debug_dir || ' Debug file for this transaction= ' || l_debug_file;
      end if;
      --


       -- dump the call stack and pl/sql table
       -- if global was set , turn debug off
       -- Put CallStack in debug file
       if l_debug_on then
          wsh_debug_sv.log(l_module_name, 'l_call_stack', l_call_stack);
       end if;

       k := g_dc_table.first;

       WHILE k is not null LOOP
       --{
           l_temp_message := k||'. Data Mismatch #'||g_dc_table(k).dcp_script||' Detected for Order No: '||g_dc_table(k).source_header_number ||' Line No: '||g_dc_table(k).source_line_number || ' Delivery Detail No: ' || g_dc_table(k).delivery_detail_id;

           IF length(l_message) < 31900 THEN
              l_message := l_message || '
' || l_temp_message;
           END IF;

          IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name, l_temp_message);
          END IF;
          k := g_dc_table.next(k);
       --}
       END LOOP;

      IF instrb(get_email_server, 'oracle') > 0
        AND length(l_message) < 32300 THEN
          IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name, 'Adding link to email message');
          END IF;

         l_temp_message := '---------------------------------------------------------------------
For a description of the data mismatch, please refer to the following link:
http://www-apps.us.oracle.com:1100/~kvenkate/DCP_Case_descriptions.html';

         l_message := l_message || '
' || l_temp_message;

      END IF;

       --Need to re-initialize g_add_to_debug because for ITS cases where multiple
       --headers or multiple batches are being processed, the subsequent headers or batches
       --need to have the correct initialization.
       g_add_to_debug := 0;

      --Send Email



          Send_Mail(sender => l_recipient1,
              recipient1 => l_recipient1,
              recipient2 => l_recipient2,
              recipient3 => l_recipient3,
              message => l_message);
   --}
   END IF;

    --Raise exception. Stop debugger if rollback is not possible
    IF l_rollback_allowed = 'Y'
      AND G_DEBUG_STARTED IN ('W', 'R', 'O', 'B')
      AND nvl(p_raise_exception, 'Y') = 'Y' THEN
       --increase global constant;
         g_add_to_debug := g_add_to_debug + 1;

       --Delete additional messages from stack.
       l_curr_msg_count := fnd_msg_pub.count_msg;

       if l_debug_on then
          wsh_debug_sv.log(l_module_name, 'G_INIT_MSG_COUNT', G_INIT_MSG_COUNT);
          wsh_debug_sv.log(l_module_name, 'l_curr_msg_count', l_curr_msg_count);
       end if;

       FOR k IN REVERSE (G_INIT_MSG_COUNT+1)..l_curr_msg_count LOOP
       --{
         fnd_msg_pub.delete_msg(p_msg_index => k);
       --}
       END LOOP;
       if l_debug_on then
          wsh_debug_sv.log(l_module_name, 'new count', fnd_msg_pub.count_msg);
       end if;
         RAISE dcp_caught;
    ELSE

       IF G_DEBUG_STARTED IN ('B', 'W') THEN
         wsh_debug_interface.stop_debugger;
       END IF;

       IF G_DEBUG_STARTED IN ('B', 'O') THEN
          oe_debug_pub.stop_ont_debugger;
       END IF;
    END IF;
--}
END IF;
  IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
  END IF;
EXCEPTION
WHEN dcp_caught THEN
   IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, 'DCP Caught: Post Process');
      wsh_debug_sv.pop(l_module_name, 'Exception: dcp_caught');
   END IF;
   RAISE dcp_caught;
WHEN others THEN
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
  END IF;
END Post_Process;

Procedure Check_Scripts(p_source_header_id IN NUMBER,
                        p_source_line_id IN NUMBER,
                        p_delivery_id IN NUMBER,
                        p_batch_id IN NUMBER,
                        x_data_inconsistent OUT NOCOPY VARCHAR2)
IS

l_rec t_dc_columns_rec_type;


CURSOR c_combine_hdr IS
select wdd.source_header_number, wdd.source_line_number, wdd.delivery_detail_id,
       wdd.released_status, wdd.requested_quantity, wdd.source_code, wdd.batch_id,
       wdd.source_line_id, wdd.source_header_id, wdd.oe_interfaced_flag, wdd.inv_interfaced_flag,
       wdd.ship_set_id, wdd.date_requested, wdd.date_scheduled, wdd.ship_to_contact_id,
       wdd.ship_to_site_use_id, wdd.org_id, wdd.organization_id,
       wdd.ship_tolerance_above, wdd.ship_tolerance_below,
       wdd.picked_quantity, wdd.cycle_count_quantity, wdd.shipped_quantity detail_sq,
       ol.line_id,
       RTRIM(ol.line_number || '.' || ol.shipment_number || '.' || ol.option_number || '.' || ol.component_number || '.' || ol.service_number, '.') line_number,
       ol.ordered_quantity, ol.cancelled_flag,
       ol.ship_set_id ol_ship_set_id, ol.shipped_quantity, ol.flow_status_code, ol.open_flag,
       ol.ship_from_org_id, ol.org_id ol_org_id,ol.schedule_ship_date, ol.request_date,
       ol.shipping_interfaced_flag, ol.header_id,
       ol.ship_to_contact_id ol_ship_to_contact_id, ol.ship_to_org_id,
       ol.fulfilled_quantity, ol.invoiced_quantity,
       oh.order_number, oh.ship_from_org_id,
       wnd.delivery_id, wnd.status_code dlvy_status_code, wts.status_code stop_status_code, wdl.delivery_leg_id
from   wsh_delivery_details wdd,
       oe_order_lines_all ol,
       oe_order_headers_all oh,
     wsh_delivery_assignments_v wda,
     wsh_new_deliveries wnd,
     wsh_delivery_legs wdl,
     wsh_trip_stops wts
where wdd.source_code = 'OE'
and   wdd.source_line_id = ol.line_id
and  nvl(ol.shippable_flag, 'N') = 'Y'
and   wdd.source_header_id = p_source_header_id
and  ol.header_id = oh.header_id
and  wdd.delivery_detail_id = wda.delivery_detail_id
and wda.delivery_id = wnd.delivery_id (+)
and wnd.delivery_id = wdl.delivery_id (+)
and wdl.pick_up_stop_id = wts.stop_id (+);


CURSOR c_combine_line IS
select wdd.source_header_number, wdd.source_line_number, wdd.delivery_detail_id,
       wdd.released_status, wdd.requested_quantity, wdd.source_code, wdd.batch_id,
       wdd.source_line_id, wdd.source_header_id, wdd.oe_interfaced_flag, wdd.inv_interfaced_flag,
       wdd.ship_set_id, wdd.date_requested, wdd.date_scheduled, wdd.ship_to_contact_id,
       wdd.ship_to_site_use_id, wdd.org_id, wdd.organization_id,
       wdd.ship_tolerance_above, wdd.ship_tolerance_below,
       wdd.picked_quantity, wdd.cycle_count_quantity, wdd.shipped_quantity detail_sq,
       ol.line_id,
       RTRIM(ol.line_number || '.' || ol.shipment_number || '.' || ol.option_number || '.' || ol.component_number || '.' || ol.service_number, '.') line_number,
       ol.ordered_quantity, ol.cancelled_flag,
       ol.ship_set_id ol_ship_set_id, ol.shipped_quantity, ol.flow_status_code, ol.open_flag,
       ol.ship_from_org_id, ol.org_id ol_org_id,ol.schedule_ship_date, ol.request_date,
       ol.shipping_interfaced_flag, ol.header_id,
       ol.ship_to_contact_id ol_ship_to_contact_id, ol.ship_to_org_id,
       ol.fulfilled_quantity, ol.invoiced_quantity,
       oh.order_number, oh.ship_from_org_id,
       wnd.delivery_id, wnd.status_code dlvy_status_code, wts.status_code stop_status_code, wdl.delivery_leg_id
from   wsh_delivery_details wdd,
       oe_order_lines_all ol,
       oe_order_headers_all oh,
     wsh_delivery_assignments_v wda,
     wsh_new_deliveries wnd,
     wsh_delivery_legs wdl,
     wsh_trip_stops wts
where wdd.source_code = 'OE'
and   wdd.source_line_id = ol.line_id
and  nvl(ol.shippable_flag, 'N') = 'Y'
and   wdd.source_line_id = p_source_line_id
and ol.header_id = oh.header_id
and  wdd.delivery_detail_id = wda.delivery_detail_id
and wda.delivery_id = wnd.delivery_id (+)
and wnd.delivery_id = wdl.delivery_id (+)
and wdl.pick_up_stop_id = wts.stop_id (+);

CURSOR c_combine_dlvy IS
select wdd.source_header_number, wdd.source_line_number, wdd.delivery_detail_id,
       wdd.released_status, wdd.requested_quantity, wdd.source_code, wdd.batch_id,
       wdd.source_line_id, wdd.source_header_id, wdd.oe_interfaced_flag, wdd.inv_interfaced_flag,
       wdd.ship_set_id, wdd.date_requested, wdd.date_scheduled, wdd.ship_to_contact_id,
       wdd.ship_to_site_use_id, wdd.org_id, wdd.organization_id,
       wdd.ship_tolerance_above, wdd.ship_tolerance_below,
       wdd.picked_quantity, wdd.cycle_count_quantity, wdd.shipped_quantity detail_sq,
       ol.line_id,
       RTRIM(ol.line_number || '.' || ol.shipment_number || '.' || ol.option_number || '.' || ol.component_number || '.' || ol.service_number, '.') line_number,
       ol.ordered_quantity, ol.cancelled_flag,
       ol.ship_set_id ol_ship_set_id, ol.shipped_quantity, ol.flow_status_code, ol.open_flag,
       ol.ship_from_org_id, ol.org_id ol_org_id,ol.schedule_ship_date, ol.request_date,
       ol.shipping_interfaced_flag, ol.header_id,
       ol.ship_to_contact_id ol_ship_to_contact_id, ol.ship_to_org_id,
       ol.fulfilled_quantity, ol.invoiced_quantity,
       oh.order_number, oh.ship_from_org_id,
       wnd.delivery_id, wnd.status_code dlvy_status_code, wts.status_code stop_status_code, wdl.delivery_leg_id
from   wsh_delivery_details wdd,
       oe_order_lines_all ol,
      oe_order_headers_all oh,
     wsh_delivery_assignments_v wda,
     wsh_new_deliveries wnd,
     wsh_delivery_legs wdl,
     wsh_trip_stops wts
where wdd.source_code = 'OE'
and   wdd.source_line_id = ol.line_id
and  nvl(ol.shippable_flag, 'N') = 'Y'
and ol.header_id = oh.header_id
and   wda.delivery_id = p_delivery_id
and  wdd.delivery_detail_id = wda.delivery_detail_id
and wda.delivery_id is not null
and wda.delivery_id = wnd.delivery_id (+)
and wnd.delivery_id = wdl.delivery_id (+)
and wdl.pick_up_stop_id = wts.stop_id (+);

CURSOR c_combine_batch IS
select wdd.source_header_number, wdd.source_line_number, wdd.delivery_detail_id,
       wdd.released_status, wdd.requested_quantity, wdd.source_code, wdd.batch_id,
       wdd.source_line_id, wdd.source_header_id, wdd.oe_interfaced_flag, wdd.inv_interfaced_flag,
       wdd.ship_set_id, wdd.date_requested, wdd.date_scheduled, wdd.ship_to_contact_id,
       wdd.ship_to_site_use_id, wdd.org_id, wdd.organization_id,
       wdd.ship_tolerance_above, wdd.ship_tolerance_below,
       wdd.picked_quantity, wdd.cycle_count_quantity, wdd.shipped_quantity detail_sq,
       ol.line_id,
       RTRIM(ol.line_number || '.' || ol.shipment_number || '.' || ol.option_number || '.' || ol.component_number || '.' || ol.service_number, '.') line_number,
       ol.ordered_quantity, ol.cancelled_flag,
       ol.ship_set_id ol_ship_set_id, ol.shipped_quantity, ol.flow_status_code, ol.open_flag,
       ol.ship_from_org_id, ol.org_id ol_org_id,ol.schedule_ship_date, ol.request_date,
       ol.shipping_interfaced_flag, ol.header_id,
       ol.ship_to_contact_id ol_ship_to_contact_id, ol.ship_to_org_id,
       ol.fulfilled_quantity, ol.invoiced_quantity,
       oh.order_number, oh.ship_from_org_id,
       wnd.delivery_id, wnd.status_code dlvy_status_code, wts.status_code stop_status_code, wdl.delivery_leg_id
from   wsh_delivery_details wdd,
       oe_order_lines_all ol,
      oe_order_headers_all oh,
     wsh_delivery_assignments_v wda,
     wsh_new_deliveries wnd,
     wsh_delivery_legs wdl,
     wsh_trip_stops wts
where wdd.source_code = 'OE'
and   wdd.source_line_id = ol.line_id
and  nvl(ol.shippable_flag, 'N') = 'Y'
and ol.header_id = oh.header_id
and   wdd.batch_id = p_batch_id
and  wdd.delivery_detail_id = wda.delivery_detail_id
and wda.delivery_id = wnd.delivery_id (+)
and wnd.delivery_id = wdl.delivery_id (+)
and wdl.pick_up_stop_id = wts.stop_id (+);

CURSOR c2_hdr IS
select wdd.source_header_number, wdd.source_line_number, wdd.delivery_detail_id
from   wsh_delivery_details wdd,
       oe_order_lines_all ol
where  wdd.source_code = 'OE'
and    wdd.source_line_id = ol.line_id
and    nvl(wdd.ship_tolerance_above,0) = 0
and    nvl(wdd.ship_tolerance_below,0) = 0
and    wdd.source_header_id = p_source_header_id
and    (wdd.released_status = 'D' or wdd.requested_quantity = 0)
and    (ol.ordered_quantity > 0 or ol.cancelled_flag = 'N')
and    not exists (
         select 'x'
         from   wsh_delivery_details wdd1
         where  wdd1.source_line_id = wdd.source_line_id
         and    wdd1.delivery_detail_id <> wdd.delivery_detail_id
         and    (wdd1.released_status <> 'D' or wdd1.requested_quantity > 0))
and  nvl(ol.shippable_flag, 'N') = 'Y';

CURSOR c2_line IS
select wdd.source_header_number, wdd.source_line_number, wdd.delivery_detail_id
from   wsh_delivery_details wdd,
       oe_order_lines_all ol
where  wdd.source_code = 'OE'
and    wdd.source_line_id = ol.line_id
and    nvl(wdd.ship_tolerance_above,0) = 0
and    nvl(wdd.ship_tolerance_below,0) = 0
and    wdd.source_line_id = p_source_line_id
and    (wdd.released_status = 'D' or wdd.requested_quantity = 0)
and    (ol.ordered_quantity > 0 or ol.cancelled_flag = 'N')
and    not exists (
         select 'x'
         from   wsh_delivery_details wdd1
         where  wdd1.source_line_id = wdd.source_line_id
         and    wdd1.delivery_detail_id <> wdd.delivery_detail_id
         and    (wdd1.released_status <> 'D' or wdd1.requested_quantity > 0))
and  nvl(ol.shippable_flag, 'N') = 'Y';

CURSOR c2_dlvy IS
select wdd.source_header_number, wdd.source_line_number, wdd.delivery_detail_id
from   wsh_delivery_details wdd,
       oe_order_lines_all ol,
       wsh_delivery_assignments_v wda
where  wdd.source_code = 'OE'
and    wdd.source_line_id = ol.line_id
and    nvl(wdd.ship_tolerance_above,0) = 0
and    nvl(wdd.ship_tolerance_below,0) = 0
and    wdd.delivery_detail_id = wda.delivery_detail_id
and    wda.delivery_id is not null
and    wda.delivery_id = p_delivery_id
and    (wdd.released_status = 'D' or wdd.requested_quantity = 0)
and    (ol.ordered_quantity > 0 or ol.cancelled_flag = 'N')
and    not exists (
         select 'x'
         from   wsh_delivery_details wdd1
         where  wdd1.source_line_id = wdd.source_line_id
         and    wdd1.delivery_detail_id <> wdd.delivery_detail_id
         and    (wdd1.released_status <> 'D' or wdd1.requested_quantity > 0))
and  nvl(ol.shippable_flag, 'N') = 'Y';

CURSOR c2_batch IS
select wdd.source_header_number, wdd.source_line_number, wdd.delivery_detail_id
from   wsh_delivery_details wdd,
       oe_order_lines_all ol
where  wdd.source_code = 'OE'
and    wdd.source_line_id = ol.line_id
and    nvl(wdd.ship_tolerance_above,0) = 0
and    nvl(wdd.ship_tolerance_below,0) = 0
and    wdd.batch_id = p_batch_id
and    (wdd.released_status = 'D' or wdd.requested_quantity = 0)
and    (ol.ordered_quantity > 0 or ol.cancelled_flag = 'N')
and    not exists (
         select 'x'
         from   wsh_delivery_details wdd1
         where  wdd1.source_line_id = wdd.source_line_id
         and    wdd1.delivery_detail_id <> wdd.delivery_detail_id
         and    (wdd1.released_status <> 'D' or wdd1.requested_quantity > 0))
and  nvl(ol.shippable_flag, 'N') = 'Y';


CURSOR C12_hdr IS
select wdd.source_header_number, wdd.source_line_number, wdd.delivery_detail_id
from  wsh_delivery_details wdd,
      oe_order_lines_all ol
where wdd.source_code = 'OE'
and   wdd.source_header_id = p_source_header_id
and   wdd.source_line_id = ol.line_id
and   nvl(wdd.oe_interfaced_flag,'N') = 'N'
and   exists (
        select 'x'
        from  oe_order_lines_all ol1
        where ol1.ship_set_id = wdd.ship_set_id
        and   ol1.header_id = wdd.source_header_id
        and   ol1.shipped_quantity is NOT NULL
        and   ol1.flow_status_code <> 'AWAITING_SHIPPING')
and wdd.ship_set_id is NOT NULL
and  nvl(ol.shippable_flag, 'N') = 'Y'
and wdd.released_status <> 'D';

CURSOR C12_line IS
select wdd.source_header_number, wdd.source_line_number, wdd.delivery_detail_id
from  wsh_delivery_details wdd,
      oe_order_lines_all ol
where wdd.source_code = 'OE'
and    wdd.source_line_id = p_source_line_id
and   wdd.source_line_id = ol.line_id
and   nvl(wdd.oe_interfaced_flag,'N') = 'N'
and   exists (
        select 'x'
        from  oe_order_lines_all ol1
        where ol1.ship_set_id = wdd.ship_set_id
        and   ol1.header_id = wdd.source_header_id
        and   ol1.shipped_quantity is NOT NULL
        and   ol1.flow_status_code <> 'AWAITING_SHIPPING')
and wdd.ship_set_id is NOT NULL
and  nvl(ol.shippable_flag, 'N') = 'Y'
and wdd.released_status <> 'D';

CURSOR C12_dlvy IS
select wdd.source_header_number, wdd.source_line_number, wdd.delivery_detail_id
from  wsh_delivery_details wdd,
      wsh_delivery_assignments_v wda,
      oe_order_lines_all ol
where wdd.source_code = 'OE'
and   wdd.source_line_id = ol.line_id
and   wdd.delivery_detail_id = wda.delivery_detail_id
and   wda.delivery_id is not null
and   wda.delivery_id = p_delivery_id
and   nvl(wdd.oe_interfaced_flag,'N') = 'N'
and   exists (
        select 'x'
        from  oe_order_lines_all ol1
        where ol1.ship_set_id = wdd.ship_set_id
        and   ol1.header_id = wdd.source_header_id
        and   ol1.shipped_quantity is NOT NULL
        and   ol1.flow_status_code <> 'AWAITING_SHIPPING')
and wdd.ship_set_id is NOT NULL
and  nvl(ol.shippable_flag, 'N') = 'Y'
and wdd.released_status <> 'D';

CURSOR C12_batch IS
select wdd.source_header_number, wdd.source_line_number, wdd.delivery_detail_id
from  wsh_delivery_details wdd,
      oe_order_lines_all ol
where wdd.source_code = 'OE'
and   wdd.batch_id = p_batch_id
and   wdd.source_line_id = ol.line_id
and   nvl(wdd.oe_interfaced_flag,'N') = 'N'
and   exists (
        select 'x'
        from  oe_order_lines_all ol1
        where ol1.ship_set_id = wdd.ship_set_id
        and   ol1.header_id = wdd.source_header_id
        and   ol1.shipped_quantity is NOT NULL
        and   ol1.flow_status_code <> 'AWAITING_SHIPPING')
and wdd.ship_set_id is NOT NULL
and  nvl(ol.shippable_flag, 'N') = 'Y'
and wdd.released_status <> 'D';


--Prompt 14. Lines that are interfaced to shipping but there is no corresponding delivery detail
--Cursor #6
CURSOR C6_hdr IS
select oh.order_number,
       RTRIM(ol.line_number || '.' || ol.shipment_number || '.' || ol.option_number || '.' || ol.component_number || '.' || ol.service_number, '.') line_number
from   oe_order_headers_all oh,
       oe_order_lines_all ol
where  oh.header_id = ol.header_id
and    oh.header_id = p_source_header_id
and    ol.shipping_interfaced_flag = 'Y'
and  nvl(ol.shippable_flag, 'N') = 'Y'
and    not exists (
         select 'x'
         from   wsh_delivery_details wdd
         where  wdd.source_code = 'OE'
         and    wdd.source_line_id = ol.line_id);

CURSOR C6_line IS
select oh.order_number,
      RTRIM(ol.line_number || '.' || ol.shipment_number || '.' || ol.option_number || '.' || ol.component_number || '.' || ol.service_number, '.') line_number
from   oe_order_headers_all oh,
       oe_order_lines_all ol
where  oh.header_id = ol.header_id
and    ol.line_id = p_source_line_id
and    ol.shipping_interfaced_flag = 'Y'
and  nvl(ol.shippable_flag, 'N') = 'Y'
and    not exists (
         select 'x'
         from   wsh_delivery_details wdd
         where  wdd.source_code = 'OE'
         and    wdd.source_line_id = ol.line_id);

--Prompt 32. Orphan reservations against closed lines
--Cursor #13
CURSOR C13_hdr IS
select oeh.order_number,
       oel.line_id,
       RTRIM(oel.line_number || '.' || oel.shipment_number || '.' || oel.option_number || '.' || oel.component_number || '.' || oel.service_number, '.') line_number
from   oe_order_headers_all oeh,
       oe_order_lines_all   oel
where  oeh.header_id = p_source_header_id
and    oeh.header_id = oel.header_id
and    oel.open_flag = 'N'
and  nvl(oel.shippable_flag, 'N') = 'Y'
and    exists (
          select 'x'
          from   mtl_reservations mr
          where  mr.demand_source_line_id = oel.line_id
          and    mr.primary_reservation_quantity > 0
              )
and    not exists (
          select 'x'
          from   wsh_delivery_details wdd
          where  wdd.source_line_id = oel.line_id
          and    wdd.source_code = 'OE'
          and    wdd.inv_interfaced_flag in ('N','P'))
order  by 1,2;

CURSOR C13_line IS
select oeh.order_number,
       oel.line_id,
       RTRIM(oel.line_number || '.' || oel.shipment_number || '.' || oel.option_number || '.' || oel.component_number || '.' || oel.service_number, '.') line_number
from   oe_order_headers_all oeh,
       oe_order_lines_all   oel
where   oel.line_id = p_source_line_id
and    oeh.header_id = oel.header_id
and    oel.open_flag = 'N'
and  nvl(oel.shippable_flag, 'N') = 'Y'
and    exists (
          select 'x'
          from   mtl_reservations mr
          where  mr.demand_source_line_id = oel.line_id
          and    mr.primary_reservation_quantity > 0
              )
and    not exists (
          select 'x'
          from   wsh_delivery_details wdd
          where  wdd.source_line_id = oel.line_id
          and    wdd.source_code = 'OE'
          and    wdd.inv_interfaced_flag in ('N','P'))
order  by 1,2;

l_dummy varchar2(30);
k NUMBER;
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_SCRIPTS';
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,' p_source_header_id', p_source_header_id);
    WSH_DEBUG_SV.log(l_module_name, 'p_source_line_id', p_source_line_id);
    WSH_DEBUG_SV.log(l_module_name, 'p_delivery_id', p_delivery_id);
    WSH_DEBUG_SV.log(l_module_name, 'p_batch_id', p_batch_id);
 END IF;

   x_data_inconsistent := 'N';

   k := g_dc_table.count;

  IF p_source_line_id IS NOT NULL THEN
     OPEN c_combine_line;
  ELSIF p_source_header_id IS NOT NULL THEN
     OPEN c_combine_hdr;
  ELSIF p_delivery_id IS NOT NULL THEN
     OPEN c_combine_dlvy;
  ELSIF p_batch_id IS NOT NULL THEN
     OPEN c_combine_batch;
  END IF;

 LOOP
 --{

  IF c_combine_hdr%ISOPEN THEN
     FETCH c_combine_hdr INTO l_rec;
     EXIT WHEN c_combine_hdr%NOTFOUND;
  ELSIF c_combine_line%ISOPEN THEN
     FETCH c_combine_line INTO l_rec;
     EXIT WHEN c_combine_line%NOTFOUND;
  ELSIF c_combine_dlvy%ISOPEN THEN
    FETCH c_combine_dlvy INTO l_rec;
    EXIT WHEN c_combine_dlvy%NOTFOUND;
  ELSIF c_combine_batch%ISOPEN THEN
    FETCH c_combine_batch INTO l_rec;
    EXIT WHEN c_combine_batch%NOTFOUND;
  ELSE
    EXIT;
  END IF;

  --check c1
  if (l_rec.ol_ordered_quantity = 0 or l_rec.ol_cancelled_flag = 'Y')
     and (l_rec.wdd_requested_quantity > 0 or l_rec.wdd_released_status <> 'D')
  then
     x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C1';
   end if;


 --Check c3
  if nvl(nvl(l_rec.ol_shipped_quantity, l_rec.ol_fulfilled_quantity), l_rec.ol_invoiced_quantity) > 0
     and    l_rec.wdd_oe_interfaced_flag = 'N'
     and    l_rec.wdd_released_status = 'C'
  then
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C3';
  end if;

 --Check c4
   if  nvl(l_rec.ol_shipped_quantity,0) = 0
      and    l_rec.wdd_oe_interfaced_flag = 'Y'
      and    l_rec.wdd_released_status = 'C'
   then
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C4';

   end if;

--Check c5
   if  nvl(l_rec.wdd_ship_set_id,-99) <> nvl(l_rec.ol_ship_set_id,-99)
   then
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C5';

    end if;



  --Check c7
  if l_rec.ol_shipping_interfaced_flag = 'N'
     and l_rec.wdd_delivery_detail_id IS NOT NULL
  then
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).dcp_script := 'C7';
  end if;

  --Check c8
    if  nvl(l_rec.wdd_oe_interfaced_flag,'N') = 'N'
       and    ( nvl(l_rec.wdd_date_scheduled, (sysdate - 50000) ) <> nvl(l_rec.ol_schedule_ship_date, (sysdate - 50000) ) or
         nvl(l_rec.wdd_date_requested,(sysdate - 50000))  <> nvl(l_rec.ol_request_date, (sysdate - 50000)) or
         nvl(l_rec.wdd_ship_to_contact_id,-99) <> nvl(l_rec.ol_ship_to_contact_id,-99) or
         nvl(l_rec.wdd_ship_to_site_use_id,-99) <> nvl(l_rec.ol_ship_to_org_id,-99)
       )
    then
       k := k+1;
        g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
       g_dc_table(k).source_line_number := l_rec.ol_line_number;
       g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C8';

      if l_debug_on then

         wsh_debug_sv.logmsg(l_module_name, 'DD attributes dates:' || to_char(l_rec.wdd_date_requested, 'dd-mon-yy hh24:mi:ss') || '-' || to_char(l_rec.wdd_date_scheduled, 'dd-mon-yy hh24:mi:ss'));

         wsh_debug_sv.logmsg(l_module_name, 'DD attributes contact use:' || l_rec.wdd_ship_to_contact_id || '-' || l_rec.wdd_ship_to_site_use_id);

         wsh_debug_sv.logmsg(l_module_name, 'OL attributes dates:' || to_char(l_rec.ol_request_date,'dd-mon-yy hh24:mi:ss') || '-' || to_char(l_rec.ol_schedule_ship_date, 'dd-mon-yy hh24:mi:ss'));

         wsh_debug_sv.logmsg(l_module_name, 'OL attributes contact use:' || l_rec.ol_ship_to_contact_id || '-' || l_rec.ol_ship_to_org_id);

      end if;
    end if;

  --Check c9
    if  nvl(l_rec.wdd_org_id,-99) <> nvl(l_rec.ol_org_id, -99)
    then
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C9 diff org' || '-' || l_rec.wdd_org_id || '-' || l_rec.ol_org_id;
    end if;

--Check c10
   if l_rec.oh_ship_from_org_id IS NULL
     and l_rec.ol_ship_from_org_id IS NULL
     and l_rec.ol_open_flag = 'Y'
   then
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.oh_order_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).dcp_script := 'C10';
   end if;

 --Check c11
    if  nvl(l_rec.wdd_Organization_id, -99) <> nvl(l_rec.ol_ship_from_org_id,-99)
    then
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C11 diff organization' || '-' || l_rec.wdd_organization_id || '-' || l_rec.ol_ship_from_org_id;
    end if;


-- Check c14
   if  l_rec.ol_open_flag = 'N'
     and l_rec.wdd_released_status in ('R','N','X','S','B','Y')
   then
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C14';
    end if;

--check 15
   if l_rec.wdd_requested_quantity = 0
      and l_rec.wdd_released_status = 'R'
   then
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C15';
   end if;

    --delivery checks
   if l_rec.wdd_released_status = 'Y'
      and l_rec.wnd_status_code = 'CL'
   then
     x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C16';

   end if;


    --Shipped delivery details assigned to open delivery
    if l_rec.wdd_released_status = 'C'
       and l_rec.wnd_status_code = 'OP'
    then
     x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C17';
    end if;

     --Confirmed(but not closed) deliveries are assigned to closed stops
    if l_rec.wnd_status_code = 'CO'
       and l_rec.wts_status_code = 'CL'
    then
    x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C18';
    end if;

 --Delivery closed but no trip/stops created
    if l_rec.wnd_status_code IN ('CO','IT','CL')
       and l_rec.wdl_delivery_leg_id IS NULL
    then
    x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C19';

    end if;

   --Quantity Checks
   if l_rec.wdd_released_status IN ('S', 'B')
      and l_rec.wdd_cycle_count_quantity IS NOT NULL
   then
    x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C20';
   end if;

   if l_rec.wdd_released_status IN ('X', 'Y')
      and  nvl(l_rec.wdd_cycle_Count_quantity,0) > ((nvl(nvl(l_rec.wdd_picked_quantity, l_rec.wdd_requested_quantity),0) - nvl(l_rec.wdd_shipped_quantity,0)))
      and nvl(l_rec.wdd_cycle_count_quantity,0) > 0
   then
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := l_rec.wdd_source_header_number;
      g_dc_table(k).source_line_number := l_rec.ol_line_number;
      g_dc_table(k).delivery_detail_id := l_rec.wdd_delivery_detail_id;
      g_dc_table(k).dcp_script := 'C21';
   end if;

 --} begin of loop
 END LOOP;

  IF c_combine_hdr%ISOPEN THEN
     CLOSE c_combine_hdr;
  ELSIF c_combine_line%ISOPEN THEN
     CLOSE c_combine_line;
  ELSIF c_combine_dlvy%ISOPEN THEN
    CLOSE c_combine_dlvy;
  ELSIF c_combine_batch%ISOPEN THEN
    CLOSE c_combine_batch;
  END IF;

 --Check c2
 if p_source_line_id is not null then
    for c_rec in c2_line loop
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := c_rec.source_header_number;
      g_dc_table(k).source_line_number := c_rec.source_line_number;
      g_dc_table(k).delivery_detail_id := c_rec.delivery_detail_id;
      g_dc_table(k).dcp_script := 'C2';

    end loop;

    for c_rec in c6_line loop
          x_data_inconsistent := 'Y';
          k := k+1;
          g_dc_table(k).source_header_number := c_rec.order_number;
          g_dc_table(k).source_line_number := c_rec.line_number;
          g_dc_table(k).dcp_script := 'C6';
    end loop;

    for c_rec in c12_line loop
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := c_rec.source_header_number;
      g_dc_table(k).source_line_number := c_rec.source_line_number;
      g_dc_table(k).delivery_detail_id := c_rec.delivery_detail_id;
      g_dc_table(k).dcp_script := 'C12';

    end loop;


    for c_rec in c13_line loop
         x_data_inconsistent := 'Y';
          k := k+1;
          g_dc_table(k).source_header_number := c_rec.order_number;
          g_dc_table(k).source_line_number := c_rec.line_number;
         g_dc_table(k).dcp_script := 'C13';
     end loop;
 elsif p_source_header_id is not null then
   for c_rec in c2_hdr loop
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := c_rec.source_header_number;
      g_dc_table(k).source_line_number := c_rec.source_line_number;
      g_dc_table(k).delivery_detail_id := c_rec.delivery_detail_id;
      g_dc_table(k).dcp_script := 'C2';

    end loop;

   for c_rec in c6_hdr loop
          x_data_inconsistent := 'Y';
          k := k+1;
          g_dc_table(k).source_header_number := c_rec.order_number;
          g_dc_table(k).source_line_number := c_rec.line_number;
          g_dc_table(k).dcp_script := 'C6';
   end loop;

    for c_rec in c12_hdr loop
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := c_rec.source_header_number;
      g_dc_table(k).source_line_number := c_rec.source_line_number;
      g_dc_table(k).delivery_detail_id := c_rec.delivery_detail_id;
      g_dc_table(k).dcp_script := 'C12';

    end loop;

      for c_rec in c13_hdr loop
          x_data_inconsistent := 'Y';
          k := k+1;
          g_dc_table(k).source_header_number := c_rec.order_number;
          g_dc_table(k).source_line_number := c_rec.line_number;
         g_dc_table(k).dcp_script := 'C13';
       end loop;

 elsif p_delivery_id is not null then
   for c_rec in c2_dlvy loop
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := c_rec.source_header_number;
     g_dc_table(k).source_line_number := c_rec.source_line_number;
      g_dc_table(k).delivery_detail_id := c_rec.delivery_detail_id;
      g_dc_table(k).dcp_script := 'C2';

    end loop;

   for c_rec in c12_dlvy loop
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := c_rec.source_header_number;
     g_dc_table(k).source_line_number := c_rec.source_line_number;
      g_dc_table(k).delivery_detail_id := c_rec.delivery_detail_id;
      g_dc_table(k).dcp_script := 'C12';

    end loop;

 elsif p_batch_id is not null then
   for c_rec in c2_batch loop
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := c_rec.source_header_number;
     g_dc_table(k).source_line_number := c_rec.source_line_number;
      g_dc_table(k).delivery_detail_id := c_rec.delivery_detail_id;
      g_dc_table(k).dcp_script := 'C2';

    end loop;

  for c_rec in c12_batch loop
      x_data_inconsistent := 'Y';
      k := k+1;
      g_dc_table(k).source_header_number := c_rec.source_header_number;
     g_dc_table(k).source_line_number := c_rec.source_line_number;
      g_dc_table(k).delivery_detail_id := c_rec.delivery_detail_id;
      g_dc_table(k).dcp_script := 'C12';

    end loop;

 end if;

  IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name, 'x_data_inconsistent', x_data_inconsistent);
    wsh_debug_sv.log(l_module_name, 'g_dc_table count', g_dc_table.count);
  END IF;


  IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
  END IF;
EXCEPTION
WHEN others THEN
  IF c_combine_hdr%ISOPEN THEN
     CLOSE c_combine_hdr;
  ELSIF c_combine_line%ISOPEN THEN
     CLOSE c_combine_line;
  ELSIF c_combine_dlvy%ISOPEN THEN
    CLOSE c_combine_dlvy;
  ELSIF c_combine_batch%ISOPEN THEN
    CLOSE c_combine_batch;
  END IF;
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
  END IF;
END Check_Scripts;

Procedure Check_ITS(p_bulk_mode IN VARCHAR2,
                    p_start_index IN NUMBER,
                    p_end_index IN NUMBER,
                    p_its_rec IN OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type,
                    p_raise_exception IN VARCHAR2)
IS
l_debug_on BOOLEAN;
l_data_inconsistent VARCHAR2(1) := 'N';

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_ITS';
i NUMBER;
l_header_id NUMBER := 0;
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name, 'p_bulk_mode', p_bulk_mode);
    WSH_DEBUG_SV.log(l_module_name, 'p_start_index', p_start_index);
    WSH_DEBUG_SV.log(l_module_name, 'p_end_index', p_end_index);
    WSH_DEBUG_SV.log(l_module_name, 'p_raise_exception', p_raise_Exception);
 END IF;

 g_dc_table.delete;

if p_bulk_mode = 'N' then
 i := p_its_rec.header_id.first;
elsif p_bulk_mode = 'Y' then
 i := p_start_index;
end if;

 WHILE i IS NOT NULL
   AND i <= nvl(p_end_index, p_its_rec.header_id.count) LOOP

  if p_its_rec.header_id(i) <> l_header_id then

    check_scripts(
              p_source_header_id => p_its_rec.header_id(i),
              x_data_inconsistent => l_data_inconsistent);

    l_header_id := p_its_rec.header_id(i);
  end if;

   i := p_its_rec.header_id.next(i);

   IF p_bulk_mode = 'N' THEN
      EXIT;
   END IF;

 END LOOP;

 Post_Process(p_action_code => 'ITS',
              p_raise_exception => p_raise_exception);


  IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN dcp_caught THEN
    if NOT l_debug_on OR l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    end if;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'dcp_caught exception: CHECK_ITS');
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DCP_CAUGHT: CHECK_ITS');
    END IF;
    RAISE data_inconsistency_exception;
  WHEN others THEN
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
   END IF;
END Check_ITS;

Procedure Check_Delivery(p_action_code IN VARCHAR2,
                    p_dlvy_table IN  WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type)
IS
l_debug_on BOOLEAN;
l_data_inconsistent VARCHAR2(1) := 'N';
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_DELIVERY';
i NUMBER;
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.LOG(l_module_name, 'p_action_code', p_action_code);
 END IF;

l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

IF l_debug_on IS NULL THEN
   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

g_dc_table.delete;

i := p_dlvy_table.first;

WHILE i IS NOT NULL LOOP

   check_scripts(
              p_delivery_id => p_dlvy_table(i).delivery_id,
              x_data_inconsistent => l_data_inconsistent);

   i := p_dlvy_table.next(i);

END LOOP;

Post_Process(p_action_code => p_action_code);

  IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN dcp_caught THEN
    if NOT l_debug_on OR l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    end if;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'dcp_caught exception');
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DCP_CAUGHT');
    END IF;
    RAISE data_inconsistency_exception;
  WHEN others THEN
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
   END IF;
END Check_Delivery;


Procedure Check_Detail(p_action_code IN VARCHAR2,
                      p_dtl_table IN wsh_glbl_var_strct_grp.Delivery_Details_Attr_Tbl_Type)
IS
l_debug_on BOOLEAN;
l_data_inconsistent VARCHAR2(1) := 'N';

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_DETAIL';
i NUMBER;
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.LOG(l_module_name, 'p_action_code', p_action_code);
 END IF;

g_dc_table.delete;

i := p_dtl_table.first;

WHILE i IS NOT NULL LOOP

   check_scripts(
              p_source_line_id => p_dtl_table(i).source_line_id,
              x_data_inconsistent => l_data_inconsistent);

   i := p_dtl_table.next(i);

END LOOP;

 Post_Process(p_action_code => p_action_code);

  IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN dcp_caught THEN
    if NOT l_debug_on OR l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    end if;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'dcp_caught exception');
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DCP_CAUGHT');
    END IF;
    RAISE data_inconsistency_exception;
  WHEN others THEN
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
   END IF;
END Check_Detail;

Procedure Check_Pick_Release(p_batch_id IN NUMBER) IS
l_debug_on BOOLEAN;
l_data_inconsistent VARCHAR2(1);
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_PICK_RELEASE';
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.LOG(l_module_name, 'p_BATCH_ID', p_batch_id);
 END IF;

 g_dc_table.delete;

 Check_Scripts(p_batch_id => p_batch_id,
               x_data_inconsistent => l_data_inconsistent);

  Post_Process(p_action_code => 'PICK-RELEASE');

  IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN dcp_caught THEN
    if NOT l_debug_on OR l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    end if;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'dcp_caught exception');
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DCP_CAUGHT');
    END IF;
    RAISE data_inconsistency_exception;
  WHEN others THEN
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
   END IF;
END Check_Pick_Release;


END WSH_DCP_PVT;

/
