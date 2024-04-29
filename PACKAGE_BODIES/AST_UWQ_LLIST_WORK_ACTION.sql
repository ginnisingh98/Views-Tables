--------------------------------------------------------
--  DDL for Package Body AST_UWQ_LLIST_WORK_ACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_UWQ_LLIST_WORK_ACTION" AS
/* $Header: astulacb.pls 115.29 2004/03/26 12:14:21 sumishar ship $ */

  G_Debug  BOOLEAN;

  l_called_node       VARCHAR2(10) := 'LLIST';

  l_name              VARCHAR2 (500);
  l_value             VARCHAR2 (4000);
  l_type              VARCHAR2 (500);
  l_data_set_type     VARCHAR2 (50);
  l_data_set_id       NUMBER;
  l_prev_data_set_id  NUMBER;

  l_temp_lead_id      NUMBER;

  PROCEDURE Log_Mesg
    (p_message IN VARCHAR2,
     p_date  IN  VARCHAR2) IS
  BEGIN
    IF G_Debug THEN
      AST_DEBUG_PUB.LogMessage(debug_msg  => p_message,
                               print_date => p_date);
    END IF;
  END; -- End procedure Log_Mesg

  PROCEDURE LLIST_WORK_NODE_REFRESH
    ( p_action_key       IN  VARCHAR2,
      p_lead_id          IN  NUMBER,
      p_sales_lead_id    IN  NUMBER,
      x_uwq_actions_list OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST
    ) IS
    l_uwq_actions_list      IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_REC_LIST;
    l_uwq_action_data_list  IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_DATA_REC_LIST;
    l_action_data           VARCHAR2(4000);
    l_launch_opp_lead	   VARCHAR2(200);
  BEGIN
    l_uwq_actions_list(1).uwq_action_key := 'UWQ_WORK_DETAILS_REFRESH';
    l_uwq_actions_list(1).action_data    := '';
    l_uwq_actions_list(1).dialog_style   := 1;
    l_uwq_actions_list(1).message        := '';

    IF p_lead_id IS NOT NULL OR
       p_sales_lead_id IS NOT NULL THEN
      Log_Mesg('Inside Lauch App Settings');
      Log_Mesg('Lead Id = '||p_lead_id);
      Log_Mesg('Sales Lead Id = '||p_sales_lead_id);
      l_uwq_action_data_list(1).name  := 'ACTION_NAME';
      l_uwq_action_data_list(1).type  := 'VARCHAR2';
      IF p_action_key = 'LEAD_CONVERT_LEAD_TO_OPP' THEN
	   IF p_lead_id IS NOT NULL THEN
          l_uwq_action_data_list(1).value := 'ASTOPCNT';
	   ELSIF p_sales_lead_id IS NOT NULL THEN
          l_uwq_action_data_list(1).value := 'ASTSLTOP';
	   END IF;
      END IF;

      l_uwq_action_data_list(2).name  := 'ACTION_TYPE';
      l_uwq_action_data_list(2).value := 1;
      l_uwq_action_data_list(2).type  := 'NUMBER';

      l_uwq_action_data_list(3).name  := 'ACTION_PARAMS';
      l_uwq_action_data_list(3).type  := 'VARCHAR2';
      IF p_action_key = 'LEAD_CONVERT_LEAD_TO_OPP' THEN
	   IF p_lead_id IS NOT NULL THEN
          l_uwq_action_data_list(3).value := 'lead_id='||p_lead_id;
	   ELSIF p_sales_lead_id IS NOT NULL THEN
          l_uwq_action_data_list(3).value := 'sales_lead_id='||p_sales_lead_id;
	   END IF;
      END IF;

      IEU_UWQ_WORK_PANEL_PUB.SET_UWQ_ACTION_DATA(l_uwq_action_data_list, l_action_data);

      l_uwq_actions_list(2).uwq_action_key := 'UWQ_LAUNCH_APP';
      l_uwq_actions_list(2).action_data    := l_action_data;
      IF NVL(FND_PROFILE.Value('AST_LAUNCH_OPP_LEAD'), 'N') = 'Y' THEN
        l_uwq_actions_list(2).dialog_style   := 1;
      ELSE
        l_uwq_actions_list(2).dialog_style   := 3;
      END IF;
      IF p_action_key = 'LEAD_CONVERT_LEAD_TO_OPP' THEN
	   IF p_lead_id IS NOT NULL THEN
	     fnd_message.set_name('AST','AST_UWQ_LAUNCH_OPP_CENTER');
	     l_launch_opp_lead :=   fnd_message.get;
          l_uwq_actions_list(2).message        := l_launch_opp_lead;
	   ELSIF p_sales_lead_id IS NOT NULL THEN
   		--From now on, Lead Linking screen will be launched without asking for user's consent.
		--Bug 2774004 .

