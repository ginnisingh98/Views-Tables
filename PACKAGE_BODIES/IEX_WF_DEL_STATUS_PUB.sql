--------------------------------------------------------
--  DDL for Package Body IEX_WF_DEL_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WF_DEL_STATUS_PUB" AS
/* $Header: iexwfdub.pls 120.0 2004/01/24 03:31:19 appldev noship $ */
/*
 * This procedure needs to be called with an itemtype and workflow process
 * which'll launch workflow.
*/

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_DEL_STATUS_WF_PUB';

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE start_workflow
(
            p_api_version     IN NUMBER := 1.0,
            p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
            p_commit          IN VARCHAR2 := FND_API.G_FALSE,
            p_delinquency_id  IN NUMBER,
            p_repossession_id IN NUMBER,
            p_litigation_id   IN NUMBER,
            p_writeoff_id     IN NUMBER,
            p_requester_id    IN NUMBER,
            p_requester_name  IN VARCHAR2,
            p_approver_id     IN NUMBER,
            p_approver_name   IN VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2)
IS
           l_result       		VARCHAR2(10);
           itemtype       		VARCHAR2(10);
           itemkey              VARCHAR2(30);
           workflowprocess      VARCHAR2(30);

           l_error_msg     		VARCHAR2(2000);
           l_return_status      VARCHAR2(20);
           l_msg_count     		NUMBER;
           l_msg_data     		VARCHAR2(2000);
           l_api_name     		VARCHAR2(100) := 'START_WORKFLOW';
           l_api_version_number CONSTANT NUMBER   := 1.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT START_WORKFLOW;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Public API: ' || l_api_name || ' start');
        IEX_DEBUG_PUB.logMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    itemtype := 'IEXDELST';
    workflowprocess := 'DEL_STATUS';

    IF p_delinquency_id IS NULL THEN
       null;
    ELSIF p_repossession_id IS NOT NULL THEN
       itemkey := 'REP'||p_repossession_id;
    ELSIF p_litigation_id IS NOT NULL THEN
       itemkey := 'LIT'||p_litigation_id;
    ELSIF p_writeoff_id IS NOT NULL THEN
       itemkey := 'WRI'||p_writeoff_id;
    END IF;

    wf_engine.createprocess  (itemtype => itemtype,
                              itemkey  => itemkey,
                              process  => workflowprocess);

    wf_engine.setitemattrnumber(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'DELINQUENCY_ID',
                                avalue   => P_DELINQUENCY_ID);

    wf_engine.setitemattrnumber(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'WRITEOFF_ID',
                                avalue   => P_WRITEOFF_ID);

    wf_engine.setitemattrtext(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'REPOSSESSION_ID',
                              avalue   => P_REPOSSESSION_ID);

    wf_engine.setitemattrtext(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'LITIGATION_ID',
                              avalue   => P_LITIGATION_ID);

    wf_engine.startprocess(itemtype => itemtype,
                           itemkey  => itemkey);

    wf_engine.ItemStatus(itemtype => ItemType,
                         itemkey  => ItemKey,
                         status   => l_return_status,
                         result   => l_result);

    if (l_return_status = 'COMPLETE') THEN
       x_return_status := 'S';
       commit;
    else
       x_return_status := 'E';
    end if;

      -- Debug Message
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'PUB: ' || l_api_name || ' end');
        IEX_DEBUG_PUB.logMessage(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'|| TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

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
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
----------------------------------
END start_workflow;

----------- procedure update_approval_status  -----------------------------
PROCEDURE update_approval_status(itemtype  IN  varchar2,
                                 itemkey   IN  varchar2,
                                 actid     IN  number,
                                 funcmode  IN  varchar2,
                                 result    OUT NOCOPY  varchar2) is

  l_responder           varchar2(100);
  l_text_value          varchar2(2000);
  l_delinquency_id      number(30);
  l_writeoff_id         number(30);
  l_litigation_id       number(30);
  l_repossession_id     number(30);
  l_api_name            VARCHAR2(100) := 'update_approval_status';
  l_errmsg_name         VARCHAR2(30);
  L_API_ERROR           EXCEPTION;

BEGIN

  if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

  l_writeoff_id := to_number(substr(itemkey, 2));

  IF to_number(substr(itemkey, 0, 2)) = 'WRI' THEN
     update IEX_WRITEOFFS
     set SUGGESTION_APPROVED_FLAG = 'Y',
         WRITEOFF_DATE = sysdate
     where WRITEOFF_ID = to_number(substr(itemkey, 2));
  ELSIF to_number(substr(itemkey, 0, 2)) = 'REP' THEN
     update IEX_REPOSSESSIONS
     set SUGGESTION_APPROVED_FLAG = 'Y',
         REPOSSESSION_DATE = sysdate
     where REPOSSESSION_ID = to_number(substr(itemkey, 2));
  ELSIF to_number(substr(itemkey, 0, 2)) = 'LIT' THEN
     update IEX_LITIGATIONS
     set SUGGESTION_APPROVED_FLAG = 'Y'
     where LITIGATION_ID = to_number(substr(itemkey, 2));
  END IF;

  COMMIT;

  result := 'COMPLETE';

EXCEPTION
  	WHEN L_API_ERROR then
      		WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('IEX_DEL_REQ_SERVICE_WF_PUB', 'Approval_status',
		      itemtype, itemkey, actid, funcmode);
      RAISE;
END update_approval_status;

----------- procedure update_rejection_status  -----------------------------
procedure update_rejection_status(
        itemtype  IN  varchar2,
        itemkey   IN  varchar2,
        actid     IN  number,
        funcmode  IN  varchar2,
        result    OUT NOCOPY varchar2) is

  l_responder           varchar2(100);
  l_text_value          varchar2(2000);
  l_writeoff_id         number(30);
  l_api_name            VARCHAR2(100) := 'update_rejection_status';
  l_errmsg_name         VARCHAR2(30);
  L_API_ERROR           EXCEPTION;

BEGIN

  if funcmode <> 'RUN' then
    result := wf_engine.eng_null;
    return;
  end if;

  l_writeoff_id := to_number(substr(itemkey, 2));

  IF to_number(substr(itemkey, 0, 2)) = 'WRI' THEN
     update IEX_WRITEOFFS
     set SUGGESTION_APPROVED_FLAG = 'N',
         WRITEOFF_DATE = sysdate
     where WRITEOFF_ID = to_number(substr(itemkey, 2));
  ELSIF to_number(substr(itemkey, 0, 2)) = 'REP' THEN
     update IEX_REPOSSESSIONS
     set SUGGESTION_APPROVED_FLAG = 'N',
         REPOSSESSION_DATE = sysdate
     where REPOSSESSION_ID = to_number(substr(itemkey, 2));
  ELSIF to_number(substr(itemkey, 0, 2)) = 'LIT' THEN
     update IEX_LITIGATIONS
     set SUGGESTION_APPROVED_FLAG = 'N'
     where LITIGATION_ID = to_number(substr(itemkey, 2));
  END IF;

  COMMIT;

  result := 'COMPLETE';

EXCEPTION
  	WHEN L_API_ERROR then
      		WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('IEX_DEL_REQ_SERVICE_WF_PUB', 'Approval_status',
		      itemtype, itemkey, actid, funcmode);
      RAISE;
END update_rejection_status;

END IEX_WF_DEL_STATUS_PUB;

/
