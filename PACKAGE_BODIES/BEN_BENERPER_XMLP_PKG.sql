--------------------------------------------------------
--  DDL for Package Body BEN_BENERPER_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENERPER_XMLP_PKG" AS
/* $Header: BENERPERB.pls 120.1 2007/12/10 08:31:45 vjaganat noship $ */

function CF_STANDARD_HEADERFormula return Number is
    l_concurrent_program_name    fnd_concurrent_programs_tl.user_concurrent_program_name%type ;   l_process_date               varchar2(30);
  l_mode                       hr_lookups.meaning%type ;
  l_derivable_factors          hr_lookups.meaning%type ;
  l_validate                   hr_lookups.meaning%type ;
  l_person                     per_people_f.full_name%type ;
  l_person_type                per_person_types.user_person_type%type ;
  l_program                    ben_pgm_f.name%type ;
  l_business_group             per_business_groups.name%type ;
  l_plan                       ben_pl_f.name%type ;
  l_enrollment_type_cycle      varchar2(800);
  l_plans_not_in_programs      hr_lookups.meaning%type ;
  l_just_programs              hr_lookups.meaning%type ;
  l_comp_object_selection_rule ff_formulas_f.formula_name%type ;
  l_person_selection_rule      ff_formulas_f.formula_name%type ;
  l_life_event_reason          ben_ler_f.name%type ;
  l_organization               hr_all_organization_units.name%type ;
  l_postal_zip_range           varchar2(80);
  l_reporting_group            ben_rptg_grp.name%type ;
  l_plan_type                  ben_pl_typ_f.name%type ;
  l_option                     ben_opt_f.name%type ;
  l_eligibility_profile        ben_eligy_prfl_f.name%type ;
  l_variable_rate_profile      ben_vrbl_rt_prfl_f.name%type ;
  l_legal_entity               hr_all_organization_units.name%type ;
  l_payroll                    pay_payrolls_f.payroll_name%type ;
  l_status                     fnd_lookups.meaning%type ;
  l_debug_message              varchar2(80);
  l_location                   hr_locations_all.description%type ;   l_audit_log                  hr_lookups.meaning%type ;   l_benft_group                ben_benfts_grp.name%type ;   l_date_from                  varchar2(30);


  L01  varchar2(80); L02 varchar2(80); L03 varchar2(80); L04 varchar2(80); L05 varchar2(80);
  L06  varchar2(80); L07 varchar2(80); L08 varchar2(80); L09 varchar2(80); L10 varchar2(80);
  L11  varchar2(80); L12 varchar2(80); L13 varchar2(80); L14 varchar2(80); L15 varchar2(80);
  L16  varchar2(80); L17 varchar2(80); L18 varchar2(80); L19 varchar2(80); L20 varchar2(80);
  begin


        ben_batch_utils.standard_header
    (p_concurrent_request_id      => P_CONCURRENT_REQUEST_ID,
     p_concurrent_program_name    => L_CONCURRENT_PROGRAM_NAME,
     p_process_date               => L_PROCESS_DATE,
     p_mode                       => L_MODE,
     p_derivable_factors          => L_DERIVABLE_FACTORS,
     p_validate                   => L_VALIDATE,
     p_person                     => L_PERSON,
     p_person_type                => L_PERSON_TYPE,
     p_program                    => L_PROGRAM,
     p_business_group             => L_BUSINESS_GROUP,
     p_plan                       => L_PLAN,
     p_popl_enrt_typ_cycl         => L_ENROLLMENT_TYPE_CYCLE,
     p_plans_not_in_programs      => L_PLANS_NOT_IN_PROGRAMS,
     p_just_programs              => L_JUST_PROGRAMS,
     p_comp_object_selection_rule => L_COMP_OBJECT_SELECTION_RULE,
     p_person_selection_rule      => L_PERSON_SELECTION_RULE,
     p_life_event_reason          => L_LIFE_EVENT_REASON,
     p_organization               => L_ORGANIZATION,
     p_postal_zip_range           => L_POSTAL_ZIP_RANGE,
     p_reporting_group            => L_REPORTING_GROUP,
     p_plan_type                  => L_PLAN_TYPE,
     p_option                     => L_OPTION,
     p_eligibility_profile        => L_ELIGIBILITY_PROFILE,
     p_variable_rate_profile      => L_VARIABLE_RATE_PROFILE,
     p_legal_entity               => L_LEGAL_ENTITY,
     p_payroll                    => L_PAYROLL,
     p_debug_message              => L_DEBUG_MESSAGE,
     p_location                   => L_LOCATION,
     p_audit_log                  => L_AUDIT_LOG,
     p_benfts_group               => L_BENFT_GROUP,
     p_status                     => L_STATUS,
     p_date_from                  => L_DATE_FROM);
    CP_CONCURRENT_PROGRAM_NAME    := l_concurrent_program_name;
  CP_PROCESS_DATE               := l_process_date;
  CP_MODE                       := l_mode;
  CP_DERIVABLE_FACTORS          := l_derivable_factors;
  CP_VALIDATE                   := l_validate;
  CP_PERSON                     := l_person;
  CP_PERSON_TYPE                := l_person_type;
  CP_PROGRAM                    := l_program;
  CP_BUSINESS_GROUP             := l_business_group;
  CP_PLAN                       := l_plan;
  CP_ENROLLMENT_TYPE_CYCLE      := l_enrollment_type_cycle;
  CP_PLANS_NOT_IN_PROGRAMS      := l_plans_not_in_programs;
  CP_JUST_PROGRAMS              := l_just_programs;
  CP_COMP_OBJECT_SELECTION_RULE := l_comp_object_selection_rule;
  CP_PERSON_SELECTION_RULE      := l_person_selection_rule;
  CP_LIFE_EVENT_REASON          := l_life_event_reason;
  CP_ORGANIZATION               := l_organization;
  CP_POSTAL_ZIP_RANGE           := l_postal_zip_range;
  CP_REPORTING_GROUP            := l_reporting_group;
  CP_PLAN_TYPE                  := l_plan_type;
  CP_OPTION                     := l_option;
  CP_ELIGIBILITY_PROFILE        := l_eligibility_profile;
  CP_VARIABLE_RATE_PROFILE      := l_variable_rate_profile;
  CP_LEGAL_ENTITY               := l_legal_entity;
  CP_PAYROLL                    := l_payroll;
  CP_DEBUG_MESSAGE              := l_debug_message;
  CP_LOCATION                   := l_location;
  CP_AUDIT_LOG                  := l_audit_log;
  CP_BENFT_GROUP                := l_benft_group;
  CP_STATUS                     := l_status;
  CP_START_DATE                 := l_date_From;
        begin
                select date_from, uneai_effective_date into CP_FROM_OCRD_DT, CP_TO_OCRD_DT
    from  ben_benefit_actions
    where request_id = P_CONCURRENT_REQUEST_ID;

    exception when no_data_found then
    null;
  end;
  begin
                select hl.meaning into CP_BCKT_STAT_CD
    from  ben_benefit_actions bft, hr_lookups hl
      where bft.PTNL_LER_FOR_PER_STAT_CD = hl.lookup_code
      and hl.lookup_type = 'BEN_PTNL_LER_FOR_PER_STAT'
      and bft.request_id = P_CONCURRENT_REQUEST_ID;

    exception when no_data_found then
    null;
  end;

  BEN_BATCH_UTILS.get_rpt_header
           (p_concurrent_request_id  => P_CONCURRENT_REQUEST_ID
           ,p_cd_1                   => L01
           ,p_cd_2                   => L02
           ,p_cd_3                   => L03
           ,p_cd_4                   => L04
           ,p_cd_5                   => L05
           ,p_cd_6                   => L06
           ,p_cd_7                   => L07
           ,p_cd_8                   => L08
           ,p_cd_9                   => L09
           ,p_cd_10                  => L10
           ,p_cd_11                  => L11
           ,p_cd_12                  => L12
           ,p_cd_13                  => L13
           ,p_cd_14                  => L14
           ,p_cd_15                  => L15
           ,p_cd_16                  => L16
           ,p_cd_17                  => L17
           ,p_cd_18                  => L18
           ,p_cd_19                  => L19
           ,p_cd_20                  => L20
           );
  CD_01 := L01;
  CD_02 := L02;
  CD_03 := L03;
  CD_04 := L04;
  CD_05 := L05;
  CD_06 := L06;
  CD_07 := L07;
  CD_08 := L08;
  CD_09 := L09;
  CD_10 := L10;
  CD_11 := L11;
  CD_12 := L12;
  CD_13 := L13;
  CD_14 := L14;
  CD_15 := L15;
  CD_16 := L16;
  CD_17 := L17;
  CD_18 := L18;
  CD_19 := L19;
  CD_20 := L20;
  CV_01 := get_val(L01);
  CV_02 := get_val(L02);
  CV_03 := get_val(L03);
  CV_04 := get_val(L04);
  CV_05 := get_val(L05);
  CV_06 := get_val(L06);
  CV_07 := get_val(L07);
  CV_08 := get_val(L08);
  CV_09 := get_val(L09);
  CV_10 := get_val(L10);
  CV_11 := get_val(L11);
  CV_12 := get_val(L12);
  CV_13 := get_val(L13);
  CV_14 := get_val(L14);
  CV_15 := get_val(L15);
  CV_16 := get_val(L16);
  CV_17 := get_val(L17);
  CV_18 := get_val(L18);
  CV_19 := get_val(L19);
  CV_20 := get_val(L20);

