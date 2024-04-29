--------------------------------------------------------
--  DDL for Package Body BEN_CON_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CON_LER" as
/* $Header: becontrg.pkb 120.3.12010000.4 2009/11/16 13:50:41 sallumwa ship $*/

-- Start Fix 4911130
g_param_tab ff_exec.outputs_t;

procedure populate_param_tab
(p_name in varchar2,
 p_value in varchar2) is
 l_next_index number;
begin
  l_next_index := nvl(g_param_tab.count,0) + 1;
  g_param_tab(l_next_index).name := p_name;
  g_param_tab(l_next_index).value := p_value;
end;
-- End Fix 4911130

procedure ler_chk(p_old IN g_con_ler_rec
                 ,p_new IN g_con_ler_rec
                 ,p_effective_date in date ) is
--
l_proc varchar2(100) := 'ben_con_ler.ler_chk';
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
 ,      ler.effective_start_date   -- Added for bug 3105696
 from   ben_ler_f ler
 where  ler.business_group_id               = p_new.business_group_id
 and ( l_status = 'I' or ler.typ_cd in ('COMP','GSP','ABS','CHECKLIST') )
 and    l_session_date
        between ler.effective_start_date
        and     ler.effective_end_date
 and    ((exists
        (select 1
          from   ben_per_info_chg_cs_ler_f psl
          ,      ben_ler_per_info_cs_ler_f lpl
          where  source_table               = 'PER_CONTACT_RELATIONSHIPS'
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
           where  source_table               = 'PER_CONTACT_RELATIONSHIPS'
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
and source_table = 'PER_CONTACT_RELATIONSHIPS'
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
and source_table = 'PER_CONTACT_RELATIONSHIPS'
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

cursor get_person_date(p_person_id in number) is
select min(effective_start_date) -- 3518038
from per_all_people_f
where person_id = p_person_id
and business_group_id = p_new.business_group_id;
--Bug 2206932 (always using the system date as user can start relationship before
--before the person is started.
/*and l_system_date between effective_start_date
and effective_end_date; */ -- commented for 3518038

l_changed BOOLEAN;
l_ler_id NUMBER;
l_typ_cd ben_ler_f.typ_cd%type ;
l_column ben_rltd_per_chg_cs_ler_f.source_column%type;  -- VARCHAR2(30);
l_new_val ben_rltd_per_chg_cs_ler_f.new_val%type;   -- VARCHAR2(30);
l_old_val ben_rltd_per_chg_cs_ler_f.old_val%type;       -- VARCHAR2(30);
l_ocrd_dt_cd VARCHAR2(30);
l_per_info_chg_cs_ler_rl number;
l_rule_output VARCHAR2(1);
l_ovn NUMBER;
l_ptnl_id NUMBER;
l_effective_end_date DATE := to_date('31-12-4712','DD-MM-YYYY');
l_effective_start_date DATE ;
l_dtctd_dt DATE ;
l_person_esd DATE := null;
l_lf_evt_ocrd_date DATE ;
l_le_exists VARCHAR2(1);
l_mnl_dt date;
l_procd_dt   date;
l_unprocd_dt date;
l_voidd_dt   date;
l_type    VARCHAR2(1);
l_date_start date;
l_date_end date;
--l_hld_person_id NUMBER;
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
-- added these two variables as part of bug 3105696
l_flag boolean:=FALSE;
l_initial_date DATE;
l_ler_eff_strt_dt DATE;
--
cursor c_per_type (p_person_id in per_all_people_f.person_id%TYPE )is
select con.system_person_type
from   per_all_people_f per , per_person_types con
where  per.person_id = p_person_id
and    per.person_type_id = con.person_type_id
and    l_session_date between per.effective_start_date and per.effective_end_date ;
--
l_per_type     per_person_types.system_person_type%TYPE ;
l_con_per_type per_person_types.system_person_type%TYPE ;
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
 l_bool :=fnd_installation.get(appl_id => 805
                   ,dep_appl_id =>805
                   ,status => l_status
                   ,industry => l_industry);

  hr_utility.set_location(' Entering: '||l_proc, 10);
  l_changed := FALSE;

  If p_effective_date is not null then
     l_initial_date := p_effective_date ;
    -- Modified for bug 3105696.
    -- If end date is specified then, consider the end date
    -- We need to consider the end date only when its entered fresh.
     If p_new.date_end is not null then
     	l_session_date:= p_new.date_end;
     else
        l_session_date := p_effective_date ;
     end if;
   -- End of Bug 3105696
  else
     open get_session_date;
     fetch get_session_date into l_session_date;
     close get_session_date;
     l_initial_date := l_session_date;
  end if ;
  open get_system_date;
  fetch get_system_date into l_system_date;
  close get_system_date;

  -- Bug 3105696
  -- l_session_date is used to fetch the valid LEs. storing the l_session_date temporarily
  -- so that we can use it later to check whether the LE is valid

  -- Bug 3105696

  l_effective_start_date := l_session_date;

  hr_utility.set_location(l_proc, 20);
  hr_utility.set_location('CONTACT PERSON '||p_new.contact_person_id, 20);
  hr_utility.set_location('PERSON '||p_new.person_id, 20);
  hr_utility.set_location('BG '||p_new.business_group_id, 20);

  -- in some situations the date we use for occured on date is null,
  -- use session date instead.
  if p_new.date_start is null then
     l_date_start := l_session_date;
  else
     l_date_start := p_new.date_start;
  end if;

  if p_new.date_end is null then
     l_date_end := l_session_date;
  else
     l_date_end := p_new.date_end;
  end if;

  -- the lf evt occurred date cannot be less than the date the person rec was created.
  open get_person_date(p_person_id => p_new.person_id); -- modified for bug 3105696
  fetch get_person_date into l_person_esd;
  close get_person_date;

  --
  if l_date_start < nvl(l_person_esd, l_date_start) then
     l_date_start := l_person_esd;
  end if;
  -- Bug 2206932
  if l_effective_start_date < nvl(l_person_esd, l_date_start) then
    --
    l_effective_start_date := nvl(l_person_esd, l_date_start) ;
    --
  end if;
  --
  hr_utility.set_location(' l_person_esd:'||to_char(l_person_esd), 30);
  hr_utility.set_location(' l_date_start:'||to_char(l_date_start), 30);
  hr_utility.set_location(' l_system_date:'||to_char(l_system_date), 30);
  hr_utility.set_location(' l_session_date:'||to_char(l_session_date), 30);
  hr_utility.set_location('l_initial_date:'||to_char(l_initial_date), 30);
  hr_utility.set_location('l_effective_start_date: '||to_char(l_effective_start_date),30);
  --
  open get_ler(l_status);
  loop
    fetch get_ler into l_ler_id,l_typ_cd, l_ocrd_dt_cd, l_ler_eff_strt_dt;
    exit when get_ler%notfound;
           l_trigger := TRUE;

    if l_ocrd_dt_cd is null then
      l_lf_evt_ocrd_date := l_date_start;
    else
      --
      --   Call the common date procedure.
      --
      ben_determine_date.main
        (p_date_cd         => l_ocrd_dt_cd
        ,p_effective_date  => l_date_start
        ,p_lf_evt_ocrd_dt  => p_new.date_start
        ,p_returned_date   => l_lf_evt_ocrd_date
         );
    end if;

    hr_utility.set_location(' l_lf_evt_ocrd_date ' ||l_lf_evt_ocrd_date, 95);
    hr_utility.set_location(' l_effective_start_date ' ||l_effective_start_date, 95);
    hr_utility.set_location(' l_dtctd_dt ' ||l_dtctd_dt, 95);
    hr_utility.set_location(' l_ler_eff_strt_dt ' ||l_ler_eff_strt_dt, 95);

    open get_ler_col(l_ler_id);
    loop
      fetch get_ler_col into l_column,l_new_val, l_old_val, l_type, l_per_info_chg_cs_ler_rl, l_rule_overrides_flag, l_chg_mandatory_cd;
      exit when get_ler_col%NOTFOUND;
      hr_utility.set_location('LER '||l_ler_id, 40);
      hr_utility.set_location('COLUMN '||l_column, 40);
      hr_utility.set_location('NEWVAL '||l_new_val, 40);
      hr_utility.set_location('OLDVAL '||l_old_val, 40);
      hr_utility.set_location('TYPE '||l_type, 40);
      --l_changed := TRUE; -- Bug 6219676 -- No need of this
      if get_ler_col%ROWCOUNT = 1 then
         hr_utility.set_location('rowcount 1 ', 50);
        l_changed := TRUE;
      end if;

      --      Due to mirroring this will avoid ptnl  being written for both
      --      prtt and contact

--      if p_new.contact_person_id < p_new.person_id then -- Bug 6219676
      --
      -- Bug - 1809612  added code to ensure that ptnl LE gets created for contact who is also an employee.
      -- Also the ptnl LE should not get created for contacts who are not EMP , EMP_APL .
      --
      -- hr_utility.set_location('Mirror - disregard ', 60);
      -- l_changed := FALSE;
      --
      --
         open c_per_type (p_new.contact_person_id );
         fetch c_per_type into l_con_per_type;
         close c_per_type ;
         --
         hr_utility.set_location('person type '||l_con_per_type||'PER'||l_per_type, 52);
         if l_con_per_type in ( 'EMP' , 'EMP_APL', 'EX_EMP')  -- Added ex-employee for bug 7113467
         then
	  --
	       open c_per_type (p_new.person_id );
               fetch c_per_type into l_per_type;
	       close c_per_type ;
             --
             if l_per_type in ( 'EMP' , 'EMP_APL', 'EX_EMP') ----------Bug 9020324
             then
	         hr_utility.set_location('person type '||l_per_type , 55);
                 l_changed := TRUE;
             else
	         hr_utility.set_location('Mirror - disregard ', 57);
                 l_changed := FALSE;
             end if;
         else
	     hr_utility.set_location('Mirror - disregard ', 60);
             l_changed := l_changed AND TRUE; -- Bug 6219676
         end if ;
         -- bug - 1809612
--      end if;

      hr_utility.set_location(l_proc, 70);

      --
      -- Call the formula here to evaluate per_info_chg_cs_ler_rl.
      -- If it returns Y, then see the applicability of the data
      -- changes based on new and old values.
      --
      l_rule_output := 'Y';
      --
      if l_per_info_chg_cs_ler_rl is not null then

         if l_column = 'PERSON_ID' then
            l_col_old_val := to_char(p_old.PERSON_ID);
            l_col_new_val := to_char(p_new.PERSON_ID);
         end if;
         --
         if l_column = 'CONTACT_PERSON_ID' then
            l_col_old_val := to_char(p_old.CONTACT_PERSON_ID);
            l_col_new_val := to_char(p_new.CONTACT_PERSON_ID);
         end if;
         --
         if l_column = 'DATE_START' then
            l_col_old_val := to_char(p_old.DATE_START,  'YYYY/MM/DD HH24:MI:SS');
            l_col_new_val := to_char(p_new.DATE_START,  'YYYY/MM/DD HH24:MI:SS');
         end if;
         --
         if l_column = 'DATE_END' then
            l_col_old_val := to_char(p_old.DATE_END,  'YYYY/MM/DD HH24:MI:SS');
            l_col_new_val := to_char(p_new.DATE_END,  'YYYY/MM/DD HH24:MI:SS');
         end if;
         --
         if l_column = 'CONTACT_TYPE' then
            l_col_old_val := p_old.CONTACT_TYPE;
            l_col_new_val := p_new.CONTACT_TYPE;
         end if;
         --
         if l_column = 'PERSONAL_FLAG' then
            l_col_old_val := p_old.PERSONAL_FLAG;
            l_col_new_val := p_new.PERSONAL_FLAG;
         end if;
         --
         if l_column = 'START_LIFE_REASON_ID' then
            l_col_old_val := to_char(p_old.START_LIFE_REASON_ID);
            l_col_new_val := to_char(p_new.START_LIFE_REASON_ID);
         end if;
         --
         if l_column = 'END_LIFE_REASON_ID' then
            l_col_old_val := to_char(p_old.END_LIFE_REASON_ID);
            l_col_new_val := to_char(p_new.END_LIFE_REASON_ID);
         end if;
         --
         if l_column = 'RLTD_PER_RSDS_W_DSGNTR_FLAG' then
            l_col_old_val := p_old.RLTD_PER_RSDS_W_DSGNTR_FLAG;
            l_col_new_val := p_new.RLTD_PER_RSDS_W_DSGNTR_FLAG;
         end if;
         --
         -- Bug 1772037 fix
         --
         if l_column = 'CONT_ATTRIBUTE1' then
            l_col_old_val := p_old.CONT_ATTRIBUTE1;
            l_col_new_val := p_new.CONT_ATTRIBUTE1;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE2' then
            l_col_old_val := p_old.CONT_ATTRIBUTE2;
            l_col_new_val := p_new.CONT_ATTRIBUTE2;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE3' then
            l_col_old_val := p_old.CONT_ATTRIBUTE3;
            l_col_new_val := p_new.CONT_ATTRIBUTE3;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE4' then
            l_col_old_val := p_old.CONT_ATTRIBUTE4;
            l_col_new_val := p_new.CONT_ATTRIBUTE4;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE5' then
            l_col_old_val := p_old.CONT_ATTRIBUTE5;
            l_col_new_val := p_new.CONT_ATTRIBUTE5;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE6' then
            l_col_old_val := p_old.CONT_ATTRIBUTE6;
            l_col_new_val := p_new.CONT_ATTRIBUTE6;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE7' then
            l_col_old_val := p_old.CONT_ATTRIBUTE7;
            l_col_new_val := p_new.CONT_ATTRIBUTE7;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE8' then
            l_col_old_val := p_old.CONT_ATTRIBUTE8;
            l_col_new_val := p_new.CONT_ATTRIBUTE8;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE9' then
            l_col_old_val := p_old.CONT_ATTRIBUTE9;
            l_col_new_val := p_new.CONT_ATTRIBUTE9;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE10' then
            l_col_old_val := p_old.CONT_ATTRIBUTE10;
            l_col_new_val := p_new.CONT_ATTRIBUTE10;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE11' then
            l_col_old_val := p_old.CONT_ATTRIBUTE11;
            l_col_new_val := p_new.CONT_ATTRIBUTE11;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE12' then
            l_col_old_val := p_old.CONT_ATTRIBUTE12;
            l_col_new_val := p_new.CONT_ATTRIBUTE12;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE13' then
            l_col_old_val := p_old.CONT_ATTRIBUTE13;
            l_col_new_val := p_new.CONT_ATTRIBUTE13;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE14' then
            l_col_old_val := p_old.CONT_ATTRIBUTE14;
            l_col_new_val := p_new.CONT_ATTRIBUTE14;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE15' then
            l_col_old_val := p_old.CONT_ATTRIBUTE15;
            l_col_new_val := p_new.CONT_ATTRIBUTE15;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE16' then
            l_col_old_val := p_old.CONT_ATTRIBUTE16;
            l_col_new_val := p_new.CONT_ATTRIBUTE16;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE17' then
            l_col_old_val := p_old.CONT_ATTRIBUTE17;
            l_col_new_val := p_new.CONT_ATTRIBUTE17;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE18' then
            l_col_old_val := p_old.CONT_ATTRIBUTE18;
            l_col_new_val := p_new.CONT_ATTRIBUTE18;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE19' then
            l_col_old_val := p_old.CONT_ATTRIBUTE19;
            l_col_new_val := p_new.CONT_ATTRIBUTE19;
         end if;
         --
         if l_column = 'CONT_ATTRIBUTE20' then
            l_col_old_val := p_old.CONT_ATTRIBUTE20;
            l_col_new_val := p_new.CONT_ATTRIBUTE20;
         end if;
         --
         -- End fix 1772037
         --

	 -- Start Fix 4911130
         hr_utility.set_location('Populating the g_param_tab', 66);
	 populate_param_tab('BEN_CON_IN_PERSON_ID',  to_char(p_new.PERSON_ID));
         populate_param_tab('BEN_CON_IN_CONTACT_PERSON_ID', to_char(p_new.CONTACT_PERSON_ID));
         populate_param_tab('BEN_CON_IN_DATE_START', to_char(p_new.DATE_START, 'YYYY/MM/DD HH24:MI:SS'));
         populate_param_tab('BEN_CON_IN_DATE_END', to_char(p_new.DATE_END, 'YYYY/MM/DD HH24:MI:SS'));
         populate_param_tab('BEN_CON_IN_CONTACT_TYPE', p_new.CONTACT_TYPE);
         populate_param_tab('BEN_CON_IN_PERSONAL_FLAG', p_new.PERSONAL_FLAG);
         populate_param_tab('BEN_CON_IN_START_LIFE_REASON_ID', to_char(p_new.START_LIFE_REASON_ID));
         populate_param_tab('BEN_CON_IN_END_LIFE_REASON_ID', to_char(p_new.END_LIFE_REASON_ID));
         populate_param_tab('BEN_CON_IN_RLTD_PER_RSDS_W_DSGNTR_FLAG', p_new.RLTD_PER_RSDS_W_DSGNTR_FLAG);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE1', p_new.cont_attribute1);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE2', p_new.cont_attribute2);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE3', p_new.cont_attribute3);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE4', p_new.cont_attribute4);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE5', p_new.cont_attribute5);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE6', p_new.cont_attribute6);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE7', p_new.cont_attribute7);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE8', p_new.cont_attribute8);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE9', p_new.cont_attribute9);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE10', p_new.cont_attribute10);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE11', p_new.cont_attribute11);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE12', p_new.cont_attribute12);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE13', p_new.cont_attribute13);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE14', p_new.cont_attribute14);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE15', p_new.cont_attribute15);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE16', p_new.cont_attribute16);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE17', p_new.cont_attribute17);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE18', p_new.cont_attribute18);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE19', p_new.cont_attribute19);
         populate_param_tab('BEN_CON_IN_CONT_ATTRIBUTE20', p_new.cont_attribute20);
         populate_param_tab('BEN_CON_IO_PERSON_ID', to_char(p_old.PERSON_ID));
         populate_param_tab('BEN_CON_IO_CONTACT_PERSON_ID', to_char(p_old.CONTACT_PERSON_ID));
         populate_param_tab('BEN_CON_IO_DATE_START', to_char(p_old.DATE_START, 'YYYY/MM/DD HH24:MI:SS'));
         populate_param_tab('BEN_CON_IO_DATE_END', to_char(p_old.DATE_END, 'YYYY/MM/DD HH24:MI:SS'));
         populate_param_tab('BEN_CON_IO_CONTACT_TYPE', p_old.CONTACT_TYPE);
         populate_param_tab('BEN_CON_IO_PERSONAL_FLAG',  p_old.PERSONAL_FLAG);
         populate_param_tab('BEN_CON_IO_START_LIFE_REASON_ID', to_char(p_old.START_LIFE_REASON_ID));
         populate_param_tab('BEN_CON_IO_END_LIFE_REASON_ID', to_char(p_old.END_LIFE_REASON_ID));
         populate_param_tab('BEN_CON_IO_RLTD_PER_RSDS_W_DSGNTR_FLAG',  p_old.RLTD_PER_RSDS_W_DSGNTR_FLAG);
         populate_param_tab('BEN_CON_IO_START_LIFE_REASON_ID', to_char(p_old.START_LIFE_REASON_ID));
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE1', p_old.cont_attribute1);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE2', p_old.cont_attribute2);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE3', p_old.cont_attribute3);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE4', p_old.cont_attribute4);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE5', p_old.cont_attribute5);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE6', p_old.cont_attribute6);
	 populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE7', p_old.cont_attribute7);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE8', p_old.cont_attribute8);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE9', p_old.cont_attribute9);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE10', p_old.cont_attribute10);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE11', p_old.cont_attribute11);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE12', p_old.cont_attribute12);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE13', p_old.cont_attribute13);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE14', p_old.cont_attribute14);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE15', p_old.cont_attribute15);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE16', p_old.cont_attribute16);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE17', p_old.cont_attribute17);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE18', p_old.cont_attribute18);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE19', p_old.cont_attribute19);
         populate_param_tab('BEN_CON_IO_CONT_ATTRIBUTE20', p_old.cont_attribute20);
         populate_param_tab('BEN_IV_LER_ID', to_char(l_ler_id));
         hr_utility.set_location('Done Populating the g_param_tab', 66);
         -- End Fix 4911130

         benutils.exec_rule(
             p_formula_id        => l_per_info_chg_cs_ler_rl,
             p_effective_date    => l_session_date,
             p_lf_evt_ocrd_dt    => null,
             p_business_group_id => nvl(p_new.business_group_id, p_old.business_group_id),
             p_person_id         => nvl(p_new.person_id, p_old.person_id),
             p_new_value         => l_col_new_val,
             p_old_value         => l_col_old_val,
             p_column_name       => l_column,
             p_ret_val           => l_rule_output,
             p_param_tab         => g_param_tab,        /* Bug No 4911130 */
             p_pk_id             => to_char(p_new.contact_relationship_id));
         --
             g_param_tab.delete;                        /* Bug No 4911130 */
      end if;
      --

           --
           if l_column = 'DATE_START' then
              hr_utility.set_location('Old Start Date '||p_old.date_start,10);
              hr_utility.set_location('New Start  Date '||p_new.date_start,10);
              l_changed := (benutils.column_changed(p_old.date_start
                         ,p_new.date_start,l_new_val) AND
                            benutils.column_changed(p_new.date_start
                         ,p_old.date_start,l_old_val) AND
                         (l_changed));
              l_dtctd_dt := l_date_start;
           end if;

           if l_column = 'DATE_END' then
            l_changed := (benutils.column_changed(p_old.date_end
                        ,p_new.date_end,l_new_val)  AND
                          benutils.column_changed(p_new.date_end
                        ,p_old.date_end,l_old_val)  AND
                       (l_person_esd <= l_session_date) AND   -- Added for 3105696
                        (l_changed));
	hr_utility.set_location('      l_person_esd (DATE END) ' ||l_person_esd, 70);
	hr_utility.set_location('      l_session_date (DATE END) ' || l_session_date, 70);
            if l_ocrd_dt_cd is null then
             l_lf_evt_ocrd_date := l_date_end;
            else
              --
              --   Call the common date procedure.
              --
              ben_determine_date.main
                (p_date_cd         => l_ocrd_dt_cd
                ,p_effective_date  => l_date_end
                ,p_lf_evt_ocrd_dt  => p_new.date_end
                ,p_returned_date   => l_lf_evt_ocrd_date
                );
            end if;
            l_dtctd_dt := l_date_end;
          end if;

          if l_column = 'CONTACT_TYPE' then
            hr_utility.set_location('Old ConTYp '||p_old.contact_type, 80);
            hr_utility.set_location('New ConTYp '||p_new.contact_type, 80);
            l_changed := (benutils.column_changed(p_old.contact_type
                        ,p_new.contact_type,l_new_val)  AND
                          benutils.column_changed(p_new.contact_type
                        ,p_old.contact_type,l_old_val)  AND
                         (l_changed));
          end if;

          if l_column = 'PERSONAL_FLAG' then
            hr_utility.set_location('Old Per_flag '||p_old.personal_flag, 90);
            hr_utility.set_location('New Per_flag '||p_new.personal_flag, 90);
            l_changed := (benutils.column_changed(p_old.personal_flag
                        ,p_new.personal_flag,l_new_val)  AND
                          benutils.column_changed(p_new.personal_flag
                        ,p_old.personal_flag,l_old_val)  AND
                         (l_changed));
          end if;

          if l_column = 'START_LIFE_REASON_ID' then

	    l_changed := (benutils.column_changed(p_old.start_life_reason_id
                        ,p_new.start_life_reason_id,l_new_val)  AND
                          benutils.column_changed(p_new.start_life_reason_id
                        ,p_old.start_life_reason_id,l_old_val)  AND
                         (l_changed));
          end if;

          if l_column = 'END_LIFE_REASON_ID' then
            l_changed := (benutils.column_changed(p_old.end_life_reason_id
                        ,p_new.end_life_reason_id,l_new_val)  AND
                          benutils.column_changed(p_new.end_life_reason_id
                        ,p_old.end_life_reason_id,l_old_val)  AND
                        (l_person_esd <= l_session_date) AND   -- Added for 3105696
                         (l_changed));
	hr_utility.set_location('      l_person_esd (END_LIFE_REASON_ID) ' ||l_person_esd, 70);
	hr_utility.set_location('      l_session_date (END_LIFE_REASON_ID) ' || l_session_date, 70);
            if l_ocrd_dt_cd is null then
             l_lf_evt_ocrd_date := l_date_end;
            else
              --
              --   Call the common date procedure.
              --
              ben_determine_date.main
                (p_date_cd         => l_ocrd_dt_cd
                ,p_effective_date  => l_date_end
                ,p_lf_evt_ocrd_dt  => p_new.date_end
                ,p_returned_date   => l_lf_evt_ocrd_date
                );
            end if;
            l_dtctd_dt := l_date_end;
          end if;

          if l_column = 'RLTD_PER_RSDS_W_DSGNTR_FLAG' then
            l_changed := (benutils.column_changed(p_old.rltd_per_rsds_w_dsgntr_flag
                        ,p_new.rltd_per_rsds_w_dsgntr_flag,l_new_val) AND
                          benutils.column_changed(p_new.rltd_per_rsds_w_dsgntr_flag
                        ,p_old.rltd_per_rsds_w_dsgntr_flag,l_old_val) AND
                         (l_changed));
          end if;
          --

          --
          -- Bug 1772037 fix
          --
          if l_column = 'CONT_ATTRIBUTE1' then
            l_changed := (benutils.column_changed(p_old.cont_attribute1
                       ,p_new.cont_attribute1,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute1
                       ,p_old.cont_attribute1,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE2' then
            l_changed := (benutils.column_changed(p_old.cont_attribute2
                       ,p_new.cont_attribute2,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute2
                       ,p_old.cont_attribute2,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE3' then
            l_changed := (benutils.column_changed(p_old.cont_attribute3
                       ,p_new.cont_attribute3,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute3
                       ,p_old.cont_attribute3,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE4' then
            l_changed := (benutils.column_changed(p_old.cont_attribute4
                       ,p_new.cont_attribute4,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute4
                       ,p_old.cont_attribute4,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE5' then
            l_changed := (benutils.column_changed(p_old.cont_attribute5
                       ,p_new.cont_attribute5,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute5
                       ,p_old.cont_attribute5,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE6' then
            l_changed := (benutils.column_changed(p_old.cont_attribute6
                       ,p_new.cont_attribute6,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute6
                       ,p_old.cont_attribute6,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE7' then
            l_changed := (benutils.column_changed(p_old.cont_attribute7
                       ,p_new.cont_attribute7,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute7
                       ,p_old.cont_attribute7,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE8' then
            l_changed := (benutils.column_changed(p_old.cont_attribute8
                       ,p_new.cont_attribute8,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute8
                       ,p_old.cont_attribute8,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE9' then
            l_changed := (benutils.column_changed(p_old.cont_attribute9
                       ,p_new.cont_attribute9,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute9
                       ,p_old.cont_attribute9,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE10' then
            l_changed := (benutils.column_changed(p_old.cont_attribute10
                       ,p_new.cont_attribute10,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute10
                       ,p_old.cont_attribute10,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE11' then
            l_changed := (benutils.column_changed(p_old.cont_attribute11
                       ,p_new.cont_attribute11,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute11
                       ,p_old.cont_attribute11,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE12' then
            l_changed := (benutils.column_changed(p_old.cont_attribute12
                       ,p_new.cont_attribute12,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute12
                       ,p_old.cont_attribute12,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE13' then
            l_changed := (benutils.column_changed(p_old.cont_attribute13
                       ,p_new.cont_attribute13,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute13
                       ,p_old.cont_attribute13,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE14' then
            l_changed := (benutils.column_changed(p_old.cont_attribute14
                       ,p_new.cont_attribute14,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute14
                       ,p_old.cont_attribute14,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE15' then
            l_changed := (benutils.column_changed(p_old.cont_attribute15
                       ,p_new.cont_attribute15,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute15
                       ,p_old.cont_attribute15,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE16' then
            l_changed := (benutils.column_changed(p_old.cont_attribute16
                       ,p_new.cont_attribute16,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute16
                       ,p_old.cont_attribute16,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE17' then
            l_changed := (benutils.column_changed(p_old.cont_attribute17
                       ,p_new.cont_attribute17,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute17
                       ,p_old.cont_attribute17,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE18' then
            l_changed := (benutils.column_changed(p_old.cont_attribute18
                       ,p_new.cont_attribute18,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute18
                       ,p_old.cont_attribute18,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE19' then
            l_changed := (benutils.column_changed(p_old.cont_attribute19
                       ,p_new.cont_attribute19,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute19
                       ,p_old.cont_attribute19,l_old_val) AND
                         (l_changed));
          end if;
          --
          if l_column = 'CONT_ATTRIBUTE20' then
            l_changed := (benutils.column_changed(p_old.cont_attribute20
                       ,p_new.cont_attribute20,l_new_val) AND
                          benutils.column_changed(p_new.cont_attribute20
                       ,p_old.cont_attribute20,l_old_val) AND
                         (l_changed));
          end if;
          --

          -- Added for 3105696
          l_flag:=FALSE;
          if l_column in ('DATE_START','START_LIFE_REASON_ID') then
          	l_flag := TRUE;
          	hr_utility.set_location('Setting the flag true', 95);
          end if;

          -- End of 3105696


          -- End fix 1772037
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
      --
    end loop;


    -- Added for 3105696
    if l_flag then
              	--l_flag is true =>>DATE_START/START_LIFE_REASON_ID has been updated.
              	-- We should check whether the Life event getting triggered is
              	-- valid as of Effective start date of relationship

              	if l_ler_eff_strt_dt >= l_initial_date then
              	-- we should not trigger the LE
              	l_changed := FALSE;
              	hr_utility.set_location('Making flag False', 95);
              	end if;
    end if;
    -- End of 3105696


    hr_utility.set_location(  l_proc, 95);
    hr_utility.set_location(' l_lf_evt_ocrd_date ' ||l_lf_evt_ocrd_date, 95);
    hr_utility.set_location(' l_effective_start_date ' ||l_effective_start_date, 95);
    hr_utility.set_location(' l_dtctd_dt ' ||l_dtctd_dt, 95);
    l_ptnl_id := 0;
    l_ovn :=null;
    --
    if l_trigger then
      if l_type = 'P' then
        open le_exists(p_new.person_id,l_ler_id,l_lf_evt_ocrd_date);
        fetch le_exists into l_le_exists;
        if le_exists%notfound then
           hr_utility.set_location(l_proc, 96);
           ben_create_ptnl_ler_for_per.create_ptnl_ler_event
           ---ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
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
           ,p_dtctd_dt       => nvl(l_dtctd_dt, l_effective_start_date)
           );
        end if;
        close le_exists;
      elsif l_type = 'R' then
          hr_utility.set_location(l_proc, 97);
           open le_exists(p_new.contact_person_id,l_ler_id,l_lf_evt_ocrd_date);
           fetch le_exists into l_le_exists;
           if le_exists%notfound then
              hr_utility.set_location(l_proc, 98);

              ben_create_ptnl_ler_for_per.create_ptnl_ler_event
              ---ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
              (p_validate => false
              ,p_ptnl_ler_for_per_id => l_ptnl_id
              ,p_ntfn_dt => l_system_date
              ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_date
              ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
              ,p_ler_id => l_ler_id
              ,p_ler_typ_cd => l_typ_cd
              ,p_person_id => p_new.contact_person_id
              ,p_business_group_Id =>p_new.business_group_id
              ,p_object_version_number => l_ovn
              ,p_effective_date => l_effective_start_date
              ,p_dtctd_dt       => nvl(l_dtctd_dt, l_effective_start_date)
              );
           end if;
           l_ptnl_id := 0;
           l_ovn :=null;
           close le_exists;
      end if;
      --
      -- reset the variables.
      --
      hr_utility.set_location(l_proc, 99);
      l_changed   := FALSE;
      l_flag      := FALSE;
      l_trigger   := TRUE;
      l_ovn       := NULL;
    hr_utility.set_location(  l_proc, 95);
    --hr_utility.set_location(' l_lf_evt_ocrd_date ' ||l_lf_evt_ocrd_date, 95);
    --hr_utility.set_location(' l_effective_start_date ' ||l_effective_start_date, 95);
    --hr_utility.set_location(' l_dtctd_dt ' ||l_dtctd_dt, 95);
    --hr_utility.set_location(' l_session_date ' ||l_session_date, 95);

--      l_effective_start_date := l_session_date; Commented part of 3105696 bug fix
    --  hr_utility.set_location(' l_effective_start_date ' ||l_effective_start_date, 567);
      l_dtctd_dt  := null;
    end if;
    close get_ler_col;
  end loop;
  hr_utility.set_location(l_proc, 100);
  close get_ler;
  hr_utility.set_location('Leaving: '||l_proc, 999);
  --

end;
end ben_con_ler;

/
