--------------------------------------------------------
--  DDL for Package Body IEX_WF_BAN_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WF_BAN_STATUS_PUB" AS
/* $Header: iexwfbsb.pls 120.11.12010000.7 2009/01/16 19:02:33 ehuh ship $ */
/*
 * This procedure needs to be called with an itemtype and workflow process
 * which'll launch workflow .Start Workfolw will call workflow based on
 * Meth_flag in methodology base table
*/

G_PKG_NAME   VARCHAR2(30);
PG_DEBUG NUMBER;

PROCEDURE start_workflow
(
      p_api_version        IN NUMBER DEFAULT 1.0,
      p_init_msg_list      IN VARCHAR2 ,
      p_commit             IN VARCHAR2 ,
	    p_user_id            IN NUMBER,
	    p_delinquency_id     IN NUMBER,
      p_party_id 	       IN NUMBER,
      p_bankruptcy_id	   IN  NUMBER,  --Added for bug 7661724 gnramasa 8th Jan 09
      x_return_status      OUT NOCOPY VARCHAR2,
      x_msg_count          OUT NOCOPY NUMBER,
      x_msg_data           OUT NOCOPY VARCHAR2
)
IS
      l_result       			 VARCHAR2(10);
      itemtype       			 VARCHAR2(30);
      itemkey       			 VARCHAR2(30);
      workflowprocess  		 VARCHAR2(30);
      l_init_msg_list varchar2(1);
      l_user_id            NUMBER;
      l_user_name          VARCHAR2(60);
      l_manager_id         NUMBER;
      l_manager_name       VARCHAR2(60);
      l_party_name         VARCHAR2(60);
      l_bankruptcy_id      number;  --Added for bug 3659342 by gnramasa

      l_error_msg     		 VARCHAR2(2000);
      l_return_status  		 VARCHAR2(20);
      l_msg_count     		 NUMBER;
      l_msg_data     			 VARCHAR2(2000);
      l_api_name     			 VARCHAR2(100);
      l_api_version_number  NUMBER;

      CURSOR c_manager(p_user_id NUMBER) IS
      SELECT b.user_id, b.user_name
      FROM JTF_RS_RESOURCE_EXTNS a
      ,    JTF_RS_RESOURCE_EXTNS b
      WHERE b.source_id = a.source_mgr_id
      AND a.user_id = p_user_id;

BEGIN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('IEX Start Bankruptcy Workflow..');
    end if;

    -- Standard Start of API savepoint
    SAVEPOINT START_WORKFLOW;

      l_api_name     		 := 'START_WORKFLOW';
      l_api_version_number  := 1.0;
      l_init_msg_list :=FND_API.G_FALSE;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list )
    THEN
          FND_MSG_PUB.initialize;
    END IF;


    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Start bug 3659342 by gnramasa
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('IEX Start Bankruptcy Workflow..p_bankruptcy_id=' ||p_bankruptcy_id);
    end if;

    /*
    SELECT TO_CHAR(IEX_DEL_WF_S.NEXTVAL) INTO itemkey FROM dual;
		itemkey := 'BANST'||TO_CHAR(p_delinquency_id)||itemkey;
    */
    itemkey := to_char(p_bankruptcy_id);
    --End bug 3659342 by gnramasa

    itemtype := 'IEXBANST';
    workflowprocess := 'BANKRUPT_STATUS';

     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('IEX Start Bankruptcy Workflow..P_user_id=' ||p_user_id);
     end if;

    begin
		-- Get manager
		SELECT user_name INTO l_user_name from JTF_RS_RESOURCE_EXTNS
		WHERE user_id = p_user_id;
      exception
        when others then
          iex_debug_pub.logmessage('IEX Start Bankruptcy Workflow usernme exception');
    end;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('IEX Start Bankruptcy Workflow..P_Party_id=' ||p_party_id);
    end if;

    begin
            SELECT party_name INTO l_party_name from hz_parties
              where party_id = p_party_id;
      exception
        when others then
          iex_debug_pub.logmessage('IEX Start Bankruptcy Workflow party_name exception');
    end;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('IEX Start Bankruptcy Workflow..P_Useerid=' ||p_user_id);
        iex_debug_pub.logmessage('IEX Start Bankruptcy Workflow..username=' ||l_user_name);
    end if;

    begin
          OPEN C_MANAGER(p_user_id);
          FETCH C_MANAGER INTO l_manager_id, l_manager_name;
          IF C_MANAGER%NOTFOUND THEN
    	     l_manager_id := p_user_id;
    	     l_manager_name := l_user_name;
          END IF;
          CLOSE C_MANAGER;
      exception
        when others then
    	     l_manager_id := p_user_id;
    	     l_manager_name := l_user_name;
             iex_debug_pub.logmessage('IEX Start Bankruptcy Workflow manager exception');
    end;
/*
    select b.bankruptcy_id bankruptcy_id
    into l_bankruptcy_id
    from iex_delinquencies d, iex_bankruptcies b
    where d.delinquency_id = b.delinquency_id
    and d.delinquency_id = p_delinquency_id;
*/
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('IEX Start Bankruptcy Workflow..getting bankruptcy id=' ||l_user_name);
    end if;

    /*
    select bankruptcy_id bankruptcy_id
    into l_bankruptcy_id
    from iex_bankruptcies
    where party_id= p_party_id
    and DISPOSITION_CODE is NULL;
    */

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      --iex_debug_pub.logmessage('IEX-4 Start Invoking  BK Id..'||l_bankruptcy_id);
      iex_debug_pub.logmessage('IEX-4 Start Invoking  BK Id..'||p_bankruptcy_id);
      iex_debug_pub.logmessage('IEX-4 Start Invoking  Manager Name..'||l_manager_name);
      iex_debug_pub.logmessage('IEX-4 Start Invoking  requesterID ..'||p_user_id);
      iex_debug_pub.logmessage('IEX-4 Start Invoking  requesterName ..'||l_user_name);
      iex_debug_pub.logmessage('IEX-4 Start Invoking  DelinquencyID ..'||p_delinquency_id);
      iex_debug_pub.logmessage('IEX-4 Start Invoking  approverId ..'||l_manager_id);
      iex_debug_pub.logmessage('IEX-4 Start Invoking  approverName ..'||l_manager_name);
      iex_debug_pub.logmessage('IEX-4 Start Invoking  partyid ..'||p_party_id);
      iex_debug_pub.logmessage('IEX-4 Start Invoking  partyName ..'||l_party_name);
      iex_debug_pub.logmessage('IEX-4 Start Invoking  ItemType ..'||itemtype);
      iex_debug_pub.logmessage('IEX-4 Start Invoking  Itemkey ..'||itemkey);
    end if;

    wf_engine.createprocess  (  itemtype => itemtype,
              itemkey  => itemkey,
              process  => 'BANKRUPT_STATUS');

    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'DELINQUENCY_ID',
                avalue   =>   p_delinquency_id);

    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'MANAGER_ID',
                avalue   =>   l_manager_id);

    wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'MANAGER_NAME',
                avalue   =>   l_manager_name);

    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'APPROVER_ID',
                avalue   =>   l_manager_id);

    wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'APPROVER_NAME',
                avalue   =>   l_manager_name);

    wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'REQUESTER_NAME',
                avalue   =>   l_user_name);

    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'REQUESTER_ID',
                avalue   =>   p_user_id);

    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'PARTY_ID',
                avalue   =>   p_party_id);

    wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'PARTY_NAME',
                avalue   =>   l_party_name);

    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'BANKRUPTCY_ID',
    --            avalue   =>   l_bankruptcy_id);
                avalue   =>   p_bankruptcy_id);

