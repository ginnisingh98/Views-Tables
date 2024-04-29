--------------------------------------------------------
--  DDL for Package Body BEN_PURGE_BCKDT_VOIDED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PURGE_BCKDT_VOIDED" AS
/* $Header: benprbck.pkb 120.5.12010000.2 2008/08/05 14:49:30 ubhat ship $ */
--
g_package          varchar2(80) := 'ben_purge_bckdt_voided';
g_max_person_err   Number := 100;
g_persons_errored  Number := 0;
g_persons_procd    Number := 0;
g_cache_per_proc   g_cache_person_process_rec;
g_elig_rows        number := 0;
g_elig_per_rows    number := 0;
g_enrt_rt_rows     number := 0;
g_enrt_prem_rows   number := 0;
g_enrt_bnft_rows   number := 0;
g_elctbl_chc_ctfn_rows     number := 0;
g_elig_per_elctbl_chc_rows number := 0;
g_pil_elctbl_chc_popl_rows number := 0;
g_elig_dpnt_rows           number := 0;
g_prtt_rt_rows             number := 0;
g_prtt_enrt_actn_rows      number := 0;
g_prtt_prem_rows           number := 0;
g_ctfn_prvdd_rows          number := 0;
g_elig_cvrd_dpnt_rows      number := 0;
g_prtt_enrt_rslt_rows      number := 0;
g_pl_bnf_rows              number := 0;
g_prmry_care_rows          number := 0;
g_per_in_ler_rows          number := 0;
g_ptnl_ler_rows            number := 0;
g_le_clsn_rows             number := 0;

--
-- ==================================================================================
--                        << Procedure: person_selection_rule >>
--  Description:
--      this procedure is called from 'process'.  It calls the person selection rule.
--   this has been added to report errors for a person while executing the selection rule
--   and prevent the conc process from failing .
-- ==================================================================================
procedure person_selection_rule
		 (p_person_id                in  Number
                 ,p_business_group_id        in  Number
                 ,p_person_selection_rule_id in  Number
                 ,p_effective_date           in  Date
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
         And p_effective_date between paf.effective_start_date and paf.effective_end_date ;
  --
  l_proc   	       varchar2(80) := g_package||'.person_selection_rule';
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
      close c1;
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
  --
  p_return := l_outputs(l_outputs.first).value;
  --
  l_actn := 'Evaluating benutils.formula return...';
  --
  If upper(p_return) not in ('Y', 'N')  then
      Raise value_exception ;
  End if;
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
      p_err_message := 'Unhandled exception while processing Person : '||to_char(p_person_id)
                       ||' in package : '|| l_proc ||'.' || substr(sqlerrm,1,170);

End person_selection_rule;
--
--

procedure print_parameters
            (p_thread_id                in number
            ,p_validate                 in varchar2
            ,p_benefit_action_id        in number
            ,p_effective_date           in date
            ,p_business_group_id        in number
            ,p_person_id                in number    default hr_api.g_number
            ,p_ler_id                   in number    default hr_api.g_number
            ,p_organization_id          in number    default hr_api.g_number
            ,p_benfts_grp_id            in number    default hr_api.g_number
            ,p_location_id              in number    default hr_api.g_number
            ,p_legal_entity_id          in number    default hr_api.g_number
            ,p_payroll_id               in number    default hr_api.g_number
            ,p_person_selection_rule_id in number	 default hr_api.g_number
            ,p_audit_log                in varchar2	 default hr_api.g_varchar2
            ,p_from_ocrd_date           in     date default null
            ,p_to_ocrd_date             in     date default null
            ,p_life_evt_typ_cd          in     varchar2 default null
            ,p_bckt_stat_cd             in     varchar2 default 'VOIDD'
            ,p_delete_life_evt          in     varchar2 default 'N'
            ,p_delete_ptnl_life_evt     in     varchar2 default 'N'
            ) is
  l_proc        varchar2(80) := g_package||'.print_parameters';
  l_string      varchar2(80);
  l_actn        varchar2(80);
begin
  hr_utility.set_location ('Entering '||l_proc,10);
  ben_batch_utils.write(p_text => 'Runtime Parameters');
  ben_batch_utils.write(p_text => '------------------');
  ben_batch_utils.write(p_text => 'Thread ID                  :'||to_char(p_thread_id));
  ben_batch_utils.write(p_text => 'Validation Mode            :' ||
                  hr_general.decode_lookup('YES_NO',p_validate));
  ben_batch_utils.write(p_text => 'Benefit Action ID          :' ||
                  to_char(p_benefit_action_id));
  ben_batch_utils.write(p_text => 'Effective Date             :' ||
                  to_char(p_effective_date,'DD/MM/YYYY'));
  ben_batch_utils.write(p_text =>'Business Group ID          :' || p_business_group_id);
  --
  If (nvl(p_person_selection_rule_id,-1) <> hr_api.g_number) then
      ben_batch_utils.write(p_text => 'Person Selection Rule      :'||
                      benutils.iftrue
                           (p_expression => p_person_selection_rule_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_person_selection_rule_id));
  End if;
  --
  l_actn := 'Printing p_person_id...';
  If (nvl(p_person_id,-1) <> hr_api.g_number) then
      ben_batch_utils.write(p_text => 'Person ID                  :'||
                      benutils.iftrue
                           (p_expression => p_person_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_person_id));
  End if;
  --
  --
  l_actn := 'Printing p_ler_id...';
  If (nvl(p_ler_id,-1) <> hr_api.g_number) then
      ben_batch_utils.write(p_text => 'Ler ID                     :'||
                      benutils.iftrue
                           (p_expression => p_ler_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_ler_id));
  End if;
  --
  l_actn := 'Printing p_organization_id...';
  If (nvl(p_organization_id,-1) <> hr_api.g_number) then
      ben_batch_utils.write(p_text => 'Organization ID            :'||
                      benutils.iftrue
                           (p_expression => p_organization_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_organization_id));
  End if;
  --
  l_actn := 'Printing p_benfts_grp_id...';
  If (nvl(p_benfts_grp_id,-1) <> hr_api.g_number) then
      ben_batch_utils.write(p_text => 'Benefits Group ID          :'||
                      benutils.iftrue
                           (p_expression => p_benfts_grp_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_benfts_grp_id));
  End if;
  --
  l_actn := 'Printing p_location_id...';
  If (nvl(p_location_id,-1) <> hr_api.g_number) then
      ben_batch_utils.write(p_text => 'Location ID                :'||
                      benutils.iftrue
                           (p_expression => p_location_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_location_id));
  End if;
  --
  l_actn := 'Printing p_legal_entity_id...';
  If (nvl(p_legal_entity_id,-1) <> hr_api.g_number) then
      ben_batch_utils.write(p_text => 'Legal Entity ID            :'||
                      benutils.iftrue
                           (p_expression => p_legal_entity_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_legal_entity_id));
  End if;
  --
  l_actn := 'Printing p_payroll_id...';
  If (nvl(p_payroll_id,-1) <> hr_api.g_number) then
      ben_batch_utils.write(p_text => 'Payroll ID                 :'||
                      benutils.iftrue
                           (p_expression => p_payroll_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_payroll_id));
  End if;
  --
  --
  If p_life_evt_typ_cd is not null then
     ben_batch_utils.write(p_text => 'Life Event Type Code       :' ||p_life_evt_typ_cd);
  end if;
  --
  if p_from_ocrd_date is not null then
     ben_batch_utils.write(p_text => 'From Occurred Date         :' || to_char(p_from_ocrd_date, 'DD/MM/YYYY'));
  end if;
  --
  ben_batch_utils.write(p_text => 'To   Occurred Date         :' || to_char(p_to_ocrd_date, 'DD/MM/YYYY'));
  ben_batch_utils.write(p_text => 'Backed Out Status Code     :'||p_bckt_stat_cd);
  ben_batch_utils.write(p_text => 'Delete Life Events         :'||
                             hr_general.decode_lookup('YES_NO',p_delete_life_evt));

  If (nvl(p_audit_log,'xxxx') <> hr_api.g_varchar2) then
      ben_batch_utils.write(p_text => 'Audit log flag             :'||
                      hr_general.decode_lookup('YES_NO',p_audit_log));
  End if;
  hr_utility.set_location ('Leaving '||l_proc,10);
exception
  when others then
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn );
    raise;
