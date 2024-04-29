--------------------------------------------------------
--  DDL for Package OE_FLEX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_FLEX_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUFLXS.pls 120.0 2005/06/01 00:23:20 appldev noship $ */

FUNCTION Get_Concat_Value(
 Line_Number      IN NUMBER,
 Shipment_Number  IN NUMBER,
 Option_Number    IN NUMBER,
 Component_Number IN NUMBER DEFAULT NULL,
 Service_Number   IN NUMBER DEFAULT NULL
 )RETURN VARCHAR2;

END OE_Flex_UTIL;

 

/
