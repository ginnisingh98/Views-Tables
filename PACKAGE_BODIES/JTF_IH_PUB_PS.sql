--------------------------------------------------------
--  DDL for Package Body JTF_IH_PUB_PS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_PUB_PS" AS
/* $Header: JTFIHPSB.pls 115.10 2000/02/29 17:58:35 pkm ship     $ */
	G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_IH_PUB';

-- Jean Zhu add Utility Validate_StartEnd_Date
  PROCEDURE Validate_StartEnd_Date
  ( p_api_name          IN      VARCHAR2,
	p_start_date_time   IN      DATE,
	p_end_date_time		IN      DATE,
    x_return_status     IN OUT  VARCHAR2
  );

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Validate_StartEnd_Date
  ( p_api_name          IN      VARCHAR2,
	p_start_date_time   IN      DATE,
	p_end_date_time		IN      DATE,
    x_return_status     IN OUT  VARCHAR2
  )
  IS
  BEGIN
	IF((p_start_date_time IS NOT NULL) AND (p_end_date_time IS NOT NULL) AND
		(p_end_date_time - p_start_date_time < 0) )THEN
			----DBMS_OUTPUT.PUT_LINE('end_date is less than start_date in JTF_IH_PUB_PS.Validate_StartEnd_Date');
			x_return_status := fnd_api.g_ret_sts_error;
            jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_end_date_time),
					    'end_date_time');
	END IF;
  END Validate_StartEnd_Date;


  PROCEDURE Validate_Interaction_Record
  ( p_api_name          IN      VARCHAR2,
    p_int_val_rec       IN      interaction_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     IN OUT  VARCHAR2
  );

--  End Utilities Declaration
-- Begin Utilities Definition

  PROCEDURE Validate_Interaction_Record
  ( p_api_name          IN      VARCHAR2,
    p_int_val_rec       IN      interaction_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     IN OUT  VARCHAR2
  )
  IS
    l_count NUMBER := 0;
  BEGIN
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

  IF ((p_int_val_rec.handler_id IS NOT NULL) AND (p_int_val_rec.handler_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM fnd_application
         WHERE application_id = p_int_val_rec.handler_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.handler_id),
					    'Handler_id');
					 RETURN;
					 END IF;
       END;
   ELSE
   	   x_return_status := fnd_api.g_ret_sts_error;
       jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.handler_id),
					    'handler_id');
			 RETURN;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate handler_id in JTF_IH_PUB_PS.Validate_Interaction_Record');

   l_count := 0;
   IF ((p_int_val_rec.party_id IS NOT NULL) AND (p_int_val_rec.party_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM hz_parties
         WHERE party_id = p_int_val_rec.party_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.party_id),
					    'party_id');
					 RETURN;
					 END IF;
       END;
	ELSE
   	   x_return_status := fnd_api.g_ret_sts_error;
       jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.party_id),
					    'party_id');
			 RETURN;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate party_id in JTF_IH_PUB_PS.Validate_Interaction_Record');

   l_count := 0;
   IF ((p_int_val_rec.resource_id IS NOT NULL) AND (p_int_val_rec.resource_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM jtf_rs_resource_extns
         WHERE resource_id = p_int_val_rec.resource_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.resource_id),
					    'resource_id');
			 RETURN;
			 END IF;
       END;
	ELSE
   	   x_return_status := fnd_api.g_ret_sts_error;
       jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.resource_id),
					    'resource_id');
			RETURN;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate resource_id in JTF_IH_PUB_PS.Validate_Interaction_Record');

   l_count := 0;
   IF ((p_int_val_rec.outcome_id IS NOT NULL) AND (p_int_val_rec.outcome_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM jtf_ih_outcomes_B
         WHERE outcome_id = p_int_val_rec.outcome_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.outcome_id),
					    'outcome_id');
					 RETURN;
					 END IF;

   	   END;
	END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate outcome_id in JTF_IH_PUB_PS.Validate_Interaction_Record');

   l_count := 0;
   IF ((p_int_val_rec.result_id IS NOT NULL) AND (p_int_val_rec.result_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM jtf_ih_results_B
         WHERE result_id = p_int_val_rec.result_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.result_id),
					    'result_id');
					 RETURN;
					 END IF;

       END;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate result_id in JTF_IH_PUB_PS.Validate_Interaction_Record');

   l_count := 0;
   IF ((p_int_val_rec.reason_id IS NOT NULL) AND (p_int_val_rec.reason_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM jtf_ih_reasons_B
         WHERE reason_id = p_int_val_rec.reason_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.reason_id),
					    'reason_id');
					 RETURN;
					 END IF;
       END;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate reason_id in JTF_IH_PUB_PS.Validate_Interaction_Record');

   l_count := 0;
   IF ((p_int_val_rec.script_id IS NOT NULL) AND (p_int_val_rec.script_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM jtf_ih_scripts
         WHERE script_id = p_int_val_rec.script_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.script_id),
					    'Script_id');
					 RETURN;
					 END IF;
       END;
   END IF;
	 ----DBMS_OUTPUT.PUT_LINE('PAST Validate script_id in JTF_IH_PUB_PS.Validate_Interaction_Record');

-- Add by Jean Zhu to validate the source_code_id
   l_count := 0;
   IF ((p_int_val_rec.source_code_id IS NOT NULL) AND (p_int_val_rec.source_code_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM ams_source_codes
         WHERE source_code_id = p_int_val_rec.source_code_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.source_code_id),
					    'source_code_id');
					 RETURN;
					 END IF;
      END;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate source_code_id in JTF_IH_PUB_PS.Validate_Interaction_Record');

   l_count := 0;
   IF ((p_int_val_rec.parent_id IS NOT NULL) AND (p_int_val_rec.parent_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM jtf_ih_interactions
         WHERE interaction_id = p_int_val_rec.parent_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.parent_id),
					    'interaction_id');
					 RETURN;
					 END IF;
      END;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate parent_id in JTF_IH_PUB_PS.Validate_Interaction_Record');

   -- Validate descriptive flexfield values
   ----------------------------------------
   IF ((p_int_val_rec.attribute1 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute2 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute3 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute4 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute5 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute6 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute7 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute8 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute9 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute10 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute11 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute12 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute13 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute14 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute15 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute_category <> fnd_api.g_miss_char)) THEN
        jtf_ih_core_util_pvt.validate_desc_flex
        ( p_api_name            => p_api_name,
          p_desc_flex_name      => 'JTF_IH',
          p_column_name1        => 'ATTRIBUTE1',
          p_column_name2        => 'ATTRIBUTE2',
          p_column_name3        => 'ATTRIBUTE3',
          p_column_name4        => 'ATTRIBUTE4',
          p_column_name5        => 'ATTRIBUTE5',
          p_column_name6        => 'ATTRIBUTE6',
          p_column_name7        => 'ATTRIBUTE7',
          p_column_name8        => 'ATTRIBUTE8',
          p_column_name9        => 'ATTRIBUTE9',
          p_column_name10       => 'ATTRIBUTE10',
          p_column_name11       => 'ATTRIBUTE11',
          p_column_name12       => 'ATTRIBUTE12',
          p_column_name13       => 'ATTRIBUTE13',
          p_column_name14       => 'ATTRIBUTE14',
          p_column_name15       => 'ATTRIBUTE15',
          p_column_value1       => p_int_val_rec.attribute1,
          p_column_value2       => p_int_val_rec.attribute2,
          p_column_value3       => p_int_val_rec.attribute3,
          p_column_value4       => p_int_val_rec.attribute4,
          p_column_value5       => p_int_val_rec.attribute5,
          p_column_value6       => p_int_val_rec.attribute6,
          p_column_value7       => p_int_val_rec.attribute7,
          p_column_value8       => p_int_val_rec.attribute8,
          p_column_value9       => p_int_val_rec.attribute9,
          p_column_value10      => p_int_val_rec.attribute10,
          p_column_value11      => p_int_val_rec.attribute11,
          p_column_value12      => p_int_val_rec.attribute12,
          p_column_value13      => p_int_val_rec.attribute13,
          p_column_value14      => p_int_val_rec.attribute14,
          p_column_value15      => p_int_val_rec.attribute15,
          p_context_value       => p_int_val_rec.attribute_category,
          p_resp_appl_id        => p_resp_appl_id,
          p_resp_id             => p_resp_id,
          x_return_status       => x_return_status);
      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
         RETURN;
      END IF;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate flexfields in JTF_IH_PUB_PS.Validate_Interaction_Record');
  END Validate_Interaction_Record;


  PROCEDURE Default_Interaction_Record  (x_interaction     IN OUT  interaction_rec_type);

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Default_Interaction_Record  (x_interaction     IN OUT  interaction_rec_type)
  IS
	BEGIN
		if (x_interaction.handler_id = fnd_api.g_miss_num)then
			x_interaction.handler_id :=0;
		end if;
			if (x_interaction.script_id = fnd_api.g_miss_num)then
			x_interaction.script_id :=0;
		end if;

		if (x_interaction.result_id = fnd_api.g_miss_num)then
			x_interaction.result_id :=0;
		end if;

		if (x_interaction.reason_id = fnd_api.g_miss_num)then
			x_interaction.reason_id :=0;
		end if;

		if (x_interaction.resource_id = fnd_api.g_miss_num)then
			x_interaction.resource_id :=0;
		end if;

		if (x_interaction.party_id = fnd_api.g_miss_num)then
			x_interaction.party_id :=0;
		end if;

		if (x_interaction.object_id = fnd_api.g_miss_num)then
			x_interaction.object_id :=0;
		end if;
		if (x_interaction.source_code_id = fnd_api.g_miss_num)then
			x_interaction.source_code_id :=0;
		end if;
	END;

  PROCEDURE Default_activity_table  (x_activities     IN OUT  activity_tbl_type);

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Default_activity_table  (x_activities     IN OUT  activity_tbl_type)
  IS
	BEGIN

		for  idx in 1 .. x_activities.count loop
			if (x_activities(idx).task_id = fnd_api.g_miss_num)then
				x_activities(idx).task_id :=0;
			end if;
			if (x_activities(idx).doc_id = fnd_api.g_miss_num)then
				x_activities(idx).doc_id :=0;
			end if;

			if (x_activities(idx).action_item_id = fnd_api.g_miss_num)then
				x_activities(idx).action_item_id :=0;
			end if;

			if (x_activities(idx).outcome_id = fnd_api.g_miss_num)then
				x_activities(idx).outcome_id :=0;
			end if;

			if (x_activities(idx).result_id = fnd_api.g_miss_num)then
				x_activities(idx).result_id :=0;
			end if;
			if (x_activities(idx).reason_id = fnd_api.g_miss_num)then
				x_activities(idx).reason_id :=0;
			end if;
			if (x_activities(idx).object_id = fnd_api.g_miss_num)then
				x_activities(idx).object_id :=0;
			end if;
			if (x_activities(idx).source_code_id = fnd_api.g_miss_num)then
				x_activities(idx).source_code_id:=0;
			end if;

		end loop;
  END;


