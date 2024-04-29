--------------------------------------------------------
--  DDL for Package Body OE_ORDER_MISC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_MISC_PUB" AS
/* $Header: OEXPMISB.pls 115.4 2004/03/29 23:13:25 sdatti ship $ */


FUNCTION GET_CONCAT_LINE_NUMBER
			(p_Line_Id  IN NUMBER)
RETURN VARCHAR2

IS
p_Line_Number NUMBER;
p_Shipment_Number NUMBER;
p_Option_Number NUMBER;
p_component_Number NUMBER;
p_service_Number NUMBER;
x_concat_value VARCHAR2(30);
p_concat_value VARCHAR2(30);
BEGIN
  IF p_line_id IS NULL
  THEN
	RETURN NULL;
  END IF;
  SELECT Line_Number,
	 Shipment_Number,
	 Option_Number,
	 Component_Number,
	 Service_Number
  INTO  p_Line_Number,
	p_Shipment_Number,
	p_Option_Number,
	p_Component_Number,
	p_Service_Number
  FROM oe_order_lines_all
  WHERE line_id=p_line_id;

    IF p_service_number is not null then
         IF p_option_number is not null then
           IF p_component_number is not null then
             p_concat_value := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number||'.'||p_component_number||'.'||
                                           p_service_number;
        ELSE
             p_concat_value := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number||'..'||p_service_number;
        END IF;

      --- if a option is not attached
      ELSE
           IF p_component_number is not null then
             p_concat_value := p_line_number||'.'||p_shipment_number||'..'||
                                           p_component_number||'.'||p_service_number;
        ELSE
             p_concat_value := p_line_number||'.'||p_shipment_number||
                                           '...'||p_service_number;
        END IF;

         END IF; /* if p_option_number number is not null */

    -- if the service number is null
    ELSE
         IF p_option_number is not null then
           IF p_component_number is not null then
             p_concat_value := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number||'.'||p_component_number;
        ELSE
             p_concat_value := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number;
        END IF;

      --- if a option is not attached
      ELSE
           IF p_component_number is not null then
             p_concat_value := p_line_number||'.'||p_shipment_number||'..'||
                                           p_component_number;
        ELSE
             /*Bug2848734 - Added IF condition */
             IF (p_line_number is NULL and p_shipment_number is NULL ) THEN
                p_concat_value := NULL;
             ELSE
                p_concat_value := p_line_number||'.'||p_shipment_number;
             END IF;
        END IF;

         END IF; /* if p_option_number number is not null */

    END IF; /* if service number is not null */
  x_concat_value :=p_concat_value;
  RETURN x_concat_value;

  EXCEPTION
   WHEN too_many_rows THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   WHEN no_data_found THEN
       RETURN NULL;

   WHEN others THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_CONCAT_LINE_NUMBER;

FUNCTION GET_CONCAT_HIST_LINE_NUMBER
			(p_Line_Id         IN NUMBER,
			 p_Version_Number  IN NUMBER)
RETURN VARCHAR2

