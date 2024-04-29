--------------------------------------------------------
--  DDL for Package Body HXC_RPT_TC_AUDIT_TRAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RPT_TC_AUDIT_TRAIL" AS
/* $Header: hxcrptaudittrail.pkb 120.10.12010000.7 2010/02/16 16:56:01 asrajago ship $ */

g_debug BOOLEAN := hr_utility.debug_enabled;

newline           VARCHAR2(1) :=
'
';




-- AFTERPFORM
-- Calls the main action block and passes on the global parameters.

FUNCTION afterpform
RETURN BOOLEAN
AS

errbuf    VARCHAR2(100);
retcode   VARCHAR2(100);

BEGIN


    -- Public Procedure afterpform
    -- Calls execute_audit_trail_reporting passing the global parameters
    -- Is called from the HXCRPTAUD.xml, data definition file.

    execute_audit_trail_reporting  (errbuf          => errbuf,
                                    retcode         => retcode,
                                    p_date_from     => p_from_date ,
                                    p_date_to       => p_to_date ,
                                    p_data_regen    => p_dat_regen ,
                                    p_record_save   => p_record_save,
                                    p_org_id        => p_org_id ,
                                    p_locn_id       => p_locn_id ,
                                    p_payroll_id    => p_payroll_id ,
                                    p_supervisor_id => p_supervisor_id ,
                                    p_person_id     => p_person_id  );

    RETURN TRUE;
END;


-- AFTERREPORT
-- Clears HXC_RPT_TC_AUDIT after the reporting is done.

FUNCTION afterreport
RETURN BOOLEAN
AS

BEGIN

    -- Public Procedure afterreport
    -- Truncates table HXC_RPT_TC_AUDIT after reporting is done.
    -- Is called from HXCRPTAUD.xml file.

    --DELETE FROM hxc_rpt_tc_audit;
    COMMIT;

    RETURN TRUE;
END;

FUNCTION beforereport
RETURN BOOLEAN
AS

BEGIN
    RETURN TRUE;
END;


-- TRANSLATE_PARAMETERS
-- Translates all the ids that are provided as parameters to the names for
-- display in the report.

PROCEDURE translate_parameters
AS

BEGIN

    -- Public Procedure translate_parameters
    -- Browse thru all the parameters, to check if they are NULL.
    -- If anything is not null, get the relevant names from corresponding
    --     tables.
    -- Convert the from,to,sysdate, data_regen and record_save flags
    -- anyway, because you need them always.



    IF g_debug
    THEN
       hr_utility.trace('translate_parameters');
    END IF;

    lp_from_date := to_char(fnd_date.canonical_to_date(p_from_date),'dd-MON-yyyy');
    lp_to_date := to_char(fnd_date.canonical_to_date(p_to_date),'dd-MON-yyyy');

    IF p_record_save = 'Y'
    THEN
       lp_record_save := 'Yes';
    ELSE
       lp_record_save := 'No';
    END IF;

    IF P_DAT_REGEN = 'Y'
    THEN
       lp_dat_regen := 'Yes';
    ELSE
       lp_dat_regen := 'No';
    END IF;


    IF (p_org_id IS NOT NULL)
    THEN
       SELECT name
         INTO lp_org
         FROM hr_all_organization_units_tl
        WHERE organization_id = p_org_id
          AND language = USERENV('LANG');

    END IF;

    IF (p_locn_id IS NOT NULL)
    THEN
       SELECT location_code
         INTO lp_location
         FROM hr_locations_all_tl
        WHERE location_id = p_locn_id
          AND language = USERENV('LANG');

    END IF;

    IF (p_payroll_id IS NOT NULL)
    THEN
       SELECT payroll_name
         INTO lp_payroll
         FROM pay_all_payrolls_f
        WHERE payroll_id = p_payroll_id
          AND fnd_date.canonical_TO_DATE(p_from_date) BETWEEN effective_start_date
                                                          AND effective_END_date;

    END IF;

    IF (p_supervisor_id IS NOT NULL)
    THEN
       SELECT full_name
         INTO lp_supervisor
         FROM per_all_people_f
        WHERE person_id = p_supervisor_id
          AND SYSDATE BETWEEN effective_start_date
                          AND effective_END_date;

    END IF;

    IF (p_person_id IS NOT NULL)
    THEN
       SELECT full_name
         INTO lp_person
         FROM per_all_people_f
        WHERE person_id = p_person_id
          AND SYSDATE BETWEEN effective_start_date
                          AND effective_END_date;

    END IF;

    lp_sysdate := TO_CHAR(SYSDATE,'dd-Mon-yyyy HH:MI:SS ');


    SELECT fnd.user_name||' ['||ppf.full_name||']'
      INTO lp_user
      FROM per_all_people_f ppf,
           fnd_user fnd
     WHERE ppf.person_id = fnd.employee_id
       AND SYSDATE BETWEEN ppf.effective_start_date
                       AND ppf.effective_end_date
       AND fnd.user_id = FND_GLOBAL.USER_ID;



    IF g_debug
    THEN
       hr_utility.trace('Translated parameters normally ');
       hr_utility.trace('lp_from_date   : '||lp_from_date);
       hr_utility.trace('lp_to_date     : '||lp_to_date);
       hr_utility.trace('lp_dat_regen   : '||lp_dat_regen);
       hr_utility.trace('lp_record_save : '||lp_record_save);
       hr_utility.trace('lp_org         : '||lp_org);
       hr_utility.trace('lp_location    : '||lp_location);
       hr_utility.trace('lp_payroll     : '||lp_payroll);
       hr_utility.trace('lp_supervisor  : '||lp_supervisor);
       hr_utility.trace('lp_person      : '||lp_person);
       hr_utility.trace('lp_user        : '||lp_user);
    END IF;

END translate_parameters;



-- EXECUTE_AUDIT_TRAIL_REPORTING
-- Main action block for Timecard Audit Trail Reporting, processes
-- the detail records accordingly, and loads data into HXC_RPT_TC_AUDIT.

PROCEDURE execute_audit_trail_reporting  (errbuf          OUT NOCOPY VARCHAR2,
                                          retcode         OUT NOCOPY NUMBER,
                                          p_date_from     IN VARCHAR2 ,
                                          p_date_to       IN VARCHAR2 ,
                                          p_data_regen    IN VARCHAR2 ,
                                          p_record_save   IN VARCHAR2 ,
                                          p_org_id        IN NUMBER DEFAULT NULL,
                                          p_locn_id       IN NUMBER DEFAULT NULL,
                                          p_payroll_id    IN NUMBER DEFAULT NULL,
                                          p_supervisor_id IN NUMBER DEFAULT NULL,
                                          p_person_id     IN NUMBER DEFAULT NULL )
AS

  l_call_status  BOOLEAN ;
  l_interval     NUMBER := 30;
  l_phase        VARCHAR2(30);
  l_status       VARCHAR2(30);
  l_dev_phase    VARCHAR2(30);
  l_dev_status   VARCHAR2(30);
  l_message      VARCHAR2(30);
  l_sqlcode      NUMBER;
  l_sqlmsg       VARCHAR2(100);


  l_data_load_request_id NUMBER;
  l_resource_id      NUMBER;
  l_start_time       DATE;
  l_stop_time        DATE;
  l_resource_count   NUMBER := 0;

  CURSOR get_timecards ( p_request_id  NUMBER)
      IS SELECT resource_id,
                tc_start_time,
                tc_stop_time
           FROM hxc_rpt_tc_hist_log log
          WHERE request_id = p_request_id  ;

