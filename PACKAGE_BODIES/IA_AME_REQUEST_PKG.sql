--------------------------------------------------------
--  DDL for Package Body IA_AME_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IA_AME_REQUEST_PKG" AS
/* $Header: IAAMREQB.pls 120.0.12010000.1 2008/07/24 09:53:33 appldev ship $   */

/* Commented out due to the approach with Value Set
FUNCTION GetLOVApprovers
       (RequesterId		IN		NUMBER,
	ResponsibilityId	IN		NUMBER,
	LOVType			IN		VARCHAR2,
	BookTypeCode		IN		VARCHAR2,
	CompanyCode		IN		VARCHAR2,
	CostCenter		IN		VARCHAR2,
	ApproverTypesTable	OUT NOCOPY 	AME_UTIL.stringList,
	ApproverIdsTable	OUT NOCOPY 	AME_UTIL.stringList)
--	ApproversTable		OUT NOCOPY 	AME_UTIL.approversTable)
  return BOOLEAN
IS

* When the approvers LOVs on FWK pages are clicked, FWK calls the AME API, 'IA_AME_REQUEST_PKG.GetLOVApprovers'
 * with the following parameters provided in order to initiate the process of getting a list of approvers
 * pertinent to the setup
 *
*

  approverTypesList	AME_UTIL.stringList;
  approverIdsList	AME_UTIL.stringList;

  approvalMethod	VARCHAR2(15)	:= NULL;
  approvalGroupId	NUMBER(15)	:= -1;

  newAmeLovId		NUMBER		:= -1;

  debugInfo		VARCHAR2(255)	:= NULL;

  localException	EXCEPTION;

  callingProgram	VARCHAR2(80)	:= 'GetLOVApprovers';

BEGIN

  -- initialize error message stack.
  FA_SRVR_MSG.init_server_message;
  IA_WF_UTIL_PKG.InitializeDebugMessage;

  -----------------------------------------------------
  debugInfo := 'Validate the input values';
  -----------------------------------------------------
  if (RequesterId is NULL or
      ResponsibilityId is NULL or
      LOVType is NULL or
      BookTypeCode is NULL) then

        raise localException;

  end if;


  *
  * The AME LOV API inserts the passed on parameters into iAssets LOV interim table named 'IA_AME_LOV_T' with a new sequence
  * for unique identifier,'ame_lov_id' generated.
  * The reason why we need this interim table and a unique identifier are as follows:
  * Firstly, AME requires one single identifier to uniquely identify a record.
  * There could be a workaround for this by having a combination of request_id, book_type_code, company_code and cost_center.
  * This, however, will lead to too much complexity of implementing and maintaining the code in AME setups in the future.
  * Secondly, FWK pages will not save a record of the request details table at the stage
  * from which AME needs a value of unique identifier such as request_detail_id.
  *

  -----------------------------------------------------
  debugInfo := 'Generate a new sequence id';
  -----------------------------------------------------
  SELECT IA_AME_LOV_T_S.nextval
  INTO newAmeLovId
  FROM dual;

  -----------------------------------------------------
  debugInfo := 'Insert parameters into IA_AME_LOV_T';
  -----------------------------------------------------
  INSERT INTO IA_AME_LOV_T
              (ame_lov_id,
               requester_id,
               book_type_code,
               company_code,
               cost_center,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date)
  VALUES (newAmeLovId,
          RequesterId,
          BookTypeCode,
          CompanyCode,
          CostCenter,
          -1,
          SYSDATE,
          -1,
          SYSDATE);

  -----------------------------------------------------
  debugInfo := 'Call AME_ENGIN.initializePlsqlContext to initialize';
  -----------------------------------------------------
  AME_ENGINE.initializePlsqlContext(ameApplicationIdIn	=> null,
                                    fndApplicationIdIn	=> IA_WF_UTIL_PKG.GetApplicationID,
                                    transactionTypeIdIn	=> IA_WF_UTIL_PKG.AME_LOV_TransactionType,
                                    transactionIdIn	=> newAmeLovId);

  *
  * This step figures out what approval method to use based on the approval rule assigned to its responsibility.
  *
  -----------------------------------------------------
  debugInfo := 'Determining what approval method to use';
  -----------------------------------------------------

  approvalMethod := IA_WF_UTIL_PKG.GetApprovalMethod(IA_WF_UTIL_PKG.GetRuleID,
                                                     BookTypeCode);

  IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, approvalMethod);

--  approvalMethod := IA_WF_UTIL_PKG.ApprovalMethodHierarchy; -- DEBUG !!

  *
  * Being based on the approval method, the AME LOV API will then determine which AME approval group to use
  *
  -----------------------------------------------------
  debugInfo := 'Get corresponding approval group ID';
  -----------------------------------------------------
    -- Call Management-hierarchy based approval group
  if (approvalMethod = IA_WF_UTIL_PKG.ApprovalMethodHierarchy) then

    if (LOVType = IA_WF_UTIL_PKG.LOVTypeReleasing) then
         approvalGroupId := AME_APPROVAL_GROUP_PKG.getId(nameIn=>IA_WF_UTIL_PKG.HierarchyBasedRelGroup);
    elsif (LOVType = IA_WF_UTIL_PKG.LOVTypeDestination) then
         approvalGroupId := AME_APPROVAL_GROUP_PKG.getId(nameIn=>IA_WF_UTIL_PKG.HierarchyBasedRecGroup);
    end if;

  elsif (approvalMethod = IA_WF_UTIL_PKG.ApprovalMethodCostCenter) then
    -- Call Cost-center based approval group
    approvalGroupId := AME_APPROVAL_GROUP_PKG.getId(nameIn=>IA_WF_UTIL_PKG.CostCenterBasedGroup);

  else

    raise localException;

  end if;

  IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, approvalGroupId);

  approverTypesList := AME_UTIL.emptyStringList;
  approverIdsList := AME_UTIL.emptyStringList;

  -----------------------------------------------------
  debugInfo := 'Call corresponding approval group';
  -----------------------------------------------------
  if (approvalMethod in (IA_WF_UTIL_PKG.ApprovalMethodHierarchy
                        ,IA_WF_UTIL_PKG.ApprovalMethodCostCenter)          ) then

    AME_APPROVAL_GROUP_PKG.getRuntimeGroupMembers(groupIdIn		=> approvalGroupId,
                                                  parameterNamesOut	=> approverTypesList,
                                                  parametersOut		=> approverIdsList);

    ApproverTypesTable := approverTypesList;
    ApproverIdsTable := approverIdsList;

    if (IA_WF_UTIL_PKG.DebugModeEnabled) then

      if (approverIdsList.count > 0) then

        -----------------------------------------------------------------------
        debugInfo := 'Number of Managers: ' || approverIdsList.count;
        -----------------------------------------------------------------------
        IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'approverIdsList', debugInfo);

        for i in 1 .. approverIdsList.count loop

          -----------------------------------------------------------------------
          debugInfo := 'Managers(' || i || ').type = ' || approverTypesList(i);
          -----------------------------------------------------------------------
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'approverIdsList', debugInfo);

          -----------------------------------------------------------------------
          debugInfo := 'Managers(' || i || ').person_id = ' || approverIdsList(i);
          -----------------------------------------------------------------------
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'approverIdsList', debugInfo);

        end loop;

      end if; -- if (approverIdsList.count > 0)

    end if; -- if DebugModeEnabled

  end if; -- if approvalMethod is either ManagementHierarchyBased or CostCenterBased


  -- back to main

  return TRUE;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');

          return FALSE;

END GetLOVApprovers;
*/

