--------------------------------------------------------
--  DDL for Package Body BEN_IREC_BACK_OUT_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_IREC_BACK_OUT_CONC" as
/* $Header: benircbo.pkb 120.0 2005/05/28 09:04 appldev noship $ */
--
/* ============================================================================
*    Name
*       Back-out iRecruitment Life Events Concurrent Manager Processes
*
*    Purpose
*       This is a new package added to backout data created by the
*       iRecruitment
*       This package houses the  procedure which would be called from
*       the concurrent manager.
*
*   Additional Notes
*      Though iRec doesnt need multithreading, person selection etc,
*      currently this concurrent program have all those capabilities
*     that incase they need it in future, we can start using that.
*
*    History
*      Date        Who        Version    What?
*      -------     ---------  -------    --------------------------------------
*      8-Sep-2004   hmani    115.0      Created
*     30-Sep-2004   hmani    115.1      Added self-service/wrapper proc
* -----------------------------------------------------------------------------
*/

/* global variables */
g_package                 varchar2(80) := 'ben_irec_back_out_conc';
g_persons_processed       number(9) := 0;
g_persons_ended           number(9) := 0;
g_persons_passed          number(9) := 0;
g_persons_errored         number(9) := 0;
g_max_errors_allowed      number(9) := 200;
g_rec                     ben_type.g_report_rec;
-- ============================================================================
--                        << Procedure: Do_Multithread >>
--  Description:
--      this procedure is called from 'process'.  It calls the back-out routine.
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
             ,p_ocrd_date             in     varchar2
             ,p_assignment_id           in     number
             ,p_life_event_id         in     number
             ,p_bckt_stat_cd          in     varchar2
             ) is
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
  l_ocrd_date         date;
  l_commit number;
  l_per_rec       per_all_people_f%rowtype;
  l_dummy2 number;
  -- l_per_dummy_rec per_all_people_f%rowtype;

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
  cursor c_ler_thread is
    select pil.per_in_ler_id,
           pil.person_id,
           pil.per_in_ler_stat_cd,
           pil.lf_evt_ocrd_dt,
           pil.business_group_id,
           ler.typ_cd,
           ler.ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.person_id = l_person_id
    and    pil.lf_evt_ocrd_dt = l_ocrd_date --between l_from_ocrd_date and l_to_ocrd_date
