--------------------------------------------------------
--  DDL for Package Body OE_LOT_SERIAL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LOT_SERIAL_UTIL" AS
/* $Header: OEXUSRLB.pls 120.0.12000000.2 2007/07/24 05:29:24 cpati ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Lot_Serial_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Lot_Serial_rec              IN  OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
,   p_old_Lot_Serial_rec            IN  OE_Order_PUB.Lot_Serial_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_REC
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                OE_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                OE_GLOBALS.NUMBER_Tbl_Type;
BEGIN

-- SINCE THIS PROCEDURE IS DOING NOTHING, FOR PERFORMANCE, IT RETURNS IMMEDIATELY
    RETURN;

    --  Load out record


    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute1,p_old_Lot_Serial_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute10,p_old_Lot_Serial_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute11,p_old_Lot_Serial_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute12,p_old_Lot_Serial_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute13,p_old_Lot_Serial_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute14,p_old_Lot_Serial_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute15,p_old_Lot_Serial_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute2,p_old_Lot_Serial_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute3,p_old_Lot_Serial_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute4,p_old_Lot_Serial_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute5,p_old_Lot_Serial_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute6,p_old_Lot_Serial_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute7,p_old_Lot_Serial_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute8,p_old_Lot_Serial_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute9,p_old_Lot_Serial_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.context,p_old_Lot_Serial_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_CONTEXT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.created_by,p_old_Lot_Serial_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_CREATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.creation_date,p_old_Lot_Serial_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.from_serial_number,p_old_Lot_Serial_rec.from_serial_number)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_FROM_SERIAL_NUMBER;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.last_updated_by,p_old_Lot_Serial_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.last_update_date,p_old_Lot_Serial_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.last_update_login,p_old_Lot_Serial_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.line_id,p_old_Lot_Serial_rec.line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_LINE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.line_set_id,p_old_Lot_Serial_rec.line_set_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_LINE_SET;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.lot_number,p_old_Lot_Serial_rec.lot_number)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_LOT_NUMBER;
        END IF;

        /* IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' -- INVCONV
         THEN
            IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.sublot_number,p_old_Lot_Serial_rec.sublot_number) -- OPM 2380194 -- INVCONV
            THEN
              l_index := l_index + 1;
              l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_SUBLOT_NUMBER;
            END IF;

        END IF; */

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.lot_serial_id,p_old_Lot_Serial_rec.lot_serial_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_LOT_SERIAL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.quantity,p_old_Lot_Serial_rec.quantity)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_QUANTITY;
        END IF;

         IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510'
         THEN
           IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.quantity2,p_old_Lot_Serial_rec.quantity2) -- OPM 2380194
           THEN
             l_index := l_index + 1;
             l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_QUANTITY2;
       	   END IF;
        END IF;
        IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.to_serial_number,p_old_Lot_Serial_rec.to_serial_number)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_TO_SERIAL_NUMBER;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_FROM_SERIAL_NUMBER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_FROM_SERIAL_NUMBER;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_LINE;
    ELSIF p_attr_id = G_LOT_NUMBER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_LOT_NUMBER;
    ELSIF p_attr_id = G_LOT_SERIAL THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_LOT_SERIAL;
    /*ELSIF p_attr_id = G_SUBLOT_NUMBER THEN         --OPM 2380194 INVCONV
       IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
   	 THEN
          l_index := l_index + 1;
          l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_SUBLOT_NUMBER;
       END IF; */
    ELSIF p_attr_id = G_QUANTITY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_QUANTITY;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_QUANTITY;

    ELSIF p_attr_id = G_QUANTITY2 THEN  --OPM 2380194
       IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
         THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_QUANTITY2;
       END IF;
    ELSIF p_attr_id = G_TO_SERIAL_NUMBER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LOT_SERIAL_UTIL.G_TO_SERIAL_NUMBER;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_Lot_Serial_rec              IN  OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
,   p_old_Lot_Serial_rec            IN  OE_Order_PUB.Lot_Serial_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_REC
)
IS
l_serial_validation_flag  VARCHAR2(1) := 'N';
x_prefix                  VARCHAR2(80);
x_quantity                VARCHAR2(80);
x_from_number             VARCHAR2(80);
x_to_number               VARCHAR2(80);
x_error_code              NUMBER;

BEGIN

    -- Please take out the comment when there is going to be a code associated
    -- with following attributes
/*
    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute1,p_old_Lot_Serial_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute10,p_old_Lot_Serial_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute11,p_old_Lot_Serial_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute12,p_old_Lot_Serial_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute13,p_old_Lot_Serial_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute14,p_old_Lot_Serial_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute15,p_old_Lot_Serial_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute2,p_old_Lot_Serial_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute3,p_old_Lot_Serial_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute4,p_old_Lot_Serial_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute5,p_old_Lot_Serial_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute6,p_old_Lot_Serial_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute7,p_old_Lot_Serial_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute8,p_old_Lot_Serial_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.attribute9,p_old_Lot_Serial_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.context,p_old_Lot_Serial_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.created_by,p_old_Lot_Serial_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.creation_date,p_old_Lot_Serial_rec.creation_date)
    THEN
        NULL;
    END IF;


    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.last_updated_by,p_old_Lot_Serial_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.last_update_date,p_old_Lot_Serial_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.last_update_login,p_old_Lot_Serial_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.line_id,p_old_Lot_Serial_rec.line_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.line_set_id,p_old_Lot_Serial_rec.line_set_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.lot_number,p_old_Lot_Serial_rec.lot_number)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.lot_serial_id,p_old_Lot_Serial_rec.lot_serial_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.from_serial_number,p_old_Lot_Serial_rec.from_serial_number)
    THEN
        l_serial_validation_flag  := 'Y';
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.quantity,p_old_Lot_Serial_rec.quantity)
    THEN
        l_serial_validation_flag  := 'Y';
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Lot_Serial_rec.to_serial_number,p_old_Lot_Serial_rec.to_serial_number)
    THEN
        l_serial_validation_flag  := 'Y';
    END IF;

    IF l_serial_validation_flag = 'Y' THEN

	   IF p_x_Lot_Serial_rec.from_serial_number IS NOT NULL AND
		 p_x_Lot_Serial_rec.from_serial_number <> FND_API.G_MISS_CHAR AND
           p_x_Lot_Serial_rec.to_serial_number <> FND_API.G_MISS_CHAR
        THEN
            IF NOT MTL_SERIAL_CHECK.INV_SERIAL_INFO(
                        p_x_Lot_Serial_rec.from_serial_number,
                        p_x_Lot_Serial_rec.to_serial_number,
                        x_prefix,
                        x_quantity,
                        x_from_number,
                        x_to_number,
                        x_error_code)
            THEN
                fnd_message.set_name('ONT','OE_QUANTITY_MISMATCH');
                oe_msg_pub.ADD;
                raise FND_API.G_EXC_ERROR;
            ELSE
                IF p_x_Lot_Serial_rec.quantity <> x_quantity THEN
                    fnd_message.set_name('ONT','OE_QUANTITY_MISMATCH');
                    oe_msg_pub.ADD;
                    raise FND_API.G_EXC_ERROR;
			 END IF;
            END IF;

	   END IF;
        l_serial_validation_flag  := 'N';

    END IF;
*/
    NULL;

