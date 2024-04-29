--------------------------------------------------------
--  DDL for Package Body BEN_PAC_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PAC_LER" as
/* $Header: bepactrg.pkb 120.1 2005/06/23 02:09:02 nhunur noship $ */
g_package varchar2(30) := 'ben_pac_ler' ;
--
-- This procedure is used to execute the rule : per_info_chg_cs_ler_rl
--
procedure exec_rule(
             p_formula_id        in  number,
             p_effective_date    in  date,
             p_lf_evt_ocrd_dt    in  date,
             p_business_group_id in  number,
             p_person_id         in  number ,
             p_new_value         in  varchar2 ,
             p_old_value         in  varchar2 ,
             p_column_name       in  varchar2 ,
             p_pk_id             in  varchar2 ,
             p_param5            in varchar2 ,
             p_param5_value      in varchar2 ,
             p_param6            in varchar2 ,
             p_param6_value      in varchar2 ,
             p_param7            in varchar2 ,
             p_param7_value      in varchar2 ,
             p_param8            in varchar2 ,
             p_param8_value      in varchar2 ,
             p_param9            in varchar2 ,
             p_param9_value      in varchar2 ,
             p_param10           in varchar2 ,
             p_param10_value     in varchar2 ,
             p_param11            in varchar2 ,
             p_param11_value      in varchar2 ,
             p_param12            in varchar2 ,
             p_param12_value      in varchar2 ,
             p_param13            in varchar2 ,
             p_param13_value      in varchar2 ,
             p_param14            in varchar2 ,
             p_param14_value      in varchar2 ,
             p_param15            in varchar2 ,
             p_param15_value      in varchar2 ,
             p_param16            in varchar2 ,
             p_param16_value      in varchar2 ,
             p_param17            in varchar2 ,
             p_param17_value      in varchar2 ,
             p_param18            in varchar2 ,
             p_param18_value      in varchar2 ,
             p_param19            in varchar2 ,
             p_param19_value      in varchar2 ,
             p_param20           in varchar2 ,
             p_param20_value     in varchar2 ,
             p_param21           in varchar2 ,
             p_param21_value     in varchar2 ,
             p_param22           in varchar2 ,
             p_param22_value     in varchar2 ,
             p_param23           in varchar2 ,
             p_param23_value     in varchar2 ,
             p_param24           in varchar2 ,
             p_param24_value     in varchar2 ,
             p_param25           in varchar2 ,
             p_param25_value     in varchar2 ,
             p_param26           in varchar2 ,
             p_param26_value     in varchar2 ,
             p_param27           in varchar2 ,
             p_param27_value     in varchar2 ,
             p_param28           in varchar2 ,
             p_param28_value     in varchar2 ,
             p_param29           in varchar2 ,
             p_param29_value     in varchar2 ,
             p_param30           in varchar2 ,
             p_param30_value     in varchar2 ,
             p_param31           in varchar2 ,
             p_param31_value     in varchar2 ,
             p_param32           in varchar2 ,
             p_param32_value     in varchar2 ,
             p_param33           in varchar2 ,
             p_param33_value     in varchar2 ,
             p_param34           in varchar2 ,
             p_param34_value     in varchar2 ,
             p_param35           in varchar2 ,
             p_param35_value     in varchar2 ,
             p_param_tab         in ff_exec.outputs_t ,
             p_ret_val           out nocopy varchar2 ,
             p_ret_date          out nocopy date) is
         --

  l_package            varchar2(80) := g_package||'.exec_rule';
  l_proc               varchar2(80) := g_package||'.exec_rule';
  l_outputs            ff_exec.outputs_t;
  l_loc_rec            hr_locations_all%rowtype;
  l_ass_rec            per_all_assignments_f%rowtype;
  l_jurisdiction_code  varchar2(30);
  l_env                ben_env_object.g_global_env_rec_type;

  --
