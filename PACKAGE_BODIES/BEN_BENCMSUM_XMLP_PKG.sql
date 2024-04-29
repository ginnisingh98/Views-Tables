--------------------------------------------------------
--  DDL for Package Body BEN_BENCMSUM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENCMSUM_XMLP_PKG" AS
/* $Header: BENCMSUMB.pls 120.2 2007/12/21 06:09:22 amakrish noship $ */

function CF_STANDARD_HEADERFormula return Number is
    l_concurrent_program_name    fnd_concurrent_programs_tl.user_concurrent_program_name%type ;   l_process_date               varchar2(30);
  l_mode                       hr_lookups.meaning%type ;
  l_validate                   hr_lookups.meaning%type ;
  l_person                     per_people_f.full_name%type ;
  l_person_type                per_person_types.user_person_type%type ;
  l_program                    ben_pgm_f.name%type ;
  l_business_group             per_business_groups.name%type ;
  l_plan                       ben_pl_f.name%type ;
  l_person_selection_rule      ff_formulas_f.formula_name%type ;
  l_life_event_reason          ben_ler_f.name%type ;
  l_organization               hr_all_organization_units.name%type ;
  l_status                     fnd_lookups.meaning%type ;
  l_cm_trgr_typ                hr_lookups.meaning%type ;
  l_cm_typ                     hr_lookups.meaning%type ;
  l_plan_in_program            hr_lookups.meaning%type ;
  l_location                   hr_locations_all.description%type ;
  l_actn_typ                   ben_actn_typ.name%type ;
  l_elig_enrol                 hr_lookups.meaning%type ;
  l_age_fctr                   ben_age_fctr.name%type ;
  l_min_age                    ben_benefit_actions.min_age%type ;
  l_max_age                    ben_benefit_actions.max_age%type ;
  l_los_fctr                   ben_los_fctr.name%type ;
  l_min_los                    ben_benefit_actions.min_los%type ;
  l_max_los                    ben_benefit_actions.max_los%type ;
  l_cmbn_age_los_fctr          ben_cmbn_age_los_fctr.name%type ;
  l_date_from                  ben_benefit_actions.date_from%type ;
  l_enrollment_period          varchar2(800);   l_audit_log                  hr_lookups.meaning%type ;

  begin

         ben_determine_communications.standard_header(
                  p_concurrent_request_id   => p_concurrent_request_id,
                  p_concurrent_program_name => l_concurrent_program_name,
                  p_process_date            => l_process_date,
                  p_validate                => l_validate,
                  p_business_group          => l_business_group,
                  p_mode                    => l_mode,
                  p_cm_trgr_typ             => l_cm_trgr_typ,
                  p_cm_typ                  => l_cm_typ,
                  p_person                  => l_person,
                  p_person_type             => l_person_type,
                  p_person_selection_rule   => l_person_selection_rule,
                  p_organization            => l_organization,
                  p_location                => l_location,
                  p_ler                     => l_life_event_reason,
                  p_program                 => l_program,
                  p_plan                    => l_plan,
                  p_plan_in_program         => l_plan_in_program,
                  p_actn_typ                => l_actn_typ,
                  p_elig_enrol              => l_elig_enrol,
                  p_age_fctr                => l_age_fctr,
                  p_min_age                 => l_min_age,
                  p_max_age                 => l_max_age,
                  p_los_fctr                => l_los_fctr,
                  p_min_los                 => l_min_los,
                  p_max_los                 => l_max_los,
                  p_cmbn_age_los_fctr       => l_cmbn_age_los_fctr,
                  p_date_from               => l_date_from,
                  p_enrollment_period       => l_enrollment_period,
                  p_audit_log               => l_audit_log,
		  p_status                  => l_status	);
    CP_CONCURRENT_PROGRAM_NAME    := l_concurrent_program_name;
  CP_PROCESS_DATE               := l_process_date;
  CP_MODE                       := l_mode;
  CP_VALIDATE                   := l_validate;
  CP_CM_TRGR_TYP                := l_cm_trgr_typ;
  CP_CM_TYP                     := l_cm_typ;
  CP_PERSON                     := l_person;
  CP_PERSON_TYPE                := l_person_type;
  CP_PROGRAM                    := l_program;
  CP_BUSINESS_GROUP             := l_business_group;
  CP_PLAN                       := l_plan;
  CP_ENROLLMENT_PERIOD          := l_enrollment_period;
  CP_PLAN_IN_PROGRAM            := l_plan_in_program;
  CP_PERSON_SELECTION_RULE      := l_person_selection_rule;
  CP_LIFE_EVENT_REASON          := l_life_event_reason;
  CP_ORGANIZATION               := l_organization;
  CP_LOCATION                   := l_location;
  CP_ACTN_TYP                   := l_actn_typ;
  CP_ELIG_ENROL                 := l_elig_enrol;
  CP_AGE_FCTR                   := l_age_fctr;
  CP_MIN_AGE                    := l_min_age;
  CP_MAX_AGE                    := l_max_age;
  CP_LOS_FCTR                   := l_los_fctr;
  CP_MIN_LOS                    := l_min_los;
  CP_MAX_LOS                    := l_max_los;
  CP_CMBN_AGE_LOS_FCTR          := l_cmbn_age_los_fctr;
  CP_DATE_FROM                  := l_date_from;
  CP_AUDIT_LOG                  := l_audit_log;
    return 1;
  end;

