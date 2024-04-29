--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_LINE_PATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_LINE_PATTR" AS
/* $Header: OEXFLPAB.pls 120.0.12010000.3 2009/06/23 11:10:42 amimukhe ship $ */


G_PKG_NAME              CONSTANT VARCHAR2(30) := 'OE_OE_Form_Line_PAttr';

g_Line_Price_Att_rec	OE_Order_PUB.Line_Price_Att_Rec_Type
					  	:= OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_REC;
g_db_Line_Price_Att_rec	OE_Order_PUB.Line_Price_Att_Rec_Type
						:= OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_REC;


/* Get Line Pricing Attr */
PROCEDURE Write_Order_Line_PAttr
(	p_Line_Price_Att_rec	IN OE_Order_PUB.Line_Price_Att_Rec_Type
,	p_db_record			IN BOOLEAN := FALSE
);

PROCEDURE Get_Order_Line_PAttr
(
	p_db_record			IN	BOOLEAN := FALSE
, 	p_order_price_attrib_id	IN 	NUMBER
,    x_Line_Price_Att_Rec 	IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Rec_Type
);

PROCEDURE Clear_Order_Line_Attr;


PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id				 in  NUMBER
,   p_line_id					 in  NUMBER
, x_attribute1 OUT NOCOPY VARCHAR2

, x_attribute10 OUT NOCOPY VARCHAR2

, x_attribute11 OUT NOCOPY VARCHAR2

, x_attribute12 OUT NOCOPY VARCHAR2

, x_attribute13 OUT NOCOPY VARCHAR2

, x_attribute14 OUT NOCOPY VARCHAR2

, x_attribute15 OUT NOCOPY VARCHAR2

, x_attribute2 OUT NOCOPY VARCHAR2

, x_attribute3 OUT NOCOPY VARCHAR2

, x_attribute4 OUT NOCOPY VARCHAR2

, x_attribute5 OUT NOCOPY VARCHAR2

, x_attribute6 OUT NOCOPY VARCHAR2

, x_attribute7 OUT NOCOPY VARCHAR2

, x_attribute8 OUT NOCOPY VARCHAR2

, x_attribute9 OUT NOCOPY VARCHAR2

, x_flex_title OUT NOCOPY VARCHAR2

, x_context OUT NOCOPY VARCHAR2

, x_header_id OUT NOCOPY NUMBER

, x_line_id OUT NOCOPY NUMBER

, x_order_price_attrib_id OUT NOCOPY NUMBER

, x_pricing_attribute1 OUT NOCOPY VARCHAR2

, x_pricing_attribute2 OUT NOCOPY VARCHAR2

, x_pricing_attribute3 OUT NOCOPY VARCHAR2

, x_pricing_context OUT NOCOPY VARCHAR2

, x_override_flag OUT NOCOPY VARCHAR2

, x_creation_date OUT NOCOPY DATE

) Is

l_Line_Price_Att_rec	OE_Order_PUB.Line_Price_Att_Rec_Type;
l_Line_Price_Att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl          OE_Order_PUB.Request_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_Header_Price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_Price_Att_Rec    	OE_Order_PUB.Line_Price_Att_Rec_Type;
l_x_Line_Price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_old_Line_Price_Att_tbl    OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_old_Line_Price_Att_Rec    OE_Order_PUB.Line_Price_Att_Rec_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENERING OE_OE_FORM_LINE_PATTR.DEFAULT_ATTRIBUTE.' , 1 ) ;
    END IF;
    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

-- Set Control Flags
	l_control_rec.controlled_operation := TRUE;
	l_control_rec.check_security       := TRUE;
	l_control_rec.default_attributes   := TRUE;
	l_control_rec.change_attributes    := TRUE;

	l_control_rec.clear_dependents     := FALSE;
	l_control_rec.validate_entity      := FALSE;
	l_control_rec.write_to_DB          := FALSE;
	l_control_rec.process              := FALSE;

	--  Instruct API to retain its caches
	l_control_rec.clear_api_cache      := FALSE;
	l_control_rec.clear_api_requests   := FALSE;
-----------------------------------------------
-- Set attributes to NULL
-----------------------------------------------

     l_x_old_line_price_att_rec := OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_REC;
     l_x_line_price_att_rec := OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_REC;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' BEFORE SETTING THINGS TO NULL: OE_ORDER_ADJ_PVT.LINE_PRICE_ATTS' ) ;
     END IF;
	l_x_Line_Price_Att_Rec.header_id := p_header_id;
	l_x_Line_Price_Att_Rec.Line_id := p_Line_id;
	l_x_Line_Price_Att_Rec.context := NULL;
	l_x_Line_Price_Att_Rec.attribute1 := NULL;
	l_x_Line_Price_Att_Rec.attribute2 := NULL;
	l_x_Line_Price_Att_Rec.attribute3 := NULL;
	l_x_Line_Price_Att_Rec.attribute4 := NULL;
	l_x_Line_Price_Att_Rec.attribute5 := NULL;
	l_x_Line_Price_Att_Rec.attribute6 := NULL;
	l_x_Line_Price_Att_Rec.attribute7 := NULL;
	l_x_Line_Price_Att_Rec.attribute8 := NULL;
	l_x_Line_Price_Att_Rec.attribute9 := NULL;
	l_x_Line_Price_Att_Rec.attribute10 := NULL;
	l_x_Line_Price_Att_Rec.attribute11 := NULL;
	l_x_Line_Price_Att_Rec.attribute12 := NULL;
	l_x_Line_Price_Att_Rec.attribute13 := NULL;
	l_x_Line_Price_Att_Rec.attribute14 := NULL;
	l_x_Line_Price_Att_Rec.attribute15 := NULL;
	l_x_Line_Price_Att_Rec.pricing_context := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute1 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute2 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute3 := NULL;
	l_x_Line_Price_Att_Rec.override_flag := NULL;


-- Set Operation to Create
	l_x_Line_Price_Att_Rec.operation := OE_GLOBALS.G_OPR_CREATE;

     l_x_Line_Price_Att_Tbl(1) := l_x_Line_Price_Att_Rec;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE CALLING OE_ORDER_ADJ_PVT.LINE_PRICE_ATTS' ) ;
    END IF;
    -- Call Oe_Order_Adj_Pvt.Line_Price_Atts
    oe_order_adj_pvt.Line_Price_Atts
    (	p_init_msg_list			=> FND_API.G_TRUE
    ,	p_validation_level 			=> FND_API.G_VALID_LEVEL_NONE
    ,	p_control_rec				=> l_control_rec
    ,	p_x_line_price_att_tbl		=> l_x_Line_price_att_tbl
    ,	p_x_old_line_price_att_tbl	=> l_x_old_Line_price_att_tbl
    );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER CALLING OE_ORDER_ADJ_PVT.LINE_PRICE_ATTS' ) ;
      END IF;
     l_x_Line_Price_Att_Rec := l_x_Line_Price_Att_tbl(1);

     IF l_x_Line_Price_Att_Rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_x_Line_Price_Att_Rec.return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
	END IF;


-- Load out parameters

    x_attribute1                := l_x_Line_Price_Att_Rec.attribute1;
    x_attribute10               := l_x_Line_Price_Att_Rec.attribute10;
    x_attribute11               := l_x_Line_Price_Att_Rec.attribute11;
    x_attribute12               := l_x_Line_Price_Att_Rec.attribute12;
    x_attribute13               := l_x_Line_Price_Att_Rec.attribute13;
    x_attribute14               := l_x_Line_Price_Att_Rec.attribute14;
    x_attribute15               := l_x_Line_Price_Att_Rec.attribute15;
    x_attribute2                := l_x_Line_Price_Att_Rec.attribute2;
    x_attribute3                := l_x_Line_Price_Att_Rec.attribute3;
    x_attribute4                := l_x_Line_Price_Att_Rec.attribute4;
    x_attribute5                := l_x_Line_Price_Att_Rec.attribute5;
    x_attribute6                := l_x_Line_Price_Att_Rec.attribute6;
    x_attribute7                := l_x_Line_Price_Att_Rec.attribute7;
    x_attribute8                := l_x_Line_Price_Att_Rec.attribute8;
    x_attribute9                := l_x_Line_Price_Att_Rec.attribute9;
    x_context                   := l_x_Line_Price_Att_Rec.context;
    x_flex_title                := l_x_Line_Price_Att_Rec.flex_title;
    x_header_id                 := l_x_Line_Price_Att_Rec.header_id;
    x_line_id                   := l_x_Line_Price_Att_Rec.line_id;
    x_order_price_attrib_id     := l_x_Line_Price_Att_Rec.order_price_attrib_id;
    x_pricing_attribute1        := l_x_Line_Price_Att_Rec.pricing_attribute1;
    x_pricing_attribute2        := l_x_Line_Price_Att_Rec.pricing_attribute2;
    x_pricing_attribute3        := l_x_Line_Price_Att_Rec.pricing_attribute3;
    x_pricing_context           := l_x_Line_Price_Att_Rec.pricing_context;
    x_override_flag           := l_x_Line_Price_Att_Rec.override_flag;


	l_x_Line_Price_Att_Rec.db_flag := FND_API.G_FALSE;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'WRITING PATTRIBUTE TO CACHE' ) ;
           END IF;
	Write_Order_Line_PAttr (
			p_Line_Price_Att_rec => l_x_Line_Price_Att_Rec
		);

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

 --  Set return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	  --  Get message count and data
	 OE_MSG_PUB.Count_And_Get
	 (   	p_count                       => x_msg_count
	    ,    p_data                        => x_msg_data
	  );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING DEFAULT ATTRIBUTE' ) ;
  END IF;
EXCEPTION
 	WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;
		 x_return_status := FND_API.G_RET_STS_ERROR;

	    --  Get message count and data

			  OE_MSG_PUB.Count_And_Get
			(   p_count                       => x_msg_count
			   ,   p_data                        => x_msg_data
			 );

 	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		 --  Get message count and data

		    OE_MSG_PUB.Count_And_Get
		  (   p_count                       => x_msg_count
		,   p_data                        => x_msg_data
		   );

	 WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	 	   OE_MSG_PUB.Add_Exc_Msg
		    (   G_PKG_NAME
			 ,   'Default_Attributes'
		   );
	  END IF;



       --  Get message count and data

	OE_MSG_PUB.Count_And_Get
	(   p_count                       => x_msg_count
	,   	p_data                        => x_msg_data
	);

END Default_Attributes;

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id				 in  NUMBER
,   p_line_id					 in  NUMBER
, x_attribute1 OUT NOCOPY VARCHAR2

, x_attribute10 OUT NOCOPY VARCHAR2

, x_attribute11 OUT NOCOPY VARCHAR2

, x_attribute12 OUT NOCOPY VARCHAR2

, x_attribute13 OUT NOCOPY VARCHAR2

, x_attribute14 OUT NOCOPY VARCHAR2

, x_attribute15 OUT NOCOPY VARCHAR2

, x_attribute2 OUT NOCOPY VARCHAR2

, x_attribute3 OUT NOCOPY VARCHAR2

, x_attribute4 OUT NOCOPY VARCHAR2

, x_attribute5 OUT NOCOPY VARCHAR2

, x_attribute6 OUT NOCOPY VARCHAR2

, x_attribute7 OUT NOCOPY VARCHAR2

, x_attribute8 OUT NOCOPY VARCHAR2

, x_attribute9 OUT NOCOPY VARCHAR2

, x_flex_title OUT NOCOPY VARCHAR2

, x_context OUT NOCOPY VARCHAR2

, x_header_id OUT NOCOPY NUMBER

, x_line_id OUT NOCOPY NUMBER

, x_order_price_attrib_id OUT NOCOPY NUMBER

, x_pricing_attribute1 OUT NOCOPY VARCHAR2

, x_pricing_attribute10 OUT NOCOPY VARCHAR2

, x_pricing_attribute11 OUT NOCOPY VARCHAR2

, x_pricing_attribute12 OUT NOCOPY VARCHAR2

, x_pricing_attribute13 OUT NOCOPY VARCHAR2

, x_pricing_attribute14 OUT NOCOPY VARCHAR2

, x_pricing_attribute15 OUT NOCOPY VARCHAR2

, x_pricing_attribute2 OUT NOCOPY VARCHAR2

, x_pricing_attribute3 OUT NOCOPY VARCHAR2

, x_pricing_attribute4 OUT NOCOPY VARCHAR2

, x_pricing_attribute5 OUT NOCOPY VARCHAR2

, x_pricing_attribute6 OUT NOCOPY VARCHAR2

, x_pricing_attribute7 OUT NOCOPY VARCHAR2

, x_pricing_attribute8 OUT NOCOPY VARCHAR2

, x_pricing_attribute9 OUT NOCOPY VARCHAR2

, x_pricing_attribute16 OUT NOCOPY VARCHAR2

, x_pricing_attribute17 OUT NOCOPY VARCHAR2

, x_pricing_attribute18 OUT NOCOPY VARCHAR2

, x_pricing_attribute19 OUT NOCOPY VARCHAR2

, x_pricing_attribute20 OUT NOCOPY VARCHAR2

, x_pricing_attribute21 OUT NOCOPY VARCHAR2

, x_pricing_attribute22 OUT NOCOPY VARCHAR2

, x_pricing_attribute23 OUT NOCOPY VARCHAR2

, x_pricing_attribute24 OUT NOCOPY VARCHAR2

, x_pricing_attribute25 OUT NOCOPY VARCHAR2

, x_pricing_attribute26 OUT NOCOPY VARCHAR2

, x_pricing_attribute27 OUT NOCOPY VARCHAR2

, x_pricing_attribute28 OUT NOCOPY VARCHAR2

, x_pricing_attribute29 OUT NOCOPY VARCHAR2

, x_pricing_attribute30 OUT NOCOPY VARCHAR2

, x_pricing_attribute31 OUT NOCOPY VARCHAR2

, x_pricing_attribute32 OUT NOCOPY VARCHAR2

, x_pricing_attribute33 OUT NOCOPY VARCHAR2

, x_pricing_attribute34 OUT NOCOPY VARCHAR2

, x_pricing_attribute35 OUT NOCOPY VARCHAR2

, x_pricing_attribute36 OUT NOCOPY VARCHAR2

, x_pricing_attribute37 OUT NOCOPY VARCHAR2

, x_pricing_attribute38 OUT NOCOPY VARCHAR2

, x_pricing_attribute39 OUT NOCOPY VARCHAR2

, x_pricing_attribute40 OUT NOCOPY VARCHAR2

, x_pricing_attribute41 OUT NOCOPY VARCHAR2

, x_pricing_attribute42 OUT NOCOPY VARCHAR2

, x_pricing_attribute43 OUT NOCOPY VARCHAR2

, x_pricing_attribute44 OUT NOCOPY VARCHAR2

, x_pricing_attribute45 OUT NOCOPY VARCHAR2

, x_pricing_attribute46 OUT NOCOPY VARCHAR2

, x_pricing_attribute47 OUT NOCOPY VARCHAR2

, x_pricing_attribute48 OUT NOCOPY VARCHAR2

, x_pricing_attribute49 OUT NOCOPY VARCHAR2

, x_pricing_attribute50 OUT NOCOPY VARCHAR2

, x_pricing_attribute51 OUT NOCOPY VARCHAR2

, x_pricing_attribute52 OUT NOCOPY VARCHAR2

, x_pricing_attribute53 OUT NOCOPY VARCHAR2

, x_pricing_attribute54 OUT NOCOPY VARCHAR2

, x_pricing_attribute55 OUT NOCOPY VARCHAR2

, x_pricing_attribute56 OUT NOCOPY VARCHAR2

, x_pricing_attribute57 OUT NOCOPY VARCHAR2

, x_pricing_attribute58 OUT NOCOPY VARCHAR2

, x_pricing_attribute59 OUT NOCOPY VARCHAR2

, x_pricing_attribute60 OUT NOCOPY VARCHAR2

, x_pricing_attribute61 OUT NOCOPY VARCHAR2

, x_pricing_attribute62 OUT NOCOPY VARCHAR2

, x_pricing_attribute63 OUT NOCOPY VARCHAR2

, x_pricing_attribute64 OUT NOCOPY VARCHAR2

, x_pricing_attribute65 OUT NOCOPY VARCHAR2

, x_pricing_attribute66 OUT NOCOPY VARCHAR2

, x_pricing_attribute67 OUT NOCOPY VARCHAR2

, x_pricing_attribute68 OUT NOCOPY VARCHAR2

, x_pricing_attribute69 OUT NOCOPY VARCHAR2

, x_pricing_attribute70 OUT NOCOPY VARCHAR2

, x_pricing_attribute71 OUT NOCOPY VARCHAR2

, x_pricing_attribute72 OUT NOCOPY VARCHAR2

, x_pricing_attribute73 OUT NOCOPY VARCHAR2

, x_pricing_attribute74 OUT NOCOPY VARCHAR2

, x_pricing_attribute75 OUT NOCOPY VARCHAR2

, x_pricing_attribute76 OUT NOCOPY VARCHAR2

, x_pricing_attribute77 OUT NOCOPY VARCHAR2

, x_pricing_attribute78 OUT NOCOPY VARCHAR2

, x_pricing_attribute79 OUT NOCOPY VARCHAR2

, x_pricing_attribute80 OUT NOCOPY VARCHAR2

, x_pricing_attribute81 OUT NOCOPY VARCHAR2

, x_pricing_attribute82 OUT NOCOPY VARCHAR2

, x_pricing_attribute83 OUT NOCOPY VARCHAR2

, x_pricing_attribute84 OUT NOCOPY VARCHAR2

, x_pricing_attribute85 OUT NOCOPY VARCHAR2

, x_pricing_attribute86 OUT NOCOPY VARCHAR2

, x_pricing_attribute87 OUT NOCOPY VARCHAR2

, x_pricing_attribute88 OUT NOCOPY VARCHAR2

, x_pricing_attribute89 OUT NOCOPY VARCHAR2

, x_pricing_attribute90 OUT NOCOPY VARCHAR2

, x_pricing_attribute91 OUT NOCOPY VARCHAR2

, x_pricing_attribute92 OUT NOCOPY VARCHAR2

, x_pricing_attribute93 OUT NOCOPY VARCHAR2

, x_pricing_attribute94 OUT NOCOPY VARCHAR2

, x_pricing_attribute95 OUT NOCOPY VARCHAR2

, x_pricing_attribute96 OUT NOCOPY VARCHAR2

, x_pricing_attribute97 OUT NOCOPY VARCHAR2

, x_pricing_attribute98 OUT NOCOPY VARCHAR2

, x_pricing_attribute99 OUT NOCOPY VARCHAR2

, x_pricing_attribute100 OUT NOCOPY VARCHAR2

, x_pricing_context OUT NOCOPY VARCHAR2

, x_override_flag OUT NOCOPY VARCHAR2

, x_creation_date OUT NOCOPY DATE

)
IS
l_Line_Price_Att_rec	OE_Order_PUB.Line_Price_Att_Rec_Type;
l_Line_Price_Att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type;

l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl          OE_Order_PUB.Request_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_Header_Price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_Price_Att_Rec    	OE_Order_PUB.Line_Price_Att_Rec_Type;
l_x_Line_Price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_old_Line_Price_Att_tbl    OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_old_Line_Price_Att_Rec    OE_Order_PUB.Line_Price_Att_Rec_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENERING OE_OE_FORM_LINE_PATTR.DEFAULT_ATTRIBUTE.' , 1 ) ;
    END IF;
    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

-- Set Control Flags
	l_control_rec.controlled_operation := TRUE;
	l_control_rec.check_security       := TRUE;
	l_control_rec.default_attributes   := TRUE;
	l_control_rec.change_attributes    := TRUE;

	l_control_rec.clear_dependents     := FALSE;
	l_control_rec.validate_entity      := FALSE;
	l_control_rec.write_to_DB          := FALSE;
	l_control_rec.process              := FALSE;

	--  Instruct API to retain its caches
	l_control_rec.clear_api_cache      := FALSE;
	l_control_rec.clear_api_requests   := FALSE;
