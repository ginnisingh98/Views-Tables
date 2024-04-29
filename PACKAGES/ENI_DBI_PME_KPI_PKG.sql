--------------------------------------------------------
--  DDL for Package ENI_DBI_PME_KPI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_PME_KPI_PKG" AUTHID CURRENT_USER AS
/*$Header: ENIPMEPS.pls 115.1 2003/08/29 16:27:28 smccombe noship $*/
PROCEDURE get_sql
(
	p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
        x_custom_sql OUT NOCOPY VARCHAR2,
        x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);
END eni_dbi_pme_kpi_pkg;

 

/
