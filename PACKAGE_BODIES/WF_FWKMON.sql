--------------------------------------------------------
--  DDL for Package Body WF_FWKMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_FWKMON" as
/* $Header: wffkmonb.pls 120.2.12010000.2 2014/10/16 21:06:43 alsosa ship $ */


-- ===========================================================================
-- FUNCTION NAME:       getNotificationResult
--
-- DESCRIPTION:         Returns the display result value for a notification.
--
-- PARAMETERS:          x_notificationId IN  Notification ID
--
-- ===========================================================================
FUNCTION getNotificationResult(x_notificationId IN number) return varchar2
IS

  ntf_result varchar2(80) := '';

  CURSOR get_result IS
      SELECT decode(ma.type,
                  'NUMBER', to_char(na.number_value),
                  'DATE',   to_char(na.date_value,
                                 nvl(ma.format, 'DD/MON/YYYY HH24:MI:SS')),
                  'LOOKUP', wf_core.activity_result(ma.format, na.text_value),
                     na.text_value) result
        FROM   wf_notification_attributes na,
               wf_message_attributes_vl ma,
               wf_notifications n
        WHERE  n.notification_id = x_notificationId
        AND    n.message_type = ma.message_type
        AND    n.message_name = ma.message_name
        AND    ma.name = na.name
        AND    ma.name = 'RESULT'
        AND    na.notification_id = n.notification_id;

BEGIN

  OPEN get_result;
  FETCH get_result into ntf_result;
  CLOSE get_result;

  return ntf_result;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

    return ntf_result;

END getNotificationResult;


FUNCTION isRespondNotification(x_notificationId IN number) RETURN number

IS

  resp_exists pls_integer := 0;


BEGIN

  -- Per Ahmed Alomari, this is the fast correct way to check for the
  -- single row existence here.  13-NOV-01

  SELECT 1
  INTO   resp_exists
  FROM	 wf_notifications wn,
	 wf_notification_attributes wna,
         wf_message_attributes m
  WHERE  wn.notification_id = x_notificationId
  AND	 wn.notification_id = wna.notification_id
  AND	 wn.message_name = m.message_name
  AND 	 wn.message_type = m.message_type
  AND	 m.name = wna.name
  AND    m.subtype = 'RESPOND'
  AND    rownum = 1;

  return resp_exists;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

    return resp_exists;


END isRespondNotification;


FUNCTION getItemStatus(x_itemType    IN varchar2,
                       x_itemKey     IN varchar2,
                       x_endDate     IN date,
                       x_rootProcess IN varchar2,
                       x_rootVersion IN number) RETURN varchar2

IS
  status_ret      varchar2(30) := '';
  activity_status varchar2(30) := '';
  activity_result varchar2(30) := '';
  error_count   pls_integer  := 0;

  -- Accoring to Kevin Hudson:
  -- The only way a root process can be set to #FORCE is by aborting the
  -- the workflow. Other activities can be set to this status for other
  -- reasons, but checking the root is a reliable "Abort" indicator.

  CURSOR get_root_info IS
  SELECT wias.activity_result_code,
         wias.activity_status
  FROM   wf_item_activity_statuses  wias,
         wf_activities    wa,
         wf_process_activities   wpa
 WHERE   wias.item_key = x_itemKey
         AND wias.item_type = x_itemType
         AND wa.name = x_rootProcess
         AND wa.version = x_rootVersion
  AND wa.item_type = x_itemType
  AND wa.name = wpa.activity_name
  AND wpa.instance_id = wias.process_activity;

