--------------------------------------------------------
--  DDL for Package Body OE_LINE_REPRICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_REPRICE" AS
/* $Header: OEXVREPB.pls 120.0.12010000.3 2008/11/24 13:40:32 aambasth ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OE_Line_REPRICE';


PROCEDURE Reprice_Line
(
 p_line_rec	 	IN	OE_Order_Pub.Line_Rec_Type
, p_Repricing_date	IN	VARCHAR2
, p_Repricing_event	IN	VARCHAR2
, p_Honor_Price_Flag    IN      VARCHAR2
, x_return_status	OUT NOCOPY /* file.sql.39 change */	VARCHAR2
)
IS
    CURSOR check_event_cur(p_repricing_event IN VARCHAR2) IS
    SELECT qp.modifier_level_code
    FROM   qp_pricing_phases qp, qp_event_phases qe
    WHERE  qp.pricing_phase_id = qe.pricing_phase_id
    AND    qe.pricing_event_code = p_repricing_event;

  l_control_rec				OE_GLOBALS.Control_Rec_Type;
  l_return_status				VARCHAR2(1);
  l_Price_Control_Rec		     QP_PREQ_GRP.control_record_type;
  l_x_line_tbl                     OE_Order_Pub.Line_Tbl_Type;
  l_line_rec                       OE_Order_Pub.Line_Rec_Type := p_line_rec;
  l_line_tbl                       OE_Order_Pub.Line_Tbl_Type;
  l_old_line_tbl                   OE_Order_Pub.Line_Tbl_Type;
  l_price_flag                  	VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_REPRICE.REPRICE_LINE '|| TO_CHAR ( P_LINE_REC.LINE_ID ) , 1 ) ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- check if repricing event is LINE level event
  FOR l_event_rec IN check_event_cur(p_repricing_event) LOOP
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EVENT LEVEL CODE IS: '||L_EVENT_REC.MODIFIER_LEVEL_CODE , 1 ) ;
    END IF;
    IF NVL(l_event_rec.modifier_level_code, 'ORDER') <> 'LINE' THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME('ONT','ONT_REPRICE_INVALID_EVENT');
      OE_MSG_PUB.Add;
      oe_line_reprice.set_reprice_status('REPRICE_INVALID_SETUP', p_line_rec.line_id);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      EXIT;
    END IF;
  END LOOP;

  If (p_Repricing_Date = 'ACTUAL_SHIPMENT_DATE') THEN
    l_line_rec.Pricing_Date := p_line_rec.Actual_Shipment_Date;
  Elsif (p_Repricing_Date = 'SCHEDULE_SHIP_DATE') THEN
    l_line_rec.Pricing_Date := p_line_rec.Schedule_Ship_Date;
  Elsif (p_Repricing_Date = 'FULFILLMENT_DATE') THEN
    l_line_rec.Pricing_Date := p_line_rec.fulfillment_date;
  Elsif (p_Repricing_Date = 'PROMISE_DATE') THEN
    l_line_rec.Pricing_Date := p_line_rec.Promise_Date;
  Elsif (p_Repricing_Date = 'REQUEST_DATE') THEN
    l_line_rec.Pricing_Date := p_line_rec.Request_Date;
  Elsif (p_Repricing_Date = 'SYSDATE') THEN
    l_line_rec.Pricing_Date := sysdate;
  ELSE
    -- No change to Pricing Date
    NULL;
  End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'REPRICING DATE IS: '||P_REPRICING_DATE , 1 ) ;
  END IF;

  IF l_line_rec.Pricing_Date IS NULL THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME('ONT','ONT_REPRICE_INVALID_DATE');
      oe_line_reprice.set_reprice_status('REPRICE_INVALID_SETUP', p_line_rec.line_id);
      OE_MSG_PUB.Add;
      return;
   -- do not raise error, instead, exit out of Reprice activity.
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_Price_Control_Rec.pricing_event := p_Repricing_Event;
  l_Price_Control_Rec.calculate_flag := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
  l_Price_Control_Rec.Simulation_Flag := 'N';
  l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;

  l_x_line_tbl(1) := l_line_rec;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'REPRICING EVENT '||P_REPRICING_EVENT , 2 ) ;
      oe_debug_pub.add(  'REPRICING DATE '||L_X_LINE_TBL ( 1 ) .PRICING_DATE , 2 ) ;
  END IF;

  oe_order_adj_pvt.Price_line(
     X_Return_Status     => l_Return_Status
    ,p_Line_id          => NULL
    ,p_Request_Type_code=> 'ONT'
    ,p_Control_rec      => l_Price_Control_Rec
    ,p_Write_To_Db		=> TRUE   --- ?????????????
    ,x_Line_Tbl		=> l_x_Line_Tbl
    ,p_honor_price_flag	=> p_honor_price_flag);


  IF   l_return_status <> FND_API.G_RET_STS_SUCCESS then
     oe_line_reprice.set_reprice_status('REPRICE_PRICING_ERROR', p_line_rec.line_id);
  END IF;

  IF	l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF 	l_return_status = FND_API.G_RET_STS_ERROR THEN
   RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_return_status := l_return_status;

