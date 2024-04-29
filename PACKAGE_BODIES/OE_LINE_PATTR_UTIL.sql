--------------------------------------------------------
--  DDL for Package Body OE_LINE_PATTR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_PATTR_UTIL" AS
/* $Header: OEXULPAB.pls 115.33 2004/04/16 21:53:10 aycui ship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'OE_OE_Form_Order_Line_PAttr';

PROCEDURE Query_Row
(   p_order_price_attrib_id        IN  NUMBER
,   x_Line_Price_Att_Rec			IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Rec_Type
)
IS
  l_Line_Price_Att_Tbl		OE_Order_PUB.Line_Price_Att_Tbl_Type;
BEGIN
	Query_Rows
		( p_order_price_attrib_id  => p_order_price_attrib_id
		, x_Line_Price_Att_Tbl => l_Line_Price_Att_Tbl
		);

     x_Line_Price_Att_Rec := l_Line_Price_Att_Tbl(1);

END Query_Row;


PROCEDURE Query_Rows
(   p_order_price_attrib_id        IN  NUMBER :=
								FND_API.G_MISS_NUM
,	p_Line_id					IN NUMBER :=
								FND_API.G_MISS_NUM
,   x_Line_Price_Att_Tbl 		IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
)
IS
l_count		NUMBER;

CURSOR l_Line_price_att_csr IS
		SELECT
 			HEADER_ID
 			,LINE_ID
			,CREATION_DATE
 			,CREATED_BY
 			,LAST_UPDATE_DATE
 			,LAST_UPDATED_BY
 			,LAST_UPDATE_LOGIN
 			,PROGRAM_APPLICATION_ID
 			,PROGRAM_ID
 			,PROGRAM_UPDATE_DATE
 			,REQUEST_ID
 			,PRICING_CONTEXT
 			,PRICING_ATTRIBUTE1
 			,PRICING_ATTRIBUTE2
 			,PRICING_ATTRIBUTE3
 			,PRICING_ATTRIBUTE4
 			,PRICING_ATTRIBUTE5
 			,PRICING_ATTRIBUTE6
 			,PRICING_ATTRIBUTE7
 			,PRICING_ATTRIBUTE8
 			,PRICING_ATTRIBUTE9
 			,PRICING_ATTRIBUTE10
 			,PRICING_ATTRIBUTE11
 			,PRICING_ATTRIBUTE12
 			,PRICING_ATTRIBUTE13
 			,PRICING_ATTRIBUTE14
 			,PRICING_ATTRIBUTE15
 			,PRICING_ATTRIBUTE16
 			,PRICING_ATTRIBUTE17
 			,PRICING_ATTRIBUTE18
 			,PRICING_ATTRIBUTE19
 			,PRICING_ATTRIBUTE20
 			,PRICING_ATTRIBUTE21
 			,PRICING_ATTRIBUTE22
 			,PRICING_ATTRIBUTE23
 			,PRICING_ATTRIBUTE24
 			,PRICING_ATTRIBUTE25
 			,PRICING_ATTRIBUTE26
 			,PRICING_ATTRIBUTE27
 			,PRICING_ATTRIBUTE28
 			,PRICING_ATTRIBUTE29
 			,PRICING_ATTRIBUTE30
 			,PRICING_ATTRIBUTE31
 			,PRICING_ATTRIBUTE32
 			,PRICING_ATTRIBUTE33
 			,PRICING_ATTRIBUTE34
 			,PRICING_ATTRIBUTE35
 			,PRICING_ATTRIBUTE36
 			,PRICING_ATTRIBUTE37
 			,PRICING_ATTRIBUTE38
 			,PRICING_ATTRIBUTE39
 			,PRICING_ATTRIBUTE40
 			,PRICING_ATTRIBUTE41
 			,PRICING_ATTRIBUTE42
 			,PRICING_ATTRIBUTE43
 			,PRICING_ATTRIBUTE44
 			,PRICING_ATTRIBUTE45
 			,PRICING_ATTRIBUTE46
 			,PRICING_ATTRIBUTE47
 			,PRICING_ATTRIBUTE48
 			,PRICING_ATTRIBUTE49
 			,PRICING_ATTRIBUTE50
 			,PRICING_ATTRIBUTE51
 			,PRICING_ATTRIBUTE52
 			,PRICING_ATTRIBUTE53
 			,PRICING_ATTRIBUTE54
 			,PRICING_ATTRIBUTE55
 			,PRICING_ATTRIBUTE56
 			,PRICING_ATTRIBUTE57
 			,PRICING_ATTRIBUTE58
 			,PRICING_ATTRIBUTE59
 			,PRICING_ATTRIBUTE60
 			,PRICING_ATTRIBUTE61
 			,PRICING_ATTRIBUTE62
 			,PRICING_ATTRIBUTE63
 			,PRICING_ATTRIBUTE64
 			,PRICING_ATTRIBUTE65
 			,PRICING_ATTRIBUTE66
 			,PRICING_ATTRIBUTE67
 			,PRICING_ATTRIBUTE68
 			,PRICING_ATTRIBUTE69
 			,PRICING_ATTRIBUTE70
 			,PRICING_ATTRIBUTE71
 			,PRICING_ATTRIBUTE72
 			,PRICING_ATTRIBUTE73
 			,PRICING_ATTRIBUTE74
 			,PRICING_ATTRIBUTE75
			,PRICING_ATTRIBUTE76
 			,PRICING_ATTRIBUTE77
 			,PRICING_ATTRIBUTE78
 			,PRICING_ATTRIBUTE79
 			,PRICING_ATTRIBUTE80
 			,PRICING_ATTRIBUTE81
 			,PRICING_ATTRIBUTE82
 			,PRICING_ATTRIBUTE83
 			,PRICING_ATTRIBUTE84
 			,PRICING_ATTRIBUTE85
 			,PRICING_ATTRIBUTE86
 			,PRICING_ATTRIBUTE87
 			,PRICING_ATTRIBUTE88
 			,PRICING_ATTRIBUTE89
 			,PRICING_ATTRIBUTE90
 			,PRICING_ATTRIBUTE91
 			,PRICING_ATTRIBUTE92
 			,PRICING_ATTRIBUTE93
 			,PRICING_ATTRIBUTE94
 			,PRICING_ATTRIBUTE95
 			,PRICING_ATTRIBUTE96
 			,PRICING_ATTRIBUTE97
 			,PRICING_ATTRIBUTE98
 			,PRICING_ATTRIBUTE99
 			,PRICING_ATTRIBUTE100
 			,CONTEXT
 			,ATTRIBUTE1
 			,ATTRIBUTE2
 			,ATTRIBUTE3
 			,ATTRIBUTE4
 			,ATTRIBUTE5
 			,ATTRIBUTE6
 			,ATTRIBUTE7
 			,ATTRIBUTE8
 			,ATTRIBUTE9
 			,ATTRIBUTE10
 			,ATTRIBUTE11
 			,ATTRIBUTE12
 			,ATTRIBUTE13
 			,ATTRIBUTE14
 			,ATTRIBUTE15
 			,FLEX_TITLE
 			,ORDER_PRICE_ATTRIB_ID
			,OVERRIDE_FLAG
			,LOCK_CONTROL
                        ,ORIG_SYS_ATTS_REF
		FROM	OE_ORDER_PRICE_ATTRIBS
		WHERE ( ORDER_PRICE_ATTRIB_ID = p_order_price_attrib_id
			Or line_id = p_Line_Id );



BEGIN

	    IF
		 (p_order_price_attrib_id IS NOT NULL
		AND
		p_order_price_attrib_id <> FND_API.G_MISS_NUM)
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
			  	 ,   'Keys are mutually exclusive'
				 );
		 END IF;
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

     l_count := 1;
	FOR imp_rec IN l_Line_price_att_csr LOOP

	x_line_price_att_tbl(l_count).attribute1  := imp_rec.attribute1;
	x_line_price_att_tbl(l_count).attribute2  := imp_rec.attribute2;
	x_line_price_att_tbl(l_count).attribute3  := imp_rec.attribute3;
	x_line_price_att_tbl(l_count).attribute4  := imp_rec.attribute4;
	x_line_price_att_tbl(l_count).attribute5  := imp_rec.attribute5;
	x_line_price_att_tbl(l_count).attribute6  := imp_rec.attribute6;
	x_line_price_att_tbl(l_count).attribute7  := imp_rec.attribute7;
	x_line_price_att_tbl(l_count).attribute8  := imp_rec.attribute8;
	x_line_price_att_tbl(l_count).attribute9  := imp_rec.attribute9;
	x_line_price_att_tbl(l_count).attribute10  := imp_rec.attribute10;


	x_line_price_att_tbl(l_count).pricing_attribute1 := imp_rec.pricing_attribute1;
	x_line_price_att_tbl(l_count).pricing_attribute2 := imp_rec.pricing_attribute2;
	x_line_price_att_tbl(l_count).pricing_attribute3 := imp_rec.pricing_attribute3;
	x_line_price_att_tbl(l_count).pricing_attribute4 := imp_rec.pricing_attribute4;
	x_line_price_att_tbl(l_count).pricing_attribute5 := imp_rec.pricing_attribute5;
	x_line_price_att_tbl(l_count).pricing_attribute6 := imp_rec.pricing_attribute6;
	x_line_price_att_tbl(l_count).pricing_attribute7 := imp_rec.pricing_attribute7;
	x_line_price_att_tbl(l_count).pricing_attribute8 := imp_rec.pricing_attribute8;
	x_line_price_att_tbl(l_count).pricing_attribute9 := imp_rec.pricing_attribute9;
	x_line_price_att_tbl(l_count).pricing_attribute10 := imp_rec.pricing_attribute10;

	x_line_price_att_tbl(l_count).pricing_attribute11 := imp_rec.pricing_attribute11;
	x_line_price_att_tbl(l_count).pricing_attribute12 := imp_rec.pricing_attribute12;
	x_line_price_att_tbl(l_count).pricing_attribute13 := imp_rec.pricing_attribute13;
	x_line_price_att_tbl(l_count).pricing_attribute14 := imp_rec.pricing_attribute14;
	x_line_price_att_tbl(l_count).pricing_attribute15 := imp_rec.pricing_attribute15;
	x_line_price_att_tbl(l_count).pricing_attribute16 := imp_rec.pricing_attribute16;
	x_line_price_att_tbl(l_count).pricing_attribute17 := imp_rec.pricing_attribute17;
	x_line_price_att_tbl(l_count).pricing_attribute18 := imp_rec.pricing_attribute18;
	x_line_price_att_tbl(l_count).pricing_attribute19 := imp_rec.pricing_attribute19;
	x_line_price_att_tbl(l_count).pricing_attribute20 := imp_rec.pricing_attribute20;

	x_line_price_att_tbl(l_count).pricing_attribute21 := imp_rec.pricing_attribute21;
	x_line_price_att_tbl(l_count).pricing_attribute22 := imp_rec.pricing_attribute22;
	x_line_price_att_tbl(l_count).pricing_attribute23 := imp_rec.pricing_attribute23;
	x_line_price_att_tbl(l_count).pricing_attribute24 := imp_rec.pricing_attribute24;
	x_line_price_att_tbl(l_count).pricing_attribute25 := imp_rec.pricing_attribute25;
	x_line_price_att_tbl(l_count).pricing_attribute26 := imp_rec.pricing_attribute26;
	x_line_price_att_tbl(l_count).pricing_attribute27 := imp_rec.pricing_attribute27;
	x_line_price_att_tbl(l_count).pricing_attribute28 := imp_rec.pricing_attribute28;
	x_line_price_att_tbl(l_count).pricing_attribute29 := imp_rec.pricing_attribute29;
	x_line_price_att_tbl(l_count).pricing_attribute30 := imp_rec.pricing_attribute30;

	x_line_price_att_tbl(l_count).pricing_attribute31 := imp_rec.pricing_attribute31;
	x_line_price_att_tbl(l_count).pricing_attribute32 := imp_rec.pricing_attribute32;
	x_line_price_att_tbl(l_count).pricing_attribute33 := imp_rec.pricing_attribute33;
	x_line_price_att_tbl(l_count).pricing_attribute34 := imp_rec.pricing_attribute34;
	x_line_price_att_tbl(l_count).pricing_attribute35 := imp_rec.pricing_attribute35;
	x_line_price_att_tbl(l_count).pricing_attribute36 := imp_rec.pricing_attribute36;
	x_line_price_att_tbl(l_count).pricing_attribute37 := imp_rec.pricing_attribute37;
	x_line_price_att_tbl(l_count).pricing_attribute38 := imp_rec.pricing_attribute38;
	x_line_price_att_tbl(l_count).pricing_attribute39 := imp_rec.pricing_attribute39;
	x_line_price_att_tbl(l_count).pricing_attribute40 := imp_rec.pricing_attribute40;


	x_line_price_att_tbl(l_count).pricing_attribute41 := imp_rec.pricing_attribute41;
	x_line_price_att_tbl(l_count).pricing_attribute42 := imp_rec.pricing_attribute42;
	x_line_price_att_tbl(l_count).pricing_attribute43 := imp_rec.pricing_attribute43;
	x_line_price_att_tbl(l_count).pricing_attribute44 := imp_rec.pricing_attribute44;
	x_line_price_att_tbl(l_count).pricing_attribute45 := imp_rec.pricing_attribute45;
	x_line_price_att_tbl(l_count).pricing_attribute46 := imp_rec.pricing_attribute46;
	x_line_price_att_tbl(l_count).pricing_attribute47 := imp_rec.pricing_attribute47;
	x_line_price_att_tbl(l_count).pricing_attribute48 := imp_rec.pricing_attribute48;
	x_line_price_att_tbl(l_count).pricing_attribute49 := imp_rec.pricing_attribute49;
	x_line_price_att_tbl(l_count).pricing_attribute50 := imp_rec.pricing_attribute50;


	x_line_price_att_tbl(l_count).pricing_attribute51 := imp_rec.pricing_attribute51;
	x_line_price_att_tbl(l_count).pricing_attribute52 := imp_rec.pricing_attribute52;
	x_line_price_att_tbl(l_count).pricing_attribute53 := imp_rec.pricing_attribute53;
	x_line_price_att_tbl(l_count).pricing_attribute54 := imp_rec.pricing_attribute54;
	x_line_price_att_tbl(l_count).pricing_attribute55 := imp_rec.pricing_attribute55;
	x_line_price_att_tbl(l_count).pricing_attribute56 := imp_rec.pricing_attribute56;
	x_line_price_att_tbl(l_count).pricing_attribute57 := imp_rec.pricing_attribute57;
	x_line_price_att_tbl(l_count).pricing_attribute58 := imp_rec.pricing_attribute58;
	x_line_price_att_tbl(l_count).pricing_attribute59 := imp_rec.pricing_attribute59;
	x_line_price_att_tbl(l_count).pricing_attribute60 := imp_rec.pricing_attribute60;

	x_line_price_att_tbl(l_count).pricing_attribute61 := imp_rec.pricing_attribute61;
	x_line_price_att_tbl(l_count).pricing_attribute62 := imp_rec.pricing_attribute62;
	x_line_price_att_tbl(l_count).pricing_attribute63 := imp_rec.pricing_attribute63;
	x_line_price_att_tbl(l_count).pricing_attribute64 := imp_rec.pricing_attribute64;
	x_line_price_att_tbl(l_count).pricing_attribute65 := imp_rec.pricing_attribute65;
	x_line_price_att_tbl(l_count).pricing_attribute66 := imp_rec.pricing_attribute66;
	x_line_price_att_tbl(l_count).pricing_attribute67 := imp_rec.pricing_attribute67;
	x_line_price_att_tbl(l_count).pricing_attribute68 := imp_rec.pricing_attribute68;
	x_line_price_att_tbl(l_count).pricing_attribute69 := imp_rec.pricing_attribute69;
	x_line_price_att_tbl(l_count).pricing_attribute70 := imp_rec.pricing_attribute70;

	x_line_price_att_tbl(l_count).pricing_attribute71 := imp_rec.pricing_attribute71;
	x_line_price_att_tbl(l_count).pricing_attribute72 := imp_rec.pricing_attribute72;
	x_line_price_att_tbl(l_count).pricing_attribute73 := imp_rec.pricing_attribute73;
	x_line_price_att_tbl(l_count).pricing_attribute74 := imp_rec.pricing_attribute74;
	x_line_price_att_tbl(l_count).pricing_attribute75 := imp_rec.pricing_attribute75;
	x_line_price_att_tbl(l_count).pricing_attribute76 := imp_rec.pricing_attribute76;
	x_line_price_att_tbl(l_count).pricing_attribute77 := imp_rec.pricing_attribute77;
	x_line_price_att_tbl(l_count).pricing_attribute78 := imp_rec.pricing_attribute78;
	x_line_price_att_tbl(l_count).pricing_attribute79 := imp_rec.pricing_attribute79;
	x_line_price_att_tbl(l_count).pricing_attribute80 := imp_rec.pricing_attribute80;


	x_line_price_att_tbl(l_count).pricing_attribute81 := imp_rec.pricing_attribute81;
	x_line_price_att_tbl(l_count).pricing_attribute82 := imp_rec.pricing_attribute82;
	x_line_price_att_tbl(l_count).pricing_attribute83 := imp_rec.pricing_attribute83;
	x_line_price_att_tbl(l_count).pricing_attribute84 := imp_rec.pricing_attribute84;
	x_line_price_att_tbl(l_count).pricing_attribute85 := imp_rec.pricing_attribute85;
	x_line_price_att_tbl(l_count).pricing_attribute86 := imp_rec.pricing_attribute86;
	x_line_price_att_tbl(l_count).pricing_attribute87 := imp_rec.pricing_attribute87;
	x_line_price_att_tbl(l_count).pricing_attribute88 := imp_rec.pricing_attribute88;
	x_line_price_att_tbl(l_count).pricing_attribute89 := imp_rec.pricing_attribute89;
	x_line_price_att_tbl(l_count).pricing_attribute90 := imp_rec.pricing_attribute90;


	x_line_price_att_tbl(l_count).pricing_attribute91 := imp_rec.pricing_attribute91;
	x_line_price_att_tbl(l_count).pricing_attribute92 := imp_rec.pricing_attribute92;
	x_line_price_att_tbl(l_count).pricing_attribute93 := imp_rec.pricing_attribute93;
	x_line_price_att_tbl(l_count).pricing_attribute94 := imp_rec.pricing_attribute94;
	x_line_price_att_tbl(l_count).pricing_attribute95 := imp_rec.pricing_attribute95;
	x_line_price_att_tbl(l_count).pricing_attribute96 := imp_rec.pricing_attribute96;
	x_line_price_att_tbl(l_count).pricing_attribute97 := imp_rec.pricing_attribute97;
	x_line_price_att_tbl(l_count).pricing_attribute98 := imp_rec.pricing_attribute98;
	x_line_price_att_tbl(l_count).pricing_attribute99 := imp_rec.pricing_attribute99;
	x_line_price_att_tbl(l_count).pricing_attribute100 := imp_rec.pricing_attribute100;


	x_line_price_att_tbl(l_count).pricing_context := imp_rec.pricing_context;
	x_line_price_att_tbl(l_count).context := imp_rec.context;
	x_line_price_att_tbl(l_count).header_id := imp_rec.header_id;
	x_line_price_att_tbl(l_count).line_id := imp_rec.line_id;
 x_line_price_att_tbl(l_count).order_price_attrib_id := imp_rec.order_price_attrib_id;
	x_line_price_att_tbl(l_count).flex_title := imp_rec.flex_title;
	x_line_price_att_tbl(l_count).created_by := imp_rec.created_by;
	x_line_price_att_tbl(l_count).creation_date := imp_rec.creation_date;
	x_line_price_att_tbl(l_count).last_updated_by := imp_rec.last_updated_by;
	x_line_price_att_tbl(l_count).last_update_date := imp_rec.last_update_date;
	x_line_price_att_tbl(l_count).program_id := imp_rec.program_id;
x_line_price_att_tbl(l_count).program_application_id := imp_rec.program_application_id;

	x_line_price_att_tbl(l_count).override_flag := imp_rec.override_flag;
	x_line_price_att_tbl(l_count).lock_control := imp_rec.lock_control;
        x_line_price_att_tbl(l_count).orig_sys_atts_ref := imp_rec.orig_sys_atts_ref;
     -- set values for non-DB fields
     x_line_price_att_tbl(l_count).db_flag          := FND_API.G_TRUE;
     x_line_price_att_tbl(l_count).operation        := FND_API.G_MISS_CHAR;
     x_line_price_att_tbl(l_count).return_status    := FND_API.G_MISS_CHAR;

     l_count := l_count + 1;
  END LOOP;

  IF ( p_order_price_attrib_id IS NOT NULL
  	  and p_order_price_attrib_id <> FND_API.G_MISS_NUM )
	  AND
	  ( x_Line_price_att_tbl.COUNT = 0 )
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


/* Insert Row */
PROCEDURE Insert_Row
( p_Line_Price_Att_rec		IN OUT NOCOPY	OE_Order_PUB.Line_Price_Att_Rec_Type
)
IS
l_lock_control	 	NUMBER := 1;

