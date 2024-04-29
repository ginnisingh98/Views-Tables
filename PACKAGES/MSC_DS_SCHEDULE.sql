--------------------------------------------------------
--  DDL for Package MSC_DS_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_DS_SCHEDULE" AUTHID CURRENT_USER AS
/* $Header: MSCDSSS.pls 120.0 2005/05/25 17:39:45 appldev noship $  */

  FIELD_SEPERATOR CONSTANT VARCHAR2(5) := '|';
  RECORD_SEPERATOR CONSTANT VARCHAR2(5) := '&';
  FORMAT_MASK CONSTANT VARCHAR2(20) :='MM/DD/YY';

  TYPE maxCharTbl IS TABLE of varchar2(32000);

  procedure getScheduleSummary(p_plan_id number, p_cat_set_id number, p_recom_days number,
    p_late_supply_total out nocopy number, p_res_cons_total out nocopy number,
    p_mat_cons_total out nocopy number, p_exc_setup_total out nocopy number,
    p_resched_total out nocopy number, p_release_total out nocopy number);

  procedure getLateSupplyDetails(p_plan_id number, p_cat_set_id number,
    p_round_val number, p_name_data in out nocopy msc_ds_schedule.maxCharTbl);

  procedure getLateSupplySummary(p_plan_id number, p_cat_set_id number,
    p_round_val number, p_total_supply out nocopy number, p_late_supply out nocopy number,
    p_avg_days_late out nocopy number, p_past_due_supply out nocopy number);

  procedure getResUtilSummary(p_plan_id number, p_resource_basis number,
    p_round_val number, p_actual_util out nocopy number, p_setup_util out nocopy number);

  procedure getResUtilDetails(p_plan_id number, p_resource_basis number,
    p_round_val number, p_name_data in out nocopy msc_ds_schedule.maxCharTbl);

END msc_ds_schedule;

 

/
