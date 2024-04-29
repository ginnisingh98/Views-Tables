--------------------------------------------------------
--  DDL for Package Body CSF_TASKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_TASKS_PUB" AS
/* $Header: CSFPTSKB.pls 120.49.12010000.57 2013/03/04 06:45:51 rkamasam ship $ */

  g_pkg_name    CONSTANT VARCHAR2(30) := 'CSF_TASKS_PUB';

  -- Task Types
  g_dep_task_type_id CONSTANT NUMBER  := 20;
  g_arr_task_type_id CONSTANT NUMBER  := 21;
  g_esc_task_type_id CONSTANT NUMBER  := 22;

  /*-- Task Status Propagation Constants
  g_working_bitcode    CONSTANT NUMBER := 001; -- 000000001
  g_assigned_bitcode   CONSTANT NUMBER := 003; -- 000000011
  g_planned_bitcode    CONSTANT NUMBER := 007; -- 000000111
  g_completed_bitcode  CONSTANT NUMBER := 009; -- 000001001
  g_closed_bitcode     CONSTANT NUMBER := 025; -- 000011001
  g_onhold_bitcode     CONSTANT NUMBER := 032; -- 000100000
  g_rejected_bitcode   CONSTANT NUMBER := 096; -- 001100000
  g_cancelled_bitcode  CONSTANT NUMBER := 224; -- 011100000
  g_start_bitcode      CONSTANT NUMBER := 511; -- 111111111*/


 -- Task Status Propagation Constants
  g_working_bitcode    CONSTANT NUMBER := 001; --  000000001
  g_assigned_bitcode   CONSTANT NUMBER := 007; --  000000111
  g_planned_bitcode    CONSTANT NUMBER := 015; --  000001111
  g_completed_bitcode  CONSTANT NUMBER := 0017; -- 000010001
  g_closed_bitcode     CONSTANT NUMBER := 049; --  000110001

  --------Variables added  for the bug 6646890---------------------
  g_accepted_bitcode       CONSTANT NUMBER := 003; -- 000000011
  ---------------------------------------------------------

  g_onhold_bitcode     CONSTANT NUMBER := 064; -- 001000000
  g_rejected_bitcode   CONSTANT NUMBER := 192; -- 011000000
  g_cancelled_bitcode  CONSTANT NUMBER := 448; -- 111000000
  g_start_bitcode      CONSTANT NUMBER := 511; -- 111111111

  -- Default Values from the Profiles
  g_plan_scope  CONSTANT NUMBER      := CSR_SCHEDULER_PUB.GET_SCH_PARAMETER_VALUE('spPlanScope');

  g_inplanning  CONSTANT NUMBER      := fnd_profile.value('CSF_DEFAULT_TASK_INPLANNING_STATUS');
  g_assigned    CONSTANT NUMBER      := fnd_profile.value('CSF_DEFAULT_TASK_ASSIGNED_STATUS');
  g_working     CONSTANT NUMBER      := fnd_profile.value('CSF_DEFAULT_TASK_WORKING_STATUS');
  g_cancelled   CONSTANT NUMBER      := fnd_profile.value('CSF_DEFAULT_TASK_CANCELLED_STATUS');
  g_unscheduled CONSTANT NUMBER      := fnd_profile.value('CSF_DEFAULT_TASK_UNSCHEDULED_STATUS');

  g_default_uom CONSTANT VARCHAR2(3) := fnd_profile.value('CSF_DEFAULT_EFFORT_UOM');
  g_overtime    CONSTANT NUMBER      := NVL(CSR_SCHEDULER_PUB.GET_SCH_PARAMETER_VALUE('spMaxOvertime'), 0) / (24 * 60);
  g_uom_hours            VARCHAR2(60):= fnd_profile.value('CSF_UOM_HOURS');

  TYPE number_tbl_type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;



  /*******************************************************************************
  *                   Private Functions and Procedures                           *
  ********************************************************************************/
  function convert_to_days
    ( p_duration  number
    , p_uom       varchar2
    , p_uom_hours varchar2
    )
  return number
  is
    l_value number;
  begin
    l_value := inv_convert.inv_um_convert
                 ( item_id       => 0
                 , precision     => 20
                 , from_quantity => p_duration
                 , from_unit     => p_uom
                 , to_unit       => p_uom_hours
                 , from_name     => null
                 , to_name       => null
                 );
    return l_value/24;
  end convert_to_days;

  function return_primary_phone
  (
	party_id  IN number
  ) return varchar2 is
	l_phone	varchar2(50);
  begin

	select decode(phone_country_code,'','',phone_country_code || '-' ) ||
               decode(phone_area_code,'','',phone_area_code || '-' ) || phone_number
        into l_phone
	from (select phone_number, phone_area_code, phone_country_code
		from hz_contact_points
		where owner_table_id = party_id
		and owner_table_name ='HZ_PARTY_SITES'
		and contact_point_type = 'PHONE'
		order by primary_flag desc, creation_date asc)
	where rownum = 1;

	return l_phone;

  exception
	when NO_DATA_FOUND then
		l_phone := null;
                return l_phone;
  end return_primary_phone;

  FUNCTION is_cancel_status (p_status_id jtf_task_statuses_b.task_status_id%TYPE)
    RETURN BOOLEAN IS
    CURSOR c_cancelled_flag IS
      SELECT task_status_id
        FROM jtf_task_statuses_b
       WHERE task_status_id = p_status_id
         AND NVL (cancelled_flag, 'N') = 'Y';
  BEGIN
    FOR v_cancelled_flag IN c_cancelled_flag LOOP
      RETURN TRUE;
    END LOOP;
    RETURN FALSE;
  END is_cancel_status;

  FUNCTION has_field_service_rule (p_task_type_id NUMBER)
    RETURN VARCHAR2 IS
    CURSOR c_task_type IS
      SELECT task_type_id
        FROM jtf_task_types_b
       WHERE rule = 'DISPATCH'
         AND NVL (schedule_flag, 'N') = 'Y'
         AND task_type_id = p_task_type_id;
  BEGIN
    FOR v_task_type IN c_task_type LOOP
      RETURN fnd_api.g_true;
    END LOOP;
    RETURN fnd_api.g_false;
  END has_field_service_rule;

  FUNCTION has_schedulable_status (p_task_status_id NUMBER)
    RETURN BOOLEAN IS
    CURSOR c_task_status IS
      SELECT task_status_id
        FROM jtf_task_statuses_b
       WHERE NVL (schedulable_flag, 'N') = 'Y'
         AND task_status_id = p_task_status_id;
  BEGIN
    FOR v_task_status IN c_task_status LOOP
      RETURN TRUE;
    END LOOP;
    RETURN FALSE;
  END has_schedulable_status;

  FUNCTION task_number (p_task_id IN NUMBER)
    RETURN VARCHAR2 IS
    CURSOR c_number IS
      SELECT task_number
        FROM jtf_tasks_b
       WHERE task_id = p_task_id;
    l_task_number   jtf_tasks_b.task_number%TYPE;
  BEGIN
    OPEN c_number;
    FETCH c_number INTO l_task_number;
    CLOSE c_number;
    RETURN l_task_number;
  END task_number;

  FUNCTION is_debrief_closed(p_task_assignment_id NUMBER)
    RETURN BOOLEAN IS
    CURSOR c_debrief_status IS
      SELECT NVL (cdh.processed_flag, 'PENDING') debrief_status
        FROM csf_debrief_headers cdh
       WHERE cdh.task_assignment_id = p_task_assignment_id;
  BEGIN
    FOR v_debrief_status IN c_debrief_status LOOP
      IF v_debrief_status.debrief_status <> 'COMPLETED' THEN
        RETURN FALSE;
      END IF;
    END LOOP;
    RETURN TRUE;
  END is_debrief_closed;

  FUNCTION check_schedulable(
    p_deleted_flag       IN         VARCHAR2
  , p_planned_start_date IN         DATE
  , p_planned_end_date   IN         DATE
  , p_planned_effort     IN         NUMBER
  , p_task_type_id       IN         NUMBER
  , p_task_status_id     IN         NUMBER
  , x_reason_code        OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
  BEGIN
    x_reason_code := NULL;
    IF p_deleted_flag = 'Y' THEN
      x_reason_code := 'CSF_DELETED_TASK';
    ELSIF has_field_service_rule (p_task_type_id) = fnd_api.g_false THEN
      x_reason_code := 'CSF_NON_FS_TASK';
    ELSIF (p_planned_start_date IS NULL OR p_planned_end_date IS NULL) THEN
      x_reason_code := 'CSF_PLANNED_DATE_NOT_SET';
    ELSIF p_planned_effort IS NULL THEN
      x_reason_code := 'CSF_PLANNED_EFFORT_NOT_SET';
    ELSIF NOT has_schedulable_status (p_task_status_id) THEN
      x_reason_code := 'CSF_STATUS_NOT_SCHEDULABLE';
    END IF;
    RETURN x_reason_code IS NULL;
  END check_schedulable;


  /*******************************************************************************
  *                    Public Functions and Procedures                           *
  ********************************************************************************/

  FUNCTION get_task_status_name (p_task_status_id NUMBER)
    RETURN VARCHAR2 IS
    l_return_value   VARCHAR2 (30);

    CURSOR c_name IS
      SELECT NAME
        FROM jtf_task_statuses_vl
       WHERE task_status_id = p_task_status_id;
  BEGIN
    OPEN c_name;
    FETCH c_name INTO l_return_value;
    CLOSE c_name;

    RETURN l_return_value;
  END get_task_status_name;

  FUNCTION get_dep_task_type_id RETURN NUMBER IS
  BEGIN
    RETURN g_dep_task_type_id;
  END get_dep_task_type_id;

  FUNCTION get_arr_task_type_id RETURN NUMBER IS
  BEGIN
    RETURN g_arr_task_type_id;
  END get_arr_task_type_id;

  -- Validate Field Service State Transitions
  FUNCTION validate_state_transition (
    p_state_type      VARCHAR2
  , p_old_status_id   NUMBER
  , p_new_status_id   NUMBER
  )
    RETURN VARCHAR2 IS
    -- Validation when new object
    CURSOR c_valid_new_trans IS
      SELECT NULL
        FROM jtf_state_responsibilities re
           , jtf_state_rules_b ru
           , jtf_state_transitions tr
       WHERE (re.responsibility_id = fnd_global.resp_id OR fnd_global.resp_id = -1)
         AND re.rule_id = ru.rule_id
         AND ru.state_type = p_state_type
         AND ru.rule_id = tr.rule_id
         AND tr.initial_state_id = p_new_status_id;

    -- Validation when existing object
    CURSOR c_valid_existing_trans IS
      SELECT NULL
        FROM jtf_state_responsibilities re
           , jtf_state_rules_b ru
           , jtf_state_transitions tr
       WHERE (re.responsibility_id = fnd_global.resp_id OR fnd_global.resp_id = -1)
         AND re.rule_id = ru.rule_id
         AND ru.state_type = p_state_type
         AND ru.rule_id = tr.rule_id
         AND tr.initial_state_id = p_old_status_id
         AND tr.final_state_id = p_new_status_id;

    l_dummy              VARCHAR2(1);
    l_transition_valid   VARCHAR2(1);
  BEGIN
    l_transition_valid := fnd_api.g_false;

    -- If the new Status eqauls the old Status... return Valid.
    IF p_new_status_id = p_old_status_id THEN
      l_transition_valid := fnd_api.g_true;
    ELSIF p_old_status_id IS NULL THEN
      OPEN c_valid_new_trans;
      FETCH c_valid_new_trans INTO l_dummy;
      IF c_valid_new_trans%FOUND THEN
        l_transition_valid := fnd_api.g_true;
      END IF;
      CLOSE c_valid_new_trans;
    ELSE
      OPEN c_valid_existing_trans;
      FETCH c_valid_existing_trans INTO l_dummy;
      IF c_valid_existing_trans%FOUND THEN
        l_transition_valid := fnd_api.g_true;
      END IF;
      CLOSE c_valid_existing_trans;
    END IF;
    RETURN l_transition_valid;
  END validate_state_transition;

  /**
   * Used to retrieve the list of valid Task Statuses the Task can take either from
   * from its current status or when it is created anew. It gives a list of Task
   * Status Names rather than Task Status IDs.
   */
  FUNCTION get_valid_statuses (
    p_state_type      VARCHAR2
  , p_old_status_id   NUMBER
  )
    RETURN VARCHAR2 IS
    l_return_value   VARCHAR2 (2000);

    -- Get valid statuses when the object is creeted for the first time
    CURSOR c_valid_new_trans IS
      SELECT DISTINCT tr.initial_state_id, ts.name
        FROM jtf_state_responsibilities re
           , jtf_state_rules_b ru
           , jtf_state_transitions tr
           , jtf_task_statuses_tl ts
       WHERE (re.responsibility_id = fnd_global.resp_id OR fnd_global.resp_id = -1)
         AND re.rule_id = ru.rule_id
         AND ru.state_type = p_state_type
         AND ru.rule_id = tr.rule_id
         AND ts.task_status_id = tr.initial_state_id
         AND ts.language = userenv('LANG');

    -- Get valid statuses from an existing status
    CURSOR c_valid_existing_trans IS
      SELECT DISTINCT tr.final_state_id, ts.name
        FROM jtf_state_responsibilities re
           , jtf_state_rules_b ru
           , jtf_state_transitions tr
           , jtf_task_statuses_tl ts
       WHERE (re.responsibility_id = fnd_global.resp_id OR fnd_global.resp_id = -1)
         AND re.rule_id = ru.rule_id
         AND ru.state_type = p_state_type
         AND ru.rule_id = tr.rule_id
         AND tr.initial_state_id = p_old_status_id
         AND ts.task_status_id = tr.final_state_id
         AND ts.language = userenv('LANG');
  BEGIN
    IF p_old_status_id IS NULL THEN
      FOR v_valid_new_trans IN c_valid_new_trans LOOP
        l_return_value := l_return_value || fnd_global.local_chr(10) || v_valid_new_trans.name;
      END LOOP;
    ELSE
      FOR v_valid_existing_trans IN c_valid_existing_trans LOOP
        l_return_value := l_return_value || fnd_global.local_chr(10) || v_valid_existing_trans.name;
      END LOOP;
    END IF;

    RETURN l_return_value;
  END get_valid_statuses;

  -- Clubs the operation of the above functions validate_state_transition and
  -- get_valid_statuses into one procedure.
  PROCEDURE validate_status_change(p_old_status_id NUMBER, p_new_status_id NUMBER) IS
    l_trans_valid    VARCHAR2(1);
    l_valid_statuses VARCHAR2(2000);
  BEGIN
    IF p_new_status_id IS NULL THEN
      RETURN;
    END IF;

    IF p_new_status_id = p_old_status_id THEN
      RETURN;
    END IF;

    l_trans_valid := validate_state_transition ('TASK_STATUS', p_old_status_id, p_new_status_id);
    IF l_trans_valid = fnd_api.g_false THEN
      l_valid_statuses := get_valid_statuses ('TASK_STATUS', p_old_status_id);
      IF l_valid_statuses IS NULL THEN
        fnd_message.set_name ('CSF', 'CSF_NO_STATE_TRANSITION');
      ELSE
        fnd_message.set_name ('CSF', 'CSF_INVALID_STATE_TRANSITION');
        fnd_message.set_token ('P_VALID_STATUSES', l_valid_statuses);
      END IF;
      fnd_message.set_token ('P_NEW_STATUS', get_task_status_name (p_new_status_id));
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
  END validate_status_change;

  /**
   * Checks whether the given Task is closable.
   * @returns TRUE    If Task is closable
   * @returns FALSE   If Task is not closable
   */
 FUNCTION is_task_closable (
    x_return_status   OUT NOCOPY      VARCHAR2
  , x_msg_count       OUT NOCOPY      NUMBER
  , x_msg_data        OUT NOCOPY      VARCHAR2
  , p_task_id         IN              NUMBER
  )
    RETURN BOOLEAN IS
    l_api_name   CONSTANT VARCHAR2 (30) := 'IS_TASK_CLOSABLE';

    CURSOR c_task_details IS
      SELECT task_status_id
        FROM jtf_tasks_b
       WHERE task_id = p_task_id;

    -- Cursor to get all the Task Assignments for the Task to be closed.
    CURSOR c_task_assignments IS
      SELECT ta.task_assignment_id
           , t.scheduled_start_date
           , t.scheduled_end_date
           , NVL (ts.closed_flag, 'N') closed_flag
           , NVL (ts.cancelled_flag, 'N') cancelled_flag
           , NVL (ts.completed_flag, 'N') completed_flag
           , NVL (ts.rejected_flag, 'N') rejected_flag
        FROM jtf_task_assignments ta, jtf_tasks_b t, jtf_task_statuses_b ts
       WHERE ta.task_id = t.task_id
         AND t.task_id = p_task_id
         AND assignment_status_id = ts.task_status_id;

    l_old_status_id             NUMBER;
    l_close_status_id           NUMBER;
    l_valid_statuses            VARCHAR2 (2000);
    l_valid_status              BOOLEAN := FALSE;
    l_update_schedulable_task   VARCHAR2(3);
    l_task_closure              Varchar2(3) := fnd_profile.value_specific('CSF: Enforce_Task_Closure', fnd_global.user_id);
  BEGIN
     -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_task_details;
    FETCH c_task_details INTO l_old_status_id;
    IF c_task_details%NOTFOUND THEN
      CLOSE c_task_details;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_task_details;

    -- Before a Task can be closed, there are some checks that needs to be done

    -- Check whether the State Transition is valid.
    l_close_status_id := fnd_profile.VALUE ('CSF_DFLT_AUTO_CLOSE_TASK_STATUS');
    IF validate_state_transition ('TASK_STATUS', l_old_status_id, l_close_status_id) = fnd_api.g_false THEN
      l_valid_statuses := get_valid_statuses ('TASK_STATUS', l_old_status_id);
      IF l_valid_statuses IS NULL THEN
        fnd_message.set_name ('CSF', 'CSF_NO_STATE_TRANSITION');
      ELSE
        fnd_message.set_name ('CSF', 'CSF_INVALID_STATE_TRANSITION');
        fnd_message.set_token ('P_VALID_STATUSES', l_valid_statuses);
      END IF;
      fnd_message.set_token ('P_NEW_STATUS', get_task_status_name (l_close_status_id));
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Check whether the Assignments and the associated Debriefs have been closed
    l_update_schedulable_task := NVL(fnd_profile.value('CSFW_UPD_SCHEDULABLE'), 'NO');
    -- added an if codetion for task closure for the bug 8282570
    if nvl(l_task_closure,'N') ='Y'
    then
          if nvl(l_update_schedulable_task,'NO') = 'NO'
          then
               FOR v_task_assignment IN c_task_assignments
               LOOP
                -- Check whether the Task Assignment is still Open.
                IF v_task_assignment.closed_flag = 'N' AND
                   v_task_assignment.cancelled_flag = 'N' AND
                   v_task_assignment.completed_flag = 'N' AND
                   v_task_assignment.rejected_flag = 'N'
                THEN
                       l_valid_status := TRUE;
                       EXIT;
                END IF;
               END LOOP;
           end if;
          -- Check whether the Debrief is closed if Task Assignment is not open
          -- and only when the profile "CSFW: Update Schedulable Task" is set to Yes
         IF l_update_schedulable_task = 'YES'
         THEN
           FOR v_task_assignment IN c_task_assignments
           LOOP
                -- Check whether the Task Assignment is still Open.
              IF v_task_assignment.closed_flag = 'N' AND
                 v_task_assignment.cancelled_flag = 'N' AND
                 v_task_assignment.completed_flag = 'N' AND
                 v_task_assignment.rejected_flag = 'N'
              THEN
                     l_valid_status := TRUE;
                     EXIT;
              END IF;
              IF NOT is_debrief_closed(v_task_assignment.task_assignment_id)
              THEN
                    fnd_message.set_name('CSF', 'CSF_DEBRIEF_PENDING');
                    fnd_msg_pub.ADD;
                    RAISE fnd_api.g_exc_error;
              END IF;
             END LOOP;
         END IF;
         -- added the following code for bug 8282570
         IF l_valid_status  = false
         THEN
            RETURN TRUE;
         ELSIF l_valid_status  = TRUE
         THEN
            FND_MESSAGE.Set_Name('CSF', 'CSF_CLOSED_TASK');
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
         END IF;
         ---- end of code for the bug 8282570
    ELSE
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      RETURN FALSE;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      RETURN FALSE;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      RETURN FALSE;
  END is_task_closable;

  /**
   * Checks whether the given Task can be closed and returns True or False
   * accordingly.
   * @deprecated Use IS_TASK_CLOSABLE (SR Team is still calling this version)
   */
  FUNCTION task_is_closable (
    x_return_status   OUT NOCOPY      VARCHAR2
  , x_msg_count       OUT NOCOPY      NUMBER
  , x_msg_data        OUT NOCOPY      VARCHAR2
  , p_task_id         IN              NUMBER
  )
    RETURN BOOLEAN IS
  BEGIN
    RETURN is_task_closable(
      x_return_status => x_return_status
    , x_msg_count     => x_msg_count
    , x_msg_data      => x_msg_data
    , p_task_id       => p_task_id
    );
  END task_is_closable;



  FUNCTION is_task_schedulable (
    x_return_status   OUT NOCOPY      VARCHAR2
  , x_msg_count       OUT NOCOPY      NUMBER
  , x_msg_data        OUT NOCOPY      VARCHAR2
  , p_task_id         IN              NUMBER
  )
    RETURN BOOLEAN IS
    l_api_name   CONSTANT VARCHAR2(30) := 'IS_TASK_SCHEDULABLE';

    CURSOR c_task_details IS
      SELECT task_type_id
           , task_status_id
           , planned_start_date
           , planned_end_date
           , planned_effort
           , address_id
           , deleted_flag
        FROM jtf_tasks_b
       WHERE task_id = p_task_id;

    l_task_details  c_task_details%ROWTYPE;
    l_schedulable   BOOLEAN;
    l_message_name  VARCHAR2(100);
  BEGIN
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Fetching the Task Details
    OPEN c_task_details;
    FETCH c_task_details INTO l_task_details;
    IF c_task_details%NOTFOUND THEN
      CLOSE c_task_details;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_task_details;

    l_schedulable := check_schedulable(
                       p_deleted_flag       => l_task_details.deleted_flag
                     , p_planned_start_date => l_task_details.planned_start_date
                     , p_planned_end_date   => l_task_details.planned_end_date
                     , p_planned_effort     => l_task_details.planned_effort
                     , p_task_type_id       => l_task_details.task_type_id
                     , p_task_status_id     => l_task_details.task_status_id
                     , x_reason_code        => l_message_name
                     );

    IF NOT l_schedulable THEN
      fnd_message.set_name('CSF', l_message_name);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    RETURN TRUE;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      RETURN FALSE;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      RETURN FALSE;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      RETURN FALSE;
  END is_task_schedulable;

  FUNCTION is_task_scheduled (
    x_return_status   OUT NOCOPY      VARCHAR2
  , x_msg_count       OUT NOCOPY      NUMBER
  , x_msg_data        OUT NOCOPY      VARCHAR2
  , p_task_id         IN              NUMBER
  )
    RETURN BOOLEAN IS
    l_api_name   CONSTANT VARCHAR2(30)   := 'IS_TASK_SCHEDULED';

    CURSOR c_task_ta_det IS
      SELECT t.scheduled_start_date
           , t.scheduled_end_date
           , t.task_split_flag
           , t.task_status_id
           , ta.resource_id
        FROM jtf_tasks_b t, jtf_task_assignments ta
       WHERE ta.task_id = t.task_id AND t.task_id = p_task_id;

    l_sched_start         jtf_tasks_b.scheduled_start_date%TYPE;
    l_sched_end           jtf_tasks_b.scheduled_end_date%TYPE;
    l_resource_id         jtf_task_assignments.resource_id%TYPE;
    l_split_flag          jtf_tasks_b.task_split_flag%TYPE;
    l_status_id           jtf_task_statuses_b.task_status_id%TYPE;
  BEGIN
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_task_ta_det;
    FETCH c_task_ta_det
      INTO l_sched_start, l_sched_end, l_split_flag, l_status_id, l_resource_id;
    IF c_task_ta_det%NOTFOUND THEN
      CLOSE c_task_ta_det;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_task_ta_det;

    IF l_split_flag IS NULL OR l_split_flag = 'D' THEN
      IF (l_resource_id IS NOT NULL) AND NOT (is_cancel_status (l_status_id)) THEN
        IF l_sched_start IS NOT NULL AND l_sched_end IS NOT NULL THEN
          RETURN TRUE;
        END IF;
      END IF;
    ELSE  -- task_split_flag is 'M'
      -- put the additional logic here asked from Max.
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      RETURN FALSE;
  END is_task_scheduled;

  /**
   * Determines whether the given Task is escalated or not
   */
  FUNCTION is_task_escalated(p_task_id NUMBER)
    RETURN BOOLEAN IS
    l_ref_task_id   NUMBER;
    l_escalated     NUMBER;

    CURSOR c_task_ref IS
      SELECT task_id
        FROM jtf_task_references_b r
       WHERE r.reference_code = 'ESC'
         AND r.object_type_code = 'TASK'
         AND r.object_id = p_task_id;

    CURSOR c_esc(b_task_id NUMBER) IS
      SELECT 1
        FROM jtf_tasks_b t
           , jtf_task_statuses_b s
       WHERE t.task_id = b_task_id
         AND t.task_type_id = g_esc_task_type_id
         AND s.task_status_id = t.task_status_id
         AND NVL(s.closed_flag, 'N') <> 'Y'
         AND NVL(t.deleted_flag, 'N') <> 'Y';
  BEGIN
    -- Get the Reference Task to the given Task
    OPEN c_task_ref;
    FETCH c_task_ref INTO l_ref_task_id;
    CLOSE c_task_ref;

    IF l_ref_task_id IS NULL THEN
      RETURN FALSE;
    END IF;

    -- Check whether the Reference object is an Escalation Task
    OPEN c_esc(l_ref_task_id);
    FETCH c_esc INTO l_escalated;
    CLOSE c_esc;

    RETURN (l_escalated IS NOT NULL);
  EXCEPTION
    WHEN OTHERS THEN
      IF c_task_ref%ISOPEN THEN
        CLOSE c_task_ref;
      END IF;
      IF c_esc%ISOPEN THEN
        CLOSE c_esc;
      END IF;
      RETURN FALSE;
  END is_task_escalated;

  /**
   * Closes an existing task
   */
  PROCEDURE close_task (
    p_api_version     IN              NUMBER
  , p_init_msg_list   IN              VARCHAR2
  , p_commit          IN              VARCHAR2
  , x_return_status   OUT NOCOPY      VARCHAR2
  , x_msg_count       OUT NOCOPY      NUMBER
  , x_msg_data        OUT NOCOPY      VARCHAR2
  , p_task_id         IN              NUMBER
  ) IS
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_api_name       CONSTANT VARCHAR2(30) := 'CLOSE_TASK';

    l_close_status_id         NUMBER;
    l_object_version_number   NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT close_task_pub;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_close_status_id := fnd_profile.VALUE ('CSF_DFLT_AUTO_CLOSE_TASK_STATUS');
    update_task_status (
      p_api_version               => 1.0
    , x_return_status             => x_return_status
    , x_msg_count                 => x_msg_count
    , x_msg_data                  => x_msg_data
    , p_task_id                   => p_task_id
    , p_task_status_id            => l_close_status_id
    , p_object_version_number     => l_object_version_number
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Standard check of p_commit
    IF fnd_api.to_boolean (p_commit) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO close_task_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO close_task_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO close_task_pub;
  END close_task;

  -- Determines which tasks in a PL/SQL table are modified
  PROCEDURE identify_modified_tasks (
    p_api_version     IN             NUMBER
  , p_init_msg_list   IN             VARCHAR2
  , x_return_status   OUT    NOCOPY  VARCHAR2
  , x_msg_count       OUT    NOCOPY  NUMBER
  , x_msg_data        OUT    NOCOPY  VARCHAR2
  , x_collection      IN OUT NOCOPY  tasks_tbl_type
  , x_count           OUT    NOCOPY  NUMBER
  ) IS
    l_api_version   CONSTANT NUMBER        := 1.0;
    l_api_name      CONSTANT VARCHAR2(30) := 'IDENTIFY_MODIFIED_TASKS';
    l_idx                    PLS_INTEGER;

    CURSOR c_task_info (p_row_id VARCHAR) IS
      SELECT t.object_version_number
           , t.task_status_id
           , ts.name task_status_name
           , t.scheduled_start_date
           , t.scheduled_end_date
		   , t.planned_start_date
		   , t.planned_end_date
		   , t.planned_effort
		   , t.planned_effort_uom
           , t.task_split_flag
           , t.parent_task_id
           , ts.schedulable_flag ts_schedulable_flag
           , ts.assigned_flag
           , tt.schedule_flag tt_schedule_flag
           , ta.resource_name
        FROM jtf_tasks_b t
           , csf_ct_task_assignments ta
           , jtf_task_statuses_vl ts
           , jtf_task_types_b tt
       WHERE t.ROWID           = CHARTOROWID (p_row_id)
         AND ts.task_status_id = t.task_status_id
         AND tt.task_type_id   = t.task_type_id
         AND ta.task_id (+)    = t.task_id;

    l_task_info    c_task_info%ROWTYPE;
  BEGIN
    -- standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- initialize message list if p_init_msg_list is set to true
    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize api return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- start processing
    x_count := 0;
    l_idx := x_collection.FIRST;
    WHILE l_idx IS NOT NULL LOOP
      -- take only schedulable tasks into account
      -- IF     (   NVL (x_collection(l_idx).status_schedulable_flag, 'N') = 'Y' --commented for ER 6360530
      --        OR NVL (x_collection(l_idx).status_assigned_flag, 'N') = 'Y'
      --       )
      --   AND NVL (x_collection(l_idx).type_schedulable_flag, 'N') = 'Y' THEN
        OPEN c_task_info (x_collection (l_idx).row_id);
        FETCH c_task_info INTO l_task_info;

        IF c_task_info%FOUND THEN
          IF NVL (l_task_info.object_version_number, -1)
              <> NVL(x_collection(l_idx).object_version_number, -1)
          THEN
            x_collection(l_idx).object_version_number   := l_task_info.object_version_number;
            x_collection(l_idx).task_status_id          := l_task_info.task_status_id;
            x_collection(l_idx).task_status             := l_task_info.task_status_name;
            x_collection(l_idx).scheduled_start_date    := l_task_info.scheduled_start_date;
            x_collection(l_idx).scheduled_end_date      := l_task_info.scheduled_end_date;
			x_collection(l_idx).planned_start_date      := l_task_info.planned_start_date;
			x_collection(l_idx).planned_end_date        := l_task_info.planned_end_date;
			x_collection(l_idx).planned_effort        := l_task_info.planned_effort;
			x_collection(l_idx).planned_effort_uom        := l_task_info.planned_effort_uom;
            x_collection(l_idx).status_schedulable_flag := l_task_info.ts_schedulable_flag;
            x_collection(l_idx).type_schedulable_flag   := l_task_info.tt_schedule_flag;
            x_collection(l_idx).status_assigned_flag    := l_task_info.assigned_flag;
            x_collection(l_idx).resource_name           := l_task_info.resource_name;
            x_collection(l_idx).task_split_flag         := l_task_info.task_split_flag;
            x_collection(l_idx).parent_task_id          := l_task_info.parent_task_id;
            x_collection(l_idx).updated_flag            := 'Y';
            x_count := x_count + 1;
          ELSE
            /* reset updated flag if not different */
            x_collection (l_idx).updated_flag := 'N';
          END IF;
        END IF;

        CLOSE c_task_info;
      --END IF;
      l_idx := x_collection.NEXT (l_idx);
    END LOOP;

    -- standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  END identify_modified_tasks;

  ---------------------------------------------------------------------------
  -- validate_planned_dates
  --   validate start / end, can not be in past, implement same rules as
  --   Scheduler core:
  --     1. when start in past or null, then start becomes sysdate
  --     2. when end in past or null, then end becomes start + plan scope
  --
  --   x_start : planned start date to be validated and possibly adjusted
  --   x_end   : planned end date
  ---------------------------------------------------------------------------
  PROCEDURE validate_planned_dates (x_start IN OUT NOCOPY DATE, x_end IN OUT NOCOPY DATE) IS
  BEGIN
    IF x_start < SYSDATE OR x_start IS NULL THEN
      x_start := SYSDATE;
    END IF;
    --
    IF x_end < SYSDATE OR x_end IS NULL THEN
      x_end := x_start + g_plan_scope;
    END IF;
  END validate_planned_dates;

  PROCEDURE create_task (
    p_api_version               IN              NUMBER
  , p_init_msg_list             IN              VARCHAR2
  , p_commit                    IN              VARCHAR2
  , x_return_status             OUT NOCOPY      VARCHAR2
  , x_msg_count                 OUT NOCOPY      NUMBER
  , x_msg_data                  OUT NOCOPY      VARCHAR2
  , p_task_id                   IN              NUMBER
  , p_task_name                 IN              VARCHAR2
  , p_description               IN              VARCHAR2
  , p_task_type_name            IN              VARCHAR2
  , p_task_type_id              IN              NUMBER
  , p_task_status_name          IN              VARCHAR2
  , p_task_status_id            IN              NUMBER
  , p_task_priority_name        IN              VARCHAR2
  , p_task_priority_id          IN              NUMBER
  , p_owner_type_name           IN              VARCHAR2
  , p_owner_type_code           IN              VARCHAR2
  , p_owner_id                  IN              NUMBER
  , p_owner_territory_id        IN              NUMBER
  , p_owner_status_id           IN              NUMBER
  , p_assigned_by_name          IN              VARCHAR2
  , p_assigned_by_id            IN              NUMBER
  , p_customer_number           IN              VARCHAR2
  , p_customer_id               IN              NUMBER
  , p_cust_account_number       IN              VARCHAR2
  , p_cust_account_id           IN              NUMBER
  , p_address_id                IN              NUMBER
  , p_address_number            IN              VARCHAR2
  , p_location_id               IN              NUMBER
  , p_planned_start_date        IN              DATE
  , p_planned_end_date          IN              DATE
  , p_scheduled_start_date      IN              DATE
  , p_scheduled_end_date        IN              DATE
  , p_actual_start_date         IN              DATE
  , p_actual_end_date           IN              DATE
  , p_timezone_id               IN              NUMBER
  , p_timezone_name             IN              VARCHAR2
  , p_source_object_type_code   IN              VARCHAR2
  , p_source_object_id          IN              NUMBER
  , p_source_object_name        IN              VARCHAR2
  , p_duration                  IN              NUMBER
  , p_duration_uom              IN              VARCHAR2
  , p_planned_effort            IN              NUMBER
  , p_planned_effort_uom        IN              VARCHAR2
  , p_actual_effort             IN              NUMBER
  , p_actual_effort_uom         IN              VARCHAR2
  , p_percentage_complete       IN              NUMBER
  , p_reason_code               IN              VARCHAR2
  , p_private_flag              IN              VARCHAR2
  , p_publish_flag              IN              VARCHAR2
  , p_restrict_closure_flag     IN              VARCHAR2
  , p_multi_booked_flag         IN              VARCHAR2
  , p_milestone_flag            IN              VARCHAR2
  , p_holiday_flag              IN              VARCHAR2
  , p_billable_flag             IN              VARCHAR2
  , p_bound_mode_code           IN              VARCHAR2
  , p_soft_bound_flag           IN              VARCHAR2
  , p_workflow_process_id       IN              NUMBER
  , p_notification_flag         IN              VARCHAR2
  , p_notification_period       IN              NUMBER
  , p_notification_period_uom   IN              VARCHAR2
  , p_alarm_start               IN              NUMBER
  , p_alarm_start_uom           IN              VARCHAR2
  , p_alarm_on                  IN              VARCHAR2
  , p_alarm_count               IN              NUMBER
  , p_alarm_interval            IN              NUMBER
  , p_alarm_interval_uom        IN              VARCHAR2
  , p_palm_flag                 IN              VARCHAR2
  , p_wince_flag                IN              VARCHAR2
  , p_laptop_flag               IN              VARCHAR2
  , p_device1_flag              IN              VARCHAR2
  , p_device2_flag              IN              VARCHAR2
  , p_device3_flag              IN              VARCHAR2
  , p_costs                     IN              NUMBER
  , p_currency_code             IN              VARCHAR2
  , p_escalation_level          IN              VARCHAR2
  , p_attribute1                IN              VARCHAR2
  , p_attribute2                IN              VARCHAR2
  , p_attribute3                IN              VARCHAR2
  , p_attribute4                IN              VARCHAR2
  , p_attribute5                IN              VARCHAR2
  , p_attribute6                IN              VARCHAR2
  , p_attribute7                IN              VARCHAR2
  , p_attribute8                IN              VARCHAR2
  , p_attribute9                IN              VARCHAR2
  , p_attribute10               IN              VARCHAR2
  , p_attribute11               IN              VARCHAR2
  , p_attribute12               IN              VARCHAR2
  , p_attribute13               IN              VARCHAR2
  , p_attribute14               IN              VARCHAR2
  , p_attribute15               IN              VARCHAR2
  , p_attribute_category        IN              VARCHAR2
  , p_date_selected             IN              VARCHAR2
  , p_category_id               IN              NUMBER
  , p_show_on_calendar          IN              VARCHAR2
  , p_task_assign_tbl           IN              jtf_tasks_pub.task_assign_tbl
  , p_task_depends_tbl          IN              jtf_tasks_pub.task_depends_tbl
  , p_task_rsrc_req_tbl         IN              jtf_tasks_pub.task_rsrc_req_tbl
  , p_task_refer_tbl            IN              jtf_tasks_pub.task_refer_tbl
  , p_task_dates_tbl            IN              jtf_tasks_pub.task_dates_tbl
  , p_task_notes_tbl            IN              jtf_tasks_pub.task_notes_tbl
  , p_task_recur_rec            IN              jtf_tasks_pub.task_recur_rec
  , p_task_contacts_tbl         IN              jtf_tasks_pub.task_contacts_tbl
  , p_template_id               IN              NUMBER
  , p_template_group_id         IN              NUMBER
  , p_enable_workflow           IN              VARCHAR2
  , p_abort_workflow            IN              VARCHAR2
  , p_task_split_flag           IN              VARCHAR2
  , p_parent_task_number        IN              VARCHAR2
  , p_parent_task_id            IN              NUMBER
  , p_child_position            IN              VARCHAR2
  , p_child_sequence_num        IN              NUMBER
  , x_task_id                   OUT NOCOPY      NUMBER
  ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_TASK';

    l_task_schedulable    BOOLEAN;
    l_reason_code         VARCHAR2(100);


  BEGIN
    SAVEPOINT csf_create_task_pub;

    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    l_task_schedulable := check_schedulable(
                            p_deleted_flag        => 'N'
                          , p_planned_start_date  => p_planned_start_date
                          , p_planned_end_date    => p_planned_end_date
                          , p_planned_effort      => p_planned_effort
                          , p_task_type_id        => p_task_type_id
                          , p_task_status_id      => p_task_status_id
                          , x_reason_code         => l_reason_code
                          );

    -- Task is not schedulable.
    IF l_task_schedulable = FALSE OR x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name ('CSF', l_reason_code);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    jtf_tasks_pub.create_task (
      p_api_version                 => p_api_version
    , p_init_msg_list               => fnd_api.g_false
    , p_commit                      => fnd_api.g_false
    , x_return_status               => x_return_status
    , x_msg_count                   => x_msg_count
    , x_msg_data                    => x_msg_data
    , p_task_id                     => p_task_id
    , p_task_name                   => p_task_name
    , p_task_type_name              => p_task_type_name
    , p_task_type_id                => p_task_type_id
    , p_description                 => p_description
    , p_task_status_name            => p_task_status_name
    , p_task_status_id              => p_task_status_id
    , p_task_priority_name          => p_task_priority_name
    , p_task_priority_id            => p_task_priority_id
    , p_owner_type_name             => p_owner_type_name
    , p_owner_type_code             => p_owner_type_code
    , p_owner_id                    => p_owner_id
    , p_owner_territory_id          => p_owner_territory_id
    , p_assigned_by_name            => p_assigned_by_name
    , p_assigned_by_id              => p_assigned_by_id
    , p_customer_number             => p_customer_number
    , p_customer_id                 => p_customer_id
    , p_cust_account_number         => p_cust_account_number
    , p_cust_account_id             => p_cust_account_id
    , p_address_id                  => p_address_id
    , p_address_number              => p_address_number
    , p_location_id                 => p_location_id
    , p_planned_start_date          => p_planned_start_date
    , p_planned_end_date            => p_planned_end_date
    , p_scheduled_start_date        => p_scheduled_start_date
    , p_scheduled_end_date          => p_scheduled_end_date
    , p_actual_start_date           => p_actual_start_date
    , p_actual_end_date             => p_actual_end_date
    , p_timezone_id                 => p_timezone_id
    , p_timezone_name               => p_timezone_name
    , p_source_object_type_code     => p_source_object_type_code
    , p_source_object_id            => p_source_object_id
    , p_source_object_name          => p_source_object_name
    , p_duration                    => p_duration
    , p_duration_uom                => p_duration_uom
    , p_planned_effort              => p_planned_effort
    , p_planned_effort_uom          => p_planned_effort_uom
    , p_actual_effort               => p_actual_effort
    , p_actual_effort_uom           => p_actual_effort_uom
    , p_percentage_complete         => p_percentage_complete
    , p_reason_code                 => p_reason_code
    , p_private_flag                => p_private_flag
    , p_publish_flag                => p_publish_flag
    , p_restrict_closure_flag       => p_restrict_closure_flag
    , p_multi_booked_flag           => p_multi_booked_flag
    , p_milestone_flag              => p_milestone_flag
    , p_holiday_flag                => p_holiday_flag
    , p_billable_flag               => p_billable_flag
    , p_bound_mode_code             => p_bound_mode_code
    , p_soft_bound_flag             => p_soft_bound_flag
    , p_workflow_process_id         => p_workflow_process_id
    , p_notification_flag           => p_notification_flag
    , p_notification_period         => p_notification_period
    , p_notification_period_uom     => p_notification_period_uom
    , p_alarm_start                 => p_alarm_start
    , p_alarm_start_uom             => p_alarm_start_uom
    , p_alarm_on                    => p_alarm_on
    , p_alarm_count                 => p_alarm_count
    , p_alarm_interval              => p_alarm_interval
    , p_alarm_interval_uom          => p_alarm_interval_uom
    , p_palm_flag                   => p_palm_flag
    , p_wince_flag                  => p_wince_flag
    , p_laptop_flag                 => p_laptop_flag
    , p_device1_flag                => p_device1_flag
    , p_device2_flag                => p_device2_flag
    , p_device3_flag                => p_device3_flag
    , p_costs                       => p_costs
    , p_currency_code               => p_currency_code
    , p_escalation_level            => p_escalation_level
    , p_attribute1                  => p_attribute1
    , p_attribute2                  => p_attribute2
    , p_attribute3                  => p_attribute3
    , p_attribute4                  => p_attribute4
    , p_attribute5                  => p_attribute5
    , p_attribute6                  => p_attribute6
    , p_attribute7                  => p_attribute7
    , p_attribute8                  => p_attribute8
    , p_attribute9                  => p_attribute9
    , p_attribute10                 => p_attribute10
    , p_attribute11                 => p_attribute11
    , p_attribute12                 => p_attribute12
    , p_attribute13                 => p_attribute13
    , p_attribute14                 => p_attribute14
    , p_attribute15                 => p_attribute15
    , p_attribute_category          => p_attribute_category
    , p_task_assign_tbl             => p_task_assign_tbl
    , p_task_depends_tbl            => p_task_depends_tbl
    , p_task_rsrc_req_tbl           => p_task_rsrc_req_tbl
    , p_task_refer_tbl              => p_task_refer_tbl
    , p_task_dates_tbl              => p_task_dates_tbl
    , p_task_notes_tbl              => p_task_notes_tbl
    , p_task_recur_rec              => p_task_recur_rec
    , p_task_contacts_tbl           => p_task_contacts_tbl
    , p_date_selected               => p_date_selected
    , p_category_id                 => p_category_id
    , p_show_on_calendar            => p_show_on_calendar
    , p_owner_status_id             => p_owner_status_id
    , p_template_id                 => p_template_id
    , p_template_group_id           => p_template_group_id
    , p_enable_workflow             => p_enable_workflow
    , p_abort_workflow              => p_abort_workflow
    , p_task_split_flag             => p_task_split_flag
    , p_parent_task_number          => p_parent_task_number
    , p_parent_task_id              => p_parent_task_id
    , p_child_position              => p_child_position
    , p_child_sequence_num          => p_child_sequence_num
    , x_task_id                     => x_task_id
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


	CSF_TASKS_PUB.CREATE_ACC_HRS(
              p_task_id                    => x_task_id
            , x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            );
    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_create_task_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_create_task_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_create_task_pub;
  END create_task;

  PROCEDURE delete_task (
    p_api_version                 IN              NUMBER
  , p_init_msg_list               IN              VARCHAR2
  , p_commit                      IN              VARCHAR2
  , x_return_status               OUT NOCOPY      VARCHAR2
  , x_msg_count                   OUT NOCOPY      NUMBER
  , x_msg_data                    OUT NOCOPY      VARCHAR2
  , p_task_id                     IN              NUMBER
  , p_task_number                 IN              VARCHAR2
  , p_object_version_number       IN              NUMBER
  , p_delete_future_recurrences   IN              VARCHAR2
  ) IS
  BEGIN
    jtf_tasks_pub.delete_task (
      p_api_version                   => p_api_version
    , p_init_msg_list                 => p_init_msg_list
    , p_commit                        => p_commit
    , x_return_status                 => x_return_status
    , x_msg_count                     => x_msg_count
    , x_msg_data                      => x_msg_data
    , p_task_id                       => p_task_id
    , p_task_number                   => p_task_number
    , p_object_version_number         => p_object_version_number
    , p_delete_future_recurrences     => p_delete_future_recurrences
    );
  END delete_task;

  /**
   *
   */
  PROCEDURE propagate_status_change(
    x_return_status           OUT    NOCOPY   VARCHAR2
  , x_msg_count               OUT    NOCOPY   NUMBER
  , x_msg_data                OUT    NOCOPY   VARCHAR2
  , p_task_id                 IN              NUMBER
  , p_object_version_number   IN OUT NOCOPY   NUMBER
  , p_new_task_status_id      IN              NUMBER
  , p_new_sts_cancelled_flag  IN              VARCHAR2
  , p_new_sts_closed_flag     IN              VARCHAR2
  ) IS
    -- Cursor to get the Task Assignments to be cancelled
    CURSOR c_cancel_task_assignments IS
      SELECT ta.task_assignment_id
           , ta.object_version_number
        FROM csf_ct_task_assignments ta
           , jtf_task_statuses_b ts
       WHERE ta.task_id = p_task_id
         AND ts.task_status_id = ta.assignment_status_id
         AND (   NVL (ts.working_flag, 'N') = 'Y'
              OR NVL (ts.accepted_flag, 'N') = 'Y'
              OR NVL (ts.on_hold_flag, 'N') = 'Y'
              OR NVL (ts.schedulable_flag, 'N') = 'Y'
              OR (     NVL(ts.assigned_flag, 'N') = 'Y'
                   AND NVL(ts.closed_flag,    'N') <> 'Y'
                   AND NVL(ts.approved_flag,  'N') <> 'Y'
                   AND NVL(ts.completed_flag, 'N') <> 'Y'
                   AND NVL(ts.rejected_flag,  'N') <> 'Y')
             );

    -- Cursor to get the Closed Task Assignments
    CURSOR c_closed_task_assignments IS
      SELECT ta.task_assignment_id
           , ta.object_version_number
           , NVL (ts.closed_flag, 'N') closed_flag
           , NVL (ts.cancelled_flag, 'N') cancelled_flag
           , NVL (ts.completed_flag, 'N') completed_flag
           , NVL (ts.rejected_flag, 'N') rejected_flag
        FROM jtf_task_assignments ta, jtf_task_statuses_b ts
       WHERE ta.task_id = p_task_id
         AND ts.task_status_id = ta.assignment_status_id;

    l_task_status_id NUMBER;
    l_task_ovn       NUMBER;
     l_task_closure   Varchar2(3) := fnd_profile.value_specific('CSF: Enforce_Task_Closure', fnd_global.user_id);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF p_new_sts_cancelled_flag = 'Y' THEN
      -- Cancel all the Open Task Assignments
      FOR v_task_assignment IN c_cancel_task_assignments LOOP
        csf_task_assignments_pub.update_assignment_status(
          p_api_version                 => 1.0
        , x_return_status               => x_return_status
        , x_msg_count                   => x_msg_count
        , x_msg_data                    => x_msg_data
        , p_task_assignment_id          => v_task_assignment.task_assignment_id
        , p_object_version_number       => v_task_assignment.object_version_number
        , p_assignment_status_id        => p_new_task_status_id
        , p_update_task                 => fnd_api.g_false
        , x_task_object_version_number  => l_task_ovn
        , x_task_status_id              => l_task_status_id
        );

        IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;
    ELSIF p_new_sts_closed_flag = 'Y' THEN
     -- added an if condition for task closeure for the bug 8282570
     IF nvl(l_task_closure,'N') = 'Y'
     THEN

          FOR v_task_assignment IN c_closed_task_assignments  LOOP

            /*
             * I didnt understand the significance of using CSFW: Update Schedulable Task
             * to check whether Debrief should be checked or not. The significance
             * of the profile is to govern whether Debrief can be invoked directly
             * without Scheduling the Task and not the other way round.
             * Therefore removed the logic - venjayar.
             */

            -- Check whether the Task Assignment is still open.
            IF (     v_task_assignment.closed_flag = 'N'
                 AND v_task_assignment.completed_flag = 'N'
                 AND v_task_assignment.cancelled_flag = 'N'
                 AND v_task_assignment.rejected_flag = 'N' )
            THEN
              fnd_message.set_name ('CSF', 'CSF_CLOSED_TASK');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;

            -- Task Assignment is not open. Check for Debrief
            IF NOT is_debrief_closed(v_task_assignment.task_assignment_id) THEN
              fnd_message.set_name('CSF', 'CSF_DEBRIEF_PENDING');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;

            -- All validations done. Close the Task Assignment
            jtf_task_assignments_pub.update_task_assignment(
              p_api_version               => 1.0
            , x_return_status             => x_return_status
            , x_msg_count                 => x_msg_count
            , x_msg_data                  => x_msg_data
            , p_task_assignment_id        => v_task_assignment.task_assignment_id
            , p_object_version_number     => v_task_assignment.object_version_number
            , p_assignment_status_id      => p_new_task_status_id
            );
            IF x_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END LOOP;


      end if;

    END IF;
  END propagate_status_change;

  /**
   * Update the status of a Task and propagate to Task Assignments also.
   *
   * If the new Status of the Task is CANCELLED, then all Assignments which are open
   * (Working, Accepted, Assigned, In-Planning, Planned, On-Hold) needs to be
   * cancelled too. Other Assignments of the Task will not be updated.
   *
   * If the new Status of the Task is CLOSED, then we have to validate if the Task
   * can be closed. For this, there should not be any Open Task Assignments linked
   * to the Task. Moreover, if the Profile "CSFW: Update Schedulable Task" is set to
   * Yes, then the debrief linked with the Assignments should have been COMPLETED.
   * Otherwise Task cant be closed. If all verifications passes, then Task and the
   * open Assignments are closed.
   */
  PROCEDURE update_task_status (
    p_api_version             IN              NUMBER
  , p_init_msg_list           IN              VARCHAR2
  , p_commit                  IN              VARCHAR2
  , p_validation_level        IN              NUMBER
  , x_return_status           OUT NOCOPY      VARCHAR2
  , x_msg_count               OUT NOCOPY      NUMBER
  , x_msg_data                OUT NOCOPY      VARCHAR2
  , p_task_id                 IN              NUMBER
  , p_task_status_id          IN              NUMBER
  , p_object_version_number   IN OUT NOCOPY   NUMBER
  ) IS
    l_api_name      CONSTANT VARCHAR2 (30)       := 'UPDATE_TASK_STATUS';
    l_api_version   CONSTANT NUMBER              := 1.0;

    -- Fetch the information related to the given Task
    CURSOR c_task_info IS
      SELECT t.task_status_id
           , t.scheduled_start_date
           , t.scheduled_end_date
           , t.object_version_number
           , t.source_object_type_code
        FROM jtf_tasks_b t
           , jtf_task_statuses_b ts
       WHERE task_id = p_task_id
         AND ts.task_status_id = t.task_status_id;

    -- Fetch the Flags corresponding to the new Task Status.
    CURSOR c_task_status_info IS
      SELECT NVL (ts.closed_flag, 'N') closed_flag
           , NVL (ts.cancelled_flag, 'N') cancelled_flag
        FROM jtf_task_statuses_b ts
       WHERE ts.task_status_id = p_task_status_id;


    l_task_info                c_task_info%ROWTYPE;
    l_task_status_info         c_task_status_info%ROWTYPE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT update_task_status_pub;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Validate if update in necessary and get old status_id just in case
    IF p_task_status_id = fnd_api.g_miss_num THEN
      RETURN;
    END IF;

    OPEN c_task_info;
    FETCH c_task_info INTO l_task_info;
    CLOSE c_task_info;

    -- No change in Task Status
    IF p_task_status_id = l_task_info.task_status_id THEN
      RETURN;
    END IF;

    IF p_validation_level IS NULL OR p_validation_level = fnd_api.g_valid_level_full THEN
      validate_status_change(l_task_info.task_status_id, p_task_status_id);
    END IF;

    OPEN c_task_status_info;
    FETCH c_task_status_info INTO l_task_status_info;
    CLOSE c_task_status_info;

    IF l_task_status_info.cancelled_flag = 'Y' AND l_task_info.source_object_type_code = 'SR' THEN
      l_task_info.scheduled_start_date := NULL;
      l_task_info.scheduled_end_date   := NULL;
    END IF;

    -- Update the Task with the new Task Status Information
    jtf_tasks_pub.update_task (
      p_api_version               => 1.0
    , x_return_status             => x_return_status
    , x_msg_count                 => x_msg_count
    , x_msg_data                  => x_msg_data
    , p_task_id                   => p_task_id
    , p_object_version_number     => p_object_version_number
    , p_task_status_id            => p_task_status_id
    , p_scheduled_start_date      => l_task_info.scheduled_start_date
    , p_scheduled_end_date        => l_task_info.scheduled_end_date
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Propagate the change to other dependent objects
    propagate_status_change(
      x_return_status             => x_return_status
    , x_msg_count                 => x_msg_count
    , x_msg_data                  => x_msg_data
    , p_task_id                   => p_task_id
    , p_object_version_number     => p_object_version_number
    , p_new_task_status_id        => p_task_status_id
    , p_new_sts_cancelled_flag    => l_task_status_info.cancelled_flag
    , p_new_sts_closed_flag       => l_task_status_info.closed_flag
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Standard check of p_commit
    IF fnd_api.to_boolean (p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_task_status_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_status_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO update_task_status_pub;
  END update_task_status;

  PROCEDURE autoreject_task(
    p_api_version             IN              NUMBER
  , p_init_msg_list           IN              VARCHAR2
  , p_commit                  IN              VARCHAR2
  , p_validation_level        IN              NUMBER
  , x_return_status           OUT NOCOPY      VARCHAR2
  , x_msg_count               OUT NOCOPY      NUMBER
  , x_msg_data                OUT NOCOPY      VARCHAR2
  , p_task_id                 IN              NUMBER
  , p_task_status_id          IN              NUMBER
  , p_object_version_number   IN OUT NOCOPY   NUMBER
  , p_reject_message          IN              VARCHAR2
  ) IS
    l_api_name      CONSTANT VARCHAR2 (30)       := 'AUTOREJECT_TASK';
    l_api_version   CONSTANT NUMBER              := 1.0;
  BEGIN
    savepoint autoreject_task;
    csf_tasks_pub.update_task_status(
      p_api_version           => 1
    , p_init_msg_list         => fnd_api.g_true
    , p_commit                => fnd_api.g_false
    , x_return_status         => x_return_status
    , x_msg_count             => x_msg_count
    , x_msg_data              => x_msg_data
    , p_task_id               => p_task_id
    , p_object_version_number => p_object_version_number
    , p_task_status_id        => p_task_status_id);

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    UPDATE JTF_TASKS_TL
       SET rejection_message = p_reject_message
     WHERE task_id = p_task_id;

    -- Standard check of p_commit
    IF fnd_api.to_boolean (p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO autoreject_task;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO autoreject_task;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO autoreject_task;
  END autoreject_task;

  PROCEDURE update_task(
    p_api_version               IN              NUMBER
  , p_init_msg_list             IN              VARCHAR2
  , p_commit                    IN              VARCHAR2
  , p_validation_level          IN              NUMBER    DEFAULT NULL
  , x_return_status             OUT    NOCOPY   VARCHAR2
  , x_msg_count                 OUT    NOCOPY   NUMBER
  , x_msg_data                  OUT    NOCOPY   VARCHAR2
  , p_task_id                   IN              NUMBER
  , p_object_version_number     IN OUT NOCOPY   NUMBER
  , p_task_number               IN              VARCHAR2
  , p_task_name                 IN              VARCHAR2
  , p_description               IN              VARCHAR2
  , p_planned_start_date        IN              DATE
  , p_planned_end_date          IN              DATE
  , p_scheduled_start_date      IN              DATE
  , p_scheduled_end_date        IN              DATE
  , p_actual_start_date         IN              DATE
  , p_actual_end_date           IN              DATE
  , p_timezone_id               IN              NUMBER
  , p_source_object_type_code   IN              VARCHAR2
  , p_source_object_id          IN              NUMBER
  , p_source_object_name        IN              VARCHAR2
  , p_task_status_id            IN              NUMBER
  , p_task_type_id              IN              NUMBER
  , p_task_priority_id          IN              NUMBER
  , p_owner_type_code           IN              VARCHAR2
  , p_owner_id                  IN              NUMBER
  , p_owner_territory_id        IN              NUMBER
  , p_owner_status_id           IN              NUMBER
  , p_assigned_by_id            IN              NUMBER
  , p_customer_id               IN              NUMBER
  , p_cust_account_id           IN              NUMBER
  , p_address_id                IN              NUMBER
  , p_location_id               IN              NUMBER
  , p_duration                  IN              NUMBER
  , p_duration_uom              IN              VARCHAR2
  , p_planned_effort            IN              NUMBER
  , p_planned_effort_uom        IN              VARCHAR2
  , p_actual_effort             IN              NUMBER
  , p_actual_effort_uom         IN              VARCHAR2
  , p_percentage_complete       IN              NUMBER
  , p_reason_code               IN              VARCHAR2
  , p_private_flag              IN              VARCHAR2
  , p_publish_flag              IN              VARCHAR2
  , p_restrict_closure_flag     IN              VARCHAR2
  , p_attribute1                IN              VARCHAR2
  , p_attribute2                IN              VARCHAR2
  , p_attribute3                IN              VARCHAR2
  , p_attribute4                IN              VARCHAR2
  , p_attribute5                IN              VARCHAR2
  , p_attribute6                IN              VARCHAR2
  , p_attribute7                IN              VARCHAR2
  , p_attribute8                IN              VARCHAR2
  , p_attribute9                IN              VARCHAR2
  , p_attribute10               IN              VARCHAR2
  , p_attribute11               IN              VARCHAR2
  , p_attribute12               IN              VARCHAR2
  , p_attribute13               IN              VARCHAR2
  , p_attribute14               IN              VARCHAR2
  , p_attribute15               IN              VARCHAR2
  , p_attribute_category        IN              VARCHAR2
  , p_date_selected             IN              VARCHAR2
  , p_category_id               IN              NUMBER
  , p_multi_booked_flag         IN              VARCHAR2
  , p_milestone_flag            IN              VARCHAR2
  , p_holiday_flag              IN              VARCHAR2
  , p_billable_flag             IN              VARCHAR2
  , p_bound_mode_code           IN              VARCHAR2
  , p_soft_bound_flag           IN              VARCHAR2
  , p_workflow_process_id       IN              NUMBER
  , p_notification_flag         IN              VARCHAR2
  , p_notification_period       IN              NUMBER
  , p_notification_period_uom   IN              VARCHAR2
  , p_alarm_start               IN              NUMBER
  , p_alarm_start_uom           IN              VARCHAR2
  , p_alarm_on                  IN              VARCHAR2
  , p_alarm_count               IN              NUMBER
  , p_alarm_fired_count         IN              NUMBER
  , p_alarm_interval            IN              NUMBER
  , p_alarm_interval_uom        IN              VARCHAR2
  , p_palm_flag                 IN              VARCHAR2
  , p_wince_flag                IN              VARCHAR2
  , p_laptop_flag               IN              VARCHAR2
  , p_device1_flag              IN              VARCHAR2
  , p_device2_flag              IN              VARCHAR2
  , p_device3_flag              IN              VARCHAR2
  , p_show_on_calendar          IN              VARCHAR2
  , p_costs                     IN              NUMBER
  , p_currency_code             IN              VARCHAR2
  , p_escalation_level          IN              VARCHAR2
  , p_parent_task_id            IN              NUMBER
  , p_parent_task_number        IN              VARCHAR2
  , p_task_split_flag           IN              VARCHAR2
  , p_child_position            IN              VARCHAR2
  , p_child_sequence_num        IN              NUMBER
  , p_enable_workflow           IN              VARCHAR2
  , p_abort_workflow            IN              VARCHAR2
  , p_find_overlap              IN              VARCHAR2  DEFAULT NULL
  ) IS
    l_api_name      CONSTANT VARCHAR2 (30) := 'UPDATE_TASK';
    l_api_version   CONSTANT NUMBER        := 1.0;

    l_new_start_date         DATE;
    l_new_end_date           DATE;
    l_planned_effort         NUMBER;
    l_planned_effort_uom     VARCHAR2(3);
    l_planned_effort_minutes NUMBER;

    CURSOR c_overlap_tasks(p_trip_id NUMBER, p_start_date DATE, p_end_date DATE) IS
      SELECT NVL(TASK_NUMBER,TASK_ID) overlap_task_num
        FROM csr_trip_tasks_v
       WHERE object_capacity_id = p_trip_id
         AND task_id <> p_task_id
         AND NVL(actual_end_date,scheduled_end_date)  >= p_start_date
         AND NVL(actual_start_date,scheduled_start_date)  <= p_end_date;

    CURSOR c_task_info IS
      SELECT t.scheduled_start_date
          , t.scheduled_end_date
          , CASE WHEN ta.actual_start_date IS NULL AND ta.actual_end_date IS NULL THEN 'N' ELSE 'Y' END is_visited
          , ta.resource_id
          , ta.resource_type_code
          , ta.object_capacity_id
          , nvl(ta.actual_effort,t.planned_effort) planned_effort
          , nvl(ta.actual_effort_uom,t.planned_effort_uom) planned_effort_uom
          , ta.task_assignment_id
          , ta.object_version_number
          , t.task_status_id
          , t.planned_start_date
          , t.planned_end_date
          , ta.assignment_status_id
          , t.task_split_flag
          , t.task_number
       FROM jtf_tasks_b t,
           (SELECT  tas.actual_start_date
                 , tas.actual_end_date
                 , tas.resource_id
                 , tas.resource_type_code
                 , tas.object_capacity_id
                 , tas.task_assignment_id
                 , tas.object_version_number
                 , tas.assignment_status_id
                 , tas.task_id
                 , tas.actual_effort
                 , tas.actual_effort_uom
             FROM jtf_task_assignments tas, jtf_task_statuses_b ts
               WHERE task_id = p_task_id
               AND ts.task_status_id = tas.assignment_status_id
               AND NVL(ts.cancelled_flag, 'N') <> 'Y'
               AND NVL(ts.closed_flag, 'N') <> 'Y'
               AND NVL(ts.completed_flag, 'N') <> 'Y'
               AND NVL(ts.rejected_flag, 'N') <> 'Y'
             ) ta
        WHERE t.task_id = p_task_id
          AND t.task_id = ta.task_id(+)
          AND NVL(t.deleted_flag, 'N') <> 'Y';

    -- Fetch the Flags corresponding to the new Task Status.
    CURSOR c_task_status_info IS
      SELECT NVL (ts.closed_flag, 'N') closed_flag
           , NVL (ts.cancelled_flag, 'N') cancelled_flag
        FROM jtf_task_statuses_b ts
       WHERE ts.task_status_id = p_task_status_id;

--The below cursor +variables are added for access hours 8869998

	l_acc_hr_id           NUMBER;
	l_acchr_loc_id        NUMBER;
	l_acchr_ct_site_id    NUMBER;
	l_acchr_ct_id         NUMBER;
	l_acchrs_found        BOOLEAN;
	l_address_id_to_pass  NUMBER;
	l_location_id_to_pass NUMBER;
	conf_object_version_number NUMBER;
	x_object_version_number    NUMBER;
  l_auto_acc_hrs        VARCHAR2(1);
  l_task_status_flag    VARCHAR2(1);

	CURSOR c_acchrs_location_csr IS
	SELECT * from csf_map_access_hours_vl where
	customer_location_id = l_acchr_loc_id;

	CURSOR c_acchrs_ctsite_csr IS
		SELECT * from csf_map_access_hours_vl where
		customer_id = l_acchr_ct_id and
		customer_site_id = l_acchr_ct_site_id;


	CURSOR c_acchrs_ct_csr IS
		SELECT * from csf_map_access_hours_vl where
		customer_id = l_acchr_ct_id
    and customer_site_id is NULL
    and customer_location_id is NULL;
	l_acchrs_setups_rec   c_acchrs_location_csr%ROWTYPE;

	CURSOR c_task_details IS
	SELECT t.task_number,
	       t.location_id,
		   t.address_id,
		   t.customer_id,
		   NVL(t.location_id, ps.location_id) loc_id
	from jtf_tasks_b t, hz_party_sites ps
	where  task_id=p_task_id
	AND ps.party_site_id(+) = t.address_id;
	l_task_dtls c_task_details%rowtype;

	CURSOR c_access_hrs_chk IS
	SELECT b.access_hour_id,nvl(b.DATA_CHANGED_FRM_UI,'N') DATA_CHANGED,
        b.ACCESSHOUR_REQUIRED,
        b.AFTER_HOURS_FLAG,
        t.DESCRIPTION
	FROM   csf_access_hours_b b,csf_access_hours_tl t
	WHERE  b.task_id=p_task_id
    and    t.access_hour_id=b.access_hour_id
    and    t.language=userenv('LANG');

	l_acc_chk_info c_access_hrs_chk%rowtype;
--end of cursor added access hours validation



    l_task_info           c_task_info%ROWTYPE;
    l_task_status_info    c_task_status_info%ROWTYPE;
    l_overlap_tasks       VARCHAR2(2000);
    l_trip_id             NUMBER;
    l_task_object_version NUMBER;
    l_task_status_id      NUMBER;
    l_task_number         NUMBER;


  BEGIN
    SAVEPOINT csf_update_task;



    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_task_info;
    FETCH c_task_info INTO l_task_info;
    CLOSE c_task_info;

    l_new_start_date       := p_scheduled_start_date;
    l_new_end_date         := p_scheduled_end_date;

    IF p_validation_level = fnd_api.g_valid_level_full OR p_validation_level IS NULL THEN

      -- Validate Task Status Change
      IF p_task_status_id <> fnd_api.g_miss_num THEN
        validate_status_change(l_task_info.task_status_id, p_task_status_id);
      END IF;

      -- Validate Trip Information corresponding to new Scheduled Dates
      IF NVL(l_new_start_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date
        OR NVL(l_new_end_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date
      THEN

        l_planned_effort       := p_planned_effort;
        l_planned_effort_uom   := p_planned_effort_uom;

        IF l_planned_effort IS NULL OR l_planned_effort = fnd_api.g_miss_num THEN
          l_planned_effort := l_task_info.planned_effort;
        END IF;
        IF l_planned_effort_uom IS NULL OR l_planned_effort_uom = fnd_api.g_miss_char THEN
          l_planned_effort_uom := l_task_info.planned_effort_uom;
        END IF;

        l_planned_effort_minutes := csf_util_pvt.convert_to_minutes(
                                      l_planned_effort
                                    , l_planned_effort_uom
                                    );

        l_task_number := l_task_info.task_number;

        IF    l_task_info.task_split_flag <> 'M'
           AND l_planned_effort_minutes > CSR_SCHEDULER_PUB.GET_SCH_PARAMETER_VALUE('spDefaultShiftDuration')
        THEN
          fnd_message.set_name ('CSF', 'CSF_TASK_UPDATE_NOT_ALLOWED');
          fnd_message.set_token('TASK_NUMBER',l_task_number);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF     l_task_info.task_assignment_id IS NOT NULL
           AND l_task_info.is_visited = 'N'
           AND (   l_task_info.scheduled_start_date <> nvl(l_new_start_date,fnd_api.g_miss_date)
                OR l_task_info.scheduled_end_date <> nvl(l_new_end_date,fnd_api.g_miss_date) )
        THEN
          IF l_new_start_date IS NULL OR l_new_start_date = fnd_api.g_miss_date THEN
            l_new_start_date := l_new_end_date - l_planned_effort_minutes / (24 * 60);
          END IF;
          IF l_new_end_date IS NULL OR l_new_end_date = fnd_api.g_miss_date THEN
            l_new_end_date := l_new_start_date + l_planned_effort_minutes / (24 * 60);
          END IF;

          csf_trips_pub.find_trip(
            p_api_version         => 1
          , p_init_msg_list       => fnd_api.g_false
          , x_return_status       => x_return_status
          , x_msg_data            => x_msg_data
          , x_msg_count           => x_msg_count
          , p_resource_id         => l_task_info.resource_id
          , p_resource_type       => l_task_info.resource_type_code
          , p_start_date_time     => l_new_start_date
          , p_end_date_time       => l_new_end_date
          , p_overtime_flag       => fnd_api.g_true
          , x_trip_id             => l_trip_id
          );

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            -- No Trip or Multiple Trips found for the given dates. Make Trip as NULL
            l_trip_id := NULL;
          END IF;

          IF NVL(l_trip_id, -1) <> NVL(l_task_info.object_capacity_id,-1) THEN
            csf_task_assignments_pub.update_task_assignment(
              p_api_version                    => p_api_version
            , p_init_msg_list                  => p_init_msg_list
            , p_commit                         => fnd_api.g_false
            , p_validation_level               => fnd_api.g_valid_level_none
            , x_return_status                  => x_return_status
            , x_msg_count                      => x_msg_count
            , x_msg_data                       => x_msg_data
            , p_task_assignment_id             => l_task_info.task_assignment_id
            , p_object_version_number          => l_task_info.object_version_number
            , p_object_capacity_id             => l_trip_id
            , p_update_task                    => fnd_api.g_false
            , x_task_object_version_number     => l_task_object_version
            , x_task_status_id                 => l_task_status_id
            );

            IF x_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;

          IF fnd_api.to_boolean(p_find_overlap) THEN
            FOR v_overlap_tasks IN c_overlap_tasks(l_trip_id,l_new_start_date,l_new_end_date) LOOP
              l_overlap_tasks := l_overlap_tasks || fnd_global.local_chr(10) || v_overlap_tasks.overlap_task_num;
            END LOOP;
          END IF;
        END IF;
      END IF;
    END IF;

    IF p_task_status_id <> fnd_api.g_miss_num AND l_task_info.task_status_id <> p_task_status_id THEN
      -- Clear the Scheduled Dates if the Task is Cancelled
      OPEN c_task_status_info;
      FETCH c_task_status_info INTO l_task_status_info;
      CLOSE c_task_status_info;

      IF l_task_status_info.cancelled_flag = 'Y' THEN
        l_new_start_date := NULL;
        l_new_end_date   := NULL;
      END IF;
    END IF;



    jtf_tasks_pub.update_task(
      p_api_version             => p_api_version
    , p_init_msg_list           => p_init_msg_list
    , p_commit                  => fnd_api.g_false
    , x_return_status           => x_return_status
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , p_task_id                 => p_task_id
    , p_object_version_number   => p_object_version_number
    , p_task_number             => p_task_number
    , p_task_name               => p_task_name
    , p_description             => p_description
    , p_task_status_id          => p_task_status_id
    , p_planned_start_date      => p_planned_start_date
    , p_planned_end_date        => p_planned_end_date
    , p_scheduled_start_date    => l_new_start_date
    , p_scheduled_end_date      => l_new_end_date
    , p_actual_start_date       => p_actual_start_date
    , p_actual_end_date         => p_actual_end_date
    , p_timezone_id             => p_timezone_id
    , p_source_object_type_code => p_source_object_type_code
    , p_source_object_id        => p_source_object_id
    , p_source_object_name      => p_source_object_name
    , p_task_type_id            => p_task_type_id
    , p_task_priority_id        => p_task_priority_id
    , p_owner_type_code         => p_owner_type_code
    , p_owner_id                => p_owner_id
    , p_owner_territory_id      => p_owner_territory_id
    , p_owner_status_id         => p_owner_status_id
    , p_assigned_by_id          => p_assigned_by_id
    , p_customer_id             => p_customer_id
    , p_cust_account_id         => p_cust_account_id
    , p_address_id              => p_address_id
    , p_location_id             => p_location_id
    , p_duration                => p_duration
    , p_duration_uom            => p_duration_uom
    , p_planned_effort          => p_planned_effort
    , p_planned_effort_uom      => p_planned_effort_uom
    , p_actual_effort           => p_actual_effort
    , p_actual_effort_uom       => p_actual_effort_uom
    , p_percentage_complete     => p_percentage_complete
    , p_reason_code             => p_reason_code
    , p_private_flag            => p_private_flag
    , p_publish_flag            => p_publish_flag
    , p_restrict_closure_flag   => p_restrict_closure_flag
    , p_attribute1              => p_attribute1
    , p_attribute2              => p_attribute2
    , p_attribute3              => p_attribute3
    , p_attribute4              => p_attribute4
    , p_attribute5              => p_attribute5
    , p_attribute6              => p_attribute6
    , p_attribute7              => p_attribute7
    , p_attribute8              => p_attribute8
    , p_attribute9              => p_attribute9
    , p_attribute10             => p_attribute10
    , p_attribute11             => p_attribute11
    , p_attribute12             => p_attribute12
    , p_attribute13             => p_attribute13
    , p_attribute14             => p_attribute14
    , p_attribute15             => p_attribute15
    , p_attribute_category      => p_attribute_category
    , p_date_selected           => p_date_selected
    , p_category_id             => p_category_id
    , p_multi_booked_flag       => p_multi_booked_flag
    , p_milestone_flag          => p_milestone_flag
    , p_holiday_flag            => p_holiday_flag
    , p_billable_flag           => p_billable_flag
    , p_bound_mode_code         => p_bound_mode_code
    , p_soft_bound_flag         => p_soft_bound_flag
    , p_workflow_process_id     => p_workflow_process_id
    , p_notification_flag       => p_notification_flag
    , p_notification_period     => p_notification_period
    , p_notification_period_uom => p_notification_period_uom
    , p_alarm_start             => p_alarm_start
    , p_alarm_start_uom         => p_alarm_start_uom
    , p_alarm_on                => p_alarm_on
    , p_alarm_count             => p_alarm_count
    , p_alarm_fired_count       => p_alarm_fired_count
    , p_alarm_interval          => p_alarm_interval
    , p_alarm_interval_uom      => p_alarm_interval_uom
    , p_palm_flag               => p_palm_flag
    , p_wince_flag              => p_wince_flag
    , p_laptop_flag             => p_laptop_flag
    , p_device1_flag            => p_device1_flag
    , p_device2_flag            => p_device2_flag
    , p_device3_flag            => p_device3_flag
    , p_show_on_calendar        => p_show_on_calendar
    , p_costs                   => p_costs
    , p_currency_code           => p_currency_code
    , p_escalation_level        => p_escalation_level
    , p_parent_task_id          => p_parent_task_id
    , p_parent_task_number      => p_parent_task_number
    , p_task_split_flag         => p_task_split_flag
    , p_child_position          => p_child_position
    , p_child_sequence_num      => p_child_sequence_num
    , p_enable_workflow         => p_enable_workflow
    , p_abort_workflow          => p_abort_workflow
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;



    -- Propagate the Task Status Change to other dependent Objects.
    IF p_task_status_id <> fnd_api.g_miss_num THEN
      propagate_status_change(
        x_return_status          => x_return_status
      , x_msg_count              => x_msg_count
      , x_msg_data               => x_msg_data
      , p_task_id                => p_task_id
      , p_object_version_number  => p_object_version_number
      , p_new_task_status_id     => p_task_status_id
      , p_new_sts_cancelled_flag => l_task_status_info.cancelled_flag
      , p_new_sts_closed_flag    => l_task_status_info.closed_flag
      );
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
    l_auto_acc_hrs := fnd_profile.value('CSF_AUTO_POPULATE_ACCESS_HRS');
/*
1) Check if access hours setups are done for the location
2) Else, check if access hours setups are done for the ct + ct site combination
3) Else, check if access hours setups are done for the ct
4) Create access hours for the task, if acc hrs setups are found for the just created task
*/
    IF l_auto_acc_hrs ='Y'
    THEN
      	OPEN c_task_details;
      	FETCH c_task_details into l_task_dtls;
      	l_acchr_ct_id := l_task_dtls.customer_id;

      	IF (l_task_dtls.location_id IS NOT NULL) THEN
      		l_acchr_loc_id := l_task_dtls.location_id;
      		OPEN c_acchrs_location_csr;
      		FETCH c_acchrs_location_csr INTO l_acchrs_setups_rec;
      		IF (c_acchrs_location_csr%NOTFOUND) THEN
      			OPEN c_acchrs_ct_csr;
      			FETCH c_acchrs_ct_csr INTO l_acchrs_setups_rec;
      			IF (c_acchrs_ct_csr%NOTFOUND) THEN
      				l_acchrs_found := false;
      			ELSE
      				l_acchrs_found := true;
      			END IF;
      			close c_acchrs_ct_csr;
      		ELSE
      			l_acchrs_found := true;
      		END IF;
      		close c_acchrs_location_csr;
      	ELSIF(l_task_dtls.ADDRESS_ID IS NOT NULL) THEN
      		l_acchr_ct_site_id := l_task_dtls.address_id;
      		OPEN c_acchrs_ctsite_csr;
      		FETCH c_acchrs_ctsite_csr INTO l_acchrs_setups_rec;
      		IF (c_acchrs_ctsite_csr%NOTFOUND) THEN
      			OPEN c_acchrs_ct_csr;
      			FETCH c_acchrs_ct_csr INTO l_acchrs_setups_rec;
      			IF (c_acchrs_ct_csr%NOTFOUND) THEN
      				l_acchrs_found := false;
      			ELSE
      				l_acchrs_found := true;
      			END IF;
      			close c_acchrs_ct_csr;
      		ELSE
      			l_acchrs_found := true;
      		END IF;
      		close c_acchrs_ctsite_csr;
      	END IF;
        IF (l_acchrs_found = true)
      	THEN

      	  OPEN  c_access_hrs_chk;
      	  FETCH c_access_hrs_chk into l_acc_chk_info;
      	  CLOSE c_access_hrs_chk;

      	  IF l_acc_chk_info.DATA_CHANGED ='N'
      	  THEN

            l_task_status_flag := csf_access_hours_pub.get_task_status_flag(p_task_id);

            /*:('Inside condition ');
            test('Access hour in table :'||l_acc_chk_info.ACCESSHOUR_REQUIRED);
            test('Description :'||l_acchrs_setups_rec.DESCRIPTION);
            */
            IF l_task_status_flag = 'S'
            THEN
      	      CSF_ACCESS_HOURS_PUB.UPDATE_ACCESS_HOURS(
      	          p_ACCESS_HOUR_ID => l_acc_chk_info.access_hour_id,
                  p_API_VERSION => 1.0 ,
                  p_init_msg_list => NULL,
      	          p_TASK_ID => p_task_id,
      	          p_ACCESS_HOUR_REQD => l_acchrs_setups_rec.accesshour_required,
      	          p_AFTER_HOURS_FLAG => l_acchrs_setups_rec.after_hours_flag,
      	          p_MONDAY_FIRST_START => l_acchrs_setups_rec.MONDAY_FIRST_START,
      	          p_MONDAY_FIRST_END => l_acchrs_setups_rec.MONDAY_FIRST_END,
      	          p_MONDAY_SECOND_START => l_acchrs_setups_rec.MONDAY_SECOND_START,
      	          p_MONDAY_SECOND_END => l_acchrs_setups_rec.MONDAY_SECOND_END,
      	          p_TUESDAY_FIRST_START => l_acchrs_setups_rec.TUESDAY_FIRST_START,
      	          p_TUESDAY_FIRST_END => l_acchrs_setups_rec.TUESDAY_FIRST_END,
      	          p_TUESDAY_SECOND_START => l_acchrs_setups_rec.TUESDAY_SECOND_START,
      	          p_TUESDAY_SECOND_END => l_acchrs_setups_rec.TUESDAY_SECOND_END,
      	          p_WEDNESDAY_FIRST_START => l_acchrs_setups_rec.WEDNESDAY_FIRST_START,
      	          p_WEDNESDAY_FIRST_END => l_acchrs_setups_rec.WEDNESDAY_FIRST_END,
      	          p_WEDNESDAY_SECOND_START => l_acchrs_setups_rec.WEDNESDAY_SECOND_START,
      	          p_WEDNESDAY_SECOND_END => l_acchrs_setups_rec.WEDNESDAY_SECOND_END,
      	          p_THURSDAY_FIRST_START => l_acchrs_setups_rec.THURSDAY_FIRST_START,
      	          p_THURSDAY_FIRST_END => l_acchrs_setups_rec.THURSDAY_FIRST_END,
      	          p_THURSDAY_SECOND_START => l_acchrs_setups_rec.THURSDAY_SECOND_START,
      	          p_THURSDAY_SECOND_END => l_acchrs_setups_rec.THURSDAY_SECOND_END,
      	          p_FRIDAY_FIRST_START => l_acchrs_setups_rec.FRIDAY_FIRST_START,
      	          p_FRIDAY_FIRST_END => l_acchrs_setups_rec.FRIDAY_FIRST_END,
      	          p_FRIDAY_SECOND_START => l_acchrs_setups_rec.FRIDAY_SECOND_START,
      	          p_FRIDAY_SECOND_END => l_acchrs_setups_rec.FRIDAY_SECOND_END,
      	          p_SATURDAY_FIRST_START => l_acchrs_setups_rec.SATURDAY_FIRST_START,
      	          p_SATURDAY_FIRST_END => l_acchrs_setups_rec.SATURDAY_FIRST_END,
      	          p_SATURDAY_SECOND_START => l_acchrs_setups_rec.SATURDAY_SECOND_START,
      	          p_SATURDAY_SECOND_END => l_acchrs_setups_rec.SATURDAY_SECOND_END,
      	          p_SUNDAY_FIRST_START => l_acchrs_setups_rec.SUNDAY_FIRST_START,
      	          p_SUNDAY_FIRST_END => l_acchrs_setups_rec.SUNDAY_FIRST_END,
      	          p_SUNDAY_SECOND_START => l_acchrs_setups_rec.SUNDAY_SECOND_START,
      	          p_SUNDAY_SECOND_END => l_acchrs_setups_rec.SUNDAY_SECOND_END,
      	          p_DESCRIPTION => nvl(l_acchrs_setups_rec.DESCRIPTION,' '),
      	          px_object_version_number => x_object_version_number,
      	          p_CREATED_BY    => null,
      	          p_CREATION_DATE   => null,
      	          p_LAST_UPDATED_BY  => null,
      	          p_LAST_UPDATE_DATE => null,
      	          p_LAST_UPDATE_LOGIN =>  null,
                  x_return_status        => x_return_status,
                  x_msg_count            => x_msg_count,
                  x_msg_data             => x_msg_data );
              ELSIF l_task_status_flag = 'A'
              THEN
                /*test('Inside condition A');
                test('Access hour in table :'||l_acc_chk_info.ACCESSHOUR_REQUIRED);
                test('Access hour from PM table :'||l_acchrs_setups_rec.accesshour_required);
                test('After hour in table :'||l_acc_chk_info.AFTER_HOURS_FLAG);
                test('After hour from PM table :'||l_acchrs_setups_rec.after_hours_flag);
                test('Description in table :'||nvl(l_acc_chk_info.DESCRIPTION,'N' ));
                test('Description from PM table :'||nvl(l_acchrs_setups_rec.DESCRIPTION,'N' ));
                */
                IF ((l_acc_chk_info.ACCESSHOUR_REQUIRED ='Y' and  l_acchrs_setups_rec.accesshour_required ='N')
                OR  (l_acc_chk_info.AFTER_HOURS_FLAG ='Y' and l_acchrs_setups_rec.after_hours_flag='N')
                OR  (nvl(l_acc_chk_info.DESCRIPTION,'N' )<>nvl(l_acchrs_setups_rec.DESCRIPTION,'N' )))
                THEN
      	         CSF_ACCESS_HOURS_PUB.UPDATE_ACCESS_HOURS(
      	          p_ACCESS_HOUR_ID => l_acc_chk_info.access_hour_id,
                  p_API_VERSION => 1.0 ,
                  p_init_msg_list => NULL,
      	          p_TASK_ID => p_task_id,
                  p_ACCESS_HOUR_REQD => l_acchrs_setups_rec.accesshour_required,
      	          p_AFTER_HOURS_FLAG => l_acchrs_setups_rec.after_hours_flag,
      	          p_MONDAY_FIRST_START => NULL,
      	          p_MONDAY_FIRST_END => NULL,
      	          p_MONDAY_SECOND_START => NULL,
      	          p_MONDAY_SECOND_END => NULL,
      	          p_TUESDAY_FIRST_START => NULL,
      	          p_TUESDAY_FIRST_END => NULL,
      	          p_TUESDAY_SECOND_START => NULL,
      	          p_TUESDAY_SECOND_END => NULL,
      	          p_WEDNESDAY_FIRST_START => NULL,
      	          p_WEDNESDAY_FIRST_END => NULL,
      	          p_WEDNESDAY_SECOND_START => NULL,
      	          p_WEDNESDAY_SECOND_END => NULL,
      	          p_THURSDAY_FIRST_START => NULL,
      	          p_THURSDAY_FIRST_END => NULL,
      	          p_THURSDAY_SECOND_START => NULL,
      	          p_THURSDAY_SECOND_END => NULL,
      	          p_FRIDAY_FIRST_START => NULL,
      	          p_FRIDAY_FIRST_END => NULL,
      	          p_FRIDAY_SECOND_START => NULL,
      	          p_FRIDAY_SECOND_END => NULL,
      	          p_SATURDAY_FIRST_START => NULL,
      	          p_SATURDAY_FIRST_END => NULL,
      	          p_SATURDAY_SECOND_START => NULL,
      	          p_SATURDAY_SECOND_END => NULL,
      	          p_SUNDAY_FIRST_START => NULL,
      	          p_SUNDAY_FIRST_END => NULL,
      	          p_SUNDAY_SECOND_START => NULL,
      	          p_SUNDAY_SECOND_END => NULL,
      	          p_DESCRIPTION => nvl(l_acchrs_setups_rec.DESCRIPTION,' '),
      	          px_object_version_number => x_object_version_number,
      	          p_CREATED_BY    => null,
      	          p_CREATION_DATE   => null,
      	          p_LAST_UPDATED_BY  => null,
      	          p_LAST_UPDATE_DATE => null,
      	          p_LAST_UPDATE_LOGIN =>  null,
                  x_return_status        => x_return_status,
                  x_msg_count            => x_msg_count,
                  x_msg_data             => x_msg_data );
                END IF;
             END IF;

      	      			/*fnd_message.set_name('CSF','CSF_TASK_ACC_UPDATE_ERROR');
      				    fnd_message.set_token('VALUE',l_task_dtls.task_number);
      				    fnd_msg_pub.add;
      					Add_Err_Msg;*/
      			  IF x_return_status = fnd_api.g_ret_sts_error THEN
      					RAISE fnd_api.g_exc_error;
      			  ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      					RAISE fnd_api.g_exc_unexpected_error;
      			  END IF;
      		END IF;
      END IF;

    END IF;-- This endif is for l_auto_acc_hrs profile check
  	 /* VAKULKAR - end - changes to associate access hours to the tasks */
    IF fnd_api.to_boolean (p_commit) THEN
      COMMIT WORK;
    END IF;

    IF l_overlap_tasks IS NOT NULL THEN
      fnd_message.set_name('CSR','CSR_TASK_OVERLAP');
      fnd_message.set_token('TASKID', l_task_number);
      fnd_message.set_token('TASKS',l_overlap_tasks);
      fnd_msg_pub.add;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_update_task;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_update_task;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_update_task;
  END update_task;

  PROCEDURE commit_task (
    p_api_version       IN              NUMBER
  , p_init_msg_list     IN              VARCHAR2 DEFAULT NULL
  , p_commit            IN              VARCHAR2 DEFAULT NULL
  , x_return_status     OUT NOCOPY      VARCHAR2
  , x_msg_data          OUT NOCOPY      VARCHAR2
  , x_msg_count         OUT NOCOPY      NUMBER
  , p_task_id           IN              NUMBER
  , p_resource_id       IN              NUMBER    DEFAULT NULL --bug 6647019
  , p_resource_type     IN              VARCHAR2  DEFAULT NULL
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'COMMIT_TASK';
    l_api_version   CONSTANT NUMBER       := 1.0;
    l_new_status_id CONSTANT NUMBER       := g_assigned;

    -- Cursor to get the Task Details
    CURSOR c_task_details IS
      SELECT t.task_number
           , t.task_status_id
           , t.object_version_number
           , t.scheduled_start_date
           , t.scheduled_end_date
           , NVL (t.task_confirmation_status, 'N') task_confirmation_status
           , ta.task_assignment_id
           , ta.object_version_number ta_object_version_number
           , ta.object_capacity_id
           , ta.assignment_status_id
           , cac.status trip_status
		   , ta.resource_id
		   , ta.resource_type_code
        FROM jtf_tasks_b t
           , jtf_task_assignments ta
           , jtf_task_statuses_b ts
           , cac_sr_object_capacity cac
       WHERE t.task_id  = p_task_id
         AND ta.task_id = t.task_id
         AND ts.task_status_id = ta.assignment_status_id
         AND NVL (ts.assigned_flag, 'N')  <> 'Y'
         AND NVL (ts.working_flag, 'N')   <> 'Y'
         AND NVL (ts.completed_flag, 'N') <> 'Y'
         AND NVL (ts.closed_flag, 'N')    <> 'Y'
         AND NVL (ts.cancelled_flag, 'N') <> 'Y'
         AND cac.object_capacity_id (+) = ta.object_capacity_id;

    -- Cursor added for bug 6647019 by modifying cursor c_task_details. Added
    -- check for p_resource_id and p_resource_type
    -- Cursor to get the Task Details
    CURSOR c_task_details_1 IS
      SELECT t.task_number
           , t.task_status_id
           , t.object_version_number
           , t.scheduled_start_date
           , t.scheduled_end_date
           , NVL (t.task_confirmation_status, 'N') task_confirmation_status
           , ta.task_assignment_id
           , ta.object_version_number ta_object_version_number
           , ta.object_capacity_id
           , ta.assignment_status_id
           , cac.status trip_status
		   , ta.resource_id
		   , ta.resource_type_code
        FROM jtf_tasks_b t
           , jtf_task_assignments ta
           , jtf_task_statuses_b ts
           , cac_sr_object_capacity cac
       WHERE t.task_id  = p_task_id
         AND ta.task_id = t.task_id
         AND ts.task_status_id = ta.assignment_status_id
         AND NVL (ts.assigned_flag, 'N')  <> 'Y'
         AND NVL (ts.working_flag, 'N')   <> 'Y'
         AND NVL (ts.completed_flag, 'N') <> 'Y'
         AND NVL (ts.closed_flag, 'N')    <> 'Y'
         AND NVL (ts.cancelled_flag, 'N') <> 'Y'
         AND cac.object_capacity_id (+) = ta.object_capacity_id
	     AND ta.resource_id = p_resource_id
	     AND ta.resource_type_code = p_resource_type;


	CURSOR c_resource_tp(l_resource_id number, l_resource_type_code VARCHAR2)
	IS
	SELECT 'X'
	FROM   JTF_RS_DEFRESROLES_VL A,
	       JTF_RS_ALL_RESOURCES_VL B,
		   JTF_RS_ROLES_B D
	WHERE  A.ROLE_RESOURCE_ID   =l_resource_id
	AND    B.RESOURCE_ID 		= A.ROLE_RESOURCE_ID
	AND    B.RESOURCE_TYPE      =l_resource_type_code
	AND    D.ROLE_ID     = A.ROLE_ID
	AND    A.ROLE_TYPE_CODE       ='CSF_THIRD_PARTY'
	AND     NVL( A.DELETE_FLAG, 'N') = 'N'
	AND    (SYSDATE >= TRUNC (A.RES_RL_START_DATE) OR A.RES_RL_START_DATE IS NULL)
	AND    (SYSDATE <= TRUNC (A.RES_RL_END_DATE) + 1 OR A.RES_RL_END_DATE IS NULL)
	AND     D.ROLE_CODE IN ('CSF_THIRD_PARTY_SERVICE_PROVID','CSF_THIRD_PARTY_ADMINISTRATOR');

    l_task_details      c_task_details%ROWTYPE;
    l_trans_valid       VARCHAR2(1);
    l_valid_statuses    VARCHAR2(2000);
	l_resource_tp       varchar2(1);
	l_resource_id       number;
	l_resource_type_code VARCHAR2(100);
  BEGIN
    SAVEPOINT csf_commit_task;

    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    -- Fetch the Task Information

    IF p_resource_id is null or p_resource_type is null --condition added for bug 6647019
    THEN
    OPEN c_task_details;
    FETCH c_task_details INTO l_task_details;
    IF c_task_details%NOTFOUND THEN
      CLOSE c_task_details;
      fnd_message.set_name ('CSF', 'CSF_AUTO_COMMIT_TASK_STATUS');
      fnd_message.set_token ('P_TASK_NUMBER', task_number(p_task_id));
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_task_details;
    ELSE
    OPEN c_task_details_1;
    FETCH c_task_details_1 INTO l_task_details;
    IF c_task_details_1%NOTFOUND THEN
      CLOSE c_task_details_1;
      fnd_message.set_name ('CSF', 'CSF_AUTO_COMMIT_TASK_STATUS');
      fnd_message.set_token ('P_TASK_NUMBER', task_number(p_task_id));
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_task_details_1;
    END IF;

    -- Trip should not be in Blocked Status
    IF l_task_details.trip_status = csf_trips_pub.g_trip_unavailable THEN
      fnd_message.set_name ('CSF', 'CSF_AUTO_COMMIT_TRIP_BLOCK');
      fnd_message.set_token ('P_TASK_NUMBER', l_task_details.task_number);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Validate Status Transition
    l_trans_valid := validate_state_transition ('TASK_STATUS', l_task_details.assignment_status_id, l_new_status_id);
    IF l_trans_valid = fnd_api.g_false THEN
      l_valid_statuses := get_valid_statuses ('TASK_STATUS', l_task_details.assignment_status_id);
      IF l_valid_statuses IS NULL THEN
        fnd_message.set_name ('CSF', 'CSF_NO_STATE_TRANSITION');
      ELSE
        fnd_message.set_name ('CSF', 'CSF_INVALID_STATE_TRANSITION');
        fnd_message.set_token ('P_VALID_STATUSES', l_valid_statuses);
      END IF;
      fnd_message.set_token ('P_NEW_STATUS', get_task_status_name (l_new_status_id));
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Check the Customer Confirmation Status - Should be either No or Received
    IF l_task_details.task_confirmation_status = 'R' THEN
	  l_resource_id        := nvl(p_resource_id,l_task_details.resource_id);
	  l_resource_type_code := nvl(p_resource_type,l_task_details.resource_type_code);
	  OPEN c_resource_tp(l_resource_id,l_resource_type_code);
	  FETCH c_resource_tp into l_resource_tp;
	  CLOSE c_resource_tp;
	  /*IF l_resource_tp IS NULL
	  THEN
		fnd_message.set_name ('CSF', 'CSF_AUTO_COMMIT_CUST_CONF');
		fnd_message.set_token ('P_TASK_NUMBER', l_task_details.task_number);
		fnd_msg_pub.ADD;
		RAISE fnd_api.g_exc_error;
	  END IF;*/
    END IF;

    -- Check for Scheduled Dates
    IF l_task_details.scheduled_start_date IS NULL THEN
      fnd_message.set_name ('CSF', 'CSF_AUTO_COMMIT_TASK_SCHE');
      fnd_message.set_token ('P_TASK_NUMBER', l_task_details.task_number);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    csf_task_assignments_pub.update_assignment_status(
      p_api_version                    => 1.0
    , p_validation_level               => fnd_api.g_valid_level_none
    , p_init_msg_list                  => fnd_api.g_false
    , p_commit                         => fnd_api.g_false
    , x_return_status                  => x_return_status
    , x_msg_count                      => x_msg_count
    , x_msg_data                       => x_msg_data
    , p_task_assignment_id             => l_task_details.task_assignment_id
    , p_assignment_status_id           => l_new_status_id
    , p_object_version_number          => l_task_details.ta_object_version_number
    , x_task_object_version_number     => l_task_details.object_version_number
    , x_task_status_id                 => l_task_details.task_status_id
    );

    IF x_return_status = fnd_api.g_ret_sts_success THEN
      -- commented for the bug 6801965
      -- Committed Task Message is added to the message stack
     -- fnd_message.set_name ('CSF', 'CSF_AUTO_COMMITTED');
     -- fnd_message.set_token ('P_TASK_NUMBER', l_task_details.task_number);
     -- fnd_msg_pub.ADD;
      RETURN;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Standard check of p_commit
    IF fnd_api.to_boolean (p_commit) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_commit_task;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_commit_task;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_commit_task;
  END commit_task;

 PROCEDURE commit_schedule (
    p_api_version            IN          NUMBER
  , p_init_msg_list          IN          VARCHAR2
  , p_commit                 IN          VARCHAR2
  , x_return_status          OUT NOCOPY  VARCHAR2
  , x_msg_count              OUT NOCOPY  NUMBER
  , x_msg_data               OUT NOCOPY  VARCHAR2
  , p_resource_id            IN          NUMBER
  , p_resource_type          IN          VARCHAR2
  , p_scheduled_start_date   IN          DATE
  , p_scheduled_end_date     IN          DATE
  , p_query_id               IN          NUMBER
  , p_trip_id                IN          NUMBER
  , p_task_id                IN          NUMBER
  , p_task_source	         IN          VARCHAR2
  , p_commit_horizon		 IN  		 NUMBER
  , p_commit_horizon_uom	 IN  		 VARCHAR2
  , p_from_task_id			 IN  		 NUMBER
  , p_to_task_id			 IN  		 NUMBER
  , p_commit_horizon_from	 IN  		 NUMBER
  , p_commit_uom_from	 	 IN  		 VARCHAR2
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'COMMIT_SCHEDULE';
    l_api_version   CONSTANT NUMBER       := 1.0;



	p_res_id                   jtf_number_table			;
	p_res_type                 jtf_varchar2_table_2000  ;
	p_res_name                 jtf_varchar2_table_2000  ;
	p_res_typ_name             jtf_varchar2_table_2000  ;
	p_res_key                  jtf_varchar2_table_2000  ;

    l_field_uom_val   		   varchar2(30);
    l_base_unit_uom   		   varchar2(10);
	l_con_val				   number;

	l_convert_dur_to_day      NUMBER;
	l_start_date              DATE;
	l_end_date		          DATE;
	l_commit_horizon		  BOOLEAN:=FALSE;


    CURSOR C_Terr_Resource
    IS  SELECT  DISTINCT TR.RESOURCE_ID RESOURCE_ID,
                   TR.RESOURCE_TYPE RESOURCE_TYPE,
                   TR.RESOURCE_NAME RESOURCE_NAME,
                   CSF_GANTT_DATA_PKG.GET_RESOURCE_TYPE_NAME( TR.RESOURCE_TYPE ) RESOURCE_TYPE_NAME,
                   TR.RESOURCE_ID||'-'||TR.RESOURCE_TYPE
		FROM CSF_SELECTED_RESOURCES_V TR
        ORDER BY UPPER(TR.RESOURCE_NAME);



    TYPE ref_cursor_type IS REF CURSOR;
    TYPE task_split_tbl_type IS TABLE OF jtf_tasks_b.task_split_flag%TYPE;

    -- REF Cursor to form different query based on different conditions.
    c_task_list    ref_cursor_type;

    -- Cursor to fetch the WHERE Clause corresponding to the chosen Query.
    CURSOR c_query_where_clause IS
      SELECT where_clause
        FROM csf_dc_queries_b
       WHERE query_id = p_query_id;

    -- Cursor to fetch all Commit Child Candidates of a Parent Task
    -- and only those assigned to Resources belonging to the Dispatcher's Territory.
    CURSOR c_child_tasks (p_parent_task_id NUMBER) IS
      SELECT t.task_id
           , cac.status trip_status
        FROM jtf_tasks_b t
           , jtf_task_assignments ta
           , jtf_task_statuses_b ts
           , cac_sr_object_capacity cac
       WHERE t.parent_task_id = p_parent_task_id
         AND ta.task_id = t.task_id
         AND ts.task_status_id = ta.assignment_status_id
         AND cac.object_capacity_id(+) = ta.object_capacity_id          -- made this outer join for bug 6940526
         AND NVL(t.deleted_flag, 'N') <> 'Y'
         AND NVL(ts.cancelled_flag, 'N') <> 'Y'
	ORDER BY 1 DESC;

	--Cursor added for bug 6866929
    --This cursor +valriable l_cnt was added for checking multiple assignments for
    --for given task
    CURSOR check_assignments(p_task_id number)
	IS
    SELECT  count(task_id)
    FROM  jtf_task_assignments a
    ,     jtf_task_statuses_b b
    WHERE  a.task_id                   = p_task_id
    AND    a.assignment_status_id      = b.task_status_id
    AND    nvl(b.cancelled_flag  ,'N') <> 'Y';
    l_cnt                    NUMBER       :=1;

    l_where_clause         csf_dc_queries_b.where_clause%TYPE;
    l_query                VARCHAR2(2000);
    l_task_id_tbl          jtf_number_table;
    l_task_split_flag_tbl  task_split_tbl_type;
    l_task_num_tbl   jtf_number_table := jtf_number_table();
    l_child_task_id_tbl    jtf_number_table;
    l_trip_status_tbl      jtf_number_table;
    l_processed_count      PLS_INTEGER;
    l_blocked_trip_found   BOOLEAN;
    l_all_passed           BOOLEAN;

  BEGIN
    SAVEPOINT csf_commit_schedule;

    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    -- Check whether the required parameters are passed.
    IF p_query_id IS NULL AND p_resource_id IS NULL AND p_task_id IS NULL AND p_trip_id IS NULL THEN
      fnd_message.set_name('CSF', 'CSF_API_INVALID_PARAM');
      fnd_message.set_token('API_NAME', g_pkg_name || '.' || l_api_name);
      fnd_message.set_token('PARAM_NAME', 'P_QUERY_ID');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_query_id IS NOT NULL AND p_query_id <> -9999 THEN
      -- Query will be passed when Commit Schedule Functionality is called from
      -- Auto Commit Concurrent Program.

      --  Fetch the WHERE Clause for the given Query.
      OPEN c_query_where_clause;
      FETCH c_query_where_clause INTO l_where_clause;
      CLOSE c_query_where_clause;

      -- Frame the Task List Query

      -- TASK_SPLIT_FLAG is queried from JTF_TASKS_B again since the Query might
      -- return PARENT_TASK and CHILD_TASK also and because of that DISTINCT might
      -- return two rows one beloning to PARENT_TASK and another for CHILD_TASK bcos
      -- of TASK_SPLIT_FLAG.

     l_query :=   ' SELECT DISTINCT NVL(csf_dc_task_grid_v.parent_task_id, csf_dc_task_grid_v.task_id) task_id
                          , (SELECT t1.task_split_flag
                               FROM jtf_tasks_b t1
                              WHERE t1.task_id = NVL(csf_dc_task_grid_v.parent_task_id, csf_dc_task_grid_v.task_id)) task_split_flag
                       FROM csf_dc_task_grid_v
                      WHERE ' || l_where_clause || ' ORDER BY 1 DESC';

      -- Initialize the REF Cursor to point to the actual Task List Query.
      OPEN c_task_list FOR l_query;
	ELSIF (p_task_source is not null and p_task_source ='TERRITORY')
	THEN
			IF p_commit_horizon IS NOT NULL AND p_commit_horizon_uom IS NOT NULL
			THEN
				l_convert_dur_to_day  :=convert_to_days(p_commit_horizon,p_commit_horizon_uom, g_uom_hours);
				l_end_date	 		  :=sysdate+	l_convert_dur_to_day;
				l_commit_horizon	  :=TRUE;
			END IF;
			l_convert_dur_to_day:=0;
			IF p_commit_horizon_from IS NOT NULL AND p_commit_uom_from IS NOT NULL
			THEN
				l_convert_dur_to_day  :=convert_to_days(p_commit_horizon_from,p_commit_uom_from, g_uom_hours);
				l_start_date 		  :=sysdate-l_convert_dur_to_day;
			ELSE
				l_start_date 		  :=sysdate;
			END IF;

		    OPEN c_terr_resource;
			FETCH c_terr_resource
			BULK COLLECT INTO
				  p_res_id
				, p_res_type
				, p_res_name
				, p_res_typ_name
				, p_res_key;
			CLOSE c_terr_resource;


			IF not (l_commit_horizon)
			THEN
					l_query := 'SELECT DISTINCT NVL(t.parent_task_id, t.task_id) task_id
							   , t.task_split_flag
								 FROM jtf_tasks_b t
							   , jtf_task_assignments ta
							   , jtf_task_statuses_b ts
							   , (SELECT TO_NUMBER(SUBSTR(column_value
										  , 1
								  , INSTR(column_value, ''-'', 1, 1) - 1
										  )
								   )resource_id
								  ,SUBSTR(column_value
										  , INSTR(column_value, ''-'', 1, 1) + 1
										  , LENGTH(column_value)
										  ) resource_type
									FROM TABLE(CAST(:p_res_key AS jtf_varchar2_table_2000))
								  ) res_info
						    WHERE ta.resource_id = res_info.resource_id
							 AND ta.resource_type_code = res_info.resource_type
							 AND ts.task_status_id = ta.assignment_status_id
							 AND NVL(ts.closed_flag, ''N'') = ''N''
							 AND NVL(ts.completed_flag, ''N'') = ''N''
							 AND NVL(ts.cancelled_flag, ''N'') = ''N''
							 AND NVL(ts.assigned_flag, ''N'') <> ''Y''
							 AND NVL(ts.working_flag, ''N'')  <> ''Y''
							 AND t.task_id = ta.task_id
							 AND ta.task_id >=:p_from_task_id
							 AND ta.task_id <=:p_to_task_id
							 AND ta.booking_start_date>=:l_start_date
							 AND t.task_type_id NOT IN (20,21)
							 AND NVL(t.deleted_flag, ''N'') <> ''Y''
							 AND t.source_object_type_code = ''SR''
						    ORDER BY 1 DESC';
					OPEN c_task_list FOR l_query USING p_res_key,p_from_task_id,p_to_task_id,l_start_date;
			ELSE
					l_query := 'SELECT DISTINCT NVL(t.parent_task_id, t.task_id) task_id
							   , t.task_split_flag
								 FROM jtf_tasks_b t
							   , jtf_task_assignments ta
							   , jtf_task_statuses_b ts
							   , (SELECT TO_NUMBER(SUBSTR(column_value
										  , 1
								  , INSTR(column_value, ''-'', 1, 1) - 1
										  )
								   )resource_id
								  ,SUBSTR(column_value
										  , INSTR(column_value, ''-'', 1, 1) + 1
										  , LENGTH(column_value)
										  ) resource_type
									FROM TABLE(CAST(:p_res_key AS jtf_varchar2_table_2000))
								  ) res_info
						    WHERE ta.resource_id = res_info.resource_id
							 AND ta.resource_type_code = res_info.resource_type
							 AND ts.task_status_id = ta.assignment_status_id
							 AND NVL(ts.closed_flag, ''N'') = ''N''
							 AND NVL(ts.completed_flag, ''N'') = ''N''
							 AND NVL(ts.cancelled_flag, ''N'') = ''N''
							 AND NVL(ts.assigned_flag, ''N'') <> ''Y''
							 AND NVL(ts.working_flag, ''N'')  <> ''Y''
							 AND t.task_id = ta.task_id
							 AND ta.task_id >=:p_from_task_id
							 AND ta.task_id <=:p_to_task_id
							 AND ta.booking_start_date between :l_start_date AND :l_end_date
							 AND t.task_type_id NOT IN (20,21)
							 AND NVL(t.deleted_flag, ''N'') <> ''Y''
							 AND t.source_object_type_code = ''SR''
						    ORDER BY 1 DESC';
					OPEN c_task_list FOR l_query USING p_res_key,p_from_task_id,p_to_task_id,l_start_date,l_end_date;
			END IF;
    ELSIF p_resource_id IS NOT NULL and p_trip_id IS NULL THEN --altered condition for bug 6647019
      -- Resource Info and Dates will be passed when Commit Schedule Functionality is
      -- called from Plan Board or Gantt at a Resource Level.

      -- Frame the Task List Query using the given Resource and Schedule Dates info.

      -- There is no way for Parent Task to be queried as part of this Query and its
      -- sufficient for us to have Child's Task Split Flag alone

      l_query :=     'SELECT DISTINCT NVL(t.parent_task_id, t.task_id) task_id
                           , t.task_split_flag
                        FROM jtf_tasks_b t
                           , jtf_task_assignments ta
                           , jtf_task_statuses_b ts
                       WHERE ta.resource_id = :1
                         AND ta.resource_type_code = :2
                         AND ts.task_status_id = ta.assignment_status_id
                         AND NVL(ts.closed_flag, ''N'') = ''N''
                         AND NVL(ts.completed_flag, ''N'') = ''N''
                         AND NVL(ts.cancelled_flag, ''N'') = ''N''
                         AND ta.booking_start_date BETWEEN :3 and :4
                         AND t.task_id = ta.task_id
                         AND t.task_type_id NOT IN (20,21)
                         AND NVL(t.deleted_flag, ''N'') <> ''Y''
                         AND t.source_object_type_code = ''SR''
                       ORDER BY 1 DESC';

      -- Initialize the REF Cursor to point to the actual Task List Query.
      OPEN c_task_list FOR l_query USING p_resource_id
                                       , p_resource_type
                                       , p_scheduled_start_date
                                       , p_scheduled_end_date;
    ELSIF p_task_id IS NOT NULL THEN
      -- There is just one task and its sufficient for us to get the TASK_SPLIT_FLAG
      -- of that task.
      l_query :=     'SELECT NVL(t.parent_task_id, t.task_id) task_id
                           , task_split_flag
                        FROM jtf_tasks_b t
                       WHERE t.task_id = :1';

      OPEN c_task_list FOR l_query USING p_task_id;
    ELSIF p_trip_id IS NOT NULL THEN
      l_query :=     'SELECT NVL(t.parent_task_id, t.task_id) task_id
                           , task_split_flag
                        FROM cac_sr_object_capacity cac
                           , jtf_task_assignments ta
                           , jtf_tasks_b t
                           , jtf_task_statuses_b ts
                       WHERE cac.object_capacity_id = :1
                         AND ta.resource_id = cac.object_id
                         AND ta.resource_type_code = cac.object_type
                         AND ta.booking_start_date <= (cac.end_date_time + ' || g_overtime || ')
                         AND ta.booking_end_date >= cac.start_date_time
                         AND ts.task_status_id = ta.assignment_status_id
                         AND NVL(ts.closed_flag, ''N'') = ''N''
                         AND NVL(ts.completed_flag, ''N'') = ''N''
                         AND NVL(ts.cancelled_flag, ''N'') = ''N''
                         AND t.task_id = ta.task_id
                         AND t.task_type_id NOT IN (20,21)
                         AND NVL(t.deleted_flag, ''N'') <> ''Y''
                         AND t.source_object_type_code = ''SR''
                       ORDER BY 1 DESC';

      OPEN c_task_list FOR l_query USING p_trip_id;
    END IF;

    l_processed_count := 0;
    l_all_passed      := TRUE;
    LOOP
    FETCH c_task_list BULK COLLECT INTO l_task_id_tbl, l_task_split_flag_tbl LIMIT 1000;

		  -- Process each Task in the Task List
		IF l_task_id_tbl.COUNT = 0 THEN  -- if there are no tasks in the trip #bug7146595
			 fnd_message.set_name('CSF','CSF_NO_TASK_FOR_RESOURCE');
			 fnd_msg_pub.ADD;
		END IF;  -- end of code for the bug7146595

        FOR i IN 1..l_task_id_tbl.COUNT
	    LOOP
	        l_processed_count := l_processed_count + 1;

			--The following code is added for this bug 6866929
			OPEN  check_assignments(l_task_id_tbl(i));
			FETCH check_assignments into l_cnt;
			CLOSE check_assignments;
	        IF l_cnt > 1
			THEN
	          fnd_message.set_name('CSF','CSF_AUTO_COMMIT_MULTI_RES');
	          fnd_message.set_token ('TASK', task_number(l_task_id_tbl(i)));
		  	  fnd_msg_pub.ADD;
	          l_all_passed := FALSE;
			--End of the code added for this bug 6866929
		 	ELSE
				IF l_task_split_flag_tbl(i) IS NOT NULL THEN
				  -- The current Task is a Parent Task. Fetch the Child Tasks and Commit them
				  OPEN c_child_tasks(l_task_id_tbl(i));
				  FETCH c_child_tasks BULK COLLECT INTO l_child_task_id_tbl, l_trip_status_tbl;
				  CLOSE c_child_tasks;

				  -- Check whether any of the Trip containing the Child Task is blocked.
				  l_blocked_trip_found := FALSE;
				  FOR j IN 1..l_trip_status_tbl.COUNT LOOP
					IF l_trip_status_tbl(j) = csf_trips_pub.g_trip_unavailable THEN
					  fnd_message.set_name ('CSF', 'CSF_AUTO_COMMIT_CHILD_TRIP_BLK');
					  fnd_message.set_token ('P_TASK_NUMBER', task_number(l_child_task_id_tbl(j)));
					  fnd_message.set_token ('P_PARENT_TASK', task_number(l_task_id_tbl(i)));
					  fnd_msg_pub.ADD;
					  l_blocked_trip_found := TRUE;
					  l_all_passed := FALSE;
					  EXIT;
					END IF;
				  END LOOP;

				  IF NOT l_blocked_trip_found THEN
					FOR j IN 1..l_child_task_id_tbl.COUNT LOOP
					  commit_task (
						p_api_version    => 1.0
					  , x_return_status  => x_return_status
					  , x_msg_data       => x_msg_data
					  , x_msg_count      => x_msg_count
					  , p_task_id        => l_child_task_id_tbl(j)
					  );
					  IF x_return_status = fnd_api.g_ret_sts_error THEN
						l_all_passed := FALSE;
					  ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
						RAISE fnd_api.g_exc_unexpected_error;
					  END IF;
					END LOOP;
				  END IF;
				ELSE
				  commit_task (
					p_api_version    => 1.0
				  , x_return_status  => x_return_status
				  , x_msg_data       => x_msg_data
				  , x_msg_count      => x_msg_count
				  , p_task_id        => l_task_id_tbl(i)
				  , p_resource_id    => p_resource_id --bug 6647019
				  , p_resource_type  => p_resource_type
				  );
				  IF x_return_status = fnd_api.g_ret_sts_error THEN
					l_all_passed := FALSE;
				  ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
					RAISE fnd_api.g_exc_unexpected_error;
          ELSE --ADDED code for the bug 6801965
            l_task_num_tbl.extend;
            l_task_num_tbl(l_task_num_tbl.last) := l_task_id_tbl(i);
				  END IF;
				END IF;
			END IF;--This is endif for checking multiple task assignments.
	    END LOOP;
      EXIT WHEN c_task_list%NOTFOUND;
    END LOOP;



    IF l_processed_count = 0 AND p_query_id IS NOT NULL THEN
      fnd_message.set_name ('CSF', 'CSF_AUTO_COMMIT_NO_TASK');
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    IF NOT l_all_passed THEN
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    -- added code for the bug 6801965
    IF l_task_num_tbl.count > 0 THEN
      FOR i in 1..l_task_num_tbl.count
      LOOP
        fnd_message.set_name ('CSF', 'CSF_AUTO_COMMITTED');
        fnd_message.set_token ('P_TASK_NUMBER', task_number(l_task_num_tbl(i)));
        fnd_msg_pub.ADD;
     END LOOP;
    END IF;
    -- end of code for the bug 6801965
     CLOSE c_task_list;
    -- Standard check of p_commit
    IF fnd_api.to_boolean (p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_commit_schedule;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_commit_schedule;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_commit_schedule;
  END commit_schedule;

  /**
   * Updates the Task Information of the Parent Task by considering the current information
   * of all the Children.
   * <br>
   * The various attributes updated are
   *    1. Task Status Propagation from Child Task to Parent Task
   *    2. Scheduled Start Date of the Task
   *    3. Scheduled End Date of the Task
   *    4. Actual Start Date of the Task
   *    5. Actual Effort of the Task
   * <br>
   * <b> Task Status Propagation </b>
   * The Bitcodes of each Task Status is defined above. The Bitcodes have been
   * carefully chosen so that AND of the Bitcodes of all the Child Tasks will
   * give the Bitcode of the Task Status the Parent should ultimately take.
   * <br>
   * <b> For Example </b>
   * Case#1:
   * Let us assume there is a Parent Task P with three children C1, C2 and C3.
   *
   *    C1 Task Status = Closed   : Bitcode = 11001
   *    C2 Task Status = Working  : Bitcode = 00001
   *    C3 Task Status = Assigned : Bitcode = 00011
   *
   * We expect the Parent Task to be in Working Status. BIT AND of all the Child
   * Tasks will result in 00001 which translates to Working.
   * <br>
   * Case#2:
   * Let us assume there is a Parent Task P with three children C1, C2 and C3.
   *
   *    C1 Task Status = Closed   : Bitcode = 11001
   *    C2 Task Status = Closed   : Bitcode = 11001
   *    C3 Task Status = Assigned : Bitcode = 00011
   *
   * Since one of the Child Tasks is already Closed, it means that the Technician has
   * started to work on the Parent Task. So the Task Status should be Working. The BIT AND
   * of all the child tasks results in the same thing even though none of the child task is
   * in Working status.
   * <br>
   * Case#3:
   * Bitcode Transition will fail however when On-Hold comes into picture. If there are
   * any Child Tasks in On-Hold Status and all others are in Closed, Cancelled or Completed
   * status, then the Parent should be updated to On-Hold status. Even if any one of the
   * Child Task is in Working/Assigned/Planned status, then the Parent Task should
   * be updated to Working/Assigned/Planned (in the same order of preference). Thus any
   * Bitcode assigned to On-Hold will not work and it has to be treated separately.
   * <br>
   * Since there are Default Task Profiles for Planned, Asssigned, Cancelled and Working
   * a Global PLSQL Table is maintained to cache that information. But we might require
   * statuses corresponding to Closed, Completed and On-Hold. These are retrieved from the
   * Child Tasks and so another Local Table is also maintained to store these information
   * which will go out of scope once the procedure completes. Note that In-Planning
   * is not used as a task cant be a Parent if its in In-Planning.
   *
   * For more information refer to Bug#4032201.
   *
   * <br>
   * Scheduled Start Date will the minimum start date of all the children.
   * Scheduled End Date will the maximum end date of all the children.
   * Actual Start Date will the minimum start date of all the children.
   * Actual End Date will the maximum end date of all the children.
   * Actual Effort will be the sum of all the Actuals of Children after converting
   * to minutes.
   *
   * @param  p_api_version                   API Version (1.0)
   * @param  p_init_msg_list                 Initialize Message List
   * @param  p_commit                        Commit the Work
   * @param  x_return_status                 Return Status of the Procedure.
   * @param  x_msg_count                     Number of Messages in the Stack.
   * @param  x_msg_data                      Stack of Error Messages.
   * @param  p_parent_task_id                Task Identifier of the Parent Task.
   * @param  p_parent_version_number         Object Version of Parent Task
   * @param  p_planned_start_date            Planned start date of Parent Task.
   * @param  p_planned_end_date              Planned end date of Parent Task.
   */
  PROCEDURE sync_parent_with_child(
    p_api_version                  IN             NUMBER
  , p_init_msg_list                IN             VARCHAR2
  , p_commit                       IN             VARCHAR2
  , x_return_status                OUT     NOCOPY VARCHAR2
  , x_msg_count                    OUT     NOCOPY NUMBER
  , x_msg_data                     OUT     NOCOPY VARCHAR2
  , p_parent_task_id               IN             NUMBER
  , p_parent_version_number        IN  OUT NOCOPY NUMBER
  , p_planned_start_date           IN             DATE
  , p_planned_end_date             IN             DATE
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'SYNC_PARENT_WITH_CHILD';
    l_api_version   CONSTANT NUMBER       := 1.0;

    CURSOR c_curr_parent_info IS
      SELECT t.task_status_id
           , t.actual_start_date
           , t.actual_end_date
           , t.scheduled_start_date
           , t.scheduled_end_date
           , t.planned_start_date
           , t.planned_end_date
           , csf_util_pvt.convert_to_minutes(t.actual_effort, t.actual_effort_uom) actual_effort
        FROM jtf_tasks_b t
       WHERE t.task_id = p_parent_task_id
         AND NVL(t.deleted_flag, 'N') <> 'Y';

    CURSOR c_new_parent_info IS
      SELECT g_inplanning task_status_id
           , MIN(t.scheduled_start_date) scheduled_start_date
           , MAX(t.scheduled_end_date) scheduled_end_date
           , MIN(t.actual_start_date) actual_start_date
           , MAX(t.actual_end_date) actual_end_date
           , SUM(csf_util_pvt.convert_to_minutes(t.actual_effort, t.actual_effort_uom)) actual_effort
        FROM jtf_tasks_b t
           , jtf_task_statuses_b ts
       WHERE t.parent_task_id = p_parent_task_id
         AND NVL(t.deleted_flag, 'N') <> 'Y'
         AND ts.task_status_id = t.task_status_id
         AND NVL(ts.cancelled_flag, 'N') <> 'Y';

    CURSOR c_child_tasks IS
      SELECT t.task_id
           , t.task_status_id
           , NVL(ts.schedulable_flag, 'N') schedulable_flag
           , NVL(ts.assigned_flag,    'N') assigned_flag
           , NVL(ts.working_flag,     'N') working_flag
           , NVL(ts.completed_flag,   'N') completed_flag
           , NVL(ts.closed_flag,      'N') closed_flag
           , NVL(ts.on_hold_flag,     'N') on_hold_flag
           , NVL(ts.rejected_flag,    'N') rejected_flag
           , NVL(ts.cancelled_flag,   'N') cancelled_flag
	   , NVL(ts.accepted_flag,    'N') accepted_flag
	   , NVL(ts.assignment_status_flag, 'N') assignment_status_flag
           , 0 status_bitcode
        FROM jtf_tasks_b t
           , jtf_task_statuses_b ts
       WHERE t.parent_task_id = p_parent_task_id
         AND ts.task_status_id = t.task_status_id
         AND NVL(t.deleted_flag, 'N') <> 'Y'
       ORDER BY t.task_id;

    l_status_bitcode_map_tbl number_tbl_type;

    l_curr_parent_info       c_curr_parent_info%ROWTYPE;
    l_new_parent_info        c_new_parent_info%ROWTYPE;
    l_pri_sts_bitcode        NUMBER;
    l_sec_sts_bitcode        NUMBER;
    l_update_parent          BOOLEAN;
    l_actual_effort_uom      VARCHAR2(3);
    --*********** added for bug 6646890************
    l_update                 BOOLEAN := FALSE;
    l_child_status           NUMBER;
    i                        NUMBER := 1;
    --*********** added for bug 6646890************


    FUNCTION get_status_bitcode(p_task c_child_tasks%ROWTYPE)
      RETURN NUMBER IS
      l_status_bitcode NUMBER;
    BEGIN
      l_status_bitcode := g_start_bitcode;

      IF p_task.cancelled_flag = 'N' AND p_task.rejected_flag = 'N' AND p_task.on_hold_flag = 'N' THEN
        IF p_task.closed_flag = 'Y' THEN
          l_status_bitcode := g_closed_bitcode;
        ELSIF p_task.completed_flag = 'Y' THEN
          l_status_bitcode := g_completed_bitcode;
        ELSIF p_task.working_flag = 'Y' THEN
          l_status_bitcode := g_working_bitcode;
--*********** added for bug 6646890************
	ELSIF p_task.accepted_flag = 'Y' THEN
	  l_status_bitcode := g_accepted_bitcode;
--*********** added for bug 6646890************
        ELSIF p_task.assigned_flag = 'Y' THEN
          l_status_bitcode := g_assigned_bitcode;
        ELSIF p_task.schedulable_flag = 'Y' THEN
          l_status_bitcode := g_planned_bitcode;
        END IF;
        --RETURN l_status_bitcode + 480; -- 480 stands for 111100000
      ELSE
        IF p_task.cancelled_flag = 'Y' THEN
          l_status_bitcode := g_cancelled_bitcode;
        ELSIF p_task.rejected_flag = 'Y' THEN
          l_status_bitcode := g_rejected_bitcode;
        ELSE
          l_status_bitcode := g_onhold_bitcode;
        END IF;
        --RETURN l_status_bitcode + 31; -- 31 stands for 000011111
      END IF;

      RETURN l_status_bitcode;
    END get_status_bitcode;
  BEGIN
    SAVEPOINT csf_sync_parent_with_child;

    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_curr_parent_info;
    FETCH c_curr_parent_info INTO l_curr_parent_info;
    CLOSE c_curr_parent_info;

    OPEN c_new_parent_info;
    FETCH c_new_parent_info INTO l_new_parent_info;
    CLOSE c_new_parent_info;

    /****************************************************************************
    *             Propagating the Child Task's Status to the Parent             *
    *****************************************************************************/
    -- Initialize the Finite Automata.
    l_pri_sts_bitcode := g_start_bitcode;
    l_sec_sts_bitcode := g_start_bitcode;

    -- If we have Child Tasks one in Planned and another in Closed, we have to
    -- move the Parent to Working Status. But none of the Children would have
    -- given the Working Status ID. So take it from Default Value.
    l_status_bitcode_map_tbl(g_working_bitcode) := g_working;

    FOR v_child IN c_child_tasks LOOP
      -- Compute the Bit Code of the Current Child Task.
--*********** added for bug 6646890************
      IF i=1 THEN
         l_child_status := v_child.task_status_id ;
	 i := i+1;
      END IF;
      IF l_child_status = v_child.task_status_id THEN
          l_update := TRUE;
      ELSE
          l_update := FALSE;
      END IF;
--*********** added for bug 6646890************

      v_child.status_bitcode := get_status_bitcode(v_child);

      IF v_child.status_bitcode <> g_start_bitcode THEN
        IF BITAND (v_child.status_bitcode, 63) BETWEEN 1 AND 62 THEN
          l_pri_sts_bitcode := BITAND(l_pri_sts_bitcode, v_child.status_bitcode);
          l_status_bitcode_map_tbl(v_child.status_bitcode) := v_child.task_status_id;
        ELSIF BITAND (v_child.status_bitcode, 448) BETWEEN 63 AND 510 THEN
          l_sec_sts_bitcode := BITAND(l_sec_sts_bitcode, v_child.status_bitcode);
          l_status_bitcode_map_tbl(v_child.status_bitcode) := v_child.task_status_id;
        END IF;
      END IF;
    END LOOP;

    -- If we have a valid Primary Status for Parent, then we have to use that status.
    -- Otherwise we have to try using Secondary Status.
    -- (l_pri_sts_bitcode in (17,49)  and l_sec_sts_bitcode=g_onhold_bitcode ) has been added for the bug for the following
    --   scenario:
    --   Suppose there are two child tasks T1,T2.T1 is in onhold status and T2 in Completed/Closed Status . Then the parent task
    --   status should be Onhold.
    IF  (l_pri_sts_bitcode in (17,49)  and l_sec_sts_bitcode=g_onhold_bitcode ) or l_pri_sts_bitcode >= 63 THEN
      l_pri_sts_bitcode := l_sec_sts_bitcode;
    END IF;

    IF l_status_bitcode_map_tbl.EXISTS(l_pri_sts_bitcode) and not (l_update) THEN
      l_new_parent_info.task_status_id := l_status_bitcode_map_tbl(l_pri_sts_bitcode);
--*********** added for bug 6646890************
    ELSIF l_update THEN
      l_new_parent_info.task_status_id := l_child_status;
    END IF;
--*********** added for bug 6646890************

    /****************************************************************************
    *               Finding out whether Parent's Data has Changed               *
    *****************************************************************************/
    l_update_parent :=
                l_curr_parent_info.task_status_id <> l_new_parent_info.task_status_id
           OR ( NVL(l_curr_parent_info.scheduled_start_date, fnd_api.g_miss_date)
                  <> NVL(l_new_parent_info.scheduled_start_date, fnd_api.g_miss_date) )
           OR ( NVL(l_curr_parent_info.scheduled_end_date, fnd_api.g_miss_date)
                  <> NVL(l_new_parent_info.scheduled_end_date, fnd_api.g_miss_date) )
           OR ( NVL(l_curr_parent_info.actual_start_date, fnd_api.g_miss_date)
                  <> NVL(l_new_parent_info.actual_start_date, fnd_api.g_miss_date) )
           OR ( NVL(l_curr_parent_info.actual_end_date, fnd_api.g_miss_date)
                  <> NVL(l_new_parent_info.actual_end_date, fnd_api.g_miss_date) )
           OR ( NVL(l_curr_parent_info.planned_start_date, fnd_api.g_miss_date)
                  <> NVL(p_planned_start_date, fnd_api.g_miss_date) )
           OR ( NVL(l_curr_parent_info.planned_end_date, fnd_api.g_miss_date)
                  <> NVL(p_planned_end_date, fnd_api.g_miss_date) )
           OR ( NVL(l_curr_parent_info.actual_effort, -1)
                  <> NVL(l_new_parent_info.actual_effort, -1) );


    /****************************************************************************
    *                    Updating the Parent Task Information                   *
    *****************************************************************************/
    IF l_update_parent THEN
      IF l_new_parent_info.actual_effort IS NOT NULL THEN
        l_actual_effort_uom := csf_util_pvt.get_uom_minutes;
      END IF;

      jtf_tasks_pub.update_task (
        p_api_version                 => 1.0
      , p_init_msg_list               => p_init_msg_list
      , p_commit                      => fnd_api.g_false
      , x_return_status               => x_return_status
      , x_msg_count                   => x_msg_count
      , x_msg_data                    => x_msg_data
      , p_task_id                     => p_parent_task_id
      , p_object_version_number       => p_parent_version_number
      , p_task_status_id              => l_new_parent_info.task_status_id
      , p_scheduled_start_date        => l_new_parent_info.scheduled_start_date
      , p_scheduled_end_date          => l_new_parent_info.scheduled_end_date
      , p_planned_start_date          => p_planned_start_date
      , p_planned_end_date            => p_planned_end_date
      , p_actual_start_date           => l_new_parent_info.actual_start_date
      , p_actual_end_date             => l_new_parent_info.actual_end_date
      , p_actual_effort               => l_new_parent_info.actual_effort
      , p_actual_effort_uom           => l_actual_effort_uom
      , p_task_split_flag             => 'M'
      , p_enable_workflow             => fnd_api.g_miss_char
      , p_abort_workflow              => fnd_api.g_miss_char
      );

      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    -- Standard check of p_commit
    IF fnd_api.to_boolean (p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_sync_parent_with_child;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_sync_parent_with_child;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_sync_parent_with_child;
  END sync_parent_with_child;

  /**
   * Updates the Attributes of the Child Tasks by considering the Parent Task.
   *
   * @param  p_api_version                   API Version (1.0)
   * @param  p_init_msg_list                 Initialize Message List
   * @param  p_commit                        Commit the Work
   * @param  x_return_status                 Return Status of the Procedure.
   * @param  x_msg_count                     Number of Messages in the Stack.
   * @param  x_msg_data                      Stack of Error Messages.
   * @param  p_parent_task_id                Task Identifier of the Parent Task.
   */
  PROCEDURE sync_child_from_parent(
    p_api_version                  IN             NUMBER
  , p_init_msg_list                IN             VARCHAR2
  , p_commit                       IN             VARCHAR2
  , x_return_status                OUT     NOCOPY VARCHAR2
  , x_msg_count                    OUT     NOCOPY NUMBER
  , x_msg_data                     OUT     NOCOPY VARCHAR2
  , p_parent_task_id               IN             NUMBER
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'SYNC_CHILD_FROM_PARENT';
    l_api_version   CONSTANT NUMBER       := 1.0;

    CURSOR c_child_tasks IS
      SELECT t.task_id
           , t.object_version_number
           , NVL(t.child_position, '@@') child_position
           , NVL(t.child_sequence_num, -1) child_sequence_num
           , RANK() OVER (ORDER BY t.scheduled_start_date, t.scheduled_end_date,nvl(t.child_sequence_num,-1)) correct_seq_num
           , LEAD (t.task_id) OVER (ORDER BY t.scheduled_start_date, t.scheduled_end_date,nvl(t.child_sequence_num,-1)) next_task_id
        FROM jtf_tasks_b t ,jtf_task_statuses_b ts
       WHERE t.parent_task_id = p_parent_task_id
         AND NVL(t.deleted_flag, 'N') <> 'Y'
         AND ts.task_status_id = t.task_status_id
         AND NVL(ts.cancelled_flag, 'N') <> 'Y';

    l_child_position      jtf_tasks_b.child_position%TYPE;
  BEGIN
    SAVEPOINT csf_sync_child_from_parent;

    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    l_child_position := 'F';
    FOR v_child_task IN c_child_tasks LOOP
      IF v_child_task.next_task_id IS NULL AND v_child_task.correct_seq_num <> 1 THEN
        l_child_position := 'L';
      END IF;

      IF ( (v_child_task.child_sequence_num <> v_child_task.correct_seq_num)
           OR (v_child_task.child_position <> l_child_position) )
      THEN
        -- Update the Child Task
        jtf_tasks_pub.update_task(
          p_api_version               => 1.0
        , x_return_status             => x_return_status
        , x_msg_count                 => x_msg_count
        , x_msg_data                  => x_msg_data
        , p_task_id                   => v_child_task.task_id
        , p_task_split_flag           => fnd_api.g_miss_char
        , p_object_version_number     => v_child_task.object_version_number
        , p_child_sequence_num        => v_child_task.correct_seq_num
        , p_child_position            => l_child_position
        , p_enable_workflow           => fnd_api.g_miss_char
        , p_abort_workflow            => fnd_api.g_miss_char
        );

        IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

      l_child_position := 'M';
    END LOOP;

    -- Standard check of p_commit
    IF fnd_api.to_boolean (p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_sync_child_from_parent;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_sync_child_from_parent;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_sync_child_from_parent;
  END sync_child_from_parent;

  PROCEDURE assign_task(
    p_api_version                 IN              NUMBER
  , p_init_msg_list               IN              VARCHAR2
  , p_commit                      IN              VARCHAR2
  , x_return_status               OUT    NOCOPY   VARCHAR2
  , x_msg_count                   OUT    NOCOPY   NUMBER
  , x_msg_data                    OUT    NOCOPY   VARCHAR2
  , p_task_id                     IN              NUMBER
  , p_object_version_number       IN OUT NOCOPY   NUMBER
  , p_task_status_id              IN              NUMBER
  , p_scheduled_start_date        IN              DATE
  , p_scheduled_end_date          IN              DATE
  , p_planned_start_date          IN              DATE
  , p_planned_end_date            IN              DATE
  , p_old_task_assignment_id      IN              NUMBER
  , p_old_ta_object_version       IN              NUMBER
  , p_assignment_status_id        IN              NUMBER
  , p_resource_id                 IN              NUMBER
  , p_resource_type               IN              VARCHAR2
  , p_object_capacity_id          IN              NUMBER
  , p_sched_travel_distance       IN              NUMBER
  , p_sched_travel_duration       IN              NUMBER
  , p_sched_travel_duration_uom   IN              VARCHAR2
  , p_planned_effort              IN              NUMBER
  , p_planned_effort_uom          IN              VARCHAR2
  , x_task_assignment_id          OUT    NOCOPY   NUMBER
  , x_ta_object_version_number    OUT    NOCOPY   NUMBER
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'ASSIGN_TASK';
    l_api_version   CONSTANT NUMBER       := 1.0;

    CURSOR c_task_info IS
      SELECT t.task_id
           , t.task_status_id
           , t.task_split_flag
           , t.object_version_number
           , t.scheduled_start_date
           , t.scheduled_end_date
           , NVL( ( SELECT 'Y'
                      FROM jtf_task_assignments ta, jtf_task_statuses_b ats
                     WHERE ta.task_id = p_task_id
                       AND ta.assignment_status_id = ats.task_status_id
                       AND NVL(ats.cancelled_flag, 'N') <> 'Y'
                       AND ROWNUM = 1
                  ), 'N'
             ) is_scheduled
        FROM jtf_tasks_b t
       WHERE t.task_id = p_task_id;

    CURSOR c_task_assignment_info IS
      SELECT ta.resource_id
           , ta.resource_type_code
        FROM jtf_task_assignments ta
       WHERE ta.task_assignment_id = p_old_task_assignment_id;

    l_task_info               c_task_info%ROWTYPE;
    l_task_assignment_info    c_task_assignment_info%ROWTYPE;
    l_planned_effort          NUMBER;
    l_planned_effort_uom      VARCHAR2(3);
    l_create_assignment       BOOLEAN;
    l_assignment_status_id    NUMBER;
    l_role                    VARCHAR2(30);
    l_task_split_flag         VARCHAR2(1);
  BEGIN
    SAVEPOINT csf_assign_task;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    -- Get the Task Information
    OPEN c_task_info;
    FETCH c_task_info INTO l_task_info;
    CLOSE c_task_info;

    IF l_task_info.task_id IS NULL THEN
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'NO_DATA_FOUND JTF_TASKS_B.TASK_ID = ' || p_task_id);
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- If the Task is already Scheduled, then the Task Should be treated to be
    -- in Unscheduled Task Status as the task should have been unscheduled
    -- before rescheduling. Since we are avoiding unnecessary unscheduling,
    -- lets assume the old task status to be Unscheduled Task Status.
    IF l_task_info.is_scheduled = 'Y' THEN
      l_task_info.task_status_id := g_unscheduled;
    END IF;

    -- Find out whether the new Task Status is valid.
    validate_status_change(l_task_info.task_status_id, p_task_status_id);

    -- If the Old Assignment specified is linked to the same resource as that
    -- of the New Assignment, then there is no need to cancel the Old Assignment.
    -- Rather just update the Old Assignment with the new Travel Times.
    l_create_assignment := TRUE;

    IF p_old_task_assignment_id IS NOT NULL THEN
      g_reschedule := 'Y';
      x_ta_object_version_number := p_old_ta_object_version;
      l_assignment_status_id     := g_cancelled;

      OPEN c_task_assignment_info;
      FETCH c_task_assignment_info INTO l_task_assignment_info;
      CLOSE c_task_assignment_info;

      IF l_task_assignment_info.resource_id = p_resource_id
        AND l_task_assignment_info.resource_type_code = p_resource_type
      THEN
        l_create_assignment    := FALSE;
        l_assignment_status_id := p_assignment_status_id;
        x_task_assignment_id   := p_old_task_assignment_id;
      END IF;

      csf_task_assignments_pub.update_task_assignment (
        p_api_version                    => 1.0
      , p_validation_level               => fnd_api.g_valid_level_none
      , x_return_status                  => x_return_status
      , x_msg_count                      => x_msg_count
      , x_msg_data                       => x_msg_data
      , p_task_assignment_id             => p_old_task_assignment_id
      , p_object_version_number          => x_ta_object_version_number
      , p_assignment_status_id           => l_assignment_status_id
      , p_object_capacity_id             => p_object_capacity_id
      , p_sched_travel_distance          => p_sched_travel_distance
      , p_sched_travel_duration          => p_sched_travel_duration
      , p_sched_travel_duration_uom      => p_sched_travel_duration_uom
      , p_update_task                    => fnd_api.g_false
      , x_task_object_version_number     => l_task_info.object_version_number
      , x_task_status_id                 => l_task_info.task_status_id
      );
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    l_planned_effort := fnd_api.g_miss_num;
    l_planned_effort_uom := fnd_api.g_miss_char;

    IF (l_task_info.task_split_flag = 'D') THEN
      l_planned_effort     := p_planned_effort;
      l_planned_effort_uom := p_planned_effort_uom;
    END IF;

    l_role := csf_resource_pub.get_third_party_role ( p_resource_id
                                                    , p_resource_type
                                                    );

    IF ( l_role = 'CSF_THIRD_PARTY_SERVICE_PROVID' ) THEN
      l_task_split_flag := NULL;
    ELSE
      l_task_split_flag := fnd_api.g_miss_char;
    END IF;


    -- Update the Task
    jtf_tasks_pub.update_task(
      p_api_version               => 1.0
    , x_return_status             => x_return_status
    , x_msg_count                 => x_msg_count
    , x_msg_data                  => x_msg_data
    , p_task_id                   => p_task_id
    , p_object_version_number     => p_object_version_number
    , p_task_status_id            => p_task_status_id
    , p_scheduled_start_date      => p_scheduled_start_date
    , p_scheduled_end_date        => p_scheduled_end_date
    , p_planned_start_date        => p_planned_start_date
    , p_planned_end_date          => p_planned_end_date
    , p_planned_effort            => l_planned_effort
    , p_planned_effort_uom        => l_planned_effort_uom
    , p_task_split_flag           => l_task_split_flag
    , p_enable_workflow           => fnd_api.g_miss_char
    , p_abort_workflow            => fnd_api.g_miss_char
    );
    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Clear out the Rejection Message, if any.
    UPDATE jtf_tasks_tl
       SET rejection_message = NULL
     WHERE task_id = p_task_id;


    -- Create the Task Assignment
    IF l_create_assignment THEN
      csf_task_assignments_pub.create_task_assignment(
        p_api_version                    => 1.0
      , p_validation_level               => fnd_api.g_valid_level_none
      , x_return_status                  => x_return_status
      , x_msg_count                      => x_msg_count
      , x_msg_data                       => x_msg_data
      , p_task_id                        => p_task_id
      , p_resource_id                    => p_resource_id
      , p_resource_type_code             => p_resource_type
      , p_assignment_status_id           => p_assignment_status_id
      , p_object_capacity_id             => p_object_capacity_id
      , p_sched_travel_distance          => p_sched_travel_distance
      , p_sched_travel_duration          => p_sched_travel_duration
      , p_sched_travel_duration_uom      => p_sched_travel_duration_uom
      , p_update_task                    => fnd_api.g_false
      , x_task_assignment_id             => x_task_assignment_id
      , x_ta_object_version_number       => x_ta_object_version_number
      , x_task_object_version_number     => p_object_version_number
      , x_task_status_id                 => l_task_info.task_status_id
      );

      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_assign_task;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_assign_task;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_assign_task;
  END assign_task;

  PROCEDURE unassign_task(
    p_api_version                IN              NUMBER
  , p_init_msg_list              IN              VARCHAR2
  , p_commit                     IN              VARCHAR2
  , x_return_status              OUT    NOCOPY   VARCHAR2
  , x_msg_count                  OUT    NOCOPY   NUMBER
  , x_msg_data                   OUT    NOCOPY   VARCHAR2
  , p_task_id                    IN              NUMBER
  , p_object_version_number      IN OUT NOCOPY   NUMBER
  , p_task_status_id             IN              NUMBER
  , p_task_assignment_id         IN              NUMBER
  , p_ta_object_version_number   IN OUT NOCOPY   NUMBER
  , p_assignment_status_id       IN              NUMBER
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UNASSIGN_TASK';
    l_api_version   CONSTANT NUMBER       := 1.0;

    CURSOR c_task_info IS
      SELECT t.task_id
           , t.task_status_id
           , t.task_split_flag
           , source_object_type_code
           , scheduled_start_date
           , scheduled_end_date
           , ta.assignment_status_id
           , ta.object_capacity_id
        FROM jtf_tasks_b t , jtf_task_assignments ta
       WHERE t.task_id = p_task_id
        AND  ta.task_id = t.task_id
        AND  ta.task_assignment_id = p_task_assignment_id;

    -- Fetch the Flags corresponding to the new Task Status.
    CURSOR c_task_status_info IS
      SELECT NVL (ts.closed_flag, 'N') closed_flag
           , NVL (ts.cancelled_flag, 'N') cancelled_flag
        FROM jtf_task_statuses_b ts
       WHERE ts.task_status_id = p_task_status_id;

    l_task_info         c_task_info%ROWTYPE;
    l_task_status_info  c_task_status_info%ROWTYPE;
    l_task_status_id    NUMBER;
  BEGIN
    SAVEPOINT csf_unassign_task;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_task_info;
    FETCH c_task_info INTO l_task_info;
    CLOSE c_task_info;

    IF nvl(l_task_info.assignment_status_id, -1) <> NVL(p_assignment_status_id, g_cancelled)
      OR l_task_info.object_capacity_id IS NOT NULL THEN
      -- Cancel the Task Assignment
      -- P_OBJECT_CAPACITY_ID is passed as NULL so that when UPDATE_ASSIGNMENT_STATUS
      -- Queries the Task Information, there will not be any Trip Information and
      -- Update is avoided as Scheduler will take care of the update.
      csf_task_assignments_pub.update_task_assignment (
        p_api_version                    => 1.0
      , p_validation_level               => fnd_api.g_valid_level_none
      , x_return_status                  => x_return_status
      , x_msg_count                      => x_msg_count
      , x_msg_data                       => x_msg_data
      , p_task_assignment_id             => p_task_assignment_id
      , p_assignment_status_id           => NVL(p_assignment_status_id, g_cancelled)
      , p_object_version_number          => p_ta_object_version_number
      , p_object_capacity_id             => NULL
      , p_update_task                    => fnd_api.g_false
      , x_task_object_version_number     => p_object_version_number
      , x_task_status_id                 => l_task_status_id
      );
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF NVL(p_task_status_id,-1) <> nvl(l_task_info.task_status_id,-1)
       OR ( l_task_info.source_object_type_code = 'SR'
            AND ( l_task_info.scheduled_start_date IS NOT NULL
                  OR l_task_info.scheduled_end_date IS NOT NULL ) ) THEN

      -- Validate the Task Status Transition
      validate_status_change(l_task_info.task_status_id, p_task_status_id);

      IF l_task_info.source_object_type_code = 'SR' THEN
        l_task_info.scheduled_start_date := NULL;
        l_task_info.scheduled_end_date   := NULL;
      END IF;

      -- Update the Task Information.
      jtf_tasks_pub.update_task(
        p_api_version           => 1.0
      , x_return_status         => x_return_status
      , x_msg_count             => x_msg_count
      , x_msg_data              => x_msg_data
      , p_task_id               => p_task_id
      , p_object_version_number => p_object_version_number
      , p_task_status_id        => p_task_status_id
      , p_scheduled_start_date  => l_task_info.scheduled_start_date
      , p_scheduled_end_date    => l_task_info.scheduled_end_date
      , p_enable_workflow       => fnd_api.g_miss_char
      , p_abort_workflow        => fnd_api.g_miss_char
      );
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    -- if the task is a child task and is being cancelled, delete(logically) the task
    IF l_task_info.task_split_flag = 'D' THEN

      OPEN c_task_status_info;
      FETCH c_task_status_info INTO l_task_status_info;
      CLOSE c_task_status_info;

      IF l_task_status_info.cancelled_flag = 'Y' THEN
        csf_tasks_pub.delete_task (
          p_api_version                 => 1.0
        , x_return_status               => x_return_status
        , x_msg_count                   => x_msg_count
        , x_msg_data                    => x_msg_data
        , p_task_id                     => p_task_id
        , p_object_version_number       => p_object_version_number
        );

        IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_unassign_task;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_unassign_task;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_unassign_task;
  END unassign_task;

  PROCEDURE update_task_and_assignment(
    p_api_version                 IN              NUMBER
  , p_init_msg_list               IN              VARCHAR2
  , p_commit                      IN              VARCHAR2
  , x_return_status               OUT    NOCOPY   VARCHAR2
  , x_msg_count                   OUT    NOCOPY   NUMBER
  , x_msg_data                    OUT    NOCOPY   VARCHAR2
  , p_task_id                     IN              NUMBER
  , p_object_version_number       IN OUT NOCOPY   NUMBER
  , p_scheduled_start_date        IN              DATE
  , p_scheduled_end_date          IN              DATE
  , p_task_assignment_id          IN              NUMBER
  , p_ta_object_version_number    IN OUT NOCOPY   NUMBER
  , p_sched_travel_distance       IN              NUMBER
  , p_sched_travel_duration       IN              NUMBER
  , p_sched_travel_duration_uom   IN              VARCHAR2
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_TASK_AND_ASSIGNMENT';
    l_api_version   CONSTANT NUMBER       := 1.0;
    l_scheduled_start        DATE;
    l_scheduled_end          DATE;
    l_distance               NUMBER;
    l_duration               NUMBER;
    l_duration_uom           VARCHAR2(3);

  BEGIN
    SAVEPOINT csf_update_task_and_assignment;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    -- Update the Task Assignment if any columns are changing
    IF    p_sched_travel_distance IS NOT NULL
       OR p_sched_travel_duration IS NOT NULL
       OR p_sched_travel_duration_uom IS NOT NULL
    THEN
      jtf_task_assignments_pub.update_task_assignment(
        p_api_version               => 1.0
      , x_return_status             => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_task_assignment_id        => p_task_assignment_id
      , p_object_version_number     => p_ta_object_version_number
      , p_sched_travel_distance     => p_sched_travel_distance
      , p_sched_travel_duration     => p_sched_travel_duration
      , p_sched_travel_duration_uom => p_sched_travel_duration_uom
      , p_enable_workflow           => fnd_api.g_miss_char
      , p_abort_workflow            => fnd_api.g_miss_char
      );
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    -- Update the Task if any columns are changing
    IF p_scheduled_start_date IS NOT NULL OR p_scheduled_end_date IS NOT NULL THEN
      jtf_tasks_pub.update_task(
        p_api_version               => 1.0
      , x_return_status             => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_task_id                   => p_task_id
      , p_object_version_number     => p_object_version_number
      , p_scheduled_start_date      => p_scheduled_start_date
      , p_scheduled_end_date        => p_scheduled_end_date
      , p_enable_workflow           => fnd_api.g_miss_char
      , p_abort_workflow            => fnd_api.g_miss_char
      );

      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_update_task_and_assignment;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_update_task_and_assignment;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_update_task_and_assignment;
  END update_task_and_assignment;

  PROCEDURE update_task_longer_than_shift(
    p_api_version             IN              NUMBER
  , p_init_msg_list           IN              VARCHAR2
  , p_commit                  IN              VARCHAR2
  , x_return_status           OUT NOCOPY      VARCHAR2
  , x_msg_count               OUT NOCOPY      NUMBER
  , x_msg_data                OUT NOCOPY      VARCHAR2
  , p_task_id                 IN              NUMBER
  , p_object_version_number   IN OUT NOCOPY   NUMBER
  , p_planned_start_date      IN              DATE
  , p_planned_end_date        IN 	      DATE
  , p_action                  IN              PLS_INTEGER
  , p_task_status_id          IN              NUMBER
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_TASK_LONGER_THAN_SHIFT';
    l_api_version   CONSTANT NUMBER       := 1.0;

    CURSOR c_parent_task_info IS
      SELECT t.task_id
           , t.task_status_id
           , t.scheduled_start_date
           , t.scheduled_end_date
           , t.planned_effort
           , t.planned_effort_uom
           , t.task_split_flag
        FROM jtf_tasks_b t
       WHERE t.task_id = p_task_id;

    CURSOR c_child_tasks IS
      SELECT t.task_id
           , t.object_version_number task_ovn
           , t.task_status_id
           , ta.task_assignment_id
           , ta.object_version_number task_assignment_ovn
           , ta.assignment_status_id
        FROM jtf_tasks_b t ,jtf_task_statuses_b ts ,jtf_task_assignments ta
       WHERE t.parent_task_id = p_task_id
         AND NVL(t.deleted_flag, 'N') <> 'Y'
         AND ts.task_status_id = t.task_status_id
         AND NVL(ts.cancelled_flag, 'N') <> 'Y'
         AND t.task_id = ta.task_id
         AND ta.assignment_status_id = ts.task_status_id;

    l_parent_task_info    c_parent_task_info%ROWTYPE;
    l_scheduled_start     DATE;
    l_scheduled_end       DATE;
    l_task_split_flag     VARCHAR2(1);
  BEGIN
    SAVEPOINT update_task_longer_than_shift;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    -- Get the Task Information
    OPEN c_parent_task_info;
    FETCH c_parent_task_info INTO l_parent_task_info;
    CLOSE c_parent_task_info;

    IF l_parent_task_info.task_id IS NULL THEN
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'NO_DATA_FOUND JTF_TASKS_B.TASK_ID = ' || p_task_id);
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Find out whether the new Task Status is valid.
    IF p_task_status_id <> fnd_api.g_miss_num THEN
      validate_status_change(l_parent_task_info.task_status_id, p_task_status_id);
    END IF;

    IF p_action = g_action_normal_to_parent THEN
      -- Correct the Parent Task Information based on current Child Tasks
      sync_parent_with_child(
        p_api_version            => 1.0
      , p_init_msg_list          => fnd_api.g_false
      , p_commit                 => fnd_api.g_false
      , x_return_status          => x_return_status
      , x_msg_count              => x_msg_count
      , x_msg_data               => x_msg_data
      , p_parent_task_id         => p_task_id
      , p_parent_version_number  => p_object_version_number
      , p_planned_start_date     => p_planned_start_date
      , p_planned_end_date       => p_planned_end_date
      );
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Correct the Child Task's Information
      sync_child_from_parent(
        p_api_version               => 1.0
      , p_init_msg_list             => fnd_api.g_false
      , p_commit                    => fnd_api.g_false
      , x_return_status             => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_parent_task_id            => p_task_id
      );
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF p_action = g_action_parent_to_normal THEN
      jtf_tasks_pub.update_task(
        p_api_version               => 1.0
      , x_return_status             => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_task_id                   => p_task_id
      , p_object_version_number     => p_object_version_number
      , p_task_status_id            => p_task_status_id
      , p_scheduled_start_date      => NULL
      , p_scheduled_end_date        => NULL
      , p_task_split_flag           => NULL
      , p_actual_start_date         => NULL
      , p_actual_end_date           => NULL
      , p_actual_effort             => NULL
      , p_actual_effort_uom         => NULL
      , p_enable_workflow           => fnd_api.g_miss_char
      , p_abort_workflow            => fnd_api.g_miss_char
      );

      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- cancel all children if parent is changed back to normal.
      FOR child_task IN c_child_tasks LOOP
        unassign_task(
            p_api_version                => 1.0
          , p_init_msg_list              => fnd_api.g_false
          , p_commit                     => fnd_api.g_false
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_task_id                    => child_task.task_id
          , p_object_version_number      => child_task.task_ovn
          , p_task_status_id             => g_cancelled
          , p_task_assignment_id         => child_task.task_assignment_id
          , p_ta_object_version_number   => child_task.task_assignment_ovn
          , p_assignment_status_id       => g_cancelled
          );
        IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_task_longer_than_shift;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_longer_than_shift;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO update_task_longer_than_shift;
  END update_task_longer_than_shift;

  PROCEDURE create_child_task(
    p_api_version                 IN              NUMBER
  , p_init_msg_list               IN              VARCHAR2
  , p_commit                      IN              VARCHAR2
  , x_return_status               OUT NOCOPY      VARCHAR2
  , x_msg_count                   OUT NOCOPY      NUMBER
  , x_msg_data                    OUT NOCOPY      VARCHAR2
  , p_parent_task_id              IN              NUMBER
  , p_task_status_id              IN              NUMBER
  , p_planned_effort              IN              NUMBER
  , p_planned_effort_uom          IN              VARCHAR2
  , p_bound_mode_code             IN              VARCHAR2
  , p_soft_bound_flag             IN              VARCHAR2
  , p_scheduled_start_date        IN              DATE
  , p_scheduled_end_date          IN              DATE
  , p_assignment_status_id        IN              NUMBER
  , p_resource_id                 IN              NUMBER
  , p_resource_type               IN              VARCHAR2
  , p_object_capacity_id          IN              NUMBER
  , p_sched_travel_distance       IN              NUMBER
  , p_sched_travel_duration       IN              NUMBER
  , p_sched_travel_duration_uom   IN              VARCHAR2
  , p_child_position              IN              VARCHAR2
  , p_child_sequence_num          IN              NUMBER
  , x_task_id                     OUT NOCOPY      NUMBER
  , x_object_version_number       OUT NOCOPY      NUMBER
  , x_task_assignment_id          OUT NOCOPY      NUMBER
  ) IS
    l_api_name      CONSTANT VARCHAR2(30)       := 'CREATE_CHILD_TASK';
    l_api_version   CONSTANT NUMBER             := 1.0;

    CURSOR c_parent_task_info IS
      SELECT t.task_name
           , t.description
           , t.task_type_id
           , t.task_priority_id
           , t.address_id
           , t.customer_id
           , t.source_object_type_code
           , t.source_object_id
           , t.source_object_name
           , t.owner_type_code
           , t.owner_id
           , t.task_confirmation_status
           , t.task_confirmation_counter
           , t.cust_account_id
           , t.planned_effort_uom
         FROM jtf_tasks_vl t
       WHERE t.task_id = p_parent_task_id;

    l_parent_task_info            c_parent_task_info%ROWTYPE;
  BEGIN
    SAVEPOINT csf_create_child_task;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    -- Get the Parent Task Information
    OPEN c_parent_task_info;
    FETCH c_parent_task_info INTO l_parent_task_info;
    IF c_parent_task_info%NOTFOUND THEN
      CLOSE c_parent_task_info;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'NO_DATA_FOUND JTF_TASKS_B.TASK_ID = ' || p_parent_task_id);
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    CLOSE c_parent_task_info;

    -- Create the Child Task using Parent Task Information
    -- (Set Zero Length Planned Window at Scheduled Start, Bound Mode code in BTS)
    jtf_tasks_pub.create_task(
      p_api_version                 => 1.0
    , p_init_msg_list               => fnd_api.g_false
    , p_commit                      => fnd_api.g_false
    , x_return_status               => x_return_status
    , x_msg_count                   => x_msg_count
    , x_msg_data                    => x_msg_data
    , p_task_name                   => l_parent_task_info.task_name
    , p_description                 => l_parent_task_info.description
    , p_task_type_id                => l_parent_task_info.task_type_id
    , p_task_status_id              => p_task_status_id
    , p_task_priority_id            => l_parent_task_info.task_priority_id
    , p_owner_id                    => l_parent_task_info.owner_id
    , p_owner_type_code             => l_parent_task_info.owner_type_code
    , p_customer_id                 => l_parent_task_info.customer_id
    , p_address_id                  => l_parent_task_info.address_id
    , p_planned_start_date          => p_scheduled_start_date
    , p_planned_end_date            => p_scheduled_start_date
    , p_scheduled_start_date        => p_scheduled_start_date
    , p_scheduled_end_date          => p_scheduled_end_date
    , p_source_object_type_code     => l_parent_task_info.source_object_type_code
    , p_source_object_id            => l_parent_task_info.source_object_id
    , p_source_object_name          => l_parent_task_info.source_object_name
    , p_planned_effort              => p_planned_effort
    , p_planned_effort_uom          => p_planned_effort_uom
    , p_bound_mode_code             => p_bound_mode_code
    , p_soft_bound_flag             => p_soft_bound_flag
    , p_parent_task_id              => p_parent_task_id
    , p_cust_account_id             => l_parent_task_info.cust_account_id
    , p_enable_workflow             => NULL
    , p_abort_workflow              => NULL
    , p_task_split_flag             => 'D'
    , p_child_position              => NVL(p_child_position, 'N')
    , p_child_sequence_num          => p_child_sequence_num
    , x_task_id                     => x_task_id
    );
    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    x_object_version_number := 1;

    -- Copy Task Confirmation Values.
    IF l_parent_task_info.task_confirmation_status = 'N' THEN
      NULL;
      -- JTF automatically creates Task with Confirmation Status as N and
      -- Counter as ZERO. Thus there is no need for another uncessary update.
    ELSIF l_parent_task_info.task_confirmation_status = 'R' THEN
      jtf_task_confirmation_pub.set_confirmation_required(
        p_api_version               => 1.0
      , p_init_msg_list             => fnd_api.g_false
      , p_commit                    => fnd_api.g_false
      , x_return_status             => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_task_id                   => x_task_id
      , p_object_version_number     => x_object_version_number
      );
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF l_parent_task_info.task_confirmation_status = 'C' THEN
      jtf_task_confirmation_pub.set_confirmation_confirmed(
        p_api_version               => 1.0
      , p_init_msg_list             => fnd_api.g_false
      , p_commit                    => fnd_api.g_false
      , x_return_status             => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_task_id                   => x_task_id
      , p_object_version_number     => x_object_version_number
      );
      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      IF l_parent_task_info.task_confirmation_counter > 0 THEN
        -- This is one horrible way of incrementing the counter. JTF has not given
        -- a API to set it directly. This way will increase the Object Version
        -- Number for each increase..
        FOR k IN 1 .. l_parent_task_info.task_confirmation_counter LOOP
          jtf_task_confirmation_pub.increase_counter(
            p_api_version               => 1.0
          , p_init_msg_list             => fnd_api.g_false
          , p_commit                    => fnd_api.g_false
          , x_return_status             => x_return_status
          , x_msg_count                 => x_msg_count
          , x_msg_data                  => x_msg_data
          , p_task_id                   => x_task_id
          , p_object_version_number     => x_object_version_number
          );
          IF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END LOOP;
      END IF;
    END IF;

    -- Create the Task Assignment
    jtf_task_assignments_pub.create_task_assignment(
      p_api_version                => 1.0
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_task_id                    => x_task_id
    , p_resource_id                => p_resource_id
    , p_resource_type_code         => p_resource_type
    , p_assignment_status_id       => p_assignment_status_id
    , p_object_capacity_id         => p_object_capacity_id
    , p_sched_travel_distance      => p_sched_travel_distance
    , p_sched_travel_duration      => p_sched_travel_duration
    , p_sched_travel_duration_uom  => p_sched_travel_duration_uom
    , p_enable_workflow            => NULL
    , p_abort_workflow             => NULL
    , p_free_busy_type             => NULL
    , x_task_assignment_id         => x_task_assignment_id
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_create_child_task;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_create_child_task;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_create_child_task;
  END create_child_task;

  /**
   * Updates the customer confirmation for normal/child/parent task
   *
   * @param  p_api_version                   API Version (1.0)
   * @param  p_init_msg_list                 Initialize Message List
   * @param  p_commit                        Commit the Work
   * @param  x_return_status                 Return Status of the Procedure
   * @param  x_msg_count                     Number of Messages in the Stack
   * @param  x_msg_data                      Stack of Error Messages
   * @param  p_task_id                       Task to be processed
   * @param  p_object_version_number         Object version of input task
   * @param  p_action                        Whether Required/Received/Not Required
   * @param  p_initiated                     Whether Customer or Dispatcher
   */

  PROCEDURE update_cust_confirmation(
    p_api_version            IN            NUMBER
  , p_init_msg_list          IN            VARCHAR2
  , p_commit                 IN            VARCHAR2
  , x_return_status          OUT NOCOPY    VARCHAR2
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , p_task_id                IN            NUMBER
  , p_object_version_number  IN OUT NOCOPY NUMBER
  , p_action                 IN            PLS_INTEGER
  , p_initiated              IN            PLS_INTEGER
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)     := 'UPDATE_CUST_CONFIRMATION';
    l_api_version CONSTANT NUMBER           := 1.0;
    i             PLS_INTEGER               := 1;

    CURSOR c_task_info (p_task_id NUMBER) IS
      SELECT t.task_id
           , t.task_split_flag
           , t.parent_task_id
           , t.task_confirmation_status
        FROM jtf_tasks_b t
       WHERE t.task_id = p_task_id;

    CURSOR c_parent_child_tasks (p_task_id NUMBER) IS
      SELECT jtb.task_id
           , jtb.object_version_number
        FROM jtf_task_statuses_vl ts, jtf_tasks_b jtb
       WHERE jtb.parent_task_id = p_task_id
         AND ts.task_status_id = jtb.task_status_id
         AND jtb.task_split_flag = 'D'
         AND (    NVL(ts.on_hold_flag,     'N') = 'Y'
               OR NVL(ts.working_flag,     'N') = 'Y'
               OR NVL(ts.schedulable_flag, 'N') = 'Y'
               OR (     NVL(ts.assigned_flag,  'N') = 'Y'
                    AND NVL(ts.closed_flag,    'N') <> 'Y'
                    AND NVL(ts.approved_flag,  'N') <> 'Y'
                    AND NVL(ts.completed_flag, 'N') <> 'Y'
                    AND NVL(ts.rejected_flag,  'N') <> 'Y' ))
      UNION
       SELECT t.task_id
            , t.object_version_number
         FROM jtf_tasks_b t
        WHERE task_id = p_task_id;

    l_cust_task_tbl   jtf_number_table := jtf_number_table();
    l_cust_objver_tbl jtf_number_table := jtf_number_table();
    l_task_info       c_task_info%ROWTYPE;
  BEGIN
    SAVEPOINT csf_update_cust_confirmation;

    x_return_status := fnd_api.g_ret_sts_success;

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    OPEN c_task_info(p_task_id);
    FETCH c_task_info INTO l_task_info;
    CLOSE c_task_info;

    IF ( l_task_info.task_split_flag IS NULL ) THEN
      l_cust_task_tbl.extend();
      l_cust_objver_tbl.extend();
      l_cust_task_tbl(l_cust_task_tbl.last) := p_task_id;
      l_cust_objver_tbl(l_cust_objver_tbl.last) := p_object_version_number;
    ELSIF ( l_task_info.task_split_flag = 'M' ) THEN
      OPEN c_parent_child_tasks(l_task_info.task_id);
      FETCH c_parent_child_tasks  BULK COLLECT INTO l_cust_task_tbl, l_cust_objver_tbl;
      CLOSE c_parent_child_tasks;
    ELSIF ( l_task_info.task_split_flag = 'D' ) THEN
      OPEN c_parent_child_tasks(l_task_info.parent_task_id);
      FETCH c_parent_child_tasks BULK COLLECT INTO l_cust_task_tbl, l_cust_objver_tbl;
      CLOSE c_parent_child_tasks;
    END IF;

    i:= l_cust_task_tbl.first;
    WHILE i IS NOT null
    LOOP
      IF p_action = csf_tasks_pub.g_action_conf_to_received THEN
        jtf_task_confirmation_pub.set_confirmation_confirmed(
          p_api_version               => 1.0
        , p_init_msg_list             => fnd_api.g_false
        , p_commit                    => fnd_api.g_false
        , x_return_status             => x_return_status
        , x_msg_count                 => x_msg_count
        , x_msg_data                  => x_msg_data
        , p_task_id                   => l_cust_task_tbl(i)
        , p_object_version_number     => l_cust_objver_tbl(i)
        );
      ELSIF p_action = csf_tasks_pub.g_action_conf_to_required THEN
        jtf_task_confirmation_pub.set_confirmation_required(
          p_api_version               => 1.0
        , p_init_msg_list             => fnd_api.g_false
        , p_commit                    => fnd_api.g_false
        , x_return_status             => x_return_status
        , x_msg_count                 => x_msg_count
        , x_msg_data                  => x_msg_data
        , p_task_id                   => l_cust_task_tbl(i)
        , p_object_version_number     => l_cust_objver_tbl(i)
        );
        IF x_return_status = fnd_api.g_ret_sts_success THEN
          IF l_task_info.task_confirmation_status = 'C' THEN
            IF p_initiated = csf_tasks_pub.g_dispatcher_initiated THEN
              jtf_task_confirmation_pub.increase_counter(
                p_api_version               => 1.0
              , p_init_msg_list             => fnd_api.g_false
              , p_commit                    => fnd_api.g_false
              , x_return_status             => x_return_status
              , x_msg_count                 => x_msg_count
              , x_msg_data                  => x_msg_data
              , p_task_id                   => l_cust_task_tbl(i)
              , p_object_version_number     => l_cust_objver_tbl(i)
              );
            ELSIF p_initiated = csf_tasks_pub.g_customer_initiated THEN
              jtf_task_confirmation_pub.reset_counter(
                p_api_version           => 1.0
              , p_commit          => fnd_api.g_false
              , p_init_msg_list         => fnd_api.g_false
              , p_object_version_number => l_cust_objver_tbl(i)
              , p_task_id               => l_cust_task_tbl(i)
              , x_return_status         => x_return_status
              , x_msg_count             => x_msg_count
              , x_msg_data              => x_msg_data
              );
            END IF;
          END IF;
        END IF;
      ELSIF p_action = csf_tasks_pub.g_action_conf_not_required THEN
        jtf_task_confirmation_pub.reset_confirmation_status(
          p_api_version               => 1.0
        , p_init_msg_list             => fnd_api.g_false
        , p_commit                    => fnd_api.g_false
        , x_return_status             => x_return_status
        , x_msg_count                 => x_msg_count
        , x_msg_data                  => x_msg_data
        , p_task_id                   => l_cust_task_tbl(i)
        , p_object_version_number     => l_cust_objver_tbl(i)
       );
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF ( p_task_id = l_cust_task_tbl(i) ) THEN
        p_object_version_number := l_cust_objver_tbl(i);
      END IF;

      i := l_cust_task_tbl.next(i);
    END LOOP;

    -- Standard check of p_commit
    IF fnd_api.to_boolean (p_commit) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_update_cust_confirmation;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_update_cust_confirmation;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_update_cust_confirmation;
  END update_cust_confirmation;

  FUNCTION get_task_location_id (
    p_task_id       IN NUMBER
  , p_party_site_id IN NUMBER
  , p_location_id   IN NUMBER
  ) RETURN NUMBER
  IS
    l_location_id NUMBER;

    CURSOR c_ps_location IS
      SELECT ps.location_id
        FROM hz_party_sites ps
       WHERE ps.party_site_id = p_party_site_id;

    CURSOR c_task_location IS
      SELECT NVL(t.location_id, ps.location_id)
        FROM jtf_tasks_b t
           , hz_party_sites ps
       WHERE t.task_id = p_task_id
         AND ps.party_site_id(+) = t.address_id;

  BEGIN
    IF p_location_id IS NOT NULL THEN
      l_location_id := p_location_id;
    ELSIF p_party_site_id IS NOT NULL THEN
      OPEN c_ps_location;
      FETCH c_ps_location INTO l_location_id;
      CLOSE c_ps_location;
    ELSE
      OPEN c_task_location;
      FETCH c_task_location INTO l_location_id;
      CLOSE c_task_location;
    END IF;

    RETURN l_location_id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END get_task_location_id;

  FUNCTION get_task_address (
    p_task_id       IN NUMBER
  , p_party_site_id IN NUMBER
  , p_location_id   IN NUMBER
  , p_short_flag    IN VARCHAR2
  ) RETURN VARCHAR2
  IS
    CURSOR c_location_info IS
      SELECT l.address1
           , l.address2
           , l.address3
           , l.address4
           , l.postal_code
           , l.city
           , l.state
           , l.province
           , l.country
        FROM hz_locations l
       WHERE l.location_id = p_location_id;

    CURSOR c_ps_location_info IS
      SELECT l.address1
           , l.address2
           , l.address3
           , l.address4
           , l.postal_code
           , l.city
           , l.state
           , l.province
           , l.country
        FROM hz_party_sites ps
           , hz_locations l
       WHERE ps.party_site_id = p_party_site_id
         AND l.location_id    = ps.location_id;

    CURSOR c_task_location_info IS
      SELECT l.address1
           , l.address2
           , l.address3
           , l.address4
           , l.postal_code
           , l.city
           , l.state
           , l.province
           , l.country
        FROM jtf_tasks_b t
           , hz_party_sites ps
           , hz_locations l
       WHERE t.task_id           = p_task_id
         AND ps.party_site_id(+) = t.address_id
         AND l.location_id       = NVL(t.location_id, ps.location_id);

    l_address       VARCHAR2(1300);
    l_location_rec  c_location_info%ROWTYPE;
  BEGIN
    IF p_location_id IS NOT NULL THEN
      OPEN c_location_info;
      FETCH c_location_info INTO l_location_rec;
      CLOSE c_location_info;
    ELSIF p_party_site_id IS NOT NULL THEN
      OPEN c_ps_location_info;
      FETCH c_ps_location_info INTO l_location_rec;
      CLOSE c_ps_location_info;
    ELSE
      OPEN c_task_location_info;
      FETCH c_task_location_info INTO l_location_rec;
      CLOSE c_task_location_info;
    END IF;

    IF p_short_flag = 'Y' THEN
      IF l_location_rec.postal_code IS NOT NULL THEN
        l_address := l_location_rec.postal_code;
      ELSE
        l_address := l_location_rec.address1;
      END IF;

      IF l_location_rec.city IS NOT NULL THEN
        l_address := l_address || ',' || l_location_rec.city;
      END IF;

      IF l_location_rec.state IS NOT NULL THEN
        l_address := l_address || ',' || l_location_rec.state;
      ELSIF l_location_rec.province IS NOT NULL THEN
        l_address := l_address || ',' || l_location_rec.province;
      END IF;
    ELSE
      l_address := l_location_rec.address1;
      IF l_location_rec.address2 IS NOT NULL THEN
        l_address := l_address || ',' || l_location_rec.address2;
      END IF;

      IF l_location_rec.address3 IS NOT NULL THEN
        l_address := l_address || ',' || l_location_rec.address3;
      END IF;

      IF l_location_rec.address4 IS NOT NULL THEN
        l_address := l_address || ',' || l_location_rec.address4;
      END IF;

      IF l_location_rec.postal_code IS NOT NULL THEN
        l_address := l_address || ',' || l_location_rec.postal_code;
      END IF;

      IF l_location_rec.city IS NOT NULL THEN
        l_address := l_address || ',' || l_location_rec.city;
      END IF;

      IF l_location_rec.state IS NOT NULL THEN
        l_address := l_address || ',' || l_location_rec.state;
      ELSIF l_location_rec.province IS NOT NULL THEN
        l_address := l_address || ',' || l_location_rec.province;
      END IF;

      l_address := l_address || ',' || l_location_rec.country;
    END IF;

    RETURN l_address;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_task_address;

  /**
   * Gets the Task Effort conditionally converted to the Default UOM as given by
   * the profile CSF: Default Effort UOM by calling
   * CSF_UTIL_PVT.GET_EFFORT_IN_DEFAULT_UOM function.
   * <br>
   * All parameters are optional. If Planned Effort, Planned Effort UOM and Task
   * Split Flag are passed, then it helps in better performance as JTF_TASKS_B
   * wont be queried to get those information. In case of better flexibility,
   * the caller can just pass the Task ID and the API will fetch the required
   * information. If case none of the required parameters are passed, the API returns
   * NULL.
   * <br>
   * Parent Task / Normal Tasks are created by the Teleservice Operators and therefore
   * its always better to represent them in the UOM they had given initially. Tasks
   * created as part of the Background processes like Child Tasks are always created
   * in Minutes by Scheduler and therefore it is incumbent upon us to represent
   * them in a proper UOM. Thus this API will convert the Planned Effort to the default
   * UOM only for Child Tasks and will merely act as a Concatenation Operator for
   * other Tasks. If you want to overrule this and want conversion to Default UOM
   * to take place for all Tasks, pass p_always_convert as FND_API.G_TRUE
   *
   * Also refer to the documentation on CSF_UTIL_PVT.GET_EFFORT_IN_DEFAULT_UOM.
   * <br>
   *
   * @param p_planned_effort      Planned Effort to be converted
   * @param p_planned_effort_uom  UOM of the above Effort
   * @param p_task_split_flag     Determines whether the Task is Child / Other
   * @param p_task_id             Task ID of the Task whose effort is to be converted
   * @param p_always_convert      Overrule the condition and convert for all Tasks.
   *
   * @result Planned Effort appro converted to Default UOM.
   */
  FUNCTION get_task_effort_in_default_uom(
    p_planned_effort       NUMBER
  , p_planned_effort_uom   VARCHAR2
  , p_task_split_flag      VARCHAR2
  , p_task_id              NUMBER
  , p_always_convert       VARCHAR2
  )
    RETURN VARCHAR2 IS

    l_effort           NUMBER;
    l_effort_uom       jtf_tasks_b.planned_effort_uom%TYPE;
    l_task_split_flag  jtf_tasks_b.task_split_flag%TYPE;

    CURSOR c_task_info IS
      SELECT NVL(p_planned_effort, planned_effort) planned_effort
           , NVL(p_planned_effort_uom, planned_effort_uom) planned_effort_uom
           , decode(p_task_split_flag, '@', task_split_flag, p_task_split_flag) task_split_flag
        FROM jtf_tasks_b
       WHERE task_id = p_task_id;
  BEGIN
    l_effort          := p_planned_effort;
    l_effort_uom      := p_planned_effort_uom;
    l_task_split_flag := p_task_split_flag;

    IF    l_effort IS NULL
       OR l_effort_uom IS NULL
       OR ( l_task_split_flag = '@' AND NVL(p_always_convert, fnd_api.g_false) = fnd_api.g_false)
    THEN
      IF p_task_id IS NOT NULL THEN
        OPEN c_task_info;
        FETCH c_task_info INTO l_effort, l_effort_uom, l_task_split_flag;
        CLOSE c_task_info;
      END IF;
    END IF;

    IF l_effort IS NULL OR l_effort_uom IS NULL THEN
      RETURN NULL;
    END IF;

    IF     NVL(l_task_split_flag, 'M') IN ('M', '@')
       AND NVL(p_always_convert, fnd_api.g_false) = fnd_api.g_false
    THEN
      RETURN l_effort || ' ' || csf_util_pvt.get_uom(l_effort_uom);
    END IF;

    RETURN csf_util_pvt.get_effort_in_default_uom(l_effort, l_effort_uom);
  END get_task_effort_in_default_uom;

  PROCEDURE get_contact_details(
    p_incident_id    IN        NUMBER
  , p_task_id        IN        NUMBER
  , x_last_name     OUT NOCOPY VARCHAR2
  , x_first_name    OUT NOCOPY VARCHAR2
  , x_title         OUT NOCOPY VARCHAR2
  , x_phone         OUT NOCOPY VARCHAR2
  , x_phone_ext     OUT NOCOPY VARCHAR2
  , x_email_address OUT NOCOPY VARCHAR2
  ) IS
    l_contact_source CONSTANT VARCHAR2(10) := fnd_profile.value('CSF_DFLT_SOURCE_FOR_CONTACT');

    l_contact_type      cs_sr_contact_points_v.contact_type%TYPE;
    l_contact_point_id  cs_sr_contact_points_v.contact_point_id%TYPE;
    l_party_id          cs_sr_contact_points_v.party_id%TYPE;

    -- Cursor to fetch the Task Contact Points
    CURSOR c_task_contact_points IS
      SELECT pc.person_last_name last_name
           , pc.person_first_name first_name
           , pc.person_title title
           , tp.phone_id
        FROM jtf_task_contacts tc
           , jtf_party_all_contacts_v pc
           , jtf_task_phones_v tp
       WHERE tc.task_id = p_task_id
         AND tc.contact_id IN (pc.party_id, pc.subject_party_id)
         AND tp.task_contact_id (+) = tc.task_contact_id;

    -- Cursor to fetch the Service Request Contact Points
    CURSOR c_sr_contact_points IS
      SELECT sub_last_name last_name
           , sub_first_name first_name
           , sub_title title
           , contact_point_id
           , party_id
           , contact_type
        FROM cs_sr_contact_points_v
       WHERE incident_id  = p_incident_id
         AND primary_flag = 'Y';

    -- Cursor to fetch the Phone Number of Contacts
    CURSOR  c_contact_phone IS
      SELECT cp.contact_point_type
           ,    DECODE(cp.phone_country_code, '', '', NULL, '', cp.phone_country_code || '-' )
             || DECODE(cp.phone_area_code, '', '', NULL, '', cp.phone_area_code || '-')
             || cp.phone_number phone
           , cp.phone_extension
           , cp.email_address
        FROM hz_contact_points cp
           , ar_lookups ar
       WHERE cp.contact_point_id  = l_contact_point_id
         AND cp.contact_point_type IN ('EMAIL', 'PHONE')
         AND cp.phone_line_type   = ar.lookup_code (+)
         AND ar.lookup_type(+)    = 'PHONE_LINE_TYPE';

    -- Cursor to fetch information regarding HRMS Employees
    -- We require joining again with cs_hz_sr_contact_points so that the OUTER
    -- Join on Phone ID works properly. If its a constant, it expects a NOT NULL
    -- Value.
    CURSOR c_emp_info IS
      SELECT p.last_name
           , p.first_name
           , p.title
           , pp.phone_number
           , p.email_address
        FROM cs_hz_sr_contact_points sr_cp
           , per_all_people_f p
           , per_phones pp
           , hr_lookups hrl
       WHERE sr_cp.incident_id  = p_incident_id
         AND sr_cp.primary_flag = 'Y'
         AND p.person_id        = sr_cp.party_id
         AND pp.phone_id(+)     = sr_cp.contact_point_id
         AND pp.parent_table(+) = 'PER_ALL_PEOPLE_F'
         AND hrl.lookup_code(+) = pp.phone_type
         AND hrl.lookup_type(+) = 'PHONE_TYPE'
       ORDER BY p.effective_end_date desc;


  BEGIN

    IF l_contact_source = 'TASK' THEN
      -- Fetch the Contact Points from the Task Data Model
      OPEN c_task_contact_points;
      FETCH c_task_contact_points INTO x_last_name, x_first_name, x_title, l_contact_point_id;
      CLOSE c_task_contact_points;

      FOR v IN c_contact_phone LOOP
        IF v.contact_point_type = 'EMAIL' THEN
          x_email_address := v.email_address;
        ELSE
          x_phone     := v.phone;
          x_phone_ext := v.phone_extension;
        END IF;
      END LOOP;
    ELSE
      -- Fetch the Contact Points from the SR Data Model
      OPEN c_sr_contact_points;
      FETCH c_sr_contact_points INTO x_last_name, x_first_name, x_title, l_contact_point_id, l_party_id, l_contact_type;
      CLOSE c_sr_contact_points;

      IF l_contact_type = 'EMPLOYEE' THEN
        OPEN c_emp_info;
        FETCH c_emp_info INTO x_last_name, x_first_name, x_title, x_phone, x_email_address;
        CLOSE c_emp_info;
      ELSE
        FOR v IN c_contact_phone LOOP
          IF v.contact_point_type = 'EMAIL' THEN
            x_email_address := v.email_address;
          ELSE
            x_phone     := v.phone;
            x_phone_ext := v.phone_extension;
          END IF;
        END LOOP;
      END IF;
    END IF;

  END get_contact_details;

  FUNCTION get_contact_details(p_incident_id NUMBER, p_task_id NUMBER)
    RETURN VARCHAR2 IS
    l_title             VARCHAR2(60);
    l_first_name        VARCHAR2(150);
    l_last_name         VARCHAR2(150);
    l_phone             VARCHAR2(50);
    l_extension         VARCHAR2(20);
    l_email_address     VARCHAR2(2000);

    l_name              VARCHAR2(500);
  BEGIN
    get_contact_details(
      p_incident_id   => p_incident_id
    , p_task_id       => p_task_id
    , x_last_name     => l_last_name
    , x_first_name    => l_first_name
    , x_title         => l_title
    , x_phone         => l_phone
    , x_phone_ext     => l_extension
    , x_email_address => l_email_address
    );

    l_name := '';
    IF l_title IS NOT NULL THEN
      l_name := l_title || ' ';
    END IF;
    IF l_first_name IS NOT NULL THEN
      l_name := l_name || l_first_name || ' ';
    END IF;
    IF l_last_name IS NOT NULL THEN
      l_name := l_name || l_last_name;
    END IF;

    RETURN l_name || '@@' || l_phone || '@@' || l_extension || '@@' || l_email_address;
  END get_contact_details;

  procedure  create_personal_task(
		      p_api_version                   in number
	      , p_init_msg_list                 in varchar2
        , p_commit                        in varchar2
        , p_task_name                     in varchar2
	      , p_description                   in varchar2
	      , p_task_type_name                in varchar2
	      , p_task_type_id                  in number
	      , p_task_status_name               in varchar2
	      , p_task_status_id              in number
	      , p_task_priority_name        in varchar2
	      , p_task_priority_id            in number
	      , p_owner_id                   in number
	      , p_owner_type_code           in varchar2
	      , p_address_id                  in number
	      , p_customer_id                 in number
	      , p_planned_start_date         in date
	      , p_planned_end_date           in date
	      , p_scheduled_start_date      in date
	      , p_scheduled_end_date         in date
	      , p_source_object_type_code    in varchar2
	      , p_planned_effort             in number
	      , p_planned_effort_uom        in varchar2
	      , p_bound_mode_code            in varchar2
	      , p_soft_bound_flag            in varchar2
	      , p_task_assign_tbl           jtf_tasks_pub.task_assign_tbl
	      , p_type                     in varchar2
        , p_trip                     in number
	      , x_return_status             out nocopy varchar2
	      , x_msg_count                 out nocopy number
	      , x_msg_data                  out nocopy varchar2
	      , x_task_id                    out nocopy number
	      )
  is
  l_api_name      CONSTANT VARCHAR2(30)       := 'CREATE_PERSONAL_TASK';
  l_api_version   CONSTANT NUMBER             := 1.0;

   l_location number;
   l_obj number;
   x_object_version_number number;
   l_task_id number;
   l_task_assignment_id number;
   l_obj_number number;
   l_task_ovn number;
   l_ts number;
   l_addr number;

  begin
     SAVEPOINT csf_create_per_task;

      x_return_status := fnd_api.g_ret_sts_success;

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;


    jtf_tasks_pub.create_task(
	      	p_api_version                => p_api_version
	      , p_init_msg_list              => p_init_msg_list
        , p_commit                     => p_commit
	      , p_task_name                  => p_task_name
	      , p_description                => p_description
	      , p_task_type_name             => p_task_type_name
	      , p_task_type_id               => p_task_type_id
	      , p_task_status_name           => p_task_status_name
	      , p_task_status_id             => p_task_status_id
	      , p_task_priority_name         => p_task_priority_name
	      , p_task_priority_id           => p_task_priority_id
	      , p_owner_id                   => p_owner_id
	      , p_owner_type_code            => p_owner_type_code
	      , p_address_id                 => p_address_id
	      , p_customer_id                => p_customer_id
        , p_planned_start_date         => p_planned_start_date
	      , p_planned_end_date           => p_planned_end_date
	      , p_scheduled_start_date       => p_scheduled_start_date
	      , p_scheduled_end_date         => p_scheduled_end_date
	      , p_source_object_type_code    => p_source_object_type_code
	      , p_planned_effort             => p_planned_effort
	      , p_planned_effort_uom         => p_planned_effort_uom
	      , p_bound_mode_code            => p_bound_mode_code
	      , p_soft_bound_flag            => p_soft_bound_flag
	      , p_task_assign_tbl            => p_task_assign_tbl
	      , x_return_status              => x_return_status
	      , x_msg_count                  => x_msg_count
	      , x_msg_data                   => x_msg_data
	      , x_task_id                    => x_task_id
	      );
        IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        l_task_id := x_task_id;



      IF fnd_api.to_boolean (p_commit) THEN
        COMMIT WORK;
      END IF;

  Exception
     WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_create_per_task;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_create_per_task;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_create_per_task;
  end;

  procedure update_personal_task(
	      	p_api_version               in number
	      , p_init_msg_list        in varchar2
        , p_commit             in varchar2
        , p_task_id                    in NUMBER
        , p_task_name                  in varchar2
        , x_version     in out nocopy number
	      , p_description                in VARCHAR2
	      , p_task_type_id             in number
	      , p_task_status_id           in number
	      , p_task_priority_id    in number
	      , p_owner_id                   in number
	      , p_owner_type_code            in varchar2
	      , p_address_id                 in number
	      , p_customer_id               in number
	      , p_planned_start_date         in date
	      , p_planned_end_date          in date
	      , p_scheduled_start_date       in date
	      , p_scheduled_end_date         in date
	      , p_source_object_type_code   in varchar2
	      , p_planned_effort             in number
	      , p_planned_effort_uom         in varchar2
	      , p_bound_mode_code            in varchar2
	      , p_soft_bound_flag           in varchar2
	      , p_type                       in varchar2
        , p_trip                  in number
	      , x_return_status              out nocopy varchar2
	      , x_msg_count                  out nocopy number
	      , x_msg_data                   out nocopy varchar2
        )
   is
    l_api_name      CONSTANT VARCHAR2(30)       := 'UPDATE_PERSONAL_TASK';
    l_api_version   CONSTANT NUMBER             := 1.0;

   cursor c_obj(p_task number)
  is
   select object_version_number
   from jtf_tasks_b
   where task_id =p_task;

   cursor c_task_ass(p_task_id number)
   is
    select jta.task_assignment_id
    from jtf_task_assignments jta,jtf_tasks_b jt
    where jt.task_id=p_task_id
    and jta.task_id=jt.task_id
    and jt.source_object_type_code = 'TASK'
    and jt.task_type_id not in (20,21);

    l_location number;
   l_obj number;
   x_object_version_number number;
   l_obj_task number;
   l_ts number;
   l_task_assignment_id number;


   begin

     SAVEPOINT csf_update_per_task;

      x_return_status := fnd_api.g_ret_sts_success;

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    open c_obj(p_task_id);
    fetch c_obj into l_obj;
    close c_obj;

       csf_tasks_pub.update_task(
		      p_api_version                => p_api_version
	      , p_init_msg_list              => p_init_msg_list
        , p_commit                     => p_commit
        , p_task_id                    => p_task_id
        , p_object_version_number      => x_version
	      , p_task_name                  => p_task_name
	      , p_description                => p_description
	      , p_task_type_id               => p_task_type_id
	      , p_task_status_id             => p_task_status_id
	      , p_task_priority_id           => p_task_priority_id
	      , p_owner_id                   => p_owner_id
	      , p_owner_type_code            => p_owner_type_code
	      , p_address_id                 => p_address_id
	      , p_customer_id                => p_customer_id
        , p_planned_start_date         => p_planned_start_date
	      , p_planned_end_date           => p_planned_end_date
	      , p_scheduled_start_date       => p_scheduled_start_date
	      , p_scheduled_end_date         => p_scheduled_end_date
	      , p_source_object_type_code    => p_source_object_type_code
	      , p_planned_effort             => p_planned_effort
	      , p_planned_effort_uom         => p_planned_effort_uom
	      , p_bound_mode_code            => p_bound_mode_code
	      , p_soft_bound_flag            => p_soft_bound_flag
	      , x_return_status              => x_return_status
	      , x_msg_count                  => x_msg_count
	      , x_msg_data                   => x_msg_data
	      );

        IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_commit) THEN
         COMMIT WORK;
        END IF;

  Exception
     WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csf_update_per_task;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csf_update_per_task;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csf_update_per_task;
  end;
  PROCEDURE set_desc_field_attr(
	  p_inst_flex_fld_tbl IN  csf_tasks_pub.Inst_flexfld_rec_type
   ,p_return_status     OUT NOCOPY      VARCHAR2
   ,p_msg_count         OUT NOCOPY      NUMBER
   ,p_msg_data          OUT NOCOPY      VARCHAR2
   ,p_obj_ver_no        OUT NOCOPY      NUMBER

  )
  IS
	 l_api_name   						        CONSTANT VARCHAR2 (30) := 'SET_DESC_FIELD_ATTR';
	 l_upd_instance_rec					      csi_datastructures_pub.instance_rec;
	 l_out_id_tbl						          csi_datastructures_pub.id_tbl;
	 l_out_party_tbl						      csi_datastructures_pub.party_tbl;
	 l_transaction_rec                csi_datastructures_pub.transaction_rec;
	 l_out_party_account_tbl				  csi_datastructures_pub.party_account_tbl;
	 l_out_instance_asset_tbl			    csi_datastructures_pub.instance_asset_tbl;
	 l_out_pricing_attribs_tbl			  csi_datastructures_pub.pricing_attribs_tbl;
	 l_out_organization_units_tbl		  csi_datastructures_pub.organization_units_tbl;
   l_out_extend_attrib_values_tbl		csi_datastructures_pub.extend_attrib_values_tbl;
   CURSOR c_instance_obj (p_instance_id number)
	 IS
	 SELECT object_version_number
	 FROM   CSI_ITEM_INSTANCES
	 WHERE instance_id=p_instance_id;



   --Below Variables are used for updating hz_parties flex field
   l_profile_id                     number;
   l_org_update_rec                 HZ_PARTY_V2PUB.organization_rec_type;
   l_party_update_rec               HZ_PARTY_V2PUB.party_rec_type;
   l_party_object_version_number    NUMBER;

  BEGIN
    SAVEPOINT set_desc_field_attr;

  	IF p_inst_flex_fld_tbl.l_flex_fl_table = 'CSI_ITEM_INSTANCES'
  	THEN
         l_upd_instance_rec                                 :=  csi_inv_trxs_pkg.init_instance_update_rec;
         l_upd_instance_rec.INSTANCE_ID                     :=  p_inst_flex_fld_tbl.l_instance_id;
         l_upd_instance_rec.INSTANCE_NUMBER                 :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.EXTERNAL_REFERENCE              :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.INVENTORY_ITEM_ID               :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.VLD_ORGANIZATION_ID             :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.INVENTORY_REVISION              :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.INV_MASTER_ORGANIZATION_ID      :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.SERIAL_NUMBER                   :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.MFG_SERIAL_NUMBER_FLAG          :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.LOT_NUMBER                      :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.QUANTITY                        :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.UNIT_OF_MEASURE                 :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.ACCOUNTING_CLASS_CODE           :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.INSTANCE_CONDITION_ID           :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.INSTANCE_STATUS_ID              :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.CUSTOMER_VIEW_FLAG              :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.MERCHANT_VIEW_FLAG              :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.SELLABLE_FLAG                   :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.SYSTEM_ID                       :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.INSTANCE_TYPE_CODE              :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.ACTIVE_START_DATE               :=  FND_API.G_MISS_DATE;
         l_upd_instance_rec.ACTIVE_END_DATE                 :=  FND_API.G_MISS_DATE;
         l_upd_instance_rec.LOCATION_TYPE_CODE              :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.LOCATION_ID                     :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.INV_ORGANIZATION_ID             :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.INV_SUBINVENTORY_NAME           :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.INV_LOCATOR_ID                  :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.PA_PROJECT_ID                   :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.PA_PROJECT_TASK_ID              :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.IN_TRANSIT_ORDER_LINE_ID        :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.WIP_JOB_ID                      :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.PO_ORDER_LINE_ID                :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.LAST_OE_ORDER_LINE_ID           :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.LAST_OE_RMA_LINE_ID             :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.LAST_PO_PO_LINE_ID              :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.LAST_OE_PO_NUMBER               :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.LAST_WIP_JOB_ID                 :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.LAST_PA_PROJECT_ID              :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.LAST_PA_TASK_ID                 :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.LAST_OE_AGREEMENT_ID            :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.INSTALL_DATE                    :=  FND_API.G_MISS_DATE;
         l_upd_instance_rec.MANUALLY_CREATED_FLAG           :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.RETURN_BY_DATE                  :=  FND_API.G_MISS_DATE;
         l_upd_instance_rec.ACTUAL_RETURN_DATE              :=  FND_API.G_MISS_DATE;
         l_upd_instance_rec.CREATION_COMPLETE_FLAG          :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.COMPLETENESS_FLAG               :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.VERSION_LABEL                   :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.VERSION_LABEL_DESCRIPTION       :=  FND_API.G_MISS_CHAR;
          l_upd_instance_rec.OBJECT_VERSION_NUMBER          :=  p_inst_flex_fld_tbl.l_obj_ver_number;
         l_upd_instance_rec.LAST_TXN_LINE_DETAIL_ID         :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.INSTALL_LOCATION_TYPE_CODE      :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.INSTALL_LOCATION_ID             :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.INSTANCE_USAGE_CODE             :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.CHECK_FOR_INSTANCE_EXPIRY       :=  FND_API.G_FALSE;
         l_upd_instance_rec.PROCESSED_FLAG                  :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.CALL_CONTRACTS                  :=  FND_API.G_FALSE;
         l_upd_instance_rec.INTERFACE_ID                    :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.GRP_CALL_CONTRACTS              :=  FND_API.G_FALSE;
         l_upd_instance_rec.CONFIG_INST_HDR_ID              :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.CONFIG_INST_REV_NUM             :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.CONFIG_INST_ITEM_ID             :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.CONFIG_VALID_STATUS             :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.INSTANCE_DESCRIPTION            :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.CALL_BATCH_VALIDATION           :=  FND_API.G_FALSE;
         l_upd_instance_rec.REQUEST_ID                      :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.PROGRAM_APPLICATION_ID          :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.PROGRAM_ID                      :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.PROGRAM_UPDATE_DATE             :=  FND_API.G_MISS_DATE;
         l_upd_instance_rec.CASCADE_OWNERSHIP_FLAG          :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.NETWORK_ASSET_FLAG              :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.MAINTAINABLE_FLAG               :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.PN_LOCATION_ID                  :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.ASSET_CRITICALITY_CODE          :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.CATEGORY_ID                     :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.EQUIPMENT_GEN_OBJECT_ID         :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.INSTANTIATION_FLAG              :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.LINEAR_LOCATION_ID              :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.OPERATIONAL_LOG_FLAG            :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.CHECKIN_STATUS                  :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.SUPPLIER_WARRANTY_EXP_DATE      :=  FND_API.G_MISS_DATE;
         l_upd_instance_rec.CONTEXT                         :=  p_inst_flex_fld_tbl.l_context 	;
         l_upd_instance_rec.ATTRIBUTE1                      :=  p_inst_flex_fld_tbl.ATTRIBUTE1 ;
         l_upd_instance_rec.ATTRIBUTE2                      :=  p_inst_flex_fld_tbl.ATTRIBUTE2 ;
         l_upd_instance_rec.ATTRIBUTE3                      :=  p_inst_flex_fld_tbl.ATTRIBUTE3 ;
         l_upd_instance_rec.ATTRIBUTE4                      :=  p_inst_flex_fld_tbl.ATTRIBUTE4 ;
         l_upd_instance_rec.ATTRIBUTE5                      :=  p_inst_flex_fld_tbl.ATTRIBUTE5 ;
         l_upd_instance_rec.ATTRIBUTE6                      :=  p_inst_flex_fld_tbl.ATTRIBUTE6 ;
         l_upd_instance_rec.ATTRIBUTE7                      :=  p_inst_flex_fld_tbl.ATTRIBUTE7 ;
         l_upd_instance_rec.ATTRIBUTE8                      :=  p_inst_flex_fld_tbl.ATTRIBUTE8 ;
         l_upd_instance_rec.ATTRIBUTE9                      :=  p_inst_flex_fld_tbl.ATTRIBUTE9 ;
         l_upd_instance_rec.ATTRIBUTE10                     :=  p_inst_flex_fld_tbl.ATTRIBUTE10;
         l_upd_instance_rec.ATTRIBUTE11                     :=  p_inst_flex_fld_tbl.ATTRIBUTE11;
         l_upd_instance_rec.ATTRIBUTE12                     :=  p_inst_flex_fld_tbl.ATTRIBUTE12;
         l_upd_instance_rec.ATTRIBUTE13                     :=  p_inst_flex_fld_tbl.ATTRIBUTE13;
         l_upd_instance_rec.ATTRIBUTE14                     :=  p_inst_flex_fld_tbl.ATTRIBUTE14;
         l_upd_instance_rec.ATTRIBUTE15                     :=  p_inst_flex_fld_tbl.ATTRIBUTE15;
         l_upd_instance_rec.ATTRIBUTE16                     :=  p_inst_flex_fld_tbl.ATTRIBUTE16;
         l_upd_instance_rec.ATTRIBUTE17                     :=  p_inst_flex_fld_tbl.ATTRIBUTE17;
         l_upd_instance_rec.ATTRIBUTE18                     :=  p_inst_flex_fld_tbl.ATTRIBUTE18;
         l_upd_instance_rec.ATTRIBUTE19                     :=  p_inst_flex_fld_tbl.ATTRIBUTE19;
         l_upd_instance_rec.ATTRIBUTE20                     :=  p_inst_flex_fld_tbl.ATTRIBUTE20;
         l_upd_instance_rec.ATTRIBUTE21                     :=  p_inst_flex_fld_tbl.ATTRIBUTE21;
         l_upd_instance_rec.ATTRIBUTE22                     :=  p_inst_flex_fld_tbl.ATTRIBUTE22;
         l_upd_instance_rec.ATTRIBUTE23                     :=  p_inst_flex_fld_tbl.ATTRIBUTE23;
         l_upd_instance_rec.ATTRIBUTE24                     :=  p_inst_flex_fld_tbl.ATTRIBUTE24;
         l_upd_instance_rec.ATTRIBUTE25                     :=  p_inst_flex_fld_tbl.ATTRIBUTE25;
         l_upd_instance_rec.ATTRIBUTE26                     :=  p_inst_flex_fld_tbl.ATTRIBUTE26;
         l_upd_instance_rec.ATTRIBUTE27                     :=  p_inst_flex_fld_tbl.ATTRIBUTE27;
         l_upd_instance_rec.ATTRIBUTE28                     :=  p_inst_flex_fld_tbl.ATTRIBUTE28;
         l_upd_instance_rec.ATTRIBUTE29                     :=  p_inst_flex_fld_tbl.ATTRIBUTE29;
         l_upd_instance_rec.ATTRIBUTE30                     :=  p_inst_flex_fld_tbl.ATTRIBUTE30;
         l_upd_instance_rec.PURCHASE_UNIT_PRICE             :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.PURCHASE_CURRENCY_CODE          :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.PAYABLES_UNIT_PRICE             :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.PAYABLES_CURRENCY_CODE          :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.SALES_UNIT_PRICE                :=  FND_API.G_MISS_NUM;
         l_upd_instance_rec.SALES_CURRENCY_CODE             :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.OPERATIONAL_STATUS_CODE         :=  FND_API.G_MISS_CHAR;
         l_upd_instance_rec.DEPARTMENT_ID                   :=  fnd_api.g_miss_num;
         l_upd_instance_rec.WIP_ACCOUNTING_CLASS            :=  fnd_api.g_miss_char;
         l_upd_instance_rec.AREA_ID                         :=  fnd_api.g_miss_num;
         l_upd_instance_rec.OWNER_PARTY_ID                  :=  fnd_api.g_miss_num;
         l_upd_instance_rec.SOURCE_CODE                     :=  FND_API.G_MISS_CHAR;

    		 l_transaction_rec.transaction_id              		:= FND_API.G_MISS_NUM ;
    		 l_transaction_rec.transaction_date            		:= sysdate;
    		 l_transaction_rec.SOURCE_TRANSACTION_DATE	   		:= sysdate;
    		 l_transaction_rec.transaction_type_id         		:= 55; -- this is transaction id for FIELD SERVICE IN csi_transactions
    		 l_transaction_rec.object_version_number       		:= 1;

    		 csi_item_instance_pub.update_item_instance
    		(
    		     p_api_version           => 1.0
    		    ,p_commit                => fnd_api.g_false
    		    ,p_init_msg_list         => fnd_api.g_true
    		    ,p_validation_level      => fnd_api.G_VALID_LEVEL_NONE
    		    ,p_instance_rec          => l_upd_instance_rec
    		    ,p_ext_attrib_values_tbl => l_out_extend_attrib_values_tbl
    		    ,p_party_tbl             => l_out_party_tbl
    		    ,p_account_tbl           => l_out_party_account_tbl
    		    ,p_pricing_attrib_tbl    => l_out_pricing_attribs_tbl
    		    ,p_org_assignments_tbl   => l_out_organization_units_tbl
    		    ,p_asset_assignment_tbl  => l_out_instance_asset_tbl
    		    ,p_txn_rec               => l_transaction_rec
    		    ,x_instance_id_lst       => l_out_id_tbl
    		    ,x_return_status         => p_return_status
    		    ,x_msg_count             => p_msg_count
    		    ,x_msg_data              => p_msg_data
        );
        IF  p_return_status = fnd_api.g_ret_sts_success
        THEN
            OPEN c_instance_obj(l_upd_instance_rec.INSTANCE_ID);
            FETCH c_instance_obj INTO p_obj_ver_no;
            CLOSE c_instance_obj;
        END IF;

  ELSIF  p_inst_flex_fld_tbl.l_flex_fl_table = 'HZ_PARTIES'
	THEN
         l_party_update_rec.party_id                      := p_inst_flex_fld_tbl.l_party_id ;
         l_org_update_rec.party_rec                       := l_party_update_rec;
         l_org_update_rec.party_rec.Attribute_Category    := NVL( p_inst_flex_fld_tbl.l_att_catogary , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute1            := NVL( p_inst_flex_fld_tbl.Attribute1 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute2            := NVL( p_inst_flex_fld_tbl.Attribute2 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute3            := NVL( p_inst_flex_fld_tbl.Attribute3 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute4            := NVL( p_inst_flex_fld_tbl.Attribute4 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute5            := NVL( p_inst_flex_fld_tbl.Attribute5 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute6            := NVL( p_inst_flex_fld_tbl.Attribute6 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute7            := NVL( p_inst_flex_fld_tbl.Attribute7 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute8            := NVL( p_inst_flex_fld_tbl.Attribute8 , FND_API.G_MISS_CHAR);

         l_org_update_rec.party_rec.Attribute9            := NVL( p_inst_flex_fld_tbl.Attribute9 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute10           := NVL( p_inst_flex_fld_tbl.Attribute10 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute11           := NVL( p_inst_flex_fld_tbl.Attribute11 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute12           := NVL( p_inst_flex_fld_tbl.Attribute12 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute13           := NVL( p_inst_flex_fld_tbl.Attribute13 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute14           := NVL( p_inst_flex_fld_tbl.Attribute14 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute15           := NVL( p_inst_flex_fld_tbl.Attribute15 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute16           := NVL( p_inst_flex_fld_tbl.Attribute16 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute17           := NVL( p_inst_flex_fld_tbl.Attribute17 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute18           := NVL( p_inst_flex_fld_tbl.Attribute18 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute19           := NVL( p_inst_flex_fld_tbl.Attribute19 , FND_API.G_MISS_CHAR);

         l_org_update_rec.party_rec.Attribute20           := NVL( p_inst_flex_fld_tbl.Attribute20 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute21           := NVL( p_inst_flex_fld_tbl.Attribute21 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute22           := NVL( p_inst_flex_fld_tbl.Attribute22 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute23           := NVL( p_inst_flex_fld_tbl.Attribute23 , FND_API.G_MISS_CHAR);
         l_org_update_rec.party_rec.Attribute24           := NVL( p_inst_flex_fld_tbl.Attribute24 , FND_API.G_MISS_CHAR);
         l_party_object_version_number                    := p_inst_flex_fld_tbl.l_obj_ver_number;

         HZ_PARTY_V2PUB.update_Organization( p_init_msg_list     => fnd_api.g_true,
                                 x_return_status                 => p_return_status,
                                 x_msg_count                     => p_msg_count,
                                 x_msg_data                      => p_msg_data,
                                 x_profile_id                    => l_profile_id,
                                 p_organization_rec              => l_org_update_rec,
                                 p_party_object_version_number   => l_party_object_version_number
                               );

        IF  p_return_status = fnd_api.g_ret_sts_success
        THEN
            p_obj_ver_no := l_party_object_version_number;
        END IF;

	END IF;

	IF p_return_status = fnd_api.g_ret_sts_error THEN
		RAISE fnd_api.g_exc_error;
	ELSIF p_return_status = fnd_api.g_ret_sts_unexp_error THEN
		RAISE fnd_api.g_exc_unexpected_error;
	END IF;
 EXCEPTION
    WHEN fnd_api.g_exc_error THEN
	  ROLLBACK TO set_desc_field_attr;
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
	  ROLLBACK TO set_desc_field_attr;
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);

    WHEN OTHERS THEN
	  ROLLBACK TO set_desc_field_attr;
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
	  fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);

  END set_desc_field_attr;


  PROCEDURE update_task_attr (
    p_api_version             IN              NUMBER
  , p_init_msg_list           IN              VARCHAR2
  , p_commit                  IN              VARCHAR2
  , x_return_status           OUT NOCOPY      VARCHAR2
  , x_msg_count               OUT NOCOPY      NUMBER
  , x_msg_data                OUT NOCOPY      VARCHAR2
  , p_task_id                 IN              NUMBER
  , p_object_version_number   IN OUT NOCOPY   NUMBER
  , p_scheduled_start_date    IN              DATE   DEFAULT NULL
  , p_scheduled_end_date      IN              DATE   DEFAULT NULL
  , p_planned_start_date      IN              DATE   DEFAULT NULL
  , p_planned_end_date        IN              DATE   DEFAULT NULL
  , p_task_priority_id        IN              NUMBER DEFAULT NULL
  , p_planned_effort		      IN	     	      NUMBER 	DEFAULT NULL
  , p_planned_effort_uom	    IN	    	      VARCHAR2  DEFAULT NULL
  , ATTRIBUTE1 		   		      IN    		      VARCHAR2 DEFAULT NULL
  , ATTRIBUTE2 		  		      IN    		      VARCHAR2 DEFAULT NULL
  , ATTRIBUTE3                IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE4                IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE5 		            IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE6                IN	            VARCHAR2 DEFAULT NULL
  , ATTRIBUTE7                IN	            VARCHAR2 DEFAULT NULL
  , ATTRIBUTE8 		            IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE9                IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE10               IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE11		            IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE12               IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE13               IN	            VARCHAR2 DEFAULT NULL
  , ATTRIBUTE14		            IN	            VARCHAR2 DEFAULT NULL
  , ATTRIBUTE15               IN              VARCHAR2 DEFAULT NULL
  , ATTRIBUTE_CATEGORY		    IN    		      VARCHAR2 DEFAULT NULL
  ) IS
    l_api_name      CONSTANT VARCHAR2 (30)       := 'UPDATE_TASK_STATUS';
    l_api_version   CONSTANT NUMBER              := 1.0;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT update_task_attr;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Update the Task with the new Task Status Information
    jtf_tasks_pub.update_task (
      p_api_version               => 1.0
    , x_return_status             => x_return_status
    , x_msg_count                 => x_msg_count
    , x_msg_data                  => x_msg_data
    , p_task_id                   => p_task_id
    , p_object_version_number     => p_object_version_number
    , p_planned_start_date        => p_planned_start_date
    , p_planned_end_date          => p_planned_end_date
    , p_scheduled_start_date      => p_scheduled_start_date
    , p_scheduled_end_date        => p_scheduled_end_date
  	, p_task_priority_id          => p_task_priority_id
  	, p_planned_effort            => p_planned_effort
  	, p_planned_effort_uom        => p_planned_effort_uom
    , P_ATTRIBUTE1				        => ATTRIBUTE1
    , P_ATTRIBUTE2				        => ATTRIBUTE2
    , P_ATTRIBUTE3				        => ATTRIBUTE3
    , P_ATTRIBUTE4				        => ATTRIBUTE4
    , P_ATTRIBUTE5				        => ATTRIBUTE5
    , P_ATTRIBUTE6				        => ATTRIBUTE6
    , P_ATTRIBUTE7 			 	        => ATTRIBUTE7
    , P_ATTRIBUTE8				        => ATTRIBUTE8
    , P_ATTRIBUTE9				        => ATTRIBUTE9
  	, P_ATTRIBUTE10			  	      => ATTRIBUTE10
  	, P_ATTRIBUTE11			  	      => ATTRIBUTE11
  	, P_ATTRIBUTE12			          => ATTRIBUTE12
  	, P_ATTRIBUTE13			          => ATTRIBUTE13
  	, P_ATTRIBUTE14			          => ATTRIBUTE14
  	, P_ATTRIBUTE15			          => ATTRIBUTE15
  	, P_ATTRIBUTE_CATEGORY		    => ATTRIBUTE_CATEGORY
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Standard check of p_commit
    IF fnd_api.to_boolean (p_commit) THEN
	  null;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_task_attr;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_attr;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO update_task_attr;
  END update_task_attr;




  PROCEDURE get_site_details_for_task
  ( p_task_id       IN NUMBER
  , p_party_id 		IN NUMBER
  , p_party_site_id IN NUMBER DEFAULT NULL
  , p_location_id   IN NUMBER DEFAULT NULL
  , p_party_site_no  OUT NOCOPY VARCHAR
  , p_party_site_nm  OUT NOCOPY VARCHAR
  , p_party_site_add OUT NOCOPY VARCHAR
  , p_party_site_ph  OUT NOCOPY VARCHAR
  )
  IS
  CURSOR c_get_site_details(p_location_id number,p_party_id_no number)
  IS
  SELECT s.party_site_number,
	   s.party_site_name,
       s.addressee,
	   csf_tasks_pub.return_primary_phone(s.party_site_id) phone_no
    FROM   hz_locations l,
           hz_party_sites s,
           hz_parties p
    WHERE  s.location_id = p_location_id
    AND    l.location_id = s.location_id
    AND    s.party_id = p.party_id
	AND    p.party_id =p_party_id_no;
	l_location_id NUMBER;
  BEGIN
    l_location_id := csf_tasks_pub.get_task_location_id(p_task_id, p_party_site_id, p_location_id);
    OPEN c_get_site_details(l_location_id,p_party_id);
	FETCH c_get_site_details INTO p_party_site_no,p_party_site_nm,p_party_site_add,p_party_site_ph;
  END;


  PROCEDURE CREATE_ACC_HRS( p_task_id                     IN NUMBER
							            , x_return_status              OUT NOCOPY VARCHAR2
							            , x_msg_count                  OUT NOCOPY NUMBER
							            , x_msg_data                   OUT NOCOPY VARCHAR2)
  IS

   --The below cursor +variables are added for access hours 8869998

	l_acc_hr_id           NUMBER;
	l_acchr_loc_id        NUMBER;
	l_acchr_ct_site_id    NUMBER;
	l_acchr_ct_id         NUMBER;
	l_acchrs_found        BOOLEAN;
	l_address_id_to_pass  NUMBER;
	l_location_id_to_pass NUMBER;
	conf_object_version_number NUMBER;
	x_object_version_number    NUMBER;
  l_auto_acc_hrs        VARCHAR2(1);

	CURSOR c_acchrs_location_csr IS
	SELECT * from csf_map_access_hours_vl where
	customer_location_id = l_acchr_loc_id;

	CURSOR c_acchrs_ctsite_csr IS
		SELECT * from csf_map_access_hours_vl where
		customer_id = l_acchr_ct_id and
		customer_site_id = l_acchr_ct_site_id;

	CURSOR c_acchrs_ct_csr IS
		SELECT * from csf_map_access_hours_vl where
		customer_id = l_acchr_ct_id
    and customer_site_id is NULL
    and customer_location_id is NULL;
	l_acchrs_setups_rec   c_acchrs_location_csr%ROWTYPE;

	CURSOR c_task_details IS
	SELECT t.task_number,
	       t.location_id,
		   t.address_id,
		   t.customer_id,
		   NVL(t.location_id, ps.location_id) loc_id
	from jtf_tasks_b t, hz_party_sites ps
	where  task_id=p_task_id
	AND ps.party_site_id(+) = t.address_id;
	l_task_dtls c_task_details%rowtype;

--end of cursor added access hours validation

  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
	l_auto_acc_hrs := fnd_profile.value('CSF_AUTO_POPULATE_ACCESS_HRS');
	/*
	1) Check if access hours setups are done for the location
	2) Else, check if access hours setups are done for the ct + ct site combination
	3) Else, check if access hours setups are done for the ct
	4) Create access hours for the task, if acc hrs setups are found for the just created task
	*/
  IF l_auto_acc_hrs ='Y'
  THEN
      	OPEN c_task_details;
      	FETCH c_task_details into l_task_dtls;
        CLOSE c_task_details;
      	l_acchr_ct_id := l_task_dtls.customer_id;

      	IF (l_task_dtls.location_id IS NOT NULL) THEN
      		l_acchr_loc_id := l_task_dtls.location_id;
      		OPEN c_acchrs_location_csr;
      		FETCH c_acchrs_location_csr INTO l_acchrs_setups_rec;
      		IF (c_acchrs_location_csr%NOTFOUND) THEN
      			OPEN c_acchrs_ct_csr;
      			FETCH c_acchrs_ct_csr INTO l_acchrs_setups_rec;
      			IF (c_acchrs_ct_csr%NOTFOUND) THEN
      				l_acchrs_found := false;
      			ELSE
      				l_acchrs_found := true;
      			END IF;
      			close c_acchrs_ct_csr;
      		ELSE
      			l_acchrs_found := true;
      		END IF;
      		close c_acchrs_location_csr;
      	ELSIF(l_task_dtls.ADDRESS_ID IS NOT NULL) THEN
      		l_acchr_ct_site_id := l_task_dtls.address_id;
      		OPEN c_acchrs_ctsite_csr;
      		FETCH c_acchrs_ctsite_csr INTO l_acchrs_setups_rec;
      		IF (c_acchrs_ctsite_csr%NOTFOUND) THEN
      			OPEN c_acchrs_ct_csr;
      			FETCH c_acchrs_ct_csr INTO l_acchrs_setups_rec;
      			IF (c_acchrs_ct_csr%NOTFOUND) THEN
      				l_acchrs_found := false;
      			ELSE
      				l_acchrs_found := true;
      			END IF;
      			close c_acchrs_ct_csr;
      		ELSE
      			l_acchrs_found := true;
      		END IF;
      		close c_acchrs_ctsite_csr;
      	END IF;

      	IF (l_acchrs_found = true)
      	THEN

      	      CSF_ACCESS_HOURS_PUB.CREATE_ACCESS_HOURS(
      		      x_ACCESS_HOUR_ID => l_acc_hr_id,
      		      p_API_VERSION => 1.0 ,
      		      p_init_msg_list => NULL,
      	          p_TASK_ID => p_task_id,
      	          p_ACCESS_HOUR_REQD => l_acchrs_setups_rec.accesshour_required,
      	          p_AFTER_HOURS_FLAG => l_acchrs_setups_rec.after_hours_flag,
      	          p_MONDAY_FIRST_START => l_acchrs_setups_rec.MONDAY_FIRST_START,
      	          p_MONDAY_FIRST_END => l_acchrs_setups_rec.MONDAY_FIRST_END,
      	          p_MONDAY_SECOND_START => l_acchrs_setups_rec.MONDAY_SECOND_START,
      	          p_MONDAY_SECOND_END => l_acchrs_setups_rec.MONDAY_SECOND_END,
      	          p_TUESDAY_FIRST_START => l_acchrs_setups_rec.TUESDAY_FIRST_START,
      	          p_TUESDAY_FIRST_END => l_acchrs_setups_rec.TUESDAY_FIRST_END,
      	          p_TUESDAY_SECOND_START => l_acchrs_setups_rec.TUESDAY_SECOND_START,
      	          p_TUESDAY_SECOND_END => l_acchrs_setups_rec.TUESDAY_SECOND_END,
      	          p_WEDNESDAY_FIRST_START => l_acchrs_setups_rec.WEDNESDAY_FIRST_START,
      	          p_WEDNESDAY_FIRST_END => l_acchrs_setups_rec.WEDNESDAY_FIRST_END,
      	          p_WEDNESDAY_SECOND_START => l_acchrs_setups_rec.WEDNESDAY_SECOND_START,
      	          p_WEDNESDAY_SECOND_END => l_acchrs_setups_rec.WEDNESDAY_SECOND_END,
      	          p_THURSDAY_FIRST_START => l_acchrs_setups_rec.THURSDAY_FIRST_START,
      	          p_THURSDAY_FIRST_END => l_acchrs_setups_rec.THURSDAY_FIRST_END,
      	          p_THURSDAY_SECOND_START => l_acchrs_setups_rec.THURSDAY_SECOND_START,
      	          p_THURSDAY_SECOND_END => l_acchrs_setups_rec.THURSDAY_SECOND_END,
      	          p_FRIDAY_FIRST_START => l_acchrs_setups_rec.FRIDAY_FIRST_START,
      	          p_FRIDAY_FIRST_END => l_acchrs_setups_rec.FRIDAY_FIRST_END,
      	          p_FRIDAY_SECOND_START => l_acchrs_setups_rec.FRIDAY_SECOND_START,
      	          p_FRIDAY_SECOND_END => l_acchrs_setups_rec.FRIDAY_SECOND_END,
      	          p_SATURDAY_FIRST_START => l_acchrs_setups_rec.SATURDAY_FIRST_START,
      	          p_SATURDAY_FIRST_END => l_acchrs_setups_rec.SATURDAY_FIRST_END,
      	          p_SATURDAY_SECOND_START => l_acchrs_setups_rec.SATURDAY_SECOND_START,
      	          p_SATURDAY_SECOND_END => l_acchrs_setups_rec.SATURDAY_SECOND_END,
      	          p_SUNDAY_FIRST_START => l_acchrs_setups_rec.SUNDAY_FIRST_START,
      	          p_SUNDAY_FIRST_END => l_acchrs_setups_rec.SUNDAY_FIRST_END,
      	          p_SUNDAY_SECOND_START => l_acchrs_setups_rec.SUNDAY_SECOND_START,
      	          p_SUNDAY_SECOND_END => l_acchrs_setups_rec.SUNDAY_SECOND_END,
      	          p_DESCRIPTION => l_acchrs_setups_rec.DESCRIPTION,
      	          px_object_version_number => x_object_version_number,
      	          p_CREATED_BY    => null,
      	          p_CREATION_DATE   => null,
      	          p_LAST_UPDATED_BY  => null,
      	          p_LAST_UPDATE_DATE => null,
      	          p_LAST_UPDATE_LOGIN =>  null,
      			  x_return_status        => x_return_status,
      			  x_msg_count            => x_msg_count,
      			  x_msg_data             => x_msg_data );

      	      			/*fnd_message.set_name('CSF','CSF_TASK_ACC_UPDATE_ERROR');
      				    fnd_message.set_token('VALUE',l_task_dtls.task_number);
      				    fnd_msg_pub.add;
      					Add_Err_Msg;*/
      			  IF x_return_status = fnd_api.g_ret_sts_error THEN
      					RAISE fnd_api.g_exc_error;
      			  ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      					RAISE fnd_api.g_exc_unexpected_error;
      			  END IF;
        	END IF;
      	/* VAKULKAR - end - changes to associate access hours to the tasks */
   END IF;-- This end if is for l_auto_acc_hrs check

  END CREATE_ACC_HRS;

PROCEDURE create_achrs( x_return_status    out nocopy varchar2 )
IS

	l_msg_count number;
	l_return_status varchar2(10);
	l_msg_data varchar2(2000);
	l_version number;
	l_task_id number;
	l_customer_id number;
	l_address_id number;
	l_location_id number;
	l_tpl_id number;
	l_tpl_grp_id number;
    l_api_name    constant varchar2(30) := 'CREATE_ACHRS';
    l_task_type  number;
    l_dc_task   varchar2(20);

 cursor c_task_type
 is
  select task_type_id
  from jtf_tasks_b
  where task_id = l_task_id;


BEGIN
 SAVEPOINT create_achrs_s;



 l_task_id := jtf_tasks_pub.p_task_user_hooks.task_id;
 l_tpl_id     := jtf_tasks_pub.p_task_user_hooks.template_id;
 l_tpl_grp_id := jtf_tasks_pub.p_task_user_hooks.template_group_id;
 IF  l_tpl_id IS NOT NULL
 THEN
   open c_task_type;
   fetch c_task_type into l_task_type;
   close c_task_type;
   l_dc_task := csf_tasks_pub.has_field_service_rule(l_task_type);
   IF l_dc_task = fnd_api.g_true
   THEN
      csf_tasks_pub.CREATE_ACC_HRS(
						              p_task_id                    => l_task_id
						            , x_return_status              => l_return_status
						            , x_msg_count                  => l_msg_count
						            , x_msg_data                   => l_msg_data
                                   );
     IF NOT(l_return_status = fnd_api.g_ret_sts_success)
	 THEN
          l_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
     END IF;
    END IF;
 END IF;
  x_return_status  := nvl( l_return_status
                          ,fnd_api.g_ret_sts_success );
EXCEPTION
 WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_achrs_s;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error )
      then
        fnd_msg_pub.add_exc_msg ( g_pkg_name, l_api_name );
      end if;
    WHEN OTHERS THEN
      ROLLBACK TO create_achrs_s;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error )
      then
        fnd_msg_pub.add_exc_msg ( g_pkg_name, l_api_name );
      end if;
END create_achrs;
END csf_tasks_pub;

/
