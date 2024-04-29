--------------------------------------------------------
--  DDL for Package CST_MGD_INFL_ADJUSTMENT_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_MGD_INFL_ADJUSTMENT_RPT" AUTHID CURRENT_USER AS
/* $Header: CSTRIADS.pls 115.7 2004/01/30 08:56:11 vjavli ship $ */

-- +======================================================================+
-- GLOBAL CONSTANTS
-- +======================================================================+
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_MGD_INFL_ADJUSTMENT_RPT';

--===================
-- PUBLIC PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Create_Infl_Adj_Rpt     PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_item_from_code        Report start item code
--             p_item_to_code          Report end item code
--             p_rpt_from_date         Report start date
--             p_rpt_to_date           Report end date
-- COMMENT   : Main procedure called by Kardex report
--========================================================================
PROCEDURE Create_Infl_Adj_Rpt
( p_org_id         IN  NUMBER
, p_item_from_code IN  VARCHAR2 := NULL
, p_item_to_code   IN  VARCHAR2 := NULL
, p_rpt_from_date  IN  VARCHAR2
, p_rpt_to_date    IN  VARCHAR2
);

END CST_MGD_INFL_ADJUSTMENT_RPT;

 

/
