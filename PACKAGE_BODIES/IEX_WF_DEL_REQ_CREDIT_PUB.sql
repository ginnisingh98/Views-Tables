--------------------------------------------------------
--  DDL for Package Body IEX_WF_DEL_REQ_CREDIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WF_DEL_REQ_CREDIT_PUB" AS
/* $Header: iexwfdcb.pls 120.1.12010000.2 2008/10/16 17:37:06 ehuh ship $ */
/*
 * This procedure needs to be called with an itemtype and workflow process
 * which'll launch workflow .Start Workfolw will call workflow based on
 * Meth_flag in methodology base table
*/

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_WF_DEL_REQ_CREDIT_PUB';

PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

PROCEDURE start_workflow
(
            p_api_version       IN NUMBER := 1.0,
            p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
            p_commit            IN VARCHAR2 := FND_API.G_FALSE,
            p_user_id   				IN NUMBER,
            p_delinquency_id 		IN NUMBER,
            p_del_type          IN VARCHAR2,
            p_repossession_id 	IN NUMBER,
            p_litigation_id 		IN NUMBER,
            p_writeoff_id 		  IN NUMBER,
            p_bankruptcy_id     IN NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_count         OUT NOCOPY NUMBER,
            x_msg_data          OUT NOCOPY VARCHAR2
)
IS
           l_result       			VARCHAR2(10);
           itemtype       			VARCHAR2(30);
           itemkey       				VARCHAR2(30);
           workflowprocess  		VARCHAR2(30);
           l_user_id            NUMBER;
           l_user_name          VARCHAR2(60);
           l_manager_id         NUMBER;
           l_manager_name       VARCHAR2(60);

           l_error_msg     			VARCHAR2(2000);
           l_return_status  		VARCHAR2(20);
           l_msg_count     			NUMBER;
           l_msg_data     			VARCHAR2(2000);
           l_api_name     			VARCHAR2(100) := 'START_WORKFLOW';
           l_api_version_number CONSTANT NUMBER := 1.0;

      CURSOR c_manager(p_user_id NUMBER) IS
      SELECT b.user_id, b.user_name
      FROM JTF_RS_RESOURCE_EXTNS a
      ,    JTF_RS_RESOURCE_EXTNS b
      WHERE b.source_id = a.source_mgr_id
      AND a.user_id = p_user_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT START_WORKFLOW;
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

    SELECT TO_CHAR(IEX_DEL_WF_S.NEXTVAL) INTO itemkey FROM dual;
--		itemkey := TO_CHAR(p_delinquency_id);
    itemtype := 'IEXDELCR';
    workflowprocess := 'CREDIT_HOLD';

    IF p_del_type = 'Delinquency' THEN

       itemkey := 'DEL'||itemkey;               --to_char(p_delinquency_id);
--DBMS_OUTPUT.PUT_LINE('itemkey = ' || itemkey);

       wf_engine.createprocess  (  itemtype => itemtype,
              itemkey  => itemkey,
              process  => 'CREDIT_HOLD');

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'DEL_TYPE',
                avalue   =>   'Delinquency');

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'DELINQUENCY_ID',
                avalue   =>   p_delinquency_id);

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'UNIQUE_ID',
                avalue   =>   'Delinquency Id: '||p_delinquency_id);

    ELSIF p_del_type = 'Repossession' THEN

       itemkey := 'REP'||itemkey;      --to_char(p_repossession_id);
--DBMS_OUTPUT.PUT_LINE('itemkey = ' || itemkey);

       wf_engine.createprocess  (  itemtype => itemtype,
              itemkey  => itemkey,
              process  => 'CREDIT_HOLD');

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'DEL_TYPE',
                avalue   =>   'Repossession');
--DBMS_OUTPUT.PUT_LINE('*');

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'REPOSSESSION_ID',
                avalue   =>   p_repossession_id);
--DBMS_OUTPUT.PUT_LINE('**');

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'UNIQUE_ID',
                avalue   =>   'Reposession Id: '||p_repossession_id);
