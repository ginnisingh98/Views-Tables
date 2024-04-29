--------------------------------------------------------
--  DDL for Package WSH_EXTERNAL_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_EXTERNAL_CUSTOM" AUTHID CURRENT_USER AS
/* $Header: WSHUOPNS.pls 115.0 99/07/16 08:23:18 porting ship $ */

  FUNCTION Order_value ( header_id IN NUMBER ) RETURN NUMBER;

  -- This should only return  FROM and WHERE clause
  FUNCTION PickRelease_SLQs( batch_id 		IN NUMBER,
			     release_mode 	IN VARCHAR2 ) RETURN VARCHAR2;

  FUNCTION Departure_Name ( departure_id  IN NUMBER ) RETURN VARCHAR2;

  FUNCTION Delivery_Name ( delivery_id IN NUMBER ) RETURN VARCHAR2;

  FUNCTION Bill_Of_Lading ( departure_id IN NUMBER ) RETURN VARCHAR2;

  FUNCTION WayBill ( departure_id IN NUMBER, del_id IN NUMBER )
  RETURN VARCHAR2;

END WSH_EXTERNAL_CUSTOM;

 

/
