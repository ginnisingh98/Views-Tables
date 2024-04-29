--------------------------------------------------------
--  DDL for Package Body BEN_BACK_OUT_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BACK_OUT_CONC" as
/* $Header: benbocon.pkb 120.0 2005/05/28 03:44:14 appldev noship $ */
--
/* ============================================================================
*    Name
*       Back-out Life Events Concurrent Manager Processes
*
*    Purpose
*       This package simply houses the concurrent manager and multi-thread
*       processes for Back-out Life Events.
*
*    History
*      Date        Who        Version    What?
*      ---------   ---------  -------    --------------------------------------
*      13-Jul-99   isen       115.0      Created
*      20-JUL-99   Gperry     115.1      genutils -> benutils package rename.
*      03-AUG-99   Gperry     115.2      CBO fix to_char with soft coded
*                                        keyflex.
*      13-SEP-99   Asen       115.3      Added call to error reports.
*      04-OCT-99   Gperry     115.4      Made whole process actually work.
*      14-MAY-00   Anupam     115.5      Assigning values into g_rec.text for
*                                        extration of data for Summary report.
*      18-MAY-00   Anupam     115.6      Assigning per_in_ler_id into g_rec.temporal_ler_id
*                                        for extraction of data for Audit Report
*      27-DEC-01   Rpillay    115.7      Added check to allow only the latest
*                                        life event to be backed out nocopy Bug# 2129181
*      27-DEC-01   Rpillay    115.8      added dbdrv,checkfile and commit
*      18-Jan-01   Rpillay    115.9      CWB changes Bug # 2183388
*      16-APR-02   vsethi     115.10     bug # 2275321 changed the person query to not
					 include the union clause
*      24-MAY-02   rpillay    115.12     Bug# 2376330 Added code for displaying
*                                        Error Message code and National identifier
*                                        in Person error reports
*      08-Jun-02   pabodla    115.13     Do not select the contingent worker
*                                        assignment when assignment data is
*                                        fetched.
*      09-Jun-02   pbodla     115.14     Bug 2547536 : Backout the dummy per in
*                                        ler's (Associated with managers)
*                                        created in cross business group.
*      19-DEC-02   nhunur                No copy.
*      27-Apr-03   mmudigon    115.16    Absences July FP enhancements
*      08-Sep-03   pbodla      115.17    When backout process errors for a
*                                        person subsequent life events are
*                                        not backed out for the thread.
*      09-Sep-03   rpgupta     115.18    3136058 Grade step backout
*      20-Aug-04   nhunur      115.19    3840255 - Changed person selecton rule exception handling.
*      03-Dec-04   swjain       115.20   4034201 - passed p_bckt_stat_cd as input parameter for
*                                                       p_ptnl_ler_for_per_stat_cd in create_benefit_actions call.
* -----------------------------------------------------------------------------
*/
--
-- Global cursor and variables declaration
--
g_package                 varchar2(80) := 'ben_back_out_conc';
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
             ,p_from_ocrd_date        in     varchar2
             ,p_to_ocrd_date          in     varchar2
             ,p_life_event_id         in     number
             ,p_organization_id       in     number
             ,p_location_id           in     number
             ,p_benfts_grp_id         in     number
             ,p_legal_entity_id       in     number
             ,p_bckt_stat_cd          in     varchar2
             ,p_abs_ler               in     varchar2) is
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
  l_from_ocrd_date         date;
  l_to_ocrd_date           date;
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
  cursor c_ler_thread is

