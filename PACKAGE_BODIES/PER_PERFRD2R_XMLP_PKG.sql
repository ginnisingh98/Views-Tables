--------------------------------------------------------
--  DDL for Package Body PER_PERFRD2R_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERFRD2R_XMLP_PKG" AS
/* $Header: PERFRD2RB.pls 120.0 2007/12/24 13:18:20 amakrish noship $ */

function c_set_unitsformula(cotorep_category in varchar2, age in number, previous_cotorep in varchar2, disability_rate in number, due_to_wa in varchar2, disability_class_code in varchar2, pid in number) return number is
  l_total_cotorep number;
  l_total_accident number;
  l_total_other number;
  pos1 integer;
  pos2 integer;
  l_base_unit number;
  l_xcot_a number;
  l_xcot_b number;
  l_xcot_c number;
  l_xcot_young_age number;
  l_xcot_old_age number;
  l_xcot_age_units number;
  l_xcot_training_hours number;
  l_xcot_training_units number;
  l_xcot_ap number;
  l_xcot_impro number;
  l_xcot_cat number;
  l_xcot_cdtd number;
  l_xcot_cfp number;
  l_xipp_low_rate number;
  l_xipp_medium_rate number;
  l_xipp_high_rate number;
  l_xipp_low_units number;
  l_xipp_medium_units number;
  l_xipp_high_units number;
  l_hire_units number;
begin
        per_fr_d2_pkg.get_extra_units(p_establishment_id,
    pc_1jan,
    l_base_unit,
    l_xcot_a,
    l_xcot_b,
    l_xcot_c,
    l_xcot_young_age,
    l_xcot_old_age,
    l_xcot_age_units,
    l_xcot_training_hours,
    l_xcot_training_units,
    l_xcot_ap,
    l_xcot_impro,
    l_xcot_cat,
    l_xcot_cdtd,
    l_xcot_cfp,
    l_xipp_low_rate,
    l_xipp_medium_rate,
    l_xipp_high_rate,
    l_xipp_low_units,
    l_xipp_medium_units,
    l_xipp_high_units,
    l_hire_units);
        l_total_cotorep := l_base_unit;
  if not(cotorep_category is null) then
        if (cotorep_category = 'A') then
      l_total_cotorep := l_total_cotorep + l_xcot_a;
    elsif (cotorep_category = 'B') then
      l_total_cotorep := l_total_cotorep + l_xcot_b;
    elsif (cotorep_category = 'C') then
      l_total_cotorep := l_total_cotorep + l_xcot_c;
    end if;
        if (age >= l_xcot_old_age) or (age < l_xcot_young_age) then
      l_total_cotorep := l_total_cotorep + l_xcot_age_units;
    end if;
        if not(pc_hours_training is null)
    and (pc_hours_training >= l_xcot_training_hours)
    then
      l_total_cotorep := l_total_cotorep + l_xcot_training_units;
    end if;
            if previous_cotorep in ('AP','IMPRO','CAT','CDTD','CFP') then
      if (previous_cotorep = 'AP') then
        l_total_cotorep := l_total_cotorep + l_xcot_ap;
      elsif (previous_cotorep = 'IMPRO') then
        l_total_cotorep := l_total_cotorep + l_xcot_impro;
      elsif (previous_cotorep = 'CAT') then
        l_total_cotorep := l_total_cotorep + l_xcot_cat;
      elsif (previous_cotorep = 'CDTD') then
        l_total_cotorep := l_total_cotorep + l_xcot_cdtd;
      elsif (pc_hire_year = p_year or pc_hire_year = p_year-1) then
        l_total_cotorep := l_total_cotorep + l_xcot_cfp;
      end if;
    end if;
    if (pc_year_became_permanent = p_year or
        pc_year_became_permanent = p_year-1)     then
      l_total_cotorep := l_total_cotorep + l_hire_units;     end if;
  end if;
        l_total_accident := l_base_unit;
  if not(disability_rate is null) and (due_to_wa = 'Y') then
        if (disability_rate >= l_xipp_low_rate)
    and (disability_rate < l_xipp_medium_rate)
    then
      l_total_accident := l_total_accident + l_xipp_low_units;
    elsif (disability_rate >= l_xipp_medium_rate)
    and (disability_rate <= l_xipp_high_rate)
    then
      l_total_accident := l_total_accident + l_xipp_medium_units;
    elsif (disability_rate > l_xipp_high_rate) then
      l_total_accident := l_total_accident + l_xipp_high_units;
    end if;
        if (pc_year_became_permanent = p_year or
        pc_year_became_permanent = p_year-1) then
      l_total_accident := l_total_accident + l_hire_units;
    end if;
  end if;
        l_total_other := l_base_unit;
    if disability_class_code in ('CIVIL','MILITARY','MILITARY_EQUIVALENT') then
        if (pc_year_became_permanent = p_year or
        pc_year_became_permanent = p_year-1) then
      l_total_other := l_total_other + l_hire_units;
    end if;
  end if;
        pc_units_total := greatest(l_total_cotorep,l_total_accident,l_total_other);
        pos1 := instr (pc_count_disabled,to_char(pid)||'=');
  if pos1 = 0 then
    pc_units_coef := 0;
  else
    pos1 := pos1 + NVL(length(to_char(pid)), 0) +1;
    pos2 := instr (pc_count_disabled,';',pos1);
    if pos2 = 0 then
      pos2 := NVL(length(pc_count_disabled), 0) +1;
    end if;
    pc_units_coef := to_number(substr(pc_count_disabled,pos1,pos2-pos1));
  end if;
    pc_units_actual := round(pc_units_total*pc_units_coef,2);
    return(1);
