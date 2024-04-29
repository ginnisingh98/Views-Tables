--------------------------------------------------------
--  DDL for Package CN_RAM_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RAM_ADJUSTMENTS_PKG" AUTHID CURRENT_USER AS
-- $Header: cnvrams.pls 120.3 2005/08/29 08:16:16 vensrini noship $

-- Procedure Name
--   identify
-- Purpose
--   To identify the RAM adjustments

  PROCEDURE identify (
	x_start_period	cn_periods.period_id%TYPE,
	x_end_period	cn_periods.period_id%TYPE,
	debug_pipe	VARCHAR2 DEFAULT NULL,
	debug_level	NUMBER	 DEFAULT NULL,
    x_org_id NUMBER );

-- Procedure Name
--   negate
-- Purpose
--   To negate OIC compensation transactions in API/Header tables which
--   have been identified in the "identify process" of RAM adjustment collection.
--   The new adjusted compensation transactins will be re-collected in the
--   "re-collect process" later.

  PROCEDURE negate (
	debug_pipe	VARCHAR2 DEFAULT NULL,
	debug_level	NUMBER	 DEFAULT NULL,
    x_org_id NUMBER );

END cn_ram_adjustments_pkg;


 

/