--	     fnd_message.set_name('AST','AST_UWQ_LAUNCH_LEAD_LINK');
--	     l_launch_opp_lead :=   fnd_message.get;
--          l_uwq_actions_list(2).message        := l_launch_opp_lead;
          l_uwq_actions_list(2).dialog_style   := 1;
	   END IF;
      END IF;
      Log_Mesg('All Lauch App Settings done.');
    END IF;

    IEU_UWQ_WORK_PANEL_PUB.SET_UWQ_ACTIONS(l_uwq_actions_list, x_uwq_actions_list);
  END; -- End procedure LLIST_WORK_NODE_REFRESH

  PROCEDURE LLIST_WORK_ITEM_ACTION
    ( p_resource_id        IN  NUMBER,
      p_language           IN  VARCHAR2,
      p_source_lang        IN  VARCHAR2,
      p_action_key         IN  VARCHAR2,
      p_action_input_data  IN  SYSTEM.ACTION_INPUT_DATA_NST,
      x_uwq_actions_list   OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count          OUT NOCOPY NUMBER,
      x_msg_data           OUT NOCOPY VARCHAR2,
      x_return_status      OUT NOCOPY VARCHAR2
    ) IS

    l_uwq_action_data_list   IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_DATA_REC_LIST;
    x_action_data            VARCHAR2 (4000);

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
  BEGIN

    IF FND_PROFILE.Value('AST_DEBUG') = 'Y' THEN
	 G_Debug := TRUE;
    ELSE
	 G_Debug := FALSE;
    END IF;

    Log_Mesg('Start Log', 'Y');
    Log_Mesg('Action Key: '||p_action_key);
    IF p_action_key = 'LEAD_NEW_TASK' THEN
      Log_Mesg('Calling New Task Action Procedure');
      LLIST_NEW_TASK
        ( p_action_key       => p_action_key,
          p_resource_id      => p_resource_id,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
        );
    ELSIF p_action_key = 'LEAD_UPDATE_LEAD' THEN
      LLIST_UPDATE_LEAD
        ( p_action_key       => p_action_key,
          p_resource_id      => p_resource_id,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
        );
    ELSIF p_action_key = 'LEAD_REASSIGN_LEAD' THEN
      LLIST_REASSIGN_LEAD
        ( p_action_key       => p_action_key,
          p_resource_id      => p_resource_id,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
        );
    ELSIF p_action_key = 'LEAD_CONVERT_LEAD_TO_OPP' THEN
      LLIST_LEAD_TO_OPPORTUNITY
        ( p_action_key       => p_action_key,
          p_resource_id      => p_resource_id,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
        );
    ELSIF p_action_key = 'LEAD_CLOSE_LEAD' THEN
      LLIST_UPDATE_LEAD
        ( p_action_key       => p_action_key,
          p_resource_id      => p_resource_id,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
        );
    ELSIF p_action_key = 'LEAD_CREATE_NOTE' THEN
      Log_Mesg('Calling Create Note Action Procedure');
      LLIST_CREATE_NOTE
        ( p_action_key       => p_action_key,
          p_resource_id      => p_resource_id,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
        );
    END IF;

    x_return_status := l_return_status;
    Log_Mesg('End Log', 'Y');
  EXCEPTION WHEN OTHERS THEN
    x_return_status := l_return_status;
    Log_Mesg('End Log in Exception', 'Y');
  END; -- End procedure LLIST_WORK_ITEM_ACTION

  PROCEDURE LLIST_NEW_TASK
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data    IN  SYSTEM.ACTION_INPUT_DATA_NST,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    ) IS

    l_creation_date             DATE   := SYSDATE;
    l_last_update_date          DATE   := SYSDATE;
    l_last_updated_by           NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_created_by                NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_last_update_login         NUMBER := FND_PROFILE.Value('LOGIN_ID'); -- REVIEW

    l_task_name                 VARCHAR2(80);   --P
    l_task_type_id              NUMBER;   --P
    l_description               VARCHAR2(4000);   --P
    l_owner_id                  NUMBER;   --W RESOURCE_ID Resource_Id  --REVIEW
    l_customer_id               NUMBER;   --W
    l_contact_id                NUMBER;   --W
    l_date_type                 VARCHAR2(30);  --P --REVIEW
    l_start_date                DATE;   --P
    l_end_date                  DATE;   --P
    l_source_object_type_code   VARCHAR2(60);
    l_source_object_id          NUMBER;   --P (Customer_party_id)
    l_source_object_name        VARCHAR2(80);   --P (Customer_Name)
    l_phone                     VARCHAR2(30);   --P
    l_phone_id                  NUMBER;   --P   --ADD TO VIEW
    l_address_id                NUMBER; --W
    l_duration                  NUMBER;
    l_duration_uom              VARCHAR2(3);
    l_status_code               VARCHAR2(30);

    l_notes                     VARCHAR2(2000);
    l_note_type                 VARCHAR2(30);
    l_note_status               VARCHAR2(1);
    l_party_id                  NUMBER;

    l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_task_id                   NUMBER;
    l_jtf_note_id               NUMBER;
    l_err_mesg                  VARCHAR2(500);
  BEGIN
    Log_Mesg('Inside New Task');
    l_data_set_id      := NULL;
    l_prev_data_set_id := NULL;
    l_owner_id         := p_resource_id;
    Log_Mesg('Owner ID: '||TO_CHAR(l_owner_id));

    Log_Mesg('Looping to get Param Item Data only.');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;

      IF l_data_set_type = 'ACTION_PARAM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Action Param Data Name: '||l_name||' ('||l_value||')');
	    IF l_name = 'TASK_NAME' THEN
	      l_task_name := l_value;
	    ELSIF l_name = 'TASK_TYPE_ID' THEN
          l_task_type_id  := TO_NUMBER(l_value);
	    ELSIF l_name = 'TASK_DESC' THEN
          l_description   := l_value;
	    ELSIF l_name = 'DATE_TYPE' THEN
          l_date_type := l_value;
	    ELSIF l_name = 'START_DATE' THEN
          l_start_date := TO_DATE(l_value, 'DD-MM-YYYY HH24:MI:SS');
	    ELSIF l_name = 'END_DATE' THEN
          l_end_date := TO_DATE(l_value, 'DD-MM-YYYY HH24:MI:SS');
	    ELSIF l_name = 'NEW_NOTE' THEN
          --Bug # 3525736
	    BEGIN
		l_notes := l_value;
	    EXCEPTION
		WHEN VALUE_ERROR THEN
			l_return_status := 'E';
			x_return_status := l_return_status;
                        FND_MESSAGE.Set_Name('AST', 'AST_NOTE_LENGTH_ERROR');
		        FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
	    END;
        END IF;

        Log_Mesg('Start parameter validation');
        IF l_name = 'END_DATE' AND
           l_end_date < l_start_date THEN
          --l_err_mesg := 'End date must be greater than start date.';
          l_return_status := 'E';
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          FND_MESSAGE.Set_Name('AST', 'AST_OPP_TASK_DATE');
          --FND_MESSAGE.Set_Token('TEXT', l_err_mesg, FALSE);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        Log_Mesg('End parameter validation');
      ELSE
        EXIT;
      END IF;
    END LOOP;
    Log_Mesg('Get Parameter Data Loop Ended');

    Log_Mesg('Looping to get Work Item and Param Item Data');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;
      l_data_set_id   := p_work_action_data(i).dataSetId;

      Log_Mesg('Data Set Type: '||l_data_set_type);
	  IF l_data_set_type = 'WORK_ITEM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Work Data Name: '||l_name||' ('||l_value||')');
 	    IF l_name = 'PARTY_ID' THEN
          l_customer_id := TO_NUMBER(l_value);
	    ELSIF l_name = 'SALES_LEAD_ID' THEN
          l_source_object_id := l_value;
	    ELSIF l_name = 'LEAD_NUMBER' THEN
          l_source_object_name := l_value;
 	    ELSIF l_name = 'CONTACT_PARTY_ID' THEN
          l_contact_id := TO_NUMBER(l_value);
        -- Begin Mod. Raam on 07.12.2002
	    ELSIF l_name = 'PHONE_ID' THEN
          l_phone_id := l_value;
        -- End Mod.
        -- Begin Mod. Raam on 07.25.2002
	    ELSIF l_name = 'ADDRESS_ID' THEN
          l_address_id := l_value;
        -- End Mod.
        END IF;
      END IF;

      Log_Mesg('Contact Id: '||l_contact_id);
      l_source_object_type_code := 'LEAD';
      Log_Mesg('Object Type Code: '||l_source_object_type_code);
      Log_Mesg('Object Type id: '||l_source_object_id);
      Log_Mesg('Object Type name: '||l_source_object_name);

      IF l_prev_data_set_id <> l_data_set_id OR
         i = p_work_action_data.COUNT THEN
        Log_Mesg('Start Create Task');
        AST_UWQ_WRAPPER_PKG.CREATE_TASK
          ( p_task_name                 => l_task_name,
            p_task_type_name            => NULL,
            p_task_type_id              => l_task_type_id,
            p_description               => l_description,
            p_owner_id                  => l_owner_id,
            p_customer_id               => l_customer_id,
            p_contact_id                => l_contact_id,
            p_date_type                 => l_date_type,
            p_start_date                => l_start_date,
            p_end_date                  => l_end_date,
            p_source_object_type_code   => l_source_object_type_code,
            p_source_object_id          => l_source_object_id,
            p_source_object_name        => l_source_object_name,
            p_phone_id                  => l_phone_id,
            p_address_id                => l_address_id,
            p_duration                  => l_duration,
            p_duration_uom              => l_duration_uom,
            p_called_node               => l_called_node,
            x_return_status             => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            x_task_id                   => l_task_id
          );
        Log_Mesg('End Create Task');

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
          --x_task_id       := l_task_id;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Failed to Creat Task: ', FALSE);