end print_parameters;
--
procedure process
            (errbuf                       out nocopy varchar2
            ,retcode                      out nocopy number
            ,p_benefit_action_id       in     number
            ,p_effective_date          in     varchar2
            ,p_business_group_id       in     number
            ,p_Person_id               in     number     default NULL
            ,p_Person_selection_rl     in     number     default NULL
            ,p_life_event_id            in     number   default null
            ,p_from_ocrd_date           in     varchar2 default null
            ,p_to_ocrd_date             in     varchar2
            ,p_organization_id          in     number   default null
            ,p_location_id              in     number   default null
            ,p_benfts_grp_id            in     number   default null
            ,p_legal_entity_id          in     number   default null
            ,p_payroll_id               in     number   default null
            ,p_life_evt_typ_cd          in     varchar2 default null
            ,p_bckt_stat_cd             in     varchar2 default 'VOIDD'
            ,p_audit_log_flag           in     varchar2 default 'N'
            ,p_delete_life_evt          in     varchar2
            ,p_delete_ptnl_life_evt     in     varchar2
            )
  is
  --
  -- Local variable declaration.
  --
  l_effective_date         date;
  l_person_ok              varchar2(30) := 'Y';
  l_person_actn_cnt        number(15) := 0;
  l_start_person_actn_id   number(15);
  l_end_person_actn_id     number(15);
  l_object_version_number  number(15);
  l_actn                   varchar2(80);
  l_request_id             number(15);
  l_benefit_action_id      number(15);
  l_person_id              number(15);
  l_person_action_id       number(15);
  l_range_id               number(15);
  l_chunk_size             number := 20;
  l_chunk_num              number := 1;
  l_threads                number(5) := 1;
  l_num_ranges             number := 0;
  l_from_ocrd_date         date;
  l_to_ocrd_date           date;
  --
  cursor c_person is
    select ppf.person_id from per_all_people_f ppf
    where (ppf.person_id = p_person_id or p_person_id is null)
    and   ppf.business_group_id = p_business_group_id
    and   l_effective_date between ppf.effective_start_date
          and ppf.effective_end_date
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
    and   (p_payroll_id is null
           or exists (select null
                      from per_all_assignments_f paf,
                           pay_payrolls_f pay
                      where paf.person_id = ppf.person_id
                      and   pay.payroll_id  = paf.payroll_id
                      and   paf.payroll_id = p_payroll_id
                      and   paf.assignment_type <> 'C'
                      and   paf.primary_flag = 'Y'
                      and   l_effective_date
                            between paf.effective_start_date
                            and     paf.effective_end_date
                      and   l_effective_date
                            between pay.effective_start_date
                            and     pay.effective_end_date));
  --
  l_proc       varchar2(80) := g_package||'.process';
  l_err_message  varchar2(2000);
  l_commit  number;