BEGIN

	oe_debug_pub.add('Entering OE_Line_Patt_UTIL.INSERT_ROW', 1);

   INSERT INTO OE_ORDER_PRICE_ATTRIBS
   ( HEADER_ID
	,LINE_ID
	,CREATION_DATE
	,CREATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_LOGIN
	,PROGRAM_APPLICATION_ID
	,PROGRAM_ID
	,PROGRAM_UPDATE_DATE
	,REQUEST_ID
	,PRICING_CONTEXT
	,PRICING_ATTRIBUTE1
	,PRICING_ATTRIBUTE2
	,PRICING_ATTRIBUTE3
	,PRICING_ATTRIBUTE4
	,PRICING_ATTRIBUTE5
	,PRICING_ATTRIBUTE6
	,PRICING_ATTRIBUTE7
	,PRICING_ATTRIBUTE8
	,PRICING_ATTRIBUTE9
	,PRICING_ATTRIBUTE10
	,PRICING_ATTRIBUTE11
	,PRICING_ATTRIBUTE12
	,PRICING_ATTRIBUTE13
	,PRICING_ATTRIBUTE14
	,PRICING_ATTRIBUTE15
	,PRICING_ATTRIBUTE16
	,PRICING_ATTRIBUTE17
	,PRICING_ATTRIBUTE18
	,PRICING_ATTRIBUTE19
	,PRICING_ATTRIBUTE20
	,PRICING_ATTRIBUTE21
	,PRICING_ATTRIBUTE22
	,PRICING_ATTRIBUTE23
	,PRICING_ATTRIBUTE24
	,PRICING_ATTRIBUTE25
	,PRICING_ATTRIBUTE26
	,PRICING_ATTRIBUTE27
	,PRICING_ATTRIBUTE28
	,PRICING_ATTRIBUTE29
	,PRICING_ATTRIBUTE30
	,PRICING_ATTRIBUTE31
	,PRICING_ATTRIBUTE32
	,PRICING_ATTRIBUTE33
	,PRICING_ATTRIBUTE34
	,PRICING_ATTRIBUTE35
	,PRICING_ATTRIBUTE36
	,PRICING_ATTRIBUTE37
	,PRICING_ATTRIBUTE38
	,PRICING_ATTRIBUTE39
	,PRICING_ATTRIBUTE40
	,PRICING_ATTRIBUTE41
	,PRICING_ATTRIBUTE42
	,PRICING_ATTRIBUTE43
	,PRICING_ATTRIBUTE44
	,PRICING_ATTRIBUTE45
	,PRICING_ATTRIBUTE46
	,PRICING_ATTRIBUTE47
	,PRICING_ATTRIBUTE48
	,PRICING_ATTRIBUTE49
	,PRICING_ATTRIBUTE50
	,PRICING_ATTRIBUTE51
	,PRICING_ATTRIBUTE52
	,PRICING_ATTRIBUTE53
	,PRICING_ATTRIBUTE54
	,PRICING_ATTRIBUTE55
	,PRICING_ATTRIBUTE56
	,PRICING_ATTRIBUTE57
	,PRICING_ATTRIBUTE58
	,PRICING_ATTRIBUTE59
	,PRICING_ATTRIBUTE60
	,PRICING_ATTRIBUTE61
	,PRICING_ATTRIBUTE62
	,PRICING_ATTRIBUTE63
	,PRICING_ATTRIBUTE64
	,PRICING_ATTRIBUTE65
	,PRICING_ATTRIBUTE66
	,PRICING_ATTRIBUTE67
	,PRICING_ATTRIBUTE68
	,PRICING_ATTRIBUTE69
	,PRICING_ATTRIBUTE70
	,PRICING_ATTRIBUTE71
	,PRICING_ATTRIBUTE72
	,PRICING_ATTRIBUTE73
	,PRICING_ATTRIBUTE74
	,PRICING_ATTRIBUTE75
	,PRICING_ATTRIBUTE76
	,PRICING_ATTRIBUTE77
	,PRICING_ATTRIBUTE78
	,PRICING_ATTRIBUTE79
	,PRICING_ATTRIBUTE80
	,PRICING_ATTRIBUTE81
	,PRICING_ATTRIBUTE82
	,PRICING_ATTRIBUTE83
	,PRICING_ATTRIBUTE84
	,PRICING_ATTRIBUTE85
	,PRICING_ATTRIBUTE86
	,PRICING_ATTRIBUTE87
	,PRICING_ATTRIBUTE88
	,PRICING_ATTRIBUTE89
	,PRICING_ATTRIBUTE90
	,PRICING_ATTRIBUTE91
	,PRICING_ATTRIBUTE92
	,PRICING_ATTRIBUTE93
	,PRICING_ATTRIBUTE94
	,PRICING_ATTRIBUTE95
	,PRICING_ATTRIBUTE96
	,PRICING_ATTRIBUTE97
	,PRICING_ATTRIBUTE98
	,PRICING_ATTRIBUTE99
	,PRICING_ATTRIBUTE100
	,CONTEXT
	,ATTRIBUTE1
	,ATTRIBUTE2
	,ATTRIBUTE3
	,ATTRIBUTE4
	,ATTRIBUTE5
	,ATTRIBUTE6
	,ATTRIBUTE7
	,ATTRIBUTE8
	,ATTRIBUTE9
	,ATTRIBUTE10
	,ATTRIBUTE11
	,ATTRIBUTE12
	,ATTRIBUTE13
	,ATTRIBUTE14
	,ATTRIBUTE15
	,FLEX_TITLE
	,ORDER_PRICE_ATTRIB_ID
	,OVERRIDE_FLAG
	,LOCK_CONTROL
        ,ORIG_SYS_ATTS_REF
	)
   VALUES
   (  p_Line_Price_Att_rec.HEADER_ID
	,p_Line_Price_Att_rec.LINE_ID
	,p_Line_Price_Att_rec.CREATION_DATE
	,p_Line_Price_Att_rec.CREATED_BY
	,p_Line_Price_Att_rec.LAST_UPDATE_DATE
	,p_Line_Price_Att_rec.LAST_UPDATED_BY
	,p_Line_Price_Att_rec.LAST_UPDATE_LOGIN
	,p_Line_Price_Att_rec.PROGRAM_APPLICATION_ID
	,p_Line_Price_Att_rec.PROGRAM_ID
	,p_Line_Price_Att_rec.PROGRAM_UPDATE_DATE
	,p_Line_Price_Att_rec.REQUEST_ID
	,p_Line_Price_Att_rec.PRICING_CONTEXT
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE1
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE2
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE3
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE4
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE5
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE6
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE7
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE8
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE9
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE10
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE11
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE12
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE13
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE14
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE15
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE16
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE17
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE18
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE19
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE20
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE21
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE22
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE23
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE24
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE25
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE26
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE27
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE28
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE29
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE30
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE31
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE32
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE33
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE34
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE35
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE36
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE37
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE38
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE39
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE40
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE41
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE42
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE43
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE44
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE45
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE46
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE47
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE48
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE49
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE50
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE51
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE52
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE53
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE54
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE55
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE56
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE57
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE58
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE59
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE60
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE61
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE62
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE63
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE64
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE65
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE66
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE67
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE68
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE69
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE70
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE71
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE72
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE73
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE74
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE75
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE76
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE77
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE78
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE79
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE80
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE81
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE82
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE83
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE84
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE85
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE86
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE87
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE88
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE89
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE90
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE91
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE92
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE93
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE94
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE95
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE96
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE97
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE98
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE99
	,p_Line_Price_Att_rec.PRICING_ATTRIBUTE100
	,p_Line_Price_Att_rec.CONTEXT
	,p_Line_Price_Att_rec.ATTRIBUTE1
	,p_Line_Price_Att_rec.ATTRIBUTE2
	,p_Line_Price_Att_rec.ATTRIBUTE3
	,p_Line_Price_Att_rec.ATTRIBUTE4
	,p_Line_Price_Att_rec.ATTRIBUTE5
	,p_Line_Price_Att_rec.ATTRIBUTE6
	,p_Line_Price_Att_rec.ATTRIBUTE7
	,p_Line_Price_Att_rec.ATTRIBUTE8
	,p_Line_Price_Att_rec.ATTRIBUTE9
	,p_Line_Price_Att_rec.ATTRIBUTE10
	,p_Line_Price_Att_rec.ATTRIBUTE11
	,p_Line_Price_Att_rec.ATTRIBUTE12
	,p_Line_Price_Att_rec.ATTRIBUTE13
	,p_Line_Price_Att_rec.ATTRIBUTE14
	,p_Line_Price_Att_rec.ATTRIBUTE15
	,p_Line_Price_Att_rec.FLEX_TITLE
	,p_Line_Price_Att_rec.ORDER_PRICE_ATTRIB_ID
	,p_Line_Price_Att_rec.OVERRIDE_FLAG
	,l_lock_control
	,p_Line_Price_Att_rec.ORIG_SYS_ATTS_REF
      );

	p_Line_Price_Att_rec.lock_control := l_lock_control;

	oe_debug_pub.add('Exiting OE_Line_Patt_UTIL.INSERT_ROW', 1);

