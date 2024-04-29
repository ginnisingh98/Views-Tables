--------------------------------------------------------
--  DDL for Package Body BEN_PREMIUM_PLAN_CONCURRENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PREMIUM_PLAN_CONCURRENT" as
/* $Header: benprplc.pkb 120.0 2005/05/28 09:20:13 appldev noship $ */
--
/* ============================================================================
*    Name
*       Premium Process Concurrent Manager Processes for Plan Premiums
*
*    Purpose
*       This package simply houses the concurrent manager and multi-thread
*       processes for Premium Calculation.
*
*    History
*      Date        Who        Version    What?
*      -------     ---------  -------    --------------------------------------
*      01-Nov-99   lmcdonal   115.0      Created
*      27-Feb-00   lmcdonal   115.1      Better debug messages.  Also, do not fail
*                                        if second of 3 processes finds noone to
*                                        process.
*      30-Dec-02   mmudigon   115.2      NOCOPY
*      03-Dec-04   ikasire    115.3      BUg 4046914
* -----------------------------------------------------------------------------
*/
--
-- Global cursor and variables declaration
--
g_package                 varchar2(80) := 'Ben_premium_plan_concurrent';
g_persons_processed       number(9) := 0;
g_persons_ended           number(9) := 0;
g_persons_passed          number(9) := 0;
g_persons_errored         number(9) := 0;
g_max_errors_allowed      number(9) := 200;
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
  --
Begin
  --
  hr_utility.set_location ('Entering '||l_proc,05);
  --
  /*
  l_effective_date:=to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date:=to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR'),'DD/MM/RRRR');
  --
  l_first_day_of_month:=to_date(p_first_day_of_month,'YYYY/MM/DD HH24:MI:SS');
  l_first_day_of_month:=to_date(to_char(trunc(l_first_day_of_month),'DD/MM/RRRR'),'DD/MM/RRRR');
  */
  l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
  l_first_day_of_month := trunc(fnd_date.canonical_to_date(p_first_day_of_month));
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  l_actn := 'Calling benutils.get_parameter...';
  -- ?? couldn't this data be passed in?  potential change to benprcon too.
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
          ,p_person_id                => null
          ,p_person_selection_rule_id => null
          ,p_comp_selection_rule_id   => l_parm.comp_selection_rl
          ,p_pgm_id                   => l_parm.pgm_id
          ,p_pl_typ_id                => l_parm.pl_typ_id
          ,p_pl_id                    => l_parm.pl_id
          ,p_person_type_id           => l_parm.person_type_id
          ,p_ler_id                   => null
          ,p_organization_id          => null
          ,p_benfts_grp_id            => null
          ,p_location_id              => null
          ,p_legal_entity_id          => null
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
  hr_utility.set_location('About to Loop for c_range_thread',38);

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

    --  ?? why is the cache used here, it's not saving any processing time
    --
    l_actn := 'Clearing g_cache_person_process cache...';
    g_cache_person_process.delete;
    open c_person_thread;
    l_record_number := 0;
    hr_utility.set_location('about to loop for c_person_thread',46);
    Loop
      --
      l_actn := 'Loading premium data into g_cache_person_process cache...';
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

    l_actn := 'Preparing to default each participant from cache...' ;
    If l_record_number > 0 then
      --
      -- Process the rows from the person process cache
      --
      hr_utility.set_location('about to Loop thru premiums....',50);
      For l_cnt in 1..l_record_number loop
        Begin
          ben_prem_pl_oipl_monthly.main
            (p_validate              => p_validate
            ,p_actl_prem_id          => g_cache_person_process(l_cnt).person_id
            ,p_business_group_id     => p_business_group_id
            ,p_mo_num                => p_mo_num
            ,p_yr_num                => p_yr_num
            ,p_first_day_of_month    => l_first_day_of_month
            ,p_effective_date        => l_effective_date);
            -- not the user parms  -- but data about premium.
