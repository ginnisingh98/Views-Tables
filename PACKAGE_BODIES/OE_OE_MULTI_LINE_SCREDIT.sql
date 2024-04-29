--------------------------------------------------------
--  DDL for Package Body OE_OE_MULTI_LINE_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_MULTI_LINE_SCREDIT" AS
/* $Header: OEXMLSCB.pls 120.1.12000000.2 2007/07/27 08:25:08 cpati ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_OE_Multi_Line_Scredit';

--  Global variables holding cached record.

g_Line_Multi_Scredit_Tbl      Line_Multi_SCREDIT_Tbl_Type;
g_Line_Multi_Scredit_Count    Number := 0;
g_Multi_MSG_Tbl               OE_DEBUG_PUB.Debug_Tbl_Type;
G_Multi_Msg_count             Number := 0;
G_MULTI_MSG_Index             Number := 0;

--  Forward declaration of procedures maintaining entity record cache.

Function Get_Multi_Errors
   (p_start_with_first Varchar2 default FND_API.G_TRUE
   ) Return Varchar2 IS
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
Begin
   if p_start_with_first = FND_API.G_TRUE
      then G_MULTI_MSG_INDEX := 1;
   else
          G_MULTI_MSG_INDEX := G_Multi_MSG_Index + 1;
   end if;
   if G_MULTI_MSG_INDEX > G_MULTI_MSG_COUNT then
      Return NULL;
   else
      Return(G_MULTI_MSG_TBL(g_multi_msg_index));
   end if;
End Get_Multi_Errors;

Procedure add_multi_errors(p_msg Varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  if p_msg is not null then
     g_multi_msg_count := g_multi_msg_count + 1;
     g_multi_msg_tbl(g_multi_msg_count) := p_msg;
  end if;
END add_multi_errors;

Procedure Copy_Errors_Multi_Msg( p_Line_id in number,
                                 p_msg_count in Number) IS
Cursor C_Line_info( p_Line_id number) IS
       select 'Following Errors Have occured for Line, (Line,Shipment) '
             || to_char(line_number) || ',' || to_char(shipment_number)
       from OE_ORDER_LineS
       where Line_id = p_Line_id;
l_line_info varchar2(500);
I number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
   -- open c_line_info(p_Line_id);
   -- fetch c_line_info
     -- into l_line_info;
   -- close c_line_info;
   -- add_multi_errors(l_line_info);

 -- for I in 1..p_msg_count loop
     -- add_multi_errors(oe_msg_pub.get(I,FND_API.G_FALSE));
 -- end loop;
/*for I in 1..p_msg_count loop
     oe_msg_pub.add_with_context(
         oe_msg_pub.get(I,FND_API.G_FALSE),
OE_GLOBALS.g_entity_line,to_char(p_line_id));
 end loop;
*/
null;


End Copy_errors_multi_msg;

/* Replace credit type : R  - Revenue
                         NR - Non Revenue
                         B  - Both Revenue and Non-Revenue
*/
PROCEDURE Replace_Line_Scredit
( p_Line_ID              IN  Number
  ,p_replace_credit_type IN  Varchar2
,p_Return_Status OUT NOCOPY Varchar2

,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY Varchar2

)
IS
l_Line_Scredit_rec            OE_Order_PUB.Line_Scredit_Rec_Type;
l_old_Line_Scredit_rec        OE_Order_PUB.Line_Scredit_Rec_Type;
l_Line_Scredit_tbl            OE_Order_PUB.Line_Scredit_Tbl_Type;
l_old_Line_Scredit_tbl        OE_Order_PUB.Line_Scredit_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               Varchar2(30);
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
l_x_action_request_tbl        OE_Order_PUB.request_tbl_type;
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;


Cursor C_OLD_R_SALES_CREDIT_ID(P_Line_ID Number) IS
       SELECT Sales_Credit_ID
       FROM OE_SALES_CREDITS SC,
	  OE_SALES_CREDIT_TYPES SCT
       WHERE Line_ID = P_Line_ID
	  AND SC.SALES_CREDIT_TYPE_id = SCT.SALES_CREDIT_TYPE_id
       AND   sct.QUOTA_FLAG  = 'Y';