--DBMS_OUTPUT.PUT_LINE('***');

    ELSIF p_del_type = 'Litigation' THEN

       itemkey := 'LIT'||itemkey;               --to_char(p_litigation_id);

       wf_engine.createprocess  (  itemtype => itemtype,
              itemkey  => itemkey,
              process  => 'CREDIT_HOLD');

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'DEL_TYPE',
                avalue   =>   'Litigation');

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'LITIGATION_ID',
                avalue   =>   p_litigation_id);

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'UNIQUE_ID',
                avalue   =>   'Litigation Id: '||p_litigation_id);

    ELSIF p_del_type = 'Writeoff' THEN

       itemkey := 'WRI'||itemkey;                --to_char(p_writeoff_id);

       wf_engine.createprocess  (  itemtype => itemtype,
              itemkey  => itemkey,
              process  => 'CREDIT_HOLD');

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'DEL_TYPE',
                avalue   =>   'Writeoff');

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'WRITEOFF_ID',
                avalue   =>   p_writeoff_id);

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'UNIQUE_ID',
                avalue   =>   'Writeoff Id: '||p_writeoff_id);

    ELSIF p_del_type = 'Bankruptcy' THEN

       itemkey := 'Ban'||itemkey;                --to_char(p_bankruptcy_id);
--DBMS_OUTPUT.PUT_LINE('itemkey = ' || itemkey);

       wf_engine.createprocess  (  itemtype => itemtype,
              itemkey  => itemkey,
              process  => 'CREDIT_HOLD');

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'DEL_TYPE',
                avalue   =>   'Bankrupt');

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'BANKRUPTCY_ID',
                avalue   =>   p_bankruptcy_id);

       wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'UNIQUE_ID',
                avalue   =>   'Bankruptcy Id: '||p_bankruptcy_id);

    ELSE
    	null;
--        result := 'COMPLETE';
    END IF;
--DBMS_OUTPUT.PUT_LINE('*');
		-- Get manager
		SELECT user_name INTO l_user_name from JTF_RS_RESOURCE_EXTNS
		WHERE user_id = p_user_id;

    OPEN C_MANAGER(p_user_id);
    FETCH C_MANAGER INTO l_manager_id, l_manager_name;
    IF C_MANAGER%NOTFOUND THEN
    	 l_manager_id := p_user_id;
    	 l_manager_name := l_user_name;
    END IF;
    CLOSE C_MANAGER;
--DBMS_OUTPUT.PUT_LINE('**');
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

    wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'REQUESTER_NAME',
                avalue   =>   l_user_name);

    wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'REQUESTER_ID',
                avalue   =>   p_user_id);

    wf_engine.startprocess( itemtype =>   itemtype,
                          itemkey  =>   itemkey);

    wf_engine.ItemStatus(  itemtype =>   ItemType,
                           itemkey  =>   ItemKey,
                           status   =>   l_return_status,
                           result   =>   l_result);
--DBMS_OUTPUT.PUT_LINE('***'||l_return_status);
    if (l_return_status = 'COMPLETE') OR (l_return_status = 'ACTIVE') THEN
       x_return_status := 'S';
       commit;
    else
       x_return_status := 'F';
    end if;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => as_utility_pvt.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
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

  l_manager_name 				varchar2(60);
  l_delinquency_id			number(30);
  l_repossession_id			number;
  l_litigation_id			  number;
  l_writeoff_id	    		number;
  l_bankruptcy_id       number;
  l_responder           varchar2(100);
  l_text_value          varchar2(2000);
  l_del_type            varchar2(100);
  l_del_type_id         varchar2(100);
  l_dummy               varchar2(1);
  l_api_name     				VARCHAR2(100) := 'update_approval_status';
  l_errmsg_name					VARCHAR2(30);
  L_API_ERROR						EXCEPTION;

  -- Bug 6936225 by Ehuh
  CURSOR c_get_acct (in_bankruptcy_id number) IS
     select cust_account_id
       from hz_cust_accounts
      where party_id = (select party_id from iex_bankruptcies
                          where bankruptcy_id = in_bankruptcy_id)
        and status = 'A';

  TYPE ACCT_ID_TBL_TYPE is Table of NUMBER
                           INDEX BY BINARY_INTEGER;
  l_acct_id_tbl      ACCT_ID_TBL_TYPE;
  iIdx               NUMBER := 0;
  l_account_id       VARCHAR2(10);
  l_return_status    VARCHAR2(20);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);

