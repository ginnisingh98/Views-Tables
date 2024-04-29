--------------------------------------------------------
--  DDL for Package Body BEN_MANAGE_DEFAULT_ENRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_MANAGE_DEFAULT_ENRT" as
/* $Header: beneadeb.pkb 120.17.12010000.7 2009/07/31 09:28:28 pvelvano ship $ */
--
/* ============================================================================
* Name
*   Manage Default Enrollment Process
*
* Purpose
*   This package is used to check validity of parameters passed in via SRS
*   or via a PL/SQL function or procedure. This package will make a call to
*   a PL/SQL package procedure will process default enrollment for
*   a particular person or person's.
*
* History
*   Date        Who         Version What?
*   ----------- ----------  ------- ---------------------------------------
*   28 Mar 1998  Hugh Dang  110.0   Created.
*   16 Jun 1998  Hugh Dang  110.1   Message functions
*   23 Jun 1998  Hugh Dang  110.2   Change Per_in_ler where clause from
*                                   effective_start_date to stat_cd.
*   29 Jun 1998  lmcdonal   110.4   Exclude programs from processing if
*                                   there are results for that program and
*                                   this per-in-ler in the result table.
*                                   ditto for plans not in program.
*   21 Jul 1998  Hugh Dang  110.5   Add print parameters procedure to
*                                   print out nocopy parameters list to the log
*                                   file.
*   22 Sep 1998  Hugh Dang  115.6   Modify the where clause for dflt enrt
*                                   date from >= effect date to <=
*                                   effective date in g_dflt_mn_epe
*                                   cursor.
*   13 Oct 1998  Hugh Dang  115.7   Modify the population source from
*                                   Elctbl Choice table to Pil Electbl chc
*                                   popl and add default process for only
*                                   one comp. object.
*   31 Oct 1998  S Tee      115.8   Added a person_id parameter to process_
*                                   post_enrollment procedure. Add
*                                   per_in_ler_id to delete_enrollment.
*   05 Nov 1998  Hugh Dang  115.9   Change call to get_parameters.
*   01 Dec 1998  Hugh Dang  115.10  Remove p_mode_cd check.
*   02 Dec 1998  Hugh Dang  115.11  Change logic how to handle report/log,
*                                   and common procedures/Function into
*                                   ben_batch_utils package.
*   11 Dec 1998  S Tee      115.12  Added the per_in_ler_id to process
*                                   common enrollment result procedure.
*   20-Dec-1998  Hdang      115.13  Added audit_log to turn audit log report
*                                   on and off.
*   22-Dec-1998  Hdang      115.14  Turn Audit log report on.
*
*   28-Dec-1998  Jlamoureux 115.15  Removed dflt_enrt_dt, enrt_typ_cycl_cd,
*                                   enrt_perd_strt_dt, and enrt_perd_end_dt
*                                   from c_dflt_mn_epe cursor.  These columns
*                                   have moved to pil_elctbl_chc_popl.
*   28-Dec-1998  Hdang      115.16  Add Prtt_enrt_rslt_id in batch_rate tbl.
*   29-Dec-1998  Hdang      115.17  Call ini_proc_info from process.
*   01-Jan-1999  Stee       115.18  Changed post enrollment to pass a process
*                                   code.
*   12-Jan-1999  Hdang      115.19  Added commit to force report info got
*                                   commit.
*   03-Feb-1999  Hdang      115.20  Add logic to default comp obj procedure to
*                                   handle mandatory flag.
*   22-Feb-1999  Hdang      115.21  Chagne p_effective_date data type from date
*                                   to varchar2
*
*   22-Feb-1999  Hdang      115.22  Change multitrhead p_eefective_date.
*   03-MAr-1999  Stee       115.23  Removed dbms_output.put_line.
*   22-MAR-1999  TMathers   115.27  CHanged -MON- to /MM/
*   05-Apr-1999  mhoyes     115.28 - Un-datetrack of per_in_ler_f changes.
*   10-May-1999  jcarpent   115.29  Check ('VOIDD','BCKDT') for pil stt cd
*   20-JUL-1999  Gperry     115.30  genutils -> benutils package rename.
*   12-Aug-1999  lmcdonal   115.31  Start support for enterable cvg amounts.
*                                   To complete, need task 280 to be done
*                                   (changes to benelinf).
*   25-Aug-1999  Gperry     115.32  Added ben_env_object call to multithread.
*   25-AUG-1999  Gperry     115.33  Leapfrog of 115.30 with ben_env_object fix.
*   25-AUG-1999  Gperry     115.34  Leapfrog of 115.32 with ben_env_object fix.
*   14-SEP-1999  shdas      115.35  added bnft_val to election_information
*   06-Oct-1999  tguy       115.36  added call to dt_fndate
*   19-Oct-1999  maagrawa   115.37  Call to write_table_and_file changed to
*                                   log the messages in the log file.
*   10-Nov-1999  jcarpent   115.38  Switched order of post_enrollment and
*                                   post_results calls so that pil is not
*                                   closed too soon.
*   14-Dec-1999  jcarpent   115.39  Moved close enrollment to end of process.
*   28-Dec-1999  stee       115.40  Added per_in_ler_id to multi_rows_edit
*                                   call and removed delete enrollment as it
*                                   will be deleted in the multi_rows_edit
*                                   logic and dependents will be recycled
*                                   properly.
*   01-Feb-2000  gperry     115.41  Fixed WWBUG 1176104. Multithreading not
*                                   working.
*   10-Feb-2000  jcarpent   115.42  Bleeding benefits fixed.  bnft vars set
*                                   null within default loop.
*   04-Apr-2000  gperry     115.43  Fixed WWBUG 1217194.
*   11-Apr-2000  mmogel     115.45  Added tokens to messages to make them
*                                   more meaningful to the user
*   18-May-2000  gperry     115.46  No persons selected errors silently now.
*                                   WWBUG 1097159
*   18-May-2000  gperry     115.47  Initial performance fixes.
*   19-May-2000  gperry     115.48  Removed ben_timing stuff.
*   30-May-2000  gperry     115.49  More performance tuning.
*   29-Jun-2000  shdas      115.50  Added call to reinstate_dpnt
*   23-jan-2001  jcarpent   115.51  Bug 1609055. Set ler info when c_pel
*                                   returns no rows.
*   01-Jul-2001  kmahendr   115.52  Unrestricted changes
*   13-Jul-2001  ikasire    115.53  Bug 1834566 changed the cursor c_rt
*                                   where clause to remove
*                                   ecr.prtt_rt_val_id is null condition.
*   18-dec-2001  tjesumic   115.54  cwb changes
*   20-dec-2001  ikasire    115.55  added dbdrv lines
*   30-Apr-2002  kmahendr   115.56  Added write calls to capture error messages.
*
*   08-Jun-02    pabodla    115.57  Do not select the contingent worker
*                                   assignment when assignment data is
*                                   fetched.
*   14-Nov-02    vsethi     115.58  Bug 2370264 In Default_Comp_obj changed exception
*                                   handling for forms (p_batch_flag is false)
*   19-dec-02    pabodla    115.59  NOCOPY Changes
    03-Jan-03    tjesumic   115.60  after the enhncemnt # 2685018 cryfwd_elig_dpnt_cd value is
                                    concated with result id from where the dpnt carry forwarded ,
                                    this fix  will seprate the code from result id
*   05-Mar-03    hnarayan   115.62  Bug 2828045 - In c_person cursor of Process,
*				    uncommented BG id check and added check
*				    to exclude PILs of type COMP and ABS. Also fixed
*				    p_ler_id parameter check condition in the query.
*   07-Mar-03    tjesumic   115.63  2944657 whne the enrollment is closed from LE form
*                                   min max restriction is nat validated.  the enrollment can be
*                                   made without enrolling in a plan, Min reqment of the plan is 1 though
*                                   this is fixed by calling ben_proc_common_enrt_rslt.set_elcn_made_or_asnd_dt
*                                   before multi_rows_edit
*   15-MAY-03    glingapp   115.64  2961251 Passed the pl_id parameter in
*				    ben_proc_common_enrt_rslt.set_elcn_made_or_asnd_dt.
*   16-Sep-03    kmahendr   115.65  GSP changes
*   22-Sep-03    mmudigon   115.66  Bug 3121395. Changes to c_rt cursor
*   6-oct-03     nhunur     115.67  made changes to exception handling in default_comp_obj procedure.
*   16-Oct-03    tjesumic   115.68  l_prev_enrt_rslt_id resintialized
*   30-Oct-03    ikasire    115.69  Bug 3192923 OVERRIDE thru date needs to be handled
*   13-sep-04    vvprabhu   115.70  Bug 3876613 Procedure Default_Comp_obj_w added
*   05-nov-04    vvprabhu   115.71  Bug 3978573 parameter p_called_from_ss added to
*                                   Default_Comp_obj to pypass multi_row_edit when called from SSBEN.
*   03-Dec-04    ikasire    115.72  Bug 4046914
*   10-Jan-05    lakrish    115.73  3989075, call dt_fndate.change_ses_date to insert a row into
*                                   fnd_sessions while running default enrt process from SS
*   26-Jan-05    ikasire    115.74  BUG 4064635 CF Suspended Interim Changes
*   26-May-05    vborkar    115.75  Bug 4387247 : In wrapper method exception
*                                   handlers changes made to avoid null errors
*                                   on SS pages
*   01-Jun-05    vborkar    115.76  Bug 4387247 : Modifications to take care of
*                                   application exceptions.
*   22-Jun-05    vvprabhu   115.77  Bug 4421813 ben_env_obj.init added to default_comp_obj
*                                   in cases where it is called from self-service.
*   20-Jul-05    ikasire    115.78  Bug 4463836 passing the p_called_from_ss to multi_row_edit call
*   26-Oct-05    bmanyam    115.79  4684991 - Use lf_evt_ocrd_dt instead of p_effective_date
*                                   when checking for overide-thru-date
*   13-Dec-05    vborkar    115.80  Bug 4695708 : Made changes to Default_Comp_obj
*                                   and Default_Comp_obj_w exception handlers
*                                   so that error messages are correctly shown
*                                   in SS.
*   11-Apr-06    swjain    115.82   Bug 4951065 - Updated cursor c_dflt_mn_epe_mndtry
*                                   in procedure Default_Comp_obj
*   03-May-06    abparekh  115.83   Bug 5158204 - use minimum (enrt perd start date, defaults assnd date )
*                                                 for default enrollment date
*   14-Sep-06    abparekh  115.84   Bug 5407755 - Modified fix of version 115.83
*                          115.85                 use NVL(defaults assnd date, enrt perd end date)
*                                                 for close enrollment date
*   16-Nov-06    vvprabhu  115.86   Bug 5664300 - added p_called_frm_ss parameter to
*                          115.87                 process_post_results
*   30-Nov-06    rtagarra  115.88   Bug 5662220 - Added check so that when there is no condition for a person
*				      in person_selection_rule then skip the person.
*   22-Jan-07    kmahendr  115.89   Bug#5768880 - changed cursor c_pel to filter
                                    out unrestricted pels
*   27-apr-07    nhunur    115.90   changed incorrect join condition introduced above

*   24-May-07    sjilla    115.91   Bug 6027345 - Additional more specific Exception hadler used.
*   06-aug-07    swjain    115.92   Bug 6319484 - Updated cursor c_dflt_mn_epe
*   09-Aug-07    vvprabhu  115.93  Bug 5857493 - added g_audit_flag to
*                                   control person selection rule error logging
*   12-jun-08    bachakra  115.97   Bug 7166971 - added clause in c_pel to apply defaults
                                    for those programs whose default assigned date is less
				    than effective date. Also removed the fix for 6992857
				    as that is not the expected functioanlity.
*   28-Jul-09    velvanop  115.99   Fidelity Enhancement Bug No: 8716679
*                                  The enhancement request is to reinstate elections from an intervening event
*                                  with a life event that is backed out and reprocessed. The objective is to allow
*                                  customers to have the ability to determine whether elections made for
*                                  intervening events should be brought forward for a backed out life events.
* -----------------------------------------------------------------------------------
*/
--
-- Global cursor and variables declaration
--
g_package             varchar2(80) := 'Ben_manage_default_Enrt';
g_max_errors_allowed  number(9) := 200;
g_persons_errored     number(9) := 0;
g_persons_procd       number(9) := 0;
g_rec                 benutils.g_batch_ler_rec;
--
-- ===========================================================================
--                   << Procedure: Write_person_category >>
-- ===========================================================================
--
Procedure write_person_category
            (p_audit_log          varchar2 default 'N'
            ,p_error              Boolean  default FALSE
            ,p_business_group_id  number
            ,P_person_id          number
            ,p_effective_date     date
            ) is
  --
  Cursor c1 (c_prtt_enrt_rslt_id number) is
    Select ecd.dpnt_person_id, ecd.cvg_strt_dt, ecd.cvg_thru_dt
      From ben_elig_cvrd_dpnt_f ecd,
           ben_per_in_ler pil
     Where ecd.prtt_enrt_rslt_id is not NULL
       and ecd.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
       and ecd.business_group_id = p_business_group_id
       and p_effective_date between
             ecd.effective_start_date and ecd.effective_end_date
       and pil.per_in_ler_id=ecd.per_in_ler_id
       --and pil.business_group_id=ecd.business_group_id
       and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') ;



  l_proc        varchar2(80) := g_package||'.write_person_category';
  l_actn        varchar2(80);
  l_cache       ben_batch_utils.g_comp_obj_table := ben_batch_utils.g_cache_comp;
  l_cache_cnt   binary_integer := ben_batch_utils.g_cache_comp_cnt;
  l_category    varchar2(30):= 'DEFNOCHG';
  l_detail      varchar2(132) := 'Default election asigned -- no current elections changed' ;
  l_OVN         Number;
  l_id          Number;
  l_OVN1   	    varchar2(240);
  l_actn_cd     varchar2(30);
