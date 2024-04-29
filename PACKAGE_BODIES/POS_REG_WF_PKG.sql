--------------------------------------------------------
--  DDL for Package Body POS_REG_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_REG_WF_PKG" as
/* $Header: POSREGWB.pls 120.5.12010000.2 2008/09/20 17:47:13 sthoppan ship $ */

/*---------------------------------------

    private constants used by this package

----------------------------------------*/

-- user responsibility profile options
PON_USR_RESP_PROF CONSTANT VARCHAR(30) := 'PON_DEFAULT_EXT_USER_RESP';
POS_USR_RESP_PROF CONSTANT VARCHAR(30) := 'POS_DEFAULT_EXT_USER_RESP';
MSC_USR_RESP_PROF CONSTANT VARCHAR(30) := 'POS_COLLAB_RESPONSIBILITY';
POS_ISP_COLLAB_RESP_PROF CONSTANT VARCHAR(30) := 'POS_ISP_COLLAB_RESP';

-- the application shortname for FND message stack
-- we use '' so that we get clean message text
FND_MSG_APP CONSTANT VARCHAR2(3) := '';

-- the default security attribute value for supplier site and contact
pos_default_sec_attr_value CONSTANT NUMBER := -9999;

-- the invitation response page URL
POS_INV_REPLY_PAGE CONSTANT VARCHAR2(4000) := 'OA_HTML/jsp/pos/registration/RegistrationReply.jsp?registrationKey=';

-- the user approval page URL
POS_APPROVAL_PAGE CONSTANT VARCHAR2(4000) := 'OA_HTML/OA.jsp?akRegionCode=POS_APPROVE_MAIN_RGN&akRegionApplicationId=177&registrationKey=';

-- a global error message holder
ERROR_MESSAGE FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := NULL;

-- error message names
MSG_USER_RESP_FAIL CONSTANT FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'POS_USER_RESP_FAIL';

MSG_UNEXPECTED_ERROR CONSTANT FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'POS_REG_UNEXPECTED_ERR';
MSG_FND_USER_DUPLICATE CONSTANT FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'SECURITY-DUPLICATE USER';
MSG_USER_CREATION_FAIL CONSTANT FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'POS_REG_USER_CREATION_FAIL';
MSG_VENDORUSER_CREATION_FAIL CONSTANT FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'POS_REG_VNDR_USR_CREATE_FAIL';
MSG_POS_SITE_SECATTR_FAIL CONSTANT FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'POS_REG_SITE_SECATTR_FAIL';
MSG_POS_CONTACT_SECATTR_FAIL CONSTANT FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'POS_REG_CONT_SECATTR_FAIL';
MSG_POS_SEC_ATTR_FAIL CONSTANT FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'POS_REG_SECATTR_FAIL';
MSG_REG_LOCK_FAIL CONSTANT FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'POS_REG_REGLOCK_FAIL';
MSG_APPRV_LOCK_FAIL CONSTANT FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'POS_REG_APPRVLOCK_FAIL';
MSG_REG_DATA_MISSING CONSTANT FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'POS_REG_DATA_MISSING';
MSG_POS_SUPP_SECATTR_FAIL CONSTANT FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'POS_SUPP_SECATTR_FAIL';
MSG_VENDORUSER_DETAILS_FAIL CONSTANT FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'POS_REG_VNDR_USR_DETAIL_FAIL';

-- global variable for logging
g_log_module_name VARCHAR2(30) := 'pos.plsql.POSREGWB';
g_log_proc_start VARCHAR2(30) := 'start';
g_log_proc_end VARCHAR2(30) := 'end';
g_log_reg_key_notfound VARCHAR2(30) := 'Registration key is NOT FOUND.';
g_log_reg_id_invalid VARCHAR2(30) := 'Registration ID is INVALID.';

TYPE g_refcur IS REF CURSOR;

/*----------------------------------------
PRIVATE FUNCTION decrypt
  decrypt initial password set by OSN
  registration request
----------------------------------------*/

function decrypt(key in varchar2, value in varchar2)  return varchar2
  as language java name 'oracle.apps.fnd.security.WebSessionManagerProc.decrypt(java.lang.String,java.lang.String) return java.lang.String';

/*******************************************************************
     PROCEDURE NAME: get_wf_role_for_users
     this is the same function as that in PO_REQAPPROVAL_INIT1 (private func)

     DESCRIPTION   :
     Given a list of users, the procedure looks through the wf_user_roles
     to get a role that has exactly same set of input list of users.

     parameters    :
       Input:
           p_list_of_users - String containing the list of users
               Example string: 'GE1', 'GE2', 'GE22'
           p_num_users - number of users in the above list
       Output:
           A string containg the role name ( or null , if such role
           does not exist ).
*******************************************************************/

FUNCTION get_wf_role_for_users(p_list_of_users in varchar2, p_num_users in number) return varchar2 IS
   l_refcur g_refcur;
   l_role_name WF_USER_ROLES.ROLE_NAME%TYPE;
   l_progress varchar2(255);
BEGIN
         open l_refcur for
           --'select role_name ,  count(role_name)
           'select role_name
            from wf_user_roles
            where
                role_name in
            (
               select role_name
               from wf_user_roles
               where user_name in (' ||  p_list_of_users || ')
               group by role_name
               having count(role_name) = :1
            )
           group by role_name
           having count(role_name) = :2 '
         using p_num_users, p_num_users;

         LOOP
           fetch l_refcur into l_role_name;
               if l_refcur%notfound then
                   exit;
               end if;
               close l_refcur;
               exit;
         END LOOP;
         return l_role_name;
EXCEPTION
    WHEN OTHERS THEN
       return null;
END;

/*----------------------------------------
function get_approver_role_for_osn_request
  for user registration coming from Oracle
  Supplier Network.  We want the notification
  be sent to all users that can approve
  external user registrations.

  this function will create a role for this
  user list, so that notification REG_ADMIN_NTF
  will be sent to this role.
----------------------------------------*/

function get_approver_role_for_osn
  return varchar2

is
   x_refcur             g_refcur;
   l_approver_func_id   NUMBER := null;
   l_user_name          FND_USER.USER_NAME%TYPE := null;
   l_num_users          number := 0;
   l_approverlist       varchar2(2000):=null;
   l_approverlist_sql   varchar2(2000):=null;
   l_role_name          WF_USER_ROLES.ROLE_NAME%TYPE := null;
   l_role_display_name  varchar2(100):=null;
   l_expiration_date    DATE;

begin

   --step 1: find the users that can approve external user registrations

   SELECT function_id
   INTO l_approver_func_id
   FROM fnd_form_functions
   WHERE function_name = 'POS_REG_APPROVE_EXT_USERS';

   OPEN x_refcur FOR
      'SELECT DISTINCT fu.user_name
      FROM fnd_user fu,
           fnd_responsibility fr,
           wf_user_roles wur
      WHERE fr.menu_id in
            (SELECT     fme.menu_id
             FROM       fnd_menu_entries fme
             START WITH fme.function_id = :1
             CONNECT BY PRIOR menu_id = sub_menu_id
             )
      AND fr.application_id = 177
      AND wur.role_name like ''FND_RESP|%|%|STANDARD''
      AND WUR.ROLE_ORIG_SYSTEM = ''FND_RESP''
      AND WUR.ROLE_ORIG_SYSTEM_ID = FR.RESPONSIBILITY_ID
      AND WUR.ASSIGNMENT_TYPE IN (''D'', ''B'')
      AND wur.user_name = fu.user_name'
   using l_approver_func_id;


   --step 2: build the approver list

   loop
     fetch x_refcur into l_user_name;
     exit when x_refcur%NOTFOUND;
     l_num_users := l_num_users + 1;
     if(l_approverlist is null) then
       l_approverlist:=l_user_name;
       l_approverlist_sql := ''''||l_user_name||'''';
     else
       l_approverlist:=l_approverlist || ' ' || l_user_name;
       l_approverlist_sql:=l_approverlist_sql||','||''''||l_user_name||'''';
     end if;
   end loop;
   close x_refcur;

   --step 3: given the approver list, find an existing matching role
   --        or create a new role

   if(l_approverlist is not null) then
     l_role_name:= get_wf_role_for_users(l_approverlist_sql, l_num_users);

     if(l_role_name is null ) then

           l_expiration_date := sysdate + 30; -- this role expires in 30 days

           WF_DIRECTORY.CreateAdHocRole(l_role_name, l_role_display_name,
             null,
             null,
             null,
             'MAILHTML',
             l_approverlist,
             null,
             null,
             'ACTIVE',
             l_expiration_date);
     end if;

     return l_role_name;

   end if;

   --the approver list is null
   return null;

exception
   when others then
     return null;
end get_approver_role_for_osn;

/*----------------------------------------

  private FUNCTION GetAdHocUserName

    Generate an adhoc user name given a registration username

  PARAMS:
     p_username IN VARCHAR2 : the username a user normally use

  RETURN:
     VARCHAR2 : an adhoc username as a workflow local username

----------------------------------------*/

FUNCTION GetAdHocUserName (p_username IN VARCHAR2) RETURN VARCHAR2
IS
lv_adhoc_username WF_LOCAL_USERS.NAME%TYPE;
BEGIN
  -- it probably won't exceed the column restraint, but just to take precaution
  lv_adhoc_username := 'POS_REG_' || p_username;
  RETURN lv_adhoc_username;
END GetAdHocUserName;


/*----------------------------------------

  private PROCEDURE ClearError

    Set the error message to be NULL

  PARAMS:
     none

----------------------------------------*/

PROCEDURE ClearError
IS
BEGIN
  ERROR_MESSAGE := NULL;
END ClearError;

/*----------------------------------------

  private FUNCTION CheckError

    Check whether the error message has been set.

  PARAMS:
     none

  RETURN:
     VARCHAR2 : the error message that has been set, or NULL if not yet set

----------------------------------------*/

FUNCTION CheckError RETURN VARCHAR2
IS
BEGIN
  RETURN ERROR_MESSAGE;
END CheckError;


/*----------------------------------------

  private PROCEDURE SetErrMsg

     Private procedure. Put message on FND message stack to signal an error
     attributes. This procedure only supports up to two tokens.

  PARAMS:
    p_err_msg         IN  VARCHAR2 : the FND message name
    p_token1          IN  VARCHAR2 DEFAULT NULL : the name of token 1
    p_token1_val      IN  VARCHAR2 DEFAULT NULL : the token 1 value
    p_token2          IN  VARCHAR2 DEFAULT NULL : the name of token 2
    p_token2_val      IN  VARCHAR2 DEFAULT NULL : the token 2 value
    p_translate       IN  BOOLEAN  DEFAULT TRUE : translation flag for tokens

----------------------------------------*/

PROCEDURE SetErrMsg
(
  p_err_msg         IN  VARCHAR2
, p_token1          IN  VARCHAR2 DEFAULT NULL
, p_token1_val      IN  VARCHAR2 DEFAULT NULL
, p_token2          IN  VARCHAR2 DEFAULT NULL
, p_token2_val      IN  VARCHAR2 DEFAULT NULL
, p_translate       IN  BOOLEAN  DEFAULT TRUE
)

IS
lv_prev_msg FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
lv_proc_name VARCHAR2(30) := 'SetErrMsg';
BEGIN

  -- just to lot previous messages if any
  lv_prev_msg := FND_MESSAGE.get();

  IF ( lv_prev_msg IS NOT NULL ) THEN

    IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.string(fnd_log.level_statement, g_log_module_name || '.' || lv_proc_name, 'Previous error message: ' || lv_prev_msg);
    END IF;

  END IF;

  ERROR_MESSAGE := p_err_msg;

  FND_MESSAGE.set_name(FND_MSG_APP, p_err_msg);

  IF ( p_token1 IS NOT NULL ) THEN
    FND_MESSAGE.set_token(p_token1, p_token1_val, p_translate);
  END IF;

  IF ( p_token2 IS NOT NULL ) THEN
    FND_MESSAGE.set_token(p_token2, p_token2_val, p_translate);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  RAISE;
