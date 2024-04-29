--------------------------------------------------------
--  DDL for Package OE_VALIDATE_HEADER_PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_HEADER_PAYMENT" AUTHID CURRENT_USER AS
/* $Header: OEXLHPMS.pls 120.0.12010000.1 2008/07/25 07:49:52 appldev ship $ */

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2
, p_Header_Payment_rec            IN  OE_Order_PUB.Header_Payment_Rec_Type
, p_old_Header_Payment_rec        IN  OE_Order_PUB.Header_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_REC
);

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2
, p_Header_Payment_rec            IN  OE_Order_PUB.Header_Payment_Rec_Type
, p_old_Header_Payment_rec        IN  OE_Order_PUB.Header_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
( x_return_status OUT NOCOPY VARCHAR2
, p_Header_Payment_rec            IN  OE_Order_PUB.Header_Payment_Rec_Type
);

END OE_Validate_Header_Payment;

/
