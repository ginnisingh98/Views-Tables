--------------------------------------------------------
--  DDL for Package Body AST_UWQ_MLIST_WORK_ACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_UWQ_MLIST_WORK_ACTION" AS
/* $Header: astumacb.pls 120.2 2005/08/10 04:44:28 appldev ship $ */

  G_Debug  BOOLEAN;

  l_called_node       VARCHAR2(10) := 'MLIST';

  l_name              VARCHAR2(500);
  l_value             VARCHAR2(4000);
  l_type              VARCHAR2(500);
  l_data_set_type     VARCHAR2(50);
  l_data_set_id       NUMBER;
  l_prev_data_set_id  NUMBER;

  PROCEDURE Log_Mesg
    (p_message IN VARCHAR2,
     p_date  IN  VARCHAR2) IS
  BEGIN
    IF G_Debug THEN
      AST_DEBUG_PUB.LogMessage(debug_msg  => p_message,
                               print_date => p_date);
    END IF;
  END; -- End procedure Log_Mesg

  PROCEDURE MLIST_UPDATE_OUTCOME
    ( p_action_key     IN  VARCHAR2,
      p_list_header_id IN  NUMBER,
      p_list_entry_id  IN  NUMBER,
      p_outcome_id     IN  NUMBER,
      p_reason_id      IN  NUMBER,
      p_result_id      IN  NUMBER,
      x_msg_count      OUT NOCOPY NUMBER,
      x_msg_data       OUT NOCOPY VARCHAR2,
      x_return_status  OUT NOCOPY VARCHAR2
    ) IS

    l_creation_date     DATE   := SYSDATE;
    l_last_update_date  DATE   := SYSDATE;
    l_last_updated_by   NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_created_by        NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_last_update_login NUMBER := FND_PROFILE.Value('LOGIN_ID'); -- REVIEW

  BEGIN
    BEGIN
      SAVEPOINT lock_ams_list;
      UPDATE Ams_list_entries
      SET outcome_id        = p_outcome_id,
          reason_id         = p_reason_id,
          result_id         = p_result_id,
          last_update_date  = l_last_update_date,
          last_updated_by   = l_last_updated_by,
          last_update_login = l_last_update_login
      WHERE list_entry_id   = p_list_entry_id
        AND list_header_id  = p_list_header_id;
    EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO lock_ams_list;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        FND_MSG_PUB.count_and_get
          ( p_count => x_msg_count,
            p_data => x_msg_data
          );
      WHEN OTHERS THEN
        ROLLBACK TO lock_ams_list;
        FND_MESSAGE.set_name ('AST', 'JTF_TASK_UNKNOWN_ERROR');
        FND_MESSAGE.set_token ('P_TEXT', SQLCODE || SQLERRM);
        x_return_status := FND_API.G_Ret_Sts_Unexp_Error;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data
          );
    END;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    COMMIT;
  END; -- End procedure MLIST_UPDATE_OUTCOME

  PROCEDURE MLIST_WORK_NODE_REFRESH
    ( p_action_key       IN  VARCHAR2,
      p_lead_id          IN  NUMBER,
      p_sales_lead_id    IN  NUMBER,
      x_uwq_actions_list OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST
    ) IS

    l_uwq_actions_list IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_REC_LIST;
    l_uwq_action_data_list  IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_DATA_REC_LIST;
    l_action_data           VARCHAR2(4000);
    l_launch_opp_lead	   VARCHAR2(500);
    l_action_key VARCHAR2(30) := p_action_key;
  BEGIN
    Log_Mesg('Node Refresh Action Set');
    l_uwq_actions_list(1).uwq_action_key := 'UWQ_WORK_DETAILS_REFRESH';
    l_uwq_actions_list(1).action_data    := '';
    l_uwq_actions_list(1).dialog_style   := 1;
    l_uwq_actions_list(1).message        := '';


    IF p_lead_id IS NOT NULL OR
       p_sales_lead_id IS NOT NULL THEN
      Log_Mesg('Lead Id = '||p_lead_id);
      Log_Mesg('Sales Lead Id = '||p_sales_lead_id);
      l_uwq_action_data_list(1).name  := 'ACTION_NAME';
      l_uwq_action_data_list(1).type  := 'VARCHAR2';

 -- Included 'PLIST_CREATE_OPPORTUNITY' and 'PLIST_CREATE_LEAD' work actions by Sumita for bug # 3812865 on 10.14.2004 in the procedure
 -- 'MLIST_WORK_NODE_REFRESH' to launch the respective work Centers

      IF p_action_key in ('MLIST_CREATE_OPPORTUNITY','PLIST_CREATE_OPPORTUNITY')THEN
        l_uwq_action_data_list(1).value := 'ASTOPCNT';
      ELSIF p_action_key in ('MLIST_CREATE_LEAD' ,'PLIST_CREATE_LEAD')THEN
        l_uwq_action_data_list(1).value := 'ASTSLCNT';
      END IF;

      l_uwq_action_data_list(2).name  := 'ACTION_TYPE';
      l_uwq_action_data_list(2).value := 1;
      l_uwq_action_data_list(2).type  := 'NUMBER';

      l_uwq_action_data_list(3).name  := 'ACTION_PARAMS';
      l_uwq_action_data_list(3).type  := 'VARCHAR2';
      IF p_action_key in ('MLIST_CREATE_LEAD','PLIST_CREATE_LEAD') THEN
        l_uwq_action_data_list(3).value := ' sales_lead_id = '||p_sales_lead_id;
      ELSIF p_action_key in ('MLIST_CREATE_OPPORTUNITY','PLIST_CREATE_OPPORTUNITY') THEN
        l_uwq_action_data_list(3).value := ' lead_id = '||p_lead_id;
      END IF;


      IEU_UWQ_WORK_PANEL_PUB.SET_UWQ_ACTION_DATA(l_uwq_action_data_list, l_action_data);

      Log_Mesg('Node Refresh Second Action Set');
      l_uwq_actions_list(2).uwq_action_key := 'UWQ_LAUNCH_APP';
      l_uwq_actions_list(2).action_data    := l_action_data;
      IF NVL(FND_PROFILE.Value('AST_LAUNCH_OPP_LEAD'), 'N') = 'Y' THEN
        l_uwq_actions_list(2).dialog_style   := 1;
      ELSE
        l_uwq_actions_list(2).dialog_style   := 3;
      END IF;
      IF p_action_key in ('MLIST_CREATE_OPPORTUNITY','PLIST_CREATE_OPPORTUNITY') THEN
	   fnd_message.set_name('AST','AST_UWQ_LAUNCH_OPP_CENTER');
	   l_launch_opp_lead :=   fnd_message.get;
        l_uwq_actions_list(2).message        := l_launch_opp_lead;
      ELSIF p_action_key in ('MLIST_CREATE_LEAD' ,'PLIST_CREATE_LEAD')THEN
	   fnd_message.set_name('AST','AST_UWQ_LAUNCH_LEAD_CENTER');
	   l_launch_opp_lead:=   fnd_message.get;
        l_uwq_actions_list(2).message        := l_launch_opp_lead;
      END IF;
    END IF;

    IEU_UWQ_WORK_PANEL_PUB.SET_UWQ_ACTIONS(l_uwq_actions_list, x_uwq_actions_list);
    Log_Mesg('Node Refresh Action Set Done.');
  END; -- End procedure MLIST_WORK_NODE_REFRESH

  PROCEDURE MLIST_WORK_ITEM_ACTION
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
    x_action_data            VARCHAR2(4000);
    l_action_key             VARCHAR2(100);

    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
  BEGIN

    IF FND_PROFILE.Value('AST_DEBUG') = 'Y' THEN
	 G_Debug := TRUE;
    ELSE
	 G_Debug := FALSE;
    END IF;

    Log_Mesg('Start Log', 'Y');

    Log_Mesg('Switching Action Keys');
    IF p_action_key = 'OMLST_CREATE_LEAD' THEN
      l_action_key := 'MLIST_CREATE_LEAD';
    ELSIF p_action_key = 'OMLST_CREATE_OPPORTUNITY' THEN
      l_action_key := 'MLIST_CREATE_OPPORTUNITY';
    ELSIF p_action_key = 'OMLST_NEW_TASK' THEN
      l_action_key := 'MLIST_NEW_TASK';
    ELSIF p_action_key = 'OMLST_CREATE_NOTE' THEN
      l_action_key := 'MLIST_CREATE_NOTE';
    ELSIF p_action_key = 'OMLST_GEN_ACTION' THEN
      l_action_key := 'MLIST_GEN_ACTION';
    ELSE
      l_action_key := p_action_key;
    END IF;
    Log_Mesg('End Switching Action Keys');

    Log_Mesg('Action Key: '||l_action_key);

     -- Included 'PLIST_CREATE_OPPORTUNITY' and 'PLIST_CREATE_LEAD' work actions by Sumita for bug # 3812865 on 10.14.2004 in the procedure
     -- 'MLIST_WORK_ITEM_ACTION' to define respective actions

    IF l_action_key in ('MLIST_CREATE_LEAD','PLIST_CREATE_LEAD') THEN
      MLIST_CREATE_LEAD
        ( p_action_key       => l_action_key,
          p_resource_id      => p_resource_id,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
        );
    ELSIF l_action_key in ('MLIST_CREATE_OPPORTUNITY','PLIST_CREATE_OPPORTUNITY') THEN
      MLIST_CREATE_OPPORTUNITY
        ( p_action_key       => l_action_key,
          p_resource_id      => p_resource_id,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data,
          x_return_status    => l_return_status
        );
    ELSIF l_action_key = 'MLIST_NEW_TASK' THEN
      Log_Mesg('Calling New Task Action Procedure');
      MLIST_NEW_TASK
        ( p_action_key       => l_action_key,
          p_resource_id      => p_resource_id,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
        );
    ELSIF l_action_key = 'MLIST_CREATE_NOTE' THEN
      Log_Mesg('Calling Create Note Action Procedure');
      MLIST_CREATE_NOTE
        ( p_action_key       => l_action_key,
          p_resource_id      => p_resource_id,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
        );

    ELSIF l_action_key = 'MLIST_GEN_ACTION' THEN
      MLIST_GEN_ACTION
        ( p_action_key       => l_action_key,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data,
          x_return_status    => l_return_status
        );
    END IF;
    x_return_status := l_return_status;
    Log_Mesg('End Log', 'Y');
    EXCEPTION WHEN OTHERS THEN
    x_return_status := l_return_status;
    Log_Mesg('End Log in Exception', 'Y');
  END; -- End procedure MLIST_WORK_ITEM_ACTION

  PROCEDURE MLIST_GEN_ACTION
    ( p_work_action_data   IN  SYSTEM.ACTION_INPUT_DATA_NST,
      p_action_key         IN  VARCHAR2,
      x_uwq_actions_list   OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count          OUT NOCOPY NUMBER,
      x_msg_data           OUT NOCOPY VARCHAR2,
      x_return_status      OUT NOCOPY VARCHAR2
    ) IS

    l_list_entry_id           NUMBER;
    l_list_header_id          NUMBER;

    l_creation_date           DATE   := SYSDATE;
    l_last_update_date        DATE   := SYSDATE;
    l_last_updated_by         NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_created_by              NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_last_update_login       NUMBER := FND_PROFILE.Value('LOGIN_ID'); -- REVIEW

    l_customer_id             NUMBER;
    l_party_id                NUMBER;
    l_source_object_type_code VARCHAR2(60);
    l_source_object_id        NUMBER;   --P (Customer_party_id)

    l_notes                   VARCHAR2(2000);
    l_jtf_note_id             NUMBER;

    l_outcome_id              NUMBER;
    l_reason_id               NUMBER;
    l_result_id               NUMBER;

    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
  BEGIN
    Log_Mesg('Inside General Action: '||p_action_key);
    l_data_set_id      := NULL;
    l_prev_data_set_id := NULL;

    Log_Mesg('Looping to get Param Item Data only.');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;

      IF l_data_set_type = 'ACTION_PARAM_DATA' THEN
	    l_name  := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Action Param Data Name: '||l_name||' ('||LENGTH(l_value)||')');
	    IF l_name = 'OUTCOME_ID' THEN
          l_outcome_id := l_value;
	    ELSIF l_name = 'REASON_ID' THEN
          l_reason_id := l_value;
	    ELSIF l_name = 'RESULT_ID' THEN
          l_result_id := l_value;
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
      ELSE
        EXIT;
      END IF;
    END LOOP;
    Log_Mesg('Get Parameter Data Loop Ended');

    Log_Mesg('Looping to get Work Item Data only.');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;
      l_data_set_id   := p_work_action_data(i).dataSetID;

	  IF l_data_set_type = 'WORK_ITEM_DATA' THEN

	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Work Data Name: '||l_name||' ('||LENGTH(l_value)||')');
	    IF l_name = 'LIST_HEADER_ID' THEN
	      l_list_header_id := l_value;
	    ELSIF l_name = 'LIST_ENTRY_ID' THEN
	      l_list_entry_id := l_value;
        ELSIF l_name = 'CUSTOMER_ID' THEN
          l_customer_id := l_value;
        ELSIF l_name = 'PARTY_ID' THEN
          l_party_id := l_value;
        END IF;
      END IF;

      IF l_prev_data_set_id <> l_data_set_id OR
         i = p_work_action_data.COUNT THEN

        Log_Mesg('List Entry Id: '||l_list_entry_id);
        Log_Mesg('List Header Id: '||l_list_header_id);

         MLIST_UPDATE_OUTCOME
          ( p_action_key     => p_action_key,
            p_list_header_id => l_list_header_id,
            p_list_entry_id  => l_list_entry_id,
            p_outcome_id     => l_outcome_id,
            p_reason_id      => l_reason_id,
            p_result_id      => l_result_id,
	        x_return_status  => l_return_status,
	        x_msg_count      => l_msg_count,
	        x_msg_data       => l_msg_data
	      );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
          --x_task_id       := l_task_id;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Failed update marketing list: ', FALSE);
