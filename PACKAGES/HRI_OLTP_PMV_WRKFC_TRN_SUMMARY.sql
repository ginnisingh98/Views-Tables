--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WRKFC_TRN_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WRKFC_TRN_SUMMARY" AUTHID CURRENT_USER AS
/* $Header: hriopwsm.pkh 120.0 2005/05/29 07:39:07 appldev noship $ */

PROCEDURE get_sql_pvt(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql         OUT NOCOPY VARCHAR2,
                      x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END hri_oltp_pmv_wrkfc_trn_summary;

 

/