--          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
          --x_task_id       := l_task_id;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Successfully Created Task: '||TO_CHAR(l_task_id), FALSE);
--          FND_MSG_PUB.ADD;
        END IF;

        Log_Mesg('Task Id: '||l_task_id);
        IF l_notes IS NOT NULL THEN
          l_source_object_type_code := 'TASK';
          l_source_object_id        := l_task_id;
          l_party_id                := l_customer_id; --REVIEW

          Log_Mesg('Start Create Note');
          AST_UWQ_WRAPPER_PKG.CREATE_NOTE
          ( p_source_object_id   => l_source_object_id,
            p_source_object_code => l_source_object_type_code,
            p_notes              => l_notes,
            p_notes_detail       => NULL,
            p_entered_by         => l_last_updated_by,
            p_entered_date       => l_last_update_date,
            p_last_update_date   => l_last_update_date,
            p_last_updated_by    => l_last_updated_by,
            p_creation_date      => l_creation_date,
            p_created_by         => l_created_by,
            p_last_update_login  => l_last_update_login,
            p_party_id           => l_party_id,
            x_jtf_note_id        => l_jtf_note_id,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data
          );
          Log_Mesg('End Create Note');

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;
--            FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--            FND_MESSAGE.Set_Token('TEXT', 'Failed to Creat Note', FALSE);
--            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            x_return_status := l_return_status;
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;
--            FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--            FND_MESSAGE.Set_Token('TEXT', 'Successfully Created Note: '||TO_CHAR(l_jtf_note_id), FALSE);
--            FND_MSG_PUB.ADD;
          END IF;
        ELSE
          Log_Mesg('User did not enter any note to create.');
        END IF;
      END IF;

      l_prev_data_set_id := l_data_set_id;
    END LOOP;
    Log_Mesg('Get Work Data Loop Ended');

    LLIST_WORK_NODE_REFRESH
      ( p_action_key       => p_action_key,
        p_lead_id          => NULL,
        p_sales_lead_id    => NULL,
        x_uwq_actions_list => x_uwq_actions_list
      );

  END; -- End procedure LLIST_NEW_TASK

  PROCEDURE LLIST_UPDATE_LEAD
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data	IN  SYSTEM.ACTION_INPUT_DATA_NST,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    ) IS

    l_last_update_date          DATE;
    l_last_updated_by           NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_created_by                NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_last_update_login         NUMBER := FND_PROFILE.Value('LOGIN_ID'); -- REVIEW

    l_admin_group_id            NUMBER; --P From GLOBAL.AST_ADMIN_GROUP_ID
    l_identity_salesforce_id    NUMBER; --P From GLOBAL.AST_RESOURCE_ID
    l_p_status_code             VARCHAR2(30); --P
    l_status_code               VARCHAR2(30); --P
    l_customer_id               NUMBER; --P
    l_contact_party_id		    NUMBER; --P
    l_admin_flag                VARCHAR2(1); --P From GLOBAL.AST_ADMIN_FLAG
    l_assign_to_salesforce_id   NUMBER; --P From GLOBAL.AST_RESOURCE_ID
    l_assign_sales_group_id     NUMBER; --P From GLOBAL.AST_MEM_GROUP_ID
    l_p_budget_status_code		VARCHAR2(30); --P
    l_budget_status_code		VARCHAR2(30); --P

    --Bug # 3491443
    l_p_description             VARCHAR2(2000); --P
    l_description               VARCHAR2(2000); --P

    l_source_promotion_id       NUMBER; --W
    l_p_lead_rank_id            NUMBER; --P
    l_lead_rank_id              NUMBER; --P
    l_p_decision_timeframe_code VARCHAR2(30); --P
    l_decision_timeframe_code   VARCHAR2(30); --P
	l_p_accept_flag				VARCHAR2(1);
	l_accept_flag				VARCHAR2(1);
	l_p_qualified_flag			VARCHAR2(1);
	l_qualified_flag			VARCHAR2(1);
    l_initiating_contact_id     NUMBER; --REVIEW
    l_phone_id                  NUMBER; --P  --ADD TO VIEW
    l_close_reason_code         VARCHAR2(30);
    l_person_id                 NUMBER;

    l_source_object_type_code   VARCHAR2(60);
    l_source_object_id          NUMBER;   -- Lead Id

    l_notes                     VARCHAR2(2000);
    l_note_type                 VARCHAR2(30);
    l_note_status               VARCHAR2(1);
    l_party_id                  NUMBER;
    l_sales_lead_id             NUMBER;

    l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_jtf_note_id               NUMBER;
  BEGIN
    Log_Mesg('Inside Update Lead');
    l_data_set_id               := NULL;
    l_prev_data_set_id          := NULL;
    l_identity_salesforce_id    := p_resource_id;

    Log_Mesg('Looping to get Param Item Data only.');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;

      IF l_data_set_type = 'ACTION_PARAM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

		Log_Mesg('Action Param Data Name: '||l_name||' ('||l_value||')');
	    IF l_name = 'ADMIN_GROUP_ID' THEN
          l_admin_group_id := TO_NUMBER(l_value);
	    ELSIF l_name = 'MEM_GROUP_ID' THEN
	      l_assign_sales_group_id := TO_NUMBER(l_value);
	    ELSIF l_name = 'ADMIN_FLAG' THEN
	      l_admin_flag := l_value;
	    ELSIF l_name = 'LEAD_NAME' THEN
	      l_description := l_value;
	      l_p_description := l_value;
	    ELSIF l_name = 'STATUS_CODE' THEN
          l_status_code := l_value;
          l_p_status_code := l_value;
	    ELSIF l_name = 'LEAD_RANK' THEN
          l_lead_rank_id   := l_value;
          l_p_lead_rank_id   := l_value;
	    ELSIF l_name = 'BUDGET_STATUS' THEN
          l_budget_status_code := l_value;
          l_p_budget_status_code := l_value;
	    ELSIF l_name = 'TIME_FRAME' THEN
          l_decision_timeframe_code := l_value;
          l_p_decision_timeframe_code := l_value;
	    ELSIF l_name = 'CLOSE_REASON' THEN
          l_close_reason_code := l_value;
	    ELSIF l_name = 'ACCEPT_FLAG' THEN
          l_accept_flag := l_value;
          l_p_accept_flag := l_value;
	    ELSIF l_name = 'QUALIFIED_FLAG' THEN
          l_qualified_flag := l_value;
          l_p_qualified_flag := l_value;
	    ELSIF l_name = 'NEW_NOTE' THEN
          --Bug # 3525736
	    BEGIN
		l_notes := l_value;
	    EXCEPTION
		WHEN VALUE_ERROR THEN
			l_return_status := 'E';
			x_return_status := l_return_status;
                        FND_MESSAGE.Set_Name('AST', 'AST_NOTE_LENGTH_ERROR');
		        FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
	    END;
	    ELSIF l_name = 'PERSON_ID' THEN
	      l_person_id := l_value;
        END IF;
      ELSE
        EXIT;
      END IF;
    END LOOP;
    Log_Mesg('Get Parameter Data Loop Ended');

    Log_Mesg('Looping to get Work Item Data only.');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).dataSetType;
      l_data_set_id   := p_work_action_data(i).dataSetID;

	  IF l_data_set_type = 'WORK_ITEM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Work Data Name: '||l_name||' ('||l_value||')');
	    IF l_name = 'SALES_LEAD_ID' THEN
          l_sales_lead_id := l_value;
	    ELSIF l_name = 'SOURCE_CODE_FOR_ID' THEN
          l_source_promotion_id := l_value; --REVIEW
 	    ELSIF l_name = 'PARTY_ID' THEN
          l_customer_id := l_value;
        ELSIF l_name = 'CONTACT_PARTY_ID' THEN
          l_initiating_contact_id := l_value;
	    ELSIF l_name = 'PHONE_ID' THEN
          l_phone_id := l_value;
	    ELSIF l_name = 'DESCRIPTION' AND
              l_p_description IS NULL THEN
          l_description := l_value;
	    ELSIF l_name = 'STATUS_CODE' AND
              l_p_status_code IS NULL THEN
          l_status_code := l_value;
	    ELSIF l_name = 'LEAD_RANK_ID' AND
              l_p_lead_rank_id IS NULL THEN
          l_lead_rank_id   := l_value;
	    ELSIF l_name = 'BUDGET_STATUS_CODE' AND
              l_p_budget_status_code IS NULL THEN
          l_budget_status_code := l_value;
	    ELSIF l_name = 'ACCEPT_FLAG' AND
              l_p_accept_flag IS NULL THEN
          l_accept_flag := l_value;
	    ELSIF l_name = 'QUALIFIED_FLAG' AND
              l_p_qualified_flag IS NULL THEN
          l_qualified_flag := l_value;
	    ELSIF l_name = 'DECISION_TIMEFRAME_CODE' AND
              l_p_decision_timeframe_code IS NULL THEN
          l_decision_timeframe_code := l_value;
        ELSIF l_name = 'ASSIGN_TO_SALESFORCE_ID' THEN
          l_assign_to_salesforce_id := l_value;
	    ELSIF l_name = 'ASSIGN_SALES_GROUP_ID' THEN
	      l_assign_sales_group_id := TO_NUMBER(l_value);
	    ELSIF l_name = 'LAST_UPDATE_DATE' THEN
		 l_last_update_date := TO_DATE(l_value, 'DD-MM-YYYY HH24:MI:SS');
        END IF;
      END IF;

      -- Begin Mod. Raam on 08.16.2002
      IF l_data_set_id <= 1 AND
         i = p_work_action_data.COUNT THEN
        IF l_p_status_code IS NULL THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('AST', 'AST_LEAD_STATUS_REQUIRED');
