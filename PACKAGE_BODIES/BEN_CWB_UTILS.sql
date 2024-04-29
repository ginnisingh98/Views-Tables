--------------------------------------------------------
--  DDL for Package Body BEN_CWB_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_UTILS" as
/* $Header: bencwbutils.pkb 120.17.12010000.3 2009/12/17 09:24:14 sgnanama ship $ */
FUNCTION get_task_access (
      p_hidden_cd            IN   VARCHAR2,
      p_task_access_cd       IN   VARCHAR2,
      p_plan_access_cd       IN   VARCHAR2,
      p_wksht_grp_cd         IN   VARCHAR2,
      p_population_cd        IN   VARCHAR2,
      p_status_cd            IN   VARCHAR2,
      p_dist_bdgt_iss_dt     IN   DATE,
      p_ss_update_start_dt   IN   DATE,
      p_ss_update_end_dt     IN   DATE,
      p_effective_dt         IN   DATE
   )
      RETURN VARCHAR2
   IS
      l_access_cd   VARCHAR2 (2);
   BEGIN
      l_access_cd := 'UP';

      IF (p_status_cd = 'NA')
      THEN
         --No Access
         l_access_cd := 'NA';
      ELSIF (p_wksht_grp_cd = 'BDGT' AND p_dist_bdgt_iss_dt IS NULL)
      THEN
         l_access_cd := 'NA';
      ELSIF (   p_hidden_cd = 'NA'
             OR p_task_access_cd = 'NA'
             OR p_plan_access_cd = 'NA'
            )
      THEN
         l_access_cd := 'NA';
      ELSIF (   p_hidden_cd = 'RO'
             OR p_task_access_cd = 'RO'
             OR p_plan_access_cd = 'RO'
            )
      THEN
         IF (p_wksht_grp_cd = 'BDGT' AND p_population_cd IS NULL)
         THEN
            l_access_cd := 'NA';
         ELSE
            l_access_cd := 'RO';
         END IF;
      ELSIF p_effective_dt NOT BETWEEN p_ss_update_start_dt AND p_ss_update_end_dt
      THEN
         l_access_cd := 'RO';
      END IF;

      RETURN l_access_cd;
   END get_task_access;
--
FUNCTION is_task_enabled
  	 (p_access_cd 		in varchar2,
	  p_population_cd 	in varchar2,
	  p_status_cd 		in varchar2,
	  p_dist_bdgt_iss_dt 	in date,
	  p_wksht_grp_cd	in varchar2)
return varchar2
is
begin
if(p_status_cd = 'NA')
then
 return 'D';
else
 if (p_wksht_grp_cd = 'BDGT')
 then
  if (p_dist_bdgt_iss_dt is null)
  then
   return 'D';
  elsif (nvl(p_access_cd,'NA') = 'RO' and p_population_cd is null) then
   return 'D';
  end if;
 /*elsif (p_wksht_grp_cd = 'RVW')
 then
   if (p_status_cd = 'NS')
   then
   return 'D';
   end if;*/
 end if;
 return 'Y';
end if;
end is_task_enabled;
--
FUNCTION get_manager_name(p_emp_per_in_ler_id in number,
	                  p_level in number)
return varchar2
  is

  Cursor csr_mgr_name
  is
  Select bcpi.full_name,
	 	 bcpi.brief_name,
         bcpi.custom_name
    From ben_cwb_person_info bcpi,
         ben_cwb_group_hrchy bcgh
   where bcgh.emp_per_in_ler_id = p_emp_per_in_ler_id
     and bcgh.lvl_num = (select max(lvl_num) - p_level + 1
                           from ben_cwb_group_hrchy
                          where emp_per_in_ler_id = p_emp_per_in_ler_id)
     and bcgh.lvl_num > 0
     and bcgh.mgr_per_in_ler_id = bcpi.group_per_in_ler_id;

  name_profile varchar2(2000);
  manager_names csr_mgr_name%rowtype;

begin

   name_profile := get_profile ('BEN_DISPLAY_EMPLOYEE_NAME');

   open csr_mgr_name;
   fetch csr_mgr_name into manager_names;
   close csr_mgr_name;

   if('FN' = name_profile)
   then
    return manager_names.full_name;
   elsif ('CN' = name_profile)
   then
    return manager_names.custom_name;
   else
    return manager_names.brief_name;
   end if;

end get_manager_name;
--

FUNCTION get_eligibility(p_plan_status in varchar2,
                         p_opt1_status in varchar2,
                         p_opt2_status in varchar2,
                         p_opt3_status in varchar2,
                         p_opt4_status in varchar2
                        )
return varchar2
is
 l_elig_count number := 0;
 l_inelig_count number := 0;
begin

  IF p_plan_status is not null THEN
     IF p_plan_status = 'Y' THEN
        l_elig_count := l_elig_count +1;
     ELSE
        l_inelig_count := l_inelig_count + 1;
     END IF;
  END IF;

  IF p_opt1_status is not null THEN
     IF p_opt1_status = 'Y' THEN
        l_elig_count := l_elig_count +1;
     ELSE
        l_inelig_count := l_inelig_count + 1;
     END IF;
  END IF;

  IF p_opt2_status is not null THEN
     IF p_opt2_status = 'Y' THEN
        l_elig_count := l_elig_count +1;
     ELSE
        l_inelig_count := l_inelig_count + 1;
     END IF;
  END IF;

  IF p_opt3_status is not null THEN
     IF p_opt3_status = 'Y' THEN
        l_elig_count := l_elig_count +1;
     ELSE
        l_inelig_count := l_inelig_count + 1;
     END IF;
  END IF;

  IF p_opt4_status is not null THEN
     IF p_opt4_status = 'Y' THEN
        l_elig_count := l_elig_count +1;
     ELSE
        l_inelig_count := l_inelig_count + 1;
     END IF;
  END IF;

  IF l_elig_count > 0 AND l_inelig_count > 0 THEN
    return 'BOTH';
  END IF;

  IF l_elig_count = 0 AND l_inelig_count = 0 THEN
    return 'BOTH';
  END IF;

  IF l_elig_count > 0 AND l_inelig_count = 0 THEN
    return 'Y';
  END IF;

  IF l_elig_count = 0 AND l_inelig_count > 0 THEN
    return 'N';
  END IF;

end;

FUNCTION get_profile(p_profile_name in varchar2)
return varchar2
is
name_profile varchar2(2000);
begin
    fnd_profile.get (p_profile_name, name_profile);
    return name_profile;
end get_profile;
--
PROCEDURE  get_site_profile (
                  p_profile_1                in varchar2 default null,
                  p_value_1                  out nocopy varchar2)
IS

l_defined_z boolean;

CURSOR value_site_profile(v_name varchar2)
IS
    SELECT valu.profile_option_value
    FROM fnd_profile_options options
        ,fnd_profile_option_values valu
    WHERE options.profile_option_name = upper(v_name)
    AND options.start_date_active  <= sysdate
    AND nvl(options.end_date_active, sysdate) >= sysdate
    AND options.profile_option_id = valu.profile_option_id
    AND	valu.level_id = 10001;