-- Jean Zhu add Utility Validate_Activity_Record

PROCEDURE Validate_Activity_Record
  ( p_api_name          IN      VARCHAR2,
    p_act_val_rec       IN      activity_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     IN OUT  VARCHAR2
  );

--  End Utilities Declaration
-- Begin Utilities Definition

  PROCEDURE Validate_Activity_Record
  ( p_api_name          IN      VARCHAR2,
    p_act_val_rec       IN      activity_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     IN OUT  VARCHAR2
  )
  IS
    l_count NUMBER := 0;
  BEGIN
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

  IF ((p_act_val_rec.interaction_id IS NOT NULL) AND (p_act_val_rec.interaction_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM jtf_ih_interactions
         WHERE interaction_id = p_act_val_rec.interaction_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.interaction_id),
					    'interaction_id');
					 RETURN;
					 END IF;
       END;
   ELSE
   	   x_return_status := fnd_api.g_ret_sts_error;
       jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.interaction_id),
					    'interaction_id');
			 RETURN;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate interaction_id in JTF_IH_PUB_PS.Validate_Activity_Record');

   l_count := 0;
   IF ((p_act_val_rec.action_item_id IS NOT NULL) AND (p_act_val_rec.action_item_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM jtf_ih_action_items_b
         WHERE action_item_id = p_act_val_rec.action_item_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.action_item_id),
					    'action_item_id');
					 RETURN;
					 END IF;
       END;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate action_item_id in JTF_IH_PUB_PS.Validate_Activity_Record');

   l_count := 0;
   IF ((p_act_val_rec.outcome_id IS NOT NULL) AND (p_act_val_rec.outcome_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM jtf_ih_outcomes_B
         WHERE outcome_id = p_act_val_rec.outcome_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.outcome_id),
					    'outcome_id');
					 RETURN;
					 END IF;

   	   END;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate outcome_id in JTF_IH_PUB_PS.Validate_Activity_Record');


   l_count := 0;
   IF ((p_act_val_rec.action_id IS NOT NULL) AND (p_act_val_rec.action_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM jtf_ih_actions_b
         WHERE action_id = p_act_val_rec.action_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.action_id),
					    'action_id');
					 RETURN;
					 END IF;
      END;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate action_id in JTF_IH_PUB_PS.Validate_Activity_Record');
   l_count := 0;
   IF ((p_act_val_rec.result_id IS NOT NULL) AND (p_act_val_rec.result_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM jtf_ih_results_B
         WHERE result_id = p_act_val_rec.result_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.result_id),
					    'result_id');
					 RETURN;
					 END IF;

       END;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate result_id in JTF_IH_PUB_PS.Validate_Activity_Record');

   l_count := 0;
   IF ((p_act_val_rec.reason_id IS NOT NULL) AND (p_act_val_rec.reason_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM jtf_ih_reasons_B
         WHERE reason_id = p_act_val_rec.reason_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.reason_id),
					    'reason_id');
					 RETURN;
					 END IF;
       END;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate reason_id in JTF_IH_PUB_PS.Validate_Activity_Record');


   l_count := 0;
   IF ((p_act_val_rec.source_code_id IS NOT NULL) AND (p_act_val_rec.source_code_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM ams_source_codes
         WHERE source_code_id = p_act_val_rec.source_code_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.source_code_id),
					    'source_code_id');
					 RETURN;
					 END IF;
      END;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate source_code_id in JTF_IH_PUB_PS.Validate_Activity_Record');

   l_count := 0;
   IF ((p_act_val_rec.media_id IS NOT NULL) AND (p_act_val_rec.media_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(*) into l_count
         FROM jtf_ih_media_items
         WHERE media_id = p_act_val_rec.media_id;
           IF (l_count <= 0) THEN
           x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.media_id),
					    'media_id');
					 RETURN;
					 END IF;
      END;
   END IF;
   ----DBMS_OUTPUT.PUT_LINE('PAST Validate media_id in JTF_IH_PUB_PS.Validate_Activity_Record');
  END Validate_Activity_Record;


  PROCEDURE Validate_Activity_table
  ( p_api_name          IN      VARCHAR2,
    p_int_val_tbl       IN      activity_tbl_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     IN OUT  VARCHAR2
  );

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Validate_Activity_table
  ( p_api_name          IN      VARCHAR2,
    p_int_val_tbl       IN      activity_tbl_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     IN OUT  VARCHAR2
  )

  IS
  l_count NUMBER := 0;

  BEGIN
    -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;

  -- Modified to call Validate_Activity_Record
	for  idx in 1 .. p_int_val_tbl.count loop
		Validate_Activity_Record(p_api_name, p_int_val_tbl(idx),p_resp_appl_id,p_resp_id,x_return_status);
		IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      		----DBMS_OUTPUT.PUT_LINE('Unsuccessful validation of a activity record in jtf_ih_pub.Validate_Activity_table');
			RETURN;
		END IF;
	END loop;
  END Validate_Activity_table;
PROCEDURE Validate_Media_Item
  ( p_api_name          IN      VARCHAR2,
    p_media_item_val    IN      media_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     IN OUT  VARCHAR2
  );

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Validate_Media_Item
  ( p_api_name          IN      VARCHAR2,
    p_media_item_val    IN      media_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     IN OUT  VARCHAR2
  )

  IS
  l_count NUMBER := 0;
  BEGIN
    -- Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;


  IF ((p_media_item_val.source_id IS NOT NULL) AND (p_media_item_val.source_id <> fnd_api.g_miss_num)) THEN
   	     SELECT count(*) into l_count
         FROM jtf_ih_sources
         WHERE source_id = p_media_item_val.source_id;
           IF (l_count <= 0) THEN
         	 x_return_status := fnd_api.g_ret_sts_error;
           jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_media_item_val.source_id),
					    'Source_id');
					 RETURN;
					 END IF;
    ELSE
   	   x_return_status := fnd_api.g_ret_sts_error;
       jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_media_item_val.source_id),
					    'Source_id');
			 RETURN;
   END IF;

   IF ((p_media_item_val.media_item_type IS  NULL) OR (p_media_item_val.media_item_type = fnd_api.g_miss_char)) THEN
   	   x_return_status := fnd_api.g_ret_sts_error;
	   jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, p_media_item_val.media_item_type,
					    'media_item_type');
	   RETURN;
   END IF;

  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RETURN;
      END IF;
  END Validate_Media_Item;

  PROCEDURE Default_Media_Item_Record  (x_media     IN OUT  media_rec_type);

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Default_Media_Item_Record  (x_media     IN OUT  media_rec_type)
  IS
	BEGIN
		if (x_media.source_id = fnd_api.g_miss_num)then
			x_media.source_id :=0;
		end if;
		if (x_media.source_item_id = fnd_api.g_miss_num)then
			x_media.source_item_id :=0;
		end if;
	END Default_Media_Item_Record;

-- Jean Zhu add Utility Validate_Mlcs_Record
  PROCEDURE Validate_Mlcs_Record
  ( p_api_name          IN      VARCHAR2,
    p_media_lc_rec      IN      media_lc_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     IN OUT  VARCHAR2
  );

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Validate_Mlcs_Record
  ( p_api_name          IN      VARCHAR2,
    p_media_lc_rec      IN      media_lc_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     IN OUT  VARCHAR2
  )

  IS
  l_count NUMBER := 0;
  BEGIN
    -- Initialize API return status to success
	x_return_status := fnd_api.g_ret_sts_success;
   l_count := 0;

  IF ((p_media_lc_rec.milcs_type_id IS NULL) OR (p_media_lc_rec.milcs_type_id = fnd_api.g_miss_num)) THEN
  	   x_return_status := fnd_api.g_ret_sts_error;
       jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_media_lc_rec.milcs_type_id),
					    'milcs_type_id');
			 RETURN;
  END IF;
  IF ((p_media_lc_rec.handler_id IS NOT NULL) AND (p_media_lc_rec.handler_id <> fnd_api.g_miss_num)) THEN
		SELECT count(*) into l_count
		FROM fnd_application
		WHERE application_id = p_media_lc_rec.handler_id;
			IF (l_count <= 0) THEN
			x_return_status := fnd_api.g_ret_sts_error;
			jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_media_lc_rec.handler_id),
							    'handler_id');
			RETURN;
			END IF;
   ELSE
   	   x_return_status := fnd_api.g_ret_sts_error;
       jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_media_lc_rec.handler_id),
					    'handler_id');
			 RETURN;
  END IF;
  l_count := 0;
  IF ((p_media_lc_rec.media_id IS NOT NULL) AND (p_media_lc_rec.media_id <> fnd_api.g_miss_num)) THEN
		SELECT count(*) into l_count
		FROM jtf_ih_media_items
		WHERE media_id = p_media_lc_rec.media_id;
			IF (l_count <= 0) THEN
			x_return_status := fnd_api.g_ret_sts_error;
			jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_media_lc_rec.media_id),
							    'media_id');
			RETURN;
			END IF;
   ELSE
   	   x_return_status := fnd_api.g_ret_sts_error;
       jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_media_lc_rec.handler_id),
					    'handler_id');
			 RETURN;
  END IF;
   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
   		RETURN;
   END IF;
  END Validate_Mlcs_Record;

  PROCEDURE Validate_Mlcs_table
  ( p_api_name          IN      VARCHAR2,
    p_mlcs_val_tab       IN      mlcs_tbl_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     IN OUT  VARCHAR2
  );

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Validate_Mlcs_table
  ( p_api_name          IN      VARCHAR2,
    p_mlcs_val_tab       IN      mlcs_tbl_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     IN OUT  VARCHAR2
  )

  IS
  l_count NUMBER := 0;
  BEGIN
    -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_count := 0;

	 for  idx in 1 .. p_mlcs_val_tab.count loop
	 	  Validate_Mlcs_Record  ( p_api_name, p_mlcs_val_tab(idx), p_resp_appl_id, p_resp_id, x_return_status);
   END loop;

   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      	----DBMS_OUTPUT.PUT_LINE('Unsuccessful validation of a media_lc record in jtf_ih_pub_PS.Validate_Mlcs_table');
    	RETURN;
   END IF;
  END Validate_Mlcs_table;

  PROCEDURE Default_Mlcs_table  (x_mlcs     IN OUT  mlcs_tbl_type);

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Default_Mlcs_table  (x_mlcs     IN OUT  mlcs_tbl_type)
  IS
	BEGIN
		for  idx in 1 .. x_mlcs.count loop
			if (x_mlcs(idx).type_id = fnd_api.g_miss_num)then
				x_mlcs(idx).type_id :=0;
			end if;
			if (x_mlcs(idx).handler_id = fnd_api.g_miss_num)then
				x_mlcs(idx).handler_id :=0;
			end if;
		end loop;
	END Default_Mlcs_table;
