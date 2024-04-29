--------------------------------------------------------
--  DDL for Package Body BEN_CWB_POST_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_POST_PROCESS" AS
/* $Header: bencwbpp.pkb 120.58.12010000.8 2010/02/02 11:49:41 sgnanama ship $ */
--
/* ============================================================================
* Name
*   Compensation Workbench Post Process
*
* Purpose
*   The purpose of this package is to perform the postprocess process of
* compensation workbench.
*
* History
*   23-DEC-01     aprabhak    115.0  created
*   08-FEB-02     aprabhak    115.1  next version
*   21-FEB-02     aprabhak    115.3  person with no WS  amount
*                                    will get the WS status updated to
*                                    processed
*   02-MAR-02     aprabhak    115.4  Added a new message for effective date
*                                    before assigned life event date
*   08-MAR-02     aprabhak    115.5  Modified the salary rise to consider
*                                    the precision. The logging will be done
*                                    only when you have the audit_log flag is
*                                    'Y'. Modified the choice loop to avoid
*                                    the multi-row edit for the persons of
*                                    x-bg. Modified the name of the routines
*                                    of default_comp_obj and process_default
*                                    _enrt.
*  10-MAR-02     aprabhak    115.6   The salary conversions now uses the newly
*                                    developed benutils routine plan_to_basis_
*                                    _conversion. Change the position of the
*                                    p_preson_id in the process routine.
*  11-MAR-02    aprabhak     115.7   added the per_pay_bases to the element
*                                    cursor and approved condition to the
*                                    salary cursor
*  15-MAR-02    aprabhak     115.8   after the pp runs the worksheet access
*                                    to RO it the prior access is updateable
*  18-MAR-02    aprabhak     115.9   the parameter p_annulization_factor is
*                                    changed to p_assignment_id to the call
*                                    to plan_to_basis_conversion.
*  27-MAR-02    aprabhak     115.10  Adding the business_group_id condition
*                                    to the c_pl_typ_rt_val cursor to avoid
*                                    full table scan.
*  03-Sep-02    maagrawa     115.11  Added new procedures for promotion
*                                    and performance rating updates.
*  08-Nov-02    aprabhak     115.12  Included the changes for itemization.
*  19-Feb-03    maagrawa     115.13  Make calls to ben_cwb_asg_update to
*                                    update performance and promotions.
*  05-Feb-03    aprabhak     115.14  Fixed 2815207
*  11-Mar-03    pbodla       115.15  Changes for : 2695023 - When pay proposal
*                                    is created link it to associated
*                                    participant rate row to allow backout if
*                                    needed.
*  13-Mar-03    pbodla       115.16  Changes for : 2695023 - Fixed typo in
*                                    update_prtt_rt_val api call.
*  20-Mar-03    aprabhak     115.17  Fixed 2857327 and 2357197.
*  20-May-03    aprabhak     115.18  Fixed 2968662.
*  18-Jun-03    aprabhak     115.19  Fixed 3011682
*  27-Jul-03    aprabhak     115.20  Fixed 3005203
*  09-sep-03    sthota       115.21  Modified the effective date format. Fixed
*                     3084042
*  09-Oct-03    sthota       115.26  Fixing the bug 3084042.
*  23-Nov-03    aprabhak     115.27  Fixing the bug 3259373.
*  02-Jan-04    aprabhak     115.28  Global Budgeting
*  10-Feb-04    aprabhak     115.29  Ignore backed out pils in pil cursor
*  22-Feb-04    aprabhak     115.31  Uncommented code for comp posting date
*  22-Feb-04    aprabhak     115.32  nvl condition to p_debug_level
*  08-Mar-04    aprabhak     115.36  Fixed 3490171.
*  09-Mar-04    aprabhak     115.37  Fixed the null rows in audit log report
*  16-Mar-04    aprabhak     115.38  For Drop3
*  20-Mar-04    aprabhak     115.39  Fixed 3490387, 3484230
*  25-May-04    maagrawa     115.40  Splitting of perf/promo record.
*  04-Jun-04    aprabhak     115.41  Corrected the threading issue.
*  04-Jun-04    aprabhak     115.42  Corrected the thread process name
*  29-Jun-04    aprabhak     115.43  Fixed the bug #3712169
*  30-Jun-04    aprabhak     115.44  bg_id passed to the assignment changes
*                                    is obtained ben_cwb_person_info
*  06-Jul-04    aprabhak     115.45  Access Change Routine
*  09-Jul-04    aprabhak     115.46  Recent Sal Change Message Corrected
*  14-Jul-04    aprabhak     115.47  fixed the issues reported in drop 13
*  22-Jul-04    aprabhak     115.48  Fixed the caching issues in error report.
*  10-Dec-04    aprabhak     115.49  Fixed bug#4030870
*  01-Feb-05    steotia      115.50  ben_cwb_audit_api call to record end of
*                                    Compensation event post process
*  31-May-05    steotia      115.51  Bugfix 4387327
*  25-Jul-05    steotia      115.52  Bugfix 4503153
*  28-Jul-05    maagrawa     115.53  4510733: Auto Aprove pay proposal
*                                    when components are involved.
*  01-Aug-05    steotia      115.54  Added NOCOPY hint
*  05-Oct-05    steotia      115.55  4607721: Fix in process of rating.
*  17-Nov-05    maagrawa     115.56  Do not error for terminated emps
*                                    when posting salary/elements.
*  28-Nov-05    maagrawa     115.57  4752433:Allow salary components along
*                                    with other compensation components.
*  30-Nov-05    maagrawa     115.58  Fixed no-data-found error with optName.
*  06-Dec-05    maagrawa     115.59  Fixed salary components cursors.
*  04-Jan-06    steotia      115.60  Override dates functionality added.
*  14-Feb-06    steotia      115.61  4997896:Termination check for perf/prom
*                                    not on run date but resp. eff/ovrd date
*  06-Mar-06    steotia      115.62  Enhancing logging for new audit report
*                                    and logging
*  16-Mar-06    steotia      115.63  same as above
*  21-Mar-06    steotia      115.64  equalising population across
*                                    compensation, perf or asgn changes
*  22-Mar-06    steotia      115.65  5109850: taking in LE date as varchar2
*  23-Mar-06    steotia      115.66  Fixing component plan logging
*                                    [l_warning_text size increased, logging
*					at -1 level also for component plan,
*                                    ws_sub_acty_typ_cd added to comp cursor],
*                                    All or nothing error flagging,
*                                    elmnt_processing_type for recurring el,
*                                    ineligible persons logged
* 03-Apr-06    steotia       115.67  Logging even in error for sal_rate
*                                    Element determintion rule called
* 07-Apr-06    steotia       115.68  5141153: Corrections on el. detn. rule
* 12-Apr-06    steotia       115.70  Fixing a possible char to numeric convern.
*                                    problem in extracting message number
* 26-Apr-06    steotia       115.71  Fixing component plan logging for plan
*                                    lvl amount posted record, checking
*                                    input currency of element, inserting
*                                    2 new error messages
* 29-Apr-06    steotia       115.73  Correcting sal change reason logic
* 10-May-06    steotia       115.74  5158117: Non-Mon rate exclusion
*                                    5181394: Future dated sal prop warning
* 16-May-06    steotia       115.75  5222874: missing data for recurring element
* 16-May-06    steotia       115.76  5158117: Salary basis element check add
* 19-May-06    steotia       115.78  Logging changes
* 14-Jul-06    steotia       115.79  Added force close of LE
* 17-Jul-06    steotia       115.80  5392779: Properly converting base_salary
*                                    5375170: String overflow error
* 11-Aug-06    steotia       115.81  5413842: In case of one emp in multiple
*                                    local plan
* 25-Aug-06    steotia       115.82  5487492: No force close in rollback
* 12-Sep-06    steotia       115.83  5413842: Downloads need complete rows
* 13-Sep-06    steotia       115.84  5483387: Wrong order of concatenation
* 13-Sep-06    steotia       115.85  5528259: (+) in c_posted_promotions reqd.
* 20-Sep-06    steotia       115.86  5531065: Using Performance Overrides (but
*                                    only if used through SS)
* 28-Sep-06    steotia       115.87  5413842: moving to parent thread
* 05-Oct-06    steotia       115.88  Putting do_not_process_flag check with
*                                    rates to take care of multiple
*                                    enrollments
* 17-Oct-06    steotia       115.89  5527054: using 5 precision if uom of
*                                    input_value is not null or Money
*                                    5460693: using option level effective
*                                    for salary proposal changes
* 02-Nov-06    steotia       115.90  5521472: if slave errors master errors
* 06-Nov-06    steotia       115.91  5235393: null->0 for amounts/salary
* 17-Nov-06    maagrawa      115.92  Do not post zeros or nulls for salary
*                                    components.
* 23-Nov-06    steotia       115.93  5659359: No more error stacking
*                                    3926221: Ineligs get no perf/promotion
*                                    3928529: process_access overhauled
*                                    trunc used to get effective date
* 18-Jan-07    maagrawa      115.94  Log old and new salary when salary
*                                    changed error is thrown.
* 04-Mar-07    steotia       115.95  5505775: CWB Enhancement
*				     Introducing Person Selection Rule
* 25-Apr-07    steotia       115.96  Closing LE of placeholder mgs also.
* 16-Jan-08    steotia       115.101 Compare rounded [proposal vs base sal]
*                                    Rate Start Date enabled
* 18-Jan-08    steotia       115.102 Checking for ws_abr_id for above
* 18-Jan-08    steotia       115.103 Overriding modified
* 08-Apr-08    sgnanama    115.104 Added p_use_rate_start_date in submit_request
* 22-Apr-08    cakunuru    115.105 Changed the cursor c_placeholder_selection:
*                                  will check for ineligible employees who are not managers.
* 7-May-08     sgnanama    115.106 selected business_group_id of the person in the
*                                  c_person_selection and c_placeholder_selection and pass
*                                  the same to the procedure evaluating the person seelction rule.
* 20-May-08   cakunuru    115.107 Changed the message in process_sal_comp_rates.
* 27-May-08   sgnanama    115.108  7126872:Added g_is_cwb_component_plan which is
*                                  used by salary api to distinguish unapproved
*                                  proposal from cwb
* 10-Jun-08   cakunuru    115.109 7155018: Added a condition for the cursor
*	                 c_pils_for_access to check for approval_cd with 'AP'.
* 10-Jun-08   cakunuru    115.110 Changed the dbdrv checkfile comment.
* 18-Aug-08  cakunuru    115.111  6994188: Set the effective_date as null if error occurs.
* 05-Nov-08  cakunuru    115.112  7042887: Modified reason to get the meaning
*			instead of reason code in the print_cache procedure.
* 13-Nov-08  sgnanama    115.113      7218121: Modified the check to assign the warning text
*                                     to p_cache_cwb_rpt_person in process_sal_comp_rates
* 10-Mar-09  cakunuru   115.14        8323386: Processesing only for eligible employess.
* 1-Feb-10 sgnanama 120.58.12010000.7 ER:8369634:Create zero percent increase/raise
* --------------------------------------------------------------------------------------
*/
--
-- Global cursor and variables declaration
--
  TYPE plan_override_date IS RECORD (
   plan ben_cwb_pl_dsgn.pl_id%type,
   date ben_cwb_pl_dsgn.ovrid_rt_strt_dt%type);

  TYPE g_override_date_t IS TABLE OF plan_override_date;

  TYPE plan_abr_info IS RECORD (
   pl_id ben_cwb_pl_dsgn.pl_id%type,
   oipl_id ben_cwb_pl_dsgn.oipl_id%type,
   element_type_id ben_cwb_pl_dsgn.ws_element_type_id%type,
   input_value_id ben_cwb_pl_dsgn.ws_input_value_id%type);

  TYPE g_abr_info_t IS TABLE OF plan_abr_info;

  g_package              VARCHAR2 (80) := 'BEN_CWB_POST_PROCESS';
  g_max_errors_allowed   NUMBER (9)    := 200;
  g_persons_errored      NUMBER (9)    := 0;
  g_persons_procd        NUMBER (9)    := 0;
  g_person_selected      NUMBER (9)    := 0;
  g_lf_evt_closed        NUMBER (9)    := 0;
  g_lf_evt_not_closed    NUMBER (9)    := 0;
  g_proc                 VARCHAR2 (80);
  g_actn                 VARCHAR2 (2000);
  g_debug_level          VARCHAR2 (1);
  g_slave_error          EXCEPTION;
  g_max_error            EXCEPTION;
  g_person_errored       BOOLEAN;

  g_override_dates g_override_date_t := g_override_date_t();
  g_plan_abr_info g_abr_info_t       := g_abr_info_t();

  CURSOR c_table_correction_data(v_benefit_action_id IN NUMBER)
  IS
    SELECT o.oipl_id,
      rpt.group_per_in_ler_id,
      rpt.pl_id,
      group_oipl.oipl_id group_oipl_id,
      rpt.person_id
    FROM ben_oipl_f o,
      ben_cwb_rpt_detail rpt,
      ben_oipl_f local_oipl,
      ben_opt_f local_opt,
      ben_opt_f group_opt,
      ben_oipl_f group_oipl
    WHERE o.pl_id = rpt.pl_id
     AND rpt.benefit_action_id = v_benefit_action_id
     AND rpt.oipl_id = -1
     AND local_oipl.oipl_id = o.oipl_id
     AND local_opt.opt_id = local_oipl.opt_id
     AND group_opt.group_opt_id = local_opt.group_opt_id
     AND group_oipl.opt_id = group_opt.group_opt_id
     AND NOT EXISTS
      (SELECT NULL
       FROM ben_cwb_rpt_detail
       WHERE oipl_id = o.oipl_id
       AND benefit_action_id = v_benefit_action_id)
    GROUP BY o.oipl_id,
      rpt.group_per_in_ler_id,
      rpt.pl_id,
      group_oipl.oipl_id,
      rpt.person_id;

  CURSOR c_get_abr_info(v_lf_evt_ocrd_date IN DATE
                       ,v_pl_id            IN NUMBER
 		       ,v_oipl_id          IN NUMBER)
  IS
     SELECT ws_element_type_id, ws_input_value_id
       FROM ben_cwb_pl_dsgn
      WHERE lf_evt_ocrd_dt = v_lf_evt_ocrd_date
        AND pl_id = v_pl_id
        AND oipl_id = v_oipl_id;

  CURSOR c_override_start_date(v_group_pl_id      IN NUMBER
                              ,v_pl_id            IN NUMBER
			      ,v_group_oipl_id    IN NUMBER
			      ,v_oipl_id          IN NUMBER
			      ,v_lf_evt_ocrd_date IN DATE)
  IS
    SELECT ovrid_rt_strt_dt
    FROM ben_cwb_pl_dsgn dsgn
    WHERE group_pl_id = v_group_pl_id
    AND pl_id = v_pl_id
    AND group_oipl_id = v_group_oipl_id
    AND oipl_id = v_oipl_id
    AND lf_evt_ocrd_dt = v_lf_evt_ocrd_date;


  CURSOR c_pil_ovn (v_per_in_ler_id IN NUMBER)
  IS
    SELECT object_version_number
      FROM ben_per_in_ler pil
     WHERE pil.per_in_ler_id = v_per_in_ler_id;

  CURSOR c_info_ovn (v_group_per_in_ler_id IN NUMBER)
  IS
    SELECT object_version_number
      FROM ben_cwb_person_info info
     WHERE info.group_per_in_ler_id = v_group_per_in_ler_id;

  CURSOR c_rate_ovn (v_group_per_in_ler_id IN NUMBER, v_pl_id IN NUMBER, v_oipl_id IN NUMBER)
  IS
    SELECT object_version_number
      FROM ben_cwb_person_rates rt
     WHERE rt.group_per_in_ler_id = v_group_per_in_ler_id
       AND rt.pl_id = v_pl_id
       AND rt.oipl_id = v_oipl_id;

  CURSOR c_grp_ovn (
    v_group_per_in_ler_id   IN   NUMBER
  , v_group_pl_id           IN   NUMBER
  , v_group_oipl_id         IN   NUMBER
  )
  IS
    SELECT  object_version_number
           ,access_cd
	   ,approval_cd
      FROM ben_cwb_person_groups grp
     WHERE grp.group_per_in_ler_id = v_group_per_in_ler_id
       AND grp.group_pl_id = v_group_pl_id
       AND grp.group_oipl_id = v_group_oipl_id;

  CURSOR c_bg_and_mgr_name (v_group_per_in_ler_id IN NUMBER, v_effective_date IN DATE)
  IS
    SELECT bg.NAME
         , per.full_name
         , info.business_group_id
      FROM per_business_groups_perf bg
         , ben_cwb_person_info info
         , per_all_people_f per
         , ben_per_in_ler pil
     WHERE info.group_per_in_ler_id = v_group_per_in_ler_id
       AND bg.business_group_id = info.business_group_id
       AND v_effective_date >= bg.date_from
       AND (   bg.date_to IS NULL
            OR bg.date_to >= v_effective_date)
       AND info.group_per_in_ler_id = pil.per_in_ler_id
       AND pil.ws_mgr_id = per.person_id(+)
       AND v_effective_date BETWEEN per.effective_start_date(+) AND per.effective_end_date(+);

  CURSOR c_emp_num_and_emp_name(v_group_per_in_ler_id IN NUMBER)
  IS
    SELECT nvl(per.custom_name,per.full_name) full_name
         , per.employee_number
         , per.assignment_id
         , per.business_group_id
         , per.legislation_code
      FROM ben_cwb_person_info per
     WHERE per.group_per_in_ler_id = v_group_per_in_ler_id;

  CURSOR c_prior_assignment(v_group_per_in_ler_id IN NUMBER)
  IS
    SELECT nvl(per.custom_name,per.full_name) full_name
         , per.employee_number
         , per.assignment_id
         , per.business_group_id
         , per.legislation_code
         , per.job_id
         , job.name job
         , per.position_id
         , pos.name position
         , per.grade_id
         , grades.name grade
         , per.people_group_id
         , ppl_groups.group_name
         , per.ass_attribute1
         , per.ass_attribute2
         , per.ass_attribute3
         , per.ass_attribute4
         , per.ass_attribute5
         , per.ass_attribute6
         , per.ass_attribute7
         , per.ass_attribute8
         , per.ass_attribute9
         , per.ass_attribute10
         , per.ass_attribute11
         , per.ass_attribute12
         , per.ass_attribute13
         , per.ass_attribute14
         , per.ass_attribute15
         , per.ass_attribute16
         , per.ass_attribute17
         , per.ass_attribute18
         , per.ass_attribute19
         , per.ass_attribute20
         , per.ass_attribute21
         , per.ass_attribute22
         , per.ass_attribute23
         , per.ass_attribute24
         , per.ass_attribute25
         , per.ass_attribute26
         , per.ass_attribute27
         , per.ass_attribute28
         , per.ass_attribute29
         , per.ass_attribute30
      FROM ben_cwb_person_info per
         , per_jobs_tl job
         , hr_all_positions_f_tl pos
         , per_grades_tl grades
         , pay_people_groups ppl_groups
     WHERE per.group_per_in_ler_id = v_group_per_in_ler_id
       AND job.job_id(+) = per.job_id
       AND job.language(+) = userenv('LANG')
       AND pos.position_id(+) = per.position_id
       AND pos.language(+) = userenv('LANG')
       AND grades.grade_id(+) = per.grade_id
       AND grades.language(+) = userenv('LANG')
       AND ppl_groups.people_group_id(+) = per.people_group_id;

  CURSOR c_batch_proc_info (v_benefit_action_id IN NUMBER)
  IS
    SELECT info.batch_proc_id
         , info.object_version_number
      FROM ben_batch_proc_info info
     WHERE info.benefit_action_id = v_benefit_action_id;

  CURSOR c_error_per_summary (v_benefit_action_id IN NUMBER)
  IS
    SELECT COUNT (*) amount
      FROM ben_cwb_rpt_detail
     WHERE person_rate_id = -9999
       AND status_cd = 'E'
       AND benefit_action_id = v_benefit_action_id;

  CURSOR c_succ_per_summary (v_benefit_action_id IN NUMBER)
  IS
    SELECT COUNT (*) amount
      FROM ben_cwb_rpt_detail
     WHERE person_rate_id = -9999
       AND status_cd IN ('WC', 'SC', 'W')
       AND benefit_action_id = v_benefit_action_id;

  CURSOR c_lf_evt_open_summary (v_benefit_action_id IN NUMBER)
  IS
    SELECT COUNT (*) amount
      FROM ben_cwb_rpt_detail
     WHERE person_rate_id = -9999
       AND lf_evt_closed_flag = 'N'
       AND benefit_action_id = v_benefit_action_id;

  CURSOR c_lf_evt_close_summary (v_benefit_action_id IN NUMBER)
  IS
    SELECT COUNT (*) amount
      FROM ben_cwb_rpt_detail
     WHERE person_rate_id = -9999
       AND lf_evt_closed_flag = 'Y'
       AND benefit_action_id = v_benefit_action_id;

  CURSOR c_placeholder_selection (
    v_pl_id               IN   NUMBER
  , v_lf_evt_orcd_date    IN   DATE
  , v_person_id           IN   NUMBER
  , v_manager_id          IN   NUMBER
  , v_business_group_id   IN   NUMBER
  , v_effective_date      IN   DATE
  )
  IS
    SELECT   pil.person_id
           , (pil.per_in_ler_id) per_in_ler_id
           , (nvl(per.custom_name,per.full_name)) full_name
           , bg.NAME
	   , per.legislation_code
	   , per.business_group_id
    FROM
        ben_per_in_ler pil,
        ben_per_in_ler mgr_pil,
        ben_cwb_person_info per,
        ben_cwb_group_hrchy hrchy,
        per_business_groups_perf bg
    where  pil.per_in_ler_stat_cd = 'STRTD'
    AND pil.group_pl_id = per.group_pl_id
    AND pil.lf_evt_ocrd_dt = per.lf_evt_ocrd_dt
    AND per.group_per_in_ler_id = pil.per_in_ler_id
    AND hrchy.emp_per_in_ler_id = pil.per_in_ler_id
    AND hrchy.mgr_per_in_ler_id = mgr_pil.per_in_ler_id
    AND (   v_person_id IS NULL
              OR pil.person_id = v_person_id)
    AND (   (    v_manager_id IS NULL
                  AND hrchy.lvl_num = (SELECT MAX (lvl_num)
                                         FROM ben_cwb_group_hrchy
                                        WHERE emp_per_in_ler_id = hrchy.emp_per_in_ler_id)
                 )
    OR (    mgr_pil.person_id = v_manager_id
         AND hrchy.lvl_num > 0)
             )
    and not exists(
        select null from
        ben_cwb_person_rates
        where group_per_in_ler_id = pil.per_in_ler_id
        )
    and (v_business_group_id is null or
         per.business_group_id = v_business_group_id)
    AND bg.business_group_id = per.business_group_id
    AND v_effective_date >= bg.date_from
    AND (   bg.date_to IS NULL
        OR bg.date_to >= v_effective_date)
    and per.group_pl_id = v_pl_id
    and per.lf_evt_ocrd_dt = v_lf_evt_orcd_date
    ;

  CURSOR c_person_selection (
    v_pl_id               IN   NUMBER
  , v_lf_evt_orcd_date    IN   DATE
  , v_person_id           IN   NUMBER
  , v_manager_id          IN   NUMBER
  , v_business_group_id   IN   NUMBER
  , v_effective_date      IN   DATE
  )
  IS
    SELECT   pil.person_id
           , max(pil.per_in_ler_id) per_in_ler_id
           , max(nvl(per.custom_name,per.full_name)) full_name
           , max(bg.NAME) NAME
	   , per.business_group_id
        FROM ben_per_in_ler pil
           , ben_per_in_ler mgr_pil
           , ben_cwb_group_hrchy hrchy
           , per_business_groups_perf bg
           , ben_cwb_person_info per
	   , ben_cwb_person_rates rates
	   , ben_cwb_pl_dsgn dsgn
       WHERE pil.per_in_ler_stat_cd = 'STRTD'
         AND pil.group_pl_id = v_pl_id
         AND pil.lf_evt_ocrd_dt = v_lf_evt_orcd_date
         AND per.group_per_in_ler_id = pil.per_in_ler_id
         AND (   v_person_id IS NULL
              OR pil.person_id = v_person_id)
         AND (   v_business_group_id IS NULL
              OR per.business_group_id = v_business_group_id)
         AND per.business_group_id = bg.business_group_id
         AND v_effective_date >= bg.date_from
         AND (   bg.date_to IS NULL
              OR bg.date_to >= v_effective_date)
         AND hrchy.emp_per_in_ler_id = pil.per_in_ler_id
         AND hrchy.mgr_per_in_ler_id = mgr_pil.per_in_ler_id
         AND (   (    v_manager_id IS NULL
                  AND hrchy.lvl_num = (SELECT MAX (lvl_num)
                                         FROM ben_cwb_group_hrchy
                                        WHERE emp_per_in_ler_id = hrchy.emp_per_in_ler_id)
                 )
              OR (    mgr_pil.person_id = v_manager_id
                  AND hrchy.lvl_num > 0)
             )
       AND rates.group_per_in_ler_id  = pil.per_in_ler_id
       AND rates.pl_id = dsgn.pl_id
       AND rates.oipl_id = dsgn.oipl_id
       --AND rates.elig_flag = 'Y'
       AND rates.lf_evt_ocrd_dt = dsgn.lf_evt_ocrd_dt
       AND dsgn.oipl_id=-1
       AND nvl(dsgn.do_not_process_flag,'N') <> 'Y'
       GROUP BY pil.person_id, per.business_group_id
    ORDER BY full_name;

  CURSOR c_check_eligibility (v_group_per_in_ler_id IN NUMBER)
  IS
   select null
   from ben_cwb_person_rates
   where group_per_in_ler_id = v_group_per_in_ler_id
   and oipl_id = -1
   and elig_flag = 'Y';

  CURSOR c_per_in_ler_ids (
    v_group_pl_id      IN   NUMBER
  , v_employee_in_bg   IN   NUMBER
  , v_person_id        IN   NUMBER
  , v_lf_evt_ocrd_dt   IN   DATE
  )
  IS
    SELECT pil.per_in_ler_id
         , pil.per_in_ler_stat_cd
         , pil.object_version_number
      FROM ben_per_in_ler pil
     WHERE pil.group_pl_id = v_group_pl_id
       AND pil.person_id = v_person_id
       AND pil.lf_evt_ocrd_dt = v_lf_evt_ocrd_dt
       AND pil.per_in_ler_stat_cd = 'STRTD'
       AND (   v_employee_in_bg IS NULL
            OR pil.business_group_id = v_employee_in_bg);

  CURSOR c_range_for_thread (v_benefit_action_id IN NUMBER)
  IS
    SELECT        ran.range_id
                , ran.starting_person_action_id
                , ran.ending_person_action_id
             FROM ben_batch_ranges ran
            WHERE ran.range_status_cd = 'U'
              AND ran.benefit_action_id = v_benefit_action_id
              AND ROWNUM < 2
    FOR UPDATE OF ran.range_status_cd;

  CURSOR c_person_for_thread (
    v_benefit_action_id        IN   NUMBER
  , v_start_person_action_id   IN   NUMBER
  , v_end_person_action_id     IN   NUMBER
  )
  IS
    SELECT   ben.person_id
           , ben.person_action_id
           , ben.object_version_number
           , ben.ler_id
           , ben.non_person_cd
        FROM ben_person_actions ben
       WHERE ben.benefit_action_id = v_benefit_action_id
         AND ben.action_status_cd <> 'P'
         AND ben.person_action_id BETWEEN v_start_person_action_id AND v_end_person_action_id
    ORDER BY ben.person_action_id;

  CURSOR c_parameter (v_benefit_action_id IN NUMBER)
  IS
    SELECT ben.*
      FROM ben_benefit_actions ben
     WHERE ben.benefit_action_id = v_benefit_action_id;

  CURSOR c_actual_termination_date (v_person_id IN NUMBER)
  IS
    SELECT actual_termination_date
      FROM per_periods_of_service
     WHERE person_id = v_person_id
       AND date_start = (SELECT   MAX (date_start)
                             FROM per_periods_of_service
                            WHERE person_id = v_person_id
                         GROUP BY person_id);

  CURSOR c_performance_promotion (v_pl_id IN NUMBER, v_lf_evt_ocrd_dt IN DATE)
  IS
    SELECT dsgn.perf_revw_strt_dt
         , nvl(dsgn.ovr_perf_revw_strt_dt, dsgn.perf_revw_strt_dt)
         , dsgn.asg_updt_eff_date
         , dsgn.emp_interview_typ_cd
      FROM ben_cwb_pl_dsgn dsgn
     WHERE dsgn.pl_id = v_pl_id
       AND dsgn.lf_evt_ocrd_dt = v_lf_evt_ocrd_dt
       AND dsgn.oipl_id = -1;

  CURSOR c_component_reason (v_pl_id IN NUMBER, v_effective_date IN DATE)
  IS
    SELECT COUNT (*)
      FROM ben_oipl_f oipl
         , ben_opt_f opt
     WHERE oipl.pl_id = v_pl_id
       AND oipl.opt_id = opt.opt_id
       and opt.component_reason is not null
       AND v_effective_date BETWEEN opt.effective_start_date AND opt.effective_end_date
       AND v_effective_date BETWEEN oipl.effective_start_date AND oipl.effective_end_date;

  CURSOR c_task_type (v_group_per_in_ler_id IN NUMBER)
  IS
    SELECT dsgn.ws_sub_acty_typ_cd
      FROM ben_cwb_person_rates rt
         , ben_cwb_pl_dsgn dsgn
     WHERE rt.group_per_in_ler_id = v_group_per_in_ler_id
       AND rt.pl_id = dsgn.pl_id
       AND rt.oipl_id = dsgn.oipl_id
       AND rt.lf_evt_ocrd_dt = dsgn.lf_evt_ocrd_dt;

 CURSOR c_input_value_precision(
     v_assignment_id NUMBER
 ,   v_effective_date DATE
   )
 IS
 SELECT decode(piv.uom,NULL,2,'M',nvl(curr.PRECISION,2),5) PRECISION
   FROM per_all_assignments_f asg,
    per_pay_bases ppb,
    pay_input_values_f piv,
    pay_element_types_f pet,
    fnd_currencies curr
WHERE asg.assignment_id = v_assignment_id
 AND v_effective_date BETWEEN asg.effective_start_date
 AND asg.effective_end_date
 AND asg.pay_basis_id = ppb.pay_basis_id
 AND ppb.input_value_id = piv.input_value_id
 AND v_effective_date BETWEEN piv.effective_start_date
 AND piv.effective_end_date
 AND piv.element_type_id = pet.element_type_id
 AND v_effective_date BETWEEN pet.effective_start_date
 AND pet.effective_end_date
 AND pet.input_currency_code = curr.currency_code;

  CURSOR c_sal_comp_rates_tot (
    v_group_per_in_ler_id   IN   NUMBER
  , v_group_pl_id           IN   NUMBER
  , v_lf_evt_orcd_dt        IN   DATE
  ,v_effective_date         in date
  ,v_profile_value          in varchar2
  )
  IS
    SELECT SUM (rt.ws_val)
      FROM ben_cwb_person_rates rt
          ,ben_oipl_f oipl
          ,ben_opt_f opt
     WHERE rt.group_per_in_ler_id = v_group_per_in_ler_id
       AND rt.group_pl_id = v_group_pl_id
       AND rt.oipl_id <> -1
       AND rt.lf_evt_ocrd_dt = v_lf_evt_orcd_dt
       AND nvl(v_profile_value,rt.ws_val) <> 0
       AND oipl.oipl_id = rt.oipl_id
       AND oipl.opt_id = opt.opt_id
       AND opt.component_reason is not null
       AND v_effective_date BETWEEN opt.effective_start_date AND opt.effective_end_date
       AND v_effective_date BETWEEN oipl.effective_start_date AND oipl.effective_end_date
       AND rt.elig_flag = 'Y';