END Apply_Attribute_Changes;

--  Procedure Complete_Record

PROCEDURE Complete_Record
(   p_x_Lot_Serial_rec                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
,   p_old_Lot_Serial_rec            IN  OE_Order_PUB.Lot_Serial_Rec_Type
)
IS
BEGIN

    OE_DEBUG_PUB.ADD('Inside complete record',1);
   OE_DEBUG_PUB.ADD('The quantity is '||to_char(p_x_Lot_Serial_rec.quantity),1);
    IF p_x_Lot_Serial_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute1 := p_old_Lot_Serial_rec.attribute1;
    END IF;

    IF p_x_Lot_Serial_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute10 := p_old_Lot_Serial_rec.attribute10;
    END IF;

    IF p_x_Lot_Serial_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute11 := p_old_Lot_Serial_rec.attribute11;
    END IF;

    IF p_x_Lot_Serial_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute12 := p_old_Lot_Serial_rec.attribute12;
    END IF;

    IF p_x_Lot_Serial_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute13 := p_old_Lot_Serial_rec.attribute13;
    END IF;

    IF p_x_Lot_Serial_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute14 := p_old_Lot_Serial_rec.attribute14;
    END IF;

    IF p_x_Lot_Serial_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute15 := p_old_Lot_Serial_rec.attribute15;
    END IF;

    IF p_x_Lot_Serial_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute2 := p_old_Lot_Serial_rec.attribute2;
    END IF;

    IF p_x_Lot_Serial_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute3 := p_old_Lot_Serial_rec.attribute3;
    END IF;

    IF p_x_Lot_Serial_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute4 := p_old_Lot_Serial_rec.attribute4;
    END IF;

    IF p_x_Lot_Serial_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute5 := p_old_Lot_Serial_rec.attribute5;
    END IF;

    IF p_x_Lot_Serial_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute6 := p_old_Lot_Serial_rec.attribute6;
    END IF;

    IF p_x_Lot_Serial_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute7 := p_old_Lot_Serial_rec.attribute7;
    END IF;

    IF p_x_Lot_Serial_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute8 := p_old_Lot_Serial_rec.attribute8;
    END IF;

    IF p_x_Lot_Serial_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute9 := p_old_Lot_Serial_rec.attribute9;
    END IF;

    IF p_x_Lot_Serial_rec.context = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.context := p_old_Lot_Serial_rec.context;
    END IF;

    IF p_x_Lot_Serial_rec.created_by = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.created_by := p_old_Lot_Serial_rec.created_by;
    END IF;

    IF p_x_Lot_Serial_rec.creation_date = FND_API.G_MISS_DATE THEN
        p_x_Lot_Serial_rec.creation_date := p_old_Lot_Serial_rec.creation_date;
    END IF;

    IF p_x_Lot_Serial_rec.from_serial_number = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.from_serial_number := p_old_Lot_Serial_rec.from_serial_number;
    END IF;

    IF p_x_Lot_Serial_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.last_updated_by := p_old_Lot_Serial_rec.last_updated_by;
    END IF;

    IF p_x_Lot_Serial_rec.last_update_date = FND_API.G_MISS_DATE THEN
        p_x_Lot_Serial_rec.last_update_date := p_old_Lot_Serial_rec.last_update_date;
    END IF;

    IF p_x_Lot_Serial_rec.last_update_login = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.last_update_login := p_old_Lot_Serial_rec.last_update_login;
    END IF;

    IF p_x_Lot_Serial_rec.line_id = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.line_id := p_old_Lot_Serial_rec.line_id;
    END IF;

    IF p_x_Lot_Serial_rec.line_set_id = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.line_set_id := p_old_Lot_Serial_rec.line_set_id;
    END IF;

    IF p_x_Lot_Serial_rec.lot_number = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.lot_number := p_old_Lot_Serial_rec.lot_number;
    END IF;

    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510'
     THEN
    	/*IF p_x_Lot_Serial_rec.sublot_number = FND_API.G_MISS_CHAR THEN
           p_x_Lot_Serial_rec.sublot_number := p_old_Lot_Serial_rec.sublot_number;
    	END IF;         --OPM 2380194  */ -- INVCONV

    	IF p_x_Lot_Serial_rec.quantity2 = FND_API.G_MISS_NUM THEN --OPM 2380194
        	p_x_Lot_Serial_rec.quantity2 := p_old_Lot_Serial_rec.quantity2;
    	END IF;
    END IF;

    IF p_x_Lot_Serial_rec.lot_serial_id = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.lot_serial_id := p_old_Lot_Serial_rec.lot_serial_id;
    END IF;

    IF p_x_Lot_Serial_rec.quantity = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.quantity := p_old_Lot_Serial_rec.quantity;
    END IF;

    IF p_x_Lot_Serial_rec.to_serial_number = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.to_serial_number := p_old_Lot_Serial_rec.to_serial_number;
    END IF;

   OE_DEBUG_PUB.ADD('The quantity is '||to_char(p_x_Lot_Serial_rec.quantity),1);