--  DBMS_OUTPUT.PUT_LINE('Before START PROCESS');

    wf_engine.startprocess( itemtype =>   itemtype,
                          itemkey  =>   itemkey);
--  DBMS_OUTPUT.PUT_LINE('After START PROCESS');

    wf_engine.ItemStatus(  itemtype =>   ItemType,
                           itemkey  =>   ItemKey,
                           status   =>   l_return_status,
                           result   =>   l_result);

    iex_debug_pub.logmessage('IEX-7 Return Status ='||l_return_status);

    if (l_return_status in ('COMPLETE', 'ACTIVE')) THEN
       x_return_status := 'S';
       commit;
    else
       x_return_status := 'F';
    end if;

--  DBMS_OUTPUT.PUT_LINE('GET ITEM STATUS = ' || l_return_status);
--  DBMS_OUTPUT.PUT_LINE('GET ITEM result = ' || l_result);


    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
--Start bug 6717204 gnramasa 11th Jan 08
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO START_WORKFLOW;
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO START_WORKFLOW;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
         ROLLBACK TO START_WORKFLOW;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
	 END IF;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
--End bug 6717204 gnramasa 11th Jan 08
----------------------------------
END start_workflow;

-- procedure update_approval_status  -----------------------------
PROCEDURE update_approval_status(
						itemtype    				IN VARCHAR2,
            itemkey     				IN VARCHAR2,
            actid								IN NUMBER,
            funcmode    				IN VARCHAR2,
            result      				OUT NOCOPY VARCHAR2
) is

  l_api_version      	  number;
  l_init_msg_list    	  varchar2(1);
  l_commit              varchar2(1);
  l_manager_name 				varchar2(60);
  l_delinquency_id			number;
  l_bankruptcy_id			number;
  l_party_id            number;
  l_party_name          varchar2(30);
  l_responder           varchar2(100);
  l_text_value          varchar2(2000);
  l_forward_to_username varchar2(100);
  l_dummy               varchar2(1);
  l_errmsg_name					VARCHAR2(30);
  L_API_ERROR						EXCEPTION;

  l_error_msg     			VARCHAR2(2000);
  l_return_status  		  VARCHAR2(20);
  l_msg_count     			NUMBER;
  l_msg_data     			  VARCHAR2(2000);
  l_api_version_number  NUMBER ;
  l_api_name     	VARCHAR2(100);
  l_profile             varchar2(01);

BEGIN

  l_api_version_number   := 1.0;
  l_api_name             := 'update_approval_status';

  if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

  l_profile := NVL(fnd_profile.value('IEX_STRY_CREATE_BANKRUPTCY'), 'Y');

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.logmessage ('update_approval_status start');
	iex_debug_pub.logmessage ('Profile IEX_STRY_CREATE_BANKRUPTCY == '||l_profile);
  END IF;

  if l_profile = 'Y' then

--DBMS_OUTPUT.PUT_LINE('update_approval_status');

     l_manager_name := wf_engine.GetItemAttrText(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'MANAGER_NAME');

     l_delinquency_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'DELINQUENCY_ID');

     l_party_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'PARTY_ID');

     l_party_name := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'PARTY_NAME');
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.logmessage ('update_approval_status start, before getting the bankruptcy id');
     END IF;

  --Start bug 6359342 gnramasa 23-Aug-07
     l_bankruptcy_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'BANKRUPTCY_ID');

     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        	iex_debug_pub.logmessage ('update_approval_status start, after getting the bankruptcy id');
     END IF;

     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.logmessage ('update_approval_status: ' || 'l_delinquency_id : '||l_delinquency_id);
	    iex_debug_pub.logmessage ('update_approval_status: ' || 'l_bankruptcy_id : '||l_bankruptcy_id);
	    iex_debug_pub.logmessage ('update_approval_status: ' || 'l_party_id : '||l_party_id);
     END IF;


     Create_strategy(
        p_api_version                     => l_api_version_number,
        p_init_msg_list                   => l_init_msg_list,
        p_commit                          => l_commit,
        X_RETURN_STATUS                   => l_return_status,
        X_MSG_COUNT                       => l_msg_count,
        X_MSG_DATA                        => l_msg_data,
        p_delinquency_id                  => l_delinquency_id,
	p_bankruptcy_id                   => l_bankruptcy_id,
	p_party_id                        => l_party_id
        );

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        	iex_debug_pub.logmessage ('update_approval_status:'||l_return_status);
      END IF;
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        	RAISE L_API_ERROR;
      END IF;
  end if;

--End bug 6359342 gnramasa 23-Aug-07


--    update Bankrupt related record here
--    Set "no Contact" flag in TCA
--    Make everything for entire customer to 'Delinquent'
--    Set Delinquency Status to 'Bankruptcy'
--    Create a 'Stop Invoicing' notification to some on the A/R side
--    Start Bankruptcy Strategy
/*
  turnoff_bankrupt_collections
  (        	p_api_version      	=> l_api_version_number,
           	p_init_msg_list    	=> l_init_msg_list,
           	p_commit           	=> l_commit,
	    			p_party_id          => l_party_id,
            x_return_status    	=> l_return_status,
            x_msg_count        	=> l_msg_count,
            x_msg_data      		=> l_msg_data);
*/
  result := 'COMPLETE';

  EXCEPTION
  	WHEN L_API_ERROR then
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('IEX_WF_BAN_STATUS_PUB', 'update_approval_status',
		      itemtype, itemkey, actid, funcmode);
      RAISE;
