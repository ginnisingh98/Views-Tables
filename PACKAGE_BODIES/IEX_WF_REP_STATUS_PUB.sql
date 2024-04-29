--------------------------------------------------------
--  DDL for Package Body IEX_WF_REP_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WF_REP_STATUS_PUB" AS
/* $Header: iexwfreb.pls 115.1 2002/03/01 09:43:41 pkm ship     $ */
/*
 * This procedure needs to be called with an itemtype and workflow process
 * which'll launch workflow.
 * This procedure is called to workflow to notify a Third Party for repossession
*/

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_WF_REP_STATUS_PUB';

PROCEDURE start_workflow
(
            p_api_version     	IN NUMBER := 1.0,
            p_init_msg_list    	IN VARCHAR2 := FND_API.G_FALSE,
            p_commit         	  IN VARCHAR2 := FND_API.G_FALSE,
            p_delinquency_id    IN NUMBER,
	          p_repossession_id 	IN NUMBER,
            p_third_party_id    IN NUMBER,
            p_third_party_name  IN NUMBER,
            p_status_yn         IN NUMBER,
            x_return_status   	OUT VARCHAR2,
            x_msg_count      	  OUT NUMBER,
            x_msg_data      	  OUT   VARCHAR2
)
IS
           l_result             VARCHAR2(10);
           itemtype             VARCHAR2(10) ;
           itemkey       	      VARCHAR2(30);
           workflowprocess     	VARCHAR2(30);

           l_error_msg     	    VARCHAR2(2000);
           l_return_status     	VARCHAR2(20);
           l_msg_count     	    NUMBER;
           l_msg_data           VARCHAR2(2000);
           l_api_name           VARCHAR2(100) := 'START_WORKFLOW';
           l_api_version_number CONSTANT NUMBER   := 1.0;
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

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    itemtype := 'IEXDELRE';
    workflowprocess := 'REP_NOTE';

    itemkey := TO_CHAR(p_repossession_id);

    wf_engine.createprocess  (  itemtype => itemtype,
              itemkey  => itemkey,
              process  => workflowprocess);

    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'REPOSSESSION_ID',
                avalue   =>   to_number(itemkey));

    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'DELINQUENCY_ID',
                avalue   =>   p_delinquency_id);

    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'THIRD_PARTY_ID',
                avalue   =>   p_third_party_id);

    wf_engine.setitemattrnumber(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'THIRD_PARTY_NAME',
                avalue   =>   p_third_party_name);

    wf_engine.setitemattrtext(  itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'STATUS_YN',
                avalue   =>   p_status_yn);

    wf_engine.startprocess(    itemtype =>   itemtype,
                itemkey  =>   itemkey);
--DBMS_OUTPUT.PUT_LINE('START PROCESS');

    wf_engine.ItemStatus(  itemtype =>   ItemType,
                           itemkey   =>  ItemKey,
                           status   =>   l_return_status,
                           result   =>   l_result);

    if (l_return_status = 'COMPLETE') THEN
       x_return_status := 'S';
       commit;
    else
       x_return_status := 'F';
    end if;
--DBMS_OUTPUT.PUT_LINE('GET ITEM STATUS = ' || l_return_status);
--DBMS_OUTPUT.PUT_LINE('GET ITEM result = ' || l_result);

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: ' || l_api_name || ' end');
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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

----------- procedure update_approval_status  -----------------------------
PROCEDURE select_notice(itemtype  	IN   varchar2,
                        itemkey     IN   varchar2,
                        actid       IN   number,
                        funcmode    IN   varchar2,
                        result      OUT  varchar2) is

  l_responder           VARCHAR2(100);
  l_text_value          VARCHAR2(2000);
  l_status              VARCHAR2(1);
  l_repossession_id     NUMBER;
  l_delinquency_id      NUMBER;
  l_api_name     				VARCHAR2(100) := 'select_notice';
  l_errmsg_name					VARCHAR2(30);
  L_API_ERROR						EXCEPTION;

BEGIN

  if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

  l_repossession_id := wf_engine.GetItemAttrText(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'REPOSSESSION_ID');


  l_delinquency_id := wf_engine.GetItemAttrText(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'DELINQUENCY_ID');

  l_status := wf_engine.GetItemAttrText(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'STATUS_YN');

  IF l_status = 'Y' THEN
     result := 'COMPLETE:'||'Y';
  ELSE
     result := 'COMPLETE:'||'N';
  END IF;

EXCEPTION
  	WHEN L_API_ERROR then
      		WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('IEX_WF_REP_STATUS_PUB', 'Select Notice',
		      itemtype, itemkey, actid, funcmode);
      RAISE;
END select_notice;



END IEX_WF_REP_STATUS_PUB;

/