BEGIN

  iex_debug_pub.logmessage ('IEX_WF_DEL_REQ_CREDIT_PUB: Starting update_approval_status......= ');

  if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

  l_manager_name := wf_engine.GetItemAttrText(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'MANAGER_NAME');

  l_delinquency_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'DELINQUENCY_ID');

  l_del_type := wf_engine.GetItemAttrText(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'DEL_TYPE');

  l_repossession_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'REPOSSESSION_ID');

  l_litigation_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'LITIGATION_ID');

  l_writeoff_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'WRITEOFF_ID');

  l_bankruptcy_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'BANKRUPTCY_ID');

  iex_debug_pub.logmessage ('IEX_WF_DEL_REQ_CREDIT_PUB: l_del_type ......= '||l_del_type);

  IF l_del_type = 'Delinquency' THEN
     update IEX_DELINQUENCIES_ALL
     set CREDIT_HOLD_APPROVED_FLAG = 'Y'
     where delinquency_id = l_delinquency_id;
  ELSIF l_del_type = 'Repossession' THEN
     update IEX_REPOSSESSIONS
     set CREDIT_HOLD_APPROVED_FLAG = 'Y'
     where repossession_id = l_repossession_id;
  ELSIF l_del_type = 'Litigation' THEN
     update IEX_LITIGATIONS
     set CREDIT_HOLD_APPROVED_FLAG = 'Y'
     where litigation_id = l_litigation_id;
  ELSIF l_del_type = 'Writeoff' THEN
     update IEX_WRITEOFFS
     set CREDIT_HOLD_APPROVED_FLAG = 'Y'
     where writeoff_id = l_writeoff_id;
  ELSIF l_del_type = 'Bankrupt' THEN
     iex_debug_pub.logmessage ('IEX_WF_DEL_REQ_CREDIT_PUB: Bankrutpcy Start ......= ');
     update IEX_BANKRUPTCIES
     set CREDIT_HOLD_APPROVED_FLAG = 'Y'
     where bankruptcy_id = l_bankruptcy_id;
     iex_debug_pub.logmessage ('IEX_WF_DEL_REQ_CREDIT_PUB: Bankrutpcy End ......= ');

     -- Bug 6936225 by Ehuh  Starting....
     begin
          Open c_get_acct(l_bankruptcy_id);
          Loop
             Fetch c_get_acct into l_account_id;

             If (C_GET_ACCT%NOTFOUND) THEN
                if (iIdx = 0) then
                   iex_debug_pub.logmessage('IEX:no acct');
                end if;
                exit;
             else
                iIdx := iIdx + 1;
                l_acct_id_tbl(iIdx) := l_account_id;
                iex_debug_pub.logmessage ('IEX: INDEX ......= '||iIdx);
                iex_debug_pub.logmessage ('IEX: l_account_id ......= '||l_account_id);
             end if;
           End Loop;

           Close C_GET_ACCT;
     --
           For i in 1..iIdx loop
                iex_debug_pub.logmessage ('IEX: l_acct_id_tbl(i) .....= '||l_acct_id_tbl(i));
                IEX_CREDIT_HOLD_API.UPDATE_CREDIT_HOLD
                           (p_api_version      => 1.0,
                            p_init_msg_list    => 'T',
                            p_commit           => 'T',
                            p_account_id       => l_acct_id_tbl(i),
                            p_site_id          => null  ,
                            p_credit_hold      => 'Y',
                            x_return_status    => l_return_status,
                            x_msg_count        => l_msg_count,
                            x_msg_data         => l_msg_data);

                iex_debug_pub.logmessage ('IEX_CREDIT_HOLD: l_return_status .....= '||l_return_status);
           End loop;

         exception
            when others then
               iex_debug_pub.logmessage ('Exception from 2nd Begin...... ');
               null;
      end;
     -- Bug 6936225 by Ehuh  Ending....

  ELSE
     iex_debug_pub.logmessage ('IEX_WF_DEL_REQ_CREDIT_PUB: Else ......= ');
     null;
  END IF;

  result := 'COMPLETE';

  EXCEPTION
  	WHEN L_API_ERROR then
                iex_debug_pub.logmessage ('IEX_WF_DEL_REQ_CREDIT_PUB: l_errmsg_name......= '||l_errmsg_name);
      		WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      iex_debug_pub.logmessage ('IEX_WF_DEL_REQ_CREDIT_PUB: Exception Others ......= ');
      WF_CORE.Context('IEX_DEL_REQ_CREDIT_WF_PUB', 'Reject_Contract',
		      itemtype, itemkey, actid, funcmode);
      RAISE;
