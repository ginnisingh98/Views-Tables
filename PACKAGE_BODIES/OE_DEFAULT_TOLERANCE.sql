--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_TOLERANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_TOLERANCE" AS
/* $Header: OEXDCISB.pls 120.0 2005/06/01 00:36:45 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OE_Default_Tolerance';

--  Start of Comments
--  API name    OE_Default_Tolerance
--  Type        Public
--  Version     Current version = 1.0
--              Initial version = 1.0

FUNCTION Under_Ship_Tol_From_Item
(
	p_database_object_name	IN	VARCHAR2
	,p_attribute_code		IN	VARCHAR2
)
RETURN VARCHAR2
IS
	l_inventory_item_id	NUMBER;
	l_under_shipment_tolerance	NUMBER;
	l_under_return_tolerance	NUMBER;
BEGIN
	l_inventory_item_id := ONT_Line_Def_Hdlr.g_record.inventory_item_id;
	select under_shipment_tolerance, under_return_tolerance into l_under_shipment_tolerance, l_under_return_tolerance
	from oe_cust_item_settings
	where internal_item_id = l_inventory_item_id
		and customer_id is null
		and site_use_id is null;
	if p_database_object_name = 'SHIP' then
		return to_char(l_under_shipment_tolerance);
	elsif p_database_object_name = 'RETURN' then
		return to_char(l_under_return_tolerance);
	else
		return null;
	end if;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

		return null;

    WHEN FND_API.G_EXC_ERROR THEN

		RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Under_Ship_Tol_From_Item ;

FUNCTION Under_Ship_Tol_From_Customer
(
	p_database_object_name	IN	VARCHAR2
	,p_attribute_code		IN	VARCHAR2
)
RETURN VARCHAR2
IS
	l_customer_id				NUMBER;
	l_under_shipment_tolerance	NUMBER;
	l_under_return_tolerance	NUMBER;
BEGIN
	l_customer_id := ONT_Line_Def_Hdlr.g_record.sold_to_org_id;
	select under_shipment_tolerance, under_return_tolerance into l_under_shipment_tolerance, l_under_return_tolerance
	from oe_cust_item_settings
	where customer_id = l_customer_id
		and internal_item_id is null
		and site_use_id is null;
	if p_database_object_name = 'SHIP' then
		return to_char(l_under_shipment_tolerance);
	elsif p_database_object_name = 'RETURN' then
		return to_char(l_under_return_tolerance);
	else
		return null;
	end if;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

		return null;

    WHEN FND_API.G_EXC_ERROR THEN

		RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Under_Ship_Tol_From_Customer ;

FUNCTION Under_Ship_Tol_From_Site
(
	p_database_object_name	IN	VARCHAR2
	,p_attribute_code		IN	VARCHAR2
)
RETURN VARCHAR2
IS
	l_site_use_id				NUMBER;
	l_under_shipment_tolerance	NUMBER;
	l_under_return_tolerance	NUMBER;
BEGIN
	if p_attribute_code = 'BILL_TO' then
		l_site_use_id := ONT_Line_Def_Hdlr.g_record.invoice_to_org_id;
	elsif	p_attribute_code = 'SHIP_TO' then
		l_site_use_id := ONT_Line_Def_Hdlr.g_record.ship_to_org_id;
	else
		return null;
	end if;

	select under_shipment_tolerance, under_return_tolerance into l_under_shipment_tolerance, l_under_return_tolerance
	from oe_cust_item_settings
	where site_use_id = l_site_use_id
		and customer_id is null
		and internal_item_id is null;
	if p_database_object_name = 'SHIP' then
		return to_char(l_under_shipment_tolerance);
	elsif p_database_object_name = 'RETURN' then
		return to_char(l_under_return_tolerance);
	else
		return null;
	end if;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

		return null;

    WHEN FND_API.G_EXC_ERROR THEN

		RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Under_Ship_Tol_From_Site;

FUNCTION Under_Ship_Tol_From_Cust_Item
(
	p_database_object_name	IN	VARCHAR2
	,p_attribute_code		IN	VARCHAR2
)
RETURN VARCHAR2
IS
	l_customer_id	NUMBER;
	l_internal_item_id	NUMBER;
	l_under_shipment_tolerance	NUMBER;
	l_under_return_tolerance	NUMBER;
BEGIN
	l_internal_item_id := ONT_Line_Def_Hdlr.g_record.inventory_item_id;
	l_customer_id := ONT_Line_Def_Hdlr.g_record.sold_to_org_id;
	select under_shipment_tolerance, under_return_tolerance into l_under_shipment_tolerance, l_under_return_tolerance
	from oe_cust_item_settings
	where internal_item_id = l_internal_item_id
		and customer_id = l_customer_id
		and site_use_id is null;
	if p_database_object_name = 'SHIP' then
		return to_char(l_under_shipment_tolerance);
	elsif p_database_object_name = 'RETURN' then
		return to_char(l_under_return_tolerance);
	else
		return null;
	end if;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

		return null;

    WHEN FND_API.G_EXC_ERROR THEN

		RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Under_Ship_Tol_From_Cust_Item ;

FUNCTION Under_Ship_Tol_From_Site_Item
(
	p_database_object_name	IN	VARCHAR2
	,p_attribute_code		IN	VARCHAR2
)
RETURN VARCHAR2
IS
	l_site_use_id	NUMBER;
	l_internal_item_id	NUMBER;
	l_under_shipment_tolerance	NUMBER;
	l_under_return_tolerance	NUMBER;
BEGIN
	l_internal_item_id := ONT_Line_Def_Hdlr.g_record.inventory_item_id;
	if p_attribute_code = 'BILL_TO' then
		l_site_use_id := ONT_Line_Def_Hdlr.g_record.invoice_to_org_id;
	elsif	p_attribute_code = 'SHIP_TO' then
		l_site_use_id := ONT_Line_Def_Hdlr.g_record.ship_to_org_id;
	else
		return null;
	end if;
	select under_shipment_tolerance, under_return_tolerance into l_under_shipment_tolerance, l_under_return_tolerance
	from oe_cust_item_settings
	where internal_item_id = l_internal_item_id
		and site_use_id = l_site_use_id;
	if p_database_object_name = 'SHIP' then
		return to_char(l_under_shipment_tolerance);
	elsif p_database_object_name = 'RETURN' then
		return to_char(l_under_return_tolerance);
	else
		return null;
	end if;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

		return null;

    WHEN FND_API.G_EXC_ERROR THEN

		RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Under_Ship_Tol_From_Site_Item ;

FUNCTION Over_Ship_Tol_From_Item
(
	p_database_object_name	IN	VARCHAR2
	,p_attribute_code		IN	VARCHAR2
)
RETURN VARCHAR2
IS
	l_inventory_item_id	NUMBER;
	l_Over_shipment_tolerance	NUMBER;
	l_Over_return_tolerance	NUMBER;
BEGIN
	l_inventory_item_id := ONT_Line_Def_Hdlr.g_record.inventory_item_id;
	select Over_shipment_tolerance, Over_return_tolerance into l_Over_shipment_tolerance, l_Over_return_tolerance
	from oe_cust_item_settings
	where internal_item_id = l_inventory_item_id
		and customer_id is null
		and site_use_id is null;
	if p_database_object_name = 'SHIP' then
		return to_char(l_Over_shipment_tolerance);
	elsif p_database_object_name = 'RETURN' then
		return to_char(l_Over_return_tolerance);
	else
		return null;
	end if;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

		return null;

    WHEN FND_API.G_EXC_ERROR THEN

		RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Over_Ship_Tol_From_Item ;

FUNCTION Over_Ship_Tol_From_Customer
(
	p_database_object_name	IN	VARCHAR2
	,p_attribute_code		IN	VARCHAR2
)
RETURN VARCHAR2
IS
	l_customer_id				NUMBER;
	l_Over_shipment_tolerance	NUMBER;
	l_Over_return_tolerance	NUMBER;
BEGIN
	l_customer_id := ONT_Line_Def_Hdlr.g_record.sold_to_org_id;
	select Over_shipment_tolerance, Over_return_tolerance into l_Over_shipment_tolerance, l_Over_return_tolerance
	from oe_cust_item_settings
	where customer_id = l_customer_id
		and internal_item_id is null
		and site_use_id is null;
	if p_database_object_name = 'SHIP' then
		return to_char(l_Over_shipment_tolerance);
	elsif p_database_object_name = 'RETURN' then
		return to_char(l_Over_return_tolerance);
	else
		return null;
	end if;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

		return null;

    WHEN FND_API.G_EXC_ERROR THEN

		RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Over_Ship_Tol_From_Customer ;

FUNCTION Over_Ship_Tol_From_Site
(
	p_database_object_name	IN	VARCHAR2
	,p_attribute_code		IN	VARCHAR2
)
RETURN VARCHAR2
IS
	l_site_use_id				NUMBER;
	l_Over_shipment_tolerance	NUMBER;
	l_Over_return_tolerance	NUMBER;
BEGIN
	if p_attribute_code = 'BILL_TO' then
		l_site_use_id := ONT_Line_Def_Hdlr.g_record.invoice_to_org_id;
	elsif	p_attribute_code = 'SHIP_TO' then
		l_site_use_id := ONT_Line_Def_Hdlr.g_record.ship_to_org_id;
	else
		return null;
	end if;

	select Over_shipment_tolerance, Over_return_tolerance into l_Over_shipment_tolerance, l_Over_return_tolerance
	from oe_cust_item_settings
	where site_use_id = l_site_use_id
		and customer_id is null
		and internal_item_id is null;
	if p_database_object_name = 'SHIP' then
		return to_char(l_Over_shipment_tolerance);
	elsif p_database_object_name = 'RETURN' then
		return to_char(l_Over_return_tolerance);
	else
		return null;
	end if;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

		return null;

    WHEN FND_API.G_EXC_ERROR THEN

		RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Over_Ship_Tol_From_Site;

FUNCTION Over_Ship_Tol_From_Cust_Item
(
	p_database_object_name	IN	VARCHAR2
	,p_attribute_code		IN	VARCHAR2
)
RETURN VARCHAR2
IS
	l_customer_id	NUMBER;
	l_internal_item_id	NUMBER;
	l_Over_shipment_tolerance	NUMBER;
	l_Over_return_tolerance	NUMBER;
BEGIN
	l_internal_item_id := ONT_Line_Def_Hdlr.g_record.inventory_item_id;
	l_customer_id := ONT_Line_Def_Hdlr.g_record.sold_to_org_id;
	select Over_shipment_tolerance, Over_return_tolerance into l_Over_shipment_tolerance, l_Over_return_tolerance
	from oe_cust_item_settings
	where internal_item_id = l_internal_item_id
		and customer_id = l_customer_id
		and site_use_id is null;
	if p_database_object_name = 'SHIP' then
		return to_char(l_Over_shipment_tolerance);
	elsif p_database_object_name = 'RETURN' then
		return to_char(l_Over_return_tolerance);
	else
		return null;
	end if;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

		return null;

    WHEN FND_API.G_EXC_ERROR THEN

		RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Over_Ship_Tol_From_Cust_Item ;

FUNCTION Over_Ship_Tol_From_Site_Item
(
	p_database_object_name	IN	VARCHAR2
	,p_attribute_code		IN	VARCHAR2
)
RETURN VARCHAR2
IS
	l_site_use_id	NUMBER;
	l_internal_item_id	NUMBER;
	l_Over_shipment_tolerance	NUMBER;
	l_Over_return_tolerance	NUMBER;
BEGIN
	l_internal_item_id := ONT_Line_Def_Hdlr.g_record.inventory_item_id;
	if p_attribute_code = 'BILL_TO' then
		l_site_use_id := ONT_Line_Def_Hdlr.g_record.invoice_to_org_id;
	elsif	p_attribute_code = 'SHIP_TO' then
		l_site_use_id := ONT_Line_Def_Hdlr.g_record.ship_to_org_id;
	else
		return null;
	end if;
	select Over_shipment_tolerance, Over_return_tolerance into l_Over_shipment_tolerance, l_Over_return_tolerance
	from oe_cust_item_settings
	where internal_item_id = l_internal_item_id
		and site_use_id = l_site_use_id;
	if p_database_object_name = 'SHIP' then
		return to_char(l_Over_shipment_tolerance);
	elsif p_database_object_name = 'RETURN' then
		return to_char(l_Over_return_tolerance);
	else
		return null;
	end if;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

		return null;

    WHEN FND_API.G_EXC_ERROR THEN

		RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Over_Ship_Tol_From_Site_Item ;

END OE_Default_Tolerance;

/