EXCEPTION

   WHEN OTHERS THEN

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
	   FND_MSG_PUB.Add_Exc_Msg
	(   G_PKG_NAME
	  ,   'Insert_Row'
	 );
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Insert_Row;


PROCEDURE Delete_Row
( p_order_price_attrib_id 	NUMBER :=
						FND_API.G_MISS_NUM
,   p_line_id                 NUMBER :=
						FND_API.G_MISS_NUM
)
IS
BEGIN
 IF p_line_id <> FND_API.G_MISS_NUM then

	DELETE FROM OE_ORDER_PRICE_ATTRIBS
	WHERE Line_Id = p_Line_id;
 Else
	DELETE FROM OE_ORDER_PRICE_ATTRIBS
	WHERE ORDER_PRICE_ATTRIB_ID = p_order_price_attrib_id;

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




/* Update Row */
PROCEDURE Update_Row
( p_Line_Price_Att_rec		IN OUT NOCOPY	OE_Order_PUB.Line_Price_Att_Rec_Type
)
IS
l_lock_control			NUMBER;

BEGIN

  oe_debug_pub.add('Entering OE_Line_PATT_UTIL.UPDATE_ROW', 1);

  -- increment lock_control by 1 whenever the record is updated
  SELECT lock_control
  INTO   l_lock_control
  FROM   OE_ORDER_PRICE_ATTRIBS
  WHERE  order_price_attrib_id = p_line_Price_Att_rec.order_price_attrib_id;

  l_lock_control := l_lock_control + 1;


  UPDATE OE_ORDER_PRICE_ATTRIBS
  SET HEADER_ID = p_Line_Price_Att_rec.HEADER_ID
	,LINE_ID		= 	p_Line_Price_Att_rec.LINE_ID
	,OVERRIDE_FLAG		= 	p_Line_Price_Att_rec.OVERRIDE_FLAG
	,CREATION_DATE	=	p_Line_Price_Att_rec.CREATION_DATE
	,CREATED_BY	= 	p_Line_Price_Att_rec.CREATED_BY
	,LAST_UPDATE_DATE	= p_Line_Price_Att_rec.LAST_UPDATE_DATE
	,LAST_UPDATED_BY = p_Line_Price_Att_rec.LAST_UPDATED_BY
	,LAST_UPDATE_LOGIN = p_Line_Price_Att_rec.LAST_UPDATE_LOGIN
	,PROGRAM_APPLICATION_ID = p_Line_Price_Att_rec.PROGRAM_APPLICATION_ID
	,PROGRAM_ID = p_Line_Price_Att_rec.PROGRAM_ID
	,PROGRAM_UPDATE_DATE = p_Line_Price_Att_rec.PROGRAM_UPDATE_DATE
	,REQUEST_ID = p_Line_Price_Att_rec.REQUEST_ID
	,PRICING_CONTEXT = p_Line_Price_Att_rec.PRICING_CONTEXT
	,PRICING_ATTRIBUTE1 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE1
	,PRICING_ATTRIBUTE2 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE2
	,PRICING_ATTRIBUTE3 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE3                  ,PRICING_ATTRIBUTE4 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE4
	,PRICING_ATTRIBUTE5 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE5
	,PRICING_ATTRIBUTE6 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE6
	,PRICING_ATTRIBUTE7 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE7
	,PRICING_ATTRIBUTE8 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE8
	,PRICING_ATTRIBUTE9 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE9
	,PRICING_ATTRIBUTE10 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE10
	,PRICING_ATTRIBUTE11 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE11
	,PRICING_ATTRIBUTE12 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE12
	,PRICING_ATTRIBUTE13 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE13
	,PRICING_ATTRIBUTE14 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE14
	,PRICING_ATTRIBUTE15 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE15
	,PRICING_ATTRIBUTE16 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE16
	,PRICING_ATTRIBUTE17 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE17
	,PRICING_ATTRIBUTE18 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE18
	,PRICING_ATTRIBUTE19 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE19
	,PRICING_ATTRIBUTE20 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE20
	,PRICING_ATTRIBUTE21 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE21
	,PRICING_ATTRIBUTE22 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE22
	,PRICING_ATTRIBUTE23 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE23
	,PRICING_ATTRIBUTE24 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE24
	,PRICING_ATTRIBUTE25 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE25
	,PRICING_ATTRIBUTE26 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE26
	,PRICING_ATTRIBUTE27 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE27
	,PRICING_ATTRIBUTE28 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE28
	,PRICING_ATTRIBUTE29 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE29
	,PRICING_ATTRIBUTE30 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE30
	,PRICING_ATTRIBUTE31 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE31
	,PRICING_ATTRIBUTE32 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE32
	,PRICING_ATTRIBUTE33 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE33
	,PRICING_ATTRIBUTE34 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE34
	,PRICING_ATTRIBUTE35 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE35
	,PRICING_ATTRIBUTE36 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE36
	,PRICING_ATTRIBUTE37 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE37
	,PRICING_ATTRIBUTE38 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE38
	,PRICING_ATTRIBUTE39 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE39
	,PRICING_ATTRIBUTE40 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE40
	,PRICING_ATTRIBUTE41 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE41
	,PRICING_ATTRIBUTE42 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE42
	,PRICING_ATTRIBUTE43 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE43
	,PRICING_ATTRIBUTE44 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE44
	,PRICING_ATTRIBUTE45 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE45
	,PRICING_ATTRIBUTE46 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE46
	,PRICING_ATTRIBUTE47 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE47
	,PRICING_ATTRIBUTE48 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE48
	,PRICING_ATTRIBUTE49 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE49
	,PRICING_ATTRIBUTE50 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE50
	,PRICING_ATTRIBUTE51 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE51
	,PRICING_ATTRIBUTE52 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE52
	,PRICING_ATTRIBUTE53 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE53
	,PRICING_ATTRIBUTE54 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE54
	,PRICING_ATTRIBUTE55 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE55
	,PRICING_ATTRIBUTE56 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE56
	,PRICING_ATTRIBUTE57 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE57
	,PRICING_ATTRIBUTE58 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE58
	,PRICING_ATTRIBUTE59 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE59
	,PRICING_ATTRIBUTE60 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE60
	,PRICING_ATTRIBUTE61 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE61
	,PRICING_ATTRIBUTE62 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE62
	,PRICING_ATTRIBUTE63 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE63
	,PRICING_ATTRIBUTE64 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE64
	,PRICING_ATTRIBUTE65 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE65
	,PRICING_ATTRIBUTE66 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE66
	,PRICING_ATTRIBUTE67 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE67
	,PRICING_ATTRIBUTE68 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE68
	,PRICING_ATTRIBUTE69 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE69
	,PRICING_ATTRIBUTE70 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE70
	,PRICING_ATTRIBUTE71 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE71
	,PRICING_ATTRIBUTE72 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE72
	,PRICING_ATTRIBUTE73 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE73
	,PRICING_ATTRIBUTE74 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE74
	,PRICING_ATTRIBUTE75 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE75
	,PRICING_ATTRIBUTE76 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE76
	,PRICING_ATTRIBUTE77 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE77
	,PRICING_ATTRIBUTE78 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE78
	,PRICING_ATTRIBUTE79 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE79
	,PRICING_ATTRIBUTE80 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE80
	,PRICING_ATTRIBUTE81 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE81
	,PRICING_ATTRIBUTE82 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE82
	,PRICING_ATTRIBUTE83 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE83
	,PRICING_ATTRIBUTE84 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE84
	,PRICING_ATTRIBUTE85 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE85
	,PRICING_ATTRIBUTE86 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE86
	,PRICING_ATTRIBUTE87 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE87
	,PRICING_ATTRIBUTE88 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE88
	,PRICING_ATTRIBUTE89 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE89
	,PRICING_ATTRIBUTE90 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE90
	,PRICING_ATTRIBUTE91 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE91
	,PRICING_ATTRIBUTE92 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE92
	,PRICING_ATTRIBUTE93 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE93
	,PRICING_ATTRIBUTE94 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE94
	,PRICING_ATTRIBUTE95 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE95
	,PRICING_ATTRIBUTE96 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE96
	,PRICING_ATTRIBUTE97 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE97
	,PRICING_ATTRIBUTE98 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE98
	,PRICING_ATTRIBUTE99 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE99
	,PRICING_ATTRIBUTE100 = p_Line_Price_Att_rec.PRICING_ATTRIBUTE100
	,ATTRIBUTE1	= p_Line_Price_Att_rec.ATTRIBUTE1
	,ATTRIBUTE2	= p_Line_Price_Att_rec.ATTRIBUTE2
	,ATTRIBUTE3	= p_Line_Price_Att_rec.ATTRIBUTE3
	,ATTRIBUTE4	= p_Line_Price_Att_rec.ATTRIBUTE4
	,ATTRIBUTE5	= p_Line_Price_Att_rec.ATTRIBUTE5
	,ATTRIBUTE6	= p_Line_Price_Att_rec.ATTRIBUTE6
	,ATTRIBUTE7	= p_Line_Price_Att_rec.ATTRIBUTE7
	,ATTRIBUTE8	= p_Line_Price_Att_rec.ATTRIBUTE8
	,ATTRIBUTE9	= p_Line_Price_Att_rec.ATTRIBUTE9
	,ATTRIBUTE10	= p_Line_Price_Att_rec.ATTRIBUTE10
	,ATTRIBUTE11	= 	p_Line_Price_Att_rec.ATTRIBUTE11
	,ATTRIBUTE12	= 	p_Line_Price_Att_rec.ATTRIBUTE12
	,ATTRIBUTE13	= 	p_Line_Price_Att_rec.ATTRIBUTE13
	,ATTRIBUTE14	= 	p_Line_Price_Att_rec.ATTRIBUTE14
	,ATTRIBUTE15	= 	p_Line_Price_Att_rec.ATTRIBUTE15
	,FLEX_TITLE = p_Line_Price_Att_rec.FLEX_TITLE
	,ORDER_PRICE_ATTRIB_ID = p_Line_Price_Att_rec.ORDER_PRICE_ATTRIB_ID
     ,LOCK_CONTROL = l_lock_control
     ,ORIG_SYS_ATTS_REF = p_Line_Price_Att_rec.ORIG_SYS_ATTS_REF
	WHERE ORDER_PRICE_ATTRIB_ID =
			p_Line_Price_Att_rec.order_price_attrib_id;

	p_Line_Price_Att_rec.lock_control := l_lock_control;

	oe_debug_pub.add('Exiting OE_Line_Patt_UTIL.UPDATE_ROW', 1);

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