return 1;
  end;

function CF_1Formula return Number is
  l_start_date                 varchar2(30);
  l_end_date                   varchar2(30);
  l_start_time                 varchar2(30);
  l_end_time                   varchar2(30);
  l_elapsed_time               varchar2(30);
  l_persons_selected           varchar2(30);
  l_persons_processed          varchar2(30);
  l_persons_errored            varchar2(30);
  l_persons_processed_succ     varchar2(30);
  l_persons_unprocessed        varchar2(30);
begin
        ben_batch_reporting.process_information
    (p_concurrent_request_id      => P_CONCURRENT_REQUEST_ID,
     p_start_date                 => L_START_DATE,
     p_end_date                   => L_END_DATE,
     p_start_time                 => L_START_TIME,
     p_end_time                   => L_END_TIME,
     p_elapsed_time               => L_ELAPSED_TIME,
     p_persons_selected           => L_PERSONS_SELECTED,
     p_persons_processed          => L_PERSONS_PROCESSED,
     p_persons_unprocessed        => L_PERSONS_UNPROCESSED,
     p_persons_processed_succ     => L_PERSONS_PROCESSED_SUCC,
     p_persons_errored            => L_PERSONS_ERRORED);
    CP_START_DATE                 := l_start_date;
  CP_END_DATE                   := l_end_date;
  CP_START_TIME                 := l_start_time;
  CP_END_TIME                   := l_end_time;
  CP_ELAPSED_TIME               := l_elapsed_time;
  CP_PERSONS_SELECTED           := l_persons_selected;
  CP_PERSONS_PROCESSED          := l_persons_processed;
  CP_PERSONS_ERRORED            := l_persons_errored;
  CP_PERSONS_UNPROCESSED        := l_persons_unprocessed;
  CP_PERSONS_PROCESSED_SUCC     := l_persons_processed_succ;
    return 1;
  end;

