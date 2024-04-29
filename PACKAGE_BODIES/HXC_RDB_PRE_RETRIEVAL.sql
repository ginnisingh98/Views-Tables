--------------------------------------------------------
--  DDL for Package Body HXC_RDB_PRE_RETRIEVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RDB_PRE_RETRIEVAL" AS
/* $Header: hxcrdbpreret.pkb 120.0.12010000.16 2010/04/29 11:59:26 asrajago noship $ */


PROCEDURE go(p_application   IN VARCHAR2,
             p_start_date    IN VARCHAR2 DEFAULT NULL,
             p_end_date      IN VARCHAR2 DEFAULT NULL,
             p_payroll_id    IN NUMBER   DEFAULT NULL,
             p_gre_id        IN NUMBER   DEFAULT NULL,
             p_org_id        IN NUMBER   DEFAULT NULL,
             p_person_id     IN NUMBER   DEFAULT NULL,
             p_cutoff        IN VARCHAR2 DEFAULT NULL,
             p_changes_since IN VARCHAR2 DEFAULT NULL,
             p_msg           OUT NOCOPY VARCHAR2,
             p_level         OUT NOCOPY VARCHAR2
             )
IS

-- Bug 9626200
-- Added this dynamic cursor text to enable search for PA
-- application also.
  l_pa_sql VARCHAR2(32000) :=

'SELECT DISTINCT ret.resource_id,
                sum.timecard_id,
                sum.approval_status,
                sum.start_time,
                TRUNC(sum.stop_time),
    		FIRST_VALUE(ret.time_building_block_id)
                      OVER (PARTITION BY ret.timecard_id
			        ORDER BY ret.last_update_date DESC,
			                 ret.time_building_block_id DESC),
    		FIRST_VALUE(ret.object_version_number)
                      OVER (PARTITION BY ret.timecard_id
		                ORDER BY ret.last_update_date DESC,
		                         ret.time_building_block_id DESC),
    		FIRST_VALUE(ret.last_update_date)
                      OVER (PARTITION BY ret.timecard_id
		                ORDER BY ret.last_update_date DESC,
		                         ret.time_building_block_id DESC)
           FROM hxc_pa_latest_details ret,
                hxc_timecard_summary sum
          WHERE ret.last_update_date >= FND_DATE.canonical_to_date(:SINCEDATE)
            AND ret.timecard_id = sum.timecard_id
            AND ret.org_id      = :ORGID ';


   l_pay_sql   VARCHAR2(32000) :=
'SELECT DISTINCT ret.resource_id,
                sum.timecard_id,
                sum.approval_status,
                sum.start_time,
                TRUNC(sum.stop_time),
   	        FIRST_VALUE(ret.time_building_block_id)
                      OVER (PARTITION BY ret.timecard_id
		                ORDER BY ret.last_update_date DESC,
		                         ret.time_building_block_id DESC),
    		FIRST_VALUE(ret.object_version_number)
                      OVER (PARTITION BY ret.timecard_id
		                ORDER BY ret.last_update_date DESC,
		                         ret.time_building_block_id DESC),
    		FIRST_VALUE(ret.last_update_date)
                      OVER (PARTITION BY ret.timecard_id
		                ORDER BY ret.last_update_date DESC,
		                         ret.time_building_block_id DESC)
           FROM hxc_pay_latest_details ret,
                hxc_timecard_summary sum
          WHERE ret.timecard_id = sum.timecard_id
            AND ret.business_group_id = BUSINESSID ';

   l_pay_asg   VARCHAR2(3000) :=
'AND EXISTS ( SELECT 1
                FROM per_all_assignments_f paf
               WHERE paf.person_id = ret.resource_id
                 AND ret.start_time BETWEEN paf.effective_start_date
                                       AND paf.effective_end_date
                 PAYROLLCRITERIA
                 ORGCRITERIA
                 GRECRITERIA  )';



l_pay_cursor  SYS_REFCURSOR;
l_pa_cursor   SYS_REFCURSOR;
restab        NUMBERTAB;
tctab         NUMBERTAB;
stattab       VARCHARTAB;
starttab      DATETAB;
stoptab       DATETAB;
dettab        NUMBERTAB;
ovntab        NUMBERTAB;
ludtab        DATETAB;
l_level       VARCHAR2(50);

       PROCEDURE update_last_touched
       IS

          CURSOR get_last_touched
              IS SELECT det.last_updated_by,
                        ROWIDTOCHAR(rdb.rowid)
                   FROM hxc_rdb_pre_timecards rdb,
                        hxc_time_building_blocks det,
                        fnd_user fnd
                  WHERE rdb.ret_user_id = FND_GLOBAL.user_id
                    AND rdb.lu_bb_id = det.time_building_block_id
                    AND rdb.lu_ovn   = det.object_version_number
                    AND det.last_updated_by = fnd.user_id
                    AND fnd.employee_id <> det.resource_id
                   ;

           usertab VARCHARTAB;
           rowtab  VARCHARTAB;
        BEGIN
             OPEN get_last_touched;
             LOOP
                FETCH get_last_touched BULK COLLECT INTO usertab,
                                                         rowtab LIMIT 1000;
                EXIT WHEN usertab.COUNT = 0;

                FORALL i IN usertab.FIRST..usertab.LAST
                   UPDATE hxc_rdb_pre_timecards
                      SET last_updated_by = usertab(i)
                    WHERE rowid = CHARTOROWID(rowtab(i));

               COMMIT;
             END LOOP;

         END update_last_touched;


         PROCEDURE update_supervisor
         IS

             CURSOR get_supervisor
                 IS SELECT paf.supervisor_id,
                           ROWIDTOCHAR(tc.rowid)
                      FROM hxc_rdb_pre_timecards tc,
                           per_all_assignments_f paf
                     WHERE tc.ret_user_id = FND_GLOBAL.user_id
                       AND tc.resource_id = paf.person_id
                       AND tc.start_time BETWEEN paf.effective_start_date
                                             AND paf.effective_end_date;

             suptab  NUMBERTAB;
             rowtab  VARCHARTAB;

         BEGIN
             OPEN get_supervisor;
             LOOP
                 FETCH get_supervisor BULK COLLECT INTO suptab,
                                                        rowtab LIMIT 500;
                 EXIT WHEN suptab.COUNT = 0;

                 FORALL i IN suptab.FIRST..suptab.LAST
                   UPDATE hxc_rdb_pre_timecards
                      SET supervisor_id = suptab(i)
                    WHERE ROWID = CHARTOROWID(rowtab(i));
                 COMMIT;
             END LOOP;

         END update_supervisor;


         PROCEDURE update_emp_details
         IS

              CURSOR get_emp_name
                  IS SELECT ppf.full_name,
                            DECODE(ppf.current_npw_flag,'Y',
                                                        ppf.npw_number,
                                                        ppf.employee_number),
                           ROWIDTOCHAR(rdb.rowid)
                       FROM hxc_rdb_pre_timecards rdb,
                            per_all_people_f ppf
                       WHERE SYSDATE BETWEEN ppf.effective_start_date
                                       AND ppf.effective_end_date
                       AND rdb.resource_id = ppf.person_id
                       AND rdb.ret_user_id = FND_GLOBAL.user_id;

              nametab  VARCHARTAB;
              notab    VARCHARTAB;
              rowtab    VARCHARTAB;

         BEGIN
                OPEN get_emp_name;
                LOOP
                    FETCH get_emp_name BULK COLLECT INTO nametab,
                                                         notab,
                                                             rowtab LIMIT 500;
                    EXIT WHEN nametab.COUNT = 0;

                    FORALL i IN nametab.FIRST..nametab.LAST
                      UPDATE hxc_rdb_pre_timecards
                         SET emp_name = nametab(i),
                             emp_no   = notab(i)
                       WHERE rowid = chartorowid(rowtab(i));

                     COMMIT;

                 END LOOP;
                 CLOSE get_emp_name;


         END update_emp_details;


         PROCEDURE pick_up_details(p_application  IN VARCHAR2)
         IS

         l_details   VARCHAR2(32000) :=
