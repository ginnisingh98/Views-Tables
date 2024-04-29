--------------------------------------------------------
--  DDL for Package Body BEN_ABS_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ABS_LER" as
/* $Header: beabatrg.pkb 120.2.12010000.2 2008/08/05 13:52:57 ubhat ship $*/

g_param_tab ff_exec.outputs_t;

function decode_reason(p_abs_attendance_reason_id in number) return varchar2 is
  --
  cursor c1 is
    select name
    from   per_abs_attendance_reasons
    where  abs_attendance_reason_id = p_abs_attendance_reason_id;
  --
  l_reason varchar2(80);
  --
begin
  --
  open c1;
    fetch c1 into l_reason;
  close c1;
  --
  return l_reason;
  --
end decode_reason;

procedure populate_param_tab
(p_name in varchar2,
 p_value in varchar2) is
  l_next_index number;
begin

  l_next_index := nvl(g_param_tab.count,0) + 1;
  g_param_tab(l_next_index).name := p_name;
  g_param_tab(l_next_index).value := p_value;

end;
--
procedure gb_abs_life_event_rule
          (p_absence_event_type in varchar2
          ,p_new_date_start in varchar2
          ,p_old_date_start in varchar2
          ,p_new_date_end in varchar2
          ,p_old_date_end in varchar2
          ,p_new_abs_attendance_type_id in varchar2
          ,p_old_abs_attendance_type_id in varchar2
          ,p_new_abs_information1 in varchar2
          ,p_old_abs_information1 in varchar2
          ,p_new_abs_information2 in varchar2
          ,p_old_abs_information2 in varchar2
          ,p_new_abs_information4 in varchar2
          ,p_old_abs_information4 in varchar2
          ,p_new_abs_information5 in varchar2
          ,p_old_abs_information5 in varchar2
          ,p_new_abs_information6 in varchar2
          ,p_old_abs_information6 in varchar2
          ,p_ret_val out nocopy varchar2) is
  --Declare local variables
  l_default VARCHAR2(25) := '_DEFAULT_';
  l_look_up_check VARCHAR2(80) := ' ';
  l_ret_val VARCHAR2(1) :='N';
  --
  l_proc_name Constant Varchar2(150) :='gb_abs_life_event_rule';
  --
