--------------------------------------------------------
--  DDL for Package Body OKC_WF_K_APPROVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_WF_K_APPROVE" as
/* $Header: OKCWCAPB.pls 120.2.12000000.3 2007/05/25 18:01:19 skkoppul ship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


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
-- 	Next Approver Cursor - here comes from user profile option value
--

/*

Due to performance reasons we decided to refuse from

(select 1 						num,
	FND_PROFILE.VALUE('OKC_K_APPROVER')	role,
	DISPLAY_NAME 				name
from wf_roles
where name=FND_PROFILE.VALUE('OKC_K_APPROVER'))

and restrict select to fnd_user data only

might be customisation problem

*/

cursor Next_Approver_csr is
select role, name
from  -- here should be your view of structure (num,role,name)
------------------------------------------------------
(
select 1 num,
  FND_PROFILE.VALUE('OKC_K_APPROVER') role,
  FND_PROFILE.VALUE('OKC_K_APPROVER') name
from dual
where not exists
( select '!'
  from FND_USER USR, PER_PEOPLE_F PER
  where USR.USER_NAME=FND_PROFILE.VALUE('OKC_K_APPROVER')
  and USR.EMPLOYEE_ID = PER.PERSON_ID
)
union all
select 1        num,
 FND_PROFILE.VALUE('OKC_K_APPROVER')   role,
 NVL(PER.FULL_NAME,FND_PROFILE.VALUE('OKC_K_APPROVER')) name
from FND_USER USR, PER_PEOPLE_F PER
where USR.USER_NAME=FND_PROFILE.VALUE('OKC_K_APPROVER')
and USR.EMPLOYEE_ID = PER.PERSON_ID
)
------------------------------------------------------
where p_current is NULL
order by num;

/*

-- For responsibility as an approver role
-- Profile option should be validated by statement:
-- SQL="SELECT RESPONSIBILITY_NAME \"Contract Approver\",
--    'FND_RESP'||r.APPLICATION_ID||':'||RESPONSIBILITY_ID \"WF Role Name\"
--    INTO :visible_option_value, :profile_option_value
--  from fnd_responsibility_vl r, fnd_application a
--  where r.APPLICATION_ID = a.APPLICATION_ID
--    and a.APPLICATION_SHORT_NAME like 'OK_'
--  order by RESPONSIBILITY_NAME"

-- For role comming from fnd_user use validation:
-- SQL="SELECT USER_NAME \"Contract Approver\",
-- USER_NAME \"WF Role Name\"
-- INTO :visible_option_value, :profile_option_value
-- from fnd_user
-- order by USER_NAME"
-- COLUMN="\"Contract Approver\"(30)"
-- COLUMN="\"WF Role Name\"(30)"

*/

l_initiator varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'INITIATOR_NAME');
l_approver varchar2(100) :=
	NVL(wf_engine.GetItemAttrText(itemtype,itemkey,'NEXT_PERFORMER_USERNAME'),
	 wf_engine.GetItemAttrText(itemtype,itemkey,'FINAL_APPROVER_UNAME'));

--
-- 	Next Informed Cursor = Initiator + Approver
--

cursor Next_Informed_csr is
select role, name from -- here should be your view
------------------------------------------------------
(select 1 num, l_approver role, '' name from dual
   where l_approver is not NULL
 union all
 select 2 num, l_initiator role, '' name from dual
 where not exists
   (select 1 from wf_user_roles
    where user_name=l_initiator
    and USER_ORIG_SYSTEM IN ('PER','FND_USR')
    and ROLE_NAME=l_approver
   )
)
------------------------------------------------------
where (p_current is NULL
	or num > (select num from -- same view
------------------------------------------------------
(select 1 num, l_approver role, '' name from dual
   where l_approver is not NULL
 union all
 select 2 num, l_initiator role, '' name from dual
 where not exists
   (select 1 from wf_user_roles
    where user_name=l_initiator
    and USER_ORIG_SYSTEM IN ('PER','FND_USR')
    and ROLE_NAME=l_approver
   )
)
------------------------------------------------------
		    where role = p_current)
) order by num;

/*
-- commented here cursor is more universal but has bad performance,
-- it is replaced by previous cursor, that is not universal
-- you should customize previous cursor, not this one

cursor Next_Informed_csr is
select role, name from -- here should be your view
------------------------------------------------------
(select rownum num, user_name role, '' name
 from
  (select distinct user_name from wf_user_roles
   where role_name in (l_initiator,l_approver)))
------------------------------------------------------
where (p_current is NULL
	or num > (select num from -- same view
------------------------------------------------------
(select rownum num, user_name role, '' name
 from
  (select distinct user_name from wf_user_roles
   where role_name in (l_initiator,l_approver)))
------------------------------------------------------
		    where role = p_current)
) order by num;
*/

begin
--
-- Administrator is backup guy - here = initiator
--
	if (p_role_type = 'ADMINISTRATOR') then
  	  x_role :=	wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
	      		itemkey	=> itemkey,
				aname  	=> 'INITIATOR_NAME');
	  x_name := wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
	      		itemkey	=> itemkey,
				aname  	=> 'INITIATOR_DISPLAY_NAME');
