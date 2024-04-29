--------------------------------------------------------
--  DDL for Package Body IEU_WPACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WPACTIONS_PVT" AS
/* $Header: IEUTKWPB.pls 120.3 2005/10/28 05:02:03 msathyan noship $ */


PROCEDURE WP_TASK
( P_RESOURCE_ID       IN NUMBER,
  P_LANGUAGE          IN VARCHAR2,
  P_SOURCE_LANG       IN VARCHAR2,
  P_ACTION_KEY        IN VARCHAR2,
  P_ACTION_INPUT_DATA IN SYSTEM.ACTION_INPUT_DATA_NST,
  P_Action_Type       IN Varchar2,
  X_UWQ_ACTION_LIST   OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
  X_MSG_COUNT         OUT NOCOPY NUMBER,
  X_MSG_DATA          OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS     OUT NOCOPY VARCHAR2
)
IS
    l_api_version           CONSTANT NUMBER      := 1.0;
    l_valid_level_full      NUMBER      := 100;
    l_note_status           VARCHAR2(3);

    -- only TASK from below is used for anything right now.
    l_src_task              CONSTANT VARCHAR2(30) := 'TASK';
    l_src_sr                CONSTANT VARCHAR2(30) := 'SR';
    l_src_lead              CONSTANT VARCHAR2(30) := 'LEAD';
    l_src_opp               CONSTANT VARCHAR2(30) := 'OPPORTUNITY';
    l_src_rel1              CONSTANT VARCHAR2(30) := 'PARTY_RELATIONSHIP';
    l_src_rel2              CONSTANT VARCHAR2(30) := 'PARTY_PERSON_RELATIONSHIP';

    -- for work to be done in uwq
    l_uwq_actions_list      IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_REC_LIST;

    --work action data items
    l_dataSetType           VARCHAR2(50);
    l_set_id                NUMBER;
    l_name                  VARCHAR2(500);
    l_value                 VARCHAR2(4000);  -- Niraj, 07-08-05, Bug 4482399: Increased from 500 to 4000

    -- parameters from the work item
    l_task_rec_tbl          TASK_REC_TBL;
    l_count                 NUMBER;
    l_continue              NUMBER :=0;
    -- parameters from the work panel
    l_task_name             VARCHAR2(80);
    l_type                  VARCHAR2(30); --NUMBER;
    l_priority              VARCHAR2(30); --NUMBER;
    l_status                VARCHAR2(30); --NUMBER;
    l_date_type             VARCHAR2(30);   -- lookup code
    l_planned_start         DATE;
    l_planned_end           DATE;
    l_actual_start          DATE;
    l_actual_end            DATE;
    l_sched_start           DATE;
    l_sched_end             DATE;
    l_description           VARCHAR2(4000);
    l_note                  VARCHAR2(4000);
    l_owner                 VARCHAR2(4000);
    l_owner_tmp             VARCHAR2(4000);
    l_assignee              VARCHAR2(4000);
    l_auto_relate_note      NUMBER;
    l_p_task_name             VARCHAR2(80);-- := g_miss_char;
    l_p_type                  VARCHAR2(30);--  := g_miss_char;
    l_p_priority              VARCHAR2(30);--  := g_miss_char;
    l_p_status                VARCHAR2(30);--  := g_miss_char;
    l_p_date_type             VARCHAR2(30) ;   -- lookup code
    l_p_planned_start         DATE;--  := g_miss_date;
    l_p_planned_end           DATE;--  := g_miss_date;
    l_p_actual_start          DATE;--  := g_miss_date;
    l_p_actual_end            DATE;--  := g_miss_date;
    l_p_sched_start           DATE;--  := g_miss_date;
    l_p_sched_end             DATE;--  := g_miss_date;
    l_p_description           VARCHAR2(4000);--  := g_miss_char;
    l_p_note                  VARCHAR2(4000);--  := g_miss_char;
    l_p_owner                 VARCHAR2(4000) ;
    l_p_owner_tmp             VARCHAR2(4000) ;
    l_p_assignee              VARCHAR2(4000) ;
    l_p_auto_relate_note      NUMBER;



    -- misc variables required for calling api
    l_obj_type_code         VARCHAR2(60); -- Niraj, 07-08-05, Bug 4482399: Increased from 30 to 60
    l_obj_id                NUMBER;
    l_obj_name              VARCHAR2(80);
    l_object_version_number NUMBER;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_owner_id              NUMBER;
    l_owner_type_code       VARCHAR2(30);
    l_owner_id_tmp              NUMBER;
    l_owner_type_code_tmp       VARCHAR2(30);

    l_assignee_id           NUMBER;
    l_assignee_type_code    VARCHAR2(30);
    l_idx                   NUMBER;
    l_idx2                  NUMBER;
    l_exist_assign_id       NUMBER;
    l_new_assign_id         NUMBER;
    l_exist_assign_ver      NUMBER;
    l_new_assign_status     NUMBER := 3;      -- ACCEPTED status id
    l_note_context_type_id  NUMBER;
    l_source_object_id      NUMBER;

    CURSOR c_task_ass (b_task_id NUMBER) IS
      SELECT task_assignment_id, object_version_number
      FROM jtf_task_all_assignments
      WHERE task_id = b_task_id AND
            assignee_role <> 'OWNER';

    -- notes related parameters
    l_note_id               NUMBER;
    l_context_id            NUMBER;
    l_note_ctxt_tbl         jtf_notes_pub.jtf_note_contexts_tbl_type;
    l_note_ctxt_idx         NUMBER;

    cursor C_note_context_id(p_object_id NUMBER) is
      select contact_id
      from jtf_task_contacts
      where task_id =  p_object_id
      and (primary_flag is null or primary_flag = 'Y')
      order by primary_flag;


    CURSOR c_task_src (b_task_id NUMBER) IS
      SELECT tb.source_object_type_code
      FROM jtf_object_usages ou,
           jtf_tasks_b tb
      WHERE
        tb.task_id = b_task_id and
        ou.object_user_code = 'NOTES' and
        ou.object_code = tb.source_object_type_code;

    -- exceptions raised in this procedure
    null_fail_exception EXCEPTION;
    fail_exception        EXCEPTION;
    name_fail_exception        EXCEPTION;

    -- cheating GSCC
    l_date_fmt             CONSTANT VARCHAR2(30) := 'DD-MON-RRRR HH24:MI:SS';


