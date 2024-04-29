--------------------------------------------------------
--  DDL for Package CN_NOTIFY_AIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_NOTIFY_AIA" AUTHID CURRENT_USER AS
-- $Header: CNNOAIAS.pls 120.0.12010000.1 2008/11/20 06:09:09 rajukum noship $


--
-- Procedure Name
--   collect
-- Purpose
--   This procedure collects source data for AIA records
-- History
--

  PROCEDURE notify (
	x_start_period	cn_periods.period_id%TYPE,
	x_end_period	cn_periods.period_id%TYPE,
	debug_pipe	VARCHAR2 DEFAULT NULL,
	debug_level	NUMBER	 DEFAULT NULL,
    x_org_id NUMBER ) ;


END cn_notify_aia;

/