-----------------------------------------------
-- Set attributes to NULL
-----------------------------------------------

     l_x_old_line_price_att_rec := OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_REC;
     l_x_line_price_att_rec := OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_REC;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' BEFORE SETTING THINGS TO NULL: OE_ORDER_ADJ_PVT.LINE_PRICE_ATTS' ) ;
     END IF;
	l_x_Line_Price_Att_Rec.header_id := p_header_id;
	l_x_Line_Price_Att_Rec.Line_id := p_Line_id;
	l_x_Line_Price_Att_Rec.context := NULL;
	l_x_Line_Price_Att_Rec.attribute1 := NULL;
	l_x_Line_Price_Att_Rec.attribute2 := NULL;
	l_x_Line_Price_Att_Rec.attribute3 := NULL;
	l_x_Line_Price_Att_Rec.attribute4 := NULL;
	l_x_Line_Price_Att_Rec.attribute5 := NULL;
	l_x_Line_Price_Att_Rec.attribute6 := NULL;
	l_x_Line_Price_Att_Rec.attribute7 := NULL;
	l_x_Line_Price_Att_Rec.attribute8 := NULL;
	l_x_Line_Price_Att_Rec.attribute9 := NULL;
	l_x_Line_Price_Att_Rec.attribute10 := NULL;
	l_x_Line_Price_Att_Rec.attribute11 := NULL;
	l_x_Line_Price_Att_Rec.attribute12 := NULL;
	l_x_Line_Price_Att_Rec.attribute13 := NULL;
	l_x_Line_Price_Att_Rec.attribute14 := NULL;
	l_x_Line_Price_Att_Rec.attribute15 := NULL;
	l_x_Line_Price_Att_Rec.pricing_context := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute1 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute2 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute3 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute4 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute5 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute6 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute7 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute8 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute9 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute10 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute11 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute12 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute13 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute14 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute15 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute16 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute17 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute18 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute19 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute20 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute21 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute22 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute23 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute24 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute25 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute26 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute27 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute28 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute29 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute30 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute31 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute32 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute33 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute34 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute35 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute36 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute37 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute38 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute39 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute40 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute41 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute42 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute43 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute44 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute45 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute46 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute47 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute48 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute49 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute50 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute51 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute52 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute53 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute54 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute55 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute56 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute57 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute58 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute59 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute60 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute61 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute62 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute63 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute64 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute65 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute66 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute67 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute68 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute69 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute70 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute71 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute72 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute73 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute74 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute75 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute76 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute77 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute78 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute79 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute80 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute81 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute82 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute83 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute84 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute85 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute86 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute87 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute88 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute89 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute90 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute91 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute92 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute93 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute94 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute95 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute96 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute97 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute98 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute99 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute100 := NULL;
	l_x_Line_Price_Att_Rec.override_flag := NULL;


-- Set Operation to Create
	l_x_Line_Price_Att_Rec.operation := OE_GLOBALS.G_OPR_CREATE;

     l_x_Line_Price_Att_Tbl(1) := l_x_Line_Price_Att_Rec;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE CALLING OE_ORDER_ADJ_PVT.LINE_PRICE_ATTS' ) ;
    END IF;
    -- Call Oe_Order_Adj_Pvt.Line_Price_Atts
    oe_order_adj_pvt.Line_Price_Atts
    (	p_init_msg_list			=> FND_API.G_TRUE
    ,	p_validation_level 			=> FND_API.G_VALID_LEVEL_NONE
    ,	p_control_rec				=> l_control_rec
    ,	p_x_line_price_att_tbl		=> l_x_Line_price_att_tbl
    ,	p_x_old_line_price_att_tbl	=> l_x_old_Line_price_att_tbl
    );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER CALLING OE_ORDER_ADJ_PVT.LINE_PRICE_ATTS' ) ;
      END IF;
     l_x_Line_Price_Att_Rec := l_x_Line_Price_Att_tbl(1);

     IF l_x_Line_Price_Att_Rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_x_Line_Price_Att_Rec.return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
	END IF;


-- Load out parameters

    x_attribute1                := l_x_Line_Price_Att_Rec.attribute1;
    x_attribute10               := l_x_Line_Price_Att_Rec.attribute10;
    x_attribute11               := l_x_Line_Price_Att_Rec.attribute11;
    x_attribute12               := l_x_Line_Price_Att_Rec.attribute12;
    x_attribute13               := l_x_Line_Price_Att_Rec.attribute13;
    x_attribute14               := l_x_Line_Price_Att_Rec.attribute14;
    x_attribute15               := l_x_Line_Price_Att_Rec.attribute15;
    x_attribute2                := l_x_Line_Price_Att_Rec.attribute2;
    x_attribute3                := l_x_Line_Price_Att_Rec.attribute3;
    x_attribute4                := l_x_Line_Price_Att_Rec.attribute4;
    x_attribute5                := l_x_Line_Price_Att_Rec.attribute5;
    x_attribute6                := l_x_Line_Price_Att_Rec.attribute6;
    x_attribute7                := l_x_Line_Price_Att_Rec.attribute7;
    x_attribute8                := l_x_Line_Price_Att_Rec.attribute8;
    x_attribute9                := l_x_Line_Price_Att_Rec.attribute9;
    x_context                   := l_x_Line_Price_Att_Rec.context;
    x_flex_title                := l_x_Line_Price_Att_Rec.flex_title;
    x_header_id                 := l_x_Line_Price_Att_Rec.header_id;
    x_line_id                   := l_x_Line_Price_Att_Rec.line_id;
    x_order_price_attrib_id     := l_x_Line_Price_Att_Rec.order_price_attrib_id;
    x_pricing_attribute1        := l_x_Line_Price_Att_Rec.pricing_attribute1;
    x_pricing_attribute10       := l_x_Line_Price_Att_Rec.pricing_attribute10;
    x_pricing_attribute100      := l_x_Line_Price_Att_Rec.pricing_attribute100;
    x_pricing_attribute11       := l_x_Line_Price_Att_Rec.pricing_attribute11;
    x_pricing_attribute12       := l_x_Line_Price_Att_Rec.pricing_attribute12;
    x_pricing_attribute13       := l_x_Line_Price_Att_Rec.pricing_attribute13;
    x_pricing_attribute14       := l_x_Line_Price_Att_Rec.pricing_attribute14;
    x_pricing_attribute15       := l_x_Line_Price_Att_Rec.pricing_attribute15;
    x_pricing_attribute16       := l_x_Line_Price_Att_Rec.pricing_attribute16;
    x_pricing_attribute17       := l_x_Line_Price_Att_Rec.pricing_attribute17;
    x_pricing_attribute18       := l_x_Line_Price_Att_Rec.pricing_attribute18;
    x_pricing_attribute19       := l_x_Line_Price_Att_Rec.pricing_attribute19;
    x_pricing_attribute2        := l_x_Line_Price_Att_Rec.pricing_attribute2;
    x_pricing_attribute20       := l_x_Line_Price_Att_Rec.pricing_attribute20;
    x_pricing_attribute21       := l_x_Line_Price_Att_Rec.pricing_attribute21;
    x_pricing_attribute22       := l_x_Line_Price_Att_Rec.pricing_attribute22;
    x_pricing_attribute23       := l_x_Line_Price_Att_Rec.pricing_attribute23;
    x_pricing_attribute24       := l_x_Line_Price_Att_Rec.pricing_attribute24;
    x_pricing_attribute25       := l_x_Line_Price_Att_Rec.pricing_attribute25;
    x_pricing_attribute26       := l_x_Line_Price_Att_Rec.pricing_attribute26;
    x_pricing_attribute27       := l_x_Line_Price_Att_Rec.pricing_attribute27;
    x_pricing_attribute28       := l_x_Line_Price_Att_Rec.pricing_attribute28;
    x_pricing_attribute29       := l_x_Line_Price_Att_Rec.pricing_attribute29;
    x_pricing_attribute3        := l_x_Line_Price_Att_Rec.pricing_attribute3;
    x_pricing_attribute30       := l_x_Line_Price_Att_Rec.pricing_attribute30;
    x_pricing_attribute31       := l_x_Line_Price_Att_Rec.pricing_attribute31;
    x_pricing_attribute32       := l_x_Line_Price_Att_Rec.pricing_attribute32;
    x_pricing_attribute33       := l_x_Line_Price_Att_Rec.pricing_attribute33;
    x_pricing_attribute34       := l_x_Line_Price_Att_Rec.pricing_attribute34;
    x_pricing_attribute35       := l_x_Line_Price_Att_Rec.pricing_attribute35;
    x_pricing_attribute36       := l_x_Line_Price_Att_Rec.pricing_attribute36;
    x_pricing_attribute37       := l_x_Line_Price_Att_Rec.pricing_attribute37;
    x_pricing_attribute38       := l_x_Line_Price_Att_Rec.pricing_attribute38;
    x_pricing_attribute39       := l_x_Line_Price_Att_Rec.pricing_attribute39;
    x_pricing_attribute4        := l_x_Line_Price_Att_Rec.pricing_attribute4;
    x_pricing_attribute40       := l_x_Line_Price_Att_Rec.pricing_attribute40;
    x_pricing_attribute41       := l_x_Line_Price_Att_Rec.pricing_attribute41;
    x_pricing_attribute42       := l_x_Line_Price_Att_Rec.pricing_attribute42;
    x_pricing_attribute43       := l_x_Line_Price_Att_Rec.pricing_attribute43;
    x_pricing_attribute44       := l_x_Line_Price_Att_Rec.pricing_attribute44;
    x_pricing_attribute45       := l_x_Line_Price_Att_Rec.pricing_attribute45;
    x_pricing_attribute46       := l_x_Line_Price_Att_Rec.pricing_attribute46;
    x_pricing_attribute47       := l_x_Line_Price_Att_Rec.pricing_attribute47;
    x_pricing_attribute48       := l_x_Line_Price_Att_Rec.pricing_attribute48;
    x_pricing_attribute49       := l_x_Line_Price_Att_Rec.pricing_attribute49;
    x_pricing_attribute5        := l_x_Line_Price_Att_Rec.pricing_attribute5;
    x_pricing_attribute50       := l_x_Line_Price_Att_Rec.pricing_attribute50;
    x_pricing_attribute51       := l_x_Line_Price_Att_Rec.pricing_attribute51;
    x_pricing_attribute52       := l_x_Line_Price_Att_Rec.pricing_attribute52;
    x_pricing_attribute53       := l_x_Line_Price_Att_Rec.pricing_attribute53;
    x_pricing_attribute54       := l_x_Line_Price_Att_Rec.pricing_attribute54;
    x_pricing_attribute55       := l_x_Line_Price_Att_Rec.pricing_attribute55;
    x_pricing_attribute56       := l_x_Line_Price_Att_Rec.pricing_attribute56;
    x_pricing_attribute57       := l_x_Line_Price_Att_Rec.pricing_attribute57;
    x_pricing_attribute58       := l_x_Line_Price_Att_Rec.pricing_attribute58;
    x_pricing_attribute59       := l_x_Line_Price_Att_Rec.pricing_attribute59;
    x_pricing_attribute6        := l_x_Line_Price_Att_Rec.pricing_attribute6;
    x_pricing_attribute60       := l_x_Line_Price_Att_Rec.pricing_attribute60;
    x_pricing_attribute61       := l_x_Line_Price_Att_Rec.pricing_attribute61;
    x_pricing_attribute62       := l_x_Line_Price_Att_Rec.pricing_attribute62;
    x_pricing_attribute63       := l_x_Line_Price_Att_Rec.pricing_attribute63;
    x_pricing_attribute64       := l_x_Line_Price_Att_Rec.pricing_attribute64;
    x_pricing_attribute65       := l_x_Line_Price_Att_Rec.pricing_attribute65;
    x_pricing_attribute66       := l_x_Line_Price_Att_Rec.pricing_attribute66;
    x_pricing_attribute67       := l_x_Line_Price_Att_Rec.pricing_attribute67;
    x_pricing_attribute68       := l_x_Line_Price_Att_Rec.pricing_attribute68;
    x_pricing_attribute69       := l_x_Line_Price_Att_Rec.pricing_attribute69;
    x_pricing_attribute7        := l_x_Line_Price_Att_Rec.pricing_attribute7;
    x_pricing_attribute70       := l_x_Line_Price_Att_Rec.pricing_attribute70;
    x_pricing_attribute71       := l_x_Line_Price_Att_Rec.pricing_attribute71;
    x_pricing_attribute72       := l_x_Line_Price_Att_Rec.pricing_attribute72;
    x_pricing_attribute73       := l_x_Line_Price_Att_Rec.pricing_attribute73;
    x_pricing_attribute74       := l_x_Line_Price_Att_Rec.pricing_attribute74;
    x_pricing_attribute75       := l_x_Line_Price_Att_Rec.pricing_attribute75;
    x_pricing_attribute76       := l_x_Line_Price_Att_Rec.pricing_attribute76;
    x_pricing_attribute77       := l_x_Line_Price_Att_Rec.pricing_attribute77;
    x_pricing_attribute78       := l_x_Line_Price_Att_Rec.pricing_attribute78;
    x_pricing_attribute79       := l_x_Line_Price_Att_Rec.pricing_attribute79;
    x_pricing_attribute8        := l_x_Line_Price_Att_Rec.pricing_attribute8;
    x_pricing_attribute80       := l_x_Line_Price_Att_Rec.pricing_attribute80;
    x_pricing_attribute81       := l_x_Line_Price_Att_Rec.pricing_attribute81;
    x_pricing_attribute82       := l_x_Line_Price_Att_Rec.pricing_attribute82;
    x_pricing_attribute83       := l_x_Line_Price_Att_Rec.pricing_attribute83;
    x_pricing_attribute84       := l_x_Line_Price_Att_Rec.pricing_attribute84;
    x_pricing_attribute85       := l_x_Line_Price_Att_Rec.pricing_attribute85;
    x_pricing_attribute86       := l_x_Line_Price_Att_Rec.pricing_attribute86;
    x_pricing_attribute87       := l_x_Line_Price_Att_Rec.pricing_attribute87;
    x_pricing_attribute88       := l_x_Line_Price_Att_Rec.pricing_attribute88;
    x_pricing_attribute89       := l_x_Line_Price_Att_Rec.pricing_attribute89;
    x_pricing_attribute9        := l_x_Line_Price_Att_Rec.pricing_attribute9;
    x_pricing_attribute90       := l_x_Line_Price_Att_Rec.pricing_attribute90;
    x_pricing_attribute91       := l_x_Line_Price_Att_Rec.pricing_attribute91;
    x_pricing_attribute92       := l_x_Line_Price_Att_Rec.pricing_attribute92;
    x_pricing_attribute93       := l_x_Line_Price_Att_Rec.pricing_attribute93;
    x_pricing_attribute94       := l_x_Line_Price_Att_Rec.pricing_attribute94;
    x_pricing_attribute95       := l_x_Line_Price_Att_Rec.pricing_attribute95;
    x_pricing_attribute96       := l_x_Line_Price_Att_Rec.pricing_attribute96;
    x_pricing_attribute97       := l_x_Line_Price_Att_Rec.pricing_attribute97;
    x_pricing_attribute98       := l_x_Line_Price_Att_Rec.pricing_attribute98;
    x_pricing_attribute99       := l_x_Line_Price_Att_Rec.pricing_attribute99;
    x_pricing_context           := l_x_Line_Price_Att_Rec.pricing_context;
    x_override_flag           := l_x_Line_Price_Att_Rec.override_flag;


	l_x_Line_Price_Att_Rec.db_flag := FND_API.G_FALSE;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'WRITING PATTRIBUTE TO CACHE' ) ;
           END IF;
	Write_Order_Line_PAttr (
			p_Line_Price_Att_rec => l_x_Line_Price_Att_Rec
		);

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

 --  Set return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	  --  Get message count and data
	 OE_MSG_PUB.Count_And_Get
	 (   	p_count                       => x_msg_count
	    ,    p_data                        => x_msg_data
	  );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING DEFAULT ATTRIBUTE' ) ;
  END IF;
EXCEPTION
 	WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;
		 x_return_status := FND_API.G_RET_STS_ERROR;

	    --  Get message count and data

			  OE_MSG_PUB.Count_And_Get
			(   p_count                       => x_msg_count
			   ,   p_data                        => x_msg_data
			 );

 	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		 --  Get message count and data

		    OE_MSG_PUB.Count_And_Get
		  (   p_count                       => x_msg_count
		,   p_data                        => x_msg_data
		   );

	 WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	 	   OE_MSG_PUB.Add_Exc_Msg
		    (   G_PKG_NAME
			 ,   'Default_Attributes'
		   );
	  END IF;



       --  Get message count and data

	OE_MSG_PUB.Count_And_Get
	(   p_count                       => x_msg_count
	,   	p_data                        => x_msg_data
	);

END Default_Attributes;


PROCEDURE Change_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,    p_order_price_attrib_id		 IN NUMBER
,    p_attr_id					 IN NUMBER
,	p_context					 IN VARCHAR2
,    p_attr_value				 IN VARCHAR2
,	p_attribute1				 IN VARCHAR2
,	p_attribute2				 IN VARCHAR2
,	p_attribute3				 IN VARCHAR2
,	p_attribute4				 IN VARCHAR2
,	p_attribute5				 IN VARCHAR2
,	p_attribute6				 IN VARCHAR2
,	p_attribute7				 IN VARCHAR2
,	p_attribute8				 IN VARCHAR2
,	p_attribute9				 IN VARCHAR2
,	p_attribute10				 IN VARCHAR2
,	p_attribute11				 IN VARCHAR2
,	p_attribute12				 IN VARCHAR2
,	p_attribute13				 IN VARCHAR2
,	p_attribute14				 IN VARCHAR2
,	p_attribute15				 IN VARCHAR2
,   p_pricing_attribute1            IN VARCHAR2
,   p_pricing_attribute10           IN VARCHAR2
,   p_pricing_attribute11           IN VARCHAR2
,   p_pricing_attribute12           IN VARCHAR2
,   p_pricing_attribute13           IN VARCHAR2
,   p_pricing_attribute14           IN VARCHAR2
,   p_pricing_attribute15           IN VARCHAR2
,   p_pricing_attribute2            IN VARCHAR2
,   p_pricing_attribute3            IN VARCHAR2
,   p_pricing_attribute4            IN VARCHAR2
,   p_pricing_attribute5            IN VARCHAR2
,   p_pricing_attribute6            IN VARCHAR2
,   p_pricing_attribute7            IN VARCHAR2
,   p_pricing_attribute8            IN VARCHAR2
,   p_pricing_attribute9            IN VARCHAR2
,   p_pricing_attribute16           IN VARCHAR2
,   p_pricing_attribute17           IN VARCHAR2
,   p_pricing_attribute18           IN VARCHAR2
,   p_pricing_attribute19           IN VARCHAR2
,   p_pricing_attribute20           IN VARCHAR2
,   p_pricing_attribute21           IN VARCHAR2
,   p_pricing_attribute22           IN VARCHAR2
,   p_pricing_attribute23           IN VARCHAR2
,   p_pricing_attribute24           IN VARCHAR2
,   p_pricing_attribute25           IN VARCHAR2
,   p_pricing_attribute26           IN VARCHAR2
,   p_pricing_attribute27           IN VARCHAR2
,   p_pricing_attribute28           IN VARCHAR2
,   p_pricing_attribute29           IN VARCHAR2
,   p_pricing_attribute30           IN VARCHAR2
,   p_pricing_attribute31           IN VARCHAR2
,   p_pricing_attribute32           IN VARCHAR2
,   p_pricing_attribute33           IN VARCHAR2
,   p_pricing_attribute34           IN VARCHAR2
,   p_pricing_attribute35           IN VARCHAR2
,   p_pricing_attribute36           IN VARCHAR2
,   p_pricing_attribute37           IN VARCHAR2
,   p_pricing_attribute38           IN VARCHAR2
,   p_pricing_attribute39           IN VARCHAR2
,   p_pricing_attribute40           IN VARCHAR2
,   p_pricing_attribute41           IN VARCHAR2
,   p_pricing_attribute42           IN VARCHAR2
,   p_pricing_attribute43           IN VARCHAR2
,   p_pricing_attribute44           IN VARCHAR2
,   p_pricing_attribute45           IN VARCHAR2
,   p_pricing_attribute46           IN VARCHAR2
,   p_pricing_attribute47           IN VARCHAR2
,   p_pricing_attribute48           IN VARCHAR2
,   p_pricing_attribute49           IN VARCHAR2
,   p_pricing_attribute50           IN VARCHAR2
,   p_pricing_attribute51           IN VARCHAR2
,   p_pricing_attribute52           IN VARCHAR2
,   p_pricing_attribute53           IN VARCHAR2
,   p_pricing_attribute54           IN VARCHAR2
,   p_pricing_attribute55           IN VARCHAR2
,   p_pricing_attribute56           IN VARCHAR2
,   p_pricing_attribute57           IN VARCHAR2
,   p_pricing_attribute58           IN VARCHAR2
,   p_pricing_attribute59           IN VARCHAR2
,   p_pricing_attribute60           IN VARCHAR2
,   p_pricing_attribute61           IN VARCHAR2
,   p_pricing_attribute62           IN VARCHAR2
,   p_pricing_attribute63           IN VARCHAR2
,   p_pricing_attribute64           IN VARCHAR2
,   p_pricing_attribute65           IN VARCHAR2
,   p_pricing_attribute66           IN VARCHAR2
,   p_pricing_attribute67           IN VARCHAR2
,   p_pricing_attribute68           IN VARCHAR2
,   p_pricing_attribute69           IN VARCHAR2
,   p_pricing_attribute70           IN VARCHAR2
,   p_pricing_attribute71           IN VARCHAR2
,   p_pricing_attribute72           IN VARCHAR2
,   p_pricing_attribute73           IN VARCHAR2
,   p_pricing_attribute74           IN VARCHAR2
,   p_pricing_attribute75           IN VARCHAR2
,   p_pricing_attribute76           IN VARCHAR2
,   p_pricing_attribute77           IN VARCHAR2
,   p_pricing_attribute78           IN VARCHAR2
,   p_pricing_attribute79           IN VARCHAR2
,   p_pricing_attribute80           IN VARCHAR2
,   p_pricing_attribute81           IN VARCHAR2
,   p_pricing_attribute82           IN VARCHAR2
,   p_pricing_attribute83           IN VARCHAR2
,   p_pricing_attribute84           IN VARCHAR2
,   p_pricing_attribute85           IN VARCHAR2
,   p_pricing_attribute86           IN VARCHAR2
,   p_pricing_attribute87           IN VARCHAR2
,   p_pricing_attribute88           IN VARCHAR2
,   p_pricing_attribute89           IN VARCHAR2
,   p_pricing_attribute90           IN VARCHAR2
,   p_pricing_attribute91           IN VARCHAR2
,   p_pricing_attribute92           IN VARCHAR2
,   p_pricing_attribute93           IN VARCHAR2
,   p_pricing_attribute94           IN VARCHAR2
,   p_pricing_attribute95           IN VARCHAR2
,   p_pricing_attribute96           IN VARCHAR2
,   p_pricing_attribute97           IN VARCHAR2
,   p_pricing_attribute98           IN VARCHAR2
,   p_pricing_attribute99           IN VARCHAR2
,   p_pricing_attribute100          IN VARCHAR2
,   p_pricing_context               IN VARCHAR2
,   p_flex_title				 in VARCHAR2
, x_flex_title OUT NOCOPY VARCHAR2