Begin
  hr_utility.set_location ('Entering '||l_proc,05);
  l_actn := 'Starting...';
  If (p_error) then
    If (p_audit_log = 'Y') then
      l_category := 'ERROR_C';
      l_detail := 'Error occur while defaulting enrollment';
      --
      l_actn := 'Calling ben_batch_utils.write_rec (ERROR)...';
      Ben_batch_utils.write_rec(p_typ_cd => l_category ,p_text   => l_detail);
    End if;
  Else
    For i in 1..l_cache_cnt Loop
      If (l_cache(i).upd_flag or l_cache(i).ins_flag or l_cache(i).del_flag) then
        l_category := 'DEFWCHG';
        l_detail := 'Default elections assigned -- some or all current election changed';
        exit;
      End if;
    End loop;
    --
    l_actn := 'Calling ben_batch_utils.write_rec (DEFAULT)...';
    Ben_batch_utils.write_rec(p_typ_cd => l_category,p_text   => l_detail);
  End if;
  If (p_audit_log = 'Y') then
    For i in 1..l_cache_cnt Loop
      If (l_cache(i).del_flag) then
        l_actn_cd := 'DEL';
      Elsif (l_cache(i).ins_flag) then
        l_actn_cd := 'INS';
      Elsif (l_cache(i).upd_flag) then
        l_actn_cd := 'UPD';
      Elsif (l_cache(i).def_flag) then
        l_actn_cd := 'DEF';
      End if;
      --
      l_actn := 'Calling ben_batch_rate_info_api.create_batch_rate_info...';
      insert into ben_batch_rate_info
        (batch_rt_id,
         benefit_action_id,
         person_id,
         pgm_id,
         pl_id,
         oipl_id,
         dflt_val,
         val,
         actn_cd,
         dflt_flag,
         business_group_id,
         object_version_number)
      values
        (ben_batch_rate_info_s.nextval,
         benutils.g_benefit_action_id,
         p_person_id,
         l_cache(i).pgm_id,
         l_cache(i).pl_id,
         l_cache(i).oipl_id,
         l_cache(i).bnft_amt,
         l_cache(i).prtt_enrt_rslt_id,
         l_actn_cd,
         'Y',
         p_business_group_id,
         1);
      --
      If (l_cache(i).prtt_enrt_rslt_id is not NULL) then
        For l_rec in c1(l_cache(i).prtt_enrt_rslt_id) loop
          --
          l_actn := 'Calling ben_batch_dpnt_info_api.create_batch_dpnt_info...';
          insert into ben_batch_dpnt_info
            (batch_dpnt_id,
             person_id,
             benefit_action_id,
             business_group_id,
             pgm_id,
             pl_id,
             oipl_id,
             enrt_cvg_strt_dt,
             enrt_cvg_thru_dt,
             actn_cd,
             object_version_number,
             dpnt_person_id)
          values
            (ben_batch_dpnt_info_s.nextval,
             p_person_id,
             benutils.g_benefit_action_id,
             p_business_group_id,
             l_cache(i).pgm_id,
             l_cache(i).pl_id,
             l_cache(i).oipl_id,
             l_rec.cvg_strt_dt,
             l_rec.cvg_thru_dt,
             l_actn_cd,
             1,
             l_rec.dpnt_person_id);
          --
        End loop;
      End if;
    End loop;
  End if;
  hr_utility.set_location ('Leaving '||l_proc,10);
Exception
  When others then
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => TRUE
                             );
    raise;
End write_person_category;
--
-- ===========================================================================
--                 << Procedure: ben_batch_utils.batch_report >>
-- ===========================================================================
--
Procedure Submit_all_reports
            (p_rpt_flag  in Boolean  default FALSE
            ,p_audit_log in varchar2 default 'N'
            ) is
  l_proc        varchar2(80) := g_package||'.submit_all_reports';
  l_actn        varchar2(80);
  l_request_id  number;
Begin
  hr_utility.set_location ('Entering '||l_proc,05);
  If fnd_global.conc_request_id <> -1 then
    l_actn := 'Calling ben_batch_utils.batch_report (BENDFAUD)...';
    If (p_audit_log = 'Y') then
      ben_batch_utils.batch_report
        (p_concurrent_request_id => fnd_global.conc_request_id
        ,p_program_name          => 'BENDFAUD'
        ,p_request_id            => l_request_id
        );
    End if;
    l_actn := 'Calling ben_batch_utils.batch_report (BENDFSUM)...';
    ben_batch_utils.batch_report
      (p_concurrent_request_id => fnd_global.conc_request_id
      ,p_program_name          => 'BENDFSUM'
      ,p_request_id            => l_request_id
      );
    l_actn := 'Calling ben_batch_utils.batch_report (BENERTYP)...';
    ben_batch_utils.batch_report
      (p_concurrent_request_id => fnd_global.conc_request_id
      ,p_program_name          => 'BENERTYP'
      ,p_request_id            => l_request_id
      ,p_subtitle              =>
          'ERROR DETAIL BY ERROR TYPE'
      );
    l_actn := 'Calling ben_batch_utils.batch_report (BENERPER)...';
    ben_batch_utils.batch_report
      (p_concurrent_request_id => fnd_global.conc_request_id
      ,p_program_name          => 'BENERPER'
      ,p_request_id            => l_request_id
      ,p_subtitle              =>
           'ERROR DETAIL BY PERSON'
      );
  End if;
  hr_utility.set_location ('Leaving '||l_proc,10);
Exception
  When others then
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => p_rpt_flag
                             );
    raise;
End Submit_all_reports;
--
-- ============================================================================
--                        << Procedure: Do_Multithread >>
--  Description:
--  	this is a main procedure to invoke the Default enrollment process.
-- ============================================================================
procedure do_multithread
             (errbuf                     out nocopy varchar2
             ,retcode                    out nocopy number
             ,p_validate              in     varchar2 default 'N'
             ,p_benefit_action_id     in     number
             ,p_thread_id             in     number
             ,p_effective_date        in     varchar2
             ,p_business_group_id     in     number
             ,p_audit_log             in     varchar2 default 'N'
             ) is
 --
 -- Local variable declaration
 --
 l_proc                   varchar2(80) := g_package||'.do_multithread';
 l_person_id              ben_person_actions.person_id%type;
 l_person_action_id       ben_person_actions.person_action_id%type;
 l_object_version_number  ben_person_actions.object_version_number%type;
 l_ler_id                 ben_person_actions.ler_id%type;
 l_range_id               ben_batch_ranges.range_id%type;
 l_record_number          number := 0;
 l_start_person_action_id number := 0;
 l_end_person_action_id   number := 0;
 l_actn                   varchar2(80);
 l_cnt                    number(5):= 0;
 l_chunk_size             number(15);
 l_threads                number(15);
 l_effective_date         date;
 --
 -- Cursors declaration
 --
 Cursor c_range_thread is
   Select ran.range_id
         ,ran.starting_person_action_id
         ,ran.ending_person_action_id
     From ben_batch_ranges ran
    Where ran.range_status_cd = 'U'
      And ran.BENEFIT_ACTION_ID  = P_BENEFIT_ACTION_ID
      And rownum < 2
      For update of ran.range_status_cd
         ;
  Cursor c_person_thread is
    Select ben.person_id
          ,ben.person_action_id
          ,ben.object_version_number
          ,ben.ler_id
      From ben_person_actions ben
     Where ben.benefit_action_id = p_benefit_action_id
       And ben.action_status_cd <> 'P'
       And ben.person_action_id between
              l_start_person_action_id and l_end_person_action_id
     Order by ben.person_action_id
          ;
  Cursor c_parameter is
    Select *
      From ben_benefit_actions ben
     Where ben.benefit_action_id = p_benefit_action_id
          ;
  l_parm c_parameter%rowtype;
  l_commit number;
  --
