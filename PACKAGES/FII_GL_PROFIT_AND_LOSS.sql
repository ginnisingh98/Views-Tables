--------------------------------------------------------
--  DDL for Package FII_GL_PROFIT_AND_LOSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_PROFIT_AND_LOSS" AUTHID CURRENT_USER AS
/* $Header: FIIGLPLS.pls 115.8 2003/12/26 22:01:56 juding noship $ */

  PROCEDURE GET_OPER_PROFIT1 (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  oper_profit_sql out NOCOPY VARCHAR2,
  oper_profit_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE get_oper_profit (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  oper_profit_sql out NOCOPY VARCHAR2, oper_profit_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE GET_REV_BY_CHANNEL (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  rev_by_channel_sql out NOCOPY VARCHAR2, rev_by_channel_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END fii_gl_profit_and_loss;

 

/
