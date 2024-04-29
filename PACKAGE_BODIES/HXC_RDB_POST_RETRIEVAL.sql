--------------------------------------------------------
--  DDL for Package Body HXC_RDB_POST_RETRIEVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RDB_POST_RETRIEVAL" AS
/* $Header: hxcrdbpostret.pkb 120.1.12010000.21 2010/05/15 11:38:12 asrajago noship $ */

PROCEDURE go(p_application  IN VARCHAR2,
             p_start_date   IN VARCHAR2 DEFAULT NULL,
             p_end_date     IN VARCHAR2 DEFAULT NULL,
             p_payroll_id   IN NUMBER   DEFAULT NULL,
             p_org_id       IN NUMBER   DEFAULT NULL,
             p_person_id    IN NUMBER   DEFAULT NULL,
             p_batch_ref    IN VARCHAR2 DEFAULT NULL,
             p_msg          OUT NOCOPY VARCHAR2,
             p_level        OUT NOCOPY VARCHAR2
             )
IS


   l_level   VARCHAR2(50);

   -- Bug 9662707
   -- Replaced hxc_timecard_summary with hxc_time_building_blocks
   -- picking up OVN instead of status.  Status would be updated later.

   -- Bug 9656063
   -- Added Asg Org search criteria
   l_pay_sql   VARCHAR2(32000) :=
' SELECT DISTINCT SUM.time_building_block_id,
         SUM.object_version_number,
         SUM.resource_id,
         batch_id,
         old_batch_id,
         retro_batch_id,
         SUM.start_time,
         TRUNC(SUM.stop_time)
    FROM hxc_ret_pay_latest_details ret,
         hxc_time_building_blocks SUM
   WHERE ret.start_time BETWEEN :p_start_date
                            AND :p_end_date
     AND ret.timecard_id = SUM.time_building_block_id
     AND business_group_id = FND_PROFILE.VALUE(''PER_BUSINESS_GROUP_ID'')
     PERSONCRITERIA
     PAYROLLCRITERIA
     BATCHCRITERIA
     ORGCRITERIA
 ';

-- Bug 9626621
-- Added Org id condition.
   l_pa_sql   VARCHAR2(32000) :=
' SELECT DISTINCT SUM.time_building_block_id,
         SUM.object_version_number,
         SUM.resource_id,
         exp_group,
         old_exp_group,
         retro_exp_group,
         SUM.start_time,
         TRUNC(SUM.stop_time)
    FROM hxc_ret_pa_latest_details ret,
         hxc_time_building_blocks SUM
   WHERE ret.start_time BETWEEN :p_start_date
                        AND :p_end_date
     AND ret.timecard_id = SUM.time_building_block_id
     AND ret.org_id = NVL(Pa_Moac_Utils.Get_Current_Org_Id,FND_PROFILE.VALUE(''ORG_ID''))
     PERSONCRITERIA
     BATCHCRITERIA
     ORGCRITERIA
 ';

    l_batch_criteria  VARCHAR2(2000) :=
    'AND (  EXISTS         (SELECT 1
                           FROM pay_batch_headers pbh
                          WHERE pbh.batch_id = ret.batch_id
                            AND pbh.batch_reference = ''BATCHREF'' )
       OR  EXISTS         (SELECT 1
                           FROM pay_batch_headers pbh
                          WHERE pbh.batch_id = ret.retro_batch_id
                            AND pbh.batch_reference = ''BATCHREF'' )
          )
     ';


     l_payroll_criteria  VARCHAR2(2000) :=
    'AND EXISTS ( SELECT 1
                    FROM per_all_assignments_f paf
                   WHERE paf.person_id = ret.resource_id
                     AND ret.start_time BETWEEN paf.effective_start_date
                                            AND paf.effective_end_date
                     AND paf.payroll_id = PAYROLL )'
;

     -- Bug 9656063

     l_org_criteria  VARCHAR2(2000) :=
    'AND EXISTS ( SELECT 1
                    FROM per_all_assignments_f paf
                   WHERE paf.person_id = ret.resource_id
                     AND ret.start_time BETWEEN paf.effective_start_date
                                            AND paf.effective_end_date
                     AND paf.organization_id = ORGANIZATION )'
;


    tctab   NUMBERTAB;
    statustab  VARCHARTAB;
    restab   NUMBERTAB;
    batchtab VARCHARTAB;
    oldtab   VARCHARTAB;			 -- Bug 9662707
    rettab   VARCHARTAB;
    starttab DATETAB;
    stoptab  DATETAB;

    l_pay_cursor  SYS_REFCURSOR;


         -- Bug 9662707
         -- Added this code to create pseudo records for old batch ids
         -- This just picks up the records having Old_batch_id and create
         -- new records for those timecards, with old_batch_id put into
         -- the batch_id column -- just picking up the old batch ids to
         -- look like normal batces.

         PROCEDURE find_and_update_old
         IS

	     -- Bug 9701527
             -- Added the NOT EXISTS to avoid same batch coming
             -- twice because batch_id and old_batch_id are same.
             CURSOR find_old_tcs
                 IS SELECT timecard_id,
                           approval_status,
                           resource_id,
                           batch_id,
                           old_batch_id,
                           retro_batch_id,
                           start_time,
                           stop_time,
                           ROWIDTOCHAR(rdb.rowid)
                      FROM hxc_rdb_post_timecards rdb
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND old_batch_id IS NOT NULL
                       AND retro_batch_id IS NOT NULL
                       AND NOT EXISTS ( SELECT 1
                                          FROM hxc_rdb_post_timecards rdb2
                                         WHERE rdb2.ret_user_id = FND_GLOBAL.user_id
                                           AND rdb2.batch_id    = rdb.old_batch_id );

              -- Bug 9705704
              -- Cursor to pick up unique combo to delete duplicates.
              CURSOR get_duplicates
                  IS SELECT MAX(ROWIDTOCHAR(rdb.rowid)),
                            timecard_id,
                            NVL(batch_id,'0'),
                            NVL(retro_batch_id,'0')
                       FROM hxc_rdb_post_timecards rdb
                      WHERE ret_user_id = FND_GLOBAL.user_id
                      GROUP BY timecard_id,batch_id,retro_batch_id;

             tctab      NUMBERTAB;
             statustab  VARCHARTAB;
             restab     NUMBERTAB;
             batchtab   VARCHARTAB;
             oldtab     VARCHARTAB;			 -- Bug 9662707
             rettab     VARCHARTAB;
             starttab   DATETAB;
             stoptab    DATETAB;
             rowtab     VARCHARTAB;

          BEGIN

              OPEN find_old_tcs;
              LOOP
                 FETCH find_old_tcs BULK COLLECT INTO tctab,
                                                      statustab,
                                                      restab,
                                                      batchtab,
                                                      oldtab,
                                                      rettab,
                                                      starttab,
                                                      stoptab,
                                                      rowtab LIMIT 500;

                 EXIT WHEN tctab.COUNT = 0;

                 FORALL i IN tctab.FIRST..tctab.LAST
                   UPDATE hxc_rdb_post_timecards
                      SET old_batch_id = NULL
                    WHERE ROWID = CHARTOROWID(rowtab(i));

                 FORALL i IN tctab.FIRST..tctab.LAST
                   INSERT INTO hxc_rdb_post_timecards
                       (timecard_id,
                        approval_status,
                        resource_id,
                        batch_id,
                        start_time,
                        stop_time,
                        ret_user_id)
                   VALUES
                       (tctab(i),
                        statustab(i),
                        restab(i),
                        oldtab(i),
                        starttab(i),
                        stoptab(i),
                        FND_GLOBAL.user_id);

                   COMMIT;

              END LOOP;
              CLOSE find_old_tcs;

              -- Bug 9705704
              -- Update all the records with a NULL old_batch_id,
              -- because now we have picked up all the old batches
              -- as batch_id itself.

              UPDATE hxc_rdb_post_timecards
                 SET old_batch_id = NULL
               WHERE ret_user_id = FND_GLOBAL.user_id;

              -- Pick up the unique combos.
              OPEN get_duplicates;
              LOOP
                 FETCH get_duplicates BULK COLLECT INTO
                                                        rowtab,
                                                        tctab,
                                                        batchtab,
                                                        rettab LIMIT 500;
                 EXIT WHEN rowtab.COUNT = 0;

                 -- Delete those duplicates which do not have the max
                 -- rowid.
                 FORALL i IN rowtab.FIRST..rowtab.LAST
                     DELETE FROM hxc_rdb_post_timecards
                           WHERE ret_user_id             = FND_GLOBAL.user_id
                             AND timecard_id             = tctab(i)
                             AND NVL(batch_id,'0')       = batchtab(i)
                             AND NVL(retro_batch_id,'0') = rettab(i)
                             AND ROWID <> CHARTOROWID(rowtab(i));

                 COMMIT;
              END LOOP;
              CLOSE get_duplicates;






          END find_and_update_old;



         -- Bug 9662707
         -- Added this procedure to trim out the records having
         -- OVNs which are not latest.  Just picks out the ones having
         -- rank <> 1 and then deletes these.

         PROCEDURE delete_duplicate_tcs
         IS

             CURSOR get_rank
                 IS SELECT ROWIDTOCHAR(ROWID),
                           RANK() OVER ( PARTITION BY timecard_id
                                             ORDER BY TO_NUMBER(approval_status) DESC ) rank
                       FROM hxc_rdb_post_timecards rdb
                      WHERE ret_user_id = FND_GLOBAL.user_id;

             tctab   VARCHARTAB;
             ovntab  NUMBERTAB;
             ranktab NUMBERTAB;

         BEGIN

             OPEN get_rank;
             LOOP
                FETCH get_rank BULK COLLECT INTO tctab,
                                                 ranktab LIMIT 500;
                EXIT WHEN tctab.COUNT = 0;

                FORALL i IN tctab.FIRST..tctab.LAST
                  DELETE FROM hxc_rdb_post_timecards
                        WHERE ret_user_id = FND_GLOBAL.user_id
                          AND ROWID       = CHARTOROWID(tctab(i))
                          AND ranktab(i) <> 1 ;


                COMMIT;
             END LOOP;
             CLOSE get_rank;

         END delete_duplicate_tcs;



         PROCEDURE update_supervisor
         IS

             CURSOR get_supervisor
                 IS SELECT asg.supervisor_id,
                           asg.payroll_id,
                           asg.organization_id,
                           asg.job_id,
                           ROWIDTOCHAR(tc.ROWID)
                      FROM hxc_rdb_post_timecards tc,
                           per_all_assignments_f asg
                     WHERE tc.ret_user_id = FND_GLOBAL.user_id
                       AND tc.resource_id = asg.person_id
                       AND tc.start_time BETWEEN asg.effective_start_date
                                             AND asg.effective_end_date;

             suptab  NUMBERTAB;
             paytab  NUMBERTAB;
             orgtab  NUMBERTAB;
             jobtab  NUMBERTAB;
             rowtab  VARCHARTAB;

         BEGIN
             OPEN get_supervisor;
             LOOP
                 FETCH get_supervisor BULK COLLECT INTO suptab,
                                                        paytab,
                                                        orgtab,
                                                        jobtab,
                                                        rowtab LIMIT 500;
                 EXIT WHEN suptab.COUNT = 0;

                 FORALL i IN suptab.FIRST..suptab.LAST
                   UPDATE hxc_rdb_post_timecards
                      SET supervisor_id = suptab(i),
                          payroll_id    = paytab(i),
                          org_job_id        = DECODE(p_application,'PAY',  orgtab(i),
                                                               'PA',   jobtab(i))
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
                           ROWIDTOCHAR(rdb.ROWID)
                       FROM hxc_rdb_post_timecards rdb,
                            per_all_people_f ppf
                       WHERE SYSDATE BETWEEN ppf.effective_start_date
                                       AND ppf.effective_end_date
                       AND rdb.resource_id = ppf.person_id
                       AND rdb.ret_user_id = FND_GLOBAL.user_id;

              nametab  VARCHARTAB;
              notab    VARCHARTAB;
              rowtab   VARCHARTAB;

         BEGIN
                OPEN get_emp_name;
                LOOP
                    FETCH get_emp_name BULK COLLECT INTO nametab,
                                                         notab,
                                                             rowtab LIMIT 500;
                    EXIT WHEN nametab.COUNT = 0;

                    FORALL i IN nametab.FIRST..nametab.LAST
                      UPDATE hxc_rdb_post_timecards
                         SET emp_name = nametab(i),
                             emp_no   = notab(i)
                       WHERE ROWID = CHARTOROWID(rowtab(i));

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
        ret.timecard_id,
        ret.start_time date_worked,
        ret.attribute1,
        ret.attribute2,
        ret.attribute3,
        ret.measure,
        ret.old_attribute1,
        ret.old_attribute2,
        ret.old_attribute3,
        ret.old_measure,
        ret.attribute1,
        ret.pbl_id,
        ret.retro_pbl_id,
        ret.old_pbl_id,
        ret.batch_id,
        ret.retro_batch_id,
        ret.request_id,
        ret.old_request_id,
        ret.old_batch_id
   FROM hxc_ret_pay_latest_details ret,
        hxc_rdb_post_timecards tc
  WHERE ret.timecard_id = tc.timecard_id
    AND NVL(tc.batch_id,''0'') = NVL(ret.batch_id,''0'')
    AND NVL(tc.retro_batch_id,''0'') = NVL(ret.retro_batch_id,''0'')
    AND tc.ret_user_id = USERID '
 ;

         l_pa_details   VARCHAR2(32000) :=