CURSOR c_salary_effective_date(
        v_group_per_in_ler_id   IN   NUMBER,
        v_rule_based IN VARCHAR2
    ) IS
    SELECT DECODE(v_rule_based,'Y',
            min(WS_RT_START_DATE),
            min(OVRID_RT_STRT_DT)) effective_date
      FROM ben_cwb_person_rates rt
         , ben_oipl_f oipl
         , ben_cwb_pl_dsgn dsgn
         , ben_opt_f opt
         , ben_cwb_person_info info
         , ben_per_in_ler pil
         , ben_cwb_xchg xchg
     WHERE rt.group_per_in_ler_id = v_group_per_in_ler_id
       AND rt.pl_id = dsgn.pl_id
       AND rt.oipl_id = dsgn.oipl_id
       AND rt.lf_evt_ocrd_dt = dsgn.lf_evt_ocrd_dt
       AND rt.group_per_in_ler_id = info.group_per_in_ler_id
       AND rt.group_per_in_ler_id = pil.per_in_ler_id
       AND oipl.oipl_id = rt.oipl_id
       AND oipl.opt_id = opt.opt_id
       AND opt.component_reason is not null
       AND OVRID_RT_STRT_DT BETWEEN opt.effective_start_date AND opt.effective_end_date
       AND OVRID_RT_STRT_DT BETWEEN oipl.effective_start_date AND oipl.effective_end_date
       and xchg.group_pl_id = rt.group_pl_id
       and xchg.lf_evt_ocrd_dt = rt.lf_evt_ocrd_dt
       and xchg.currency = rt.currency
       AND exists (select null from ben_cwb_pl_dsgn where pl_id = rt.pl_id and oipl_id = -1 and nvl(do_not_process_flag,'N') <> 'Y');

  CURSOR c_sal_comp_rates (
    v_group_per_in_ler_id   IN   NUMBER
  , v_group_pl_id           IN   NUMBER
  , v_lf_evt_orcd_dt        IN   DATE
  , v_effective_date        IN   DATE
  )
  IS
    SELECT nvl(rt.ws_val,0) ws_val
         , rt.person_rate_id
         , opt.component_reason
         , dsgn.salary_change_reason
         , dsgn.pl_id
         , dsgn.oipl_id
         , dsgn.group_pl_id
         , dsgn.group_oipl_id
         , dsgn.ws_nnmntry_uom units
         , dsgn.ws_sub_acty_typ_cd
         , pil.ws_mgr_id
         , info.full_name
         , info.employee_number
         , info.business_group_id
         , rt.elig_sal_val
         , xchg.xchg_rate
         , rt.elig_flag
         , rt.currency
      FROM ben_cwb_person_rates rt
         , ben_oipl_f oipl
         , ben_cwb_pl_dsgn dsgn
         , ben_opt_f opt
         , ben_cwb_person_info info
         , ben_per_in_ler pil
         , ben_cwb_xchg xchg
     WHERE rt.group_per_in_ler_id = v_group_per_in_ler_id
       AND rt.group_pl_id = v_group_pl_id
       --AND rt.oipl_id <> -1
       --AND rt.elig_flag = 'Y' (for logging)
       AND rt.lf_evt_ocrd_dt = v_lf_evt_orcd_dt
       --AND nvl(rt.ws_val,0) <> 0
       AND rt.pl_id = dsgn.pl_id
       AND rt.oipl_id = dsgn.oipl_id
       AND rt.lf_evt_ocrd_dt = dsgn.lf_evt_ocrd_dt
       AND rt.group_per_in_ler_id = info.group_per_in_ler_id
       AND rt.group_per_in_ler_id = pil.per_in_ler_id
       AND oipl.oipl_id = rt.oipl_id
       AND oipl.opt_id = opt.opt_id
       AND opt.component_reason is not null
       AND v_effective_date BETWEEN opt.effective_start_date AND opt.effective_end_date
       AND v_effective_date BETWEEN oipl.effective_start_date AND oipl.effective_end_date
       and xchg.group_pl_id = rt.group_pl_id
       and xchg.lf_evt_ocrd_dt = rt.lf_evt_ocrd_dt
       and xchg.currency = rt.currency
       AND exists (select null from ben_cwb_pl_dsgn where pl_id = rt.pl_id and oipl_id = -1 and nvl(do_not_process_flag,'N') <> 'Y');


  CURSOR c_non_sal_comp_rates (v_group_per_in_ler_id IN NUMBER, v_effective_date IN DATE)
  IS
    SELECT rt.ws_val
         , rt.person_rate_id
         , rt.pl_id
         , rt.oipl_id
         , rt.object_version_number
         , dsgn.ws_sub_acty_typ_cd
         , dsgn.ws_abr_id
         , dsgn.salary_change_reason
         , dsgn.ws_nnmntry_uom units
         , dsgn.acty_ref_perd_cd
         , dsgn.business_group_id
         , dsgn.group_pl_id
         , dsgn.group_oipl_id
         , pil.ws_mgr_id
         , info.full_name
         , info.employee_number
         , info.assignment_id
         , opt.component_reason
         , info.base_salary_currency
         , dsgn.uom_precision
         , info.base_salary
         , rt.elig_sal_val
         , initcap(info.base_salary_frequency) base_salary_frequency
         , info.pay_annulization_factor
         , dsgn.pl_annulization_factor
         , xchg.xchg_rate
         , rt.elig_flag
         , info.fte_factor
         , rt.currency
      FROM ben_cwb_person_rates rt
         , ben_cwb_pl_dsgn dsgn
         , ben_cwb_person_info info
         , ben_per_in_ler pil
         , ben_oipl_f oipl
         , ben_opt_f opt
         , ben_cwb_xchg xchg
     WHERE rt.group_per_in_ler_id = v_group_per_in_ler_id
       AND rt.pl_id = dsgn.pl_id
       AND rt.oipl_id = dsgn.oipl_id
       --AND rt.elig_flag = 'Y' (for logging)
       AND rt.lf_evt_ocrd_dt = dsgn.lf_evt_ocrd_dt
       AND rt.group_per_in_ler_id = info.group_per_in_ler_id
       AND rt.group_per_in_ler_id = pil.per_in_ler_id
       AND rt.oipl_id = oipl.oipl_id (+)
       AND oipl.opt_id = opt.opt_id (+)
       AND v_effective_date BETWEEN opt.effective_start_date (+) AND opt.effective_end_date (+)
       AND v_effective_date BETWEEN oipl.effective_start_date (+)AND oipl.effective_end_date (+)
       and xchg.group_pl_id = rt.group_pl_id
       and xchg.lf_evt_ocrd_dt = rt.lf_evt_ocrd_dt
       and xchg.currency = rt.currency
       AND exists (select null from ben_cwb_pl_dsgn where pl_id = rt.pl_id and oipl_id = -1 and nvl(do_not_process_flag,'N') <> 'Y');

  CURSOR c_ranking_info (v_group_per_in_ler_id IN NUMBER)
  IS
    SELECT xtra_info.aei_information1
         , xtra_info.aei_information2
         , xtra_info.aei_information4
         , xtra_info.assignment_id
         , xtra_info.object_version_number
         , xtra_info.assignment_extra_info_id
      FROM per_assignment_extra_info xtra_info
         , ben_cwb_person_info per
     WHERE per.group_per_in_ler_id = v_group_per_in_ler_id
       AND xtra_info.assignment_id = per.assignment_id
       AND xtra_info.information_type = 'CWBRANK'
       AND xtra_info.aei_information1 IS NOT NULL
       AND xtra_info.aei_information3 IS NULL;

 CURSOR c_ranking_info_date ( v_group_per_in_ler_id IN NUMBER
                             ,v_eff_dt IN DATE
                             ,v_ranked_by IN VARCHAR2)

   IS
     SELECT xtra_info.aei_information1
          , xtra_info.aei_information2
          , xtra_info.aei_information4
          , xtra_info.assignment_id
          , xtra_info.object_version_number
       FROM per_assignment_extra_info xtra_info
          , ben_cwb_person_info per
      WHERE per.group_per_in_ler_id = v_group_per_in_ler_id
        AND xtra_info.assignment_id = per.assignment_id
        AND xtra_info.information_type = 'CWBRANK'
        AND xtra_info.aei_information5 = fnd_date.date_to_canonical(v_eff_dt)
        AND xtra_info.aei_information2 = v_ranked_by;


  CURSOR c_prev_pay_proposal (v_group_per_in_ler_id IN NUMBER, v_effective_date IN DATE)
  IS
    SELECT asg.assignment_id
         , asg.pay_basis_id
         , ppp.proposed_salary_n
         , ppp.object_version_number
      FROM per_all_assignments_f asg
         , per_pay_bases ppb
         , per_pay_proposals ppp
         , ben_cwb_person_info per
     WHERE per.group_per_in_ler_id = v_group_per_in_ler_id
       AND asg.assignment_id = per.assignment_id
       AND v_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
       AND ppb.pay_basis_id = asg.pay_basis_id
       AND ppp.assignment_id = asg.assignment_id
       AND ppp.approved = 'Y'
       AND ppp.change_date =
             (SELECT MAX (ppp1.change_date)
                FROM per_pay_proposals ppp1
               WHERE ppp1.assignment_id = asg.assignment_id
                 AND ppp1.approved = 'Y'
                 AND change_date < v_effective_date);

  CURSOR c_future_pay_proposal (v_group_per_in_ler_id IN NUMBER, v_effective_date IN DATE)
  IS
   SELECT ppp.proposed_salary_n
     FROM per_pay_proposals ppp
        , ben_cwb_person_info per
    WHERE per.group_per_in_ler_id = v_group_per_in_ler_id
      AND ppp.assignment_id = per.assignment_id
      AND ppp.change_date > v_effective_date;

  CURSOR c_element_entry (
    v_pay_basis_id     IN   NUMBER
  , v_assignmnet_id    IN   NUMBER
  , v_effective_date   IN   DATE
  )
  IS
    SELECT ele.element_entry_id
          ,ele.element_type_id
      FROM per_pay_bases bas
         , pay_element_entries_f ele
         , pay_element_entry_values_f entval
     WHERE bas.pay_basis_id = v_pay_basis_id
       AND entval.input_value_id = bas.input_value_id
       AND v_effective_date BETWEEN entval.effective_start_date AND entval.effective_end_date
       AND ele.assignment_id = v_assignmnet_id
       AND v_effective_date BETWEEN ele.effective_start_date AND ele.effective_end_date
       AND ele.element_entry_id = entval.element_entry_id;

  CURSOR c_tot_chg_amt_for_proposal (v_pay_proposal_id IN NUMBER)
  IS
    SELECT SUM (comp.change_amount_n) tamt
      FROM per_pay_proposal_components comp
     WHERE comp.pay_proposal_id = v_pay_proposal_id;

  CURSOR c_person_info (v_group_per_in_ler_id IN NUMBER)
  IS
    SELECT per.business_group_id
         , per.base_salary
         , per.base_salary_currency
         , initcap(base_salary_frequency) base_salary_frequency
         , pay_annulization_factor
         , fte_factor
      FROM ben_cwb_person_info per
     WHERE per.group_per_in_ler_id = v_group_per_in_ler_id;

  CURSOR c_group_plan_name (v_group_pl_id IN NUMBER, v_lf_evt_ocrd_dt IN DATE)
  IS
    SELECT dsgn.NAME
         , dsgn.group_pl_id
      FROM ben_cwb_pl_dsgn dsgn
     WHERE dsgn.pl_id = v_group_pl_id
       AND dsgn.pl_id = dsgn.group_pl_id
       AND dsgn.group_oipl_id = -1
       AND dsgn.oipl_id = dsgn.group_oipl_id
       AND dsgn.lf_evt_ocrd_dt = v_lf_evt_ocrd_dt;

  CURSOR c_group_option_name (v_group_pl_id IN NUMBER, v_lf_evt_ocrd_dt IN DATE)
  IS
    SELECT dsgn.NAME
         , dsgn.group_oipl_id
      FROM ben_cwb_pl_dsgn dsgn
     WHERE dsgn.pl_id = v_group_pl_id
       AND dsgn.pl_id = dsgn.group_pl_id
       AND dsgn.oipl_id = dsgn.group_oipl_id
       AND dsgn.lf_evt_ocrd_dt = v_lf_evt_ocrd_dt
       AND dsgn.oipl_id <> -1;

  CURSOR c_plan_name (v_group_pl_id IN NUMBER, v_lf_evt_ocrd_dt IN DATE)
  IS
    SELECT dsgn.NAME
         , dsgn.pl_id
      FROM ben_cwb_pl_dsgn dsgn
     WHERE dsgn.group_pl_id = v_group_pl_id
       AND dsgn.lf_evt_ocrd_dt = v_lf_evt_ocrd_dt
       AND dsgn.oipl_id = -1
       AND dsgn.pl_id <> dsgn.group_pl_id;

  CURSOR c_option_name (v_group_pl_id IN NUMBER, v_lf_evt_ocrd_dt IN DATE)
  IS
    SELECT dsgn.NAME
         , dsgn.oipl_id
      FROM ben_cwb_pl_dsgn dsgn
     WHERE dsgn.group_pl_id = v_group_pl_id
       AND dsgn.lf_evt_ocrd_dt = v_lf_evt_ocrd_dt
       AND dsgn.pl_id <> dsgn.group_pl_id
       AND dsgn.oipl_id <> -1;

  CURSOR c_actions (v_benefit_action_id IN NUMBER)
  IS
    SELECT   COUNT (*) amount
           , action_status_cd
        FROM ben_person_actions act
       WHERE act.benefit_action_id = v_benefit_action_id
         AND act.action_status_cd IN ('P', 'E', 'U')
    GROUP BY action_status_cd;

  CURSOR c_pils_for_access( v_group_pl_id    IN NUMBER
                                   ,v_lf_evt_ocrd_dt IN DATE
                                  )
  IS
     SELECT  pil.per_in_ler_id
            ,nvl(info.custom_name,info.full_name) full_name
       FROM  ben_per_in_ler pil
            ,ben_cwb_person_groups pgroup
            ,ben_cwb_person_info info
      WHERE pil.lf_evt_ocrd_dt = v_lf_evt_ocrd_dt
        AND pil.group_pl_id = v_group_pl_id
        AND pgroup.group_per_in_ler_id = pil.per_in_ler_id
        AND pgroup.group_oipl_id = -1
        AND ( nvl(pgroup.access_cd,'UP') = 'UP' OR approval_cd = 'AP' )
        AND info.group_per_in_ler_id = pil.per_in_ler_id
        AND NOT EXISTS (
            SELECT NULL
            FROM ben_cwb_group_hrchy h, ben_per_in_ler p
                 ,ben_cwb_person_rates r
            WHERE h.mgr_per_in_ler_id =  pil.per_in_ler_id
            AND h.lvl_num > 0
            AND p.per_in_ler_id = h.emp_per_in_ler_id
            AND p.lf_evt_ocrd_dt = pil.lf_evt_ocrd_dt
            AND p.group_pl_id = pil.group_pl_id
            AND p.per_in_ler_stat_cd = 'STRTD'
            AND r.group_per_in_ler_id = h.emp_per_in_ler_id
            AND r.oipl_id = -1
            AND r.elig_flag = 'Y'
            )
        AND NOT EXISTS (
            SELECT NULL
            FROM ben_per_in_ler p
            WHERE p.per_in_ler_id = pil.per_in_ler_id
            AND p.lf_evt_ocrd_dt = pil.lf_evt_ocrd_dt
            AND p.group_pl_id = pil.group_pl_id
            AND p.per_in_ler_stat_cd = 'STRTD'
            AND NOT EXISTS (
             SELECT NULL
             FROM ben_cwb_group_hrchy h
             WHERE h.mgr_per_in_ler_id = p.per_in_ler_id
             )
             );

  CURSOR c_emp_pils_still_open(v_mgr_per_in_ler_id IN NUMBER)
  IS
     SELECT emp_per_in_ler_id
       FROM  ben_per_in_ler pil
            ,ben_cwb_group_hrchy hrchy
      WHERE hrchy.mgr_per_in_ler_id = v_mgr_per_in_ler_id
        AND hrchy.lvl_num > 0
        AND pil.per_in_ler_id = hrchy.emp_per_in_ler_id
        AND pil.per_in_ler_stat_cd = 'STRTD'
        AND rownum = 1;

  CURSOR c_sal_factors(v_group_pl_id          IN NUMBER,
                       v_lf_evt_ocrd_dt       IN DATE,
                       v_group_per_in_ler_id  IN NUMBER
                      )
  IS
     SELECT dsgn.pl_annulization_factor,
            dsgn.uom_precision,
            info.pay_annulization_factor,
            dsgn.salary_change_reason
       FROM ben_cwb_pl_dsgn dsgn,
            ben_cwb_person_info info
      WHERE dsgn.group_pl_id = v_group_pl_id
        AND dsgn.group_pl_id = dsgn.pl_id
        AND dsgn.oipl_id = -1
        AND dsgn.lf_evt_ocrd_dt = v_lf_evt_ocrd_dt
        AND info.group_per_in_ler_id = v_group_per_in_ler_id;

  CURSOR c_element_input_currency(v_element_type_id          IN NUMBER,
                                  v_effective_date       IN DATE
                                  )
  IS
     SELECT input_currency_code
       FROM pay_element_types_f
      WHERE element_type_id =  v_element_type_id
        AND v_effective_date BETWEEN effective_start_date AND effective_end_date;

   CURSOR c_element_input_value_name(v_input_value_id          IN NUMBER,
                                     v_element_type_id         IN NUMBER,
                                     v_effective_date          IN DATE
                                     )
  IS
        select pet.element_name||': '||piv.name
        , processing_type
        , input_currency_code
          from pay_input_values_f piv,
               pay_element_types_f pet
         where piv.input_value_id = v_input_value_id
           and piv.element_type_id = v_element_type_id
           and piv.element_type_id = pet.element_type_id
           and v_effective_date between piv.effective_start_date and piv.effective_end_date
           and v_effective_date between pet.effective_start_date and pet.effective_end_date;

   CURSOR c_posted_element(v_assignment_id    IN NUMBER
                          ,v_element_type_id  IN NUMBER
                          ,v_input_value_id   IN NUMBER
                          ,v_effective_date   IN DATE)
   IS
          select eev.screen_entry_value
          from pay_element_entries_f ee,
               pay_element_entry_values_f eev
          where ee.assignment_id = v_assignment_id
          and ee.element_type_id = v_element_type_id
          and v_effective_date between ee.effective_start_date and ee.effective_end_date
          and eev.element_entry_id = ee.element_entry_id
          and eev.input_value_id = v_input_value_id
          and eev.effective_start_date = ee.effective_start_date
          and eev.effective_end_date = ee.effective_end_date
          and eev.screen_entry_value is not null
          order by ee.effective_start_date;

    CURSOR c_posted_salary(v_pay_proposal_id IN NUMBER)
    IS
        select proposed_salary_n
          from per_pay_proposals
          where pay_proposal_id = v_pay_proposal_id;

    CURSOR c_posted_rating(v_person_id      IN NUMBER,
                           v_effective_date IN DATE)
    IS
     select perf.performance_rating
       from per_performance_reviews perf
      where perf.person_id = v_person_id
        and perf.review_date = v_effective_date;

    CURSOR c_posted_promotions(v_assignment_id      IN NUMBER,
                               v_effective_date     IN DATE)
    IS
 select asgn.job_id
      , job.name job
      , asgn.position_id
      , pos.name position
      , asgn.grade_id
      , grade.name grade
      , asgn.people_group_id
      , people_group.group_name
      , asgn.ass_attribute1
      , asgn.ass_attribute2
      , asgn.ass_attribute3
      , asgn.ass_attribute4
      , asgn.ass_attribute5
      , asgn.ass_attribute6
      , asgn.ass_attribute7
      , asgn.ass_attribute8
      , asgn.ass_attribute9
      , asgn.ass_attribute10
      , asgn.ass_attribute11
      , asgn.ass_attribute12
      , asgn.ass_attribute13
      , asgn.ass_attribute14
      , asgn.ass_attribute15
      , asgn.ass_attribute16
      , asgn.ass_attribute17
      , asgn.ass_attribute18
      , asgn.ass_attribute19
      , asgn.ass_attribute20
      , asgn.ass_attribute21
      , asgn.ass_attribute22
      , asgn.ass_attribute23
      , asgn.ass_attribute24
      , asgn.ass_attribute25
      , asgn.ass_attribute26
      , asgn.ass_attribute27
      , asgn.ass_attribute28
      , asgn.ass_attribute29
      , asgn.ass_attribute30
 from per_all_assignments_f asgn
    , per_jobs_tl job
    , hr_all_positions_f_tl pos
    , per_grades_tl grade
    , pay_people_groups people_group
 where assignment_id = v_assignment_id
 and v_effective_date between effective_start_date and effective_end_date
 and job.job_id(+) = asgn.job_id
 and job.language(+) = userenv('LANG')
 and pos.position_id(+) = asgn.position_id
 and pos.language(+) = userenv('LANG')
 and grade.grade_id(+) = asgn.grade_id
 and grade.language(+) = userenv('LANG')
 and people_group.people_group_id(+) = asgn.people_group_id;

    CURSOR c_proposed_promotions(v_transaction_id      IN NUMBER,
                                 v_transaction_type    IN VARCHAR2)
    IS
 select job.name job
      , pos.name position
      , grade.name grade
      , people_group.group_name
 from ben_transaction asgn
    , per_jobs_tl job
    , hr_all_positions_f_tl pos
    , per_grades_tl grade
    , pay_people_groups people_group
 where asgn.transaction_id = v_transaction_id
 and asgn.transaction_type = v_transaction_type
 and job.job_id(+) = asgn.attribute5
 and job.language(+) = userenv('LANG')
 and pos.position_id(+) = asgn.attribute6
 and pos.language(+) = userenv('LANG')
 and grade.grade_id(+) = asgn.attribute7
 and grade.language(+) = userenv('LANG')
 and people_group.people_group_id(+) = asgn.attribute8;

CURSOR c_overrides_perf_prom(v_group_per_in_ler_id IN NUMBER,
                             v_lf_evt_ocrd_dt IN DATE)
IS
SELECT trans.transaction_id,
  trans.attribute1,
  trans.attribute2
FROM ben_transaction trans,
  ben_cwb_pl_dsgn dsgn
WHERE trans.transaction_id IN
  (SELECT DISTINCT pl_id
   FROM ben_cwb_person_rates rates
   WHERE group_per_in_ler_id = v_group_per_in_ler_id)
AND trans.transaction_type = 'CWBPPOVDT' || to_char(v_lf_evt_ocrd_dt,'yyyy/mm/dd');

CURSOR c_slaves(v_request_id IN NUMBER)
IS
    Select null
      From fnd_concurrent_requests fnd
     Where request_id = v_request_id
       and status_code = 'E';

CURSOR c_get_ws_rate_start_dt(
    v_group_per_in_ler_id IN NUMBER,
    v_group_pl_id IN NUMBER,
    v_pl_id IN NUMBER,
    v_oipl_id IN NUMBER,
    v_group_oipl_id IN NUMBER,
    v_lf_evt_ocrd_dt IN DATE)
IS
 SELECT WS_RT_START_DATE
 FROM BEN_CWB_PERSON_RATES
 WHERE GROUP_PER_IN_LER_ID = v_group_per_in_ler_id
 AND PL_ID = v_pl_id
 AND OIPL_ID = v_oipl_id
 AND LF_EVT_OCRD_DT = v_lf_evt_ocrd_dt
 AND GROUP_PL_ID = v_group_pl_id
 AND GROUP_OIPL_ID = v_group_oipl_id
    ;

--
-- ============================================================================
--                            <<write>>
-- ============================================================================
--

 PROCEDURE WRITE (p_string IN VARCHAR2)
  IS
 BEGIN
    ben_batch_utils.WRITE (p_string);
 END;

--
-- ============================================================================
--                            <<write_s>>
-- ============================================================================
--

 PROCEDURE write_s (p_string IN VARCHAR2)
  IS
 BEGIN
    IF (g_debug_level = 'S')
    THEN
          WRITE (p_string);
    END IF;
 END;

--
-- ============================================================================
--                            <<write_m>>
-- ============================================================================
--

 PROCEDURE write_m (p_string IN VARCHAR2)
  IS
 BEGIN
    IF (   g_debug_level = 'M'
        OR g_debug_level = 'H'
        OR g_debug_level = 'S')
    THEN
      WRITE (p_string);
    END IF;
END;

--
-- ============================================================================
--                            <<write_h>>
-- ============================================================================
--

PROCEDURE write_h (p_string IN VARCHAR2)
  IS
BEGIN
    IF (   g_debug_level = 'H'
           OR g_debug_level = 'S')
    THEN
      WRITE (p_string);
    END IF;
END;


--
-- ============================================================================
--                            <<process_access>>
-- ============================================================================
--

PROCEDURE process_access( p_group_pl_id     IN NUMBER
                         ,p_lf_evt_ocrd_dt  IN DATE
                         ,p_validate        IN VARCHAR2 DEFAULT 'N'
                        )
IS
l_pils_for_access c_pils_for_access%ROWTYPE;
l_grp_ovn c_grp_ovn%ROWTYPE;
l_emp_pils_still_open c_emp_pils_still_open%ROWTYPE;
l_emps_not_found BOOLEAN := FALSE;
l_no_of_man_picked NUMBER := 0;
l_no_of_man_access_changed NUMBER := 0;
BEGIN

  g_proc := 'process_access';
  g_actn := 'processing access routine...';
  write(g_actn);
  SAVEPOINT cwb_post_process_access;

  IF c_pils_for_access%ISOPEN THEN
      close c_pils_for_access;
  END IF;

  OPEN c_pils_for_access(p_group_pl_id,p_lf_evt_ocrd_dt );
  LOOP

   FETCH c_pils_for_access INTO l_pils_for_access;

   EXIT WHEN c_pils_for_access%NOTFOUND;

   write_h('Processing access for the employee ' || l_pils_for_access.full_name);
   write_h('l_pils_for_access.per_in_ler_id is '||l_pils_for_access.per_in_ler_id);
    l_no_of_man_picked := l_no_of_man_picked + 1;
    /*
    l_emps_not_found  := FALSE;

    OPEN  c_emp_pils_still_open(l_pils_for_access.mgr_per_in_ler_id);
    FETCH c_emp_pils_still_open INTO l_emp_pils_still_open;
    IF c_emp_pils_still_open%NOTFOUND THEN
      l_emps_not_found := TRUE;
      write_h('All Employees are processed for this manager and eligible for status update');
    ELSE
      write_h('Some Employees are not processed for this manager and not eligible for status update');
    END IF;
    CLOSE c_emp_pils_still_open;

    IF l_emps_not_found THEN
    */
      OPEN c_grp_ovn (l_pils_for_access.per_in_ler_id, p_group_pl_id, -1);

      FETCH c_grp_ovn
       INTO l_grp_ovn;
      CLOSE c_grp_ovn;

      write_h('l_grp_ovn.access_cd is '||l_grp_ovn.access_cd);

      IF l_grp_ovn.object_version_number IS NOT NULL AND
         (nvl(l_grp_ovn.access_cd,'UP') = 'UP'  OR nvl(l_grp_ovn.approval_cd, 'AP') = 'AP')
      THEN
         write_m('Access and approval cd update for '||l_pils_for_access.full_name);
         BEGIN
            ben_cwb_person_groups_api.update_group_budget
                                        (p_group_per_in_ler_id       => l_pils_for_access.per_in_ler_id
                                       , p_group_pl_id               => p_group_pl_id
                                       , p_group_oipl_id             => -1
                                       , p_access_cd                 => 'RO'
                                       , p_approval_date             => sysdate
                                       , p_approval_cd               => 'PR'
                                       , p_object_version_number     => l_grp_ovn.object_version_number
                                        );
           l_no_of_man_access_changed := l_no_of_man_access_changed +1;
         EXCEPTION
         WHEN OTHERS THEN
           WRITE(SQLERRM);
           write('Access processing for '||l_pils_for_access.full_name ||'errored');
         END;

       ELSE
       write_m('Access and approval cd not update for '||l_pils_for_access.full_name || ' as status is not UP');
      END IF;
    --END IF;
    write_h('--------------------------------------');
 END LOOP;
  CLOSE c_pils_for_access;

  WRITE('Number of persons picked for access change is ' || l_no_of_man_picked);
  WRITE('Number of persons access changed is '||l_no_of_man_access_changed);

 IF (p_validate = 'Y')
  THEN
   g_actn := 'Running in rollback mode, access processing rolled back...';
   WRITE (g_actn);
    ROLLBACK TO cwb_post_process_access;
 END IF;

END;


