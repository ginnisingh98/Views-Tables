--------------------------------------------------------
--  DDL for Package Body BEN_ASG_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ASG_LER" as
/* $Header: beasgtrg.pkb 120.0 2005/05/28 00:29:52 appldev noship $*/
procedure ler_chk(p_old IN g_asg_ler_rec
                 ,p_new IN g_asg_ler_rec
                 ,p_effective_date in date default null ) is
--
l_session_date DATE;
l_system_date DATE;
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
cursor get_ler(l_status varchar2) is
 select ler.ler_id
 ,      ler.typ_cd
 ,      ler.ocrd_dt_det_cd
 from   ben_ler_f ler
 where  ler.business_group_id               = p_new.business_group_id
   and    l_session_date between ler.effective_start_date
   and    ler.effective_end_date   -- For Bug 3299709
and ( l_status = 'I' or ler.typ_cd in ('COMP','GSP','ABS','CHECKLIST') )
 and    ((exists
        (select 1
          from   ben_per_info_chg_cs_ler_f psl
          ,      ben_ler_per_info_cs_ler_f lpl
          where  source_table               = 'PER_ALL_ASSIGNMENTS_F'
          and    psl.per_info_chg_cs_ler_id = lpl.per_info_chg_cs_ler_id
          and    lpl.business_group_id    = psl.business_group_id
          and    lpl.business_group_id    = ler.business_group_id
          and    l_session_date between psl.effective_start_date
          and    psl.effective_end_date
       	  and    l_session_date between lpl.effective_start_date
          and    lpl.effective_end_date    -- For Bug 3299709
          and    lpl.ler_id                 = ler.ler_id)
 	  )
 OR      (exists
          (select 1
           from   ben_rltd_per_chg_cs_ler_f rpc
           ,      ben_ler_rltd_per_cs_ler_f lrp
           where  source_table               = 'PER_ALL_ASSIGNMENTS_F'
           and    lrp.business_group_id    = rpc.business_group_id
           and    lrp.business_group_id    = ler.business_group_id
           and    l_session_date between rpc.effective_start_date
           and    rpc.effective_end_date
	   and    l_session_date between lrp.effective_start_date
           and    lrp.effective_end_date   -- For Bug 3299709
           and    rpc.rltd_per_chg_cs_ler_id = lrp.rltd_per_chg_cs_ler_id
           and    lrp.ler_id                 = ler.ler_id)
           ))
  order by ler.ler_id;

cursor get_ler_col(p_ler_id IN NUMBER) is
select psl.source_column, psl.new_val, psl.old_val, 'P', psl.per_info_chg_cs_ler_rl, psl.rule_overrides_flag, lpl.chg_mandatory_cd
from ben_ler_per_info_cs_ler_f lpl, ben_per_info_chg_cs_ler_f psl
where lpl.ler_id = p_ler_id and
lpl.business_group_id = p_new.business_group_id
and  lpl.business_group_id  = psl.business_group_id
and l_session_date between psl.effective_start_date
and psl.effective_end_date
and l_session_date between lpl.effective_start_date
and lpl.effective_end_date  -- For Bug 3299709
and psl.per_info_chg_cs_ler_id = lpl.per_info_chg_cs_ler_id
and source_table = 'PER_ALL_ASSIGNMENTS_F'
UNION
select rpc.source_column, rpc.new_val, rpc.old_val, 'R', rpc.rltd_per_chg_cs_ler_rl per_info_chg_cs_ler, rpc.rule_overrides_flag, lrp.chg_mandatory_cd
from ben_ler_rltd_per_cs_ler_f lrp, ben_rltd_per_chg_cs_ler_f rpc
where lrp.ler_id = p_ler_id and
lrp.business_group_id = p_new.business_group_id
and  lrp.business_group_id  = rpc.business_group_id
and l_session_date between rpc.effective_start_date
and rpc.effective_end_date
and l_session_date between lrp.effective_start_date
and lrp.effective_end_date  -- For Bug 3299709
and rpc.rltd_per_chg_cs_ler_id = lrp.rltd_per_chg_cs_ler_id
and source_table = 'PER_ALL_ASSIGNMENTS_F'
order by 1;
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
l_changed BOOLEAN;
l_ler_id NUMBER;
l_typ_cd ben_ler_f.typ_cd%type ;
l_ocrd_dt_cd VARCHAR2(30);
l_column ben_rltd_per_chg_cs_ler_f.source_column%type;  -- VARCHAR2(30);
l_new_val ben_rltd_per_chg_cs_ler_f.new_val%type;   -- VARCHAR2(30);
l_old_val ben_rltd_per_chg_cs_ler_f.old_val%type;       -- VARCHAR2(30);
l_per_info_chg_cs_ler_rl number;
l_rule_output VARCHAR2(1);
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
--
l_bool  BOOLEAN;
l_status VARCHAR2(1);
l_industry VARCHAR2(1);
l_col_new_val VARCHAR2(1000);
l_col_old_val varchar2(1000);
--
l_rule_overrides_flag VARCHAR2(1);
l_chg_mandatory_cd VARCHAR2(1);
l_trigger boolean := TRUE;
--
--
begin
-- Bug 3320133
 benutils.set_data_migrator_mode;
 if hr_general.g_data_migrator_mode in ( 'Y','P') then
   --
   return;
   --
 end if;
 --
