--------------------------------------------------------
--  DDL for Package Body BEN_PPR_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PPR_LER" as
/* $Header: bepprtrg.pkb 120.0 2005/05/28 11:00:38 appldev noship $*/
procedure ler_chk(p_old IN g_ppr_ler_rec
                 ,p_new IN g_ppr_ler_rec
                 ,p_effective_date in date
            ) is
--
l_session_date DATE;

--
cursor get_session_date IS
select effective_date
from   fnd_sessions
where  session_id = userenv('SESSIONID');
--

cursor get_ler(l_status varchar2) is
 select ler.ler_id
 ,      ler.typ_cd
 ,      ler.ocrd_dt_det_cd
 from   ben_ler_f ler
 where
 ler.business_group_id               = p_new.business_group_id
 and l_session_date between ler.effective_start_date and ler.effective_end_date
 and ( l_status = 'I' or ler.typ_cd in ('COMP','GSP','ABS','CHECKLIST') )
 and
 ((exists
        (select 1
          from   ben_per_info_chg_cs_ler_f psl
          ,      ben_ler_per_info_cs_ler_f lpl
          where  source_table               = 'PER_PERFORMANCE_REVIEWS'
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
           where  source_table               = 'PER_PERFORMANCE_REVIEWS'
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

--
cursor get_ler_col(p_ler_id IN NUMBER) is
select psl.source_column
,      psl.new_val
,      psl.old_val
,      'P', psl.per_info_chg_cs_ler_rl, psl.rule_overrides_flag, lpl.chg_mandatory_cd
from   ben_ler_per_info_cs_ler_f lpl
,      ben_per_info_chg_cs_ler_f psl
where  lpl.ler_id                            = p_ler_id
and    lpl.business_group_id                 = p_new.business_group_id
and    lpl.business_group_id               = psl.business_group_id
and    l_session_date between
       psl.effective_start_date and    psl.effective_end_date
and    psl.per_info_chg_cs_ler_id            = lpl.per_info_chg_cs_ler_id
and    source_table                          = 'PER_PERFORMANCE_REVIEWS'
UNION
select rpc.source_column
,      rpc.new_val
,      rpc.old_val
,      'R', rpc.rltd_per_chg_cs_ler_rl per_info_chg_cs_ler, rpc.rule_overrides_flag, lrp.chg_mandatory_cd
from   ben_ler_rltd_per_cs_ler_f lrp
,      ben_rltd_per_chg_cs_ler_f rpc
where  lrp.ler_id = p_ler_id
and    lrp.business_group_id                 = p_new.business_group_id
and    lrp.business_group_id               = rpc.business_group_id
and    l_session_date between
       rpc.effective_start_date and    rpc.effective_end_date
and    rpc.rltd_per_chg_cs_ler_id            = lrp.rltd_per_chg_cs_ler_id
and    source_table                          = 'PER_PERFORMANCE_REVIEWS'
order by 1;
--
cursor le_exists(p_person_id in number
                ,p_ler_id in number
                ,p_lf_evt_ocrd_dt in date) is
select 'Y'
from   ben_ptnl_ler_for_per
where  person_id                             = p_person_id
and    ler_id                                = p_ler_id
and    ptnl_ler_for_per_stat_cd              = 'DTCTD'
and    lf_evt_ocrd_dt                        = p_lf_evt_ocrd_dt
;
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
cursor c_get_review_type(p_event_id in number) is
  select type
  from per_events
  where event_id = p_event_id;
--
l_changed              BOOLEAN;
l_lf_evt_ocrd_date     DATE;
l_effective_start_date DATE;
l_ler_id               NUMBER;
l_typ_cd ben_ler_f.typ_cd%type ;
l_ovn                  NUMBER;
l_ptnl_id              NUMBER;
l_hld_person_id        NUMBER;
l_ocrd_dt_cd           VARCHAR2(30);
l_column ben_rltd_per_chg_cs_ler_f.source_column%type;  -- VARCHAR2(30);
l_new_val ben_rltd_per_chg_cs_ler_f.new_val%type;   -- VARCHAR2(30);
l_old_val ben_rltd_per_chg_cs_ler_f.old_val%type;       -- VARCHAR2(30);
l_per_info_chg_cs_ler_rl number;
l_rule_output VARCHAR2(1);
l_type                 VARCHAR2(1);
l_le_exists            VARCHAR2(1);

--
l_bool  BOOLEAN;
l_status VARCHAR2(1);
l_industry VARCHAR2(1);
--
l_col_new_val varchar2(1000);
l_col_old_val varchar2(1000);
--
l_rule_overrides_flag VARCHAR2(1);
l_chg_mandatory_cd VARCHAR2(1);
l_trigger boolean := TRUE;
--
l_old_review_type varchar2(30);
l_new_review_type varchar2(30);
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

  hr_utility.set_location(' Entering: ben_ppr_trigger', 10);
  l_changed := FALSE;

    --
      If p_effective_date is not null then
         l_session_date := p_effective_date ;
      else
        open get_session_date;
        fetch get_session_date into  l_session_date;
        close get_session_date;
      end if;


  --
  hr_utility.set_location('p_new.review_date is'||p_new.review_date, 999);
  hr_utility.set_location('l_session_date is'||l_session_date, 999);
  --
  l_effective_start_date := l_session_date;
  --
  hr_utility.set_location(' ben_ppr_trigger', 20);
  hr_utility.set_location('sess '||l_session_date, 20);
  hr_utility.set_location('PERSON '||p_new.person_id, 20);
  hr_utility.set_location('BG '||p_new.business_group_id, 20);

  open get_ler(l_status);
  loop
    fetch get_ler into l_ler_id,l_typ_cd, l_ocrd_dt_cd;
    exit when get_ler%notfound;
           l_trigger := TRUE;


       if l_ocrd_dt_cd is null then
         l_lf_evt_ocrd_date := p_new.review_date;
       else
         --
         --   Call the common date procedure.
         --
         ben_determine_date.main
           (p_date_cd         => l_ocrd_dt_cd
           ,p_effective_date  => p_new.review_date
           ,p_lf_evt_ocrd_dt  => p_new.review_date
           ,p_returned_date   => l_lf_evt_ocrd_date
           );
       end if;


     --
    open get_ler_col(l_ler_id);
    loop
      fetch get_ler_col into l_column,l_new_val, l_old_val, l_type, l_per_info_chg_cs_ler_rl, l_rule_overrides_flag, l_chg_mandatory_cd;
      exit when get_ler_col%NOTFOUND;

      hr_utility.set_location('LER '||l_ler_id, 20);
      hr_utility.set_location('COLUMN '||l_column, 20);
      hr_utility.set_location('NEWVAL '||l_new_val, 20);
      hr_utility.set_location('OLDVAL '||l_old_val, 20);
      hr_utility.set_location('TYPE '||l_type, 20);

      l_changed := TRUE;
      if get_ler_col%ROWCOUNT = 1 then
        hr_utility.set_location('rowcount 1 ', 20);
        l_changed := TRUE;
      end if;
      hr_utility.set_location(' ben_ppr_trigger', 50);
      -- Call the formula here to evaluate per_info_chg_cs_ler_rl.
      -- If it returns Y, then see the applicability of the data
      -- changes based on new and old values.
      --
      l_rule_output := 'Y';
      --
      if l_per_info_chg_cs_ler_rl is not null then
         --
         if l_column = 'PERFORMANCE_RATING' then
            l_col_old_val := p_old.PERFORMANCE_RATING;
            l_col_new_val := p_new.PERFORMANCE_RATING;
         end if;
         --
         if l_column = 'EVENT_ID' then
            l_col_old_val := p_old.EVENT_ID;
            l_col_new_val := p_new.EVENT_ID;
         end if;
         --

         --
         if l_column = 'REVIEW_DATE' then
            l_col_old_val := p_old.REVIEW_DATE;
            l_col_new_val := p_new.REVIEW_DATE;
         end if;
         --
         if l_column = 'BUSINESS_GROUP_ID' then
            l_col_old_val := to_char(p_old.BUSINESS_GROUP_ID);
            l_col_new_val := to_char(p_new.BUSINESS_GROUP_ID);
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
         if l_column = 'ATTRIBUTE6' then
            l_col_old_val := p_old.ATTRIBUTE6;
            l_col_new_val := p_new.ATTRIBUTE6;
         end if;
         --
         if l_column = 'ATTRIBUTE7' then
            l_col_old_val := p_old.ATTRIBUTE7;
            l_col_new_val := p_new.ATTRIBUTE7;
         end if;
         --
         if l_column = 'ATTRIBUTE8' then
            l_col_old_val := p_old.ATTRIBUTE8;
            l_col_new_val := p_new.ATTRIBUTE8;
         end if;
         --
          if l_column = 'ATTRIBUTE9' then
            l_col_old_val := p_old.ATTRIBUTE9;
            l_col_new_val := p_new.ATTRIBUTE9;
         end if;
         --
         if l_column = 'ATTRIBUTE10' then
            l_col_old_val := p_old.ATTRIBUTE10;
            l_col_new_val := p_new.ATTRIBUTE10;
         end if;
         --
         if l_column = 'ATTRIBUTE11' then
            l_col_old_val := p_old.ATTRIBUTE11;
            l_col_new_val := p_new.ATTRIBUTE11;
         end if;
         --
         if l_column = 'ATTRIBUTE12' then
            l_col_old_val := p_old.ATTRIBUTE12;
            l_col_new_val := p_new.ATTRIBUTE12;
         end if;
         --
         if l_column = 'ATTRIBUTE13' then
            l_col_old_val := p_old.ATTRIBUTE13;
            l_col_new_val := p_new.ATTRIBUTE13;
         end if;
         --
         if l_column = 'ATTRIBUTE14' then
            l_col_old_val := p_old.ATTRIBUTE14;
            l_col_new_val := p_new.ATTRIBUTE14;
         end if;
         --
         if l_column = 'ATTRIBUTE15' then
            l_col_old_val := p_old.ATTRIBUTE15;
            l_col_new_val := p_new.ATTRIBUTE15;
         end if;
         --
         if l_column = 'ATTRIBUTE16' then
            l_col_old_val := p_old.ATTRIBUTE16;
            l_col_new_val := p_new.ATTRIBUTE16;
         end if;
         --
         if l_column = 'ATTRIBUTE17' then
            l_col_old_val := p_old.ATTRIBUTE17;
            l_col_new_val := p_new.ATTRIBUTE17;
         end if;
         --
         if l_column = 'ATTRIBUTE18' then
            l_col_old_val := p_old.ATTRIBUTE18;
            l_col_new_val := p_new.ATTRIBUTE18;
         end if;
         --
         if l_column = 'ATTRIBUTE19' then
            l_col_old_val := p_old.ATTRIBUTE19;
            l_col_new_val := p_new.ATTRIBUTE19;
         end if;
         --
         if l_column = 'ATTRIBUTE20' then
            l_col_old_val := p_old.ATTRIBUTE20;
            l_col_new_val := p_new.ATTRIBUTE20;
         end if;
         --
         if l_column = 'ATTRIBUTE21' then
            l_col_old_val := p_old.ATTRIBUTE21;
            l_col_new_val := p_new.ATTRIBUTE21;
         end if;
         --
         if l_column = 'ATTRIBUTE22' then
            l_col_old_val := p_old.ATTRIBUTE22;
            l_col_new_val := p_new.ATTRIBUTE22;
         end if;
         --
         if l_column = 'ATTRIBUTE23' then
            l_col_old_val := p_old.ATTRIBUTE23;
            l_col_new_val := p_new.ATTRIBUTE23;
         end if;
         --
         if l_column = 'ATTRIBUTE24' then
            l_col_old_val := p_old.ATTRIBUTE24;
            l_col_new_val := p_new.ATTRIBUTE24;
         end if;
         --
         if l_column = 'ATTRIBUTE25' then
            l_col_old_val := p_old.ATTRIBUTE25;
            l_col_new_val := p_new.ATTRIBUTE25;
         end if;
         --
         if l_column = 'ATTRIBUTE26' then
            l_col_old_val := p_old.ATTRIBUTE26;
            l_col_new_val := p_new.ATTRIBUTE26;
         end if;
         --
         if l_column = 'ATTRIBUTE27' then
            l_col_old_val := p_old.ATTRIBUTE27;
            l_col_new_val := p_new.ATTRIBUTE27;
         end if;
         --
         if l_column = 'ATTRIBUTE28' then
            l_col_old_val := p_old.ATTRIBUTE28;
            l_col_new_val := p_new.ATTRIBUTE28;
         end if;
         --
         if l_column = 'ATTRIBUTE29' then
            l_col_old_val := p_old.ATTRIBUTE29;
            l_col_new_val := p_new.ATTRIBUTE29;
         end if;
         --
         if l_column = 'ATTRIBUTE30' then
            l_col_old_val := p_old.ATTRIBUTE30;
            l_col_new_val := p_new.ATTRIBUTE30;
         end if;
         --

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

             p_param5           => 'BEN_PPR_IN_PERFORMANCE_RATING',
             p_param5_value     => p_new.PERFORMANCE_RATING,
             p_param6           => 'BEN_PPR_IO_PERFORMANCE_RATING',
             p_param6_value     => p_old.PERFORMANCE_RATING,

             p_param7           => 'BEN_PPR_IN_EVENT_ID',
             p_param7_value     => p_new.EVENT_ID,
             p_param8           => 'BEN_PPR_IO_EVENT_ID',
             p_param8_value     => p_old.EVENT_ID,

             p_param9           => 'BEN_PPR_IN_REVIEW_DATE',
             p_param9_value     => to_char(p_new.REVIEW_DATE, 'YYYY/MM/DD HH24:MI:SS'),
             p_param10           => 'BEN_PPR_IO_REVIEW_DATE',
             p_param10_value     => to_char(p_old.REVIEW_DATE, 'YYYY/MM/DD HH24:MI:SS'),

             p_param11           => 'BEN_PPR_IN_ATTRIBUTE1',
             p_param11_value     => p_new.ATTRIBUTE1,
             p_param12           => 'BEN_PPR_IO_ATTRIBUTE1',
             p_param12_value     => p_old.ATTRIBUTE1,

             p_param13           => 'BEN_PPR_IN_ATTRIBUTE2',
             p_param13_value     => p_new.ATTRIBUTE2,
             p_param14           => 'BEN_PPR_IO_ATTRIBUTE2',
             p_param14_value     => p_old.ATTRIBUTE2,

             p_param15           => 'BEN_PPR_IN_ATTRIBUTE3',
             p_param15_value     => p_new.ATTRIBUTE3,
             p_param16           => 'BEN_PPR_IO_ATTRIBUTE3',
             p_param16_value     => p_old.ATTRIBUTE3,

             p_param17           => 'BEN_PPR_IN_ATTRIBUTE4',
             p_param17_value     => p_new.ATTRIBUTE4,
             p_param18           => 'BEN_PPR_IO_ATTRIBUTE4',
             p_param18_value     => p_old.ATTRIBUTE4,

             p_param19           => 'BEN_PPR_IN_ATTRIBUTE5',
             p_param19_value     => p_new.ATTRIBUTE5,
             p_param20           => 'BEN_PPR_IO_ATTRIBUTE5',
             p_param20_value     => p_old.ATTRIBUTE5,

             p_param21           => 'BEN_PPR_IN_ATTRIBUTE6',
             p_param21_value     => p_new.ATTRIBUTE6,
             p_param22           => 'BEN_PPR_IO_ATTRIBUTE6',
             p_param22_value     => p_old.ATTRIBUTE6,

             p_param23           => 'BEN_PPR_IN_ATTRIBUTE7',
             p_param23_value     => p_new.ATTRIBUTE7,
             p_param24           => 'BEN_PPR_IO_ATTRIBUTE7',
             p_param24_value     => p_old.ATTRIBUTE7,

             p_param25           => 'BEN_PPR_IN_ATTRIBUTE8',
             p_param25_value     => p_new.ATTRIBUTE8,
             p_param26           => 'BEN_PPR_IO_ATTRIBUTE8',
             p_param26_value     => p_old.ATTRIBUTE8,

             p_param27           => 'BEN_PPR_IN_ATTRIBUTE9',
             p_param27_value     => p_new.ATTRIBUTE9,
             p_param28           => 'BEN_PPR_IO_ATTRIBUTE9',
             p_param28_value     => p_old.ATTRIBUTE9,

             p_param29           => 'BEN_PPR_IN_ATTRIBUTE10',
             p_param29_value     => p_new.ATTRIBUTE10,
             p_param30           => 'BEN_PPR_IO_ATTRIBUTE10',
             p_param30_value     => p_old.ATTRIBUTE10,

             p_param31           => 'BEN_PPR_IN_ATTRIBUTE11',
             p_param31_value     => p_new.ATTRIBUTE11,
             p_param32           => 'BEN_PPR_IO_ATTRIBUTE11',
             p_param32_value     => p_old.ATTRIBUTE11,

             p_param33           => 'BEN_PPR_IN_ATTRIBUTE12',
             p_param33_value     => p_new.ATTRIBUTE12,
             p_param34           => 'BEN_PPR_IO_ATTRIBUTE12',
             p_param34_value     => p_old.ATTRIBUTE12,



             p_pk_id             => to_char(p_new.performance_review_id),
             p_ret_val           => l_rule_output);
         --
      end if;
      --
      hr_utility.set_location(' ben_ppr_trigger'|| '  l_rule_output = ' || l_rule_output, 9999);

      --

          if l_column = 'REVIEW_DATE' then
              l_changed := (benutils.column_changed(p_old.review_date
                         ,p_new.review_date,l_new_val) AND
                            benutils.column_changed(p_new.review_date
                         ,p_old.review_date,l_old_val) AND
                         (l_changed));
           end if;

      --
           if l_column = 'PERFORMANCE_RATING' then
             l_changed := (benutils.column_changed(p_old.performance_rating
                          ,p_new.performance_rating,l_new_val) AND
                           benutils.column_changed(p_new.performance_rating
                          ,p_old.performance_rating,l_old_val) AND
                          (l_changed));
            hr_utility.set_location('NEW DOB'||p_new.performance_rating, 50);
            hr_utility.set_location('OLD DOB'||p_old.performance_rating, 50);
             hr_utility.set_location(' ben_ppr_trigger', 60);
           end if;
      --
           if l_column = 'EVENT_ID' then
	     --
	     -- Bug : 3692707
	     --
	     l_new_review_type := null;
	     l_old_review_type := null;
	     --
	     if l_new_val not in ('OABANY', 'NULL') then
	       --
	       open c_get_review_type(p_new.event_id);
	       fetch c_get_review_type into l_new_review_type;
	       close c_get_review_type;
	       --
	     end if;
	     --
	     if l_old_val not in ('OABANY', 'NULL') then
	       --
	       open c_get_review_type(p_old.event_id);
	       fetch c_get_review_type into l_old_review_type;
	       close c_get_review_type;
	       --
	     end if;
	     --
	     l_new_review_type := nvl(l_new_review_type, p_new.event_id);
	     l_old_review_type := nvl(l_old_review_type, p_old.event_id);
	     --
	     l_changed := (benutils.column_changed(l_old_review_type
                          ,l_new_review_type,l_new_val) AND
                           benutils.column_changed(l_new_review_type
                          ,l_old_review_type,l_old_val) AND
                          (l_changed));
             --
	     -- Bug : 3692707
	     --
	   end if;

           --
           if l_column = 'ATTRIBUTE1' then
             l_changed := (benutils.column_changed(p_old.attribute1
                        ,p_new.attribute1,l_new_val) AND
                           benutils.column_changed(p_new.attribute1
                        ,p_old.attribute1,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 210);
            hr_utility.set_location('NEW A1'||p_new.attribute1, 50);
            hr_utility.set_location('OLD A1'||p_old.attribute1, 50);
           end if;
      --
           if l_column = 'ATTRIBUTE2' then
             l_changed := (benutils.column_changed(p_old.attribute2
                        ,p_new.attribute2,l_new_val) AND
                           benutils.column_changed(p_new.attribute2
                        ,p_old.attribute2,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 220);
           end if;
      --
           if l_column = 'ATTRIBUTE3' then
             l_changed := (benutils.column_changed(p_old.attribute3
                        ,p_new.attribute3,l_new_val) AND
                           benutils.column_changed(p_new.attribute3
                        ,p_old.attribute3,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 230);
           end if;
      --
           if l_column = 'ATTRIBUTE4' then
             l_changed := (benutils.column_changed(p_old.attribute4
                        ,p_new.attribute4,l_new_val) AND
                           benutils.column_changed(p_new.attribute4
                        ,p_old.attribute4,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 240);
           end if;
      --
           if l_column = 'ATTRIBUTE5' then
             l_changed := (benutils.column_changed(p_old.attribute5
                        ,p_new.attribute5,l_new_val) AND
                           benutils.column_changed(p_new.attribute5
                        ,p_old.attribute5,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 250);
           end if;
      --
           if l_column = 'ATTRIBUTE6' then
             l_changed := (benutils.column_changed(p_old.attribute6
                        ,p_new.attribute6,l_new_val) AND
                           benutils.column_changed(p_new.attribute6
                        ,p_old.attribute6,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 260);
           end if;
      --
           if l_column = 'ATTRIBUTE7' then
             l_changed := (benutils.column_changed(p_old.attribute7
                        ,p_new.attribute7,l_new_val) AND
                           benutils.column_changed(p_new.attribute7
                        ,p_old.attribute7,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 270);
           end if;
      --
           if l_column = 'ATTRIBUTE8' then
             l_changed := (benutils.column_changed(p_old.attribute8
                        ,p_new.attribute8,l_new_val) AND
                           benutils.column_changed(p_new.attribute8
                        ,p_old.attribute8,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 280);
           end if;
      --
           if l_column = 'ATTRIBUTE9' then
             l_changed := (benutils.column_changed(p_old.attribute9
                        ,p_new.attribute9,l_new_val) AND
                           benutils.column_changed(p_new.attribute9
                        ,p_old.attribute9,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 290);
           end if;
      --
           if l_column = 'ATTRIBUTE10' then
             l_changed := (benutils.column_changed(p_old.attribute10
                        ,p_new.attribute10,l_new_val) AND
                           benutils.column_changed(p_new.attribute10
                        ,p_old.attribute10,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 300);
           end if;
      --
           if l_column = 'ATTRIBUTE11' then
             l_changed := (benutils.column_changed(p_old.attribute11
                        ,p_new.attribute11,l_new_val) AND
                           benutils.column_changed(p_new.attribute11
                        ,p_old.attribute11,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 310);
           end if;
      --
           if l_column = 'ATTRIBUTE12' then
             l_changed := (benutils.column_changed(p_old.attribute12
                        ,p_new.attribute12,l_new_val) AND
                           benutils.column_changed(p_new.attribute12
                        ,p_old.attribute12,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 320);
           end if;
      --
           if l_column = 'ATTRIBUTE13' then
             l_changed := (benutils.column_changed(p_old.attribute13
                        ,p_new.attribute13,l_new_val) AND
                           benutils.column_changed(p_new.attribute13
                        ,p_old.attribute13,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 330);
           end if;
      --
           if l_column = 'ATTRIBUTE14' then
             l_changed := (benutils.column_changed(p_old.attribute14
                        ,p_new.attribute14,l_new_val) AND
                           benutils.column_changed(p_new.attribute14
                        ,p_old.attribute14,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 340);
           end if;
      --
           if l_column = 'ATTRIBUTE15' then
             l_changed := (benutils.column_changed(p_old.attribute15
                        ,p_new.attribute15,l_new_val) AND
                           benutils.column_changed(p_new.attribute15
                        ,p_old.attribute15,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 350);
           end if;
      --
           if l_column = 'ATTRIBUTE16' then
             l_changed := (benutils.column_changed(p_old.attribute16
                        ,p_new.attribute16,l_new_val) AND
                           benutils.column_changed(p_new.attribute16
                        ,p_old.attribute16,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 360);
           end if;
      --
           if l_column = 'ATTRIBUTE17' then
             l_changed := (benutils.column_changed(p_old.attribute17
                        ,p_new.attribute17,l_new_val) AND
                           benutils.column_changed(p_new.attribute17
                        ,p_old.attribute17,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 370);
           end if;
      --
           if l_column = 'ATTRIBUTE18' then
             l_changed := (benutils.column_changed(p_old.attribute18
                        ,p_new.attribute18,l_new_val) AND
                           benutils.column_changed(p_new.attribute18
                        ,p_old.attribute18,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 380);
           end if;
      --
           if l_column = 'ATTRIBUTE19' then
             l_changed := (benutils.column_changed(p_old.attribute19
                        ,p_new.attribute19,l_new_val) AND
                           benutils.column_changed(p_new.attribute19
                        ,p_old.attribute19,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 390);
           end if;
      --
           if l_column = 'ATTRIBUTE20' then
             l_changed := (benutils.column_changed(p_old.attribute20
                        ,p_new.attribute20,l_new_val) AND
                           benutils.column_changed(p_new.attribute20
                        ,p_old.attribute20,l_old_val) AND
                          (l_changed));
             hr_utility.set_location(' ben_ppr_trigger', 400);
           end if;
      --

               if l_column = 'ATTRIBUTE21' then
                 l_changed := (benutils.column_changed(p_old.attribute21
                            ,p_new.attribute21,l_new_val) AND
                               benutils.column_changed(p_new.attribute21
                            ,p_old.attribute21,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ATTRIBUTE22' then
                 l_changed := (benutils.column_changed(p_old.attribute22
                            ,p_new.attribute22,l_new_val) AND
                               benutils.column_changed(p_new.attribute22
                            ,p_old.attribute22,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ATTRIBUTE23' then
                 l_changed := (benutils.column_changed(p_old.attribute23
                            ,p_new.attribute23,l_new_val) AND
                               benutils.column_changed(p_new.attribute23
                            ,p_old.attribute23,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ATTRIBUTE24' then
                 l_changed := (benutils.column_changed(p_old.attribute24
                            ,p_new.attribute24,l_new_val) AND
                               benutils.column_changed(p_new.attribute24
                            ,p_old.attribute24,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ATTRIBUTE25' then
                 l_changed := (benutils.column_changed(p_old.attribute25
                            ,p_new.attribute25,l_new_val) AND
                               benutils.column_changed(p_new.attribute25
                            ,p_old.attribute25,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ATTRIBUTE26' then
                 l_changed := (benutils.column_changed(p_old.attribute26
                            ,p_new.attribute26,l_new_val) AND
                               benutils.column_changed(p_new.attribute26
                            ,p_old.attribute26,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ATTRIBUTE27' then
                 l_changed := (benutils.column_changed(p_old.attribute27
                            ,p_new.attribute27,l_new_val) AND
                               benutils.column_changed(p_new.attribute27
                            ,p_old.attribute27,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ATTRIBUTE28' then
                 l_changed := (benutils.column_changed(p_old.attribute28
                            ,p_new.attribute28,l_new_val) AND
                               benutils.column_changed(p_new.attribute28
                            ,p_old.attribute28,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ATTRIBUTE29' then
                 l_changed := (benutils.column_changed(p_old.attribute29
                            ,p_new.attribute29,l_new_val) AND
                               benutils.column_changed(p_new.attribute29
                            ,p_old.attribute29,l_old_val) AND
                              (l_changed));
               end if;
          --
               if l_column = 'ATTRIBUTE30' then
                 l_changed := (benutils.column_changed(p_old.attribute30
                            ,p_new.attribute30,l_new_val) AND
                               benutils.column_changed(p_new.attribute30
                            ,p_old.attribute30,l_old_val) AND
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
    hr_utility.set_location(' ben_ppr_trigger', 30);
    l_ptnl_id := 0;
    l_ovn :=null;
    if l_trigger then



      if l_type = 'P' then
        --
        -- Life event has occured for Participant
        --
         hr_utility.set_location('l_lf_evt_ocrd_date is '||l_lf_evt_ocrd_date, 987);
        open le_exists(p_new.person_id,l_ler_id,l_lf_evt_ocrd_date);
        fetch le_exists into l_le_exists;
        --
        -- If an already existing life event of this
        -- type exists do nothing.
        --

        if le_exists%notfound then
           hr_utility.set_location(' Entering: ben_ppr_trigger5', 60);
           ben_create_ptnl_ler_for_per.create_ptnl_ler_event
           --ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
           (p_validate                 => false
           ,p_ptnl_ler_for_per_id      => l_ptnl_id
           ,p_ntfn_dt                  => trunc(sysdate)
           ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_date
           ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
           ,p_ler_id                   => l_ler_id
           ,p_ler_typ_cd               => l_typ_cd
           ,p_person_id                => p_new.person_id
           ,p_business_group_Id        => p_new.business_group_id
           ,p_object_version_number    => l_ovn
           ,p_effective_date           => l_effective_start_date
           ,p_dtctd_dt                 => l_lf_evt_ocrd_date);
        end if;
        close le_exists;
      elsif l_type = 'R' then
        hr_utility.set_location(' Entering: ben_ppr_trigger5-rp', 65);
        --
        -- Related Life event has occured for Participant contacts
        --
        open get_contacts(p_new.person_id);
        loop
           fetch get_contacts into l_hld_person_id;
           exit when get_contacts%notfound;
           open le_exists(l_hld_person_id,l_ler_id,l_lf_evt_ocrd_date);
           fetch le_exists into l_le_exists;
           --
           -- If potential life event does not already exist
           -- create it.
           if le_exists%notfound then
              hr_utility.set_location(' Entering: ben_ppr_trigger5', 60);
              ben_create_ptnl_ler_for_per.create_ptnl_ler_event
              --ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
              (p_validate                 => false
              ,p_ptnl_ler_for_per_id      => l_ptnl_id
              ,p_ntfn_dt                  => trunc(sysdate)
              ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_date
              ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
              ,p_ler_id                   => l_ler_id
              ,p_ler_typ_cd               => l_typ_cd
              ,p_person_id                => l_hld_person_id
              ,p_business_group_Id        => p_new.business_group_id
              ,p_object_version_number    => l_ovn
              ,p_effective_date           => l_effective_start_date
              ,p_dtctd_dt                 => l_lf_evt_ocrd_date);
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
      hr_utility.set_location(' ben_ppr_trigger', 40);
      l_changed   := FALSE;
      l_trigger   := TRUE;
      l_ovn       := NULL;

    end if;
    close get_ler_col;
  end loop;
  hr_utility.set_location(' ben_ppr_trigger', 180);
  close get_ler;
  hr_utility.set_location(' Leaving: ben_ppr_trigger', 200);

end;
end ben_ppr_ler;

/
