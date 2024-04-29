--------------------------------------------------------
--  DDL for Package Body OE_INTERNAL_REQUISITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INTERNAL_REQUISITION_PVT" AS
/* $Header: OEXVIRQB.pls 120.0.12010000.8 2014/08/18 05:47:53 rahujain noship $ */

--  Global constant holding the package name
G_PKG_Name          CONSTANT VARCHAR2(30) := 'OE_INTERNAL_REQUISITION_PVT';

-- Added for 8583903
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

Procedure Get_Eligible_ISO_Shipment  -- Body definition
(  P_internal_req_line_id   IN PO_Requisition_Lines_All.Requisition_Line_id%TYPE
,  P_internal_req_header_id IN PO_Requisition_Headers_All.Requisition_Header_id%TYPE
,  X_line_ids_rec	    OUT NOCOPY Line_Id_Rec_Type
,  X_return_status	    OUT NOCOPY VARCHAR2
) IS
--
l_line_ids_rec	Line_Id_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

Begin

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_Internal_Requisition_Pvt.Get_Eligible_ISO_Shipment', 1 ) ;
    oe_debug_pub.add(  ' Requisition Line id :'||P_internal_req_line_id , 5 ) ;
    oe_debug_pub.add(  ' Requisition Header id :'||P_internal_req_header_id , 5) ;
  END IF;

  X_return_status := FND_API.G_RET_STS_SUCCESS;

  select l.line_id
       , l.line_number
       , l.shipment_number
       , l.header_id
       , l.ordered_quantity
       , l.ordered_quantity2
       , l.request_date
       , l.schedule_arrival_date --Bug 19273040
  into   l_line_ids_rec.line_id
       , l_line_ids_rec.line_number
       , l_line_ids_rec.shipment_number
       , l_line_ids_rec.header_id
       , l_line_ids_rec.ordered_quantity
       , l_line_ids_rec.ordered_quantity2
       , l_line_ids_rec.request_date
       , l_line_ids_rec.sch_arrival_date --Bug 19273040
  from   oe_order_headers_all h
       , oe_order_lines_all l
  -- OE_Order_Header_All table is used in this query to use
  -- the OE_Order_Headers_N7 index for performance reasons
  where  h.header_id = l.header_id
  and    h.source_document_id = p_internal_req_header_id
  and    l.source_document_line_id = p_internal_req_line_id
  and    h.source_document_type_id = OE_Globals.G_ORDER_SOURCE_INTERNAL
  and    h.open_flag = 'Y'
  and    l.open_flag = 'Y'
  and    nvl(l.cancelled_flag,'N') = 'N'
  and    nvl(l.fulfilled_flag,'N') = 'N'
  and    nvl(l.shipped_quantity,0) = 0
  and    nvl(l.fulfilled_quantity,0) = 0
  and    l.actual_shipment_date is null
  and    not exists (select 1 from wsh_delivery_details w
                     where  w.source_line_id = l.line_id
                     and    w.source_header_id = h.header_id
                     and    w.source_code = 'OE'
                     and    w.released_status = 'C')
  order by l.shipment_number;
  --  If delivery detail is pick release: Not verifying!, because
  --  OM Pick Released constraint is not a seeded constraint

  X_line_ids_rec := l_line_ids_rec;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  ' EXITING OE_Internal_Requisition_Pvt.Get_Eligible_ISO_Shipment', 1 ) ;
  END IF;

Exception

  WHEN NO_DATA_FOUND THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' EXITING Get_Eligible_ISO_Shipment With No Data Found Error', 1 ) ;
    END IF;
    FND_Message.Set_Name('ONT', 'OE_IRCMS_NOT_ELIGIBLE');
    -- There is no sales order line shipment eligible for update/cancellation.
    OE_MSG_PUB.Add;
    X_return_status := FND_API.G_RET_STS_ERROR;

  WHEN TOO_MANY_ROWS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' EXITING Get_Eligible_ISO_Shipment with Too Many Rows error', 1 ) ;
    END IF;
    FND_Message.Set_Name('ONT', 'OE_IRCMS_TOO_MANY_ROWS');
    -- There are multiple sales order line shipments eligible for update.
    -- This is not allowed.
    OE_MSG_PUB.Add;
    X_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' EXITING Get_Eligible_ISO_Shipment with others error'||sqlerrm,1);
    END IF;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Get_Eligible_ISO_Shipment');
      -- Pkg Body global variable = 'OE_internal_Requisition_Pv'
    END IF;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
End Get_Eligible_ISO_Shipment;


Function Update_Allowed -- Body definition
( P_line_id          IN NUMBER
, P_Attribute        IN VARCHAR2
) RETURN BOOLEAN
IS
--
l_line_rec         OE_Order_Pub.Line_Rec_Type;
l_return_status    VARCHAR2(1);
l_line_rowtype_rec      OE_AK_ORDER_LINES_V%ROWTYPE;
l_attr_update_allowed   BOOLEAN := FALSE;
l_entity_update_allowed BOOLEAN := FALSE;
l_action           NUMBER;
l_result           NUMBER := OE_PC_GLOBALS.NO;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_Internal_Requisition_Pvt.Update_Allowed', 1) ;
  END IF;

  OE_LINE_UTIL.QUERY_ROW( p_line_id  => P_line_id
                        , x_line_rec => l_line_rec );

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add( ' Converting to Rowtype record', 5);
  END IF;

  OE_LINE_Util_Ext.API_Rec_To_Rowtype_Rec( p_LINE_rec    => l_line_rec
                                         , x_rowtype_rec => l_line_rowtype_rec);

  --Initialize security global record
  OE_LINE_SECURITY.g_record := l_line_rowtype_rec;

  IF P_Attribute IS NULL OR P_Attribute in ('REQUEST_DATE','ALL') THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Checking if update of Request Date is allowed', 5);
    END IF;
    l_result := OE_Line_Security.Request_Date -- Is_OP_Constrained
                ( p_operation           => OE_PC_GLOBALS.UPDATE_OP
                -- , p_column_name         => 'REQUEST_DATE'
                , p_record              => l_line_rowtype_rec
                , x_on_operation_action => l_action );

    IF l_result = OE_PC_GLOBALS.NO THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( ' Update of Request Date is allowed. Action'||l_action,1);
      END IF;
      l_attr_update_allowed := TRUE;
    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( ' Update of Request Date is not allowed.',1);
        oe_debug_pub.add( ' Action / Result : '||l_action||' / '||l_result,1);
      END IF;
      l_attr_Update_Allowed := FALSE;
    END IF; -- l_result
  END IF; -- P_Attribute


  IF (NOT l_attr_update_allowed AND P_Attribute IS NULL)
    OR P_Attribute in ('ORDERED_QUANTITY', 'ALL') THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Checking if update of Ordered Quantity is allowed',5);
    END IF;

    l_result := OE_Line_Security.Ordered_Quantity --Is_OP_Constrained
                ( p_operation           => OE_PC_GLOBALS.UPDATE_OP
                -- , p_column_name         => 'ORDERED_QUANTITY'
                , p_record              => l_line_rowtype_rec
                , x_on_operation_action => l_action );

    IF l_result = OE_PC_GLOBALS.NO THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( 'Update of Ordered Quantity is allowed. Action'||l_action,1);
      END IF;
      l_attr_Update_Allowed := TRUE;
    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( ' Update of Ordered Quantity is not allowed.',1);
        oe_debug_pub.add( ' Action / Result : '||l_action||' / '||l_result,1);
      END IF;
      l_attr_Update_Allowed := FALSE;
    END IF; -- l_result
  END IF; -- P_Attribute

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add( ' Checking if Update operation is allowed for a record',5);
  END IF;
  IF ( NOT l_entity_update_allowed ) AND ( l_attr_update_allowed ) THEN

    l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;

    OE_Line_Security.Entity -- Is_OP_Constrained
    ( p_LINE_rec           => l_line_rec
    , x_result             => l_result
    , x_return_status      => l_return_status );

    IF l_result = OE_PC_GLOBALS.NO THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( 'Update is allowed for Entity. Action'||l_action,1);
      END IF;
      l_entity_Update_Allowed := TRUE;
    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( ' Entity Update is not allowed.',1);
        oe_debug_pub.add( ' Action / Result : '||l_action||' / '||l_result,1);
      END IF;
      l_entity_Update_Allowed := FALSE;
    END IF; -- l_result
  END IF; -- l_entity_update_allowed

  IF l_entity_update_allowed AND l_attr_update_allowed THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Order Line is allowed to UPDATE.',1);
    END IF;
    RETURN TRUE;
  ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Order Line is NOT allowed to UPDATE.',1);
    END IF;
    -- Resetting the Boolean for the next iteration of the loop
    l_entity_update_allowed := FALSE;
    l_attr_update_allowed   := FALSE;
    RETURN FALSE;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_Internal_Requisition_Pvt.Update_Allowed', 1 ) ;
  END IF;
Exception
  WHEN OTHERS THEN
    oe_debug_pub.add(  ' When Others of OE_Internal_Requisition_Pvt.Update_Allowed '||sqlerrm,1);
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Update_Allowed');
      -- Pkg Body global variable = 'OE_internal_Requisition_Pv'
    END IF;
    RETURN FALSE;
