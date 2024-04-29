--------------------------------------------------------
--  DDL for Package Body PAY_ASSG_COST_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ASSG_COST_WF" as
/* $Header: pyacoswf.pkb 120.1.12010000.7 2009/02/04 06:07:19 pgongada noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_ASSG_COST_WF.';
g_debug boolean := hr_utility.debug_enabled;
g_approver    ame_util.approversTable2;
  /*Used to get the transaction id pertaining to the specified
    item type and item key. If the transaction id does not exists
    then it will create starting a transaction.*/
  FUNCTION GET_TRANSACTION_ID(
                itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funcmode    in varchar2) RETURN NUMBER IS

  l_transaction_id HR_API_TRANSACTIONS.TRANSACTION_ID%TYPE;
  l_result         varchar2(100);
  l_performer_id   number(10);
  l_proc  varchar2(100) := g_package||'GET_TRANSACTION_ID';
  BEGIN
    hr_utility.set_location('Entering ... '||l_proc,10);
    l_transaction_id     := wf_engine.GetItemAttrNumber(
                                itemtype         => itemtype
                               ,itemkey          => itemkey
                               ,aname            => 'TRANSACTION_ID'
                               ,ignore_notfound  => false
                               );
    /*If no transaction exists, start a transaction.*/
    IF L_TRANSACTION_ID IS NULL THEN
      hr_utility.set_location(l_proc || '....Step1',20);
      l_performer_id := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'PERFORMER_PERSON_ID');

      hr_utility.set_location(l_proc , 30);

      hr_transaction_ss.start_transaction
      (itemtype    =>    itemtype
      ,itemkey     =>    itemkey
      ,actid       =>    actid
      ,funmode     =>    'RUN'
      ,p_login_person_id => l_performer_id
      ,result      => l_result);
      hr_utility.set_location(l_proc, 40);

      /*Gett the newly created transaction and set as workflow attribute*/
      l_transaction_id:= hr_transaction_ss.get_transaction_id
                         (p_item_type   =>   itemtype
                         ,p_item_key    =>   itemkey);
      wf_engine.SetItemAttrNumber(itemtype,itemkey,'TRANSACTION_ID',l_transaction_id);
      hr_utility.set_location(l_proc ,50);

    END IF;
    hr_utility.set_location('Leaving....'||l_proc ,60);
    RETURN l_transaction_id;

  END GET_TRANSACTION_ID;