, x_order_price_attrib_id OUT NOCOPY NUMBER

, x_header_id OUT NOCOPY NUMBER

, x_line_id OUT NOCOPY NUMBER

, x_context OUT NOCOPY VARCHAR2

, x_attribute1 OUT NOCOPY VARCHAR2

, x_attribute2 OUT NOCOPY VARCHAR2

, x_attribute3 OUT NOCOPY VARCHAR2

, x_attribute4 OUT NOCOPY VARCHAR2

, x_attribute5 OUT NOCOPY VARCHAR2

, x_attribute6 OUT NOCOPY VARCHAR2

, x_attribute7 OUT NOCOPY VARCHAR2

, x_attribute8 OUT NOCOPY VARCHAR2

, x_attribute9 OUT NOCOPY VARCHAR2

, x_attribute10 OUT NOCOPY VARCHAR2

, x_attribute11 OUT NOCOPY VARCHAR2

, x_attribute12 OUT NOCOPY VARCHAR2

, x_attribute13 OUT NOCOPY VARCHAR2

, x_attribute14 OUT NOCOPY VARCHAR2

, x_attribute15 OUT NOCOPY VARCHAR2

, x_pricing_attribute1 OUT NOCOPY VARCHAR2

, x_pricing_attribute10 OUT NOCOPY VARCHAR2

, x_pricing_attribute11 OUT NOCOPY VARCHAR2

, x_pricing_attribute12 OUT NOCOPY VARCHAR2

, x_pricing_attribute13 OUT NOCOPY VARCHAR2

, x_pricing_attribute14 OUT NOCOPY VARCHAR2

, x_pricing_attribute15 OUT NOCOPY VARCHAR2

, x_pricing_attribute2 OUT NOCOPY VARCHAR2

, x_pricing_attribute3 OUT NOCOPY VARCHAR2

, x_pricing_attribute4 OUT NOCOPY VARCHAR2

, x_pricing_attribute5 OUT NOCOPY VARCHAR2

, x_pricing_attribute6 OUT NOCOPY VARCHAR2

, x_pricing_attribute7 OUT NOCOPY VARCHAR2

, x_pricing_attribute8 OUT NOCOPY VARCHAR2

, x_pricing_attribute9 OUT NOCOPY VARCHAR2

, x_pricing_attribute16 OUT NOCOPY VARCHAR2

, x_pricing_attribute17 OUT NOCOPY VARCHAR2

, x_pricing_attribute18 OUT NOCOPY VARCHAR2

, x_pricing_attribute19 OUT NOCOPY VARCHAR2

, x_pricing_attribute20 OUT NOCOPY VARCHAR2

, x_pricing_attribute21 OUT NOCOPY VARCHAR2

, x_pricing_attribute22 OUT NOCOPY VARCHAR2

, x_pricing_attribute23 OUT NOCOPY VARCHAR2

, x_pricing_attribute24 OUT NOCOPY VARCHAR2

, x_pricing_attribute25 OUT NOCOPY VARCHAR2

, x_pricing_attribute26 OUT NOCOPY VARCHAR2

, x_pricing_attribute27 OUT NOCOPY VARCHAR2

, x_pricing_attribute28 OUT NOCOPY VARCHAR2

, x_pricing_attribute29 OUT NOCOPY VARCHAR2

, x_pricing_attribute30 OUT NOCOPY VARCHAR2

, x_pricing_attribute31 OUT NOCOPY VARCHAR2

, x_pricing_attribute32 OUT NOCOPY VARCHAR2

, x_pricing_attribute33 OUT NOCOPY VARCHAR2

, x_pricing_attribute34 OUT NOCOPY VARCHAR2

, x_pricing_attribute35 OUT NOCOPY VARCHAR2

, x_pricing_attribute36 OUT NOCOPY VARCHAR2

, x_pricing_attribute37 OUT NOCOPY VARCHAR2

, x_pricing_attribute38 OUT NOCOPY VARCHAR2

, x_pricing_attribute39 OUT NOCOPY VARCHAR2

, x_pricing_attribute40 OUT NOCOPY VARCHAR2

, x_pricing_attribute41 OUT NOCOPY VARCHAR2

, x_pricing_attribute42 OUT NOCOPY VARCHAR2

, x_pricing_attribute43 OUT NOCOPY VARCHAR2

, x_pricing_attribute44 OUT NOCOPY VARCHAR2

, x_pricing_attribute45 OUT NOCOPY VARCHAR2

, x_pricing_attribute46 OUT NOCOPY VARCHAR2

, x_pricing_attribute47 OUT NOCOPY VARCHAR2

, x_pricing_attribute48 OUT NOCOPY VARCHAR2

, x_pricing_attribute49 OUT NOCOPY VARCHAR2

, x_pricing_attribute50 OUT NOCOPY VARCHAR2

, x_pricing_attribute51 OUT NOCOPY VARCHAR2

, x_pricing_attribute52 OUT NOCOPY VARCHAR2

, x_pricing_attribute53 OUT NOCOPY VARCHAR2

, x_pricing_attribute54 OUT NOCOPY VARCHAR2

, x_pricing_attribute55 OUT NOCOPY VARCHAR2

, x_pricing_attribute56 OUT NOCOPY VARCHAR2

, x_pricing_attribute57 OUT NOCOPY VARCHAR2

, x_pricing_attribute58 OUT NOCOPY VARCHAR2

, x_pricing_attribute59 OUT NOCOPY VARCHAR2

, x_pricing_attribute60 OUT NOCOPY VARCHAR2

, x_pricing_attribute61 OUT NOCOPY VARCHAR2

, x_pricing_attribute62 OUT NOCOPY VARCHAR2

, x_pricing_attribute63 OUT NOCOPY VARCHAR2

, x_pricing_attribute64 OUT NOCOPY VARCHAR2

, x_pricing_attribute65 OUT NOCOPY VARCHAR2

, x_pricing_attribute66 OUT NOCOPY VARCHAR2

, x_pricing_attribute67 OUT NOCOPY VARCHAR2

, x_pricing_attribute68 OUT NOCOPY VARCHAR2

, x_pricing_attribute69 OUT NOCOPY VARCHAR2

, x_pricing_attribute70 OUT NOCOPY VARCHAR2

, x_pricing_attribute71 OUT NOCOPY VARCHAR2

, x_pricing_attribute72 OUT NOCOPY VARCHAR2

, x_pricing_attribute73 OUT NOCOPY VARCHAR2

, x_pricing_attribute74 OUT NOCOPY VARCHAR2

, x_pricing_attribute75 OUT NOCOPY VARCHAR2

, x_pricing_attribute76 OUT NOCOPY VARCHAR2

, x_pricing_attribute77 OUT NOCOPY VARCHAR2

, x_pricing_attribute78 OUT NOCOPY VARCHAR2

, x_pricing_attribute79 OUT NOCOPY VARCHAR2

, x_pricing_attribute80 OUT NOCOPY VARCHAR2

, x_pricing_attribute81 OUT NOCOPY VARCHAR2

, x_pricing_attribute82 OUT NOCOPY VARCHAR2

, x_pricing_attribute83 OUT NOCOPY VARCHAR2

, x_pricing_attribute84 OUT NOCOPY VARCHAR2

, x_pricing_attribute85 OUT NOCOPY VARCHAR2

, x_pricing_attribute86 OUT NOCOPY VARCHAR2

, x_pricing_attribute87 OUT NOCOPY VARCHAR2

, x_pricing_attribute88 OUT NOCOPY VARCHAR2

, x_pricing_attribute89 OUT NOCOPY VARCHAR2

, x_pricing_attribute90 OUT NOCOPY VARCHAR2

, x_pricing_attribute91 OUT NOCOPY VARCHAR2

, x_pricing_attribute92 OUT NOCOPY VARCHAR2

, x_pricing_attribute93 OUT NOCOPY VARCHAR2

, x_pricing_attribute94 OUT NOCOPY VARCHAR2

, x_pricing_attribute95 OUT NOCOPY VARCHAR2

, x_pricing_attribute96 OUT NOCOPY VARCHAR2

, x_pricing_attribute97 OUT NOCOPY VARCHAR2

, x_pricing_attribute98 OUT NOCOPY VARCHAR2

, x_pricing_attribute99 OUT NOCOPY VARCHAR2

, x_pricing_attribute100 OUT NOCOPY VARCHAR2

, x_pricing_context OUT NOCOPY VARCHAR2

, x_override_flag OUT NOCOPY VARCHAR2

,   p_called_from_pattr             IN  VARCHAR2 DEFAULT 'N'

)
IS

l_Line_Price_Att_Rec	OE_Order_PUB.Line_Price_Att_Rec_Type;
l_old_Line_Price_Att_rec	OE_Order_PUB.Line_Price_Att_Rec_Type;
l_Line_Price_Att_Tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_old_Line_Price_Att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type;