END SetErrMsg;


/*----------------------------------------

  private FUNCTION GetEnterpriseName

    Returns the Enterprise Name

  PARAMS:
     none

  RETURN:
     VARCHAR2 : the Enterprise Name or NULL if error

----------------------------------------*/

FUNCTION GetEnterpriseName RETURN VARCHAR2
IS

lv_party_name HZ_PARTIES.PARTY_NAME%TYPE;
lv_exception_msg VARCHAR2(32000);
lv_status VARCHAR2(240);
lv_proc_name VARCHAR2(30) := 'GetEnterpriseName';

BEGIN

  POS_ENTERPRISE_UTIL_PKG.get_enterprise_party_name( lv_party_name, lv_exception_msg, lv_status);

  IF ( lv_status <> 'S' ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Error getting the Enterprise Name: ' || lv_exception_msg);
    END IF;

    RETURN '';
  ELSE
    RETURN lv_party_name;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END GetEnterpriseName;

/*----------------------------------------

  private FUNCTION GetRegPageURL

    Returns the URL of the registration page with the invitation key. The
    URL will be in the format of protocol://host:port/page?param=val...

  PARAMS:
     p_inv_key IN VARCHAR2 : the invitation key

  RETURN:
     VARCHAR2 : the registration page with the invitation key, or NULL if error

----------------------------------------*/

FUNCTION GetRegPageURL (
  p_inv_key IN VARCHAR2,
  p_reg_lang_code IN VARCHAR2
) RETURN VARCHAR2
IS

BEGIN

    RETURN pos_url_pkg.get_external_url || POS_INV_REPLY_PAGE || p_inv_key || '&regLang=' || p_reg_lang_code;

EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END GetRegPageURL;


/*----------------------------------------

  private FUNCTION GetApprPageURL

    Returns the URL of the approval page with the registration key. The
    URL will be in the format of protocol://host:port/page?param=val...

  PARAMS:
     p_reg_key IN VARCHAR2 : the registration key

  RETURN:
     VARCHAR2 : the approval page with the registsration key, or NULL if error

----------------------------------------*/

FUNCTION GetApprPageURL (
  p_reg_key IN VARCHAR2
) RETURN VARCHAR2
IS

lv_fwk_agent VARCHAR2(4000) := NULL;

BEGIN

  FND_PROFILE.get('APPS_FRAMEWORK_AGENT', lv_fwk_agent);


  IF ( lv_fwk_agent IS NULL ) THEN
    RETURN '';
  ELSIF ( substr(lv_fwk_agent, -1, 1) = '/' ) THEN
    RETURN lv_fwk_agent || POS_APPROVAL_PAGE || p_reg_key;
  ELSE
    RETURN lv_fwk_agent || '/' || POS_APPROVAL_PAGE || p_reg_key;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END GetApprPageURL;


/*----------------------------------------

  private FUNCTION GetLogonPageURL

    Returns the URL of the logon page. The URL will be in the format
    of protocol://host:port/page?param=val...

  PARAMS:
     none

  RETURN:
     VARCHAR2 : the logon page URL, or NULL if error

----------------------------------------*/

FUNCTION GetLogonPageURL (
  p_internal_flag IN VARCHAR2
) RETURN VARCHAR2
IS

BEGIN

  IF ( p_internal_flag = 'Y' OR p_internal_flag = 'y' ) THEN
     RETURN pos_url_pkg.get_internal_login_url;
  ELSE
     RETURN pos_url_pkg.get_external_login_url;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END GetLogonPageURL;

/*----------------------------------------

  private PROCEDURE UpdItemTypeKeyHelper

    Convenient procedure for updating item type and item key

  PARAMS:
    p_itemtype VARCHAR2 - the item type
    p_itemkey  VARCHAR2 - the item key
    p_itemtype_fieldname VARCHAR2 - the item type field_name
    p_itemkey_fieldname  VARCHAR2 - the item key field_name

----------------------------------------*/

PROCEDURE UpdItemTypeKeyHelper (
  p_itemtype IN VARCHAR2
, p_itemkey  IN VARCHAR2
, p_itemtype_fieldname IN VARCHAR2
, p_itemkey_fieldname  IN VARCHAR2
)
IS

ln_reg_id NUMBER := -1;
ln_app_id NUMBER := -1;
lv_reg_type FND_REGISTRATIONS.REGISTRATION_TYPE%TYPE := NULL;

lv_registration_key WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
lv_proc_name VARCHAR2(30) := 'UpdItemTypeKeyHelper';

BEGIN


  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
  END IF;


  lv_registration_key := WF_ENGINE.GetItemAttrText(p_itemtype, p_itemkey, 'REGISTRATION_KEY');

  ln_reg_id := FND_REGISTRATION_UTILS_PKG.get_reg_id_from_key(lv_registration_key);

  ln_app_id := WF_ENGINE.GetItemAttrNumber(p_itemtype, p_itemkey, 'APPLICATION_ID');

  lv_reg_type := WF_ENGINE.GetItemAttrText(p_itemtype, p_itemkey, 'REGISTRATION_TYPE');

  FND_REGISTRATION_PKG.insert_fnd_reg_details(
      ln_reg_id, ln_app_id, lv_reg_type, p_itemtype_fieldname,
      'VARCHAR2', NULL, p_itemtype, NULL, NULL);

  FND_REGISTRATION_PKG.insert_fnd_reg_details(
      ln_reg_id, ln_app_id, lv_reg_type, p_itemkey_fieldname,
      'VARCHAR2', NULL, p_itemkey, NULL, NULL);


  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;


  RETURN;

EXCEPTION
WHEN OTHERS THEN

  IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
  END IF;

  RAISE;
END UpdItemTypeKeyHelper;

/*----------------------------------------

  public PROCEDURE LockReg

     Workflow activity function. Lock the registration record to prevent
     simultaneous responses to the same invitation.

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if the record is successfully locked.
    COMPLETE:ERROR   - if the record's status has changed when getting the lock

----------------------------------------*/

PROCEDURE LockReg(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS

lv_reg_key WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
lv_reg_status FND_REGISTRATIONS.REGISTRATION_STATUS%TYPE;
lv_proc_name VARCHAR2(30) := 'LockReg';

BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


ClearError;

IF ( funcmode = 'RUN' ) then

  lv_reg_key := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRATION_KEY', TRUE);
  IF ( lv_reg_key IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, g_log_reg_key_notfound);
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  -- lock the registration record row
  SELECT registration_status
  INTO   lv_reg_status
  FROM   fnd_registrations
  WHERE  registration_key = lv_reg_key
  FOR UPDATE;

  -- check the precondition of registration
  -- for nun-OSN request, it should be INVITED,
  -- for OSN request, it's OSNREQUESTED before raising the 'Registered' event
  IF ( lv_reg_status <> 'INVITED' AND lv_reg_status <> 'OSNREQUESTED' ) THEN
    SetErrMsg(MSG_REG_LOCK_FAIL);
    resultout := 'COMPLETE:ERROR';

    IF ( fnd_log.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_error, g_log_module_name || '.' || lv_proc_name, 'Registration status is '||lv_reg_status);
    END IF;

    -- hack. just to raise an arbitrary exception
    RAISE NO_DATA_FOUND;
  END IF;

  resultout := 'COMPLETE:SUCCESS';


  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;


  RETURN;

END IF;

EXCEPTION
WHEN OTHERS THEN

  IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
  END IF;

  IF ( CheckError() IS NULL ) THEN
    SetErrMsg(MSG_UNEXPECTED_ERROR);
    resultout := 'COMPLETE:ERROR';
  END IF;
  WF_CORE.CONTEXT (V_PACKAGE_NAME, 'LOCKREG', itemtype, itemkey, to_char(actid), funcmode);
  RAISE;
END LockReg;

/*----------------------------------------

  public PROCEDURE LockApprv

     Workflow activity function. Lock the registration record (to be approved)
     to prevent simultaneous approving process.

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if the record is successfully locked.
    COMPLETE:ERROR   - if the record's status has changed when getting the lock

----------------------------------------*/

PROCEDURE LockApprv(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS

lv_reg_key WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
lv_reg_status FND_REGISTRATIONS.REGISTRATION_STATUS%TYPE;
lv_proc_name VARCHAR2(30) := 'LockApprv';

BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


ClearError;

IF ( funcmode = 'RUN' ) then

  lv_reg_key := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRATION_KEY', TRUE);

  IF ( lv_reg_key IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, g_log_reg_key_notfound);
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  -- lock the registration record row
  SELECT registration_status
  INTO   lv_reg_status
  FROM   fnd_registrations
  WHERE  registration_key = lv_reg_key
  FOR UPDATE;

  -- check the pre-condition of an approval process
  IF ( lv_reg_status <> 'REGISTERED' ) THEN

    IF ( fnd_log.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_error, g_log_module_name || '.' || lv_proc_name, 'Registration status is '||lv_reg_status);
    END IF;

    SetErrMsg(MSG_APPRV_LOCK_FAIL);
    resultout := 'COMPLETE:ERROR';
    -- hack. just to raise an arbitrary exception
    RAISE NO_DATA_FOUND;
  END IF;

  resultout := 'COMPLETE:SUCCESS';

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;

  RETURN;

END IF;

EXCEPTION
WHEN OTHERS THEN

  IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
  END IF;

  IF ( CheckError() IS NULL ) THEN
    SetErrMsg(MSG_UNEXPECTED_ERROR);
    resultout := 'COMPLETE:ERROR';
  END IF;
  WF_CORE.CONTEXT (V_PACKAGE_NAME, 'LOCKAPPRV', itemtype, itemkey, to_char(actid), funcmode);
  RAISE;
END LockApprv;

/*----------------------------------------

  public PROCEDURE LockRjct

     Workflow activity function. Lock the registration record (to be rejected)
     to prevent simultaneous rejection.

     Exactly the same as LockApprv.

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if the record is successfully locked.
    COMPLETE:ERROR   - if the record's status has changed when getting the lock

----------------------------------------*/

PROCEDURE LockRjct(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS
lv_proc_name VARCHAR2(30) := 'LockRjct';
BEGIN


  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
  END IF;

  LockApprv(itemtype, itemkey, actid, funcmode, resultout);

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;


END LockRjct;


/*----------------------------------------

  public PROCEDURE UpdInvTypeKey

     Workflow activity function. Update registration details with the itemtype
     and item key

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE : always return COMPLETE. do not raise errors.

----------------------------------------*/

PROCEDURE UpdInvTypeKey(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS
lv_proc_name VARCHAR2(30) := 'UpdInvTypeKey';
BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


ClearError;

IF ( funcmode = 'RUN' ) then

  UpdItemTypeKeyHelper(itemtype, itemkey,
      FND_REGISTRATION_UTILS_PKG.INVITATION_WF_ITEM_TYPE,
      FND_REGISTRATION_UTILS_PKG.INVITATION_WF_ITEM_KEY);

  resultout := 'COMPLETE';

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;

  RETURN;

END IF;

EXCEPTION
WHEN OTHERS THEN

  IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
  END IF;

  -- do not raise exception. if something wrong, just skip it
  resultout := 'COMPLETE';
  RETURN;
END UpdInvTypeKey;

/*----------------------------------------

  public PROCEDURE UpdRegTypeKey

     Workflow activity function. Update registration details with the itemtype
     and item key

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE : always return COMPLETE. do not raise errors.

----------------------------------------*/

PROCEDURE UpdRegTypeKey(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS
lv_proc_name VARCHAR2(30) := 'UpdRegTypeKey';
BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


IF ( funcmode = 'RUN' ) then

  UpdItemTypeKeyHelper(itemtype, itemkey,
      FND_REGISTRATION_UTILS_PKG.REGISTRATION_WF_ITEM_TYPE,
      FND_REGISTRATION_UTILS_PKG.REGISTRATION_WF_ITEM_KEY);

  resultout := 'COMPLETE';

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;

  RETURN;

END IF;

EXCEPTION
WHEN OTHERS THEN

   IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
   END IF;

  -- do not raise exception. if something wrong, just skip it
  resultout := 'COMPLETE';
  RETURN;
END UpdRegTypeKey;

/*----------------------------------------

  public PROCEDURE UpdApprvTypeKey

     Workflow activity function. Update registration details with the itemtype
     and item key

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE : always return COMPLETE. do not raise errors.

----------------------------------------*/

PROCEDURE UpdApprvTypeKey(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS
lv_proc_name VARCHAR2(30) := 'UpdApprvTypeKey';
BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


IF ( funcmode = 'RUN' ) then

  UpdItemTypeKeyHelper(itemtype, itemkey,
      FND_REGISTRATION_UTILS_PKG.APPROVAL_WF_ITEM_TYPE,
      FND_REGISTRATION_UTILS_PKG.APPROVAL_WF_ITEM_KEY);

  resultout := 'COMPLETE';

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;

  RETURN;

END IF;

EXCEPTION
WHEN OTHERS THEN

  IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
  END IF;

  -- do not raise exception. if something wrong, just skip it
  resultout := 'COMPLETE';
  RETURN;
END UpdApprvTypeKey;

/*----------------------------------------

  public PROCEDURE UpdRjctTypeKey

     Workflow activity function. Update registration details with the itemtype
     and item key

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE : always return COMPLETE. do not raise errors.

----------------------------------------*/

PROCEDURE UpdRjctTypeKey(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS
lv_proc_name VARCHAR2(30) := 'UpdRjctTypeKey';
BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


IF ( funcmode = 'RUN' ) then

  UpdItemTypeKeyHelper(itemtype, itemkey,
      FND_REGISTRATION_UTILS_PKG.REJECTION_WF_ITEM_TYPE,
      FND_REGISTRATION_UTILS_PKG.REJECTION_WF_ITEM_KEY);

  resultout := 'COMPLETE';

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;

  RETURN;

END IF;

EXCEPTION
WHEN OTHERS THEN

  IF ( fnd_log.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_error,g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
  END IF;

  -- do not raise exception. if something wrong, just skip it
  resultout := 'COMPLETE';
  RETURN;
END UpdRjctTypeKey;


/*----------------------------------------

  public PROCEDURE SetInvItemAttrValues

     Workflow activity function. Set item attribute values in 'USER_INVITED'
     process.
     Following attributes are set:

       * REGISTRANT_LANGUAGE         * NOTE
       * REGISTRANT_EMAIL            * ADHOC_USER_NAME
       * ENTERPRISE_NAME             * REG_PAGE_URL

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if everything is ok.
    COMPLETE:ERROR   - if critical attribute cannot be set.

----------------------------------------*/

PROCEDURE SetInvItemAttrValues(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS

lv_reg_key WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
ln_reg_id NUMBER;

lv_registrant_lang FND_REGISTRATIONS.LANGUAGE_CODE%TYPE;
lv_registrant_email FND_REGISTRATIONS.EMAIL%TYPE;

lv_enterprise_name HZ_PARTIES.PARTY_NAME%TYPE;
lv_reg_page_url VARCHAR2(32000);

lv_notes FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE;

lv_x_field_type FND_REGISTRATION_DETAILS.FIELD_TYPE%TYPE;
lv_x_field_format FND_REGISTRATION_DETAILS.FIELD_FORMAT%TYPE;
ln_x_field_value_number FND_REGISTRATION_DETAILS.FIELD_VALUE_NUMBER%TYPE;
lv_x_field_value_date FND_REGISTRATION_DETAILS.FIELD_VALUE_DATE%TYPE;
lv_proc_name VARCHAR2(30) := 'SetInvItemAttrValues';

BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


IF ( funcmode = 'RUN' ) then

  lv_reg_key := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRATION_KEY', TRUE);
  IF ( lv_reg_key IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, g_log_reg_key_notfound);
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  ln_reg_id := FND_REGISTRATION_UTILS_PKG.get_reg_id_from_key(lv_reg_key);

  BEGIN
    SELECT NVL(language_code, 'US'), email
    INTO   lv_registrant_lang, lv_registrant_email
    FROM   fnd_registrations
    WHERE  registration_id = ln_reg_id;
  EXCEPTION WHEN OTHERS THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, g_log_reg_id_invalid);
    END IF;

    RAISE;
  END;

  IF ( lv_registrant_email IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Email is null.');
    END IF;

    SetErrMsg(MSG_REG_DATA_MISSING);
    resultout := 'COMPLETE:ERROR';
    -- hack!!! just to raise an arbitrary exception
    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'REGISTRANT_LANGUAGE', lv_registrant_lang);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'REGISTRANT_EMAIL', lv_registrant_email);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'ADHOC_USER_NAME', GetAdHocUserName(ln_reg_id));

  lv_enterprise_name := GetEnterpriseName();
  IF ( lv_enterprise_name IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Enterprise name is not found.');
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'ENTERPRISE_NAME', lv_enterprise_name);

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'Note', lv_x_field_type, lv_x_field_format, lv_notes, ln_x_field_value_number, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    lv_notes := NULL;
  END;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'NOTE', lv_notes);

  lv_reg_page_url := GetRegPageURL(lv_reg_key, lv_registrant_lang);
  IF ( lv_reg_page_url IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Invitation response page URL is not found.');
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'REG_PAGE_URL', lv_reg_page_url);

  resultout := 'COMPLETE:SUCCESS';

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;

  RETURN;

END IF;
EXCEPTION
  WHEN OTHERS THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
    END IF;

    IF ( CheckError() IS NULL ) THEN
      SetErrMsg(MSG_UNEXPECTED_ERROR);
      resultout := 'COMPLETE:ERROR';
    END IF;
    WF_CORE.CONTEXT (V_PACKAGE_NAME, 'SETINVITEMATTRVALUES', itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END SetInvItemAttrValues;

/*----------------------------------------

  public PROCEDURE SetRegItemAttrValues

     Workflow activity function. Set item attribute values in 'USER_REGISTERED'
     process.
     Following attributes are set:

       * APPROVER_ROLE               * NOTE
       * FIRST_NAME                  * LAST_NAME
       * VENDOR_NAME                 * APPROVAL_PAGE_URL
       * ENTERPRISE_NAME             * LOGON_PAGE_URL

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if everything is ok.
    COMPLETE:ERROR   - if critical attribute cannot be set.

----------------------------------------*/

PROCEDURE SetRegItemAttrValues(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS

lv_reg_key WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
ln_reg_id NUMBER;

lv_first_name FND_REGISTRATIONS.FIRST_NAME%TYPE := NULL;
lv_last_name FND_REGISTRATIONS.LAST_NAME%TYPE := NULL;
lv_vendor_name FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE := NULL;
lv_osn_tp_name FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE := NULL;
ln_approver_id NUMBER := NULL;
--lv_approver_role FND_USER.USER_NAME%TYPE := NULL; --varchar2(100)
lv_approver_role WF_USER_ROLES.ROLE_NAME%TYPE := NULL; --varchar2(320)
lv_approval_page_url VARCHAR2(32000) := NULL;
lv_notes FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE := NULL;
lv_enterprise_name HZ_PARTIES.PARTY_NAME%TYPE;
lv_logon_page_url VARCHAR2(32000) := NULL;

lv_x_field_type FND_REGISTRATION_DETAILS.FIELD_TYPE%TYPE;
lv_x_field_format FND_REGISTRATION_DETAILS.FIELD_FORMAT%TYPE;
lv_x_field_value_string FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE;
ln_x_field_value_number FND_REGISTRATION_DETAILS.FIELD_VALUE_NUMBER%TYPE;
lv_x_field_value_date FND_REGISTRATION_DETAILS.FIELD_VALUE_DATE%TYPE;
lv_proc_name VARCHAR2(30) := 'SetRegItemAttrValues';

BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


IF ( funcmode = 'RUN' ) then

  lv_reg_key := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRATION_KEY', TRUE);
  IF ( lv_reg_key IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, g_log_reg_key_notfound);
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  ln_reg_id := FND_REGISTRATION_UTILS_PKG.get_reg_id_from_key(lv_reg_key);

  BEGIN
    SELECT first_name, last_name
    INTO   lv_first_name, lv_last_name
    FROM   fnd_registrations
    WHERE  registration_id = ln_reg_id;
  EXCEPTION WHEN OTHERS THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, g_log_reg_id_invalid);
    END IF;

    RAISE;
  END;

  IF ( lv_first_name IS NULL OR lv_last_name IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'First or last name is missing.');
    END IF;

    SetErrMsg(MSG_REG_DATA_MISSING);
    resultout := 'COMPLETE:ERROR';
    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'FIRST_NAME', lv_first_name);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'LAST_NAME', lv_last_name);

  -- check if the registration is from Oracle Supplier Network
  -- and set the approver role attribute
  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'OSN Request ID', lv_x_field_type, lv_x_field_format, lv_x_field_value_string, ln_x_field_value_number, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    ln_x_field_value_number := NULL;
  END;

  if (ln_x_field_value_number is not null) then
    -- this request is from OSN
    WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'IS_OSNREQUEST', 'Y');
    lv_approver_role := get_approver_role_for_osn();
  else
    WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'IS_OSNREQUEST', 'N');
  end if;

-- if this request is not from OSN, or failed to get approver role
if (ln_x_field_value_number is null
    or lv_approver_role is null) then

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'Approver ID', lv_x_field_type, lv_x_field_format, lv_x_field_value_string, ln_approver_id, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    ln_approver_id := NULL;
  END;

  IF ( ln_approver_id IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Approver ID is missing');
    END IF;

    SetErrMsg(MSG_REG_DATA_MISSING);
    resultout := 'COMPLETE:ERROR';
    RAISE NO_DATA_FOUND;
  END IF;

  BEGIN
    SELECT user_name
    INTO   lv_approver_role
    FROM   fnd_user
    WHERE  user_id = ln_approver_id;
  EXCEPTION WHEN OTHERS THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Approver ID is INVALID');
    END IF;

    RAISE;
  END;

end if; -- if this request is not from OSN, or failed to get approver role

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'APPROVER_ROLE', lv_approver_role);

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'Supplier Name', lv_x_field_type, lv_x_field_format, lv_vendor_name, ln_x_field_value_number, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    lv_vendor_name := NULL;
  END;

  --if it's an OSN request, could use trading partner when supplier is null
  IF ( lv_vendor_name IS NULL ) THEN
    BEGIN
      FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'OSN TP Name', lv_x_field_type, lv_x_field_format, lv_osn_tp_name, ln_x_field_value_number, lv_x_field_value_date);

      lv_vendor_name := lv_osn_tp_name;
    EXCEPTION WHEN OTHERS THEN
      lv_osn_tp_name := NULL;
    END;
  END IF;

  IF ( lv_vendor_name IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Vendor name is not found.');
    END IF;

    SetErrMsg(MSG_REG_DATA_MISSING);
    resultout := 'COMPLETE:ERROR';
    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'VENDOR_NAME', lv_vendor_name);

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'Note', lv_x_field_type, lv_x_field_format, lv_notes, ln_x_field_value_number, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    lv_notes := NULL;
  END;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'NOTE', lv_notes);

  lv_enterprise_name := GetEnterpriseName();
  IF ( lv_enterprise_name IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Enterprise name is not found.');
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'ENTERPRISE_NAME', lv_enterprise_name);

  lv_approval_page_url := GetApprPageURL(lv_reg_key);
  IF ( lv_approval_page_url IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Approval page URL is not found.');
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'APPROVAL_PAGE_URL', lv_approval_page_url);

  lv_logon_page_url := GetLogonPageURL('Y');
  IF ( lv_logon_page_url IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Logon page URL is NOT FOUND.');
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'LOGON_PAGE_URL', lv_logon_page_url);

  resultout := 'COMPLETE:SUCCESS';

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;

  RETURN;

END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
    END IF;

    IF ( CheckError() IS NULL ) THEN
      SetErrMsg(MSG_UNEXPECTED_ERROR);
      resultout := 'COMPLETE:ERROR';
    END IF;
    WF_CORE.CONTEXT (V_PACKAGE_NAME, 'SETREGITEMATTRVALUES', itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END SetRegItemAttrValues;

/*----------------------------------------

  public PROCEDURE SetApprvItemAttrValues

     Workflow activity function. Set item attribute values in 'USER_APPROVED'
     process.
     Following attributes are set:

       * ENTERPRISE_NAME             * LOGON_PAGE_URL
       * CONTACT_EMAIL               * IS_INVITED
       * ADHOC_USER_NAME             * REQUESTED_USER_NAME
       * REGISTRANT_EMAIL            * VENDOR_ID
       * POS_SELECTED                * PON_SELECTED
       * FIRST_NAME                  * LAST_NAME
       * REGISTRANT_TITLE            * REGISTRANT_PHONE
       * REGISTRANT_PHONE_EXT        * REGISTRANT_FAX
       * REGISTRANT_JOB_TITLE        * MIDDLE_NAME
       * SC_SELECTED

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if everything is ok.
    COMPLETE:ERROR   - if critical attribute cannot be set.

----------------------------------------*/

PROCEDURE SetApprvItemAttrValues(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS

lv_reg_key WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
ln_reg_id NUMBER;

lv_requested_user_name FND_REGISTRATIONS.REQUESTED_USER_NAME%TYPE := NULL;
lv_user_email FND_REGISTRATIONS.EMAIL%TYPE := NULL;
lv_first_name FND_REGISTRATIONS.FIRST_NAME%TYPE := NULL;
lv_last_name FND_REGISTRATIONS.LAST_NAME%TYPE := NULL;
lv_middle_name FND_REGISTRATIONS.MIDDLE_NAME%TYPE := NULL;
lv_title FND_REGISTRATIONS.USER_TITLE%TYPE := NULL;
lv_phone FND_REGISTRATIONS.PHONE%TYPE := NULL;
lv_phone_ext FND_REGISTRATIONS.PHONE_EXTENSION%TYPE := NULL;
lv_fax FND_REGISTRATIONS.FAX%TYPE := NULL;

ln_approver_id NUMBER;
lv_contact_email FND_USER.EMAIL_ADDRESS%TYPE;
lv_logon_page_url VARCHAR2(32000) := NULL;
lv_enterprise_name HZ_PARTIES.PARTY_NAME%TYPE;
lv_is_invited_flag FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE;
ln_vendor_id NUMBER;
lv_pos_flag FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE;
lv_pon_flag FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE;
lv_sc_flag FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE;
lv_notes FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE;
lv_job_title FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE;

lv_x_field_type FND_REGISTRATION_DETAILS.FIELD_TYPE%TYPE;
lv_x_field_format FND_REGISTRATION_DETAILS.FIELD_FORMAT%TYPE;
lv_x_field_value_string FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE;
ln_x_field_value_number FND_REGISTRATION_DETAILS.FIELD_VALUE_NUMBER%TYPE;
lv_x_field_value_date FND_REGISTRATION_DETAILS.FIELD_VALUE_DATE%TYPE;
lv_proc_name VARCHAR2(30) := 'SetApprvItemAttrValues';

BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


IF ( funcmode = 'RUN' ) then

  lv_reg_key := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRATION_KEY',
TRUE);
  IF ( lv_reg_key IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, g_log_reg_key_notfound);
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  ln_reg_id := FND_REGISTRATION_UTILS_PKG.get_reg_id_from_key(lv_reg_key);

  BEGIN
    SELECT requested_user_name, email, first_name, last_name, middle_name, user_title, phone, phone_extension, fax
    INTO   lv_requested_user_name, lv_user_email, lv_first_name, lv_last_name, lv_middle_name, lv_title, lv_phone, lv_phone_ext, lv_fax
    FROM   fnd_registrations
    WHERE  registration_id = ln_reg_id;
  EXCEPTION WHEN OTHERS THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, g_log_reg_id_invalid);
    END IF;

    RAISE;
  END;

  IF ( lv_requested_user_name IS NULL OR lv_user_email IS NULL OR lv_first_name IS NULL OR lv_last_name IS NULL OR lv_phone IS NULL) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Requested user name, or email, or first name, or last name, or phone is missing');
    END IF;

    SetErrMsg(MSG_REG_DATA_MISSING);
    resultout := 'COMPLETE:ERROR';
    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'REQUESTED_USER_NAME', lv_requested_user_name);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'ADHOC_USER_NAME', GetAdHocUserName(ln_reg_id));
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'REGISTRANT_EMAIL', lv_user_email);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'FIRST_NAME', lv_first_name);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'LAST_NAME', lv_last_name);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'MIDDLE_NAME', lv_middle_name);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'REGISTRANT_TITLE', lv_title);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'REGISTRANT_PHONE', lv_phone);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'REGISTRANT_PHONE_EXT', lv_phone_ext);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'REGISTRANT_FAX', lv_fax);

  lv_enterprise_name := GetEnterpriseName();
  IF ( lv_enterprise_name IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Enterprise name is not found.');
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'ENTERPRISE_NAME', lv_enterprise_name);

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'Invited Flag', lv_x_field_type, lv_x_field_format, lv_is_invited_flag, ln_x_field_value_number, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    lv_is_invited_flag := NULL;
  END;

  IF ( lv_is_invited_flag IS NULL ) THEN
    lv_is_invited_flag := 'N';
  ELSIF ( upper(substr(lv_is_invited_flag, 1, 1)) = 'Y' ) THEN
    lv_is_invited_flag := 'Y';
  ELSE
    lv_is_invited_flag := 'N';
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'IS_INVITED', lv_is_invited_flag);

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'Approver ID', lv_x_field_type, lv_x_field_format, lv_x_field_value_string, ln_approver_id, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    ln_approver_id := NULL;
  END;

  IF ( ln_approver_id IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Approver ID is missing');
    END IF;

    SetErrMsg(MSG_REG_DATA_MISSING);
    resultout := 'COMPLETE:ERROR';
    RAISE NO_DATA_FOUND;
  END IF;

  BEGIN
    SELECT email_address
    INTO   lv_contact_email
    FROM   fnd_user
    WHERE  user_id = ln_approver_id;

  EXCEPTION WHEN OTHERS THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Approver ID is INVALID');
    END IF;

    RAISE;
  END;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'CONTACT_EMAIL', lv_contact_email);

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'Supplier Number', lv_x_field_type, lv_x_field_format, lv_x_field_value_string, ln_vendor_id, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    ln_vendor_id := NULL;
  END;

  IF ( ln_vendor_id IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Vendor ID is not found.');
    END IF;

    SetErrMsg(MSG_REG_DATA_MISSING);
    resultout := 'COMPLETE:ERROR';
    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrNumber(itemtype, itemkey, 'VENDOR_ID', ln_vendor_id);

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'ISP', lv_x_field_type, lv_x_field_format, lv_pos_flag, ln_x_field_value_number, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    lv_pos_flag := NULL;
  END;

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'Sourcing', lv_x_field_type, lv_x_field_format, lv_pon_flag, ln_x_field_value_number, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    lv_pon_flag := NULL;
  END;

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'CollaborativePlanning', lv_x_field_type, lv_x_field_format, lv_sc_flag, ln_x_field_value_number, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    lv_sc_flag := NULL;
  END;

  IF ( lv_pos_flag IS NULL ) THEN
    lv_pos_flag := 'N';
  ELSIF ( upper(substr(lv_pos_flag, 1, 1)) = 'Y' ) THEN
    lv_pos_flag := 'Y';
  ELSE
    lv_pos_flag := 'N';
  END IF;

  IF ( lv_pon_flag IS NULL ) THEN
    lv_pon_flag := 'N';
  ELSIF ( upper(substr(lv_pon_flag, 1, 1)) = 'Y' ) THEN
    lv_pon_flag := 'Y';
  ELSE
    lv_pon_flag := 'N';
  END IF;

  IF ( lv_sc_flag IS NULL ) THEN
    lv_sc_flag := 'N';
  ELSIF ( upper(substr(lv_sc_flag, 1, 1)) = 'Y' ) THEN
    lv_sc_flag := 'Y';
  ELSE
    lv_sc_flag := 'N';
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'POS_SELECTED', lv_pos_flag);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'PON_SELECTED', lv_pon_flag);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'SC_SELECTED', lv_sc_flag);

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'Note', lv_x_field_type, lv_x_field_format, lv_notes, ln_x_field_value_number, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    lv_notes := NULL;
  END;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'NOTE', lv_notes);

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'Job Title', lv_x_field_type, lv_x_field_format, lv_job_title, ln_x_field_value_number, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    lv_job_title := NULL;
  END;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'REGISTRANT_JOB_TITLE', lv_job_title);

  lv_logon_page_url := GetLogonPageURL('N');
  IF ( lv_logon_page_url IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Logon page URL is NOT FOUND.');
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'LOGON_PAGE_URL', lv_logon_page_url);

  -- check if the registration is from Oracle Supplier Network
  -- and set the IS_OSNREQUEST attribute
  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'OSN Request ID', lv_x_field_type, lv_x_field_format, lv_x_field_value_string, ln_x_field_value_number, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    ln_x_field_value_number := NULL;
  END;
  if (ln_x_field_value_number is not null) then
    WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'IS_OSNREQUEST', 'Y');
  else
    WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'IS_OSNREQUEST', 'N');
  end if;

  resultout := 'COMPLETE:SUCCESS';

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;

  RETURN;

