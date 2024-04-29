--------------------------------------------------------
--  DDL for Package Body OE_OTA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OTA_UTIL" As
/* $Header: OEXUOTAB.pls 120.0 2005/06/01 01:01:32 appldev noship $ */

G_OTA_STATUS                  VARCHAR2(1) := FND_API.G_MISS_CHAR;

Function Get_Product_Status(p_application_id      NUMBER)
RETURN VARCHAR2 IS
   l_ret_val           BOOLEAN;
   l_status            VARCHAR2(1);
   l_industry          VARCHAR2(1);
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

   if (p_application_id = 810
		   AND G_OTA_STATUS = FND_API.G_MISS_CHAR)
     then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'GET OTA PROD. STATUS' ) ;
     END IF;

           -- Make a call to fnd_installation.get function to check for the
           -- installation status of the CRM products and return the status.

           l_ret_val := fnd_installation.get(p_application_id,p_application_id
                         ,l_status,l_industry);
           if p_application_id = 810   then
               G_OTA_STATUS := l_status;
           end if;

    end if;

    if p_application_id = 810 then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OTA RET PROD. STATUS :'||G_OTA_STATUS ) ;
     END IF;
     return (G_OTA_STATUS);
    end if;

END Get_Product_Status;

Procedure Notify_OTA
(   p_line_id                       IN  NUMBER
,   p_org_id                        IN  NUMBER
,   p_order_quantity_uom            IN  VARCHAR2
,   p_daemon_type                   IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

)
IS

l_return_status               VARCHAR2(1);
l_sql_stat                    VARCHAR2(3000);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING NOTIFY_OTA API' ) ;
  END IF;


    /* The application id for Order Capture is 697 */

    --IF Get_Product_Status(810) IN ('I','S') THEN

    -- lkxu, for bug 1701377
    IF OE_GLOBALS.G_OTA_INSTALLED IS NULL THEN
	 OE_GLOBALS.G_OTA_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(810);
    END IF;

    IF OE_GLOBALS.G_OTA_INSTALLED = 'Y' THEN

    -- Call the OTA API
    l_sql_stat := '
    Begin
    OTA_CANCEL_API.DELETE_CANCEL_LINE(
        :p_line_id
      , :p_org_id
      , :p_uom
      , :p_daemon_type
	 , :x_return_status);
	 END;';


    EXECUTE IMMEDIATE l_sql_stat
	 USING IN  p_line_id
      ,     IN  p_org_id
	 ,     IN  p_order_quantity_uom
	 ,     IN  p_daemon_type
, OUT  l_return_status;


    x_return_status := l_return_status;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'JPN: OTA RETURN STATUS IS: ' || L_RETURN_STATUS ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NOTIFY_OTA API - UNEXPECTED ERROR' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING NOTIFY_OTA API' ) ;
        END IF;
	   /* OE_DEBUG_PUB.ADD('Notify OC error msg is: ' || substr(x_msg_data, 1,200)); */
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NOTIFY_OTA API - ERROR' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING NOTIFY_OTA API' ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF; -- API exists

EXCEPTION


    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'NOTIFY_OTA'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Notify_OTA;


PROCEDURE Get_Enrollment_Status(p_line_id   IN NUMBER
,x_valid OUT NOCOPY VARCHAR2

,x_return_status OUT NOCOPY VARCHAR2)

IS
l_sql_stat       VARCHAR2(3000);
l_valid          VARCHAR2(1);
l_return_status  VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING GET OTA ENROLLMENT' , 1 ) ;
    END IF;
    -- IF Get_Product_Status(810) IN ('I','S') THEN

    -- lkxu, for bug 1701377
    IF OE_GLOBALS.G_OTA_INSTALLED IS NULL THEN
	 OE_GLOBALS.G_OTA_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(810);
    END IF;

    IF OE_GLOBALS.G_OTA_INSTALLED = 'Y' THEN

    -- Call the OTA Enrollment status checking API

    l_sql_stat := '
    Begin
    OTA_UTILITY.CHECK_ENROLLMENT(
				:p_line_id
				,:x_valid
				,:x_return_status
				);
				END;';

    EXECUTE IMMEDIATE l_sql_stat
	  USING IN p_line_id
, OUT l_valid

, OUT l_return_status;


    x_return_status := l_return_status;
    x_valid         := l_valid;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'GET_ENROLLMENT_STATUS API - UNEXPECTED ERROR' ) ;
	  END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'EXITING GET_ENROLLMENT_STATUS API' ) ;
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'GET_ENROLLMENT_STATUS API - ERROR' ) ;
	   END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING GET_ENROLLMENT_STATUS API' ) ;
        END IF;
	   RAISE FND_API.G_EXC_ERROR;

    END IF;

    END IF;



