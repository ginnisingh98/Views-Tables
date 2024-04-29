--------------------------------------------------------
--  DDL for Package Body BEN_BENACTIV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENACTIV_XMLP_PKG" AS
/* $Header: BENACTIVB.pls 120.1 2007/12/10 08:22:52 vjaganat noship $ */

function CF_STANDARD_HEADERFormula return Number is

  l_concurrent_program_name    fnd_concurrent_programs_tl.user_concurrent_program_name%type ;   l_process_date               varchar2(30);
  l_mode                       hr_lookups.meaning%type ;   l_derivable_factors          hr_lookups.meaning%type ;
  l_validate                   hr_lookups.meaning%type ;   l_person                     per_people_f.full_name%type ;
  l_person_type                per_person_types.user_person_type%type ;
  l_program                    ben_pgm_f.name%type ;   l_business_group             per_business_groups.name%type ;
  l_plan                       ben_pl_f.name%type ;   l_enrollment_type_cycle      varchar2(800);
  l_plans_not_in_programs      hr_lookups.meaning%type ;
  l_just_programs              hr_lookups.meaning%type ;
  l_comp_object_selection_rule ff_formulas_f.formula_name%type ;
  l_person_selection_rule      ff_formulas_f.formula_name%type ;   l_life_event_reason          ben_ler_f.name%type ;   l_organization               hr_all_organization_units.name%type ;   l_postal_zip_range           varchar2(800);
  l_reporting_group            ben_rptg_grp.name%type ;
  l_plan_type                  ben_pl_typ_f.name%type ;
  l_option                     ben_opt_f.name%type ;   l_eligibility_profile        ben_eligy_prfl_f.name%type ;   l_variable_rate_profile      ben_vrbl_rt_prfl_f.name%type ;
  l_legal_entity               hr_all_organization_units.name%type ;   l_payroll                    pay_payrolls_f.payroll_name%type ;
  l_status                     fnd_lookups.meaning%type ;   l_all			       varchar2(80);         begin

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
  select loc.location_code into CP_LOCATION
  from hr_locations loc,
  ben_benefit_actions bft
  where bft.request_id = P_CONCURRENT_REQUEST_ID
  and bft.location_id = loc.location_id;

  exception
  when no_data_found then
  CP_LOCATION := l_all;
  end;

  begin
  select bng.name into CP_PERSON_BNFT_GRP
  from ben_benfts_grp bng,
  ben_benefit_actions bft
  where bft.request_id = P_CONCURRENT_REQUEST_ID
  and bft.benfts_grp_id = bng.benfts_grp_id;

  exception
  when no_data_found then
  CP_PERSON_BNFT_GRP := l_all;
  end;

  begin
  select decode(audit_log_flag, 'Y', 'Yes', 'N', 'No')  into CP_AUDIT_FLAG
  from   ben_benefit_actions bft
  where bft.request_id = P_CONCURRENT_REQUEST_ID;


  exception
  when no_data_found then
  null;
  end;

  begin
  select decode(lmt_prpnip_by_org_flag, 'Y', 'Yes', 'N', 'No')  into CP_LMT_BY_ORG_FLAG
  from   ben_benefit_actions bft
  where bft.request_id = P_CONCURRENT_REQUEST_ID;


  exception
  when no_data_found then
  null;
  end;

  return 1;
  end;

