--------------------------------------------------------
--  DDL for Package Body IA_WF_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IA_WF_REQUEST_PKG" AS
/* $Header: IAWFREQB.pls 120.1 2006/01/31 14:46:25 appldev noship $   */

/*
PROCEDURE Insert_Approval
         (p_request_id            in  number
         ,p_approver_id           in  number
         ,p_approval_status       in  varchar2
         ,p_approval_chain_phase  in  varchar2
         ,p_approval_id           out nocopy number
         );
*/

/*
PROCEDURE Repopulate_Approvers_List
         (p_request_id            in  number,
          p_releasing_approvers   in  AME_UTIL.approversTable,
          p_receiving_approvers   in  AME_UTIL.approversTable
         );
*/

/*
PROCEDURE Update_Approval_Status
         (p_approval_id      in number
         ,p_chain_phase      in varchar2
         ,p_approval_status  in varchar2
         );
*/

/*
PROCEDURE Update_Approval_Notify
         (p_approval_id      in number
         ,p_notification_id  in number
         ,p_user_comment     in varchar2
         );
*/

PROCEDURE Update_Request_Header_Status
         (p_request_id       in number
         ,p_status           in varchar2
         );

PROCEDURE Update_Request_Line_Status
         (p_request_id       in number
         ,p_status           in varchar2
         );

FUNCTION Start_Process(p_request_id in number)
return NUMBER
IS

  l_itemkey		VARCHAR2(30) := p_request_id;

  l_book_type_code	VARCHAR2(30);

  l_person_id			NUMBER(15);

  l_preparer_id			NUMBER(15);
  l_preparer_name		VARCHAR2(30);
  l_preparer_name_display	VARCHAR2(80);
  l_preparer_user_id		NUMBER(15);

  l_system_admin		VARCHAR2(30) := NULL;

  l_requester_id		NUMBER(15);
  l_requester_name		VARCHAR2(30);
  l_requester_name_display	VARCHAR2(80);

  l_releasing_approver_id	NUMBER(15);
  l_releasing_approver_name	VARCHAR2(30);
  l_releasing_approver_name_disp	VARCHAR2(80);

  l_receiving_approver_id	NUMBER(15);
  l_receiving_approver_name	VARCHAR2(30);
  l_receiving_approver_name_disp	VARCHAR2(80);

  l_responsibility_id   NUMBER(15);
  l_rule_id		NUMBER(15);
  l_status		VARCHAR2(30);

  l_dummy		NUMBER(15);
  l_dummy_text		VARCHAR2(80);

  l_request_type	VARCHAR2(15);
  l_purpose		VARCHAR2(2000);

  l_approval_type       VARCHAR2(30);
  l_chain_phase         VARCHAR2(30);

  l_attribute		VARCHAR2(30);
  l_error_message	VARCHAR2(2000);

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;
  localWFException      EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Start_Process';

BEGIN

  savepoint START_PROCESS_STEP1;

  /***************************
  * Initializing variables
  ***************************/
  -----------------------------------------------------
  debugInfo := 'Initialize error message stack';
  -----------------------------------------------------
  FA_SRVR_MSG.init_server_message;
  IA_WF_UTIL_PKG.InitializeDebugMessage;


  -----------------------------------------------------
  debugInfo := 'Retrieve book type code from IA_REQUEST_HEADERS';
  -----------------------------------------------------
  begin

    select book_type_code
          ,preparer_id
          ,requester_id
          ,responsibility_id
          ,request_type
          ,purpose
          ,status
          ,releasing_approver_id
          ,receiving_approver_id
    into l_book_type_code
        ,l_preparer_id
        ,l_requester_id
        ,l_responsibility_id
        ,l_request_type
        ,l_purpose
        ,l_status
        ,l_releasing_approver_id
        ,l_receiving_approver_id
    from ia_request_headers
    where request_id=p_request_id;

  exception
    when others then
      FND_MESSAGE.set_name('IA', 'IA_NO_REQUEST_FOUND'); -- Error: Unable to find request id, REQUEST_ID
      FND_MESSAGE.set_token('REQUEST_ID', p_request_id);
      l_error_message := FND_MESSAGE.Get;
      raise localException;
  end;

  if (l_status is NULL or l_status <> IA_WF_UTIL_PKG.HeaderStatusSubmitted) then
      FND_MESSAGE.set_name('IA', 'IA_INVALID_STATUS_FOR_START_WF'); -- Error: You can not submit the request id, REQUEST_ID. The status of request must be set to Submitted in order for Workflow to initiate the request.
      FND_MESSAGE.set_token('REQUEST_ID', p_request_id);
      l_error_message := FND_MESSAGE.Get;
      raise localException;
  end if;


  begin

    -----------------------------------------------------
    debugInfo := 'Get Preparer Name';
    -----------------------------------------------------
    l_person_id := l_preparer_id;
    WF_DIRECTORY.GetUserName('PER',
                             l_person_id,
                             l_preparer_name,
                             l_preparer_name_display);


    -----------------------------------------------------
    debugInfo := 'Get Requester Name';
    -----------------------------------------------------
    l_person_id := l_requester_id;
    WF_DIRECTORY.GetUserName('PER',
                             l_person_id,
                             l_requester_name,
                             l_requester_name_display);

    -----------------------------------------------------
    debugInfo := 'Validate Releasing Approver ID and Get the Name';
    -----------------------------------------------------
    l_person_id := l_releasing_approver_id;
    WF_DIRECTORY.GetUserName('PER',
                             l_person_id,
                             l_releasing_approver_name,
                             l_releasing_approver_name_disp);

    -----------------------------------------------------
    debugInfo := 'Validate Receiving Approver ID and Get the Name';
    -----------------------------------------------------
    l_person_id := l_receiving_approver_id;
    WF_DIRECTORY.GetUserName('PER',
                             l_person_id,
                             l_receiving_approver_name,
                             l_receiving_approver_name_disp);

  exception
    when others then
         FND_MESSAGE.set_name('IA', 'IA_NO_PERSON_FOUND'); -- Error: Unable to find person id, PERSON_ID
         FND_MESSAGE.set_token('PERSON_ID', l_person_id);
         l_error_message := FND_MESSAGE.Get;
         raise localException;
  end;


  -----------------------------------------------------
  debugInfo := 'Validate Book Type Code';
  -----------------------------------------------------
  if (l_request_type = IA_WF_UTIL_PKG.RequestTypeTransfer) then

    begin

      select book_type_code
      into l_dummy_text
      from fa_book_controls
      where book_type_code=l_book_type_code
        and book_class='CORPORATE'
        and rownum < 2;

    exception
      when others then
        FND_MESSAGE.set_name('IA', 'IA_NO_BOOK_FOUND'); -- Error: Unable to find book, BOOK_TYPE_CODE with book class of Corporate
        FND_MESSAGE.set_token('BOOK_TYPE_CODE', l_book_type_code);
        l_error_message := FND_MESSAGE.Get;
        raise localException;
    end;

  end if;

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
  debugInfo := 'Get User ID of Preparer';
  -----------------------------------------------------
  begin

    l_preparer_user_id := to_number(FND_PROFILE.VALUE('USER_ID'));

    /* To avoid error when launched from pl/sql
    if (l_preparer_user_id is NULL) then
      raise localException;
    end if;
    */

  end;

  -----------------------------------------------------
  debugInfo := 'Initialize Profile';
  -----------------------------------------------------
  if (not IA_WF_UTIL_PKG.InitializeProfile(p_user_id           => l_preparer_user_id,
                                           p_responsibility_id => l_responsibility_id) ) then
       raise localException;
  end if;

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

  if (l_approval_type = IA_WF_UTIL_PKG.ApprovalTypeDestination) then
    l_chain_phase :=  IA_WF_UTIL_PKG.ApprovalTypeDestination;
  else
    l_chain_phase :=  IA_WF_UTIL_PKG.ApprovalTypeReleasing;
  end if;

  /***************************
  * Initializing AME session
  ***************************/