Begin
  --
  hr_utility.set_location('Entering '||l_proc, 1);
  /*
  l_effective_date := to_date(p_effective_date
                             ,'YYYY/MM/DD HH24:MI:SS');
  --
  l_effective_date := to_date(to_char(trunc(l_effective_date)
                                     ,'DD/MM/RRRR'),'DD/MM/RRRR');
  */
  l_effective_date :=  trunc(fnd_date.canonical_to_date(p_effective_date));
  l_from_ocrd_date:=trunc(fnd_date.canonical_to_date(p_from_ocrd_date));
  l_to_ocrd_date:=trunc(fnd_date.canonical_to_date(p_to_ocrd_date));

  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
        (p_ses_date => l_effective_date,
         p_commit   => l_commit);

  ben_batch_utils.ini(p_actn_cd => 'PROC_INFO');
  --
  -- Get the parameters defined for the batch process.
  --
  benutils.get_parameter
    (p_business_group_id   => p_business_group_id
    ,p_batch_exe_cd        => 'BENPRBCK'
    ,p_threads             => l_threads
    ,p_chunk_size          => l_chunk_size
    ,p_max_errors          => g_max_person_err);
 if p_benefit_action_id is null then
    --
    -- Create a new benefit_action row.
    --
    ben_benefit_actions_api.create_benefit_actions
      (p_validate               => FALSE
      ,p_benefit_action_id      => l_benefit_action_id
      ,p_process_date           => l_effective_date
      ,p_person_id              => p_person_id
      ,p_mode_cd                => 'P'
      ,p_business_group_id      => p_business_group_id
      ,p_person_selection_rl    => p_person_selection_rl
      ,p_no_programs_flag       => 'N'
      ,p_no_plans_flag          => 'N'
      ,p_derivable_factors_flag => 'N'
      ,p_validate_flag          => 'N'
      ,p_audit_log_flag         => p_audit_log_flag
      ,p_ler_id                 => p_life_event_id
      ,p_date_from              => l_from_ocrd_date --reuse
      ,p_lf_evt_ocrd_dt         => l_to_ocrd_date   -- reuse
      ,p_organization_id        => p_organization_id
      ,p_location_id            => p_location_id
      ,p_benfts_grp_id          => p_benfts_grp_id
      ,p_legal_entity_id        => p_legal_entity_id
      ,p_payroll_id             => p_payroll_id
      ,p_ptnl_ler_for_per_stat_cd => p_life_evt_typ_cd     --reuse
      ,p_elig_enrol_cd            => p_bckt_stat_cd        --reuse
      ,p_debug_messages_flag    => p_delete_life_evt       --reuse
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_effective_date
      ,p_request_id             => fnd_global.conc_request_id
      ,p_program_application_id => fnd_global.prog_appl_id
      ,p_program_id             => fnd_global.conc_program_id
      ,p_program_update_date    => sysdate);
    --
    benutils.g_benefit_action_id := l_benefit_action_id;
    --
    benutils.g_thread_id         := 99;
    --
    l_actn := 'Removing batch ranges ';
    --
    delete from ben_batch_ranges
     where benefit_action_id = l_benefit_action_id;

    hr_utility.set_location ('Before c_person',11);
    for l_rec in c_person
    loop
      --
      hr_utility.set_location (' c_person',11);
      -- set variables for this iteration
      --
      l_person_ok := 'Y';
      --
      -- Check the person selection rule.
      --
      if p_person_selection_rl is not null then
        --
	 person_selection_rule
                 (p_person_id                 => l_rec.person_id
                 ,p_business_group_id         => p_business_group_id
                 ,p_person_selection_rule_id  => p_person_selection_rl
                 ,p_effective_date            => l_effective_date
		 ,p_return                    => l_person_ok
                 ,p_err_message               => l_err_message );

                 if l_err_message  is not null
		 then
		     Ben_batch_utils.write(p_text =>
        		'<< Person id : '||to_char(l_rec.person_id)||' failed.'||
			'   Reason : '|| l_err_message ||' >>' );
	         end if ;
        --
      end if;
      --
      if l_person_ok = 'Y' then
        --
        -- Either no person sel rule or person selection rule passed. Create a
        -- person action row.
        --
        ben_person_actions_api.create_person_actions
          (p_validate              => FALSE
          ,p_person_action_id      => l_person_action_id
          ,p_person_id             => l_rec.person_id
          ,p_benefit_action_id     => l_benefit_action_id
          ,p_action_status_cd      => 'U'
          ,p_chunk_number          => l_chunk_num
          ,p_object_version_number => l_object_version_number
          ,p_effective_date        => l_effective_date);
        --
        -- increment the person action count
        --
        l_person_actn_cnt := l_person_actn_cnt + 1;
       -- Set the ending person action id to the last person action id that got
        -- created
        --
        l_end_person_actn_id := l_person_action_id;
        --
        -- We have to create batch ranges based on the number of person actions
        -- created and the chunk size defined for the batch process.
        --
        if mod(l_person_actn_cnt, l_chunk_size) = 1 or l_chunk_size = 1 then
          --
          -- This is the first person action id in a new range.
          --
          l_start_person_actn_id := l_person_action_id;
          --
        end if;
        --
        if mod(l_person_actn_cnt, l_chunk_size) = 0 or l_chunk_size = 1 then
          --
          -- The number of person actions that got created equals the chunk
          -- size. Create a batch range for the person actions.
          --
          ben_batch_ranges_api.create_batch_ranges
            (p_validate                  => FALSE
            ,p_effective_date            => l_effective_date
            ,p_benefit_action_id         => l_benefit_action_id
            ,p_range_id                  => l_range_id
            ,p_range_status_cd           => 'U'
            ,p_starting_person_action_id => l_start_person_actn_id
            ,p_ending_person_action_id   => l_end_person_actn_id
            ,p_object_version_number     => l_object_version_number);
          --
          l_num_ranges := l_num_ranges + 1;
          l_chunk_num := l_chunk_num + 1;
          --
        end if;
        --
      end if;
       --
    end loop;
    --
    -- There may be a few person actions left over from the loop above that may
    -- not have got inserted into a batch range because the number was less than
    -- the chunk size. Create a range for the remaining person actions. This
    -- also applies when only one person gets selected.
    --
    if l_person_actn_cnt > 0 and
       mod(l_person_actn_cnt, l_chunk_size) <> 0 then
      --
      ben_batch_ranges_api.create_batch_ranges
        (p_validate                  => FALSE
        ,p_effective_date            => l_effective_date
        ,p_benefit_action_id         => l_benefit_action_id
        ,p_range_id                  => l_range_id
        ,p_range_status_cd           => 'U'
        ,p_starting_person_action_id => l_start_person_actn_id
        ,p_ending_person_action_id   => l_end_person_actn_id
        ,p_object_version_number     => l_object_version_number);
      --
      l_num_ranges := l_num_ranges + 1;
      --
    end if;
    --
  Else
    --
    -- Benefit action id is not null i.e. the batch process is being restarted
    -- for a certain benefit action id. Create batch ranges and person actions
    -- for restarting.
    --
    l_benefit_action_id := p_benefit_action_id;
    --
    hr_utility.set_location('Restarting for benefit action id : ' ||
                            to_char(l_benefit_action_id), 10);
    ben_batch_utils.create_restart_person_actions
      (p_benefit_action_id  => p_benefit_action_id
      ,p_effective_date     => l_effective_date
      ,p_chunk_size         => l_chunk_size
      ,p_threads            => l_threads
      ,p_num_ranges         => l_num_ranges
      ,p_num_persons        => l_person_actn_cnt);
    --
  end if;
  --
  commit;
  --
  -- Submit requests to the concurrent manager based on the number of ranges
  -- that got created.
  --
  if l_num_ranges > 1 then
    --
    hr_utility.set_location('More than one range got created.', 10);
    --
    --
    -- Set the number of threads to the lesser of the defined number of threads
    -- and the number of ranges created above. There's no point in submitting
    -- 5 threads for only two ranges.
    --
    l_threads := least(l_threads, l_num_ranges);
    --
    for l_count in 1..(l_threads - 1)
    loop
      --
      -- We are subtracting one from the number of threads because the main
      -- process will act as the last thread and will be able to keep track of
      -- the child requests that get submitted.
      --
      hr_utility.set_location('Submitting request ' || l_count, 10);
      --
      l_request_id := fnd_request.submit_request
                        (application => 'BEN'
                        ,program     => 'BENPRTRD'
                        ,description => NULL
                        ,sub_request => FALSE
                        ,argument1   => l_benefit_action_id
                        ,argument2   => l_count
                        ,argument3   => p_effective_date
                        ,argument4   => p_business_group_id
                        ,argument5   => p_life_event_id
                        ,argument6   => p_from_ocrd_date
                        ,argument7   => p_to_ocrd_date
                        ,argument8   => p_organization_id
                        ,argument9   => p_location_id
                        ,argument10  => p_benfts_grp_id
                        ,argument11  => p_legal_entity_id
                        ,argument12  => p_payroll_id
                        ,argument13  => p_life_evt_typ_cd
                        ,argument14  => p_bckt_stat_cd
                        ,argument15  => p_audit_log_flag
                        ,argument16  => p_delete_life_evt
                        );
      --
      -- Store the request id of the concurrent request
      --
      ben_batch_utils.g_num_processes := ben_batch_utils.g_num_processes + 1;
      ben_batch_utils.g_processes_tbl(ben_batch_utils.g_num_processes)
        := l_request_id;
      commit;
      --
    end loop;
    --
  elsif l_num_ranges = 0 then
    --
    -- No ranges got created. i.e. no people got selected. Error out.
    --
    print_parameters
      (p_thread_id                => 99
      ,p_validate                 => 'false'
      ,p_benefit_action_id        => l_benefit_action_id
      ,p_business_group_id        => p_business_group_id
      ,p_effective_date           => l_effective_date
      ,p_person_id                => p_person_id
      ,p_person_selection_rule_id => p_person_selection_rl
      );
    --
    ben_batch_utils.write(p_text =>
                       'No person got selected with above selection criteria.');
    --
    fnd_message.set_name('BEN','BEN_91769_NOONE_TO_PROCESS');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.raise_error;
    --
  end if;
  --
  -- Carry on with the master. This will ensure that the master finishes last.
  --
  hr_utility.set_location('Submitting the master process', 10);
  --
  do_multithread
    (errbuf               => errbuf
    ,retcode              => retcode
    ,p_benefit_action_id  => l_benefit_action_id
    ,p_thread_id          => l_threads
    ,p_effective_date     => p_effective_date
    ,p_business_group_id  => p_business_group_id
    ,p_life_event_id      => p_life_event_id
    ,p_from_ocrd_date     => p_from_ocrd_date
    ,p_to_ocrd_date       => p_to_ocrd_date
    ,p_organization_id    => p_organization_id
    ,p_location_id        => p_location_id
    ,p_benfts_grp_id      => p_benfts_grp_id
    ,p_legal_entity_id    => p_legal_entity_id
    ,p_payroll_id         => p_payroll_id
    ,p_life_evt_typ_cd    => p_life_evt_typ_cd
    ,p_bckt_stat_cd       => p_bckt_stat_cd
    ,p_audit_log_flag     => p_audit_log_flag
    ,p_delete_life_evt    => p_delete_life_evt
    );
  --
  -- Check if all the slave processes are finished.
  --
  ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
  --
  --
  benutils.write(p_text => benutils.g_banner_minus);
  if p_delete_ptnl_life_evt = 'Y' and p_delete_life_evt = 'Y'
  then
   --
        delete from ben_ptnl_ler_for_per
         where ptnl_ler_for_per_stat_cd = 'VOIDD'
           and   business_group_id = p_business_group_id
	   and   (p_life_event_id is null or ler_id = p_life_event_id)
	   and   (p_person_id is null or person_id = p_person_id);

