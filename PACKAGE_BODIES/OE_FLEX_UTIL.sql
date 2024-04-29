--------------------------------------------------------
--  DDL for Package Body OE_FLEX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_FLEX_UTIL" AS
/* $Header: OEXUFLXB.pls 120.0 2005/05/31 23:18:46 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Order_PUB';

FUNCTION Get_Concat_Value(
 Line_Number      IN NUMBER,
 Shipment_Number  IN NUMBER,
 Option_Number    IN NUMBER,
 Component_Number IN NUMBER DEFAULT NULL,
 Service_Number   IN NUMBER DEFAULT NULL
 )RETURN VARCHAR2
IS
p_concat_value   VARCHAR2(240);
BEGIN

    --=========================================
    -- Added for identifying Service Lines
    --=========================================
    IF service_number is not null then
	 IF option_number is not null then
	   IF component_number is not null then
	     p_concat_value := line_number||'.'||shipment_number||'.'||
					   option_number||'.'||component_number||'.'||
					   service_number;
        ELSE
	     p_concat_value := line_number||'.'||shipment_number||'.'||
					   option_number||'..'||service_number;
        END IF;

      --- if a option is not attached
      ELSE
	   IF component_number is not null then
	     p_concat_value := line_number||'.'||shipment_number||'..'||
					   component_number||'.'||service_number;
        ELSE
	     p_concat_value := line_number||'.'||shipment_number||
					   '...'||service_number;
        END IF;

	 END IF; /* if option number is not null */

    -- if the service number is null
    ELSE
	 IF option_number is not null then
	   IF component_number is not null then
	     p_concat_value := line_number||'.'||shipment_number||'.'||
					   option_number||'.'||component_number;
        ELSE
	     p_concat_value := line_number||'.'||shipment_number||'.'||
					   option_number;
        END IF;

      --- if a option is not attached
      ELSE
	   IF component_number is not null then
	     p_concat_value := line_number||'.'||shipment_number||'..'||
					   component_number;
        ELSE
	     p_concat_value := line_number||'.'||shipment_number;
        END IF;

	 END IF; /* if option number is not null */

    END IF; /* if service number is not null */
    RETURN p_concat_value;

END Get_Concat_Value;


END OE_Flex_UTIL;

/