/*
  -----------------------------------------------------
  debugInfo := 'Clear all AME PL/SQL session context and approvals for the transaciton ID';
  -----------------------------------------------------
  if (not IA_AME_REQUEST_PKG.InitializeAME(RequestId => p_request_id)) then
       FND_MESSAGE.set_name('IA', 'IA_AME_INITIALIZE_ERROR'); -- Error: Error occurred when initializing a session for Oracle Approvals Management.
       l_error_message := FND_MESSAGE.Get;
       raise localException;
  end if;
*/


  begin

    -----------------------------------------------------
    debugInfo := 'Set the current request status to Pending';
    -----------------------------------------------------
    update ia_request_headers
    set status = IA_WF_UTIL_PKG.HeaderStatusPendingApproval
       ,last_update_date = SYSDATE
       ,last_updated_by = nvl(to_number(FND_PROFILE.VALUE('USER_ID')),-1)
       ,last_update_login = nvl(to_number(FND_PROFILE.VALUE('LOGIN_ID')),-1)
    where request_id = p_request_id;

    update ia_request_details
    set status = IA_WF_UTIL_PKG.LineStatusPending
       ,last_update_date = SYSDATE
       ,last_updated_by = nvl(to_number(FND_PROFILE.VALUE('USER_ID')),-1)
       ,last_update_login = nvl(to_number(FND_PROFILE.VALUE('LOGIN_ID')),-1)
    where request_id = p_request_id;

  exception
    when others then
      FND_MESSAGE.set_name('IA', 'IA_HEADER_STATUS_UPDATE_ERROR'); -- Error: Unable to update the status for request id, REQUEST_ID
      FND_MESSAGE.set_token('REQUEST_ID', p_request_id);
      l_error_message := FND_MESSAGE.Get;
      raise localException;
  end;

  /****************************
  * Launching Workflow Process
  *****************************/

  -- WF_ENGINE.threshold := -1;


  begin
    -----------------------------------------------------
    debugInfo := 'Create a new process';
    -----------------------------------------------------
    WF_ENGINE.createProcess(ItemType => IA_WF_UTIL_PKG.WF_TransactionType,
                            ItemKey  => l_itemkey,
                            process  => IA_WF_UTIL_PKG.WF_MainProcess);

  exception
    when others then
      FND_MESSAGE.set_name('IA', 'IA_WF_CREATE_PROCESS_ERROR'); -- Error: Unable to create a workflow process for request id, REQUEST_ID
      FND_MESSAGE.set_token('REQUEST_ID', p_request_id);
      l_error_message := FND_MESSAGE.Get;
      raise localException;
  end;


  begin

    l_system_admin := IA_WF_UTIL_PKG.GetSystemAdministrator;

    -----------------------------------------------------
    debugInfo := 'Set system item attributes';
    -----------------------------------------------------
    if (l_system_admin is NOT NULL) then
      WF_ENGINE.SetItemOwner(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                             itemkey  => l_itemkey,
                             owner    => l_system_admin); -- l_preparer_name);
    end if;

    WF_ENGINE.SetItemUserKey(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                             itemkey  => l_itemkey,
                             userkey  => p_request_id); -- p_request_id);

  exception
    when others then
      FND_MESSAGE.set_name('IA', 'IA_WF_SET_SYSTEM_ATTRS_ERROR'); -- Error: Unable to set the workflow system attributes for request id, REQUEST_ID
      FND_MESSAGE.set_token('REQUEST_ID', p_request_id);
      l_error_message := FND_MESSAGE.Get;
      raise localWFException;
  end;


  begin
    -----------------------------------------------------
    debugInfo := 'Set item attributes';
    -----------------------------------------------------
    l_attribute := 'REQUEST_ID';
    WF_ENGINE.SetItemAttrNumber(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                                itemkey  => l_itemkey,
                                aname    => 'REQUEST_ID',
  		      	        avalue   => p_request_id);

    l_attribute := 'PREPARER_ID';
    WF_ENGINE.SetItemAttrNumber(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                                itemkey  => l_itemkey,
  	 	                aname    => 'PREPARER_ID',
		      	        avalue   => l_preparer_id);

    l_attribute := 'PREPARER_NAME';
    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
  		      	      itemkey  => l_itemkey,
	 	      	      aname    => 'PREPARER_NAME',
		  	      avalue   => l_preparer_name);

    l_attribute := 'PREPARER_NAME_DISP';
    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
  		      	      itemkey  => l_itemkey,
	 	      	      aname    => 'PREPARER_NAME_DISP',
		  	      avalue   => l_preparer_name_display);

    l_attribute := 'REQUESTER_ID';
    WF_ENGINE.SetItemAttrNumber(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                                itemkey  => l_itemkey,
	 	      	        aname    => 'REQUESTER_ID',
		      	        avalue   => l_requester_id);

    l_attribute := 'REQUESTER_NAME';
    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
 		      	      itemkey  => l_itemkey,
	 	      	      aname    => 'REQUESTER_NAME',
		  	      avalue   => l_requester_name);

    l_attribute := 'REQUESTER_NAME_DISP';
    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
 		      	      itemkey  => l_itemkey,
	 	      	      aname    => 'REQUESTER_NAME_DISP',
		  	      avalue   => l_requester_name_display);

    l_attribute := 'DELEGATEE_ID';
    WF_ENGINE.SetItemAttrNumber(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                                itemkey  => l_itemkey,
	 	      	        aname    => 'DELEGATEE_ID',
		      	        avalue   => '');

    l_attribute := 'BOOK_TYPE_CODE';
    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
 		      	      itemkey  => l_itemkey,
	 	      	      aname    => 'BOOK_TYPE_CODE',
		  	      avalue   => l_book_type_code);

    l_attribute := 'REQUEST_TYPE';
    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
 		      	      itemkey  => l_itemkey,
	 	      	      aname    => 'REQUEST_TYPE',
		  	      avalue   => l_request_type);

    l_attribute := 'REQUEST_TYPE_DISP';
    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                              itemkey  => l_itemkey,
                              aname    => 'REQUEST_TYPE_DISP',
                              avalue   => IA_WF_UTIL_PKG.GetLookupMeaning(p_lookup_type=>'REQUEST_TYPE',
                                                                          p_lookup_code=>l_request_type));

    l_attribute := 'REQUEST_PURPOSE';
    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
 		      	      itemkey  => l_itemkey,
	 	      	      aname    => 'REQUEST_PURPOSE',
		  	      avalue   => l_purpose);

    l_attribute := 'RULE_ID';
    WF_ENGINE.SetItemAttrNumber(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                                itemkey  => l_itemkey,
	 	      	        aname    => 'RULE_ID',
		      	        avalue   => l_rule_id);

    l_attribute := 'APPROVAL_CHAIN_PHASE';
    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
 		      	      itemkey  => l_itemkey,
	 	      	      aname    => 'APPROVAL_CHAIN_PHASE',
		  	      avalue   => l_chain_phase);

    l_attribute := 'APPROVAL_CHAIN_PHASE_DISP';
    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                              itemkey  => l_itemkey,
                              aname    => 'APPROVAL_CHAIN_PHASE_DISP',
                              avalue   => IA_WF_UTIL_PKG.GetLookupMeaning(p_lookup_type=>'APPROVAL_TYPE',
                                                                          p_lookup_code=>l_chain_phase));

    l_attribute := 'NO_MORE_APPROVER_FLAG';
    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
 		      	      itemkey  => l_itemkey,
	 	      	      aname    => 'NO_MORE_APPROVER_FLAG',
		  	      avalue   => 'N');

/** Reference for settting other item types

  WF_ENGINE.SetItemAttrDate(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
		      	    itemkey  => l_itemkey,
	 	      	    aname    => 'AAA_DATE',
		      	    avalue   => p_aaa_date);
***/

    l_attribute := 'REQUEST_STATUS';
    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
 		      	      itemkey  => l_itemkey,
	 	      	      aname    => 'REQUEST_STATUS',
		  	      avalue   => IA_WF_UTIL_PKG.HeaderStatusPendingApproval);

    l_attribute := 'REQUEST_STATUS_DISP';
    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                              itemkey  => l_itemkey,
                              aname    => 'REQUEST_STATUS_DISP',
                              avalue   => IA_WF_UTIL_PKG.GetLookupMeaning(p_lookup_type=>'REQ_HDR_STATUS',
                                                                          p_lookup_code=>IA_WF_UTIL_PKG.HeaderStatusPendingApproval));
  exception
    when others then
      FND_MESSAGE.set_name('IA', 'IA_WF_SET_ATTRIBUTE_ERROR'); -- Error: Unable to set the workflow attribute ATTRIBUTE for request id, REQUEST_ID
      FND_MESSAGE.set_token('ATTRIBUTE', l_attribute);
      FND_MESSAGE.set_token('REQUEST_ID', p_request_id);
      l_error_message := FND_MESSAGE.Get;
      raise localWFException;
  end;


  begin

    -----------------------------------------------------
    debugInfo := 'Start Work Flow process';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => l_itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    WF_ENGINE.StartProcess(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                           itemkey  => l_itemkey);

  exception
    when others then
      FND_MESSAGE.set_name('IA', 'IA_WF_START_PROCESS_ERROR'); -- Error: Unable to start a workflow process for request id, REQUEST_ID
      FND_MESSAGE.set_token('REQUEST_ID', p_request_id);
      l_error_message := FND_MESSAGE.Get;
      raise localWFException;
  end;

  commit;

  return 1;