END update_approval_status;

-- procedure update_rejection_status  -----------------------------
procedure update_rejection_status(
	    itemtype    				IN VARCHAR2,
            itemkey     				IN VARCHAR2,
            actid					IN NUMBER,
            funcmode    				IN VARCHAR2,
            result      				OUT NOCOPY VARCHAR2
) is

  l_responder           varchar2(100);
  l_text_value          varchar2(2000);
  l_manager_name 	varchar2(60);
  l_delinquency_id	number;
  l_party_id            number;
  l_party_name          varchar2(30);
  l_api_name     	VARCHAR2(100);
  l_errmsg_name		VARCHAR2(30);
  L_API_ERROR		EXCEPTION;

BEGIN

  iex_debug_pub.logmessage('IEX-Reject Bankruptcy Start  ..');
  l_api_name  := 'update_rejection_status';
  l_manager_name := wf_engine.GetItemAttrText(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'MANAGER_NAME');

  l_delinquency_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'DELINQUENCY_ID');

  l_party_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'PARTY_ID');

  l_party_name := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'PARTY_NAME');

  iex_debug_pub.logmessage('IEX-Reject Bankruptcy partyid ..'||l_party_id);
  -- fixed a bug 5261811
  begin
    update IEX_BANKRUPTCIES
      set DISPOSITION_CODE = 'WITHDRAWN'
           where party_id = l_party_id
             --and delinquency_id = l_delinquency_id
             and disposition_code is null;
    exception
      when others then
           iex_debug_pub.logmessage('IEX-Rejct Exception....');
           null;
  end;

  result := 'COMPLETE';

EXCEPTION
		WHEN l_API_ERROR then
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('IEX_WF_BAN_STATUS_PUB', 'update_rejection_status',
		      itemtype, itemkey, actid, funcmode);
      RAISE;

END update_rejection_status;

-- procedure set_no_contact_in_tca  -----------------------------
PROCEDURE set_no_contact_in_tca(
						itemtype    				IN VARCHAR2,
            itemkey     				IN VARCHAR2,
            actid								IN NUMBER,
            funcmode    				IN VARCHAR2,
            result      				OUT NOCOPY VARCHAR2) IS

  l_errmsg_name					   VARCHAR2(30);
  L_API_ERROR						   EXCEPTION;
  l_init_msg_list          VARCHAR2(1);
  l_api_name     				   VARCHAR2(100);
  l_api_version_number      NUMBER;
  l_contact_preference_id  NUMBER;
  o_contact_preference_id  NUMBER;
  l_return_status          VARCHAR2(30);
  l_msg_count     			   NUMBER;
  l_msg_data     			     VARCHAR2(2000);
  l_object_version_number  NUMBER;

  l_party_id               NUMBER;
  l_o_party_id             NUMBER;
  l_p_party_id             NUMBER;

  l_contact_preference_rec HZ_CONTACT_PREFERENCE_V2PUB.contact_preference_rec_type;

  CURSOR C_DO_PARTY(p_person_id NUMBER) IS
  SELECT contact_preference_id FROM HZ_CONTACT_PREFERENCES
  WHERE CONTACT_LEVEL_TABLE = 'HZ_PARTIES'
  AND CONTACT_LEVEL_TABLE_ID = P_PERSON_ID
  AND PREFERENCE_CODE = 'DO';

  CURSOR C_DO_NOT_PARTY(p_person_id NUMBER) IS
  SELECT contact_preference_id FROM HZ_CONTACT_PREFERENCES
  WHERE CONTACT_LEVEL_TABLE = 'HZ_PARTIES'
  AND CONTACT_LEVEL_TABLE_ID = P_PERSON_ID
  AND PREFERENCE_CODE = 'DO_NOT';

  --Begin Bug#4597394 schekuri 08-Sep-2005
  --Replaced the view HZ_PARTY_RELATIONSHIPS with HZ_RELATIONSHIPS and
  --added necessary filter conditions
  CURSOR C_PARTY(p_org_party_id NUMBER) IS
  SELECT
    P.PARTY_ID
--  , P.PARTY_NAME
  FROM
    HZ_RELATIONSHIPS   REL
  , HZ_PARTIES               C
  , HZ_PARTIES               P
  , HZ_PARTIES               O
  WHERE O.PARTY_TYPE = 'ORGANIZATION'
  AND O.PARTY_ID = REL.OBJECT_ID
  AND P.PARTY_TYPE = 'PERSON'
  AND P.PARTY_ID = REL.SUBJECT_ID
  AND C.PARTY_TYPE = 'PARTY_RELATIONSHIP'
  AND REL.PARTY_ID = C.PARTY_ID
  AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
  AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
  AND REL.DIRECTIONAL_FLAG = 'F'
  AND O.PARTY_ID = p_org_party_id;


/*  CURSOR C_PARTY(p_org_party_id NUMBER) IS
  SELECT
    P.PARTY_ID
--  , P.PARTY_NAME
  FROM
    HZ_PARTY_RELATIONSHIPS   REL
  , HZ_PARTIES               C
  , HZ_PARTIES               P
  , HZ_PARTIES               O
  WHERE O.PARTY_TYPE = 'ORGANIZATION'
  AND O.PARTY_ID = REL.OBJECT_ID
  AND P.PARTY_TYPE = 'PERSON'
  AND P.PARTY_ID = REL.SUBJECT_ID
  AND C.PARTY_TYPE = 'PARTY_RELATIONSHIP'
  AND REL.PARTY_ID = C.PARTY_ID
  AND O.PARTY_ID = p_org_party_id;*/
--End Bug#4597394 schekuri 08-Sep-2005

BEGIN

  l_init_msg_list          := FND_API.G_FALSE;
  l_api_name      := 'set_no_contact';
  l_api_version_number      := 1.0;

  if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

  l_party_id := wf_engine.GetItemAttrNumber(
                itemtype  => itemtype,
                itemkey   => itemkey,
                aname     => 'PARTY_ID');

  OPEN C_PARTY(l_party_id);
  LOOP
  FETCH c_party INTO l_p_party_id;
  EXIT WHEN NOT C_PARTY%FOUND;
    -- Dbms_output.put_line('Person Id '||l_p_party_id);

    OPEN C_DO_PARTY(l_p_party_id);
    FETCH c_do_party INTO l_contact_preference_id;
    IF C_DO_PARTY%FOUND THEN