Begin
  --
  hr_utility.set_location ('Entering '||l_proc,05);
  --
  l_effective_date := fnd_date.canonical_to_date(p_effective_date);
  --
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  l_actn := 'Calling benutils.get_parameter...';
  benutils.get_parameter(p_business_group_id  => p_business_group_Id
                        ,p_batch_exe_cd       => 'BENEADEB'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed                          );
  --
  -- Set up benefits environment
  --
  ben_env_object.init(p_business_group_id => p_business_group_id,
                      p_effective_date    => l_effective_date,
                      p_thread_id         => p_thread_id,
                      p_chunk_size        => l_chunk_size,
                      p_threads           => l_threads,
                      p_max_errors        => g_max_errors_allowed,
                      p_benefit_action_id => p_benefit_action_id);
  --
  l_actn := 'Calling ben_batch_utils.ini...';
  ben_batch_utils.ini;
  --
  -- Copy benefit action id to global in benutils package
  --
  benutils.g_benefit_action_id := p_benefit_action_id;
  benutils.g_thread_id         := p_thread_id;
  g_persons_errored            := 0;
  g_persons_procd              := 0;
  open c_parameter;
  fetch c_parameter into l_parm;
  close c_parameter;
  --
  l_actn := 'Calling ben_batch_utils.print_parameters...';
  --
  ben_batch_utils.print_parameters
          (p_thread_id                => p_thread_id
          ,p_benefit_action_id        => p_benefit_action_id
          ,p_validate                 => p_validate
          ,p_business_group_id        => p_business_group_id
          ,p_effective_date           => l_effective_date
          ,p_popl_enrt_typ_cycl_id    => l_parm.popl_enrt_typ_cycl_id
          ,p_person_id                => l_parm.person_id
          ,p_person_selection_rule_id => l_parm.person_selection_rl
          ,p_person_type_id           => l_parm.person_type_id
          ,p_ler_id                   => l_parm.ler_id
          ,p_organization_id          => l_parm.organization_id
          ,p_benfts_grp_id            => l_parm.benfts_grp_id
          ,p_location_id              => l_parm.location_id
          ,p_legal_entity_id          => l_parm.legal_entity_id
          ,p_payroll_id               => l_parm.payroll_id
          ,p_audit_log                => l_parm.audit_log_flag
          );
  --
  -- While loop to only try and fetch records while they exist
  -- we always try and fetch the size of the chunk, if we get less
  -- then we know that the process is finished so we end the while loop.
  -- The process is as follows :
  -- 1) Lock the rows that are not processed
  -- 2) Grab as many rows as we can upto the chunk size
  -- 3) Put each row into the person cache.
  -- 4) Process the person cache
  -- 5) Go to number 1 again.
  --
  Loop
    l_actn := 'Opening c_range thread and fetch range...';
    open c_range_thread;
    fetch c_range_thread into l_range_id
                             ,l_start_person_action_id
                             ,l_end_person_action_id;
    exit when c_range_thread%notfound;
    close c_range_thread;
    If(l_range_id is not NULL) then
      --
      l_actn := 'Updating ben_batch_ranges row...';
      --
      update ben_batch_ranges ran set ran.range_status_cd = 'P'
         where ran.range_id = l_range_id;
      commit;
    End if;
    --
    -- Remove all records from cache
    --
    l_actn := 'Clearing g_cache_person_process cache...';
    g_cache_person_process.delete;
    open c_person_thread;
    l_record_number := 0;
    Loop
      --
      l_actn := 'Loading person data into g_cache_person_process cache...';
      --
      fetch c_person_thread
        into g_cache_person_process(l_record_number+1).person_id
            ,g_cache_person_process(l_record_number+1).person_action_id
            ,g_cache_person_process(l_record_number+1).object_version_number
            ,g_cache_person_process(l_record_number+1).ler_id;
      exit when c_person_thread%notfound;
      l_record_number := l_record_number + 1;
    End loop;
    close c_person_thread;
    --
    l_actn := 'Preparing to default each participant from cache...' ;
    --
    If l_record_number > 0 then
      --
      -- Process the rows from the person process cache
      --
      For l_cnt in 1..l_record_number loop
        Begin
          ben_manage_default_enrt.process_default_enrt
            (p_validate              => p_validate
            ,p_person_id             => g_cache_person_process(l_cnt).person_id
            ,p_business_group_id     => p_business_group_id
            ,p_effective_date        => l_effective_date
            ,p_person_action_id      => g_cache_person_process(l_cnt).person_action_id
            ,p_object_version_number => g_cache_person_process(l_cnt).object_version_number
            ,p_audit_log             => p_audit_log
            );
          --
        Exception
            When others then
              If (g_persons_errored > g_max_errors_allowed) then
                  fnd_message.raise_error;
              End if;
        End;
      End loop;
    Else
      --
      l_actn := 'Erroring out nocopy since not person is found in range...' ;
      --
      fnd_message.set_name('BEN','BEN_91709_PER_NOT_FND_IN_RNG');
      fnd_message.set_token('PROCEDURE',l_proc);
      fnd_message.raise_error;
    End if;
    commit;
  End loop;
  benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
  commit;
  --
  l_actn := 'Calling Log_beneadeb_statistics...';
  ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_procd
                               ,p_num_pers_errored   => g_persons_errored
                               );
  hr_utility.set_location ('Leaving '||l_proc,70);
Exception
  When others then
    ben_batch_utils.rpt_error(p_proc       => l_proc
                             ,p_last_actn  => l_actn
                             ,p_rpt_flag   => TRUE
                             );
    ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_procd
                                 ,p_num_pers_errored   => g_persons_errored
                                 );
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    commit;
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP',l_actn );
    fnd_message.raise_error;
    --
end do_multithread;
--
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                   << Procedure: Restart >>
-- *****************************************************************
--
procedure restart (errbuf                 out nocopy varchar2
                  ,retcode                out nocopy number
                  ,p_benefit_action_id in     number
                  ) is
  --
  -- Cursor Declaration
  --
  cursor c_parameters is
    Select -- to_char(process_date,'YYYY/MM/DD HH24:MI:SS') process_date
           fnd_date.date_to_canonical(process_date) process_date
          ,validate_flag
          ,person_id
          ,person_type_id
          ,pgm_id
          ,business_group_id
          ,pl_id
          ,popl_enrt_typ_cycl_id
          ,person_selection_rl
          ,ler_id
          ,organization_id
          ,benfts_grp_id
          ,location_id
          ,legal_entity_id
          ,payroll_id
          ,debug_messages_flag
          ,audit_log_flag
      From ben_benefit_actions ben
     Where ben.benefit_action_id = p_benefit_action_id;
  --
  -- Local Variable declaration.
  --
  l_proc        varchar2(80) := g_package||'.restart';
  l_parameters	c_parameters%rowtype;
  l_errbuf      varchar2(80);
  l_retcode     number;
  l_actn        varchar2(80);
Begin
    hr_utility.set_location ('Entering '||l_proc,10);
    --
    -- get the parameters for a previous run and do a restart
    --
    l_actn := 'Getting parameter data...';
    open c_parameters;
    fetch c_parameters into l_parameters;
    If c_parameters%notfound then
        ben_batch_utils.rpt_error(p_proc      => l_proc
                                 ,p_last_actn => l_actn
                                 ,p_rpt_flag  => TRUE
                                 );
        fnd_message.set_name('BEN','BEN_91710_RESTRT_PARMS_NOT_FND');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.raise_error;
    End if;
    close c_parameters;
    --
    -- Call process procedure with parameters for restart
    --
    l_actn := 'Calling process...';
    Process (errbuf                     => l_errbuf
            ,retcode                    => l_retcode
            ,p_benefit_action_id        => p_benefit_action_id
            ,p_effective_date           => l_parameters.process_date
            ,p_validate                 => l_parameters.validate_flag
            ,p_person_id                => l_parameters.person_id
            ,p_person_type_id           => l_parameters.person_type_id
            ,p_business_group_id        => l_parameters.business_group_id
            ,p_popl_enrt_typ_cycl_id    => l_parameters.popl_enrt_typ_cycl_id
            ,p_ler_id                   => l_parameters.ler_id
            ,p_organization_id          => l_parameters.organization_id
            ,p_benfts_grp_id            => l_parameters.benfts_grp_id
            ,p_location_id              => l_parameters.location_id
            ,p_legal_entity_id          => l_parameters.legal_entity_id
            ,p_payroll_id               => l_parameters.payroll_id
            ,p_debug_messages           => l_parameters.debug_messages_flag
            ,p_audit_log                => l_parameters.audit_log_flag
            );
    hr_utility.set_location ('Leaving '||l_proc,70);
Exception
    when others then
        ben_batch_utils.rpt_error(p_proc      => l_proc
                                 ,p_last_actn => l_actn
                                 ,p_rpt_flag  => TRUE
                                 );
        raise;
end restart;
--
-- *************************************************************************
-- *                          << Procedure: Process >>
-- *************************************************************************
--
procedure process(errbuf                     out nocopy varchar2
                 ,retcode                    out nocopy number
                 ,p_benefit_action_id        in  number
                 ,p_effective_date           in  varchar2
                 ,p_validate                 in  varchar2 default 'N'
                 ,p_person_id                in  number   default null
                 ,p_person_type_id           in  number   default null
                 ,p_business_group_id        in  number
                 ,p_popl_enrt_typ_cycl_id    in  number   default null
                 ,p_person_selection_rule_id in  number   default null
                 ,p_ler_id                   in  number   default null
                 ,p_organization_id          in  number   default null
                 ,p_benfts_grp_id            in  number   default null
                 ,p_location_id              in  number   default null
                 ,p_legal_entity_id          in  number   default null
                 ,p_payroll_id               in  number   default null
                 ,p_debug_messages           in  varchar2 default 'N'
                 ,p_audit_log                in  varchar2 default 'N') is
  --
  -- local variable declaration.
  --
  l_effective_date         date;
  l_request_id             number;
  l_proc                   varchar2(80) := g_package||'.process';
  l_benefit_action_id      ben_benefit_actions.benefit_action_id%type;
  l_object_version_number  ben_benefit_actions.object_version_number%type;
  l_person_id_out          per_people_f.person_id%type;
  l_range_id               ben_batch_ranges.range_id%type;
  l_chunk_size             number;
  l_threads                number;
  l_start_person_action_id number := 0;
  l_end_person_action_id   number := 0;
  l_rule_value             varchar2(30);
  l_skip                   boolean;
  l_actn                   varchar2(80);
  l_num_ranges             number := 0;
  l_num_rows               number := 0;
  l_num_persons            number := 0;
  l_commit                 number;
  --
  -- Cursors declaration.
  --
  --
  -- Bug fix 2828045 - uncommented the BG id check =>
  --	pil.business_group_id = p_business_group_id, and added
  --	check for filtering out PILs of type COMP and ABS, since these
  --	PILs should not be considered for Default Enrt Process.
  -- 	Also, fixed the p_ler_id comparison clause along with this.
  --	The p_ler_id param is compared with pil.per_in_ler_id instead
  --	of pil.ler_id
  --
  cursor c_person is
    select pil.person_id
    from   ben_per_in_ler pil
    where
      pil.business_group_id = p_business_group_id		-- 2828045
    and    pil.per_in_ler_id in
           (select pel.per_in_ler_id
            from   ben_pil_elctbl_chc_popl pel
            where  pel.business_group_id = pil.business_group_id
            and    pel.per_in_ler_id = pil.per_in_ler_id
            and    pel.dflt_enrt_dt  <=  l_effective_date
	    and    pel.dflt_asnd_dt is NULL
            and    pel.ELCNS_MADE_DT is NULL)
    and    pil.per_in_ler_stat_cd = 'STRTD'
    and    (p_person_id is NULL or pil.person_id = p_person_id)
    -- and    (p_ler_id is NULL or pil.per_in_ler_id = p_ler_id) -- 2828045
    and    (p_ler_id is NULL or pil.ler_id = p_ler_id)
    and    exists (select null 					-- 2828045
		   from ben_ler_f ler
		   where ler.ler_id = pil.ler_id
		   and   ler.typ_cd not in ('COMP','ABS','GSP')
		   and   l_effective_date
			 between ler.effective_start_date
			 and     ler.effective_end_date
		  )
    and    (p_person_type_id is null
            or exists (select null
                       from   per_person_type_usages ptu
                       where  ptu.person_id = pil.person_id
                       and    ptu.person_type_id = p_person_type_id))
    -- Bug : 2170794 Commented the code below and added the new clauses .
