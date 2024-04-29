--------------------------------------------------------
--  DDL for Package BIX_REAL_TIME_RPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_REAL_TIME_RPTS_PKG" AUTHID CURRENT_USER AS
/* $Header: bixxrtss.pls 115.9 2003/01/10 00:14:15 achanda noship $ */
PROCEDURE pop_q_st_rpt(p_context VARCHAR2);
PROCEDURE pop_agt_st_rpt(p_context VARCHAR2);
PROCEDURE pop_agt_dtl_rpt(p_context VARCHAR2);
END BIX_REAL_TIME_RPTS_PKG;

 

/