EXCEPTION
/*
message_name: IA_DEBUG
message_text: ERROR occurred in
              CALLING_SEQUENCE
              with parameters (PARAMETERS)
              while performing the following operation:
              DEBUG_INFO
*/
        WHEN localException THEN
          rollback to START_PROCESS_STEP1;
          FA_SRVR_MSG.add_message(calling_fn => l_error_message);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo||' '||l_error_message, 'Error');

          return -1;

        WHEN localWFException THEN
          rollback to START_PROCESS_STEP1;
          FA_SRVR_MSG.add_message(calling_fn => l_error_message);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo||' '||l_error_message, 'Error');
/*
          IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => p_request_id,
                                           p_calling_fn => callingProgram,
                                           p_parameter1 => debugInfo||' '||l_error_message);
*/

          return -1;

        WHEN OTHERS THEN
          rollback to START_PROCESS_STEP1;
          FA_SRVR_MSG.Add_SQL_Error(calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');

          return -1;

END Start_Process;

FUNCTION Abort_Process(p_request_id in number)
return NUMBER
IS

  l_error_message       VARCHAR2(2000);

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;
  localWFException      EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Abort_Process';


BEGIN

  savepoint ABORT_PROCESS_STEP1;


  -----------------------------------------------------
  debugInfo := 'Calling AbortProcess';
  IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => p_request_id,
                                   p_calling_fn => callingProgram,
                                   p_parameter1 => debugInfo);
  -----------------------------------------------------

  WF_ENGINE.AbortProcess(IA_WF_UTIL_PKG.WF_TransactionType,
                         p_request_id);

  commit;

  return 1; -- If successful

EXCEPTION

WHEN OTHERS THEN
         rollback to ABORT_PROCESS_STEP1;
         FA_SRVR_MSG.Add_SQL_Error(calling_fn => callingProgram);
         IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');

         return -1; -- If errored out

END Abort_Process;

PROCEDURE Check_Approval_Type
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2)
IS

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Check_Approval_Type';


  l_approval_id		NUMBER(15);
  l_rule_id		NUMBER(15);

  l_approval_type  	VARCHAR2(30);
  l_approvals_required 	VARCHAR2(30);

  l_attribute           VARCHAR2(30);
  l_error_message       VARCHAR2(2000);

  l_book_type_code	VARCHAR2(30);

  localWFException      EXCEPTION;


BEGIN

  if (funcmode = 'RUN') then

    -----------------------------------------------------
    debugInfo := 'Get rule ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_rule_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                            ,itemkey => itemkey
                                            ,aname => 'RULE_ID');

    -----------------------------------------------------
    debugInfo := 'Get Book Type Code';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_book_type_code := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                 ,itemkey => itemkey
                                                 ,aname => 'BOOK_TYPE_CODE');

    -----------------------------------------------------
    debugInfo := 'Get Approval Type';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_approval_type := IA_WF_UTIL_PKG.GetApprovalType(p_rule_id        => l_rule_id
                                                     ,p_book_type_code => l_book_type_code);

    if (l_approval_type = IA_WF_UTIL_PKG.ApprovalTypeNone) then
       l_approvals_required := 'NO';
    else
       l_approvals_required := 'YES';
    end if;


    begin

      l_attribute := 'APPROVALS_REQUIRED';
      WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                                itemkey  => itemkey,
                                aname    => 'APPROVALS_REQUIRED',
                                avalue   => l_approvals_required);
    exception
      when others then
        FND_MESSAGE.set_name('IA', 'IA_WF_SET_ATTRIBUTE_ERROR'); -- Error: Unable to set the workflow attribute ATTRIBUTE for request id, REQUEST_ID
        FND_MESSAGE.set_token('ATTRIBUTE', l_attribute);
        FND_MESSAGE.set_token('REQUEST_ID', itemkey);
        l_error_message := FND_MESSAGE.Get;
        raise localWFException;
    end;

    result := 'COMPLETE:'||l_approvals_required;

  elsif (funcmode = 'CANCEL') THEN

      result := 'COMPLETE';

  end if;

EXCEPTION
        WHEN localWFException THEN
          FA_SRVR_MSG.add_message(calling_fn => l_error_message);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo||' '||l_error_message, 'Error');
          result := 'COMPLETE:ERROR';
          WF_CORE.Context(IA_WF_UTIL_PKG.WF_TransactionType, callingProgram,
                          itemtype, itemkey, to_char(actid), debugInfo);
          RAISE;

        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');
          result := 'COMPLETE:ERROR';

          WF_CORE.Context(IA_WF_UTIL_PKG.WF_TransactionType, callingProgram,
                          itemtype, itemkey, to_char(actid), debugInfo);
          RAISE;

END Check_Approval_Type;

PROCEDURE Get_Next_Approver
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2)
IS

  l_approval_id     	NUMBER(15) := NULL;
  l_request_id      	NUMBER(15) := -1;


  debugInfo             VARCHAR2(255)   := NULL;

  l_error_message	VARCHAR2(2000);

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Get_Next_Approver';


  tempApprover      	AME_UTIL.approverRecord;
  tempApprovers     	AME_UTIL.approversTable;


  l_approver_id     		NUMBER(15) := NULL;
  l_approver_name		VARCHAR2(150);
  l_approver_name_display	VARCHAR2(150);

  l_approver_role		VARCHAR2(50);
  l_approver_role_display	VARCHAR2(150);

  l_chain_phase			VARCHAR2(30);
  l_no_more_approver_flag	VARCHAR2(1);


BEGIN

  if (funcmode = 'RUN') then

    -----------------------------------------------------
    debugInfo := 'Get item attributes';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_request_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                               ,itemkey => itemkey
                                               ,aname => 'REQUEST_ID');

    -----------------------------------------------------
    l_chain_phase := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                              ,itemkey => itemkey
                                              ,aname => 'APPROVAL_CHAIN_PHASE');

    -----------------------------------------------------
    -- debugInfo := 'Get next approver ID';
    debugInfo := 'Get next approver ID: l_chain_phase='||l_chain_phase;
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    if (not IA_AME_REQUEST_PKG.GetNextApprover(RequestId  => l_request_id
                                              ,ChainPhase => l_chain_phase -- IN OUT
                                              ,Approver   => tempApprover
                                              ,NoMoreApproverFlag => l_no_more_approver_flag )) then

         FND_MESSAGE.set_name('IA', 'IA_AME_NEXT_APPROVER_ERROR'); -- Error: Error occurred when fetching a next approver from Oracle Approval Management.
         l_error_message := FND_MESSAGE.Get;
         raise localException;
    end if;

    l_approver_id := tempApprover.person_id;


    WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'APPROVAL_CHAIN_PHASE',
                              avalue   => l_chain_phase);

    WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'APPROVAL_CHAIN_PHASE_DISP',
                              avalue   => IA_WF_UTIL_PKG.GetLookupMeaning(p_lookup_type=>'APPROVAL_TYPE',
                                                                          p_lookup_code=>l_chain_phase));

    if (l_approver_id is NULL) then
      -----------------------------------------------------
      debugInfo := 'Logic for finally approved';
      IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
      -----------------------------------------------------
      WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'NO_MORE_APPROVER_FLAG',
                                avalue   => 'Y');

      result := 'COMPLETE:NOT_FOUND';

      IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                       p_calling_fn => callingProgram,
                                       p_parameter1 => debugInfo);

    else

      -----------------------------------------------------
      debugInfo := 'Derive the role name for the approver ID from DIRECTORY and set item attributes';
      IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
      -----------------------------------------------------

