--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_HEADER_PATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_HEADER_PATTR" AS
/* $Header: OEXDHPAB.pls 120.0.12000000.3 2007/04/27 09:05:06 jisingh ship $ */

--  Global constant holding the package name

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'OE_Default_Header_Pattr';

--  Package global used within the package.

g_Header_price_att_rec      OE_Order_PUB.Header_Price_Att_Rec_Type;

--  Get functions.

FUNCTION Get_Flex_Title
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Flex_Title;

FUNCTION Get_Override_Flag
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Override_Flag;

FUNCTION Get_Header
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Header;

FUNCTION Get_Line
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Line;

FUNCTION Get_Order_Price_Attrib
RETURN NUMBER
IS
l_order_price_attrib_id NUMBER;
BEGIN

	SELECT OE_ORDER_PRICE_ATTRIBS_S.nextval INTO
	l_order_price_attrib_id
	FROM	DUAL;

    RETURN l_order_price_attrib_id;

EXCEPTION

 WHEN OTHERS THEN

  IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    OE_MSG_PUB.Add_Exc_Msg
	(    G_PKG_NAME          ,
	 'Get_Price_Attrib'
	 );
  END IF;

  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Order_Price_Attrib;

FUNCTION Get_Pricing_Attribute100
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute100;

FUNCTION Get_Pricing_Attribute11
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute11;

FUNCTION Get_Pricing_Attribute12
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute12;

FUNCTION Get_Pricing_Attribute13
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute13;

FUNCTION Get_Pricing_Attribute14
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute14;

FUNCTION Get_Pricing_Attribute15
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute15;

FUNCTION Get_Pricing_Attribute16
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute16;

FUNCTION Get_Pricing_Attribute17
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute17;

FUNCTION Get_Pricing_Attribute18
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute18;

FUNCTION Get_Pricing_Attribute19
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute19;

FUNCTION Get_Pricing_Attribute20
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute20;

FUNCTION Get_Pricing_Attribute21
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute21;

FUNCTION Get_Pricing_Attribute22
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute22;

FUNCTION Get_Pricing_Attribute23
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute23;

FUNCTION Get_Pricing_Attribute24
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute24;

FUNCTION Get_Pricing_Attribute25
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute25;

FUNCTION Get_Pricing_Attribute26
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute26;

FUNCTION Get_Pricing_Attribute27
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute27;

FUNCTION Get_Pricing_Attribute28
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute28;

FUNCTION Get_Pricing_Attribute29
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute29;

FUNCTION Get_Pricing_Attribute30
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute30;

FUNCTION Get_Pricing_Attribute31
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute31;

FUNCTION Get_Pricing_Attribute32
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute32;

FUNCTION Get_Pricing_Attribute33
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute33;

FUNCTION Get_Pricing_Attribute34
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute34;

FUNCTION Get_Pricing_Attribute35
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute35;

FUNCTION Get_Pricing_Attribute36
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute36;

FUNCTION Get_Pricing_Attribute37
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute37;

FUNCTION Get_Pricing_Attribute38
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute38;

FUNCTION Get_Pricing_Attribute39
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute39;

FUNCTION Get_Pricing_Attribute40
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute40;

FUNCTION Get_Pricing_Attribute41
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute41;

FUNCTION Get_Pricing_Attribute42
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute42;

FUNCTION Get_Pricing_Attribute43
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute43;

FUNCTION Get_Pricing_Attribute44
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute44;

FUNCTION Get_Pricing_Attribute45
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute45;

FUNCTION Get_Pricing_Attribute46
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute46;

FUNCTION Get_Pricing_Attribute47
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute47;

FUNCTION Get_Pricing_Attribute48
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute48;

FUNCTION Get_Pricing_Attribute49
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute49;

FUNCTION Get_Pricing_Attribute50
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute50;

FUNCTION Get_Pricing_Attribute51
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute51;

FUNCTION Get_Pricing_Attribute52
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute52;

FUNCTION Get_Pricing_Attribute53
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute53;

FUNCTION Get_Pricing_Attribute54
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute54;

FUNCTION Get_Pricing_Attribute55
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute55;

FUNCTION Get_Pricing_Attribute56
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute56;

FUNCTION Get_Pricing_Attribute57
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute57;

FUNCTION Get_Pricing_Attribute58
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute58;

FUNCTION Get_Pricing_Attribute59
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute59;

FUNCTION Get_Pricing_Attribute60
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute60;

FUNCTION Get_Pricing_Attribute61
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute61;

FUNCTION Get_Pricing_Attribute62
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute62;

FUNCTION Get_Pricing_Attribute63
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute63;

FUNCTION Get_Pricing_Attribute64
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute64;

FUNCTION Get_Pricing_Attribute65
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute65;

FUNCTION Get_Pricing_Attribute66
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute66;

