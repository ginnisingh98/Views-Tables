--------------------------------------------------------
--  DDL for Package Body IEX_WF_DEL_REQ_SERVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WF_DEL_REQ_SERVICE_PUB" AS
/* $Header: iexwfdsb.pls 120.1 2006/05/30 21:20:01 scherkas noship $ */
/*
 * This procedure needs to be called with an itemtype and workflow process
 * which'll launch workflow .Start Workfolw will call workflow based on
 * Meth_flag in methodology base table
*/

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_WF_DEL_REQ_SERVICE_PUB';

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE start_workflow
(
           	p_api_version      	IN NUMBER := 1.0,
           	p_init_msg_list    	IN VARCHAR2 := FND_API.G_FALSE,
           	p_commit           	IN VARCHAR2 := FND_API.G_FALSE,
	    			p_user_id   				IN NUMBER,
	    			p_delinquency_id 		IN NUMBER,
            p_del_type          IN VARCHAR2,
            p_repossession_id 	IN NUMBER,
            p_litigation_id 		IN NUMBER,
            p_writeoff_id 		  IN NUMBER,
            p_bankruptcy_id     IN NUMBER,
            x_return_status    	OUT NOCOPY VARCHAR2,
            x_msg_count        	OUT NOCOPY NUMBER,
            x_msg_data      		OUT NOCOPY VARCHAR2
)
IS
           l_result       			VARCHAR2(10);
           itemtype       			VARCHAR2(30);
           itemkey       				VARCHAR2(30);
           workflowprocess  		VARCHAR2(30);
           l_sequence           NUMBER;
	    		 l_manager_id				  NUMBER;
	    		 l_manager_name				VARCHAR2(60);
	    		 l_user_name				  VARCHAR2(60);

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

    SELECT TO_CHAR(IEX_DEL_WF_S.NEXTVAL) INTO l_sequence FROM dual;

--		itemkey := TO_CHAR(p_delinquency_id);


    itemtype := 'IEXDELCS';
    workflowprocess := 'SERVICE_HOLD';

--DBMS_OUTPUT.PUT_LINE('Workflow Process = ' || workflowprocess);

    IF p_del_type = 'Delinquency' THEN

       itemkey := 'DEL'||to_char(p_delinquency_id)||to_char(l_sequence);
--DBMS_OUTPUT.PUT_LINE('itemkey = ' || itemkey);

       wf_engine.createprocess  (  itemtype => itemtype,
              itemkey  => itemkey,
              process  => 'SERVICE_HOLD');

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

       itemkey := 'REP'||to_char(p_repossession_id)||to_char(l_sequence);
--DBMS_OUTPUT.PUT_LINE('itemkey = ' || itemkey);

       wf_engine.createprocess  (  itemtype => itemtype,
              itemkey  => itemkey,
              process  => 'SERVICE_HOLD');

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

       itemkey := 'LIT'||to_char(p_litigation_id)||to_char(l_sequence);
--DBMS_OUTPUT.PUT_LINE('itemkey = ' || itemkey);

       wf_engine.createprocess  (  itemtype => itemtype,
              itemkey  => itemkey,
              process  => 'SERVICE_HOLD');

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

       itemkey := 'WRI'||to_char(p_writeoff_id)||to_char(l_sequence);
--DBMS_OUTPUT.PUT_LINE('itemkey = ' || itemkey);

       wf_engine.createprocess  (  itemtype => itemtype,
              itemkey  => itemkey,
              process  => 'SERVICE_HOLD');

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

       itemkey := 'Ban'||to_char(p_writeoff_id)||to_char(l_sequence);

       wf_engine.createprocess  (  itemtype => itemtype,
              itemkey  => itemkey,
              process  => 'SERVICE_HOLD');

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
                avalue   =>   'Bankruptcy Id: '||p_writeoff_id);

    ELSE
    	null;
--        result := 'COMPLETE';
    END IF;
--DBMS_OUTPUT.PUT_LINE('Select manager');

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
--DBMS_OUTPUT.PUT_LINE('Manager Id '||l_manager_id);
--DBMS_OUTPUT.PUT_LINE('Manager Name '||l_manager_name);

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('start_workflow: ' || 'Get manager for Request Service Workflow =>'||
                              l_manager_id);
    END IF;

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

    if (l_return_status = 'COMPLETE') THEN
       x_return_status := 'S';
       commit;
    elsif (l_return_status = 'ACTIVE') THEN
       x_return_status := 'A';
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
  l_delinquency_id			number;
  l_repossession_id			number;
  l_litigation_id			  number;
  l_writeoff_id	    		number;
  l_bankruptcy_id       number;
  l_responder           varchar2(100);
  l_del_type            varchar2(100);
  l_del_type_id         varchar2(100);
  l_dummy               varchar2(1);
  l_api_name     				VARCHAR2(100) := 'update_approval_status';
  l_errmsg_name					VARCHAR2(30);
  L_API_ERROR						EXCEPTION;