'SELECT ret.resource_id,
        ret.time_building_block_id,
        ret.object_version_number ovn,
        ret.timecard_id,
        ret.start_time date_worked,
        ret.attribute1,
        ret.attribute2,
        ret.attribute3,
        ret.measure,
        ret.old_attribute1,
        ret.old_attribute2,
        ret.old_attribute3,
        ret.old_measure,
        ret.attribute1,
        ret.pei_id,
        ret.retro_pei_id,
        ret.old_pei_id,
        ret.exp_group,
        ret.retro_exp_group,
        ret.request_id,
        ret.old_request_id,
        ret.old_exp_group
   FROM hxc_ret_pa_latest_details ret,
        hxc_rdb_post_timecards tc
  WHERE ret.timecard_id = tc.timecard_id
    AND tc.ret_user_id = USERID
    AND NVL(tc.batch_id,''0'') = NVL(ret.exp_group,''0'')
    AND NVL(tc.retro_batch_id,''0'') = NVL(ret.retro_exp_group,''0'')
';


          l_ref_cursor SYS_REFCURSOR;
          restab       NUMBERTAB;
          bbtab        NUMBERTAB;
          ovntab       NUMBERTAB;
          stattab      VARCHARTAB;
          tctab        NUMBERTAB;
          dwtab        DATETAB;
          att1tab      VARCHARTAB;
          att2tab      VARCHARTAB;
          att3tab      VARCHARTAB;
          measuretab   NUMBERTAB;
          oatt1tab     VARCHARTAB;
          oatt2tab     VARCHARTAB;
          oatt3tab     VARCHARTAB;
          omeasuretab  NUMBERTAB;
          recline      NUMBERTAB;
          orecline     NUMBERTAB;
          retroline    NUMBERTAB;
          batchid      VARCHARTAB;
          rbatchid     VARCHARTAB;
          hrspmtab     NUMBERTAB;
          reqid        NUMBERTAB;
          rreqid       NUMBERTAB;
          obatchid     VARCHARTAB;

          BEGIN
               IF p_application = 'PA'
               THEN
                   l_details := l_pa_details;
               ELSIF p_application = 'PAY'
               THEN
                   l_details := REPLACE(l_details,'LATEST_DETAILS','HXC_RET_PAY_LATEST_DETAILS');
               END IF;
               l_details := REPLACE(l_details,'USERID',FND_GLOBAL.user_id);

               OPEN l_ref_cursor FOR l_details;
               LOOP
                  FETCH l_ref_cursor BULK COLLECT INTO restab,
                                                       bbtab,
                                                       ovntab,
                                                       tctab,
                                                       dwtab,
                                                       att1tab,
                                                       att2tab,
                                                       att3tab,
                                                       measuretab,
                                                       oatt1tab,
                                                       oatt2tab,
                                                       oatt3tab,
                                                       omeasuretab,
                                                       hrspmtab ,
                                                       recline,
                                                       retroline,
                                                       orecline,
                                                       batchid,
                                                       rbatchid,
                                                       reqid,
                                                       rreqid,
                                                       obatchid
                                                                LIMIT 500;
                   EXIT WHEN restab.COUNT = 0;

                   FORALL i IN restab.FIRST..restab.LAST
                     INSERT INTO hxc_rdb_post_details
                                 (resource_id,
                       		  time_building_block_id,
                       		  ovn,
                       		  timecard_id,
                       		  date_worked,
                       		  attribute1,
                       		  attribute2,
                       		  attribute3,
                       		  measure,
                       		  old_attribute1,
                       		  old_attribute2,
                       		  old_attribute3,
                       		  old_measure,
                       		  hrs_pm,
                       		  rec_line_id,
                       		  rec_retro_line_id,
                            adj_rec_line_id,
                       		  batch_id,
                       		  retro_batch_id,
                            request_id,
                            old_request_id,
                            old_batch_id,
                       		  ret_user_id )
                      VALUES
                                 (  restab(i),
                                    bbtab(i),
                                    ovntab(i),
                                    tctab(i),
                                    dwtab(i),
                                    att1tab(i),
                                    att2tab(i),
                                    att3tab(i),
                                    measuretab(i),
                                    oatt1tab(i),
                                    oatt2tab(i),
                                    oatt3tab(i),
                                    omeasuretab(i),
                                    DECODE(p_application,'PA',hrspmtab(i),NULL),
                                    recline(i),
                                    retroline(i),
                                    orecline(i),
                                    batchid(i),
                                    rbatchid(i),
                                    reqid(i),
                                    rreqid(i),
                                    obatchid(i),
                                    FND_GLOBAL.user_id);

                      COMMIT;
                 END LOOP;

         END pick_up_details;





         -- Bug 9662707
         -- Added this procedure mimicking the above one, just to pick up the
         -- old details for each adjusted entry.


         PROCEDURE pick_up_old_details(p_application  IN VARCHAR2)
         IS


         -- The below cursor is pretty much like the one used for the above proc.
         -- Instead of the current details, it picks up the old batch line details
         -- (attributes, measure etc) and picks up NULL in place of old batch details
         -- and retro batch details. This would create some details just like the
         -- old entries are created newly as new lines.
         --
         -- Eg. Reg 8 hrs
         --     Retrieved.
         --     Changed to Reg 6 hours.
         --     The above proc would have picked it up like this.

         --     current details 6 hrs, Reg.
         --     retro   details -8 hrs, Reg.
         --
         --     The original + 8 hrs is lost here.  This procedure would just pick up
         --     and put it into the table.
         --

         l_details   VARCHAR2(32000) :=