IS
p_Line_Number NUMBER;
p_Shipment_Number NUMBER;
p_Option_Number NUMBER;
p_component_Number NUMBER;
p_service_Number NUMBER;
x_concat_value VARCHAR2(30);
p_concat_value VARCHAR2(30);
BEGIN
  IF p_line_id IS NULL
  THEN
	RETURN NULL;
  END IF;
  SELECT Line_Number,
	 Shipment_Number,
	 Option_Number,
	 Component_Number,
	 Service_Number
  INTO  p_Line_Number,
	p_Shipment_Number,
	p_Option_Number,
	p_Component_Number,
	p_Service_Number
  FROM OE_ORDER_LINES_HISTORY
  WHERE line_id=p_line_id
  AND version_number=p_version_number;

    IF p_service_number is not null then
         IF p_option_number is not null then
           IF p_component_number is not null then
             p_concat_value := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number||'.'||p_component_number||'.'||
                                           p_service_number;
        ELSE
             p_concat_value := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number||'..'||p_service_number;
        END IF;

      --- if a option is not attached
      ELSE
           IF p_component_number is not null then
             p_concat_value := p_line_number||'.'||p_shipment_number||'..'||
                                           p_component_number||'.'||p_service_number;
        ELSE
             p_concat_value := p_line_number||'.'||p_shipment_number||
                                           '...'||p_service_number;
        END IF;

         END IF; /* if p_option_number number is not null */

    -- if the service number is null
    ELSE
         IF p_option_number is not null then
           IF p_component_number is not null then
             p_concat_value := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number||'.'||p_component_number;
        ELSE
             p_concat_value := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number;
        END IF;

      --- if a option is not attached
      ELSE
           IF p_component_number is not null then
             p_concat_value := p_line_number||'.'||p_shipment_number||'..'||
                                           p_component_number;
        ELSE
             /*Bug2848734 - Added IF condition */
             IF (p_line_number is NULL and p_shipment_number is NULL ) THEN
                p_concat_value := NULL;
             ELSE
                p_concat_value := p_line_number||'.'||p_shipment_number;
             END IF;
        END IF;

         END IF; /* if p_option_number number is not null */

    END IF; /* if service number is not null */
  x_concat_value :=p_concat_value;
  RETURN x_concat_value;

  EXCEPTION
   WHEN too_many_rows THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   WHEN no_data_found THEN
       RETURN NULL;

   WHEN others THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_CONCAT_HIST_LINE_NUMBER;

FUNCTION GET_CONCAT_HIST_LINE_NUMBER
			(p_Line_Id         IN NUMBER)
RETURN VARCHAR2

IS
p_Line_Number NUMBER;
p_Shipment_Number NUMBER;
p_Option_Number NUMBER;
p_component_Number NUMBER;
p_service_Number NUMBER;
x_concat_value VARCHAR2(30);
p_concat_value VARCHAR2(30);
BEGIN
  IF p_line_id IS NULL
  THEN
	RETURN NULL;
  END IF;
  SELECT distinct Line_Number,
	 Shipment_Number,
	 Option_Number,
	 Component_Number,
	 Service_Number
  INTO  p_Line_Number,
	p_Shipment_Number,
	p_Option_Number,
	p_Component_Number,
	p_Service_Number
  FROM OE_ORDER_LINES_HISTORY
  WHERE line_id=p_line_id;

    IF p_service_number is not null then
         IF p_option_number is not null then
           IF p_component_number is not null then
             p_concat_value := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number||'.'||p_component_number||'.'||
                                           p_service_number;
        ELSE
             p_concat_value := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number||'..'||p_service_number;
        END IF;

      --- if a option is not attached
      ELSE
           IF p_component_number is not null then
             p_concat_value := p_line_number||'.'||p_shipment_number||'..'||
                                           p_component_number||'.'||p_service_number;
        ELSE
             p_concat_value := p_line_number||'.'||p_shipment_number||
                                           '...'||p_service_number;
        END IF;

         END IF; /* if p_option_number number is not null */

    -- if the service number is null
    ELSE
         IF p_option_number is not null then
           IF p_component_number is not null then
             p_concat_value := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number||'.'||p_component_number;
        ELSE
             p_concat_value := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number;
        END IF;

      --- if a option is not attached
      ELSE
           IF p_component_number is not null then
             p_concat_value := p_line_number||'.'||p_shipment_number||'..'||
                                           p_component_number;
        ELSE
             /*Bug2848734 - Added IF condition */
             IF (p_line_number is NULL and p_shipment_number is NULL ) THEN
                p_concat_value := NULL;
             ELSE
                p_concat_value := p_line_number||'.'||p_shipment_number;
             END IF;
        END IF;

         END IF; /* if p_option_number number is not null */

    END IF; /* if service number is not null */
  x_concat_value :=p_concat_value;
  RETURN x_concat_value;

  EXCEPTION
   WHEN too_many_rows THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   WHEN no_data_found THEN
       RETURN NULL;

   WHEN others THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_CONCAT_HIST_LINE_NUMBER;
END OE_ORDER_MISC_PUB;

/
