--------------------------------------------------------
--  DDL for Package Body JTF_TASK_REPEAT_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_REPEAT_ASSIGNMENT_PVT" AS
/* $Header: jtfvtkcb.pls 120.1.12000000.2 2007/07/19 08:42:29 lokumar ship $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                            All rights reserved.                       |
+=======================================================================+
| FILENAME                                                              |
|   jtftkcb.pls                                                         |
|                                                                       |
| DESCRIPTION                                                           |
|   This package is used to process the repsone of assignee's response  |
|    in repeating appointment.                                          |
|   The assignee can accept or reject either a specific appointment or  |
|        all the appointments among repeating appointments.             |
|                                                                       |
|   Action     assignment_status_id                                     |
|   ========== ======================                                   |
|   REJECT ALL          4                                               |
|   ACCEPT ALL          3                                               |
|                                                                       |
|   The possible value for add_option:                                  |
|       T: Add a new invitee to all the future appointments             |
|       A: Add a new invitee to all appointments                        |
|       F: Add a new invitee to the current selected appointment only   |
|       N: Skip the new functionality                                   |
|                                                                       |
|   The possible value for delete_option:                               |
|       T: Delete a new invitee from all the future appointments        |
|       A: Delete a new invitee from all appointments                   |
|       F: Delete a new invitee from the current selected appointment   |
|       N: Skip the new functionality                                   |
|                                                                       |
| NOTES                                                                 |
|                                                                       |
| Date          Developer        Change                                 |
|------         ---------------  ---------------------------------------|
| 28-Mar-2002   cjang            Created                                |
| 29-Mar-2002   cjang            Added response_invitation_rec          |
|                                      add_assignee_rec                 |
|                                      delete_assignee_rec              |
|                                      add_assignee_rec                 |
|                                      add_assignee_rec                 |
|                                      add_assignee                     |
|                                      delete_assignee                  |
|                                Modified response_invitation           |
| 02-Apr-2002   cjang            Modified                               |
| 03-Apr-2002   cjang            Fixed so as to update last_update_date |
| 09-Apr-2002   cjang            Update object_changed_date with SYSDATE|
|                                      in jtf_tasks_b                   |
| 10-Apr-2002   cjang        A user is NOT allowed to accept one of     |
|                              occurrences.                             |
|                            He/She can either accept all or reject all.|
|                            The "update_all" and "calendar_start_date" |
|                              in response_invitation_rec is removed.   |
| 28-Apr-2002   cjang        Modified the package name to refer the     |
|                            followings:                                |
|                              - is_this_first_task                     |
|                              - get_new_first_taskid                   |
|                              - exist_syncid                           |
|                              from jtf_task_utl to jta_sync_task_utl   |
*=======================================================================*/

    PROCEDURE response_invitation(
        p_api_version             IN     NUMBER,
        p_init_msg_list           IN     VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN     VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN OUT NOCOPY NUMBER,
        p_response_invitation_rec IN     response_invitation_rec,
        x_return_status           OUT NOCOPY    VARCHAR2,
        x_msg_count               OUT NOCOPY    NUMBER,
        x_msg_data                OUT NOCOPY    VARCHAR2
    )
    IS
        CURSOR c_assignments (b_recurrence_rule_id NUMBER
                            , b_task_assignment_id NUMBER)
        IS
        SELECT jtb.task_id
             , jtaa.task_assignment_id
             , jtaa.object_version_number
          FROM jtf_task_all_assignments jtaa
             , jtf_tasks_b jtb
             , jtf_task_all_assignments rs
         WHERE jtb.recurrence_rule_id = b_recurrence_rule_id
           AND rs.task_assignment_id  = b_task_assignment_id
           AND jtaa.task_id     = jtb.task_id
           AND jtaa.resource_id = rs.resource_id;

        l_object_version_number NUMBER := p_object_version_number;
    BEGIN
        SAVEPOINT response_invitation_pvt;

        x_return_status := fnd_api.g_ret_sts_success;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        ----------------------------------------------------
        FOR rec_assignments IN c_assignments(b_recurrence_rule_id  => p_response_invitation_rec.recurrence_rule_id
                                           , b_task_assignment_id  => p_response_invitation_rec.task_assignment_id)
        LOOP
            l_object_version_number := rec_assignments.object_version_number;

            jtf_task_assignments_pvt.g_response_flag := jtf_task_utl.g_yes_char;

            jtf_task_assignments_pvt.update_task_assignment (
                  p_api_version           => p_api_version,
                  p_object_version_number => l_object_version_number,
                  p_init_msg_list         => fnd_api.g_true,
                  p_commit                => fnd_api.g_false,
                  p_task_assignment_id    => rec_assignments.task_assignment_id,
                  p_assignment_status_id  => p_response_invitation_rec.assignment_status_id,
                  x_return_status         => x_return_status,
                  x_msg_count             => x_msg_count,
                  x_msg_data              => x_msg_data,
                  p_enable_workflow       => 'N',
                  p_abort_workflow        => 'N'
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF p_response_invitation_rec.task_id = rec_assignments.task_id
            THEN
                p_object_version_number := l_object_version_number;
            END IF;
        END LOOP;
        ----------------------------------------------------

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO response_invitation_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO response_invitation_pvt;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END response_invitation;

    PROCEDURE add_assignee(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT fnd_api.g_false,
            p_commit               IN  VARCHAR2 DEFAULT fnd_api.g_false,
            p_add_assignee_rec     IN  add_assignee_rec,
            x_return_status       OUT NOCOPY  VARCHAR2,
            x_msg_count           OUT NOCOPY  NUMBER,
            x_msg_data            OUT NOCOPY  VARCHAR2,
            x_task_assignment_id  OUT NOCOPY  NUMBER
    )
    IS
        CURSOR c_tasks (b_recurrence_rule_id NUMBER
                       ,b_calendar_start_date DATE
                       ,b_add_option VARCHAR2)
        IS
        SELECT task_id
             , calendar_start_date
          FROM jtf_tasks_b
         WHERE recurrence_rule_id = b_recurrence_rule_id
           AND ((b_add_option = JTF_TASK_REPEAT_APPT_PVT.G_ALL)   OR
                (b_add_option = JTF_TASK_REPEAT_APPT_PVT.G_FUTURE AND calendar_start_date >= b_calendar_start_date) OR
                (b_add_option = JTF_TASK_REPEAT_APPT_PVT.G_ONE    AND calendar_start_date  = b_calendar_start_date));

        l_task_exclusion_id   NUMBER;

        CURSOR c_recur (b_recurrence_rule_id NUMBER) IS
        SELECT *
          FROM jtf_task_recur_rules
         WHERE recurrence_rule_id = b_recurrence_rule_id;

        rec_recur   c_recur%ROWTYPE;

        l_rowid ROWID;
        l_new_recurrence_rule_id NUMBER := NULL;
        l_new_minimum_task_id    NUMBER := NULL;
        l_first                  BOOLEAN := FALSE;
        l_exist_new_first_task   BOOLEAN := FALSE;
        l_sync_id NUMBER;

        l_add_option VARCHAR2(1) := p_add_assignee_rec.add_option;
    BEGIN
        SAVEPOINT add_assignee_pvt;

        x_return_status := fnd_api.g_ret_sts_success;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        ----------------------------------------------------------
        -- Check whether the current task_id is the first task_id
        --              which has been synced
        ----------------------------------------------------------
        l_first := jta_sync_task_utl.is_this_first_task(p_task_id => p_add_assignee_rec.task_id);

        -----------------------------------
        -- Get new minimum task id
        -----------------------------------
        l_new_minimum_task_id := jta_sync_task_utl.get_new_first_taskid(
                                    p_calendar_start_date => p_add_assignee_rec.calendar_start_date,
                                    p_recurrence_rule_id  => p_add_assignee_rec.recurrence_rule_id
                                 );
        IF l_new_minimum_task_id > 0
        THEN
            l_exist_new_first_task := TRUE;
        END IF;

        -----------------------------------
        -- Check if this is the last one
        -----------------------------------
        IF (l_first AND NOT l_exist_new_first_task) OR
           (l_first AND l_add_option = JTF_TASK_REPEAT_APPT_PVT.G_FUTURE)
        THEN
            -- This repeating rule has only one appointment currently OR
            -- A user selected the first task one and
            --     chose the option "Add this new invitee into all the future appointments"
            l_add_option := JTF_TASK_REPEAT_APPT_PVT.G_ALL;
        END IF;

        IF l_add_option = JTF_TASK_REPEAT_APPT_PVT.G_FUTURE
        THEN
            -----------------------------------------------------------------
            -- Create a new repeating rule (use recurrence table handler)
            -----------------------------------------------------------------
            OPEN c_recur (p_add_assignee_rec.recurrence_rule_id);
            FETCH c_recur INTO rec_recur;
            IF c_recur%NOTFOUND
            THEN
                CLOSE c_recur;
                fnd_message.set_name ('JTF', 'JTF_TK_INVALID_RECUR_RULE');
                fnd_message.set_token ('P_TASK_RECURRENCE_RULE_ID', p_add_assignee_rec.recurrence_rule_id);
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
                x_start_date_active  => trunc(p_add_assignee_rec.calendar_start_date), -- New start date
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
        END IF;

        FOR rec_tasks IN c_tasks (b_recurrence_rule_id => p_add_assignee_rec.recurrence_rule_id
                                 ,b_calendar_start_date=> p_add_assignee_rec.calendar_start_date
                                 ,b_add_option         => l_add_option)
        LOOP
            IF l_add_option = JTF_TASK_REPEAT_APPT_PVT.G_ONE AND
               l_first AND
               l_exist_new_first_task
            THEN
                ---------------------------------------------------
                -- Update mapping table with new minimum task id
                --    if this is the first one and not the last one
                ---------------------------------------------------
                IF jta_sync_task_utl.exist_syncid(
                                p_task_id     => rec_tasks.task_id,
                                x_sync_id     => l_sync_id)
                THEN
                    jta_sync_task_map_pkg.update_row (
                        p_task_sync_id => l_sync_id,
                        p_task_id      => l_new_minimum_task_id,
                        p_resource_id  => p_add_assignee_rec.resource_id
                    );
                END IF;
            END IF;

            IF l_add_option = JTF_TASK_REPEAT_APPT_PVT.G_FUTURE OR
               l_add_option = JTF_TASK_REPEAT_APPT_PVT.G_ONE
            THEN
                --------------------------------------------
                -- Insert this appt into exclusion table
                --------------------------------------------
                SELECT jta_task_exclusions_s.NEXTVAL
                  INTO l_task_exclusion_id
                  FROM DUAL;

                jta_task_exclusions_pkg.insert_row (
                    p_task_exclusion_id   => l_task_exclusion_id,
                    p_task_id             => rec_tasks.task_id,
                    p_recurrence_rule_id  => p_add_assignee_rec.recurrence_rule_id,
                    p_exclusion_date      => rec_tasks.calendar_start_date
                );

                --------------------------------------------------------
                -- l_new_recurrence_rule_id has the following value
                --    1) NULL if option = JTF_TASK_REPEAT_APPT_PVT.G_ONE
                --    2) new recurrence rule id if option = JTF_TASK_REPEAT_APPT_PVT.G_FUTURE
                --------------------------------------------------------
                UPDATE jtf_tasks_b
                   SET recurrence_rule_id = l_new_recurrence_rule_id
                     , object_changed_date = SYSDATE
                 WHERE task_id = rec_tasks.task_id;
            END IF;

            ----------------------
            -- Add a new invitee
            ----------------------
            jtf_task_assignments_pvt.create_task_assignment (
                p_api_version           => 1.0,
                p_init_msg_list         => fnd_api.g_false,
                p_commit                => fnd_api.g_false,
                p_task_id               => rec_tasks.task_id,
                p_resource_type_code    => p_add_assignee_rec.resource_type_code,
                p_resource_id           => p_add_assignee_rec.resource_id,
		p_free_busy_type        => p_add_assignee_rec.free_busy_type,
                p_assignment_status_id  => p_add_assignee_rec.assignment_status_id,
                p_add_option            => NULL,
                p_enable_workflow       => 'N',
                p_abort_workflow        => 'N',
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                x_task_assignment_id    => x_task_assignment_id
            );
            IF x_return_status <> fnd_api.g_ret_sts_success THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

        END LOOP;
        ----------------------------------------------------

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO add_assignee_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO add_assignee_pvt;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END add_assignee;

    PROCEDURE delete_assignee(
            p_api_version         IN  NUMBER,
            p_init_msg_list       IN  VARCHAR2 DEFAULT fnd_api.g_false,
            p_commit              IN  VARCHAR2 DEFAULT fnd_api.g_false,
            p_delete_assignee_rec IN  delete_assignee_rec,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_msg_count           OUT NOCOPY NUMBER,
            x_msg_data            OUT NOCOPY VARCHAR2
    )
    IS
        CURSOR c_assignments (b_recurrence_rule_id NUMBER
                             ,b_calendar_start_date DATE
                             ,b_resource_id NUMBER
                             ,b_delete_option VARCHAR2)
        IS
        SELECT jtaa.task_assignment_id
             , jtaa.object_version_number
             , jtaa.task_id
             , jtb.calendar_start_date
          FROM jtf_task_all_assignments jtaa
             , jtf_tasks_b jtb
         WHERE jtb.recurrence_rule_id = b_recurrence_rule_id
           AND ((b_delete_option = JTF_TASK_REPEAT_APPT_PVT.G_ALL) OR
                (b_delete_option = JTF_TASK_REPEAT_APPT_PVT.G_ONE    AND jtb.calendar_start_date  = b_calendar_start_date) OR
                (b_delete_option = JTF_TASK_REPEAT_APPT_PVT.G_FUTURE AND jtb.calendar_start_date >= b_calendar_start_date))
           AND jtaa.task_id = jtb.task_id
           AND jtaa.resource_id = b_resource_id;

        l_task_exclusion_id NUMBER;

        CURSOR c_recur (b_recurrence_rule_id NUMBER) IS
        SELECT *
          FROM jtf_task_recur_rules
         WHERE recurrence_rule_id = b_recurrence_rule_id;

        rec_recur   c_recur%ROWTYPE;

        l_rowid ROWID;
        l_new_recurrence_rule_id NUMBER := NULL;
        l_new_minimum_task_id    NUMBER := NULL;
        l_first                  BOOLEAN := FALSE;
        l_exist_new_first_task   BOOLEAN := FALSE;
        l_sync_id NUMBER;

        l_delete_option VARCHAR2(1) := p_delete_assignee_rec.delete_option;
    BEGIN
        SAVEPOINT delete_assignee_pvt;

        x_return_status := fnd_api.g_ret_sts_success;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        ----------------------------------------------------
        ----------------------------------------------------------
        -- Check whether the current task_id is the first task_id
        --              which has been synced
        ----------------------------------------------------------
        l_first := jta_sync_task_utl.is_this_first_task(
                        p_task_id     => p_delete_assignee_rec.task_id
                   );

        -----------------------------------
        -- Get new minimum task id
        -----------------------------------
        l_new_minimum_task_id := jta_sync_task_utl.get_new_first_taskid(
                                    p_calendar_start_date => p_delete_assignee_rec.calendar_start_date,
                                    p_recurrence_rule_id  => p_delete_assignee_rec.recurrence_rule_id
                                 );
        IF l_new_minimum_task_id > 0
        THEN
            l_exist_new_first_task := TRUE;
        END IF;

        -----------------------------------
        -- Check if this is the last one
        -----------------------------------
        IF (l_first AND NOT l_exist_new_first_task) OR
           (l_first AND l_delete_option = JTF_TASK_REPEAT_APPT_PVT.G_FUTURE)
        THEN
            -- This repeating rule has only one appointment currently OR
            -- A user selected the first task one and
            --     chose the option "Delete this invitee from all the future appointments"
            l_delete_option := JTF_TASK_REPEAT_APPT_PVT.G_ALL;
        END IF;

        IF l_delete_option = JTF_TASK_REPEAT_APPT_PVT.G_FUTURE
        THEN
            -----------------------------------------------------------------
            -- Create a new repeating rule (use recurrence table handler)
            -----------------------------------------------------------------
            OPEN c_recur (p_delete_assignee_rec.recurrence_rule_id);
            FETCH c_recur INTO rec_recur;
            IF c_recur%NOTFOUND
            THEN
                CLOSE c_recur;
                fnd_message.set_name ('JTF', 'JTF_TK_INVALID_RECUR_RULE');
                fnd_message.set_token ('P_TASK_RECURRENCE_RULE_ID', p_delete_assignee_rec.recurrence_rule_id);
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
                x_start_date_active  => trunc(p_delete_assignee_rec.calendar_start_date), -- New start date
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
        END IF;

        FOR rec_assignments IN c_assignments (b_recurrence_rule_id  => p_delete_assignee_rec.recurrence_rule_id
                                             ,b_calendar_start_date => p_delete_assignee_rec.calendar_start_date
                                             ,b_resource_id         => p_delete_assignee_rec.resource_id
                                             ,b_delete_option       => l_delete_option)
        LOOP
            IF l_delete_option = JTF_TASK_REPEAT_APPT_PVT.G_ONE AND
               l_first AND
               l_exist_new_first_task
            THEN
                ---------------------------------------------------
                -- Update mapping table with new minimum task id
                --    if this is the first one and not the last one
                ---------------------------------------------------
                IF jta_sync_task_utl.exist_syncid(
                                p_task_id     => rec_assignments.task_id,
                                x_sync_id     => l_sync_id)
                THEN
                    jta_sync_task_map_pkg.update_row (
                        p_task_sync_id => l_sync_id,
                        p_task_id      => l_new_minimum_task_id,
                        p_resource_id  => p_delete_assignee_rec.resource_id
                    );
                END IF;
            END IF;

            IF l_delete_option = JTF_TASK_REPEAT_APPT_PVT.G_FUTURE OR
               l_delete_option = JTF_TASK_REPEAT_APPT_PVT.G_ONE
            THEN
                --------------------------------------------
                -- Insert this appt into exclusion table
                --------------------------------------------
                SELECT jta_task_exclusions_s.NEXTVAL
                  INTO l_task_exclusion_id
                  FROM DUAL;

                jta_task_exclusions_pkg.insert_row (
                    p_task_exclusion_id   => l_task_exclusion_id,
                    p_task_id             => rec_assignments.task_id,
                    p_recurrence_rule_id  => p_delete_assignee_rec.recurrence_rule_id,
                    p_exclusion_date      => rec_assignments.calendar_start_date
                );

                --------------------------------------------------------
                -- l_new_recurrence_rule_id has the following value
                --    1) NULL if option = JTF_TASK_REPEAT_APPT_PVT.G_ONE
                --    2) new recurrence rule id if option = JTF_TASK_REPEAT_APPT_PVT.G_FUTURE
                --------------------------------------------------------
                UPDATE jtf_tasks_b
                   SET recurrence_rule_id = l_new_recurrence_rule_id
                     , object_changed_date = SYSDATE
                 WHERE task_id = rec_assignments.task_id;
            END IF;

            ----------------------
            -- Delete this invitee
            ----------------------
            jtf_task_assignments_pvt.delete_task_assignment (
                p_api_version           => 1.0,
                p_init_msg_list         => fnd_api.g_false,
                p_commit                => fnd_api.g_false,
                p_task_assignment_id    => rec_assignments.task_assignment_id,
                p_object_version_number => rec_assignments.object_version_number,
                p_delete_option         => NULL,
                p_enable_workflow       => 'N',
                p_abort_workflow        => 'N',
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
            );
            IF x_return_status <> fnd_api.g_ret_sts_success THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END LOOP;
        ----------------------------------------------------

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO delete_assignee_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO delete_assignee_pvt;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END delete_assignee;

END jtf_task_repeat_assignment_pvt;

/
