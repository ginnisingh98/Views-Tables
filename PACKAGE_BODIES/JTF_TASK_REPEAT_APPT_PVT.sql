--------------------------------------------------------
--  DDL for Package Body JTF_TASK_REPEAT_APPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_REPEAT_APPT_PVT" AS
/* $Header: jtfvtkob.pls 120.6 2006/04/27 05:01:19 sbarat ship $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                            All rights reserved.                       |
+=======================================================================+
| FILENAME                                                              |
|   jtfvtkob.pls                                                        |
|                                                                       |
| DESCRIPTION                                                           |
|   This is used to process the change of repeating appointments        |
| NOTES                                                                 |
|                                                                       |
| Date          Developer     Change                                    |
|------         ------------- ---------------------------------------   |
| 26-Mar-2002   cjang         Created                                   |
| 28-Mar-2002   cjang         Modified the code for p_change_mode       |
|                             Added jtf_task_utl.is_this_first_task(),  |
|                                   jtf_task_utl.get_new_first_taskid(),|
|                                   jtf_task_utl.exist_syncid()         |
| 01-Apr-2002   cjang         Moved jtf_task_utl.is_this_first_task(),  |
|                                   jtf_task_utl.get_new_first_taskid(),|
|                                   jtf_task_utl.exist_syncid()         |
|                                to jtf_task_utl                        |
| 02-Apr-2002   cjang         Fixed modify_time and                     |
|                                   update_repeat_appointment           |
| 03-Apr-2002   cjang         Fixed so as to update last_update_date    |
| 08-Apr-2002   cjang         Added update_assignment_status            |
| 09-Apr-2002   cjang         Update object_changed_date with SYSDATE   |
|                                      in jtf_tasks_b                   |
| 24-Apr-2002   cjang         Modified c_future and c_all               |
|                                 in update_repeat_appointment          |
|                                 to check deleted_flag                 |
|                             If chnage mode = ALL, do not check if it's|
|                              the first task or not                    |
| 02-May-2002   cjang         Commented out update_assignment_status    |
| 28-Apr-2002   cjang        Modified the package name to refer the     |
|                            followings:                                |
|                              - is_this_first_task                     |
|                              - get_new_first_taskid                   |
|                              - exist_syncid                           |
|                              from jtf_task_utl to jta_sync_task_utl   |
| 03-Aug-2005   Swapan Barat Added location_id for Enh# 3691788         |
| 27-Jan-2006   Swapan Barat Fixed issue in modify_time for bug# 3850322|
| 24-Feb_2006   Twan fix issue in bug 4321360                           |
| 12-Apr-2006   Swapan Barat Fixed occurs number issue for  when        |
|                            change_mode = G_FUTURE for new recurrrence |
|                            rule. Bug# 5119782.                        |
| 26-Apr-2006   Swapan Barat Fixed bug# 5153942                         |
*=======================================================================*/

    --PROCEDURE update_assignment_status(p_task_id IN NUMBER)
    --IS
    --BEGIN
    --  UPDATE jtf_task_all_assignments
    --     SET assignment_status_id = 18
    --   WHERE assignee_role = 'ASSIGNEE'
    --     AND task_id = p_task_id;
    --END update_assignment_status;

    PROCEDURE modify_time(p_old_calendar_start_date IN DATE,
                          p_old_calendar_end_date   IN DATE,
                          p_updated_field_rec       updated_field_rec,
                          x_planned_start_date      OUT NOCOPY DATE,
                          x_planned_end_date        OUT NOCOPY DATE,
                          x_scheduled_start_date    OUT NOCOPY DATE,
                          x_scheduled_end_date      OUT NOCOPY DATE,
                          x_actual_start_date       OUT NOCOPY DATE,
                          x_actual_end_date         OUT NOCOPY DATE
    )
    IS
        l_start_date DATE;
        l_end_date   DATE;
    BEGIN
        x_planned_start_date   := p_old_calendar_start_date;
        x_planned_end_date     := p_old_calendar_end_date;
        x_scheduled_start_date := p_old_calendar_start_date;
        x_scheduled_end_date   := p_old_calendar_end_date;
        x_actual_start_date    := p_old_calendar_start_date;
        x_actual_end_date      := p_old_calendar_end_date;

        ---------------------------------------------------
        -- Check if start time is changed
        ---------------------------------------------------
        IF to_char(p_old_calendar_start_date,'HH24:MI:SS') <> to_char(p_updated_field_rec.new_calendar_start_date,'HH24:MI:SS')
        THEN
            l_start_date := to_date(to_char(p_old_calendar_start_date,'DD-MON-YYYY')||' '||
                                    to_char(p_updated_field_rec.new_calendar_start_date,'HH24:MI:SS'),
                                    'DD-MON-YYYY HH24:MI:SS');
            x_planned_start_date   := l_start_date;
            x_scheduled_start_date := l_start_date;
            x_actual_start_date    := l_start_date;
        END IF;

        ---------------------------------------------------
        -- Check if end time is changed
        ---------------------------------------------------
        IF to_char(p_old_calendar_end_date,'HH24:MI:SS') <> to_char(p_updated_field_rec.new_calendar_end_date,'HH24:MI:SS')
        THEN
            -- Commented out by SBARAT on 27/01/2006 for bug# 3850322
            /*l_end_date := to_date(to_char(p_old_calendar_end_date,'DD-MON-YYYY')||' '||
                                  to_char(p_updated_field_rec.new_calendar_end_date,'HH24:MI:SS'),
                                  'DD-MON-YYYY HH24:MI:SS');*/

            -- Added by SBARAT on 27/01/2006 for bug# 3850322
            l_end_date := NVL(l_start_date, p_old_calendar_start_date) +
                             (p_updated_field_rec.new_calendar_end_date - p_updated_field_rec.new_calendar_start_date);

            x_planned_end_date   := l_end_date;
            x_scheduled_end_date := l_end_date;
            x_actual_end_date    := l_end_date;

        END IF;
    END modify_time;

    PROCEDURE update_repeat_appointment(
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN OUT NOCOPY   NUMBER,
        p_updated_field_rec       IN       updated_field_rec,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2
    )
    IS

        CURSOR c_recur (b_recurrence_rule_id NUMBER) IS
        SELECT *
          FROM jtf_task_recur_rules
         WHERE recurrence_rule_id = b_recurrence_rule_id;

        rec_recur   c_recur%ROWTYPE;

        CURSOR c_future (b_start_date DATE, b_recurrence_rule_id NUMBER) IS
        SELECT task_id, calendar_start_date, calendar_end_date
          FROM jtf_tasks_b
         WHERE NVL(deleted_flag,'N') = 'N'
           AND calendar_start_date >= b_start_date
           AND recurrence_rule_id   = b_recurrence_rule_id;

        CURSOR c_all (b_recurrence_rule_id NUMBER) IS
        SELECT task_id, calendar_start_date, calendar_end_date
          FROM jtf_tasks_b
         WHERE NVL(deleted_flag,'N') = 'N'
           AND recurrence_rule_id = b_recurrence_rule_id;

        l_new_minimum_task_id       NUMBER;
        l_task_exclusion_id         jta_task_exclusions.task_exclusion_id%TYPE;
        l_new_recurrence_rule_id    NUMBER;
        l_send_notification         VARCHAR2(1);
        l_rowid                     ROWID;
        l_first                     BOOLEAN := FALSE;
        l_exist_new_first_task      BOOLEAN := FALSE;
        l_start_date_changed        BOOLEAN := FALSE;
        l_start_time_changed        BOOLEAN := FALSE;
        l_end_time_changed          BOOLEAN := FALSE;
        l_object_version_number     NUMBER;
        l_sync_id                   NUMBER;

        l_planned_start_date        DATE;
        l_planned_end_date          DATE;
        l_scheduled_start_date      DATE;
        l_scheduled_end_date        DATE;
        l_actual_start_date         DATE;
        l_actual_end_date           DATE;

        l_change_mode               VARCHAR2(1) := p_updated_field_rec.change_mode;

        l_occurs                    NUMBER:=0;  -- Added by SBARAT on 12/04/2006 for bug# 5119782

    BEGIN
        SAVEPOINT update_repeat_appointment_pvt;

        x_return_status := fnd_api.g_ret_sts_success;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        -----------------------------------------------------------------------
        --   l_first    l_exist_new_first_task  mapping_table  exclusion_table
        --   =======    ======================  =============  ===============
        --      Y               Y                 Update          Insert
        --
        --      Y               N               l_change_mode is changed to G_ALL
        --
        --      N              Any                  N/A           Insert
        -----------------------------------------------------------------------

        IF l_change_mode <> G_ALL
        THEN
            ---------------------------------------------------
            -- Check whether the current task_id is the first task_id
            --              which has been synced
            ---------------------------------------------------
            l_first := jta_sync_task_utl.is_this_first_task(p_task_id => p_updated_field_rec.task_id);

            -----------------------------------
            -- Get new minimum task id
            -----------------------------------
            l_new_minimum_task_id := jta_sync_task_utl.get_new_first_taskid(
                                        p_calendar_start_date => p_updated_field_rec.old_calendar_start_date,
                                        p_recurrence_rule_id  => p_updated_field_rec.recurrence_rule_id
                                     );
            IF l_new_minimum_task_id > 0
            THEN
                l_exist_new_first_task := TRUE;
            END IF;

