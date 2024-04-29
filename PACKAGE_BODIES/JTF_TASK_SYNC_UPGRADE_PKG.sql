--------------------------------------------------------
--  DDL for Package Body JTF_TASK_SYNC_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_SYNC_UPGRADE_PKG" AS
/* $Header: jtftkugb.pls 120.2 2006/02/14 06:37:46 sbarat ship $ */
/*======================================================================+
| DESCRIPTION                                                           |
|    This package is used to migrate the existing task data             |
|      so that they can work with synchronization function.             |
|                                                                       |
| NOTES                                                                 |
|                                                                       |
| Date          Developer        Change                                 |
| ------        ---------------  -------------------------------------- |
| 26-Aug-2002   cjang            Created.                               |
| 18-Oct-2004   mmarovic         Added is_repeating_appt to improve     |
|            upgrade performance for customers that do not use appts.   |
| 14-Feb-2006   sbarat           Added hint 'parallel' for perf         |
|                                bug# 4965969. Reviewed by Avanish      |
|                                Srivatsav of Perf Team.                |
+=======================================================================*/

-- Global variable that will be set to TRUE if there is any repeating
-- appointment to be upgraded - it will be set by is_repeating_appt
g_repeating_appt BOOLEAN := null;

-- Checks is there any repeating appointment to migrate
FUNCTION is_repeating_appt RETURN BOOLEAN
IS
  cursor c_appt is
    select 'x'
      from jtf_tasks_b
      where source_object_type_code = 'APPOINTMENT'
        and rownum = 1;
  l_is_appt CHAR(1);

BEGIN
     if g_repeating_appt is null
     then
         open c_appt;
         fetch c_appt into l_is_appt;
         close c_appt;
         if l_is_appt = 'x'
         then
              g_repeating_appt := true;
         else
              g_repeating_appt := false;
         end if;
     end if;

     return g_repeating_appt;

END is_repeating_appt;

PROCEDURE update_invalid_repeating_appts
IS
    -----------------------------------------------------------
    -- For selecting duplicate repeating appointments
    --   among unchanged records
    -----------------------------------------------------------
    CURSOR c_duplicates (b_recurrence_rule_id  NUMBER
                        ,b_recur_creation_date DATE) IS
    SELECT t.task_id
      FROM jtf_tasks_b t
         , (SELECT recurrence_rule_id
                 , calendar_start_date
                 , count(task_id) cnt
                 , min(task_id) min_task_id
              FROM jtf_tasks_b
             WHERE recurrence_rule_id = b_recurrence_rule_id
               AND (last_update_date <= b_recur_creation_date OR
                    last_update_date = creation_date)
               AND source_object_type_code = 'APPOINTMENT'
            HAVING count(task_id) > 1
            GROUP BY recurrence_rule_id, calendar_start_date
            ) dup
     WHERE t.recurrence_rule_id  = dup.recurrence_rule_id
       AND t.calendar_start_date = dup.calendar_start_date
       AND t.task_id <> dup.min_task_id;

    -----------------------------------------------------------
    -- For selecting all repeating appointments not changed
    --   among unchanged records
    -----------------------------------------------------------
    CURSOR c_repeat_appt (b_recurrence_rule_id  NUMBER
                         ,b_recur_creation_date DATE) IS
    SELECT task_id
         , calendar_start_date
         , created_by
      FROM jtf_tasks_b
     WHERE recurrence_rule_id = b_recurrence_rule_id
       AND (last_update_date <= b_recur_creation_date OR
            last_update_date = creation_date)
       AND source_object_type_code = 'APPOINTMENT'
    ORDER BY calendar_start_date, task_id;

    ------------------------------------------------------------------
    -- For selecting recurrence rules for all repeating appointments
    ------------------------------------------------------------------
    CURSOR c_recur IS
    SELECT recurrence_rule_id
         , occurs_which
         , day_of_week
         , date_of_month
         , occurs_number
         , occurs_month
         , occurs_uom
         , occurs_every
         , start_date_active
         , end_date_active
         , sunday
         , monday
         , tuesday
         , wednesday
         , thursday
         , friday
         , saturday
         , created_by
         , creation_date
      FROM jtf_task_recur_rules r
     WHERE EXISTS (SELECT 1
                     FROM jtf_tasks_b jtb
                    WHERE jtb.recurrence_rule_id = r.recurrence_rule_id
                      AND jtb.source_object_type_code = 'APPOINTMENT'
                      AND (jtb.object_changed_date = to_date('01/02/1970','MM/DD/YYYY') OR
                           jtb.object_changed_date IS NULL)
                   );

    l_output_dates_tbl     jtf_task_recurrences_pvt.output_dates_rec;
    l_output_dates_counter INTEGER;
    l_invalid              BOOLEAN := TRUE;
    l_all_changed          BOOLEAN := FALSE;
    l_task_exclusion_id    NUMBER;
    l_time VARCHAR2(8) := '00:00:00';
    l_exclusion_date DATE;

    l_num NUMBER := 0;
    l_commit_records NUMBER := 0;
    l_commit_checkpoint NUMBER := 1000;