End Update_Allowed;


Function Cancel_Allowed -- Body definition
( P_line_id IN NUMBER
) RETURN BOOLEAN
IS
--
l_line_rec         OE_Order_Pub.Line_Rec_Type;
l_result           NUMBER := OE_PC_GLOBALS.NO;
l_rowtype_rec      OE_AK_ORDER_LINES_V%ROWTYPE;
l_return_status    VARCHAR2(1);
l_action              NUMBER;
l_constraint_id       NUMBER;
l_grp                 NUMBER;
l_on_operation_action NUMBER;
l_column_name         VARCHAR2(120);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_Internal_Requisition_Pvt.Cancel_Allowed', 1) ;
  END IF;

  OE_LINE_UTIL.QUERY_ROW( p_line_id  => P_line_id
                        , x_line_rec => l_line_rec );

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add( ' Calling OE_Line_SEcurity.Entity',5);
  END IF;

  l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
  l_line_rec.ordered_quantity := 0;
  IF l_line_rec.ordered_quantity2 IS NOT NULL AND l_line_rec.ordered_quantity2 <> 0 THEN
    l_line_rec.ordered_quantity2 := 0;
  END IF;

  OE_Line_Security.Entity -- Is_OP_Constrained
  ( p_LINE_rec           => l_line_rec
  , x_result             => l_result
  , x_return_status      => l_return_status );

  IF l_result = OE_PC_GLOBALS.NO THEN
-- Vaibhav
    OE_LINE_Util_Ext.API_Rec_To_Rowtype_Rec
        ( p_LINE_rec    => l_line_rec
        , x_rowtype_rec => l_rowtype_rec);

    --Initialize security global record
    OE_LINE_SECURITY.g_record := l_rowtype_rec;

    -- Modified the code for bug 7675256
    l_result := OE_Line_Security.Ordered_Quantity --Is_OP_Constrained
                ( p_operation           => OE_PC_GLOBALS.UPDATE_OP
                -- , p_column_name         => 'ORDERED_QUANTITY'
                , p_record              => l_rowtype_rec
                , x_on_operation_action => l_action );

/*  -- Commented for bug 7675256
    l_column_name := NULL;

    l_result := OE_PC_Constraints_Admin_PVT.Is_OP_constrained
     ( p_responsibility_id       => nvl(fnd_global.resp_id, -1)
     , p_application_id          => nvl(fnd_global.resp_appl_id,-1)
     , p_operation               => OE_PC_Globals.CANCEL_OP
     , p_qualifier_attribute     => l_rowtype_rec.transaction_phase_code
     , p_entity_id               => OE_PC_GLOBALS.G_ENTITY_LINE
     , p_column_name             => l_column_name
     , p_check_all_cols_constraint   => 'N' -- g_check_all_cols_constraint ???
     , p_is_caller_defaulting    => 'N' -- g_is_caller_defaulting ???
     , p_use_cached_results      => 'Y' --  ???
     , x_constraint_id           => l_constraint_id
     , x_constraining_conditions_grp => l_grp
     , x_on_operation_action     => l_on_operation_action
     );
*/

    IF l_result = OE_PC_GLOBALS.NO THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( 'Cancel is allowed for this shipment.',1);
      END IF;
      RETURN TRUE;
    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( 'Cancel is Not allowed for this shipment',1);
      END IF;
      RETURN FALSE;
    END IF;
  ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'Cancel is not allowed for this shipment.',1);
    END IF;
    RETURN FALSE;
  END IF;
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_Internal_Requisition_Pvt.Cancel_Allowed', 1 ) ;
  END IF;

Exception
  WHEN OTHERS THEN
    oe_debug_pub.add(  ' When Others of OE_Internal_Requisition_Pvt.Cancel_Allowed '||sqlerrm,1);
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Cancel_Allowed');
      -- Pkg Body global variable = 'OE_internal_Requisition_Pvt'
    END IF;
    RETURN FALSE;
End Cancel_Allowed;


Function Cancel_Header_Allowed -- Body definition
( P_header_id IN NUMBER
) RETURN BOOLEAN
IS
--
l_header_rec         OE_Order_Pub.Header_Rec_Type;
l_header_rowtype_rec OE_AK_ORDER_HEADERS_V%ROWTYPE;
l_action             NUMBER;
l_result           NUMBER := OE_PC_GLOBALS.NO;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_Internal_Requisition_Pvt.Cancel_Header_Allowed', 1 ) ;
  END IF;

  OE_HEADER_UTIL.QUERY_ROW( p_header_id  => P_header_id
                        , x_header_rec => l_header_rec );

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add( ' Converting to Rowtype record',5);
  END IF;

  OE_HEADER_Util.API_Rec_To_Rowtype_Rec( p_header_rec    => l_header_rec
                                         , x_rowtype_rec => l_header_rowtype_rec);

  -- Initialize security global record
  OE_Header_SECURITY.g_record := l_header_rowtype_rec;

  l_result := OE_Header_Security.Is_OP_Constrained
              ( p_operation           => OE_PC_GLOBALS.CANCEL_OP
              , p_record              => l_header_rowtype_rec
              , x_on_operation_action => l_action );

  IF l_result = OE_PC_GLOBALS.NO THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'Cancel is allowed for this Order. Action'||l_action,1);
    END IF;
    RETURN TRUE;
  ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'Cancel is not allowed for this Order. Action'||l_action,1);
    END IF;
    RETURN FALSE;
  END IF;
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_Internal_Requisition_Pvt.Cancel_Header_Allowed', 1 ) ;
  END IF;

Exception
  WHEN OTHERS THEN
    oe_debug_pub.add(  ' When Others of OE_Internal_Requisition_Pvt.Cancel_Header_Allowed '||sqlerrm,1);
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Cancel_Header_Allowed');
      -- Pkg Body global variable = 'OE_internal_Requisition_Pvt'
    END IF;
    RETURN FALSE;
End Cancel_Header_Allowed;


PROCEDURE Process_Line_Entity  -- Body definition
(p_line_Tbl       IN OE_Order_PUB.Line_Tbl_Type
,P_mode           IN VARCHAR2
,P_Cancel         IN BOOLEAN
,x_return_status  OUT NOCOPY VARCHAR2
)
IS

l_x_line_tbl       OE_Order_PUB.Line_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_TBL;
l_x_old_line_tbl   OE_Order_PUB.Line_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_TBL;
l_control_rec    OE_GLOBALS.Control_Rec_Type;
l_return_status  VARCHAR2(1);
l_header_id      NUMBER;
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);
--
l_debug_level    CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_Internal_Requisition_Pvt.Process_Line_Entity', 1 ) ;
    oe_debug_pub.add(  ' Count of Lines :'||P_Line_Tbl.COUNT, 5 ) ;
    oe_debug_pub.add(  ' Mode :'||P_Mode, 5 ) ;
  END IF;

  l_x_line_tbl   := p_line_tbl;
  l_header_id     := l_x_line_tbl(1).header_id;

  IF p_mode = 'V' THEN
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.write_to_db := FALSE;
    l_control_rec.process := FALSE;
  END IF;
  IF p_cancel THEN
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.default_attributes   := FALSE;
  END IF;


  OE_ORDER_PVT.Lines
  ( p_validation_level         => FND_API.G_VALID_LEVEL_NONE
  , p_control_rec              => l_control_rec
  , p_x_line_tbl               => l_x_line_tbl
  , p_x_old_line_tbl           => l_x_old_line_tbl
  , x_return_status            => l_return_status);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  ' After OE_Order_Pvt.Lines: '||l_return_status);
  END IF;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_mode = 'P' THEN -- Mode is PROCESS

    OE_Order_PVT.Process_Requests_And_Notify
    ( p_process_requests => TRUE
    -- , p_notify           => FALSE -- Not Needed
    , p_line_tbl         => l_x_line_tbl
    , p_old_line_tbl     => l_x_old_line_tbl
    , x_return_status    => l_return_status );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' Process_requests_and_notify UNEXP_ERROR',1 ) ;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Process_requests_and_notify RET_STS_ERROR',1 ) ;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF P_Cancel THEN
      OE_SALES_CAN_UTIL.Call_Process_Fulfillment(p_header_id => l_header_id);
    END IF;
  END IF; -- P_Mode = Process

  x_return_status := l_return_status;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_Internal_Requisition_Pvt.Process_Line_Entity', 1 ) ;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Process_Line_Entity' );
    END IF;

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Process_Line_Entity' );
    END IF;
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
    END IF;
END Process_Line_Entity;


Procedure Apply_Hold_for_IReq  -- Body definition
(  P_API_Version            IN  NUMBER
,  P_internal_req_line_id   IN PO_Requisition_Lines_All.Requisition_Line_id%TYPE
,  P_internal_req_header_id IN PO_Requisition_Headers_All.Requisition_Header_id%TYPE
,  X_msg_count              OUT NOCOPY NUMBER
,  X_msg_data               OUT NOCOPY VARCHAR2
,  X_return_status	    OUT NOCOPY VARCHAR2
) IS

--
l_API_name    Constant Varchar2(30) := 'APPLY_HOLD_FOR_IREQ';
l_API_version Constant Number       := 1.0;

