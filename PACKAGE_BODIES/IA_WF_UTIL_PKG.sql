--------------------------------------------------------
--  DDL for Package Body IA_WF_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IA_WF_UTIL_PKG" AS
/* $Header: IAWFUTLB.pls 120.0 2005/06/03 23:54:27 appldev noship $   */

----------------------------------------------------------
FUNCTION ApplicationShortName return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'IA';
END;

----------------------------------------------------------
FUNCTION ProfileDebugMode return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'IA_PRINT_DEBUG';
END;

----------------------------------------------------------
FUNCTION ProfileRuleID return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'IA_SELF_SERVICE_RULE_ID';
END;

----------------------------------------------------------
FUNCTION ProfileSystemAdministrator return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'IA_SYSTEM_ADMINISTRATOR_NAME';
END;

----------------------------------------------------------
FUNCTION RequestTypeAssetList return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'ASSETLIST';
END;

----------------------------------------------------------
FUNCTION RequestTypeTransfer return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'TRANSFER';
END;

----------------------------------------------------------
FUNCTION RequestTypeRetire return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'RETIRE';
END;

----------------------------------------------------------
FUNCTION ApprovalStatusSubmitted return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'SUBMITTED';
END;

----------------------------------------------------------
FUNCTION ApprovalStatusPendingApproval return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'PENDING';
END;

----------------------------------------------------------
FUNCTION ApprovalStatusApproved return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'APPROVED';
END;

----------------------------------------------------------
FUNCTION ApprovalStatusFinallyApproved return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'FINAL_APPROVED';
END;

----------------------------------------------------------
FUNCTION ApprovalStatusDelegated return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'DELEGATED';
END;

----------------------------------------------------------
FUNCTION ApprovalStatusRejected return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'REJECTED';
END;

----------------------------------------------------------
FUNCTION HeaderStatusSubmitted return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'SUBMITTED';
END;

----------------------------------------------------------
FUNCTION HeaderStatusPendingApproval return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'PENDING';
END;

----------------------------------------------------------
FUNCTION HeaderStatusApproved return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'APPROVED';
END;

----------------------------------------------------------
FUNCTION HeaderStatusRejected return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'REJECTED';
END;

----------------------------------------------------------
FUNCTION HeaderStatusPendingError return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'PENDING_ERROR';
END;

----------------------------------------------------------
FUNCTION HeaderStatusPost return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'POST';
END;

----------------------------------------------------------
FUNCTION LineStatusNew return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'NEW';
END;

----------------------------------------------------------
FUNCTION LineStatusPending return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'PENDING';
END;

----------------------------------------------------------
FUNCTION LineStatusPost return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'POST';
END;

----------------------------------------------------------
FUNCTION LineStatusOnReview return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'ON_REVIEW';
END;

----------------------------------------------------------
FUNCTION LineStatusOnHold return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'ON_HOLD';
END;

----------------------------------------------------------
FUNCTION LineStatusRejected return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'REJECTED';
END;

----------------------------------------------------------
FUNCTION LineStatusPosted return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'POSTED';
END;

----------------------------------------------------------
FUNCTION RespTypeRequest return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'REQUEST_ONLY';
END;

----------------------------------------------------------
FUNCTION RespTypeAll return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'REQUEST_APPROVE';
END;

----------------------------------------------------------
FUNCTION ApprovalTypeAll return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'ALL';
END;

----------------------------------------------------------
FUNCTION ApprovalTypeReleasing return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'RELEASE';
END;

----------------------------------------------------------
FUNCTION ApprovalTypeDestination return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'RECEIVE';
END;

----------------------------------------------------------
FUNCTION ApprovalTypeNone return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'NONE';
END;

----------------------------------------------------------
FUNCTION LOVTypeReleasing return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'RELEASING';
END;

----------------------------------------------------------
FUNCTION LOVTypeDestination return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'DESTINATION';
END;

----------------------------------------------------------
FUNCTION ApprovalMethodHierarchy return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'HIERARCHY';
END;

----------------------------------------------------------
FUNCTION ApprovalMethodCostCenter return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'COST_CENTER';
END;

/*
----------------------------------------------------------
FUNCTION AME_LOV_TransactionType return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'IA_LOV_APPROVERS';
END;
*/

