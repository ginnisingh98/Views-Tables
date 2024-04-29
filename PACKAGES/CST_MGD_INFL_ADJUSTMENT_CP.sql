--------------------------------------------------------
--  DDL for Package CST_MGD_INFL_ADJUSTMENT_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_MGD_INFL_ADJUSTMENT_CP" AUTHID CURRENT_USER AS
/* $Header: CSTCIADS.pls 120.1 2006/01/23 14:38:20 vjavli noship $ */

-- +======================================================================+
-- GLOBAL CONSTANTS
-- +======================================================================+
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_MGD_INFL_ADJUSTMENT_CP';

--===================
-- PRIVATE PROCEDURES
--===================


--========================================================================
-- PROCEDURE : Calculate_Adjustment    PRIVATE
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_org_id                Organization ID
--             p_country_code          Country code
--             p_acct_period_id        Account period ID
--             p_inflation_index       Inflation index
-- COMMENT   : This is the concurrent program for inflation adjustment.
--========================================================================
PROCEDURE Calculate_Adjustment (
  x_errbuf          OUT NOCOPY VARCHAR2
, x_retcode         OUT NOCOPY VARCHAR2
, p_org_id          IN  NUMBER
, p_country_code    IN  VARCHAR2
, p_acct_period_id  IN  NUMBER
, p_inflation_index IN  VARCHAR2
);


--========================================================================
-- PROCEDURE : Transfer_to_GL          PRIVATE
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_org_id                Organization ID
--             p_country_code          Country code
--             p_acct_period_id        Account perio ID
-- COMMENT   : This concurrent program creates account entries for
--             inflation adjusted items and set the period to final.
--========================================================================
PROCEDURE Transfer_to_GL (
  x_errbuf         OUT NOCOPY VARCHAR2
, x_retcode        OUT NOCOPY VARCHAR2
, p_org_id         IN  NUMBER
, p_country_code   IN  VARCHAR2
, p_acct_period_id IN  NUMBER
);


END CST_MGD_INFL_ADJUSTMENT_CP;

 

/