--
-- old version
--
	PROCEDURE Create_MediaItem
	(
	p_api_version		IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2, --DEFAULT FND_API.G_FALSE,
  p_commit			IN	VARCHAR2, --DEFAULT FND_API.G_FALSE,
  p_resp_appl_id		IN	NUMBER   DEFAULT NULL,
  p_resp_id			IN	NUMBER   DEFAULT NULL,
  p_user_id			IN	NUMBER,
  p_login_id			IN	NUMBER   DEFAULT NULL,
  x_return_status		OUT	VARCHAR2,
  x_msg_count			OUT	NUMBER,
  x_msg_data			OUT	VARCHAR2,
	p_media IN media_rec_type,
	p_mlcs IN mlcs_tbl_type
  ) AS
	 	 l_api_name         CONSTANT VARCHAR2(30) := 'Create_MediaItem';
     l_api_version      CONSTANT NUMBER       := 1.0;
     l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
     l_return_status    VARCHAR2(1);
     l_int_val_rec      media_rec_type := p_media;
     l_milcs_id           NUMBER;
     l_mlcs mlcs_tbl_type := p_mlcs;

	BEGIN
				   -- Standard start of API savepoint
   SAVEPOINT create_media_pub;

   -- Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;

         --
         -- Validate user and login session IDs
         --
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name              => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id               => p_user_id,
				p_login_id              => p_login_id,
				x_return_status         => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;

		Validate_Media_Item
		( p_api_name            => l_api_name_full,
			p_media_item_val      => p_media,
			p_resp_appl_id        => p_resp_appl_id,
			p_resp_id             => p_resp_id,
			x_return_status       => l_return_status
		);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
	Default_Media_Item_Record(l_int_val_rec);
	IF ((p_media.media_id IS NULL) OR (p_media.media_id = fnd_api.g_miss_num)) THEN
    SELECT jtf_ih_media_items_s1.NEXTVAL INTO l_int_val_rec.media_id FROM dual;
  END IF;

		insert into jtf_ih_Media_Items
		(
			 DURATION,
			 DIRECTION,
			 END_DATE_TIME,
			 SOURCE_ITEM_CREATE_DATE_TIME,
			 INTERACTION_PERFORMED,
			 SOURCE_ITEM_ID,
			 START_DATE_TIME,
			 MEDIA_ID,
			 SOURCE_ID,
			 MEDIA_ITEM_TYPE,
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATED_BY,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN,
			 MEDIA_ITEM_REF,
			 MEDIA_DATA
		) values (
			 l_int_val_rec.duration,
			 l_int_val_rec.direction,
			 l_int_val_rec.end_date_time,
			 l_int_val_rec.source_item_create_date_time,
			 l_int_val_rec.interaction_performed,
			 l_int_val_rec.source_item_id,
			 l_int_val_rec.start_date_time,
			 l_int_val_rec.media_id,
			 l_int_val_rec.source_id,
			 l_int_val_rec.media_item_type,
			 p_user_id,
			 SysDate,
			 p_user_id,
			 SysDate,
			 p_login_id,
			 l_int_val_rec.media_item_ref,
			 l_int_val_rec.media_data
			 );
														   --
			Validate_Mlcs_table
			( p_api_name            => l_api_name_full,
			p_mlcs_val_tab         => p_mlcs,
			p_resp_appl_id        => p_resp_appl_id,
			p_resp_id             => p_resp_id,
			x_return_status       => l_return_status
		  );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;

		Default_Mlcs_table(l_mlcs);
			for  idx in 1 .. p_mlcs.count loop
	 	  IF ((p_mlcs(idx).milcs_id IS NULL) OR (p_mlcs(idx).milcs_id = fnd_api.g_miss_num)) THEN
        SELECT jtf_ih_media_item_lc_seg_s1.NEXTVAL INTO l_mlcs(idx).milcs_id FROM dual;
	 	  END IF;

				insert into jtf_ih_media_item_lc_segs
				(
					 START_DATE_TIME,
					 TYPE_TYPE,
					 TYPE_ID,
					 DURATION,
					 END_DATE_TIME,
					 MILCS_ID,
					 MILCS_TYPE_ID,
					 MEDIA_ID,
					 HANDLER_ID,
					 CREATED_BY,
					 CREATION_DATE,
					 LAST_UPDATED_BY,
					 LAST_UPDATE_DATE,
					 LAST_UPDATE_LOGIN
 					)
					values
				  (
				   l_mlcs(idx).start_date_time,
				   l_mlcs(idx).type_type,
					 l_mlcs(idx).type_id,
					 l_mlcs(idx).duration,
					 l_mlcs(idx).end_date_time,
					 l_mlcs(idx).milcs_id,
					 l_mlcs(idx).milcs_type_id,
					 l_int_val_rec.media_id,
					 l_mlcs(idx).handler_id,
					 p_user_id,
					 Sysdate,
					 p_user_id,
					 Sysdate,
					 p_login_id
					);
			END loop;


   -- Standard check of p_commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );
  EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_media_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_media_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN OTHERS THEN
      ROLLBACK TO create_media_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );

  END Create_MediaItem;

-- Jean Zhu split old version PROCEDURE Create_MediaItem() to
-- two PROCEDUREs Create_MediaItem() and Create_MediaLifecycle()

PROCEDURE Create_MediaItem
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id		IN	NUMBER		DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count		OUT	NUMBER,
	x_msg_data		OUT	VARCHAR2,
	p_media_rec		IN	media_rec_type,
	x_media_id		OUT NUMBER
)AS

	 l_api_name         CONSTANT VARCHAR2(30) := 'Create_MediaItem';
     l_api_version      CONSTANT NUMBER       := 1.0;
     l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
     l_return_status    VARCHAR2(1);
     l_media_id         NUMBER := NULL;

	BEGIN
	-- Standard start of API savepoint
	SAVEPOINT create_media_pub;

	-- Standard call to check for call compatibility
	IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
	END IF;
	----DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB_PS.Create_MediaItem');

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := fnd_api.g_ret_sts_success;

	--
	-- Validate user and login session IDs
	--
	IF (p_user_id IS NULL) THEN
		jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
		RAISE fnd_api.g_exc_error;
	ELSE
		jtf_ih_core_util_pvt.validate_who_info
		(	p_api_name              => l_api_name_full,
			p_parameter_name_usr    => 'p_user_id',
			p_parameter_name_log    => 'p_login_id',
			p_user_id               => p_user_id,
			p_login_id              => p_login_id,
			x_return_status         => l_return_status );
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
	END IF;
	----DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB_PS.Create_MediaItem');

	Validate_Media_Item
	(	p_api_name            => l_api_name_full,
		p_media_item_val      => p_media_rec,
		p_resp_appl_id        => p_resp_appl_id,
		p_resp_id             => p_resp_id,
		x_return_status       => l_return_status
		);
	IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
	END IF;

	----DBMS_OUTPUT.PUT_LINE('PAST Validate_Media_Item in JTF_IH_PUB_PS.Create_MediaItem');

    SELECT jtf_ih_media_items_s1.NEXTVAL INTO l_media_id FROM dual;

	----DBMS_OUTPUT.PUT_LINE('PAST generate PK in JTF_IH_PUB_PS.Create_MediaItem');
	insert into jtf_ih_Media_Items
		(
			 DURATION,
			 DIRECTION,
			 END_DATE_TIME,
			 SOURCE_ITEM_CREATE_DATE_TIME,
			 INTERACTION_PERFORMED,
			 SOURCE_ITEM_ID,
			 START_DATE_TIME,
			 MEDIA_ID,
			 SOURCE_ID,
			 MEDIA_ITEM_TYPE,
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATED_BY,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN,
			 MEDIA_ITEM_REF,
			 MEDIA_DATA
		) values (
			 p_media_rec.duration,
			 p_media_rec.direction,
			 p_media_rec.end_date_time,
			 p_media_rec.source_item_create_date_time,
			 p_media_rec.interaction_performed,
			 p_media_rec.source_item_id,
			 p_media_rec.start_date_time,
			 l_media_id,
			 p_media_rec.source_id,
			 p_media_rec.media_item_type,
			 p_user_id,
			 SysDate,
			 p_user_id,
			 SysDate,
			 p_login_id,
			 p_media_rec.media_item_ref,
			 p_media_rec.media_data
		);
	----DBMS_OUTPUT.PUT_LINE('PAST Insert data in JTF_IH_PUB_PS.Create_MediaItem');

	--
	-- Output
	--														   --
	x_media_id := l_media_id;

   -- Standard check of p_commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );
  EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_media_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_media_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN OTHERS THEN
      ROLLBACK TO create_media_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );

  END Create_MediaItem;


