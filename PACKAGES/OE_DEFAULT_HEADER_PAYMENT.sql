--------------------------------------------------------
--  DDL for Package OE_DEFAULT_HEADER_PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_HEADER_PAYMENT" AUTHID CURRENT_USER AS
/* $Header: OEXDHPMS.pls 120.0.12010000.1 2008/07/25 07:47:22 appldev ship $ */

PROCEDURE Attributes
(   p_x_Header_Payment_rec          IN OUT NOCOPY  OE_Order_PUB.Header_Payment_Rec_Type
,   p_old_Header_Payment_rec        IN  OE_Order_PUB.Header_Payment_Rec_Type
,   p_iteration                     IN  NUMBER := 1
) ;
FUNCTION Get_Payment_Number
(p_header_id	IN NUMBER)
RETURN NUMBER;

END OE_Default_Header_Payment  ;

/