END Complete_Record;

--  Procedure Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_Lot_Serial_rec                IN OUT NOCOPY  OE_Order_PUB.Lot_Serial_Rec_Type
)
IS
BEGIN

    IF p_x_Lot_Serial_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute1 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute10 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute11 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute12 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute13 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute14 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute15 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute2 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute3 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute4 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute5 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute6 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute7 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute8 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.attribute9 := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.context = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.context := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.created_by = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.created_by := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.creation_date = FND_API.G_MISS_DATE THEN
        p_x_Lot_Serial_rec.creation_date := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.from_serial_number = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.from_serial_number := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.last_updated_by := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.last_update_date = FND_API.G_MISS_DATE THEN
        p_x_Lot_Serial_rec.last_update_date := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.last_update_login = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.last_update_login := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.line_id = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.line_id := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.line_set_id = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.line_set_id := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.lot_number = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.lot_number := NULL;
    END IF;

    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510'
       THEN

     	/*IF p_x_Lot_Serial_rec.sublot_number = FND_API.G_MISS_CHAR THENINVCONV
        	p_x_Lot_Serial_rec.sublot_number := NULL;
    	END IF;  --OPM 2380194 */

     	IF p_x_Lot_Serial_rec.quantity2 = FND_API.G_MISS_NUM THEN  --OPM 2380194
        	p_x_Lot_Serial_rec.quantity2 := NULL;
    	END IF;
    END IF;

    IF p_x_Lot_Serial_rec.lot_serial_id = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.lot_serial_id := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.quantity = FND_API.G_MISS_NUM THEN
        p_x_Lot_Serial_rec.quantity := NULL;
    END IF;

    IF p_x_Lot_Serial_rec.to_serial_number = FND_API.G_MISS_CHAR THEN
        p_x_Lot_Serial_rec.to_serial_number := NULL;
    END IF;

END Convert_Miss_To_Null;

--  Procedure Set_Line_Set_ID
--  When parent line is split, this procedure should be called to update
--  the line set id to point to the line set.
--  Whenever line_set_id is set, the records should be accessed by line_set_id
Procedure Set_Line_Set_ID
(   p_Line_ID                       IN NUMBER
,   p_Line_Set_ID                   IN NUMBER)
IS
BEGIN

    UPDATE OE_LOT_SERIAL_NUMBERS
    SET LINE_SET_ID = p_Line_Set_ID
    WHERE LINE_ID = p_Line_ID;

    IF (SQL%NOTFOUND) THEN
     -- No lot/serial numbers attached to the return line, do nothing
      NULL;
    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Set_Line_Set_ID'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Set_Line_Set_ID;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Lot_Serial_rec          IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
)
IS
  l_lock_control NUMBER;
/* jolin start*/
--added for notification framework
      l_lot_serial_rec     OE_Order_PUB.Lot_serial_Rec_Type;
      l_index    NUMBER;
      l_return_status VARCHAR2(1);
/* jolin end*/

BEGIN

    SELECT lock_control
    INTO   l_lock_control
    FROM   OE_LOT_SERIAL_NUMBERS
    WHERE  lot_serial_id = p_Lot_Serial_rec.lot_serial_id;

    l_lock_control := l_lock_control + 1;

/* jolin start*/
    --added query_row for notification framework
    --before update, query lot serial record, this record will be used
    --to update global picture

     OE_LOT_SERIAL_UTIL.Query_Row(p_lot_serial_id => p_lot_serial_rec.lot_serial_id,
                              x_lot_serial_rec =>l_lot_serial_rec);
     oe_debug_pub.add('before update, lot_serial_id= '|| l_lot_serial_rec.lot_serial_id, 1);
/* jolin end*/

    UPDATE  OE_LOT_SERIAL_NUMBERS
    SET     ATTRIBUTE1                 = p_Lot_Serial_rec.attribute1
    ,       ATTRIBUTE10                = p_Lot_Serial_rec.attribute10
    ,       ATTRIBUTE11                = p_Lot_Serial_rec.attribute11
    ,       ATTRIBUTE12                = p_Lot_Serial_rec.attribute12
    ,       ATTRIBUTE13                = p_Lot_Serial_rec.attribute13
    ,       ATTRIBUTE14                = p_Lot_Serial_rec.attribute14
    ,       ATTRIBUTE15                = p_Lot_Serial_rec.attribute15
    ,       ATTRIBUTE2                 = p_Lot_Serial_rec.attribute2
    ,       ATTRIBUTE3                 = p_Lot_Serial_rec.attribute3
    ,       ATTRIBUTE4                 = p_Lot_Serial_rec.attribute4
    ,       ATTRIBUTE5                 = p_Lot_Serial_rec.attribute5
    ,       ATTRIBUTE6                 = p_Lot_Serial_rec.attribute6
    ,       ATTRIBUTE7                 = p_Lot_Serial_rec.attribute7
    ,       ATTRIBUTE8                 = p_Lot_Serial_rec.attribute8
    ,       ATTRIBUTE9                 = p_Lot_Serial_rec.attribute9
    ,       CONTEXT                    = p_Lot_Serial_rec.context
    ,       CREATED_BY                 = p_Lot_Serial_rec.created_by
    ,       CREATION_DATE              = p_Lot_Serial_rec.creation_date
    ,       FROM_SERIAL_NUMBER         = p_Lot_Serial_rec.from_serial_number
    ,       LAST_UPDATED_BY            = p_Lot_Serial_rec.last_updated_by
    ,       LAST_UPDATE_DATE           = p_Lot_Serial_rec.last_update_date
    ,       LAST_UPDATE_LOGIN          = p_Lot_Serial_rec.last_update_login
    ,       LINE_ID                    = p_Lot_Serial_rec.line_id
    ,       LOT_NUMBER                 = p_Lot_Serial_rec.lot_number
