--------------------------------------------------------
--  DDL for Package Body BEN_EVALUATE_ELIG_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EVALUATE_ELIG_CONC" as
/* $Header: benunvel.pkb 120.1.12010000.2 2008/08/05 14:55:10 ubhat ship $ */
--
/* ============================================================================
*    Name
*       Eligibility Engine Concurrent Manager Processes
*
*    Purpose
*       This package simply houses the concurrent manager and multi-thread
*       processes for Eligibility Engine
*
*    History
*      Date        Who        Version    What?
*      ---------   ---------  -------    --------------------------------------
*      08-jul-2004 mmudigon   115.0      Created
*      13-jun-2005 mmudigon   115.1      Added business_group_id to where clause
*                                        of cursor c_ebo
*      01-Dec-06   rtagarra   115.2      Bug 5662220 :Added check so that when there is no condition for a person
*					 in person_selection_rule then skip the person.
* -----------------------------------------------------------------------------
*/
--
-- Global cursor and variables declaration
--
g_package                 varchar2(80) := 'ben_evaluate_elig_conc';
g_persons_processed       number(9) := 0;
g_persons_ended           number(9) := 0;
g_persons_passed          number(9) := 0;
g_persons_errored         number(9) := 0;
g_max_errors_allowed      number(9) := 200;
g_rec                     ben_type.g_report_rec;
--
--
-- ============================================================================
--                        << Procedure: Do_Multithread >>
--  Description:
--  	this procedure is called from 'process'.  It calls the back-out routine.
-- ============================================================================
procedure do_multithread
             (errbuf                  out nocopy    varchar2
             ,retcode                 out nocopy    number
             ,p_validate              in     varchar2 default 'N'
             ,p_benefit_action_id     in     number
             ,p_thread_id             in     number
             ,p_effective_date        in     varchar2
             ,p_business_group_id     in     number
             ,p_person_id             in     number
             ,p_assignment_type       in     varchar2
             ,p_elig_obj_type         in     varchar2
             ,p_elig_obj_id           in     number) is
  --
  -- Local variable declaration
  --
  l_proc                   varchar2(80) := g_package||'.do_multithread';
  l_person_id              ben_person_actions.person_id%type;
  l_person_action_id       ben_person_actions.person_action_id%type;
  l_object_version_number  ben_person_actions.object_version_number%type;
  l_range_id               ben_batch_ranges.range_id%type;
  l_record_number          number := 0;
  l_start_person_action_id number := 0;
  l_end_person_action_id   number := 0;
  l_actn                   varchar2(80);
  l_cnt                    number(5):= 0;
  l_chunk_size             number(15);
  l_threads                number(15);
  l_effective_date         date;
  l_eligible               boolean;
  l_commit                 number;
  --
  -- Cursors declaration
  --
  Cursor c_range_thread is
    Select ran.range_id
          ,ran.starting_person_action_id
          ,ran.ending_person_action_id
    From   ben_batch_ranges ran
    Where  ran.range_status_cd = 'U'
    And    ran.BENEFIT_ACTION_ID  = P_BENEFIT_ACTION_ID
    And    rownum < 2
    For    update of ran.range_status_cd;
  --
  cursor c_person_thread is
    select ben.person_id,
           ben.person_action_id
    from   ben_person_actions ben
    where  ben.benefit_action_id = p_benefit_action_id
    and    ben.action_status_cd not in ('P','E')
    and    ben.person_action_id
           between l_start_person_action_id
           and     l_end_person_action_id
    order  by ben.person_action_id;
  --
  Cursor c_parameter is
    Select *
    From   ben_benefit_actions ben
    Where  ben.benefit_action_id = p_benefit_action_id;
  --
  l_parm c_parameter%rowtype;
  --
  cursor c_person is
    select ppf.*
    from   per_all_people_f ppf
    where  ppf.person_id = l_person_id
      and  business_group_id = p_business_group_id
    and    nvl(l_effective_date,trunc(sysdate))
           between ppf.effective_start_date
           and     ppf.effective_end_date;

  l_per_rec       per_all_people_f%rowtype;
  l_per_dummy_rec per_all_people_f%rowtype;

  cursor c_ebo is
  select elig_obj_id
    from ben_elig_obj_f
   where (p_elig_obj_id is null or
          elig_obj_id = p_elig_obj_id)
     and l_effective_date between effective_start_date
     and effective_end_date
     and business_group_id = p_business_group_id
     and table_name = p_elig_obj_type;
  l_ebo_rec c_ebo%rowtype;

Begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','dt_fndate.change_ses_date');
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  l_effective_date:=trunc(fnd_date.canonical_to_date(p_effective_date));
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','benutils.get_parameter');
  benutils.get_parameter(p_business_group_id  => p_business_group_id
                        ,p_batch_exe_cd       => 'BENUNVEL'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed);
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','ben_env_object.init');
  ben_env_object.init(p_business_group_id => p_business_group_id,
                      p_effective_date    => l_effective_date,
                      p_thread_id         => p_thread_id,
                      p_chunk_size        => l_chunk_size,
                      p_threads           => l_threads,
                      p_max_errors        => g_max_errors_allowed,
                      p_benefit_action_id => p_benefit_action_id);
  --
  -- Copy benefit action id to global in benutils package
  --
  benutils.g_benefit_action_id := p_benefit_action_id;
  benutils.g_thread_id         := p_thread_id;
  g_persons_errored            := 0;
  g_persons_processed          := 0;
  --
  open c_parameter;
    --
    fetch c_parameter into l_parm;
    --
  close c_parameter;
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','ben_batch_utils.print_parameters');
  ben_batch_utils.print_parameters
          (p_thread_id                => p_thread_id
          ,p_benefit_action_id        => p_benefit_action_id
          ,p_validate                 => p_validate
          ,p_business_group_id        => p_business_group_id
          ,p_person_id                => p_person_id
          ,p_effective_date           => l_effective_date
          ,p_person_selection_rule_id => l_parm.person_selection_rl
          ,p_organization_id          => l_parm.organization_id
          ,p_benfts_grp_id            => l_parm.benfts_grp_id
          ,p_location_id              => l_parm.location_id
          ,p_legal_entity_id          => l_parm.legal_entity_id);
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
  hr_utility.set_location('getting range',10);
  --
  Loop
    --
    open c_range_thread;
      --
      fetch c_range_thread into l_range_id
                               ,l_start_person_action_id
                               ,l_end_person_action_id;
      hr_utility.set_location('doing range fetch',10);
      --
      if c_range_thread%notfound then
        --
        hr_utility.set_location('range not Found',10);
        --
        exit;
        --
      end if;
      --
      hr_utility.set_location('range Found',10);
      --
    close c_range_thread;
    --
    update ben_batch_ranges ran
    set    ran.range_status_cd = 'P'
    where  ran.range_id = l_range_id;
    --
    commit;
    --
    -- Get person who are in the range
    --
    open c_person_thread;
      --
      loop
        --
        fetch c_person_thread into l_person_id,
                                   l_person_action_id;
        hr_utility.set_location('person id'||l_person_id,10);
        --
        exit when c_person_thread%notfound;
        --
        savepoint last_place;
        benutils.set_cache_record_position;
        --
        l_per_rec := l_per_dummy_rec;
        open c_person;
        fetch c_person into l_per_rec;
        close c_person;
        --
        begin
          --
          hr_utility.set_location('Before open',10);
              --
          open c_ebo;
          loop
             fetch c_ebo into l_ebo_rec;
             if c_ebo%notfound then
                exit;
             end if;

             ben_per_asg_elig.eligible
             (p_person_id             => l_person_id
             ,p_assignment_type       => p_assignment_type
             ,p_elig_obj_id           => l_ebo_rec.elig_obj_id
             ,p_effective_date        => l_effective_date
             ,p_business_group_id     => p_business_group_id
             ,p_save_results          => true
             );
          end loop;
          close c_ebo;

          g_rec.rep_typ_cd := 'LFBO';
          g_rec.person_id := l_person_id;
          benutils.write(p_rec => g_rec);
          --
          -- If we get here it was successful.
          --
          update ben_person_actions
              set   action_status_cd = 'P'
              where person_id = l_person_id
              and   benefit_action_id = p_benefit_action_id;
          --
          benutils.write(l_per_rec.full_name||' processed successfully');
          g_persons_processed := g_persons_processed + 1;
          --
        exception
          --
          when others then
            --
            hr_utility.set_location('Super Error exception level',10);
            hr_utility.set_location(sqlerrm,10);
            rollback to last_place;
            benutils.rollback_cache;
            --
            update ben_person_actions
              set   action_status_cd = 'E'
              where person_id = l_person_id
              and   benefit_action_id = p_benefit_action_id;
            --
            commit;
            --
            g_persons_errored := g_persons_errored + 1;
            g_rec.rep_typ_cd := 'ERROR_LF';
            g_rec.person_id := l_person_id;
            g_rec.national_identifier := l_per_rec.national_identifier;
            g_rec.error_message_code := benutils.get_message_name;
            g_rec.text := fnd_message.get;

            hr_utility.set_location('Error Message '||g_rec.text,10);
            benutils.write(l_per_rec.full_name||' processed unsuccessfully');
            benutils.write(g_rec.text);
            benutils.write(p_rec => g_rec);
            --
            hr_utility.set_location('Max Errors = '||g_max_errors_allowed,10);
            hr_utility.set_location('Num Errors = '||g_persons_errored,10);
            if g_persons_errored > g_max_errors_allowed then
              --
              fnd_message.set_name('BEN','BEN_92431_BENBOCON_ERROR_LIMIT');
              benutils.write(p_text => fnd_message.get);
              --
              raise;
              --
            end if;
            --
        end;
        --
        hr_utility.set_location('Closing c_person_thread',10);
        --
      end loop;
      --
    close c_person_thread;
    --
    -- Commit chunk
    --
    if p_validate = 'Y' then
      --
      hr_utility.set_location('Rolling back transaction ',10);
      --
      rollback;
      --
    end if;
    --
    fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
    fnd_message.set_token('PROC','benutils.write_table_and_file');
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    commit;
    --
  end loop;
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','benbatch_utils.write_logfile');
  ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_processed
                               ,p_num_pers_errored   => g_persons_errored);
  --
  commit;
  --
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
Exception
  --
  When others then
    --
    hr_utility.set_location('Super Error',10);
    hr_utility.set_location(sqlerrm,10);
    hr_utility.set_location('Super Error',10);
    rollback;
    benutils.rollback_cache;
    --
    g_rec.rep_typ_cd := 'FATAL';
    g_rec.text := fnd_message.get;
    g_rec.person_id := l_person_id;
    --
    benutils.write(p_text => g_rec.text);
    benutils.write(p_rec => g_rec);
    --
    ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_processed
                                 ,p_num_pers_errored   => g_persons_errored);
    --
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    --
    commit;
    --
    fnd_message.raise_error;
    --
