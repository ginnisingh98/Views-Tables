--------------------------------------------------------
--  DDL for Package RCI_PROC_CERT_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCI_PROC_CERT_SUMM_PKG" AUTHID CURRENT_USER as
/*$Header: rciproccerts.pls 120.7.12000000.1 2007/01/16 20:46:44 appldev ship $*/

function get_default_year return varchar2;
PROCEDURE get_kpi(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_proc_cert_result(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_proc_cert_summary(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE proc_cert_initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

PROCEDURE proc_cert_incremental_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);
/*todo remove this later
TYPE TIME_DIMENSIONS_RECORD IS RECORD
(
	 period_year number(15)
	 ,period_num number(15)
	 ,quarter_num number(15)
	 ,ent_period_id number
	 ,ent_qtr_id number
	 ,ent_year_id number
	 ,report_date_julian number
);
TYPE CERT_DETAIL_RECORD IS RECORD
(
	 cert_id amw_certification_b.certification_id%type
     ,cert_status amw_certification_b.certification_status%type
     ,cert_type amw_certification_b.certification_type%type
);
*/

PROCEDURE update_proc_cert_table(
    p_process_id IN NUMBER,
    p_org_id IN NUMBER,
    p_cert_id IN NUMBER);
--todo remove this later
--    cert_rec IN CERT_DETAIL_RECORD,time_rec IN TIME_DIMENSIONS_RECORD);

PROCEDURE get_proc_cert_details(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END RCI_PROC_CERT_SUMM_PKG;


 

/
