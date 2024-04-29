--------------------------------------------------------
--  DDL for Package Body BEN_PREMIUM_CONCURRENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PREMIUM_CONCURRENT" as
/* $Header: benprcon.pkb 120.1 2006/07/04 13:38:09 swjain ship $ */
--
/* ============================================================================
*    Name
*       Premium Process Concurrent Manager Processes
*
*    Purpose
*       This package simply houses the concurrent manager and multi-thread
*       processes for Premium Calculation.
*
*    History
*      Date        Who        Version    What?
*      -------     ---------  -------    --------------------------------------
*      18-Jun-99   lmcdonal   115.0      Created
*      08-Jul-99   lmcdonal   115.1      Added reporting
*      20-JUL-99   Gperry     115.2      genutils -> benutils package rename.
*      23-Jul-99   lmcdonal   115.3      add distinct to main cursor.
*      06-Oct-99   tguy       115.4      added call to dt_fndate
*      12-Oct-99   maagrawa   115.5      ben_env_object.init call added
*                                        to do_multithread.
*      02-Nov-99   lmcdonal   115.6      Make ben_prem_pl_oipl_monthly
*                                        multi-threaded.
*      08-Nov-99   lmcdonal   115.7      The last 3 parms were missing from
*                                        'BENPRCOM' submit_request call.
*                                        p_first_day parm of multithread s/b char.
*      27-Feb-00   lmcdonal   115.8      Better debug messages.  Also, do not fail
*                                        if first of 3 processes finds noone to
*                                        process.
*      26-Apr-02    nhunur      115.9    Fix for bug  2345799 / 13530340.6
*      08-Jun-02   pabodla      115.10   Do not select the contingent worker
*                                        assignment when assignment data is
*                                        fetched.
*      17-Jun-02    vsethi      115.11   Modified the person determination
*					 criteria to include organization and
*					 legal entity
*      18-Jun-02    vsethi      115.12   Modified the sub_query in c_person cursor
*					 to refer the person_id of outer query and
*					 not p_person_id
*      30-Dec-2002 mmudigon     115.14   NOCOPY
*      07-Jan-2003 rpgupta      115.15   Removed l_return from procedure
*					 prem_person_selection_rule as formula was
*					 not being picked up
*      04-Jun-2006 swjain       115.16   Bug 5331889 - passed person_id as input param
*                                        in prem_person_selection_rule and added input1 as
*                                        additional param for future use
* -----------------------------------------------------------------------------
*/
--
-- Global cursor and variables declaration
--
g_package                 varchar2(80) := 'Ben_premium_concurrent';
g_persons_processed       number(9) := 0;
g_persons_ended           number(9) := 0;
g_persons_passed          number(9) := 0;
g_persons_errored         number(9) := 0;
g_max_errors_allowed      number(9) := 200;
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
  l_actn := 'Calling ben_batch_utils.batch_report (BENPRSUM)...';
  ben_batch_utils.batch_report
         (p_concurrent_request_id => fnd_global.conc_request_id
         ,p_program_name          => 'BENPRSUM'
         ,p_request_id            => l_request_id
         );
  l_actn := 'Calling ben_batch_utils.batch_report (BENPRDEA)...';
  ben_batch_utils.batch_report
         (p_concurrent_request_id => fnd_global.conc_request_id
         ,p_program_name          => 'BENPRDEA'
         ,p_request_id            => l_request_id
         );
  l_actn := 'Calling ben_batch_utils.batch_report (BENERTYP)...';
  ben_batch_utils.batch_report
         (p_concurrent_request_id => fnd_global.conc_request_id
         ,p_program_name          => 'BENERTYP'
         ,p_request_id            => l_request_id
         );
  l_actn := 'Calling ben_batch_utils.batch_report (BENERPER)...';
  ben_batch_utils.batch_report
         (p_concurrent_request_id => fnd_global.conc_request_id
         ,p_program_name          => 'BENERPER'
         ,p_request_id            => l_request_id
         );

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
-- ==================================================================================
--                        << Procedure: prem_person_selection_rule >>
--  Description:
--      this procedure is called from 'process'.  It calls the person selection rule.
--   this has been added to report errors for a person while executing the selection rule
--   and prevent the conc process from failing .
-- ==================================================================================
procedure prem_person_selection_rule
		 (p_person_id                in  Number
                 ,p_business_group_id        in  Number
                 ,p_person_selection_rule_id in  Number
                 ,p_effective_date           in  Date
                 ,p_batch_flag               in  Boolean default FALSE
                 ,p_input1                   in  varchar2 default null    -- Bug 5331889
                 ,p_input1_value             in  varchar2 default null
		 ,p_return                   in out nocopy varchar2
                 ,p_err_message              in out nocopy varchar2 ) as

  Cursor c1 is
      Select assignment_id
        From per_assignments_f paf
       Where paf.person_id = p_person_id
         and paf.assignment_type <> 'C'
         And paf.primary_flag = 'Y'
         And paf.business_group_id = p_business_group_id
         And p_effective_date between
                 paf.effective_start_date and paf.effective_end_date ;
  --
  l_proc   	       varchar2(80) := g_package||'.prem_person_selection_rule';
  l_outputs   	   ff_exec.outputs_t;
  --l_return  	   varchar2(30);
  l_assignment_id  number;
  l_actn           varchar2(80);
  value_exception  exception ;
