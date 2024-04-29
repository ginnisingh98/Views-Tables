--------------------------------------------------------
--  DDL for Package Body BEN_MANAGE_OPEN_ENRT_WNDW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_MANAGE_OPEN_ENRT_WNDW" as
/* $Header: benmnoew.pkb 120.0.12000000.1 2007/05/31 10:04:27 swjain noship $ */
--
/* ============================================================================
*    Name
*       MANAGE OPEN ENROLLMENT WINDOW Concurrent Manager Process
*
*    Purpose
*       This package simply houses the concurrent manager and multi-thread
*       processes for Managing Open Enrollment Window.
*
*    History
*      Date        Who        Version    What?
*      ---------   ---------  -------    -----------------------------------------------------------
*      14-Jul-06   swjain     115.0      Created
*      26-Jul-06   swjain     115.1      Made few minor changes
*      28-Jul-06   swjain     115.2      Added more checks in check_business_rules and added pgm_id
*					 and pl_id check in c_person cursor in procedure process
*      10/30/2006  gsehgal    115.3      bug: 5611643. Log report changes
*      11/10/2006  gsehgal    115.5      bug 5611643 Log report changes.
* --------------------------------------------------------------------------------------------------
*/
--
-- Global cursor and variables declaration
--
g_package                 varchar2(80) := 'ben_manage_open_enrt_wndw';
g_persons_processed       number(9) := 0;
g_persons_ended           number(9) := 0;
g_persons_passed          number(9) := 0;
g_persons_errored         number(9) := 0;
g_max_errors_allowed      number(9) := 200;
g_rec                     ben_type.g_report_rec;
g_debug boolean := hr_utility.debug_enabled;
--
--
procedure check_business_rules
    (p_business_group_id        in number,
     p_validate                 in varchar2,
     p_new_enrt_perd_end_dt     in varchar2 default null,
     p_new_procg_end_dt         in varchar2 default null,
     p_new_dflt_enrt_dt         in varchar2 default null,
     p_no_of_days               in number   default null,
     p_pgm_id                   in number   default null,
     p_pl_id                    in number   default null
  ) is
  --
  l_package               varchar2(80) := g_package||'.check_business_rules';
 --
begin
  --
  if g_debug then
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  -- This procedure checks validity of parameters that have been passed to the
  -- BENMNGLE process.
  --
  -- Check if mandatory arguments have been stipulated
  --
  hr_api.mandatory_arg_error(p_api_name       => l_package,
                             p_argument       => 'p_business_group_id',
                             p_argument_value => p_business_group_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_package,
                             p_argument       => 'p_validate',
                             p_argument_value => p_validate);
  --
  -- Business Rule Checks
  --
  -- New Dates and no_of_days can not be both be populated
  --
  if  (p_new_enrt_perd_end_dt is not null or p_new_procg_end_dt is not null or
       p_new_dflt_enrt_dt is not null) and p_no_of_days is not null then
    --
    fnd_message.set_name('BEN','BEN_94640_NEW_DATE_OR_DAY');
    fnd_message.raise_error;
    --
  end if;
  --
  -- Either of New Dates and no_of_days should be specified
  --
  if  (p_new_enrt_perd_end_dt is null and p_new_procg_end_dt is null and
       p_new_dflt_enrt_dt is null) and p_no_of_days is null then
    --
    fnd_message.set_name('BEN','BEN_94640_NEW_DATE_OR_DAY');
    fnd_message.raise_error;
    --
  end if;
  --
  -- Both PGM and PL ID can't be set at the same time
  --
  if  (p_pl_id is not null and p_pgm_id is not null) then
    --
    fnd_message.set_name('BEN','BEN_94641_PL_OR_PGM');
    fnd_message.raise_error;
    --
  end if;
  --
 If (p_new_enrt_perd_end_dt is not null and p_new_procg_end_dt is not null
     and p_new_enrt_perd_end_dt > p_new_procg_end_dt) then
    --
    fnd_message.set_name('BEN','BEN_94014_PROC_END_ENRT_END');
    fnd_message.raise_error;
    --
  End If;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
--
exception
--
    when others then
      --
      hr_utility.set_location('Error || sqlerrm',10);
      ben_batch_utils.write('Error is : '||benutils.get_message_name||' - '||fnd_message.get);
      fnd_message.raise_error;
      --