BEGIN
    IF NOT is_repeating_appt() THEN
       RETURN;
    END IF;

    FOR rec_recur IN c_recur
    LOOP
        -----------------------------------------------------------
        -- Duplicate Dates:
        --        Nullify recurrence_rule_id
        -----------------------------------------------------------
        FOR rec_duplicates IN c_duplicates(rec_recur.recurrence_rule_id
                                          ,rec_recur.creation_date)
        LOOP
            l_num := l_num + 1;

            -- Nullify recurrence_rule_id
            UPDATE jtf_tasks_b
               SET recurrence_rule_id = NULL
                 , last_updated_by = fnd_global.user_id
             WHERE task_id = rec_duplicates.task_id;

            COMMIT;

        END LOOP;

        -----------------------------------------------------------
        -- Invalid and Extra Dates:
        --        Nullify recurrence_rule_id
        --        Insert into exclusion table
        -----------------------------------------------------------
        jtf_task_recurrences_pvt.generate_dates (
            p_occurs_which         => rec_recur.occurs_which,
            p_day_of_week          => rec_recur.day_of_week,
            p_date_of_month        => rec_recur.date_of_month,
            p_occurs_month         => rec_recur.occurs_month,
            p_occurs_uom           => rec_recur.occurs_uom,
            p_occurs_every         => rec_recur.occurs_every,
            p_occurs_number        => NULL,
            p_start_date           => rec_recur.start_date_active,
            p_end_date             => rec_recur.end_date_active,
            x_output_dates_tbl     => l_output_dates_tbl,
            x_output_dates_counter => l_output_dates_counter,
            p_sunday               => rec_recur.sunday,
            p_monday               => rec_recur.monday,
            p_tuesday              => rec_recur.tuesday,
            p_wednesday            => rec_recur.wednesday,
            p_thursday             => rec_recur.thursday,
            p_friday               => rec_recur.friday,
            p_saturday             => rec_recur.saturday
        );

        IF l_output_dates_tbl.COUNT > 0
        THEN
            FOR rec_repeat_appt IN c_repeat_appt (rec_recur.recurrence_rule_id
                                                 ,rec_recur.creation_date)
            LOOP
                l_invalid := TRUE;

                IF l_output_dates_tbl.COUNT > 0
                THEN
                    FOR i IN l_output_dates_tbl.FIRST..l_output_dates_tbl.LAST
                    LOOP
                        IF l_output_dates_tbl.EXISTS(i)
                        THEN
                            IF TRUNC(l_output_dates_tbl(i)) = TRUNC(rec_repeat_appt.calendar_start_date)
                            THEN
                                l_output_dates_tbl.DELETE(i);
                                l_invalid := FALSE;
                                l_time := to_char(rec_repeat_appt.calendar_start_date,'HH24:MI:SS');
                                EXIT;
                            END IF;
                        END IF;
                    END LOOP;
                END IF;

                -----------------------------------------------
                -- If not found the matched date
                -----------------------------------------------
                IF l_invalid
                THEN
                    -- Nullify recurrence_rule_id
                    UPDATE jtf_tasks_b
                       SET recurrence_rule_id = NULL
                         , last_updated_by = fnd_global.user_id
                     WHERE task_id = rec_repeat_appt.task_id;

                    l_num := l_num + 1;

                    IF (l_num - l_commit_records) = l_commit_checkpoint
                    THEN
                        COMMIT;
                        l_commit_records := l_commit_records + l_commit_checkpoint;
                    END IF;
                END IF;

            END LOOP; -- c_repeat_appt

            COMMIT;

        END IF; -- l_output_dates_tbl.COUNT > 0

        -----------------------------------------------------------
        -- Missing Dates:
        --        Insert into exclusion table
        -----------------------------------------------------------
        IF l_output_dates_tbl.COUNT > 0
        THEN
            FOR i IN l_output_dates_tbl.FIRST..l_output_dates_tbl.LAST
            LOOP
                IF l_output_dates_tbl.EXISTS(i)
                THEN
                    SELECT jta_task_exclusions_s.NEXTVAL
                      INTO l_task_exclusion_id
                      FROM DUAL;

                    IF TRUNC(l_output_dates_tbl(i)) = l_output_dates_tbl(i) AND
                       l_time <> '00:00:00'
                    THEN
                        l_exclusion_date := TO_DATE(TO_CHAR(l_output_dates_tbl(i),'YYYY/MM/DD')||' '||l_time
                                                   ,'YYYY/MM/DD HH24:MI:SS');
                    ELSE
                        l_exclusion_date := l_output_dates_tbl(i);
                    END IF;

                    jta_task_exclusions_pkg.insert_row (
                        p_task_exclusion_id  => l_task_exclusion_id,
                        p_task_id            => 0-i,
                        p_recurrence_rule_id => rec_recur.recurrence_rule_id,
                        p_exclusion_date     => l_exclusion_date,
                        p_created_by         => rec_recur.created_by
                    );

                    l_num := l_num + 1;

                    COMMIT;
                END IF; -- l_output_dates_tbl.EXISTS(i)
            END LOOP; -- FOR i
        END IF; -- l_output_dates_tbl.COUNT > 0

    END LOOP; -- c_recur

    COMMIT WORK;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20001, 'Unexpected error at jtftkugb.pls (update_invalid_repeating_appts) : '||SQLERRM(SQLCODE));