--
-- Signotory here = initiator
--
	elsif (p_role_type = 'SIGNATORY') then
  	  x_role :=	wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
	      		itemkey	=> itemkey,
				aname  	=> 'INITIATOR_NAME');
	  x_name := wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
	      		itemkey	=> itemkey,
				aname  	=> 'INITIATOR_DISPLAY_NAME');
--
-- Approver - in cursor
--
	elsif (p_role_type = 'APPROVER') then
	  open Next_Approver_csr;
	  fetch Next_Approver_csr into x_role, x_name;
	  close Next_Approver_csr;
--
-- Informed - in cursor
--
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
-- Procedure Name  : valid_approver
-- Description     : check for approver account to be active (from WF point of view)
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure valid_approver(itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is

cursor c1(p_account varchar2) is
select 'T'
from FND_USER
where
	FND_USER.USER_NAME=p_account
	and FND_USER.EMPLOYEE_ID is NULL
	and trunc(sysdate) between trunc(start_date) and nvl(end_date,sysdate)
union all
select 'T'
from FND_USER USR, PER_PEOPLE_F PER
where USR.USER_NAME=p_account
and trunc(sysdate) between trunc(USR.start_date) and nvl(USR.end_date,sysdate)
and USR.EMPLOYEE_ID = PER.PERSON_ID
and trunc(sysdate) between trunc(per.effective_start_date) and nvl(per.effective_end_date,sysdate)
;
l_dummy varchar2(1) := 'F';

begin
        mo_global.init('OKC');
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
	  open c1(wf_engine.GetItemAttrText(itemtype,itemkey,'NEXT_PERFORMER_USERNAME'));
	  fetch c1 into l_dummy;
	  close c1;
	  resultout := 'COMPLETE:'||l_dummy;
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
	  wf_core.context('OKC_WF_K_APPROVE',
		'VALID_APPROVER',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end valid_approver;

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
		resultout := 'K_APPROVAL_PROCESS';
		return;
	end if;

	--
	-- SET_CTX mode - set context for new DB session
	--
	if (command = 'SET_CTX') then
	OKC_CONTRACT_APPROVAL_PUB.wf_copy_env(
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
	  wf_core.context('OKC_WF_K_APPROVE',
		'SELECTOR',
		item_type,
		item_key,
		to_char(activity_id),
		command);
	  raise;
end Selector;

-- Start of comments
--
-- Procedure Name  : Post_Approval
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Post_Approval         : 1.0
-- End of comments

procedure Post_Approval(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
l_name varchar2(100):=wf_engine.GetItemAttrText(itemtype,itemkey,'NEXT_PERFORMER_USERNAME');
l_display_name varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'N_PERFORMER_DISPLAY_NAME');
l_context varchar2(100);
/* the cursor changed because of bug#2316572 -- INCORRECT APPROVER NAME FOR FORWARDED CONTRACT APPROVAL
cursor Actual_Performer_csr is
select  --+ORDERED
	u.name, u.display_name
from wf_user_roles r, wf_users u
where r.role_name=l_name
and r.USER_ORIG_SYSTEM=u.ORIG_SYSTEM
and r.USER_ORIG_SYSTEM_ID=u.ORIG_SYSTEM_ID
and
(
  (l_context not like 'email:%' and u.NAME=l_context)
 or
  (l_context like 'email:%' and u.EMAIL_ADDRESS=substr(l_context,7))
);
*/ -- bug#2316572
-- the above cursor is changed because of bug#2316572 (discussed with msengupt)
-- looks like we don't need select from wf_user_roles (reassignment to user not to role)
cursor Actual_Performer_csr is
select  --+ORDERED
	u.name, u.display_name
from
   wf_users u
where
(
  (l_context not like 'email:%' and u.NAME=l_context)
 or
  (l_context like 'email:%' and u.EMAIL_ADDRESS=substr(l_context,7))
);
--
begin
	--
	-- RESPOND mode
	-- and TRANSFER mode added after the bug#2316572
--	if (funcmode = 'RESPOND') then   -- also bug#2316572 - we need handle TRANSFER as well
	if (funcmode in('RESPOND','TRANSFER')) then
	  l_context := wf_engine.context_text;
	  open Actual_Performer_csr;
	  fetch Actual_Performer_csr into l_name, l_display_name;
	  close Actual_Performer_csr;
     	  wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 	=> 'ACTUAL_PERFORMER',
						avalue	=> l_name);
     	  wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 	=> 'ACTUAL_PERFORMER_D',
						avalue	=> l_display_name);
    	  return;
	end if;
	--
	-- if other mode mode
	--
		--
--!!! run in CANCEL mode    		resultout := 'COMPLETE:';
    		return;
		--
exception
	when others then
	  wf_core.context('OKC_WF_K_APPROVE',
		'POST_APPROVAL',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end Post_Approval;

-- Start of comments
--
-- Procedure Name  : Post_Sign
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Post_Approval   : 1.0
-- End of comments

procedure Post_Sign(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
l_name varchar2(100);
l_display_name varchar2(100);
l_context varchar2(100);

cursor Actual_Performer_csr is
select  --+ORDERED
	u.name, u.display_name
from
   wf_users u
where
(
  (l_context not like 'email:%' and u.NAME=l_context)
 or
  (l_context like 'email:%' and u.EMAIL_ADDRESS=substr(l_context,7))
);
begin
	if (funcmode in('RESPOND','TRANSFER')) then
	  l_context := wf_engine.context_text;
	  open Actual_Performer_csr;
	  fetch Actual_Performer_csr into l_name, l_display_name;
	  close Actual_Performer_csr;
     	  wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 	=> 'SIGNATORY_USERNAME',
						avalue	=> l_name);
     	  wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 	=> 'SIGNATORY_DISPLAY_NAME',
						avalue	=> l_display_name);
    	  return;
	end if;
	return;
exception
	when others then
	  wf_core.context('OKC_WF_K_APPROVE',
		'POST_SIGN',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end Post_Sign;

-- Start of comments
--
-- Procedure Name  : IS_related
-- Description     : determins K relation to IStore
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure IS_related(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
L1 varchar2(1):='F';
/* commented by GunA
cursor c1 is
  select 'T'
  from OKC_K_REL_OBJS_V R, ASO_Quote_Headers_ALL Q
  where R.chr_id = wf_engine.GetItemAttrNumber(itemtype,itemkey,'CONTRACT_ID')
--  and R.RTY_CODE = 'CONTRACTNEGOTIATESQUOTE'
  and R.RTY_CODE like 'CONTRACT%IS%TERM%FOR%QUOTE'
  and R.CLE_ID IS NULL
    and Q.QUOTE_HEADER_ID = R.OBJECT1_ID1
    and Q.QUOTE_SOURCE_CODE like 'IStore%' ;
*/
/* Cursor to check contracts in IStore and Quotation */
-- Bug#2208391 - added check of profile option 'OKC_CREATE_ORDER_FROM_K'
CURSOR c1 is
select 'T'
  from okc_k_rel_objs
 where chr_id = wf_engine.GetItemAttrNumber(itemtype,itemkey,'CONTRACT_ID')
   and JTOT_OBJECT1_CODE = G_OBJECT_CODE
   ---and RTY_CODE          = G_TERMSFORQUOTE ;
   -- and RTY_CODE          in (G_TERMSFORQUOTE, G_NEGOTIATESQUOTE);
   and (RTY_CODE=G_TERMSFORQUOTE OR RTY_CODE=G_NEGOTIATESQUOTE
                AND Nvl(Fnd_Profile.Value('OKC_CREATE_ORDER_FROM_K'),'Y')='N');
                                --taking BOTH into account as per Bug 2050306 abkumar
BEGIN
        mo_global.init('OKC');
        --
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
        open c1;
        fetch c1 into L1;
        close c1;
	  resultout := 'COMPLETE:'||L1;
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
	  wf_core.context('OKC_WF_K_APPROVE',
		'IS_RELATED',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end IS_related;



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
	  wf_core.context('OKC_WF_K_APPROVE',
		'NOTE_FILLED',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end note_filled;

--
-- Procedure Name  : IS_K_TEMPLATE
-- Description     : determines if K is a template
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0

procedure IS_K_TEMPLATE(	itemtype	in varchar2,
				itemkey 	 in varchar2,
				actid		 in number,
				funcmode	 in varchar2,
				resultout out nocopy varchar2	) is
--
L1 varchar2(1):='F';
--
-- Cursor to check if contract is a template
   CURSOR c1 is
   select 'T'
   from   okc_k_headers_v
   where  id = wf_engine.GetItemAttrNumber(itemtype,itemkey,'CONTRACT_ID')
   and    template_yn = 'Y';
--
BEGIN
   --
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
        open c1;
        fetch c1 into L1;
        close c1;
	  resultout := 'COMPLETE:'||L1;
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
	  wf_core.context('OKC_WF_K_APPROVE',
		'IS_K_TEMPLATE',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end IS_K_TEMPLATE;

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
L_CONTRACT_ADMIN_USERNAME 	varchar2(240);  --Bug:3018825 increased legth to 240
V_DUMMY varchar2(240);
L_SIGNATORY_USERNAME 		varchar2(240);  --Bug:3018825 increased legth to 240
L_SIGNATORY_DISPLAY_NAME  	varchar2(240);
l_id number;
L_INITIATOR_NAME  	varchar2(240);
L_INITIATOR_DISPLAY_NAME  	varchar2(240);
L_K_SHORT_DESCRIPTION 		varchar2(4000);

cursor C_INITIATOR_DISPLAY_NAME(P_USER_ID in number) is
/*
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
-- replaced to boost perf
*/
  select user_name name,user_name display_name
  from fnd_user
  where user_id=P_USER_ID
  and employee_id is null
union all
  select
       USR.USER_NAME name, PER.FULL_NAME display_name
  from
       PER_PEOPLE_F PER,
       FND_USER USR
  where  trunc(SYSDATE)
      between PER.EFFECTIVE_START_DATE and PER.EFFECTIVE_END_DATE
    and    PER.PERSON_ID       = USR.EMPLOYEE_ID
    and USR.USER_ID = P_USER_ID
;

cursor C_K_SHORT_DESCRIPTION(P_CONTRACT_ID in number) is
  select SHORT_DESCRIPTION
  from okc_k_headers_tl
  where id = P_CONTRACT_ID
	and language=userenv('LANG');
begin
        mo_global.init('OKC');
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
-- Signatory U/D/name
--
	  select_next(itemtype => itemtype,
			itemkey => itemkey,
			p_role_type 	=> 'SIGNATORY',
			x_role		=> L_SIGNATORY_USERNAME,
			x_name		=> L_SIGNATORY_DISPLAY_NAME);
	  wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'SIGNATORY_USERNAME',
			avalue	=> L_SIGNATORY_USERNAME);

	  wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'SIGNATORY_DISPLAY_NAME',
			avalue	=> L_SIGNATORY_DISPLAY_NAME);
--
  	  l_id := wf_engine.GetItemAttrNumber(
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
			aname  	=> 'CONTRACT_ID');
	  open C_K_SHORT_DESCRIPTION(l_id);
	  fetch C_K_SHORT_DESCRIPTION into L_K_SHORT_DESCRIPTION;
	  close C_K_SHORT_DESCRIPTION;
	  wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'K_SHORT_DESCRIPTION',
			avalue	=> L_K_SHORT_DESCRIPTION);
--
 update_invalid_approver(itemtype => itemtype,
                         itemkey  => itemkey,
                         actid => actid,
                         funcmode => funcmode,
                         resultout => resultout);

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
	  wf_core.context('OKC_WF_K_APPROVE',
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
L_NEXT_PERFORMER_USERNAME varchar2(240);
L_NEXT_PERFORMER_USERNAME_OUT varchar2(240);
L_N_PERFORMER_DISPLAY_NAME varchar2(240);
begin
        mo_global.init('OKC');
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
--  then Contract is considered as approved by initiator
	    if (L_NEXT_PERFORMER_USERNAME is NULL) then
   	      wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'N_PERFORMER_DISPLAY_NAME',
			avalue	=> L_INITIATOR_DISPLAY_NAME);
   	      wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'FINAL_APPROVER_UNAME',
			avalue	=> NULL);
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
			p_current	=> L_NEXT_PERFORMER_USERNAME,
			--x_role	=> L_NEXT_PERFORMER_USERNAME,
			x_role		=> L_NEXT_PERFORMER_USERNAME_OUT,
			x_name		=> L_N_PERFORMER_DISPLAY_NAME);

	    if (L_NEXT_PERFORMER_USERNAME_OUT is NULL) then
                wf_engine.SetItemAttrText (
	  	    itemtype 	=> itemtype,
	      	    itemkey	=> itemkey,
  	      	    aname 	=> 'FINAL_APPROVER_UNAME',
		    avalue	=> wf_engine.GetItemAttrText(
			             itemtype 	=> itemtype,
	      		             itemkey	=> itemkey,
			             aname  	=> 'NEXT_PERFORMER_USERNAME'));

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
		    avalue	=> L_NEXT_PERFORMER_USERNAME_OUT);

                wf_engine.SetItemAttrText(
                    itemtype 	=> itemtype,
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
	  wf_core.context('OKC_WF_K_APPROVE',
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
L_NEXT_INFORMED_USERNAME varchar2(100);
L_NEXT_INFORMED_USERNAME_OUT varchar2(100);
v_dummy varchar2(240);
begin

	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then

	  L_NEXT_INFORMED_USERNAME := wf_engine.GetItemAttrText(
	                itemtype 	=> itemtype,
	                itemkey	        => itemkey,
			aname  	        => 'NEXT_INFORMED_USERNAME');

	  select_next(itemtype     => itemtype,
                      itemkey      => itemkey,
                      p_role_type  => 'INFORMED',
                      p_current    => L_NEXT_INFORMED_USERNAME,
                      x_role	   => L_NEXT_INFORMED_USERNAME_OUT,
		      x_name	   => V_DUMMY);

	  wf_engine.SetItemAttrText (
		itemtype 	=> itemtype,
	      	itemkey	        => itemkey,
  	      	aname 	        => 'NEXT_INFORMED_USERNAME',
		avalue	        => L_NEXT_INFORMED_USERNAME_OUT);

	  if (L_NEXT_INFORMED_USERNAME_OUT is NULL) then
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
	  wf_core.context('OKC_WF_K_APPROVE',
		'SELECT_INFORMED',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end Select_Informed;

procedure Select_Informed_A(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2) is
begin
  Select_Informed(	itemtype,
				itemkey ,
				actid	,
				funcmode,
				resultout);
end;

procedure Select_Informed_AR(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2) is

 l_contract_id   NUMBER;
 l_scs_code      VARCHAR2(30);
 l_wf_item_key   VARCHAR2(240);
 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_msg_count     NUMBER;
 l_msg_data      VARCHAR2(2000);

 CURSOR csr_k_details (p_chr_id NUMBER) IS
  	select okch.scs_code, oksh.wf_item_key
  	from okc_k_headers_all_b okch, oks_k_headers_b oksh
  	where okch.ID = p_chr_id
     and   okch.id = oksh.chr_id;
begin

  Select_Informed(	itemtype,
				itemkey ,
				actid	,
				funcmode,
				resultout);
  IF resultout = 'COMPLETE:F' THEN

     l_contract_id := wf_engine.GetItemAttrNumber(
                                       itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'CONTRACT_ID');

     OPEN csr_k_details(l_contract_id);
     FETCH csr_k_details INTO l_scs_code, l_wf_item_key;
     CLOSE csr_k_details;

     -- create new instance of OKS Contract Process wf only if it does not exist
     -- and the contract is either Service, warranty contract or subscrption agreement
     IF l_scs_code in ('SERVICE', 'WARRANTY','SUBSCRIPTION') AND l_wf_item_key IS NULL THEN

       empty_mess(itemtype, itemkey );

       OKC_CONTRACT_APPROVAL_PVT.continue_k_process
                         (
                          p_api_version    => 1.0,
                          p_init_msg_list  => 'T',
                          x_return_status  => l_return_status,
                          x_msg_count      => l_msg_count,
                          x_msg_data       => l_msg_data,
                          p_contract_id    => l_contract_id,
                          p_wf_item_key    => NULL,
                          p_called_from    => 'REJECTED'
                         );
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          load_mess(itemtype, itemkey );
       END IF;
     END IF;
  END IF;
exception
	when others then
	  wf_core.context('OKC_WF_K_APPROVE',
		'SELECT_INFORMED_AR',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;

end;

procedure Select_Informed_S(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2) is

 l_contract_id   NUMBER;
 l_scs_code      VARCHAR2(30);
 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_msg_count     NUMBER;
 l_msg_data      VARCHAR2(2000);

 CURSOR csr_class_code(p_chr_id NUMBER) IS
  	select scs_code
  	from okc_k_headers_all_b
  	where ID = p_chr_id;

begin

  Select_Informed(	itemtype,
				itemkey ,
				actid	,
				funcmode,
				resultout);

  IF resultout = 'COMPLETE:F' THEN

     l_contract_id := wf_engine.GetItemAttrNumber(
                                       itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'CONTRACT_ID');


     OPEN csr_class_code(l_contract_id);
     FETCH csr_class_code INTO l_scs_code;
     CLOSE csr_class_code;

     -- Since Approval workflow is about to be completed as it has been
     -- approved and signed, we should change the negotiation status to Complete
     IF l_scs_code in ('SERVICE', 'WARRANTY','SUBSCRIPTION')  THEN
       empty_mess(itemtype, itemkey );

       OKC_CONTRACT_APPROVAL_PVT.continue_k_process
                         (
                          p_api_version    => 1.0,
                          p_init_msg_list  => 'T',
                          x_return_status  => l_return_status,
                          x_msg_count      => l_msg_count,
                          x_msg_data       => l_msg_data,
                          p_contract_id    => l_contract_id,
                          p_wf_item_key    => NULL,
                          p_called_from    => 'APPROVE'
                         );
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          load_mess(itemtype, itemkey );
       END IF;
     END IF;
  END IF;
exception
	when others then
	  wf_core.context('OKC_WF_K_APPROVE',
		'SELECT_INFORMED_S',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end;

procedure Select_Informed_SR(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2) is

 l_contract_id   NUMBER;
 l_scs_code      VARCHAR2(30);
 l_wf_item_key   VARCHAR2(240);
 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_msg_count     NUMBER;
 l_msg_data      VARCHAR2(2000);

 CURSOR csr_k_details (p_chr_id NUMBER) IS
  	select okch.scs_code, oksh.wf_item_key
  	from okc_k_headers_all_b okch, oks_k_headers_b oksh
  	where okch.ID = p_chr_id
     and   okch.id = oksh.chr_id;
begin

  Select_Informed(	itemtype,
				itemkey ,
				actid	,
				funcmode,
				resultout);
  IF resultout = 'COMPLETE:F' THEN

     l_contract_id := wf_engine.GetItemAttrNumber(
                                       itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'CONTRACT_ID');

     OPEN csr_k_details(l_contract_id);
     FETCH csr_k_details INTO l_scs_code, l_wf_item_key;
     CLOSE csr_k_details;

     -- create new instance of OKS Contract Process wf only if it does not exist
     -- and the contract is either Service, warranty contract or subscrption agreement
     IF l_scs_code in ('SERVICE', 'WARRANTY','SUBSCRIPTION') AND l_wf_item_key IS NULL THEN

       empty_mess(itemtype, itemkey );

       OKC_CONTRACT_APPROVAL_PVT.continue_k_process
                         (
                          p_api_version    => 1.0,
                          p_init_msg_list  => 'T',
                          x_return_status  => l_return_status,
                          x_msg_count      => l_msg_count,
                          x_msg_data       => l_msg_data,
                          p_contract_id    => l_contract_id,
                          p_wf_item_key    => NULL,
                          p_called_from    => 'REJECTED'
                         );
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          load_mess(itemtype, itemkey );
       END IF;
     END IF;
  END IF;
exception
	when others then
	  wf_core.context('OKC_WF_K_APPROVE',
		'SELECT_INFORMED_SR',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
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
L_CONTRACT_ID number;
x_return_status varchar2(1);
begin

        mo_global.init('OKC');
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
--
	  empty_mess(	itemtype,
				itemkey );
  	  L_CONTRACT_ID := wf_engine.GetItemAttrNumber(
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
			aname  	=> 'CONTRACT_ID');
	  OKC_CONTRACT_APPROVAL_PUB.k_approved(
				p_contract_id => L_CONTRACT_ID,
                  	x_return_status	=> x_return_status);
	  if (x_return_status = OKC_API.G_RET_STS_SUCCESS)
	  then
	    --
  	    wf_engine.SetItemAttrDate (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'DATE_SIGNED',
			avalue	=> sysdate);
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
	  wf_core.context('OKC_WF_K_APPROVE',
		'RECORD_APPROVED',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end Record_Approved;

-- Start of comments
--
-- Procedure Name  : Erase_Approved
-- Description     : Does not need customization
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Erase_Approved(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
L_CONTRACT_ID number;
x_return_status varchar2(1);
begin
        mo_global.init('OKC');
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
--
	  empty_mess(	itemtype,
				itemkey );
  	  L_CONTRACT_ID := wf_engine.GetItemAttrNumber(
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
			aname  	=> 'CONTRACT_ID');
	  OKC_CONTRACT_APPROVAL_PUB.k_erase_approved(
				p_contract_id => L_CONTRACT_ID,
                  	x_return_status	=> x_return_status);
	  if (x_return_status = OKC_API.G_RET_STS_SUCCESS)
	  then
	    --
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
	  wf_core.context('OKC_WF_K_APPROVE',
		'ERASE_APPROVED',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end Erase_Approved;

-- Start of comments
--
-- Procedure Name  : Record_Signed
-- Description     : Could be customized to widen sign procedure
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Record_Signed(itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
L_DATE_SIGNED Date;
L_CONTRACT_ID number;
x_return_status varchar2(1);
begin
        mo_global.init('OKC');
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
--
	  empty_mess(	itemtype,
				itemkey );
    	  L_DATE_SIGNED := wf_engine.GetItemAttrDate (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'DATE_SIGNED');
  	  L_CONTRACT_ID := wf_engine.GetItemAttrNumber(
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
			aname  	=> 'CONTRACT_ID');
	  OKC_CONTRACT_APPROVAL_PUB.k_signed(
		p_contract_id 	=> L_CONTRACT_ID,
		p_date_signed 	=> NVL(L_DATE_SIGNED,sysdate),
            x_return_status	=> x_return_status
		    );
	  if (x_return_status = OKC_API.G_RET_STS_SUCCESS)
	  then
	    --
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
	  wf_core.context('OKC_WF_K_APPROVE',
		'RECORD_SIGNED',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end Record_Signed;

-- Start of comments
--
-- Procedure Name  : was_approver
-- Description     : note mandatory if reject
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure was_approver(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
begin
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
        if (wf_engine.GetItemAttrText(itemtype,itemkey,'FINAL_APPROVER_UNAME') is NULL) then
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
	  wf_core.context('OKC_WF_K_APPROVE',
		'WAS_APPROVER',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end was_approver;

  -- Start of comments
  --
  -- Procedure Name  : NOTIFY_SALES_REP_W
  -- Description     : Procedure to call private API
  --                   OKC_OC_INT_QTK_PVT.NOTIFY_SALES_REP
  -- Business Rules  : Private API
  -- IN Parameters   : itemtype,itemkey ,actid,funcmode
  -- OUT Parameters  : resultout
  -- Version         : 1.0
  --
  -- End of comments
Procedure NOTIFY_SALES_REP_W	  (itemtype	in  varchar2,
				   itemkey  	in varchar2,
                                      actid	in  number,
                    		   funcmode	in  varchar2,
                                    resultout out nocopy varchar2 )
  IS
       --Local Variables
    l_return_status     VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
    l_contract_id       number  :=NULL;
    l_msg_count         number  :=NULL;
    l_msg_data          varchar2(1000)  :=NULL;

     --Global Variables
    G_API_VERSION                     NUMBER        :=1.0 ;

BEGIN
    mo_global.init('OKC');
    --
	-- RUN mode - normal process execution
	--
	If (funcmode = 'RUN') then
    --

  	  l_contract_id := wf_engine.GetItemAttrNumber(
				itemtype => itemtype,
      				itemkey	 => itemkey,
				aname  	 => 'CONTRACT_ID');
   	  empty_mess( itemtype,
	               itemkey );
       /*
        calling notification api to notify quoation and IStore
       */
       OKC_OC_INT_QTK_PVT.NOTIFY_SALES_REP
                               (p_api_version     => g_api_version
                               ,p_contract_id     => l_contract_id
                               ,x_msg_count       => l_msg_count
                               ,x_msg_data        => l_msg_data
                               ,x_return_status   => l_return_status ) ;

  	  If (l_return_status = OKC_API.G_RET_STS_SUCCESS) then
	    --
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
    End If;
EXCEPTION
	when others then
	  wf_core.context(pkg_name => 'OKC_WF_K_APPROVE',
                         proc_name => 'NOTIFY_SALES_REP_W',
                	      arg1 => itemtype,
                	      arg2 => itemkey,
            		      arg3 => to_char(actid),
            		      arg4 => funcmode);

	  Raise;
end NOTIFY_SALES_REP_W;

-- Procedure Name  : Make_Active
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Make_Active(itemtype	in varchar2,
				itemkey   in varchar2,
				actid		 in number,
				funcmode	 in varchar2,
				resultout out nocopy varchar2	) is
--
L_CONTRACT_ID number;
x_return_status varchar2(1);
--
begin
        mo_global.init('OKC');
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
--
	  empty_mess(	itemtype,
				itemkey );
  	  L_CONTRACT_ID := wf_engine.GetItemAttrNumber(
			itemtype	=> itemtype,
	      itemkey	=> itemkey,
			aname  	=> 'CONTRACT_ID');
	  OKC_CONTRACT_APPROVAL_PUB.activate_template(
				p_contract_id   => L_CONTRACT_ID,
            x_return_status => x_return_status);
	  if (x_return_status = OKC_API.G_RET_STS_SUCCESS)
	  then
	    --
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
	  wf_core.context('OKC_WF_K_APPROVE',
		'MAKE_ACTIVE',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end Make_Active;

-- Procedure Name  : updt_quote_from_k
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure updt_quote_from_k(itemtype  in varchar2,
                            itemkey   in varchar2,
                            actid     in number,
                            funcmode  in varchar2,
                            resultout out nocopy varchar2  ) is
--
l_contract_id   number;
x_return_status varchar2(30);
x_msg_count     number;
x_msg_data      varchar2(4000);
l_api_version   NUMBER        :=1.0 ;
l_session_id    number;
CURSOR csr_session_id IS
SELECT userenv('sessionid')
FROM dual;
--
begin
        mo_global.init('OKC');
        --
        -- RUN mode - normal process execution
        --
        if (funcmode = 'RUN') then
--
          empty_mess( itemtype,
                      itemkey );
--
        OPEN csr_session_id;
          FETCH csr_session_id INTO l_session_id;
        CLOSE csr_session_id;

        wf_engine.SetItemAttrNumber (
                 itemtype  => itemtype,
                 itemkey=> itemkey,
                 aname => 'QUOTE_SESSION_ID',
                 avalue=> l_session_id);
--
          l_contract_id := wf_engine.GetItemAttrNumber(
                               itemtype  => itemtype,
                               itemkey   => itemkey,
                               aname     => 'CONTRACT_ID');

                  OKC_OC_INT_PUB.update_quote_from_k(
                   p_api_version    => l_api_version
                  ,p_commit         => OKC_API.G_TRUE
                  ,p_quote_id       => NULL
                  ,p_contract_id    => l_contract_id
                  ,p_trace_mode     => NULL
                  ,x_return_status  => x_return_status
                  ,x_msg_count      => x_msg_count
                  ,x_msg_data       => x_msg_data
                  );

          if (x_return_status = OKC_API.G_RET_STS_SUCCESS)
          then
            --
            resultout := 'COMPLETE:T';
            return;
            --
          else
            --
            load_mess(  itemtype,
                                itemkey );
            resultout := 'COMPLETE:F';
            return;
            --
          end if;

        end if; -- run mode
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
          wf_core.context('OKC_WF_K_APPROVE',
                'updt_quote_from_k',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          raise;
end updt_quote_from_k;


-- Start of comments
-- Procedure Name  : invalid_approver
-- Description     : Procedure to update okc_k_process in case of invalid approver in profile option.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments


PROCEDURE invalid_approver(itemtype	IN VARCHAR2,
				itemkey  	IN VARCHAR2,
				actid		IN NUMBER,
				funcmode	IN VARCHAR2,
				resultout OUT NOCOPY VARCHAR2	)
IS
   CURSOR csr_process_id(p_contract_id IN NUMBER)
   IS
   SELECT id
   FROM okc_k_processes
   WHERE chr_id = p_contract_id
/*Bug 3255018 AND pdf_id = (SELECT id */
   AND pdf_id in (SELECT id
                 FROM OKC_PROCESS_DEFS_V
                 WHERE usage = 'APPROVE'
                 AND PDF_TYPE = 'WPS'
 		 AND WF_NAME = 'OKCAUKAP');

  l_contract_id   NUMBER;
  l_return_status VARCHAR2(30);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(4000);
  l_api_version   NUMBER        :=1.0 ;
  l_cpsv_rec  Okc_Contract_Pub.cpsv_rec_type;
  x_cpsv_rec  Okc_Contract_Pub.cpsv_rec_type;
  l_init_msg_list VARCHAR2(1) := Okc_Api.G_FALSE;
  l_process_id NUMBER;
BEGIN
  mo_global.init('OKC');
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
    empty_mess( itemtype, itemkey );

    l_contract_id := wf_engine.GetItemAttrNumber(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'CONTRACT_ID');

    OPEN csr_process_id(l_contract_id);
      FETCH csr_process_id INTO l_process_id;
    CLOSE csr_process_id;

    l_cpsv_rec.id :=  l_process_id;
	l_cpsv_rec.in_process_yn := 'E';

    Okc_Contract_Pub.update_contract_process(
      p_api_version  => l_api_version,
      p_init_msg_list => l_init_msg_list,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      p_cpsv_rec => l_cpsv_rec,
      x_cpsv_rec => x_cpsv_rec);

    IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
      resultout := 'COMPLETE:T';
      RETURN;
    ELSE
      load_mess(  itemtype, itemkey );
      resultout := 'COMPLETE:F';
      RETURN;
    END IF;

  END IF; -- run mode

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
                --
    resultout := 'COMPLETE:';
    RETURN;
                --
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
                --
    resultout := 'COMPLETE:';
    RETURN;
                --
  END IF;
EXCEPTION
        WHEN OTHERS THEN
          wf_core.context('OKC_WF_K_APPROVE',
                'invalid_approver',
                itemtype,
                itemkey,
                TO_CHAR(actid),
                funcmode);
          RAISE;
END invalid_approver;


-- Start of comments
--
-- Procedure Name  : update_invalid_approver
-- Description     : update_invalid_approver error code in IN_PROCESS_YN field of OKC_K_PROCESSES
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE update_invalid_approver(itemtype	IN VARCHAR2,
				itemkey  	IN VARCHAR2,
				actid		IN NUMBER,
				funcmode	IN VARCHAR2,
				resultout OUT NOCOPY VARCHAR2	)
IS
   CURSOR csr_process_id(p_contract_id IN NUMBER)
   IS
   SELECT id, in_process_yn
   FROM okc_k_processes
   WHERE chr_id = p_contract_id
/*Bug 3255018 AND pdf_id = (SELECT id */
   AND pdf_id in (SELECT id
                 FROM OKC_PROCESS_DEFS_V
                 WHERE usage = 'APPROVE'
                 AND PDF_TYPE = 'WPS'
 		 AND WF_NAME = 'OKCAUKAP');

  l_contract_id   NUMBER;
  l_return_status VARCHAR2(30);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(4000);
  l_api_version   NUMBER        :=1.0 ;
  l_cpsv_rec  Okc_Contract_Pub.cpsv_rec_type;
  x_cpsv_rec  Okc_Contract_Pub.cpsv_rec_type;
  l_init_msg_list VARCHAR2(1) := Okc_Api.G_FALSE;
  l_process_id NUMBER;
  l_in_process_yn VARCHAR2(1);
BEGIN
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
    empty_mess( itemtype, itemkey );

    l_contract_id := wf_engine.GetItemAttrNumber(
                       itemtype  => itemtype,
                       itemkey   => itemkey,
                       aname     => 'CONTRACT_ID');

    OPEN csr_process_id(l_contract_id);
      FETCH csr_process_id INTO l_process_id, l_in_process_yn;
    CLOSE csr_process_id;

    IF l_in_process_yn = 'E' THEN
      l_cpsv_rec.id :=  l_process_id;
	  l_cpsv_rec.in_process_yn := NULL;

      Okc_Contract_Pub.update_contract_process(
        p_api_version  => l_api_version,
        p_init_msg_list => l_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        p_cpsv_rec => l_cpsv_rec,
        x_cpsv_rec => x_cpsv_rec);

      IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
        resultout := 'COMPLETE:T';
        RETURN;
      ELSE
        load_mess(  itemtype, itemkey );
        resultout := 'COMPLETE:F';
        RETURN;
      END IF;
    END IF;
  END IF; -- run mode

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
                --
    resultout := 'COMPLETE:';
    RETURN;
                --
  END IF;
  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
                --
    resultout := 'COMPLETE:';
    RETURN;
                --
  END IF;
EXCEPTION
        WHEN OTHERS THEN
          wf_core.context('Okc_Wf_K_Approve',
                'update_invalid_approver',
                itemtype,
                itemkey,
                TO_CHAR(actid),
                funcmode);
          RAISE;
END update_invalid_approver;

end OKC_WF_K_APPROVE;

/