Begin
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Get assignment ID form per_assignments_f table.
  --
  l_actn := 'Opening C1 Assignment cursor...';
  open c1;
  fetch c1 into l_assignment_id;
  If c1%notfound then
      raise ben_batch_utils.g_record_error;
  End if;
  close c1;
  -- Call formula initialise routine
  --
  l_actn := 'Calling benutils.formula procedure...';

  l_outputs := benutils.formula
                      (p_formula_id        => p_person_selection_rule_id
                      ,p_effective_date    => p_effective_date
                      ,p_business_group_id => p_business_group_id
                      ,p_assignment_id     => l_assignment_id
                      ,p_param1            => 'BEN_IV_PERSON_ID'          -- Bug 5331889
                      ,p_param1_value      => to_char(p_person_id)
                      ,p_param2            => p_input1
                      ,p_param2_value      => p_input1_value);
  p_return := l_outputs(l_outputs.first).value;
  --
  l_actn := 'Evaluating benutils.formula return...';
  --
  If upper(p_return) not in ('Y', 'N')  then
      Raise value_exception ;
  End if;
  --p_return := 'Y';
  hr_utility.set_location ('Leaving '||l_proc,10);
Exception
  When ben_batch_utils.g_record_error then
      p_return := 'N' ;
      fnd_message.set_name('BEN','BEN_91698_NO_ASSIGNMENT_FND');
      fnd_message.set_token('ID' ,to_char(p_person_id) );
      fnd_message.set_token('PROC',l_proc  ) ;
	  p_err_message := fnd_message.get ;

  When value_exception then
      p_return := 'N' ;
      fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
      fnd_message.set_token('RL','person_selection_rule_id :'||p_person_selection_rule_id);
      fnd_message.set_token('PROC',l_proc  ) ;
	  p_err_message := fnd_message.get ;

  when others then
      p_return := 'N' ;
      p_err_message := 'A unhandled exception has been raised while processing Person : '||to_char(p_person_id)
                       ||' in package : '|| l_proc ||'.';

