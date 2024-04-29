--------------------------------------------------------
--  DDL for Package HR_HEAD_COUNT_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HEAD_COUNT_SUMMARY" AUTHID CURRENT_USER AS
/* $Header: perhdsum.pkh 115.6 2003/04/27 23:23:27 asahay noship $ */

TYPE HQOrgTableType is record
  (rev_start_val 		NUMBER
  ,nonrev_start_val 		NUMBER
  ,rev_end_val 			NUMBER
  ,nonrev_end_val 		NUMBER
  ,rev_nh 			NUMBER
  ,nonrev_nh 			NUMBER
  ,rev_term 			NUMBER
  ,nonrev_term 			NUMBER);
--
TYPE HQOrgTable is TABLE of HQOrgTableType
Index by binary_integer;
--
HQOrgData HQOrgTable;
--
function get_rev_start_val(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_start_val,WNDS,WNPS);
--
function get_nonrev_start_val(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_start_val,WNDS,WNPS);
--
function get_rev_end_val(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_end_val,WNDS,WNPS);
--
function get_nonrev_end_val(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_end_val,WNDS,WNPS);
--
function get_rev_nh(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_nh,WNDS,WNPS);
--
function get_nonrev_nh(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_nh,WNDS,WNPS);
--
function get_rev_term(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_term,WNDS,WNPS);
--
function get_nonrev_term(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_term,WNDS,WNPS);
--
function get_rev_net_change(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_net_change,WNDS,WNPS);
--
function get_nonrev_net_change(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_net_change,WNDS,WNPS);
--
function get_rev_other_net(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_rev_other_net,WNDS,WNPS);
--
function get_nonrev_other_net(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_nonrev_other_net,WNDS,WNPS);
--
--
procedure populate_summary_table
( P_BUSINESS_GROUP_ID         IN NUMBER
, P_TOP_ORGANIZATION_ID       IN NUMBER
, P_ORGANIZATION_STRUCTURE_ID IN NUMBER
, P_BUDGET                    IN VARCHAR2
, P_ROLL_UP                   IN VARCHAR2
, P_INCLUDE_TOP_ORG           IN VARCHAR2
, P_REPORT_DATE_FROM          IN DATE
, P_REPORT_DATE_TO            IN DATE
, P_REPORT_DATE               IN DATE
, P_INCLUDE_ASG_TYPE	      IN VARCHAR2
, P_JOB_CATEGORY              IN VARCHAR2 default 'RG');

END HR_HEAD_COUNT_SUMMARY;

 

/