PROCEDURE Create_MediaLifecycle
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count	OUT	NUMBER,
	x_msg_data	OUT	VARCHAR2,
	p_media_lc_rec		IN	media_lc_rec_type
)AS

	 l_api_name         CONSTANT VARCHAR2(30) := 'Create_MediaLifecycle';
     l_api_version      CONSTANT NUMBER       := 1.0;
     l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
     l_return_status    VARCHAR2(1);
     l_milcs_id         NUMBER := NULL;

	BEGIN
	-- Standard start of API savepoint
	SAVEPOINT create_media_lc_pub;

	-- Standard call to check for call compatibility
	IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
	END IF;
	----DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB_PS.Create_MediaLifecycle');
	-- Initialize message list if p_init_msg_list is set to TRUE
	IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := fnd_api.g_ret_sts_success;

	--
	-- Validate user and login session IDs
	--
	IF (p_user_id IS NULL) THEN
		jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
		RAISE fnd_api.g_exc_error;
	ELSE
		jtf_ih_core_util_pvt.validate_who_info
		(	p_api_name              => l_api_name_full,
			p_parameter_name_usr    => 'p_user_id',
			p_parameter_name_log    => 'p_login_id',
			p_user_id               => p_user_id,
			p_login_id              => p_login_id,
			x_return_status         => l_return_status );
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
	END IF;
	----DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB_PS.Create_MediaLifecycle');
	Validate_Mlcs_Record
	(	p_api_name            => l_api_name_full,
		p_media_lc_rec	      => p_media_lc_rec,
		p_resp_appl_id        => p_resp_appl_id,
		p_resp_id             => p_resp_id,
		x_return_status       => l_return_status
		);
	IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
	END IF;
	----DBMS_OUTPUT.PUT_LINE('PAST Validate_Mlcs_Record in JTF_IH_PUB_PS.Create_MediaLifecycle');


    SELECT jtf_ih_media_item_lc_seg_s1.NEXTVAL INTO l_milcs_id FROM dual;
	----DBMS_OUTPUT.PUT_LINE('PAST generate PK in JTF_IH_PUB_PS.Create_MediaLifecycle');

	insert into jtf_ih_media_item_lc_segs
	(
			 START_DATE_TIME,
			 TYPE_TYPE,
			 TYPE_ID,
			 DURATION,
			 END_DATE_TIME,
			 MILCS_ID,
			 MILCS_TYPE_ID,
			 MEDIA_ID,
			 HANDLER_ID,
			 RESOURCE_ID,
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATED_BY,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN
 	)
	values
	(
			p_media_lc_rec.start_date_time,
			p_media_lc_rec.type_type,
			p_media_lc_rec.type_id,
			p_media_lc_rec.duration,
			p_media_lc_rec.end_date_time,
			l_milcs_id,
			p_media_lc_rec.milcs_type_id,
			p_media_lc_rec.media_id,
			p_media_lc_rec.handler_id,
			p_media_lc_rec.resource_id,
			p_user_id,
			Sysdate,
			p_user_id,
			Sysdate,
			p_login_id
	);
	--DBMS_OUTPUT.PUT_LINE('PAST insert data in JTF_IH_PUB_PS.Create_MediaLifecycle');

   -- Standard check of p_commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );
  EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_media_lc_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_media_lc_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN OTHERS THEN
      ROLLBACK TO create_media_lc_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );

  END Create_MediaLifecycle;

 PROCEDURE Create_Interaction(
		  p_api_version			IN	NUMBER,
		  p_init_msg_list		IN	VARCHAR2, --DEFAULT FND_API.G_FALSE,
		  p_commit					IN	VARCHAR2, --DEFAULT FND_API.G_FALSE,
		  p_resp_appl_id		IN	NUMBER   DEFAULT NULL,
		  p_resp_id					IN	NUMBER   DEFAULT NULL,
		  p_user_id					IN	NUMBER,
		  p_login_id				IN	NUMBER   DEFAULT NULL,
		  x_return_status		OUT	VARCHAR2,
		  x_msg_count				OUT	NUMBER,
		  x_msg_data				OUT	VARCHAR2,
	    p_interaction_rec 		IN 	interaction_rec_type,
		  p_activities 			IN 	activity_tbl_type
		) IS
		 l_api_name         CONSTANT VARCHAR2(30) := 'Create_Interaction';
		 l_api_version      CONSTANT NUMBER       := 1.0;
		 l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		 l_return_status    VARCHAR2(1);
		 l_int_val_rec      interaction_rec_type := p_interaction_rec;
		 l_interaction_id   NUMBER;
		 l_activity_id      NUMBER;
     		 l_activities activity_tbl_type := p_activities;

		BEGIN

		-- Standard start of API savepoint
		SAVEPOINT create_interaction_pub;

		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
    RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB_PS.Create_Interaction');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
		END IF;

   	-- Initialize API return status to success
   	x_return_status := fnd_api.g_ret_sts_success;

   	--
   	-- Apply business-rule validation to all required and passed parameters
    --
    -- Validate user and login session IDs
    --
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name              => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id               => p_user_id,
				p_login_id              => p_login_id,
				x_return_status         => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB_PS.Create_Interaction');

		--
		-- Validate all non-missing attributes by calling the utility procedure.
		--
		Validate_Interaction_Record
		( p_api_name            => l_api_name_full,
			p_int_val_rec         => p_interaction_rec,
			p_resp_appl_id        => p_resp_appl_id,
			p_resp_id             => p_resp_id,
			x_return_status       => l_return_status
		);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST Validate_Interaction_Record in JTF_IH_PUB_PS.Create_Interaction');
		Default_Interaction_Record(l_int_val_rec);
  	IF ((p_interaction_rec.interaction_id IS NULL) OR (p_interaction_rec.interaction_id = fnd_api.g_miss_num)) THEN
        SELECT jtf_ih_interactions_s1.NEXTVAL INTO l_int_val_rec.interaction_id FROM dual;

  	END IF;

		INSERT INTO jtf_ih_Interactions
	 	(
			 CREATED_BY,
			 REFERENCE_FORM,
			 CREATION_DATE,
			 LAST_UPDATED_BY,
			 DURATION,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN,
			 END_DATE_TIME,
			 FOLLOW_UP_ACTION,
			 NON_PRODUCTIVE_TIME_AMOUNT,
			 RESULT_ID,
			 REASON_ID,
			 START_DATE_TIME,
			 OUTCOME_ID,
			 PREVIEW_TIME_AMOUNT,
			 PRODUCTIVE_TIME_AMOUNT,
			 HANDLER_ID,
			 INTER_INTERACTION_DURATION,
			 INTERACTION_ID,
			 WRAP_UP_TIME_AMOUNT,
			 SCRIPT_ID,
			 PARTY_ID,
			 RESOURCE_ID,
			 OBJECT_ID,
       			 OBJECT_TYPE,
       			 SOURCE_CODE_ID,
       			 SOURCE_CODE,
			 ATTRIBUTE1,
			 ATTRIBUTE2,
			 ATTRIBUTE3,
			 ATTRIBUTE4,
			 ATTRIBUTE5,
			 ATTRIBUTE6,
			 ATTRIBUTE7,
			 ATTRIBUTE8,
			 ATTRIBUTE9,
			 ATTRIBUTE10,
			 ATTRIBUTE11,
			 ATTRIBUTE12,
			 ATTRIBUTE13,
			 ATTRIBUTE14,
			 ATTRIBUTE15,
			 ATTRIBUTE_CATEGORY,
			 ACTIVE
			)
			VALUES
			(
			 p_user_id,
			 l_int_val_rec.reference_form,
			 Sysdate,
			 p_user_id,
			 l_int_val_rec.duration,
			 Sysdate,
			 p_login_id,
			 l_int_val_rec.end_date_time,
			 l_int_val_rec.follow_up_action,
			 l_int_val_rec.non_productive_time_amount,
			 l_int_val_rec.result_id,
			 l_int_val_rec.reason_id,
			 l_int_val_rec.start_date_time,
			 l_int_val_rec.outcome_id,
			 l_int_val_rec.preview_time_amount,
			 l_int_val_rec.productive_time_amount,
			 l_int_val_rec.handler_id,
			 l_int_val_rec.inter_interaction_duration,
			 l_int_val_rec.interaction_id,
			 l_int_val_rec.wrapup_time_amount,
			 l_int_val_rec.script_id,
			 l_int_val_rec.party_id,
			 l_int_val_rec.resource_id,
			 l_int_val_rec.object_id,
			 l_int_val_rec.object_type,
			 l_int_val_rec.source_code_id,
			 l_int_val_rec.source_code,
			 l_int_val_rec.attribute1,
			 l_int_val_rec.attribute2,
			 l_int_val_rec.attribute3,
			 l_int_val_rec.attribute4,
			 l_int_val_rec.attribute5,
			 l_int_val_rec.attribute6,
			 l_int_val_rec.attribute7,
			 l_int_val_rec.attribute8,
			 l_int_val_rec.attribute9,
			 l_int_val_rec.attribute10,
			 l_int_val_rec.attribute11,
			 l_int_val_rec.attribute12,
			 l_int_val_rec.attribute13,
			 l_int_val_rec.attribute14,
			 l_int_val_rec.attribute15,
			 l_int_val_rec.attribute_category,
			 'Y'
			);
			--DBMS_OUTPUT.PUT_LINE('PAST INSERT INTO jtf_ih_Interactions in JTF_IH_PUB_PS.Create_Interaction');

			Validate_Activity_table
			(
			p_api_name            => l_api_name_full,
			p_int_val_tbl         => p_activities,
			p_resp_appl_id        => p_resp_appl_id,
			p_resp_id             => p_resp_id,
			x_return_status       => l_return_status
		  );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;

			Default_activity_table(l_activities);
			for  idx in 1 .. p_activities.count loop
	 	  IF ((p_activities(idx).activity_id IS NULL) OR (p_activities(idx).activity_id = fnd_api.g_miss_num)) THEN
			  	SELECT jtf_ih_activities_s1.NEXTVAL INTO l_activities(idx).activity_id FROM dual;
      END IF;
			insert into jtf_ih_Activities
			(
           OBJECT_ID,
					 OBJECT_TYPE,
           SOURCE_CODE_ID,
           SOURCE_CODE,
					 DURATION,
					 DESCRIPTION,
					 DOC_ID,
					 END_DATE_TIME,
					 ACTIVITY_ID,
					 RESULT_ID,
					 REASON_ID,
					 START_DATE_TIME,
					 INTERACTION_ACTION_TYPE,
					 MEDIA_ID,
					 OUTCOME_ID,
					 ACTION_ITEM_ID,
					 INTERACTION_ID,
					 TASK_ID,
					 CREATION_DATE,
					 CREATED_BY,
					 LAST_UPDATED_BY,
					 LAST_UPDATE_DATE,
					 LAST_UPDATE_LOGIN,
					 ACTION_ID,
					 ACTIVE
					)
					values
				  (
				   l_activities(idx).object_id,
					 l_activities(idx).object_type,
					 l_activities(idx).source_code_id,
					 l_activities(idx).source_code,
					 l_activities(idx).duration,
					 l_activities(idx).description,
					 l_activities(idx).doc_id,
					 l_activities(idx).end_date_time,
					 l_activities(idx).activity_id,
					 l_activities(idx).result_id,
					 l_activities(idx).reason_id,
				   l_activities(idx).start_date_time,
					 l_activities(idx).interaction_action_type,
					 l_activities(idx).media_id,
					 l_activities(idx).outcome_id,
					 l_activities(idx).action_item_id,
			     l_int_val_rec.interaction_id,
					 l_activities(idx).task_id,
					 Sysdate,
					 p_user_id,
					 p_user_id,
					 Sysdate,
					 p_login_id,
					 l_activities(idx).action_id,
					 'Y'
					);
			END loop;

     	IF ((l_int_val_rec.parent_id IS NOT NULL) AND (l_int_val_rec.parent_id  <> fnd_api.g_miss_num))	THEN
				insert into jtf_ih_interaction_inters
				(
					 INTERACT_INTERACTION_ID,
					 INTERACT_INTERACTION_IDRELATES,
					 CREATED_BY,
					 CREATION_DATE,
 					 LAST_UPDATED_BY,
					 LAST_UPDATE_DATE,
					 LAST_UPDATE_LOGIN
					)
					values
				  (
			     l_int_val_rec.interaction_id,
			     l_int_val_rec.parent_id,
					 p_user_id,
					 Sysdate,
					 p_user_id,
					 Sysdate,
					 p_user_id
 					);
     END IF;
   --
   -- Set OUT value
   --
   --x_interaction_id := l_int_val_rec.interaction_id;

   -- Standard check of p_commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );
  EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_interaction_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_interaction_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN OTHERS THEN
      ROLLBACK TO create_interaction_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );

  END Create_Interaction;



	PROCEDURE Get_InteractionActivityCount
	(
	p_api_version		IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2, --DEFAULT FND_API.G_FALSE,
  p_resp_appl_id		IN	NUMBER   DEFAULT NULL,
  p_resp_id			IN	NUMBER   DEFAULT NULL,
  p_user_id			IN	NUMBER,
  p_login_id			IN	NUMBER   DEFAULT NULL,
  x_return_status		OUT	VARCHAR2,
  x_msg_count			OUT	NUMBER,
  x_msg_data			OUT	VARCHAR2,
	p_outcome_id         IN NUMBER,
	p_result_id          IN NUMBER,
	p_reason_id          IN NUMBER,
	p_script_id    IN NUMBER,
	p_media_id     IN NUMBER,
  x_activity_count OUT NUMBER
  ) AS
		 l_api_name         CONSTANT VARCHAR2(30) := 'Get_InteractionActivityCount';
		 l_api_version      CONSTANT NUMBER       := 1.1;
		 l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		 l_return_status    VARCHAR2(1);

	actionCount NUMBER;

   BEGIN

   			IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
		END IF;

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
		END IF;

   	-- Initialize API return status to success
   	x_return_status := fnd_api.g_ret_sts_success;

   	--
   	-- Apply business-rule validation to all required and passed parameters
    --
    -- Validate user and login session IDs
    --
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name              => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id               => p_user_id,
				p_login_id              => p_login_id,
				x_return_status         => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;

		SELECT count(*) into actionCount
		FROM jtf_ih_Activities
		where outcome_id = p_outcome_id
		and  result_id = p_result_id
		and reason_id = p_reason_id
		and media_id = p_media_id
		;
		x_activity_count := actionCount;
   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );
  EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );

	END Get_InteractionActivityCount;

	PROCEDURE Get_InteractionCount
	(
	p_api_version		IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2, --DEFAULT FND_API.G_FALSE,
  p_resp_appl_id		IN	NUMBER   DEFAULT NULL,
  p_resp_id			IN	NUMBER   DEFAULT NULL,
  p_user_id			IN	NUMBER,
  p_login_id			IN	NUMBER   DEFAULT NULL,
  x_return_status		OUT	VARCHAR2,
  x_msg_count			OUT	NUMBER,
  x_msg_data			OUT	VARCHAR2,
	p_outcome_id         IN NUMBER,
	p_result_id          IN NUMBER,
	p_reason_id          IN NUMBER,
	p_attribute1			IN	VARCHAR2 DEFAULT NULL,
  p_attribute2			IN	VARCHAR2 DEFAULT NULL,
  p_attribute3			IN	VARCHAR2 DEFAULT NULL,
  p_attribute4			IN	VARCHAR2 DEFAULT NULL,
  p_attribute5			IN	VARCHAR2 DEFAULT NULL,
  p_attribute6			IN	VARCHAR2 DEFAULT NULL,
  p_attribute7			IN	VARCHAR2 DEFAULT NULL,
  p_attribute8			IN	VARCHAR2 DEFAULT NULL,
  p_attribute9			IN	VARCHAR2 DEFAULT NULL,
  p_attribute10		IN	VARCHAR2 DEFAULT NULL,
  p_attribute11		IN	VARCHAR2 DEFAULT NULL,
  p_attribute12		IN	VARCHAR2 DEFAULT NULL,
  p_attribute13		IN	VARCHAR2 DEFAULT NULL,
  p_attribute14		IN	VARCHAR2 DEFAULT NULL,
  p_attribute15		IN	VARCHAR2 DEFAULT NULL,
  p_attribute_category        IN      VARCHAR2 DEFAULT NULL,
  x_interaction_count OUT NUMBER
	)	AS
		 l_api_name         CONSTANT VARCHAR2(30) := 'Get_InteractionCount';
		 l_api_version      CONSTANT NUMBER       := 1.1;
		 l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		 l_return_status    VARCHAR2(1);

	interactionCount NUMBER;
	BEGIN

		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
		END IF;

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
		END IF;

   	-- Initialize API return status to success
   	x_return_status := fnd_api.g_ret_sts_success;

   	--
   	-- Apply business-rule validation to all required and passed parameters
    --
    -- Validate user and login session IDs
    --
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name              => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id               => p_user_id,
				p_login_id              => p_login_id,
				x_return_status         => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;

		SELECT count(*) into interactionCount
		FROM jtf_ih_Interactions
		where outcome_id = p_outcome_id
		and result_id = p_result_id
		and reason_id = p_reason_id
		and ((attribute1 = p_attribute1) or (p_attribute1 is NULL and attribute1 is NULL))
		and ((attribute2 = p_attribute2) or (p_attribute2 is NULL and attribute2 is NULL))
		and ((attribute3 = p_attribute3) or (p_attribute3 is NULL and attribute3 is NULL))
		and ((attribute4 = p_attribute4) or (p_attribute4 is NULL and attribute4 is NULL))
		and ((attribute5 = p_attribute5) or (p_attribute5 is NULL and attribute5 is NULL))
		and ((attribute6 = p_attribute6) or (p_attribute6 is NULL and attribute6 is NULL))
		and ((attribute7 = p_attribute7) or (p_attribute7 is NULL and attribute7 is NULL))
		and ((attribute8 = p_attribute8) or (p_attribute8 is NULL and attribute8 is NULL))
		and ((attribute9 = p_attribute9) or (p_attribute9 is NULL and attribute9 is NULL))
		and ((attribute10 = p_attribute10) or (p_attribute10 is NULL and attribute10 is NULL))
		and ((attribute11 = p_attribute11) or (p_attribute11 is NULL and attribute11 is NULL))
		and ((attribute12 = p_attribute12) or (p_attribute12 is NULL and attribute12 is NULL))
		and ((attribute13 = p_attribute13) or (p_attribute13 is NULL and attribute13 is NULL))
		and ((attribute14 = p_attribute14) or (p_attribute14 is NULL and attribute14 is NULL))
		and ((attribute15 = p_attribute15) or (p_attribute15 is NULL and attribute15 is NULL))
		and ((p_attribute_category = p_attribute_category) or (p_attribute_category is NULL and p_attribute_category is NULL))
		;
		x_interaction_count := interactionCount;
   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );
  EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );

	END Get_InteractionCount;

 PROCEDURE Open_Interaction  -- created by Jean Zhu 01/11/2000
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id			IN	NUMBER 	 DEFAULT NULL,
	p_resp_id			IN	NUMBER DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER DEFAULT NULL,
	x_return_status			OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_interaction_rec		IN	INTERACTION_REC_TYPE,
	x_interaction_id		OUT	NUMBER
)
AS
		 l_api_name         CONSTANT VARCHAR2(30) := 'Open_Interaction';
		 l_api_version      CONSTANT NUMBER       := 1.0;
		 l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		 l_return_status    VARCHAR2(1);
		 l_interaction_id	NUMBER;
		 l_start_date_time	DATE;
		 l_active			VARCHAR2(1) := 'Y';
		 l_duration			NUMBER := NULL;
		 l_productive_time_amount	NUMBER := NULL;
	BEGIN
		-- Standard start of API savepoint
		SAVEPOINT open_interaction_pub;

		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
		RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB_PS.Open_Interaction');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name              => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id               => p_user_id,
				p_login_id              => p_login_id,
				x_return_status         => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB_PS.Open_Interaction');

		--
		-- Validate all non-missing attributes by calling the utility procedure.
		--
		Validate_Interaction_Record
		(	p_api_name            => l_api_name_full,
			p_int_val_rec         => p_interaction_rec,
			p_resp_appl_id        => p_resp_appl_id,
			p_resp_id             => p_resp_id,
			x_return_status       => l_return_status
		);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST Validate_Interaction_Record in JTF_IH_PUB_PS.Open_Interaction');

		-- assign the start_date_time
		IF(p_interaction_rec.start_date_time IS NOT NULL) THEN
			l_start_date_time := p_interaction_rec.start_date_time;
		ELSE
			l_start_date_time := SYSDATE;
		END IF;

		-- assign the duration
		IF(p_interaction_rec.duration IS NOT NULL) THEN
			l_duration := p_interaction_rec.duration;
		ELSIF(p_interaction_rec.end_date_time IS NOT NULL) THEN
			--
			-- Validate start_date_time and end_date_time by calling the utility procedure.
			--
			Validate_StartEnd_Date
			(	p_api_name          => l_api_name_full,
				p_start_date_time   => l_start_date_time,
				p_end_date_time		=> p_interaction_rec.end_date_time,
				x_return_status     => l_return_status
			);
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
			--DBMS_OUTPUT.PUT_LINE('PAST Validate_StartEnd_Date in JTF_IH_PUB_PS.Open_Interaction');
			l_duration := ROUND((p_interaction_rec.end_date_time - l_start_date_time)*24*60);
		END IF;

		-- assign the productive_time_amount
		IF(p_interaction_rec.productive_time_amount IS NOT NULL) THEN
			l_productive_time_amount := p_interaction_rec.productive_time_amount;
		ELSIF(l_duration IS NOT NULL) THEN
			IF(p_interaction_rec.non_productive_time_amount IS NOT NULL) THEN
				l_productive_time_amount := l_duration - p_interaction_rec.non_productive_time_amount;
				IF(l_productive_time_amount < 0) THEN
					x_return_status := fnd_api.g_ret_sts_error;
					jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full,
						to_char(p_interaction_rec.non_productive_time_amount),'non_productive_time_amount');
					RETURN;
				END IF;
			ELSE
				l_productive_time_amount := l_duration;
			END IF;
		END IF;

		SELECT JTF_IH_INTERACTIONS_S1.NextVal into l_interaction_id FROM dual;

		INSERT INTO jtf_ih_interactions
		(
			 CREATED_BY,
			 REFERENCE_FORM,
			 CREATION_DATE,
			 LAST_UPDATED_BY,
			 DURATION,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN,
			 END_DATE_TIME,
			 FOLLOW_UP_ACTION,
			 NON_PRODUCTIVE_TIME_AMOUNT,
			 RESULT_ID,
			 REASON_ID,
			 START_DATE_TIME,
			 OUTCOME_ID,
			 PREVIEW_TIME_AMOUNT,
			 PRODUCTIVE_TIME_AMOUNT,
			 HANDLER_ID,
			 INTER_INTERACTION_DURATION,
			 INTERACTION_ID,
			 WRAP_UP_TIME_AMOUNT,
			 SCRIPT_ID,
			 PARTY_ID,
			 RESOURCE_ID,
			 OBJECT_ID,
       		 OBJECT_TYPE,
       		 SOURCE_CODE_ID,
       		 SOURCE_CODE,
			 ATTRIBUTE1,
			 ATTRIBUTE2,
			 ATTRIBUTE3,
			 ATTRIBUTE4,
			 ATTRIBUTE5,
			 ATTRIBUTE6,
			 ATTRIBUTE7,
			 ATTRIBUTE8,
			 ATTRIBUTE9,
			 ATTRIBUTE10,
			 ATTRIBUTE11,
			 ATTRIBUTE12,
			 ATTRIBUTE13,
			 ATTRIBUTE14,
			 ATTRIBUTE15,
			 ATTRIBUTE_CATEGORY,
			 ACTIVE
			)
			VALUES
			(
			 p_user_id,
			 p_interaction_rec.reference_form,
			 Sysdate,
			 p_user_id,
			 l_duration,
			 Sysdate,
			 p_login_id,
			 p_interaction_rec.end_date_time,
			 p_interaction_rec.follow_up_action,
			 p_interaction_rec.non_productive_time_amount,
			 p_interaction_rec.result_id,
			 p_interaction_rec.reason_id,
			 l_start_date_time,
			 p_interaction_rec.outcome_id,
			 p_interaction_rec.preview_time_amount,
			 l_productive_time_amount,
			 p_interaction_rec.handler_id,
			 p_interaction_rec.inter_interaction_duration,
			 l_interaction_id,
			 p_interaction_rec.wrapup_time_amount,
			 p_interaction_rec.script_id,
			 p_interaction_rec.party_id,
			 p_interaction_rec.resource_id,
			 p_interaction_rec.object_id,
			 p_interaction_rec.object_type,
			 p_interaction_rec.source_code_id,
			 p_interaction_rec.source_code,
			 p_interaction_rec.attribute1,
			 p_interaction_rec.attribute2,
			 p_interaction_rec.attribute3,
			 p_interaction_rec.attribute4,
			 p_interaction_rec.attribute5,
			 p_interaction_rec.attribute6,
			 p_interaction_rec.attribute7,
			 p_interaction_rec.attribute8,
			 p_interaction_rec.attribute9,
			 p_interaction_rec.attribute10,
			 p_interaction_rec.attribute11,
			 p_interaction_rec.attribute12,
			 p_interaction_rec.attribute13,
			 p_interaction_rec.attribute14,
			 p_interaction_rec.attribute15,
			 p_interaction_rec.attribute_category,
			 l_active
			);
		--DBMS_OUTPUT.PUT_LINE('PAST INSERT INTO jtf_ih_Interactions in JTF_IH_PUB_PS.Open_Interaction');


     	IF ((p_interaction_rec.parent_id IS NOT NULL) AND (p_interaction_rec.parent_id  <> fnd_api.g_miss_num))	THEN
				INSERT INTO jtf_ih_interaction_inters
				(
					 INTERACT_INTERACTION_ID,
					 INTERACT_INTERACTION_IDRELATES,
					 CREATED_BY,
					 CREATION_DATE,
 					 LAST_UPDATED_BY,
					 LAST_UPDATE_DATE,
					 LAST_UPDATE_LOGIN
				)
				VALUES
				(
					l_interaction_id,
					p_interaction_rec.parent_id,
					p_user_id,
					Sysdate,
					p_user_id,
					Sysdate,
					p_user_id
 				);
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST INSERT INTO jtf_ih_Interaction_inters in JTF_IH_PUB_PS.Open_Interaction');
		--
		-- Set OUT value
		--
		x_interaction_id := l_interaction_id;

		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO open_interaction_pub;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO open_interaction_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN OTHERS THEN
			ROLLBACK TO open_interaction_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
	END Open_Interaction;


