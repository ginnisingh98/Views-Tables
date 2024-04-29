--------------------------------------------------------
--  DDL for Package Body IEX_WF_NEW_DEL_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WF_NEW_DEL_STATUS_PUB" AS
/* $Header: iexwfdwb.pls 120.7.12010000.1 2008/07/29 10:13:42 appldev ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_WF_NEW_DEL_STATUS_PUB';

PG_DEBUG NUMBER(2); -- fix a bug 3975142  := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

PROCEDURE invoke_new_del_status_wf
(
      p_api_version           IN NUMBER := 1.0,
      p_init_msg_list         IN VARCHAR2, -- fix a bug 3975142  := FND_API.G_FALSE,
      p_commit                IN VARCHAR2, -- fix a bug 3975142  := FND_API.G_FALSE,
      p_delinquency_id        IN NUMBER,
      p_object_id             IN NUMBER,
      p_object_type           IN VARCHAR2,
      p_user_id               IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
)
IS
      l_parameter_list        wf_parameter_list_t;
      l_event_name            varchar2(240); -- fix a bug 3975142  := 'oracle.apps.iex.delstatus.create';
      l_result       	      VARCHAR2(10);
      itemtype                VARCHAR2(30);
      itemkey                 VARCHAR2(1000);
      l_object_type           varchar2(30);
      workflowprocess         VARCHAR2(30);

      l_error_msg     		 VARCHAR2(2000);
      l_return_status  		 VARCHAR2(20);
      l_msg_count     		 NUMBER;
      l_msg_data     			 VARCHAR2(2000);
      l_api_name     			 VARCHAR2(100); -- fix a bug 3975142  := 'invoke_new_del_status_wf';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_api_version_number2 CONSTANT NUMBER := 2.0;

      l_action_type         varchar2(7); -- fix a bug 3975142  := 'created';
      l_manager_id          number;
      l_manager_name        varchar2(30);

      CURSOR c_get_manager(p_user_id NUMBER) IS
        SELECT b.user_id, b.user_name
          FROM JTF_RS_RESOURCE_EXTNS a
              ,JTF_RS_RESOURCE_EXTNS b
          WHERE b.source_id = a.source_mgr_id
            AND a.user_id = p_user_id;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT invoke_new_del_status_wf;

    iex_debug_pub.logmessage('IEX- Start Invoking Creating New Delinquency Workflow');

    --PG_DEBUG  := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
    l_event_name   := 'oracle.apps.iex.delstatus.create';
    l_api_name     := 'invoke_new_del_status_wf';
    l_action_type  := 'created';

    iex_debug_pub.logmessage('IEX-1 Start Invoking  and object_type'||p_object_type);
    iex_debug_pub.logmessage('l_api_version_number..'||l_api_version_number||'p_api_version..'||p_api_version);
    -- Standard call to check for call compatibility.

    if p_object_type = 'Bankruptcy' then
       IF NOT FND_API.Compatible_API_Call ( l_api_version_number2,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME)
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    else
       IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME)
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    end if;


    iex_debug_pub.logmessage('IEX-2 Start Invoking Creating New Delinquency Workflow');
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
          FND_MSG_PUB.initialize;
    END IF;



    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    iex_debug_pub.logmessage('IEX- Before getting item key information....');

    SELECT TO_CHAR(IEX_DEL_WF_S.NEXTVAL) INTO itemkey FROM dual;

    itemkey := 'NEWST'||TO_CHAR(p_delinquency_id)||itemkey;

    iex_debug_pub.logmessage('IEX- Before getting manager information....');

    begin
        open c_get_manager(p_user_id);
        Fetch c_get_manager Into l_manager_id, l_manager_name;
        if c_get_manager%NOTFOUND Then
           l_manager_id := null;
           l_manager_name := null;
        end if;
        Close c_get_manager;
    exception
        When others then
             l_manager_id := null;
             l_manager_name := null;
    end;

    iex_debug_pub.logmessage('IEX- Manager Name ....'||l_manager_name);
    iex_debug_pub.logmessage('IEX- Manager ID ....'||l_manager_id);
    iex_debug_pub.logmessage('IEX- Object ID ....'||p_object_id);

    if p_object_type = 'CRepossession' then
       wf_event.AddParameterToList('CONTRACT_ID', p_delinquency_id,l_parameter_list);
       l_object_type := 'Repossession';
    elsif p_object_type = 'CWriteoff' then
       wf_event.AddParameterToList('CONTRACT_ID', p_delinquency_id,l_parameter_list);
       l_object_type := 'Writeoff';
    elsif p_object_type = 'CLitigation' then
       wf_event.AddParameterToList('CONTRACT_ID', p_delinquency_id,l_parameter_list);
    elsif p_object_type = 'Bankruptcy' then
       l_object_type := 'Bankruptcy';
       --wf_event.AddParameterToList('BAKRUPTCY_ID', p_object_id,l_parameter_list);
    else
       wf_event.AddParameterToList('DELINQUENCY_ID', p_delinquency_id,l_parameter_list);
       l_object_type := p_object_type;
    end if;

    wf_event.AddParameterToList('MANAGER_ID',l_manager_id,l_parameter_list);
    wf_event.AddParameterToList('MANAGER_NAME',l_manager_name,l_parameter_list);
    wf_event.AddParameterToList('TYPE_ID',p_object_id,l_parameter_list);
    wf_event.AddParameterToList('SUB_DEL_TYPE',l_object_type,l_parameter_list);
    wf_event.AddParameterToList('ACTION_TYPE',l_action_type,l_parameter_list);

    iex_debug_pub.logmessage('IEX- Starting Raising Workflow   ....');

    wf_event.raise( p_event_name  => l_event_name
                   ,p_event_key   => itemkey
                   ,p_parameters  => l_parameter_list);

    iex_debug_pub.logmessage('IEX- Ending Raising Workflow and before Commit  ....');

    COMMIT ;
    l_parameter_list.DELETE;


    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

--Start bug 6740370 gnramasa 11th Jan 08
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO invoke_new_del_status_wf;
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO invoke_new_del_status_wf;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
         ROLLBACK TO invoke_new_del_status_wf;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
	 END IF;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
--End bug 6740370 gnramasa 11th Jan 08
----------------------------------
END invoke_new_del_status_wf;

PROCEDURE invoke_upd_del_status_wf
(
      p_api_version           IN NUMBER := 1.0,
      p_init_msg_list         IN VARCHAR2, -- fix a bug 3975142  := FND_API.G_FALSE,
      p_commit                IN VARCHAR2, -- fix a bug 3975142  := FND_API.G_FALSE,
      p_delinquency_id        IN NUMBER,
      p_object_id             IN NUMBER,
      p_object_type           IN VARCHAR2,
      p_user_id               IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
)
IS
      l_parameter_list        wf_parameter_list_t;
      l_event_name            varchar2(240); -- fix a bug 3975142  := 'oracle.apps.iex.delstatus.update';
      l_result       	      VARCHAR2(10);
      itemtype                VARCHAR2(30);
      itemkey                 VARCHAR2(1000);
      l_object_type           varchar2(30);
      workflowprocess         VARCHAR2(30);

      l_error_msg     		 VARCHAR2(2000);
      l_return_status  		 VARCHAR2(20);
      l_msg_count     		 NUMBER;
      l_msg_data     			 VARCHAR2(2000);
      l_api_name     			 VARCHAR2(100); -- fix a bug 3975142  := 'invoke_upd_del_status_wf';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_api_version_number2 CONSTANT NUMBER := 2.0;

      l_action_type         varchar2(7); -- fix a bug 3975142  := 'updated';
      l_manager_id          number;
      l_manager_name        varchar2(30);

      CURSOR c_get_manager(p_user_id NUMBER) IS
        SELECT b.user_id, b.user_name
          FROM JTF_RS_RESOURCE_EXTNS a
              ,JTF_RS_RESOURCE_EXTNS b
          WHERE b.source_id = a.source_mgr_id
            AND a.user_id = p_user_id;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT invoke_new_del_status_wf;

    PG_DEBUG  := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
    l_event_name   := 'oracle.apps.iex.delstatus.update';
    l_api_name     := 'invoke_upd_del_status_wf';
    l_action_type  := 'updated';


    -- Standard call to check for call compatibility.
    if p_object_type = 'Bankruptcy' then
       IF NOT FND_API.Compatible_API_Call ( l_api_version_number2,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME)
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    else
       IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME)
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    end if;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
          FND_MSG_PUB.initialize;
    END IF;



    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT TO_CHAR(IEX_DEL_WF_S.NEXTVAL) INTO itemkey FROM dual;

    itemkey := 'NEWST'||TO_CHAR(p_delinquency_id)||itemkey;

    begin
        open c_get_manager(p_user_id);
        Fetch c_get_manager Into l_manager_id, l_manager_name;
        if c_get_manager%NOTFOUND Then
           l_manager_id := null;
           l_manager_name := null;
        end if;
        Close c_get_manager;
    exception
        When others then
             l_manager_id := null;
             l_manager_name := null;
    end;

    if p_object_type = 'CRepossession' then
       wf_event.AddParameterToList('CONTRACT_ID', p_delinquency_id,l_parameter_list);
       l_object_type := 'Repossession';
    elsif p_object_type = 'CWriteoff' then
       wf_event.AddParameterToList('CONTRACT_ID', p_delinquency_id,l_parameter_list);
       l_object_type := 'Writeoff';
    elsif p_object_type = 'CLitigation' then
       wf_event.AddParameterToList('CONTRACT_ID', p_delinquency_id,l_parameter_list);
       l_object_type := 'Litigation';
    else
       wf_event.AddParameterToList('DELINQUENCY_ID', p_delinquency_id,l_parameter_list);
       l_object_type := p_object_type;
    end if;

    wf_event.AddParameterToList('MANAGER_ID',l_manager_id,l_parameter_list);
    wf_event.AddParameterToList('MANAGER_NAME',l_manager_name,l_parameter_list);
    wf_event.AddParameterToList('TYPE_ID',p_object_id,l_parameter_list);
    wf_event.AddParameterToList('SUB_DEL_TYPE',l_object_type,l_parameter_list);
    wf_event.AddParameterToList('ACTION_TYPE',l_action_type,l_parameter_list);



    wf_event.raise( p_event_name  => l_event_name
                   ,p_event_key   => itemkey
                   ,p_parameters  => l_parameter_list);

      COMMIT ;
      l_parameter_list.DELETE;


    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

--Start bug 6740370 gnramasa 11th Jan 08
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO invoke_new_del_status_wf;
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO invoke_new_del_status_wf;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
         ROLLBACK TO invoke_new_del_status_wf;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
	 END IF;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
--End bug 6740370 gnramasa 11th Jan 08
----------------------------------
END invoke_upd_del_status_wf;


END IEX_WF_NEW_DEL_STATUS_PUB;

/