FUNCTION Get_Pricing_Attribute67
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute67;

FUNCTION Get_Pricing_Attribute68
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute68;

FUNCTION Get_Pricing_Attribute69
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute69;

FUNCTION Get_Pricing_Attribute70
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute70;

FUNCTION Get_Pricing_Attribute71
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute71;

FUNCTION Get_Pricing_Attribute72
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute72;

FUNCTION Get_Pricing_Attribute73
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute73;

FUNCTION Get_Pricing_Attribute74
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute74;

FUNCTION Get_Pricing_Attribute75
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute75;

FUNCTION Get_Pricing_Attribute76
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute76;

FUNCTION Get_Pricing_Attribute77
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute77;

FUNCTION Get_Pricing_Attribute78
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute78;

FUNCTION Get_Pricing_Attribute79
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute79;

FUNCTION Get_Pricing_Attribute80
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute80;

FUNCTION Get_Pricing_Attribute81
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute81;

FUNCTION Get_Pricing_Attribute82
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute82;

FUNCTION Get_Pricing_Attribute83
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute83;

FUNCTION Get_Pricing_Attribute84
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute84;

FUNCTION Get_Pricing_Attribute85
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute85;

FUNCTION Get_Pricing_Attribute86
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute86;

FUNCTION Get_Pricing_Attribute87
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute87;

FUNCTION Get_Pricing_Attribute88
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute88;

FUNCTION Get_Pricing_Attribute89
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute89;

FUNCTION Get_Pricing_Attribute90
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute90;

FUNCTION Get_Pricing_Attribute91
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute91;

FUNCTION Get_Pricing_Attribute92
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute92;

FUNCTION Get_Pricing_Attribute93
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute93;

FUNCTION Get_Pricing_Attribute94
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute94;

FUNCTION Get_Pricing_Attribute95
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute95;

FUNCTION Get_Pricing_Attribute96
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute96;

FUNCTION Get_Pricing_Attribute97
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute97;

FUNCTION Get_Pricing_Attribute98
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute98;

FUNCTION Get_Pricing_Attribute99
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute99;


PROCEDURE Get_Flex_Header_Pattr
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_header_price_att_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute1 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute10 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute11 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute12 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute13 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute14 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute15 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute2 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute3 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute4 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute5 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute6 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute7 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute8 := NULL;
    END IF;

    IF g_header_price_att_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.attribute9 := NULL;
    END IF;

    IF g_header_price_att_rec.context = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.context := NULL;
    END IF;

END Get_Flex_Header_Pattr;

PROCEDURE Get_Flex_Pricing
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_header_price_att_rec.pricing_attribute1 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute1 := NULL;
    END IF;

    IF g_header_price_att_rec.pricing_attribute10 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute10 := NULL;
    END IF;

    IF g_header_price_att_rec.pricing_attribute2 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute2 := NULL;
    END IF;

    IF g_header_price_att_rec.pricing_attribute3 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute3 := NULL;
    END IF;

    IF g_header_price_att_rec.pricing_attribute4 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute4 := NULL;
    END IF;

    IF g_header_price_att_rec.pricing_attribute5 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute5 := NULL;
    END IF;

    IF g_header_price_att_rec.pricing_attribute6 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute6 := NULL;
    END IF;

    IF g_header_price_att_rec.pricing_attribute7 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute7 := NULL;
    END IF;

    IF g_header_price_att_rec.pricing_attribute8 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute8 := NULL;
    END IF;

    IF g_header_price_att_rec.pricing_attribute9 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute9 := NULL;
    END IF;

    IF g_header_price_att_rec.pricing_context = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_context := NULL;
    END IF;

    IF g_header_price_att_rec.pricing_attribute11 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute11 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute12 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute12 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute13 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute13 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute14 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute14 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute15 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute15 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute16 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute16 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute17 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute17 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute18 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute18 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute19 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute19 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute20 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute20 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute21 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute21 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute22 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute22 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute23 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute23 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute24 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute24 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute25 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute25 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute26 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute26 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute27 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute27 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute28 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute28 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute29 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute29 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute30 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute30 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute31 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute31 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute32 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute32 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute33 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute33 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute34 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute34 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute35 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute35 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute36 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute36 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute37 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute37 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute38 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute38 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute39 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute39 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute40 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute40 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute41 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute41 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute42 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute42 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute43 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute43 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute44 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute44 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute45 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute45 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute46 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute46 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute47 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute47 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute48 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute48 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute49 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute49 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute50 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute50 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute51 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute51 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute52 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute52 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute53 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute53 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute54 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute54 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute55 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute55 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute56 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute56 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute57 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute57 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute58 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute58 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute59 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute59 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute60 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute60 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute61 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute61 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute62 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute62 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute63 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute63 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute64 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute64 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute65 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute65 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute66 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute66 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute67 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute67 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute69 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute69 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute70 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute70 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute71 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute71 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute72 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute72 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute73 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute73 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute74 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute74 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute75 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute75 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute76 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute76 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute77 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute77 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute78 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute78 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute79 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute79 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute80 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute80 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute81 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute81 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute82 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute82 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute83 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute83 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute84 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute84 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute85 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute85 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute86 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute86 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute87 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute87 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute88 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute88 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute89 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute89 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute90 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute90 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute91 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute91 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute92 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute92 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute93 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute93 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute94 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute94 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute95 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute95 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute96 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute96 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute97 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute97 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute98 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute98 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute99 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute99 := NULL;
    END IF;
    IF g_header_price_att_rec.pricing_attribute100 = FND_API.G_MISS_CHAR THEN
        g_header_price_att_rec.pricing_attribute100 := NULL;
    END IF;