/*  and    ((p_location_id is null
             and p_organization_id is null
             and p_legal_entity_id is null
             and p_payroll_id is null)
            or exists (select null
                       from   per_all_assignments_f asg
                       where  nvl(asg.location_id,hr_api.g_number) =
                              nvl(p_location_id,hr_api.g_number)
                       and    nvl(asg.organization_id,hr_api.g_number) =
                              nvl(p_organization_id,hr_api.g_number)
                       and    nvl(asg.soft_coding_keyflex_id,hr_api.g_number) =
                              nvl(p_legal_entity_id,hr_api.g_number)
                       and    nvl(asg.payroll_id, hr_api.g_number)=
                              nvl(p_payroll_id,hr_api.g_number)
                       and    asg.person_id = pil.person_id
                       and    asg.primary_flag = 'Y'
                       and    asg.business_group_id = pil.business_group_id
                       and    l_effective_date
                              between asg.effective_start_date
                              and     asg.effective_end_date))
*/
    and    ((p_location_id is null )
            or exists (select null
                       from   per_all_assignments_f asg
                       where  asg.location_id = p_location_id
                       and    asg.person_id = pil.person_id
                       and    asg.assignment_type <> 'C'
                       and    asg.primary_flag = 'Y'
                       and    asg.business_group_id = pil.business_group_id
                       and    l_effective_date
                              between asg.effective_start_date and  asg.effective_end_date))
    and    (( p_organization_id is null )
            or exists (select null
                       from   hr_organization_units org,
                              per_all_assignments_f asg
                       where  asg.organization_id = org.organization_id
                       and    org.organization_id = p_organization_id
                       and    l_effective_date
                              between org.date_from and nvl(org.date_to,l_effective_date )
                       and    asg.person_id = pil.person_id
                       and    asg.assignment_type <> 'C'
                       and    asg.primary_flag = 'Y'
                       and    asg.business_group_id = pil.business_group_id
                       and    l_effective_date
                              between asg.effective_start_date and asg.effective_end_date))
    and    (( p_legal_entity_id is null )
            or exists (select null
                       from hr_soft_coding_keyflex hsc,
                            per_all_assignments_f asg
                       where asg.person_id = pil.person_id
                       and   asg.assignment_type <> 'C'
                       and asg.primary_flag = 'Y'
                       and asg.business_group_id = pil.business_group_id
                       and l_effective_date
                           between asg.effective_start_date and asg.effective_end_date
                       and asg.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
                       and hsc.segment1 = to_char(p_legal_entity_id)))
    and    (( p_payroll_id is null)
            or exists (select null
                       from   pay_payrolls_f pay,
                              per_all_assignments_f asg
                       where  asg.person_id = pil.person_id
                       and   asg.assignment_type <> 'C'
                       and    asg.primary_flag = 'Y'
                       and    asg.business_group_id = pil.business_group_id
                       and    l_effective_date
                              between asg.effective_start_date  and  asg.effective_end_date
                       and    pay.payroll_id = p_payroll_id
                       and    pay.payroll_id = asg.payroll_id
                       and    l_effective_date
                              between pay.effective_start_date and pay.effective_end_date ))
-- Bug : 2170794
    and    (p_benfts_grp_id is null
            or exists (select null
                       from   ben_benfts_grp bng,
                              per_all_people_f ppf
                       where  bng.benfts_grp_id = p_benfts_grp_id
                       And    bng.business_group_id = pil.business_group_id
                       And    ppf.person_id = pil.person_id
                       And    ppf.benefit_group_id = bng.benfts_grp_id
                       And    l_effective_date
                              between ppf.effective_start_date
                              and     ppf.effective_end_date));
  --
  l_person_action_id           l_number_type := l_number_type();
  l_person_id                  l_number_type := l_number_type();
  l_silent_error exception;
  --
Begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  -- Bug 5857493
  if p_audit_log ='Y' then
     ben_batch_utils.g_audit_flag := true;
  else
     ben_batch_utils.g_audit_flag := false;
  end if;
  --
  l_effective_date := fnd_date.canonical_to_date(p_effective_date);
  --
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  l_actn := 'Initialize the ben_batch_utils cache...';
  --
  ben_batch_utils.ini(p_actn_cd => 'PROC_INFO');
  --
  -- Get chunk_size and Thread values for multi-thread process, and check to
  --
  l_actn := 'Calling benutils.get_parameter...';
  benutils.get_parameter(p_business_group_id  => p_business_group_Id
                        ,p_batch_exe_cd       => 'BENEADEB'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed);
  --
  benutils.g_benefit_action_id := p_benefit_action_id;
  benutils.g_thread_id         := 99;
  --
  -- Create benefit actions parameters in the benefit action table.
  -- Do not create if a benefit action already exists, in other words
  -- we are doing a restart.
  --
  if p_benefit_action_id is null then
    --
    ben_benefit_actions_api.create_perf_benefit_actions
      (p_validate               => false
      ,p_benefit_action_id      => l_benefit_action_id
      ,p_process_date           => l_effective_date
      ,p_mode_cd                => 'S'
      ,p_derivable_factors_flag => 'N'
      ,p_validate_flag          => p_validate
      ,p_person_id              => p_person_id
      ,p_person_type_id         => p_person_type_id
      ,p_pgm_id                 => NULL
      ,p_business_group_id      => p_business_group_id
      ,p_pl_id                  => NULL
      ,p_popl_enrt_typ_cycl_id  => p_popl_enrt_typ_cycl_id
      ,p_no_programs_flag       => 'N'
      ,p_no_plans_flag          => 'N'
      ,p_comp_selection_rl      => NULL
      ,p_person_selection_rl    => p_person_selection_rule_id
      ,p_ler_id                 => p_ler_id
      ,p_organization_id        => p_organization_id
      ,p_benfts_grp_id          => p_benfts_grp_id
      ,p_location_id            => p_location_id
      ,p_pstl_zip_rng_id        => NULL
      ,p_rptg_grp_id            => NULL
      ,p_pl_typ_id              => NULL
      ,p_opt_id                 => NULL
      ,p_eligy_prfl_id          => NULL
      ,p_vrbl_rt_prfl_id        => NULL
      ,p_legal_entity_id        => p_legal_entity_id
      ,p_payroll_id             => p_payroll_id
      ,p_audit_log_flag         => p_audit_log
      ,p_debug_messages_flag    => p_debug_messages
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_effective_date
      ,p_request_id             => fnd_global.conc_request_id
      ,p_program_application_id => fnd_global.prog_appl_id
      ,p_program_id             => fnd_global.conc_program_id
      ,p_program_update_date    => sysdate);
    --
    benutils.g_benefit_action_id := l_benefit_action_id;
    --
    -- Now lets create person actions for all the people we are going to
    -- process in the BENEADEB run.
    --
    open c_person;
      --
      l_actn := 'Loading person_actions table..';
      --
      loop
        --
        fetch c_person into l_person_id_out;
        exit when c_person%notfound;
        --
        l_skip := FALSE;
        --
        if p_person_selection_rule_id is not null then
          --
          l_actn := 'Calling Ben_batch_utils.person_selection_rule...';
          l_rule_value :=
             ben_batch_utils.person_selection_rule
               (p_person_id               => l_person_id_out
               ,p_business_group_id       => p_business_group_id
               ,p_person_selection_rule_id=> p_person_selection_rule_id
               ,p_effective_date          => l_effective_date);
          --
          if l_rule_value = 'N' then
            --
            l_skip := TRUE;
	    --
          elsif l_rule_value = 'Y' then  -- Bug 5662220
            --
            l_skip := FALSE;
            --
	  else
            --
	      l_skip := TRUE;	         -- Bug 5662220
            --
          end if;
          --
        end if;
        --
        -- Store person_id into person actions table.
        --
        if not l_skip then
          --
          l_num_persons := l_num_persons + 1;
          l_num_rows := l_num_rows + 1;
          --
          -- Extend person_action_id type
          --
          l_person_action_id.extend(1);
          --
          -- Get Primary Key value
          --
          select ben_person_actions_s.nextval
          into   l_person_action_id(l_num_rows)
          from   sys.dual;
          --
          -- Extend person_id type
          --
          l_person_id.extend(1);
          l_person_id(l_num_rows) := l_person_id_out;
          --
          if l_num_rows = l_chunk_size then
            --
            -- Bulk bind in person actions
            --
            forall l_count in 1..l_num_rows
              --
              insert into ben_person_actions
                (person_action_id,
                 person_id,
                 ler_id,
                 benefit_action_id,
                 action_status_cd,
                 object_version_number)
              values
                (l_person_action_id(l_count),
                 l_person_id(l_count),
                 0,
                 l_benefit_action_id,
                 'U',
                 1);
            --
            l_num_ranges := l_num_ranges + 1;
            --
            -- Select next sequence number for the range
            --
            select ben_batch_ranges_s.nextval
            into   l_range_id
            from   sys.dual;
            --
            -- Calculate start and end points of the range
            --
            l_start_person_action_id := l_person_action_id(1);
            l_end_person_action_id := l_person_action_id(l_num_rows);
            --
            insert into ben_batch_ranges
              (range_id,
               benefit_action_id,
               range_status_cd,
               starting_person_action_id,
               ending_person_action_id,
               object_version_number)
            values
              (l_range_id,
               l_benefit_action_id,
               'U',
               l_start_person_action_id,
               l_end_person_action_id,
               1);
            --
            l_num_rows := 0;
            --
            -- Dispose of varray
            --
            l_person_action_id.delete;
            l_person_id.delete;
            --
            commit;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    close c_person;
    --
    if l_num_rows <> 0 then
      --
      forall l_count in 1..l_num_rows
      --
      -- Bulk bind in person actions
      --
      insert into ben_person_actions
        (person_action_id,
         person_id,
         ler_id,
         benefit_action_id,
         action_status_cd,
         object_version_number)
      values
        (l_person_action_id(l_count),
         l_person_id(l_count),
         0,
         l_benefit_action_id,
         'U',
         1);
      --
      l_num_ranges := l_num_ranges + 1;
      --
      -- Get next sequence for the range
      --
      select ben_batch_ranges_s.nextval
      into   l_range_id
      from   sys.dual;
      --
      l_start_person_action_id := l_person_action_id(1);
      l_end_person_action_id := l_person_action_id(l_num_rows);
      --
      insert into ben_batch_ranges
        (range_id,
         benefit_action_id,
         range_status_cd,
         starting_person_action_id,
         ending_person_action_id,
         object_version_number)
      values
        (l_range_id,
         l_benefit_action_id,
         'U',
         l_start_person_action_id,
         l_end_person_action_id,
         1);
      --
      l_num_rows := 0;
      --
      -- Dispose of data in varrays
      --
      l_person_action_id.delete;
      l_person_id.delete;
      --
      commit;
      --
    end if;
    --
  Else
    --
    l_benefit_action_id := p_benefit_action_id;
    l_actn := 'Calling Ben_batch_utils.create_restart_person_actions...';
    --
    Ben_batch_utils.create_restart_person_actions
      (p_benefit_action_id  => p_benefit_action_id
      ,p_effective_date     => l_effective_date
      ,p_chunk_size         => l_chunk_size
      ,p_threads            => l_threads
      ,p_num_ranges         => l_num_ranges
      ,p_num_persons        => l_num_persons);
    --
  End if;
  --
  commit;
  --
  -- Now to multithread the code.
  --
  If l_num_ranges > 1 then
    --
    For l_count in 1..least(l_threads,l_num_ranges)-1 loop
      --
      l_actn := 'Submitting job to con-current manager...';
      l_request_id := fnd_request.submit_request
                        (application => 'BEN'
                        ,program     => 'BENDFLT'
                        ,description => NULL
                        ,sub_request => FALSE
                        ,argument1   => p_validate
                        ,argument2   => l_benefit_action_id
                        ,argument3   => l_count
                        ,argument4   => p_effective_date
                        ,argument5   => p_business_group_id
                        ,argument6   => p_audit_log);
      --
      -- Store the request id of the concurrent request
      --
      ben_batch_utils.g_num_processes := ben_batch_utils.g_num_processes + 1;
      ben_batch_utils.g_processes_tbl(ben_batch_utils.g_num_processes)
        := l_request_id;
      --
      commit;
      --
    End loop;
    --
  Elsif (l_num_ranges = 0 ) then
    --
    l_actn := 'Calling Ben_batch_utils.print_parameters...';
    --
    Ben_batch_utils.print_parameters
      (p_thread_id                => 99
      ,p_benefit_action_id        => l_benefit_action_id
      ,p_validate                 => p_validate
      ,p_business_group_id        => p_business_group_id
      ,p_effective_date           => l_effective_date
      ,p_popl_enrt_typ_cycl_id    => p_popl_enrt_typ_cycl_id
      ,p_person_id                => p_person_id
      ,p_person_selection_rule_id => p_person_selection_rule_id
      ,p_person_type_id           => p_person_type_id
      ,p_ler_id                   => p_ler_id
      ,p_organization_id          => p_organization_id
      ,p_benfts_grp_id            => p_benfts_grp_id
      ,p_location_id              => p_location_id
      ,p_legal_entity_id          => p_legal_entity_id
      ,p_payroll_id               => p_payroll_id
      ,p_audit_log                => p_audit_log);
    --
    Ben_batch_utils.write(p_text =>
        '<< No Person got selected with above selection criteria >>' );
    fnd_message.set_name('BEN','BEN_91769_NOONE_TO_PROCESS');
    fnd_message.set_token('PROC',l_proc);
    raise l_silent_error;
    --
  End if;
  --
  l_actn := 'Calling do_multithread...';
  --
  do_multithread(errbuf               => errbuf
                ,retcode              => retcode
                ,p_validate           => p_validate
                ,p_benefit_action_id  => l_benefit_action_id
                ,p_thread_id          => l_threads+1
                ,p_effective_date     => p_effective_date
                ,p_business_group_id  => p_business_group_id
                ,p_audit_log          => p_audit_log);
  --
  l_actn := 'Calling ben_batch_utils.check_all_slaves_finished...';
  ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
  --
  l_actn := 'Calling ben_batch_utils.End_process...';
  ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                             ,p_person_selected   => l_num_persons
                             ,p_business_group_id => p_business_group_id);
  --
  l_actn := 'Calling submit_all_reports...';
  submit_all_reports(p_audit_log => p_audit_log);
  --
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
Exception
  --
  when l_silent_error then
     ben_batch_utils.write(p_text => fnd_message.get);
     benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
     If (l_num_ranges > 0) then
       ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
       ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                                  ,p_person_selected   => l_num_persons
                                  ,p_business_group_id => p_business_group_id);
       submit_all_reports(p_audit_log => p_audit_log);
     End if;
     --
  when others then
     ben_batch_utils.rpt_error(p_proc      => l_proc
                              ,p_last_actn => l_actn
                              ,p_rpt_flag  => TRUE   );
     ben_batch_utils.write(p_text => fnd_message.get);
     ben_batch_utils.write(p_text => sqlerrm);
     ben_batch_utils.write(p_text => 'Big Error Occured');
     benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
     If (l_num_ranges > 0) then
       ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
       ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                                  ,p_person_selected   => l_num_persons
                                  ,p_business_group_id => p_business_group_id);
       submit_all_reports(p_audit_log => p_audit_log);
     End if;
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE', l_proc);
     fnd_message.set_token('STEP', l_actn );
     fnd_message.raise_error;