PROCEDURE Update_Interaction  -- created by Jean Zhu 01/11/2000
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count		OUT	NUMBER,
	x_msg_data		OUT	VARCHAR2,
	p_interaction_rec	IN	interaction_rec_type
)
AS
		 l_api_name         CONSTANT VARCHAR2(30) := 'Update_Interaction';
		 l_api_version      CONSTANT NUMBER       := 1.0;
		 l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		 l_return_status    VARCHAR2(1);
		 l_count			NUMBER;
		 l_start_date_time	DATE;
		 l_active			VARCHAR2(1) := NULL;
		 l_duration			NUMBER := NULL;
		 l_productive_time_amount	NUMBER := NULL;
	BEGIN
		-- Standard start of API savepoint
		SAVEPOINT update_interaction_pub;

		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
		RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB_PS.Update_Interaction');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			(	p_api_name              => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id               => p_user_id,
				p_login_id              => p_login_id,
				x_return_status         => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB_PS.Update_Interaction');

		--
		-- Validate all non-missing attributes by calling the utility procedure.
		--
		Validate_Interaction_Record
		(	p_api_name            => l_api_name_full,
			p_int_val_rec         => p_interaction_rec,
			p_resp_appl_id        => p_resp_appl_id,
			p_resp_id             => p_resp_id,
			x_return_status       => l_return_status
		);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST Validate_Interaction_Record in JTF_IH_PUB_PS.Update_Interaction');


		--
		-- Update table JTF_IH_INTERACTIONS
		--
		IF (p_interaction_rec.interaction_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'interaction_id');
				RAISE fnd_api.g_exc_error;
		ELSE
   			l_count := 0;
   			SELECT count(*) into l_count
			FROM jtf_ih_interactions
			WHERE interaction_id = p_interaction_rec.interaction_id;
			IF(l_count <> 1) THEN
				x_return_status := fnd_api.g_ret_sts_error;
				jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(p_interaction_rec.interaction_id),
					    'interaction_id');
				RETURN;
			ELSE
				SELECT active into l_active
				FROM jtf_ih_interactions
				WHERE interaction_id = p_interaction_rec.interaction_id;
				IF(l_active <> 'N') THEN
					SELECT start_date_time into l_start_date_time FROM jtf_ih_interactions
					WHERE interaction_id = p_interaction_rec.interaction_id;

					-- assign the duration
					IF(p_interaction_rec.duration IS NOT NULL) THEN
						l_duration := p_interaction_rec.duration;
					ELSIF(p_interaction_rec.end_date_time IS NOT NULL) THEN
						--
						-- Validate start_date_time and end_date_time by calling the utility procedure.
						--
						Validate_StartEnd_Date
						(	p_api_name          => l_api_name_full,
							p_start_date_time   => l_start_date_time,
							p_end_date_time		=> p_interaction_rec.end_date_time,
							x_return_status     => l_return_status
						);
						IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
							RAISE fnd_api.g_exc_error;
						END IF;
						--DBMS_OUTPUT.PUT_LINE('PAST Validate_StartEnd_Date in JTF_IH_PUB_PS.Open_Interaction');
						l_duration := ROUND((p_interaction_rec.end_date_time - l_start_date_time)*24*60);
					END IF;

					-- assign the productive_time_amount
					IF(p_interaction_rec.productive_time_amount IS NOT NULL) THEN
						l_productive_time_amount := p_interaction_rec.productive_time_amount;
					ELSIF(l_duration IS NOT NULL) THEN
						IF(p_interaction_rec.non_productive_time_amount IS NOT NULL) THEN
							l_productive_time_amount := l_duration - p_interaction_rec.non_productive_time_amount;
								IF(l_productive_time_amount < 0) THEN
									x_return_status := fnd_api.g_ret_sts_error;
									jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full,
										to_char(p_interaction_rec.non_productive_time_amount),'non_productive_time_amount');
									RETURN;
								END IF;
						ELSE
							l_productive_time_amount := l_duration;
						END IF;
					END IF;

					IF(p_interaction_rec.reference_form	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET REFERENCE_FORM = p_interaction_rec.reference_form
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.follow_up_action	<> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET FOLLOW_UP_ACTION = p_interaction_rec.follow_up_action
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(l_duration IS NOT NULL) THEN
						UPDATE jtf_ih_interactions SET DURATION = l_duration
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.end_date_time	 <> fnd_api.g_miss_date) THEN
						UPDATE jtf_ih_interactions SET END_DATE_TIME = p_interaction_rec.end_date_time
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.inter_interaction_duration	<> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_interactions SET INTER_INTERACTION_DURATION = p_interaction_rec.inter_interaction_duration
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.non_productive_time_amount	<> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_interactions SET NON_PRODUCTIVE_TIME_AMOUNT = p_interaction_rec.non_productive_time_amount
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.preview_time_amount	<> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_interactions SET PREVIEW_TIME_AMOUNT = p_interaction_rec.preview_time_amount
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(l_productive_time_amount	 IS NOT NULL) THEN
						UPDATE jtf_ih_interactions SET PRODUCTIVE_TIME_AMOUNT = l_productive_time_amount
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.wrapUp_time_amount	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_interactions SET WRAP_UP_TIME_AMOUNT = p_interaction_rec.wrapUp_time_amount
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.handler_id	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_interactions SET HANDLER_ID = p_interaction_rec.handler_id
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.script_id	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_interactions SET SCRIPT_ID = p_interaction_rec.script_id
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.outcome_id	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_interactions SET OUTCOME_ID = p_interaction_rec.outcome_id
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.result_id	<> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_interactions SET RESULT_ID = p_interaction_rec.result_id
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.reason_id	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_interactions SET REASON_ID = p_interaction_rec.reason_id
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.resource_id	<> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_interactions SET RESOURCE_ID = p_interaction_rec.resource_id
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.object_id	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_interactions SET OBJECT_ID = p_interaction_rec.object_id
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.object_type	<> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET OBJECT_TYPE = p_interaction_rec.object_type
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.source_code_id	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_interactions SET SOURCE_CODE_ID = p_interaction_rec.source_code_id
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.source_code	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET SOURCE_CODE = p_interaction_rec.source_code
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute1	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE1 = p_interaction_rec.attribute1
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute2	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE2 = p_interaction_rec.attribute2
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute3	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE3 = p_interaction_rec.attribute3
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute4  <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE4 = p_interaction_rec.attribute4
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute5	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE5 = p_interaction_rec.attribute5
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute6	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE6 = p_interaction_rec.attribute6
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute7	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE7 = p_interaction_rec.attribute7
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute8	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE8 = p_interaction_rec.attribute8
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute9	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE9 = p_interaction_rec.attribute9
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute10	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE10 = p_interaction_rec.attribute10
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute11	<> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE11 = p_interaction_rec.attribute11
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute12	<> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE12 = p_interaction_rec.attribute12
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute13	<> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE13 = p_interaction_rec.attribute13
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute14	<> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE14 = p_interaction_rec.attribute14
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute15	<> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE15 = p_interaction_rec.attribute15
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
					IF(p_interaction_rec.attribute_category	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_interactions SET ATTRIBUTE_CATEGORY = p_interaction_rec.attribute_category
						WHERE interaction_id = p_interaction_rec.interaction_id;
					END IF;
				END IF;
			END IF;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST update table jtf_ih_interactions in JTF_IH_PUB_PS.Update_Interaction');

    	IF ((p_interaction_rec.parent_id IS NOT NULL) AND (p_interaction_rec.parent_id  <> fnd_api.g_miss_num))	THEN
     		l_count := 0;
			SELECT count(*) into l_count
			FROM jtf_ih_interaction_inters
			WHERE interact_interaction_id = p_interaction_rec.interaction_id and
				  interact_interaction_idrelates = 	p_interaction_rec.parent_id;
            IF (l_count <= 0) THEN
				INSERT INTO jtf_ih_interaction_inters
				(
					 INTERACT_INTERACTION_ID,
					 INTERACT_INTERACTION_IDRELATES,
					 CREATED_BY,
					 CREATION_DATE,
 					 LAST_UPDATED_BY,
					 LAST_UPDATE_DATE,
					 LAST_UPDATE_LOGIN
				)
				VALUES
				(
					p_interaction_rec.interaction_id,
					p_interaction_rec.parent_id,
					p_user_id,
					Sysdate,
					p_user_id,
					Sysdate,
					p_user_id
 				);
			END IF;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST INSERT INTO jtf_ih_Interaction_inters in JTF_IH_PUB_PS.Update_Interaction');

		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );

		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO update_interaction_pub;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO update_interaction_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN OTHERS THEN
			ROLLBACK TO update_interaction_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
	END Update_Interaction;

