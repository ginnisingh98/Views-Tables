--------------------------------------------------------
--  DDL for Package Body BEN_MAINTAIN_DESIGNEE_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_MAINTAIN_DESIGNEE_ELIG" as
/* $Header: bendsgel.pkb 120.6.12010000.5 2009/02/05 12:43:01 krupani ship $ */
--
/* ============================================================================
*    Name
*       Maintain Designee Eligibility
*
*    Purpose
*       This package is used to check validity of parameters passed in via SRS
*       or via a PL/SQL function or procedure. This package check to see if
*       all designees for the person and comp object are still eligible, if
*       not, it will update the status to "not covered" and end date the row.
*
*    History
*      Date        Who        Version    What?
*      -------     ---------  -------    --------------------------------------
*      30-Nov-98   jcarpent   115.0      Created
*      22-Dec-98   jcarpent   115.1      Changed end date logic
*      03-Jan-98   Tmathers   115.2      Made compilable.
*      06-Jan-98   jcarpent   115.3      Added reporting.
*      19-Feb-99   gperry     115.4      Added call to communciations for when
*                                        a dependent is being deleted.
*      23-Feb-99   jcarpent   115.5      Changed effective date format
*      03-Mar-99   stee       115.6      Removed dbms_output.put_line.
*      22-Mar-99   Tmathers   115.8      Changed -MON- to /MM/'
*      28-Apr-99   lmcdonal   115.10     prtt_enrt_rslt now has a status code.
*      30-apr-99   shdas      115.11     modified contexts to rule calls.
*      10-may-99   jcarpent   115.12     Check ('VOIDD', 'BCKDT') for pil stat
*      18-may-99   jcarpent   115.13     Changed delete_pdp to update_pdp,
*                                        init PROC_INFO, and added commits
*      25-may-99   jcarpent   115.14     Changed end date handling if bendetdt
*                                        returns null.  Removed sub-titles
*                                        for error reports to fix concurrent
*                                        manager display.
*      05-JUL-99   stee       115.15     Create  benefit assignments for
*                                        dependents who become ineligible.
*      20-JUL-99   Gperry     115.16     genutils -> benutils package rename.
*      24-Aug-99   maagrawa   115.17     Dependents related changes.
*      30-Aug-99   maagrawa   115.18     Added parameter p_dpnt_inelig_rsn_cd
*                                        to dependent eligibility process
*                                        to return ineligible reason.
*      02-Sep-99   maagrawa   115.19     Added HIPAA communications.
*      07-Sep-99   tguy       115.20     fixed call to pay_mag_util
*      06-Oct-99   tguy       115.21     added call to dt_fndate
*      12-Oct-99   maagrawa   115.22     ben_env_object.init call added
*                                        to do_multithread.
*      02-Nov-99   maagrawa   115.23     Coverage through date to be effective
*                                        date if the calculated date is less
*                                        than coverage start date.
*      03-Jan-00   maagrawa   115.24     Added pl_typ_id to comm. process.
*      17-Jan-00   maagrawa   115.25     Moved the HIPAA logic to bencommu
*                                        and bencomde.
*      28-Jan-00   pbodla     115.26   - Fidelity Bug : 5445, Move the benefits
*                                        assignment creation out nocopy of for loop.
*                                      - Submit_all_reports is modified
*      17-Feb-00   jcarpent   115.27   - Pass correct elig_thru_dt to
*                                        update_elig_dpnt.  bug 4719
*      18-Feb-00   gperry     115.28     Multithread was calling wrong process.
*                                        now calling BENMDSGL.
*                                        WWBUG 1201093.
*      25-Feb-00   jcarpent   115.29   - Pass person_id to person selection rl.
*      14-Mar-00   maagrawa   115.30   Pass the elig_change_dt as the life event
*                                      occured date to comm. process.(1230019)
*      31-Mar-00   maagrawa   115.31   Pass the cvg_strt_dt to dpnt.
*                                      eligibilty process (4929).
*                                      If found ineligible, end the eligibiltity
*                                      for all the comp. objects depending on
*                                      the level at which eligibilty is
*                                      defined.
*      03-Apr-00   mmogel     115.32   - Added tokens to messages to make them
*                                        more meaningful to the user
*      07-Jun-00   jcarpent   115.33   - Added init of l_returned_end_dt since
*                                        was bleeding to other comp objects
*                                        for dependent. (4728)
*      29-aug-01   pbodla     115.34   - bug:1949361 jurisdiction code is
*                                        derived inside benutils.formula
*      18-dec-01   tjesumic   115.35   - cwb changes
*      20-dec-01   ikasire    115.36     added dbdrv lines
*      20-dec-01   ikasire    115.37     added commit
*      12-feb-02   pabodla    115.38     Bug 1579948 Fix: if g_profile_value is
*                                        'N' then do not write no designation
*                                        change records into the batch log tables
*      04-App-02   pabodla    115.39     Bug 1579948 Fix: added if stmt to
*                                        restrict a row to write into the
*                                        ben_batch_dpnt_info if
*                                        g_profile_value set to "No". This is
*                                        done for improving the performance
*                                        of audit log
*      30-Apr-02   kmahendr   115.40     Added write calls to capture error messages.
*      08-Jun-02   pabodla    115.41     Do not select the contingent worker
*                                        assignment when assignment data is
*                                        fetched.
*      11-jul-02   tjesumic   115.42     # 2455430 The coverage end date is calculated
*                                        on the basis of  event occured date
*      19-dec-2002 pabodla    115.43     NOCOPY Changes
*      02-Jun-2003 rpgupta    115.44     Bug 2985206
*					 Changed cursor c_person
*      02-Jun-2003 rpgupta    115.45     Bug 2985206
*					 Changed cursor c_person again to merge
*					 similar join conditions
*      02-Jun-2003 hmani      115.46     Bug 2985206
*					 Changed cursor c_person again to merge
*					 similar join conditions - Rearcsed in
*      27-Jul-2003 pabodla    115.47     Bug 3056894 - Added personal_flag to
*                                        c_designation to consider only
*                                        personal relationships.
*      16-Jun-2004 bmanyam   115.48     Bug 3657077 - In calc_dpnt_cvg_end_dt procedure
*                                       passed the correct param (l_cvg_end_rl) ot
*                                       ben_determine_date.main
*      05-Aug-2004 rpgupta   115.49     Bug 3808703 - c_person does not return any
*                                       rows when the pl_id is specified. Its coded to
*                                       use pl_id only for plans not in programs.
*      03-Dec-2004 ikasire   115.50     Bug 4046914
*     30-dec-2004   nhunur  115.51     4031733 - No need to open cursor c_state
*     08-Jan-2005    mmudigon115.52     4398114 - changed <= to >= in line 1836
*      05-May-06     rtagarra 115.53    Bug#5070692:Changed the parameter value from FALSE to TRUE so that when run the
                                        Maintain Designee Eligibility warnings will come in the log file when dependent coverage
					start and end date has date earlier than LE occured date.
*     09-May-06   rtagarra  115.54     Change in exception block for process_designee_elig.
*     26-May-06   bmanyam   115.55     5100008 - EGD elig_thru_dt is the
                                       date eligibility is lost. Previously the elig_thru_dt
                                       was updated with PDP cvg_thru_dt.
      07-aug-06    ssarkar  115.56     5442301 - dont update elig_cvrd_dpnt if it is overriden
*     01-Dec-06    rtagarra 115.57     5662220 - Added check so that when there is no condition for a person in person_selection_rule
					then skip the person.
*     05-Apr-07    rtagarra 115.58     5908080 - Continued for fix 5442301: Added date condition for c_designation.
*     14-Jan-07    rtagarra 115.59     6747807 - Fixed cursor c_person and c_designation
*     05-Feb-09    krupani  115.61     7718592 - Reverted back fix against 5908080
* -----------------------------------------------------------------------------
*/
--
-- Global cursor and variables declaration
--
g_package                 varchar2(80) := 'Ben_maintain_designee_elig';
g_persons_processed       number(9) := 0;
g_persons_ended           number(9) := 0;
g_persons_passed          number(9) := 0;
g_persons_errored         number(9) := 0;
g_designations_ended      number(9) := 0;
g_designations_remaining  number(9) := 0;
g_max_errors_allowed      number(9) := 200;
type g_report_rec is record
    (
     person_id             /*per_people_f */per_all_people_f.person_id%type,
     pgm_id                ben_pgm_f.pgm_id%type,
     pl_id                 ben_pl_f.pl_id%type,
     oipl_id               ben_oipl_f.oipl_id%type,
     dpnt_cvg_strt_dt      date,
     dpnt_cvg_thru_dt      date,
     contact_type          hr_lookups.lookup_code%type,
     actn_cd               hr_lookups.lookup_code%type);