End process;
--
-- ============================================================================
--                   << Procedure: Default_comp_obj>>
-- ============================================================================
Procedure Default_Comp_obj
                  (p_validate           in  Boolean default FALSE
                  ,p_per_in_ler_id      in  Number
                  ,p_person_id          in  Number
                  ,p_business_group_id  in  Number
                  ,p_effective_date     in  Date
                  ,p_pgm_id             in  Number
                  ,p_pl_nip_id          in  Number
                  ,p_susp_flag          out nocopy Boolean
                  ,p_batch_flag         in  Boolean default FALSE
                  ,p_cls_enrt_flag      in  Boolean default TRUE
		  ,p_called_frm_ss      in  Boolean default FALSE
		  ,p_reinstate_dflts_flag in varchar2 default 'N' -- Enhancement Bug :8716679
		  ,p_prev_per_in_ler_id in Number default null --  -- Enhancement Bug :8716679
                  ) is

   l_prev_pil_id number;

  -- in_pndg_wkflow_flag added to block electable choice in pending workflow not to be assigned
  Cursor c_dflt_mn_epe is
    Select epe.ELIG_PER_ELCTBL_CHC_ID
          ,epe.PGM_ID
          ,epe.PL_ID
          ,epe.OIPL_ID
          ,epe.DPNT_CVG_STRT_DT_CD
          ,epe.DPNT_CVG_STRT_DT_RL
          ,epe.ENRT_CVG_STRT_DT
          ,epe.CRYFWD_ELIG_DPNT_CD
          ,epe.CRNTLY_ENRD_FLAG
          ,epe.DFLT_FLAG
          ,epe.ELCTBL_FLAG
          ,epe.MNDTRY_FLAG
          ,epe.AUTO_ENRT_FLAG
          ,epe.PRTT_ENRT_RSLT_ID
          ,epe.BUSINESS_GROUP_ID
          ,'DEF' actn_cd
          ,'N' Suspended
          ,epe.in_pndg_wkflow_flag
      From ben_elig_per_elctbl_chc epe
     Where epe.Auto_enrt_flag = 'N'
       and epe.per_in_ler_id = p_per_in_ler_id
       and epe.Business_group_id = p_business_group_id
       and (epe.elctbl_flag = 'Y' or epe.mndtry_flag = 'Y')
       and (p_pgm_id is NULL or epe.pgm_id = p_pgm_id)
       and (p_pl_nip_id is null
             or (p_pl_nip_id = epe.pl_id and epe.pgm_id is NULL) )
       /* Modified the condition for  Enhancement Bug :8716679. Defaulting the explicit elections
       will only be called if p_reinstate_dflts_flag = 'Y' or else normal defaulting logic will work.*/
       and ( (p_reinstate_dflts_flag = 'N' and (epe.dflt_flag = 'Y' or  epe.crntly_enrd_flag = 'Y') ) or
             (p_reinstate_dflts_flag = 'Y' and epe.crntly_enrd_flag = 'Y' and prtt_enrt_rslt_id is not null
	        and 'Y' = ( select 'Y' from ben_prtt_enrt_rslt_f pen
	                where pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
			and pen.per_in_ler_id = p_prev_per_in_ler_id
			and pen.prtt_enrt_rslt_stat_cd is null
			and pen.enrt_mthd_cd = 'E'
			and pen.sspndd_flag = 'N'
                        and not exists
                         (select 'Y' from ben_prtt_enrt_rslt_f pen2
                           where pen.prtt_enrt_rslt_id = pen2.rplcs_sspndd_rslt_id
                                 and pen2.prtt_enrt_rslt_stat_cd is null
                                 and pen2.per_in_ler_id = p_prev_per_in_ler_id) )
	     )               )
       /* End of change for  Enhancement Bug :8716679    */
       and not exists (select null from ben_prtt_enrt_rslt_f pen
             where pen.per_in_ler_id = epe.per_in_ler_id
             -- Bug 6319484 Instead of checking for same pen_id,
             -- check if not already enrolled in same plan
 	       and nvl(pen.pgm_id,hr_api.g_number) = nvl(epe.pgm_id,hr_api.g_number)
               and pen.pl_id = epe.pl_id
             --  and pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
               and pen.prtt_enrt_rslt_stat_cd IS NULL
               and pen.effective_end_date = hr_api.g_eot
               and pen.enrt_cvg_thru_dt   = hr_api.g_eot )
     order by epe.pgm_id, epe.pl_id;

    cursor c_test(c_pen_id number) is
    select pen.prtt_enrt_rslt_id||'Y' from ben_prtt_enrt_rslt_f pen
	                where pen.prtt_enrt_rslt_id = c_pen_id
			and pen.per_in_ler_id = l_prev_pil_id
			and pen.prtt_enrt_rslt_stat_cd is null
			and pen.enrt_mthd_cd = 'E'
			and pen.sspndd_flag = 'N'
                        and not exists
                         (select 'Y' from ben_prtt_enrt_rslt_f pen2
                           where pen.prtt_enrt_rslt_id = pen2.rplcs_sspndd_rslt_id
                                 and pen2.prtt_enrt_rslt_stat_cd is null
                                 and pen2.per_in_ler_id = l_prev_pil_id);
   l_test varchar2(100);

  Cursor c_dflt_mn_epe_mndtry (c_pgm_id number, c_pl_id number)  is
    Select epe.ELIG_PER_ELCTBL_CHC_ID
          ,epe.PGM_ID
          ,epe.PL_ID
          ,epe.OIPL_ID
          ,epe.DPNT_CVG_STRT_DT_CD
          ,epe.DPNT_CVG_STRT_DT_RL
          ,epe.ENRT_CVG_STRT_DT
          ,epe.CRYFWD_ELIG_DPNT_CD
          ,epe.CRNTLY_ENRD_FLAG
          ,epe.DFLT_FLAG
          ,epe.ELCTBL_FLAG
          ,epe.MNDTRY_FLAG
          ,epe.AUTO_ENRT_FLAG
          ,epe.PRTT_ENRT_RSLT_ID
          ,epe.BUSINESS_GROUP_ID
          ,'DEF' actn_cd
          ,'N' Suspended
          ,epe.in_pndg_wkflow_flag
      From ben_elig_per_elctbl_chc epe
     Where epe.dflt_flag = 'N'
       and epe.crntly_enrd_flag = 'N'
       and epe.mndtry_flag = 'Y'
       and epe.Auto_enrt_flag = 'N'
       and epe.per_in_ler_id = p_per_in_ler_id
       and epe.Business_group_id = p_business_group_id
       and nvl(epe.pgm_id,hr_api.g_number) = nvl(c_pgm_id, hr_api.g_number)
       and epe.pl_id  = c_pl_id
       and comp_lvl_cd = 'OIPL';                -- Bug 4951065
  --
  Cursor c_pen (lc_prtt_enrt_rslt_id number) is
    Select prtt_enrt_rslt_id
          ,effective_start_date
          ,effective_end_date
          ,object_version_number
          ,bnft_amt
          ,uom
          ,enrt_mthd_cd
          ,business_group_id
          ,enrt_cvg_strt_dt
          ,enrt_cvg_thru_dt
          ,ERLST_DEENRT_DT
          ,enrt_ovrid_thru_dt
          ,enrt_ovridn_flag
      From ben_prtt_enrt_rslt_f
      Where prtt_enrt_rslt_id = lc_prtt_enrt_rslt_id
        and p_effective_date between
              effective_start_date and effective_end_date
        and prtt_enrt_rslt_stat_cd IS NULL
        and business_group_id = p_business_group_id
           ;
  l_pen c_pen%ROWTYPE;
  --
  Cursor c_rt (v_elig_per_elctbl_chc_id number) is
    Select ecr.enrt_rt_id
          ,nvl(ecr.val,ecr.dflt_val) default_val
          ,ecr.ANN_DFLT_VAL
      From ben_enrt_rt ecr
     Where ecr.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
       and ecr.business_group_id = p_business_group_id
       and ecr.entr_val_at_enrt_flag = 'Y'
    --   and ecr.prtt_rt_val_id is null   -- ikasire bug 1834655
  Union
    Select ecr.enrt_rt_id
          ,nvl(ecr.val,ecr.dflt_val) default_val
          ,ecr.ANN_DFLT_VAL
     From ben_enrt_rt ecr
         ,ben_enrt_bnft enb
    Where enb.enrt_bnft_id = ecr.enrt_bnft_id
      and ecr.business_group_id = p_business_group_id
      and enb.business_group_id = p_business_group_id
      and enb.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
      and ecr.entr_val_at_enrt_flag = 'Y'
 --      and ecr.prtt_rt_val_id is null     --  ikasire bug 1834655
         ;
  --
  Cursor c_bnft (l_elig_per_elctbl_chc_id number) is
    Select enrt_bnft_id, val, dflt_val, entr_val_at_enrt_flag,cvg_mlt_cd
      From ben_enrt_bnft
     Where elig_per_elctbl_chc_id = l_elig_per_elctbl_chc_id
       and dflt_flag = 'Y'
          ;
  Type enrt_id_table is table of c_rt%rowtype index by binary_integer;
  Type epe_table is table of c_dflt_mn_epe%rowtype index by binary_integer;
  --
  -- Local Variables
  --
  l_proc                 varchar2(80) := g_package || '.Default_comp_obj';
  l_output_string        varchar2(80);
  l_validate             boolean;
  l_actn                 varchar2(80);
  l_rt                   enrt_id_table;
  l_tot_rt               number(5) := 0;
  l_bnft_amt             ben_enrt_bnft.val%type;
  l_dflt_bnft_amt        ben_enrt_bnft.val%type;
  l_entr_flag            varchar2(1);
  l_bnft_id              ben_enrt_bnft.enrt_bnft_id%type;
  l_suspend_flag         varchar2(30);
  l_prtt_enrt_interim_id number(15);
  l_datetrack_mode       varchar2(30);
  l_effective_start_date date;
  l_effective_end_date   date;
  l_dump_num             number(15);
  l_dump_boolean         boolean;
  l_epe                  epe_table;
  l_epe_cnt              binary_integer := 0;
  l_prev_pgm_id          number := -999999;
  l_prev_pl_id           number := -999999;
  l_actn_cd              varchar2(30);
  l_cvg_mlt_cd           varchar2(30) := null ;
  l_cryfwd_elig_dpnt_cd  varchar2(30);
  l_prev_rslt_id_at      number := 0 ;
  l_prev_prtt_enrt_rslt_id number ;
  l_not_ovridn           boolean := true ;
  l_global_pil_rec ben_global_enrt.g_global_pil_rec_type; -- 4684991
  l_rdefault_table_cnt number;