END update_invalid_repeating_appts;

PROCEDURE initialize_object_changed_date
IS
    -- Added hint by SBARAT on 14/02/2006 for perf bug# 4965969
    CURSOR c_tasks IS
    SELECT /*+ parallel(b) */ b.rowid row_id
      FROM jtf_tasks_b b
     WHERE b.object_changed_date IS NULL;

    l_num NUMBER := 0;
    l_commit_records NUMBER := 0;
    l_commit_checkpoint NUMBER := 1000;
BEGIN
    IF NOT is_repeating_appt() THEN
       RETURN;
    END IF;

    ----------------------------------------------------------------------------
    -- Update object_changed_date with 02-Jan-1970
    ----------------------------------------------------------------------------
    FOR rec_tasks IN c_tasks
    LOOP
        UPDATE jtf_tasks_b
           SET object_changed_date = TO_DATE('01/02/1970', 'MM/DD/YYYY')
             , last_updated_by = fnd_global.user_id
         WHERE rowid = rec_tasks.row_id;

        l_num := l_num + 1;

        IF (l_num - l_commit_records) = l_commit_checkpoint
        THEN
            COMMIT;
            l_commit_records := l_commit_records + l_commit_checkpoint;
        END IF;

    END LOOP;

    COMMIT WORK;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20001, 'Unexpected error at jtftkugb.pls (initialize_object_changed_date) : '||SQLCODE||' '||SQLERRM);