PROCEDURE Clear_Dependent_Attr
(   p_attr_id                   IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Line_Price_Att_rec      IN OUT NOCOPY  OE_Order_PUB.Line_Price_Att_Rec_Type
,   p_old_Line_Price_Att_rec    IN  OE_Order_PUB.Line_Price_Att_Rec_Type :=
                                    OE_Order_PUB.G_MISS_LINE_PRICE_ATT_REC
-- ,   x_Line_Price_Att_rec      OUT OE_Order_PUB.Line_Price_Att_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                OE_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                OE_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

   -- x_Line_Price_Att_rec := p_Line_Price_Att_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute1,p_old_Line_price_att_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE1;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute10,p_old_Line_price_att_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE10;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute11,p_old_Line_price_att_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE11;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute12,p_old_Line_price_att_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE12;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute13,p_old_Line_price_att_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE13;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute14,p_old_Line_price_att_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE14;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute15,p_old_Line_price_att_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE15;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute2,p_old_Line_price_att_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE2;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute3,p_old_Line_price_att_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE3;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute4,p_old_Line_price_att_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE4;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute5,p_old_Line_price_att_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE5;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute6,p_old_Line_price_att_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE6;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute7,p_old_Line_price_att_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE7;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute8,p_old_Line_price_att_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE8;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.attribute9,p_old_Line_price_att_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE9;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.context,p_old_Line_price_att_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_CONTEXT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.created_by,p_old_Line_price_att_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_CREATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.creation_date,p_old_Line_price_att_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_CREATION_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.flex_title,p_old_Line_price_att_rec.flex_title)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_FLEX_TITLE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.header_id,p_old_Line_price_att_rec.header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_HEADER;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.last_updated_by,p_old_Line_price_att_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_LAST_UPDATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.last_update_date,p_old_Line_price_att_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.last_update_login,p_old_Line_price_att_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.line_id,p_old_Line_price_att_rec.line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_LINE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.order_price_attrib_id,p_old_Line_price_att_rec.order_price_attrib_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ORDER_PRICE_ATTRIB;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute1,p_old_Line_price_att_rec.pricing_attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE1;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute10,p_old_Line_price_att_rec.pricing_attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE10;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute100,p_old_Line_price_att_rec.pricing_attribute100)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE100;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute11,p_old_Line_price_att_rec.pricing_attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE11;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute12,p_old_Line_price_att_rec.pricing_attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE12;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute13,p_old_Line_price_att_rec.pricing_attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE13;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute14,p_old_Line_price_att_rec.pricing_attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE14;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute15,p_old_Line_price_att_rec.pricing_attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE15;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute16,p_old_Line_price_att_rec.pricing_attribute16)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE16;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute17,p_old_Line_price_att_rec.pricing_attribute17)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE17;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute18,p_old_Line_price_att_rec.pricing_attribute18)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE18;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute19,p_old_Line_price_att_rec.pricing_attribute19)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE19;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute2,p_old_Line_price_att_rec.pricing_attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE2;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute20,p_old_Line_price_att_rec.pricing_attribute20)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE20;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute21,p_old_Line_price_att_rec.pricing_attribute21)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE21;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute22,p_old_Line_price_att_rec.pricing_attribute22)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE22;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute23,p_old_Line_price_att_rec.pricing_attribute23)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE23;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute24,p_old_Line_price_att_rec.pricing_attribute24)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE24;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute25,p_old_Line_price_att_rec.pricing_attribute25)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE25;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute26,p_old_Line_price_att_rec.pricing_attribute26)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE26;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute27,p_old_Line_price_att_rec.pricing_attribute27)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE27;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute28,p_old_Line_price_att_rec.pricing_attribute28)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE28;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute29,p_old_Line_price_att_rec.pricing_attribute29)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE29;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute3,p_old_Line_price_att_rec.pricing_attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE3;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute30,p_old_Line_price_att_rec.pricing_attribute30)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE30;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute31,p_old_Line_price_att_rec.pricing_attribute31)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE31;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute32,p_old_Line_price_att_rec.pricing_attribute32)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE32;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute33,p_old_Line_price_att_rec.pricing_attribute33)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE33;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute34,p_old_Line_price_att_rec.pricing_attribute34)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE34;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute35,p_old_Line_price_att_rec.pricing_attribute35)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE35;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute36,p_old_Line_price_att_rec.pricing_attribute36)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE36;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute37,p_old_Line_price_att_rec.pricing_attribute37)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE37;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute38,p_old_Line_price_att_rec.pricing_attribute38)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE38;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute39,p_old_Line_price_att_rec.pricing_attribute39)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE39;
        END IF;


-- Stopped Here

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute4,p_old_Line_price_att_rec.pricing_attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE4;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute40,p_old_Line_price_att_rec.pricing_attribute40)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE40;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute41,p_old_Line_price_att_rec.pricing_attribute41)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE41;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute42,p_old_Line_price_att_rec.pricing_attribute42)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE42;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute43,p_old_Line_price_att_rec.pricing_attribute43)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE43;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute44,p_old_Line_price_att_rec.pricing_attribute44)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE44;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute45,p_old_Line_price_att_rec.pricing_attribute45)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE45;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute46,p_old_Line_price_att_rec.pricing_attribute46)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE46;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute47,p_old_Line_price_att_rec.pricing_attribute47)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE47;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute48,p_old_Line_price_att_rec.pricing_attribute48)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE48;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute49,p_old_Line_price_att_rec.pricing_attribute49)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE49;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute5,p_old_Line_price_att_rec.pricing_attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE5;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute50,p_old_Line_price_att_rec.pricing_attribute50)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE50;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute51,p_old_Line_price_att_rec.pricing_attribute51)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE51;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute52,p_old_Line_price_att_rec.pricing_attribute52)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE52;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute53,p_old_Line_price_att_rec.pricing_attribute53)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE53;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute54,p_old_Line_price_att_rec.pricing_attribute54)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE54;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute55,p_old_Line_price_att_rec.pricing_attribute55)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE55;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute56,p_old_Line_price_att_rec.pricing_attribute56)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE56;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute57,p_old_Line_price_att_rec.pricing_attribute57)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE57;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute58,p_old_Line_price_att_rec.pricing_attribute58)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE58;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute59,p_old_Line_price_att_rec.pricing_attribute59)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE59;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute6,p_old_Line_price_att_rec.pricing_attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE6;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute60,p_old_Line_price_att_rec.pricing_attribute60)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE60;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute61,p_old_Line_price_att_rec.pricing_attribute61)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE61;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute62,p_old_Line_price_att_rec.pricing_attribute62)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE62;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute63,p_old_Line_price_att_rec.pricing_attribute63)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE63;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute64,p_old_Line_price_att_rec.pricing_attribute64)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE64;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute65,p_old_Line_price_att_rec.pricing_attribute65)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE65;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute66,p_old_Line_price_att_rec.pricing_attribute66)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE66;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute67,p_old_Line_price_att_rec.pricing_attribute67)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE67;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute68,p_old_Line_price_att_rec.pricing_attribute68)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE68;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute69,p_old_Line_price_att_rec.pricing_attribute69)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE69;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute7,p_old_Line_price_att_rec.pricing_attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE7;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute70,p_old_Line_price_att_rec.pricing_attribute70)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE70;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute71,p_old_Line_price_att_rec.pricing_attribute71)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE71;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute72,p_old_Line_price_att_rec.pricing_attribute72)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE72;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute73,p_old_Line_price_att_rec.pricing_attribute73)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE73;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute74,p_old_Line_price_att_rec.pricing_attribute74)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE74;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute75,p_old_Line_price_att_rec.pricing_attribute75)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE75;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute76,p_old_Line_price_att_rec.pricing_attribute76)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE76;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute77,p_old_Line_price_att_rec.pricing_attribute77)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE77;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute78,p_old_Line_price_att_rec.pricing_attribute78)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE78;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute79,p_old_Line_price_att_rec.pricing_attribute79)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE79;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute8,p_old_Line_price_att_rec.pricing_attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE8;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute80,p_old_Line_price_att_rec.pricing_attribute80)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE80;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute81,p_old_Line_price_att_rec.pricing_attribute81)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE81;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute82,p_old_Line_price_att_rec.pricing_attribute82)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE82;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute83,p_old_Line_price_att_rec.pricing_attribute83)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE83;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute84,p_old_Line_price_att_rec.pricing_attribute84)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE84;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute85,p_old_Line_price_att_rec.pricing_attribute85)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE85;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute86,p_old_Line_price_att_rec.pricing_attribute86)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE86;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute87,p_old_Line_price_att_rec.pricing_attribute87)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE87;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute88,p_old_Line_price_att_rec.pricing_attribute88)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE88;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute89,p_old_Line_price_att_rec.pricing_attribute89)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE89;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute9,p_old_Line_price_att_rec.pricing_attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE9;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute90,p_old_Line_price_att_rec.pricing_attribute90)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE90;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute91,p_old_Line_price_att_rec.pricing_attribute91)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE91;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute92,p_old_Line_price_att_rec.pricing_attribute92)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE92;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute93,p_old_Line_price_att_rec.pricing_attribute93)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE93;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute94,p_old_Line_price_att_rec.pricing_attribute94)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE94;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute95,p_old_Line_price_att_rec.pricing_attribute95)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE95;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute96,p_old_Line_price_att_rec.pricing_attribute96)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE96;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute97,p_old_Line_price_att_rec.pricing_attribute97)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE97;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute98,p_old_Line_price_att_rec.pricing_attribute98)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE98;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_attribute99,p_old_Line_price_att_rec.pricing_attribute99)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE99;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.pricing_context,p_old_Line_price_att_rec.pricing_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_CONTEXT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.program_application_id,p_old_Line_price_att_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.program_id,p_old_Line_price_att_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PROGRAM;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.program_update_date,p_old_Line_price_att_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.request_id,p_old_Line_price_att_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_REQUEST;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Price_Att_rec.orig_sys_atts_ref,p_old_Line_price_att_rec.orig_sys_atts_ref)
       THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ORIG_SYS_ATTS_REF;
       END IF;

    ELSIF p_attr_id = G_OVERRIDE_FLAG THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_OVERRIDE_FLAG;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_CREATION_DATE;
    ELSIF p_attr_id = G_FLEX_TITLE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_FLEX_TITLE;
    ELSIF p_attr_id = G_HEADER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_HEADER;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_LINE;
    ELSIF p_attr_id = G_ORDER_PRICE_ATTRIB THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ORDER_PRICE_ATTRIB;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE1;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE10;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE100 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE100;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE11;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE12;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE13;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE14;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE15;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE16 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE16;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE17 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE17;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE18 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE18;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE19 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE19;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE2;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE20 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE20;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE21 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE21;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE22 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE22;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE23 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE23;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE24 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE24;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE25 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE25;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE26 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE26;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE27 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE27;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE28 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE28;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE29 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE29;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE3;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE30 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE30;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE31 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE31;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE32 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE32;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE33 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE33;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE34 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE34;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE35 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE35;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE36 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE36;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE37 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE37;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE38 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE38;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE39 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE39;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE4;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE40 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE40;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE41 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE41;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE42 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE42;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE43 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE43;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE44 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE44;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE45 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE45;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE46 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE46;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE47 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE47;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE48 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE48;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE49 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE49;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE5;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE50 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE50;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE51 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE51;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE52 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE52;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE53 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE53;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE54 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE54;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE55 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE55;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE56 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE56;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE57 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE57;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE58 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE58;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE59 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE59;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE6;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE60 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE60;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE61 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE61;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE62 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE62;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE63 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE63;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE64 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE64;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE65 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE65;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE66 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE66;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE67 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE67;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE68 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE68;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE69 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE69;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE7;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE70 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE70;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE71 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE71;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE72 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE72;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE73 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE73;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE74 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE74;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE75 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE75;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE76 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE76;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE77 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE77;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE78 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE78;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE79 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE79;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE8;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE80 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE80;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE81 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE81;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE82 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE82;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE83 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE83;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE84 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE84;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE85 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE85;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE86 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE86;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE87 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE87;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE88 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE88;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE89 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE89;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE9;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE90 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE90;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE91 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE91;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE92 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE92;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE93 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE93;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE94 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE94;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE95 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE95;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE96 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE96;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE97 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE97;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE98 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE98;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE99 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE99;
    ELSIF p_attr_id = G_PRICING_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PRICING_CONTEXT;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_REQUEST;

    ELSIF p_attr_id = G_ORIG_SYS_ATTS_REF THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_Line_PAttr_Util.G_ORIG_SYS_ATTS_REF;
    END IF;