----------------------------------------------------------
FUNCTION AME_RELEASE_TransactionType return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'IA_RELEASE_CHAIN';
END;

----------------------------------------------------------
FUNCTION AME_RECEIVE_TransactionType return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'IA_RECEIVE_CHAIN';
END;

----------------------------------------------------------
FUNCTION HierarchyBasedRelGroup return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'IA_APPROVAL_HRCH_REL';
END;

----------------------------------------------------------
FUNCTION HierarchyBasedRecGroup return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'IA_APPROVAL_HRCH_REC';
END;

----------------------------------------------------------
FUNCTION CostCenterBasedGroup return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'IA_APPROVAL_CC';
END;

----------------------------------------------------------
FUNCTION WF_TransactionType return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'IAWF';
END;

----------------------------------------------------------
FUNCTION WF_MainProcess return VARCHAR2
----------------------------------------------------------
IS
BEGIN
  RETURN 'IA_MAIN';
END;


/*
----------------------------------------------------------
PROCEDURE RaiseException(
        p_calling_fn	IN VARCHAR2,
        p_message_name	IN VARCHAR2 DEFAULT NULL,
        p_debug_info	IN VARCHAR2 DEFAULT ''
----------------------------------------------------------
) IS
BEGIN

  if (p_message_name is not NULL) then
    FND_MESSAGE.SET_NAME('OFA', p_message_name);
  elsif (p_debug_info is not NULL) then
    FND_MESSAGE.SET_NAME('OFA', 'FA_API_SHARED_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('SQLSTMT', p_calling_fn||' : '||p_debug_info||' : '||SQLERRM);
  end if;

END RaiseException;
*/


----------------------------------------------------------
PROCEDURE InitializeServerMessage
----------------------------------------------------------
IS
BEGIN

  -- initialize server message stack.
  fa_srvr_msg.init_server_message;

END InitializeServerMessage;

----------------------------------------------------------
PROCEDURE InitializeDebugMessage
----------------------------------------------------------
IS
BEGIN

  if (IA_WF_UTIL_PKG.DebugModeEnabled) then
	-- initialize debug message stack.
	fa_debug_pkg.initialize;
        fa_srvr_msg.init_server_message;
  end if;

END InitializeDebugMessage;

----------------------------------------------------------
PROCEDURE AddDebugMessage(
        p_calling_fn	IN VARCHAR2,
        p_parameter1	IN VARCHAR2 DEFAULT '',
        p_parameter2	IN VARCHAR2 DEFAULT ''
) IS
----------------------------------------------------------
BEGIN

  if (IA_WF_UTIL_PKG.DebugModeEnabled) then
         fa_debug_pkg.add(p_calling_fn, p_parameter1, p_parameter2);
  end if;

END AddDebugMessage;

----------------------------------------------------------
PROCEDURE AddWFDebugMessage(
        p_request_id    IN VARCHAR2,
        p_calling_fn	IN VARCHAR2,
        p_parameter1	IN VARCHAR2 DEFAULT '',
        p_parameter2	IN VARCHAR2 DEFAULT ''
) IS
----------------------------------------------------------
  l_debug_info  VARCHAR2(4000);
BEGIN

  if (IA_WF_UTIL_PKG.DebugModeEnabled) then

       fa_debug_pkg.add(p_calling_fn, p_parameter1, p_parameter2);

       l_debug_info := WF_ENGINE.GetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                                                 itemkey  => p_request_id,
                                                 aname    => 'DEBUG_INFO');

       l_debug_info := '[TIMESTAMP:'|| to_char(SYSDATE,'DD-MON-YYYY HH24:MI:SS') ||', FUNCTION: '|| p_calling_fn ||', DEBUG_INFO: '||  p_parameter1 || ', REQUEST_ID: ' || p_request_id ||'] <--' || l_debug_info;

       l_debug_info := substr(l_debug_info, 1, 2000);

       WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                                 itemkey  => p_request_id,
                                 aname    => 'DEBUG_INFO',
                                 avalue   => l_debug_info);
  end if;

END AddWFDebugMessage;


----------------------------------------------------------
FUNCTION GetApplicationID return NUMBER
----------------------------------------------------------
IS

  l_application_id	NUMBER(15) := -1;