procedure check_approvers_exist
               (itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funcmode    in varchar2,
                resultout   out nocopy varchar2)
  is
    all_approvers    ame_util.approversTable2;
    next_approver    ame_util.approversTable2;
    l_transaction_id HR_API_TRANSACTIONS.TRANSACTION_ID%TYPE;
    l_apprvl_process_complete varchar2(1000);
    l_proc varchar2(72) := g_package||'check_approvers_exist';
    l_flagApproversAsNotified  varchar2(10);
    l_role_name varchar2(240);
    l_role_display_name varchar2(240);

    l_wf_admin	     ame_util.approverRecord2;
    l_admin_name varchar2(240);
    l_admin_display_name varchar2(240);
  begin
      hr_utility.set_location('Entering:'|| l_proc, 10);
      /*Get the transaction id*/
      l_transaction_id     := get_transaction_id(
                                itemtype         => itemtype
                               ,itemkey          => itemkey
                               ,actid            => actid
                               ,funcmode         => funcmode
                               );
      /*Find out any approvers are there. If there are no approvers then
      the following call raise exception. Catch that exception and set the
      resultout to 'F'. The WF/AME Admin gets the notification of no approver.
      Once he setup the approver then the notification would go to the approver
      as expected. We are not supposed to reject any Workflow in the absense of
      approver.*/

      hr_utility.set_location(l_proc, 20);
      resultout := ame_util.booleanTrue;
      begin
	      ame_api2.getNextApprovers4(
        	          applicationIdIn               => 801,
                	  transactionTypeIn             => 'PAY_ASSIGNMENT_COSTING',
	                  transactionIdIn               => l_transaction_id,
        	          approvalProcessCompleteYNOut  => l_apprvl_process_complete,
                	  nextApproversOut              => g_approver);
              if (l_apprvl_process_complete = ame_util.booleanTrue) then
		resultout := 'F';
              else
		resultout := 'T';
              end if;
     	      EXCEPTION
		/*This is to catch the exception when there is no approver etc.
		Once the exception raises, then the AME/workflow admin will get
		the notification with the exception message raised.*/
		when OTHERS then
                wf_engine.setItemAttrText(itemtype, itemkey,'AME_EXCEPTION',SQLERRM(SQLCODE));
                resultout:='F';
     end;
     if resultout <> 'F' and l_apprvl_process_complete <> ame_util.booleanTrue then
	/*First clear all approvers, then get the approver again. This is to by-pass
          NO_DATA_FOUND exception. This situation occurs when there is no approver
          and resume the workflow after setting the approver.*/
        ame_api2.clearAllApprovals(
                APPLICATIONIDIN              => 801,
                TRANSACTIONTYPEIN            => 'PAY_ASSIGNMENT_COSTING',
                TRANSACTIONIDIN              => l_transaction_id);
        /*Now get the approver again*/
        ame_api2.getNextApprovers4(
        	          applicationIdIn               => 801,
                	  transactionTypeIn             => 'PAY_ASSIGNMENT_COSTING',
	                  transactionIdIn               => l_transaction_id,
        	          approvalProcessCompleteYNOut  => l_apprvl_process_complete,
                	  nextApproversOut              => g_approver);
        if (l_apprvl_process_complete <> ame_util.booleanTrue) then
		wf_engine.setItemAttrText(itemtype, itemkey,'APPROVER_LOGIN_NAME',g_approver(1).name);
		wf_directory.GetRoleName(p_orig_system       => NVL(g_approver(1).orig_system,'PER')
                                  ,p_orig_system_id    => g_approver(1).orig_system_id
                                  ,p_name              => l_role_name
                                  ,p_display_name      => l_role_display_name);
	         wf_engine.setItemAttrText(itemtype, itemkey,'APPROVER_NAME',l_role_display_name);
        	 resultout:='T';
	end if;
     end if;
              EXCEPTION
	        when OTHERS then
                resultout:='F';
 end check_approvers_exist;


  -- ------------------------------------------------------------------------
  -- |-------------------------< GET_NEXT_APPROVER >-------------------------|
  -- ------------------------------------------------------------------------
 procedure get_next_approver
              (itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funcmode    in varchar2,
                resultout   out nocopy varchar2) is

    l_current_approver      ame_util.approversTable2 := g_approver;
    l_next_approver         ame_util.approversTable2;

    l_transaction_id HR_API_TRANSACTIONS.TRANSACTION_ID%TYPE;
    l_apprvl_process_complete varchar2(1000);
    l_proc varchar2(72);
    l_flagApproversAsNotified  varchar2(10);
    l_role_name varchar2(240);
    l_role_display_name varchar2(240);

  begin
      hr_utility.set_location('Entering ... '||l_proc, 10);
      /*Get the transaction id*/
      l_transaction_id     := get_transaction_id(
                                itemtype         => itemtype
                               ,itemkey          => itemkey
                               ,actid            => actid
                               ,funcmode         => funcmode
                               );

      /*Update the status of the previous approver to true as the control
      comes to this place once the approver approves it.*/

      hr_utility.set_location(l_proc,20);
      ame_api2.updateApprovalStatus2(
                  applicationIdIn             =>801,
                  transactionTypeIn           =>'PAY_ASSIGNMENT_COSTING',
                  transactionIdIn             =>l_transaction_id,
                  approvalStatusIn            => ame_util.approvedStatus,
                  approverNameIn              => wf_engine.getItemAttrText(itemtype, itemkey,'APPROVER_LOGIN_NAME'),
                  updateItemIn                => true);

      /*Now get the next approver.*/
      hr_utility.set_location(l_proc,30);
      ame_api2.getNextApprovers4(
                  applicationIdIn               => 801,
                  transactionTypeIn             => 'PAY_ASSIGNMENT_COSTING',
                  transactionIdIn               => l_transaction_id,
                  approvalProcessCompleteYNOut  => l_apprvl_process_complete,
                  nextApproversOut              => g_approver);

      /*If there are approvers, then send notifications to the approver(s) by setting
      the attribute APPROVER_LOGIN_NAME. Workflow sends notifications to the approvers
      If there are no approvers then we need to save the data. Once the resultout
      is set to 'F' workflow take care of saving the data by calling underlaying
      APIs*/
      hr_utility.set_location(l_proc, 40);
      if l_apprvl_process_complete = ame_util.booleanFalse then
          /*Set the previous approver attributes.*/
          wf_engine.setItemAttrText(itemtype, itemkey,'PREVIOUS_APPROVER_LOGIN_NAME',
				    wf_engine.getItemAttrText(itemtype, itemkey, 'APPROVER_LOGIN_NAME'));
          wf_engine.setItemAttrText(itemtype, itemkey,'PREVIOUS_APPROVER_NAME',
				    wf_engine.getItemAttrText(itemtype, itemkey, 'APPROVER_NAME'));

          /*Set the current approver attributes.*/
          wf_engine.setItemAttrText(itemtype, itemkey,'APPROVER_LOGIN_NAME',g_approver(1).name);
          /*Get the approver name from wf_roles.*/
          wf_directory.GetRoleName(p_orig_system       => NVL(g_approver(1).orig_system,'PER')
                                   ,p_orig_system_id    => g_approver(1).orig_system_id
                                   ,p_name              => l_role_name
                                   ,p_display_name      => l_role_display_name);
          wf_engine.setItemAttrText(itemtype, itemkey,'APPROVER_NAME',l_role_display_name);

          resultout := 'T';
      else
          resultout := 'F';
      end if;
      hr_utility.set_location('Leaving.....'||l_proc,50);
      EXCEPTION
	WHEN OTHERS THEN
	    hr_utility.set_location('An EXCEPTION occured '||SQLERRM(SQLCODE),60);
	    hr_utility.set_location('Leaving ..'||l_proc,1000);
        RAISE;
  end get_next_approver;
  -- ------------------------------------------------------------------------
  -- |--------------------------< START_WF_PROCESS>-------------------------|
  -- ------------------------------------------------------------------------
 procedure START_WF_PROCESS (P_PERSON_ID                IN NUMBER
                             ,P_ASSIGNMENT_ID            IN NUMBER
                             ,P_ITEM_KEY                 IN VARCHAR2
                             ,P_PERFORMER_LOGIN_NAME     IN VARCHAR2
                             ,P_PERFORMER_ID             in number
                             ,P_EFFECTIVE_DATE           IN DATE
            			           ) is

  l_item_type       varchar2(8)   := 'PYASGWF';
  l_process         varchar2(30)  := 'PYASGWF_PROCESS';
  l_employee_name   varchar2(240) := null;
  l_requestor_name  varchar2(240);
  l_login_name      varchar2(240);
  l_proc            varchar2(72) ;
  --
  l_user_key varchar2(240) := p_Item_Key;
  --
  l_wf_admin	     ame_util.approverRecord2;
    l_admin_name varchar2(240);
    l_admin_display_name varchar2(240);

  CURSOR csr_person_name is
      select FULL_NAME
      from per_all_people_f
      where person_id = p_person_id
      and trunc(sysdate) between effective_start_date and effective_end_date;
  BEGIN
    hr_utility.set_location('Entering....'||l_proc,10);
    /*Create the workflow process.*/
    wf_engine.CreateProcess (ItemType       =>  l_Item_Type
                            ,ItemKey        =>  p_Item_Key
                            ,process        =>  l_process
                            ,User_Key       =>  l_user_key
                            ,Owner_Role     =>  'COREPAY'
                             );
    /*Get the person name whose values are getting changed.*/
    open csr_person_name;
    fetch csr_person_name into l_employee_name;
    close csr_person_name;

    /*Get the requestor details from AME.*/
    wf_directory.GetRoleName(p_orig_system       => 'PER'
                            ,p_orig_system_id    => p_performer_id
                            ,p_name              => l_login_name
                            ,p_display_name      => l_requestor_name);

    --
    /*Set Workflow attributes.*/
    wf_engine.setItemAttrNumber(l_item_type, p_item_key, 'CURRENT_PERSON_ID', P_PERSON_ID);
    wf_engine.setItemAttrNumber(l_item_type, p_item_key, 'CURRENT_ASSIGNMENT_ID',P_ASSIGNMENT_ID);
    wf_engine.setItemAttrText(l_item_type, p_item_key, 'PROCESS_NAME','PYASGWF_PROCESS');
    wf_engine.setItemAttrDate(l_item_type, p_item_key,'CURRENT_EFFECTIVE_DATE',SYSDATE);
    wf_engine.setItemAttrNumber(l_item_type, p_item_key,'PERFORMER_PERSON_ID',P_PERFORMER_ID);
    wf_engine.setItemAttrDate(l_item_type, p_item_key,'EFFECTIVE_DATE',P_EFFECTIVE_DATE);
    wf_engine.setItemAttrText(l_item_type, p_item_key, 'EMP_NAME', l_employee_name);
    wf_engine.setItemAttrText(l_item_type, p_item_key, 'REQUESTOR_LOGIN_NAME', P_PERFORMER_LOGIN_NAME);
    wf_engine.setItemAttrText(l_item_type, p_item_key, 'REQUESTOR_NAME', l_requestor_name);

    /*As the control comes here only for the first time. At this time only requestor would be there.
      So for the time being we are setting the previous approver details as the requestor.*/
    wf_engine.setItemAttrText(l_item_type, p_item_key, 'PREVIOUS_APPROVER_LOGIN_NAME', P_PERFORMER_LOGIN_NAME);
    wf_engine.setItemAttrText(l_item_type, p_item_key, 'PREVIOUS_APPROVER_NAME', l_requestor_name);

    /*Get the AME/workflow admin details and populate the attributes.*/
    ame_api2.getAdminApprover(applicationIdIn => 801,
                              transactionTypeIn => 'PAY_ASSIGNMENT_COSTING',
                              adminApproverOut  => l_wf_admin);
    wf_engine.setItemAttrText(l_item_type, p_item_key,'WF_ADMIN_LOGIN_NAME',l_wf_admin.name);
    wf_directory.GetRoleName(p_orig_system       => NVL(l_wf_admin.orig_system,'PER')
                            ,p_orig_system_id    => l_wf_admin.orig_system_id
                            ,p_name              => l_admin_name
                            ,p_display_name      => l_admin_display_name);
    wf_engine.setItemAttrText(l_item_type, p_item_key,'WF_ADMIN_NAME',l_admin_display_name);

    /*Start the created workflow process.*/
    wf_engine.StartProcess    (itemtype       => l_Item_Type
                               ,itemkey       => p_Item_Key
                               );