END Clear_Dependent_Attr;


PROCEDURE Complete_Record
(   p_x_Line_Price_Att_rec      IN OUT NOCOPY  OE_Order_PUB.Line_Price_Att_Rec_Type
,   p_old_Line_price_att_rec    IN  OE_Order_PUB.Line_Price_Att_Rec_Type
)
IS

l_Line_price_att_rec   OE_Order_PUB.Line_Price_Att_Rec_Type := p_x_Line_Price_Att_rec;
BEGIN

    IF l_Line_price_att_rec.override_flag = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.override_flag := p_old_Line_price_att_rec.override_flag;
    END IF;

    IF l_Line_price_att_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute1 := p_old_Line_price_att_rec.attribute1;
    END IF;

    IF l_Line_price_att_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute10 := p_old_Line_price_att_rec.attribute10;
    END IF;

    IF l_Line_price_att_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute11 := p_old_Line_price_att_rec.attribute11;
    END IF;

    IF l_Line_price_att_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute12 := p_old_Line_price_att_rec.attribute12;
    END IF;

    IF l_Line_price_att_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute13 := p_old_Line_price_att_rec.attribute13;
    END IF;

    IF l_Line_price_att_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute14 := p_old_Line_price_att_rec.attribute14;
    END IF;

    IF l_Line_price_att_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute15 := p_old_Line_price_att_rec.attribute15;
    END IF;

    IF l_Line_price_att_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute2 := p_old_Line_price_att_rec.attribute2;
    END IF;

    IF l_Line_price_att_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute3 := p_old_Line_price_att_rec.attribute3;
    END IF;

    IF l_Line_price_att_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute4 := p_old_Line_price_att_rec.attribute4;
    END IF;

    IF l_Line_price_att_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute5 := p_old_Line_price_att_rec.attribute5;
    END IF;

    IF l_Line_price_att_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute6 := p_old_Line_price_att_rec.attribute6;
    END IF;

    IF l_Line_price_att_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute7 := p_old_Line_price_att_rec.attribute7;
    END IF;

    IF l_Line_price_att_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute8 := p_old_Line_price_att_rec.attribute8;
    END IF;

    IF l_Line_price_att_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute9 := p_old_Line_price_att_rec.attribute9;
    END IF;

    IF l_Line_price_att_rec.context = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.context := p_old_Line_price_att_rec.context;
    END IF;

    IF l_Line_price_att_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.created_by := p_old_Line_price_att_rec.created_by;
    END IF;

    IF l_Line_price_att_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Line_price_att_rec.creation_date := p_old_Line_price_att_rec.creation_date;
    END IF;

    IF l_Line_price_att_rec.flex_title = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.flex_title := p_old_Line_price_att_rec.flex_title;
    END IF;

    IF l_Line_price_att_rec.header_id = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.header_id := p_old_Line_price_att_rec.header_id;
    END IF;

    IF l_Line_price_att_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.last_updated_by := p_old_Line_price_att_rec.last_updated_by;
    END IF;

    IF l_Line_price_att_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Line_price_att_rec.last_update_date := p_old_Line_price_att_rec.last_update_date;
    END IF;

    IF l_Line_price_att_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.last_update_login := p_old_Line_price_att_rec.last_update_login;
    END IF;

    IF l_Line_price_att_rec.line_id = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.line_id := p_old_Line_price_att_rec.line_id;
    END IF;

    IF l_Line_price_att_rec.order_price_attrib_id = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.order_price_attrib_id := p_old_Line_price_att_rec.order_price_attrib_id;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute1 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute1 := p_old_Line_price_att_rec.pricing_attribute1;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute10 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute10 := p_old_Line_price_att_rec.pricing_attribute10;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute100 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute100 := p_old_Line_price_att_rec.pricing_attribute100;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute11 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute11 := p_old_Line_price_att_rec.pricing_attribute11;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute12 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute12 := p_old_Line_price_att_rec.pricing_attribute12;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute13 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute13 := p_old_Line_price_att_rec.pricing_attribute13;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute14 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute14 := p_old_Line_price_att_rec.pricing_attribute14;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute15 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute15 := p_old_Line_price_att_rec.pricing_attribute15;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute16 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute16 := p_old_Line_price_att_rec.pricing_attribute16;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute17 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute17 := p_old_Line_price_att_rec.pricing_attribute17;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute18 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute18 := p_old_Line_price_att_rec.pricing_attribute18;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute19 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute19 := p_old_Line_price_att_rec.pricing_attribute19;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute2 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute2 := p_old_Line_price_att_rec.pricing_attribute2;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute20 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute20 := p_old_Line_price_att_rec.pricing_attribute20;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute21 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute21 := p_old_Line_price_att_rec.pricing_attribute21;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute22 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute22 := p_old_Line_price_att_rec.pricing_attribute22;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute23 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute23 := p_old_Line_price_att_rec.pricing_attribute23;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute24 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute24 := p_old_Line_price_att_rec.pricing_attribute24;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute25 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute25 := p_old_Line_price_att_rec.pricing_attribute25;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute26 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute26 := p_old_Line_price_att_rec.pricing_attribute26;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute27 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute27 := p_old_Line_price_att_rec.pricing_attribute27;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute28 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute28 := p_old_Line_price_att_rec.pricing_attribute28;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute29 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute29 := p_old_Line_price_att_rec.pricing_attribute29;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute3 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute3 := p_old_Line_price_att_rec.pricing_attribute3;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute30 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute30 := p_old_Line_price_att_rec.pricing_attribute30;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute31 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute31 := p_old_Line_price_att_rec.pricing_attribute31;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute32 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute32 := p_old_Line_price_att_rec.pricing_attribute32;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute33 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute33 := p_old_Line_price_att_rec.pricing_attribute33;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute34 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute34 := p_old_Line_price_att_rec.pricing_attribute34;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute35 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute35 := p_old_Line_price_att_rec.pricing_attribute35;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute36 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute36 := p_old_Line_price_att_rec.pricing_attribute36;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute37 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute37 := p_old_Line_price_att_rec.pricing_attribute37;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute38 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute38 := p_old_Line_price_att_rec.pricing_attribute38;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute39 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute39 := p_old_Line_price_att_rec.pricing_attribute39;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute4 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute4 := p_old_Line_price_att_rec.pricing_attribute4;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute40 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute40 := p_old_Line_price_att_rec.pricing_attribute40;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute41 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute41 := p_old_Line_price_att_rec.pricing_attribute41;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute42 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute42 := p_old_Line_price_att_rec.pricing_attribute42;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute43 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute43 := p_old_Line_price_att_rec.pricing_attribute43;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute44 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute44 := p_old_Line_price_att_rec.pricing_attribute44;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute45 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute45 := p_old_Line_price_att_rec.pricing_attribute45;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute46 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute46 := p_old_Line_price_att_rec.pricing_attribute46;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute47 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute47 := p_old_Line_price_att_rec.pricing_attribute47;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute48 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute48 := p_old_Line_price_att_rec.pricing_attribute48;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute49 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute49 := p_old_Line_price_att_rec.pricing_attribute49;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute5 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute5 := p_old_Line_price_att_rec.pricing_attribute5;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute50 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute50 := p_old_Line_price_att_rec.pricing_attribute50;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute51 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute51 := p_old_Line_price_att_rec.pricing_attribute51;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute52 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute52 := p_old_Line_price_att_rec.pricing_attribute52;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute53 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute53 := p_old_Line_price_att_rec.pricing_attribute53;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute54 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute54 := p_old_Line_price_att_rec.pricing_attribute54;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute55 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute55 := p_old_Line_price_att_rec.pricing_attribute55;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute56 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute56 := p_old_Line_price_att_rec.pricing_attribute56;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute57 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute57 := p_old_Line_price_att_rec.pricing_attribute57;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute58 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute58 := p_old_Line_price_att_rec.pricing_attribute58;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute59 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute59 := p_old_Line_price_att_rec.pricing_attribute59;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute6 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute6 := p_old_Line_price_att_rec.pricing_attribute6;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute60 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute60 := p_old_Line_price_att_rec.pricing_attribute60;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute61 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute61 := p_old_Line_price_att_rec.pricing_attribute61;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute62 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute62 := p_old_Line_price_att_rec.pricing_attribute62;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute63 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute63 := p_old_Line_price_att_rec.pricing_attribute63;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute64 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute64 := p_old_Line_price_att_rec.pricing_attribute64;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute65 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute65 := p_old_Line_price_att_rec.pricing_attribute65;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute66 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute66 := p_old_Line_price_att_rec.pricing_attribute66;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute67 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute67 := p_old_Line_price_att_rec.pricing_attribute67;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute68 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute68 := p_old_Line_price_att_rec.pricing_attribute68;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute69 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute69 := p_old_Line_price_att_rec.pricing_attribute69;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute7 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute7 := p_old_Line_price_att_rec.pricing_attribute7;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute70 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute70 := p_old_Line_price_att_rec.pricing_attribute70;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute71 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute71 := p_old_Line_price_att_rec.pricing_attribute71;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute72 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute72 := p_old_Line_price_att_rec.pricing_attribute72;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute73 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute73 := p_old_Line_price_att_rec.pricing_attribute73;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute74 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute74 := p_old_Line_price_att_rec.pricing_attribute74;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute75 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute75 := p_old_Line_price_att_rec.pricing_attribute75;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute76 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute76 := p_old_Line_price_att_rec.pricing_attribute76;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute77 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute77 := p_old_Line_price_att_rec.pricing_attribute77;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute78 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute78 := p_old_Line_price_att_rec.pricing_attribute78;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute79 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute79 := p_old_Line_price_att_rec.pricing_attribute79;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute8 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute8 := p_old_Line_price_att_rec.pricing_attribute8;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute80 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute80 := p_old_Line_price_att_rec.pricing_attribute80;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute81 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute81 := p_old_Line_price_att_rec.pricing_attribute81;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute82 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute82 := p_old_Line_price_att_rec.pricing_attribute82;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute83 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute83 := p_old_Line_price_att_rec.pricing_attribute83;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute84 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute84 := p_old_Line_price_att_rec.pricing_attribute84;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute85 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute85 := p_old_Line_price_att_rec.pricing_attribute85;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute86 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute86 := p_old_Line_price_att_rec.pricing_attribute86;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute87 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute87 := p_old_Line_price_att_rec.pricing_attribute87;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute88 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute88 := p_old_Line_price_att_rec.pricing_attribute88;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute89 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute89 := p_old_Line_price_att_rec.pricing_attribute89;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute9 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute9 := p_old_Line_price_att_rec.pricing_attribute9;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute90 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute90 := p_old_Line_price_att_rec.pricing_attribute90;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute91 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute91 := p_old_Line_price_att_rec.pricing_attribute91;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute92 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute92 := p_old_Line_price_att_rec.pricing_attribute92;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute93 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute93 := p_old_Line_price_att_rec.pricing_attribute93;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute94 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute94 := p_old_Line_price_att_rec.pricing_attribute94;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute95 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute95 := p_old_Line_price_att_rec.pricing_attribute95;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute96 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute96 := p_old_Line_price_att_rec.pricing_attribute96;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute97 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute97 := p_old_Line_price_att_rec.pricing_attribute97;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute98 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute98 := p_old_Line_price_att_rec.pricing_attribute98;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute99 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute99 := p_old_Line_price_att_rec.pricing_attribute99;
    END IF;

    IF l_Line_price_att_rec.pricing_context = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_context := p_old_Line_price_att_rec.pricing_context;
    END IF;

    IF l_Line_price_att_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.program_application_id := p_old_Line_price_att_rec.program_application_id;
    END IF;

    IF l_Line_price_att_rec.program_id = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.program_id := p_old_Line_price_att_rec.program_id;
    END IF;

    IF l_Line_price_att_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_Line_price_att_rec.program_update_date := p_old_Line_price_att_rec.program_update_date;
    END IF;

    IF l_Line_price_att_rec.request_id = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.request_id := p_old_Line_price_att_rec.request_id;
    END IF;

    IF l_Line_price_att_rec.orig_sys_atts_ref = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.orig_sys_atts_ref := p_old_Line_price_att_rec.orig_sys_atts_ref;
    END IF;
    -- RETURN l_Line_price_att_rec;
    p_x_Line_price_att_rec := l_Line_price_att_rec;