'SELECT ret.resource_id,
        ret.time_building_block_id,
        ret.object_version_number ovn,
        ret.timecard_id,
        ret.start_time date_worked,
        ret.old_attribute1,
        ret.old_attribute2,
        ret.old_attribute3,
        ret.old_measure,
        NULL,
        NULL,
        NULL,
        NULL,
        ret.old_attribute1,
        ret.old_pbl_id,
        NULL,
        NULL,
        ret.old_batch_id,
        NULL,
        ret.old_request_id,
        NULL,
        NULL
   FROM hxc_ret_pay_latest_details ret,
        hxc_rdb_post_timecards tc
  WHERE ret.timecard_id = tc.timecard_id
    AND tc.batch_id = ret.old_batch_id
    AND ret.old_pbl_id <> NVL(ret.pbl_id,0)
    AND tc.ret_user_id = USERID '
 ;

         l_pa_details   VARCHAR2(32000) :=
'SELECT ret.resource_id,
        ret.time_building_block_id,
        ret.object_version_number ovn,
        ret.timecard_id,
        ret.start_time date_worked,
        ret.old_attribute1,
        ret.old_attribute2,
        ret.old_attribute3,
        ret.old_measure,
        NULL,
        NULL,
        NULL,
        NULL,
        ret.old_attribute1,
        ret.old_pei_id,
        NULL,
        NULL,
        ret.old_exp_group,
        NULL,
        ret.old_request_id,
        NULL,
        NULL
   FROM hxc_ret_pa_latest_details ret,
        hxc_rdb_post_timecards tc
  WHERE ret.timecard_id = tc.timecard_id
    AND tc.ret_user_id = USERID
    AND tc.batch_id = ret.old_exp_group
    AND ret.old_pei_id <> NVL(ret.pei_id,0)