--    ,       SUBLOT_NUMBER              = p_Lot_Serial_rec.sublot_number    --OPM 2380194     INVCONV
    ,       LOT_SERIAL_ID              = p_Lot_Serial_rec.lot_serial_id
    ,       QUANTITY                   = p_Lot_Serial_rec.quantity
    ,       QUANTITY2                  = p_Lot_Serial_rec.quantity2  --OPM 2380194
    ,       TO_SERIAL_NUMBER           = p_Lot_Serial_rec.to_serial_number
    ,       ORIG_SYS_LOTSERIAL_REF     = p_Lot_Serial_rec.orig_sys_lotserial_ref
    ,       LINE_SET_ID                = p_Lot_Serial_rec.line_set_id
    ,       LOCK_CONTROL               = p_Lot_Serial_rec.lock_control
    WHERE   LOT_SERIAL_ID = p_Lot_Serial_rec.lot_serial_id
    ;

 /* jolin start*/
IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN

    -- calling notification framework to update global picture

  oe_debug_pub.add('after update, old lot serial Id= ' || l_lot_serial_rec.lot_serial_id);
  oe_debug_pub.add('after update, new lot serial Id= ' || p_lot_serial_rec.lot_serial_id);

   OE_ORDER_UTIL.Update_Global_Picture(
			p_Upd_New_Rec_If_Exists => True,
                    	p_lot_serial_rec =>	p_lot_serial_rec,
                    	p_old_lot_serial_rec => l_lot_serial_rec,
                    	p_lot_serial_id => 	p_lot_serial_rec.lot_serial_id,
                    	x_index => 		l_index,
                    	x_return_status =>	 l_return_status);

    OE_DEBUG_PUB.ADD('Update_Global Return Status from OE_LOT_SERIAL_UTIL.update_row is: ' || l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        OE_DEBUG_PUB.ADD('EVENT NOTIFY - Unexpected Error');
        OE_DEBUG_PUB.ADD('Exiting OE_LOT_SERIAL_UTIL.Update_ROW', 1);
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        OE_DEBUG_PUB.ADD('Update_Global_Picture Error in OE_LOT_SERIAL_UTIL.Update_row');
        OE_DEBUG_PUB.ADD('Exiting OE_LOT_SERIAL_UTIL.Update_ROW', 1);
	RAISE FND_API.G_EXC_ERROR;
     END IF;

   -- notification framework end
END IF; /* code set is pack H or higher */
/* jolin end*/

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Lot_Serial_rec                IN  OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
)
IS
  l_lock_control   NUMBER := 1;
/* jolin start*/
        l_index    NUMBER;
        l_return_status VARCHAR2(1);
/* jolin end*/

BEGIN

    INSERT  INTO OE_LOT_SERIAL_NUMBERS
    (       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       FROM_SERIAL_NUMBER
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       LOT_NUMBER
--    ,       SUBLOT_NUMBER --OPM 2380194  INVCONV
    ,       LOT_SERIAL_ID
    ,       QUANTITY
    ,       QUANTITY2 --OPM 2380194
    ,       TO_SERIAL_NUMBER
    ,       ORIG_SYS_LOTSERIAL_REF
    ,       LINE_SET_ID
    ,       LOCK_CONTROL
    )
    VALUES
    (       p_Lot_Serial_rec.attribute1
    ,       p_Lot_Serial_rec.attribute10
    ,       p_Lot_Serial_rec.attribute11
    ,       p_Lot_Serial_rec.attribute12
    ,       p_Lot_Serial_rec.attribute13
    ,       p_Lot_Serial_rec.attribute14
    ,       p_Lot_Serial_rec.attribute15
    ,       p_Lot_Serial_rec.attribute2
    ,       p_Lot_Serial_rec.attribute3
    ,       p_Lot_Serial_rec.attribute4
    ,       p_Lot_Serial_rec.attribute5
    ,       p_Lot_Serial_rec.attribute6
    ,       p_Lot_Serial_rec.attribute7
    ,       p_Lot_Serial_rec.attribute8
    ,       p_Lot_Serial_rec.attribute9
    ,       p_Lot_Serial_rec.context
    ,       p_Lot_Serial_rec.created_by
    ,       p_Lot_Serial_rec.creation_date
    ,       p_Lot_Serial_rec.from_serial_number
    ,       p_Lot_Serial_rec.last_updated_by
    ,       p_Lot_Serial_rec.last_update_date
    ,       p_Lot_Serial_rec.last_update_login
    ,       p_Lot_Serial_rec.line_id
    ,       p_Lot_Serial_rec.lot_number
--    ,       p_Lot_Serial_rec.sublot_number    --OPM 2380194     INVCONV
    ,       p_Lot_Serial_rec.lot_serial_id
    ,       p_Lot_Serial_rec.quantity
    ,       p_Lot_Serial_rec.quantity2  --OPM 2380194
    ,       p_Lot_Serial_rec.to_serial_number
    ,       p_Lot_Serial_rec.orig_sys_lotserial_ref
    ,       p_Lot_Serial_rec.line_set_id
    ,       p_Lot_Serial_rec.lock_control
    );

/* jolin start*/
IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
   -- calling notification framework to update global picture
     OE_ORDER_UTIL.Update_Global_Picture(
			p_Upd_New_Rec_If_Exists => True,
                    	p_old_lot_serial_rec => NULL,
                    	p_lot_serial_rec =>	p_lot_serial_rec,
                    	p_lot_serial_id => 	p_lot_serial_rec.lot_serial_id,
                    	x_index => 		l_index,
                    	x_return_status => 	l_return_status);

    OE_DEBUG_PUB.ADD('Update_Global Return Status from OE_LOT_SERIAL_UTIL.insert_row is: ' || l_return_status);
    OE_DEBUG_PUB.ADD('returned index is: ' || l_index ,1);


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        OE_DEBUG_PUB.ADD('EVENT NOTIFY - Unexpected Error');
        OE_DEBUG_PUB.ADD('Exiting OE_LOT_SERIAL_UTIL.INSERT_ROW', 1);
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        OE_DEBUG_PUB.ADD('Update_Global_Picture Error in OE_LOT_SERIAL_UTIL.Insert_row');
        OE_DEBUG_PUB.ADD('Exiting OE_LOT_SERIAL_UTIL.INSERT_ROW', 1);
	RAISE FND_API.G_EXC_ERROR;
     END IF;

  -- notification framework end