/*
FUNCTION GetNextApprover
       (RequestId		IN		NUMBER,
	Approver		OUT NOCOPY 	AME_UTIL.approverRecord)
  return BOOLEAN
IS

  approverTypesList	AME_UTIL.stringList;
  approverIdsList	AME_UTIL.stringList;

  approverRecord	AME_UTIL.approverRecord;


  debugInfo		VARCHAR2(255)	:= NULL;

  localException	EXCEPTION;

  callingProgram	VARCHAR2(80)	:= 'GetNextApprover(RequestId, Approver)';

BEGIN

  -- initialize error message stack.
  -- FA_SRVR_MSG.init_server_message;
  -- IA_WF_UTIL_PKG.InitializeDebugMessage;

  *
  * This step calls AME_API.getNextApprover.
  *
  -----------------------------------------------------
  debugInfo := 'Calling AME_API.getNextApprover(RequestId, Approver)';
  -----------------------------------------------------
  IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'before', debugInfo);

  AME_API.getNextApprover(applicationIdIn => IA_WF_UTIL_PKG.GetApplicationID,
                          transactionTypeIn => IA_WF_UTIL_PKG.AME_RELEASE_TransactionType,
                          transactionIdIn => RequestId,
                          nextApproverOut => approverRecord);

  IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'after', debugInfo);

  Approver := approverRecord;

  return TRUE;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          return FALSE;

END GetNextApprover;
*/