End Get_Enrollment_Status;


PROCEDURE Get_Event_Status(p_line_id   IN NUMBER
,x_valid OUT NOCOPY VARCHAR2

,x_return_status OUT NOCOPY VARCHAR2)

IS
l_sql_stat       VARCHAR2(3000);
l_valid          VARCHAR2(1);
l_return_status  VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING GET OTA ENROLLMENT' , 1 ) ;
    END IF;
    -- IF Get_Product_Status(810) IN ('I','S') THEN

    -- lkxu, for bug 1701377
    IF OE_GLOBALS.G_OTA_INSTALLED IS NULL THEN
	 OE_GLOBALS.G_OTA_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(810);
    END IF;

    IF OE_GLOBALS.G_OTA_INSTALLED = 'Y' THEN

    -- Call the OTA Event status checking API

    l_sql_stat := '
    Begin
    OTA_UTILITY.CHECK_EVENT(
				:p_line_id
				,:x_valid
				,:x_return_status
				);
				END;';

    EXECUTE IMMEDIATE l_sql_stat
	  USING IN p_line_id
, OUT l_valid

, OUT l_return_status;


    x_return_status := l_return_status;
    x_valid         := l_valid;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'GET_EVENT_STATUS API - UNEXPECTED ERROR' ) ;
	  END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'EXITING GET_EVENT_STATUS API' ) ;
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'GET_EVENT_STATUS API - ERROR' ) ;
	   END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING GET_EVENT_STATUS API' ) ;
        END IF;
	   RAISE FND_API.G_EXC_ERROR;

    END IF;

  END IF;


End Get_Event_Status;


PROCEDURE Get_OTA_Description
(p_line_id    IN    NUMBER
,p_uom        IN    VARCHAR2
,x_description OUT NOCOPY VARCHAR2

,x_course_end_date OUT NOCOPY DATE

,x_return_status OUT NOCOPY VARCHAR2

)
IS

l_sql_stat           VARCHAR2(3000);
l_description        VARCHAR2(2000);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING GET_OTA DESCRIPTION' , 1 ) ;
    END IF;
    -- IF Get_Product_Status(810) IN ('I','S') THEN

    -- lkxu, for bug 1701377
    IF OE_GLOBALS.G_OTA_INSTALLED IS NULL THEN
	 OE_GLOBALS.G_OTA_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(810);
    END IF;

    IF OE_GLOBALS.G_OTA_INSTALLED = 'Y' THEN

	-- Call the OTA API to get the item description to be interfaced
	-- with AR. The OTA API will also return the sourse end date that will
	-- need to be interfaced with AR as GL date.

	l_sql_stat := '
	Begin
	OTA_UTILITY.Get_Description(
			  :p_line_id
                ,:p_uom
			 ,:x_description
			 ,:x_course_end_date
			 ,:x_return_status
			 );
			 END;';
     EXECUTE IMMEDIATE l_sql_stat
		   USING  IN p_line_id
		   ,      IN p_uom
, OUT l_description

, OUT x_course_end_date

, OUT x_return_status;


     x_description := l_description;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING GET_OTA DESCRIPTION'|| L_DESCRIPTION , 1 ) ;
     END IF;
     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'GET_OTA_DESCRIPTION API - UNEXPECTED ERROR' ) ;
	    END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXITING GET_OTA_DESCRIPTION API' ) ;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'GET_OTA_DESCRIPTION API - ERROR' ) ;
	    END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXITING GET_OTA_DESCRIPTION API' ) ;
         END IF;
	    RAISE FND_API.G_EXC_ERROR;
     END IF;

   END IF;


End Get_OTA_Description;



PROCEDURE Check_OTA_Line( p_application_id IN NUMBER,
                           p_entity_short_name in VARCHAR2,
                           p_validation_entity_short_name in VARCHAR2,
                           p_validation_tmplt_short_name in VARCHAR2,
                           p_record_set_tmplt_short_name in VARCHAR2,
                           p_scope in VARCHAR2,
p_result OUT NOCOPY NUMBER ) is



l_line_id NUMBER := oe_line_security.g_record.line_id;
l_quantity_uom   VARCHAR2(3);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  select order_quantity_uom into l_quantity_uom
  from oe_order_lines_all where
  line_id = l_line_id;
  if l_quantity_uom IN ('ENR','EVT') then
    p_result := 1;
  else
    p_result := 0;
  end if;


EXCEPTION
    WHEN no_data_found then
      p_result := 0;

END Check_OTA_Line;

