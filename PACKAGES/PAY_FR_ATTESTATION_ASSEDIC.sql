--------------------------------------------------------
--  DDL for Package PAY_FR_ATTESTATION_ASSEDIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_ATTESTATION_ASSEDIC" AUTHID CURRENT_USER As
/* $Header: pyfraasd.pkh 115.3 2003/06/03 12:12:10 sspratur noship $ */

Type number_tab is Table Of Number Index by binary_integer;
g_service_id number_tab;
g_npil_payment_id  Number;
g_legal_term_indemnity_id Number;
g_conventional_indemnity_id Number;
--Added the following global variables --Bug#2953410
g_contractual_indemnity_id Number;
g_transactional_indemnity_id Number;

Procedure set_defined_balance_ids(p_actual_hours_worked_id     Out Nocopy Number ,
                                  p_days_unpaid_id             Out Nocopy Number ,
                                  p_days_partially_paid_id     Out Nocopy Number,
                                  p_subject_to_unemployment_id Out Nocopy Number,
                                  p_non_monthly_earnings_id    Out Nocopy Number,
                                  p_ee_unemployment_ta_id      Out Nocopy Number,
                                  p_ee_unemployment_tb_id      Out Nocopy Number
                                 );
Function get_last_fulltime_day_worked(p_person_id In Number ,
                                      p_last_day_worked In Date) Return Date;

Function get_estab_head_count(p_establishment_id Number ,
                              p_actual_termination_date Date) Return Number;

Function get_pension_provider_info(p_assignment_id Number ,
                                   p_establishment_id Number ,
                                   p_termination_date Date,
                                   p_type Varchar2) Return Varchar2 ;

Function pension_category(p_business_group_id Number ,
                          p_assignment_id Number,
                          p_actual_termination_date Date,
                          p_period_of_service_id Number) Return Varchar2 ;

--Changed the signature to accept two more parameters --Bug#2953410
--p_transactional_indemnity and  p_contractual_indemnity

Procedure get_termination_indemnities(p_assignment_id           In  Number ,
                                      p_last_day_worked         In  Date ,
                                      p_actual_termination_date In  Date ,
                                      p_npil                    Out Nocopy Number ,
                                      p_holiday_pay_amount      Out Nocopy Number,
                                      p_hoilday_pay_rate        Out Nocopy Number ,
                                      p_ft_contract_indemnity   Out Nocopy Number,
                                      p_legal_indemnity         Out Nocopy Number,
                                      p_conventional_indemnity  Out Nocopy Number,
                                      p_transactional_indemnity Out Nocopy Number,
                                      p_contractual_indemnity   Out Nocopy Number);

Procedure insert_date_run(p_effective_date varchar2);

End pay_fr_attestation_assedic;

 

/
