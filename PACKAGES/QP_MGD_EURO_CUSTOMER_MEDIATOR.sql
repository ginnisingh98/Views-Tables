--------------------------------------------------------
--  DDL for Package QP_MGD_EURO_CUSTOMER_MEDIATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MGD_EURO_CUSTOMER_MEDIATOR" AUTHID CURRENT_USER AS
-- $Header: QPXMCSTS.pls 120.0 2005/06/02 00:02:16 appldev noship $
---+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     QPXMCSTS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Specification of    QP_MGD_EURO_CUSTOMER_MEDIATOR                  |
--|                                                                       |
--| HISTORY                                                               |
--|     03-May-2000  rajkrish            Created                          |
--|     07-May-2001  tsimmond   added procedure All_Customer_Conversion   |
--+======================================================================


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Customer_Conversion           PUBLIC
-- PARAMETERS: p_customer_id                 Customer id to be Converted
--             p_customer_number             Customer number
--             p_default_euro_price_list_id  Default Euro price list id.
--             p_update_existing_euro_pl     Yes/No to update existing
--                                           price list.
--
-- COMMENT   : Main Logic to Process the Customer Conversion
--
--=======================================================================
PROCEDURE Customer_Conversion
( p_customer_id                IN  NUMBER
, p_customer_number            IN  VARCHAR2
, p_default_euro_price_list_id IN  NUMBER
, p_update_existing_euro_pl    IN  VARCHAR2 := 'N'
);


--========================================================================
-- PROCEDURE : Sites_Conversion        PUBLIC
-- PARAMETERS: p_customer_number       Customer Number
--             p_customer_address_id   Customer Address
--             p_site_conversion_ncu   NCU Address Sites to be converted
--             p_convert_so_flag       Convert Sales Order?
--             p_so_conversion_ncu     NCU Sales Orders to be converted
--             p_convert_partial_ship_flag
--             p_update_db_flag        commit the changes
--
-- COMMENT   : Main Logic to Process the Sites Conversion
--
--=======================================================================
PROCEDURE Sites_Conversion
( p_customer_id                IN NUMBER
, p_customer_address_id        IN NUMBER
, p_convert_so_flag            IN VARCHAR2
, p_so_conversion_ncu          IN VARCHAR2
, p_convert_partial_so         IN VARCHAR2
, p_line_invoice_to_org_id     IN NUMBER
, p_so_reprice_flag            IN VARCHAR2
, p_default_euro_price_list_id IN  NUMBER
, p_update_existing_euro_pl    IN  VARCHAR2 := 'N'
);


--========================================================================
-- PROCEDURE : ALL_Customer_Conversion     PUBLIC
-- PARAMETERS:
--   p_default_euro_price_list_id  Id of the default Euro price list
--   p_update_existing_euro_pl     Yes/No to update existing price list
--   p_convert_so_flag             Yes/No to convert Sales Orders
--   p_so_conversion_ncu           NCU of the So to be converted
--                                 Default is ALL
--   p_convert_partial_so          Yes/No to convert partially shipped SO
--   p_so_reprice_flag             Yes/No to reprice all sales orders
--
-- COMMENT   : Main Logic to Process the ALL Customer Conversion
--
--=======================================================================
PROCEDURE ALL_Customer_Conversion
( p_default_euro_price_list_id    IN  NUMBER   DEFAULT NULL
, p_convert_so_flag               IN  VARCHAR2 := 'N'
, p_so_conversion_ncu             IN  VARCHAR2 := NULL
, p_convert_partial_so   	  IN  VARCHAR2 := 'N'
, p_update_existing_euro_pl       IN  VARCHAR2 := 'N'
, p_so_reprice_flag               IN VARCHAR2  := 'N'
);



END QP_MGD_EURO_CUSTOMER_MEDIATOR;


 

/
