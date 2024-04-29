--------------------------------------------------------
--  DDL for Package OE_CATALOG_PRICING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CATALOG_PRICING_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPRCAS.pls 120.0 2005/06/01 23:14:53 appldev noship $ */

PROCEDURE Get_Pricing
(p_item_number IN NUMBER,
 p_ordered_quantity IN NUMBER,
 p_uom IN VARCHAR2,
 p_price_list_id IN NUMBER,
 p_sold_to_org_id IN NUMBER,
 p_currency IN VARCHAR2,
 p_ordered_date IN VARCHAR2,
 status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 x_customer_price OUT NOCOPY /* file.sql.39 change */ NUMBER,
 x_list_price OUT NOCOPY /* file.sql.39 change */ NUMBER);

END OE_CATALOG_PRICING_PUB ;

 

/
