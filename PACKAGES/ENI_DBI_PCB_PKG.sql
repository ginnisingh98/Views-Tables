--------------------------------------------------------
--  DDL for Package ENI_DBI_PCB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_PCB_PKG" AUTHID CURRENT_USER AS
   /*$Header: ENIPCBPS.pls 115.2 2003/11/20 11:14:44 skadamal noship $*/

PROCEDURE GET_SQL ( p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql        OUT NOCOPY VARCHAR2
                  , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION GetLabel(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                  , measure_label IN NUMBER) RETURN VARCHAR2;
END ENI_DBI_PCB_PKG;

 

/