--     Dbms_output.put_line('P Id '||l_contact_preference_id||' Update');
     	 l_contact_preference_rec.CONTACT_PREFERENCE_ID := l_contact_preference_id;
     	 l_contact_preference_rec.PREFERENCE_CODE := 'DO_NOT';
     	 l_contact_preference_rec.REQUESTED_BY := 'PARTY';
	 --Begin bug#5087608 schekuri 27-May-2006
	 --"CONTACT" lookup code is inactive in AR lookup type CONTACT_TYPE
	 l_contact_preference_rec.CONTACT_TYPE := 'ALL';
         --l_contact_preference_rec.CONTACT_TYPE := 'CONTACT';
       	 --End bug#5087608 schekuri 27-May-2006
       l_contact_preference_rec.PREFERENCE_START_DATE := sysdate;
       l_contact_preference_rec.STATUS := 'A';
       l_contact_preference_rec.CREATED_BY_MODULE := 'IEX';

       HZ_CONTACT_PREFERENCE_V2PUB.get_contact_preference_rec (
           p_init_msg_list            => l_init_msg_list,
           p_contact_preference_id    => l_contact_preference_id,
           x_contact_preference_rec   => l_contact_preference_rec,
           x_return_status            => l_return_status,
           x_msg_count                => l_msg_count,
           x_msg_data                 => l_msg_data);

       IF l_return_status = 'S'
       	  and l_contact_preference_rec.PREFERENCE_CODE = 'DO_NOT'
	  and l_contact_preference_rec.CONTACT_TYPE = 'ALL' THEN  --Changed for bug#5087608 schekuri 27-May-2006
       	  --and l_contact_preference_rec.CONTACT_TYPE = 'CONTACT' THEN
       	  null;
       ELSE
       -- update contact_preference_type
         HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference (
           p_init_msg_list            =>  l_init_msg_list,
           p_contact_preference_rec   =>  l_contact_preference_rec,
           p_object_version_number    =>  l_object_version_number,
           x_return_status            =>  l_return_status,
           x_msg_count                =>  l_msg_count,
           x_msg_data                 =>  l_msg_data);
       END IF;

--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('set_no_contact_in_tca: ' || 'Update Contact Preference:'||l_return_status);
       END IF;
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	  RAISE L_API_ERROR;
       END IF;

    ELSE
--     Dbms_output.put_line('P Id '||l_contact_preference_id||' Null');
       null;
    END IF;
    CLOSE C_DO_PARTY;
    l_contact_preference_id := null;

    OPEN C_DO_NOT_PARTY(l_p_party_id);
    FETCH c_do_not_party INTO l_contact_preference_id;
    IF c_do_not_party%FOUND THEN  -- fetch succeeded
--     Dbms_output.put_line('P Id*'||l_contact_preference_id||' Null');
       null;
    ELSE
--     Dbms_output.put_line('P Id*'||l_contact_preference_id||' Create');
       l_contact_preference_rec.CONTACT_LEVEL_TABLE := 'HZ_PARTIES';
       l_contact_preference_rec.CONTACT_LEVEL_TABLE_ID := l_p_party_id;
       l_contact_preference_rec.PREFERENCE_CODE := 'DO_NOT';
       l_contact_preference_rec.REQUESTED_BY := 'PARTY';
       --Begin bug#5087608 schekuri 27-May-2006
       --"CONTACT" lookup code is inactive in AR lookup type CONTACT_TYPE
       l_contact_preference_rec.CONTACT_TYPE := 'ALL';
       --l_contact_preference_rec.CONTACT_TYPE := 'CONTACT';
       --End bug#5087608 schekuri 27-May-2006
       l_contact_preference_rec.PREFERENCE_START_DATE := sysdate;
       l_contact_preference_rec.STATUS := 'A';
       l_contact_preference_rec.CREATED_BY_MODULE := 'IEX';

       HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference (
              p_init_msg_list             =>  l_init_msg_list,
              p_contact_preference_rec    =>  l_contact_preference_rec,
              x_contact_preference_id     =>  o_contact_preference_id,
              x_return_status             =>  l_return_status,
              x_msg_count                 =>  l_msg_count,
              x_msg_data                  =>  l_msg_data);

--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('set_no_contact_in_tca: ' || 'Create Contact Preference:'||l_return_status);
       END IF;
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	  RAISE L_API_ERROR;
       END IF;

    END IF;
    CLOSE C_DO_NOT_PARTY;
    l_contact_preference_id := null;

  END LOOP;
  CLOSE C_PARTY;

/*
  HZ_CONTACT_PREFERENCE_V2PUB.get_contact_preference_rec (
    p_init_msg_list                         =>  l_init_msg_list,
    p_contact_preference_id                 =>  l_contact_preference_id,
    x_contact_preference_rec                =>  l_contact_preference_rec,
    x_return_status                         =>  l_return_status,
    x_msg_count                             =>  l_msg_count,
    x_msg_data                              =>  l_msg_data);

  HZ_contact_perference_v2pub.create_contact_preference (
    p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
    p_contact_preference_rec    IN      CONTACT_PREFERENCE_REC_TYPE,
    x_contact_preference_id     OUT NOCOPY     NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  );

  HZ_contact_perference_v2pub.update_contact_preference (
    p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
    p_contact_preference_rec                IN      CONTACT_PREFERENCE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY  NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2);

  */

  result := 'COMPLETE';

EXCEPTION
		WHEN l_API_ERROR then
      		WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('IEX_WF_BAN_STATUS_PUB', 'set_no_contact_in_TCA',
		      itemtype, itemkey, actid, funcmode);
      RAISE;

END set_no_contact_in_tca;

-- procedure turnoff_collection_profile  -----------------------------
procedure turnoff_collection_profile(
						itemtype    				IN VARCHAR2,
            itemkey     				IN VARCHAR2,
            actid								IN NUMBER,
            funcmode    				IN VARCHAR2,
            result      				OUT NOCOPY VARCHAR2) IS

  l_api_name     				VARCHAR2(100);
  l_errmsg_name					VARCHAR2(30);
  l_api_error						EXCEPTION;
  l_profile             VARCHAR2(1);