begin
    --
    hr_utility.set_location ('Entering '||l_package,10);
    --
    if fnd_global.conc_request_id = -1 then
       --
       -- This makes sense for the calls made from the forms.
       --
       ben_env_object.init(p_business_group_id  => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_thread_id          => 1,
                        p_chunk_size         => 1,
                        p_threads            => 1,
                        p_max_errors         => 1,
                        p_benefit_action_id  => null);
       --
    end if;
    --
    -- Call formula initialise routine
    --
    if p_person_id is not null then
       ben_person_object.get_object(p_person_id => p_person_id,
                                    p_rec       => l_ass_rec);
    end if;
    --
    if p_person_id is not null and l_ass_rec.assignment_id is null then
      --
      ben_person_object.get_benass_object(p_person_id => p_person_id,
                                          p_rec       => l_ass_rec);
      --
    end if;
    --
    --
    hr_utility.set_location('assignment_id '||l_ass_rec.assignment_id , 13);
    l_outputs := benutils.formula
      (p_formula_id        => p_formula_id,
       p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
       p_assignment_id     => l_ass_rec.assignment_id,
       p_organization_id   => l_ass_rec.organization_id,
       p_business_group_id => p_business_group_id,
       p_param1            => 'NEW_VAL',
       p_param1_value      => p_new_value,
       p_param2            => 'OLD_VAL',
       p_param2_value      => p_old_value,
       p_param3            => 'COLUMN',
       p_param3_value      => p_column_name,
       p_param4            => 'PK_ID',
       p_param4_value      => p_pk_id,
       p_param5            => p_param5,
       p_param5_value      => p_param5_value,
       p_param6            => p_param6,
       p_param6_value      => p_param6_value,
       p_param7            => p_param7,
       p_param7_value      => p_param7_value,
       p_param8            => p_param8,
       p_param8_value      => p_param8_value,
       p_param9            => p_param9,
       p_param9_value      => p_param9_value,
       p_param10           => p_param10,
       p_param10_value     => p_param10_value,
       p_param11           => p_param11,
       p_param11_value     => p_param11_value,
       p_param12           => p_param12,
       p_param12_value     => p_param12_value,
       p_param13           => p_param13,
       p_param13_value     => p_param13_value,
       p_param14           => p_param14,
       p_param14_value     => p_param14_value,
       p_param15           => p_param15,
       p_param15_value     => p_param15_value,
       p_param16           => p_param16,
       p_param16_value     => p_param16_value,
       p_param17           => p_param17,
       p_param17_value     => p_param17_value,
       p_param18           => p_param18,
       p_param18_value     => p_param18_value,
       p_param19           => p_param19,
       p_param19_value     => p_param19_value,
       p_param20           => p_param20,
       p_param20_value     => p_param20_value,
       p_param21           => p_param21,
       p_param21_value     => p_param21_value,
       p_param22           => p_param22,
       p_param22_value     => p_param22_value,
       p_param23           => p_param23,
       p_param23_value     => p_param23_value,
       p_param24           => p_param24,
       p_param24_value     => p_param24_value,
       p_param25           => p_param25,
       p_param25_value     => p_param25_value,
       p_param26           => p_param26,
       p_param26_value     => p_param26_value,
       p_param27           => p_param27,
       p_param27_value     => p_param27_value,
       p_param28           => p_param28,
       p_param28_value     => p_param28_value,
       p_param29           => p_param29,
       p_param29_value     => p_param29_value,
       p_param30           => p_param30,
       p_param30_value     => p_param30_value,
       p_param31           => p_param31,
       p_param31_value     => p_param31_value,
       p_param32           => p_param32,
       p_param32_value     => p_param32_value,
       p_param33           => p_param33,
       p_param33_value     => p_param33_value,
       p_param34           => p_param34,
       p_param34_value     => p_param34_value,
       p_param35           => 'PERSON_ID',
       p_param35_value     => to_char(p_person_id),
       p_param_tab         => p_param_tab,
       p_jurisdiction_code => l_jurisdiction_code);
    --

    for l_count in l_outputs.first..l_outputs.last loop
    --
    declare
	invalid_param exception;
    begin
	--
	 if l_outputs(l_count).name = 'RETURN_FLAG' then
	   --
           hr_utility.set_location ('RETURN_FLAG  '|| l_outputs(l_count).value,10);
	   p_ret_val := l_outputs(l_count).value;
	   -- defensive coding
	   if ( p_ret_val not in ('Y' , 'N' , 'y' , 'n' )
	       OR p_ret_val is null )
	   then
	       p_ret_val := 'Y' ;
	   end if ;
	   --
	 elsif l_outputs(l_count).name = 'LE_OCCURED_DATE' then
	   --
           hr_utility.set_location ('LE_OCCURED_DATE  '|| l_outputs(l_count).value,10);
           if  l_outputs(l_count).value is not null
           then
	       p_ret_date := fnd_date.canonical_to_date(l_outputs(l_count).value);
           else
               p_ret_date := NULL ;
           end if ;
	   --
	 else
	   --
           hr_utility.set_location ('INVALID RULE VALUE  '|| l_outputs(l_count).value,10);
	   -- Account for cases where formula returns an unknown
	   -- variable name
           --
	   fnd_message.set_name('BEN','BEN_92310_FORMULA_RET_PARAM_');
	   fnd_message.set_token('PROC',l_proc);
	   fnd_message.set_token('FORMULA', p_formula_id);
	   fnd_message.set_token('PARAMETER',l_outputs(l_count).name);
	   -- Handling this particular exception seperately.
	   raise invalid_param;
	   --
	 end if;
	 --
	 -- Code for type casting errors from formula return variables
	 --
       exception
	 --
	 when invalid_param then
		fnd_message.raise_error;
	 when others then
	   --
	   fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
	   fnd_message.set_token('PROC',l_proc);
	   fnd_message.set_token('FORMULA', p_formula_id);
	   fnd_message.set_token('PARAMETER',l_outputs(l_count).name);
	   fnd_message.raise_error;
	   --
    end;
    end loop;
    hr_utility.set_location ('Leaving '||l_package,10);
    --