PROCEDURE Close_Interaction  -- created by Jean Zhu 01/11/2000
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count		OUT	NUMBER,
	x_msg_data		OUT	VARCHAR2,
	p_interaction_rec	IN	interaction_rec_type
)
AS
		 l_api_name         CONSTANT VARCHAR2(30) := 'Close_Interaction';
		 l_api_version      CONSTANT NUMBER       := 1.0;
		 l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		 l_return_status    VARCHAR2(1);
		 l_outcome_id		NUMBER := NULL;
		 l_end_date_time	DATE := NULL;
		 l_action_item_id	NUMBER := NULL;
		 CURSOR	l_activity_id_c IS
			SELECT activity_id FROM jtf_ih_activities
			WHERE interaction_id = p_interaction_rec.interaction_id;
	BEGIN
		SAVEPOINT close_interaction_pub1;

		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
		RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB_PS.Close_Interaction');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name              => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id               => p_user_id,
				p_login_id              => p_login_id,
				x_return_status         => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB_PS.Close_Interaction');

		--
		-- Update interaction
		--
		Update_Interaction
		(	p_api_version,
			p_init_msg_list,
			p_commit,
			p_resp_appl_id,
			p_resp_id,
			p_user_id,
			p_login_id,
			x_return_status,
			x_msg_count,
			x_msg_data,
			p_interaction_rec);
		--DBMS_OUTPUT.PUT_LINE('PAST Update_Interaction in JTF_IH_PUB_PS.Close_Interaction');

   	    SELECT outcome_id into l_outcome_id
        FROM jtf_ih_interactions
        WHERE interaction_id = p_interaction_rec.interaction_id;
		IF (l_outcome_id IS NULL) THEN
			x_return_status := fnd_api.g_ret_sts_error;
	       jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(p_interaction_rec.outcome_id),
				    'outcome_id');
		RETURN;
		END IF;

		SELECT end_date_time into l_end_date_time
        FROM jtf_ih_interactions
        WHERE interaction_id = p_interaction_rec.interaction_id;
		IF(l_end_date_time IS NULL) THEN
			l_end_date_time := SYSDATE;
		END IF;
		--
		-- Set active to 'N' for jtf_ih_interactions and related jtf_ih_activities
		--
		UPDATE jtf_ih_interactions SET ACTIVE = 'N',end_date_time =l_end_date_time
				WHERE interaction_id = p_interaction_rec.interaction_id;

		FOR v_activity_id_c IN l_activity_id_c LOOP
			l_outcome_id := NULL;
   			SELECT outcome_id into l_outcome_id
			FROM jtf_ih_activities
			WHERE activity_id = v_activity_id_c.activity_id;
			IF (l_outcome_id IS NULL) THEN
				x_return_status := fnd_api.g_ret_sts_error;
			   jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(l_outcome_id),
						'outcome_id');
			RETURN;
			END IF;

			l_action_item_id := NULL;
   			SELECT action_item_id into l_action_item_id
			FROM jtf_ih_activities
			WHERE activity_id = v_activity_id_c.activity_id;
			IF (l_action_item_id IS NULL) THEN
				x_return_status := fnd_api.g_ret_sts_error;
			   jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(l_action_item_id),
						'action_item_id');
			RETURN;
			END IF;

			SELECT end_date_time into l_end_date_time
			FROM jtf_ih_activities
			WHERE activity_id = v_activity_id_c.activity_id;
			IF(l_end_date_time IS NULL) THEN
				l_end_date_time := SYSDATE;
			END IF;
			UPDATE jtf_ih_activities SET ACTIVE = 'N',end_date_time = l_end_date_time
					WHERE interaction_id = p_interaction_rec.interaction_id;
		END LOOP;
		--DBMS_OUTPUT.PUT_LINE('PAST Update ACTIVE in JTF_IH_PUB_PS.Close_Interaction');

		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO close_interaction_pub1;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO close_interaction_pub1;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN OTHERS THEN
			ROLLBACK TO close_interaction_pub1;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );

	END Close_Interaction;

