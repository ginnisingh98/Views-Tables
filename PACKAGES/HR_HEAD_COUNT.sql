--------------------------------------------------------
--  DDL for Package HR_HEAD_COUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HEAD_COUNT" AUTHID CURRENT_USER AS
/* $Header: perhdcnt.pkh 120.0.12010000.1 2008/07/28 05:42:31 appldev ship $ */

TYPE HQOrgTableType is record
  (rev_start_val 			NUMBER
  ,nonrev_start_val 		NUMBER
  ,rev_perm 				NUMBER
  ,nonrev_perm 			NUMBER
  ,rev_cont 				NUMBER
  ,nonrev_cont 			NUMBER
  ,rev_temp 				NUMBER
  ,nonrev_temp 			NUMBER
  ,rev_nh 				NUMBER
  ,nonrev_nh 				NUMBER
  ,rev_cur_nh 				NUMBER
  ,nonrev_cur_nh 			NUMBER
  ,rev_transfer_in 			NUMBER
  ,nonrev_transfer_in 		NUMBER
  ,rev_transfer_out 		NUMBER
  ,nonrev_transfer_out 		NUMBER
  ,rev_open_offers 			NUMBER
  ,nonrev_open_offers 		NUMBER
  ,rev_accepted_offers 		NUMBER
  ,nonrev_accepted_offers 	NUMBER
  ,rev_vacant_FTE 			NUMBER
  ,nonrev_vacant_FTE 		NUMBER
  ,rev_vol_term 			NUMBER
  ,nonrev_vol_term 			NUMBER
  ,rev_invol_term 			NUMBER
  ,nonrev_invol_term 		NUMBER
  ,rev_cur_term 			NUMBER
  ,nonrev_cur_term 			NUMBER
  ,rev_end_val 			NUMBER
  ,nonrev_end_val 			NUMBER);
--
TYPE HQOrgTable is TABLE of HQOrgTableType
Index by binary_integer;
--
HQOrgData HQOrgTable;
--
function get_rev_start_val(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_start_val,WNDS,WNPS);
--
function get_nonrev_start_val(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_start_val,WNDS,WNPS);
--
function get_rev_perm(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_perm,WNDS,WNPS);
--
function get_nonrev_perm(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_perm,WNDS,WNPS);
--
function get_rev_cont(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_cont,WNDS,WNPS);
--
function get_nonrev_cont(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_cont,WNDS,WNPS);
--
function get_rev_temp(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_temp,WNDS,WNPS);
--
function get_nonrev_temp(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_temp,WNDS,WNPS);
--
function get_rev_cur_nh(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_cur_nh,WNDS,WNPS);
--
function get_nonrev_cur_nh(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_cur_nh,WNDS,WNPS);
--
function get_rev_nh(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_nh,WNDS,WNPS);
--
function get_nonrev_nh(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_nh,WNDS,WNPS);
--
function get_rev_transfer_in(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_transfer_in,WNDS,WNPS);
--
function get_nonrev_transfer_in(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_transfer_in,WNDS,WNPS);
--
function get_rev_transfer_out(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_transfer_out,WNDS,WNPS);
--
function get_nonrev_transfer_out(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_transfer_out,WNDS,WNPS);
--
function get_rev_open_offers(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_open_offers,WNDS,WNPS);
--
function get_nonrev_open_offers(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_open_offers,WNDS,WNPS);
--
function get_rev_accepted_offers(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_accepted_offers,WNDS,WNPS);
--
function get_nonrev_accepted_offers(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_accepted_offers,WNDS,WNPS);
--
function get_rev_vacant_FTE(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_vacant_FTE,WNDS,WNPS);
--
function get_nonrev_vacant_FTE(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_vacant_FTE,WNDS,WNPS);
--
function get_rev_vol_term(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_vol_term,WNDS,WNPS);
--
function get_nonrev_vol_term(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_vol_term,WNDS,WNPS);
--
function get_rev_invol_term(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_invol_term,WNDS,WNPS);
--
function get_nonrev_invol_term(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_invol_term,WNDS,WNPS);
--
function get_rev_cur_term(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_invol_term,WNDS,WNPS);
--
function get_nonrev_cur_term(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_invol_term,WNDS,WNPS);
--
function get_rev_end_val(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_end_val,WNDS,WNPS);
--
function get_nonrev_end_val(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_end_val,WNDS,WNPS);
--
function get_rev_change(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_change,WNDS,WNPS);
--
function get_nonrev_change(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_change,WNDS,WNPS);
--
function get_rev_pct_change(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_pct_change,WNDS,WNPS);
--
function get_nonrev_pct_change(p_org_structure_element_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_pct_change,WNDS,WNPS);
--
--
procedure populate_headcount_table
( P_BUSINESS_GROUP_ID         	IN NUMBER
, P_TOP_ORGANIZATION_ID       	IN NUMBER
, P_ORGANIZATION_STRUCTURE_ID 	IN NUMBER
, P_BUDGET              	IN VARCHAR2
, P_ROLL_UP              	IN VARCHAR2
, P_REPORT_DATE_FROM           	IN DATE
, P_REPORT_DATE_TO             	IN DATE
, P_REPORT_DATE              	IN DATE
, P_INCLUDE_ASG_TYPE         	IN VARCHAR2
, P_INCLUDE_TOP_ORG         	IN VARCHAR2
, P_WORKER_TYPE         	IN VARCHAR2
, P_DAYS_PRIOR_TO_END_DATE      IN NUMBER
, P_JOB_CATEGORY         	IN VARCHAR2 default 'RG');

END HR_HEAD_COUNT;

/
