--------------------------------------------------------
--  DDL for Package Body AST_UWQ_OLIST_WORK_ACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_UWQ_OLIST_WORK_ACTION" AS
/* $Header: astuoacb.pls 120.6 2005/10/18 23:02:42 appldev ship $ */

  G_Debug  BOOLEAN;

  l_called_node       VARCHAR2(10) := 'OLIST';

  l_name              VARCHAR2 (500);
  l_value             VARCHAR2 (4000);
  l_type              VARCHAR2 (500);
  l_data_set_type     VARCHAR2 (50);
  l_data_set_id       NUMBER;
  l_prev_data_set_id  NUMBER;

  PROCEDURE Log_Mesg
    (p_message IN VARCHAR2,
     p_date  IN  VARCHAR2 DEFAULT 'N') IS
  BEGIN
    IF G_Debug THEN
      AST_DEBUG_PUB.LogMessage(debug_msg  => p_message,
                               print_date => p_date);
    END IF;
  END; -- End procedure Log_Mesg

  PROCEDURE OLIST_WORK_NODE_REFRESH
    ( p_action_key       IN  VARCHAR2,
      p_lead_id          IN  NUMBER DEFAULT NULL,
--      p_sales_lead_id    IN  NUMBER DEFAULT NULL,
      x_uwq_actions_list OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST
    ) IS
    l_uwq_actions_list      IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_REC_LIST;
    l_uwq_action_data_list  IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_DATA_REC_LIST;
    l_action_data           VARCHAR2(4000);
  BEGIN
    l_uwq_actions_list(1).uwq_action_key := 'UWQ_WORK_DETAILS_REFRESH';
    l_uwq_actions_list(1).action_data    := '';
    l_uwq_actions_list(1).dialog_style   := 1;
    l_uwq_actions_list(1).message        := '';

--fix for bug # 3484366
/*
    IF p_lead_id IS NOT NULL THEN
--	OR p_sales_lead_id IS NOT NULL THEN
      Log_Mesg('Inside Lauch App Settings');
      Log_Mesg('Lead Id = '||p_lead_id);
--      Log_Mesg('Sales Lead Id = '||p_sales_lead_id);
      l_uwq_action_data_list(1).name  := 'ACTION_NAME';
      l_uwq_action_data_list(1).type  := 'VARCHAR2';

      l_uwq_action_data_list(2).name  := 'ACTION_TYPE';
      l_uwq_action_data_list(2).value := 1;
      l_uwq_action_data_list(2).type  := 'NUMBER';

      l_uwq_action_data_list(3).name  := 'ACTION_PARAMS';
      l_uwq_action_data_list(3).type  := 'VARCHAR2';

      IEU_UWQ_WORK_PANEL_PUB.SET_UWQ_ACTION_DATA(l_uwq_action_data_list, l_action_data);

      l_uwq_actions_list(2).uwq_action_key := 'UWQ_LAUNCH_APP';
      l_uwq_actions_list(2).action_data    := l_action_data;
      Log_Mesg('All Lauch App Settings done.');
    END IF;
*/

    IEU_UWQ_WORK_PANEL_PUB.SET_UWQ_ACTIONS(l_uwq_actions_list, x_uwq_actions_list);
  END; -- End procedure OLIST_WORK_NODE_REFRESH

--Code added for R12 Ehnancement Change customer name ---Start
  PROCEDURE Contacts_Delete(P_LEAD_ID IN NUMBER,
p_resource_id  IN NUMBER,
p_admin_flag IN  VARCHAR2,
p_admin_group_id  IN   NUMBER,
x_msg_count           OUT NOCOPY NUMBER,
x_msg_data            OUT NOCOPY VARCHAR2,
x_return_status       OUT NOCOPY VARCHAR2) IS
 v_profile_tbl    AS_UTILITY_PUB.profile_tbl_type:=as_api_records_pkg.get_p_profile_tbl;
 v_contact_tbl    AS_OPPORTUNITY_PUB.contact_tbl_Type:=as_api_records_pkg.get_p_contact_tbl;
 v_contact_out_tbl AS_OPPORTUNITY_PUB.contact_out_tbl_Type:=as_api_records_pkg.get_p_contact_out_tbl;
 v_header_rec    AS_OPPORTUNITY_PUB.header_rec_Type:=as_api_records_pkg.get_p_header_rec;

  v_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;


  v_msg_count NUMBER;
  v_msg_data VARCHAR2(2000);
  v_comp_num  NUMBER:=1;