l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl          OE_Order_PUB.Request_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_Header_Price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_Price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_x_old_Line_Price_Att_tbl    OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_x_Line_Price_Att_Rec        OE_Order_PUB.Line_Price_Att_Rec_Type ;
l_x_old_Line_Price_Att_Rec    OE_Order_PUB.Line_Price_Att_Rec_Type ;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_PATTR.CHANGE_ATTRIBUTES' , 1 ) ;
	END IF;
    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.
     l_control_rec.controlled_operation := TRUE;
	l_control_rec.check_security       := TRUE;
	l_control_rec.clear_dependents     := TRUE;
	l_control_rec.default_attributes   := TRUE;
	l_control_rec.change_attributes    := TRUE;

	l_control_rec.validate_entity      := FALSE;

        IF p_called_from_pattr = 'Y' THEN
          -- don't write to db if this is coming from Promotions window.
	  l_control_rec.write_to_DB          := FALSE;
        ELSE
	  l_control_rec.write_to_DB          := TRUE;
        END IF;

	l_control_rec.process          := FALSE;
	l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LINE_PRICE_ATT;


	--  Instruct API to retain its caches
	l_control_rec.clear_api_cache      := FALSE;
	l_control_rec.clear_api_requests   := FALSE;

	SAVEPOINT change_attributes;

	Get_Order_Line_PAttr
	( 	p_db_record  => FALSE
	, p_order_price_attrib_id => p_order_price_attrib_id
	, x_Line_Price_Att_rec    => l_x_Line_Price_Att_Rec
	);

	l_x_old_Line_Price_Att_rec := l_x_Line_Price_Att_Rec;


		   IF p_attr_id = OE_Line_PAttr_Util.G_FLEX_TITLE THEN
			l_x_Line_Price_Att_rec.flex_title := p_attr_value;
	     ELSIF p_attr_id = OE_Line_PAttr_Util.G_HEADER THEN
			l_x_Line_Price_Att_rec.header_id := TO_NUMBER(p_attr_value);

	     ELSIF p_attr_id = OE_Line_PAttr_Util.G_OVERRIDE_FLAG THEN
			l_x_Line_Price_Att_rec.override_flag := p_attr_value;

		ELSIF p_attr_id = OE_Line_PAttr_Util.G_LINE THEN
			l_x_Line_Price_Att_rec.line_id := TO_NUMBER(p_attr_value);
		ELSIF p_attr_id = OE_Line_PAttr_Util.G_ORDER_PRICE_ATTRIB THEN
			l_x_Line_Price_Att_rec.order_price_attrib_id := TO_NUMBER(p_attr_value);

	    ELSIF p_attr_id = OE_Line_PAttr_Util.G_CONTEXT
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE1
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE2
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE3
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE4
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE5
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE6
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE7
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE8
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE9
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE10
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE11
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE12
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE13
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE14
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE15
			THEN
				l_x_Line_Price_Att_rec.context       := p_context;
				l_x_Line_Price_Att_rec.attribute1    := p_attribute1;
				l_x_Line_Price_Att_rec.attribute2    := p_attribute2;
				l_x_Line_Price_Att_rec.attribute3    := p_attribute3;
				l_x_Line_Price_Att_rec.attribute4    := p_attribute4;
				l_x_Line_Price_Att_rec.attribute5    := p_attribute5;
				l_x_Line_Price_Att_rec.attribute6    := p_attribute6;
				l_x_Line_Price_Att_rec.attribute7    := p_attribute7;
				l_x_Line_Price_Att_rec.attribute8    := p_attribute8;
				l_x_Line_Price_Att_rec.attribute9    := p_attribute9;
				l_x_Line_Price_Att_rec.attribute10   := p_attribute10;
				l_x_Line_Price_Att_rec.attribute11   := p_attribute11;
				l_x_Line_Price_Att_rec.attribute12   := p_attribute12;
				l_x_Line_Price_Att_rec.attribute13   := p_attribute13;
				l_x_Line_Price_Att_rec.attribute14   := p_attribute14;
				l_x_Line_Price_Att_rec.attribute15   := p_attribute15;
	    ELSIF p_attr_id = OE_Line_PAttr_Util.G_PRICING_CONTEXT
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE1
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE2
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE3
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE4
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE5
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE6
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE7
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE8
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE9
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE10
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE11
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE12
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE13
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE14
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE15
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE16
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE17
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE18
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE19
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE20
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE21
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE22
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE23
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE24
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE25
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE26
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE27
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE28
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE29
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE30
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE31
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE32
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE33
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE34
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE35
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE36
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE37
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE38
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE39
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE40
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE41
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE42
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE43
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE44
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE45
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE46
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE47
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE48
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE49
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE50
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE51
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE52
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE53
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE54
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE55
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE56
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE57
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE58
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE59
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE60
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE61
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE62
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE63
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE64
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE65
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE66
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE67
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE68
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE69
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE70
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE71
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE72
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE73
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE74
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE75
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE76
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE77
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE78
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE79
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE80
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE81
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE82
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE83
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE84
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE85
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE86
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE87
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE88
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE89
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE90
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE91
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE92
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE93
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE94
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE95
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE96
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE97
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE98
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE99
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE100
			THEN
				l_x_Line_Price_Att_rec.flex_title := 	p_flex_title;
				l_x_Line_Price_Att_rec.pricing_context       := p_pricing_context;
				l_x_Line_Price_Att_rec.pricing_attribute1    := p_pricing_attribute1;
				l_x_Line_Price_Att_rec.pricing_attribute2    := p_pricing_attribute2;
				l_x_Line_Price_Att_rec.pricing_attribute3    := p_pricing_attribute3;
				l_x_Line_Price_Att_rec.pricing_attribute4    := p_pricing_attribute4;
				l_x_Line_Price_Att_rec.pricing_attribute5    := p_pricing_attribute5;
				l_x_Line_Price_Att_rec.pricing_attribute6    := p_pricing_attribute6;
				l_x_Line_Price_Att_rec.pricing_attribute7    := p_pricing_attribute7;
				l_x_Line_Price_Att_rec.pricing_attribute8    := p_pricing_attribute8;
				l_x_Line_Price_Att_rec.pricing_attribute9    := p_pricing_attribute9;
				l_x_Line_Price_Att_rec.pricing_attribute10   := p_pricing_attribute10;
				l_x_Line_Price_Att_rec.pricing_attribute11   := p_pricing_attribute11;
				l_x_Line_Price_Att_rec.pricing_attribute12   := p_pricing_attribute12;
				l_x_Line_Price_Att_rec.pricing_attribute13   := p_pricing_attribute13;
				l_x_Line_Price_Att_rec.pricing_attribute14   := p_pricing_attribute14;
				l_x_Line_Price_Att_rec.pricing_attribute15   := p_pricing_attribute15;
				l_x_Line_Price_Att_rec.pricing_attribute16    := p_pricing_attribute16;
				l_x_Line_Price_Att_rec.pricing_attribute17    := p_pricing_attribute17;
				l_x_Line_Price_Att_rec.pricing_attribute18    := p_pricing_attribute18;
				l_x_Line_Price_Att_rec.pricing_attribute19    := p_pricing_attribute19;
				l_x_Line_Price_Att_rec.pricing_attribute20   := p_pricing_attribute20;
				l_x_Line_Price_Att_rec.pricing_attribute21   := p_pricing_attribute21;
				l_x_Line_Price_Att_rec.pricing_attribute22   := p_pricing_attribute22;
				l_x_Line_Price_Att_rec.pricing_attribute23   := p_pricing_attribute23;
				l_x_Line_Price_Att_rec.pricing_attribute24   := p_pricing_attribute24;
				l_x_Line_Price_Att_rec.pricing_attribute25   := p_pricing_attribute25;
				l_x_Line_Price_Att_rec.pricing_attribute26    := p_pricing_attribute26;
				l_x_Line_Price_Att_rec.pricing_attribute27    := p_pricing_attribute27;
				l_x_Line_Price_Att_rec.pricing_attribute28    := p_pricing_attribute28;
				l_x_Line_Price_Att_rec.pricing_attribute29    := p_pricing_attribute29;
				l_x_Line_Price_Att_rec.pricing_attribute30   := p_pricing_attribute30;
				l_x_Line_Price_Att_rec.pricing_attribute31   := p_pricing_attribute31;
				l_x_Line_Price_Att_rec.pricing_attribute32   := p_pricing_attribute32;
				l_x_Line_Price_Att_rec.pricing_attribute33   := p_pricing_attribute33;
				l_x_Line_Price_Att_rec.pricing_attribute34   := p_pricing_attribute34;
				l_x_Line_Price_Att_rec.pricing_attribute35   := p_pricing_attribute35;
				l_x_Line_Price_Att_rec.pricing_attribute36    := p_pricing_attribute36;
				l_x_Line_Price_Att_rec.pricing_attribute37    := p_pricing_attribute37;
				l_x_Line_Price_Att_rec.pricing_attribute38    := p_pricing_attribute38;
				l_x_Line_Price_Att_rec.pricing_attribute39    := p_pricing_attribute39;
				l_x_Line_Price_Att_rec.pricing_attribute40   := p_pricing_attribute40;
				l_x_Line_Price_Att_rec.pricing_attribute41   := p_pricing_attribute41;
				l_x_Line_Price_Att_rec.pricing_attribute42   := p_pricing_attribute42;
				l_x_Line_Price_Att_rec.pricing_attribute43   := p_pricing_attribute43;
				l_x_Line_Price_Att_rec.pricing_attribute44   := p_pricing_attribute44;
				l_x_Line_Price_Att_rec.pricing_attribute45   := p_pricing_attribute45;
				l_x_Line_Price_Att_rec.pricing_attribute46    := p_pricing_attribute46;
				l_x_Line_Price_Att_rec.pricing_attribute47    := p_pricing_attribute47;
				l_x_Line_Price_Att_rec.pricing_attribute48    := p_pricing_attribute48;
				l_x_Line_Price_Att_rec.pricing_attribute49    := p_pricing_attribute49;
				l_x_Line_Price_Att_rec.pricing_attribute50   := p_pricing_attribute50;
				l_x_Line_Price_Att_rec.pricing_attribute51   := p_pricing_attribute51;
				l_x_Line_Price_Att_rec.pricing_attribute52   := p_pricing_attribute52;
				l_x_Line_Price_Att_rec.pricing_attribute53   := p_pricing_attribute53;
				l_x_Line_Price_Att_rec.pricing_attribute54   := p_pricing_attribute54;
				l_x_Line_Price_Att_rec.pricing_attribute55   := p_pricing_attribute55;
				l_x_Line_Price_Att_rec.pricing_attribute56    := p_pricing_attribute56;
				l_x_Line_Price_Att_rec.pricing_attribute57    := p_pricing_attribute57;
				l_x_Line_Price_Att_rec.pricing_attribute58    := p_pricing_attribute58;
				l_x_Line_Price_Att_rec.pricing_attribute59    := p_pricing_attribute59;
				l_x_Line_Price_Att_rec.pricing_attribute60   := p_pricing_attribute60;
				l_x_Line_Price_Att_rec.pricing_attribute61   := p_pricing_attribute61;
				l_x_Line_Price_Att_rec.pricing_attribute62   := p_pricing_attribute62;
				l_x_Line_Price_Att_rec.pricing_attribute63   := p_pricing_attribute63;
				l_x_Line_Price_Att_rec.pricing_attribute64   := p_pricing_attribute64;
				l_x_Line_Price_Att_rec.pricing_attribute65   := p_pricing_attribute65;
				l_x_Line_Price_Att_rec.pricing_attribute66    := p_pricing_attribute66;
				l_x_Line_Price_Att_rec.pricing_attribute67    := p_pricing_attribute67;
				l_x_Line_Price_Att_rec.pricing_attribute68    := p_pricing_attribute68;
				l_x_Line_Price_Att_rec.pricing_attribute69    := p_pricing_attribute69;
				l_x_Line_Price_Att_rec.pricing_attribute70   := p_pricing_attribute70;
				l_x_Line_Price_Att_rec.pricing_attribute71   := p_pricing_attribute71;
				l_x_Line_Price_Att_rec.pricing_attribute72   := p_pricing_attribute72;
				l_x_Line_Price_Att_rec.pricing_attribute73   := p_pricing_attribute73;
				l_x_Line_Price_Att_rec.pricing_attribute74   := p_pricing_attribute74;
				l_x_Line_Price_Att_rec.pricing_attribute75   := p_pricing_attribute75;
				l_x_Line_Price_Att_rec.pricing_attribute76    := p_pricing_attribute76;
				l_x_Line_Price_Att_rec.pricing_attribute77    := p_pricing_attribute77;
				l_x_Line_Price_Att_rec.pricing_attribute78    := p_pricing_attribute78;
				l_x_Line_Price_Att_rec.pricing_attribute79    := p_pricing_attribute79;
				l_x_Line_Price_Att_rec.pricing_attribute80   := p_pricing_attribute80;
				l_x_Line_Price_Att_rec.pricing_attribute81   := p_pricing_attribute81;
				l_x_Line_Price_Att_rec.pricing_attribute82   := p_pricing_attribute82;
				l_x_Line_Price_Att_rec.pricing_attribute83   := p_pricing_attribute83;
				l_x_Line_Price_Att_rec.pricing_attribute84   := p_pricing_attribute84;
				l_x_Line_Price_Att_rec.pricing_attribute85   := p_pricing_attribute85;
				l_x_Line_Price_Att_rec.pricing_attribute86    := p_pricing_attribute86;
				l_x_Line_Price_Att_rec.pricing_attribute87    := p_pricing_attribute87;
				l_x_Line_Price_Att_rec.pricing_attribute88    := p_pricing_attribute88;
				l_x_Line_Price_Att_rec.pricing_attribute89    := p_pricing_attribute89;
				l_x_Line_Price_Att_rec.pricing_attribute90   := p_pricing_attribute90;
				l_x_Line_Price_Att_rec.pricing_attribute91   := p_pricing_attribute91;
				l_x_Line_Price_Att_rec.pricing_attribute92   := p_pricing_attribute92;
				l_x_Line_Price_Att_rec.pricing_attribute93   := p_pricing_attribute93;
				l_x_Line_Price_Att_rec.pricing_attribute94   := p_pricing_attribute94;
				l_x_Line_Price_Att_rec.pricing_attribute95   := p_pricing_attribute95;
				l_x_Line_Price_Att_rec.pricing_attribute96    := p_pricing_attribute96;
				l_x_Line_Price_Att_rec.pricing_attribute97    := p_pricing_attribute97;
				l_x_Line_Price_Att_rec.pricing_attribute98    := p_pricing_attribute98;
				l_x_Line_Price_Att_rec.pricing_attribute99    := p_pricing_attribute99;
				l_x_Line_Price_Att_rec.pricing_attribute100    := p_pricing_attribute100;

		ELSE

	 --  Unexpected error, unrecognized attribute

		    	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
			OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'Change_Attributes'
			,   'Unrecognized attribute'
			);
			END IF;

																			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
																		END IF;



   --bug 3266627
   --Added the if loop p_called_from_pattr=N so that this fires only if called from sales order
      IF p_called_from_pattr = 'N' THEN
        IF l_x_Line_Price_Att_rec.pricing_context is null and
           l_x_old_Line_Price_Att_rec.pricing_context is null then
             clear_order_line_attr;
             return;
        END IF;
      END IF;
   --bug 3266627
    --  Set Operation.
	   IF FND_API.To_Boolean(l_x_Line_Price_Att_rec.db_flag) THEN
		   l_x_Line_Price_Att_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
	   ELSE
		   l_x_Line_Price_Att_rec.operation := OE_GLOBALS.G_OPR_CREATE;
	   END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' PATTR OPERATION:'||L_X_LINE_PRICE_ATT_REC.OPERATION ) ;
    END IF;
    --If new pricing context is null and old is not null then we
    --know user is clearing the field hence operation delete
    If l_x_line_price_att_rec.pricing_context is Null and
       l_x_old_Line_Price_Att_rec.pricing_context is Not Null and
       l_x_Line_Price_Att_rec.operation <>  OE_GLOBALS.G_OPR_CREATE
    Then

       l_x_Line_Price_Att_rec.operation := OE_GLOBALS.G_OPR_DELETE;
       clear_order_line_attr;

    End If;

  	--  Populate Order Line pricing Attributes table

	 l_x_Line_Price_Att_Tbl(1) := l_x_Line_Price_Att_rec;
	 l_x_old_Line_Price_Att_tbl(1) := l_x_old_Line_Price_Att_rec;


    -- Call Oe_Order_Adj_Pvt.Line_Price_Atts
    l_Line_Price_Att_rec := l_x_Line_Price_Att_rec;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' NEW PRICING CONTEXT:'||L_X_LINE_PRICE_ATT_TBL ( 1 ) .PRICING_CONTEXT ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' OLD PRICING CONTEXT:'||L_X_OLD_LINE_PRICE_ATT_TBL ( 1 ) .PRICING_CONTEXT ) ;
    END IF;

    IF p_called_from_pattr <> 'Y' THEN
      -- this is coming from Sales Order Line window.
      if l_x_Line_price_att_tbl(1).flex_title is null then
         l_x_Line_price_att_tbl(1).flex_title := 'QP_ATTR_DEFNS_PRICING';
      end if;
    END IF;

    oe_order_adj_pvt.Line_Price_Atts
    (	p_init_msg_list			=> FND_API.G_TRUE
    ,	p_validation_level 			=> FND_API.G_VALID_LEVEL_NONE
    ,	p_control_rec				=> l_control_rec
    ,	p_x_line_price_att_tbl		=> l_x_Line_price_att_tbl
    ,	p_x_old_line_price_att_tbl	=> l_x_old_Line_price_att_tbl
    );

    --Pricing attributes has changed, repricing needed. Log delayed request
    --for repricing
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PATTR:'||L_X_LINE_PRICE_ATT_REC.LINE_ID ) ;
    END IF;
    OE_delayed_requests_Pvt.log_request(p_entity_code 		 => 'LINE',
	          			p_entity_id         	 => l_x_Line_Price_Att_rec.line_id,
			        	p_requesting_entity_code => 'LINE',
				        p_requesting_entity_id   => l_x_Line_Price_Att_rec.line_id,
		 		        p_param1                 => l_x_Line_Price_Att_rec.line_id,
                                        p_request_unique_key1    => 'PRICE',--'BATCH', --Bug 8555923
                 	                p_param2                 => 'PRICE',--'BATCH', --Bug 8555923
		 		        p_request_type           => 'PRICE_LINE',
		 		        x_return_status          => l_return_status);

	l_x_Line_Price_Att_Rec := l_x_Line_Price_Att_tbl(1);

    IF l_x_Line_Price_Att_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'PATTR ERROR 1' ) ;
         END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_x_Line_Price_Att_rec.return_status = FND_API.G_RET_STS_ERROR THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'PATTR ERROR 2' ) ;
         END IF;
	 RAISE FND_API.G_EXC_ERROR;
    END IF;

	-- Init Out parameters
    x_attribute1                   := FND_API.G_MISS_CHAR;
    x_attribute10                  := FND_API.G_MISS_CHAR;
    x_attribute11                  := FND_API.G_MISS_CHAR;
    x_attribute12                  := FND_API.G_MISS_CHAR;
    x_attribute13                  := FND_API.G_MISS_CHAR;
    x_attribute14                  := FND_API.G_MISS_CHAR;
    x_attribute15                  := FND_API.G_MISS_CHAR;
    x_attribute2                   := FND_API.G_MISS_CHAR;
    x_attribute3                   := FND_API.G_MISS_CHAR;
    x_attribute4                   := FND_API.G_MISS_CHAR;
    x_attribute5                   := FND_API.G_MISS_CHAR;
    x_attribute6                   := FND_API.G_MISS_CHAR;
    x_attribute7                   := FND_API.G_MISS_CHAR;
    x_attribute8                   := FND_API.G_MISS_CHAR;
    x_attribute9                   := FND_API.G_MISS_CHAR;
    x_context                      := FND_API.G_MISS_CHAR;
    x_flex_title                   := FND_API.G_MISS_CHAR;
    x_header_id                    := FND_API.G_MISS_NUM;
    x_line_id                      := FND_API.G_MISS_NUM;
    x_order_price_attrib_id        := FND_API.G_MISS_NUM;
    x_pricing_attribute1           := FND_API.G_MISS_CHAR;
    x_pricing_attribute10          := FND_API.G_MISS_CHAR;
    x_pricing_attribute100         := FND_API.G_MISS_CHAR;
    x_pricing_attribute11          := FND_API.G_MISS_CHAR;
    x_pricing_attribute12          := FND_API.G_MISS_CHAR;
    x_pricing_attribute13          := FND_API.G_MISS_CHAR;
    x_pricing_attribute14          := FND_API.G_MISS_CHAR;
    x_pricing_attribute15          := FND_API.G_MISS_CHAR;
    x_pricing_attribute16          := FND_API.G_MISS_CHAR;
    x_pricing_attribute17          := FND_API.G_MISS_CHAR;
    x_pricing_attribute18          := FND_API.G_MISS_CHAR;
    x_pricing_attribute19          := FND_API.G_MISS_CHAR;
    x_pricing_attribute2           := FND_API.G_MISS_CHAR;
    x_pricing_attribute20          := FND_API.G_MISS_CHAR;
    x_pricing_attribute21          := FND_API.G_MISS_CHAR;
    x_pricing_attribute22          := FND_API.G_MISS_CHAR;
    x_pricing_attribute23          := FND_API.G_MISS_CHAR;
    x_pricing_attribute24          := FND_API.G_MISS_CHAR;
    x_pricing_attribute25          := FND_API.G_MISS_CHAR;
    x_pricing_attribute26          := FND_API.G_MISS_CHAR;
    x_pricing_attribute27          := FND_API.G_MISS_CHAR;
    x_pricing_attribute28          := FND_API.G_MISS_CHAR;
    x_pricing_attribute29          := FND_API.G_MISS_CHAR;
    x_pricing_attribute3           := FND_API.G_MISS_CHAR;
    x_pricing_attribute30          := FND_API.G_MISS_CHAR;
    x_pricing_attribute31          := FND_API.G_MISS_CHAR;
    x_pricing_attribute32          := FND_API.G_MISS_CHAR;
    x_pricing_attribute33          := FND_API.G_MISS_CHAR;
    x_pricing_attribute34          := FND_API.G_MISS_CHAR;
    x_pricing_attribute35          := FND_API.G_MISS_CHAR;
    x_pricing_attribute36          := FND_API.G_MISS_CHAR;
    x_pricing_attribute37          := FND_API.G_MISS_CHAR;
    x_pricing_attribute38          := FND_API.G_MISS_CHAR;
    x_pricing_attribute39          := FND_API.G_MISS_CHAR;
    x_pricing_attribute4           := FND_API.G_MISS_CHAR;
    x_pricing_attribute40          := FND_API.G_MISS_CHAR;
    x_pricing_attribute41          := FND_API.G_MISS_CHAR;
    x_pricing_attribute42          := FND_API.G_MISS_CHAR;
    x_pricing_attribute43          := FND_API.G_MISS_CHAR;
    x_pricing_attribute44          := FND_API.G_MISS_CHAR;
    x_pricing_attribute45          := FND_API.G_MISS_CHAR;
    x_pricing_attribute46          := FND_API.G_MISS_CHAR;
    x_pricing_attribute47          := FND_API.G_MISS_CHAR;
    x_pricing_attribute48          := FND_API.G_MISS_CHAR;
    x_pricing_attribute49          := FND_API.G_MISS_CHAR;
    x_pricing_attribute5           := FND_API.G_MISS_CHAR;
    x_pricing_attribute50          := FND_API.G_MISS_CHAR;
    x_pricing_attribute51          := FND_API.G_MISS_CHAR;
    x_pricing_attribute52          := FND_API.G_MISS_CHAR;
    x_pricing_attribute53          := FND_API.G_MISS_CHAR;
    x_pricing_attribute54          := FND_API.G_MISS_CHAR;
    x_pricing_attribute55          := FND_API.G_MISS_CHAR;
    x_pricing_attribute56          := FND_API.G_MISS_CHAR;
    x_pricing_attribute57          := FND_API.G_MISS_CHAR;
    x_pricing_attribute58          := FND_API.G_MISS_CHAR;
    x_pricing_attribute59          := FND_API.G_MISS_CHAR;
    x_pricing_attribute6           := FND_API.G_MISS_CHAR;
    x_pricing_attribute60          := FND_API.G_MISS_CHAR;
    x_pricing_attribute61          := FND_API.G_MISS_CHAR;
    x_pricing_attribute62          := FND_API.G_MISS_CHAR;
    x_pricing_attribute63          := FND_API.G_MISS_CHAR;
    x_pricing_attribute64          := FND_API.G_MISS_CHAR;
    x_pricing_attribute65          := FND_API.G_MISS_CHAR;
    x_pricing_attribute66          := FND_API.G_MISS_CHAR;
    x_pricing_attribute67          := FND_API.G_MISS_CHAR;
    x_pricing_attribute68          := FND_API.G_MISS_CHAR;
    x_pricing_attribute69          := FND_API.G_MISS_CHAR;
    x_pricing_attribute7           := FND_API.G_MISS_CHAR;
    x_pricing_attribute70          := FND_API.G_MISS_CHAR;
    x_pricing_attribute71          := FND_API.G_MISS_CHAR;
    x_pricing_attribute72          := FND_API.G_MISS_CHAR;
    x_pricing_attribute73          := FND_API.G_MISS_CHAR;
    x_pricing_attribute74          := FND_API.G_MISS_CHAR;
    x_pricing_attribute75          := FND_API.G_MISS_CHAR;
    x_pricing_attribute76          := FND_API.G_MISS_CHAR;
    x_pricing_attribute77          := FND_API.G_MISS_CHAR;
    x_pricing_attribute78          := FND_API.G_MISS_CHAR;
    x_pricing_attribute79          := FND_API.G_MISS_CHAR;
    x_pricing_attribute8           := FND_API.G_MISS_CHAR;
    x_pricing_attribute80          := FND_API.G_MISS_CHAR;
    x_pricing_attribute81          := FND_API.G_MISS_CHAR;
    x_pricing_attribute82          := FND_API.G_MISS_CHAR;
    x_pricing_attribute83          := FND_API.G_MISS_CHAR;
    x_pricing_attribute84          := FND_API.G_MISS_CHAR;
    x_pricing_attribute85          := FND_API.G_MISS_CHAR;
    x_pricing_attribute86          := FND_API.G_MISS_CHAR;
    x_pricing_attribute87          := FND_API.G_MISS_CHAR;
    x_pricing_attribute88          := FND_API.G_MISS_CHAR;
    x_pricing_attribute89          := FND_API.G_MISS_CHAR;
    x_pricing_attribute9           := FND_API.G_MISS_CHAR;
    x_pricing_attribute90          := FND_API.G_MISS_CHAR;
    x_pricing_attribute91          := FND_API.G_MISS_CHAR;
    x_pricing_attribute92          := FND_API.G_MISS_CHAR;
    x_pricing_attribute93          := FND_API.G_MISS_CHAR;
    x_pricing_attribute94          := FND_API.G_MISS_CHAR;
    x_pricing_attribute95          := FND_API.G_MISS_CHAR;
    x_pricing_attribute96          := FND_API.G_MISS_CHAR;
    x_pricing_attribute97          := FND_API.G_MISS_CHAR;
    x_pricing_attribute98          := FND_API.G_MISS_CHAR;
    x_pricing_attribute99          := FND_API.G_MISS_CHAR;
    x_pricing_context              := FND_API.G_MISS_CHAR;
    x_override_flag              := FND_API.G_MISS_CHAR;

	-- Record structure

         -- No Get Values

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.override_flag,
		   l_Line_Price_Att_Rec.override_flag)
     THEN
		x_override_flag := l_x_Line_Price_Att_Rec.override_flag;
     END IF;


	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute1,
		   l_Line_Price_Att_Rec.attribute1)
     THEN
		x_attribute1 := l_x_Line_Price_Att_Rec.attribute1;
     END IF;


	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute2,
		   l_Line_Price_Att_Rec.attribute2)
     THEN
		x_attribute3 := l_x_Line_Price_Att_Rec.attribute2;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute3,
		   l_Line_Price_Att_Rec.attribute3)
     THEN
		x_attribute3 := l_x_Line_Price_Att_Rec.attribute3;
     END IF;


	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute4,
		   l_Line_Price_Att_Rec.attribute4)
     THEN
		x_attribute4 := l_x_Line_Price_Att_Rec.attribute4;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute5,
		   l_Line_Price_Att_Rec.attribute5)
     THEN
		x_attribute5 := l_x_Line_Price_Att_Rec.attribute5;
     END IF;
	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute6,
		   l_Line_Price_Att_Rec.attribute6)
     THEN
		x_attribute6 := l_x_Line_Price_Att_Rec.attribute6;
     END IF;
	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute7,
		   l_Line_Price_Att_Rec.attribute7)
     THEN
		x_attribute7 := l_x_Line_Price_Att_Rec.attribute7;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute8,
		   l_Line_Price_Att_Rec.attribute8)
     THEN
		x_attribute8 := l_x_Line_Price_Att_Rec.attribute8;
     END IF;



	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute9,
		   l_Line_Price_Att_Rec.attribute9)
     THEN
		x_attribute9 := l_x_Line_Price_Att_Rec.attribute9;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute10,
		   l_Line_Price_Att_Rec.attribute10)
     THEN
		x_attribute10 := l_x_Line_Price_Att_Rec.attribute10;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute11,
		   l_Line_Price_Att_Rec.attribute11)
     THEN
		x_attribute11 := l_x_Line_Price_Att_Rec.attribute11;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute12,
		   l_Line_Price_Att_Rec.attribute12)
     THEN
		x_attribute12 := l_x_Line_Price_Att_Rec.attribute12;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute13,
		   l_Line_Price_Att_Rec.attribute13)
     THEN
		x_attribute13 := l_x_Line_Price_Att_Rec.attribute13;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute14,
		   l_Line_Price_Att_Rec.attribute14)
     THEN
		x_attribute14 := l_x_Line_Price_Att_Rec.attribute14;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute15,
		   l_Line_Price_Att_Rec.attribute15)
     THEN
		x_attribute15 := l_x_Line_Price_Att_Rec.attribute15;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.header_id,
		   l_Line_Price_Att_Rec.header_id)
     THEN
		x_header_id := l_x_Line_Price_Att_Rec.header_id;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.line_id,
		   l_Line_Price_Att_Rec.line_id)
     THEN
		x_line_id := l_x_Line_Price_Att_Rec.line_id;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.flex_title,
		   l_Line_Price_Att_Rec.flex_title)
     THEN
		x_flex_title := l_x_Line_Price_Att_Rec.flex_title;
     END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.order_price_attrib_id,
                            l_Line_Price_Att_Rec.order_price_attrib_id)
    THEN
        x_order_price_attrib_id := l_x_Line_Price_Att_Rec.order_price_attrib_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute1,
                            l_Line_Price_Att_Rec.pricing_attribute1)
    THEN
        x_pricing_attribute1 := l_x_Line_Price_Att_Rec.pricing_attribute1;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute10,
                            l_Line_Price_Att_Rec.pricing_attribute10)
    THEN
        x_pricing_attribute10 := l_x_Line_Price_Att_Rec.pricing_attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute100,
                            l_Line_Price_Att_Rec.pricing_attribute100)
    THEN
        x_pricing_attribute100 := l_x_Line_Price_Att_Rec.pricing_attribute100;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute11,
                            l_Line_Price_Att_Rec.pricing_attribute11)
    THEN
        x_pricing_attribute11 := l_x_Line_Price_Att_Rec.pricing_attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute12,
                            l_Line_Price_Att_Rec.pricing_attribute12)
    THEN
        x_pricing_attribute12 := l_x_Line_Price_Att_Rec.pricing_attribute12;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute13,
                            l_Line_Price_Att_Rec.pricing_attribute13)
    THEN
        x_pricing_attribute13 := l_x_Line_Price_Att_Rec.pricing_attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute14,
                            l_Line_Price_Att_Rec.pricing_attribute14)
    THEN
        x_pricing_attribute14 := l_x_Line_Price_Att_Rec.pricing_attribute14;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute15,
                            l_Line_Price_Att_Rec.pricing_attribute15)
    THEN
        x_pricing_attribute15 := l_x_Line_Price_Att_Rec.pricing_attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute16,
                            l_Line_Price_Att_Rec.pricing_attribute16)
    THEN
        x_pricing_attribute16 := l_x_Line_Price_Att_Rec.pricing_attribute16;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute17,
                            l_Line_Price_Att_Rec.pricing_attribute17)
    THEN
        x_pricing_attribute17 := l_x_Line_Price_Att_Rec.pricing_attribute17;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute18,
                            l_Line_Price_Att_Rec.pricing_attribute18)
    THEN
        x_pricing_attribute18 := l_x_Line_Price_Att_Rec.pricing_attribute18;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute19,
                            l_Line_Price_Att_Rec.pricing_attribute19)
    THEN
        x_pricing_attribute19 := l_x_Line_Price_Att_Rec.pricing_attribute19;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute2,
                            l_Line_Price_Att_Rec.pricing_attribute2)
    THEN
        x_pricing_attribute2 := l_x_Line_Price_Att_Rec.pricing_attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute20,
                            l_Line_Price_Att_Rec.pricing_attribute20)
    THEN
        x_pricing_attribute20 := l_x_Line_Price_Att_Rec.pricing_attribute20;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute21,
                            l_Line_Price_Att_Rec.pricing_attribute21)
    THEN
        x_pricing_attribute21 := l_x_Line_Price_Att_Rec.pricing_attribute21;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute22,
                            l_Line_Price_Att_Rec.pricing_attribute22)
    THEN
        x_pricing_attribute22 := l_x_Line_Price_Att_Rec.pricing_attribute22;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute23,
                            l_Line_Price_Att_Rec.pricing_attribute23)
    THEN
        x_pricing_attribute23 := l_x_Line_Price_Att_Rec.pricing_attribute23;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute24,
                            l_Line_Price_Att_Rec.pricing_attribute24)
    THEN
        x_pricing_attribute24 := l_x_Line_Price_Att_Rec.pricing_attribute24;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute25,
                            l_Line_Price_Att_Rec.pricing_attribute25)
    THEN
        x_pricing_attribute25 := l_x_Line_Price_Att_Rec.pricing_attribute25;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute26,
                            l_Line_Price_Att_Rec.pricing_attribute26)
    THEN
        x_pricing_attribute26 := l_x_Line_Price_Att_Rec.pricing_attribute26;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute27,
                            l_Line_Price_Att_Rec.pricing_attribute27)
    THEN
        x_pricing_attribute27 := l_x_Line_Price_Att_Rec.pricing_attribute27;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute28,
                            l_Line_Price_Att_Rec.pricing_attribute28)
    THEN
        x_pricing_attribute28 := l_x_Line_Price_Att_Rec.pricing_attribute28;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute29,
                            l_Line_Price_Att_Rec.pricing_attribute29)
    THEN
        x_pricing_attribute29 := l_x_Line_Price_Att_Rec.pricing_attribute29;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute3,
                            l_Line_Price_Att_Rec.pricing_attribute3)
    THEN
        x_pricing_attribute3 := l_x_Line_Price_Att_Rec.pricing_attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute30,
                            l_Line_Price_Att_Rec.pricing_attribute30)
    THEN
        x_pricing_attribute30 := l_x_Line_Price_Att_Rec.pricing_attribute30;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute31,
                            l_Line_Price_Att_Rec.pricing_attribute31)
    THEN
        x_pricing_attribute31 := l_x_Line_Price_Att_Rec.pricing_attribute31;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute32,
                            l_Line_Price_Att_Rec.pricing_attribute32)
    THEN
        x_pricing_attribute32 := l_x_Line_Price_Att_Rec.pricing_attribute32;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute33,
                            l_Line_Price_Att_Rec.pricing_attribute33)
    THEN
        x_pricing_attribute33 := l_x_Line_Price_Att_Rec.pricing_attribute33;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute34,
                            l_Line_Price_Att_Rec.pricing_attribute34)
    THEN
        x_pricing_attribute34 := l_x_Line_Price_Att_Rec.pricing_attribute34;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute35,
                            l_Line_Price_Att_Rec.pricing_attribute35)
    THEN
        x_pricing_attribute35 := l_x_Line_Price_Att_Rec.pricing_attribute35;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute36,
                            l_Line_Price_Att_Rec.pricing_attribute36)
    THEN
        x_pricing_attribute36 := l_x_Line_Price_Att_Rec.pricing_attribute36;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute37,
                            l_Line_Price_Att_Rec.pricing_attribute37)
    THEN
        x_pricing_attribute37 := l_x_Line_Price_Att_Rec.pricing_attribute37;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute38,
                            l_Line_Price_Att_Rec.pricing_attribute38)
    THEN
        x_pricing_attribute38 := l_x_Line_Price_Att_Rec.pricing_attribute38;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute39,
                            l_Line_Price_Att_Rec.pricing_attribute39)
    THEN
        x_pricing_attribute39 := l_x_Line_Price_Att_Rec.pricing_attribute39;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute4,
                            l_Line_Price_Att_Rec.pricing_attribute4)
    THEN
        x_pricing_attribute4 := l_x_Line_Price_Att_Rec.pricing_attribute4;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute40,
                            l_Line_Price_Att_Rec.pricing_attribute40)
    THEN
        x_pricing_attribute40 := l_x_Line_Price_Att_Rec.pricing_attribute40;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute41,
                            l_Line_Price_Att_Rec.pricing_attribute41)
    THEN
        x_pricing_attribute41 := l_x_Line_Price_Att_Rec.pricing_attribute41;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute42,
                            l_Line_Price_Att_Rec.pricing_attribute42)
    THEN
        x_pricing_attribute42 := l_x_Line_Price_Att_Rec.pricing_attribute42;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute43,
                            l_Line_Price_Att_Rec.pricing_attribute43)
    THEN
        x_pricing_attribute43 := l_x_Line_Price_Att_Rec.pricing_attribute43;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute44,
                            l_Line_Price_Att_Rec.pricing_attribute44)
    THEN
        x_pricing_attribute44 := l_x_Line_Price_Att_Rec.pricing_attribute44;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute45,
                            l_Line_Price_Att_Rec.pricing_attribute45)
    THEN
        x_pricing_attribute45 := l_x_Line_Price_Att_Rec.pricing_attribute45;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute46,
                            l_Line_Price_Att_Rec.pricing_attribute46)
    THEN
        x_pricing_attribute46 := l_x_Line_Price_Att_Rec.pricing_attribute46;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute47,
                            l_Line_Price_Att_Rec.pricing_attribute47)
    THEN
        x_pricing_attribute47 := l_x_Line_Price_Att_Rec.pricing_attribute47;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute48,
                            l_Line_Price_Att_Rec.pricing_attribute48)
    THEN
        x_pricing_attribute48 := l_x_Line_Price_Att_Rec.pricing_attribute48;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute49,
                            l_Line_Price_Att_Rec.pricing_attribute49)
    THEN
        x_pricing_attribute49 := l_x_Line_Price_Att_Rec.pricing_attribute49;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute5,
                            l_Line_Price_Att_Rec.pricing_attribute5)
    THEN
        x_pricing_attribute5 := l_x_Line_Price_Att_Rec.pricing_attribute5;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute50,
                            l_Line_Price_Att_Rec.pricing_attribute50)
    THEN
        x_pricing_attribute50 := l_x_Line_Price_Att_Rec.pricing_attribute50;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute51,
                            l_Line_Price_Att_Rec.pricing_attribute51)
    THEN
        x_pricing_attribute51 := l_x_Line_Price_Att_Rec.pricing_attribute51;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute52,
                            l_Line_Price_Att_Rec.pricing_attribute52)
    THEN
        x_pricing_attribute52 := l_x_Line_Price_Att_Rec.pricing_attribute52;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute53,
                            l_Line_Price_Att_Rec.pricing_attribute53)
    THEN
        x_pricing_attribute53 := l_x_Line_Price_Att_Rec.pricing_attribute53;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute54,
                            l_Line_Price_Att_Rec.pricing_attribute54)
    THEN
        x_pricing_attribute54 := l_x_Line_Price_Att_Rec.pricing_attribute54;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute55,
                            l_Line_Price_Att_Rec.pricing_attribute55)
    THEN
        x_pricing_attribute55 := l_x_Line_Price_Att_Rec.pricing_attribute55;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute56,
                            l_Line_Price_Att_Rec.pricing_attribute56)
    THEN
        x_pricing_attribute56 := l_x_Line_Price_Att_Rec.pricing_attribute56;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute57,
                            l_Line_Price_Att_Rec.pricing_attribute57)
    THEN
        x_pricing_attribute57 := l_x_Line_Price_Att_Rec.pricing_attribute57;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute58,
                            l_Line_Price_Att_Rec.pricing_attribute58)
    THEN
        x_pricing_attribute58 := l_x_Line_Price_Att_Rec.pricing_attribute58;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute59,
                            l_Line_Price_Att_Rec.pricing_attribute59)
    THEN
        x_pricing_attribute59 := l_x_Line_Price_Att_Rec.pricing_attribute59;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute6,
                            l_Line_Price_Att_Rec.pricing_attribute6)
    THEN
        x_pricing_attribute6 := l_x_Line_Price_Att_Rec.pricing_attribute6;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute60,
                            l_Line_Price_Att_Rec.pricing_attribute60)
    THEN
        x_pricing_attribute60 := l_x_Line_Price_Att_Rec.pricing_attribute60;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute61,
                            l_Line_Price_Att_Rec.pricing_attribute61)
    THEN
        x_pricing_attribute61 := l_x_Line_Price_Att_Rec.pricing_attribute61;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute62,
                            l_Line_Price_Att_Rec.pricing_attribute62)
    THEN
        x_pricing_attribute62 := l_x_Line_Price_Att_Rec.pricing_attribute62;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute63,
                            l_Line_Price_Att_Rec.pricing_attribute63)
    THEN
        x_pricing_attribute63 := l_x_Line_Price_Att_Rec.pricing_attribute63;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute64,
                            l_Line_Price_Att_Rec.pricing_attribute64)
    THEN
        x_pricing_attribute64 := l_x_Line_Price_Att_Rec.pricing_attribute64;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute65,
                            l_Line_Price_Att_Rec.pricing_attribute65)
    THEN
        x_pricing_attribute65 := l_x_Line_Price_Att_Rec.pricing_attribute65;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute66,
                            l_Line_Price_Att_Rec.pricing_attribute66)
    THEN
        x_pricing_attribute66 := l_x_Line_Price_Att_Rec.pricing_attribute66;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute67,
                            l_Line_Price_Att_Rec.pricing_attribute67)
    THEN
        x_pricing_attribute67 := l_x_Line_Price_Att_Rec.pricing_attribute67;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute68,
                            l_Line_Price_Att_Rec.pricing_attribute68)
    THEN
        x_pricing_attribute68 := l_x_Line_Price_Att_Rec.pricing_attribute68;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute69,
                            l_Line_Price_Att_Rec.pricing_attribute69)
    THEN
        x_pricing_attribute69 := l_x_Line_Price_Att_Rec.pricing_attribute69;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute7,
                            l_Line_Price_Att_Rec.pricing_attribute7)
    THEN
        x_pricing_attribute7 := l_x_Line_Price_Att_Rec.pricing_attribute7;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute70,
                            l_Line_Price_Att_Rec.pricing_attribute70)
    THEN
        x_pricing_attribute70 := l_x_Line_Price_Att_Rec.pricing_attribute70;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute71,
                            l_Line_Price_Att_Rec.pricing_attribute71)
    THEN
        x_pricing_attribute71 := l_x_Line_Price_Att_Rec.pricing_attribute71;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute72,
                            l_Line_Price_Att_Rec.pricing_attribute72)
    THEN
        x_pricing_attribute72 := l_x_Line_Price_Att_Rec.pricing_attribute72;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute73,
                            l_Line_Price_Att_Rec.pricing_attribute73)
    THEN
        x_pricing_attribute73 := l_x_Line_Price_Att_Rec.pricing_attribute73;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute74,
                            l_Line_Price_Att_Rec.pricing_attribute74)
    THEN
        x_pricing_attribute74 := l_x_Line_Price_Att_Rec.pricing_attribute74;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute75,
                            l_Line_Price_Att_Rec.pricing_attribute75)
    THEN
        x_pricing_attribute75 := l_x_Line_Price_Att_Rec.pricing_attribute75;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute76,
                            l_Line_Price_Att_Rec.pricing_attribute76)
    THEN
        x_pricing_attribute76 := l_x_Line_Price_Att_Rec.pricing_attribute76;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute77,
                            l_Line_Price_Att_Rec.pricing_attribute77)
    THEN
        x_pricing_attribute77 := l_x_Line_Price_Att_Rec.pricing_attribute77;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute78,
                            l_Line_Price_Att_Rec.pricing_attribute78)
    THEN
        x_pricing_attribute78 := l_x_Line_Price_Att_Rec.pricing_attribute78;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute79,
                            l_Line_Price_Att_Rec.pricing_attribute79)
    THEN
        x_pricing_attribute79 := l_x_Line_Price_Att_Rec.pricing_attribute79;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute8,
                            l_Line_Price_Att_Rec.pricing_attribute8)
    THEN
        x_pricing_attribute8 := l_x_Line_Price_Att_Rec.pricing_attribute8;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute80,
                            l_Line_Price_Att_Rec.pricing_attribute80)
    THEN
        x_pricing_attribute80 := l_x_Line_Price_Att_Rec.pricing_attribute80;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute81,
                            l_Line_Price_Att_Rec.pricing_attribute81)
    THEN
        x_pricing_attribute81 := l_x_Line_Price_Att_Rec.pricing_attribute81;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute82,
                            l_Line_Price_Att_Rec.pricing_attribute82)
    THEN
        x_pricing_attribute82 := l_x_Line_Price_Att_Rec.pricing_attribute82;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute83,
                            l_Line_Price_Att_Rec.pricing_attribute83)
    THEN
        x_pricing_attribute83 := l_x_Line_Price_Att_Rec.pricing_attribute83;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute84,
                            l_Line_Price_Att_Rec.pricing_attribute84)
    THEN
        x_pricing_attribute84 := l_x_Line_Price_Att_Rec.pricing_attribute84;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute85,
                            l_Line_Price_Att_Rec.pricing_attribute85)
    THEN
        x_pricing_attribute85 := l_x_Line_Price_Att_Rec.pricing_attribute85;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute86,
                            l_Line_Price_Att_Rec.pricing_attribute86)
    THEN
        x_pricing_attribute86 := l_x_Line_Price_Att_Rec.pricing_attribute86;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute87,
                            l_Line_Price_Att_Rec.pricing_attribute87)
    THEN
        x_pricing_attribute87 := l_x_Line_Price_Att_Rec.pricing_attribute87;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute88,
                            l_Line_Price_Att_Rec.pricing_attribute88)
    THEN
        x_pricing_attribute88 := l_x_Line_Price_Att_Rec.pricing_attribute88;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute89,
                            l_Line_Price_Att_Rec.pricing_attribute89)
    THEN
        x_pricing_attribute89 := l_x_Line_Price_Att_Rec.pricing_attribute89;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute9,
                            l_Line_Price_Att_Rec.pricing_attribute9)
    THEN
        x_pricing_attribute9 := l_x_Line_Price_Att_Rec.pricing_attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute90,
                            l_Line_Price_Att_Rec.pricing_attribute90)
    THEN
        x_pricing_attribute90 := l_x_Line_Price_Att_Rec.pricing_attribute90;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute91,
                            l_Line_Price_Att_Rec.pricing_attribute91)
    THEN
        x_pricing_attribute91 := l_x_Line_Price_Att_Rec.pricing_attribute91;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute92,
                            l_Line_Price_Att_Rec.pricing_attribute92)
    THEN
        x_pricing_attribute92 := l_x_Line_Price_Att_Rec.pricing_attribute92;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute93,
                            l_Line_Price_Att_Rec.pricing_attribute93)
    THEN
        x_pricing_attribute93 := l_x_Line_Price_Att_Rec.pricing_attribute93;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute94,
                            l_Line_Price_Att_Rec.pricing_attribute94)
    THEN
        x_pricing_attribute94 := l_x_Line_Price_Att_Rec.pricing_attribute94;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute95,
                            l_Line_Price_Att_Rec.pricing_attribute95)
    THEN
        x_pricing_attribute95 := l_x_Line_Price_Att_Rec.pricing_attribute95;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute96,
                            l_Line_Price_Att_Rec.pricing_attribute96)
    THEN
        x_pricing_attribute96 := l_x_Line_Price_Att_Rec.pricing_attribute96;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute97,
                            l_Line_Price_Att_Rec.pricing_attribute97)
    THEN
        x_pricing_attribute97 := l_x_Line_Price_Att_Rec.pricing_attribute97;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute98,
                            l_Line_Price_Att_Rec.pricing_attribute98)
    THEN
        x_pricing_attribute98 := l_x_Line_Price_Att_Rec.pricing_attribute98;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute99,
                            l_Line_Price_Att_Rec.pricing_attribute99)
    THEN
        x_pricing_attribute99 := l_x_Line_Price_Att_Rec.pricing_attribute99;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_context,
                            l_Line_Price_Att_Rec.pricing_context)
    THEN
        x_pricing_context := l_x_Line_Price_Att_Rec.pricing_context;
	END IF;

    IF nvl(p_called_from_pattr,'x') <> 'Y' THEN
        l_x_Line_Price_Att_Rec.db_flag:=FND_API.G_TRUE;
    END IF;

	Write_Order_Line_PAttr
	(
	   p_Line_Price_Att_rec   => l_x_Line_Price_Att_Rec
	) ;




    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

 	--  Set return status.

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	    --  Get message count and data

	OE_MSG_PUB.Count_And_Get
	(   p_count                       => x_msg_count
	 ,   p_data                        => x_msg_data
	);


	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_PATTR.CHANGE_ATTRIBUTES' , 1 ) ;
	END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

	  x_return_status := FND_API.G_RET_STS_ERROR;

		--  Get message count and data
	   OE_MSG_PUB.Count_And_Get
	 (   p_count                       => x_msg_count
    		,   p_data                        => x_msg_data
	  );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	    --  Get message count and data

		  OE_MSG_PUB.Count_And_Get
		(   p_count                       => x_msg_count
		   ,   p_data                        => x_msg_data
		 );

	 WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

		   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
	    	OE_MSG_PUB.Add_Exc_Msg
		   (   G_PKG_NAME
		   ,   'Change_Attribute');
	   END IF;