--    and    pil.ler_id = p_life_event_id
    and    pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
    and    pil.assignment_id = p_assignment_id
    and    pil.person_id = p_person_id
    and    ler.ler_id = pil.ler_id
    and    ler.typ_cd = 'IREC'
    and    nvl(l_effective_date,trunc(sysdate))
           between ler.effective_start_date
           and ler.effective_end_date
    order  by pil.person_id desc;
  --
  l_ler_thread c_ler_thread%rowtype;
  --
  Cursor c_parameter is
    Select *
    From   ben_benefit_actions ben
    Where  ben.benefit_action_id = p_benefit_action_id;
  --
    l_parm c_parameter%rowtype;
  --
  --
  cursor c_person is
    select ppf.*
    from   per_all_people_f ppf
    where  ppf.person_id = l_person_id
    and    nvl(l_effective_date,trunc(sysdate))
           between ppf.effective_start_date
           and     ppf.effective_end_date;

  --
  --
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
  l_ocrd_date := trunc(fnd_date.canonical_to_date(p_ocrd_date));
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','benutils.get_parameter');
  benutils.get_parameter(p_business_group_id  => p_business_group_id
                        ,p_batch_exe_cd       => 'BENBOCON'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed);
  --
  hr_utility.set_location ('l_threads '||l_threads,10);
  hr_utility.set_location ('l_chunk_size '||l_chunk_size,10);
  --
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

        open c_person;
        -- l_per_rec := l_per_dummy_rec;
        fetch c_person into l_per_rec;
        close c_person;

        --
        begin
          --
          hr_utility.set_location('Before open',10);
          open c_ler_thread;
            --
            Loop
              --
              fetch c_ler_thread into l_ler_thread;
              exit when c_ler_thread%notfound;
              --fnd_file.put_line(fnd_file.log,'per_in_ler_id  '||l_ler_thread.per_in_ler_id);
              -- fnd_file.put_line(fnd_file.log,'typ_cd  '||l_ler_thread.typ_cd);
              --
              hr_utility.set_location ('per_in_ler_id '||l_ler_thread.per_in_ler_id,10);
              hr_utility.set_location ('typ_cd '||l_ler_thread.typ_cd,10);
              hr_utility.set_location ('bg id '||l_ler_thread.business_group_id,10);

              --
              --
              fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
              fnd_message.set_token('PROC','ben_back_out_life_event');
              hr_utility.set_location ('calling bolfe ',10);

             ben_back_out_life_event.g_enrt_made_flag := Null;

              ben_back_out_life_event.back_out_life_events
               (p_per_in_ler_id      => l_ler_thread.per_in_ler_id
               ,p_business_group_id  => l_ler_thread.business_group_id
               ,p_bckt_stat_cd       => p_bckt_stat_cd
               ,p_effective_date     => l_effective_date);
              --

		hr_utility.set_location ('this ler is '||l_ler_thread.per_in_ler_id||' pil is '||p_life_event_id,777);

              g_rec.ler_id := l_ler_thread.ler_id;
              g_rec.rep_typ_cd := 'LFBO';
              g_rec.person_id := l_person_id;
              --
              --  This is to assign the global variable which contains information about
              --  the closed or in process life events with or without election,
              --  that were backed out.
              --
          g_rec.text      := l_ler_thread.per_in_ler_stat_cd ||
                                        ben_back_out_life_event.g_enrt_made_flag;
              --
              -- This is to assign the per_in_ler_id in the record to extract the
          -- the electable choices later.
              g_rec.temporal_ler_id :=  l_ler_thread.per_in_ler_id;

              benutils.write(p_rec => g_rec);
              --
            End loop;
            --
          close c_ler_thread;
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

            --
            if c_ler_thread%isopen then

              close c_ler_thread;
              --
            end if;
            --
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
            g_rec.ler_id := nvl(p_life_event_id,l_ler_thread.ler_id);
            g_rec.rep_typ_cd := 'ERROR_LF';
            -- g_rec.text := fnd_message.get;
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
    g_rec.ler_id := nvl(p_life_event_id,l_ler_thread.ler_id);
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
--
-- *************************************************************************
-- *                          << Procedure: Process >>
-- *************************************************************************
--  This is called from the concurrent manager

procedure process
              (errbuf                     out nocopy    varchar2
                 ,retcode                    out nocopy    number
                 ,p_benefit_action_id        in     number   default null
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_business_group_id        in     number
                 ,p_person_id                in     number
                 ,p_assignment_id            in     number
                 ,p_life_event_id            in     number
                 ,p_ocrd_date                in     varchar2
                 ,p_person_selection_rule_id in     number   default null
                 ,p_debug_messages           in     varchar2 default 'N'
                 ,p_bckt_stat_cd             in     varchar2 default 'VOIDD'
                ) is

/* local variable defintions */
  l_proc                   varchar2(80) := g_package||'.process';
  l_request_id             number;
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
  l_commit         number;
  --
  l_effective_date         date;
  l_ocrd_date              date;
  l_no_one_to_process      exception;
  l_no_irec_ler            exception;
  l_business_group_id      number;
  --
  l_person_selection       number;
  l_dummy                  number;

/* cursor definitions*/

cursor c_person is
 select distinct  ppf.person_id, ppf.business_group_id
    from   per_all_people_f ppf
    where  l_effective_date between ppf.effective_start_date and ppf.effective_end_date
      and  exists (select null
                   from   ben_per_in_ler pil
                      , ben_ler_f ler
                   where  pil.lf_evt_ocrd_dt = l_ocrd_date
                   and    pil.ler_id = ler.ler_id
                   and    l_effective_date between ler.effective_start_date
                          and ler.effective_end_date
                   and    ler.business_group_id = p_business_group_id
                   and    pil.ler_id = p_life_event_id
                   and    pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
                   and    pil.person_id = ppf.person_id
                   and    pil.person_id = p_person_id
                   and    pil.assignment_id = p_assignment_id
                   and    ler.typ_cd ='IREC'
                   )
      and  exists ( select null from per_person_type_usages_f ptu,
                per_person_types ppt, per_all_assignments_f apl_ass
				where ppt.person_type_id = ptu.person_type_id
				and ppt.system_person_type in( 'APL', 'APL_EX_APL','EMP_APL', 'EX_EMP_APL')
				and ppt.business_group_id = ppf.business_group_id
				and apl_ass.business_group_id = p_business_group_id
				and ptu.person_id         = ppf.person_id
				and l_effective_date between ptu.effective_start_date
				and  ptu.effective_end_date
				and apl_ass.person_id         = ppf.person_id
				and apl_ass.assignment_id = p_assignment_id
				and apl_ass.assignment_type ='A'
				and l_effective_date between apl_ass.effective_start_date
				and  apl_ass.effective_end_date
				) ;

