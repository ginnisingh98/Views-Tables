--------------------------------------------------------
--  DDL for Package Body PON_REMINDER_NOTIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_REMINDER_NOTIFICATION_PKG" AS
--$Header: PONSREMB.pls 120.1.12010000.1 2009/06/23 08:58:10 appldev noship $

g_module_prefix         CONSTANT VARCHAR2(50) := 'reminder_notification';
PON_SEND_NOTIF CONSTANT VARCHAR2(10) := 'PON_NOT';

g_fnd_debug 		CONSTANT VARCHAR2(1)   := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_module 		CONSTANT VARCHAR2(50) := 'pon.plsql.pon_reminder_notification_pkg';
g_debug_enabled  VARCHAR2(1) := 'N';

g_before_close_date CONSTANT VARCHAR2(80) := 'BEFORE_CLOSE_DATE';
g_after_open_date CONSTANT VARCHAR2(80) := 'AFTER_OPEN_DATE';
g_after_preview_date CONSTANT VARCHAR2(80) := 'AFTER_PREVIEW_DATE';


--TYPE t_number_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


PROCEDURE send_notification_wrapper(
  ErrCode number,
  ErrMesg Varchar2,
  p_send_when IN VARCHAR2,
  p_days_values IN VARCHAR2
) IS



p_trimmed_days_values VARCHAR2(255);

days_values_table t_number_table_type ;

count_elements NUMBER;
pointer NUMBER;
comma_position NUMBER;
temp_day_value VARCHAR2(10);

temp_num NUMBER;

l_purge_done BOOLEAN;

l_api_name			VARCHAR2(100)	:= ' send_notification_wrapper ';
l_progress			NUMBER		:= 0;
x_progress FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN
  IF(g_fnd_debug = 'Y') then

	  if (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) then
		  g_debug_enabled := 'Y';
	  end if;

  END IF;

  IF(g_debug_enabled = 'Y') then
	  x_progress := ++l_progress || l_api_name || ' : BEGIN :';
	  log_message(x_progress);
	  x_progress := ++l_progress || l_api_name || ' : IN PARAMETERS : '
                                             || 'p_send_when : ' || p_send_when
                                             || 'p_days_values' || p_days_values;
	  log_message(x_progress);
  END IF;


  IF(g_debug_enabled = 'Y') then
	   x_progress := ++l_progress || l_api_name || ' : calling purge procedure for purging unused notifications.';
	   log_message(x_progress);
	END IF;


-------------------
-- purge logic for the unused workflows
purge_notif_wf(TRUE, l_purge_done);

---------------------

IF(g_debug_enabled = 'Y') then
	   x_progress := ++l_progress || l_api_name || ' : begin analysing of comma separated values passed from the conc program';
	   log_message(x_progress);
END IF;

p_trimmed_days_values := Trim(p_days_values);
count_elements := 0;
pointer := 1;

IF(g_debug_enabled = 'Y') then
	   x_progress := ++l_progress || l_api_name || ' : values added in the table of numbers';
	   log_message(x_progress);
END IF;



WHILE(Length(p_trimmed_days_values) > 0)
LOOP
comma_position := InStr(p_trimmed_days_values, ',', 1, 1);

IF (comma_position = 0)
THEN
comma_position := Length(p_trimmed_days_values) + 1;
END IF;

temp_day_value := Trim(SubStr(p_trimmed_days_values, 1, comma_position - 1 ));
p_trimmed_days_values := SubStr(p_trimmed_days_values, comma_position  + 1 );

IF(temp_day_value IS NOT NULL)THEN
BEGIN
days_values_table(count_elements + 1) := To_Number(temp_day_value);
IF(g_debug_enabled = 'Y') then
	   x_progress := ++l_progress || l_api_name
                                || 'value no. ' || count_elements + 1
                                || ' : ' || days_values_table(count_elements + 1);
	   log_message(x_progress);
END IF;
EXCEPTION WHEN OTHERS THEN
NULL;
END;

temp_num := days_values_table(count_elements + 1);
count_elements := count_elements + 1;



END IF;

END LOOP;
IF(g_debug_enabled = 'Y') then
	   x_progress := ++l_progress || l_api_name || ' : CSV converted to table of numbers';
	   log_message(x_progress);
END IF;
--now  days_values_table has the required values of number of days