END Change_Attributes;


PROCEDURE Validate_And_Write
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_order_price_attrib_id         IN  NUMBER
, x_creation_date OUT NOCOPY DATE

, x_created_by OUT NOCOPY NUMBER

, x_last_update_date OUT NOCOPY DATE

, x_last_updated_by OUT NOCOPY NUMBER

, x_last_update_login OUT NOCOPY NUMBER

, x_program_id OUT NOCOPY NUMBER

, x_program_application_id OUT NOCOPY NUMBER

, x_program_update_date OUT NOCOPY DATE

, x_request_id OUT NOCOPY NUMBER

, x_lock_control OUT NOCOPY NUMBER

,   p_called_from_pattr             IN  VARCHAR2 DEFAULT 'N'
)
IS
l_Line_Price_Att_Rec		OE_Order_PUB.Line_Price_Att_Rec_Type;
l_old_Line_Price_Att_rec		OE_Order_PUB.Line_Price_Att_Rec_Type;
l_Line_Price_Att_Tbl		OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_old_Line_Price_Att_tbl		OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl          OE_Order_PUB.Request_Tbl_Type;

/* OUT NOCOPY parameters for Process Order */

l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_Header_Price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_Price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_x_old_Line_Price_Att_tbl    OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_x_Line_Price_Att_Rec        OE_Order_PUB.Line_Price_Att_Rec_Type ;
l_x_old_Line_Price_Att_Rec    OE_Order_PUB.Line_Price_Att_Rec_Type ;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.
    l_control_rec.controlled_operation := TRUE;
	l_control_rec.validate_entity      := TRUE;
	l_control_rec.write_to_DB          := TRUE;

	l_control_rec.check_security       := FALSE;
	l_control_rec.clear_dependents     := FALSE;
	l_control_rec.default_attributes   := FALSE;
	l_control_rec.change_attributes    := FALSE;
	l_control_rec.process              := FALSE;
	l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LINE_PRICE_ATT;

	    --  Instruct API to retain its caches
	     l_control_rec.clear_api_cache      := FALSE;
		l_control_rec.clear_api_requests   := FALSE;


		SAVEPOINT validate_and_write;

		Get_Order_Line_PAttr
			( p_db_record					=>  TRUE
			, p_order_price_attrib_id		=>  p_order_price_attrib_id
			, x_Line_Price_Att_rec			=> l_x_old_Line_Price_Att_rec
			) ;

		Get_Order_Line_PAttr
			( p_db_record					=>	FALSE
			, p_order_price_attrib_id		=> p_order_price_attrib_id
			, x_Line_Price_Att_rec			=> l_x_Line_Price_Att_rec
			) ;

    --  Set Operation.
    IF p_called_from_pattr = 'Y' THEN
      -- this is from Promotions window.
      IF FND_API.To_Boolean(l_x_Line_Price_Att_Rec.db_flag) THEN
	 l_x_Line_Price_Att_Rec.operation := OE_GLOBALS.G_OPR_UPDATE;
      ELSE
	 l_x_Line_Price_Att_Rec.operation := OE_GLOBALS.G_OPR_CREATE;
      END IF;
    ELSE
      -- this is from Sales Order Line window.
      l_x_Line_Price_Att_Rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    END IF;


		l_x_Line_Price_Att_Tbl(1) := l_x_Line_Price_Att_Rec	;
		l_x_old_Line_Price_Att_tbl(1) := l_x_old_Line_Price_Att_rec;

    -- Call Oe_Order_Adj_Pvt.Line_Price_Atts
    oe_order_adj_pvt.Line_Price_Atts
    (	p_init_msg_list			=> FND_API.G_TRUE
    ,	p_validation_level 			=> FND_API.G_VALID_LEVEL_NONE
    ,	p_control_rec				=> l_control_rec
    ,	p_x_line_price_att_tbl		=> l_x_Line_price_att_tbl
    ,	p_x_old_line_price_att_tbl	=> l_x_old_Line_price_att_tbl
    );

	   /******************************************************************
	   -- Call Process Pricing
    	   OE_Order_PVT.Process_order
	   	(   p_api_version_number          => 1.0
		,   p_init_msg_list               => FND_API.G_TRUE
		,   x_return_status               => l_return_status
		,   x_msg_count                   => x_msg_count
		,   x_msg_data                    => x_msg_data
		,   p_control_rec                 => l_control_rec
		,   p_Line_price_Att_tbl        => l_Line_Price_Att_Tbl

		,   x_header_rec                  => l_x_header_rec
		,   x_Header_Adj_tbl              => l_x_Header_Adj_tbl
		,   x_Header_price_Att_tbl         => l_x_Header_Price_Att_tbl
		,   x_Header_Adj_Att_tbl           => l_x_Header_Adj_Att_tbl
		,   x_Header_Adj_Assoc_tbl         => l_x_Header_Adj_Assoc_tbl
		,   x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
		,   x_line_tbl                    => l_x_line_tbl
		,   x_Line_Adj_tbl                => l_x_Line_Adj_tbl
		,   x_Line_price_Att_tbl          => l_x_Line_Price_Att_tbl
		,   x_Line_Adj_Att_tbl            => l_x_Line_Adj_Att_tbl
		,   x_Line_Adj_Assoc_tbl          => l_x_Line_Adj_Assoc_tbl
		,   x_Line_Scredit_tbl            => l_x_Line_Scredit_tbl
		,   x_Lot_Serial_tbl              => l_x_Lot_Serial_tbl
		,    x_action_request_tbl           => l_action_request_tbl
	  );
       *********************************************************************/

		l_x_Line_Price_Att_Rec := l_x_Line_Price_Att_tbl(1);


		--- Linda
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'RETURN STATUS IS: '||L_X_LINE_PRICE_ATT_REC.RETURN_STATUS , 1 ) ;
		END IF;

    		IF l_x_Line_Price_Att_Rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_x_Line_Price_Att_Rec.return_status = FND_API.G_RET_STS_ERROR THEN
		    RAISE FND_API.G_EXC_ERROR;
		END IF;

    /*******
    Oe_Order_Pvt.Process_Requests_And_Notify
    (	p_process_requests		=> FALSE
    ,	p_notify				=> TRUE
    ,	p_line_price_att_tbl	=> l_x_line_price_att_tbl
    ,	p_old_line_price_att_tbl	=> l_x_old_line_price_att_tbl
    ,	x_return_status		=> l_return_status
    );
    *****/

    		x_lock_control         := l_x_Line_Price_Att_Rec.lock_control;
    		x_creation_date        := l_x_Line_Price_Att_Rec.creation_date;
		x_created_by           := l_x_Line_Price_Att_Rec.created_by;
		x_last_update_date     := l_x_Line_Price_Att_Rec.last_update_date;
		x_last_updated_by      := l_x_Line_Price_Att_Rec.last_updated_by;
		x_last_update_login    := l_x_Line_Price_Att_Rec.last_update_login;
    		x_program_id           := l_x_Line_Price_Att_rec.program_id;
    		x_program_application_id := l_x_Line_Price_Att_rec.program_application_id;
    		x_program_update_date  := l_x_Line_Price_Att_rec.program_update_date;
    		x_request_id      	   := l_x_Line_Price_Att_rec.request_id;

	/* Clears the Line record cache */
		Clear_Order_Line_Attr;

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

	  --  Get message count and data
		OE_MSG_PUB.Count_And_Get
		(   p_count                       => x_msg_count
	    ,   p_data                        => x_msg_data
	     );


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

	    x_return_status := FND_API.G_RET_STS_ERROR;

		--  Get message count and data

       OE_MSG_PUB.Count_And_Get
       (   p_count                       => x_msg_count
	  ,   p_data                        => x_msg_data
	   );

       ROLLBACK TO SAVEPOINT validate_and_write;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  --  Get message count and data

	   OE_MSG_PUB.Count_And_Get
	   (   p_count                       => x_msg_count
		 ,   p_data                        => x_msg_data
	   );

	  ROLLBACK TO SAVEPOINT validate_and_write;

	WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;
		NULL;