FUNCTION Get_val (p_cd varchar2) RETURN varchar2 IS
  l_str  Varchar2(240) := null;
BEGIN
  If (p_cd in ('P_EFFECTIVE_DATE')) then
    l_str := CP_PROCESS_DATE;
  Elsif (p_cd in ('P_MODE')) then
    l_str := NVL(CP_MODE,'ALL');
  Elsif (p_cd in ('P_DERIVABLE_FACTORS')) then
    l_str := NVL(CP_DERIVABLE_FACTORS,'ALL');
  Elsif (p_cd in ('P_VALIDATE')) then
    l_str := CP_VALIDATE;
  Elsif (p_cd in ('P_PERSON_ID')) then
    l_str := NVL(CP_PERSON,'ALL');
  Elsif (p_cd in ('P_PERSON_TYPE_ID')) then
    l_str := NVL(CP_PERSON_TYPE,'ALL');
  Elsif (p_cd in ('P_PGM_ID')) then
    l_str := NVL(CP_PROGRAM,'ALL');
  Elsif (p_cd in ('P_BUSINESS_GROUP_ID')) then
    l_str := CP_BUSINESS_GROUP;
  Elsif (p_cd in ('P_PL_ID')) then
    l_str := NVL(CP_PLAN,'ALL');
  Elsif (p_cd in ('P_GROUP_PL_ID')) then
    l_str := NVL(CP_PLAN,'ALL');
  Elsif (p_cd in ('P_POPL_ENRT_TYP_CYCL_ID')) then
    l_str := NVL(CP_ENROLLMENT_TYPE_CYCLE,'ALL');
  Elsif (p_cd in ('P_NO_PROGRAMS_FLAG')) then
    l_str := CP_PLANS_NOT_IN_PROGRAMS ;
  Elsif (p_cd in ('P_NO_PLANS_FLAG ')) then
    l_str := CP_JUST_PROGRAMS;
  Elsif (p_cd in ('P_COMP_SELECTION_RL')) then
    l_str := NVL(CP_COMP_OBJECT_SELECTION_RULE,'ALL');
  Elsif (p_cd in ('P_PERSON_SELECTION_RULE_ID')) then
    l_str := NVL(CP_PERSON_SELECTION_RULE,'ALL') ;
  Elsif (p_cd in ('P_LER_ID')) then
    l_str := NVL(CP_LIFE_EVENT_REASON,'ALL');
  Elsif (p_cd in ('P_LIFE_EVENT_ID')) then
    l_str := NVL(CP_LIFE_EVENT_REASON,'ALL');
  Elsif (p_cd in ('P_OCRD_DATE')) then
    l_str := NVL(CP_START_DATE,'ALL');
  Elsif (p_cd in ('P_ORGANIZATION_ID')) then
    l_str := NVL(CP_ORGANIZATION,'ALL');
  Elsif (p_cd in ('P_PSTL_ZIP_RNG_ID')) then
    l_str := NVL(CP_POSTAL_ZIP_RANGE,'ALL');
  Elsif (p_cd in ('P_RPTG_GRP_ID')) then
    l_str := NVL(CP_REPORTING_GROUP,'ALL');
  Elsif (p_cd in ('P_PL_TYP_ID')) then
    l_str := NVL(CP_PLAN_TYPE,'ALL');
  Elsif (p_cd in ('P_OPT_ID')) then
    l_str := NVL(CP_OPTION,'ALL');
  Elsif (p_cd in ('P_ELIGY_PRFL_ID')) then
    l_str := NVL(CP_ELIGIBILITY_PROFILE,'ALL');
  Elsif (p_cd in ('P_VRBL_RT_PRFL_ID')) then
    l_str := NVL(CP_VARIABLE_RATE_PROFILE,'ALL');
  Elsif (p_cd in ('P_LEGAL_ENTITY_ID')) then
    l_str := NVL(CP_LEGAL_ENTITY,'ALL');
  Elsif (p_cd in ('P_PAYROLL_ID')) then
    l_str := NVL(CP_PAYROLL,'ALL');
  Elsif (p_cd in ('P_LOCATION_ID')) then
    l_str := NVL(CP_LOCATION, 'ALL');
  Elsif (p_cd in ('P_DEBUG_MESSAGES', 'P_DEBUG_MESSAGE')) then
    l_str := NVL(CP_DEBUG_MESSAGE, 'ALL');
  Elsif (p_cd in ('P_AUDIT_LOG')) then
    l_str := NVL(CP_AUDIT_LOG, 'ALL');
  Elsif (p_cd in ('P_BENFTS_GRP_ID')) then
    l_str := NVL(CP_BENFT_GROUP, 'ALL');
        Elsif (p_cd in ('P_FROM_OCRD_DATE')) then
    l_str := NVL(CP_FROM_OCRD_DT, '');
  Elsif (p_cd in ('P_TO_OCRD_DATE')) then
    l_str := NVL(CP_TO_OCRD_DT, '');
  Elsif (p_cd in ('P_BCKT_STAT_CD')) then
    l_str := NVL(CP_BCKT_STAT_CD, '');

          Elsif (p_cd in ('P_ABS_LER')) then
    l_str := 'N' ;

  Elsif (p_cd is NULL) then
    l_str := NULL;
  Else
    l_str := 'ERR';
  End if;
  return l_str;