l_req_hdr_id    PO_Requisition_Headers_All.Requisition_Header_id%TYPE;
l_line_ids_rec	 Line_Id_rec_Type;
l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_hold_source_rec    OE_HOLDS_PVT.Hold_Source_Rec_Type;
--
-- Modified for 8583903
l_file_val  VARCHAR2(2000);
l_debug_level NUMBER := oe_debug_pub.g_debug_level;
--

Begin

-- Added IF condition for 8583903
IF (g_fnd_debug = 'Y') THEN

  oe_debug_pub.debug_on;
  oe_debug_pub.initialize;
  l_file_val    := OE_DEBUG_PUB.Set_Debug_Mode('FILE'); -- Dir/File
  oe_Debug_pub.setdebuglevel(5);

  l_debug_level := oe_debug_pub.g_debug_level;

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string( log_level => FND_LOG.LEVEL_STATEMENT
                , module    => 'po.plsql.'||G_PKG_Name||'.'||l_API_name
		, message   => '*** The Order Mangement Debug Log Dir/File is '||l_file_val);
  END IF;
END IF;

  IF Not FND_API.Compatible_API_Call
         ( l_API_version
         , p_API_version
         , l_API_name
         , G_PKG_Name) THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  SavePoint Apply_Hold_For_IReq;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_Internal_Requisition_Pvt.Apply_Hold_for_IReq', 1 ) ;
    oe_debug_pub.add(  ' Requisition Line id :'||P_internal_req_line_id , 5 ) ;
    oe_debug_pub.add(  ' Requisition Header id :'||P_internal_req_header_id , 5) ;
  END IF;

  -- OE_MSG_PUB.set_msg_context();
  -- No need to set the message context as the caller of this API is PO
  -- and Message window is not applicable in Requesting organization

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF P_internal_req_line_id is NULL THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Invalid value passed for Requisition Line',1);
    END IF;
    FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_REQ_LIN');
    -- FND_Message.Set_Token('REQ_LIN_ID',' P_internal_req_line_id');
    OE_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF P_internal_req_header_id is NULL THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' No value passed for Requisition Header',1);
    END IF;
    Begin
      oe_debug_pub.add( ' Retrieving Requisition Header id',5);
      select requisition_header_id
      into   l_req_hdr_id
      from   po_requisition_lines_all
      where  requisition_line_id = P_internal_req_line_id;

      IF l_req_hdr_id IS NULL THEN
        oe_debug_pub.add( ' Invalid value for Requisition Header',5);
        FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_REQ_HDR');
        -- FND_Message.Set_Token('REQ_HDR_ID',P_internal_req_header_id);
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    Exception
      When No_Data_Found Then
        oe_debug_pub.add( ' Invalid value passed for Requisition Line',5);
        FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_REQ_LIN');
        -- FND_Message.Set_Token('REQ_LIN_ID',P_internal_req_line_id);
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    End;
  ELSE
    l_req_hdr_id := P_internal_req_header_id;
  END IF;

  Get_Eligible_ISO_Shipment
  (  P_internal_req_line_id   => P_internal_req_line_id
  ,  P_internal_req_header_id => P_internal_req_header_id
  ,  X_line_ids_rec	         => l_line_ids_rec
  ,  X_return_status          => l_return_status );

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add( ' Applying hold for line_id '||l_line_ids_rec.line_id,5);
  END IF;

  l_hold_source_rec.hold_id := 17;
  -- Ensure that the new seeded hold_id should be 17 in seed database
  l_hold_source_rec.hold_entity_code := 'O';
  l_hold_source_rec.hold_entity_id   := l_line_ids_rec.header_id;
  l_hold_source_rec.line_id          := l_line_ids_rec.line_id;  -- Line level hold
  l_hold_source_rec.header_id        := l_line_ids_rec.header_id;

  OE_GLOBALS.G_SYS_HOLD := TRUE; -- bug 9494397
  OE_Holds_Pvt.apply_holds
  ( p_hold_source_rec => l_hold_source_rec
  , x_return_status   => l_return_status
  , x_msg_count       => l_msg_count
  , x_msg_data        => l_msg_data );
  OE_GLOBALS.G_SYS_HOLD := FALSE; -- bug 9494397

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := l_return_status;

  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_Internal_Requisition_Pvt.Apply_Hold_for_IReq', 1 ) ;
  END IF;

-- Added for 8583903
oe_debug_pub.debug_off;
oe_Debug_pub.setdebuglevel(0);

Exception
  WHEN FND_API.G_EXC_ERROR THEN
    -- OE_MSG_PUB.Reset_Msg_Context('LINE');
    x_return_status := FND_API.G_RET_STS_ERROR;
  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);
    ROLLBACK TO Apply_Hold_For_IReq;

    -- Added for 8583903
    oe_debug_pub.debug_off;
    oe_Debug_pub.setdebuglevel(0);
    OE_GLOBALS.G_SYS_HOLD := FALSE; -- bug 9494397

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- OE_MSG_PUB.Reset_Msg_Context('LINE');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);
    ROLLBACK TO Apply_Hold_For_IReq;

    -- Added for 8583903
    oe_debug_pub.debug_off;
    oe_Debug_pub.setdebuglevel(0);
    OE_GLOBALS.G_SYS_HOLD := FALSE; -- bug 9494397

  WHEN OTHERS THEN
    oe_debug_pub.add(  ' When Others of OE_Internal_Requisition_Pvt.Apply_Hold_for_IReq '||sqlerrm,1);
    -- OE_MSG_PUB.Reset_Msg_Context('LINE');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Apply_Hold_for_IReq');
      -- Pkg Body global variable = 'OE_internal_Requisition_Pvt'
    END IF;
  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
			    P_Data  => x_msg_Data);
    ROLLBACK TO Apply_Hold_For_IReq;

    -- Added for 8583903
    oe_debug_pub.debug_off;
    oe_Debug_pub.setdebuglevel(0);
    OE_GLOBALS.G_SYS_HOLD := FALSE; -- bug 9494397

End Apply_Hold_for_IReq;


Procedure Release_Hold_for_IReq  -- Body definition
(  P_API_Version            IN  NUMBER
,  P_internal_req_line_id   IN PO_Requisition_Lines_All.Requisition_Line_id%TYPE
,  P_internal_req_header_id IN PO_Requisition_Headers_All.Requisition_Header_id%TYPE
,  X_msg_count              OUT NOCOPY NUMBER
,  X_msg_data               OUT NOCOPY VARCHAR2
,  X_return_status	    OUT NOCOPY VARCHAR2
) IS
--
l_API_name    Constant Varchar2(30) := 'RELEASE_HOLD_FOR_IREQ';
l_API_version Constant Number       := 1.0;

l_req_hdr_id    PO_Requisition_Headers_All.Requisition_Header_id%TYPE;
l_line_id       NUMBER;
l_header_id     NUMBER;
l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_hold_source_rec    OE_HOLDS_PVT.Hold_Source_Rec_Type;
l_hold_release_rec   OE_Holds_Pvt.Hold_Release_REC_Type;
--
-- Added for 8583903
l_file_val  VARCHAR2(2000);
l_debug_level NUMBER := oe_debug_pub.g_debug_level;
--

Begin

-- Added IF condition for 8583903
IF (g_fnd_debug = 'Y') THEN

  oe_debug_pub.debug_on;
  oe_debug_pub.initialize;
  l_file_val    := OE_DEBUG_PUB.Set_Debug_Mode('FILE'); --Dir/File
  oe_Debug_pub.setdebuglevel(5);

  l_debug_level := oe_debug_pub.g_debug_level;

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string( log_level => FND_LOG.LEVEL_STATEMENT
                , module    => 'po.plsql.'||G_PKG_Name||'.'||l_API_name
		, message   => '*** The Order Mangement Debug Log Dir/File is '||l_file_val);
  END IF;