END Validate_And_Write;



PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_order_price_attrib_id         IN  NUMBER
)
IS
l_Line_Price_Att_Rec	OE_Order_PUB.Line_Price_Att_Rec_Type;
l_old_Line_Price_Att_rec	OE_Order_PUB.Line_Price_Att_Rec_Type;
l_Line_Price_Att_Tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_old_Line_Price_Att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl          OE_Order_PUB.Request_Tbl_Type;

/* out nocopy parameters for Process Order */

l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_Header_Price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_Price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_x_old_Line_Price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_x_Line_Price_Att_Rec        OE_Order_PUB.Line_Price_Att_Rec_Type ;
l_x_old_Line_Price_Att_Rec        OE_Order_PUB.Line_Price_Att_Rec_Type ;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_PATTR.DELETE_ROW' , 1 ) ;
	   END IF;
    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;


	--  Set control flags.
		l_control_rec.controlled_operation := TRUE;
		l_control_rec.check_security       := TRUE;
		l_control_rec.validate_entity      := TRUE;
		l_control_rec.write_to_DB          := TRUE;

		l_control_rec.clear_dependents     := FALSE;
		l_control_rec.default_attributes   := FALSE;
                --bug 2702382
		l_control_rec.change_attributes    := TRUE;
		l_control_rec.process              := FALSE;

		l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LINE_PRICE_ATT;

	    --  Instruct API to retain its caches
	     l_control_rec.clear_api_cache      := FALSE;
		l_control_rec.clear_api_requests   := FALSE;


		Get_Order_Line_PAttr
			( p_db_record					=>	FALSE
			, p_order_price_attrib_id		=> p_order_price_attrib_id
			, x_Line_Price_Att_Rec			=> l_x_Line_Price_Att_Rec
			);

	     l_x_Line_Price_Att_Rec.operation := OE_GLOBALS.G_OPR_DELETE;

	     l_x_Line_Price_Att_Tbl(1) := l_x_Line_Price_Att_Rec;


    		-- Call Oe_Order_Adj_Pvt.Line_Price_Atts
    		oe_order_adj_pvt.Line_Price_Atts
    		(	p_init_msg_list			=> FND_API.G_TRUE
    		,	p_validation_level 			=> FND_API.G_VALID_LEVEL_NONE
    		,	p_control_rec				=> l_control_rec
    		,	p_x_line_price_att_tbl		=> l_x_Line_price_att_tbl
    		,	p_x_old_line_price_att_tbl	=> l_x_old_Line_price_att_tbl
    		);

          /*****************************************************************
    	   	OE_Order_PVT.Process_order
	   		(   p_api_version_number          => 1.0
		,   p_init_msg_list               => FND_API.G_TRUE
		,   x_return_status               => l_return_status
		,   x_msg_count                   => x_msg_count
		,   x_msg_data                    => x_msg_data
		,   p_control_rec                 => l_control_rec
		,   p_Line_price_Att_tbl        => l_Line_Price_Att_Tbl

		,   x_header_rec                  => l_x_header_rec
		,   x_Header_Adj_tbl              => l_x_Header_Adj_tbl
		,   x_Header_price_Att_tbl        => l_x_Header_Price_Att_tbl
		,   x_Header_Adj_Att_tbl          => l_x_Header_Adj_Att_tbl
		,   x_Header_Adj_Assoc_tbl        => l_x_Header_Adj_Assoc_tbl
		,   x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
		,   x_line_tbl                    => l_x_line_tbl
		,   x_Line_Adj_tbl                => l_x_Line_Adj_tbl
		,   x_Line_price_Att_tbl          => l_x_Line_Price_Att_tbl
		,   x_Line_Adj_Att_tbl            => l_x_Line_Adj_Att_tbl
		,   x_Line_Adj_Assoc_tbl          => l_x_Line_Adj_Assoc_tbl
		,   x_Line_Scredit_tbl            => l_x_Line_Scredit_tbl
		,   x_Lot_Serial_tbl              => l_x_Lot_Serial_tbl
		,    x_action_request_tbl           => l_action_request_tbl
	  );
	  ********************************************************************/

       l_x_Line_Price_Att_Rec := l_x_Line_Price_Att_tbl(1);

    		IF l_x_Line_Price_Att_Rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_x_Line_Price_Att_Rec.return_status = FND_API.G_RET_STS_ERROR THEN
		    RAISE FND_API.G_EXC_ERROR;
		END IF;


    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    		x_return_status := FND_API.G_RET_STS_SUCCESS;


	   --  Get message count and data
		OE_MSG_PUB.Count_And_Get
		(   p_count                       => x_msg_count
		,   p_data                        => x_msg_data
		);

EXCEPTION

    		WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

		  x_return_status := FND_API.G_RET_STS_ERROR;

			--  Get message count and data
		  OE_MSG_PUB.Count_And_Get
		  (   p_count                       => x_msg_count
		    ,   p_data                        => x_msg_data
		  );

    		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		--  Get message count and data
		  OE_MSG_PUB.Count_And_Get
		  (   p_count                       => x_msg_count
		    ,   p_data                        => x_msg_data
		  );

		WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;
			NULL;

END Delete_Row;

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_order_price_attrib_id         IN  NUMBER
,   p_lock_control                  IN  NUMBER
)
IS
l_return_status               VARCHAR2(1);
l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Price_Att_Rec      OE_Order_PUB.Line_Price_Att_Rec_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  Load Line_Pricing_PAttr record

    l_x_Line_Price_Att_Rec.operation    := OE_GLOBALS.G_OPR_LOCK;
    l_x_Line_Price_Att_Rec.lock_control := p_lock_control;
    l_x_Line_Price_Att_Rec.order_price_attrib_id := p_order_price_attrib_id;


	OE_Line_PAttr_Util.Lock_Row
	(   p_x_Line_Price_Att_rec      => l_x_Line_Price_Att_rec
 	,   x_return_status             => l_return_status
 	);

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_Line_Price_Att_Rec.db_flag := FND_API.G_TRUE;

        Write_Order_Line_PAttr
        (   p_Line_Price_Att_rec      => l_x_Line_Price_Att_Rec
        ,   p_db_record                   => TRUE
        );

    END IF;

    --  Set return status.

    x_return_status := l_return_status;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END Lock_Row;

PROCEDURE Write_Order_Line_PAttr
(	p_Line_Price_Att_rec	IN OE_Order_PUB.Line_Price_Att_Rec_Type
,	p_db_record			IN BOOLEAN := FALSE
)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	g_Line_Price_Att_rec := p_Line_Price_Att_rec;

	IF p_db_record THEN
		g_db_Line_Price_Att_rec	:= p_Line_Price_Att_rec	;
	END IF;

END Write_Order_Line_PAttr ;


PROCEDURE Get_Order_Line_PAttr
(
	p_db_record			IN	BOOLEAN := FALSE
, 	p_order_price_attrib_id	IN 	NUMBER
,	x_Line_Price_Att_Rec	IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_pattr_exists varchar2(1) := 'N'; --Added for bug#2645465
BEGIN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  ' ENTERING GET_ORDER_LINE_PATTR: PRICE_ATTRIBS_ID:'||P_ORDER_PRICE_ATTRIB_ID ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  ' G_LINE_PRICE_ATTR_REC.ORDER_PRICE_ATTRIB_ID:'||G_LINE_PRICE_ATT_REC.ORDER_PRICE_ATTRIB_ID ) ;
        END IF;

        -- Added for bug#2645465
        begin
            select 'Y' into l_pattr_exists from dual
            where exists ( select 'Y' from oe_order_price_attribs
                           where order_price_attrib_id = p_order_price_attrib_id );
        exception
            when others then
                 null;
        end;

        IF l_pattr_exists = 'Y' THEN
            g_Line_Price_Att_Rec.db_flag := FND_API.G_TRUE;
        END IF;

	IF p_order_price_attrib_id <>
			nvl(g_Line_Price_Att_rec.order_price_attrib_id,FND_API.G_MISS_NUM) THEN

		OE_Line_PAttr_Util.Query_Row
		(	p_order_price_attrib_id => p_order_price_attrib_id
		,  	x_Line_Price_Att_rec    => g_Line_Price_Att_rec
		) ;

		g_Line_Price_Att_rec.db_flag := FND_API.G_TRUE;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  ' SETTING DB FLAG TO TRUE' ) ;
                END IF;
	-- 	Load DB Record
		g_db_Line_Price_Att_rec := g_Line_Price_Att_rec;

	END IF;

	IF p_db_record THEN

          x_Line_Price_Att_Rec :=  g_db_Line_Price_Att_rec;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'P_DB_RECORD IS TRUE: X_LINE_PRICE_ATT_REC DB FLAG:'||X_LINE_PRICE_ATT_REC.DB_FLAG ) ;
          END IF;
	ELSE
          x_Line_Price_Att_Rec := g_Line_Price_Att_rec;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'P_DB_RECORD IS FALSE: X_LINE_PRICE_ATT_REC DB FLAG:'||X_LINE_PRICE_ATT_REC.DB_FLAG ) ;
          END IF;
	END IF;


END Get_Order_Line_PAttr;


PROCEDURE Clear_Order_Line_Attr
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   	g_Line_Price_Att_Rec         := OE_Order_PUB.G_MISS_LINE_PRICE_ATT_REC;
	g_db_Line_Price_Att_rec      := OE_Order_PUB.G_MISS_LINE_PRICE_ATT_REC;


END Clear_Order_Line_Attr;


procedure process_price (x_return_status OUT NOCOPY Varchar2)

is
l_return_status 	varchar2(30);
l_start_time number;
l_elapse_time number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

    SAVEPOINT Process_Price;
    OE_GLOBALS.G_UI_FLAG:= TRUE;

     Oe_Order_Pvt.Process_Requests_And_Notify
    (	p_process_requests	=> TRUE
    ,	p_notify			=> TRUE
    ,   p_process_ack           => TRUE
    ,	x_return_status	=> l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
    OE_GLOBALS.G_UI_FLAG:= FALSE;
	exception when FND_API.G_EXC_ERROR or FND_API.G_EXC_UNEXPECTED_ERROR then
               ROLLBACK TO SAVEPOINT Process_Price;
               OE_GLOBALS.G_UI_FLAG:= FALSE;
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'ERROR WHILE PRICING ' ) ;
               END IF;
               x_return_status := l_return_status;


end process_price;


PROCEDURE Change_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,    p_order_price_attrib_id		 IN NUMBER
,    p_attr_id					 IN NUMBER
,	p_context					 IN VARCHAR2
,    p_attr_value				 IN VARCHAR2
,	p_attribute1				 IN VARCHAR2
,	p_attribute2				 IN VARCHAR2
,	p_attribute3				 IN VARCHAR2
,	p_attribute4				 IN VARCHAR2
,	p_attribute5				 IN VARCHAR2
,	p_attribute6				 IN VARCHAR2
,	p_attribute7				 IN VARCHAR2
,	p_attribute8				 IN VARCHAR2
,	p_attribute9				 IN VARCHAR2
,	p_attribute10				 IN VARCHAR2
,	p_attribute11				 IN VARCHAR2
,	p_attribute12				 IN VARCHAR2
,	p_attribute13				 IN VARCHAR2
,	p_attribute14				 IN VARCHAR2
,	p_attribute15				 IN VARCHAR2
,   p_pricing_attribute1            IN VARCHAR2
,   p_pricing_attribute10           IN VARCHAR2
,   p_pricing_attribute11           IN VARCHAR2
,   p_pricing_attribute12           IN VARCHAR2
,   p_pricing_attribute13           IN VARCHAR2
,   p_pricing_attribute14           IN VARCHAR2
,   p_pricing_attribute15           IN VARCHAR2
,   p_pricing_attribute2            IN VARCHAR2
,   p_pricing_attribute3            IN VARCHAR2
,   p_pricing_attribute4            IN VARCHAR2
,   p_pricing_attribute5            IN VARCHAR2
,   p_pricing_attribute6            IN VARCHAR2
,   p_pricing_attribute7            IN VARCHAR2
,   p_pricing_attribute8            IN VARCHAR2
,   p_pricing_attribute9            IN VARCHAR2
,   p_pricing_attribute16           IN VARCHAR2
,   p_pricing_attribute17           IN VARCHAR2
,   p_pricing_attribute18           IN VARCHAR2
,   p_pricing_attribute19           IN VARCHAR2
,   p_pricing_attribute20           IN VARCHAR2
,   p_pricing_attribute21           IN VARCHAR2
,   p_pricing_attribute22           IN VARCHAR2
,   p_pricing_attribute23           IN VARCHAR2
,   p_pricing_attribute24           IN VARCHAR2
,   p_pricing_attribute25           IN VARCHAR2
,   p_pricing_attribute26           IN VARCHAR2
,   p_pricing_attribute27           IN VARCHAR2
,   p_pricing_attribute28           IN VARCHAR2
,   p_pricing_attribute29           IN VARCHAR2
,   p_pricing_attribute30           IN VARCHAR2
,   p_pricing_context               IN VARCHAR2
,   p_flex_title				 IN VARCHAR2
, x_flex_title OUT NOCOPY VARCHAR2

, x_order_price_attrib_id OUT NOCOPY NUMBER

, x_header_id OUT NOCOPY NUMBER

, x_line_id OUT NOCOPY NUMBER

, x_context OUT NOCOPY VARCHAR2

, x_attribute1 OUT NOCOPY VARCHAR2

, x_attribute2 OUT NOCOPY VARCHAR2

, x_attribute3 OUT NOCOPY VARCHAR2

, x_attribute4 OUT NOCOPY VARCHAR2

, x_attribute5 OUT NOCOPY VARCHAR2

, x_attribute6 OUT NOCOPY VARCHAR2

, x_attribute7 OUT NOCOPY VARCHAR2

, x_attribute8 OUT NOCOPY VARCHAR2

, x_attribute9 OUT NOCOPY VARCHAR2

, x_attribute10 OUT NOCOPY VARCHAR2

, x_attribute11 OUT NOCOPY VARCHAR2

, x_attribute12 OUT NOCOPY VARCHAR2

, x_attribute13 OUT NOCOPY VARCHAR2

, x_attribute14 OUT NOCOPY VARCHAR2

, x_attribute15 OUT NOCOPY VARCHAR2

, x_pricing_attribute1 OUT NOCOPY VARCHAR2

, x_pricing_attribute10 OUT NOCOPY VARCHAR2

, x_pricing_attribute11 OUT NOCOPY VARCHAR2

, x_pricing_attribute12 OUT NOCOPY VARCHAR2

