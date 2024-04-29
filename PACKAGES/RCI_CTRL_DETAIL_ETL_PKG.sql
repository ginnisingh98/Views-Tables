--------------------------------------------------------
--  DDL for Package RCI_CTRL_DETAIL_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCI_CTRL_DETAIL_ETL_PKG" AUTHID CURRENT_USER AS
--$Header: rcicdtetls.pls 120.3.12000000.1 2007/01/16 20:46:08 appldev ship $

PROCEDURE initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

PROCEDURE incr_load(
   errbuf  IN OUT NOCOPY VARCHAR2
  ,retcode IN OUT NOCOPY NUMBER);

FUNCTION get_last_run_date ( p_fact_name VARCHAR2) RETURN DATE;

FUNCTION err_mesg (
   p_mesg      IN VARCHAR2
  ,p_proc_name IN VARCHAR2 DEFAULT NULL
  ,p_stmt_id   IN NUMBER DEFAULT -1) RETURN VARCHAR2 ;

PROCEDURE check_initial_load_setup (
   x_global_start_date OUT NOCOPY DATE
  ,x_rci_schema 	   OUT NOCOPY VARCHAR2);

END RCI_CTRL_DETAIL_ETL_PKG;

 

/