END initialize_object_changed_date;

PROCEDURE exclude_modified_repeat_appts
IS
    -- Added hint by SBARAT on 14/02/2006 for perf bug# 4965969
    CURSOR c_updated_appts IS
    SELECT /*+ parallel(t) */ t.task_id
         , t.recurrence_rule_id
         , t.calendar_start_date
         , t.created_by
         , t.deleted_flag
         , recur.creation_date recur_creation_date
      FROM jtf_tasks_b t
         , jtf_task_recur_rules recur
     WHERE ((t.creation_date <> t.last_update_date AND
             t.last_update_date > recur.creation_date
             ) OR
            deleted_flag = 'Y')
       AND t.recurrence_rule_id = recur.recurrence_rule_id
       AND t.source_object_type_code = 'APPOINTMENT'
       AND (t.object_changed_date = to_date('01/02/1970','MM/DD/YYYY') OR
            t.object_changed_date IS NULL)
    ORDER BY t.calendar_start_date, t.task_id;

    CURSOR c_duplicate_dates (b_recurrence_rule_id NUMBER
                             --,b_recur_creation_date DATE
                             ,b_calendar_start_date DATE
                             ,b_task_id NUMBER) IS
    SELECT task_id
      FROM jtf_tasks_b
     WHERE recurrence_rule_id = b_recurrence_rule_id
       AND calendar_start_date = b_calendar_start_date
       AND task_id <> b_task_id;

    CURSOR c_recur (b_recurrence_rule_id NUMBER) IS
    SELECT recurrence_rule_id
         , occurs_which
         , day_of_week
         , date_of_month
         , occurs_number
         , occurs_month
         , occurs_uom
         , occurs_every
         , start_date_active
         , end_date_active
         , sunday
         , monday
         , tuesday
         , wednesday
         , thursday
         , friday
         , saturday
         , created_by
      FROM jtf_task_recur_rules
     WHERE recurrence_rule_id = b_recurrence_rule_id;

    rec_duplicate_dates  c_duplicate_dates%ROWTYPE;
    rec_recur  c_recur%ROWTYPE;

    notfound_recur_rule EXCEPTION;
    l_recurrence_rule_id NUMBER;

    l_output_dates_tbl     jtf_task_recurrences_pvt.output_dates_rec;
    l_output_dates_counter INTEGER;

    l_updated BOOLEAN;
    l_duplicate_found BOOLEAN;
    l_start_date_or_extra_modified BOOLEAN;

    l_task_exclusion_id NUMBER;

    l_num NUMBER := 0;
    l_commit_records NUMBER := 0;
    l_commit_checkpoint NUMBER := 1000;