--
type g_report_table is table of g_report_rec
  index by binary_integer;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< calc_dpnt_cvg_end_dt >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure calc_dpnt_cvg_end_dt(
          p_person_id              in     number        default NULL
         ,p_pgm_id                 in     number        default NULL
         ,p_pl_id                  in     number        default NULL
         ,p_oipl_id                in     number        default NULL
         ,p_ptip_id                in     number        default NULL
         ,p_business_group_id      in     number
         ,p_effective_date         in     date
         ,p_returned_end_dt           out nocopy date
         ) is
  l_proc         varchar2(72) := g_package||'calc_dpnt_cvg_end_dt';
  l_enrt_cvg_end_dt   date;
  l_cvg_strt_cd  varchar2(30);
  l_cvg_strt_rl  number;
  l_cvg_end_cd   varchar2(30);
  l_cvg_end_rl   number(15);
  l_step         integer;
  l_effective    date;
begin
    hr_utility.set_location(' Entering:'||l_proc,10);
    ben_prtt_enrt_result_api.determine_dpnt_cvg_dt_cd
              (p_pgm_id                 => p_pgm_id
              ,P_ptip_id                => p_ptip_id
              ,p_pl_id                  => p_pl_id
              ,p_ler_id                 => null
              ,p_effective_date         => p_effective_date
              ,p_business_group_id      => p_business_group_id
              ,p_cvg_strt_cd            => l_cvg_strt_cd
              ,p_cvg_strt_rl            => l_cvg_strt_rl
              ,p_cvg_end_cd             => l_cvg_end_cd
              ,p_cvg_end_rl             => l_cvg_end_rl
              );
     hr_utility.set_location(' cvg end dt cd :'||l_cvg_end_cd ,10);
     hr_utility.set_location(' elig chnage dt:'||ben_evaluate_dpnt_elg_profiles.get_elig_change_dt,109);
     -- tilak  2455430 : I dont think we need the if condition as it is
     --  only AED and ODBED   are avaialble
     -- for end dt codes  This conditon makes the AED  calc  wrong , get_elig_change_dt return
     -- Date of birth -1  that is not  the AED date but ODBED

    --if (l_cvg_end_cd in ('AED','ODBED','AFDEM','ALDEM','AFDFEM','OMFED',
    --                     'TMFED','30DFLED','TDBED','60DFLED','SDFED','SDBED',
    --                     'TODFED')) then
    --  l_enrt_cvg_end_dt:=ben_evaluate_dpnt_elg_profiles.get_elig_change_dt;
    --  hr_utility.set_location(' cvg end dt :'||l_enrt_cvg_end_dt ,110);
    --else
      ben_determine_date.main
                (P_DATE_CD                => l_cvg_end_cd
                ,p_formula_id             => l_cvg_end_rl -- l_cvg_strt_rl Bug: 3657077; end-date-rule should be passed.
                ,P_PER_IN_LER_ID          => null
                ,P_PERSON_ID              => p_person_id
                ,P_PGM_ID                 => p_pgm_id
                ,P_PL_ID                  => p_pl_id
                ,P_OIPL_ID                => p_oipl_id
                ,P_BUSINESS_GROUP_ID      => p_business_group_id
                ,P_EFFECTIVE_DATE         => l_effective
                ,P_LF_EVT_OCRD_DT         => ben_evaluate_dpnt_elg_profiles.
                                            get_elig_change_dt + 1
                ,P_RETURNED_DATE          => l_enrt_cvg_end_dt
                );
    hr_utility.set_location(' cvg end dt :'||l_enrt_cvg_end_dt ,111);
    --end if;
    if l_enrt_cvg_end_dt is null then
      l_enrt_cvg_end_dt:=ben_evaluate_dpnt_elg_profiles.get_elig_change_dt;
    hr_utility.set_location(' cvg end dt :'||l_enrt_cvg_end_dt ,112);
    end if;
    p_returned_end_dt  := l_enrt_cvg_end_dt;
    hr_utility.set_location(' Leaving:'||l_proc, 70);
end calc_dpnt_cvg_end_dt;
--
-- ===========================================================================
--                 << Procedure: ben_batch_utils.batch_report >>
-- ===========================================================================
--
Procedure Submit_all_reports (p_rpt_flag  Boolean default FALSE) is
  l_proc        varchar2(80) := g_package||'.submit_all_reports';
  l_actn        varchar2(80);
  l_request_id  number;
Begin
  hr_utility.set_location ('Entering '||l_proc,05);
  l_actn := 'Calling ben_batch_utils.batch_report (BENDEAUD)...';
  --
  If fnd_global.conc_request_id <> -1 then
    --
    ben_batch_utils.batch_report
         (p_concurrent_request_id => fnd_global.conc_request_id
         ,p_program_name          => 'BENDEAUD'
         ,p_request_id            => l_request_id
         );
    l_actn := 'Calling ben_batch_utils.batch_report (BENDESUM)...';
    ben_batch_utils.batch_report
         (p_concurrent_request_id => fnd_global.conc_request_id
         ,p_program_name          => 'BENDESUM'
         ,p_request_id            => l_request_id
         );
    l_actn := 'Calling ben_batch_utils.batch_report (BENERTYP)...';
    ben_batch_utils.batch_report
         (p_concurrent_request_id => fnd_global.conc_request_id
         ,p_program_name          => 'BENERTYP'
         ,p_request_id            => l_request_id
--         ,p_subtitle              =>
--           'MANAGE DEFAULT ENROLLMENTS - ERROR DETAIL BY ERROR TYPE'
         );
    l_actn := 'Calling ben_batch_utils.batch_report (BENERPER)...';
    ben_batch_utils.batch_report
         (p_concurrent_request_id => fnd_global.conc_request_id
         ,p_program_name          => 'BENERPER'
         ,p_request_id            => l_request_id
--         ,p_subtitle              =>
--           'MANAGE DEFAULT ENROLLMENTS - ERROR DETAIL BY PERSON'
         );
  end if;
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
--  	this is a main procedure to invoke the maintain designee elig process.
-- ============================================================================
procedure do_multithread
             (errbuf                     out nocopy varchar2
             ,retcode                    out nocopy number
             ,p_validate              in     varchar2 default 'N'
             ,p_benefit_action_id     in     number
             ,p_thread_id             in     number
             ,p_effective_date        in     varchar2
             ,p_business_group_id     in     number
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
  hr_utility.set_location ('Entering '||l_proc,05);
  --
  /*
  l_effective_date:=to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date:=to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR'),'DD/MM/RRRR');
  */
  l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
  --
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  l_actn := 'Calling benutils.get_parameter...';
  benutils.get_parameter(p_business_group_id  => p_business_group_Id
                        ,p_batch_exe_cd       => 'BENDSGEL'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed);
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
  g_persons_processed              := 0;
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
          ,p_person_id                => l_parm.person_id
          ,p_person_selection_rule_id => l_parm.person_selection_rl
          ,p_comp_selection_rule_id   => l_parm.comp_selection_rl
          ,p_pgm_id                   => l_parm.pgm_id
          ,p_pl_id                    => l_parm.pl_id
          ,p_person_type_id           => l_parm.person_type_id
          ,p_ler_id                   => null
          ,p_organization_id          => l_parm.organization_id
          ,p_benfts_grp_id            => l_parm.benfts_grp_id
          ,p_location_id              => l_parm.location_id
          ,p_legal_entity_id          => l_parm.legal_entity_id
          ,p_payroll_id               => l_parm.payroll_id
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
          ben_maintain_designee_elig.process_designee_elig
            (p_validate              => p_validate
            ,p_person_id             => g_cache_person_process(l_cnt).person_id
            ,p_person_action_id      => g_cache_person_process(l_cnt).person_action_id
            ,p_comp_selection_rl     => l_parm.comp_selection_rl
            ,p_pgm_id                => l_parm.pgm_id
            ,p_pl_id                 => l_parm.pl_id
            ,p_object_version_number => g_cache_person_process(l_cnt).object_version_number
            ,p_business_group_id     => p_business_group_id
            ,p_effective_date        => l_effective_date
          );
        Exception
            When others then
              If (g_persons_errored > g_max_errors_allowed) then
                  fnd_message.raise_error;
              End if;
        End;
      benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE); --Bug 5070692
      End loop;
    Else
      --
      l_actn := 'Erroring out nocopy since not person is found in range...' ;
      --
      fnd_message.set_name('BEN','BEN_91709_PER_NOT_FND_IN_RNG');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.raise_error;
    End if;
   benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE); --Bug 5070692
  End loop;
  benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE); -- Bug5070692
  --
  l_actn := 'Calling Log_statistics...';
  ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_processed
                               ,p_num_pers_errored   => g_persons_errored
                               );
  hr_utility.set_location ('Leaving '||l_proc,70);