BEGIN

  OPEN get_root_info;
  FETCH get_root_info into activity_result, activity_status;
  CLOSE get_root_info;

  BEGIN

    -- Per Ahmed Alomari, this is the fast correct way to check for the
    -- single row existence here.  13-NOV-01

    SELECT 1
    INTO   error_count
    FROM   wf_item_activity_statuses
    WHERE  item_type = x_itemType
    AND    item_key = x_itemKey
    AND    activity_status = 'ERROR'
    AND    rownum = 1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      error_count := 0;
  END;

  -- If the end date isn't null, the workflow has completed processing.

  if (x_endDate is not null) then

    if (activity_result = '#FORCE') then
      status_ret := 'FORCE';
    elsif (error_count > 0) then
      status_ret := 'COMPLETE_WITH_ERRORS';
    else
      status_ret := 'COMPLETE';
    end if;

  else -- Workflow is still in process

    if (activity_status = 'SUSPEND') then
      if (error_count > 0) then
        status_ret := 'SUSPEND_WITH_ERRORS';
      else
        status_ret := 'SUSPEND';
      end if;
    else
      if (error_count > 0) then
        status_ret := 'ERROR';
      else
        status_ret := 'ACTIVE';
      end if;
    end if;

  end if;

  return status_ret;

END getItemStatus;


function getRoleEmailAddress (x_role_name in varchar2) return varchar2

IS
  -- Copied from wf_directory.getRoleDisplayName()

  colon pls_integer;

  cursor c_role is
    select email_address
    from wf_roles
    where name = x_role_name
    and   ORIG_SYSTEM NOT IN ('HZ_PARTY','POS','ENG_LIST','AMV_CHN',
                              'HZ_GROUP','CUST_CONT');

  cursor corig_role is
    select email_address
    from wf_roles
    where orig_system = substr(x_role_name, 1, colon-1)
    and orig_system_id = substr(x_role_name, colon+1)
    and name = x_role_name;

  email wf_roles.email_address%TYPE;

begin
  if instr(x_role_name, 'email:')=1 then
    return replace(x_role_name, 'email:');
  end if;
  colon := instr(x_role_name, ':');
  if (colon = 0) then
    open c_role;
    fetch c_role into email;
    close c_role;
  else
    open corig_role;
    fetch corig_role into email;
    close corig_role;
  end if;

  return email;

end getRoleEmailAddress;


FUNCTION getEncryptedAccessKey(itemType in varchar2,
                               itemKey in varchar2,
                               adminMode in varchar2 ) RETURN varchar2 is

  l_key varchar2(2048);

BEGIN

  l_key := icx_call.encrypt(wf_monitor.getAccessKey(itemType, itemKey, adminMode));

  return l_key;

  EXCEPTION
    when others then
      raise;

END getEncryptedAccessKey;



FUNCTION getEncryptedAdminMode (adminMode in varchar2) RETURN varchar2 is

  l_adminMode varchar2(2048);

BEGIN

  l_adminMode := icx_call.encrypt(adminMode);

  return l_adminMode;

  EXCEPTION
    when others then
      raise;

END getEncryptedAdminMode;



FUNCTION isMonitorAdministrator(userName in varchar2) RETURN varchar2 is

  l_adminRole varchar2(30);
  l_isAdmin varchar2(1) := 'N';

BEGIN

  l_adminRole := wf_core.translate('WF_ADMIN_ROLE');

  if (l_adminRole = '*') then

    l_isAdmin := 'Y';

  else

    if (wf_directory.isPerformer(userName, l_adminRole)) then

      l_isAdmin := 'Y';

    end if;
  end if;

  return l_isAdmin;


  EXCEPTION
    when others then
      raise;

END isMonitorAdministrator;


FUNCTION getAnonymousSimpleURL(itemType in varchar2,
                               itemKey in varchar2,
			       firstPage in varchar2 ,
                               adminMode in varchar2 ) RETURN varchar2 is
  l_url varchar2(4000);
  l_adminMode varchar2(2048);
  l_accessKey varchar2(2048);
  l_regionToDisplay varchar2(30) := 'WF_SSG_MONITOR_HISTORY_PAGE';
  l_itemType varchar2(2000);
  l_itemKey varchar2(2000);