'SELECT ret.resource_id,
        ret.time_building_block_id,
        ret.object_version_number ovn,
        tc.approval_status,
        ret.timecard_id,
        ret.start_time date_worked,
        ret.attribute1,
        ret.attribute2,
        ret.attribute3,
        ret.measure,
        ret.attribute1
   from LATEST_DETAILS ret,
        hxc_rdb_pre_timecards tc
where ret.timecard_id = tc.timecard_id
  and tc.ret_user_id = USERID '
 ;

          l_ref_cursor SYS_REFCURSOR;
          restab  NUMBERTAB;
          bbtab   NUMBERTAB;
          ovntab  NUMBERTAB;
          stattab VARCHARTAB;
          tctab   NUMBERTAB;
          dwtab DATETAB;
          att1tab  VARCHARTAB;
          att2tab  VARCHARTAB;
          att3tab  VARCHARTAB;
          measuretab NUMBERTAB;
          hrspmtab   NUMBERTAB;

          BEGIN
               IF p_application = 'PA'
               THEN
                   l_details := REPLACE(l_details,'LATEST_DETAILS','HXC_PA_LATEST_DETAILS');
               ELSIF p_application = 'PAY'
               THEN
                   l_details := REPLACE(l_details,'LATEST_DETAILS','HXC_PAY_LATEST_DETAILS');
               END IF;
               l_details := REPLACE(l_details,'USERID',FND_GLOBAL.user_id);

               OPEN l_ref_cursor FOR l_details;
               LOOP
                  FETCH l_ref_cursor BULK COLLECT INTO restab,
                                                       bbtab,
                                                       ovntab,
                                                       stattab,
                                                       tctab,
                                                       dwtab,
                                                       att1tab,
                                                       att2tab,
                                                       att3tab,
                                                       measuretab,
                                                       hrspmtab LIMIT 500;
                   EXIT WHEN restab.count = 0;

                   FORALL i IN restab.FIRST..restab.LAST
                     INSERT INTO hxc_rdb_pre_details
                       (resource_id,
                        time_building_block_id,
                        ovn,
                        approval_status,
                        timecard_id,
                        date_worked,
                        attribute1,
                        attribute2,
                        attribute3,
                        measure,
                        hrs_pm,
                        ret_user_id )
                    VALUES
                       (  restab(i),
                                                       bbtab(i),
                                                       ovntab(i),
                                                       stattab(i),
                                                       tctab(i),
                                                       dwtab(i),
                                                       att1tab(i),
                                                       att2tab(i),
                                                       att3tab(i),
                                                       measuretab(i),
                                                       DECODE(p_application,'PA',hrspmtab(i),NULL),
                                                       FND_GLOBAL.user_id);

                      commit;
                 end loop;

            END pick_up_details;


            PROCEDURE summarize_statuses
            IS

            BEGIN
                INSERT
                  INTO hxc_rdb_pre_status
                      (approval_status,
                       timecards,
                       ret_user_id)
                SELECT approval_status,
                       count(timecard_id) Timecards,
                       FND_GLOBAL.user_id
                  FROM hxc_rdb_pre_timecards
                 WHERE ret_user_id = FND_GLOBAL.user_id
                 GROUP by approval_status
                  UNION
                 SELECT 'Total',count(*),
                       FND_GLOBAL.user_id
                  FROM hxc_rdb_pre_timecards
                 WHERE ret_user_id = FND_GLOBAL.user_id;
                COMMIT;

            END summarize_statuses;


            PROCEDURE summarize_attributes
            IS

            BEGIN
                INSERT
                  INTO hxc_rdb_pre_attributes
                      (approval_status,
                       attribute1,
                       attribute2,
                       attribute3,
                       measure,
                       ret_user_id)
                SELECT DISTINCT approval_status,
                       attribute1,
                       attribute2,
                       attribute3,
                       SUM(measure) OVER (PARTITION BY approval_status,
                                                       attribute1||
                                                       attribute2||
                                                       attribute3) measure,
                       FND_GLOBAL.user_id
                  FROM hxc_rdb_pre_details
                 WHERE ret_user_id = FND_GLOBAL.user_id
                       UNION
                       ALL
                SELECT DISTINCT 'Total' approval_status,
                       attribute1,
                       attribute2,
                       attribute3,
                       SUM(measure) OVER (PARTITION BY
                                                       attribute1||
                                                       attribute2||
                                                       attribute3) measure,
                       fnd_global.user_id
                  FROM hxc_rdb_pre_details
                 WHERE ret_user_id = FND_GLOBAL.user_id;
                COMMIT;

            END summarize_attributes;

            PROCEDURE summarize_hrs_pm(p_application  IN VARCHAR2)
            IS

            BEGIN
                IF p_application = 'PA'
                THEN
                    INSERT
                      INTO hxc_rdb_pre_hrs_pm
                           (approval_status,
                            hrs_pm,
                            timecards,
                            ret_user_id)
                    SELECT distinct approval_status,
                           hrs_pm,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY approval_status,
                                                                 hrs_pm) ,
                           fnd_global.user_id
                      FROM hxc_rdb_pre_details
                     WHERE ret_user_id = FND_GLOBAL.user_id
                           UNION
                           ALL
                    SELECT DISTINCT 'Total' approval_status,
                           hrs_pm,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY hrs_pm) measure,
                           fnd_global.user_id
                      FROM hxc_rdb_pre_details
                     WHERE ret_user_id = FND_GLOBAL.user_id;

                COMMIT;
                END IF;

                IF p_application = 'PAY'
                THEN
                    INSERT into hxc_rdb_pre_hrs_pm
                           (approval_status,
                            hrs_pm,
                            timecards,
                            ret_user_id)
                    SELECT DISTINCT approval_status,
                           supervisor_id,
                           COUNT(*) OVER (PARTITION BY approval_status,
                                                       supervisor_id) ,
                           FND_GLOBAL.user_id
                      FROM hxc_rdb_pre_timecards
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND supervisor_id IS NOT NULL
                      UNION
                        ALL
                     SELECT DISTINCT 'Total' approval_status,
                            supervisor_id,
                            COUNT(*) OVER (PARTITION BY supervisor_id),
                           FND_GLOBAL.user_id
                      FROM hxc_rdb_pre_timecards
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND supervisor_id IS NOT NULL;
                    COMMIT;
                END IF;

            END summarize_hrs_pm;

            PROCEDURE summarize_updated
            IS

            BEGIN
                INSERT
                  INTO hxc_rdb_pre_updated
                       (approval_status,
                        last_updated_by,
                       timecards,
                       ret_user_id)
                SELECT distinct approval_status,
                       last_updated_by,
                       COUNT(*) OVER (PARTITION BY approval_status,
                                                   last_updated_by) ,
                       FND_GLOBAL.user_id
                  FROM hxc_rdb_pre_timecards
                 WHERE ret_user_id = FND_GLOBAL.user_id
                   AND last_updated_by IS NOT NULL
                  UNION
                    ALL
                 SELECT distinct 'Total' approval_status,
                        last_updated_by,
                        COUNT(*) OVER (PARTITION BY last_updated_by),
                       FND_GLOBAL.user_id
                  FROM hxc_rdb_pre_timecards
                 WHERE ret_user_id = FND_GLOBAL.user_id
                   AND last_updated_by IS NOT NULL;
                COMMIT;

            END summarize_updated;

            PROCEDURE translate_hrs_pm(p_application  IN VARCHAR2)
            IS

             CURSOR get_proj_manager
                 IS SELECT ppf.full_name||'('||proj.name||')',
                           ppf.person_id,
                           ROWIDTOCHAR(rdb.rowid)
                      FROM hxc_rdb_pre_hrs_pm rdb,
                           PA_PROJECT_PARTIES         PPP  ,
                           PA_PROJECT_ROLE_TYPES_B     PPRT,
                           per_all_people_f           ppf,
                           pa_projects_all            proj
                     WHERE  PPP.PROJECT_ID                      = rdb.hrs_pm
                       AND rdb.ret_user_id = FND_GLOBAL.user_id
                       AND PPP.PROJECT_ROLE_ID                 = PPRT.PROJECT_ROLE_ID
                       AND PPRT.PROJECT_ROLE_TYPE              ='PROJECT MANAGER'
                       AND PPRT.role_party_class = 'PERSON'
                       AND SYSDATE BETWEEN ppf.effective_start_date
                                       AND ppf.effective_end_date
                       AND PPP.RESOURCE_SOURCE_ID = ppf.person_id
                       AND rdb.hrs_pm = proj.project_id
                       AND trunc(SYSDATE)  BETWEEN trunc(PPP.start_date_active)
                                               AND NVL(trunc(PPP.end_date_active),SYSDATE);

              CURSOR get_hrs_name
                  IS SELECT ppf.full_name,
                            ppf.person_id,
                           ROWIDTOCHAR(rdb.rowid)
                       FROM hxc_rdb_pre_hrs_pm rdb,
                            per_all_people_f ppf
                       WHERE SYSDATE BETWEEN ppf.effective_start_date
                                       AND ppf.effective_end_date
                       AND rdb.hrs_pm = ppf.person_id
                       AND rdb.ret_user_id = FND_GLOBAL.user_id;


              nametab   VARCHARTAB;
              idtab     NUMBERTAB;
              rowtab    VARCHARTAB;

            BEGIN
                IF p_application = 'PA'
                THEN
                OPEN get_proj_manager;
                LOOP
                    FETCH get_proj_manager BULK COLLECT INTO nametab,
                                                             idtab,
                                                             rowtab LIMIT 500;
                    EXIT WHEN nametab.COUNT = 0;

                    FORALL i IN nametab.FIRST..nametab.LAST
                      UPDATE hxc_rdb_pre_hrs_pm
                         SET hrs_pm_name = nametab(i),
                             resource_id = idtab(i)
                       WHERE rowid = chartorowid(rowtab(i));

                     COMMIT;

                 END LOOP;
                 CLOSE get_proj_manager;
                END IF;

                IF p_application = 'PAY'
                THEN
                OPEN get_hrs_name;
                LOOP
                    FETCH get_hrs_name BULK COLLECT INTO nametab,
                                                         idtab,
                                                         rowtab LIMIT 500;
                    EXIT WHEN nametab.COUNT = 0;

                    FORALL i IN nametab.FIRST..nametab.LAST
                      UPDATE hxc_rdb_pre_hrs_pm
                         SET hrs_pm_name = nametab(i),
                             resource_id = idtab(i)
                       WHERE ROWID = CHARTOROWID(rowtab(i));

                     COMMIT;

                 END LOOP;
                 CLOSE get_hrs_name;

                 END IF;


              END translate_hrs_pm;


              PROCEDURE translate_attributes(p_application  IN VARCHAR2)
              IS


                CURSOR get_projects
                    IS SELECT proj.name||' - '||
                              task.task_number||' - '||
                              rdb.attribute3,
                              ROWIDTOCHAR(rdb.rowid)
                         FROM hxc_rdb_pre_attributes rdb,
                              pa_projects_all proj,
                              pa_tasks task
                        WHERE rdb.ret_user_id = FND_GLOBAL.user_id
                          AND rdb.attribute1 = proj.project_id
                          AND rdb.attribute2 = task.task_id;

                CURSOR get_elements
                    IS SELECT pay.element_name,
                              ROWIDTOCHAR(rdb.rowid)
                         FROM hxc_rdb_pre_attributes rdb,
                              pay_element_types_f_tl pay
                        WHERE rdb.ret_user_id = FND_GLOBAL.user_id
                          AND pay.language = USERENV('LANG')
                          AND rdb.attribute1 = pay.element_type_id;

                 atttab  VARCHARTAB;
                 rowtab  VARCHARTAB;



               BEGIN

                   IF p_application = 'PA'
                   THEN
                      OPEN get_projects;
                      LOOP
                         FETCH get_projects BULK COLLECT INTO atttab,
                                                              rowtab LIMIT 500;
                         EXIT WHEN atttab.COUNT = 0;

                         FORALL i IN atttab.FIRST..atttab.LAST
                           UPDATE hxc_rdb_pre_attributes
                              SET attribute_name = atttab(i)
                            WHERE rowid = CHARTOROWID(rowtab(i));


                         COMMIT;

                      END LOOP;

                      CLOSE get_projects;

                   END IF;

                   IF p_application = 'PAY'
                   THEN
                      OPEN get_elements;
                      LOOP
                         FETCH get_elements BULK COLLECT INTO atttab,
                                                              rowtab LIMIT 500;
                         EXIT WHEN atttab.COUNT = 0;

                         FORALL i IN atttab.FIRST..atttab.LAST
                           UPDATE hxc_rdb_pre_attributes
                              SET attribute_name = atttab(i)
                            WHERE rowid = CHARTOROWID(rowtab(i));


                         COMMIT;

                      END LOOP;

                      CLOSE get_elements;

                   END IF;

               END translate_attributes;

               PROCEDURE translate_updated_by
               IS

                 CURSOR get_updated
                     IS SELECT ppf.full_name,
                               ppf.person_id,
                               ROWIDTOCHAR(rdb.rowid)
                          FROM hxc_rdb_pre_updated rdb,
                               fnd_user fnd,
                               per_all_people_f ppf
                         WHERE rdb.ret_user_id = FND_GLOBAL.user_id
                           AND rdb.last_updated_by = fnd.user_id
                           AND fnd.employee_id = ppf.person_id
                           AND SYSDATE BETWEEN ppf.effective_start_date
                                           AND ppf.effective_end_date;

                  nametab VARCHARTAB;
                  idtab   NUMBERTAB;
                  rowtab  VARCHARTAB;


                 BEGIN
                     OPEN get_updated;
                     LOOP
                         FETCH get_updated BULK COLLECT INTO nametab,
                                                             idtab,
                                                             rowtab LIMIT 500;
                         EXIT WHEN nametab.COUNT = 0;

                         FORALL i IN nametab.FIRST..nametab.LAST
                            UPDATE hxc_rdb_pre_updated
                               SET last_updated_name = nametab(i),
                                   resource_id       = idtab(i)
                              WHERE rowid = CHARTOROWID(rowtab(i));

                         COMMIT;
                     END LOOP;
               END translate_updated_by;


           PROCEDURE translate_skipped
           IS

              CURSOR get_emp_name
                  IS SELECT ppf.full_name,
                            DECODE(ppf.current_npw_flag,'Y',
                                                        ppf.npw_number,
                                                        ppf.employee_number),
                           ROWIDTOCHAR(rdb.rowid)
                       FROM hxc_rdb_pre_skipped rdb,
                            per_all_people_f ppf
                       WHERE SYSDATE BETWEEN ppf.effective_start_date
                                       AND ppf.effective_end_date
                       AND rdb.resource_id = ppf.person_id
                       AND rdb.ret_user_id = FND_GLOBAL.user_id;

              nametab  VARCHARTAB;
              notab    VARCHARTAB;
              rowtab    VARCHARTAB;

         BEGIN
                OPEN get_emp_name;
                LOOP
                    FETCH get_emp_name BULK COLLECT INTO nametab,
                                                         notab,
                                                             rowtab LIMIT 500;
                    EXIT WHEN nametab.COUNT = 0;

                    FORALL i IN nametab.FIRST..nametab.LAST
                      UPDATE hxc_rdb_pre_skipped
                         SET emp_name = nametab(i),
                             emp_no   = notab(i)
                       WHERE rowid = chartorowid(rowtab(i));

                     COMMIT;

                 END LOOP;
                 CLOSE get_emp_name;

          END translate_skipped;