Exception
  When others then
    ben_batch_utils.rpt_error(p_proc       => l_proc
                             ,p_last_actn  => l_actn
                             ,p_rpt_flag   => TRUE
                             );
    ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_processed
                                 ,p_num_pers_errored   => g_persons_errored
                                 );
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP',l_actn );
    fnd_message.raise_error;
End do_multithread;
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
    Select process_date
          ,mode_cd
          ,validate_flag
          ,person_id
          ,person_type_id
          ,pgm_id
          ,business_group_id
          ,pl_id
          ,popl_enrt_typ_cycl_id
          ,person_selection_rl
          ,comp_selection_rl
          ,ler_id
          ,organization_id
          ,benfts_grp_id
          ,location_id
          ,legal_entity_id
          ,payroll_id
          ,debug_messages_flag
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
            ,p_person_selection_rule_id => l_parameters.person_selection_rl
            ,p_comp_selection_rule_id   => l_parameters.comp_selection_rl
            ,p_pgm_id                   => l_parameters.pgm_id
            ,p_pl_id                    => l_parameters.pl_id
            ,p_organization_id          => l_parameters.organization_id
            ,p_benfts_grp_id            => l_parameters.benfts_grp_id
            ,p_location_id              => l_parameters.location_id
            ,p_legal_entity_id          => l_parameters.legal_entity_id
            ,p_payroll_id               => l_parameters.payroll_id
            ,p_debug_messages           => l_parameters.debug_messages_flag
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
procedure process(errbuf                        out nocopy varchar2
                 ,retcode                       out nocopy number
                 ,p_benefit_action_id        in     number
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_person_id                in     number   default null
                 ,p_person_type_id           in     number   default null
                 ,p_business_group_id        in     number
                 ,p_person_selection_rule_id in     number   default null
                 ,p_comp_selection_rule_id   in     number   default null
                 ,p_pgm_id                   in     number   default null
                 ,p_pl_id                    in     number   default null
                 ,p_organization_id          in     number   default null
                 ,p_benfts_grp_id            in     number   default null
                 ,p_location_id              in     number   default null
                 ,p_legal_entity_id          in     number   default null
                 ,p_payroll_id               in     number   default null
                 ,p_debug_messages           in     varchar2 default 'N'
                 ) is
  l_effective_date         date;
  l_part_person_id         number;
  --
  -- Cursors declaration.
  --
  cursor c_person is
      Select distinct ecd.dpnt_person_id, pil.person_id
        From ben_prtt_enrt_rslt_f pen,
             ben_elig_cvrd_dpnt_f ecd,
             ben_per_in_ler pil
       Where pen.business_group_id =  p_business_group_id
         and pen.prtt_enrt_rslt_stat_cd is null
         and ( p_pgm_id is null  or pen.pgm_id=p_pgm_id)
         and ( p_pl_id is null or pen.pl_id = p_pl_id)--3808703
        --(pen.pl_id=p_pl_id and pen.pgm_id is null))
         and l_effective_date between
               pen.effective_start_date and pen.effective_end_date
         and l_effective_date between
               pen.enrt_cvg_strt_dt and nvl(pen.enrt_cvg_thru_dt,hr_api.g_eot)
         and ecd.prtt_enrt_rslt_id=pen.prtt_enrt_rslt_id
         and (nvl(ecd.ovrdn_flag,'N')='N' or
              nvl(ecd.ovrdn_thru_dt,l_effective_date)>=l_effective_date)
         and ecd.business_group_id = pen.business_group_id
         and l_effective_date between
               ecd.effective_start_date and ecd.effective_end_date
         and l_effective_date between
               ecd.cvg_strt_dt and ecd.cvg_thru_dt
         and (p_person_id is NULL or pen.person_id = P_person_id)
         and (p_person_type_id is null
                 or exists (select null
                              from per_person_type_usages ptu
                             where ptu.person_id = pen.person_id
                               and ptu.person_type_id = P_person_type_id
                           )
              )
/*         bug 2985206 */
/*         and ( (p_location_id is null and p_organization_id is null
                and p_legal_entity_id is null and p_payroll_id is null
               ) or exists (select null
                              from per_assignments_f asg
                             where nvl(asg.location_id,hr_api.g_number) =
                                       nvl(p_location_id,hr_api.g_number)
                               and nvl(asg.organization_id,hr_api.g_number) =
                                       nvl(p_organization_id,hr_api.g_number)
                               and nvl(asg.soft_coding_keyflex_id,
                                       hr_api.g_number) =
                                       nvl(p_legal_entity_id,hr_api.g_number)
                               and nvl(asg.payroll_id, hr_api.g_number)=
                                       nvl(p_payroll_id,hr_api.g_number)
                               and asg.person_id = pen.person_id
                               and   asg.assignment_type <> 'C'
                               and asg.primary_flag = 'Y'
                               and asg.business_group_id =
                                   pen.business_group_id
                               and l_effective_date between
                                       asg.effective_start_date and
                                       asg.effective_end_date
                             )
              )
*/
         	and (
         		(p_location_id is null and p_organization_id is null
                	and p_payroll_id is null
               	       )
               	       or exists (select null
                              from per_assignments_f asg
                             where nvl(asg.location_id,hr_api.g_number) =
                                       nvl(p_location_id,nvl(asg.location_id,hr_api.g_number))
                               and nvl(asg.organization_id,hr_api.g_number) =
                                       nvl(p_organization_id,nvl(asg.organization_id,hr_api.g_number))
                               and nvl(asg.payroll_id,hr_api.g_number) =
                                       nvl(p_payroll_id,nvl(asg.payroll_id,hr_api.g_number))
                               and asg.person_id = pen.person_id
                               and   asg.assignment_type <> 'C'
                               and asg.primary_flag = 'Y'
                               and asg.business_group_id =
                                   pen.business_group_id
                               and l_effective_date between
                                       asg.effective_start_date and
                                       asg.effective_end_date
                             )
                     )
         and  (p_legal_entity_id is null
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
                       and hsc.segment1 = to_char(p_legal_entity_id)
                       )
              )
	 /* end bug 2985206 */
         and (p_benfts_grp_id is null
               or exists(select null
                          from ben_benfts_grp bng
                               ,/*per_people_f*/ per_all_people_f ppf
                         where bng.benfts_grp_id = p_benfts_grp_id
                           and bng.business_group_id = pen.business_group_id
                           and ppf.person_id = pen.person_id
                           and ppf.benefit_group_id = bng.benfts_grp_id
                           and l_effective_date between
                                  ppf.effective_start_date and
                                  ppf.effective_end_date
                         )
              )
         and    pil.per_in_ler_id=ecd.per_in_ler_id
         --and    pil.business_group_id=ecd.business_group_id
         and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
         --and    pen.prtt_enrt_rslt_stat_cd not in ('VOIDD','BCKDT')
	 and    pen.prtt_enrt_rslt_stat_cd is null
  ;
  --
  -- local variable declaration.
  --
  l_request_id             number;
  l_proc                   varchar2(80) := g_package||'.process';
  l_benefit_action_id      ben_benefit_actions.benefit_action_id%type;
  l_object_version_number  ben_benefit_actions.object_version_number%type;
  l_person_id              /*per_people_f*/ per_all_people_f.person_id%type;
  l_person_action_id       ben_person_actions.person_action_id%type;
  l_ler_id                 ben_ler_f.ler_id%type;
  l_range_id               ben_batch_ranges.range_id%type;
  l_chunk_size             number := 20;
  l_threads                number := 1;
  l_start_person_action_id number := 0;
  l_end_person_action_id   number := 0;
  l_prev_person_id         number := 0;
  rl_ret                   char(1);
  skip                     boolean;
  l_person_cnt             number := 0;
  l_cnt                    number := 0;
  l_actn                   varchar2(80);
  l_num_range              number := 0;
  l_chunk_num              number := 1;
  l_num_row                number := 0;
  l_commit                 number;
  --
