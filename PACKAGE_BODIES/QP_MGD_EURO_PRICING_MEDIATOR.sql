--------------------------------------------------------
--  DDL for Package Body QP_MGD_EURO_PRICING_MEDIATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MGD_EURO_PRICING_MEDIATOR" AS
/*  $Header: QPXMPRDB.pls 120.0 2005/06/02 01:32:51 appldev noship $ */
---+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     QPXMPRDB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Package Body  of    QP_MGD_EURO_PRICING_MEDIATOR                   |
--|    Euro conversion program for QP pricing data                        |
--|                                                                       |
--| HISTORY                                                               |
--|     20-Jun-2000  rajkrish            Created                          |
--|     04-oct-2000                      Updated                          |
--|     05-Jan-2000  rajkrish       updated BUG 1570643                   |
--|     13-DEc-2001  rajkrish       BUG 2138996 2PM                       |
--|                  Manufacturing Globalization Team                     |
--|     Jan-10-2002  Rajkrish IT  hints                                   |
--|     03-APR-2002  tsimmond   removed code                              |
--+=======================================================================+


G_PKG_NAME CONSTANT VARCHAR2(30) := 'QP_MGD_EURO_PRICING_MEDIATOR' ;
G_mgd_request_id    NUMBER ;
G_mgd_program_id    NUMBER ;
G_mgd_user_id       NUMBER ;
G_rate              NUMBER ;
--===========================
-- PROCEDURES AND FUNCTIONS
--===========================


--========================================================================
-- PROCEDURE : Convert_Pricing_Data

-- COMMENT   : Main Logic to Convert theh pricing data to Euro
--             No parameters requirtes as the entite data needs to
--             be converted to Euro. ( Only the currency that falls in the
--               Euro Zone ).
--             The process requires no Inputs
--=======================================================================
PROCEDURE Convert_Pricing_Data
IS
BEGIN

  NULL;
  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END Convert_Pricing_Data;

END QP_MGD_EURO_PRICING_MEDIATOR;


/