Cursor C_OLD_NR_SALES_CREDIT_ID(P_Line_ID Number) IS
       SELECT Sales_Credit_ID
       FROM OE_SALES_CREDITS SC,
	  OE_SALES_CREDIT_TYPES SCT
       WHERE Line_ID = P_Line_ID
	  AND SC.SALES_CREDIT_TYPE_id = SCT.SALES_CREDIT_TYPE_id
       AND   SCT.QUOTA_FLAG  = 'N';
Cursor C_OLD_SALES_CREDIT_ID(P_Line_ID Number) IS
       SELECT Sales_Credit_ID
       FROM OE_SALES_CREDITS
       WHERE Line_ID = P_Line_ID;
I Number;
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   l_x_Line_Scredit_tbl.delete;
   l_Old_Line_Scredit_tbl.delete;

    --  Set control flags for Delete

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    -- Delete Existing Sales Credits for the Line
    I := 1;
    IF P_REPLACE_CREDIT_TYPE = 'R' then -- Replace Revenue
       FOR R_OLD_SALES_CREDIT IN C_OLD_R_SALES_CREDIT_ID(p_Line_id) LOOP
           --  Read DB record from cache

               OE_Line_Scredit_Util.Lock_Row
               (   p_sales_credit_id  => R_OLD_SALES_CREDIT.SALES_CREDIT_ID
			,   p_x_line_scredit_rec => l_Line_Scredit_rec
			,   x_return_status    =>   l_return_status
               );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
      END IF;
               --  Set Operation.

               l_Line_Scredit_rec.operation := OE_GLOBALS.G_OPR_LOCK;
               --  Populate Line_Scredit table

               l_x_Line_Scredit_tbl(I) := l_Line_Scredit_rec;
               I  := I +1;
      END LOOP;
    ELSIF P_REPLACE_CREDIT_TYPE = 'NR' then -- Replace NON Revenue
       FOR R_OLD_SALES_CREDIT IN C_OLD_NR_SALES_CREDIT_ID(p_Line_id) LOOP
           --  Read DB record from cache

               OE_Line_Scredit_Util.Lock_Row
               (   p_sales_credit_id  => R_OLD_SALES_CREDIT.SALES_CREDIT_ID
			,   p_x_line_scredit_rec => l_Line_Scredit_rec
			,   x_return_status    =>   l_return_status
               );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
      END IF;
               --  Set Operation.

               l_Line_Scredit_rec.operation := OE_GLOBALS.G_OPR_LOCK;
               --  Populate Line_Scredit table

               l_x_Line_Scredit_tbl(I) := l_Line_Scredit_rec;
               I  := I +1;
      END LOOP;
    ELSE -- Replace both Revenue and Non-Revenue
       FOR R_OLD_SALES_CREDIT IN C_OLD_SALES_CREDIT_ID(p_Line_id) LOOP
           --  Read DB record from cache

                OE_Line_Scredit_Util.Lock_Row
               (   p_sales_credit_id  => R_OLD_SALES_CREDIT.SALES_CREDIT_ID
			,   p_x_line_scredit_rec => l_Line_Scredit_rec
			,   x_return_status    =>   l_return_status
               );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
      END IF;
               --  Set Operation.

               l_Line_Scredit_rec.operation := OE_GLOBALS.G_OPR_LOCK;
               --  Populate Line_Scredit table

               l_x_Line_Scredit_tbl(I) := l_Line_Scredit_rec;
               I  := I +1;
      END LOOP;
   END IF;
   -- Set the operation code to Delete from LOCK
   FOR J in 1..(I-1) LOOP
       l_x_Line_Scredit_tbl(j).operation := OE_GLOBALS.G_OPR_DELETE;
   END LOOP;
   --  Call OE_Order_PVT.Process_order
   OE_Order_PVT.Process_order
      (   p_api_version_number          => 1.0
      ,   p_init_msg_list               => FND_API.G_TRUE
      ,   x_return_status               => l_return_status
      ,   x_msg_count                   => p_msg_count
      ,   x_msg_data                    => p_msg_data
      ,   p_control_rec                 => l_control_rec
      ,   p_x_header_rec                => l_x_header_rec
      ,   p_x_Header_Adj_tbl            => l_x_Header_Adj_tbl
      ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
--serla begin
      ,   p_x_Header_Payment_tbl        => l_x_Header_Payment_tbl
--serla end
      ,   p_x_line_tbl                  => l_x_line_tbl
      ,   p_x_Line_Adj_tbl              => l_x_Line_Adj_tbl
      ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
--serla begin
      ,   p_x_Line_Payment_tbl          => l_x_Line_Payment_tbl
--serla end
      ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_tbl
      ,   p_x_action_request_tbl        => l_x_action_request_tbl
      ,   p_x_Header_price_Att_tbl      => l_x_Header_price_Att_tbl
      ,   p_x_Header_Adj_Att_tbl        => l_x_Header_Adj_Att_tbl
      ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
      ,   p_x_Line_price_Att_tbl        => l_x_Line_price_Att_tbl
      ,   p_x_Line_Adj_Att_tbl          => l_x_Line_Adj_Att_tbl
      ,   p_x_Line_Adj_Assoc_tbl        => l_x_Line_Adj_Assoc_tbl

      );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
      END IF;

             --  Set return status.

    p_return_status := FND_API.G_RET_STS_SUCCESS;

   l_x_Line_Scredit_tbl.delete;
   l_Old_Line_Scredit_tbl.delete;
    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;


    --  Populate Line_Scredit table for Inserts
  For I in 1 .. g_Line_Multi_Scredit_Count Loop
    l_Line_Scredit_rec           := OE_Order_PUB.G_MISS_Line_SCREDIT_REC;
    l_Line_Scredit_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    l_Line_Scredit_rec.Line_id := p_Line_id;
    l_Line_Scredit_rec.SalesRep_Id
           := g_Line_Multi_Scredit_Tbl(I).SalesRep_Id;
    l_Line_Scredit_rec.sales_Credit_type_id
           := g_Line_Multi_Scredit_Tbl(I).sales_Credit_type_id;
    l_Line_Scredit_rec.percent
           := g_Line_Multi_Scredit_Tbl(I).percent;
    -- changes start for bug 3742335
    l_Line_Scredit_rec.Context		:=	g_Line_Multi_Scredit_Tbl(I).Context ;
    l_Line_Scredit_rec.Attribute1	:=	g_Line_Multi_Scredit_Tbl(I).Attribute1 ;
    l_Line_Scredit_rec.Attribute2	:=	g_Line_Multi_Scredit_Tbl(I).Attribute2 ;
    l_Line_Scredit_rec.Attribute3	:=	g_Line_Multi_Scredit_Tbl(I).Attribute3 ;
    l_Line_Scredit_rec.Attribute4	:=	g_Line_Multi_Scredit_Tbl(I).Attribute4 ;
    l_Line_Scredit_rec.Attribute5	:=	g_Line_Multi_Scredit_Tbl(I).Attribute5 ;
    l_Line_Scredit_rec.Attribute6	:=	g_Line_Multi_Scredit_Tbl(I).Attribute6 ;
    l_Line_Scredit_rec.Attribute7	:=	g_Line_Multi_Scredit_Tbl(I).Attribute7 ;
    l_Line_Scredit_rec.Attribute8	:=	g_Line_Multi_Scredit_Tbl(I).Attribute8 ;
    l_Line_Scredit_rec.Attribute9	:=	g_Line_Multi_Scredit_Tbl(I).Attribute9 ;
    l_Line_Scredit_rec.Attribute10	:=	g_Line_Multi_Scredit_Tbl(I).Attribute10;
    l_Line_Scredit_rec.Attribute11	:=	g_Line_Multi_Scredit_Tbl(I).Attribute11;
    l_Line_Scredit_rec.Attribute12	:=	g_Line_Multi_Scredit_Tbl(I).Attribute12;
    l_Line_Scredit_rec.Attribute13	:=	g_Line_Multi_Scredit_Tbl(I).Attribute13;
    l_Line_Scredit_rec.Attribute14	:=	g_Line_Multi_Scredit_Tbl(I).Attribute14;
    l_Line_Scredit_rec.Attribute15	:=	g_Line_Multi_Scredit_Tbl(I).Attribute15;
    -- changes end for bug 3742335
    l_Line_Scredit_rec.Sales_Group_Id := g_Line_Multi_Scredit_Tbl(I).Sales_Group_Id;  --5692017
    l_Line_Scredit_rec.Sales_Group_updated_flag := g_Line_Multi_Scredit_Tbl(I).Sales_Group_updated_flag;  --5692017
    l_x_Line_Scredit_tbl(I)     := l_Line_Scredit_rec;
    l_old_Line_Scredit_tbl(I) := OE_Order_PUB.G_MISS_Line_SCREDIT_REC;
 END loop;

    --  Call OE_Order_PVT.Process_order
     OE_DELAYED_REQUESTS_PVT.Clear_Request(x_return_status => l_return_status);

