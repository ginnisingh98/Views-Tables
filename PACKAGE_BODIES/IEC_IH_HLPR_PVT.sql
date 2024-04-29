--------------------------------------------------------
--  DDL for Package Body IEC_IH_HLPR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_IH_HLPR_PVT" AS
/* $Header: IECVIHB.pls 115.26 2004/05/24 20:39:49 minwang noship $ */

PROCEDURE Log
(
  p_method_name   IN VARCHAR2,
  p_sql_errmsg    IN VARCHAR2
)
IS
  l_error_msg VARCHAR2(2048);
BEGIN

  IEC_OCS_LOG_PVT.LOG_INTERNAL_PLSQL_ERROR
  (
    'IEC_IH_HLPR_PVT',
     p_method_name,
     '',
     p_sql_errmsg,
     l_error_msg
  );

END Log;

-- Sub-Program Unit Declarations
-----------------------------++++++-------------------------------
--
--  API name    : CREATE_INTERACTION
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Called by dial server to record IH related information
--                for Advanced Outbound Predicitive dialing.
--
--  Version     : Initial version 1.0
--
-----------------------------++++++-------------------------------
PROCEDURE CREATE_INTERACTION
(
  P_MEDIA_ID      IN  NUMBER,
  P_PARTY_ID 	    IN	NUMBER,
  P_START_TIME	  IN	DATE,
  P_END_TIME		  IN	DATE,
  P_OUTCOME_ID	  IN	NUMBER,
  P_REASON_ID	    IN	NUMBER,
  P_RESULT_ID	    IN	NUMBER
)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_api_version     CONSTANT NUMBER   := 1.0;
  l_init_msg_list		VARCHAR2(1);
  l_commit			    VARCHAR2(1);
  l_user_id			    NUMBER;
  l_return_status		VARCHAR2(1);
  l_msg_count			  NUMBER;
  l_msg_data			  VARCHAR2(2000);

  l_resource_id     NUMBER            := 0;

