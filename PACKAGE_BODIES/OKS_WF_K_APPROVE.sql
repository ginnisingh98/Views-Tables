--------------------------------------------------------
--  DDL for Package Body OKS_WF_K_APPROVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_WF_K_APPROVE" AS
/* $Header: OKSWCAPB.pls 120.11.12000000.2 2007/05/16 23:52:21 skkoppul ship $ */

    G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKS_WF_K_APPROVE';
    G_APP_NAME                   CONSTANT   VARCHAR2(3)   := 'OKS';
    G_MODULE                     CONSTANT   VARCHAR2(250) := 'oks.plsql.'||g_pkg_name||'.';

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
    l_approver_record2  ame_util.approverRecord2;
    l_forwardee      ame_util.approverRecord2;
    l_process_complete_yn   varchar2(1);
    l_next_approvers      ame_util.approversTable2;
    l_all_approvers      ame_util.approversTable2;
    G_APPLICATION_ID         CONSTANT   NUMBER := 515;
    G_TRANSACTION_TYPE           CONSTANT   VARCHAR2(200) := 'OKS_INTERNAL_APPROVAL';

    l_item_indexes        ame_util.idList;
    l_item_classes        ame_util.stringList;
    l_item_ids            ame_util.stringList;
    l_item_sources        ame_util.longStringList;
    l_name     varchar2(150);

  ------------------------------------------------------------------------------
  -- EXCEPTIONS
  ------------------------------------------------------------------------------
  NoValidApproverException  EXCEPTION;


-- Start of comment
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

PROCEDURE set_performer
(
 itemtype               IN         VARCHAR2,
 itemkey                IN         VARCHAR2
) IS

 l_api_name        CONSTANT VARCHAR2(30) := 'set_performer';
 l_chr_id                   NUMBER;
 x_return_status            VARCHAR2(1);
 x_msg_count                NUMBER;
 x_msg_data                 VARCHAR2(2000);
 l_salesrep_id              NUMBER;
 l_salesrep_name            VARCHAR2(100);
 l_dummy                    VARCHAR2(100);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered '||G_PKG_NAME ||'.'||l_api_name);
 END IF;
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'itemtype: ' || itemtype ||
                ' itemkey: ' || itemkey);
 END IF;
 l_chr_id := wf_engine.GetItemAttrNumber(
                          itemtype    => itemtype,
                          itemkey     => itemkey,
                          aname       => 'CONTRACT_ID');

 -- Get Salesrep user name to whom the error notification
 -- about valid approver not found should be sent to
 IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                  'OKS_RENEW_CONTRACT_PVT.GET_USER_NAME(p_chr_id= '||l_chr_id||')');
 END IF;
 OKS_RENEW_CONTRACT_PVT.GET_USER_NAME
 (
  p_api_version   => 1.0,
  p_init_msg_list => FND_API.G_FALSE,
  x_return_status => x_return_status,
  x_msg_count     => x_msg_count,
  x_msg_data      => x_msg_data,
  p_chr_id        => l_chr_id,
  p_hdesk_user_id => NULL,
  x_user_id       => l_salesrep_id,
  x_user_name     => l_salesrep_name
 );
 IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  'OKS_RENEW_CONTRACT_PVT.GET_USER_NAME(x_return_status= '||
                  x_return_status||' x_msg_count ='||x_msg_count||')');
   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  ' x_user_id ='||l_salesrep_id||
                  ' x_user_name ='||l_salesrep_name);
 END IF;
 -- Check if SALESREP_HD_NAME item attribute exists, if not create one
 BEGIN
     l_dummy := wf_engine.GetItemAttrText
                (
                  itemtype  => itemtype,
                  itemkey   => itemkey,
                  aname     => 'SALESREP_HD_NAME'
                );
 EXCEPTION
     WHEN OTHERS THEN
        wf_engine.AddItemAttr
               (
                itemtype  => itemtype,
                itemkey   => itemkey,
                aname     => 'SALESREP_HD_NAME'
               );
 END;
 -- In case of errors in deriving salesrep or help desk, send the
 -- notification to the person who initiated the process
 IF x_return_status <> FND_API.G_RET_STS_SUCCESS OR l_salesrep_name IS NULL THEN
    wf_engine.SetItemAttrText (
                       itemtype => itemtype,
                       itemkey  => itemkey,
                       aname    => 'SALESREP_HD_NAME',
                       avalue   => wf_engine.GetItemAttrText(
                                              itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'INITIATOR_NAME')
                     );
 ELSE
    wf_engine.SetItemAttrText (
                       itemtype => itemtype,
                       itemkey  => itemkey,
                       aname    => 'SALESREP_HD_NAME',
                       avalue   => l_salesrep_name);
 END IF;