oe_debug_pub.add('Sales_Group_Id:'||l_Line_Scredit_rec.Sales_Group_Id);  --5692017
oe_debug_pub.add('Sales_Group_updated_flag:'||l_Line_Scredit_rec.Sales_Group_updated_flag);  --5692017

    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_FALSE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => p_msg_count
    ,   x_msg_data                    => p_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => l_x_header_rec
    ,   p_x_Header_Adj_tbl            => l_x_Header_Adj_tbl
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
--serla begin
    ,   p_x_Header_Payment_tbl        => l_x_Header_Payment_tbl
--serla end
    ,   p_x_line_tbl                  => l_x_line_tbl
    ,   p_x_Line_Adj_tbl              => l_x_Line_Adj_tbl
    ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
--serla begin
    ,   p_x_Line_Payment_tbl          => l_x_Line_Payment_tbl
--serla end
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_tbl
    ,   p_x_action_request_tbl        => l_x_action_request_tbl
    ,   p_x_Header_price_Att_tbl      => l_x_Header_price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl        => l_x_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Line_price_Att_tbl        => l_x_Line_price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl          => l_x_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl        => l_x_Line_Adj_Assoc_tbl

    );

oe_debug_pub.add('after process order: sales_group_id:'||l_x_Line_Scredit_tbl(1).sales_group_id);  --5692017
oe_debug_pub.add('after process order: sales_group_flag'||l_x_Line_Scredit_tbl(1).sales_group_updated_flag);  --5692017


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    OE_OE_Form_Line_Scredit.Process_entity
                               (x_return_status =>l_return_status
                               ,x_msg_count => p_msg_count
                               ,x_msg_data => p_msg_data
                               );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Replace_Line_Scredit'
            );
        END IF;

