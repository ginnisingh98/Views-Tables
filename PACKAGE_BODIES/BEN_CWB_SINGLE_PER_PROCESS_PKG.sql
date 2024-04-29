--------------------------------------------------------
--  DDL for Package Body BEN_CWB_SINGLE_PER_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_SINGLE_PER_PROCESS_PKG" as
/* $Header: bencwbsp.pkb 120.6 2007/08/21 12:16:17 steotia noship $ */
--
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
--
g_package varchar2(33):='  ben_cwb_single_per_process_pkg.';
g_debug boolean := hr_utility.debug_enabled;
--
-- --------------------------------------------------------------------------
-- |----------------------< process >---------------------|
-- --------------------------------------------------------------------------
--
procedure process
               (errbuf OUT NOCOPY VARCHAR2
               ,retcode OUT NOCOPY NUMBER
	       ,p_validate in varchar2 default 'Y'
	       ,p_search_date in varchar2
	       ,p_person_id in number
	       ,p_business_group in number
               ,p_group_pl_id in varchar2
	       ,p_lf_evt_dt_range in varchar2
               ,p_lf_evt_dt in varchar2
	       ,p_run_from_ss in varchar2 default 'N'
	       ,p_clone_all_data_flag in varchar2 default 'N'
	       ,p_backout_and_process_flag in varchar2 default 'N') is

 l_person_type varchar2(240);
 l_method varchar2(240);
 l_method_display varchar2(240);
 l_special_flag varchar2(240);
 l_start_date varchar2(240);
 l_term_date varchar2(240);
 l_no_payroll_warn varchar2(240);
 l_no_salary_warn varchar2(240);
 l_no_supervisor_warn varchar2(240);
 l_no_position_warn varchar2(240);
 l_no_paybasis_warn varchar2(240);
 l_past_term_warn varchar2(240);
 l_future_term_warn varchar2(240);
 l_curr_absence_warn varchar2(240);
 l_future_absence_warn varchar2(240);
 l_data_freeze_date date;
 l_search_date date;
 l_lf_evt_dt_range date;
 l_lf_evt_dt date;
 l_group_pl_id number;
 l_commit number;
 l_clone_all_data_flag varchar2(30);
 l_backout_and_process_flag varchar2(30);

 l_group_per_in_ler_id number;
 l_group_pl_name varchar2(240);
 l_plan_name varchar2(240);
 l_prsrv_bdgt_cd varchar2(30);
 l_period varchar2(80);
 l_elig_status varchar2(80);
 l_event_status varchar2(80);
 l_pp_stat_cd varchar2(80);
 l_pl_id number;

 l_benefit_action_id number;
 l_object_version_number number;

 l_err varchar2(240);
 l_appl varchar2(30);
 l_loc varchar2(240);
 l_type  varchar2(30);

 l_index number;

 cursor c_freeze_date
		(v_pl_id in number
		,v_search_date in date) is
	select max(enp.data_freeze_date) data_freeze_date
	from ben_popl_enrt_typ_cycl_f petc
	    ,ben_enrt_perd enp
	    ,ben_yr_perd  yr
	    ,ben_wthn_yr_perd wyr
	where petc.pl_id = v_pl_id
	and   v_search_date between petc.effective_start_date and petc.effective_end_date
	and   petc.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id
	and   yr.yr_perd_id = enp.yr_perd_id
	and   enp.wthn_yr_perd_id = wyr.wthn_yr_perd_id (+);
