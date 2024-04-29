--------------------------------------------------------
--  DDL for Package OE_SHIPPING_CURRENT_LOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SHIPPING_CURRENT_LOC" AUTHID CURRENT_USER AS
/* $Header: OEXOMWSS.pls 120.0 2005/06/01 02:36:58 appldev noship $ */


FUNCTION get_current_location(
 p_delivery_name	     IN	VARCHAR2 DEFAULT NULL,
 p_tracking_number_dd	IN	VARCHAR2 DEFAULT NULL,
 p_mode			     IN	VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;

END OE_SHIPPING_CURRENT_LOC;

 

/
