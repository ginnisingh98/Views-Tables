--------------------------------------------------------
--  DDL for Package RCI_COMPL_ENV_CHG_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCI_COMPL_ENV_CHG_SUMM_PKG" AUTHID CURRENT_USER as
/*$Header: rcicmpenvchgsums.pls 120.2 2005/12/09 12:00:39 appldev noship $*/

/*** 12.09.2005 npanandi: added below procedure/functions ***/
PROCEDURE check_initial_load_setup (
   x_global_start_date OUT NOCOPY DATE
  ,x_rci_schema 	   OUT NOCOPY VARCHAR2);

FUNCTION get_last_run_date ( p_fact_name VARCHAR2) RETURN DATE;

FUNCTION err_mesg (
   p_mesg      IN VARCHAR2
  ,p_proc_name IN VARCHAR2 DEFAULT NULL
  ,p_stmt_id   IN NUMBER DEFAULT -1) RETURN VARCHAR2 ;
/*** 12.09.2005 npanandi: ends procedure/functions ***/

procedure initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

procedure incremental_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

function calculate_risks_chg(   cert_id in number,
                                org_id in number,
                                process_id in number) return number;

function calculate_cntrl_chg(   cert_id in number,
                                org_id in number,
                                process_id in number) return number;

PROCEDURE         get_summ_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

end rci_compl_env_chg_summ_pkg;

 

/