End do_multithread;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                   << Procedure: Restart >>
-- *****************************************************************
--
procedure restart (errbuf                 out nocopy varchar2
                  ,retcode                out nocopy number
                  ,p_benefit_action_id    in  number) is
  --
  -- Cursor Declaration
  --
  cursor c_parameters is
    Select process_date
          ,mode_cd
          ,validate_flag
          ,person_id
          ,pl_id
          ,concat_segs
          ,business_group_id
          ,person_selection_rl
          ,los_det_to_use_cd
          ,organization_id
          ,location_id
          ,benfts_grp_id
          ,legal_entity_id
          ,debug_messages_flag
    From  ben_benefit_actions ben
    Where ben.benefit_action_id = p_benefit_action_id;
  --
  -- Local Variable declaration.
  --
  l_proc        varchar2(80) := g_package||'.restart';
  l_parameters	c_parameters%rowtype;
  l_errbuf      varchar2(80);
  l_retcode     number;
  --
Begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- get the parameters for a previous run and do a restart
  --
  open c_parameters;
    --
    fetch c_parameters into l_parameters;
    If c_parameters%notfound then
      --
      fnd_message.set_name('BEN','BEN_91710_RESTRT_PARMS_NOT_FND');
      fnd_message.raise_error;
      --
    End if;
    --
  close c_parameters;
  --
  -- Call process procedure with parameters for restart
  --
  process(errbuf                     => l_errbuf
         ,retcode                    => l_retcode
         ,p_benefit_action_id        => p_benefit_action_id
         ,p_effective_date           => fnd_date.date_to_canonical
                                        (l_parameters.process_date)
         ,p_validate                 => l_parameters.validate_flag
         ,p_business_group_id        => l_parameters.business_group_id
         ,p_person_id                => l_parameters.person_id
         ,p_assignment_type          => l_parameters.los_det_to_use_cd
         ,p_elig_obj_id              => l_parameters.pl_id
         ,p_elig_obj_type            => l_parameters.concat_segs
         ,p_organization_id          => l_parameters.organization_id
         ,p_location_id              => l_parameters.location_id
         ,p_benfts_grp_id            => l_parameters.benfts_grp_id
         ,p_legal_entity_id          => l_parameters.legal_entity_id
         ,p_person_selection_rule_id => l_parameters.person_selection_rl
         ,p_debug_messages           => l_parameters.debug_messages_flag);
  --
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
end restart;
--
-- *************************************************************************
-- *                          << Procedure: Process >>
-- *************************************************************************
--  This is what is called from the concurrent manager screen
--
procedure process(errbuf                     out nocopy    varchar2
                 ,retcode                    out nocopy    number
                 ,p_benefit_action_id        in     number   default null
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_business_group_id        in     number
                 ,p_person_id                in     number
                 ,p_assignment_type          in     varchar2
                 ,p_elig_obj_type            in     varchar2
                 ,p_elig_obj_id              in     number
                 ,p_organization_id          in     number   default null
                 ,p_location_id              in     number   default null
                 ,p_benfts_grp_id            in     number   default null
                 ,p_legal_entity_id          in     number   default null
                 ,p_person_selection_rule_id in     number   default null
                 ,p_debug_messages           in     varchar2 default 'N') is
  --
  l_effective_date         date;
  l_from_ocrd_date         date;
  l_to_ocrd_date           date;
  l_no_one_to_process      exception;
  --
  -- Cursors declaration.
  --
  cursor c_person is
  select ppf.person_id
    from per_all_people_f ppf
   where ppf.business_group_id = p_business_group_id
     and l_effective_date between ppf.effective_start_date
     and ppf.effective_end_date
     and (p_person_id is null or
          ppf.person_id = p_person_id)
     and (p_organization_id is null
          or exists (select null
                      from   per_all_assignments_f paa
                      where  paa.person_id = ppf.person_id
                      and    l_effective_date
                             between paa.effective_start_date
                             and     paa.effective_end_date
                      and    paa.business_group_id = ppf.business_group_id
                      and    paa.primary_flag = 'Y'
                      and    paa.organization_id = p_organization_id))
     and   (p_location_id is null
          or exists (select null
                     from   per_all_assignments_f paa
                     where  paa.person_id = ppf.person_id
                     and    l_effective_date
                            between paa.effective_start_date
                            and     paa.effective_end_date
                     and    paa.business_group_id = ppf.business_group_id
                     and    paa.primary_flag = 'Y'
                     and    paa.location_id = p_location_id))
    and   (p_benfts_grp_id is null
          or exists (select null
                     from   per_all_people_f pap
                     where  pap.person_id = ppf.person_id
                     and    pap.business_group_id = ppf.business_group_id
                     and    l_effective_date
                            between pap.effective_start_date
                            and     pap.effective_end_date
                     and    pap.benefit_group_id = p_benfts_grp_id))
    and   (p_legal_entity_id is null
          or exists (select null
                     from   per_assignments_f paf,
                            hr_soft_coding_keyflex soft
                     where  paf.person_id = ppf.person_id
                     and    paf.assignment_type <> 'C'
                     and    l_effective_date
                            between paf.effective_start_date
                            and     paf.effective_end_date
                     and    paf.business_group_id = ppf.business_group_id
                     and    paf.primary_flag = 'Y'
                     and    soft.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
                     and    soft.segment1 = to_char(p_legal_entity_id))) ;

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
  l_num_range              number := 0;
  l_chunk_num              number := 1;
  l_num_row                number := 0;
  l_commit number;
  --
Begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  l_effective_date:=trunc(fnd_date.canonical_to_date(p_effective_date));
  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  -- Get chunk_size and Thread values for multi-thread process.
  --
  ben_batch_utils.ini;
  ben_batch_utils.ini(p_actn_cd => 'PROC_INFO');
  --
  benutils.get_parameter(p_business_group_id  => p_business_group_id
                        ,p_batch_exe_cd       => 'BENUNVEL'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed);
  --
  -- Create benefit actions parameters in the benefit action table.
  -- Do not create if a benefit action already exists, in other words
  -- we are doing a restart.
  --
  If p_benefit_action_id is null then
    hr_utility.set_location('l_effective_date '||l_effective_date,10);
    hr_utility.set_location('p_business_group_id '||p_business_group_id,10);
    hr_utility.set_location('p_debug_messages '||p_debug_messages,10);
    hr_utility.set_location('p_validate '||p_validate,10);
    hr_utility.set_location('p_person_id '||p_person_id,10);
    --
    ben_benefit_actions_api.create_perf_benefit_actions
      (p_validate_flag          => p_validate
      ,p_benefit_action_id      => l_benefit_action_id
      ,p_process_date           => l_effective_date
      ,p_mode_cd                => 'S'
      ,p_derivable_factors_flag => 'N'
      ,p_person_id              => p_person_id
      ,p_pl_id                  => p_elig_obj_id
      ,p_concat_segs            => p_elig_obj_type
      ,p_person_type_id         => null
      ,p_business_group_id      => p_business_group_id
      ,p_no_programs_flag       => 'N'
      ,p_no_plans_flag          => 'N'
      ,p_audit_log_flag         => 'Y'
      ,p_los_det_to_use_cd      => p_assignment_type
      ,p_person_selection_rl    => p_person_selection_rule_id
      ,p_organization_id        => p_organization_id
      ,p_benfts_grp_id          => p_benfts_grp_id
      ,p_location_id            => p_location_id
      ,p_pstl_zip_rng_id        => null
      ,p_rptg_grp_id            => null
      ,p_eligy_prfl_id          => null
      ,p_legal_entity_id        => p_legal_entity_id
      ,p_debug_messages_flag    => 'N'
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_effective_date
      ,p_request_id             => fnd_global.conc_request_id
      ,p_program_application_id => fnd_global.prog_appl_id
      ,p_program_id             => fnd_global.conc_program_id
      ,p_program_update_date    => sysdate);
    --
    benutils.g_benefit_action_id := l_benefit_action_id;
    --
    -- Delete/clear ranges from ben_batch_ranges table
    --
    Delete from ben_batch_ranges
    Where  benefit_action_id = l_benefit_action_id;
    --
    -- Now lets create person actions for all the people we are going to
    -- process in the Back-out life event run
    --
    open c_person;
      --
      l_person_cnt := 0;
      l_cnt := 0;
      --
      loop
        --
        fetch c_person into l_person_id;
        exit when c_person%notfound;
        --
        l_cnt := l_cnt + 1;
        --
        skip := false;
        --
        If p_person_selection_rule_id is not NULL then
          --
          rl_ret := ben_batch_utils.person_selection_rule
                      (p_person_id               => l_person_id
                      ,p_business_group_id       => p_business_group_id
                      ,p_person_selection_rule_id=> p_person_selection_rule_id
                      ,p_effective_date          => l_effective_date);
          --
