--------------------------------------------------------
--  DDL for Package Body BEN_PRO_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRO_LER" as
/* $Header: beprotrg.pkb 120.3 2007/03/01 13:28:13 nhunur noship $*/

--
cursor get_session_date IS
select effective_date
from   fnd_sessions
where  session_id = userenv('SESSIONID');
--
cursor get_system_date IS
select trunc(sysdate)
from   dual;
--
cursor le_exists(p_person_id in number
                ,p_ler_id in number
                ,p_lf_evt_ocrd_dt in date) is
select 'Y'
from ben_ptnl_ler_for_per
where person_id = p_person_id
and   ler_id = p_ler_id
and   ptnl_ler_for_per_stat_cd = 'DTCTD'
and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
--
cursor c_get_person(p_assignment_id in number
                   ,p_effective_date in date)
is
    select a.person_id
    from   per_all_people_f a,
           per_all_assignments_f asg
    where  a.person_id = asg.person_id
    and    asg.assignment_id = p_assignment_id
    and    asg.business_group_id = a.business_group_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date
    and    p_effective_date
           between asg.effective_start_date
           and     asg.effective_end_date;
--

procedure ler_chk(p_old IN g_pro_ler_rec
                 ,p_new IN g_pro_ler_rec
                 ,p_effective_date in date  ) is
--
l_session_date DATE;
l_system_date DATE;

--
-- Bug 5203589
cursor c_old_ppp
is
  select *
    from per_pay_proposals
   where pay_proposal_id = p_old.pay_proposal_id;
--
l_old_ppp_rec c_old_ppp%rowtype;
--
cursor get_ler(l_status varchar2) is
 select ler.ler_id
 ,      ler.typ_cd
 ,      ler.ocrd_dt_det_cd
 from   ben_ler_f ler
 where  ler.business_group_id               = p_new.business_group_id
 and    l_session_date
        between ler.effective_start_date
        and     ler.effective_end_date
 and    ((exists
        (select 1
          from   ben_per_info_chg_cs_ler_f psl
          ,      ben_ler_per_info_cs_ler_f lpl
          where  source_table               = 'PER_PAY_PROPOSALS'
          and    psl.per_info_chg_cs_ler_id = lpl.per_info_chg_cs_ler_id
          and    lpl.business_group_id    = psl.business_group_id
          and    lpl.business_group_id    = ler.business_group_id
          and    l_session_date between psl.effective_start_date
          and    psl.effective_end_date
          and    l_session_date between lpl.effective_start_date
          and    lpl.effective_end_date
          and    lpl.ler_id                 = ler.ler_id)
	)
 OR      (exists
          (select 1
           from   ben_rltd_per_chg_cs_ler_f rpc
           ,      ben_ler_rltd_per_cs_ler_f lrp
           where  source_table               = 'PER_PAY_PROPOSALS'
           and    lrp.business_group_id    = rpc.business_group_id
           and    lrp.business_group_id    = ler.business_group_id
           and    l_session_date between rpc.effective_start_date
           and    rpc.effective_end_date
           and    l_session_date between lrp.effective_start_date
           and    lrp.effective_end_date
           and    rpc.rltd_per_chg_cs_ler_id = lrp.rltd_per_chg_cs_ler_id
           and    lrp.ler_id                 = ler.ler_id)
         ))
  order by ler.ler_id;
