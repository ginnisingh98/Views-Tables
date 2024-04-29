--------------------------------------------------------
--  DDL for Package Body OKC_WF_CHK_APPROVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_WF_CHK_APPROVE" as
/* $Header: OKCWCHKB.pls 120.0 2005/05/26 09:57:10 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

----------------------------------------------------------------------------
--
--       C U S T O M I Z E  select_next
--
----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : select_next
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure select_next(itemtype	in varchar2 default NULL,
				itemkey  	in varchar2 default NULL,
				p_role_type 	in varchar2,
				p_current  		in varchar2 default NULL,
				x_role	 out nocopy varchar2,
				x_name	 out nocopy varchar2
) is
--
-- 	Next Approver Cursor
--
-- Bug 1563675: Modified next_approver_csr for performance problem similar
-- to the way that the contract approval cursor was modified
--
cursor Next_Approver_csr is
select role, name
from  -- here should be your view of structure (num,role,name)
------------------------------------------------------
(select 1 num, FND_PROFILE.VALUE('OKC_CR_APPROVER') role,
	   NVL(PER.FULL_NAME, USR.USER_NAME) name
   from FND_USER USR, PER_PEOPLE_F PER
  where USR.USER_NAME = FND_PROFILE.VALUE('OKC_CR_APPROVER')
    and USR.EMPLOYEE_ID = PER.PERSON_ID(+)
    and trunc(sysdate) between nvl(per.effective_start_date, trunc(sysdate)) and
						 nvl(per.effective_end_date, trunc(sysdate))
)
------------------------------------------------------
where p_current is NULL
order by num;
--
-- 	Next Informed Cursor
--
cursor Next_Informed_csr is
select role, name
from  -- here should be your view of structure (num,role,name)
------------------------------------------------------
(select 1 num, FND_PROFILE.VALUE('OKC_CR_APPROVER') role,
	   NVL(PER.FULL_NAME, USR.USER_NAME) name
   from FND_USER USR, PER_PEOPLE_F PER
  where USR.USER_NAME = FND_PROFILE.VALUE('OKC_CR_APPROVER')
    and USR.EMPLOYEE_ID = PER.PERSON_ID(+)
    and trunc(sysdate) between nvl(per.effective_start_date, trunc(sysdate)) and
						 nvl(per.effective_end_date, trunc(sysdate))
)
------------------------------------------------------
where p_current is NULL
order by num;
begin
	if (p_role_type = 'ADMINISTRATOR') then
  	  x_role :=	wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
	      		itemkey	=> itemkey,
				aname  	=> 'INITIATOR_NAME');
	  x_name := wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
	      		itemkey	=> itemkey,
				aname  	=> 'INITIATOR_DISPLAY_NAME');
	elsif (p_role_type = 'SIGNATORY') then
  	  x_role :=	wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
	      		itemkey	=> itemkey,
				aname  	=> 'INITIATOR_NAME');
	  x_name := wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
	      		itemkey	=> itemkey,
				aname  	=> 'INITIATOR_DISPLAY_NAME');
	elsif (p_role_type = 'APPROVER') then
	  open Next_Approver_csr;
	  fetch Next_Approver_csr into x_role, x_name;
	  close Next_Approver_csr;
	elsif (p_role_type = 'INFORMED') then
	  open Next_Informed_csr;
	  fetch Next_Informed_csr into x_role, x_name;
	  close Next_Informed_csr;
	end if;
end select_next;
----------------------------------------------------------------------------
--
--       You can stop customization here
--
----------------------------------------------------------------------------

-- Start of comments
--
-- Procedure Name  : Selector
-- Description     : Selector/Callback function - no need to customize
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Selector  ( 	item_type	in varchar2,
			item_key  	in varchar2,
			activity_id	in number,
			command		in varchar2,
			resultout out nocopy varchar2	) is
-- local declarations
begin
	resultout := ''; -- return value for other possible modes
	--
	-- RUN mode - normal process execution
	--
	if (command = 'RUN') then
		--
		-- Return process to run
		--
		resultout := 'CHK_APPROVAL_PROCESS';
		return;
	end if;

	--
	-- SET_CTX mode - set context for new DB session
	--
	if (command = 'SET_CTX') then
	OKC_CHANGE_CONTRACT_PUB.wf_copy_env(
		p_item_type => item_type,
		p_item_key  => item_key);
		return;
	end if;

	--
	-- TEST_CTX mode - test context
	--
	if (command = 'TEST_CTX') then
		-- test code
		resultout := 'TRUE';
		return;
	end if;

exception
	when others then
	  wf_core.context('OKC_WF_CHK_APPROVE',
		'SELECTOR',
		item_type,
		item_key,
		to_char(activity_id),
		command);
	  raise;
end Selector;

-- Start of comments
--
-- Procedure Name  : Initialize
-- Description     : Initialization of attributes that were not initialized by k_start API
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Initialize (	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
L_CONTRACT_ADMIN_USERNAME 	varchar2(30);
V_DUMMY varchar2(240);
l_id number;
L_INITIATOR_NAME  	varchar2(240);
L_INITIATOR_DISPLAY_NAME  	varchar2(240);
cursor C_INITIATOR_DISPLAY_NAME(P_USER_ID in number) is
  select name,display_name
  from wf_roles
  where orig_system = 'FND_USR'
  and orig_system_id=P_USER_ID
union all
select
       USR.USER_NAME name,
       PER.FULL_NAME display_name
from
       PER_PEOPLE_F PER,
       FND_USER USR
where  trunc(SYSDATE) between PER.EFFECTIVE_START_DATE
                          and PER.EFFECTIVE_END_DATE
and    PER.PERSON_ID       = USR.EMPLOYEE_ID
and USR.USER_ID = P_USER_ID
and not exists (select '1'
  from wf_roles
  where orig_system = 'FND_USR'
  and orig_system_id=P_USER_ID)
;

begin
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
--
-- Initiator/Initial
--
  	  l_id := wf_engine.GetItemAttrNumber(
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
			aname  	=> 'USER_ID');
	  open C_INITIATOR_DISPLAY_NAME(l_id);
	  fetch C_INITIATOR_DISPLAY_NAME into L_INITIATOR_NAME,L_INITIATOR_DISPLAY_NAME;
	  close C_INITIATOR_DISPLAY_NAME;
	  wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'INITIATOR_NAME',
			avalue	=> L_INITIATOR_NAME);
	  wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'INITIATOR_DISPLAY_NAME',
			avalue	=> L_INITIATOR_DISPLAY_NAME);
--
-- Administrator U/name
--
	  select_next(itemtype => itemtype,
			itemkey => itemkey,
			p_role_type 	=> 'ADMINISTRATOR',
			x_role		=> L_CONTRACT_ADMIN_USERNAME,
			x_name		=> V_DUMMY);
	  wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'CONTRACT_ADMIN_USERNAME',
			avalue	=> L_CONTRACT_ADMIN_USERNAME);
--
	  resultout := 'COMPLETE:';
  	  return;
	--
	end if;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';
    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';
    		return;
		--
	end if;
exception
	when others then
	  wf_core.context('OKC_WF_CHK_APPROVE',
		'INITIALIZE',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end Initialize;

-- Start of comments
--
-- Procedure Name  : Select_Approver
-- Description     : Customize using your approval chain
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Select_Approver(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
L_INITIATOR_DISPLAY_NAME varchar2(240);
L_NEXT_PERFORMER_USERNAME varchar2(30);
L_N_PERFORMER_DISPLAY_NAME varchar2(240);
begin
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
	  L_NEXT_PERFORMER_USERNAME := wf_engine.GetItemAttrText(
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
			aname  	=> 'NEXT_PERFORMER_USERNAME');
	  if (L_NEXT_PERFORMER_USERNAME is NULL)
	  then -- just start
	    L_INITIATOR_DISPLAY_NAME := wf_engine.GetItemAttrText(
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
			aname  	=> 'INITIATOR_DISPLAY_NAME');
	    select_next(itemtype => itemtype,
			itemkey => itemkey,
			p_role_type 	=> 'APPROVER',
			p_current  		=> NULL,
			x_role		=> L_NEXT_PERFORMER_USERNAME,
			x_name		=> L_N_PERFORMER_DISPLAY_NAME);
--  just for common situation if no approvers at all
--  then Change Contract is considered as approved by initiator
	    if (L_NEXT_PERFORMER_USERNAME is NULL) then
   	      wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'N_PERFORMER_DISPLAY_NAME',
			avalue	=> L_INITIATOR_DISPLAY_NAME);
	      resultout := 'COMPLETE:F';
	    else
    	      wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'P_PERFORMER_DISPLAY_NAME',
			avalue	=> L_INITIATOR_DISPLAY_NAME);
  	      wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'NEXT_PERFORMER_USERNAME',
			avalue	=> L_NEXT_PERFORMER_USERNAME);
  	      wf_engine.SetItemAttrText(itemtype 	=> itemtype,
	      				itemkey	=> itemkey,
  	      				aname 	=> 'N_PERFORMER_DISPLAY_NAME',
						avalue	=> L_N_PERFORMER_DISPLAY_NAME);
	      resultout := 'COMPLETE:T';
          end if;
  	    return;
	  else
   	    wf_engine.SetItemAttrText
		(
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'P_PERFORMER_DISPLAY_NAME',
			avalue	=> wf_engine.GetItemAttrText(
						itemtype 	=> itemtype,
	      				itemkey	=> itemkey,
						aname  	=> 'N_PERFORMER_DISPLAY_NAME')
		);
	    select_next(itemtype => itemtype,
			itemkey => itemkey,
			p_role_type 	=> 'APPROVER',
			p_current  		=> L_NEXT_PERFORMER_USERNAME,
			x_role		=> L_NEXT_PERFORMER_USERNAME,
			x_name		=> L_N_PERFORMER_DISPLAY_NAME);
	    if (L_NEXT_PERFORMER_USERNAME is NULL) then
  	      wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'NEXT_PERFORMER_USERNAME',
			avalue	=> NULL);
 	      resultout := 'COMPLETE:F';
	    else
  	      wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'NEXT_PERFORMER_USERNAME',
			avalue	=> L_NEXT_PERFORMER_USERNAME);
  	      wf_engine.SetItemAttrText(itemtype 	=> itemtype,
	      				itemkey	=> itemkey,
  	      				aname 	=> 'N_PERFORMER_DISPLAY_NAME',
						avalue	=> L_N_PERFORMER_DISPLAY_NAME);
 	      resultout := 'COMPLETE:T';
          end if;
  	    return;
	    --
	  end if;
	end if;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';
    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';
    		return;
		--
	end if;
exception
	when others then
	  wf_core.context('OKC_WF_CHK_APPROVE',
		'SELECT_APPROVER',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end Select_Approver;

-- Start of comments
--
-- Procedure Name  : Select_Informed
-- Description     : Customize using your To be Informed chain
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Select_Informed(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2) is
L_NEXT_INFORMED_USERNAME varchar2(30);
v_dummy varchar2(240);
begin
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
	  L_NEXT_INFORMED_USERNAME := wf_engine.GetItemAttrText(
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
			aname  	=> 'NEXT_INFORMED_USERNAME');
	  select_next(itemtype => itemtype,
			itemkey => itemkey,
			p_role_type 	=> 'INFORMED',
			p_current  		=> L_NEXT_INFORMED_USERNAME,
			x_role		=> L_NEXT_INFORMED_USERNAME,
			x_name		=> V_DUMMY);
	  wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'NEXT_INFORMED_USERNAME',
			avalue	=> L_NEXT_INFORMED_USERNAME);
	  if (L_NEXT_INFORMED_USERNAME is NULL) then
	    resultout := 'COMPLETE:F';
	  else
	      resultout := 'COMPLETE:T';
        end if;
	  return;
	end if;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';
    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';
    		return;
		--
	end if;
exception
	when others then
	  wf_core.context('OKC_WF_CHK_APPROVE',
		'SELECT_INFORMED',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end Select_Informed;

-- Start of comments
--
-- Procedure Name  : empty_mess
-- Description     : Private procedure to empty message attributes
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure empty_mess(	itemtype	in varchar2,
				itemkey  	in varchar2) is
i integer;
begin
  FOR I IN 1..9 LOOP
    wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 	=> 'MESSAGE'||i,
						avalue	=> '');
  END LOOP;
end;

-- Start of comments
--
-- Procedure Name  : load_mess
-- Description     : Private procedure to load messages into attributes
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure load_mess(	itemtype	in varchar2,
				itemkey  	in varchar2) is
i integer;
j integer;
begin
  j := NVL(FND_MSG_PUB.Count_Msg,0);
  if (j=0) then return; end if;
  if (j>9) then j:=9; end if;
  FOR I IN 1..J LOOP
    wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      			itemkey  	=> itemkey,
  	      			aname 	=> 'MESSAGE'||i,
					avalue	=> FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
  END LOOP;
end;

-- Start of comments
--
-- Procedure Name  : Record_Approved
-- Description     : Does not need customization
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Record_Approved(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
L_CHANGE_REQUEST_ID number;
x_return_status varchar2(1);
begin
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
--
	  empty_mess(	itemtype,
				itemkey );
  	  L_CHANGE_REQUEST_ID := wf_engine.GetItemAttrNumber(
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
			aname  	=> 'CHANGE_REQUEST_ID');
	  OKC_CHANGE_CONTRACT_PUB.change_request_approved(
				p_change_request_id => L_CHANGE_REQUEST_ID,
                  	x_return_status => x_return_status);
	  if (x_return_status = OKC_API.G_RET_STS_SUCCESS)
	  then
	    resultout := 'COMPLETE:T';
  	    return;
	    --
	  else
	    --
	    load_mess(	itemtype,
				itemkey );
	    resultout := 'COMPLETE:F';
  	    return;
	    --
	  end if;
	end if;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';
    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';
    		return;
		--
	end if;
exception
	when others then
	  wf_core.context('OKC_WF_CHK_APPROVE',
		'RECORD_APPROVED',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end Record_Approved;

-- Start of comments
--
-- Procedure Name  : Record_Rejected
-- Description     : Does not need customization
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Record_Rejected(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
L_CHANGE_REQUEST_ID number;
x_return_status varchar2(1);
begin
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
--
	  empty_mess(	itemtype,
				itemkey );
  	  L_CHANGE_REQUEST_ID := wf_engine.GetItemAttrNumber(
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
			aname  	=> 'CHANGE_REQUEST_ID');
	  OKC_CHANGE_CONTRACT_PUB.change_request_rejected(
				p_change_request_id => L_CHANGE_REQUEST_ID,
                  	x_return_status => x_return_status);
	  if (x_return_status = OKC_API.G_RET_STS_SUCCESS)
	  then
	    resultout := 'COMPLETE:T';
  	    return;
	    --
	  else
	    --
	    load_mess(	itemtype,
				itemkey );
	    resultout := 'COMPLETE:F';
  	    return;
	    --
	  end if;
	end if;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';
    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';
    		return;
		--
	end if;
exception
	when others then
	  wf_core.context('OKC_WF_CHK_APPROVE',
		'RECORD_REJECTED',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end Record_Rejected;
--
-- Start of comments
--
-- Procedure Name  : note_filled
-- Description     : note mandatory if reject
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure note_filled(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
begin
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
        if (wf_engine.GetItemAttrText(itemtype,itemkey,'NOTE') is NULL) then
	      resultout := 'COMPLETE:F';
	  else
	      resultout := 'COMPLETE:T';
	  end if;
	end if;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';
    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';
    		return;
		--
	end if;
exception
	when others then
	  wf_core.context('OKC_WF_CHK_APPROVE',
		'NOTE_FILLED',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end note_filled;

end OKC_WF_CHK_APPROVE;

/