l_trans_id_tab       FLOATTABLE;
l_trans_date_tab     DATETABLE;
l_trans_max_date_tab DATETABLE;
l_trans_user_tab     VARCHARTABLE;
l_trans_name_tab     VARCHARTABLE;
l_comments_tab       VARCHARTABLE;
l_bb_id_tab          NUMTABLE;
l_bb_ovn_tab         NUMTABLE;
l_max_bb_id_tab      NUMTABLE;
l_trans_status_tab   VARCHARTABLE;


l_del_bb_id_tab    NUMTABLE;
l_del_bb_ovn_tab   NUMTABLE;
l_del_date_tab     DATETABLE;
l_del_id_tab       FLOATTABLE;





--   EXECUTE AUDIT TRAIL REPORTING -- FUNCTIONAL FLOW
--   ================================================
--
--   This prog is used to created the Change history for each timecard, whose
--   information is retrieved from HXC_TIME_ATTRIBUTES, HXC_TIME_BUILDING_BLOCKS
--   and HXC_TRANSACTIONS.
--
--   The processing is done per timecard -- meaning the table HXC_RPT_TC_DETAILS_ALL
--   table is grouped by resource_id, start_time and stop_time for each iteration
--   of processing.
--
--   Timecard Level Actions
--   ======================
--
--   Submissions
--   -----------
--
--   In ideal case, each submission would mean a different transaction_id with atleast
--   one detail building block id in SUBMITTED status.  For Self Service, Transaction
--   is created only when there is a Submission, not for timecard Save, but Timekeeper
--   creates a Deposit Transaction for timecard Save as well. So the most basic submission
--   has to be captured by looking for distinct DEPOSIT transactions, with Time building
--   blocks which are not in WORKING status. In Self service, there is no way you are going
--   to submit a timecard with ERROR status, but Timekeeper can do so. Meaning, we are
--   showing ERROR status as such too.
--
--   For the record_save option, a different query would run and pick up the WORKING
--   status guys as well.
--
--   Approvals
--   ---------
--
--   Timecard approvals normally are captured by the APPLICATION_PERIOD scope records
--   from hxc_time_building_blocks. A join with our Details_all table and hxc_time_building
--   blocks will give you this information. Once you get all the approvals, these has to be placed
--   so that the reporting table will get this info in proper place. For this, the submissions
--   captured above are browsed thru and a most appropriate submission is found out.
--   The transaciton_id of this submission is taken in as the transaction id of the approval
--   action and while the report groups the data on transaction_id, we get in the proper order.
--   The most appropriate approval is a transaction_id whose action date is equal to
--   ( only for Approval on submit style ) or less than the action date for the approval,
--   and who has a successive transaction_id with action date greater than the
--   approval date.
--
--   eg.    Approval date               Transaction_dates
--          08:05:11                     07:50:33
--                                       07:59:15
--                                       08:03:52
--                                       08:13:34
--                                       09:45:23
--
--      Here the given approval will take the transaction id of 08:03:52.
--
--
--
--   Deletions
--   ---------
--
--   Deletions can be of two kinds.
--
--     1)  Deletion from Recent Timecards page.
--     2)  Overwriting with a Template. -- This is deletion and resubmission.
--
--    The first case is straight forward.  When a timecard is deleted this way
--    its all time_building_blocks are end dated, and a new set will be
--    created with the created date equal to date_to. We track this down by
--    looking at transactions where the creation_date is equal to date_to
--    and day_date_to ( date_to of the parent day building block ) is
--    end dated.  Actually for the first case day_date_to is equal to the
--    creation_date and date_to of the detail record, and this is the only
--    thing you need to check. This also means that a negative condition should
--    be added to evade this whilst recording submissions.
--
--    The second case is slightly more complex. Here the details are end dated
--    but a new set wont be created.  The worst part is that there might be a
--    one or two seconds delay on the date_to timing for the existing set of
--    time_building_blocks -- Meaning, the existing OVN of Timecard.Day and
--    Detail scopes will have different date_to values. This is exactly the
--    reason why we cant equate date_to of the detail record to the day scope
--    record and pick up the deleted timecards even in the above case.
--
--    To escape this, we pick up all records having date_to = creation_date.
--    This will pick up records with Timecard Delete as we would expect,
--    Overwriting, again expected and those for which a row delete happened
--    in the time entry page.  Those for which the row delete happened in the time
--    entry page would not have a new timebuilding block id for the submitted timecard.
--    Where as a template overwritten timecard will have a new set of time building
--    block ids.
--
--    In either case, the entries would be tracked down as Submissions earlier --
--    because though you are deleting timecard as a whole ( while overwriting )
--    or deleting a line from the timecard ( while deleting from the time entry
--    screen ), the rest of the timecard is submitted.  So loop thru the submissions
--    and pick up the transaction of the deletion we are processing.
--    For this, check if the max timecard id and min timecard id for the transaction
--    are same to the deleted timecards timecard id.
--
--    TC bb id    OVN   date_to
--    1            1    end of time
--
--    When deleted from the Recent timecards page.
--
--    TC bb id    OVN    date_to
--    1            1     sysdate
--
--    When deleting a row from the Time entry page.
--
--    TC bb id    OVN    date_to
--    1            1     sysdate
--    1            2     end of time
--
--    When overwriting with a template
--
--    Tc bb id    OVN    date_to
--    1            1     sysdate
--    2            1     end of time.
--
--
--    Now the first case will be anyway captured from the query, and there neednt
--    be any check on this, because the transaction that is holding it will not
--    be picked up in submissions.
--
--    For the second case, we dont want this as a timecard delete, so compare the
--    transactions max tc bb id and min tc bb id. Both will be the same, so dont
--    use this record.
--
--    For the third case the comparison would fail and we have to consider this as
--    a deletion.
--
--      As of now, we are not considering a separate query for Deletions with Record save
--      option toggling.  This is because, as of now, in 12.1.1, a deleting an entry
--      and saving the timecard yields a Submitted status time entry as well.  This would
--      take care of Deletion with Working status being recorded.
--
--
--
--    Detail Changes
--    --------------
--
--    The logic followed here is put inline for more clarity.
--
--
--
--
--    ACTION_TYPE column
--    ==================
--
--    HXC_RPT_TC_AUDIT has this column called Action_type which is used particularly
--    in ordering the entries while querying for the report.
--
--
--    Timecard Level Actions
--    -----------------------
--
--    TS                      ---    Timecard Submission
--    TSD                     ---    Timecard Deletion
--    TSA                     ---    Timecard Approval
--
--
--    These are named so to ease out ordering.  A Deletion or an Approval cannot
--    happen without a Submission, hence TS ( alphabetically, the first of the three).
--    Once submitted, the next action that might come would be Deletion or Approval.
--    But in no way can a Deletion be followed by Approval. It has to be
--    either Sub->Appr->Deletion or Sub->Deletion, meaning Deletion will always
--    come to the end in the transaction. Hence TSD for Deletion and TSA for approval
--    because approval falls b/w the other two, if at all it falls.
--
--
--
--    Detail Level Actions
--    ---------------------
--
--    EN                      ---     New Entry/Late Entry
--    EB                      ---     Before Edit
--    EC                      ---     After Edit
--    ED                      ---     Deleted
--
--
--
--    No complex logic here. Only Before/After Edit can come together, for the same
--    date-detail.  Hence EB and EC respectively, because Before Edit should appear
--    first.
--
--






  -- RECORD_SUBMISSIONS
  -- Queries against HXC_RPT_TC_DETAILS_ALL and captures all the timecard
  -- submissions.

  PROCEDURE record_submissions( p_resource_id  IN NUMBER,
                                p_start_time   IN DATE,
                                p_stop_time    IN DATE,
                                p_record_save  IN VARCHAR2)
  AS




     -- The following two queries have been given conditions for a range
     -- for a date check.  Creation_date and day_date_to logically could be
     -- the same value, but for big timecards you would see a one or 2 secs delay.
     -- Meaning, we check for this condition in a range, rather than an inequality.
     --

  CURSOR get_transactions ( p_resource_id NUMBER,
                            p_start_time  DATE,
                            p_stop_time   DATE )
      IS SELECT transaction_id,
                MAX(creation_date),
                MIN(creation_date),
                MIN(created_by_user),
                MIN(tc_comments),
                MIN(tc_bb_id),
                MIN(tc_bb_ovn),
                MAX(tc_bb_id),
                MIN(resource_name),
                MIN(status)
           FROM hxc_rpt_tc_details_all
          WHERE resource_id   = p_resource_id
            AND tc_start_time = p_start_time
            AND tc_stop_time  = p_stop_time
            AND creation_date NOT BETWEEN (day_date_to - (2/(24*60*60)))
                                      AND (day_date_to + (2/(24*60*60)))
            AND transaction_id IS NOT NULL
            AND transaction_detail_id IS NOT NULL
            AND status <> 'WORKING'
          GROUP BY transaction_id
          ORDER BY MIN(creation_date) ;

  CURSOR get_all_transactions ( p_resource_id NUMBER,
                            p_start_time  DATE,
                            p_stop_time   DATE )
      IS SELECT transaction_id,
                MAX(creation_date),
                MIN(creation_date),
                MIN(created_by_user),
                MIN(tc_comments),
                MIN(tc_bb_id),
                MIN(tc_bb_ovn),
                MAX(tc_bb_id),
                MIN(resource_name),
                MIN(decode(transaction_detail_id,NULL,'WORKING',status))
           FROM hxc_rpt_tc_details_all
          WHERE resource_id   = p_resource_id
            AND tc_start_time = p_start_time
            AND tc_stop_time  = p_stop_time
            AND creation_date NOT BETWEEN (day_date_to - (2/(24*60*60)))
                                      AND (day_date_to + (2/(24*60*60)))
            AND transaction_id IS NOT NULL
          GROUP BY transaction_id
          ORDER BY MIN(creation_date) ;


  BEGIN

      -- Private Procedure record_submissions
      -- Query from HXC_RPT_TC_DETAILS_ALL, grouping by transaction
      --       id for this timecard, and pick up all the distinct
      --       transaction ids, and relevant info like the users, dates
      --       timecard_id, ovn, etc.
      -- Insert into HXC_RPT_TC_AUDIT, the picked up information.

      IF g_debug
      THEN
         hr_utility.trace('record_submissions for '||p_resource_id
                        ||' from '||p_start_time
                        ||' to '||p_stop_time);
      END IF;

      IF p_record_save = 'Y'
      THEN
          OPEN get_all_transactions(p_resource_id,
      	                        p_start_time,
      	                        p_stop_time );

      	  FETCH get_all_transactions BULK COLLECT INTO l_trans_id_tab,
      	                                           l_trans_max_date_tab,
      	                                           l_trans_date_tab,
      	                                           l_trans_user_tab,
      	                                           l_comments_tab,
      	                                           l_bb_id_tab,
      	                                           l_bb_ovn_tab,
      	                                           l_max_bb_id_tab,
      	                                           l_trans_name_tab,
      	                                           l_trans_status_tab ;
      	  CLOSE get_all_transactions;
      ELSE
          OPEN get_transactions(p_resource_id,
      	                        p_start_time,
      	                        p_stop_time );

      	  FETCH get_transactions BULK COLLECT INTO l_trans_id_tab,
      	                                           l_trans_max_date_tab,
      	                                           l_trans_date_tab,
      	                                           l_trans_user_tab,
      	                                           l_comments_tab,
      	                                           l_bb_id_tab,
      	                                           l_bb_ovn_tab,
      	                                           l_max_bb_id_tab,
      	                                           l_trans_name_tab,
      	                                           l_trans_status_tab ;
      	  CLOSE get_transactions;
      END IF;

      IF g_debug
      THEN
         hr_utility.trace('Fetched from get_transactions ');
         hr_utility.trace('Total number of submissions : '||l_trans_id_tab.COUNT);
      END IF;


      IF l_trans_id_tab.COUNT > 0
      THEN
         FORALL i IN l_trans_id_tab.FIRST..l_trans_id_tab.LAST
              INSERT INTO hxc_rpt_tc_audit
                         ( resource_id,
                           tc_start_time,
                           tc_stop_time,
                           resource_name,
                           action,
                           action_date,
                           action_by,
                           comments,
                           transaction_id,
                           tc_bb_id,
                           tc_bb_ovn,
                           action_type )
                   VALUES ( p_resource_id,
                            p_start_time,
                            p_stop_time,
                            l_trans_name_tab(i),
                            INITCAP(DECODE(l_trans_status_tab(i),'WORKING','Saved',l_trans_status_tab(i))),
                            l_trans_max_date_tab(i),
                            l_trans_user_tab(i),
                            l_comments_tab(i),
                            l_trans_id_tab(i),
                            l_bb_id_tab(i),
                            l_bb_ovn_tab(i),
                            'TS' );
      END IF;

      IF g_debug
      THEN
         hr_utility.trace('record_submissions completed alright ');
      END IF;


  END record_submissions ;



  -- RECORD_APPROVALS
  -- Queries against HXC_TIME_BUIDLING_BLOCKS to capture the
  -- Approval details for this timecard.

  PROCEDURE record_approvals ( p_resource_id   IN NUMBER,
                               p_start_time    IN DATE,
                               p_stop_time     IN DATE )
  AS


  CURSOR get_approvals ( p_resource_id NUMBER,
                         p_start_time  DATE,
                         p_stop_time   DATE )
      IS SELECT 0 transaction_id,
                0 tc_bb_id,
                hxc.creation_date,
                fnd.user_name ,
                NVL(fnd.employee_id,-1),
                INITCAP(approval_status),
                DECODE(comment_text,
                       'LIGHT_APPROVAL','Approval On Submit',
                       'AUTO_APPROVE',  'Auto Approved',
                       comment_text),
                ' '
           FROM hxc_time_building_blocks hxc,
                fnd_user fnd
          WHERE scope = 'APPLICATION_PERIOD'
            AND resource_id        = p_resource_id
            AND p_start_time BETWEEN start_time
                                 AND stop_time
            AND TRUNC(p_stop_time) BETWEEN start_time
                                       AND stop_time
            AND approval_status IN ('APPROVED','REJECTED')
            AND fnd.user_id = hxc.created_by
            AND NVL(hxc.comment_text,' ') <> 'TIMED_OUT'
            AND NVL(hxc.comment_text,' ') <> 'BLANK_NOTIFICATION'
         ORDER BY hxc.creation_date ;



  CURSOR get_approvers ( p_person_id   NUMBER,
                         p_appr_date   DATE )
      IS SELECT full_name
           FROM per_all_people_f
          WHERE person_id   = p_person_id
            AND p_appr_date BETWEEN effective_start_date
                                AND effective_end_date ;



  l_appr_trans_tab    NUMTABLE;
  l_appr_bb_tab       NUMTABLE;
  l_appr_date_tab     DATETABLE;
  l_appr_user_tab     VARCHARTABLE;
  l_appr_status_tab   VARCHARTABLE;
  l_appr_comments_tab VARCHARTABLE;
  l_appr_resource_tab VARCHARTABLE;
  l_appr_person_tab   NUMTABLE;
  l_approver_name     VARCHAR2(400);

  BEGIN

      -- Private Procedure record_approvals
      -- Queries against HXC_TIME_BUILDING_BLOCKS and FND_USER
      --      for all the APPLICATION_PERIOD records for this timecard.
      --      The application periods are joined with BETWEEN & AND
      --      conditions to pull up those timecards whose Approval period
      --      spans across multiple timecard periods.
      -- To find out the user's name fetch the full name from PER_ALL_PEOPLE_F.
      -- To find out the transaction/submission that matches these approvals,
      --      loops thru the transaction date pl/sql table already created, to find
      --      a matching transaction.
      -- Once all the transactions are picked up, inserts the records into HXC_RPT_TC_AUDIT.

      IF g_debug
      THEN
         hr_utility.trace('record_approvals for '||p_resource_id
                        ||' from '||p_start_time
                        ||' to '||p_stop_time);
      END IF;

      OPEN get_approvals (p_resource_id,
                          p_start_time,
                          p_stop_time ) ;

      FETCH get_approvals BULK COLLECT INTO l_appr_trans_tab,
                                            l_appr_bb_tab,
                                            l_appr_date_tab,
                                            l_appr_user_tab,
                                            l_appr_person_tab,
                                            l_appr_status_tab,
                                            l_appr_comments_tab,
                                            l_appr_resource_tab ;

       CLOSE get_approvals;

       IF g_debug
       THEN
          hr_utility.trace('Fetched from get_approvals ');
          hr_utility.trace('Total number of approvals : '||l_appr_trans_tab.COUNT);
       END IF;


       IF l_appr_trans_tab.COUNT > 0
       THEN
          FOR i IN l_appr_trans_tab.FIRST..l_appr_trans_tab.LAST
          LOOP

             -- Initialize the approver's name to blank.
             l_approver_name := ' ';

             -- Do this only if there exists a valid person. -1 here would mean
             -- a null for employee_id in FND_USER, so the person who approved
             -- is a dummy person like SYSADMIN.

             IF l_appr_person_tab(i) <> -1
             THEN
                OPEN get_approvers( l_appr_person_tab(i),
                                    l_appr_date_tab(i) );
                FETCH get_approvers INTO l_approver_name;
                CLOSE get_approvers;
             END IF;

             l_appr_user_tab(i) := l_appr_user_tab(i)||newline
                                         ||'['||l_approver_name||']';

             -- Bug 9137834
             -- Added the following IF condition to take care of
             -- BLANK auto approved timecards.
             IF l_trans_id_tab.COUNT > 0
             THEN

                FOR j IN l_trans_id_tab.FIRST..l_trans_id_tab.LAST-1
             	LOOP

             	   IF ( (l_trans_date_tab(j) <= l_appr_date_tab(i))
             	      AND (l_trans_date_tab(j+1) > l_appr_date_tab(i)))
             	   THEN
             	      l_appr_trans_tab(i) := l_trans_id_tab(j);
             	      l_appr_bb_tab(i)    := l_bb_id_tab(j);
             	      l_appr_resource_tab(i) := l_trans_name_tab(j);
             	      EXIT;
             	   END IF;
             	END LOOP;

             	IF l_appr_trans_tab(i) = 0
             	THEN
             	    l_appr_trans_tab(i) := l_trans_id_tab(l_trans_id_tab.LAST);
             	    l_appr_bb_tab(i) := l_bb_id_tab(l_bb_id_tab.LAST);
             	    l_appr_resource_tab(i) := l_trans_name_tab(l_bb_id_tab.LAST);
             	END IF;

             END IF;

           END LOOP;

          FORALL i IN l_appr_trans_tab.FIRST..l_appr_trans_tab.LAST
                 INSERT INTO hxc_rpt_tc_audit
                         ( resource_id,
                           tc_start_time,
                           tc_stop_time,
                           resource_name,
                           action,
                           action_date,
                           action_by,
                           comments,
                           transaction_id,
                           tc_bb_id,
                           action_type )
                    VALUES ( p_resource_id,
                             p_start_time,
                             p_stop_time,
                             l_appr_resource_tab(i),
                             l_appr_status_tab(i),
                             l_appr_date_tab(i),
                             l_appr_user_tab(i),
                             l_appr_comments_tab(i),
                             l_appr_trans_tab(i),
                             l_appr_bb_tab(i),
                             'TSA' );

       l_appr_trans_tab.DELETE;
       l_appr_bb_tab.DELETE;
       l_appr_date_tab.DELETE;
       l_appr_user_tab.DELETE;
       l_appr_resource_tab.DELETE;
       l_appr_status_tab.DELETE;
       l_appr_comments_tab.DELETE;


      END IF;

      IF g_debug
      THEN
         hr_utility.trace('record_approvals completed alright ');
      END IF;



  END record_approvals ;




  -- RECORD_DELETIONS
  -- Queries against HXC_RPT_TC_DETAILS_ALL to find out all the timecard
  -- deletions, and records these into HXC_RPT_TC_AUDIT.

  PROCEDURE record_deletions  ( p_resource_id  IN NUMBER,
                                p_start_time   IN DATE,
                                p_stop_time    IN DATE )
  AS

  CURSOR get_deletions ( p_resource_id NUMBER,
                            p_start_time  DATE,
                            p_stop_time   DATE )
      IS SELECT transaction_id,
                MIN(creation_date),
                MIN(created_by_user),
                MIN(tc_comments),
                MIN(tc_bb_id),
                MIN(tc_bb_ovn),
                MIN(resource_name)
           FROM hxc_rpt_tc_details_all det
          WHERE resource_id   = p_resource_id
            AND tc_start_time = p_start_time
            AND tc_stop_time  = p_stop_time
            AND day_date_to   <> hr_general.end_of_time
            AND creation_date  = date_to
            AND transaction_id IS NOT NULL
            AND status <> 'WORKING'
            AND NOT EXISTS ( SELECT 1
                               FROM hxc_timecard_summary hxc
                              WHERE timecard_id = det.tc_bb_id
                                AND hxc.resource_id  = det.resource_id
                                AND hxc.start_time   = det.tc_start_time
                            )
          GROUP BY transaction_id
          ORDER BY MIN(creation_date) ;




  l_del_comments_tab VARCHARTABLE;
  l_del_user_tab     VARCHARTABLE;
  l_del_name_tab     VARCHARTABLE;



  BEGIN


      -- Private Procedure record_deletions
      -- Queries against HXC_RPT_TC_DETAILS_ALL table for all records
      --      that have creation_date = deleted date for the day record
      --      These indicate a timecard delete.
      -- Insert these including the transaction_ids into HXC_RPT_TC_AUDIT.

      IF g_debug
      THEN
         hr_utility.trace('record_deletions for '||p_resource_id
                        ||' from '||p_start_time
                        ||' to '||p_stop_time);
      END IF;


      OPEN get_deletions   (p_resource_id,
                            p_start_time,
                            p_stop_time );
      FETCH get_deletions BULK COLLECT INTO l_del_id_tab,
                                            l_del_date_tab,
                                            l_del_user_tab,
                                            l_del_comments_tab,
                                            l_del_bb_id_tab,
                                            l_del_bb_ovn_tab,
                                            l_del_name_tab ;
      CLOSE get_deletions;

      IF g_debug
      THEN
         hr_utility.trace('Fetched from get_deletions ');
         hr_utility.trace('Total number of deletions : '||l_del_id_tab.COUNT);
      END IF;


      IF l_del_id_tab.COUNT > 0
      THEN
         FOR i IN l_del_id_tab.FIRST..l_del_id_tab.LAST
         LOOP
            FOR j IN l_trans_id_tab.FIRST..l_trans_id_tab.LAST
            LOOP
               IF l_trans_id_tab(j) = l_del_id_tab(i)
               THEN

                  IF l_max_bb_id_tab(j) = l_del_bb_id_tab(i)
                  THEN
                    l_del_id_tab(i) := 0;
                    EXIT;
                  END IF;   -- l_max_bb_id_tab(j) = l_bb_id_tab(j)

                  IF l_trans_id_tab.EXISTS(j-1)
                  THEN
                      l_del_id_tab(i) := l_trans_id_tab(j-1) ;
                  ELSE
                     l_del_id_tab(i) := l_del_id_tab(i) - 1;
                  END IF; -- l_trans_id_tab.EXISTS(j-1)
                  EXIT;   -- l_trans_id_tab.FIRST..l_trans_id_tab.LAST
               END IF;    -- l_trans_id_tab(j) = l_del_id_tab(i)
            END LOOP;     -- l_trans_id_tab.FIRST..l_trans_id_tab.LAST
         END LOOP;        -- l_del_id_tab.FIRST..l_del_id_tab.LAST



         FOR i IN l_del_id_tab.FIRST..l_del_id_tab.LAST
         LOOP
            IF l_del_id_tab(i) <> 0
            THEN
              INSERT INTO hxc_rpt_tc_audit
                         ( resource_id,
                           tc_start_time,
                           tc_stop_time,
                           resource_name,
                           action,
                           action_date,
                           action_by,
                           comments,
                           transaction_id,
                           tc_bb_id,
                           tc_bb_ovn,
                           action_type )
                   VALUES ( p_resource_id,
                            p_start_time,
                            p_stop_time,
                            l_del_name_tab(i),
                            'Deleted Timecard',
                            l_del_date_tab(i),
                            l_del_user_tab(i),
                            l_del_comments_tab(i),
                            l_del_id_tab(i),
                            l_del_bb_id_tab(i),
                            l_del_bb_ovn_tab(i),
                            'TSD' );
              END IF; -- l_del_id_tab(i) <> 0
         END LOOP;

      	 l_del_comments_tab.DELETE;
      	 l_del_user_tab.DELETE;
      	 l_del_name_tab.DELETE;

      END IF;

      IF g_debug
      THEN
         hr_utility.trace('record_deletions completed alright ');
      END IF;


  END record_deletions ;




  -- RECORD_DETAILS
  -- Queries against HXC_RPT_TC_DETAILS_ALL and records the detail records
  -- in the required format.


  PROCEDURE record_details ( p_resource_id  IN NUMBER,
                             p_start_time   IN DATE,
                             p_stop_time    IN DATE,
                             p_record_save  IN VARCHAR2 )
  AS

    l_audit_cnt  NUMBER := 0;
    temp1        VARCHAR2(500);
    temp2        VARCHAR2(500);

    l_tc_details       TIMEDETAILSTABLE;
    l_audit_details    AUDITTABLE ;

    l_delete_done      BOOLEAN;


   -- The following two queries have been given conditions for a range
   -- for a date check.  Creation_date and day_date_to logically could be
   -- the same value, but for big timecards you would see a one or 2 secs delay.
   -- Meaning, we check for this condition in a range, rather than an inequality.
   --
   CURSOR get_details ( p_resource_id NUMBER,
                       p_start_time  DATE,
                       p_stop_time   DATE )
      IS SELECT  *
           FROM hxc_rpt_tc_details_all
          WHERE resource_id           = p_resource_id
            AND tc_start_time 	      = p_start_time
            AND tc_stop_time  	      = p_stop_time
            AND creation_date         NOT BETWEEN (day_date_to - (2/(24*60*60)))
                                      AND (day_date_to + (2/(24*60*60)))
            AND transaction_id        IS NOT NULL
            AND transaction_detail_id IS NOT NULL
            AND status <> 'WORKING'
          ORDER BY detail_bb_id,
                   detail_bb_ovn ;


   CURSOR get_all_details ( p_resource_id NUMBER,
                            p_start_time  DATE,
                            p_stop_time   DATE )
      IS SELECT  *
           FROM hxc_rpt_tc_details_all
          WHERE resource_id   = p_resource_id
            AND tc_start_time = p_start_time
            AND tc_stop_time  = p_stop_time
            AND creation_date         NOT BETWEEN (day_date_to - (2/(24*60*60)))
                                      AND (day_date_to + (2/(24*60*60)))
            AND transaction_id IS NOT NULL
          ORDER BY detail_bb_id,
                   detail_bb_ovn ;


    -- COPY_TIMECARD_TO_AUDIT
    -- Copies the timecard record from HXC_RPT_TC_DETAILS_ALL to an
    -- audit record format, like the record structure in HXC_RPT_TC_AUDIT.

    PROCEDURE copy_timecard_to_audit (p_tc_record    IN            hxc_rpt_tc_details_all%ROWTYPE,
                                      p_audit_record IN OUT NOCOPY hxc_rpt_tc_audit%ROWTYPE)
    AS
    BEGIN

          -- Private Procedure copy_timecard_to_audit
          -- Copies timecard style record from HXC_RPT_TC_DETAILS_ALL
          --    to audit type after putting in necessary formatting, like
          --    concatenating all attributes, with a Line Feed as separator.

          p_audit_record.detail_bb_id  := p_tc_record.detail_bb_id;
          p_audit_record.detail_bb_ovn := p_tc_record.detail_bb_ovn;
          p_audit_record.time_entry_date := p_tc_record.day_start_time;
          p_audit_record.attribute_info :=
                 p_tc_record.attribute1||newline||p_tc_record.attribute2||newline||
                 p_tc_record.attribute3||newline||p_tc_record.attribute4||newline||
		 p_tc_record.attribute5||newline||p_tc_record.attribute6||newline||
		 p_tc_record.attribute7||newline||p_tc_record.attribute8||newline||
		 p_tc_record.attribute9||newline||p_tc_record.attribute10||newline||
  		 p_tc_record.attribute11||newline||p_tc_record.attribute12||newline||
		 p_tc_record.attribute13||newline||p_tc_record.attribute14||newline||
		 p_tc_record.attribute15||newline||p_tc_record.attribute16||newline||
		 p_tc_record.attribute17||newline||p_tc_record.attribute18||newline||
		 p_tc_record.attribute19||newline||p_tc_record.attribute20||newline||
		 p_tc_record.attribute21||newline||p_tc_record.attribute22||newline||
		 p_tc_record.attribute23||newline||p_tc_record.attribute24||newline||
		 p_tc_record.attribute25||newline||p_tc_record.attribute26||newline||
		 p_tc_record.attribute27||newline||p_tc_record.attribute28||newline||
		 p_tc_record.attribute29||newline||p_tc_record.attribute30;

          p_audit_record.attribute_info := LTRIM(RTRIM(p_audit_record.attribute_info,newline),newline) ;
          p_audit_record.hours := p_tc_record.hours_measure;
          p_audit_record.action_date := p_tc_record.creation_date;
          p_audit_record.action_by := p_tc_record.created_by_user;
          p_audit_record.comments := p_tc_record.detail_comments;
          p_audit_record.transaction_id := p_tc_record.transaction_id;
          p_audit_record.resource_id := p_tc_record.resource_id;
          p_audit_record.resource_name := p_tc_record.resource_name;
          p_audit_record.tc_start_time := p_tc_record.tc_start_time;
          p_audit_record.tc_stop_time  := p_tc_record.tc_stop_time;
          p_audit_record.cla_reason    :=
                       LTRIM(RTRIM(p_tc_record.cla_reason||'-'||
                         p_tc_record.cla_comments,'-'),'-');

          -- Code below added to include start stop times in the report.
          -- TO_CHAR(date,'HHMISSAM') will print the time in the following
          -- format.
          --   115959PM
          --  If the start, stop times are not given, the default time
          -- of <date> 11:59:59 PM would be the column value.
          --  Just check this up. If its not the default time, record it
          -- as start stop time.


          IF TO_CHAR(p_tc_record.day_stop_time,'HHMISSAM') <> '115959PM'
          THEN
              p_audit_record.start_stop_time := to_char(p_tc_record.day_start_time,'HH:MI AM')||newline||
                             to_char(p_tc_record.day_stop_time,'HH:MI AM');
          END IF;



      END copy_timecard_to_audit ;

      -- TIME_DETAILS
      -- For a given timecard record, from HXC_RPT_TC_DETAILS_ALL, returns a
      -- concatenated string of attributes, hours and comments.

      FUNCTION time_details( p_tc_record  IN hxc_rpt_tc_details_all%ROWTYPE )
      RETURN VARCHAR2
      AS
       time_detail VARCHAR2(4000);

      BEGIN -- time_details

           -- Private function time_details
           -- Concatenates the attributes, hours and detail comments and returns these as a
           --    string.
           time_detail := p_tc_record.attribute1||p_tc_record.attribute2||p_tc_record.attribute3||
			  p_tc_record.attribute4||p_tc_record.attribute5||p_tc_record.attribute6||
			  p_tc_record.attribute7||p_tc_record.attribute8||p_tc_record.attribute9||
			  p_tc_record.attribute10||p_tc_record.attribute11||p_tc_record.attribute12||
			  p_tc_record.attribute13||p_tc_record.attribute14||p_tc_record.attribute15||
			  p_tc_record.attribute16||p_tc_record.attribute17||p_tc_record.attribute18||
			  p_tc_record.attribute19||p_tc_record.attribute20||p_tc_record.attribute21||
			  p_tc_record.attribute22||p_tc_record.attribute23||p_tc_record.attribute24||
			  p_tc_record.attribute25||p_tc_record.attribute26||p_tc_record.attribute27||
			  p_tc_record.attribute28||p_tc_record.attribute29||p_tc_record.attribute30||
                          to_char(p_tc_record.day_start_time,'dd/mm/yy/hh24/mi/ss')||
                          to_char(p_tc_record.day_stop_time,'dd/mm/yy/hh24/mi/ss')||
			  p_tc_record.hours_measure||p_tc_record.detail_comments;
           RETURN time_detail;
      END time_details;


      -- INSERT_DETAILS
      -- Inserts all the audit records into HXC_RPT_TC_AUDIT.

      PROCEDURE insert_details
      AS

      BEGIN

          -- Private Procedure insert_details
          -- Inserts the details collected into audit record pl/sql table, into
          --     HXC_RPT_TC_AUDIT.

          IF g_debug
          THEN
             hr_utility.trace('Inserting details into hxc_rpt_tc_audit ');

             -- Commenting the below code, which logs all the detail info to be
             -- recorded into HXC_RPT_TC_AUDIT.  Not too much hit to performance,
             -- but uncomment and run only if you see that there is an issue in the way
             -- the details are getting framed.  Else, this would just add on hundreds
             -- of lines to your log files, nothing more.

             -- FOR i IN l_audit_details.FIRST..l_audit_details.LAST
             -- LOOP
             --    hr_utility.trace('Record No.'||i);
             --    hr_utility.trace('time_entry_date : '||l_audit_details(i).time_entry_date);
             -- 	hr_utility.trace('attribute_info : '||l_audit_details(i).attribute_info);
             -- 	hr_utility.trace('hours : '||l_audit_details(i).hours);
             -- 	hr_utility.trace('action : '||l_audit_details(i).action);
             -- 	hr_utility.trace('action_date : '||l_audit_details(i).action_date);
             -- 	hr_utility.trace('action_by : '||l_audit_details(i).action_by);
             -- 	hr_utility.trace('comments : '||l_audit_details(i).comments);
             -- 	hr_utility.trace('reasons : '||l_audit_details(i).reasons);
             -- 	hr_utility.trace('transaction_id : '||l_audit_details(i).transaction_id);
             -- 	hr_utility.trace('detail_bb_id : '||l_audit_details(i).detail_bb_id);
             -- 	hr_utility.trace('detail_bb_ovn : '||l_audit_details(i).detail_bb_ovn);
             -- 	hr_utility.trace('tc_bb_id : '||l_audit_details(i).tc_bb_id);
             -- 	hr_utility.trace('tc_bb_ovn : '||l_audit_details(i).tc_bb_ovn);
             -- 	hr_utility.trace('action_type : '||l_audit_details(i).action_type);
             -- 	hr_utility.trace('resource_id : '||l_audit_details(i).resource_id);
             -- 	hr_utility.trace('tc_start_time : '||l_audit_details(i).tc_start_time);
             -- 	hr_utility.trace('tc_stop_time : '||l_audit_details(i).tc_stop_time);
             -- 	hr_utility.trace('action_by_person : '||l_audit_details(i).action_by_person);
             -- 	hr_utility.trace('cla_reason : '||l_audit_details(i).cla_reason);
             -- 	hr_utility.trace('resource_name : '||l_audit_details(i).resource_name);
             -- END LOOP;

          END IF;

          FORALL i IN l_audit_details.FIRST..l_audit_details.LAST
               INSERT INTO hxc_rpt_tc_audit
                    VALUES l_audit_details(i);
         COMMIT;
      END insert_details ;


  BEGIN -- record_details


      -- Private Procedure record_details
      -- Pick up all the detail records from HXC_RPT_TC_DETAILS_ALL for this timecard into
      --    pl/sql table of HXC_RPT_TC_DETAILS_ALL rowtype, ordered by detail bb id. If
      --    p_record_save is set to Y, need to pick up WORKING status records also. In that
      --    case work with get_all_details cursor, else with get_details.
      -- Loop thru these picked up details.
      --    *  If the OVN is 1, then it is a New Entry, if its not a Late Entry.
      --       If CLA reason is NULL, then it is a New Entry, else its a Late Entry.
      --       If CLA reason is not NULL, but the entry was made well in time, its
      --       a Late Entry, just a New Entry.
      --    *  If OVN is not 1, then check if there is another element of the same
      --       bb id before this element. -- If yes, then its a changed entry,
      --       if the date_to column is not end of time, make sure this is an edited entry
      --       so record as After Edit after comparing the attributes of this element and
      --       the previous element.
      --       If there is no element prior to this with the same bb id, then its again a New
      --       Entry.
      --    *  Check the next entry in the table, if it is of the same bb id, then this is
      --       changed in the next transaction, so insert a record with Before Edit entry
      --       after fetching the proper transaction id and after checking if the attributes
      --       have changed.
      --    *  If the next entry with the same bb id is having an end date, then you know it is
      --       deleted in the next submission.  So create an entry saying Deleted.
      -- Once you have looped thru all the records, insert the details collected into HXC_RPT_
      -- TC_AUDIT.

      -- Inline comments are put in for more clarity.

      l_audit_details := audittable();

      IF p_record_save = 'Y'
      THEN
         OPEN get_all_details(p_resource_id,
                              p_start_time,
                              p_stop_time );

         FETCH get_all_details BULK
                            COLLECT INTO l_tc_details ;

         CLOSE get_all_details;
      ELSE
         OPEN get_details(p_resource_id,
                          p_start_time,
                          p_stop_time );

         FETCH get_details BULK
                        COLLECT INTO l_tc_details ;

         CLOSE get_details;
      END IF;

      IF g_debug
      THEN
         hr_utility.trace('Fetched details ');
         hr_utility.trace('Total Number of details fetched : '||l_tc_details.COUNT);
      END IF;


      IF l_tc_details.COUNT > 0
      THEN


      FOR i IN l_tc_details.FIRST..l_tc_details.LAST
      LOOP
          -- First of all, make sure if this entry is included in a Deletion
          -- ( A deletion can be a deletion from Recent timecards page or
          --   an Overwrite with template.  An Overwritten timecard entries
          --   neednt be shown again, and need to be trimmed off.  So check if
          --   this time entry belongs to a timecard previously recorded as
          --   Deleted )
          l_delete_done := FALSE;
          IF (     l_del_bb_id_tab.COUNT > 0
               AND l_tc_details(i).date_to <> hr_general.end_of_time )
          THEN
             FOR x IN l_del_bb_id_tab.FIRST..l_del_bb_id_tab.LAST
             LOOP
                IF (     l_del_bb_id_tab(x)  = l_tc_details(i).tc_bb_id
                     AND l_del_bb_ovn_tab(x) = l_tc_details(i).tc_bb_ovn
                     AND l_del_id_tab(x) <> 0
                    )
                THEN
                   -- Found out its true, so mark the flag.  We would use this flag before
                   -- inserting.
                   l_delete_done := TRUE;
                   EXIT;
                END IF;
              END LOOP;
           END IF;

          IF (l_tc_details(i).detail_bb_ovn = 1) OR
            (    (l_tc_details(i).detail_bb_ovn <> 1)
              AND l_tc_details.EXISTS(i-1) = FALSE ) OR
            (     l_tc_details.EXISTS(i-1) = TRUE
              AND l_tc_details(i-1).detail_bb_id <> l_tc_details(i).detail_bb_id)

          THEN -- new record
             l_audit_details.EXTEND;
             l_audit_cnt := l_audit_cnt + 1 ;
             copy_timecard_to_audit(l_tc_details(i),
                                    l_audit_details(l_audit_cnt));
             IF ( l_tc_details(i).cla_type = 'LATE'
                 AND TRUNC(l_tc_details(i).creation_date) >
                           TRUNC(l_tc_details(i).day_start_time) )
             THEN
                 l_audit_details(l_audit_cnt).action := 'Late Entry';
             ELSE
                 l_audit_details(l_audit_cnt).action := 'New Entry';
             END IF;
             l_audit_details(l_audit_cnt).action_type := 'EN' ;
          ELSE -- if not new record
             IF l_tc_details(i).detail_bb_id = l_tc_details(i-1).detail_bb_id
             THEN
                 temp1 :=    time_details(l_tc_details(i));
                 temp2 :=    time_details(l_tc_details(i-1));
                 IF temp1 <> temp2
                 THEN
                    l_audit_details.EXTEND(1);
                    l_audit_cnt := l_audit_cnt + 1 ;

                    copy_timecard_to_audit(l_tc_details(i),
                                           l_audit_details(l_audit_cnt) );
                    l_audit_details(l_audit_cnt).action := 'After Edit';
                    l_audit_details(l_audit_cnt).action_type := 'EC' ;
                 END IF; -- IF temp1 <> temp2
             END IF; -- IF l_tc_details(i-1).detail_bb_id = l_tc_details(i-1).detail_bb_id
          END IF;  -- IF new record

          IF l_tc_details(i).date_to <> hr_general.end_of_time
          THEN
             IF l_tc_details.EXISTS(i+1)
             THEN
                IF l_tc_details(i).detail_bb_id = l_tc_details(i+1).detail_bb_id
                THEN -- Changed Record
                   temp1 :=   time_details(l_tc_details(i));
                   temp2 :=   time_details(l_tc_details(i+1));
                   IF temp1 <> temp2
                   THEN -- Not just OVN, a real change
                        l_audit_details.EXTEND(1);
                        l_audit_cnt := l_audit_cnt + 1 ;
                        copy_timecard_to_audit(l_tc_details(i),
                                               l_audit_details(l_audit_cnt));
                        l_audit_details(l_audit_cnt).comments := l_tc_details(i).detail_comments;
                        l_audit_details(l_audit_cnt).transaction_id := l_tc_details(i+1).transaction_id;
                        l_audit_details(l_audit_cnt).action_by := l_tc_details(i).last_updated_by_user;
                        l_audit_details(l_audit_cnt).action := 'Before Edit';
                        l_audit_details(l_audit_cnt).action_type := 'EB' ;
                   END IF; -- IF temp1 <> temp2
                ELSE -- its deleted	 (l_tc_details(i).detail_bb_id = l_tc_details(i+1).detail_bb_id
                     --               is false )
                   FOR j IN l_trans_id_tab.FIRST..l_trans_id_tab.LAST
                   LOOP
                      IF (l_trans_date_tab(j) >= l_tc_details(i).date_to)
                        AND (l_bb_id_tab(j) = l_tc_details(i).tc_bb_id)
                      THEN
                          l_audit_details.EXTEND(1);
                          l_audit_cnt := l_audit_cnt + 1 ;
                          copy_timecard_to_audit(l_tc_details(i),
                                              l_audit_details(l_audit_cnt));
                          l_audit_details(l_audit_cnt).action_date := l_trans_date_tab(j);
                          l_audit_details(l_audit_cnt).action_by := l_tc_details(i).last_updated_by_user;
                          l_audit_details(l_audit_cnt).action := 'Deleted';
                          l_audit_details(l_audit_cnt).action_type := 'ED' ;
                          l_audit_details(l_audit_cnt).transaction_id :=
                                                  l_trans_id_tab(j);
                          EXIT;
                       -- Is the entry deleted, but still the next transaction is of
                       -- a different timecard id ? In that case, we only need to find
                       -- out if this belongs to a Deleted Timecard.  If not, we need
                       -- to mark it as a delete for next transaction anyway.
                       ELSIF (l_trans_date_tab(j) >= l_tc_details(i).date_to)
                         AND NOT l_delete_done
                        THEN
                          l_audit_details.EXTEND(1);
                          l_audit_cnt := l_audit_cnt + 1 ;
                          copy_timecard_to_audit(l_tc_details(i),
                                              l_audit_details(l_audit_cnt));
                          l_audit_details(l_audit_cnt).action_date := l_trans_date_tab(j);
                          l_audit_details(l_audit_cnt).action_by := l_tc_details(i).last_updated_by_user;
                          l_audit_details(l_audit_cnt).action := 'Deleted';
                          l_audit_details(l_audit_cnt).action_type := 'ED' ;
                          l_audit_details(l_audit_cnt).transaction_id :=
                                                  l_trans_id_tab(j);
                          EXIT;
                      END IF;  -- IF trans_date_tab = tc_details.date_to
                   END LOOP;  -- FOR j IN l_trans_id_tab
                END IF;  -- IF tc_details(i).bb_id = tc_details(i+1).bb_id
             ELSE -- l_tc_details.EXISTS
                FOR j IN l_trans_date_tab.FIRST..l_trans_date_tab.LAST
                LOOP
                   IF l_trans_date_tab(j) >= l_tc_details(i).date_to
                   THEN
                      l_audit_details.EXTEND(1);
                      l_audit_cnt := l_audit_cnt + 1 ;
                      copy_timecard_to_audit(l_tc_details(i),
                                     l_audit_details(l_audit_cnt));
                      l_audit_details(l_audit_cnt).action := 'Deleted';
                      l_audit_details(l_audit_cnt).action_type := 'ED' ;
                      l_audit_details(l_audit_cnt).action_date := l_trans_date_tab(j);
                      l_audit_details(l_audit_cnt).action_by := l_tc_details(i).last_updated_by_user;

                      l_audit_details(l_audit_cnt).transaction_id := l_trans_id_tab(j);
                      EXIT;
                   END IF;
                END LOOP;
             END IF;  -- l_tc_details.EXISTS
          END IF; -- IF l_tc_details(i).date_to <> '31-DEC-4712'
    END LOOP; -- FOR i IN l_tc_details.FIRST..l_tc_details.LAST

    insert_details;

    END IF;

    l_trans_id_tab.DELETE;
    l_trans_date_tab.DELETE;
    l_trans_user_tab.DELETE;
    l_comments_tab.DELETE;
    l_bb_id_tab.DELETE;
    l_bb_ovn_tab.DELETE;
    l_max_bb_id_tab.DELETE;
    l_trans_status_tab.DELETE;

    l_del_bb_id_tab.DELETE;
    l_del_bb_ovn_tab.DELETE;
    l_del_date_tab.DELETE;
    l_del_id_tab.DELETE;


    l_tc_details.DELETE;
    l_audit_details.DELETE;


  END record_details ;