function CF_SUMMARY_EVENTFormula return Number is
    l_without_active_life_event  varchar2(30);
  l_with_active_life_event     varchar2(30);
  l_no_life_event_created      varchar2(30);
  l_life_event_open_and_closed varchar2(30);
  l_life_event_created         varchar2(30);
  l_life_event_still_active    varchar2(30);
  l_life_event_closed          varchar2(30);
  l_life_event_replaced        varchar2(30);
  l_life_event_dsgn_only       varchar2(30);
  l_life_event_choices         varchar2(30);
  l_life_event_no_effect       varchar2(30);
  l_life_event_rt_pr_chg       varchar2(30);
  l_life_event_collapsed       varchar2(30);
  l_life_event_collision       varchar2(30);
  begin
    ben_batch_reporting.activity_summary_by_action
    (p_concurrent_request_id      => P_CONCURRENT_REQUEST_ID,
     p_without_active_life_event  => l_without_active_life_event,
     p_with_active_life_event     => l_with_active_life_event,
     p_no_life_event_created      => l_no_life_event_created,
     p_life_event_open_and_closed => l_life_event_open_and_closed,
     p_life_event_created         => l_life_event_created,
     p_life_event_still_active    => l_life_event_still_active,
     p_life_event_closed          => l_life_event_closed,
     p_life_event_replaced        => l_life_event_replaced,
     p_life_event_dsgn_only       => l_life_event_dsgn_only,
     p_life_event_choices         => l_life_event_choices,
     p_life_event_no_effect       => l_life_event_no_effect,
     p_life_event_rt_pr_chg       => l_life_event_rt_pr_chg,
     p_life_event_collapsed       => l_life_event_collapsed,
     p_life_event_collision       => l_life_event_collision
  );
    CP_WITHOUT_ACTIVE_LIFE_EVENT   := l_without_active_life_event;
  CP_WITH_ACTIVE_LIFE_EVENT      := l_with_active_life_event-
                                     l_life_event_replaced;
  CP_NO_LIFE_EVENT_CREATED       := l_no_life_event_created;
  CP_LIFE_EVENT_OPEN_AND_CLOSED  := l_life_event_open_and_closed;
  CP_LIFE_EVENT_CREATED          := l_life_event_created;
  CP_LIFE_EVENT_STILL_ACTIVE     := l_life_event_still_active;
  CP_LIFE_EVENT_CLOSED           := l_life_event_closed;
  CP_LIFE_EVENT_REPLACED         := l_life_event_replaced;
  CP_LIFE_EVENT_DSGN_ONLY        := l_life_event_dsgn_only;
  CP_LIFE_EVENT_CHOICES          := l_life_event_choices;
  CP_LIFE_EVENT_NO_EFFECT        := l_life_event_no_effect;
  CP_LIFE_EVENT_RT_PR_CHG        := l_life_event_rt_pr_chg;
  CP_NO_CHANGE_TO_LIFE           := l_no_life_event_created+
                                     l_life_event_still_active +
                                     l_life_event_collapsed+
                                     l_life_event_collision;
  CP_CR_OPN_CLS                  := l_life_event_open_and_closed+
                                     l_life_event_closed;
  CP_TOTAL_CLOSED                := to_number(l_life_event_closed) +
                                     to_number(l_life_event_open_and_closed);
  CP_LIFE_EVENT_COLLAPSED        := l_life_event_collapsed;
  CP_LIFE_EVENT_COLLISION        := l_life_event_collision;
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

function CF_TEMPORAL_LIFE_EVENTSFormula return Number is
begin
    ben_batch_reporting.temporal_life_events
    (p_concurrent_request_id  => P_concurrent_request_id,
     p_age_changed            => CP_age_changed,
     p_los_changed            => CP_los_changed,
     p_comb_age_los_changed   => CP_comb_age_los_changed,
     p_pft_changed            => CP_pft_changed,
     p_comp_lvl_changed       => CP_comp_lvl_changed,
     p_hrs_wkd_changed        => CP_hrs_wkd_changed,
     p_loss_of_eligibility        => CP_LOSS_OF_ELIGIBILITY,
     p_late_payment               => CP_late_payment,
     p_max_enrollment_rchd        => CP_max_enrollment_rchd,
     p_period_enroll_changed      => CP_period_enroll_changed,
     p_voulntary_end_cvg          => CP_voulntary_end_cvg,
     p_waiting_satisfied          => CP_waiting_satisfied,
     p_persons_no_potential   => CP_persons_no_potential,
     p_persons_with_potential => CP_persons_with_potential,
     p_number_of_events_created => CP_number_of_events_created);

  return 1;
  end;

function BeforeReport return boolean is
begin
    /*hr_standard.event('BEFORE REPORT');*/
  return (TRUE);
end;