';


          l_ref_cursor SYS_REFCURSOR;
          restab       NUMBERTAB;
          bbtab        NUMBERTAB;
          ovntab       NUMBERTAB;
          stattab      VARCHARTAB;
          tctab        NUMBERTAB;
          dwtab        DATETAB;
          att1tab      VARCHARTAB;
          att2tab      VARCHARTAB;
          att3tab      VARCHARTAB;
          measuretab   NUMBERTAB;
          oatt1tab     VARCHARTAB;
          oatt2tab     VARCHARTAB;
          oatt3tab     VARCHARTAB;
          omeasuretab  NUMBERTAB;
          recline      NUMBERTAB;
          orecline     NUMBERTAB;
          retroline    NUMBERTAB;
          batchid      VARCHARTAB;
          rbatchid     VARCHARTAB;
          hrspmtab     NUMBERTAB;
          reqid        NUMBERTAB;
          rreqid       NUMBERTAB;
          obatchid     VARCHARTAB;

          BEGIN
               IF p_application = 'PA'
               THEN
                   l_details := l_pa_details;
               ELSIF p_application = 'PAY'
               THEN
                   l_details := REPLACE(l_details,'LATEST_DETAILS','HXC_RET_PAY_LATEST_DETAILS');
               END IF;
               l_details := REPLACE(l_details,'USERID',FND_GLOBAL.user_id);

               OPEN l_ref_cursor FOR l_details;
               LOOP
                  FETCH l_ref_cursor BULK COLLECT INTO restab,
                                                       bbtab,
                                                       ovntab,
                                                       tctab,
                                                       dwtab,
                                                       att1tab,
                                                       att2tab,
                                                       att3tab,
                                                       measuretab,
                                                       oatt1tab,
                                                       oatt2tab,
                                                       oatt3tab,
                                                       omeasuretab,
                                                       hrspmtab ,
                                                       recline,
                                                       retroline,
                                                       orecline,
                                                       batchid,
                                                       rbatchid,
                                                       reqid,
                                                       rreqid,
                                                       obatchid
                                                                LIMIT 500;
                   EXIT WHEN restab.COUNT = 0;

                   FORALL i IN restab.FIRST..restab.LAST
                     INSERT INTO hxc_rdb_post_details
                                 (resource_id,
                       		  time_building_block_id,
                       		  ovn,
                       		  timecard_id,
                       		  date_worked,
                       		  attribute1,
                       		  attribute2,
                       		  attribute3,
                       		  measure,
                       		  old_attribute1,
                       		  old_attribute2,
                       		  old_attribute3,
                       		  old_measure,
                       		  hrs_pm,
                       		  rec_line_id,
                       		  rec_retro_line_id,
                                  adj_rec_line_id,
                       		  batch_id,
                       		  retro_batch_id,
                                  request_id,
                                  old_request_id,
                                  old_batch_id,
                       		  ret_user_id )
                      VALUES
                                 (  restab(i),
                                    bbtab(i),
                                    ovntab(i),
                                    tctab(i),
                                    dwtab(i),
                                    att1tab(i),
                                    att2tab(i),
                                    att3tab(i),
                                    measuretab(i),
                                    oatt1tab(i),
                                    oatt2tab(i),
                                    oatt3tab(i),
                                    omeasuretab(i),
                                    DECODE(p_application,'PA',hrspmtab(i),NULL),
                                    recline(i),
                                    retroline(i),
                                    orecline(i),
                                    batchid(i),
                                    rbatchid(i),
                                    reqid(i),
                                    rreqid(i),
                                    obatchid(i),
                                    FND_GLOBAL.user_id);

                      COMMIT;
                 END LOOP;

         END pick_up_old_details;



         -- Bug 9662707
         -- Added this procedure to update the statuses of the timecard
         -- records.

         PROCEDURE update_statuses
         IS

             -- To pick up the guys which are active now.
             CURSOR get_summary
                 IS SELECT sum.approval_status,
                           rdb.timecard_id
                      FROM hxc_rdb_post_timecards rdb,
                           hxc_timecard_summary sum
                     WHERE rdb.ret_user_id = FND_GLOBAL.user_id
                       AND rdb.timecard_id  = sum.timecard_id;


             -- To pick up those which are deleted now or overwritten with a
             -- template, or deleted and recreated.

             CURSOR get_blocks
                 IS SELECT ROWIDTOCHAR(rowid)
                      FROM hxc_rdb_post_timecards
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND approval_status NOT IN ( SELECT lookup_code
                                                      FROM fnd_lookup_values
                                                     WHERE lookup_type = 'HXC_APPROVAL_STATUS'
                                                       AND language = USERENV('LANG') );

              -- To get the latest versions of the those which are mow deleted
              -- and later versions exist.

              CURSOR get_latest
                  IS SELECT rdb.timecard_id,
                            sum.timecard_id,
                            sum.approval_status,
		            ROWIDTOCHAR(rdb.rowid)
                       FROM hxc_rdb_post_timecards rdb,
                            hxc_timecard_summary sum
                      WHERE rdb.ret_user_id     = FND_GLOBAL.user_id
                        AND rdb.approval_status = 'RDBDELETED'
                        AND rdb.resource_id     = sum.resource_id
	                AND rdb.start_time      = sum.start_time
                     	AND rdb.stop_time       = TRUNC(sum.stop_time)
	                AND rdb.timecard_id    <> sum.timecard_id ;


              stattab    VARCHARTAB;
              tctab      NUMBERTAB;
              rowtab     VARCHARTAB;


              rdbtab     NUMBERTAB;
              sumtab     NUMBERTAB;
              statustab  VARCHARTAB;
              rowidtab   VARCHARTAB;


         BEGIN

              -- Update from hxc_timecard_summary for those in there.

              OPEN get_summary;
              LOOP
                 FETCH get_summary BULK COLLECT INTO stattab,
                                                     tctab LIMIT 500;
                 EXIT WHEN stattab.COUNT = 0;

                 FORALL i IN tctab.FIRST..tctab.LAST
                    UPDATE hxc_rdb_post_timecards
                       SET approval_status = stattab(i)
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND timecard_id = tctab(i);

                 COMMIT;
               END LOOP;
              CLOSE get_summary;

              -- Update everything else to DELETED.

              OPEN get_blocks;
              FETCH get_blocks BULK COLLECT INTO rowtab;
              CLOSE get_blocks;

              FORALL i IN rowtab.FIRST..rowtab.LAST
                 UPDATE hxc_rdb_post_timecards
                    SET approval_status = 'RDBDELETED'
                  WHERE rowid = CHARTOROWID(rowtab(i));

              COMMIT;

              -- Pick up later versions.
              OPEN get_latest;
              FETCH get_latest BULK COLLECT INTO rdbtab,
                                                 sumtab,
                                                 statustab,
                                                 rowidtab;

              CLOSE get_latest;



              -- Update the timecard ids and statuses for the timecards.
              FORALL i IN rowidtab.FIRST..rowidtab.LAST
                 UPDATE hxc_rdb_post_timecards
                    SET approval_status = statustab(i),
                        timecard_id     = sumtab(i)
                   WHERE ROWID = CHARTOROWID(rowidtab(i));

              -- Update the timecard_id in the details table because they
              -- are referenced below.

              FORALL i IN rowidtab.FIRST..rowidtab.LAST
                 UPDATE hxc_rdb_post_details
                    SET timecard_id     = sumtab(i)
                   WHERE timecard_id    = rdbtab(i);


              COMMIT;



         END update_statuses;


         -- Bug 9662707
         -- Added this proc to update the retro batches with suffix (Retro)
         -- Works only for PA.

         PROCEDURE update_retro_batches
         IS

             CURSOR pick_timecards
                 IS SELECT ROWIDTOCHAR(rdb.rowid)
                      FROM hxc_rdb_post_timecards rdb
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND retro_batch_id IS NOT NULL;


             CURSOR pick_details
                 IS SELECT ROWIDTOCHAR(rdb.rowid)
                      FROM hxc_rdb_post_details rdb
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND retro_batch_id IS NOT NULL;

                rowtab  VARCHARTAB;


         BEGIN

             OPEN pick_timecards;
             LOOP
                FETCH pick_timecards BULK COLLECT INTO rowtab LIMIT 500;
                EXIT WHEN rowtab.COUNT = 0;
                FORALL i IN rowtab.FIRST..rowtab.LAST
                   UPDATE hxc_rdb_post_timecards
                      SET retro_batch_id = retro_batch_id||'(Retro)'
                    WHERE rowid = CHARTOROWID(rowtab(i));

                COMMIT;
              END LOOP;
             CLOSE pick_timecards;

             OPEN pick_details;
             LOOP
                FETCH pick_details BULK COLLECT INTO rowtab LIMIT 500;
                EXIT WHEN rowtab.COUNT = 0;
                FORALL i IN rowtab.FIRST..rowtab.LAST
                   UPDATE hxc_rdb_post_details
                      SET retro_batch_id = retro_batch_id||'(Retro)'
                    WHERE rowid = CHARTOROWID(rowtab(i));

                COMMIT;
              END LOOP;
             CLOSE pick_details;

        END update_retro_batches;



         PROCEDURE update_partially_retrieved(p_application  IN VARCHAR2)
         IS

             CURSOR get_partially_retrieved_pay
                 IS SELECT ROWIDTOCHAR(tc.ROWID)
                      FROM hxc_rdb_post_timecards tc,
                           hxc_pay_latest_details pay
                     WHERE tc.ret_user_id = FND_GLOBAL.user_id
                       AND tc.timecard_id = pay.timecard_id;

             CURSOR get_partially_retrieved_pa
                 IS SELECT ROWIDTOCHAR(tc.ROWID)
                      FROM hxc_rdb_post_timecards tc,
                           hxc_pa_latest_details pay
                     WHERE tc.ret_user_id = FND_GLOBAL.user_id
                       AND tc.timecard_id = pay.timecard_id;


             rowtab  VARCHARTAB;

         BEGIN
             IF p_application = 'PAY'
             THEN
             OPEN get_partially_retrieved_pay;
             LOOP
                 FETCH get_partially_retrieved_pay BULK COLLECT INTO rowtab LIMIT 500;
                 EXIT WHEN rowtab.COUNT = 0;

                 FORALL i IN rowtab.FIRST..rowtab.LAST
                   UPDATE hxc_rdb_post_timecards
                      SET partially_retrieved = 'Y'
                    WHERE ROWID = CHARTOROWID(rowtab(i));
                 COMMIT;
             END LOOP;
            CLOSE get_partially_retrieved_pay;
            END IF;

            IF p_application = 'PA'
            THEN
             OPEN get_partially_retrieved_pa;
             LOOP
                 FETCH get_partially_retrieved_pa BULK COLLECT INTO rowtab LIMIT 500;
                 EXIT WHEN rowtab.COUNT = 0;

                 FORALL i IN rowtab.FIRST..rowtab.LAST
                   UPDATE hxc_rdb_post_timecards
                      SET partially_retrieved = 'Y'
                    WHERE ROWID = CHARTOROWID(rowtab(i));
                 COMMIT;
             END LOOP;
            CLOSE get_partially_retrieved_pa;
            END IF;


         END update_partially_retrieved;



            PROCEDURE summarize_batches
            IS

            BEGIN
                INSERT
                  INTO hxc_rdb_post_batches
                      (batch_id,
                       timecards,
                       retro_flag,
                       ret_user_id)
                SELECT DISTINCT batch_id,
                       COUNT(DISTINCT timecard_id) OVER (PARTITION BY batch_id) Timecards,
                       'N',
                       FND_GLOBAL.user_id
                  FROM hxc_rdb_post_timecards
                 WHERE ret_user_id = FND_GLOBAL.user_id
                   AND batch_id IS NOT NULL
                  UNION
                SELECT DISTINCT retro_batch_id,
                       COUNT(DISTINCT timecard_id) OVER (PARTITION BY retro_batch_id) Timecards,
                       'Y',
                       FND_GLOBAL.user_id
                  FROM hxc_rdb_post_timecards
                 WHERE ret_user_id = FND_GLOBAL.user_id
                   AND retro_batch_id IS NOT NULL
                   AND NVL(retro_batch_id,'0') <> NVL(batch_id,'0')
                   AND NVL(retro_batch_id,'0') <> NVL(old_batch_id,'0') ;
                COMMIT;

            END summarize_batches;


            PROCEDURE summarize_attributes
            IS

            BEGIN
                INSERT
                  INTO hxc_rdb_post_attributes
                      (batch_id,
                       attribute1,
                       attribute2,
                       attribute3,
                       measure,
                       negative_flag,
                       ret_user_id)
                SELECT DISTINCT batch_id,
                       attribute1,
                       attribute2,
                       attribute3,
                       SUM(measure) OVER (PARTITION BY batch_id,
                                                       attribute1,
                                                       attribute2,
                                                       attribute3),
                       1,
                       FND_GLOBAL.user_id
                  FROM hxc_rdb_post_details
                 WHERE rec_line_id IS NOT NULL
                   AND ret_user_id = FND_GLOBAL.user_id
                UNION
                SELECT DISTINCT '0' batch_id,
                       attribute1,
                       attribute2,
                       attribute3,
                       SUM(measure) OVER (PARTITION BY attribute1,
                                                       attribute2,
                                                       attribute3),
                       1,
                       FND_GLOBAL.user_id
                  FROM hxc_rdb_post_details
                 WHERE rec_line_id IS NOT NULL
                   AND ret_user_id = FND_GLOBAL.user_id;


                INSERT
                  INTO hxc_rdb_post_attributes
                      (batch_id,
                       attribute1,
                       attribute2,
                       attribute3,
                       measure,
                       negative_flag,
                       ret_user_id)
                SELECT DISTINCT retro_batch_id,
                       old_attribute1,
                       old_attribute2,
                       old_attribute3,
                       SUM(-1*old_measure) OVER (PARTITION BY retro_batch_id,
                                                              old_attribute1,
                                                              old_attribute2,
                                                              old_attribute3),
                       -1,
                       FND_GLOBAL.user_id
                  FROM hxc_rdb_post_details
                 WHERE rec_retro_line_id IS NOT NULL
                   AND ret_user_id = FND_GLOBAL.user_id
                UNION
                SELECT DISTINCT '0' retro_batch_id,
                       old_attribute1,
                       old_attribute2,
                       old_attribute3,
                       SUM(-1*old_measure) OVER (PARTITION BY old_attribute1,
                                                              old_attribute2,
                                                              old_attribute3),
                       -1,
                       FND_GLOBAL.user_id
                  FROM hxc_rdb_post_details
                 WHERE rec_retro_line_id IS NOT NULL
                   AND ret_user_id = FND_GLOBAL.user_id;


                INSERT INTO HXC_RDB_POST_ATTRIBUTES
                      ( attribute1,
                        attribute2,
	                attribute3,
                    	measure,
                    	batch_id,
                        total,
                        negative_flag,
                        ret_user_id
                       )
                  SELECT attribute1,
                         attribute2,
	                 attribute3,
                    	 SUM(measure),
                    	 batch_id,
                    	 ' (Total) 'total,
                        1,
                         FND_GLOBAL.user_id
                    FROM hxc_rdb_post_attributes
                   WHERE ret_user_id = FND_GLOBAL.user_id
                   GROUP BY batch_id,
                            attribute1,
                            attribute2,
                            attribute3 ;


                COMMIT;

            END summarize_attributes;

            PROCEDURE summarize_hrs_pm(p_application  IN VARCHAR2)
            IS

            BEGIN

                IF p_application = 'PAY'
                THEN
                    INSERT INTO hxc_rdb_post_hrs_pm
                           (batch_id,
                            hrs_pm,
                            timecards,
                            ret_user_id)
                    SELECT DISTINCT batch_id,
                           supervisor_id,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY batch_id,
                                                                          supervisor_id) ,
                           FND_GLOBAL.user_id
                      FROM hxc_rdb_post_timecards
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND supervisor_id IS NOT NULL
					   AND batch_id IS NOT NULL
					 UNION
                    SELECT DISTINCT retro_batch_id,
                           supervisor_id,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY retro_batch_id,
                                                                          supervisor_id) ,
                           FND_GLOBAL.user_id
                      FROM hxc_rdb_post_timecards
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND supervisor_id IS NOT NULL
					   AND retro_batch_id IS NOT NULL
					 UNION
                    SELECT '0' batch_id,
			   supervisor_id,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY supervisor_id) ,
                           FND_GLOBAL.user_id
                      FROM hxc_rdb_post_timecards
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND supervisor_id IS NOT NULL;
                    COMMIT;
                END IF;

                IF p_application = 'PA'
                THEN
                    INSERT
                      INTO hxc_rdb_post_hrs_pm
                           (batch_id,
                            hrs_pm,
                            timecards,
                            ret_user_id)
                    SELECT DISTINCT batch_id,
                           hrs_pm,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY batch_id,
                                                                          hrs_pm) ,
                           fnd_global.user_id
                      FROM hxc_rdb_post_details
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND batch_id IS NOT NULL
                           UNION
                    SELECT DISTINCT retro_batch_id,
                           hrs_pm,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY retro_batch_id,
                                                                          hrs_pm) ,
                           fnd_global.user_id
                      FROM hxc_rdb_post_details
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND retro_batch_id IS NOT NULL
                           UNION
                    SELECT DISTINCT '0' batch_id,
                           hrs_pm,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY hrs_pm) measure,
                           fnd_global.user_id
                      FROM hxc_rdb_post_details
                     WHERE ret_user_id = FND_GLOBAL.user_id;

                COMMIT;
                END IF;


            END summarize_hrs_pm;

            PROCEDURE summarize_payroll_exp(p_application  IN VARCHAR2)
            IS

            BEGIN

                IF p_application = 'PAY'
                THEN
                    INSERT INTO hxc_rdb_post_payroll_exp_type
                           (batch_id,
                            payroll_exp_id,
                            timecards,
                            ret_user_id)
                    SELECT DISTINCT batch_id,
                           payroll_id,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY batch_id,
                                                                          payroll_id) ,
                           FND_GLOBAL.user_id
                      FROM hxc_rdb_post_timecards
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND payroll_id IS NOT NULL
					   AND batch_id IS NOT NULL
					 UNION
                    SELECT DISTINCT retro_batch_id,
                           payroll_id,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY retro_batch_id,
                                                                          payroll_id) ,
                           FND_GLOBAL.user_id
                      FROM hxc_rdb_post_timecards
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND payroll_id IS NOT NULL
					   AND retro_batch_id IS NOT NULL
					 UNION
                    SELECT '0' batch_id,
			   payroll_id,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY payroll_id) ,
                           FND_GLOBAL.user_id
                      FROM hxc_rdb_post_timecards
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND payroll_id IS NOT NULL;
                    COMMIT;
                END IF;


                -- Bug 9626265
                -- Added the condition to avoid the totals
                -- adding up here.
                IF p_application = 'PA'
                THEN
                    INSERT INTO hxc_rdb_post_payroll_exp_type
                           (batch_id,
                            payroll_exp_id,
                            timecards,
                            ret_user_id)
                    SELECT DISTINCT batch_id,
                           attribute3,
                           SUM(measure) OVER (PARTITION BY batch_id,
                                                           attribute3) ,
                           FND_GLOBAL.user_id
                      FROM hxc_rdb_post_attributes
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND total IS NULL ;
                    COMMIT;
                END IF;


            END summarize_payroll_exp;




            PROCEDURE summarize_partial
            IS

            BEGIN

                    INSERT INTO hxc_rdb_post_partial_timecards
                           (batch_id,
                            start_time,
                            stop_time,
                            timecards,
                            ret_user_id)
                   SELECT DISTINCT batch_id,
                          start_time,
                          stop_time,
                          COUNT(DISTINCT timecard_id) OVER (PARTITION BY batch_id,
                                                                         start_time,
                                                                         stop_time),
                          FND_GLOBAL.user_id
                     FROM hxc_rdb_post_timecards
                     WHERE partially_retrieved = 'Y'
                      AND batch_id IS NOT NULL
                      AND ret_user_id = FND_GLOBAL.user_id
                     UNION
                   SELECT DISTINCT retro_batch_id,
                          start_time,
                          stop_time,
                          COUNT(DISTINCT timecard_id) OVER (PARTITION BY retro_batch_id,
                                                                         start_time,
                                                                         stop_time),
                          FND_GLOBAL.user_id
                     FROM hxc_rdb_post_timecards
                     WHERE partially_retrieved = 'Y'
                       AND retro_batch_id IS NOT NULL
                      AND ret_user_id = FND_GLOBAL.user_id
                    UNION
                   SELECT DISTINCT '0' batch_id,
                          start_time,
                          stop_time,
                          COUNT(DISTINCT timecard_id) OVER (PARTITION BY start_time,
                                                                         stop_time),
                          FND_GLOBAL.user_id
                     FROM hxc_rdb_post_timecards
                     WHERE partially_retrieved = 'Y'
                      AND ret_user_id = FND_GLOBAL.user_id ;
                    COMMIT;

            END summarize_partial;




            PROCEDURE summarize_distinct
            IS

            BEGIN

                    INSERT INTO hxc_rdb_post_dist_timecards
                           (batch_id,
                            start_time,
                            stop_time,
                            timecards,
                            ret_user_id)
                   SELECT DISTINCT batch_id,
                          start_time,
                          stop_time,
                          COUNT(DISTINCT timecard_id) OVER (PARTITION BY batch_id,
                                                                         start_time,
                                                                         stop_time),
                          FND_GLOBAL.user_id
                     FROM hxc_rdb_post_timecards
                     WHERE batch_id IS NOT NULL
                      AND ret_user_id = FND_GLOBAL.user_id
                     UNION
                   SELECT DISTINCT retro_batch_id,
                          start_time,
                          stop_time,
                          COUNT(DISTINCT timecard_id) OVER (PARTITION BY retro_batch_id,
                                                                         start_time,
                                                                         stop_time),
                          FND_GLOBAL.user_id
                     FROM hxc_rdb_post_timecards
                     WHERE retro_batch_id IS NOT NULL
                      AND ret_user_id = FND_GLOBAL.user_id
                    UNION
                   SELECT DISTINCT '0' batch_id,
                          start_time,
                          stop_time,
                          COUNT(DISTINCT timecard_id) OVER (PARTITION BY start_time,
                                                                         stop_time),
                          FND_GLOBAL.user_id
                     FROM hxc_rdb_post_timecards
                     WHERE ret_user_id = FND_GLOBAL.user_id ;
                    COMMIT;

            END summarize_distinct;



            PROCEDURE summarize_org(p_application  IN VARCHAR2)
            IS

            BEGIN

                    INSERT INTO hxc_rdb_post_org_job
                           (batch_id,
                            org_job_id,
                            timecards,
                            ret_user_id)
                    SELECT DISTINCT batch_id,
                           org_job_id,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY batch_id,
                                                                          org_job_id) ,
                           FND_GLOBAL.user_id
                      FROM hxc_rdb_post_timecards
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND org_job_id IS NOT NULL
					   AND batch_id IS NOT NULL
					 UNION
                    SELECT DISTINCT retro_batch_id,
                           org_job_id,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY retro_batch_id,
                                                                          org_job_id) ,
                           FND_GLOBAL.user_id
                      FROM hxc_rdb_post_timecards
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND org_job_id IS NOT NULL
					   AND retro_batch_id IS NOT NULL
					 UNION
                    SELECT '0' batch_id,
                           org_job_id,
                           COUNT(DISTINCT timecard_id) OVER (PARTITION BY org_job_id) ,
                           FND_GLOBAL.user_id
                      FROM hxc_rdb_post_timecards
                     WHERE ret_user_id = FND_GLOBAL.user_id
                       AND org_job_id IS NOT NULL;
                    COMMIT;

            END summarize_org;



            PROCEDURE translate_hrs_pm(p_application  IN VARCHAR2)
            IS

             CURSOR get_proj_manager
                 IS SELECT ppf.full_name||'('||proj.name||')',
                           ppf.person_id,
                           ROWIDTOCHAR(rdb.ROWID)
                      FROM hxc_rdb_post_hrs_pm rdb,
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
                       AND TRUNC(SYSDATE)  BETWEEN TRUNC(PPP.start_date_active)
                                               AND NVL(TRUNC(PPP.end_date_active),SYSDATE);

              CURSOR get_hrs_name
                  IS SELECT ppf.full_name,
                            ppf.person_id,
                           ROWIDTOCHAR(rdb.ROWID)
                       FROM hxc_rdb_post_hrs_pm rdb,
                            per_all_people_f ppf
                       WHERE SYSDATE BETWEEN ppf.effective_start_date
                                       AND ppf.effective_end_date
                       AND rdb.hrs_pm = ppf.person_id
                       AND rdb.ret_user_id = FND_GLOBAL.user_id;


              nametab   VARCHARTAB;
              idtab     NUMBERTAB;
              rowtab    VARCHARTAB;

            BEGIN

                IF p_application = 'PAY'
                THEN
                OPEN get_hrs_name;
                LOOP
                    FETCH get_hrs_name BULK COLLECT INTO nametab,
                                                         idtab,
                                                         rowtab LIMIT 500;
                    EXIT WHEN nametab.COUNT = 0;

                    FORALL i IN nametab.FIRST..nametab.LAST
                      UPDATE hxc_rdb_post_hrs_pm
                         SET hrs_pm_name = nametab(i),
                             resource_id = idtab(i)
                       WHERE ROWID = CHARTOROWID(rowtab(i));

                     COMMIT;

                 END LOOP;
                 CLOSE get_hrs_name;

                 END IF;

                IF p_application = 'PA'
                THEN
                OPEN get_proj_manager;
                LOOP
                    FETCH get_proj_manager BULK COLLECT INTO nametab,
                                                             idtab,
                                                             rowtab LIMIT 500;
                    EXIT WHEN nametab.COUNT = 0;

                    FORALL i IN nametab.FIRST..nametab.LAST
                      UPDATE hxc_rdb_post_hrs_pm
                         SET hrs_pm_name = nametab(i),
                             resource_id = idtab(i)
                       WHERE ROWID = CHARTOROWID(rowtab(i));

                     COMMIT;

                 END LOOP;
                 CLOSE get_proj_manager;
                END IF;



            END translate_hrs_pm;




            PROCEDURE translate_batches(p_application  IN VARCHAR2)
            IS

              -- Bug 9714916
              -- While picking up the payroll batches, remove
              -- the retro flag from the batch id.
              -- Add the tag to the batch name.
              CURSOR get_batch_name
                  IS SELECT pbh.batch_name||DECODE(retro_flag,'Y','(Retro)'),
                           ROWIDTOCHAR(rdb.ROWID)
                       FROM hxc_rdb_post_batches rdb,
                            pay_batch_headers pbh
                       WHERE REPLACE(rdb.batch_id,'(Retro)') = pbh.batch_id
                       AND rdb.ret_user_id = FND_GLOBAL.user_id;


              nametab  VARCHARTAB;
              rowtab    VARCHARTAB;

            BEGIN

                IF p_application = 'PAY'
                THEN
                OPEN get_batch_name;
                LOOP
                    FETCH get_batch_name BULK COLLECT INTO nametab,
                                                             rowtab LIMIT 500;
                    EXIT WHEN nametab.COUNT = 0;

                    FORALL i IN nametab.FIRST..nametab.LAST
                      UPDATE hxc_rdb_post_batches
                         SET batch_name = nametab(i)
                       WHERE ROWID = CHARTOROWID(rowtab(i));

                     COMMIT;

                 END LOOP;
                 CLOSE get_batch_name;

                 END IF;

                 IF p_application = 'PA'
                 THEN
                    UPDATE hxc_rdb_post_batches
                       SET batch_name = batch_id
                     WHERE ret_user_id = FND_GLOBAL.user_id;
                END IF;


              END translate_batches;



              PROCEDURE translate_attributes(p_application  IN VARCHAR2)
              IS


                CURSOR get_projects
                    IS SELECT proj.name||' - '||
                              task.task_number||' - '||
                              rdb.attribute3,
                              ROWIDTOCHAR(rdb.ROWID)
                         FROM hxc_rdb_post_attributes rdb,
                              pa_projects_all proj,
                              pa_tasks task
                        WHERE rdb.ret_user_id = FND_GLOBAL.user_id
                          AND rdb.attribute1 = proj.project_id
                          AND rdb.attribute2 = task.task_id;

                CURSOR get_elements
                    IS SELECT pay.element_name,
                              ROWIDTOCHAR(rdb.ROWID)
                         FROM hxc_rdb_post_attributes rdb,
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
                           UPDATE hxc_rdb_post_attributes
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
                           UPDATE hxc_rdb_post_attributes
                              SET attribute_name = atttab(i)
                            WHERE ROWID = CHARTOROWID(rowtab(i));


                         COMMIT;

                      END LOOP;

                      CLOSE get_elements;

                   END IF;

            END translate_attributes;




            PROCEDURE translate_payroll(p_application  IN VARCHAR2)
            IS

             CURSOR get_proj_manager
                 IS SELECT ppf.full_name,
                           ROWIDTOCHAR(rdb.ROWID)
                      FROM hxc_rdb_pre_hrs_pm rdb,
                           PA_PROJECT_PARTIES         PPP  ,
                           PA_PROJECT_ROLE_TYPES_B     PPRT,
                           per_all_people_f           ppf
                     WHERE  PPP.PROJECT_ID                      = rdb.hrs_pm
                       AND rdb.ret_user_id = FND_GLOBAL.user_id
                       AND PPP.PROJECT_ROLE_ID                 = PPRT.PROJECT_ROLE_ID
                       AND PPRT.PROJECT_ROLE_TYPE              ='PROJECT MANAGER'
                       AND PPRT.role_party_class = 'PERSON'
                       AND SYSDATE BETWEEN ppf.effective_start_date
                                       AND ppf.effective_end_date
                       AND PPP.RESOURCE_SOURCE_ID = ppf.person_id
                       AND TRUNC(SYSDATE)  BETWEEN TRUNC(PPP.start_date_active)
                                               AND NVL(TRUNC(PPP.end_date_active),SYSDATE);

              CURSOR get_payroll_name
                  IS SELECT ppf.payroll_name,
                           ROWIDTOCHAR(rdb.ROWID)
                       FROM hxc_rdb_post_payroll_exp_type rdb,
                            pay_payrolls_f ppf
                       WHERE rdb.payroll_exp_id = ppf.payroll_id
                       AND rdb.ret_user_id = FND_GLOBAL.user_id;


              nametab  VARCHARTAB;
              rowtab    VARCHARTAB;

            BEGIN

                IF p_application = 'PAY'
                THEN
                OPEN get_payroll_name;
                LOOP
                    FETCH get_payroll_name BULK COLLECT INTO nametab,
                                                             rowtab LIMIT 500;
                    EXIT WHEN nametab.COUNT = 0;

                    FORALL i IN nametab.FIRST..nametab.LAST
                      UPDATE hxc_rdb_post_payroll_exp_type
                         SET payroll_exp_name = nametab(i)
                       WHERE ROWID = CHARTOROWID(rowtab(i));

                     COMMIT;

                 END LOOP;
                 CLOSE get_payroll_name;

                 END IF;

                 IF p_application = 'PA'
                 THEN
                    UPDATE hxc_rdb_post_payroll_exp_type
                       SET payroll_exp_name = payroll_exp_id
                     WHERE ret_user_id = FND_GLOBAL.user_id;
                 END IF;


            END translate_payroll;




            PROCEDURE translate_org_job(p_application  IN VARCHAR2)
            IS

             CURSOR get_proj_manager
                 IS SELECT ppf.full_name,
                           ROWIDTOCHAR(rdb.ROWID)
                      FROM hxc_rdb_pre_hrs_pm rdb,
                           PA_PROJECT_PARTIES         PPP  ,
                           PA_PROJECT_ROLE_TYPES_B     PPRT,
                           per_all_people_f           ppf
                     WHERE  PPP.PROJECT_ID                      = rdb.hrs_pm
                       AND rdb.ret_user_id = FND_GLOBAL.user_id
                       AND PPP.PROJECT_ROLE_ID                 = PPRT.PROJECT_ROLE_ID
                       AND PPRT.PROJECT_ROLE_TYPE              ='PROJECT MANAGER'
                       AND PPRT.role_party_class = 'PERSON'
                       AND SYSDATE BETWEEN ppf.effective_start_date
                                       AND ppf.effective_end_date
                       AND PPP.RESOURCE_SOURCE_ID = ppf.person_id
                       AND TRUNC(SYSDATE)  BETWEEN TRUNC(PPP.start_date_active)
                                               AND NVL(TRUNC(PPP.end_date_active),SYSDATE);

              CURSOR get_org_name
                  IS SELECT org.name,
                           ROWIDTOCHAR(rdb.ROWID)
                       FROM hxc_rdb_post_org_job rdb,
                            hr_all_organization_units org
                       WHERE rdb.org_job_id = org.organization_id
                       AND rdb.ret_user_id = FND_GLOBAL.user_id;

              CURSOR get_job_name
                  IS SELECT job.name,
                           ROWIDTOCHAR(rdb.ROWID)
                       FROM hxc_rdb_post_org_job rdb,
                            per_jobs job
                       WHERE rdb.org_job_id = job.job_id
                       AND rdb.ret_user_id = FND_GLOBAL.user_id;



              nametab  VARCHARTAB;
              rowtab    VARCHARTAB;

            BEGIN

                IF p_application = 'PAY'
                THEN
                OPEN get_org_name;
                LOOP
                    FETCH get_org_name BULK COLLECT INTO nametab,
                                                             rowtab LIMIT 500;
                    EXIT WHEN nametab.COUNT = 0;

                    FORALL i IN nametab.FIRST..nametab.LAST
                      UPDATE hxc_rdb_post_org_job
                         SET org_job_name = nametab(i)
                       WHERE ROWID = CHARTOROWID(rowtab(i));

                     COMMIT;

                 END LOOP;
                 CLOSE get_org_name;

                 END IF;

                IF p_application = 'PA'
                THEN
                OPEN get_job_name;
                LOOP
                    FETCH get_job_name BULK COLLECT INTO nametab,
                                                             rowtab LIMIT 500;
                    EXIT WHEN nametab.COUNT = 0;

                    FORALL i IN nametab.FIRST..nametab.LAST
                      UPDATE hxc_rdb_post_org_job
                         SET org_job_name = nametab(i)
                       WHERE ROWID = CHARTOROWID(rowtab(i));

                     COMMIT;

                 END LOOP;
                 CLOSE get_job_name;

                 END IF;


              END translate_org_job;