begin
  --
  hr_utility.set_location('Entering: ' || l_proc_name, 5);
  hr_utility.set_location('Absence event type: ' || p_absence_event_type, 5);
  --
  if p_absence_event_type = 'START' then
    --
    --Check that there is a difference between the old and new values of
    --start date.

    --
    hr_utility.set_location('Absence Event Type = START', 10);
    l_look_up_check := HR_GENERAL.DECODE_LOOKUP('PQP_GAP_ABSENCE_TYPES_LIST',p_new_abs_attendance_type_id);
    --
    if l_look_up_check is not null then
      --
      if p_old_date_start <> p_new_date_start and p_new_abs_attendance_type_id <> l_default then
        --
        --Set the return flag to "Y"es to allow this person change to cause an
        --"absence start" life event.
        --NOTE the default for the flag is "N"o.
        --
        l_ret_val := 'Y';
        --
      end if;

      --End Absence Start Date Section
      hr_utility.set_location('End Absence Start Date Section:' || l_ret_val, 20);
      --
      --Begin Absence Information 1 - Start Date Fraction Section
      --Check that there is a difference between the old and new values of
      --ABS_INFORMATION1.

      --
      if l_ret_val = 'N' then
        --
        if p_old_abs_information1 <> p_new_abs_information1 and p_new_abs_attendance_type_id <> l_default then
          --
          l_ret_val := 'Y';
          --
        end if;
        --
      end if;

      --End Absence Information 1
      hr_utility.set_location('End of Absence Information 1 Section:' || l_ret_val, 30);
      --
      --Begin Absence Information 2 - End Date Fraction Section
      --Check that there is a difference between the old and new values of
      --ABS_INFORMATION2.

      --
      if l_ret_val = 'N' then
        --
        if p_old_abs_information2 <> p_new_abs_information2 and p_new_abs_attendance_type_id <> l_default then
          --
          l_ret_val := 'Y';
          --
        end if;
        --
      end if;

      --End Absence Information 2
      hr_utility.set_location('End of Absence Information 2 Section:' || l_ret_val, 40);


      --
      --Check that there is a difference between the old and new values of
      --INFORMATION4(Pension rate start date) .

      --
      if l_ret_val = 'N' then
        --
          if p_new_abs_information4 <> p_old_abs_information4 and p_new_abs_attendance_type_id <> l_default then
          --
          l_ret_val := 'Y';
          --
        end if;
        --
      end if;

      --End Absence Information 4 i.e. Pension start date
      hr_utility.set_location('End of Pension Rate start date section:' || l_ret_val, 50);

      --Check that there is a difference between the old and new values of
      --INFORMATION5(Pension rate end date) .

      --
      if l_ret_val = 'N' then
        --
        if p_new_abs_information5 <> p_old_abs_information5 and p_new_abs_attendance_type_id <> l_default then
          --
          l_ret_val := 'Y';
          --
        end if;
        --
      end if;

      --End Absence Information 5 i.e. Pension end date
      hr_utility.set_location('End of Pension Rate end date section:' || l_ret_val, 60);
      --
      --Check that there is a difference between the old and new values of
      --INFORMATION6(Pension rate) .

      --
      if l_ret_val = 'N' then
        --
        if p_new_abs_information6 <> p_old_abs_information6 and p_new_abs_attendance_type_id <> l_default then
          --
          l_ret_val := 'Y';
          --
        end if;
        --
      end if;

      --End Absence Information 2 - End Date Fraction Section
      hr_utility.set_location('End of Pension Rate section:' || l_ret_val, 70);
      --
    end if; --End for checking lookup exist
    --
  elsif p_absence_event_type = 'END' then
    --
    --Check that there is a difference between the old and new values of
    --End Date.
    --NOTE When an absence is deleted, the absence_type_id new value will be
    --defaulted. To record an absence delete a seperate life event reason has
    --to be setup. To prevent a absence start change from being logged on a
    --delete, an additional check is introduced to ensure that new value is not
    --equal to the default.
    --
    hr_utility.set_location('Absence Event Type = END', 80);
    l_look_up_check := HR_GENERAL.DECODE_LOOKUP('PQP_GAP_ABSENCE_TYPES_LIST',p_new_abs_attendance_type_id);
    --
    if l_look_up_check is not null then
      --(
      if p_old_date_end <> p_new_date_end and p_new_abs_attendance_type_id <> l_default then
        --
        --Set the return flag to "Y"es to allow this person change to cause an
        --"absence end" life event.
        --NOTE the default for the flag is "N"o.
        --
        l_ret_val := 'Y';
        --
      end if;
      --
    end if;
    --
  elsif p_absence_event_type = 'DELETE' then
    --
    --Check that the new value of absence type id has been defaulted.
    --NOTE When an absence is deleted, the absence_type_id new value will be
    --defaulted. To record an absence delete a seperate life event reason has
    --to be setup. To prevent a absence start change from being logged on a
    --delete, an additional check is introduced to ensure that new value is not
    --equal to the default.
    --
    hr_utility.set_location('Absence Event Type = DELETE', 90);
    l_look_up_check := HR_GENERAL.DECODE_LOOKUP('PQP_GAP_ABSENCE_TYPES_LIST',p_old_abs_attendance_type_id);

    if l_look_up_check is not null then
      --
      if p_old_abs_attendance_type_id <> l_default and p_new_abs_attendance_type_id = l_default then
        --
        --Set the return flag to "Y"es to allow this person change to cause an
        --"absence delete" life event.
        --NOTE the default for the flag is "N"o.
        --
        l_ret_val := 'Y';
        --
      end if;
      --
    end if;
    --
  end if;
  --
  p_ret_val := l_ret_val;
  hr_utility.set_location('Leaving: ' || l_proc_name, 100);
  --
end gb_abs_life_event_rule;
--
procedure ler_chk(p_old IN g_abs_ler_rec
                 ,p_new IN g_abs_ler_rec
                 ,p_effective_date in date default null ) is
  --
  l_session_date DATE;
  l_system_date DATE;
  l_status VARCHAR2(1)   := 'N';
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
  cursor get_ler is
    select ler.ler_id,
           ler.ocrd_dt_det_cd,
           -- ABSENCES
           ler.typ_cd,
           ler.lf_evt_oper_cd
    from   ben_ler_f ler
    where  ler.business_group_id = nvl(p_new.business_group_id,p_old.business_group_id)
    and    l_session_date
           between ler.effective_start_date
           and     ler.effective_end_date
    --
    -- ABSENCES : for OSB customers trigger the absence
    -- life events.
    --
    and    (l_status = 'I' or ler.typ_cd in ( 'ABS','CHECKLIST' ))
    and    ((exists
            (select 1
             from   ben_per_info_chg_cs_ler_f psl,
                    ben_ler_per_info_cs_ler_f lpl
             where  source_table = 'PER_ABSENCE_ATTENDANCES'
             and    psl.per_info_chg_cs_ler_id = lpl.per_info_chg_cs_ler_id
             and    lpl.business_group_id = psl.business_group_id
             and    lpl.business_group_id = ler.business_group_id
             and    l_session_date between psl.effective_start_date
             and    psl.effective_end_date
             and    l_session_date
                    between lpl.effective_start_date
             and    lpl.effective_end_date
             and    lpl.ler_id = ler.ler_id)
    	)
    or      (exists
            (select 1
             from   ben_rltd_per_chg_cs_ler_f rpc,
                    ben_ler_rltd_per_cs_ler_f lrp
             where  source_table = 'PER_ABSENCE_ATTENDANCES'
             and    lrp.business_group_id = rpc.business_group_id
             and    lrp.business_group_id = ler.business_group_id
             and    l_session_date
                    between rpc.effective_start_date
                    and     rpc.effective_end_date
             and    l_session_date
                    between lrp.effective_start_date
                    and     lrp.effective_end_date
             and    rpc.rltd_per_chg_cs_ler_id = lrp.rltd_per_chg_cs_ler_id
             and    lrp.ler_id = ler.ler_id)
          ))
  order by ler.ler_id;
  --
  cursor get_ler_col(p_ler_id IN NUMBER) is
    select psl.source_column,
           psl.new_val,
           psl.old_val,
           'P',
           psl.per_info_chg_cs_ler_rl, psl.rule_overrides_flag, nvl(lpl.chg_mandatory_cd,'Y')
    from   ben_ler_per_info_cs_ler_f lpl,
           ben_per_info_chg_cs_ler_f psl
    where  lpl.ler_id = p_ler_id
    and    lpl.business_group_id = nvl(p_new.business_group_id,p_old.business_group_id)
    and    lpl.business_group_id  = psl.business_group_id
    and    l_session_date
           between psl.effective_start_date
           and     psl.effective_end_date
    and    l_session_date
           between lpl.effective_start_date
           and     lpl.effective_end_date
    and    psl.per_info_chg_cs_ler_id = lpl.per_info_chg_cs_ler_id
    and    source_table = 'PER_ABSENCE_ATTENDANCES'
    union
    select rpc.source_column,
           rpc.new_val,
           rpc.old_val,
           'R',
           rpc.rltd_per_chg_cs_ler_rl per_info_chg_cs_ler, rpc.rule_overrides_flag, nvl(lrp.chg_mandatory_cd,'Y')
    from   ben_ler_rltd_per_cs_ler_f lrp,
           ben_rltd_per_chg_cs_ler_f rpc
    where  lrp.ler_id = p_ler_id
    and    lrp.business_group_id = nvl(p_new.business_group_id,p_old.business_group_id)
    and    lrp.business_group_id  = rpc.business_group_id
    and    l_session_date
           between rpc.effective_start_date
           and     rpc.effective_end_date
    and    l_session_date
           between lrp.effective_start_date
           and     lrp.effective_end_date
    and    rpc.rltd_per_chg_cs_ler_id = lrp.rltd_per_chg_cs_ler_id
    and    source_table = 'PER_ABSENCE_ATTENDANCES'
    order  by 1;
  --
  cursor le_exists(p_person_id in number
                  ,p_ler_id in number
                  ,p_lf_evt_ocrd_dt in date
                  ,p_trgr_table_pk_id in number) is
    select 'Y'
    from   ben_ptnl_ler_for_per
    where  person_id = p_person_id
    and    ler_id = p_ler_id
    and    ptnl_ler_for_per_stat_cd = 'DTCTD'
    and    lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
    and    nvl(trgr_table_pk_id,-1) = nvl(p_trgr_table_pk_id,-1);
  --
  cursor get_contacts(p_person_id in number) is
    select person_id
    from   per_contact_relationships
    where  contact_person_id = p_person_id
    and    business_group_id = nvl(p_new.business_group_id,p_old.business_group_id)
    and    l_session_date
           between nvl(date_start,l_session_date)
           and     nvl(date_end,l_session_date)
    and    personal_flag = 'Y'
    order  by person_id;
  --
  l_changed BOOLEAN;
  l_ler_id NUMBER;
  l_column ben_rltd_per_chg_cs_ler_f.source_column%type;  -- VARCHAR2(30);
  l_new_val ben_rltd_per_chg_cs_ler_f.new_val%type;   -- VARCHAR2(30);
  l_old_val ben_rltd_per_chg_cs_ler_f.old_val%type;       -- VARCHAR2(30);
  l_ocrd_dt_cd VARCHAR2(30);
  l_bool boolean;
  -- ABSENCES
  l_typ_cd     VARCHAR2(30);
  l_per_info_chg_cs_ler_rl number;
  l_rule_output            VARCHAR2(1);
  --
  /* l_absences_rule_output   VARCHAR2(1) := 'N'; */
  -- Commented during Multiple Table LE Triggering enhancement

  --
  l_ovn NUMBER;
  l_ptnl_id NUMBER;
  l_effective_end_date DATE := to_date('31-12-4712','DD-MM-YYYY');
  l_effective_start_date DATE ;
  l_lf_evt_ocrd_date DATE ;
  l_le_exists VARCHAR2(1);
  l_mnl_dt date;
  l_dtctd_dt   date;
  l_procd_dt   date;
  l_unprocd_dt date;
  l_voidd_dt   date;
  l_type    VARCHAR2(1);
  l_hld_person_id NUMBER;
  l_date_start date;
  l_date_end date;
  l_industry VARCHAR2(1);
  l_col_new_val VARCHAR2(1000);
  l_col_old_val VARCHAR2(1000);
  l_lf_evt_oper_cd VARCHAR2(30);
  l_trgr_table_pk_id number;
  l_effective_date date;
  --
  --
  l_rule_overrides_flag VARCHAR2(1);
  l_chg_mandatory_cd VARCHAR2(1);
  l_trigger boolean := TRUE;
  --
  l_leg_code VARCHAR2(10);
--
begin
  --
--hr_utility.trace_on(null, 'dax');
  benutils.set_data_migrator_mode; -- Bug 3320133
      --
  if hr_general.g_data_migrator_mode in ( 'Y','P') then
    --
    return;
    --
  end if;
  --
  l_bool :=fnd_installation.get(appl_id     => 805
                               ,dep_appl_id =>805
                               ,status      => l_status
                               ,industry    => l_industry);

  hr_utility.set_location(' Entering: ben_abs_trigger', 10);
  l_changed := FALSE;
  --
  If p_effective_date is not null then
    --
    l_session_date := p_effective_date ;
    --
  else
    --
    open get_session_date;
      --
      fetch get_session_date into l_session_date;
      --
    close get_session_date;
    --
  end if ;
  --
  -- 3096367
  -- get the effective date to make it the lf evt ocrd dt, if actual and projected are null
  --
  open get_session_date;
    --
    fetch get_session_date into l_effective_date;
    --
  close get_session_date;

  hr_utility.set_location('l_effective_date:'||l_effective_date, 20);

  --
  open get_system_date;
    --
    fetch get_system_date into l_system_date;
    --
  close get_system_date;
  --
  l_effective_start_date := l_session_date;
  hr_utility.set_location(' ben_abs_trigger', 20);
  --
  --
  hr_utility.set_location(' l_system_date:'||to_char(l_system_date), 20);
  hr_utility.set_location(' l_session_date:'||to_char(l_session_date,'dd-mon-rr hh24:mi:ss'), 20);
  hr_utility.set_location(' new abs id:'||to_char(p_new.absence_attendance_id), 20);
  hr_utility.set_location(' old abs id:'||to_char(p_old.absence_attendance_id), 20);
  --
  open get_ler;
    --
    loop
      --
      fetch get_ler into l_ler_id, l_ocrd_dt_cd, l_typ_cd, l_lf_evt_oper_cd;
      hr_utility.set_location(' count : '||to_char(get_ler%rowcount), 20);
      exit when get_ler%notfound;
      --
      hr_utility.set_location(' lf evt oper cd: '||l_lf_evt_oper_cd, 20);
      hr_utility.set_location('old start_date: '||to_char(p_old.date_start), 20);
      hr_utility.set_location('new start_date: '||to_char(p_new.date_start), 20);
      hr_utility.set_location('old end_date: '||to_char(p_old.date_end), 20);
      hr_utility.set_location('new end_date: '||to_char(p_new.date_end), 20);
      if l_typ_cd <> 'ABS' or
         (l_typ_cd = 'ABS' and
          -- This is to stop triggering START/END LEs in case of Delete
            ((p_new.absence_attendance_id is null and
              p_old.absence_attendance_id is not null and
              l_lf_evt_oper_cd = 'DELETE') or
             (p_new.absence_attendance_id is not null and
              l_lf_evt_oper_cd in ('START','END'))
            )
         ) then
        --
        --l_absences_rule_output := 'N';
        --
        -- in some situations the date we use for occured on date is null,
        -- use session date instead.
        --
        -- 3096367
        -- nvl(actual start date, nvl(projected date, session date))

        if l_typ_cd = 'ABS' then
           l_date_start := nvl( nvl(nvl(p_new.date_start,p_old.date_start), p_new.date_projected_start)
           		       ,l_effective_date);
           l_date_end := nvl( nvl(nvl(p_new.date_end,p_old.date_end), p_new.date_projected_end)
           		       ,l_effective_date);

        else
           l_date_start := nvl(p_new.date_start,l_session_date);
           l_date_end := nvl(p_new.date_end,l_session_date);
        end if;
        --
        hr_utility.set_location('l_date_start'||l_date_start, 30);
        hr_utility.set_location('l_date_end'||l_date_end, 30);
        --
        if l_ocrd_dt_cd is null then
          --
          l_lf_evt_ocrd_date := l_date_start;
          --
        else
          --
          --   Call the common date procedure.
          --
          ben_determine_date.main
            (p_date_cd         => l_ocrd_dt_cd
            ,p_effective_date  => l_date_start
            ,p_lf_evt_ocrd_dt  => l_date_start
            ,p_returned_date   => l_lf_evt_ocrd_date);
          --
        end if;
        --
        l_changed := FALSE;
        --
        open get_ler_col(l_ler_id);
          --
          loop
            --
            fetch get_ler_col into l_column,
                                   l_new_val,
                                   l_old_val,
                                   l_type,
                                   l_per_info_chg_cs_ler_rl,l_rule_overrides_flag, l_chg_mandatory_cd;
            exit when get_ler_col%NOTFOUND;
            --
            hr_utility.set_location(' l_column'||l_column, 50);
            hr_utility.set_location(' l_new_val'||l_new_val, 50);
            hr_utility.set_location(' l_old_val'||l_old_val, 50);
            hr_utility.set_location(' l_type'||l_type, 50);
            hr_utility.set_location(' l_ler_id'||l_ler_id, 50);
            --
            if get_ler_col%ROWCOUNT = 1 then
              --
              l_changed := TRUE;
              --
            end if;
            --
            hr_utility.set_location(' ben_abs_trigger', 51);
            --
            -- Call the formula here to evaluate per_info_chg_cs_ler_rl.
            -- If it returns Y, then see the applicability of the data
            -- changes based on new and old values.
            --
            l_rule_output := 'Y';
            --
            --If there is a rule attached, execute the rule
            if l_per_info_chg_cs_ler_rl is not null then
              --
              if l_column = 'PERSON_ID' then
                --
                l_col_old_val := to_char(p_old.PERSON_ID);
                l_col_new_val := to_char(p_new.PERSON_ID);
                --
              elsif l_column = 'DATE_START' then
                --
                l_col_old_val := to_char(p_old.DATE_START,  'YYYY/MM/DD HH24:MI:SS');
                l_col_new_val := to_char(p_new.DATE_START,  'YYYY/MM/DD HH24:MI:SS');
                --
              elsif l_column = 'DATE_END' then
                --
                l_col_old_val := to_char(p_old.DATE_END,  'YYYY/MM/DD HH24:MI:SS');
                l_col_new_val := to_char(p_new.DATE_END,  'YYYY/MM/DD HH24:MI:SS');
                --
              elsif l_column = 'ABSENCE_ATTENDANCE_TYPE_ID' then
                --
                l_col_old_val := to_char(p_old.ABSENCE_ATTENDANCE_TYPE_ID);
                l_col_new_val := to_char(p_new.ABSENCE_ATTENDANCE_TYPE_ID);
                --
              elsif l_column = 'ABS_ATTENDANCE_REASON_ID' then
                --
                l_col_old_val := to_char(p_old.ABS_ATTENDANCE_REASON_ID);
                l_col_new_val := to_char(p_new.ABS_ATTENDANCE_REASON_ID);
                --
                -- Added extra columns for ABSENCES processing.
                --
              elsif l_column = 'SICKNESS_START_DATE' then
                 --
                 l_col_old_val := to_char(p_old.SICKNESS_START_DATE,  'YYYY/MM/DD HH24:MI:SS');
                 l_col_new_val := to_char(p_new.SICKNESS_START_DATE,  'YYYY/MM/DD HH24:MI:SS');
                 --
              elsif l_column = 'SICKNESS_END_DATE' then
                 --
                 l_col_old_val := to_char(p_old.SICKNESS_END_DATE,  'YYYY/MM/DD HH24:MI:SS');
                 l_col_new_val := to_char(p_new.SICKNESS_END_DATE,  'YYYY/MM/DD HH24:MI:SS');
                 --
              elsif l_column = 'ABSENCE_DAYS' then
                 --
                 l_col_old_val := to_char(p_old.ABSENCE_DAYS);
                 l_col_new_val := to_char(p_new.ABSENCE_DAYS);
                 --
              elsif l_column = 'ABSENCE_HOURS' then
                 --
                 l_col_old_val := to_char(p_old.ABSENCE_HOURS);
                 l_col_new_val := to_char(p_new.ABSENCE_HOURS);
                 --
              elsif l_column = 'DATE_NOTIFICATION' then
                 --
                 l_col_old_val := to_char(p_old.DATE_NOTIFICATION,  'YYYY/MM/DD HH24:MI:SS');
                 l_col_new_val := to_char(p_new.DATE_NOTIFICATION,  'YYYY/MM/DD HH24:MI:SS');
                 --
              elsif l_column = 'DATE_PROJECTED_END' then
                 --
                 l_col_old_val := to_char(p_old.DATE_PROJECTED_END,  'YYYY/MM/DD HH24:MI:SS');
                 l_col_new_val := to_char(p_new.DATE_PROJECTED_END,  'YYYY/MM/DD HH24:MI:SS');
                 --
              elsif l_column = 'DATE_PROJECTED_START' then
                 --
                 l_col_old_val := to_char(p_old.DATE_PROJECTED_START,  'YYYY/MM/DD HH24:MI:SS');
                 l_col_new_val := to_char(p_new.DATE_PROJECTED_START,  'YYYY/MM/DD HH24:MI:SS');
                 --
              elsif l_column = 'TIME_END' then
                 --
                 l_col_old_val := p_old.TIME_END;
                 l_col_new_val := p_new.TIME_END;
                 --
              elsif l_column = 'TIME_PROJECTED_END' then
                 --
                 l_col_old_val := p_old.TIME_PROJECTED_END;
                 l_col_new_val := p_new.TIME_PROJECTED_END;
                 --
              elsif l_column = 'TIME_PROJECTED_START' then
                 --
                 l_col_old_val := p_old.TIME_PROJECTED_START;
                 l_col_new_val := p_new.TIME_PROJECTED_START;
                 --
              elsif l_column = 'TIME_START' then
                 --
                 l_col_old_val := p_old.TIME_START;
                 l_col_new_val := p_new.TIME_START;
                 --
              elsif l_column = 'PREGNANCY_RELATED_ILLNESS' then
                 --
                 l_col_old_val := p_old.PREGNANCY_RELATED_ILLNESS;
                 l_col_new_val := p_new.PREGNANCY_RELATED_ILLNESS;
                 --
              elsif l_column = 'REASON_FOR_NOTIFICATION_DELAY' then
                 --
                 l_col_old_val := p_old.REASON_FOR_NOTIFICATION_DELAY;
                 l_col_new_val := p_new.REASON_FOR_NOTIFICATION_DELAY;
                 --
              elsif l_column = 'SSP1_ISSUED' then
                 --
                 l_col_old_val := p_old.SSP1_ISSUED;
                 l_col_new_val := p_new.SSP1_ISSUED;
                 --
              elsif l_column = 'PERIOD_OF_INCAPACITY_ID' then
                 --
                 l_col_old_val := to_char(p_old.PERIOD_OF_INCAPACITY_ID);
                 l_col_new_val := to_char(p_new.PERIOD_OF_INCAPACITY_ID);
                 --
              elsif l_column = 'ACCEPT_LATE_NOTIFICATION_FLAG' then
                 --
                 l_col_old_val := p_old.ACCEPT_LATE_NOTIFICATION_FLAG;
                 l_col_new_val := p_new.ACCEPT_LATE_NOTIFICATION_FLAG;
                 --
              elsif l_column = 'LINKED_ABSENCE_ID' then
                 --
                 l_col_old_val := to_char(p_old.LINKED_ABSENCE_ID);
                 l_col_new_val := to_char(p_new.LINKED_ABSENCE_ID);
                 --
              elsif l_column = 'MATERNITY_ID' then
                 --
                 l_col_old_val := to_char(p_old.MATERNITY_ID);
                 l_col_new_val := to_char(p_new.MATERNITY_ID);
                 --
              elsif l_column = 'OCCURRENCE' then
                 --
                 l_col_old_val := to_char(p_old.OCCURRENCE);
                 l_col_new_val := to_char(p_new.OCCURRENCE);
                 --
              end if;
              --
              populate_param_tab( 'BEN_ABA_IN_PERSON_ID',to_char(p_new.PERSON_ID));
              populate_param_tab('BEN_ABA_IN_PERSON_ID',to_char(p_new.PERSON_ID));
              populate_param_tab('BEN_ABA_IO_PERSON_ID',to_char(p_old.PERSON_ID));
              populate_param_tab('BEN_ABA_IN_DATE_START', to_char(p_new.DATE_START, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IO_DATE_START', to_char(p_old.DATE_START, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IN_DATE_END', to_char(p_new.DATE_END, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IO_DATE_END', to_char(p_old.DATE_END, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IN_ABSENCE_ATTENDANCE_TYPE_ID',
              to_char(p_new.ABSENCE_ATTENDANCE_TYPE_ID));
              populate_param_tab('BEN_ABA_IO_ABSENCE_ATTENDANCE_TYPE_ID',
              to_char(p_old.ABSENCE_ATTENDANCE_TYPE_ID));
              populate_param_tab('BEN_ABA_IN_ABS_ATTENDANCE_REASON_ID',
              to_char(p_new.ABS_ATTENDANCE_REASON_ID));
              populate_param_tab('BEN_ABA_IO_ABS_ATTENDANCE_REASON_ID',
              to_char(p_old.ABS_ATTENDANCE_REASON_ID));
              populate_param_tab('BEN_ABA_IN_SICKNESS_START_DATE',
              to_char(p_new.SICKNESS_START_DATE, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IO_SICKNESS_START_DATE',
              to_char(p_old.SICKNESS_START_DATE, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IN_SICKNESS_END_DATE',
              to_char(p_new.SICKNESS_END_DATE, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IO_SICKNESS_END_DATE',
              to_char(p_old.SICKNESS_END_DATE, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IN_ABSENCE_DAYS', to_char(p_new.ABSENCE_DAYS));
              populate_param_tab('BEN_ABA_IO_ABSENCE_DAYS', to_char(p_old.ABSENCE_DAYS));
              populate_param_tab('BEN_ABA_IN_ABSENCE_HOURS', to_char(p_new.ABSENCE_HOURS));
              populate_param_tab('BEN_ABA_IO_ABSENCE_HOURS', to_char(p_old.ABSENCE_HOURS));
              populate_param_tab('BEN_ABA_IN_DATE_NOTIFICATION',
              to_char(p_new.DATE_NOTIFICATION, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IO_DATE_NOTIFICATION',
              to_char(p_old.DATE_NOTIFICATION, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IN_DATE_PROJECTED_END',
              to_char(p_new.DATE_PROJECTED_END, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IO_DATE_PROJECTED_END',
              to_char(p_old.DATE_PROJECTED_END, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IN_DATE_PROJECTED_START',
              to_char(p_new.DATE_PROJECTED_START, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IO_DATE_PROJECTED_START',
              to_char(p_old.DATE_PROJECTED_START, 'YYYY/MM/DD HH24:MI:SS'));
              populate_param_tab('BEN_ABA_IN_TIME_END', p_new.TIME_END);
              populate_param_tab('BEN_ABA_IO_TIME_END', p_old.TIME_END);
              populate_param_tab('BEN_ABA_IN_TIME_PROJECTED_END', p_new.TIME_PROJECTED_END);
              populate_param_tab('BEN_ABA_IO_TIME_PROJECTED_END', p_old.TIME_PROJECTED_END);
              populate_param_tab('BEN_ABA_IN_TIME_PROJECTED_START', p_new.TIME_PROJECTED_START);
              populate_param_tab('BEN_ABA_IO_TIME_PROJECTED_START', p_old.TIME_PROJECTED_START);
              populate_param_tab('BEN_LER_ID', to_char(l_ler_id));
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION_CATEGORY', p_new.abs_information_category);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION1', p_new.abs_information1);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION2', p_new.abs_information2);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION3', p_new.abs_information3);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION4', p_new.abs_information4);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION5', p_new.abs_information5);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION6', p_new.abs_information6);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION7', p_new.abs_information7);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION8', p_new.abs_information8);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION9', p_new.abs_information9);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION10', p_new.abs_information10);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION11', p_new.abs_information11);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION12', p_new.abs_information12);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION13', p_new.abs_information13);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION14', p_new.abs_information14);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION15', p_new.abs_information15);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION16', p_new.abs_information16);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION17', p_new.abs_information17);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION18', p_new.abs_information18);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION19', p_new.abs_information19);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION20', p_new.abs_information20);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION21', p_new.abs_information21);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION22', p_new.abs_information22);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION23', p_new.abs_information23);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION24', p_new.abs_information24);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION25', p_new.abs_information25);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION26', p_new.abs_information26);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION27', p_new.abs_information27);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION28', p_new.abs_information28);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION29', p_new.abs_information29);
              populate_param_tab('BEN_ABA_IN_ABS_INFORMATION30', p_new.abs_information30);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE_CATEGORY', p_new.attribute_category);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE1', p_new.attribute1);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE2', p_new.attribute2);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE3', p_new.attribute3);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE4', p_new.attribute4);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE5', p_new.attribute5);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE6', p_new.attribute6);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE7', p_new.attribute7);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE8', p_new.attribute8);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE9', p_new.attribute9);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE10', p_new.attribute10);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE11', p_new.attribute11);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE12', p_new.attribute12);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE13', p_new.attribute13);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE14', p_new.attribute14);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE15', p_new.attribute15);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE16', p_new.attribute16);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE17', p_new.attribute17);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE18', p_new.attribute18);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE19', p_new.attribute19);
              populate_param_tab('BEN_ABA_IN_ATTRIBUTE20', p_new.attribute20);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION_CATEGORY', p_old.abs_information_category);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION1', p_old.abs_information1);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION2', p_old.abs_information2);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION3', p_old.abs_information3);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION4', p_old.abs_information4);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION5', p_old.abs_information5);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION6', p_old.abs_information6);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION7', p_old.abs_information7);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION8', p_old.abs_information8);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION9', p_old.abs_information9);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION10', p_old.abs_information10);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION11', p_old.abs_information11);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION12', p_old.abs_information12);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION13', p_old.abs_information13);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION14', p_old.abs_information14);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION15', p_old.abs_information15);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION16', p_old.abs_information16);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION17', p_old.abs_information17);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION18', p_old.abs_information18);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION19', p_old.abs_information19);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION20', p_old.abs_information20);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION21', p_old.abs_information21);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION22', p_old.abs_information22);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION23', p_old.abs_information23);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION24', p_old.abs_information24);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION25', p_old.abs_information25);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION26', p_old.abs_information26);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION27', p_old.abs_information27);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION28', p_old.abs_information28);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION29', p_old.abs_information29);
              populate_param_tab('BEN_ABA_IO_ABS_INFORMATION30', p_old.abs_information30);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE_CATEGORY', p_old.attribute_category);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE1', p_old.attribute1);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE2', p_old.attribute2);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE3', p_old.attribute3);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE4', p_old.attribute4);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE5', p_old.attribute5);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE6', p_old.attribute6);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE7', p_old.attribute7);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE8', p_old.attribute8);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE9', p_old.attribute9);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE10', p_old.attribute10);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE11', p_old.attribute11);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE12', p_old.attribute12);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE13', p_old.attribute13);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE14', p_old.attribute14);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE15', p_old.attribute15);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE16', p_old.attribute16);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE17', p_old.attribute17);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE18', p_old.attribute18);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE19', p_old.attribute19);
              populate_param_tab('BEN_ABA_IO_ATTRIBUTE20', p_old.attribute20);

              benutils.exec_rule
              (p_formula_id        => l_per_info_chg_cs_ler_rl,
               p_effective_date    => l_session_date,
               p_lf_evt_ocrd_dt    => null,
               p_business_group_id => nvl(p_new.business_group_id,p_old.business_group_id),
               p_person_id         => nvl(p_new.person_id, p_old.person_id),
               p_new_value         => l_col_new_val,
               p_old_value         => l_col_old_val,
               p_column_name       => l_column,
               p_ret_val           => l_rule_output,
               p_param_tab         => g_param_tab,
               p_pk_id             => to_char(nvl(p_new.absence_attendance_id,p_old.absence_attendance_id)));
              g_param_tab.delete;
              --
              --If there is no rule attached, proceed with normal processing
	    else
	      --
	      l_leg_code := hr_api.return_legislation_code(nvl(p_new.business_group_id,p_old.business_group_id));
	      if l_leg_code = 'GB' then
                --
	        gb_abs_life_event_rule
	        (p_absence_event_type              =>  l_lf_evt_oper_cd,
	         p_new_date_start                  =>  nvl(to_char(p_new.DATE_START, 'YYYY/MM/DD HH24:MI:SS'), '12/31/4712'),
                 p_old_date_start                  =>  nvl(to_char(p_old.DATE_START, 'YYYY/MM/DD HH24:MI:SS'), '12/31/4712'),
	         p_new_date_end                    =>  nvl(to_char(p_new.DATE_END, 'YYYY/MM/DD HH24:MI:SS'), '12/31/4712'),
                 p_old_date_end                    =>  nvl(to_char(p_old.DATE_END, 'YYYY/MM/DD HH24:MI:SS'), '12/31/4712'),
    	         p_new_abs_attendance_type_id      =>  nvl(to_char(p_new.ABSENCE_ATTENDANCE_TYPE_ID), '_DEFAULT_'),
  	         p_old_abs_attendance_type_id      =>  nvl(to_char(p_old.ABSENCE_ATTENDANCE_TYPE_ID), '_DEFAULT_'),
                 p_new_abs_information1            =>  nvl(p_new.abs_information1, '_DEFAULT_'),
                 p_old_abs_information1            =>  nvl(p_old.abs_information1, '_DEFAULT_'),
                 p_new_abs_information2            =>  nvl(p_new.abs_information2, '_DEFAULT_'),
                 p_old_abs_information2            =>  nvl(p_old.abs_information2, '_DEFAULT_'),
                 p_new_abs_information4            =>  nvl(p_new.abs_information4, '12/31/4712'),
                 p_old_abs_information4            =>  nvl(p_old.abs_information4, '12/31/4712'),
                 p_new_abs_information5            =>  nvl(p_new.abs_information5, '12/31/4712'),
                 p_old_abs_information5            =>  nvl(p_old.abs_information5, '12/31/4712'),
                 p_new_abs_information6            =>  nvl(p_new.abs_information6, '_DEFAULT_'),
                 p_old_abs_information6            =>  nvl(p_old.abs_information6, '_DEFAULT_'),
		 p_ret_val                         =>  l_rule_output
	        );
                --
	      end if;
              --
            end if;
            --
            -- ABSENCES
            -- If the rule returns Y then override the columns data changed or not
            -- for absences. Also attch the profile value check.
            --
            --  if l_absences_rule_output = 'N' and l_rule_output = 'Y'  and l_typ_cd = 'ABS'
            --  then
            --     l_absences_rule_output := l_rule_output;
            --
            --  end if;
            -- Commented during Multiple Table LE Triggering enhancement
            --
            if l_rule_output = 'Y' then
              --
              if l_column = 'ABSENCE_ATTENDANCE_TYPE_ID' then
                --
                l_changed :=
                  (benutils.column_changed
                     (p_old.absence_attendance_type_id,
                      p_new.absence_attendance_type_id,
                      l_new_val) and
                   benutils.column_changed
                     (p_new.absence_attendance_type_id,
                     p_old.absence_attendance_type_id,
                      l_old_val) and
                     (l_changed));
                --
              end if;
              --
              if l_column = 'ABS_ATTENDANCE_REASON_ID' then
                --
                -- We need to decode the absence_attendance_reasons back
                -- to lookup values.
                --
                l_changed :=
                  (benutils.column_changed
                    (decode_reason(p_old.abs_attendance_reason_id),
                     decode_reason(p_new.abs_attendance_reason_id),
                     l_new_val) and
                   benutils.column_changed
                    (decode_reason(p_new.abs_attendance_reason_id),
                     decode_reason(p_old.abs_attendance_reason_id),
                     l_old_val) and (l_changed));
                --
              end if;
              --
              if l_column = 'DATE_START' then
                --
                hr_utility.set_location(' Inside Date start ben_abs_trigger', 52);
                l_changed :=
                  (benutils.column_changed
                    (p_old.date_start,
                     p_new.date_start,
                     l_new_val) and
                   benutils.column_changed
                    (p_new.date_start,
                     p_old.date_start,
                     l_old_val) and (l_changed))or -- added here for bug 6895974
		     (benutils.column_changed
                    (p_old.abs_information1,
                     p_new.abs_information1,
                     l_new_val) and
                   benutils.column_changed
                    (p_new.abs_information1,
                     p_old.abs_information1,
                     l_old_val) and (l_changed))or
		     (benutils.column_changed
                    (p_old.abs_information2,
                     p_new.abs_information2,
                     l_new_val) and
                   benutils.column_changed
                    (p_new.abs_information2,
                     p_old.abs_information2,
                     l_old_val) and (l_changed))or
		     (benutils.column_changed
                    (p_old.abs_information4,
                     p_new.abs_information4,
                     l_new_val) and
                   benutils.column_changed
                    (p_new.abs_information4,
                     p_old.abs_information4,
                     l_old_val) and (l_changed))or
		     (benutils.column_changed
                    (p_old.abs_information5,
                     p_new.abs_information5,
                     l_new_val) and
                   benutils.column_changed
                    (p_new.abs_information5,
                     p_old.abs_information5,
                     l_old_val) and (l_changed))or
		     (benutils.column_changed
                    (p_old.abs_information6,
                     p_new.abs_information6,
                     l_new_val) and
                   benutils.column_changed
                    (p_new.abs_information6,
                     p_old.abs_information6,
                     l_old_val) and (l_changed)); -- added till here for bug 6895974
                --
              end if;
              --
              if l_column = 'DATE_END' then
                --
                l_changed :=
                  (benutils.column_changed
                    (p_old.date_end,
                     p_new.date_end,
                     l_new_val) and
                   benutils.column_changed
                    (p_new.date_end,
                     p_old.date_end,
                     l_old_val) and (l_changed));
                --
                if l_ocrd_dt_cd is null then
                  --
                  l_lf_evt_ocrd_date := l_date_end;
                  --
                else
                  --
                  --   Call the common date procedure.
                  --
                  ben_determine_date.main
                    (p_date_cd         => l_ocrd_dt_cd,
                     p_effective_date  => l_date_end,
                     p_lf_evt_ocrd_dt  => l_date_end,
                     p_returned_date   => l_lf_evt_ocrd_date);
                  --
                end if;
                --
              end if;
              --
           /* elsif l_rule_output = 'N' then
              --
              l_changed := FALSE;

              -- Commented during Multiple Table LE Triggering enhancement
              */
              --
            end if;
            --
            hr_utility.set_location(' ben_abs_trigger', 30);
            --
            l_ptnl_id := 0;
            l_ovn :=null;

            --
			       	-- Checking the rule output and the rule override flag.
				        	-- Whether the rule is mandatory or not, rule output should return 'Y'
				        	-- Rule Mandatory flag is just to override the column data change.


							hr_utility.set_location('l_rule_output = '|| l_rule_output, 20.01);


				        	if l_rule_output = 'Y' and l_rule_overrides_flag = 'Y' then
				        	  l_changed := TRUE ;
				        	elsif l_rule_output = 'Y' and l_rule_overrides_flag = 'N' then
				        	  l_changed := l_changed AND TRUE;
				        	elsif l_rule_output = 'N' then
				        	  l_changed := FALSE;
				        	  hr_utility.set_location(' Rule output is N, so we should not trigger LE', 20.01);
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
								l_trigger := TRUE;
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



            --
            -- ABSENCES
            -- For absence life events even if a formula is returns Y then create
            -- life events also add profile
            --
            if l_trigger  -- or (l_typ_cd = 'ABS' and l_absences_rule_output = 'Y')
            then
              --
              if l_type = 'P' then
                --
                l_trgr_table_pk_id := nvl(p_new.absence_attendance_id,p_old.absence_attendance_id);
                open le_exists(nvl(p_new.person_id,p_old.person_id),l_ler_id,l_lf_evt_ocrd_date,l_trgr_table_pk_id);
                  --
                  fetch le_exists into l_le_exists;
                  --
                  if le_exists%notfound then
                    --
                    hr_utility.set_location(' Entering: ben_abs_trigger5', 60);
                    --
                    ben_create_ptnl_ler_for_per.create_ptnl_ler_event
                    --ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
                      (p_validate                 => false
                      ,p_ptnl_ler_for_per_id      => l_ptnl_id
                      ,p_ntfn_dt                  => l_system_date
                      ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_date
                      ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
                      ,p_ler_id                   => l_ler_id
                      ,p_ler_typ_cd               => l_typ_cd
                      ,p_person_id                => nvl(p_new.person_id,p_old.person_id)
                      ,p_business_group_Id        => nvl(p_new.business_group_id,p_old.business_group_id)
                      -- ABSENCES
                      ,p_trgr_table_pk_id         => l_trgr_table_pk_id
                      ,p_object_version_number    => l_ovn
                      ,p_effective_date           => l_effective_start_date
                      ,p_dtctd_dt                 => l_effective_start_date);
                    --
                  end if;
                  --
                close le_exists;
                --
              elsif l_type = 'R' then
                --
                hr_utility.set_location(' Entering: ben_abs_trigger5-', 65);
                --
                open get_contacts(nvl(p_new.person_id,p_old.person_id));
                  --
                  loop
                    --
                    fetch get_contacts into l_hld_person_id;
                    exit when get_contacts%notfound;
                    --
                    open le_exists(l_hld_person_id,l_ler_id,l_lf_evt_ocrd_date,null);
                      --
                      fetch le_exists into l_le_exists;
                      --
                      if le_exists%notfound then
                        --
                        hr_utility.set_location('Entering: ben_abs_trigger5', 60);
                        --
                        ben_create_ptnl_ler_for_per.create_ptnl_ler_event
                        --ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
                          (p_validate                 => false
                          ,p_ptnl_ler_for_per_id      => l_ptnl_id
                          ,p_ntfn_dt                  => l_system_date
                          ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_date
                          ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
                          ,p_ler_id                   => l_ler_id
                          ,p_ler_typ_cd               => l_typ_cd
                          ,p_person_id                => l_hld_person_id
                          ,p_business_group_Id        => nvl(p_new.business_group_id,p_old.business_group_id)
                          ,p_object_version_number    => l_ovn
                          ,p_effective_date           => l_effective_start_date
                          ,p_dtctd_dt                 => l_effective_start_date);
                        --
                      end if;
                      --
                      l_ptnl_id := 0;
                      l_ovn :=null;
                      --
                    close le_exists;
                    --
                  end loop;
                  --
                close get_contacts;
                --
              end if;
              --
              -- reset the variables.
              --
              hr_utility.set_location(' ben_abs_trigger', 40);
              --
              l_changed   := FALSE;
              l_ovn       := NULL;
              l_effective_start_date := l_session_date;
              -- l_lf_evt_ocrd_date := l_session_date;
            end if;
            --
          end loop;
          --
        close get_ler_col;
        --
      end if;
      --
    end loop;
    --
    hr_utility.set_location('  ben_abs_trigger', 50);
    --
    close get_ler;
    --
    hr_utility.set_location('  leaving ben_abs_trigger', 70);
--    hr_utility.trace_off;
end;
--
end ben_abs_ler;


/