BEGIN

  l_api_name     		:= 'create delinquency';
  if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

  l_profile := NVL(fnd_profile.value('IEX_TURNOFF_COLLECT_BANKRUPTCY'), 'Y');


  wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'TURNOFF_COLLECTION_PROFILE',
                avalue   =>   l_profile);

  IF l_profile = 'Y' THEN
  	 result := wf_engine.eng_completed ||':Y';
--     result := 'COMPLETE:Y';
  ELSE
  	 result := wf_engine.eng_completed ||':N';
--     result := 'COMPLETE:N';
  END IF;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('turnoff_collection_profile: ' || 'result =>'||result);
  END IF;

EXCEPTION
		WHEN l_API_ERROR then
      		WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('IEX_WF_BAN_STATUS_PUB', 'Create_Strategy',
		      itemtype, itemkey, actid, funcmode);
      RAISE;

END turnoff_collection_profile;


-- ******************************************************************
PROCEDURE turnoff_collections
(
						itemtype    				IN VARCHAR2,
            itemkey     				IN VARCHAR2,
            actid								IN NUMBER,
            funcmode    				IN VARCHAR2,
            result      				OUT NOCOPY VARCHAR2) IS

  l_errmsg_name					VARCHAR2(30);
  l_api_error						EXCEPTION;
  l_turnoff_collection_profile VARCHAR2(1);
  l_turnoff_invoice_profile VARCHAR2(1);
  l_default_notice_profile VARCHAR2(1);
  l_msg_count     			NUMBER;
  l_msg_data     			  VARCHAR2(2000);
  l_api_name     			  VARCHAR2(100);
  l_api_version_number   NUMBER ;
  l_object_code         VARCHAR2(10);
  l_source_module       VARCHAR2(20);
  P_ObjectType          VARCHAR2(30);
  p_ObjectID            NUMBER;
  l_init_msg_list       VARCHAR2(1);
  l_return_status  		  VARCHAR2(20);
  l_commit              varchar2(1);
  l_validation_level    NUMBER;
  l_party_id            NUMBER;
  l_cas_id              NUMBER;
  p_delinquency_id      NUMBER;
  p_bankruptcy_id       NUMBER;

  CaseIdTab IEX_UTILITIES.t_numbers;
  DelIdTab IEX_UTILITIES.t_numbers;

  CURSOR C_CASE(p_party_id NUMBER) IS
  SELECT cas_id
  FROM iex_cases_all_b
  WHERE party_id = p_party_id;

  CURSOR C_DELINQ(p_case_id NUMBER) IS
  SELECT delinquency_id
  FROM iex_delinquencies
  WHERE case_id = p_case_id ;

  l_case_id    NUMBER;
  l_case_count NUMBER;
  l_del_id     NUMBER;
  l_del_count  NUMBER;
  l_ban_id     NUMBER;

  bankruptcy_REC          IEX_BANKRUPTCIES_PVT.bankruptcy_Rec_Type;
  TYPE  bankruptcy_Tbl_Type      IS TABLE OF IEX_BANKRUPTCIES_PVT.bankruptcy_Rec_Type
                                 INDEX BY BINARY_INTEGER;
  bankruptcy_TBL          bankruptcy_Tbl_Type;

BEGIN

  l_api_name   := 'Turn Off Collections';
  l_api_version_number := 1.0;
  l_object_code        := 'IEX_CASE';
  l_source_module      := 'create_delinquency';
  P_ObjectType         := 'BANKRUPTCY';
  p_ObjectID           := p_bankruptcy_id;
  l_init_msg_list      := FND_API.G_FALSE;

  if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

  --get profile
/*
  l_turnoff_collection_profile := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'TURNOFF_COLLECTION_PROFILE');

  l_party_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'PARTY_ID');

--    l_turnoff_collection_profile := NVL(fnd_profile.value('IEX_TURNOFF_COLLECT_BANKRUPTCY'), 'Y');
--    dbms_output.put_line('Profile '||l_turnoff_collection_profile);

  OPEN C_CASE(l_party_id);
  LOOP
    FETCH C_CASE INTO l_case_id;
    EXIT WHEN NOT C_CASE%FOUND;
      --dbms_output.put_line('l_case_id '||l_case_id);

    OPEN C_DELINQ(l_case_id);
    FETCH C_DELINQ INTO l_del_id;
      --dbms_output.put_line('No of Del '||C_DELINQ%ROWCOUNT);

      IF NOT C_DELINQ%FOUND THEN
         --dbms_output.put_line('Create Del and Ban Here');
         --Create Del and Ban Record Here
         --dbms_output.put_line('Create Del and Ban Here');
         CaseIdTab(1) := l_cas_id;

         -- Create Del and Ban Record Here
         IEX_DELINQUENCY_PUB.Create_Ind_Delinquency
            (p_api_version         =>  l_api_version_number,
             p_init_msg_list       =>  l_init_msg_list,
             p_commit              =>  l_commit,
             p_validation_level    =>  l_validation_level,
             x_return_status       =>  l_return_status,
             x_msg_count           =>  l_msg_count,
             x_msg_data            =>  l_msg_data,
             p_source_module       =>  'IEX_WF_BAN_STATUS_PUN.create_delinquency',  --Name of the calling procedure in the format Package.Procedure
             p_party_id            =>  l_party_id,
             p_object_code         =>  'IEX_CASE' , --'IEX_CASE'  for now.
             p_object_id_tbl       =>  CaseIdTab,   -- Table of Case Ids.
             x_del_id_tbl          =>  DelIdTab     -- Table of Deliquencies that got created (Index correspoding to the case_id table);
             );
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logMessage('In turnoff_collections.Create Ind Delinquency: ' ||l_return_status);
         END IF;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         	  RAISE L_API_ERROR;
         END IF;

         l_del_id := DelIdTab(1);
      END IF;
      CLOSE C_DELINQ;

      bankruptcy_REC.Cas_id := l_cas_id;
      bankruptcy_REC.delinquency_id := l_del_id;
      bankruptcy_REC.party_id := l_party_id;

      IEX_BANKRUPTCIES_PVT.Create_bankruptcy(
             P_Api_Version_Number  =>  l_api_version_number,
             P_Init_Msg_List       =>  l_init_msg_list,
             P_Commit              =>  l_commit,
             p_validation_level    =>  l_validation_level,
             P_bankruptcy_Rec      =>  bankruptcy_REC,
             X_BANKRUPTCY_ID       =>  l_ban_id,
             X_Return_Status       =>  l_return_status,
             X_Msg_Count           =>  l_msg_count,
             X_Msg_Data            =>  l_msg_data
             );
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logMessage('In turnoff_collections.Create bankruptcy: ' ||l_return_status);
      END IF;
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE L_API_ERROR;
      END IF;

      IEX_STRATEGY_PUB.create_strategy(
             P_Api_Version_Number  => l_api_version_number,
             P_Init_Msg_List       => l_init_msg_list,
             P_Commit              => l_commit,
             p_validation_level    => l_validation_level,
             X_Return_Status       => l_return_status,
             X_Msg_Count           => l_msg_count,
             X_Msg_Data            => l_msg_data,
             p_DelinquencyID       => l_del_id,
             p_ObjectType          => P_ObjectType,
             p_ObjectID            => P_ObjectID);

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logMessage('In turnoff_collections.Create strategy: ' ||l_return_status);
      END IF;
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE L_API_ERROR;
      END IF;

      l_del_id := null;
    END LOOP;
    CLOSE C_CASE;
*/
  result := 'COMPLETE';