BEGIN

     -- Bug 9654164
     -- Added this code snippet to manage the validity of
     -- this or other sessions by the same user.
     l_level := validate_current_session;
     IF l_level = 'ERROR'
     THEN
        p_msg := 'HXC_RDB_INVALID_SESSION_ERR';
        p_level := 'ERROR';
     ELSIF l_level = 'WARNING'
     THEN
        p_msg := 'HXC_RDB_STALE_SESSIONS_WRN';
        p_level := 'WARNING';
     END IF;

     clear_old_data;
     IF p_application = 'PA'
     THEN
        IF p_org_id IS NOT NULL
        THEN
           l_pa_sql := l_pa_sql||l_pay_asg;
           l_pa_sql := REPLACE(l_pa_sql,'PAYROLLCRITERIA');
           l_pa_sql := REPLACE(l_pa_sql,'GRECRITERIA');
           l_pa_sql := REPLACE(l_pa_sql,'ORGCRITERIA','AND paf.organization_id = '||p_org_id||' ');

        END IF;
        IF p_person_id IS NOT NULL
        THEN
           l_pa_sql := l_pa_sql||' AND ret.resource_id = '||p_person_id;
        END IF;

        IF p_start_date IS NOT NULL
        THEN
           l_pa_sql := l_pa_sql||' AND sum.start_time >= fnd_date.canonical_to_date('''||
                               fnd_date.date_to_canonical(TO_DATE(p_start_date,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'))
                                                            )||''') ';
        END IF;

        IF p_end_date IS NOT NULL
        THEN
           l_pa_sql := l_pa_sql||' AND TRUNC(sum.stop_time) <= fnd_date.canonical_to_date('''||
                              fnd_date.date_to_canonical(TO_DATE(p_end_date,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'))
                                                            )||''') ';
        END IF;


        OPEN l_pa_cursor FOR l_pa_sql
                         USING FND_DATE.date_to_canonical( SYSDATE-FND_PROFILE.VALUE('HXC_RETRIEVAL_CHANGES_DATE')),
                               NVL(Pa_Moac_Utils.Get_Current_Org_Id,FND_PROFILE.VALUE('ORG_ID'));
        LOOP
           FETCH l_pa_cursor BULK COLLECT INTO restab,
                                                  tctab,
                                                  stattab,
                                                  starttab,
                                                  stoptab,
                                                  dettab,
                                                  ovntab,ludtab LIMIT 500;
           EXIT WHEN restab.COUNT = 0;

           FORALL i IN restab.FIRST..restab.LAST
             INSERT INTO hxc_rdb_pre_timecards
               ( resource_id,
                 timecard_id,
                 approval_status,
                 start_time,
                 stop_time,
                 lu_bb_id,
                 lu_ovn,
                 last_update_date,
                 ret_user_id)
             VALUES (restab(i),
                     tctab(i),
                     stattab(i),
                     starttab(i),
                     stoptab(i),
                     dettab(i),
                     ovntab(i),ludtab(i),
                     FND_GLOBAL.user_id);

            COMMIT;
         END LOOP;

         CLOSE l_pa_cursor;


         l_pa_sql := REPLACE(l_pa_sql,'ret.last_update_date >= FND_DATE.canonical_to_date',
                                         'ret.last_update_date < FND_DATE.canonical_to_date');

        OPEN l_pa_cursor FOR l_pa_sql
                         USING FND_DATE.date_to_canonical( SYSDATE-FND_PROFILE.VALUE('HXC_RETRIEVAL_CHANGES_DATE')),
                               NVL(Pa_Moac_Utils.Get_Current_Org_Id,FND_PROFILE.VALUE('ORG_ID'));

        LOOP
           FETCH l_pa_cursor BULK COLLECT INTO restab,
                                                  tctab,
                                                  stattab,
                                                  starttab,
                                                  stoptab,
                                                  dettab,
                                                  ovntab,ludtab LIMIT 500;
           EXIT WHEN restab.COUNT = 0;

           FORALL i IN restab.FIRST..restab.LAST
             INSERT INTO hxc_rdb_pre_skipped
               ( resource_id,
                 timecard_id,
                 approval_status,
                 start_time,
                 stop_time,
                 ret_user_id)
             VALUES (restab(i),
                     tctab(i),
                     stattab(i),
                     starttab(i),
                     stoptab(i),
                     FND_GLOBAL.user_id);

            COMMIT;
         END LOOP;
         CLOSE l_pa_cursor;





       ELSIF p_application = 'PAY'
       THEN
           l_pay_sql := REPLACE(l_pay_sql,'BUSINESSID',FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'));

           IF p_start_date IS NOT NULL
           THEN
              l_pay_sql := l_pay_sql||' AND sum.start_time >= fnd_date.canonical_to_date('''||
                                 fnd_date.date_to_canonical(TO_DATE(p_start_date,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'))
                                                            )||''') ';
           END IF;
           IF p_end_date IS NOT NULL
           THEN
                            l_pay_sql := l_pay_sql||' AND TRUNC(sum.stop_time) <= fnd_date.canonical_to_date('''||
                                 fnd_date.date_to_canonical(TO_DATE(p_end_date,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'))
                                                            )||''') ';

           END IF;

           IF p_person_id IS NOT NULL
           THEN
              l_pay_sql := l_pay_sql||' AND ret.resource_id = '||p_person_id ;
           END IF;

           IF p_changes_since IS NOT NULL
           THEN
              l_pay_sql := l_pay_sql||' AND ret.last_update_date >= fnd_date.canonical_to_date('''||
                                 fnd_date.date_to_canonical(TO_DATE(p_changes_since,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'))
                                                            )||''') ';

           ELSE
              l_pay_sql := l_pay_sql||' AND ret.last_update_date >= fnd_date.canonical_to_date('''||
                                 fnd_date.date_to_canonical(SYSDATE-FND_PROFILE.VALUE('HXC_RETRIEVAL_CHANGES_DATE'))||''') ';
           END IF;


          IF COALESCE(p_payroll_id,p_gre_id,p_org_id) IS NOT NULL
          THEN
             l_pay_sql := l_pay_sql||l_pay_asg;
             IF p_payroll_id IS NOT NULL
             THEN
                l_pay_sql := REPLACE(l_pay_sql,'PAYROLLCRITERIA','AND paf.payroll_id = '||p_payroll_id||' ');
             ELSE
                l_pay_sql := REPLACE(l_pay_sql,'PAYROLLCRITERIA');
             END IF;
             IF p_org_id IS NOT NULL
             THEN
                l_pay_sql := REPLACE(l_pay_sql,'ORGCRITERIA','AND paf.organization_id = '||p_org_id||' ');
             ELSE
                l_pay_sql := REPLACE(l_pay_sql,'ORGCRITERIA');
             END IF;

             IF p_gre_id IS NOT NULL
             THEN
                l_pay_sql := REPLACE(l_pay_sql,'GRECRITERIA');
             ELSE
                l_pay_sql := REPLACE(l_pay_sql,'GRECRITERIA');
             END IF;

          END IF;


          OPEN l_pay_cursor FOR l_pay_sql;
          LOOP
             FETCH l_pay_cursor BULK COLLECT INTO restab,
                                                  tctab,
                                                  stattab,
                                                  starttab,
                                                  stoptab,
                                                  dettab,
                                                  ovntab,ludtab LIMIT 500;
           EXIT WHEN restab.COUNT = 0;

           FORALL i IN restab.FIRST..restab.LAST
             INSERT INTO hxc_rdb_pre_timecards
               ( resource_id,
                 timecard_id,
                 approval_status,
                 start_time,
                 stop_time,
                 lu_bb_id,
                 lu_ovn,
                 last_update_date,
                 ret_user_id)
             VALUES (restab(i),
                     tctab(i),
                     stattab(i),
                     starttab(i),
                     stoptab(i),
                     dettab(i),
                     ovntab(i),ludtab(i),
                     FND_GLOBAL.user_id);

            COMMIT;
         END LOOP;

        CLOSE l_pay_cursor;

          l_pay_sql := REPLACE(l_pay_sql,' AND ret.last_update_date >= fnd_date.canonical_to_date(',
                                         ' AND ret.last_update_date < fnd_date.canonical_to_date(');
          OPEN l_pay_cursor FOR l_pay_sql;
          LOOP
             FETCH l_pay_cursor BULK COLLECT INTO restab,
                                                  tctab,
                                                  stattab,
                                                  starttab,
                                                  stoptab,
                                                  dettab,
                                                  ovntab,ludtab LIMIT 500;
           EXIT WHEN restab.COUNT = 0;

           FORALL i IN restab.FIRST..restab.LAST
             INSERT INTO hxc_rdb_pre_skipped
               ( resource_id,
                 timecard_id,
                 approval_status,
                 start_time,
                 stop_time,
                 ret_user_id)
             VALUES (restab(i),
                     tctab(i),
                     stattab(i),
                     starttab(i),
                     stoptab(i),
                     FND_GLOBAL.user_id);

            COMMIT;
         END LOOP;




       END IF;

       update_last_touched;
       update_supervisor;
       update_emp_details;
       pick_up_details(p_application);
       summarize_statuses;
       summarize_attributes;
       summarize_hrs_pm(p_application);
       summarize_updated;
       translate_hrs_pm(p_application);
       translate_attributes(p_application);
       translate_updated_by;
       translate_skipped;




END go;


PROCEDURE unlock
IS

    CURSOR pick_lock_rowid
        IS SELECT ROWIDTOCHAR(loc.rowid)
             FROM hxc_rdb_pre_timecards rdb,
                  hxc_locks loc
            WHERE rdb.resource_id = loc.resource_id
              AND rdb.start_time = loc.start_time
              AND TRUNC(rdb.stop_time) = TRUNC(loc.stop_time)
              AND lock_date <= SYSDATE - (1/48);

    rowtab  VARCHARTAB;

BEGIN

    OPEN pick_lock_rowid;
    LOOP
       FETCH pick_lock_rowid BULK COLLECT INTO rowtab LIMIT 500;
       EXIT WHEN rowtab.COUNT = 0;

       FORALL i IN rowtab.FIRST..rowtab.LAST
         DELETE FROM HXC_LOCKS
               WHERE ROWID = CHARTOROWID(rowtab(i));
       COMMIT;
    END LOOP;


    CLOSE pick_lock_rowid;

END unlock;

PROCEDURE clear_old_data
IS

      CURSOR get_old_timecards
          IS SELECT ROWIDTOCHAR(rowid)
               FROM hxc_rdb_pre_timecards
              WHERE ret_user_id = FND_GLOBAL.user_id;

      CURSOR get_old_details
          IS SELECT ROWIDTOCHAR(rowid)
               FROM hxc_rdb_pre_details
              WHERE ret_user_id = FND_GLOBAL.user_id;

       rowtab  VARCHARTAB;

BEGIN
    OPEN get_old_timecards;
    LOOP
       FETCH get_old_timecards BULK COLLECT INTO rowtab LIMIT 500;
       EXIT WHEN rowtab.COUNT = 0;

       FORALL i IN rowtab.FIRST..rowtab.LAST
        DELETE FROM hxc_rdb_pre_timecards
              WHERE ROWID = CHARTOROWID(rowtab(i));

       COMMIT;

    END LOOP;
    CLOSE get_old_timecards;

    OPEN get_old_details;
    LOOP
       FETCH get_old_details BULK COLLECT INTO rowtab LIMIT 500;
       EXIT WHEN rowtab.COUNT = 0;

       FORALL i IN rowtab.FIRST..rowtab.LAST
        DELETE FROM hxc_rdb_pre_details
              WHERE ROWID = CHARTOROWID(rowtab(i));

       COMMIT;

    END LOOP;
    CLOSE get_old_details;


    DELETE FROM hxc_rdb_pre_status
          WHERE ret_user_id = FND_GLOBAL.user_id;

    DELETE FROM hxc_rdb_pre_attributes
          WHERE ret_user_id = FND_GLOBAL.user_id;

    DELETE FROM hxc_rdb_pre_hrs_pm
          WHERE ret_user_id = FND_GLOBAL.user_id;

    DELETE FROM hxc_rdb_pre_updated
          WHERE ret_user_id = FND_GLOBAL.user_id;

    DELETE FROM hxc_rdb_pre_skipped
          WHERE ret_user_id = FND_GLOBAL.user_id;

    COMMIT;

END clear_old_data;


/*********************************************************************************************************
Procedure Name : GENERATE_PRE_RETRIEVAL_XML
Description : This procedure is used to dynamically generate the XML structure when the user clicks on
	      "Generate PDF" button on the Timecard Retrieval Dashboard > Pre Retrieval page.
	      This procedure is called from the Controller of the pre retrieval dashboard page and the XML
	      is passed back to the same Controller which then generates the PDF and launches it on the
	      self-service page.
*********************************************************************************************************/


PROCEDURE generate_pre_retrieval_xml(p_application_code IN VARCHAR2 DEFAULT 'PAY',
				     p_user_name        IN VARCHAR2 DEFAULT 'ANONYMOUS',
				     p_timecard_status 	IN VARCHAR2 DEFAULT NULL,
				     p_attribute_name 	IN VARCHAR2 DEFAULT NULL,
				     p_sup_name  	IN VARCHAR2 DEFAULT NULL,
				     p_delegated_person	IN VARCHAR2 DEFAULT NULL,
				     p_dynamic_sql      IN VARCHAR2,
				     p_pre_xml          OUT NOCOPY CLOB
				    )
IS

l_icx_date_format	VARCHAR2(20);
l_language_code		VARCHAR2(30);
l_report_info		VARCHAR2(100);

query1			varchar2(200);

qryCtx1			dbms_xmlgen.ctxType;
xmlresult1		CLOB;
l_pre_xml		CLOB DEFAULT empty_clob();
l_resultOffset		int;

l_dynamic_cursor  SYS_REFCURSOR; -- new code


TYPE r_details IS RECORD
   (person_name             hxc_rdb_pre_timecards.emp_name%TYPE,
    person_number           hxc_rdb_pre_timecards.emp_no%TYPE,
    start_time		    varchar2(50),
    stop_time		    varchar2(50),
    status		    fnd_lookup_values.meaning%TYPE,
    last_update_date	    varchar2(50),
    resource_id             varchar2(20),
    timecard_id             varchar2(20));

TYPE t_details IS TABLE OF r_details
INDEX BY BINARY_INTEGER;

timecard_details_tab          t_details;

BEGIN


	fnd_profile.get('ICX_DATE_FORMAT_MASK', l_icx_date_format);
	l_language_code := USERENV('LANG');

	l_report_info := '<?xml version="1.0" encoding="UTF-8"?>	<HXCRDBPRE> ';

	query1 := 'SELECT '
		|| 'user_name INITIATED_BY, '
		|| 'TO_CHAR(SYSDATE, ''' || l_icx_date_format || ''') RUN_DATE '
		|| 'from fnd_user '
		|| 'where user_id = fnd_global.user_id' ;

	qryCtx1 := dbms_xmlgen.newContext(query1);
	dbms_xmlgen.setRowTag(qryCtx1, NULL);
	dbms_xmlgen.setRowSetTag(qryCtx1, 'G_REPORT_INFO');
	xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
	dbms_xmlgen.closecontext(qryctx1);
	l_pre_xml := xmlresult1;
	dbms_lob.write(l_pre_xml, length(l_report_info), 1, l_report_info);
	l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
	dbms_lob.copy(l_pre_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, length(l_report_info), l_resultOffset +1);


	dbms_lob.writeappend(l_pre_xml, length('<G_PARAMETER_DETAILS>
<APP>' || p_application_code || '</APP>
<TIMECARD_STATUS>' || p_timecard_status || '</TIMECARD_STATUS>
<ATTRIBUTE_NAME>' || p_attribute_name || '</ATTRIBUTE_NAME>
<SUPERVISOR_NAME>' || p_sup_name || '</SUPERVISOR_NAME>
<DELEGATED_PERSON>' || p_delegated_person || '</DELEGATED_PERSON>
</G_PARAMETER_DETAILS>
'), '<G_PARAMETER_DETAILS>
<APP>' || p_application_code || '</APP>
<TIMECARD_STATUS>' || p_timecard_status || '</TIMECARD_STATUS>
<ATTRIBUTE_NAME>' || p_attribute_name || '</ATTRIBUTE_NAME>
<SUPERVISOR_NAME>' || p_sup_name || '</SUPERVISOR_NAME>
<DELEGATED_PERSON>' || p_delegated_person || '</DELEGATED_PERSON>
</G_PARAMETER_DETAILS>
');


	dbms_lob.writeappend(l_pre_xml, length('<LIST_G_DETAILS> '), '<LIST_G_DETAILS> ');

        OPEN l_dynamic_cursor FOR p_dynamic_sql;
        LOOP
           FETCH l_dynamic_cursor BULK COLLECT INTO timecard_details_tab LIMIT 300;
          EXIT WHEN timecard_details_tab.COUNT = 0;

	  FOR l_index IN 1..timecard_details_tab.COUNT
	  LOOP

	  dbms_lob.writeappend(l_pre_xml, length('<G_DETAILS>
<TIMECARD_ID>' || timecard_details_tab(l_index).timecard_id || '</TIMECARD_ID>
<START_TIME>' || timecard_details_tab(l_index).start_time || '</START_TIME>
<STOP_TIME>' || timecard_details_tab(l_index).stop_time || '</STOP_TIME>
<STATUS>' || timecard_details_tab(l_index).status || '</STATUS>
<LAST_UPDATE_DATE>' || timecard_details_tab(l_index).last_update_date || '</LAST_UPDATE_DATE>
<PERSON_NAME>' || timecard_details_tab(l_index).person_name || '</PERSON_NAME>
<PERSON_NUMBER>' || timecard_details_tab(l_index).person_number || '</PERSON_NUMBER>
</G_DETAILS>
'), '<G_DETAILS>
<TIMECARD_ID>' || timecard_details_tab(l_index).timecard_id || '</TIMECARD_ID>
<START_TIME>' || timecard_details_tab(l_index).start_time || '</START_TIME>
<STOP_TIME>' || timecard_details_tab(l_index).stop_time || '</STOP_TIME>
<STATUS>' || timecard_details_tab(l_index).status || '</STATUS>
<LAST_UPDATE_DATE>' || timecard_details_tab(l_index).last_update_date || '</LAST_UPDATE_DATE>
<PERSON_NAME>' || timecard_details_tab(l_index).person_name || '</PERSON_NAME>
<PERSON_NUMBER>' || timecard_details_tab(l_index).person_number || '</PERSON_NUMBER>
</G_DETAILS>
');

	  END LOOP;

       END LOOP;

       CLOSE l_dynamic_cursor;

	dbms_lob.writeappend(l_pre_xml, length('</LIST_G_DETAILS>
</HXCRDBPRE>
 '), '</LIST_G_DETAILS>
</HXCRDBPRE>
 ');

	p_pre_xml := l_pre_xml;

END generate_pre_retrieval_xml;





-- Added the below procedure to pick up each timecard's details
-- On demand.
PROCEDURE load_unretrieved_details( p_application   IN   VARCHAR2,
                                    p_timecard_id   IN   NUMBER)
IS

                CURSOR get_projects
                    IS SELECT proj.name||' - '||
                              task.task_number||' - '||
                              rdb.attribute3,
                              ROWIDTOCHAR(rdb.ROWID)
                         FROM hxc_rdb_pre_tc_details rdb,
                              pa_projects_all proj,
                              pa_tasks task
                        WHERE rdb.ret_user_id = FND_GLOBAL.user_id
                          AND rdb.attribute1 = proj.project_id
                          AND rdb.attribute2 = task.task_id;

                CURSOR get_elements
                    IS SELECT pay.element_name,
                              ROWIDTOCHAR(rdb.ROWID)
                         FROM hxc_rdb_pre_tc_details rdb,
                              pay_element_types_f_tl pay
                        WHERE rdb.ret_user_id = FND_GLOBAL.user_id
                          AND pay.language = USERENV('LANG')
                          AND rdb.attribute1 = pay.element_type_id;



                 atttab   VARCHARTAB;
                 rowtab   VARCHARTAB;
                 nametab  VARCHARTAB;

BEGIN

     DELETE FROM hxc_rdb_pre_tc_details
           WHERE ret_user_id = FND_GLOBAL.user_id;
     COMMIT;

     INSERT INTO hxc_rdb_pre_tc_details
                (time_building_block_id,
                 date_worked,
                 measure,
                 attribute1,
                 attribute2,
                 attribute3,
                 start_time,
                 stop_time,
                 timecard_id,
                 ret_user_id)
          SELECT det.time_building_block_id,
	         det.date_worked,
	         det.measure,
	         attribute1,
	         attribute2,
	         attribute3,
	         TO_CHAR(detail.start_time,'HH24:MI'), -- Bug 9656636
	         TO_CHAR(detail.stop_time,'HH24:MI'),
                 timecard_id,
                 FND_GLOBAL.user_id
            FROM hxc_rdb_pre_details      det,
                 hxc_time_building_blocks detail
           WHERE timecard_id                = p_timecard_id
             AND det.time_building_block_id = detail.time_building_block_id
             AND det.ovn                    = detail.object_version_number
             AND det.ret_user_id            = FND_GLOBAL.user_id;

     COMMIT;

     IF p_application = 'PA'
     THEN
        OPEN get_projects;
        LOOP
           FETCH get_projects BULK COLLECT INTO atttab,
                                                rowtab LIMIT 500;
           EXIT WHEN atttab.COUNT = 0;

           FORALL i IN atttab.FIRST..atttab.LAST
             UPDATE hxc_rdb_pre_tc_details
                SET attribute_name = atttab(i)
              WHERE ROWID = CHARTOROWID(rowtab(i));


           COMMIT;

        END LOOP;

        CLOSE get_projects;

     END IF;

     IF p_application = 'PAY'
     THEN
        OPEN get_elements;
        LOOP
           FETCH get_elements BULK COLLECT INTO atttab,
                                                rowtab LIMIT 500;
           EXIT WHEN atttab.COUNT = 0;

           FORALL i IN atttab.FIRST..atttab.LAST
             UPDATE hxc_rdb_pre_tc_details
                SET attribute_name = atttab(i)
              WHERE ROWID = CHARTOROWID(rowtab(i));


           COMMIT;

        END LOOP;

        CLOSE get_elements;

     END IF;

     COMMIT;


END load_unretrieved_details;


-- Bug 9494445
-- Added this procedure to unlock specific timecards.

PROCEDURE release_timecard_lock ( p_resource_id IN VARCHAR2,
                                  p_start_time  IN VARCHAR2,
                                  p_stop_time   IN VARCHAR2 )

IS
   PRAGMA AUTONOMOUS_TRANSACTION;


BEGIN

     DELETE FROM hxc_locks
        WHERE resource_id  = TO_NUMBER(p_resource_id)
          AND TRUNC(start_time)   = TO_DATE(p_start_time,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'))
          AND TRUNC(stop_time)    = TO_DATE(p_stop_time,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'));
     COMMIT;


END release_timecard_lock;


-- Bug 9654164
-- Added this function to be called before
-- all events in the dashboard so that any invalid
-- session is notified right away.

FUNCTION validate_login
RETURN VARCHAR2
IS

  l_exists NUMBER;

BEGIN
    SELECT 1
      INTO l_exists
      FROM hxc_rdb_logins
     WHERE user_id = FND_GLOBAL.user_id
       AND login_id = FND_GLOBAL.login_id
       AND status = 'VALID';

    RETURN NULL;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
         RETURN 'HXC_RDB_INVALID_SESSION_ERR';

END validate_login;




-- Bug 9654164
-- Added this function to record the session into the list of
-- valid sessions.  Only one session is allowed to be valid for
-- a given user.  The specific login checks to see if any other login
-- is active, and terminates those sessions.

FUNCTION validate_current_session
RETURN VARCHAR2
IS

   l_exists  NUMBER;
   l_rowid   VARCHAR2(50);
   l_tab     VARCHARTAB := VARCHARTAB();
   rowtab    VARCHARTAB;
   edtab     DATETAB;

   CURSOR get_others
       IS SELECT ROWIDTOCHAR(rdb.rowid),
		 NVL(fnd.end_time,hr_general.end_of_time)
	    FROM hxc_rdb_logins rdb,
		 fnd_logins fnd
	   WHERE rdb.login_id = fnd.login_id
             AND rdb.user_id = fnd_global.user_id
             AND rdb.login_id <> fnd_global.login_id;


BEGIN


     -- Delete anything which is older than half an hour.
     DELETE FROM hxc_rdb_logins
           WHERE user_id = FND_GLOBAL.user_id
             AND login_id <> FND_GLOBAL.login_id
             AND last_action_date < SYSDATE - (1/48);


     -- Find out if this session is already invalidated.
     BEGIN

          SELECT 1
            INTO l_exists
            FROM hxc_rdb_logins
           WHERE user_id = fnd_global.user_id
             AND login_id = fnd_global.login_id
             AND status = 'INVALID';

          IF l_exists = 1
          THEN
             RETURN 'ERROR';
          END IF;

        EXCEPTION
              WHEN NO_DATA_FOUND THEN
                    NULL;
     END;



     -- Either insert a new row or update the last touched date
     -- if already existing.
     BEGIN
         INSERT INTO hxc_rdb_logins
              (user_id,
               login_id,
               last_action_date,
               status,
               notified)
            VALUES
               (FND_GLOBAL.user_id,
                FND_GLOBAL.login_id,
                SYSDATE,
                'VALID',
                'N');

         EXCEPTION
             WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE hxc_rdb_logins
                     SET last_action_date = SYSDATE
                   WHERE user_id = FND_GLOBAL.user_id
                     AND login_id = FND_GLOBAL.login_id;
     END;

     -- Pick up other sessions which are active
     -- right now.
     OPEN get_others;
     FETCH get_others BULK COLLECT INTO rowtab,
                                        edtab;

     CLOSE get_others;

     -- Anything which is properly logged out
     -- can be deleted.
     FORALL i IN rowtab.FIRST..rowtab.LAST
       DELETE FROM hxc_rdb_logins
             WHERE ROWID = CHARTOROWID(rowtab(i))
               AND edtab(i) <> hr_general.end_of_time;


     -- Update any other session to be invalid.
     FORALL i IN rowtab.FIRST..rowtab.LAST
        UPDATE hxc_rdb_logins
           SET status = 'INVALID'
         WHERE ROWID = CHARTOROWID(rowtab(i))
           AND edtab(i) = hr_general.end_of_time
         RETURNING rowid BULK COLLECT INTO l_tab;

     -- Check if this session is already notified.
     -- If notified, no need to send the warning again.
     l_rowid := NULL;
     BEGIN
         SELECT ROWIDTOCHAR(rdb.rowid)
           INTO l_rowid
           FROM hxc_rdb_logins rdb
          WHERE login_id = FND_GLOBAL.login_id
            AND user_id  = FND_GLOBAL.user_id
            AND notified = 'N';

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_rowid := NULL;
     END;


     IF l_tab.COUNT > 0
       AND l_rowid IS NOT NULL
     THEN
         UPDATE hxc_rdb_logins
            SET notified = 'Y'
          WHERE rowid = chartorowid(l_rowid);
         RETURN 'WARNING';

     END IF;

     COMMIT;


     RETURN NULL;

END validate_current_session;

END HXC_RDB_PRE_RETRIEVAL;


/