--  v_validation_level_full  number  := ast_api.G_VALID_LEVEL_FULL ;
  v_true                   varchar2(5)  := 'T';
  v_false                  varchar2(5)  := 'F';
--  v_ret_sts_success        varchar2(1)  := ast_api.G_RET_STS_SUCCESS;
 -- v_ret_sts_error          varchar2(1)  := ast_api.G_RET_STS_ERROR;
 -- v_ret_sts_unexp_error    varchar2(1)  := ast_api.G_RET_STS_UNEXP_ERROR;


  v_contact_id NUMBER;

  CURSOR LEAD_CONTACT_ID_CUR IS
  SELECT LEAD_CONTACT_ID
  FROM
  AS_OPPORTUNITY_CONTACTS_V
  WHERE  LEAD_ID= P_lead_id;

  BEGIN


   v_contact_tbl(1).lead_id          := P_lead_id;
  FOR LEAD_CONTACT_ID_REC IN LEAD_CONTACT_ID_CUR
  LOOP
	 v_contact_tbl(1).lead_contact_id  := LEAD_CONTACT_ID_REC.LEAD_CONTACT_ID;


      BEGIN

        AS_OPPORTUNITY_PUB.DELETE_CONTACTS(
            p_api_version_number      => 2.0,
            p_init_msg_list           => v_true,
            p_commit                  => v_true,
            p_validation_level        => 100,
            p_identity_salesforce_id  => p_resource_id,
            p_contact_tbl             => v_contact_tbl,
            p_check_access_flag       => 'N',
            p_admin_flag              => nvl(p_admin_flag,'N'),
            p_admin_group_id          => p_admin_group_id,
            p_partner_cont_party_id   => NULL,
            p_profile_tbl             => v_profile_tbl,
            x_contact_out_tbl         => v_contact_out_tbl,
            x_return_status           => v_return_status,
            x_msg_count               => v_msg_count,
            x_msg_data                => v_msg_data
         );


      IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  x_return_status := v_return_status;
		  x_msg_count     := v_msg_count;
		  x_msg_data      := v_msg_data;
		  RAISE FND_API.G_EXC_ERROR;
	ELSE
		  x_return_status := v_return_status;
		  x_msg_count     := v_msg_count;
		  x_msg_data      := v_msg_data;
	END IF;

    END;

    END LOOP;
		x_return_status := v_return_status;
END Contacts_Delete;

PROCEDURE Salesteam_Update(
p_customer_id  IN NUMBER,
p_lead_id	 IN NUMBER) IS
BEGIN


UPDATE AS_ACCESSES_ALL SET CUSTOMER_ID = p_customer_id
WHERE LEAD_ID=p_lead_id;


EXCEPTION
WHEN OTHERS THEN
NULL;

END Salesteam_Update;

PROCEDURE Notes_Update( p_lead_id IN NUMBER,
p_last_update_date   IN   DATE,
p_customer_id         IN  NUMBER
) IS
l_lead_id	number := p_lead_id;

CURSOR CUR_NOTE IS
SELECT C.NOTE_CONTEXT_ID,
C.JTF_NOTE_ID,
C.OBJECT_ID
FROM AST_NOTES_DETAILS_VL NT,
AST_NOTES_CONTEXTS_V C
WHERE NT.SOURCE_OBJECT_ID = p_lead_id
AND C.OBJECT_CODE='PARTY'
AND NT.JTF_NOTE_ID = C.JTF_NOTE_ID;

l_return_status    varchar2(1);
--l_date		date := to_date(name_in('ASTOPOVW_HEADER.last_update_date'),'DD-MON-YYYY HH24:MI:SS');

BEGIN

FOR CUR_NOTE_REC IN CUR_NOTE
LOOP
JTF_NOTES_PUB.Update_note_context(
 p_validation_level    => 100
, x_return_status   =>  l_return_status
, p_note_context_id =>  CUR_NOTE_REC.NOTE_CONTEXT_ID
, p_jtf_note_id      => CUR_NOTE_REC.JTF_NOTE_ID
, p_note_context_type_id => p_customer_id
, p_note_context_type    => 'PARTY'
, p_last_updated_by      => FND_PROFILE.Value('USER_ID')
, p_last_update_date     => p_last_update_date
, p_last_update_login    =>FND_PROFILE.Value('LOGIN_ID')
);

END LOOP;

END Notes_Update;