--          FND_MESSAGE.Set_Token('TEXT', 'Failed to Update Lead: ', FALSE);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      -- End Mod.

      IF l_prev_data_set_id <> l_data_set_id OR
         i = p_work_action_data.COUNT THEN

        Log_Mesg('Before Territory check Has_updatelead ');
        AST_ACCESS.Has_UpdateLeadAccess
        ( p_sales_lead_id   => l_sales_lead_id,
          p_admin_flag      => l_admin_flag,
          p_admin_group_id  => l_admin_group_id,
          p_person_id       => l_person_id,
          p_resource_id     => l_identity_salesforce_id,
          x_return_status	=> l_return_status,
	      x_msg_count		=> l_msg_count,
	      x_msg_data		=> l_msg_data
        );
        Log_Mesg('After Territory check ' ||l_return_status);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        Log_Mesg(l_sales_lead_id||' - '||l_status_code);
        AST_UWQ_WRAPPER_PKG.UPDATE_LEAD
   	      (
	        p_sales_lead_id			  => l_sales_lead_id,
	        p_admin_group_id		  => l_admin_group_id,
	        p_identity_salesforce_id  => l_identity_salesforce_id,
		   p_last_update_date       => l_last_update_date,
	        p_status_code		      => l_status_code,
	        p_customer_id		      => l_customer_id,
            p_admin_flag              => l_admin_flag,
            p_assign_to_salesforce_id => l_assign_to_salesforce_id,
            p_assign_sales_group_id   => l_assign_sales_group_id,
	        p_budget_status_code	  => l_budget_status_code,
	        p_description		      => l_description,
	        p_source_promotion_id	  => l_source_promotion_id,
	        p_lead_rank_id		      => l_lead_rank_id,
	        p_decision_timeframe_code => l_decision_timeframe_code,
	        p_initiating_contact_id   => l_initiating_contact_id,
	        p_phone_id		          => l_phone_id,
            p_close_reason_code		  => l_close_reason_code,
	  	    p_accept_flag			  => l_accept_flag,
	  	    p_qualified_flag		  => l_qualified_flag,
            p_called_node             => l_called_node,
	        x_return_status		      => l_return_status,
	        x_msg_count		          => l_msg_count,
	        x_msg_data		          => l_msg_data
	      );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Failed to Update Lead: ', FALSE);