end check_business_rules;
--
procedure print_parameters
   (p_benefit_action_id in number) is
  --
  l_package varchar2(80);
  --
  Cursor c_parameter is
    Select *
    From   ben_benefit_actions ben
    Where  ben.benefit_action_id = p_benefit_action_id;
  --
  l_parm c_parameter%rowtype;
  --
begin
  --
  if g_debug then
    l_package := g_package||'.print_parameters';
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  open c_parameter;
    --
    fetch c_parameter into l_parm;
    --
  close c_parameter;
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Runtime Parameters');
  fnd_file.put_line(which => fnd_file.log,
                    buff  => '------------------');
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Concurrent Request ID      :'||
                    fnd_global.conc_request_id);
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Validation Mode            :'||
                    hr_general.decode_lookup('YES_NO',l_parm.validate_flag));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Benefit Action ID          :'||
                    p_benefit_action_id);
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Effective Date             :'||
                    to_char(l_parm.process_date,'DD/MM/YYYY'));
		    -- l_parm.process_date);
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Business Group ID          :'||
                    l_parm.business_group_id);
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Program ID                 :'||
                    benutils.iftrue
                     (p_expression => l_parm.pgm_id is null,
                      p_true       => 'All',
                      p_false      => l_parm.pgm_id));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Plan ID                    :'||
                    benutils.iftrue
                     (p_expression => l_parm.pl_id is null,
                      p_true       => 'All',
                      p_false      => l_parm.pl_id));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Person ID                  :'||
                    benutils.iftrue
                     (p_expression => l_parm.person_id is null,
                      p_true       => 'None',
                      p_false      => l_parm.person_id));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Person Selection Rule      :'||
                    benutils.iftrue
                     (p_expression => l_parm.person_selection_rl is null,
                      p_true       => 'None',
                      p_false      => l_parm.person_selection_rl));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Ler ID                     :'||
                    benutils.iftrue
                    (p_expression => l_parm.ler_id is null,
                     p_true       => 'None',
                     p_false      =>  l_parm.ler_id));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'New Enrollment End Date    :'||
                    benutils.iftrue
                     (p_expression => l_parm.bft_attribute3 is null,
                      p_true       => 'NONE',
                      p_false      => l_parm.bft_attribute3));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'New Processing End Date    :'||
                    benutils.iftrue
                     (p_expression => l_parm.bft_attribute4 is null,
                      p_true       => 'NONE',
                      p_false      => l_parm.bft_attribute4));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'New Default Enrollment Date:'||
                    benutils.iftrue
                     (p_expression => l_parm.bft_attribute5 is null,
                      p_true       => 'NONE',
		      p_false      => l_parm.bft_attribute5));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Number of Days to Shift    :'||
                    benutils.iftrue
                     (p_expression => l_parm.bft_attribute6 is null,
                      p_true       => 'NONE',
                      p_false      => l_parm.bft_attribute6));
  -- added bug: 5611643
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Life Event Occured Date    :'||
                    benutils.iftrue
                     (p_expression => l_parm.bft_attribute7 is null,
                      p_true       => 'NONE',
		      p_false      => to_char(
					fnd_date.canonical_to_date(l_parm.bft_attribute7),'DD/MM/YYYY')));
  --

  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Organization ID            :'||
                    benutils.iftrue
                     (p_expression => l_parm.organization_id is null,
                      p_true       => 'All',
                      p_false      => l_parm.organization_id));

  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Benefit Group ID           :'||
                    benutils.iftrue
                     (p_expression => l_parm.benfts_grp_id is null,
                      p_true       => 'All',
                      p_false      => l_parm.benfts_grp_id));

  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Location ID                :'||
                    benutils.iftrue
                     (p_expression => l_parm.location_id is null,
                      p_true       => 'All',
                      p_false      => l_parm.location_id));

  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Postal Zip Range ID        :'||
                    benutils.iftrue
                     (p_expression => l_parm.pstl_zip_rng_id is null,
                      p_true       => 'All',
                      p_false      => l_parm.pstl_zip_rng_id));

  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Reporting Group ID         :'||
                    benutils.iftrue
                     (p_expression => l_parm.rptg_grp_id is null,
                      p_true       => 'All',
                      p_false      => l_parm.rptg_grp_id));

  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Legal Entity ID            :'||
                    benutils.iftrue
                     (p_expression => l_parm.legal_entity_id is null,
                      p_true       => 'All',
                      p_false      => l_parm.legal_entity_id));

  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Payroll ID                 :'||
                    benutils.iftrue
                     (p_expression => l_parm.payroll_id is null,
                      p_true       => 'All',
                      p_false      => l_parm.payroll_id));

  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Audit Log Flag             :'||
                    l_parm.debug_messages_flag);

  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