EXCEPTION
 WHEN OTHERS THEN
    wf_engine.SetItemAttrText (
                       itemtype => itemtype,
                       itemkey  => itemkey,
                       aname    => 'SALESREP_HD_NAME',
                       avalue   => wf_engine.GetItemAttrText(
                                              itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'INITIATOR_NAME')
                     );
END;

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

l_api_name     CONSTANT VARCHAR2(30) := 'select_next';
l_initiator varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'INITIATOR_NAME');
l_approver varchar2(100) :=
	NVL(wf_engine.GetItemAttrText(itemtype,itemkey,'NEXT_PERFORMER_USERNAME'),
	 wf_engine.GetItemAttrText(itemtype,itemkey,'FINAL_APPROVER_UNAME'));
l_id number;
l_item_classes        ame_util.stringList;
l_item_ids            ame_util.stringList;
l_completed           ame_util.charList;
l_user_names          varchar2(2000);
l_role_name           varchar2(1000);
l_role_display_name   varchar2(1000);
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

begin

   IF (l_debug = 'Y') THEN
        okc_debug.log('OKSWCAPB: Select_Next() --  Start of Select_Next()', 2);
   END IF;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                   'Entered '||G_PKG_NAME ||'.'||l_api_name||
                   ' Item Key '||itemkey||
                   ' Role Type '||p_role_type||' Current '||p_current);
   END IF;

   -- Initialize message stack
   FND_MSG_PUB.initialize;
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
           l_id := wf_engine.GetItemAttrNumber(
			itemtype        => itemtype,
                        itemkey         => itemkey,
			aname           => 'CONTRACT_ID');

           BEGIN
              ame_api2.getNextApprovers1(                    --    Get the next approver
                    applicationIdIn => G_APPLICATION_ID,
                    transactionTypeIn => G_TRANSACTION_TYPE,
                    transactionIdIn => l_id,
                    flagApproversAsNotifiedIn => ame_util.booleanTrue,
                    approvalProcessCompleteYNOut => l_process_complete_yn,
                    nextApproversOut => l_next_approvers,
                    itemIndexesOut => l_item_indexes,
                    itemClassesOut => l_item_classes,
                    itemIdsOut => l_item_ids,
                    itemSourcesOut => l_item_sources);
           EXCEPTION
              WHEN OTHERS THEN
                  IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                    fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
                                  'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
                                  ||SQLCODE||', sqlerrm = '||SQLERRM);
                  END IF;
                  FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                  RAISE NoValidApproverException;
           END;
           IF l_next_approvers.count =0 THEN
               x_role := null;
               x_name := null;
           ELSIF l_next_approvers.count =1 THEN
               x_role :=l_next_approvers(1).name;
               x_name :='';
           ELSE
               FOR i IN l_next_approvers.first..l_next_approvers.last LOOP
                IF l_next_approvers.exists(i) THEN
                  IF (i=1) THEN
                    l_user_names := l_next_approvers(1).name;
                  ELSE
                    l_user_names := l_user_names || ',' || l_next_approvers(i).name;
                  END IF;
                END IF;
               END LOOP;

               --Create an adhoc role using l_user_names
               WF_DIRECTORY.createAdHocRole(
                            role_name=>l_role_name,
                            role_display_name=>l_role_display_name,
                            language=>null,
                            territory=>null,
                            role_description=>'Service Contract Internal Approval Adhoc Role',
                            notification_preference=>'MAILHTML',
                            role_users=>l_user_names,
                            email_address=>null,
                            fax=>null,
                            status=>'ACTIVE',
                            expiration_date=>SYSDATE+1);
               x_role  :=l_role_name;
               x_name  :=l_role_display_name;
           END IF;
