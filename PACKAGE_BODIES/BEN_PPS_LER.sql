--------------------------------------------------------
--  DDL for Package Body BEN_PPS_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PPS_LER" as
/* $Header: bepsptrg.pkb 120.2 2006/11/29 15:18:52 abparekh noship $*/
procedure ler_chk(p_old            in g_pps_ler_rec
                 ,p_new            in g_pps_ler_rec
                 ,p_event          in varchar2
                 ,p_effective_date in date) is
--
l_session_date DATE;
l_system_date DATE;
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
          where  source_table               = 'PER_PERIODS_OF_SERVICE'
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
           where  source_table               = 'PER_PERIODS_OF_SERVICE'
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
and source_table = 'PER_PERIODS_OF_SERVICE'
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
and source_table = 'PER_PERIODS_OF_SERVICE'
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
l_actual_termination_date date;
--
l_bool  BOOLEAN;
l_status VARCHAR2(1);
l_industry VARCHAR2(1);
l_continue boolean := true;
l_col_new_val VARCHAR2(1000); -- UTF8
l_col_old_val varchar2(1000); -- UTF8
--
l_rule_overrides_flag VARCHAR2(1);
l_chg_mandatory_cd VARCHAR2(1);
l_trigger boolean := TRUE;
--
--
begin
 --
 -- Bug 3320133
  benutils.set_data_migrator_mode;
 -- End of Bug 3320133
 if hr_general.g_data_migrator_mode in ( 'Y','P') then
   --
   -- We don't want triggers to fire
   --
   return;
   --
 end if;
 --
 if ben_pps_ler.ben_pps_evt_chk >= 1 and p_event = 'UPDATING' then
   --
   l_continue := false;
   --
 end if ;
 --
 if l_continue then
 l_bool :=fnd_installation.get(appl_id => 805
                   ,dep_appl_id =>805
                   ,status => l_status
                   ,industry => l_industry);

  hr_utility.set_location(' Entering: ben_pps_trigger', 10);
  l_changed := FALSE;
  --open get_session_date;
  --fetch get_session_date into l_session_date;
  --close get_session_date;
  --
  -- Bug 1928098 : Here the per_periodsa_of_service.date_start
  -- is passed as effective_date, if the person whose hire date is 1960 and
  -- and terminated in 2001 will not get the termination life event
  -- if that ler is defined after 1960.
  -- So try use the actual termination date first and then use the
  -- effective_date passed in
  --
  l_session_date := nvl(p_new.actual_termination_date, p_effective_date);
  open get_system_date;
  fetch get_system_date into l_system_date;
  close get_system_date;
  l_effective_start_date := l_session_date;
  --  l_lf_evt_ocrd_date := l_session_date;
  hr_utility.set_location(' ben_pps_trigger', 20);

  -- in some situations the date we use for occured on date is null,
  -- use session date instead.
  if p_new.actual_termination_date is null then
     l_actual_termination_date := l_session_date;
  else
     l_actual_termination_date := p_new.actual_termination_date;
  end if;

  open get_ler(l_status);
  loop
    fetch get_ler into l_ler_id,l_typ_cd, l_ocrd_dt_cd;
    exit when get_ler%notfound;
           l_trigger := TRUE;
    --
    hr_utility.set_location(' ler type '|| l_typ_cd, 20);
    if l_ocrd_dt_cd is null then
      l_lf_evt_ocrd_date := p_new.date_start;
    else
      --
      --   Call the common date procedure.
      --
      -- Bug 1928098 : pass l_session_date
      --
      ben_determine_date.main
        (p_date_cd         => l_ocrd_dt_cd
        ,p_effective_date  => nvl(l_session_date,p_new.date_start)
        ,p_lf_evt_ocrd_dt  => nvl(l_session_date,p_new.date_start)
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
      hr_utility.set_location(' ben_pps_trigger', 50);
      -- Call the formula here to evaluate per_info_chg_cs_ler_rl.
      -- If it returns Y, then see the applicability of the data
      -- changes based on new and old values.
      --
      l_rule_output := 'Y';
      --
      if l_per_info_chg_cs_ler_rl is not null then
         --
         --
         if l_column = 'DATE_START' then
              l_col_old_val := to_char(p_old.DATE_START, 'YYYY/MM/DD HH24:MI:SS');
              l_col_new_val := to_char(p_new.DATE_START, 'YYYY/MM/DD HH24:MI:SS');
         end if;
         --
         if l_column = 'ACTUAL_TERMINATION_DATE' then
              l_col_old_val := to_char(p_old.ACTUAL_TERMINATION_DATE, 'YYYY/MM/DD HH24:MI:SS');
              l_col_new_val := to_char(p_new.ACTUAL_TERMINATION_DATE, 'YYYY/MM/DD HH24:MI:SS');
         end if;
         --
         if l_column = 'ADJUSTED_SVC_DATE' then
              l_col_old_val := to_char(p_old.ADJUSTED_SVC_DATE, 'YYYY/MM/DD HH24:MI:SS');
              l_col_new_val := to_char(p_new.ADJUSTED_SVC_DATE, 'YYYY/MM/DD HH24:MI:SS');
         end if;
         --
         if l_column = 'FINAL_PROCESS_DATE' then
              l_col_old_val := to_char(p_old.FINAL_PROCESS_DATE, 'YYYY/MM/DD HH24:MI:SS');
              l_col_new_val := to_char(p_new.FINAL_PROCESS_DATE, 'YYYY/MM/DD HH24:MI:SS');
         end if;
         --
         if l_column = 'ATTRIBUTE1' then
              l_col_old_val := p_old.ATTRIBUTE1;
              l_col_new_val := p_new.ATTRIBUTE1;
         end if;
         --
         if l_column = 'ATTRIBUTE2' then
              l_col_old_val := p_old.ATTRIBUTE2;
              l_col_new_val := p_new.ATTRIBUTE2;
         end if;
         --
         if l_column = 'ATTRIBUTE3' then
              l_col_old_val := p_old.ATTRIBUTE3;
              l_col_new_val := p_new.ATTRIBUTE3;
         end if;
         --
         if l_column = 'ATTRIBUTE4' then
              l_col_old_val := p_old.ATTRIBUTE4;
              l_col_new_val := p_new.ATTRIBUTE4;
         end if;
         --
         if l_column = 'ATTRIBUTE5' then
              l_col_old_val := p_old.ATTRIBUTE5;
              l_col_new_val := p_new.ATTRIBUTE5;
         end if;
         --
         if l_column = 'LEAVING_REASON' then
              l_col_old_val := p_old.LEAVING_REASON;
              l_col_new_val := p_new.LEAVING_REASON;
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
             p_pk_id             => to_char(p_new.PERIOD_OF_SERVICE_ID), -- 9999 is it passed.
             p_param5            => 'BEN_PPS_IN_DATE_START',
             p_param5_value      => to_char(p_new.DATE_START,'YYYY/MM/DD HH24:MI:SS'),
             p_param6            => 'BEN_PPS_IO_DATE_START',
             p_param6_value      => to_char(p_old.DATE_START,'YYYY/MM/DD HH24:MI:SS'),
             p_param7            => 'BEN_PPS_IN_ACTUAL_TERMINATION_DATE',
             p_param7_value      => to_char(p_new.ACTUAL_TERMINATION_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param8            => 'BEN_PPS_IO_ACTUAL_TERMINATION_DATE',
             p_param8_value      => to_char(p_old.ACTUAL_TERMINATION_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param9            => 'BEN_PPS_IN_ADJUSTED_SVC_DATE',
             p_param9_value      => to_char(p_new.ADJUSTED_SVC_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param10            => 'BEN_PPS_IO_ADJUSTED_SVC_DATE',
             p_param10_value      => to_char(p_old.ADJUSTED_SVC_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param11            => 'BEN_PPS_IN_FINAL_PROCESS_DATE',
             p_param11_value      => to_char(p_new.FINAL_PROCESS_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param12            => 'BEN_PPS_IO_FINAL_PROCESS_DATE',
             p_param12_value      => to_char(p_old.FINAL_PROCESS_DATE,'YYYY/MM/DD HH24:MI:SS'),
             p_param13            => 'BEN_PPS_IN_LEAVING_REASON',
             p_param13_value      => p_new.LEAVING_REASON,
             p_param14            => 'BEN_PPS_IO_LEAVING_REASON',
             p_param14_value      => p_old.LEAVING_REASON,
             p_param15           => 'BEN_PPS_IN_ATTRIBUTE1',
             p_param15_value     => p_new.ATTRIBUTE1,
             p_param16           => 'BEN_PPS_IO_ATTRIBUTE1',
             p_param16_value     => p_old.ATTRIBUTE1,
             p_param17           => 'BEN_PPS_IN_ATTRIBUTE2',
             p_param17_value     => p_new.ATTRIBUTE2,
             p_param18           => 'BEN_PPS_IO_ATTRIBUTE2',
             p_param18_value     => p_old.ATTRIBUTE2,
             p_param20           => 'BEN_PPS_IN_ATTRIBUTE3',
             p_param20_value     => p_new.ATTRIBUTE3,
             p_param21           => 'BEN_PPS_IO_ATTRIBUTE3',
             p_param21_value     => p_old.ATTRIBUTE3,
             p_param22           => 'BEN_PPS_IN_ATTRIBUTE4',
             p_param22_value     => p_new.ATTRIBUTE4,
             p_param23           => 'BEN_PPS_IO_ATTRIBUTE4',
             p_param23_value     => p_old.ATTRIBUTE4,
             p_param24           => 'BEN_PPS_IN_ATTRIBUTE5',
             p_param24_value     => p_new.ATTRIBUTE5,
             p_param25           => 'BEN_PPS_IO_ATTRIBUTE5',
             p_param25_value     => p_old.ATTRIBUTE5,
             p_param26           => 'BEN_IV_LER_ID',    /* Bug 3891096 */
             p_param26_value     => to_char(l_ler_id),
             p_ret_val           => l_rule_output);
         --
      end if;
      --

       --
            -- Bug 1877018
            if l_column = 'FINAL_PROCESS_DATE' then
              l_changed := (benutils.column_changed(p_old.FINAL_PROCESS_DATE
                           ,p_new.FINAL_PROCESS_DATE,l_new_val) AND
                            benutils.column_changed(p_new.FINAL_PROCESS_DATE
                           ,p_old.FINAL_PROCESS_DATE,l_old_val) AND
                           (l_changed));
                --
                if l_ocrd_dt_cd is null then
                  l_lf_evt_ocrd_date := nvl(p_new.FINAL_PROCESS_DATE,
                                            l_session_date);
                else
                  --
                  --   Call the common date procedure.
                  --
                  ben_determine_date.main
                    (p_date_cd         => l_ocrd_dt_cd
                    ,p_effective_date  => nvl(p_new.FINAL_PROCESS_DATE,
                                              l_session_date)
                    ,p_lf_evt_ocrd_dt  => nvl(p_new.FINAL_PROCESS_DATE,
                                              l_session_date)
                    ,p_returned_date   => l_lf_evt_ocrd_date
                    );
                end if;
              hr_utility.set_location(' l_changed:',39);
            end if;
       --
            if l_column = 'DATE_START' then
              l_changed := (benutils.column_changed(p_old.date_start
                           ,p_new.date_start,l_new_val) AND
                            benutils.column_changed(p_new.date_start
                           ,p_old.date_start,l_old_val) AND
                           (l_changed));
              hr_utility.set_location(' l_changed:',40);
	      --
	      -- Bug 5672925
	      -- If Person Changes are based on DATE_START then LF_EVT_OCRD_DT should be
	      -- new DATE_START and not the effective date
	      --
              if l_ocrd_dt_cd is null then
                l_lf_evt_ocrd_date := p_new.date_start;
              else
                --
                --   Call the common date procedure.
                --
                ben_determine_date.main
                  (p_date_cd         => l_ocrd_dt_cd
                  ,p_effective_date  => p_new.date_start
                  ,p_lf_evt_ocrd_dt  => p_new.date_start
                  ,p_returned_date   => l_lf_evt_ocrd_date
                  );
              end if;
	      hr_utility.set_location('ACE l_lf_evt_ocrd_date = ' || l_lf_evt_ocrd_date, 9999);
	      -- Bug 5672925
	      --
            end if;
       --
              if l_column = 'ACTUAL_TERMINATION_DATE' then
                l_changed := (benutils.column_changed(p_old.actual_termination_date
                           ,p_new.actual_termination_date,l_new_val) AND
                              benutils.column_changed(p_new.actual_termination_date
                           ,p_old.actual_termination_date,l_old_val) AND
                             (l_changed));
                --
                if l_ocrd_dt_cd is null then
                  l_lf_evt_ocrd_date := l_actual_termination_date;
                else
                  --
                  --   Call the common date procedure.
                  --
                  ben_determine_date.main
                    (p_date_cd         => l_ocrd_dt_cd
                    ,p_effective_date  => l_actual_termination_date
                    ,p_lf_evt_ocrd_dt  => p_new.actual_termination_date
                    ,p_returned_date   => l_lf_evt_ocrd_date
                    );
                end if;
            end if;
       --
             if l_column = 'LEAVING_REASON' then
                l_changed := (benutils.column_changed(p_old.leaving_reason
                           ,p_new.leaving_reason,l_new_val) AND
                              benutils.column_changed(p_new.leaving_reason
                           ,p_old.leaving_reason,l_old_val) AND
                             (l_changed));
               --
               if l_ocrd_dt_cd is null then
                 l_lf_evt_ocrd_date := l_actual_termination_date;
               else
                 --
                 --   Call the common date procedure.
                 --
                 ben_determine_date.main
                   (p_date_cd         => l_ocrd_dt_cd
                   ,p_effective_date  => l_actual_termination_date
                   ,p_lf_evt_ocrd_dt  => p_new.actual_termination_date
                   ,p_returned_date   => l_lf_evt_ocrd_date
                   );
               end if;

            end if;

       --
            if l_column = 'ADJUSTED_SVC_DATE' then
              l_changed := (benutils.column_changed(p_old.adjusted_svc_date
                          ,p_new.adjusted_svc_date,l_new_val)  AND
                            benutils.column_changed(p_new.adjusted_svc_date
                          ,p_old.adjusted_svc_date,l_old_val)  AND
                           (l_changed));
            end if;
       --
            if l_column = 'ATTRIBUTE1' then
              l_changed := (benutils.column_changed(p_old.attribute1
                         ,p_new.attribute1,l_new_val) AND
                            benutils.column_changed(p_new.attribute1
                         ,p_old.attribute1,l_old_val) AND
                           (l_changed));
            end if;
       --
            if l_column = 'ATTRIBUTE2' then
              l_changed := (benutils.column_changed(p_old.attribute2
                         ,p_new.attribute2,l_new_val) AND
                            benutils.column_changed(p_new.attribute2
                         ,p_old.attribute2,l_old_val) AND
                           (l_changed));
            end if;
       --
            if l_column = 'ATTRIBUTE3' then
              l_changed := (benutils.column_changed(p_old.attribute3
                         ,p_new.attribute3,l_new_val) AND
                            benutils.column_changed(p_new.attribute3
                         ,p_old.attribute3,l_old_val) AND
                           (l_changed));
            end if;
       --
            if l_column = 'ATTRIBUTE4' then
              l_changed := (benutils.column_changed(p_old.attribute4
                         ,p_new.attribute4,l_new_val) AND
                            benutils.column_changed(p_new.attribute4
                         ,p_old.attribute4,l_old_val) AND
                           (l_changed));
            end if;
       --
            if l_column = 'ATTRIBUTE5' then
              l_changed := (benutils.column_changed(p_old.attribute5
                         ,p_new.attribute5,l_new_val) AND
                            benutils.column_changed(p_new.attribute5
                         ,p_old.attribute5,l_old_val) AND
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
      /* if not l_changed then
	           exit;
      end if; */
    end loop;
    hr_utility.set_location('  ben_pps_trigger', 50);
    l_ptnl_id := 0;
    l_ovn :=null;
    if l_trigger then
      if l_type = 'P' then
        open le_exists(p_new.person_id,l_ler_id,l_lf_evt_ocrd_date);
        fetch le_exists into l_le_exists;
        if le_exists%notfound then
           hr_utility.set_location(' Entering: ben_pps_trigger5', 60);

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
           ,p_effective_date => l_effective_start_date
           ,p_dtctd_dt       => l_effective_start_date);
        end if;
        close le_exists;
      elsif l_type = 'R' then
        hr_utility.set_location(' Entering: ben_pps_trigger5-', 65);
        open get_contacts(p_new.person_id);
        loop
           fetch get_contacts into l_hld_person_id;
           exit when get_contacts%notfound;
           open le_exists(l_hld_person_id,l_ler_id,l_lf_evt_ocrd_date);
           fetch le_exists into l_le_exists;
           if le_exists%notfound then
               hr_utility.set_location(' Entering: ben_pps_trigger5', 60);

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
      hr_utility.set_location(' ben_pps_trigger', 60);
      l_changed   := FALSE;
      l_trigger   := TRUE;
      l_ovn       := NULL;
      l_effective_start_date := l_session_date;
      --      l_lf_evt_ocrd_date := l_session_date;
    end if;
    close get_ler_col;
  end loop;
  hr_utility.set_location('  ben_pps_trigger', 70);
  close get_ler;
  hr_utility.set_location('  leaving ben_pps_trigger', 80);
 end if;
 --
 -- following are to be removed whne hr fix the bug
 --
 if p_event = 'UPDATING' and
   p_new.actual_termination_date is null and
   p_old.actual_termination_date is not null then
   --
   ben_pps_ler.ben_pps_evt_chk :=  ben_pps_ler.ben_pps_evt_chk + 1 ;
   --
 end if ;
 --
 if ben_pps_ler.ben_pps_evt_chk >= 1 then  --5095450: resetting it to 0 /* NOTE logic using  ben_pps_evt_chk can be removed !! */
   --
   ben_pps_ler.ben_pps_evt_chk := 0 ;
   --
 end if ;
 --
end;
end ben_pps_ler;

/