END Complete_Record;

PROCEDURE Convert_Miss_To_Null
(   p_x_Line_Price_Att_rec        IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Rec_Type
)
IS
l_Line_price_att_rec   OE_Order_PUB.Line_Price_Att_Rec_Type := p_x_Line_Price_Att_rec;
BEGIN

    IF l_Line_price_att_rec.override_flag = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.override_flag := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute1 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute10 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute11 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute12 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute13 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute14 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute15 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute2 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute3 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute4 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute5 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute6 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute7 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute8 := NULL;
    END IF;

    IF l_Line_price_att_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.attribute9 := NULL;
    END IF;

    IF l_Line_price_att_rec.context = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.context := NULL;
    END IF;

    IF l_Line_price_att_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.created_by := NULL;
    END IF;

    IF l_Line_price_att_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Line_price_att_rec.creation_date := NULL;
    END IF;

    IF l_Line_price_att_rec.flex_title = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.flex_title := NULL;
    END IF;

    IF l_Line_price_att_rec.header_id = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.header_id := NULL;
    END IF;

    IF l_Line_price_att_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.last_updated_by := NULL;
    END IF;

    IF l_Line_price_att_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Line_price_att_rec.last_update_date := NULL;
    END IF;

    IF l_Line_price_att_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.last_update_login := NULL;
    END IF;

    IF l_Line_price_att_rec.line_id = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.line_id := NULL;
    END IF;

    IF l_Line_price_att_rec.order_price_attrib_id = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.order_price_attrib_id := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute1 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute1 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute10 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute10 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute100 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute100 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute11 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute11 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute12 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute12 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute13 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute13 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute14 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute14 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute15 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute15 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute16 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute16 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute17 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute17 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute18 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute18 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute19 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute19 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute2 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute2 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute20 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute20 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute21 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute21 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute22 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute22 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute23 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute23 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute24 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute24 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute25 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute25 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute26 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute26 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute27 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute27 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute28 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute28 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute29 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute29 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute3 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute3 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute30 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute30 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute31 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute31 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute32 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute32 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute33 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute33 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute34 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute34 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute35 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute35 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute36 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute36 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute37 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute37 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute38 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute38 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute39 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute39 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute4 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute4 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute40 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute40 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute41 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute41 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute42 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute42 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute43 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute43 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute44 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute44 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute45 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute45 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute46 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute46 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute47 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute47 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute48 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute48 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute49 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute49 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute5 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute5 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute50 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute50 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute51 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute51 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute52 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute52 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute53 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute53 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute54 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute54 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute55 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute55 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute56 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute56 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute57 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute57 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute58 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute58 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute59 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute59 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute6 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute6 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute60 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute60 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute61 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute61 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute62 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute62 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute63 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute63 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute64 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute64 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute65 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute65 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute66 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute66 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute67 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute67 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute68 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute68 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute69 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute69 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute7 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute7 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute70 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute70 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute71 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute71 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute72 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute72 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute73 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute73 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute74 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute74 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute75 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute75 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute76 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute76 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute77 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute77 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute78 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute78 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute79 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute79 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute8 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute8 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute80 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute80 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute81 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute81 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute82 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute82 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute83 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute83 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute84 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute84 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute85 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute85 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute86 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute86 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute87 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute87 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute88 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute88 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute89 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute89 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute9 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute9 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute90 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute90 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute91 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute91 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute92 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute92 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute93 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute93 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute94 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute94 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute95 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute95 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute96 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute96 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute97 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute97 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute98 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute98 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_attribute99 = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_attribute99 := NULL;
    END IF;

    IF l_Line_price_att_rec.pricing_context = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.pricing_context := NULL;
    END IF;

    IF l_Line_price_att_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.program_application_id := NULL;
    END IF;

    IF l_Line_price_att_rec.program_id = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.program_id := NULL;
    END IF;

    IF l_Line_price_att_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_Line_price_att_rec.program_update_date := NULL;
    END IF;

    IF l_Line_price_att_rec.request_id = FND_API.G_MISS_NUM THEN
        l_Line_price_att_rec.request_id := NULL;
    END IF;

    IF l_Line_price_att_rec.orig_sys_atts_ref = FND_API.G_MISS_CHAR THEN
        l_Line_price_att_rec.orig_sys_atts_ref := NULL;
    END IF;
    -- RETURN l_Line_price_att_rec;
    p_x_Line_price_att_rec := l_Line_price_att_rec;

END Convert_Miss_To_Null;

PROCEDURE Apply_Attribute_Changes
(   p_x_Line_Price_Att_rec      IN OUT NOCOPY  OE_Order_PUB.Line_Price_Att_Rec_Type
,   p_old_Line_price_att_rec    IN  OE_Order_PUB.Line_Price_Att_Rec_Type := OE_Order_PUB.G_MISS_LINE_PRICE_ATT_REC
)
IS
l_price_flag				boolean 	:= FALSE;
l_booked_flag				Varchar2(1) := 'N';
l_shipping_quantity 		number;
l_order_quantity_uom		VARCHAR2(3);
l_organization_id			NUMBER := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
l_ins_status				VARCHAR2(1);
l_industry				VARCHAR2(1);
l_dynamicSqlString			VARCHAR2(2000);
l_Return_Status 			Varchar2(1);
l_msg_name				VARCHAR2(200);
l_pricing_event                         VARCHAR2(30);
l_order_pricing_event                   VARCHAR2(30);
l_order_status_rec QP_UTIL_PUB.ORDER_LINES_STATUS_REC_TYPE;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--bug 2702382 begin
l_price_adj_id1   number;
l_tmp1 number;
l_tmp_price_flag	boolean 	:= FALSE;
l_lst_type_code varchar2(10);
l_lineid1 number;
CURSOR get_price_adj_ids(l_lineid1 IN NUMBER,l_list_hdr_id1 IN NUMBER)
is select price_adjustment_id,list_line_type_code from
oe_price_adjustments
where line_id = l_lineid1 and list_header_id = l_list_hdr_id1;

FUNCTION delete_price_adj(l_prc_adj_id IN number,l_lst_code IN varchar2)
RETURN BOOLEAN is
begin
  if l_lst_code in ('PRG','IUE','OID') then
    null;  --do not expect these cases to be overriden
  elsif l_lst_code = 'PBH' then
   delete from oe_price_adjustments where price_adjustment_id in
   (select rltd_price_adj_id from oe_price_adj_assocs where
    price_adjustment_id = l_prc_adj_id
    union
    select price_adjustment_id from oe_price_adj_assocs where
    price_adjustment_id = l_prc_adj_id
   );
   delete from oe_price_adj_assocs where
   price_adjustment_id = l_prc_adj_id;
  elsif l_lst_code in ('DIS','SUR') then
   begin
   --check if this is a freegoods lines adjustment if so, do not delete it
    select 1 into  l_tmp1
    from oe_price_adj_assocs opaa,oe_price_adjustments opa
    where opaa.rltd_price_adj_id = l_prc_adj_id and
    opaa.price_adjustment_id = opa.price_adjustment_id and
    opa.list_line_type_code = 'PRG';
   exception
    when no_data_found then
    --indicates not a free goods adjustment, so delete it
    oe_debug_pub.add('in free goods line no data found');
     delete from oe_price_adjustments where
     price_adjustment_id = l_prc_adj_id;
    when others then
     null;
   end;
  end if;
  if SQL%ROWCOUNT > 0 then
    RETURN TRUE;
  else
    RETURN FALSE;
  end if;
  exception
    when others then
     RETURN FALSE;
end;

--bug 2702382 end