--          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Successfully Updated Lead: '||TO_CHAR(l_sales_lead_id), FALSE);
--          FND_MSG_PUB.ADD;
        END IF;

        IF l_notes IS NOT NULL THEN
          l_source_object_type_code := 'LEAD';
          l_source_object_id        := l_sales_lead_id;
          l_party_id                := l_customer_id; --REVIEW

          AST_UWQ_WRAPPER_PKG.CREATE_NOTE
          ( p_source_object_id   => l_source_object_id,
            p_source_object_code => l_source_object_type_code,
            p_notes              => l_notes,
            p_notes_detail       => NULL,
            p_entered_by         => l_last_updated_by,
            p_entered_date       => sysdate,
            p_last_update_date   => sysdate,
            p_last_updated_by    => l_last_updated_by,
            p_creation_date      => sysdate,
            p_created_by         => l_created_by,
            p_last_update_login  => l_last_update_login,
            p_party_id           => l_party_id,
            x_jtf_note_id        => l_jtf_note_id,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            Log_Mesg('Note Creation Failed.');
            x_return_status := l_return_status;
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;
--            FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--            FND_MESSAGE.Set_Token('TEXT', 'Failed to Creat Note', FALSE);
--            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            x_return_status := l_return_status;
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;
--            FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--            FND_MESSAGE.Set_Token('TEXT', 'Successfully Created Note: '||TO_CHAR(l_jtf_note_id), FALSE);
--            FND_MSG_PUB.ADD;
          END IF;
        ELSE
          Log_Mesg('User did not enter any note to create.');
        END IF;
      END IF;
      l_prev_data_set_id := l_data_set_id;
    END LOOP;
    Log_Mesg('Get Work Data Loop Ended');

    LLIST_WORK_NODE_REFRESH
      ( p_action_key       => p_action_key,
        p_lead_id          => NULL,
        p_sales_lead_id    => NULL,
        x_uwq_actions_list => x_uwq_actions_list
      );

  END; -- End procedure LEAD_UPDATE_LEAD

  PROCEDURE LLIST_REASSIGN_LEAD
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data	IN  SYSTEM.ACTION_INPUT_DATA_NST,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    ) IS

    l_creation_date           DATE   := SYSDATE;
    l_last_update_date        DATE   := SYSDATE;
    l_last_updated_by         NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_created_by              NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_last_update_login       NUMBER := FND_PROFILE.Value('LOGIN_ID'); -- REVIEW

    l_admin_flag              VARCHAR2(1); --P From GLOBAL.AST_ADMIN_FLAG
    l_admin_group_id          NUMBER; --P From GLOBAL.AST_ADMIN_GROUP_ID
    l_default_group_id        NUMBER; --P
    l_person_id               NUMBER; --P
    l_customer_id             NUMBER; --P
    l_sales_lead_id           NUMBER;
    l_new_salesforce_id       NUMBER; --P
    l_new_sales_group_id      NUMBER; --P
    l_new_owner_id            NUMBER; --P
    l_resource_id             NUMBER;
    l_first_pos               NUMBER;
    l_second_pos              NUMBER;

    l_phone_id                NUMBER; --P
    l_source_object_type_code VARCHAR2(60);
    l_source_object_id        NUMBER; -- Lead Id

    l_notes                   VARCHAR2(2000);
    l_note_type               VARCHAR2(30);
    l_note_status             VARCHAR2(1);
    l_party_id                NUMBER;
    l_jtf_note_id             NUMBER;

    l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
  BEGIN
    Log_Mesg('Inside Reassign Lead');
    l_data_set_id      := NULL;
    l_prev_data_set_id := NULL;
    l_resource_id      := p_resource_id;

    Log_Mesg('Looping to get Param Item Data only.');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;

      IF l_data_set_type = 'ACTION_PARAM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

		Log_Mesg('Action Param Data Name: '||l_name||' ('||l_value||')');
	    IF l_name = 'LEAD_OWNER' THEN
          l_first_pos := INSTR(l_value, '-');
          l_second_pos := INSTR(l_value, '-', -1);
          l_new_salesforce_id := SUBSTR(l_value, 1, (l_first_pos - 1));
          l_new_sales_group_id := SUBSTR(l_value, (l_first_pos + 1), (l_second_pos - l_first_pos)-1);
          l_new_owner_id       := SUBSTR(l_value, (l_second_pos + 1));
	    ELSIF l_name = 'NEW_NOTE' THEN
          --Bug # 3525736
	    BEGIN
		l_notes := l_value;
	    EXCEPTION
		WHEN VALUE_ERROR THEN
			l_return_status := 'E';
			x_return_status := l_return_status;
                        FND_MESSAGE.Set_Name('AST', 'AST_NOTE_LENGTH_ERROR');
		        FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
	    END;
	    ELSIF l_name = 'ADMIN_GROUP_ID' THEN
          l_admin_group_id := TO_NUMBER(l_value);
	    ELSIF l_name = 'ADMIN_FLAG' THEN
	      l_admin_flag := l_value;
	    ELSIF l_name = 'DEFAULT_GROUP_ID' THEN
	      l_default_group_id := l_value;
	    ELSIF l_name = 'PERSON_ID' THEN
	      l_person_id := l_value;
        END IF;
      ELSE
        EXIT;
      END IF;
    END LOOP;
    Log_Mesg('Get Parameter Data Loop Ended');

    Log_Mesg('l_new_sales_force_id : '||l_new_salesforce_id);
    Log_Mesg('l_new_sales_group_id : '||l_new_sales_group_id);
    Log_Mesg('l_new_owner_id : '||l_new_owner_id);

    Log_Mesg('Looping to get Work Item Data only.');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).dataSetType;
      l_data_set_id   := p_work_action_data(i).dataSetID;

	  IF l_data_set_type = 'WORK_ITEM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Work Data Name: '||l_name||' ('||l_value||')');
	    IF l_name = 'SALES_LEAD_ID' THEN
          l_sales_lead_id := l_value;
 	    ELSIF l_name = 'PARTY_ID' THEN
          l_customer_id := l_value;
	    ELSIF l_name = 'PHONE_ID' THEN
          l_phone_id := l_value;
		ELSIF l_name = 'LAST_UPDATE_DATE' THEN
		 l_last_update_date := TO_DATE(l_value, 'DD-MM-YYYY HH24:MI:SS');
        END IF;
      END IF;

      IF l_prev_data_set_id <> l_data_set_id OR
         i = p_work_action_data.COUNT THEN

        Log_Mesg('Before Territory check');
        AST_ACCESS.Has_LeadOwnerAccess
        ( p_sales_lead_id   => l_sales_lead_id,
          p_admin_flag      => l_admin_flag,
          p_admin_group_id  => l_admin_group_id,
          p_person_id       => l_person_id,
          p_resource_id     => l_resource_id,
          x_return_status	=> l_return_status,
	      x_msg_count		=> l_msg_count,
	      x_msg_data		=> l_msg_data
        );
        Log_Mesg('After Territory check');

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        AST_UWQ_WRAPPER_PKG.REASSIGN_LEAD
        (
         p_admin_flag			=> l_admin_flag,
         p_admin_group_id		=> l_admin_group_id,
         p_default_group_id     => l_default_group_id,
         p_person_id            => l_person_id,
         p_resource_id			=> l_resource_id,
         p_sales_lead_id		=> l_sales_lead_id,
         p_new_salesforce_id	=> l_new_salesforce_id,
		 p_last_update_date     => l_last_update_date,
         p_new_sales_group_id	=> l_new_sales_group_id,
         p_new_owner_id			=> l_new_owner_id,
         p_called_node          => l_called_node,
         x_return_status		=> l_return_status,
         x_msg_count		    => l_msg_count,
         x_msg_data		        => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Failed to Reassign Lead: ', FALSE);
--          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Successfully Reassigned Lead: ', FALSE);
--          FND_MSG_PUB.ADD;
        END IF;

        IF l_notes IS NOT NULL THEN
          l_source_object_type_code := 'LEAD';
          l_source_object_id        := l_sales_lead_id;
          l_party_id                := l_customer_id; --REVIEW

          AST_UWQ_WRAPPER_PKG.CREATE_NOTE
          ( p_source_object_id   => l_source_object_id,
            p_source_object_code => l_source_object_type_code,
            p_notes              => l_notes,
            p_notes_detail       => NULL,
            p_entered_by         => l_last_updated_by,
            p_entered_date       => l_last_update_date,
            p_last_update_date   => l_last_update_date,
            p_last_updated_by    => l_last_updated_by,
            p_creation_date      => l_creation_date,
            p_created_by         => l_created_by,
            p_last_update_login  => l_last_update_login,
            p_party_id           => l_party_id,
            x_jtf_note_id        => l_jtf_note_id,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            Log_Mesg('Note Creation Failed.');
            x_return_status := l_return_status;
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;
--            FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--            FND_MESSAGE.Set_Token('TEXT', 'Failed to Creat Note', FALSE);
--            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            x_return_status := l_return_status;
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;
--            FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--            FND_MESSAGE.Set_Token('TEXT', 'Successfully Created Note: '||TO_CHAR(l_jtf_note_id), FALSE);
--            FND_MSG_PUB.ADD;
          END IF;
        ELSE
          Log_Mesg('User did not enter any note to create.');
        END IF;
      END IF;
      l_prev_data_set_id := l_data_set_id;
    END LOOP;
    Log_Mesg('Get Work Data Loop Ended');

    LLIST_WORK_NODE_REFRESH
      ( p_action_key       => p_action_key,
        p_lead_id          => NULL,
        p_sales_lead_id    => NULL,
        x_uwq_actions_list => x_uwq_actions_list
      );

  END; -- End procedure LLIST_LEAD_REASSIGN_LEAD

  PROCEDURE LLIST_LEAD_TO_OPPORTUNITY
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data	IN  SYSTEM.ACTION_INPUT_DATA_NST,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    ) IS

    --moved creation date as sysdate for created objects here. jraj 9/4/03
	-- last update date is now obtained as datetime from bali...fix for bug 2614503.
	-- used for update lead.
    l_last_update_date        DATE;
    l_last_updated_by         NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_created_by              NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_last_update_login       NUMBER := FND_PROFILE.Value('LOGIN_ID'); -- REVIEW

    l_admin_flag              VARCHAR2(1); --P From GLOBAL.AST_ADMIN_FLAG
    l_sales_lead_id           NUMBER;
    l_sales_group_id          NUMBER; --W
    l_resource_id             NUMBER;

    l_admin_group_id            NUMBER; --P From GLOBAL.AST_ADMIN_GROUP_ID
    l_identity_salesforce_id    NUMBER; --P From GLOBAL.AST_RESOURCE_ID
    l_p_status_code             VARCHAR2(30); --P
    l_status_code               VARCHAR2(30); --P
    l_customer_id               NUMBER; --P
    l_contact_party_id		    NUMBER; --P
    l_assign_to_salesforce_id   NUMBER; --P From GLOBAL.AST_RESOURCE_ID
    l_assign_sales_group_id     NUMBER; --P From GLOBAL.AST_MEM_GROUP_ID
    l_p_budget_status_code		VARCHAR2(30); --P
    l_budget_status_code		VARCHAR2(30); --P

    --Bug # 3491443
    l_p_description             VARCHAR2(2000); --P
    l_description               VARCHAR2(2000); --P

    l_source_promotion_id       NUMBER; --W
    l_p_lead_rank_id            NUMBER; --P
    l_lead_rank_id              NUMBER; --P
    l_p_decision_timeframe_code VARCHAR2(30); --P
    l_decision_timeframe_code   VARCHAR2(30); --P
	l_p_accept_flag				VARCHAR2(1);
	l_accept_flag				VARCHAR2(1);
	l_p_qualified_flag			VARCHAR2(1);
	l_qualified_flag			VARCHAR2(1);
    l_initiating_contact_id     NUMBER; --REVIEW
    l_phone_id                  NUMBER; --P  --ADD TO VIEW
    l_close_reason_code         VARCHAR2(30);
    l_person_id                 NUMBER;

    l_source_object_type_code VARCHAR2(60);
    l_source_object_id        NUMBER; -- Lead Id

    l_notes                   VARCHAR2(2000);
    l_note_type               VARCHAR2(30);
    l_note_status             VARCHAR2(1);
    l_party_id                NUMBER;
    l_jtf_note_id             NUMBER;

    l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_opp_id                  NUMBER;
    l_app_launch              VARCHAR2(1);
  BEGIN
    Log_Mesg('Inside convert lead to opportunity.');
    l_data_set_id      := NULL;
    l_prev_data_set_id := NULL;
    l_resource_id      := p_resource_id;
    l_identity_salesforce_id    := l_resource_id;

    Log_Mesg('Looping to get Param Item Data only.');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;

      IF l_data_set_type = 'ACTION_PARAM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

		Log_Mesg('Action Param Data Name: '||l_name||' ('||LENGTH(l_value)||')');
	    IF l_name = 'ADMIN_GROUP_ID' THEN
          l_admin_group_id := TO_NUMBER(l_value);
	    ELSIF l_name = 'MEM_GROUP_ID' THEN
	      l_sales_group_id := TO_NUMBER(l_value);
	      l_assign_sales_group_id := TO_NUMBER(l_value);
	    ELSIF l_name = 'ADMIN_FLAG' THEN
	      l_admin_flag := l_value;
	    ELSIF l_name = 'LEAD_NAME' THEN
	      l_description := l_value;
	      l_p_description := l_value;
	    ELSIF l_name = 'STATUS_CODE' THEN
          l_status_code := l_value;
          l_p_status_code := l_value;
	    ELSIF l_name = 'LEAD_RANK' THEN
          l_lead_rank_id   := l_value;
          l_p_lead_rank_id   := l_value;
	    ELSIF l_name = 'BUDGET_STATUS' THEN
          l_budget_status_code := l_value;
          l_p_budget_status_code := l_value;
	    ELSIF l_name = 'TIME_FRAME' THEN
          l_decision_timeframe_code := l_value;
          l_p_decision_timeframe_code := l_value;
	    ELSIF l_name = 'CLOSE_REASON' THEN
          l_close_reason_code := l_value;
	    ELSIF l_name = 'ACCEPT_FLAG' THEN
          l_accept_flag := l_value;
          l_p_accept_flag := l_value;
	    ELSIF l_name = 'QUALIFIED_FLAG' THEN
          l_qualified_flag := l_value;
          l_p_qualified_flag := l_value;
	    ELSIF l_name = 'NEW_NOTE' THEN
          --Bug # 3525736
	    BEGIN
		l_notes := l_value;
	    EXCEPTION
		WHEN VALUE_ERROR THEN
			l_return_status := 'E';
			x_return_status := l_return_status;
                        FND_MESSAGE.Set_Name('AST', 'AST_NOTE_LENGTH_ERROR');
		        FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
	    END;
	    ELSIF l_name = 'PERSON_ID' THEN
	      l_person_id := l_value;
        END IF;
      ELSE
        EXIT;
      END IF;
    END LOOP;
    Log_Mesg('Get Parameter Data Loop Ended');

    Log_Mesg('Looping to get Work Item Data only.');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).dataSetType;
      l_data_set_id   := p_work_action_data(i).dataSetID;

	  IF l_data_set_type = 'WORK_ITEM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Work Data Name: '||l_name||' ('||LENGTH(l_value)||')');
	    IF l_name = 'SALES_LEAD_ID' THEN
          l_sales_lead_id := l_value;
	    ELSIF l_name = 'SOURCE_CODE_FOR_ID' THEN
          l_source_promotion_id := l_value; --REVIEW
 	    ELSIF l_name = 'PARTY_ID' THEN
          l_customer_id := l_value;
        ELSIF l_name = 'CONTACT_PARTY_ID' THEN
          l_initiating_contact_id := l_value;
	    ELSIF l_name = 'PHONE_ID' THEN
          l_phone_id := l_value;
	    ELSIF l_name = 'DESCRIPTION' AND
          l_p_description IS NULL THEN
          l_description := l_value;
	    ELSIF l_name = 'STATUS_CODE' AND
          l_p_status_code IS NULL THEN
          l_status_code := l_value;
	    ELSIF l_name = 'LEAD_RANK_ID' AND
          l_p_lead_rank_id IS NULL THEN
          l_lead_rank_id   := l_value;
	    ELSIF l_name = 'BUDGET_STATUS_CODE' AND
          l_p_budget_status_code IS NULL THEN
          l_budget_status_code := l_value;
	    ELSIF l_name = 'ACCEPT_FLAG' AND
          l_p_accept_flag IS NULL THEN
          l_accept_flag := l_value;
	    ELSIF l_name = 'QUALIFIED_FLAG' AND
          l_p_qualified_flag IS NULL THEN
          l_qualified_flag := l_value;
	    ELSIF l_name = 'DECISION_TIMEFRAME_CODE' AND
          l_p_decision_timeframe_code IS NULL THEN
          l_decision_timeframe_code := l_value;
        ELSIF l_name = 'ASSIGN_TO_SALESFORCE_ID' THEN
          l_assign_to_salesforce_id := l_value;
	    ELSIF l_name = 'ASSIGN_SALES_GROUP_ID' THEN
	      l_assign_sales_group_id := TO_NUMBER(l_value);
	    -- last update date is now obtained as datetime from bali...fix for bug 2614503.
	    -- used for update lead.
		ELSIF l_name = 'LAST_UPDATE_DATE' THEN
		 l_last_update_date := TO_DATE(l_value, 'DD-MM-YYYY HH24:MI:SS');
        END IF;
      END IF;

      IF l_data_set_id <= 1 AND
         i = p_work_action_data.COUNT THEN
        IF l_p_status_code IS NULL THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('AST', 'AST_LEAD_STATUS_REQUIRED');