--
-- ============================================================================
--                            <<End_process>>
-- ============================================================================
--
  PROCEDURE end_process (
    p_benefit_action_id   IN   NUMBER
  , p_person_selected     IN   NUMBER
  , p_business_group_id   IN   NUMBER DEFAULT NULL
  )
  IS
    l_actions                 c_actions%ROWTYPE;
    l_batch_proc_id           NUMBER;
    l_object_version_number   NUMBER;
  BEGIN
    --
    -- Get totals for unprocessed, processed successfully and errored
    --
    g_proc := 'end_process';
    OPEN c_actions (p_benefit_action_id);

    LOOP
      FETCH c_actions
       INTO l_actions;

      EXIT WHEN c_actions%NOTFOUND;

      IF l_actions.action_status_cd = 'P'
      THEN
        g_exec_param_rec.persons_proc_succ := l_actions.amount;
      ELSIF l_actions.action_status_cd = 'E'
      THEN
        g_exec_param_rec.persons_errored := l_actions.amount;
      END IF;
    END LOOP;

    CLOSE c_actions;

    OPEN c_error_per_summary (p_benefit_action_id);

    FETCH c_error_per_summary
     INTO g_exec_param_rec.persons_errored;

    CLOSE c_error_per_summary;

    OPEN c_succ_per_summary (p_benefit_action_id);

    FETCH c_succ_per_summary
     INTO g_exec_param_rec.persons_proc_succ;

    CLOSE c_succ_per_summary;

    OPEN c_lf_evt_open_summary (p_benefit_action_id);

    FETCH c_lf_evt_open_summary
     INTO g_exec_param_rec.lf_evt_not_closed;

    CLOSE c_lf_evt_open_summary;

    OPEN c_lf_evt_close_summary (p_benefit_action_id);

    FETCH c_lf_evt_close_summary
     INTO g_exec_param_rec.lf_evt_closed;

    CLOSE c_lf_evt_close_summary;

    --
    -- Set value of number of persons processed
    --
    g_exec_param_rec.persons_selected :=
                               g_exec_param_rec.persons_errored + g_exec_param_rec.persons_proc_succ;
    ben_batch_proc_info_api.create_batch_proc_info
                                            (p_validate                  => FALSE
                                           , p_batch_proc_id             => l_batch_proc_id
                                           , p_benefit_action_id         => p_benefit_action_id
                                           , p_strt_dt                   => TRUNC
                                                                              (g_exec_param_rec.start_date
                                                                              )
                                           , p_end_dt                    => TRUNC (SYSDATE)
                                           , p_strt_tm                   => TO_CHAR
                                                                              (g_exec_param_rec.start_date
                                                                             , 'HH24:MI:SS'
                                                                              )
                                           , p_end_tm                    => TO_CHAR (SYSDATE
                                                                                   , 'HH24:MI:SS'
                                                                                    )
                                           , p_elpsd_tm                  => TO_CHAR
                                                                              ((DBMS_UTILITY.get_time
                                                                                - g_exec_param_rec.start_time
                                                                               )
                                                                               / 100
                                                                              )
                                                                            || ' seconds'
                                           , p_per_slctd                 => g_exec_param_rec.persons_selected
                                           , p_per_proc                  => g_exec_param_rec.lf_evt_closed
                                           , p_per_unproc                => g_exec_param_rec.lf_evt_not_closed
                                           , p_per_proc_succ             => g_exec_param_rec.persons_proc_succ
                                           , p_per_err                   => g_exec_param_rec.persons_errored
                                           , p_business_group_id         => p_business_group_id
                                           , p_object_version_number     => l_object_version_number
                                            );
    COMMIT;
  END end_process;

  PROCEDURE init (p_group_plan_id IN NUMBER, p_lf_evt_ocrd_dt IN DATE)
  IS
    l_group_plan_rec      c_group_plan_name%ROWTYPE;
    l_group_option_rec    c_group_option_name%ROWTYPE;
    l_actual_plan_rec     c_plan_name%ROWTYPE;
    l_actual_option_rec   c_option_name%ROWTYPE;
  BEGIN
    g_proc := 'init';

    g_cwb_rpt_person.person_rate_id :=null;
    g_cwb_rpt_person.pl_id          :=null;
    g_cwb_rpt_person.person_id      :=null;
    g_cwb_rpt_person.oipl_id        :=null;
    g_cwb_rpt_person.group_pl_id    :=null;
    g_cwb_rpt_person.group_oipl_id  :=null;
    g_cwb_rpt_person.full_name      :=null;
    g_cwb_rpt_person.emp_number     :=null;
    g_cwb_rpt_person. business_group_name   :=null;
    g_cwb_rpt_person.business_group_id      :=null;
    g_cwb_rpt_person.manager_name           :=null;
    g_cwb_rpt_person.ws_mgr_id              :=null;
    g_cwb_rpt_person.pl_name                :=null;
    g_cwb_rpt_person.opt_name               :=null;
    g_cwb_rpt_person.amount                 :=null;
    g_cwb_rpt_person.units                   :=null;
    g_cwb_rpt_person.performance_rating      :=null;
    g_cwb_rpt_person.assignment_changed      :=null;
    g_cwb_rpt_person.status                  :=null;
    g_cwb_rpt_person.lf_evt_closed           :=null;
    g_cwb_rpt_person.error_or_warning_text   :=null;
    g_cwb_rpt_person.benefit_action_id      :=null;
    OPEN c_group_plan_name (p_group_plan_id, p_lf_evt_ocrd_dt);

    FETCH c_group_plan_name
     INTO l_group_plan_rec;

    g_group_plan_name := l_group_plan_rec.NAME;

    CLOSE c_group_plan_name;

    OPEN c_group_option_name (p_group_plan_id, p_lf_evt_ocrd_dt);

    LOOP
      FETCH c_group_option_name
       INTO l_group_option_rec;

      EXIT WHEN c_group_option_name%NOTFOUND;
      g_cache_group_options (l_group_option_rec.group_oipl_id) := l_group_option_rec.NAME;
    END LOOP;

    CLOSE c_group_option_name;

    OPEN c_plan_name (p_group_plan_id, p_lf_evt_ocrd_dt);

    LOOP
      FETCH c_plan_name
       INTO l_actual_plan_rec;

      EXIT WHEN c_plan_name%NOTFOUND;
      g_cache_actual_plans (l_actual_plan_rec.pl_id) := l_actual_plan_rec.NAME;
    END LOOP;

    CLOSE c_plan_name;

    OPEN c_option_name (p_group_plan_id, p_lf_evt_ocrd_dt);

    LOOP
      FETCH c_option_name
       INTO l_actual_option_rec;

      EXIT WHEN c_option_name%NOTFOUND;
      g_cache_actual_options (l_actual_option_rec.oipl_id) := l_actual_option_rec.NAME;
    END LOOP;

    CLOSE c_option_name;
  END;

  PROCEDURE insert_person_actions (
    p_per_actn_id_array     IN   g_number_type
  , p_per_id                IN   g_number_type
  , p_group_per_in_ler_id   IN   g_number_type
  , p_benefit_action_id     IN   NUMBER
  , p_is_placeholder        IN   g_number_type
  )
  IS
    l_num_rows   NUMBER := p_per_actn_id_array.COUNT;
  BEGIN
    g_proc := 'insert_person_actions';
    write('Time before inserting person actions '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
    FORALL l_count IN 1 .. p_per_actn_id_array.COUNT
      --
      INSERT INTO ben_person_actions
                  (person_action_id
                 , person_id
                 , ler_id
                 , benefit_action_id
                 , action_status_cd
                 , object_version_number
                 , NON_PERSON_CD
                  )
           VALUES (p_per_actn_id_array (l_count)
                 , p_per_id (l_count)
                 , p_group_per_in_ler_id (l_count)
                 , p_benefit_action_id
                 , 'U'
                 , 1
                 , decode(p_is_placeholder (l_count),1,'Y','N')
                  );

      write_m ('Time before inserting ben batch ranges '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
    INSERT INTO ben_batch_ranges
                (range_id
               , benefit_action_id
               , range_status_cd
               , starting_person_action_id
               , ending_person_action_id
               , object_version_number
                )
         VALUES (ben_batch_ranges_s.NEXTVAL
               , p_benefit_action_id
               , 'U'
               , p_per_actn_id_array (1)
               , p_per_actn_id_array (l_num_rows)
               , 1
                );
   write_m ('Time at end of insert person actions '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
  END;

  PROCEDURE print_cache
  IS
    l_evaluated    NUMBER (9) := 0;
    l_successful   NUMBER (9) := 0;
    l_error        NUMBER (9) := 0;
    l_closed_le    NUMBER (9) := 0;
    l_open_le      NUMBER (9) := 0;
    l_previous     NUMBER     := -1;
    l_message_number NUMBER;
    l_message_text VARCHAR2 (2000);
  BEGIN
    g_proc := 'print_cache';
    WRITE ('Time before printing cache '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
    WRITE ('Populating records into reporting tables...');
    --
    FOR i IN 1 .. g_cache_cwb_rpt_person.COUNT
    LOOP
      BEGIN
       IF(g_cache_cwb_rpt_person (i).status='E') THEN
        l_message_number := fnd_number.canonical_to_number
         (substr(g_cache_cwb_rpt_person (i).error_or_warning_text,1,
          instr(g_cache_cwb_rpt_person (i).error_or_warning_text,' ')));
       END IF;
        l_message_text := g_cache_cwb_rpt_person (i).error_or_warning_text;
      EXCEPTION
       WHEN others THEN
        l_message_text := '-1 Oracle Internal Error. Check logfile for details.';
      END;
      IF(g_cache_cwb_rpt_person (i).ws_sub_acty_typ_cd = 'ICM7' AND
	 nvl(g_cache_cwb_rpt_person (i).amount_posted,0) = 0) THEN
		g_cache_cwb_rpt_person (i).new_sal:=g_cache_cwb_rpt_person (i).prev_sal;
      END IF;/*
      g_cache_cwb_rpt_person (i).amount is null OR
         g_cache_cwb_rpt_person (i).amount = 0) THEN
         g_cache_cwb_rpt_person (i).prev_sal := null;
         g_cache_cwb_rpt_person (i).new_sal := null;
      END IF;*/
       INSERT INTO ben_cwb_rpt_detail
                  (benefit_action_id
                 , person_rate_id
                 , pl_id
                 , person_id
                 , country_code
                 , group_per_in_ler_id
                 , oipl_id
                 , group_pl_id
                 , group_oipl_id
                 , ws_mgr_id
                 , lf_evt_ocrd_dt
                 , full_name
                 , employee_number
                 , business_group_id
                 , business_group_name
                 , manager_name
                 , pl_name
                 , opt_name
                 , amount
                 , units
                 , performance_rating
                 , assignment_changed_flag
                 , status_cd
                 , lf_evt_closed_flag
                 , error_or_warning_text
                 , cwb_rpt_detail_id
  , base_salary_currency
  , currency
  , base_salary
  , elig_salary
  , percent_of_elig_sal
  , base_sal_freq
  , pay_ann_factor
  , pl_ann_factor
  , conversion_factor
  , adjusted_amount
  , prev_sal
  , new_sal
  , pay_proposal_id
  , pay_basis_id
  , element_entry_id
  , exchange_rate
  , effective_date
  , reason
  , eligibility
  , fte_factor
  , element_input_value
  , amount_posted
  , assignment_id
  , element_entry_value_id
  , input_value_id
  , element_type_id
  , eev_screen_entry_value
  , elmnt_processing_type
  , uom_precision
  , ws_sub_acty_typ_cd
  , posted_rating
  , rating_type
  , rating_date
  , prior_job
  , posted_job
  , proposed_job
  , prior_position
  , posted_position
  , proposed_position
  , prior_grade
  , posted_grade
  , proposed_grade
  , prior_group
  , posted_group
  , proposed_group
  , prior_flex1
  , posted_flex1
  , proposed_flex1
  , prior_flex2
  , posted_flex2
  , proposed_flex2
  , prior_flex3
  , posted_flex3
  , proposed_flex3
  , prior_flex4
  , posted_flex4
  , proposed_flex4
  , prior_flex5
  , posted_flex5
  , proposed_flex5
  , prior_flex6
  , posted_flex6
  , proposed_flex6
  , prior_flex7
  , posted_flex7
  , proposed_flex7
  , prior_flex8
  , posted_flex8
  , proposed_flex8
  , prior_flex9
  , posted_flex9
  , proposed_flex9
  , prior_flex10
  , posted_flex10
  , proposed_flex10
  , prior_flex11
  , posted_flex11
  , proposed_flex11
  , prior_flex12
  , posted_flex12
  , proposed_flex12
  , prior_flex13
  , posted_flex13
  , proposed_flex13
  , prior_flex14
  , posted_flex14
  , proposed_flex14
  , prior_flex15
  , posted_flex15
  , proposed_flex15
  , prior_flex16
  , posted_flex16
  , proposed_flex16
  , prior_flex17
  , posted_flex17
  , proposed_flex17
  , prior_flex18
  , posted_flex18
  , proposed_flex18
  , prior_flex19
  , posted_flex19
  , proposed_flex19
  , prior_flex20
  , posted_flex20
  , proposed_flex20
  , prior_flex21
  , posted_flex21
  , proposed_flex21
  , prior_flex22
  , posted_flex22
  , proposed_flex22
  , prior_flex23
  , posted_flex23
  , proposed_flex23
  , prior_flex24
  , posted_flex24
  , proposed_flex24
  , prior_flex25
  , posted_flex25
  , proposed_flex25
  , prior_flex26
  , posted_flex26
  , proposed_flex26
  , prior_flex27
  , posted_flex27
  , proposed_flex27
  , prior_flex28
  , posted_flex28
  , proposed_flex28
  , prior_flex29
  , posted_flex29
  , proposed_flex29
  , prior_flex30
  , posted_flex30
  , proposed_flex30
  , asgn_change_reason
  , pending_workflow
  , new_rpt
  , prev_eev_screen_entry_value)
           VALUES (benutils.g_benefit_action_id
                 , g_cache_cwb_rpt_person (i).person_rate_id
                 , g_cache_cwb_rpt_person (i).pl_id
                 , g_cache_cwb_rpt_person (i).person_id
                 ,  g_cache_cwb_rpt_person (i).country_code
                 , g_cache_cwb_rpt_person (i).group_per_in_ler_id
                 , g_cache_cwb_rpt_person (i).oipl_id
                 , g_cache_cwb_rpt_person (i).group_pl_id
                 , g_cache_cwb_rpt_person (i).group_oipl_id
                 , g_cache_cwb_rpt_person (i).ws_mgr_id
                 , g_cache_cwb_rpt_person (i).lf_evt_ocrd_date
                 , g_cache_cwb_rpt_person (i).full_name
                 , g_cache_cwb_rpt_person (i).emp_number
                 , g_cache_cwb_rpt_person (i).business_group_id
                 , g_cache_cwb_rpt_person (i).business_group_name
                 , g_cache_cwb_rpt_person (i).manager_name
                 , g_cache_cwb_rpt_person (i).pl_name
                 , g_cache_cwb_rpt_person (i).opt_name
                 , g_cache_cwb_rpt_person (i).amount
                 , g_cache_cwb_rpt_person (i).units
                 , g_cache_cwb_rpt_person (i).performance_rating
                 , g_cache_cwb_rpt_person (i).assignment_changed
                 , g_cache_cwb_rpt_person (i).status
                 , g_cache_cwb_rpt_person (i).lf_evt_closed
                 , l_message_text
                 , ben_cwb_rpt_detail_s.NEXTVAL
  ,  g_cache_cwb_rpt_person (i).base_salary_currency
  ,  g_cache_cwb_rpt_person (i).currency
  ,  round(g_cache_cwb_rpt_person (i).base_salary*g_cache_cwb_rpt_person (i).pay_ann_factor/g_cache_cwb_rpt_person (i).pl_ann_factor,
     nvl(g_cache_cwb_rpt_person (i).uom_precision,2))
  ,  g_cache_cwb_rpt_person (i).elig_salary
  ,  g_cache_cwb_rpt_person (i).percent_of_elig_sal
  ,  g_cache_cwb_rpt_person (i).base_sal_freq
  ,  g_cache_cwb_rpt_person (i).pay_ann_factor
  ,  g_cache_cwb_rpt_person (i).pl_ann_factor
  ,  g_cache_cwb_rpt_person (i).conversion_factor
  ,  g_cache_cwb_rpt_person (i).adjusted_amount
  ,  g_cache_cwb_rpt_person (i).prev_sal
  ,  g_cache_cwb_rpt_person (i).new_sal
  ,  g_cache_cwb_rpt_person (i).pay_proposal_id
  ,  g_cache_cwb_rpt_person (i).pay_basis_id
  ,  g_cache_cwb_rpt_person (i).element_entry_id
  ,  g_cache_cwb_rpt_person (i).exchange_rate
  ,  g_cache_cwb_rpt_person (i).effective_date
  ,  hr_general.decode_lookup('PROPOSAL_REASON',g_cache_cwb_rpt_person (i).reason)   -- bug : 7042887
  ,  g_cache_cwb_rpt_person (i).eligibility
  ,  g_cache_cwb_rpt_person (i).fte_factor
  ,  g_cache_cwb_rpt_person (i).element_input_value
  ,  nvl(g_cache_cwb_rpt_person (i).amount_posted,0)
  ,  g_cache_cwb_rpt_person (i).assignment_id
  ,  g_cache_cwb_rpt_person (i).element_entry_value_id
  ,  g_cache_cwb_rpt_person (i).input_value_id
  ,  g_cache_cwb_rpt_person (i).element_type_id
  ,  g_cache_cwb_rpt_person (i).eev_screen_entry_value
  ,  g_cache_cwb_rpt_person (i).elmnt_processing_type
  ,  g_cache_cwb_rpt_person (i).uom_precision
  ,  g_cache_cwb_rpt_person (i).ws_sub_acty_typ_cd
  ,  substr(g_cache_cwb_rpt_person (i).posted_rating,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).rating_type,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).rating_date,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_job,1,700)			--sg
  ,  substr(g_cache_cwb_rpt_person (i).posted_job,1,700)		--sg
  ,  substr(g_cache_cwb_rpt_person (i).proposed_job,1,700)		--sg
  ,  substr(g_cache_cwb_rpt_person (i).prior_position,1,240)		--sg
  ,  substr(g_cache_cwb_rpt_person (i).posted_position,1,240)		--sg
  ,  substr(g_cache_cwb_rpt_person (i).proposed_position,1,240)		--sg
  ,  substr(g_cache_cwb_rpt_person (i).prior_grade,1,240)		--sg
  ,  substr(g_cache_cwb_rpt_person (i).posted_grade,1,240)		--sg
  ,  substr(g_cache_cwb_rpt_person (i).proposed_grade,1,240)		--sg
  ,  substr(g_cache_cwb_rpt_person (i).prior_group,1,240)		--sg
  ,  substr(g_cache_cwb_rpt_person (i).posted_group,1,240)		--sg
  ,  substr(g_cache_cwb_rpt_person (i).proposed_group,1,240)		--sg
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex1,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex1,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex1,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex2,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex2,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex2,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex3,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex3,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex3,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex4,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex4,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex4,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex5,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex5,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex5,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex6,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex6,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex6,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex7,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex7,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex7,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex8,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex8,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex8,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex9,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex9,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex9,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex10,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex10,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex10,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex11,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex11,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex11,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex12,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex12,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex12,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex13,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex13,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex13,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex14,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex14,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex14,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex15,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex15,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex15,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex16,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex16,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex16,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex17,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex17,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex17,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex18,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex18,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex18,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex19,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex19,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex19,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex20,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex20,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex20,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex21,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex21,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex21,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex22,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex22,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex22,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex23,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex23,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex23,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex24,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex24,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex24,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex25,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex25,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex25,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex26,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex26,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex26,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex27,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex27,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex27,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex28,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex28,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex28,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex29,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex29,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex29,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).prior_flex30,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).posted_flex30,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).proposed_flex30,1,30)
  ,  substr(g_cache_cwb_rpt_person (i).asgn_change_reason,1,30)
  ,  g_cache_cwb_rpt_person (i).pending_workflow
  ,  'Y'
  ,  g_cache_cwb_rpt_person (i).prev_eev_screen_entry_value);
      IF l_previous <> g_cache_cwb_rpt_person (i).person_id
      THEN
        l_previous := g_cache_cwb_rpt_person (i).person_id;

        INSERT INTO ben_cwb_rpt_detail
                    (benefit_action_id
                   , person_rate_id
                   , person_id
                   , country_code
                   , business_group_id
                   , business_group_name
                   , status_cd
                   , lf_evt_closed_flag
                   , cwb_rpt_detail_id
                    )
             VALUES (benutils.g_benefit_action_id
                   , -9999
                   , g_cache_cwb_sum_person (g_cache_cwb_rpt_person (i).person_id).person_id
                   , g_cache_cwb_sum_person (g_cache_cwb_rpt_person (i).person_id).country_code
                   , g_cache_cwb_sum_person (g_cache_cwb_rpt_person (i).person_id).bg_id
                   , g_cache_cwb_sum_person (g_cache_cwb_rpt_person (i).person_id).bg_name
                   , g_cache_cwb_sum_person (g_cache_cwb_rpt_person (i).person_id).status
                   , g_cache_cwb_sum_person (g_cache_cwb_rpt_person (i).person_id).lf_evt_closed
                   , ben_cwb_rpt_detail_s.NEXTVAL
                    );

        IF (g_cache_cwb_sum_person (g_cache_cwb_rpt_person (i).person_id).status = 'E')
        THEN
          l_error := l_error + 1;
        END IF;

        IF (   g_cache_cwb_sum_person (g_cache_cwb_rpt_person (i).person_id).status = 'SC'
            OR g_cache_cwb_sum_person (g_cache_cwb_rpt_person (i).person_id).status = 'WC'
            OR g_cache_cwb_sum_person (g_cache_cwb_rpt_person (i).person_id).status = 'W'
           )
        THEN
          l_successful := l_successful + 1;
        END IF;

        IF (g_cache_cwb_sum_person (g_cache_cwb_rpt_person (i).person_id).lf_evt_closed = 'Y')
        THEN
          l_closed_le := l_closed_le + 1;
        END IF;

        IF (g_cache_cwb_sum_person (g_cache_cwb_rpt_person (i).person_id).lf_evt_closed = 'N')
        THEN
          l_open_le := l_open_le + 1;
        END IF;
      END IF;
    END LOOP;
    WRITE ('Time at the end of printing cache '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
    --
    l_evaluated := l_successful + l_error;
    WRITE ('=======================Summary of the run =========================');
    WRITE ('No of persons evaluated in this thread ' || l_evaluated);
    WRITE ('No of persons successful in this thread ' || l_successful);
    WRITE ('No of persons errored in this thread ' || l_error);
    WRITE ('No of life events closed in this thread ' || l_closed_le);
    WRITE ('No of life events open in this thread ' || l_open_le);
  END;

  PROCEDURE table_corrections (
    p_benefit_action_id   IN   NUMBER
  )
  IS
   l_table_correction_rec c_table_correction_data%ROWTYPE;
  BEGIN
   WRITE('table corrections');
   FOR l_table_correction_rec IN c_table_correction_data(p_benefit_action_id)
   LOOP
      INSERT INTO ben_cwb_rpt_detail (
        benefit_action_id,
        person_id,
        pl_id,
        oipl_id,
        group_per_in_ler_id,
        group_oipl_id,
        cwb_rpt_detail_id
        )
      VALUES (
        p_benefit_action_id,
        l_table_correction_rec.person_id,
        l_table_correction_rec.pl_id,
        l_table_correction_rec.oipl_id,
        l_table_correction_rec.group_per_in_ler_id,
        l_table_correction_rec.group_oipl_id,
        ben_cwb_rpt_detail_s.NEXTVAL
        );
      WRITE(
        p_benefit_action_id||'-'||
        l_table_correction_rec.person_id||'-'||
        l_table_correction_rec.pl_id||'-'||
        l_table_correction_rec.oipl_id||'-'||
        l_table_correction_rec.group_oipl_id
        );
   END LOOP;
  --EXCEPTION
  END;

   PROCEDURE get_plan_abr_info(
     p_lf_evt_ocrd_date    IN DATE
   , p_pl_id               IN NUMBER
   , p_oipl_id             IN NUMBER
   , p_element_type_id     OUT NOCOPY NUMBER
   , p_input_value_id      OUT NOCOPY NUMBER
   )
   IS
    l_found boolean;
    l_plan_abr_info plan_abr_info;
    l_element_type_id number;
    l_input_value_id number;
    BEGIN
    l_found := false;
     FOR element IN 1..g_plan_abr_info.COUNT
      LOOP
       if(g_plan_abr_info(element).pl_id = p_pl_id) then
        if(g_plan_abr_info(element).oipl_id = p_oipl_id) then
         l_element_type_id := g_plan_abr_info(element).element_type_id;
         l_input_value_id  := g_plan_abr_info(element).input_value_id;
         l_found := true;
        end if;
       end if;
      END LOOP;
      if(l_found = false) then
        OPEN c_get_abr_info(p_lf_evt_ocrd_date
                           ,p_pl_id
 		          ,p_oipl_id);
        FETCH c_get_abr_info INTO l_element_type_id,l_input_value_id;
        CLOSE c_get_abr_info;
        l_plan_abr_info.pl_id   := p_pl_id;
        l_plan_abr_info.oipl_id := p_oipl_id;
        l_plan_abr_info.element_type_id := l_element_type_id;
        l_plan_abr_info.input_value_id := l_input_value_id;
        g_plan_abr_info.extend;
        g_plan_abr_info(g_plan_abr_info.last) := l_plan_abr_info;
      end if;
      p_element_type_id := l_element_type_id;
      p_input_value_id  := l_input_value_id;
     EXCEPTION
      WHEN others THEN
       WRITE('Error at get_plan_abr_info');
       WRITE(SQLERRM);
     END;

  FUNCTION get_ws_rate_start_dt(
    p_group_per_in_ler_id IN NUMBER,
    p_group_pl_id IN NUMBER,
    p_pl_id IN NUMBER,
    p_oipl_id IN NUMBER,
    p_group_oipl_id IN NUMBER,
    p_lf_evt_ocrd_dt IN DATE
   )
  RETURN DATE
  IS
   l_rate_start_date DATE;
  BEGIN
   OPEN c_get_ws_rate_start_dt(
    p_group_per_in_ler_id,
    p_group_pl_id,
    p_pl_id,
    p_oipl_id,
    p_group_oipl_id,
    p_lf_evt_ocrd_dt);
   FETCH c_get_ws_rate_start_dt INTO l_rate_start_date;
   CLOSE c_get_ws_rate_start_dt;
   RETURN l_rate_start_date;
  END ;

  FUNCTION get_override_start_date(
    p_lf_evt_ocrd_date    IN DATE
  , p_group_pl_id         IN NUMBER
  , p_pl_id               IN NUMBER
  , p_group_oipl_id       IN NUMBER
  , p_oipl_id             IN NUMBER
  , p_effective_date      IN DATE
  )
  RETURN DATE
  IS
    l_local_plan    varchar2(50);
    l_local_option  varchar2(50);
    l_group_plan    varchar2(50);
    l_group_option  varchar2(50);
    l_count         number;
    l_found         boolean;
    l_index         number;
    l_plan          number;
    l_group_pl_id   number;
    l_pl_id         number;
    l_group_oipl_id number;
    l_oipl_id       number;
    --l_lf_evt_ocrd_date date;
    l_date          date;
    l_plan_date     plan_override_date;
  BEGIN
    l_local_plan     := p_pl_id;
    l_local_option   := p_oipl_id;
    l_group_plan     := p_group_pl_id;
    l_group_option   := p_group_oipl_id;
    l_count := 1;
    l_found := null;
   /*WRITE(p_lf_evt_ocrd_date||' '||p_group_pl_id||' '||p_pl_id||' '||p_group_oipl_id
   ||' '||p_oipl_id||' '||p_effective_date);*/
   WHILE l_count <= 4 LOOP
    CASE l_count
      WHEN 1 THEN if(((l_found is null)or(l_found <> true))and(l_local_option <> -1)) then
                   l_plan_date.plan := l_local_option;
                   FOR element IN 1..g_override_dates.COUNT
		    LOOP
		     if(g_override_dates(element).plan = l_local_option) then
		      if(g_override_dates(element).date is not null) then
		       l_found := true; --found entry in table with date
		       l_date := g_override_dates(element).date;
       		       WRITE(g_override_dates(element).date
		       ||' Override date found for Local Option : '
		       || g_override_dates(element).plan);
		      else
		       l_found := false; --found entry : dont run cursor!
		      end if;
		     end if;
		     EXIT when(l_found = true);
                    END LOOP;
		     if(l_found is null) then
		      OPEN c_override_start_date(p_group_pl_id,p_pl_id,p_group_oipl_id,p_oipl_id,p_lf_evt_ocrd_date);
                      FETCH c_override_start_date INTO l_date;
                      CLOSE c_override_start_date;
		      if(l_date is not null) then
		       l_found := true;
		      end if;
		      l_plan_date.date := l_date;
                      g_override_dates.extend;
                      g_override_dates(g_override_dates.last) := l_plan_date;
		     end if;
		    end if;
      WHEN 2 THEN if(((l_found is null)or(l_found <> true))and(l_group_option <> -1)) then
                   l_plan_date.plan := l_group_option;
                   FOR element IN 1..g_override_dates.COUNT
		    LOOP
		     if(g_override_dates(element).plan = l_group_option) then
		      if(g_override_dates(element).date is not null) then
		       l_found := true; --found entry in table with date
		       l_date := g_override_dates(element).date;
       		       WRITE(g_override_dates(element).date
		       ||' Override date found for Group Option : '
		       || g_override_dates(element).plan);
		      else
		       l_found := false; --found entry : dont run cursor!
		      end if;
		     end if;
		     EXIT when(l_found = true);
                    END LOOP;
		     if(l_found is null) then
		      OPEN c_override_start_date(p_group_pl_id,p_group_pl_id,p_group_oipl_id,p_group_oipl_id,p_lf_evt_ocrd_date);
                      FETCH c_override_start_date INTO l_date;
                      CLOSE c_override_start_date;
		      if(l_date is not null) then
		       l_found := true;
		      end if;
		      l_plan_date.date := l_date;
                      g_override_dates.extend;
                      g_override_dates(g_override_dates.last) := l_plan_date;
		     end if;
		    end if;
      WHEN 3 THEN if(((l_found is null)or(l_found <> true))and(l_local_plan<>l_group_plan)) then
                   l_plan_date.plan := l_local_plan;
                   FOR element IN 1..g_override_dates.COUNT
		    LOOP
		     if(g_override_dates(element).plan = l_local_plan) then
		      if(g_override_dates(element).date is not null) then
		       l_found := true; --found entry in table with date
		       l_date := g_override_dates(element).date;
       		       WRITE(g_override_dates(element).date
		       ||' Override date found for Local Plan : '
		       || g_override_dates(element).plan);
		      else
		       l_found := false; --found entry : dont run cursor!
		      end if;
		     end if;
		     EXIT when(l_found = true);
                    END LOOP;
		     if(l_found is null) then
		      OPEN c_override_start_date(p_group_pl_id,p_pl_id,-1,-1,p_lf_evt_ocrd_date);
                      FETCH c_override_start_date INTO l_date;
                      CLOSE c_override_start_date;
		      if(l_date is not null) then
		       l_found := true;
		      end if;
		      l_plan_date.date := l_date;
                      g_override_dates.extend;
                      g_override_dates(g_override_dates.last) := l_plan_date;
		     end if;
		    end if;
      WHEN 4 THEN if((l_found is null)or(l_found <> true)) then
                   l_plan_date.plan := l_group_plan;
                   FOR element IN 1..g_override_dates.COUNT
		    LOOP
		     if(g_override_dates(element).plan = l_group_plan) then
		      if(g_override_dates(element).date is not null) then
		       l_found := true; --found entry in table with date
		       l_date := g_override_dates(element).date;
       		       WRITE(g_override_dates(element).date
		       ||' Override date found for Group Plan : '
		       || g_override_dates(element).plan);
		      else
		       l_found := false; --found entry : dont run cursor!
		      end if;
		     end if;
		     EXIT when(l_found = true);
                    END LOOP;
		     if(l_found is null) then
		      OPEN c_override_start_date(p_group_pl_id,p_group_pl_id,-1,-1,p_lf_evt_ocrd_date);
                      FETCH c_override_start_date INTO l_date;
                      CLOSE c_override_start_date;
		      if(l_date is not null) then
		       l_found := true;
		      end if;
		      l_plan_date.date := l_date;
                      g_override_dates.extend;
                      g_override_dates(g_override_dates.last) := l_plan_date;
		     end if;
		    end if;
   END CASE;
   l_count := l_count + 1;
  END LOOP;
  /*
  FOR element IN 1..g_override_dates.COUNT
  LOOP
   WRITE(g_override_dates(element).plan||' - '||g_override_dates(element).date);
  END LOOP;
  */
  RETURN l_date;
  END;

  PROCEDURE process_life_event (
    p_person_id               IN              NUMBER
  , p_lf_evt_ocrd_date        IN              DATE
  , p_plan_id                 IN              NUMBER
  , p_group_per_in_ler_id     IN              NUMBER
  , p_effective_date          IN              DATE
  , p_employees_in_bg         IN              NUMBER
  )
  IS
    pil_rec                      c_per_in_ler_ids%ROWTYPE;
    l_procd_dt                   DATE;
    l_strtd_dt                   DATE;
    l_voidd_dt                   DATE;
    l_count_open_lers            NUMBER                             := 0;
    l_pil_ovn                    c_pil_ovn%ROWTYPE;
    l_info_ovn                   c_info_ovn%ROWTYPE;
  BEGIN

    write_m ('Time before processing the life events '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
    OPEN c_per_in_ler_ids (p_plan_id, p_employees_in_bg, p_person_id, p_lf_evt_ocrd_date);

    LOOP
      FETCH c_per_in_ler_ids
       INTO pil_rec;

      EXIT WHEN c_per_in_ler_ids%NOTFOUND;

      IF (pil_rec.per_in_ler_id <> p_group_per_in_ler_id)
      THEN
        write_h ('selected per_in_ler_id ' || pil_rec.per_in_ler_id || ' for closing');
        ben_person_life_event_api.update_person_life_event
                                         (p_per_in_ler_id             => pil_rec.per_in_ler_id
                                        , p_per_in_ler_stat_cd        => 'PROCD'
                                        , p_procd_dt                  => l_procd_dt
                                        , p_voidd_dt                  => l_voidd_dt
                                        , p_strtd_dt                  => l_strtd_dt
                                        , p_object_version_number     => pil_rec.object_version_number
                                        , p_effective_date            => p_effective_date
                                         );
      END IF;
    END LOOP;

    CLOSE c_per_in_ler_ids;
    write_m ('Time after processing the life events '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

    g_persons_procd := g_persons_procd + 1;

    OPEN c_per_in_ler_ids (p_plan_id, p_employees_in_bg, p_person_id, p_lf_evt_ocrd_date);

    LOOP
      FETCH c_per_in_ler_ids
       INTO pil_rec;

      EXIT WHEN c_per_in_ler_ids%NOTFOUND;

      IF (    pil_rec.per_in_ler_id <> p_group_per_in_ler_id
          AND pil_rec.per_in_ler_stat_cd <> 'PROCD'
         )
      THEN
        write_h ('Following actual per_in_ler_id ' || pil_rec.per_in_ler_id || ' still open');
        l_count_open_lers := l_count_open_lers + 1;
      END IF;
    END LOOP;

    CLOSE c_per_in_ler_ids;

    IF (l_count_open_lers = 0)
    THEN
      write_h ('selected the group_per_in_ler_id ' || p_group_per_in_ler_id || ' for closing');

      OPEN c_pil_ovn (p_group_per_in_ler_id);

      FETCH c_pil_ovn
       INTO l_pil_ovn;

      CLOSE c_pil_ovn;
      write_h ('Time before updating the person life event '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
      ben_person_life_event_api.update_person_life_event
                                        (p_per_in_ler_id             => p_group_per_in_ler_id
                                       , p_per_in_ler_stat_cd        => 'PROCD'
                                       , p_procd_dt                  => l_procd_dt
                                       , p_voidd_dt                  => l_voidd_dt
                                       , p_strtd_dt                  => l_strtd_dt
                                       , p_object_version_number     => l_pil_ovn.object_version_number
                                       , p_effective_date            => p_effective_date
                                        );
      write_h ('Time after updating the person life event '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));


      OPEN c_info_ovn (p_group_per_in_ler_id);

       FETCH c_info_ovn
        INTO l_info_ovn;
       CLOSE c_info_ovn;

      WRITE ('updating post process stat code...');
      ben_cwb_person_info_api.update_person_info
                                           (p_group_per_in_ler_id       => p_group_per_in_ler_id
                                           , p_post_process_stat_cd      => 'PR'
                                           , p_object_version_number     => l_info_ovn.object_version_number
                                           );

      -- ************ audit changes ************* --
      ben_cwb_audit_api.update_per_record(p_per_in_ler_id => p_group_per_in_ler_id);
      -- **************************************** --

      WRITE ('creating cache for reporting...');

      g_cache_cwb_sum_person (p_person_id).lf_evt_closed := 'Y';
    ELSE
      g_cache_cwb_sum_person (p_person_id).lf_evt_closed := 'N';
    END IF;
  END;

  PROCEDURE process_sal_comp_rates (
    p_effective_date         IN              DATE
  , p_lf_evt_ocrd_date       IN              DATE
  , p_group_pl_id            IN              NUMBER
  , p_group_per_in_ler_id    IN              NUMBER
  , p_person_id              IN              NUMBER
  , p_cache_cwb_rpt_person   IN OUT NOCOPY   g_cache_cwb_rpt_person_rec
  , p_cwb_rpt_person_rec     IN OUT NOCOPY   g_cwb_rpt_person_rec
  , p_debug_level            IN              VARCHAR2 DEFAULT NULL
  , p_use_rate_start_date    IN              VARCHAR2 DEFAULT 'N'
  , p_post_zero_salary_increase   IN         VARCHAR2 DEFAULT NULL
  , p_pay_proposal_id        OUT NOCOPY      NUMBER
  , p_pay_basis_id           OUT NOCOPY      NUMBER
  , p_warning                OUT NOCOPY      BOOLEAN
  )
  IS

    asg_rec                   c_prev_pay_proposal%ROWTYPE;
    elm_rec                   c_element_entry%ROWTYPE;
    tot_com_amt_rec           c_tot_chg_amt_for_proposal%ROWTYPE;
    per_bg_rec                c_person_info%ROWTYPE;
    sal_rate_rec              c_sal_comp_rates%ROWTYPE;
    l_rate_ovn                c_rate_ovn%ROWTYPE;
    l_sal_factors             c_sal_factors%ROWTYPE;
    l_effective_date          DATE;
    l_precision               NUMBER;
    l_pay_proposal_id         NUMBER;
    l_sal_incr                NUMBER;
    l_ele_ent_id              NUMBER;
    l_prev_sal                NUMBER;
    l_object_version_number   NUMBER;
    l_dummy1                  BOOLEAN;
    l_dummy2                  BOOLEAN;
    l_dummy3                  BOOLEAN;
    l_dummy4                  BOOLEAN;
    l_component_ovn           NUMBER;
    l_component_id            NUMBER;
    l_component_reason        VARCHAR2 (200);
    l_count                   NUMBER                               := 0;
    l_total                   NUMBER;
    l_error                   BOOLEAN;
    l_warning_text            VARCHAR2 (2000);
    l_oipl_id                 NUMBER;
    l_message                 VARCHAR2 (600);
    l_message_name            VARCHAR2 (240);
    l_app_name                VARCHAR2 (240);
    l_pay_basis_id            NUMBER;
    future_pay_proposal_rec   c_future_pay_proposal%ROWTYPE;
    l_element_input_currency  VARCHAR2 (30);
  BEGIN
    g_actn := ' calling sal admin api for components ...';
    g_proc := 'process_sal_comp_rates';
    WRITE (g_actn);

    l_error := FALSE;
    p_warning := FALSE;

    IF(p_use_rate_start_date = 'Y') THEN
     WRITE ('Postings are ws rate start date based');
    END IF;

          OPEN c_salary_effective_date(p_group_per_in_ler_id,p_use_rate_start_date);
          FETCH c_salary_effective_date INTO l_effective_date;
          CLOSE c_salary_effective_date;

          IF(l_effective_date IS NULL AND p_use_rate_start_date = 'Y') THEN
           g_actn :=
            'The salary is not posted as no rate start date is defined.';
           WRITE (g_actn);
           fnd_message.set_name ('BEN', 'BEN_94906_CWB_NO_RATE_STRT_DT');
           l_message := fnd_message.get_encoded;
           fnd_message.set_encoded(l_message);
           --
           fnd_message.parse_encoded(encoded_message => l_message,
                                  app_short_name  => l_app_name,
                                  message_name    => l_message_name);
           IF g_person_errored = FALSE THEN
            l_warning_text := substr(l_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get,1,2000);
           END IF;
           l_error := TRUE;
           g_person_errored := TRUE;
          END IF;

          IF(l_effective_date IS NULL) THEN
            l_effective_date:=p_effective_date;
          END IF;
          WRITE ('Effective date :'||l_effective_date);

    OPEN c_prev_pay_proposal (p_group_per_in_ler_id, l_effective_date);

    FETCH c_prev_pay_proposal
     INTO asg_rec;
    CLOSE c_prev_pay_proposal;

    l_pay_basis_id := asg_rec.pay_basis_id;

    IF (asg_rec.pay_basis_id IS NOT NULL)
    THEN
      OPEN c_element_entry (asg_rec.pay_basis_id, asg_rec.assignment_id, l_effective_date);

      FETCH c_element_entry
       INTO elm_rec;
      l_prev_sal := asg_rec.proposed_salary_n;
      write_s ('Previous salary is ' || l_prev_sal);

      IF c_element_entry%FOUND
      THEN
        l_ele_ent_id := elm_rec.element_entry_id;
        write_m ('Element entry found...');
      ELSE
        l_ele_ent_id := NULL;
        write_m ('Element entry not found...');
      END IF;

      CLOSE c_element_entry;

      OPEN c_input_value_precision(asg_rec.assignment_id,l_effective_date);
      FETCH c_input_value_precision INTO l_precision;
      CLOSE c_input_value_precision;

    ELSE
      g_actn :=
            'The salary is not posted as no pay basis is defined.';
      WRITE (g_actn);
        fnd_message.set_name ('BEN', 'BEN_94674_CWB_NO_PAY_BASIS');
        l_message := fnd_message.get_encoded;
        fnd_message.set_encoded(l_message);
        --
        fnd_message.parse_encoded(encoded_message => l_message,
                                  app_short_name  => l_app_name,
                                  message_name    => l_message_name);
        IF g_person_errored = FALSE THEN
            l_warning_text := substr(l_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get,1,2000);
        END IF;
        l_error := TRUE;
        g_person_errored := TRUE;
    END IF;

      IF(l_precision IS NULL) THEN
        l_precision:=2;
      END IF;

      OPEN c_person_info (p_group_per_in_ler_id);

      FETCH c_person_info
       INTO per_bg_rec;

      CLOSE c_person_info;

write_h(per_bg_rec.base_salary);
write_h(asg_rec.proposed_salary_n);
write_h(l_precision);

      IF (round(per_bg_rec.base_salary,l_precision) <>
          round(asg_rec.proposed_salary_n,l_precision))
      THEN
        g_actn :=
          'This employee had a recent update to Base Salary '
          || 'or Pay Basis. The new salary could not be posted.'
          || ' Either delete the recent update and rerun this process,'
          || 'or apply the new salary manually. ';
        WRITE (g_actn);
        write_m('Salary in HR '||asg_rec.proposed_salary_n);
        write_m('Salary in CWB '||per_bg_rec.base_salary);
        fnd_message.set_name ('BEN', 'BEN_91141_CWB_RECENT_SAL_CHG');
        l_message := fnd_message.get_encoded;
        fnd_message.set_encoded(l_message);
        --
        fnd_message.parse_encoded(encoded_message => l_message,
                                  app_short_name  => l_app_name,
                                  message_name    => l_message_name);
        IF g_person_errored = FALSE THEN
            l_warning_text := substr(l_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get,1,2000);
        END IF;
        l_error := TRUE;
        g_person_errored := TRUE;
        --fnd_message.raise_error;
      END IF;

        OPEN c_sal_comp_rates_tot (p_group_per_in_ler_id,
                                   p_group_pl_id,
                                   p_lf_evt_ocrd_date,
                                   l_effective_date,
				   p_post_zero_salary_increase);
        FETCH c_sal_comp_rates_tot INTO l_total;
        CLOSE c_sal_comp_rates_tot;

        IF ((l_total IS NOT NULL) AND (NOT l_error)) THEN

          WRITE ('Inserting salary proposal...');
          write_m ('Time before inserting the salary proposal '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
          BEGIN
          hr_maintain_proposal_api.insert_salary_proposal
                                              (p_pay_proposal_id               => l_pay_proposal_id
                                             , p_assignment_id                 => asg_rec.assignment_id
                                             , p_business_group_id             => per_bg_rec.business_group_id
                                             , p_change_date                   => l_effective_date
                                             , p_object_version_number         => l_object_version_number
                                             , p_multiple_components           => 'Y'
                                             , p_approved                      => 'N'
                                             , p_validate                      => FALSE
                                             , p_element_entry_id              => l_ele_ent_id
                                             , p_inv_next_sal_date_warning     => l_dummy1
                                             , p_proposed_salary_warning       => l_dummy2
                                             , p_approved_warning              => l_dummy3
                                             , p_payroll_warning               => l_dummy4
                                              );
          OPEN c_future_pay_proposal (p_group_per_in_ler_id, l_effective_date);

          FETCH c_future_pay_proposal
          INTO future_pay_proposal_rec;
          CLOSE c_future_pay_proposal;

          IF(future_pay_proposal_rec.proposed_salary_n is not null) THEN
           p_warning := TRUE;
           fnd_message.set_name ('BEN', 'BEN_94685_FUTURE_SAL_PROP_WARN');
           l_message := fnd_message.get_encoded;
           fnd_message.set_encoded(l_message);
           --
           fnd_message.parse_encoded(encoded_message => l_message,
                                     app_short_name  => l_app_name,
                                     message_name    => l_message_name);
           IF g_person_errored = FALSE THEN
               l_warning_text := substr(l_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get,1,2000);
           END IF;
           g_person_errored := TRUE;
           --l_warning_text := l_warning_text||'Future dated salary proposal exists';
          END IF;

          EXCEPTION
           WHEN OTHERS THEN
            WRITE('Error in insert_salary_proposal : '||SQLERRM);
            l_error := TRUE;
            l_message := fnd_message.get_encoded;
            fnd_message.set_encoded(l_message);
            --
            fnd_message.parse_encoded(encoded_message => l_message,
                                      app_short_name  => l_app_name,
                                      message_name    => l_message_name);
            IF g_person_errored = FALSE THEN
                l_warning_text := substr(l_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get,1,2000);
            END IF;
            g_person_errored := TRUE;
          END;
         write_m ('Time after inserting the salary proposal '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
        END IF;

        OPEN c_sal_comp_rates (p_group_per_in_ler_id
                             , p_group_pl_id
                             , p_lf_evt_ocrd_date
                             , l_effective_date
                              );
        write_m ('Time before looping salary components '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

        LOOP
          FETCH c_sal_comp_rates
           INTO sal_rate_rec;
          l_oipl_id := sal_rate_rec.oipl_id;
          EXIT WHEN c_sal_comp_rates%NOTFOUND;

        IF(l_oipl_id <> -1) THEN
          --IF l_total IS NOT NULL THEN
             OPEN c_sal_factors(p_group_pl_id,p_lf_evt_ocrd_date,p_group_per_in_ler_id);
              FETCH c_sal_factors INTO l_sal_factors;
             CLOSE c_sal_factors;
             l_sal_incr := round(sal_rate_rec.ws_val * l_sal_factors.pl_annulization_factor / l_sal_factors.pay_annulization_factor,l_precision);
             WRITE('l_sal_factors.pl_annulization_factor is '||l_sal_factors.pl_annulization_factor);
             WRITE('l_sal_factors.pay_annulization_factor is '||l_sal_factors.pay_annulization_factor);
             WRITE('l_sal_factors.uom_precision is '||l_sal_factors.uom_precision);

          --END IF;
        END IF;

          WRITE ('Populating report record for salary processing with components...');
          p_cwb_rpt_person_rec.person_rate_id := sal_rate_rec.person_rate_id;
          p_cwb_rpt_person_rec.pl_id := sal_rate_rec.pl_id;
          p_cwb_rpt_person_rec.oipl_id := sal_rate_rec.oipl_id;
          p_cwb_rpt_person_rec.group_pl_id := sal_rate_rec.group_pl_id;
          p_cwb_rpt_person_rec.group_oipl_id := sal_rate_rec.group_oipl_id;
          p_cwb_rpt_person_rec.full_name := sal_rate_rec.full_name;
          p_cwb_rpt_person_rec.emp_number := sal_rate_rec.employee_number;
          p_cwb_rpt_person_rec.business_group_id := sal_rate_rec.business_group_id;
          p_cwb_rpt_person_rec.ws_mgr_id := sal_rate_rec.ws_mgr_id;
          p_cwb_rpt_person_rec.units := null;

          p_cwb_rpt_person_rec.base_salary_currency := per_bg_rec.base_salary_currency;
          p_cwb_rpt_person_rec.base_salary := per_bg_rec.base_salary;
          p_cwb_rpt_person_rec.elig_salary := round(sal_rate_rec.elig_sal_val,l_precision);
          p_cwb_rpt_person_rec.amount := round(nvl(sal_rate_rec.ws_val,0),l_precision);
          if(p_cwb_rpt_person_rec.elig_salary is null OR p_cwb_rpt_person_rec.elig_salary = 0 ) then
           p_cwb_rpt_person_rec.percent_of_elig_sal := 0;
          else
          p_cwb_rpt_person_rec.percent_of_elig_sal :=
           round((p_cwb_rpt_person_rec.amount/p_cwb_rpt_person_rec.elig_salary)*100,l_precision);
          end if;
          p_cwb_rpt_person_rec.base_sal_freq := per_bg_rec.base_salary_frequency;
          p_cwb_rpt_person_rec.pay_ann_factor := l_sal_factors.pay_annulization_factor;
          p_cwb_rpt_person_rec.pl_ann_factor := l_sal_factors.pl_annulization_factor;
          p_cwb_rpt_person_rec.conversion_factor :=
           round(l_sal_factors.pl_annulization_factor/l_sal_factors.pay_annulization_factor,
            l_precision);
          p_cwb_rpt_person_rec.adjusted_amount := round(nvl(l_sal_incr,0),l_precision);
          p_cwb_rpt_person_rec.prev_sal := round(nvl(asg_rec.proposed_salary_n,0),l_precision);
          p_cwb_rpt_person_rec.exchange_rate := sal_rate_rec.xchg_rate;
          p_cwb_rpt_person_rec.effective_date := l_effective_date;
          p_cwb_rpt_person_rec.reason := sal_rate_rec.component_reason;
          p_cwb_rpt_person_rec.eligibility := sal_rate_rec.elig_flag;
          p_cwb_rpt_person_rec.fte_factor := per_bg_rec.fte_factor;
          p_cwb_rpt_person_rec.group_per_in_ler_id := p_group_per_in_ler_id;
          p_cwb_rpt_person_rec.currency := sal_rate_rec.currency;
          p_cwb_rpt_person_rec.lf_evt_ocrd_date := p_lf_evt_ocrd_date;
          p_cwb_rpt_person_rec.ws_sub_acty_typ_cd := 'ICM7';


           if(l_error OR p_warning) then
            p_cwb_rpt_person_rec.error_or_warning_text := substr(l_warning_text,1,2000);
           end if;

         IF(l_oipl_id <> -1) THEN
          IF (l_total IS NOT NULL AND nvl(p_post_zero_salary_increase,nvl(l_sal_incr,0)) <> 0 AND (NOT l_error) AND sal_rate_rec.elig_flag = 'Y') THEN
            WRITE ('Inserting salary proposal component...');
            write_h ('==============Inserting Salary component ========');
            write_h ('||Parameter              Description            ');
            write_h ('||p_assignment_id -      ' || asg_rec.assignment_id);
            write_h ('||p_business_group_id -  ' || per_bg_rec.business_group_id);
            write_h ('||p_change_date -        ' || l_effective_date);
            write_h ('||p_component_reason -    ' || sal_rate_rec.component_reason);
            write_h ('||p_component_increase -  ' || l_sal_incr);
            write_h ('================================================');
            write_m ('Time before inserting the salary proposal components '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
            BEGIN
              OPEN c_element_input_currency(elm_rec.element_type_id,l_effective_date);
              FETCH c_element_input_currency INTO l_element_input_currency;
              CLOSE c_element_input_currency;

              IF(l_element_input_currency is not null
                 AND l_element_input_currency <> sal_rate_rec.currency) THEN
	           WRITE('Currency in CWB does not match Input Currency of the Element Type');
                   write_m('Currency for Element '||l_element_input_currency);
                   write_m('Currency in CWB '||sal_rate_rec.currency);

               fnd_message.set_name ('BEN', 'BEN_94673_EL_CURR_MISMATCH');
               l_message := fnd_message.get_encoded;
               fnd_message.set_encoded(l_message);
               --
               fnd_message.parse_encoded(encoded_message => l_message,
                                         app_short_name  => l_app_name,
                                         message_name    => l_message_name);
               IF g_person_errored = FALSE THEN
                   l_warning_text := substr(l_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get,1,2000);
               END IF;
               l_error := TRUE;
               g_person_errored := TRUE;
               --fnd_message.raise_error;

              END IF;
              hr_maintain_proposal_api.insert_proposal_component
                                              (p_component_id              => l_component_id
                                             , p_pay_proposal_id           => l_pay_proposal_id
                                             , p_business_group_id         => per_bg_rec.business_group_id
                                             , p_approved                  => 'Y'
                                             , p_component_reason          => sal_rate_rec.component_reason
                                             , p_change_amount_n           => l_sal_incr
                                             , p_object_version_number     => l_component_ovn
                                              );
            EXCEPTION
             WHEN OTHERS THEN
              WRITE('Error in insert_proposal_component : '||SQLERRM);
              l_error := TRUE;
              l_message := fnd_message.get_encoded;
              fnd_message.set_encoded(l_message);
              --
              fnd_message.parse_encoded(encoded_message => l_message,
                                        app_short_name  => l_app_name,
                                        message_name    => l_message_name);
              IF g_person_errored = FALSE THEN
                  l_warning_text := substr(l_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get,1,2000);
              END IF;
              g_person_errored := TRUE;
            END;

            write_m('Time after inserting the salary proposal components '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
            OPEN c_rate_ovn (p_group_per_in_ler_id, sal_rate_rec.pl_id, sal_rate_rec.oipl_id);

            FETCH c_rate_ovn
             INTO l_rate_ovn;

            CLOSE c_rate_ovn;
            write_m ('Time before updating the person rates with proposal and element entry ids '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
            ben_cwb_person_rates_api.update_person_rate
                                        (p_group_per_in_ler_id        => p_group_per_in_ler_id
                                       , p_pl_id                      => sal_rate_rec.pl_id
                                       , p_oipl_id                    => sal_rate_rec.oipl_id
                                       , p_pay_proposal_id            => l_pay_proposal_id
                                       , p_comp_posting_date          => l_effective_date
                                       , p_object_version_number      => l_rate_ovn.object_version_number
                                        );
            write_m ('Time after updating the person rates with proposal and element entry ids '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
            WRITE ('Pay proposal id and element entry id populated in to the table');
          END IF;
         END IF;


           l_count := l_count + 1;
           p_cache_cwb_rpt_person (l_count).person_rate_id := sal_rate_rec.person_rate_id;
           p_cache_cwb_rpt_person (l_count).pl_id := sal_rate_rec.pl_id;
           p_cache_cwb_rpt_person (l_count).oipl_id := sal_rate_rec.oipl_id;
           p_cache_cwb_rpt_person (l_count).group_pl_id := sal_rate_rec.group_pl_id;
           p_cache_cwb_rpt_person (l_count).group_oipl_id := sal_rate_rec.group_oipl_id;
           p_cache_cwb_rpt_person (l_count).full_name := sal_rate_rec.full_name;
           p_cache_cwb_rpt_person (l_count).emp_number := sal_rate_rec.employee_number;
           p_cache_cwb_rpt_person (l_count).business_group_id := sal_rate_rec.business_group_id;
           p_cache_cwb_rpt_person (l_count).ws_mgr_id := sal_rate_rec.ws_mgr_id;
           p_cache_cwb_rpt_person (l_count).units := null;

           p_cache_cwb_rpt_person (l_count).base_salary_currency := per_bg_rec.base_salary_currency;
           p_cache_cwb_rpt_person (l_count).base_salary := per_bg_rec.base_salary;
           p_cache_cwb_rpt_person (l_count).elig_salary := round(sal_rate_rec.elig_sal_val,l_precision);
           p_cache_cwb_rpt_person (l_count).amount := round(nvl(sal_rate_rec.ws_val,0),l_precision);
           if(p_cache_cwb_rpt_person (l_count).elig_salary is null OR p_cache_cwb_rpt_person (l_count).elig_salary = 0 ) then
            p_cache_cwb_rpt_person (l_count).percent_of_elig_sal := 0;
           else
           p_cache_cwb_rpt_person (l_count).percent_of_elig_sal :=
            round((p_cache_cwb_rpt_person (l_count).amount/p_cache_cwb_rpt_person (l_count).elig_salary)*100,l_precision);
           end if;
           p_cache_cwb_rpt_person (l_count).base_sal_freq := per_bg_rec.base_salary_frequency;
           p_cache_cwb_rpt_person (l_count).pay_ann_factor := l_sal_factors.pay_annulization_factor;
           p_cache_cwb_rpt_person (l_count).pl_ann_factor := l_sal_factors.pl_annulization_factor;
           p_cache_cwb_rpt_person (l_count).conversion_factor :=
            round(l_sal_factors.pl_annulization_factor/l_sal_factors.pay_annulization_factor,
             l_precision);
           p_cache_cwb_rpt_person (l_count).adjusted_amount := round(nvl(l_sal_incr,0),l_precision);
           p_cache_cwb_rpt_person (l_count).prev_sal := round(nvl(asg_rec.proposed_salary_n,0),l_precision);
           p_cache_cwb_rpt_person (l_count).exchange_rate := sal_rate_rec.xchg_rate;
           p_cache_cwb_rpt_person (l_count).effective_date := l_effective_date;
           p_cache_cwb_rpt_person (l_count).reason := sal_rate_rec.component_reason;
           p_cache_cwb_rpt_person (l_count).eligibility := sal_rate_rec.elig_flag;
           p_cache_cwb_rpt_person (l_count).fte_factor := per_bg_rec.fte_factor;

           p_cache_cwb_rpt_person (l_count).pay_proposal_id := l_pay_proposal_id;
           p_cache_cwb_rpt_person (l_count).pay_basis_id := asg_rec.pay_basis_id;

           p_cache_cwb_rpt_person (l_count).assignment_id := asg_rec.assignment_id;
           p_cache_cwb_rpt_person (l_count).uom_precision := l_sal_factors.uom_precision;
           p_cache_cwb_rpt_person (l_count).ws_sub_acty_typ_cd := 'ICM7';

           p_cache_cwb_rpt_person (l_count).group_per_in_ler_id := p_group_per_in_ler_id;
           p_cache_cwb_rpt_person (l_count).currency := sal_rate_rec.currency;
           p_cache_cwb_rpt_person (l_count).lf_evt_ocrd_date := p_lf_evt_ocrd_date;

           if(l_error or p_warning) then   --7218121
            p_cache_cwb_rpt_person (l_count).error_or_warning_text := substr(l_warning_text,1,2000);
           end if;
        END LOOP;
        write_m ('Time after looping salary components '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
        CLOSE c_sal_comp_rates;

        OPEN c_tot_chg_amt_for_proposal (l_pay_proposal_id);
        FETCH c_tot_chg_amt_for_proposal INTO tot_com_amt_rec;
        CLOSE c_tot_chg_amt_for_proposal;

        IF (l_total IS NOT NULL AND (NOT l_error)) THEN
          write_m ('Time before updating the salary proposal '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
          BEGIN
           hr_maintain_proposal_api.update_salary_proposal
                                           (p_pay_proposal_id               => l_pay_proposal_id
                                          , p_object_version_number         => l_object_version_number
                                          , p_proposed_salary_n             => (l_prev_sal
                                                                                + tot_com_amt_rec.tamt)
                                          , p_approved                      => 'Y'
                                          , p_inv_next_sal_date_warning     => l_dummy1
                                          , p_proposal_reason               => l_sal_factors.salary_change_reason
                                          , p_proposed_salary_warning       => l_dummy2
                                          , p_approved_warning              => l_dummy3
                                          , p_payroll_warning               => l_dummy4
                                           );
         write_m ('Time after updating the salary proposal '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
            EXCEPTION
             WHEN OTHERS THEN
              WRITE('Error in update_salary_proposal : '||SQLERRM);
              l_error := TRUE;
              l_message := fnd_message.get_encoded;
              fnd_message.set_encoded(l_message);
              --
              fnd_message.parse_encoded(encoded_message => l_message,
                                        app_short_name  => l_app_name,
                                        message_name    => l_message_name);
              IF g_person_errored = FALSE THEN
                  l_warning_text := substr(l_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get,1,2000);
              END IF;
              g_person_errored := TRUE;
            END;
        END IF;

       p_pay_proposal_id := l_pay_proposal_id;
       p_pay_basis_id := l_pay_basis_id;

       IF(l_error) THEN
        RAISE ben_batch_utils.g_record_error;
        WRITE('Raising error in process_sal_comp_rates');
       END IF;

  END;

  PROCEDURE process_sal_rate (
    p_effective_date          IN       DATE
  , p_lf_evt_ocrd_date        IN       DATE
  , p_group_pl_id             IN       NUMBER
  , p_group_per_in_ler_id     IN       NUMBER
  , p_person_id               IN       NUMBER
  , p_pl_id                   IN       NUMBER
  , p_oipl_id                 IN       NUMBER
  , p_ws_abr_id               IN       NUMBER
  , p_ws_val                  IN       NUMBER
  , p_currency                IN       VARCHAR2
  , p_nip_acty_ref_perd_cd    IN       VARCHAR2
  , p_business_group_id       IN       NUMBER
  , p_object_version_number   IN       NUMBER
  , p_salary_change_reason    IN       VARCHAR2
  , p_debug_level             IN       VARCHAR2 DEFAULT NULL
  , p_precision               IN       NUMBER
  , p_warning_text            OUT NOCOPY   VARCHAR2
  , p_prev_sal                OUT NOCOPY   VARCHAR2
  , p_pay_proposal_id         OUT NOCOPY   NUMBER
  , p_pay_basis_id            OUT NOCOPY   NUMBER
  , p_warning                 OUT NOCOPY   BOOLEAN
  )
  IS
    asg_rec                   c_prev_pay_proposal%ROWTYPE;
    elm_rec                   c_element_entry%ROWTYPE;
    l_person_info             c_person_info%ROWTYPE;
    l_rate_ovn                c_rate_ovn%ROWTYPE;
    l_pay_proposal_id         NUMBER;
    l_sal_incr                NUMBER;
    l_ele_ent_id              NUMBER;
    l_prev_sal                NUMBER;
    l_object_version_number   NUMBER;
    l_dummy1                  BOOLEAN;
    l_dummy2                  BOOLEAN;
    l_dummy3                  BOOLEAN;
    l_dummy4                  BOOLEAN;
    l_error                   BOOLEAN;
    l_message                 VARCHAR2 (600);
    l_message_name            VARCHAR2 (240);
    l_app_name                VARCHAR2 (240);
    future_pay_proposal_rec   c_future_pay_proposal%ROWTYPE;
    l_element_input_currency  VARCHAR2 (30);
  BEGIN
    g_actn := 'Preparing to call sal admin api ...';
    g_proc := 'process_sal_rate';
    WRITE (g_actn);
    l_error := FALSE;
    p_warning := FALSE;
    p_warning_text := null;

    OPEN c_prev_pay_proposal (p_group_per_in_ler_id, p_effective_date);

    FETCH c_prev_pay_proposal
     INTO asg_rec;

    CLOSE c_prev_pay_proposal;

    OPEN c_person_info (p_group_per_in_ler_id);

    FETCH c_person_info
     INTO l_person_info;

    CLOSE c_person_info;

    IF (asg_rec.pay_basis_id IS NOT NULL)
    THEN
      WRITE ('Found salary basis for the person...');
      write_h ('Pay basis id for the person is ' || asg_rec.pay_basis_id);
      p_pay_basis_id := asg_rec.pay_basis_id;

      OPEN c_element_entry (asg_rec.pay_basis_id, asg_rec.assignment_id, p_effective_date);

      FETCH c_element_entry
       INTO elm_rec;
      l_prev_sal := asg_rec.proposed_salary_n;
       write_s ('Previous salary is ' || l_prev_sal);

      IF c_element_entry%FOUND
      THEN
        l_ele_ent_id := elm_rec.element_entry_id;
        write_h ('Element entry found ' || l_ele_ent_id);
      ELSE
        l_ele_ent_id := NULL;
        write_h ('Element entry not found...');
      END IF;
      CLOSE c_element_entry;


    ELSE
      g_actn :=
            'The salary is not posted as no pay basis is defined.';
      WRITE (g_actn);
        fnd_message.set_name ('BEN', 'BEN_94674_CWB_NO_PAY_BASIS');
        l_message := fnd_message.get_encoded;
        fnd_message.set_encoded(l_message);
        --
        fnd_message.parse_encoded(encoded_message => l_message,
                                  app_short_name  => l_app_name,
                                  message_name    => l_message_name);
        IF g_person_errored = FALSE THEN
            p_warning_text := p_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get;
        END IF;
        l_error := TRUE;
        g_person_errored := TRUE;
    END IF;

      WRITE ('Checking for salary proposal changes...');

write_h(asg_rec.proposed_salary_n);
write_h(l_person_info.base_salary);
write_h(p_precision);

       IF (round(asg_rec.proposed_salary_n,p_precision) <>
           round(l_person_info.base_salary,p_precision))
      THEN
        g_actn :=
          'This employee had a recent update to Base Salary '
          || 'or Pay Basis. The new salary could not be posted.'
          || ' Either delete the recent update and rerun this process,'
          || 'or apply the new salary manually. ';
        WRITE (g_actn);
        write_m('Salary in HR '||asg_rec.proposed_salary_n);
        write_m('Salary in CWB '||l_person_info.base_salary);
        fnd_message.set_name ('BEN', 'BEN_91141_CWB_RECENT_SAL_CHG');
        l_message := fnd_message.get_encoded;
        fnd_message.set_encoded(l_message);
        --
        fnd_message.parse_encoded(encoded_message => l_message,
                                  app_short_name  => l_app_name,
                                  message_name    => l_message_name);
        IF g_person_errored = FALSE THEN
            p_warning_text := p_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get;
        END IF;
        l_error := TRUE;
        g_person_errored := TRUE;
        --fnd_message.raise_error;
      END IF;
      IF(NOT l_error) THEN
        l_prev_sal := asg_rec.proposed_salary_n;
        g_actn := 'Inserting salary proposal for non_comp_salary';
        WRITE (g_actn);
        write_h ('==============Inserting Salary proposal========');
        write_h ('||Parameter              Description            ');
        write_h ('||p_assignment_id -      ' || asg_rec.assignment_id);
        write_h ('||p_business_group_id -  ' || p_business_group_id);
        write_h ('||p_change_date -        ' || p_effective_date);
        write_h ('||p_proposal_reason -    ' || p_salary_change_reason);
        write_h ('||p_proposed_salary increase -  ' || p_ws_val);
        write_h ('================================================');
        write_m ('Time before inserting the salary proposal '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
        BEGIN
              OPEN c_element_input_currency(elm_rec.element_type_id,p_effective_date);
              FETCH c_element_input_currency INTO l_element_input_currency;
              CLOSE c_element_input_currency;

              IF(p_currency is not null
                 AND l_element_input_currency <> p_currency) THEN
	           WRITE('Currency in CWB does not match Input Currency of the Element Type');

                   write_m('Currency for Element '||l_element_input_currency);
                   write_m('Currency in CWB '||p_currency);
               fnd_message.set_name ('BEN', 'BEN_94673_EL_CURR_MISMATCH');
               l_message := fnd_message.get_encoded;
               fnd_message.set_encoded(l_message);
               --
               fnd_message.parse_encoded(encoded_message => l_message,
                                         app_short_name  => l_app_name,
                                         message_name    => l_message_name);
               IF g_person_errored = FALSE THEN
                   p_warning_text := p_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get;
               END IF;
               l_error := TRUE;
               g_person_errored := TRUE;
              END IF;
              hr_maintain_proposal_api.insert_salary_proposal
                                               (p_pay_proposal_id               => l_pay_proposal_id
                                              , p_assignment_id                 => asg_rec.assignment_id
                                              , p_business_group_id             => p_business_group_id
                                              , p_change_date                   => p_effective_date
                                              , p_proposal_reason               => p_salary_change_reason
                                              , p_proposed_salary_n             => (l_prev_sal
                                                                                    + p_ws_val
                                                                                   --l_sal_incr --p_ws_val
                                                                                   )
                                              , p_object_version_number         => l_object_version_number
                                              , p_multiple_components           => 'N'
                                              , p_approved                      => 'Y'
                                              , p_validate                      => FALSE
                                              , p_element_entry_id              => l_ele_ent_id
                                              , p_inv_next_sal_date_warning     => l_dummy1
                                              , p_proposed_salary_warning       => l_dummy2
                                              , p_approved_warning              => l_dummy3
                                              , p_payroll_warning               => l_dummy4
                                               );
          OPEN c_future_pay_proposal (p_group_per_in_ler_id, p_effective_date);

          FETCH c_future_pay_proposal
          INTO future_pay_proposal_rec;
          CLOSE c_future_pay_proposal;

          IF(future_pay_proposal_rec.proposed_salary_n is not null) THEN
           p_warning := TRUE;
           fnd_message.set_name ('BEN', 'BEN_94685_FUTURE_SAL_PROP_WARN');
           l_message := fnd_message.get_encoded;
           fnd_message.set_encoded(l_message);
           --
           fnd_message.parse_encoded(encoded_message => l_message,
                                     app_short_name  => l_app_name,
                                     message_name    => l_message_name);
           IF g_person_errored = FALSE THEN
               p_warning_text := p_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get;
           END IF;
           g_person_errored := TRUE;
           --p_warning_text := p_warning_text||'Future dated salary proposal exists';
          END IF;
          p_prev_sal := l_prev_sal;
          p_pay_proposal_id := l_pay_proposal_id;
          EXCEPTION
           WHEN OTHERS THEN
            p_prev_sal := l_prev_sal;
            p_pay_proposal_id := l_pay_proposal_id;
            WRITE('Exception at insert_salary_proposal : '||SQLERRM);
            l_error := TRUE;        l_message := fnd_message.get_encoded;
            fnd_message.set_encoded(l_message);
            --
            fnd_message.parse_encoded(encoded_message => l_message,
                                      app_short_name  => l_app_name,
                                      message_name    => l_message_name);
            IF g_person_errored = FALSE THEN
                p_warning_text := p_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get;
            END IF;
            g_person_errored := TRUE;
            --p_warning_text := p_warning_text||SQLERRM;
          END;
         write_m ('Time after inserting the salary proposal '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
         write_h ('Pay Proposal_id is ' || l_pay_proposal_id);
         write_h ('p_element_entry_id is ' || l_ele_ent_id);
        g_actn := 'updating pay proposal and element entry into person rates...';
        WRITE (g_actn);

        OPEN c_rate_ovn (p_group_per_in_ler_id, p_pl_id, p_oipl_id);

        FETCH c_rate_ovn
         INTO l_rate_ovn;

        CLOSE c_rate_ovn;
        write_m ('Time before updating person rates '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
        ben_cwb_person_rates_api.update_person_rate
                                        (p_group_per_in_ler_id        => p_group_per_in_ler_id
                                       , p_pl_id                      => p_pl_id
                                       , p_oipl_id                    => p_oipl_id
                                       --, p_element_entry_value_id     => l_ele_ent_id
                                       , p_pay_proposal_id            => l_pay_proposal_id
                                       , p_object_version_number      => l_rate_ovn.object_version_number
                                        );
        write_m ('Time after updating person rates '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
        WRITE ('Pay proposal id and element entry id populated in to the table');
   END IF;

   IF(l_error) THEN
    RAISE ben_batch_utils.g_record_error;
   END IF;

  END;

  PROCEDURE process_non_sal_rate (
    p_effective_date          IN   DATE
  , p_lf_evt_ocrd_date        IN   DATE
  , p_group_pl_id             IN   NUMBER
  , p_group_per_in_ler_id     IN   NUMBER
  , p_person_id               IN   NUMBER
  , p_pl_id                   IN   NUMBER
  , p_oipl_id                 IN   NUMBER
  , p_ws_abr_id               IN   NUMBER
  , p_ws_val                  IN   NUMBER
  , p_nip_acty_ref_perd_cd    IN   VARCHAR2
  , p_business_group_id       IN   NUMBER
  , p_object_version_number   IN   NUMBER
  , p_debug_level             IN   VARCHAR2 DEFAULT NULL
  , p_input_value_id          IN OUT NOCOPY   NUMBER
  , p_element_type_id         IN OUT NOCOPY   NUMBER
  , p_warning_text            IN OUT NOCOPY VARCHAR2
  , p_element_entry_value_id  OUT NOCOPY NUMBER
  , p_eev_screen_entry_value  OUT NOCOPY NUMBER
  )
  IS
    l_ovn                      NUMBER;
    l_rate_ovn                 c_rate_ovn%ROWTYPE;
    l_object_version_number    NUMBER               := p_object_version_number;
    l_error                    BOOLEAN;
    l_emp_num_and_emp_name     c_emp_num_and_emp_name%ROWTYPE;
    l_message                  VARCHAR2 (600);
    l_message_name             VARCHAR2 (240);
    l_app_name                 VARCHAR2 (240);
  BEGIN
    g_actn := 'calling element entry ...';
    g_proc := 'process_non_sal_rate';
    WRITE (g_actn);

    IF(p_warning_text is not null) THEN
     l_error := TRUE;
    ELSE
     l_error := FALSE;
    END IF;

    write_h ('=====================Element Entry ==========================');
    write_h ('||Person Id                ' || p_person_id);
    write_h ('||p_ws_abr_id              ' || p_ws_abr_id);
    write_h ('||p_nip_acty_ref_perd_cd   ' || p_nip_acty_ref_perd_cd);
    write_h ('||p_effective_date         ' || p_effective_date);
    write_h ('||p_ws_val                 ' || p_ws_val);
    write_h ('||p_pl_id                  ' || p_pl_id);
    write_h ('||l_object_version_number  ' || l_object_version_number);
    write_h ('||p_business_group_id      ' || p_business_group_id);
    write_h ('||l_element_entry_value_id ' || p_element_entry_value_id);
    write_h ('||l_eev_screen_entry_value ' || p_eev_screen_entry_value);
    write_h ('||l_element_type_id        ' || p_element_type_id);
    write_h ('||l_input_value_id         ' || p_input_value_id);
    write_h ('================================================================');
    BEGIN
    IF(NOT l_error) THEN
     ben_element_entry.create_enrollment_element
                                           (p_person_id                     => p_person_id
                                          , p_acty_base_rt_id               => p_ws_abr_id
                                          , p_acty_ref_perd                 => p_nip_acty_ref_perd_cd
                                          , p_rt_start_date                 => p_effective_date
                                          , p_rt                            => p_ws_val
                                          , p_pl_id                         => p_pl_id
                                          , p_prv_object_version_number     => l_object_version_number
                                          , p_business_group_id             => p_business_group_id
                                          , p_effective_date                => p_effective_date
                                          , p_element_entry_value_id        => p_element_entry_value_id
                                          , p_eev_screen_entry_value        => p_eev_screen_entry_value
                                          , p_input_value_id                => p_input_value_id
                                          , p_element_type_id               => p_element_type_id
                                           );
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        WRITE('Exception at create_enrollment_element : '||SQLERRM);
         l_error := TRUE;
         l_message := fnd_message.get_encoded;
         fnd_message.set_encoded(l_message);
         --
         fnd_message.parse_encoded(encoded_message => l_message,
                                   app_short_name  => l_app_name,
                                   message_name    => l_message_name);
         IF g_person_errored = FALSE THEN
             p_warning_text := p_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get;
         END IF;
         g_person_errored := TRUE;
    END;
    g_actn := 'updating the element entry id into person rates ...';
    WRITE (g_actn);

    OPEN c_rate_ovn (p_group_per_in_ler_id, p_pl_id, p_oipl_id);

    FETCH c_rate_ovn
     INTO l_rate_ovn;

    CLOSE c_rate_ovn;
    BEGIN
     IF(NOT l_error) THEN
     ben_cwb_person_rates_api.update_person_rate
                                         (p_group_per_in_ler_id        => p_group_per_in_ler_id
                                        , p_pl_id                      => p_pl_id
                                        , p_oipl_id                    => p_oipl_id
                                        , p_element_entry_value_id     => p_element_entry_value_id
                                        , p_object_version_number      => l_rate_ovn.object_version_number
                                         );
     END IF;
    EXCEPTION
      WHEN OTHERS THEN
        WRITE('Exception at update_person_rate : '||SQLERRM);
         l_error := TRUE;
         l_message := fnd_message.get_encoded;
         fnd_message.set_encoded(l_message);
         --
         fnd_message.parse_encoded(encoded_message => l_message,
                                   app_short_name  => l_app_name,
                                   message_name    => l_message_name);
         IF g_person_errored = FALSE THEN
             p_warning_text := p_warning_text||fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get;
         END IF;
         g_person_errored := TRUE;
    END;

     write_h ('l_element_entry_value_id ' || p_element_entry_value_id);
     write_h ('l_eev_screen_entry_value ' || p_eev_screen_entry_value);
     write_h ('l_element_type_id        ' || p_element_type_id);
     write_h ('l_input_value_id         ' || p_input_value_id);

       IF(l_error) THEN
        RAISE ben_batch_utils.g_record_error;
       END IF;
  END;

  PROCEDURE compensation_object (
    p_group_per_in_ler_id    IN              NUMBER
  , p_person_id              IN              NUMBER
  , p_effective_date         IN              DATE
  , p_group_pl_id            IN              NUMBER
  , p_lf_evt_ocrd_date       IN              DATE
  , p_cache_cwb_rpt_person   IN OUT NOCOPY   g_cache_cwb_rpt_person_rec
  , p_cwb_rpt_person_rec     IN OUT NOCOPY   g_cwb_rpt_person_rec
  , p_grant_price_val        IN              NUMBER DEFAULT NULL
  , p_audit_log              IN              VARCHAR2 DEFAULT 'N'
  , p_debug_level            IN              VARCHAR2 DEFAULT NULL
  , p_process_sal_comp       IN              VARCHAR2 DEFAULT 'N'
  , p_use_rate_start_date    IN              VARCHAR2 DEFAULT 'N'
  , p_pay_proposal_id        OUT NOCOPY      NUMBER
  , p_element_entry_value_id OUT NOCOPY      NUMBER
  , p_warning                OUT NOCOPY      BOOLEAN
  )
  IS
    --ER:8369634
    cursor c_post_zero_salary_increase is
      select post_zero_salary_increase
      from ben_cwb_pl_dsgn
      where pl_id = p_group_pl_id
      and lf_evt_ocrd_dt = p_lf_evt_ocrd_date
      and group_oipl_id = -1;

    l_rate_ovn    c_rate_ovn%ROWTYPE;
    l_sal_factors c_sal_factors%ROWTYPE;
    l_precision NUMBER;
    l_amount      NUMBER                         := NULL;
    l_count       NUMBER                         := 0;
    l_warning     VARCHAR2 (2000);
    l_override_start_date DATE;
    l_effective_date DATE;
    l_prev_sal     NUMBER;
    l_pay_proposal_id NUMBER;
    l_error BOOLEAN;
    l_pay_basis_id NUMBER;
    l_element_entry_value_id NUMBER;
    l_input_value_id NUMBER;
    l_element_type_id NUMBER;
    l_eev_screen_entry_value NUMBER;
    l_element_input_value VARCHAR2 (2000);
    l_processing_type VARCHAR2 (30);
    l_currency_cd VARCHAR2 (30);
    l_input_currency VARCHAR2 (30);
    l_message                 VARCHAR2 (600);
    l_message_name            VARCHAR2 (240);
    l_app_name                VARCHAR2 (240);
    asg_rec                   c_prev_pay_proposal%ROWTYPE;
    l_post_zero_salary_increase VARCHAR2(10);
    l_post_zero_salary_no_comp VARCHAR2(10);
  BEGIN
    g_proc := 'compensation_object';

    l_error := FALSE;
    p_warning := FALSE;
    p_pay_proposal_id := null;
    p_element_entry_value_id := null;

    -- ER:8369634
    for l_post_zero_salary_incr in c_post_zero_salary_increase loop
	l_post_zero_salary_increase := l_post_zero_salary_incr.post_zero_salary_increase;
    end loop;
    write('Post Zero Salary increase :' || l_post_zero_salary_increase);
    if(l_post_zero_salary_increase = 'Y') then
	l_post_zero_salary_increase := '999';
    else
	l_post_zero_salary_increase := null;
    end if;
    write_h('l_post_zero_salary_increase:' || l_post_zero_salary_increase);

    IF p_process_sal_comp = 'Y' THEN
      g_actn := 'Processing salary components...';
      WRITE (g_actn);
      BEGIN
      write_h ('Time before calling process_sal_comp_rates '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
      process_sal_comp_rates (p_effective_date           => p_effective_date
                            , p_lf_evt_ocrd_date         => p_lf_evt_ocrd_date
                            , p_group_pl_id              => p_group_pl_id
                            , p_person_id                => p_person_id
                            , p_cache_cwb_rpt_person     => p_cache_cwb_rpt_person
                            , p_cwb_rpt_person_rec       => p_cwb_rpt_person_rec
                            , p_group_per_in_ler_id      => p_group_per_in_ler_id
                            , p_debug_level              => p_debug_level
                            , p_pay_proposal_id          => p_pay_proposal_id
                            , p_pay_basis_id             => l_pay_basis_id
                            , p_warning                  => p_warning
                            , p_use_rate_start_date      => p_use_rate_start_date
			    , p_post_zero_salary_increase => l_post_zero_salary_increase
                             );

      write_h ('Time after calling process_sal_comp_rates  '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
      EXCEPTION
       WHEN OTHERS THEN
        WRITE('Error in process_sal_comp_rates : '||SQLERRM);
         l_error := TRUE;
      END;
    END IF;

    g_actn := 'Processing non component rates...';
    write_h ('Time before processing non component rates '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
    WRITE (g_actn);
    l_count := p_cache_cwb_rpt_person.COUNT;

    for rt_rec in c_non_sal_comp_rates (p_group_per_in_ler_id, p_effective_date) loop

        p_cwb_rpt_person_rec.adjusted_amount       := null;
        p_cwb_rpt_person_rec.amount                := null;
        p_cwb_rpt_person_rec.amount_posted         := null;
        p_cwb_rpt_person_rec.assignment_changed    := null;
        p_cwb_rpt_person_rec.assignment_id         := null;
        p_cwb_rpt_person_rec.base_sal_freq         := null;
        p_cwb_rpt_person_rec.base_salary           := null;
        p_cwb_rpt_person_rec.base_salary_currency  := null;
        p_cwb_rpt_person_rec.benefit_action_id     := null;
        p_cwb_rpt_person_rec.business_group_id     := null;
        p_cwb_rpt_person_rec.business_group_name   := null;
        p_cwb_rpt_person_rec.conversion_factor     := null;
        p_cwb_rpt_person_rec.country_code          := null;
        p_cwb_rpt_person_rec.currency              := null;
        p_cwb_rpt_person_rec.eev_screen_entry_value:= null;
        p_cwb_rpt_person_rec.effective_date        := null;
        p_cwb_rpt_person_rec.element_entry_id      := null;
        p_cwb_rpt_person_rec.element_entry_value_id:= null;
        p_cwb_rpt_person_rec.element_input_value   := null;
        p_cwb_rpt_person_rec.element_type_id       := null;
        p_cwb_rpt_person_rec.elig_salary           := null;
        p_cwb_rpt_person_rec.eligibility           := null;
        p_cwb_rpt_person_rec.elmnt_processing_type := null;
        p_cwb_rpt_person_rec.emp_number            := null;
        p_cwb_rpt_person_rec.error_or_warning_text := null;
        p_cwb_rpt_person_rec.exchange_rate         := null;
        p_cwb_rpt_person_rec.fte_factor            := null;
        p_cwb_rpt_person_rec.full_name             := null;
        p_cwb_rpt_person_rec.group_oipl_id         := null;
        p_cwb_rpt_person_rec.group_per_in_ler_id   := null;
        p_cwb_rpt_person_rec.group_pl_id           := null;
        p_cwb_rpt_person_rec.input_value_id        := null;
        p_cwb_rpt_person_rec.lf_evt_closed         := null;
        p_cwb_rpt_person_rec.lf_evt_ocrd_date      := null;
        p_cwb_rpt_person_rec.manager_name          := null;
        p_cwb_rpt_person_rec.new_sal               := null;
        p_cwb_rpt_person_rec.oipl_id               := null;
        p_cwb_rpt_person_rec.opt_name              := null;
        p_cwb_rpt_person_rec.pay_ann_factor        := null;
        p_cwb_rpt_person_rec.pay_basis_id          := null;
        p_cwb_rpt_person_rec.pay_proposal_id       := null;
        p_cwb_rpt_person_rec.percent_of_elig_sal   := null;
        p_cwb_rpt_person_rec.performance_rating    := null;
        p_cwb_rpt_person_rec.person_id             := null;
        p_cwb_rpt_person_rec.pl_ann_factor         := null;
        p_cwb_rpt_person_rec.pl_id                 := null;
        p_cwb_rpt_person_rec.pl_name               := null;
        p_cwb_rpt_person_rec.prev_eev_screen_entry_value := null;
        p_cwb_rpt_person_rec.prev_sal              := null;
        p_cwb_rpt_person_rec.rating_date           := null;
        p_cwb_rpt_person_rec.reason                := null;
        p_cwb_rpt_person_rec.status                := null;
        p_cwb_rpt_person_rec.units                 := null;
        p_cwb_rpt_person_rec.uom_precision         := null;
        p_cwb_rpt_person_rec.ws_mgr_id             := null;
        p_cwb_rpt_person_rec.ws_sub_acty_typ_cd    := null;
        l_prev_sal               := null;
        l_pay_proposal_id        := null;
        l_pay_basis_id           := null;
        l_element_entry_value_id := null;
        l_input_value_id         := null;
        l_element_type_id        := null;
        l_eev_screen_entry_value := null;
        l_element_input_value    := 'No Element specified';
        l_processing_type        := null;
        l_currency_cd            := null;
        l_input_currency         := null;

      write_h ('The compensation type is ' || rt_rec.ws_sub_acty_typ_cd);
      l_amount := rt_rec.ws_val;

-- anniversary date change
    if rt_rec.component_reason is null then
     if(p_use_rate_start_date = 'Y' and rt_rec.ws_abr_id is not null) then
      l_override_start_date := get_ws_rate_start_dt(
         p_group_per_in_ler_id => p_group_per_in_ler_id,
         p_group_pl_id         => rt_rec.group_pl_id,
         p_pl_id               => rt_rec.pl_id,
         p_oipl_id             => rt_rec.oipl_id,
         p_group_oipl_id       => rt_rec.group_oipl_id,
         p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_date);
      if(l_override_start_date is null) then
           l_error := TRUE;
           fnd_message.set_name ('BEN', 'BEN_94906_CWB_NO_RATE_STRT_DT');
           l_message := fnd_message.get_encoded;
           fnd_message.set_encoded(l_message);
           fnd_message.parse_encoded(encoded_message => l_message,
                                     app_short_name  => l_app_name,
                                     message_name    => l_message_name);
           IF g_person_errored = FALSE THEN
               l_warning := substr(fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get,1,2000);
           END IF;
           g_person_errored := TRUE;
           l_effective_date := null;
      else
         write_h('Found ws rate start date: '||l_override_start_date);
	 l_effective_date := l_override_start_date;
      end if;
     else
      l_override_start_date :=   get_override_start_date(
	                             p_lf_evt_ocrd_date => p_lf_evt_ocrd_date
                                ,p_group_pl_id    => rt_rec.group_pl_id
                                ,p_pl_id          => rt_rec.pl_id
                                ,p_group_oipl_id  => rt_rec.group_oipl_id
                                ,p_oipl_id        => rt_rec.oipl_id
                                ,p_effective_date => p_effective_date
                                );
	IF(l_override_start_date is not null) THEN
	 l_effective_date := l_override_start_date;
	ELSE
	 l_effective_date := p_effective_date;
	END IF;
	end if;

      WRITE('Posting date : ' || l_effective_date);      p_cwb_rpt_person_rec.person_rate_id := rt_rec.person_rate_id;
      p_cwb_rpt_person_rec.pl_id := rt_rec.pl_id;
      p_cwb_rpt_person_rec.oipl_id := rt_rec.oipl_id;
      p_cwb_rpt_person_rec.group_pl_id := rt_rec.group_pl_id;
      p_cwb_rpt_person_rec.group_oipl_id := rt_rec.group_oipl_id;
      p_cwb_rpt_person_rec.full_name := rt_rec.full_name;
      p_cwb_rpt_person_rec.emp_number := rt_rec.employee_number;
      p_cwb_rpt_person_rec.business_group_id := rt_rec.business_group_id;
      p_cwb_rpt_person_rec.units := rt_rec.units;
      p_cwb_rpt_person_rec.ws_mgr_id := rt_rec.ws_mgr_id;

      p_cwb_rpt_person_rec.base_salary_currency := rt_rec.base_salary_currency;
      p_cwb_rpt_person_rec.base_salary := rt_rec.base_salary;
      p_cwb_rpt_person_rec.elig_salary := round(rt_rec.elig_sal_val,rt_rec.uom_precision);
      p_cwb_rpt_person_rec.amount := round(nvl(rt_rec.ws_val,0),rt_rec.uom_precision);

      IF(p_cwb_rpt_person_rec.elig_salary is null OR p_cwb_rpt_person_rec.elig_salary = 0 ) THEN
       p_cwb_rpt_person_rec.percent_of_elig_sal := 0;
      ELSE
      p_cwb_rpt_person_rec.percent_of_elig_sal :=
       round((p_cwb_rpt_person_rec.amount/p_cwb_rpt_person_rec.elig_salary)*100,rt_rec.uom_precision);
      END IF;

      p_cwb_rpt_person_rec.base_sal_freq := rt_rec.base_salary_frequency;
      p_cwb_rpt_person_rec.pay_ann_factor := rt_rec.pay_annulization_factor;
      p_cwb_rpt_person_rec.pl_ann_factor := rt_rec.pl_annulization_factor;
      p_cwb_rpt_person_rec.exchange_rate := rt_rec.xchg_rate;
      p_cwb_rpt_person_rec.effective_date := l_effective_date;
      p_cwb_rpt_person_rec.reason := rt_rec.component_reason;
      p_cwb_rpt_person_rec.eligibility := rt_rec.elig_flag;
      p_cwb_rpt_person_rec.fte_factor := rt_rec.fte_factor;

      IF(rt_rec.ws_sub_acty_typ_cd='ICM7') THEN
        p_cwb_rpt_person_rec.conversion_factor :=
         round(rt_rec.pl_annulization_factor/rt_rec.pay_annulization_factor,
          6);
      ELSE
       p_cwb_rpt_person_rec.conversion_factor := 1;
      BEGIN
       WRITE_H(rt_rec.ws_abr_id||' '||l_effective_date||' '||rt_rec.assignment_id||' '||rt_rec.business_group_id);
       WRITE_H(rt_rec.pl_id||' '||p_group_per_in_ler_id);
       if(rt_rec.ws_abr_id is not null and l_effective_date is not null) then
        WRITE_H('Calling element determintaion with fol data');
        ben_manage_cwb_life_events.exec_element_det_rl
         (p_acty_base_rt_id => rt_rec.ws_abr_id,
          p_effective_date  => l_effective_date,
          p_assignment_id => rt_rec.assignment_id,
          p_organization_id => null,
          p_business_group_id => rt_rec.business_group_id,
          p_pl_id => rt_rec.pl_id,
          p_ler_id => p_group_per_in_ler_id,
          p_element_type_id => l_element_type_id,
          p_input_value_id  => l_input_value_id,
	      p_currency_cd => l_currency_cd);
       WRITE('Rule called and returned input_value_id: '||l_input_value_id||' and element_type_id: '||l_element_type_id);
       end if;
      EXCEPTION
      WHEN others THEN
       WRITE('No Element Rule Found ');
       --WRITE(SQLERRM);
       fnd_message.CLEAR();
      END;
       if(l_element_type_id is null and l_input_value_id is null) then
        get_plan_abr_info(
          p_lf_evt_ocrd_date    => p_lf_evt_ocrd_date
        , p_pl_id               => rt_rec.pl_id
        , p_oipl_id             => rt_rec.oipl_id
        , p_element_type_id     => l_element_type_id
        , p_input_value_id      => l_input_value_id
        );
        end if;
        p_cwb_rpt_person_rec.input_value_id := l_input_value_id;
        p_cwb_rpt_person_rec.element_type_id := l_element_type_id;
        --p_cwb_rpt_person_rec.eev_screen_entry_value := l_eev_screen_entry_value;
        l_currency_cd := rt_rec.currency;

      OPEN c_element_input_value_name(l_input_value_id,l_element_type_id,l_effective_date);
      FETCH c_element_input_value_name INTO l_element_input_value,l_processing_type,l_input_currency;
      CLOSE c_element_input_value_name;
      p_cwb_rpt_person_rec.element_input_value := SUBSTR(l_element_input_value,1,80);		--sg
      p_cwb_rpt_person_rec.elmnt_processing_type := l_processing_type;
     END IF;

     p_cwb_rpt_person_rec.adjusted_amount := p_cwb_rpt_person_rec.amount;
     p_cwb_rpt_person_rec.assignment_id := rt_rec.assignment_id;
     p_cwb_rpt_person_rec.uom_precision := rt_rec.uom_precision;
     p_cwb_rpt_person_rec.ws_sub_acty_typ_cd := rt_rec.ws_sub_acty_typ_cd;
     p_cwb_rpt_person_rec.currency := rt_rec.currency;
     p_cwb_rpt_person_rec.lf_evt_ocrd_date := p_lf_evt_ocrd_date;
     p_cwb_rpt_person_rec.group_per_in_ler_id := p_group_per_in_ler_id;

     p_cwb_rpt_person_rec.pay_proposal_id := null;
     p_cwb_rpt_person_rec.pay_basis_id := null;

	-- ER:8369634
     if(rt_rec.ws_sub_acty_typ_cd = 'ICM7' AND l_post_zero_salary_increase IS NOT NULL) then
	l_post_zero_salary_no_comp := 'Y';
     end if;

     IF (( (rt_rec.ws_val IS NOT NULL AND
          rt_rec.ws_val <> 0) OR (l_post_zero_salary_no_comp = 'Y')) AND rt_rec.elig_flag = 'Y') THEN
        WRITE ('Valid worksheet amount found for processing ...');
	write_h('Worksheet amount : ' || rt_rec.ws_val);
        --p_cwb_rpt_person_rec.amount := l_amount;

        IF rt_rec.ws_sub_acty_typ_cd = 'ICM7' THEN
          g_actn := 'Processing salary without components...';
          WRITE (g_actn);

        OPEN c_sal_factors(p_group_pl_id,p_lf_evt_ocrd_date,p_group_per_in_ler_id);
        FETCH c_sal_factors INTO l_sal_factors;
        CLOSE c_sal_factors;
        OPEN c_input_value_precision(rt_rec.assignment_id,l_effective_date);
        FETCH c_input_value_precision INTO l_precision;
        CLOSE c_input_value_precision;
        IF(l_precision IS NULL) THEN
            l_precision := l_sal_factors.uom_precision;
        END IF;
        l_amount := round(rt_rec.ws_val * l_sal_factors.pl_annulization_factor/l_sal_factors.pay_annulization_factor,l_precision);

          if p_process_sal_comp = 'N' then
            g_actn := 'Processing salary ...';
            WRITE (g_actn);

             write_h('l_sal_factors.pl_annulization_factor is '||l_sal_factors.pl_annulization_factor);
             write_h('l_sal_factors.pay_annulization_factor is '||l_sal_factors.pay_annulization_factor);
             write_h('l_precision is '||l_precision);
             write_s ('The amount ' || rt_rec.ws_val || ' Converted amount ' || l_amount);

            write_m ('Time before calling process_sal_rate '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
            BEGIN
             process_sal_rate (p_effective_date            => l_effective_date
                            , p_lf_evt_ocrd_date           => p_lf_evt_ocrd_date
                            , p_group_pl_id                => p_group_pl_id
                            , p_person_id                  => p_person_id
                            , p_pl_id                      => rt_rec.pl_id
                            , p_oipl_id                    => rt_rec.oipl_id
                            , p_ws_abr_id                  => rt_rec.ws_abr_id
                            , p_ws_val                     => l_amount
                            , p_currency                   => rt_rec.currency
                            , p_salary_change_reason       => l_sal_factors.salary_change_reason
                            , p_nip_acty_ref_perd_cd       => rt_rec.acty_ref_perd_cd
                            , p_business_group_id          => rt_rec.business_group_id
                            , p_object_version_number      => rt_rec.object_version_number
                            , p_group_per_in_ler_id        => p_group_per_in_ler_id
                            , p_debug_level                => p_debug_level
                            , p_precision                  => l_precision
                            , p_warning_text               => l_warning
                            , p_prev_sal                   => l_prev_sal
                            , p_pay_proposal_id            => l_pay_proposal_id
                            , p_pay_basis_id               => l_pay_basis_id
                            , p_warning                    => p_warning);
            EXCEPTION
             WHEN OTHERS THEN
              WRITE('Error in process_sal_rate : '||SQLERRM);
              l_error := TRUE;
            END;

            write_m ('Time after calling process_sal_rate '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

            p_cwb_rpt_person_rec.adjusted_amount := round(nvl(l_amount,0),l_precision);
            p_cwb_rpt_person_rec.prev_sal := round(nvl(l_prev_sal,0),l_precision);
            p_cwb_rpt_person_rec.pay_proposal_id := l_pay_proposal_id;
            p_cwb_rpt_person_rec.pay_basis_id := l_pay_basis_id;
            p_cwb_rpt_person_rec.reason := rt_rec.salary_change_reason;
          else
            p_cwb_rpt_person_rec.pay_proposal_id := p_pay_proposal_id;
            p_cwb_rpt_person_rec.reason := rt_rec.salary_change_reason;
            p_cwb_rpt_person_rec.pay_basis_id := l_pay_basis_id;

          end if;
        ELSE
          g_actn := 'Processing non salary rates...';

          WRITE('Element input currency : '||l_input_currency);
          WRITE('Rate currency : '||rt_rec.currency);
	  WRITE('Non Monetary UOM: '||rt_rec.units);

          IF(rt_rec.units is null) THEN
           IF(l_input_currency<>rt_rec.currency) THEN
	       WRITE('Currency in CWB does not match Input Currency of the Element Type');
           fnd_message.set_name ('BEN', 'BEN_94673_EL_CURR_MISMATCH');
           l_error := TRUE;

           l_message := fnd_message.get_encoded;
           fnd_message.set_encoded(l_message);
           --
           fnd_message.parse_encoded(encoded_message => l_message,
                                     app_short_name  => l_app_name,
                                     message_name    => l_message_name);
           IF g_person_errored = FALSE THEN
               l_warning := substr(fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get,1,2000);
           END IF;
           g_person_errored := TRUE;

           END IF;
	  END IF;

          WRITE (g_actn);

          l_amount := rt_rec.ws_val;
          p_cwb_rpt_person_rec.units := rt_rec.units;

          write_m ('Time before calling process_non_sal_rate '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
          BEGIN
           OPEN c_posted_element(rt_rec.assignment_id
                                ,l_element_type_id
                                ,l_input_value_id
                                ,l_effective_date);
           FETCH c_posted_element INTO p_cwb_rpt_person_rec.prev_eev_screen_entry_value;
           CLOSE c_posted_element;
	   --WRITE('Old screen value: '||p_cwb_rpt_person_rec.prev_eev_screen_entry_value);
           process_non_sal_rate (p_effective_date            => l_effective_date
                               , p_lf_evt_ocrd_date          => p_lf_evt_ocrd_date
                               , p_group_pl_id               => p_group_pl_id
                               , p_person_id                 => p_person_id
                               , p_pl_id                     => rt_rec.pl_id
                               , p_oipl_id                   => rt_rec.oipl_id
                               , p_ws_abr_id                 => rt_rec.ws_abr_id
                               , p_ws_val                    => l_amount
                               , p_nip_acty_ref_perd_cd      => rt_rec.acty_ref_perd_cd
                               , p_business_group_id         => rt_rec.business_group_id
                               , p_object_version_number     => rt_rec.object_version_number
                               , p_group_per_in_ler_id       => p_group_per_in_ler_id
                               , p_debug_level               => p_debug_level
                               , p_warning_text              => l_warning
                               , p_element_entry_value_id    => l_element_entry_value_id
                               , p_input_value_id            => l_input_value_id
                               , p_element_type_id           => l_element_type_id
                               , p_eev_screen_entry_value    => l_eev_screen_entry_value);
          EXCEPTION
           WHEN OTHERS THEN
            WRITE('Error in process_non_sal_rate :'||SQLERRM);
            l_error := TRUE;
          END;
         p_cwb_rpt_person_rec.adjusted_amount := round(nvl(l_amount,0),rt_rec.uom_precision);
         p_cwb_rpt_person_rec.element_entry_value_id := l_element_entry_value_id;
         p_element_entry_value_id := l_element_entry_value_id;
         p_cwb_rpt_person_rec.eev_screen_entry_value := l_eev_screen_entry_value;
         write_m ('Time after calling process_non_sal_rate '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
        END IF; -- non-salary.
      END IF;
      IF ((nvl(l_post_zero_salary_increase,rt_rec.ws_val) IS NULL OR
          nvl(l_post_zero_salary_increase,rt_rec.ws_val) = 0) AND rt_rec.elig_flag = 'Y'
          AND rt_rec.ws_sub_acty_typ_cd = 'ICM7') THEN
        WRITE ('No worksheet amount found. Obtaining other reqd data for reporting...');
        OPEN c_prev_pay_proposal (p_group_per_in_ler_id, l_effective_date);
        FETCH c_prev_pay_proposal
        INTO asg_rec;
        CLOSE c_prev_pay_proposal;
        p_cwb_rpt_person_rec.pay_basis_id := asg_rec.pay_basis_id;
        p_cwb_rpt_person_rec.prev_sal := nvl(asg_rec.proposed_salary_n,0);
        p_cwb_rpt_person_rec.reason := rt_rec.salary_change_reason;
	--write_h('Prev Sal : '||p_cwb_rpt_person_rec.prev_sal);
      END IF; -- ws_amt is not null

      l_count := l_count + 1;
      p_cache_cwb_rpt_person (l_count).person_rate_id := p_cwb_rpt_person_rec.person_rate_id;
      p_cache_cwb_rpt_person (l_count).pl_id := p_cwb_rpt_person_rec.pl_id;
      p_cache_cwb_rpt_person (l_count).oipl_id := p_cwb_rpt_person_rec.oipl_id;
      p_cache_cwb_rpt_person (l_count).group_pl_id := p_cwb_rpt_person_rec.group_pl_id;
      p_cache_cwb_rpt_person (l_count).group_oipl_id := p_cwb_rpt_person_rec.group_oipl_id;
      p_cache_cwb_rpt_person (l_count).full_name := p_cwb_rpt_person_rec.full_name;
      p_cache_cwb_rpt_person (l_count).emp_number := p_cwb_rpt_person_rec.emp_number;
      p_cache_cwb_rpt_person (l_count).business_group_id := p_cwb_rpt_person_rec.business_group_id;
      p_cache_cwb_rpt_person (l_count).ws_mgr_id := p_cwb_rpt_person_rec.ws_mgr_id;
      p_cache_cwb_rpt_person (l_count).units := p_cwb_rpt_person_rec.units;
      p_cache_cwb_rpt_person (l_count).assignment_id := p_cwb_rpt_person_rec.assignment_id;

          p_cache_cwb_rpt_person (l_count).base_salary_currency := p_cwb_rpt_person_rec.base_salary_currency;
          p_cache_cwb_rpt_person (l_count).elig_salary := p_cwb_rpt_person_rec.elig_salary;
          p_cache_cwb_rpt_person (l_count).amount := p_cwb_rpt_person_rec.amount;
          p_cache_cwb_rpt_person (l_count).percent_of_elig_sal := p_cwb_rpt_person_rec.percent_of_elig_sal;
          p_cache_cwb_rpt_person (l_count).conversion_factor := p_cwb_rpt_person_rec.conversion_factor;
          p_cache_cwb_rpt_person (l_count).exchange_rate := p_cwb_rpt_person_rec.exchange_rate;
          p_cache_cwb_rpt_person (l_count).effective_date := p_cwb_rpt_person_rec.effective_date;
          p_cache_cwb_rpt_person (l_count).eligibility := p_cwb_rpt_person_rec.eligibility;

          p_cache_cwb_rpt_person (l_count).adjusted_amount := p_cwb_rpt_person_rec.adjusted_amount;
          p_cache_cwb_rpt_person (l_count).uom_precision := p_cwb_rpt_person_rec.uom_precision;
          p_cache_cwb_rpt_person (l_count).currency := p_cwb_rpt_person_rec.currency;

          p_cache_cwb_rpt_person (l_count).ws_sub_acty_typ_cd :=p_cwb_rpt_person_rec.ws_sub_acty_typ_cd;

      p_cache_cwb_rpt_person (l_count).group_per_in_ler_id := p_group_per_in_ler_id;
      p_cache_cwb_rpt_person (l_count).lf_evt_ocrd_date := p_lf_evt_ocrd_date;

          IF rt_rec.ws_sub_acty_typ_cd = 'ICM7' THEN
           p_cache_cwb_rpt_person (l_count).prev_sal := p_cwb_rpt_person_rec.prev_sal;
           p_cache_cwb_rpt_person (l_count).base_salary := p_cwb_rpt_person_rec.base_salary;
           p_cache_cwb_rpt_person (l_count).base_sal_freq := p_cwb_rpt_person_rec.base_sal_freq;
           p_cache_cwb_rpt_person (l_count).pay_ann_factor := p_cwb_rpt_person_rec.pay_ann_factor;
           p_cache_cwb_rpt_person (l_count).pl_ann_factor := p_cwb_rpt_person_rec.pl_ann_factor;
           p_cache_cwb_rpt_person (l_count).reason := p_cwb_rpt_person_rec.reason;
           p_cache_cwb_rpt_person (l_count).fte_factor := p_cwb_rpt_person_rec.fte_factor;
           p_cache_cwb_rpt_person (l_count).pay_proposal_id := p_cwb_rpt_person_rec.pay_proposal_id;
           p_cache_cwb_rpt_person (l_count).pay_basis_id := p_cwb_rpt_person_rec.pay_basis_id;
          ELSE
           p_cache_cwb_rpt_person (l_count).prev_sal := null;
           p_cache_cwb_rpt_person (l_count).base_salary := null;
           p_cache_cwb_rpt_person (l_count).base_sal_freq := null;
           p_cache_cwb_rpt_person (l_count).pay_ann_factor := null;
           p_cache_cwb_rpt_person (l_count).pl_ann_factor := null;
           p_cache_cwb_rpt_person (l_count).reason := null;
           p_cache_cwb_rpt_person (l_count).fte_factor := null;
           p_cache_cwb_rpt_person (l_count).pay_proposal_id := null;
           p_cache_cwb_rpt_person (l_count).pay_basis_id := null;
           p_cache_cwb_rpt_person (l_count).element_entry_value_id := p_cwb_rpt_person_rec.element_entry_value_id;
           p_cache_cwb_rpt_person (l_count).input_value_id := p_cwb_rpt_person_rec.input_value_id;
           p_cache_cwb_rpt_person (l_count).element_type_id := p_cwb_rpt_person_rec.element_type_id;
           p_cache_cwb_rpt_person (l_count).eev_screen_entry_value := p_cwb_rpt_person_rec.eev_screen_entry_value;
           p_cache_cwb_rpt_person (l_count).element_input_value := p_cwb_rpt_person_rec.element_input_value;
           p_cache_cwb_rpt_person (l_count).elmnt_processing_type := p_cwb_rpt_person_rec.elmnt_processing_type;
           p_cache_cwb_rpt_person (l_count).prev_eev_screen_entry_value := p_cwb_rpt_person_rec.prev_eev_screen_entry_value;
          END IF;


      IF (l_warning IS NOT NULL) THEN
        WRITE('Writing error message in cache : '||l_warning);
        p_cache_cwb_rpt_person (l_count).error_or_warning_text := substr(l_warning,1,2000);
        p_cwb_rpt_person_rec.error_or_warning_text := substr(l_warning,1,2000);
      END IF;
      IF((rt_rec.elig_flag = 'Y')AND(NOT l_error)) THEN
       g_actn := 'updating posting date...';
       WRITE (g_actn);

       OPEN c_rate_ovn (p_group_per_in_ler_id, rt_rec.pl_id, rt_rec.oipl_id);
       FETCH c_rate_ovn INTO l_rate_ovn;
       CLOSE c_rate_ovn;

       write_h ('=====================posting date =========================');
       write_h ('||p_group_per_in_ler_id    ' || p_group_per_in_ler_id);
       write_h ('||p_pl_id                  ' || rt_rec.pl_id);
       write_h ('||p_oipl_id                ' || rt_rec.oipl_id);
       write_h ('||p_comp_posting_date      ' || l_effective_date);
       write_h ('||p_object_version_number  ' || rt_rec.object_version_number);
       write_h ('================================================================');
       ben_cwb_person_rates_api.update_person_rate
                                      (p_group_per_in_ler_id       => p_group_per_in_ler_id
                                     , p_pl_id                     => rt_rec.pl_id
                                     , p_oipl_id                   => rt_rec.oipl_id
                                     , p_comp_posting_date         => l_effective_date
                                     , p_object_version_number     => l_rate_ovn.object_version_number);
      END IF;
     end if; -- component_reason is null
    END LOOP;
    write_m ('Time after processing non component rates '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

       IF(l_error) THEN
        WRITE('Raising exception at compensation_object');
        RAISE ben_batch_utils.g_record_error;
       END IF;
  END;

--
-- ============================================================================
--                   << Procedure: process_person >>
-- ============================================================================
--
  PROCEDURE process_person (
    p_validate                IN              VARCHAR2 DEFAULT 'N'
  , p_person_id               IN              NUMBER DEFAULT NULL
  , p_person_action_id        IN              NUMBER DEFAULT NULL
  , p_object_version_number   IN OUT NOCOPY   NUMBER
  , p_business_group_id       IN              NUMBER
  , p_lf_evt_ocrd_date        IN              DATE
  , p_plan_id                 IN              NUMBER
  , p_group_per_in_ler_id     IN              NUMBER
  , p_grant_price_val         IN              NUMBER DEFAULT NULL
  , p_effective_date          IN              DATE
  , p_audit_log               IN              VARCHAR2 DEFAULT 'N'
  , p_debug_level             IN              VARCHAR2 DEFAULT NULL
  , p_process_sal_comp        IN              VARCHAR2 DEFAULT 'N'
  , p_employees_in_bg         IN              NUMBER
  , p_is_self_service         IN              VARCHAR2 DEFAULT 'N'
  , p_is_placeholder          IN              VARCHAR2
  , p_use_rate_start_date     IN              VARCHAR2
  )
  IS
    l_comp_error                 BOOLEAN                            := FALSE;
    l_perf_error                 BOOLEAN                            := FALSE;
    l_promo_error                BOOLEAN                            := FALSE;
    l_actual_termination_date    DATE;
    l_perf_revw_strt_dt          DATE;
    l_perf_revw_new_strt_dt      DATE;
    l_asg_updt_eff_date          DATE;
    l_interview_typ_cd           VARCHAR2 (80);
    l_ranking_info               c_ranking_info%ROWTYPE;
    l_ranking_info_date          c_ranking_info_date%ROWTYPE;
    l_per_in_ler_id              NUMBER;
    l_ovn                        NUMBER;
    l_assignment_extra_info_id   NUMBER;
    l_cache_cwb_rpt_person       g_cache_cwb_rpt_person_rec;
    l_bg_and_mgr_name            c_bg_and_mgr_name%ROWTYPE;
    l_amount                     NUMBER                             := NULL;
    l_perf_txn                   ben_cwb_asg_update.g_txn%ROWTYPE;
    l_asg_txn                    ben_cwb_asg_update.g_txn%ROWTYPE;
    l_rate_ovn                   c_rate_ovn%ROWTYPE;
    l_grp_ovn                    c_grp_ovn%ROWTYPE;
    l_emp_num_and_emp_name       c_emp_num_and_emp_name%ROWTYPE;
    l_rating_status              VARCHAR2 (200);
    l_promotion_status           VARCHAR2 (200);
    l_promo_person_rec           g_cwb_rpt_person_rec;
    l_perf_person_rec            g_cwb_rpt_person_rec;
    l_pay_proposal_id            NUMBER;
    tot_com_amt_rec              c_tot_chg_amt_for_proposal%ROWTYPE;
    l_error                      BOOLEAN;
    l_collected_message          VARCHAR2 (2000);
    l_element_entry_value_id     NUMBER;
    l_posted_perf_rating         VARCHAR2 (200);
    l_posted_promotions          c_posted_promotions%ROWTYPE;
    l_prior_assignment_dtls      c_prior_assignment%ROWTYPE;
    l_proposed_promotions        c_proposed_promotions%ROWTYPE;
    l_message                    VARCHAR2 (600);
    l_message_name               VARCHAR2 (240);
    l_app_name                   VARCHAR2 (240);
    l_amount_posted              VARCHAR2(60);
    l_warning                    BOOLEAN;
    l_overrides_perf_prom        c_overrides_perf_prom%ROWTYPE;
    l_is_eligible                BOOLEAN;
    l_dummy                      c_check_eligibility%ROWTYPE;
    l_counter                    NUMBER;
  BEGIN
    g_proc := 'process_person';
    SAVEPOINT cwb_post_process_person;

    l_error := FALSE;
    g_person_errored := FALSE;

        open c_check_eligibility(p_group_per_in_ler_id);
        fetch c_check_eligibility into l_dummy;
        If c_check_eligibility%found then
            l_is_eligible := TRUE;
        else
            l_is_eligible := FALSE;
        End if;
        Close c_check_eligibility;

    IF(l_is_eligible = FALSE) THEN
     WRITE('Ineligible Person');
    END IF;

    WRITE ('initializing global names for this thread... ');
    init (p_plan_id, p_lf_evt_ocrd_date);

    OPEN c_bg_and_mgr_name (p_group_per_in_ler_id, p_effective_date);

    FETCH c_bg_and_mgr_name
     INTO l_bg_and_mgr_name;

    CLOSE c_bg_and_mgr_name;

    OPEN c_emp_num_and_emp_name(p_group_per_in_ler_id);
       FETCH c_emp_num_and_emp_name into l_emp_num_and_emp_name;
    CLOSE c_emp_num_and_emp_name;

    if(p_is_placeholder='N') then

    OPEN c_performance_promotion (p_plan_id, p_lf_evt_ocrd_date);

    FETCH c_performance_promotion
     INTO l_perf_revw_strt_dt
        , l_perf_revw_new_strt_dt
        , l_asg_updt_eff_date
        , l_interview_typ_cd;

    CLOSE c_performance_promotion;

    IF((l_asg_updt_eff_date IS NOT NULL)or(l_perf_revw_strt_dt IS NOT NULL)) THEN
        OPEN c_overrides_perf_prom(p_group_per_in_ler_id, p_lf_evt_ocrd_date);
        FETCH c_overrides_perf_prom INTO l_overrides_perf_prom;
        CLOSE c_overrides_perf_prom;
    END IF;

    write_h ('=====================Processing Person ==========================');
    write_h ('||Person Id          ' || p_person_id);
    write_h ('||Per_in_ler_id      ' || p_group_per_in_ler_id);
    write_h ('||Person Action id   ' || p_person_action_id);
    write_h ('||Plan id            ' || p_plan_id);
    write_h ('||Employees in bg    ' || p_employees_in_bg);
    write_h ('||Employee bg        ' || l_emp_num_and_emp_name.business_group_id);
    write_h ('================================================================');

    g_actn := 'Process compensation for the person...';
    WRITE (g_actn);

   -- Processesing only for eligible employess.
   -- Bug: 8323386

    IF l_is_eligible = TRUE then

    BEGIN
      SAVEPOINT process_compensation_object;
      write_m ('Time before processing compensation object '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
      compensation_object (p_group_per_in_ler_id      => p_group_per_in_ler_id
                         , p_person_id                => p_person_id
                         , p_effective_date           => p_effective_date
                         , p_group_pl_id              => p_plan_id
                         , p_lf_evt_ocrd_date         => p_lf_evt_ocrd_date
                         , p_cache_cwb_rpt_person     => l_cache_cwb_rpt_person
                         , p_cwb_rpt_person_rec       => g_cwb_rpt_person
                         , p_grant_price_val          => p_grant_price_val
                         , p_audit_log                => p_audit_log
                         , p_debug_level              => p_debug_level
                         , p_process_sal_comp         => p_process_sal_comp
                         , p_pay_proposal_id          => l_pay_proposal_id
                         , p_element_entry_value_id   => l_element_entry_value_id
                         , p_warning                  => l_warning
                         , p_use_rate_start_date      => p_use_rate_start_date
                          );
      write_m ('Time after processing compensation object '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
      l_comp_error := FALSE;
    EXCEPTION
      WHEN OTHERS
      THEN
        WRITE('Error in compensation_object : '||SQLERRM);
        ROLLBACK TO process_compensation_object;
        l_comp_error := TRUE;
        g_person_errored := TRUE;
    END;

    END IF;

    if l_perf_revw_strt_dt is not null then
      OPEN ben_cwb_asg_update.g_txn (l_emp_num_and_emp_name.assignment_id,
                                     ben_cwb_asg_update.g_ws_perf_rec_type||to_char(l_perf_revw_strt_dt, 'yyyy/mm/dd')
                                         ||l_interview_typ_cd);

      FETCH ben_cwb_asg_update.g_txn INTO l_perf_txn;
      CLOSE ben_cwb_asg_update.g_txn;
    end if;

    if l_asg_updt_eff_date is not null then
      OPEN ben_cwb_asg_update.g_txn (l_emp_num_and_emp_name.assignment_id,
                                     ben_cwb_asg_update.g_ws_asg_rec_type||to_char(l_asg_updt_eff_date, 'yyyy/mm/dd'));

      FETCH ben_cwb_asg_update.g_txn INTO l_asg_txn;
      CLOSE ben_cwb_asg_update.g_txn;
    end if;

    IF l_asg_txn.assignment_id is not null or l_perf_txn.assignment_id IS NOT NULL THEN
      --
      OPEN c_actual_termination_date (p_person_id);
      FETCH c_actual_termination_date INTO l_actual_termination_date;
      CLOSE c_actual_termination_date;

      IF l_actual_termination_date IS NOT NULL THEN
        IF (((l_asg_txn.assignment_id is not null)  and (l_asg_updt_eff_date >= l_actual_termination_date)) OR
	    ((l_perf_txn.assignment_id is not null) and (l_perf_revw_strt_dt >= l_actual_termination_date)) ) THEN
          WRITE ('The person was terminated on ' || l_actual_termination_date
                     || ' promotion or performance was not applied' );
          fnd_message.set_name ('BEN', 'BEN_93365_PERSON_TERMINATED');
          l_error := TRUE;
          --fnd_message.raise_error;
        END IF;
      END IF;
    END IF;

        l_perf_person_rec.full_name := l_emp_num_and_emp_name.full_name;
        l_perf_person_rec.person_id := p_person_id;
        l_perf_person_rec.emp_number := l_emp_num_and_emp_name.employee_number;
        l_perf_person_rec.business_group_name := l_bg_and_mgr_name.name;
        l_perf_person_rec.manager_name := l_bg_and_mgr_name.full_name;
        l_perf_person_rec.pl_name := g_group_plan_name;
        l_perf_person_rec.business_group_id := l_bg_and_mgr_name.business_group_id;
        l_perf_person_rec.country_code := l_emp_num_and_emp_name.legislation_code;
        l_perf_person_rec.group_per_in_ler_id := p_group_per_in_ler_id;
-- if override is null and mode is SS then do not process OR if PUI then usual
    IF (((p_is_self_service = 'Y' and l_overrides_perf_prom.attribute2 is not null)
       OR (p_is_self_service = 'N')) and
       (l_perf_txn.attribute1 is not null and l_perf_txn.attribute3 is not null)
       and (l_is_eligible = TRUE)
       ) THEN

      BEGIN
        SAVEPOINT process_rating;
        g_actn := 'found assignment id in the transaction table processing rating...';
        WRITE (g_actn);
        write_m ('Time before processing rating '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

        if(p_is_self_service = 'Y') then
         WRITE('override performance review date = '||l_overrides_perf_prom.attribute2);
         l_perf_revw_strt_dt := to_date(l_overrides_perf_prom.attribute2,'yyyy/mm/dd');
        else
         WRITE('performance review date = '||l_perf_revw_strt_dt);
         l_perf_revw_strt_dt := l_perf_revw_strt_dt;
        end if;

        l_perf_person_rec.rating_date := l_perf_revw_strt_dt;
        l_perf_person_rec.rating_type := l_perf_txn.attribute2;
        l_perf_person_rec.performance_rating := substrb(hr_general.decode_lookup('PERFORMANCE_RATING',l_perf_txn.attribute3),1,30);

        if(l_error) then
         fnd_message.raise_error;
        end if;

         ben_cwb_asg_update.process_rating (p_person_id             => p_person_id
                                          , p_txn_rec               => l_perf_txn
                                          , p_business_group_id     => l_emp_num_and_emp_name.business_group_id
                                          , p_audit_log             => p_audit_log
                                          , p_process_status        => l_rating_status
                                          , p_group_per_in_ler_id   => p_group_per_in_ler_id
                                          , p_effective_date        => l_perf_revw_strt_dt
                                           );

        write_m ('Time after processing rating '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

        IF l_rating_status = 'CWB_PERF_SUS' THEN
          g_actn := 'Person ' || p_person_id || ' processed successfully for Performance Rating';
          WRITE (g_actn);
        END IF;

        l_perf_person_rec.status := 'SC';

        WRITE('Performance rating is '||l_perf_person_rec.performance_rating);
        l_perf_error := FALSE;

      EXCEPTION
        WHEN OTHERS THEN
          WRITE('Error at Performance rating '||SQLERRM);
          l_perf_person_rec.status := 'E';
          l_message := fnd_message.get_encoded;
          fnd_message.set_encoded(l_message);
           --
          fnd_message.parse_encoded(encoded_message => l_message,
                                    app_short_name  => l_app_name,
                                    message_name    => l_message_name);
          l_perf_person_rec.error_or_warning_text := substr(fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get,1,2000);
          g_person_errored := TRUE;
          WRITE(l_perf_person_rec.error_or_warning_text);
          ROLLBACK TO process_rating;
	      IF(benutils.get_message_name = 'BEN_93371_RATING_EXST_FOR_DATE') THEN
	       --l_perf_person_rec.error_or_warning_text := fnd_message.get;
           write_m ('Time after processing rating '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
	       WRITE('Failed Performance rating is '||l_perf_person_rec.performance_rating);
           l_rating_status := 'CWB_PERF_SUS';
	      ELSE
           l_perf_error := TRUE;
           l_error := TRUE;
	      END IF;
          g_actn := 'Person ' || p_person_id || ' failed for Performance Rating';
          WRITE (g_actn);
      END;
    ELSE
     l_perf_person_rec.rating_date := hr_general.end_of_time;
     l_perf_person_rec.status := 'SC';
    END IF;
      --

          l_promo_person_rec.full_name := l_emp_num_and_emp_name.full_name;
          l_promo_person_rec.person_id := p_person_id;
          l_promo_person_rec.emp_number := l_emp_num_and_emp_name.employee_number;
          l_promo_person_rec.business_group_name := l_bg_and_mgr_name.name;
          l_promo_person_rec.manager_name := l_bg_and_mgr_name.full_name;
          l_promo_person_rec.pl_name := g_group_plan_name;
          l_promo_person_rec.business_group_id := l_bg_and_mgr_name.business_group_id;
          l_promo_person_rec.country_code := l_emp_num_and_emp_name.legislation_code;
          l_promo_person_rec.group_per_in_ler_id := p_group_per_in_ler_id;
          l_promo_person_rec.assignment_id := l_emp_num_and_emp_name.assignment_id;
-- if override is null and mode is SS then do not process OR if PUI then usual
    IF (((p_is_self_service = 'Y' and l_overrides_perf_prom.attribute2 is not null)
        OR (p_is_self_service = 'N')) and
       (l_asg_txn.attribute1 is not NULL)
       and (l_is_eligible=TRUE)) THEN

      BEGIN
        SAVEPOINT process_promotions;
        g_actn := 'processing promotions ...';
        WRITE (g_actn);
        write_m ('Time before processing promotions '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

        if(p_is_self_service = 'Y') then
         WRITE('override promotion date = '||l_overrides_perf_prom.attribute1);
         l_asg_updt_eff_date := to_date(l_overrides_perf_prom.attribute1,'yyyy/mm/dd');
        else
         WRITE('promotion date = '||l_asg_updt_eff_date);
         l_asg_updt_eff_date := l_asg_updt_eff_date;
        end if;

        OPEN c_prior_assignment(p_group_per_in_ler_id);
        FETCH c_prior_assignment into l_prior_assignment_dtls;
        CLOSE c_prior_assignment;
          l_promo_person_rec.assignment_changed := 'Y';
          l_promo_person_rec.prior_job := l_prior_assignment_dtls.job;
          l_promo_person_rec.prior_position := l_prior_assignment_dtls.position;
          l_promo_person_rec.prior_grade := l_prior_assignment_dtls.grade;
          l_promo_person_rec.prior_group := l_prior_assignment_dtls.group_name;

          OPEN c_proposed_promotions(to_number(l_emp_num_and_emp_name.assignment_id),
                              ben_cwb_asg_update.g_ws_asg_rec_type
                              ||l_asg_txn.attribute1);
          FETCH c_proposed_promotions into l_proposed_promotions;
          CLOSE c_proposed_promotions;
          WRITE(ben_cwb_asg_update.g_ws_asg_rec_type||l_asg_txn.attribute1);

          l_promo_person_rec.proposed_job := l_proposed_promotions.job;
          l_promo_person_rec.proposed_position := l_proposed_promotions.position;
          l_promo_person_rec.proposed_grade := l_proposed_promotions.grade;
          l_promo_person_rec.proposed_group := l_proposed_promotions.group_name;

          l_promo_person_rec.prior_flex1 := l_prior_assignment_dtls.ass_attribute1;
          l_promo_person_rec.proposed_flex1 := l_asg_txn.attribute11;
          l_promo_person_rec.prior_flex2 := l_prior_assignment_dtls.ass_attribute2;
          l_promo_person_rec.proposed_flex2 := l_asg_txn.attribute12;
          l_promo_person_rec.prior_flex3 := l_prior_assignment_dtls.ass_attribute3;
          l_promo_person_rec.proposed_flex3 := l_asg_txn.attribute13;
          l_promo_person_rec.prior_flex4 := l_prior_assignment_dtls.ass_attribute4;
          l_promo_person_rec.proposed_flex4 := l_asg_txn.attribute14;
          l_promo_person_rec.prior_flex5 := l_prior_assignment_dtls.ass_attribute5;
          l_promo_person_rec.proposed_flex5 := l_asg_txn.attribute15;
          l_promo_person_rec.prior_flex6 := l_prior_assignment_dtls.ass_attribute6;
          l_promo_person_rec.proposed_flex6 := l_asg_txn.attribute16;
          l_promo_person_rec.prior_flex7 := l_prior_assignment_dtls.ass_attribute7;
          l_promo_person_rec.proposed_flex7 := l_asg_txn.attribute17;
          l_promo_person_rec.prior_flex8 := l_prior_assignment_dtls.ass_attribute8;
          l_promo_person_rec.proposed_flex8 := l_asg_txn.attribute18;
          l_promo_person_rec.prior_flex9 := l_prior_assignment_dtls.ass_attribute9;
          l_promo_person_rec.proposed_flex9 := l_asg_txn.attribute19;
          l_promo_person_rec.prior_flex10 := l_prior_assignment_dtls.ass_attribute10;
          l_promo_person_rec.proposed_flex10 := l_asg_txn.attribute20;
          l_promo_person_rec.prior_flex11 := l_prior_assignment_dtls.ass_attribute11;
          l_promo_person_rec.proposed_flex11 := l_asg_txn.attribute21;
          l_promo_person_rec.prior_flex12 := l_prior_assignment_dtls.ass_attribute12;
          l_promo_person_rec.proposed_flex12 := l_asg_txn.attribute22;
          l_promo_person_rec.prior_flex13 := l_prior_assignment_dtls.ass_attribute13;
          l_promo_person_rec.proposed_flex13 := l_asg_txn.attribute23;
          l_promo_person_rec.prior_flex14 := l_prior_assignment_dtls.ass_attribute14;
          l_promo_person_rec.proposed_flex14 := l_asg_txn.attribute24;
          l_promo_person_rec.prior_flex15 := l_prior_assignment_dtls.ass_attribute15;
          l_promo_person_rec.proposed_flex15 := l_asg_txn.attribute25;
          l_promo_person_rec.prior_flex16 := l_prior_assignment_dtls.ass_attribute16;
          l_promo_person_rec.proposed_flex16 := l_asg_txn.attribute26;
          l_promo_person_rec.prior_flex17 := l_prior_assignment_dtls.ass_attribute17;
          l_promo_person_rec.proposed_flex17 := l_asg_txn.attribute27;
          l_promo_person_rec.prior_flex18 := l_prior_assignment_dtls.ass_attribute18;
          l_promo_person_rec.proposed_flex18 := l_asg_txn.attribute28;
          l_promo_person_rec.prior_flex19 := l_prior_assignment_dtls.ass_attribute19;
          l_promo_person_rec.proposed_flex19 := l_asg_txn.attribute29;
          l_promo_person_rec.prior_flex20 := l_prior_assignment_dtls.ass_attribute20;
          l_promo_person_rec.proposed_flex20 := l_asg_txn.attribute30;
          l_promo_person_rec.prior_flex21 := l_prior_assignment_dtls.ass_attribute21;
          l_promo_person_rec.proposed_flex21 := l_asg_txn.attribute31;
          l_promo_person_rec.prior_flex22 := l_prior_assignment_dtls.ass_attribute22;
          l_promo_person_rec.proposed_flex22 := l_asg_txn.attribute32;
          l_promo_person_rec.prior_flex23 := l_prior_assignment_dtls.ass_attribute23;
          l_promo_person_rec.proposed_flex23 := l_asg_txn.attribute33;
          l_promo_person_rec.prior_flex24 := l_prior_assignment_dtls.ass_attribute24;
          l_promo_person_rec.proposed_flex24 := l_asg_txn.attribute34;
          l_promo_person_rec.prior_flex25 := l_prior_assignment_dtls.ass_attribute25;
          l_promo_person_rec.proposed_flex25 := l_asg_txn.attribute35;
          l_promo_person_rec.prior_flex26 := l_prior_assignment_dtls.ass_attribute26;
          l_promo_person_rec.proposed_flex26 := l_asg_txn.attribute36;
          l_promo_person_rec.prior_flex27 := l_prior_assignment_dtls.ass_attribute27;
          l_promo_person_rec.proposed_flex27 := l_asg_txn.attribute37;
          l_promo_person_rec.prior_flex28 := l_prior_assignment_dtls.ass_attribute28;
          l_promo_person_rec.proposed_flex28 := l_asg_txn.attribute38;
          l_promo_person_rec.prior_flex29 := l_prior_assignment_dtls.ass_attribute29;
          l_promo_person_rec.proposed_flex29 := l_asg_txn.attribute39;
          l_promo_person_rec.prior_flex30 := l_prior_assignment_dtls.ass_attribute30;
          l_promo_person_rec.proposed_flex30 := l_asg_txn.attribute40;
          l_promo_person_rec.asgn_change_reason := l_asg_txn.attribute3;
          l_promo_person_rec.effective_date := l_asg_updt_eff_date;

        if(l_error) then
         fnd_message.raise_error;
        end if;

        ben_cwb_asg_update.process_promotions (p_person_id             => p_person_id
                                             , p_asg_txn_rec           => l_asg_txn
                                             , p_business_group_id     => l_emp_num_and_emp_name.business_group_id
                                             , p_audit_log             => p_audit_log
                                             , p_process_status        => l_promotion_status
                                             , p_group_per_in_ler_id   => p_group_per_in_ler_id
                                             , p_effective_date        => l_asg_updt_eff_date
                                              );
        IF l_promotion_status = 'CWB_PROM_SUS' THEN
          g_actn := 'Person ' || p_person_id || ' processed successfully for assignment changes';
          WRITE (g_actn);
          l_promo_person_rec.status := 'SC';
          l_promo_error := FALSE;
        ELSE
          l_promo_person_rec.status := 'SC';
        END IF;
        write_m ('Time after processing promotions '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
      EXCEPTION
        WHEN OTHERS THEN
          WRITE('Error at processing promotions'||SQLERRM);
          l_promo_person_rec.status := 'E';
          l_message := fnd_message.get_encoded;
          fnd_message.set_encoded(l_message);
          --
          fnd_message.parse_encoded(encoded_message => l_message,
                                    app_short_name  => l_app_name,
                                    message_name    => l_message_name);
          l_promo_person_rec.error_or_warning_text := substr(fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get,1,2000);
          WRITE(l_promo_person_rec.error_or_warning_text);
          ROLLBACK TO process_promotions;
          l_promo_error := TRUE;
          l_error := TRUE;
          g_person_errored := TRUE;
          g_actn:='Person ' || p_person_id || ' failed for assignment changes';
          WRITE (g_actn);
      END;
    ELSE
          l_promo_person_rec.assignment_changed := 'N';
          l_promo_person_rec.status := 'SC';
    END IF;
    --

    BEGIN
    IF (   l_comp_error
        OR l_perf_error
        OR l_promo_error)
    THEN
      l_error := TRUE;
      g_person_errored := TRUE;
      RAISE ben_batch_utils.g_record_error;
    END IF;

    process_life_event(p_person_id
                     , p_lf_evt_ocrd_date
                     , p_plan_id
                     , p_group_per_in_ler_id
                     , p_effective_date
                     , p_employees_in_bg);

    EXCEPTION
     WHEN OTHERS THEN
      WRITE('Life Event not closed due to error');
      g_cache_cwb_sum_person (p_person_id).lf_evt_closed := 'N';
    END;

    BEGIN
    SAVEPOINT process_ranking;
    IF l_perf_revw_strt_dt is not null THEN

    write_m ('Time before processing the rank '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
    FOR l_ranking_info IN c_ranking_info (p_group_per_in_ler_id)
    LOOP
      WRITE ('Updating ranking for this person...');

      IF c_ranking_info_date%ISOPEN THEN
         CLOSE c_ranking_info_date;
      END IF;

      OPEN c_ranking_info_date(p_group_per_in_ler_id,
                               l_perf_revw_strt_dt ,
                               l_ranking_info.aei_information2);
      FETCH c_ranking_info_date INTO l_ranking_info_date;
      IF c_ranking_info_date%NOTFOUND  THEN
         write ('Found a rank which needs to be updated...');
         hr_assignment_extra_info_api.create_assignment_extra_info
          ( p_validate                 => false
            ,p_assignment_id            => l_ranking_info.assignment_id
            ,p_information_type         => 'CWBRANK'
            ,p_aei_information_category => 'CWBRANK'
            ,p_aei_information1         => l_ranking_info.aei_information1
            ,p_aei_information2         => l_ranking_info.aei_information2
            ,p_aei_information3         => p_group_per_in_ler_id
            ,p_aei_information4         => l_ranking_info.aei_information4
            ,p_aei_information5         => fnd_date.date_to_canonical(l_perf_revw_strt_dt)
            ,p_aei_information6         => p_plan_id
            ,p_assignment_extra_info_id => l_assignment_extra_info_id
            ,p_object_version_number    => l_ovn );
     ELSE
       WRITE ('Found a rank which need not be updated...');
     END IF;
      CLOSE c_ranking_info_date;



    END LOOP;

    write_m ('Time after processing the rank '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
          WRITE('Error at Ranking '||SQLERRM);
          l_perf_person_rec.status := 'E';
          l_message := fnd_message.get_encoded;
          fnd_message.set_encoded(l_message);
           --
          fnd_message.parse_encoded(encoded_message => l_message,
                                    app_short_name  => l_app_name,
                                    message_name    => l_message_name);
          l_perf_person_rec.error_or_warning_text := substr(fnd_message.get_number(l_app_name,l_message_name)||' '||fnd_message.get,1,2000);
          WRITE(l_perf_person_rec.error_or_warning_text);
          ROLLBACK TO process_ranking;
          l_perf_error := TRUE;
          l_error := TRUE;
          g_person_errored := TRUE;
          g_actn := 'Person ' || p_person_id || ' failed for Ranking';
          WRITE (g_actn);
    END;

    WRITE ('creating cache for reporting...');

    FOR v_counter IN 1 .. l_cache_cwb_rpt_person.COUNT
    LOOP
    IF(trim(l_collected_message) is null) THEN
      l_collected_message := substr(l_collected_message||
       l_cache_cwb_rpt_person (v_counter).error_or_warning_text,1,2000);
    END IF;
    /* -- not stacking up messages
    if(instr(l_collected_message,l_cache_cwb_rpt_person (v_counter).error_or_warning_text)=0 or
       instr(l_collected_message,l_cache_cwb_rpt_person (v_counter).error_or_warning_text)is null) then

      l_collected_message := substr(l_collected_message||
       l_cache_cwb_rpt_person (v_counter).error_or_warning_text,1,2000);
    end if;
    */
    END LOOP;

    --IF l_rating_status = 'CWB_PERF_SUS' THEN
      if (l_perf_person_rec.rating_date is not null) then
       if((NOT l_error)and(p_validate <> 'Y')and
          (l_perf_txn.attribute1 is not null and l_perf_txn.attribute3 is not null)
       ) then
        open c_posted_rating(l_perf_person_rec.person_id,
                             l_perf_person_rec.rating_date);
        fetch c_posted_rating into l_posted_perf_rating;
        close c_posted_rating;

        l_perf_person_rec.posted_rating :=
         substrb(hr_general.decode_lookup('PERFORMANCE_RATING',l_posted_perf_rating),1,30);

       end if;
       IF(l_error) THEN
        l_perf_person_rec.status := 'E';
       END IF;
       g_cache_cwb_rpt_person (g_cache_cwb_rpt_person.COUNT + 1) := l_perf_person_rec;
       IF(trim(l_collected_message) is null) THEN
       l_collected_message := substr(l_collected_message||
        l_perf_person_rec.error_or_warning_text,1,2000);
       END IF;
       --l_collected_message||' '||l_perf_person_rec.error_or_warning_text;
    END IF;

    --IF l_promotion_status = 'CWB_PROM_SUS' THEN
    IF (l_promo_person_rec.assignment_id is not null) then
     if((NOT l_error)and(p_validate <> 'Y')and(l_asg_txn.attribute1 is not null)) then
        open c_posted_promotions(l_promo_person_rec.assignment_id,
                                 l_promo_person_rec.effective_date);
        fetch c_posted_promotions into l_posted_promotions;
        close c_posted_promotions;

        l_promo_person_rec.posted_job := l_posted_promotions.job;
        l_promo_person_rec.posted_position := l_posted_promotions.position;
        l_promo_person_rec.posted_grade := l_posted_promotions.grade;
        l_promo_person_rec.posted_group := l_posted_promotions.group_name;
        l_promo_person_rec.posted_flex1 := l_posted_promotions.ass_attribute1;
        l_promo_person_rec.posted_flex2 := l_posted_promotions.ass_attribute2;
        l_promo_person_rec.posted_flex3 := l_posted_promotions.ass_attribute3;
        l_promo_person_rec.posted_flex4 := l_posted_promotions.ass_attribute4;
        l_promo_person_rec.posted_flex5 := l_posted_promotions.ass_attribute5;
        l_promo_person_rec.posted_flex6 := l_posted_promotions.ass_attribute6;
        l_promo_person_rec.posted_flex7 := l_posted_promotions.ass_attribute7;
        l_promo_person_rec.posted_flex8 := l_posted_promotions.ass_attribute8;
        l_promo_person_rec.posted_flex9 := l_posted_promotions.ass_attribute9;
        l_promo_person_rec.posted_flex10 := l_posted_promotions.ass_attribute10;
        l_promo_person_rec.posted_flex11 := l_posted_promotions.ass_attribute11;
        l_promo_person_rec.posted_flex12 := l_posted_promotions.ass_attribute12;
        l_promo_person_rec.posted_flex13 := l_posted_promotions.ass_attribute13;
        l_promo_person_rec.posted_flex14 := l_posted_promotions.ass_attribute14;
        l_promo_person_rec.posted_flex15 := l_posted_promotions.ass_attribute15;
        l_promo_person_rec.posted_flex16 := l_posted_promotions.ass_attribute16;
        l_promo_person_rec.posted_flex17 := l_posted_promotions.ass_attribute17;
        l_promo_person_rec.posted_flex18 := l_posted_promotions.ass_attribute18;
        l_promo_person_rec.posted_flex19 := l_posted_promotions.ass_attribute19;
        l_promo_person_rec.posted_flex20 := l_posted_promotions.ass_attribute20;
        l_promo_person_rec.posted_flex21 := l_posted_promotions.ass_attribute21;
        l_promo_person_rec.posted_flex22 := l_posted_promotions.ass_attribute22;
        l_promo_person_rec.posted_flex23 := l_posted_promotions.ass_attribute23;
        l_promo_person_rec.posted_flex24 := l_posted_promotions.ass_attribute24;
        l_promo_person_rec.posted_flex25 := l_posted_promotions.ass_attribute25;
        l_promo_person_rec.posted_flex26 := l_posted_promotions.ass_attribute26;
        l_promo_person_rec.posted_flex27 := l_posted_promotions.ass_attribute27;
        l_promo_person_rec.posted_flex28 := l_posted_promotions.ass_attribute28;
        l_promo_person_rec.posted_flex29 := l_posted_promotions.ass_attribute29;
        l_promo_person_rec.posted_flex30 := l_posted_promotions.ass_attribute30;

     end if;
       WRITE('Writing Promotion Record into Cache...');
       IF(l_error) THEN
        l_promo_person_rec.status := 'E';
       END IF;
       g_cache_cwb_rpt_person (g_cache_cwb_rpt_person.COUNT + 1) := l_promo_person_rec;
       IF(trim(l_collected_message) is null) THEN
       l_collected_message := substr(l_collected_message||
        l_promo_person_rec.error_or_warning_text,1,2000);
        END IF;
       --l_collected_message||' '||l_promo_person_rec.error_or_warning_text;
       WRITE(l_promo_person_rec.full_name);
       WRITE(l_promo_person_rec.assignment_changed);
    END IF;

    FOR v_counter IN 1 .. l_cache_cwb_rpt_person.COUNT
    LOOP
      l_amount_posted := null;
      --WRITE('Counter: '||v_counter);
      l_cache_cwb_rpt_person (v_counter).manager_name := l_bg_and_mgr_name.full_name;
      l_cache_cwb_rpt_person (v_counter).business_group_name := l_bg_and_mgr_name.NAME;
      l_cache_cwb_rpt_person (v_counter).person_id := p_person_id;
      l_cache_cwb_rpt_person (v_counter).country_code := l_emp_num_and_emp_name.legislation_code;
      if((NOT l_error)and(p_validate <> 'Y')
       and(l_cache_cwb_rpt_person (v_counter).element_entry_value_id is not null)) then
        WRITE('Element_entry_value_id: '||l_cache_cwb_rpt_person (v_counter).element_entry_value_id);
        OPEN c_posted_element(l_cache_cwb_rpt_person (v_counter).assignment_id
                             ,l_cache_cwb_rpt_person (v_counter).element_type_id
                             ,l_cache_cwb_rpt_person (v_counter).input_value_id
                             ,l_cache_cwb_rpt_person (v_counter).effective_date);
        --FETCH c_posted_element INTO l_cache_cwb_rpt_person (v_counter).amount_posted;
        FETCH c_posted_element INTO l_amount_posted;
        CLOSE c_posted_element;
        l_cache_cwb_rpt_person (v_counter).amount_posted:= fnd_number.canonical_to_number(l_amount_posted);
        WRITE('Amount posted: '||l_cache_cwb_rpt_person (v_counter).amount_posted);
      end if;
      if((NOT l_error)and(p_validate <> 'Y')and
       (l_cache_cwb_rpt_person (v_counter).pay_proposal_id is not null)) then
        WRITE('Pay_proposal_id: '||l_cache_cwb_rpt_person (v_counter).pay_proposal_id);
        OPEN c_posted_salary(l_cache_cwb_rpt_person (v_counter).pay_proposal_id);
        FETCH c_posted_salary INTO l_cache_cwb_rpt_person (v_counter).new_sal;
        CLOSE c_posted_salary;
        l_cache_cwb_rpt_person (v_counter).amount_posted
         := l_cache_cwb_rpt_person (v_counter).new_sal - l_cache_cwb_rpt_person (v_counter).prev_sal;
        WRITE('New Sal: '||l_cache_cwb_rpt_person (v_counter).new_sal);
      end if;

      if(NOT l_error) THEN
       l_cache_cwb_rpt_person (v_counter).lf_evt_closed := 'Y';
      else
       l_cache_cwb_rpt_person (v_counter).lf_evt_closed := 'N';
       l_cache_cwb_rpt_person (v_counter).effective_date := NULL;
      end if;

      l_warning := FALSE; --warning not supported completely yet

      IF(l_warning) THEN
       l_cache_cwb_rpt_person (v_counter).status := 'W';
      ELSE
      IF(NOT l_error) THEN
       IF (l_cache_cwb_rpt_person (v_counter).amount IS NULL)
        THEN
          l_cache_cwb_rpt_person (v_counter).status := 'SC';
       ELSE
        IF (l_amount IS NULL)
         THEN
           l_amount := 0;
         END IF;
        l_amount := l_amount + l_cache_cwb_rpt_person (v_counter).amount;
        l_cache_cwb_rpt_person (v_counter).status := 'SC';
      END IF;

      ELSE
          l_cache_cwb_rpt_person (v_counter).status := 'E';
      END IF;
      END IF;


      IF l_cache_cwb_rpt_person (v_counter).pl_id = l_cache_cwb_rpt_person (v_counter).group_pl_id
      THEN
        l_cache_cwb_rpt_person (v_counter).pl_name := g_group_plan_name;
      ELSE
        l_cache_cwb_rpt_person (v_counter).pl_name :=
                                    g_cache_actual_plans (l_cache_cwb_rpt_person (v_counter).pl_id);
      END IF;

      IF l_cache_cwb_rpt_person (v_counter).oipl_id <> -1
      THEN
        IF l_cache_cwb_rpt_person (v_counter).oipl_id =
                                                   l_cache_cwb_rpt_person (v_counter).group_oipl_id
        THEN
          l_cache_cwb_rpt_person (v_counter).opt_name :=
                                 g_cache_group_options (l_cache_cwb_rpt_person (v_counter).oipl_id);
        ELSE
          l_cache_cwb_rpt_person (v_counter).opt_name :=
                                g_cache_actual_options (l_cache_cwb_rpt_person (v_counter).oipl_id);
        END IF;
      ELSE
       l_cache_cwb_rpt_person (v_counter).error_or_warning_text := substr(l_collected_message,1,2000);
      END IF;

      g_cache_cwb_rpt_person (g_cache_cwb_rpt_person.COUNT + 1) :=
                                                                  l_cache_cwb_rpt_person (v_counter);
    END LOOP;
    WRITE('populating g_cache_cwb_sum_person');
    g_cache_cwb_sum_person (p_person_id).person_id := p_person_id;
    g_cache_cwb_sum_person (p_person_id).bg_name := l_bg_and_mgr_name.NAME;
    g_cache_cwb_sum_person (p_person_id).bg_id := p_business_group_id;
    g_cache_cwb_sum_person (p_person_id).country_code := l_emp_num_and_emp_name.legislation_code;

    l_warning := FALSE; --warning not supported completely yet

   IF(l_warning) THEN
    g_cache_cwb_sum_person (p_person_id).status := 'W';
   ELSE
   IF(NOT l_error) THEN
    IF (l_amount IS NULL)
    THEN
      g_cache_cwb_sum_person (p_person_id).status := 'SC';
    ELSE
      g_cache_cwb_sum_person (p_person_id).status := 'SC';
    END IF;
   ELSE
    g_cache_cwb_sum_person (p_person_id).status := 'E';
    RAISE ben_batch_utils.g_record_error;
   END IF;
   END IF;
else
    BEGIN
    write_h ('=====================Processing Person ==========================');
    write_h ('||Person Id          ' || p_person_id);
    write_h ('||Per_in_ler_id      ' || p_group_per_in_ler_id);
    write_h ('||Person Action id   ' || p_person_action_id);
    write_h ('||Plan id            ' || p_plan_id);
    write_h ('=================================================================');
    l_counter := g_cache_cwb_rpt_person.COUNT;
    l_counter := l_counter + 1;

    g_cache_cwb_rpt_person(l_counter).group_pl_id:= p_plan_id;
    g_cache_cwb_rpt_person(l_counter).person_id:= p_person_id;
    g_cache_cwb_rpt_person(l_counter).assignment_id := l_emp_num_and_emp_name.assignment_id;
    g_cache_cwb_rpt_person(l_counter).emp_number := l_emp_num_and_emp_name.employee_number;
    g_cache_cwb_rpt_person(l_counter).group_per_in_ler_id:= p_group_per_in_ler_id;
    g_cache_cwb_rpt_person(l_counter).full_name:= l_emp_num_and_emp_name.full_name;
    g_cache_cwb_rpt_person(l_counter).business_group_name:= l_bg_and_mgr_name.name;
    g_cache_cwb_rpt_person(l_counter).business_group_id:= l_bg_and_mgr_name.business_group_id;
    g_cache_cwb_rpt_person(l_counter).manager_name:= l_bg_and_mgr_name.full_name;
    g_cache_cwb_rpt_person(l_counter).pl_name:= g_group_plan_name;
    g_cache_cwb_rpt_person(l_counter).country_code:= l_emp_num_and_emp_name.legislation_code;
    g_cache_cwb_rpt_person(l_counter).lf_evt_ocrd_date:= p_lf_evt_ocrd_date;
    g_cache_cwb_rpt_person(l_counter).group_per_in_ler_id := p_group_per_in_ler_id;
    --g_cache_cwb_rpt_person(l_counter).oipl_id := -1;
    --g_cache_cwb_rpt_person(l_counter).eligibility := 'N';

    process_life_event(p_person_id
                     , p_lf_evt_ocrd_date
                     , p_plan_id
                     , p_group_per_in_ler_id
                     , p_effective_date
                     , p_employees_in_bg);
    WRITE('Placeholder Life Event closed.');
    g_cache_cwb_sum_person (p_person_id).lf_evt_closed := 'Y';
    g_cache_cwb_rpt_person(l_counter).status:= 'SC';
    g_cache_cwb_rpt_person(l_counter).lf_evt_closed:= 'Y';

    EXCEPTION
     WHEN OTHERS THEN
      WRITE('Life Event not closed due to error');
      g_cache_cwb_sum_person (p_person_id).lf_evt_closed := 'N';
      g_cache_cwb_rpt_person(l_counter).status:= 'E';
      g_cache_cwb_rpt_person(l_counter).lf_evt_closed:= 'N';
    END;
end if;
    IF (p_validate = 'Y')
    THEN
      g_actn := 'Running in rollback mode, person rolled back...';
      WRITE (g_actn);
      ROLLBACK TO cwb_post_process_person;
    END IF;

    IF p_person_action_id IS NOT NULL
    THEN
      g_actn := 'Updating person actions as processed...';
      WRITE (g_actn);
      write_h ('Time before updating the person actions '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
      write_h ('=====================Updating Person Actions==========================');
      write_h ('||Person Action id        ' || p_person_action_id);
      write_h ('||p_object_version_number ' || p_object_version_number);
      write_h ('||p_effective_date        ' || p_effective_date);
      write_h ('================================================================');
      ben_person_actions_api.update_person_actions
                                               (p_person_action_id          => p_person_action_id
                                              , p_action_status_cd          => 'P'
                                              , p_object_version_number     => p_object_version_number
                                              , p_effective_date            => p_effective_date
                                               );
      WRITE ('Time after updating the person actions '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
    END IF;

    g_actn := 'Finished processing the person...';
    Write ('----------------------------------------------------');
    WRITE (g_actn);
  EXCEPTION
    WHEN OTHERS
    THEN
      WRITE('Error at Process Person');
      ROLLBACK TO cwb_post_process_person;

      IF ((g_is_force_on_per = 'Y')and(p_validate <> 'Y')) THEN
       write_h('Forcing life event to close');
       process_life_event(
                       p_person_id
                     , p_lf_evt_ocrd_date
                     , p_plan_id
                     , p_group_per_in_ler_id
                     , p_effective_date
                     , p_employees_in_bg);
      END IF;

      g_persons_errored := g_persons_errored + 1;
      ben_batch_utils.rpt_error (p_proc => g_proc, p_last_actn => g_actn, p_rpt_flag => TRUE);

      IF p_person_action_id IS NOT NULL
      THEN
        ben_person_actions_api.update_person_actions
                                               (p_person_action_id          => p_person_action_id
                                              , p_action_status_cd          => 'E'
                                              , p_object_version_number     => p_object_version_number
                                              , p_effective_date            => p_effective_date
                                               );
/*
        g_cwb_rpt_person.status := 'E';
        g_cwb_rpt_person.lf_evt_closed := 'N';
        g_cwb_rpt_person.full_name := l_emp_num_and_emp_name.full_name;
        g_cwb_rpt_person.emp_number := l_emp_num_and_emp_name.employee_number;
        g_cwb_rpt_person.person_id := p_person_id;
        g_cwb_rpt_person.business_group_name := l_bg_and_mgr_name.NAME;
        g_cwb_rpt_person.manager_name := l_bg_and_mgr_name.full_name;
        g_cwb_rpt_person.pl_name := g_group_plan_name;

        IF g_cwb_rpt_person.group_oipl_id <> -1 THEN
          g_cwb_rpt_person.opt_name := g_cache_group_options (g_cwb_rpt_person.group_oipl_id);
        END IF;

        g_cwb_rpt_person.error_or_warning_text := substr(benutils.get_message_name || ' '||fnd_message.get,1,2000);

        IF l_comp_error THEN
          g_cwb_rpt_person.error_or_warning_text := substr(g_cwb_rpt_person.error_or_warning_text ||
               ' '||'Person ' || p_person_id || ' failed for compensation',1,2000);
        END IF;

        IF l_perf_error THEN
          g_cwb_rpt_person.amount := null;
          g_cwb_rpt_person.units := null;
          g_cwb_rpt_person.error_or_warning_text := substr(g_cwb_rpt_person.error_or_warning_text ||
               ' '||'Person ' || p_person_id || ' failed for Performance Rating',1,2000);
        END IF;

        IF l_promo_error THEN
          g_cwb_rpt_person.amount := null;
          g_cwb_rpt_person.units := null;
                  g_cwb_rpt_person.error_or_warning_text := substr(g_cwb_rpt_person.error_or_warning_text ||
                  ' '||'Person ' || p_person_id || ' failed for assignment changes',1,2000);
        END IF;
*/
        g_cache_cwb_sum_person (p_person_id).status := 'E';
        g_cache_cwb_sum_person (p_person_id).lf_evt_closed := 'N';
        g_cache_cwb_sum_person (p_person_id).country_code := l_emp_num_and_emp_name.legislation_code;
 --       g_cache_cwb_rpt_person (g_cache_cwb_rpt_person.COUNT + 1) := g_cwb_rpt_person;

      END IF;
      WRITE (benutils.get_message_name);
      WRITE (fnd_message.get);
      WRITE (SQLERRM||' in process_person');
      RAISE ben_batch_utils.g_record_error;
  END;

-- ============================================================================
--                        << Procedure: Do_Multithread >>
--  Description:
--    this is a main procedure to invoke the Compensation Workbench post
--    process.
-- ============================================================================
  PROCEDURE do_multithread (
    errbuf                OUT NOCOPY      VARCHAR2
  , retcode               OUT NOCOPY      NUMBER
  , p_validate            IN              VARCHAR2 DEFAULT 'N'
  , p_benefit_action_id   IN              NUMBER
  , p_thread_id           IN              NUMBER
  , p_effective_date      IN              VARCHAR2
  , p_audit_log           IN              VARCHAR2 DEFAULT 'N'
  , p_is_force_on_per     IN              VARCHAR2 DEFAULT 'N'
  , p_is_self_service     IN              VARCHAR2 DEFAULT 'N'
  , p_use_rate_start_date IN              VARCHAR2 DEFAULT 'N'
  )
  IS
    l_parm                     c_parameter%ROWTYPE;
    l_commit                   NUMBER;
    l_range_id                 NUMBER;
    l_record_number            NUMBER                := 0;
    l_start_person_action_id   NUMBER                := 0;
    l_end_person_action_id     NUMBER                := 0;
    l_effective_date           DATE;
    l_threads NUMBER;
    l_chunk_size NUMBER;
    g_max_errors_allowed NUMBER;
  BEGIN/*
  if(p_thread_id = 4) then
   dbms_lock.sleep(30);
  end if;*/
    g_actn := 'Started do_multithread for the thread ' || p_thread_id;
    g_proc := 'do_multithread';
    benutils.g_benefit_action_id := p_benefit_action_id;
    WRITE (g_actn);
    write_h ('=====================do_multithread=============');
    write_h ('||Parameter              Description            ');
    write_h ('||p_effective_dates -    ' || p_effective_date);
    write_h ('||p_validate -           ' || p_validate);
    write_h ('||p_benefit_action_id -  ' || p_benefit_action_id);
    write_h ('||p_thread_id -          ' || p_thread_id);
    write_h ('||p_audit_log -          ' || p_audit_log);
    write_h ('||p_is_force_on_per -    ' || p_is_force_on_per);
    write_h ('||p_is_self_service -    ' || p_is_self_service);
    l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
    --l_effective_date := TRUNC (TO_DATE (p_effective_date, 'YYYY/MM/DD HH24:MI:SS'));
    write_m ('l_effective_date is ' || l_effective_date);
    g_actn := 'Put row in fnd_sessions...';
    WRITE (g_actn);
    write_h ('dt_fndate.change_ses_date with ' || l_effective_date);
    dt_fndate.change_ses_date (p_ses_date => l_effective_date, p_commit => l_commit);

    IF (l_commit = 1)
    THEN
      write_h ('The session date is committed...');
      COMMIT;
    END IF;

    g_is_force_on_per := p_is_force_on_per;

    OPEN c_parameter (p_benefit_action_id);

    FETCH c_parameter
     INTO l_parm;

    CLOSE c_parameter;

    benutils.get_parameter (p_business_group_id     => l_parm.business_group_id
                          , p_batch_exe_cd          => 'BENCWBPP'
                          , p_threads               => l_threads
                          , p_chunk_size            => l_chunk_size
                          , p_max_errors            => g_max_errors_allowed
                           );

    g_debug_level := l_parm.debug_messages_flag;

    write_m ('Time before processing the ranges '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

    ---- bug 7126872, global var used by salary api to distinguish unapproved proposal from cwb
    IF(l_parm.bft_attribute1 = 'Y')	THEN
	 g_is_cwb_component_plan := 'Y';
    END IF;
    LOOP
      OPEN c_range_for_thread (p_benefit_action_id);

      FETCH c_range_for_thread
       INTO l_range_id
          , l_start_person_action_id
          , l_end_person_action_id;

      EXIT WHEN c_range_for_thread%NOTFOUND;

      CLOSE c_range_for_thread;

      IF (l_range_id IS NOT NULL)
      THEN
        write_h ('Range with range_id ' || l_range_id || ' with Starting person action id '
                 || l_start_person_action_id
                );
        write_h (' and Ending Person Action id ' || l_end_person_action_id || ' is selected');
        g_actn := 'Marking ben_batch_ranges for range_id ' || l_range_id || ' as processed...';
        WRITE (g_actn);

        UPDATE ben_batch_ranges ran
           SET ran.range_status_cd = 'P'
         WHERE ran.range_id = l_range_id;

        COMMIT;
      END IF;

      g_cache_person_process.DELETE;
      g_actn := 'Loading person data into g_cache_person_process cache...';
      WRITE (g_actn);
      WRITE ('Time'||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

      OPEN c_person_for_thread (p_benefit_action_id
                              , l_start_person_action_id
                              , l_end_person_action_id
                               );

      l_record_number := 0;

      LOOP
        FETCH c_person_for_thread
         INTO g_cache_person_process (l_record_number + 1).person_id
            , g_cache_person_process (l_record_number + 1).person_action_id
            , g_cache_person_process (l_record_number + 1).object_version_number
            , g_cache_person_process (l_record_number + 1).per_in_ler_id
            , g_cache_person_process (l_record_number + 1).non_person_cd;

        EXIT WHEN c_person_for_thread%NOTFOUND;
        --
        l_record_number := l_record_number + 1;
      END LOOP;

      CLOSE c_person_for_thread;
      WRITE ('Time '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

      WRITE ('Number of Persons selected in this range ' || g_cache_person_process.COUNT);
      write_h ('======Parameters required for processing this person ====');
      write_h ('||l_parm.business_group_id   ' || l_parm.business_group_id);
      write_h ('||l_parm.lf_evt_ocrd_dt      ' || l_parm.lf_evt_ocrd_dt);
      write_h ('||l_parm.grant_price_val     ' || l_parm.grant_price_val);
      write_h ('||l_parm.pl_id               ' || l_parm.pl_id);
      write_h ('||l_parm.debug_messages_flag ' || l_parm.debug_messages_flag);
      write_h ('||l_parm.bft_attribute1      ' || l_parm.bft_attribute1);
      write_h ('=======================================================');
      WRITE ('Time '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

      IF l_record_number > 0
      THEN
        FOR l_cnt IN 1 .. l_record_number
        LOOP
          --
          BEGIN
            g_actn := 'Calling process_person...';
            process_person
                   (p_validate                  => p_validate
                  , p_person_id                 => g_cache_person_process (l_cnt).person_id
                  , p_business_group_id         => l_parm.business_group_id
                  , p_effective_date            => l_effective_date
                  , p_lf_evt_ocrd_date          => l_parm.lf_evt_ocrd_dt
                  , p_grant_price_val           => l_parm.grant_price_val
                  , p_plan_id                   => l_parm.pl_id
                  , p_group_per_in_ler_id       => g_cache_person_process (l_cnt).per_in_ler_id
                  , p_person_action_id          => g_cache_person_process (l_cnt).person_action_id
                  , p_object_version_number     => g_cache_person_process (l_cnt).object_version_number
                  , p_audit_log                 => p_audit_log
                  , p_debug_level               => l_parm.debug_messages_flag
                  , p_process_sal_comp          => l_parm.bft_attribute1
                  , p_employees_in_bg           => l_parm.bft_attribute3
                  , p_is_self_service           => p_is_self_service
                  , p_is_placeholder            => g_cache_person_process (l_cnt).non_person_cd
                  , p_use_rate_start_date       => p_use_rate_start_date
                   );
          EXCEPTION
            WHEN OTHERS
            THEN
              WRITE(SQLERRM||' in multithread, caught in process_person call');
              IF (g_persons_errored > g_max_errors_allowed)
              THEN
                g_actn := '<<Compensation Workbench Max Error Limit '||g_max_errors_allowed ||' Reached >> ';
                WRITE (g_actn);
                fnd_message.set_name ('BEN', 'BEN_93145_MAX_LIMIT_REACHED');
                -- removed RAISE ben_batch_utils.g_record_error;
		raise g_max_error;
              END IF;

              NULL;
          END;
        END LOOP;

      write_m ('Time after processing the ranges '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
      ELSE
        --
        g_actn := 'Erroring out since no person is found in range...';
        --
        fnd_message.set_name ('BEN', 'BEN_91709_PER_NOT_FND_IN_RNG');
        fnd_message.set_token ('PROCEDURE', g_proc);
        fnd_message.raise_error;
      END IF;

      COMMIT;
    END LOOP;
    g_is_cwb_component_plan := 'N';
    print_cache;
  EXCEPTION
    WHEN g_max_error THEN
      WRITE(SQLERRM);
      print_cache;
      table_corrections(p_benefit_action_id);
      COMMIT;
      raise g_max_error;
    WHEN OTHERS
    THEN
      WRITE(SQLERRM);
      print_cache;
      table_corrections(p_benefit_action_id);
      COMMIT;
      fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token ('PROCEDURE', g_proc);
      fnd_message.set_token ('STEP', g_actn);
      fnd_message.raise_error;
  END;

  PROCEDURE process (
    errbuf               OUT NOCOPY      VARCHAR2
  , retcode              OUT NOCOPY      NUMBER
  , p_effective_date     IN              VARCHAR2
  , p_validate           IN              VARCHAR2
  , p_pl_id              IN              NUMBER
  , p_lf_evt_orcd_date   IN              VARCHAR2
  , p_person_id          IN              NUMBER DEFAULT NULL
  , p_manager_id         IN              NUMBER DEFAULT NULL
  , p_employees_in_bg    IN              NUMBER DEFAULT NULL
  , p_grant_price_val    IN              NUMBER DEFAULT NULL
  , p_audit_log          IN              VARCHAR2 DEFAULT 'N'
  , p_hidden_audit_log   IN              VARCHAR2
  , p_debug_level        IN              VARCHAR2 DEFAULT 'L'
  , p_bg_id              IN              NUMBER
  , p_is_multi_thread    IN              VARCHAR2 DEFAULT 'Y'
  , p_is_force_on_per    IN              VARCHAR2 DEFAULT 'N'
  , p_is_self_service    IN              VARCHAR2 DEFAULT 'N'
  , p_person_selection_rule_id IN        NUMBER   DEFAULT NULL
  , p_use_rate_start_date IN             VARCHAR2 DEFAULT 'N'
  )
  IS
    --
    -- local variable declaration.
    --
    l_effective_date          DATE;
    l_commit                  NUMBER;
    l_chunk_size              NUMBER;
    l_request_id              NUMBER;
    l_threads                 NUMBER;
    l_benefit_action_id       NUMBER;
    l_object_version_number   NUMBER;
    l_num_ranges              NUMBER                       := 0;
    l_num_persons             NUMBER                       := 0;
    l_comp_reason_count       NUMBER;
    l_silent_error            EXCEPTION;
    l_slave_errored           EXCEPTION;
    l_process_compents        VARCHAR2 (1)                 := 'N';
    l_num_rows                NUMBER                       := 0;
    ps_rec                    c_person_selection%ROWTYPE;
    l_person_action_ids       g_number_type                := g_number_type ();
    l_person_ids              g_number_type                := g_number_type ();
    l_per_in_ler_ids          g_number_type                := g_number_type ();
    l_is_placeholder          g_number_type                := g_number_type ();
    l_lf_evt_orcd_date        DATE;
    l_dummy                   c_slaves%ROWTYPE;
    l_person_ok    varchar2(1) := 'Y';
    l_err_message  varchar2(2000);
    l_person_id              per_all_people_f.person_id%type;
    pl_rec c_placeholder_selection%ROWTYPE;
    l_count NUMBER;
  BEGIN
    g_actn := 'Stating the post-process...';
    WRITE (g_actn);
    g_proc := g_package || '.process';
    g_debug_level := p_debug_level;
    l_lf_evt_orcd_date := trunc(fnd_date.canonical_to_date(p_lf_evt_orcd_date));
    l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
    write_h ('=====================process====================');
    write_h ('||Parameter              Description            ');
    write_h ('||p_effective_dates -    ' || l_effective_date);
    write_h ('||p_validate -           ' || p_validate);
    write_h ('||p_pl_id -              ' || p_pl_id);
    write_h ('||p_le_orcd_date -       ' || l_lf_evt_orcd_date);
    write_h ('||p_person_id -          ' || p_person_id);
    write_h ('||p_manager_id -         ' || p_manager_id);
    write_h ('||p_employees_in_bg -    ' || p_employees_in_bg);
    write_h ('||p_grant_price_val -    ' || p_grant_price_val);
    write_h ('||p_audit_log -          ' || p_audit_log);
    write_h ('||p_bg_id -              ' || p_bg_id);
    write_h ('||p_is_multi_thread -    ' || p_is_multi_thread);
    write_h ('||p_is_force_on_per -    ' || p_is_force_on_per);
    write_h ('||p_use_rate_start_date - ' || p_use_rate_start_date);
    write_h ('||p_is_self_service -    ' || p_is_self_service);
    write_h ('================================================');
    write_m ('l_effective_date is ' || l_effective_date);
    g_actn := 'Put row in fnd_sessions...';
    WRITE (g_actn);
    write_h ('dt_fndate.change_ses_date with ' || l_effective_date);
    dt_fndate.change_ses_date (p_ses_date => l_effective_date, p_commit => l_commit);
    write_h ('Commit value for dt_fndate is ' || l_commit);

    IF (l_commit = 1)
    THEN
      write_h ('The session date is committed...');
      COMMIT;
    END IF;

    g_actn := 'initializing the process parameters';
    WRITE (g_actn);
    g_exec_param_rec.persons_selected := 0;
    g_exec_param_rec.persons_proc_succ := 0;
    g_exec_param_rec.persons_errored := 0;
    g_exec_param_rec.lf_evt_closed := 0;
    g_exec_param_rec.lf_evt_not_closed := 0;
    g_exec_param_rec.business_group_id := p_bg_id;
    g_exec_param_rec.start_date := SYSDATE;
    g_exec_param_rec.start_time := DBMS_UTILITY.get_time;
    g_actn := 'Checking for valid read-only-reason to find salary components...';
    WRITE (g_actn);
    WRITE ('Time'||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

    OPEN c_component_reason (p_pl_id, l_effective_date);
    FETCH c_component_reason INTO l_comp_reason_count;
    CLOSE c_component_reason;

    WRITE ('Time'||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

    write_m ('Options with component reason is ' || l_comp_reason_count);

    IF l_comp_reason_count > 0 THEN
      l_process_compents := 'Y';
    END IF;

    g_actn := 'Calling ben_batch_utils.ini...';
    WRITE (g_actn);
    write_h ('ben_batch_utils.ini with PROC_INFO');
    ben_batch_utils.ini (p_actn_cd => 'PROC_INFO');
    g_actn := 'Calling benutils.get_parameter...';
    WRITE (g_actn);
    write_h ('benutils.get_parameter with ' || p_bg_id || ' ' || 'BENCWBPP' || ' '
             || g_max_errors_allowed
            );
    benutils.get_parameter (p_business_group_id     => p_bg_id
                          , p_batch_exe_cd          => 'BENCWBPP'
                          , p_threads               => l_threads
                          , p_chunk_size            => l_chunk_size
                          , p_max_errors            => g_max_errors_allowed
                           );
    write_h ('Values of l_threads is ' || l_threads || ' and l_chunk_size is ' || l_chunk_size);
    benutils.g_thread_id := 99;                            -- need to investigate why this is needed
    g_actn := 'Creating benefit actions...';
    WRITE (g_actn);
    WRITE ('Time'||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
    write_h ('=====================Benefit Actions=======================');
    write_h ('||Parameter                  value                         ');
    write_h ('||p_request_id-             ' || fnd_global.conc_request_id);
    write_h ('||p_program_application_id- ' || fnd_global.prog_appl_id);
    write_h ('||p_program_id-             ' || fnd_global.conc_program_id);
    write_h ('==========================================================');
    ben_benefit_actions_api.create_perf_benefit_actions
                                               (p_benefit_action_id          => l_benefit_action_id
                                              , p_process_date               => l_effective_date
                                              , p_mode_cd                    => 'W'
                                              , p_derivable_factors_flag     => 'NONE'
                                              , p_validate_flag              => p_validate
                                              , p_debug_messages_flag        => NVL (p_debug_level
                                                                                   , 'N'
                                                                                    )
                                              , p_business_group_id          => p_bg_id
                                              , p_no_programs_flag           => 'N'
                                              , p_no_plans_flag              => 'N'
                                              , p_audit_log_flag             => p_audit_log
                                              , p_pl_id                      => p_pl_id
                                              , p_pgm_id                     => -9999
                                              , p_lf_evt_ocrd_dt             => l_lf_evt_orcd_date
                                              , p_person_id                  => p_person_id
                                              , p_grant_price_val            => p_grant_price_val
                                              , p_object_version_number      => l_object_version_number
                                              , p_effective_date             => l_effective_date
                                              , p_request_id                 => fnd_global.conc_request_id
                                              , p_program_application_id     => fnd_global.prog_appl_id
                                              , p_program_id                 => fnd_global.conc_program_id
                                              , p_program_update_date        => SYSDATE
                                              , p_bft_attribute1             => l_process_compents
                                              , p_bft_attribute3             => p_employees_in_bg
                                              , p_bft_attribute4             => p_manager_id
                                               );
    write ('Benefit Action Id is ' || l_benefit_action_id);
    benutils.g_benefit_action_id := l_benefit_action_id;
    g_actn := 'Inserting Person Actions...';
    WRITE (g_actn);
    write_m ('Time before processing the person selections '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

    OPEN c_placeholder_selection (p_pl_id
                           , l_lf_evt_orcd_date
                           , p_person_id
                           , p_manager_id
                           , p_employees_in_bg
                           , l_effective_date
                            );

    LOOP
      FETCH c_placeholder_selection
       INTO pl_rec;

      EXIT WHEN c_placeholder_selection%NOTFOUND;

      l_person_ok := 'Y';
      l_person_id :=pl_rec.person_id;

        If p_person_selection_rule_id is not NULL then
        --
          begin
          ben_batch_utils.person_selection_rule
                      (p_person_id               => l_person_id
                      ,p_business_group_id       => pl_rec.business_group_id
                      ,p_person_selection_rule_id=> p_person_selection_rule_id
                      ,p_effective_date          => l_effective_date
                      ,p_return                  => l_person_ok
                      ,p_err_message             => l_err_message );

                 if l_err_message  is not null
		 then
		     Ben_batch_utils.write(p_text =>
        		'<< Person id : '||to_char(l_person_id)||' failed.'||
			'   Reason : '|| l_err_message ||' >>' );
                    l_err_message := NULL ;
	         end if ;
	exception
		when others then
			l_person_ok:='N';
	end;
          --
        End if;


      If l_person_ok = 'Y'  then

      	l_num_rows := l_num_rows + 1;
      	l_num_persons := l_num_persons + 1;
      	l_person_action_ids.EXTEND (1);
      	l_person_ids.EXTEND (1);
      	l_per_in_ler_ids.EXTEND (1);
      	l_is_placeholder.EXTEND (1);

      SELECT ben_person_actions_s.NEXTVAL
        INTO l_person_action_ids (l_num_rows)
        FROM DUAL;

      l_person_ids (l_num_rows) := pl_rec.person_id;
      l_per_in_ler_ids (l_num_rows) := pl_rec.per_in_ler_id;
      l_is_placeholder (l_num_rows) := 1;

      write_h ('============Placeholder Person Header==================');
      write_h ('||Person Name      ' || pl_rec.full_name);
      write_h ('||Business Group   ' || pl_rec.NAME);
      write_h ('||Person Id        ' || pl_rec.person_id);
      write_h ('||Per_in_ler_id    ' || pl_rec.per_in_ler_id);
      write_h ('||Person Action id ' || l_person_action_ids (l_num_rows));
      write_h ('=======================================================');

      end if;

      IF l_num_rows = l_chunk_size
      THEN
        l_num_ranges := l_num_ranges + 1;
        insert_person_actions (p_per_actn_id_array       => l_person_action_ids
                             , p_per_id                  => l_person_ids
                             , p_group_per_in_ler_id     => l_per_in_ler_ids
                             , p_benefit_action_id       => l_benefit_action_id
                             , p_is_placeholder          => l_is_placeholder
                              );
        l_num_rows := 0;
        l_person_action_ids.DELETE;
        l_person_ids.DELETE;
        l_per_in_ler_ids.DELETE;
      	l_is_placeholder.DELETE;
      END IF;
    g_cache_cwb_sum_person (pl_rec.person_id).person_id := pl_rec.person_id;
    g_cache_cwb_sum_person (pl_rec.person_id).bg_name := pl_rec.NAME;
    g_cache_cwb_sum_person (pl_rec.person_id).bg_id := p_bg_id;
    g_cache_cwb_sum_person (pl_rec.person_id).country_code := pl_rec.legislation_code;
    g_cache_cwb_sum_person (pl_rec.person_id).person_name := pl_rec.full_name;
    g_cache_cwb_sum_person (pl_rec.person_id).benefit_action_id := l_benefit_action_id;
    END LOOP;

    CLOSE c_placeholder_selection;

    OPEN c_person_selection (p_pl_id
                           , l_lf_evt_orcd_date
                           , p_person_id
                           , p_manager_id
                           , p_employees_in_bg
                           , l_effective_date
                            );

    LOOP
      FETCH c_person_selection
       INTO ps_rec;

      EXIT WHEN c_person_selection%NOTFOUND;

      l_person_ok := 'Y';
      l_person_id :=ps_rec.person_id;

        If p_person_selection_rule_id is not NULL then
        --
          begin
          ben_batch_utils.person_selection_rule
                      (p_person_id               => l_person_id
                      ,p_business_group_id       => ps_rec.business_group_id
                      ,p_person_selection_rule_id=> p_person_selection_rule_id
                      ,p_effective_date          => l_effective_date
                      ,p_return                  => l_person_ok
                      ,p_err_message             => l_err_message );

                 if l_err_message  is not null
		 then
		     Ben_batch_utils.write(p_text =>
        		'<< Person id : '||to_char(l_person_id)||' failed.'||
			'   Reason : '|| l_err_message ||' >>' );
                    l_err_message := NULL ;
	         end if ;
	exception
		when others then
			l_person_ok:='N';
	end;
          --
        End if;


      If l_person_ok = 'Y'  then

      	l_num_rows := l_num_rows + 1;
      	l_num_persons := l_num_persons + 1;
      	l_person_action_ids.EXTEND (1);
      	l_person_ids.EXTEND (1);
      	l_per_in_ler_ids.EXTEND (1);
      	l_is_placeholder.EXTEND (1);


      SELECT ben_person_actions_s.NEXTVAL
        INTO l_person_action_ids (l_num_rows)
        FROM DUAL;

      l_person_ids (l_num_rows) := ps_rec.person_id;
      l_per_in_ler_ids (l_num_rows) := ps_rec.per_in_ler_id;
      l_is_placeholder(l_num_rows) := 0;

      write_h ('=====================Person Header====================');
      write_h ('||Person Name      ' || ps_rec.full_name);
      write_h ('||Business Group   ' || ps_rec.NAME);
      write_h ('||Person Id        ' || ps_rec.person_id);
      write_h ('||Per_in_ler_id    ' || ps_rec.per_in_ler_id);
      write_h ('||Person Action id ' || l_person_action_ids (l_num_rows));
      write_h ('=======================================================');

      end if;

      IF l_num_rows = l_chunk_size
      THEN
        l_num_ranges := l_num_ranges + 1;
        insert_person_actions (p_per_actn_id_array       => l_person_action_ids
                             , p_per_id                  => l_person_ids
                             , p_group_per_in_ler_id     => l_per_in_ler_ids
                             , p_benefit_action_id       => l_benefit_action_id
                             , p_is_placeholder          => l_is_placeholder
                              );
        l_num_rows := 0;
        l_person_action_ids.DELETE;
        l_person_ids.DELETE;
        l_per_in_ler_ids.DELETE;
        l_is_placeholder.DELETE;
      END IF;
    END LOOP;

    CLOSE c_person_selection;

    g_person_selected := l_num_rows;
    WRITE ('Total no of person selected - ' || g_person_selected);
    g_actn := 'Inserting the last range of persons if exists...';
    WRITE (g_actn);
    write_m ('Time after processing the person selections '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));


    IF l_num_rows <> 0
    THEN
      l_num_ranges := l_num_ranges + 1;
      insert_person_actions (p_per_actn_id_array       => l_person_action_ids
                           , p_per_id                  => l_person_ids
                           , p_group_per_in_ler_id     => l_per_in_ler_ids
                           , p_benefit_action_id       => l_benefit_action_id
                           , p_is_placeholder          => l_is_placeholder
                            );
      l_num_rows := 0;
      l_person_action_ids.DELETE;
      l_person_ids.DELETE;
      l_per_in_ler_ids.DELETE;
      l_is_placeholder.DELETE;
    END IF;

    COMMIT;
    g_actn := 'Submitting job to con-current manager...';
    WRITE (g_actn);
    g_actn := 'Preparing for launching concurrent requests';
    WRITE (g_actn);
    ben_batch_utils.g_num_processes := 0;
    ben_batch_utils.g_processes_tbl.DELETE;

    write_m ('Time before launching the threads '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

    IF l_num_ranges > 1
    THEN
      FOR l_count IN 1 .. LEAST (l_threads, l_num_ranges) - 1
      LOOP
        write_h ('=====================Request Parameters===================');
        write_h ('||Parameter               value                           ');
        write_h ('||argument2-              ' || l_benefit_action_id);
        write_h ('||argument3-              ' || l_count);
        write_h ('==========================================================');
        l_request_id :=
          fnd_request.submit_request (application     => 'BEN'
                                    , program         => 'BENCWBMT'
                                    , description     => NULL
                                    , sub_request     => FALSE
                                    , argument1       => p_validate
                                    , argument2       => l_benefit_action_id
                                    , argument3       => l_count
                                    , argument4       => p_effective_date
                                    , argument5       => p_audit_log
				    , argument6       => p_is_force_on_per
				    , argument7       => p_is_self_service
				    , argument8       => p_use_rate_start_date
                                     );
        ben_batch_utils.g_num_processes := ben_batch_utils.g_num_processes + 1;
        ben_batch_utils.g_processes_tbl (ben_batch_utils.g_num_processes) := l_request_id;
        write_m ('request id for this thread ' || l_request_id);
        COMMIT;
      END LOOP;
    ELSIF l_num_ranges = 0
    THEN
      WRITE ('<< No Person got selected with above selection criteria >>');
      fnd_message.set_name ('BEN', 'BEN_91769_NOONE_TO_PROCESS');
      fnd_message.set_token ('PROC', g_proc);
      RAISE l_silent_error;
    END IF;

    write_m ('Time after launching the threads '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));

    write_h ('=====================do_multithread in Process============');
    write_h ('||Parameter               value                           ');
    write_h ('||p_benefit_action_id-    ' || l_benefit_action_id);
    write_h ('||p_thread_id-            ' || (l_threads + 1));
    write_h ('==========================================================');
    do_multithread (errbuf                  => errbuf
                  , retcode                 => retcode
                  , p_validate              => p_validate
                  , p_benefit_action_id     => l_benefit_action_id
                  , p_thread_id             => l_threads + 1
                  , p_effective_date        => p_effective_date
                  , p_audit_log             => p_audit_log
		  , p_is_force_on_per       => p_is_force_on_per
		  , p_is_self_service       => p_is_self_service
		  , p_use_rate_start_date   => p_use_rate_start_date
                   );
    g_actn := 'Calling ben_batch_utils.check_all_slaves_finished...';
    WRITE (g_actn);

    ben_batch_utils.check_all_slaves_finished (p_rpt_flag => TRUE);
    g_actn := 'Calling end_process...';
    WRITE (g_actn);

    write_h ('=====================End Process==========');
    write_h ('||Parameter               value                           ');
    write_h ('||p_pl_id-             ' || p_pl_id);
    write_h ('||p_lf_evt_orcd_date-  ' || l_lf_evt_orcd_date);
    write_h ('==========================================================');

    process_access( p_pl_id
                   ,l_lf_evt_orcd_date
                   ,p_validate
                  );

    write_h ('=====================End Process==========');
    write_h ('||Parameter               value                           ');
    write_h ('||p_benefit_action_id-    ' || l_benefit_action_id);
    write_h ('||p_person_selected-      ' || l_num_persons);
    write_h ('==========================================================');
    end_process (p_benefit_action_id     => l_benefit_action_id
               , p_person_selected       => l_num_persons
               , p_business_group_id     => p_bg_id
                );
    table_corrections(l_benefit_action_id);
    g_actn := 'Finished Process Procedure...';
    WRITE (g_actn);

    BEGIN
      For l_count in 1..ben_batch_utils.g_num_processes loop
        open c_slaves(ben_batch_utils.g_processes_tbl(l_count));
        fetch c_slaves into l_dummy;
        If c_slaves%found then
          close c_slaves;
          raise l_slave_errored;
          exit;
        End if;
        Close c_slaves;
      End loop;
    EXCEPTION
	WHEN l_slave_errored THEN
		--fnd_message.set_name ('BEN', 'BEN_94890_CWB_PROC_SLAVE_ERROR');
                --fnd_message.set_name('BEN', 'BEN_93145_MAX_LIMIT_REACHED');
		g_actn:= 'slave processes';
	        raise g_slave_error;
    END;

  EXCEPTION
    --
    WHEN l_silent_error
    THEN
      WRITE (fnd_message.get);
	IF (l_num_ranges > 0) THEN
		WRITE('END_PROCESS');
		ben_batch_utils.check_all_slaves_finished (p_rpt_flag => TRUE);
		end_process (p_benefit_action_id     => l_benefit_action_id
			, p_person_selected       => l_num_persons
			, p_business_group_id     => p_bg_id
			);
	END IF;
    --
    WHEN g_slave_error THEN
      WRITE (fnd_message.get);
      WRITE (SQLERRM);
      WRITE ('Big Error Occurred');
	IF (l_num_ranges > 0) THEN
		WRITE('END_PROCESS');
		ben_batch_utils.check_all_slaves_finished (p_rpt_flag => TRUE);
		end_process (p_benefit_action_id     => l_benefit_action_id
			, p_person_selected       => l_num_persons
			, p_business_group_id     => p_bg_id
			);
	END IF;
	fnd_message.clear();
      fnd_message.set_name('BEN', 'BEN_94890_CWB_PROC_SLAVE_ERROR');
      --fnd_message.set_name('BEN', 'BEN_93145_MAX_LIMIT_REACHED');
      --fnd_message.raise_error;
      RAISE_APPLICATION_ERROR(-20001,fnd_global.Newline||fnd_message.get||fnd_global.Newline);
      --
    WHEN g_max_error THEN
      WRITE (fnd_message.get);
      WRITE (SQLERRM);
      WRITE ('Big Error Occurred');
	IF (l_num_ranges > 0) THEN
		WRITE('END_PROCESS');
		ben_batch_utils.check_all_slaves_finished (p_rpt_flag => TRUE);
		end_process (p_benefit_action_id     => l_benefit_action_id
			, p_person_selected       => l_num_persons
			, p_business_group_id     => p_bg_id
			);
	END IF;

      fnd_message.set_name('BEN', 'BEN_93145_MAX_LIMIT_REACHED');
      --fnd_message.raise_error;
      RAISE_APPLICATION_ERROR(-20001,fnd_global.Newline||fnd_message.get||fnd_global.Newline);
    --
    WHEN OTHERS THEN
      WRITE (fnd_message.get);
      WRITE (SQLERRM);
      WRITE ('Big Error Occurred');
	IF (l_num_ranges > 0) THEN
		WRITE('END_PROCESS');
		ben_batch_utils.check_all_slaves_finished (p_rpt_flag => TRUE);
		end_process (p_benefit_action_id     => l_benefit_action_id
			, p_person_selected       => l_num_persons
			, p_business_group_id     => p_bg_id
			);
	END IF;

      fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token ('PROCEDURE', g_proc);
      fnd_message.set_token ('STEP', g_actn);
      fnd_message.raise_error;
  END;
END;

/