--      end if;
      --
      ben_batch_utils.write(p_text => ' No. of Voided Potentials Deleted   = ' || sql%rowcount );
  elsif p_delete_ptnl_life_evt = 'Y' and p_delete_life_evt = 'N'
  then
      If p_person_id is not null then
        delete from ben_ptnl_ler_for_per p
         where p.ptnl_ler_for_per_stat_cd = 'VOIDD'
            and   p.business_group_id = p_business_group_id
          and   p.person_id = p_person_id
            and not exists ( select 1
                       from ben_per_in_ler pil
		       where pil.PTNL_LER_FOR_PER_ID = p.PTNL_LER_FOR_PER_ID);
      else
         delete from ben_ptnl_ler_for_per p
          where p.ptnl_ler_for_per_stat_cd = 'VOIDD'
            and   p.business_group_id = p_business_group_id
            and not exists ( select 1
                       from ben_per_in_ler pil
		       where pil.PTNL_LER_FOR_PER_ID = p.PTNL_LER_FOR_PER_ID);
      end if;
      --
      ben_batch_utils.write(p_text => ' No. of Voided Potentials Deleted   = ' || sql%rowcount );
      --
  end if;
  --
  benutils.write(p_text => benutils.g_banner_minus);
  --
  -- Time to delete orphaned data in key transation tables as this causes
  -- application errors and customers expect this process to delete all such data.
  -- dont delete PEN as it has lot of other child tables.
  -- May be we shud plug in the ben post process calll here
  --
  delete from ben_elig_cvrd_dpnt_f t
  where business_group_id = p_business_group_id
  and not exists ( select 1 from ben_per_in_ler p
                   where p.per_in_ler_id = t.per_in_ler_id ) ;

  delete from ben_pl_bnf_f t
  where business_group_id = p_business_group_id
  and   not exists ( select 1 from ben_per_in_ler p
                     where p.per_in_ler_id = t.per_in_ler_id );
  --
  -- End the process.
  --
  ben_batch_utils.end_process
    (p_benefit_action_id => l_benefit_action_id
    ,p_person_selected   => l_person_actn_cnt
    ,p_business_group_id => p_business_group_id);
  --
  hr_utility.set_location ('Leaving ' || l_proc, 10);
  --
  commit;
  --
exception
  --
  when others then
    --
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => TRUE);
    --
    benutils.write(p_text => fnd_message.get);
    benutils.write(p_text => sqlerrm);
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    --
    if l_num_ranges > 0 then
      --
      ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
      --
      ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                                 ,p_person_selected   => l_person_actn_cnt
                                 ,p_business_group_id => p_business_group_id);
      --
      --submit_all_reports(p_audit_log => 'N');
      --
    end if;
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP', l_actn );
    fnd_message.raise_error;
   --
end process;
--

procedure do_multithread
  (errbuf                     out nocopy varchar2
  ,retcode                    out nocopy number
  ,p_benefit_action_id        in     number
  ,p_thread_id                in     number
  ,p_effective_date           in     varchar2
  ,p_business_group_id        in     number
  ,p_life_event_id            in     number   default null
  ,p_from_ocrd_date           in     varchar2 default null
  ,p_to_ocrd_date             in     varchar2
  ,p_organization_id          in     number   default null
  ,p_location_id              in     number   default null
  ,p_benfts_grp_id            in     number   default null
  ,p_legal_entity_id          in     number   default null
  ,p_payroll_id               in     number   default null
  ,p_life_evt_typ_cd          in     varchar2 default null
  ,p_bckt_stat_cd             in     varchar2 default 'VOIDD'
  ,p_audit_log_flag           in     varchar2 default 'N'
  ,p_delete_life_evt          in     varchar2
  )
  is
  --
  -- Local variable declaration
  --
  l_effective_date         date;
  l_proc                   varchar2(80) := g_package || '.do_multithread';
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
  l_validate               Boolean := FALSE;
  l_chunk_size             number;
  l_threads                number;
  --
  -- Cursor declarations
  --
  cursor c_range_thread
  is
  select ran.range_id
        ,ran.starting_person_action_id
        ,ran.ending_person_action_id
    from ben_batch_ranges ran
   where ran.range_status_cd = 'U'
     and ran.benefit_action_id  = p_benefit_action_id
     and rownum < 2
     for update of ran.range_status_cd;
  --
  cursor c_person_thread
  is
  select ben.person_id
        ,ben.person_action_id
        ,ben.object_version_number
    from ben_person_actions ben
   where ben.benefit_action_id = p_benefit_action_id
     and ben.action_status_cd <> 'P'
     and ben.person_action_id between l_start_person_action_id
                                  and l_end_person_action_id
   order by ben.person_action_id;
  --
  cursor c_parameter
  is
  select *
    from ben_benefit_actions ben
   where ben.benefit_action_id = p_benefit_action_id;
  --
  l_parm c_parameter%rowtype;
  l_commit number;
  --
  -- start bug 3079317
  l_rec               benutils.g_active_life_event;
  l_env               ben_env_object.g_global_env_rec_type;
  l_per_rec           per_all_people_f%rowtype;
  l_encoded_message   varchar2(2000);
  l_app_short_name    varchar2(2000);
  l_message_name      varchar2(2000);
  g_rec               ben_type.g_report_rec;
  l_from_ocrd_date  date;
  l_to_ocrd_date    date;
  --
  -- end bug 3079317

begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  /*
  l_effective_date := to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date := to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR')
                             ,'DD/MM/RRRR');
  */
  l_effective_date :=  trunc(fnd_date.canonical_to_date(p_effective_date));
  l_from_ocrd_date :=trunc(fnd_date.canonical_to_date(p_from_ocrd_date));
  l_to_ocrd_date :=trunc(fnd_date.canonical_to_date(p_to_ocrd_date));
  --
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  l_actn := 'Calling benutils.get_parameter...';
  benutils.get_parameter(p_business_group_id  => p_business_group_id
                        ,p_batch_exe_cd       => 'BENPRBCK'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_person_err);
  --
  -- Set up benefits environment
  --
  ben_env_object.init(p_business_group_id => p_business_group_id,
                      p_effective_date    => l_effective_date,
                      p_thread_id         => p_thread_id,
                      p_chunk_size        => l_chunk_size,
                      p_threads           => l_threads,
                      p_max_errors        => g_max_person_err,
                      p_benefit_action_id => p_benefit_action_id);
  --
  g_persons_procd   := 0;
  g_persons_errored := 0;
  g_elig_rows  := 0;
  g_elig_per_rows    := 0;
  g_enrt_rt_rows     := 0;
  g_enrt_prem_rows   := 0;
  g_enrt_bnft_rows   := 0;
  g_elctbl_chc_ctfn_rows     := 0;
  g_elig_per_elctbl_chc_rows := 0;
  g_pil_elctbl_chc_popl_rows := 0;
  g_elig_dpnt_rows           := 0;
  g_prtt_rt_rows             := 0;
  g_prtt_enrt_actn_rows      := 0;
  g_prtt_prem_rows           := 0;
  g_ctfn_prvdd_rows          := 0;
  g_elig_cvrd_dpnt_rows      := 0;
  g_prtt_enrt_rslt_rows      := 0;
  g_pl_bnf_rows              := 0;
  g_prmry_care_rows          := 0;
  g_per_in_ler_rows          := 0;
  g_ptnl_ler_rows            := 0;
  g_le_clsn_rows             := 0;
  --
  ben_batch_utils.ini;
  --
  benutils.g_benefit_action_id := p_benefit_action_id;
  benutils.g_thread_id         := p_thread_id;
  --
  -- Fetch the parameters defined for the batch process.
  --
  open c_parameter;
  fetch c_parameter into l_parm;
  close c_parameter;
  --
  -- Print the parameters to the log file.
  --
  print_parameters
    (p_thread_id                => p_thread_id
    ,p_benefit_action_id        => p_benefit_action_id
    ,p_validate                 => 'N'
    ,p_business_group_id        => p_business_group_id
    ,p_effective_date           => l_effective_date
    ,p_person_id                => l_parm.person_id
    ,p_person_selection_rule_id => l_parm.person_selection_rl
    ,p_location_id              => l_parm.location_id
    ,p_ler_id                   => l_parm.ler_id
    ,p_organization_id          => l_parm.organization_id
    ,p_benfts_grp_id            => l_parm.benfts_grp_id
    ,p_legal_entity_id          => l_parm.legal_entity_id
    ,p_payroll_id               => l_parm.payroll_id
    ,p_from_ocrd_date           => l_parm.date_from
    ,p_to_ocrd_date             => l_parm.lf_evt_ocrd_dt
    ,p_life_evt_typ_cd          => l_parm.ptnl_ler_for_per_stat_cd
    ,p_bckt_stat_cd             => l_parm.elig_enrol_cd
    ,p_delete_life_evt          => l_parm.debug_messages_flag
    ,p_audit_log                => p_audit_log_flag);
  --
  loop
    --
    open c_range_thread;
    fetch c_range_thread into l_range_id,
                              l_start_person_action_id,
                              l_end_person_action_id;
    --
    exit when c_range_thread%notfound;
    --
    close c_range_thread;
    --
    -- Update the range status code to processed 'P'
    --
    update ben_batch_ranges ran
       set ran.range_status_cd = 'P'
     where ran.range_id = l_range_id;
    --
    hr_utility.set_location('Updated range ' || to_char(l_range_id) ||
                            ' status code to P', 10);
    --
    commit;
    --
    -- Remove all records from cache
    --
    g_cache_per_proc.delete;
    --
    open c_person_thread;
    --
    l_record_number := 0;
    --
    hr_utility.set_location('Load person actions into the cache', 10);
    --
    loop
      --
      fetch c_person_thread into
            g_cache_per_proc(l_record_number+1).person_id
           ,g_cache_per_proc(l_record_number+1).person_action_id
           ,g_cache_per_proc(l_record_number+1).object_version_number
           ;
      --
      exit when c_person_thread%notfound;
      --
      l_record_number := l_record_number + 1;
      --
      l_actn := 'Updating person_ations.';
      --
      update ben_person_actions
         set action_status_cd = 'T'
       where person_action_id = l_person_action_id;
      --
    end loop;
    --
    close c_person_thread;
    --
    commit;
    --
    if l_record_number > 0 then
      --
      for l_cnt in 1..l_record_number
      loop
        --
        hr_utility.set_location('Purge rows for ' ||
                                to_char(g_cache_per_proc(l_cnt).person_id), 10);
        --
        begin
          --
          ben_purge_bckdt_voided.purge_single_person
            (p_effective_date        => l_effective_date
            ,p_business_group_id     => p_business_group_id
            ,p_person_id      => g_cache_per_proc(l_cnt).person_id
            ,p_life_event_id  => p_life_event_id
            ,p_from_ocrd_date => l_from_ocrd_date
            ,p_to_ocrd_date   => l_to_ocrd_date
            ,p_life_evt_typ_cd  => p_life_evt_typ_cd
            ,p_bckt_stat_cd     => p_bckt_stat_cd
            ,p_audit_log_flag   => p_audit_log_flag
            ,p_delete_life_evt  => p_delete_life_evt
            );
          g_persons_procd := g_persons_procd + 1;

        exception
          --
          when others then
          --
      ben_env_object.setenv(p_lf_evt_ocrd_dt => l_effective_date);
      ben_env_object.get(p_rec => l_env);
      ben_person_object.get_object(p_person_id => g_cache_per_proc(l_cnt).person_id,
                       p_rec       => l_per_rec);
      --
      l_encoded_message := fnd_message.get_encoded;
      fnd_message.parse_encoded(encoded_message => l_encoded_message,
                    app_short_name  => l_app_short_name,
                    message_name    => l_message_name);

      fnd_message.set_encoded(encoded_message => l_encoded_message);
      --
      g_rec.text := fnd_message.get ;
      --
      g_rec.error_message_code := nvl(l_message_name , nvl(g_rec.error_message_code,sqlcode));
      g_rec.text := nvl(g_rec.text , nvl(g_rec.text,substr(sqlerrm,1,400)) );
      g_rec.rep_typ_cd := 'ERROR';
      g_rec.person_id := g_cache_per_proc(l_cnt).person_id;
      benutils.write(p_text => g_rec.text);
      benutils.write(p_rec => g_rec);
      --
      update ben_person_actions
      set action_status_cd = 'E'
      where person_action_id = g_cache_per_proc(l_cnt).person_action_id;
      --
          g_persons_errored := g_persons_errored + 1;
          --
          if g_persons_errored > g_max_person_err then
              fnd_message.raise_error;
          end if;
          --
        end;
        --
      end loop;
      --
    else
      --
      hr_utility.set_location('No records found. Erroring out.', 10);
      --
      l_actn := 'Reporting error since there is no record found';
      --
      fnd_message.set_name('BEN','BEN_91906_PER_NOT_FND_IN_RNG');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('BENEFIT_ACTION_ID',to_char(p_benefit_action_id));
      fnd_message.set_token('BG_ID',to_char(p_business_group_id));
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
      --
    end if;
    --
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    --
    commit;
    --
  end loop;
  --
  benutils.write(p_text => benutils.g_banner_minus);
  benutils.write(p_text => 'Table Name                 No. Of Rows Deleted');
  benutils.write(p_text => '----------                 -------------------');
  benutils.write(p_text => 'Ben_elig_per_f               '||to_char(g_elig_rows));
  benutils.write(p_text => 'Ben_elig_per_opt_f           '||to_char(g_elig_per_rows));
  benutils.write(p_text => 'Ben_enrt_rt                  '||to_char(g_enrt_rt_rows));
  benutils.write(p_text => 'Ben_enrt_prem                '||to_char(g_enrt_prem_rows));
  benutils.write(p_text => 'Ben_enrt_bnft                '||to_char(g_enrt_bnft_rows));
  benutils.write(p_text => 'Ben_elctbl_chc_ctfn          '||to_char(g_elctbl_chc_ctfn_rows));
  benutils.write(p_text => 'Ben_elig_per_elctbl_chc      '||to_char(g_elig_per_elctbl_chc_rows));
  benutils.write(p_text => 'Ben_pil_elctbl_chc_popl      '||to_char(g_pil_elctbl_chc_popl_rows));
  benutils.write(p_text => 'Ben_elig_dpnt                '||to_char(g_elig_dpnt_rows));
  benutils.write(p_text => 'Ben_prtt_rt_val              '||to_char(g_prtt_rt_rows));
  benutils.write(p_text => 'Ben_prtt_enrt_actn_f         '||to_char(g_prtt_enrt_actn_rows));
  benutils.write(p_text => 'Ben_prtt_prem_f              '||to_char(g_prtt_prem_rows));
  benutils.write(p_text => 'Ben_prtt_enrt_ctfn_prvdd_f   '||to_char(g_ctfn_prvdd_rows));
  benutils.write(p_text => 'Ben_elig_cvrd_dpnt_f         '||to_char(g_elig_cvrd_dpnt_rows));
  benutils.write(p_text => 'Ben_prtt_enrt_rslt_f         '||to_char(g_prtt_enrt_rslt_rows));
  benutils.write(p_text => 'Ben_pl_bnf_f                 '||to_char(g_pl_bnf_rows));
  benutils.write(p_text => 'Ben_prmry_care_prvdr_f       '||to_char(g_prmry_care_rows));
  benutils.write(p_text => 'Ben_per_in_ler               '||to_char(g_per_in_ler_rows));
  benutils.write(p_text => 'Ben_ptnl_ler_for_per         '||to_char(g_ptnl_ler_rows));
  benutils.write(p_text => 'Ben_le_clsn_n_rstr           '||to_char(g_le_clsn_rows));
  benutils.write(p_text => benutils.g_banner_minus);
  --
  benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
  --
  commit;
  --
  --
  ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_procd
                               ,p_num_pers_errored   => g_persons_errored);
  --
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
exception
  --
  when others then
    --
    rollback;
    benutils.write(p_text => sqlerrm);
    --
    hr_utility.set_location('BENPRBCK Super Error ' || l_proc, 10);
    --
    ben_batch_utils.rpt_error(p_proc       => l_proc
                             ,p_last_actn  => l_actn
                             ,p_rpt_flag   => TRUE);
    --
    ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_procd
                                 ,p_num_pers_errored   => g_persons_errored);
    --
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP',l_actn );
    fnd_message.raise_error;
    --