BEGIN

    -- x_Line_price_att_rec := p_Line_Price_Att_rec;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.override_flag,p_old_Line_price_att_rec.override_flag)
    THEN
        l_price_flag := TRUE;
    END IF;



    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute1,p_old_Line_price_att_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute10,p_old_Line_price_att_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute11,p_old_Line_price_att_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute12,p_old_Line_price_att_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute13,p_old_Line_price_att_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute14,p_old_Line_price_att_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute15,p_old_Line_price_att_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute2,p_old_Line_price_att_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute3,p_old_Line_price_att_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute4,p_old_Line_price_att_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute5,p_old_Line_price_att_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute6,p_old_Line_price_att_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute7,p_old_Line_price_att_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute8,p_old_Line_price_att_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.attribute9,p_old_Line_price_att_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.context,p_old_Line_price_att_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.created_by,p_old_Line_price_att_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.creation_date,p_old_Line_price_att_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.flex_title,p_old_Line_price_att_rec.flex_title)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.header_id,p_old_Line_price_att_rec.header_id)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.last_updated_by,p_old_Line_price_att_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.last_update_date,p_old_Line_price_att_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.last_update_login,p_old_Line_price_att_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.line_id,p_old_Line_price_att_rec.line_id)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.order_price_attrib_id,p_old_Line_price_att_rec.order_price_attrib_id)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute1,p_old_Line_price_att_rec.pricing_attribute1)
    THEN
        l_price_flag := TRUE;
       -- lkxu: added for OTA integration, call the OTA API dynamically if
	  -- the pricing context is OTA_PRICING.
	  IF oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_context, 'OTA') THEN
         -- application id for OTA is 810.
	    --IF fnd_installation.get(810, 810, l_ins_status, l_industry) THEN

         -- bug 1701377
	    IF OE_GLOBALS.G_OTA_INSTALLED IS NULL THEN
		 OE_GLOBALS.G_OTA_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(810);
         END IF;

	    IF OE_GLOBALS.G_OTA_INSTALLED = 'Y' THEN
           BEGIN
		   SELECT order_quantity_uom
		   INTO   l_order_quantity_uom
		   FROM   oe_order_lines_all
		   WHERE  line_id = p_x_Line_Price_Att_rec.line_id;

		 EXCEPTION WHEN NO_DATA_FOUND THEN
		   null;
           END;

	      l_dynamicSqlString := '
	      Begin
	        OTA_CANCEL_API.upd_max_attendee(
			:p_line_id,
		 	:p_org_id,
			:p_max_attendee,
			:p_upm,
			:p_operation,
			:x_return_status,
			:x_msg_data);
            END;';

	       EXECUTE IMMEDIATE l_dynamicSqlString
		    USING IN p_x_Line_Price_Att_rec.line_id,
			  IN l_organization_id,
			  IN fnd_number.canonical_to_number(p_x_Line_Price_Att_rec.pricing_attribute1),
			  IN l_order_quantity_uom,
			  IN p_x_Line_Price_Att_rec.operation,
			  OUT l_return_status,
			  OUT l_msg_name;

	      oe_debug_pub.add('OTA call return status is: '||l_return_status,1);
	      oe_debug_pub.add('OTA call return message is: '||l_msg_name,1);

           IF l_return_status = 'E' THEN
		   oe_debug_pub.add('OTA API - Error.', 1);
		   FND_MESSAGE.SET_NAME('OTA',l_msg_name);
		   OE_MSG_PUB.ADD;
		   RAISE FND_API.G_EXC_ERROR;
           END IF;

         ELSE
	      oe_debug_pub.add('OTA module is not installed. ',1);
	    END IF;
       END IF;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute10,p_old_Line_price_att_rec.pricing_attribute10)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute100,p_old_Line_price_att_rec.pricing_attribute100)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute11,p_old_Line_price_att_rec.pricing_attribute11)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute12,p_old_Line_price_att_rec.pricing_attribute12)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute13,p_old_Line_price_att_rec.pricing_attribute13)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute14,p_old_Line_price_att_rec.pricing_attribute14)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute15,p_old_Line_price_att_rec.pricing_attribute15)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute16,p_old_Line_price_att_rec.pricing_attribute16)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute17,p_old_Line_price_att_rec.pricing_attribute17)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute18,p_old_Line_price_att_rec.pricing_attribute18)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute19,p_old_Line_price_att_rec.pricing_attribute19)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute2,p_old_Line_price_att_rec.pricing_attribute2)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute20,p_old_Line_price_att_rec.pricing_attribute20)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute21,p_old_Line_price_att_rec.pricing_attribute21)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute22,p_old_Line_price_att_rec.pricing_attribute22)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute23,p_old_Line_price_att_rec.pricing_attribute23)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute24,p_old_Line_price_att_rec.pricing_attribute24)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute25,p_old_Line_price_att_rec.pricing_attribute25)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute26,p_old_Line_price_att_rec.pricing_attribute26)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute27,p_old_Line_price_att_rec.pricing_attribute27)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute28,p_old_Line_price_att_rec.pricing_attribute28)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute29,p_old_Line_price_att_rec.pricing_attribute29)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute3,p_old_Line_price_att_rec.pricing_attribute3)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute30,p_old_Line_price_att_rec.pricing_attribute30)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute31,p_old_Line_price_att_rec.pricing_attribute31)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute32,p_old_Line_price_att_rec.pricing_attribute32)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute33,p_old_Line_price_att_rec.pricing_attribute33)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute34,p_old_Line_price_att_rec.pricing_attribute34)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute35,p_old_Line_price_att_rec.pricing_attribute35)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute36,p_old_Line_price_att_rec.pricing_attribute36)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute37,p_old_Line_price_att_rec.pricing_attribute37)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute38,p_old_Line_price_att_rec.pricing_attribute38)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute39,p_old_Line_price_att_rec.pricing_attribute39)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute4,p_old_Line_price_att_rec.pricing_attribute4)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute40,p_old_Line_price_att_rec.pricing_attribute40)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute41,p_old_Line_price_att_rec.pricing_attribute41)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute42,p_old_Line_price_att_rec.pricing_attribute42)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute43,p_old_Line_price_att_rec.pricing_attribute43)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute44,p_old_Line_price_att_rec.pricing_attribute44)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute45,p_old_Line_price_att_rec.pricing_attribute45)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute46,p_old_Line_price_att_rec.pricing_attribute46)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute47,p_old_Line_price_att_rec.pricing_attribute47)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute48,p_old_Line_price_att_rec.pricing_attribute48)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute49,p_old_Line_price_att_rec.pricing_attribute49)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute5,p_old_Line_price_att_rec.pricing_attribute5)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute50,p_old_Line_price_att_rec.pricing_attribute50)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute51,p_old_Line_price_att_rec.pricing_attribute51)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute52,p_old_Line_price_att_rec.pricing_attribute52)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute53,p_old_Line_price_att_rec.pricing_attribute53)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute54,p_old_Line_price_att_rec.pricing_attribute54)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute55,p_old_Line_price_att_rec.pricing_attribute55)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute56,p_old_Line_price_att_rec.pricing_attribute56)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute57,p_old_Line_price_att_rec.pricing_attribute57)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute58,p_old_Line_price_att_rec.pricing_attribute58)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute59,p_old_Line_price_att_rec.pricing_attribute59)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute6,p_old_Line_price_att_rec.pricing_attribute6)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute60,p_old_Line_price_att_rec.pricing_attribute60)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute61,p_old_Line_price_att_rec.pricing_attribute61)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute62,p_old_Line_price_att_rec.pricing_attribute62)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute63,p_old_Line_price_att_rec.pricing_attribute63)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute64,p_old_Line_price_att_rec.pricing_attribute64)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute65,p_old_Line_price_att_rec.pricing_attribute65)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute66,p_old_Line_price_att_rec.pricing_attribute66)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute67,p_old_Line_price_att_rec.pricing_attribute67)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute68,p_old_Line_price_att_rec.pricing_attribute68)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute69,p_old_Line_price_att_rec.pricing_attribute69)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute7,p_old_Line_price_att_rec.pricing_attribute7)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute70,p_old_Line_price_att_rec.pricing_attribute70)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute71,p_old_Line_price_att_rec.pricing_attribute71)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute72,p_old_Line_price_att_rec.pricing_attribute72)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute73,p_old_Line_price_att_rec.pricing_attribute73)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute74,p_old_Line_price_att_rec.pricing_attribute74)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute75,p_old_Line_price_att_rec.pricing_attribute75)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute76,p_old_Line_price_att_rec.pricing_attribute76)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute77,p_old_Line_price_att_rec.pricing_attribute77)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute78,p_old_Line_price_att_rec.pricing_attribute78)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute79,p_old_Line_price_att_rec.pricing_attribute79)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute8,p_old_Line_price_att_rec.pricing_attribute8)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute80,p_old_Line_price_att_rec.pricing_attribute80)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute81,p_old_Line_price_att_rec.pricing_attribute81)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute82,p_old_Line_price_att_rec.pricing_attribute82)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute83,p_old_Line_price_att_rec.pricing_attribute83)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute84,p_old_Line_price_att_rec.pricing_attribute84)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute85,p_old_Line_price_att_rec.pricing_attribute85)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute86,p_old_Line_price_att_rec.pricing_attribute86)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute87,p_old_Line_price_att_rec.pricing_attribute87)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute88,p_old_Line_price_att_rec.pricing_attribute88)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute89,p_old_Line_price_att_rec.pricing_attribute89)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute9,p_old_Line_price_att_rec.pricing_attribute9)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute90,p_old_Line_price_att_rec.pricing_attribute90)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute91,p_old_Line_price_att_rec.pricing_attribute91)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute92,p_old_Line_price_att_rec.pricing_attribute92)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute93,p_old_Line_price_att_rec.pricing_attribute93)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute94,p_old_Line_price_att_rec.pricing_attribute94)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute95,p_old_Line_price_att_rec.pricing_attribute95)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute96,p_old_Line_price_att_rec.pricing_attribute96)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute97,p_old_Line_price_att_rec.pricing_attribute97)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute98,p_old_Line_price_att_rec.pricing_attribute98)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_attribute99,p_old_Line_price_att_rec.pricing_attribute99)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.pricing_context,p_old_Line_price_att_rec.pricing_context)
    THEN
        l_price_flag := TRUE;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.program_application_id,p_old_Line_price_att_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.program_id,p_old_Line_price_att_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.program_update_date,p_old_Line_price_att_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.request_id,p_old_Line_price_att_rec.request_id)
    THEN
        NULL;
    END IF;

   IF NOT oe_globals.Equal(p_x_Line_Price_Att_rec.orig_sys_atts_ref,p_old_Line_price_att_rec.orig_sys_atts_ref)
   THEN
      NULL;
     END IF;
--for bug 2702382 begin
 if p_x_line_price_att_rec.operation = OE_GLOBALS.G_OPR_DELETE
    and  p_x_line_price_att_rec.flex_title = 'QP_ATTR_DEFNS_QUALIFIER'
    and p_x_line_price_att_rec.pricing_context = 'MODLIST'
    and p_x_line_price_att_rec.pricing_attribute1 is not null
  then
    IF (p_x_line_price_att_rec.pricing_attribute2 is not null) THEN
     begin
      select price_adjustment_id,list_line_type_code
      into l_price_adj_id1,l_lst_type_code
      from oe_price_adjustments
      where line_id = p_x_line_price_att_rec.line_id
      and   list_line_id = p_x_line_price_att_rec.pricing_attribute2
      and   updated_flag = 'Y';
      l_price_flag := delete_price_adj(l_price_adj_id1,l_lst_type_code);
     exception
      when others then
       oe_debug_pub.add('in no data found - apply attribute change');
       null;
     end;
    elsif p_x_line_price_att_rec.pricing_attribute2 is null THEN
     begin
      select 1 into l_tmp1 from dual
      where exists
      (select 1 from oe_price_adjustments where
      list_header_id = p_x_line_price_att_rec.pricing_attribute1
      and updated_flag = 'Y');
      for l_prj_adj_cur in
      get_price_adj_ids(p_x_line_price_att_rec.line_id,
      p_x_line_price_att_rec.pricing_attribute1)
      loop
       l_tmp_price_flag :=
       delete_price_adj(l_prj_adj_cur.price_adjustment_id,
       l_prj_adj_cur.list_line_type_code);
       if l_tmp_price_flag then
        l_price_flag := l_tmp_price_flag;
       end if;
      end loop;
     exception
      when others then
        null;
     end;
    end if;
 end if;
--for bug 2702382 end

    If l_price_flag Then

	   oe_debug_pub.ADD('Logging delayed request for pricing from OE_Line_PAttr_Util.apply_attribute_changes ', 1);
--2442012
      Begin
               Select booked_flag,shipping_quantity into
                        l_booked_flag,l_shipping_quantity
               From OE_Order_lines where
                  Line_id =       p_x_Line_Price_Att_rec.Line_Id;
               Exception when no_data_found then
                   Null;
      End;

      If l_shipping_quantity > 0 Then
           l_pricing_event := 'BATCH,BOOK,SHIP';
           l_order_pricing_event := 'ORDER,BOOK';
      Elsif  l_booked_flag='Y' Then
             l_pricing_event := 'BATCH,BOOK';
             l_order_pricing_event := 'ORDER,BOOK';
      Else
             l_pricing_event := 'BATCH';
             l_order_pricing_event := 'ORDER';
      End If;

      --Need to register changed line so that repricing for this line will happen
      oe_debug_pub.add(' Before calling registered changed lines from ulpab');
      OE_LINE_ADJ_UTIL.Register_Changed_Lines(p_line_id=> p_x_Line_Price_Att_rec.line_id,
                                              p_header_id=>p_x_Line_Price_Att_rec.header_id,
                                              p_operation=>OE_GLOBALS.G_OPR_UPDATE);
      oe_debug_pub.add(' After calling registered changed line');

      --for bug 2456108    begin
      if (p_x_line_price_att_rec.flex_title = 'QP_ATTR_DEFNS_QUALIFIER') then
        OE_delayed_requests_Pvt.log_request(
	p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
	p_entity_id         	=> p_x_Line_Price_Att_rec.line_id,
	p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
	p_requesting_entity_id   => p_x_Line_Price_Att_rec.line_id,
	p_request_unique_key1    => l_pricing_event,
	p_param1                 => p_x_Line_Price_Att_rec.header_id,
        p_param2                 => l_pricing_event,
	p_request_type           => OE_GLOBALS.G_PRICE_LINE,
	x_return_status          => l_return_status);
    elsif (p_x_line_price_att_rec.flex_title = 'QP_ATTR_DEFNS_PRICING') then

        -- for bug 3533776: Find out whether order event needs all lines to be sent
        QP_UTIL_PUB.Get_Order_Lines_Status(l_order_pricing_event,l_order_status_rec);

	IF l_debug_level  > 0 THEN
          oe_debug_pub.add('SummaryFlag:'||l_order_status_rec.SUMMARY_LINE_FLAG||'ALL_LINES_FLAG:'||
			 l_order_status_rec.ALL_LINES_FLAG||' CHANGED_LINE_FLAG:'||l_order_status_rec.CHANGED_LINES_FLAG);
          oe_debug_pub.add('G_DEFER_PRICING'||OE_GLOBALS.G_DEFER_PRICING);
          if (OE_GLOBALS.G_UI_FLAG) then
            oe_debug_pub.add('ui mode');
          end if;
	END IF;

        -- If 'ORDER' event doesn't require sending in all lines, let's just price the current line
	If  l_order_status_rec.ALL_LINES_FLAG = 'N'
	    AND l_order_status_rec.SUMMARY_LINE_FLAG = 'N'
	    AND (OE_GLOBALS.G_UI_FLAG)
            AND (OE_GLOBALS.G_DEFER_PRICING = 'N')  THEN
             OE_delayed_requests_Pvt.log_request(
        	p_entity_code 			=> OE_GLOBALS.G_ENTITY_LINE,
	        p_entity_id         	=> p_x_Line_Price_Att_rec.line_id,
	        p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
	        p_requesting_entity_id   => p_x_Line_Price_Att_rec.line_id,
	        p_request_unique_key1    => l_pricing_event,
	        p_param1                 => p_x_Line_Price_Att_rec.line_id,
                p_param2                 => l_pricing_event,
	        p_request_type           => OE_GLOBALS.G_PRICE_LINE,
	        x_return_status          => l_return_status);

	ELSE
            OE_delayed_requests_Pvt.log_request(
	    p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
	    p_entity_id         	=> p_x_Line_Price_Att_rec.Header_Id,
	    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
	    p_requesting_entity_id   => p_x_Line_Price_Att_rec.Header_Id,
	    p_request_unique_key1    => l_pricing_event,
	    p_param1                 => p_x_Line_Price_Att_rec.header_id,
       	    p_param2                 => l_pricing_event,
	    p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
	    x_return_status          => l_return_status);
	END IF;
     end if;  ---for bug 2456108  end

/*		Begin
			Select booked_flag,shipping_quantity into
				l_booked_flag,l_shipping_quantity
			From OE_Order_lines where
			Line_id =	p_x_Line_Price_Att_rec.Line_Id;
			Exception when no_data_found then
				Null;
		End;

	    	If l_booked_flag='Y' Then
           OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	=> p_x_Line_Price_Att_rec.Header_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_Line_Price_Att_rec.Header_Id,
				p_request_unique_key1    => 'BOOK',
		 		p_param1                 => p_x_Line_Price_Att_rec.header_id,
                 	p_param2                 => 'BOOK',
		 		p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 		x_return_status          => l_return_status);
		End If;

	    	If l_shipping_quantity > 0 Then
           OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	=> p_x_Line_Price_Att_rec.Line_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_Line_Price_Att_rec.Line_Id,
				p_request_unique_key1    => 'SHIP',
		 		p_param1                 => p_x_Line_Price_Att_rec.header_id,
                 	p_param2                 => 'SHIP',
		 		p_request_type           => OE_GLOBALS.G_PRICE_LINE,
		 		x_return_status          => l_return_status);
		End If;
*/--2442012
		l_Price_Flag := FALSE;

	End If;

