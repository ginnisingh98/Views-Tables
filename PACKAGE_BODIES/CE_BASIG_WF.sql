--------------------------------------------------------
--  DDL for Package Body CE_BASIG_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BASIG_WF" as
/* $Header: cebasigwfb.pls 120.2.12010000.2 2009/03/26 12:06:41 csutaria ship $ */


  G_signatory_id	NUMBER(15);
  G_signatory_history_id NUMBER(15);
  G_approver_person_id NUMBER(15);
  G_rowid 	varchar2(20);

    g_name varchar2(100);
    g_display_name varchar2(100);
    g_requester_id number;
    g_single_limit_amount NUMBER;
    g_joint_limit_amount NUMBER;
    l_signatory_id	NUMBER;
    g_signatory_name VARCHAR2(100);
    g_bank_account_name CE_BANK_ACCOUNTS.BANK_ACCOUNT_NAME%TYPE;
    g_currency_code FND_CURRENCIES.CURRENCY_CODE%TYPE;
    g_org_id	NUMBER(15);

    g_start_date DATE;
    g_end_date DATE;
    g_other_limits CE_BA_SIGNATORIES.OTHER_LIMITS%TYPE;
    g_person_type CE_BA_SIGNATORIES_V.person_type%TYPE;
    g_person_job CE_BA_SIGNATORIES_V.person_job%TYPE;
    g_person_org_name CE_BA_SIGNATORIES_V.person_org_name%TYPE;
    g_person_location CE_BA_SIGNATORIES_V.person_location%type;
    g_bank_branch_name ce_bank_branches_v.bank_branch_name%type;
    g_bank_account_number ce_bank_accounts.bank_Account_num%type;
    g_signer_group CE_BA_SIGNATORIES_V.signer_group%type;



PROCEDURE initialize
 (fndApplicationIdIn in integer,
 transactionIdIn in varchar2,
 transactionTypeIn in varchar2 default null)

IS
	ameappid number;
	l_org_id number(15);
BEGIN
	FND_PROFILE.get('ORG_ID',l_org_id);
	FND_CLIENT_INFO.set_org_context(l_org_id);
	fnd_global.apps_initialize(fnd_profile.value('USER_ID'),
							fnd_profile.value('RESP_ID'),
							fnd_profile.value('RESP_APPL_ID'));

   	ame_api.clearAllApprovals(applicationIdIn => fndApplicationIdIn,
                              transactionIdIn => transactionidin,
                              transactionTypeIn => transactionTypeIn);
END;

procedure SELECT_NEXT_APPROVER(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
is
    tempApprover ame_util.approverRecord;
    l_emp_id	number;
    l_user_name fnd_user.user_name%TYPE;

begin

  --
  -- RUN mode - normal process execution
  --
	  if (funcmode = 'RUN') then

 	    ame_api.getNextApprover(applicationIdIn => 260,
                             transactionIdIn => itemkey,
                             transactionTypeIn => itemtype,
                             nextApproverOut => tempApprover);

	      IF(tempApprover.user_id IS NULL AND
		 tempApprover.person_id is null) THEN
			result := 'COMPLETE:F';
		return;
	      ELSE
	 	 WF_DIRECTORY.getusername('PER',tempApprover.person_id,
						g_name, g_display_name);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'APPROVER_NAME',
          			                   g_name);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'APPROVAL_DISPLAY_NAME',
          			                   g_display_name);

		WF_ENGINE.SetItemAttrNumber(itemtype,
								  itemkey,
								  'APPROVER_PERSON_ID',
								  tempapprover.person_id);

		    result  := 'COMPLETE:T';
		    return;
	      END IF;
	   END IF;
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  result := '';
  return;