/*
            -----------------------------------
            -- Check if start date is changed
            -----------------------------------
            IF trunc(p_updated_field_rec.old_calendar_start_date) <>
               trunc(p_updated_field_rec.new_calendar_start_date)
            THEN
                -- If start date is changed,
                --   we update only the current appointment
                l_change_mode := G_ONE;
            END IF;
*/

            -----------------------------------
            -- Check if this is the last one
            -----------------------------------
            IF (l_first AND NOT l_exist_new_first_task) OR
               (l_first AND l_change_mode = G_FUTURE)
            THEN
                -- This repeating rule has only one appointment currently OR
                -- A user selected the first task one and
                --     chose the option "Update all the future appointments"
                l_change_mode := G_ALL;
            END IF;
        END IF;

        --------------------------------------------------------------
        --
        -- Process this update based on l_change_mode
        --
        --------------------------------------------------------------
        IF l_change_mode = G_ONE
        THEN
            ---------------------------------------------------
            -- Update mapping table with new minimum task id
            --    if this is the first one and not the last one
            ---------------------------------------------------
            IF l_first and l_exist_new_first_task
            THEN
                IF jta_sync_task_utl.exist_syncid(
                                p_task_id => p_updated_field_rec.task_id,
                                x_sync_id => l_sync_id)
                THEN
                    UPDATE jta_sync_task_mapping
                       SET task_id = l_new_minimum_task_id
                         , last_update_date = SYSDATE
                     WHERE task_id = p_updated_field_rec.task_id;
                END IF;
            END IF;

            --------------------------------------------
            -- Insert this appt into exclusion table
            --------------------------------------------
            SELECT jta_task_exclusions_s.NEXTVAL
              INTO l_task_exclusion_id
              FROM DUAL;

            jta_task_exclusions_pkg.insert_row (
                p_task_exclusion_id   => l_task_exclusion_id,
                p_task_id             => p_updated_field_rec.task_id,
                p_recurrence_rule_id  => p_updated_field_rec.recurrence_rule_id,
                p_exclusion_date      => p_updated_field_rec.old_calendar_start_date
            );

            --------------------------------------------------------
            -- Update this appointment
            --------------------------------------------------------
            jtf_tasks_pvt.update_task (
                p_api_version             => p_api_version,
                p_init_msg_list           => p_init_msg_list,
                p_commit                  => p_commit,
                p_object_version_number   => p_object_version_number,
                p_task_id                 => p_updated_field_rec.task_id, -- Current appt
                p_task_name               => p_updated_field_rec.task_name,
                p_task_type_id            => p_updated_field_rec.task_type_id,
                p_description             => p_updated_field_rec.description,
                p_task_status_id          => p_updated_field_rec.task_status_id,
                p_task_priority_id        => p_updated_field_rec.task_priority_id,
                p_owner_type_code         => p_updated_field_rec.owner_type_code,
                p_owner_id                => p_updated_field_rec.owner_id,
                p_owner_territory_id      => p_updated_field_rec.owner_territory_id,
                p_assigned_by_id          => p_updated_field_rec.assigned_by_id,
                p_customer_id             => p_updated_field_rec.customer_id,
                p_cust_account_id         => p_updated_field_rec.cust_account_id,
                p_address_id              => p_updated_field_rec.address_id,
                p_planned_start_date      => p_updated_field_rec.planned_start_date,
                p_planned_end_date        => p_updated_field_rec.planned_end_date,
                p_scheduled_start_date    => p_updated_field_rec.scheduled_start_date,
                p_scheduled_end_date      => p_updated_field_rec.scheduled_end_date,
                p_actual_start_date       => p_updated_field_rec.actual_start_date,
                p_actual_end_date         => p_updated_field_rec.actual_end_date,
                p_timezone_id             => p_updated_field_rec.timezone_id,
                p_source_object_type_code => p_updated_field_rec.source_object_type_code,
                p_source_object_id        => p_updated_field_rec.source_object_id,
                p_source_object_name      => p_updated_field_rec.source_object_name,
                p_duration                => p_updated_field_rec.duration,
                p_duration_uom            => p_updated_field_rec.duration_uom,
                p_planned_effort          => p_updated_field_rec.planned_effort,
                p_planned_effort_uom      => p_updated_field_rec.planned_effort_uom,
                p_actual_effort           => p_updated_field_rec.actual_effort,
                p_actual_effort_uom       => p_updated_field_rec.actual_effort_uom,
                p_percentage_complete     => p_updated_field_rec.percentage_complete,
                p_reason_code             => p_updated_field_rec.reason_code,
                p_private_flag            => p_updated_field_rec.private_flag,
                p_publish_flag            => p_updated_field_rec.publish_flag,
                p_restrict_closure_flag   => p_updated_field_rec.restrict_closure_flag,
                p_multi_booked_flag       => p_updated_field_rec.multi_booked_flag,
                p_milestone_flag          => p_updated_field_rec.milestone_flag,
                p_holiday_flag            => p_updated_field_rec.holiday_flag,
                p_billable_flag           => p_updated_field_rec.billable_flag,
                p_bound_mode_code         => p_updated_field_rec.bound_mode_code,
                p_soft_bound_flag         => p_updated_field_rec.soft_bound_flag,
                p_workflow_process_id     => p_updated_field_rec.workflow_process_id,
                p_notification_flag       => p_updated_field_rec.notification_flag,
                p_notification_period     => p_updated_field_rec.notification_period,
                p_notification_period_uom => p_updated_field_rec.notification_period_uom,
                p_parent_task_id          => p_updated_field_rec.parent_task_id,
                p_alarm_start             => p_updated_field_rec.alarm_start,
                p_alarm_start_uom         => p_updated_field_rec.alarm_start_uom,
                p_alarm_on                => p_updated_field_rec.alarm_on,
                p_alarm_count             => p_updated_field_rec.alarm_count,
                p_alarm_fired_count       => p_updated_field_rec.alarm_fired_count,
                p_alarm_interval          => p_updated_field_rec.alarm_interval,
                p_alarm_interval_uom      => p_updated_field_rec.alarm_interval_uom,
                p_palm_flag               => p_updated_field_rec.palm_flag,
                p_wince_flag              => p_updated_field_rec.wince_flag,
                p_laptop_flag             => p_updated_field_rec.laptop_flag,
                p_device1_flag            => p_updated_field_rec.device1_flag,
                p_device2_flag            => p_updated_field_rec.device2_flag,
                p_device3_flag            => p_updated_field_rec.device3_flag,
                p_costs                   => p_updated_field_rec.costs,
                p_currency_code           => p_updated_field_rec.currency_code,
                p_escalation_level        => p_updated_field_rec.escalation_level,
                x_return_status           => x_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data,
                p_attribute1              => p_updated_field_rec.attribute1,
                p_attribute2              => p_updated_field_rec.attribute2,
                p_attribute3              => p_updated_field_rec.attribute3,
                p_attribute4              => p_updated_field_rec.attribute4,
                p_attribute5              => p_updated_field_rec.attribute5,
                p_attribute6              => p_updated_field_rec.attribute6,
                p_attribute7              => p_updated_field_rec.attribute7,
                p_attribute8              => p_updated_field_rec.attribute8,
                p_attribute9              => p_updated_field_rec.attribute9,
                p_attribute10             => p_updated_field_rec.attribute10,
                p_attribute11             => p_updated_field_rec.attribute11,
                p_attribute12             => p_updated_field_rec.attribute12,
                p_attribute13             => p_updated_field_rec.attribute13,
                p_attribute14             => p_updated_field_rec.attribute14,
                p_attribute15             => p_updated_field_rec.attribute15,
                p_attribute_category      => p_updated_field_rec.attribute_category,
                p_date_selected           => p_updated_field_rec.date_selected,
                p_category_id             => p_updated_field_rec.category_id,
                p_show_on_calendar        => p_updated_field_rec.show_on_calendar,
                p_owner_status_id         => p_updated_field_rec.owner_status_id,
                p_enable_workflow         => p_updated_field_rec.enable_workflow,
                p_abort_workflow          => p_updated_field_rec.abort_workflow,
                p_change_mode             => G_SKIP,
                p_free_busy_type          => p_updated_field_rec.free_busy_type, -- Bug No 4231616
		    p_task_confirmation_status  => jtf_task_utl.g_miss_char,
		    p_task_confirmation_counter => jtf_task_utl.g_miss_number,
		    p_task_split_flag		  => jtf_task_utl.g_miss_char,
		    p_child_position		  => jtf_task_utl.g_miss_char,
		    p_child_sequence_num	  => jtf_task_utl.g_miss_number,
                p_location_id               => p_updated_field_rec.location_id
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            --------------------------------------------------------
            -- Nullify recurrence_rule_id for this appointment
            --------------------------------------------------------
            UPDATE jtf_tasks_b
               SET recurrence_rule_id = NULL
                 , object_changed_date = SYSDATE
             WHERE task_id = p_updated_field_rec.task_id;

            IF l_first
            THEN
                UPDATE jtf_tasks_b
                   SET object_changed_date = SYSDATE
                 WHERE task_id = l_new_minimum_task_id;
            END IF;

            --------------------------------------------------------
            -- Wipe out the assignment status for invitees
            -- This will change the status back to 18 (Invited)
            --------------------------------------------------------
            --update_assignment_status(p_task_id => p_updated_field_rec.task_id);

        ELSIF l_change_mode = G_FUTURE
        THEN
            -----------------------------------------------------------------
            -- Create a new repeating rule (use recurrence table handler)
            -----------------------------------------------------------------
            OPEN c_recur (p_updated_field_rec.recurrence_rule_id);
            FETCH c_recur INTO rec_recur;
            IF c_recur%NOTFOUND
            THEN
                CLOSE c_recur;
                fnd_message.set_name ('JTF', 'JTF_TK_INVALID_RECUR_RULE');
                fnd_message.set_token ('P_TASK_RECURRENCE_RULE_ID', p_updated_field_rec.recurrence_rule_id);
                fnd_msg_pub.add;

                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            CLOSE c_recur;

            SELECT jtf_task_recur_rules_s.NEXTVAL
              INTO l_new_recurrence_rule_id
              FROM dual;

            jtf_task_recur_rules_pkg.insert_row (
                x_rowid              => l_rowid,
                x_recurrence_rule_id => l_new_recurrence_rule_id,
                x_occurs_which       => rec_recur.occurs_which,
                x_day_of_week        => rec_recur.day_of_week,
                x_date_of_month      => rec_recur.date_of_month,
                x_occurs_month       => rec_recur.occurs_month,
                x_occurs_uom         => rec_recur.occurs_uom,
                x_occurs_every       => rec_recur.occurs_every,
                x_occurs_number      => rec_recur.occurs_number,
                x_start_date_active  => trunc(p_updated_field_rec.new_calendar_start_date), -- New start date
                x_end_date_active    => rec_recur.end_date_active,
                x_attribute1         => rec_recur.attribute1 ,
                x_attribute2         => rec_recur.attribute2 ,
                x_attribute3         => rec_recur.attribute3 ,
                x_attribute4         => rec_recur.attribute4 ,
                x_attribute5         => rec_recur.attribute5 ,
                x_attribute6         => rec_recur.attribute6 ,
                x_attribute7         => rec_recur.attribute7 ,
                x_attribute8         => rec_recur.attribute8 ,
                x_attribute9         => rec_recur.attribute9 ,
                x_attribute10        => rec_recur.attribute10 ,
                x_attribute11        => rec_recur.attribute11 ,
                x_attribute12        => rec_recur.attribute12 ,
                x_attribute13        => rec_recur.attribute13 ,
                x_attribute14        => rec_recur.attribute14 ,
                x_attribute15        => rec_recur.attribute15,
                x_attribute_category => rec_recur.attribute_category ,
                x_creation_date      => SYSDATE,
                x_created_by         => jtf_task_utl.created_by,
                x_last_update_date   => SYSDATE,
                x_last_updated_by    => jtf_task_utl.updated_by,
                x_last_update_login  => fnd_global.login_id,
                x_sunday             => rec_recur.sunday,
                x_monday             => rec_recur.monday,
                x_tuesday            => rec_recur.tuesday,
                x_wednesday          => rec_recur.wednesday,
                x_thursday           => rec_recur.thursday,
                x_friday             => rec_recur.friday,
                x_saturday           => rec_recur.saturday,
                x_date_selected      => rec_recur.date_selected
            );

            -------------------------------------------------
            -- Find all the future appointments
            -- This cursor is not selecting the current appt
            -- The current appt is updated after this loop
            -------------------------------------------------
            FOR rec_future IN c_future (b_start_date         => p_updated_field_rec.old_calendar_start_date,
                                        b_recurrence_rule_id => p_updated_field_rec.recurrence_rule_id)
            LOOP

                l_occurs :=l_occurs + 1;    -- Added by SBARAT on 12/04/2006 for bug# 5119782

                --------------------------------------------
                -- Insert this appt into exclusion table
                --------------------------------------------
                SELECT jta_task_exclusions_s.NEXTVAL
                  INTO l_task_exclusion_id
                  FROM DUAL;

                jta_task_exclusions_pkg.insert_row (
                    p_task_exclusion_id   => l_task_exclusion_id,
                    p_task_id             => rec_future.task_id,
                    p_recurrence_rule_id  => p_updated_field_rec.recurrence_rule_id,
                    p_exclusion_date      => rec_future.calendar_start_date
                );

                modify_time(p_old_calendar_start_date => rec_future.calendar_start_date,
                            p_old_calendar_end_date   => rec_future.calendar_end_date,
                            p_updated_field_rec       => p_updated_field_rec,
                            x_planned_start_date      => l_planned_start_date,
                            x_planned_end_date        => l_planned_end_date,
                            x_scheduled_start_date    => l_scheduled_start_date,
                            x_scheduled_end_date      => l_scheduled_end_date,
                            x_actual_start_date       => l_actual_start_date,
                            x_actual_end_date         => l_actual_end_date
                );

                ---------------------------------------------------------
                -- Call update_task for each future appt
                --   to update the updated fields and recurrence_rule_id
                ---------------------------------------------------------
                l_object_version_number := jta_sync_task_common.get_ovn (p_task_id => rec_future.task_id);

                jtf_tasks_pvt.update_task (
                    p_api_version             => p_api_version,
                    p_init_msg_list           => p_init_msg_list,
                    p_commit                  => p_commit,
                    p_object_version_number   => l_object_version_number,
                    p_task_id                 => rec_future.task_id, -- Future appt
                    p_task_name               => p_updated_field_rec.task_name,
                    p_task_type_id            => p_updated_field_rec.task_type_id,
                    p_description             => p_updated_field_rec.description,
                    p_task_status_id          => p_updated_field_rec.task_status_id,
                    p_task_priority_id        => p_updated_field_rec.task_priority_id,
                    p_owner_type_code         => p_updated_field_rec.owner_type_code,
                    p_owner_id                => p_updated_field_rec.owner_id,
                    p_owner_territory_id      => p_updated_field_rec.owner_territory_id,
                    p_assigned_by_id          => p_updated_field_rec.assigned_by_id,
                    p_customer_id             => p_updated_field_rec.customer_id,
                    p_cust_account_id         => p_updated_field_rec.cust_account_id,
                    p_address_id              => p_updated_field_rec.address_id,
                    p_planned_start_date      => l_planned_start_date,
                    p_planned_end_date        => l_planned_end_date,
                    p_scheduled_start_date    => l_scheduled_start_date,
                    p_scheduled_end_date      => l_scheduled_end_date,
                    p_actual_start_date       => l_actual_start_date,
                    p_actual_end_date         => l_actual_end_date,
                    p_timezone_id             => p_updated_field_rec.timezone_id,
                    p_source_object_type_code => p_updated_field_rec.source_object_type_code,
                    p_source_object_id        => p_updated_field_rec.source_object_id,
                    p_source_object_name      => p_updated_field_rec.source_object_name,
                    p_duration                => p_updated_field_rec.duration,
                    p_duration_uom            => p_updated_field_rec.duration_uom,
                    p_planned_effort          => p_updated_field_rec.planned_effort,
                    p_planned_effort_uom      => p_updated_field_rec.planned_effort_uom,
                    p_actual_effort           => p_updated_field_rec.actual_effort,
                    p_actual_effort_uom       => p_updated_field_rec.actual_effort_uom,
                    p_percentage_complete     => p_updated_field_rec.percentage_complete,
                    p_reason_code             => p_updated_field_rec.reason_code,
                    p_private_flag            => p_updated_field_rec.private_flag,
                    p_publish_flag            => p_updated_field_rec.publish_flag,
                    p_restrict_closure_flag   => p_updated_field_rec.restrict_closure_flag,
                    p_multi_booked_flag       => p_updated_field_rec.multi_booked_flag,
                    p_milestone_flag          => p_updated_field_rec.milestone_flag,
                    p_holiday_flag            => p_updated_field_rec.holiday_flag,
                    p_billable_flag           => p_updated_field_rec.billable_flag,
                    p_bound_mode_code         => p_updated_field_rec.bound_mode_code,
                    p_soft_bound_flag         => p_updated_field_rec.soft_bound_flag,
                    p_workflow_process_id     => p_updated_field_rec.workflow_process_id,
                    p_notification_flag       => p_updated_field_rec.notification_flag,
                    p_notification_period     => p_updated_field_rec.notification_period,
                    p_notification_period_uom => p_updated_field_rec.notification_period_uom,
                    p_parent_task_id          => p_updated_field_rec.parent_task_id,
                    p_alarm_start             => p_updated_field_rec.alarm_start,
                    p_alarm_start_uom         => p_updated_field_rec.alarm_start_uom,
                    p_alarm_on                => p_updated_field_rec.alarm_on,
                    p_alarm_count             => p_updated_field_rec.alarm_count,
                    p_alarm_fired_count       => p_updated_field_rec.alarm_fired_count,
                    p_alarm_interval          => p_updated_field_rec.alarm_interval,
                    p_alarm_interval_uom      => p_updated_field_rec.alarm_interval_uom,
                    p_palm_flag               => p_updated_field_rec.palm_flag,
                    p_wince_flag              => p_updated_field_rec.wince_flag,
                    p_laptop_flag             => p_updated_field_rec.laptop_flag,
                    p_device1_flag            => p_updated_field_rec.device1_flag,
                    p_device2_flag            => p_updated_field_rec.device2_flag,
                    p_device3_flag            => p_updated_field_rec.device3_flag,
                    p_costs                   => p_updated_field_rec.costs,
                    p_currency_code           => p_updated_field_rec.currency_code,
                    p_escalation_level        => p_updated_field_rec.escalation_level,
                    x_return_status           => x_return_status,
                    x_msg_count               => x_msg_count,
                    x_msg_data                => x_msg_data,
                    p_attribute1              => p_updated_field_rec.attribute1,
                    p_attribute2              => p_updated_field_rec.attribute2,
                    p_attribute3              => p_updated_field_rec.attribute3,
                    p_attribute4              => p_updated_field_rec.attribute4,
                    p_attribute5              => p_updated_field_rec.attribute5,
                    p_attribute6              => p_updated_field_rec.attribute6,
                    p_attribute7              => p_updated_field_rec.attribute7,
                    p_attribute8              => p_updated_field_rec.attribute8,
                    p_attribute9              => p_updated_field_rec.attribute9,
                    p_attribute10             => p_updated_field_rec.attribute10,
                    p_attribute11             => p_updated_field_rec.attribute11,
                    p_attribute12             => p_updated_field_rec.attribute12,
                    p_attribute13             => p_updated_field_rec.attribute13,
                    p_attribute14             => p_updated_field_rec.attribute14,
                    p_attribute15             => p_updated_field_rec.attribute15,
                    p_attribute_category      => p_updated_field_rec.attribute_category,
                    p_date_selected           => p_updated_field_rec.date_selected,
                    p_category_id             => p_updated_field_rec.category_id,
                    p_show_on_calendar        => p_updated_field_rec.show_on_calendar,
                    p_owner_status_id         => p_updated_field_rec.owner_status_id,
                    p_enable_workflow         => p_updated_field_rec.enable_workflow,
                    p_abort_workflow          => p_updated_field_rec.abort_workflow,
                    p_change_mode             => G_SKIP,
		        p_free_busy_type          => p_updated_field_rec.free_busy_type, -- Bug No 4231616
		        p_task_confirmation_status  => jtf_task_utl.g_miss_char,
		        p_task_confirmation_counter => jtf_task_utl.g_miss_number,
		        p_task_split_flag		=> jtf_task_utl.g_miss_char,
		        p_child_position		=> jtf_task_utl.g_miss_char,
		        p_child_sequence_num	      => jtf_task_utl.g_miss_number,
                    p_location_id               => p_updated_field_rec.location_id
                );
                 --Added by RDESPOTO on 07/29/2004
                cac_view_util_pvt.update_repeat_collab_details(
                  p_source_task_id => p_updated_field_rec.task_id,
                  p_target_task_id => rec_future.task_id );

                IF NOT (x_return_status = fnd_api.g_ret_sts_success)
                THEN
                   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                UPDATE jtf_tasks_b
                   SET recurrence_rule_id = l_new_recurrence_rule_id
                     , object_changed_date = SYSDATE
                 WHERE task_id = rec_future.task_id;

                UPDATE jtf_tasks_b
                   SET object_changed_date = SYSDATE
                 WHERE task_id = p_updated_field_rec.task_id;

                IF rec_future.task_id = p_updated_field_rec.task_id
                THEN
                    p_object_version_number := l_object_version_number;
                END IF;

                --------------------------------------------------------
                -- Wipe out the assignment status for invitees
                -- This will change the status back to 18 (Invited)
                --------------------------------------------------------
                --update_assignment_status(p_task_id => rec_future.task_id);
            END LOOP;

            -- Added by SBARAT on 12/04/2006 for bug# 5119782
            UPDATE jtf_task_recur_rules
               SET occurs_number=l_occurs
               WHERE recurrence_rule_id = l_new_recurrence_rule_id;

        ELSIF l_change_mode = G_ALL
        THEN
            ------------------------
            -- Find all tasks
            ------------------------
            FOR rec_all IN c_all (b_recurrence_rule_id => p_updated_field_rec.recurrence_rule_id)
            LOOP
                modify_time(p_old_calendar_start_date => rec_all.calendar_start_date,
                            p_old_calendar_end_date   => rec_all.calendar_end_date,
                            p_updated_field_rec       => p_updated_field_rec,
                            x_planned_start_date      => l_planned_start_date,
                            x_planned_end_date        => l_planned_end_date,
                            x_scheduled_start_date    => l_scheduled_start_date,
                            x_scheduled_end_date      => l_scheduled_end_date,
                            x_actual_start_date       => l_actual_start_date,
                            x_actual_end_date         => l_actual_end_date
                );
                --------------------------------------------
                -- Call update_task for the each appt
                --------------------------------------------
                l_object_version_number := jta_sync_task_common.get_ovn (p_task_id => rec_all.task_id);

                jtf_tasks_pvt.update_task (
                    p_api_version             => p_api_version,
                    p_init_msg_list           => p_init_msg_list,
                    p_commit                  => p_commit,
                    p_object_version_number   => l_object_version_number,
                    p_task_id                 => rec_all.task_id, -- each appt
                    p_task_name               => p_updated_field_rec.task_name,
                    p_task_type_id            => p_updated_field_rec.task_type_id,
                    p_description             => p_updated_field_rec.description,
                    p_task_status_id          => p_updated_field_rec.task_status_id,
                    p_task_priority_id        => p_updated_field_rec.task_priority_id,
                    p_owner_type_code         => p_updated_field_rec.owner_type_code,
                    p_owner_id                => p_updated_field_rec.owner_id,
                    p_owner_territory_id      => p_updated_field_rec.owner_territory_id,
                    p_assigned_by_id          => p_updated_field_rec.assigned_by_id,
                    p_customer_id             => p_updated_field_rec.customer_id,
                    p_cust_account_id         => p_updated_field_rec.cust_account_id,
                    p_address_id              => p_updated_field_rec.address_id,
                    p_planned_start_date      => l_planned_start_date,
                    p_planned_end_date        => l_planned_end_date,
                    p_scheduled_start_date    => l_scheduled_start_date,
                    p_scheduled_end_date      => l_scheduled_end_date,
                    p_actual_start_date       => l_actual_start_date,
                    p_actual_end_date         => l_actual_end_date,
                    p_timezone_id             => p_updated_field_rec.timezone_id,
                    p_source_object_type_code => p_updated_field_rec.source_object_type_code,
                    p_source_object_id        => p_updated_field_rec.source_object_id,
                    p_source_object_name      => p_updated_field_rec.source_object_name,
                    p_duration                => p_updated_field_rec.duration,
                    p_duration_uom            => p_updated_field_rec.duration_uom,
                    p_planned_effort          => p_updated_field_rec.planned_effort,
                    p_planned_effort_uom      => p_updated_field_rec.planned_effort_uom,
                    p_actual_effort           => p_updated_field_rec.actual_effort,
                    p_actual_effort_uom       => p_updated_field_rec.actual_effort_uom,
                    p_percentage_complete     => p_updated_field_rec.percentage_complete,
                    p_reason_code             => p_updated_field_rec.reason_code,
                    p_private_flag            => p_updated_field_rec.private_flag,
                    p_publish_flag            => p_updated_field_rec.publish_flag,
                    p_restrict_closure_flag   => p_updated_field_rec.restrict_closure_flag,
                    p_multi_booked_flag       => p_updated_field_rec.multi_booked_flag,
                    p_milestone_flag          => p_updated_field_rec.milestone_flag,
                    p_holiday_flag            => p_updated_field_rec.holiday_flag,
                    p_billable_flag           => p_updated_field_rec.billable_flag,
                    p_bound_mode_code         => p_updated_field_rec.bound_mode_code,
                    p_soft_bound_flag         => p_updated_field_rec.soft_bound_flag,
                    p_workflow_process_id     => p_updated_field_rec.workflow_process_id,
                    p_notification_flag       => p_updated_field_rec.notification_flag,
                    p_notification_period     => p_updated_field_rec.notification_period,
                    p_notification_period_uom => p_updated_field_rec.notification_period_uom,
                    p_parent_task_id          => p_updated_field_rec.parent_task_id,
                    p_alarm_start             => p_updated_field_rec.alarm_start,
                    p_alarm_start_uom         => p_updated_field_rec.alarm_start_uom,
                    p_alarm_on                => p_updated_field_rec.alarm_on,
                    p_alarm_count             => p_updated_field_rec.alarm_count,
                    p_alarm_fired_count       => p_updated_field_rec.alarm_fired_count,
                    p_alarm_interval          => p_updated_field_rec.alarm_interval,
                    p_alarm_interval_uom      => p_updated_field_rec.alarm_interval_uom,
                    p_palm_flag               => p_updated_field_rec.palm_flag,
                    p_wince_flag              => p_updated_field_rec.wince_flag,
                    p_laptop_flag             => p_updated_field_rec.laptop_flag,
                    p_device1_flag            => p_updated_field_rec.device1_flag,
                    p_device2_flag            => p_updated_field_rec.device2_flag,
                    p_device3_flag            => p_updated_field_rec.device3_flag,
                    p_costs                   => p_updated_field_rec.costs,
                    p_currency_code           => p_updated_field_rec.currency_code,
                    p_escalation_level        => p_updated_field_rec.escalation_level,
                    x_return_status           => x_return_status,
                    x_msg_count               => x_msg_count,
                    x_msg_data                => x_msg_data,
                    p_attribute1              => p_updated_field_rec.attribute1,
                    p_attribute2              => p_updated_field_rec.attribute2,
                    p_attribute3              => p_updated_field_rec.attribute3,
                    p_attribute4              => p_updated_field_rec.attribute4,
                    p_attribute5              => p_updated_field_rec.attribute5,
                    p_attribute6              => p_updated_field_rec.attribute6,
                    p_attribute7              => p_updated_field_rec.attribute7,
                    p_attribute8              => p_updated_field_rec.attribute8,
                    p_attribute9              => p_updated_field_rec.attribute9,
                    p_attribute10             => p_updated_field_rec.attribute10,
                    p_attribute11             => p_updated_field_rec.attribute11,
                    p_attribute12             => p_updated_field_rec.attribute12,
                    p_attribute13             => p_updated_field_rec.attribute13,
                    p_attribute14             => p_updated_field_rec.attribute14,
                    p_attribute15             => p_updated_field_rec.attribute15,
                    p_attribute_category      => p_updated_field_rec.attribute_category,
                    p_date_selected           => p_updated_field_rec.date_selected,
                    p_category_id             => p_updated_field_rec.category_id,
                    p_show_on_calendar        => p_updated_field_rec.show_on_calendar,
                    p_owner_status_id         => p_updated_field_rec.owner_status_id,
                    p_enable_workflow         => p_updated_field_rec.enable_workflow,
                    p_abort_workflow          => p_updated_field_rec.abort_workflow,
                    p_change_mode             => G_SKIP,
		        p_free_busy_type          => p_updated_field_rec.free_busy_type, -- Bug No 4231616
		        p_task_confirmation_status  => jtf_task_utl.g_miss_char,
		        p_task_confirmation_counter => jtf_task_utl.g_miss_number,
		        p_task_split_flag		=> jtf_task_utl.g_miss_char,
		        p_child_position		=> jtf_task_utl.g_miss_char,
		        p_child_sequence_num	      => jtf_task_utl.g_miss_number,
                    p_location_id               => p_updated_field_rec.location_id
                );

                 --Added by RDESPOTO on 07/29/2004
                cac_view_util_pvt.update_repeat_collab_details(
                  p_source_task_id => p_updated_field_rec.task_id,
                  p_target_task_id => rec_all.task_id );

                IF NOT (x_return_status = fnd_api.g_ret_sts_success)
                THEN
                   x_return_status := fnd_api.g_ret_sts_unexp_error;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF rec_all.task_id = p_updated_field_rec.task_id
                THEN
                    p_object_version_number := l_object_version_number;
                END IF;

                --------------------------------------------------------
                -- Wipe out the assignment status for invitees
                -- This will change the status back to 18 (Invited)
                --------------------------------------------------------
                --update_assignment_status(p_task_id => rec_all.task_id);
            END LOOP;

        END IF; -- end-if trunc(tasks.calendar_start_date) <> trunc(l_calendar_start_date)

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO update_repeat_appointment_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO update_repeat_appointment_pvt;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END update_repeat_appointment;

END JTF_TASK_REPEAT_APPT_PVT;

/