BEGIN


     -- Bug 9654164
     -- Added this code snippet to manage the validity of
     -- this or other sessions by the same user.
     l_level := hxc_rdb_pre_retrieval.validate_current_session;
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



    IF p_application = 'PAY'
    THEN
       IF p_person_id IS NOT NULL
       THEN
          l_pay_sql := REPLACE(l_pay_sql,'PERSONCRITERIA','AND ret.resource_id ='||p_person_id);
       ELSE
          l_pay_sql := REPLACE(l_pay_sql,'PERSONCRITERIA');
       END IF;

       IF p_batch_ref IS NOT NULL
       THEN
          l_batch_criteria := REPLACE(l_batch_criteria,'BATCHREF',p_batch_ref);
          l_pay_sql := REPLACE(l_pay_sql,'BATCHCRITERIA',l_batch_criteria);
       ELSE
          l_pay_sql := REPLACE(l_pay_sql,'BATCHCRITERIA');
       END IF;

       IF p_payroll_id IS NOT NULL
       THEN
          l_payroll_criteria := REPLACE(l_payroll_criteria,'PAYROLL',p_payroll_id);
          l_pay_sql := REPLACE(l_pay_sql,'PAYROLLCRITERIA',l_payroll_criteria);
       ELSE
          l_pay_sql := REPLACE(l_pay_sql,'PAYROLLCRITERIA');

       END IF;

       -- Bug 9656063
       -- Added this construct for filtering based on Asg's organization.
       IF p_org_id IS NOT NULL
       THEN
          l_org_criteria := REPLACE(l_org_criteria,'ORGANIZATION',p_org_id);
          l_pay_sql := REPLACE(l_pay_sql,'ORGCRITERIA',l_org_criteria);
       ELSE
          l_pay_sql := REPLACE(l_pay_sql,'ORGCRITERIA');

       END IF;


       OPEN l_pay_cursor FOR l_pay_sql USING TO_DATE(p_start_date,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'))
                                            ,TO_DATE(p_end_date,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'));
       LOOP
          FETCH l_pay_cursor BULK COLLECT INTO tctab,
                                               statustab,
                                               restab,
                                               batchtab,
                                               oldtab,
                                               rettab,
                                               starttab,
                                               stoptab LIMIT 500;
         EXIT WHEN tctab.COUNT = 0;

         FORALL i IN tctab.FIRST..tctab.LAST
           INSERT INTO hxc_rdb_post_timecards
                     (timecard_id,
                      approval_status,
                      resource_id,
                      batch_id,
                      old_batch_id,
                      retro_batch_id,
                      start_time,
                      stop_time,
                      ret_user_id)
                VALUES
                     ( tctab(i),
                       statustab(i),
                       restab(i),
                       batchtab(i),
                       oldtab(i),
                       rettab(i),
                       starttab(i),
                       stoptab(i),
                       FND_GLOBAL.user_id);

          COMMIT;

        END LOOP;


       CLOSE l_pay_cursor;



    END IF;


    IF p_application = 'PA'
    THEN
       IF p_person_id IS NOT NULL
       THEN
          l_pa_sql := REPLACE(l_pa_sql,'PERSONCRITERIA','AND ret.resource_id ='||p_person_id);
       ELSE
          l_pa_sql := REPLACE(l_pa_sql,'PERSONCRITERIA');
       END IF;

       IF p_batch_ref IS NOT NULL
       THEN
          l_pa_sql := REPLACE(l_pa_sql,'BATCHCRITERIA','AND (   ret.exp_group = '''||p_batch_ref||''''||
                                                         '     OR ret.retro_exp_group = '''||p_batch_ref||''')');
       ELSE
          l_pa_sql := REPLACE(l_pa_sql,'BATCHCRITERIA');
       END IF;


       -- Bug 9656063
       -- Added this construct for filtering based on Asg's organization.
       IF p_org_id IS NOT NULL
       THEN
          l_org_criteria := REPLACE(l_org_criteria,'ORGANIZATION',p_org_id);
          l_pa_sql := REPLACE(l_pa_sql,'ORGCRITERIA',l_org_criteria);
       ELSE
          l_pa_sql := REPLACE(l_pa_sql,'ORGCRITERIA');

       END IF;



       OPEN l_pay_cursor FOR l_pa_sql USING TO_DATE(p_start_date,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'))
                                            ,TO_DATE(p_end_date,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'));
       LOOP
          FETCH l_pay_cursor BULK COLLECT INTO tctab,
                                               statustab,
                                               restab,
                                               batchtab,
                                               oldtab,
                                               rettab,
                                               starttab,
                                               stoptab LIMIT 500;
         EXIT WHEN tctab.COUNT = 0;

         FORALL i IN tctab.FIRST..tctab.LAST
           INSERT INTO hxc_rdb_post_timecards
                     (timecard_id,
                      approval_status,
                      resource_id,
                      batch_id,
                      old_batch_id,
                      retro_batch_id,
                      start_time,
                      stop_time,
                      ret_user_id)
                VALUES
                     ( tctab(i),
                       statustab(i),
                       restab(i),
                       batchtab(i),
                       oldtab(i),
                       rettab(i),
                       starttab(i),
                       stoptab(i),
                       FND_GLOBAL.user_id);

          COMMIT;

        END LOOP;


       CLOSE l_pay_cursor;


    END IF;

       -- Bug 9662707
       find_and_update_old;
       delete_duplicate_tcs;
       update_supervisor;
       update_emp_details;
       update_partially_retrieved(p_application);
       pick_up_details(p_application);
       -- Bug 9662707
       pick_up_old_details(p_application);
       update_statuses;
       -- Bug 9714916
       -- Removed the application check here.
       -- Calling this procedure for Payroll (for the sake of OTLR) and projects.
       update_retro_batches;
       summarize_batches;
       summarize_attributes;
       summarize_partial;
       summarize_distinct;
       summarize_hrs_pm(p_application);
       summarize_payroll_exp(p_application);
       summarize_org(p_application);
       translate_hrs_pm(p_application);
       translate_batches(p_application);
       translate_attributes(p_application);
       translate_org_job(p_application);
       translate_payroll(p_application);


END go;



PROCEDURE clear_old_data
IS

      CURSOR get_old_timecards
          IS SELECT ROWIDTOCHAR(ROWID)
               FROM hxc_rdb_post_timecards
              WHERE ret_user_id = FND_GLOBAL.user_id;

      CURSOR get_old_details
          IS SELECT ROWIDTOCHAR(ROWID)
               FROM hxc_rdb_post_details
              WHERE ret_user_id = FND_GLOBAL.user_id;

       rowtab  VARCHARTAB;

BEGIN
    OPEN get_old_timecards;
    LOOP
       FETCH get_old_timecards BULK COLLECT INTO rowtab LIMIT 500;
       EXIT WHEN rowtab.COUNT = 0;

       FORALL i IN rowtab.FIRST..rowtab.LAST
        DELETE FROM hxc_rdb_post_timecards
              WHERE ROWID = CHARTOROWID(rowtab(i));

       COMMIT;

    END LOOP;
    CLOSE get_old_timecards;

    OPEN get_old_details;
    LOOP
       FETCH get_old_details BULK COLLECT INTO rowtab LIMIT 500;
       EXIT WHEN rowtab.COUNT = 0;

       FORALL i IN rowtab.FIRST..rowtab.LAST
        DELETE FROM hxc_rdb_post_details
              WHERE ROWID = CHARTOROWID(rowtab(i));

       COMMIT;

    END LOOP;
    CLOSE get_old_details;


    DELETE FROM hxc_rdb_post_batches
          WHERE ret_user_id = FND_GLOBAL.user_id;

    DELETE FROM hxc_rdb_post_attributes
          WHERE ret_user_id = FND_GLOBAL.user_id;

    DELETE FROM hxc_rdb_post_hrs_pm
          WHERE ret_user_id = FND_GLOBAL.user_id;

    DELETE FROM hxc_rdb_post_payroll_exp_type
          WHERE ret_user_id = FND_GLOBAL.user_id;

    DELETE FROM hxc_rdb_post_partial_timecards
          WHERE ret_user_id = FND_GLOBAL.user_id;

    DELETE FROM hxc_rdb_post_dist_timecards
          WHERE ret_user_id = FND_GLOBAL.user_id;

    DELETE FROM hxc_rdb_post_org_job
          WHERE ret_user_id = FND_GLOBAL.user_id;

    DELETE FROM hxc_rdb_post_tc_details
          WHERE ret_user_id = FND_GLOBAL.user_id;


    COMMIT;

END clear_old_data;


PROCEDURE load_retrieved_details( p_application   IN   VARCHAR2,
                                  p_timecard_id   IN   NUMBER)
IS




       CURSOR get_projects
            IS SELECT proj.name||' - '||
                      task.task_number||' - '||
                      rdb.attribute3,
                      ROWIDTOCHAR(rdb.ROWID)
                 FROM hxc_rdb_post_tc_details rdb,
                      pa_projects_all proj,
                      pa_tasks task
                WHERE rdb.ret_user_id = FND_GLOBAL.user_id
                  AND rdb.attribute1 = proj.project_id
                  AND rdb.attribute2 = task.task_id;

        CURSOR get_elements
            IS SELECT pay.element_name,
                      ROWIDTOCHAR(rdb.ROWID)
                 FROM hxc_rdb_post_tc_details rdb,
                      pay_element_types_f_tl pay
                WHERE rdb.ret_user_id = FND_GLOBAL.user_id
                  AND pay.language = USERENV('LANG')
                  AND rdb.attribute1 = pay.element_type_id;


        -- Bug 9714916
        -- If the batch names comes with a piped retro tag,
        -- remove those.  Works only for Payroll retro batches.
        CURSOR get_batch_name
          IS SELECT pbh.batch_name,
                    ROWIDTOCHAR(rdb.ROWID)
               FROM hxc_rdb_post_tc_details rdb,
                    pay_batch_headers pbh
              WHERE REPLACE(rdb.batch_id,'(Retro)') = pbh.batch_id
                AND rdb.ret_user_id = FND_GLOBAL.user_id;

        CURSOR get_batch_name_old
            IS SELECT pbh.batch_name,
                      ROWIDTOCHAR(rdb.ROWID)
                 FROM hxc_rdb_post_tc_details rdb,
                      pay_batch_headers pbh
                WHERE rdb.old_batch_id = pbh.batch_id
                  AND rdb.ret_user_id = FND_GLOBAL.user_id;


                 atttab  VARCHARTAB;
                 rowtab  VARCHARTAB;
                 nametab  VARCHARTAB;

BEGIN

     DELETE FROM hxc_rdb_post_tc_details
           WHERE ret_user_id = FND_GLOBAL.user_id;
     COMMIT;

     INSERT INTO hxc_rdb_post_tc_details
              (time_building_block_id,
               date_worked,
               measure,
               attribute1,
               attribute2,
               attribute3,
               rec_line_id,
               batch_id,
               request_id,
               adj_rec_line_id,
               old_batch_id,
               old_request_id,
               timecard_id,
               ret_user_id)
       SELECT DISTINCT time_building_block_id,
	      date_worked,
	      measure,
	      attribute1,
	      attribute2,
	      attribute3,
	      rec_line_id,
	      batch_id,
              request_id,
              NULL,
              NULL,
              NULL,
              timecard_id,
              FND_GLOBAL.user_id
         FROM hxc_rdb_post_details det
        WHERE timecard_id = p_timecard_id
          AND rec_line_id IS NOT NULL
          AND ret_user_id = FND_GLOBAL.user_id
        UNION
          ALL
       SELECT DISTINCT time_building_block_id,
	      date_worked,
	      -1*old_measure,
	      old_attribute1,
	      old_attribute2,
	      old_attribute3,
	      rec_retro_line_id,
      	      retro_batch_id,
              request_id,
              adj_rec_line_id,
              old_batch_id,
              old_request_id,
              timecard_id,
              FND_GLOBAL.user_id
         FROM hxc_rdb_post_details det
        WHERE timecard_id = p_timecard_id
          AND rec_retro_line_id IS NOT NULL
          AND ret_user_id = FND_GLOBAL.user_id ;

     COMMIT;

     IF p_application = 'PA'
     THEN
        OPEN get_projects;
        LOOP
           FETCH get_projects BULK COLLECT INTO atttab,
                                                rowtab LIMIT 500;
           EXIT WHEN atttab.COUNT = 0;

           FORALL i IN atttab.FIRST..atttab.LAST
             UPDATE hxc_rdb_post_tc_details
                SET attribute_name = atttab(i)
              WHERE ROWID = CHARTOROWID(rowtab(i));

           COMMIT;

        END LOOP;

        CLOSE get_projects;

        UPDATE hxc_rdb_post_tc_details
           SET batch_name = batch_id,
               old_line_details = RTRIM(adj_rec_line_id||' - '||old_batch_id||' - '||old_request_id,' - ')
         WHERE timecard_id = p_timecard_id
           AND ret_user_id  = FND_GLOBAL.user_id;

     END IF;

     IF p_application = 'PAY'
     THEN
        OPEN get_elements;
        LOOP

            FETCH get_elements BULK COLLECT INTO atttab,
                                                 rowtab LIMIT 500;
            EXIT WHEN atttab.COUNT = 0;

            FORALL i IN atttab.FIRST..atttab.LAST
               UPDATE hxc_rdb_post_tc_details
                  SET attribute_name = atttab(i)
                WHERE ROWID = CHARTOROWID(rowtab(i));

            COMMIT;

        END LOOP;
        CLOSE get_elements;

        OPEN get_batch_name;
        LOOP
           FETCH get_batch_name BULK COLLECT INTO nametab,
                                                  rowtab LIMIT 500;
           EXIT WHEN nametab.COUNT = 0;

           FORALL i IN nametab.FIRST..nametab.LAST
              UPDATE hxc_rdb_post_tc_details
                 SET batch_name = nametab(i)
               WHERE ROWID = CHARTOROWID(rowtab(i));

           COMMIT;

        END LOOP;
        CLOSE get_batch_name;

        OPEN get_batch_name_old;
        LOOP
            FETCH get_batch_name_old BULK COLLECT INTO nametab,
                                                       rowtab LIMIT 500;
            EXIT WHEN nametab.COUNT = 0;

            FORALL i IN nametab.FIRST..nametab.LAST
               UPDATE hxc_rdb_post_tc_details
                  SET old_line_details = adj_rec_line_id||' - '||nametab(i)||' - '||old_request_id
                WHERE ROWID = CHARTOROWID(rowtab(i));

            COMMIT;

        END LOOP;
        CLOSE get_batch_name_old;
     END IF;

     COMMIT;


END load_retrieved_details;


/*********************************************************************************************************
Procedure Name : generate_post_retrieval_xml
Description : This procedure is used to dynamically generate the XML structure when the user clicks on
	      "Generate PDF" button on the Timecard Retrieval Dashboard > Post Retrieval page.
	      This procedure is called from the Controller of the post retrieval dashboard page and the XML
	      is passed back to the same Controller which then generates the PDF and launches it on the
	      self-service page.
*********************************************************************************************************/


PROCEDURE generate_post_retrieval_xml(p_application_code IN VARCHAR2 DEFAULT 'PAY',
				     p_user_name         IN VARCHAR2 DEFAULT 'ANONYMOUS',
				     p_batch_name 	 IN VARCHAR2 DEFAULT NULL,
				     p_attribute_name 	 IN VARCHAR2 DEFAULT NULL,
				     p_sup_name  	 IN VARCHAR2 DEFAULT NULL,
				     p_payroll_name	 IN VARCHAR2 DEFAULT NULL,
				     p_distinct_tc	 IN VARCHAR2 DEFAULT NULL,
				     p_partial_tc	 IN VARCHAR2 DEFAULT NULL,
				     p_organization	 IN VARCHAR2 DEFAULT NULL,
				     p_dynamic_sql       IN VARCHAR2,
				     p_post_xml          OUT NOCOPY CLOB
				    )
IS

l_icx_date_format	VARCHAR2(20);
l_language_code		VARCHAR2(30);
l_report_info		VARCHAR2(100);

query1			varchar2(200);

qryCtx1			dbms_xmlgen.ctxType;
xmlresult1		CLOB;
l_post_xml		CLOB DEFAULT empty_clob();
l_resultOffset		int;

l_dynamic_cursor  SYS_REFCURSOR;


TYPE r_details IS RECORD
   (person_name             hxc_rdb_post_timecards.emp_name%TYPE,
    person_number           hxc_rdb_post_timecards.emp_no%TYPE,
    start_time		    varchar2(50),
    stop_time		    varchar2(50),
    status		    fnd_lookup_values.meaning%TYPE,
    last_update_date        varchar2(50),
    resource_id             varchar2(20),
    timecard_id             varchar2(20));

TYPE t_details IS TABLE OF r_details
INDEX BY BINARY_INTEGER;

timecard_details_tab          t_details;

BEGIN


	fnd_profile.get('ICX_DATE_FORMAT_MASK', l_icx_date_format);
	l_language_code := USERENV('LANG');

	l_report_info := '<?xml version="1.0" encoding="UTF-8"?>	<HXCRDBPOST> ';

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
	l_post_xml := xmlresult1;
	dbms_lob.write(l_post_xml, length(l_report_info), 1, l_report_info);
	l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
	dbms_lob.copy(l_post_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, length(l_report_info), l_resultOffset +1);


	dbms_lob.writeappend(l_post_xml, length('<G_PARAMETER_DETAILS>
<APP>' || p_application_code || '</APP>
<BATCH_NAME>' || p_batch_name || '</BATCH_NAME>
<ATTRIBUTE_NAME>' || p_attribute_name || '</ATTRIBUTE_NAME>
<SUP_PM_NAME>' || p_sup_name || '</SUP_PM_NAME>
<PAYROLL_JOB_NAME>' || p_payroll_name || '</PAYROLL_JOB_NAME>
<DISTINCT_PERIOD>' || p_distinct_tc || '</DISTINCT_PERIOD>
<PARTIAL_TC>' || p_partial_tc || '</PARTIAL_TC>
<ORG>' || p_organization || '</ORG>
</G_PARAMETER_DETAILS>
'), '<G_PARAMETER_DETAILS>
<APP>' || p_application_code || '</APP>
<BATCH_NAME>' || p_batch_name || '</BATCH_NAME>
<ATTRIBUTE_NAME>' || p_attribute_name || '</ATTRIBUTE_NAME>
<SUP_PM_NAME>' || p_sup_name || '</SUP_PM_NAME>
<PAYROLL_JOB_NAME>' || p_payroll_name || '</PAYROLL_JOB_NAME>
<DISTINCT_PERIOD>' || p_distinct_tc || '</DISTINCT_PERIOD>
<PARTIAL_TC>' || p_partial_tc || '</PARTIAL_TC>
<ORG>' || p_organization || '</ORG>
</G_PARAMETER_DETAILS>
');


	dbms_lob.writeappend(l_post_xml, length('<LIST_G_DETAILS> '), '<LIST_G_DETAILS> ');

        OPEN l_dynamic_cursor FOR p_dynamic_sql;
        LOOP
           FETCH l_dynamic_cursor BULK COLLECT INTO timecard_details_tab LIMIT 300;
          EXIT WHEN timecard_details_tab.COUNT = 0;

	  FOR l_index IN 1..timecard_details_tab.COUNT
	  LOOP

	  dbms_lob.writeappend(l_post_xml, length('<G_DETAILS>
<TIMECARD_ID>' || timecard_details_tab(l_index).timecard_id || '</TIMECARD_ID>
<START_TIME>' || timecard_details_tab(l_index).start_time || '</START_TIME>
<STOP_TIME>' || timecard_details_tab(l_index).stop_time || '</STOP_TIME>
<STATUS>' || timecard_details_tab(l_index).status || '</STATUS>
<PERSON_NAME>' || timecard_details_tab(l_index).person_name || '</PERSON_NAME>
<PERSON_NUMBER>' || timecard_details_tab(l_index).person_number || '</PERSON_NUMBER>
</G_DETAILS>
'), '<G_DETAILS>
<TIMECARD_ID>' || timecard_details_tab(l_index).timecard_id || '</TIMECARD_ID>
<START_TIME>' || timecard_details_tab(l_index).start_time || '</START_TIME>
<STOP_TIME>' || timecard_details_tab(l_index).stop_time || '</STOP_TIME>
<STATUS>' || timecard_details_tab(l_index).status || '</STATUS>
<PERSON_NAME>' || timecard_details_tab(l_index).person_name || '</PERSON_NAME>
<PERSON_NUMBER>' || timecard_details_tab(l_index).person_number || '</PERSON_NUMBER>
</G_DETAILS>
');

	  END LOOP;

       END LOOP;

       CLOSE l_dynamic_cursor;

	dbms_lob.writeappend(l_post_xml, length('</LIST_G_DETAILS>
</HXCRDBPOST>
 '), '</LIST_G_DETAILS>
</HXCRDBPOST>
 ');

	p_post_xml := l_post_xml;

END generate_post_retrieval_xml;


END HXC_RDB_POST_RETRIEVAL;


/
