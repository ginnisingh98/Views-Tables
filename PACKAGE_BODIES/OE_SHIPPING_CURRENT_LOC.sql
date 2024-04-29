--------------------------------------------------------
--  DDL for Package Body OE_SHIPPING_CURRENT_LOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SHIPPING_CURRENT_LOC" AS
/* $Header: OEXOMWSB.pls 120.0 2005/05/31 23:04:12 appldev noship $ */


FUNCTION get_current_location(
 p_delivery_name	IN	VARCHAR2 DEFAULT NULL,
 p_tracking_number_dd	IN	VARCHAR2 DEFAULT NULL,
 p_mode			IN	VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2 IS

my_tab WSH_SHIPPING_INFO.Tracking_Info_tab_typ;
x_location_name VARCHAR2(50);
l_return VARCHAR2(50);
begin

--WSH_shipping_info.Track_shipment('16103',null,'CURRENT',my_tab,l_return);
WSH_shipping_info.Track_shipment(p_delivery_name,p_tracking_number_dd,p_mode,my_tab,l_return);

for i in 1..my_tab.COUNT loop

x_location_name 	:= my_tab(i).location_name;

end loop;

return x_location_name;

end;

END OE_SHIPPING_CURRENT_LOC;

/