Begin

  hr_utility.set_location ('Entering '||l_proc,10);

  --
  /*
  l_effective_date:=to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date:=to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR'),'DD/MM/RRRR');
  */
  l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
  --
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  l_actn := 'Initialize the ben_batch_utils cache...';
  --
  ben_batch_utils.ini;
  --
  l_actn := 'Initialize the ben_batch_utils cache...';
  --
  ben_batch_utils.ini(p_actn_cd => 'PROC_INFO');
  --
  -- Check that all the mandatory input parameters
  -- such as p_business_group_id, p_mode, p_effective_date
  --
  l_actn := 'Checking arguments...';
  hr_api.mandatory_arg_error(p_api_name       => g_package
                            ,p_argument       => 'p_business_group_id'
                            ,p_argument_value => p_business_group_id
                            );
  hr_api.mandatory_arg_error(p_api_name       => g_package
                            ,p_argument       => 'p_effective_date'
                            ,p_argument_value => p_effective_date
                            );
  --
  -- Get chunk_size and Thread values for multi-thread process, and check to
  -- assure they are sensible.
  --        chunk_size between(10 and 100). If not in range, default to 20.
  --        threads between <1 and 100>. If not in range, default to 1
  --
  l_actn := 'Calling benutils.get_parameter...';
  benutils.get_parameter(p_business_group_id  => p_business_group_Id
                        ,p_batch_exe_cd       => 'BENDSGEL'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed);
  benutils.g_benefit_action_id := p_benefit_action_id;
  benutils.g_thread_id         := 99;
  --
  -- Create benefit actions parameters in the benefit action table.
  -- Do not create is a benefit action already exists, in other words
  -- we are doing a restart.
  --
  If(p_benefit_action_id is null) then
    ben_benefit_actions_api.create_benefit_actions
      (p_validate               => false
      ,p_benefit_action_id      => l_benefit_action_id
      ,p_process_date           => l_effective_date
      ,p_mode_cd                => 'S'
      ,p_derivable_factors_flag => 'N'
      ,p_validate_flag          => p_validate
      ,p_person_id              => p_person_id
      ,p_person_type_id         => p_person_type_id
      ,p_pgm_id                 => p_pgm_id
      ,p_business_group_id      => p_business_group_id
      ,p_pl_id                  => p_pl_id
      ,p_popl_enrt_typ_cycl_id  => null
      ,p_no_programs_flag       => 'N'
      ,p_no_plans_flag          => 'N'
      ,p_comp_selection_rl      => p_comp_selection_rule_id
      ,p_person_selection_rl    => p_person_selection_rule_id
      ,p_ler_id                 => null
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
      ,p_debug_messages_flag    => p_debug_messages
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_effective_date
      ,p_request_id             => fnd_global.conc_request_id
      ,p_program_application_id => fnd_global.prog_appl_id
      ,p_program_id             => fnd_global.conc_program_id
      ,p_program_update_date    => sysdate
      );
    benutils.g_benefit_action_id := l_benefit_action_id;
    --
    -- Delete/clear ranges from ben_batch_ranges table
    --
    l_actn := 'Delete rows from ben_batch_ranges..';
    Delete from ben_batch_ranges
     Where benefit_action_id = l_benefit_action_id;
    --
    -- Now lets create person actions for all the people we are going to
    -- process in the BENEADEB run.
    --
    open c_person;
    l_person_cnt := 0;
    l_cnt := 0;
    l_actn := 'Loading person_actions table..';
	Loop
      fetch c_person into l_person_id,l_part_person_id;
      Exit when c_person%notfound;
      l_cnt := l_cnt + 1;
      l_actn := 'Calling ben_batch_utils.person_selection_rule...';
      hr_utility.set_location('person_id='||to_char(l_person_id),999);
      --
      -- if p_person_selection_rule_id is pass, test rule.
      -- If the rule return 'N' then
      -- Bug 5662220: If the rule doesnt return 'Y' or 'N' then also skip the person
      -- skip that person_id.
      --
      skip := FALSE;
      If (p_person_selection_rule_id is not NULL) then
        l_actn := 'Calling Ben_batch_utils.person_selection_rule...';
        rl_ret := ben_batch_utils.person_selection_rule
                    (p_person_id               => l_part_person_id
                    ,p_business_group_id       => p_business_group_id
                    ,p_person_selection_rule_id=> p_person_selection_rule_id
                    ,p_effective_date          => l_effective_date
                    );
--        If (rl_ret = 'N') then
          If (rl_ret <> 'Y') then --Bug 5662220
          skip := TRUE;
        End if;
      End if;
      --
      -- Store person_id into person actions table.
      --
      If ( not skip) then
        l_actn := 'Calling Ben_person_actions_api.create_person_actions...';
        Ben_person_actions_api.create_person_actions
           (p_validate              => false
           ,p_person_action_id      => l_person_action_id
           ,p_person_id             => l_person_id
           ,p_ler_id                => 0
           ,p_benefit_action_id     => l_benefit_action_id
           ,p_action_status_cd      => 'U'
           ,p_chunk_number          => l_chunk_num
           ,p_object_version_number => l_object_version_number
           ,p_effective_date        => l_effective_date
           );
        l_num_row := l_num_row + 1;
        l_person_cnt := l_person_cnt + 1;
        l_end_person_action_id := l_person_action_id;
        If l_num_row = 1 then
          l_start_person_action_id := l_person_action_id;
        End if;
        If l_num_row = l_chunk_size then
          --
          -- Create a range of data to be multithreaded.
          --
          l_actn := 'Calling Ben_batch_ranges_api.create_batch_ranges(in)...';
          Ben_batch_ranges_api.create_batch_ranges
            (p_validate                  => false
            ,p_benefit_action_id         => l_benefit_action_id
            ,p_range_id                  => l_range_id
            ,p_range_status_cd           => 'U'
            ,p_starting_person_action_id => l_start_person_action_id
            ,p_ending_person_action_id   => l_end_person_action_id
            ,p_object_version_number     => l_object_version_number
            ,p_effective_date            => l_effective_date
            );
          l_start_person_action_id := 0;
          l_end_person_action_id := 0;
          l_num_row  := 0;
          l_num_range := l_num_range + 1;
          l_chunk_num := l_chunk_num + 1;
        End if;
      End if;
    End loop;
    Close c_person;
    If (l_num_row <> 0) then
      l_actn := 'Calling Ben_batch_ranges_api.create_batch_ranges(Last)...';
      Ben_batch_ranges_api.create_batch_ranges
        (p_validate                  => false
        ,p_benefit_action_id         => l_benefit_action_id
        ,p_range_id                  => l_range_id
        ,p_range_status_cd           => 'U'
        ,p_starting_person_action_id => l_start_person_action_id
        ,p_ending_person_action_id   => l_end_person_action_id
        ,p_object_version_number     => l_object_version_number
        ,p_effective_date            => l_effective_date
        );
      l_num_range := l_num_range + 1;
    End if;
  Else
    l_benefit_action_id := p_benefit_action_id;
    l_actn := 'Calling Ben_batch_utils.create_restart_person_actions...';
    Ben_batch_utils.create_restart_person_actions
      (p_benefit_action_id  => p_benefit_action_id
      ,p_effective_date     => l_effective_date
      ,p_chunk_size         => l_chunk_size
      ,p_threads            => l_threads
      ,p_num_ranges         => l_num_range
      ,p_num_persons        => l_person_cnt
      );
  End if;
  commit;
  --
  -- Now to multithread the code.
  --
  If l_num_range > 1 then
    For l_count in 1..least(l_threads,l_num_range)-1 loop
      --
      l_actn := 'Submitting job to con-current manager...';
      l_request_id := fnd_request.submit_request
                        (application => 'BEN'
                        ,program     => 'BENMDSGL'
                        ,description => NULL
                        ,sub_request => FALSE
                        ,argument1   => p_validate
                        ,argument2   => l_benefit_action_id
                        ,argument3   => l_count
                        ,argument4   => p_effective_date
                        ,argument5   => p_business_group_id
                        );
      --
      -- Store the request id of the concurrent request
      --
      ben_batch_utils.g_num_processes := ben_batch_utils.g_num_processes + 1;
      ben_batch_utils.g_processes_tbl(ben_batch_utils.g_num_processes)
        := l_request_id;
    End loop;
  Elsif (l_num_range = 0 ) then
    l_actn := 'Calling Ben_batch_utils.print_parameters...';
    Ben_batch_utils.print_parameters
      (p_thread_id                => 99
      ,p_benefit_action_id        => l_benefit_action_id
      ,p_validate                 => p_validate
      ,p_business_group_id        => p_business_group_id
      ,p_effective_date           => l_effective_date
      ,p_mode                     => null
      ,p_comp_selection_rule_id   => p_comp_selection_rule_id
      ,p_pgm_id                   => p_pgm_id
      ,p_pl_id                    => p_pl_id
      ,p_popl_enrt_typ_cycl_id    => null
      ,p_person_id                => p_person_id
      ,p_person_selection_rule_id => p_person_selection_rule_id
      ,p_person_type_id           => p_person_type_id
      ,p_ler_id                   => null
      ,p_organization_id          => p_organization_id
      ,p_benfts_grp_id            => p_benfts_grp_id
      ,p_location_id              => p_location_id
      ,p_legal_entity_id          => p_legal_entity_id
      ,p_payroll_id               => p_payroll_id
      );
      Ben_batch_utils.write(p_text =>
          '<< No Person got selected with above selection criteria >>' );
      fnd_message.set_name('BEN','BEN_91769_NOONE_TO_PROCESS');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.raise_error;
  End if;
  --
  l_actn := 'Calling do_multithread...';
  do_multithread(errbuf               => errbuf
                ,retcode              => retcode
                ,p_validate           => p_validate
                ,p_benefit_action_id  => l_benefit_action_id
                ,p_thread_id          => l_threads+1
                ,p_effective_date     => p_effective_date
                ,p_business_group_id  => p_business_group_id
                );
  --
  l_actn := 'Calling ben_batch_utils.check_all_slaves_finished...';
  --
  ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
  ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                             ,p_person_selected   => l_person_cnt
                             ,p_business_group_id => p_business_group_id);
  submit_all_reports;
  hr_utility.set_location ('Leaving '||l_proc,70);
