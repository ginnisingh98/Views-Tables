--------------------------------------------------------
--  DDL for Package POA_BIS_ALERTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_BIS_ALERTS" AUTHID CURRENT_USER AS
/* $Header: poaalrts.pls 115.4 2002/12/27 22:24:15 iali ship $ */

TYPE POA_Label_Value_Type IS RECORD (
label VARCHAR2(1000) := FND_API.G_MISS_CHAR,
value VARCHAR2(1000) := FND_API.G_MISS_CHAR,
heading VARCHAR2(1000) := FND_API.G_MISS_CHAR);

TYPE POA_Label_Value_Tbl IS TABLE OF POA_Label_Value_Type
INDEX BY BINARY_INTEGER;

g_percent_mask VARCHAR2(20) := '9999990D00';

PROCEDURE get_target_value(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2,
p_time_period IN VARCHAR2,
p_org_id IN NUMBER,
p_found OUT NOCOPY BOOLEAN,
p_target_value OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type);

PROCEDURE get_target_orgs(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2,
p_target_orgs OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_Type);

PROCEDURE get_period_info(
p_org_id IN NUMBER,
p_for_current_period IN BOOLEAN,
p_start_date OUT NOCOPY DATE,
p_end_date OUT NOCOPY DATE,
p_period_name OUT NOCOPY VARCHAR2,
p_period_set_name OUT NOCOPY VARCHAR2,
p_currency OUT NOCOPY VARCHAR2,
p_period_type OUT NOCOPY VARCHAR2);

PROCEDURE get_current_period_info(
p_org_id IN NUMBER,
p_start_date OUT NOCOPY DATE,
p_end_date OUT NOCOPY DATE,
p_period_name OUT NOCOPY VARCHAR2,
p_period_set_name OUT NOCOPY VARCHAR2,
p_currency OUT NOCOPY VARCHAR2,
p_period_type OUT NOCOPY VARCHAR2);

PROCEDURE get_previous_period_info(
p_org_id IN NUMBER,
p_start_date OUT NOCOPY DATE,
p_end_date OUT NOCOPY DATE,
p_period_name OUT NOCOPY VARCHAR2,
p_period_set_name OUT NOCOPY VARCHAR2,
p_currency OUT NOCOPY VARCHAR2,
p_period_type OUT NOCOPY VARCHAR2);

PROCEDURE get_gl_info(
p_org_id IN NUMBER,
p_period_set_name OUT NOCOPY VARCHAR2,
p_currency OUT NOCOPY VARCHAR2,
p_period_type OUT NOCOPY VARCHAR2);

PROCEDURE get_value(
p_label IN VARCHAR2,
p_value_tbl IN POA_Label_Value_Tbl,
p_index OUT NOCOPY NUMBER,
p_heading OUT NOCOPY VARCHAR2,
p_value OUT NOCOPY VARCHAR2);

PROCEDURE set_value(
p_label IN VARCHAR2,
p_heading IN VARCHAR2,
p_value IN VARCHAR2,
p_value_tbl IN OUT NOCOPY POA_Label_Value_Tbl);

PROCEDURE insert_row(
p_label IN VARCHAR2,
p_heading IN VARCHAR2,
p_value IN VARCHAR2,
p_value_tbl IN OUT NOCOPY POA_Label_Value_Tbl);

PROCEDURE get_actual(
p_target_level_short_name IN VARCHAR2,
p_org_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE,
p_currency IN VARCHAR2,
p_value_tbl OUT NOCOPY POA_Label_Value_Tbl);

PROCEDURE get_actual_poactlkg_all_m(
p_start_date IN DATE,
p_end_date IN DATE,
p_currency IN VARCHAR2,
p_value_tbl OUT NOCOPY POA_Label_Value_Tbl);

PROCEDURE get_actual_poactlkg_ou_m(
p_org_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE,
p_currency IN VARCHAR2,
p_value_tbl OUT NOCOPY POA_Label_Value_Tbl);

PROCEDURE get_actual_poactlkg_org_m(
p_org_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE,
p_currency IN VARCHAR2,
p_value_tbl OUT NOCOPY POA_Label_Value_Tbl);

PROCEDURE get_actual_poaspsal_all_m(
p_start_date IN DATE,
p_end_date IN DATE,
p_currency IN VARCHAR2,
p_value_tbl OUT NOCOPY POA_Label_Value_Tbl);

PROCEDURE get_actual_poaspsal_ou_m(
p_org_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE,
p_currency IN VARCHAR2,
p_value_tbl OUT NOCOPY POA_Label_Value_Tbl);

PROCEDURE get_report_param(
p_target_level_short_name IN VARCHAR2,
p_org_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE,
p_period_type IN VARCHAR2,
p_param OUT NOCOPY VARCHAR2);

PROCEDURE get_org_name(
p_org_id IN NUMBER,
p_org_name OUT NOCOPY VARCHAR2);

PROCEDURE compare_targets(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2,
p_for_current_period IN BOOLEAN);

PROCEDURE process_alert_previous_period(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2);

PROCEDURE process_alert_current_period(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2);

PROCEDURE process_alert(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2,
p_for_current_period IN BOOLEAN);

PROCEDURE post_actual(
p_target_level_short_name IN VARCHAR2,
p_plan_short_name IN VARCHAR2,
p_for_current_period IN BOOLEAN);

PROCEDURE start_workflow(
p_wf_item_type IN VARCHAR2,
p_wf_process IN VARCHAR2,
p_role IN VARCHAR2,
p_value_tbl IN POA_Label_Value_Tbl,
x_return_status OUT NOCOPY VARCHAR2);

END POA_BIS_ALERTS;

 

/
