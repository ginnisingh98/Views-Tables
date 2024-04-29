--------------------------------------------------------
--  DDL for Package CST_PERIODIC_ABSORPTION_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PERIODIC_ABSORPTION_CP" AUTHID CURRENT_USER AS
-- $Header: CSTCITPS.pls 120.1.12000000.3 2007/05/10 05:40:24 vmutyala ship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     CSTCITPS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Periodic Absorption Cost Processor concurrent Program             |
--| HISTORY                                                               |
--|     08/26/03 David Herring   Created                                  |
--|     10/27/2003 vjavli        p_tolerance parameter updated            |
--|     11/25/03   David Herring moved order of run option parameter      |
--|     01/20/04   vjavli        x_errbuf, x_retcode is the right order   |
--|     04/10/04   vjavli        Main Concurrent Program api: name change |
--|                              to Periodic_Absorb_Cost_Process          |
--+========================================================================

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Periodic_Absorb_Cost_Process      PRIVATE
-- COMMENT   : This procedure acts as a wrapper around the code that will
--             process periodic absorption cost of transactions according
--             to the periodic weighted average costing (PWAC) cost method
--             using a new Periodic Absorption Cost Rollup algorithm
--=========================================================================
PROCEDURE Periodic_Absorb_Cost_Process
( x_errbuf                  OUT NOCOPY VARCHAR2
, x_retcode                 OUT NOCOPY VARCHAR2
, p_legal_entity_id         IN  VARCHAR2
, p_cost_type_id            IN  VARCHAR2
, p_period_id               IN  VARCHAR2
, p_run_options             IN  VARCHAR2
, p_process_upto_date       IN  VARCHAR2 DEFAULT NULL
, p_tolerance               IN  VARCHAR2
, p_number_of_iterations    IN  VARCHAR2
, p_number_of_workers       IN  VARCHAR2 DEFAULT '1'
);

END CST_PERIODIC_ABSORPTION_CP;

 

/