--
Exception
  when others then
     ben_batch_utils.rpt_error(p_proc      => l_proc
                              ,p_last_actn => l_actn
                              ,p_rpt_flag  => TRUE   );
     benutils.write(p_text => fnd_message.get);
     benutils.write(p_text => sqlerrm);
--     benutils.write(p_text => 'Big Error Occured');
     benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
     If (l_num_range > 0) then
       ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
       ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                                  ,p_person_selected   => l_person_cnt
                                  ,p_business_group_id => p_business_group_id
       ) ;
       -- submit_all_reports;
     End if;
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE', l_proc);
     fnd_message.set_token('STEP', l_actn );
     fnd_message.raise_error;
End process;
--
-- ============================================================================
--                     << comp_selection_Rule >>
-- ============================================================================
--
function comp_selection_rule
                 (p_person_id                in     number
                 ,p_business_group_id        in     number
                 ,p_pgm_id                   in     number
                 ,p_pl_id                    in     number
                 ,p_pl_typ_id                in     number
                 ,p_opt_id                   in     number
                 ,p_ler_id                   in     number
                 ,p_oipl_id                  in     number
                 ,p_comp_selection_rule_id   in     number
                 ,p_effective_date           in     date
                 ) return char is
  cursor c1 is
      select assignment_id,organization_id
        from per_assignments_f paf
       where paf.person_id = p_person_id
         and paf.assignment_type <> 'C'
         and paf.primary_flag = 'Y'
         and paf.business_group_id = p_business_group_id
         and p_effective_date between
                 paf.effective_start_date and paf.effective_end_date;

  Cursor c_state is
  select region_2
  from hr_locations_all loc,per_all_assignments_f asg
  where loc.location_id = asg.location_id
  and asg.person_id = p_person_id
  and asg.primary_flag = 'Y'
       and p_effective_date between
             asg.effective_start_date and asg.effective_end_date
       and asg.business_group_id=p_business_group_id;

  l_jurisdiction_code     varchar2(30);
  l_state c_state%rowtype;
  l_proc   	   varchar2(80) := g_package||'.person_selection_rule';
  l_outputs   	   ff_exec.outputs_t;
  l_return  	   varchar2(30);
  l_assignment_id  number;
  l_organization_id  number;
  l_step           integer;
begin
l_step := 10;
    hr_utility.set_location ('Entering '||l_proc,10);
     --
     -- Get assignment ID,organization_id form per_assignments_f table.
     --
     open c1;
     fetch c1 into l_assignment_id,l_organization_id;
     if c1%notfound then
         ben_batch_utils.rpt_error(p_proc => l_proc,
              p_last_actn => 'Step = '||to_char(l_step),p_rpt_flag => TRUE);
         fnd_message.set_name('BEN','BEN_91698_NO_ASSIGNMENT_FND');
         fnd_message.set_token('PROC',l_proc);
         fnd_message.set_token('ID' , to_char(p_person_id));
         raise ben_maintain_designee_elig.g_record_error;
     end if;
     close c1;
l_step := 20;
     --

/* -- 4031733 - Cursor c_state populates l_state variable which is no longer
   -- used in the package. Cursor can be commented

     if p_person_id is not null then
       open c_state;
       fetch c_state into l_state;
       close c_state;

       if l_state.region_2 is not null then
         l_jurisdiction_code :=
            pay_mag_utils.lookup_jurisdiction_code
              (p_state => l_state.region_2);
       end if;
     end if;
*/
     -- Call formula initialise routine
     --
     l_outputs := benutils.formula
                      (p_formula_id        => p_comp_selection_rule_id
                      ,p_effective_date    => p_effective_date
                      ,p_pgm_id            => p_pgm_id
                      ,p_pl_id             => p_pl_id
                      ,p_pl_typ_id         => p_pl_typ_id
                      ,p_opt_id            => p_opt_id
                      ,p_ler_id            => p_ler_id
                      ,p_business_group_id => p_business_group_id
                      ,p_assignment_id     => l_assignment_id
                      ,p_organization_id   => l_organization_id
                      ,p_jurisdiction_code => l_jurisdiction_code);

     l_return := l_outputs(l_outputs.first).value;
l_step := 30;
     if upper(l_return) not in ('Y', 'N')  then
          --
          -- Defensive coding for Non Y return
          --
          ben_batch_utils.rpt_error(p_proc => l_proc,
              p_last_actn => 'Step = '||to_char(l_step),p_rpt_flag => TRUE);
          fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
          fnd_message.set_token('RL','formula_id :'||p_comp_selection_rule_id);
          fnd_message.set_token('PROC',l_proc);
          raise ben_maintain_designee_elig.g_record_error;
     end if;
     return l_return;
     hr_utility.set_location ('Leaving '||l_proc,10);
exception
    when others then
         ben_batch_utils.rpt_error(p_proc => l_proc,
                p_last_actn => 'Step = '||to_char(l_step),p_rpt_flag => TRUE);
         raise;