END IF;

EXCEPTION
  WHEN OTHERS THEN

     IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
     END IF;

    IF ( CheckError() IS NULL ) THEN
      SetErrMsg(MSG_UNEXPECTED_ERROR);
      resultout := 'COMPLETE:ERROR';
    END IF;
    WF_CORE.CONTEXT (V_PACKAGE_NAME, 'SETAPPRVITEMATTRVALUES', itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END SetApprvItemAttrValues;

/*----------------------------------------

  public PROCEDURE SetRjctItemAttrValues

     Workflow activity function. Set item attribute values in 'USER_REJECTED'
     process.
     Following attributes are set:

       * REGISTRANT_LANGUAGE         * IS_INVITED
       * REGISTRANT_EMAIL            * ADHOC_USER_NAME
       * ENTERPRISE_NAME             * CONTACT_EMAIL

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if everything is ok.
    COMPLETE:ERROR   - if critical attribute cannot be set.

----------------------------------------*/

PROCEDURE SetRjctItemAttrValues(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS

lv_reg_key WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
ln_reg_id NUMBER;

lv_registrant_lang FND_REGISTRATIONS.LANGUAGE_CODE%TYPE;
lv_registrant_email FND_REGISTRATIONS.EMAIL%TYPE;

lv_enterprise_name HZ_PARTIES.PARTY_NAME%TYPE;

ln_approver_id NUMBER;
lv_contact_email FND_USER.EMAIL_ADDRESS%TYPE;
lv_is_invited_flag FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE;

lv_x_field_type FND_REGISTRATION_DETAILS.FIELD_TYPE%TYPE;
lv_x_field_format FND_REGISTRATION_DETAILS.FIELD_FORMAT%TYPE;
lv_x_field_value_string FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE;
ln_x_field_value_number FND_REGISTRATION_DETAILS.FIELD_VALUE_NUMBER%TYPE;
lv_x_field_value_date FND_REGISTRATION_DETAILS.FIELD_VALUE_DATE%TYPE;
lv_proc_name VARCHAR2(30) := 'SetRjctItemAttrValues';
BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


IF ( funcmode = 'RUN' ) then

  lv_reg_key := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRATION_KEY', TRUE);
  IF ( lv_reg_key IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, g_log_reg_key_notfound);
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  ln_reg_id := FND_REGISTRATION_UTILS_PKG.get_reg_id_from_key(lv_reg_key);

  BEGIN
    SELECT NVL(language_code, 'US'), email
    INTO   lv_registrant_lang, lv_registrant_email
    FROM   fnd_registrations
    WHERE  registration_id = ln_reg_id;
  EXCEPTION WHEN OTHERS THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, g_log_reg_id_invalid);
    END IF;

    RAISE;
  END;

  IF ( lv_registrant_email IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Email is MISSING');
    END IF;

    SetErrMsg(MSG_REG_DATA_MISSING);
    resultout := 'COMPLETE:ERROR';
    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'REGISTRANT_LANGUAGE', lv_registrant_lang);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'REGISTRANT_EMAIL', lv_registrant_email);
  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'ADHOC_USER_NAME', GetAdHocUserName(ln_reg_id));

  lv_enterprise_name := GetEnterpriseName();
  IF ( lv_enterprise_name IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Enterprise name is not found.');
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'ENTERPRISE_NAME', lv_enterprise_name);

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'Invited Flag', lv_x_field_type, lv_x_field_format, lv_is_invited_flag, ln_x_field_value_number, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    lv_is_invited_flag := NULL;
  END;

  IF ( lv_is_invited_flag IS NULL ) THEN
    lv_is_invited_flag := 'N';
  ELSIF ( upper(substr(lv_is_invited_flag, 1, 1)) = 'Y' ) THEN
    lv_is_invited_flag := 'Y';
  ELSE
    lv_is_invited_flag := 'N';
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'IS_INVITED', lv_is_invited_flag);

  BEGIN
    FND_REGISTRATION_PKG.retrieve_fnd_reg_details( ln_reg_id, 'Approver ID', lv_x_field_type, lv_x_field_format, lv_x_field_value_string, ln_approver_id, lv_x_field_value_date);
  EXCEPTION WHEN OTHERS THEN
    ln_approver_id := NULL;
  END;

  IF ( ln_approver_id IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Approver ID is MISSING');
    END IF;

    SetErrMsg(MSG_REG_DATA_MISSING);
    resultout := 'COMPLETE:ERROR';
    RAISE NO_DATA_FOUND;
  END IF;

  BEGIN
    SELECT email_address
    INTO   lv_contact_email
    FROM   fnd_user
    WHERE  user_id = ln_approver_id;

  EXCEPTION WHEN OTHERS THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Approver ID is INVALID');
    END IF;

    RAISE;
  END;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'CONTACT_EMAIL', lv_contact_email);

  resultout := 'COMPLETE:SUCCESS';

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;

  RETURN;