End prem_person_selection_rule;
--
-- ============================================================================
--                        << Procedure: Do_Multithread >>
--  Description:
--      this procedure is called from 'process'.  It calls the premium routine.
-- ============================================================================
procedure do_multithread
             (errbuf                     out nocopy varchar2
             ,retcode                    out nocopy number
             ,p_validate              in     varchar2 default 'N'
             ,p_benefit_action_id     in     number
             ,p_thread_id             in     number
             ,p_effective_date        in     varchar2
             ,p_business_group_id     in     number
             ,p_mo_num                in     number
             ,p_yr_num                in     number
             ,p_first_day_of_month    in     varchar2
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
 l_first_day_of_month     date;
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
  l_ovn                number := null;
  l_commit number;
  l_error_text         varchar2(200) := null;

Begin

  hr_utility.set_location ('Entering '||l_proc,05);

  l_effective_date:=to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date:=to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR'),'DD/MM/RRRR');

  l_first_day_of_month:=to_date(p_first_day_of_month,'YYYY/MM/DD HH24:MI:SS');
  l_first_day_of_month:=to_date(to_char(trunc(l_first_day_of_month),'DD/MM/RRRR'),'DD/MM/RRRR');
  --
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  l_actn := 'Calling benutils.get_parameter...';
  benutils.get_parameter(p_business_group_id  => p_business_group_Id
                        ,p_batch_exe_cd       => 'BENPRCON'
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
          ,p_pl_typ_id                => l_parm.pl_typ_id
          ,p_pl_id                    => l_parm.pl_id
          ,p_person_type_id           => l_parm.person_type_id
          ,p_ler_id                   => null
          ,p_organization_id          => l_parm.organization_id
          ,p_benfts_grp_id            => null
          ,p_location_id              => null
          ,p_legal_entity_id          => l_parm.legal_entity_id
          ,p_payroll_id               => null
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

      l_actn := 'Loading person data into g_cache_person_process cache...';
      fetch c_person_thread
        into g_cache_person_process(l_record_number+1).person_id
            ,g_cache_person_process(l_record_number+1).person_action_id
            ,g_cache_person_process(l_record_number+1).object_version_number
            ,g_cache_person_process(l_record_number+1).ler_id;
      exit when c_person_thread%notfound;
      hr_utility.set_location ('Fetch person:'||
           to_char(g_cache_person_process(l_record_number+1).person_id),20);
      l_record_number := l_record_number + 1;
    End loop;
    close c_person_thread;
    l_actn := 'Preparing to default each participant from cache...' ;
    If l_record_number > 0 then
      --
      -- Process the rows from the person process cache
      --
      For l_cnt in 1..l_record_number loop
        Begin
          hr_utility.set_location ('Call ben_prem_prtt_monthly.main:',30);

          ben_prem_prtt_monthly.main
            (p_validate              => p_validate
            ,p_person_id             => g_cache_person_process(l_cnt).person_id
            ,p_person_action_id      => g_cache_person_process(l_cnt).person_action_id
            ,p_comp_selection_rl     => l_parm.comp_selection_rl
            ,p_pgm_id                => l_parm.pgm_id
            ,p_pl_typ_id             => l_parm.pl_typ_id
            ,p_pl_id                 => l_parm.pl_id
            ,p_object_version_number => g_cache_person_process(l_cnt).object_version_number
            ,p_business_group_id     => p_business_group_id
            ,p_mo_num                => p_mo_num
            ,p_yr_num                => p_yr_num
            ,p_first_day_of_month    => l_first_day_of_month
            ,p_effective_date        => l_effective_date
          );
          g_persons_processed := g_persons_processed + 1;
        Exception
          When others then
              l_error_text := sqlerrm;
              hr_utility.set_location ('Person Failed in '||l_proc,777);
              hr_utility.set_location (' with error '||l_error_text,777);

              g_persons_errored := g_persons_errored + 1;

              If (g_persons_errored > g_max_errors_allowed) then
                  hr_utility.set_location ('Person errors exceeds max allowed',778);
                  fnd_message.raise_error;
              End if;
        End;
      End loop;
    Else
      --
      l_actn := 'Erroring out nocopy since not person is found in range...' ;
      --
      hr_utility.set_location ('BEN_91709_PER_NOT_FND_IN_RNG',778);
      fnd_message.set_name('BEN','BEN_91709_PER_NOT_FND_IN_RNG');
      fnd_message.raise_error;
    End if;
    benutils.write_table_and_file(p_table => TRUE, p_file  => FALSE);
  End loop;
  benutils.write_table_and_file(p_table => TRUE, p_file  => FALSE);
  --
  l_actn := 'Calling Log_statistics...';
  ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_processed
                               ,p_num_pers_errored   => g_persons_errored
                               );
  hr_utility.set_location ('Leaving '||l_proc,70);
Exception
  When others then
    l_error_text := sqlerrm;
    hr_utility.set_location ('Fail in '||l_proc,998);
    hr_utility.set_location (' with error '||l_error_text,999);

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
          ,pgm_id
          ,pl_typ_id
          ,pl_id
          ,business_group_id
          ,popl_enrt_typ_cycl_id
          ,person_selection_rl
          ,comp_selection_rl
          ,ler_id
          ,organization_id
          ,legal_entity_id
          ,debug_messages_flag
      From ben_benefit_actions ben
     Where ben.benefit_action_id = p_benefit_action_id;
  --
  -- Local Variable declaration.
  --
  l_proc        varchar2(80) := g_package||'.restart';
  l_parameters  c_parameters%rowtype;
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
        hr_utility.set_location ('BEN_91710_RESTRT_PARMS_NOT_FND',778);
        fnd_message.set_name('BEN','BEN_91710_RESTRT_PARMS_NOT_FND');
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
            ,p_business_group_id        => l_parameters.business_group_id
            ,p_pgm_id                   => l_parameters.pgm_id
            ,p_pl_typ_id                => l_parameters.pl_typ_id
            ,p_pl_id                    => l_parameters.pl_id
            ,p_person_selection_rule_id => l_parameters.person_selection_rl
            ,p_comp_selection_rule_id   => l_parameters.comp_selection_rl
            ,p_organization_id          => l_parameters.organization_id
            ,p_legal_entity_id          => l_parameters.legal_entity_id
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
--  This is what is called from the concurrent manager screen
--
procedure process(errbuf                        out nocopy varchar2
                 ,retcode                       out nocopy number
                 ,p_benefit_action_id        in     number   default null
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_person_id                in     number   default null
                 ,p_business_group_id        in     number
                 ,p_pgm_id                   in     number   default null
                 ,p_pl_typ_id                in     number   default null
                 ,p_pl_id                    in     number   default null
                 ,p_person_selection_rule_id in     number   default null
                 ,p_comp_selection_rule_id   in     number   default null
                 ,p_organization_id          in     number   default null
                 ,p_legal_entity_id          in     number   default null
                 ,p_debug_messages           in     varchar2 default 'N'
                 ) is

  cursor c_person (p_effective_date date) is
    select distinct pen.person_id
    from   ben_prtt_enrt_rslt_f pen
    where  pen.prtt_enrt_rslt_stat_cd is null
    and    pen.sspndd_flag = 'N'
    and    pen.comp_lvl_cd not in ('PLANFC', 'PLANIMP')  -- not a dummy plan
           -- cvg starts sometime before end of next month:
    and    pen.enrt_cvg_strt_dt <= add_months(p_effective_date,1)
           -- check criteria user entered on the submit form:
    and    (pen.person_id = p_person_id or p_person_id is null)
    and    (pen.pl_id = p_pl_id  or p_pl_id is null)
    and    (pen.pl_typ_id = p_pl_typ_id or p_pl_typ_id is null)
    and    (pen.pgm_id = p_pgm_id or p_pgm_id is null)
    and    pen.business_group_id+0 = p_business_group_id
    and    p_effective_date between
           pen.effective_start_date and pen.effective_end_date
    and    (p_organization_id is null
    	   or exists (select null from per_all_assignments_f
    	   	   where  person_id = pen.person_id
    	   	   and	  business_group_id = p_business_group_id
    	   	   and    p_effective_date between nvl(effective_start_date,p_effective_date )
    	   	   	  and 	nvl(effective_end_date, p_effective_date )
    	   	   and    primary_flag = 'Y'
    	   	   and    organization_id = p_organization_id ) )
    and    ( p_legal_entity_id is null
    	     or exists (select null
	                from   per_assignments_f paf,
	                       hr_soft_coding_keyflex soft
	                where  paf.person_id = pen.person_id
	                and    p_effective_date
	                       between paf.effective_start_date
	                       and     paf.effective_end_date
  		  	and    paf.business_group_id = p_business_group_id
	                and    paf.primary_flag = 'Y'
	                and    soft.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
                        and    soft.segment1 = to_char(p_legal_entity_id)));

  --
  -- local variable declaration.
  --
  l_request_id             number;
  l_proc                   varchar2(80) := g_package||'.process';
  l_benefit_action_id      ben_benefit_actions.benefit_action_id%type;
  l_object_version_number  ben_benefit_actions.object_version_number%type;
  l_person_id              per_people_f.person_id%type;
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
  l_commit number;
  l_effective_date         date;
  l_effective_date_char    varchar2(19);
  -- premium fields:
  l_first_day_of_month date;
  l_first_day_of_month_char varchar2(19);
  l_mo_num             number;
  l_yr_num             number;

  l_errbuf      varchar2(80);
  l_retcode     number;
  l_restart     boolean;
  l_err_message varchar2(800);
Begin
  hr_utility.set_location ('Entering '||l_proc,10);

  l_effective_date:=to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date:=to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR'),'DD/MM/RRRR');
  -- No matter what date the user entered, make sure we process on the last day of the
  -- month:
  l_effective_date := last_day(l_effective_date);
  l_effective_date_char := to_char(l_effective_date,'YYYY/MM/DD HH24:MI:SS');
  --
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  -- Load premium fields:
  l_first_day_of_month :=
      to_date('01/'||to_char(l_effective_date,'MM/RRRR'),'DD/MM/RRRR');
  l_first_day_of_month_char := to_char(l_first_day_of_month,'YYYY/MM/DD HH24:MI:SS');
  l_mo_num := to_char(l_effective_date,'MM');
  l_yr_num := to_char(l_effective_date,'RRRR');
  --
  l_actn := 'Initialize the ben_batch_utils cache...';
  ben_batch_utils.ini;
  l_actn := 'Initialize the ben_batch_utils cache...';
  ben_batch_utils.ini(p_actn_cd => 'PROC_INFO');
  --
  -- Check that all the mandatory input parameters
  -- such as p_business_group_id, p_mode, p_effective_date
  --
  l_actn := 'Checking arguments...';
  hr_utility.set_location('Checking arguments',12);
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
                        ,p_batch_exe_cd       => 'BENPRCON'
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

    hr_utility.set_location('p_benefit_action_id is null',14);
    l_restart := FALSE;

    ben_benefit_actions_api.create_benefit_actions
      (p_validate               => false
      ,p_benefit_action_id      => l_benefit_action_id
      ,p_process_date           => l_effective_date
      ,p_mode_cd                => 'S'
      ,p_derivable_factors_flag => 'N'
      ,p_validate_flag          => p_validate
      ,p_person_id              => p_person_id
      ,p_person_type_id         => null
      ,p_pgm_id                 => p_pgm_id
      ,p_business_group_id      => p_business_group_id
      ,p_pl_typ_id              => p_pl_typ_id
      ,p_pl_id                  => p_pl_id
      ,p_popl_enrt_typ_cycl_id  => null
      ,p_no_programs_flag       => 'N'
      ,p_no_plans_flag          => 'N'
      ,p_comp_selection_rl      => p_comp_selection_rule_id
      ,p_person_selection_rl    => p_person_selection_rule_id
      ,p_ler_id                 => null
      ,p_organization_id        => p_organization_id
      ,p_benfts_grp_id          => null
      ,p_location_id            => null
      ,p_pstl_zip_rng_id        => NULL
      ,p_rptg_grp_id            => NULL
      ,p_opt_id                 => NULL
      ,p_eligy_prfl_id          => NULL
      ,p_vrbl_rt_prfl_id        => NULL
      ,p_legal_entity_id        => p_legal_entity_id
      ,p_payroll_id             => null
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
    hr_utility.set_location('Delete rows from ben_batch_ranges',16);

    Delete from ben_batch_ranges
     Where benefit_action_id = l_benefit_action_id;
    --
    -- Now lets create person actions for all the people we are going to
    -- process in the Premium Calculation run.
    --
    open c_person (p_effective_date => l_effective_date);
    l_person_cnt := 0;
    l_cnt := 0;
    l_actn := 'Loading person_actions table..';
    Loop
      fetch c_person into l_person_id;
      Exit when c_person%notfound;
      l_cnt := l_cnt + 1;


      hr_utility.set_location('LAMC: person_id='||to_char(l_person_id)||
                ' l_cnt='||to_char(l_cnt),18);

      -- check person rule criteria that the user entered on the submit form.
      skip := FALSE;
      rl_ret := 'Y';
-- tar no - 13530340.6
     Begin
       l_err_message := null ;
       If (p_person_selection_rule_id is not NULL) then
          l_actn := 'Calling Ben_batch_utils.person_selection_rule...';
/*        rl_ret := ben_batch_utils.person_selection_rule
                    (p_person_id               => l_person_id
                    ,p_business_group_id       => p_business_group_id
                    ,p_person_selection_rule_id=> p_person_selection_rule_id
                    ,p_effective_date          => l_effective_date
                    );
*/

             prem_person_selection_rule
		  		(p_person_id                => l_person_id
                 		,p_business_group_id        => p_business_group_id
                 		,p_person_selection_rule_id => p_person_selection_rule_id
                 		,p_effective_date           => l_effective_date
		       	        ,p_return                   => rl_ret
                 		,p_err_message              => l_err_message ) ;


		 if l_err_message  is not null
		 then
		     Ben_batch_utils.write(p_text =>
        		'<< Person id : '||to_char(l_person_id)||' failed.'||
			'   Reason : '|| l_err_message ||' >>' );
			 skip := TRUE;
  	                 g_persons_errored := g_persons_errored + 1;
                 else
                     If (rl_ret = 'N') then
                         skip := TRUE;
                     End if;
	         end if ;

        End if;
      End ;
-- tar no - 13530340.6
      --
      -- Store data into person actions table.
      --
      If ( not skip) then
        hr_utility.set_location('not skip...Inserting Ben_person_actions',28);

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

    hr_utility.set_location('l_num_row='||to_char(l_num_row),18);

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
    hr_utility.set_location('p_benefit_action_id is not null',30);
    l_restart := TRUE;
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
  hr_utility.set_location('l_num_range '||to_char(l_num_range),30);

  If l_num_range > 1 then
    For l_count in 1..least(l_threads,l_num_range)-1 loop
      --
      l_actn := 'Submitting job to con-current manager...';
      hr_utility.set_location('Submitting BENPRCOM to con-current manager ',32);

      l_request_id := fnd_request.submit_request
                        (application => 'BEN'
                        ,program     => 'BENPRCOM'
                        ,description => NULL
                        ,sub_request => FALSE
                        ,argument1   => p_validate
                        ,argument2   => l_benefit_action_id
                        ,argument3   => l_count
                        ,argument4   => l_effective_date_char
                        ,argument5   => p_business_group_id
                        ,argument6   => l_mo_num
                        ,argument7   => l_yr_num
                        ,argument8   => l_first_day_of_month_char );
      --
      -- Store the request id of the concurrent request
      --
      ben_batch_utils.g_num_processes := ben_batch_utils.g_num_processes + 1;
      ben_batch_utils.g_processes_tbl(ben_batch_utils.g_num_processes)
        := l_request_id;
    End loop;
  Elsif (l_num_range = 0 ) then
    l_actn := 'Calling Ben_batch_utils.print_parameters...';
    hr_utility.set_location('Calling Ben_batch_utils.print_parameters ',34);

    Ben_batch_utils.print_parameters
      (p_thread_id                => 99
      ,p_benefit_action_id        => l_benefit_action_id
      ,p_validate                 => p_validate
      ,p_business_group_id        => p_business_group_id
      ,p_effective_date           => l_effective_date
      ,p_mode                     => null
      ,p_comp_selection_rule_id   => p_comp_selection_rule_id
      ,p_pgm_id                   => p_pgm_id
      ,p_pl_typ_id                => p_pl_typ_id
      ,p_pl_id                    => p_pl_id
      ,p_popl_enrt_typ_cycl_id    => null
      ,p_person_id                => p_person_id
      ,p_person_selection_rule_id => p_person_selection_rule_id
      ,p_person_type_id           => null
      ,p_ler_id                   => null
      ,p_organization_id          => p_organization_id
      ,p_benfts_grp_id            => null
      ,p_location_id              => null
      ,p_legal_entity_id          => p_legal_entity_id
      ,p_payroll_id               => null
      );

     -- Because there  are other processes below, do not error if first process finds
     -- noone to process.

      Ben_batch_utils.write(p_text =>
   '<< No Person was selected for Participant Premiums with above selection criteria >>' );
     -- hr_utility.set_location ('BEN_91769_NOONE_TO_PROCESS',778);
     -- fnd_message.set_name('BEN','BEN_91769_NOONE_TO_PROCESS');
     -- fnd_message.raise_error;
  End if;

  if (l_num_range <> 0 ) then
    l_actn := 'Calling do_multithread...';
    hr_utility.set_location('Calling do_multithread ',34);
    do_multithread(errbuf               => errbuf
                ,retcode              => retcode
                ,p_validate           => p_validate
                ,p_benefit_action_id  => l_benefit_action_id
                ,p_thread_id          => l_threads+1
                ,p_effective_date     => l_effective_date_char
                ,p_business_group_id  => p_business_group_id
                ,p_mo_num             => l_mo_num
                ,p_yr_num             => l_yr_num
                ,p_first_day_of_month => l_first_day_of_month_char
                );
    l_actn := 'Calling ben_batch_utils.check_all_slaves_finished...';

    hr_utility.set_location('Calling ben_batch_utils.check_all_slaves_finished ',38);

    ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
  end if;
  --------------------------------------------------------------------------
  -- Now call the other two processes:
  --------------------------------------------------------------------------
  if p_person_id is null and p_person_selection_rule_id is null then
     -- only process comp object premiums if no person criteria was selected
     ben_premium_plan_concurrent.process
         (errbuf                     => l_errbuf
         ,retcode                    => l_retcode
         ,p_benefit_action_id        => l_benefit_action_id
         ,p_effective_date           => l_effective_date_char
         ,p_validate                 => p_validate
         ,p_pgm_id                   => p_pgm_id
         ,p_pl_typ_id                => p_pl_typ_id
         ,p_pl_id                    => p_pl_id
         ,p_business_group_id        => p_business_group_id
         ,p_comp_selection_rule_id   => p_comp_selection_rule_id
         ,p_debug_messages           => p_debug_messages
         ,p_mo_num                   => l_mo_num
         ,p_yr_num                   => l_yr_num
         ,p_first_day_of_month       => l_first_day_of_month_char
         ,p_threads                  => l_threads
         ,p_chunk_size               => l_chunk_size
         ,p_max_errors               => g_max_errors_allowed
         ,p_restart                  => l_restart);

  end if;
  ben_prem_prtt_credits_mo.main
      (p_validate                 => p_validate
      ,p_person_id                => p_person_id
      ,p_person_selection_rule_id => p_person_selection_rule_id
      ,p_comp_selection_rule_id   => p_comp_selection_rule_id
      ,p_pgm_id                   => p_pgm_id
      ,p_pl_typ_id                => p_pl_typ_id
      ,p_pl_id                    => p_pl_id
      ,p_organization_id          => p_organization_id
      ,p_legal_entity_id          => p_legal_entity_id
      ,p_business_group_id        => p_business_group_id
      ,p_mo_num                   => l_mo_num
      ,p_yr_num                   => l_yr_num
      ,p_first_day_of_month       => l_first_day_of_month
      ,p_effective_date           => l_effective_date);
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
     --
     benutils.write(p_text => fnd_message.get);
     benutils.write(p_text => sqlerrm);
     benutils.write(p_text => 'Big Error Occured');
     benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
     If (l_num_range > 0) then
       ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
       ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                                  ,p_person_selected   => l_person_cnt
                                  ,p_business_group_id => p_business_group_id
       ) ;
     End if;
     hr_utility.set_location ('HR_6153_ALL_PROCEDURE_FAIL',689);
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE', l_proc);
     fnd_message.set_token('STEP', l_actn );
     fnd_message.raise_error;
End process;
--
end ben_premium_concurrent;  -- End of Package.

/