FUNCTION GetNextApprover
       (RequestId		IN		NUMBER,
        ChainPhase              IN OUT NOCOPY   VARCHAR2,
	Approver		OUT NOCOPY 	AME_UTIL.approverRecord,
        NoMoreApproverFlag      OUT NOCOPY      VARCHAR2)
  return BOOLEAN
IS

  approverRecord	AME_UTIL.approverRecord;

  l_book_type_code      VARCHAR2(30);
  l_responsibility_id   NUMBER(15);
  l_releasing_approver_id       NUMBER(15);
  l_receiving_approver_id       NUMBER(15);
  l_rule_id             NUMBER(15);
  l_approval_type       VARCHAR2(30);
  l_approval_method     VARCHAR2(30);
  l_error_message       VARCHAR2(2000);

  l_dummy               NUMBER(15);

  l_chainPhase		VARCHAR2(30);

  debugInfo		VARCHAR2(255)	:= NULL;

  localException	EXCEPTION;

  callingProgram	VARCHAR2(80)	:= 'GetNextApprover(long format)';

BEGIN

  -- initialize error message stack.
  -- FA_SRVR_MSG.init_server_message;
  -- IA_WF_UTIL_PKG.InitializeDebugMessage;

  l_chainPhase := ChainPhase;
  NoMoreApproverFlag := 'N';


  -----------------------------------------------------
  debugInfo := 'Retrieve book type code from IA_REQUEST_HEADERS';
  -----------------------------------------------------
  begin

    select book_type_code
          ,responsibility_id
          ,releasing_approver_id
          ,receiving_approver_id
    into l_book_type_code
        ,l_responsibility_id
        ,l_releasing_approver_id
        ,l_receiving_approver_id
    from ia_request_headers
    where request_id=RequestId;

  exception
    when others then
      FND_MESSAGE.set_name('IA', 'IA_NO_REQUEST_FOUND'); -- Error: Unable to find request id, REQUEST_ID
      FND_MESSAGE.set_token('REQUEST_ID', RequestId);
      l_error_message := FND_MESSAGE.Get;
      raise localException;
  end;

  -----------------------------------------------------
  debugInfo := 'Validate Responsibility ID';
  -----------------------------------------------------
  begin

    select responsibility_id
    into l_dummy
    from fnd_responsibility
    where responsibility_id=l_responsibility_id
      and application_id=IA_WF_UTIL_PKG.GetApplicationID;

  exception
    when others then
      FND_MESSAGE.set_name('IA', 'IA_NO_RESPONSIBILITY_FOUND'); -- Error: Unable to find responsibility id, RESPONSIBILITY_ID
      FND_MESSAGE.set_token('RESPONSIBILITY_ID', l_responsibility_id);
      l_error_message := FND_MESSAGE.Get;
      raise localException;
  end;

  -----------------------------------------------------
  debugInfo := 'Get Rule ID';
  -----------------------------------------------------
  begin

    l_rule_id := IA_WF_UTIL_PKG.GetRuleID(p_responsibility_id => l_responsibility_id);

  exception
    when others then
        FND_MESSAGE.set_name('IA', 'IA_NO_RULE_ASSIGNED');
         -- Error: No rule has been defined for responsibility id, RESPONSIBILITY_ID
        FND_MESSAGE.set_token('RESPONSIBILITY_ID', l_responsibility_id);
        l_error_message := FND_MESSAGE.Get;
        raise localException;
  end;

  -----------------------------------------------------
  debugInfo := 'Initialize rule setup';
  -----------------------------------------------------
  if (not IA_WF_UTIL_PKG.ResetRuleSetup(p_rule_id        => l_rule_id,
                                        p_book_type_code => l_book_type_code) ) then
       FND_MESSAGE.set_name('IA', 'IA_RULE_RETRIEVAL_ERROR'); -- Error: Unable to find rule id, RULE_ID
       FND_MESSAGE.set_token('RULE_ID', l_rule_id);
       l_error_message := FND_MESSAGE.Get;
       raise localException;
  end if;

  -----------------------------------------------------
  debugInfo := 'Get Approval Type';
  -----------------------------------------------------
  l_approval_type := IA_WF_UTIL_PKG.GetApprovalType(p_rule_id        => l_rule_id,
                                                    p_book_type_code => l_book_type_code);

  -----------------------------------------------------
  debugInfo := 'Get Approval Method';
  -----------------------------------------------------
  l_approval_method := IA_WF_UTIL_PKG.GetApprovalMethod(p_rule_id        => l_rule_id,
                                                        p_book_type_code => l_book_type_code);


  if ( l_approval_method = IA_WF_UTIL_PKG.ApprovalMethodHierarchy ) then

    /*
    * This step calls AME_API.getNextApprover.
    */
    -----------------------------------------------------
    debugInfo := 'Calling AME_API.getNextApprover(long format)';
    -----------------------------------------------------
    IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'before', debugInfo);


    if (l_chainPhase is NULL or l_chainPhase = IA_WF_UTIL_PKG.ApprovalTypeReleasing) then

      -----------------------------------------------------
      debugInfo := 'Calling AME_API.getNextApprover for releasing chain';
      -----------------------------------------------------
      AME_API.getNextApprover(applicationIdIn => IA_WF_UTIL_PKG.GetApplicationID,
                              transactionTypeIn => IA_WF_UTIL_PKG.AME_RELEASE_TransactionType,
                              transactionIdIn => RequestId,
                              nextApproverOut => approverRecord);

      if (approverRecord.person_id is NULL) then
        l_chainPhase := IA_WF_UTIL_PKG.ApprovalTypeDestination;
      end if;

    end if;

    if (l_chainPhase = IA_WF_UTIL_PKG.ApprovalTypeDestination) then

      -----------------------------------------------------
      debugInfo := 'Calling AME_API.getNextApprover for receiving chain';
      -----------------------------------------------------
      AME_API.getNextApprover(applicationIdIn => IA_WF_UTIL_PKG.GetApplicationID,
                              transactionTypeIn => IA_WF_UTIL_PKG.AME_RECEIVE_TransactionType,
                              transactionIdIn => RequestId,
                              nextApproverOut => approverRecord);

      if (approverRecord.person_id is NULL) then
        NoMoreApproverFlag := 'Y';
      end if;

    end if;

  else

    -- The following logic will be executed when approval method is COST_CENTER.

    NoMoreApproverFlag := WF_ENGINE.GetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType
                                                   ,itemkey => RequestId
                                                   ,aname => 'NO_MORE_APPROVER_FLAG');