/*
      WF_DIRECTORY.GetRoleName('PER',
                               l_approver_id,
                               l_approver_role,
                               l_approver_role_display);
*/

      WF_DIRECTORY.GetUserName('PER',
                               l_approver_id,
                               l_approver_name,
                               l_approver_name_display);

      WF_ENGINE.SetItemAttrNumber(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPROVER_ID',
                                  avalue   => l_approver_id);

      -- l_approver_role := 'DEMO'; -- I guess fnd user needs to be set up for the role to be retrieved correctly.

/*
      WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'APPROVER_ROLE',
                                avalue   => l_approver_role);
*/

      WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'APPROVER_NAME',
                                avalue   => l_approver_name);

      WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'APPROVER_NAME_DISP',
                                avalue   => l_approver_name_display);

      result := 'COMPLETE:FOUND';

    end if;

  elsif (funcmode = 'CANCEL') THEN

      result := 'COMPLETE';

  end if;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => l_error_message);
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');
          result := 'COMPLETE:ERROR';

          WF_CORE.Context(IA_WF_UTIL_PKG.WF_TransactionType, callingProgram,
                          itemtype, itemkey, to_char(actid), debugInfo);
          RAISE;


END Get_Next_Approver;


PROCEDURE Set_Role(p_role_name in varchar2)
IS
--   v_user_name fnd_user.user_name%type := 'FA_USER1';
   user_name            varchar2(100):=null;
   user_display_name    varchar2(100):=null;
   language             varchar2(100):=userenv('LANG');
   territory            varchar2(100):='America';
   description          varchar2(100):=NULL;
   notification_preference varchar2(100):='MAILTEXT';
   email_address        varchar2(100):=NULL;
   fax                  varchar2(100):=NULL;
   status               varchar2(100):='ACTIVE';
   expiration_date      varchar2(100):=NULL;
   role_name            varchar2(100):=NULL;
   role_display_name    varchar2(100):=NULL;
   role_description     varchar2(100):=NULL;
   wf_id                Number;

   duplicate_user_or_role       exception;
   PRAGMA       EXCEPTION_INIT (duplicate_user_or_role, -20002);

BEGIN

   /* Create a role for ad hoc user */

   role_name := p_role_name;

   role_display_name := role_name || 'Dis';
--   email_address := 'yyoon@us.oracle.com';
   email_address := 'Young-won.Yoon@oracle.com';

   begin

     WF_Directory.CreateAdHocRole
        (role_name, role_display_name,
         language, territory,  role_description, notification_preference,
         user_name, email_address, fax, status, expiration_date);

   exception
       when duplicate_user_or_role then
            WF_Directory.SetAdHocRoleAttr (role_name, role_display_name,
            notification_preference, language, territory, email_address, fax);
   end;

END;


/*
FUNCTION Respond
         (p_request_id       in NUMBER
         ,p_result           in VARCHAR2
         ,p_delegatee_id     in NUMBER
         ,p_comment          in VARCHAR2
         )
return NUMBER
IS

  l_error_message	VARCHAR2(2000);

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Respond';

  l_notification_id	NUMBER(15);
  l_recipient_role	VARCHAR2(320);
  l_original_recipient	VARCHAR2(320);

  l_dummy		NUMBER(15);
  l_approval_id		NUMBER(15);

BEGIN

  savepoint RESPOND_STEP1;

  -----------------------------------------------------
  debugInfo := 'Initialize error message stack';
  -----------------------------------------------------
  FA_SRVR_MSG.init_server_message;
  IA_WF_UTIL_PKG.InitializeDebugMessage;

  -----------------------------------------------------
  debugInfo := 'Check if the given request_id is valid';
  -----------------------------------------------------
  begin

    select 1
    into l_dummy
    from ia_request_headers
    where request_id=p_request_id;

    select max(approval_id)
    into l_approval_id
    from ia_request_approvals
    where request_id=p_request_id
      and status=IA_WF_UTIL_PKG.ApprovalStatusPendingApproval;

  exception
    when others then
      FND_MESSAGE.set_name('IA', 'IA_NO_REQUEST_FOUND'); -- Error: Unable to find request id, REQUEST_ID
      FND_MESSAGE.set_token('REQUEST_ID', p_request_id);
      l_error_message := FND_MESSAGE.Get;
      raise localException;
  end;

  -----------------------------------------------------
  debugInfo := 'Retrieve the notification ID for the given request_id';
  -----------------------------------------------------
  begin

    select *+  leading(grp_id_view)  *
           notification_id
          ,recipient_role
          ,original_recipient
    into l_notification_id
        ,l_recipient_role
        ,l_original_recipient
    from wf_notifications wfn ,
       ( select notification_id group_id
         from wf_item_activity_statuses
         where item_type = 'IAWF'
           and item_key = p_request_id
       )  grp_id_view
    where grp_id_view.group_id = wfn.group_id;

  exception
    when others then
      FND_MESSAGE.set_name('IA', 'IA_NO_NOTIFICATION_FOUND'); -- Error: Unable to find the notification for request id, REQUEST_ID
      FND_MESSAGE.set_token('REQUEST_ID', p_request_id);
      l_error_message := FND_MESSAGE.Get;
      raise localException;
  end;

  -----------------------------------------------------
  debugInfo := 'Set the result code for the given notification';
  -----------------------------------------------------
  WF_NOTIFICATION.SetAttrText(l_notification_id, 'RESULT', p_result);
  -- wf_notification.SetAttrText(l_notification_id, 'RESULT', 'APPROVED');
  -- wf_notification.SetAttrText(l_notification_id, 'APPROVAL_RESPONSE', 'APPROVED');

  if (p_delegatee_id is NOT NULL) then
    -----------------------------------------------------
    debugInfo := 'Set the delegatee ID for the given notification';
    -----------------------------------------------------
    WF_NOTIFICATION.SetAttrNumber(l_notification_id, 'DELEGATEE_ID', p_delegatee_id);
  end if;

  if (p_result='CANCELLED') then

    -----------------------------------------------------
    debugInfo := 'Cancel the notification';
    -----------------------------------------------------
    -- WF_NOTIFICATION.Respond(l_notification_id, p_comment, 'DEMO');
    WF_NOTIFICATION.Cancel(l_notification_id, p_comment);

  else

    -----------------------------------------------------
    debugInfo := 'Respond the notification';
    -----------------------------------------------------
    -- WF_NOTIFICATION.Respond(l_notification_id, p_comment, 'DEMO');
    WF_NOTIFICATION.Respond(l_notification_id, p_comment, l_recipient_role);

  end if;

  -----------------------------------------------------
  debugInfo := 'Update ia_approval_requests with the notification ID';
  -----------------------------------------------------
  * COMMENTED OUT DUE TO NEW STANDARD WORKFLOW
  Update_Approval_Notify(p_approval_id     => l_approval_id
                        ,p_notification_id => l_notification_id
                        ,p_user_comment    => substr(p_comment,1,4000));

  *

  commit;

  return 1;

EXCEPTION

        WHEN localException THEN
          rollback to RESPOND_STEP1;
          FA_SRVR_MSG.add_message(calling_fn => l_error_message);
          IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => p_request_id,
                                           p_calling_fn => callingProgram,
                                           p_parameter1 => debugInfo||' '||l_error_message);

          return -1;

        WHEN OTHERS THEN
          rollback to RESPOND_STEP1;
          FA_SRVR_MSG.add_message(calling_fn => l_error_message);
          IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => p_request_id,
                                           p_calling_fn => callingProgram,
                                           p_parameter1 => debugInfo||' '||l_error_message);

          return -1;

END Respond;
*/

