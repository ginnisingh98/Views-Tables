--------------------------------------------------------
--  DDL for Package OE_DEFAULT_LINE_PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_LINE_PAYMENT" AUTHID CURRENT_USER AS
/* $Header: OEXDLPMS.pls 120.1 2006/02/20 03:36:18 serla noship $ */

PROCEDURE Attributes
(   p_x_Line_Payment_rec          IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Rec_Type
,   p_old_Line_Payment_rec        IN  OE_Order_PUB.Line_Payment_Rec_Type
,   p_iteration                     IN  NUMBER := 1
) ;

FUNCTION Get_Payment_Number
(p_header_id IN NUMBER DEFAULT NULL
, p_line_id IN NUMBER)
RETURN NUMBER;

END OE_Default_Line_Payment  ;

 

/