--          FND_MESSAGE.Set_Token('TEXT', 'Failed to Update Lead: ', FALSE);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      IF l_prev_data_set_id <> l_data_set_id OR
         i = p_work_action_data.COUNT THEN

        Log_Mesg('Before Territory check Has_updatelead ');
        AST_ACCESS.Has_UpdateLeadAccess
        ( p_sales_lead_id   => l_sales_lead_id,
          p_admin_flag      => l_admin_flag,
          p_admin_group_id  => l_admin_group_id,
          p_person_id       => l_person_id,
          p_resource_id     => l_identity_salesforce_id,
          x_return_status	=> l_return_status,
	      x_msg_count		=> l_msg_count,
	      x_msg_data		=> l_msg_data
        );
        Log_Mesg('After Territory check ' ||l_return_status);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        Log_Mesg(l_sales_lead_id||' - '||l_status_code);
        AST_UWQ_WRAPPER_PKG.UPDATE_LEAD
   	      (
	        p_sales_lead_id			  => l_sales_lead_id,
	        p_admin_group_id		  => l_admin_group_id,
	        p_identity_salesforce_id  => l_identity_salesforce_id,
			p_last_update_date        => l_last_update_date,
	        p_status_code		      => l_status_code,
	        p_customer_id		      => l_customer_id,
            p_admin_flag              => l_admin_flag,
            p_assign_to_salesforce_id => l_assign_to_salesforce_id,
            p_assign_sales_group_id   => l_assign_sales_group_id,
	        p_budget_status_code	  => l_budget_status_code,
	        p_description		      => l_description,
	        p_source_promotion_id	  => l_source_promotion_id,
	        p_lead_rank_id		      => l_lead_rank_id,
	        p_decision_timeframe_code => l_decision_timeframe_code,
	        p_initiating_contact_id   => l_initiating_contact_id,
	        p_phone_id		          => l_phone_id,
            p_close_reason_code		  => l_close_reason_code,
	  	    p_accept_flag			  => l_accept_flag,
	  	    p_qualified_flag		  => l_qualified_flag,
            p_called_node             => l_called_node,
	        x_return_status		      => l_return_status,
	        x_msg_count		          => l_msg_count,
	        x_msg_data		          => l_msg_data
	      );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Failed to Update Lead: ', FALSE);