cursor c_person_selection (cv_formula_id number
               , cv_business_group_id number
                           , cv_effective_date date
                           ) is
      select fff.formula_id
      from ff_formulas_f fff,
           ff_formulas_f fff1
      where fff.business_group_id = cv_business_group_id
        and cv_effective_date between fff.effective_start_date
                                  and fff.effective_end_date
        and fff.formula_name      = fff1.formula_name
        and cv_effective_date between fff1.effective_start_date
                                  and fff1.effective_end_date
        and fff1.formula_id        = cv_formula_id;

cursor c_chk_ler(cv_effective_date date) is
		select a.ler_id
		from ben_ler_f a
		where a.business_group_id = p_business_group_id
		and a.typ_cd = 'IREC'
		and a.ler_id = p_life_event_id
		and cv_effective_date between a.effective_start_date and
		nvl(a.effective_end_date,to_date('31/12/4712','DD/MM/YYYY'));

begin
  --
 --hr_utility.trace_on(null, 'TRC');

  hr_utility.set_location ('Entering '||l_proc,10);
  --

  hr_utility.set_location ('p_business_group_id '||p_business_group_id,10);
  hr_utility.set_location ('p_life_event_id '||p_life_event_id,10);
  hr_utility.set_location ('p_ocrd_date '||p_ocrd_date,10);
  hr_utility.set_location ('p_assignment_id '||p_assignment_id,10);
  hr_utility.set_location ('p_person_id '||p_person_id,10);
  hr_utility.set_location ('p_person_selection_rule_id '||p_person_selection_rule_id,10);
  --

  --
  l_effective_date:=trunc(fnd_date.canonical_to_date(p_effective_date));
  l_ocrd_date:=trunc(fnd_date.canonical_to_date(p_ocrd_date));

  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);

  -- the following situation should never occur
  -- but to ensure everything goes fine, we are adding this validation
  open c_chk_ler(l_effective_date);
  fetch c_chk_ler into l_dummy;
  if c_chk_ler%notfound then
    close c_chk_ler;
    hr_utility.set_location ('The Passed LER ID is Wrong  ',30);
    fnd_message.set_name('BEN','BEN_PASSED_LER_ID_IS_WRONG');
    raise l_no_irec_ler;

  end if;
  close c_chk_ler;


  --
  -- Get chunk_size and Thread values for multi-thread process.
  --
  ben_batch_utils.ini;
  ben_batch_utils.ini(p_actn_cd => 'PROC_INFO');
  --

  benutils.get_parameter(p_business_group_id  => p_business_group_id
                        ,p_batch_exe_cd       => 'BENBOCON'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed);

  --
  -- Create benefit actions parameters in the benefit action table.
  -- Do not create if a benefit action already exists, in other words
  -- we are doing a restart.
  --
  -- Create benefit actions parameters in the benefit action table.
  -- Do not create if a benefit action already exists, in other words
  -- we are doing a restart.
  --

  If p_benefit_action_id is null then
    --
    ben_benefit_actions_api.create_benefit_actions
      (p_validate               => false
      ,p_benefit_action_id      => l_benefit_action_id
      ,p_process_date           => l_effective_date
      ,p_mode_cd                => 'S'
      ,p_derivable_factors_flag => 'N'
      ,p_validate_flag          => p_validate
      ,p_person_id              => p_person_id
      ,p_person_type_id         => null
      ,p_pgm_id                 => null
      ,p_business_group_id      => p_business_group_id
      ,p_pl_typ_id              => null
      ,p_pl_id                  => null
      ,p_popl_enrt_typ_cycl_id  => null
      ,p_no_programs_flag       => 'N'
      ,p_no_plans_flag          => 'N'
      ,p_comp_selection_rl      => null
      ,p_person_selection_rl    => p_person_selection_rule_id
      ,p_ler_id                 => p_life_event_id
      ,p_organization_id        => null
      ,p_benfts_grp_id          => null
      ,p_location_id            => null
      ,p_pstl_zip_rng_id        => p_assignment_id   -- Note that we have reused
      ,p_rptg_grp_id            => null
      ,p_opt_id                 => null
      ,p_eligy_prfl_id          => null
      ,p_vrbl_rt_prfl_id        => null
      ,p_legal_entity_id        => null
      ,p_payroll_id             => null
      ,p_debug_messages_flag    => p_debug_messages
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_effective_date
      ,p_request_id             => fnd_global.conc_request_id
      ,p_program_application_id => fnd_global.prog_appl_id
      ,p_program_id             => fnd_global.conc_program_id
      ,p_program_update_date    => sysdate
      ,p_date_from              => l_ocrd_date
      ,p_uneai_effective_date   => null);
    --
    benutils.g_benefit_action_id := l_benefit_action_id;
    --
    hr_utility.set_location ('l_benefit_action_id created is  '||l_benefit_action_id,30);
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
        l_person_selection := null;
        fetch c_person into l_person_id, l_business_group_id;
        hr_utility.set_location ('next person selected is  '||l_person_id,30);
        exit when c_person%notfound;
        --
        l_cnt := l_cnt + 1;
        --
        skip := false;
        --
        If p_person_selection_rule_id is not NULL then
        --
        open c_person_selection (p_person_selection_rule_id, l_business_group_id, l_ocrd_date);
        fetch c_person_selection into l_person_selection;
        close c_person_selection;
        --fnd_file.put_line(fnd_file.log,' l_business_group_id  '||l_business_group_id||'l_person_selection' ||l_person_selection);

        if l_person_selection is not null then
        --
          --
          rl_ret := ben_batch_utils.person_selection_rule
                      (p_person_id               => l_person_id
                      ,p_business_group_id       => l_business_group_id
                      ,p_person_selection_rule_id=> l_person_selection--p_person_selection_rule_id
                      ,p_effective_date          => l_effective_date);
          --
          If rl_ret = 'N' then
            --
            skip := TRUE;
            --
          End if;
          --
        else --l_person_selection is null --
          skip := TRUE; --
        end if;  --

        End if;
        --
        -- Store person_id into person actions table.
        --
        If (not skip) then
          --
          hr_utility.set_location ('person passed selection rule  '||l_person_id,35);
          Ben_person_actions_api.create_person_actions
            (p_validate              => false
            ,p_person_action_id      => l_person_action_id
            ,p_person_id             => l_person_id
            ,p_ler_id                => l_ler_id
            ,p_benefit_action_id     => l_benefit_action_id
            ,p_action_status_cd      => 'U'
            ,p_chunk_number          => l_chunk_num
            ,p_object_version_number => l_object_version_number
            ,p_effective_date        => l_effective_date);
          --
          hr_utility.set_location ('person action created is  '||l_person_action_id,40);
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
          ----
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
            hr_utility.set_location ('person action range created is  '||l_range_id,45);
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
    --
    hr_utility.set_location('l_num_row='||to_char(l_num_row),48);
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
      hr_utility.set_location('l_num_row='||to_char(l_num_row),50);
      hr_utility.set_location ('person action range created is  '||l_range_id,55);
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
  hr_utility.set_location('l_num_range = '||to_char(l_num_range),50);
  hr_utility.set_location('l_person_cnt = '||to_char(l_person_cnt),50);

  If l_num_range > 1 then
    --
    For l_count in 1..least(l_threads,l_num_range)-1 loop
      --
      hr_utility.set_location('spawning thread  #'||l_count,60);
      --
      l_request_id := fnd_request.submit_request
                       (application => 'BEN'
                       ,program     => 'BEIRECBT' -- Currently not there
                       ,description => NULL
                       ,sub_request => FALSE
                       ,argument1   => p_validate
                       ,argument2   => l_benefit_action_id
                       ,argument3   => l_count
                       ,argument4   => p_effective_date
                       ,argument5   => p_business_group_id
                       ,argument6   => p_ocrd_date
                       ,argument7   => p_assignment_id
                       ,argument8   => p_life_event_id
                       ,argument9   => p_bckt_stat_cd
                       );
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
     ,p_ler_id                   => p_life_event_id
     ,p_organization_id          => null
     ,p_benfts_grp_id            => null
     ,p_location_id              => null
     ,p_legal_entity_id          => null);
    --
  --
  hr_utility.set_location('No person selected  ',999);