exception
  when others then
    wf_core.context('CEBASIG', 'SELECT_NEXT_APPROVER',
		    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end SELECT_NEXT_APPROVER;

procedure UPDATE_SIGNATORY_HISTORY_APPR(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
is
begin

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

	G_signatory_id := WF_ENGINE.GetItemAttrNumber(
							itemtype,
							itemkey,
							'SIGNATORY_ID');

	G_approver_person_id := WF_ENGINE.GetItemAttrNumber(
							itemtype,
							itemkey,
							'APPROVER_PERSON_ID');

        ame_api.updateApprovalStatus2
		(applicationIdIn => 260,
		transactionIdIn => itemkey,
		approvalstatusin =>'APPROVED',
		approverpersonidIn => g_approver_person_id,
		transactionTypeIn => 'CEBASIG',
	        forwardeeIn => ame_util.emptyApproverRecord);

	Insert_history_record('APPROVED');

    result  := 'COMPLETE';
    return;
  end if;

  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  result := '';
  return;

exception
  when others then
    wf_core.context('CEBASIG', 'UPDATE_SIGNATORY_HISTORY_APPR',
		    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end UPDATE_SIGNATORY_HISTORY_APPR;

procedure UPDATE_SIGNATORY_HISTORY_REJ(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
is
begin

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


	G_signatory_id := WF_ENGINE.GetItemAttrNumber(
							itemtype,
							itemkey,
							'SIGNATORY_ID');

	G_approver_person_id := WF_ENGINE.GetItemAttrText(
							itemtype,
							itemkey,
							'APPROVER_PERSON_ID');

	Insert_history_record('REJECTED');

        ame_api.updateApprovalStatus2
		(applicationIdIn => 260,
		transactionIdIn => itemkey,
		approvalstatusin =>'REJECTED',
		approverpersonidIn => g_approver_person_id,
		transactionTypeIn => 'CEBASIG',
	        forwardeeIn => ame_util.emptyApproverRecord);

	result  := 'COMPLETE';
	return;
  end if;

  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  result := '';
  return;

exception
  when others then
    wf_core.context('CEBASIG', 'UPDATE_SIGNATORY_HISTORY_REJ',
		    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end UPDATE_SIGNATORY_HISTORY_REJ;

procedure APPROVE_SIGNATORY(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
is
    l_signatory_id NUMBER(15);
begin

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then
    l_signatory_id := WF_ENGINE.GetItemAttrNumber(itemtype,
										itemkey,
										'SIGNATORY_ID');
    UPDATE ce_ba_signatories
    SET status = 'APPROVED'
    WHERE signatory_id = l_signatory_id;

    result  := 'COMPLETE';
    return;
  end if;

  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  result := '';
  return;

exception
  when others then
    wf_core.context('CE_BASIG', 'APPROVE_SIGNATORY',
		    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end APPROVE_SIGNATORY;

procedure REJECT_SIGNATORY(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out  NOCOPY varchar2)
is
        l_signatory_id NUMBER(15);
begin

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    l_signatory_id := WF_ENGINE.GetItemAttrNumber(itemtype,
										itemkey,
										'SIGNATORY_ID');

    UPDATE ce_ba_signatories
    SET status = 'REJECTED'
    WHERE signatory_id = l_signatory_id;

    result  := 'COMPLETE';
    return;
  end if;


  --
  -- CANCEL mode - activity 'compensation'
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  result := '';
  return;

exception
  when others then
    wf_core.context('CEBASIG', 'REJECT_SIGNATORY',
		    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end REJECT_SIGNATORY;

PROCEDURE selector(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    command  in varchar2,
    result    in out  NOCOPY varchar2)
IS
	l_n_org_id number;
l_user_id number;
l_resp_id number;
l_resp_appl_id number;

BEGIN
	l_n_org_id := WF_ENGINE.GetItemAttrNumber(itemtype,
  					        itemkey,
  					        'ORG_ID');

	IF (command = 'RUN') THEN
		result := 'CEBASIG';
		return;
	ELSIF command = 'SET_CTX' THEN
		l_user_id := to_number(WF_ENGINE.GetItemAttrText(itemtype,itemkey,
							'USER_ID'));
		l_resp_id := to_number(WF_ENGINE.GetItemAttrText(itemtype,itemkey,
							'RESPONSIBILITY_ID'));
		l_resp_appl_id := to_number(WF_ENGINE.GetItemAttrText(itemtype,itemkey,
							'APPLICATION_ID'));
	        l_n_org_id := WF_ENGINE.GetItemAttrText(itemtype,
  					        itemkey,
  					        'ORG_ID');

		fnd_global.apps_initialize(l_user_id,
							l_resp_id,
							l_resp_appl_id);

	 	fnd_client_info.set_org_context(l_n_org_id);

		return;
	  ELSIF (command = 'TEST_CTX') THEN
 	   l_n_org_id := WF_ENGINE.GetItemAttrText(itemtype,
  					        itemkey,
  					        'ORG_ID');

  	   IF (nvl(rtrim(substrb(USERENV('CLIENT_INFO'), 1, 10)),'NULL') =
			nvl(to_char(l_n_org_id),'NULL')) THEN
	       result := 'TRUE';
	     ELSE
		result := 'NOTSET'; -- bug 8367571
	     END IF;
	END IF;
exception
  when others then
    wf_core.context('CEBASIG', 'SELECTOR',
		    itemtype, itemkey, to_char(actid), command);
    raise;

END selector;


PROCEDURE insert_history_record (p_action VARCHAR2)
IS
   BEGIN

	UPDATE ce_ba_signatory_hist_h
	SET 	current_record_flag='N'
	WHERE	signatory_id = G_signatory_id;

	CE_BA_SIGNATORY_HISTORY.insert_row
		(X_rowid => G_rowid,
		 X_Signatory_id => G_signatory_id,
		 X_Signatory_History_id	=> G_signatory_history_id,
		 X_Approver_person_id => G_approver_person_id,
		 X_Action => p_action,
		 X_Current_record_flag => 'Y',
                 X_Last_Updated_By  => FND_GLOBAL.user_id,
                 X_Last_Update_Date  => sysdate,
                 X_Last_Update_Login => FND_GLOBAL.login_id,
 		 X_Created_By        => FND_GLOBAL.user_id,
                 X_Creation_Date     => sysdate,
		 X_Attribute_category => null,
		 X_Attribute1	=> null,
		 X_Attribute2	=> null,
		 X_Attribute3	=> null,
		 X_Attribute4	=> null,
		 X_Attribute5	=> null,
		 X_Attribute6	=> null,
		 X_Attribute7	=> null,
		 X_Attribute8	=> null,
		 X_Attribute9	=> null,
		 X_Attribute10	=> null,
		 X_Attribute11  => null,
		 X_Attribute12  => null,
		 X_Attribute13  => null,
		 X_Attribute14  => null,
		 X_Attribute15  => null);
END insert_history_record;



PROCEDURE init_all(  itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    command  in varchar2,
    result    in out NOCOPY varchar2)
IS
 l_user_id NUMBER;
 l_resp_id NUMBER;
 l_resp_appl_id NUMBER;
 l_org_id NUMBER;
id number := itemkey;
BEGIN
	IF command='RUN' THEN
		initialize(260,id,'CEBASIG');
	fnd_global.apps_initialize(fnd_profile.value('USER_ID'),
							fnd_profile.value('RESP_ID'),
							fnd_profile.value('RESP_APPL_ID'));
		FND_PROFILE.get('ORG_ID',l_org_id);
	      fnd_client_info.set_org_context(l_org_id);

	FND_PROFILE.get('ORG_ID',l_org_id);
	l_user_id := fnd_profile.value('USER_ID');
	l_resp_id := fnd_profile.value('RESP_ID');
	l_resp_appl_id :=  fnd_profile.value('RESP_APPL_ID');

	  WF_ENGINE.setItemAttrText('CEBASIG',id,'ORG_ID',to_char(l_org_id));
	  WF_ENGINE.setItemAttrText('CEBASIG',id,'USER_ID',to_char(l_user_id));
	  WF_ENGINE.setItemAttrText('CEBASIG',id,'RESPONSIBILITY_ID',to_char(l_resp_id));
	  WF_ENGINE.setItemAttrText('CEBASIG',id,'APPLICATION_ID',to_char(l_resp_appl_id));

	l_signatory_id := id;

 -- populate ce_security_profiles_tmp table with ce_security_profiles_v
 CEP_STANDARD.init_security;

		SELECT basv.person_name, basv.single_limit_amount,
				basv.joint_limit_amount,basv.other_limits,
				basv.signer_group, basv.requester_id,
				ba.bank_account_name, ba.bank_account_num,
				ba.currency_code, bb.bank_branch_name,
				basv.person_type, basv.person_job,
				basv.person_location, basv.person_org_name,
				basv.start_date, basv.end_date
		INTO    g_signatory_name, g_single_limit_amount,
				g_joint_limit_amount, g_other_limits,
				g_signer_group,g_requester_id,
				g_bank_Account_name, g_bank_account_number,
				g_currency_code, g_bank_branch_name,
				g_person_type, g_person_job,
				g_person_location, g_person_org_name,
				g_start_Date, g_end_date
		FROM ce_ba_signatories_v basv,
			 ce_bank_accts_gt_v ba, --ce_bank_accounts_v ba,
			 ce_bank_branches_v bb
		WHERE basv.signatory_id = l_signatory_id
		AND	  ba.bank_account_id = basv.bank_Account_id
		AND   bb.branch_party_id = ba.bank_branch_id;

	 	 WF_DIRECTORY.getusername('PER',g_requester_id,
						g_name, g_display_name);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'REQUESTER_NAME',
          			                   g_name);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'REQUESTER_DISPLAY_NAME',
          			                   g_display_name);

		 WF_ENGINE.SetItemAttrNumber(itemtype,
									itemkey,
									'SIGNATORY_ID',
									l_signatory_id);

	 	 WF_DIRECTORY.getusername('PER',l_signatory_id,
						g_name, g_display_name);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'SIGNATORY_NAME',
          			                   g_signatory_name);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'SINGLE_LIMIT_AMOUNT',
          			                   g_single_limit_amount);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'JOINT_LIMIT_AMOUNT',
          			                   g_joint_limit_amount);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'BANK_ACCOUNT_NAME',
          			                   g_bank_Account_name);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'BANK_ACCOUNT_CURRENCY_CODE',
          			                   g_currency_code);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'PERSON_TYPE',
          			                   g_person_type);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'PERSON_JOB',
          			                   g_person_job);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'PERSON_LOCATION',
          			                   g_person_location);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'HR_ORGANIZATION',
          			                   g_person_org_name);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'PERSON_GROUP',
          			                   g_signer_group);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'OTHER_LIMITATIONS',
          			                   g_other_limits);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'START_DATE',
          			                   g_start_date);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'END_DATE',
          			                   g_end_date);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'BANK_ACCOUNT_NUMBER',
          			                   g_bank_account_number);

		 WF_ENGINE.SetItemAttrText(itemtype,
   		                           itemkey,
      			                       'BANK_BRANCH_NAME',
          			                   g_bank_branch_name);


	result:='COMPLETE';
	RETURN;
	ELSE
		return;
	END IF;