RETURN NULL; Exception
  When others then
     return 'ERR';
END;

function BeforePForm return boolean is
begin

  return (TRUE);
end;

function AfterPForm return boolean is
    CURSOR c_conc_pgm_name (cv_request_id number) is
  SELECT fcp.concurrent_program_name
    FROM ben_benefit_actions bft, fnd_concurrent_programs fcp
   WHERE bft.program_id = fcp.concurrent_program_id
     AND bft.request_id = cv_request_id;
    l_source_program   varchar2(30);
  begin

  if P_CONCURRENT_REQUEST_ID is not null
  then
        open c_conc_pgm_name(P_CONCURRENT_REQUEST_ID);
      fetch c_conc_pgm_name into l_source_program;
            if l_source_program = 'BENCWBBO'
      then
       run_mode := 'CWBGLOBAL_BKOUT';
      elsif l_source_program = 'BENIRCBO'
      then
        run_mode := 'IREC_BKOUT';
      else
       run_mode := 'OTHERS';
      end if;
          close c_conc_pgm_name;
      else
         run_mode := 'OTHERS';
      end if;
                  P_CONC_REQUEST_ID := P_CONCURRENT_REQUEST_ID;
    return (TRUE);
 end;

function BeforeReport return boolean is
begin
   -- hr_standard.event('BEFORE REPORT');
  return (TRUE);