-- hr_utility.trace_off;
    fnd_message.set_name('BEN','BEN_91769_NOONE_TO_PROCESS');
    fnd_message.set_token('PROC' , l_proc);
    raise l_no_one_to_process;
    --
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
                ,p_ocrd_date          => p_ocrd_date
                ,p_assignment_id        => p_assignment_id
                ,p_life_event_id      => p_life_event_id
                ,p_bckt_stat_cd       => p_bckt_stat_cd
                );
  --
  hr_utility.set_location('waiting for slaves',65);
  --
  ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
  ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                             ,p_person_selected   => l_person_cnt
                             ,p_business_group_id => p_business_group_id);
  --
  hr_utility.set_location('hurray my slaves are done',70);
  --


  -- THIS SHOULD NOT HAPPEN HERE.
  savepoint data_change;

  if p_validate = 'Y' then
    hr_utility.set_location('Rolling back transaction ',10);
    rollback to data_change;
  end if;
  --

  hr_utility.set_location ('Leaving '||l_proc,75);
  --
  --hr_utility.trace_off;
Exception

  when l_no_one_to_process then
    benutils.write(p_text => fnd_message.get);
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);

 when l_no_irec_ler then
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
          ,business_group_id
          ,person_selection_rl
          ,ler_id
          ,debug_messages_flag
          ,date_from
          ,ptnl_ler_for_per_stat_cd
          ,person_id
          , pstl_zip_rng_id  -- using this for assignment id
       --   ,pl_id
    From  ben_benefit_actions ben
    Where ben.benefit_action_id = p_benefit_action_id;
  --
  -- Local Variable declaration.
  --
  l_proc        varchar2(80) := g_package||'.restart';
  l_parameters  c_parameters%rowtype;
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
         ,p_life_event_id            => l_parameters.ler_id
         ,p_ocrd_date                => fnd_date.date_to_canonical
                                        (l_parameters.date_from)
         ,p_assignment_id            => l_parameters.pstl_zip_rng_id
         ,p_person_selection_rule_id => l_parameters.person_selection_rl
         ,p_debug_messages           => l_parameters.debug_messages_flag);
  --
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
end restart;
--
--
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                   << Procedure: p_back_out_irec_le >>
-- *****************************************************************
-- this procedure is a self-service wrapper or called from BENDSPLE
-- to backout irec LE
--
procedure p_back_out_irec_le
       (p_per_in_ler_id         in number,
        p_bckt_stat_cd          in varchar2 default 'VOIDD',
        p_business_group_id     in number,
        p_effective_date        in date) is

