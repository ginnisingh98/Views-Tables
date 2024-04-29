--------------------------------------------------------
--  DDL for Package OE_VALIDATE_LINE_PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_LINE_PAYMENT" AUTHID CURRENT_USER AS
/* $Header: OEXLLPMS.pls 115.2 2003/10/20 07:00:53 appldev ship $ */

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2
, p_Line_Payment_rec            IN  OE_Order_PUB.Line_Payment_Rec_Type
, p_old_Line_Payment_rec        IN  OE_Order_PUB.Line_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_REC
);

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2
, p_Line_Payment_rec            IN  OE_Order_PUB.Line_Payment_Rec_Type
, p_old_Line_Payment_rec        IN  OE_Order_PUB.Line_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
( x_return_status OUT NOCOPY VARCHAR2
, p_Line_Payment_rec            IN  OE_Order_PUB.Line_Payment_Rec_Type
);

END OE_Validate_Line_Payment;

 

/