END IF;
EXCEPTION
  WHEN OTHERS THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
    END IF;

    IF ( CheckError() IS NULL ) THEN
      SetErrMsg(MSG_UNEXPECTED_ERROR);
      resultout := 'COMPLETE:ERROR';
    END IF;
    WF_CORE.CONTEXT (V_PACKAGE_NAME, 'SETRJCTITEMATTRVALUES', itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END SetRjctItemAttrValues;

/*----------------------------------------

  public PROCEDURE CreateLocalUser

     Workflow activity function. Create a workflow ad-hoc (local) user.

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if everything is ok
    COMPLETE:ERROR   - if anything wrong

----------------------------------------*/

PROCEDURE CreateLocalUser(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS

lv_user_name WF_LOCAL_USERS.NAME%TYPE;
lv_user_email WF_LOCAL_USERS.EMAIL_ADDRESS%TYPE;
lv_user_language WF_LOCAL_USERS.LANGUAGE%TYPE;
lv_nls_lang FND_LANGUAGES.NLS_LANGUAGE%TYPE;
lv_proc_name VARCHAR2(30) := 'CreateLocalUser';

BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


IF ( funcmode = 'RUN' ) then

  lv_user_name := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'ADHOC_USER_NAME');
  lv_user_email := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRANT_EMAIL');
  lv_user_language := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRANT_LANGUAGE');

  SELECT nls_language
  INTO   lv_nls_lang
  FROM   fnd_languages
  WHERE  language_code = lv_user_language;

  /*
  * Add the notification_preference parameter in method 'CreateAdHocUser', to remove the attachment in
  * invitation mail notification. Please refer the bug 7424124 for mre info.
  */

  WF_DIRECTORY.CreateAdHocUser(	name => lv_user_name,
	                        display_name => lv_user_name,
				language => lv_nls_lang,
				notification_preference => 'MAILHTM2',
				email_address => lv_user_email);


  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, 'ad hoc user created');
  END IF;



  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, 'confirm guest user responsibility');
  END IF;


  POS_ANON_PKG.confirm_has_resp('POS_SUPPLIER_GUEST_USER');


  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, 'guest user responsibility confirmed');
  END IF;


  resultout := 'COMPLETE:SUCCESS';

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;

  RETURN;