EXCEPTION
	WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME,
				   'Reprice_Line'
				);
			END IF;

    WHEN 	FND_API.G_EXC_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_ERROR;
	WHEN OTHERS THEN
                oe_line_reprice.set_reprice_status('REPRICE_UNEXPECTED_ERROR',p_line_rec.line_id);
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  OE_MSG_PUB.set_msg_context(
           p_entity_code                => 'LINE'
          ,p_entity_id                  => l_line_rec.line_id
          ,p_header_id                  => l_line_rec.header_id
          ,p_line_id                    => l_line_rec.line_id
          ,p_order_source_id            => l_line_rec.order_source_id
          ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
          ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
          ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
          ,p_change_sequence            => l_line_rec.change_sequence
          ,p_source_document_type_id    => l_line_rec.source_document_type_id
          ,p_source_document_id         => l_line_rec.source_document_id
          ,p_source_document_line_id    => l_line_rec.source_document_line_id );

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
                            oe_debug_pub.add('In others of Reprice line');
			END IF;

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME,
				   'Reprice_Line'
				);
			END IF;

END Reprice_Line;

/*
	This procedure is to get the work flow activity attribute for a given
	item type, item key, activity id and attribute name using work flow
	engine API GetActivityAttrText.
*/

PROCEDURE Get_Activity_Attribute
(
	p_item_type			IN	VARCHAR2
,	p_item_key			IN	VARCHAR2
,	p_activity_id			IN	VARCHAR2
,	p_Reprice_attr_name		IN	VARCHAR2
,	x_attribute_value		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,	x_return_status			OUT NOCOPY /* file.sql.39 change */	VARCHAR2
)
IS
	l_errname			VARCHAR2(30);
	l_errmsg			VARCHAR2(2000);
	l_errstack			VARCHAR2(2000);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
  l_header_id                 NUMBER;
  l_orig_sys_line_ref         VARCHAR2(50);
  l_orig_sys_shipment_ref     VARCHAR2(50);
  l_order_source_id           NUMBER;
  l_orig_sys_document_ref     VARCHAR2(50);
  l_change_sequence           VARCHAR2(50);
  l_source_document_type_id   NUMBER;
  l_source_document_id        NUMBER;
  l_source_document_line_id   NUMBER;
