--------------------------------------------------------
--  DDL for Package OE_VALIDATE_LOT_SERIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_LOT_SERIAL" AUTHID CURRENT_USER AS
/* $Header: OEXLSRLS.pls 120.0 2005/05/31 23:36:17 appldev noship $ */

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_Lot_Serial_rec                IN  OE_Order_PUB.Lot_Serial_Rec_Type
,   p_old_Lot_Serial_rec            IN  OE_Order_PUB.Lot_Serial_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_REC
);

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_Lot_Serial_rec                IN  OE_Order_PUB.Lot_Serial_Rec_Type
,   p_old_Lot_Serial_rec            IN  OE_Order_PUB.Lot_Serial_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
( x_return_status OUT NOCOPY VARCHAR2

,   p_Lot_Serial_rec                IN  OE_Order_PUB.Lot_Serial_Rec_Type
);

END OE_Validate_Lot_Serial;

 

/
