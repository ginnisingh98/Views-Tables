--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_SCH_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_SCH_LINE" AS
/* $Header: OEXLSCHB.pls 120.1 2006/03/29 16:45:00 spooruli noship $ */

G_PKG_NAME             CONSTANT     VARCHAR2(30):='OE_VALIDATE_SCH_LINE';

/*---------------------------------------------------------------------
Procedure Name : Validate_Line
Description    : Validates a line before transferring the reservations.
                 Lines are not allowed to hold the reservations before
                 not allowed to hold the reservations
--------------------------------------------------------------------- */
FUNCTION Validate_Line(p_line_id IN NUMBER)
RETURN BOOLEAN
IS

 l_schedule_status        VARCHAR2(30);
 l_scheduling_level_code  VARCHAR2(30);
 l_header_id              NUMBER;
 l_line_type_id            NUMBER;
BEGIN

  oe_debug_pub.add('Entering OE_VALIDATE_SCH_LINE.validate ' || p_line_id,1);
  Select schedule_status_code,
         header_id,
         line_type_id
  Into   l_schedule_status,
         l_header_id,
         l_line_type_id
  From   oe_order_lines_all
  Where  line_id = p_line_id;


  IF l_schedule_status is Null THEN

     Return FALSE;
  END IF;

  oe_debug_pub.add('Exiting the call with success',1);
  RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'OE_VALIDATE_SCH_LINE.validate'
            );
        END IF;
        RETURN FALSE;

END Validate_Line;
END OE_VALIDATE_SCH_LINE;

/
