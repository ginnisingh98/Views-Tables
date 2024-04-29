--------------------------------------------------------
--  DDL for Package BIX_REAL_TIME_BINS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_REAL_TIME_BINS_PKG" AUTHID CURRENT_USER AS
/* $Header: bixquebs.pls 115.17 2003/01/10 00:14:59 achanda ship $ */
PROCEDURE populate_bin(p_context VARCHAR2 DEFAULT NULL);
PROCEDURE populate_agent_status_bin(p_context VARCHAR2 DEFAULT NULL);

END BIX_REAL_TIME_BINS_PKG;

 

/