--
cursor get_ler_col(p_ler_id IN NUMBER) is
select psl.source_column, psl.new_val, psl.old_val, 'P', psl.per_info_chg_cs_ler_rl, psl.rule_overrides_flag, lpl.chg_mandatory_cd
from ben_ler_per_info_cs_ler_f lpl, ben_per_info_chg_cs_ler_f psl
where lpl.ler_id = p_ler_id and
lpl.business_group_id = p_new.business_group_id
and  lpl.business_group_id  = psl.business_group_id
and l_session_date between psl.effective_start_date
and psl.effective_end_date
and l_session_date between lpl.effective_start_date
and lpl.effective_end_date
and psl.per_info_chg_cs_ler_id = lpl.per_info_chg_cs_ler_id
and source_table = 'PER_PAY_PROPOSALS'
UNION
select rpc.source_column, rpc.new_val, rpc.old_val, 'R', rpc.rltd_per_chg_cs_ler_rl per_info_chg_cs_ler, rpc.rule_overrides_flag, lrp.chg_mandatory_cd
from ben_ler_rltd_per_cs_ler_f lrp, ben_rltd_per_chg_cs_ler_f rpc
where lrp.ler_id = p_ler_id and
lrp.business_group_id = p_new.business_group_id
and  lrp.business_group_id  = rpc.business_group_id
and l_session_date between rpc.effective_start_date
and rpc.effective_end_date
and l_session_date between lrp.effective_start_date
and lrp.effective_end_date
and rpc.rltd_per_chg_cs_ler_id = lrp.rltd_per_chg_cs_ler_id
and source_table = 'PER_PAY_PROPOSALS'
order by 1;
--
cursor get_contacts(p_person_id in number) is
select person_id
from per_contact_relationships
where contact_person_id = p_person_id
and business_group_id = p_new.business_group_id
and l_session_date between nvl(date_start,l_session_date)
and nvl(date_end,l_session_date)
and personal_flag = 'Y'
order by person_id;
--
l_old   g_pro_ler_rec; /* Bug 5203589 */
l_person_id number;
l_changed  BOOLEAN;
l_ler_id NUMBER;
l_typ_cd ben_ler_f.typ_cd%type ;
l_ocrd_dt_cd VARCHAR2(30);
l_column ben_rltd_per_chg_cs_ler_f.source_column%type;  -- VARCHAR2(30);
l_new_val ben_rltd_per_chg_cs_ler_f.new_val%type;   -- VARCHAR2(30);
l_old_val ben_rltd_per_chg_cs_ler_f.old_val%type;       -- VARCHAR2(30);
l_per_info_chg_cs_ler_rl number;
l_ovn NUMBER;
l_ptnl_id NUMBER;
l_effective_end_date DATE := to_date('31-12-4712','DD-MM-YYYY');
l_effective_start_date DATE ;
--l_session_date DATE ;
l_lf_evt_ocrd_date DATE ;
l_le_exists VARCHAR2(1);
l_mnl_dt date;
l_dtctd_dt   date;
l_procd_dt   date;
l_unprocd_dt date;
l_voidd_dt   date;
l_type    VARCHAR2(1);
l_hld_person_id NUMBER;
l_rule_output VARCHAR2(1);
--
l_bool  BOOLEAN;
l_status VARCHAR2(1);
l_industry VARCHAR2(1);
l_col_new_val VARCHAR2(1000);  --UTF8
l_col_old_val varchar2(1000);  --UTF8
--
l_rule_overrides_flag VARCHAR2(1);
l_chg_mandatory_cd VARCHAR2(1);
l_trigger boolean := TRUE;
--
--
begin
 --

 -- Bug 2016857
  benutils.set_data_migrator_mode;
 -- Bug 2016857

 if hr_general.g_data_migrator_mode in ( 'Y','P') then
   --
   return;
   --
 end if;
 --
 -- Bug 5203589
 -- When a new pay proposal is created then PER_PYP_SHD.G_OLD_REC in the calling package peppyrhi.pkb
 -- do not hold correct values. Somehow PER_PYP_SHD.G_OLD_REC.PAY_PROPOSAL_ID holds correct PK value.
 --
 if p_old.PAY_PROPOSAL_ID <> p_new.PAY_PROPOSAL_ID
 then
   --
   open c_old_ppp;
     --
     fetch c_old_ppp into l_old_ppp_rec;
     --
   close c_old_ppp;
   --
   l_old.person_id                      :=     p_old.person_id;
   l_old.BUSINESS_GROUP_ID              :=     l_old_ppp_rec.BUSINESS_GROUP_ID;
   l_old.PAY_PROPOSAL_ID                :=     l_old_ppp_rec.PAY_PROPOSAL_ID;
   l_old.OBJECT_VERSION_NUMBER          :=     l_old_ppp_rec.OBJECT_VERSION_NUMBER;
   l_old.ASSIGNMENT_ID                  :=     l_old_ppp_rec.ASSIGNMENT_ID;
   l_old.EVENT_ID                       :=     l_old_ppp_rec.EVENT_ID;
   l_old.CHANGE_DATE                    :=     l_old_ppp_rec.CHANGE_DATE;
   l_old.LAST_CHANGE_DATE               :=     l_old_ppp_rec.LAST_CHANGE_DATE;
   l_old.NEXT_PERF_REVIEW_DATE          :=     l_old_ppp_rec.NEXT_PERF_REVIEW_DATE;
   l_old.NEXT_SAL_REVIEW_DATE           :=     l_old_ppp_rec.NEXT_SAL_REVIEW_DATE;
   l_old.PERFORMANCE_RATING             :=     l_old_ppp_rec.PERFORMANCE_RATING;
   l_old.PROPOSAL_REASON                :=     l_old_ppp_rec.PROPOSAL_REASON;
   l_old.PROPOSED_SALARY_N              :=     l_old_ppp_rec.PROPOSED_SALARY_N;
   l_old.REVIEW_DATE                    :=     l_old_ppp_rec.REVIEW_DATE;
   l_old.APPROVED                       :=    'N' ; -- l_old_ppp_rec.APPROVED;
   l_old.MULTIPLE_COMPONENTS            :=     l_old_ppp_rec.MULTIPLE_COMPONENTS;
   l_old.FORCED_RANKING                 :=     l_old_ppp_rec.FORCED_RANKING;
   l_old.PERFORMANCE_REVIEW_ID          :=     l_old_ppp_rec.PERFORMANCE_REVIEW_ID;
   l_old.ATTRIBUTE1                     :=     l_old_ppp_rec.ATTRIBUTE1;
   l_old.ATTRIBUTE2                     :=     l_old_ppp_rec.ATTRIBUTE2;
   l_old.ATTRIBUTE3                     :=     l_old_ppp_rec.ATTRIBUTE3;
   l_old.ATTRIBUTE4                     :=     l_old_ppp_rec.ATTRIBUTE4;
   l_old.ATTRIBUTE5                     :=     l_old_ppp_rec.ATTRIBUTE5;
   l_old.ATTRIBUTE6                     :=     l_old_ppp_rec.ATTRIBUTE6;
   l_old.ATTRIBUTE7                     :=     l_old_ppp_rec.ATTRIBUTE7;
   l_old.ATTRIBUTE8                     :=     l_old_ppp_rec.ATTRIBUTE8;
   l_old.ATTRIBUTE9                     :=     l_old_ppp_rec.ATTRIBUTE9;
   l_old.ATTRIBUTE10                    :=     l_old_ppp_rec.ATTRIBUTE10;
   l_old.ATTRIBUTE11                    :=     l_old_ppp_rec.ATTRIBUTE11;
   l_old.ATTRIBUTE12                    :=     l_old_ppp_rec.ATTRIBUTE12;
   l_old.ATTRIBUTE13                    :=     l_old_ppp_rec.ATTRIBUTE13;
   l_old.ATTRIBUTE14                    :=     l_old_ppp_rec.ATTRIBUTE14;
   l_old.ATTRIBUTE15                    :=     l_old_ppp_rec.ATTRIBUTE15;
   l_old.ATTRIBUTE16                    :=     l_old_ppp_rec.ATTRIBUTE16;
   l_old.ATTRIBUTE17                    :=     l_old_ppp_rec.ATTRIBUTE17;
   l_old.ATTRIBUTE18                    :=     l_old_ppp_rec.ATTRIBUTE18;
   l_old.ATTRIBUTE19                    :=     l_old_ppp_rec.ATTRIBUTE19;
   l_old.ATTRIBUTE20                    :=     l_old_ppp_rec.ATTRIBUTE20;
   l_old.PROPOSED_SALARY                :=     l_old_ppp_rec.PROPOSED_SALARY;
   --
 else
   --
   -- Case when pay proposal is updated, then PER_PYP_SHD.G_OLD_REC in the calling package peppyrhi.pkb
   -- hold correct old values. Hence it is safe to use values from P_OLD
   --
   l_old := p_old;
   --
 end if;
 --
 -- Bug 5203589
 --
/*
 l_bool :=fnd_installation.get(appl_id => 805
                              ,dep_appl_id =>805
                              ,status => l_status
                              ,industry => l_industry);
 if l_status = 'I' then
 */
  hr_utility.set_location(' Entering: ben_pro_trigger', 10);
  --
  if p_new.person_id is null then
     --
     open c_get_person(p_new.assignment_id, p_new.change_date);
     fetch c_get_person into l_person_id;
     -- p_new.person_id := l_person_id;
     -- p_old.person_id := l_person_id;
     close c_get_person;
     --
  end if;
  --
  l_changed := FALSE;
  if p_effective_date is not null then
     l_session_date := p_effective_Date ;
  Else
     open get_session_date;
     fetch get_session_date into l_session_date;
     close get_session_date;
  End if ;
  open get_system_date;
  fetch get_system_date into l_system_date;
  close get_system_date;
  l_effective_start_date := l_session_date;
  --  l_lf_evt_ocrd_date := l_session_date;
  hr_utility.set_location(' ben_pro_trigger', 20);