--Code added for R12 Ehnancement Change customer name ---End

  PROCEDURE OLIST_WORK_ITEM_ACTION
    ( p_resource_id        IN  NUMBER,
      p_language           IN  VARCHAR2 DEFAULT NULL,
      p_source_lang        IN  VARCHAR2 DEFAULT NULL,
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
    IF p_action_key = 'OPP_NEW_TASK' THEN
      Log_Mesg('Calling New Task Action Procedure');
      OLIST_NEW_TASK
        ( p_action_key       => p_action_key,
          p_resource_id      => p_resource_id,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data
        );
    ELSIF p_action_key = 'OPP_UPDATE_OPPORTUNITY' THEN
      OLIST_UPDATE_OPPORTUNITY
        ( p_action_key       => p_action_key,
          p_resource_id      => p_resource_id,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data,
          x_return_status    => l_return_status
        );
    ELSIF p_action_key = 'OPP_CLOSE_OPPORTUNITY' THEN
      OLIST_UPDATE_OPPORTUNITY
        ( p_action_key       => p_action_key,
          p_resource_id      => p_resource_id,
          p_work_action_data => p_action_input_data,
          x_uwq_actions_list => x_uwq_actions_list,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data,
          x_return_status    => l_return_status
        );
    ELSIF p_action_key = 'OPP_CREATE_NOTE' THEN
      Log_Mesg('Calling Create Note Action Procedure');
      OLIST_CREATE_NOTE
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
  END; -- End procedure OLIST_WORK_ITEM_ACTION

  PROCEDURE OLIST_NEW_TASK
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data    IN  SYSTEM.ACTION_INPUT_DATA_NST DEFAULT NULL,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    ) IS

    l_creation_date             DATE   := SYSDATE;
    l_last_update_date          DATE   := SYSDATE;
    l_last_updated_by           NUMBER := FND_PROFILE.Value('USER_ID');
    l_created_by                NUMBER := FND_PROFILE.Value('USER_ID');
    l_last_update_login         NUMBER := FND_PROFILE.Value('LOGIN_ID');

    l_task_name                 VARCHAR2(80);
    l_task_type_id              NUMBER;
    l_description               VARCHAR2(4000);
    l_owner_id                  NUMBER;
    l_customer_id               NUMBER;
    l_contact_id                NUMBER;
    l_date_type                 VARCHAR2(30);
    l_start_date                DATE;
    l_end_date                  DATE;
    l_source_object_type_code   VARCHAR2(60);
    l_source_object_id          NUMBER;
    l_source_object_name        VARCHAR2(80);
    l_phone_id                  NUMBER;
    l_address_id                NUMBER;
    l_duration                  NUMBER;
    l_duration_uom              VARCHAR2(3);
    l_status_code               VARCHAR2(30);

    l_notes                     VARCHAR2(2000);
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
	    ELSIF l_name = 'LEAD_ID' THEN
          l_source_object_id := l_value;
	    ELSIF l_name = 'LEAD_NUMBER' THEN
          l_source_object_name := l_value;
 	    ELSIF l_name = 'CONTACT_PARTY_ID' THEN
          l_contact_id := TO_NUMBER(l_value);
	    ELSIF l_name = 'PHONE_ID' THEN
          l_phone_id := l_value;
	    ELSIF l_name = 'ADDRESS_ID' THEN
          l_address_id := l_value;
        END IF;
      END IF;

      Log_Mesg('Contact Id: '||l_contact_id);
      l_source_object_type_code := 'OPPORTUNITY';
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
          l_party_id                := l_customer_id;

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

    OLIST_WORK_NODE_REFRESH
      ( p_action_key       => p_action_key,
        x_uwq_actions_list => x_uwq_actions_list
      );

  END; -- End procedure OLIST_NEW_TASK


  PROCEDURE OLIST_UPDATE_OPPORTUNITY
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data	IN  SYSTEM.ACTION_INPUT_DATA_NST DEFAULT NULL,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    ) IS

	l_list_source_type      VARCHAR2(30);

	l_creation_date         DATE := SYSDATE;
	l_last_update_date      DATE;
	l_p_last_update_date      DATE;
	l_last_updated_by       NUMBER := FND_PROFILE.Value('USER_ID');
	--created by used for creating note..
	l_created_by            NUMBER := FND_PROFILE.Value('USER_ID');
	l_last_update_login     NUMBER := FND_PROFILE.Value('LOGIN_ID');

	l_lead_number			VARCHAR2(30);
	l_lead_id				NUMBER;
	l_p_lead_id				NUMBER; --added For R12
	l_temp				VARCHAR2(1); --added For R12
	l_temp_id				NUMBER;
	l_admin_group_id         NUMBER;
	l_person_id			NUMBER;
	l_total_amount			NUMBER;
	l_p_total_amount		NUMBER;
	l_total_revenue_forecast_amt    NUMBER; --added For R12
	l_p_total_revenue_fore_amt    NUMBER;--added For R12
	l_admin_flag            VARCHAR2(1);
	l_resource_id           NUMBER;
	l_description           VARCHAR2(240);
	l_p_description         VARCHAR2(240);
	l_status_code           VARCHAR2(30);
	l_p_status_code         VARCHAR2(30);
	l_close_reason_code		VARCHAR2(30);
	l_p_close_reason_code	VARCHAR2(30);
	l_customer_id           NUMBER;
	l_old_customer_id       NUMBER; --added for R12
	l_contact_party_id	    NUMBER;
	l_address_id            NUMBER;
	l_new_address_id        NUMBER; --added for R12
	l_sales_stage_id        NUMBER;
	l_p_sales_stage_id        NUMBER;
	l_win_probability       NUMBER;
	l_p_win_probability       NUMBER;
	l_channel_code          VARCHAR2(30);
	l_p_channel_code          VARCHAR2(30);
	l_decision_date         DATE;
	l_p_decision_date         DATE;
	--code commented for R12 Enhancement --Start
	/* l_close_competitor_code VARCHAR2(30);
	l_close_competitor_id   NUMBER;
	l_close_competitor      VARCHAR2(80);
	l_p_close_competitor_id NUMBER; */
	--code commented for R12 Enhancement --End
	l_close_comment         VARCHAR2(240);
	l_p_close_comment         VARCHAR2(240);
	l_parent_project        VARCHAR2(80);
	l_freeze_flag           VARCHAR2(1);
	l_access_flag			VARCHAR2(1);
	l_currency_code 		VARCHAR2(60);
	l_vehicle_response_code 		VARCHAR2(2000);
	l_customer_budget 		NUMBER;
	l_p_currency_code 		VARCHAR2(60);
	l_p_vehicle_response_code 		VARCHAR2(200);
	l_p_customer_budget 		NUMBER;
	l_salesgroup_id         NUMBER;
	l_source_promotion_id   NUMBER;
	l_p_source_promotion_id   NUMBER;
	l_validation_level_full  	  NUMBER := 100;

	l_source_object_type_code   VARCHAR2(60);
	l_source_object_id          NUMBER;

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
	l_jtf_note_id               NUMBER;
	l_err_mesg                  VARCHAR2(500);
	l_err_mesg_temp                  VARCHAR2(500); --added for R12
	l_dataSetId                NUMBER;  --added for bug#4676975
