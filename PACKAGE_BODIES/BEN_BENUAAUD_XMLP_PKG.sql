--------------------------------------------------------
--  DDL for Package Body BEN_BENUAAUD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENUAAUD_XMLP_PKG" AS
/* $Header: BENUAAUDB.pls 120.1 2007/12/10 08:38:30 vjaganat noship $ */

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
  l_val                        Number(38);
  l_all			       varchar2(80);      begin

                  ben_batch_reporting.standard_header
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
     p_status                     => L_STATUS);
    CP_CONCURRENT_PROGRAM_NAME    := l_concurrent_program_name;
  CP_PROCESS_DATE               := l_process_date;
  CP_STATUS                     := l_status;
         CP_VALIDATE                   := l_validate;
  CP_PERSON                     := l_person;
  CP_PROGRAM                    := l_program;
  CP_PLAN                       := l_plan;
  CP_PERSON_SELECTION_RULE      := l_person_selection_rule;
        fnd_message.set_name('BEN','BEN_91792_ALL_PROMPT');
  l_all := substrb(fnd_message.get,1,80);
  begin
                select location_code into CP_LOCATION
    from hr_locations a,
          ben_benefit_actions b
    where a.location_id = b.location_id
    and    b.request_id = P_CONCURRENT_REQUEST_ID;

    exception when no_data_found then
    CP_LOCATION := l_all;
  end;
  begin
                select meaning into CP_AUDIT_LOG_FLAG
    from hr_lookups a,
          ben_benefit_actions b
    where a.lookup_type = 'YES_NO'
    and   a.lookup_code = b.AUDIT_LOG_FLAG
    and   b.request_id = P_CONCURRENT_REQUEST_ID;

    exception when no_data_found then
    null;
  end;
    begin
                select meaning into CP_DEBUG_MESSAGES
    from hr_lookups a,
          ben_benefit_actions b
    where a.lookup_type = 'YES_NO'
    and   a.lookup_code = b.DEBUG_MESSAGES_FLAG
    and   b.request_id = P_CONCURRENT_REQUEST_ID;

    exception when no_data_found then
    null;
  end;
      ben_batch_utils.summary_by_action
    (p_concurrent_request_id              => P_CONCURRENT_REQUEST_ID
    ,p_cd_1  => 'ACTNENRTDEL',   p_val_1  => CP_ACTNENRTDEL
    ,p_cd_2  => 'ACTNNOENRTDEL', p_val_2  => CP_ACTNNOENRTDEL
    ,p_cd_3  => 'ACTNNOACTN',    p_val_3  => CP_ACTNNOACTN
    ,p_cd_4  => 'XXX',           p_val_4  => l_val
    ,p_cd_5  => 'XXX',           p_val_5  => l_val
    ,p_cd_6  => 'XXX',           p_val_6  => l_val
    ,p_cd_7  => 'XXX',           p_val_7  => l_val
    ,p_cd_8  => 'XXX',           p_val_8  => l_val
    ,p_cd_9  => 'XXX',           p_val_9  => l_val
    ,p_cd_10 => 'XXX',           p_val_10 => l_val
    );
  CP_ACTNENRTDEL   := nvl(CP_ACTNENRTDEL,0);
  CP_ACTNNOENRTDEL := nvl(CP_ACTNNOENRTDEL,0);
  CP_ACTNNOACTN    := nvl(CP_ACTNNOACTN,0);
    return 1;
  end;

function CF_PROCESS_INFORMATIONFormula return Number is
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

function BeforeReport return boolean is
begin
    --hr_standard.event('BEFORE REPORT');
  return (TRUE);
end;

function AfterReport return boolean is
begin
    --hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

function AfterPForm return boolean is
begin
                P_CONC_REQUEST_ID := P_CONCURRENT_REQUEST_ID;
    return (TRUE);
 end;

--Functions to refer Oracle report placeholders--

 Function CP_PROCESS_DATE_p return date is
	Begin
	 return CP_PROCESS_DATE;
	 END;
 Function CP_BUSINESS_GROUP_p return varchar2 is
	Begin
	 return CP_BUSINESS_GROUP;
	 END;
 Function CP_CONCURRENT_PROGRAM_NAME_p return varchar2 is
	Begin
	 return CP_CONCURRENT_PROGRAM_NAME;
	 END;
 Function CP_START_DATE_p return varchar2 is
	Begin
	 return CP_START_DATE;
	 END;
 Function CP_END_DATE_p return varchar2 is
	Begin
	 return CP_END_DATE;
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
 Function CP_START_TIME_p return varchar2 is
	Begin
	 return CP_START_TIME;
	 END;
 Function CP_END_TIME_p return varchar2 is
	Begin
	 return CP_END_TIME;
	 END;
 Function CP_PERSONS_UNPROCESSED_p return number is
	Begin
	 return CP_PERSONS_UNPROCESSED;
	 END;
 Function CP_PERSONS_PROCESSED_SUCC_p return number is
	Begin
	 return CP_PERSONS_PROCESSED_SUCC;
	 END;
 Function CP_PERSONS_ERRORED_p return number is
	Begin
	 return CP_PERSONS_ERRORED;
	 END;
 Function CP_STATUS_p return varchar2 is
	Begin
	 return CP_STATUS;
	 END;
 Function CP_ACTNNOACTN_p return number is
	Begin
	 return CP_ACTNNOACTN;
	 END;
 Function CP_ACTNENRTDEL_p return number is
	Begin
	 return CP_ACTNENRTDEL;
	 END;
 Function CP_ACTNNOENRTDEL_p return number is
	Begin
	 return CP_ACTNNOENRTDEL;
	 END;
 Function CP_PLAN_p return varchar2 is
	Begin
	 return CP_PLAN;
	 END;
 Function CP_PROGRAM_p return varchar2 is
	Begin
	 return CP_PROGRAM;
	 END;
 Function CP_LOCATION_p return varchar2 is
	Begin
	 return CP_LOCATION;
	 END;
 Function CP_PERSON_p return varchar2 is
	Begin
	 return CP_PERSON;
	 END;
 Function CP_PERSON_SELECTION_RULE_p return varchar2 is
	Begin
	 return CP_PERSON_SELECTION_RULE;
	 END;
 Function CP_VALIDATE_p return varchar2 is
	Begin
	 return CP_VALIDATE;
	 END;
 Function CP_DEBUG_MESSAGES_p return varchar2 is
	Begin
	 return CP_DEBUG_MESSAGES;
	 END;
 Function CP_AUDIT_LOG_FLAG_p return varchar2 is
	Begin
	 return CP_AUDIT_LOG_FLAG;
	 END;
END BEN_BENUAAUD_XMLP_PKG ;

/