, x_pricing_attribute13 OUT NOCOPY VARCHAR2

, x_pricing_attribute14 OUT NOCOPY VARCHAR2

, x_pricing_attribute15 OUT NOCOPY VARCHAR2

, x_pricing_attribute2 OUT NOCOPY VARCHAR2

, x_pricing_attribute3 OUT NOCOPY VARCHAR2

, x_pricing_attribute4 OUT NOCOPY VARCHAR2

, x_pricing_attribute5 OUT NOCOPY VARCHAR2

, x_pricing_attribute6 OUT NOCOPY VARCHAR2

, x_pricing_attribute7 OUT NOCOPY VARCHAR2

, x_pricing_attribute8 OUT NOCOPY VARCHAR2

, x_pricing_attribute9 OUT NOCOPY VARCHAR2

, x_pricing_attribute16 OUT NOCOPY VARCHAR2

, x_pricing_attribute17 OUT NOCOPY VARCHAR2

, x_pricing_attribute18 OUT NOCOPY VARCHAR2

, x_pricing_attribute19 OUT NOCOPY VARCHAR2

, x_pricing_attribute20 OUT NOCOPY VARCHAR2

, x_pricing_attribute21 OUT NOCOPY VARCHAR2

, x_pricing_attribute22 OUT NOCOPY VARCHAR2

, x_pricing_attribute23 OUT NOCOPY VARCHAR2

, x_pricing_attribute24 OUT NOCOPY VARCHAR2

, x_pricing_attribute25 OUT NOCOPY VARCHAR2

, x_pricing_attribute26 OUT NOCOPY VARCHAR2

, x_pricing_attribute27 OUT NOCOPY VARCHAR2

, x_pricing_attribute28 OUT NOCOPY VARCHAR2

, x_pricing_attribute29 OUT NOCOPY VARCHAR2

, x_pricing_attribute30 OUT NOCOPY VARCHAR2

, x_pricing_context OUT NOCOPY VARCHAR2

, x_override_flag OUT NOCOPY VARCHAR2

,   p_called_from_pattr             IN  VARCHAR2 DEFAULT 'N'

) IS

l_Line_Price_Att_Rec	OE_Order_PUB.Line_Price_Att_Rec_Type;
l_old_Line_Price_Att_rec	OE_Order_PUB.Line_Price_Att_Rec_Type;
l_Line_Price_Att_Tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_old_Line_Price_Att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type;

l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl          OE_Order_PUB.Request_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_Header_Price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_Price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_x_old_Line_Price_Att_tbl    OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_x_Line_Price_Att_Rec        OE_Order_PUB.Line_Price_Att_Rec_Type ;
l_x_old_Line_Price_Att_Rec    OE_Order_PUB.Line_Price_Att_Rec_Type ;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_PATTR.CHANGE_ATTRIBUTES' , 1 ) ;
	END IF;
    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.
     l_control_rec.controlled_operation := TRUE;
	l_control_rec.check_security       := TRUE;
	l_control_rec.clear_dependents     := TRUE;
	l_control_rec.default_attributes   := TRUE;
	l_control_rec.change_attributes    := TRUE;

	l_control_rec.validate_entity      := FALSE;

        IF p_called_from_pattr = 'Y' THEN
          -- don't write to db if this is coming from Promotions window.
	  l_control_rec.write_to_DB          := FALSE;
        ELSE
	  l_control_rec.write_to_DB          := TRUE;
        END IF;

	l_control_rec.process          := FALSE;
	l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LINE_PRICE_ATT;


	--  Instruct API to retain its caches
	l_control_rec.clear_api_cache      := FALSE;
	l_control_rec.clear_api_requests   := FALSE;

	SAVEPOINT change_attributes;

	Get_Order_Line_PAttr
	( 	p_db_record  => FALSE
	, p_order_price_attrib_id => p_order_price_attrib_id
	, x_Line_Price_Att_rec    => l_x_Line_Price_Att_Rec
	);

	l_x_old_Line_Price_Att_rec := l_x_Line_Price_Att_Rec;


		   IF p_attr_id = OE_Line_PAttr_Util.G_FLEX_TITLE THEN
			l_x_Line_Price_Att_rec.flex_title := p_attr_value;
	     ELSIF p_attr_id = OE_Line_PAttr_Util.G_HEADER THEN
			l_x_Line_Price_Att_rec.header_id := TO_NUMBER(p_attr_value);

	     ELSIF p_attr_id = OE_Line_PAttr_Util.G_OVERRIDE_FLAG THEN
			l_x_Line_Price_Att_rec.override_flag := p_attr_value;

		ELSIF p_attr_id = OE_Line_PAttr_Util.G_LINE THEN
			l_x_Line_Price_Att_rec.line_id := TO_NUMBER(p_attr_value);
		ELSIF p_attr_id = OE_Line_PAttr_Util.G_ORDER_PRICE_ATTRIB THEN
			l_x_Line_Price_Att_rec.order_price_attrib_id := TO_NUMBER(p_attr_value);

	    ELSIF p_attr_id = OE_Line_PAttr_Util.G_CONTEXT
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE1
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE2
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE3
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE4
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE5
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE6
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE7
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE8
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE9
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE10
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE11
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE12
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE13
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE14
			OR     p_attr_id = OE_Line_PAttr_Util.G_ATTRIBUTE15
			THEN
				l_x_Line_Price_Att_rec.context       := p_context;
				l_x_Line_Price_Att_rec.attribute1    := p_attribute1;
				l_x_Line_Price_Att_rec.attribute2    := p_attribute2;
				l_x_Line_Price_Att_rec.attribute3    := p_attribute3;
				l_x_Line_Price_Att_rec.attribute4    := p_attribute4;
				l_x_Line_Price_Att_rec.attribute5    := p_attribute5;
				l_x_Line_Price_Att_rec.attribute6    := p_attribute6;
				l_x_Line_Price_Att_rec.attribute7    := p_attribute7;
				l_x_Line_Price_Att_rec.attribute8    := p_attribute8;
				l_x_Line_Price_Att_rec.attribute9    := p_attribute9;
				l_x_Line_Price_Att_rec.attribute10   := p_attribute10;
				l_x_Line_Price_Att_rec.attribute11   := p_attribute11;
				l_x_Line_Price_Att_rec.attribute12   := p_attribute12;
				l_x_Line_Price_Att_rec.attribute13   := p_attribute13;
				l_x_Line_Price_Att_rec.attribute14   := p_attribute14;
				l_x_Line_Price_Att_rec.attribute15   := p_attribute15;
	    ELSIF p_attr_id = OE_Line_PAttr_Util.G_PRICING_CONTEXT
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE1
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE2
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE3
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE4
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE5
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE6
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE7
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE8
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE9
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE10
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE11
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE12
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE13
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE14
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE15
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE16
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE17
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE18
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE19
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE20
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE21
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE22
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE23
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE24
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE25
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE26
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE27
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE28
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE29
			OR     p_attr_id = OE_Line_PAttr_Util.G_PRICING_ATTRIBUTE30
			THEN
				l_x_Line_Price_Att_rec.flex_title := 	p_flex_title;
				l_x_Line_Price_Att_rec.pricing_context       := p_pricing_context;
				l_x_Line_Price_Att_rec.pricing_attribute1    := p_pricing_attribute1;
				l_x_Line_Price_Att_rec.pricing_attribute2    := p_pricing_attribute2;
				l_x_Line_Price_Att_rec.pricing_attribute3    := p_pricing_attribute3;
				l_x_Line_Price_Att_rec.pricing_attribute4    := p_pricing_attribute4;
				l_x_Line_Price_Att_rec.pricing_attribute5    := p_pricing_attribute5;
				l_x_Line_Price_Att_rec.pricing_attribute6    := p_pricing_attribute6;
				l_x_Line_Price_Att_rec.pricing_attribute7    := p_pricing_attribute7;
				l_x_Line_Price_Att_rec.pricing_attribute8    := p_pricing_attribute8;
				l_x_Line_Price_Att_rec.pricing_attribute9    := p_pricing_attribute9;
				l_x_Line_Price_Att_rec.pricing_attribute10   := p_pricing_attribute10;
				l_x_Line_Price_Att_rec.pricing_attribute11   := p_pricing_attribute11;
				l_x_Line_Price_Att_rec.pricing_attribute12   := p_pricing_attribute12;
				l_x_Line_Price_Att_rec.pricing_attribute13   := p_pricing_attribute13;
				l_x_Line_Price_Att_rec.pricing_attribute14   := p_pricing_attribute14;
				l_x_Line_Price_Att_rec.pricing_attribute15   := p_pricing_attribute15;
				l_x_Line_Price_Att_rec.pricing_attribute16    := p_pricing_attribute16;
				l_x_Line_Price_Att_rec.pricing_attribute17    := p_pricing_attribute17;
				l_x_Line_Price_Att_rec.pricing_attribute18    := p_pricing_attribute18;
				l_x_Line_Price_Att_rec.pricing_attribute19    := p_pricing_attribute19;
				l_x_Line_Price_Att_rec.pricing_attribute20   := p_pricing_attribute20;
				l_x_Line_Price_Att_rec.pricing_attribute21   := p_pricing_attribute21;
				l_x_Line_Price_Att_rec.pricing_attribute22   := p_pricing_attribute22;
				l_x_Line_Price_Att_rec.pricing_attribute23   := p_pricing_attribute23;
				l_x_Line_Price_Att_rec.pricing_attribute24   := p_pricing_attribute24;
				l_x_Line_Price_Att_rec.pricing_attribute25   := p_pricing_attribute25;
				l_x_Line_Price_Att_rec.pricing_attribute26    := p_pricing_attribute26;
				l_x_Line_Price_Att_rec.pricing_attribute27    := p_pricing_attribute27;
				l_x_Line_Price_Att_rec.pricing_attribute28    := p_pricing_attribute28;
				l_x_Line_Price_Att_rec.pricing_attribute29    := p_pricing_attribute29;

		ELSE

	 --  Unexpected error, unrecognized attribute

		    	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
			OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'Change_Attributes'
			,   'Unrecognized attribute'
			);
			END IF;

																			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
																		END IF;



    --  Set Operation.
	   IF FND_API.To_Boolean(l_x_Line_Price_Att_rec.db_flag) THEN
		   l_x_Line_Price_Att_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
	   ELSE
		   l_x_Line_Price_Att_rec.operation := OE_GLOBALS.G_OPR_CREATE;
	   END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' PATTR OPERATION:'||L_X_LINE_PRICE_ATT_REC.OPERATION ) ;
    END IF;
    --If new pricing context is null and old is not null then we
    --know user is clearing the field hence operation delete
    If l_x_line_price_att_rec.pricing_context is Null and
       l_x_old_Line_Price_Att_rec.pricing_context is Not Null and
       l_x_Line_Price_Att_rec.operation <>  OE_GLOBALS.G_OPR_CREATE
    Then

       l_x_Line_Price_Att_rec.operation := OE_GLOBALS.G_OPR_DELETE;
       clear_order_line_attr;

    End If;

  	--  Populate Order Line pricing Attributes table

	 l_x_Line_Price_Att_Tbl(1) := l_x_Line_Price_Att_rec;
	 l_x_old_Line_Price_Att_tbl(1) := l_x_old_Line_Price_Att_rec;


    -- Call Oe_Order_Adj_Pvt.Line_Price_Atts
    l_Line_Price_Att_rec := l_x_Line_Price_Att_rec;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' NEW PRICING CONTEXT:'||L_X_LINE_PRICE_ATT_TBL ( 1 ) .PRICING_CONTEXT ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' OLD PRICING CONTEXT:'||L_X_OLD_LINE_PRICE_ATT_TBL ( 1 ) .PRICING_CONTEXT ) ;
    END IF;

    IF p_called_from_pattr <> 'Y' THEN
      -- this is coming from Sales Order Line window.
      if l_x_Line_price_att_tbl(1).flex_title is null then
         l_x_Line_price_att_tbl(1).flex_title := 'QP_ATTR_DEFNS_PRICING';
      end if;
    END IF;

    oe_order_adj_pvt.Line_Price_Atts
    (	p_init_msg_list			=> FND_API.G_TRUE
    ,	p_validation_level 			=> FND_API.G_VALID_LEVEL_NONE
    ,	p_control_rec				=> l_control_rec
    ,	p_x_line_price_att_tbl		=> l_x_Line_price_att_tbl
    ,	p_x_old_line_price_att_tbl	=> l_x_old_Line_price_att_tbl
    );

    --Pricing attributes has changed, repricing needed. Log delayed request
    --for repricing
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PATTR:'||L_X_LINE_PRICE_ATT_REC.LINE_ID ) ;
    END IF;
    OE_delayed_requests_Pvt.log_request(p_entity_code 		 => 'LINE',
	          			p_entity_id         	 => l_x_Line_Price_Att_rec.line_id,
			        	p_requesting_entity_code => 'LINE',
				        p_requesting_entity_id   => l_x_Line_Price_Att_rec.line_id,
		 		        p_param1                 => l_x_Line_Price_Att_rec.line_id,
                 	                p_param2                 => 'PRICE',--'BATCH', --Bug 8555923
		 		        p_request_type           => 'PRICE_LINE',
		 		        x_return_status          => l_return_status);

	l_x_Line_Price_Att_Rec := l_x_Line_Price_Att_tbl(1);

    IF l_x_Line_Price_Att_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'PATTR ERROR 1' ) ;
         END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_x_Line_Price_Att_rec.return_status = FND_API.G_RET_STS_ERROR THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'PATTR ERROR 2' ) ;
         END IF;
	 RAISE FND_API.G_EXC_ERROR;
    END IF;

	-- Init Out parameters
    x_attribute1                   := FND_API.G_MISS_CHAR;
    x_attribute10                  := FND_API.G_MISS_CHAR;
    x_attribute11                  := FND_API.G_MISS_CHAR;
    x_attribute12                  := FND_API.G_MISS_CHAR;
    x_attribute13                  := FND_API.G_MISS_CHAR;
    x_attribute14                  := FND_API.G_MISS_CHAR;
    x_attribute15                  := FND_API.G_MISS_CHAR;
    x_attribute2                   := FND_API.G_MISS_CHAR;
    x_attribute3                   := FND_API.G_MISS_CHAR;
    x_attribute4                   := FND_API.G_MISS_CHAR;
    x_attribute5                   := FND_API.G_MISS_CHAR;
    x_attribute6                   := FND_API.G_MISS_CHAR;
    x_attribute7                   := FND_API.G_MISS_CHAR;
    x_attribute8                   := FND_API.G_MISS_CHAR;
    x_attribute9                   := FND_API.G_MISS_CHAR;
    x_context                      := FND_API.G_MISS_CHAR;
    x_flex_title                   := FND_API.G_MISS_CHAR;
    x_header_id                    := FND_API.G_MISS_NUM;
    x_line_id                      := FND_API.G_MISS_NUM;
    x_order_price_attrib_id        := FND_API.G_MISS_NUM;
    x_pricing_attribute1           := FND_API.G_MISS_CHAR;
    x_pricing_attribute10          := FND_API.G_MISS_CHAR;
    x_pricing_attribute11          := FND_API.G_MISS_CHAR;
    x_pricing_attribute12          := FND_API.G_MISS_CHAR;
    x_pricing_attribute13          := FND_API.G_MISS_CHAR;
    x_pricing_attribute14          := FND_API.G_MISS_CHAR;
    x_pricing_attribute15          := FND_API.G_MISS_CHAR;
    x_pricing_attribute16          := FND_API.G_MISS_CHAR;
    x_pricing_attribute17          := FND_API.G_MISS_CHAR;
    x_pricing_attribute18          := FND_API.G_MISS_CHAR;
    x_pricing_attribute19          := FND_API.G_MISS_CHAR;
    x_pricing_attribute2           := FND_API.G_MISS_CHAR;
    x_pricing_attribute20          := FND_API.G_MISS_CHAR;
    x_pricing_attribute21          := FND_API.G_MISS_CHAR;
    x_pricing_attribute22          := FND_API.G_MISS_CHAR;
    x_pricing_attribute23          := FND_API.G_MISS_CHAR;
    x_pricing_attribute24          := FND_API.G_MISS_CHAR;
    x_pricing_attribute25          := FND_API.G_MISS_CHAR;
    x_pricing_attribute26          := FND_API.G_MISS_CHAR;
    x_pricing_attribute27          := FND_API.G_MISS_CHAR;
    x_pricing_attribute28          := FND_API.G_MISS_CHAR;
    x_pricing_attribute29          := FND_API.G_MISS_CHAR;
    x_pricing_attribute3           := FND_API.G_MISS_CHAR;
    x_pricing_attribute30          := FND_API.G_MISS_CHAR;
    x_pricing_attribute4           := FND_API.G_MISS_CHAR;
    x_pricing_attribute5           := FND_API.G_MISS_CHAR;
    x_pricing_attribute6           := FND_API.G_MISS_CHAR;
    x_pricing_attribute7           := FND_API.G_MISS_CHAR;
    x_pricing_attribute8           := FND_API.G_MISS_CHAR;
    x_pricing_attribute9           := FND_API.G_MISS_CHAR;
    x_pricing_context              := FND_API.G_MISS_CHAR;
    x_override_flag              := FND_API.G_MISS_CHAR;

	-- Record structure

         -- No Get Values

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.override_flag,
		   l_Line_Price_Att_Rec.override_flag)
     THEN
		x_override_flag := l_x_Line_Price_Att_Rec.override_flag;
     END IF;


	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute1,
		   l_Line_Price_Att_Rec.attribute1)
     THEN
		x_attribute1 := l_x_Line_Price_Att_Rec.attribute1;
     END IF;


	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute2,
		   l_Line_Price_Att_Rec.attribute2)
     THEN
		x_attribute3 := l_x_Line_Price_Att_Rec.attribute2;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute3,
		   l_Line_Price_Att_Rec.attribute3)
     THEN
		x_attribute3 := l_x_Line_Price_Att_Rec.attribute3;
     END IF;


	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute4,
		   l_Line_Price_Att_Rec.attribute4)
     THEN
		x_attribute4 := l_x_Line_Price_Att_Rec.attribute4;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute5,
		   l_Line_Price_Att_Rec.attribute5)
     THEN
		x_attribute5 := l_x_Line_Price_Att_Rec.attribute5;
     END IF;
	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute6,
		   l_Line_Price_Att_Rec.attribute6)
     THEN
		x_attribute6 := l_x_Line_Price_Att_Rec.attribute6;
     END IF;
	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute7,
		   l_Line_Price_Att_Rec.attribute7)
     THEN
		x_attribute7 := l_x_Line_Price_Att_Rec.attribute7;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute8,
		   l_Line_Price_Att_Rec.attribute8)
     THEN
		x_attribute8 := l_x_Line_Price_Att_Rec.attribute8;
     END IF;



	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute9,
		   l_Line_Price_Att_Rec.attribute9)
     THEN
		x_attribute9 := l_x_Line_Price_Att_Rec.attribute9;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute10,
		   l_Line_Price_Att_Rec.attribute10)
     THEN
		x_attribute10 := l_x_Line_Price_Att_Rec.attribute10;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute11,
		   l_Line_Price_Att_Rec.attribute11)
     THEN
		x_attribute11 := l_x_Line_Price_Att_Rec.attribute11;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute12,
		   l_Line_Price_Att_Rec.attribute12)
     THEN
		x_attribute12 := l_x_Line_Price_Att_Rec.attribute12;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute13,
		   l_Line_Price_Att_Rec.attribute13)
     THEN
		x_attribute13 := l_x_Line_Price_Att_Rec.attribute13;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute14,
		   l_Line_Price_Att_Rec.attribute14)
     THEN
		x_attribute14 := l_x_Line_Price_Att_Rec.attribute14;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.attribute15,
		   l_Line_Price_Att_Rec.attribute15)
     THEN
		x_attribute15 := l_x_Line_Price_Att_Rec.attribute15;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.header_id,
		   l_Line_Price_Att_Rec.header_id)
     THEN
		x_header_id := l_x_Line_Price_Att_Rec.header_id;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.line_id,
		   l_Line_Price_Att_Rec.line_id)
     THEN
		x_line_id := l_x_Line_Price_Att_Rec.line_id;
     END IF;

	IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.flex_title,
		   l_Line_Price_Att_Rec.flex_title)
     THEN
		x_flex_title := l_x_Line_Price_Att_Rec.flex_title;
     END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.order_price_attrib_id,
                            l_Line_Price_Att_Rec.order_price_attrib_id)
    THEN
        x_order_price_attrib_id := l_x_Line_Price_Att_Rec.order_price_attrib_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute1,
                            l_Line_Price_Att_Rec.pricing_attribute1)
    THEN
        x_pricing_attribute1 := l_x_Line_Price_Att_Rec.pricing_attribute1;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute10,
                            l_Line_Price_Att_Rec.pricing_attribute10)
    THEN
        x_pricing_attribute10 := l_x_Line_Price_Att_Rec.pricing_attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute11,
                            l_Line_Price_Att_Rec.pricing_attribute11)
    THEN
        x_pricing_attribute11 := l_x_Line_Price_Att_Rec.pricing_attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute12,
                            l_Line_Price_Att_Rec.pricing_attribute12)
    THEN
        x_pricing_attribute12 := l_x_Line_Price_Att_Rec.pricing_attribute12;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute13,
                            l_Line_Price_Att_Rec.pricing_attribute13)
    THEN
        x_pricing_attribute13 := l_x_Line_Price_Att_Rec.pricing_attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute14,
                            l_Line_Price_Att_Rec.pricing_attribute14)
    THEN
        x_pricing_attribute14 := l_x_Line_Price_Att_Rec.pricing_attribute14;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute15,
                            l_Line_Price_Att_Rec.pricing_attribute15)
    THEN
        x_pricing_attribute15 := l_x_Line_Price_Att_Rec.pricing_attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute16,
                            l_Line_Price_Att_Rec.pricing_attribute16)
    THEN
        x_pricing_attribute16 := l_x_Line_Price_Att_Rec.pricing_attribute16;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute17,
                            l_Line_Price_Att_Rec.pricing_attribute17)
    THEN
        x_pricing_attribute17 := l_x_Line_Price_Att_Rec.pricing_attribute17;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute18,
                            l_Line_Price_Att_Rec.pricing_attribute18)
    THEN
        x_pricing_attribute18 := l_x_Line_Price_Att_Rec.pricing_attribute18;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute19,
                            l_Line_Price_Att_Rec.pricing_attribute19)
    THEN
        x_pricing_attribute19 := l_x_Line_Price_Att_Rec.pricing_attribute19;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute2,
                            l_Line_Price_Att_Rec.pricing_attribute2)
    THEN
        x_pricing_attribute2 := l_x_Line_Price_Att_Rec.pricing_attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute20,
                            l_Line_Price_Att_Rec.pricing_attribute20)
    THEN
        x_pricing_attribute20 := l_x_Line_Price_Att_Rec.pricing_attribute20;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute21,
                            l_Line_Price_Att_Rec.pricing_attribute21)
    THEN
        x_pricing_attribute21 := l_x_Line_Price_Att_Rec.pricing_attribute21;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute22,
                            l_Line_Price_Att_Rec.pricing_attribute22)
    THEN
        x_pricing_attribute22 := l_x_Line_Price_Att_Rec.pricing_attribute22;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute23,
                            l_Line_Price_Att_Rec.pricing_attribute23)
    THEN
        x_pricing_attribute23 := l_x_Line_Price_Att_Rec.pricing_attribute23;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute24,
                            l_Line_Price_Att_Rec.pricing_attribute24)
    THEN
        x_pricing_attribute24 := l_x_Line_Price_Att_Rec.pricing_attribute24;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute25,
                            l_Line_Price_Att_Rec.pricing_attribute25)
    THEN
        x_pricing_attribute25 := l_x_Line_Price_Att_Rec.pricing_attribute25;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute26,
                            l_Line_Price_Att_Rec.pricing_attribute26)
    THEN
        x_pricing_attribute26 := l_x_Line_Price_Att_Rec.pricing_attribute26;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute27,
                            l_Line_Price_Att_Rec.pricing_attribute27)
    THEN
        x_pricing_attribute27 := l_x_Line_Price_Att_Rec.pricing_attribute27;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute28,
                            l_Line_Price_Att_Rec.pricing_attribute28)
    THEN
        x_pricing_attribute28 := l_x_Line_Price_Att_Rec.pricing_attribute28;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute29,
                            l_Line_Price_Att_Rec.pricing_attribute29)
    THEN
        x_pricing_attribute29 := l_x_Line_Price_Att_Rec.pricing_attribute29;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute3,
                            l_Line_Price_Att_Rec.pricing_attribute3)
    THEN
        x_pricing_attribute3 := l_x_Line_Price_Att_Rec.pricing_attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute30,
                            l_Line_Price_Att_Rec.pricing_attribute30)
    THEN
        x_pricing_attribute30 := l_x_Line_Price_Att_Rec.pricing_attribute30;
    END IF;


    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute4,
                            l_Line_Price_Att_Rec.pricing_attribute4)
    THEN
        x_pricing_attribute4 := l_x_Line_Price_Att_Rec.pricing_attribute4;
    END IF;


    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute5,
                            l_Line_Price_Att_Rec.pricing_attribute5)
    THEN
        x_pricing_attribute5 := l_x_Line_Price_Att_Rec.pricing_attribute5;
    END IF;



    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute6,
                            l_Line_Price_Att_Rec.pricing_attribute6)
    THEN
        x_pricing_attribute6 := l_x_Line_Price_Att_Rec.pricing_attribute6;
    END IF;


    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute7,
                            l_Line_Price_Att_Rec.pricing_attribute7)
    THEN
        x_pricing_attribute7 := l_x_Line_Price_Att_Rec.pricing_attribute7;
    END IF;


    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute8,
                            l_Line_Price_Att_Rec.pricing_attribute8)
    THEN
        x_pricing_attribute8 := l_x_Line_Price_Att_Rec.pricing_attribute8;
    END IF;


    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_attribute9,
                            l_Line_Price_Att_Rec.pricing_attribute9)
    THEN
        x_pricing_attribute9 := l_x_Line_Price_Att_Rec.pricing_attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Price_Att_Rec.pricing_context,
                            l_Line_Price_Att_Rec.pricing_context)
    THEN
        x_pricing_context := l_x_Line_Price_Att_Rec.pricing_context;
	END IF;

    IF nvl(p_called_from_pattr,'x') <> 'Y' THEN
        l_x_Line_Price_Att_Rec.db_flag:=FND_API.G_TRUE;
    END IF;

	Write_Order_Line_PAttr
	(
	   p_Line_Price_Att_rec   => l_x_Line_Price_Att_Rec
	) ;


    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

 	--  Set return status.

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	    --  Get message count and data

	OE_MSG_PUB.Count_And_Get
	(   p_count                       => x_msg_count
	 ,   p_data                        => x_msg_data
	);


	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_PATTR.CHANGE_ATTRIBUTES' , 1 ) ;
	END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

	  x_return_status := FND_API.G_RET_STS_ERROR;

		--  Get message count and data
	   OE_MSG_PUB.Count_And_Get
	 (   p_count                       => x_msg_count
    		,   p_data                        => x_msg_data
	  );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	    --  Get message count and data

		  OE_MSG_PUB.Count_And_Get
		(   p_count                       => x_msg_count
		   ,   p_data                        => x_msg_data
		 );

	 WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

		   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
	    	OE_MSG_PUB.Add_Exc_Msg
		   (   G_PKG_NAME
		   ,   'Change_Attribute');
	   END IF;