--Code added for R12 enhancement ---Start

    l_uwq_actions_list      IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_REC_LIST;
    l_uwq_action_data_list  IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_DATA_REC_LIST;
    l_action_data           VARCHAR2(4000);

    cursor c_loc(p_cust_id in number) is select
     party_site_id from
      hz_party_sites site
      where site.party_id = p_cust_id
      and site.identifying_address_flag = 'Y';

    cursor c_prop(p_lead_id number) is select 'x'
    from PRP_PROP_OBJECTS_V
    where object_id=p_lead_id
    and object_type='OPPORTUNITY';

    cursor c_quote(p_lead_id number) is select 'x'
    from ASO_I_QUOTE_HEADERS_BALI_V
    where QUOTE_HEADER_ID in
    (select QUOTE_OBJECT_ID
    from aso_quote_related_objects_v
    where object_type_code = 'LDID'
    and object_id = p_lead_id);
--Code added for R12 enhancement ---End
  BEGIN
    Log_Mesg('Inside Update Opportunity Action');
    l_data_set_id               := NULL;
    l_prev_data_set_id          := NULL;
    l_dataSetId                 := NULL; --added for bug#4676975

    l_resource_id := p_resource_id;
    --freeze flag should not be reset corrected by removing jraj 08/22/03.

	--added for bug#4676975  --start
	FOR I IN 1.. p_work_action_data.COUNT LOOP
	  l_dataSetId      := p_work_action_data(i).dataSetId;
	END LOOP;
	--added for bug#4676975  --end

	FOR I IN 1.. p_work_action_data.COUNT LOOP
		 l_data_set_type := p_work_action_data(i).datasettype;

		 IF l_data_set_type = 'ACTION_PARAM_DATA' THEN
			l_name := p_work_action_data(i).name;
			l_value := p_work_action_data(i).value;
			l_type  := p_work_action_data(i).type;

			Log_Mesg('Action Param Data Name: '||l_name||' ('||l_value||')');
			IF l_name = 'PARTY_ID' THEN
			     l_customer_id := l_value;
		        ELSIF l_name = 'CUSTOMER_NAME' THEN

			--added for bug#4676975  --start
			     IF l_dataSetId =1 then
				  BEGIN
				        l_customer_id := l_value;
				  EXCEPTION
				  WHEN VALUE_ERROR THEN
				    x_return_status := 'E';
				   FND_MESSAGE.Set_Name('AST', 'AST_OPP_CUST_SET_CHECK');
				   FND_MSG_PUB.ADD;
				   RAISE FND_API.G_EXC_ERROR;
				  END;
			     END if;
			--added for bug#4676975  --End

			ELSIF l_name = 'LEAD_ID' THEN
			    l_p_lead_id :=	l_value;
			ELSIF l_name = 'OPPORTUNITY_NAME' THEN
			     l_description := l_value;
			     l_p_description := l_value;
			ELSIF l_name = 'STATUS_CODE' THEN
			     l_status_code := l_value;
			     l_p_status_code := l_value;
			ELSIF l_name = 'CLOSE_REASON' THEN
			     l_close_reason_code := l_value;
			     l_p_close_reason_code := l_value;
			ELSIF l_name = 'SALES_STAGE' THEN
			     l_sales_stage_id := l_value;
			     l_p_sales_stage_id := l_value;
			ELSIF l_name = 'WIN_PROBABILITY' THEN
			     l_win_probability := l_value;
			     l_p_win_probability := l_value;
			ELSIF l_name = 'SALES_CHANNEL' THEN
			     l_channel_code := l_value;
			     l_p_channel_code := l_value;
			ELSIF l_name = 'TOTAL_AMOUNT' THEN
			     l_total_amount := TO_NUMBER(l_value);
			     l_p_total_amount := TO_NUMBER(l_value);
			--Code added for R12 Enhancement --Start
			ELSIF l_name = 'FORECAST_AMOUNT' THEN
			     l_total_revenue_forecast_amt  := TO_NUMBER(l_value);
			     l_p_total_revenue_fore_amt := TO_NUMBER(l_value);
			--Code added for R12 Enhancement --End
			ELSIF l_name = 'CLOSE_DATE' THEN
			     l_decision_date := TO_DATE(l_value, 'DD-MM-YYYY HH24:MI:SS');
			     l_p_decision_date := TO_DATE(l_value, 'DD-MM-YYYY HH24:MI:SS');
			ELSIF l_name = 'SOURCE_CODE' THEN
			     l_source_promotion_id := l_value;
			     l_p_source_promotion_id := l_value;
			--code modified  for R12  enhancement --Start
			/* ELSIF l_name = 'KEY_COMPETITOR_ID' THEN
			     l_close_competitor_id := l_value;
			     l_p_close_competitor_id := l_value; */
     			--code modified  for R12  enhancement --end
			ELSIF l_name = 'ADMIN_GROUP_ID' THEN
			     l_admin_group_id := l_value;
			ELSIF l_name = 'ADMIN_FLAG' THEN
			     l_admin_flag := l_value;
			ELSIF l_name = 'MEM_GROUP_ID' THEN
			     l_salesgroup_id := l_value;
			ELSIF l_name = 'PERSON_ID' THEN
			     l_person_id := l_value;
               ELSIF l_name = 'CURRENCY_CODE' THEN
		          l_p_currency_code := l_value;
		          l_currency_code := l_value;
               ELSIF l_name = 'VEHICLE_RESPONSE_CODE' THEN
		          l_p_vehicle_response_code := l_value;
		          l_vehicle_response_code := l_value;
               ELSIF l_name = 'CUSTOMER_BUDGET' THEN
		          l_p_customer_budget := l_value;
		          l_customer_budget := l_value;