--          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Successfully Updated Lead: '||TO_CHAR(l_sales_lead_id), FALSE);
--          FND_MSG_PUB.ADD;
        END IF;

        Log_Mesg('Before calling girish API to convert lead');
        AST_UWQ_WRAPPER_PKG.CREATE_OPP_FOR_LEAD
        (
         p_admin_flag	  => l_admin_flag,
         p_sales_lead_id  => l_sales_lead_id,
         p_resource_id	  => l_resource_id,
         p_salesgroup_id  => l_sales_group_id,
         p_called_node    => l_called_node,
         x_return_status  => l_return_status,
         x_msg_count	  => l_msg_count,
         x_msg_data		  => l_msg_data,
         x_app_launch     => l_app_launch,
         x_opportunity_id => l_opp_id
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Failed to Convert Lead to Opportunity: ', FALSE);
--          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Successfully Converted Lead to Opportuniy: '||TO_CHAR(l_opp_id), FALSE);
--          FND_MSG_PUB.ADD;
        END IF;
        Log_Mesg('After calling girish API : l_app_launch' || l_app_launch);

        IF l_notes IS NOT NULL THEN
          l_source_object_type_code := 'LEAD';
          l_source_object_id        := l_sales_lead_id;
          l_party_id                := l_customer_id; --REVIEW

          AST_UWQ_WRAPPER_PKG.CREATE_NOTE
          ( p_source_object_id   => l_source_object_id,
            p_source_object_code => l_source_object_type_code,
            p_notes              => l_notes,
            p_notes_detail       => NULL,
            p_entered_by         => l_last_updated_by,
            p_entered_date       => sysdate,
            p_last_update_date   => sysdate,
            p_last_updated_by    => l_last_updated_by,
            p_creation_date      => sysdate,
            p_created_by         => l_created_by,
            p_last_update_login  => l_last_update_login,
            p_party_id           => l_party_id,
            x_jtf_note_id        => l_jtf_note_id,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            Log_Mesg('Note Creation Failed.');
            x_return_status := l_return_status;
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;
--            FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--            FND_MESSAGE.Set_Token('TEXT', 'Failed to Creat Note', FALSE);
--            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            x_return_status := l_return_status;
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;
--            FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--            FND_MESSAGE.Set_Token('TEXT', 'Successfully Created Note: '||TO_CHAR(l_jtf_note_id), FALSE);
--            FND_MSG_PUB.ADD;
          END IF;
        ELSE
          Log_Mesg('User did not enter any note to create.');
        END IF;

      END IF;
      l_prev_data_set_id := l_data_set_id;
    END LOOP;
    Log_Mesg('Get Work Data Loop Ended');

    IF l_app_launch = 'Y' THEN
      LLIST_WORK_NODE_REFRESH
      ( p_action_key       => p_action_key,
        p_lead_id          => NULL,
        p_sales_lead_id    => l_sales_lead_id,
        x_uwq_actions_list => x_uwq_actions_list
      );
    ELSE
      LLIST_WORK_NODE_REFRESH
      ( p_action_key       => p_action_key,
        p_sales_lead_id    => NULL,
        p_lead_id          => l_opp_id,
        x_uwq_actions_list => x_uwq_actions_list
      );
    END IF;
  END; -- End procedure LLIST_LEAD_TO_OPPORTUNITY

  PROCEDURE LLIST_CREATE_NOTE
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data    IN  SYSTEM.ACTION_INPUT_DATA_NST,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    ) IS

    l_creation_date             DATE   := SYSDATE;
    l_last_update_date          DATE   := SYSDATE;
    l_last_updated_by           NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_created_by                NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_last_update_login         NUMBER := FND_PROFILE.Value('LOGIN_ID'); -- REVIEW

    l_customer_id               NUMBER;   --W
    l_source_object_type_code   VARCHAR2(60);
    l_source_object_id          NUMBER;   --P (Customer_party_id)
    l_source_object_name        VARCHAR2(80);   --P (Customer_Name)

    l_notes                     VARCHAR2(2000);
    l_party_id                  NUMBER;

    l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_task_id                   NUMBER;
    l_jtf_note_id               NUMBER;
    l_err_mesg                  VARCHAR2(500);
  BEGIN
    Log_Mesg('Inside Create Note');
    l_data_set_id      := NULL;
    l_prev_data_set_id := NULL;

    Log_Mesg('Looping to get Param Item Data only.');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;

      IF l_data_set_type = 'ACTION_PARAM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Action Param Data Name: '||l_name||' ('||l_value||')');
		IF l_name = 'NEW_NOTE' THEN
          --Bug # 3525736
	    BEGIN
		l_notes := l_value;
	    EXCEPTION
		WHEN VALUE_ERROR THEN
			l_return_status := 'E';
			x_return_status := l_return_status;
                        FND_MESSAGE.Set_Name('AST', 'AST_NOTE_LENGTH_ERROR');
		        FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
	    END;
        END IF;
      ELSE
        EXIT;
      END IF;
    END LOOP;
    Log_Mesg('Get Parameter Data Loop Ended');

    Log_Mesg('Looping to get Work Item and Param Item Data');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;
      l_data_set_id   := p_work_action_data(i).dataSetId;

      Log_Mesg('Data Set Type: '||l_data_set_type);
	  IF l_data_set_type = 'WORK_ITEM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Work Data Name: '||l_name||' ('||l_value||')');
 	    IF l_name = 'PARTY_ID' THEN
          l_customer_id := TO_NUMBER(l_value);
	    ELSIF l_name = 'SALES_LEAD_ID' THEN
          l_source_object_id := l_value;
        END IF;
      END IF;

      Log_Mesg('Object Type Code: '||l_source_object_type_code);
      Log_Mesg('Object Type id: '||l_source_object_id);

      IF l_prev_data_set_id <> l_data_set_id OR
         i = p_work_action_data.COUNT THEN

        IF l_notes IS NOT NULL THEN
		  l_source_object_type_code := 'LEAD';
          l_party_id                := l_customer_id; --REVIEW

          Log_Mesg('Start Create Note');
          AST_UWQ_WRAPPER_PKG.CREATE_NOTE
          ( p_source_object_id   => l_source_object_id,
            p_source_object_code => l_source_object_type_code,
            p_notes              => l_notes,
            p_notes_detail       => NULL,
            p_entered_by         => l_last_updated_by,
            p_entered_date       => l_last_update_date,
            p_last_update_date   => l_last_update_date,
            p_last_updated_by    => l_last_updated_by,
            p_creation_date      => l_creation_date,
            p_created_by         => l_created_by,
            p_last_update_login  => l_last_update_login,
            p_party_id           => l_party_id,
            x_jtf_note_id        => l_jtf_note_id,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data
          );
          Log_Mesg('End Create Note');

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;
--            FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--            FND_MESSAGE.Set_Token('TEXT', 'Failed to Creat Note', FALSE);
--            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            x_return_status := l_return_status;
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;
--            FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--            FND_MESSAGE.Set_Token('TEXT', 'Successfully Created Note: '||TO_CHAR(l_jtf_note_id), FALSE);
--            FND_MSG_PUB.ADD;
          END IF;
        ELSE
          Log_Mesg('User did not enter any note to create.');
        END IF;
      END IF;

      l_prev_data_set_id := l_data_set_id;
    END LOOP;
    Log_Mesg('Get Work Data Loop Ended');

    LLIST_WORK_NODE_REFRESH
      ( p_action_key       => p_action_key,
        p_lead_id          => NULL,
        p_sales_lead_id    => NULL,
        x_uwq_actions_list => x_uwq_actions_list
      );

  END; -- End procedure LLIST_CREATE_NOTE

END; -- Package Body AST_UWQ_LLIST_WORK_ACTION

/