end comp_selection_rule;
--
-- ============================================================================
--                   << Procedure: process_designee_elig >>
-- ============================================================================
--
Procedure Process_designee_elig
                  (p_validate              in     varchar2 default 'N'
                  ,p_person_id             in     number default null
                  ,p_person_action_id      in     number default null
                  ,p_comp_selection_rl     in     number
                  ,p_pgm_id                in     number
                  ,p_pl_id                 in     number
                  ,p_object_version_number in out nocopy number
                  ,p_business_group_id     in     number
                  ,p_effective_date        in     date
                  ) is
  --
  -- Local Cursor
  --
  cursor c_designation is
      Select pen.pgm_id,
             pen.pl_id,
             pen.pl_typ_id,
             pen.oipl_id,
             pen.person_id,
             pen.ptip_id,
             pen.ler_id,
             ecd.elig_cvrd_dpnt_id,
             ecd.object_version_number,
             ecd.ovrdn_flag,
             ecd.ovrdn_thru_dt,
             ecd.cvg_strt_dt,
             ecd.effective_start_date,
             ctr.contact_relationship_id,
             ctr.contact_type,
             ctr.date_end, -- 5100008 Added this
             -- CWB Changes.
             ecd.per_in_ler_id
        From ben_prtt_enrt_rslt_f pen,
             ben_elig_cvrd_dpnt_f ecd,
             ben_per_in_ler pil,
             per_contact_relationships ctr
       Where pen.business_group_id =  p_business_group_id
         and pen.prtt_enrt_rslt_stat_cd is null
         and ecd.dpnt_person_id = p_person_id
         and (nvl(ecd.ovrdn_flag,'N')='N' or
              nvl(ecd.ovrdn_thru_dt,p_effective_date)>=p_effective_date)
         and p_effective_date between
               pen.effective_start_date and pen.effective_end_date
         and p_effective_date between
               pen.enrt_cvg_strt_dt and nvl(pen.enrt_cvg_thru_dt,
                                            hr_api.g_eot)
         and ecd.prtt_enrt_rslt_id=pen.prtt_enrt_rslt_id
         and ecd.business_group_id = pen.business_group_id
         and p_effective_date between
               ecd.effective_start_date and ecd.effective_end_date
         and p_effective_date between
              ecd.cvg_strt_dt and ecd.cvg_thru_dt
         and ctr.person_id=pen.person_id
         -- Bug 3056894
         and ctr.personal_flag='Y'
         and ctr.business_group_id=p_business_group_id
         and ctr.contact_person_id=p_person_id
         and pil.per_in_ler_id=ecd.per_in_ler_id
         and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
         --and    pen.prtt_enrt_rslt_stat_cd not in ('VOIDD','BCKDT')
	 and    pen.prtt_enrt_rslt_stat_cd is null
  ;
  --
     cursor c_opt(l_oipl_id  number) is
	select opt_id from ben_oipl_f oipl
	where oipl.oipl_id = l_oipl_id
         and p_effective_date between
               oipl.effective_start_date and oipl.effective_end_date;

  l_opt c_opt%rowtype;
  --
  cursor c_dpnt_dsgn_lvl(v_pgm_id in number) is
     select pgm.dpnt_dsgn_lvl_cd
     from   ben_pgm_f pgm
     where  pgm.pgm_id            = v_pgm_id
     and    pgm.business_group_id = p_business_group_id
     and    p_effective_date between
            pgm.effective_start_date and pgm.effective_end_date;
  --
  cursor c_ptip_elig(v_person_id in number,
                     v_ptip_id   in number) is
     select pep.elig_per_id
     from   ben_elig_per_f pep,
            ben_pl_f       pln,
            ben_ptip_f     ptip,
            ben_per_in_ler pil
     where  pep.person_id  = v_person_id
     and    pep.pl_id      = pln.pl_id
     and    pln.pl_typ_id  = ptip.pl_typ_id
     and    ptip.ptip_id   = v_ptip_id
     and    ptip.pgm_id    = pep.pgm_id
     and    p_effective_date between
            pep.effective_start_date and pep.effective_end_date
     and    p_effective_date between
            pln.effective_start_date and pln.effective_end_date
     and    p_effective_date between
            ptip.effective_start_date and ptip.effective_end_date
     and    pep.per_in_ler_id = pil.per_in_ler_id(+)
     and    (pil.per_in_ler_stat_cd is null OR
             pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT'));
  --
  cursor c_pgm_elig(v_person_id in number,
                    v_pgm_id    in number) is
     select pep.elig_per_id
     from   ben_elig_per_f pep,
            ben_per_in_ler pil
     where  pep.person_id  = v_person_id
     and    pep.pgm_id     = v_pgm_id
     and    pep.pl_id is not null
     and    p_effective_date between
            pep.effective_start_date and pep.effective_end_date
     and    pep.per_in_ler_id = pil.per_in_ler_id(+)
     and    (pil.per_in_ler_stat_cd is null OR
             pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT'));
  --
  cursor c_pl_elig(v_person_id  in number,
                   v_pl_id      in number,
                   v_pgm_id     in number) is
     select pep.elig_per_id
     from   ben_elig_per_f pep,
            ben_per_in_ler pil
     where  pep.person_id      = v_person_id
     and    pep.pl_id          = v_pl_id
     and    ((v_pgm_id is null and pep.pgm_id is null) OR
             (pep.pgm_id = v_pgm_id))
     and    p_effective_date between
            pep.effective_start_date and pep.effective_end_date
     and    pep.per_in_ler_id = pil.per_in_ler_id(+)
     and    (pil.per_in_ler_stat_cd is null OR
             pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT'));
  --
  cursor c_max_create_dt(v_elig_per_id in number) is
     select max(egd.create_dt)
     from   ben_elig_dpnt  egd,
            ben_per_in_ler pil
     where  egd.elig_per_id    = v_elig_per_id
     and    egd.dpnt_person_id = p_person_id
     and    egd.per_in_ler_id  = pil.per_in_ler_id (+)
     and    (pil.per_in_ler_stat_cd is null OR
             pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT'));
  --
  cursor c_egd(v_elig_per_id in number,
               v_create_dt   in date) is
     select egd.*
     from   ben_elig_dpnt  egd,
            ben_per_in_ler pil
     where  egd.elig_per_id = v_elig_per_id
     and    egd.dpnt_person_id = p_person_id
     and    egd.dpnt_inelig_flag = 'N'
     and    egd.create_dt = v_create_dt
     and    egd.per_in_ler_id = pil.per_in_ler_id (+)
     and    (pil.per_in_ler_stat_cd is null OR
             pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')) ;
  --
  -- Local Variables
  --
  l_proc                  Varchar2(80) := g_package || '.process_designee_elig';
  l_output_string         Varchar2(80);
  l_validate              boolean;
  l_actn                  varchar2(80);
  l_action                varchar2(30);
  l_rule_ret              varchar2(30);
  l_elig_flag             varchar2(30);
  l_inelig_rsn_cd         varchar2(30);
  l_datetrack_mode        varchar2(30);
  l_pel_cnt               binary_integer := 0;
  l_susp_flag             boolean;
  l_output                varchar2(2000);
  l_person_ended          varchar2(30):='N';
  l_this_person_ended     varchar2(30);
  l_part_person_id        number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_level                 varchar2(30):=null; -- it will figure it out
  l_returned_strt_dt      date;
  l_object_version_number number;
  l_perhasmultptus        boolean;
  l_assignment_id         number;
  l_returned_end_dt       date;
  l_cache                 g_report_table;
  l_id                    number;
  l_ovn1                  number;
  l_cache_cnt             number:=0;
  l_found                 boolean := false;
  l_egd_rec               ben_elig_dpnt%rowtype;
  l_dummy                 varchar2(1);
  l_comp_ineligible       boolean := FALSE;
  l_temp_person_id        number;
  l_min_returned_end_dt   date;
  l_elig_per_id           number;
  l_max_create_dt         date;
  l_egd_elig_thru_dt      date; -- 5100008

  --
begin
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
  For l_rec in c_designation loop
    hr_utility.set_location(l_proc,101);

    l_returned_end_dt:=null;

    if l_rec.oipl_id is not null then
	open c_opt(l_rec.oipl_id);
	fetch c_opt into l_opt;
	close c_opt;
    end if;

    l_this_person_ended:='N';
    l_part_person_id:=l_rec.person_id;
    l_pel_cnt := l_pel_cnt + 1;
    --
    l_actn := 'Processing (person:' ||to_char(p_person_id) ||
              ' pgm:' || to_char(l_rec.pgm_id) ||
              ' Pl_no_Pgm:' || to_char(l_rec.pl_id) ||  ')';
    --
    --
    -- Check if the comp object requirements are satisfied
    -- Note: pgm_id and pl_id args already checked in the cursor
    --
    l_rule_ret:='Y';
    if p_comp_selection_rl is not null then
      hr_utility.set_location(l_proc,102);
      l_rule_ret:=comp_selection_rule(
                p_person_id                => p_person_id
               ,p_business_group_id        => p_business_group_id
               ,p_pgm_id                   => l_rec.pgm_id
               ,p_pl_id                    => l_rec.pl_id
               ,p_pl_typ_id                => l_rec.pl_typ_id
               ,p_opt_id                   => l_opt.opt_id
               ,p_oipl_id                  => l_rec.oipl_id
               ,p_ler_id                   => l_rec.ler_id
               ,p_comp_selection_rule_id   => p_comp_selection_rl
               ,p_effective_date           => p_effective_date
      );
    end if;
    hr_utility.set_location(l_proc,103);
    if l_rule_ret='Y' then
      hr_utility.set_location(l_proc,104);
      --
      -- Check to see if the dependent is still eligible
      --
      hr_utility.set_location('contact_person_id='||to_char(p_person_id),1100);
      hr_utility.set_location('oipl_id='||to_char(l_rec.oipl_id),1100);
      hr_utility.set_location('ptip_id='||to_char(l_rec.ptip_id),1100);
      hr_utility.set_location('pl_id='||to_char(l_rec.pl_id),1100);
      hr_utility.set_location('pgm_id='||to_char(l_rec.pgm_id),1100);
      hr_utility.set_location('contact_relationship_id_id='||to_char(l_rec.contact_relationship_id),1100);
      --
      if l_rec.pgm_id is not null then
        --
        open  c_dpnt_dsgn_lvl(l_rec.pgm_id);
        fetch c_dpnt_dsgn_lvl into l_level;
        close c_dpnt_dsgn_lvl;
        --
      end if;
      --
      if l_level is null then
        --
        l_level := 'PL';
        --
      end if;
      --
      ben_evaluate_dpnt_elg_profiles.main
        (p_contact_relationship_id  => l_rec.contact_relationship_id,
	 p_contact_person_id        => p_person_id,
	 p_pgm_id                   => l_rec.pgm_id,
	 p_pl_id                    => l_rec.pl_id,
	 p_ptip_id                  => l_rec.ptip_id,
	 p_oipl_id                  => l_rec.oipl_id,
	 p_business_group_id        => p_business_group_id,
	 p_per_in_ler_id            => null,
         p_lf_evt_ocrd_dt           => null,
	 p_effective_date           => p_effective_date,
         p_dpnt_cvg_strt_dt         => l_rec.cvg_strt_dt,
	 p_level                    => l_level,
	 p_dependent_eligible_flag  => l_elig_flag,
         p_dpnt_inelig_rsn_cd       => l_inelig_rsn_cd);
        --
        -- If the dependent is not eligible end date row
        --
      hr_utility.set_location(l_proc,105);
      hr_utility.set_location('l_elig_flag'||l_elig_flag,8888);
      --
      if l_elig_flag<>'Y' then
        --
        hr_utility.set_location(l_proc,106);
        --
        -- 5100008  : Added this to fetch EGD ELIG_THRU_DT
        if (l_rec.date_end <= p_effective_date) then
           l_egd_elig_thru_dt := l_rec.date_end;
        else
          l_egd_elig_thru_dt := ben_evaluate_dpnt_elg_profiles.get_elig_change_dt;
        end if;
        -- 5100008 ENDS

        --
        -- Get the dpnt cvg end date
        -- Bug 5442301 -- dont update cvg_thru date if it is overriden
	 hr_utility.set_location('SARKAR l_rec.ovrdn_flag '||l_rec.ovrdn_flag,8888);
	 hr_utility.set_location('SARKAR l_rec.ovrdn_thru_dt '||l_rec.ovrdn_thru_dt,8888);


	 if nvl(l_rec.ovrdn_flag,'N') = 'Y' and
	    nvl(l_rec.ovrdn_thru_dt,hr_api.g_eot) >= p_effective_date then

               null;
	 else
               calc_dpnt_cvg_end_dt(
                p_person_id              => l_rec.person_id
               ,p_pgm_id                 => l_rec.pgm_id
               ,p_pl_id                  => l_rec.pl_id
               ,p_oipl_id                => l_rec.oipl_id
               ,p_ptip_id                => l_rec.ptip_id
               ,p_business_group_id      => p_business_group_id
               ,p_effective_date         => p_effective_date
               ,p_returned_end_dt        => l_returned_end_dt);
        end if;

        --

--        if nvl(l_min_returned_end_dt, l_returned_end_dt) >= l_returned_end_dt then
          -- 5100008 : BEN_ASG needs to be created on ELIG_THRU_DT, not on CVG_THRU_DT
          -- Hence commented above line.
          if nvl(l_min_returned_end_dt, l_egd_elig_thru_dt) >= l_egd_elig_thru_dt then

           --
           l_comp_ineligible := TRUE;
           l_temp_person_id  := l_rec.person_id;
           l_min_returned_end_dt := l_egd_elig_thru_dt;
           --
        end if;
        --
        -- Call api
        --
        if p_effective_date=l_rec.effective_start_date then
          l_datetrack_mode:=hr_api.g_correction;
        else
          l_datetrack_mode:=hr_api.g_update;
        end if;
        --
        -- According to the cursor, the coverage has started as of the
        -- effective date, so the coverage through date should atleast be
        -- the coverge start date. If the coverage through date is less
        -- than the coverage start date, we assign a value of effective
        -- date.
        --
        if l_returned_end_dt < l_rec.cvg_strt_dt then
           --
           l_returned_end_dt := p_effective_date;
           --
        end if;
        --
        hr_utility.set_location('pdp_id='||to_char(l_rec.elig_cvrd_dpnt_id),111);
        hr_utility.set_location('cvg_thru_dt='||to_char(l_returned_end_dt),112);
        -- -- Bug 5442301 -- dont update cvg_thru date if it is overriden
     if     nvl(l_rec.ovrdn_flag,'N') = 'Y' and
	    nvl(l_rec.ovrdn_thru_dt,hr_api.g_eot) >= p_effective_date then

               null;
     else
        ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt(
          p_elig_cvrd_dpnt_id     => l_rec.elig_cvrd_dpnt_id
         ,p_effective_start_date  => l_effective_start_date
         ,p_effective_end_date    => l_effective_end_date
         ,p_object_version_number => l_rec.object_version_number
         ,p_business_group_id     => p_business_group_id
         ,p_effective_date        => p_effective_date
         ,p_cvg_thru_dt           => l_returned_end_dt
         ,p_datetrack_mode        => l_datetrack_mode
         ,p_program_application_id => fnd_global.prog_appl_id
         ,p_program_id             => fnd_global.conc_program_id
         ,p_request_id             => fnd_global.conc_request_id
         ,p_program_update_date    => sysdate
         ,p_multi_row_actn        => false
        );
    end if;
        --
        l_found := ben_ELIG_DPNT_api.get_elig_dpnt_rec(
                      p_elig_cvrd_dpnt_id     => l_rec.elig_cvrd_dpnt_id
                     ,p_effective_date        => p_effective_date
                     ,p_elig_dpnt_rec         => l_egd_rec);
        --
        if l_found and l_egd_rec.dpnt_inelig_flag = 'N' then
           --
           ben_elig_dpnt_api.update_elig_dpnt(
              p_elig_dpnt_id          => l_egd_rec.elig_dpnt_id
             ,p_object_version_number => l_egd_rec.object_version_number
             ,p_effective_date        => p_effective_date
             ,p_elig_thru_dt          => l_egd_elig_thru_dt --l_returned_end_dt 5100008
             ,p_dpnt_inelig_flag      => 'Y'
             ,p_inelg_rsn_cd          => l_inelig_rsn_cd
              );
           --
        end if;
        --
        if l_level = 'PGM' then
          --
          open c_pgm_elig(l_rec.person_id,
                          l_rec.pgm_id);
          --
        elsif l_level = 'PTIP' then
          --
          open c_ptip_elig(l_rec.person_id,
                           l_rec.ptip_id);
          --
        elsif l_level = 'PL' then
          --
          open c_pl_elig(l_rec.person_id,
                         l_rec.pl_id,
                         l_rec.pgm_id);
          --
        end if;
        --
        loop
          --
          if l_level = 'PGM' then
            --
            fetch c_pgm_elig into l_elig_per_id;
            --
            if c_pgm_elig%notfound then
              --
              exit;
              --
            end if;
            --
          elsif l_level = 'PTIP' then
            --
            fetch c_ptip_elig into l_elig_per_id;
            --
            if c_ptip_elig%notfound then
              --
              exit;
              --
            end if;
            --
          elsif l_level = 'PL' then
            --
            fetch c_pl_elig into l_elig_per_id;
            --
            if c_pl_elig%notfound then
              --
              exit;
              --
            end if;
            --
          else
            --
            exit;
            --
          end if;
          --
          open  c_max_create_dt(l_elig_per_id);
          fetch c_max_create_dt into l_max_create_dt;
          close c_max_create_dt;
          --
          for l_egd in c_egd(l_elig_per_id, l_max_create_dt) loop
            --
            ben_elig_dpnt_api.update_elig_dpnt(
              p_elig_dpnt_id          => l_egd.elig_dpnt_id
             ,p_object_version_number => l_egd.object_version_number
             ,p_effective_date        => p_effective_date
             ,p_elig_thru_dt          => l_egd_elig_thru_dt --l_returned_end_dt
             ,p_dpnt_inelig_flag      => 'Y'
             ,p_inelg_rsn_cd          => l_inelig_rsn_cd);
            --
          end loop;
          --
        end loop;
        --
        if l_level = 'PGM' then
          --
          close c_pgm_elig;
          --
        elsif l_level = 'PTIP' then
          --
          close c_ptip_elig;
          --
        elsif l_level = 'PL' then
          --
          close c_pl_elig;
          --
        end if;
        --
        /* --
        -- Create benefits assignment for dependent - COBRA requirement.
        --
        ben_assignment_internal.copy_empasg_to_benasg
          (p_person_id             => l_rec.person_id
          ,p_dpnt_person_id        => p_person_id
          ,p_effective_date        => l_returned_end_dt + 1
          ,p_assignment_id         => l_assignment_id
          ,p_object_version_number => l_object_version_number
          ,p_perhasmultptus        => l_perhasmultptus
          );
        */
        --
        -- Create communication if required
        --
        ben_generate_communications.main
          (p_person_id             => l_rec.person_id,
           p_dpnt_person_id        => p_person_id,
           -- CWB Changes.
           p_per_in_ler_id         => l_rec.per_in_ler_id,
           p_pgm_id                => l_rec.pgm_id,
           p_pl_id                 => l_rec.pl_id,
           p_pl_typ_id             => l_rec.pl_typ_id,
           p_business_group_id     => p_business_group_id,
           p_proc_cd1              => 'DPNTENDENRT',
           p_proc_cd2              => 'HPADPNTLC',
           p_effective_date        => p_effective_date,
           p_lf_evt_ocrd_dt        => ben_evaluate_dpnt_elg_profiles.get_elig_change_dt,
           p_source                => 'bendsgel');
        --
        g_designations_ended:=g_designations_ended+1;
        l_person_ended:='Y';
        l_this_person_ended:='Y';
      else
        hr_utility.set_location(l_proc,107);
        g_designations_remaining:=g_designations_remaining+1;
      end if;
      hr_utility.set_location(l_proc,108);
      --
    end if;
    --
    -- write the audit info for this
    --
    -- bump up the counter
    --
    l_cache_cnt:=l_cache_cnt+1;
    --
    -- set the values in cache, this cache is so that rollback may
    -- happen (p_validate set) and still the audit will be written
    --
    if l_this_person_ended='Y' then
      l_cache(l_cache_cnt).actn_cd:='ENDED';
    else
      l_cache(l_cache_cnt).actn_cd:='NOCHG';
    end if;
    l_cache(l_cache_cnt).person_id:=l_rec.person_id;
    l_cache(l_cache_cnt).pgm_id:=l_rec.pgm_id;
    l_cache(l_cache_cnt).pl_id:=l_rec.pl_id;
    l_cache(l_cache_cnt).oipl_id:=l_rec.oipl_id;
    l_cache(l_cache_cnt).contact_type:=l_rec.contact_type;
    l_cache(l_cache_cnt).dpnt_cvg_strt_dt:=l_rec.cvg_strt_dt;
    l_cache(l_cache_cnt).dpnt_cvg_thru_dt:=l_returned_end_dt;
    --
    hr_utility.set_location(l_proc,109);
    --
  end loop;
  --
  if l_comp_ineligible  then
      --
      -- Person is ineligible for atleast one comp object
      -- Create benefits assignment for dependent - COBRA requirement.
      --
      ben_assignment_internal.copy_empasg_to_benasg
          (p_person_id             => l_temp_person_id
          ,p_dpnt_person_id        => p_person_id
          ,p_effective_date        => least(l_min_returned_end_dt+1, p_effective_date+1)
          ,p_assignment_id         => l_assignment_id
          ,p_object_version_number => l_object_version_number
          ,p_perhasmultptus        => l_perhasmultptus
          );
      --
  end if;
  --
  hr_utility.set_location(l_proc,110);
  l_actn := 'Calling Ben_batch_utils.write_comp...';
  Ben_batch_utils.write_comp(p_business_group_id => p_business_group_id
                            ,p_effective_date    => p_effective_date
                            );
  l_actn := 'Calling write_rec (category)...';
  If (p_validate = 'Y') then
    Rollback to process_default_enrt_savepoint;
  End if;
  --
  -- Store the participant Id on the related_person_id so that
  -- may get participant counts for summary report
  --
  ben_batch_utils.g_rec.related_person_id:=l_part_person_id;
  hr_utility.set_location('g_profile_value = '||g_profile_value,100);
  if l_person_ended='Y' then
    Ben_batch_utils.write_rec(p_typ_cd => 'DSGENDED');
  else
    --
    --Bug 1579948 Fix
    --
    if(g_profile_value <> 'N') then
      --
      Ben_batch_utils.write_rec(p_typ_cd => 'DSGNOCHG');
      --
    end if;
    --
  end if;
  --
  -- write audit report info
  --
  -- Bug 1579948 Fix: Added if stmt to restrict a row to write into
  -- ben_batch_dpnt_info if the g_profile_value set to "No". This is
  -- done for improving the performance of audit log
  --
  For i in 1..l_cache_cnt Loop
    hr_utility.set_location(l_proc||' pgm_id='||to_char(l_cache(i).pgm_id),111);
    if((l_cache(i).actn_cd = 'ENDED')
       or (l_cache(i).actn_cd = 'NOCHG'
          and nvl(g_profile_value, 'Y') = 'Y')) then
      ben_batch_dpnt_info_api.create_batch_dpnt_info
            (p_batch_dpnt_id         => l_id
            ,p_person_id             => l_cache(i).person_id
            ,p_benefit_action_id     => benutils.g_benefit_action_id
            ,p_business_group_id     => p_business_group_id
            ,p_pgm_id                => l_cache(i).pgm_id
            ,p_pl_id                 => l_cache(i).pl_id
            ,p_oipl_id               => l_cache(i).oipl_id
            ,p_contact_typ_cd        => l_cache(i).contact_type
            ,p_enrt_cvg_strt_dt      => l_cache(i).dpnt_cvg_strt_dt
            ,p_enrt_cvg_thru_dt      => l_cache(i).dpnt_cvg_thru_dt
            ,p_actn_cd               => l_cache(i).actn_cd
            ,p_object_version_number => l_ovn1
            ,p_dpnt_person_id        => p_person_id
            ,p_effective_date        => p_effective_date
       );
    end if;
  End loop;
  --
  If p_person_action_id is not null then
    --
    l_actn := 'Calling ben_person_actions_api.update_person_actions...';
    --
    ben_person_actions_api.update_person_actions
      (p_person_action_id      => p_person_action_id
      ,p_action_status_cd      => 'P'
      ,p_object_version_number => p_object_version_number
      ,p_effective_date        => p_effective_date
      );
  End if;
  g_persons_processed := g_persons_processed + 1;
  commit;
  hr_utility.set_location ('Leaving '|| l_proc,10);
Exception
  When others then
    rollback to process_default_enrt_savepoint;
    g_persons_errored := g_persons_errored + 1;
    -- capture the error message
    benutils.write(p_text => fnd_message.get);
    benutils.write(p_text => sqlerrm);
    ben_batch_utils.write_error_rec;
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
    commit;
    raise ben_batch_utils.g_record_error;
end process_designee_elig;
--
end ben_maintain_designee_elig;  -- End of Package.

/
