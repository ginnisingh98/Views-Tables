--------------------------------------------------------
--  DDL for Package QP_MGD_EURO_PRICING_MEDIATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MGD_EURO_PRICING_MEDIATOR" AUTHID CURRENT_USER AS
/*  $Header: QPXMPRDS.pls 120.0 2005/06/01 23:55:11 appldev noship $ */

---+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     QPXMPRDS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Specification of    QP_MGD_EURO_PRICING_MEDIATOR                   |
--|                                                                       |
--| HISTORY                                                               |
--|     20-Jun-2000  rajkrish            Created                          |
--+======================================================================


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Convert_Pricing_Data

-- COMMENT   : Main Logic to Convert theh pricing data to Euro
--             No parameters requirtes as the entite data needs to
--             be converted to Euro. ( Only the currency that falls in the
--               Euro Zone ).
--             The process requires no Inputs
--=======================================================================
PROCEDURE Convert_Pricing_Data ;



END QP_MGD_EURO_PRICING_MEDIATOR;


 

/