BEGIN
    IF NOT is_repeating_appt() THEN
       RETURN;
    END IF;

    ----------------------------------------------------------------------------
    --    For all the modified occurrences,
    --       - Nullify recurrence_rule_id
    --       - Insert into exclusion table
    --    For all the deleted occurrences
    --       - Insert into exclusion table
    ----------------------------------------------------------------------------
    FOR rec_updated_appts IN c_updated_appts
    LOOP
        l_updated := FALSE;
        l_duplicate_found := FALSE;
        l_start_date_or_extra_modified := TRUE;

        -------------------------------------------------------------
        -- Check duplicate dates among unchanged records.
        -- This is the duplication made by an end user.
        -------------------------------------------------------------
        OPEN c_duplicate_dates(rec_updated_appts.recurrence_rule_id
                              --,rec_updated_appts.recur_creation_date
                              ,rec_updated_appts.calendar_start_date
                              ,rec_updated_appts.task_id);
        FETCH c_duplicate_dates INTO rec_duplicate_dates;
        IF c_duplicate_dates%FOUND
        THEN
            l_duplicate_found := TRUE;
        END IF;
        CLOSE c_duplicate_dates;

        -------------------------------------------------------------
        -- Get recurrence rule
        -------------------------------------------------------------
        OPEN c_recur (rec_updated_appts.recurrence_rule_id);
        FETCH c_recur INTO rec_recur;
        IF c_recur%NOTFOUND
        THEN
            l_recurrence_rule_id := rec_updated_appts.recurrence_rule_id;
            CLOSE c_recur;
            raise notfound_recur_rule;
        END IF;
        CLOSE c_recur;

        -------------------------------------------------------------
        -- Generate repeating dates
        -------------------------------------------------------------
        jtf_task_recurrences_pvt.generate_dates (
            p_occurs_which         => rec_recur.occurs_which,
            p_day_of_week          => rec_recur.day_of_week,
            p_date_of_month        => rec_recur.date_of_month,
            p_occurs_month         => rec_recur.occurs_month,
            p_occurs_uom           => rec_recur.occurs_uom,
            p_occurs_every         => rec_recur.occurs_every,
            p_occurs_number        => NULL,
            p_start_date           => rec_recur.start_date_active,
            p_end_date             => rec_recur.end_date_active,
            x_output_dates_tbl     => l_output_dates_tbl,
            x_output_dates_counter => l_output_dates_counter,
            p_sunday               => rec_recur.sunday,
            p_monday               => rec_recur.monday,
            p_tuesday              => rec_recur.tuesday,
            p_wednesday            => rec_recur.wednesday,
            p_thursday             => rec_recur.thursday,
            p_friday               => rec_recur.friday,
            p_saturday             => rec_recur.saturday
        );

        IF l_output_dates_tbl.COUNT > 0
        THEN
            FOR i IN l_output_dates_tbl.FIRST..l_output_dates_tbl.LAST
            LOOP
                IF TRUNC(rec_updated_appts.calendar_start_date) = TRUNC(l_output_dates_tbl(i))
                THEN
                    l_start_date_or_extra_modified := FALSE;
                    EXIT;
                END IF;
            END LOOP;
        END IF; -- l_output_dates_tbl.COUNT > 0

        -----------------------------------------------------------------------
        -- If rec_updated_appts.calendar_start_date has a unchanged duplicate one,
        --    we don't make an exclusion for this.
        -- We assume this duplication was caused because the start date has
        --    been updated by an end user.
        -- If this duplication has been made by a bug in recurrence API,
        --   the records would have been nullified by the script "jtftkugb.sql"
        -- The script "jtftkugb.sql" will encounter the missing dates
        --   for the records whose the start date has been changed.
        -- And the script will make exclusions for those missing dates.
        -----------------------------------------------------------------------

        -- The following "if" means
        --    that the appointment start date has been changed and has not been duplicated
        IF NOT (l_duplicate_found OR l_start_date_or_extra_modified)
        THEN
            SELECT jta_task_exclusions_s.NEXTVAL
              INTO l_task_exclusion_id
              FROM DUAL;

            jta_task_exclusions_pkg.insert_row (
                p_task_exclusion_id  => l_task_exclusion_id,
                p_task_id            => rec_updated_appts.task_id,
                p_recurrence_rule_id => rec_updated_appts.recurrence_rule_id,
                p_exclusion_date     => rec_updated_appts.calendar_start_date,
                p_created_by         => rec_updated_appts.created_by
            );

            l_updated := TRUE;
        END IF;

        -- If this has not been deleted, nullify recurrence rule
        IF NVL(rec_updated_appts.deleted_flag,'N') = 'N'
        THEN
            UPDATE jtf_tasks_b
               SET recurrence_rule_id = NULL
                 , last_updated_by = fnd_global.user_id
             WHERE task_id = rec_updated_appts.task_id;

            l_updated := TRUE;
        END IF;

        -- If this record is altered, check the commit check point
        IF l_updated
        THEN
            l_num := l_num + 1;

            IF (l_num - l_commit_records) = l_commit_checkpoint
            THEN
                COMMIT;
                l_commit_records := l_commit_records + l_commit_checkpoint;
            END IF;
        END IF;

    END LOOP;

    COMMIT WORK;