BEGIN

 l_note_status := nvl(fnd_profile.value('JTF_NTS_NOTE_STATUS'),'I');
 --DELETE FROM msista_tmp;
 --commit;
 --INSERT INTO msista_Tmp values (11, 'P_Action_Type is '|| P_Action_Type);
 --commit;

 SAVEPOINT update_task_savepoint;

 -- initialize fnd's message list
 fnd_msg_pub.initialize();

 -- Get all the required parameters from Action Input List
 -- required parameters are TBD.

  /*
    To Do -
    a. loop through the work_action_Data
    b. identify 'work_item_data'
    c. collect the task_id for each DataSetID that comes through into l_task_rec_tbl
    d. collect the 'action_param_data' that comes through into the set of params
    e. if task_Rec_tbl.count > 1 => multi-select mode
    f. if multi-select mode, we should ignore some of the parameters (per reqmnt).
    g. loop through l_task_rec_tbl and call update_task for each task_id - do not --commit.
    g1. break out of loop if any update_task fails.
    h. if all task items were updated successfully - --commit.
    i. if any task update fails, roll back and return error message.
  */
  --INSERT  INTO msista_Tmp values (20, 'entering for(p_action_input_data) loop');
  --commit;
  --** These default values have been added as part of bug #4706930 - MS **---
      l_p_task_name             := FND_API.G_MISS_CHAR;
      l_p_type                  := FND_API.G_MISS_CHAR;
      l_p_priority              := FND_API.G_MISS_CHAR;
      l_p_status                := FND_API.G_MISS_CHAR;

      l_p_planned_start         := FND_API.G_MISS_DATE;
      l_p_planned_end           := FND_API.G_MISS_DATE;
      l_p_actual_start          := FND_API.G_MISS_DATE;
      l_p_actual_end            := FND_API.G_MISS_DATE;
      l_p_sched_start           := FND_API.G_MISS_DATE;
      l_p_sched_end             := FND_API.G_MISS_DATE;
      l_p_description           := FND_API.G_MISS_CHAR;
      l_p_note                  := FND_API.G_MISS_CHAR;

  for i in 1..p_action_input_data.COUNT LOOP

      l_dataSetType := p_action_input_data(i).dataSetType;
      if (l_dataSetType = 'WORK_ITEM_DATA')      then

        l_set_id := p_action_input_data(i).dataSetId;
        l_name  := p_action_input_data (i).name;
        l_value := p_action_input_data (i).value;

        --INSERT INTO msista_Tmp values (30, 'found WORK_ITEM_DATA, set_id = ' || l_set_id || ', name - ''' || l_name || ''', value = ''' || l_value || '''');
        --commit;
        if (l_name = 'TASK_ID') then
          l_task_rec_tbl(l_set_id).id := l_value;
        ELSIF (l_name = 'SOURCE_OBJECT_ID') THEN
          l_task_rec_tbl(l_set_id).source_id := l_value;
        ELSIF (l_name = 'IEU_ACTION_OBJECT_CODE') THEN
          l_task_rec_tbl(l_set_id).source_type_code := l_value;
--        ELSIF (l_name = 'TASK_PRIORITY') THEN    ---- getting this value for reassign, reschedule, and transfer owner actions.
--          l_task_rec_tbl(l_set_id).priority_name := l_value;
        ELSIF (l_name = 'OBJECT_VERSION_NUMBER') THEN
          l_task_rec_tbl(l_set_id).object_version_number := l_value;
         end if;


      elsif (l_dataSetType = 'ACTION_PARAM_DATA')
      then

        --don't care for l_set_id for action parameter data
        l_name  := p_action_input_data (i).name;
        l_value := p_action_input_data (i).value;

        --INSERT INTO msista_Tmp values (40, 'found ACTION_PARAM_DATA, name - ''' || l_name || ''', value = ''' || l_value || '''');
        --commit;

        IF (l_name = 'TASK_NAME') THEN
          l_p_task_name := l_value;
        ELSIF (l_name = 'TASK_TYPE') THEN
          l_p_type := l_value;
        ELSIF (l_name = 'TASK_PRIORITY') THEN
          l_p_priority := l_value;
        ELSIF (l_name = 'TASK_STATUS') THEN
          l_p_status := l_value;
        ELSIF (l_name = 'PLANNED_START_DATE') THEN
          l_p_planned_start := TO_DATE(l_value, l_date_fmt);
        ELSIF (l_name = 'PLANNED_END_DATE') THEN
          l_p_planned_end := TO_DATE(l_value, l_date_fmt);
        ELSIF (l_name = 'ACTUAL_START_DATE') THEN
          l_p_actual_start := TO_DATE(l_value, l_date_fmt);
        ELSIF (l_name = 'ACTUAL_END_DATE') THEN
          l_p_actual_end := TO_DATE(l_value, l_date_fmt);
        ELSIF (l_name = 'SCHED_START_DATE') THEN
          l_p_sched_start := TO_DATE(l_value, l_date_fmt);
        ELSIF (l_name = 'SCHEDULED_END') THEN
          l_p_sched_end := TO_DATE(l_value, l_date_fmt);
        ELSIF (l_name = 'DESCRIPTION') THEN
          l_p_description := l_value;
        ELSIF (l_name = 'NEW_NOTE') THEN
          l_p_note := l_value;
        ELSIF (l_name = 'OWNER') THEN
          l_p_owner := l_value;
        ELSIF (l_name = 'ASSIGNEE') THEN
          l_p_assignee := l_value;
        END IF;
      end if;
  end loop;

  -- parameters validations
  -- number of tasks selected in uwq
  l_count := l_task_rec_tbl.COUNT;
  if (l_count = 1) then -- single mode
      -- single mode requires task type, priority, and status
      /*
      Update Task:
        Checked by Form:N/A
        Checked by API:Task Status, Task Type

       Close Task
        Checked by Form: N/A
        Checked by API:Task Status,Task Type

       Reassign  Task:
        Checked by Form:Task Assignee
        Checked by API: N/A

       Reschedule Task:
        Checked by Form: N/A
        Checked by API: N/A

       Transfer Task:
        Checked by Form: Task Owner
        Checked by API: N/A
      */
      if (l_p_task_name is null) then
         RAISE name_fail_exception;
      end if;
      if ((p_Action_Type = 'UPDATE_TASK' or p_Action_TYPE = 'CLOSE_TASK')
           and (l_p_type is null  or l_p_status is null)) then
         -- ROLLBACK TO update_task_savepoint;
          --INSERT INTO msista_Tmp values (45, 'null_fail_exception');
          --commit;

          RAISE null_fail_exception;
      end if;
   END if;

  /*
    e. if task_Rec_tbl.count > 1 => multi-select mode
    f. if multi-select mode, we should ignore some of the parameters (per reqmnt).
    g. loop through l_task_rec_tbl and call update_task for each task_id - do not --commit.
    g1. break out of loop if any update_task fails.
    h. if all task items were updated successfully - --commit.
    i. if any task update fails, roll back and return error message.
  */

   -- task api uses g_miss* values for defaults
  IF (l_p_task_name is NULL) THEN
      --INSERT INTO msista_Tmp values (42, 'l_task_name is null');
      --commit;

      l_task_name := FND_API.G_MISS_CHAR;
  ELSE
      --INSERT INTO msista_Tmp values (42, 'l_task_name <> null');
      --commit;

      l_task_name := l_p_task_name;
  END IF;
  IF ( l_p_type is NULL ) THEN
      --INSERT INTO msista_Tmp values (42, 'l_type is null');
      --commit;

      l_type := FND_API.G_MISS_CHAR;    --G_MISS_NUM;
  ELSE
      --INSERT INTO msista_Tmp values (42, 'l_type <> null');
      --commit;

      l_type := l_p_type;
  END IF;
  IF (l_p_description is NULL ) THEN
      --INSERT INTO msista_Tmp values (42, 'l_description is null');
      --commit;
        l_description := FND_API.G_MISS_CHAR;
  ELSE
      --INSERT INTO msista_Tmp values (42, 'l_description <> null');
      --commit;

      l_description := l_p_description;
  END IF;
  IF (l_p_status is NULL ) THEN
      --INSERT INTO msista_Tmp values (42, 'l_status is null');
      --commit;

      l_status := FND_API.G_MISS_CHAR;    --g_miss_num;
  ELSE
      --INSERT INTO msista_Tmp values (42, 'l_status <> null');
      --commit;

      l_status := l_p_status;
  END IF;
  IF ((l_count > 1 AND l_p_priority is NULL ) or
      (l_count = 1 AND l_p_priority is NULL )) THEN
      --INSERT INTO msista_Tmp values (42, 'l_priority is null');
      --commit;

      l_priority := FND_API.G_MISS_CHAR;    --g_miss_num;
  ELSE
      --INSERT INTO msista_Tmp values (42, 'l_count is '||l_count||',l_priority <> null and it is '||l_p_priority);
      --commit;

      l_priority := l_p_priority;
  END IF;
  IF (l_p_owner is NULL) THEN
      --INSERT INTO msista_Tmp values (42, 'l_owner is null');
      --commit;

      l_owner_id := FND_API.G_MISS_NUM;
      l_owner_type_code := FND_API.G_MISS_CHAR;
  ELSE
      --INSERT INTO msista_Tmp values (42, 'l_owner <> null, parsing l_owner='||l_owner);
      --commit;

      -- owner type code is bundled with owner code, need to break them apart
      l_owner := l_p_owner;
      l_idx := INSTR(l_owner, G_OPEN_SQBR, 1, 1);
      l_idx2 := INSTR(l_owner, G_CLOSE_SQBR, -1, 1);
      l_owner_id := TO_NUMBER(SUBSTR(l_owner, 1, l_idx-1));
      l_owner_type_code := SUBSTR(l_owner, l_idx+1, l_idx2-l_idx-1);
      --INSERT INTO msista_Tmp values (42, 'l_owner_id - ''' || l_owner_id || ''', l_owner_type_code - ''' || l_owner_type_code || '''');
      --commit;

  END IF;
  IF (l_p_assignee is NULL) THEN
      --INSERT INTO msista_Tmp values (42, 'l_assignee is null');
      --commit;

      l_assignee_id := FND_API.G_MISS_NUM;
      l_assignee_type_code := FND_API.G_MISS_CHAR;
  ELSE
      --INSERT  INTO msista_Tmp values (42, 'l_assignee <> null, parsing');
      --commit;

      -- assignee type code is bundled with assignee code, break them apart
      l_assignee := l_p_assignee;
      l_idx := INSTR(l_assignee, G_OPEN_SQBR, 1, 1);
      l_idx2 := INSTR(l_assignee, G_CLOSE_SQBR, -1, 1);
      l_assignee_id := TO_NUMBER(SUBSTR(l_assignee, 1, l_idx-1));
      l_assignee_type_code := SUBSTR(l_assignee, l_idx+1, l_idx2-l_idx-1);
      --INSERT  INTO msista_Tmp values (42, 'l_assignee_id - ''' || l_assignee_id || ''', l_assignee_type_code - ''' || l_assignee_type_code || '''');
      --commit;

  END IF;
  IF (l_count > 1 AND l_p_planned_start is NULL) THEN
      --INSERT  INTO msista_Tmp values (42, 'l_planned_start is null');
      --commit;

      l_planned_start := FND_API.G_MISS_DATE;
  ELSE
      --INSERT  INTO msista_Tmp values (42, 'l_planned_start <> null');
      --commit;

      l_planned_start := l_p_planned_start;
  END IF;
  IF (l_count > 1 AND l_p_planned_end is NULL) THEN
      --INSERT  INTO msista_Tmp values (42, 'l_planned_end is null');
      --commit;

      l_planned_end := FND_API.G_MISS_DATE;
  ELSE
      --INSERT  INTO msista_Tmp values (42, 'l_planned_end <> null');
      --commit;

      l_planned_end :=l_p_planned_end;
  END IF;
  IF (l_count > 1 AND l_p_actual_start is NULL) THEN
      --INSERT  INTO msista_Tmp values (42, 'l_actual_start is null');
      --commit;

      l_actual_start := FND_API.G_MISS_DATE;
  ELSE
      --INSERT  INTO msista_Tmp values (42, 'l_actual_start <> null');
      --commit;

      l_actual_start := l_p_actual_start;
  END IF;
  IF (l_count > 1 AND l_p_actual_end is NULL) THEN
      --INSERT  INTO msista_Tmp values (42, 'l_actual_end is null');
      --commit;

      l_actual_end := FND_API.G_MISS_DATE;
  ELSE
      --INSERT  INTO msista_Tmp values (42, 'l_actual_end <> null');
      --commit;

      l_actual_end := l_p_actual_end;
  END IF;
  IF (l_count > 1 AND l_p_sched_start is NULL) THEN
      --INSERT  INTO msista_Tmp values (42, 'l_sched_start is null');
      --commit;

      l_sched_start := FND_API.G_MISS_DATE;
  ELSE
      --INSERT  INTO msista_Tmp values (42, 'l_sched_start <> null');
      --commit;

      l_sched_start := l_p_sched_start;
  END IF;
  IF (l_count > 1 AND l_p_sched_end is NULL) THEN

      --INSERT  INTO msista_Tmp values (42, 'l_sched_end is null');
      --commit;

      l_sched_end := FND_API.G_MISS_DATE;
  ELSE
      --INSERT  INTO msista_Tmp values (42, 'l_sched_end <> null');
      --commit;

      l_sched_end := l_p_sched_end;
  END IF;


  FOR i IN 1..l_count LOOP

    /* if actions are Reassign, Reschedule or Transfer Owner then get the priority name from work_item_data
       else get the priority name from action_param_data

    if (p_action_type = 'REASSIGN_TASK' or p_action_type = 'RESCHEDULE_TASK'
        or p_action_type = 'TRANSFER_TASK_OWNER_TASK') then
       l_priority := l_task_rec_tbl(i).priority_name;
    else
       l_priority := l_p_priority;
    end if;

    -- This code is not required because these changes now, update/close task actions in multi select mode
    -- throws an error.

   */

    --INSERT  INTO msista_Tmp values (49, 'inside update task loop '|| i);
    --  --commit;
    -- get current object_version_number of task to updated

    -- 09/24/03 commented this code because getting the object_version_number from p_action_input_data. (fix bug 3127477)
/*
    SELECT object_version_number INTO l_object_version_number
    FROM jtf_tasks_b WHERE task_id = l_task_rec_tbl(i).id;
*/

    -- call the update_task api to update the task object
    --INSERT  INTO msista_Tmp values (50, 'calling update_task, with params :- ');
    --INSERT  INTO msista_Tmp values (51, 'p_api_version                       => ''' || l_api_version || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_init_msg_list                     => ''' || G_FALSE || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_--commit                            => ''' || G_FALSE || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_object_version_number             => ''' || l_object_version_number || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_task_id                           => ''' || l_task_rec_tbl(i).id || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_task_name                         => ''' || l_task_name || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_task_type_name                    => ''' || l_type || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_description                       => ''' || l_description || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_task_status_name                  => ''' || l_status || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_task_priority_name                => ''' || l_priority || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_owner_type_code                   => ''' || l_owner_type_code || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_owner_id                          => ''' || l_owner_id || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_assigned_by_id                    => ''' || l_assignee_id || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_planned_start_date                => ''' || l_planned_start || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_planned_end_date                  => ''' || l_planned_end || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_scheduled_start_date              => ''' || l_actual_start || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_scheduled_end_date                => ''' || l_actual_end || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_actual_start_date                 => ''' || l_sched_start || '''');
    --INSERT  INTO msista_Tmp values (51, 'p_actual_end_date                   => ''' || l_sched_end || '''');
    --INSERT  INTO msista_Tmp values (51, 'x_return_status                     => ''' || l_return_status || '''');
    --INSERT  INTO msista_Tmp values (51, 'x_msg_count                         => ''' || l_msg_count || '''');
    --INSERT  INTO msista_Tmp values (51, 'x_msg_data                          => ''' || l_msg_data || '''');
    --commit;

    jtf_tasks_pub.update_task(
      p_api_version                       => l_api_version,
      p_init_msg_list                     => G_FALSE,
      p_commit                            => G_FALSE,
      p_object_version_number             => l_task_rec_tbl(i).object_version_number,
      p_task_id                           => l_task_rec_tbl(i).id,
      p_task_name                         => l_task_name,
      p_task_type_name                    => l_type,
      p_description                       => l_description,
      p_task_status_name                  => l_status,
      p_task_priority_name                => l_priority,
      p_owner_type_code                   => l_owner_type_code,
      p_owner_id                          => l_owner_id,
      p_planned_start_date                => l_planned_start,
      p_planned_end_date                  => l_planned_end,
      p_scheduled_start_date              => l_sched_start,
      p_scheduled_end_date                => l_sched_end,
      p_actual_start_date                 => l_actual_start,
      p_actual_end_date                   => l_actual_end,
      x_return_status                     => l_return_status,
      x_msg_count                         => l_msg_count,
      x_msg_data                          => l_msg_data
    );

    --if call fails, break out of loop
    IF NOT (l_return_status = G_SUCCESS) THEN
      --INSERT  INTO msista_Tmp values (60, 'update_task failed, ret_status - ' || l_return_status);
      --INSERT  INTO msista_Tmp values (60, 'update_task failed, msg_count - ' || l_msg_count);
      --INSERT  INTO msista_Tmp values (60, 'update_task failed, msg_data - ' || l_msg_data);
      --commit;

      --fnd_msg_pub.count_and_get (
      --  p_count => l_msg_count,
      --  p_data => l_msg_data
      --);
      --INSERT  INTO msista_Tmp values (60, 'update_task failed, msg_count - ' || l_msg_count);
      --INSERT  INTO msista_Tmp values (60, 'update_task failed, msg_data - ' || l_msg_data);
      --commit;

      RAISE fail_exception;
    ELSE
      --INSERT  INTO msista_Tmp values (60, 'update_task OK, ret_status - ' || l_return_status);
      --commit;

      NULL;
    END IF;

    -- if task assignment is being modified, it has to be dealt with separately
    IF (l_assignee IS NOT NULL) THEN
      /*
       to do
       a. delete all existing assignments
       b. assign task to specified assignee
       c. --commit
      */
      -- a
      OPEN c_task_ass (l_task_rec_tbl(i).id);
      LOOP
        FETCH c_task_ass INTO l_exist_assign_id, l_exist_assign_ver;

        -- not a problem if task is not currently assigned, exit loop.
        IF c_task_ass%FOUND THEN

          --INSERT  INTO msista_Tmp values (62, 'deleting task_assignment - ' || l_exist_assign_id);
          --commit;

          -- delete assignments one by one
          jtf_task_assignments_pub.delete_task_assignment(
            p_api_version             => l_api_version,
            p_object_version_number   => l_exist_assign_ver,
            p_init_msg_list           => G_FALSE,
            p_commit                  => G_FALSE,
            p_task_assignment_id      => l_exist_assign_id,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
          );

          IF NOT (l_return_status = G_SUCCESS) THEN
            --INSERT  INTO msista_Tmp values (62, 'delete_task_assignment failed, ret_status - ' || l_return_status);
            --INSERT  INTO msista_Tmp values (62, 'delete_task_assignment failed, msg_count - ' || l_msg_count);
            --INSERT  INTO msista_Tmp values (62, 'delete_task_assignment failed, msg_data - ' || l_msg_data);
            --commit;

            RAISE fail_exception;
          ELSE
            --INSERT  INTO msista_Tmp values (62, 'delete_task_assignment OK, ret_status - ' || l_return_status);
            --commit;

	    NULL;
          END IF;
        ELSE
          EXIT;
        END IF;
      END LOOP;

      IF (c_task_ass%ISOPEN) THEN
        CLOSE c_task_ass;
      END IF;

      -- b
      jtf_task_assignments_pub.create_task_assignment(
        p_api_version                 => l_api_version,
        p_init_msg_list               => G_FALSE,
        p_commit                      => G_FALSE,
        p_task_id                     => l_task_rec_tbl(i).id,
        p_resource_type_code          => l_assignee_type_code,
        p_resource_id                 => l_assignee_id,
        p_assignment_status_id        => l_new_assign_status,
        x_return_status               => l_return_status,
        x_msg_count                   => l_msg_count,
        x_msg_data                    => l_msg_data,
        x_task_assignment_id          => l_new_assign_id,
        p_show_on_calendar            => G_YES
      );

      IF NOT (l_return_status = G_SUCCESS) THEN
        --INSERT  INTO msista_Tmp values (64, 'create_task_assignment failed, ret_status - ' || l_return_status);
        --INSERT  INTO msista_Tmp values (64, 'create_task_assignment failed, msg_count - ' || l_msg_count);
        --INSERT  INTO msista_Tmp values (64, 'create_task_assignment failed, msg_data - ' || l_msg_data);
        --commit;

        RAISE fail_exception;
      ELSE
        --INSERT  INTO msista_Tmp values (64, 'create_task_assignment OK, ret_status - ' || l_return_status);
        --commit;

	NULL;
      END IF;
    END IF;

    -- next, if there is note data to be applied
    -- call note creation api
    IF (l_p_note IS NOT NULL) THEN
      -- by default the note has to be related to the task
      l_note_ctxt_idx := 1;
      l_note_ctxt_tbl(l_note_ctxt_idx).NOTE_CONTEXT_TYPE := l_src_task;
      l_note_ctxt_tbl(l_note_ctxt_idx).NOTE_CONTEXT_TYPE_ID := l_task_rec_tbl(i).id;
      l_note_ctxt_idx := l_note_ctxt_idx+1;

      jtf_notes_pub.create_note(
          -- p_parent_note_id    => fnd_api.g_miss_num,
          -- p_jtf_note_id            => fnd_api.g_miss_num,
          p_api_version           => l_api_version,
          p_init_msg_list         => G_FALSE,
          p_commit                => G_FALSE,
          p_validation_level      =>  l_valid_level_full,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data,
          -- p_org_id               =>   NULL,
          p_source_object_id      => l_task_rec_tbl(i).id,
          p_source_object_code    => l_src_task,
          p_notes                 => l_p_note
          --, p_notes_detail          => NULL
          , p_note_status           => 'I'
          ,p_entered_date          => TO_DATE('1','j'),
          x_jtf_note_id           => l_note_id
          , p_last_update_date      => TO_DATE('1','j')
          , p_last_updated_by       => fnd_global.user_id
          , p_creation_date         => TO_DATE('1','j')
          --, p_created_by            => fnd_global.user_id
          --, p_last_update_login     => fnd_global.login_id
          /*, p_attribute1            => NULL
          , p_attribute2            => NULL
          , p_attribute3            => NULL
          , p_attribute4            => NULL
          , p_attribute5            => NULL
          , p_attribute6            => NULL
          , p_attribute7            => NULL
          , p_attribute8            => NULL
          , p_attribute9            => NULL
          , p_attribute10           => NULL
          , p_attribute11           => NULL
          , p_attribute12           => NULL
          , p_attribute13           => NULL
          , p_attribute14           => NULL
          , p_attribute15           => NULL
          , p_context               => NULL
          , p_note_type             => NULL*/,
          p_jtf_note_contexts_tab => l_note_ctxt_tbl
          ,        p_entered_by            => G_USER_ID
      );

      IF NOT (l_return_status = G_SUCCESS) THEN
        RAISE fail_exception;
      ELSE
        -- we have to do some additional work if 'auto-relate note' is true
        IF (FND_PROFILE.VALUE('IEU_AUTO_RELATED') = 'Y') THEN -- this is for source document
	  l_continue := 0;
	  select count(source_object_id) into l_continue
	  from jtf_tasks_b
	  where task_id = l_task_rec_tbl(i).id;

          if (l_continue > 0) then
		  select source_object_id into l_note_context_type_id
		  from jtf_tasks_b
		  where task_id = l_task_rec_tbl(i).id;
          else l_note_context_type_id := null;
          end if;

          OPEN c_task_src(l_task_rec_tbl(i).id);
          FETCH c_task_src INTO l_obj_type_code;

          -- if the source object type of the task is registered for notes usage,
          -- create a note context for
          IF (c_task_src%FOUND) THEN
           if (l_note_context_type_id is not null) then
		    jtf_notes_pub.Create_note_context
		    ( p_validation_level     => l_valid_level_full,
		      p_jtf_note_id          => l_note_id,
		      p_last_update_date     => FND_API.G_MISS_DATE,
		      p_last_updated_by      => G_USER_ID,
		      p_creation_date        => FND_API.G_MISS_DATE,
		      p_note_context_type_id => l_note_context_type_id,
		      p_note_context_type    => l_obj_type_code,
		      x_return_status        => l_return_status,
		      x_note_context_id      => l_context_id
		    );


		    IF NOT (l_return_status = G_SUCCESS) THEN
		      RAISE fail_exception;
		    ELSE
		      NULL;
		    END IF;
	   end if;
          END IF; -- if cursor%found

          IF (c_task_src%ISOPEN) THEN
            CLOSE c_task_src;
          END IF;

        END IF; -- auto_relate = 1

	IF (FND_PROFILE.VALUE('AS_NOTES_LEAD_CUSTOMER') = 'Y') THEN
	  l_continue := 0;
	  select count(customer_id) into l_continue
	  from jtf_tasks_b
	  where task_id = l_task_rec_tbl(i).id;

          if (l_continue > 0) then
		  select customer_id into l_note_context_type_id
		  from jtf_tasks_b
		  where task_id = l_task_rec_tbl(i).id;
          else l_note_context_type_id := null;
          end if;

          OPEN c_task_src(l_task_rec_tbl(i).id);
          FETCH c_task_src INTO l_obj_type_code;

          -- if the source object type of the task is registered for notes usage,
          -- create a note context for
	  if (l_obj_type_code = 'LEAD'  ) then
		  IF (c_task_src%FOUND) THEN
			  if (l_note_context_type_id is not null) then
				    jtf_notes_pub.Create_note_context
				    ( p_validation_level     => l_valid_level_full,
				      p_jtf_note_id          => l_note_id,
				      p_last_update_date     => FND_API.G_MISS_DATE,
				      p_last_updated_by      => G_USER_ID,
				      p_creation_date        => FND_API.G_MISS_DATE,
				      p_note_context_type_id => l_note_context_type_id,
				      p_note_context_type    => 'PARTY',
				      x_return_status        => l_return_status,
				      x_note_context_id      => l_context_id
				    );


				    IF NOT (l_return_status = G_SUCCESS) THEN
				      RAISE fail_exception;
				    ELSE
				      NULL;
				    END IF;
			  end if;
		   end if;-- if c_task_src%FOUND
          END IF; -- l_obj_type_code = 'LEAD'

          IF (c_task_src%ISOPEN) THEN
            CLOSE c_task_src;
          END IF;

        END IF; -- if AS_NOTES_LEAD_CUSTOMER


	IF (FND_PROFILE.VALUE('AS_NOTES_LEAD_CONTACT') = 'Y') THEN
          --INSERT  INTO msista_Tmp values (70, 'auto related profile is YES' );
          --commit;
          l_continue := 0;
	  for c2_rec in  C_note_context_id (l_task_rec_tbl(i).id)
		LOOP
                    if l_continue = 0 then
		       l_note_context_type_id := c2_rec.contact_id;
		       l_continue := l_continue +1;
		    end if;
	  end loop;

          OPEN c_task_src(l_task_rec_tbl(i).id);
          FETCH c_task_src INTO l_obj_type_code;

          -- if the source object type of the task is registered for notes usage,
          -- create a note context for
	  if ( l_obj_type_code = 'LEAD'  ) then
		  IF (c_task_src%FOUND) THEN
			  if (l_note_context_type_id is not null) then
				    jtf_notes_pub.Create_note_context
				    ( p_validation_level     => l_valid_level_full,
				      p_jtf_note_id          => l_note_id,
				      p_last_update_date     => FND_API.G_MISS_DATE,
				      p_last_updated_by      => G_USER_ID,
				      p_creation_date        => FND_API.G_MISS_DATE,
				      p_note_context_type_id => l_note_context_type_id,
				      p_note_context_type    => 'PARTY',
				      x_return_status        => l_return_status,
				      x_note_context_id      => l_context_id
				    );


				    IF NOT (l_return_status = G_SUCCESS) THEN
				      RAISE fail_exception;
				    ELSE
				      NULL;
				    END IF;
			   end if;
		   end if;-- if c_task_src%FOUND
          END IF; -- if  l_obj_type_code = 'LEAD'

          IF (c_task_src%ISOPEN) THEN
            CLOSE c_task_src;
          END IF;

        END IF; -- IF (FND_PROFILE.VALUE('AS_NOTES_LEAD_CONTACT') = 'Y')

	IF (FND_PROFILE.VALUE('AS_NOTES_OPP_CUSTOMER') = 'Y') THEN
          --INSERT  INTO msista_Tmp values (70, 'auto related profile is YES' );
          --commit;
          l_continue := 0;
          select count(customer_id) into l_continue
	  from jtf_tasks_b
          where task_id = l_task_rec_tbl(i).id;

	  if (l_continue > 0) then
              select customer_id into l_note_context_type_id
              from jtf_tasks_b
              where task_id = l_task_rec_tbl(i).id;
          else l_note_context_type_id := null;
          end if;

          OPEN c_task_src(l_task_rec_tbl(i).id);
          FETCH c_task_src INTO l_obj_type_code;

          -- if the source object type of the task is registered for notes usage,
          -- create a note context for
	  if (l_obj_type_code = 'OPPORTUNITY'  ) then
		  IF (c_task_src%FOUND) THEN
			  if (l_note_context_type_id is not null) then
			    jtf_notes_pub.Create_note_context
			    ( p_validation_level     => l_valid_level_full,
			      p_jtf_note_id          => l_note_id,
			      p_last_update_date     => FND_API.G_MISS_DATE,
			      p_last_updated_by      => G_USER_ID,
			      p_creation_date        => FND_API.G_MISS_DATE,
			      p_note_context_type_id => l_note_context_type_id,
			      p_note_context_type    => 'PARTY',
			      x_return_status        => l_return_status,
			      x_note_context_id      => l_context_id
			    );


			    IF NOT (l_return_status = G_SUCCESS) THEN
			      --INSERT  INTO msista_Tmp values (74, 'create_note_context failed, ret_status - ' || l_return_status);
			      --INSERT  INTO msista_Tmp values (74, 'create_note_context failed, msg_count - ' || l_msg_count);
			      --INSERT  INTO msista_Tmp values (74, 'create_note_context failed, msg_data - ' || l_msg_data);
			      --commit;

			      RAISE fail_exception;
			    ELSE
			      NULL;
			    END IF;
			  end if;
		  end if;-- if c_task_src%FOUND.
          END IF; -- if l_obj_type_code = 'OPPORTUNITY'

          IF (c_task_src%ISOPEN) THEN
            CLOSE c_task_src;
          END IF;

        END IF; -- IF (FND_PROFILE.VALUE('AS_NOTES_OPP_CUSTOMER') = 'Y')


	IF (FND_PROFILE.VALUE('AS_NOTES_OPP_CONTACT') = 'Y') THEN
          --INSERT  INTO msista_Tmp values (70, 'auto related profile is YES' );
          --commit;
          l_continue := 0;
	  for c2_rec in  C_note_context_id (l_task_rec_tbl(i).id)
		LOOP
                    if l_continue = 0 then
		       l_note_context_type_id := c2_rec.contact_id;
		       l_continue := l_continue +1;
		    end if;
		end loop;

          OPEN c_task_src(l_task_rec_tbl(i).id);
          FETCH c_task_src INTO l_obj_type_code;

          -- if the source object type of the task is registered for notes usage,
          -- create a note context for
	  if ( l_obj_type_code = 'OPPORTUNITY'  ) then
		  IF (c_task_src%FOUND) THEN
			  if (l_note_context_type_id is not null) then
			    jtf_notes_pub.Create_note_context
			    ( p_validation_level     => l_valid_level_full,
			      p_jtf_note_id          => l_note_id,
			      p_last_update_date     => FND_API.G_MISS_DATE,
			      p_last_updated_by      => G_USER_ID,
			      p_creation_date        => FND_API.G_MISS_DATE,
			      p_note_context_type_id => l_note_context_type_id,
			      p_note_context_type    => 'PARTY',
			      x_return_status        => l_return_status,
			      x_note_context_id      => l_context_id
			    );


			    IF NOT (l_return_status = G_SUCCESS) THEN

			      RAISE fail_exception;
			    ELSE
			      NULL;
			    END IF;
			  end if;
		  end if;-- if lead...
          END IF; -- if cursor%found

          IF (c_task_src%ISOPEN) THEN
            CLOSE c_task_src;
          END IF;
        END IF; -- IF (FND_PROFILE.VALUE('AS_NOTES_OPP_CONTACT') = 'Y')

	IF (FND_PROFILE.VALUE('AS_NOTES_REL_OBJECT') = 'Y') THEN
		l_continue := 0;
		select count(a.object_id) into l_continue
		from hz_relationships a, hz_parties b
		where b.party_type = 'PARTY_RELATIONSHIP'
		      and a.party_id in (select source_object_id
						from jtf_tasks_b
						where task_id = l_task_rec_tbl(i).id)
		      and a.party_id = b.party_id
		      and a.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		      AND a.OBJECT_TABLE_NAME = 'HZ_PARTIES'
		      AND DIRECTIONAL_FLAG = 'F';

		if (l_continue > 0) then
		 select a.object_id into l_note_context_type_id
		 from hz_relationships a, hz_parties b
		 where b.party_type = 'PARTY_RELATIONSHIP'
		       and a.party_id  in (select source_object_id
						from jtf_tasks_b
						where task_id = l_task_rec_tbl(i).id)
		       and a.party_id = b.party_id
      		       and a.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		       AND a.OBJECT_TABLE_NAME = 'HZ_PARTIES'
		       AND DIRECTIONAL_FLAG = 'F';

		else l_note_context_type_id :=null;
		end if ;

	        OPEN c_task_src(l_task_rec_tbl(i).id);
		FETCH c_task_src INTO l_obj_type_code;

		-- if the source object type of the task is registered for notes usage,
		-- create a note context for
		if (l_obj_type_code = 'PARTY'  ) then
			  IF (c_task_src%FOUND) THEN
				  if (l_note_context_type_id is not null) then
				   jtf_notes_pub.Create_note_context
				    ( p_validation_level     => l_valid_level_full,
				      p_jtf_note_id          => l_note_id,
				      p_last_update_date     => FND_API.G_MISS_DATE,
				      p_last_updated_by      => G_USER_ID,
				      p_creation_date        => FND_API.G_MISS_DATE,
				      p_note_context_type_id => l_note_context_type_id,
				      p_note_context_type    => 'PARTY',
				      x_return_status        => l_return_status,
				      x_note_context_id      => l_context_id
				    );


				    IF NOT (l_return_status = G_SUCCESS) THEN
				      RAISE fail_exception;
				    ELSE
				      NULL;
				    END IF;
				  end if;
		          end if;-- if lead...
                END IF; -- if cursor%found

		IF (c_task_src%ISOPEN) THEN
		    CLOSE c_task_src;
		END IF;
        END IF; --IF (FND_PROFILE.VALUE('AS_NOTES_REL_OBJECT') = 'Y')


	IF (FND_PROFILE.VALUE('AS_NOTES_REL_SUBJECT') = 'Y') THEN
	 l_continue := 0;
	 select count(a.subject_id) into l_continue
         from hz_relationships a, hz_parties b
         where b.party_type = 'PARTY_RELATIONSHIP'
	            and a.party_id = (select source_object_id
	                        from jtf_tasks_b
				where task_id = l_task_rec_tbl(i).id)
		    and a.party_id = b.party_id
		    and a.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		    AND a.OBJECT_TABLE_NAME = 'HZ_PARTIES'
		    AND DIRECTIONAL_FLAG = 'F';

         if (l_continue > 0) then
           select a.subject_id into l_note_context_type_id
           from hz_relationships a, hz_parties b
           where b.party_type = 'PARTY_RELATIONSHIP'
	            and a.party_id = (select source_object_id
	                        from jtf_tasks_b
				where task_id = l_task_rec_tbl(i).id)
		    and a.party_id = b.party_id
		    and a.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		    AND a.OBJECT_TABLE_NAME = 'HZ_PARTIES'
		    AND DIRECTIONAL_FLAG = 'F';

          else l_note_context_type_id := null;
          end if;

          OPEN c_task_src(l_task_rec_tbl(i).id);
          FETCH c_task_src INTO l_obj_type_code;

          -- if the source object type of the task is registered for notes usage,
          -- create a note context for
	  if ( l_obj_type_code = 'PARTY'  ) then
		  IF (c_task_src%FOUND) THEN
			  if (l_note_context_type_id is not null) then
			   jtf_notes_pub.Create_note_context
			    ( p_validation_level     => l_valid_level_full,
			      p_jtf_note_id          => l_note_id,
			      p_last_update_date     => FND_API.G_MISS_DATE,
			      p_last_updated_by      => G_USER_ID,
			      p_creation_date        => FND_API.G_MISS_DATE,
			      p_note_context_type_id => l_note_context_type_id,
			      p_note_context_type    => 'PARTY',
			      x_return_status        => l_return_status,
			      x_note_context_id      => l_context_id
			    );


			    IF NOT (l_return_status = G_SUCCESS) THEN
			      RAISE fail_exception;
			    ELSE
			      NULL;
			    END IF;
		          end if;
		  end if;-- if lead...
          END IF; -- if cursor%found

          IF (c_task_src%ISOPEN) THEN
            CLOSE c_task_src;
          END IF;
        END IF; -- if FND_PROFILE.VALUE('AS_NOTES_REL_SUBJECT') = 'Y')
      END IF; -- if create_note ok
    END IF; -- IF (l_note IS NOT NULL)

    -- continue with rest of task items
  END LOOP; -- FOR i IN 1..l_count

  -- Set UWQ Actions Data if all is OK
  l_uwq_actions_list(1).uwq_action_key := 'UWQ_WORK_DETAILS_REFRESH';
  l_uwq_actions_list(1).Action_data := '' ;
  l_uwq_actions_list(1).dialog_style := 1 ;
  l_uwq_actions_list(1).message := '' ;

  IEU_UWQ_WORK_PANEL_PUB.SET_UWQ_ACTIONS(l_uwq_actions_list,
                                         x_uwq_action_list) ;

  x_return_status := G_SUCCESS;

  -- everything went A-OK
  commit WORK;

  EXCEPTION

    -- all exceptions are the same for now
    WHEN null_fail_exception THEN
      x_return_status := G_UNEXP_ERROR;

      fnd_message.set_name ('IEU', 'IEU_STATUS_TYPE_FAIL');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (
        p_count => x_msg_count,
        p_data => x_msg_data
      );

    WHEN name_fail_exception THEN
      x_return_status := G_UNEXP_ERROR;

      fnd_message.set_name ('IEU', 'IEU_TASK_NAME_FAIL');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (
        p_count => x_msg_count,
        p_data => x_msg_data
      );

    WHEN fail_exception THEN
      x_return_status := G_UNEXP_ERROR;
      --fnd_message.set_name ('IEU', 'IEU_STATUS_TYPE_FAIL');
      if (l_msg_count is null) or (l_msg_count < 1) then
      fnd_message.set_name ('IEU', 'IEU_UPDATE_TASK_FAIL');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (
        p_count => x_msg_count,
        p_data => x_msg_data
      );
   end if;
    WHEN OTHERS THEN

      -- rollback disabled until this works right, there is a --commit at the end
      -- roll back always
      ROLLBACK TO update_task_savepoint;

      x_return_status := G_UNEXP_ERROR;

      fnd_message.set_name ('IEU', 'IEU_UPDATE_TASK_FAIL');
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get (
        p_count => x_msg_count,
        p_data => x_msg_data
      );

END WP_TASK; -- PROCEDURE WP_TASK

PROCEDURE CLOSE_TASK
( P_RESOURCE_ID       IN NUMBER,
  P_LANGUAGE          IN VARCHAR2,
  P_SOURCE_LANG       IN VARCHAR2,
  P_ACTION_KEY        IN VARCHAR2,
  P_ACTION_INPUT_DATA IN SYSTEM.ACTION_INPUT_DATA_NST,
  X_UWQ_ACTION_LIST   OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
  X_MSG_COUNT         OUT NOCOPY NUMBER,
  X_MSG_DATA          OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS     OUT NOCOPY VARCHAR2
)
IS
BEGIN
  IEU_WPACTIONS_PVT.WP_TASK(P_RESOURCE_ID,
			P_LANGUAGE   ,
			P_SOURCE_LANG,
			P_ACTION_KEY ,
			P_ACTION_INPUT_DATA ,
			'CLOSE_TASK',
			X_UWQ_ACTION_LIST  ,
			X_MSG_COUNT        ,
			X_MSG_DATA         ,
			X_RETURN_STATUS);

END CLOSE_TASK; -- PROCEDURE CLOSE_TASK


PROCEDURE UPDATE_TASK
( P_RESOURCE_ID       IN NUMBER,
  P_LANGUAGE          IN VARCHAR2,
  P_SOURCE_LANG       IN VARCHAR2,
  P_ACTION_KEY        IN VARCHAR2,
  P_ACTION_INPUT_DATA IN SYSTEM.ACTION_INPUT_DATA_NST,
  X_UWQ_ACTION_LIST   OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
  X_MSG_COUNT         OUT NOCOPY NUMBER,
  X_MSG_DATA          OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS     OUT NOCOPY VARCHAR2
)
IS
BEGIN
  IEU_WPACTIONS_PVT.WP_TASK(P_RESOURCE_ID,
			P_LANGUAGE   ,
			P_SOURCE_LANG,
			P_ACTION_KEY ,
			P_ACTION_INPUT_DATA ,
			'UPDATE_TASK',
			X_UWQ_ACTION_LIST  ,
			X_MSG_COUNT        ,
			X_MSG_DATA         ,
			X_RETURN_STATUS);

END UPDATE_TASK; -- PROCEDURE UPDATE_TASK

PROCEDURE REASSIGN_TASK
( P_RESOURCE_ID       IN NUMBER,
  P_LANGUAGE          IN VARCHAR2,
  P_SOURCE_LANG       IN VARCHAR2,
  P_ACTION_KEY        IN VARCHAR2,
  P_ACTION_INPUT_DATA IN SYSTEM.ACTION_INPUT_DATA_NST,
  X_UWQ_ACTION_LIST   OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
  X_MSG_COUNT         OUT NOCOPY NUMBER,
  X_MSG_DATA          OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS     OUT NOCOPY VARCHAR2
)
IS
BEGIN
  IEU_WPACTIONS_PVT.WP_TASK(P_RESOURCE_ID,
			P_LANGUAGE   ,
			P_SOURCE_LANG,
			P_ACTION_KEY ,
			P_ACTION_INPUT_DATA ,
			'REASSIGN_TASK',
			X_UWQ_ACTION_LIST  ,
			X_MSG_COUNT        ,
			X_MSG_DATA         ,
			X_RETURN_STATUS);

END REASSIGN_TASK; -- PROCEDURE REASSIGN_TASK

PROCEDURE RESCHEDULE_TASK
( P_RESOURCE_ID       IN NUMBER,
  P_LANGUAGE          IN VARCHAR2,
  P_SOURCE_LANG       IN VARCHAR2,
  P_ACTION_KEY        IN VARCHAR2,
  P_ACTION_INPUT_DATA IN SYSTEM.ACTION_INPUT_DATA_NST,
  X_UWQ_ACTION_LIST   OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
  X_MSG_COUNT         OUT NOCOPY NUMBER,
  X_MSG_DATA          OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS     OUT NOCOPY VARCHAR2
)
IS
BEGIN
  IEU_WPACTIONS_PVT.WP_TASK(P_RESOURCE_ID,
			P_LANGUAGE   ,
			P_SOURCE_LANG,
			P_ACTION_KEY ,
			P_ACTION_INPUT_DATA ,
			'RESCHEDULE_TASK',
			X_UWQ_ACTION_LIST  ,
			X_MSG_COUNT        ,
			X_MSG_DATA         ,
			X_RETURN_STATUS);

END RESCHEDULE_TASK; -- PROCEDURE RESCHEDULE_TASK

PROCEDURE TRANSFER_TASK_OWNER_TASK
( P_RESOURCE_ID       IN NUMBER,
  P_LANGUAGE          IN VARCHAR2,
  P_SOURCE_LANG       IN VARCHAR2,
  P_ACTION_KEY        IN VARCHAR2,
  P_ACTION_INPUT_DATA IN SYSTEM.ACTION_INPUT_DATA_NST,
  X_UWQ_ACTION_LIST   OUT NOCOPY SYSTEM.IEU_UWQ_WORK_ACTIONS_NST,
  X_MSG_COUNT         OUT NOCOPY NUMBER,
  X_MSG_DATA          OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS     OUT NOCOPY VARCHAR2
)
IS
BEGIN
  IEU_WPACTIONS_PVT.WP_TASK(P_RESOURCE_ID,
			P_LANGUAGE   ,
			P_SOURCE_LANG,
			P_ACTION_KEY ,
			P_ACTION_INPUT_DATA ,
			'TRANSFER_TASK_OWNER_TASK',
			X_UWQ_ACTION_LIST  ,
			X_MSG_COUNT        ,
			X_MSG_DATA         ,
			X_RETURN_STATUS);

END TRANSFER_TASK_OWNER_TASK; -- PROCEDURE TRANSFER_TASK_OWNER_TASK

end IEU_WPACTIONS_PVT;

/
