--------------------------------------------------------
--  DDL for Package Body OE_QUOTE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_QUOTE_UTIL" AS
/* $Header: OEXUQUOB.pls 120.0.12010000.3 2009/05/13 10:47:52 smanian ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Quote_Util';

PROCEDURE Complete_Negotiation
   (p_header_id                 IN NUMBER
   ,x_return_status             OUT NOCOPY VARCHAR2
   ,x_msg_count                 OUT NOCOPY NUMBER
   ,x_msg_data                  OUT NOCOPY VARCHAR2
   )
IS

  l_old_header_rec            OE_Order_PUB.Header_Rec_Type;
  l_old_line_tbl              OE_Order_PUB.Line_Tbl_Type;
  l_header_rec                OE_Order_PUB.Header_Rec_Type;
  l_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
  l_header_adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
  l_line_adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
  l_header_price_att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
  l_line_price_att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
  l_header_adj_att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
  l_line_adj_att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
  l_header_adj_assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
  l_line_adj_assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
  l_header_scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
  l_line_scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
  l_lot_serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
  l_header_payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
  l_line_payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
  l_action_request_tbl        OE_Order_PUB.request_tbl_type;
  l_control_rec               OE_GLOBALS.Control_Rec_Type;
  l_return_status             VARCHAR2(30);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  I                           NUMBER;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  if l_debug_level > 0 then
     oe_debug_pub.add('ENTER Complete_Negotiation',1);
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Query/Lock order header and lines

  OE_Header_Util.Lock_Row
            (p_header_id         => p_header_id
            ,p_x_header_rec      => l_old_header_rec
            ,x_return_status     => l_return_status
            );
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  OE_Line_Util.Lock_Rows
            (p_header_id         => p_header_id
            ,x_line_tbl          => l_old_line_tbl
            ,x_return_status     => l_return_status
            );
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Set attributes on header and lines to change phase
  -- from negotiation to fulfillment

  l_header_rec := l_old_header_rec;
  l_line_tbl := l_old_line_tbl;

  l_header_rec.operation := oe_globals.g_opr_update;
  l_header_rec.transaction_phase_code := 'F';

  IF l_header_rec.ordered_date IS NULL THEN
	 l_header_rec.ordered_date := FND_API.G_MISS_DATE;--bug8477340
  END IF;

  oe_debug_pub.add('old quote date :'||to_char(l_old_header_rec.quote_date
                                       ,'DD-MON-YYYY HH24:MI:SS'));
  oe_debug_pub.add('new quote date :'||to_char(l_header_rec.quote_date
                                       ,'DD-MON-YYYY HH24:MI:SS'));
  l_header_rec.flow_status_code := 'ENTERED';
  -- Bug 3519935
  -- Send reason as SYSTEM, this will be used if audit constraint to
  -- require reason or versioning constraint to require reason is
  -- applicable to this update operation.
  l_header_rec.change_reason := 'SYSTEM';

  I := l_line_tbl.FIRST;
  WHILE I IS NOT NULL LOOP

     l_line_tbl(I).operation := oe_globals.g_opr_update;
     l_line_tbl(I).transaction_phase_code := 'F';
     l_line_tbl(I).flow_status_code := 'ENTERED';

     -- Following schedule dates should default in fulfillment phase
     l_line_tbl(I).schedule_ship_date := fnd_api.g_miss_date;
     l_line_tbl(I).schedule_arrival_date := fnd_api.g_miss_date;

     -- Bug 3519935
     -- Send reason as SYSTEM, this will be used if audit constraint to
     -- require reason or versioning constraint to require reason is
     -- applicable to this update operation.
     l_line_tbl(I).change_reason := 'SYSTEM';

     I := l_line_tbl.NEXT(I);

  END LOOP;


  -- Set global to indicate that call is from complete negotiation API

  G_COMPLETE_NEG := 'Y';


  -- Call process order for the update

  OE_Order_PVT.Process_Order
  	(p_api_version_number          => 1.0
        -- no attribute validation needed
	,p_validation_level            => fnd_api.g_valid_level_none
        ,p_control_rec                 => l_control_rec
	,p_x_header_rec                => l_header_rec
	,p_old_header_rec              => l_old_header_rec
	,p_x_line_tbl                  => l_line_tbl
	,p_old_line_tbl                => l_old_line_tbl
        ,p_x_header_adj_tbl            => l_header_adj_tbl
        ,p_x_header_price_att_tbl      => l_header_price_att_tbl
        ,p_x_header_adj_att_tbl        => l_header_adj_att_tbl
        ,p_x_header_adj_assoc_tbl      => l_header_adj_assoc_tbl
        ,p_x_header_scredit_tbl        => l_header_scredit_tbl
        ,p_x_header_payment_tbl        => l_header_payment_tbl
        ,p_x_line_adj_tbl              => l_line_adj_tbl
        ,p_x_line_price_att_tbl        => l_line_price_att_tbl
        ,p_x_line_adj_att_tbl          => l_line_adj_att_tbl
        ,p_x_line_adj_assoc_tbl        => l_line_adj_assoc_tbl
        ,p_x_line_scredit_tbl          => l_line_scredit_tbl
        ,p_x_line_payment_tbl          => l_line_payment_tbl
        ,p_x_lot_serial_tbl            => l_lot_serial_tbl
        ,p_x_action_request_tbl        => l_action_request_tbl
        ,x_return_status               => l_return_status
        ,x_msg_count                   => l_msg_count
        ,x_msg_data                    => l_msg_data
	);

  -- Re-set global to N after process order call
  G_COMPLETE_NEG := 'N';

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

  if l_debug_level > 0 then
     oe_debug_pub.add('EXIT Complete_Negotiation',1);
  end if;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     G_COMPLETE_NEG := 'N';
     x_return_status := FND_API.G_RET_STS_ERROR;
     OE_MSG_PUB.Count_And_Get
       (   p_count                       => x_msg_count
       ,   p_data                        => x_msg_data
       );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     G_COMPLETE_NEG := 'N';
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     OE_MSG_PUB.Count_And_Get
       (   p_count                       => x_msg_count
       ,   p_data                        => x_msg_data
       );

  WHEN OTHERS THEN
     G_COMPLETE_NEG := 'N';
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
               (G_PKG_NAME
                ,'Complete_Negotiation'
               );
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     OE_MSG_PUB.Count_And_Get
       (   p_count                       => x_msg_count
       ,   p_data                        => x_msg_data
       );

END Complete_Negotiation;

END OE_Quote_Util;

/