EXCEPTION
    WHEN notfound_recur_rule THEN
        ROLLBACK;
        raise_application_error(-20001, 'Unexpected error at jtftkugb.pls (exclude_modified_repeat_appts) : recurrence_rule_id '||l_recurrence_rule_id||'is not found in the table JTF_TASK_RECUR_RULES.');

    WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20001, 'Unexpected error at jtftkugb.pls (exclude_modified_repeat_appts) : '||SQLCODE||' '||SQLERRM);
END exclude_modified_repeat_appts;

PROCEDURE correct_recurrence_rule
IS
    CURSOR c_recur IS
    SELECT *
      FROM jtf_task_recur_rules r
     WHERE (end_date_active IS NULL OR occurs_number IS NULL)
       AND EXISTS (SELECT 1
                     FROM jtf_tasks_b t
                    WHERE t.source_object_type_code = 'APPOINTMENT'
                      AND t.recurrence_rule_id = r.recurrence_rule_id);

    l_output_dates_tbl     jtf_task_recurrences_pvt.output_dates_rec;
    l_output_dates_counter INTEGER;
    l_max_date DATE;
    l_occurs_number NUMBER;

    l_num NUMBER := 0;
    l_commit_records NUMBER := 0;
    l_commit_checkpoint NUMBER := 1000;
BEGIN
    IF NOT is_repeating_appt() THEN
       RETURN;
    END IF;

    ----------------------------------------------------------------------------
    -- Update end_date_active in jtf_task_recur_rules with the last one of dates
    --        which is generated by jtf_task_recurrences_pvt.generate_dates().
    ----------------------------------------------------------------------------
    FOR rec_recur IN c_recur
    LOOP
        jtf_task_recurrences_pvt.generate_dates (
            p_occurs_which         => rec_recur.occurs_which,
            p_day_of_week          => rec_recur.day_of_week,
            p_date_of_month        => rec_recur.date_of_month,
            p_occurs_month         => rec_recur.occurs_month,
            p_occurs_uom           => rec_recur.occurs_uom,
            p_occurs_every         => rec_recur.occurs_every,
            p_occurs_number        => rec_recur.occurs_number,
            p_start_date           => rec_recur.start_date_active,
            p_end_date             => rec_recur.end_date_active,
            x_output_dates_tbl     => l_output_dates_tbl,
            x_output_dates_counter => l_output_dates_counter,
            p_sunday               => rec_recur.sunday,
            p_monday               => rec_recur.monday,
            p_tuesday              => rec_recur.tuesday,
            p_wednesday            => rec_recur.wednesday,
            p_thursday             => rec_recur.thursday,
            p_friday               => rec_recur.friday,
            p_saturday             => rec_recur.saturday
        );

        l_occurs_number := l_output_dates_tbl.COUNT;

        IF l_output_dates_tbl.COUNT > 0
        THEN
            -------------------------------------------------------
            -- Find the repeating end date from l_output_dates_tbl
            -------------------------------------------------------
            l_max_date := l_output_dates_tbl(l_output_dates_tbl.FIRST);
            FOR i IN l_output_dates_tbl.FIRST..l_output_dates_tbl.LAST
            LOOP
                IF l_max_date < l_output_dates_tbl(i)
                THEN
                    l_max_date := l_output_dates_tbl(i);
                END IF;
            END LOOP;

            UPDATE jtf_task_recur_rules
               SET occurs_number = l_occurs_number
                 , end_date_active = l_max_date
                 , last_updated_by = fnd_global.user_id
             WHERE recurrence_rule_id = rec_recur.recurrence_rule_id;

            l_num := l_num + 1;

            IF (l_num - l_commit_records) = l_commit_checkpoint
            THEN
                COMMIT;
                l_commit_records := l_commit_records + l_commit_checkpoint;
            END IF;
        END IF;
    END LOOP;

    COMMIT WORK;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20001, 'Unexpected error at jtftkugb.pls (correct_recurrence_rule) : '||SQLCODE||' '||SQLERRM);
