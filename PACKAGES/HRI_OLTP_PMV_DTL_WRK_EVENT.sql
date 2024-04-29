--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_DTL_WRK_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_DTL_WRK_EVENT" AUTHID CURRENT_USER AS
/* $Header: hriopwev.pkh 120.3 2005/06/13 02:47:51 cbridge noship $ */

-- U.I rearchitecture procedures
PROCEDURE get_hire_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                                 x_custom_sql     OUT NOCOPY VARCHAR2,
                                 x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_term_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                                 x_custom_sql     OUT NOCOPY VARCHAR2,
                                 x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_trans_in_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                                     x_custom_sql     OUT NOCOPY VARCHAR2,
                                     x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_trans_out_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                                      x_custom_sql     OUT NOCOPY VARCHAR2,
                                      x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_turnover_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                               x_custom_sql     OUT NOCOPY VARCHAR2,
                               x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_wf_trans_out_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                                   x_custom_sql     OUT NOCOPY VARCHAR2,
                                   x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_c_trans_out_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                                  x_custom_sql     OUT NOCOPY VARCHAR2,
                                  x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_c_trans_in_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                                 x_custom_sql     OUT NOCOPY VARCHAR2,
                                 x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END hri_oltp_pmv_dtl_wrk_event;

 

/