/* 8888 delete lines.
  if p_new.date_to is null then
     l_date_to := l_session_date;
  else
     l_date_to := p_new.date_to;
  end if;
   8888
*/

  hr_utility.set_location(' l_system_date:'||to_char(l_system_date), 20);
  hr_utility.set_location(' l_session_date:'||to_char(l_session_date), 20);

  open get_ler(l_status);
  loop
    --
    fetch get_ler into l_ler_id,l_typ_cd, l_ocrd_dt_cd;
    exit when get_ler%notfound;
           l_trigger := TRUE;

    hr_utility.set_location('ler '||l_ler_id, 20);
    hr_utility.set_location('det_cd '||l_ocrd_dt_cd, 20);
    hr_utility.set_location('DR system date '||l_system_date, 20);
    --
    if l_ocrd_dt_cd is null then
      l_lf_evt_ocrd_date := p_new.change_date;
    else
      --
      --   Call the common date procedure.
      --
      ben_determine_date.main
        (p_date_cd         => l_ocrd_dt_cd
        ,p_effective_date  => p_new.change_date
        ,p_lf_evt_ocrd_dt  => p_new.change_date
        ,p_returned_date   => l_lf_evt_ocrd_date
        );
    end if;
    --
    open get_ler_col(l_ler_id);
    loop
      fetch get_ler_col into l_column,l_new_val, l_old_val, l_type, l_per_info_chg_cs_ler_rl, l_rule_overrides_flag, l_chg_mandatory_cd;
      exit when get_ler_col%NOTFOUND;

      l_changed := TRUE;
      if get_ler_col%ROWCOUNT = 1 then
        l_changed := TRUE;
      end if;
      hr_utility.set_location(' ben_pro_trigger', 50);
      --
      -- Call the formula here to evaluate per_info_chg_cs_ler_rl.
      -- If it returns Y, then see the applicability of the data
      -- changes based on new and old values.
      --
      l_rule_output := 'Y';
      --
      if l_per_info_chg_cs_ler_rl is not null then
         --
           if l_column = 'CHANGE_DATE' then
              l_col_old_val := to_char(l_old.change_date, 'YYYY/MM/DD HH24:MI:SS');
              l_col_new_val := to_char(p_new.change_date, 'YYYY/MM/DD HH24:MI:SS');
           end if;
           --
           if l_column = 'LAST_CHANGE_DATE' then
              l_col_old_val := to_char(l_old.last_change_date, 'YYYY/MM/DD HH24:MI:SS');
              l_col_new_val := to_char(p_new.last_change_date, 'YYYY/MM/DD HH24:MI:SS');
           end if;
           --
           if l_column = 'NEXT_PERF_REVIEW_DATE' then
              l_col_old_val := to_char(l_old.next_perf_review_date, 'YYYY/MM/DD HH24:MI:SS');
              l_col_new_val := to_char(p_new.next_perf_review_date, 'YYYY/MM/DD HH24:MI:SS');
           end if;
           --
           if l_column = 'NEXT_SAL_REVIEW_DATE' then
              l_col_old_val := to_char(l_old.next_sal_review_date, 'YYYY/MM/DD HH24:MI:SS');
              l_col_new_val := to_char(p_new.next_sal_review_date, 'YYYY/MM/DD HH24:MI:SS');
           end if;
           --

           if l_column = 'PERFORMANCE_RATING' then
              l_col_old_val := l_old.PERFORMANCE_RATING;
              l_col_new_val := p_new.PERFORMANCE_RATING;
           end if;
           --
           --
           if l_column = 'PROPOSAL_REASON' then
              l_col_old_val := l_old.PROPOSAL_REASON;
              l_col_new_val := p_new.PROPOSAL_REASON;
           end if;
           --
           if l_column = 'PROPOSED_SALARY_N' then
              l_col_old_val := to_char(l_old.PROPOSED_SALARY_N);
              l_col_new_val := to_char(p_new.PROPOSED_SALARY_N);
           end if;
           --
           if l_column = 'REVIEW_DATE' then
              l_col_old_val := to_char(l_old.REVIEW_date, 'YYYY/MM/DD HH24:MI:SS');
              l_col_new_val := to_char(p_new.REVIEW_date, 'YYYY/MM/DD HH24:MI:SS');
           end if;
           --
           --
           if l_column = 'APPROVED' then
              l_col_old_val := l_old.APPROVED;
              l_col_new_val := p_new.APPROVED;
           end if;
           --
           --
           if l_column = 'MULTIPLE_COMPONENTS' then
              l_col_old_val := l_old.MULTIPLE_COMPONENTS;
              l_col_new_val := p_new.MULTIPLE_COMPONENTS;
           end if;
           --
           --
           if l_column = 'FORCED_RANKING' then
              l_col_old_val := to_char(l_old.FORCED_RANKING);
              l_col_new_val := to_char(p_new.FORCED_RANKING);
           end if;
           --
           if l_column = 'PERFORMANCE_REVIEW_ID' then
              l_col_old_val := to_char(l_old.PERFORMANCE_REVIEW_ID);
              l_col_new_val := to_char(p_new.PERFORMANCE_REVIEW_ID);
           end if;
           --
           if l_column = 'EVENT_ID' then
              l_col_old_val := to_char(l_old.EVENT_ID);
              l_col_new_val := to_char(p_new.EVENT_ID);
           end if;
           --
           if l_column = 'PROPOSED_SALARY' then
              l_col_old_val := l_old.PROPOSED_SALARY;
              l_col_new_val := p_new.PROPOSED_SALARY;
           end if;
           --
           if l_column = 'ATTRIBUTE1' then
              l_col_old_val := l_old.ATTRIBUTE1;
              l_col_new_val := p_new.ATTRIBUTE1;
           end if;
           --
           if l_column = 'ATTRIBUTE2' then
              l_col_old_val := l_old.ATTRIBUTE2;
              l_col_new_val := p_new.ATTRIBUTE2;
           end if;
           --
           if l_column = 'ATTRIBUTE3' then
              l_col_old_val := l_old.ATTRIBUTE3;
              l_col_new_val := p_new.ATTRIBUTE3;
           end if;
           --
           if l_column = 'ATTRIBUTE4' then
              l_col_old_val := l_old.ATTRIBUTE4;
              l_col_new_val := p_new.ATTRIBUTE4;
           end if;
           --
           if l_column = 'ATTRIBUTE5' then
              l_col_old_val := l_old.ATTRIBUTE5;
              l_col_new_val := p_new.ATTRIBUTE5;
           end if;
           --
           if l_column = 'ATTRIBUTE6' then
              l_col_old_val := l_old.ATTRIBUTE6;
              l_col_new_val := p_new.ATTRIBUTE6;
           end if;
           --
           if l_column = 'ATTRIBUTE7' then
              l_col_old_val := l_old.ATTRIBUTE7;
              l_col_new_val := p_new.ATTRIBUTE7;
           end if;
           --
           if l_column = 'ATTRIBUTE8' then
              l_col_old_val := l_old.ATTRIBUTE8;
              l_col_new_val := p_new.ATTRIBUTE8;
           end if;
           --
           if l_column = 'ATTRIBUTE9' then
              l_col_old_val := l_old.ATTRIBUTE9;
              l_col_new_val := p_new.ATTRIBUTE9;
           end if;
           --
           if l_column = 'ATTRIBUTE10' then
              l_col_old_val := l_old.ATTRIBUTE10;
              l_col_new_val := p_new.ATTRIBUTE10;
           end if;
           --
           if l_column = 'ATTRIBUTE11' then
              l_col_old_val := l_old.ATTRIBUTE11;
              l_col_new_val := p_new.ATTRIBUTE11;
           end if;
           --
           if l_column = 'ATTRIBUTE12' then
              l_col_old_val := l_old.ATTRIBUTE12;
              l_col_new_val := p_new.ATTRIBUTE12;
           end if;
           --
           if l_column = 'ATTRIBUTE13' then
              l_col_old_val := l_old.ATTRIBUTE13;
              l_col_new_val := p_new.ATTRIBUTE13;
           end if;
           --
           if l_column = 'ATTRIBUTE14' then
              l_col_old_val := l_old.ATTRIBUTE14;
              l_col_new_val := p_new.ATTRIBUTE14;
           end if;
           --
           if l_column = 'ATTRIBUTE15' then
              l_col_old_val := l_old.ATTRIBUTE15;
              l_col_new_val := p_new.ATTRIBUTE15;
           end if;
           --
           if l_column = 'ATTRIBUTE16' then
              l_col_old_val := l_old.ATTRIBUTE16;
              l_col_new_val := p_new.ATTRIBUTE16;
           end if;
           --
           if l_column = 'ATTRIBUTE17' then
              l_col_old_val := l_old.ATTRIBUTE17;
              l_col_new_val := p_new.ATTRIBUTE17;
           end if;
           --
           if l_column = 'ATTRIBUTE18' then
              l_col_old_val := l_old.ATTRIBUTE18;
              l_col_new_val := p_new.ATTRIBUTE18;
           end if;
           --
           if l_column = 'ATTRIBUTE19' then
              l_col_old_val := l_old.ATTRIBUTE19;
              l_col_new_val := p_new.ATTRIBUTE19;
           end if;
           --
           if l_column = 'ATTRIBUTE20' then
              l_col_old_val := l_old.ATTRIBUTE20;
              l_col_new_val := p_new.ATTRIBUTE20;
           end if;
           --
         benutils.exec_rule(
             p_formula_id        => l_per_info_chg_cs_ler_rl,
             p_effective_date    => l_session_date,
             p_lf_evt_ocrd_dt    => null,
             p_business_group_id => nvl(p_new.business_group_id, l_old.business_group_id),
             p_person_id         => nvl(p_new.person_id, nvl(l_old.person_id, l_person_id)),
             p_new_value         => l_col_new_val,
             p_old_value         => l_col_old_val,
             p_column_name       => l_column,
             p_pk_id             => to_char(p_new.pay_proposal_id),
             p_param5            => 'BEN_PRO_IN_CHANGE_DATE',
             p_param5_value      => to_char(p_new.CHANGE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param6            => 'BEN_PRO_IO_CHANGE_DATE',
             p_param6_value      => to_char(l_old.CHANGE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param7            => 'BEN_PRO_IN_LAST_CHANGE_DATE',
             p_param7_value      => to_char(p_new.LAST_CHANGE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param8            => 'BEN_PRO_IO_LAST_CHANGE_DATE',
             p_param8_value      => to_char(l_old.LAST_CHANGE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param9            => 'BEN_PRO_IN_NEXT_PERF_REVIEW_DATE',
             p_param9_value      => to_char(p_new.NEXT_PERF_REVIEW_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param10            => 'BEN_PRO_IO_NEXT_PERF_REVIEW_DATE',
             p_param10_value      => to_char(l_old.NEXT_PERF_REVIEW_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param11            => 'BEN_PRO_IN_NEXT_SAL_REVIEW_DATE',
             p_param11_value      => to_char(p_new.NEXT_SAL_REVIEW_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param12            => 'BEN_PRO_IO_NEXT_SAL_REVIEW_DATE',
             p_param12_value      => to_char(l_old.NEXT_SAL_REVIEW_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param13            => 'BEN_PRO_IN_PERFORMANCE_RATING',
             p_param13_value      => p_new.PERFORMANCE_RATING,
             p_param14            => 'BEN_PRO_IO_PERFORMANCE_RATING',
             p_param14_value      => l_old.PERFORMANCE_RATING,
             p_param15           => 'BEN_PRO_IN_PROPOSAL_REASON',
             p_param15_value     => p_new.PROPOSAL_REASON,
             p_param16           => 'BEN_PRO_IO_PROPOSAL_REASON',
             p_param16_value     => l_old.PROPOSAL_REASON,
             p_param17           => 'BEN_PRO_IN_PROPOSED_SALARY_N',
             p_param17_value     => to_char(p_new.PROPOSED_SALARY_N),
             p_param18           => 'BEN_PRO_IO_PROPOSED_SALARY_N',
             p_param18_value     => to_char(l_old.PROPOSED_SALARY_N),
             p_param20           => 'BEN_PRO_IN_REVIEW_DATE',
             p_param20_value     => to_char(p_new.REVIEW_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param21           => 'BEN_PRO_IO_REVIEW_DATE',
             p_param21_value     => to_char(l_old.REVIEW_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param22           => 'BEN_PRO_IN_APPROVED',
             p_param22_value     => p_new.APPROVED,
             p_param23           => 'BEN_PRO_IO_APPROVED',
             p_param23_value     => l_old.APPROVED,
             p_param24           => 'BEN_PRO_IN_MULTIPLE_COMPONENTS',
             p_param24_value     => p_new.MULTIPLE_COMPONENTS,
             p_param25           => 'BEN_PRO_IO_MULTIPLE_COMPONENTS',
             p_param25_value     => l_old.MULTIPLE_COMPONENTS,
             p_param26           => 'BEN_PRO_IN_FORCED_RANKING',
             p_param26_value     => to_char(p_new.FORCED_RANKING),
             p_param27           => 'BEN_PRO_IO_FORCED_RANKING',
             p_param27_value     => to_char(l_old.FORCED_RANKING),
             p_param28           => 'BEN_PRO_IN_PERFORMANCE_REVIEW_ID',
             p_param28_value     => to_char(p_new.PERFORMANCE_REVIEW_ID),
             p_param29           => 'BEN_PRO_IO_PERFORMANCE_REVIEW_ID',
             p_param29_value     => to_char(l_old.PERFORMANCE_REVIEW_ID),
             p_param30           => 'BEN_PRO_IN_EVENT_ID',
             p_param30_value     => to_char(p_new.EVENT_ID),
             p_param31           => 'BEN_PRO_IO_EVENT_ID',
             p_param31_value     => to_char(l_old.EVENT_ID),
             p_param32           => 'BEN_PRO_IN_PROPOSED_SALARY',
             p_param32_value     => p_new.PROPOSED_SALARY,
             p_param33           => 'BEN_PRO_IO_PROPOSED_SALARY',
             p_param33_value     => l_old.PROPOSED_SALARY,
             p_param34           => 'BEN_PRO_IN_ATTRIBUTE1',
             p_param34_value     => p_new.ATTRIBUTE1,
             p_param35           => 'BEN_PRO_IO_ATTRIBUTE1',
             p_param35_value     => l_old.ATTRIBUTE1,
             p_ret_val           => l_rule_output);
         --
      end if;
      --

          --
          if l_column = 'CHANGE_DATE' then
              l_changed := (benutils.column_changed(l_old.CHANGE_DATE
                         ,p_new.CHANGE_DATE,l_new_val) AND
                          benutils.column_changed(p_new.CHANGE_DATE
                         ,l_old.CHANGE_DATE,l_old_val) AND
                          (l_changed));
            hr_utility.set_location(' l_changed:',40);
           end if;
           --
           if l_column = 'LAST_CHANGE_DATE' then
              l_changed := (benutils.column_changed(l_old.LAST_CHANGE_DATE
                         ,p_new.LAST_CHANGE_DATE,l_new_val) AND
                            benutils.column_changed(p_new.LAST_CHANGE_DATE
                         ,l_old.LAST_CHANGE_DATE,l_old_val) AND
                            (l_changed));
            --
           end if;
           --
           if l_column = 'NEXT_PERF_REVIEW_DATE' then
              l_changed := (benutils.column_changed(l_old.NEXT_PERF_REVIEW_DATE
                         ,p_new.NEXT_PERF_REVIEW_DATE,l_new_val) AND
                            benutils.column_changed(p_new.NEXT_PERF_REVIEW_DATE
                         ,l_old.NEXT_PERF_REVIEW_DATE,l_old_val) AND
                           (l_changed));
           end if;
           --
           if l_column = 'NEXT_SAL_REVIEW_DATE' then
              l_changed := (benutils.column_changed(l_old.NEXT_SAL_REVIEW_DATE
                        ,p_new.NEXT_SAL_REVIEW_DATE,l_new_val) AND
                          benutils.column_changed(p_new.NEXT_SAL_REVIEW_DATE
                        ,l_old.NEXT_SAL_REVIEW_DATE,l_old_val)  );
           end if;
           --
           if l_column = 'PERFORMANCE_RATING' then
              l_changed := (benutils.column_changed(l_old.PERFORMANCE_RATING
                        ,p_new.PERFORMANCE_RATING,l_new_val) AND
                          benutils.column_changed(p_new.PERFORMANCE_RATING
                        ,l_old.PERFORMANCE_RATING,l_old_val)  );
           end if;
           --
           if l_column = 'PROPOSED_SALARY_N' then
              l_changed := (benutils.column_changed(l_old.PROPOSED_SALARY_N
                        ,p_new.PROPOSED_SALARY_N,l_new_val) AND
                          benutils.column_changed(p_new.PROPOSED_SALARY_N
                        ,l_old.PROPOSED_SALARY_N,l_old_val)   );
           end if;
           --
           if l_column = 'PROPOSAL_REASON' then
              l_changed := (benutils.column_changed(l_old.PROPOSAL_REASON
                        ,p_new.PROPOSAL_REASON,l_new_val) AND
                          benutils.column_changed(p_new.PROPOSAL_REASON
                        ,l_old.PROPOSAL_REASON,l_old_val)   );
           end if;
           --
           if l_column = 'REVIEW_DATE' then
              l_changed := (benutils.column_changed(l_old.REVIEW_DATE
                        ,p_new.REVIEW_DATE,l_new_val) AND
                          benutils.column_changed(p_new.REVIEW_DATE
                        ,l_old.REVIEW_DATE,l_old_val)   );
           end if;
           --
           if l_column = 'APPROVED' then
              l_changed := (benutils.column_changed(l_old.APPROVED
                        ,p_new.APPROVED,l_new_val) AND
                          benutils.column_changed(p_new.APPROVED
                        ,l_old.APPROVED,l_old_val)   );
           end if;
           --
           if l_column = 'MULTIPLE_COMPONENTS' then
              l_changed := (benutils.column_changed(l_old.MULTIPLE_COMPONENTS
                        ,p_new.MULTIPLE_COMPONENTS,l_new_val) AND
                          benutils.column_changed(p_new.MULTIPLE_COMPONENTS
                        ,l_old.MULTIPLE_COMPONENTS,l_old_val)   );
           end if;
           --
           if l_column = 'FORCED_RANKING' then
              l_changed := (benutils.column_changed(l_old.FORCED_RANKING
                        ,p_new.FORCED_RANKING,l_new_val) AND
                          benutils.column_changed(p_new.FORCED_RANKING
                        ,l_old.FORCED_RANKING,l_old_val)   );
           end if;
           --
           if l_column = 'PERFORMANCE_REVIEW_ID' then
              l_changed := (benutils.column_changed(l_old.PERFORMANCE_REVIEW_ID
                        ,p_new.PERFORMANCE_REVIEW_ID,l_new_val) AND
                          benutils.column_changed(p_new.PERFORMANCE_REVIEW_ID
                        ,l_old.PERFORMANCE_REVIEW_ID,l_old_val)   );
           end if;
           --
           if l_column = 'EVENT_ID' then
              l_changed := (benutils.column_changed(l_old.EVENT_ID
                        ,p_new.EVENT_ID,l_new_val) AND
                          benutils.column_changed(p_new.EVENT_ID
                        ,l_old.EVENT_ID,l_old_val)   );
           end if;
           --
           if l_column = 'PROPOSED_SALARY' then
              l_changed := (benutils.column_changed(l_old.PROPOSED_SALARY
                        ,p_new.PROPOSED_SALARY,l_new_val) AND
                          benutils.column_changed(p_new.PROPOSED_SALARY
                        ,l_old.PROPOSED_SALARY,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE1' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE1
                        ,p_new.ATTRIBUTE1,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE1
                        ,l_old.ATTRIBUTE1,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE2' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE2
                        ,p_new.ATTRIBUTE2,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE2
                        ,l_old.ATTRIBUTE2,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE3' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE3
                        ,p_new.ATTRIBUTE3,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE3
                        ,l_old.ATTRIBUTE3,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE4' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE4
                        ,p_new.ATTRIBUTE4,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE4
                        ,l_old.ATTRIBUTE4,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE5' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE5
                        ,p_new.ATTRIBUTE5,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE5
                        ,l_old.ATTRIBUTE5,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE6' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE6
                        ,p_new.ATTRIBUTE6,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE6
                        ,l_old.ATTRIBUTE6,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE7' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE7
                        ,p_new.ATTRIBUTE7,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE7
                        ,l_old.ATTRIBUTE7,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE8' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE8
                        ,p_new.ATTRIBUTE8,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE8
                        ,l_old.ATTRIBUTE8,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE9' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE9
                        ,p_new.ATTRIBUTE9,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE9
                        ,l_old.ATTRIBUTE9,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE10' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE10
                        ,p_new.ATTRIBUTE10,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE10
                        ,l_old.ATTRIBUTE10,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE11' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE11
                        ,p_new.ATTRIBUTE11,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE11
                        ,l_old.ATTRIBUTE11,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE12' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE12
                        ,p_new.ATTRIBUTE12,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE12
                        ,l_old.ATTRIBUTE12,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE13' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE13
                        ,p_new.ATTRIBUTE13,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE13
                        ,l_old.ATTRIBUTE13,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE14' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE14
                        ,p_new.ATTRIBUTE14,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE14
                        ,l_old.ATTRIBUTE14,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE15' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE15
                        ,p_new.ATTRIBUTE15,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE15
                        ,l_old.ATTRIBUTE15,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE16' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE16
                        ,p_new.ATTRIBUTE16,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE16
                        ,l_old.ATTRIBUTE16,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE17' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE17
                        ,p_new.ATTRIBUTE17,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE17
                        ,l_old.ATTRIBUTE17,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE18' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE18
                        ,p_new.ATTRIBUTE18,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE18
                        ,l_old.ATTRIBUTE18,l_old_val)   );
           end if;
           --
           if l_column = 'ATTRIBUTE20' then
              l_changed := (benutils.column_changed(l_old.ATTRIBUTE20
                        ,p_new.ATTRIBUTE20,l_new_val) AND
                          benutils.column_changed(p_new.ATTRIBUTE20
                        ,l_old.ATTRIBUTE20,l_old_val)   );
           end if;
           --
	-- Checking the rule output and the rule override flag.
	-- Whether the rule is mandatory or not, rule output should return 'Y'
	-- Rule Mandatory flag is just to override the column data change.

		if l_rule_output = 'Y' and l_rule_overrides_flag = 'Y' then
		   l_changed := TRUE ;
		elsif l_rule_output = 'Y' and l_rule_overrides_flag = 'N' then
		   l_changed := l_changed AND TRUE;
		elsif l_rule_output = 'N' then
			  hr_utility.set_location(' Rule output is N, so we should not trigger LE', 20.01);
		   l_changed := FALSE;
		end if;

		hr_utility.set_location('After the rule Check ',20.05);
		if l_changed then
		   hr_utility.set_location('     l_change TRUE l_rule_overrides_flag '||l_rule_overrides_flag, 20.1);
		else
		   hr_utility.set_location('     l_change FALSE l_rule_overrides_flag '||l_rule_overrides_flag, 20.1);
		end if;
	-- Check for Column Mandatory Change
	-- If column change is mandatory and data change has failed then dont trigger
	-- If column change is non-mandatory and the data change has passed, then trigger.

		if l_chg_mandatory_cd = 'Y' and not l_changed then
			hr_utility.set_location('Found Mandatory and its failed ', 20.1);
			l_changed := FALSE;
			l_trigger := FALSE;
			exit;
		 elsif l_chg_mandatory_cd = 'Y' and l_changed then
			hr_utility.set_location('Found Mandatory and its passed ', 20.1);
			l_changed := TRUE;
		--	exit; */
		elsif l_chg_mandatory_cd = 'N' and l_changed then
		    hr_utility.set_location('Found First Non-Mandatory and its passed ', 20.1);
			l_changed := TRUE;
			l_trigger := TRUE;
			exit;
		end if;


		hr_utility.set_location('After the Mandatory code check ',20.05);
		if l_changed then
			hr_utility.set_location('       l_change TRUE ', 20.1);
		else
			hr_utility.set_location('        l_change FALSE ', 20.1);
		end if;
		--
		/* if not l_changed then
		exit;
		end if;  */

    end loop;
    hr_utility.set_location('  ben_pro_trigger', 50);
    l_ptnl_id := 0;
    l_ovn :=null;
    --
    if l_changed then
       hr_utility.set_location(' l_changed = TRUE' || l_type, 9999);
    else
       hr_utility.set_location(' l_changed = FALSE' || l_type, 9999);
    end if;
    if l_trigger then
      if l_type = 'P' then
        open le_exists(nvl(p_new.person_id, l_person_id),l_ler_id,l_lf_evt_ocrd_date);
        fetch le_exists into l_le_exists;
        if le_exists%notfound then
           hr_utility.set_location(' Entering: ben_pro_trigger5', 60);

           ben_create_ptnl_ler_for_per.create_ptnl_ler_event
           --ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
           (p_validate => false
           ,p_ptnl_ler_for_per_id => l_ptnl_id
           ,p_ntfn_dt => l_system_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_date
           ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
           ,p_ler_id => l_ler_id
           ,p_ler_typ_cd => l_typ_cd
           ,p_person_id => nvl(p_new.person_id, l_person_id)
           ,p_business_group_Id =>p_new.business_group_id
           ,p_object_version_number => l_ovn
           ,p_effective_date => nvl(l_effective_start_date, p_new.change_date)
           ,p_dtctd_dt       => nvl(l_effective_start_date, p_new.change_date));
        end if;
        close le_exists;
      elsif l_type = 'R' then
        hr_utility.set_location(' Entering: ben_pro_trigger5-', 65);
        open get_contacts(nvl(p_new.person_id, l_person_id));
        loop
           fetch get_contacts into l_hld_person_id;
           exit when get_contacts%notfound;
           open le_exists(l_hld_person_id,l_ler_id,l_lf_evt_ocrd_date);
           fetch le_exists into l_le_exists;
           if le_exists%notfound then
              hr_utility.set_location(' Entering: ben_pro_trigger5', 60);

              ben_create_ptnl_ler_for_per.create_ptnl_ler_event
              --ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
              (p_validate => false
              ,p_ptnl_ler_for_per_id => l_ptnl_id
              ,p_ntfn_dt => l_system_date
              ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_date
              ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
              ,p_ler_id => l_ler_id
              ,p_ler_typ_cd => l_typ_cd
              ,p_person_id => l_hld_person_id
              ,p_business_group_Id =>p_new.business_group_id
              ,p_object_version_number => l_ovn
              ,p_effective_date => nvl(l_effective_start_date, p_new.change_date)
              ,p_dtctd_dt       => nvl(l_effective_start_date, p_new.change_date));
           end if;
           l_ptnl_id := 0;
           l_ovn :=null;
           close le_exists;
        end loop;
        close get_contacts;
      end if;
      --
      -- reset the variables.
      --
      hr_utility.set_location(' ben_pro_trigger', 40);
      l_changed   := FALSE;
      l_trigger   := TRUE;
      l_ovn       := NULL;
      l_effective_start_date := nvl(l_session_date, p_new.change_date);
      -- l_lf_evt_ocrd_date := l_session_date;
    end if;
    close get_ler_col;
  end loop;
  hr_utility.set_location('  ben_pro_trigger', 50);
  close get_ler;
  hr_utility.set_location('  leaving ben_pro_trigger', 60);
 --end if;

 -- If a Pay Proposal has been approved then check for Quartile in Grade life event
 if hr_general.g_data_migrator_mode not in ( 'Y','P') then
   if nvl(l_old.approved,'N') = 'N' and p_new.approved = 'Y' then
     ben_pro_ler.qua_in_gr_ler_chk(null,null,l_old,p_new,p_effective_date,'P');
   end if;
 end if;
end;

procedure qua_in_gr_ler_chk (p_old_asg IN ben_asg_ler.g_asg_ler_rec
                            ,p_new_asg IN ben_asg_ler.g_asg_ler_rec
                            ,p_old_pro IN g_pro_ler_rec
                            ,p_new_pro IN g_pro_ler_rec
                            ,p_effective_date IN date default null
                            ,p_called_from IN varchar2) is

l_session_date date;
l_system_date date;
l_changed BOOLEAN;
l_ler_id NUMBER;
l_ocrd_dt_cd VARCHAR2(30);
l_ovn NUMBER;
l_ptnl_id NUMBER;
l_effective_end_date DATE := to_date('31-12-4712','DD-MM-YYYY');
l_lf_evt_ocrd_date DATE ;
l_le_exists VARCHAR2(1);
l_dtctd_dt   date;
l_procd_dt   date;
l_unprocd_dt date;
l_type    VARCHAR2(1);
--
l_bool  BOOLEAN;
l_status VARCHAR2(1);
l_industry VARCHAR2(1);
l_date_from date;
l_date_to date;
l_old_qua_in_gr varchar2(30);
l_new_qua_in_gr varchar2(30);
l_person_id number;
l_new_start_date date;
--
l_old_max_val number;
l_old_min_val number;
l_new_max_val number;
l_new_min_val number;
l_assignment_id per_all_assignments_f.assignment_id%type;
l_business_group_id per_all_assignments_f.business_group_id%type;
l_old_grade_id number;
l_new_grade_id number;
l_old_pay_basis_id per_all_assignments_f.pay_basis_id%type;
l_new_pay_basis_id per_all_assignments_f.pay_basis_id%type;
l_quar_in_grade_cd varchar2(30);
l_old_person_sal number;
l_new_person_sal number;
l_change_date date;
--
cursor get_ler_qig (p_business_group_id number) is
select ler.ler_id
      ,ler.ocrd_dt_det_cd
from   ben_ler_f ler
where  ler.business_group_id = p_business_group_id
and    typ_cd = 'QUAINGR'
and    l_session_date between ler.effective_start_date and
       ler.effective_end_date
order by ler.ler_id;
--
cursor c_min_max(p_grade_id        number
       ,p_business_group_id number
       ,p_lf_evt_ocrd_dt    date
       ,p_pay_basis_id      number) is
select (maximum * grade_annualization_factor) maximum ,
       (minimum * grade_annualization_factor) minimum
from   pay_grade_rules_f pgr,
       per_pay_bases ppb
where  ppb.pay_basis_id = p_pay_basis_id
and    ppb.business_group_id = p_business_group_id
and    pgr.rate_id = ppb.rate_id
and    pgr.business_group_id = p_business_group_id
and    pgr.grade_or_spinal_point_id  = p_grade_id
and    p_lf_evt_ocrd_dt between nvl(pgr.effective_start_date, p_lf_evt_ocrd_dt)
and    nvl(pgr.effective_end_date, p_lf_evt_ocrd_dt);
--
cursor c_annual_sal(p_assignment_id     number
       ,p_business_group_id number
       ,p_lf_evt_ocrd_dt    date
       ,p_pay_basis_id      number
       ,p_old_new varchar2) is
select ppp.proposed_salary_n * ppb.pay_annualization_factor annual_salary,ppp.change_date
from   per_pay_bases      ppb,
       per_pay_proposals ppp
where  ppb.pay_basis_id = p_pay_basis_id
and    ppb.business_group_id = p_business_group_id
and    ppp.assignment_id = p_assignment_id
and    ppp.approved = 'Y'
and    ppp.change_date <= p_lf_evt_ocrd_dt
and    (p_called_from = 'A' or (p_called_from = 'P' and p_old_new = 'new') )
union
select ppp.proposed_salary_n * ppb.pay_annualization_factor annual_salary,ppp.change_date
from   per_pay_bases      ppb,
       per_pay_proposals ppp
where  ppb.pay_basis_id = p_pay_basis_id
and    ppb.business_group_id = p_business_group_id
and    ppp.assignment_id = p_assignment_id
and    ppp.approved = 'Y'
and    ppp.pay_proposal_id <> p_new_pro.pay_proposal_id
and    ppp.change_date <= p_lf_evt_ocrd_dt
and    p_called_from = 'P' and p_old_new = 'old'
order by 2 desc ;
--
cursor c_asg(p_person_id number,p_business_group_id number,p_assignment_id number) is
select grade_id,pay_basis_id
from   per_all_assignments_f
where  assignment_id = p_assignment_id
and    person_id     = p_person_id
and    business_group_id = p_business_group_id
and    l_session_date between effective_start_date and effective_end_date;
--

procedure get_quartile(p_min  IN number default 0
                      ,p_max  IN number default 0
                      ,p_salary IN number default 0
                      ,p_code OUT NOCOPY  varchar2
                      )
is
l_min number;
l_max number;
l_count number;
l_divisor         number := 4;
l_addition_factor     number;
l_multiplication_factor number;
BEGIN
  hr_utility.set_location('Entering get_quartile',10);
  if p_salary > nvl(p_max,0) then
    --
    p_code := 'ABV' ;
    --
  elsif p_salary < nvl(p_min,0) then
    --
    p_code := 'BLW' ;
    --
  else
    --
    l_min := p_min;
    l_addition_factor := (p_max - p_min)/l_divisor;
    --
    for l_count in 1..4 loop
      l_max := l_min + (l_addition_factor );
      if l_count <> 1 then
        l_min := l_min + 1;
      end if;
      if p_salary between l_min and l_max then
         p_code := l_divisor - l_count + 1;
         --commit;
--exit;
      end if;
      l_min := l_max;
      p_code := 'NA';
    end loop;
    --
  end if;
  hr_utility.set_location('Leaving get_quartile',15);
END;
--

begin
 hr_utility.set_location('Entering: qua_in_gr_ler_chk ', 510);
 hr_utility.set_location('Profile val '||fnd_profile.value('BEN_QUA_IN_GR_LER'), 510);

 -- Check if the profile option for Life Event triggering is enabled
 --
 -- Changed to treat null as 'N' and not as 'Y'
 if nvl(fnd_profile.value('BEN_QUA_IN_GR_LER'),'N') = 'Y' then

  l_bool :=fnd_installation.get(appl_id => 805
                               ,dep_appl_id =>805
                               ,status => l_status
                               ,industry => l_industry);
  if l_status = 'I' then
    --
    l_changed := FALSE;
    --
    open get_session_date;
    fetch get_session_date into l_session_date;
    close get_session_date;
    --
    open get_system_date;
    fetch get_system_date into l_system_date;
    close get_system_date;
    --
    -- For Assignment use Session date, for PayProposal use Change Date
    --
    if p_called_from = 'A' then
      l_business_group_id := p_new_asg.business_group_id;
      l_new_start_date    := l_session_date;
    else
      l_business_group_id := p_new_pro.business_group_id;
      l_new_start_date    := p_new_pro.change_date;
    end if;
    --
    hr_utility.set_location('l_session_date:'||to_char(l_session_date), 30);
    hr_utility.set_location('l_business_group_id '||l_business_group_id, 199);
    hr_utility.set_location('l_new_start_date: '||to_char(l_new_start_date),30);

    open get_ler_qig(l_business_group_id);
    fetch get_ler_qig into l_ler_id, l_ocrd_dt_cd;

    if get_ler_qig%found then
    --
    hr_utility.set_location(' Found get_ler_qig ', 199);

      if l_ocrd_dt_cd is null then
        --
        l_lf_evt_ocrd_date := l_new_start_date;
        --
      else
        --
        --   Call the common date procedure.
        --
        ben_determine_date.main
          (p_date_cd         => l_ocrd_dt_cd
          ,p_effective_date  => nvl(l_new_start_date,l_session_date)
          ,p_lf_evt_ocrd_dt  => nvl(l_new_start_date,l_session_date)
          ,p_returned_date   => l_lf_evt_ocrd_date
         );
      end if;
      hr_utility.set_location('LER ID is '||l_ler_id,30);
      hr_utility.set_location('Life Event Occured date is '||l_lf_evt_ocrd_date,30);
      --
      if p_called_from = 'A' then
        l_person_id         := p_new_asg.person_id;
        l_assignment_id     := p_new_asg.assignment_id;
        l_new_grade_id      := p_new_asg.grade_id;
        l_new_pay_basis_id  := p_new_asg.pay_basis_id;
        l_old_grade_id      := p_old_asg.grade_id;
        l_old_pay_basis_id  := p_old_asg.pay_basis_id;

        --
      elsif p_called_from = 'P' then

        if p_new_pro.person_id is null then
          open c_get_person(p_new_pro.assignment_id,p_effective_date);
          fetch c_get_person into l_person_id;
          close c_get_person;
        end if;
        l_person_id         := nvl(p_new_pro.person_id,l_person_id);
        l_business_group_id := p_new_pro.business_group_id;
        l_assignment_id     := p_new_pro.assignment_id;

        open  c_asg(l_person_id,l_business_group_id,l_assignment_id);
        fetch c_asg into l_old_grade_id,l_old_pay_basis_id;
        close c_asg;

        l_new_grade_id     := l_old_grade_id;
        l_new_pay_basis_id := l_old_pay_basis_id;
        --
      end if;
      --
      hr_utility.set_location('l_old_pay_basis_id is '||l_old_pay_basis_id, 199);
      hr_utility.set_location('l_new_pay_basis_id is '||l_new_pay_basis_id, 199);
      hr_utility.set_location('l_old_grade_id is '||l_old_grade_id, 199);
      hr_utility.set_location('l_new_grade_id is '||l_new_grade_id, 199);
      --
      -- For update, get the old proposed salary from the previous approved record.
      -- If the proposed salary is changed,get it from the pay proposal record being passed.
      --

      open c_annual_sal(l_assignment_id
             ,l_business_group_id
             ,nvl(l_lf_evt_ocrd_date,l_new_start_date)
             ,l_old_pay_basis_id
             ,'old') ;
      fetch c_annual_sal into l_old_person_sal,l_change_date;
      close c_annual_sal;

      open c_annual_sal(l_assignment_id
             ,l_business_group_id
             ,nvl(l_lf_evt_ocrd_date,l_new_start_date)
             ,l_new_pay_basis_id
             ,'new') ;
      fetch c_annual_sal into l_new_person_sal,l_change_date;
      close c_annual_sal;
      hr_utility.set_location('p_new_pro.pay_proposal_id is '||p_new_pro.pay_proposal_id, 199);
      hr_utility.set_location('l_old_person_sal is '||l_old_person_sal, 199);
      hr_utility.set_location('l_new_person_sal is '||l_new_person_sal, 199);

      open c_min_max(l_old_grade_id
             ,l_business_group_id
             ,nvl(l_lf_evt_ocrd_date, p_effective_date)
             ,l_old_pay_basis_id);
      fetch c_min_max into l_old_max_val, l_old_min_val;
      close c_min_max;
      --
      open c_min_max(l_new_grade_id
             ,l_business_group_id
             ,nvl(l_lf_evt_ocrd_date, p_effective_date)
             ,l_new_pay_basis_id);
      fetch c_min_max into l_new_max_val, l_new_min_val;
      close c_min_max;
      --
      hr_utility.set_location('l_old_max_val is '||l_old_max_val, 199);
      hr_utility.set_location('l_old_min_val is '||l_old_min_val, 199);
      hr_utility.set_location('l_new_max_val is '||l_new_max_val, 199);
      hr_utility.set_location('l_new_min_val is '||l_new_min_val, 199);
      --
      -- Get the Quartile in grade in which the person's salary fall
      -- within the given min - max range
      --
      if l_old_person_sal is null or l_old_grade_id is null
         or (l_old_min_val is null and l_old_max_val is null) then
        l_old_qua_in_gr := 'NA';
      else
        /*
	-- commented for bug: 4558945
	get_quartile(p_min       => nvl(l_old_min_val,0)
                    ,p_max       => nvl(l_old_max_val,0)
                    ,p_salary    => l_old_person_sal
                    ,p_code      => l_old_qua_in_gr);
        */
	-- added for bug: 4558945
 	 l_old_qua_in_gr :=
         ben_cwb_person_info_pkg.get_grd_quartile (p_salary      => l_old_person_sal,
                                                   p_min         =>  nvl(l_old_min_val,0),
                                                   p_max         => nvl(l_old_max_val,0),
                                                   p_mid         => ( nvl(l_old_min_val,0)+ nvl(l_old_max_val,0))/ 2
						   );

      end if;
      if p_called_from = 'P' and l_old_grade_id is null
        or (l_new_min_val is null and l_new_max_val is null) then
        l_new_qua_in_gr := 'NA';
      else
        /*
	-- commented for bug: 4558945
	get_quartile(p_min       => nvl(l_new_min_val,0)
                    ,p_max       => nvl(l_new_max_val,0)
                    ,p_salary    => l_new_person_sal
                    ,p_code      => l_new_qua_in_gr);
	*/
	-- added for bug: 4558945
 	 l_new_qua_in_gr :=
         ben_cwb_person_info_pkg.get_grd_quartile (p_salary      => l_new_person_sal,
                                                   p_min         =>  nvl(l_new_min_val,0),
                                                   p_max         => nvl(l_new_max_val,0),
                                                   p_mid         => ( nvl(l_new_min_val,0)+ nvl(l_new_max_val,0))/ 2
						   );
      end if;
      --
      hr_utility.set_location('Old Quartile in Grade value is '||l_old_qua_in_gr,100);
      hr_utility.set_location('New Quartile in Grade value is '||l_new_qua_in_gr,110);
      --
      if l_old_qua_in_gr <> l_new_qua_in_gr then
        l_changed := TRUE;
      end if;
      --
      if l_changed then
        hr_utility.set_location('Change detected', 30);
      end if;
      --
      l_ptnl_id := 0;
      l_ovn :=null;
      --
      if l_changed then
          open le_exists(l_person_id,l_ler_id,l_lf_evt_ocrd_date);
          fetch le_exists into l_le_exists;
          if le_exists%notfound then
             hr_utility.set_location(' Calling create_ptnl_ler_for_per ', 60);
             ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
             (p_validate => false
             ,p_ptnl_ler_for_per_id => l_ptnl_id
             ,p_ntfn_dt => l_system_date
             ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_date
             ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
             ,p_ler_id => l_ler_id
             ,p_person_id => l_person_id
             ,p_business_group_Id =>l_business_group_id
             ,p_object_version_number => l_ovn
             ,p_effective_date => l_new_start_date
             ,p_dtctd_dt       => l_new_start_date);
          end if;
          close le_exists;
        --
        -- reset the variables.
        --
        l_changed   := FALSE;
--        l_trigger   := FALSE;
      l_ovn       := NULL;
      end if;
    end if;
    close get_ler_qig;
  end if;
 end if;
 hr_utility.set_location('Leaving: qua_in_gr_ler_chk', 130);
end qua_in_gr_ler_chk;

end ben_pro_ler;

/
