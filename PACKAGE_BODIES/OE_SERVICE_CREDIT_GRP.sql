--------------------------------------------------------
--  DDL for Package Body OE_SERVICE_CREDIT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SERVICE_CREDIT_GRP" As
/* $Header: OEXGSVCB.pls 120.0 2005/06/01 00:23:40 appldev noship $ */


PROCEDURE Get_Service_Credit_Eligible(
	p_line_id in number,
	p_service_credit_eligible out NOCOPY /* file.sql.39 change */ varchar2)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Entering OE_SERVICE_CREDIT_PVT.GET_SERVICE_CREDIT_ELIGIBLE');
  END IF;

  if p_line_id is null then

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('line id is null');
    END IF;

   raise FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  SELECT Service_Credit_Eligible_Code
  INTO p_service_credit_eligible
  FROM OE_ORDER_LINES_ALL
  WHERE line_id = p_line_id;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('service_credit_eligible_code is: '|| p_service_credit_eligible);
    oe_debug_pub.add('Exiting OE_SERVICE_CREDIT_PVT.GET_SERVICE_CREDIT_ELIGIBLE');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF 	OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	OE_MSG_PUB.Add_Exc_Msg
	(   G_PKG_NAME
	,   'Get_Service_Credit_Eligible'
	);
    END IF;

    oe_debug_pub.add('Unexpected Error');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Service_Credit_Eligible;

END OE_SERVICE_CREDIT_GRP;

/
