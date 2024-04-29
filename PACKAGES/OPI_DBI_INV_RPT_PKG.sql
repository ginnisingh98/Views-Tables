--------------------------------------------------------
--  DDL for Package OPI_DBI_INV_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_INV_RPT_PKG" 
/* $Header: OPIDRINVRS.pls 120.1 2005/08/10 03:58:01 srayadur noship $ */

AUTHID CURRENT_USER AS

TYPE opi_dbi_col_rec is RECORD(column_name         VARCHAR2(32),
                               column_alias        VARCHAR2(32));

TYPE opi_dbi_col_tbl is TABLE of opi_dbi_col_rec;

TYPE opi_dbi_dim_tbl is TABLE of varchar2(100);


/* Inventory Turns table portlet */
PROCEDURE inv_turns_tbl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY
                BIS_QUERY_ATTRIBUTES_TBL);

  /* Inventory Turns trend portlet */
PROCEDURE inv_turns_trd_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY
                  BIS_QUERY_ATTRIBUTES_TBL);

END OPI_DBI_INV_RPT_PKG;

 

/