--    if (NoMoreApproverFlag is null or NoMoreApproverFlag = 'N') then
    if (ChainPhase = IA_WF_UTIL_PKG.ApprovalTypeReleasing ) then

      if (l_approval_type = IA_WF_UTIL_PKG.ApprovalTypeAll or
          l_approval_type = IA_WF_UTIL_PKG.ApprovalTypeReleasing) then

        if (l_chainPhase is NULL or l_chainPhase = IA_WF_UTIL_PKG.ApprovalTypeReleasing) then
          approverRecord.person_id := l_releasing_approver_id;
          l_chainPhase := IA_WF_UTIL_PKG.ApprovalTypeDestination;
         end if;

        if (l_approval_type = IA_WF_UTIL_PKG.ApprovalTypeReleasing) then
          NoMoreApproverFlag := 'Y';
        else
          NoMoreApproverFlag := 'S';
        end if;

      end if;

    elsif (NoMoreApproverFlag='Y') then

          approverRecord.person_id := null;
          l_chainPhase := IA_WF_UTIL_PKG.ApprovalTypeDestination;
          NoMoreApproverFlag := 'Y';

    else

      if (l_approval_type = IA_WF_UTIL_PKG.ApprovalTypeAll or
          l_approval_type = IA_WF_UTIL_PKG.ApprovalTypeDestination) then

          approverRecord.person_id := l_receiving_approver_id;
          l_chainPhase := IA_WF_UTIL_PKG.ApprovalTypeDestination;
          NoMoreApproverFlag := 'Y';

      end if;

    end if;

    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                              itemkey  => RequestId,
                              aname    => 'NO_MORE_APPROVER_FLAG',
                              avalue   => NoMoreApproverFlag);

  end if;

  -- return out parameters
  ChainPhase := l_chainPhase;
  Approver := approverRecord;

  IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'after', debugInfo);


  return TRUE;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          return FALSE;

