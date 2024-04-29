--------------------------------------------------------
--  DDL for Package CN_NOTIFY_WRITEOFFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_NOTIFY_WRITEOFFS" AUTHID CURRENT_USER AS
-- $Header: cnnowos.pls 120.0 2005/08/29 08:15:49 vensrini noship $


--
-- Procedure Name
--   collect
-- Purpose
--   This procedure collects source data for writeoffs
-- History
--   01-05-96	A. Erickson	Created
--

  PROCEDURE notify (
	x_start_period	cn_periods.period_id%TYPE,
	x_end_period	cn_periods.period_id%TYPE,
	debug_pipe	VARCHAR2 DEFAULT NULL,
	debug_level	NUMBER	 DEFAULT NULL,
    x_org_id NUMBER ) ;


END cn_notify_writeoffs;
 

/
