--------------------------------------------------------
--  DDL for Package Body OE_LINE_PRICE_AATTR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_PRICE_AATTR_UTIL" AS
/* $Header: OEXULAAB.pls 120.0 2005/06/01 02:26:30 appldev noship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'Oe_Line_Price_Aattr_util';

PROCEDURE Query_Row
(   p_price_adj_attrib_id     IN  NUMBER
,   x_Line_Adj_Att_Rec		IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Rec_Type
)
IS

l_Line_Adj_Att_Tbl	 OE_Order_PUB.Line_Adj_Att_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	Query_Rows
		( p_price_adj_attrib_id => p_price_adj_attrib_id
		, x_Line_Adj_Att_Tbl => l_Line_Adj_Att_Tbl
		);

     x_Line_Adj_Att_Rec := l_Line_Adj_Att_Tbl(1);

END Query_Row;



PROCEDURE Query_Rows
(   p_price_adj_attrib_id           IN  NUMBER :=
								FND_API.G_MISS_NUM
,   p_price_adjustment_id           IN  NUMBER :=
								FND_API.G_MISS_NUM
,   x_Line_Adj_Att_Tbl			IN OUT NOCOPY OE_ORDER_PUB.Line_Adj_Att_Tbl_Type
)
IS
l_count		NUMBER;

CURSOR l_price_Adj_att_csr IS
		SELECT
	  	PRICE_ADJUSTMENT_ID
		,PRICING_CONTEXT
 		,PRICING_ATTRIBUTE
 		,CREATION_DATE
 		,CREATED_BY
 		,LAST_UPDATE_DATE
 		,LAST_UPDATED_BY
 		,LAST_UPDATE_LOGIN
 		,PROGRAM_APPLICATION_ID
 		,PROGRAM_ID
 		,PROGRAM_UPDATE_DATE
 		,REQUEST_ID
 		,PRICING_ATTR_VALUE_FROM
		,PRICING_ATTR_VALUE_TO
 		,COMPARISON_OPERATOR
 		,FLEX_TITLE
 		,PRICE_ADJ_ATTRIB_ID
		,LOCK_CONTROL
		from oe_price_adj_attribs where
		 PRICE_ADJ_ATTRIB_ID =  p_price_adj_attrib_id
	Union all
		SELECT
	  	PRICE_ADJUSTMENT_ID
		,PRICING_CONTEXT
 		,PRICING_ATTRIBUTE
 		,CREATION_DATE
 		,CREATED_BY
 		,LAST_UPDATE_DATE
 		,LAST_UPDATED_BY
 		,LAST_UPDATE_LOGIN
 		,PROGRAM_APPLICATION_ID
 		,PROGRAM_ID
 		,PROGRAM_UPDATE_DATE
 		,REQUEST_ID
 		,PRICING_ATTR_VALUE_FROM
		,PRICING_ATTR_VALUE_TO
 		,COMPARISON_OPERATOR
 		,FLEX_TITLE
 		,PRICE_ADJ_ATTRIB_ID
		,LOCK_CONTROL
		from oe_price_adj_attribs where
		price_adjustment_id = p_price_adjustment_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	l_count := 1;
	FOR iml_rec IN l_price_Adj_att_csr LOOP

 	x_Line_Adj_Att_Tbl(l_count).PRICE_ADJUSTMENT_ID 	:= iml_rec.PRICE_ADJUSTMENT_ID;
	x_Line_Adj_Att_Tbl(l_count).PRICING_CONTEXT		:= iml_rec.PRICING_CONTEXT;
 	x_Line_Adj_Att_Tbl(l_count).PRICING_ATTRIBUTE	:= iml_rec.PRICING_ATTRIBUTE;
 	x_Line_Adj_Att_Tbl(l_count).CREATION_DATE		:= iml_rec.CREATION_DATE;
 	x_Line_Adj_Att_Tbl(l_count).CREATED_BY			:= iml_rec.CREATED_BY;
 	x_Line_Adj_Att_Tbl(l_count).LAST_UPDATE_DATE	:= iml_rec.LAST_UPDATE_DATE;
 	x_Line_Adj_Att_Tbl(l_count).LAST_UPDATED_BY		:= iml_rec.LAST_UPDATED_BY;
 	x_Line_Adj_Att_Tbl(l_count).LAST_UPDATE_LOGIN	:= iml_rec.LAST_UPDATE_LOGIN;
 	x_Line_Adj_Att_Tbl(l_count).PROGRAM_APPLICATION_ID	:= iml_rec.PROGRAM_APPLICATION_ID;
 	x_Line_Adj_Att_Tbl(l_count).PROGRAM_ID				:= iml_rec.PROGRAM_ID;
 	x_Line_Adj_Att_Tbl(l_count).PROGRAM_UPDATE_DATE 		:= iml_rec.PROGRAM_UPDATE_DATE;
 	x_Line_Adj_Att_Tbl(l_count).REQUEST_ID				:= iml_rec.REQUEST_ID;
 	x_Line_Adj_Att_Tbl(l_count).PRICING_ATTR_VALUE_FROM	:= iml_rec.PRICING_ATTR_VALUE_FROM;
	x_Line_Adj_Att_Tbl(l_count).PRICING_ATTR_VALUE_TO	:= iml_rec.PRICING_ATTR_VALUE_TO;
 	x_Line_Adj_Att_Tbl(l_count).COMPARISON_OPERATOR		:= iml_rec.COMPARISON_OPERATOR;
 	x_Line_Adj_Att_Tbl(l_count).FLEX_TITLE				:= iml_rec.FLEX_TITLE;
 	x_Line_Adj_Att_Tbl(l_count).PRICE_ADJ_ATTRIB_ID 		:= iml_rec.PRICE_ADJ_ATTRIB_ID;
 	x_Line_Adj_Att_Tbl(l_count).LOCK_CONTROL 			:= iml_rec.LOCK_CONTROL;

	-- set values for non-DB fields
 	x_Line_Adj_Att_Tbl(l_count).db_flag 		:= FND_API.G_TRUE;
 	x_Line_Adj_Att_Tbl(l_count).operation 		:= FND_API.G_MISS_CHAR;
 	x_Line_Adj_Att_Tbl(l_count).return_status 	:= FND_API.G_MISS_CHAR;

	l_count := l_count + 1;
  END LOOP;

  IF ( p_price_Adj_attrib_id IS NOT NULL
  		and p_price_Adj_attrib_id <> FND_API.G_MISS_NUM)
	  AND
	  (x_Line_Adj_Att_tbl.COUNT = 0 )
	THEN
		RAISE NO_DATA_FOUND;
  END IF;

--  RETURN l_Line_Adj_Att_tbl;

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

PROCEDURE Insert_Row
( p_Line_Adj_Att_Rec			IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Rec_Type
)
IS
l_lock_control		NUMBER := 1;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 IF l_debug_level > 0 THEN
   oe_debug_pub.add('Entering  Oe_Line_Price_Aattr_util.insert_row');
 END IF;

	INSERT INTO OE_PRICE_ADJ_ATTRIBS
	( 	PRICE_ADJUSTMENT_ID
		,PRICING_CONTEXT
 		,PRICING_ATTRIBUTE
 		,CREATION_DATE
 		,CREATED_BY
 		,LAST_UPDATE_DATE
 		,LAST_UPDATED_BY
 		,LAST_UPDATE_LOGIN
 		,PROGRAM_APPLICATION_ID
 		,PROGRAM_ID
 		,PROGRAM_UPDATE_DATE
 		,REQUEST_ID
 		,PRICING_ATTR_VALUE_FROM
		,PRICING_ATTR_VALUE_TO
 		,COMPARISON_OPERATOR
 		,FLEX_TITLE
 		,PRICE_ADJ_ATTRIB_ID
		,LOCK_CONTROL
	)
	VALUES
	( 	p_Line_Adj_Att_Rec.PRICE_ADJUSTMENT_ID
		,p_Line_Adj_Att_Rec.PRICING_CONTEXT
 		,p_Line_Adj_Att_Rec.PRICING_ATTRIBUTE
 		,p_Line_Adj_Att_Rec.CREATION_DATE
 		,p_Line_Adj_Att_Rec.CREATED_BY
 		,p_Line_Adj_Att_Rec.LAST_UPDATE_DATE
 		,p_Line_Adj_Att_Rec.LAST_UPDATED_BY
 		,p_Line_Adj_Att_Rec.LAST_UPDATE_LOGIN
 		,p_Line_Adj_Att_Rec.PROGRAM_APPLICATION_ID
 		,p_Line_Adj_Att_Rec.PROGRAM_ID
 		,p_Line_Adj_Att_Rec.PROGRAM_UPDATE_DATE
 		,p_Line_Adj_Att_Rec.REQUEST_ID
 		,p_Line_Adj_Att_Rec.PRICING_ATTR_VALUE_FROM
		,p_Line_Adj_Att_Rec.PRICING_ATTR_VALUE_TO
 		,p_Line_Adj_Att_Rec.COMPARISON_OPERATOR
 		,p_Line_Adj_Att_Rec.FLEX_TITLE
 		,p_Line_Adj_Att_Rec.PRICE_ADJ_ATTRIB_ID
		,l_lock_control
	 );

 	p_Line_Adj_Att_Rec.lock_control := l_lock_control;

 IF l_debug_level > 0 THEN
   oe_debug_pub.add('Leaving  Oe_Line_Price_Aattr_util.insert_row');
 END IF;

EXCEPTION

   WHEN OTHERS THEN

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
	   FND_MSG_PUB.Add_Exc_Msg
	(   G_PKG_NAME
	  ,   'Insert_Row'
	 );
   END IF;

   IF l_debug_level > 0 THEN
     oe_debug_pub.add('Exceptions in Oe_Line_Price_Aattr_util.insert_row:'||SQLERRM);
   END IF;

   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

PROCEDURE Update_Row
( p_Line_Adj_Att_Rec			IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Rec_Type
)
IS
l_lock_control		NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 	SELECT 	lock_control
	INTO		l_lock_control
	FROM		OE_PRICE_ADJ_ATTRIBS
	WHERE	price_adj_attrib_id = p_Line_Adj_Att_rec.price_adj_attrib_id;

	l_lock_control := l_lock_control + 1;

	UPDATE OE_PRICE_ADJ_ATTRIBS
	SET 	PRICE_ADJUSTMENT_ID    = p_Line_Adj_Att_Rec.Price_Adjustment_id
		,PRICING_CONTEXT    = p_Line_Adj_Att_Rec.Pricing_Context
 		,PRICING_ATTRIBUTE      = p_Line_Adj_Att_Rec.Pricing_Attribute
 		,CREATION_DATE          = p_Line_Adj_Att_Rec.creation_date
 		,CREATED_BY             = p_Line_Adj_Att_Rec.created_by
 		,LAST_UPDATE_DATE       = p_Line_Adj_Att_Rec.last_update_date
 		,LAST_UPDATED_BY        = p_Line_Adj_Att_Rec.last_updated_by
 		,LAST_UPDATE_LOGIN      = p_Line_Adj_Att_Rec.last_update_login
 		,PROGRAM_APPLICATION_ID = p_Line_Adj_Att_Rec.program_application_id
 		,PROGRAM_ID              = p_Line_Adj_Att_Rec.program_id
 		,PROGRAM_UPDATE_DATE     = p_Line_Adj_Att_Rec.program_update_date
 		,REQUEST_ID              = p_Line_Adj_Att_Rec.request_id
 		,PRICING_ATTR_VALUE_FROM = p_Line_Adj_Att_Rec.pricing_attr_value_from
		,PRICING_ATTR_VALUE_TO   = p_Line_Adj_Att_Rec.pricing_attr_value_to
 		,COMPARISON_OPERATOR     = p_Line_Adj_Att_Rec.comparison_operator
 		,FLEX_TITLE              = p_Line_Adj_Att_Rec.flex_title
 		,PRICE_ADJ_ATTRIB_ID     = p_Line_Adj_Att_Rec.price_adj_attrib_id
		,LOCK_CONTROL			= l_lock_control

	WHERE PRICE_ADJ_ATTRIB_ID  = p_Line_Adj_Att_Rec.price_adj_attrib_id;

     p_Line_Adj_Att_Rec.lock_control := l_lock_control;


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



END Update_Row ;

PROCEDURE Delete_Row
( p_price_adj_attrib_id     NUMBER := FND_API.G_MISS_NUM
,   p_price_adjustment_id     NUMBER := FND_API.G_MISS_NUM
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF p_price_adjustment_id <> FND_API.G_MISS_NUM then
   --bug3528335 splitting the DELETE statement to delete attributes corresponding to child lines first (if the parent is PBH) and then the parent
--bug3405372 deleting the rows corresponding to the child lines of PBH modifiers as well.
        DELETE FROM OE_PRICE_ADJ_ATTRIBS
        WHERE PRICE_ADJUSTMENT_ID IN (SELECT RLTD_PRICE_ADJ_ID
				      FROM OE_PRICE_ADJ_ASSOCS ASSOCS,
				           OE_PRICE_ADJUSTMENTS PARENT
				      WHERE ASSOCS.PRICE_ADJUSTMENT_ID=PARENT.PRICE_ADJUSTMENT_ID
				      AND PARENT.PRICE_ADJUSTMENT_ID=p_price_adjustment_id
				      AND PARENT.LIST_LINE_TYPE_CODE='PBH');
	IF l_debug_level > 0 THEN
	   oe_debug_pub.add('pviprana: Deleted '||SQL%ROWCOUNT||' pricing attributes of child lines');
	END IF;



	DELETE  FROM OE_PRICE_ADJ_ATTRIBS
	WHERE   PRICE_ADJUSTMENT_ID = p_price_adjustment_id;
--bug3528335 end
else
	DELETE OE_PRICE_ADJ_ATTRIBS
	WHERE PRICE_ADJ_ATTRIB_ID   = p_price_adj_attrib_id;
end if;

EXCEPTION

WHEN OTHERS THEN
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		FND_MSG_PUB.Add_Exc_Msg
		(   G_PKG_NAME
		,   'Delete_Row'
		);
	END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

PROCEDURE Complete_Record
(   p_x_Line_Adj_Att_rec      IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Rec_Type
,   p_old_Line_Adj_Att_rec    IN  OE_Order_PUB.Line_Adj_Att_Rec_Type
)
IS

l_Line_Adj_Att_rec   OE_Order_PUB.Line_Adj_Att_Rec_Type := p_x_Line_Adj_Att_rec;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_Line_Adj_Att_rec.PRICE_ADJUSTMENT_ID = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.PRICE_ADJUSTMENT_ID := p_old_Line_Adj_Att_rec.PRICE_ADJUSTMENT_ID;
    END IF;

    IF l_Line_Adj_Att_rec.PRICING_CONTEXT = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_Att_rec.PRICING_CONTEXT := p_old_Line_Adj_Att_rec.PRICING_CONTEXT;
    END IF;

    IF l_Line_Adj_Att_rec.PRICING_ATTRIBUTE = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_Att_rec.PRICING_ATTRIBUTE := p_old_Line_Adj_Att_rec.PRICING_ATTRIBUTE;
    END IF;

    IF l_Line_Adj_Att_rec.CREATION_DATE = FND_API.G_MISS_DATE THEN
        l_Line_Adj_Att_rec.CREATION_DATE := p_old_Line_Adj_Att_rec.CREATION_DATE;
    END IF;

    IF l_Line_Adj_Att_rec.CREATED_BY = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.CREATED_BY := p_old_Line_Adj_Att_rec.CREATED_BY;
    END IF;

    IF l_Line_Adj_Att_rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE THEN
        l_Line_Adj_Att_rec.LAST_UPDATE_DATE := p_old_Line_Adj_Att_rec.LAST_UPDATE_DATE;
    END IF;

    IF l_Line_Adj_Att_rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.LAST_UPDATED_BY := p_old_Line_Adj_Att_rec.LAST_UPDATED_BY;
    END IF;

    IF l_Line_Adj_Att_rec.LAST_UPDATE_LOGIN = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.LAST_UPDATE_LOGIN := p_old_Line_Adj_Att_rec.LAST_UPDATE_LOGIN;
    END IF;

    IF l_Line_Adj_Att_rec.PROGRAM_APPLICATION_ID = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.PROGRAM_APPLICATION_ID := p_old_Line_Adj_Att_rec.PROGRAM_APPLICATION_ID;
    END IF;

    IF l_Line_Adj_Att_rec.PROGRAM_ID = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.PROGRAM_ID := p_old_Line_Adj_Att_rec.PROGRAM_ID;
    END IF;

    IF l_Line_Adj_Att_rec.PROGRAM_UPDATE_DATE = FND_API.G_MISS_DATE THEN
        l_Line_Adj_Att_rec.PROGRAM_UPDATE_DATE := p_old_Line_Adj_Att_rec.PROGRAM_UPDATE_DATE;
    END IF;

    IF l_Line_Adj_Att_rec.REQUEST_ID = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.REQUEST_ID := p_old_Line_Adj_Att_rec.REQUEST_ID;
    END IF;

    IF l_Line_Adj_Att_rec.PRICING_ATTR_VALUE_FROM = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_Att_rec.PRICING_ATTR_VALUE_FROM := p_old_Line_Adj_Att_rec.PRICING_ATTR_VALUE_FROM;
    END IF;

    IF l_Line_Adj_Att_rec.PRICING_ATTR_VALUE_TO = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_Att_rec.PRICING_ATTR_VALUE_TO := p_old_Line_Adj_Att_rec.PRICING_ATTR_VALUE_TO;
    END IF;

    IF l_Line_Adj_Att_rec.COMPARISON_OPERATOR = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_Att_rec.COMPARISON_OPERATOR := p_old_Line_Adj_Att_rec.COMPARISON_OPERATOR;
    END IF;

    IF l_Line_Adj_Att_rec.FLEX_TITLE = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_Att_rec.FLEX_TITLE := p_old_Line_Adj_Att_rec.FLEX_TITLE;
    END IF;

    IF l_Line_Adj_Att_rec.PRICE_ADJ_ATTRIB_ID = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.PRICE_ADJ_ATTRIB_ID := p_old_Line_Adj_Att_rec.PRICE_ADJ_ATTRIB_ID;
    END IF;

    -- RETURN l_Line_Adj_Att_rec;
    p_x_Line_Adj_Att_rec := l_Line_Adj_Att_rec;

END Complete_Record;

PROCEDURE Convert_Miss_To_Null
(   p_x_Line_Adj_Att_rec        IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Rec_Type
)
IS
l_Line_Adj_Att_rec   OE_Order_PUB.Line_Adj_Att_Rec_Type := p_x_Line_Adj_Att_rec;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_Line_Adj_Att_rec.PRICE_ADJUSTMENT_ID = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.PRICE_ADJUSTMENT_ID := Null;
    END IF;

    IF l_Line_Adj_Att_rec.PRICING_CONTEXT = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_Att_rec.PRICING_CONTEXT := Null;
    END IF;

    IF l_Line_Adj_Att_rec.PRICING_ATTRIBUTE = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_Att_rec.PRICING_ATTRIBUTE := Null;
    END IF;

    IF l_Line_Adj_Att_rec.CREATION_DATE = FND_API.G_MISS_DATE THEN
        l_Line_Adj_Att_rec.CREATION_DATE := Null;
    END IF;

    IF l_Line_Adj_Att_rec.CREATED_BY = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.CREATED_BY := Null;
    END IF;

    IF l_Line_Adj_Att_rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE THEN
        l_Line_Adj_Att_rec.LAST_UPDATE_DATE := Null;
    END IF;

    IF l_Line_Adj_Att_rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.LAST_UPDATED_BY := Null;
    END IF;

    IF l_Line_Adj_Att_rec.LAST_UPDATE_LOGIN = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.LAST_UPDATE_LOGIN := Null;
    END IF;

    IF l_Line_Adj_Att_rec.PROGRAM_APPLICATION_ID = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.PROGRAM_APPLICATION_ID := Null;
    END IF;

    IF l_Line_Adj_Att_rec.PROGRAM_ID = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.PROGRAM_ID := Null;
    END IF;

    IF l_Line_Adj_Att_rec.PROGRAM_UPDATE_DATE = FND_API.G_MISS_DATE THEN
        l_Line_Adj_Att_rec.PROGRAM_UPDATE_DATE := Null;
    END IF;

    IF l_Line_Adj_Att_rec.REQUEST_ID = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.REQUEST_ID := Null;
    END IF;

    IF l_Line_Adj_Att_rec.PRICING_ATTR_VALUE_FROM = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_Att_rec.PRICING_ATTR_VALUE_FROM := Null;
    END IF;

    IF l_Line_Adj_Att_rec.PRICING_ATTR_VALUE_TO = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_Att_rec.PRICING_ATTR_VALUE_TO := Null;
    END IF;

    IF l_Line_Adj_Att_rec.COMPARISON_OPERATOR = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_Att_rec.COMPARISON_OPERATOR := Null;
    END IF;

    IF l_Line_Adj_Att_rec.FLEX_TITLE = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_Att_rec.FLEX_TITLE := Null;
    END IF;

    IF l_Line_Adj_Att_rec.PRICE_ADJ_ATTRIB_ID = FND_API.G_MISS_NUM THEN
        l_Line_Adj_Att_rec.PRICE_ADJ_ATTRIB_ID := Null;
    END IF;

    -- RETURN l_Line_Adj_Att_rec;
    p_x_Line_Adj_Att_rec := l_Line_Adj_Att_rec;

END Convert_Miss_To_Null;

PROCEDURE Apply_Attribute_Changes
(   p_x_Line_Adj_Att_rec      IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Rec_Type
,   p_old_Line_Adj_Att_rec    IN  OE_Order_PUB.Line_Adj_Att_Rec_Type := OE_Order_PUB.G_MISS_Line_Adj_Att_REC
-- ,   x_Line_Adj_Att_rec     OUT OE_Order_PUB.Line_Adj_Att_Rec_Type
)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    -- x_Line_Adj_Att_rec := p_Line_Adj_Att_rec;
    p_x_Line_Adj_Att_rec := p_x_Line_Adj_Att_rec;

END Apply_Attribute_Changes;

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_Line_Adj_Att_rec      IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Rec_Type
,   p_price_adj_attrib_id	IN NUMBER := FND_API.G_MISS_NUM
)
is
l_Line_Adj_Att_rec       OE_Order_PUB.Line_Adj_Att_Rec_Type;
l_lock_control			NUMBER;
l_price_adj_attrib_id	NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_PRICE_PATTR_UTIL.LOCK_ROW.' , 1 ) ;
    END IF;
    SAVEPOINT Lock_Row;

    l_lock_control := NULL;

    IF p_price_adj_attrib_id <> FND_API.G_MISS_NUM THEN
       l_price_adj_attrib_id := p_price_adj_attrib_id;
    ELSE
      l_price_adj_attrib_id := p_x_Line_Adj_Att_rec.price_adj_attrib_id;
      l_lock_control := p_x_Line_Adj_Att_rec.lock_control;
    END IF;

    SELECT price_adj_attrib_id
    INTO   l_price_adj_attrib_id
    FROM   oe_price_adj_attribs
    WHERE  price_adj_attrib_id = l_price_adj_attrib_id
    FOR UPDATE NOWAIT;

    OE_Line_Price_Aattr_Util.Query_Row
    (p_price_adj_attrib_id	=> l_price_adj_attrib_id
    ,x_Line_Adj_Att_rec		=> p_x_Line_Adj_Att_rec
    );


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'QUERIED LOCK_CONTROL: '|| P_X_LINE_ADJ_ATT_REC.LOCK_CONTROL , 1 ) ;
    END IF;

    -- If lock_control is not passed(is null or missing), then return the locked record.

    IF l_lock_control is null OR
       l_lock_control = FND_API.G_MISS_NUM
    THEN

        --  Set return status
        x_return_status                          := FND_API.G_RET_STS_SUCCESS;
        p_x_Line_Adj_Att_rec.return_status     := FND_API.G_RET_STS_SUCCESS;

        -- return for lock by ID.
	RETURN;

    END IF;

    --  Row locked. If the whole record is passed, then
    --  Compare lock_control.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COMPARE ' , 1 ) ;
    END IF;

    IF      OE_GLOBALS.Equal(p_x_Line_Adj_Att_rec.lock_control,
                             l_lock_control)
    THEN

        --  Row has not changed. Set out parameter.

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LOCKED ROW' , 1 ) ;
        END IF;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_Line_Adj_Att_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ROW CHANGED BY OTHER USER' , 1 ) ;
        END IF;

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Line_Adj_Att_rec.return_status       := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            -- Release the lock
            ROLLBACK TO Lock_Row;

            fnd_message.set_name('ONT','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Line_Adj_Att_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Line_Adj_Att_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        p_x_Line_Adj_Att_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

end lock_row;

-- procedure lock_rows
PROCEDURE Lock_Rows
(   p_price_adj_attrib_id     IN NUMBER
							:= FND_API.G_MISS_NUM
,   p_price_adjustment_id     IN NUMBER
							:= FND_API.G_MISS_NUM
,   x_Line_Adj_Att_tbl       	OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

)
IS

  CURSOR lock_att_lines(p_price_adjustment_id IN NUMBER) IS
  SELECT price_adj_attrib_id
  FROM   oe_price_adj_attribs
  WHERE  price_adjustment_id = p_price_adjustment_id
  FOR UPDATE NOWAIT;

  l_Line_Adj_Att_tbl     	OE_Order_PUB.Line_Adj_Att_Tbl_Type;
  l_price_adj_attrib_id		NUMBER;
  l_lock_control			NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_PRICE_AATTR_UTIL.LOCK_ROWS.' , 1 ) ;
    END IF;

  IF (p_price_adj_attrib_id IS NOT NULL AND
	 p_price_adj_attrib_id <> FND_API.G_MISS_NUM) AND
     (p_price_adjustment_id IS NOT NULL AND
	 p_price_adjustment_id <> FND_API.G_MISS_NUM)
  THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 OE_MSG_PUB.Add_Exc_Msg
	 (  G_PKG_NAME
	 ,  'Lock_Rows'
	 ,  'Keys are mutually exclusive: price_adj_attrib_id = ' ||
	    p_price_adj_attrib_id || ', price_adjustment_id = ' || p_price_adjustment_id );
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_price_adj_attrib_id <> FND_API.G_MISS_NUM THEN

    SELECT price_adj_attrib_id
    INTO   l_price_adj_attrib_id
    FROM   oe_price_adj_attribs
    WHERE  price_adj_attrib_id = p_price_adj_attrib_id
    FOR UPDATE NOWAIT;
  END IF;

  -- null price_adjustment_id shouldn't be passed in unnecessarily if
  -- price_adj_attrib_id is passed in already.
  BEGIN
    IF p_price_adjustment_id <> FND_API.G_MISS_NUM THEN
	 SAVEPOINT LOCK_ROWS;
	 OPEN lock_att_lines(p_price_adjustment_id);

	 LOOP
	   FETCH lock_att_lines INTO l_price_adj_attrib_id;
	   EXIT WHEN lock_att_lines%NOTFOUND;
      END LOOP;
      CLOSE lock_att_lines;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
	 ROLLBACK TO LOCK_ROWS;

	 IF lock_att_lines%ISOPEN THEN
        CLOSE lock_att_lines;
      END IF;

	 RAISE;
  END;


  OE_Line_Price_Aattr_Util.Query_Rows
  ( p_price_adj_attrib_id	=> p_price_adj_attrib_id
  , p_price_adjustment_id	=> p_price_adjustment_id
  , x_Line_Adj_Att_tbl		=> x_Line_Adj_Att_tbl
  );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

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

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_PRICE_AATTR_UTIL.LOCK_ROWS.' , 1 ) ;
    END IF;


END lock_rows;

END Oe_Line_Price_Aattr_util;

/