END Apply_Attribute_Changes;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_x_Line_Price_Att_rec      IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Rec_Type
,   p_order_price_attrib_id    IN NUMBER := FND_API.G_MISS_NUM
)
IS
l_Line_Price_Att_rec     OE_Order_PUB.Line_Price_Att_Rec_Type;
l_order_price_attrib_id	NUMBER;
l_lock_control			NUMBER;

BEGIN

    oe_debug_pub.add('Entering OE_Line_Adj_Util.Lock_Row.', 1);
    SAVEPOINT Lock_Row;

    l_lock_control := NULL;

    IF p_order_price_attrib_id <> FND_API.G_MISS_NUM THEN
      l_order_price_attrib_id := p_order_price_attrib_id;
    ELSE
      l_order_price_attrib_id := p_x_Line_Price_Att_rec.order_price_attrib_id;
      l_lock_control := p_x_Line_Price_Att_rec.lock_control;
    END IF;

    SELECT order_price_attrib_id
    INTO   l_order_price_attrib_id
    FROM   oe_order_price_attribs
    WHERE  order_price_attrib_id = l_order_price_attrib_id
    FOR UPDATE NOWAIT;

    OE_Line_PAttr_Util.Query_Row
    (p_order_price_attrib_id	=> l_order_price_attrib_id
    ,x_Line_Price_Att_rec	=> p_x_Line_Price_Att_rec
    );


    oe_debug_pub.add('queried lock_control: '|| p_x_line_price_att_rec.lock_control, 1);

    -- If lock_control is not passed(is null or missing), then return the locked record.


    IF l_lock_control is null OR
       l_lock_control = FND_API.G_MISS_NUM
    THEN

        --  Set return status
        x_return_status                            := FND_API.G_RET_STS_SUCCESS;
        p_x_line_Price_Att_rec.return_status     := FND_API.G_RET_STS_SUCCESS;

        -- return for lock by ID.
	RETURN;

    END IF;

    --  Row locked. If the whole record is passed, then
    --  Compare lock_control.

    oe_debug_pub.add('compare ', 1);

    IF      OE_GLOBALS.Equal(p_x_line_Price_Att_rec.lock_control,
                             l_lock_control)
    THEN

        --  Row has not changed. Set out parameter.

        oe_debug_pub.add('locked row', 1);

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_line_Price_Att_rec.return_status       := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.
        oe_debug_pub.add('row changed by other user', 1);

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_line_Price_Att_rec.return_status       := FND_API.G_RET_STS_ERROR;

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
        p_x_Line_Price_Att_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Line_Price_Att_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        p_x_Line_Price_Att_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

-- procedure lock_rows
PROCEDURE Lock_Rows
(   p_order_price_attrib_id     IN NUMBER
							:= FND_API.G_MISS_NUM
,   p_line_id                   IN NUMBER
							:= FND_API.G_MISS_NUM
,   x_Line_Price_Att_tbl        OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS

  CURSOR lock_pattr_lines(p_line_id IN NUMBER) IS
  SELECT order_price_attrib_id
  FROM   oe_order_price_attribs
  WHERE  line_id = p_line_id
  FOR UPDATE NOWAIT;

  l_Line_Price_Att_tbl     OE_Order_PUB.Line_Price_Att_Tbl_Type;
  l_order_price_attrib_id	NUMBER;
  l_lock_control			NUMBER;

BEGIN

    oe_debug_pub.add('Entering OE_Line_PAttr_Util.Lock_Rows.', 1);

  IF (p_order_price_attrib_id IS NOT NULL AND
	 p_order_price_attrib_id <> FND_API.G_MISS_NUM) AND
     (p_line_id IS NOT NULL AND
	 p_line_id <> FND_API.G_MISS_NUM)
  THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 OE_MSG_PUB.Add_Exc_Msg
	 (  G_PKG_NAME
	 ,  'Lock_Rows'
	 ,  'Keys are mutually exclusive: order_price_attrib_id = ' ||
	    p_order_price_attrib_id || ', line_id = ' || p_line_id );
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_order_price_attrib_id <> FND_API.G_MISS_NUM THEN

    SELECT order_price_attrib_id
    INTO   l_order_price_attrib_id
    FROM   oe_order_price_attribs
    WHERE  order_price_attrib_id = p_order_price_attrib_id
    FOR UPDATE NOWAIT;
  END IF;

  -- null line_id shouldn't be passed in unnecessarily if
  -- order_price_attrib_id is passed in already.
  BEGIN
    IF p_line_id <> FND_API.G_MISS_NUM THEN
	 SAVEPOINT LOCK_ROWS;
	 OPEN lock_pattr_lines(p_line_id);

	 LOOP
	   FETCH lock_pattr_lines INTO l_order_price_attrib_id;
	   EXIT WHEN lock_pattr_lines%NOTFOUND;
      END LOOP;
      CLOSE lock_pattr_lines;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
	 ROLLBACK TO LOCK_ROWS;

	 IF lock_pattr_lines%ISOPEN THEN
        CLOSE lock_pattr_lines;
      END IF;

	 RAISE;
  END;


  OE_Line_PAttr_Util.Query_Rows
  ( p_order_price_attrib_id	=> p_order_price_attrib_id
  , p_line_id				=> p_line_id
  , x_Line_Price_Att_tbl		=> x_Line_Price_Att_tbl
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
          ,   'Lock_Row'
         );
       END IF;

    oe_debug_pub.add('Exiting OE_Line_PAttr_Util.Lock_Rows.', 1);


END lock_rows;

PROCEDURE copy_pricing_attributes
(	p_from_line_id			NUMBER
,	p_to_line_id			NUMBER
,	p_to_header_id			NUMBER
,	x_return_status  OUT NOCOPY  VARCHAR2
) IS

l_Header_Adj_tbl 			oe_order_pub.Header_adj_tbl_type;
l_Line_Adj_tbl 			oe_order_pub.Line_adj_tbl_type;
l_control_rec				Oe_Globals.Control_rec_type;
l_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_tbl_type;
l_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_tbl_type;
l_header_rec                	OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_action_request_tbl        OE_Order_PUB.request_tbl_type;
l_x_lot_serial_tbl            OE_Order_PUB.lot_serial_tbl_type;
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_price_Att_tbl_type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_tbl_type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_tbl_type;
l_x_Line_price_Att_tbl        OE_Order_PUB.Line_price_Att_tbl_type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_tbl_type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_tbl_type;
l_Line_Price_Att_tbl     	OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_msg_count                 number;
l_x_msg_data                  Varchar2(2000);
l_df_error_code			number := 0;
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
i		PLS_INTEGER;

BEGIN
  oe_debug_pub.add('Entering OE_Line_PAttr_Util.copy_pricing_attribtes.', 1);

	OE_Line_PAttr_Util.Query_rows(p_line_id	=> p_from_line_id
						    , x_Line_Price_att_tbl	=> l_Line_Price_Att_tbl);


     i := l_line_price_att_tbl.First;
	While i IS NOT NULL LOOP

     oe_debug_pub.add('Entering the LOOP ...  : ', 1);

     -- calling Pricing API to check if the pricing context is valid.
	QP_UTIL.validate_context_code(
		    p_flexfield_name => l_line_price_att_tbl(i).flex_title
		   ,p_application_short_name  => 'QP'
		   ,p_context_name            => l_line_price_att_tbl(i).pricing_context
		   ,p_error_code              => l_df_error_code);


     IF l_df_error_code = 0 THEN
	  -- copy it if the pricing context is valid, don't copy if it is invalid

	  l_line_price_att_tbl(i).operation := OE_GLOBALS.G_OPR_CREATE;
	  l_line_price_att_tbl(i).line_id := p_to_line_id;
	  l_line_price_att_tbl(i).header_id := p_to_header_id;
	  l_line_price_att_tbl(i).order_price_attrib_id := FND_API.G_MISS_NUM;

	  l_x_line_price_att_tbl(l_x_line_price_att_tbl.count+1)
							    := l_line_price_att_tbl(i);


     END IF;

	  i:= L_Line_Price_Att_Tbl.Next(i);

     END LOOP;


  IF l_x_line_price_att_tbl.count > 0 THEN

   -- set control record
   l_control_rec.controlled_operation := TRUE;
   l_control_rec.write_to_DB          := TRUE;
   l_control_rec.change_attributes    := TRUE;
   l_control_rec.default_attributes   := TRUE;
   l_control_rec.validate_entity      := TRUE;
   l_control_rec.clear_dependents     := TRUE;

   l_control_rec.process              := FALSE;
   l_control_rec.clear_api_cache      := FALSE;
   l_control_rec.clear_api_requests   := FALSE;


    --  Call OE_Order_PVT.Process_order

	oe_debug_pub.add('Before OE_Order_PVT.Process_order',1);

     -- OE_Globals.G_RECURSION_MODE := 'Y';


    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => l_x_msg_count
    ,   x_msg_data                    => l_x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_Line_Adj_tbl              => l_Line_Adj_tbl
    ,   p_x_Line_Adj_att_tbl          => l_Line_Adj_att_tbl
--  ,   x_header_rec                  => l_x_header_rec
    ,   p_x_header_rec                => l_header_rec
    ,   p_x_Header_Adj_tbl            => l_x_Header_Adj_tbl
    ,   p_x_header_price_att_tbl      => l_x_header_price_att_tbl
    ,   p_x_Header_Adj_att_tbl        => l_x_Header_Adj_att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
--serla begin
    ,   p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
--serla end
--  ,   p_x_line_tbl                  => l_x_line_tbl
    ,   p_x_line_tbl                  => l_line_tbl
 -- ,   x_Line_Adj_tbl                => l_x_Line_Adj_tbl
    ,   p_x_Line_Price_att_tbl        => l_x_Line_Price_att_tbl
 -- ,   x_Line_Adj_att_tbl            => l_x_Line_Adj_att_tbl
 -- ,   x_Line_Adj_Assoc_tbl          => l_x_Line_Adj_Assoc_tbl
    ,   p_x_Line_Adj_Assoc_tbl        => l_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
--serla begin
    ,   p_x_Line_Payment_tbl            => l_x_Line_Payment_tbl
--serla end
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_Tbl
    ,   p_x_action_request_tbl        => l_x_Action_Request_tbl
    ,   p_validation_level       	   => OE_GLOBALS.G_VALID_LEVEL_PARTIAL
    );

     --  OE_Globals.G_RECURSION_MODE := 'N';

  End IF;

	IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

     oe_debug_pub.add('Exiting OE_Line_PAttr_Util.copy_pricing_attribtes.', 1);

	Exception
	    	WHEN FND_API.G_EXC_ERROR THEN

		  	x_return_status := FND_API.G_RET_STS_ERROR;

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END copy_pricing_attributes;

-- Fixed bug 1857538
-- copy_model_pattr now takes only the line_id as parameter
-- Get the model_line_id and use it to inherit the
-- pricing attributes and pricing context

PROCEDURE copy_model_pattr
(
--	p_model_line_id		NUMBER
	p_to_line_id			NUMBER
,	x_return_status  OUT NOCOPY VARCHAR2
) IS

/* not needed, as per bug1857538

      CURSOR  Get_Option_Lines(p_model_line_id IN NUMBER)
      IS
      SELECT header_id, line_id
      FROM   oe_order_lines
      WHERE  top_model_line_id = p_model_line_id
      AND    (item_type_code = OE_GLOBALS.G_ITEM_OPTION
      OR      item_type_code = OE_GLOBALS.G_ITEM_CLASS
      OR      item_type_code = OE_GLOBALS.G_ITEM_KIT);
*/


l_from_header_id		NUMBER;
l_top_model_line_id			NUMBER;


BEGIN

  	oe_debug_pub.add('Entering OE_Line_PAttr_Util.copy_model_pattr.', 1);

	SELECT top_model_line_id, header_id
        INTO l_top_model_line_id, l_from_header_id
	FROM oe_order_lines
	WHERE line_id = p_to_line_id;

/* -- not needed, fixed bug 1857538

	OPEN Get_Option_Lines(p_model_line_id);
	LOOP
	  FETCH Get_Option_Lines INTO l_from_header_id, l_to_line_id;
	  EXIT WHEN Get_Option_Lines%NOTFOUND;
*/

  	oe_debug_pub.add('Copying pricing attributes for line '||p_to_line_id);

	  copy_pricing_attributes
		(	 p_from_line_id		=> l_top_model_line_id
			,p_to_line_id		=> p_to_line_id
			,p_to_header_id		=> l_from_header_id
			,x_return_status  	=> x_return_status
		);

/* --not needed, as per bug1857538
	END LOOP;
	CLOSE Get_Option_Lines;
*/


	IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

  	oe_debug_pub.add('Exiting OE_Line_PAttr_Util.copy_model_pattr.', 1);

	EXCEPTION
	    	WHEN FND_API.G_EXC_ERROR THEN

		  	x_return_status := FND_API.G_RET_STS_ERROR;

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END copy_model_pattr;

END OE_Line_PAttr_Util;

/