--
-- Informed - in cursor
--
	elsif (p_role_type = 'INFORMED') then
	  open Next_Informed_csr;
	  fetch Next_Informed_csr into x_role, x_name;
	  close Next_Informed_csr;
	end if;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name||
                    ' x_role:'||x_role||' x_name:'||x_name);
        END IF;
        IF (l_debug = 'Y') THEN
          okc_debug.log('OKSWCAPB: Select_Next() --  End of Select_Next()', 2);
        END IF;
EXCEPTION
  WHEN NoValidApproverException THEN
      IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
             'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.NoValidApproverException '||
             ' A valid approver is not found for this contract');
      END IF;
      RAISE NoValidApproverException;
  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 'Leaving '||G_PKG_NAME ||'.'||l_api_name||' from OTHERS sqlcode = '
                 ||SQLCODE||', sqlerrm = '||SQLERRM);
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      RAISE;
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
	-- Add for adhoc approvers
	resultout :='COMPLETE:T';
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
l_id   varchar2(100);
l_original varchar2(100):=wf_engine.GetItemAttrText(itemtype,itemkey,'NEXT_PERFORMER_USERNAME');

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
/* cursor Actual_Performer_csr is
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
*/
-- Broken the above cursor into two due to bug 4865186 to avoid FTS
CURSOR csr_actual_performer_1(p_context IN VARCHAR2) IS
select u.name, u.display_name
from   wf_users u
where UPPER(u.EMAIL_ADDRESS)=UPPER(substr(p_context,7));

CURSOR csr_actual_performer_2(p_context IN VARCHAR2) IS
select  u.name, u.display_name
from    wf_users u
where u.NAME=p_context;

begin
	--
	-- RESPOND mode
	-- and TRANSFER mode added after the bug#2316572
--	if (funcmode = 'RESPOND') then   -- also bug#2316572 - we need handle TRANSFER as well
	if (funcmode in('RESPOND','TRANSFER')) then
	  l_context := wf_engine.context_text;

          IF l_context like 'email:%' THEN
            OPEN csr_actual_performer_1(l_context);
            FETCH csr_actual_performer_1 INTO l_name, l_display_name;
            CLOSE csr_actual_performer_1;
          ELSE
            OPEN csr_actual_performer_2(l_context);
            FETCH csr_actual_performer_2 INTO l_name, l_display_name;
            CLOSE csr_actual_performer_2;
          END IF;

     	  wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      				itemkey => itemkey,
  	      				aname 	=> 'ACTUAL_PERFORMER',
					avalue	=> l_name);
     	  wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      				itemkey => itemkey,
  	      				aname 	=> 'ACTUAL_PERFORMER_D',
					avalue	=> l_display_name);
          wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      				itemkey => itemkey,
  	      				aname 	=> 'FROM',
					avalue	=> l_name);




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
/*
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
*/
-- Broken the above cursor into two due to bug 4865186 to avoid FTS
CURSOR csr_actual_performer_1(p_context IN VARCHAR2) IS
select u.name, u.display_name
from   wf_users u
where UPPER(u.EMAIL_ADDRESS)=UPPER(substr(p_context,7));

CURSOR csr_actual_performer_2(p_context IN VARCHAR2) IS
select  u.name, u.display_name
from    wf_users u
where u.NAME=p_context;

