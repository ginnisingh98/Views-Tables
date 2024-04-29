--------------------------------------------------------
--  DDL for Package RCI_ORG_CERT_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCI_ORG_CERT_SUMM_PKG" AUTHID CURRENT_USER AS
/* $Header: rciocss.pls 120.6.12000000.1 2007/01/16 20:46:22 appldev ship $ */

PROCEDURE get_org_kpi(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- the get_org_certification_result procedure is called by
-- Organization Certification Summary report.
PROCEDURE get_org_certification_result(
   p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- the get_org_cert_prcnt procedure is called by
-- Organization Certification Result report.
PROCEDURE get_org_cert_prcnt(
   p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- the get_unmitigated_risks procedure is called by
-- Organization Certification Unmitigated Risks List report.
PROCEDURE get_unmitigated_risks(
   p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- the get_control_list procedure is called by
-- Organization Certification Control Detail List report.
PROCEDURE get_control_list(
   p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- the get_issue_detail procedure is called by
-- Issue Detail List report.
PROCEDURE get_issue_detail(
   p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- the get_deficient_processes procedure is called by
-- Process Deficiency Detail report.
PROCEDURE get_deficient_processes(
   p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- the get_org_certification_detail procedure is called by
-- Organization Certification Detail report.
PROCEDURE get_org_certification_detail(
   p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- the get_process_detail procedure is called by
-- Organization Certification Detail + Significant Account Evaluation Summary report.
PROCEDURE get_process_detail(
   p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

---12.08.2005 npanandi: added below function
function get_default_year
  return varchar2;

----01.05.2006 npanandi: added below function
FUNCTION get_last_day(date_id NUMBER, type VARCHAR2) RETURN varchar2;

END RCI_ORG_CERT_SUMM_PKG;

 

/
