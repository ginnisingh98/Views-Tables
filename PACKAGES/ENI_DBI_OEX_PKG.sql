--------------------------------------------------------
--  DDL for Package ENI_DBI_OEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_OEX_PKG" AUTHID CURRENT_USER AS
/*$Header: ENIOEXPS.pls 115.2 2003/08/05 05:15:57 smccombe noship $*/

PROCEDURE get_sql
(
	p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
        x_custom_sql OUT NOCOPY VARCHAR2,
        x_custom_output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL
) ;

END eni_dbi_oex_pkg;

 

/