END IF; /* code set is pack H or higher */
/* jolin end */

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

/* Function Is_Last_In_Line_Set: to check if there is any other line that is in the same
 * line set as the current line, pass in line id and return boolean
 */

FUNCTION Is_Last_In_Line_Set(p_line_id NUMBER)
RETURN BOOLEAN
IS
l_line_rec oe_order_pub.line_rec_type;
l_line_set_id NUMBER;
dummy NUMBER;
BEGIN

   oe_line_util.query_row(p_line_id=>p_line_id, x_line_rec=>l_line_rec);

   l_line_set_id := l_line_rec.line_set_id;

   IF (l_line_rec.line_set_id IS NOT NULL AND
       l_line_rec.line_set_id <> fnd_api.g_miss_num)
     THEN

      BEGIN
	 SELECT 1 INTO dummy
         FROM oe_order_lines
         WHERE line_set_id = l_line_set_id
	   AND line_id <> p_line_id;
      EXCEPTION
	 WHEN others THEN
	    RETURN TRUE;
      END;
      RETURN FALSE;
    ELSE
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

END Is_Last_In_Line_Set;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_lot_serial_id                 IN  NUMBER := fnd_api.g_miss_num
,   p_line_id                       IN NUMBER := fnd_api.g_miss_num

)
IS
l_line_rec OE_ORDER_PUB.line_rec_type;
/* jolin start*/
  -- added for notification framework
        l_old_lot_serial_rec    OE_Order_PUB.Lot_Serial_Rec_Type;
        l_new_lot_serial_rec	OE_Order_PUB.Lot_Serial_Rec_Type;
        l_index    		NUMBER;
        l_return_status		VARCHAR2(1);

CURSOR line_set IS
	SELECT lot_serial_id
     	FROM OE_LOT_SERIAL_NUMBERS
	WHERE line_set_id = l_line_rec.line_set_id;

CURSOR lot_serial IS
	SELECT lot_serial_id
     	FROM OE_LOT_SERIAL_NUMBERS
	WHERE line_id = p_line_id;

/* jolin end*/


BEGIN

   oe_debug_pub.add('Entering OE_LOT_SERIAL_UTIL.DELETE_ROW', 1);
   IF (p_line_id <> FND_API.G_MISS_NUM)
   THEN

     OE_LINE_UTIL.Query_Row(p_line_id=>p_line_id,x_line_rec=>l_line_rec);

     IF (l_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE)
     THEN
       IF (l_line_rec.line_set_id IS NULL OR
	 l_line_rec.line_set_id = FND_API.G_MISS_NUM)
       THEN
	/* jolin start*/
	IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
	  --added for notification framework to update global picture for lot serials for this line_id

         oe_debug_pub.add('JPN: Line ID' || p_line_id);
	 FOR l_lots IN lot_serial
	    LOOP
	    --query lot serial record, then call notification framework to update global picture.

	     OE_LOT_SERIAL_UTIL.Query_Row(p_lot_serial_id => l_lots.lot_serial_id,
                            		x_lot_serial_rec =>l_old_lot_serial_rec);

	     oe_debug_pub.add('in delete row, lot_serial_id= '|| l_lots.lot_serial_id , 1);

	    /* Set the operation on the record so that globals are updated as well */
	     l_new_lot_serial_rec.operation := OE_GLOBALS.G_OPR_DELETE;
	     l_new_lot_serial_rec.lot_serial_id :=l_lots.lot_serial_id;

	      OE_ORDER_UTIL.Update_Global_Picture(
		    p_Upd_New_Rec_If_Exists => 	True,
                    p_lot_serial_rec =>		l_new_lot_serial_rec,
                    p_old_lot_serial_rec => 	l_old_lot_serial_rec,
                    p_lot_serial_id =>		l_lots.lot_serial_id,
                    x_index => 			l_index,
                    x_return_status => 		l_return_status);

	     OE_DEBUG_PUB.ADD('Update_Global Return Status from OE_LOT_SERIAL_UTIL.delete_row' ||
		' for deleting line set lot_serial line is: ' || l_return_status);

	    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	        OE_DEBUG_PUB.ADD('EVENT NOTIFY - Unexpected Error');
	        OE_DEBUG_PUB.ADD('Exiting OE_LOT_SERIAL_UTIL.DELETE_ROW', 1);
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	        OE_DEBUG_PUB.ADD('Update_Global_Picture Error in OE_LOT_SERIAL_UTIL.Delete_row');
	        OE_DEBUG_PUB.ADD('Exiting OE_LOT_SERIAL_UTIL.DELETE_ROW', 1);
		RAISE FND_API.G_EXC_ERROR;
	     END IF;

	  END LOOP;
	    -- notification framework end
	END IF; /* code set is pack H or higher */
	/* jolin end*/

          -- delete lot serial numbers for this line
          DELETE FROM oe_lot_serial_numbers
	  WHERE line_id = p_line_id;

       ELSIF (Is_Last_In_Line_Set(p_line_id)) THEN

	/* jolin start*/
	IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
	  --added for notification framework to update global picture for lot serials in line set

	 FOR l_set IN line_set
	    LOOP
	    --query lot serial record, then call notification framework to update global picture.

	     OE_LOT_SERIAL_UTIL.Query_Row(p_lot_serial_id => l_set.lot_serial_id,
                            		x_lot_serial_rec =>l_old_lot_serial_rec);

	     oe_debug_pub.add('in delete row, lot_serial_id= '|| l_set.lot_serial_id , 1);

	    /* Set the operation on the record so that globals are updated as well */
	     l_new_lot_serial_rec.operation := OE_GLOBALS.G_OPR_DELETE;
	     l_new_lot_serial_rec.lot_serial_id :=l_set.lot_serial_id;

	      OE_ORDER_UTIL.Update_Global_Picture(
		    p_Upd_New_Rec_If_Exists => 	True,
                    p_lot_serial_rec =>		l_new_lot_serial_rec,
                    p_old_lot_serial_rec => 	l_old_lot_serial_rec,
                    p_lot_serial_id =>		l_set.lot_serial_id,
                    x_index => 			l_index,
                    x_return_status => 		l_return_status);

	     OE_DEBUG_PUB.ADD('Update_Global Return Status from OE_LOT_SERIAL_UTIL.delete_row' ||
		' for deleting line set lot_serial line is: ' || l_return_status);

	    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	        OE_DEBUG_PUB.ADD('EVENT NOTIFY - Unexpected Error');
	        OE_DEBUG_PUB.ADD('Exiting OE_LOT_SERIAL_UTIL.DELETE_ROW', 1);
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	        OE_DEBUG_PUB.ADD('Update_Global_Picture Error in OE_LOT_SERIAL_UTIL.Delete_row');
	        OE_DEBUG_PUB.ADD('Exiting OE_LOT_SERIAL_UTIL.DELETE_ROW', 1);
		RAISE FND_API.G_EXC_ERROR;
	     END IF;

	  END LOOP;
	    -- notification framework end
	END IF; /* code set is pack H or higher */
	/* jolin end*/

         -- delete lot serial records for this line set
         DELETE FROM oe_lot_serial_numbers
	  WHERE line_set_id = l_line_rec.line_set_id;

       ELSE  -- there are other lines in this line set, keep lot/serial numbers
         NULL;

       END IF;
     END IF; -- return_line

   ELSE -- no line_id
      DELETE  FROM OE_LOT_SERIAL_NUMBERS
	WHERE   LOT_SERIAL_ID = p_lot_serial_id;

  END IF; -- line_id or lot_serial_id

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Procedure Query_Row