END correct_recurrence_rule;

PROCEDURE reset_assignment_status
IS
    -- Added hint by SBARAT on 14/02/2006 for perf bug# 4965969
    CURSOR c_appt_with_mixed_status IS
    SELECT DISTINCT
           t.task_id
         , a.task_assignment_id
      FROM jtf_task_all_assignments a
         , jtf_tasks_b t
         , (SELECT /*+ parallel(jtb) */ jtb.recurrence_rule_id
                 , jtaa.resource_id
                 , SUM(decode(jtaa.assignment_status_id, 3,  1, 0)) num_of_accept
                 , SUM(decode(jtaa.assignment_status_id, 4,  1, 0)) num_of_reject
                 , SUM(decode(jtaa.assignment_status_id, 18, 1, 0)) num_of_invitee
              FROM jtf_task_all_assignments jtaa
                 , jtf_tasks_b jtb
             WHERE jtb.recurrence_rule_id IS NOT NULL
               AND jtb.source_object_type_code = 'APPOINTMENT'
               AND jtaa.task_id = jtb.task_id
               AND jtaa.assignee_role = 'ASSIGNEE'
               AND jtaa.assignment_status_id IN (18, 3, 4)
            HAVING NOT
                   ((SUM(decode(jtaa.assignment_status_id, 3,  1, 0)) > 0 AND SUM(decode(jtaa.assignment_status_id, 4,  1, 0)) = 0 AND SUM(decode(jtaa.assignment_status_id, 18,  1, 0)) = 0) OR
                    (SUM(decode(jtaa.assignment_status_id, 3,  1, 0)) = 0 AND SUM(decode(jtaa.assignment_status_id, 4,  1, 0)) > 0 AND SUM(decode(jtaa.assignment_status_id, 18,  1, 0)) = 0) OR
                    (SUM(decode(jtaa.assignment_status_id, 3,  1, 0)) = 0 AND SUM(decode(jtaa.assignment_status_id, 4,  1, 0)) = 0 AND SUM(decode(jtaa.assignment_status_id, 18,  1, 0)) > 0))
            GROUP BY jtb.recurrence_rule_id, jtaa.resource_id
            ORDER BY jtb.recurrence_rule_id, jtaa.resource_id
           ) m
     WHERE t.recurrence_rule_id = m.recurrence_rule_id
       AND a.task_id = t.task_id
       AND a.resource_id = m.resource_id;

    l_num NUMBER := 0;
    l_commit_records NUMBER := 0;
    l_commit_checkpoint NUMBER := 1000;
BEGIN
    IF NOT is_repeating_appt() THEN
       RETURN;
    END IF;

    ----------------------------------------------------------------------------
    -- Find all appts having accept, reject and invitee together
    ----------------------------------------------------------------------------
    l_num := 0;
    FOR rec_appt_with_mixed_status IN c_appt_with_mixed_status
    LOOP
        l_num := l_num + 1;

        UPDATE jtf_task_all_assignments
           SET assignment_status_id = 18
             , last_updated_by = fnd_global.user_id
         WHERE task_assignment_id = rec_appt_with_mixed_status.task_assignment_id;

        IF (l_num - l_commit_records) = l_commit_checkpoint
        THEN
            COMMIT;
            l_commit_records := l_commit_records + l_commit_checkpoint;
        END IF;

    END LOOP;

    COMMIT WORK;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20001, 'Unexpected error at jtftkugb.pls (reset_assignment_status) : '||SQLCODE||' '||SQLERRM);
END reset_assignment_status;