PROCEDURE Add_Activity  -- created by Jean Zhu 01/11/2000
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id			IN	NUMBER	DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_activity_rec		IN	activity_rec_type,
	x_activity_id		OUT NUMBER
)
AS
		 l_api_name         CONSTANT VARCHAR2(30) := 'Add_Activity';
		 l_api_version      CONSTANT NUMBER       := 1.0;
		 l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		 l_return_status    VARCHAR2(1);
		 l_activity_id 	    NUMBER;
		 l_duration			NUMBER := NULL;
		 l_start_date_time	DATE;
		 l_active			VARCHAR2(1) := 'Y';
	BEGIN
		-- Standard start of API savepoint
		SAVEPOINT add_activity_pub;

		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
		RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB_PS.Add_Activity');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name              => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id               => p_user_id,
				p_login_id              => p_login_id,
				x_return_status         => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB_PS.Add_Activity');

		--
		-- Validate all non-missing attributes by calling the utility procedure.
		--
		Validate_Activity_Record
		(	p_api_name            => l_api_name_full,
			p_act_val_rec         => p_activity_rec,
			p_resp_appl_id        => p_resp_appl_id,
			p_resp_id             => p_resp_id,
			x_return_status       => l_return_status
		);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST Validate_Activity_Record in JTF_IH_PUB_PS.Add_Activity');


		IF(p_activity_rec.start_date_time IS NOT NULL) THEN
			l_start_date_time := p_activity_rec.start_date_time;
		ELSE
			l_start_date_time := SYSDATE;
		END IF;

		IF(p_activity_rec.duration IS NOT NULL) THEN
			l_duration := p_activity_rec.duration;
		ELSIF(p_activity_rec.end_date_time IS NOT NULL) THEN
			--
			-- Validate start_date_time and end_date_time by calling the utility procedure.
			--
			Validate_StartEnd_Date
			(	p_api_name          => l_api_name_full,
				p_start_date_time   => l_start_date_time,
				p_end_date_time		=> p_activity_rec.end_date_time,
				x_return_status     => l_return_status
			);
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
			--DBMS_OUTPUT.PUT_LINE('PAST Validate_StartEnd_Date in JTF_IH_PUB_PS.Add_Activity');
			l_duration := ROUND((p_activity_rec.end_date_time - l_start_date_time)*24*60);
		END IF;

		SELECT JTF_IH_ACTIVITIES_S1.NextVal into l_activity_id FROM dual;

		INSERT INTO jtf_ih_Activities
		(
			ACTIVITY_ID,
			OBJECT_ID,
			OBJECT_TYPE,
			SOURCE_CODE_ID,
			SOURCE_CODE,
			DURATION,
			DESCRIPTION,
			DOC_ID,
			DOC_REF,
			END_DATE_TIME,
			RESULT_ID,
			REASON_ID,
			START_DATE_TIME,
			ACTION_ID,
			INTERACTION_ACTION_TYPE,
			MEDIA_ID,
			OUTCOME_ID,
			ACTION_ITEM_ID,
			INTERACTION_ID,
			TASK_ID,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN,
			ACTIVE
		)
		VALUES
		(
			l_activity_id,
			p_activity_rec.object_id,
		    p_activity_rec.object_type,
			p_activity_rec.source_code_id,
			p_activity_rec.source_code,
			l_duration,
			p_activity_rec.description,
			p_activity_rec.doc_id,
			p_activity_rec.doc_ref,
			p_activity_rec.end_date_time,
			p_activity_rec.result_id,
			p_activity_rec.reason_id,
			l_start_date_time,
			p_activity_rec.action_id,
			p_activity_rec.interaction_action_type,
			p_activity_rec.media_id,
			p_activity_rec.outcome_id,
			p_activity_rec.action_item_id,
			p_activity_rec.interaction_id,
			p_activity_rec.task_id,
			Sysdate,
			p_user_id,
			p_user_id,
			Sysdate,
			p_login_id,
			l_active
		);
		--DBMS_OUTPUT.PUT_LINE('PAST INSERT INTO jtf_ih_activities in JTF_IH_PUB_PS.Add_Activity');

		--
		-- Set OUT value
		--
		x_activity_id := l_activity_id;

		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO add_activity_pub;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO add_activity_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN OTHERS THEN
			ROLLBACK TO add_activity_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
	END Add_Activity;