end exec_rule;
--
procedure ler_chk(p_old  IN g_pac_ler_rec
                 ,p_new  IN g_pac_ler_rec
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
cursor get_ler(l_status varchar2) is
 select ler.ler_id
 ,      ler.typ_cd
 ,      ler.ocrd_dt_det_cd
 from   ben_ler_f ler
 where  ler.business_group_id  = p_new.business_group_id
 and    l_session_date between ler.effective_start_date and ler.effective_end_date
 and ( l_status = 'I' or ler.typ_cd in ('COMP','GSP','ABS','CHECKLIST') )
 and    ((exists
        (select 1
          from   ben_per_info_chg_cs_ler_f psl
          ,      ben_ler_per_info_cs_ler_f lpl
          where  source_table               like 'PER_PERSON_ANALYSES%'
          and    psl.per_info_chg_cs_ler_id = lpl.per_info_chg_cs_ler_id
          and    lpl.business_group_id    = psl.business_group_id
          and    lpl.business_group_id    = ler.business_group_id
          and    l_session_date between psl.effective_start_date and psl.effective_end_date
       	  and    l_session_date between lpl.effective_start_date and lpl.effective_end_date
          and    lpl.ler_id                 = ler.ler_id)
 	  )
 OR      (exists
          (select 1
           from   ben_rltd_per_chg_cs_ler_f rpc
           ,      ben_ler_rltd_per_cs_ler_f lrp
           where  source_table             like 'PER_PERSON_ANALYSES%'
           and    lrp.business_group_id    = rpc.business_group_id
           and    lrp.business_group_id    = ler.business_group_id
           and    l_session_date between rpc.effective_start_date and rpc.effective_end_date
	   and    l_session_date between lrp.effective_start_date and lrp.effective_end_date
           and    rpc.rltd_per_chg_cs_ler_id = lrp.rltd_per_chg_cs_ler_id
           and    lrp.ler_id                 = ler.ler_id)
           ))
  order by ler.ler_id;

cursor get_ler_col(p_ler_id IN NUMBER) is
select psl.source_column, psl.new_val, psl.old_val,
       'P', psl.per_info_chg_cs_ler_rl, psl.rule_overrides_flag,
       lpl.chg_mandatory_cd, psl.source_table ,
       substr(psl.source_table, instr(psl.source_table, '-')+2 ,length(psl.source_table)) l_context
from ben_ler_per_info_cs_ler_f lpl,
     ben_per_info_chg_cs_ler_f psl
where lpl.ler_id = p_ler_id
and  lpl.business_group_id = p_new.business_group_id
and  lpl.business_group_id  = psl.business_group_id
and  l_session_date between psl.effective_start_date and psl.effective_end_date
and  l_session_date between lpl.effective_start_date and lpl.effective_end_date
and  psl.per_info_chg_cs_ler_id = lpl.per_info_chg_cs_ler_id
and  source_table like 'PER_PERSON_ANALYSES%'
UNION
select rpc.source_column, rpc.new_val, rpc.old_val,
     'R', rpc.rltd_per_chg_cs_ler_rl per_info_chg_cs_ler, rpc.rule_overrides_flag,
     lrp.chg_mandatory_cd, rpc.source_table,
     substr(rpc.source_table, instr(rpc.source_table, '-')+2 ,length(rpc.source_table)) l_context
from ben_ler_rltd_per_cs_ler_f lrp,
     ben_rltd_per_chg_cs_ler_f rpc
where lrp.ler_id = p_ler_id
and   lrp.business_group_id = p_new.business_group_id
and  lrp.business_group_id  = rpc.business_group_id
and l_session_date between rpc.effective_start_date and rpc.effective_end_date
and l_session_date between lrp.effective_start_date and lrp.effective_end_date
and rpc.rltd_per_chg_cs_ler_id = lrp.rltd_per_chg_cs_ler_id
and source_table like 'PER_PERSON_ANALYSES%'
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
cursor c_get_pac(p_id in number) is
select *
from per_analysis_criteria
where ANALYSIS_CRITERIA_ID = p_id;
--
l_param_tab  ff_exec.outputs_t ;
l_old_pac c_get_pac%rowtype ;
l_new_pac c_get_pac%rowtype ;
l_source_table ben_per_info_chg_cs_ler_f.source_table%TYPE ;
l_context varchar2(30);
--
l_changed BOOLEAN;
l_ler_id NUMBER;
l_typ_cd ben_ler_f.typ_cd%type ;
l_ocrd_dt_cd VARCHAR2(30);
l_column ben_rltd_per_chg_cs_ler_f.source_column%type;
l_new_val ben_rltd_per_chg_cs_ler_f.new_val%type;
l_old_val ben_rltd_per_chg_cs_ler_f.old_val%type;
l_per_info_chg_cs_ler_rl number;
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
l_rule_output varchar2(30) ;
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
cursor c_get_context_num ( p_name varchar2 ) is
select id_flex_num
from FND_ID_FLEX_STRUCTURES_TL
where id_flex_structure_name = p_name
and language = userenv('LANG');
--
l_context_num number;
l_ret_date    date;
--
begin
 --
 benutils.set_data_migrator_mode;
 if hr_general.g_data_migrator_mode in ( 'Y','P') then
   --
   return;
   --
 end if;
 --
 l_bool := fnd_installation.get(appl_id => 805
                               ,dep_appl_id =>805
                               ,status => l_status
                               ,industry => l_industry);

    hr_utility.set_location(' Entering: ben_pac_trigger', 10);
    l_changed := FALSE;
    --
    l_system_date := trunc(sysdate);
    --
    open get_session_date;
    fetch get_session_date into l_session_date;
    close get_session_date;
    --
    -- in case it is null
    --
    l_session_date := nvl(l_session_date , l_system_date) ;
    --
    l_effective_start_date := nvl(l_session_date,l_system_date);
    --
    hr_utility.set_location(' ben_pac_trigger - after l_session_date' || to_char(l_session_date), 20);
    hr_utility.set_location(' ben_pac_trigger - after l_effective_start_date', 20);
    --
 open get_ler(l_status);
 loop
    fetch get_ler into l_ler_id,l_typ_cd, l_ocrd_dt_cd;
    exit when get_ler%notfound;
    l_trigger := TRUE;
    --
    if l_ocrd_dt_cd is null
    then
        l_lf_evt_ocrd_date := nvl(p_new.date_from,l_effective_start_date);
    else
      --
      --   Call the common date procedure.
      --
      ben_determine_date.main
        (p_date_cd         => l_ocrd_dt_cd
        ,p_effective_date  => l_effective_start_date
        ,p_lf_evt_ocrd_dt  => l_effective_start_date
        ,p_returned_date   => l_lf_evt_ocrd_date
        );
    end if;
    --
    hr_utility.set_location(' ben_pac_trigger - after l_lf_evt_ocrd_date', 30);
    open get_ler_col(l_ler_id);
    loop
      fetch get_ler_col into l_column,l_new_val, l_old_val, l_type, l_per_info_chg_cs_ler_rl,
                       l_rule_overrides_flag, l_chg_mandatory_cd ,l_source_table, l_context;
      exit when get_ler_col%NOTFOUND;

      -- check if the context set on data changes matches that of
      -- the new record being inserted / updated
      -- if it matches only then we are interested in proceeding
      open c_get_context_num (l_context );
      fetch c_get_context_num into l_context_num ;
      if c_get_context_num%NOTFOUND then
          -- cant verify and proceed
          close c_get_context_num ;
          exit ;
      else
          close c_get_context_num ;
      end if;
      hr_utility.set_location(' ben_pac_trigger - context num      '||l_context_num , 50);
      hr_utility.set_location(' ben_pac_trigger - p_newid_flex_num '||p_new.id_flex_num , 50);
      --
      -- continue if context num is same as new value for new.id_flex_num
      -- else exit
      --
      if l_context_num <> p_new.id_flex_num
      then
          l_trigger := FALSE;
          l_changed := FALSE;
          exit;
      end if;
      --
      l_changed := TRUE;
      --
      hr_utility.set_location('LER    '||l_ler_id, 20);
      hr_utility.set_location('COLUMN '||l_column, 20);
      hr_utility.set_location('NEWVAL '||l_new_val, 20);
      hr_utility.set_location('OLDVAL '||l_old_val, 20);
      hr_utility.set_location('TYPE   '||l_type, 20);
      hr_utility.set_location('leod   '||l_lf_evt_ocrd_date, 20);
      --
      -- get the master table details using the old and new ANALYSIS_CRITERIA_ID
      -- if its insert then its null to any value
      -- if its update then its any value to any value
      -- This is possible as per_analysis_criteria is a KFF
      --
      if p_old.analysis_criteria_id is NULL
      then
          l_old_pac := NULL ;
      else
          open c_get_pac ( p_old.analysis_criteria_id );
          fetch c_get_pac into l_old_pac ;
          close c_get_pac ;
      end if;
      --
      hr_utility.set_location(' ben_pac_trigger - after l_old_pac', 40);
      --
      open c_get_pac ( p_new.analysis_criteria_id );
      fetch c_get_pac into l_new_pac ;
      close c_get_pac ;
      --
      hr_utility.set_location(' ben_pac_trigger - after l_new_pac', 40);
      -- Call the formula now to evaluate per_info_chg_cs_ler_rl.
      -- If it returns Y, then see the applicability of the data
      -- changes based on new and old values.
      --
      l_rule_output := 'Y';
      --
      if l_per_info_chg_cs_ler_rl is not null then
         --
         if l_column = 'DATE_FROM' then
            l_col_old_val := p_old.DATE_FROM;
	    l_col_new_val := p_new.DATE_FROM;
         end if;
         --
         if l_column = 'DATE_TO' then
            l_col_old_val := p_old.DATE_TO;
	    l_col_new_val := p_new.DATE_TO;
         end if;
         --
         if l_column = 'ANALYSIS_CRITERIA_ID' then
            l_col_old_val := p_old.ANALYSIS_CRITERIA_ID;
	    l_col_new_val := p_new.ANALYSIS_CRITERIA_ID;
         end if;
         --
         if l_column = 'SEGMENT1' then
            l_col_old_val := l_old_pac.SEGMENT1;
            l_col_new_val := l_new_pac.SEGMENT1;
         end if;
         --
         if l_column = 'SEGMENT2' then
            l_col_old_val := l_old_pac.SEGMENT2;
            l_col_new_val := l_new_pac.SEGMENT2;
         end if;
         --
         if l_column = 'SEGMENT3' then
            l_col_old_val := l_old_pac.SEGMENT3;
            l_col_new_val := l_new_pac.SEGMENT3;
         end if;
         --
         if l_column = 'SEGMENT4' then
            l_col_old_val := l_old_pac.SEGMENT4;
            l_col_new_val := l_new_pac.SEGMENT4;
         end if;
         --
         if l_column = 'SEGMENT5' then
            l_col_old_val := l_old_pac.SEGMENT5;
            l_col_new_val := l_new_pac.SEGMENT5;
         end if;
         --
         if l_column = 'SEGMENT6' then
            l_col_old_val := l_old_pac.SEGMENT6;
            l_col_new_val := l_new_pac.SEGMENT6;
         end if;
         --
         if l_column = 'SEGMENT7' then
            l_col_old_val := l_old_pac.SEGMENT7;
            l_col_new_val := l_new_pac.SEGMENT7;
         end if;
         --
         if l_column = 'SEGMENT8' then
            l_col_old_val := l_old_pac.SEGMENT8;
            l_col_new_val := l_new_pac.SEGMENT8;
         end if;
         --
         if l_column = 'SEGMENT9' then
            l_col_old_val := l_old_pac.SEGMENT9;
            l_col_new_val := l_new_pac.SEGMENT9;
         end if;
         --
         if l_column = 'SEGMENT10' then
            l_col_old_val := l_old_pac.SEGMENT10;
            l_col_new_val := l_new_pac.SEGMENT10;
         end if;
         --
         if l_column = 'SEGMENT11' then
            l_col_old_val := l_old_pac.SEGMENT11;
            l_col_new_val := l_new_pac.SEGMENT11;
         end if;
         --
         if l_column = 'SEGMENT12' then
            l_col_old_val := l_old_pac.SEGMENT12;
            l_col_new_val := l_new_pac.SEGMENT12;
         end if;
         --
         if l_column = 'SEGMENT13' then
            l_col_old_val := l_old_pac.SEGMENT13;
            l_col_new_val := l_new_pac.SEGMENT13;
         end if;
         --
         if l_column = 'SEGMENT14' then
            l_col_old_val := l_old_pac.SEGMENT14;
            l_col_new_val := l_new_pac.SEGMENT14;
         end if;
         --
         if l_column = 'SEGMENT15' then
            l_col_old_val := l_old_pac.SEGMENT15;
            l_col_new_val := l_new_pac.SEGMENT15;
         end if;
         --
         if l_column = 'SEGMENT16' then
            l_col_old_val := l_old_pac.SEGMENT16;
            l_col_new_val := l_new_pac.SEGMENT16;
         end if;
         --
         if l_column = 'SEGMENT17' then
            l_col_old_val := l_old_pac.SEGMENT17;
            l_col_new_val := l_new_pac.SEGMENT17;
         end if;
         --
         if l_column = 'SEGMENT18' then
            l_col_old_val := l_old_pac.SEGMENT18;
            l_col_new_val := l_new_pac.SEGMENT18;
         end if;
         --
         if l_column = 'SEGMENT19' then
            l_col_old_val := l_old_pac.SEGMENT19;
            l_col_new_val := l_new_pac.SEGMENT19;
         end if;
         --
         if l_column = 'SEGMENT20' then
            l_col_old_val := l_old_pac.SEGMENT20;
            l_col_new_val := l_new_pac.SEGMENT20;
         end if;
         --
         if l_column = 'SEGMENT21' then
            l_col_old_val := l_old_pac.SEGMENT21;
            l_col_new_val := l_new_pac.SEGMENT21;
         end if;
         --
         if l_column = 'SEGMENT22' then
            l_col_old_val := l_old_pac.SEGMENT22;
            l_col_new_val := l_new_pac.SEGMENT22;
         end if;
         --
         if l_column = 'SEGMENT23' then
            l_col_old_val := l_old_pac.SEGMENT23;
            l_col_new_val := l_new_pac.SEGMENT23;
         end if;
         --
         if l_column = 'SEGMENT24' then
            l_col_old_val := l_old_pac.SEGMENT24;
            l_col_new_val := l_new_pac.SEGMENT24;
         end if;
         --
         if l_column = 'SEGMENT25' then
            l_col_old_val := l_old_pac.SEGMENT25;
            l_col_new_val := l_new_pac.SEGMENT25;
         end if;
         --
         if l_column = 'SEGMENT26' then
            l_col_old_val := l_old_pac.SEGMENT26;
            l_col_new_val := l_new_pac.SEGMENT26;
         end if;
         --
         if l_column = 'SEGMENT27' then
            l_col_old_val := l_old_pac.SEGMENT27;
            l_col_new_val := l_new_pac.SEGMENT27;
         end if;
         --
         if l_column = 'SEGMENT28' then
            l_col_old_val := l_old_pac.SEGMENT28;
            l_col_new_val := l_new_pac.SEGMENT28;
         end if;
         --
         if l_column = 'SEGMENT29' then
            l_col_old_val := l_old_pac.SEGMENT29;
            l_col_new_val := l_new_pac.SEGMENT29;
         end if;
         --
         if l_column = 'SEGMENT30' then
            l_col_old_val := l_old_pac.SEGMENT30;
            l_col_new_val := l_new_pac.SEGMENT30;
         end if;
         --
         hr_utility.set_location(' ben_pac_trigger - before exec_rule', 40);

         exec_rule(
             p_formula_id        => l_per_info_chg_cs_ler_rl,
             p_effective_date    => l_session_date,
             p_lf_evt_ocrd_dt    => null,
             p_business_group_id => nvl(p_new.business_group_id, p_old.business_group_id),
             p_person_id         => nvl(p_new.person_id, p_old.person_id),
             p_new_value         => l_col_new_val,
             p_old_value         => l_col_old_val,
             p_column_name       => l_column,
             p_param5           => 'BEN_PAC_IN_SEGMENT1',
             p_param5_value     => l_new_pac.SEGMENT1,
             p_param6           => 'BEN_PAC_IO_SEGMENT1',
             p_param6_value     => l_old_pac.SEGMENT1,
             p_param7           => 'BEN_PAC_IN_SEGMENT2',
             p_param7_value     => l_new_pac.SEGMENT2,
             p_param8           => 'BEN_PAC_IO_SEGMENT2',
             p_param8_value     => l_old_pac.SEGMENT2,
             p_param9           => 'BEN_PAC_IN_SEGMENT3',
             p_param9_value     => l_new_pac.SEGMENT3,
             p_param10           => 'BEN_PAC_IO_SEGMENT3',
             p_param10_value     => l_old_pac.SEGMENT3,
             p_param11           => 'BEN_PAC_IN_SEGMENT4',
             p_param11_value     => l_new_pac.SEGMENT4,
             p_param12           => 'BEN_PAC_IO_SEGMENT4',
             p_param12_value     => l_old_pac.SEGMENT4,
             p_param13           => 'BEN_PAC_IN_SEGMENT5',
             p_param13_value     => l_new_pac.SEGMENT5,
             p_param14           => 'BEN_PAC_IO_SEGMENT5',
             p_param14_value     => l_old_pac.SEGMENT5,
             p_param15           => 'BEN_PAC_IN_SEGMENT6',
             p_param15_value     => l_new_pac.SEGMENT6,
             p_param16           =>  'BEN_PAC_IO_SEGMENT6',
             p_param16_value     => l_old_pac.SEGMENT6,
             p_param17           => 'BEN_PAC_IN_SEGMENT7',
             p_param17_value     => l_new_pac.SEGMENT7,
             p_param18           => 'BEN_PAC_IO_SEGMENT7',
             p_param18_value     => l_old_pac.SEGMENT7,
             p_param19           => 'BEN_PAC_IN_SEGMENT8',
             p_param19_value     => l_new_pac.SEGMENT8,
             p_param20           => 'BEN_PAC_IO_SEGMENT8',
             p_param20_value     => l_old_pac.SEGMENT8,
             p_param21           => 'BEN_PAC_IN_SEGMENT9',
             p_param21_value     => l_new_pac.SEGMENT9,
             p_param22           => 'BEN_PAC_IO_SEGMENT9',
             p_param22_value     => l_old_pac.SEGMENT9,
             p_param23           => 'BEN_PAC_IN_SEGMENT10',
             p_param23_value     => l_new_pac.SEGMENT10,
             p_param24           => 'BEN_PAC_IO_SEGMENT10',
             p_param24_value     => l_old_pac.SEGMENT10,
             p_param25           => 'BEN_PAC_IN_SEGMENT11',
             p_param25_value     => l_new_pac.SEGMENT11,
             p_param26           => 'BEN_PAC_IO_SEGMENT11',
             p_param26_value     => l_old_pac.SEGMENT11,
             p_param27           => 'BEN_PAC_IN_SEGMENT12',
             p_param27_value     => l_new_pac.SEGMENT12,
             p_param28           => 'BEN_IV_LER_ID',
             p_param28_value     => to_char(l_ler_id),
             p_param29           => 'BEN_PAC_IN_DATE_FROM',
             p_param29_value     => to_char(p_new.DATE_FROM, 'YYYY/MM/DD HH24:MI:SS'),
             p_param30           => 'BEN_PAC_IO_DATE_FROM',
             p_param30_value     => to_char(p_old.DATE_FROM, 'YYYY/MM/DD HH24:MI:SS'),
             p_param31           => 'BEN_PAC_IN_DATE_TO',
             p_param31_value     => to_char(p_new.DATE_TO, 'YYYY/MM/DD HH24:MI:SS'),
             p_param32           => 'BEN_PAC_IO_DATE_TO',
             p_param32_value     => to_char(p_old.DATE_TO, 'YYYY/MM/DD HH24:MI:SS'),
             p_param33           => 'BEN_PAC_IN_ANALYSIS_CRITERIA_ID',
             p_param33_value     =>  to_char(p_new.ANALYSIS_CRITERIA_ID),
             p_param34           => 'BEN_PAC_IO_ANALYSIS_CRITERIA_ID',
             p_param34_value     => to_char(p_old.ANALYSIS_CRITERIA_ID),
	     p_param35           => NULL,
             p_param35_value     => NULL,
             p_pk_id             => to_char(p_new.PERSON_ANALYSIS_ID),
             p_param_tab         => l_param_tab ,
             p_ret_val           => l_rule_output,
             p_ret_date          => l_ret_date );
         --
         hr_utility.set_location(' ben_pac_trigger - after benutils.exec_rule' || l_rule_output, 40);
         hr_utility.set_location(' ben_pac_trigger - after benutils.exec_rule' || to_char(l_ret_date), 40);
         --
         -- rule date overrides all dates
         l_lf_evt_ocrd_date := nvl(l_ret_date , l_lf_evt_ocrd_date ) ;
         --
      end if;
       --
       --
       if l_column = 'DATE_FROM' then
  	 l_changed := (benutils.column_changed(p_old.DATE_FROM
  		    ,p_new.DATE_FROM,l_new_val) AND
  		       benutils.column_changed(p_new.DATE_FROM
  		    ,p_old.DATE_FROM,l_old_val) AND
  		      (l_changed));
  --
       end if;
  --
       if l_column = 'DATE_TO' then
  	 l_changed := (benutils.column_changed(p_old.DATE_TO
  		    ,p_new.DATE_TO,l_new_val) AND
  		       benutils.column_changed(p_new.DATE_TO
  		    ,p_old.DATE_TO,l_old_val) AND
  		      (l_changed));
       end if;
  --
       if l_column = 'ANALYSIS_CRITERIA_ID' then
    	 l_changed := (benutils.column_changed(p_old.ANALYSIS_CRITERIA_ID
    		    ,p_new.ANALYSIS_CRITERIA_ID,l_new_val) AND
    		       benutils.column_changed(p_new.ANALYSIS_CRITERIA_ID
    		    ,p_old.ANALYSIS_CRITERIA_ID,l_old_val) AND
    		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT1' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT1
		    ,l_new_pac.SEGMENT1,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT1
		    ,l_old_pac.SEGMENT1,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT2' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT2
		    ,l_new_pac.SEGMENT2,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT2
		    ,l_old_pac.SEGMENT2,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT3' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT3
		    ,l_new_pac.SEGMENT3,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT3
		    ,l_old_pac.SEGMENT3,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT4' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT4
		    ,l_new_pac.SEGMENT4,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT4
		    ,l_old_pac.SEGMENT4,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT5' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT5
		    ,l_new_pac.SEGMENT5,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT5
		    ,l_old_pac.SEGMENT5,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT6' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT6
		    ,l_new_pac.SEGMENT6,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT6
		    ,l_old_pac.SEGMENT6,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT7' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT7
		    ,l_new_pac.SEGMENT7,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT7
		    ,l_old_pac.SEGMENT7,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT8' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT8
		    ,l_new_pac.SEGMENT8,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT8
		    ,l_old_pac.SEGMENT8,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT9' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT9
		    ,l_new_pac.SEGMENT9,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT9
		    ,l_old_pac.SEGMENT9,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT10' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT10
		    ,l_new_pac.SEGMENT10,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT10
		    ,l_old_pac.SEGMENT10,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT11' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT11
		    ,l_new_pac.SEGMENT11,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT11
		    ,l_old_pac.SEGMENT11,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT12' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT12
		    ,l_new_pac.SEGMENT12,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT12
		    ,l_old_pac.SEGMENT12,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT13' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT13
		    ,l_new_pac.SEGMENT13,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT13
		    ,l_old_pac.SEGMENT13,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT14' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT14
		    ,l_new_pac.SEGMENT14,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT14
		    ,l_old_pac.SEGMENT14,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT15' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT15
		    ,l_new_pac.SEGMENT15,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT15
		    ,l_old_pac.SEGMENT15,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT16' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT16
		    ,l_new_pac.SEGMENT16,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT16
		    ,l_old_pac.SEGMENT16,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT17' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT17
		    ,l_new_pac.SEGMENT17,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT17
		    ,l_old_pac.SEGMENT17,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT18' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT18
		    ,l_new_pac.SEGMENT18,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT18
		    ,l_old_pac.SEGMENT18,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT19' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT19
		    ,l_new_pac.SEGMENT19,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT19
		    ,l_old_pac.SEGMENT19,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT20' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT20
		    ,l_new_pac.SEGMENT20,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT20
		    ,l_old_pac.SEGMENT20,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT21' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT21
		    ,l_new_pac.SEGMENT21,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT21
		    ,l_old_pac.SEGMENT21,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT22' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT22
		    ,l_new_pac.SEGMENT22,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT22
		    ,l_old_pac.SEGMENT22,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT23' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT23
		    ,l_new_pac.SEGMENT23,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT23
		    ,l_old_pac.SEGMENT23,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT24' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT24
		    ,l_new_pac.SEGMENT24,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT24
		    ,l_old_pac.SEGMENT24,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT25' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT25
		    ,l_new_pac.SEGMENT25,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT25
		    ,l_old_pac.SEGMENT25,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT26' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT26
		    ,l_new_pac.SEGMENT26,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT26
		    ,l_old_pac.SEGMENT26,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT27' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT27
		    ,l_new_pac.SEGMENT27,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT27
		    ,l_old_pac.SEGMENT27,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT28' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT28
		    ,l_new_pac.SEGMENT28,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT28
		    ,l_old_pac.SEGMENT28,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT29' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT29
		    ,l_new_pac.SEGMENT29,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT29
		    ,l_old_pac.SEGMENT29,l_old_val) AND
		      (l_changed));
       end if;
  --
       if l_column = 'SEGMENT30' then
	 l_changed := (benutils.column_changed(l_old_pac.SEGMENT30
		    ,l_new_pac.SEGMENT30,l_new_val) AND
		       benutils.column_changed(l_new_pac.SEGMENT30
		    ,l_old_pac.SEGMENT30,l_old_val) AND
		      (l_changed));
       end if;

       hr_utility.set_location(' ben_pac_trigger - after l_changed', 40);
        --
       	-- Checking the rule output and the rule override flag.
	-- Whether the rule is mandatory or not, rule output should return 'Y'
	-- Rule Mandatory flag is just to override the column data change.

	if l_rule_output = 'Y' and l_rule_overrides_flag = 'Y' then
	  l_changed := l_changed AND TRUE ;
	elsif l_rule_output = 'Y' and l_rule_overrides_flag = 'N' then
	  l_changed := l_changed AND TRUE;
	elsif l_rule_output = 'N' then
	  hr_utility.set_location(' Rule output is N, so we should not trigger LE', 20.01);
	  l_changed := FALSE;
	end if;

	hr_utility.set_location('After the rule Check ',20.05);
	if l_changed then
	  hr_utility.set_location('l_change TRUE l_rule_overrides_flag '||l_rule_overrides_flag, 20.1);
	else
	  hr_utility.set_location('l_change FALSE l_rule_overrides_flag '||l_rule_overrides_flag, 20.1);
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
	elsif l_chg_mandatory_cd = 'N' and l_changed then
		hr_utility.set_location('Found First Non-Mandatory and its passed ', 20.1);
		l_changed := TRUE;
		l_trigger := TRUE;
		exit;
	end if;

	hr_utility.set_location('After the Mandatory code check ',20.05);
	if l_changed then
	   hr_utility.set_location('l_change TRUE ', 20.1);
	else
	  hr_utility.set_location('l_change FALSE ', 20.1);
	end if;
    end loop;
    --
    hr_utility.set_location(' ben_pac_trigger', 30);
    --
    if l_changed then
       hr_utility.set_location(' Change detected', 30);
    end if;
    --
    l_ptnl_id := 0;
    l_ovn :=null;
    if l_trigger then
      if l_type = 'P' then
        open le_exists(p_new.person_id,l_ler_id,l_lf_evt_ocrd_date);
        fetch le_exists into l_le_exists;
        if le_exists%notfound then
           hr_utility.set_location(' Entering: ben_pac_trigger ', 60);

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
        --
      elsif l_type = 'R' then
        open get_contacts(p_new.person_id);
        loop
           fetch get_contacts into l_hld_person_id;
           exit when get_contacts%notfound;
           open le_exists(l_hld_person_id,l_ler_id,l_lf_evt_ocrd_date);
           fetch le_exists into l_le_exists;
           if le_exists%notfound then
              hr_utility.set_location(' Entering: ben_pac_trigger5', 60);

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
      hr_utility.set_location(' ben_pac_trigger', 100);
      l_changed   := FALSE;
      l_trigger   := TRUE;
      l_ovn       := NULL;
    end if;
    close get_ler_col;
  end loop;
  hr_utility.set_location(' ben_pac_trigger', 110);
  close get_ler;
  hr_utility.set_location(' Leaving: ben_pac_trigger', 120);
end;
--
end ben_pac_ler;

/