IF(g_debug_enabled = 'Y') then
	   x_progress := ++l_progress || l_api_name || ' : calling send_notification procedure with the table of numbers';
	   log_message(x_progress);
END IF;
send_notification(To_Char(p_send_when), days_values_table);

IF(g_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : END :';
	log_message(x_progress);
END IF;

EXCEPTION WHEN OTHERS THEN
IF(g_debug_enabled = 'Y') then
	x_progress := l_api_name|| 'Exception Found. Error Code : ' || ErrCode || ' Error Name : ' || ErrMesg;
  log_message(x_progress);
END IF;


END send_notification_wrapper;

--*************************************************************************************

PROCEDURE send_notification(
 p_send_when IN VARCHAR2,
 p_days_values_number_table t_number_table_type
) IS

l_check_exists NUMBER;
l_diff_days NUMBER;
found_flag BOOLEAN;

l_temp_sys_date pon_auction_headers_all.close_bidding_date%TYPE;

CURSOR active_neg_cursor IS
      SELECT pah.auction_header_id auction_header_id,
             pah.close_bidding_date close_bidding_date,
             pah.open_bidding_date open_bidding_date,
             pah.view_by_date preview_date
      FROM pon_auction_headers_all pah
      WHERE pah.auction_status = 'ACTIVE'
      AND pah.close_bidding_date > SYSDATE
      AND SYSDATE > pah.open_bidding_date;

c_neg_details active_neg_cursor%ROWTYPE;

l_api_name			VARCHAR2(100)	:= ' send_notification ';
l_progress			NUMBER		:= 0;
x_progress FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN
   IF(g_debug_enabled = 'Y') then
	  x_progress := ++l_progress || l_api_name || ' : BEGIN :';
	  log_message(x_progress);
	  x_progress := ++l_progress || l_api_name || ' : IN PARAMETERS : '
                                             || 'p_send_when : ' || p_send_when
                                             || 'p_days_values_number_table : table of numbers';
	  log_message(x_progress);
  END IF;


      OPEN  active_neg_cursor;
      LOOP

		    fetch active_neg_cursor into c_neg_details;
		    EXIT when active_neg_cursor%NOTFOUND;

        l_temp_sys_date := SYSDATE;


        IF p_send_when = g_before_close_date
        THEN
          SELECT Floor(c_neg_details.close_bidding_date - l_temp_sys_date) INTO l_diff_days
          FROM dual;
        ELSIF p_send_when = g_after_open_date
        THEN
          SELECT Floor(l_temp_sys_date - c_neg_details.open_bidding_date) INTO l_diff_days
          FROM dual;
        ELSIF p_send_when = g_after_preview_date
        THEN
          SELECT Floor(l_temp_sys_date - c_neg_details.preview_date) INTO l_diff_days
          FROM dual;
        END IF;

     IF(g_debug_enabled = 'Y') then
	      x_progress := ++l_progress || l_api_name || ' : difference of days calculated, l_diff_days =  ' || l_diff_days;
	      log_message(x_progress);
     END IF;

        BEGIN
          found_flag :=  FALSE;
          FOR i IN p_days_values_number_table.first .. p_days_values_number_table.last
          LOOP
          IF (p_days_values_number_table(i) = l_diff_days)
            THEN
              BEGIN
                found_flag := TRUE;
                EXIT;
              END;
          END IF;

          END LOOP;

          IF found_flag = TRUE
          THEN
            BEGIN

            IF(g_debug_enabled = 'Y') then
	             x_progress := ++l_progress || l_api_name || ' : calling call_wf_process_to_send_notif for auction_id : ' || c_neg_details.auction_header_id ;
	            log_message(x_progress);
            END IF;
            BEGIN
            call_wf_process_to_send_notif(c_neg_details.auction_header_id);

            --update pon_auction_headers_all
            --increment the value of the no-of-notification-sent column
	           UPDATE pon_auction_headers_all pah
	           SET  pah.no_of_notifications_sent = Nvl(pah.no_of_notifications_sent, 0) + 1
	           WHERE auction_header_id = c_neg_details.auction_header_id;

             EXCEPTION WHEN OTHERS THEN
             IF(g_debug_enabled = 'Y') then
	              x_progress := ++l_progress || l_api_name || ' : exception found in the subsequent procedure calls :';
	              log_message(x_progress);
             END IF;

             END;

            END;
          END IF;

        END;
        -- code

      END LOOP;

IF(g_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : END :';
	log_message(x_progress);
END IF;

END send_notification;
--*************************************************************************************


PROCEDURE call_wf_process_to_send_notif(
p_auction_header_id IN NUMBER
)
IS

TYPE l_TP_contact_id_table_type IS TABLE OF pon_bidding_parties.trading_partner_contact_id%TYPE;
TYPE l_TP_contact_name_table_type IS TABLE OF pon_bidding_parties.trading_partner_contact_name%TYPE;
TYPE l_TP_name_table_type IS TABLE OF pon_bidding_parties.trading_partner_name%TYPE;
TYPE l_vendor_site_code_table_type IS TABLE OF pon_bidding_parties.vendor_site_code%TYPE;
TYPE l_vendor_site_id_table_type IS TABLE OF pon_bidding_parties.vendor_site_id%TYPE;
TYPE l_add_con_email_table_type IS TABLE OF pon_bidding_parties.additional_contact_email%TYPE;
TYPE l_TP_id_table_type IS TABLE OF pon_bidding_parties.trading_partner_id%TYPE;

l_TP_contact_id_table l_TP_contact_id_table_type := l_TP_contact_id_table_type(NULL);
l_TP_contact_name_table l_TP_contact_name_table_type := l_TP_contact_name_table_type(NULL);
l_TP_name_table l_TP_name_table_type := l_TP_name_table_type(NULL);
l_vendor_site_code_table l_vendor_site_code_table_type := l_vendor_site_code_table_type(NULL);
l_vendor_site_id_table  l_vendor_site_id_table_type :=  l_vendor_site_id_table_type(NULL);
l_add_con_email_table l_add_con_email_table_type := l_add_con_email_table_type(NULL);
l_TP_id_table l_TP_id_table_type := l_TP_id_table_type(NULL);

p_wf_item_key VARCHAR2(240);

l_api_name			VARCHAR2(100)	:= ' call_wf_process_to_send_notif ';
l_progress			NUMBER		:= 0;
x_progress FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

---------------   vars reqd to call wflow

p_trading_partner_contact_name VARCHAR2(80);
p_trading_partner_name VARCHAR2(80);
p_auction_title VARCHAR2(80);
p_reminder_date DATE;
p_neg_preview_date DATE;
p_neg_open_date DATE;
p_neg_close_date DATE;
p_supplier_name VARCHAR2(255);
p_supplier_id NUMBER;
p_supplier_contact_name VARCHAR2(225);
p_supplier_role_name VARCHAR2(80);
p_supplier_site VARCHAR2(80);
p_item_key VARCHAR2(350);
p_notification_no NUMBER;
p_supplier_site_id NUMBER;
p_person_id NUMBER(10);
p_name VARCHAR2(244);

p_add_con_email VARCHAR(240);
p_add_con_role_name VARCHAR2(240);
p_supplier_contact_id NUMBER;
p_document_number VARCHAR2(240);

------------------

BEGIN

IF(g_debug_enabled = 'Y') then
	  x_progress := ++l_progress || l_api_name || ' : BEGIN :';
	  log_message(x_progress);
	  x_progress := ++l_progress || l_api_name || ' : IN PARAMETERS:'
                                             || 'auction header id : ' || p_auction_header_id  ;
	  log_message(x_progress);
END IF;

SELECT pbp.trading_partner_contact_id,
pbp.trading_partner_contact_name,
pbp.vendor_site_code,
pbp.trading_partner_name,
pbp.trading_partner_id,
pbp.vendor_site_id,
pbp.additional_contact_email

BULK COLLECT INTO l_TP_contact_id_table,
l_TP_contact_name_table,
l_vendor_site_code_table,
l_TP_name_table,
l_TP_id_table,
l_vendor_site_id_table,
l_add_con_email_table

FROM pon_bidding_parties pbp

WHERE
pbp.auction_header_id = p_auction_header_id
AND  pbp.trading_partner_contact_id NOT IN
  (SELECT  pbh.trading_partner_contact_id
  FROM pon_bid_headers pbh
  WHERE pbh.auction_header_id = p_auction_header_id
  AND pbh.bid_status = 'ACTIVE'
);



--get the values from the pon_auction_headers_all table
SELECT
auction_title,
trading_partner_name,
open_bidding_date,
close_bidding_date,
view_by_date,
wf_item_key,
Nvl(no_of_notifications_sent, 0) + 1,
document_number
INTO
p_auction_title,
p_trading_partner_name,
p_neg_open_date,
p_neg_close_date,
p_neg_preview_date,
p_wf_item_key,
p_notification_no,
p_document_number

FROM pon_auction_headers_all
WHERE auction_header_id = p_auction_header_id;


--get the name of the buyer
  BEGIN
    SELECT person_id
    INTO p_person_id
    FROM  per_all_people_f
    WHERE party_id = (
                        SELECT trading_partner_contact_id
                        FROM pon_auction_headers_all
                        WHERE auction_header_id = p_auction_header_id
                      )
    AND SYSDATE BETWEEN effective_start_date AND effective_end_date;

    EXCEPTION WHEN OTHERS THEN
      IF(g_debug_enabled = 'Y') THEN
	      x_progress := ++l_progress || l_api_name || ' : exception while finding buyer name :';
	      log_message(x_progress);
      END IF;
      RAISE;
  END;



wf_directory.GetUserName('PER',
                      p_person_id,
                      p_name,
                      p_trading_partner_contact_name);
--set the sending date as the sysdate
p_reminder_date := SYSDATE;

IF  l_TP_contact_id_table.first > 0 THEN
BEGIN

    FOR i IN  l_TP_contact_id_table.first .. l_TP_contact_id_table.last
    LOOP
    p_supplier_contact_id := l_TP_contact_id_table(i);
    p_supplier_contact_name := l_TP_contact_name_table(i);
    p_supplier_name := l_TP_name_table(i);
    p_supplier_id := l_TP_id_table(i);
    p_supplier_site := l_vendor_site_code_table(i);
    p_supplier_site_id := l_vendor_site_id_table(i);
    --if vendor site id is -1, change site code to null

    IF p_supplier_site_id = -1 THEN
    p_supplier_site := '';
    END IF;

    p_add_con_email := l_add_con_email_table(i);

    IF  p_supplier_contact_id IS NOT NULL THEN

      BEGIN
          SELECT USER_NAME INTO p_supplier_role_name FROM FND_USER
          WHERE person_party_id = l_TP_contact_id_table(i)
          AND SYSDATE BETWEEN start_date AND nvl(end_date,SYSDATE+1);
          EXCEPTION
          WHEN TOO_MANY_ROWS THEN
            IF(g_debug_enabled = 'Y') then
	            x_progress := ++l_progress || l_api_name || ': too many user name found for the supplier :';
	            log_message(x_progress);
            END IF;

          SELECT USER_NAME
          INTO p_supplier_role_name
          FROM FND_USER
          WHERE person_party_id = l_TP_contact_id_table(i)
          AND SYSDATE BETWEEN start_date AND nvl(end_date,SYSDATE+1)
          AND ROWNUM = 1;

       END;


    --create the item key for the workflow
      p_item_key := p_wf_item_key||'_'||l_TP_contact_id_table(i)||'_'||p_auction_header_id
                               ||'_' ||to_char(sysdate, 'JSSSSS')||dbms_random.value;

      IF(g_debug_enabled = 'Y') then
	      x_progress := ++l_progress || l_api_name || ' : starting workflow process'
                                               || 'auction header id' || p_auction_header_id;
	      log_message(x_progress);
       END IF;


      start_wf_process(p_auction_header_id,
      p_trading_partner_contact_name,
      p_trading_partner_name,
      p_auction_title,
      p_reminder_date,
      p_neg_preview_date,
      p_neg_open_date,
      p_neg_close_date,
      p_supplier_name,
      p_supplier_contact_name,
      p_supplier_role_name,
      p_supplier_site,
      p_item_key,
      p_notification_no,
      p_supplier_site_id,
      p_document_number
      );
    END IF;
    IF p_add_con_email IS NOT NULL THEN

      IF(g_debug_enabled = 'Y') then
	      x_progress := ++l_progress || l_api_name || ' : additional contact email is not null : ';
	      log_message(x_progress);
      END IF;


      BEGIN
        SELECT wf_user_name
        INTO
        p_add_con_role_name
        FROM pon_bidding_parties
        WHERE auction_header_id = p_auction_header_id
        AND trading_partner_id = p_supplier_id
        AND Nvl(vendor_site_id,-1) = p_supplier_site_id;

      EXCEPTION WHEN OTHERS THEN
        IF(g_debug_enabled = 'Y') then
	        x_progress := ++l_progress || l_api_name || ' : role name not found : ';
	        log_message(x_progress);
        END IF;
        RAISE;
      END;

      p_item_key := p_wf_item_key||'_'||p_add_con_role_name||'_'
                    ||p_auction_header_id||'_' ||to_char(sysdate, 'JSSSSS')||dbms_random.value;


      IF(g_debug_enabled = 'Y') then
	      x_progress := ++l_progress || l_api_name || ' : starting workflow process'
                                                || 'auction header id' || p_auction_header_id;
	      log_message(x_progress);
      END IF;

      --start workflow id add_con user name
      start_wf_process(p_auction_header_id,
                      p_trading_partner_contact_name,
                      p_trading_partner_name,
                      p_auction_title,
                      p_reminder_date,
                      p_neg_preview_date,
                      p_neg_open_date,
                      p_neg_close_date,
                      p_supplier_name,
                      p_supplier_contact_name,
                      p_add_con_role_name,
                      p_supplier_site,
                      p_item_key,
                      p_notification_no,
                      p_supplier_site_id,
                      p_document_number
                    );
    END IF;

    END LOOP;
END;
END IF;

IF(g_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : END :';
	log_message(x_progress);
END IF;

END call_wf_process_to_send_notif;
--*************************************************************************************

PROCEDURE start_wf_process(
p_auction_header_id IN NUMBER,
p_trading_partner_contact_name IN VARCHAR2,
p_trading_partner_name IN VARCHAR2,
p_auction_title IN VARCHAR2,
p_reminder_date IN DATE,
p_neg_preview_date IN DATE,
p_neg_open_date IN DATE,
p_neg_close_date IN DATE,
p_supplier_name IN VARCHAR2,
p_supplier_contact_name IN VARCHAR2,
p_supplier_role_name IN VARCHAR2,
p_supplier_site IN VARCHAR2,
p_item_key IN VARCHAR2,
p_notification_no IN NUMBER,
p_supplier_site_id IN NUMBER,
p_document_number IN VARCHAR2
)
IS

x_neg_summary_url_supplier     VARCHAR2(2000);

l_api_name			VARCHAR2(100)	:= ' start_wf_process ';
l_progress			NUMBER		:= 0;
x_progress FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

l_server_timezone VARCHAR2(80);
l_user_timezone VARCHAR2(80);
l_user_timezone_desc VARCHAR2(240);

l_language_code VARCHAR2(5);

l_neg_open_date_tz DATE;
l_neg_close_date_tz DATE;
l_neg_preview_date_tz DATE;
l_reminder_date_tz DATE;

l_user_name VARCHAR2(80);



BEGIN



IF(g_debug_enabled = 'Y') then
	  x_progress := ++l_progress || l_api_name || ' : BEGIN :';

	  x_progress := ++l_progress || l_api_name || ' : IN PARAMETERS: all parameters required to start the workflow'
                                            || p_auction_header_id || ', ' ||  p_trading_partner_contact_name
	                  || ', ' ||  p_trading_partner_name || ', ' ||  p_auction_title || ', '
                    	                  ||  p_reminder_date || ', ' ||  p_neg_preview_date || ', '
	                  ||  p_neg_open_date || ', ' ||  p_neg_close_date || ', '
	                  ||  p_supplier_name || ', ' ||  p_supplier_contact_name || ', '
	                  ||  p_supplier_role_name || ', ' ||  p_supplier_site
	                  || ', ' ||  p_item_key || ', ' ||  p_notification_no || ', ' ||  p_supplier_site_id
                                            || ' item key for the workflow : ' || p_item_key;

               	log_message(x_progress);
END IF;
	  l_user_name := p_supplier_role_name;

    -- set the db session language
    PON_PROFILE_UTIL_PKG.get_wf_language(l_user_name, l_language_code);
    PON_AUCTION_PKG.set_session_language(null, l_language_code);

    --------------------------------
    --get the user time zone based on the p_supplier_role_name

    l_user_timezone := PON_AUCTION_PKG.get_time_zone(l_user_name);
    l_server_timezone := PON_AUCTION_PKG.get_oex_time_zone;


    IF (PON_OEX_TIMEZONE_PKG.valid_zone(l_user_timezone) = 1) THEN
      BEGIN
        l_neg_open_date_tz := PON_OEX_TIMEZONE_PKG.convert_time(p_neg_open_date, l_server_timezone, l_user_timezone);
        l_neg_close_date_tz := PON_OEX_TIMEZONE_PKG.convert_time(p_neg_close_date, l_server_timezone, l_user_timezone);
        l_reminder_date_tz := PON_OEX_TIMEZONE_PKG.convert_time(p_reminder_date, l_server_timezone, l_user_timezone);
        IF p_neg_preview_date IS NOT NULL THEN
          l_neg_preview_date_tz := PON_OEX_TIMEZONE_PKG.convert_time(p_neg_preview_date, l_server_timezone, l_user_timezone);
        END IF;
      END;
    ELSE
      BEGIN
        l_user_timezone := l_server_timezone;
        l_neg_open_date_tz := p_neg_open_date;
        l_neg_close_date_tz := p_neg_close_date;
        l_neg_preview_date_tz := p_neg_preview_date;
        l_reminder_date_tz := p_reminder_date;
      END;
    END IF;

    l_user_timezone_desc := PON_AUCTION_PKG.get_timezone_description(l_user_timezone, l_language_code);


    wf_engine.createProcess(itemtype => PON_SEND_NOTIF,
                            itemkey  => p_item_key,
                            process  => 'SEND_NOTIF');

    --1

    wf_engine.SetItemAttrText(itemtype => PON_SEND_NOTIF,
                              itemkey  => p_item_key,
                              aname    => 'BUYER',
                              avalue   => p_trading_partner_contact_name);
    --2
    wf_engine.SetItemAttrText(itemtype => PON_SEND_NOTIF,
                              itemkey  => p_item_key,
                              aname    => 'TRADING_PARTNER_NAME_BUYER',
                              avalue   => p_trading_partner_name);
    --3
    wf_engine.SetItemAttrText(itemtype => PON_SEND_NOTIF,
                              itemkey  => p_item_key,
                              aname    => 'AUCTION_TITLE',
                              avalue   => p_auction_title);
    --4
    wf_engine.SetItemAttrText(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'TP_CONTACT_NAME_SUPP',
                             avalue   => p_supplier_contact_name);
    --5
    wf_engine.SetItemAttrText(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'TRADING_PARTNER_NAME_SUPP',
                             avalue   => p_supplier_name);
    --6
    wf_engine.SetItemAttrText(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'SUPPLIER_SITE',
                             avalue   => p_supplier_site);
    --7
    wf_engine.SetItemAttrText(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'AUCTION_HEADER_ID',
                             avalue   => p_document_number);
    --8
    wf_engine.SetItemAttrDate(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'SENT_ON_DATE',
                             avalue   => l_reminder_date_tz);
    --9
    wf_engine.SetItemAttrDate(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'PREVIEW_DATE',
                             avalue   => l_neg_preview_date_tz);
    --10
    wf_engine.SetItemAttrDate(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'OPEN_DATE',
                             avalue   => l_neg_open_date_tz);
    --11
    wf_engine.SetItemAttrDate(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'CLOSE_DATE',
                             avalue   => l_neg_close_date_tz);
    --12


   wf_engine.SetItemAttrText(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'SUPPLIER_TO_SEND_NOTIF',
                             avalue   => p_supplier_role_name);


    --13
   wf_engine.SetItemAttrText(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'NOTIFICATION_NO',
                             avalue   => p_notification_no);

 -- Get the supplier dest URL
    x_neg_summary_url_supplier := pon_wf_utl_pkg.get_dest_page_url (
		                          p_dest_func => 'PON_NEG_SUMMARY'
                                 ,p_notif_performer  => 'SUPPLIER');
     --14
    wf_engine.SetItemAttrText(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'PON_NEG_SUMMARY_DEST_URL',
                             avalue   => x_neg_summary_url_supplier);



    --15
    wf_engine.SetItemAttrText(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'VENDOR_SITE_ID',
                             avalue   => p_supplier_site_id);


    --16
    wf_engine.SetItemAttrNumber(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'AUCTION_ID',
                             avalue   => p_auction_header_id);

    --17
    wf_engine.SetItemAttrText(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'USER_TIMEZONE',
                             avalue   => l_user_timezone_desc);

   --18
    wf_engine.SetItemAttrText(itemtype => PON_SEND_NOTIF,
                             itemkey  => p_item_key,
                             aname    => 'SET_FROM_ROLE',
                             avalue   => p_trading_partner_contact_name);


 --start workflow
   BEGIN
   wf_engine.StartProcess(itemtype => PON_SEND_NOTIF,
                         itemkey  => p_item_key);


   EXCEPTION WHEN OTHERS THEN

      IF(g_debug_enabled = 'Y') then
        x_progress := ++l_progress || l_api_name || 'Exception : '|| SQLERRM ;
	      log_message(x_progress);
      END IF;

   END;



IF(g_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : END :';
	log_message(x_progress);
END IF;

END start_wf_process;
--*************************************************************************************

PROCEDURE purge_notif_wf(
  p_start_purge IN BOOLEAN,
  p_purge_done OUT NOCOPY BOOLEAN
) IS

l_item_key_like VARCHAR2(255);
l_exact_item_key VARCHAR2(255);

TYPE t_auction_header_id_type IS TABLE OF PON_AUCTION_HEADERS_ALL.auction_header_id%TYPE;
TYPE t_wf_item_key_type IS TABLE OF PON_AUCTION_HEADERS_ALL.wf_item_key%TYPE;
TYPE t_exact_item_key_type is TABLE OF WF_ITEMS.item_key%TYPE;

t_auction_header_id t_auction_header_id_type := t_auction_header_id_type(null);
t_wf_item_key t_wf_item_key_type := t_wf_item_key_type(null);
t_exact_item_key t_exact_item_key_type := t_exact_item_key_type(null);

l_api_name			VARCHAR2(100)	:= ' purge_notif_wf ';
l_progress			NUMBER		:= 0;
x_progress FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

IF(g_debug_enabled = 'Y') then
	  x_progress := ++l_progress || l_api_name || ' : BEGIN :';
	  log_message(x_progress);
END IF;

SELECT
pah.auction_header_id auction_header_id,
pah.wf_item_key

BULK COLLECT INTO
t_auction_header_id,
t_wf_item_key

FROM pon_auction_headers_all pah
WHERE pah.close_bidding_date < SYSDATE
AND SYSDATE > pah.open_bidding_date
AND Nvl(pah.no_of_notifications_sent, 0) > 0;

IF(t_auction_header_id.first > 0) THEN


      FOR i IN  t_auction_header_id.first..t_auction_header_id.last
      LOOP

        l_item_key_like := t_wf_item_key(i)||'_%_'||t_auction_header_id(i)||'_%';

        IF(g_debug_enabled = 'Y') then
	        x_progress := ++l_progress || l_api_name
                                     || 'auction header id ' || t_auction_header_id(i)
                                     || ': like item key to find the exact item key:' || l_item_key_like;
	        log_message(x_progress);
        END IF;

        BEGIN
        SELECT item_key
        BULK COLLECT INTO
        t_exact_item_key
        FROM wf_items
        WHERE item_key LIKE l_item_key_like;

        EXCEPTION WHEN OTHERS THEN

	IF(g_debug_enabled = 'Y') then
		        x_progress := ++l_progress || l_api_name || ' : no item key for the auction ' ;
		        log_message(x_progress);
   	END IF;

        END; -- SELECT STATEMENT

        IF (t_exact_item_key.first > 0) THEN

            FOR j IN t_exact_item_key.first..t_exact_item_key.last
            LOOP

        	IF(g_debug_enabled = 'Y') then
		        x_progress := ++l_progress || l_api_name || ' : exact item key to purge the workflow:' || t_exact_item_key(j);
		        log_message(x_progress);
   	END IF;


        	WF_PURGE.ITEMS (itemtype => PON_SEND_NOTIF,
                                    itemkey  => t_exact_item_key(j),
                                    enddate  => SYSDATE,
                                    docommit => TRUE,
                                    force    => TRUE
          	            );




             END LOOP;
          END IF;
        --update pon_auction_headers_all
          --change the value to -1 after purging
	          UPDATE pon_auction_headers_all pah
	          SET  pah.no_of_notifications_sent = -1
	          WHERE auction_header_id = t_auction_header_id(i);
      END LOOP;

END IF;



IF(g_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : END :';
	log_message(x_progress);
END IF;

EXCEPTION WHEN No_Data_Found THEN

NULL;

END purge_notif_wf;
--*************************************************************************************


PROCEDURE log_message(p_message  IN    VARCHAR2) IS
BEGIN
   IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string(log_level => FND_LOG.level_statement,
                        module  =>  g_module,
                        message  => substr(p_message, 0, 4000));
      END IF;
   END IF;
END log_message;
--*************************************************************************************

END pon_reminder_notification_pkg;

/