/**
			ELSIF l_name = 'LAST_UPDATE_DATE' THEN
			     l_last_update_date := TO_DATE(l_value, 'dd/mon/yyyy hh24:mi:ss');
			     l_p_last_update_date := TO_DATE(l_value, 'dd/mon/yyyy hh24:mi:ss');
**/
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
		END IF;
	END LOOP;
    Log_Mesg('Get Parameter Data Loop Ended');

    Log_Mesg('Looping to get Work Item Data only: ' || p_work_action_data.COUNT);
    FOR I IN 1.. p_work_action_data.COUNT LOOP
      l_data_set_type := p_work_action_data(i).datasettype;
      l_data_set_id   := p_work_action_data(i).dataSetID;

	  IF l_data_set_type = 'WORK_ITEM_DATA' THEN
	    l_name := p_work_action_data(i).name;
	    l_value := p_work_action_data(i).value;
	    l_type  := p_work_action_data(i).type;

        Log_Mesg('Work Data Name: '||l_name||' ('||l_value||')');
		IF l_name = 'LIST_SOURCE_TYPE' THEN
	      l_list_source_type := l_value;
	    ELSIF l_name = 'LEAD_ID' THEN
          l_lead_id := l_value;
	    ELSIF l_name = 'LEAD_NUMBER' THEN
          l_lead_number := l_value;
 	    ELSIF l_name = 'PARTY_ID' THEN
         -- l_customer_id := l_value; --Commented for R12
	 l_old_customer_id := l_value; --Added for R12

	--added for bug#4676975   --Start
	 if l_dataSetId >1 then
	 l_customer_id :=  l_old_customer_id; --for test needs to be removed
	 end if;
	--added for bug#4676975   --End

 	    ELSIF l_name = 'CONTACT_PARTY_ID' THEN
          l_contact_party_id := l_value;
 	    ELSIF l_name = 'DESCRIPTION' AND
              l_p_description IS NULL THEN
          l_description := l_value;
 	    ELSIF l_name = 'STATUS_CODE' AND
              l_p_status_code IS NULL THEN
          l_status_code := l_value;
 	    ELSIF l_name = 'CLOSE_REASON' AND
              l_p_close_reason_code IS NULL THEN
          l_close_reason_code := l_value;
 	    ELSIF l_name = 'SOURCE_PROMOTION_ID' AND
              l_p_source_promotion_id IS NULL THEN
          l_source_promotion_id := l_value;
 	    ELSIF l_name = 'SALES_STAGE_ID' AND
              l_p_sales_stage_id IS NULL THEN
          l_sales_stage_id := l_value;
 	    ELSIF l_name = 'WIN_PROBABILITY' AND
              l_p_win_probability IS NULL THEN
          l_win_probability := l_value;
 	    ELSIF l_name = 'TOTAL_AMOUNT' AND
              l_p_total_amount IS NULL THEN
          l_total_amount := l_value;
	--Code added for R12 Enhancement ---Start
 	    ELSIF l_name = 'FORECAST_AMOUNT' AND
              l_p_total_revenue_fore_amt IS NULL THEN
          l_total_revenue_forecast_amt   := l_value;
	--Code added for R12 Enhancement ---End

 	    ELSIF l_name = 'CHANNEL_CODE' AND
              l_p_channel_code IS NULL THEN
          l_channel_code := l_value;
 	    ELSIF l_name = 'DECISION_DATE' AND
              l_p_decision_date IS NULL THEN
	     l_decision_date := TO_DATE(l_value, 'DD-MM-YYYY HH24:MI:SS');
 	    ELSIF l_name = 'LAST_UPDATE_DATE' AND
              l_p_last_update_date IS NULL THEN
          l_last_update_date := TO_DATE(l_value, 'DD-MM-YYYY HH24:MI:SS');