begin
/*
       ben_batch_utils.write(p_validate);
       ben_batch_utils.write(p_search_date);
       ben_batch_utils.write(p_person_id);
       ben_batch_utils.write(p_business_group);
       ben_batch_utils.write(p_group_pl_id);
       ben_batch_utils.write(p_lf_evt_dt);
       ben_batch_utils.write(p_run_from_ss);
*/
 if(p_run_from_ss='N') then
  l_group_pl_id := substr(p_group_pl_id,1,instr(p_group_pl_id,'^')-1);
 else
  l_group_pl_id := p_group_pl_id;
 end if;

 l_search_date := fnd_date.canonical_to_date(p_search_date);
 l_lf_evt_dt_range := fnd_date.canonical_to_date(p_lf_evt_dt_range);
 l_lf_evt_dt := fnd_date.canonical_to_date(p_lf_evt_dt);

 l_clone_all_data_flag := p_clone_all_data_flag;
 l_backout_and_process_flag := p_backout_and_process_flag;

 dt_fndate.change_ses_date
        (p_ses_date => l_search_date,
         p_commit   => l_commit);
 ben_batch_utils.write ('+===========================================================================+');
 ben_batch_utils.write ('Changing Session Date: '||l_search_date);
 ben_batch_utils.write ('Commit on date       : '||l_commit);
 ben_batch_utils.write ('+===========================================================================+');

    ben_batch_utils.write ('Time: '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
    ben_batch_utils.write ('=====================Benefit Actions=======================');
    ben_batch_utils.write ('||Parameter                  value                         ');
    ben_batch_utils.write ('||p_request_id-             ' || fnd_global.conc_request_id);
    ben_batch_utils.write ('||p_program_application_id- ' || fnd_global.prog_appl_id);
    ben_batch_utils.write ('||p_program_id-             ' || fnd_global.conc_program_id);
    ben_batch_utils.write ('==========================================================');
    ben_benefit_actions_api.create_perf_benefit_actions
                                               (p_benefit_action_id          => l_benefit_action_id
                                              , p_process_date               => sysdate
                                              , p_mode_cd                    => 'W'
                                              , p_derivable_factors_flag     => 'NONE'
                                              , p_validate_flag              => 'N'
                                              , p_debug_messages_flag        => 'N'
                                              , p_business_group_id          =>  p_business_group
                                              , p_no_programs_flag           => 'N'
                                              , p_no_plans_flag              => 'N'
                                              , p_audit_log_flag             => 'N'
                                              , p_pl_id                      => l_group_pl_id
                                              , p_pgm_id                     => -9999
                                              , p_lf_evt_ocrd_dt             => l_lf_evt_dt
                                              , p_person_id                  => p_person_id
                                              --, p_grant_price_val            => p_grant_price_val
                                              , p_object_version_number      => l_object_version_number
                                              , p_effective_date             => l_search_date
                                              , p_request_id                 => fnd_global.conc_request_id
                                              , p_program_application_id     => fnd_global.prog_appl_id
                                              , p_program_id                 => fnd_global.conc_program_id
                                              , p_program_update_date        => SYSDATE
					      , p_bft_attribute30            => 'N'
                                               );
    ben_batch_utils.write ('Benefit Action Id: ' || l_benefit_action_id);
    benutils.g_benefit_action_id := l_benefit_action_id;
    commit;
    savepoint fallback;
 ben_batch_utils.write('Processing...');
 ben_batch_utils.write('Validate: '||p_validate);
 ben_batch_utils.write('Search Date: '||l_search_date);
 ben_batch_utils.write('Person ID: '||p_person_id);
 ben_batch_utils.write('Business group ID: '||p_business_group);
 ben_batch_utils.write('Plan ID: '||l_group_pl_id);
 ben_batch_utils.write('LER Date: '||l_lf_evt_dt);
 ben_batch_utils.write('Run from SS? '||p_run_from_ss);

 if(p_run_from_ss='N') then

 open c_freeze_date(l_group_pl_id,l_search_date);
 fetch c_freeze_date into l_data_freeze_date;
 close c_freeze_date;
 ben_batch_utils.write('Freeze Date: '||l_data_freeze_date);

 ben_batch_utils.write ('+=================detect_method_and_warning=================================+');
 begin
 detect_method_and_warnings
               (p_person_id => p_person_id
               ,p_group_pl_id => l_group_pl_id
               ,p_lf_evt_dt => l_lf_evt_dt
               ,p_data_freeze_date => l_data_freeze_date
               ,p_search_date => l_search_date
               ,p_person_type => l_person_type
               ,p_method => l_method
               ,p_method_display => l_method_display
               ,p_special_flag => l_special_flag
               ,p_start_date => l_start_date
               ,p_term_date => l_term_date
               ,p_no_payroll_warn => l_no_payroll_warn
               ,p_no_salary_warn => l_no_salary_warn
               ,p_no_supervisor_warn => l_no_supervisor_warn
               ,p_no_position_warn => l_no_position_warn
               ,p_no_paybasis_warn => l_no_paybasis_warn
               ,p_past_term_warn => l_past_term_warn
               ,p_future_term_warn => l_future_term_warn
               ,p_curr_absence_warn => l_curr_absence_warn
               ,p_future_absence_warn => l_future_absence_warn);
 exception
  when others then
   ben_batch_utils.write('detect_method_and_warnings failed');
   ben_batch_utils.write(SQLERRM);
 end;
 ben_batch_utils.write ('+==========================Parameters=======================================+');
 ben_batch_utils.write('After detect_method_and_warnings');
 ben_batch_utils.write('Person Type: '||l_person_type);
 ben_batch_utils.write('Processing method:'||l_method);
 ben_batch_utils.write('Method Display: '||l_method_display);
 ben_batch_utils.write('Special Flag: '||l_special_flag);
 ben_batch_utils.write('Start Date: '||l_start_date);
 ben_batch_utils.write('Termination Date: '||l_term_date);
 ben_batch_utils.write ('+==========================Warnings=========================================+');

 if(upper(l_no_payroll_warn)='Y') then
   fnd_message.set_name('BEN','BEN_94050_ADMIN_PP_NO_PAYROLL');
   ben_batch_utils.write(fnd_message.get);
 end if;
 if(upper(l_no_salary_warn)='Y') then
   fnd_message.set_name('BEN','BEN_94051_ADMIN_PP_NO_SALARY');
   ben_batch_utils.write(fnd_message.get);
 end if;
 if(upper(l_no_supervisor_warn)='Y') then
   fnd_message.set_name('BEN','BEN_94052_ADMIN_PP_NO_SUPRVSR');
   ben_batch_utils.write(fnd_message.get);
 end if;
 if(upper(l_no_position_warn)='Y') then
   fnd_message.set_name('BEN','BEN_94053_ADMIN_PP_NO_POSITION');
   ben_batch_utils.write(fnd_message.get);
 end if;
 if(upper(l_no_paybasis_warn)='Y') then
   fnd_message.set_name('BEN','BEN_94054_ADMIN_PP_NO_PAYBASIS');
   ben_batch_utils.write(fnd_message.get);
 end if;

 if(l_method='SPECIAL') then
   fnd_message.set_name('BEN','BEN_94055_ADMIN_PP_SPL_PROCESS');
   ben_batch_utils.write(fnd_message.get);
   fnd_message.set_name('BEN','BEN_94056_ADMIN_PP_SPL_PRC_ABR');
   ben_batch_utils.write(fnd_message.get);
   fnd_message.set_name('BEN','BEN_94057_ADMIN_PP_SPL_PRC_ELG');
   ben_batch_utils.write(fnd_message.get);
   fnd_message.set_name('BEN','BEN_94058_ADMIN_PP_SPL_PRC_MGR');
   ben_batch_utils.write(fnd_message.get);
   l_clone_all_data_flag := 'Y';
 elsif (l_method='REPROCESS') then
   fnd_message.set_name('BEN','BEN_94063_ADMIN_PP_REPROCESS');
   ben_batch_utils.write(fnd_message.get);
 end if;

 if((l_method='REPROCESS') or (l_method='PH_TO_NORMAL')) then
   l_backout_and_process_flag := 'Y';
 end if;

 if(upper(l_past_term_warn)='Y') then
   fnd_message.set_name('BEN','BEN_94059_ADMIN_PP_PAST_TERM');
   ben_batch_utils.write(fnd_message.get);
 end if;
 if(upper(l_future_term_warn)='Y') then
   fnd_message.set_name('BEN','BEN_94060_ADMIN_PP_FUTURE_TERM');
   ben_batch_utils.write(fnd_message.get);
 end if;
 if(upper(l_curr_absence_warn)='Y') then
   fnd_message.set_name('BEN','BEN_94061_ADMIN_PP_CURR_ABSNCE');
   ben_batch_utils.write(fnd_message.get);
 end if;
 if(upper(l_future_absence_warn)='Y') then
   fnd_message.set_name('BEN','BEN_94062_ADMIN_PP_FUTUR_ABSNC');
   ben_batch_utils.write(fnd_message.get);
 end if;

 end if;

 ben_batch_utils.write ('+==============Running participation process================================+');
 begin

 ben_batch_utils.write('p_validate: '||p_validate);
 ben_batch_utils.write('l_search_date: '||l_search_date);
 ben_batch_utils.write('p_person_id: '||p_person_id);
 ben_batch_utils.write('p_business_group: '||p_business_group);
 ben_batch_utils.write('l_group_pl_id: '||l_group_pl_id);
 ben_batch_utils.write('l_lf_evt_dt: '||l_lf_evt_dt);

 ben_batch_utils.write('Clone all data? '||l_clone_all_data_flag);
 ben_batch_utils.write('Backout and reprocess? '||l_backout_and_process_flag);

 run_participation_process
               (p_validate                 => p_validate
               ,p_effective_date           => l_search_date
               ,p_person_id                => p_person_id
               ,p_business_group_id        => p_business_group
               ,p_group_pl_id              => l_group_pl_id
               ,p_lf_evt_ocrd_dt           => l_lf_evt_dt
               ,p_clone_all_data_flag      => l_clone_all_data_flag
               ,p_backout_and_process_flag => l_backout_and_process_flag
               ,p_group_per_in_ler_id      => l_group_per_in_ler_id
               ,p_group_pl_name            => l_group_pl_name
               ,p_plan_name                => l_plan_name
               ,p_prsrv_bdgt_cd            => l_prsrv_bdgt_cd
               ,p_period                   => l_period
               ,p_elig_status              => l_elig_status
               ,p_event_status             => l_event_status
               ,p_pp_stat_cd               => l_pp_stat_cd
               ,p_pl_id                    => l_pl_id);

 exception
  when others then
   ben_batch_utils.write('run_participation_process failed');
   ben_batch_utils.write(SQLERRM);
 end;

 ben_batch_utils.write ('+===========================Results=========================================+');
 ben_batch_utils.write('group_per_in_ler_id: '||l_group_per_in_ler_id);
 ben_batch_utils.write('Group Plan Name: '||l_group_pl_name);
 ben_batch_utils.write('Plan Name: '||l_plan_name);
 ben_batch_utils.write('Preserve Budget Code: '||l_prsrv_bdgt_cd);
 ben_batch_utils.write('Period: '||l_period);
 ben_batch_utils.write('Eligibility Status: '||l_elig_status);
 ben_batch_utils.write('Event Status: '||l_event_status);
 ben_batch_utils.write('Participation Process Status Code: '||l_pp_stat_cd);
 ben_batch_utils.write('Plan ID: '||l_pl_id);
 ben_batch_utils.write ('+===========================================================================+');

 if(l_group_per_in_ler_id=-1) then
  ben_batch_utils.write('Cannot process person');
 end if;

 if(FND_MSG_PUB.COUNT_MSG()>0) then
  raise ben_batch_utils.g_record_error;
 end if;

exception
when others then
 rollback to fallback;
 ben_batch_utils.write('Run Participation Process has failed to enroll person');

 --l_err := FND_MSG_PUB.GET_DETAIL(p_msg_index => FND_MSG_PUB.G_FIRST);
 --l_err := replace(FND_MSG_PUB.GET_DETAIL(p_msg_index => FND_MSG_PUB.G_FIRST),chr(0),' ');
 --l_appl := rtrim(substr(l_err,0,instr(l_err,' ')));
 --l_err := rtrim(substr(ltrim(substr(l_err,instr(l_err,' '))),0,instr(ltrim(substr(l_err,instr(l_err,' '))),' ')));
 --fnd_message.set_name (l_appl, l_err);
 /*
FND_MESSAGE.Set_Encoded(FND_MSG_PUB.GET_DETAIL(p_msg_index => FND_MSG_PUB.G_FIRST));
*/

FOR i IN 1..FND_MSG_PUB.Count_Msg    LOOP
 if(i=1) then
  l_index := FND_MSG_PUB.G_FIRST;
 else
  l_index := FND_MSG_PUB.G_NEXT;
 end if;
 l_err := FND_MSG_PUB.GET_DETAIL(p_msg_index => l_index);
 insert into ben_transaction( transaction_id
                             ,transaction_type
                             ,status
                             ,attribute1
                             ,attribute2
			     --,attribute3
			     )
                      values( BEN_TRANSACTION_S.NEXTVAL
		            ,'EMPENROLL'||l_benefit_action_id
			    ,'E'
			    --,FND_MSG_PUB.GET_DETAIL(p_msg_index => l_index)
			    ,replace(l_err,chr(0),' ')
			    ,p_person_id
			    --l_loc
			    );
END LOOP;
 commit;
FND_MESSAGE.Set_Encoded(l_err);
l_loc := FND_MESSAGE.GET_TOKEN('FND_ERROR_LOCATION_FIELD','Y');
l_type := FND_MESSAGE.GET_TOKEN('FND_MESSAGE_TYPE','Y');
 raise;
end;

--
-- --------------------------------------------------------------------------
-- |-----------------------< recreate_error_stack >-------------------------|
-- --------------------------------------------------------------------------
--
procedure recreate_error_stack(p_request_id in number) is

cursor c_errors(v_request_id in number) is
 select attribute1
 from ben_benefit_actions actn, ben_transaction, fnd_concurrent_requests req
 where req.request_id = v_request_id
 and req.request_id = actn.request_id
 and transaction_type = 'EMPENROLL'||benefit_action_id
 and attribute2 = req.ARGUMENT3;
l_errors varchar2(240);
l_message varchar2(240);
begin
   fnd_msg_pub.initialize;
   open c_errors(p_request_id);
   loop
    fetch c_errors into l_errors;
    EXIT WHEN c_errors%NOTFOUND;

    l_message := replace(l_errors,' ',chr(0));
    fnd_message.set_encoded(l_message);
    FND_MSG_PUB.ADD;

   end loop;
   close c_errors;
end;

--
-- --------------------------------------------------------------------------
-- |----------------------< detect_method_and_warnings >---------------------|
-- --------------------------------------------------------------------------
--
procedure detect_method_and_warnings
               (p_person_id in number
               ,p_group_pl_id in number
               ,p_lf_evt_dt in date
               ,p_data_freeze_date in date
               ,p_search_date in date
               ,p_person_type out nocopy varchar2
               ,p_method out nocopy varchar2
               ,p_method_display out nocopy varchar2
               ,p_special_flag out nocopy varchar2
               ,p_start_date out nocopy varchar2
               ,p_term_date out nocopy varchar2
               ,p_no_payroll_warn out nocopy varchar2
               ,p_no_salary_warn out nocopy varchar2
               ,p_no_supervisor_warn out nocopy varchar2
               ,p_no_position_warn out nocopy varchar2
               ,p_no_paybasis_warn out nocopy varchar2
               ,p_past_term_warn out nocopy varchar2
               ,p_future_term_warn out nocopy varchar2
               ,p_curr_absence_warn out nocopy varchar2
               ,p_future_absence_warn out nocopy varchar2) is

cursor csr_person_type(p_person_id number
                      ,p_effective_date date) is
select ppt.system_person_type
from per_person_type_usages_f ptu
    ,per_person_types ppt
where ptu.person_id = p_person_id
and   p_effective_date between ptu.effective_start_date
            and ptu.effective_end_date
and   ptu.person_type_id = ppt.person_type_id
and   ppt.system_person_type in ('EMP','CWK');

cursor csr_pds_details(p_person_id number
                      ,p_effective_date date) is
select date_start
      ,actual_termination_date
      ,final_process_date
      ,projected_termination_date
from  per_all_assignments_f asg
     ,per_periods_of_service pds
where asg.person_id = p_person_id
and   p_effective_date between
      asg.effective_start_date and asg.effective_end_date
and   asg.period_of_service_id = pds.period_of_service_id;

cursor csr_pdp_details(p_person_id number
                      ,p_effective_date date) is
select date_start
      ,actual_termination_date
      ,final_process_date
      ,projected_termination_date
from per_periods_of_placement
where person_id = p_person_id
and   p_effective_date between date_start
      and nvl(actual_termination_date,to_date('4712/12/31','yyyy/mm/dd'));

cursor csr_pil_details(p_person_id number
                      ,p_group_pl_id number
                      ,p_lf_evt_dt date) is
select pil.per_in_ler_id
      ,pil.per_in_ler_stat_cd
      ,per.post_process_stat_cd
      ,rates.group_per_in_ler_id rates_id
from ben_per_in_ler pil
    ,ben_cwb_person_info per
    ,ben_cwb_person_rates rates
where pil.person_id = p_person_id
and   pil.group_pl_id = p_group_pl_id
and   pil.lf_evt_ocrd_dt = p_lf_evt_dt
and   pil.per_in_ler_stat_cd  <> 'BCKDT'
and   pil.per_in_ler_id = per.group_per_in_ler_id
and   pil.per_in_ler_id = rates.group_per_in_ler_id (+)
and   rates.oipl_id (+) = -1;

cursor csr_other_details(p_person_id number
                        ,p_eff_date date) is
select decode(asg.payroll_id,null,'Y','N') no_payroll
      ,decode(ppp.pay_proposal_id,null,'Y','N') no_salary
      ,decode(asg.supervisor_id, null, 'Y', 'N') no_supervisor
      ,decode(asg.position_id, null, 'Y', 'N') no_position
      ,decode(asg.pay_basis_id, null, 'Y', 'N') no_paybasis
      ,decode(curr_abs.absence_attendance_id,null,'N','Y') curr_abs
      ,decode(future_abs.absence_attendance_id,null,'N','Y') future_abs
from per_all_assignments_f asg
    ,per_pay_proposals ppp
    ,per_absence_attendances curr_abs
    ,per_absence_attendances future_abs
where asg.person_id = p_person_id
and   asg.primary_flag = 'Y'
and   asg.assignment_type in ('E','C')
and   p_eff_date between asg.effective_start_date and asg.effective_end_date
and   asg.assignment_id = ppp.assignment_id (+)
and   ppp.proposed_salary_n (+) > 0
and   ppp.approved (+) = 'Y'
and   asg.person_id = curr_abs.person_id (+)
and   p_eff_date between curr_abs.date_start(+) and curr_abs.date_end (+)
and   asg.person_id = future_abs.person_id (+)
and   p_eff_date < future_abs.date_start (+);



-- Added to check hrchy used in plan design
-- Bug# 4395367

cursor csr_pl_dsgn_hrchy(p_group_pl_id number
                      ,p_lf_evt_dt date) is
select HRCHY_TO_USE_CD
from
   BEN_ENRT_PERD  enrt
 , ben_cwb_pl_dsgn  dsgn
where  dsgn.pl_id = p_group_pl_id
and    enrt.enrt_perd_id = dsgn.enrt_perd_id
and    dsgn.lf_evt_ocrd_dt= p_lf_evt_dt;



-- variable declaration
l_per_in_ler_id number;
l_per_in_ler_stat_cd varchar2(30);
l_post_process_stat_cd varchar2(30);
l_rates_id number;
--
l_date_start date;
l_act_term_date date;
l_final_proc_date date;
l_proj_term_date date;
l_term_date date;
--
l_eff_date date;
--

--
l_hrchy_cd varchar2(5);
--

   l_proc     varchar2(72) := g_package||'detect_method_and_warnings';
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   -- find the person type of the person
   open csr_person_type(p_person_id, p_search_date);
   fetch csr_person_type into p_person_type;
   close csr_person_type;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   --
   -- Detect method
   --
   -- get the pil details
   open csr_pil_details(p_person_id, p_group_pl_id, p_lf_evt_dt);
   fetch csr_pil_details into l_per_in_ler_id
                             ,l_per_in_ler_stat_cd
                             ,l_post_process_stat_cd
                             ,l_rates_id;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 30);
   end if;
   --
   -- check whether the pil is present and has the status 'PROCESSED'
   if (csr_pil_details%found) then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 40);
      end if;
      --
      -- pil is present
      if (l_post_process_stat_cd = 'PR') then
         -- return null, so that caller will raise the error
         p_method := null;

      elsif (l_rates_id is null) then
         -- rates record is not present. so placeholder to normal
         p_method := 'PH_TO_NORMAL';
      else
         -- rates is also present. so reprocess
         p_method := 'REPROCESS';
      end if;
      -- for both PH_TO_NORMAL and REPROCESS, special process is required
      -- if no pds record exists on life event occured date
       open csr_pds_details(p_person_id, p_lf_evt_dt);
       fetch csr_pds_details into l_date_start
                                   ,l_act_term_date
                                   ,l_final_proc_date
                                   ,l_proj_term_date;

       if (csr_pds_details%notfound) then
         p_special_flag := 'Y';
       end if;
       close csr_pds_details;
   else
      --
      if g_debug then
         hr_utility.set_location(l_proc, 50);
      end if;
      --
      -- the person is going to processed for the first time.
      -- check normal processing or special processing
      if (p_person_type = 'EMP') then
         -- check the pds details as on lf_evt_dt
         --
         if g_debug then
            hr_utility.set_location(l_proc, 60);
         end if;
         --
         open csr_pds_details(p_person_id, p_lf_evt_dt);
         fetch csr_pds_details into l_date_start
                                   ,l_act_term_date
                                   ,l_final_proc_date
                                   ,l_proj_term_date;

         if (csr_pds_details%notfound) then
            -- the person does not have valid assignment on lf_evt_dt
            -- special processing
            p_method := 'SPECIAL';
         else
            -- anything else is normal processing
            p_method := 'NORMAL';
         end if;
         --
         close csr_pds_details;
      else -- the person is 'CWK'
         --
         if g_debug then
            hr_utility.set_location(l_proc, 70);
         end if;
         --
         -- check the pds details as on lf_evt_dt
         open csr_pdp_details(p_person_id, p_lf_evt_dt);
         fetch csr_pdp_details into l_date_start
                                   ,l_act_term_date
                                   ,l_final_proc_date
                                   ,l_proj_term_date;

         if (csr_pdp_details%notfound) then
            -- the person does not have valid assignment on lf_evt_dt
            -- special processing
            p_method := 'SPECIAL';
         else
            -- anything else is normal processing
            p_method := 'NORMAL';
         end if;
         --
         close csr_pdp_details;
      end if; -- of peson_type
      --
      --
   end if;
   --
   close csr_pil_details;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 80);
   end if;
   --
   -- Detect the employement period and warnings

   -- find the employement period effective on the search_date
   if p_person_type = 'EMP' then
      open csr_pds_details(p_person_id, p_search_date);
      fetch csr_pds_details into l_date_start
                                ,l_act_term_date
                                ,l_final_proc_date
                                ,l_proj_term_date;

      close csr_pds_details;
      -- set the start_date and term_date
      p_start_date := l_date_start;
      p_term_date := l_final_proc_date;
   else -- the person is 'CWK'
      open csr_pdp_details(p_person_id, p_search_date);
      fetch csr_pdp_details into l_date_start
                                ,l_act_term_date
                                ,l_final_proc_date
                                ,l_proj_term_date;

      close csr_pdp_details;
      -- set the start_date and term_date
      p_start_date := l_date_start;
      p_term_date := l_act_term_date;
      --
   end if;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 90);
   end if;
   --
   -- find the eff_date in this order : data_freeze_date, lf_evt_dt
   l_eff_date := p_data_freeze_date;
   if (l_eff_date is null) then
      l_eff_date := p_lf_evt_dt;
   end if;
   --
   --
   if g_debug then
      hr_utility.set_location(l_proc, 100);
   end if;
   --
   -- set the warnings
   open csr_other_details(p_person_id, l_eff_date);
   fetch csr_other_details into p_no_payroll_warn
                               ,p_no_salary_warn
                               ,p_no_supervisor_warn
                               ,p_no_position_warn
                               ,p_no_paybasis_warn
                               ,p_curr_absence_warn
                               ,p_future_absence_warn;

  	open csr_pl_dsgn_hrchy(p_group_pl_id, p_lf_evt_dt);
        fetch csr_pl_dsgn_hrchy into  l_hrchy_cd;

        if l_hrchy_cd = 'S' then
            p_no_position_warn:= 'N';
         end if;

        if l_hrchy_cd = 'P' then
	    p_no_supervisor_warn:= 'N';
         end if;

        close csr_pl_dsgn_hrchy;

   close csr_other_details;
   --
   --
   if g_debug then
      hr_utility.set_location(l_proc, 110);
   end if;
   --
   l_date_start := null; l_act_term_date := null;
   l_final_proc_date := null; l_proj_term_date := null;
   -- check the future term warn
   if p_person_type = 'EMP' then
      open csr_pds_details(p_person_id, l_eff_date);
      fetch csr_pds_details into l_date_start
                                ,l_act_term_date
                                ,l_final_proc_date
                                ,l_proj_term_date;

      close csr_pds_details;
   else -- the person is 'CWK'
      open csr_pdp_details(p_person_id, l_eff_date);
      fetch csr_pdp_details into l_date_start
                                ,l_act_term_date
                                ,l_final_proc_date
                                ,l_proj_term_date;

      close csr_pdp_details;
   end if;
   --
   --
   if g_debug then
      hr_utility.set_location(l_proc, 120);
   end if;
   --
   l_term_date := l_act_term_date;
   if l_term_date is null then
      l_term_date := l_final_proc_date;
      if l_term_date is null then
         l_term_date := l_proj_term_date;
      end if;
   end if;
   --
   --
   if g_debug then
      hr_utility.set_location(l_proc, 130);
   end if;
   --
   if l_term_date is not null then
      if l_term_date <= l_eff_date then
         p_past_term_warn := 'Y';
      else
         p_future_term_warn := 'Y';
      end if;
   end if;
   --
   --
   if g_debug then
      hr_utility.set_location(l_proc, 140);
   end if;
   --
   -- set the p_method_display with lookup value
   select meaning into p_method_display
   from hr_lookups
   where lookup_type = 'BEN_CWB_ADMIN_PP_TYPE'
   and   lookup_code = p_method;

   -- set the p_term_date with lookup value, if it is null
   if p_term_date is null then
      select meaning into p_term_date
      from hr_lookups
      where lookup_type = 'BEN_CWB_MISC_TEXT'
      and lookup_code = 'ONGOING';
   end if;
   --
   if g_debug then
      hr_utility.set_location(p_method,10);
      hr_utility.set_location(p_start_date,20);
      hr_utility.set_location(p_term_date,30);
      hr_utility.set_location(p_no_payroll_warn,40);
      hr_utility.set_location(p_no_salary_warn,50);
      hr_utility.set_location(p_no_supervisor_warn,60);
      hr_utility.set_location(p_no_position_warn,70);
      hr_utility.set_location(p_no_paybasis_warn,80);
      hr_utility.set_location(p_past_term_warn,90);
      hr_utility.set_location(p_future_term_warn,100);
      hr_utility.set_location(p_curr_absence_warn,110);
      hr_utility.set_location(p_future_absence_warn,120);
      hr_utility.set_location(p_person_type,120);
   end if;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 999);
   end if;
   --