END Change_Attributes;

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id				 in  NUMBER
,   p_line_id					 in  NUMBER
, x_attribute1 OUT NOCOPY VARCHAR2

, x_attribute10 OUT NOCOPY VARCHAR2

, x_attribute11 OUT NOCOPY VARCHAR2

, x_attribute12 OUT NOCOPY VARCHAR2

, x_attribute13 OUT NOCOPY VARCHAR2

, x_attribute14 OUT NOCOPY VARCHAR2

, x_attribute15 OUT NOCOPY VARCHAR2

, x_attribute2 OUT NOCOPY VARCHAR2

, x_attribute3 OUT NOCOPY VARCHAR2

, x_attribute4 OUT NOCOPY VARCHAR2

, x_attribute5 OUT NOCOPY VARCHAR2

, x_attribute6 OUT NOCOPY VARCHAR2

, x_attribute7 OUT NOCOPY VARCHAR2

, x_attribute8 OUT NOCOPY VARCHAR2

, x_attribute9 OUT NOCOPY VARCHAR2

, x_flex_title OUT NOCOPY VARCHAR2

, x_context OUT NOCOPY VARCHAR2

, x_header_id OUT NOCOPY NUMBER

, x_line_id OUT NOCOPY NUMBER

, x_order_price_attrib_id OUT NOCOPY NUMBER

, x_pricing_attribute1 OUT NOCOPY VARCHAR2

, x_pricing_attribute10 OUT NOCOPY VARCHAR2

, x_pricing_attribute11 OUT NOCOPY VARCHAR2

, x_pricing_attribute12 OUT NOCOPY VARCHAR2

, x_pricing_attribute13 OUT NOCOPY VARCHAR2

, x_pricing_attribute14 OUT NOCOPY VARCHAR2

, x_pricing_attribute15 OUT NOCOPY VARCHAR2

, x_pricing_attribute2 OUT NOCOPY VARCHAR2

, x_pricing_attribute3 OUT NOCOPY VARCHAR2

, x_pricing_attribute4 OUT NOCOPY VARCHAR2

, x_pricing_attribute5 OUT NOCOPY VARCHAR2

, x_pricing_attribute6 OUT NOCOPY VARCHAR2

, x_pricing_attribute7 OUT NOCOPY VARCHAR2

, x_pricing_attribute8 OUT NOCOPY VARCHAR2

, x_pricing_attribute9 OUT NOCOPY VARCHAR2

, x_pricing_attribute16 OUT NOCOPY VARCHAR2

, x_pricing_attribute17 OUT NOCOPY VARCHAR2

, x_pricing_attribute18 OUT NOCOPY VARCHAR2

, x_pricing_attribute19 OUT NOCOPY VARCHAR2

, x_pricing_attribute20 OUT NOCOPY VARCHAR2

, x_pricing_attribute21 OUT NOCOPY VARCHAR2

, x_pricing_attribute22 OUT NOCOPY VARCHAR2

, x_pricing_attribute23 OUT NOCOPY VARCHAR2

, x_pricing_attribute24 OUT NOCOPY VARCHAR2

, x_pricing_attribute25 OUT NOCOPY VARCHAR2

, x_pricing_attribute26 OUT NOCOPY VARCHAR2

, x_pricing_attribute27 OUT NOCOPY VARCHAR2

, x_pricing_attribute28 OUT NOCOPY VARCHAR2

, x_pricing_attribute29 OUT NOCOPY VARCHAR2

, x_pricing_attribute30 OUT NOCOPY VARCHAR2

, x_pricing_context OUT NOCOPY VARCHAR2

, x_override_flag OUT NOCOPY VARCHAR2

, x_creation_date OUT NOCOPY DATE

) IS
l_Line_Price_Att_rec	OE_Order_PUB.Line_Price_Att_Rec_Type;
l_Line_Price_Att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type;

l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl          OE_Order_PUB.Request_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_Header_Price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_Price_Att_Rec    	OE_Order_PUB.Line_Price_Att_Rec_Type;
l_x_Line_Price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_old_Line_Price_Att_tbl    OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_old_Line_Price_Att_Rec    OE_Order_PUB.Line_Price_Att_Rec_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENERING OE_OE_FORM_LINE_PATTR.DEFAULT_ATTRIBUTE.' , 1 ) ;
    END IF;
    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

-- Set Control Flags
	l_control_rec.controlled_operation := TRUE;
	l_control_rec.check_security       := TRUE;
	l_control_rec.default_attributes   := TRUE;
	l_control_rec.change_attributes    := TRUE;

	l_control_rec.clear_dependents     := FALSE;
	l_control_rec.validate_entity      := FALSE;
	l_control_rec.write_to_DB          := FALSE;
	l_control_rec.process              := FALSE;

	--  Instruct API to retain its caches
	l_control_rec.clear_api_cache      := FALSE;
	l_control_rec.clear_api_requests   := FALSE;
-----------------------------------------------
-- Set attributes to NULL
-----------------------------------------------

     l_x_old_line_price_att_rec := OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_REC;
     l_x_line_price_att_rec := OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_REC;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' BEFORE SETTING THINGS TO NULL: OE_ORDER_ADJ_PVT.LINE_PRICE_ATTS' ) ;
     END IF;
	l_x_Line_Price_Att_Rec.header_id := p_header_id;
	l_x_Line_Price_Att_Rec.Line_id := p_Line_id;
	l_x_Line_Price_Att_Rec.context := NULL;
	l_x_Line_Price_Att_Rec.attribute1 := NULL;
	l_x_Line_Price_Att_Rec.attribute2 := NULL;
	l_x_Line_Price_Att_Rec.attribute3 := NULL;
	l_x_Line_Price_Att_Rec.attribute4 := NULL;
	l_x_Line_Price_Att_Rec.attribute5 := NULL;
	l_x_Line_Price_Att_Rec.attribute6 := NULL;
	l_x_Line_Price_Att_Rec.attribute7 := NULL;
	l_x_Line_Price_Att_Rec.attribute8 := NULL;
	l_x_Line_Price_Att_Rec.attribute9 := NULL;
	l_x_Line_Price_Att_Rec.attribute10 := NULL;
	l_x_Line_Price_Att_Rec.attribute11 := NULL;
	l_x_Line_Price_Att_Rec.attribute12 := NULL;
	l_x_Line_Price_Att_Rec.attribute13 := NULL;
	l_x_Line_Price_Att_Rec.attribute14 := NULL;
	l_x_Line_Price_Att_Rec.attribute15 := NULL;
	l_x_Line_Price_Att_Rec.pricing_context := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute1 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute2 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute3 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute4 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute5 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute6 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute7 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute8 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute9 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute10 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute11 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute12 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute13 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute14 := NULL;
	l_x_Line_Price_Att_Rec.Pricing_Attribute15 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute16 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute17 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute18 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute19 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute20 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute21 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute22 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute23 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute24 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute25 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute26 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute27 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute28 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute29 := NULL;
	l_x_Line_Price_Att_Rec.pricing_attribute30 := NULL;
	l_x_Line_Price_Att_Rec.override_flag := NULL;


-- Set Operation to Create
	l_x_Line_Price_Att_Rec.operation := OE_GLOBALS.G_OPR_CREATE;

     l_x_Line_Price_Att_Tbl(1) := l_x_Line_Price_Att_Rec;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE CALLING OE_ORDER_ADJ_PVT.LINE_PRICE_ATTS' ) ;
    END IF;
    -- Call Oe_Order_Adj_Pvt.Line_Price_Atts
    oe_order_adj_pvt.Line_Price_Atts
    (	p_init_msg_list			=> FND_API.G_TRUE
    ,	p_validation_level 			=> FND_API.G_VALID_LEVEL_NONE
    ,	p_control_rec				=> l_control_rec
    ,	p_x_line_price_att_tbl		=> l_x_Line_price_att_tbl
    ,	p_x_old_line_price_att_tbl	=> l_x_old_Line_price_att_tbl
    );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER CALLING OE_ORDER_ADJ_PVT.LINE_PRICE_ATTS' ) ;
      END IF;
     l_x_Line_Price_Att_Rec := l_x_Line_Price_Att_tbl(1);

     IF l_x_Line_Price_Att_Rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_x_Line_Price_Att_Rec.return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
	END IF;


-- Load out parameters

    x_attribute1                := l_x_Line_Price_Att_Rec.attribute1;
    x_attribute10               := l_x_Line_Price_Att_Rec.attribute10;
    x_attribute11               := l_x_Line_Price_Att_Rec.attribute11;
    x_attribute12               := l_x_Line_Price_Att_Rec.attribute12;
    x_attribute13               := l_x_Line_Price_Att_Rec.attribute13;
    x_attribute14               := l_x_Line_Price_Att_Rec.attribute14;
    x_attribute15               := l_x_Line_Price_Att_Rec.attribute15;
    x_attribute2                := l_x_Line_Price_Att_Rec.attribute2;
    x_attribute3                := l_x_Line_Price_Att_Rec.attribute3;
    x_attribute4                := l_x_Line_Price_Att_Rec.attribute4;
    x_attribute5                := l_x_Line_Price_Att_Rec.attribute5;
    x_attribute6                := l_x_Line_Price_Att_Rec.attribute6;
    x_attribute7                := l_x_Line_Price_Att_Rec.attribute7;
    x_attribute8                := l_x_Line_Price_Att_Rec.attribute8;
    x_attribute9                := l_x_Line_Price_Att_Rec.attribute9;
    x_context                   := l_x_Line_Price_Att_Rec.context;
    x_flex_title                := l_x_Line_Price_Att_Rec.flex_title;
    x_header_id                 := l_x_Line_Price_Att_Rec.header_id;
    x_line_id                   := l_x_Line_Price_Att_Rec.line_id;
    x_order_price_attrib_id     := l_x_Line_Price_Att_Rec.order_price_attrib_id;
    x_pricing_attribute1        := l_x_Line_Price_Att_Rec.pricing_attribute1;
    x_pricing_attribute10       := l_x_Line_Price_Att_Rec.pricing_attribute10;
    x_pricing_attribute11       := l_x_Line_Price_Att_Rec.pricing_attribute11;
    x_pricing_attribute12       := l_x_Line_Price_Att_Rec.pricing_attribute12;
    x_pricing_attribute13       := l_x_Line_Price_Att_Rec.pricing_attribute13;
    x_pricing_attribute14       := l_x_Line_Price_Att_Rec.pricing_attribute14;
    x_pricing_attribute15       := l_x_Line_Price_Att_Rec.pricing_attribute15;
    x_pricing_attribute16       := l_x_Line_Price_Att_Rec.pricing_attribute16;
    x_pricing_attribute17       := l_x_Line_Price_Att_Rec.pricing_attribute17;
    x_pricing_attribute18       := l_x_Line_Price_Att_Rec.pricing_attribute18;
    x_pricing_attribute19       := l_x_Line_Price_Att_Rec.pricing_attribute19;
    x_pricing_attribute2        := l_x_Line_Price_Att_Rec.pricing_attribute2;
    x_pricing_attribute20       := l_x_Line_Price_Att_Rec.pricing_attribute20;
    x_pricing_attribute21       := l_x_Line_Price_Att_Rec.pricing_attribute21;
    x_pricing_attribute22       := l_x_Line_Price_Att_Rec.pricing_attribute22;
    x_pricing_attribute23       := l_x_Line_Price_Att_Rec.pricing_attribute23;
    x_pricing_attribute24       := l_x_Line_Price_Att_Rec.pricing_attribute24;
    x_pricing_attribute25       := l_x_Line_Price_Att_Rec.pricing_attribute25;
    x_pricing_attribute26       := l_x_Line_Price_Att_Rec.pricing_attribute26;
    x_pricing_attribute27       := l_x_Line_Price_Att_Rec.pricing_attribute27;
    x_pricing_attribute28       := l_x_Line_Price_Att_Rec.pricing_attribute28;
    x_pricing_attribute29       := l_x_Line_Price_Att_Rec.pricing_attribute29;
    x_pricing_attribute3        := l_x_Line_Price_Att_Rec.pricing_attribute3;
    x_pricing_attribute30       := l_x_Line_Price_Att_Rec.pricing_attribute30;
    x_pricing_attribute4        := l_x_Line_Price_Att_Rec.pricing_attribute4;
    x_pricing_attribute5        := l_x_Line_Price_Att_Rec.pricing_attribute5;
    x_pricing_attribute6        := l_x_Line_Price_Att_Rec.pricing_attribute6;
    x_pricing_attribute7        := l_x_Line_Price_Att_Rec.pricing_attribute7;
    x_pricing_attribute8        := l_x_Line_Price_Att_Rec.pricing_attribute8;
    x_pricing_attribute9        := l_x_Line_Price_Att_Rec.pricing_attribute9;
    x_pricing_context           := l_x_Line_Price_Att_Rec.pricing_context;
    x_override_flag           := l_x_Line_Price_Att_Rec.override_flag;


	l_x_Line_Price_Att_Rec.db_flag := FND_API.G_FALSE;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'WRITING PATTRIBUTE TO CACHE' ) ;
           END IF;
	Write_Order_Line_PAttr (
			p_Line_Price_Att_rec => l_x_Line_Price_Att_Rec
		);

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

 --  Set return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	  --  Get message count and data
	 OE_MSG_PUB.Count_And_Get
	 (   	p_count                       => x_msg_count
	    ,    p_data                        => x_msg_data
	  );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING DEFAULT ATTRIBUTE' ) ;
  END IF;
EXCEPTION
 	WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;
		 x_return_status := FND_API.G_RET_STS_ERROR;

	    --  Get message count and data

			  OE_MSG_PUB.Count_And_Get
			(   p_count                       => x_msg_count
			   ,   p_data                        => x_msg_data
			 );

 	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		 --  Get message count and data

		    OE_MSG_PUB.Count_And_Get
		  (   p_count                       => x_msg_count
		,   p_data                        => x_msg_data
		   );

	 WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	 	   OE_MSG_PUB.Add_Exc_Msg
		    (   G_PKG_NAME
			 ,   'Default_Attributes'
		   );
	  END IF;



       --  Get message count and data

	OE_MSG_PUB.Count_And_Get
	(   p_count                       => x_msg_count
	,   	p_data                        => x_msg_data
	);

END Default_Attributes;



END OE_OE_Form_Line_PAttr;

/
