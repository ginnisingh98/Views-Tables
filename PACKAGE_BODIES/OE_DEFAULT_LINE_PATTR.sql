--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_LINE_PATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_LINE_PATTR" AS
/* $Header: OEXDLPAB.pls 120.1 2006/05/23 05:48:54 aycui noship $ */

--  Global constant holding the package name

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'OE_Default_Line_Pattr';

--  Package global used within the package.

 -- g_Line_Price_Att_rec      OE_Order_PUB.Line_Pricing_Pattr_Rec_Type;

g_Line_Price_Att_rec      OE_Order_PUB.Line_Price_Att_Rec_Type;

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


PROCEDURE Get_Flex_Line_Pricing_Pattr
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_Line_Price_Att_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute1 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute10 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute11 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute12 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute13 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute14 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute15 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute2 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute3 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute4 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute5 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute6 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute7 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute8 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.attribute9 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.context = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.context := NULL;
    END IF;


    IF g_Line_Price_Att_rec.pricing_attribute11 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute11 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute12 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute12 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute13 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute13 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute14 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute14 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute15 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute15 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute16 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute16 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute17 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute17 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute18 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute18 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute19 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute19 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute20 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute20 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute21 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute21 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute22 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute22 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute23 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute23 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute24 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute24 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute25 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute25 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute26 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute26 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute27 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute27 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute28 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute28 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute29 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute29 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute30 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute30 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute31 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute31 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute32 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute32 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute33 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute33 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute34 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute34 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute35 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute35 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute36 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute36 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute37 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute37 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute38 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute38 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute39 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute39 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute40 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute40 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute41 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute41 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute42 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute42 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute43 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute43 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute44 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute44 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute45 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute45 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute46 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute46 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute47 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute47 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute48 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute48 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute49 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute49 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute50 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute50 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute51 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute51 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute52 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute52 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute53 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute53 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute54 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute54 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute55 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute55 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute56 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute56 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute57 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute57 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute58 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute58 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute59 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute59 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute60 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute60 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute61 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute61 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute62 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute62 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute63 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute63 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute64 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute64 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute65 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute65 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute66 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute66 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute67 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute67 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute69 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute69 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute70 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute70 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute71 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute71 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute72 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute72 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute73 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute73 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute74 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute74 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute75 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute75 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute76 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute76 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute77 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute77 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute78 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute78 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute79 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute79 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute80 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute80 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute81 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute81 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute82 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute82 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute83 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute83 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute84 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute84 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute85 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute85 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute86 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute86 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute87 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute87 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute88 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute88 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute89 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute89 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute90 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute90 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute91 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute91 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute92 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute92 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute93 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute93 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute94 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute94 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute95 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute95 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute96 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute96 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute97 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute97 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute98 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute98 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute99 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute99 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute100 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute100 := NULL;
    END IF;



END Get_Flex_Line_Pricing_Pattr;

PROCEDURE Get_Flex_Pricing
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_Line_Price_Att_rec.pricing_attribute1 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute1 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute10 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute10 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute2 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute2 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute3 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute3 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute4 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute4 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute5 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute5 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute6 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute6 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute7 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute7 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute8 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute8 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute9 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute9 := NULL;
    END IF;

    IF g_Line_Price_Att_rec.pricing_context = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_context := NULL;
    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute11 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute11 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute12 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute12 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute13 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute13 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute14 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute14 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute15 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute15 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute16 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute16 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute17 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute17 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute18 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute18 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute19 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute19 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute20 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute20 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute21 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute21 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute22 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute22 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute23 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute23 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute24 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute24 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute25 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute25 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute26 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute26 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute27 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute27 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute28 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute28 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute29 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute29 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute30 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute30 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute31 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute31 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute32 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute32 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute33 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute33 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute34 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute34 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute35 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute35 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute36 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute36 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute37 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute37 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute38 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute38 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute39 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute39 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute40 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute40 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute41 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute41 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute42 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute42 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute43 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute43 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute44 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute44 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute45 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute45 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute46 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute46 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute47 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute47 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute48 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute48 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute49 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute49 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute50 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute50 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute51 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute51 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute52 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute52 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute53 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute53 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute54 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute54 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute55 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute55 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute56 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute56 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute57 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute57 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute58 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute58 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute59 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute59 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute60 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute60 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute61 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute61 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute62 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute62 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute63 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute63 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute64 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute64 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute65 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute65 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute66 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute66 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute67 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute67 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute68 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute68 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute69 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute69 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute70 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute70 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute71 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute71 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute72 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute72 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute73 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute73 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute74 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute74 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute75 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute75 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute76 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute76 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute77 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute77 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute78 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute78 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute79 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute79 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute80 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute80 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute81 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute81 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute82 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute82 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute83 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute83 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute84 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute84 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute85 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute85 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute86 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute86 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute87 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute87 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute88 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute88 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute89 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute89 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute90 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute90 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute91 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute91 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute92 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute92 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute93 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute93 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute94 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute94 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute95 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute95 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute96 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute96 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute97 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute97 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute98 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute98 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute99 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute99 := NULL;
    END IF;
    IF g_Line_Price_Att_rec.pricing_attribute100 = FND_API.G_MISS_CHAR THEN
        g_Line_Price_Att_rec.pricing_attribute100 := NULL;
    END IF;



END Get_Flex_Pricing;

--  Procedure Attributes

