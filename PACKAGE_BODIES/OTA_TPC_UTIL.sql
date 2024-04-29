--------------------------------------------------------
--  DDL for Package Body OTA_TPC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPC_UTIL" as
/* $Header: ottpcutl.pkb 115.5 2003/05/29 08:25:22 jheer noship $ */
--
function calc_amount(
  p_item_type_usage_id in number,
  p_business_group_id in number,
  p_training_plan_id in number,
  p_organization_id in number,
  p_period_start_date in date,
  p_period_end_date in date,
  p_plan_status in varchar2,
  p_measurement_type_id in number,
  p_cost_level in varchar2,
  p_event_id in number,
  p_delegate_booking_id in number,
  p_to_currency in varchar2,
  p_payroll_id in number)
return number
is
l_template_id hr_summary_item_type_usage.template_id%type;
l_prmrec      hr_summary_util.prmtabtype;
l_statement   varchar2(32000);
l_result      ota_training_plan_costs.amount%type;
l_dyn_curs    integer;
l_dyn_rows    integer;
begin
  select template_id into l_template_id
    from hr_summary_item_type_usage
    where item_type_usage_id = p_item_type_usage_id;
  --
  l_prmrec(1).name := 'P_BUSINESS_GROUP_ID';
  l_prmrec(1).value := p_business_group_id;
  l_prmrec(2).name := 'P_TRAINING_PLAN_ID';
  l_prmrec(2).value := p_training_plan_id;
  l_prmrec(3).name := 'P_ORGANIZATION_ID';
  l_prmrec(3).value := p_organization_id;
  l_prmrec(4).name := 'P_PERIOD_START_DATE';
  l_prmrec(4).value := 'to_date('''||to_char(p_period_start_date,'YYYYMMDD')||''',''YYYYMMDD'')';
  l_prmrec(5).name := 'P_PERIOD_END_DATE';
  l_prmrec(5).value := 'to_date('''||to_char(p_period_end_date,'YYYYMMDD')||''',''YYYYMMDD'')';
  l_prmrec(6).name := 'P_PLAN_STATUS';
  l_prmrec(6).value := p_plan_status;
  l_prmrec(7).name := 'P_MEASUREMENT_TYPE_ID';
  l_prmrec(7).value := p_measurement_type_id;
  l_prmrec(8).name := 'P_COST_LEVEL';
  l_prmrec(8).value := p_cost_level;
  l_prmrec(9).name := 'P_EVENT_ID';
  l_prmrec(9).value := p_event_id;
  l_prmrec(10).name := 'P_DELEGATE_BOOKING_ID';
  l_prmrec(10).value := p_delegate_booking_id;
  l_prmrec(11).name := 'P_TO_CURRENCY';
  l_prmrec(11).value := p_to_currency;
  l_prmrec(12).name := 'P_PAYROLL_ID';
  l_prmrec(12).value := p_payroll_id;
  --
  hrsumrep.process_run(
    p_business_group_id => p_business_group_id,
    p_process_type => 'TRAINING COST',
    p_template_id => l_template_id,
    p_process_name => 'Compute Amount',
    p_parameters => l_prmrec,
    p_item_type_usage_id => p_item_type_usage_id,
    p_store_data => FALSE,
    p_statement => l_statement,
    p_debug     => 'N' );
  --
  l_dyn_curs := dbms_sql.open_cursor;
  dbms_sql.parse(l_dyn_curs, l_statement, dbms_sql.v7);
  dbms_sql.define_column(l_dyn_curs, 1, l_result);
  l_dyn_rows := dbms_sql.execute_and_fetch(l_dyn_curs, TRUE);
  dbms_sql.column_value(l_dyn_curs, 1, l_result);
  dbms_sql.close_cursor(l_dyn_curs);
--
  return l_result;
end calc_amount;
--
end OTA_TPC_UTIL;

/