begin
	if (funcmode in('RESPOND','TRANSFER')) then
	  l_context := wf_engine.context_text;

          IF l_context like 'email:%' THEN
            OPEN csr_actual_performer_1(l_context);
            FETCH csr_actual_performer_1 INTO l_name, l_display_name;
            CLOSE csr_actual_performer_1;
          ELSE
            OPEN csr_actual_performer_2(l_context);
            FETCH csr_actual_performer_2 INTO l_name, l_display_name;
            CLOSE csr_actual_performer_2;
          END IF;

     	  wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      			     itemkey  	=> itemkey,
  	      			     aname 	=> 'SIGNATORY_USERNAME',
			             avalue	=> l_name);
     	  wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      			     itemkey  	=> itemkey,
  	      			     aname 	=> 'SIGNATORY_DISPLAY_NAME',
				     avalue	=> l_display_name);
          wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      			     itemkey  	=> itemkey,
  	      			     aname 	=> 'FROM',
				     avalue	=> l_name);
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
        IF (l_debug = 'Y') THEN
            okc_debug.log('OKSWCAPB: Initialize Start of initialize()', 2);
        END IF;
        mo_global.init('OKS');
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

          IF (l_debug = 'Y') THEN
            okc_debug.log('OKSWCAPB: Initialize() USER_ID='||l_id, 2);
          END IF;

	  wf_engine.SetItemAttrText (
					itemtype 	=> itemtype,
	      				itemkey		=> itemkey,
			  	      	aname 		=> 'INITIATOR_NAME',
					avalue		=> L_INITIATOR_NAME);
	  wf_engine.SetItemAttrText (
					itemtype 	=> itemtype,
				      	itemkey		=> itemkey,
  	      				aname 		=> 'INITIATOR_DISPLAY_NAME',
					avalue		=> L_INITIATOR_DISPLAY_NAME);
          wf_engine.SetItemAttrText (
					itemtype 	=> itemtype,
				      	itemkey		=> itemkey,
			  	      	aname 		=> 'FROM',
					avalue		=> L_INITIATOR_NAME);
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
          IF (l_debug = 'Y') THEN
            okc_debug.log('OKSWCAPB: Initialize() -- Before call ame_ap2.clearAllApprovals()', 2);
          END IF;

          ame_api2.clearAllApprovals(
                                     applicationIdIn => G_APPLICATION_ID,
                                     transactionTypeIn => G_TRANSACTION_TYPE,
                                     transactionIdIn => l_id);
          IF (l_debug = 'Y') THEN
            okc_debug.log('OKSWCAPB: Initialize() -- After call ame_ap2.clearAllApprovals()', 2);
          END IF;

	  open C_K_SHORT_DESCRIPTION(l_id);
	  fetch C_K_SHORT_DESCRIPTION into L_K_SHORT_DESCRIPTION;
	  close C_K_SHORT_DESCRIPTION;
	  wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'K_SHORT_DESCRIPTION',
			avalue	=> L_K_SHORT_DESCRIPTION);
--
          IF (l_debug = 'Y') THEN
            okc_debug.log('OKSWCAPB: Initialize() -- Before call update_invalid_approver()', 2);
          END IF;

          update_invalid_approver(itemtype => itemtype,
                         itemkey  => itemkey,
                         actid => actid,
                         funcmode => funcmode,
                         resultout => resultout);
          IF (l_debug = 'Y') THEN
            okc_debug.log('OKSWCAPB: Initialize() -- After call update_invalid_approver()', 2);
          END IF;

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

l_api_name           CONSTANT VARCHAR2(50) := 'Select_Approver';

L_INITIATOR_DISPLAY_NAME      VARCHAR2(240);
L_NEXT_PERFORMER_USERNAME     VARCHAR2(240);
L_NEXT_PERFORMER_USERNAME_OUT VARCHAR2(240);
L_N_PERFORMER_DISPLAY_NAME    VARCHAR2(240);