end;
-- --------------------------------------------------------------------------
-- |----------------------< run_participation_process >---------------------|
-- --------------------------------------------------------------------------
--
procedure run_participation_process
               (p_validate                 in     varchar2 default 'N'
               ,p_effective_date           in     date
               ,p_person_id                in     number   default null
               ,p_business_group_id        in     number
               ,p_group_pl_id              in     number   default null
               ,p_lf_evt_ocrd_dt           in     date default null
               ,p_clone_all_data_flag      in     varchar2 default 'N'
               ,p_backout_and_process_flag in     varchar2 default 'N'
               ,p_group_per_in_ler_id      out nocopy number
               ,p_group_pl_name            out nocopy varchar2
               ,p_plan_name                out nocopy varchar2
               ,p_prsrv_bdgt_cd            out nocopy varchar2
               ,p_period                   out nocopy varchar2
               ,p_elig_status              out nocopy varchar2
               ,p_event_status             out nocopy varchar2
               ,p_pp_stat_cd               out nocopy varchar2
               ,p_pl_id                    out nocopy number) is
--
   l_group_per_in_ler_id number;
   l_group_pl_name ben_cwb_pl_dsgn.name%type;
   l_plan_name ben_cwb_pl_dsgn.name%type;
   l_prsrv_bdgt_cd ben_cwb_pl_dsgn.prsrv_bdgt_cd%type;
   l_period varchar2(80);
   l_elig_status varchar2(80);
   l_event_status varchar2(80);
   l_pp_stat_cd varchar2(80);
   l_pl_id number;