PROCEDURE Attributes
( p_x_Line_Price_Att_rec		IN OUT NOCOPY	OE_Order_PUB.Line_Price_Att_Rec_Type
--	 := OE_Order_PUB.G_MISS_LINE_PRICE_ATT_REC
,   p_iteration               IN  NUMBER DEFAULT 1
-- , x_Line_Price_Att_rec	OUT 	OE_Order_PUB.Line_Price_Att_Rec_Type
)
IS
n number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
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

    --  Initialize g_Line_Price_Att_rec

    g_Line_Price_Att_rec := p_x_Line_Price_Att_rec;

--    g_Line_Price_Att_rec := p_x_Line_Price_Att_rec;


    --  Default missing attributes.

    IF g_Line_Price_Att_rec.flex_title = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.flex_title := Get_Flex_Title;

        IF g_Line_Price_Att_rec.flex_title IS NOT NULL THEN

            IF oe_validate_adj.Flex_Title(g_Line_Price_Att_rec.flex_title)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id       => OE_Line_PAttr_Util.G_FLEX_TITLE
                ,   p_x_Line_Price_Att_rec      => g_Line_Price_Att_rec
           --   ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.flex_title := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.header_id = FND_API.G_MISS_NUM THEN

        g_Line_Price_Att_rec.header_id := Get_Header;

        IF g_Line_Price_Att_rec.header_id IS NOT NULL THEN

            IF oe_validate_adj.Header(g_Line_Price_Att_rec.header_id)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                 => OE_Line_PAttr_Util.G_HEADER
                ,   p_x_Line_Price_Att_rec      => g_Line_Price_Att_rec
            --  ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.line_id = FND_API.G_MISS_NUM THEN

        g_Line_Price_Att_rec.line_id := Get_Line;

        IF g_Line_Price_Att_rec.line_id IS NOT NULL THEN

            IF oe_validate_adj.Line(g_Line_Price_Att_rec.line_id)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                  => OE_Line_PAttr_Util.G_LINE
                ,   p_x_Line_Price_Att_rec      => g_Line_Price_Att_rec
           --   ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.line_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.order_price_attrib_id = FND_API.G_MISS_NUM THEN

        g_Line_Price_Att_rec.order_price_attrib_id := Get_Order_Price_Attrib;

        IF g_Line_Price_Att_rec.order_price_attrib_id IS NOT NULL THEN

            IF oe_validate_adj.Order_Price_Attrib(g_Line_Price_Att_rec.order_price_attrib_id)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id       => OE_Line_PAttr_Util.G_ORDER_PRICE_ATTRIB
                ,   p_x_Line_Price_Att_rec      => g_Line_Price_Att_rec
             -- ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.order_price_attrib_id := NULL;
            END IF;

        END IF;

    END IF;

--

    IF g_Line_Price_Att_rec.override_flag = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.override_flag := Get_Override_Flag;

        IF g_Line_Price_Att_rec.override_flag IS NOT NULL THEN

            IF oe_validate_adj.override_flag(g_Line_Price_Att_rec.override_flag)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id       => OE_Line_PAttr_Util.G_OVERRIDE_FLAG
                ,   p_x_Line_Price_Att_rec      => g_Line_Price_Att_rec
           --   ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.override_flag := NULL;
            END IF;

        END IF;

    END IF;



--




