--------------------------------------------------------
--  DDL for Package Body RCV_DCP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_DCP_PVT" AS
  /* $Header: INVRDCPB.pls 120.10.12010000.2 2010/01/25 19:57:56 vthevark ship $ */
  g_pkg_name CONSTANT VARCHAR2(50)    := 'RCV_DCP_PVT';
  g_userid            NUMBER;
  g_user_email        VARCHAR2(32767);
  g_user_name         VARCHAR2(32767);
  g_env               VARCHAR2(32767);
  g_debug_on          VARCHAR2(2)          := asn_debug.is_debug_on; -- Bug 9152790
  g_table_count       NUMBER :=1;

  FUNCTION get_email_server
    RETURN VARCHAR2 IS
    l_debug_on             BOOLEAN;
    l_module_name CONSTANT VARCHAR2(100) := g_pkg_name || '.' || 'GET_EMAIL_SERVER';
  BEGIN
    IF g_debug_on = 'Y' THEN
      l_debug_on  := TRUE;
    ELSE
      l_debug_on  := FALSE;
    END IF;

    IF l_debug_on THEN
      asn_debug.put_line('Entering ' || l_module_name);
    END IF;

    IF rcv_dcp_pvt.g_email_server IS NOT NULL THEN
      IF l_debug_on THEN
        asn_debug.put_line('Server name in cache:' || rcv_dcp_pvt.g_email_server);
      END IF;

      RETURN rcv_dcp_pvt.g_email_server;
    END IF;

    rcv_dcp_pvt.g_email_server  := fnd_profile.VALUE('RCV_DCP_EMAIL_SERVER');

    IF l_debug_on THEN
      asn_debug.put_line('Server name profile :' || rcv_dcp_pvt.g_email_server);
    END IF;

    RETURN rcv_dcp_pvt.g_email_server;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug_on THEN
        asn_debug.put_line('When others error has occurred. Oracle error message is ' || SQLERRM);
      END IF;

      RETURN NULL;
  END get_email_server;

  FUNCTION get_email_address
    RETURN VARCHAR2 IS
    l_debug_on             BOOLEAN;
    l_module_name CONSTANT VARCHAR2(100) := g_pkg_name || '.' || 'GET_EMAIL_ADDRESS';
  BEGIN
    IF g_debug_on = 'Y' THEN
      l_debug_on  := TRUE;
    ELSE
      l_debug_on  := FALSE;
    END IF;

    IF l_debug_on THEN
      asn_debug.put_line('Entering:' || l_module_name);
    END IF;

    IF rcv_dcp_pvt.g_email_address IS NOT NULL THEN
      IF l_debug_on THEN
        asn_debug.put_line('Email Address cache :' || rcv_dcp_pvt.g_email_address);
      END IF;

      RETURN rcv_dcp_pvt.g_email_address;
    END IF;

    rcv_dcp_pvt.g_email_address  := fnd_profile.VALUE('RCV_DCP_EMAIL_ADDRESSES');

    IF l_debug_on THEN
      asn_debug.put_line('Email Address profile :' || rcv_dcp_pvt.g_email_address);
    END IF;

    RETURN rcv_dcp_pvt.g_email_address;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug_on THEN
        asn_debug.put_line('When others error has occurred. Oracle error message is ' || SQLERRM);
      END IF;

      RETURN NULL;
  END get_email_address;

  PROCEDURE send_mail(
    sender     IN VARCHAR2
  , recipient1 IN VARCHAR2
  , recipient2 IN VARCHAR2
  , recipient3 IN VARCHAR2
  , recipient4 IN VARCHAR2
  , MESSAGE    IN VARCHAR2
  ) IS
    l_mailhost             VARCHAR2(32767);
    l_mail_conn            UTL_SMTP.connection;
    l_email_addrs          VARCHAR2(32767);
    l_spr                  VARCHAR2(30)        := ',';
    l_start_pos            NUMBER;
    l_end_pos              NUMBER;
    j                      NUMBER;
    l_recipient1           VARCHAR2(32767);
    l_recipient2           VARCHAR2(32767);
    l_recipient3           VARCHAR2(32767);
    l_recipient4           VARCHAR2(32767);
    l_recipient5           VARCHAR2(32767);
    l_sender               VARCHAR2(32767)     := 'Oracle-Logistics-Data-Integrity-Check@oraclelogistics';
    l_debug_on             BOOLEAN;
    l_module_name CONSTANT VARCHAR2(100)       := g_pkg_name || '.' || 'SEND_MAIL';

    CURSOR c_env IS
      SELECT NAME
        FROM v$database;
  BEGIN
    --
    IF g_debug_on = 'Y' THEN
      l_debug_on  := TRUE;
    ELSE
      l_debug_on  := FALSE;
    END IF;

    FOR c_env_rec IN c_env LOOP
      l_sender  := l_sender || '-' || c_env_rec.NAME;
    END LOOP;

    IF l_debug_on THEN
      asn_debug.put_line('Entering:' || l_module_name);
      asn_debug.put_line('sender: ' || sender);
      asn_debug.put_line('recipient1: ' || recipient1);
      asn_debug.put_line('recipient2: ' || recipient2);
      asn_debug.put_line('recipient3: ' || recipient3);
      asn_debug.put_line('recipient4: ' || recipient4);
    END IF;

    --Call function that will return the email server name
    l_mailhost     := get_email_server;
    --Call function that will return the email addresses
    l_email_addrs  := get_email_address;

    --Parse to get individual recipients
    IF l_debug_on THEN
      asn_debug.put_line('l_mailhost: ' || l_mailhost);
      asn_debug.put_line('l_email_addrs: ' || l_email_addrs);
    END IF;

    IF l_mailhost IS NOT NULL
       AND l_email_addrs IS NOT NULL THEN
      l_mail_conn   := UTL_SMTP.open_connection(l_mailhost, 25);
      j             := 1;
      l_start_pos   := 1;
      l_end_pos     := INSTRB(l_email_addrs, l_spr, 1, j);

      IF l_end_pos = 0 THEN
        l_end_pos  := LENGTHB(l_email_addrs) + 1;
      END IF;

      l_recipient1  := SUBSTRB(l_email_addrs, l_start_pos, l_end_pos - l_start_pos);
      j             := j + 1;
      l_start_pos   := l_end_pos + 1;
      l_end_pos     := INSTRB(l_email_addrs, l_spr, 1, j);

      IF l_end_pos = 0 THEN
        l_end_pos  := LENGTHB(l_email_addrs) + 1;
      END IF;

      l_recipient2  := SUBSTRB(l_email_addrs, l_start_pos, l_end_pos - l_start_pos);
      j             := j + 1;
      l_start_pos   := l_end_pos + 1;
      l_end_pos     := INSTRB(l_email_addrs, l_spr, 1, j);

      IF l_end_pos = 0 THEN
        l_end_pos  := LENGTHB(l_email_addrs) + 1;
      END IF;

      l_recipient3  := SUBSTRB(l_email_addrs, l_start_pos, l_end_pos - l_start_pos);
      j             := j + 1;
      l_start_pos   := l_end_pos + 1;
      l_end_pos     := INSTRB(l_email_addrs, l_spr, 1, j);

      IF l_end_pos = 0 THEN
        l_end_pos  := LENGTHB(l_email_addrs) + 1;
      END IF;

      l_recipient4  := SUBSTRB(l_email_addrs, l_start_pos, l_end_pos - l_start_pos);
      j             := j + 1;
      l_start_pos   := l_end_pos + 1;
      l_end_pos     := INSTRB(l_email_addrs, l_spr, 1, j);

      IF l_end_pos = 0 THEN
        l_end_pos  := LENGTHB(l_email_addrs) + 1;
      END IF;

      l_recipient5  := SUBSTRB(l_email_addrs, l_start_pos, l_end_pos - l_start_pos);

      IF l_debug_on THEN
        asn_debug.put_line('Now sender :' || l_sender);
        asn_debug.put_line('Now recipient1: ' || l_recipient1);
        asn_debug.put_line('Now recipient2: ' || l_recipient2);
        asn_debug.put_line('Now recipient3: ' || l_recipient3);
        asn_debug.put_line('Now recipient4: ' || l_recipient4);
        asn_debug.put_line('Now recipient5: ' || l_recipient5);
      END IF;

      UTL_SMTP.helo(l_mail_conn, l_mailhost);
      UTL_SMTP.mail(l_mail_conn, l_sender);

      IF l_recipient1 IS NOT NULL THEN
        UTL_SMTP.rcpt(l_mail_conn, l_recipient1);
      END IF;

      IF l_recipient2 IS NOT NULL THEN
        UTL_SMTP.rcpt(l_mail_conn, l_recipient2);
      END IF;

      IF l_recipient3 IS NOT NULL THEN
        UTL_SMTP.rcpt(l_mail_conn, l_recipient3);
      END IF;

      IF l_recipient4 IS NOT NULL THEN
        UTL_SMTP.rcpt(l_mail_conn, l_recipient4);
      END IF;

      IF l_recipient5 IS NOT NULL THEN
        UTL_SMTP.rcpt(l_mail_conn, l_recipient5);
      END IF;

      UTL_SMTP.DATA(l_mail_conn, MESSAGE);
      UTL_SMTP.quit(l_mail_conn);
    ELSE
      IF l_debug_on THEN
        asn_debug.put_line('Not sending mail. Server Name or Email id is null');
      END IF;
    END IF;

    IF l_debug_on THEN
      asn_debug.put_line('Exiting :' || l_module_name);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug_on THEN
        asn_debug.put_line('Unexpected error has occurred. Oracle error message is ' || SQLERRM);
        asn_debug.put_line('EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
  END send_mail;

  /*===========================================================================
  FUNCTION NAME:  is_dcp_enabled

  DESCRIPTION:    This function returns the DCP profile

  ===========================================================================*/
  FUNCTION is_dcp_enabled
    RETURN NUMBER IS
  BEGIN
    IF rcv_dcp_pvt.g_check_dcp IS NOT NULL THEN
      RETURN(rcv_dcp_pvt.g_check_dcp);
    END IF;

    rcv_dcp_pvt.g_check_dcp  := NVL(fnd_profile.VALUE('RCV_ENABLE_DCP'), 0);
    RETURN rcv_dcp_pvt.g_check_dcp;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END is_dcp_enabled;


  PROCEDURE switch_debug(p_action IN VARCHAR2, p_file_name OUT NOCOPY VARCHAR2) IS
    l_file_name         VARCHAR2(2000);
    l_dir_separator     VARCHAR2(1);
    l_debug_dir         VARCHAR2(32767);
    l_utl_file_locns    VARCHAR2(32767);
    L_NDX               VARCHAR2(1);
    l_idx 		NUMBER;
    l_list 		VARCHAR2(32767);
    l_comma_pos         NUMBER;

    CURSOR c_utl_file IS
      SELECT rtrim(ltrim(value)) from v$parameter
      WHERE lower(name) = 'utl_file_dir';

  BEGIN
    IF p_action = 'ON' THEN
      -- Turn debug on
      fnd_profile.put('INV_DEBUG_TRACE', '1');
      fnd_profile.put('INV_DEBUG_LEVEL', '11');

      -- Processing for INV Debug file
      OPEN c_utl_file;
      FETCH c_utl_file INTO l_utl_file_locns;
      CLOSE c_utl_file;
      l_dir_separator := '/';
      l_ndx := instr(l_utl_file_locns,l_dir_separator);
      IF (l_ndx = 0) then
       l_dir_separator := '\';
      END IF;
      -- Validate that Filename in profile is correct
      l_debug_dir := nvl(substr(g_inv_debug_file,1,instr(g_inv_debug_file,l_dir_separator,-1,1)-1),'-999');
      IF (l_utl_file_locns <> '*') THEN
        l_list := l_utl_file_locns;
        LOOP
	  l_idx := instr(l_list,',');

	  IF l_idx > 0 THEN
	    IF l_debug_dir = rtrim(ltrim(SUBSTR(l_list,1,l_idx -1))) THEN
	      IF g_inv_debug_enabled <> '1' THEN
	        -- Filename in profile is correct but debug is off, Lets generate a new filename
	        l_file_name := l_debug_dir||l_dir_separator||'RCV_DCP'||userenv('SESSIONID')||'.dbg';
	      ELSE
	        -- Filename in profile is correct, Lets use it
		l_file_name := g_inv_debug_file;
	      END IF;
	      EXIT;
	    END IF;
	    l_list := SUBSTR(l_list,l_idx + 1);
	  ELSE
	    IF l_debug_dir = rtrim(ltrim(l_list)) THEN
	      IF g_inv_debug_enabled <> '1' THEN
	        -- Filename in profile is correct but debug is off, Lets generate a new filename
	        l_file_name := l_debug_dir||l_dir_separator||'RCV_DCP'||userenv('SESSIONID')||'.dbg';
	      ELSE
	        -- Filename in profile is correct, Lets use it
		l_file_name := g_inv_debug_file;
	      END IF;
	    ELSE
	      -- Filename in the profile is incorrect, generating a new filename.
	      l_comma_pos := INSTRB(l_utl_file_locns, ',');
	      IF l_comma_pos <> 0 THEN
	        l_debug_dir := SUBSTRB(l_utl_file_locns, 1, l_comma_pos-1);
	      ELSE
	        l_debug_dir := l_utl_file_locns;
	      END IF;
	      l_dir_separator := '/';
	      l_ndx := instr(l_debug_dir,l_dir_separator);
	      IF l_ndx = 0 THEN
	        l_dir_separator := '\';
	      END IF;
	      l_file_name := l_debug_dir||l_dir_separator||'RCV_DCP'||userenv('SESSIONID')||'.dbg';
            END IF;
	    EXIT;
	  END IF;
	END LOOP;
      ELSE
       IF g_inv_debug_enabled <> '1' THEN
         l_file_name :=l_dir_separator||'tmp'||l_dir_separator||'RCV_DCP'||userenv('SESSIONID')||'.dbg';
       ELSE
         l_file_name :=g_inv_debug_file;
       END IF;
      END IF;

      fnd_profile.put('INV_DEBUG_FILE',l_file_name);
      p_file_name := l_file_name;
      g_debug_started  := 'Y';

    ELSIF p_action = 'OFF' THEN
      --Restore back the profiles
      fnd_profile.put('INV_DEBUG_TRACE', g_inv_debug_enabled);
      fnd_profile.put('INV_DEBUG_LEVEL', g_inv_debug_level);
      fnd_profile.put('INV_DEBUG_FILE', g_inv_debug_file);
      g_debug_started := 'N';
    END IF;
  END switch_debug;



  PROCEDURE post_process(p_action_code IN VARCHAR2, p_raise_exception IN VARCHAR2) IS
    l_call_stack           VARCHAR2(32767);
    l_message              VARCHAR2(32767);
    l_debug_file           VARCHAR2(32767);
    l_debug_dir            VARCHAR2(32767);
    l_debug_on             BOOLEAN;
    l_all_debug_on         BOOLEAN;
    l_module_name CONSTANT VARCHAR2(100)   := g_pkg_name || '.' || 'POST_PROCESS';
    k                      NUMBER;
    l_rollback_allowed     VARCHAR2(1);
    l_return_status        VARCHAR2(30);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(32767);
    l_conc_request_id      NUMBER;
    l_module               VARCHAR2(32767);
    l_level                NUMBER;
    l_comma_pos            NUMBER;
    l_curr_msg_count       NUMBER          := 0;
    l_recipient1           VARCHAR2(32767);
    l_recipient2           VARCHAR2(32767);
    l_recipient3           VARCHAR2(32767);
    l_temp_message         VARCHAR2(32767);
    l_ndx                  VARCHAR2(1);
    l_file_name 	   VARCHAR2(2000);

    crlf          CONSTANT VARCHAR2(2)     := fnd_global.local_CHR(13) || fnd_global.local_CHR(10);

    CURSOR c_user_info(p_user_id IN NUMBER) IS
      SELECT user_name
           , email_address
        FROM fnd_user
       WHERE user_id = p_user_id;

    CURSOR c_env IS
      SELECT NAME
        FROM v$database;
  BEGIN
    /***
     a) Check if debug is ON
     b) If rollback is allowed and debug is off then turn debug ON and Raise Exception
     c) If rollback is allowed and debug is ON then collect all information and Finally Send email. If debug was turned on by DCP then turn it off.
     d) If rollback is NOT allowed then collect information, put the information in a new debug file and Send email
    *****/

    --
    IF g_debug_on = 'Y' THEN
      l_debug_on  := TRUE;
    ELSE
      l_debug_on  := FALSE;
    END IF;

    IF g_debug_started <> 'Y' THEN
      fnd_profile.get('INV_DEBUG_TRACE', g_inv_debug_enabled);
      fnd_profile.get('INV_DEBUG_LEVEL', g_inv_debug_level);
      fnd_profile.get('INV_DEBUG_FILE', g_inv_debug_file);
    END IF;

    IF (g_inv_debug_enabled = '1') or (g_debug_started = 'Y') THEN -- Bug 9152790
      l_all_debug_on  := TRUE;
    ELSE
      l_all_debug_on  := FALSE;
    END IF;

    --
    IF l_debug_on THEN
      asn_debug.put_line('Entering :' || l_module_name);
      asn_debug.put_line('p_action_code' || p_action_code);
      asn_debug.put_line('p_raise_exception' || p_raise_exception);
    END IF;

    l_rollback_allowed  := NVL(p_raise_exception, 'Y');

    IF g_userid IS NULL THEN
      fnd_profile.get('USER_ID', g_userid);
      OPEN c_user_info(g_userid);
      FETCH c_user_info INTO g_user_name, g_user_email;
      CLOSE c_user_info;
    END IF;

    IF g_env IS NULL THEN
      OPEN c_env;
      FETCH c_env INTO g_env;
      CLOSE c_env;
    END IF;

    l_conc_request_id   := fnd_global.conc_request_id;

    IF (l_conc_request_id = 0) THEN
      l_conc_request_id  := NULL;
    END IF;

    IF l_debug_on THEN
      asn_debug.put_line('User Id' || g_userid);
      asn_debug.put_line('User Name' || g_user_name);
      asn_debug.put_line('Env' || g_env);
    END IF;

    IF (g_dc_table.COUNT > 0) THEN

      IF NOT l_all_debug_on THEN
        switch_debug(p_action => 'ON', p_file_name => g_file_name);
        l_debug_on       := TRUE;
        g_debug_on       := 'Y';

        asn_debug.put_line('DCP - Started Debugger');
        asn_debug.put_line('g_dc_table count :' || g_dc_table.COUNT);
        asn_debug.put_line('l_rollback_allowed :' || l_rollback_allowed);
        asn_debug.put_line('conc. request id :' || l_conc_request_id);

	IF (l_rollback_allowed = 'Y') THEN
		RAISE dcp_caught;
	END IF;
      ELSIF g_debug_started <> 'Y' THEN
      	g_file_name := g_inv_debug_file;
      END IF;
      --{
         --Get CallStack
      l_message  := 'Subject: RCV Data inconsistency detected for ' || g_user_name || ' in ' || g_env || crlf || ' ' || crlf;
      l_message  := l_message || 'Action Performed:' || p_action_code;

      IF NVL(l_conc_request_id, -1) <> -1 THEN
        l_message  :=
              l_message
           || '
  Data Inconsistency found in environment '
           || g_env
           || ' for concurrent request id '
           || l_conc_request_id
           || ' submitted by user '
           || g_user_name
	   || '. INV Debug file for this transaction = ' || g_file_name||'. '||crlf ||' ' || crlf
           || '.';
      ELSE
        l_message  :=
            l_message || crlf || ' ' || crlf || 'Data Inconsistency found in environment ' || g_env || ' for a transaction run by user ' || g_user_name || '. INV Debug file for this transaction = ' || g_file_name||'. '||crlf ||' ' || crlf;
      END IF;

      --
      -- dump the call stack and pl/sql table
      -- if global was set , turn debug off
      -- Put CallStack in debug file
      IF l_debug_on THEN
        l_call_stack  := DBMS_UTILITY.format_call_stack;
        asn_debug.put_line('**********Begining of Call Stack**********');
        asn_debug.put_line(l_call_stack);
        asn_debug.put_line('**********End of Call Stack**********');
      END IF;


      l_message  := l_message || '********** Here are the Details **********' ||   crlf;
      k          := g_dc_table.FIRST;

      WHILE k IS NOT NULL LOOP
        --***************************************************************--
          --{The g_dc_table contents need to be changed accordingly
        --***************************************************************--
        l_temp_message  :=
              k
           || '. Data Mismatch #'
           || g_dc_table(k).msg
           || '.(To Org:'
           || g_dc_table(k).to_organization_code
           || ', Item:'
           || g_dc_table(k).item_name
           || ', Header Interface id:'
           || g_dc_table(k).header_interface_id
           || ', Interface Transaction id:'
           || g_dc_table(k).interface_transaction_id
           || ', Shipment header id:'
           || g_dc_table(k).shipment_header_id
           || ', Shipment line id:'
           || g_dc_table(k).shipment_line_id
           || ',';
        l_temp_message  :=
              l_temp_message
           || ' Trx Type:'
           || g_dc_table(k).txn_type
           || ', RHI receipt header id: '
           || g_dc_table(k).rhi_receipt_header_id
	   || ', RHI processing status code: '
           || g_dc_table(k).rhi_processing_status_code
	   || ', RHI receipt source code: '
           || g_dc_table(k).rhi_receipt_source_code
	   || ', RHI asn type: '
           || g_dc_table(k).rhi_asn_type
	   || ', RHI creation date: '
           || g_dc_table(k).rhi_creation_date
	   || ', RSH asn type: '
           || g_dc_table(k).rsh_asn_type
           || ', RT transaction id:'
           || g_dc_table(k).rt_transaction_id
           || ', MMT transaction id:'
           || g_dc_table(k).mmt_transaction_id
           || ', OEL line id:'
           || g_dc_table(k).oel_line_id
	   || ', OEL Flow status Code:'
           || g_dc_table(k).oel_flow_status_code
           || ', MOH header id:'
           || g_dc_table(k).moh_header_id
           || ', MOL line id:'
           || g_dc_table(k).mol_line_id
           || ', MSN serial number:'
           || g_dc_table(k).msn_serial_number
	   || ', MSN current status:'
           || g_dc_table(k).msn_current_status
	   || ', MSN last update date:'
           || g_dc_table(k).msn_last_update_date
	   || ', WLPN LPN context:'
           || g_dc_table(k).wlpn_lpn_context
           || ', From org:'
           || g_dc_table(k).from_organization_code
           || ')';

        IF LENGTH(l_message) < 31900 THEN
          l_message  := l_message || '
	  ' || l_temp_message || '. ';
        END IF;

        IF l_debug_on THEN
          asn_debug.put_line(l_temp_message);
        END IF;

        k               := g_dc_table.NEXT(k);
      --}
      END LOOP;

      l_message  := l_message ||crlf|| '********** End of the Details **********';
      --Send Email
      send_mail(sender               => l_recipient1, recipient1 => l_recipient1, recipient2 => l_recipient2, recipient3 => l_recipient3
      , MESSAGE                      => l_message);
      g_dc_table.DELETE;
      g_table_count := 1;
         --}
      --}
    END IF;

    -- Stop the debugger if it was started earlier
    IF g_debug_started = 'Y' THEN
      switch_debug(p_action => 'OFF', p_file_name => l_file_name);
      IF l_debug_on THEN
        asn_debug.put_line('DCP - Stopped Debugger');
	g_debug_on := asn_debug.is_debug_on; -- Bug 9152790
      END IF;
    END IF;
  EXCEPTION
    WHEN dcp_caught THEN
      IF l_debug_on THEN
        asn_debug.put_line('DCP Caught: Post Process');
        asn_debug.put_line('Exception: dcp_caught');
      END IF;

      RAISE dcp_caught;
    WHEN OTHERS THEN
      IF l_debug_on THEN
        asn_debug.put_line('Unexpected error has occured. Oracle error message is ' || SQLERRM);
        asn_debug.put_line('EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
  END post_process;

  PROCEDURE check_scripts(p_action_code IN VARCHAR2, p_header_interface_id IN NUMBER, p_interface_transaction_id IN NUMBER) IS
    /*** Look for Data Mismatch and Add information to g_dc_table if found ***/
    CURSOR c1 IS
      SELECT 'RHI IN RUNNING WHEN THERE IS A ROW IN RSH'
           , rhi.receipt_header_id
           , rhi.ship_to_organization_id
           , rhi.from_organization_id
           , rhi.transaction_type
	   , rhi.processing_status_code
           , rhi.receipt_source_code
           , rhi.asn_type rhi_asn_type
           , rsh.asn_type rsh_asn_type
           , rhi.creation_date
        FROM rcv_headers_interface rhi, rcv_shipment_headers rsh
       WHERE rhi.header_interface_id = p_header_interface_id
         AND rsh.shipment_header_id = rhi.receipt_header_id
         AND rhi.processing_status_code IN('RUNNING', 'PENDING')
         AND rhi.receipt_source_code in ('VENDOR','CUSTOMER')
         AND nvl(rhi.asn_type, 'STD') = 'STD'
         AND nvl(rsh.asn_type, '&&&&') NOT IN ('ASN','ASBN') ;


    CURSOR c2 IS
      SELECT 'Shipment line exists without a shipment header'
           , rsl.shipment_line_id
           , rti.item_id
           , rti.to_organization_id
           , rti.from_organization_id
           , rti.transaction_type
        FROM rcv_shipment_lines rsl, rcv_transactions_interface rti
       WHERE rti.interface_transaction_id = p_interface_transaction_id
         AND rti.shipment_line_id = rsl.shipment_line_id
         AND NOT EXISTS(SELECT 1
                          FROM rcv_shipment_headers rsh
                         WHERE rsh.shipment_header_id = rsl.shipment_header_id);

--As per Maneesh's suggestion, commenting this check from DCP
/*    CURSOR c3 IS
      SELECT 'Shipment exists for Int Shp. or Internal Order without MMT'
           , rsh.shipment_header_id
           , rsl.shipment_line_id
           , rsl.mmt_transaction_id
           , rti.item_id
           , rti.to_organization_id
           , rti.from_organization_id
           , rti.transaction_type
        FROM rcv_shipment_headers rsh, rcv_shipment_lines rsl, rcv_transactions_interface rti
       WHERE rti.interface_transaction_id = p_interface_transaction_id
         AND rti.shipment_line_id = rsl.shipment_line_id
         AND rsh.shipment_header_id = rsl.shipment_header_id
         AND rsh.receipt_source_code IN('INTERNAL ORDER', 'INVENTORY')
         AND rsl.mmt_transaction_id IS NOT NULL
         AND NOT EXISTS(SELECT 1
                          FROM mtl_material_transactions mmt
                         WHERE rsl.mmt_transaction_id = mmt.transaction_id);*/

    CURSOR c4 IS
      SELECT 'Flow status code is not awaiting return disposition for RMA receipt'
           , rt.transaction_id
           , oel.line_id
           , rti.item_id
           , rti.to_organization_id
           , rti.from_organization_id
           , rti.transaction_type
	   , oel.flow_status_code
        FROM oe_order_lines_all oel, rcv_transactions rt, rcv_transactions_interface rti
       WHERE rti.interface_transaction_id = p_interface_transaction_id
         AND rti.interface_transaction_id = rt.interface_transaction_id
         AND oel.line_id = rt.oe_order_line_id
         AND rti.receipt_source_code = 'CUSTOMER'
         AND rt.transaction_type = 'RECEIVE'
         AND nvl(rti.auto_transact_code, 'RECEIVE') = 'RECEIVE'
         AND oel.flow_status_code = 'AWAITING_RETURN';



    CURSOR c5 IS
      SELECT 'Flow status code is not returned for RMA delivery'
           , rt.transaction_id
           , oel.line_id
           , rti.item_id
           , rti.to_organization_id
           , rti.from_organization_id
           , rti.transaction_type
	   , oel.flow_status_code
        FROM oe_order_lines_all oel, rcv_transactions rt, rcv_transactions_interface rti
       WHERE rti.interface_transaction_id = p_interface_transaction_id
         AND rti.interface_transaction_id = rt.interface_transaction_id
         AND oel.line_id = rt.oe_order_line_id
AND rti.receipt_source_code = 'CUSTOMER'
         AND rt.transaction_type = 'DELIVER'
         AND oel.flow_status_code IN ('AWAITING_RETURN', 'AWAITING_RETURN_DISPOSITION')
	 AND oel.shipped_quantity = oel.fulfilled_quantity;

    CURSOR c6 IS
      SELECT 'MSN group mark id not null'
           , msn.serial_number
           , msn.inventory_item_id
           , msn.current_organization_id
           , rti.transaction_type
           , msn.last_update_date
           , msn.current_status
           , wlpn.lpn_context
      FROM mtl_serial_numbers msn,
            rcv_transactions_interface rti,
            mtl_serial_numbers_temp msnt,
            wms_license_plate_numbers wlpn
      WHERE rti.interface_transaction_id = p_interface_transaction_id
        AND msnt.product_code = 'RCV'
	AND msnt.product_transaction_id = rti.interface_transaction_id
	AND msn.serial_number between msnt.fm_serial_number and msnt.to_serial_number
	AND msn.inventory_item_id = rti.item_id
	AND msn.current_organization_id = rti.to_organization_id
	AND nvl(msn.lpn_id, -1) = wlpn.lpn_id (+)
	AND (wlpn.lpn_context is null or wlpn.lpn_context in (1,3))
	AND NVL(msn.group_mark_id ,-1) <> -1
      UNION ALL
      SELECT 'MSN group mark id not null'
           , msn.serial_number
           , msn.inventory_item_id
           , msn.current_organization_id
           , rt.transaction_type
           , msn.last_update_date
           , msn.current_status
           , wlpn.lpn_context
      FROM mtl_serial_numbers msn,
            rcv_transactions rt,
            mtl_unit_transactions mut,
            wms_license_plate_numbers wlpn
      WHERE rt.interface_transaction_id = p_interface_transaction_id
        AND mut.product_code ='RCV'
	AND mut.product_transaction_id = rt.transaction_id
	AND msn.serial_number = mut.serial_number
	AND msn.inventory_item_id = mut.inventory_item_id
	AND msn.current_organization_id = mut.organization_id
	AND nvl(msn.lpn_id, -1) = wlpn.lpn_id (+)
	AND (wlpn.lpn_context is null or wlpn.lpn_context in (1,3))
	AND NVL(msn.group_mark_id ,-1) <> -1
	AND not exists
          (select 1 from rcv_transactions rt1
          where rt1.parent_transaction_id = rt.transaction_id);

   CURSOR c7 IS
      SELECT 'MOL exists with invalid wms_process_flag'
           , mol.line_id
           , moh.header_id
           , mol.inventory_item_id
           , rt.organization_id
           , rt.transaction_type
        FROM mtl_txn_request_lines mol, mtl_txn_request_headers moh, rcv_transactions rt
       WHERE rt.interface_transaction_id = p_interface_transaction_id
         AND rt.transaction_type = 'RECEIVE'
         AND (mol.lpn_id = rt.transfer_lpn_id
              OR mol.lpn_id = rt.lpn_id)
         AND mol.line_status <> 5
         AND mol.header_id = moh.header_id
         AND moh.move_order_type = 6
         AND mol.wms_process_flag = 2;

    CURSOR c_org(p_org_id IN NUMBER) IS
      SELECT organization_code
        FROM org_organization_definitions
       WHERE organization_id = p_org_id;

    CURSOR c_item(p_org_id IN NUMBER, p_item_id IN NUMBER) IS
      SELECT concatenated_segments
        FROM mtl_system_items_kfv
       WHERE inventory_item_id = p_item_id
         AND organization_id = p_org_id;

    l_debug_on             BOOLEAN;
    l_module_name CONSTANT VARCHAR2(100)  := g_pkg_name || '.' || 'CHECK_SCRIPTS';
    l_profile              VARCHAR2(2000);
    i                      NUMBER;
  BEGIN
    IF g_debug_on = 'Y' THEN
      l_debug_on  := TRUE;
    ELSE
      l_debug_on  := FALSE;
    END IF;
    i := g_table_count;

    IF (p_action_code = 'PREPROCESSOR') THEN ---{
      FOR c1_rec IN c1 LOOP
        g_dc_table(i).header_interface_id       := p_header_interface_id;
        g_dc_table(i).interface_transaction_id  := p_interface_transaction_id;
        g_dc_table(i).msg                       := 'C1=>RHI IN RUNNING WHEN THERE IS A ROW IN RSH';
        g_dc_table(i).rhi_receipt_header_id     := c1_rec.receipt_header_id;
        g_dc_table(i).txn_type                  := c1_rec.transaction_type;
	g_dc_table(i).rhi_processing_status_code:= c1_rec.processing_status_code;
	g_dc_table(i).rhi_receipt_source_code 	:= c1_rec.receipt_source_code ;
	g_dc_table(i).rhi_asn_type 		:= c1_rec.rhi_asn_type;
	g_dc_table(i).rsh_asn_type              := c1_rec.rsh_asn_type;
	g_dc_table(i).rhi_creation_date 		:= c1_rec.creation_date;

        IF (c1_rec.ship_to_organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c1_rec.ship_to_organization_id) LOOP
            g_dc_table(i).to_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;

        IF (c1_rec.from_organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c1_rec.from_organization_id) LOOP
            g_dc_table(i).from_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;

        i                                       := i + 1;
      END LOOP;
    ELSIF(p_action_code = 'Verify RTI') THEN ---{
      FOR c2_rec IN c2 LOOP
        g_dc_table(i).header_interface_id       := p_header_interface_id;
        g_dc_table(i).interface_transaction_id  := p_interface_transaction_id;
        g_dc_table(i).msg                       := 'C2=>Shipment line exists without a shipment header';
        g_dc_table(i).shipment_line_id          := c2_rec.shipment_line_id;
        g_dc_table(i).txn_type                  := c2_rec.transaction_type;

        IF (c2_rec.to_organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c2_rec.to_organization_id) LOOP
            g_dc_table(i).to_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;

        IF (c2_rec.from_organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c2_rec.from_organization_id) LOOP
            g_dc_table(i).from_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;

        IF (c2_rec.to_organization_id IS NOT NULL
            AND c2_rec.item_id IS NOT NULL) THEN
          FOR c_item_rec IN c_item(c2_rec.to_organization_id, c2_rec.item_id) LOOP
            g_dc_table(i).item_name  := c_item_rec.concatenated_segments;
          END LOOP;
        END IF;

        i                                       := i + 1;
      END LOOP;
--As per Maneesh's suggestion, commenting this check from DCP
/*      FOR c3_rec IN c3 LOOP
        g_dc_table(i).header_interface_id       := p_header_interface_id;
        g_dc_table(i).interface_transaction_id  := p_interface_transaction_id;
        g_dc_table(i).msg                       := 'C3=>Shipment exists for Int Shp. or Internal Order without MMT';
        g_dc_table(i).shipment_header_id        := c3_rec.shipment_header_id;
        g_dc_table(i).shipment_line_id          := c3_rec.shipment_line_id;
        g_dc_table(i).mmt_transaction_id        := c3_rec.mmt_transaction_id;
        g_dc_table(i).txn_type                  := c3_rec.transaction_type;

        IF (c3_rec.to_organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c3_rec.to_organization_id) LOOP
            g_dc_table(i).to_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;

        IF (c3_rec.from_organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c3_rec.from_organization_id) LOOP
            g_dc_table(i).from_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;

        IF (c3_rec.to_organization_id IS NOT NULL
            AND c3_rec.item_id IS NOT NULL) THEN
          FOR c_item_rec IN c_item(c3_rec.to_organization_id, c3_rec.item_id) LOOP
            g_dc_table(i).item_name  := c_item_rec.concatenated_segments;
          END LOOP;
        END IF;

        i                                       := i + 1;
      END LOOP;*/

      FOR c4_rec IN c4 LOOP
        g_dc_table(i).header_interface_id       := p_header_interface_id;
        g_dc_table(i).interface_transaction_id  := p_interface_transaction_id;
        g_dc_table(i).msg                       := 'C4=>Flow status code is not awaiting return disposition for RMA receipt';
        g_dc_table(i).rt_transaction_id         := c4_rec.transaction_id;
        g_dc_table(i).oel_line_id               := c4_rec.line_id;
        g_dc_table(i).txn_type                  := c4_rec.transaction_type;
	g_dc_table(i).oel_flow_status_code 	:= c4_rec.flow_status_code;

        IF (c4_rec.to_organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c4_rec.to_organization_id) LOOP
            g_dc_table(i).to_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;

        IF (c4_rec.from_organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c4_rec.from_organization_id) LOOP
            g_dc_table(i).from_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;

        IF (c4_rec.to_organization_id IS NOT NULL
            AND c4_rec.item_id IS NOT NULL) THEN
          FOR c_item_rec IN c_item(c4_rec.to_organization_id, c4_rec.item_id) LOOP
            g_dc_table(i).item_name  := c_item_rec.concatenated_segments;
          END LOOP;
        END IF;

        i                                       := i + 1;
      END LOOP;

      FOR c5_rec IN c5 LOOP
        g_dc_table(i).header_interface_id       := p_header_interface_id;
        g_dc_table(i).interface_transaction_id  := p_interface_transaction_id;
        g_dc_table(i).msg                       := 'C5=>Flow status code is not returned for RMA delivery';
        g_dc_table(i).rt_transaction_id         := c5_rec.transaction_id;
        g_dc_table(i).oel_line_id               := c5_rec.line_id;
        g_dc_table(i).txn_type                  := c5_rec.transaction_type;
	g_dc_table(i).oel_flow_status_code      := c5_rec.flow_status_code;

        IF (c5_rec.to_organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c5_rec.to_organization_id) LOOP
            g_dc_table(i).to_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;

        IF (c5_rec.from_organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c5_rec.from_organization_id) LOOP
            g_dc_table(i).from_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;

        IF (c5_rec.to_organization_id IS NOT NULL
            AND c5_rec.item_id IS NOT NULL) THEN
          FOR c_item_rec IN c_item(c5_rec.to_organization_id, c5_rec.item_id) LOOP
            g_dc_table(i).item_name  := c_item_rec.concatenated_segments;
          END LOOP;
        END IF;

        i                                       := i + 1;
      END LOOP;
    ELSIF(p_action_code = 'Post WMS') THEN
      FOR c6_rec IN c6 LOOP
        g_dc_table(i).header_interface_id       := p_header_interface_id;
        g_dc_table(i).interface_transaction_id  := p_interface_transaction_id;
        g_dc_table(i).msg                       := 'C6=>MSN group mark id not null';
        g_dc_table(i).msn_serial_number         := c6_rec.serial_number;
        g_dc_table(i).txn_type                  := c6_rec.transaction_type;
	g_dc_table(i).msn_last_update_date 	:= c6_rec.last_update_date;
	g_dc_table(i).msn_current_status 	:= c6_rec.current_status;
	g_dc_table(i).wlpn_lpn_context 		:= c6_rec.lpn_context;

        IF (c6_rec.current_organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c6_rec.current_organization_id) LOOP
            g_dc_table(i).to_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;

/*        IF (c6_rec.from_organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c6_rec.from_organization_id) LOOP
            g_dc_table(i).from_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;*/

        IF (c6_rec.current_organization_id IS NOT NULL
            AND c6_rec.inventory_item_id IS NOT NULL) THEN
          FOR c_item_rec IN c_item(c6_rec.current_organization_id, c6_rec.inventory_item_id) LOOP
            g_dc_table(i).item_name  := c_item_rec.concatenated_segments;
          END LOOP;
        END IF;

        i                                       := i + 1;
      END LOOP;

      FOR c7_rec IN c7 LOOP
        g_dc_table(i).header_interface_id       := p_header_interface_id;
        g_dc_table(i).interface_transaction_id  := p_interface_transaction_id;
        g_dc_table(i).msg                       := 'C7=>MOL exists with invalid wms_process_flag';
        g_dc_table(i).moh_header_id             := c7_rec.header_id;
        g_dc_table(i).mol_line_id               := c7_rec.line_id;
        g_dc_table(i).txn_type                  := c7_rec.transaction_type;

        IF (c7_rec.organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c7_rec.organization_id) LOOP
            g_dc_table(i).to_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;

/*        IF (c7_rec.from_organization_id IS NOT NULL) THEN
          FOR c_org_rec IN c_org(c7_rec.from_organization_id) LOOP
            g_dc_table(i).from_organization_code  := c_org_rec.organization_code;
          END LOOP;
        END IF;*/

        IF (c7_rec.organization_id IS NOT NULL
            AND c7_rec.inventory_item_id IS NOT NULL) THEN
          FOR c_item_rec IN c_item(c7_rec.organization_id, c7_rec.inventory_item_id) LOOP
            g_dc_table(i).item_name  := c_item_rec.concatenated_segments;
          END LOOP;
        END IF;

        i                                       := i + 1;
      END LOOP;
    END IF; ---}

    g_table_count := i;
    IF (i > 1) THEN
      IF l_debug_on THEN
        asn_debug.put_line('Data is inconsistent');
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug_on THEN
        asn_debug.put_line('Unexpected error has occurred. Oracle error message is ' || SUBSTR(SQLERRM, 1, 180));
        asn_debug.put_line('EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
  END check_scripts;

  PROCEDURE validate_data(
    p_dcp_event                IN            VARCHAR2
--  , p_header_interface_id      IN            NUMBER DEFAULT NULL
  , p_request_id               IN            NUMBER DEFAULT NULL
  , p_group_id                 IN            NUMBER DEFAULT NULL
  , p_interface_transaction_id IN            NUMBER DEFAULT NULL
  , p_lpn_group_id             IN            NUMBER DEFAULT NULL
  , p_raise_exception          IN            VARCHAR2
  , x_return_status            OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_on             BOOLEAN;
    l_module_name CONSTANT VARCHAR2(100) := g_pkg_name || '.' || 'Validate_data';
    i                      NUMBER;
    l_header_id            NUMBER        := 0;
    CURSOR headers_cur_dcp(x_request_id NUMBER, x_group_id NUMBER) IS
         SELECT *
	 FROM rcv_headers_interface
	 WHERE NVL(asn_type, 'STD') IN('ASN', 'ASBN', 'STD', 'WC')
	 	AND processing_status_code IN('RUNNING', 'SUCCESS','ERROR','PENDING')
		AND(NVL(validation_flag, 'N') = 'Y'
		    OR processing_status_code = 'SUCCESS') -- include success row for multi-line asn
		AND(processing_request_id IS NULL
		    OR processing_request_id = x_request_id)
                AND GROUP_ID = DECODE(x_group_id, 0, GROUP_ID, x_group_id);

     CURSOR dcp_cursor1(x_lpn_group_id NUMBER) IS
        SELECT distinct interface_transaction_id
	    FROM rcv_transactions
	    WHERE lpn_group_id = x_lpn_group_id;

     CURSOR dcp_cursor2(x_group_id NUMBER) IS
        SELECT distinct interface_transaction_id
                FROM rcv_transactions
                WHERE group_id = x_group_id
                AND lpn_group_id is null;

  BEGIN
    IF g_debug_on = 'Y' THEN
      l_debug_on  := TRUE;
    ELSE
      l_debug_on  := FALSE;
    END IF;

    IF l_debug_on THEN
      asn_debug.put_line('p_request_id= ' || p_request_id);
      asn_debug.put_line('p_group_id= ' || p_group_id);
      asn_debug.put_line('p_lpn_group_id= ' || p_lpn_group_id);
      asn_debug.put_line('p_interface_transaction_id=' || p_interface_transaction_id);
      asn_debug.put_line('p_raise_exception' || p_raise_exception);
    END IF;
    IF p_dcp_event = 'PREPROCESSOR' THEN
    	FOR header_cur_rec IN headers_cur_dcp(p_request_id, p_group_id) LOOP
	    	check_scripts(p_action_code => p_dcp_event, p_header_interface_id => header_cur_rec.header_interface_id, p_interface_transaction_id => p_interface_transaction_id);
	END LOOP;
    ELSIF p_dcp_event = 'Post WMS' THEN
    	IF (p_lpn_group_id is not null) THEN
		FOR dcp_cursor1_rec IN dcp_cursor1(p_lpn_group_id) LOOP
			check_scripts(p_action_code => p_dcp_event, p_header_interface_id => NULL, p_interface_transaction_id => dcp_cursor1_rec.interface_transaction_id);
		END LOOP;
	ELSIF (p_group_id is not null) THEN
		FOR dcp_cursor2_rec IN dcp_cursor2(p_group_id) LOOP
                        check_scripts(p_action_code => p_dcp_event, p_header_interface_id => NULL, p_interface_transaction_id => dcp_cursor2_rec.interface_transaction_id);
                END LOOP;
	END IF;
    ELSE
        check_scripts(p_action_code => p_dcp_event, p_header_interface_id => NULL, p_interface_transaction_id => p_interface_transaction_id);
    END IF;
    post_process(p_action_code => p_dcp_event, p_raise_exception => p_raise_exception);
    x_return_status  := 'S';
  EXCEPTION
    WHEN dcp_caught THEN
      IF l_debug_on THEN
        asn_debug.put_line('dcp_caught exception: Validate_data');
        asn_debug.put_line('EXCEPTION:DCP_CAUGHT: Validate_data');
      END IF;

      x_return_status  := 'S';
      RAISE data_inconsistency_exception;
    WHEN OTHERS THEN
      IF l_debug_on THEN
        asn_debug.put_line('Unexpected error has occurred. Oracle error message is ' || SUBSTR(SQLERRM, 1, 180));
        asn_debug.put_line('EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
        x_return_status  := 'E';
      END IF;
  END validate_data;
END rcv_dcp_pvt;

/
