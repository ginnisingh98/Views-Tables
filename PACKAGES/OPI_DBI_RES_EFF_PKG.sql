--------------------------------------------------------
--  DDL for Package OPI_DBI_RES_EFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_RES_EFF_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDRRSEFS.pls 115.0 2003/06/25 00:52:43 warwu noship $ */


/*
    Report query for viewby = Org, Res G, Res D, Res
*/
PROCEDURE get_rpt_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

/*
    Report query for viewby = Time
*/

PROCEDURE get_trd_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END opi_dbi_res_eff_pkg;

 

/