/*
PROCEDURE Insert_Next_Approver
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2)
IS

  l_error_message	VARCHAR2(2000);

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Insert_Next_Approver';

  l_request_id   	NUMBER(15) := NULL;
  l_chain_phase		VARCHAR2(30);
  l_approver_id   	NUMBER(15) := NULL;
  l_approval_id   	NUMBER(15) := NULL;

  tempReleasingApprovers 	AME_UTIL.approversTable;
  tempReceivingApprovers 	AME_UTIL.approversTable;

BEGIN

  if (funcmode = 'RUN') then

    null;

    * COMMENTED OUT DUE TO NEW STANDARD WORKFLOW
    -----------------------------------------------------
    debugInfo := 'Get request ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_request_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                               ,itemkey => itemkey
                                               ,aname => 'REQUEST_ID');

    -----------------------------------------------------
    l_chain_phase := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                              ,itemkey => itemkey
                                              ,aname => 'APPROVAL_CHAIN_PHASE');

    -----------------------------------------------------
    debugInfo := 'Get approver ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                ,itemkey => itemkey
                                                ,aname => 'APPROVER_ID');

     -----------------------------------------------------
    debugInfo := 'Insert into IA_REQUEST_APPROVALS table the next approver with status of Pending Approval';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    Insert_Approval(p_request_id           => l_request_id
                   ,p_approver_id          => l_approver_id
                   ,p_approval_status      => IA_WF_UTIL_PKG.ApprovalStatusPendingApproval
                   ,p_approval_chain_phase => l_chain_phase
                   ,p_approval_id          => l_approval_id);


    -----------------------------------------------------
    debugInfo := 'Set approval ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    WF_ENGINE.SetItemAttrNumber(itemtype => itemtype
                               ,itemkey  => itemkey
                               ,aname    => 'APPROVAL_ID'
                               ,avalue   => l_approval_id);

    -----------------------------------------------------
    debugInfo := 'Insert into IA_APPROVERS_LIST_T';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);

    -----------------------------------------------------
    debugInfo := 'Calling IA_AME_REQUEST_PKG.GetAllApprovers';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);

    -----------------------------------------------------
    if (not IA_AME_REQUEST_PKG.GetAllApprovers(RequestID => l_request_id,
                                               ReleasingApprovers => tempReleasingApprovers,
                                               ReceivingApprovers => tempReceivingApprovers) ) then

      FND_MESSAGE.set_name('IA', 'IA_AME_NEXT_APPROVER_ERROR');
      l_error_message := FND_MESSAGE.Get;
      raise localException;
    end if;

    Repopulate_Approvers_List(p_request_id          => l_request_id,
                              p_releasing_approvers => tempReleasingApprovers,
                              p_receiving_approvers => tempReceivingApprovers);
    *


  elsif (funcmode = 'CANCEL') THEN

      result := 'COMPLETE';

  end if;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');
          result := 'COMPLETE:ERROR';

          WF_CORE.Context(IA_WF_UTIL_PKG.WF_TransactionType, callingProgram,
                          itemtype, itemkey, to_char(actid), debugInfo);
          RAISE;

END Insert_Next_Approver;
*/

/*
PROCEDURE Insert_Approval
         (p_request_id            in  number
         ,p_approver_id           in  number
         ,p_approval_status       in  varchar2
         ,p_approval_chain_phase  in  varchar2
         ,p_approval_id           out nocopy number
         )
IS

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Insert_Approval';


  l_approval_id     number(15);


  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

       -----------------------------------------------------
       debugInfo := 'Get a new approval ID';
       -----------------------------------------------------
       select ia_request_approvals_s.nextval
       into l_approval_id
       from dual;

       -----------------------------------------------------
       debugInfo := 'Insert into IA_REQUEST_APPROVALS';
       -----------------------------------------------------
       insert into ia_request_approvals
       (approval_id
       ,request_id
       ,approver_id
       ,status
       ,transaction_date
       ,approval_chain_phase
       ,created_by
       ,creation_date
       ,last_update_date
       ,last_updated_by
       ,last_update_login
       )
       values(l_approval_id
             ,p_request_id
             ,p_approver_id
             ,p_approval_status
             ,NULL
             ,p_approval_chain_phase
             ,nvl(to_number(FND_PROFILE.VALUE('USER_ID')),-1)
             ,sysdate
             ,sysdate
             ,nvl(to_number(FND_PROFILE.VALUE('USER_ID')),-1)
             ,nvl(to_number(FND_PROFILE.VALUE('LOGIN_ID')),-1)
             );

       p_approval_id := l_approval_id;

       commit;

EXCEPTION
        WHEN OTHERS THEN
          rollback;
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');
END Insert_Approval;
*/

/*
PROCEDURE Repopulate_Approvers_List
         (p_request_id            in  number,
          p_releasing_approvers   in  AME_UTIL.approversTable,
          p_receiving_approvers   in  AME_UTIL.approversTable
         )
IS

  debugInfo             VARCHAR2(255)   := NULL;

  l_error_message	VARCHAR2(2000);

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Repopulate_Approvers_List';

  itemkey 		NUMBER(15)	:= p_request_id;

  tempApprovers		 	AME_UTIL.approversTable;
  l_list_id   			NUMBER(15);
  l_approver_id 		NUMBER(15);
  l_ame_approval_status 	VARCHAR2(30);
  l_approval_status 		VARCHAR2(30);
  l_chain_phase 		VARCHAR2(30);
  l_phase_id			NUMBER(15);
  l_approval_order 		NUMBER(15) := 0;

  l_pending_approver_skipped	VARCHAR2(1);

--  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  -----------------------------------------------------
  debugInfo := 'Delete rows from IA_APPROVERS_LIST_T';
  IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                   p_calling_fn => callingProgram,
                                   p_parameter1 => debugInfo);

  -----------------------------------------------------
  begin
    delete from ia_approvers_list_t
    where request_id = p_request_id;
  exception
    when others then
      null;
  end;

  l_approval_order := 0;
  l_pending_approver_skipped := 'N';

  for l_phase_id in 1 .. 2 loop

     if ( l_phase_id = 1 ) then
       tempApprovers := p_releasing_approvers;
       l_chain_phase := IA_WF_UTIL_PKG.ApprovalTypeReleasing;
     else
       tempApprovers := p_receiving_approvers;
       l_chain_phase := IA_WF_UTIL_PKG.ApprovalTypeDestination;
     end if;

     for i in 1 .. tempApprovers.count loop

       l_approval_order := l_approval_order + 1;
       l_ame_approval_status := tempApprovers(i).approval_status;

       * Please note that a person whose approval_status is null
        * is required to approve for a given request *

       if (l_ame_approval_status is NULL and l_pending_approver_skipped = 'N') then

         l_pending_approver_skipped := 'Y';

       elsif (l_ame_approval_status is NULL and l_pending_approver_skipped = 'Y') then

         -----------------------------------------------------
         debugInfo := 'Get a new list ID';
         IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                          p_calling_fn => callingProgram,
                                          p_parameter1 => debugInfo);
         -----------------------------------------------------
         select ia_approvers_list_t_s.nextval
         into l_list_id
         from dual;

         l_approver_id := tempApprovers(i).person_id;

         -----------------------------------------------------
         debugInfo := 'Insert into IA_APPROVERS_LIST_T';
         IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                          p_calling_fn => callingProgram,
                                          p_parameter1 => debugInfo);
         -----------------------------------------------------
         insert into ia_approvers_list_t
         (list_id
         ,request_id
         ,approver_id
         ,approval_order
         ,status
         ,approval_chain_phase
         ,created_by
         ,creation_date
         ,last_update_date
         ,last_updated_by
         ,last_update_login
         )
         values(l_list_id
               ,p_request_id
               ,l_approver_id
               ,l_approval_order
               ,IA_WF_UTIL_PKG.ApprovalStatusPendingApproval -- PENDING
               ,l_chain_phase
               ,nvl(to_number(FND_PROFILE.VALUE('USER_ID')),-1)
               ,sysdate
               ,sysdate
               ,nvl(to_number(FND_PROFILE.VALUE('USER_ID')),-1)
               ,nvl(to_number(FND_PROFILE.VALUE('LOGIN_ID')),-1)
               );

       end if;

     end loop;

  end loop;

  commit;

EXCEPTION
        WHEN OTHERS THEN
          rollback;
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');
END Repopulate_Approvers_List;
*/


/*
PROCEDURE Update_Approval_Notify
         (p_approval_id      in number
         ,p_notification_id  in number
         ,p_user_comment     in varchar2
         )
IS

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Update_Approval_Notify';

BEGIN

  update ia_request_approvals
  set notification_id = p_notification_id
     ,user_comment = p_user_comment
     ,last_update_date = SYSDATE
     ,last_updated_by = nvl(to_number(FND_PROFILE.VALUE('USER_ID')),-1)
     ,last_update_login = nvl(to_number(FND_PROFILE.VALUE('LOGIN_ID')),-1)
  where approval_id = p_approval_id;

END Update_Approval_Notify;
*/