BEGIN
  l_init_msg_list		:=FND_API.G_TRUE;
  l_commit			    :=FND_API.G_TRUE;
  l_user_id			    := NVL(FND_GLOBAL.user_id,-1);

  IF(L_INTERACTION_INITIAL = 0 ) THEN

	  l_interaction_rec.interaction_id := NULL;
	  l_interaction_rec.reference_form := NULL;
	  l_interaction_rec.follow_up_action := NULL;
	  l_interaction_rec.inter_interaction_duration := NULL;
	  l_interaction_rec.non_productive_time_amount := NULL;
	  l_interaction_rec.preview_time_amount := NULL;
	  l_interaction_rec.productive_time_amount := NULL;
	  l_interaction_rec.wrapUp_time_amount := NULL;
	  l_interaction_rec.handler_id := 545;
	  l_interaction_rec.script_id := NULL;

    begin
     	select resource_id into l_resource_id
        from jtf_rs_resource_extns
        where user_name = 'IECAOUSER';

      Exception
        When NO_DATA_FOUND then
          l_resource_id := 0;
    End;

	  l_interaction_rec.resource_id := l_resource_id;

	  l_interaction_rec.parent_id := NULL;
	  l_interaction_rec.object_id := NULL;
	  l_interaction_rec.object_type := NULL;
	  l_interaction_rec.source_code_id := NULL;
	  l_interaction_rec.source_code := NULL;
	  l_interaction_rec.attribute1 := NULL;
	  l_interaction_rec.attribute2 := NULL;
	  l_interaction_rec.attribute3 := NULL;
	  l_interaction_rec.attribute4 := NULL;
	  l_interaction_rec.attribute5 := NULL;
	  l_interaction_rec.attribute6 := NULL;
	  l_interaction_rec.attribute7 := NULL;
	  l_interaction_rec.attribute8 := NULL;
	  l_interaction_rec.attribute9 := NULL;
	  l_interaction_rec.attribute10 := NULL;
	  l_interaction_rec.attribute11 := NULL;
	  l_interaction_rec.attribute12 := NULL;
	  l_interaction_rec.attribute13 := NULL;
	  l_interaction_rec.attribute14 := NULL;
	  l_interaction_rec.attribute15 := NULL;
	  l_interaction_rec.attribute_category := NULL;
    l_activities_tbl(1).activity_id := NULL;
	  l_activities_tbl(1).cust_account_id := NULL;
	  l_activities_tbl(1).cust_org_id := NULL;
	  l_activities_tbl(1).role := NULL;
	  l_activities_tbl(1).task_id := NULL;
	  l_activities_tbl(1).doc_id := NULL;
	  l_activities_tbl(1).doc_ref := NULL;
    l_activities_tbl(1).doc_source_object_name := NULL;
	  l_activities_tbl(1).media_id := NULL;
    l_activities_tbl(1).interaction_id := NULL;
	  l_activities_tbl(1).description := NULL;
	  l_activities_tbl(1).action_id := 51;
	  l_activities_tbl(1).interaction_action_type := NULL;
	  l_activities_tbl(1).object_id := NULL;
	  l_activities_tbl(1).object_type := NULL;
	  l_activities_tbl(1).source_code_id := NULL;
	  l_activities_tbl(1).source_code := NULL;
    l_activities_tbl(1).script_trans_id := NULL;

	  L_INTERACTION_INITIAL := 1;

  END IF;

  l_interaction_rec.duration := null;
	l_interaction_rec.end_date_time := p_end_time;
	l_interaction_rec.start_date_time := p_start_time;
	l_interaction_rec.outcome_id := p_outcome_id;
	l_interaction_rec.result_id := p_result_id;
	l_interaction_rec.reason_id := p_reason_id;

	l_interaction_rec.party_id := p_party_id;
	l_activities_tbl(1).duration := null;
	l_activities_tbl(1).end_date_time := p_end_time;
	l_activities_tbl(1).start_date_time := p_start_time;
	l_activities_tbl(1).action_item_id := 25;
	l_activities_tbl(1).outcome_id := p_outcome_id;
	l_activities_tbl(1).result_id := p_result_id;
	l_activities_tbl(1).reason_id := p_reason_id;
	l_activities_tbl(1).media_id := P_MEDIA_ID;

  JTF_IH_PUB.Create_Interaction
  (
      p_api_version => l_api_version,
      p_init_msg_list => l_init_msg_list,
      p_commit => l_commit,
      p_user_id => l_user_id,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
  	  p_interaction_rec => l_interaction_rec,
      p_activities => l_activities_tbl
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

		-- No point in trying to create the others.
    -- the only thing we can do here is to log an error message
    LOG('CREATE_INTERACTION', l_msg_data);

  END IF;

  commit;

END CREATE_INTERACTION;

-----------------------------++++++-------------------------------
--
--  API name    : CREATE_MILCS
--  Type        : Private
--
--  Version     : Initial version 1.0
--
-----------------------------++++++-------------------------------

PROCEDURE CREATE_MILCS
(
  P_MEDIA_ID      IN  NUMBER,
	P_MILCS_TYPE    IN  NUMBER,
	P_START_TIME    IN  DATE,
  P_END_TIME		  IN	DATE
)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_api_version     CONSTANT NUMBER   := 1.0;
  l_init_msg_list		VARCHAR2(1);
  l_commit			    VARCHAR2(1);
  l_user_id			    NUMBER;
  l_return_status		VARCHAR2(1);
  l_msg_count			  NUMBER;
  l_msg_data			  VARCHAR2(2000);

  l_resource_id     NUMBER            := 0;

BEGIN
  l_init_msg_list		:= FND_API.G_TRUE;
  l_commit			    := FND_API.G_TRUE;
  l_user_id			    := NVL(FND_GLOBAL.user_id,-1);

  IF (L_MEDIA_LC_INITIAL = 0) THEN

    begin
     	select resource_id into l_resource_id
        from jtf_rs_resource_extns
        where user_name = 'IECAOUSER';

      Exception
        When NO_DATA_FOUND then
          l_resource_id := 0;
    End;

    l_media_lc_rec.type_type := 'TELEPHONY, OUTBOUND';
    l_media_lc_rec.type_id := NULL;
    l_media_lc_rec.milcs_id := NULL;
    l_media_lc_rec.handler_id := 545;
    l_media_lc_rec.resource_id := l_resource_id;
    l_media_lc_rec.milcs_code := NULL;

    L_MEDIA_LC_INITIAL := 1;

  END IF;

  l_media_lc_rec.media_id := P_MEDIA_ID;
  l_media_lc_rec.milcs_type_id := P_MILCS_TYPE;
  l_media_lc_rec.start_date_time := P_START_TIME;
  l_media_lc_rec.end_date_time := P_END_TIME;
  l_media_lc_rec.duration := null;

  JTF_IH_PUB.Create_MediaLifecycle
	(
      p_api_version => l_api_version,
      p_init_msg_list => l_init_msg_list,
    	p_commit => l_commit,
      p_user_id => l_user_id,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      p_media_lc_rec => l_media_lc_rec
	);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

		-- No point in trying to create the others.
    -- the only thing we can do here is to log an error message
    LOG('CREATE_MILCS', l_msg_data);

  END IF;

  commit;

END CREATE_MILCS;

-----------------------------++++++-------------------------------
--
--  API name    : UPDATE_CLOSE_MEDIA_ITEM
--  Type        : Private
--
--  Version     : Initial version 1.0
--
-----------------------------++++++-------------------------------
PROCEDURE UPDATE_CLOSE_MEDIA_ITEM
(
  P_MEDIA_ID      IN  NUMBER,
  P_SUBSET_ID     IN  NUMBER,
  P_SVR_GROUP_ID  IN  NUMBER,
  P_START_TIME	  IN	DATE,
  P_END_TIME		  IN	DATE,
  P_ADDRESS	      IN  VARCHAR2,
  P_ABANDON_FLAG  IN  VARCHAR2,
  P_HARD_CLOSE    IN  VARCHAR2
)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_commit			    VARCHAR2(1);

  l_return_status		VARCHAR2(1);
  l_msg_count			  NUMBER;
  l_msg_data			  VARCHAR2(2000);

BEGIN
  l_commit			    := FND_API.G_TRUE;

  JTF_IH_IEC_PVT.CLOSE_AO_CALL
  (
        p_Media_id => P_MEDIA_ID,
        p_Hard_Close =>P_HARD_CLOSE,
        p_source_item_id => P_SUBSET_ID,
        p_address => P_ADDRESS,
        p_start_date_time => P_START_TIME,
        p_end_date_time => P_END_TIME,
				p_duration => null,
        p_media_abandon_flag => P_ABANDON_FLAG,
        p_Server_Group_ID => P_SVR_GROUP_ID,
        x_Commit => l_commit,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

    -- dbms_output.put_line(l_msg_data);

		-- No point in trying to create the others.
    -- the only thing we can do here is to log an error message
    LOG('UPDATE_CLOSE_MEDIA_ITEM', l_msg_data);

  END IF;

  commit;

END UPDATE_CLOSE_MEDIA_ITEM;


END IEC_IH_HLPR_PVT;

/