Begin
  hr_utility.set_location ('Entering '|| l_proc , 5);

  l_actn := 'Openning c_dflt_mn_epe cursor...';
  hr_utility.set_location (l_actn , 10);
  p_susp_flag  := FALSE;

  -- Bug - 4684991 - Fetch pil details
  ben_global_enrt.get_pil
       (p_per_in_ler_id          => p_per_in_ler_id
       ,p_global_pil_rec         => l_global_pil_rec);
  --
  --
  -- Retreive Records from Elig_per_elctbl_chc Table.
  --
  --

  For l_rec in c_dflt_mn_epe loop
    --hr_utility.set_location (l_actn , 11);
     hr_utility.set_location ('l_rec.prtt_enrt_rslt_id '|| l_rec.prtt_enrt_rslt_id , 5);
     open c_test(l_rec.prtt_enrt_rslt_id);
     fetch c_test into l_test;
     hr_utility.set_location ('l_test '|| l_test , 5);
     close c_test;

    If (l_prev_pgm_id = -999999) then
      NULL;
    Elsif (l_prev_pgm_id <> l_rec.pgm_id) then
      For l_rec1 in c_dflt_mn_epe_mndtry(c_pgm_id => l_prev_pgm_id
                                        ,c_pl_id  => l_prev_pl_id ) loop
        l_epe_cnt  := l_epe_cnt + 1;
        l_epe(l_epe_cnt) := l_rec1;
        --hr_utility.set_location (l_actn||' First ', 12 );
      End loop;
    Elsif (l_prev_pl_id <> l_rec.pl_id) then
      For l_rec1 in c_dflt_mn_epe_mndtry(c_pgm_id => l_prev_pgm_id
                                        ,c_pl_id  => l_prev_pl_id ) loop
        l_epe_cnt  := l_epe_cnt + 1;
        l_epe(l_epe_cnt) := l_rec1;
        --hr_utility.set_location (l_actn||' Second ', 12 );
      End loop;
    End if;
    --hr_utility.set_location (l_actn||'Outside ', 13);
    l_epe_cnt  := l_epe_cnt + 1;
    l_epe(l_epe_cnt) := l_rec;
    l_prev_pgm_id := l_rec.pgm_id;
    l_prev_pl_id  := l_rec.pl_id;
  End loop;
  --
  --hr_utility.set_location ('Last loop '||l_actn , 15);
  -- Last loop
  --
  If l_epe_cnt > 0 then
    For l_rec1 in c_dflt_mn_epe_mndtry(c_pgm_id => l_prev_pgm_id
                                      ,c_pl_id  => l_prev_pl_id ) loop
      l_epe_cnt  := l_epe_cnt + 1;
      l_epe(l_epe_cnt) := l_rec1;
      --hr_utility.set_location ('l_rec1 ' , 16);
    End loop;
  End if;
  --
  --hr_utility.set_location ('Before '||l_actn , 17);
  For i in 1..l_epe_cnt Loop
    --
    l_not_ovridn := true ;
    --
    If (l_epe(i).prtt_enrt_rslt_id is not NULL) then
      l_actn := 'Getting enrollment data from c_pen cursor...';
      hr_utility.set_location (l_actn , 18);
      open c_pen(l_epe(i).prtt_enrt_rslt_id);
      fetch c_pen into l_pen;
      If (c_pen%notfound) then
        Close c_pen;
        fnd_message.set_name('BEN','BEN_91711_ENRT_RSLT_NOT_FND');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('ID',to_char(l_epe(i).prtt_enrt_rslt_id));
        fnd_message.set_token('PERSON_ID',to_char(p_person_id));
        fnd_message.set_token('LER_ID',null);
        fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
        fnd_message.raise_error;
      End if;
      close c_pen;
      --
      hr_utility.set_location (' lf_evt_ocrd_dt '|| to_char(l_global_pil_rec.lf_evt_ocrd_dt) , 5);
      --
      -- 4684991 - Use lf_evt_ocrd_dt instead of p_effective_date
      if l_pen.enrt_ovridn_flag = 'Y'
         AND nvl(l_pen.enrt_ovrid_thru_dt,hr_api.g_eot) >
                   NVL(l_global_pil_rec.lf_evt_ocrd_dt, p_effective_date) then
        --
        l_not_ovridn := false ;
        --
      end if ;
      --
      If (l_pen.effective_start_date = p_effective_date) then
        l_datetrack_mode := hr_api.g_correction;
      Else
        l_datetrack_mode := hr_api.g_update;
      End if;
      l_epe(i).actn_cd := 'UPD';
    Else
      l_datetrack_mode := hr_api.g_insert;
      l_epe(i).actn_cd := 'INS';
    End if;

    If(nvl(l_epe(i).dflt_flag,'X') = 'Y'
       or nvl(l_epe(i).mndtry_flag, 'X') = 'Y') and
       nvl(l_epe(i).in_pndg_wkflow_flag,'N') <> 'Y' and
       l_not_ovridn                                 then -- added flag condition so that if pending flag=Y
                                                         -- election is not made

      l_actn := 'Openning c_bnft cursor for benefit...';
      hr_utility.set_location(l_actn , 20);
      l_bnft_id:=null;
      l_bnft_amt:=null;
      l_dflt_bnft_amt:=null;
      l_entr_flag:=null;
      open c_bnft(l_epe(i).elig_per_elctbl_chc_id);

      fetch c_bnft into l_bnft_id, l_bnft_amt, l_dflt_bnft_amt, l_entr_flag,l_cvg_mlt_cd ;
      --hr_utility.set_location(' l_bnft_amt '||l_bnft_amt ,21 );
      --hr_utility.set_location(' l_dflt_bnft_amt '||l_dflt_bnft_amt , 22);
      --hr_utility.set_location(' l_entr_flag '||l_entr_flag , 23);
      close c_bnft;
      -- if the benefit amount is entered at enrollment, use the default
      -- benefit value instead of the val field.
      if l_entr_flag = 'Y' or l_cvg_mlt_cd = 'SAAEAR' then
         l_bnft_amt := l_dflt_bnft_amt;
      end if;

      l_actn := 'Initializing rate cache and load...';

      For j in 1..10 loop
         l_rt(j).enrt_rt_id   := NULL;
         l_rt(j).default_val  := 0;
         l_rt(j).ann_dflt_val := 0;
      End loop;
      l_tot_rt := 0;
      For Crec in c_rt(l_epe(i).elig_per_elctbl_chc_id) loop
        l_tot_rt := l_tot_rt + 1;
        l_rt(l_tot_rt).enrt_rt_id    := Crec.enrt_rt_id;
        l_rt(l_tot_rt).default_val   := Crec.default_val;
        l_rt(l_tot_rt).ann_dflt_val  := Crec.ann_dflt_val;
        --hr_utility.set_location('l_rt(l_tot_rt).ann_dflt_val '||l_rt(l_tot_rt).ann_dflt_val  ,26);
        --hr_utility.set_location('Crec.dflt_val '||l_rt(l_tot_rt).dflt_val , 27);
      End loop;
      l_suspend_flag := 'N';
      If (nvl(l_epe(i).actn_cd,'XXX') = 'UPD') then
        If nvl(l_bnft_amt,0) = nvl(l_pen.bnft_amt,0) then
          l_epe(i).actn_cd := 'DEF';
        End if;
      End if;
      --
      l_actn := 'Calling ben_election_information.election_information...';
      --