/* Function: Is_OTA_Line */

FUNCTION Is_OTA_Line
(p_order_quantity_uom   VARCHAR2 := FND_API.G_MISS_CHAR)
RETURN BOOLEAN
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING IS_OTA_LINE FUNCTION ' , 1 ) ;
    END IF;
    IF p_order_quantity_uom <> FND_API.G_MISS_CHAR THEN
	  -- check the uom value
	  IF p_order_quantity_uom IN ('ENR','EVT') THEN
		RETURN TRUE;
       ELSE
		RETURN FALSE;
       END IF;
    ELSE
	  RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING IS_OTA_LINE FUNCTION ' , 1 ) ;
    END IF;

EXCEPTION
   when others then
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXCEPTION IN IS_OTA_LINE FUNCTION ' , 1 ) ;
	END IF;
     RETURN FALSE;
END Is_OTA_Line;


/* csheu create new procedure Create_OTA_Enroll */

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

x_return_status OUT NOCOPY VARCHAR2)


IS

l_sql_stat           VARCHAR2(3000);
l_return_status      VARCHAR2(1);
l_enrollment_id      NUMBER;
l_enrollment_status  VARCHAR2(30);


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING CREATE_OTA_ENROLL' , 1 ) ;
    END IF;
    -- IF Get_Product_Status(810) IN ('I','S') THEN

    -- lkxu, for bug 1701377
    IF OE_GLOBALS.G_OTA_INSTALLED IS NULL THEN
	 OE_GLOBALS.G_OTA_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(810);
    END IF;

    IF OE_GLOBALS.G_OTA_INSTALLED = 'Y' THEN

	-- Call the OTA API to create enrollment

	l_sql_stat := '
	Begin
	OTA_OM_UPD_API.CREATE_ENROLL_FROM_OM(
			  :p_line_id
                ,:p_org_id
			 ,:p_sold_to_org_id
			 ,:p_ship_to_org_id
			 ,:p_sold_to_contact_id
			 ,:p_ship_to_contact_id
			 ,:p_event_id
			 ,:p_order_date
			 ,:x_enrollment_id
                ,:x_enrollment_status
                ,:x_return_status
			 );
			 END;';
     EXECUTE IMMEDIATE l_sql_stat
		   USING  IN p_line_id
		   ,      IN p_org_id
		   ,      IN p_sold_to_org_id
		   ,      IN p_ship_to_org_id
		   ,      IN p_sold_to_contact_id
		   ,      IN p_ship_to_contact_id
		   ,      IN p_event_id
		   ,      IN p_order_date
, OUT l_enrollment_id

, OUT l_enrollment_status

, OUT l_return_status;


     x_return_status := l_return_status;
	x_enrollment_id := l_enrollment_id;
	x_enrollment_status := l_enrollment_status;


     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING CREATE OTA ENROLL '|| L_RETURN_STATUS , 1 ) ;
     END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING CREATE OTA ENROLL '|| L_ENROLLMENT_STATUS , 1 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING CREATE OTA ENROLL '|| L_RETURN_STATUS , 1 ) ;
	END IF;

   END IF;
END Create_OTA_Enroll;


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
RETURN DATE
IS

l_sql_stat           VARCHAR2(3000);
l_activity_name	     VARCHAR2(2000);
l_event_title        VARCHAR2(2000);
l_course_start_date  DATE;
l_course_end_date    DATE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING GET_OTA_EVENT_END_DATE' , 1 ) ;
    END IF;

    IF OE_GLOBALS.G_OTA_INSTALLED IS NULL THEN
	 OE_GLOBALS.G_OTA_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(810);
    END IF;

    IF OE_GLOBALS.G_OTA_INSTALLED = 'Y' THEN

      l_sql_stat := '
	Begin
	  OTA_OM_UTIL.Get_Event_Detail(
	  		 :p_line_id
                	,:p_uom
			,:x_activity_name
			,:x_event_title
                        ,:x_course_start_date
			,:x_course_end_date);
        END;';

      EXECUTE IMMEDIATE l_sql_stat
		   USING  IN p_line_id
		   ,      IN p_uom
, OUT l_activity_name

, OUT l_event_title

, OUT l_course_start_date

, OUT l_course_end_date;


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING GET_OTA_EVENT_END_DATE WITH EVENT END DATE' , 1 ) ;
      END IF;
      RETURN l_course_end_date;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING GET_OTA_EVENT_END_DATE WITH NULL' , 1 ) ;
    END IF;
    RETURN NULL;


EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_OTA_Event_End_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


End Get_OTA_Event_End_Date;

END OE_OTA_UTIL;


/