BEGIN

  if (firstPage = 'DIAGRAM') then
    l_regionToDisplay := 'WF_SSG_MONITOR_DIAGRAM_PAGE';
  end if;

  --
  -- Encode all parameters.
  --

  l_accessKey := getEncryptedAccessKey(itemType, itemKey, adminMode);

  l_adminMode := icx_call.encrypt(adminMode);

  l_accessKey := wfa_html.conv_special_url_chars(getEncryptedAccessKey(itemType, itemKey, adminMode));

  l_adminMode := wfa_html.conv_special_url_chars(icx_call.encrypt(adminMode));

  l_itemType := wfa_html.conv_special_url_chars(itemType);

  l_itemKey := wfa_html.conv_special_url_chars(itemKey);

  l_url := getGuestMonitorURL('0', l_regionToDisplay, l_accessKey, l_adminMode,
                              l_itemType, l_itemKey);

  return l_url;

  EXCEPTION
    when others then
      raise;

END getAnonymousSimpleURL;


FUNCTION getAnonymousAdvanceURL(itemType in varchar2,
                                itemKey in varchar2,
                                firstPage in varchar2 ,
                                adminMode in varchar2) RETURN varchar2 is
  l_url varchar2(4000);
  l_regionToDisplay varchar2(30) := 'WF_G_MONITOR_HISTORY_PAGE';
  l_accessKey varchar2(2048);
  l_adminMode varchar2(2048);
  l_itemType varchar2(2000);
  l_itemKey varchar2(2000);

BEGIN

  if (firstPage = 'DIAGRAM') then
    l_regionToDisplay := 'WF_G_MONITOR_DIAGRAM_PAGE';
  end if;

  --
  -- Encode all parameters.
  --

  l_accessKey := wfa_html.conv_special_url_chars(getEncryptedAccessKey(itemType, itemKey, adminMode));

  l_adminMode := wfa_html.conv_special_url_chars(icx_call.encrypt(adminMode));

  l_itemType := wfa_html.conv_special_url_chars(itemType);

  l_itemKey := wfa_html.conv_special_url_chars(itemKey);

  l_url := getGuestMonitorURL('0', l_regionToDisplay, l_accessKey, l_adminMode,
                              l_itemType, l_itemKey);

  return l_url;

  EXCEPTION
    when others then
      raise;

END getAnonymousAdvanceURL;


FUNCTION getGuestMonitorURL (akRegionApplicationId in varchar2 ,
                             akRegionCode in varchar2 ,
                             accessKey in varchar2 ,
                             adminMode in varchar2 ,
                             itemType in varchar2 ,
                             itemKey in varchar2 ) RETURN varchar2 is

  l_url varchar2(4000);

begin

  l_url := FND_WEB_CONFIG.PLSQL_AGENT||'wf_fwkmon.GuestMonitor'||
           '?akRegionApplicationId='||akRegionApplicationId||
           '&'||'akRegionCode='||akRegionCode||
           '&'||'wa='||accessKey||
           '&'||'wm='||adminMode||
           '&'||'itemType='||itemType||
           '&'||'itemKey='||itemKey;

  return l_url;

end getGuestMonitorURL;


PROCEDURE GuestMonitor (akRegionApplicationId in varchar2 ,
                        akRegionCode in varchar2 ,
                        wa in varchar2 ,
                        wm in varchar2 ,
                        itemType in varchar2 ,
                        itemKey in varchar2 ) is

  l_session_id number;
  l_validate boolean;
  l_url varchar2(4000);
  l_dbc varchar2(240);
  l_language_code varchar2(30);
  l_transaction_id number;
  l_accessKey varchar2(2000);
  l_adminMode varchar2(2000);
  l_itemType varchar2(2000);
  l_itemKey varchar2(2000);