END Replace_Line_Scredit;

Procedure Add_Multi_Line_Scredit_Req
  (p_init              IN Varchar2 Default FND_API.G_FALSE
  ,p_salesrep_id       IN Number
  ,p_sales_Credit_type_id IN Number
  ,p_percent           IN Number
  -- changes start for bug 3742335
  ,p_Context	  Varchar2
  ,p_Attribute1	  Varchar2
  ,p_Attribute2	  Varchar2
  ,p_Attribute3   Varchar2
  ,p_Attribute4   Varchar2
  ,p_Attribute5   Varchar2
  ,p_Attribute6   Varchar2
  ,p_Attribute7   Varchar2
  ,p_Attribute8   Varchar2
  ,p_Attribute9   Varchar2
  ,p_Attribute10  Varchar2
  ,p_Attribute11  Varchar2
  ,p_Attribute12  Varchar2
  ,p_Attribute13  Varchar2
  ,p_Attribute14  Varchar2
  ,p_Attribute15  Varchar2
  -- changes end for bug 3742335
  ,p_sales_group_id       IN Number  --5692017
  ,p_sales_group_updated_flag  IN Varchar2  --5692017
,p_return_status OUT NOCOPY Varchar2

,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY Varchar2

  ) IS
I number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    if p_init = FND_API.G_TRUE then
        --  Initialize message list.
       oe_msg_pub.initialize;
       g_Line_Multi_Scredit_Count := 0;
       g_Line_Multi_Scredit_Tbl.delete;
    end if;
    g_Line_Multi_Scredit_Count := g_Line_Multi_Scredit_Count +1;
    I := g_Line_Multi_Scredit_Count;
    g_Line_Multi_Scredit_Tbl(I).salesrep_id := p_salesrep_id;
    g_Line_Multi_Scredit_Tbl(I).sales_Credit_type_id := p_sales_Credit_type_id;
    g_Line_Multi_Scredit_Tbl(I).percent := p_percent;
    -- changes start for bug 3742335
    g_Line_Multi_Scredit_Tbl(I).Context	    :=	p_Context   ;
    g_Line_Multi_Scredit_Tbl(I).Attribute1  :=	p_Attribute1;
    g_Line_Multi_Scredit_Tbl(I).Attribute2  :=	p_Attribute2;
    g_Line_Multi_Scredit_Tbl(I).Attribute3  :=	p_Attribute3;
    g_Line_Multi_Scredit_Tbl(I).Attribute4  :=	p_Attribute4;
    g_Line_Multi_Scredit_Tbl(I).Attribute5  :=	p_Attribute5;
    g_Line_Multi_Scredit_Tbl(I).Attribute6  :=	p_Attribute6;
    g_Line_Multi_Scredit_Tbl(I).Attribute7  :=	p_Attribute7;
    g_Line_Multi_Scredit_Tbl(I).Attribute8  :=	p_Attribute8;
    g_Line_Multi_Scredit_Tbl(I).Attribute9  :=	p_Attribute9;
    g_Line_Multi_Scredit_Tbl(I).Attribute10 :=	p_Attribute10;
    g_Line_Multi_Scredit_Tbl(I).Attribute11 :=	p_Attribute11;
    g_Line_Multi_Scredit_Tbl(I).Attribute12 :=	p_Attribute12;
    g_Line_Multi_Scredit_Tbl(I).Attribute13 :=	p_Attribute13;
    g_Line_Multi_Scredit_Tbl(I).Attribute14 :=	p_Attribute14;
    g_Line_Multi_Scredit_Tbl(I).Attribute15 :=	p_Attribute15;
    -- changes end for bug 3742335
    g_Line_Multi_Scredit_Tbl(I).sales_group_id := p_sales_group_id;  --5692017
    g_Line_Multi_Scredit_Tbl(I).sales_group_updated_flag := p_sales_group_updated_flag;  --5692017

  oe_msg_pub.Count_And_Get
    (   p_count                       => p_msg_count
    ,   p_data                        => p_msg_data
    );
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => p_msg_count
        ,   p_data                        => p_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => p_msg_count
        ,   p_data                        => p_msg_data
        );

    WHEN OTHERS THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Add_Multi_Line_Scredit_Req'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => p_msg_count
        ,   p_data                        => p_msg_data
        );

