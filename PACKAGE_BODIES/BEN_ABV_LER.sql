--------------------------------------------------------
--  DDL for Package Body BEN_ABV_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ABV_LER" as
/* $Header: beabvtrg.pkb 120.0 2005/05/28 00:19:54 appldev noship $*/
procedure ler_chk(p_old IN g_abv_ler_rec
                 ,p_new IN g_abv_ler_rec
                 ,p_effective_date in date default null ) is
l_session_date DATE;
l_person_id NUMBER;
l_system_date DATE;
--
cursor get_person_id IS
select person_id
from per_all_assignments_f
where assignment_id = p_new.assignment_id
and business_group_id = p_new.business_group_id
and l_session_date
    between effective_start_date
    and     effective_end_date;
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
 and    l_session_date
        between ler.effective_start_date
        and     ler.effective_end_date
and ( l_status = 'I' or ler.typ_cd in ('COMP','GSP','ABS','CHECKLIST') )
 and    ((exists
        (select 1
          from   ben_per_info_chg_cs_ler_f psl
          ,      ben_ler_per_info_cs_ler_f lpl
          where  source_table               = 'PER_ASSIGNMENT_BUDGET_VALUES_F'
          and    psl.per_info_chg_cs_ler_id = lpl.per_info_chg_cs_ler_id
          and    lpl.business_group_id   = psl.business_group_id
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
           where  source_table               = 'PER_ASSIGNMENT_BUDGET_VALUES_F'
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
and source_table = 'PER_ASSIGNMENT_BUDGET_VALUES_F'
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
and source_table = 'PER_ASSIGNMENT_BUDGET_VALUES_F'
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
--
l_col_new_val VARCHAR2(1000);
l_col_old_val varchar2(1000);
--
l_rule_overrides_flag VARCHAR2(1);
l_chg_mandatory_cd VARCHAR2(1);
l_trigger boolean := TRUE;
--
--
begin

benutils.set_data_migrator_mode; -- Bug 3320133

 if hr_general.g_data_migrator_mode in ( 'Y','P') then
   --
   return;
   --
 end if;

 l_bool :=fnd_installation.get(appl_id => 805
                   ,dep_appl_id =>805
                   ,status => l_status
                   ,industry => l_industry);

    begin
        hr_utility.set_location(' Entering: ben_abv_trigger', 10);
        l_changed := FALSE;
        If p_effective_date is not null then
           l_session_date := p_effective_date ;
        else
           open get_session_date;
           fetch get_session_date into l_session_date;
           close get_session_date;
        end if ;
        open get_person_id;
        fetch get_person_id into l_person_id;
        close get_person_id;
        open get_system_date;
        fetch get_system_date into l_system_date;
        close get_system_date;
        l_effective_start_date := l_session_date;
        --  l_lf_evt_ocrd_date := l_session_date;
        --
        hr_utility.set_location('ASSIGNMENT_ID'||p_new.assignment_id,10);
        hr_utility.set_location('BUSINESS_GROUP_ID'||p_new.assignment_id,10);
        hr_utility.set_location('VALUE'||p_new.assignment_id,10);
        hr_utility.set_location('ASSIGNMENT_BUDGET_VALUE_ID'||p_new.assignment_id,10);
        hr_utility.set_location('EFFECTIVE_START_DATE'||p_new.assignment_id,10);
        hr_utility.set_location('EFFECTIVE_END_DATE'||p_new.assignment_id,10);
        hr_utility.set_location('sess '||l_session_date, 20);
        hr_utility.set_location('PERSON '||l_person_id, 20);
        hr_utility.set_location('BG '||p_new.business_group_id, 20);
        --
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
             --

             hr_utility.set_location('LER '||l_ler_id, 20);
             hr_utility.set_location('COLUMN '||l_column, 20);
             hr_utility.set_location('NEWVAL '||l_new_val, 20);
             l_changed := TRUE;
      if get_ler_col%ROWCOUNT = 1 then
               l_changed := TRUE;
               hr_utility.set_location('rowcount 1 ', 20);
             end if;
             hr_utility.set_location(' ben_abv_trigger', 20);
             --      hr_utility.set_location('New'||p_new.person_type_id, 20);
             --      hr_utility.set_location('New'||p_old.person_type_id, 20);
             hr_utility.set_location(' ben_abv_trigger', 20);
             --
             -- Call the formula here to evaluate per_info_chg_cs_ler_rl.
             -- If it returns Y, then see the applicability of the data
             -- changes based on new and old values.
             --
             l_rule_output := 'Y';
             --
             if l_per_info_chg_cs_ler_rl is not null then
                --
              if l_column = 'ASSIGNMENT_ID' then
                 l_col_old_val := to_char(p_old.ASSIGNMENT_ID);
                 l_col_new_val := to_char(p_new.ASSIGNMENT_ID);
               end if;
         --
              if l_column = 'VALUE' then
                 l_col_old_val := to_char(p_old.VALUE);
                 l_col_new_val := to_char(p_new.VALUE);
              end if;
         --
         --
              if l_column = 'EFFECTIVE_START_DATE' then
                 l_col_old_val := to_char(p_old.EFFECTIVE_START_DATE,  'YYYY/MM/DD HH24:MI:SS');
                 l_col_new_val := to_char(p_new.EFFECTIVE_START_DATE,  'YYYY/MM/DD HH24:MI:SS');
              end if;
         --
              if l_column = 'EFFECTIVE_END_DATE' then
                 l_col_old_val := to_char(p_old.EFFECTIVE_END_DATE,  'YYYY/MM/DD HH24 :MI:SS');
                 l_col_new_val := to_char(p_new.EFFECTIVE_END_DATE,  'YYYY/MM/DD HH24 :MI:SS');
             end if;
                benutils.exec_rule(
                    p_formula_id        => l_per_info_chg_cs_ler_rl,
                    p_effective_date    => l_session_date,
                    p_lf_evt_ocrd_dt    => null,
                    p_business_group_id => nvl(p_new.business_group_id, p_old.business_group_id),
                    p_person_id         => l_person_id,  --  nvl(p_new.person_id, p_old.person_id),
                    p_new_value         => l_col_new_val,
                    p_old_value         => l_col_old_val,
                    p_column_name       => l_column,
                    p_ret_val           => l_rule_output,
                    p_param5           => 'BEN_ABV_IN_EFFECTIVE_START_DATE',
                    p_param5_value     => to_char(p_new.EFFECTIVE_START_DATE, 'YYYY/MM/DD HH24:MI:SS'),
                    p_param6           => 'BEN_ABV_IO_EFFECTIVE_START_DATE',
                    p_param6_value     => to_char(p_old.EFFECTIVE_START_DATE, 'YYYY/MM/DD HH24:MI:SS'),
                    p_param7           => 'BEN_ABV_IN_EFFECTIVE_END_DATE',
                    p_param7_value     => to_char(p_new.EFFECTIVE_END_DATE, 'YYYY/MM/DD HH24:MI:SS'),
                    p_param8           => 'BEN_ABV_IO_EFFECTIVE_END_DATE',
                    p_param8_value     => to_char(p_old.EFFECTIVE_END_DATE, 'YYYY/MM/DD HH24:MI:SS'),
                    p_param9           => 'BEN_IV_LER_ID',    /* Bug 3891096 */
                    p_param9_value     => to_char(l_ler_id),
                    p_pk_id            => to_char(p_new.assignment_budget_value_id)
                    );
                --
             end if;
             --

                --
                if l_column = 'VALUE' then
                   l_changed := (benutils.column_changed(p_old.value
                                    ,p_new.value,l_new_val) AND
                                       benutils.column_changed(p_new.value
                                    ,p_old.value,l_old_val) AND
                                    (l_changed));
                end if;
                hr_utility.set_location(' ben_abv_trigger', 30);
                --
                if l_column = 'ASSIGNMENT_BUDGET_VALUE_ID' then
                   l_changed := (benutils.column_changed(p_old.assignment_budget_value_id
                                  ,p_new.assignment_budget_value_id,l_new_val) AND
                                       benutils.column_changed(p_new.assignment_budget_value_id
                                  ,p_old.assignment_budget_value_id,l_old_val) AND
                                  (l_changed));
                end if;
                --

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
     /*  if not l_changed then
	 	                 exit;
             end if; */
             hr_utility.set_location(' ben_abv_trigger', 40);
           end loop;
           hr_utility.set_location('  ben_abv_trigger', 50);
           l_ptnl_id := 0;
           l_ovn :=null;
           if l_trigger then
             if l_type = 'P' then
               open le_exists(l_person_id,l_ler_id,l_lf_evt_ocrd_date);
               fetch le_exists into l_le_exists;
               if le_exists%notfound then
                  hr_utility.set_location(' Entering: ben_abv_trigger5', 60);

                  ben_create_ptnl_ler_for_per.create_ptnl_ler_event
                  --ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
                  (p_validate => false
                  ,p_ptnl_ler_for_per_id => l_ptnl_id
                  ,p_ntfn_dt => l_system_date
                  ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_date
                  ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
                  ,p_ler_id => l_ler_id
                  ,p_ler_typ_cd => l_typ_cd
                  ,p_person_id => l_person_id
                  ,p_business_group_Id =>p_new.business_group_id
                  ,p_object_version_number => l_ovn
                  ,p_effective_date => l_effective_start_date
                  ,p_dtctd_dt       => l_effective_start_date);
               end if;
               close le_exists;
             elsif l_type = 'R' then
               hr_utility.set_location(' Entering: ben_abv_trigger5-', 65);
               open get_contacts(l_person_id);
               loop
                  fetch get_contacts into l_hld_person_id;
                  exit when get_contacts%notfound;
                  open le_exists(l_hld_person_id,l_ler_id,l_lf_evt_ocrd_date);
                  fetch le_exists into l_le_exists;
                  if le_exists%notfound then
                hr_utility.set_location(' Entering: ben_abv_trigger5', 60);

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
                     ,p_mnl_dt         => null
                     ,p_dtctd_dt       => l_effective_start_date
                     ,p_procd_dt       => null
                     ,p_unprocd_dt     => null
                     ,p_mnlo_dt        => null
                     ,p_voidd_dt       => null);
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
             hr_utility.set_location(' ben_abv_trigger', 40);
             l_changed   := FALSE;
             l_trigger   := TRUE;
      		 l_ovn       := NULL;
             l_effective_start_date := l_session_date;
             --      l_lf_evt_ocrd_date := l_session_date;
           end if;
           close get_ler_col;
        end loop;
        hr_utility.set_location('  ben_abv_trigger', 50);
        close get_ler;
        hr_utility.set_location('  leaving ben_abv_trigger', 70);
    exception
       when others then
           hr_utility.set_location(sqlerrm, 70);
           raise;
    end;

end;
end ben_abv_ler;

/
