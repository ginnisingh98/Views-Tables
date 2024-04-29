--------------------------------------------------------
--  DDL for Package ONT_MGD_EURO_OE_MEDIATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_MGD_EURO_OE_MEDIATOR" AUTHID CURRENT_USER AS
/*  $Header: ONTMSOXS.pls 120.0 2005/06/01 02:20:19 appldev noship $ */

---+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     ONTMSOXS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Specification of    ONT_MGD_EURO_OE_MEDIATOR                   |
--|                                                                       |
--| HISTORY                                                               |
--|     03-Aug-2000  rajkrish            Created                          |
--+======================================================================


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Convert_sales_orders

-- COMMENT   : Main Logic to Convert the Sales Orders to Euro
--             This package converts the Open Sales Order to Euro
--=======================================================================
PROCEDURE Convert_sales_orders
( p_customer_id              IN NUMBER
, p_header_invoice_to_org_id IN NUMBER
, p_line_invoice_to_org_id   IN NUMBER
, p_so_conversion_ncu        IN VARCHAR2
, p_convert_partial_so       IN VARCHAR2
, p_so_reprice_flag          IN VARCHAR2
) ;


END ONT_MGD_EURO_OE_MEDIATOR;


 

/