EXCEPTION
		WHEN L_API_ERROR then
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('IEX_WF_BAN_STATUS_PUB', 'turnoff Bankrupt Collections',
		      itemtype, itemkey, actid, funcmode);
      RAISE;

END turnoff_collections;

-- ******************************************************************
PROCEDURE no_turnoff_collections
(
						itemtype    				IN VARCHAR2,
            itemkey     				IN VARCHAR2,
            actid								IN NUMBER,
            funcmode    				IN VARCHAR2,
            result      				OUT NOCOPY VARCHAR2) IS

  l_errmsg_name					VARCHAR2(30);
  l_api_error						EXCEPTION;
  l_turnoff_collection_profile VARCHAR2(1);
  l_turnoff_invoice_profile VARCHAR2(1);
  l_default_notice_profile VARCHAR2(1);
  l_msg_count     			NUMBER;
  l_msg_data     			  VARCHAR2(2000);
  l_api_name     			  VARCHAR2(100);
  l_api_version_number   NUMBER;
  l_init_msg_list       VARCHAR2(3) ;
  l_commit              varchar2(1) ;
  l_object_code         VARCHAR2(10);
  l_source_module       VARCHAR2(20);
  l_party_id            NUMBER;
  l_return_status  		  VARCHAR2(20);
  l_validation_level    NUMBER;
  l_cas_id              NUMBER;
  p_delinquency_id      NUMBER;
  p_bankruptcy_id       NUMBER;

  CaseIdTab IEX_UTILITIES.t_numbers;
  DelIdTab IEX_UTILITIES.t_numbers;

  CURSOR C_CASE(p_party_id NUMBER) IS
  SELECT cas_id
  FROM iex_cases_all_b
  WHERE party_id = p_party_id;

  CURSOR C_DELINQ(p_case_id NUMBER) IS
  SELECT delinquency_id
  FROM iex_delinquencies
  WHERE case_id = p_case_id;

  l_case_id    NUMBER;
  l_case_count NUMBER;
  l_del_id     NUMBER;
  l_del_count  NUMBER;
  l_ban_id     NUMBER;

  bankruptcy_REC                 IEX_BANKRUPTCIES_PVT.bankruptcy_Rec_Type;
  TYPE  bankruptcy_Tbl_Type      IS TABLE OF IEX_BANKRUPTCIES_PVT.bankruptcy_Rec_Type
                                 INDEX BY BINARY_INTEGER;
  bankruptcy_TBL                 bankruptcy_Tbl_Type;

  P_ObjectType          VARCHAR2(30);
  p_ObjectID            NUMBER;

BEGIN
 -- 12/15/04
 -- obseleting this routine,we will have only one bankruptcy record in the database
  l_api_version_number := 1.0;
  l_init_msg_list      := FND_API.G_FALSE;
  l_commit             := 'T';
  l_object_code        := 'IEX_CASE';
  l_source_module      := 'create_delinquency';

  P_ObjectType         := 'BANKRUPTCY';
  p_ObjectID           := p_bankruptcy_id;

  if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

/*
  --get profile
  l_turnoff_collection_profile := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'TURNOFF_COLLECTION_PROFILE');

  l_party_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'PARTY_ID');

--l_turnoff_collection_profile := NVL(fnd_profile.value('IEX_TURNOFF_COLLECT_BANKRUPTCY'), 'Y');
--dbms_output.put_line('Profile '||l_turnoff_collection_profile);

  OPEN C_CASE(l_party_id);
        --      l_case_count := C_CASE%ROWCOUNT;
  LOOP
    FETCH C_CASE INTO l_case_id;
    EXIT WHEN NOT C_CASE%FOUND;
      --dbms_output.put_line('l_case_id '||l_case_id);

    OPEN C_DELINQ(l_case_id);
    FETCH C_DELINQ INTO l_del_id;
      --dbms_output.put_line('No of Del '||C_DELINQ%ROWCOUNT);

      IF NOT C_DELINQ%FOUND THEN
         --dbms_output.put_line('Create Del and Ban Here');
         --Create Del and Ban Record Here
         --dbms_output.put_line('Create Del and Ban Here');
         CaseIdTab(1) := l_cas_id;

         -- Create Del and Ban Record Here
         IEX_DELINQUENCY_PUB.Create_Ind_Delinquency
            (p_api_version         =>  l_api_version_number,
             p_init_msg_list       =>  l_init_msg_list,
             p_commit              =>  l_commit,
             p_validation_level    =>  l_validation_level,
             x_return_status       =>  l_return_status,
             x_msg_count           =>  l_msg_count,
             x_msg_data            =>  l_msg_data,
             p_source_module       =>  'IEX_WF_BAN_STATUS_PUN.create_delinquency',  --Name of the calling procedure in the format Package.Procedure
             p_party_id            =>  l_party_id,
             p_object_code         =>  'IEX_CASE' , --'IEX_CASE'  for now.
             p_object_id_tbl       =>  CaseIdTab,   -- Table of Case Ids.
             x_del_id_tbl          =>  DelIdTab     -- Table of Deliquencies that got created (Index correspoding to the case_id table);
             );
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('In no_turnoff_collections.Create Ind Delinquency: ' ||l_return_status);
        END IF;
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE L_API_ERROR;
        END IF;

        l_del_id := DelIdTab(1);

        bankruptcy_REC.Cas_id := l_cas_id;
        bankruptcy_REC.delinquency_id := l_del_id;
        bankruptcy_REC.party_id := l_party_id;

        IEX_BANKRUPTCIES_PVT.Create_bankruptcy(
             P_Api_Version_Number  =>  l_api_version_number,
             P_Init_Msg_List       =>  l_init_msg_list,
             P_Commit              =>  l_commit,
             p_validation_level    =>  l_validation_level,
             P_bankruptcy_Rec      =>  bankruptcy_REC,
             X_BANKRUPTCY_ID       =>  l_ban_id,
             X_Return_Status       =>  l_return_status,
             X_Msg_Count           =>  l_msg_count,
             X_Msg_Data            =>  l_msg_data
             );
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('In no_turnoff_collections.Create bankruptcy: ' ||l_return_status);
        END IF;
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE L_API_ERROR;
        END IF;

        IEX_STRATEGY_PUB.create_strategy(
             P_Api_Version_Number  => l_api_version_number,
             P_Init_Msg_List       => l_init_msg_list,
             P_Commit              => l_commit,
             p_validation_level    => l_validation_level,
             X_Return_Status       => l_return_status,
             X_Msg_Count           => l_msg_count,
             X_Msg_Data            => l_msg_data,
             p_DelinquencyID       => l_del_id,
             p_ObjectType          => P_ObjectType,
             p_ObjectID            => P_ObjectID);
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('In no_turnoff_collections.Create strategy: ' ||l_return_status);
        END IF;
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE L_API_ERROR;
        END IF;

        l_del_id := null;
      END IF;
      CLOSE C_DELINQ;

    END LOOP;
    CLOSE C_CASE;
*/

  result := 'COMPLETE';