end do_multithread;
--
-- -----------------------------------------------------------------------------
-- |----------------------------< restart >------------------------------------|
-- -----------------------------------------------------------------------------
--
procedure restart
  (errbuf                 out nocopy varchar2
  ,retcode                out nocopy number
  ,p_benefit_action_id in     number)
is
  --
  -- Cursor Declaration
  --
  cursor c_parameters
  is
  select --to_char(process_date, 'YYYY/MM/DD HH24:MI:SS') process_date
         fnd_date.date_to_canonical(process_date) process_date
        ,business_group_id
        ,person_id
        ,person_selection_rl
        --,life_event_id
        --,from_ocrd_date
        ,lf_evt_ocrd_dt  -- mapped to t_ocrd_date
        ,organization_id
        ,location_id
        ,benfts_grp_id
        ,legal_entity_id
        ,payroll_id
        ,CM_TRGR_TYP_CD   -- mapped to lf_evt_typ_cd
        ,PTNL_LER_FOR_PER_STAT_CD -- mapped to bck_stat_cd
        ,audit_log_flag
    From ben_benefit_actions ben
   Where ben.benefit_action_id = p_benefit_action_id;
  --
  -- Local Variable declaration.
  --
  l_parameters  c_parameters%rowtype;
  l_errbuf      varchar2(80);
  l_retcode     number;
  l_actn        varchar2(80);
  --
  l_proc        varchar2(80) := g_package||'.restart';
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- get the parameters for a previous run and do a restart
  --
  open c_parameters;
  fetch c_parameters into l_parameters;
  --
  if c_parameters%notfound then
    --
    close c_parameters;
    fnd_message.set_name('BEN','BEN_91710_RESTRT_PARMS_NOT_FND');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.raise_error;
    --
  end if;
  --
  close c_parameters;
  --
  -- Call the process procedure with parameters for restart
  --
  Process
    (errbuf                     => l_errbuf
    ,retcode                    => l_retcode
    ,p_benefit_action_id        => p_benefit_action_id
    ,p_effective_date           => l_parameters.process_date
    ,p_business_group_id        => l_parameters.business_group_id
    ,p_person_id                => l_parameters.person_id
    ,p_Person_selection_rl      => l_parameters.Person_selection_rl
    --,p_life_event_id            => l_parameters.life_event_id
    --,p_from_ocrd_date           => l_parameters.
    ,p_to_ocrd_date             => l_parameters.lf_evt_ocrd_dt
    ,p_organization_id          => l_parameters.organization_id
    ,p_location_id              => l_parameters.location_id
    ,p_benfts_grp_id            => l_parameters.benfts_grp_id
    ,p_legal_entity_id          => l_parameters.legal_entity_id
    ,p_payroll_id               => l_parameters.payroll_id
    ,p_life_evt_typ_cd          => l_parameters.CM_TRGR_TYP_CD
    ,p_bckt_stat_cd             => l_parameters.PTNL_LER_FOR_PER_STAT_CD
    ,p_audit_log_flag           => l_parameters.audit_log_flag
    );
  --
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
end restart;
--
procedure purge_single_person
            (p_effective_date          in  date
            ,p_business_group_id       in  number
            ,p_person_id        in  Number     default NULL
            ,p_life_event_id            in     number   default null
            ,p_from_ocrd_date           in     date default null
            ,p_to_ocrd_date             in     date
            ,p_life_evt_typ_cd          in     varchar2 default null
            ,p_bckt_stat_cd             in     varchar2 default 'VOIDD'
            ,p_audit_log_flag           in     varchar2 default 'N'
            ,p_delete_life_evt          in     varchar2
            )
             is