--            ,p_pl_typ_id             => g_cache_person_process(l_cnt).pl_typ_id
 --           ,p_pl_id                 => g_cache_person_process(l_cnt).pl_id
  --          ,p_opt_id                => g_cache_person_process(l_cnt).opt_id);

          g_persons_processed := g_persons_processed + 1;
        Exception
          When others then
              g_persons_errored := g_persons_errored + 1;
              If (g_persons_errored > g_max_errors_allowed) then
                  hr_utility.set_location ('Errors received exceeds max allowed',05);
                  fnd_message.raise_error;
              End if;
        End;
      End loop;
    Else
      --
      l_actn := 'Erroring out nocopy since not person is found in range...' ;
      hr_utility.set_location ('BEN_92452_PREM_NOT_IN_RNG',05);
      fnd_message.set_name('BEN','BEN_92452_PREM_NOT_IN_RNG');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.raise_error;
    End if;

    benutils.write_table_and_file(p_table => TRUE, p_file  => FALSE);
  End loop;

  hr_utility.set_location('End of loops',70);
  benutils.write_table_and_file(p_table => TRUE, p_file  => FALSE);
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
    hr_utility.set_location ('HR_6153_ALL_PROCEDURE_FAIL',05);
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP',l_actn );
    fnd_message.raise_error;
End do_multithread;
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
                 ,p_business_group_id        in     number
                 ,p_pgm_id                   in     number   default null
                 ,p_pl_typ_id                in     number   default null
                 ,p_pl_id                    in     number   default null
                 ,p_comp_selection_rule_id   in     number   default null
                 ,p_debug_messages           in     varchar2 default 'N'
                 ,p_first_day_of_month       in     varchar2
                 ,p_mo_num                   in     number
                 ,p_yr_num                   in     number
                 ,p_threads            in     number
                 ,p_chunk_size         in     number
                 ,p_max_errors         in     number
                 ,p_restart            in     boolean default FALSE ) is
  --
  -- Cursors declaration.
  --

  -- Premiums to be processed:
  cursor c_prems (p_effective_date date) is
    select apr.actl_prem_id, apr.oipl_id, apr.pl_id
    from   ben_actl_prem_f apr
    where  apr.prem_asnmt_cd = 'PROC'  -- ENRT are dealt with in benprprm.pkb
    and    apr.business_group_id = p_business_group_id
    and    p_effective_date between
           apr.effective_start_date and apr.effective_end_date;
   l_prems c_prems%rowtype;

  l_pl_typ_id number ;
  l_pl_id     number ;
  l_opt_id    number ;
  l_pgm_id    number ;
  --
  -- local variable declaration.
  --
  l_effective_date         date;
  l_first_day_of_month     date;
  l_request_id             number;
  l_proc                   varchar2(80) := g_package||'.process';
  l_benefit_action_id      ben_benefit_actions.benefit_action_id%type;
  l_object_version_number  ben_benefit_actions.object_version_number%type;
  l_person_action_id       ben_person_actions.person_action_id%type;
  l_ler_id                 ben_ler_f.ler_id%type;
  l_range_id               ben_batch_ranges.range_id%type;
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