function CF_SUMMARY_EVENTFormula return Number is
    l_rcv_cm_cnt       number;
  l_rcv_1_cm_cnt     number;
  l_rcv_mlt_cm_cnt   number;
  begin
    ben_determine_communications.summary_by_action
    (p_concurrent_request_id             => P_CONCURRENT_REQUEST_ID
    ,p_rcv_comm_count                    => l_rcv_cm_cnt
    ,p_rcv_1_comm_count                  => l_rcv_1_cm_cnt
    ,p_rcv_mlt_comm_count                => l_rcv_mlt_cm_cnt
    );
    CP_RCV_CM_CNT     := l_rcv_cm_cnt;
  CP_RCV_1_CM_CNT   := l_rcv_1_cm_cnt;
  CP_RCV_MLT_CM_CNT := l_rcv_mlt_cm_cnt;
  CP_RCV_NO_CM_CNT  := CP_PERSONS_PROCESSED_SUCC - l_rcv_cm_cnt;
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

 Function CP_PROCESS_DATE_p return varchar2 is
	Begin
	 return CP_PROCESS_DATE;
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
 Function CP_ENROLLMENT_PERIOD_p return varchar2 is
	Begin
	 return CP_ENROLLMENT_PERIOD;
	 END;
 Function CP_PLAN_IN_PROGRAM_p return varchar2 is
	Begin
	 return CP_PLAN_IN_PROGRAM;
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
 Function CP_RCV_1_CM_CNT_p return number is
	Begin
	 return CP_RCV_1_CM_CNT;
	 END;
 Function CP_RCV_MLT_CM_CNT_p return number is
	Begin
	 return CP_RCV_MLT_CM_CNT;
	 END;
 Function CP_END_TIME_p return varchar2 is
	Begin
	 return CP_END_TIME;
	 END;
 Function CP_START_TIME_p return varchar2 is
	Begin
	 return CP_START_TIME;
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
 Function CP_RCV_NO_CM_CNT_p return number is
	Begin
	 return CP_RCV_NO_CM_CNT;
	 END;
 Function CP_RCV_CM_CNT_p return number is
	Begin
	 return CP_RCV_CM_CNT;
	 END;
 Function CP_CM_TYP_p return varchar2 is
	Begin
	 return CP_CM_TYP;
	 END;
 Function CP_LOCATION_p return varchar2 is
	Begin
	 return CP_LOCATION;
	 END;
 Function CP_ACTN_TYP_p return varchar2 is
	Begin
	 return CP_ACTN_TYP;
	 END;
 Function CP_ELIG_ENROL_p return varchar2 is
	Begin
	 return CP_ELIG_ENROL;
	 END;
 Function CP_AGE_FCTR_p return varchar2 is
	Begin
	 return CP_AGE_FCTR;
	 END;
 Function CP_MIN_AGE_p return varchar2 is
	Begin
	 return CP_MIN_AGE;
	 END;
 Function CP_MAX_AGE_p return varchar2 is
	Begin
	 return CP_MAX_AGE;
	 END;
 Function CP_LOS_FCTR_p return varchar2 is
	Begin
	 return CP_LOS_FCTR;
	 END;
 Function CP_MIN_LOS_p return varchar2 is
	Begin
	 return CP_MIN_LOS;
	 END;
 Function CP_CMBN_AGE_LOS_FCTR_p return varchar2 is
	Begin
	 return CP_CMBN_AGE_LOS_FCTR;
	 END;
 Function CP_DATE_FROM_p return varchar2 is
	Begin
	 return CP_DATE_FROM;
	 END;
 Function CP_AUDIT_LOG_p return varchar2 is
	Begin
	 return CP_AUDIT_LOG;
	 END;
 Function CP_MAX_LOS_p return varchar2 is
	Begin
	 return CP_MAX_LOS;
	 END;
 Function CP_CM_TRGR_TYP_p return varchar2 is
	Begin
	 return CP_CM_TRGR_TYP;
	 END;
END BEN_BENCMSUM_XMLP_PKG ;

/
