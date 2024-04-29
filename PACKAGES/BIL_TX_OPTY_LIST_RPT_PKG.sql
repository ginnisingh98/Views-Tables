--------------------------------------------------------
--  DDL for Package BIL_TX_OPTY_LIST_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_TX_OPTY_LIST_RPT_PKG" AUTHID CURRENT_USER AS
/* $Header: biltxols.pls 120.1 2005/09/19 15:33 syeddana ship $ */


PROCEDURE OPTY_LIST_RPT (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                        ,x_custom_sql    OUT NOCOPY VARCHAR2
                        ,x_custom_attr   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END BIL_TX_OPTY_LIST_RPT_PKG;


 

/