END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF ( fnd_log.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_error,g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
    END IF;

    IF ( CheckError() IS NULL ) THEN
      SetErrMsg(MSG_UNEXPECTED_ERROR);
      resultout := 'COMPLETE:ERROR';
    END IF;
    WF_CORE.CONTEXT (V_PACKAGE_NAME, 'CREATELOCALUSER', itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END CreateLocalUser;

/*----------------------------------------

  public PROCEDURE DeleteLocalUser

     Workflow activity function. Delete a workflow ad-hoc (local) user.
     Do not raise exception. If the deletion fails, just skip it.

  PARAMS:
    WF Standard API.

  RETURN:
    WF Standard API.

----------------------------------------*/

PROCEDURE DeleteLocalUser(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS

lv_user_name WF_LOCAL_USERS.NAME%TYPE;

BEGIN

IF ( funcmode = 'RUN' ) then

  lv_user_name := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'ADHOC_USER_NAME');

  DELETE FROM wf_local_users
  WHERE       name = lv_user_name;

  resultout := 'COMPLETE';
  RETURN;

END IF;

EXCEPTION
WHEN OTHERS THEN
  RETURN;
END DeleteLocalUser;

/*----------------------------------------

  PROCEDURE AssginResp

    Assgin responsibility to user

  PARAM:
    p_user_id IN NUMBER     - the FND_USER id of the assignee
    p_resp_app_id IN NUMBER - the application id associated with the resp
    p_resp_key IN VARCHAR2  - the responsibility key

  EXCEPTION:
    none. Do not raise exception.

----------------------------------------*/
PROCEDURE AssginResp(
  p_user_id IN NUMBER
, p_resp_app_id IN NUMBER
, p_resp_key IN VARCHAR2
)
IS

lv_proc_name VARCHAR2(30) := 'AssginResp';
ln_resp_id NUMBER := NULL;

CURSOR l_resp_id_cur (p_app_id NUMBER, p_resp_key VARCHAR2) IS
	  SELECT responsibility_id
	  FROM   fnd_responsibility
	  WHERE  application_id = p_app_id
	  AND    responsibility_key = p_resp_key
	  AND    (end_date IS NULL OR end_date > start_date);

BEGIN

   OPEN l_resp_id_cur(p_resp_app_id, p_resp_key);
   FETCH l_resp_id_cur INTO ln_resp_id;
   CLOSE l_resp_id_cur;
   IF ln_resp_id IS NULL THEN

      IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' ||
		     lv_proc_name, 'Invalid responsibility key ' || p_resp_key);
      END IF;

      RETURN;
   END IF;

   FND_USER_RESP_GROUPS_API.insert_assignment
     ( user_id => p_user_id,
       responsibility_id => ln_resp_id,
       responsibility_application_id => p_resp_app_id,
       security_group_id => 0,
       start_date => sysdate,
       end_date => NULL,
       description => p_resp_key);

EXCEPTION
   WHEN OTHERS THEN

      IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' ||
		     lv_proc_name, 'Failed to assign responsibility ' ||
		     p_resp_key || '. sqlerrm: '||sqlerrm);
      END IF;

END AssginResp;

/*----------------------------------------

  PROCEDURE SetSecAttr

    Set security atttribute to the user.

  PARAM:
    p_user_id IN NUMBER          - the FND_USER id of the assignee
    p_attribute_code IN VARCHAR2 - the security attribute code
    p_app_id IN NUMBER           - the application id associated with the
				   security code
    p_varchar2_value IN VARCHAR2 - the VARCHAR2 value DEFAULT NULL
    p_date_value IN DATE         - date value DEFAULT NULL
    p_number_value IN NUMBER     - number value DEFAULT NULL

    Note: one of the three values must be NOT NULL.

  EXCEPTION:

    Raise exceptions.

----------------------------------------*/
PROCEDURE SetSecAttr(
  p_user_id IN NUMBER
, p_attribute_code IN VARCHAR2
, p_app_id IN NUMBER
, p_varchar2_value IN VARCHAR2 DEFAULT NULL
, p_date_value IN DATE DEFAULT NULL
, p_number_value IN NUMBER DEFAULT NULL
)
IS

lv_proc_name VARCHAR2(30) := 'SetSecAttr';
lv_exception_msg VARCHAR2(4000);
lv_status VARCHAR2(30);
ln_msg_count NUMBER := 0;

BEGIN
   BEGIN
      ICX_USER_SEC_ATTR_PVT.Create_user_sec_attr
	( p_api_version_number => 1.0,
	  p_return_status => lv_status,
	  p_msg_count => ln_msg_count,
	  p_msg_data => lv_exception_msg,
	  p_web_user_id => p_user_id,
	  p_attribute_code => p_attribute_code,
	  p_attribute_appl_id =>p_app_id,
	  p_varchar2_value => p_varchar2_value,
	  p_date_value => p_date_value,
	  p_number_value => p_number_value,
	  p_created_by => fnd_global.user_id,
	  p_creation_date => sysdate,
	  p_last_updated_by => fnd_global.user_id,
	  p_last_update_date => sysdate,
	  p_last_update_login => fnd_global.login_id);
   EXCEPTION
      WHEN OTHERS THEN

	 IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	   fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' ||
			lv_proc_name, 'failed in ICX_USER_SEC_ATTR_PVT.create_user_sec_attr, sqlerrm ' || Sqlerrm);
	 END IF;

	 RAISE;
   END;

   IF lv_status = 'S' THEN
    return;
   END IF;

   IF ln_msg_count > 0 THEN

      IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name,
		     'Failed to set securing attribute for ' ||
		     ' user_id ' || p_user_id ||
		     ', attribute code ' || p_attribute_code ||
		     ', app id ' || p_app_id ||
		     ', varchar2 value ' || p_varchar2_value ||
		     ', date value ' || p_date_value ||
		     ', number value ' || p_number_value
		     );
      END IF;

   END IF;

   IF ln_msg_count = 1 THEN

      IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Error message: '||lv_exception_msg);
      END IF;

      RAISE NO_DATA_FOUND;
   ELSIF ln_msg_count > 1 THEN
      FOR l_index IN 1..fnd_msg_pub.count_msg LOOP
	 lv_exception_msg := fnd_msg_pub.get(l_index);

	 IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	   fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Error message no. ' || l_index || ': ' || lv_exception_msg);
	 END IF;

      END LOOP;
      RAISE NO_DATA_FOUND;
   END IF;
END SetSecAttr;

/*----------------------------------------

  private PROCEDURE create_resp_sec_attr_ifneeded

    Create the responsibility security attributes if it is not yet created

  PARAM:
     p_resp_id          IN NUMBER    - responsibility id
     p_resp_appl_id     IN NUMBER    - responsibility application  id
     p_sec_attr_code    IN VARCHAR2  - security attribute code
     p_sec_attr_appl_id IN NUMBER    - security attribute application id

  EXCEPTION:

    Raise exceptions.

----------------------------------------*/