END GetNextApprover;

FUNCTION GetAllApprovers
       (RequestId		IN		NUMBER,
	ReleasingApprovers	OUT NOCOPY 	AME_UTIL.approversTable,
	ReceivingApprovers	OUT NOCOPY 	AME_UTIL.approversTable)
  return BOOLEAN
IS

  approverTypesList	AME_UTIL.stringList;
  approverIdsList	AME_UTIL.stringList;

  releasingApproverRec  AME_UTIL.approverRecord;
  receivingApproverRec  AME_UTIL.approverRecord;

  l_book_type_code      VARCHAR2(30);
  l_responsibility_id   NUMBER(15);
  l_releasing_approver_id       NUMBER(15);
  l_receiving_approver_id       NUMBER(15);
  l_rule_id             NUMBER(15);
  l_approval_type       VARCHAR2(30);
  l_approval_method     VARCHAR2(30);
  l_error_message       VARCHAR2(2000);


  l_dummy               NUMBER(15);

  debugInfo		VARCHAR2(255)	:= NULL;

  localException	EXCEPTION;

  callingProgram	VARCHAR2(80)	:= 'GetAllApprovers';

BEGIN

  -----------------------------------------------------
  debugInfo := 'Retrieve book type code from IA_REQUEST_HEADERS';
  -----------------------------------------------------
  begin

    select book_type_code
          ,responsibility_id
          ,releasing_approver_id
          ,receiving_approver_id
    into l_book_type_code
        ,l_responsibility_id
        ,l_releasing_approver_id
        ,l_receiving_approver_id
    from ia_request_headers
    where request_id=RequestId;

  exception
    when others then
      FND_MESSAGE.set_name('IA', 'IA_NO_REQUEST_FOUND'); -- Error: Unable to find request id, REQUEST_ID
      FND_MESSAGE.set_token('REQUEST_ID', RequestId);
      l_error_message := FND_MESSAGE.Get;
      raise localException;
  end;

  -----------------------------------------------------
  debugInfo := 'Validate Responsibility ID';
  -----------------------------------------------------
  begin

    select responsibility_id
    into l_dummy
    from fnd_responsibility
    where responsibility_id=l_responsibility_id
      and application_id=IA_WF_UTIL_PKG.GetApplicationID;

  exception
    when others then
      FND_MESSAGE.set_name('IA', 'IA_NO_RESPONSIBILITY_FOUND'); -- Error: Unable to find responsibility id, RESPONSIBILITY_ID
      FND_MESSAGE.set_token('RESPONSIBILITY_ID', l_responsibility_id);
      l_error_message := FND_MESSAGE.Get;
      raise localException;
  end;

  -----------------------------------------------------
  debugInfo := 'Get Rule ID';
  -----------------------------------------------------
  begin

    l_rule_id := IA_WF_UTIL_PKG.GetRuleID(p_responsibility_id => l_responsibility_id);

  exception
    when others then
        FND_MESSAGE.set_name('IA', 'IA_NO_RULE_ASSIGNED'); -- Error: No rule has been defined for responsibility id, RESPONSIBILITY_ID.
        FND_MESSAGE.set_token('RESPONSIBILITY_ID', l_responsibility_id);
        l_error_message := FND_MESSAGE.Get;
        raise localException;
  end;

  -----------------------------------------------------
  debugInfo := 'Initialize rule setup';
  -----------------------------------------------------
  if (not IA_WF_UTIL_PKG.ResetRuleSetup(p_rule_id        => l_rule_id,
                                        p_book_type_code => l_book_type_code) ) then
       FND_MESSAGE.set_name('IA', 'IA_RULE_RETRIEVAL_ERROR'); -- Error: Unable to find rule id, RULE_ID
       FND_MESSAGE.set_token('RULE_ID', l_rule_id);
       l_error_message := FND_MESSAGE.Get;
       raise localException;
  end if;

  -----------------------------------------------------
  debugInfo := 'Get Approval Type';
  -----------------------------------------------------
  l_approval_type := IA_WF_UTIL_PKG.GetApprovalType(p_rule_id        => l_rule_id,
                                                    p_book_type_code => l_book_type_code);

  -----------------------------------------------------
  debugInfo := 'Get Approval Method';
  -----------------------------------------------------
  l_approval_method := IA_WF_UTIL_PKG.GetApprovalMethod(p_rule_id        => l_rule_id,
                                                        p_book_type_code => l_book_type_code);


  /*
  * This step calls AME_API.getAllApprovers only when Approval method is HIERARCHY.
  */

