--------------------------------------------------------
--  DDL for Package RCI_OPEN_REMED_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCI_OPEN_REMED_SUMM_PKG" AUTHID CURRENT_USER AS
/*$Header: rciopnrs.pls 120.5.12000000.1 2007/01/16 20:46:35 appldev ship $*/
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE get_kpi(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_open_remediation_result(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_findings_details(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE get_remediations_details(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE open_remed_act_initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

PROCEDURE open_remed_act_increment_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

/*
PROCEDURE open_remed_act_initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);
PROCEDURE open_remed_act_incremental_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);
*/

PROCEDURE fn_Get_Bucket_Id(age_in_days Number, v_1 out NOCOPY  Number, v_2 out NOCOPY  Number, v_3 out NOCOPY  Number, v_4 out NOCOPY  Number);

FUNCTION get_last_day(date_id NUMBER, type VARCHAR2) RETURN varchar2;

procedure insert_findings_initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

procedure insert_findings_increment_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

procedure insert_remeds_initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

procedure insert_remeds_increment_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

/** 12.16.2005 npanandi: added check_initial_load_setup below **/
PROCEDURE check_initial_load_setup (
   x_global_start_date OUT NOCOPY DATE
  ,x_rci_schema 	   OUT NOCOPY VARCHAR2);

/** 12.16.2005 npanandi: added err_mesg below **/
FUNCTION err_mesg (
   p_mesg      IN VARCHAR2
  ,p_proc_name IN VARCHAR2 DEFAULT NULL
  ,p_stmt_id   IN NUMBER DEFAULT -1) RETURN VARCHAR2 ;

END RCI_OPEN_REMED_SUMM_PKG;

 

/