/*
PROCEDURE Update_Approval_Status
         (p_approval_id      in number
         ,p_chain_phase      in varchar2
         ,p_approval_status  in varchar2
         )
IS

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Update_Approval_Status';

  tempApprover      AME_UTIL.approverRecord;

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  update ia_request_approvals
  set status = p_approval_status
     ,approval_chain_phase = p_chain_phase
     ,transaction_date = SYSDATE
     ,last_update_date = SYSDATE
     ,last_updated_by = nvl(to_number(FND_PROFILE.VALUE('USER_ID')),-1)
     ,last_update_login = nvl(to_number(FND_PROFILE.VALUE('LOGIN_ID')),-1)
  where approval_id = p_approval_id;

  COMMIT;

END Update_Approval_Status;
*/

PROCEDURE Update_Request_Header_Status
         (p_request_id       in number
         ,p_status           in varchar2
         )
IS

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Update_Request_Header_Status';

--  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  update ia_request_headers
  set status = p_status
     ,last_update_date = SYSDATE
     ,last_updated_by = nvl(to_number(FND_PROFILE.VALUE('USER_ID')),-1)
     ,last_update_login = nvl(to_number(FND_PROFILE.VALUE('LOGIN_ID')),-1)
  where request_id = p_request_id;

  COMMIT;

END Update_Request_Header_Status;


PROCEDURE Update_Request_Line_Status
         (p_request_id       in number
         ,p_status           in varchar2
         )
IS

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Update_Request_Line_Status';

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  /* We are updating the status only when the current status is 'PENDING'
  * since Super user can intervene the process by changing the line-level detail status.
  * As per a discussion with project team on Feb 19, 2004, we will have Super user see
  * the requests with status PENDING, POST, ON_REVIEW, or ON_HOLD on the SuperUser page.
  */
  update ia_request_details
  set status = p_status
     ,last_update_date = SYSDATE
     ,last_updated_by = nvl(to_number(FND_PROFILE.VALUE('USER_ID')),-1)
     ,last_update_login = nvl(to_number(FND_PROFILE.VALUE('LOGIN_ID')),-1)
  where request_id = p_request_id
    and status = IA_WF_UTIL_PKG.LineStatusPending;

  COMMIT;

END Update_Request_Line_Status;


PROCEDURE Send_Response_Notification
         (itemtype  in varchar2
         ,itemkey   in varchar2
         ,actid     in number
         ,funcmode  in varchar2
         ,result    out nocopy varchar2)
IS

  l_request_id		NUMBER(15) := -1;
  l_approval_id		NUMBER(15) := -1;
  l_approver_role	VARCHAR2(320);
  l_notification_id	NUMBER(15);

  l_user_comment	VARCHAR2(4000) := NULL;

BEGIN

  if (funcmode = 'RUN') then

    l_request_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                               ,itemkey  => itemkey
                                               ,aname    => 'REQUEST_ID');

    l_approval_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                ,itemkey  => itemkey
                                                ,aname    => 'APPROVAL_ID');

    l_approver_role := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                ,itemkey  => itemkey
                                                ,aname    => 'APPROVER_ROLE');

    l_notification_id := WF_NOTIFICATION.SEND(
                            role     => l_approver_role,
                            msg_type => itemtype,
                            msg_name => 'IA_MSG_REQUIRE_APPROVAL');

    commit; -- absolutely necessary for notification ?

    /* COMMENTED OUT DUE TO NEW STANDARD WORKFLOW
    Update_Approval_Notify(p_approval_id     => l_approval_id
                          ,p_notification_id => l_notification_id
                          ,p_user_comment    => l_user_comment);
    */

    result := 'COMPLETE:XXXXXXX';


  elsif (funcmode = 'CANCEL') THEN

      result := 'COMPLETE';

  end if;



END Send_Response_Notification;

PROCEDURE Process_Approved
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2)
IS

  debugInfo             VARCHAR2(255)   := NULL;

  l_error_message	VARCHAR2(2000);

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Process_Approved';

  l_request_id		NUMBER(15);
  l_chain_phase		VARCHAR2(30);
  l_approval_id		NUMBER(15);
  l_approver_id		NUMBER(15);

  tempApprover 		AME_UTIL.approverRecord;

BEGIN

  if (funcmode = 'RUN') then
    -----------------------------------------------------
    debugInfo := 'Get request ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_request_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                               ,itemkey => itemkey
                                               ,aname => 'REQUEST_ID');

    -----------------------------------------------------
    l_chain_phase := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                             ,itemkey => itemkey
                                             ,aname => 'APPROVAL_CHAIN_PHASE');

    -----------------------------------------------------
    debugInfo := 'Get approval ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_approval_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                ,itemkey => itemkey
                                                ,aname => 'APPROVAL_ID');

    -----------------------------------------------------
    debugInfo := 'Get approver ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                ,itemkey => itemkey
                                                ,aname => 'APPROVER_ID');

    tempApprover.person_id := l_approver_id;
    tempApprover.approval_status := AME_UTIL.approvedStatus;

    -----------------------------------------------------
    debugInfo := 'Update Approval Status';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    -- Bug#5002756: Disabled UpdateApprovalStatus in case of CostCenter method
    if (IA_WF_UTIL_PKG.GetApprovalMethod(p_rule_id        => WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                                                        ,itemkey => itemkey
                                                                                        ,aname => 'RULE_ID')
                                        ,p_book_type_code => WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                                                      ,itemkey => itemkey
                                                                                      ,aname => 'BOOK_TYPE_CODE')
                                    )
           = IA_WF_UTIL_PKG.ApprovalMethodHierarchy ) then

      if (not IA_AME_REQUEST_PKG.UpdateApprovalStatus(RequestId  => l_request_id
                                                     ,ChainPhase => l_chain_phase
                                                     ,Approver   => tempApprover)) then
         FND_MESSAGE.set_name('IA', 'IA_AME_UPDATE_STATUS_ERROR'); -- Error occurred when updating approval status in AME.
         l_error_message := FND_MESSAGE.Get;
         raise localException;
      end if;
    end if;

    -----------------------------------------------------
    debugInfo := 'Set the current approval status to Approved';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    /* COMMENTED OUT DUE TO NEW STANDARD WORKFLOW
    Update_Approval_Status(p_approval_id     => l_approval_id
                          ,p_chain_phase     => l_chain_phase
                          ,p_approval_status => IA_WF_UTIL_PKG.ApprovalStatusApproved);
    */

  elsif (funcmode = 'CANCEL') THEN

      result := 'COMPLETE';

  end if;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');
          result := 'COMPLETE:ERROR';

          WF_CORE.Context(IA_WF_UTIL_PKG.WF_TransactionType, callingProgram,
                          itemtype, itemkey, to_char(actid), debugInfo);
          RAISE;

END Process_Approved;

PROCEDURE Process_Delegated
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2)
IS

  debugInfo             VARCHAR2(255)   := NULL;

  l_error_message	VARCHAR2(2000);

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Process_Delegated';

  l_request_id          NUMBER(15);
  l_chain_phase		VARCHAR2(30);
  l_approval_id   	NUMBER(15);
  l_approver_id         NUMBER(15);
  l_delegatee_id        NUMBER(15);

  tempApprover 		AME_UTIL.approverRecord;
  tempDelegatee 	AME_UTIL.approverRecord;

