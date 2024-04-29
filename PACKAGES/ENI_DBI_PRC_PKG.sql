--------------------------------------------------------
--  DDL for Package ENI_DBI_PRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_PRC_PKG" AUTHID CURRENT_USER AS
/*$Header: ENIPRCPS.pls 115.1 2003/08/05 05:09:58 smccombe noship $*/

PROCEDURE get_sql
(
	p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
        x_custom_sql OUT NOCOPY VARCHAR2,
        x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

END eni_dbi_prc_pkg;

 

/