-- 	    ELSIF l_name = 'LAST_UPDATED_BY' THEN
--          l_last_updated_by := l_value;
 	    ELSIF l_name = 'ADDRESS_ID' THEN
          l_address_id := l_value;
 	    ELSIF l_name = 'PARENT_PROJECT' THEN
          l_parent_project := l_value;
 	    ELSIF l_name = 'CLOSE_COMMENT' THEN
          l_close_comment := l_value;
 	  --code modified for R12 enhancement --Start
	/*    ELSIF l_name = 'CLOSE_COMPETITOR_CODE' THEN
            l_close_competitor_code := l_value;
 	    ELSIF l_name = 'CLOSE_COMPETITOR_ID' AND
		   l_p_close_competitor_id IS NULL THEN
          l_close_competitor_id := TO_NUMBER(l_value);
            ELSIF l_name = 'CLOSE_COMPETITOR' THEN
          l_close_competitor := l_value; */
	  --code modified for R12 enhancement --end
         ELSIF l_name = 'CURRENCY_CODE' AND
	     l_p_currency_code is null THEN
	     l_currency_code := l_value;
         ELSIF l_name = 'VEHICLE_RESPONSE_CODE' AND
           l_p_vehicle_response_code is null THEN
	   l_vehicle_response_code := l_value;
         ELSIF l_name = 'CUSTOMER_BUDGET' AND
           l_p_customer_budget is null THEN
	   l_customer_budget := l_value;
        END IF;
	END IF;


 --code added for R12 enhancement --Start
 if l_customer_id is not null and
           l_old_customer_id <> l_customer_id then


   open c_loc(l_customer_id);
    fetch c_loc into l_new_address_id;
    l_address_id := l_new_address_id;
    close c_loc;

    open c_prop(l_lead_id);
    fetch c_prop into l_temp;
    close c_prop;

    open c_quote(l_lead_id);
    fetch c_quote into l_temp;
    close c_quote;

    if l_temp is not null then
     l_return_status := 'E';
    end if;
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        FND_MESSAGE.Set_Name('ASN', 'ASN_PROPOSALS_QUOTES_ERR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

 end if;
   --code added for R12 enhancement --End

	--Bug # 3516066
      Log_Mesg('Start parameter validation');
      --code modified for R12 enhancement --Start
      /*
      IF l_name = 'CLOSE_COMPETITOR_ID' AND
         NVL(FND_PROFILE.Value('AS_COMPETITOR_REQUIRED'), 'N') = 'Y' AND
         l_p_close_competitor_id IS NULL THEN
        l_return_status := 'E';
      END IF;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        FND_MESSAGE.Set_Name('AS', 'API_CLOSE_COMPETITOR_REQUIRED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;  */
--code modified for R12 enhancement --end
      Log_Mesg('End parameter validation');
	--End of bug # 3516066

	IF l_prev_data_set_id <> l_data_set_id OR
		i = p_work_action_data.COUNT THEN

		Log_Mesg('Before has_updateOpportunityAccess ');
		AST_ACCESS.has_updateOpportunityAccess
		(
			p_lead_id   => 	l_lead_id,
			p_admin_flag      => l_admin_flag,
			p_admin_group_id  => l_admin_group_id,
			p_person_id       => l_person_id,
			p_resource_id     => p_resource_id,
			x_return_status	=> l_return_status,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_msg_data
		);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  x_return_status := l_return_status;
		  x_msg_count     := l_msg_count;
		  x_msg_data      := l_msg_data;
		  RAISE FND_API.G_EXC_ERROR;
		END IF;




	   AST_UWQ_WRAPPER_PKG.UPDATE_OPPORTUNITY
	     ( p_admin_group_id         => l_admin_group_id,
	       p_admin_flag             => l_admin_flag,
	       p_resource_id            => l_resource_id,
	       p_last_update_date       => l_last_update_date,
	       p_lead_id                => l_lead_id,
	       p_lead_number            => l_lead_number,
	       p_description            => l_description,
	       p_status_code            => l_status_code,
		  p_close_reason_code		 => l_close_reason_code,
	       p_source_promotion_id	 => l_source_promotion_id,
	       p_customer_id            => l_customer_id,
		  p_contact_party_id	     => l_contact_party_id,
	       p_address_id             => l_address_id,
	       p_sales_stage_id         => l_sales_stage_id,
	       p_win_probability        => l_win_probability,
	       p_total_amount           => l_total_amount,
	       p_total_revenue_forecast_amt => l_total_revenue_forecast_amt  ,--Code added for R12
	       p_channel_code           => l_channel_code,
	       p_decision_date          => l_decision_date,
	       p_currency_code          => l_currency_code,
	       p_vehicle_response_code  => l_vehicle_response_code,
	       p_customer_budget        => l_customer_budget,
	     --Code commented for R12 Enhancement --Start
	  /*     p_close_competitor_code  => l_close_competitor_code,
	       p_close_competitor_id    => l_p_close_competitor_id,--Earlier l_close_competitor_id was passed. Bug # 3516066
	       p_close_competitor       => l_close_competitor, */
	       --Code commented for R12 Enhancement --End
	       p_close_comment          => l_close_comment,
	       p_parent_project         => l_parent_project,
	       p_freeze_flag            => l_freeze_flag,
	       p_called_node            => l_called_node,
	       x_return_status          => l_return_status,
	       x_msg_count              => l_msg_count,
	       x_msg_data               => l_msg_data,
	       x_lead_id                => l_temp_id
	     );

	   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     x_return_status := l_return_status;
	     x_msg_count     := l_msg_count;
	     x_msg_data      := l_msg_data;
	     RAISE FND_API.G_EXC_ERROR;
	   ELSE
	  --Code added for R12 enhancement ---Start
	   if l_customer_id is not null and
           l_old_customer_id <> l_customer_id then
           null;
    	   Contacts_Delete(
           p_lead_id => l_lead_id,
           p_resource_id => l_resource_id,
           p_admin_flag => l_admin_flag,
           p_admin_group_id => l_admin_group_id,
           x_msg_count => l_msg_count,
           x_msg_data => l_msg_data,
           x_return_status => l_return_status);

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	       x_return_status := l_return_status;
	       x_msg_count     := l_msg_count;
	       x_msg_data      := l_msg_data;
	       RAISE FND_API.G_EXC_ERROR;
    	    END IF;

           Salesteam_Update(p_customer_id => l_customer_id,
           p_lead_id=> l_lead_id);

           Notes_Update(
           p_lead_id =>l_lead_id,
           p_last_update_date => l_last_update_date,
           p_customer_id => l_customer_id
           );
        end if;
	--Code added for R12 enhancement ---Start

	     x_return_status := l_return_status;
	     x_msg_count     := l_msg_count;
	     x_msg_data      := l_msg_data;
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
	         p_entered_date       => SYSDATE,
	         p_last_update_date   => SYSDATE,
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
	       RAISE FND_API.G_EXC_ERROR;
	     ELSE
	       x_return_status := l_return_status;
	       x_msg_count     := l_msg_count;
	       x_msg_data      := l_msg_data;
	     END IF;
	   ELSE
	     Log_Mesg('User did not enter any note to create.');
	   END IF;
	END IF;
    l_prev_data_set_id := l_data_set_id;
  END LOOP;

  --Code added for R12 enhancement ---Start

 if l_customer_id is not null and
	  l_old_customer_id <> l_customer_id then

   l_uwq_actions_list(1).uwq_action_key := 'UWQ_WORK_DETAILS_REFRESH';
    l_uwq_actions_list(1).action_data    := '';
    l_uwq_actions_list(1).dialog_style   := 2;
    l_uwq_actions_list(1).message        := 'Please note, changing the customer for this opportunity will update the
address, remove all contacts and allow the sales team to be reassigned.';
    IEU_UWQ_WORK_PANEL_PUB.SET_UWQ_ACTIONS(l_uwq_actions_list, x_uwq_actions_list);
else
	OLIST_WORK_NODE_REFRESH
  ( p_action_key       => p_action_key,
	    p_lead_id          => l_lead_id,
	    x_uwq_actions_list => x_uwq_actions_list
  );
      end if;
--Code added for R12 enhancement ---End

 END; -- End procedure OLIST_UPDATE_OPPORTUNITY

  PROCEDURE OLIST_CREATE_NOTE
    ( p_action_key          IN  VARCHAR2,
      p_resource_id         IN  NUMBER,
      p_work_action_data    IN  SYSTEM.ACTION_INPUT_DATA_NST DEFAULT NULL,
      x_uwq_actions_list    OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2
    ) IS

    l_creation_date             DATE   := SYSDATE;
    l_last_update_date          DATE   := SYSDATE;
    l_last_updated_by           NUMBER := FND_PROFILE.Value('USER_ID');
    l_created_by                NUMBER := FND_PROFILE.Value('USER_ID');
    l_last_update_login         NUMBER := FND_PROFILE.Value('LOGIN_ID');

    l_customer_id               NUMBER;
    l_source_object_type_code   VARCHAR2(60);
    l_source_object_id          NUMBER;
    l_source_object_name        VARCHAR2(80);

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
	    ELSIF l_name = 'LEAD_ID' THEN
          l_source_object_id := l_value;
        END IF;
      END IF;

      Log_Mesg('Object Type Code: '||l_source_object_type_code);
      Log_Mesg('Object Type id: '||l_source_object_id);

      IF l_prev_data_set_id <> l_data_set_id OR
         i = p_work_action_data.COUNT THEN

        IF l_notes IS NOT NULL THEN
		  l_source_object_type_code := 'OPPORTUNITY';
          l_party_id                := l_customer_id;

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

    OLIST_WORK_NODE_REFRESH
      ( p_action_key       => p_action_key,
        x_uwq_actions_list => x_uwq_actions_list
      );

  END; -- End procedure OLIST_CREATE_NOTE

END; -- Package Body AST_UWQ_OLIST_WORK_ACTION

/