END IF;

  IF Not FND_API.Compatible_API_Call
         ( l_API_version
         , p_API_version
         , l_API_name
         , G_PKG_Name) THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  SavePoint Release_Hold_For_IReq;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_Internal_Requisition_Pvt.Release_Hold_for_IReq', 1 ) ;
    oe_debug_pub.add(  ' Requisition Line id :'||P_internal_req_line_id , 5 ) ;
    oe_debug_pub.add(  ' Requisition Header id :'||P_internal_req_header_id , 5) ;
  END IF;

  -- OE_MSG_PUB.set_msg_context();
  -- No need to set the message context as the caller of this API is PO
  -- and Message window is not applicable in Requesting organization

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF P_internal_req_line_id is NULL THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Invalid value passed for Requisition Line',1);
    END IF;
    FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_REQ_LIN');
    -- FND_Message.Set_Token('REQ_LIN_ID',P_internal_req_line_id);
    OE_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF P_internal_req_header_id is NULL THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' No value passed for Requisition Header',1);
    END IF;
    Begin
      oe_debug_pub.add( ' Retrieving Requisition Header id',5);
      select requisition_header_id
      into   l_req_hdr_id
      from   po_requisition_lines_all
      where  requisition_line_id = P_internal_req_line_id;

      IF l_req_hdr_id IS NULL THEN
        oe_debug_pub.add( ' Invalid value for Requisition Header',5);
        FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_REQ_HDR');
        -- FND_Message.Set_Token('REQ_HDR_ID',P_internal_req_header_id);
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    Exception
      When No_Data_Found Then
        oe_debug_pub.add( ' Invalid value passed for Requisition Line',5);
        FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_REQ_LIN');
        -- FND_Message.Set_Token('REQ_LIN_ID',P_internal_req_line_id);
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    End;
  ELSE
    l_req_hdr_id := P_internal_req_header_id;
  END IF;

  Begin

    select l.line_id, l.header_id
    into   l_line_id, l_header_id
    from   oe_order_headers_all h
         , oe_order_lines_all l
         , oe_order_holds_all oh
         , oe_hold_sources_all hs
    -- OE_Order_Header_All table is used in this query to use
    -- the OE_Order_Headers_N7 index for performance reasons
    where  h.header_id = l.header_id
    and    h.header_id = oh.header_id
    and    l.line_id = oh.line_id
    and    oh.hold_source_id = hs.hold_source_id
    and    hs.hold_id = 17
    and    oh.hold_release_id is null
    and    h.order_source_id = OE_Globals.G_ORDER_SOURCE_INTERNAL
    and    h.source_document_id = l_req_hdr_id
    and    l.source_document_line_id = P_internal_req_line_id;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Releasing hold for line_id '||l_line_id,5);
    END IF;

    l_hold_source_rec.hold_id := 17;
    -- Ensure that the new seeded hold_id should be 17 in seed database
    l_hold_source_rec.hold_entity_code := 'O';
    l_hold_source_rec.hold_entity_id   := l_header_id;
    l_hold_source_rec.line_id          := l_line_id;  -- Line level hold
    l_hold_source_rec.header_id        := l_header_id;

    l_hold_release_rec.release_reason_code := 'IR_ISO_HOLD';
    -- We need to seed a new reason as a lookup code
    l_hold_release_rec.release_comment     := 'IR ISO Change Management System hold is released';

    OE_GLOBALS.G_SYS_HOLD := TRUE; -- bug 9494397
    OE_Holds_Pvt.Release_Holds( p_hold_source_rec  => l_hold_source_rec
                              , p_hold_release_rec => l_hold_release_rec
                              , x_return_status    => l_return_status
                              , x_msg_count        => l_msg_count
                              , x_msg_data         => l_msg_data );
    OE_GLOBALS.G_SYS_HOLD := FALSE; -- bug 9494397

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  Exception
    When No_Data_Found Then
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( 'EXITING OE_Internal_Requisition_Pvt.Release_Hold_for_Ireq with No Data Found Error');
      END IF;
      FND_Message.Set_Name('ONT', 'OE_IRCMS_NO_HOLD_RELEASED');
      -- There is no sales order line shipment on hold.
      OE_MSG_PUB.Add;
      X_return_status := FND_API.G_RET_STS_ERROR;

    When Too_Many_Rows Then
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('EXITING OE_Internal_Requisition_Pvt.Release_Hold_for_Ireq with Too Many rows error') ;
      END IF;
      FND_Message.Set_Name('ONT', 'OE_IRCMS_MANY_HOLD');
      -- There are many sales order line shipments eligible for hold release. This is not allowed.
      OE_MSG_PUB.Add;
      X_return_status := FND_API.G_RET_STS_ERROR;
  End;

  -- OE_MSG_PUB.Reset_Msg_Context('LINE');
  -- Not resetting the message because it was never initialized
  -- Same is the case in Exception block

  x_return_status := l_return_status;

  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_Internal_Requisition_Pvt.Release_Hold_for_IReq', 1 ) ;
  END IF;

-- Added for 8583903
oe_debug_pub.debug_off;
oe_Debug_pub.setdebuglevel(0);


Exception
  WHEN FND_API.G_EXC_ERROR THEN
    -- OE_MSG_PUB.Reset_Msg_Context('LINE');
    x_return_status := FND_API.G_RET_STS_ERROR;
  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);
    ROLLBACK TO Release_Hold_For_IReq;

    -- Added for 8583903
    oe_debug_pub.debug_off;
    oe_Debug_pub.setdebuglevel(0);
    OE_GLOBALS.G_SYS_HOLD := FALSE; -- bug 9494397


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- OE_MSG_PUB.Reset_Msg_Context('LINE');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);
    ROLLBACK TO Release_Hold_For_IReq;

    -- Added for 8583903
    oe_debug_pub.debug_off;
    oe_Debug_pub.setdebuglevel(0);
    OE_GLOBALS.G_SYS_HOLD := FALSE; -- bug 9494397

  WHEN OTHERS THEN
    oe_debug_pub.add(  ' When Others of OE_Internal_Requisition_Pvt.Release_Hold_for_IReq '||sqlerrm,1);
    -- OE_MSG_PUB.Reset_Msg_Context('LINE');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Release_Hold_for_IReq');
      -- Pkg Body global variable = 'OE_internal_Requisition_Pvt'
    END IF;
  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);
    ROLLBACK TO Release_Hold_For_IReq;

    -- Added for 8583903
    oe_debug_pub.debug_off;
    oe_Debug_pub.setdebuglevel(0);
    OE_GLOBALS.G_SYS_HOLD := FALSE; -- bug 9494397

End Release_Hold_for_IReq;


Procedure Is_IReq_Changable -- Body definition
(  P_API_Version            IN  NUMBER
,  P_internal_req_line_id   IN PO_Requisition_Lines_All.Requisition_Line_id%TYPE
,  P_internal_req_header_id IN PO_Requisition_Headers_All.Requisition_Header_id%TYPE
,  X_Update_Allowed         OUT NOCOPY BOOLEAN
,  X_Cancel_Allowed         OUT NOCOPY BOOLEAN
,  X_msg_count              OUT NOCOPY NUMBER
,  X_msg_data               OUT NOCOPY VARCHAR2
,  X_return_status	    OUT NOCOPY VARCHAR2
) IS

--
CURSOR All_Order_Lines (v_order_header_id NUMBER) IS
select l.line_id
from   oe_order_lines_all l
where  l.header_id = v_order_header_id
and    nvl(l.cancelled_flag,'N') = 'N';
--
l_API_name    Constant Varchar2(30) := 'IS_IREQ_CHANGABLE';
l_API_version Constant Number       := 1.0;

l_req_hdr_id       PO_Requisition_Headers_All.Requisition_Header_id%TYPE;
l_header_id        NUMBER;
l_line_id            NUMBER;
l_lines_ctr          NUMBER := 0;
l_cancel_eligble_lin NUMBER := 0;
l_line_ids_rec	    Line_Id_rec_Type;
l_update_allowed        BOOLEAN := FALSE;
l_cancel_allowed        BOOLEAN := FALSE;
l_skip_ctr_chk          BOOLEAN := FALSE;
l_Cancel_Allowed_ctr    NUMBER := 0;
l_loop_counter          NUMBER := 0;
l_return_status    VARCHAR2(1);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_hold_applied_count NUMBER := 0;
l_hold_source_rec    OE_HOLDS_PVT.Hold_Source_Rec_Type;
--
-- Added for 8583903
l_file_val  VARCHAR2(2000);
l_debug_level NUMBER := oe_debug_pub.g_debug_level;
--

Begin

-- Added IF condition for 8583903
IF (g_fnd_debug = 'Y') THEN

  oe_debug_pub.debug_on;
  oe_debug_pub.initialize;
  l_file_val    := OE_DEBUG_PUB.Set_Debug_Mode('FILE'); --Dir/File
  oe_Debug_pub.setdebuglevel(5);

  l_debug_level := oe_debug_pub.g_debug_level;

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string( log_level => FND_LOG.LEVEL_STATEMENT
                , module    => 'po.plsql.'||G_PKG_Name||'.'||l_API_name
		, message   => '*** The Order Mangement Debug Log Dir/File is '||l_file_val);
  END IF;