end print_parameters;
--
-- ============================================================================
--                        << Procedure: Do_Multithread >>
--  Description:
--  	this procedure is called from 'process'.  It calls the Update POPL.
-- ============================================================================
procedure do_multithread
                 (errbuf                     out nocopy varchar2
                 ,retcode                    out nocopy number
                 ,p_benefit_action_id        in     number
                 ,p_effective_date           in     varchar2
                 ,p_thread_id                in     number
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_business_group_id        in     number
                 ,p_pgm_id                   in     number   default null
                 ,p_pl_id                    in     number   default null
                 ,p_lf_evt_ocrd_dt           in     varchar2 default null
                 ,p_ler_id                   in     number   default null
                 ,p_new_enrt_perd_end_dt     in     varchar2 default null
                 ,p_new_procg_end_dt         in     varchar2 default null
                 ,p_new_dflt_enrt_dt         in     varchar2 default null
                 ,p_no_of_days               in     number   default null
                 ,p_audit_log_flag           in     varchar2 default 'N') is
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
  l_popl_cnt               number(5):= 0;
  l_chunk_size             number(15);
  l_threads                number(15);
  l_new_enrt_perd_end_dt   date;
  l_new_procg_end_dt       date;
  l_new_dflt_enrt_dt       date;
  l_effective_date         date;
  l_lf_evt_ocrd_dt         date;
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
  Cursor c_pel is-- (p_per_in_ler_id number) is
    select ppf.full_name, pil.per_in_ler_id,
           pil.person_id,
           pil.per_in_ler_stat_cd,
           pil.lf_evt_ocrd_dt,
           ler.typ_cd,
           ler.ler_id,
	   ler.name,
	   pel.pil_elctbl_chc_popl_id, pel.enrt_perd_strt_dt,
           pel.enrt_perd_end_dt, pel.procg_end_dt, pel.dflt_enrt_dt,
	   pel.object_version_number
    from   ben_per_in_ler pil,
           ben_ler_f ler,
	   ben_pil_elctbl_chc_popl pel,
           per_all_people_f ppf
    where pil.person_id = l_person_id
      and pil.lf_evt_ocrd_dt = nvl(l_lf_evt_ocrd_dt,pil.lf_evt_ocrd_dt)
      and pil.business_group_id+0 = p_business_group_id
      and pil.ler_id = nvl(p_ler_id,pil.ler_id)
      and pil.per_in_ler_stat_cd = 'STRTD'
      and ler.typ_cd not in ('SCHEDDU','GSP','ABS','COMP')
      and ler.ler_id = pil.ler_id
      and nvl(l_effective_date,trunc(sysdate))
          between ler.effective_start_date
              and ler.effective_end_date
      and pel.per_in_ler_id = pil.per_in_ler_id
      and ((p_pl_id is null and pgm_id = nvl(p_pgm_id, pgm_id)) or
           (p_pgm_id is null and pl_id = nvl(p_pl_id, pl_id)))
      and pel.business_group_id = p_business_group_id
      and ppf.person_id = pil.person_id
      and nvl(l_effective_date,trunc(sysdate))
          between ppf.effective_start_date
              and ppf.effective_end_date
    order  by pel.pil_elctbl_chc_popl_id;
  --
  l_pel c_pel%rowtype;
  --
  l_commit number;
  --
Begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location ('Entering '||l_proc,10);
    hr_utility.set_location ('p_benefit_action_id is :'||p_benefit_action_id,10);
    hr_utility.set_location ('p_effective_date is :'||p_effective_date,10);
    hr_utility.set_location ('p_thread_id is :'||p_thread_id,10);
    hr_utility.set_location ('p_pgm_id is :'||p_pgm_id,10);
    hr_utility.set_location ('p_pl_id is :'||p_pl_id,10);
  end if;
  --
  l_effective_date:=trunc(fnd_date.canonical_to_date(p_effective_date));
  l_lf_evt_ocrd_dt:=trunc(fnd_date.canonical_to_date(p_lf_evt_ocrd_dt));
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','dt_fndate.change_ses_date');
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','benutils.get_parameter');
  benutils.get_parameter(p_business_group_id  => p_business_group_id
                        -- bug: 5611643
			-- ,p_batch_exe_cd       => 'BENMNOEM'
			,p_batch_exe_cd       => 'BENMNOEW'
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
    print_parameters
     (p_benefit_action_id        => p_benefit_action_id);
  --
  if p_audit_log_flag = 'Y' then
    -- ben_batch_utils.write(rpad('-',140,'-'));
    ben_batch_utils.write(rpad('-',150,'-'));
    ben_batch_utils.write('| EMP NAME                      | '||'Status       | '||'POPL ID   | '||
                        'Old Enrt Perd | '||'New Enrt Perd | '||
                        'Old Processing | '||'New Processing | '||
			'Old Dflt  | '||'New Dflt  |');
    ben_batch_utils.write('| '||rpad(' ',30)||'| '||rpad(' ',13)||'| '||rpad(' ',10)||'| '||
                        rpad('End Date',14)||'| '||rpad('End Date',14)||'| '||
                        rpad('End Date',15)||'| '||rpad('End Date',15)||'| '||
                        rpad('End Date',10)||'| '||rpad('End Date',10)||'|');
    -- ben_batch_utils.write(rpad('-',140,'-'));
    ben_batch_utils.write(rpad('-',150,'-'));
  end if;
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
        begin
          --
          open c_pel;
	      loop
	      fetch c_pel into l_pel;
	      exit when c_pel%NOTFOUND;
	      --
              hr_utility.set_location('per_in_ler_id  '||l_pel.per_in_ler_id,10);
              hr_utility.set_location('typ_cd  '||l_pel.typ_cd,10);
	        if (p_no_of_days is not null) then
  		    hr_utility.set_location('In IF part...',10);
                    hr_utility.set_location('Adding no of days to all dates...',10);
		    l_new_enrt_perd_end_dt := l_pel.enrt_perd_end_dt + p_no_of_days;
                    l_new_procg_end_dt     := l_pel.procg_end_dt + p_no_of_days;
                    l_new_dflt_enrt_dt     := l_pel.dflt_enrt_dt + p_no_of_days;
                else
		    hr_utility.set_location('In ELSE part...',10);
   		    l_new_enrt_perd_end_dt := l_pel.enrt_perd_end_dt;
                    l_new_procg_end_dt     := l_pel.procg_end_dt;
                    l_new_dflt_enrt_dt     := l_pel.dflt_enrt_dt;
		    --
		    if p_new_enrt_perd_end_dt is not null then
		       hr_utility.set_location('Replacing enrt end date...',10);
                       l_new_enrt_perd_end_dt := trunc(fnd_date.canonical_to_date(p_new_enrt_perd_end_dt));
                    end if;
		    if p_new_procg_end_dt is not null then
		       hr_utility.set_location('Replacing procg end date...',10);
                       l_new_procg_end_dt := trunc(fnd_date.canonical_to_date(p_new_procg_end_dt));
                    end if;
		    if p_new_dflt_enrt_dt is not null then
		       hr_utility.set_location('Replacing dflt enrt date...',10);
                       l_new_dflt_enrt_dt := trunc(fnd_date.canonical_to_date(p_new_dflt_enrt_dt));
                    end if;
		    --
                 end if;
		 --
		 if g_debug then
  		   hr_utility.set_location('New ...enrt_perd_end_dt'||l_new_enrt_perd_end_dt,10);
		   hr_utility.set_location('New ...procg_end_dt'||l_new_procg_end_dt,10);
		   hr_utility.set_location('New ...dflt_enrt_dt'||l_new_dflt_enrt_dt,10);
                 end if;
		 /* Now updating the POPL record */
		 hr_utility.set_location('Updating POPL record : '||l_pel.pil_elctbl_chc_popl_id,10);
	         BEN_pil_elctbl_chc_popl_API.update_pil_elctbl_chc_popl
				(p_validate => FALSE
				,p_PIL_ELCTBL_CHC_POPL_ID => l_pel.pil_elctbl_chc_popl_id
				,p_DFLT_ENRT_DT => l_new_dflt_enrt_dt
				,p_ENRT_PERD_END_DT => l_new_enrt_perd_end_dt
				,p_PROCG_END_DT => l_new_procg_end_dt
      			        ,p_OBJECT_VERSION_NUMBER => l_pel.object_version_number
				,p_effective_date => l_effective_date
				);
		 hr_utility.set_location('Updation done'||l_pel.pil_elctbl_chc_popl_id,10);
              --
              if p_audit_log_flag = 'Y' then
      	        ben_batch_utils.write('| '||rpad(l_pel.full_name,30)||'| '||'SUCCESS      | '||
	                        rpad(l_pel.pil_elctbl_chc_popl_id,10)||'| '||
	                        rpad(l_pel.enrt_perd_end_dt,14)||'| '||rpad(l_new_enrt_perd_end_dt,14)||'| '||
				rpad(l_pel.procg_end_dt,15)||'| '||rpad(l_new_procg_end_dt,15)||'| '||
                                rpad(l_pel.dflt_enrt_dt,10)||'| '||rpad(l_new_dflt_enrt_dt,10)||'|');
              end if;
              l_popl_cnt := l_popl_cnt + 1;
              --
              end loop;
	      --
              close c_pel;
	      if l_popl_cnt = 0 then
	        if p_audit_log_flag = 'Y' then
     	           ben_batch_utils.write('| '||rpad(l_pel.full_name,30)||'| '||'UNSUCCESSFUL | No record found for the given set of conditions.');
                end if;
		hr_utility.set_location('No POPL record found for '||l_pel.full_name ||' for the given set of conditions.',10);
              end if;
	      l_popl_cnt := 0;
          --
          -- If we get here it was successful.
          --
          update ben_person_actions
              set   action_status_cd = 'P'
              where person_id = l_person_id
              and   benefit_action_id = p_benefit_action_id;
          --
          g_persons_processed := g_persons_processed + 1;
          --
        exception
          --
          when others then
            --
            hr_utility.set_location('Super Error exception level',10);
            hr_utility.set_location(sqlerrm,10);
            --
            if c_pel%isopen then

              close c_pel;
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
            --
            hr_utility.set_location('Error Message '||g_rec.text,10);
	    if p_audit_log_flag = 'Y' then
   	        -- changed bug: 5611643
	      /*
	      ben_batch_utils.write('| '||rpad(l_pel.full_name,18)||'| '||'UNSUCCESSFUL | Error is - '||
	                            benutils.get_message_name||' - '||substr(fnd_message.get,1,80));
		*/
		DECLARE
		   l_message_text     VARCHAR2 (2100);
		   l_message_length   NUMBER          := 148; -- := 136;
		BEGIN
		   l_message_text :=
			 '| '
		      || RPAD (l_pel.full_name, 30)
		      || '| '
		      || 'UNSUCCESSFUL | Error is - '
		      || benutils.get_message_name
		      || ' - '
		      || fnd_message.get;
		   ben_batch_utils.WRITE (SUBSTR (l_message_text, 1, l_message_length) || ' |');

		   LOOP
		      IF LENGTH (l_message_text) > l_message_length
		      THEN
			 l_message_text :=
			       RPAD ('| ', 47)
			    || '|'
			    || SUBSTR (l_message_text, l_message_length + 1);
			 ben_batch_utils.WRITE (   SUBSTR (l_message_text, 1,
							   l_message_length));
		      ELSE
			 EXIT;
		      END IF;
		   END LOOP;
		END;

            end if;
            --
            hr_utility.set_location('Max Errors = '||g_max_errors_allowed,10);
            hr_utility.set_location('Num Errors = '||g_persons_errored,10);
            -- if g_persons_errored > g_max_errors_allowed then
	    if g_persons_errored >= g_max_errors_allowed then
              --
              fnd_message.set_name('BEN','BEN_94642_BENMNOEW_ERROR_LIMIT');
              ben_batch_utils.write(p_text => fnd_message.get);
              --
              raise;
              --
            end if;
            --
        end;
        --
      end loop;
      --
      hr_utility.set_location('Closing c_person_thread',10);
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
    hr_utility.set_location('Commiting transaction ',10);
    --
    commit;
    --
  end loop;
  --
  if p_audit_log_flag = 'Y' then
    ben_batch_utils.write(rpad('-',140,'-'));
  end if;
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
    g_rec.ler_id := p_ler_id;
    g_rec.rep_typ_cd := 'FATAL';
    g_rec.text := fnd_message.get;
    g_rec.person_id := l_person_id;
    --
    benutils.write(p_text => g_rec.text);
    benutils.write(p_rec => g_rec);
    --
    ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_processed
                                 ,p_num_pers_errored   => g_persons_errored);
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
          ,person_selection_rl
          ,ler_id
          ,organization_id
          ,location_id
          ,benfts_grp_id

          ,pgm_id
          ,pl_id
          ,pstl_zip_rng_id
          ,rptg_grp_id
          ,legal_entity_id
          ,payroll_id
          ,debug_messages_flag
          ,object_version_number
          ,request_id
          ,program_application_id
          ,program_id
          ,program_update_date
          ,bft_attribute3
          ,bft_attribute4
          ,bft_attribute5
          ,bft_attribute6
	  ,bft_attribute7
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
/*  process(errbuf                     => l_errbuf
         ,retcode                    => l_retcode
         ,p_benefit_action_id        => p_benefit_action_id
         ,p_effective_date           => fnd_date.date_to_canonical
                                        (l_parameters.process_date)
         ,p_validate                 => l_parameters.validate_flag
         ,p_business_group_id        => l_parameters.business_group_id
         ,p_ler_id                   => l_parameters.ler_id
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
 */
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
procedure process(errbuf                        out nocopy varchar2
                 ,retcode                       out nocopy number
                 ,p_benefit_action_id        in     number
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_person_id                in     number   default null
                 ,p_person_selection_rule_id in     number   default null
                 ,p_business_group_id        in     number
                 ,p_pgm_id                   in     number   default null
                 ,p_pl_id                    in     number   default null
                 ,p_lf_evt_ocrd_dt           in     varchar2 default null
                 ,p_ler_id                   in     number   default null
                 ,p_new_enrt_perd_end_dt     in     varchar2 default null
                 ,p_new_procg_end_dt         in     varchar2 default null
                 ,p_new_dflt_enrt_dt         in     varchar2 default null
                 ,p_no_of_days               in     number   default null
                 ,p_organization_id          in     number   default null
                 ,p_benfts_grp_id            in     number   default null
                 ,p_location_id              in     number   default null
                 ,p_pstl_zip_rng_id          in     number   default null
                 ,p_rptg_grp_id              in     number   default null
                 ,p_legal_entity_id          in     number   default null
                 ,p_payroll_id               in     number   default null
                 ,p_audit_log_flag           in     varchar2 default 'N') is
  --
  l_effective_date         date;
  l_lf_evt_ocrd_dt         date;
  l_to_ocrd_date           date;
  l_no_one_to_process      exception;
  l_bckt_stat                 varchar2(20);
  --
  -- Cursors declaration.
  --
 cursor c_person is
 select ppf.person_id
    from   per_all_people_f ppf
    where  ppf.person_id = nvl(p_person_id, ppf.person_id)
           and ppf.business_group_id = p_business_group_id
           and l_effective_date
           between ppf.effective_start_date
           and     ppf.effective_end_date
           and    exists (select null
                   from   ben_per_in_ler pil
                   	    , ben_ler_f ler
                   where  pil.lf_evt_ocrd_dt = nvl(l_lf_evt_ocrd_dt,  pil.lf_evt_ocrd_dt)
                   and    pil.ler_id = ler.ler_id
                   and    l_effective_date between ler.effective_start_date
                          and ler.effective_end_date
                   and    ler.business_group_id = p_business_group_id
   	           and    ler.typ_cd not in ('SCHEDDU','GSP','ABS','COMP')
                   and    pil.ler_id = nvl(p_ler_id, pil.ler_id)
                   and    pil.per_in_ler_stat_cd = 'STRTD'
	           and    pil.business_group_id = p_business_group_id
                   and    pil.person_id = ppf.person_id
                   and    pil.business_group_id = ppf.business_group_id
		   and   exists (select pil_elctbl_chc_popl_id
                                   from ben_pil_elctbl_chc_popl
                                   where per_in_ler_id = pil.per_in_ler_id
                                    and ((p_pl_id is null and pgm_id = nvl(p_pgm_id, pgm_id)) or
                                         (p_pgm_id is null and pl_id = nvl(p_pl_id, pl_id)))))
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
                     and    soft.segment1 = to_char(p_legal_entity_id)))
      and (p_payroll_id is null
          or exists (select null
                     from pay_payrolls_f pay,
                          per_all_assignments_f paf
                    where paf.person_id = ppf.person_id
                    and   paf.assignment_type <> 'C'
                    and paf.primary_flag = 'Y'
                    and paf.business_group_id = ppf.business_group_id
                    and l_effective_date
                        between paf.effective_start_date
                        and paf.effective_end_date
                    and pay.payroll_id = p_payroll_id
                    and pay.payroll_id = paf.payroll_id
                    and l_effective_date
                        between pay.effective_start_date
                        and pay.effective_end_date))
      and (p_pstl_zip_rng_id is null
          or exists (select null
                     from per_addresses pad,
                          ben_pstl_zip_rng_f rzr
                     where pad.person_id = ppf.person_id
                     and pad.primary_flag = 'Y'
                     and l_effective_date
                         between nvl(pad.date_from,l_effective_date)
                         and nvl(pad.date_to,l_effective_date)
                     and rzr.pstl_zip_rng_id = p_pstl_zip_rng_id
                     and pad.postal_code
                         between rzr.from_value
                         and rzr.to_value
                     and l_effective_date
                         between rzr.effective_start_date
                         and rzr.effective_end_date));
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
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location ('Entering '||l_proc,10);
     hr_utility.set_location ('p_validate : '||p_validate,5);
  end if;
  --
  -- Check that business rules that apply to this conc request are being adhered to.
  --
  check_business_rules
    (p_business_group_id        => p_business_group_id,
     p_validate                 => p_validate,
     p_new_enrt_perd_end_dt     => p_new_enrt_perd_end_dt,
     p_new_procg_end_dt         => p_new_procg_end_dt,
     p_new_dflt_enrt_dt         => p_new_dflt_enrt_dt,
     p_no_of_days               => p_no_of_days,
     p_pgm_id                   => p_pgm_id,
     p_pl_id                    => p_pl_id
  );
  --
  l_effective_date:=trunc(fnd_date.canonical_to_date(p_effective_date));
  l_lf_evt_ocrd_dt:=trunc(fnd_date.canonical_to_date(p_lf_evt_ocrd_dt));
  --
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
      (p_ses_date => nvl(l_lf_evt_ocrd_dt,l_effective_date),
       p_commit   => l_commit);
  --
  -- Get chunk_size and Thread values for multi-thread process.
  --
  ben_batch_utils.ini;
  ben_batch_utils.ini(p_actn_cd => 'PROC_INFO');
  --
  benutils.get_parameter(p_business_group_id  => p_business_group_id
                        -- bug 5611643
			-- ,p_batch_exe_cd       => 'BENMNGLE'
			,p_batch_exe_cd       => 'BENMNOEW'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_errors_allowed);
  if g_debug then
     hr_utility.set_location (l_proc||' Done get pm ',30);
     hr_utility.set_location('Num Threads = '||l_threads,10);
     hr_utility.set_location('Chunk Size = '||l_chunk_size,10);
     hr_utility.set_location('Max Errors = '||g_max_errors_allowed,10);
  end if;
  --
  --
  -- Create benefit actions parameters in the benefit action table.
  -- Do not create if a benefit action already exists, in other words
  -- we are doing a restart.
  --
  if p_benefit_action_id is null then
  --
     if g_debug then
        hr_utility.set_location (l_proc||' Create BFT ',30);
     end if;
  --
    ben_benefit_actions_api.create_benefit_actions
      (p_validate               => false
      ,p_benefit_action_id      => l_benefit_action_id
      ,p_process_date           => l_effective_date
      ,p_mode_cd                => 'S'
      ,p_derivable_factors_flag => 'N'
      ,p_validate_flag          => p_validate
      ,p_person_id              => p_person_id
      ,p_pgm_id                 => p_pgm_id
      ,p_business_group_id      => p_business_group_id
      ,p_pl_id                  => p_pl_id
      ,p_person_selection_rl    => p_person_selection_rule_id
      ,p_ler_id                 => p_ler_id
      ,p_organization_id        => p_organization_id
      ,p_benfts_grp_id          => p_benfts_grp_id
      ,p_location_id            => p_location_id
      ,p_pstl_zip_rng_id        => p_pstl_zip_rng_id
      ,p_rptg_grp_id            => p_rptg_grp_id
      ,p_legal_entity_id        => p_legal_entity_id
      ,p_payroll_id             => p_payroll_id
      ,p_debug_messages_flag    => p_audit_log_flag
      ,p_no_programs_flag       => 'N'
      ,p_no_plans_flag          => 'N'
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_effective_date
      ,p_request_id             => fnd_global.conc_request_id
      ,p_program_application_id => fnd_global.prog_appl_id
      ,p_program_id             => fnd_global.conc_program_id
      ,p_program_update_date    => sysdate
      ,p_bft_attribute3         => p_new_enrt_perd_end_dt
      ,p_bft_attribute4         => p_new_procg_end_dt
      ,p_bft_attribute5         => p_new_dflt_enrt_dt
      ,p_bft_attribute6         => p_no_of_days
      -- added bug 5611643
      ,p_bft_attribute7         => p_lf_evt_ocrd_dt
      );
    --
    benutils.g_benefit_action_id := l_benefit_action_id;
    --
    if g_debug then
       hr_utility.set_location (' l_benefit_action_id : '||l_benefit_action_id,20);
       hr_utility.set_location (l_proc||' Dn Create BFT ',20);
    end if;
    --
    -- Delete/clear ranges from ben_batch_ranges table
    --
    Delete from ben_batch_ranges
    Where  benefit_action_id = l_benefit_action_id;
    --
    -- Now lets create person actions for all the people we are going to process
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

         if l_err_message  is not null then
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
                       ,program     => 'BENMNOEM'
                       ,description => NULL
                       ,sub_request => FALSE
                       ,argument1   => l_benefit_action_id
                       ,argument2   => p_effective_date
                       ,argument3   => l_count
                       ,argument4   => p_validate
                       ,argument5   => p_business_group_id
                       ,argument6   => p_pgm_id
                       ,argument7   => p_pl_id
                       ,argument8   => p_lf_evt_ocrd_dt
                       ,argument9   => p_ler_id
                       ,argument10  => p_new_enrt_perd_end_dt
                       ,argument11  => p_new_procg_end_dt
                       ,argument12  => p_new_dflt_enrt_dt
                       ,argument13  => p_no_of_days
                       ,argument14  => p_audit_log_flag);
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
   print_parameters
     (p_benefit_action_id        => l_benefit_action_id);
  --
    fnd_message.set_name('BEN','BEN_91769_NOONE_TO_PROCESS');
    fnd_message.set_token('PROC' , l_proc);
    raise l_no_one_to_process;
  --
  End if;
  --
  do_multithread(errbuf                      =>  errbuf
                 ,retcode                    =>  retcode
                 ,p_benefit_action_id        =>  l_benefit_action_id
                 ,p_effective_date           =>  p_effective_date
                 ,p_thread_id                =>  l_threads+1
                 ,p_validate                 =>  p_validate
                 ,p_business_group_id        =>  p_business_group_id
                 ,p_pgm_id                   =>  p_pgm_id
                 ,p_pl_id                    =>  p_pl_id
                 ,p_lf_evt_ocrd_dt           =>  p_lf_evt_ocrd_dt
                 ,p_ler_id                   =>  p_ler_id
                 ,p_new_enrt_perd_end_dt     =>  p_new_enrt_perd_end_dt
                 ,p_new_procg_end_dt         =>  p_new_procg_end_dt
                 ,p_new_dflt_enrt_dt         =>  p_new_dflt_enrt_dt
                 ,p_no_of_days               =>  p_no_of_days
                 ,p_audit_log_flag           =>  p_audit_log_flag);
  --
  ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
  ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                             ,p_person_selected   => l_person_cnt
                             ,p_business_group_id => p_business_group_id);
  --
  -- need to write summary contents here
  --
  --
  hr_utility.set_location ('Leaving '||l_proc,70);
--
Exception
  --
  when l_no_one_to_process then
    ben_batch_utils.write(p_text => fnd_message.get);
  --
  when others then
     --
     hr_utility.set_location('Super Error',10);
     rollback;
     ben_batch_utils.write(p_text => fnd_message.get);
     ben_batch_utils.write(p_text => sqlerrm);
     --
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
end BEN_MANAGE_OPEN_ENRT_WNDW;  -- End of Package.

/