--  if ( l_approval_method = IA_WF_UTIL_PKG.ApprovalMethodHierarchy ) then

    -----------------------------------------------------
    debugInfo := 'Calling AME_API.getAllApprovers';
    -----------------------------------------------------
    IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'before', debugInfo);

    if (l_releasing_approver_id is NOT NULL
        and (l_approval_type = IA_WF_UTIL_PKG.ApprovalTypeAll or l_approval_type = IA_WF_UTIL_PKG.ApprovalTypeReleasing)) then
      AME_API.getAllApprovers(applicationIdIn   => IA_WF_UTIL_PKG.GetApplicationID,
                              transactionTypeIn => IA_WF_UTIL_PKG.AME_RELEASE_TransactionType,
                              transactionIdIn   => RequestId,
                              ApproversOut      => ReleasingApprovers);
    end if;

    if (l_receiving_approver_id is NOT NULL
        and (l_approval_type = IA_WF_UTIL_PKG.ApprovalTypeAll or l_approval_type = IA_WF_UTIL_PKG.ApprovalTypeDestination)) then
      AME_API.getAllApprovers(applicationIdIn   => IA_WF_UTIL_PKG.GetApplicationID,
                              transactionTypeIn => IA_WF_UTIL_PKG.AME_RECEIVE_TransactionType,
                              transactionIdIn   => RequestId,
                              ApproversOut      => ReceivingApprovers);
    end if;

    IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'after', debugInfo);

/*
  else

    -- The following logic will be executed when approval method is COST_CENTER.

    releasingApproverRec.person_id := l_releasing_approver_id;
    receivingApproverRec.person_id := l_receiving_approver_id;

    ReleasingApprovers(1) := releasingApproverRec;
    ReceivingApprovers(1) := receivingApproverRec;

  end if;
*/


  return TRUE;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => l_error_message);
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          return FALSE;

END GetAllApprovers;

FUNCTION UpdateApprovalStatus
       (RequestId		IN		NUMBER,
        ChainPhase		IN		VARCHAR2,
        Approver		IN		AME_UTIL.approverRecord DEFAULT AME_UTIL.emptyApproverRecord,
        Forwardee		IN		AME_UTIL.approverRecord DEFAULT AME_UTIL.emptyApproverRecord)
  return BOOLEAN
IS

  l_transactionType	VARCHAR2(255)	:= IA_WF_UTIL_PKG.AME_RELEASE_TransactionType;

  debugInfo		VARCHAR2(255)	:= NULL;

  localException	EXCEPTION;

  callingProgram	VARCHAR2(80)	:= 'UpdateApprovalStatus';

BEGIN

  /*
  * This step calls AME_API.getNextApprover.
  */
  -----------------------------------------------------
  debugInfo := 'Calling AME_API.UpdateApprovalStatus';
  -----------------------------------------------------
  IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'before', debugInfo);

  if (ChainPhase = IA_WF_UTIL_PKG.ApprovalTypeReleasing) then
    l_transactionType := IA_WF_UTIL_PKG.AME_RELEASE_TransactionType;
  else
    l_transactionType := IA_WF_UTIL_PKG.AME_RECEIVE_TransactionType;
  end if;

  AME_API.updateApprovalStatus(applicationIdIn   => IA_WF_UTIL_PKG.GetApplicationID,
                               transactionTypeIn => l_transactionType,
                               transactionIdIn   => RequestId,
                               approverIn        => Approver,
                               forwardeeIn       => Forwardee);