END IF;

  IF Not FND_API.Compatible_API_Call
         ( l_API_version
         , p_API_version
         , l_API_name
         , G_PKG_Name) THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_Internal_Requisition_Pvt.Is_IReq_Changable', 1 ) ;
    oe_debug_pub.add(  ' Requisition Line id :'||P_internal_req_line_id , 5 ) ;
    oe_debug_pub.add(  ' Requisition Header id :'||P_internal_req_header_id , 5) ;
  END IF;

  -- OE_MSG_PUB.set_msg_context();
  -- No need to set the message context as the caller of this API is PO
  -- and Message window is not applicable in Requesting organization

  l_return_status := FND_API.G_RET_STS_SUCCESS;
  X_Update_Allowed := FALSE;
  X_Cancel_Allowed := FALSE;

  IF P_internal_req_header_id is NULL AND P_internal_req_line_id is NULL THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Invalid value for Requisition Header/Line',1);
    END IF;
    FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_REQ_INFO');
    OE_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF P_internal_req_header_id is NOT NULL AND P_internal_req_line_id is NULL THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Requisition Line is NULL. We cannot check if Requisition Line is allowed to Update',1);
    END IF;
    X_UPDATE_Allowed := FALSE;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Checking if Requisition header is allowed to Cancel',5);
    END IF;
    Begin
      select h.header_id
      into   l_header_id
      from   oe_order_headers_all h
      where  h.source_document_id = p_internal_req_header_id
      and    h.order_source_id = OE_Globals.G_ORDER_SOURCE_INTERNAL
      and    h.open_flag = 'Y';

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( ' Header id is '||l_header_id,5);
      END IF;

      OPEN All_Order_Lines (l_header_id);
      LOOP
      FETCH All_Order_Lines INTO l_line_id;
      EXIT WHEN All_Order_Lines%NOTFOUND;
      l_lines_ctr := l_lines_ctr + 1;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( ' Checking cancellation allowed for line_id '||l_line_id,5);
      END IF;

      IF Cancel_Allowed( p_Line_id => l_line_id) THEN
        l_cancel_eligble_lin := l_cancel_eligble_lin + 1;
      ELSE
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add( ' Line is not allowed for cancellation',5);
          oe_debug_pub.add( ' Since line cancel is not allowed, setting header FULL Cancel as FALSE',5);
          oe_debug_pub.add( ' Exiting out of the loop ',5);
        END IF;
        X_Cancel_Allowed := FALSE;
        l_skip_ctr_chk := TRUE;
        EXIT;
      END IF;
      END LOOP;
      CLOSE All_Order_Lines;

      IF NOT l_skip_ctr_chk THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add( ' Total number of order lines are '||l_lines_ctr);
          oe_debug_pub.add( ' Total number of lines eligible for cancellation are '||l_cancel_eligble_lin);
        END IF;

        IF l_lines_ctr = l_cancel_eligble_lin THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add( ' All Lines are eligible for cancellation',5);
          END IF;
          X_Cancel_Allowed := Cancel_Header_Allowed( P_header_id => l_header_id);
          IF X_Cancel_Allowed THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add( ' Header cancellation is TRUE',5);
            END IF;
          ELSE
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add( ' Header cancellation is FALSE',5);
            END IF;
          END IF;
        ELSE
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add( ' Header cancellation is not allowed' , 5);
          END IF;
          X_Cancel_Allowed := FALSE;
        END IF;
      END IF; -- NOT l_skip_ctr_chk

      GOTO SKIP_REQ_LINE_CHK;

    Exception
      When No_Data_Found Then
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add( ' Requisition is not allowed to cancel',1);
        END IF;
        X_Cancel_Allowed := FALSE;
        GOTO SKIP_REQ_LINE_CHK;
      When Others Then
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add( ' Invalid value for Requisition Header',1);
        END IF;
        X_Cancel_Allowed := FALSE;
        FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_REQ_HDR');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    End;
  END IF;

  IF P_internal_req_header_id is NULL AND P_internal_req_line_id is NOT NULL THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' No value passed for Requisition Header',1);
    END IF;
    Begin
      oe_debug_pub.add( ' Retrieving Requisition Header id',5);
      select requisition_header_id
      into   l_req_hdr_id
      from   po_requisition_lines_all
      where  requisition_line_id = P_internal_req_line_id;

      IF l_req_hdr_id IS NULL THEN
        oe_debug_pub.add( ' Invalid value for Requisition Header',5);
        FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_REQ_HDR');
        -- FND_Message.Set_Token('REQ_HDR_ID',P_internal_req_header_id);
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    Exception
      When No_Data_Found Then
        oe_debug_pub.add( ' Invalid value passed for Requisition Line',5);
        FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_REQ_LIN');
        -- FND_Message.Set_Token('REQ_LIN_ID',P_internal_req_line_id);
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    End;
  ELSE
    l_req_hdr_id := P_internal_req_header_id;
  END IF;

  Get_Eligible_ISO_Shipment
  (  P_internal_req_line_id   => P_internal_req_line_id
  ,  P_internal_req_header_id => l_req_hdr_id
  ,  X_line_ids_rec	         => l_line_ids_rec
  ,  X_return_status          => l_return_status );

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add( ' Line id: '||l_line_ids_rec.line_id,5);
  END IF;

  IF NOT X_Update_Allowed THEN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add( ' Checking if Update is allowed',5);
    END IF;
    l_Update_Allowed := Update_Allowed(P_Line_id => l_line_ids_rec.line_id);
    IF l_Update_Allowed THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( ' Update is Allowed',5);
      END IF;
      X_Update_Allowed := TRUE;
    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' Update is Not Allowed for this requisition line',1);
      END IF;
    END IF;
  END IF;

  IF NOT X_Cancel_Allowed THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Checking if Cancel is allowed',5);
    END IF;
    l_Cancel_Allowed := Cancel_Allowed(p_line_id => l_line_ids_rec.line_id);

    IF l_Cancel_Allowed THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add( ' Cancel is Allowed',5);
      END IF;
      X_Cancel_Allowed := TRUE;
    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' Cancel is Not Allowed for this requisition line',1);
      END IF;
    END IF;
  END IF;

  -- OE_MSG_PUB.Reset_Msg_Context('LINE');
  -- Not resetting the message because it was never initialized
  -- Same is the case in Exception block

  <<SKIP_REQ_LINE_CHK>>
  null;

  IF l_debug_level  > 0 THEN
    IF X_Update_Allowed THEN
      oe_debug_pub.add(  ' Record is allowed to Update',5);
    END IF;
    IF X_Cancel_Allowed THEN
      oe_debug_pub.add(  ' Record is allowed to Cancel',5);
    END IF;
  END IF;

  x_return_status := l_return_status;

  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_Internal_Requisition_Pvt.Is_IReq_Changable', 1 ) ;
  END IF;

-- Added for 8583903
oe_debug_pub.debug_off;
oe_Debug_pub.setdebuglevel(0);

Exception
  WHEN FND_API.G_EXC_ERROR THEN
    -- OE_MSG_PUB.Reset_Msg_Context('LINE');
    x_return_status := FND_API.G_RET_STS_ERROR;
    X_Update_Allowed := FALSE;
    X_Cancel_Allowed := FALSE;
  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);

    -- Added for 8583903
    oe_debug_pub.debug_off;
    oe_Debug_pub.setdebuglevel(0);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- OE_MSG_PUB.Reset_Msg_Context('LINE');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    X_Update_Allowed := FALSE;
    X_Cancel_Allowed := FALSE;
  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);

    -- Added 8583903
    oe_debug_pub.debug_off;
    oe_Debug_pub.setdebuglevel(0);

  WHEN OTHERS THEN
    oe_debug_pub.add(  ' When Others of OE_Internal_Requisition_Pvt.Is_IReq_Changable '||sqlerrm,1);
    -- OE_MSG_PUB.Reset_Msg_Context('LINE');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    X_Update_Allowed := FALSE;
    X_Cancel_Allowed := FALSE;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Is_IReq_Changable');
      -- Pkg Body global variable = 'OE_internal_Requisition_Pvt'
    END IF;
  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);

    -- Added for 8583903
    oe_debug_pub.debug_off;
    oe_Debug_pub.setdebuglevel(0);

End Is_IReq_Changable;

--Bug 19273040 overrloaded
Procedure Call_Process_Order_for_IReq  -- Body definition
(  P_API_Version             IN  NUMBER
,  P_internal_req_line_id    IN PO_Requisition_Lines_All.Requisition_Line_id%TYPE
,  P_internal_req_header_id  IN PO_Requisition_Headers_All.Requisition_Header_id%TYPE
,  P_Mode                    IN  VARCHAR2
,  P_Cancel_ISO              IN  BOOLEAN
,  P_Cancel_ISO_lines        IN  BOOLEAN
,  P_New_Request_Date        IN  DATE
,  P_Delta_Ordered_Qty       IN  NUMBER
,  X_msg_count               OUT NOCOPY NUMBER
,  X_msg_data                OUT NOCOPY VARCHAR2
,  X_return_status	         OUT NOCOPY VARCHAR2
)
IS
l_new_needby_date DATE;
BEGIN

   --call the overloaded procedure
   Call_Process_Order_for_IReq  -- Body definition
   (  P_API_Version             => P_API_Version
   ,  P_internal_req_line_id    => P_internal_req_line_id
   ,  P_internal_req_header_id  => P_internal_req_header_id
   ,  P_Mode                    => P_Mode
   ,  P_Cancel_ISO              => P_Cancel_ISO
   ,  P_Cancel_ISO_lines        => P_Cancel_ISO_lines
   ,  P_New_Request_Date        => P_New_Request_Date
   ,  P_Delta_Ordered_Qty       => P_Delta_Ordered_Qty
   ,  X_msg_count               => X_msg_count
   ,  X_msg_data                => X_msg_data
   ,  X_return_status	         => X_return_status
   ,  x_new_needby_date         => l_new_needby_date );

END Call_Process_Order_for_IReq;