BEGIN
		x_attribute_value := wf_engine.GetActivityAttrText(p_item_type,p_item_key,p_activity_id,p_Reprice_attr_name);

		x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
	WHEN OTHERS THEN
                oe_line_reprice.set_reprice_status('REPRICE_UNEXPECTED_ERROR',to_number(p_item_key));
  select header_id, order_source_id, orig_sys_document_ref,
         orig_sys_line_ref, orig_sys_shipment_ref, change_sequence,
         source_document_type_id,source_document_id,source_document_line_id
  into   l_header_id, l_order_source_id, l_orig_sys_document_ref,
         l_orig_sys_line_ref, l_orig_sys_shipment_ref, l_change_sequence,
         l_source_document_type_id, l_source_document_id, l_source_document_line_id
  from   oe_order_lines_all
  where   line_id = to_number(p_item_key);
  OE_MSG_PUB.set_msg_context(
           p_entity_code                => 'LINE'
          ,p_entity_id                  => to_number(p_item_key)
          ,p_header_id                  => l_header_id
          ,p_line_id                    => to_number(p_item_key)
          ,p_order_source_id            => l_order_source_id
          ,p_orig_sys_document_ref      => l_orig_sys_document_ref
          ,p_orig_sys_document_line_ref => l_orig_sys_line_ref
          ,p_orig_sys_shipment_ref      => l_orig_sys_shipment_ref
          ,p_change_sequence            => l_change_sequence
          ,p_source_document_type_id    => l_source_document_type_id
          ,p_source_document_id         => l_source_document_id
          ,p_source_document_line_id    => l_source_document_line_id );

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'WORK FLOW ERROR HAS OCCURED ' , 1 ) ;
		END IF;
		WF_CORE.Get_Error(l_errname, l_errmsg, l_errstack);
		IF	l_errname = 'WFENG_ACTIVITY_ATTR' THEN
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'ERROR MESSAGE '||L_ERRMSG , 1 ) ;
			END IF;
			x_attribute_value := 'NONE';
			x_return_status := FND_API.G_RET_STS_SUCCESS;
		ELSE
                  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                      OE_MSG_PUB.Add_Exc_Msg
                      (   G_PKG_NAME
                      ,   'Get_Activity_Attribute'
                      );
                  END IF;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		END IF;

END Get_Activity_Attribute;

/*
	This procedure is called when a line reaches Reprice_LINE work flow
	activity. It gets the Repricing date and Repricing Event attribute
        and calls reprice_line to reprice the line.
*/