end;

function AfterPForm return boolean is
begin
  PC_1JAN := to_date (to_char(P_YEAR)||'/01/01','YYYY/MM/DD');
  PC_31DEC := to_date (to_char(P_YEAR)||'/12/31','YYYY/MM/DD');
  PC_31DEC_m := to_char(PC_31DEC, 'dd-mon-yyyy');
  return (TRUE);
end;

function BeforeReport return boolean is
  l_return_code integer;
  l_headcount_obligation number;
  l_headcount_particular number;
  l_basis_obligation number;
  l_obligation number;
  l_breakdown_particular varchar2(32000);
  l_count_disabled varchar2(32000);
  l_disabled_where_clause varchar2(32500);
begin
  --Commented By Raj hr_standard.event('BEFORE REPORT');
  l_return_code := per_fr_d2_pkg.set_headcounts
                                    (P_ESTABLISHMENT_ID,
                                     PC_1JAN,
                                     PC_31DEC,
                                     l_headcount_obligation,
                                     l_headcount_particular,
                                     l_basis_obligation,
                                     l_obligation,
                                     l_breakdown_particular,
                                     l_count_disabled,
                                     l_disabled_where_clause);
  PC_HEADCOUNT_OBLIGATION := l_headcount_obligation;
  PC_HEADCOUNT_PARTICULAR := l_headcount_particular;
  PC_BASIS_OBLIGATION := l_basis_obligation;
  PC_OBLIGATION := l_obligation;
  PC_BREAKDOWN_PARTICULAR := l_breakdown_particular;
  PC_COUNT_DISABLED := l_count_disabled;
  PC_DISABLED_WHERE_CLAUSE := l_disabled_where_clause;
  return (TRUE);
end;

function fc_set_job_infoformula(pid in number) return number is
  l_pcs_code              varchar2(10);
  l_job_title             varchar2(240);
  l_hours_training        number;
  l_hire_year             number;
  l_year_became_permanent number;
begin
  per_fr_d2_pkg.get_job_info(p_establishment_id,
                             pid,
                             pc_1jan,
                             pc_31dec,
                             p_year,
                             l_pcs_code,
                             l_job_title,
                             l_hours_training,
                             l_hire_year,
                             l_year_became_permanent);
  pc_pcs_code := l_pcs_code;
  pc_job_title := l_job_title;
  pc_hours_training := l_hours_training;
  pc_hire_year := l_hire_year;
  pc_year_became_permanent := l_year_became_permanent;
  return(1);
end;

function g_disabled_empgroupfilter(disability_start_date in date, disability_end_date in date) return boolean is
begin
  if nvl(disability_start_date,to_date('1900/01/01','YYYY/MM/DD')) <= pc_31dec
    and nvl(disability_end_date,to_date('4712/12/31','YYYY/MM/DD')) >= pc_1jan
  then
    return (TRUE);
  else
    return (FALSE);
  end if;
RETURN NULL; end;

function AfterReport return boolean is
begin
  --Commented By Raj hr_standard.event('AFTER REPORT');
  return (TRUE);

end;

--Functions to refer Oracle report placeholders--

 Function PC_HIRE_YEAR_p return number is
	Begin
	 return PC_HIRE_YEAR;
	 END;
 Function PC_YEAR_BECAME_PERMANENT_p return number is
	Begin
	 return PC_YEAR_BECAME_PERMANENT;
	 END;
 Function PC_JOB_TITLE_p return varchar2 is
	Begin
	 return PC_JOB_TITLE;
	 END;
 Function PC_HOURS_TRAINING_p return number is
	Begin
	 return PC_HOURS_TRAINING;
	 END;
 Function PC_PCS_CODE_p return varchar2 is
	Begin
	 return PC_PCS_CODE;
	 END;
 Function PC_UNITS_TOTAL_p return number is
	Begin
	 return PC_UNITS_TOTAL;
	 END;
 Function PC_UNITS_COEF_p return number is
	Begin
	 return PC_UNITS_COEF;
	 END;
 Function PC_UNITS_ACTUAL_p return number is
	Begin
	 return PC_UNITS_ACTUAL;
	 END;
 Function PC_DISABLED_WHERE_CLAUSE_p return varchar2 is
	Begin
	 return PC_DISABLED_WHERE_CLAUSE;
	 END;
 Function PC_HEADCOUNT_OBLIGATION_p return number is
	Begin
	 return PC_HEADCOUNT_OBLIGATION;
	 END;
 Function PC_HEADCOUNT_PARTICULAR_p return number is
	Begin
	 return PC_HEADCOUNT_PARTICULAR;
	 END;
 Function PC_BASIS_OBLIGATION_p return number is
	Begin
	 return PC_BASIS_OBLIGATION;
	 END;
 Function PC_OBLIGATION_p return number is
	Begin
	 return PC_OBLIGATION;
	 END;
 Function PC_BREAKDOWN_PARTICULAR_p return varchar2 is
	Begin
	 return PC_BREAKDOWN_PARTICULAR;
	 END;
 Function PC_COUNT_DISABLED_p return varchar2 is
	Begin
	 return PC_COUNT_DISABLED;
	 END;
END PER_PERFRD2R_XMLP_PKG ;

/