END START_WF_PROCESS;
  -- ------------------------------------------------------------------------
  -- |--------------------------< APPROVE_PROCESS >-------------------------|
  -- ------------------------------------------------------------------------
  PROCEDURE APPROVE_PROCESS(
   itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result       out    nocopy  varchar2) is
    l_transaction_id            HR_API_TRANSACTIONS.TRANSACTION_ID%TYPE;
    l_transaction_step_id       HR_UTIL_WEB.G_VARCHAR2_TAB_TYPE;
    l_api_name                  HR_UTIL_WEB.G_VARCHAR2_TAB_TYPE;
    l_row                       number;
    l_proc                      varchar2(255) := g_package||'APPROVE_PROCESS';
    l_api_to_call               varchar2(1000);
    l_actid                     WF_ITEM_ACTIVITY_STATUSES.process_activity%TYPE;
    l_effective_date            DATE;
  begin

    /*Set the previous approver attributes.*/
     wf_engine.setItemAttrText(itemtype, itemkey,'PREVIOUS_APPROVER_LOGIN_NAME',
                              wf_engine.getItemAttrText(itemtype, itemkey, 'APPROVER_LOGIN_NAME'));
     wf_engine.setItemAttrText(itemtype, itemkey,'PREVIOUS_APPROVER_NAME',
   			      wf_engine.getItemAttrText(itemtype, itemkey, 'APPROVER_NAME'));

    /* Get the transaction step id pertaining to the work flow process
    identified by the itemkey, itemkey and actid.*/
    hr_transaction_api.get_transaction_step_info(p_item_type   => itemtype
                                               ,p_item_key    => itemkey
                                               ,p_activity_id => 0 --l_actid
                                               ,p_transaction_step_id   => l_transaction_step_id
                                               ,p_api_name => l_api_name
                                               ,p_rows => l_row);
    /*l_row represents number of steps pertaining to itemtype, itemkey and actid.
    But in our case it's always one. So we assume it as one always.*/
    /*Call the API to save the data into base tables.*/
    for i in 0..l_row-1 loop
      /*Construct the API call*/
      l_api_to_call := 'Begin ';
      l_api_to_call := l_api_to_call || l_api_name(i)||'(';
      l_api_to_call := l_api_to_call || 'p_transaction_step_id => '||to_number(l_transaction_step_id(i));
      l_api_to_call := l_api_to_call || ' ); end;';

      /*Call the API*/
      EXECUTE IMMEDIATE (l_api_to_call);

    end loop;
    commit;
  end APPROVE_PROCESS;
  -- ------------------------------------------------------------------------
  -- |--------------------------< REJECT_PROCESS >--------------------------|
  -- ------------------------------------------------------------------------
  PROCEDURE REJECT_PROCESS(
   itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result       out    nocopy  varchar2) IS
  l_proc        varchar2(240) := g_package||'REJECT_PROCESS';
  l_result      varchar2(20);
BEGIN
  if g_debug then
    hr_utility.set_location('Entering ..'||l_proc,10);
  end if;

  hr_transaction_ss.rollback_transaction(
                    itemtype     => itemtype
                    ,itemkey     => itemkey
                    ,actid       => actid
                    ,funmode     => funmode
                    ,result      => l_result);
  if (l_result = 'SUCCESS') then
    hr_utility.set_location('Transaction deleted successfully ',20);
  else
    hr_utility.set_location('Error in deleting Transaction ',30);
  end if;
  if g_debug then
    hr_utility.set_location('Leaving ..'||l_proc,1000);
  end if;
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('An EXCEPTION occured',40);
      hr_utility.set_location('Leaving ..'||l_proc,1000);
      RAISE;
END REJECT_PROCESS;

end PAY_ASSG_COST_WF;

/