-- End of Bug 3320133

 l_bool :=fnd_installation.get(appl_id => 805
                   ,dep_appl_id =>805
                   ,status => l_status
                   ,industry => l_industry);

  hr_utility.set_location(' Entering: ben_asg_trigger', 10);
  l_changed := FALSE;
  --
  if p_effective_date is not null then
    --
    l_session_date := p_effective_date ;
    --
  else
    --
    open get_session_date;
    fetch get_session_date into l_session_date;
    close get_session_date;
    --
  end if;
  --
/*
  open get_session_date;
  fetch get_session_date into l_session_date;
  close get_session_date;
*/
  open get_system_date;
  fetch get_system_date into l_system_date;
  close get_system_date;
  l_effective_start_date := l_session_date;
  --  l_lf_evt_ocrd_date := l_session_date;
  hr_utility.set_location(' ben_asg_trigger', 20);
  open get_ler(l_status);
  loop
    fetch get_ler into l_ler_id,l_typ_cd, l_ocrd_dt_cd;
    exit when get_ler%notfound;
           l_trigger := TRUE;
    --
    if l_ocrd_dt_cd is null then
      l_lf_evt_ocrd_date := p_new.effective_start_date;
    else
      --
      --   Call the common date procedure.
      --
      ben_determine_date.main
        (p_date_cd         => l_ocrd_dt_cd
        ,p_effective_date  => p_new.effective_start_date
        ,p_lf_evt_ocrd_dt  => p_new.effective_start_date
        ,p_returned_date   => l_lf_evt_ocrd_date
        );
    end if;
    --
    open get_ler_col(l_ler_id);
    loop
      fetch get_ler_col into l_column,l_new_val, l_old_val, l_type, l_per_info_chg_cs_ler_rl, l_rule_overrides_flag, l_chg_mandatory_cd;
      exit when get_ler_col%NOTFOUND;
      if get_ler_col%ROWCOUNT =1 then
        l_changed := TRUE;
      end if;
      l_changed := TRUE;
      hr_utility.set_location(' ben_asg_trigger', 50);
      hr_utility.set_location('LER '||l_ler_id, 20);
      hr_utility.set_location('COLUMN '||l_column, 20);
      hr_utility.set_location('NEWVAL '||l_new_val, 20);
      hr_utility.set_location('OLDVAL '||l_old_val, 20);
      hr_utility.set_location('TYPE '||l_type, 20);
      hr_utility.set_location('leod '||l_lf_evt_ocrd_date, 20);
      --
      -- Call the formula here to evaluate per_info_chg_cs_ler_rl.
      -- If it returns Y, then see the applicability of the data
      -- changes based on new and old values.
      --
      l_rule_output := 'Y';
      --
      if l_per_info_chg_cs_ler_rl is not null then
         --
         if l_column = 'PERSON_ID' then
            l_col_old_val := to_char(p_old.PERSON_ID);
            l_col_new_val := to_char(p_new.PERSON_ID);
         end if;
         --
         if l_column = 'ASSIGNMENT_ID' then
            l_col_old_val := to_char(p_old.ASSIGNMENT_ID);
            l_col_new_val := to_char(p_new.ASSIGNMENT_ID);
         end if;
         --
         if l_column = 'BUSINESS_GROUP_ID' then
            l_col_old_val := to_char(p_old.BUSINESS_GROUP_ID);
            l_col_new_val := to_char(p_new.BUSINESS_GROUP_ID);
         end if;
         --
         if l_column = 'POSITION_ID' then
            l_col_old_val := to_char(p_old.POSITION_ID);
            l_col_new_val := to_char(p_new.POSITION_ID);
         end if;
         --
         if l_column = 'PAY_BASIS_ID' then
            l_col_old_val := to_char(p_old.PAY_BASIS_ID);
            l_col_new_val := to_char(p_new.PAY_BASIS_ID);
         end if;
         --
         if l_column = 'CHANGE_REASON' then
            l_col_old_val := p_old.CHANGE_REASON;
            l_col_new_val := p_new.CHANGE_REASON;
         end if;
         --
         if l_column = 'FREQUENCY' then
            l_col_old_val := p_old.FREQUENCY;
            l_col_new_val := p_new.FREQUENCY;
         end if;
         --
         if l_column = 'LABOUR_UNION_MEMBER_FLAG' then
            l_col_old_val := p_old.LABOUR_UNION_MEMBER_FLAG;
            l_col_new_val := p_new.LABOUR_UNION_MEMBER_FLAG;
         end if;
         --
         if l_column = 'PEOPLE_GROUP_ID' then
            l_col_old_val := to_char(p_old.PEOPLE_GROUP_ID);
            l_col_new_val := to_char(p_new.PEOPLE_GROUP_ID);
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE1' then
            l_col_old_val := p_old.ASS_ATTRIBUTE1;
            l_col_new_val := p_new.ASS_ATTRIBUTE1;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE2' then
            l_col_old_val := p_old.ASS_ATTRIBUTE2;
            l_col_new_val := p_new.ASS_ATTRIBUTE2;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE3' then
            l_col_old_val := p_old.ASS_ATTRIBUTE3;
            l_col_new_val := p_new.ASS_ATTRIBUTE3;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE4' then
            l_col_old_val := p_old.ASS_ATTRIBUTE4;
            l_col_new_val := p_new.ASS_ATTRIBUTE4;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE5' then
            l_col_old_val := p_old.ASS_ATTRIBUTE5;
            l_col_new_val := p_new.ASS_ATTRIBUTE5;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE6' then
            l_col_old_val := p_old.ASS_ATTRIBUTE6;
            l_col_new_val := p_new.ASS_ATTRIBUTE6;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE7' then
            l_col_old_val := p_old.ASS_ATTRIBUTE7;
            l_col_new_val := p_new.ASS_ATTRIBUTE7;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE8' then
            l_col_old_val := p_old.ASS_ATTRIBUTE8;
            l_col_new_val := p_new.ASS_ATTRIBUTE8;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE9' then
            l_col_old_val := p_old.ASS_ATTRIBUTE9;
            l_col_new_val := p_new.ASS_ATTRIBUTE9;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE10' then
            l_col_old_val := p_old.ASS_ATTRIBUTE10;
            l_col_new_val := p_new.ASS_ATTRIBUTE10;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE11' then
            l_col_old_val := p_old.ASS_ATTRIBUTE11;
            l_col_new_val := p_new.ASS_ATTRIBUTE11;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE12' then
            l_col_old_val := p_old.ASS_ATTRIBUTE12;
            l_col_new_val := p_new.ASS_ATTRIBUTE12;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE13' then
            l_col_old_val := p_old.ASS_ATTRIBUTE13;
            l_col_new_val := p_new.ASS_ATTRIBUTE13;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE14' then
            l_col_old_val := p_old.ASS_ATTRIBUTE14;
            l_col_new_val := p_new.ASS_ATTRIBUTE14;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE15' then
            l_col_old_val := p_old.ASS_ATTRIBUTE15;
            l_col_new_val := p_new.ASS_ATTRIBUTE15;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE16' then
            l_col_old_val := p_old.ASS_ATTRIBUTE16;
            l_col_new_val := p_new.ASS_ATTRIBUTE16;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE17' then
            l_col_old_val := p_old.ASS_ATTRIBUTE17;
            l_col_new_val := p_new.ASS_ATTRIBUTE17;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE18' then
            l_col_old_val := p_old.ASS_ATTRIBUTE18;
            l_col_new_val := p_new.ASS_ATTRIBUTE18;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE19' then
            l_col_old_val := p_old.ASS_ATTRIBUTE19;
            l_col_new_val := p_new.ASS_ATTRIBUTE19;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE20' then
            l_col_old_val := p_old.ASS_ATTRIBUTE20;
            l_col_new_val := p_new.ASS_ATTRIBUTE20;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE21' then
            l_col_old_val := p_old.ASS_ATTRIBUTE21;
            l_col_new_val := p_new.ASS_ATTRIBUTE21;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE22' then
            l_col_old_val := p_old.ASS_ATTRIBUTE22;
            l_col_new_val := p_new.ASS_ATTRIBUTE22;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE23' then
            l_col_old_val := p_old.ASS_ATTRIBUTE23;
            l_col_new_val := p_new.ASS_ATTRIBUTE23;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE24' then
            l_col_old_val := p_old.ASS_ATTRIBUTE24;
            l_col_new_val := p_new.ASS_ATTRIBUTE24;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE25' then
            l_col_old_val := p_old.ASS_ATTRIBUTE25;
            l_col_new_val := p_new.ASS_ATTRIBUTE25;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE26' then
            l_col_old_val := p_old.ASS_ATTRIBUTE26;
            l_col_new_val := p_new.ASS_ATTRIBUTE26;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE27' then
            l_col_old_val := p_old.ASS_ATTRIBUTE27;
            l_col_new_val := p_new.ASS_ATTRIBUTE27;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE28' then
            l_col_old_val := p_old.ASS_ATTRIBUTE28;
            l_col_new_val := p_new.ASS_ATTRIBUTE28;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE29' then
            l_col_old_val := p_old.ASS_ATTRIBUTE29;
            l_col_new_val := p_new.ASS_ATTRIBUTE29;
         end if;
         --
         if l_column = 'ASS_ATTRIBUTE30' then
            l_col_old_val := p_old.ASS_ATTRIBUTE30;
            l_col_new_val := p_new.ASS_ATTRIBUTE30;
         end if;
         --
         if l_column = 'EFFECTIVE_START_DATE' then
            l_col_old_val := to_char(p_old.EFFECTIVE_START_DATE,  'YYYY/MM/DD HH24:MI:SS');
            l_col_new_val := to_char(p_new.EFFECTIVE_START_DATE,  'YYYY/MM/DD HH24:MI:SS');
         end if;
         --
         if l_column = 'EFFECTIVE_END_DATE' then
            l_col_old_val := to_char(p_old.EFFECTIVE_END_DATE,  'YYYY/MM/DD HH24:MI:SS');
            l_col_new_val := to_char(p_new.EFFECTIVE_END_DATE,  'YYYY/MM/DD HH24:MI:SS');
         end if;
         --
         if l_column = 'ORGANIZATION_ID' then
            l_col_old_val := to_char(p_old.ORGANIZATION_ID);
            l_col_new_val := to_char(p_new.ORGANIZATION_ID);
         end if;
         --
         if l_column = 'GRADE_ID' then
            l_col_old_val := to_char(p_old.GRADE_ID);
            l_col_new_val := to_char(p_new.GRADE_ID);
         end if;
         --
         if l_column = 'JOB_ID' then
            l_col_old_val := to_char(p_old.JOB_ID);
            l_col_new_val := to_char(p_new.JOB_ID);
         end if;
         --
         if l_column = 'PAYROLL_ID' then
            l_col_old_val := to_char(p_old.PAYROLL_ID);
            l_col_new_val := to_char(p_new.PAYROLL_ID);
         end if;
         --
         if l_column = 'LOCATION_ID' then
            l_col_old_val := to_char(p_old.LOCATION_ID);
            l_col_new_val := to_char(p_new.LOCATION_ID);
         end if;
         --
         if l_column = 'ASSIGNMENT_STATUS_TYPE_ID' then
            l_col_old_val := to_char(p_old.ASSIGNMENT_STATUS_TYPE_ID);
            l_col_new_val := to_char(p_new.ASSIGNMENT_STATUS_TYPE_ID);
         end if;
         --
         if l_column = 'ASSIGNMENT_TYPE' then
            l_col_old_val := p_old.ASSIGNMENT_TYPE;
            l_col_new_val := p_new.ASSIGNMENT_TYPE;
         end if;
         --
         if l_column = 'PRIMARY_FLAG' then
            l_col_old_val := p_old.PRIMARY_FLAG;
            l_col_new_val := p_new.PRIMARY_FLAG;
         end if;
         --
         if l_column = 'EMPLOYMENT_CATEGORY' then
            l_col_old_val := p_old.EMPLOYMENT_CATEGORY;
            l_col_new_val := p_new.EMPLOYMENT_CATEGORY;
         end if;
         --
         if l_column = 'BARGAINING_UNIT_CODE' then
            l_col_old_val := p_old.BARGAINING_UNIT_CODE;
            l_col_new_val := p_new.BARGAINING_UNIT_CODE;
         end if;
         --
         if l_column = 'HOURLY_SALARIED_CODE' then
            l_col_old_val := p_old.HOURLY_SALARIED_CODE;
            l_col_new_val := p_new.HOURLY_SALARIED_CODE;
         end if;
         --
         if l_column = 'NORMAL_HOURS' then
            l_col_old_val := p_old.NORMAL_HOURS;
            l_col_new_val := p_new.NORMAL_HOURS;
         end if;
         --
         benutils.exec_rule(
             p_formula_id        => l_per_info_chg_cs_ler_rl,
             p_effective_date    => l_session_date,
             p_lf_evt_ocrd_dt    => null,
             p_business_group_id => nvl(p_new.business_group_id, p_old.business_group_id),
             p_person_id         => nvl(p_new.person_id, p_old.person_id),
             p_new_value         => l_col_new_val,
             p_old_value         => l_col_old_val,
             p_column_name       => l_column,
             p_param5           => 'BEN_ASG_IN_EFFECTIVE_START_DATE',
             p_param5_value     => to_char(p_new.EFFECTIVE_START_DATE, 'YYYY/MM/DD HH24:MI:SS'),
             p_param6           => 'BEN_ASG_IO_EFFECTIVE_START_DATE',
             p_param6_value     => to_char(p_old.EFFECTIVE_START_DATE, 'YYYY/MM/DD HH24:MI:SS'),
             p_param7           => 'BEN_ASG_IN_EFFECTIVE_END_DATE',
             p_param7_value     => to_char(p_new.EFFECTIVE_END_DATE, 'YYYY/MM/DD HH24:MI:SS'),
             p_param8           => 'BEN_ASG_IO_EFFECTIVE_END_DATE',
             p_param8_value     => to_char(p_old.EFFECTIVE_END_DATE, 'YYYY/MM/DD HH24:MI:SS'),
             p_param9           => 'BEN_ASG_IN_ORGANIZATION_ID',
             p_param9_value     => to_char(p_new.ORGANIZATION_ID),
             p_param10           => 'BEN_ASG_IO_ORGANIZATION_ID',
             p_param10_value     => to_char(p_old.ORGANIZATION_ID),
             p_param11           => 'BEN_ASG_IN_GRADE_ID',
             p_param11_value     => to_char(p_new.GRADE_ID),
             p_param12           => 'BEN_ASG_IO_GRADE_ID',
             p_param12_value     => to_char(p_old.GRADE_ID),
             p_param13           => 'BEN_ASG_IN_JOB_ID',
             p_param13_value     => to_char(p_new.JOB_ID),
             p_param14           => 'BEN_ASG_IO_JOB_ID',
             p_param14_value     => to_char(p_old.JOB_ID),
             p_param15           => 'BEN_ASG_IN_PAYROLL_ID',
             p_param15_value     => to_char(p_new.PAYROLL_ID),
             p_param16           => 'BEN_ASG_IO_PAYROLL_ID',
             p_param16_value     => to_char(p_old.PAYROLL_ID),
             p_param17           => 'BEN_ASG_IN_LOCATION_ID',
             p_param17_value     => to_char(p_new.LOCATION_ID),
             p_param18           => 'BEN_ASG_IO_LOCATION_ID',
             p_param18_value     => to_char(p_old.LOCATION_ID),
             p_param19           => 'BEN_ASG_IN_ASSIGNMENT_STATUS_TYPE_ID',
             p_param19_value     => to_char(p_new.ASSIGNMENT_STATUS_TYPE_ID),
             p_param20           => 'BEN_ASG_IO_ASSIGNMENT_STATUS_TYPE_ID',
             p_param20_value     => to_char(p_old.ASSIGNMENT_STATUS_TYPE_ID),
             p_param21           => 'BEN_ASG_IN_ASSIGNMENT_TYPE',
             p_param21_value     => p_new.ASSIGNMENT_TYPE,
             p_param22           => 'BEN_ASG_IO_ASSIGNMENT_TYPE',
             p_param22_value     => p_old.ASSIGNMENT_TYPE,
             p_param23           => 'BEN_ASG_IN_PRIMARY_FLAG',
             p_param23_value     => p_new.PRIMARY_FLAG,
             p_param24           => 'BEN_ASG_IO_PRIMARY_FLAG',
             p_param24_value     => p_old.PRIMARY_FLAG,
             p_param25           => 'BEN_ASG_IN_EMPLOYMENT_CATEGORY',
             p_param25_value     => p_new.EMPLOYMENT_CATEGORY,
             p_param26           => 'BEN_ASG_IO_EMPLOYMENT_CATEGORY',
             p_param26_value     => p_old.EMPLOYMENT_CATEGORY,
             p_param27           => 'BEN_ASG_IN_BARGAINING_UNIT_CODE',
             p_param27_value     => p_new.BARGAINING_UNIT_CODE,
             p_param28           => 'BEN_ASG_IO_BARGAINING_UNIT_CODE',
             p_param28_value     => p_old.BARGAINING_UNIT_CODE,
             p_param29           => 'BEN_ASG_IN_HOURLY_SALARIED_CODE',
             p_param29_value     => p_new.HOURLY_SALARIED_CODE,
             p_param30           => 'BEN_ASG_IO_HOURLY_SALARIED_CODE',
             p_param30_value     => p_old.HOURLY_SALARIED_CODE,
             p_param31           => 'BEN_ASG_IN_NORMAL_HOURS',
             p_param31_value     => p_new.NORMAL_HOURS,
             p_param32           => 'BEN_ASG_IO_NORMAL_HOURS',
             p_param32_value     => p_old.NORMAL_HOURS,
             p_param33           => 'BEN_IV_LER_ID',    /* Bug 3891096 */
             p_param33_value     => to_char(l_ler_id),
             p_pk_id             => to_char(p_new.assignment_id),
             p_ret_val           => l_rule_output);
         --
      end if;
      --

         --
               if l_column = 'ASSIGNMENT_STATUS_TYPE_ID' then
                 l_changed := (benutils.column_changed(p_old.assignment_status_type_id
                              ,p_new.assignment_status_type_id,l_new_val) AND
                               benutils.column_changed(p_new.assignment_status_type_id
                              ,p_old.assignment_status_type_id,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ORGANIZATION_ID' then
                 l_changed := (benutils.column_changed(p_old.organization_id
                              ,p_new.organization_id,l_new_val) AND
                               benutils.column_changed(p_new.organization_id
                              ,p_old.organization_id,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASSIGNMENT_TYPE' then
                 l_changed := (benutils.column_changed(p_old.assignment_type
                              ,p_new.assignment_type,l_new_val) AND
                               benutils.column_changed(p_new.assignment_type
                              ,p_old.assignment_type,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'PRIMARY_FLAG' then
                 l_changed := (benutils.column_changed(p_old.primary_flag
                              ,p_new.primary_flag,l_new_val) AND
                               benutils.column_changed(p_new.primary_flag
                              ,p_old.primary_flag,l_old_val) AND
                               (l_changed));
               end if;
          --
               if l_column = 'CHANGE_REASON' then
                 l_changed := (benutils.column_changed(p_old.change_reason
                              ,p_new.change_reason,l_new_val) AND
                               benutils.column_changed(p_new.change_reason
                              ,p_old.change_reason,l_old_val) AND
                               (l_changed));
               end if;
          --
               if l_column = 'EMPLOYMENT_CATEGORY' then
                 l_changed := (benutils.column_changed(p_old.employment_category
                              ,p_new.employment_category,l_new_val) AND
                               benutils.column_changed(p_new.employment_category
                              ,p_old.employment_category,l_old_val) AND
                              (l_changed));
                hr_utility.set_location('NEW EC'||p_new.employment_category, 50);
                hr_utility.set_location('OLD EC'||p_old.employment_category, 50);
               end if;
               if l_column = 'FREQUENCY' then
                 l_changed := (benutils.column_changed(p_old.frequency
                              ,p_new.frequency,l_new_val) AND
                               benutils.column_changed(p_new.frequency
                              ,p_old.frequency,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'GRADE_ID' then
                 l_changed := (benutils.column_changed(p_old.grade_id
                              ,p_new.grade_id,l_new_val) AND
                               benutils.column_changed(p_new.grade_id
                              ,p_old.grade_id,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'JOB_ID' then
                 l_changed := (benutils.column_changed(p_old.job_id
                              ,p_new.job_id,l_new_val) AND
                               benutils.column_changed(p_new.job_id
                              ,p_old.job_id,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'POSITION_ID' then
                 l_changed := (benutils.column_changed(p_old.position_id
                              ,p_new.position_id,l_new_val) AND
                               benutils.column_changed(p_new.position_id
                              ,p_old.position_id,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'LOCATION_ID' then
                 l_changed := (benutils.column_changed(p_old.location_id
                              ,p_new.location_id,l_new_val) AND
                               benutils.column_changed(p_new.location_id
                              ,p_old.location_id,l_old_val) AND
                              (l_changed));

                 -- When called from Termination, do not trigger Location LE
                 if l_changed and not ben_asg_ins.g_trgr_loc_chg then --Bug 2666342
                   l_changed := FALSE;
                 end if;

               end if;
          --
               if l_column = 'NORMAL_HOURS' then
                 l_changed := (benutils.column_changed(p_old.normal_hours
                              ,p_new.normal_hours,l_new_val) AND
                               benutils.column_changed(p_new.normal_hours
                              ,p_old.normal_hours,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'PAYROLL_ID' then
                 l_changed := (benutils.column_changed(p_old.payroll_id
                              ,p_new.payroll_id,l_new_val) AND
                               benutils.column_changed(p_new.payroll_id
                              ,p_old.payroll_id,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'PAY_BASIS_ID' then
                 l_changed := (benutils.column_changed(p_old.pay_basis_id
                              ,p_new.pay_basis_id,l_new_val) AND
                               benutils.column_changed(p_new.pay_basis_id
                              ,p_old.pay_basis_id,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'BARGAINING_UNIT_CODE' then
                 l_changed := (benutils.column_changed(p_old.bargaining_unit_code
                              ,p_new.bargaining_unit_code,l_new_val) AND
                               benutils.column_changed(p_new.bargaining_unit_code
                              ,p_old.bargaining_unit_code,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'LABOUR_UNION_MEMBER_FLAG' then
                 l_changed := (benutils.column_changed(p_old.labour_union_member_flag
                              ,p_new.labour_union_member_flag,l_new_val) AND
                               benutils.column_changed(p_new.labour_union_member_flag
                              ,p_old.labour_union_member_flag,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'PEOPLE_GROUP_ID' then
                 l_changed := (benutils.column_changed(p_old.people_group_id
                              ,p_new.people_group_id,l_new_val) AND
                               benutils.column_changed(p_new.people_group_id
                              ,p_old.people_group_id,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'HOURLY_SALARIED_CODE' then
                 l_changed := (benutils.column_changed(p_old.hourly_salaried_code
                              ,p_new.hourly_salaried_code,l_new_val) AND
                               benutils.column_changed(p_new.hourly_salaried_code
                              ,p_old.hourly_salaried_code,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE1' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute1
                            ,p_new.ass_attribute1,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute1
                            ,p_old.ass_attribute1,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE2' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute2
                            ,p_new.ass_attribute2,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute2
                            ,p_old.ass_attribute2,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE3' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute3
                            ,p_new.ass_attribute3,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute3
                            ,p_old.ass_attribute3,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE4' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute4
                            ,p_new.ass_attribute4,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute4
                            ,p_old.ass_attribute4,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE5' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute5
                            ,p_new.ass_attribute5,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute5
                            ,p_old.ass_attribute5,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE6' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute6
                            ,p_new.ass_attribute6,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute6
                            ,p_old.ass_attribute6,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE7' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute7
                            ,p_new.ass_attribute7,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute7
                            ,p_old.ass_attribute7,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE8' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute8
                            ,p_new.ass_attribute8,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute8
                            ,p_old.ass_attribute8,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE9' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute9
                            ,p_new.ass_attribute9,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute9
                            ,p_old.ass_attribute9,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE10' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute10
                            ,p_new.ass_attribute10,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute10
                            ,p_old.ass_attribute10,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE11' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute11
                            ,p_new.ass_attribute11,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute11
                            ,p_old.ass_attribute11,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE12' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute12
                            ,p_new.ass_attribute12,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute12
                            ,p_old.ass_attribute12,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE13' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute13
                            ,p_new.ass_attribute13,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute13
                            ,p_old.ass_attribute13,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE14' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute14
                            ,p_new.ass_attribute14,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute14
                            ,p_old.ass_attribute14,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE15' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute15
                            ,p_new.ass_attribute15,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute15
                            ,p_old.ass_attribute15,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE16' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute16
                            ,p_new.ass_attribute16,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute16
                            ,p_old.ass_attribute16,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE17' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute17
                            ,p_new.ass_attribute17,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute17
                            ,p_old.ass_attribute17,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE18' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute18
                            ,p_new.ass_attribute18,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute18
                            ,p_old.ass_attribute18,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE19' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute19
                            ,p_new.ass_attribute19,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute19
                            ,p_old.ass_attribute19,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE20' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute20
                            ,p_new.ass_attribute20,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute20
                            ,p_old.ass_attribute20,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE21' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute21
                            ,p_new.ass_attribute21,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute21
                            ,p_old.ass_attribute21,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE22' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute22
                            ,p_new.ass_attribute22,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute22
                            ,p_old.ass_attribute22,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE23' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute23
                            ,p_new.ass_attribute23,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute23
                            ,p_old.ass_attribute23,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE24' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute24
                            ,p_new.ass_attribute24,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute24
                            ,p_old.ass_attribute24,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE25' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute25
                            ,p_new.ass_attribute25,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute25
                            ,p_old.ass_attribute25,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE26' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute26
                            ,p_new.ass_attribute26,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute26
                            ,p_old.ass_attribute26,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE27' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute27
                            ,p_new.ass_attribute27,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute27
                            ,p_old.ass_attribute27,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE28' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute28
                            ,p_new.ass_attribute28,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute28
                            ,p_old.ass_attribute28,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE29' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute29
                            ,p_new.ass_attribute29,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute29
                            ,p_old.ass_attribute29,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ASS_ATTRIBUTE30' then
                 l_changed := (benutils.column_changed(p_old.ass_attribute30
                            ,p_new.ass_attribute30,l_new_val) AND
                               benutils.column_changed(p_new.ass_attribute30
                            ,p_old.ass_attribute30,l_old_val) AND
                              (l_changed));
               end if;
          --

      --
       	-- Checking the rule output and the rule override flag.
	        	-- Whether the rule is mandatory or not, rule output should return 'Y'
	        	-- Rule Mandatory flag is just to override the column data change.
	            hr_utility.set_location('Rule Override Flag = '||l_rule_overrides_flag,20);
	        	if l_rule_output = 'Y' and l_rule_overrides_flag = 'Y' then
	        	  l_changed := TRUE ;
	        	  hr_utility.set_location('Rule output = Y, Trigger LE even column change not satisfied', 20.01);
	        	elsif l_rule_output = 'Y' and l_rule_overrides_flag = 'N' then
	        	  l_changed := l_changed AND TRUE;
	        	elsif l_rule_output = 'N' then
                      hr_utility.set_location(' Rule output is N, so we should not trigger LE', 20.01);
	        	  l_changed := FALSE;
	        	end if;

	        	hr_utility.set_location('After the rule Check ',20.05);
	        	if l_changed then
	        	  hr_utility.set_location('l_changed TRUE ', 20.1);
	        	else
	        	  hr_utility.set_location('l_changed FALSE ', 20.1);
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
      end if; */
      --
    end loop;
    hr_utility.set_location(' ben_asg_trigger', 30);
    if l_changed then
      hr_utility.set_location(' Change detected', 30);
    end if;
    l_ptnl_id := 0;
    l_ovn :=null;
    if l_trigger then
      if l_type = 'P' then
        open le_exists(p_new.person_id,l_ler_id,l_lf_evt_ocrd_date);
        fetch le_exists into l_le_exists;
        if le_exists%notfound then
           hr_utility.set_location(' Entering: ben_asg_trigger5', 60);
           ben_create_ptnl_ler_for_per.create_ptnl_ler_event
           --ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
           (p_validate => false
           ,p_ptnl_ler_for_per_id => l_ptnl_id
           ,p_ntfn_dt => l_system_date
           ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_date
           ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
           ,p_ler_id => l_ler_id
           ,p_ler_typ_cd => l_typ_cd
           ,p_person_id => p_new.person_id
           ,p_business_group_Id =>p_new.business_group_id
           ,p_object_version_number => l_ovn
           ,p_assignment_id  => nvl(p_new.ASSIGNMENT_ID, p_old.ASSIGNMENT_ID)
           ,p_effective_date => l_effective_start_date
           ,p_dtctd_dt       => l_effective_start_date);
        end if;
        close le_exists;
      elsif l_type = 'R' then
        hr_utility.set_location(' Entering: ben_asg_trigger5-', 65);
        open get_contacts(p_new.person_id);
        loop
           fetch get_contacts into l_hld_person_id;
           exit when get_contacts%notfound;
           open le_exists(l_hld_person_id,l_ler_id,l_lf_evt_ocrd_date);
           fetch le_exists into l_le_exists;
           if le_exists%notfound then
              hr_utility.set_location(' Entering: ben_asg_trigger5', 60);

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
              ,p_effective_date => l_effective_start_date
              ,p_assignment_id  => nvl(p_new.ASSIGNMENT_ID, p_old.ASSIGNMENT_ID)
              ,p_dtctd_dt       => l_effective_start_date);
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
      hr_utility.set_location(' ben_asg_trigger', 100);
      l_changed   := FALSE;
      l_trigger   := TRUE;
      l_ovn       := NULL;
      --      l_effective_start_date := p_new.effective_start_date;
      --      l_lf_evt_ocrd_date := p_new.effective_start_date;
    end if;
    close get_ler_col;
  end loop;
  hr_utility.set_location(' ben_asg_trigger', 110);
  close get_ler;
  hr_utility.set_location(' Leaving: ben_asg_trigger', 120);

 benutils.set_data_migrator_mode; -- Bug 3320133
 if hr_general.g_data_migrator_mode not in ( 'Y','P') then
   -- If Pay Basis or Grade is changed then check for Quartile in Grade life event, Bug 2628274
   if ( nvl(p_old.grade_id,0) <> nvl(p_new.grade_id,0) ) or
      ( nvl(p_old.pay_basis_id,0) <> nvl(p_new.pay_basis_id,0) ) then
     ben_pro_ler.qua_in_gr_ler_chk(p_old,p_new,null,null,p_effective_date,'A');
   end if;
 end if;
end;
end ben_asg_ler;

/