--          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Successfully marketing list updated ', FALSE);
--          FND_MSG_PUB.ADD;
        END IF;

        IF l_notes IS NOT NULL THEN
          l_source_object_type_code := 'PARTY';
          -- Begin Mod Raam on 07.12.2002
          l_source_object_id        := l_party_id;
          --l_party_id                := NULL;
          -- End Mod.

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
--            FND_MESSAGr.Set_Token('TEXT','Failed to Create Note', FALSE);
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

    MLIST_WORK_NODE_REFRESH
     ( p_action_key       => p_action_key,
       p_lead_id          => NULL,
       p_sales_lead_id    => NULL,
       x_uwq_actions_list => x_uwq_actions_list
     );

    x_return_status := l_return_status;
  END; -- End procedure MLIST_GEN_ACTION

  PROCEDURE MLIST_NEW_TASK
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data    IN  SYSTEM.ACTION_INPUT_DATA_NST,
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

    l_list_entry_id           NUMBER; --W
    l_list_header_id          NUMBER; --W
    l_list_source_type        VARCHAR2(30); --W
    l_task_name               VARCHAR2(80);   --P
    l_task_type_name          VARCHAR2(30);   --P
    l_task_type_id            NUMBER;   --P
    l_description             VARCHAR2(4000);   --P
    l_owner_id                NUMBER;   --W RESOURCE_ID Resource_Id  --REVIEW
    l_customer_id             NUMBER;   --W
    l_customer_name           VARCHAR2(500); --W
    l_first_name              VARCHAR2(150); --W
    l_last_name               VARCHAR2(150); --W
    l_contact_id              NUMBER;   --W
    l_date_type               VARCHAR2(30);  --P --REVIEW
    l_start_date              DATE;   --P
    l_end_date                DATE;   --P
    l_source_object_type_code VARCHAR2(60);
    l_source_object_id        NUMBER;   --P (Customer_party_id)
    l_source_object_name      VARCHAR2(80);   --P (Customer_Name)
    l_phone                   VARCHAR2(30);   --P
    l_address_id              NUMBER; --W
    l_contact_point_id        NUMBER;   --P   --ADD TO VIEW
    l_duration                NUMBER;
    l_duration_uom            VARCHAR2(3);

    l_party_id                NUMBER;
    l_notes                   VARCHAR2(2000);
    l_note_type               VARCHAR2(30);
    l_note_status             VARCHAR2(1);

    l_outcome_id              NUMBER;
    l_reason_id               NUMBER;
    l_result_id               NUMBER;

    l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_task_id                 NUMBER;
    l_jtf_note_id             NUMBER;
    l_err_mesg                VARCHAR2(500);
  BEGIN
    Log_Mesg('Inside New Task');
    l_data_set_id      := NULL;
    l_prev_data_set_id := NULL;
    l_owner_id         := p_resource_id;

    Log_Mesg('Looping to get Param Item Data only.');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;

      IF l_data_set_type = 'ACTION_PARAM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Action Param Data Name: '||l_name||' ('||LENGTH(l_value)||')');
	    IF l_name = 'TASK_NAME' THEN
	      l_task_name := l_value;
	    ELSIF l_name = 'TASK_TYPE_NAME' THEN
          l_task_type_name := l_value;
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
	    ELSIF l_name = 'OUTCOME_ID' THEN
          l_outcome_id := l_value;
	    ELSIF l_name = 'REASON_ID' THEN
          l_reason_id := l_value;
	    ELSIF l_name = 'RESULT_ID' THEN
          l_result_id := l_value;
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

    Log_Mesg('Looping to get Work Item Data only.');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;
      l_data_set_id   := p_work_action_data(i).dataSetId;

      Log_Mesg('Work Data Set: '||l_data_set_id);
	  IF l_data_set_type = 'WORK_ITEM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Work Data Name: '||l_name||' ('||LENGTH(l_value)||')');
	    IF l_name = 'LIST_HEADER_ID' THEN
	      l_list_header_id := l_value;
	    ELSIF l_name = 'LIST_ENTRY_ID' THEN
	      l_list_entry_id := l_value;
	    ELSIF l_name = 'LIST_SOURCE_TYPE' THEN
	      l_list_source_type := l_value;
 	    ELSIF l_name = 'CUSTOMER_ID' THEN
          l_customer_id := TO_NUMBER(l_value);
	    ELSIF l_name = 'CUSTOMER_NAME' THEN
          l_customer_name := l_value;
	    ELSIF l_name = 'FIRST_NAME' THEN
          l_first_name := l_value;
	    ELSIF l_name = 'LAST_NAME' THEN
          l_last_name := l_value;
 	    ELSIF l_name = 'PARTY_ID' THEN
          l_party_id := TO_NUMBER(l_value);
	    ELSIF l_name = 'PHONE' THEN
          l_phone := l_value;
	    ELSIF l_name = 'LOCATION_ID' THEN
          l_address_id := l_value;
	    ELSIF l_name = 'CONTACT_POINT_ID' THEN
          l_contact_point_id := l_value;
        END IF;
      END IF;

      IF l_prev_data_set_id <> l_data_set_id OR
         i = p_work_action_data.COUNT THEN

        l_source_object_type_code := 'PARTY';
        l_source_object_id        := l_party_id;
        l_customer_id             := l_party_id;
        IF l_list_source_type IN ( 'PERSON_LIST','CONSUMER') THEN
          l_source_object_name := l_first_name||' '||l_last_name;
        END IF;

        Log_Mesg('Start Create Task');
        AST_UWQ_WRAPPER_PKG.CREATE_TASK
          ( p_task_name                 => l_task_name,
            p_task_type_name            => l_task_type_name,
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
            p_address_id                => l_address_id,
            p_phone_id                  => l_contact_point_id,
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

        MLIST_UPDATE_OUTCOME
        ( p_action_key     => p_action_key,
          p_list_header_id => l_list_header_id,
          p_list_entry_id  => l_list_entry_id,
          p_outcome_id     => l_outcome_id,
          p_reason_id      => l_reason_id,
          p_result_id      => l_result_id,
          x_return_status  => l_return_status,
          x_msg_count      => l_msg_count,
          x_msg_data       => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
          --x_task_id       := l_task_id;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Failed update marketing list: ', FALSE);
--          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
--          FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--          FND_MESSAGE.Set_Token('TEXT', 'Successfully marketing list updated ', FALSE);
--          FND_MSG_PUB.ADD;
        END IF;

        IF l_notes IS NOT NULL THEN
          l_source_object_type_code := 'TASK';
          l_source_object_id        := l_task_id;

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

    MLIST_WORK_NODE_REFRESH
      ( p_action_key       => p_action_key,
        p_lead_id          => NULL,
        p_sales_lead_id    => NULL,
        x_uwq_actions_list => x_uwq_actions_list
      );

  END; -- End procedure MLIST_NEW_TASK

  PROCEDURE MLIST_CREATE_LEAD
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data	IN  SYSTEM.ACTION_INPUT_DATA_NST,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    ) IS
    l_list_entry_id             NUMBER;
    l_list_header_id            NUMBER;
    l_list_source_type          VARCHAR2(30); --W

    l_creation_date             DATE   := SYSDATE;
    l_last_update_date          DATE   := SYSDATE;
    l_last_updated_by           NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_created_by                NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_last_update_login         NUMBER := FND_PROFILE.Value('LOGIN_ID'); -- REVIEW

    l_admin_group_id            NUMBER; --P From GLOBAL.AST_ADMIN_GROUP_ID
    l_identity_salesforce_id    NUMBER; --P From GLOBAL.AST_RESOURCE_ID
    l_status_code               VARCHAR2(30); --P
    l_customer_id               NUMBER; --P
    l_contact_party_id		    NUMBER; --P
    l_address_id                NUMBER; --W
    l_admin_flag                VARCHAR2(1); --P From GLOBAL.AST_ADMIN_FLAG
    l_assign_to_salesforce_id   NUMBER; --P From GLOBAL.AST_RESOURCE_ID
    l_assign_sales_group_id     NUMBER; --P From GLOBAL.AST_MEM_GROUP_ID
    l_budget_status_code		VARCHAR2(30); --P
    l_description               VARCHAR2(240); --P
    l_lead_rank_id              NUMBER; --P
    l_decision_timeframe_code   VARCHAR2(30); --P
    l_initiating_contact_id     NUMBER; --REVIEW
    l_contact_point_id          NUMBER; --P  --ADD TO VIEW


   l_source_code        VARCHAR2(30);  -- Added by Sumita for bug # 3812865 on 10.14.2004

     l_source_code_id            NUMBER;
    l_source_object_type_code   VARCHAR2(60);
    l_source_object_id          NUMBER;   -- Lead Id


   l_action_key  varchar2(100) :=  p_action_key;  -- Added by Sumita for bug # 3812865 on 10.14.2004
    l_notes                     VARCHAR2(2000);
    l_note_type                 VARCHAR2(30);
    l_note_status               VARCHAR2(1);
    l_party_id                  NUMBER;

    l_outcome_id                NUMBER;
    l_reason_id                 NUMBER;
    l_result_id                 NUMBER;

    l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_sales_lead_id             NUMBER;
    l_jtf_note_id               NUMBER;
  BEGIN
    Log_Mesg('Inside Create Lead');
    l_identity_salesforce_id    := p_resource_id;
    l_assign_to_salesforce_id   := p_resource_id;

    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).dataSetType;
	  IF l_data_set_type = 'WORK_ITEM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Work Data Name: '||l_name||' ('||LENGTH(l_value)||')');
	    IF l_name = 'LIST_HEADER_ID' THEN
	      l_list_header_id := l_value;
	    ELSIF l_name = 'LIST_ENTRY_ID' THEN
	      l_list_entry_id := l_value;
	    ELSIF l_name = 'LIST_SOURCE_TYPE' THEN
	      l_list_source_type := l_value;
	    --Commenting out since we can get source_code_id directly from the view. Bug# 2775958
	    /**
	   ELSIF l_name = 'SOURCE_CODE'
	     l_source_code := l_value; --REVIEW
	   **/

	    ELSIF l_name = 'SOURCE_CODE_FOR_ID' THEN
          l_source_code_id := l_value;
 	    ELSIF l_name = 'CUSTOMER_ID' THEN
          l_customer_id := l_value;
 	    ELSIF l_name = 'PARTY_ID' THEN
          l_contact_party_id := l_value;
          l_party_id         := l_value;
 	    ELSIF l_name = 'LOCATION_ID' THEN
          l_address_id := l_value;
	    ELSIF l_name = 'CONTACT_POINT_ID' THEN
          l_contact_point_id := l_value;
        END IF;
      ELSIF l_data_set_type = 'ACTION_PARAM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

		Log_Mesg('Action Param Data Name: '||l_name||' ('||l_value||')');
	    IF l_name = 'ADMIN_GROUP_ID' THEN
          l_admin_group_id := TO_NUMBER(l_value);

 -- Added by Sumita for bug # 3812865 on 10.14.2004
	    ELSIF l_name = 'SOURCE_CODE'  and  l_action_key = 'PLIST_CREATE_LEAD' THEN
	               l_source_code := l_value; --REVIEW
 -- End Mod.

	    ELSIF l_name = 'MEM_GROUP_ID' THEN
	      l_assign_sales_group_id := TO_NUMBER(l_value);
	    ELSIF l_name = 'ADMIN_FLAG' THEN
	      l_admin_flag := l_value;
	    ELSIF l_name = 'LEAD_NAME' THEN
	      l_description := l_value;
	    ELSIF l_name = 'STATUS_CODE' THEN
		 l_status_code := l_value;
	    ELSIF l_name = 'TIME_FRAME_CODE' THEN
  		  l_decision_timeframe_code := l_value;
	    ELSIF l_name = 'LEAD_RANK_ID' THEN
          l_lead_rank_id   := l_value;
	    ELSIF l_name = 'BUDGET_STATUS_CODE' THEN
          l_budget_status_code := l_value;
	    ELSIF l_name = 'TIME_FRAME' THEN
          l_decision_timeframe_code := l_value;
	    ELSIF l_name = 'ADMIN_GROUP_ID' THEN
          l_admin_group_id := l_value;
	    ELSIF l_name = 'ADMIN_FLAG' THEN
          l_admin_flag := l_value;
	    ELSIF l_name = 'MEM_GROUP_ID' THEN
          l_assign_sales_group_id := l_value;
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
	    ELSIF l_name = 'OUTCOME_ID' THEN
          l_outcome_id := l_value;
	    ELSIF l_name = 'REASON_ID' THEN
          l_reason_id := l_value;
	    ELSIF l_name = 'RESULT_ID' THEN
          l_result_id := l_value;
        END IF;
      END IF;
    END LOOP;

    AST_ACCESS.Has_Create_LeadOppAccess
    ( p_admin_flag     => l_admin_flag,
      p_opplead_ident  => 'L',
      x_return_status  => l_return_status,
      x_msg_count      => l_msg_count,
      x_msg_data       => l_msg_data
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_list_source_type IN ( 'PERSON_LIST','CONSUMER' ) THEN
      l_customer_id      := l_contact_party_id;
      l_contact_party_id := NULL;
    END IF;
    Log_Mesg('Customer Id: '||l_customer_id);
    AST_UWQ_WRAPPER_PKG.CREATE_LEAD
 	  ( p_admin_group_id		  => l_admin_group_id,
	    p_identity_salesforce_id  => l_identity_salesforce_id,
	    p_status_code		      => l_status_code,
	    p_customer_id		      => l_customer_id,
	    p_contact_party_id	      => l_contact_party_id,
	    p_address_id		      => l_address_id,
        p_admin_flag              => l_admin_flag,
        p_assign_to_salesforce_id => l_assign_to_salesforce_id,
        p_assign_sales_group_id   => l_assign_sales_group_id,
	    p_budget_status_code	  => l_budget_status_code,
	    p_description		      => l_description,
	    p_source_code             => l_source_code,  -- Added by Sumita for bug # 3812865 on 10.14.2004
	    p_source_code_id	      => l_source_code_id,
	    p_lead_rank_id		      => l_lead_rank_id,
	    p_decision_timeframe_code => l_decision_timeframe_code,
	    p_initiating_contact_id   => l_initiating_contact_id,
	    p_phone_id		          => l_contact_point_id,
        p_called_node             => l_called_node,
	p_action_key                  => l_action_key,  -- Added by Sumita for bug # 3812865 on 10.14.2004
	    x_sales_lead_id		      => l_sales_lead_id,
	    x_return_status		      => l_return_status,
	    x_msg_count		          => l_msg_count,
	    x_msg_data		          => l_msg_data
	  );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
--      FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--      FND_MESSAGE.Set_Token('TEXT', 'Failed to Creat Lead: ', FALSE);
--      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
--      FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--      FND_MESSAGE.Set_Token('TEXT', 'Successfully Created Lead: '||TO_CHAR(l_sales_lead_id), FALSE);
--      FND_MSG_PUB.ADD;
    END IF;

    MLIST_UPDATE_OUTCOME
    ( p_action_key     => p_action_key,
      p_list_header_id => l_list_header_id,
      p_list_entry_id  => l_list_entry_id,
      p_outcome_id     => l_outcome_id,
      p_reason_id      => l_reason_id,
      p_result_id      => l_result_id,
      x_return_status  => l_return_status,
      x_msg_count      => l_msg_count,
      x_msg_data       => l_msg_data
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
--      FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--      FND_MESSAGE.Set_Token('TEXT', 'Failed update marketing list: ', FALSE);
--      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
--      FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--      FND_MESSAGE.Set_Token('TEXT', 'Successfully marketing list updated ', FALSE);
--      FND_MSG_PUB.ADD;
    END IF;

    IF l_notes IS NOT NULL THEN
      l_source_object_type_code := 'LEAD';
      l_source_object_id        := l_sales_lead_id;
      l_party_id                := l_customer_id;

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
--        FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--        FND_MESSAGE.Set_Token('TEXT', 'Failed to Creat Note', FALSE);
--        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_return_status := l_return_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
--        FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--        FND_MESSAGE.Set_Token('TEXT', 'Successfully Created Note: '||TO_CHAR(l_jtf_note_id), FALSE);
--        FND_MSG_PUB.ADD;
      END IF;
    ELSE
      Log_Mesg('User did not enter any note to create.');
    END IF;

    MLIST_WORK_NODE_REFRESH
      ( p_action_key       => p_action_key,
        p_lead_id          => NULL,
        p_sales_lead_id    => l_sales_lead_id,
        x_uwq_actions_list => x_uwq_actions_list
      );

  END; -- End procedure MLIST_CREATE_LEAD

 PROCEDURE MLIST_CREATE_OPPORTUNITY
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data	IN  SYSTEM.ACTION_INPUT_DATA_NST,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    ) IS

    l_list_entry_id         NUMBER;
    l_list_header_id        NUMBER;
    l_list_source_type      VARCHAR2(30); --W

    l_creation_date         DATE   := SYSDATE;
    l_last_update_date      DATE   := SYSDATE;
    l_last_updated_by       NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_created_by            NUMBER := FND_PROFILE.Value('USER_ID'); --REVIEW
    l_last_update_login     NUMBER := FND_PROFILE.Value('LOGIN_ID'); -- REVIEW

    l_admin_group_id        NUMBER; --P
    l_admin_flag            VARCHAR2(1); --P
    l_resource_id           NUMBER; --P From GLOBAL.AST_RESOURCE_ID
    l_description           VARCHAR2(240); --P
    l_status_code           VARCHAR2(30); --P
    l_customer_id           NUMBER; --P
    l_contact_party_id	    NUMBER; --P
    l_address_id            NUMBER; --W
    l_sales_stage_id        NUMBER; --P
    l_win_probability       NUMBER; --P
    l_channel_code          VARCHAR2(30); --P
    l_decision_date         DATE; --P or Profile AS_DEFAULT_DECISION_DATE
    l_total_revenue_forecast_amt    NUMBER; --added For R12
    --code commented for R12 Enhancement --Start
 /*   l_close_competitor_code VARCHAR2(30);
    l_close_competitor_id   NUMBER;
    l_close_competitor      VARCHAR2(255); */
    --code commented for R12 Enhancement --End
    l_close_comment         VARCHAR2(240);
    l_parent_project        VARCHAR2(80);
    l_freeze_flag           VARCHAR2(1);
    l_salesgroup_id         NUMBER; --P
    l_source_code           VARCHAR2(30);  -- Added by Sumita for bug # 3812865 on 10.14.2004
    l_action_key VARCHAR2(30) := p_action_key;  -- Added by Sumita for bug # 3812865 on 10.14.2004

    l_source_code_id        NUMBER;

    l_source_object_type_code   VARCHAR2(60);
    l_source_object_id          NUMBER;   --P (Customer_party_id)

    l_notes                     VARCHAR2(2000);
    l_note_type                 VARCHAR2(30);
    l_note_status               VARCHAR2(1);
    l_party_id                  NUMBER;

    l_outcome_id                NUMBER;
    l_reason_id                 NUMBER;
    l_result_id                 NUMBER;

    l_customer_budget           NUMBER;
    l_currency_code             varchar2(60);
    l_vehicle_response_code     varchar2(2000);

    l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_lead_id                   NUMBER;
    l_jtf_note_id               NUMBER;
    l_err_mesg                  VARCHAR2(500);
  BEGIN
    Log_Mesg('Inside Create Opportunity Action');
    l_resource_id := p_resource_id;
    l_freeze_flag := 'N';

    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;
	  IF l_data_set_type = 'WORK_ITEM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Work Data Name: '||l_name||' ('||l_value||')');
	    IF l_name = 'LIST_HEADER_ID' THEN
	      l_list_header_id := l_value;
	    ELSIF l_name = 'LIST_ENTRY_ID' THEN
	      l_list_entry_id := l_value;
	    ELSIF l_name = 'LIST_SOURCE_TYPE' THEN
	      l_list_source_type := l_value;
	    /**
	    ELSIF l_name = 'SOURCE_CODE' THEN
          l_source_code := l_value;
	    **/
	    ELSIF l_name = 'SOURCE_CODE_FOR_ID' THEN
          l_source_code_id := l_value;
 	    ELSIF l_name = 'CUSTOMER_ID' THEN
          l_customer_id := l_value;
 	    ELSIF l_name = 'PARTY_ID' THEN
          l_contact_party_id := l_value;
 	    ELSIF l_name = 'LOCATION_ID' THEN
          l_address_id := l_value;
        END IF;
      ELSIF l_data_set_type = 'ACTION_PARAM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Action Param Data Name: '||l_name||' ('||LENGTH(l_value)||')');
	    IF l_name = 'CUSTOMER_ID' THEN
          l_customer_id := l_value;
	    ELSIF l_name = 'OPPORTUNITY_NAME' THEN
          l_description := l_value;
	    ELSIF l_name = 'STATUS_CODE' THEN
          l_status_code := l_value;
	    ELSIF l_name = 'SALES_STAGE' THEN
          l_sales_stage_id := l_value;

 -- Added by Sumita for bug # 3812865 on 10.14.2004
	  ELSIF l_name = 'SOURCE_CODE'  and l_action_key = 'PLIST_CREATE_OPPORTUNITY' THEN
		l_source_code := l_value;
