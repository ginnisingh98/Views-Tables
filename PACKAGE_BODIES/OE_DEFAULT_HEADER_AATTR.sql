--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_HEADER_AATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_HEADER_AATTR" AS
/* $Header: OEXDHAAB.pls 120.0 2005/05/31 23:11:05 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'OE_Default_Header_Aattr';

--  Package global used within the package.

g_Header_Adj_Att_rec      OE_Order_PUB.Header_Adj_Att_Rec_Type;

--  Get functions.


FUNCTION Get_Price_Adj_Attrib
RETURN NUMBER
IS
l_Price_Adj_attrib_id NUMBER;
BEGIN

	SELECT OE_PRICE_ADJ_ATTRIBS_S.nextval INTO
	l_price_adj_attrib_id
	FROM	DUAL;

    RETURN l_price_adj_attrib_id;

EXCEPTION

 WHEN OTHERS THEN

  IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    OE_MSG_PUB.Add_Exc_Msg
	(    G_PKG_NAME          ,
	 'Get_Price_Adj_Attrib'
	 );
  END IF;

  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Price_Adj_Attrib;

--  Procedure Attributes

PROCEDURE Attributes
( p_Header_Adj_Att_rec		IN out nocopy 	OE_Order_PUB.Header_Adj_Att_Rec_Type
,   p_iteration               IN  NUMBER := 1
--, x_Header_Adj_Att_rec	OUT 	OE_Order_PUB.Header_Adj_Att_Rec_Type
)
IS
BEGIN

    --  Check number of iterations.

    IF p_iteration > OE_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_DEF_MAX_ITERATION');
            FND_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_Header_Adj_Att_rec

    g_Header_Adj_Att_rec := p_Header_Adj_Att_rec;


    --  Default missing attributes.

	   IF g_Header_Adj_Att_rec.Price_Adj_attrib_id = FND_API.G_MISS_NUM THEN
			g_Header_Adj_Att_rec.Price_Adj_attrib_id :=
								Get_Price_Adj_Attrib;
    	   End if;

    IF g_Header_Adj_Att_rec.PRICE_ADJUSTMENT_ID = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Att_rec.PRICE_ADJUSTMENT_ID := Null;
    END IF;

    IF g_Header_Adj_Att_rec.PRICING_CONTEXT = FND_API.G_MISS_CHAR THEN
        g_Header_Adj_Att_rec.PRICING_CONTEXT := Null;
    END IF;

    IF g_Header_Adj_Att_rec.PRICING_ATTRIBUTE = FND_API.G_MISS_CHAR THEN
        g_Header_Adj_Att_rec.PRICING_ATTRIBUTE := Null;
    END IF;

    IF g_Header_Adj_Att_rec.CREATION_DATE = FND_API.G_MISS_DATE THEN
        g_Header_Adj_Att_rec.CREATION_DATE := Null;
    END IF;

    IF g_Header_Adj_Att_rec.CREATED_BY = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Att_rec.CREATED_BY := Null;
    END IF;

    IF g_Header_Adj_Att_rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE THEN
        g_Header_Adj_Att_rec.LAST_UPDATE_DATE := Null;
    END IF;

    IF g_Header_Adj_Att_rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Att_rec.LAST_UPDATED_BY := Null;
    END IF;

    IF g_Header_Adj_Att_rec.LAST_UPDATE_LOGIN = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Att_rec.LAST_UPDATE_LOGIN := Null;
    END IF;

    IF g_Header_Adj_Att_rec.PROGRAM_APPLICATION_ID = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Att_rec.PROGRAM_APPLICATION_ID := Null;
    END IF;

    IF g_Header_Adj_Att_rec.PROGRAM_ID = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Att_rec.PROGRAM_ID := Null;
    END IF;

    IF g_Header_Adj_Att_rec.PROGRAM_UPDATE_DATE = FND_API.G_MISS_DATE THEN
        g_Header_Adj_Att_rec.PROGRAM_UPDATE_DATE := Null;
    END IF;

    IF g_Header_Adj_Att_rec.REQUEST_ID = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Att_rec.REQUEST_ID := Null;
    END IF;

    IF g_Header_Adj_Att_rec.PRICING_ATTR_VALUE_FROM = FND_API.G_MISS_CHAR THEN
        g_Header_Adj_Att_rec.PRICING_ATTR_VALUE_FROM := Null;
    END IF;

    IF g_Header_Adj_Att_rec.PRICING_ATTR_VALUE_TO = FND_API.G_MISS_CHAR THEN
        g_Header_Adj_Att_rec.PRICING_ATTR_VALUE_TO := Null;
    END IF;

    IF g_Header_Adj_Att_rec.COMPARISON_OPERATOR = FND_API.G_MISS_CHAR THEN
        g_Header_Adj_Att_rec.COMPARISON_OPERATOR := Null;
    END IF;

    IF g_Header_Adj_Att_rec.FLEX_TITLE = FND_API.G_MISS_CHAR THEN
        g_Header_Adj_Att_rec.FLEX_TITLE := Null;
    END IF;
        --  Done defaulting attributes

        p_Header_Adj_Att_rec := g_Header_Adj_Att_rec;


END Attributes;

END OE_Default_Header_Aattr;

/
