--------------------------------------------------------
--  DDL for Package Body WSH_EXTERNAL_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_EXTERNAL_CUSTOM" AS
/* $Header: WSHUOPNB.pls 115.3 99/07/16 08:23:15 porting ship $ */

  FUNCTION Order_value ( header_id IN NUMBER )  RETURN NUMBER IS
    ov 	NUMBER;
  BEGIN
    ov := 0;
    RETURN ov;
  END Order_value;

  FUNCTION PickRelease_SLQs( batch_id 		IN NUMBER,
			     release_mode 	IN VARCHAR2 )
  RETURN VARCHAR2 IS
  BEGIN
    RETURN NULL;
  END PickRelease_SLQs;

  FUNCTION Departure_Name ( departure_id  IN NUMBER )
  RETURN VARCHAR2 IS
    dep_name 	VARCHAR2(30);
  BEGIN
    dep_name := SUBSTR(TO_CHAR( departure_id), 1, 30);
    RETURN dep_name;
  END Departure_Name;

  FUNCTION Delivery_Name ( delivery_id IN NUMBER )
  RETURN VARCHAR2 IS
    del_name 	VARCHAR2(30);
  BEGIN
    del_name := SUBSTR(TO_CHAR( delivery_id), 1, 15);
    RETURN del_name;
  END Delivery_Name;

  FUNCTION Bill_Of_Lading ( departure_id IN NUMBER )
  RETURN VARCHAR2 IS
  BEGIN
    RETURN NULL;
  END Bill_Of_Lading;

  FUNCTION WayBill ( departure_id IN NUMBER, del_id IN NUMBER )
  RETURN VARCHAR2 IS
  BEGIN

    RETURN NULL;

  END WayBill;

END WSH_EXTERNAL_CUSTOM;

/
