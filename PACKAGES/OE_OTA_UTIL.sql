--------------------------------------------------------
--  DDL for Package OE_OTA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OTA_UTIL" AUTHID CURRENT_USER As
/* $Header: OEXUOTAS.pls 120.0 2005/06/01 01:01:56 appldev noship $ */

G_PKG_NAME                   CONSTANT VARCHAR2(30) := 'OE_OTA_UTIL';


--  Procedure : Notify_OTA
--

PROCEDURE Notify_OTA
(   p_line_id                       IN  NUMBER
,   p_org_id                        IN  NUMBER
,   p_order_quantity_uom            IN  VARCHAR2
,   p_daemon_type                   IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Get_Enrollment_Status
( p_line_id            IN   NUMBER
, x_valid OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Get_Event_Status
( p_line_id            IN   NUMBER
, x_valid OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Get_OTA_Description
( p_line_id        IN  NUMBER
, p_uom            IN  VARCHAR2
, x_description OUT NOCOPY VARCHAR2

, x_course_end_date OUT NOCOPY DATE

, x_return_status OUT NOCOPY VARCHAR2

);


PROCEDURE Check_OTA_Line( p_application_id IN NUMBER,
					  p_entity_short_name in VARCHAR2,
					  p_validation_entity_short_name in VARCHAR2,
					  p_validation_tmplt_short_name in VARCHAR2,
                           p_record_set_tmplt_short_name in VARCHAR2,
                           p_scope in VARCHAR2,
p_result OUT NOCOPY NUMBER );


FUNCTION Is_OTA_Line
(p_order_quantity_uom   VARCHAR2 := FND_API.G_MISS_CHAR)
RETURN BOOLEAN;

/*csheu added procedure Create_OTA_Enroll */

PROCEDURE Create_OTA_Enroll(p_line_id IN NUMBER,
					   p_org_id  IN NUMBER,
					   p_sold_to_org_id IN NUMBER,
					   p_ship_to_org_id IN NUMBER,
					   p_sold_to_contact_id IN NUMBER,
					   p_ship_to_contact_id IN NUMBER,
					   p_event_id IN NUMBER,
					   p_order_date IN DATE,
x_enrollment_id OUT NOCOPY NUMBER,

x_enrollment_status OUT NOCOPY VARCHAR2,

x_return_status OUT NOCOPY VARCHAR2);



-----------------------------------------
-- Function name: Get_OTA_Event_End_Date
-- Abstract: Given a line_id and UOM, return the event
--           information associated with the order line.
--           This API is called during cross item validation
--           for commitment.
------------------------------------------
Function Get_OTA_Event_End_Date
(p_line_id      	IN  NUMBER,
 p_UOM             	IN  VARCHAR2)
RETURN DATE;

END OE_OTA_UTIL;


 

/
