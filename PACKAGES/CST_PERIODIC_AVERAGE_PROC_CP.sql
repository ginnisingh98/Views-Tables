--------------------------------------------------------
--  DDL for Package CST_PERIODIC_AVERAGE_PROC_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PERIODIC_AVERAGE_PROC_CP" AUTHID CURRENT_USER AS
-- $Header: CSTVITPS.pls 120.2.12010000.1 2008/07/24 17:25:59 appldev ship $
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     CSTVITPS.pls   Created By Vamshi Mutyala                          |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Periodic Average Cost Processor  Concurrent Program                |
--|                                                                       |
--+========================================================================


--========================================================================
-- PROCEDURE : begin_cp_worker     PUBLIC
-- PARAMETERS:  x_errbuf                 OUT Error Message If any
--		x_retcode                OUT Return Status
--		p_legal_entity           IN  Legal Entity Id
--		p_cost_type_id           IN  Cost Type Id
--		p_cost_method            IN  Cost Method Type
--		p_cost_group_id          IN  Cost Group Id
--		p_period_id              IN  PAC Period Id
--		p_prev_period_id         IN  Previous PAC Period Id
--		p_starting_phase         IN  Starting Phase in PAC process
--		p_pac_rates_id           IN  PAC Rates Id
--		p_start_date             IN  Start date of PAC period
--		p_end_date               IN  End date of PAC period
-- COMMENT   : This procedure will process phases 1-4 for all transactions
--=========================================================================

PROCEDURE begin_cp_worker
( x_errbuf                 OUT NOCOPY VARCHAR2
, x_retcode                OUT NOCOPY VARCHAR2
, p_legal_entity           IN  NUMBER
, p_cost_type_id           IN  NUMBER
, p_master_org_id          IN  NUMBER
, p_cost_method            IN  NUMBER
, p_cost_group_id          IN  NUMBER
, p_period_id              IN  NUMBER
, p_prev_period_id         IN  NUMBER
, p_starting_phase         IN  NUMBER
, p_pac_rates_id           IN  NUMBER
, p_uom_control            IN  NUMBER
, p_start_date             IN  DATE
, p_end_date               IN  DATE
);

--========================================================================
-- PROCEDURE : Set Status    PRIVATE
-- COMMENT   : Set the status of a specific phase
--========================================================================
PROCEDURE set_status
( p_period_id           IN NUMBER
, p_cost_group_id       IN NUMBER
, p_phase               IN NUMBER
, p_status              IN NUMBER
, p_end_date            IN DATE
, p_user_id             IN NUMBER
, p_login_id            IN NUMBER
, p_req_id              IN NUMBER
, p_prg_id              IN NUMBER
, p_prg_appid           IN NUMBER
);

END CST_PERIODIC_AVERAGE_PROC_CP;

/
