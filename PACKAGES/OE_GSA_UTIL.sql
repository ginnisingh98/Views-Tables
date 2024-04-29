--------------------------------------------------------
--  DDL for Package OE_GSA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_GSA_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUGSAS.pls 120.0 2005/06/01 02:53:42 appldev noship $ */

FUNCTION Check_GSA_Main
(p_line_rec	 IN	 OE_Order_Pub.Line_Rec_Type,
 x_resultout     IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2)  RETURN VARCHAR2;

FUNCTION Check_GSA_Enabled
(p_line_rec	 IN	 OE_Order_Pub.Line_Rec_Type) RETURN VARCHAR2;

FUNCTION Check_GSA_Indicator
(p_line_rec	 IN	 OE_Order_Pub.Line_Rec_Type) RETURN VARCHAR2;

FUNCTION Check_GSA_CUSTOMER
(p_line_rec	 IN	 OE_Order_Pub.Line_Rec_Type) RETURN VARCHAR2;

FUNCTION Get_NonGSA_Count
(p_line_rec	 IN	 OE_Order_Pub.Line_Rec_Type) RETURN NUMBER;

FUNCTION Check_NONGSA_CUSTOMER
(p_line_rec	 IN	 OE_Order_Pub.Line_Rec_Type) RETURN VARCHAR2;

FUNCTION Get_GSA_Count
(p_line_rec	 IN	 OE_Order_Pub.Line_Rec_Type) RETURN NUMBER;

FUNCTION Get_Hold_id(hold NUMBER) RETURN NUMBER ;

FUNCTION Get_Source_id(header_id  NUMBER) RETURN NUMBER ;

FUNCTION Release_Hold
(p_line_rec	 IN	 OE_Order_Pub.Line_Rec_Type,
 x_resultout IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2) RETURN VARCHAR2;


END OE_GSA_UTIL;

 

/