EXCEPTION
  when others then
    wf_core.context('CEBASIG', 'INIT_ALL',
		    itemtype, itemkey, to_char(actid), command);
    raise;

END init_all;


/*  This procedure can be used to start the wf process from pl/sql */
PROCEDURE startit(id number)
IS
 l_user_id NUMBER;
 l_resp_id NUMBER;
 l_resp_appl_id NUMBER;
 l_org_id NUMBER;
 itemtype VARCHAR2(100);
 itemkey NUMBER;
BEGIN

	initialize(260,id,'CEBASIG');
	WF_ENGINE.CREATEPROCESS('CEBASIG',
                           id,
                          'CEBASIG');

	fnd_global.apps_initialize(fnd_profile.value('USER_ID'),
							fnd_profile.value('RESP_ID'),
							fnd_profile.value('RESP_APPL_ID'));
		FND_PROFILE.get('ORG_ID',l_org_id);
	fnd_client_info.set_org_context(l_org_id);

	FND_PROFILE.get('ORG_ID',l_org_id);
	l_user_id := fnd_profile.value('USER_ID');
	l_resp_id := fnd_profile.value('RESP_ID');
	l_resp_appl_id :=  fnd_profile.value('RESP_APPL_ID');

	WF_ENGINE.setItemAttrText('CEBASIG',id,'ORG_ID',to_char(l_org_id));
	WF_ENGINE.setItemAttrText('CEBASIG',id,'USER_ID',to_char(l_user_id));
	WF_ENGINE.setItemAttrText('CEBASIG',id,'RESPONSIBILITY_ID',to_char(l_resp_id));
	WF_ENGINE.setItemAttrText('CEBASIG',id,'APPLICATION_ID',to_char(l_resp_appl_id));

 	WF_ENGINE.STARTPROCESS('CEBASIG',
                          id);
	COMMIT;
END startit;

end CE_BASIG_WF;

/
