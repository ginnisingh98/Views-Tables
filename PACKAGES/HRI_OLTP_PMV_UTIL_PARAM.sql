--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_UTIL_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_UTIL_PARAM" AUTHID CURRENT_USER AS
/* $Header: hrioputp.pkh 120.2 2005/09/20 05:02:44 jrstewar noship $ */

TYPE HRI_PMV_PARAM_REC_TYPE IS RECORD
      (time_curr_start_date   DATE,
       time_curr_end_date     DATE,
       time_comp_start_date   DATE,
       time_comp_end_date     DATE,
       page_period_type       VARCHAR2(30),
       time_comparison_type   VARCHAR2(30),
       peo_supervisor_id      NUMBER,
       currency_code          VARCHAR2(40),
       rate_type              VARCHAR2(40),
       event_sep_type         VARCHAR2(30),
       absence_duration_uom   VARCHAR2(100),
       absence_category       VARCHAR2(4000),
       absence_type           VARCHAR2(4000),
       absence_reason         VARCHAR2(4000),
       view_by                VARCHAR2(100),
       peo_sup_rollup_flag    VARCHAR2(30),
       wkth_wktyp_sk_fk       VARCHAR2(30),
       order_by               VARCHAR2(1000),
       bis_region_code        VARCHAR2(30),
       debug_header           VARCHAR2(4000));

TYPE HRI_PMV_BIND_REC_TYPE IS RECORD
      (pmv_bind_string        VARCHAR2(32000),
       sql_bind_string        VARCHAR2(32000));

TYPE HRI_PMV_BIND_TAB_TYPE IS TABLE OF HRI_PMV_BIND_REC_TYPE
       INDEX BY VARCHAR2(100);

PROCEDURE get_parameters_from_table
           (p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
            p_parameter_rec        OUT NOCOPY HRI_PMV_PARAM_REC_TYPE,
            p_bind_tab             OUT NOCOPY HRI_PMV_BIND_TAB_TYPE);

END hri_oltp_pmv_util_param;

 

/
