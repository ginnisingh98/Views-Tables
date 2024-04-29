--------------------------------------------------------
--  DDL for Package OPI_DBI_RES_EFF_JOB_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_RES_EFF_JOB_DTL_PKG" AUTHID CURRENT_USER as
/*$Header: OPIDRRSEJDS.pls 120.0 2005/05/24 17:57:14 appldev noship $ */

  PROCEDURE get_dtl_sql( p_param          IN         BIS_PMV_PAGE_PARAMETER_TBL
                     , x_custom_sql     OUT NOCOPY VARCHAR2
                     , x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
END opi_dbi_res_eff_job_dtl_pkg;

 

/