function AfterReport return boolean is
begin
   /* hr_standard.event('AFTER REPORT'); */
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
            if l_source_program = 'BENCOMOD'
      then
        run_mode := 'COMP';
      elsif l_source_program = 'BENSEMOD'
      then
       run_mode := 'SELECTION';
      elsif l_source_program = 'BENPAMOD'
      then
       run_mode := 'PERSONNEL';
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
 Function CP_WITHOUT_ACTIVE_LIFE_EVENT_p return number is
	Begin
	 return CP_WITHOUT_ACTIVE_LIFE_EVENT;
	 END;
 Function CP_WITH_ACTIVE_LIFE_EVENT_p return number is
	Begin
	 return CP_WITH_ACTIVE_LIFE_EVENT;
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
 Function CP_NO_LIFE_EVENT_CREATED_p return number is
	Begin
	 return CP_NO_LIFE_EVENT_CREATED;
	 END;
 Function CP_LIFE_EVENT_OPEN_AND_CLOSED1 return number is
	Begin
	 return CP_LIFE_EVENT_OPEN_AND_CLOSED;
	 END;
 Function CP_LIFE_EVENT_STILL_ACTIVE_p return number is
	Begin
	 return CP_LIFE_EVENT_STILL_ACTIVE;
	 END;
 Function CP_LIFE_EVENT_REPLACED_p return number is
	Begin
	 return CP_LIFE_EVENT_REPLACED;
	 END;
 Function CP_LIFE_EVENT_CREATED_p return number is
	Begin
	 return CP_LIFE_EVENT_CREATED;
	 END;
 Function CP_LIFE_EVENT_CLOSED_p return number is
	Begin
	 return CP_LIFE_EVENT_CLOSED;
	 END;
 Function CP_TOTAL_CLOSED_p return number is
	Begin
	 return CP_TOTAL_CLOSED;
	 END;
 Function CP_AGE_CHANGED_p return varchar2 is
	Begin
	 return CP_AGE_CHANGED;
	 END;
 Function CP_LOS_CHANGED_p return varchar2 is
	Begin
	 return CP_LOS_CHANGED;
	 END;
 Function CP_COMB_AGE_LOS_CHANGED_p return varchar2 is
	Begin
	 return CP_COMB_AGE_LOS_CHANGED;
	 END;
 Function CP_PFT_CHANGED_p return varchar2 is
	Begin
	 return CP_PFT_CHANGED;
	 END;
 Function CP_COMP_LVL_CHANGED_p return varchar2 is
	Begin
	 return CP_COMP_LVL_CHANGED;
	 END;
 Function CP_HRS_WKD_CHANGED_p return varchar2 is
	Begin
	 return CP_HRS_WKD_CHANGED;
	 END;
 Function CP_PERSONS_NO_POTENTIAL_p return varchar2 is
	Begin
	 return CP_PERSONS_NO_POTENTIAL;
	 END;
 Function CP_PERSONS_WITH_POTENTIAL_p return varchar2 is
	Begin
	 return CP_PERSONS_WITH_POTENTIAL;
	 END;
 Function CP_NUMBER_OF_EVENTS_CREATED_p return varchar2 is
	Begin
	 return CP_NUMBER_OF_EVENTS_CREATED;
	 END;
 Function CP_LIFE_EVENT_DSGN_ONLY_p return number is
	Begin
	 return CP_LIFE_EVENT_DSGN_ONLY;
	 END;
 Function CP_LIFE_EVENT_CHOICES_p return number is
	Begin
	 return CP_LIFE_EVENT_CHOICES;
	 END;
 Function CP_LIFE_EVENT_NO_EFFECT_p return number is
	Begin
	 return CP_LIFE_EVENT_NO_EFFECT;
	 END;
 Function CP_LIFE_EVENT_RT_PR_CHG_p return number is
	Begin
	 return CP_LIFE_EVENT_RT_PR_CHG;
	 END;
 Function CP_NO_CHANGE_TO_LIFE_p return number is
	Begin
	 return CP_NO_CHANGE_TO_LIFE;
	 END;
 Function CP_CR_OPN_CLS_p return number is
	Begin
	 return CP_CR_OPN_CLS;
	 END;
 Function CP_LIFE_EVENT_COLLAPSED_p return number is
	Begin
	 return CP_LIFE_EVENT_COLLAPSED;
	 END;
 Function CP_LIFE_EVENT_COLLISION_p return number is
	Begin
	 return CP_LIFE_EVENT_COLLISION;
	 END;
 Function CP_LOCATION_p return varchar2 is
	Begin
	 return CP_LOCATION;
	 END;
 Function CP_PERSON_BNFT_GRP_p return varchar2 is
	Begin
	 return CP_PERSON_BNFT_GRP;
	 END;
 Function CP_AUDIT_FLAG_p return varchar2 is
	Begin
	 return CP_AUDIT_FLAG;
	 END;
 Function CP_LMT_BY_ORG_FLAG_p return varchar2 is
	Begin
	 return CP_LMT_BY_ORG_FLAG;
	 END;
 Function CP_LOSS_OF_ELIGIBILITY_p return varchar2 is
	Begin
	 return CP_LOSS_OF_ELIGIBILITY;
	 END;
 Function CP_late_payment_p return varchar2 is
	Begin
	 return CP_late_payment;
	 END;
 Function CP_max_enrollment_rchd_p return varchar2 is
	Begin
	 return CP_max_enrollment_rchd;
	 END;
 Function CP_period_enroll_changed_p return varchar2 is
	Begin
	 return CP_period_enroll_changed;
	 END;
 Function CP_voulntary_end_cvg_p return varchar2 is
	Begin
	 return CP_voulntary_end_cvg;
	 END;
 Function CP_waiting_satisfied_p return varchar2 is
	Begin
	 return CP_waiting_satisfied;
	 END;
END BEN_BENACTIV_XMLP_PKG ;

/
