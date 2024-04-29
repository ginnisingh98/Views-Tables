--------------------------------------------------------
--  DDL for Package OE_LOT_SERIAL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LOT_SERIAL_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUSRLS.pls 120.0.12000000.1 2007/01/16 22:06:09 appldev ship $ */

--  Attributes global constants

G_ATTRIBUTE1                  CONSTANT NUMBER := 1;
G_ATTRIBUTE10                 CONSTANT NUMBER := 2;
G_ATTRIBUTE11                 CONSTANT NUMBER := 3;
G_ATTRIBUTE12                 CONSTANT NUMBER := 4;
G_ATTRIBUTE13                 CONSTANT NUMBER := 5;
G_ATTRIBUTE14                 CONSTANT NUMBER := 6;
G_ATTRIBUTE15                 CONSTANT NUMBER := 7;
G_ATTRIBUTE2                  CONSTANT NUMBER := 8;
G_ATTRIBUTE3                  CONSTANT NUMBER := 9;
G_ATTRIBUTE4                  CONSTANT NUMBER := 10;
G_ATTRIBUTE5                  CONSTANT NUMBER := 11;
G_ATTRIBUTE6                  CONSTANT NUMBER := 12;
G_ATTRIBUTE7                  CONSTANT NUMBER := 13;
G_ATTRIBUTE8                  CONSTANT NUMBER := 14;
G_ATTRIBUTE9                  CONSTANT NUMBER := 15;
G_CONTEXT                     CONSTANT NUMBER := 16;
G_CREATED_BY                  CONSTANT NUMBER := 17;
G_CREATION_DATE               CONSTANT NUMBER := 18;
G_FROM_SERIAL_NUMBER          CONSTANT NUMBER := 19;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 20;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 21;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 22;
G_LINE                        CONSTANT NUMBER := 23;
G_LOT_NUMBER                  CONSTANT NUMBER := 24;
G_LOT_SERIAL                  CONSTANT NUMBER := 25;
G_QUANTITY                    CONSTANT NUMBER := 26;
G_TO_SERIAL_NUMBER            CONSTANT NUMBER := 27;
G_ORIG_SYS_LOTSERIAL_REF      CONSTANT NUMBER := 28;
G_CHANGE_SEQUENCE_ID          CONSTANT NUMBER := 29;
G_LINE_SET                    CONSTANT NUMBER := 30;
G_LOCK_CONTROL                CONSTANT NUMBER := 31;
--G_SUBLOT_NUMBER               CONSTANT NUMBER := 32; --OPM 2380194 INVCONV
G_QUANTITY2                   CONSTANT NUMBER := 32; --OPM 2380194
G_MAX_ATTR_ID                 CONSTANT NUMBER := 33;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Lot_Serial_rec                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
,   p_old_Lot_Serial_rec            IN  OE_Order_PUB.Lot_Serial_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_REC
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_Lot_Serial_rec                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
,   p_old_Lot_Serial_rec            IN  OE_Order_PUB.Lot_Serial_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_REC
);

--  Procedure Complete_Record

PROCEDURE Complete_Record
(   p_x_Lot_Serial_rec                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
,   p_old_Lot_Serial_rec            IN  OE_Order_PUB.Lot_Serial_Rec_Type
);

--  PROCEDURE Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_Lot_Serial_rec                IN  OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
);

--  Procedure Set_Line_Set_ID
--  When parent line is split, this procedure should be called to update
--  the line set id to point to the line set.
--  Whenever line_set_id is set, the records should be accessed by line_set_id

PROCEDURE Set_Line_Set_ID
(   p_Line_ID                       IN NUMBER
,   p_Line_Set_ID                   IN NUMBER
);

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Lot_Serial_rec                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Lot_Serial_rec                IN  OUT NOCOPY  OE_Order_PUB.Lot_Serial_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_lot_serial_id                 IN  NUMBER := FND_API.G_MISS_NUM
,   p_line_id                       IN  NUMBER := FND_API.G_MISS_NUM
);

--  Procedure Query_Row

PROCEDURE Query_Row
(   p_lot_serial_id                 IN  NUMBER
,   x_lot_serial_rec                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
);

--  Procedure Query_Rows

--

PROCEDURE Query_Rows
(   p_lot_serial_id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_set_id                   IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_lot_serial_tbl                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
);

--  Procedure       lock_Row
--


PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

,   p_lot_serial_id                 IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Lot_Serial_rec              IN  OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
);

PROCEDURE Lock_Rows
(   p_lot_serial_id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_lot_serial_tbl                OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

);

--  Function Get_Values

FUNCTION Get_Values
(   p_Lot_Serial_rec                IN  OE_Order_PUB.Lot_Serial_Rec_Type
,   p_old_Lot_Serial_rec            IN  OE_Order_PUB.Lot_Serial_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_REC
) RETURN OE_Order_PUB.Lot_Serial_Val_Rec_Type;

--  Function Get_Ids

PROCEDURE Get_Ids
(   p_x_Lot_Serial_rec              IN  OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
,   p_Lot_Serial_val_rec            IN  OE_Order_PUB.Lot_Serial_Val_Rec_Type
);

END OE_Lot_Serial_Util;

 

/