PROCEDURE create_resp_sec_attr_ifneeded
  (p_resp_id          IN NUMBER,
   p_resp_appl_id     IN NUMBER,
   p_sec_attr_code    IN VARCHAR2,
   p_sec_attr_appl_id IN NUMBER
   )
  IS
     CURSOR l_cur IS
	SELECT 1
	  FROM ak_resp_security_attributes
	  WHERE responsibility_id = p_resp_id AND
	  resp_application_id = p_resp_appl_id AND
	  attribute_code = p_sec_attr_code AND
	  attribute_application_id = p_sec_attr_appl_id;
     l_num NUMBER;
     lv_proc_name VARCHAR2(30) := 'create_resp_sec_attr_ifneeded';

BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_num;
   IF l_cur%found THEN
      CLOSE l_cur;

      IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, 'Responsibility Security Attribute for resp_id=' || p_resp_id || ' and attribute_code=' || p_sec_attr_code || ' exists.');
      END IF;

      RETURN;
   END IF;
   CLOSE l_cur;
   --

   IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, 'Creating Responsibility Security Attribute for resp_id=' || p_resp_id || ' and attribute_code=' || p_sec_attr_code);
   END IF;


   INSERT INTO ak_resp_security_attributes
     (responsibility_id,
      resp_application_id,
      attribute_code,
      attribute_application_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
      )
     VALUES
     (p_resp_id,
      p_resp_appl_id,
      p_sec_attr_code,
      p_sec_attr_appl_id,
      fnd_global.user_id,
      Sysdate,
      fnd_global.user_id,
      Sysdate,
      fnd_global.login_id
      );


   IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, 'Responsibility Security Attribute created');
   END IF;


EXCEPTION
  WHEN OTHERS THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
    END IF;

    IF ( CheckError() IS NULL ) THEN
      SetErrMsg(MSG_UNEXPECTED_ERROR);
    END IF;
    RAISE;
END create_resp_sec_attr_ifneeded;

/*----------------------------------------

  private PROCEDURE set_resp_sec_attrval_ifneeded

    Set the responsibility security attributes value if it is not yet set

  PARAM:
     p_resp_id          IN NUMBER    - responsibility id
     p_resp_appl_id     IN NUMBER    - responsibility application  id
     p_sec_attr_code    IN VARCHAR2  - security attribute code
     p_sec_attr_appl_id IN NUMBER    - security attribute application id
     p_varchar2_value   IN VARCHAR2 DEFAULT NULL - the varchar2 value
     p_date_value       IN DATE DEFAULT NULL     - the data value
     p_number_value     IN NUMBER DEFAULT NULL   - the number value

  EXCEPTION:

    Raise exceptions.

----------------------------------------*/

PROCEDURE set_resp_sec_attrval_ifneeded
  (p_resp_id          IN NUMBER,
   p_resp_appl_id     IN NUMBER,
   p_sec_attr_code    IN VARCHAR2,
   p_sec_attr_appl_id IN NUMBER,
   p_varchar2_value   IN VARCHAR2 DEFAULT NULL,
   p_date_value       IN DATE DEFAULT NULL,
   p_number_value     IN NUMBER DEFAULT NULL
   )
  IS
     CURSOR l_cur IS
	SELECT 1
	  FROM ak_resp_security_attr_values
	  WHERE responsibility_id = p_resp_id AND
	  resp_application_id = p_resp_appl_id AND
	  attribute_code = p_sec_attr_code AND
	  attribute_application_id = p_sec_attr_appl_id;
     l_num NUMBER;
     lv_proc_name VARCHAR2(30) := 'set_resp_sec_attrval_ifneeded';

BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_num;
   IF l_cur%found THEN
      CLOSE l_cur;

      IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, 'No need to set Responsibility Security Attribute value for resp_id=' || p_resp_id || ' and attribute_code=' || p_sec_attr_code);
      END IF;

      RETURN;
   END IF;
   CLOSE l_cur;
   --

   IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, 'Setting Responsibility Security Attribute value for resp_id=' || p_resp_id || ' and attribute_code=' || p_sec_attr_code);
   END IF;


   INSERT INTO ak_resp_security_attr_values
     (responsibility_id,
      resp_application_id,
      attribute_code,
      attribute_application_id,
      varchar2_value,
      date_value,
      number_value
      )
     VALUES
     (p_resp_id,
      p_resp_appl_id,
      p_sec_attr_code,
      p_sec_attr_appl_id,
      p_varchar2_value,
      p_date_value,
      p_number_value
      );


   IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, 'Responsibility Security Attribute value set');
   END IF;


EXCEPTION
  WHEN OTHERS THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
    END IF;

    IF ( CheckError() IS NULL ) THEN
      SetErrMsg(MSG_UNEXPECTED_ERROR);
    END IF;
    RAISE;
END set_resp_sec_attrval_ifneeded;

/*----------------------------------------

   PROCEDURE check_isp_resp_sec_attr

    This procedure will create iSP securing attributes
    (ICX_SUPPLIER_ORG_ID, ICX_SUPPLIER_SITE_ID, ICX_SUPPLIER_CONTACT_ID)
    for the responsibility, if they are not defined. It will also
    set the default value (-9999) for the securing attributes
    ICX_SUPPLIER_SITE_ID and ICX_SUPPLIER_CONTACT_ID for the responsibility,
    if they are not defined.

  PARAM:
     p_resp_id          IN NUMBER    - responsibility id
     p_resp_appl_id     IN NUMBER    - responsibility application  id

  EXCEPTION:

    Raise exceptions.

----------------------------------------*/

PROCEDURE check_isp_resp_sec_attr
  (p_resp_id      IN NUMBER,
   p_resp_appl_id IN NUMBER)
  IS
     CURSOR l_app_id_cur IS
	SELECT application_id
	  FROM   fnd_application
	  WHERE  application_short_name = 'POS';
     l_isp_appl_id NUMBER;
     lv_proc_name VARCHAR2(30) := 'set_resp_sec_attrval_ifneeded';

BEGIN
   OPEN l_app_id_cur;
   FETCH l_app_id_cur INTO l_isp_appl_id;
   IF l_app_id_cur%notfound THEN
      CLOSE l_app_id_cur;

      IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'Application ID for POS is not found');
      END IF;

      RAISE NO_DATA_FOUND;
   END IF;
   CLOSE l_app_id_cur;
   --
   -- only create the attribute, not set default value
   -- because we do want the value be set at the user level for ICX_SUPPLIER_ORG_ID
   create_resp_sec_attr_ifneeded(p_resp_id          => p_resp_id,
				 p_resp_appl_id     => p_resp_appl_id,
				 p_sec_attr_code    => 'ICX_SUPPLIER_ORG_ID',
				 p_sec_attr_appl_id => l_isp_appl_id
				 );
   --
   create_resp_sec_attr_ifneeded(p_resp_id          => p_resp_id,
				 p_resp_appl_id     => p_resp_appl_id,
				 p_sec_attr_code    => 'ICX_SUPPLIER_SITE_ID',
				 p_sec_attr_appl_id => l_isp_appl_id
				 );
   --
   set_resp_sec_attrval_ifneeded(p_resp_id          => p_resp_id,
				 p_resp_appl_id     => p_resp_appl_id,
				 p_sec_attr_code    => 'ICX_SUPPLIER_SITE_ID',
				 p_sec_attr_appl_id => l_isp_appl_id,
				 p_varchar2_value   => NULL,
				 p_date_value       => NULL,
				 p_number_value     => pos_default_sec_attr_value
				 );
   --
   create_resp_sec_attr_ifneeded(p_resp_id          => p_resp_id,
				 p_resp_appl_id     => p_resp_appl_id,
				 p_sec_attr_code    => 'ICX_SUPPLIER_CONTACT_ID',
				 p_sec_attr_appl_id => l_isp_appl_id
				 );
   --
   set_resp_sec_attrval_ifneeded(p_resp_id          => p_resp_id,
				 p_resp_appl_id     => p_resp_appl_id,
				 p_sec_attr_code    => 'ICX_SUPPLIER_CONTACT_ID',
				 p_sec_attr_appl_id => l_isp_appl_id,
				 p_varchar2_value   => NULL,
				 p_date_value       => NULL,
				 p_number_value     => pos_default_sec_attr_value
				 );
EXCEPTION
  WHEN OTHERS THEN
    IF ( CheckError() IS NULL ) THEN
      SetErrMsg(MSG_UNEXPECTED_ERROR);
    END IF;
    RAISE;
END check_isp_resp_sec_attr;

/*----------------------------------------

   PROCEDURE check_isp_resp_sec_attr

    Overload check_isp_resp_sec_attr(NUMBER, NUMBER) to take the responsibility
    key.

  PARAM:
     p_resp_key         IN VARCHAR2  - the responsibility key
     p_resp_appl_id     IN NUMBER    - responsibility application  id

  EXCEPTION:

    Raise exceptions.

----------------------------------------*/

PROCEDURE check_isp_resp_sec_attr
  (p_resp_key     IN VARCHAR2,
   p_resp_appl_id IN NUMBER)
  IS
     lv_proc_name VARCHAR2(30) := 'check_isp_resp_sec_attr';
     ln_resp_id NUMBER;
     --
     CURSOR l_resp_id_cur (p_appl_id NUMBER, p_resp_key VARCHAR2) IS
	SELECT responsibility_id
	  FROM   fnd_responsibility
	  WHERE  application_id = p_appl_id
	  AND    responsibility_key = p_resp_key
	  AND    (end_date IS NULL OR end_date > start_date);
BEGIN
   OPEN l_resp_id_cur(p_resp_appl_id, p_resp_key);
   FETCH l_resp_id_cur INTO ln_resp_id;
   CLOSE l_resp_id_cur;
   IF ln_resp_id IS NULL THEN

      IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' ||
		     lv_proc_name, 'Invalid responsibility key ' || p_resp_key);
      END IF;

      RETURN;
   END IF;
   --
   check_isp_resp_sec_attr(ln_resp_id, p_resp_appl_id);
END check_isp_resp_sec_attr;

/*----------------------------------------

  public PROCEDURE CreateUser

     Workflow activity function. Actually create the user in FND_USER.
     Following activities are done:
       * generate random user password
       * insert FND_USER
       * insert TCA
       * assign user responsibility
       * set user security attributes

     Two item attribute values are set:

       * ASSIGNED_USER_NAME                * FIRST_LOGON_KEY

  PARAMS:
    WF Standard API.

  RETURN:
    WF Standard API.

----------------------------------------*/

