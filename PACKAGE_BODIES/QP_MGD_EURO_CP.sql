--------------------------------------------------------
--  DDL for Package Body QP_MGD_EURO_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MGD_EURO_CP" AS
/* $Header: QPXCEURB.pls 120.1 2005/06/15 00:02:31 appldev  $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    QPXCEURB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Body of concurrent program package QP_MGD_EURO_CP                 |
--|                                                                       |
--| HISTORY                                                               |
--|    01-May-2000  rajkrish   Created                                    |
--|    17-Aug-2000  rajkrish   Updated                                    |
--|    04-May-2001  tsimmond   Added new procedure Run_All_Customer_      |
--|                            Conversion                                 |
--|    05-Sep-2001  rajkrish   TCA Model                                  |
--|    03-APR-2002  tsimmond   removed code                               |
--+======================================================================--

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'QP_MGD_EURO_CP';


--========================================================================
-- PROCEDURE : Run_Euro_Customer_Conversion       PUBLIC
-- PARAMETERS:
--   x_retcode                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--   x_errbuf                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--   p_customer_id              Customer being converted
--   p_customer_address_id      Customer Site Address
--   p_convert_so_flag          Flag to indicate of SO needs to be converted
--   p_line_invoice_to_org_id   Bill to site of the Order Lines
--   p_so_conversion_ncu        NCU of the So to be converted
--                              Default is ALL
--   p_convert_partial_so       Indicate to convert partially transacted SO
--   p_so_reprice_flag          Reprice flag for the new Euro Order
--                              NULL will take the original value
--
-- COMMENT   : This is the concurrent program for EURO conversion of
--             customer and customer sites,
--             Including the Sales Orders.
--
--========================================================================
PROCEDURE Run_Euro_Customer_Conversion
( x_retcode                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_errbuf                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, p_customer_id              IN NUMBER
, p_customer_address_id      IN NUMBER
, p_convert_so_flag          IN VARCHAR2
, p_line_invoice_to_org_id   IN NUMBER
, p_so_conversion_ncu        IN VARCHAR2
, p_convert_partial_so       IN VARCHAR2
, p_so_reprice_flag          IN VARCHAR2
)
IS
BEGIN

  x_retcode:='0';
  x_errbuf :=' ';

  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END Run_Euro_Customer_Conversion;


--========================================================================
-- PROCEDURE : Run_All_Customer_Conversion       PUBLIC
-- PARAMETERS:
--   x_retcode                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--   x_errbuf                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--   p_default_euro_price_list_id  Id of the default Euro price list
--   p_update_existing_euro_pl     Yes/No to update existing price list
--   p_convert_so_flag             Yes/No to convert Sales Orders
--   p_so_conversion_ncu           NCU of the So to be converted
--                                 Default is ALL
--   p_convert_partial_so          Yes/No  to convert partially shipped SO
--   p_so_reprice_flag             Yes/No to reprice all sales orders
--
-- COMMENT   : This is the concurrent program for EURO conversion of
--             all customers and customer sites, including the Sales Orders
--             in one operation.
--
--========================================================================
PROCEDURE Run_All_Customer_Conversion
( x_retcode                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_errbuf                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, p_default_euro_price_list_id  IN NUMBER
, p_update_existing_euro_pl     IN VARCHAR2
, p_convert_so_flag             IN VARCHAR2
, p_so_conversion_ncu           IN VARCHAR2
, p_convert_partial_so          IN VARCHAR2
, p_so_reprice_flag             IN VARCHAR2
)
IS
BEGIN

  x_retcode:='0';
  x_errbuf :=' ';

  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END Run_All_Customer_Conversion;


END QP_MGD_EURO_CP;


/