END Add_Multi_Line_Scredit_Req;

Procedure Replace_Multi_Line_Scredit
   (
    p_cont_on_error            IN  Varchar2 Default FND_API.G_TRUE
    ,p_Line_id_list          IN  Oe_Globals.Selected_Record_Tbl  --MOAC PI
    ,p_replace_credit_type     IN  Varchar2
,p_Return_Status OUT NOCOPY Varchar2

,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY Varchar2

   ) IS
l_x_Line_id                  number;
l_x_Line_id_str              Varchar2(80);
--l_x_Line_id_list             Varchar2(2000) := p_Line_id_list;
l_return_status                Varchar2(30);
l_msg_count                    Number;
--MOAC PI
L_x_org_id                   Number;
l_prev_org_id                Number;
i                            Number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  g_Multi_MSG_Tbl.Delete;
  g_Multi_MSG_count := 0;
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  OE_MSG_PUB.initialize;
  --MOAC PI
  i := p_Line_id_list.first;
  while i is not null loop
     SAVEPOINT Line_Salescredit;
     l_x_Line_id := p_Line_id_list(i).id1;
     l_x_org_id := p_Line_id_list(i).org_id;
     IF l_prev_org_id is null or l_prev_org_id <> l_x_org_id Then
        MO_GLOBAL.set_policy_context(p_access_mode => 'S',  p_org_id  =>  l_x_Org_Id);
        L_prev_org_id := l_x_org_id;
     End If;
   --MOAC PI

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROCESSING SALES CREDIT FOR LINE ID ' || TO_CHAR ( L_X_LINE_ID ) ) ;
     END IF;
     Replace_Line_Scredit(l_x_Line_id
                           ,p_replace_credit_type
                           ,l_return_status
                           ,l_msg_count
                           ,p_msg_data);
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       Copy_Errors_Multi_Msg(l_x_Line_id,
                             l_msg_count);
       p_return_status := l_return_status;
       rollback to Line_Salescredit;
       if p_cont_on_error = FND_API.G_TRUE then
          null;
       else
          EXIT;
       end if;
    end if;
    i := p_Line_id_list.next(i); --MOAC PI
  END LOOP;
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
     RAISE FND_API.G_EXC_ERROR;
  END IF;
        oe_msg_pub.Count_And_Get
        (   p_count                       => p_msg_count
        ,   p_data                        => p_msg_data
        );
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => p_msg_count
        ,   p_data                        => p_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => p_msg_count
        ,   p_data                        => p_msg_data
        );

    WHEN OTHERS THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Replace_Multi_Line_Scredit'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => p_msg_count
        ,   p_data                        => p_msg_data
        );

END Replace_Multi_Line_Scredit;

END OE_OE_Multi_Line_Scredit;

/