PROCEDURE CreateUser(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS

lv_reg_key WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
ln_reg_id NUMBER := -1;

-- user info needed to update FND_USER and TCA

lv_user_name FND_USER.USER_NAME%TYPE;
lv_unencrypted_password VARCHAR2(30);

--OSN: the encrypted initial password
l_encrypted_initial_password VARCHAR2(240);
l_retcode VARCHAR2(1);

lv_user_description FND_USER.DESCRIPTION%TYPE;
lv_user_email FND_USER.EMAIL_ADDRESS%TYPE;
ln_vendor_id NUMBER;
lv_user_firstname WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
lv_user_lastname WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
lv_user_middlename WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
lv_title WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
lv_phone WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
lv_phone_ext WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
lv_fax WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;
lv_job_title WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE;

ln_user_fnd_id NUMBER := -1;
ln_pon_app_id NUMBER := -1;
ln_pos_app_id NUMBER := -1;
lv_is_pos_selected VARCHAR2(1) := 'N';
lv_is_pon_selected VARCHAR2(1) := 'N';
lv_is_msc_selected VARCHAR2(1) := 'N';
lv_resp_key FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE := NULL;
ln_site_id NUMBER := -1;
ln_contact_id NUMBER := -1;
ln_resp_code VARCHAR2(240);
ln_resp_id NUMBER := -1;
ln_resp_app_id NUMBER := -1;
lvr_exception_msg VARCHAR2(4000);
lvr_status VARCHAR2(30);

lv_external_web_agent fnd_profile_option_values.profile_option_value%TYPE := NULL;
lv_ext_servlet_agent fnd_profile_option_values.profile_option_value%TYPE := NULL;

-- out parameters
ln_party_id NUMBER := -1;
ln_relationship_id NUMBER := -1;
lv_exception_msg VARCHAR2(4000);
lv_status VARCHAR2(30);
ln_msg_count NUMBER := 0;

ln_counter NUMBER := 0;
lv_proc_name VARCHAR2(30) := 'CreateUser';

CURSOR l_app_id_cur(p_app_short_name VARCHAR2) IS
   SELECT application_id
   FROM   fnd_application
   WHERE  application_short_name = p_app_short_name;

CURSOR l_site_cont_id_cur (p_reg_id NUMBER, p_field_name VARCHAR2) IS
	 SELECT field_value_number
	 FROM   fnd_registration_details
	 WHERE  registration_id = p_reg_id
	 AND    field_name like p_field_name||'%';

CURSOR l_user_resp_app_cur (p_reg_id NUMBER, p_field_name VARCHAR2) IS
	 SELECT field_value_string
	 FROM   fnd_registration_details
	 WHERE  registration_id = p_reg_id
	 AND    field_name like p_field_name||'%';

CURSOR l_fnd_user_cur(l_user_id IN NUMBER) IS
   SELECT * FROM fnd_user WHERE user_id = l_user_id;

l_fnd_user_rec l_fnd_user_cur%ROWTYPE;

lv_pattern   VARCHAR2(40);
lv_flag      VARCHAR2(40);


l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(3000);

l_resp_ids         po_tbl_number;
l_resp_app_ids     po_tbl_number;
l_sec_attr_codes   po_tbl_varchar30;
l_sec_attr_numbers po_tbl_number;

l_vendor_party_id NUMBER;

BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


IF ( funcmode = 'RUN' ) then

  -- retrieve user info
  lv_reg_key := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRATION_KEY',TRUE);
  IF ( lv_reg_key IS NULL ) THEN

    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, g_log_reg_key_notfound);
    END IF;

    RAISE NO_DATA_FOUND;
  END IF;

  ln_reg_id := FND_REGISTRATION_UTILS_PKG.get_reg_id_from_key(lv_reg_key);

  lv_user_name := upper(WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REQUESTED_USER_NAME'));
  lv_user_email := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRANT_EMAIL');
  lv_user_firstname := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'FIRST_NAME');
  lv_user_lastname := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'LAST_NAME');
  lv_user_middlename := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'MIDDLE_NAME');
  ln_vendor_id := WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'VENDOR_ID');
  lv_title := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRANT_TITLE');
  lv_phone := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRANT_PHONE');
  lv_phone_ext := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRANT_PHONE_EXT');
  lv_fax := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRANT_FAX');
  lv_job_title := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'REGISTRANT_JOB_TITLE');
  lv_is_pos_selected := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'POS_SELECTED');
  lv_is_pon_selected := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'PON_SELECTED');
  lv_is_msc_selected := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'SC_SELECTED');

  -- password generation

  -- OSN: retrieve initial pwd set from OSN request, only when
  -- the initial password is not set do we generate user pwd.
  BEGIN
         l_encrypted_initial_password := NULL;

	 SELECT field_value_string
	 INTO   l_encrypted_initial_password
	 FROM   fnd_registration_details
	 WHERE  registration_id = ln_reg_id
	 AND    field_name  = 'Initial Pass';

	 lv_unencrypted_password := decrypt (
                                   lv_reg_key,
	                           l_encrypted_initial_password
                                   );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --if Initial Pass not found, then it's not an OSN request
	 l_encrypted_initial_password := NULL;
         lv_unencrypted_password := NULL;
  END;

  IF lv_unencrypted_password IS NULL THEN
    lv_unencrypted_password := pos_password_util_pkg.generate_user_pwd();
  END IF;

  IF lv_unencrypted_password IS NULL THEN
    lv_unencrypted_password := fnd_crypto.smallrandomnumber();

    IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'unable to generate password');
    END IF;

  END IF;

  --insert FND_USER
  BEGIN

    SELECT 1
    INTO   ln_counter
    FROM   fnd_user
    WHERE  user_name = lv_user_name
    AND    ROWNUM = 1;

    SetErrMsg(MSG_FND_USER_DUPLICATE);
    resultout := 'COMPLETE:ERROR';
    RAISE TOO_MANY_ROWS;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       NULL; -- good. to create user later

    WHEN OTHERS THEN

      IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.selectfnduser', Sqlerrm);
      END IF;

      IF ( CheckError() IS NULL ) THEN
        SetErrMsg(MSG_USER_CREATION_FAIL);
        resultout := 'COMPLETE:ERROR';
      END IF;
      RAISE;
  END;

  -- Create User Party in TCA

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'Creating vendor user');
  END IF;

  SELECT party_id INTO l_vendor_party_id FROM po_vendors WHERE vendor_id = ln_vendor_id;

  pos_supp_contact_pkg.create_supplier_contact
    (p_vendor_party_id => l_vendor_party_id,
     p_first_name      => lv_user_firstname,
     p_last_name       => lv_user_lastname,
     p_middle_name     => NULL,
     p_contact_title   => NULL,
     p_job_title       => NULL,
     p_phone_area_code => NULL,
     p_phone_extension => NULL,
     p_fax_area_code   => NULL,
     p_fax_number      => NULL,
     p_email_address   => lv_user_email,
     x_return_status   => l_return_status,
     x_msg_count       => l_msg_count,
     x_msg_data        => l_msg_data,
     x_person_party_id => ln_party_id
     );

  IF l_return_status IS NULL OR l_return_status <> fnd_api.g_ret_sts_success THEN

     IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'POS_VENDOR_UTIL_PKG error message: '||lv_exception_msg);
     END IF;

     SetErrMsg(MSG_VENDORUSER_CREATION_FAIL);
     resultout := 'COMPLETE:ERROR';
    -- hack!!! just to raise an exception
     RAISE NO_DATA_FOUND;
  END IF;


  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'Vendor user created');
  END IF;

  pos_user_admin_pkg.create_supplier_user_account
    (p_user_name       	 => lv_user_name,
     p_user_email      	 => lv_user_email,
     p_person_party_id 	 => ln_party_id,
     p_resp_ids        	 => l_resp_ids,
     p_resp_app_ids    	 => l_resp_app_ids,
     p_sec_attr_codes  	 => l_sec_attr_codes,
     p_sec_attr_numbers  => l_sec_attr_numbers,
     p_password        	 => lv_unencrypted_password,
     x_return_status   	 => l_return_status,
     x_msg_count       	 => l_msg_count,
     x_msg_data        	 => l_msg_data,
     x_user_id         	 => ln_user_fnd_id,
     x_password        	 => lv_unencrypted_password
     );

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'Creating vendor user details');
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'ASSIGNED_USER_NAME', upper(lv_user_name));

  WF_ENGINE.SetItemAttrText(itemtype, itemkey, 'FIRST_LOGON_KEY', lv_unencrypted_password);

  -- get application ids
  OPEN l_app_id_cur('POS');
  FETCH l_app_id_cur INTO ln_pos_app_id;
  CLOSE l_app_id_cur;

  OPEN l_app_id_cur('PON');
  FETCH l_app_id_cur INTO ln_pon_app_id;
  CLOSE l_app_id_cur;

  -- Set user Responsibility


    IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'Setting user responsibility');
    END IF;

    OPEN l_user_resp_app_cur(ln_reg_id, 'POS_SUPPLIER_RESP_ID');
    ln_counter := 0;
    LOOP

    FETCH l_user_resp_app_cur INTO ln_resp_code;
	EXIT WHEN l_user_resp_app_cur%NOTFOUND;
	BEGIN
       -- Break the string into numbers
       ln_resp_id := TO_NUMBER(SUBSTR(ln_resp_code, 0, INSTR(ln_resp_code, ':') - 1));
       ln_resp_app_id := TO_NUMBER(SUBSTR(ln_resp_code, INSTR(ln_resp_code, ':') + 1));
       POS_USER_ADMIN_PKG.grant_user_resp(ln_user_fnd_id, ln_resp_id, ln_resp_app_id, lvr_status, lvr_exception_msg);
       IF ln_resp_app_id = ln_pos_app_id THEN
	  check_isp_resp_sec_attr(ln_resp_id,ln_resp_app_id);
       END IF;
       ln_counter := ln_counter + 1;
	EXCEPTION
	   WHEN OTHERS THEN
	      SetErrMsg(MSG_USER_RESP_FAIL);
	      resultout := 'COMPLETE:ERROR';
	      RAISE;
	END;
    END LOOP;
    CLOSE l_user_resp_app_cur;

    -- set supplier security attribute


    IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'Setting supplier security attribute');
    END IF;

     BEGIN
        --SetSecAttr(ln_user_fnd_id, 'ICX_SUPPLIER_ORG_ID', ln_pos_app_id, NULL, NULL, ln_vendor_id);

        OPEN l_site_cont_id_cur(ln_reg_id, 'POS_SUPPLIER_ID');
        ln_counter := 0;
        LOOP
	        FETCH l_site_cont_id_cur INTO ln_site_id;
    	    EXIT WHEN l_site_cont_id_cur%NOTFOUND;
	        BEGIN
	            SetSecAttr(ln_user_fnd_id, 'ICX_SUPPLIER_ORG_ID', ln_pos_app_id, NULL, NULL, ln_site_id);
            END;
        END LOOP;
        CLOSE l_site_cont_id_cur;
        EXCEPTION
           	WHEN OTHERS THEN
           	  SetErrMsg(MSG_POS_SUPP_SECATTR_FAIL);
              resultout := 'COMPLETE:ERROR';
    	    RAISE;
     END;


     IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'Supplier security attribute set');
     END IF;


     -- set site security attribute

     IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'Setting site security attribute');
     END IF;

     OPEN l_site_cont_id_cur(ln_reg_id, 'POS_SUPPLIER_SITE_ID');
     ln_counter := 0;
     LOOP
	FETCH l_site_cont_id_cur INTO ln_site_id;
	EXIT WHEN l_site_cont_id_cur%NOTFOUND;
	BEGIN
	   SetSecAttr(ln_user_fnd_id, 'ICX_SUPPLIER_SITE_ID', ln_pos_app_id, NULL, NULL, ln_site_id);
	   ln_counter := ln_counter + 1;
	EXCEPTION
	   WHEN OTHERS THEN
	      SetErrMsg(MSG_POS_SITE_SECATTR_FAIL);
	      resultout := 'COMPLETE:ERROR';
	      RAISE;
	END;
     END LOOP;
     CLOSE l_site_cont_id_cur;


     IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'Site security attribute set');
     END IF;


     -- set contact security attribute

     IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'Setting contact security attribute');
     END IF;

     OPEN l_site_cont_id_cur(ln_reg_id, 'POS_SUPPLIER_CONTACT_ID');
     ln_counter := 0;
     LOOP
	FETCH l_site_cont_id_cur INTO ln_contact_id;
	EXIT WHEN l_site_cont_id_cur%NOTFOUND;
	BEGIN
	   SetSecAttr(ln_user_fnd_id, 'ICX_SUPPLIER_CONTACT_ID', ln_pos_app_id, NULL, NULL, ln_contact_id);
           ln_counter := ln_counter + 1;
	EXCEPTION
	   WHEN OTHERS THEN
	      SetErrMsg(MSG_POS_CONTACT_SECATTR_FAIL);
	      resultout := 'COMPLETE:ERROR';
	      RAISE;
	END;
     END LOOP;
     CLOSE l_site_cont_id_cur;


     IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'Contact security attribute set');
     END IF;


  -- set user level APPS_WEB_AGENT profile option value
  set_profile_opt_ext_user(p_userid => ln_user_fnd_id);

  --OSN: need to set the profile to identify this user as a local user
  IF l_encrypted_initial_password IS NOT NULL THEN
      IF ( fnd_profile.save(
                       X_NAME               => 'APPS_SSO_LOCAL_LOGIN',
		       -- 'Applications SSO Login Types' (Both/Local/SSO)
		       X_VALUE              => 'Local',
		       X_LEVEL_NAME         => 'USER',
		       X_LEVEL_VALUE        => to_char(ln_user_fnd_id),
		       X_LEVEL_VALUE_APP_ID => NULL) )  THEN
            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_SSO_LOCAL_LOGIN profile option value set');
            END IF;
      ELSE
            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_SSO_LOCAL_LOGIN profile option value fail');
            END IF;
      END IF;
  END IF;

  resultout := 'COMPLETE:SUCCESS';

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;

  RETURN;

