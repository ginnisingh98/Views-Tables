--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_HEADER_ADJ_ASSOCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_HEADER_ADJ_ASSOCS" AS
/* $Header: OEXDHASB.pls 120.0 2005/06/01 00:06:37 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'OE_Default_Header_Adj_Assocs';

--  Package global used within the package.

g_Header_Adj_Assoc_rec      OE_Order_PUB.Header_Adj_Assoc_Rec_Type;

--  Get functions.


FUNCTION Get_Price_Adj_Assoc
RETURN NUMBER
IS
l_Price_Adj_Assoc_id NUMBER;
BEGIN

	SELECT OE_PRICE_ADJ_ASSOCS_S.nextval INTO
	l_price_adj_Assoc_id
	FROM	DUAL;

    RETURN l_price_adj_Assoc_id;

EXCEPTION

 WHEN OTHERS THEN

  IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    OE_MSG_PUB.Add_Exc_Msg
	(    G_PKG_NAME          ,
	 'Get_Price_Adj_Assoc'
	 );
  END IF;

  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Price_Adj_Assoc;

--  Procedure Attributes

PROCEDURE Attributes
( p_x_Header_Adj_Assoc_rec	IN OUT NOCOPY	OE_Order_PUB.Header_Adj_Assoc_Rec_Type
--	 := OE_Order_PUB.G_MISS_Header_Adj_Assoc_REC
,   p_iteration               IN  NUMBER := 1
-- , x_Header_Adj_Assoc_rec	OUT 	OE_Order_PUB.Header_Adj_Assoc_Rec_Type
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

    --  Initialize g_Header_Adj_Assoc_rec

    g_Header_Adj_Assoc_rec := p_x_Header_Adj_Assoc_rec;


    --  Default missing attributes.

	   IF g_Header_Adj_Assoc_rec.Price_Adj_Assoc_id = FND_API.G_MISS_NUM THEN
			g_Header_Adj_Assoc_rec.Price_Adj_Assoc_id :=
								Get_Price_Adj_Assoc;
    	   End if;

    IF g_Header_Adj_Assoc_rec.CREATION_DATE = FND_API.G_MISS_DATE THEN
        g_Header_Adj_Assoc_rec.CREATION_DATE := Null;
    END IF;

    IF g_Header_Adj_Assoc_rec.CREATED_BY = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Assoc_rec.CREATED_BY := Null;
    END IF;

    IF g_Header_Adj_Assoc_rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE THEN
        g_Header_Adj_Assoc_rec.LAST_UPDATE_DATE := Null;
    END IF;

    IF g_Header_Adj_Assoc_rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Assoc_rec.LAST_UPDATED_BY := Null;
    END IF;

    IF g_Header_Adj_Assoc_rec.LAST_UPDATE_LOGIN = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Assoc_rec.LAST_UPDATE_LOGIN := Null;
    END IF;

    IF g_Header_Adj_Assoc_rec.PROGRAM_APPLICATION_ID = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Assoc_rec.PROGRAM_APPLICATION_ID := Null;
    END IF;

    IF g_Header_Adj_Assoc_rec.PROGRAM_ID = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Assoc_rec.PROGRAM_ID := Null;
    END IF;

    IF g_Header_Adj_Assoc_rec.PROGRAM_UPDATE_DATE = FND_API.G_MISS_DATE THEN
        g_Header_Adj_Assoc_rec.PROGRAM_UPDATE_DATE := Null;
    END IF;

    IF g_Header_Adj_Assoc_rec.REQUEST_ID = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Assoc_rec.REQUEST_ID := Null;
    END IF;

    IF g_Header_Adj_Assoc_rec.PRICE_ADJ_ASSOC_ID = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Assoc_rec.PRICE_ADJ_ASSOC_ID := Null;
    END IF;

    IF g_Header_Adj_Assoc_rec.LINE_ID = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Assoc_rec.LINE_ID := Null;
	end if;

    IF g_Header_Adj_Assoc_rec.RLTD_PRICE_ADJ_ID = FND_API.G_MISS_NUM THEN
        g_Header_Adj_Assoc_rec.RLTD_PRICE_ADJ_ID := Null;
    end if;



        --  Done defaulting attributes

        p_x_Header_Adj_Assoc_rec := g_Header_Adj_Assoc_rec;


END Attributes;

END OE_Default_Header_Adj_Assocs;

/