PROCEDURE Update_Activity  -- created by Jean Zhu 01/11/2000
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id			IN	NUMBER	DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_activity_rec		IN	activity_rec_type
)
AS
		 l_api_name         CONSTANT VARCHAR2(30) := 'Update_Activity';
		 l_api_version      CONSTANT NUMBER       := 1.0;
		 l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		 l_return_status    VARCHAR2(1);
		 l_start_date_time	DATE;
		 l_duration			NUMBER := NULL;
		 l_count			NUMBER := 0;
		 l_active			VARCHAR2(1) := NULL;
	BEGIN
		-- Standard start of API savepoint
		SAVEPOINT update_activity_pub;

		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
		RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB_PS.Update_Activity');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			(	p_api_name              => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id               => p_user_id,
				p_login_id              => p_login_id,
				x_return_status         => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB_PS.Update_Activity');

		--
		-- Validate all non-missing attributes by calling the utility procedure.
		--
		Validate_Activity_Record
		(	p_api_name            => l_api_name_full,
			p_act_val_rec         => p_activity_rec,
			p_resp_appl_id        => p_resp_appl_id,
			p_resp_id             => p_resp_id,
			x_return_status       => l_return_status
		);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST Validate_Activity_Record in JTF_IH_PUB_PS.Update_Activity');

		--
		-- Update table JTF_IH_INTERACTIONS
		--
		IF (p_activity_rec.activity_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'activity_id');
				RAISE fnd_api.g_exc_error;
		ELSE
   			l_count := 0;
   			SELECT count(*) into l_count
			FROM jtf_ih_activities
			WHERE activity_id = p_activity_rec.activity_id;
			IF (l_count <> 1) THEN
				x_return_status := fnd_api.g_ret_sts_error;
				jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(p_activity_rec.activity_id),
					    'activity_id');
				RETURN;
			ELSE
				SELECT active into l_active FROM jtf_ih_activities
				WHERE activity_id = p_activity_rec.activity_id;
				IF(l_active <> 'N') THEN
					SELECT start_date_time into l_start_date_time FROM jtf_ih_activities
					WHERE activity_id = p_activity_rec.activity_id;
					IF(p_activity_rec.duration IS NOT NULL) THEN
						l_duration := p_activity_rec.duration;
					ELSIF(p_activity_rec.end_date_time IS NOT NULL) THEN
						--
						-- Validate start_date_time and end_date_time by calling the utility procedure.
						--
						Validate_StartEnd_Date
						(	p_api_name          => l_api_name_full,
							p_start_date_time   => l_start_date_time,
							p_end_date_time		=> p_activity_rec.end_date_time,
							x_return_status     => l_return_status
						);
						IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
							RAISE fnd_api.g_exc_error;
						END IF;
						--DBMS_OUTPUT.PUT_LINE('PAST Validate_StartEnd_Date in JTF_IH_PUB_PS.Update_Activity');
						l_duration := ROUND((p_activity_rec.end_date_time - p_activity_rec.start_date_time)*24*60);
					END IF;
					IF(l_duration IS NOT NULL) THEN
						UPDATE jtf_ih_activities SET DURATION = l_duration
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.end_date_time	 <> fnd_api.g_miss_date) THEN
						UPDATE jtf_ih_activities SET END_DATE_TIME = p_activity_rec.end_date_time
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.cust_account_id	<> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_activities SET CUST_ACCOUNT_ID = p_activity_rec.cust_account_id
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.cust_org_id	<> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_activities SET CUST_ORG_ID = p_activity_rec.cust_org_id
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.role	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_activities SET ROLE = p_activity_rec.role
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.outcome_id	<> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_activities SET OUTCOME_ID = p_activity_rec.outcome_id
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.result_id	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_activities SET RESULT_ID = p_activity_rec.result_id
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.reason_id	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_activities SET REASON_ID = p_activity_rec.reason_id
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.task_id	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_activities SET TASK_ID = p_activity_rec.task_id
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.object_id	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_activities SET OBJECT_ID = p_activity_rec.object_id
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.object_type	<> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_activities SET OBJECT_TYPE = p_activity_rec.object_type
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.source_code_id	<> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_activities SET SOURCE_CODE_ID = p_activity_rec.source_code_id
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.source_code	<> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_activities SET SOURCE_CODE = p_activity_rec.source_code
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.doc_id	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_activities SET DOC_ID = p_activity_rec.doc_id
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.doc_ref	<> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_activities SET DOC_REF = p_activity_rec.doc_ref
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.media_id	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_activities SET MEDIA_ID = p_activity_rec.media_id
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.action_item_id	<> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_activities SET ACTION_ITEM_ID = p_activity_rec.action_item_id
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.interaction_id	<> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_activities SET INTERACTION_ID = p_activity_rec.interaction_id
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.description	<> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_activities SET DESCRIPTION = p_activity_rec.description
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.action_id	 <> fnd_api.g_miss_num) THEN
						UPDATE jtf_ih_activities SET ACTION_ID = p_activity_rec.action_id
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
					IF(p_activity_rec.interaction_action_type	 <> fnd_api.g_miss_char) THEN
						UPDATE jtf_ih_activities SET INTERACTION_ACTION_TYPE = p_activity_rec.interaction_action_type
						WHERE activity_id = p_activity_rec.activity_id;
					END IF;
				END IF;
			END IF;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST update table jtf_ih_activities in JTF_IH_PUB_PS.Update_Activity');

		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO update_activity_pub;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO update_activity_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN OTHERS THEN
			ROLLBACK TO update_activity_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
	END Update_Activity;

PROCEDURE Close_Interaction  -- created by Jean Zhu 01/11/2000
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count		OUT	NUMBER,
	x_msg_data		OUT	VARCHAR2,
	p_interaction_id	IN	NUMBER
)
AS
		 l_api_name         CONSTANT VARCHAR2(30) := 'Close_Interaction';
		 l_api_version      CONSTANT NUMBER       := 1.0;
		 l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		 l_return_status    VARCHAR2(1);
		 l_outcome_id		NUMBER := NULL;
		 l_end_date_time	DATE := NULL;
		 l_action_item_id	NUMBER := NULL;
		 CURSOR	l_activity_id_c IS
			SELECT activity_id FROM jtf_ih_activities
			WHERE interaction_id = p_interaction_id;
	BEGIN
		SAVEPOINT close_interaction_pub2;

		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
		RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB_PS.Close_Interaction_2');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name              => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id               => p_user_id,
				p_login_id              => p_login_id,
				x_return_status         => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB_PS.Close_Interaction_2');

   	    SELECT outcome_id into l_outcome_id
        FROM jtf_ih_interactions
        WHERE interaction_id = p_interaction_id;
		IF (l_outcome_id IS NULL) THEN
			x_return_status := fnd_api.g_ret_sts_error;
	       jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(l_outcome_id),
				    'outcome_id');
		RETURN;
		END IF;

		SELECT end_date_time into l_end_date_time
        FROM jtf_ih_interactions
        WHERE interaction_id = p_interaction_id;
		IF(l_end_date_time IS NULL) THEN
			l_end_date_time := SYSDATE;
		END IF;
		--
		-- Set active to 'N' for jtf_ih_interactions and related jtf_ih_activities
		--
		UPDATE jtf_ih_interactions SET ACTIVE = 'N',end_date_time =l_end_date_time
				WHERE interaction_id = p_interaction_id;

		FOR v_activity_id_c IN l_activity_id_c LOOP
			l_outcome_id := NULL;
   			SELECT outcome_id into l_outcome_id
			FROM jtf_ih_activities
			WHERE activity_id = v_activity_id_c.activity_id;
			IF (l_outcome_id IS NULL) THEN
				x_return_status := fnd_api.g_ret_sts_error;
			   jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(l_outcome_id),
						'outcome_id');
			RETURN;
			END IF;

			l_action_item_id := NULL;
   			SELECT action_item_id into l_action_item_id
			FROM jtf_ih_activities
			WHERE activity_id = v_activity_id_c.activity_id;
			IF (l_action_item_id IS NULL) THEN
				x_return_status := fnd_api.g_ret_sts_error;
			   jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(l_action_item_id),
						'action_item_id');
			RETURN;
			END IF;

			SELECT end_date_time into l_end_date_time
			FROM jtf_ih_activities
			WHERE activity_id = v_activity_id_c.activity_id;
			IF(l_end_date_time IS NULL) THEN
				l_end_date_time := SYSDATE;
			END IF;
			UPDATE jtf_ih_activities SET ACTIVE = 'N',end_date_time = l_end_date_time
					WHERE interaction_id = p_interaction_id;
		END LOOP;
		--DBMS_OUTPUT.PUT_LINE('PAST Update ACTIVE in JTF_IH_PUB_PS.Close_Interaction_2');


		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO close_interaction_pub2;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO close_interaction_pub2;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN OTHERS THEN
			ROLLBACK TO close_interaction_pub2;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );

	END Close_Interaction;


PROCEDURE Update_ActivityDuration  -- created by Jean Zhu 01/11/2000
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id			IN	NUMBER	DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_activity_id		IN	NUMBER,
	p_end_date_time		IN  DATE,
	p_duration			IN	NUMBER
)
AS
		 l_api_name         CONSTANT VARCHAR2(30) := 'Update_ActivityDuration';
		 l_api_version      CONSTANT NUMBER       := 1.0;
		 l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		 l_return_status    VARCHAR2(1);
		 l_start_date_time	DATE;
	BEGIN

		-- Standard start of API savepoint
		SAVEPOINT update_activityDuration;

		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
		RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB_PS.Update_ActivityDuration');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			(	p_api_name              => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id               => p_user_id,
				p_login_id              => p_login_id,
				x_return_status         => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB_PS.Update_ActivityDuration');

		--
		-- Update table JTF_IH_INTERACTIONS
		--
		IF (p_activity_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'activity_id');
				RAISE fnd_api.g_exc_error;
		ELSIF(p_end_date_time IS NULL) THEN RETURN;
		ELSE
			SELECT start_date_time into l_start_date_time
			FROM jtf_ih_activities
			WHERE activity_id = p_activity_id;
		--
		-- Validate start_date_time and end_date_time by calling the utility procedure.
		--
			Validate_StartEnd_Date
			(	p_api_name          => l_api_name_full,
				p_start_date_time   => l_start_date_time,
				p_end_date_time		=> p_end_date_time,
				x_return_status     => l_return_status
			);
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
			--DBMS_OUTPUT.PUT_LINE('PAST Validate_StartEnd_Date in JTF_IH_PUB_PS.Update_ActivityDuration');

			UPDATE jtf_ih_activities SET END_DATE_TIME = p_end_date_time,
				 DURATION = p_duration 	WHERE activity_id = p_activity_id;

			--DBMS_OUTPUT.PUT_LINE('PAST update end_date_time and duration in JTF_IH_PUB_PS.Update_ActivityDuration');
		END IF;

		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO update_activityDuration;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO update_activityDuration;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
		WHEN OTHERS THEN
			ROLLBACK TO update_activityDuration;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data        => x_msg_data );
	END Update_ActivityDuration;

	PROCEDURE Open_MediaItem
	(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count	OUT	NUMBER,
	x_msg_data	OUT	VARCHAR2,
	p_media_rec	IN	media_rec_type,
	x_media_id	OUT NUMBER
	) AS
	BEGIN
		NULL;
	END Open_MediaItem;

	PROCEDURE Update_MediaItem
	(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count	OUT	NUMBER,
	x_msg_data	OUT	VARCHAR2,
	p_media_rec	IN	media_rec_type
	) AS
	BEGIN
		NULL;
	END Update_MediaItem;

	PROCEDURE Close_MediaItem
	(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count	OUT	NUMBER,
	x_msg_data	OUT	VARCHAR2,
	p_media_rec	IN	media_rec_type
	) AS
	BEGIN
		NULL;
	END Close_MediaItem;

	PROCEDURE Add_MediaLifecycle
	(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count	OUT	NUMBER,
	x_msg_data	OUT	VARCHAR2,
	p_media_lc_rec	IN	media_lc_rec_type
	) AS
	BEGIN
		NULL;
	END Add_MediaLifecycle;

	PROCEDURE Update_MediaLifecycle
	(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count	OUT	NUMBER,
	x_msg_data	OUT	VARCHAR2,
	p_media_lc_rec	IN	media_lc_rec_type
	) AS

	BEGIN
		NULL;
	END Update_MediaLifecycle;



FUNCTION INIT_INTERACTION_REC RETURN interaction_rec_type
AS

l_interaction_rec_type interaction_rec_type;

BEGIN

return l_interaction_rec_type;

END INIT_INTERACTION_REC;

FUNCTION INIT_ACTIVITY_REC RETURN activity_rec_type
AS

l_activity_rec_type activity_rec_type;

BEGIN

return l_activity_rec_type;

END INIT_ACTIVITY_REC;

END JTF_IH_PUB_PS;

/