BEGIN

  if (funcmode = 'RUN') then
    -----------------------------------------------------
    debugInfo := 'Get request ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_request_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                               ,itemkey => itemkey
                                               ,aname => 'REQUEST_ID');

    -----------------------------------------------------
    l_chain_phase := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                              ,itemkey => itemkey
                                              ,aname => 'APPROVAL_CHAIN_PHASE');

    -----------------------------------------------------
    debugInfo := 'Get current approval ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_approval_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                ,itemkey => itemkey
                                                ,aname => 'APPROVAL_ID');

    -----------------------------------------------------
    debugInfo := 'Get approver ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                ,itemkey => itemkey
                                                ,aname => 'APPROVER_ID');

    IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, l_approver_id);

    -----------------------------------------------------
    debugInfo := 'Get delegatee ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_delegatee_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                 ,itemkey => itemkey
                                                 ,aname => 'DELEGATEE_ID');

    IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, l_delegatee_id);

    tempApprover.user_id := NULL;
    tempApprover.person_id := l_approver_id;
    tempApprover.authority := AME_UTIL.authorityApprover; -- ???
    tempApprover.approval_status := AME_UTIL.forwardStatus;

    tempDelegatee.person_id := l_delegatee_id;
    tempDelegatee.api_insertion := AME_UTIL.apiInsertion;
    tempDelegatee.authority := AME_UTIL.authorityApprover;
    tempDelegatee.approval_status := NULL;

    -----------------------------------------------------
    debugInfo := 'Update AME Approval Status';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    -- Bug#5002756: Disabled UpdateApprovalStatus in case of CostCenter method
    if (IA_WF_UTIL_PKG.GetApprovalMethod(p_rule_id        => WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                                                    ,itemkey => itemkey
                                                                                    ,aname => 'RULE_ID')
                                        ,p_book_type_code => WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                                                    ,itemkey => itemkey
                                                                                    ,aname => 'BOOK_TYPE_CODE')
                                    )
           = IA_WF_UTIL_PKG.ApprovalMethodHierarchy ) then
      if (not IA_AME_REQUEST_PKG.UpdateApprovalStatus(RequestId  => l_request_id
                                                   ,ChainPhase => l_chain_phase
                                                   ,Approver   => tempApprover
                                                   ,Forwardee  => tempDelegatee)) then
         FND_MESSAGE.set_name('IA', 'IA_AME_UPDATE_STATUS_ERROR'); -- Error occurred when updating approval status in Oracle Approval Management.
         l_error_message := FND_MESSAGE.Get;
         raise localException;
      end if;
    end if;

    -----------------------------------------------------
    debugInfo := 'Set the current approval status to Delegated';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    /* COMMENTED OUT DUE TO NEW STANDARD WORKFLOW
    Update_Approval_Status(p_approval_id     => l_approval_id
                          ,p_chain_phase     => l_chain_phase
                          ,p_approval_status => IA_WF_UTIL_PKG.ApprovalStatusDelegated);
    */

  elsif (funcmode = 'CANCEL') THEN

      result := 'COMPLETE';

  end if;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');
          result := 'COMPLETE:ERROR';

          WF_CORE.Context(IA_WF_UTIL_PKG.WF_TransactionType, callingProgram||'--'||debugInfo||'--SQLERRM:'||substr(sqlerrm, 1, 240),
                          itemtype, itemkey, to_char(actid), debugInfo);
          RAISE;

END Process_Delegated;

PROCEDURE Process_Rejected
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2)
IS

  debugInfo             VARCHAR2(255)   := NULL;

  l_error_message	VARCHAR2(2000);

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Process_Rejected';

  l_request_id		NUMBER(15);
  l_chain_phase		VARCHAR2(30);
  l_approval_id		NUMBER(15);
  l_approver_id		NUMBER(15);

  tempApprover 		AME_UTIL.approverRecord;

BEGIN

  if (funcmode = 'RUN') then
    -----------------------------------------------------
    debugInfo := 'Get request ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_request_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                               ,itemkey => itemkey
                                               ,aname => 'REQUEST_ID');

    -----------------------------------------------------
    l_chain_phase := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                              ,itemkey => itemkey
                                              ,aname => 'APPROVAL_CHAIN_PHASE');

    -----------------------------------------------------
    debugInfo := 'Get approval ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_approval_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                ,itemkey => itemkey
                                                ,aname => 'APPROVAL_ID');

    -----------------------------------------------------
    debugInfo := 'Get approver ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                ,itemkey => itemkey
                                                ,aname => 'APPROVER_ID');

    tempApprover.person_id := l_approver_id;
    tempApprover.approval_status := AME_UTIL.rejectStatus;

    -----------------------------------------------------
    debugInfo := 'Update Approval Status';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    -- Bug#5002756: Disabled UpdateApprovalStatus in case of CostCenter method
    if (IA_WF_UTIL_PKG.GetApprovalMethod(p_rule_id        => WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                                                    ,itemkey => itemkey
                                                                                    ,aname => 'RULE_ID')
                                        ,p_book_type_code => WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                                                    ,itemkey => itemkey
                                                                                    ,aname => 'BOOK_TYPE_CODE')
                                    )
           = IA_WF_UTIL_PKG.ApprovalMethodHierarchy ) then
      if (not IA_AME_REQUEST_PKG.UpdateApprovalStatus(RequestId  => l_request_id
                                                   ,ChainPhase => l_chain_phase
                                                   ,Approver   => tempApprover)) then
         FND_MESSAGE.set_name('IA', 'IA_AME_UPDATE_STATUS_ERROR'); -- Error occurred when updating approval status in Oracle Approvals Management.
         l_error_message := FND_MESSAGE.Get;
         raise localException;
      end if;
    end if;

    -----------------------------------------------------
    debugInfo := 'Set the current approval status to Rejected';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    /* COMMENTED OUT DUE TO NEW STANDARD WORKFLOW
    Update_Approval_Status(p_approval_id     => l_approval_id
                          ,p_chain_phase     => l_chain_phase
                          ,p_approval_status => IA_WF_UTIL_PKG.ApprovalStatusRejected);
    */

    -----------------------------------------------------
    debugInfo := 'Set the current request status to Rejected';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    Update_Request_Header_Status(p_request_id  => l_request_id
                                ,p_status      => IA_WF_UTIL_PKG.HeaderStatusRejected);

    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                              itemkey  => itemkey,
                              aname    => 'REQUEST_STATUS',
                              avalue   => IA_WF_UTIL_PKG.HeaderStatusRejected);

    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                              itemkey  => itemkey,
                              aname    => 'REQUEST_STATUS_DISP',
                              avalue   => IA_WF_UTIL_PKG.GetLookupMeaning(p_lookup_type=>'REQ_HDR_STATUS',
                                                                          p_lookup_code=>IA_WF_UTIL_PKG.HeaderStatusRejected));
    -----------------------------------------------------
    debugInfo := 'Set the current detail status to Rejected';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    Update_Request_Line_Status(p_request_id  => l_request_id
                              ,p_status      => IA_WF_UTIL_PKG.LineStatusRejected);

  elsif (funcmode = 'CANCEL') THEN

      result := 'COMPLETE';

  end if;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');
          result := 'COMPLETE:ERROR';

          WF_CORE.Context(IA_WF_UTIL_PKG.WF_TransactionType, callingProgram,
                          itemtype, itemkey, to_char(actid), debugInfo);
          RAISE;

END Process_Rejected;

PROCEDURE Process_Cancelled
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2)
IS

  debugInfo             VARCHAR2(255)   := NULL;

  l_error_message	VARCHAR2(2000);

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Process_Cancelled';

  l_request_id		NUMBER(15);
  l_chain_phase		VARCHAR2(30);
  l_approval_id		NUMBER(15);
  l_approver_id		NUMBER(15);

  tempApprover 		AME_UTIL.approverRecord;

BEGIN

  if (funcmode = 'RUN') then
    -----------------------------------------------------
    debugInfo := 'Get request ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_request_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                               ,itemkey => itemkey
                                               ,aname => 'REQUEST_ID');

    -----------------------------------------------------
    l_chain_phase := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                              ,itemkey => itemkey
                                              ,aname => 'APPROVAL_CHAIN_PHASE');

    -----------------------------------------------------
    debugInfo := 'Get approval ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_approval_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                ,itemkey => itemkey
                                                ,aname => 'APPROVAL_ID');

    -----------------------------------------------------
    debugInfo := 'Get approver ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                ,itemkey => itemkey
                                                ,aname => 'APPROVER_ID');


    /****
    -----------------------------------------------------
    debugInfo := 'Set the current approval status to Rejected';
    -----------------------------------------------------
    Update_Approval_Status(p_approval_id     => l_approval_id
                          ,p_chain_phase     => l_chain_phase
                          ,p_approval_status => IA_WF_UTIL_PKG.ApprovalStatusRejected);

    -----------------------------------------------------
    debugInfo := 'Set the current request status to Rejected';
    -----------------------------------------------------
    Update_Request_Header_Status(p_request_id  => l_request_id
                                ,p_status      => IA_WF_UTIL_PKG.HeaderStatusRejected);

    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                              itemkey  => itemkey,
                              aname    => 'REQUEST_STATUS',
                              avalue   => IA_WF_UTIL_PKG.HeaderStatusRejected);

    WF_ENGINE.SetItemAttrText(itemtype => IA_WF_UTIL_PKG.WF_TransactionType,
                              itemkey  => itemkey,
                              aname    => 'REQUEST_STATUS_DISP',
                              avalue   => IA_WF_UTIL_PKG.GetLookupMeaning(p_lookup_type=>'REQ_HDR_STATUS',
                                                                          p_lookup_code=>IA_WF_UTIL_PKG.HeaderStatusRejected));
    ****/


  elsif (funcmode = 'CANCEL') THEN

      result := 'COMPLETE';

  end if;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');
          result := 'COMPLETE:ERROR';

          WF_CORE.Context(IA_WF_UTIL_PKG.WF_TransactionType, callingProgram,
                          itemtype, itemkey, to_char(actid), debugInfo);
          RAISE;

