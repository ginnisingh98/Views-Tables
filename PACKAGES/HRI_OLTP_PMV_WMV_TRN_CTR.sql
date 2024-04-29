--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_TRN_CTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_TRN_CTR" AUTHID CURRENT_USER AS
/* $Header: hriopwtc.pkh 120.0 2005/05/29 07:39:36 appldev noship $ */

PROCEDURE GET_SQL_RNK_CTR(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql         OUT NOCOPY VARCHAR2,
                      x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_SQL_CTR_T4(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                         x_custom_sql         OUT NOCOPY VARCHAR2,
                         x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END hri_oltp_pmv_wmv_trn_ctr;

 

/