END Get_Flex_Pricing;

--  Procedure Attributes

PROCEDURE Attributes
( p_x_header_Price_att_rec	IN OUT NOCOPY	OE_Order_PUB.Header_Price_Att_Rec_Type
--	 := OE_Order_PUB.G_MISS_Header_PRICE_ATT_REC
,   p_iteration               IN  NUMBER := 1
-- , x_Header_Price_Att_rec	OUT 	OE_Order_PUB.Header_Price_Att_Rec_Type
)
IS
BEGIN

    --  Check number of iterations.

    IF p_iteration > OE_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_DEF_MAX_ITERATION');
            FND_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_header_price_att_rec

    g_header_price_att_rec := p_x_header_Price_att_rec;

--    g_header_price_att_rec := p_header_Price_att_rec;


    --  Default missing attributes.

    IF g_header_price_att_rec.flex_title = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.flex_title := Get_Flex_Title;

        IF g_header_price_att_rec.flex_title IS NOT NULL THEN

            IF oe_validate_adj.Flex_Title(g_header_price_att_rec.flex_title)
            THEN
                OE_Header_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id       => OE_Header_PAttr_Util.G_FLEX_TITLE
                ,   p_x_header_Price_att_rec      => g_header_price_att_rec
           --     ,   x_Header_Price_Att_rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.flex_title := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.header_id = FND_API.G_MISS_NUM THEN

        g_header_price_att_rec.header_id := Get_Header;

        IF g_header_price_att_rec.header_id IS NOT NULL THEN

            IF oe_validate_adj.Header(g_header_price_att_rec.header_id)
            THEN
                OE_Header_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                 => OE_Header_PAttr_Util.G_HEADER
                ,   p_x_header_Price_att_rec      => g_header_price_att_rec
              --  ,   x_Header_Price_Att_rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.line_id = FND_API.G_MISS_NUM THEN

        g_header_price_att_rec.line_id := Get_Line;

        IF g_header_price_att_rec.line_id IS NOT NULL THEN

            IF oe_validate_adj.Line(g_header_price_att_rec.line_id)
            THEN
                OE_Header_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                  => OE_Header_PAttr_Util.G_LINE
                ,   p_x_header_Price_att_rec      => g_header_price_att_rec
              --  ,   x_Header_Price_Att_rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.line_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.order_price_attrib_id = FND_API.G_MISS_NUM THEN

        g_header_price_att_rec.order_price_attrib_id := Get_Order_Price_Attrib;

        IF g_header_price_att_rec.order_price_attrib_id IS NOT NULL THEN

            IF oe_validate_adj.Order_Price_Attrib(g_header_price_att_rec.order_price_attrib_id)
            THEN
                OE_Header_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id       => OE_Header_PAttr_Util.G_ORDER_PRICE_ATTRIB
                ,   p_x_header_Price_att_rec      => g_header_price_att_rec
             --   ,   x_Header_Price_Att_rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.order_price_attrib_id := NULL;
            END IF;

        END IF;

    END IF;

--

    IF g_header_price_att_rec.Override_Flag = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.Override_Flag := Get_Override_Flag;

        IF g_header_price_att_rec.Override_Flag IS NOT NULL THEN

            IF oe_validate_adj.Override_Flag(g_header_price_att_rec.Override_Flag)
            THEN
                OE_Header_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id       => OE_Header_PAttr_Util.G_OVERRIDE_FLAG
                ,   p_x_header_Price_att_rec      => g_header_price_att_rec
             --   ,   x_Header_Price_Att_rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.Override_Flag := NULL;
            END IF;

        END IF;

    END IF;





--

