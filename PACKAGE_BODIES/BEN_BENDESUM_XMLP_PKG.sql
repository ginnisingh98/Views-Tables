--------------------------------------------------------
--  DDL for Package Body BEN_BENDESUM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENDESUM_XMLP_PKG" AS
/* $Header: BENDESUMB.pls 120.1 2007/12/10 08:29:27 vjaganat noship $ */

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
  l_all			       varchar2(80);
  begin

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
  CP_STATUS                     := l_status;
        fnd_message.set_name('BEN','BEN_91792_ALL_PROMPT');
  l_all := substrb(fnd_message.get,1,80);
  begin
                select name into CP_PERSON_BNFT_GRP
    from ben_benfts_grp a,
         ben_benefit_actions b
    where a.benfts_grp_id = b.benfts_grp_id
    and    b.request_id = P_CONCURRENT_REQUEST_ID;

    exception when no_data_found then
    CP_PERSON_BNFT_GRP := l_all;

  end;
  begin
                select location_code into CP_LOCATION
    from hr_locations a,
          ben_benefit_actions b
    where a.location_id = b.location_id
    and    b.request_id = P_CONCURRENT_REQUEST_ID;

    exception when no_data_found then
    CP_LOCATION := l_all;
  end;

  return 1;
  end;

function CF_SUMMARY_EVENTFormula return Number is
    l_val  number;
  begin
    ben_batch_utils.summary_by_action
    (p_concurrent_request_id         => P_CONCURRENT_REQUEST_ID
    ,p_cd_1  => 'DSGNOCHG', p_val_1  => CP_DEFNOCHG
    ,p_cd_2  => 'DSGENDED', p_val_2  => CP_DEFWCHG
    ,p_cd_3  => 'XXX',      p_val_3  => l_val
    ,p_cd_4  => 'XXX',      p_val_4  => l_val
    ,p_cd_5  => 'XXX',      p_val_5  => l_val
    ,p_cd_6  => 'XXX',      p_val_6  => l_val
    ,p_cd_7  => 'XXX',      p_val_7  => l_val
    ,p_cd_8  => 'XXX',      p_val_8  => l_val
    ,p_cd_9  => 'XXX',      p_val_9  => l_val
    ,p_cd_10 => 'XXX',      p_val_10 => l_val
    );
  CP_DEFNOCHG := nvl(CP_DEFNOCHG,0);
  CP_DEFWCHG  := nvl(CP_DEFWCHG,0);
  CP_DEFTOTAL  := CP_DEFNOCHG + CP_DEFWCHG;
        select count(distinct related_person_id)
  into   CP_PARTICIPANTS_ENDED
  from   ben_reporting rpt,
         ben_benefit_actions ba
  where  ba.request_id=P_CONCURRENT_REQUEST_ID and
         ba.benefit_action_id=rpt.benefit_action_id and
         rpt.rep_typ_cd='DSGENDED';
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
    (p_concurrent_request_id      => p_concurrent_request_id,
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

function CP_DEFTOTALFormula return Number is
begin
  return 1;
end;

function AfterReport return boolean is
begin
    --hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

function BeforeReport return boolean is
begin
    --hr_standard.event('BEFORE REPORT');
  return (TRUE);
end;

function AfterPForm return boolean is
begin
                P_CONC_REQUEST_ID := P_CONCURRENT_REQUEST_ID;
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
 Function CP_COMP_OBJECT_SELECTION1 return varchar2 is
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
 Function CP_MODE_p return varchar2 is
	Begin
	 return CP_MODE;
	 END;
 Function CP_DEFNOCHG_p return number is
	Begin
	 return CP_DEFNOCHG;
	 END;
 Function CP_DEFWCHG_p return number is
	Begin
	 return CP_DEFWCHG;
	 END;
 Function CP_END_TIME_p return varchar2 is
	Begin
	 return CP_END_TIME;
	 END;
 Function CP_START_TIME_p return varchar2 is
	Begin
	 return CP_START_TIME;
	 END;
 Function CP_STATUS_p return varchar2 is
	Begin
	 return CP_STATUS;
	 END;
 Function CP_PERSONS_ERRORED_p return number is
	Begin
	 return CP_PERSONS_ERRORED;
	 END;
 Function CP_PERSONS_PROCESSED_SUCC_p return number is
	Begin
	 return CP_PERSONS_PROCESSED_SUCC;
	 END;
 Function CP_PERSONS_UNPROCESSED_p return number is
	Begin
	 return CP_PERSONS_UNPROCESSED;
	 END;
 Function CP_DEFTOTAL_p return number is
	Begin
	 return CP_DEFTOTAL;
	 END;
 Function cp_participants_ended_p return number is
	Begin
	 return cp_participants_ended;
	 END;
 Function CP_LOCATION_p return varchar2 is
	Begin
	 return CP_LOCATION;
	 END;
 Function CP_PERSON_BNFT_GRP_p return varchar2 is
	Begin
	 return CP_PERSON_BNFT_GRP;
	 END;
END BEN_BENDESUM_XMLP_PKG ;

/