END IF; -- funcmode = 'RUN'

EXCEPTION
   WHEN OTHERS THEN

      IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', Sqlerrm);
      END IF;

      IF ( CheckError() IS NULL ) THEN
	 SetErrMsg(MSG_UNEXPECTED_ERROR);
	 resultout := 'COMPLETE:ERROR';
      END IF;
      WF_CORE.CONTEXT (V_PACKAGE_NAME, 'CREATEUSER', itemtype, itemkey, to_char(actid), funcmode);
      RAISE;
END CreateUser;


/*---------------------------------------

public
Procedure to set profile options for external user.
This procedure set the APPS_FRAMEWORK_AGENT and
APPS_WEB_AGENT for external user

*/

PROCEDURE set_profile_opt_ext_user
(p_userid in number)
is
lv_external_web_agent fnd_profile_option_values.profile_option_value%TYPE := NULL;
lv_ext_servlet_agent fnd_profile_option_values.profile_option_value%TYPE := NULL;
lv_pattern   VARCHAR2(40);
lv_flag      VARCHAR2(40);
lv_proc_name VARCHAR2(30) := 'set_profile_opt_ext_user';
begin

  fnd_profile.get('POS_EXTERNAL_URL', lv_external_web_agent);
  fnd_profile.get('POS_EXTERNAL_URL', lv_ext_servlet_agent);

  IF ( lv_external_web_agent IS NOT NULL ) THEN

     lv_pattern := '/pls';
     lv_flag    := ''; -- we want it to be case sensitive for now.
     If (owa_pattern.match(lv_external_web_agent,lv_pattern, lv_flag)) then
        -- The external profile still points to icx web site.

        IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'Setting user level APPS_WEB_AGENT profile option value');
        END IF;

        IF ( fnd_profile.save( x_name => 'APPS_WEB_AGENT',
                            x_value => lv_external_web_agent,
                            x_level_name => 'USER',
                            x_level_value => p_userid ) ) THEN

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_WEB_AGENT profile option value set');
            END IF;

        ELSE

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_WEB_AGENT profile option value fail');
            END IF;

        END IF;

        owa_pattern.change(lv_ext_servlet_agent, '/pls.*', '/oa_servlets/');
        IF ( fnd_profile.save( x_name => 'APPS_SERVLET_AGENT',
                            x_value => lv_ext_servlet_agent,
                            x_level_name => 'USER',
                            x_level_value => p_userid ) ) THEN

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_SERVLET_AGENT profile option value set');
            END IF;

        ELSE

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_SERVLET_AGENT profile option value fail');
            END IF;

        END IF;

        owa_pattern.change(lv_ext_servlet_agent, '/oa_servlets.*', '');
        IF ( fnd_profile.save( x_name => 'APPS_FRAMEWORK_AGENT',
                            x_value => lv_ext_servlet_agent,
                            x_level_name => 'USER',
                            x_level_value => p_userid ) ) THEN

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_FRAMEWORK_AGENT profile option value set');
            END IF;

        ELSE

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_FRAMEWORK_AGENT profile option value fail');
            END IF;

        END IF;
     ELSE
        IF ( fnd_profile.save( x_name => 'APPS_FRAMEWORK_AGENT',
                            x_value => lv_ext_servlet_agent,
                            x_level_name => 'USER',
                            x_level_value => p_userid ) ) THEN

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_FRAMEWORK_AGENT profile option value set');
            END IF;

        ELSE

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_FRAMEWORK_AGENT profile option value fail');
            END IF;

        END IF;
        -- set only the framework agent. there is no way to set web agent
        -- as we dont know the external dbc name.
        lv_ext_servlet_agent := lv_ext_servlet_agent || '/oa_servlets';
        IF ( fnd_profile.save( x_name => 'APPS_SERVLET_AGENT',
                            x_value => lv_ext_servlet_agent,
                            x_level_name => 'USER',
                            x_level_value => p_userid ) ) THEN

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_servlet_AGENT profile option value set');
            END IF;

        ELSE

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_servlet_AGENT profile option value fail');
            END IF;

        END IF;
     End if;

  ELSE

     IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'POS_EXTERNAL_URL is not set');
     END IF;

  END IF;


end set_profile_opt_ext_user;


/*----------------------------------------

  public PROCEDURE IsInvited

     Workflow activity function. Check whether the registration is invited.

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:Y - if the registration is invited;
    COMPLETE:N - otherwise

----------------------------------------*/

PROCEDURE IsInvited(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS

lv_invitation_flag VARCHAR2(30) := NULL;
lv_proc_name VARCHAR2(30) := 'IsInvited';

BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


IF ( funcmode = 'RUN' ) then

  lv_invitation_flag := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'IS_INVITED');

  IF ( lv_invitation_flag IS NOT NULL AND lv_invitation_flag = 'Y') THEN
    resultout := 'COMPLETE:Y';
  ELSE
    resultout := 'COMPLETE:N';
  END IF;
END IF;

IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
END IF;

RETURN;

EXCEPTION
WHEN OTHERS THEN
  -- do not raise exception. if something wrong, just assume non-invitation

  IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', sqlerrm);
  END IF;

  resultout := 'COMPLETE:N';
  RETURN;
END IsInvited;

/*----------------------------------------

  public PROCEDURE CheckRejectMailSent

     Workflow activity function. Check whether the rejection email has been
     sent or not

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:Y - if the mail has been sent
    COMPLETE:N - otherwise

----------------------------------------*/

PROCEDURE CheckRejectMailSent(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS
lv_proc_name VARCHAR2(30) := 'CheckRejectMailSent';
BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


IF ( funcmode = 'RUN' ) then

  SELECT DECODE(wn.mail_status, 'MAIL', 'COMPLETE:N', 'COMPLETE:Y')
  INTO   resultout
  FROM   wf_item_activity_statuses_v ws, wf_notifications wn
  WHERE  ws.item_type = itemtype
  AND    ws.item_key  = itemkey
  AND    ws.notification_id = wn.notification_id;

  RETURN;

END IF;


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
END IF;


EXCEPTION WHEN OTHERS THEN
  -- do not raise exception. if something wrong, just assume 'SENT'

  IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', sqlerrm);
  END IF;

  resultout := 'COMPLETE:Y';
  RETURN;
END CheckRejectMailSent;

/*----------------------------------------

  public PROCEDURE MarkSuccess

     Workflow activity function. Mark the success of this workflow process
     by pushing "success" message.

  PARAMS:
    WF Standard API.

  RETURN:
    WF Standard API.

----------------------------------------*/

PROCEDURE MarkSuccess(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS

lv_proc_name VARCHAR(30) := 'MarkSuccess';

BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


IF ( funcmode = 'RUN' ) then

  SetErrMsg(FND_REGISTRATION_UTILS_PKG.EVENT_SUCCESS);
  resultout := 'COMPLETE';

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
  END IF;

  RETURN;
END IF;

EXCEPTION WHEN OTHERS THEN
  IF ( CheckError() IS NULL ) THEN
    SetErrMsg(MSG_UNEXPECTED_ERROR);
    resultout := 'COMPLETE';
  END IF;
  WF_CORE.CONTEXT (V_PACKAGE_NAME, 'MARKSUCCESS', itemtype, itemkey, to_char(actid), funcmode);
  RAISE;
END MarkSuccess;

function isPasswordChangeable(username in varchar2) return varchar2
is
BEGIN
    if ( fnd_sso_manager.isPasswordChangeable(username) ) then
        return 'Y';
    else
        return 'N';
    end if;
END isPasswordChangeable;


/*----------------------------------------
function set_initial_password
  set the initial password for osn
  registration request, so the user
  doesn't need to change password at
  first logon

set_initial_password needs to be called
  after the user is created
----------------------------------------*/
function set_initial_password(l_reg_id NUMBER)
  return varchar2

is
    l_user_name FND_USER.USER_NAME%TYPE;
    l_osn_req_id NUMBER;
    l_internal_id NUMBER;
    l_reg_key FND_REGISTRATIONS.REGISTRATION_KEY%TYPE;
    l_encrypted_initial_password VARCHAR2(240);
    l_initial_password VARCHAR2(30);
    l_retcode VARCHAR2(1);
begin
    l_encrypted_initial_password := NULL;
    l_initial_password := NULL;

    --r12 requirement to use centralized password management
    select r.requested_user_name, d1.field_value_number, d2.field_value_number
    into   l_user_name, l_osn_req_id, l_internal_id
    from fnd_registrations r,
         fnd_registration_details d1, fnd_registration_details d2
    where r.registration_id = l_reg_id
    and   d1.registration_id = l_reg_id
    and   d2.registration_id = l_reg_id
    and   d1.field_name = 'OSN Request ID'
    and   d2.field_name = 'OSN Request InternalID';

    l_initial_password := fnd_vault.get('POS_OSN',
                    to_char(l_osn_req_id) || '_' || to_char(l_internal_id) );

    -- to be compatible with old requests
    if (l_initial_password is NULL) then
      select d.field_value_string, r.requested_user_name, r.registration_key
      into   l_encrypted_initial_password, l_user_name, l_reg_key
      from   fnd_registration_details d, fnd_registrations r
      where  r.registration_id = l_reg_id
      and  d.registration_id = l_reg_id
      and    d.field_name  = 'Initial Pass';

      l_initial_password := decrypt (
                              l_reg_key,
                              l_encrypted_initial_password
                              );
    end if;

    if (l_initial_password is NULL) then
        return 'N';
    end if;

    --call fnd_web_sec.change_password: the same routine
    --when user first time logon and change his/her password
    l_retcode := fnd_web_sec.change_password (
                              l_user_name,
                              l_initial_password
                              );

    fnd_vault.del('POS_OSN',
                  to_char(l_osn_req_id) || '_' || to_char(l_internal_id) );

    return l_retcode;
exception
    when others then
      return 'N';
end set_initial_password;

/*----------------------------------------

  public PROCEDURE IsOsnRequest

     Workflow activity function. Check whether the registration is
     from Oracle Supplier Network.

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:Y - if the registration is from OSN;
    COMPLETE:N - otherwise

----------------------------------------*/

PROCEDURE IsOsnRequest(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
)
IS

lv_osnrequest_flag VARCHAR2(30) := NULL;
lv_proc_name VARCHAR2(30) := 'IsOsnRequest';

BEGIN


IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_start);
END IF;


IF ( funcmode = 'RUN' ) then

  lv_osnrequest_flag := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'IS_OSNREQUEST');

  IF ( lv_osnrequest_flag IS NOT NULL AND lv_osnrequest_flag = 'Y') THEN
    resultout := 'COMPLETE:Y';
  ELSE
    resultout := 'COMPLETE:N';
  END IF;
END IF;

IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name, g_log_proc_end);
END IF;

RETURN;

EXCEPTION
WHEN OTHERS THEN
  -- do not raise exception. if something's wrong, just assume non-osnrequest

  IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name || '.exception', sqlerrm);
  END IF;

  resultout := 'COMPLETE:N';
  RETURN;
END IsOsnRequest;

END POS_REG_WF_PKG;


/