/*

    IF g_header_price_att_rec.pricing_attribute100 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute100 := Get_Pricing_Attribute100;

        IF g_header_price_att_rec.pricing_attribute100 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute100(g_header_price_att_rec.pricing_attribute100)
            THEN
                OE_Header_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id     => OE_Header_PAttr_Util.G_PRICING_ATTRIBUTE100
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute100 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute11 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute11 := Get_Pricing_Attribute11;

        IF g_header_price_att_rec.pricing_attribute11 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute11(g_header_price_att_rec.pricing_attribute11)
            THEN
                OE_Header_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_PAttr_Util.G_PRICING_ATTRIBUTE11
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute11 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute12 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute12 := Get_Pricing_Attribute12;

        IF g_header_price_att_rec.pricing_attribute12 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute12(g_header_price_att_rec.pricing_attribute12)
            THEN
                OE_Header_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE12
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute12 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute13 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute13 := Get_Pricing_Attribute13;

        IF g_header_price_att_rec.pricing_attribute13 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute13(g_header_price_att_rec.pricing_attribute13)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE13
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute13 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute14 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute14 := Get_Pricing_Attribute14;

        IF g_header_price_att_rec.pricing_attribute14 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute14(g_header_price_att_rec.pricing_attribute14)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE14
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute14 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute15 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute15 := Get_Pricing_Attribute15;

        IF g_header_price_att_rec.pricing_attribute15 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute15(g_header_price_att_rec.pricing_attribute15)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE15
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute15 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute16 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute16 := Get_Pricing_Attribute16;

        IF g_header_price_att_rec.pricing_attribute16 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute16(g_header_price_att_rec.pricing_attribute16)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE16
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute16 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute17 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute17 := Get_Pricing_Attribute17;

        IF g_header_price_att_rec.pricing_attribute17 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute17(g_header_price_att_rec.pricing_attribute17)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE17
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute17 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute18 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute18 := Get_Pricing_Attribute18;

        IF g_header_price_att_rec.pricing_attribute18 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute18(g_header_price_att_rec.pricing_attribute18)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE18
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute18 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute19 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute19 := Get_Pricing_Attribute19;

        IF g_header_price_att_rec.pricing_attribute19 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute19(g_header_price_att_rec.pricing_attribute19)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE19
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute19 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute20 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute20 := Get_Pricing_Attribute20;

        IF g_header_price_att_rec.pricing_attribute20 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute20(g_header_price_att_rec.pricing_attribute20)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE20
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute20 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute21 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute21 := Get_Pricing_Attribute21;

        IF g_header_price_att_rec.pricing_attribute21 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute21(g_header_price_att_rec.pricing_attribute21)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE21
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute21 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute22 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute22 := Get_Pricing_Attribute22;

        IF g_header_price_att_rec.pricing_attribute22 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute22(g_header_price_att_rec.pricing_attribute22)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE22
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute22 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute23 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute23 := Get_Pricing_Attribute23;

        IF g_header_price_att_rec.pricing_attribute23 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute23(g_header_price_att_rec.pricing_attribute23)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE23
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute23 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute24 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute24 := Get_Pricing_Attribute24;

        IF g_header_price_att_rec.pricing_attribute24 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute24(g_header_price_att_rec.pricing_attribute24)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE24
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute24 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute25 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute25 := Get_Pricing_Attribute25;

        IF g_header_price_att_rec.pricing_attribute25 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute25(g_header_price_att_rec.pricing_attribute25)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE25
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute25 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute26 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute26 := Get_Pricing_Attribute26;

        IF g_header_price_att_rec.pricing_attribute26 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute26(g_header_price_att_rec.pricing_attribute26)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE26
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute26 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute27 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute27 := Get_Pricing_Attribute27;

        IF g_header_price_att_rec.pricing_attribute27 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute27(g_header_price_att_rec.pricing_attribute27)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE27
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute27 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute28 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute28 := Get_Pricing_Attribute28;

        IF g_header_price_att_rec.pricing_attribute28 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute28(g_header_price_att_rec.pricing_attribute28)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE28
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute28 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute29 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute29 := Get_Pricing_Attribute29;

        IF g_header_price_att_rec.pricing_attribute29 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute29(g_header_price_att_rec.pricing_attribute29)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE29
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute29 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute30 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute30 := Get_Pricing_Attribute30;

        IF g_header_price_att_rec.pricing_attribute30 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute30(g_header_price_att_rec.pricing_attribute30)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE30
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute30 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute31 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute31 := Get_Pricing_Attribute31;

        IF g_header_price_att_rec.pricing_attribute31 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute31(g_header_price_att_rec.pricing_attribute31)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE31
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute31 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute32 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute32 := Get_Pricing_Attribute32;

        IF g_header_price_att_rec.pricing_attribute32 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute32(g_header_price_att_rec.pricing_attribute32)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE32
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute32 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute33 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute33 := Get_Pricing_Attribute33;

        IF g_header_price_att_rec.pricing_attribute33 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute33(g_header_price_att_rec.pricing_attribute33)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE33
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute33 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute34 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute34 := Get_Pricing_Attribute34;

        IF g_header_price_att_rec.pricing_attribute34 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute34(g_header_price_att_rec.pricing_attribute34)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE34
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute34 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute35 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute35 := Get_Pricing_Attribute35;

        IF g_header_price_att_rec.pricing_attribute35 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute35(g_header_price_att_rec.pricing_attribute35)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE35
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute35 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute36 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute36 := Get_Pricing_Attribute36;

        IF g_header_price_att_rec.pricing_attribute36 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute36(g_header_price_att_rec.pricing_attribute36)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE36
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute36 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute37 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute37 := Get_Pricing_Attribute37;

        IF g_header_price_att_rec.pricing_attribute37 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute37(g_header_price_att_rec.pricing_attribute37)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE37
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute37 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute38 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute38 := Get_Pricing_Attribute38;

        IF g_header_price_att_rec.pricing_attribute38 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute38(g_header_price_att_rec.pricing_attribute38)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE38
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute38 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute39 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute39 := Get_Pricing_Attribute39;

        IF g_header_price_att_rec.pricing_attribute39 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute39(g_header_price_att_rec.pricing_attribute39)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE39
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute39 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute40 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute40 := Get_Pricing_Attribute40;

        IF g_header_price_att_rec.pricing_attribute40 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute40(g_header_price_att_rec.pricing_attribute40)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE40
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute40 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute41 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute41 := Get_Pricing_Attribute41;

        IF g_header_price_att_rec.pricing_attribute41 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute41(g_header_price_att_rec.pricing_attribute41)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE41
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute41 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute42 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute42 := Get_Pricing_Attribute42;

        IF g_header_price_att_rec.pricing_attribute42 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute42(g_header_price_att_rec.pricing_attribute42)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE42
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute42 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute43 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute43 := Get_Pricing_Attribute43;

        IF g_header_price_att_rec.pricing_attribute43 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute43(g_header_price_att_rec.pricing_attribute43)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE43
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute43 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute44 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute44 := Get_Pricing_Attribute44;

        IF g_header_price_att_rec.pricing_attribute44 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute44(g_header_price_att_rec.pricing_attribute44)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE44
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute44 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute45 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute45 := Get_Pricing_Attribute45;

        IF g_header_price_att_rec.pricing_attribute45 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute45(g_header_price_att_rec.pricing_attribute45)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE45
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute45 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute46 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute46 := Get_Pricing_Attribute46;

        IF g_header_price_att_rec.pricing_attribute46 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute46(g_header_price_att_rec.pricing_attribute46)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE46
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute46 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute47 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute47 := Get_Pricing_Attribute47;

        IF g_header_price_att_rec.pricing_attribute47 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute47(g_header_price_att_rec.pricing_attribute47)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE47
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute47 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute48 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute48 := Get_Pricing_Attribute48;

        IF g_header_price_att_rec.pricing_attribute48 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute48(g_header_price_att_rec.pricing_attribute48)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE48
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute48 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute49 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute49 := Get_Pricing_Attribute49;

        IF g_header_price_att_rec.pricing_attribute49 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute49(g_header_price_att_rec.pricing_attribute49)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE49
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute49 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute50 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute50 := Get_Pricing_Attribute50;

        IF g_header_price_att_rec.pricing_attribute50 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute50(g_header_price_att_rec.pricing_attribute50)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE50
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute50 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute51 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute51 := Get_Pricing_Attribute51;

        IF g_header_price_att_rec.pricing_attribute51 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute51(g_header_price_att_rec.pricing_attribute51)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE51
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute51 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute52 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute52 := Get_Pricing_Attribute52;

        IF g_header_price_att_rec.pricing_attribute52 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute52(g_header_price_att_rec.pricing_attribute52)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE52
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute52 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute53 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute53 := Get_Pricing_Attribute53;

        IF g_header_price_att_rec.pricing_attribute53 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute53(g_header_price_att_rec.pricing_attribute53)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE53
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute53 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute54 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute54 := Get_Pricing_Attribute54;

        IF g_header_price_att_rec.pricing_attribute54 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute54(g_header_price_att_rec.pricing_attribute54)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE54
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute54 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute55 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute55 := Get_Pricing_Attribute55;

        IF g_header_price_att_rec.pricing_attribute55 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute55(g_header_price_att_rec.pricing_attribute55)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE55
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute55 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute56 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute56 := Get_Pricing_Attribute56;

        IF g_header_price_att_rec.pricing_attribute56 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute56(g_header_price_att_rec.pricing_attribute56)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE56
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute56 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute57 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute57 := Get_Pricing_Attribute57;

        IF g_header_price_att_rec.pricing_attribute57 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute57(g_header_price_att_rec.pricing_attribute57)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE57
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute57 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute58 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute58 := Get_Pricing_Attribute58;

        IF g_header_price_att_rec.pricing_attribute58 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute58(g_header_price_att_rec.pricing_attribute58)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE58
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute58 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute59 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute59 := Get_Pricing_Attribute59;

        IF g_header_price_att_rec.pricing_attribute59 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute59(g_header_price_att_rec.pricing_attribute59)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE59
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute59 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute60 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute60 := Get_Pricing_Attribute60;

        IF g_header_price_att_rec.pricing_attribute60 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute60(g_header_price_att_rec.pricing_attribute60)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE60
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute60 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute61 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute61 := Get_Pricing_Attribute61;

        IF g_header_price_att_rec.pricing_attribute61 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute61(g_header_price_att_rec.pricing_attribute61)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE61
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute61 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute62 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute62 := Get_Pricing_Attribute62;

        IF g_header_price_att_rec.pricing_attribute62 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute62(g_header_price_att_rec.pricing_attribute62)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE62
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute62 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute63 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute63 := Get_Pricing_Attribute63;

        IF g_header_price_att_rec.pricing_attribute63 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute63(g_header_price_att_rec.pricing_attribute63)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE63
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute63 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute64 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute64 := Get_Pricing_Attribute64;

        IF g_header_price_att_rec.pricing_attribute64 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute64(g_header_price_att_rec.pricing_attribute64)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE64
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute64 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute65 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute65 := Get_Pricing_Attribute65;

        IF g_header_price_att_rec.pricing_attribute65 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute65(g_header_price_att_rec.pricing_attribute65)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE65
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute65 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute66 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute66 := Get_Pricing_Attribute66;

        IF g_header_price_att_rec.pricing_attribute66 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute66(g_header_price_att_rec.pricing_attribute66)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE66
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute66 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute67 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute67 := Get_Pricing_Attribute67;

        IF g_header_price_att_rec.pricing_attribute67 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute67(g_header_price_att_rec.pricing_attribute67)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE67
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute67 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute68 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute68 := Get_Pricing_Attribute68;

        IF g_header_price_att_rec.pricing_attribute68 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute68(g_header_price_att_rec.pricing_attribute68)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE68
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute68 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute69 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute69 := Get_Pricing_Attribute69;

        IF g_header_price_att_rec.pricing_attribute69 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute69(g_header_price_att_rec.pricing_attribute69)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE69
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute69 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute70 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute70 := Get_Pricing_Attribute70;

        IF g_header_price_att_rec.pricing_attribute70 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute70(g_header_price_att_rec.pricing_attribute70)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE70
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute70 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute71 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute71 := Get_Pricing_Attribute71;

        IF g_header_price_att_rec.pricing_attribute71 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute71(g_header_price_att_rec.pricing_attribute71)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE71
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute71 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute72 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute72 := Get_Pricing_Attribute72;

        IF g_header_price_att_rec.pricing_attribute72 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute72(g_header_price_att_rec.pricing_attribute72)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE72
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute72 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute73 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute73 := Get_Pricing_Attribute73;

        IF g_header_price_att_rec.pricing_attribute73 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute73(g_header_price_att_rec.pricing_attribute73)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE73
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute73 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute74 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute74 := Get_Pricing_Attribute74;

        IF g_header_price_att_rec.pricing_attribute74 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute74(g_header_price_att_rec.pricing_attribute74)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE74
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute74 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute75 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute75 := Get_Pricing_Attribute75;

        IF g_header_price_att_rec.pricing_attribute75 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute75(g_header_price_att_rec.pricing_attribute75)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE75
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute75 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute76 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute76 := Get_Pricing_Attribute76;

        IF g_header_price_att_rec.pricing_attribute76 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute76(g_header_price_att_rec.pricing_attribute76)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE76
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute76 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute77 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute77 := Get_Pricing_Attribute77;

        IF g_header_price_att_rec.pricing_attribute77 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute77(g_header_price_att_rec.pricing_attribute77)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE77
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute77 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute78 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute78 := Get_Pricing_Attribute78;

        IF g_header_price_att_rec.pricing_attribute78 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute78(g_header_price_att_rec.pricing_attribute78)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE78
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute78 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute79 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute79 := Get_Pricing_Attribute79;

        IF g_header_price_att_rec.pricing_attribute79 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute79(g_header_price_att_rec.pricing_attribute79)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE79
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute79 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute80 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute80 := Get_Pricing_Attribute80;

        IF g_header_price_att_rec.pricing_attribute80 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute80(g_header_price_att_rec.pricing_attribute80)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE80
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute80 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute81 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute81 := Get_Pricing_Attribute81;

        IF g_header_price_att_rec.pricing_attribute81 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute81(g_header_price_att_rec.pricing_attribute81)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE81
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute81 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute82 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute82 := Get_Pricing_Attribute82;

        IF g_header_price_att_rec.pricing_attribute82 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute82(g_header_price_att_rec.pricing_attribute82)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE82
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute82 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute83 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute83 := Get_Pricing_Attribute83;

        IF g_header_price_att_rec.pricing_attribute83 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute83(g_header_price_att_rec.pricing_attribute83)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE83
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute83 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute84 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute84 := Get_Pricing_Attribute84;

        IF g_header_price_att_rec.pricing_attribute84 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute84(g_header_price_att_rec.pricing_attribute84)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE84
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute84 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute85 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute85 := Get_Pricing_Attribute85;

        IF g_header_price_att_rec.pricing_attribute85 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute85(g_header_price_att_rec.pricing_attribute85)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE85
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute85 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute86 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute86 := Get_Pricing_Attribute86;

        IF g_header_price_att_rec.pricing_attribute86 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute86(g_header_price_att_rec.pricing_attribute86)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE86
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute86 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute87 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute87 := Get_Pricing_Attribute87;

        IF g_header_price_att_rec.pricing_attribute87 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute87(g_header_price_att_rec.pricing_attribute87)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE87
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute87 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute88 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute88 := Get_Pricing_Attribute88;

        IF g_header_price_att_rec.pricing_attribute88 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute88(g_header_price_att_rec.pricing_attribute88)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE88
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute88 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute89 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute89 := Get_Pricing_Attribute89;

        IF g_header_price_att_rec.pricing_attribute89 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute89(g_header_price_att_rec.pricing_attribute89)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE89
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute89 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute90 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute90 := Get_Pricing_Attribute90;

        IF g_header_price_att_rec.pricing_attribute90 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute90(g_header_price_att_rec.pricing_attribute90)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE90
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute90 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute91 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute91 := Get_Pricing_Attribute91;

        IF g_header_price_att_rec.pricing_attribute91 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute91(g_header_price_att_rec.pricing_attribute91)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE91
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute91 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute92 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute92 := Get_Pricing_Attribute92;

        IF g_header_price_att_rec.pricing_attribute92 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute92(g_header_price_att_rec.pricing_attribute92)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE92
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute92 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute93 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute93 := Get_Pricing_Attribute93;

        IF g_header_price_att_rec.pricing_attribute93 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute93(g_header_price_att_rec.pricing_attribute93)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE93
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute93 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute94 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute94 := Get_Pricing_Attribute94;

        IF g_header_price_att_rec.pricing_attribute94 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute94(g_header_price_att_rec.pricing_attribute94)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE94
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute94 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute95 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute95 := Get_Pricing_Attribute95;

        IF g_header_price_att_rec.pricing_attribute95 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute95(g_header_price_att_rec.pricing_attribute95)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE95
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute95 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute96 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute96 := Get_Pricing_Attribute96;

        IF g_header_price_att_rec.pricing_attribute96 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute96(g_header_price_att_rec.pricing_attribute96)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE96
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute96 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute97 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute97 := Get_Pricing_Attribute97;

        IF g_header_price_att_rec.pricing_attribute97 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute97(g_header_price_att_rec.pricing_attribute97)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE97
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute97 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute98 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute98 := Get_Pricing_Attribute98;

        IF g_header_price_att_rec.pricing_attribute98 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute98(g_header_price_att_rec.pricing_attribute98)
            THEN
                OE_Header_Pattr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE98
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_Rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute98 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_header_price_att_rec.pricing_attribute99 = FND_API.G_MISS_CHAR THEN

        g_header_price_att_rec.pricing_attribute99 := Get_Pricing_Attribute99;

        IF g_header_price_att_rec.pricing_attribute99 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute99(g_header_price_att_rec.pricing_attribute99)
            THEN
                OE_Header_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Header_Pattr_Util.G_PRICING_ATTRIBUTE99
                ,   p_header_Price_att_rec      => g_header_price_att_rec
                ,   x_Header_Price_Att_rec      => g_header_price_att_rec
                );
            ELSE
                g_header_price_att_rec.pricing_attribute99 := NULL;
            END IF;

        END IF;

    END IF;

*/
--  Code above commented



    IF g_header_price_att_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Header_Pattr;

    END IF;

    IF g_header_price_att_rec.pricing_attribute1 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute10 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute2 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute3 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute4 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute5 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute6 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute7 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute8 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute9 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute11 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute12 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute13 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute14 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute15 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute16 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute17 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute18 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute19 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute20 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute21 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute22 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute23 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute24 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute25 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute26 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute27 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute28 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute29 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute30 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute31 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute32 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute33 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute34 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute35 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute36 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute37 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute38 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute39 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute40 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute41 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute42 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute43 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute44 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute45 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute46 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute47 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute48 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute49 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute50 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute51 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute52 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute53 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute54 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute55 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute56 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute57 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute58 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute59 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute60 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute61 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute62 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute63 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute64 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute65 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute66 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute67 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute68 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute69 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute70 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute71 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute72 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute73 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute74 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute75 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute76 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute77 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute78 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute79 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute80 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute81 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute82 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute83 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute84 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute85 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute86 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute87 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute88 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute89 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute90 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute91 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute92 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute93 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute94 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute95 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute96 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute97 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute98 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute99 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute100 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Pricing;

    END IF;

    IF g_header_price_att_rec.created_by = FND_API.G_MISS_NUM THEN

        g_header_price_att_rec.created_by := NULL;

    END IF;


    IF g_header_price_att_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_header_price_att_rec.creation_date := sysdate;

    END IF;

    IF g_header_price_att_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_header_price_att_rec.last_updated_by := NULL;

    END IF;

    IF g_header_price_att_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_header_price_att_rec.last_update_date := NULL;

    END IF;

    IF g_header_price_att_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_header_price_att_rec.last_update_login := NULL;

    END IF;

    IF g_header_price_att_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_header_price_att_rec.program_application_id := NULL;

    END IF;

    IF g_header_price_att_rec.program_id = FND_API.G_MISS_NUM THEN

        g_header_price_att_rec.program_id := NULL;

    END IF;

    IF g_header_price_att_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_header_price_att_rec.program_update_date := NULL;

    END IF;

    IF g_header_price_att_rec.request_id = FND_API.G_MISS_NUM THEN

        g_header_price_att_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.
  /* commented for bug#5679839
    IF  g_header_price_att_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.context = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.created_by = FND_API.G_MISS_NUM
    OR  g_header_price_att_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_header_price_att_rec.flex_title = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.header_id = FND_API.G_MISS_NUM
    OR  g_header_price_att_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_header_price_att_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_header_price_att_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_header_price_att_rec.line_id = FND_API.G_MISS_NUM
    OR  g_header_price_att_rec.order_price_attrib_id = FND_API.G_MISS_NUM
    OR  g_header_price_att_rec.pricing_attribute1 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute10 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute100 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute11 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute12 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute13 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute14 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute15 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute16 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute17 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute18 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute19 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute2 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute20 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute21 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute22 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute23 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute24 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute25 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute26 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute27 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute28 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute29 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute3 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute30 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute31 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute32 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute33 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute34 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute35 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute36 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute37 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute38 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute39 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute4 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute40 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute41 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute42 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute43 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute44 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute45 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute46 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute47 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute48 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute49 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute5 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute50 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute51 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute52 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute53 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute54 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute55 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute56 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute57 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute58 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute59 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute6 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute60 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute61 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute62 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute63 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute64 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute65 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute66 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute67 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute68 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute69 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute7 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute70 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute71 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute72 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute73 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute74 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute75 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute76 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute77 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute78 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute79 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute8 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute80 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute81 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute82 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute83 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute84 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute85 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute86 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute87 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute88 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute89 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute9 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute90 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute91 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute92 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute93 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute94 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute95 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute96 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute97 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute98 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_attribute99 = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.pricing_context = FND_API.G_MISS_CHAR
    OR  g_header_price_att_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_header_price_att_rec.program_id = FND_API.G_MISS_NUM
    OR  g_header_price_att_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_header_price_att_rec.request_id = FND_API.G_MISS_NUM
    OR  g_header_price_att_rec.override_flag = FND_API.G_MISS_CHAR
    THEN

        OE_Default_header_pattr.Attributes
        (   p_x_Header_Price_Att_rec      => g_Header_Price_Att_rec
        ,   p_iteration                   => p_iteration + 1
    --    ,   x_Header_Price_Att_rec      => x_Header_Price_Att_rec
        );

    ELSE
    */
        --  Done defaulting attributes

        p_x_Header_Price_Att_rec := g_Header_Price_Att_rec;

  --  END IF;

END Attributes;

END OE_Default_Header_Pattr;

/