/*
      hr_utility.set_location(l_actn , 30);
      hr_utility.set_location(' l_bnft_id '||l_bnft_id ,30);
      hr_utility.set_location(' l_bnft_amt '||l_bnft_amt ,30);
      hr_utility.set_location(' p_enrt_rt_id1 '||l_rt(1).enrt_rt_id ,30);
      hr_utility.set_location(' l_rt(1).dflt_val '||l_rt(1).dflt_val ,31);
      hr_utility.set_location(' p_Ann_rt_val1 '|| l_rt(1).ann_dflt_val , 31);
*/
      --
      /* Added for Enhancement Bug 8716679
	   To add the electable choices to pl/sql table that are defaulted. This pl/sql
	   is scanned to check whether the enrollment record is already defaulted. If the
	   enrollment is defaulted then the enrollment that is to be reinstated will
	   not be reinstated*/
      hr_utility.set_location ('Defaulted epe '||l_epe(i).elig_per_elctbl_chc_id,199);
      hr_utility.set_location ('p_prev_per_in_ler_id '|| p_prev_per_in_ler_id , 5);
      if(p_reinstate_dflts_flag = 'Y') then
         l_rdefault_table_cnt := nvl( ben_lf_evt_clps_restore.g_reinstated_defaults.LAST, 0) + 1;
         ben_lf_evt_clps_restore.g_reinstated_defaults(l_rdefault_table_cnt) := l_epe(i).elig_per_elctbl_chc_id;
      end if;
      /* End of Enhancement Bug 8716679*/

      Ben_election_information.election_information
        (p_elig_per_elctbl_chc_id => l_epe(i).elig_per_elctbl_chc_id
        ,p_prtt_enrt_rslt_id      => l_epe(i).prtt_enrt_rslt_id
        ,p_effective_date         => p_effective_date
        ,p_enrt_mthd_cd           => 'D'
        ,p_business_group_id      => p_business_group_id
        ,p_enrt_bnft_id           => l_bnft_id
        ,p_bnft_val               => l_bnft_amt
        ,p_enrt_rt_id1            => l_rt(1).enrt_rt_id
        ,p_enrt_rt_id2            => l_rt(2).enrt_rt_id
        ,p_enrt_rt_id3            => l_rt(3).enrt_rt_id
        ,p_enrt_rt_id4            => l_rt(4).enrt_rt_id
        ,p_enrt_rt_id5            => l_rt(5).enrt_rt_id
        ,p_enrt_rt_id6            => l_rt(6).enrt_rt_id
        ,p_enrt_rt_id7            => l_rt(7).enrt_rt_id
        ,p_enrt_rt_id8            => l_rt(8).enrt_rt_id
        ,p_enrt_rt_id9            => l_rt(9).enrt_rt_id
        ,p_enrt_rt_id10           => l_rt(10).enrt_rt_id
        ,p_rt_val1                => l_rt(1).default_val
        ,p_rt_val2                => l_rt(2).default_val
        ,p_rt_val3                => l_rt(3).default_val
        ,p_rt_val4                => l_rt(4).default_val
        ,p_rt_val5                => l_rt(5).default_val
        ,p_rt_val6                => l_rt(6).default_val
        ,p_rt_val7                => l_rt(7).default_val
        ,p_rt_val8                => l_rt(8).default_val
        ,p_rt_val9                => l_rt(9).default_val
        ,p_rt_val10               => l_rt(10).default_val
        ,p_Ann_rt_val1            => l_rt(1).ann_dflt_val
        ,p_Ann_rt_val2            => l_rt(2).ann_dflt_val
        ,p_Ann_rt_val3            => l_rt(3).ann_dflt_val
        ,p_Ann_rt_val4            => l_rt(4).ann_dflt_val
        ,p_Ann_rt_val5            => l_rt(5).ann_dflt_val
        ,p_Ann_rt_val6            => l_rt(6).ann_dflt_val
        ,p_Ann_rt_val7            => l_rt(7).ann_dflt_val
        ,p_Ann_rt_val8            => l_rt(8).ann_dflt_val
        ,p_Ann_rt_val9            => l_rt(9).ann_dflt_val
        ,p_Ann_rt_val10           => l_rt(10).ann_dflt_val
        ,p_datetrack_mode         => l_datetrack_mode
        ,p_suspend_flag           => l_suspend_flag
        ,p_prtt_enrt_interim_id   => l_prtt_enrt_interim_id
        ,P_PRTT_RT_VAL_ID1        => l_dump_num
        ,P_PRTT_RT_VAL_ID2        => l_dump_num
        ,P_PRTT_RT_VAL_ID3        => l_dump_num
        ,P_PRTT_RT_VAL_ID4        => l_dump_num
        ,P_PRTT_RT_VAL_ID5        => l_dump_num
        ,P_PRTT_RT_VAL_ID6        => l_dump_num
        ,P_PRTT_RT_VAL_ID7        => l_dump_num
        ,P_PRTT_RT_VAL_ID8        => l_dump_num
        ,P_PRTT_RT_VAL_ID9        => l_dump_num
        ,P_PRTT_RT_VAL_ID10       => l_dump_num
        ,P_OBJECT_VERSION_NUMBER  => l_pen.object_version_number
        ,p_effective_start_date   => l_effective_start_date
        ,p_effective_end_date     => l_effective_end_date
        ,P_DPNT_ACTN_WARNING      => l_dump_boolean
        ,P_BNF_ACTN_WARNING       => l_dump_boolean
        ,P_CTFN_ACTN_WARNING      => l_dump_boolean
        );
      -- after the enhncemnt # 2685018 cryfwd_elig_dpnt_cd value is concated with
      -- result id from where the dpnt carry forwarded , this will seprate the code from
      --- result id

      l_prev_prtt_enrt_rslt_id := null; -- Reintializing the previous enrt result id
      l_cryfwd_elig_dpnt_cd := l_epe(i).cryfwd_elig_dpnt_cd ;
      l_prev_rslt_id_at     := instr(l_cryfwd_elig_dpnt_cd, '^') ;
      --- if the  result id concated with the code, then  the caht '^' must be aprt of the
      --- the code

      if l_prev_rslt_id_at   > 0  then
          --- if the to_number errors , catch the exception
          Begin
             l_prev_prtt_enrt_rslt_id := to_number(substr(l_cryfwd_elig_dpnt_cd,l_prev_rslt_id_at+1) );
          Exception
             when value_error then
                  l_prev_prtt_enrt_rslt_id := null;
          End  ;
          l_cryfwd_elig_dpnt_cd := substr(l_cryfwd_elig_dpnt_cd,1,l_prev_rslt_id_at-1) ;
      end if ;


      if l_datetrack_mode = hr_api.g_insert and l_cryfwd_elig_dpnt_cd = 'CFRRWP' then

          ben_automatic_enrollments.reinstate_dpnt
                            (p_pgm_id               => l_epe(i).pgm_id,
                             p_pl_id                => l_epe(i).pl_id,
                             p_oipl_id              => l_epe(i).oipl_id,
                             p_business_group_id    => p_business_group_id,
                             p_person_id            => p_person_id,
                             p_per_in_ler_id        => p_per_in_ler_id,
                             p_elig_per_elctbl_chc_id => l_epe(i).elig_per_elctbl_chc_id,
                             p_dpnt_cvg_strt_dt_cd    => l_epe(i).dpnt_cvg_strt_dt_cd,
                             p_dpnt_cvg_strt_dt_rl    => l_epe(i).dpnt_cvg_strt_dt_rl,
                             p_enrt_cvg_strt_dt       => l_epe(i).enrt_cvg_strt_dt,
                             p_effective_date         => p_effective_date,
                             p_prev_prtt_enrt_rslt_id => l_prev_prtt_enrt_rslt_id
                            );
       end if;
      l_actn := 'Getting suspend status...';
      --
      l_epe(i).suspended := l_suspend_flag;
      If (l_suspend_flag = 'Y') then
         p_susp_flag  := TRUE;
      End if;
    Elsif(nvl(l_epe(i).dflt_flag,'X') <> 'Y'
           and nvl(l_epe(i).crntly_enrd_flag, 'X') = 'Y'
           and p_effective_date >= nvl(l_pen.ERLST_DEENRT_DT, hr_api.g_sot)
           and l_epe(i).AUTO_ENRT_FLAG  = 'N'
          ) then
      --
      --  The enrollment result is ended in the multi_rows_edit. This
      --  is information for the batch reports.
      --
      l_epe(i).actn_cd := 'DEL';
      --
    End if;
    If (p_batch_flag) then
      --
      l_actn := 'Calling Ben_batch_utils.cache_comp_obj...';
      Ben_batch_utils.cache_comp_obj
        (p_prtt_enrt_rslt_id => l_epe(i).prtt_enrt_rslt_id
        ,p_effective_date    => p_effective_date
        ,p_actn_cd           => l_epe(i).actn_cd
        ,p_suspended         => l_epe(i).suspended);
    End if;
  End loop;

  -- Bug 4421813 Call init so that the person details are available for later procedures

  if l_epe_cnt = 0 and fnd_global.conc_request_id = -1 and p_called_frm_ss then
  --
  ben_env_object.init(p_business_group_id  => p_business_group_id,
                      p_effective_date     => p_effective_date,
                      p_thread_id          => 1,
                      p_chunk_size         => 1,
                      p_threads            => 1,
                      p_max_errors         => 1,
                      p_benefit_action_id  => null);
  --
  end if;


  --
      ben_proc_common_enrt_rslt.set_elcn_made_or_asnd_dt(
                     p_per_in_ler_id     => p_per_in_ler_id
                    ,p_pgm_id            => p_pgm_id
                    ,p_pl_id             => p_pl_nip_id --null Bug 2961251 passed pl_id parameter instead of null
                    ,p_enrt_mthd_cd      => 'D'   -- Explicit
                    ,p_business_group_id => p_business_group_id
                    ,p_effective_date    => p_effective_date
                    ,p_validate          => FALSE
                     );

  -- Check data to make sure multi-rows adit passed.  This section is used
  -- for the last program ID.
  --

  -- if (not p_called_frm_ss) then
       l_actn := 'Calling Ben_PRTT_ENRT_RESULT_api.multi_rows_edit...';
       Ben_PRTT_ENRT_RESULT_api.multi_rows_edit
        (p_person_id           => p_person_id
         ,p_effective_date     => p_effective_date
         ,p_business_group_id  => p_business_group_id
         ,p_pgm_id 	       => p_pgm_id
         ,p_per_in_ler_id      => p_per_in_ler_id
         ,p_called_frm_ss      => p_called_frm_ss
         );
  -- End if;
  --
  -- Invoke post result process.
  --
  l_actn := 'Calling Ben_proc_common_enrt_rslt.process_post_results...';
  Ben_proc_common_enrt_rslt.process_post_results
    (p_person_id          => p_person_id
    ,p_enrt_mthd_cd       => 'D'
    ,p_effective_date     => p_effective_date
    ,p_business_group_id  => p_business_group_id
    ,p_validate           => FALSE
    ,p_per_in_ler_id      => p_per_in_ler_id
    ,p_called_frm_ss      =>p_called_frm_ss
    );
  --
  -- Invoke process_post_enrollment.
  --
  l_actn := 'Calling Ben_proc_common_enrt_rslt.process_post_enrollment...';
  Ben_proc_common_enrt_rslt.process_post_enrollment
    (p_per_in_ler_id     => p_per_in_ler_id
    ,p_pgm_id            => p_pgm_id
    ,p_pl_id             => p_pl_nip_id
    ,p_enrt_mthd_cd      => 'D'
    ,p_proc_cd           => 'DFLTENRT'
    ,p_person_id         => p_person_id
    ,p_business_group_id => p_business_group_id
    ,p_effective_date    => p_effective_date
    ,p_validate          => FALSE
    ,p_cls_enrt_flag     => p_cls_enrt_flag
    );
  hr_utility.set_location ('Leaving '|| l_proc,10);
Exception
  when app_exception.application_exception then  -- 6027345
	  fnd_message.raise_error;               -- 6027345
  When others then
    if p_batch_flag then
     --
     -- Update person action to errored as record has an error
     --
     -- ben_batch_utils.write(p_text => fnd_message.get);
     ben_batch_utils.write(p_text => sqlerrm);
     ben_batch_utils.rpt_error(p_proc      => l_proc
                              ,p_last_actn => l_actn
                              ,p_rpt_flag  => p_batch_flag
                              );
     raise ben_batch_utils.g_record_error ;
    -- Added for Bug 2370264
    else
      hr_utility.set_location ('Error in Default_Comp_obj : '|| sqlerrm , 87);
      fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
      fnd_message.set_token('2',substr(sqlerrm,1,500)); -- 4695708
      fnd_message.raise_error;
    end if;
    -- End 2370264