Procedure Call_Process_Order_for_IReq  -- Body definition
(  P_API_Version             IN  NUMBER
,  P_internal_req_line_id    IN PO_Requisition_Lines_All.Requisition_Line_id%TYPE
,  P_internal_req_header_id  IN PO_Requisition_Headers_All.Requisition_Header_id%TYPE
,  P_Mode                    IN  VARCHAR2
,  P_Cancel_ISO              IN  BOOLEAN
,  P_Cancel_ISO_lines        IN  BOOLEAN
,  P_New_Request_Date        IN  DATE
,  P_Delta_Ordered_Qty       IN  NUMBER
,  X_msg_count               OUT NOCOPY NUMBER
,  X_msg_data                OUT NOCOPY VARCHAR2
,  X_return_status	         OUT NOCOPY VARCHAR2
,  x_new_needby_date         OUT NOCOPY DATE --Bug 19273040
) IS
--
CURSOR All_Order_Lines (v_order_header_id NUMBER) IS
select l.line_id, l.header_id, l.ordered_quantity2
from   oe_order_lines_all l
--     , oe_order_headers_all h
where  nvl(l.shipped_quantity,0) = 0
-- and    h.orig_sys_document_ref = p_internal_req_header_id
-- and    h.order_source_id = OE_Globals.G_ORDER_SOURCE_INTERNAL
-- and    h.header_id = v_order_header_id
-- and    h.header_id = l.header_id
and    l.source_document_id = p_internal_req_header_id
and    l.order_source_id = OE_Globals.G_ORDER_SOURCE_INTERNAL
and    l.header_id = v_order_header_id
-- and    h.open_flag = 'Y'
and    nvl(cancelled_flag,'N') = 'N'
and    l.open_flag = 'Y'
and    not exists (select 1 from wsh_delivery_details w
                   where  w.source_line_id = l.line_id
                   and    w.source_code = 'OE'
                   and    released_status = 'C')
order by l.line_id;
--
l_API_name    Constant Varchar2(30) := 'CALL_PROCESS_ORDER_FOR_IREQ';
l_API_version Constant Number       := 1.0;
--
l_req_hdr_id    PO_Requisition_Headers_All.Requisition_Header_id%TYPE;
l_line_ids_rec	 Line_Id_rec_Type;
l_line_orig_rec OE_Order_PUB.Line_Rec_Type := OE_ORDER_PUB.G_MISS_LINE_REC;
l_line_tbl      OE_Order_PUB.Line_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_TBL;
l_control_rec   OE_GLOBALS.Control_Rec_Type;
l_return_status VARCHAR2(1);
l_header_rec    OE_Order_PUB.Header_Rec_Type := OE_ORDER_PUB.G_MISS_HEADER_REC;
l_old_header_rec OE_ORDER_PUB.Header_Rec_Type := OE_ORDER_PUB.G_MISS_HEADER_REC;
l_line_id       NUMBER;
l_header_id     NUMBER;
l_order_header_id NUMBER;
l_line_ord_qty2 NUMBER;
l_lin_update    NUMBER := 0;
l_lin_cancel    NUMBER := 0;
l_lines_ctr     NUMBER := 0;
l_cancel_eligble_lin NUMBER := 0;
l_count_of_lines     NUMBER;
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_cancel_request      BOOLEAN := FALSE;
l_Process_Line_Entity BOOLEAN := FALSE;
l_Cancel_Allowed      BOOLEAN := FALSE;
--
-- Added for 8583903
l_file_val  VARCHAR2(2000);
l_debug_level NUMBER := oe_debug_pub.g_debug_level;
--
l_sch_arrival_date DATE; --Bug 19273040
l_need_by_date     DATE; --Bug 19273040
Begin

-- Added IF condition for 8583903
IF (g_fnd_debug = 'Y') THEN

  oe_debug_pub.debug_on;
  oe_debug_pub.initialize;
  l_file_val    := OE_DEBUG_PUB.Set_Debug_Mode('FILE'); -- Dir/File
  oe_Debug_pub.setdebuglevel(5);

  l_debug_level := oe_debug_pub.g_debug_level;

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string( log_level => FND_LOG.LEVEL_STATEMENT
                , module    => 'po.plsql.'||G_PKG_Name||'.'||l_API_name
		, message   => '*** The Order Mangement Debug Log Dir/File is '||l_file_val);
  END IF;