-- End Mod.

	    ELSIF l_name = 'WIN_PROBABILITY' THEN
          l_win_probability := l_value;
	    ELSIF l_name = 'SALES_CHANNEL' THEN
          l_channel_code := l_value;
	    ELSIF l_name = 'CLOSE_DATE' THEN
          l_decision_date := TO_DATE(l_value, 'DD-MM-YYYY HH24:MI:SS');
	  --code modified for R12 enhancement --Start
	   ELSIF l_name = 'FORECAST_AMOUNT' THEN
           l_total_revenue_forecast_amt  := l_value;
	  /* ELSIF l_name = 'KEY_COMPETITOR_ID' THEN
           l_close_competitor_id := l_value; */
	  --code modified for R12 enhancement --end
	    ELSIF l_name = 'ADMIN_GROUP_ID' THEN
          l_admin_group_id := l_value;
	    ELSIF l_name = 'ADMIN_FLAG' THEN
          l_admin_flag := l_value;
	    ELSIF l_name = 'MEM_GROUP_ID' THEN
          l_salesgroup_id := l_value;
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
	    ELSIF l_name = 'OUTCOME_ID' THEN
          l_outcome_id := l_value;
	    ELSIF l_name = 'REASON_ID' THEN
          l_reason_id := l_value;
	    ELSIF l_name = 'RESULT_ID' THEN
          l_result_id := l_value;
         ELSIF l_name = 'CURRENCY_CODE' THEN
	     l_currency_code := l_value;
         ELSIF l_name = 'VEHICLE_RESPONSE_CODE' THEN
	     l_vehicle_response_code := l_value;
         ELSIF l_name = 'CUSTOMER_BUDGET' THEN
	     l_customer_budget := l_value;
        END IF;
      END IF;


      AST_ACCESS.Has_Create_LeadOppAccess
      ( p_admin_flag     => l_admin_flag,
        p_opplead_ident  => 'O',
        x_return_status  => l_return_status,
        x_msg_count      => l_msg_count,
        x_msg_data       => l_msg_data
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      Log_Mesg('Start parameter validation');
       --code commented for R12 enhancement --Start
      /* IF l_name = 'KEY_COMPETITOR_ID' AND
         NVL(FND_PROFILE.Value('AS_COMPETITOR_REQUIRED'), 'N') = 'Y' AND
         l_close_competitor_id IS NULL THEN
        l_return_status := 'E';
      END IF;


      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        FND_MESSAGE.Set_Name('AS', 'API_CLOSE_COMPETITOR_REQUIRED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;   */
      --code commented for R12 enhancement --end
      Log_Mesg('End parameter validation');

    END LOOP;

    IF l_list_source_type IN ( 'PERSON_LIST','CONSUMER' ) THEN
      l_customer_id       := l_contact_party_id;
      l_contact_party_id  := NULL;
    END IF;

    AST_UWQ_WRAPPER_PKG.CREATE_OPPORTUNITY
      ( p_admin_group_id         => l_admin_group_id,
        p_admin_flag             => l_admin_flag,
        p_resource_id            => l_resource_id,
        p_last_update_date       => l_last_update_date,
        p_lead_id                => NULL,
        p_lead_number            => NULL,
        p_description            => l_description,
        p_status_code            => l_status_code,
	p_source_code          => l_source_code,  -- Added by Sumita for bug # 3812865 on 10.14.2004
        p_source_code_id            => l_source_code_id,
        p_customer_id            => l_customer_id,
 	    p_contact_party_id	     => l_contact_party_id,
        p_address_id             => l_address_id,
        p_sales_stage_id         => l_sales_stage_id,
        p_win_probability        => l_win_probability,
        p_total_amount           => NULL,
	p_total_revenue_forecast_amt => l_total_revenue_forecast_amt, --code added for R12
        p_channel_code           => l_channel_code,
        p_decision_date          => l_decision_date,
        p_currency_code          => l_currency_code,
	   p_vehicle_response_code  => l_vehicle_response_code,
	   p_customer_budget        => l_customer_budget,
--Code commented for R12 enhancement --Start
/*        p_close_competitor_code  => l_close_competitor_code,
        p_close_competitor_id    => l_close_competitor_id,
        p_close_competitor       => l_close_competitor, */
--Code commented for R12 enhancement --End
        p_close_comment          => l_close_comment,
        p_parent_project         => l_parent_project,
        p_freeze_flag            => l_freeze_flag,
        p_salesgroup_id          => l_salesgroup_id,
        p_called_node            => l_called_node,
	p_action_key               =>  l_action_key,  -- Added by Sumita for bug # 3812865 on 10.14.2004
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data,
        x_lead_id                => l_lead_id
      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
--      FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--      FND_MESSAGE.Set_Token('TEXT', 'Failed to Creat Opportunity: ', FALSE);
--      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
--      FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--      FND_MESSAGE.Set_Token('TEXT', 'Successfully Created Opportunity: '||TO_CHAR(l_lead_id), FALSE);
--      FND_MSG_PUB.ADD;
    END IF;

    MLIST_UPDATE_OUTCOME
    ( p_action_key     => p_action_key,
      p_list_header_id => l_list_header_id,
      p_list_entry_id  => l_list_entry_id,
      p_outcome_id     => l_outcome_id,
      p_reason_id      => l_reason_id,
      p_result_id      => l_result_id,
      x_return_status  => l_return_status,
      x_msg_count      => l_msg_count,
      x_msg_data       => l_msg_data
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
--      FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--      FND_MESSAGE.Set_Token('TEXT', 'Failed update marketing list: ', FALSE);
--      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
--      FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--      FND_MESSAGE.Set_Token('TEXT', 'Successfully marketing list updated ', FALSE);
--      FND_MSG_PUB.ADD;
    END IF;

    IF l_notes IS NOT NULL THEN
      l_source_object_type_code := 'OPPORTUNITY';
      l_source_object_id        := l_lead_id;
      l_party_id                := l_customer_id;

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
--        FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--        FND_MESSAGE.Set_Token('TEXT', 'Failed to Creat Note', FALSE);
--        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_return_status := l_return_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
--        FND_MESSAGE.Set_Name('AST', 'AST_API_ERR');
--        FND_MESSAGE.Set_Token('TEXT', 'Successfully Created Note: '||TO_CHAR(l_jtf_note_id), FALSE);
--        FND_MSG_PUB.ADD;
      END IF;
    ELSE
      Log_Mesg('User did not enter any note to create.');
    END IF;

    MLIST_WORK_NODE_REFRESH
      ( p_action_key       => p_action_key,
        p_sales_lead_id    => NULL,
        p_lead_id          => l_lead_id,
        x_uwq_actions_list => x_uwq_actions_list
      );

  END; -- End procedure MLIST_CREATE_OPPORTUNITY

  PROCEDURE MLIST_CREATE_NOTE
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data    IN  SYSTEM.ACTION_INPUT_DATA_NST,
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

    l_list_entry_id           NUMBER; --W
    l_list_header_id          NUMBER; --W
    l_list_source_type        VARCHAR2(30); --W
    l_source_object_type_code VARCHAR2(60);
    l_source_object_id        NUMBER;   --P (Customer_party_id)
    l_source_object_name      VARCHAR2(80);   --P (Customer_Name)

    l_party_id                NUMBER;
    l_notes                   VARCHAR2(2000);

    l_outcome_id              NUMBER;
    l_reason_id               NUMBER;
    l_result_id               NUMBER;

    l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_jtf_note_id             NUMBER;
    l_err_mesg                VARCHAR2(500);
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

        Log_Mesg('Action Param Data Name: '||l_name||' ('||LENGTH(l_value)||')');
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
	    ELSIF l_name = 'OUTCOME_ID' THEN
          l_outcome_id := l_value;
	    ELSIF l_name = 'REASON_ID' THEN
          l_reason_id := l_value;
	    ELSIF l_name = 'RESULT_ID' THEN
          l_result_id := l_value;
        END IF;

      ELSE
        EXIT;
      END IF;
    END LOOP;
    Log_Mesg('Get Parameter Data Loop Ended');

    Log_Mesg('Looping to get Work Item Data only.');
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;
      l_data_set_id   := p_work_action_data(i).dataSetId;

      Log_Mesg('Work Data Set: '||l_data_set_id);
	  IF l_data_set_type = 'WORK_ITEM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Work Data Name: '||l_name||' ('||LENGTH(l_value)||')');
	    IF l_name = 'LIST_HEADER_ID' THEN
	      l_list_header_id := l_value;
	    ELSIF l_name = 'LIST_ENTRY_ID' THEN
	      l_list_entry_id := l_value;
	    ELSIF l_name = 'LIST_SOURCE_TYPE' THEN
	      l_list_source_type := l_value;
 	    ELSIF l_name = 'PARTY_ID' THEN
          l_party_id := TO_NUMBER(l_value);
        END IF;
      END IF;

      IF l_prev_data_set_id <> l_data_set_id OR
         i = p_work_action_data.COUNT THEN

        l_source_object_type_code := 'PARTY';
        l_source_object_id        := l_party_id;

        IF l_notes IS NOT NULL THEN
--          l_source_object_type_code := 'PARTY';
--          l_source_object_id        := l_task_id;

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

    MLIST_WORK_NODE_REFRESH
      ( p_action_key       => p_action_key,
        p_lead_id          => NULL,
        p_sales_lead_id    => NULL,
        x_uwq_actions_list => x_uwq_actions_list
      );

  END; -- End procedure MLIST_CREATE_NOTE

END; -- Package Body UWQ_MLIST_WORK_ACTION

/
