--------------------------------------------------------
--  DDL for Package CN_NOTIFY_AIA_OM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_NOTIFY_AIA_OM" AUTHID CURRENT_USER AS
-- $Header: CNNOAIAOMS.pls 120.0.12010000.2 2009/06/05 13:05:28 rajukum noship $


--
-- Procedure Name
--   notify
-- Purpose
--   This procedure collects source data for AIA order records
-- History
--

  PROCEDURE notify (
	x_start_period	cn_periods.period_id%TYPE,
	x_end_period	cn_periods.period_id%TYPE,
	debug_pipe	VARCHAR2 DEFAULT NULL,
	debug_level	NUMBER	 DEFAULT NULL,
    x_org_id NUMBER ) ;

--
-- Procedure Name
--   notify_failed_trx
-- Purpose
--   This procedure collects source data for AIA order records
-- History
--

  PROCEDURE notify_failed_trx (
        p_batch_id	cn_not_trx_all.batch_id%TYPE,
	x_start_period	cn_periods.period_id%TYPE,
	x_end_period	cn_periods.period_id%TYPE,
	debug_pipe	VARCHAR2 DEFAULT NULL,
	debug_level	NUMBER	 DEFAULT 1,
    x_org_id NUMBER ) ;


END cn_notify_aia_om;

/