--
   l_proc     varchar2(72) := g_package||'run_participation_process';
--
begin
   --
   ben_batch_utils.write('-');
       ben_batch_utils.write(p_validate);
       ben_batch_utils.write(p_effective_date);
       ben_batch_utils.write(p_person_id);
       ben_batch_utils.write(p_business_group_id);
       ben_batch_utils.write(p_group_pl_id);
       ben_batch_utils.write(p_lf_evt_ocrd_dt);
       ben_batch_utils.write(p_clone_all_data_flag);
       ben_batch_utils.write(p_backout_and_process_flag);
   ben_batch_utils.write('-');

   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
      hr_utility.set_location('p_effective_date :'||p_effective_date,20);
      hr_utility.set_location('p_person_id :'||p_person_id,30);
      hr_utility.set_location('p_business_group_id :'||p_business_group_id,40);
      hr_utility.set_location('p_group_pl_id :'||p_group_pl_id, 50);
      hr_utility.set_location('p_lf_evt_ocrd_dt :'||p_lf_evt_ocrd_dt, 60);
      hr_utility.set_location('p_clone_all_data :'||p_clone_all_data_flag,70);
      hr_utility.set_location('p_backout_and_process_flag :'
                               ||p_backout_and_process_flag, 80);
   end if;

   ben_manage_cwb_life_events.global_online_process_w(
        p_validate                  => p_validate
       ,p_effective_date            => p_effective_date
       ,p_person_id                 => p_person_id
       ,p_business_group_id         => p_business_group_id
       ,p_pl_id                     => p_group_pl_id
       ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
       ,p_clone_all_data_flag       => p_clone_all_data_flag
       ,p_backout_and_process_flag  => p_backout_and_process_flag);
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   --
   -- find the group_per_in_ler_id and elig_status of the person
   begin
      select pil.per_in_ler_id
            ,grppln.name group_pl_name
            ,decode(rates.group_per_in_ler_id, null, '-1',pln.name) plan_name
            ,pln.prsrv_bdgt_cd prsrv_bdgt_cd
            ,decode(grppln.wthn_yr_start_dt,null,null,grppln.wthn_yr_start_dt
                     ||' - '||grppln.wthn_yr_end_dt) period
            ,elig_stat.meaning eligible_status
            ,event_stat.meaning event_status
            ,per.post_process_stat_cd pp_stat_cd
            ,pln.pl_id
      into  l_group_per_in_ler_id
           ,l_group_pl_name
           ,l_plan_name
           ,l_prsrv_bdgt_cd
           ,l_period
           ,l_elig_status
           ,l_event_status
           ,l_pp_stat_cd
           ,l_pl_id
      from ben_per_in_ler pil
          ,ben_cwb_pl_dsgn grppln
          ,ben_cwb_pl_dsgn pln
          ,ben_cwb_person_rates rates
          ,ben_cwb_person_info per
          ,hr_lookups elig_stat
          ,hr_lookups event_stat
      where pil.person_id = p_person_id
      and   pil.group_pl_id = p_group_pl_id
      and   pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
      and   pil.per_in_ler_stat_cd ='STRTD'
      and   pil.per_in_ler_id = per.group_per_in_ler_id
      and   event_stat.lookup_type (+) = 'BEN_PER_IN_LER_STAT'
      and   event_stat.lookup_code (+) = pil.per_in_ler_stat_cd
      and   event_stat.enabled_flag (+) = 'Y'
      and   pil.group_pl_id = grppln.pl_id
      and   grppln.oipl_id = -1
      and   pil.lf_evt_ocrd_dt = grppln.lf_evt_ocrd_dt
      and   pil.group_pl_id = pln.group_pl_id
      and   pil.lf_evt_ocrd_dt = pln.lf_evt_ocrd_dt
      and   decode(rates.group_per_in_ler_id, null, 'Y', pln.actual_flag)= 'Y'
      and   pln.oipl_id = -1
      and   pil.per_in_ler_id = rates.group_per_in_ler_id (+)
      and   decode(rates.group_per_in_ler_id,null,pil.group_pl_id,rates.pl_id)
                  = pln.pl_id
      and   rates.oipl_id (+)= -1
      and   elig_stat.lookup_type (+) = 'BEN_CWB_ELIG_CRITERIA'
      and   elig_stat.lookup_code (+) = rates.elig_flag
      and   elig_stat.enabled_flag (+) = 'Y'
      and   rownum = 1;
      --
      --
      if g_debug then
         hr_utility.set_location(l_proc, 30);
      end if;
      --
      -- set the values to out parameters
      p_group_per_in_ler_id := l_group_per_in_ler_id;
      p_group_pl_name := l_group_pl_name;
      p_plan_name := l_plan_name;
      p_prsrv_bdgt_cd := l_prsrv_bdgt_cd;
      p_period := l_period;
      p_elig_status := l_elig_status;
      p_event_status := l_event_status;
      p_pp_stat_cd := l_pp_stat_cd;
      p_pl_id := l_pl_id;
   exception
      when others then
         --
         if g_debug then
            hr_utility.set_location(' Leaving:'|| l_proc, 49);
         end if;
         --
         p_group_per_in_ler_id := -1;
   end;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end;
end BEN_CWB_SINGLE_PER_PROCESS_PKG;


/