BEGIN

  if (ApplicationID is NULL) then

        SELECT  application_id
        INTO    l_application_id
        FROM    fnd_application
        WHERE   application_short_name = IA_WF_UTIL_PKG.ApplicationShortName;

        ApplicationID := l_application_id;

  else

        l_application_id := ApplicationID;

  end if;

  RETURN l_application_id;

EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return NULL;

END GetApplicationID;


----------------------------------------------------------
FUNCTION DebugModeEnabled return BOOLEAN
----------------------------------------------------------
IS

  debugMode	VARCHAR2(30) := NULL;

BEGIN

  if (DebugModeEnabledFlag is NULL) then

	fnd_profile.get(IA_WF_UTIL_PKG.ProfileDebugMode, debugMode);

  	if (debugMode = 'Y' or debugMode = 'y') then
		DebugModeEnabledFlag := TRUE;
  	else
		DebugModeEnabledFlag := FALSE;
  	end if;

  end if;

  return DebugModeEnabledFlag;


EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return FALSE;

END DebugModeEnabled;


----------------------------------------------------------
FUNCTION GetRuleID
return NUMBER
----------------------------------------------------------
IS

BEGIN

--  if (RuleID is NULL) then

	fnd_profile.get(IA_WF_UTIL_PKG.ProfileRuleID, RuleID);

--  end if;

  return RuleID;


EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return NULL;

END GetRuleID;


----------------------------------------------------------
FUNCTION GetRuleID(p_responsibility_id      IN NUMBER)
return NUMBER
----------------------------------------------------------
IS

BEGIN

--  if (RuleID is NULL) then

	RuleID := to_number(fnd_profile.value_specific(name              => IA_WF_UTIL_PKG.ProfileRuleID
                                                      ,responsibility_id => p_responsibility_id
                                                      ,application_id    => IA_WF_UTIL_PKG.GetApplicationID)
                           );

--  end if;

  return RuleID;


EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return NULL;

END GetRuleID;


----------------------------------------------------------
FUNCTION GetSystemAdministrator
return VARCHAR2
----------------------------------------------------------
IS

 l_system_admin VARCHAR2(80);

BEGIN


	fnd_profile.get(IA_WF_UTIL_PKG.ProfileSystemAdministrator, l_system_admin);


  return l_system_admin;


EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return NULL;

END GetSystemAdministrator;


----------------------------------------------------------
FUNCTION IsTransferEnabled(p_rule_id        IN NUMBER
                          ,p_book_type_code IN VARCHAR2)
return VARCHAR2
----------------------------------------------------------
IS
  localException EXCEPTION;
BEGIN

  if (TransferEnabled is NULL) then

    if (not ResetRuleSetup(p_rule_id        => p_rule_id
                          ,p_book_type_code => p_book_type_code) ) then
         raise localException;
    end if;

  end if;

  return TransferEnabled;


EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return NULL;

END IsTransferEnabled;


----------------------------------------------------------
FUNCTION IsTransactionDateAllowed(p_rule_id        IN NUMBER
                                 ,p_book_type_code IN VARCHAR2)
return VARCHAR2
----------------------------------------------------------
IS

  localException EXCEPTION;
BEGIN

  if (TransactionDateAllowed is NULL) then

    if (not ResetRuleSetup(p_rule_id        => p_rule_id
                          ,p_book_type_code => p_book_type_code) ) then
         raise localException;
    end if;

  end if;

  return TransactionDateAllowed;


EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return NULL;

END IsTransactionDateAllowed;


----------------------------------------------------------
FUNCTION GetResponsibilityType(p_rule_id        IN NUMBER
                              ,p_book_type_code IN VARCHAR2)
return VARCHAR2
----------------------------------------------------------
IS

  localException EXCEPTION;
BEGIN

  if (ResponsibilityType is NULL) then

    if (not ResetRuleSetup(p_rule_id        => p_rule_id
                          ,p_book_type_code => p_book_type_code) ) then
         raise localException;
    end if;

  end if;

  return ResponsibilityType;


EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return NULL;

END GetResponsibilityType;

----------------------------------------------------------
FUNCTION IsSuperUserApprovalRequired(p_rule_id        IN NUMBER
                                    ,p_book_type_code IN VARCHAR2)