END update_approval_status;

-- procedure update_rejection_status  -----------------------------
procedure update_rejection_status(
						itemtype    				IN VARCHAR2,
            itemkey     				IN VARCHAR2,
            actid								IN NUMBER,
            funcmode    				IN VARCHAR2,
            result      				OUT NOCOPY VARCHAR2
) is

  l_manager_name 				varchar2(60);
  l_delinquency_id			number(30);
  l_repossession_id			number;
  l_litigation_id			  number;
  l_writeoff_id	    		number;
  l_bankruptcy_id       number;
  l_responder           varchar2(100);
  l_text_value          varchar2(2000);
  l_del_type            varchar2(100);
  l_del_type_id         varchar2(100);
  l_api_name     				VARCHAR2(100) := 'update_rejection_status';
  l_errmsg_name					VARCHAR2(30);
  L_API_ERROR						EXCEPTION;

BEGIN
  l_manager_name := wf_engine.GetItemAttrText(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'MANAGER_NAME');

  l_delinquency_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'DELINQUENCY_ID');

  l_del_type := wf_engine.GetItemAttrText(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'DEL_TYPE');

  l_repossession_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'REPOSSESSION_ID');

  l_litigation_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'LITIGATION_ID');

  l_writeoff_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'WRITEOFF_ID');

  l_bankruptcy_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'BANKRUPTCY_ID');

  IF l_del_type = 'Delinquency' THEN
     update IEX_DELINQUENCIES_ALL
     set CREDIT_HOLD_APPROVED_FLAG = 'N'
     where delinquency_id = l_delinquency_id;
  ELSIF l_del_type = 'Repossession' THEN
     update IEX_REPOSSESSIONS
     set CREDIT_HOLD_APPROVED_FLAG = 'N'
     where repossession_id = l_repossession_id;
  ELSIF l_del_type = 'Litigation' THEN
     update IEX_LITIGATIONS
     set CREDIT_HOLD_APPROVED_FLAG = 'N'
     where litigation_id = l_litigation_id;
  ELSIF l_del_type = 'Writeoff' THEN
     update IEX_WRITEOFFS
     set CREDIT_HOLD_APPROVED_FLAG = 'N'
     where writeoff_id = l_writeoff_id;
  ELSIF l_del_type = 'Bankrupt' THEN
     update IEX_BANKRUPTCIES
     set CREDIT_HOLD_APPROVED_FLAG = 'N'
     where bankruptcy_id = l_bankruptcy_id;
  ELSE
     null;
  END IF;

  result := 'COMPLETE';

EXCEPTION
		WHEN l_API_ERROR then
      		WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('IEX_DEL_REQ_CREDIT_WF_PUB', 'Reject_Contract',
		      itemtype, itemkey, actid, funcmode);
      RAISE;

END update_rejection_status;

END IEX_WF_DEL_REQ_CREDIT_PUB;

/