PROCEDURE Query_Row
(   p_lot_serial_id                 IN  NUMBER
,   x_lot_serial_rec                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
)
IS
l_lot_serial_tbl  OE_Order_PUB.Lot_Serial_Tbl_Type;
BEGIN

     Query_Rows
        (   p_lot_serial_id               => p_lot_serial_id
           ,x_lot_serial_tbl => l_lot_serial_tbl
        );
     x_lot_serial_rec := l_lot_serial_tbl(1);

END Query_Row;

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
)
IS
l_Lot_Serial_rec              OE_Order_PUB.Lot_Serial_Rec_Type;
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_line_id                     NUMBER := p_line_id;
l_line_set_id                 NUMBER := p_line_set_id;
l_count                         NUMBER;  --6052770
CURSOR l_Lot_Serial_csr IS
    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       FROM_SERIAL_NUMBER
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       LOT_NUMBER
  --  ,       SUBLOT_NUMBER    --OPM 2380194    INVCONV
    ,       LOT_SERIAL_ID
    ,       QUANTITY
    ,       QUANTITY2    --OPM 2380194
    ,       TO_SERIAL_NUMBER
    ,       LINE_SET_ID
    ,       LOCK_CONTROL
    FROM    OE_LOT_SERIAL_NUMBERS
    WHERE ( LOT_SERIAL_ID = p_lot_serial_id
    )
    OR (    LINE_ID = l_line_id
    )
    OR (    LINE_SET_ID = l_line_set_id
    );