-- grade step backout
-- 3136058
    select pil.per_in_ler_id,
           pil.person_id,
           pil.per_in_ler_stat_cd,
           pil.lf_evt_ocrd_dt,
           ler.typ_cd,
           ler.ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.person_id = l_person_id
    and    pil.lf_evt_ocrd_dt
           between l_from_ocrd_date
           and     l_to_ocrd_date
    and    pil.business_group_id+0 = p_business_group_id
    and    ((p_abs_ler = 'N' and
             pil.ler_id = p_life_event_id
             and
             ( ( ler.typ_cd = 'GSP'
                 and pil.per_in_ler_stat_cd = 'STRTD'
                )
              or
               ( ler.typ_cd <> 'GSP'
                and pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
                )
              )
            ) or
             (p_abs_ler = 'Y' and
              pil.ler_id in
                  (select ler.ler_id
                     from ben_ler_f ler
                    where ler.typ_cd = 'ABS'
                      and ler.lf_evt_oper_cd in ('START','END')
                      and    pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
                      and ler.business_group_id = p_business_group_id
                      and l_effective_date between ler.effective_start_date
                          and ler.effective_end_date)))
    and    ler.ler_id = pil.ler_id
    and    nvl(l_effective_date,trunc(sysdate))
           between ler.effective_start_date
           and ler.effective_end_date
    order  by pil.person_id desc,
           pil.lf_evt_ocrd_dt desc,
           decode(ler.lf_evt_oper_cd,'END',2,1) desc;


  --
  l_ler_thread c_ler_thread%rowtype;
  --
  cursor c_ler_abs_thread is
    select pil.per_in_ler_id,
           pil.person_id,
           pil.per_in_ler_stat_cd,
           pil.lf_evt_ocrd_dt,
           ler.typ_cd,
           ler.ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.person_id = l_person_id
    and    pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
    and    pil.lf_evt_ocrd_dt
           between l_ler_thread.lf_evt_ocrd_dt
           and     l_to_ocrd_date
    and    pil.business_group_id+0 = p_business_group_id
    and    ler.ler_id = pil.ler_id
    and    nvl(l_effective_date,trunc(sysdate))
           between ler.effective_start_date
           and ler.effective_end_date
    and    pil.per_in_ler_id <> l_ler_thread.per_in_ler_id
    and    ler.lf_evt_oper_cd <> 'DEL'
    order  by pil.person_id desc,
           pil.lf_evt_ocrd_dt desc,
           decode(ler.lf_evt_oper_cd,'END',2,1) desc;
  l_ler_abs_thread c_ler_abs_thread%rowtype;

  Cursor c_parameter is
    Select *
    From   ben_benefit_actions ben
    Where  ben.benefit_action_id = p_benefit_action_id;
  --
  l_parm c_parameter%rowtype;
  --
  l_commit number;
  l_per_rec       per_all_people_f%rowtype;
  l_per_dummy_rec per_all_people_f%rowtype;
  --
  cursor c_latest_ler is
     select pil.per_in_ler_id,
            ler.name
     from   ben_per_in_ler pil,
            ben_ler_f  ler
     where  pil.person_id = l_person_id
     and    pil.business_group_id+0  = p_business_group_id
     and    pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
     and    pil.ler_id = ler.ler_id
     and    ler.typ_cd not in ('SCHEDDU','COMP', 'GSP')
     and    nvl(l_effective_date,trunc(sysdate))
            between ler.effective_start_date
            and ler.effective_end_date
     order  by pil.lf_evt_ocrd_dt desc, pil.per_in_ler_id desc;
  --
  cursor c_latest_ler_abs is
     select pil.per_in_ler_id,
            ler.name
     from   ben_per_in_ler pil,
            ben_ler_f  ler
     where  pil.person_id = l_person_id
     and    pil.business_group_id+0  = p_business_group_id
     and    pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
     and    pil.ler_id = ler.ler_id
     and    ler.typ_cd not in ('ABS','SCHEDDU','COMP', 'GSP')
     and    pil.lf_evt_ocrd_dt >= l_from_ocrd_date
     and    nvl(l_effective_date,trunc(sysdate))
            between ler.effective_start_date
            and ler.effective_end_date
     order  by pil.lf_evt_ocrd_dt desc, pil.per_in_ler_id desc;
  --
  cursor c_latest_ler_cwb is
     select pil.per_in_ler_id,
            ler.name
     from   ben_per_in_ler pil,
            ben_ler_f  ler
     where  pil.person_id = l_person_id
     and    pil.business_group_id+0  = p_business_group_id
     and    pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
     and    pil.ler_id = ler.ler_id
     and    ler.typ_cd = 'COMP'
     and    ler.ler_id = p_life_event_id
     and    nvl(l_effective_date,trunc(sysdate))
            between ler.effective_start_date
            and ler.effective_end_date
     order by pil.lf_evt_ocrd_dt desc, pil.per_in_ler_id desc;
  -- 3136058
  cursor c_latest_ler_gsp is
     select pil.per_in_ler_id,
            ler.name
     from   ben_per_in_ler pil,
            ben_ler_f  ler
     where  pil.person_id = l_person_id
     and    pil.business_group_id+0  = p_business_group_id
     and    pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
     and    pil.ler_id = ler.ler_id
     and    ler.typ_cd = 'GSP'
     and    ler.ler_id = p_life_event_id
     and    nvl(l_effective_date,trunc(sysdate))
            between ler.effective_start_date
            and ler.effective_end_date
     order by pil.lf_evt_ocrd_dt desc, pil.per_in_ler_id desc;



  --
  l_latest_ler c_latest_ler%rowtype;
  --

  cursor c_person is
    select ppf.*
    from   per_all_people_f ppf
    where  ppf.person_id = l_person_id
    and    nvl(l_effective_date,trunc(sysdate))
           between ppf.effective_start_date
           and     ppf.effective_end_date;

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
  l_from_ocrd_date:=trunc(fnd_date.canonical_to_date(p_from_ocrd_date));
  l_to_ocrd_date:=trunc(fnd_date.canonical_to_date(p_to_ocrd_date));
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','benutils.get_parameter');
  benutils.get_parameter(p_business_group_id  => p_business_group_id
                        ,p_batch_exe_cd       => 'BENBOCON'
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

        --
        -- Commented out for CWB - Bug # 2183388
        -- Using cursor c_person below to duplicate the functionality
        --
        /*
        fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
        fnd_message.set_token('PROC','ben_person_object');
        ben_person_object.get_object(p_person_id => l_person_id,
                                     p_rec       => l_per_rec);
        */

        --
        -- CWB - Added to avoid calling ben_person_object.get_object
        --

        open c_person;
        l_per_rec := l_per_dummy_rec;
        fetch c_person into l_per_rec;
        close c_person;

        --
        -- CWB
        --

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
              fnd_file.put_line(fnd_file.log,'per_in_ler_id  '||l_ler_thread.per_in_ler_id);
              fnd_file.put_line(fnd_file.log,'typ_cd  '||l_ler_thread.typ_cd);

              --
              --  This is to check that only the most recent LE's
              --  are allowed to be backed out
              --
              --

              if l_ler_thread.typ_cd = 'ABS' then
              --
                open c_latest_ler_abs;
                fetch c_latest_ler_abs into l_latest_ler;
                if c_latest_ler_abs%found then
                   close c_latest_ler_abs;
                   fnd_message.set_name('BEN','BEN_93383_ABS_LE_CANNOT_BO');
                   fnd_message.set_token('P_LER',l_latest_ler.name);
                   fnd_message.raise_error;
                end if;
                close c_latest_ler_abs;
              --
              elsif l_ler_thread.typ_cd = 'COMP' then
              --
                open c_latest_ler_cwb;
                fetch c_latest_ler_cwb into l_latest_ler;
                if c_latest_ler_cwb%found then
                  if l_latest_ler.per_in_ler_id <> l_ler_thread.per_in_ler_id then
                    close c_latest_ler_cwb;
                    fnd_message.set_name('BEN','BEN_92216_NOT_LATST_PER_IN_LER');
                    fnd_message.raise_error;
                  end if;
                end if;
                close c_latest_ler_cwb;
              --
              elsif l_ler_thread.typ_cd = 'GSP' then
              -- 3136058
                open c_latest_ler_gsp;
                fetch c_latest_ler_gsp into l_latest_ler;
                if c_latest_ler_gsp%found then
                  if l_latest_ler.per_in_ler_id <> l_ler_thread.per_in_ler_id then
                    close c_latest_ler_gsp;
                    fnd_message.set_name('BEN','BEN_92216_NOT_LATST_PER_IN_LER');
                    fnd_message.raise_error;
                  end if;
                end if;
                close c_latest_ler_gsp;

              --
              else
              --
                open c_latest_ler;
                fetch c_latest_ler into l_latest_ler;
                if c_latest_ler%found then
                  if l_latest_ler.per_in_ler_id <> l_ler_thread.per_in_ler_id then
                    close c_latest_ler;
                    fnd_message.set_name('BEN','BEN_92216_NOT_LATST_PER_IN_LER');
                    fnd_message.raise_error;
                  end if;
                end if;
                close c_latest_ler;
              --
              end if;
              --
              --
              fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
              fnd_message.set_token('PROC','ben_back_out_life_event');
	      ben_back_out_life_event.g_enrt_made_flag := Null;
              ben_back_out_life_event.back_out_life_events
               (p_per_in_ler_id      => l_ler_thread.per_in_ler_id
               ,p_business_group_id  => p_business_group_id
               ,p_bckt_stat_cd       => p_bckt_stat_cd
               ,p_effective_date     => l_effective_date);
              --
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

            if c_latest_ler%isopen then

              close c_latest_ler;
              --
            end if;

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
            -- g_rec.text := fnd_message.get; -- Bug 2376630 Moved code below benutils.get_message_name
            g_rec.person_id := l_person_id;

            -- Bug 2376330 start
            -- Added National Identifier and Error Message code

            g_rec.national_identifier := l_per_rec.national_identifier;
            g_rec.error_message_code := benutils.get_message_name;
            g_rec.text := fnd_message.get;

            -- Bug 2376330 end
            --
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
          ,business_group_id
          ,popl_enrt_typ_cycl_id
          ,person_selection_rl
          ,ler_id
          ,organization_id
          ,location_id
          ,benfts_grp_id
          ,legal_entity_id
          ,debug_messages_flag
	  ,date_from
	  ,uneai_effective_date
          ,ptnl_ler_for_per_stat_cd
          ,inelg_action_cd
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
         ,p_life_event_id            => l_parameters.ler_id
         ,p_from_ocrd_date           => fnd_date.date_to_canonical
                                        (l_parameters.date_from)
         ,p_to_ocrd_date             => fnd_date.date_to_canonical
                                        (l_parameters.uneai_effective_date)
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
                 ,p_life_event_id            in     number
                 ,p_from_ocrd_date           in     varchar2
                 ,p_to_ocrd_date             in     varchar2
                 ,p_organization_id          in     number   default null
                 ,p_location_id              in     number   default null
                 ,p_benfts_grp_id            in     number   default null
                 ,p_legal_entity_id          in     number   default null
                 ,p_person_selection_rule_id in     number   default null
                 ,p_debug_messages           in     varchar2 default 'N'
                 ,p_bckt_stat_cd             in     varchar2 default 'UNPROCD'
                 ,p_abs_ler                  in     varchar2 default 'N') is
  --
  l_effective_date         date;
  l_from_ocrd_date         date;
  l_to_ocrd_date           date;
  l_no_one_to_process      exception; --Bug 2253040
  l_bckt_stat                 varchar2(20);
  --
  -- Cursors declaration.
  --
 cursor c_person is
 -- grade step backout
 -- 3136058
 select ppf.person_id
    from   per_all_people_f ppf
    where  -- bug 2547536 ppf.business_group_id = p_business_group_id and
      l_effective_date
           between ppf.effective_start_date
           and     ppf.effective_end_date
    and    exists (select null
                   from   ben_per_in_ler pil
                   	  , ben_ler_f ler
                   where  pil.lf_evt_ocrd_dt between l_from_ocrd_date
                          and l_to_ocrd_date
                   and    pil.ler_id = ler.ler_id
                   and    l_effective_date between ler.effective_start_date
                          and ler.effective_end_date
                   and    ler.business_group_id = p_business_group_id
                   and    ((p_abs_ler = 'N'
                            and pil.ler_id = p_life_event_id
                            and
                              ( ( ler.typ_cd = 'GSP'
                                  and pil.per_in_ler_stat_cd = 'STRTD'
                                 )
                                or
                                ( ler.typ_cd <> 'GSP'
                                  and pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
                                 )
                               )
                            )
                            or
                           (p_abs_ler = 'Y'
			    and ler.typ_cd = 'ABS'
                            and ler.lf_evt_oper_cd in ('START','END')
                            and pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
                            )
                           )
                   and    pil.business_group_id = p_business_group_id
                   and    pil.person_id = ppf.person_id
                   )
                   -- Bug 2547536 -- and    pil.business_group_id = ppf.business_group_id)
    and    (p_organization_id is null
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

    -- begin bug #2275321
    -- The union does not contain checks for organization, benefit group,
    -- legal entity and location. Also as all types of life events (comp, dsblty etc)
    -- are fetched by the above sql, there is no need for the union
    /*
    UNION
    select ppf.person_id
    from   per_all_people_f ppf
    where  l_effective_date between ppf.effective_start_date and ppf.effective_end_date
    and    exists (select null
                   from   ben_per_in_ler pil,
                          ben_ler_f ler
                   where  ler.ler_id = pil.ler_id
                   and    ler.typ_cd = 'COMP'
                   and    l_effective_date
                          between ler.effective_start_date
                          and ler.effective_end_date
                   and    pil.per_in_ler_stat_cd in ('STRTD','PROCD')
                   and    pil.lf_evt_ocrd_dt
                          between l_from_ocrd_date
                          and     l_to_ocrd_date
                   and    pil.ler_id = p_life_event_id
                   and    pil.person_id = ppf.person_id
                   and    pil.business_group_id = p_business_group_id);
      */
      -- end bug # 2275321
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
  l_person_ok    varchar2(1) := 'Y';
  l_err_message  varchar2(2000);
Begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  l_effective_date:=trunc(fnd_date.canonical_to_date(p_effective_date));
  l_from_ocrd_date:=trunc(fnd_date.canonical_to_date(p_from_ocrd_date));
  l_to_ocrd_date:=trunc(fnd_date.canonical_to_date(p_to_ocrd_date));
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
                        ,p_batch_exe_cd       => 'BENBOCON'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed);
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
      ,p_person_id              => null
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
      ,p_organization_id        => p_organization_id
      ,p_benfts_grp_id          => p_benfts_grp_id
      ,p_location_id            => p_location_id
      ,p_pstl_zip_rng_id        => null
      ,p_rptg_grp_id            => null
      ,p_opt_id                 => null
      ,p_eligy_prfl_id          => null
      ,p_vrbl_rt_prfl_id        => null
      ,p_legal_entity_id        => p_legal_entity_id
      ,p_payroll_id             => null
      ,p_debug_messages_flag    => p_debug_messages
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_effective_date
      ,p_request_id             => fnd_global.conc_request_id
      ,p_program_application_id => fnd_global.prog_appl_id
      ,p_program_id             => fnd_global.conc_program_id
      ,p_program_update_date    => sysdate
      ,p_date_from              => l_from_ocrd_date
      ,p_uneai_effective_date   => l_to_ocrd_date
      --Bug No 4034201
      ,p_ptnl_ler_for_per_stat_cd => p_bckt_stat_cd);
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
        l_person_ok := 'Y';
        --
        If p_person_selection_rule_id is not NULL then
          --
          ben_batch_utils.person_selection_rule
                      (p_person_id               => l_person_id
                      ,p_business_group_id       => p_business_group_id
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
          --
        End if;
        --
        -- Store person_id into person actions table.
        --
        If l_person_ok = 'Y'  then
          --
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
                       ,program     => 'BENBOCOM'
                       ,description => NULL
                       ,sub_request => FALSE
                       ,argument1   => p_validate
                       ,argument2   => l_benefit_action_id
                       ,argument3   => l_count
                       ,argument4   => p_effective_date
                       ,argument5   => p_business_group_id
                       ,argument6   => p_from_ocrd_date
                       ,argument7   => p_to_ocrd_date
                       ,argument8   => p_life_event_id
                       ,argument9   => p_organization_id
                       ,argument10  => p_location_id
                       ,argument11  => p_benfts_grp_id
                       ,argument12  => p_legal_entity_id
                       ,argument13  => p_bckt_stat_cd
                       ,argument14  => p_abs_ler);
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
     ,p_organization_id          => p_organization_id
     ,p_benfts_grp_id            => p_benfts_grp_id
     ,p_location_id              => p_location_id
     ,p_legal_entity_id          => p_legal_entity_id);
    --
    fnd_message.set_name('BEN','BEN_91769_NOONE_TO_PROCESS');
    --Bug 2253040
    fnd_message.set_token('PROC' , l_proc);
    raise l_no_one_to_process;
    -- fnd_message.raise_error;
    --Bug 2253040
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
                ,p_from_ocrd_date     => p_from_ocrd_date
                ,p_to_ocrd_date       => p_to_ocrd_date
                ,p_life_event_id      => p_life_event_id
                ,p_organization_id    => p_organization_id
                ,p_location_id        => p_location_id
                ,p_benfts_grp_id      => p_benfts_grp_id
                ,p_legal_entity_id    => p_legal_entity_id
                ,p_bckt_stat_cd       => p_bckt_stat_cd
                ,p_abs_ler            => p_abs_ler);
  --
  ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
  ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                             ,p_person_selected   => l_person_cnt
                             ,p_business_group_id => p_business_group_id);
  --
  -- submit summary report here
  --
  l_request_id := fnd_request.submit_request
                  (application    => 'BEN',
                   program        => 'BENBOSUM',
                   description    => null,
                   sub_request    => false,
                   argument1      => fnd_global.conc_request_id);
  --
  --submit Error reports here
  --
  l_request_id := fnd_request.submit_request
                  (application    => 'BEN',
                   program        => 'BENERTYP',
                   description    => null,
                   sub_request    => false,
                   argument1      => fnd_global.conc_request_id);
  --
  l_request_id := fnd_request.submit_request
                  (application    => 'BEN',
                   program        => 'BENERPER',
                   description    => null,
                   sub_request    => false,
                   argument1      => fnd_global.conc_request_id);
  --
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
  hr_utility.trace_off;
Exception
    --Bug 2253040
  when l_no_one_to_process then
    benutils.write(p_text => fnd_message.get);
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    --Bug 2253040

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
end ben_back_out_conc;  -- End of Package.

/
