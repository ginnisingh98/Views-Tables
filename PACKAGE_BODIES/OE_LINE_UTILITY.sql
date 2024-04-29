--------------------------------------------------------
--  DDL for Package Body OE_LINE_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_UTILITY" as
/* $Header: OEXLUTSB.pls 115.1 99/07/16 08:13:23 porting shi $ */

procedure GET_LINE_TRIPLET(
   P_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID              IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID           IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                         IN NUMBER DEFAULT NULL
,  P_BASE_LINE_NUMBER			 OUT NUMBER
,  P_SHIPMENT_SCHEDULE_NUMBER		 OUT NUMBER
,  P_OPTION_LINE_NUMBER			 OUT NUMBER
				)
IS
BEGIN
  P_BASE_LINE_NUMBER := OE_QUERY.BASE_LINE_NUMBER (P_PARENT_LINE_ID, P_SERVICE_PARENT_LINE_ID,
				P_SHIPMENT_SCHEDULE_LINE_ID, P_LINE_NUMBER);
  P_SHIPMENT_SCHEDULE_NUMBER := OE_QUERY.SHIPMENT_SCHEDULE_NUMBER (P_PARENT_LINE_ID,
				P_SERVICE_PARENT_LINE_ID, P_SHIPMENT_SCHEDULE_LINE_ID,
				P_LINE_NUMBER);
  P_OPTION_LINE_NUMBER := OE_QUERY.OPTION_LINE_NUMBER (P_PARENT_LINE_ID, P_SERVICE_PARENT_LINE_ID,
				P_SHIPMENT_SCHEDULE_LINE_ID, P_LINE_NUMBER);
END GET_LINE_TRIPLET;

procedure GET_LINE_QUADRUPLET(
   P_LINE_ID				 IN NUMBER
,  P_BASE_LINE_NUMBER			 OUT NUMBER
,  P_SHIPMENT_SCHEDULE_NUMBER		 OUT NUMBER
,  P_OPTION_LINE_NUMBER			 OUT NUMBER
,  P_SERVICE_LINE_NUMBER		 OUT NUMBER
				)
IS
  V_PARENT_LINE_ID 		NUMBER;
  V_SERVICE_PARENT_LINE_ID	NUMBER;
  V_SHIPMENT_SCHEDULE_LINE_ID	NUMBER;
  V_LINE_NUMBER			NUMBER;
BEGIN
  SELECT PARENT_LINE_ID, SERVICE_PARENT_LINE_ID, SHIPMENT_SCHEDULE_LINE_ID,
	 LINE_NUMBER
  INTO   V_PARENT_LINE_ID, V_SERVICE_PARENT_LINE_ID, V_SHIPMENT_SCHEDULE_LINE_ID,
	 V_LINE_NUMBER
  FROM   SO_LINES
  WHERE  LINE_ID = P_LINE_ID;

  P_BASE_LINE_NUMBER := OE_QUERY.BASE_LINE_NUMBER (V_PARENT_LINE_ID, V_SERVICE_PARENT_LINE_ID,
				V_SHIPMENT_SCHEDULE_LINE_ID, V_LINE_NUMBER);
  P_SHIPMENT_SCHEDULE_NUMBER := OE_QUERY.SHIPMENT_SCHEDULE_NUMBER (V_PARENT_LINE_ID,
				V_SERVICE_PARENT_LINE_ID, V_SHIPMENT_SCHEDULE_LINE_ID,
				V_LINE_NUMBER);
  P_OPTION_LINE_NUMBER := OE_QUERY.OPTION_LINE_NUMBER (V_PARENT_LINE_ID, V_SERVICE_PARENT_LINE_ID,
				V_SHIPMENT_SCHEDULE_LINE_ID, V_LINE_NUMBER);

  IF (V_SERVICE_PARENT_LINE_ID IS NULL) THEN
    P_SERVICE_LINE_NUMBER := NULL;
  ELSE
    P_SERVICE_LINE_NUMBER := V_LINE_NUMBER;
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND
THEN
  P_BASE_LINE_NUMBER := NULL;
  P_SHIPMENT_SCHEDULE_NUMBER := NULL;
  P_OPTION_LINE_NUMBER := NULL;
  P_SERVICE_LINE_NUMBER := NULL;
  RETURN;
END GET_LINE_QUADRUPLET;

END OE_LINE_UTILITY;

/