--
  l_from_ocrd_date  date;
  --
  cursor  c_per_in_ler_1  is
    select per_in_ler_id
    from  ben_per_in_ler pil
    where pil.person_id = p_person_id
    and   pil.business_group_id = p_business_group_id
    and   pil.per_in_ler_stat_cd in ('BCKDT','VOIDD')
    and   (p_life_event_id is null or pil.ler_id = p_life_event_id)
    and   pil.lf_evt_ocrd_dt between l_from_ocrd_date and p_to_ocrd_date
    and   (p_life_evt_typ_cd is null or
           exists (select null
                   from ben_ler_f ler
                   where ler.ler_id = pil.ler_id
                   and ler.typ_cd = p_life_evt_typ_cd
                   and pil.lf_evt_ocrd_dt between ler.effective_start_date and
                       ler.effective_end_date));
  --
  cursor   c_per_in_ler_2  is
    select per_in_ler_id
    from  ben_per_in_ler pil
    where pil.person_id = p_person_id
    and   pil.business_group_id = p_business_group_id
    and   pil.per_in_ler_stat_cd in ('VOIDD')
    and   (p_life_event_id is null or pil.ler_id = p_life_event_id)
    and   pil.lf_evt_ocrd_dt between l_from_ocrd_date and p_to_ocrd_date
    and   (p_life_evt_typ_cd is null or
           exists (select null
                   from ben_ler_f ler
                   where ler.ler_id = pil.ler_id
                   and ler.typ_cd = p_life_evt_typ_cd
                   and pil.lf_evt_ocrd_dt between ler.effective_start_date and
                       ler.effective_end_date));
  --
  cursor c_elctbl_chc (p_per_in_ler_id number) is
    select elig_per_elctbl_chc_id
    from   ben_elig_per_elctbl_chc epe
    where  epe.per_in_ler_id = p_per_in_ler_id;
  --
  cursor  c_prtt_enrt_rslt (p_per_in_ler_id number) is
    select prtt_enrt_rslt_id
    from   ben_prtt_enrt_rslt_f pen
    where  pen.per_in_ler_id = p_per_in_ler_id
    and    pen.prtt_enrt_rslt_stat_cd in ('BCKDT','VOIDD');
  --
  type per_in_tab is table of ben_per_in_ler.per_in_ler_id%type
  index by binary_integer;
  t_per_in_ler per_in_tab;
  t_per_in_ler2  per_in_tab;
  t_elctbl_chc   per_in_tab;
  t_rslt         per_in_tab;