/*
  AME_API.updateApprovalStatus2(applicationIdIn    => IA_WF_UTIL_PKG.GetApplicationID,
                                transactionIdIn    => l_transactionType,
                                approvalStatusIn   => ame_util.noResponseStatus,
                                approverPersonIdIn => l_forward_from_id,
                                approverUserIdIn   => NULL,
                                transactionTypeIn  => p_item_type,
                                forwardeeIn        => l_recApprover);
*/

  IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'after', debugInfo);

  return TRUE;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          return FALSE;

END UpdateApprovalStatus;

FUNCTION InitializePlsqlContext
       (RequestId		IN		NUMBER)
  return BOOLEAN
IS

  debugInfo		VARCHAR2(255)	:= NULL;

  localException	EXCEPTION;

  callingProgram	VARCHAR2(80)	:= 'InitializePlsqlContext';

BEGIN

  /*
  * This step calls AME_ENGINE.InitializePlsqlContext.
  */
  -----------------------------------------------------
  debugInfo := 'Calling AME_ENGINE.initializePlsqlContext';
  -----------------------------------------------------
  IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'before', debugInfo);

  /*
  AME_ENGINE.initializePlsqlContext(ameApplicationIdIn  => null,
                                    fndApplicationIdIn  => IA_WF_UTIL_PKG.GetApplicationID,
                                    transactionTypeIdIn => IA_WF_UTIL_PKG.AME_RELEASE_TransactionType,
                                    transactionIdIn     => RequestId);

  AME_ENGINE.initializePlsqlContext(ameApplicationIdIn  => null,
                                    fndApplicationIdIn  => IA_WF_UTIL_PKG.GetApplicationID,
                                    transactionTypeIdIn => IA_WF_UTIL_PKG.AME_RECEIVE_TransactionType,
                                    transactionIdIn     => RequestId);
  */

  return TRUE;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          return FALSE;

END InitializePlsqlContext;

FUNCTION InitializeAME
       (RequestId		IN		NUMBER)
  return BOOLEAN
IS

  debugInfo		VARCHAR2(255)	:= NULL;

  localException	EXCEPTION;

  callingProgram	VARCHAR2(80)	:= 'InitializeAME';

BEGIN

  /*
  * This step calls AME_API.clearAllApprovals.
  */
  -----------------------------------------------------
  debugInfo := 'Calling AME_ENGINE.initializePlsqlContext';
  -----------------------------------------------------
  IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'before', debugInfo);

  AME_ENGINE.initializePlsqlContext(ameApplicationIdIn  => null,
                                    fndApplicationIdIn  => IA_WF_UTIL_PKG.GetApplicationID,
                                    transactionTypeIdIn => IA_WF_UTIL_PKG.AME_RELEASE_TransactionType,
                                    transactionIdIn     => RequestId);

  AME_ENGINE.initializePlsqlContext(ameApplicationIdIn  => null,
                                    fndApplicationIdIn  => IA_WF_UTIL_PKG.GetApplicationID,
                                    transactionTypeIdIn => IA_WF_UTIL_PKG.AME_RECEIVE_TransactionType,
                                    transactionIdIn     => RequestId);

  -----------------------------------------------------
  debugInfo := 'Calling AME_API.clearAllApprovals';
  -----------------------------------------------------
  IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, 'before', debugInfo);

  AME_API.clearAllApprovals(applicationIdIn   => IA_WF_UTIL_PKG.GetApplicationID,
                            transactionTypeIn => IA_WF_UTIL_PKG.AME_RELEASE_TransactionType,
                            transactionIdIn   => RequestId);

  AME_API.clearAllApprovals(applicationIdIn   => IA_WF_UTIL_PKG.GetApplicationID,
                            transactionTypeIn => IA_WF_UTIL_PKG.AME_RECEIVE_TransactionType,
                            transactionIdIn   => RequestId);


  return TRUE;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          return FALSE;

END InitializeAME;

END IA_AME_REQUEST_PKG;

/
