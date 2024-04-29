--------------------------------------------------------
--  DDL for Package RCI_OPEN_ISSUE_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCI_OPEN_ISSUE_SUMM_PKG" AUTHID CURRENT_USER as
/*$Header: rciopenisssumms.pls 120.1 2005/10/07 18:05:00 appldev noship $*/

procedure initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

procedure incremental_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);


PROCEDURE         get_summ_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


end RCI_OPEN_ISSUE_SUMM_PKG;

 

/