END IF;

  IF Not FND_API.Compatible_API_Call
         ( l_API_version
         , p_API_version
         , l_API_name
         , G_PKG_Name) THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  SavePoint Call_Process_Order_for_IReq;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_Internal_Requisition_Pvt.Call_Process_Order_for_IReq', 1 ) ;
    oe_debug_pub.add(  ' P_internal_req_line_id :'||P_internal_req_line_id , 5 ) ;
    oe_debug_pub.add(  ' P_internal_req_header_id :'||P_internal_req_header_id , 5 ) ;
    oe_debug_pub.add(  ' P_Mode :'||P_Mode , 5 ) ;
    oe_debug_pub.add(  ' P_New_Request_Date :'||P_New_Request_Date , 5 ) ;
    oe_debug_pub.add(  ' P_Delta_Ordered_Qty :'||P_Delta_Ordered_Qty , 5 ) ;
    IF P_Cancel_ISO THEN
      oe_debug_pub.add(  ' Header level cancellation',5);
    ELSE
      oe_debug_pub.add(  ' Not a header level cancellation',5);
    END IF;
    IF P_Cancel_ISO_Lines THEN
      oe_debug_pub.add(  ' Line level cancellation',5);
    ELSE
      oe_debug_pub.add(  ' Not a line level cancellation',5);
    END IF;
  END IF;

  -- OE_MSG_PUB.set_msg_context();
  -- No need to set the message context as the caller of this API is PO
  -- and Message window is not applicable in Requesting organization

  OE_msg_PUB.Initialize;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (NOT P_Cancel_ISO AND NOT P_Cancel_ISO_Lines AND
      P_New_Request_Date is NULL AND P_Delta_Ordered_Qty = 0) OR
     (P_Cancel_ISO AND P_Cancel_ISO_Lines) OR
     (P_Cancel_ISO AND P_internal_req_header_id is null) OR
     (P_Cancel_ISO_Lines AND P_internal_req_line_id is null) OR
     (NOT P_Cancel_ISO AND P_internal_req_line_id is NULL) OR
     (P_internal_req_header_id is null AND P_internal_req_line_id is null) OR
     (P_Cancel_ISO AND P_New_Request_Date IS NOT NULL) OR
     (P_Cancel_ISO AND P_Delta_Ordered_Qty IS NOT NULL AND P_Delta_Ordered_Qty <> 0) OR
     (P_Cancel_ISO_Lines AND P_New_Request_Date IS NOT NULL) OR
     (P_Cancel_ISO_Lines AND P_Delta_Ordered_Qty IS NOT NULL AND P_Delta_Ordered_Qty <> 0) OR
     (P_New_Request_Date IS NOT NULL AND P_internal_req_line_id IS NULL) OR
     (P_Delta_Ordered_Qty IS NOT NULL AND P_Delta_Ordered_Qty <> 0 AND P_internal_req_line_id IS NULL) THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Invalid call to Order Management', 5 ) ;
      oe_debug_pub.add( ' Please provide a valid argument values', 5 ) ;
    END IF;
    FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_OM_CALL');
    OE_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF P_Mode NOT IN ('V','P') THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add( ' Mode is Invalid. The Valid values are V or P', 1 ) ;
      oe_debug_pub.add( ' Invalid Mode passed to Fulfillment Organization',5);
    END IF;
    FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_MODE');
    OE_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF P_internal_req_header_id is NULL THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' No value passed for Requisition Header',1);
    END IF;
    Begin
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( ' Retrieving Requisition Header id',5);
      END IF;
      select requisition_header_id
      into   l_req_hdr_id
      from   po_requisition_lines_all
      where  requisition_line_id = P_internal_req_line_id;

      IF l_req_hdr_id IS NULL THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add( ' Invalid value for Requisition Header',5);
        END IF;
        FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_REQ_HDR');
        -- FND_Message.Set_Token('REQ_HDR_ID',P_internal_req_header_id);
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    Exception
      When No_Data_Found Then
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add( ' Invalid value passed for Requisition Line',5);
        END IF;
        FND_Message.Set_Name('ONT', 'OE_IRCMS_INVALID_REQ_LIN');
        -- FND_Message.Set_Token('REQ_LIN_ID',P_internal_req_line_id);
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    End;
  ELSE
    l_req_hdr_id := P_internal_req_header_id;
  END IF;

  G_Update_ISO_From_Req := TRUE; -- Confirming IR initiated change

  l_lin_update := 0;

  IF P_Cancel_ISO THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add(' Order level cancellation request',5);
    END IF;

    Begin
      select header_id
      into   l_order_header_id
      from   oe_order_headers_all h
      where  h.source_document_id = l_req_hdr_id
      and    h.order_source_id = OE_Globals.G_ORDER_SOURCE_INTERNAL
      and    h.open_flag = 'Y';
    Exception
      WHEN No_Data_found THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add( ' Invalid value passed for Requisition Header: no data found',1);
        END IF;
        FND_Message.Set_name('ONT','OE_IRCMS_INVALID_REQ_HDR');
        RAISE FND_API.G_EXC_ERROR;
      WHEN Too_Many_Rows THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add( ' Invalid value passed for Requisition Header: too many rows',1);
        END IF;
        FND_Message.Set_name('ONT','OE_IRCMS_INVALID_REQ_HDR');
        RAISE FND_API.G_EXC_ERROR;
    End;

    l_Cancel_Allowed := Cancel_Header_Allowed( P_header_id => l_order_header_id);

    IF l_Cancel_Allowed THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( ' No Header level cancellation constraint',5);
      END IF;

      OPEN All_Order_Lines (l_order_header_id);
      LOOP
        FETCH All_Order_Lines INTO l_line_id, l_header_id, l_line_ord_qty2;
        EXIT WHEN All_Order_Lines%NOTFOUND;
        l_lines_ctr := l_lines_ctr + 1;
        IF Cancel_Allowed( p_Line_id => l_line_id) THEN

          l_cancel_eligble_lin := l_cancel_eligble_lin + 1;

          OE_LINE_UTIL.QUERY_ROW( p_line_id  => l_line_id
                                , x_line_rec => l_line_orig_rec);

          l_line_tbl(l_cancel_eligble_lin) := l_line_orig_rec;

          -- l_line_tbl(l_cancel_eligble_lin).line_id   := l_line_id;
          -- l_line_tbl(l_cancel_eligble_lin).header_id := l_header_id;
          l_line_tbl(l_cancel_eligble_lin).operation := OE_GLOBALS.G_OPR_UPDATE;
          l_line_tbl(l_cancel_eligble_lin).ordered_quantity  := 0;
          l_line_tbl(l_cancel_eligble_lin).change_reason := 'IR_ISO_CMS_CHG'; -- 'Internal requisition initiated change';
          IF (l_line_ord_qty2 IS NOT NULL AND l_line_ord_qty2 <> 0 ) THEN
            l_line_tbl(l_cancel_eligble_lin).ordered_quantity2 := 0;
          END IF;
        END IF;
        END LOOP;
      CLOSE All_Order_Lines;

      select count(line_id)
      into   l_count_of_lines
      from   oe_order_lines_all
      where  header_id = l_order_header_id
      and    nvl(cancelled_flag,'N') = 'N';

      IF l_cancel_eligble_lin > 0 OR l_count_of_lines = 0 THEN
        IF l_debug_level > 0 THEN
          oe_debug_pub.add('Order cancellation request is valid',5);
        END IF;

        IF l_count_of_lines = l_cancel_eligble_lin THEN

          IF l_debug_level > 0 THEN
            oe_debug_pub.add(' Cancel FULL Order request',5);
          END IF;

          OE_MSG_PUB.set_msg_context
          ( p_entity_code                  => 'HEADER'
          , p_entity_id                    => l_order_header_id
          , p_header_id                    => l_order_header_id
          , p_line_id                      => null
          , p_orig_sys_document_ref        => l_req_hdr_id
          , p_orig_sys_document_line_ref   => null
          , p_change_sequence              => null
          , p_source_document_id           => l_req_hdr_id
          , p_source_document_line_id      => null
          , p_order_source_id              => OE_Globals.G_ORDER_SOURCE_INTERNAL
          , p_source_document_type_id      => OE_Globals.G_ORDER_SOURCE_INTERNAL);

          OE_Header_Util.lock_Row
          ( p_header_id     => l_order_header_id
          , p_x_header_rec  => l_header_rec
          , x_return_status => l_return_status );

          l_old_header_rec := l_header_rec;

          l_header_rec.cancelled_flag :='Y';
          l_header_rec.change_reason  := 'IR_ISO_CMS_CHG'; --'Internal requisition initiated change';
          l_header_rec.operation      := OE_GLOBALS.G_OPR_UPDATE;

          l_control_rec.controlled_operation := TRUE;
          l_control_rec.default_attributes   := FALSE;

          IF p_mode = 'V' THEN
            l_control_rec.write_to_db := FALSE;
            l_control_rec.process := FALSE;
          END IF;

          OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can := TRUE;
          -- This global is required to be set to TRUE if it is an internal sales
          -- order level cancellation.

          oe_order_pvt.Header
          ( p_validation_level => FND_API.G_VALID_LEVEL_NONE
          , p_control_rec      => l_control_rec
          , p_x_header_rec     => l_header_rec
          , p_x_old_header_rec => l_old_header_rec
          , x_return_status    => l_return_status );


          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            OE_MSG_PUB.Reset_Msg_Context('HEADER');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            OE_MSG_PUB.Reset_Msg_Context('HEADER');
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF P_Mode = 'P' THEN -- Mode is Process
            OE_Order_PVT.Process_Requests_And_Notify
            ( p_process_requests => TRUE
            -- , p_notify           => FALSE -- Not needed
            , x_return_status    => l_return_status
            , p_header_rec       => l_header_rec
            , p_old_header_rec   => l_old_header_rec );


            x_return_status  := l_return_status;
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add( ' Return Status is '||l_return_status,1) ;
            END IF;
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  ' CANCELLATION UNEXPECTED FAILURE',1 ) ;
              END IF;
              OE_MSG_PUB.Reset_Msg_Context('HEADER');
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  ' CANCELLATION EXPECTED FAILURE',1 ) ;
              END IF;
              OE_MSG_PUB.Reset_Msg_Context('HEADER');
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF; -- P_Mode = PROCESS

          OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can := FALSE;
          -- Resetting the global to FALSE, as processing is done.

          OE_MSG_PUB.Reset_Msg_Context('HEADER');

        ELSIF l_count_of_lines > l_cancel_eligble_lin THEN
          IF l_debug_level > 0 THEN
            oe_debug_pub.add(' Cancel REMAINING Order request',5);
          END IF;
          l_Process_Line_Entity := TRUE;
          l_cancel_request := TRUE;
        END IF; -- l_count_of_lines = l_cancel_eligble_lin
      END IF;
    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add( ' There are Header level cancellation constraint',5);
      END IF;
      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF; -- P_Cancel_Order

  IF (P_New_Request_Date IS NOT NULL OR ( P_Delta_Ordered_Qty IS NOT NULL
  AND p_Delta_Ordered_Qty <> 0) OR P_Cancel_ISO_Lines) AND NOT l_Process_Line_Entity THEN

    Get_Eligible_ISO_Shipment
    (  P_internal_req_line_id   => P_internal_req_line_id
    ,  P_internal_req_header_id => l_req_hdr_id
    ,  X_line_ids_rec	     => l_line_ids_rec
    ,  X_return_status          => l_return_status );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF P_Cancel_ISO_Lines THEN
      IF l_debug_level > 0 THEN
        oe_debug_pub.add(' Line level Cancel request',5);
        oe_debug_pub.add(' Check for Cancel of Line_id '||l_line_ids_rec.line_id,5);
      END IF;
      IF Cancel_Allowed( p_Line_id => l_line_ids_rec.line_id) THEN
        l_lin_cancel := l_lin_cancel + 1;
        OE_LINE_UTIL.QUERY_ROW( p_line_id  => l_line_ids_rec.line_id
                              , x_line_rec => l_line_orig_rec);
        l_line_tbl(l_lin_cancel) := l_line_orig_rec;
        -- l_line_tbl(l_lin_cancel).line_id   := l_line_ids_rec.line_id;
        -- l_line_tbl(l_lin_cancel).header_id := l_line_ids_rec.header_id;
        l_line_tbl(l_lin_cancel).operation := OE_GLOBALS.G_OPR_UPDATE;
        l_line_tbl(l_lin_cancel).ordered_quantity  := 0;
        l_line_tbl(l_lin_cancel).change_reason := 'IR_ISO_CMS_CHG'; --'Internal requisition initiated change';
        IF (l_line_ids_rec.ordered_quantity2 IS NOT NULL
          AND l_line_ids_rec.ordered_quantity2 <> 0 ) THEN
          l_line_tbl(l_lin_cancel).ordered_quantity2 := 0;
        END IF;
        l_Process_Line_Entity := TRUE;
        l_cancel_request := TRUE;
      ELSE
        IF l_debug_level > 0 THEN
          oe_debug_pub.add(' Cancel is not allowed for this line. Setting the status to Error',5);
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    ELSIF P_New_Request_Date IS NOT NULL OR ( P_Delta_Ordered_Qty IS NOT NULL
      AND p_Delta_Ordered_Qty <> 0) THEN -- This is an update request

      IF l_debug_level > 0 THEN
        oe_debug_pub.add(' This is an Update request',5);
      END IF;

      IF P_New_Request_Date IS NOT NULL AND ( P_Delta_Ordered_Qty IS NULL
      OR p_Delta_Ordered_Qty = 0) THEN

        IF l_debug_level > 0 THEN
          oe_debug_pub.add(' Only Request Date is changed',5);
          oe_debug_pub.add(' Check if update is allowed for line_id '||l_line_ids_rec.line_id,5);
        END IF;
        IF NOT OE_Globals.Equal(P_New_Request_Date, l_line_ids_rec.request_date) AND
          Update_Allowed( p_Line_id   => l_line_ids_rec.line_id
                        , P_Attribute => 'REQUEST_DATE') THEN

          IF l_debug_level > 0 THEN
            oe_debug_pub.add(' Request Date is different w.r.t. sales order line ',5);
            oe_debug_pub.add(' Request Date is allowed to change',5);
          END IF;

          l_lin_update := l_lin_update + 1;

          OE_LINE_UTIL.QUERY_ROW( p_line_id  => l_line_ids_rec.line_id
                                , x_line_rec => l_line_orig_rec);
          l_line_tbl(l_lin_update) := l_line_orig_rec;

          -- l_line_tbl(l_lin_update).line_id   := l_line_ids_rec.line_id;
          -- l_line_tbl(l_lin_update).header_id   := l_line_ids_rec.header_id;
          l_line_tbl(l_lin_update).operation   := OE_GLOBALS.G_OPR_UPDATE;
          l_line_tbl(l_lin_update).request_date  := P_New_Request_Date;
          l_line_tbl(l_lin_update).change_reason := 'IR_ISO_CMS_CHG'; --'Internal requisition initiated change';

          l_Process_Line_Entity := TRUE;

        ELSE
          IF l_debug_level > 0 THEN
            oe_debug_pub.add(' Update is not allowed for this line. Setting the status to Error',5);
          END IF;
          l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

      ELSIF P_New_Request_Date IS NULL AND (P_Delta_Ordered_Qty IS NOT NULL
      OR p_Delta_Ordered_Qty <> 0) THEN

        IF l_debug_level > 0 THEN
          oe_debug_pub.add(' Only Ordered Quantity is changed',5);
          oe_debug_pub.add(' Check for update of Line_id '||l_line_ids_rec.line_id,5);
        END IF;
        IF Update_Allowed( p_Line_id   => l_line_ids_rec.line_id
                         , P_Attribute => 'ORDERED_QUANTITY') THEN

          l_lin_update := l_lin_update + 1;

          OE_LINE_UTIL.QUERY_ROW( p_line_id  => l_line_ids_rec.line_id
                                , x_line_rec => l_line_orig_rec);
          l_line_tbl(l_lin_update) := l_line_orig_rec;

          -- l_line_tbl(l_lin_update).line_id     := l_line_ids_rec.line_id;
          -- l_line_tbl(l_lin_update).header_id   := l_line_ids_rec.header_id;
          l_line_tbl(l_lin_update).ordered_quantity := l_line_ids_rec.ordered_quantity + P_Delta_Ordered_Qty;
          l_line_tbl(l_lin_update).operation     := OE_GLOBALS.G_OPR_UPDATE;
          l_line_tbl(l_lin_update).change_reason := 'IR_ISO_CMS_CHG'; --'Internal requisition initiated change';

          l_Process_Line_Entity := TRUE;

        ELSE
          IF l_debug_level > 0 THEN
            oe_debug_pub.add(' Update is not allowed for this line. Setting the status to Error',5);
          END IF;
          l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

      ELSIF P_New_Request_Date IS NOT NULL AND (P_Delta_Ordered_Qty IS NOT NULL
      OR p_Delta_Ordered_Qty <> 0) THEN

        IF l_debug_level > 0 THEN
          oe_debug_pub.add(' Both Request Date and Ordered Quantity are changed',5);
          oe_debug_pub.add(' Check for update of Line_id '||l_line_ids_rec.line_id,5);
        END IF;
        IF NOT OE_Globals.Equal(P_New_Request_Date, l_line_ids_rec.request_date) AND
           Update_Allowed( p_Line_id   => l_line_ids_rec.line_id
                         , P_Attribute => 'ALL') THEN

          l_lin_update := l_lin_update + 1;

          OE_LINE_UTIL.QUERY_ROW( p_line_id  => l_line_ids_rec.line_id
                                , x_line_rec => l_line_orig_rec);
          l_line_tbl(l_lin_update) := l_line_orig_rec;

          -- l_line_tbl(l_lin_update).line_id     := l_line_ids_rec.line_id;
          -- l_line_tbl(l_lin_update).header_id   := l_line_ids_rec.header_id;
          l_line_tbl(l_lin_update).ordered_quantity := l_line_ids_rec.ordered_quantity + P_Delta_Ordered_Qty;
          l_line_tbl(l_lin_update).operation   := OE_GLOBALS.G_OPR_UPDATE;
          l_line_tbl(l_lin_update).request_date  := P_New_Request_Date;
          l_line_tbl(l_lin_update).change_reason := 'IR_ISO_CMS_CHG'; --'Internal requisition initiated change';

          l_Process_Line_Entity := TRUE;
        ELSE
          IF l_debug_level > 0 THEN
            oe_debug_pub.add(' Update is not allowed for this line. Setting the status to Error',5);
          END IF;
          l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF; -- P_New_Request_Date/P_Delta_Ordered_Qty
    END IF; -- something has changed
  END IF; -- Update/Cancel Request

  IF l_Process_Line_Entity THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' Before calling Process_Line_Entity', 5 ) ;
    END IF;

    OE_MSG_PUB.set_msg_context
    ( p_entity_code                  => 'LINE'
    , p_entity_id                    => l_line_ids_rec.line_id
    , p_header_id                    => l_line_ids_rec.header_id
    , p_line_id                      => l_line_ids_rec.line_id
    , p_orig_sys_document_ref        => l_req_hdr_id
    , p_orig_sys_document_line_ref   => P_internal_req_line_id
    , p_change_sequence              => null
    , p_source_document_id           => l_req_hdr_id
    , p_source_document_line_id      => P_internal_req_line_id
    , p_order_source_id              => OE_Globals.G_ORDER_SOURCE_INTERNAL
    , p_source_document_type_id      => OE_Globals.G_ORDER_SOURCE_INTERNAL);

    Process_Line_Entity
    ( p_line_tbl          => l_line_tbl
    , p_mode              => P_mode
    , p_Cancel            => l_cancel_request
    , x_return_status     => l_return_status
    );

    OE_MSG_PUB.Reset_Msg_Context('LINE');

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' After calling Process_Line_Entity'||l_return_status, 5 ) ;
    END IF;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  x_return_status := l_return_status;
  G_Update_ISO_From_Req := FALSE; -- Confirming IR initiated change

  --Bug 19273040 Start
  --Check for a difference in SAD vs NBD due to ATP giving new date
  x_new_needby_date := NULL; --Get the new SAD if the line will rescheduled.
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'Checking if a value needs to be passed in x_new_needby_date', 5 ) ;
  END IF;

  IF (P_New_Request_Date IS NOT NULL OR ( P_Delta_Ordered_Qty IS NOT NULL  AND p_Delta_Ordered_Qty <> 0) )
  AND NOT P_CANCEL_ISO --not a header level cancellation
  AND l_Process_Line_Entity --line has been changed
  THEN
     begin
         select schedule_arrival_date
         into   l_sch_arrival_date
         from   oe_order_lines_all
         where  line_id = l_line_ids_rec.line_id;

         select prl.need_by_date
         into   l_need_by_date
         from  po_requisition_lines_all prl
         where  prl.requisition_line_id = P_internal_req_line_id;
       EXCEPTION
       WHEN OTHERS THEN
         l_sch_arrival_date := null;
       END;

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Old SAD on Order Line: ' || l_line_ids_rec.sch_arrival_date, 5 ) ;
          oe_debug_pub.add(  'New SAD on Order Line: ' || l_sch_arrival_date, 5 );
          oe_debug_pub.add(  'Need by date on IR Line: ' || l_need_by_date, 5 ) ;
          oe_debug_pub.add(  'Passed Need by date : ' || P_New_Request_Date, 5 ) ;
       END IF;

       IF  l_sch_arrival_date IS NOT NULL AND
           Trunc(l_sch_arrival_date) <> Trunc(nvl(P_New_Request_Date,l_need_by_date)) AND --check ISO vs IR
           Trunc(l_sch_arrival_date) <> Trunc(l_line_ids_rec.sch_arrival_date) THEN --check with old SAD
           x_new_needby_date := l_sch_arrival_date;
       END IF;
  END IF;
  --What about when lines are in set, and change of one line's SAD will change all lines SAD but only one NBD will propagate.
  --Bug 19273040 END

  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_Internal_Requisition_Pvt.Call_Process_Order_for_IReq', 1 ) ;
  END IF;