PROCEDURE Process_Repricing
(
	p_api_version_number	IN	NUMBER
,	p_line_id		IN	NUMBER
,	p_activity_id		IN	NUMBER
,	x_result_out		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,	x_return_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,	x_msg_count		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,	x_msg_data		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
)
IS

  l_line_rec				OE_Order_Pub.Line_Rec_Type;
  l_return_status			VARCHAR2(1);
  l_item_key				VARCHAR2(240);
  l_Repricing_date_attr		VARCHAR2(30):='REPRICE_DATE';
  l_Repricing_date			VARCHAR2(30);
  l_Repricing_event_attr		VARCHAR2(30):='REPRICE_EVENTS';
  l_Repricing_event		     VARCHAR2(30);
  l_Honor_Price_Flag_attr	VARCHAR2(30):='HONOR_PRICE_FLAG';
  l_Honor_Price_Flag	     VARCHAR2(30);
  l_item_type                 VARCHAR2(8) := OE_GLOBALS.G_WFI_LIN;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_REPRICE.PROCESS_REPRICING '|| TO_CHAR ( P_LINE_ID ) , 1 ) ;
  END IF;

  x_result_out := 'COMPLETE';

  OE_Line_Util.Query_Row(p_line_id	=>	p_line_id,
  		         x_line_rec	=>	l_line_rec);

  OE_MSG_PUB.set_msg_context(
           p_entity_code                => 'LINE'
          ,p_entity_id                  => l_line_rec.line_id
          ,p_header_id                  => l_line_rec.header_id
          ,p_line_id                    => l_line_rec.line_id
          ,p_order_source_id            => l_line_rec.order_source_id
          ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
          ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
          ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
          ,p_change_sequence            => l_line_rec.change_sequence
          ,p_source_document_type_id    => l_line_rec.source_document_type_id
          ,p_source_document_id         => l_line_rec.source_document_id
          ,p_source_document_line_id    => l_line_rec.source_document_line_id );


  -- It is a non shippable line, complete the Reprice activity
  -- with a result of complete:not_eligible.Fix for bug 2883913.

  /*
  Commented for bug 7592279 start
  Removed the condition below to enable repricing of Non Shippable lines

  IF nvl(l_line_rec.shippable_flag, 'N') <> 'Y' THEN
    x_result_out := 'COMPLETE:NOT_ELIGIBLE';
    oe_line_reprice.set_reprice_status('REPRICE_NOT_ELIGIBLE', p_line_id);
    return;
  END IF;
  Commented for bug 7592279 end*/

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ACTIVTITY ID : '||TO_CHAR ( P_ACTIVITY_ID ) , 3 ) ;
  END IF;
  l_item_key := to_char(p_line_id);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING GET REPRICING ACTIVITY ' , 3 ) ;
  END IF;

  Get_Activity_Attribute
  (
  	p_item_type		=> 	l_item_type,
  	p_item_key		=>	l_item_key,
  	p_activity_id		=>	p_activity_id,
  	p_Reprice_attr_name	=> 	l_Repricing_date_attr,
  	x_attribute_value	=> 	l_Repricing_date,
  	x_return_status		=> 	l_return_status
   );

  IF	l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF 	l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'REPRICING DATE : '|| L_REPRICING_DATE , 3 ) ;
      oe_debug_pub.add(  'CALLING GET ATTRIBUTE - REPRICING EVENT ' , 3 ) ;
  END IF;

  Get_Activity_Attribute
  (
    p_item_type			=> l_item_type,
    p_item_key			=> l_item_key,
    p_activity_id		=> p_activity_id,
    p_Reprice_attr_name		=> l_Repricing_Event_Attr,
    x_attribute_value		=> l_Repricing_Event,
    x_return_status		=> l_return_status
  );

  IF	l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF 	l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF	l_Repricing_Event IS NULL THEN
    l_Repricing_Event := 'REPRICE_LINE';
  End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'REPRICING EVENT : '|| L_REPRICING_EVENT , 3 ) ;
  END IF;

  Get_Activity_Attribute
  (
    p_item_type			=> l_item_type,
    p_item_key			=> l_item_key,
    p_activity_id		=> p_activity_id,
    p_Reprice_attr_name		=> l_Honor_Price_Flag_attr,
    x_attribute_value		=> l_Honor_Price_Flag,
    x_return_status		=> l_return_status
  );

  IF	l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF 	l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF	l_Honor_Price_Flag IS NULL THEN
    l_Honor_Price_Flag := 'Y';
  End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'HONOR PRICE FLAG : '|| L_HONOR_PRICE_FLAG , 3 ) ;
  END IF;

   Reprice_Line
   (
     p_line_rec		=>	l_line_rec,
     p_Repricing_date	=>	l_Repricing_date,
     p_Repricing_event 	=> 	l_Repricing_event,
     p_Honor_Price_Flag => 	l_Honor_Price_Flag,
     x_return_status 	=>	l_return_status
   );

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'RETURN STATUS FROM REPRICE LINE : '||L_RETURN_STATUS , 3 ) ;
   END IF;

  IF	l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF 	l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING FROM OE_LINE_REPRICE.PROCESS_REPRICING : '||X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION
	WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN
        	IF l_debug_level  > 0 THEN
        	    oe_debug_pub.add(  'PROCESS_REPRICING : EXITING WITH UNEXPECTED ERROR'||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
        	END IF;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		x_result_out := 'INCOMPLETE';
/*		IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME,
				   'Process_Repricing'
				);
		END IF; */

    WHEN 	FND_API.G_EXC_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_ERROR;
  		x_result_out := 'INCOMPLETE';
	WHEN OTHERS THEN
        	IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('In others of Process_Reprice ');
        	    oe_debug_pub.add(  'PROCESS_REPRICING : EXITING WITH OTHERS ERROR' , 1 ) ;
		    oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
		END IF;
          	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		x_result_out := 'INCOMPLETE';
                oe_line_reprice.set_reprice_status('REPRICE_UNEXPECTED_ERROR', p_line_id);
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Repricing'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Repricing;

Procedure set_reprice_status (p_flow_status IN VARCHAR2,
                              p_line_id     IN NUMBER)
IS

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

 IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Setting Flow Stauts code to '||p_flow_status || 'for line id ' ||p_line_id);
 END IF;

 IF oe_code_control.code_release_level>='110510' THEN
     Update oe_order_lines_all
     Set flow_status_code = p_flow_status
     Where line_id = p_line_id;
 End IF;

END set_reprice_status;

END OE_LINE_REPRICE;


/