EXCEPTION
		WHEN L_API_ERROR then
      		WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('IEX_WF_BAN_STATUS_PUB', 'turnoff Bankrupt Collections',
		      itemtype, itemkey, actid, funcmode);
      RAISE;

END no_turnoff_collections;

-- procedure Create Strategy  -----------------------------
PROCEDURE Create_Strategy(
            p_api_version       IN NUMBER DEFAULT 1.0,
            p_init_msg_list     IN VARCHAR2 ,
            p_commit            IN VARCHAR2 ,
	    p_delinquency_id 		IN NUMBER,
            p_bankruptcy_id 		IN NUMBER,
            p_party_id 		      IN NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_count         OUT NOCOPY NUMBER,
            x_msg_data          OUT NOCOPY VARCHAR2) IS

  l_errmsg_name					VARCHAR2(30);
  L_API_ERROR						EXCEPTION;
  l_msg_count     			NUMBER;
  l_msg_data     			  VARCHAR2(2000);
  l_return_status  		  VARCHAR2(20);
  l_commit              varchar2(1);
  l_validation_level    NUMBER;
  l_error_msg     			VARCHAR2(2000);

  P_ObjectType          VARCHAR2(30);
  p_ObjectID            NUMBER;
  l_api_version_number   NUMBER;
  l_api_name     				VARCHAR2(100);
  l_init_msg_list       VARCHAR2(1);
  l_disposition_code	varchar2(30);

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT START_STRATEGY;

  P_ObjectType        := 'BANKRUPTCY';
  p_ObjectID          := p_bankruptcy_id;
  l_api_version_number := 1.0;
  l_api_name     := 'Create Strategy';
  l_init_msg_list := FND_API.G_FALSE;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
          FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Create Strategy for a object

    P_API_VERSION_NUMBER := 2.0
    P_ObjectType := 'DELINQUENT', 'BANKRUPTCY', 'WRITEOFF', 'REPOSSESSION', 'LITIGATION', 'BANKRUPTCY'
    p_ObjectID := DelinquencyID, BankRuptcyID, WriteoffID, RepossessionID, Litigation ID, Bankruptcy ID
  */

    select disposition_code
    into l_disposition_code
    from iex_bankruptcies
    where bankruptcy_id = p_bankruptcy_id;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	IEX_DEBUG_PUB.logMessage('Create_Strategy : l_disposition_code := ' ||l_disposition_code);
    END IF;

   if l_disposition_code is NULL then
	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('Create_Strategy : Calling IEX_STRATEGY_PUB.create_strategy');
	    END IF;
	  IEX_STRATEGY_PUB.create_strategy(
	    P_Api_Version_Number   => l_api_version_number,
	    P_Init_Msg_List        => l_init_msg_list,
	    P_Commit               => l_commit,
	    p_validation_level     => l_validation_level,
	    X_Return_Status        => l_return_status,
	    X_Msg_Count            => l_msg_count,
	    X_Msg_Data             => l_msg_data,
	    p_DelinquencyID        => p_delinquency_id,
	    p_ObjectType           => P_ObjectType,
	    p_ObjectID             => P_ObjectID);
   else
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('Start cancel_strategy_and_workflow');
	END IF;
   end if;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );
--Start bug 6717204 gnramasa 11th Jan 08
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
		 ROLLBACK TO START_STRATEGY;
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ROLLBACK TO START_STRATEGY;
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      WHEN OTHERS THEN
		 ROLLBACK TO START_STRATEGY;
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		 END IF;
		 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
--End bug 6717204 gnramasa 11th Jan 08
END Create_Strategy;

--Start bug 7661724 gnramasa 8th Jan 09
procedure cancel_strategy_and_workflow(
            p_party_id 		IN NUMBER,
	    p_bankruptcy_id     IN NUMBER,
	    p_disposition_code  IN VARCHAR2)
IS
cursor c_get_strategy_id (l_bkrid number) is
select st.strategy_id
from iex_strategies st
where st.status_code = 'OPEN'
and st.jtf_object_type = 'IEX_BANKRUPTCY'
and st.jtf_object_id = l_bkrid;

l_startegy_id	number;
l_item_type	VARCHAR2(100) := 'IEXBANST';
l_result	VARCHAR2(100);
l_status	VARCHAR2(8);

-- Begin bug 7703313
l_itemkey       varchar2(240);

cursor get_cr_itemkey(c_id number) is
       select distinct item_key from wf_item_attr_values_ondemand
         where name = 'BANKRUPTCY_ID' and number_value = c_id and item_type = 'IEXDELCR';
cursor get_cs_itemkey(c_id number) is
       select distinct item_key from wf_item_attr_values_ondemand
         where name = 'BANKRUPTCY_ID' and number_value = c_id and item_type = 'IEXDELCS';