--          If rl_ret = 'N' then -- Bug 5662220
          If rl_ret <> 'Y' then
            --
            skip := TRUE;
            --
          End if;
          --
        End if;
        --
        -- Store person_id into person actions table.
        --
        If (not skip) then
          --
          Ben_person_actions_api.create_person_actions
            (p_validate              => false
            ,p_person_action_id      => l_person_action_id
            ,p_person_id             => l_person_id
            ,p_benefit_action_id     => l_benefit_action_id
            ,p_action_status_cd      => 'U'
            ,p_chunk_number          => l_chunk_num
            ,p_object_version_number => l_object_version_number
            ,p_effective_date        => l_effective_date);
          --
          l_num_row := l_num_row + 1;
          l_person_cnt := l_person_cnt + 1;
          l_end_person_action_id := l_person_action_id;
          --
          If l_num_row = 1 then
            --
            l_start_person_action_id := l_person_action_id;
            --
          End if;
          --
          If l_num_row = l_chunk_size then
            --
            -- Create a range of data to be multithreaded.
            --
            Ben_batch_ranges_api.create_batch_ranges
              (p_validate                  => false
              ,p_benefit_action_id         => l_benefit_action_id
              ,p_range_id                  => l_range_id
              ,p_range_status_cd           => 'U'
              ,p_starting_person_action_id => l_start_person_action_id
              ,p_ending_person_action_id   => l_end_person_action_id
              ,p_object_version_number     => l_object_version_number
              ,p_effective_date            => l_effective_date);
            --
            l_start_person_action_id := 0;
            l_end_person_action_id := 0;
            l_num_row  := 0;
            l_num_range := l_num_range + 1;
            --
          End if;
          --
        End if;
        --
      End loop;
      --
    close c_person;
    --
    hr_utility.set_location('l_num_row='||to_char(l_num_row),18);
    --
    If l_num_row <> 0 then
      --
      Ben_batch_ranges_api.create_batch_ranges
        (p_validate                  => false
        ,p_benefit_action_id         => l_benefit_action_id
        ,p_range_id                  => l_range_id
        ,p_range_status_cd           => 'U'
        ,p_starting_person_action_id => l_start_person_action_id
        ,p_ending_person_action_id   => l_end_person_action_id
        ,p_object_version_number     => l_object_version_number
        ,p_effective_date            => l_effective_date);
      --
      l_num_range := l_num_range + 1;
      --
    End if;
    --
  Else
    --
    l_benefit_action_id := p_benefit_action_id;
    --
    Ben_batch_utils.create_restart_person_actions
     (p_benefit_action_id  => p_benefit_action_id
     ,p_effective_date     => l_effective_date
     ,p_chunk_size         => l_chunk_size
     ,p_threads            => l_threads
     ,p_num_ranges         => l_num_range
     ,p_num_persons        => l_person_cnt);
    --
  End if;
  --
  If l_num_range > 1 then
    --
    For l_count in 1..least(l_threads,l_num_range)-1 loop
      --
      l_request_id := fnd_request.submit_request
                       (application => 'BEN'
                       ,program     => 'BENUNELTHRD'
                       ,description => NULL
                       ,sub_request => FALSE
                       ,argument1   => p_validate
                       ,argument2   => l_benefit_action_id
                       ,argument3   => l_count
                       ,argument4   => p_effective_date
                       ,argument5   => p_business_group_id
                       ,argument6   => p_person_id
                       ,argument7   => p_assignment_type
                       ,argument8   => p_elig_obj_type
                       ,argument9   => p_elig_obj_id);
      --
      -- Store the request id of the concurrent request
      --
      ben_batch_utils.g_num_processes := ben_batch_utils.g_num_processes + 1;
      ben_batch_utils.g_processes_tbl(ben_batch_utils.g_num_processes)
        := l_request_id;
      --
    End loop;
    --
    commit;
    --
  Elsif (l_num_range = 0 ) then
    --
    Ben_batch_utils.print_parameters
     (p_thread_id                => 99
     ,p_benefit_action_id        => l_benefit_action_id
     ,p_validate                 => p_validate
     ,p_business_group_id        => p_business_group_id
     ,p_effective_date           => l_effective_date
     ,p_person_selection_rule_id => p_person_selection_rule_id
     ,p_person_id                => p_person_id
     ,p_organization_id          => p_organization_id
     ,p_benfts_grp_id            => p_benfts_grp_id
     ,p_location_id              => p_location_id
     ,p_legal_entity_id          => p_legal_entity_id);
    --
    fnd_message.set_name('BEN','BEN_91769_NOONE_TO_PROCESS');
    fnd_message.set_token('PROC' , l_proc);
    raise l_no_one_to_process;
  End if;
  --
  do_multithread(errbuf               => errbuf
                ,retcode              => retcode
                ,p_validate           => p_validate
                ,p_benefit_action_id  => l_benefit_action_id
                ,p_thread_id          => l_threads+1
                ,p_effective_date     => p_effective_date
                ,p_business_group_id  => p_business_group_id
                ,p_person_id          => p_person_id
                ,p_assignment_type    => p_assignment_type
                ,p_elig_obj_type      => p_elig_obj_type
                ,p_elig_obj_id        => p_elig_obj_id);
  --
  ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
  ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                             ,p_person_selected   => l_person_cnt
                             ,p_business_group_id => p_business_group_id);
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
Exception
  when l_no_one_to_process then
    benutils.write(p_text => fnd_message.get);
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
  when others then
     --
     hr_utility.set_location('Super Error',10);
     rollback;
     benutils.write(p_text => fnd_message.get);
     benutils.write(p_text => sqlerrm);
     benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
     If (l_num_range > 0) then
       ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
       ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                                  ,p_person_selected   => l_person_cnt
                                  ,p_business_group_id => p_business_group_id
       ) ;
     End if;
     fnd_message.raise_error;
End process;
--
end ben_evaluate_elig_conc;

/