end;

function AfterReport return boolean is
begin
   -- hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_PROCESS_DATE_p return varchar2 is
	Begin
	 return CP_PROCESS_DATE;
	 END;
 Function CP_DERIVABLE_FACTORS_p return varchar2 is
	Begin
	 return CP_DERIVABLE_FACTORS;
	 END;
 Function CP_VALIDATE_p return varchar2 is
	Begin
	 return CP_VALIDATE;
	 END;
 Function CP_PERSON_p return varchar2 is
	Begin
	 return CP_PERSON;
	 END;
 Function CP_PERSON_TYPE_p return varchar2 is
	Begin
	 return CP_PERSON_TYPE;
	 END;
 Function CP_PROGRAM_p return varchar2 is
	Begin
	 return CP_PROGRAM;
	 END;
 Function CP_BUSINESS_GROUP_p return varchar2 is
	Begin
	 return CP_BUSINESS_GROUP;
	 END;
 Function CP_PLAN_p return varchar2 is
	Begin
	 return CP_PLAN;
	 END;
 Function CP_ENROLLMENT_TYPE_CYCLE_p return varchar2 is
	Begin
	 return CP_ENROLLMENT_TYPE_CYCLE;
	 END;
 Function CP_PLANS_NOT_IN_PROGRAMS_p return varchar2 is
	Begin
	 return CP_PLANS_NOT_IN_PROGRAMS;
	 END;
 Function CP_JUST_PROGRAMS_p return varchar2 is
	Begin
	 return CP_JUST_PROGRAMS;
	 END;
 Function CP_COMP_OBJECT_SELECTION_RULE1 return varchar2 is
	Begin
	 return CP_COMP_OBJECT_SELECTION_RULE;
	 END;
 Function CP_PERSON_SELECTION_RULE_p return varchar2 is
	Begin
	 return CP_PERSON_SELECTION_RULE;
	 END;
 Function CP_LIFE_EVENT_REASON_p return varchar2 is
	Begin
	 return CP_LIFE_EVENT_REASON;
	 END;
 Function CP_ORGANIZATION_p return varchar2 is
	Begin
	 return CP_ORGANIZATION;
	 END;
 Function CP_POSTAL_ZIP_RANGE_p return varchar2 is
	Begin
	 return CP_POSTAL_ZIP_RANGE;
	 END;
 Function CP_REPORTING_GROUP_p return varchar2 is
	Begin
	 return CP_REPORTING_GROUP;
	 END;
 Function CP_PLAN_TYPE_p return varchar2 is
	Begin
	 return CP_PLAN_TYPE;
	 END;
 Function CP_OPTION_p return varchar2 is
	Begin
	 return CP_OPTION;
	 END;
 Function CP_ELIGIBILITY_PROFILE_p return varchar2 is
	Begin
	 return CP_ELIGIBILITY_PROFILE;
	 END;
 Function CP_VARIABLE_RATE_PROFILE_p return varchar2 is
	Begin
	 return CP_VARIABLE_RATE_PROFILE;
	 END;
 Function CP_LEGAL_ENTITY_p return varchar2 is
	Begin
	 return CP_LEGAL_ENTITY;
	 END;
 Function CP_PAYROLL_p return varchar2 is
	Begin
	 return CP_PAYROLL;
	 END;
 Function CP_CONCURRENT_PROGRAM_NAME_p return varchar2 is
	Begin
	 return CP_CONCURRENT_PROGRAM_NAME;
	 END;
 Function CP_MODE_p return varchar2 is
	Begin
	 return CP_MODE;
	 END;
 Function CP_STATUS_p return varchar2 is
	Begin
	 return CP_STATUS;
	 END;
 Function CP_START_DATE_p return varchar2 is
	Begin
	 return CP_START_DATE;
	 END;
 Function CP_END_DATE_p return varchar2 is
	Begin
	 return CP_END_DATE;
	 END;
 Function CP_START_TIME_p return varchar2 is
	Begin
	 return CP_START_TIME;
	 END;
 Function CP_END_TIME_p return varchar2 is
	Begin
	 return CP_END_TIME;
	 END;
 Function CP_ELAPSED_TIME_p return varchar2 is
	Begin
	 return CP_ELAPSED_TIME;
	 END;
 Function CP_PERSONS_SELECTED_p return number is
	Begin
	 return CP_PERSONS_SELECTED;
	 END;
 Function CP_PERSONS_PROCESSED_p return number is
	Begin
	 return CP_PERSONS_PROCESSED;
	 END;
 Function CP_PERSONS_ERRORED_p return number is
	Begin
	 return CP_PERSONS_ERRORED;
	 END;
 Function CP_PERSONS_UNPROCESSED_p return number is
	Begin
	 return CP_PERSONS_UNPROCESSED;
	 END;
 Function CP_PERSONS_PROCESSED_SUCC_p return number is
	Begin
	 return CP_PERSONS_PROCESSED_SUCC;
	 END;
 Function CD_01_p return varchar2 is
	Begin
	 return CD_01;
	 END;
 Function CD_02_p return varchar2 is
	Begin
	 return CD_02;
	 END;
 Function CD_03_p return varchar2 is
	Begin
	 return CD_03;
	 END;
 Function CD_04_p return varchar2 is
	Begin
	 return CD_04;
	 END;
 Function CD_05_p return varchar2 is
	Begin
	 return CD_05;
	 END;
 Function CD_06_p return varchar2 is
	Begin
	 return CD_06;
	 END;
 Function CD_07_p return varchar2 is
	Begin
	 return CD_07;
	 END;
 Function CD_08_p return varchar2 is
	Begin
	 return CD_08;
	 END;
 Function CD_09_p return varchar2 is
	Begin
	 return CD_09;
	 END;
 Function CD_10_p return varchar2 is
	Begin
	 return CD_10;
	 END;
 Function CD_11_p return varchar2 is
	Begin
	 return CD_11;
	 END;
 Function CD_12_p return varchar2 is
	Begin
	 return CD_12;
	 END;
 Function CD_13_p return varchar2 is
	Begin
	 return CD_13;
	 END;
 Function CD_14_p return varchar2 is
	Begin
	 return CD_14;
	 END;
 Function CD_15_p return varchar2 is
	Begin
	 return CD_15;
	 END;
 Function CD_16_p return varchar2 is
	Begin
	 return CD_16;
	 END;
 Function CD_17_p return varchar2 is
	Begin
	 return CD_17;
	 END;
 Function CD_18_p return varchar2 is
	Begin
	 return CD_18;
	 END;
 Function CD_19_p return varchar2 is
	Begin
	 return CD_19;
	 END;
 Function CD_20_p return varchar2 is
	Begin
	 return CD_20;
	 END;
 Function CV_01_p return varchar2 is
	Begin
	 return CV_01;
	 END;
 Function CV_02_p return varchar2 is
	Begin
	 return CV_02;
	 END;
 Function CV_03_p return varchar2 is
	Begin
	 return CV_03;
	 END;
 Function CV_04_p return varchar2 is
	Begin
	 return CV_04;
	 END;
 Function CV_05_p return varchar2 is
	Begin
	 return CV_05;
	 END;
 Function CV_06_p return varchar2 is
	Begin
	 return CV_06;
	 END;
 Function CV_07_p return varchar2 is
	Begin
	 return CV_07;
	 END;
 Function CV_08_p return varchar2 is
	Begin
	 return CV_08;
	 END;
 Function CV_09_p return varchar2 is
	Begin
	 return CV_09;
	 END;
 Function CV_10_p return varchar2 is
	Begin
	 return CV_10;
	 END;
 Function CV_11_p return varchar2 is
	Begin
	 return CV_11;
	 END;
 Function CV_12_p return varchar2 is
	Begin
	 return CV_12;
	 END;
 Function CV_13_p return varchar2 is
	Begin
	 return CV_13;
	 END;
 Function CV_14_p return varchar2 is
	Begin
	 return CV_14;
	 END;
 Function CV_15_p return varchar2 is
	Begin
	 return CV_15;
	 END;
 Function CV_16_p return varchar2 is
	Begin
	 return CV_16;
	 END;
 Function CV_17_p return varchar2 is
	Begin
	 return CV_17;
	 END;
 Function CV_18_p return varchar2 is
	Begin
	 return CV_18;
	 END;
 Function CV_19_p return varchar2 is
	Begin
	 return CV_19;
	 END;
 Function CV_20_p return varchar2 is
	Begin
	 return CV_20;
	 END;
 Function CP_DEBUG_MESSAGE_p return varchar2 is
	Begin
	 return CP_DEBUG_MESSAGE;
	 END;
 Function CP_LOCATION_p return varchar2 is
	Begin
	 return CP_LOCATION;
	 END;
 Function CP_AUDIT_LOG_p return varchar2 is
	Begin
	 return CP_AUDIT_LOG;
	 END;
 Function CP_BENFT_GROUP_p return varchar2 is
	Begin
	 return CP_BENFT_GROUP;
	 END;
 Function CP_1_p return varchar2 is
	Begin
	 return CP_1;
	 END;
 Function CP_FROM_OCRD_DT_p return varchar2 is
	Begin
	 return CP_FROM_OCRD_DT;
	 END;
 Function CP_TO_OCRD_DT_p return varchar2 is
	Begin
	 return CP_TO_OCRD_DT;
	 END;
 Function CP_BCKT_STAT_CD_p return varchar2 is
	Begin
	 return CP_BCKT_STAT_CD;
	 END;
END BEN_BENERPER_XMLP_PKG ;

/