BEGIN

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


  IF l_del_type = 'Delinquency' THEN
     update IEX_DELINQUENCIES_ALL
     set SERVICE_HOLD_APPROVED_FLAG = 'Y'
     where delinquency_id = l_delinquency_id;
  ELSIF l_del_type = 'Repossession' THEN
     update IEX_REPOSSESSIONS
     set SERVICE_HOLD_APPROVED_FLAG = 'Y'
     where repossession_id = l_repossession_id;
  ELSIF l_del_type = 'Litigation' THEN
     update IEX_LITIGATIONS
     set SERVICE_HOLD_APPROVED_FLAG = 'Y'
     where litigation_id = l_litigation_id;
  ELSIF l_del_type = 'Writeoff' THEN
     update IEX_WRITEOFFS
     set SERVICE_HOLD_APPROVED_FLAG = 'Y'
     where writeoff_id = l_writeoff_id;
  ELSIF l_del_type = 'Bankruptcy' THEN
     update IEX_BANKRUPTCIES
     set SERVICE_HOLD_APPROVED_FLAG = 'Y'
     where bankruptcy_id = l_bankruptcy_id;
  ELSE
     null;
  END IF;

  result := 'COMPLETE';

  EXCEPTION
  	WHEN L_API_ERROR then
      		WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('IEX_WF_DEL_REQ_SERVICE_PUB', 'Approval_status',
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
  l_responder           varchar2(100);
  l_del_type            varchar2(100);
  l_delinquency_id			number;
  l_repossession_id			number;
  l_litigation_id			  number;
  l_writeoff_id	    		number;
  l_bankruptcy_id       number;
  l_id_length           number;
  l_api_name     				VARCHAR2(100) := 'update rejection Status';
  l_errmsg_name					VARCHAR2(30);
  L_API_ERROR						EXCEPTION;

BEGIN

  if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

  l_manager_name := wf_engine.GetItemAttrText(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'MANAGER_NAME');

  l_del_type := wf_engine.GetItemAttrText(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'DEL_TYPE');

  IF l_del_type = 'Delinquency' THEN
     l_delinquency_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'DELINQUENCY_ID');

     update IEX_DELINQUENCIES_ALL
     set SERVICE_HOLD_APPROVED_FLAG = 'N'
     where delinquency_id = l_delinquency_id;
  ELSIF l_del_type = 'Repossession' THEN
     l_repossession_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'REPOSSESSION_ID');

     update IEX_REPOSSESSIONS
     set SERVICE_HOLD_APPROVED_FLAG = 'N'
     where repossession_id = l_repossession_id;
  ELSIF l_del_type = 'Litigation' THEN
     l_litigation_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'LITIGATION_ID');

     update IEX_LITIGATIONS
     set SERVICE_HOLD_APPROVED_FLAG = 'N'
     where litigation_id = l_litigation_id;
  ELSIF l_del_type = 'Writeoff' THEN
     l_writeoff_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'WRITEOFF_ID');

     update IEX_WRITEOFFS
     set SERVICE_HOLD_APPROVED_FLAG = 'N'
     where writeoff_id = l_writeoff_id;
  ELSIF l_del_type = 'Bankruptcy' THEN
     l_bankruptcy_id := wf_engine.GetItemAttrNumber(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'BANKRUPTCY_ID');

     update IEX_BANKRUPTCIES
     set SERVICE_HOLD_APPROVED_FLAG = 'Y'
     where bankruptcy_id = l_bankruptcy_id;
  ELSE
     null;
  END IF;

  result := 'COMPLETE';

EXCEPTION
    WHEN l_API_ERROR then
      	WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('IEX_WF_DEL_REQ_SERVICE_PUB', 'Reject_status',
		      itemtype, itemkey, actid, funcmode);
      RAISE;

END update_rejection_status;


procedure select_type(
            itemtype            IN VARCHAR2,
            itemkey             IN VARCHAR2,
            actid	              IN NUMBER,
            funcmode            IN VARCHAR2,
            result              OUT NOCOPY VARCHAR2
) is
  l_responder           varchar2(100);
  l_del_type            varchar2(100);
  l_delinquency_id			number(30);
  l_repossession_id			number(30);
  l_litigation_id			  number(30);
  l_writeoff_id	    		number(30);
  l_bankruptcy_id       number(30);
  l_api_name     				VARCHAR2(100) := 'select type';
  l_errmsg_name					VARCHAR2(30);
  L_API_ERROR						EXCEPTION;

BEGIN

  IF l_del_type = 'Delinquency' THEN
     update IEX_DELINQUENCIES_ALL
     set SERVICE_HOLD_APPROVED_FLAG = 'N'
     where delinquency_id = TO_NUMBER(substr(itemkey, 3));
  ELSIF l_del_type = 'Repossession' THEN
     update IEX_REPOSSESSIONS
     set SERVICE_HOLD_APPROVED_FLAG = 'N'
     where repossession_id = TO_NUMBER(substr(itemkey, 3));
  ELSIF l_del_type = 'Litigation' THEN
     update IEX_LITIGATIONS
     set SERVICE_HOLD_APPROVED_FLAG = 'N'
     where litigation_id = TO_NUMBER(substr(itemkey, 3));
  ELSIF l_del_type = 'Writeoff' THEN
     update IEX_WRITEOFFS
     set SERVICE_HOLD_APPROVED_FLAG = 'N'
     where writeoff_id = TO_NUMBER(substr(itemkey, 3));
  ELSIF l_del_type = 'Bankruptcy' THEN
     update IEX_BANKRUPTCIES
     set SERVICE_HOLD_APPROVED_FLAG = 'Y'
     where bankruptcy_id = TO_NUMBER(substr(itemkey, 4));
  ELSE
     null;
  END IF;

  result := 'COMPLETE';

EXCEPTION
    WHEN l_API_ERROR then
      	WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('IEX_WF_DEL_REQ_SERVICE_PUB', 'Select Type',
		      itemtype, itemkey, actid, funcmode);
      RAISE;
END select_type;

END IEX_WF_DEL_REQ_SERVICE_PUB;

/