-- Added for 8583903
oe_debug_pub.debug_off;
oe_Debug_pub.setdebuglevel(0);

Exception
  WHEN FND_API.G_EXC_ERROR THEN
    -- OE_MSG_PUB.Reset_Msg_Context('LINE');
    x_return_status := FND_API.G_RET_STS_ERROR;
  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);
    G_Update_ISO_From_Req := FALSE; -- Confirming IR initiated change
    ROLLBACK TO Call_Process_Order_for_IReq;

    -- Added for 8583903
    oe_debug_pub.debug_off;
    oe_Debug_pub.setdebuglevel(0);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- OE_MSG_PUB.Reset_Msg_Context('LINE');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);
    G_Update_ISO_From_Req := FALSE; -- Confirming IR initiated change
    ROLLBACK TO Call_Process_Order_for_IReq;

    -- Added for 8583903
    oe_debug_pub.debug_off;
    oe_Debug_pub.setdebuglevel(0);

  WHEN OTHERS THEN
    oe_debug_pub.add(  ' When Others of OE_Internal_Requisition_Pvt.Call_Process_Order_for_IReq '||sqlerrm,1);
    -- OE_MSG_PUB.Reset_Msg_Context('LINE');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Call_Process_Order_for_IReq');
      -- Pkg Body global variable = 'OE_internal_Requisition_Pvt'
    END IF;
  OE_MSG_PUB.Count_And_Get (P_encoded =>'F',   --added for bug 13992154
                            P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);
    G_Update_ISO_From_Req := FALSE; -- Confirming IR initiated change
    ROLLBACK TO Call_Process_Order_for_IReq;

    -- Added for 8583903
    oe_debug_pub.debug_off;
    oe_Debug_pub.setdebuglevel(0);

End Call_Process_Order_for_IReq;

END OE_INTERNAL_REQUISITION_PVT;

/