-- This code commented no longer required
/*
    IF g_Line_Price_Att_rec.pricing_attribute100 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute100 := Get_Pricing_Attribute100;

        IF g_Line_Price_Att_rec.pricing_attribute100 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute100(g_Line_Price_Att_rec.pricing_attribute100)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE100
                ,   p_x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute100 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute11 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute11 := Get_Pricing_Attribute11;

        IF g_Line_Price_Att_rec.pricing_attribute11 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute11(g_Line_Price_Att_rec.pricing_attribute11)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE11
                ,   p_x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute11 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute12 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute12 := Get_Pricing_Attribute12;

        IF g_Line_Price_Att_rec.pricing_attribute12 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute12(g_Line_Price_Att_rec.pricing_attribute12)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE12
                ,   p_x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute12 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute13 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute13 := Get_Pricing_Attribute13;

        IF g_Line_Price_Att_rec.pricing_attribute13 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute13(g_Line_Price_Att_rec.pricing_attribute13)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE13
                ,   p_x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute13 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute14 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute14 := Get_Pricing_Attribute14;

        IF g_Line_Price_Att_rec.pricing_attribute14 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute14(g_Line_Price_Att_rec.pricing_attribute14)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE14
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute14 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute15 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute15 := Get_Pricing_Attribute15;

        IF g_Line_Price_Att_rec.pricing_attribute15 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute15(g_Line_Price_Att_rec.pricing_attribute15)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE15
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute15 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute16 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute16 := Get_Pricing_Attribute16;

        IF g_Line_Price_Att_rec.pricing_attribute16 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute16(g_Line_Price_Att_rec.pricing_attribute16)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE16
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute16 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute17 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute17 := Get_Pricing_Attribute17;

        IF g_Line_Price_Att_rec.pricing_attribute17 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute17(g_Line_Price_Att_rec.pricing_attribute17)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE17
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute17 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute18 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute18 := Get_Pricing_Attribute18;

        IF g_Line_Price_Att_rec.pricing_attribute18 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute18(g_Line_Price_Att_rec.pricing_attribute18)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE18
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute18 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute19 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute19 := Get_Pricing_Attribute19;

        IF g_Line_Price_Att_rec.pricing_attribute19 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute19(g_Line_Price_Att_rec.pricing_attribute19)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE19
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute19 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute20 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute20 := Get_Pricing_Attribute20;

        IF g_Line_Price_Att_rec.pricing_attribute20 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute20(g_Line_Price_Att_rec.pricing_attribute20)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE20
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute20 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute21 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute21 := Get_Pricing_Attribute21;

        IF g_Line_Price_Att_rec.pricing_attribute21 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute21(g_Line_Price_Att_rec.pricing_attribute21)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE21
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute21 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute22 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute22 := Get_Pricing_Attribute22;

        IF g_Line_Price_Att_rec.pricing_attribute22 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute22(g_Line_Price_Att_rec.pricing_attribute22)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE22
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute22 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute23 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute23 := Get_Pricing_Attribute23;

        IF g_Line_Price_Att_rec.pricing_attribute23 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute23(g_Line_Price_Att_rec.pricing_attribute23)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE23
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute23 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute24 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute24 := Get_Pricing_Attribute24;

        IF g_Line_Price_Att_rec.pricing_attribute24 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute24(g_Line_Price_Att_rec.pricing_attribute24)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE24
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute24 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute25 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute25 := Get_Pricing_Attribute25;

        IF g_Line_Price_Att_rec.pricing_attribute25 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute25(g_Line_Price_Att_rec.pricing_attribute25)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE25
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute25 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute26 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute26 := Get_Pricing_Attribute26;

        IF g_Line_Price_Att_rec.pricing_attribute26 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute26(g_Line_Price_Att_rec.pricing_attribute26)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE26
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute26 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute27 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute27 := Get_Pricing_Attribute27;

        IF g_Line_Price_Att_rec.pricing_attribute27 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute27(g_Line_Price_Att_rec.pricing_attribute27)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE27
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute27 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute28 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute28 := Get_Pricing_Attribute28;

        IF g_Line_Price_Att_rec.pricing_attribute28 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute28(g_Line_Price_Att_rec.pricing_attribute28)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE28
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute28 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute29 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute29 := Get_Pricing_Attribute29;

        IF g_Line_Price_Att_rec.pricing_attribute29 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute29(g_Line_Price_Att_rec.pricing_attribute29)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE29
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute29 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute30 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute30 := Get_Pricing_Attribute30;

        IF g_Line_Price_Att_rec.pricing_attribute30 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute30(g_Line_Price_Att_rec.pricing_attribute30)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE30
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute30 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute31 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute31 := Get_Pricing_Attribute31;

        IF g_Line_Price_Att_rec.pricing_attribute31 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute31(g_Line_Price_Att_rec.pricing_attribute31)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE31
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute31 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute32 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute32 := Get_Pricing_Attribute32;

        IF g_Line_Price_Att_rec.pricing_attribute32 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute32(g_Line_Price_Att_rec.pricing_attribute32)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE32
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute32 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute33 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute33 := Get_Pricing_Attribute33;

        IF g_Line_Price_Att_rec.pricing_attribute33 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute33(g_Line_Price_Att_rec.pricing_attribute33)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE33
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute33 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute34 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute34 := Get_Pricing_Attribute34;

        IF g_Line_Price_Att_rec.pricing_attribute34 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute34(g_Line_Price_Att_rec.pricing_attribute34)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE34
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute34 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute35 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute35 := Get_Pricing_Attribute35;

        IF g_Line_Price_Att_rec.pricing_attribute35 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute35(g_Line_Price_Att_rec.pricing_attribute35)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE35
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute35 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute36 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute36 := Get_Pricing_Attribute36;

        IF g_Line_Price_Att_rec.pricing_attribute36 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute36(g_Line_Price_Att_rec.pricing_attribute36)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE36
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute36 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute37 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute37 := Get_Pricing_Attribute37;

        IF g_Line_Price_Att_rec.pricing_attribute37 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute37(g_Line_Price_Att_rec.pricing_attribute37)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE37
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute37 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute38 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute38 := Get_Pricing_Attribute38;

        IF g_Line_Price_Att_rec.pricing_attribute38 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute38(g_Line_Price_Att_rec.pricing_attribute38)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE38
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute38 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute39 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute39 := Get_Pricing_Attribute39;

        IF g_Line_Price_Att_rec.pricing_attribute39 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute39(g_Line_Price_Att_rec.pricing_attribute39)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE39
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute39 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute40 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute40 := Get_Pricing_Attribute40;

        IF g_Line_Price_Att_rec.pricing_attribute40 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute40(g_Line_Price_Att_rec.pricing_attribute40)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE40
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute40 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute41 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute41 := Get_Pricing_Attribute41;

        IF g_Line_Price_Att_rec.pricing_attribute41 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute41(g_Line_Price_Att_rec.pricing_attribute41)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE41
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute41 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute42 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute42 := Get_Pricing_Attribute42;

        IF g_Line_Price_Att_rec.pricing_attribute42 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute42(g_Line_Price_Att_rec.pricing_attribute42)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE42
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute42 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute43 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute43 := Get_Pricing_Attribute43;

        IF g_Line_Price_Att_rec.pricing_attribute43 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute43(g_Line_Price_Att_rec.pricing_attribute43)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE43
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute43 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute44 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute44 := Get_Pricing_Attribute44;

        IF g_Line_Price_Att_rec.pricing_attribute44 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute44(g_Line_Price_Att_rec.pricing_attribute44)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE44
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute44 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute45 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute45 := Get_Pricing_Attribute45;

        IF g_Line_Price_Att_rec.pricing_attribute45 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute45(g_Line_Price_Att_rec.pricing_attribute45)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE45
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute45 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute46 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute46 := Get_Pricing_Attribute46;

        IF g_Line_Price_Att_rec.pricing_attribute46 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute46(g_Line_Price_Att_rec.pricing_attribute46)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE46
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute46 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute47 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute47 := Get_Pricing_Attribute47;

        IF g_Line_Price_Att_rec.pricing_attribute47 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute47(g_Line_Price_Att_rec.pricing_attribute47)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE47
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute47 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute48 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute48 := Get_Pricing_Attribute48;

        IF g_Line_Price_Att_rec.pricing_attribute48 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute48(g_Line_Price_Att_rec.pricing_attribute48)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE48
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute48 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute49 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute49 := Get_Pricing_Attribute49;

        IF g_Line_Price_Att_rec.pricing_attribute49 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute49(g_Line_Price_Att_rec.pricing_attribute49)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE49
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute49 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute50 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute50 := Get_Pricing_Attribute50;

        IF g_Line_Price_Att_rec.pricing_attribute50 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute50(g_Line_Price_Att_rec.pricing_attribute50)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE50
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute50 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute51 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute51 := Get_Pricing_Attribute51;

        IF g_Line_Price_Att_rec.pricing_attribute51 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute51(g_Line_Price_Att_rec.pricing_attribute51)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE51
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute51 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute52 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute52 := Get_Pricing_Attribute52;

        IF g_Line_Price_Att_rec.pricing_attribute52 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute52(g_Line_Price_Att_rec.pricing_attribute52)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE52
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute52 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute53 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute53 := Get_Pricing_Attribute53;

        IF g_Line_Price_Att_rec.pricing_attribute53 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute53(g_Line_Price_Att_rec.pricing_attribute53)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE53
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute53 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute54 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute54 := Get_Pricing_Attribute54;

        IF g_Line_Price_Att_rec.pricing_attribute54 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute54(g_Line_Price_Att_rec.pricing_attribute54)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE54
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute54 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute55 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute55 := Get_Pricing_Attribute55;

        IF g_Line_Price_Att_rec.pricing_attribute55 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute55(g_Line_Price_Att_rec.pricing_attribute55)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE55
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute55 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute56 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute56 := Get_Pricing_Attribute56;

        IF g_Line_Price_Att_rec.pricing_attribute56 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute56(g_Line_Price_Att_rec.pricing_attribute56)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE56
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute56 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute57 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute57 := Get_Pricing_Attribute57;

        IF g_Line_Price_Att_rec.pricing_attribute57 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute57(g_Line_Price_Att_rec.pricing_attribute57)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE57
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute57 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute58 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute58 := Get_Pricing_Attribute58;

        IF g_Line_Price_Att_rec.pricing_attribute58 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute58(g_Line_Price_Att_rec.pricing_attribute58)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE58
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute58 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute59 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute59 := Get_Pricing_Attribute59;

        IF g_Line_Price_Att_rec.pricing_attribute59 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute59(g_Line_Price_Att_rec.pricing_attribute59)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE59
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute59 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute60 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute60 := Get_Pricing_Attribute60;

        IF g_Line_Price_Att_rec.pricing_attribute60 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute60(g_Line_Price_Att_rec.pricing_attribute60)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE60
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute60 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute61 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute61 := Get_Pricing_Attribute61;

        IF g_Line_Price_Att_rec.pricing_attribute61 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute61(g_Line_Price_Att_rec.pricing_attribute61)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE61
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute61 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute62 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute62 := Get_Pricing_Attribute62;

        IF g_Line_Price_Att_rec.pricing_attribute62 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute62(g_Line_Price_Att_rec.pricing_attribute62)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE62
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute62 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute63 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute63 := Get_Pricing_Attribute63;

        IF g_Line_Price_Att_rec.pricing_attribute63 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute63(g_Line_Price_Att_rec.pricing_attribute63)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE63
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute63 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute64 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute64 := Get_Pricing_Attribute64;

        IF g_Line_Price_Att_rec.pricing_attribute64 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute64(g_Line_Price_Att_rec.pricing_attribute64)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE64
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute64 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute65 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute65 := Get_Pricing_Attribute65;

        IF g_Line_Price_Att_rec.pricing_attribute65 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute65(g_Line_Price_Att_rec.pricing_attribute65)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE65
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute65 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute66 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute66 := Get_Pricing_Attribute66;

        IF g_Line_Price_Att_rec.pricing_attribute66 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute66(g_Line_Price_Att_rec.pricing_attribute66)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE66
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute66 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute67 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute67 := Get_Pricing_Attribute67;

        IF g_Line_Price_Att_rec.pricing_attribute67 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute67(g_Line_Price_Att_rec.pricing_attribute67)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE67
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute67 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute68 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute68 := Get_Pricing_Attribute68;

        IF g_Line_Price_Att_rec.pricing_attribute68 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute68(g_Line_Price_Att_rec.pricing_attribute68)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE68
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute68 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute69 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute69 := Get_Pricing_Attribute69;

        IF g_Line_Price_Att_rec.pricing_attribute69 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute69(g_Line_Price_Att_rec.pricing_attribute69)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE69
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute69 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute70 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute70 := Get_Pricing_Attribute70;

        IF g_Line_Price_Att_rec.pricing_attribute70 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute70(g_Line_Price_Att_rec.pricing_attribute70)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE70
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute70 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute71 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute71 := Get_Pricing_Attribute71;

        IF g_Line_Price_Att_rec.pricing_attribute71 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute71(g_Line_Price_Att_rec.pricing_attribute71)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE71
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute71 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute72 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute72 := Get_Pricing_Attribute72;

        IF g_Line_Price_Att_rec.pricing_attribute72 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute72(g_Line_Price_Att_rec.pricing_attribute72)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE72
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute72 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute73 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute73 := Get_Pricing_Attribute73;

        IF g_Line_Price_Att_rec.pricing_attribute73 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute73(g_Line_Price_Att_rec.pricing_attribute73)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE73
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute73 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute74 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute74 := Get_Pricing_Attribute74;

        IF g_Line_Price_Att_rec.pricing_attribute74 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute74(g_Line_Price_Att_rec.pricing_attribute74)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE74
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute74 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute75 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute75 := Get_Pricing_Attribute75;

        IF g_Line_Price_Att_rec.pricing_attribute75 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute75(g_Line_Price_Att_rec.pricing_attribute75)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE75
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute75 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute76 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute76 := Get_Pricing_Attribute76;

        IF g_Line_Price_Att_rec.pricing_attribute76 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute76(g_Line_Price_Att_rec.pricing_attribute76)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE76
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute76 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute77 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute77 := Get_Pricing_Attribute77;

        IF g_Line_Price_Att_rec.pricing_attribute77 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute77(g_Line_Price_Att_rec.pricing_attribute77)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE77
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute77 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute78 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute78 := Get_Pricing_Attribute78;

        IF g_Line_Price_Att_rec.pricing_attribute78 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute78(g_Line_Price_Att_rec.pricing_attribute78)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE78
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute78 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute79 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute79 := Get_Pricing_Attribute79;

        IF g_Line_Price_Att_rec.pricing_attribute79 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute79(g_Line_Price_Att_rec.pricing_attribute79)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE79
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute79 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute80 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute80 := Get_Pricing_Attribute80;

        IF g_Line_Price_Att_rec.pricing_attribute80 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute80(g_Line_Price_Att_rec.pricing_attribute80)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE80
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute80 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute81 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute81 := Get_Pricing_Attribute81;

        IF g_Line_Price_Att_rec.pricing_attribute81 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute81(g_Line_Price_Att_rec.pricing_attribute81)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE81
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute81 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute82 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute82 := Get_Pricing_Attribute82;

        IF g_Line_Price_Att_rec.pricing_attribute82 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute82(g_Line_Price_Att_rec.pricing_attribute82)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE82
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute82 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute83 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute83 := Get_Pricing_Attribute83;

        IF g_Line_Price_Att_rec.pricing_attribute83 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute83(g_Line_Price_Att_rec.pricing_attribute83)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE83
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute83 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute84 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute84 := Get_Pricing_Attribute84;

        IF g_Line_Price_Att_rec.pricing_attribute84 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute84(g_Line_Price_Att_rec.pricing_attribute84)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE84
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute84 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute85 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute85 := Get_Pricing_Attribute85;

        IF g_Line_Price_Att_rec.pricing_attribute85 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute85(g_Line_Price_Att_rec.pricing_attribute85)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE85
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute85 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute86 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute86 := Get_Pricing_Attribute86;

        IF g_Line_Price_Att_rec.pricing_attribute86 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute86(g_Line_Price_Att_rec.pricing_attribute86)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE86
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute86 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute87 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute87 := Get_Pricing_Attribute87;

        IF g_Line_Price_Att_rec.pricing_attribute87 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute87(g_Line_Price_Att_rec.pricing_attribute87)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE87
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute87 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute88 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute88 := Get_Pricing_Attribute88;

        IF g_Line_Price_Att_rec.pricing_attribute88 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute88(g_Line_Price_Att_rec.pricing_attribute88)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE88
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute88 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute89 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute89 := Get_Pricing_Attribute89;

        IF g_Line_Price_Att_rec.pricing_attribute89 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute89(g_Line_Price_Att_rec.pricing_attribute89)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE89
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute89 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute90 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute90 := Get_Pricing_Attribute90;

        IF g_Line_Price_Att_rec.pricing_attribute90 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute90(g_Line_Price_Att_rec.pricing_attribute90)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE90
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute90 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute91 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute91 := Get_Pricing_Attribute91;

        IF g_Line_Price_Att_rec.pricing_attribute91 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute91(g_Line_Price_Att_rec.pricing_attribute91)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE91
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute91 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute92 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute92 := Get_Pricing_Attribute92;

        IF g_Line_Price_Att_rec.pricing_attribute92 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute92(g_Line_Price_Att_rec.pricing_attribute92)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE92
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute92 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute93 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute93 := Get_Pricing_Attribute93;

        IF g_Line_Price_Att_rec.pricing_attribute93 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute93(g_Line_Price_Att_rec.pricing_attribute93)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE93
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute93 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute94 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute94 := Get_Pricing_Attribute94;

        IF g_Line_Price_Att_rec.pricing_attribute94 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute94(g_Line_Price_Att_rec.pricing_attribute94)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE94
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute94 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute95 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute95 := Get_Pricing_Attribute95;

        IF g_Line_Price_Att_rec.pricing_attribute95 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute95(g_Line_Price_Att_rec.pricing_attribute95)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE95
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute95 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute96 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute96 := Get_Pricing_Attribute96;

        IF g_Line_Price_Att_rec.pricing_attribute96 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute96(g_Line_Price_Att_rec.pricing_attribute96)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE96
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute96 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute97 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute97 := Get_Pricing_Attribute97;

        IF g_Line_Price_Att_rec.pricing_attribute97 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute97(g_Line_Price_Att_rec.pricing_attribute97)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE97
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute97 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute98 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute98 := Get_Pricing_Attribute98;

        IF g_Line_Price_Att_rec.pricing_attribute98 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute98(g_Line_Price_Att_rec.pricing_attribute98)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE98
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute98 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute99 = FND_API.G_MISS_CHAR THEN

        g_Line_Price_Att_rec.pricing_attribute99 := Get_Pricing_Attribute99;

        IF g_Line_Price_Att_rec.pricing_attribute99 IS NOT NULL THEN

            IF oe_validate_adj.Pricing_Attribute99(g_Line_Price_Att_rec.pricing_attribute99)
            THEN
                OE_Line_PAttr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE99
                ,   p_Line_Price_Att_rec      => g_Line_Price_Att_rec
                ,   x_Line_Price_Att_rec      => g_Line_Price_Att_rec
                );
            ELSE
                g_Line_Price_Att_rec.pricing_attribute99 := NULL;
            END IF;

        END IF;

    END IF;
*/

    IF g_Line_Price_Att_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Line_Pricing_Pattr;

    END IF;

    IF g_Line_Price_Att_rec.pricing_attribute1 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute10 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute2 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute3 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute4 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute5 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute6 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute7 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute8 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute9 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_context = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute11 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute12 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute13 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute14 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute15 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute16 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute17 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute18 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute19 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute20 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute21 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute22 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute23 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute24 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute25 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute26 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute27 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute28 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute29 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute30 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute31 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute32 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute33 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute34 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute35 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute36 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute37 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute38 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute39 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute40 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute41 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute42 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute43 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute44 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute45 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute46 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute47 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute48 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute49 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute50 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute51 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute52 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute53 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute54 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute55 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute56 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute57 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute58 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute59 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute60 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute61 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute62 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute63 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute64 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute65 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute66 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute67 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute68 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute69 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute70 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute71 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute72 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute73 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute74 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute75 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute76 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute77 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute78 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute79 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute80 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute81 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute82 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute83 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute84 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute85 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute86 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute87 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute88 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute89 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute90 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute91 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute92 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute93 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute94 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute95 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute96 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute97 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute98 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute99 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute100 = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Pricing;

    END IF;

    IF g_Line_Price_Att_rec.created_by = FND_API.G_MISS_NUM THEN

        g_Line_Price_Att_rec.created_by := NULL;

    END IF;


    IF g_Line_Price_Att_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_Line_Price_Att_rec.creation_date := sysdate;

    END IF;

    IF g_Line_Price_Att_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_Line_Price_Att_rec.last_updated_by := NULL;

    END IF;

    IF g_Line_Price_Att_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_Line_Price_Att_rec.last_update_date := NULL;

    END IF;

    IF g_Line_Price_Att_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_Line_Price_Att_rec.last_update_login := NULL;

    END IF;

    IF g_Line_Price_Att_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_Line_Price_Att_rec.program_application_id := NULL;

    END IF;

    IF g_Line_Price_Att_rec.program_id = FND_API.G_MISS_NUM THEN

        g_Line_Price_Att_rec.program_id := NULL;

    END IF;

    IF g_Line_Price_Att_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_Line_Price_Att_rec.program_update_date := NULL;

    END IF;

    IF g_Line_Price_Att_rec.request_id = FND_API.G_MISS_NUM THEN

        g_Line_Price_Att_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.