Begin
  hr_utility.set_location ('Entering '||l_proc,10);
  /*
  l_effective_date:=to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date:=to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR'),'DD/MM/RRRR');
  --
  l_first_day_of_month:=to_date(p_first_day_of_month,'YYYY/MM/DD HH24:MI:SS');
  l_first_day_of_month:=to_date(to_char(trunc(l_first_day_of_month),'DD/MM/RRRR'),'DD/MM/RRRR');
  */
  l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
  l_first_day_of_month := trunc(fnd_date.canonical_to_date(p_first_day_of_month));
  --
  --
  --?? l_actn := 'Initialize the ben_batch_utils cache...';
  --??   ben_batch_utils.ini;
  --??   l_actn := 'Initialize the ben_batch_utils cache...';
  --??   ben_batch_utils.ini(p_actn_cd => 'PROC_INFO');
  --
  --
  -- Create actions if we are not doing a restart.
  --
  l_benefit_action_id := p_benefit_action_id;

  If NOT(p_restart) then
    hr_utility.set_location('Not a Restart',14);
    --
    -- Now lets create person actions for all the people we are going to
    -- process in the Premium Calculation run.
    --
    open c_prems(p_effective_date => l_effective_date);
    l_person_cnt := 0;
    l_cnt := 0;
    l_actn := 'Loading person_actions table..';
    Loop
      fetch c_prems into l_prems;
      Exit when c_prems%notfound;
      l_cnt := l_cnt + 1;
      l_actn := 'Calling ben_batch_utils.comp_obj_selection_rule...';
      hr_utility.set_location('l_actl_prem_id='||to_char(l_prems.actl_prem_id)||
                ' l_cnt='||to_char(l_cnt),18);
      --
      -- if comp_obj_selection_rule is pass, test rule.
      -- If the rule return 'N' then
      -- skip that l_actl_prem_id.
      --
      skip := FALSE;

      -- check criteria that the user entered on the submit form.

      if p_pl_id is not null or p_pl_typ_id is not null or p_pgm_id is not null
         or p_comp_selection_rule_id is not null then
         rl_ret := 'Y';
         ben_prem_pl_oipl_monthly.get_comp_object_info
             (p_oipl_id        => l_prems.oipl_id
             ,p_pl_id          => l_prems.pl_id
             ,p_pgm_id         => p_pgm_id
             ,p_effective_date => l_effective_date
             ,p_out_pgm_id     => l_pgm_id
             ,p_out_pl_typ_id  => l_pl_typ_id
             ,p_out_pl_id      => l_pl_id
             ,p_out_opt_id     => l_opt_id);

         if p_pl_id is not null and p_pl_id <> l_pl_id then
               rl_ret := 'N';
         elsif p_pl_typ_id is not null and p_pl_typ_id <> l_pl_typ_id then
               rl_ret := 'N';
         elsif p_pgm_id is not null and p_pgm_id <> l_pgm_id then
               rl_ret := 'N';
         elsif rl_ret = 'Y' and p_comp_selection_rule_id is not null then
            l_actn := 'found a comp object rule...';
            hr_utility.set_location('found a comp object rule',22);
            rl_ret:=ben_maintain_designee_elig.comp_selection_rule(
                p_person_id                => null -- we have no person_id
               ,p_business_group_id        => p_business_group_id
               ,p_pgm_id                   => l_pgm_id
               ,p_pl_id                    => l_pl_id
               ,p_pl_typ_id                => l_pl_typ_id
               ,p_opt_id                   => l_opt_id
               ,p_oipl_id                  => l_prems.oipl_id
               ,p_ler_id                   => null -- we have no ler_id
               ,p_comp_selection_rule_id   => p_comp_selection_rule_id
               ,p_effective_date           => l_effective_date);
         end if;

         If (rl_ret = 'N') then
            skip := TRUE;
         End if;

      end if;


      --
      -- Store actl_prem_id into person actions table.
      --
      If ( not skip) then
        hr_utility.set_location('not skip...Inserting Ben_person_actions',28);
        l_actn := 'Inserting Ben_person_actions...';
        select ben_person_actions_s.nextval
        into   l_person_action_id
        from   sys.dual;

        insert into ben_person_actions
              (person_action_id,
               person_id,
               ler_id,
               benefit_action_id,
               action_status_cd,
               object_version_number,
               chunk_number,
               non_person_cd)
            values
              (l_person_action_id,
               l_prems.actl_prem_id,
               0,
               p_benefit_action_id,
               'U',
               1,
               l_chunk_num,
               'PREM');

        l_num_row := l_num_row + 1;
        l_person_cnt := l_person_cnt + 1;
        l_end_person_action_id := l_person_action_id;
        If l_num_row = 1 then
          l_start_person_action_id := l_person_action_id;
        End if;
        If l_num_row = p_chunk_size then
          --
          -- Create a range of data to be multithreaded.
          --
          l_actn := 'Inserting Ben_batch_ranges.......';
          hr_utility.set_location('Inserting Ben_batch_ranges',32);
          -- Select next sequence number for the range
          --
          select ben_batch_ranges_s.nextval
          into   l_range_id
          from   sys.dual;

          insert into ben_batch_ranges
            (range_id,
             benefit_action_id,
             range_status_cd,
             starting_person_action_id,
             ending_person_action_id,
             object_version_number)
          values
            (l_range_id,
             p_benefit_action_id,
             'U',
             l_start_person_action_id,
             l_end_person_action_id,
             1);
          l_start_person_action_id := 0;
          l_end_person_action_id := 0;
          l_num_row  := 0;
          l_num_range := l_num_range + 1;
          l_chunk_num := l_chunk_num + 1;
        End if;
      End if;
    End loop;
    Close c_prems;
    hr_utility.set_location('l_num_row='||to_char(l_num_row),34);
    If (l_num_row <> 0) then
      l_actn := 'Inserting Final Ben_batch_ranges...';
      hr_utility.set_location('Inserting Final Ben_batch_ranges',38);

          select ben_batch_ranges_s.nextval
          into   l_range_id
          from   sys.dual;

          insert into ben_batch_ranges
            (range_id,
             benefit_action_id,
             range_status_cd,
             starting_person_action_id,
             ending_person_action_id,
             object_version_number)
          values
            (l_range_id,
             p_benefit_action_id,
             'U',
             l_start_person_action_id,
             l_end_person_action_id,
             1);
      l_num_range := l_num_range + 1;
    End if;
  Else
    hr_utility.set_location('This is a RESTART',42);
    l_actn := 'Calling Ben_batch_utils.create_restart_person_actions...';
    Ben_batch_utils.create_restart_person_actions
      (p_benefit_action_id  => p_benefit_action_id
      ,p_effective_date     => l_effective_date
      ,p_chunk_size         => p_chunk_size
      ,p_threads            => p_threads
      ,p_num_ranges         => l_num_range
      ,p_num_persons        => l_person_cnt
      ,p_non_person_cd      => 'PREM'
      );
  End if;
  commit;
  --
  -- Now to multithread the code.
  --
  hr_utility.set_location('l_num_range '||to_char(l_num_range),46);
  If l_num_range > 1 then
    For l_count in 1..least(p_threads,l_num_range)-1 loop
      --
      l_actn := 'Submitting job to con-current manager...';
      hr_utility.set_location('Submitting BENPRPLC to con-current manager ',50);
      -- Conncurrent manage needs the effective date in a varchar form.
      l_request_id := fnd_request.submit_request
                        (application => 'BEN'
                        ,program     => 'BENPRPLC'
                        ,description => NULL
                        ,sub_request => FALSE
                        ,argument1   => p_validate
                        ,argument2   => l_benefit_action_id
                        ,argument3   => l_count
                        ,argument4   => p_effective_date
                        ,argument5   => p_business_group_id
                        ,argument6   => p_mo_num
                        ,argument7   => p_yr_num
                        ,argument8   => p_first_day_of_month
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
    hr_utility.set_location('Calling Ben_batch_utils.print_parameters ',56);
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
      ,p_person_id                => null
      ,p_person_selection_rule_id => null
      ,p_person_type_id           => null
      ,p_ler_id                   => null
      ,p_organization_id          => null
      ,p_benfts_grp_id            => null
      ,p_location_id              => null
      ,p_legal_entity_id          => null
      ,p_payroll_id               => null
      );

     -- Because there  are other processes to run, do not error if first process finds
     -- noone to process.

      Ben_batch_utils.write(p_text =>
          '<< No Process Premiums were selected with above selection criteria >>' );
      --fnd_message.set_name('BEN','BEN_92453_NO_PREMS_TO_PROCESS');
      --fnd_message.raise_error;
  End if;

  if (l_num_range <> 0 ) then

    l_actn := 'Calling do_multithread...';
    hr_utility.set_location('Calling do_multithread ',60);
    do_multithread(errbuf               => errbuf
                ,retcode              => retcode
                ,p_validate           => p_validate
                ,p_benefit_action_id  => l_benefit_action_id
                ,p_thread_id          => p_threads+1
                ,p_effective_date     => p_effective_date
                ,p_business_group_id  => p_business_group_id
                ,p_mo_num             => p_mo_num
                ,p_yr_num             => p_yr_num
                ,p_first_day_of_month => p_first_day_of_month
                );
    l_actn := 'Calling ben_batch_utils.check_all_slaves_finished...';

    hr_utility.set_location('Calling ben_batch_utils.check_all_slaves_finished ',64);
    ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
    ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                             ,p_person_selected   => l_person_cnt
                             ,p_business_group_id => p_business_group_id
                             ,p_non_person_cd     => 'PREM');
  end if;
  hr_utility.set_location ('Leaving '||l_proc,99);
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
     hr_utility.set_location ('HR_6153_ALL_PROCEDURE_FAIL',25);
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE', l_proc);
     fnd_message.set_token('STEP', l_actn );
     fnd_message.raise_error;
End process;
--
end ben_premium_plan_concurrent;  -- End of Package.

/