return VARCHAR2
----------------------------------------------------------
IS

  localException EXCEPTION;
BEGIN

  if (SuperUserApprovalRequired is NULL) then

    if (not ResetRuleSetup(p_rule_id        => p_rule_id
                          ,p_book_type_code => p_book_type_code) ) then
         raise localException;
    end if;

  end if;

  return SuperUserApprovalRequired;


EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return NULL;

END IsSuperUserApprovalRequired;

----------------------------------------------------------
FUNCTION GetApprovalType(p_rule_id        IN NUMBER
                        ,p_book_type_code IN VARCHAR2)
return VARCHAR2
----------------------------------------------------------
IS

  localException EXCEPTION;
BEGIN

  if (ApprovalType is NULL) then

    if (not ResetRuleSetup(p_rule_id        => p_rule_id
                          ,p_book_type_code => p_book_type_code) ) then
         raise localException;
    end if;

  end if;

  return ApprovalType;


EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return NULL;

END GetApprovalType;

----------------------------------------------------------
FUNCTION GetApprovalMethod(p_rule_id        IN NUMBER
                          ,p_book_type_code IN VARCHAR2)
return VARCHAR2
----------------------------------------------------------
IS

  localException EXCEPTION;
BEGIN

  if (ApprovalMethod is NULL) then

    if (not ResetRuleSetup(p_rule_id        => p_rule_id
                          ,p_book_type_code => p_book_type_code) ) then
         raise localException;
    end if;


  end if;

  return ApprovalMethod;


EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return NULL;

END GetApprovalMethod;

----------------------------------------------------------
FUNCTION ResetRuleSetup(p_rule_id        IN NUMBER
                       ,p_book_type_code IN VARCHAR2)
return BOOLEAN
----------------------------------------------------------
IS

  localException EXCEPTION;
BEGIN

  select nvl(rd.enable_transfer_flag,'N')
        ,nvl(rd.allow_transaction_date_flag,'N')
        ,nvl(rd.responsibility_type,IA_WF_UTIL_PKG.RespTypeRequest)
        ,nvl(rd.require_superuser_flag,'N')
        ,nvl(rd.approval_type,IA_WF_UTIL_PKG.ApprovalTypeAll)
        ,nvl(rd.approval_method,IA_WF_UTIL_PKG.ApprovalMethodCostCenter)
  into TransferEnabled
      ,TransactionDateAllowed
      ,ResponsibilityType
      ,SuperUserApprovalRequired
      ,ApprovalType
      ,ApprovalMethod
  from ia_rule_details rd
  where rd.rule_id=p_rule_id
    and rd.book_type_code=p_book_type_code;

  return TRUE;


EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return FALSE;

END ResetRuleSetup;

----------------------------------------------------------
FUNCTION GetLookupMeaning(p_lookup_type    IN VARCHAR2
                         ,p_lookup_code    IN VARCHAR2)
return VARCHAR2
----------------------------------------------------------
IS

  l_meaning VARCHAR2(80);

  localException EXCEPTION;

BEGIN

  select flv.meaning
  into l_meaning
  from fnd_lookup_values flv
  where flv.lookup_type=p_lookup_type
    and flv.lookup_code=p_lookup_code
    and flv.view_application_id=205 -- IA application id
    and flv.language=nvl(userenv('LANG'),'US')
    and flv.security_group_id =
           fnd_global.lookup_security_group
           (flv.lookup_type
           ,flv.view_application_id
           );

  return l_meaning;


EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return NULL;

END GetLookupMeaning;


----------------------------------------------------------
FUNCTION InitializeProfile(p_user_id            IN NUMBER
                          ,p_responsibility_id  IN NUMBER)
return BOOLEAN
----------------------------------------------------------
IS

  localException EXCEPTION;

BEGIN

  FND_PROFILE.initialize(user_id_z => p_user_id
                        ,responsibility_id_z => p_responsibility_id
                        ,application_id_z => IA_WF_UTIL_PKG.GetApplicationId);

  return TRUE;

EXCEPTION
        WHEN OTHERS THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
                return FALSE;

END InitializeProfile;

END IA_WF_UTIL_PKG;

/