BEGIN

    IF
    (p_lot_serial_id IS NOT NULL
     AND
     p_lot_serial_id <> FND_API.G_MISS_NUM)
    AND
    (p_line_id IS NOT NULL
     AND
     p_line_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: lot_serial_id = '|| p_lot_serial_id || ', line_id = '|| p_line_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    IF
    (p_lot_serial_id IS NOT NULL
     AND
     p_lot_serial_id <> FND_API.G_MISS_NUM)
    AND
    (p_line_set_id IS NOT NULL
     AND
     p_line_set_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: lot_serial_id = '|| p_lot_serial_id || ', line_set_id = '|| p_line_set_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    IF
    (p_line_set_id IS NOT NULL
     AND
     p_line_set_id <> FND_API.G_MISS_NUM)
    AND
    (p_line_id IS NOT NULL
     AND
     p_line_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: line_set_id = '|| p_line_set_id ||', line_id = '|| p_line_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    /* After a return line is split, lot serial numbers attach to the
       whole line set, so check if this line belongs to a line set
       and if yes, query by line set */
    IF
    (p_line_id IS NOT NULL
     AND
     p_line_id <> FND_API.G_MISS_NUM)
    THEN

      -- find line set id and query by line set id
      OE_LINE_UTIL.QUERY_ROW(p_line_id=>p_line_id,x_line_rec=>l_line_rec);

      IF
      (l_line_rec.line_set_id IS NOT NULL
      AND
       l_line_rec.line_set_id <> FND_API.G_MISS_NUM)
      THEN
        l_line_set_id := l_line_rec.line_set_id;
        l_line_id := FND_API.G_MISS_NUM;
      END IF;

    END IF;

    --  Loop over fetched records

    l_count := 1; --6052770
    FOR l_implicit_rec IN l_Lot_Serial_csr LOOP

/*6052770
        l_Lot_Serial_rec.attribute1    := l_implicit_rec.ATTRIBUTE1;
        l_Lot_Serial_rec.attribute10   := l_implicit_rec.ATTRIBUTE10;
        l_Lot_Serial_rec.attribute11   := l_implicit_rec.ATTRIBUTE11;
        l_Lot_Serial_rec.attribute12   := l_implicit_rec.ATTRIBUTE12;
        l_Lot_Serial_rec.attribute13   := l_implicit_rec.ATTRIBUTE13;
        l_Lot_Serial_rec.attribute14   := l_implicit_rec.ATTRIBUTE14;
        l_Lot_Serial_rec.attribute15   := l_implicit_rec.ATTRIBUTE15;
        l_Lot_Serial_rec.attribute2    := l_implicit_rec.ATTRIBUTE2;
        l_Lot_Serial_rec.attribute3    := l_implicit_rec.ATTRIBUTE3;
        l_Lot_Serial_rec.attribute4    := l_implicit_rec.ATTRIBUTE4;
        l_Lot_Serial_rec.attribute5    := l_implicit_rec.ATTRIBUTE5;
        l_Lot_Serial_rec.attribute6    := l_implicit_rec.ATTRIBUTE6;
        l_Lot_Serial_rec.attribute7    := l_implicit_rec.ATTRIBUTE7;
        l_Lot_Serial_rec.attribute8    := l_implicit_rec.ATTRIBUTE8;
        l_Lot_Serial_rec.attribute9    := l_implicit_rec.ATTRIBUTE9;
        l_Lot_Serial_rec.context       := l_implicit_rec.CONTEXT;
        l_Lot_Serial_rec.created_by    := l_implicit_rec.CREATED_BY;
        l_Lot_Serial_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_Lot_Serial_rec.from_serial_number := l_implicit_rec.FROM_SERIAL_NUMBER;
        l_Lot_Serial_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_Lot_Serial_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_Lot_Serial_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_Lot_Serial_rec.line_id       := l_implicit_rec.LINE_ID;
        l_Lot_Serial_rec.lot_number    := l_implicit_rec.LOT_NUMBER;
--        l_Lot_Serial_rec.sublot_number    := l_implicit_rec.SUBLOT_NUMBER; --OPM 2380194 INVCONV
        l_Lot_Serial_rec.lot_serial_id := l_implicit_rec.LOT_SERIAL_ID;
        l_Lot_Serial_rec.quantity      := l_implicit_rec.QUANTITY;
        l_Lot_Serial_rec.quantity2      := l_implicit_rec.QUANTITY2;  --OPM 2380194
        l_Lot_Serial_rec.to_serial_number := l_implicit_rec.TO_SERIAL_NUMBER;
        l_Lot_Serial_rec.line_set_id   := l_implicit_rec.LINE_SET_ID;
        l_Lot_Serial_rec.lock_control  := l_implicit_rec.LOCK_CONTROL;
        x_Lot_Serial_tbl(x_Lot_Serial_tbl.COUNT + 1) := l_Lot_Serial_rec;
6052770*/

/*6052770*/

        x_Lot_Serial_tbl(l_count).attribute1    := l_implicit_rec.ATTRIBUTE1;
        x_Lot_Serial_tbl(l_count).attribute10   := l_implicit_rec.ATTRIBUTE10;
        x_Lot_Serial_tbl(l_count).attribute11   := l_implicit_rec.ATTRIBUTE11;
        x_Lot_Serial_tbl(l_count).attribute12   := l_implicit_rec.ATTRIBUTE12;
        x_Lot_Serial_tbl(l_count).attribute13   := l_implicit_rec.ATTRIBUTE13;
        x_Lot_Serial_tbl(l_count).attribute14   := l_implicit_rec.ATTRIBUTE14;
        x_Lot_Serial_tbl(l_count).attribute15   := l_implicit_rec.ATTRIBUTE15;
        x_Lot_Serial_tbl(l_count).attribute2    := l_implicit_rec.ATTRIBUTE2;
        x_Lot_Serial_tbl(l_count).attribute3    := l_implicit_rec.ATTRIBUTE3;
        x_Lot_Serial_tbl(l_count).attribute4    := l_implicit_rec.ATTRIBUTE4;
        x_Lot_Serial_tbl(l_count).attribute5    := l_implicit_rec.ATTRIBUTE5;
        x_Lot_Serial_tbl(l_count).attribute6    := l_implicit_rec.ATTRIBUTE6;
        x_Lot_Serial_tbl(l_count).attribute7    := l_implicit_rec.ATTRIBUTE7;
        x_Lot_Serial_tbl(l_count).attribute8    := l_implicit_rec.ATTRIBUTE8;
        x_Lot_Serial_tbl(l_count).attribute9    := l_implicit_rec.ATTRIBUTE9;
        x_Lot_Serial_tbl(l_count).context       := l_implicit_rec.CONTEXT;
        x_Lot_Serial_tbl(l_count).created_by    := l_implicit_rec.CREATED_BY;
        x_Lot_Serial_tbl(l_count).creation_date := l_implicit_rec.CREATION_DATE;
        x_Lot_Serial_tbl(l_count).from_serial_number := l_implicit_rec.FROM_SERIAL_NUMBER;
        x_Lot_Serial_tbl(l_count).last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        x_Lot_Serial_tbl(l_count).last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        x_Lot_Serial_tbl(l_count).last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        x_Lot_Serial_tbl(l_count).line_id       := l_implicit_rec.LINE_ID;
        x_Lot_Serial_tbl(l_count).lot_number    := l_implicit_rec.LOT_NUMBER;
        x_Lot_Serial_tbl(l_count).lot_serial_id := l_implicit_rec.LOT_SERIAL_ID;
        x_Lot_Serial_tbl(l_count).quantity      := l_implicit_rec.QUANTITY;
        x_Lot_Serial_tbl(l_count).to_serial_number := l_implicit_rec.TO_SERIAL_NUMBER;
        x_Lot_Serial_tbl(l_count).line_set_id   := l_implicit_rec.LINE_SET_ID;
        x_Lot_Serial_tbl(l_count).lock_control  := l_implicit_rec.LOCK_CONTROL;

        l_count := l_count + 1;

/*6052770*/


    END LOOP;


    --  PK sent and no rows found

    IF
    (p_lot_serial_id IS NOT NULL
     AND
     p_lot_serial_id <> FND_API.G_MISS_NUM)
    AND
    (x_Lot_Serial_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_lot_serial_id                 IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Lot_Serial_rec              IN  OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
)
IS

l_lot_serial_id             NUMBER;
l_lock_control                NUMBER;
BEGIN

    oe_debug_pub.add('Entering OE_LOT_SERIAL_UTIL.LOCK_ROW', 1);

    SAVEPOINT Lock_Row;

    l_lock_control := NULL;

    -- Retrieve the primary key.
    IF p_lot_serial_id <> FND_API.G_MISS_NUM THEN
        l_lot_serial_id := p_lot_serial_id;
    ELSE
        l_lot_serial_id   := p_x_Lot_Serial_rec.lot_serial_id;
        l_lock_control    := p_x_Lot_Serial_rec.lock_control;
    END IF;

   SELECT  lot_serial_id
    INTO   l_lot_serial_id
    FROM   oe_lot_serial_numbers
    WHERE  lot_serial_id = l_lot_serial_id
    FOR UPDATE NOWAIT;

    oe_debug_pub.add('selected for update', 1);

    OE_Lot_serial_Util.Query_Row
	(p_lot_serial_id  => l_lot_serial_id
	,x_lot_serial_rec => p_x_lot_serial_rec );


    -- If lock_control is passed, then return the locked record.
    IF l_lock_control is NULL OR
       l_lock_control <> FND_API.G_MISS_NUM THEN

        --  Set return status
        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_lot_serial_rec.return_status       := FND_API.G_RET_STS_SUCCESS;

        RETURN;

    END IF;

    --  Row locked. If the whole record is passed, then
    --  Compare IN attributes to DB attributes.

    IF  OE_GLOBALS.Equal(p_x_lot_serial_rec.lock_control,
                         l_lock_control)
    THEN

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_lot_serial_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_lot_serial_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            -- Release the lock
	    ROLLBACK TO Lock_Row;

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_CHANGED');
            oe_msg_pub.Add;

        END IF;

    END IF;

    oe_debug_pub.add('Exiting OE_Lot_serial_UTIL.LOCK_ROW', 1);

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Lot_Serial_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Lot_Serial_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        p_x_Lot_Serial_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;


PROCEDURE Lock_Rows
(   p_lot_serial_id           IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                   IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_lot_serial_tbl          OUT NOCOPY OE_Order_PUB.Lot_serial_Tbl_Type
,   x_return_status             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 )
IS
  CURSOR lock_lot_serial(p_line_id  NUMBER) IS
  SELECT lot_serial_id
  FROM   oe_lot_serial_numbers
  WHERE  line_id = p_line_id
    FOR UPDATE NOWAIT;

  l_lot_serial_id    NUMBER;
BEGIN

    oe_debug_pub.add('entering oe_lot_serial_util.lock_rows', 1);

    IF (p_lot_serial_id IS NOT NULL AND
        p_lot_serial_id <> FND_API.G_MISS_NUM) AND
       (p_line_id IS NOT NULL AND
        p_line_id <> FND_API.G_MISS_NUM)
    THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
          , 'Lock Rows'
          , 'Keys are mutually exclusive: lot_serial_id = '||
             p_lot_serial_id || ', line_id = '|| p_line_id );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

   IF p_lot_serial_id <> FND_API.G_MISS_NUM THEN

     SELECT lot_serial_id
     INTO   l_lot_serial_id
     FROM   OE_LOT_SERIAL_NUMBERS
     WHERE  lot_serial_id   = p_lot_serial_id
     FOR UPDATE NOWAIT;

   END IF;

   -- people should not pass in null line_id unnecessarily,
   -- if they already passed in lot_serial_id.

   BEGIN

     IF p_line_id <> FND_API.G_MISS_NUM THEN

       SAVEPOINT LOCK_ROWS;
       OPEN lock_lot_serial(p_line_id);

       LOOP
         FETCH lock_lot_serial INTO l_lot_serial_id;
         EXIT WHEN lock_lot_serial%NOTFOUND;
       END LOOP;

       CLOSE lock_lot_serial;

     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK TO LOCK_ROWS;

       IF lock_lot_serial%ISOPEN THEN
         CLOSE lock_lot_serial;
       END IF;

       RAISE;
   END;

   -- locked all

   OE_Lot_serial_Util.Query_Rows
     (p_lot_serial_id          => p_lot_serial_id
     ,p_line_id                  => p_line_id
     ,x_lot_serial_tbl         => x_lot_serial_tbl
     );

   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   oe_debug_pub.add('exiting oe_lot_serial_util.lock_rows', 1);

EXCEPTION
   WHEN NO_DATA_FOUND THEN

     x_return_status                := FND_API.G_RET_STS_ERROR;

     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
       fnd_message.set_name('ONT','OE_LOCK_ROW_DELETED');
       OE_MSG_PUB.Add;
     END IF;

    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

      x_return_status                := FND_API.G_RET_STS_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        fnd_message.set_name('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
        OE_MSG_PUB.Add;
      END IF;

    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
         ,   'Lock_Rows'
        );
      END IF;

END Lock_Rows;


--  Function Get_Values

FUNCTION Get_Values
(   p_Lot_Serial_rec                IN  OE_Order_PUB.Lot_Serial_Rec_Type
,   p_old_Lot_Serial_rec            IN  OE_Order_PUB.Lot_Serial_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_REC
) RETURN OE_Order_PUB.Lot_Serial_Val_Rec_Type
IS
l_Lot_Serial_val_rec          OE_Order_PUB.Lot_Serial_Val_Rec_Type;
BEGIN

    NULL;

    RETURN l_Lot_Serial_val_rec;

END Get_Values;

--  Function Get_Ids

PROCEDURE Get_Ids
(   p_x_Lot_Serial_rec              IN OUT NOCOPY  OE_Order_PUB.Lot_Serial_Rec_Type
,   p_Lot_Serial_val_rec            IN  OE_Order_PUB.Lot_Serial_Val_Rec_Type
)
IS
BEGIN

    --  initialize  return_status.

    p_x_Lot_Serial_rec.return_status := FND_API.G_RET_STS_SUCCESS;

END Get_Ids;

END OE_Lot_Serial_Util;

/
