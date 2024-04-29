--------------------------------------------------------
--  DDL for Package OE_CAT_RESULTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CAT_RESULTS_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXCATRS.pls 120.0 2005/06/01 00:43:50 appldev noship $ */

PROCEDURE Check_Availability (
p_calling_module IN VARCHAR2,
p_inventory_item_id IN NUMBER,
p_organization_id IN NUMBER,
p_customer_id IN NUMBER,
p_customer_site_id IN NUMBER,
p_uom IN VARCHAR2,
p_pricelist_id IN VARCHAR2,
p_input_quantity IN NUMBER ,
p_need_by_date IN VARCHAR2,
p_vendor_item_number IN VARCHAR2,
p_currency_code IN VARCHAR2,
x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_pocall_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_available_qty OUT NOCOPY /* file.sql.39 change */ NUMBER,
x_available_date OUT NOCOPY /* file.sql.39 change */ DATE,
x_customer_price OUT NOCOPY /* file.sql.39 change */ NUMBER,
x_list_price OUT NOCOPY /* file.sql.39 change */ NUMBER,
x_pricing_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


PROCEDURE Get_Availability (
p_inventory_item_id IN NUMBER ,
p_input_quantity IN NUMBER,
p_organization_id IN NUMBER,
p_customer_id IN NUMBER,
p_customer_site_id IN NUMBER,
p_uom IN VARCHAR2,
p_need_by_date IN VARCHAR2
);

END OE_CAT_RESULTS_PUB ;

 

/