BEGIN -- execute_audit_trail_reporting


   -- Public Procedure execute_audit_trail_reporting
   -- Take all the parameters and initiate request Load Timecard Snapshot
   --      passing all the parameters.
   -- While waiting for the request, translate all the parameters for display.
   -- Wait for the request to complete.
   -- Delete from HXC_RPT_TC_AUDIT, just in case last run crashed.
   -- Open get_timecards, passing in this request id, and fetch all the timecards.
   -- For each timecard,
   --    * Record the submissions.
   --    * Record approvals
   --    * Record deletions
   --    * Record details, and changes.
   -- Clear HXC_RPT_TC_AUDIT.


   IF g_debug
   THEN
      hr_utility.trace('execute_audit_trail_reporting');
      hr_utility.trace('Parameters ');
      hr_utility.trace('===========');
      hr_utility.trace('p_date_from     '||p_date_from);
      hr_utility.trace('p_date_to       '||p_date_to);
      hr_utility.trace('p_data_regen    '||p_data_regen);
      hr_utility.trace('p_record_save   '||p_record_save);
      hr_utility.trace('p_org_id        '||p_org_id);
      hr_utility.trace('p_locn_id       '||p_locn_id);
      hr_utility.trace('p_payroll_id    '||p_payroll_id);
      hr_utility.trace('p_supervisor_id '||p_supervisor_id);
      hr_utility.trace('p_person_id     '||p_person_id);
   END IF;


   -- Calling Load timecard snapshot passing the required parameters.

   l_data_load_request_id := FND_REQUEST.SUBMIT_REQUEST ( application => 'HXC',
                                                         program      => 'HXCRPTTCSN',
                                                         description => NULL,
                                                         sub_request => FALSE,
                                                         argument1   =>   p_date_from     ,
                                                         argument2    =>  p_date_to       ,
                                                         argument3    =>  p_data_regen    ,
                                                         argument4    =>  p_record_save   ,
                                                         argument5    =>  p_org_id        ,
                                                         argument6    =>  p_locn_id       ,
                                                         argument7    =>  p_payroll_id    ,
                                                         argument8    =>  p_supervisor_id ,
                                                         argument9    =>  p_person_id     );
   COMMIT;

   IF l_data_load_request_id = 0
   THEN
      hr_utility.trace('There was an error in submitting Load Timecard Snapshot ');
      hr_utility.trace('Sql Error : '||SQLCODE);
   END IF;


   -- Translate_parameters is to translate the given parameters to the process
   -- for display to the user. While the request waits for Load Timecard Snapshot
   -- process, translate these parameters. After it is finished, come back and wait
   -- for Load timecard Snapshot.

   translate_parameters;

   IF g_debug
   THEN
      hr_utility.trace('Request went to wait at '||to_char(sysdate,'dd-MON-yyyy HH:MI:SS'));
   END IF;

   l_call_status := FND_CONCURRENT.WAIT_FOR_REQUEST( request_id => l_data_load_request_id,
                                                     interval   => l_interval,
                                                     max_wait    => 0,
                                                     phase      => l_phase,
                                                     status     => l_status,
                                                     dev_phase  => l_dev_phase,
                                                     dev_status => l_dev_status,
                                                     message    => l_message );

   IF g_debug
   THEN
      hr_utility.trace('Request stopped at '||to_char(sysdate,'dd-MON-yyyy HH:MI:SS'));
   END IF;

   IF l_call_status = FALSE
   THEN
      IF g_debug
      THEN
         hr_utility.trace('There was an error in executing Load Timecard Snapshot ');
         hr_utility.trace('Sql Error : '||SQLCODE);
      END IF;
   END IF;

   -- Just in case the previous run crashed, clear the reporting table before you
   -- insert anything.

   DELETE FROM hxc_rpt_tc_audit;

   OPEN get_timecards(l_data_load_request_id);
   LOOP
      FETCH get_timecards INTO l_resource_id,
                               l_start_time,
                               l_stop_time ;
      EXIT WHEN get_timecards%NOTFOUND;

      IF g_debug
      THEN
         hr_utility.trace('Fetched from get_timecards ');
         hr_utility.trace('Resource id   : '||l_resource_id);
         hr_utility.trace('TC start time : '||l_start_time);
         hr_utility.trace('TC stop time  : '||l_stop_time);
      END IF;

      IF l_resource_count = 100
      THEN
         COMMIT;
         l_resource_count := 1;
      ELSE
         l_resource_count := l_resource_count + 1;
      END IF;

      -- Bug 9137834
      -- Added the exception block
      BEGIN
          record_submissions(l_resource_id,
      	                     l_start_time,
      	                     l_stop_time,
      	                     p_record_save);


      	  record_approvals (l_resource_id,
      	                    l_start_time,
      	                    l_stop_time );


      	  record_deletions(l_resource_id,
      	                   l_start_time,
      	                   l_stop_time );

      	  record_details(l_resource_id,
      	                 l_start_time,
      	                 l_stop_time,
      	                 p_record_save );
       EXCEPTION
               WHEN OTHERS THEN
                   hr_utility.trace('Error stack ');
                   hr_utility.trace(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
                   hr_utility.trace(' Exception '||SQLERRM||' while processing the following timecard ');
                   hr_utility.trace(' Resource_id '||l_resource_id);
                   hr_utility.trace(' Start_time  '||l_start_time);
                   hr_utility.trace(' Stop_time  '||l_stop_time);

      END;

   END LOOP;
   CLOSE get_timecards;
   COMMIT;
   IF g_debug
   THEN
      hr_utility.trace('Completed Audit Trail Reporting normally ');
      hr_utility.trace('Finished processing at '||TO_CHAR(SYSDATE,'dd-MON-yyyy HH:MI:SS'));
   END IF;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
         hr_utility.trace('No Data Found from execute_audit_trail_reporting ');

END execute_audit_trail_reporting;




END HXC_RPT_TC_AUDIT_TRAIL;


/