BEGIN
        IF (l_debug = 'Y') THEN
            okc_debug.log('OKSWCAPB: Select_Approver() --  Start of Select_Approver()', 2);
        END IF;

        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                   'Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                           'itemtype: ' || itemtype ||
                           ' itemkey: ' || itemkey  ||
                           ' actid: ' || to_char(actid) ||
                           ' funcmode: ' || funcmode);
        END IF;

        mo_global.init('OKC');
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
           L_NEXT_PERFORMER_USERNAME := wf_engine.GetItemAttrText(
                                                        itemtype   => itemtype,
                                                        itemkey    => itemkey,
                                                        aname      => 'NEXT_PERFORMER_USERNAME');
           if (L_NEXT_PERFORMER_USERNAME is NULL) then -- just start
               L_INITIATOR_DISPLAY_NAME := wf_engine.GetItemAttrText(
                                                        itemtype   => itemtype,
                                                        itemkey    => itemkey,
                                                        aname      => 'INITIATOR_DISPLAY_NAME');
               -- Empty message attributes so that we can push new messages in case of errors
               empty_mess(
                       itemtype   => itemtype,
                       itemkey    => itemkey
                     );
               -- Now get the Approver
               BEGIN
                   select_next(itemtype     => itemtype,
                               itemkey      => itemkey,
                               p_role_type  => 'APPROVER',
                               p_current    => NULL,
                               x_role       => L_NEXT_PERFORMER_USERNAME,
                               x_name       => L_N_PERFORMER_DISPLAY_NAME);
               EXCEPTION
                   WHEN NoValidApproverException THEN
                      -- Load the item attributes with error messages
                      load_mess(
                            itemtype   => itemtype,
                            itemkey    => itemkey
                         );
                      -- set the performer(salesrep, Help desk or initiator) of this notification
                      set_performer(
                            itemtype   => itemtype,
                            itemkey    => itemkey
                         );
                      resultout := 'COMPLETE:';
                      return;
               END;
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

               -- Empty message attributes so that we can push new messages in case of errors
               empty_mess(
                       itemtype   => itemtype,
                       itemkey    => itemkey
                     );
               -- Now get the Approver
               BEGIN
                   select_next(itemtype     => itemtype,
                               itemkey      => itemkey,
                               p_role_type  => 'APPROVER',
                               p_current    => L_NEXT_PERFORMER_USERNAME,
                               x_role       => L_NEXT_PERFORMER_USERNAME_OUT,
                               x_name       => L_N_PERFORMER_DISPLAY_NAME);
               EXCEPTION
                   WHEN NoValidApproverException THEN
                      -- Load the item attributes with error messages
                      load_mess(
                            itemtype   => itemtype,
                            itemkey    => itemkey
                         );
                      -- set the performer(salesrep, Help desk or initiator) of this notification
                      set_performer(
                            itemtype   => itemtype,
                            itemkey    => itemkey
                         );
                      resultout := 'COMPLETE:';
                      return;
               END;
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
        IF (l_debug = 'Y') THEN
            okc_debug.log('OKSWCAPB: Select_Approver() --  End of Select_Approver()', 2);
        END IF;
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
-- Procedure Name  : Notify_AME
-- Description     : To Update AME the status of approver
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Update_AME(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2) is

begin


  ame_api2.updateApprovalStatus2(
         applicationIdIn   => G_APPLICATION_ID,
         transactionTypeIn => G_TRANSACTION_TYPE,
         transactionIdIn   => wf_engine.GetItemAttrText(itemtype,itemkey,'CONTRACT_ID'),
         approvalStatusIn  => ame_util.approvedStatus,
         approverNameIn    => wf_engine.GetItemAttrText(itemtype,itemkey,'ACTUAL_PERFORMER'),
         forwardeeIn       => ame_util.emptyApproverRecord2
         );

end;

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
begin
  Select_Informed(	itemtype,
				itemkey ,
				actid	,
				funcmode,
				resultout);
end;

procedure Select_Informed_S(	itemtype	in varchar2,
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

procedure Select_Informed_SR(	itemtype	in varchar2,
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
	   -- load_mess(	itemtype,
		--		itemkey );
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

procedure Record_Rejected(
                          itemtype  in         varchar2,
                          itemkey   in         varchar2,
                          actid     in         number,
                          funcmode  in         varchar2,
                          resultout out nocopy VARCHAR2
              ) is

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
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then

	  empty_mess(itemtype,
                     itemkey );

          l_contract_id := wf_engine.GetItemAttrNumber(
                                       itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'CONTRACT_ID');

          OPEN csr_class_code(l_contract_id);
          FETCH csr_class_code INTO l_scs_code;
          CLOSE csr_class_code;

          IF l_scs_code in ('SERVICE', 'WARRANTY','SUBSCRIPTION')  THEN
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
          END IF;
	  if (l_return_status = OKC_API.G_RET_STS_SUCCESS)
	  then
	    --
	    resultout := 'COMPLETE:T';
  	    return;
	    --
	  else
	    --
	    load_mess(itemtype,
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
	  wf_core.context('OKS_WF_K_APPROVE',
		'Record_Rejected',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end Record_Rejected;

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

end OKS_WF_K_APPROVE;



/
