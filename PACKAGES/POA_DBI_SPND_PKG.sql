--------------------------------------------------------
--  DDL for Package POA_DBI_SPND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_SPND_PKG" AUTHID CURRENT_USER AS
/* $Header: poadbispnds.pls 120.0 2005/09/08 17:15:35 nnewadka noship $ */
--
PROCEDURE trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT  NOCOPY VARCHAR2
                   ,x_custom_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END poa_dbi_spnd_pkg ;

 

/
