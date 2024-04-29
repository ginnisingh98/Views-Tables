--------------------------------------------------------
--  DDL for Package Body BEN_BENCMAUD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENCMAUD_XMLP_PKG" AS
/* $Header: BENCMAUDB.pls 120.1 2007/12/10 08:27:09 vjaganat noship $ */

function CF_STANDARD_HEADERFormula return number is
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
		  p_status                  => l_status);
    CP_CONCURRENT_PROGRAM_NAME    := l_concurrent_program_name;
  CP_PROCESS_DATE               := l_process_date;
  CP_STATUS                     := l_status;
  CP_BUSINESS_GROUP             := l_business_group;


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
  l_rcv_cm_cnt                 number;
  l_rcv_1_cm_cnt               number;
  l_rcv_mlt_cm_cnt             number;
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
      ben_determine_communications.summary_by_action
    (p_concurrent_request_id             => P_CONCURRENT_REQUEST_ID
    ,p_rcv_comm_count                    => l_rcv_cm_cnt
    ,p_rcv_1_comm_count                  => l_rcv_1_cm_cnt
    ,p_rcv_mlt_comm_count                => l_rcv_mlt_cm_cnt
    );
    CP_RCV_CM_CNT     := l_rcv_cm_cnt;
  CP_RCV_1_CM_CNT   := l_rcv_1_cm_cnt;
  CP_RCV_MLT_CM_CNT := l_rcv_mlt_cm_cnt;
  CP_RCV_NO_CM_CNT  := l_persons_processed_succ - l_rcv_cm_cnt;
    return 1;
  end;

function BeforeReport return boolean is
begin
  --  hr_standard.event('BEFORE REPORT');
  return (TRUE);
end;

function AfterReport return boolean is
begin
  --  hr_standard.event('AFTER REPORT');
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
 Function CP_RCV_CM_CNT_p return number is
	Begin
	 return CP_RCV_CM_CNT;
	 END;
 Function CP_RCV_1_CM_CNT_p return number is
	Begin
	 return CP_RCV_1_CM_CNT;
	 END;
 Function CP_RCV_MLT_CM_CNT_p return number is
	Begin
	 return CP_RCV_MLT_CM_CNT;
	 END;
 Function CP_RCV_NO_CM_CNT_p return number is
	Begin
	 return CP_RCV_NO_CM_CNT;
	 END;
END BEN_BENCMAUD_XMLP_PKG ;

/