begin

  -- If the user already has an ICX session, use that.  Otherwise, create a new
  -- one for the GUEST user and assign the PREFERENCES responsibility.

  if not icx_sec.validateSession(c_validate_only => 'Y')

  then

    -- user_id 6 is the seeded id for username GUEST

    l_session_id :=  icx_sec.createSession
                          (p_user_id     => 6,
                           c_mode_code   => '115X');


    l_validate := icx_sec.validateSessionPrivate(c_session_id => l_session_id,
                                                 c_validate_only => 'Y');

    owa_util.mime_header('text/html', FALSE);

    icx_sec.sendsessioncookie(l_session_id);

    -- Set the responsibility to the PREFERENCES responsibility (which
    -- we can assume the GUEST user has).  This points to the
    -- ICX_PREFERENCES menu, to which the "Guest" monitor application
    -- menus have been added.

    l_transaction_id := icx_sec.createTransaction(
                           p_session_id => l_session_id,
                           p_resp_appl_id => 178,
                           p_responsibility_id => 20873,
                           p_security_group_id => 0);

    icx_sec.updateSessionContext(p_application_id => 178,
                                 p_responsibility_id => 20873,
                                 p_security_group_id => 0,
                                 p_session_id => l_session_id,
				 p_transaction_id => l_transaction_id);

  else

    -- We are reusing a preexisting session, so we need to
    -- get the transaction_id for the url.  You could have multiple
    -- txn ids per function, or none.

    BEGIN

      SELECT max(transaction_id)
      INTO   l_transaction_id
      FROM   icx_transactions
      WHERE  session_id = icx_sec.g_session_id
      AND    responsibility_id = icx_sec.g_responsibility_id
      AND    security_group_id = icx_sec.g_security_group_id
      AND    function_id = icx_sec.g_function_id
      GROUP BY transaction_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

          SELECT icx_transactions_s.nextval
          INTO   l_transaction_id
          FROM   sys.dual;

    END;

  end if;

  -- Get the framework agent and make sure it always has a trailing slash.

  l_url := fnd_web_config.trail_slash(fnd_profile.value('APPS_FRAMEWORK_AGENT'));

  fnd_profile.get(name => 'APPS_DATABASE_ID',
                   val => l_dbc);

  if l_dbc is null
  then
    l_dbc := FND_WEB_CONFIG.DATABASE_ID;
  end if;

  --
  -- Encode all the parameters (they would have been decoded when GuestMonitor was called)
  --

  l_accessKey := wfa_html.conv_special_url_chars(wa);

  l_adminMode := wfa_html.conv_special_url_chars(wm);

  l_itemType := wfa_html.conv_special_url_chars(itemType);

  l_itemKey := wfa_html.conv_special_url_chars(itemKey);

  l_url := l_url||'OA_HTML/';

  l_url := l_url||'OA.jsp?'||'akRegionCode='||akRegionCode||
                  '&'||'akRegionApplicationId='||akRegionApplicationId||
                  '&'||'dbc='||l_dbc||
--                  '&'||'language_code='||icx_sec.g_language_code||
                  '&'||'transactionid='||l_transaction_id||
                  '&'||'wa='||l_accessKey||
                  '&'||'wm='||l_adminMode||
                  '&'||'itemType='||l_itemType||
                  '&'||'itemKey='||l_itemKey||
                  '&'||'wia=Y';

owa_util.redirect_url(l_url);

end GuestMonitor;

--
-- GetNtfResponderName
--   Function to return the Notification Responder's display name
--
-- IN
--   p_notification_id - Notification ID
-- RETURN
--   Responder's display anme
--
function GetNtfResponderName(p_notification_id in number)
return varchar2
is
  l_responder wf_notifications.responder%type;
  l_username  varchar2(360);
begin

  SELECT responder
  INTO   l_responder
  FROM   wf_notifications
  WHERE  notification_id = p_notification_id;

  -- Check if directory service has display name
  l_username := wf_directory.GetRoleDisplayName2(l_responder);

  if (l_username is not null) then
    return l_username;
  end if;

  -- If the responder was purged from directory service, check for the
  -- denormalized value from wf_comments table
  SELECT wc.from_user
  INTO   l_username
  FROM   wf_notifications wn,
         wf_comments wc
  WHERE  wn.notification_id = p_notification_id
    AND  wn.notification_id = wc.notification_id
    AND  wn.responder = wc.from_role
    AND  wc.action_type = 'RESPOND'
    AND  wc.action like 'RESPOND%'
    AND  rownum = 1;

  return l_username;

exception
  when no_data_found then
    return null;
  when others then
    wf_core.context('wf_fwkmon', 'GetNtfResponderName', to_char(p_notification_id));
    raise;
end GetNtfResponderName;

end wf_fwkmon;

/