END Process_Cancelled;

PROCEDURE Update_ApprovalStatus_To_Final
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2)
IS

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Update_ApprovalStatus_To_Final';

  l_approvals_required  VARCHAR2(3);

  l_request_id		NUMBER(15);
  l_chain_phase		VARCHAR2(30);
  l_approval_id		NUMBER(15);

BEGIN

  if (funcmode = 'RUN') then

    -----------------------------------------------------
    debugInfo := 'Get request ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_request_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                               ,itemkey => itemkey
                                               ,aname => 'REQUEST_ID');

    -----------------------------------------------------
    debugInfo := 'Get approvals required flag';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_approvals_required := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                       ,itemkey => itemkey
                                                       ,aname => 'APPROVALS_REQUIRED');

    if (l_approvals_required = 'YES') then
      -----------------------------------------------------
      debugInfo := 'Get approval chain phase';
      l_chain_phase := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                ,itemkey => itemkey
                                                ,aname => 'APPROVAL_CHAIN_PHASE');

      -----------------------------------------------------
      debugInfo := 'Get approval ID';
      IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                       p_calling_fn => callingProgram,
                                       p_parameter1 => debugInfo);
      -----------------------------------------------------
      l_approval_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey => itemkey
                                                  ,aname => 'APPROVAL_ID');

      -----------------------------------------------------
      debugInfo := 'Update Approval Status to Finally Approved';
      IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                       p_calling_fn => callingProgram,
                                       p_parameter1 => debugInfo);
      -----------------------------------------------------
      /* COMMENTED OUT DUE TO NEW STANDARD WORKFLOW
      Update_Approval_Status(p_approval_id     => l_approval_id
                            ,p_chain_phase     => l_chain_phase
                            ,p_approval_status => IA_WF_UTIL_PKG.ApprovalStatusFinallyApproved);
      */
    end if;

    -----------------------------------------------------
    debugInfo := 'Update Header Status to Approved';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    Update_Request_Header_Status(p_request_id  => l_request_id
                                ,p_status      => IA_WF_UTIL_PKG.HeaderStatusApproved);

    WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'REQUEST_STATUS',
                              avalue   => IA_WF_UTIL_PKG.HeaderStatusApproved);

    WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'REQUEST_STATUS_DISP',
                              avalue   => IA_WF_UTIL_PKG.GetLookupMeaning(p_lookup_type=>'REQ_HDR_STATUS',
                                                                          p_lookup_code=>IA_WF_UTIL_PKG.HeaderStatusApproved));

    result := 'COMPLETE:OK';

  elsif (funcmode = 'CANCEL') THEN

    result := 'COMPLETE';

  end if;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');
          result := 'COMPLETE:ERROR';

          WF_CORE.Context(IA_WF_UTIL_PKG.WF_TransactionType, callingProgram,
                          itemtype, itemkey, to_char(actid), debugInfo);
          RAISE;

END Update_ApprovalStatus_To_Final;

PROCEDURE SuperUser_Approval_Required
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2)
IS

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'SuperUser_Approval_Required';


  l_approval_id		NUMBER(15);
  l_rule_id		NUMBER(15);

  l_superuser_required  VARCHAR2(1);

  l_book_type_code	VARCHAR2(30);

BEGIN

  if (funcmode = 'RUN') then
    -----------------------------------------------------
    debugInfo := 'Get approval ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_approval_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                ,itemkey => itemkey
                                                ,aname => 'APPROVAL_ID');

    -----------------------------------------------------
    debugInfo := 'Get rule ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_rule_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                            ,itemkey => itemkey
                                            ,aname => 'RULE_ID');

    -----------------------------------------------------
    debugInfo := 'Get Book Type Code';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_book_type_code := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                 ,itemkey => itemkey
                                                 ,aname => 'BOOK_TYPE_CODE');

    -----------------------------------------------------
    debugInfo := 'Check whether Super User approval is required';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_superuser_required := IA_WF_UTIL_PKG.IsSuperUserApprovalRequired(l_rule_id
                                                                      ,l_book_type_code);

    result := 'COMPLETE:'||l_superuser_required;

  elsif (funcmode = 'CANCEL') THEN

      result := 'COMPLETE';

  end if;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');
          result := 'COMPLETE:ERROR';

          WF_CORE.Context(IA_WF_UTIL_PKG.WF_TransactionType, callingProgram,
                          itemtype, itemkey, to_char(actid), debugInfo);
          RAISE;

END SuperUser_Approval_Required;

PROCEDURE Update_LineStatus_To_OnReview
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2)
IS

  l_request_id number(15);

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Update_LineStatus_To_Post';

BEGIN

  if (funcmode = 'RUN') then
    -----------------------------------------------------
    debugInfo := 'Get request ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_request_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                               ,itemkey => itemkey
                                               ,aname => 'REQUEST_ID');

    -----------------------------------------------------
    debugInfo := 'Update request line status to ON_REVIEW';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    Update_Request_Line_Status(p_request_id  => l_request_id
                              ,p_status      => IA_WF_UTIL_PKG.LineStatusOnReview);

  elsif (funcmode = 'CANCEL') THEN

      result := 'COMPLETE';

  end if;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');
          result := 'COMPLETE:ERROR';

          WF_CORE.Context(IA_WF_UTIL_PKG.WF_TransactionType, callingProgram,
                          itemtype, itemkey, to_char(actid), debugInfo);
          RAISE;

END Update_LineStatus_To_OnReview;

PROCEDURE Update_LineStatus_To_Post
         (itemtype in varchar2
         ,itemkey in varchar2
         ,actid in number
         ,funcmode in varchar2
         ,result out nocopy varchar2)
IS

  l_request_id number(15);

  debugInfo             VARCHAR2(255)   := NULL;

  localException        EXCEPTION;

  callingProgram        VARCHAR2(80)    := 'Update_LineStatus_To_Post';

BEGIN

  if (funcmode = 'RUN') then

    -----------------------------------------------------
    debugInfo := 'Get request ID';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    l_request_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                               ,itemkey => itemkey
                                               ,aname => 'REQUEST_ID');

    -----------------------------------------------------
    debugInfo := 'Update request line status to POST';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    Update_Request_Line_Status(p_request_id  => l_request_id
                              ,p_status      => IA_WF_UTIL_PKG.LineStatusPost);


    /*
       Added for Super User Feature
    */
    -----------------------------------------------------
    debugInfo := 'Update Header Status to Post';
    IA_WF_UTIL_PKG.AddWFDebugMessage(p_request_id => itemkey,
                                     p_calling_fn => callingProgram,
                                     p_parameter1 => debugInfo);
    -----------------------------------------------------
    Update_Request_Header_Status(p_request_id  => l_request_id
                                ,p_status      => IA_WF_UTIL_PKG.HeaderStatusPost);

    WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'REQUEST_STATUS',
                              avalue   => IA_WF_UTIL_PKG.HeaderStatusPost);

    WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'REQUEST_STATUS_DISP',
                              avalue   => IA_WF_UTIL_PKG.GetLookupMeaning(p_lookup_type=>'REQ_HDR_STATUS',
                                                                          p_lookup_code=>IA_WF_UTIL_PKG.HeaderStatusPost));

    result := 'COMPLETE:OK';

  elsif (funcmode = 'CANCEL') THEN

      result := 'COMPLETE';

  end if;

EXCEPTION
        WHEN OTHERS THEN
          FA_SRVR_MSG.add_message(
                         calling_fn => callingProgram||':'||debugInfo);
          FA_SRVR_MSG.Add_SQL_Error(
                         calling_fn => callingProgram);
          IA_WF_UTIL_PKG.AddDebugMessage(callingProgram, debugInfo, 'Error');
          result := 'COMPLETE:ERROR';

          WF_CORE.Context(IA_WF_UTIL_PKG.WF_TransactionType, callingProgram,
                          itemtype, itemkey, to_char(actid), debugInfo);
          RAISE;

END Update_LineStatus_To_Post;

END IA_WF_REQUEST_PKG;

/
