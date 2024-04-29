--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_QUERY_TIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_QUERY_TIME" AUTHID CURRENT_USER AS
/* $Header: hriopqtm.pkh 120.0 2005/05/29 07:34:12 appldev noship $ */

PROCEDURE GET_TIME_CLAUSE
          (p_projection_type     VARCHAR2 DEFAULT 'N'
          ,p_page_period_type    VARCHAR2
          ,p_page_comp_type      VARCHAR2
          ,o_trend_table         OUT NOCOPY VARCHAR2
          ,o_previous_periods    OUT NOCOPY VARCHAR2
          ,o_projection_periods  OUT NOCOPY VARCHAR2);

FUNCTION get_time_clause
          (p_past_trend   IN VARCHAR2 DEFAULT 'Y',
           p_future_trend IN VARCHAR2 DEFAULT 'N')
         RETURN VARCHAR2;

PROCEDURE get_period_binds
          (p_projection_type     VARCHAR2 DEFAULT 'N'
          ,p_page_period_type    VARCHAR2
          ,p_page_comp_type      VARCHAR2
          ,o_previous_periods    OUT NOCOPY NUMBER
          ,o_projection_periods  OUT NOCOPY NUMBER);

END HRI_OLTP_PMV_QUERY_TIME;

 

/
