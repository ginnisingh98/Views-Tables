--------------------------------------------------------
--  DDL for Package RCI_SIG_ACCT_EVAL_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCI_SIG_ACCT_EVAL_SUMM_PKG" AUTHID CURRENT_USER AS
/*$Header: rcisgacs.pls 120.5.12000000.1 2007/01/16 20:46:47 appldev ship $*/

PROCEDURE get_kpi(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_sig_acct_eval_details(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION get_risk_count(p_org_id number) return number;
FUNCTION get_control_count(p_org_id number) return number;
FUNCTION get_latest_engagement(p_org_id number) return varchar2;
PROCEDURE get_org_details(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_sig_acct_details(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_sig_acct_eval_result(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_sig_acct_eval_summ_result(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE sig_acct_incremental_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

PROCEDURE sig_acct_initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

/*todo 01/06/2005 remove this--These 3 procedures from amwvfscb.pls
Procedure CountOrgsIneffCtrl_finitem
    (P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
    P_FINANCIAL_ITEM_ID in number , p_org_with_ineffective_ctrls  OUT NOCOPY  number);
Procedure CountUnmittigatedRisk_finitem
    (P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
    P_FINANCIAL_ITEM_ID in number , p_unmitigated_risks  OUT NOCOPY  number);
Procedure CountIneffectiveCtrls_finitem
    (P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
    P_FINANCIAL_ITEM_ID in number , p_ineffective_controls  OUT NOCOPY  number);
*/
FUNCTION get_unmiti_risks(p_cert_id number, p_org_id number) return number;
FUNCTION get_ineff_ctrls(p_cert_id number, p_org_id number) return number;
FUNCTION get_ineff_procs(p_cert_id number, p_org_id number) return number;
PROCEDURE get_org_def_details(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
END RCI_SIG_ACCT_EVAL_SUMM_PKG;


 

/
