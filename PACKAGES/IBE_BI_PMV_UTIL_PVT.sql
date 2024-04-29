--------------------------------------------------------
--  DDL for Package IBE_BI_PMV_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_BI_PMV_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVBIUTILS.pls 120.1 2005/09/16 05:51:38 appldev ship $ */

FUNCTION GET_CURR_CODE(id IN varchar2,p_MSITE_ID IN varchar2)
                 return varchar2;

PROCEDURE ENT_YR_SPAN(p_asof_date   IN  Date,
                      x_timespan    OUT NOCOPY Number,
                      x_sequence    OUT NOCOPY Number);

PROCEDURE ENT_QTR_SPAN(p_asof_date  IN  DATE,
                       p_comparator IN  VARCHAR2,
                       x_cur_start  OUT NOCOPY DATE,
                       x_prev_start OUT NOCOPY DATE,
                       x_mid_start  OUT NOCOPY DATE,
                       x_cur_year   OUT NOCOPY NUMBER,
                       x_prev_year  OUT NOCOPY NUMBER,
                       x_timespan   OUT NOCOPY NUMBER);

PROCEDURE ENT_PRD_SPAN(p_asof_date  IN  DATE,
                       p_comparator IN  VARCHAR2,
                       x_cur_start  OUT NOCOPY DATE,
                       x_prev_start OUT NOCOPY DATE,
                       x_mid_start  OUT NOCOPY DATE,
                       x_cur_year   OUT NOCOPY NUMBER,
                       x_prev_year  OUT NOCOPY NUMBER,
                       x_timespan   OUT NOCOPY NUMBER);

PROCEDURE WEEK_SPAN(  p_asof_date   IN  DATE,
                      p_comparator  IN VARCHAR2,
                      x_cur_start   OUT NOCOPY DATE,
                      x_prev_start  OUT NOCOPY DATE,
                      x_pcur_start  OUT NOCOPY DATE,
                      x_pprev_start OUT NOCOPY DATE,
                      x_timespan    OUT NOCOPY NUMBER);

FUNCTION GET_RECORD_TYPE_ID(p_period_type IN VARCHAR2)
RETURN NUMBER;

FUNCTION GET_PREV_DATE(p_asof_date IN DATE, p_period_type VARCHAR2, p_comparison_type VARCHAR2)
RETURN DATE;

END IBE_BI_PMV_UTIL_PVT;

 

/