cursor c_get_le_det is
   select ler_id, to_char(lf_evt_ocrd_dt,'YYYY/MM/DD HH24:MI:SS'), person_id, assignment_id
   from ben_per_in_ler pil
   where pil.per_in_ler_id = p_per_in_ler_id
   and pil.business_group_id = p_business_group_id
   and pil.lf_evt_ocrd_dt <= p_effective_date;
  --
  -- Local Variable declaration.
  --
  l_proc        varchar2(80) := g_package||'.p_back_out_irec_le';
  l_errbuf      varchar2(80);
  l_retcode     number;
  l_ler_id      number;
  l_person_id   number;
  l_assignment_id number;
  l_lf_evt_ocrd_dt varchar2(30);
  l_effective_date varchar2(30) := to_char(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  --
begin
 --
   hr_utility.set_location ('Entering '||l_proc,10);
 --
 -- Get all the PIL Details
 --
   open c_get_le_det;
     fetch c_get_le_det into l_ler_id, l_lf_evt_ocrd_dt, l_person_id, l_assignment_id;
      if c_get_le_det%found then
       close c_get_le_det;
      l_effective_date := to_char(p_effective_date,'YYYY/MM/DD HH24:MI:SS');

       -- Submit the backout process
       ben_irec_back_out_conc.process(
                errbuf                      => l_errbuf
                ,retcode                    => l_retcode
                ,p_effective_date           => l_effective_date
                ,p_validate                 => 'N'
                ,p_business_group_id        => p_business_group_id
                ,p_person_id                => l_person_id
                ,p_life_event_id            => l_ler_id
                ,p_ocrd_date                => l_lf_evt_ocrd_dt
                ,p_assignment_id            => l_assignment_id
                , p_bckt_stat_cd            => 'VOIDD'
                ,p_debug_messages           => 'N');
      else
         close c_get_le_det;
          hr_utility.set_location ('PIL Details Not found '||l_proc,70);
      end if;
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
end p_back_out_irec_le;
--
--
end ben_irec_back_out_conc;
--

/