-- End bug 7703313

begin
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('Start cancel_strategy_and_workflow');
	END IF;
	SAVEPOINT cancel_strategy_and_workflow;

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('cancel_strategy_and_workflow: p_party_id =>' || p_party_id);
		IEX_DEBUG_PUB.logMessage('cancel_strategy_and_workflow: p_bankruptcy_id =>' || p_bankruptcy_id);
		IEX_DEBUG_PUB.logMessage('cancel_strategy_and_workflow: p_disposition_code =>' || p_disposition_code);
	END IF;

        begin
	   open c_get_strategy_id (p_bankruptcy_id);
	   fetch c_get_strategy_id into l_startegy_id;
	   close c_get_strategy_id;

	   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('cancel_strategy_and_workflow: l_startegy_id =>' || l_startegy_id);
	   END IF;

           exception
             when others then IEX_DEBUG_PUB.logMessage('exception to get strategy ID'); null;
        end;

	if l_startegy_id is not null then
		begin
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				IEX_DEBUG_PUB.logMessage('cancel_strategy_and_workflow: Before calling IEX_STRATEGY_WF.SEND_SIGNAL');
			END IF;
			IEX_STRATEGY_WF.SEND_SIGNAL(process     => 'IEXSTRY',
						  strategy_id => l_startegy_id,
						  status      => 'CANCELLED' ) ;

			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				IEX_DEBUG_PUB.logMessage('cancel_strategy_and_workflow: After calling IEX_STRATEGY_WF.SEND_SIGNAL');
			END IF;
		exception
		when others then
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				IEX_DEBUG_PUB.logMessage('cancel_strategy_and_workflow: In others exception');
			END IF;
			Update iex_strategies set status_code =  'CANCELLED'
			 where  strategy_id = l_startegy_id;

			update iex_strategy_work_items
			set status_code =  'CANCELLED'
			where  strategy_id = l_startegy_id
			and status_code in ('PRE-WAIT','OPEN');

			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				IEX_DEBUG_PUB.logMessage('cancel_strategy_and_workflow: End of others exception');
			END IF;
		end;
	end if;

	if (p_disposition_code = 'WITHDRAWN') or (p_disposition_code = 'DISMISSED') then
            begin
		wf_engine.itemstatus(itemtype => l_item_type,   itemkey => p_bankruptcy_id,   status => l_status,   result => l_result);
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			IEX_DEBUG_PUB.logMessage('cancel_strategy_and_workflow: Workflow status =>' || l_status);
		END IF;

		IF l_status <> wf_engine.eng_completed THEN
			wf_engine.abortprocess(itemtype => l_item_type,   itemkey => p_bankruptcy_id);
			wf_engine.itemstatus(itemtype => l_item_type,   itemkey => p_bankruptcy_id,   status => l_status,   result => l_result);
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				IEX_DEBUG_PUB.logMessage('cancel_strategy_and_workflow: Abort process has completed and status =>' || l_status);
			END IF;

		 END IF;
		 EXCEPTION
                      when others then IEX_DEBUG_PUB.logMessage('exception to disposition code step 1 '); null;

	     END;

                 -- Begin bug 7703313
             begin
                   open get_cs_itemkey(p_bankruptcy_id);
                   Loop
                        fetch get_cs_itemkey into l_itemkey;
                        exit when get_cs_itemkey%NOTFOUND;

                        if (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			   IEX_DEBUG_PUB.logMessage('IEXDELCS Workflow Status = :: =>' || l_status||'and itemkey is...'||l_itemkey);
		        end if;

                        wf_engine.itemstatus(itemtype => 'IEXDELCS',   itemkey => l_itemkey,   status => l_status,   result => l_result);
                        if (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			   IEX_DEBUG_PUB.logMessage('IEXDELCS Workflow Status = :: =>' || l_status||'and itemkey is...'||l_itemkey);
		        end if;

                        if l_status <> wf_engine.eng_completed THEN
			   wf_engine.abortprocess(itemtype => 'IEXDELCS',   itemkey => l_itemkey);
			   wf_engine.itemstatus(itemtype => 'IEXDELCS',   itemkey => l_itemkey,   status => l_status,   result => l_result);
			   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				IEX_DEBUG_PUB.logMessage('cancel serviceHold_workflow: Abort process has completed and status =>' || l_status);
			   END IF;
                        end if;
                    End Loop;
                    close get_cs_itemkey;

                    exception
                        when others then
                             IEX_DEBUG_PUB.logMessage('ServiceHold Workflow does not exist '||p_bankruptcy_id);
                             null;
            end;

            begin
                   open get_cr_itemkey(p_bankruptcy_id);
                   Loop
                        fetch get_cr_itemkey into l_itemkey;
                        exit when get_cr_itemkey%NOTFOUND;

                        if (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			    IEX_DEBUG_PUB.logMessage('IEXDELCR Workflow Status = :: =>' || l_status||'and itemkwy is ...'||l_itemkey);
		        end if;

                        wf_engine.itemstatus(itemtype => 'IEXDELCR',   itemkey => l_itemkey,   status => l_status,   result => l_result);
                        if (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			    IEX_DEBUG_PUB.logMessage('IEXDELCR Workflow Status = :: =>' || l_status||'and itemkwy is ...'||l_itemkey);
		        end if;

                        if l_status <> wf_engine.eng_completed THEN
		           wf_engine.abortprocess(itemtype => 'IEXDELCR',   itemkey => l_itemkey);
			   wf_engine.itemstatus(itemtype => 'IEXDELCR',   itemkey => l_itemkey,   status => l_status,   result => l_result);
			   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				IEX_DEBUG_PUB.logMessage('cancel_creditHold_request_workflow: Abort process has completed and status =>' || l_status);
	                   END IF;
                        end if;
                    End Loop;
                    close get_cr_itemkey;

              exception
                        when others then
                             IEX_DEBUG_PUB.logMessage('Credit Hold Request Workflow does not exist '||p_bankruptcy_id);
                             null;
            end;
                 -- End bug 7703313

	end if;
	commit;
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('End cancel_strategy_and_workflow');
	END IF;
end cancel_strategy_and_workflow;
--End bug 7661724 gnramasa 8th Jan 09

BEGIN

     G_PKG_NAME  := 'IEX_WF_BAN_STATUS_PUB';
     PG_DEBUG    := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

END IEX_WF_BAN_STATUS_PUB;

/
