--------------------------------------------------------
--  DDL for Package FII_PSI_FUNDS_AVAIL_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PSI_FUNDS_AVAIL_SUM_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIPSIFAS.pls 120.1 2005/10/30 05:06:05 appldev noship $ */

PROCEDURE GET_FUNDS_AVAIL_SUM
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       funds_avail_sql out NOCOPY VARCHAR2,
       funds_avail_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END;

 

/