BEGIN
if(p_profile_1 is not null) then
    open value_site_profile(p_profile_1);
    fetch value_site_profile
    into p_value_1;
    close value_site_profile;
end if;
END get_site_profile;
--
--
PROCEDURE  get_resp_profile (
                  p_resp_id                  in number default null,
                  p_profile_1                in varchar2 default null,
                  p_value_1                  out nocopy varchar2)
IS

l_defined_z boolean;

CURSOR value_resp_profile(v_name varchar2, v_resp_id number)
IS
    SELECT valu.profile_option_value
    FROM fnd_profile_options options
        ,fnd_profile_option_values valu
    WHERE options.profile_option_name = upper(v_name)
    AND options.start_date_active  <= sysdate
    AND nvl(options.end_date_active, sysdate) >= sysdate
    AND options.profile_option_id = valu.profile_option_id
    AND valu.level_value_application_id = 800
    AND	valu.level_id = 10003
    AND valu.level_value = v_resp_id;

BEGIN
if(p_profile_1 is not null) then
    open value_resp_profile(p_profile_1,p_resp_id);
    fetch value_resp_profile
    into p_value_1;
    close value_resp_profile;
end if;
END get_resp_profile;
--
PROCEDURE  get_user_profile (
                  p_user_id                  in number default null,
                  p_profile_1                in varchar2 default null,
                  p_profile_2                in varchar2 default null,
                  p_profile_3                in varchar2 default null,
                  p_profile_4                in varchar2 default null,
                  p_profile_5                in varchar2 default null,
                  p_profile_6                in varchar2 default null,
                  p_profile_7                in varchar2 default null,
                  p_profile_8                in varchar2 default null,
                  p_profile_9                in varchar2 default null,
                  p_profile_10               in varchar2 default null,
                  p_value_1                  out nocopy varchar2,
                  p_value_2                  out nocopy varchar2,
                  p_value_3                  out nocopy varchar2,
                  p_value_4                  out nocopy varchar2,
                  p_value_5                  out nocopy varchar2,
                  p_value_6                  out nocopy varchar2,
                  p_value_7                  out nocopy varchar2,
                  p_value_8                  out nocopy varchar2,
                  p_value_9                  out nocopy varchar2,
                  p_value_10                 out nocopy varchar2)
IS

l_defined_z boolean;

CURSOR value_user_profile(v_name varchar2, v_user_id number)
IS
    SELECT valu.profile_option_value
    FROM fnd_profile_options options
        ,fnd_profile_option_values valu
    WHERE options.profile_option_name = upper(v_name)
    AND options.start_date_active  <= sysdate
    AND nvl(options.end_date_active, sysdate) >= sysdate
    AND options.profile_option_id = valu.profile_option_id
	AND valu.application_id = 805
	AND	valu.level_id = 10004
	AND	valu.level_value = v_user_id;

BEGIN
if(p_profile_1 is not null) then
    open value_user_profile(p_profile_1,p_user_id);
    fetch value_user_profile
    into p_value_1;
    close value_user_profile;
end if;
if(p_profile_2 is not null) then
    open value_user_profile(p_profile_2,p_user_id);
    fetch value_user_profile
    into p_value_2;
    close value_user_profile;
end if;
if(p_profile_3 is not null) then
    open value_user_profile(p_profile_3,p_user_id);
    fetch value_user_profile
    into p_value_3;
    close value_user_profile;
end if;
if(p_profile_4 is not null) then
    open value_user_profile(p_profile_4,p_user_id);
    fetch value_user_profile
    into p_value_4;
    close value_user_profile;
end if;
if(p_profile_5 is not null) then
    open value_user_profile(p_profile_5,p_user_id);
    fetch value_user_profile
    into p_value_5;
    close value_user_profile;
end if;
if(p_profile_6 is not null) then
    open value_user_profile(p_profile_6,p_user_id);
    fetch value_user_profile
    into p_value_6;
    close value_user_profile;
end if;
if(p_profile_7 is not null) then
    open value_user_profile(p_profile_7,p_user_id);
    fetch value_user_profile
    into p_value_7;
    close value_user_profile;
end if;
if(p_profile_8 is not null) then
    open value_user_profile(p_profile_8,p_user_id);
    fetch value_user_profile
    into p_value_8;
    close value_user_profile;
end if;
if(p_profile_9 is not null) then
    open value_user_profile(p_profile_9,p_user_id);
    fetch value_user_profile
    into p_value_9;
    close value_user_profile;
end if;
if(p_profile_10 is not null) then
    open value_user_profile(p_profile_10,p_user_id);
    fetch value_user_profile
    into p_value_10;
    close value_user_profile;
end if;
END get_user_profile;
--
FUNCTION get_bdgt_pct_of_elig_sal_decs return number is
  l_return_value number;
begin
  l_return_value :=  to_number(get_profile('BEN_CWB_BS_PCT_ES_DECS_DISP'));
  if l_return_value is null then
    return 2;
  elsif l_return_value > 10 then
    return 10;
  else
    return l_return_value;
  end if;
exception
  when others then
    return 2;
end get_bdgt_pct_of_elig_sal_decs;
--
FUNCTION get_alloc_pct_of_elig_sal_decs return number is
  l_return_value number;
begin
  l_return_value :=  to_number(get_profile('BEN_CWB_WS_PCT_ES_DECS_DISP'));
  if l_return_value is null then
    return 2;
  elsif l_return_value > 10 then
    return 10;
  else
    return l_return_value;
  end if;
exception
  when others then
    return 2;
end get_alloc_pct_of_elig_sal_decs;
--
FUNCTION is_person_switchable(p_person_id in number,
                              p_effective_date in date)
return varchar2
is
CURSOR is_person_in_secured_view
is
SELECT 'x'
  FROM per_people_f ppf,
       per_person_types ppt
 WHERE ppf.person_id = p_person_id
   AND ppt.person_type_id  = ppf.person_type_id
   AND ppt.system_person_type <> 'EX_EMP_APL'
   AND p_effective_date between ppf.effective_start_date and ppf.effective_end_date;

l_switch varchar2(1);

begin
OPEN is_person_in_secured_view;
FETCH is_person_in_secured_view INTO l_switch;
if is_person_in_secured_view%NOTFOUND then
 CLOSE is_person_in_secured_view;
 return 'N';
else
 CLOSE is_person_in_secured_view;
 return 'Y';
end if;
END is_person_switchable;


function add_number_with_null_check(p_orig_val in number,
                                    p_new_val  in number) return number is
begin
  if p_orig_val is null then
    return p_new_val;
  else
    return p_orig_val + nvl(p_new_val,0);
  end if;
end add_number_with_null_check;



/* ---------------------------------------------------------------------
   Procedures/Functions Below are defined for Document Management
   Enhancements to support Printable Documents (PDF)
   BEGIN
   --------------------------------------------------------------------- */