Begin
  --
  --hr_utility.trace_on(null,'ORACLE');
  hr_utility.set_location('Entering purge_single_person',1);
  l_from_ocrd_date := nvl(p_from_ocrd_date, to_date('01/01/1900','dd/mm/yyyy'));
  --
  open c_per_in_ler_1;
  fetch c_per_in_ler_1 bulk collect into t_per_in_ler;
  close c_per_in_ler_1;
  --
  if p_bckt_stat_cd = 'VOIDD' then
    open c_per_in_ler_2;
    fetch c_per_in_ler_2 bulk collect into t_per_in_ler2;
    close c_per_in_ler_2;
   t_per_in_ler := t_per_in_ler2; -- Added while fixing 3670708
  else
   t_per_in_ler2 := t_per_in_ler;
  end if;
  --
   hr_utility.set_location('delete elig per',2);
  if t_per_in_ler.count > 0 then
    --
    forall i in 1..t_per_in_ler.last
      --
      delete from ben_elig_per_f pep
        where pep.per_in_ler_id = t_per_in_ler(i);
      g_elig_rows := g_elig_rows + sql%rowcount;
      --
    forall i in 1..t_per_in_ler.last
      delete from ben_elig_per_opt_f epo
        where epo.per_in_ler_id = t_per_in_ler(i);
      g_elig_per_rows := g_elig_per_rows + sql%rowcount;
      --
  end if;
  --
   hr_utility.set_location('delete elig per',3);
  if t_per_in_ler2.count > 0 then
     --
     -- added here during bug fix 3670708
		forall i in 1..t_per_in_ler2.last
		delete from ben_pil_elctbl_chc_popl pel
		where pel.per_in_ler_id = t_per_in_ler2(i);
		g_pil_elctbl_chc_popl_rows := g_pil_elctbl_chc_popl_rows + sql%rowcount;
		--
     -- End of bug fix 3670708

    for i in 1..t_per_in_ler2.last loop
       --
       t_elctbl_chc.delete;
       t_rslt.delete; -- Added while fixing 3670708
       --
       open c_elctbl_chc (t_per_in_ler2(i));
       fetch c_elctbl_chc bulk collect into t_elctbl_chc;
       close c_elctbl_chc;
       --
       open c_prtt_enrt_rslt (t_per_in_ler2(i));
       fetch c_prtt_enrt_rslt bulk collect into t_rslt;
       close c_prtt_enrt_rslt;

       -- delete all the rows related to elig per elctbl choice for the voided life event
       if t_elctbl_chc.count > 0 then
         --
         hr_utility.set_location('delete enrt rt',1);
         forall i in 1..t_elctbl_chc.last
            delete from ben_enrt_rt
            where elig_per_elctbl_chc_id = t_elctbl_chc(i);
         g_enrt_rt_rows := g_enrt_rt_rows + sql%rowcount;

         forall i in 1..t_elctbl_chc.last
            delete from ben_enrt_rt
            where enrt_bnft_id in
            (select enrt_bnft_id
               from ben_enrt_bnft
              where elig_per_elctbl_chc_id = t_elctbl_chc(i));
          g_enrt_rt_rows := g_enrt_rt_rows + sql%rowcount;

          forall i in 1..t_elctbl_chc.last
            delete from ben_enrt_prem
            where elig_per_elctbl_chc_id = t_elctbl_chc(i);
          g_enrt_prem_rows := g_enrt_prem_rows + sql%rowcount;

         forall i in 1..t_elctbl_chc.last
            delete from ben_enrt_prem
            where enrt_bnft_id in
            (select enrt_bnft_id
               from ben_enrt_bnft
              where elig_per_elctbl_chc_id = t_elctbl_chc(i));
         g_enrt_prem_rows := g_enrt_prem_rows + sql%rowcount;

         forall i in 1..t_elctbl_chc.last
            delete from ben_elctbl_chc_ctfn
            where elig_per_elctbl_chc_id  =  t_elctbl_chc(i);
         g_elctbl_chc_ctfn_rows := g_elctbl_chc_ctfn_rows + sql%rowcount;

         forall i in 1..t_elctbl_chc.last
            delete from ben_elctbl_chc_ctfn
            where  enrt_bnft_id in
                  (select enrt_bnft_id
                     from ben_enrt_bnft
                    where elig_per_elctbl_chc_id = t_elctbl_chc(i));
         g_elctbl_chc_ctfn_rows := g_elctbl_chc_ctfn_rows + sql%rowcount;

         forall i in 1..t_elctbl_chc.last
            delete from ben_enrt_bnft
            where elig_per_elctbl_chc_id  =  t_elctbl_chc(i);
         g_enrt_bnft_rows := g_enrt_bnft_rows + sql%rowcount;

          --
          -- Commented it out and deleting this thru per_in_ler above Bug 3670708
        /*
        forall i in 1..t_elctbl_chc.last
           delete from ben_pil_elctbl_chc_popl pel
           where pel.pil_elctbl_chc_popl_id =
              (select pil_elctbl_chc_popl_id
               from ben_elig_per_elctbl_chc
               where elig_per_elctbl_chc_id =  t_elctbl_chc(i));
         g_pil_elctbl_chc_popl_rows := g_pil_elctbl_chc_popl_rows + sql%rowcount;
         */

         --
         forall i in 1..t_elctbl_chc.last
            delete from ben_elig_per_elctbl_chc
            where elig_per_elctbl_chc_id  =  t_elctbl_chc(i);
         g_elig_per_elctbl_chc_rows := g_elig_per_elctbl_chc_rows + sql%rowcount;
         --
         forall i in 1..t_elctbl_chc.last
            delete from ben_elig_dpnt
            where elig_per_elctbl_chc_id  =  t_elctbl_chc(i);
         g_elig_dpnt_rows := g_elig_dpnt_rows +  sql%rowcount;

       end if;
       -- delete all the rows related to prtt_enrt_rslt for the voided life events
       if t_rslt.count > 0 then
         --
         forall i in 1..t_rslt.last
           --
           delete from ben_prtt_rt_val
           where prtt_enrt_rslt_id = t_rslt(i);
         g_prtt_rt_rows := g_prtt_rt_rows + sql%rowcount;
         --
         forall i in 1..t_rslt.last
           --
           delete from ben_prtt_enrt_actn_f
           where prtt_enrt_rslt_id = t_rslt(i);
         g_prtt_enrt_actn_rows := g_prtt_enrt_actn_rows + sql%rowcount;
           --
         forall i in 1..t_rslt.last
           --
           delete from ben_prtt_prem_f
           where prtt_enrt_rslt_id = t_rslt(i);
         g_prtt_prem_rows := g_prtt_prem_rows + sql%rowcount;
         --
         forall i in 1..t_rslt.last
           --
           delete from ben_prtt_enrt_ctfn_prvdd_f
           where prtt_enrt_rslt_id = t_rslt(i);
         g_ctfn_prvdd_rows := g_ctfn_prvdd_rows + sql%rowcount;

         forall i in 1..t_rslt.last
           --
           delete from ben_elig_cvrd_dpnt_f
           where prtt_enrt_rslt_id = t_rslt(i);
         g_elig_cvrd_dpnt_rows := g_elig_cvrd_dpnt_rows + sql%rowcount;
         --
         forall i in 1..t_rslt.last
           --
           delete from ben_prtt_enrt_rslt_f
           where prtt_enrt_rslt_id = t_rslt(i);
         g_prtt_enrt_rslt_rows := g_prtt_enrt_rslt_rows + sql%rowcount;
         --
         forall i in 1..t_rslt.last
           --
           delete from ben_pl_bnf_f
           where prtt_enrt_rslt_id = t_rslt(i);
         g_pl_bnf_rows := g_pl_bnf_rows + sql%rowcount;
         --
         forall i in 1..t_rslt.last
           --
           delete from ben_prmry_care_prvdr_f
           where prtt_enrt_rslt_id = t_rslt(i);
         g_prmry_care_rows := g_prmry_care_rows + sql%rowcount;
         --
       end if;
     end loop;
     --
     forall i in 1..t_per_in_ler2.last
      delete from ben_le_clsn_n_rstr
        where per_in_ler_id = t_per_in_ler2(i);
     g_le_clsn_rows := g_le_clsn_rows + sql%rowcount;
     --
     if p_delete_life_evt = 'Y' then
       forall i in 1..t_per_in_ler2.last
         delete from ben_ptnl_ler_for_per
          where ptnl_ler_for_per_id = (select ptnl_ler_for_per_id
                                       from ben_per_in_ler pil
                                       where per_in_ler_id = t_per_in_ler2(i))
          and ptnl_ler_for_per_stat_cd = 'VOIDD';
       --
       forall i in 1..t_per_in_ler2.last
         delete from ben_per_in_ler
           where per_in_ler_id = t_per_in_ler2(i);
     end if;
     --
  end if;
  --
  commit;
  --
  hr_utility.set_location('Leaving purge_single_person',100);
end ;

end ben_purge_bckdt_voided;

/