PROCEDURE nullify_wrong_assignments
IS
    CURSOR c_recur IS
    SELECT *
      FROM jtf_task_recur_rules r
     WHERE EXISTS (SELECT 1
                     FROM jtf_tasks_b t
                    WHERE t.source_object_type_code = 'APPOINTMENT'
                      AND t.recurrence_rule_id = r.recurrence_rule_id);

    CURSOR c_assignees (b_recurrence_rule_id NUMBER
                       ,b_valid_count NUMBER) IS
    SELECT a.resource_id
         , a.resource_type_code
         , count(a.task_assignment_id)
      FROM jtf_task_all_assignments a
         , jtf_tasks_b t
     WHERE t.recurrence_rule_id = b_recurrence_rule_id
       AND t.source_object_type_code = 'APPOINTMENT'
       AND (t.object_changed_date = to_date('01/02/1970','MM/DD/YYYY') OR
            t.object_changed_date IS NULL)
       AND a.task_id = t.task_id
       AND a.assignee_role = 'ASSIGNEE'
     HAVING count(a.task_assignment_id) < b_valid_count
     GROUP BY a.resource_id, a.resource_type_code
     ORDER BY a.resource_id, a.resource_type_code;

    rec_assignees          c_assignees%ROWTYPE;

    l_output_dates_tbl     jtf_task_recurrences_pvt.output_dates_rec;
    l_output_dates_counter INTEGER;
    l_max_date DATE;

    l_num NUMBER := 0;
    l_commit_records NUMBER := 0;
    l_commit_checkpoint NUMBER := 1000;
BEGIN
    IF NOT is_repeating_appt() THEN
       RETURN;
    END IF;

    ----------------------------------------------------------------------------
    -- Find all appts having accept, reject and invitee together
    ----------------------------------------------------------------------------
    FOR rec_recur IN c_recur
    LOOP
        jtf_task_recurrences_pvt.generate_dates (
            p_occurs_which         => rec_recur.occurs_which,
            p_day_of_week          => rec_recur.day_of_week,
            p_date_of_month        => rec_recur.date_of_month,
            p_occurs_month         => rec_recur.occurs_month,
            p_occurs_uom           => rec_recur.occurs_uom,
            p_occurs_every         => rec_recur.occurs_every,
            p_occurs_number        => NULL,
            p_start_date           => rec_recur.start_date_active,
            p_end_date             => rec_recur.end_date_active,
            x_output_dates_tbl     => l_output_dates_tbl,
            x_output_dates_counter => l_output_dates_counter,
            p_sunday               => rec_recur.sunday,
            p_monday               => rec_recur.monday,
            p_tuesday              => rec_recur.tuesday,
            p_wednesday            => rec_recur.wednesday,
            p_thursday             => rec_recur.thursday,
            p_friday               => rec_recur.friday,
            p_saturday             => rec_recur.saturday
        );

        OPEN c_assignees (rec_recur.recurrence_rule_id, l_output_dates_tbl.COUNT);
        FETCH c_assignees INTO rec_assignees;

        IF c_assignees%FOUND
        THEN
            l_num := l_num + 1;

            UPDATE jtf_tasks_b
               SET recurrence_rule_id = NULL
                 , last_updated_by = fnd_global.user_id
             WHERE recurrence_rule_id = rec_recur.recurrence_rule_id
               AND NVL(deleted_flag,'N') <> 'Y';

            IF (l_num - l_commit_records) = l_commit_checkpoint
            THEN
                COMMIT;
                l_commit_records := l_commit_records + l_commit_checkpoint;
            END IF;
        END IF;

        CLOSE c_assignees;

    END LOOP;

    COMMIT WORK;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20001, 'Unexpected error at jtftkugb.pls (nullify_wrong_assignments) : '||SQLCODE||' '||SQLERRM);
END nullify_wrong_assignments;

END JTF_TASK_SYNC_UPGRADE_PKG;

/