End Default_Comp_obj;
--
-- ============================================================================
--                   << Procedure: process_default_enrt >>
-- ============================================================================
--
Procedure Process_default_enrt
                  (p_validate              in     varchar2 default 'N'
                  ,p_person_id             in     number default null
                  ,p_person_action_id      in     number default null
                  ,p_object_version_number in out nocopy number
                  ,p_business_group_id     in     number
                  ,p_effective_date        in     date
                  ,p_batch_flag            in     Boolean default FALSE
                  ,p_audit_log             in     varchar2 default 'N'
                  ) is
  --
  -- Local Cursor
  --
  -- See bug 1960 : this cursor is not retrieving any pil_popl's due to :
  --                and a.ELCNS_MADE_DT  is not NULL
  --                so above part of where clause is chaged to
  --                and a.ELCNS_MADE_DT  is NULL
  --
  Cursor C_pel is
    Select a.PER_IN_LER_ID
          ,a.PGM_ID
          ,a.PL_ID
          ,b.lf_evt_ocrd_dt
          ,b.ler_id
          ,a.dflt_enrt_dt
          ,a.enrt_perd_strt_dt
          ,a.enrt_perd_end_dt
      From Ben_pil_elctbl_chc_popl a
          ,ben_per_in_ler b
          ,ben_ler_f ler
     Where a.PIL_ELCTBL_POPL_STAT_CD  = 'STRTD'
       --and a.business_group_id = b.business_group_id
       and a.business_group_id = p_business_group_id
       and a.per_in_ler_id = b.per_in_ler_id
       and a.dflt_enrt_dt  <=  p_effective_date -- 7166971
       and b.per_in_ler_stat_cd = 'STRTD'
       and a.ELCNS_MADE_DT  is NULL
       and ler.ler_id = b.ler_id
       and ler.typ_cd not in ('SCHEDDU')     -- bug5768880
       and p_effective_date between ler.effective_start_date
           and ler.effective_End_date
       and b.person_id = p_person_id ;
  --
  Cursor C_pil is
    Select b.PER_IN_LER_ID
          ,b.lf_evt_ocrd_dt
          ,b.ler_id
      From ben_per_in_ler b,
           ben_ler_f ler
     Where b.per_in_ler_stat_cd = 'STRTD'
       and b.person_id = p_person_id
       and b.ler_id = ler.ler_id
       and ler.typ_cd not in ('COMP','GSP')
       and p_effective_date between
           ler.effective_start_date and
           ler.effective_end_date
          ;
  --
  -- Local Variables
  --
  l_proc            Varchar2(80) := g_package || '.process_default enrollment';
  l_output_string   Varchar2(80);
  l_validate        boolean;
  l_actn            varchar2(80);
  l_bnft_amt        ben_enrt_bnft.val%type;
  l_bnft_id         ben_enrt_bnft.enrt_bnft_id%type;
  l_datetrack_mode  varchar2(30);
  l_pel_cnt         binary_integer := 0;
  l_susp_flag       boolean;
  l_output          varchar2(2000);
  l_per_in_ler_id   number;
  l_lf_evt_ocrd_dt  date;
  l_ler_id          number;
  l_dflt_enrt_date  date;
  --
begin
--  hr_utility.trace_on(NULL,'TRC');
  hr_utility.set_location ('Entering '|| l_proc,10);
  l_actn := 'Initializing...';
  Savepoint process_default_enrt_savepoint;
  --
  -- Cache person data and write personal data into cache.
  --
  l_actn := 'Calling ben_batch_utils.person_header...';
  ben_batch_utils.person_header
    (p_person_id           => p_person_id
    ,p_business_group_id   => p_business_group_id
    ,p_effective_date      => p_effective_date
    );
  --
  l_actn := 'Calling ben_batch_utils.ini(COMP_OBJ)...';
  ben_batch_utils.ini('COMP_OBJ');
  For l_rec in c_pel loop
    l_pel_cnt := l_pel_cnt + 1;
    l_per_in_ler_id:=l_rec.per_in_ler_id;
    l_ler_id := l_rec.ler_id;
    l_lf_evt_ocrd_dt := l_rec.lf_evt_ocrd_dt;
    --
    l_actn := 'Calling Default_comp_obj(pgm:' || to_char(l_rec.pgm_id) ||
              ' Pl_no_Pgm:' || to_char(l_rec.pl_id) ||  ')';
    --
    --
    -- Bug 5407755
    -- Default enrollment date = nvl (  (     'Defaults will be assigned on',
    --                                     OR 'Days after Enrollment Period to Apply Defaults'
    --                                   ),
    --                                 Enrollment Period End Date
    --                                )
    --
    l_dflt_enrt_date := NVL (l_rec.dflt_enrt_dt, l_rec.enrt_perd_end_dt);
    --
    IF l_dflt_enrt_date IS NULL
    THEN
       l_dflt_enrt_date := p_effective_date;
    END IF;
    --
    hr_utility.set_location ('l_Dflt_enrt_Date = ' || l_dflt_enrt_date, 9999);
    --
    Default_comp_obj
      (p_validate           => FALSE
      ,p_per_in_ler_id      => l_rec.per_in_ler_id
      ,p_person_id          => p_person_id
      ,p_business_group_id  => p_business_group_id
      ,p_effective_date     => l_Dflt_enrt_Date      /* Bug 5158204 */
      ,p_pgm_id             => l_rec.pgm_id
      ,p_pl_nip_id          => l_rec.pl_id
      ,p_susp_flag          => l_susp_flag
      ,p_batch_flag         => TRUE
      ,p_cls_enrt_flag      => FALSE
      );
    --
  End loop;
  --
  -- jcarpent
  -- Bug 1609055.  If this is null then you get an error inserting
  -- the log rows.  Instead just fetch the per_in_ler_info for the
  -- started event.
  -- Tilak
  -- now can be  multiple per_in_ler_id is started  status
  if l_ler_id is null then
    open c_pil;
    fetch c_pil into
      l_per_in_ler_id,
      l_lf_evt_ocrd_dt,
      l_ler_id;
    close c_pil;
  end if;
  --
  --  Close enrollment i.e. update the per_in_ler to processed.
  --
  if l_pel_cnt>0 then
    ben_close_enrollment.close_single_enrollment
      (p_per_in_ler_id        => l_per_in_ler_id
      ,p_effective_date       => p_effective_date
      ,p_business_group_id    => p_business_group_id
      ,p_validate             => false
      ,p_close_uneai_flag     => 'Y'
      ,p_uneai_effective_date => p_effective_date
    );
  end if;
  --
  l_actn := 'Calling Ben_batch_utils.write_comp...';
  Ben_batch_utils.write_comp(p_business_group_id => p_business_group_id
                            ,p_effective_date    => p_effective_date
                            );
  If (p_validate = 'Y') then
    Rollback to process_default_enrt_savepoint;
  End if;
  --
  l_actn := 'Calling write_person_category...';
  write_person_category (p_audit_log         => p_audit_log
                        ,p_person_id         => p_person_id
                        ,p_business_group_id => p_business_group_id
                        ,p_effective_date    => p_effective_date
                        );
  --
  If p_person_action_id is not null then
    --
    l_actn := 'Calling ben_person_actions_api.update_person_actions...';
    --
    update ben_person_actions
    set    action_status_cd = 'P'
    where  person_action_id = p_person_action_id;
    --
  End if;
  --
  g_rec.person_id := p_person_id;
  g_rec.ler_id := l_ler_id;
  g_rec.per_in_ler_id := l_per_in_ler_id;
  g_rec.lf_evt_ocrd_dt := l_lf_evt_ocrd_dt;
  g_rec.replcd_flag := 'N';
  g_rec.crtd_flag := 'N';
  g_rec.tmprl_flag := 'N';
  g_rec.dltd_flag := 'N';
  g_rec.open_and_clsd_flag := 'N';
  g_rec.not_crtd_flag := 'N';
  g_rec.clsd_flag := 'Y';
  g_rec.stl_actv_flag := 'N';
  g_rec.clpsd_flag := 'N';
  g_rec.clsn_flag := 'N';
  g_rec.no_effect_flag := 'N';
  g_rec.cvrge_rt_prem_flag := 'N';
  g_rec.business_group_id := p_business_group_id;
  g_rec.effective_date := p_effective_date;
  --
  benutils.write(p_rec => g_rec);
  --
  g_persons_procd := g_persons_procd + 1;
  benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
  hr_utility.set_location ('Leaving '|| l_proc,10);
Exception
  When others then
    rollback to process_default_enrt_savepoint;
    g_persons_errored := g_persons_errored + 1;
    ben_batch_utils.write_error_rec;
    ben_batch_utils.write(p_text => fnd_message.get);
    ben_batch_utils.write(p_text => sqlerrm);
    ben_batch_utils.rpt_error(p_proc       => l_proc
                             ,p_last_actn  => l_actn
                             ,p_rpt_flag   => TRUE);
    Ben_batch_utils.write_comp(p_business_group_id => p_business_group_id
                              ,p_effective_date    => p_effective_date
                              );
    If p_person_action_id is not null then
      ben_person_actions_api.update_person_actions
        (p_person_action_id      => p_person_action_id
        ,p_action_status_cd      => 'E'
        ,p_object_version_number => p_object_version_number
        ,p_effective_date        => p_effective_date
        );
    End if;
    write_person_category (p_audit_log         => p_audit_log
                          ,p_error             => TRUE
                          ,p_person_id         => p_person_id
                          ,p_business_group_id => p_business_group_id
                          ,p_effective_date    => p_effective_date
                          );
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    raise ben_batch_utils.g_record_error;
end process_default_enrt;

-- ============================================================================
--                   << Procedure: Default_comp_obj_w >>
-- ============================================================================
Procedure Default_Comp_obj_w
  (p_validate           in     varchar2 default 'TRUE'
  ,p_per_in_ler_id      in     Number
  ,p_person_id          in     Number
  ,p_business_group_id  in     Number
  ,p_effective_date     in     Date
  ,p_pgm_id             in     Number
  ,p_pl_nip_id          in     Number default null
  ,p_susp_flag             out nocopy varchar2
  ,p_batch_flag         in     varchar2 default 'FALSE'
  ,p_cls_enrt_flag      in     varchar2 default 'FALSE'
  ) is

  l_proc            Varchar2(80) := g_package || '.Default_Comp_obj_w';
  l_suspend_flag    boolean;
  l_validate        boolean;
  l_batch_flag      boolean;
  l_cls_enrt_flag   boolean;
  l_commit          number;
begin
  --
  fnd_msg_pub.initialize;
  hr_utility.set_location ('Entering '|| l_proc,10);

  if UPPER(p_validate) = 'TRUE' then
    l_validate := true;
  else
    l_validate := false;
  end if;
  --
  if UPPER(p_batch_flag) = 'FALSE' then
    l_batch_flag := false;
  else
    l_batch_flag := true;
  end if;
  --
  if UPPER(p_cls_enrt_flag) = 'FALSE' then
    l_cls_enrt_flag := false;
  else
    l_cls_enrt_flag := true;
  end if;
  --

  -- Bug 3989075, Put row in fnd_sessions for SS processing
  dt_fndate.change_ses_date
    (p_ses_date => p_effective_date,
     p_commit   => l_commit);

  Default_Comp_obj
    (p_validate           => l_validate
    ,p_per_in_ler_id      => p_per_in_ler_id
    ,p_person_id          => p_person_id
    ,p_business_group_id  => p_business_group_id
    ,p_effective_date     => p_effective_date
    ,p_pgm_id             => p_pgm_id
    ,p_pl_nip_id          => p_pl_nip_id
    ,p_susp_flag          => l_suspend_flag
    ,p_batch_flag         => l_batch_flag
    ,p_cls_enrt_flag      => l_cls_enrt_flag
    ,p_called_frm_ss      => TRUE
    );
  --
  if l_suspend_flag = true then
    p_susp_flag := 'TRUE';
  else
    p_susp_flag := 'FALSE';
  end if;
  hr_utility.set_location ('Leaving '|| l_proc,20);

exception
  --
  when app_exception.application_exception then	--Bug 4387247
    hr_utility.set_location ('Application Error in Default_Comp_obj_w.', 88);
    fnd_msg_pub.add;
  when others then
    hr_utility.set_location ('Other Error in Default_Comp_obj_w : '|| sqlerrm , 89);
    --Bug 4387247
    fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
    fnd_message.set_token('2',substr(sqlerrm,1,200));
    fnd_msg_pub.add;
end Default_Comp_obj_w;
--
end ben_manage_default_enrt;  -- End of Package.

/