/*  Comented for fix 1433292
    IF  g_Line_Price_Att_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.context = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.created_by = FND_API.G_MISS_NUM
    OR  g_Line_Price_Att_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_Line_Price_Att_rec.flex_title = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.header_id = FND_API.G_MISS_NUM
    OR  g_Line_Price_Att_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_Line_Price_Att_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_Line_Price_Att_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_Line_Price_Att_rec.line_id = FND_API.G_MISS_NUM
    OR  g_Line_Price_Att_rec.order_price_attrib_id = FND_API.G_MISS_NUM
    OR  g_Line_Price_Att_rec.pricing_attribute1 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute10 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute100 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute11 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute12 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute13 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute14 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute15 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute16 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute17 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute18 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute19 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute2 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute20 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute21 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute22 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute23 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute24 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute25 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute26 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute27 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute28 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute29 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute3 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute30 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute31 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute32 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute33 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute34 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute35 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute36 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute37 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute38 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute39 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute4 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute40 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute41 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute42 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute43 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute44 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute45 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute46 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute47 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute48 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute49 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute5 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute50 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute51 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute52 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute53 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute54 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute55 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute56 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute57 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute58 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute59 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute6 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute60 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute61 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute62 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute63 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute64 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute65 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute66 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute67 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute68 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute69 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute7 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute70 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute71 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute72 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute73 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute74 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute75 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute76 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute77 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute78 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute79 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute8 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute80 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute81 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute82 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute83 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute84 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute85 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute86 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute87 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute88 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute89 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute9 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute90 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute91 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute92 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute93 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute94 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute95 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute96 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute97 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute98 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_attribute99 = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.pricing_context = FND_API.G_MISS_CHAR
    OR  g_Line_Price_Att_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_Line_Price_Att_rec.program_id = FND_API.G_MISS_NUM
    OR  g_Line_Price_Att_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_Line_Price_Att_rec.request_id = FND_API.G_MISS_NUM
    OR  g_Line_Price_Att_rec.override_flag = FND_API.G_MISS_CHAR
    THEN

        OE_Default_Line_PAttr.Attributes
        (   p_x_Line_Price_Att_rec      => g_Line_Price_Att_rec
        ,   p_iteration                   => p_iteration + 1
  --      ,   x_Line_Price_Att_rec      => x_Line_Price_Att_rec
        );

    ELSE
*/

       --  Done defaulting attributes
       --  Added for bug#2645465
       FND_FLEX_DESCVAL.set_context_value(g_Line_Price_Att_rec.pricing_context);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE1',g_Line_Price_Att_rec.pricing_attribute1);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE2',g_Line_Price_Att_rec.pricing_attribute2);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE3',g_Line_Price_Att_rec.pricing_attribute3);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE4',g_Line_Price_Att_rec.pricing_attribute4);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE5',g_Line_Price_Att_rec.pricing_attribute5);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE6',g_Line_Price_Att_rec.pricing_attribute6);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE7',g_Line_Price_Att_rec.pricing_attribute7);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE8',g_Line_Price_Att_rec.pricing_attribute8);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE9',g_Line_Price_Att_rec.pricing_attribute9);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE10',g_Line_Price_Att_rec.pricing_attribute10);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE11',g_Line_Price_Att_rec.pricing_attribute11);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE12',g_Line_Price_Att_rec.pricing_attribute12);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE13',g_Line_Price_Att_rec.pricing_attribute13);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE14',g_Line_Price_Att_rec.pricing_attribute14);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE15',g_Line_Price_Att_rec.pricing_attribute15);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE16',g_Line_Price_Att_rec.pricing_attribute16);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE17',g_Line_Price_Att_rec.pricing_attribute17);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE18',g_Line_Price_Att_rec.pricing_attribute18);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE19',g_Line_Price_Att_rec.pricing_attribute19);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE20',g_Line_Price_Att_rec.pricing_attribute20);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE21',g_Line_Price_Att_rec.pricing_attribute21);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE22',g_Line_Price_Att_rec.pricing_attribute22);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE23',g_Line_Price_Att_rec.pricing_attribute23);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE24',g_Line_Price_Att_rec.pricing_attribute24);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE25',g_Line_Price_Att_rec.pricing_attribute25);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE26',g_Line_Price_Att_rec.pricing_attribute26);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE27',g_Line_Price_Att_rec.pricing_attribute27);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE28',g_Line_Price_Att_rec.pricing_attribute28);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE29',g_Line_Price_Att_rec.pricing_attribute29);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE30',g_Line_Price_Att_rec.pricing_attribute30);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE31',g_Line_Price_Att_rec.pricing_attribute31);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE32',g_Line_Price_Att_rec.pricing_attribute32);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE33',g_Line_Price_Att_rec.pricing_attribute33);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE34',g_Line_Price_Att_rec.pricing_attribute34);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE35',g_Line_Price_Att_rec.pricing_attribute35);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE36',g_Line_Price_Att_rec.pricing_attribute36);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE37',g_Line_Price_Att_rec.pricing_attribute37);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE38',g_Line_Price_Att_rec.pricing_attribute38);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE39',g_Line_Price_Att_rec.pricing_attribute39);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE40',g_Line_Price_Att_rec.pricing_attribute40);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE41',g_Line_Price_Att_rec.pricing_attribute41);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE42',g_Line_Price_Att_rec.pricing_attribute42);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE43',g_Line_Price_Att_rec.pricing_attribute43);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE44',g_Line_Price_Att_rec.pricing_attribute44);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE45',g_Line_Price_Att_rec.pricing_attribute45);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE46',g_Line_Price_Att_rec.pricing_attribute46);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE47',g_Line_Price_Att_rec.pricing_attribute47);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE48',g_Line_Price_Att_rec.pricing_attribute48);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE49',g_Line_Price_Att_rec.pricing_attribute49);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE50',g_Line_Price_Att_rec.pricing_attribute50);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE51',g_Line_Price_Att_rec.pricing_attribute51);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE52',g_Line_Price_Att_rec.pricing_attribute52);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE53',g_Line_Price_Att_rec.pricing_attribute53);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE54',g_Line_Price_Att_rec.pricing_attribute54);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE55',g_Line_Price_Att_rec.pricing_attribute55);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE56',g_Line_Price_Att_rec.pricing_attribute56);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE57',g_Line_Price_Att_rec.pricing_attribute57);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE58',g_Line_Price_Att_rec.pricing_attribute58);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE59',g_Line_Price_Att_rec.pricing_attribute59);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE60',g_Line_Price_Att_rec.pricing_attribute60);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE61',g_Line_Price_Att_rec.pricing_attribute61);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE62',g_Line_Price_Att_rec.pricing_attribute62);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE63',g_Line_Price_Att_rec.pricing_attribute63);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE64',g_Line_Price_Att_rec.pricing_attribute64);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE65',g_Line_Price_Att_rec.pricing_attribute65);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE66',g_Line_Price_Att_rec.pricing_attribute66);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE67',g_Line_Price_Att_rec.pricing_attribute67);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE68',g_Line_Price_Att_rec.pricing_attribute68);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE69',g_Line_Price_Att_rec.pricing_attribute69);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE70',g_Line_Price_Att_rec.pricing_attribute70);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE71',g_Line_Price_Att_rec.pricing_attribute71);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE72',g_Line_Price_Att_rec.pricing_attribute72);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE73',g_Line_Price_Att_rec.pricing_attribute73);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE74',g_Line_Price_Att_rec.pricing_attribute74);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE75',g_Line_Price_Att_rec.pricing_attribute75);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE76',g_Line_Price_Att_rec.pricing_attribute76);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE77',g_Line_Price_Att_rec.pricing_attribute77);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE78',g_Line_Price_Att_rec.pricing_attribute78);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE79',g_Line_Price_Att_rec.pricing_attribute79);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE80',g_Line_Price_Att_rec.pricing_attribute80);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE81',g_Line_Price_Att_rec.pricing_attribute81);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE82',g_Line_Price_Att_rec.pricing_attribute82);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE83',g_Line_Price_Att_rec.pricing_attribute83);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE84',g_Line_Price_Att_rec.pricing_attribute84);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE85',g_Line_Price_Att_rec.pricing_attribute85);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE86',g_Line_Price_Att_rec.pricing_attribute86);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE87',g_Line_Price_Att_rec.pricing_attribute87);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE88',g_Line_Price_Att_rec.pricing_attribute88);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE89',g_Line_Price_Att_rec.pricing_attribute89);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE90',g_Line_Price_Att_rec.pricing_attribute90);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE91',g_Line_Price_Att_rec.pricing_attribute91);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE92',g_Line_Price_Att_rec.pricing_attribute92);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE93',g_Line_Price_Att_rec.pricing_attribute93);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE94',g_Line_Price_Att_rec.pricing_attribute94);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE95',g_Line_Price_Att_rec.pricing_attribute95);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE96',g_Line_Price_Att_rec.pricing_attribute96);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE97',g_Line_Price_Att_rec.pricing_attribute97);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE98',g_Line_Price_Att_rec.pricing_attribute98);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE99',g_Line_Price_Att_rec.pricing_attribute99);
       fnd_flex_descval.set_column_value('PRICING_ATTRIBUTE100',g_Line_Price_Att_rec.pricing_attribute100);

       IF  FND_FLEX_DESCVAL.validate_desccols(
         'QP',
         'QP_ATTR_DEFNS_PRICING',
         'D',   --bug 2912987
         SYSDATE)
       THEN
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('After call to FND_FLEX_DESCVAL.validate_desccols');
           END IF;
           n := FND_FLEX_DESCVAL.segment_count;
           for i in 1..n loop
              IF FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE1' Then
                 g_Line_Price_Att_rec.pricing_attribute1 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE2' Then
                 g_Line_Price_Att_rec.pricing_attribute2 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE3' Then
                 g_Line_Price_Att_rec.pricing_attribute3 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE4' Then
                 g_Line_Price_Att_rec.pricing_attribute4 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE5' Then
                 g_Line_Price_Att_rec.pricing_attribute5 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE6' Then
                 g_Line_Price_Att_rec.pricing_attribute6 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE7' Then
                 g_Line_Price_Att_rec.pricing_attribute7 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE8' Then
                 g_Line_Price_Att_rec.pricing_attribute8 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE9' Then
                 g_Line_Price_Att_rec.pricing_attribute9 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE10' Then
                 g_Line_Price_Att_rec.pricing_attribute10 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE11' Then
                 g_Line_Price_Att_rec.pricing_attribute11 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE12' Then
                 g_Line_Price_Att_rec.pricing_attribute12 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE13' Then
                 g_Line_Price_Att_rec.pricing_attribute13 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE14' Then
                 g_Line_Price_Att_rec.pricing_attribute14 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE15' Then
                 g_Line_Price_Att_rec.pricing_attribute15 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE16' Then
                 g_Line_Price_Att_rec.pricing_attribute16 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE17' Then
                 g_Line_Price_Att_rec.pricing_attribute17 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE18' Then
                 g_Line_Price_Att_rec.pricing_attribute18 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE19' Then
                 g_Line_Price_Att_rec.pricing_attribute19 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE20' Then
                 g_Line_Price_Att_rec.pricing_attribute20 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE21' Then
                 g_Line_Price_Att_rec.pricing_attribute21 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE22' Then
                 g_Line_Price_Att_rec.pricing_attribute22 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE23' Then
                 g_Line_Price_Att_rec.pricing_attribute23 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE24' Then
                 g_Line_Price_Att_rec.pricing_attribute24 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE25' Then
                 g_Line_Price_Att_rec.pricing_attribute25 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE26' Then
                 g_Line_Price_Att_rec.pricing_attribute26 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE27' Then
                 g_Line_Price_Att_rec.pricing_attribute27 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE28' Then
                 g_Line_Price_Att_rec.pricing_attribute28 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE29' Then
                 g_Line_Price_Att_rec.pricing_attribute29 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE30' Then
                 g_Line_Price_Att_rec.pricing_attribute30 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE31' Then
                 g_Line_Price_Att_rec.pricing_attribute31 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE32' Then
                 g_Line_Price_Att_rec.pricing_attribute32 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE33' Then
                 g_Line_Price_Att_rec.pricing_attribute33 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE34' Then
                 g_Line_Price_Att_rec.pricing_attribute34 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE35' Then
                 g_Line_Price_Att_rec.pricing_attribute35 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE36' Then
                 g_Line_Price_Att_rec.pricing_attribute36 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE37' Then
                 g_Line_Price_Att_rec.pricing_attribute37 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE38' Then
                 g_Line_Price_Att_rec.pricing_attribute38 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE39' Then
                 g_Line_Price_Att_rec.pricing_attribute39 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE40' Then
                 g_Line_Price_Att_rec.pricing_attribute40 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE41' Then
                 g_Line_Price_Att_rec.pricing_attribute41 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE42' Then
                 g_Line_Price_Att_rec.pricing_attribute42 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE43' Then
                 g_Line_Price_Att_rec.pricing_attribute43 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE44' Then
                 g_Line_Price_Att_rec.pricing_attribute44 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE45' Then
                 g_Line_Price_Att_rec.pricing_attribute45 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE46' Then
                 g_Line_Price_Att_rec.pricing_attribute46 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE47' Then
                 g_Line_Price_Att_rec.pricing_attribute47 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE48' Then
                 g_Line_Price_Att_rec.pricing_attribute48 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE49' Then
                 g_Line_Price_Att_rec.pricing_attribute49 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE50' Then
                 g_Line_Price_Att_rec.pricing_attribute50 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE51' Then
                 g_Line_Price_Att_rec.pricing_attribute51 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE52' Then
                 g_Line_Price_Att_rec.pricing_attribute52 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE53' Then
                 g_Line_Price_Att_rec.pricing_attribute53 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE54' Then
                 g_Line_Price_Att_rec.pricing_attribute54 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE55' Then
                 g_Line_Price_Att_rec.pricing_attribute55 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE56' Then
                 g_Line_Price_Att_rec.pricing_attribute56 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE57' Then
                 g_Line_Price_Att_rec.pricing_attribute57 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE58' Then
                 g_Line_Price_Att_rec.pricing_attribute58 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE59' Then
                 g_Line_Price_Att_rec.pricing_attribute59 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE60' Then
                 g_Line_Price_Att_rec.pricing_attribute60 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE61' Then
                 g_Line_Price_Att_rec.pricing_attribute61 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE62' Then
                 g_Line_Price_Att_rec.pricing_attribute62 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE63' Then
                 g_Line_Price_Att_rec.pricing_attribute63 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE64' Then
                 g_Line_Price_Att_rec.pricing_attribute64 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE65' Then
                 g_Line_Price_Att_rec.pricing_attribute65 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE66' Then
                 g_Line_Price_Att_rec.pricing_attribute66 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE67' Then
                 g_Line_Price_Att_rec.pricing_attribute67 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE68' Then
                 g_Line_Price_Att_rec.pricing_attribute68 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE69' Then
                 g_Line_Price_Att_rec.pricing_attribute69 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE70' Then
                 g_Line_Price_Att_rec.pricing_attribute70 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE71' Then
                 g_Line_Price_Att_rec.pricing_attribute71 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE72' Then
                 g_Line_Price_Att_rec.pricing_attribute72 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE73' Then
                 g_Line_Price_Att_rec.pricing_attribute73 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE74' Then
                 g_Line_Price_Att_rec.pricing_attribute74 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE75' Then
                 g_Line_Price_Att_rec.pricing_attribute75 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE76' Then
                 g_Line_Price_Att_rec.pricing_attribute76 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE77' Then
                 g_Line_Price_Att_rec.pricing_attribute77 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE78' Then
                 g_Line_Price_Att_rec.pricing_attribute78 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE79' Then
                 g_Line_Price_Att_rec.pricing_attribute79 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE80' Then
                 g_Line_Price_Att_rec.pricing_attribute80 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE81' Then
                 g_Line_Price_Att_rec.pricing_attribute81 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE82' Then
                 g_Line_Price_Att_rec.pricing_attribute82 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE83' Then
                 g_Line_Price_Att_rec.pricing_attribute83 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE84' Then
                 g_Line_Price_Att_rec.pricing_attribute84 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE85' Then
                 g_Line_Price_Att_rec.pricing_attribute85 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE86' Then
                 g_Line_Price_Att_rec.pricing_attribute86 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE87' Then
                 g_Line_Price_Att_rec.pricing_attribute87 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE88' Then
                 g_Line_Price_Att_rec.pricing_attribute88 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE89' Then
                 g_Line_Price_Att_rec.pricing_attribute89 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE90' Then
                 g_Line_Price_Att_rec.pricing_attribute90 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE91' Then
                 g_Line_Price_Att_rec.pricing_attribute91 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE92' Then
                 g_Line_Price_Att_rec.pricing_attribute92 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE93' Then
                 g_Line_Price_Att_rec.pricing_attribute93 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE94' Then
                 g_Line_Price_Att_rec.pricing_attribute94 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE95' Then
                 g_Line_Price_Att_rec.pricing_attribute95 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE96' Then
                 g_Line_Price_Att_rec.pricing_attribute96 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE97' Then
                 g_Line_Price_Att_rec.pricing_attribute97 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE98' Then
                 g_Line_Price_Att_rec.pricing_attribute98 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE99' Then
                 g_Line_Price_Att_rec.pricing_attribute99 :=  FND_FLEX_DESCVAL.segment_id(i);
              Elsif FND_FLEX_DESCVAL.segment_column_name(i) = 'PRICING_ATTRIBUTE100' Then
                 g_Line_Price_Att_rec.pricing_attribute100 :=  FND_FLEX_DESCVAL.segment_id(i);
              End If;
           end loop;
       ELSE
           null;
       END IF;

       p_x_Line_Price_Att_rec := g_Line_Price_Att_rec;


--    END IF;

END Attributes;

END OE_Default_Line_PAttr;

/