Function get_option1_name(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2
is
  cursor cur_option1_name is
    Select name
    From  ben_cwb_pl_dsgn
    Where pl_id = p_group_plan_id
    and   group_pl_id = p_group_plan_id
    And   lf_evt_ocrd_dt = p_lf_evnt_ocrd_dt
    --And   oipl_id  <> -1
    --And   opt_count = 1;
    and  oipl_ordr_num = 1;

   l_option1_name varchar2(240);
Begin

     open cur_option1_name;
     fetch  cur_option1_name into l_option1_name;
     close  cur_option1_name;
     return l_option1_name;
End;


Procedure populate_person_option1_rec(
      p_group_plan_id in number,
      p_lf_evt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2)
Is
    cursor cur_option1_rate is
      Select bcpr.*
      From  ben_cwb_person_rates bcpr,ben_cwb_pl_dsgn  bcpd
      Where bcpr.group_per_in_ler_id = p_group_per_in_ler_id
      And   bcpd.group_pl_id    = p_group_plan_id
     -- AND   bcpd.pl_id          = p_group_plan_id
      And   bcpd.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
      --And   bcpd.oipl_id        <> -1
      --And   bcpd.opt_count      = 1
      and oipl_ordr_num = 1
      And   bcpr.pl_id          = bcpd.pl_id
      And   bcpr.group_pl_id    = bcpd.group_pl_id
      And   bcpr.oipl_id        = bcpd.oipl_id
      And   bcpr.lf_evt_ocrd_dt = bcpd.lf_evt_ocrd_dt
      and   bcpr.elig_flag = 'Y';
Begin

       g_opt1_person_rates_rec := null;
       open cur_option1_rate;
       fetch cur_option1_rate into  g_opt1_person_rates_rec;
       close cur_option1_rate;

End;

Function get_option1_rate_ws_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option1_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt1_person_rates_rec.ws_val;

End get_option1_rate_ws_amt;

Function get_option1_unit(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2
Is
 --- ws_nmmntry_uom need to be decode from lookup table
    Cursor cur_option1_units is
       Select decode(ws_nnmntry_uom,null,currency, hr_general.decode_lookup('BEN_NNMNTRY_UOM',ws_nnmntry_uom) )
       From  ben_cwb_person_rates bcpr,ben_cwb_pl_dsgn  bcpd
                         Where bcpr.group_per_in_ler_id = p_group_per_in_ler_id
                         And   bcpd.group_pl_id    = p_group_plan_id
                         And   bcpd.lf_evt_ocrd_dt = p_lf_evnt_ocrd_dt
                         And   bcpr.pl_id          = bcpd.pl_id
                         And   bcpr.group_pl_id    = bcpd.group_pl_id
                         And   bcpr.oipl_id        = bcpd.oipl_id
                         And   bcpr.lf_evt_ocrd_dt = bcpd.lf_evt_ocrd_dt
                         and   bcpr.elig_flag = 'Y'
            and   oipl_ordr_num = 1;

  l_option1_unit  varchar2(30);
Begin
  open  cur_option1_units;
  fetch cur_option1_units into l_option1_unit;
  close cur_option1_units;
  return l_option1_unit;
End get_option1_unit;


Function get_option1_elg_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option1_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt1_person_rates_rec.ELIG_SAL_VAL;

End get_option1_elg_sal;

Function get_option1_elg_per_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
Is
Begin

	populate_person_option1_rec(
	                     p_group_plan_id,
	                     p_lf_evnt_ocrd_dt,
	                     p_oipl_id,
	                     p_group_per_in_ler_id,
	                     p_pl_id,
                     p_ws_sub_acty_typ_cd);

  if (g_opt1_person_rates_rec.elig_sal_val <> 0) then
  	return round( (g_opt1_person_rates_rec.ws_val / g_opt1_person_rates_rec.elig_sal_val) * 100,2);
  else
  	return to_number(null);
  end if;

End get_option1_elg_per_sal;

Function get_option1_rate_reco_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option1_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt1_person_rates_rec.REC_VAL;

End get_option1_rate_reco_amt;

Function get_option1_rate_oth_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option1_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt1_person_rates_rec.OTH_COMP_VAL;

End get_option1_rate_oth_sal;

Function get_option1_rate_sta_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option1_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt1_person_rates_rec.STAT_SAL_VAL;

End get_option1_rate_sta_sal;

Function get_option1_rate_tot_comp(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option1_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt1_person_rates_rec.TOT_COMP_VAL;

End get_option1_rate_tot_comp;


Function get_option1_rate_misc1(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option1_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt1_person_rates_rec.MISC1_VAL;

End get_option1_rate_misc1;

Function get_option1_rate_misc2(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option1_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt1_person_rates_rec.MISC2_VAL;

End get_option1_rate_misc2;

Function get_option1_rate_misc3(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option1_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt1_person_rates_rec.MISC3_VAL;

End get_option1_rate_misc3;


Function get_option2_name(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2
is
  cursor cur_option2_name is
    Select name
    From  ben_cwb_pl_dsgn
    Where pl_id = p_group_plan_id
    And   group_pl_id = p_group_plan_id
    And   lf_evt_ocrd_dt = p_lf_evnt_ocrd_dt
   -- And   oipl_id  <> -1
    -- And   opt_count = 2;
    and oipl_ordr_num = 2;

   l_option2_name varchar2(240);
Begin

     open cur_option2_name;
     fetch  cur_option2_name into l_option2_name;
     close  cur_option2_name;
     return l_option2_name;
End;

Procedure populate_person_option2_rec(
      p_group_plan_id in number,
      p_lf_evt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2)
Is
    cursor cur_option2_rate is
      Select bcpr.*
      From  ben_cwb_person_rates bcpr,ben_cwb_pl_dsgn  bcpd
      Where bcpr.group_per_in_ler_id = p_group_per_in_ler_id
      And   bcpd.group_pl_id = p_group_plan_id
      --AND   bcpd.pl_id       = p_group_plan_id
      And   bcpd.lf_evt_ocrd_dt= p_lf_evt_ocrd_dt
      --And   bcpd.oipl_id  <> -1
     -- And   bcpd.opt_count = 2
           and oipl_ordr_num = 2
      And   bcpd.pl_id = bcpr.pl_id
      And   bcpd.group_pl_id  = bcpr.group_pl_id
      And   bcpd.oipl_id = bcpr.oipl_id
      And   bcpd.lf_evt_ocrd_dt = bcpr.lf_evt_ocrd_dt
      and   bcpr.elig_flag = 'Y';
Begin

      	     g_opt2_person_rates_rec := null;
             open cur_option2_rate;
             fetch cur_option2_rate into  g_opt2_person_rates_rec;
             close cur_option2_rate;

End populate_person_option2_rec;

Function get_option2_rate_ws_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option2_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt2_person_rates_rec.ws_val;

End get_option2_rate_ws_amt;

Function get_option2_unit(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2
Is
----- ws_nnmntry_uom needs to be decoded from lookup table
    Cursor cur_option2_units is
       Select decode(ws_nnmntry_uom,null,currency,hr_general.decode_lookup('BEN_NNMNTRY_UOM',ws_nnmntry_uom))
        From  ben_cwb_person_rates bcpr,ben_cwb_pl_dsgn  bcpd
                          Where bcpr.group_per_in_ler_id = p_group_per_in_ler_id
                          And   bcpd.group_pl_id    = p_group_plan_id
                          And   bcpd.lf_evt_ocrd_dt = p_lf_evnt_ocrd_dt
                          And   bcpr.pl_id          = bcpd.pl_id
                          And   bcpr.group_pl_id    = bcpd.group_pl_id
                          And   bcpr.oipl_id        = bcpd.oipl_id
                          And   bcpr.lf_evt_ocrd_dt = bcpd.lf_evt_ocrd_dt
                          and   bcpr.elig_flag = 'Y'
             and   oipl_ordr_num = 2;

  l_option2_unit  varchar2(30);
Begin
  open  cur_option2_units;
  fetch cur_option2_units into l_option2_unit;
  close cur_option2_units;
  return l_option2_unit;
End get_option2_unit;


Function get_option2_elg_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin

   populate_person_option2_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt2_person_rates_rec.ELIG_SAL_VAL;

End get_option2_elg_sal;

Function get_option2_elg_per_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
Is
Begin

	 populate_person_option2_rec(
	                     p_group_plan_id,
	                     p_lf_evnt_ocrd_dt,
	                     p_oipl_id,
	                     p_group_per_in_ler_id,
	                     p_pl_id,
                     p_ws_sub_acty_typ_cd);

if (g_opt2_person_rates_rec.elig_sal_val <> 0) then
  return round( (g_opt2_person_rates_rec.ws_val / g_opt2_person_rates_rec.elig_sal_val) * 100,2);
else
  return to_number(null);
end if;

End get_option2_elg_per_sal;

Function get_option2_rate_reco_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option2_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt2_person_rates_rec.REC_VAL;

End get_option2_rate_reco_amt;

Function get_option2_rate_oth_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option2_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt2_person_rates_rec.OTH_COMP_VAL;

End get_option2_rate_oth_sal;

Function get_option2_rate_sta_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option2_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt2_person_rates_rec.STAT_SAL_VAL;

End get_option2_rate_sta_sal;

Function get_option2_rate_tot_comp(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option2_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt2_person_rates_rec.TOT_COMP_VAL;

End get_option2_rate_tot_comp;


Function get_option2_rate_misc1(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option2_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt2_person_rates_rec.MISC1_VAL;

End get_option2_rate_misc1;

Function get_option2_rate_misc2(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option2_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt2_person_rates_rec.MISC2_VAL;

End get_option2_rate_misc2;

Function get_option2_rate_misc3(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option2_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt2_person_rates_rec.MISC3_VAL;

End get_option2_rate_misc3;


Function get_option3_name(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2
is
  cursor cur_option3_name is
    Select name
    From  ben_cwb_pl_dsgn
    Where pl_id = p_group_plan_id
    And   group_pl_id = p_group_plan_id
    And   lf_evt_ocrd_dt = p_lf_evnt_ocrd_dt
    -- And   oipl_id  <> -1
   -- And   opt_count = 3;
   and oipl_ordr_num = 3;

   l_option3_name varchar2(240);
Begin

     open cur_option3_name;
     fetch  cur_option3_name into l_option3_name;
     close  cur_option3_name;
     return l_option3_name;
End get_option3_name;

Procedure populate_person_option3_rec(
      p_group_plan_id in number,
      p_lf_evt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2)
Is
    cursor cur_option3_rate is
      Select bcpr.*
      From  ben_cwb_person_rates bcpr,ben_cwb_pl_dsgn  bcpd
      Where bcpr.group_per_in_ler_id = p_group_per_in_ler_id
      And   bcpd.group_pl_id = p_group_plan_id
     -- AND   bcpd.pl_id       = p_group_plan_id
      And   bcpd.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
      --And   bcpd.oipl_id  <> -1
      --And   bcpd.opt_count = 3
       and oipl_ordr_num = 3
      And   bcpd.pl_id = bcpr.pl_id
      And   bcpd.group_pl_id  = bcpr.group_pl_id
      And   bcpd.oipl_id = bcpr.oipl_id
      And   bcpd.lf_evt_ocrd_dt = bcpr.lf_evt_ocrd_dt
      and   bcpr.elig_flag = 'Y';
Begin

            g_opt3_person_rates_rec := null;
            open cur_option3_rate;
            fetch cur_option3_rate into  g_opt3_person_rates_rec;
            close cur_option3_rate;

End populate_person_option3_rec;

Function get_option3_rate_ws_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option3_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt3_person_rates_rec.ws_val;

End get_option3_rate_ws_amt;

Function get_option3_unit(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2
Is
-- ws_nnmntry_uom needs to be decoded from lookup table
    Cursor cur_option3_units is
       Select decode(ws_nnmntry_uom,null,currency,hr_general.decode_lookup('BEN_NNMNTRY_UOM',ws_nnmntry_uom))
       From  ben_cwb_person_rates bcpr,ben_cwb_pl_dsgn  bcpd
                         Where bcpr.group_per_in_ler_id = p_group_per_in_ler_id
                         And   bcpd.group_pl_id    = p_group_plan_id
                         And   bcpd.lf_evt_ocrd_dt = p_lf_evnt_ocrd_dt
                         And   bcpr.pl_id          = bcpd.pl_id
                         And   bcpr.group_pl_id    = bcpd.group_pl_id
                         And   bcpr.oipl_id        = bcpd.oipl_id
                         And   bcpr.lf_evt_ocrd_dt = bcpd.lf_evt_ocrd_dt
                         and   bcpr.elig_flag = 'Y'
            and   oipl_ordr_num = 3;

  l_option3_unit  varchar2(30);
Begin
  open  cur_option3_units;
  fetch cur_option3_units into l_option3_unit;
  close cur_option3_units;
  return l_option3_unit;
End get_option3_unit;


Function get_option3_elg_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin

   populate_person_option3_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt3_person_rates_rec.ELIG_SAL_VAL;

End get_option3_elg_sal;

Function get_option3_elg_per_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
Is
Begin

   populate_person_option3_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
if (g_opt3_person_rates_rec.elig_sal_val <> 0) then
  return round( (g_opt3_person_rates_rec.ws_val / g_opt3_person_rates_rec.elig_sal_val) * 100,2);
else
  return to_number(null);
end if;


End get_option3_elg_per_sal;

Function get_option3_rate_reco_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option3_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt3_person_rates_rec.REC_VAL;

End get_option3_rate_reco_amt;

Function get_option3_rate_oth_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option3_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt3_person_rates_rec.OTH_COMP_VAL;

End get_option3_rate_oth_sal;

Function get_option3_rate_sta_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option3_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt3_person_rates_rec.STAT_SAL_VAL;

End get_option3_rate_sta_sal;

Function get_option3_rate_tot_comp(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option3_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt3_person_rates_rec.TOT_COMP_VAL;

End get_option3_rate_tot_comp;


Function get_option3_rate_misc1(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option3_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt3_person_rates_rec.MISC1_VAL;

End get_option3_rate_misc1;

Function get_option3_rate_misc2(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option3_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt3_person_rates_rec.MISC2_VAL;

End get_option3_rate_misc2;

Function get_option3_rate_misc3(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id              in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option3_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt3_person_rates_rec.MISC3_VAL;
End get_option3_rate_misc3;

Function get_option4_name(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2
is
  cursor cur_option4_name is
    Select name
    From  ben_cwb_pl_dsgn
    Where pl_id = p_group_plan_id
    And   group_pl_id = p_group_plan_id
    And   lf_evt_ocrd_dt = p_lf_evnt_ocrd_dt
   -- And   oipl_id  <> -1
   -- And   opt_count = 4;
    and oipl_ordr_num = 4 ;

   l_option4_name varchar2(240);
Begin

     open cur_option4_name;
     fetch  cur_option4_name into l_option4_name;
     close  cur_option4_name;
     return l_option4_name;
End get_option4_name;

Procedure populate_person_option4_rec(
      p_group_plan_id in number,
      p_lf_evt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2)
Is
    cursor cur_option4_rate is
      Select bcpr.*
      From  ben_cwb_person_rates bcpr,ben_cwb_pl_dsgn  bcpd
      Where bcpr.group_per_in_ler_id = p_group_per_in_ler_id
      And   bcpd.group_pl_id = p_group_plan_id
     -- AND   bcpd.pl_id       = p_group_plan_id
      And   bcpd.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
      --And   bcpd.oipl_id  <> -1
     -- And   bcpd.opt_count = 4
           and oipl_ordr_num = 4
      And   bcpd.pl_id = bcpr.pl_id
      And   bcpd.group_pl_id  = bcpr.group_pl_id
      And   bcpd.oipl_id = bcpr.oipl_id
      And   bcpd.lf_evt_ocrd_dt = bcpr.lf_evt_ocrd_dt
      and   bcpr.elig_flag = 'Y';
Begin
            g_opt4_person_rates_rec := null;
            open cur_option4_rate;
            fetch cur_option4_rate into  g_opt4_person_rates_rec;
            close cur_option4_rate;

End populate_person_option4_rec;

Function get_option4_rate_ws_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option4_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt4_person_rates_rec.ws_val;

End get_option4_rate_ws_amt;

Function get_option4_unit(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2
Is
-- ws_nnmntry_uom needs to be decoded from lookup table
    Cursor cur_option4_units is
       Select decode(ws_nnmntry_uom,null,currency,hr_general.decode_lookup('BEN_NNMNTRY_UOM',ws_nnmntry_uom))
        From  ben_cwb_person_rates bcpr,ben_cwb_pl_dsgn  bcpd
                          Where bcpr.group_per_in_ler_id = p_group_per_in_ler_id
                          And   bcpd.group_pl_id    = p_group_plan_id
                          And   bcpd.lf_evt_ocrd_dt = p_lf_evnt_ocrd_dt
                          And   bcpr.pl_id          = bcpd.pl_id
                          And   bcpr.group_pl_id    = bcpd.group_pl_id
                          And   bcpr.oipl_id        = bcpd.oipl_id
                          And   bcpr.lf_evt_ocrd_dt = bcpd.lf_evt_ocrd_dt
                          and   bcpr.elig_flag = 'Y'
             and   oipl_ordr_num = 4;

  l_option4_unit  varchar2(30);
Begin
  open  cur_option4_units;
  fetch cur_option4_units into l_option4_unit;
  close cur_option4_units;
  return l_option4_unit;
End get_option4_unit;


Function get_option4_elg_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin

   populate_person_option4_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt4_person_rates_rec.ELIG_SAL_VAL;

End get_option4_elg_sal;

Function get_option4_elg_per_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
Is
Begin

	 populate_person_option4_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
if (g_opt4_person_rates_rec.elig_sal_val <> 0) then
  return round( (g_opt4_person_rates_rec.ws_val / g_opt4_person_rates_rec.elig_sal_val) * 100,2);
else
  return to_number(null);
end if;

End get_option4_elg_per_sal;

Function get_option4_rate_reco_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option4_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt4_person_rates_rec.REC_VAL;

End get_option4_rate_reco_amt;

Function get_option4_rate_oth_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option4_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt4_person_rates_rec.OTH_COMP_VAL;

End get_option4_rate_oth_sal;

Function get_option4_rate_sta_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option4_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt4_person_rates_rec.STAT_SAL_VAL;

End get_option4_rate_sta_sal;

Function get_option4_rate_tot_comp(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option4_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt4_person_rates_rec.TOT_COMP_VAL;

End get_option4_rate_tot_comp;


Function get_option4_rate_misc1(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option4_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt4_person_rates_rec.MISC1_VAL;

End get_option4_rate_misc1;

Function get_option4_rate_misc2(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option4_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt4_person_rates_rec.MISC2_VAL;

End get_option4_rate_misc2;

Function get_option4_rate_misc3(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id              in number,
      p_ws_sub_acty_typ_cd in varchar2) return number
is
Begin
   populate_person_option4_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt4_person_rates_rec.MISC3_VAL;
End get_option4_rate_misc3;


--
PROCEDURE populate_person_rates_rec(
      p_group_plan_id in number,
      p_lf_evt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2,
      p_new_or_prior in varchar2  ) is

-- *********
-- This next cursor never retreives any record as the person
-- always gets a new group_per_in_ler_id for each cycle. So for
-- one group_per_in_ler_id, we can find only one lf_evt_ocrd_dt
cursor c_prior_person_rate_dt is
      select max(lf_evt_ocrd_dt)
      from ben_cwb_person_rates
      where group_per_in_ler_id = p_group_per_in_ler_id
      and   group_pl_id = p_group_plan_id
      --and   pl_id  =    p_pl_id
      and   lf_evt_ocrd_dt < p_lf_evt_ocrd_dt
      and   elig_flag = 'Y';

-- *** change here. commented out group_pl_id and using pl_id
cursor c_person_rates (c_lf_evt_ocrd_dt Date) is
      select * from ben_cwb_person_rates
      where group_per_in_ler_id = p_group_per_in_ler_id
      and   group_pl_id = p_group_plan_id
      --and    pl_id  =    p_pl_id
      and    oipl_id =  p_oipl_id
      and   lf_evt_ocrd_dt = c_lf_evt_ocrd_dt
      and   elig_flag = 'Y';


 l_lf_evt_ocrd_dt date;
begin
  hr_utility.set_location('Entering populate_person_rates_rec. p_ws_sub_acty_typ_cd='||p_ws_sub_acty_typ_cd,10);
 -- if (p_ws_sub_acty_typ_cd ='ICM7') then -- Salary Plan
  hr_utility.set_location('p_new_or_prior='||p_ws_sub_acty_typ_cd,10);
    if (p_new_or_prior ='NEW') then

      g_person_rates_rec := null;
      open  c_person_rates (p_lf_evt_ocrd_dt);
      fetch c_person_rates into g_person_rates_rec;
      close c_person_rates;

    elsif (p_new_or_prior ='PRIOR') then
      open  c_prior_person_rate_dt;
      fetch c_prior_person_rate_dt into l_lf_evt_ocrd_dt;
      close c_prior_person_rate_dt;

      if (l_lf_evt_ocrd_dt is not null) then
        g_prior_person_rates_rec := null;
        open  c_person_rates (l_lf_evt_ocrd_dt);
        fetch c_person_rates into g_prior_person_rates_rec;
        close c_person_rates;
      end if;

    end if;
 -- end if;  then -- Salary Plan
end;

FUNCTION get_pay_rate (
     		  p_group_plan_id in number,
    		  p_lf_evnt_ocrd_dt in Date,
    		  p_oipl_id        in number,
    		  p_group_per_in_ler_id in number,
   		  p_pl_id            in number,
  		  p_ws_sub_acty_typ_cd in varchar2,
   		  p_new_or_prior  in varchar2) return number is


      l_proposed_salary number := 0;

      cursor c_pay_proposal is
            select max(nvl(proposed_salary_n,0))
            from per_pay_proposals ppp  ,ben_cwb_person_rates rts
            where rts.pay_proposal_id = ppp.pay_proposal_id
            and   rts.group_per_in_ler_id = p_group_per_in_ler_id
            and   rts.group_pl_id =  p_group_plan_id
            and   rts.lf_evt_ocrd_dt = p_lf_evnt_ocrd_dt
            and   rts.ws_val is not null
      	    and   rts.elig_flag = 'Y';
      cursor c_prior_pay_proposal is
      	select nvl(base_salary,0)
      	from ben_cwb_person_info
      	where group_per_in_ler_id = p_group_per_in_ler_id;

begin

   if (p_new_or_prior = 'NEW') then
      open c_pay_proposal;
      fetch c_pay_proposal into l_proposed_salary;
      close c_pay_proposal;
   else
      -- we need to get the prior salary
      open c_prior_pay_proposal;
      fetch c_prior_pay_proposal into l_proposed_salary;
      close c_prior_pay_proposal;
   end if;
   return l_proposed_salary;
end get_pay_rate;



FUNCTION get_pay_rate_change_amount (
      p_group_plan_id in number,
      p_lf_evt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number is

      l_new_proposed_salary   number;
      l_prior_proposed_salary number;
      l_pay_proposal          varchar2(30);
begin
   l_new_proposed_salary :=
   get_pay_rate (
    p_group_plan_id,p_lf_evt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');

   l_prior_proposed_salary :=
   get_pay_rate (
     p_group_plan_id,p_lf_evt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'PRIOR');

   if (l_new_proposed_salary = l_prior_proposed_salary) then
      return 0;
   else
      return l_new_proposed_salary - l_prior_proposed_salary;
   end if;
end get_pay_rate_change_amount;


FUNCTION get_pay_rate_change_percent (
      p_group_plan_id in number,
      p_lf_evt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number is

      l_new_proposed_salary   number;
      l_prior_proposed_salary number;
      l_pay_proposal          varchar2(30);
begin
   l_new_proposed_salary :=
   get_pay_rate (
    p_group_plan_id,p_lf_evt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');

   l_prior_proposed_salary :=
   get_pay_rate (
     p_group_plan_id,p_lf_evt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'PRIOR');


  if (l_new_proposed_salary = l_prior_proposed_salary) then
      return 0;
   else
      if (l_new_proposed_salary = 0 ) then
         return 0;
      elsif (l_prior_proposed_salary = 0) then
        return 100;
      end if;
      return round(((l_new_proposed_salary - l_prior_proposed_salary) / l_prior_proposed_salary) * 100,2);
   end if;
end get_pay_rate_change_percent;

FUNCTION get_pay_rate_change_date (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2,
      p_new_or_prior  in varchar2) return varchar2 is


      l_change_date varchar2(30);

      -- return the comp_posting_date
      cursor c_pay_proposal_date is
                 select max(change_date)
                 from per_pay_proposals ppp
                     ,ben_cwb_person_rates rts
                 where rts.pay_proposal_id = ppp.pay_proposal_id
                 and   rts.group_per_in_ler_id = p_group_per_in_ler_id
                 and   rts.group_pl_id =  p_group_plan_id
                 and   rts.lf_evt_ocrd_dt = p_lf_evnt_ocrd_dt
                 and   rts.ws_val is not null
      	  	 and   rts.elig_flag = 'Y';


      cursor c_prior_pay_proposal_date is
      select BASE_SALARY_CHANGE_DATE
      from ben_cwb_person_info
      where group_per_in_ler_id = p_group_per_in_ler_id;

begin
-- *********
   if (p_new_or_prior = 'NEW') then
      open c_pay_proposal_date;
      fetch c_pay_proposal_date into l_change_date;
      close c_pay_proposal_date;
   else
      -- we need to get the prior salary
      open c_prior_pay_proposal_date;
      fetch c_prior_pay_proposal_date into l_change_date;
      close c_prior_pay_proposal_date;
   end if;

   return l_change_date;

end get_pay_rate_change_date;


FUNCTION get_pay_rate_basis (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return Varchar2 is

Cursor c_pay_rate_basis is
select initcap(pay_basis)
from   per_pay_bases ppb,
       per_all_assignments_f  paaf
where  ppb.pay_basis_id = paaf.pay_basis_id
and    sysdate between paaf.effective_start_date and paaf.effective_end_date
and    paaf.primary_flag = 'Y'
and    paaf.assignment_id = g_person_rates_rec.assignment_id;

l_pay_basis  per_pay_bases.pay_basis%Type;
BEGIN

   populate_person_rates_rec (
    p_group_plan_id,p_lf_evnt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');

   OPEN  c_pay_rate_basis;
   fetch c_pay_rate_basis into l_pay_basis;
   close c_pay_rate_basis;

   return l_pay_basis;
end get_pay_rate_basis;

FUNCTION get_plan_rate_ws_amt (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number is
begin
   populate_person_rates_rec (
     p_group_plan_id,p_lf_evnt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');

   return g_person_rates_rec.ws_val;
end get_plan_rate_ws_amt;

FUNCTION get_plan_rate_elig_sal (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number is
begin
   populate_person_rates_rec (
     p_group_plan_id,p_lf_evnt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');

   return g_person_rates_rec.elig_sal_val;
end get_plan_rate_elig_sal;

FUNCTION get_plan_percent_elig_sal (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number is
begin
   populate_person_rates_rec (
    p_group_plan_id,p_lf_evnt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');

if (g_person_rates_rec.elig_sal_val <>0 ) then
   return round( (g_person_rates_rec.ws_val / g_person_rates_rec.elig_sal_val) * 100,2);
else
   return to_number(null);
end if;

end get_plan_percent_elig_sal;

FUNCTION get_plan_rate_rec_amt (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number is
begin
   populate_person_rates_rec (
     p_group_plan_id,p_lf_evnt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');

   return g_person_rates_rec.rec_val;
end get_plan_rate_rec_amt;

FUNCTION get_plan_rate_other_sal (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number is
begin
   populate_person_rates_rec (
     p_group_plan_id,p_lf_evnt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');

   return g_person_rates_rec.oth_comp_val;
end get_plan_rate_other_sal;

FUNCTION get_plan_rate_stat_sal (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number is
begin
   populate_person_rates_rec (
     p_group_plan_id,p_lf_evnt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');

   return g_person_rates_rec.stat_sal_val;
end get_plan_rate_stat_sal;

FUNCTION get_plan_rate_total_comp (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number is
begin
   populate_person_rates_rec (
     p_group_plan_id,p_lf_evnt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');

   return g_person_rates_rec.tot_comp_val;
end get_plan_rate_total_comp;

FUNCTION get_plan_rate_misc1 (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number is
begin
   populate_person_rates_rec (
     p_group_plan_id,p_lf_evnt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');

   return g_person_rates_rec.misc1_val;
end get_plan_rate_misc1;

FUNCTION get_plan_rate_misc2 (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number is
begin
   populate_person_rates_rec (
     p_group_plan_id,p_lf_evnt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');

   return g_person_rates_rec.misc2_val;
end get_plan_rate_misc2;

FUNCTION get_plan_rate_misc3 (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number is
begin
   populate_person_rates_rec (
     p_group_plan_id,p_lf_evnt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');

   return g_person_rates_rec.misc3_val;
end get_plan_rate_misc3;

PROCEDURE  populate_asgn_txn_rec (
    p_assignment_id     in number,
    p_asg_updt_eff_date in date) IS

BEGIN

   --IF (nvl(g_asgn_txn_rec.assignment_id,-1) <> p_assignment_id OR
   --    nvl(to_date(g_asgn_txn_rec.asg_updt_eff_date,'RRRR/MM/DD'),hr_general.start_of_time  ) <> p_asg_updt_eff_date ) THEN

       g_asgn_txn_rec := null;
       OPEN  g_cursor_asgn_txn (p_assignment_id, to_char(p_asg_updt_eff_date,'RRRR/MM/DD'));
       FETCH g_cursor_asgn_txn into g_asgn_txn_rec;
       CLOSE g_cursor_asgn_txn;

   --END IF;
END populate_asgn_txn_rec;

FUNCTION get_new_job (
    p_assignment_id     in number,
    p_asg_updt_eff_date in date) return varchar2 IS
begin
     populate_asgn_txn_rec (p_assignment_id, p_asg_updt_eff_date);

     if ( g_asgn_txn_rec.job_id is not null) then
        return ( hr_general.decode_job(g_asgn_txn_rec.job_id));
     end if;

     return null;
end get_new_job;

FUNCTION get_new_position (
    p_assignment_id     in number,
    p_asg_updt_eff_date in date) return varchar2 IS
begin
     populate_asgn_txn_rec (p_assignment_id, p_asg_updt_eff_date);
     -- Using DECODE_POSITION_LATEST_NAME instead of DECODE_POSITION  : Anadi
     if ( g_asgn_txn_rec.position_id is not null) then
        return ( hr_general.DECODE_POSITION_LATEST_NAME(g_asgn_txn_rec.position_id));
     end if;

     return null;
end get_new_position;

FUNCTION get_new_grade (
    p_assignment_id     in number,
    p_asg_updt_eff_date in date) return varchar2 IS
begin
     populate_asgn_txn_rec (p_assignment_id, p_asg_updt_eff_date);

     if ( g_asgn_txn_rec.grade_id is not null) then
        return ( hr_general.decode_grade (g_asgn_txn_rec.grade_id));
     end if;

     return null;
end get_new_grade ;


FUNCTION get_new_people_group(
    p_assignment_id     in number,
    p_asg_updt_eff_date in date) return varchar2 IS
begin
     populate_asgn_txn_rec (p_assignment_id, p_asg_updt_eff_date);

     if ( g_asgn_txn_rec.people_group_id is not null) then
        return ( hr_general.decode_people_group (g_asgn_txn_rec.people_group_id));
     end if;

     return null;
end get_new_people_group ;

FUNCTION get_new_asgn_flex(
    p_assignment_id     in number,
    p_asg_updt_eff_date in date,
    p_asg_flex_num      in number
    ) return varchar2 IS

    l_asgn_flex  ben_transaction.attribute11%Type;
begin
     populate_asgn_txn_rec (p_assignment_id, p_asg_updt_eff_date);

     if (p_asg_flex_num = 1) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex1;
     elsif (p_asg_flex_num = 2) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex2;
     elsif (p_asg_flex_num = 3) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex3;
     elsif (p_asg_flex_num = 4) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex4;
     elsif (p_asg_flex_num = 5) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex5;
     elsif (p_asg_flex_num = 6) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex6;
     elsif (p_asg_flex_num = 7) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex7;
     elsif (p_asg_flex_num = 8) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex8;
     elsif (p_asg_flex_num = 9) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex9;
     elsif (p_asg_flex_num = 10) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex10;
     elsif (p_asg_flex_num = 11) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex11;
     elsif (p_asg_flex_num = 12) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex12;
     elsif (p_asg_flex_num = 13) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex13;
     elsif (p_asg_flex_num = 14) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex14;
     elsif (p_asg_flex_num = 15) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex15;
     elsif (p_asg_flex_num = 16) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex16;
     elsif (p_asg_flex_num = 17) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex17;
     elsif (p_asg_flex_num = 18) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex18;
     elsif (p_asg_flex_num = 19) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex19;
     elsif (p_asg_flex_num = 20) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex20;
     elsif (p_asg_flex_num = 21) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex21;
     elsif (p_asg_flex_num = 22) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex22;
     elsif (p_asg_flex_num = 23) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex23;
     elsif (p_asg_flex_num = 24) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex24;
     elsif (p_asg_flex_num = 25) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex25;
     elsif (p_asg_flex_num = 26) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex26;
     elsif (p_asg_flex_num = 27) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex27;
     elsif (p_asg_flex_num = 28) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex28;
     elsif (p_asg_flex_num = 29) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex29;
     elsif (p_asg_flex_num = 30) then
       l_asgn_flex := g_asgn_txn_rec.asgn_flex30;
     end if;

     return l_asgn_flex;

end get_new_asgn_flex;

function get_new_perf_rating (
    p_assignment_id     in number,
    p_perf_revw_strt_dt in date,
    p_emp_interview_typ_cd in varchar2 ) return varchar2 IS

CURSOR c_perf_rate  is
select hr_general.decode_lookup('PERFORMANCE_RATING',attribute3)
From  ben_transaction
where transaction_id = p_assignment_id
and   transaction_type = 'CWBPERF'||to_char(p_perf_revw_strt_dt,'rrrr/mm/dd')
||p_emp_interview_typ_cd;

l_perf_rating ben_transaction.attribute3%Type;
begin
   open  c_perf_rate;
   fetch c_perf_rate into l_perf_rating;
   close c_perf_rate;

   return l_perf_rating;

end get_new_perf_rating;

--
function get_group_short_name (
                 p_plan_id                in number ,
                 p_lf_evt_ocrd_dt         in date   ) return varchar2 is
cursor c_doc_short_name is
select pqh_document_short_name
from   ben_cwb_pl_dsgn
where  pl_id    = p_plan_id
and    oipl_id =  -1
and    lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;

l_short_name  pqh_documents_f.short_name%type;
 begin

     if (p_plan_id is null) then
       return null;
     end if;

     open c_doc_short_name;
     fetch c_doc_short_name into l_short_name;
     close c_doc_short_name;

      return l_short_name;
end get_group_short_name;


procedure  populate_ws_mgr(p_group_per_in_ler_id in number) is

    cursor c_ws_mgr_name is
        select info.full_name, info.brief_name, info.custom_name
        from   ben_cwb_person_info info,
                ben_cwb_group_hrchy hrchy
        where  hrchy.emp_per_in_ler_id = p_group_per_in_ler_id
        and    hrchy.mgr_per_in_ler_id = info.group_per_in_ler_id
        and    hrchy.lvl_num = 1;
begin

	open c_ws_mgr_name;
	g_ws_mgr_full_name := null;
	g_ws_mgr_brief_name := null;
	g_ws_mgr_custom_name := null;
        fetch c_ws_mgr_name  into g_ws_mgr_full_name,g_ws_mgr_brief_name,g_ws_mgr_custom_name;
        close c_ws_mgr_name;

end  populate_ws_mgr;


function get_ws_mgr_full_name(p_group_per_in_ler_id in number) return varchar2 is
begin
	  --if (g_ws_mgr_full_name is null) then
	        populate_ws_mgr(p_group_per_in_ler_id);
	  --end if;
	  return g_ws_mgr_full_name;
end  get_ws_mgr_full_name;


function get_ws_mgr_brief_name(p_group_per_in_ler_id in number) return varchar2 is
	begin
	  --if (g_ws_mgr_brief_name is null) then
	        populate_ws_mgr(p_group_per_in_ler_id);
	  --end if;
	  return g_ws_mgr_brief_name;
end  get_ws_mgr_brief_name;


function get_ws_mgr_custom_name(p_group_per_in_ler_id in number) return varchar2 is
begin
	  --if (g_ws_mgr_custom_name is null) then
	        populate_ws_mgr(p_group_per_in_ler_id);
	  --end if;
	  return g_ws_mgr_custom_name;
end  get_ws_mgr_custom_name;


--

Function get_option_currency(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2,
      p_oipl_ordr_num in number) return varchar2
Is

    Cursor cur_option_currency is
       Select currency
       From  ben_cwb_person_rates bcpr,ben_cwb_pl_dsgn  bcpd
       Where bcpr.group_per_in_ler_id = p_group_per_in_ler_id
               And   bcpd.group_pl_id    = p_group_plan_id
               And   bcpd.lf_evt_ocrd_dt = p_lf_evnt_ocrd_dt
               And   bcpr.pl_id          = bcpd.pl_id
               And   bcpr.group_pl_id    = bcpd.group_pl_id
               And   bcpr.oipl_id        = bcpd.oipl_id
               And   bcpr.lf_evt_ocrd_dt = bcpd.lf_evt_ocrd_dt
               And   bcpr.elig_flag = 'Y'
               And   oipl_ordr_num = p_oipl_ordr_num;

  l_option_currency  varchar2(30);
Begin
  open  cur_option_currency;
  fetch cur_option_currency into l_option_currency;
  close cur_option_currency;
  return l_option_currency;
End get_option_currency;



Function get_option1_currency(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2
Is
    l_option1_currency  varchar2(30);
Begin
  l_option1_currency := get_option_currency(p_group_plan_id,p_lf_evnt_ocrd_dt,
  					    p_oipl_id,p_group_per_in_ler_id,
  					    p_pl_id,p_ws_sub_acty_typ_cd,1);
  return l_option1_currency;
End get_option1_currency;

Function get_option2_currency(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2
Is
    l_option2_currency  varchar2(30);
Begin
  l_option2_currency := get_option_currency(p_group_plan_id,p_lf_evnt_ocrd_dt,
  					    p_oipl_id,p_group_per_in_ler_id,
  					    p_pl_id,p_ws_sub_acty_typ_cd,2);
  return l_option2_currency;
End get_option2_currency;

Function get_option3_currency(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2
Is
    l_option3_currency  varchar2(30);
Begin
  l_option3_currency := get_option_currency(p_group_plan_id,p_lf_evnt_ocrd_dt,
  					    p_oipl_id,p_group_per_in_ler_id,
  					    p_pl_id,p_ws_sub_acty_typ_cd,3);
  return l_option3_currency;
End get_option3_currency;

Function get_option4_currency(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2
Is
    l_option4_currency  varchar2(30);
Begin
  l_option4_currency := get_option_currency(p_group_plan_id,p_lf_evnt_ocrd_dt,
  					    p_oipl_id,p_group_per_in_ler_id,
  					    p_pl_id,p_ws_sub_acty_typ_cd,4);
  return l_option4_currency;
End get_option4_currency;

FUNCTION get_plan_rate_start_dt (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return varchar2 is
begin
   populate_person_rates_rec (
     p_group_plan_id,p_lf_evnt_ocrd_dt,
    p_oipl_id,p_group_per_in_ler_id, p_pl_id,
    p_ws_sub_acty_typ_cd, 'NEW');
   return g_person_rates_rec.ws_rt_start_date;
end get_plan_rate_start_dt;

Function get_option1_rate_start_dt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2 is
Begin
   populate_person_option1_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt1_person_rates_rec.ws_rt_start_date;
end get_option1_rate_start_dt;

Function get_option2_rate_start_dt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2 is
Begin
   populate_person_option2_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt2_person_rates_rec.ws_rt_start_date;
end get_option2_rate_start_dt;

Function get_option3_rate_start_dt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2 is
Begin
   populate_person_option3_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt3_person_rates_rec.ws_rt_start_date;
end get_option3_rate_start_dt;

Function get_option4_rate_start_dt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2 is
Begin
   populate_person_option4_rec(
                     p_group_plan_id,
                     p_lf_evnt_ocrd_dt,
                     p_oipl_id,
                     p_group_per_in_ler_id,
                     p_pl_id,
                     p_ws_sub_acty_typ_cd);
   return  g_opt4_person_rates_rec.ws_rt_start_date;
end get_option4_rate_start_dt;

Function get_custom_segment_message(
     p_custom_seg_text in varchar2 ) return varchar2
is
l_return_text varchar2(200) := null;
l_prod_name   varchar2(5)   := null;
l_msg_name    varchar2(100)   := null;
begin
l_return_text := p_custom_seg_text;
if(p_custom_seg_text is not null) then
    if nvl(substr(p_custom_seg_text,1,4),'XXX') = 'INFO'  then
        if((substr(p_custom_seg_text,6,3) is not null) AND (substr(p_custom_seg_text,10) is not null)) then
            l_prod_name := substr(p_custom_seg_text,6,3);
            l_msg_name := substr(p_custom_seg_text,10);
            l_return_text := fnd_message.get_string(l_prod_name,l_msg_name);
        end if;
    end if;
end if;
return l_return_text;
end get_custom_segment_message;

--

/* ---------------------------------------------------------------------
   END -- Changes for Printable document
   --------------------------------------------------------------------- */
END;

/
