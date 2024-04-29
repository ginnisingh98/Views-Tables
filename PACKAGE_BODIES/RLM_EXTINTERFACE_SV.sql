--------------------------------------------------------
--  DDL for Package Body RLM_EXTINTERFACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_EXTINTERFACE_SV" as
/*$Header: RLMEINTB.pls 120.5.12010000.2 2010/01/21 11:26:37 sunilku ship $*/
/*===========================================================================*/

--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
g_wheretab RLM_CORE_SV.t_dynamic_tab;
--
/*==============================================================================

PROCEDURE BuildOELineTab(x_Op_tab IN rlm_rd_sv.t_generic_tab,
			 x_return_status OUT NOCOPY VARCHAR2)

==============================================================================*/

PROCEDURE BuildOELineTab(x_Op_tab IN rlm_rd_sv.t_generic_tab, x_return_status out NOCOPY VARCHAR2)
IS

  x_linecount NUMBER;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'BuildOELineTab');
     rlm_core_sv.dlog(k_DEBUG,'no of lines in oe interface table',
                            x_Op_Tab.COUNT);
  END IF;
  --
  x_return_status := 'S';
  g_oe_line_tbl.delete;
  --
  FOR counter IN 1..x_Op_Tab.COUNT LOOP
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'Loading the oe lines tables PL/SQL table: ', counter );
     END IF;
     --
     x_linecount := counter;
     --
     g_oe_line_tbl(x_linecount) := oe_order_pub.g_miss_line_rec;
     --
     RLM_TPA_SV.BuildOELine(g_oe_line_tbl(x_linecount),x_Op_tab(counter));
     RLM_TPA_SV.BuildTpOELine(g_oe_line_tbl(x_linecount),x_Op_tab(counter));
     --
  END LOOP;
  --
  x_return_status := 'S';
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
    --
    WHEN OTHERS THEN
        --
        x_return_status := 'E';
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'When Other Exception',substr(sqlerrm,1,200));
           rlm_core_sv.dpop(k_SDEBUG);
        END IF;

END BuildOELineTab;


/*===========================================================================
 PROCEDURE ProcessOperation(x_Op_tab IN rlm_rd_sv.t_generic_tab,
			    x_header_id IN NUMBER,
			    x_return_status IN OUT NOCOPY VARCHAR2)

===========================================================================*/
PROCEDURE ProcessOperation(x_Op_tab IN rlm_rd_sv.t_generic_tab,
                           x_header_id IN NUMBER,
                           x_return_status IN OUT NOCOPY VARCHAR2)
IS
  --
  x_msg_count            NUMBER;
  l_return_status        VARCHAR2(1);
  x_msg_data             VARCHAR2(4000);
  x_oe_api_version       NUMBER:=1;
  e_BuildOELineTab       EXCEPTION;
  e_ProcessOrderFailed   EXCEPTION;
  v_DebugMode            NUMBER;
  v_FileName             VARCHAR2(2000);
  l_control_rec          OE_GLOBALS.Control_Rec_Type := OE_GLOBALS.G_MISS_CONTROL_REC;
  l_line_adj_tbl         OE_Order_PUB.Line_Adj_Tbl_Type;
  v_line_id              NUMBER;
  x_msg_name             FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
  x_token                FND_NEW_MESSAGES.TYPE%TYPE;
  v_msg_text             VARCHAR2(32000);
  l_start_time           NUMBER;
  l_end_time             NUMBER;
  l_oe_line_tbl_out      oe_order_pub.line_tbl_type;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'ProcessOperation');
  END IF;
  --
  BuildOELineTab(x_Op_Tab,x_Return_Status);
  --
  IF x_Return_Status = 'E' THEN
     raise e_BuildOELineTab;
  END IF;
  --
  IF g_oe_line_tbl.count >0 THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'starting insert oe lines');
     END IF;
     --
     fnd_profile.get(rlm_core_sv.C_DEBUG_PROFILE, v_DebugMode);
     --
     oe_debug_pub.add('Calling Process_order from DSP',1);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'RLM DEBUG PROFILE :',v_DebugMode);
        rlm_core_sv.dlog(k_DEBUG,'IS OM Debug On:', OE_DEBUG_PUB.IsDebugOn);
        rlm_core_sv.dlog(k_DEBUG,'OM Debug Level:', to_char(OE_DEBUG_PUB.G_DEBUG_LEVEL));
        rlm_core_sv.dlog(k_DEBUG,'G_UI_FLAG',OE_GLOBALS.G_UI_FLAG);
        rlm_core_sv.dlog(k_DEBUG,'G_DEBUG_MODE',OE_DEBUG_PUB.G_DEBUG_MODE);
        rlm_core_sv.dlog(k_DEBUG,'See OE DEBUG FILE for details on process Order API errors');
        rlm_core_sv.dlog(k_DEBUG,'Om Debug File dir:',OE_DEBUG_PUB.G_DIR);
     END IF;
     --
     v_FileName := OE_DEBUG_PUB.set_debug_mode ('FILE');
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'Om Debug File name:',v_FileName);
     END IF;
     --
     -- This setting ensures the pl/sql table returned by Process
     -- order api contains messages from workflow scheduling activities

     OE_STANDARD_WF.Save_Messages_Off;
     --
     /* setting the debug mode back CONC so we could see
        the debug messages in both the log file and the request log */
     --
     v_FileName := OE_DEBUG_PUB.set_debug_mode ('CONC');
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'x_Op_tab(1).schedule_type', x_Op_tab(1).schedule_type);
     END IF;
     --
     SELECT hsecs INTO l_start_time from v$timer;
     --
     IF x_Op_tab(1).schedule_type <> k_SEQUENCED THEN
        --
        OE_Order_GRP.Process_order
        (   p_api_version_number          => x_oe_api_version
        ,   p_init_msg_list               => FND_API.G_TRUE
        ,   p_return_values               => FND_API.G_FALSE
        ,   p_commit                      => FND_API.G_FALSE
        ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
        ,   p_control_rec		 => OE_GLOBALS.G_MISS_CONTROL_REC
        ,   p_api_service_level		 => OE_GLOBALS.G_ALL_SERVICE
        ,   x_return_status               => l_return_status
        ,   x_msg_count                   => x_msg_count
        ,   x_msg_data                    => x_msg_data
        ,   p_line_tbl                    => g_oe_line_tbl
        ,   x_header_rec                  => g_oe_header_out_rec
        ,   x_header_val_rec              => g_oe_header_val_out_rec
        ,   x_Header_Adj_tbl              => g_oe_Header_Adj_out_tbl
        ,   x_Header_Adj_val_tbl          => g_oe_Header_Adj_val_out_tbl
        ,   x_Header_price_Att_tbl        => g_oe_Header_price_Att_out_tbl
        ,   x_Header_Adj_Att_tbl          => g_oe_Header_Adj_Att_out_tbl
        ,   x_Header_Adj_Assoc_tbl        => g_oe_Header_Adj_Assoc_out_tbl
        ,   x_Header_Scredit_tbl          => g_oe_Header_Scredit_out_tbl
        ,   x_Header_Scredit_val_tbl      => g_oe_Hdr_Scdt_val_out_tbl
        ,   x_line_tbl                    => l_oe_line_tbl_out
        ,   x_line_val_tbl                => g_oe_line_val_out_tbl
        ,   x_Line_Adj_tbl                => g_oe_line_Adj_out_tbl
        ,   x_Line_Adj_val_tbl            => g_oe_line_Adj_val_out_tbl
        ,   x_Line_price_Att_tbl          => g_oe_Line_price_Att_out_tbl
        ,   x_Line_Adj_Att_tbl            => g_oe_Line_Adj_Att_out_tbl
        ,   x_Line_Adj_Assoc_tbl          => g_oe_Line_Adj_Assoc_out_tbl
        ,   x_Line_Scredit_tbl            => g_oe_line_scredit_out_tbl
        ,   x_Line_Scredit_val_tbl        => g_oe_line_scredit_val_out_tbl
        ,   x_Lot_Serial_tbl              => g_oe_lot_serial_out_tbl
        ,   x_Lot_Serial_val_tbl          => g_oe_lot_serial_val_out_tbl
        ,   x_Action_Request_tbl          => g_oe_Action_Request_out_Tbl
        );
        --
     ELSE
        --
        l_control_rec.controlled_operation := TRUE;
        l_control_rec.process_partial := TRUE;
        --
        OE_Order_GRP.Process_order
        (   p_api_version_number          => x_oe_api_version
        ,   p_init_msg_list               => FND_API.G_TRUE
        ,   p_control_rec                 => l_control_rec
        ,   x_return_status               => l_return_status
        ,   x_msg_count                   => x_msg_count
        ,   x_msg_data                    => x_msg_data
        ,   p_line_tbl                    => g_oe_line_tbl
        ,   p_line_adj_tbl	           => l_line_adj_tbl
        ,   x_header_rec                  => g_oe_header_out_rec
        ,   x_header_val_rec              => g_oe_header_val_out_rec
        ,   x_Header_Adj_tbl              => g_oe_Header_Adj_out_tbl
        ,   x_Header_Adj_val_tbl          => g_oe_Header_Adj_val_out_tbl
        ,   x_Header_price_Att_tbl        => g_oe_Header_price_Att_out_tbl
        ,   x_Header_Adj_Att_tbl          => g_oe_Header_Adj_Att_out_tbl
        ,   x_Header_Adj_Assoc_tbl        => g_oe_Header_Adj_Assoc_out_tbl
        ,   x_Header_Scredit_tbl          => g_oe_Header_Scredit_out_tbl
        ,   x_Header_Scredit_val_tbl      => g_oe_Hdr_Scdt_val_out_tbl
        ,   x_line_tbl                    => l_oe_line_tbl_out
        ,   x_line_val_tbl                => g_oe_line_val_out_tbl
        ,   x_Line_Adj_tbl                => g_oe_line_Adj_out_tbl
        ,   x_Line_Adj_val_tbl            => g_oe_line_Adj_val_out_tbl
        ,   x_Line_price_Att_tbl          => g_oe_Line_price_Att_out_tbl
        ,   x_Line_Adj_Att_tbl            => g_oe_Line_Adj_Att_out_tbl
        ,   x_Line_Adj_Assoc_tbl          => g_oe_Line_Adj_Assoc_out_tbl
        ,   x_Line_Scredit_tbl            => g_oe_line_scredit_out_tbl
        ,   x_Line_Scredit_val_tbl        => g_oe_line_scredit_val_out_tbl
        ,   x_Lot_Serial_tbl              => g_oe_lot_serial_out_tbl
        ,   x_Lot_Serial_val_tbl          => g_oe_lot_serial_val_out_tbl
        ,   x_Action_Request_tbl          => g_oe_Action_Request_out_Tbl
        );
        --
     END IF;
     --
     SELECT hsecs INTO l_end_time from v$timer;
     --
     v_msg_text :='no of lines in g_oe_line_tbl -  '|| g_oe_line_tbl.LAST;
     fnd_file.put_line(fnd_file.log, v_msg_text);
     v_msg_text := 'Return Status - ' || l_return_status;
     fnd_file.put_line(fnd_file.log, v_msg_text);
     --
     v_msg_text :='Time spent in OE call - '|| (l_end_time-l_start_time)/100;
     fnd_file.put_line(fnd_file.log, v_msg_text);
     --
     x_return_status := l_return_status;
     --
     IF (l_debug <> -1) THEN
      --
      rlm_core_sv.dlog(k_DEBUG,'# of lines in input tbl',g_oe_line_tbl.LAST);
      rlm_core_sv.dlog(k_DEBUG,'# of lines in output table',l_oe_line_tbl_out.LAST);
      rlm_core_sv.dlog(k_DEBUG,'Process Order return Status',x_return_Status);
      rlm_core_sv.dlog(k_DEBUG,'Process Order Error Count',x_msg_count);
      rlm_core_sv.dlog(k_DEBUG,'Process Order Error',x_msg_data);
     END IF;
     --
     g_total_lines := g_total_lines + g_oe_line_tbl.LAST;
     g_total_time := g_total_time + ((l_end_time-l_start_time)/100);
     --
     v_msg_text := 'Total number of lines sent to OM - '||g_total_lines ;
     fnd_file.put_line(fnd_file.log, v_msg_text);
     v_msg_text := 'Total Time - ' || g_total_time;
     fnd_file.put_line(fnd_file.log, v_msg_text);
     --
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
        l_return_status = FND_API.G_RET_STS_ERROR THEN
        --
        RAISE e_ProcessOrderFailed;
        --
     END IF;
     --
     x_token := 'WARN';
     x_msg_name := 'RLM_PROCESS_ORDER_WARN';
     --
     InsertOMMessages(x_header_id,
                      x_Op_tab(1).customer_item_id,
                      x_msg_count,rlm_message_sv.k_warn_level,
                      x_token,
                      x_msg_name);
     --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG,'successful');
  END IF;
  --
  --x_return_status := 'E';
  --
EXCEPTION
    --
    WHEN e_ProcessOrderFailed THEN
       --
       x_token := 'ERROR';
       x_msg_name := 'RLM_OE_API_FAILED';
       --
       InsertOMMessages(x_header_id,
                        x_Op_tab(1).customer_item_id,
                        x_msg_count,rlm_message_sv.k_error_level,
                        x_token,
                        x_msg_name);
       --
       IF x_Op_tab(1).schedule_type = k_SEQUENCED THEN/*2342919*/
         --
         FOR s IN 1 .. l_oe_line_tbl_out.COUNT LOOP
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG, 'Line return status', l_oe_line_tbl_out(s).return_status);
           END IF;
           --
	   IF l_oe_line_tbl_out(s).return_status <> FND_API.G_RET_STS_SUCCESS THEN
             --
             UPDATE rlm_schedule_lines_all
	     SET process_status = rlm_core_sv.k_PS_ERROR
             WHERE line_id = l_oe_line_tbl_out(s).source_document_line_id;
             --
             BEGIN
                --
                UPDATE rlm_interface_lines_all
	        SET process_status = rlm_core_sv.k_PS_ERROR
                WHERE line_id =
                 (
                  SELECT interface_line_id
                  FROM rlm_schedule_lines_all
                  WHERE line_id = l_oe_line_tbl_out(s).source_document_line_id
                 );
		--
  		IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(k_DEBUG, 'No of Interface Lines updated', SQL%ROWCOUNT);
                END IF;
                --
             EXCEPTION
                --
                WHEN OTHERS THEN
		  --
  		  IF (l_debug <> -1) THEN
                     rlm_core_sv.dlog(k_DEBUG, 'Interface Line not found for
                    Source Document Line Id', l_oe_line_tbl_out(s).source_document_line_id);
                  END IF;
                  --
             END;
             --
           ELSE
             --
             UPDATE rlm_schedule_lines_all
	     SET process_status = rlm_core_sv.k_PS_PROCESSED
             WHERE line_id = l_oe_line_tbl_out(s).source_document_line_id;
             --
             BEGIN
                --
                UPDATE rlm_interface_lines_all
	        SET process_status = rlm_core_sv.k_PS_PROCESSED
                WHERE line_id =
                 (
                  SELECT interface_line_id
                  FROM rlm_schedule_lines_all
                  WHERE line_id = l_oe_line_tbl_out(s).source_document_line_id
                 );
                --
  		IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(k_DEBUG, 'No of Interface Lines updated', SQL%ROWCOUNT);
                END IF;
                --
             EXCEPTION
                --
                WHEN OTHERS THEN
		  --
  		  IF (l_debug <> -1) THEN
                     rlm_core_sv.dlog(k_DEBUG, 'Interface Line not found for
                    Source Document Line Id', l_oe_line_tbl_out(s).source_document_line_id);
                  END IF;
                  --
             END;
             --
           END IF;
           --
         END LOOP;
         --
       END IF;/*2342919*/
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(k_SDEBUG);
       END IF;
       --
    WHEN e_BuildOELineTab THEN
       --
       rlm_message_sv.app_error(
                 x_ExceptionLevel => rlm_message_sv.k_error_level,
                 x_MessageName => 'RLM_BUILD_OE_LINE_TAB',
                 x_InterfaceHeaderId => x_header_id,
                 x_InterfaceLineId => NULL,
                 x_ScheduleHeaderId => x_Op_Tab(1).schedule_header_id,
                 x_ScheduleLineId => NULL,
                 x_OrderHeaderId => NULL,
                 x_OrderLineId => NULL,
                 x_Token1 => 'ERROR',
                 x_value1 => substr(sqlerrm,1,200));
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG,'Build OE Line Tab returned failed', x_return_Status);
          rlm_core_sv.dlog(k_DEBUG,'Error',substr(sqlerrm,1,200));
          rlm_core_sv.dpop(k_SDEBUG);
       END IF;
       --
    WHEN OTHERS THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
       END IF;
       --
       raise;
       --
END ProcessOperation;

/*===========================================================================

          PROCEDURE    InsertOMMessages

===========================================================================*/

PROCEDURE InsertOMMessages(x_header_id IN NUMBER,
                           x_customer_item_id IN NUMBER,
                           x_msg_count  IN NUMBER,
                           x_msg_level  IN VARCHAR2,
                           x_token IN VARCHAR2,
                           x_msg_name IN VARCHAR2)
IS
  --
  x_msg                          VARCHAR2(4000);
  v_interface_line_id            NUMBER;
  v_schedule_header_id           NUMBER;
  v_order_header_id              NUMBER;
  v_request_date                 VARCHAR2(150);
  l_entity_code                  VARCHAR2(30);
  l_entity_ref                   VARCHAR2(50);
  l_entity_id                    NUMBER;
  l_header_id                    NUMBER;
  l_line_id                      NUMBER;
  l_order_source_id              NUMBER;
  l_orig_sys_document_ref        VARCHAR2(50);
  l_orig_sys_line_ref            VARCHAR2(50);
  l_orig_sys_shipment_ref        VARCHAR2(50);
  l_change_sequence              VARCHAR2(50);
  l_source_document_type_id      NUMBER;
  l_source_document_id           NUMBER;
  l_source_document_line_id      NUMBER;
  l_attribute_code               VARCHAR2(30);
  l_constraint_id                NUMBER;
  l_process_activity             NUMBER;
  l_transaction_id               NUMBER;
  l_notification_flag            VARCHAR2(1) := 'N' ;
  l_type                         VARCHAR2(30) ;
  l_msg_level                    VARCHAR2(10); -- 4129069
  v_PO_msg                       VARCHAR2(200);   -- Bug 4297984
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'InsertOMMessages');
     rlm_core_sv.dlog(k_DEBUG,'x_msg_count',x_msg_count);
     rlm_core_sv.dlog(k_DEBUG,'x_msg_name',x_msg_name);
     rlm_core_sv.dlog(k_DEBUG,'x_msg_level',x_msg_level);
     rlm_core_sv.dlog(k_DEBUG,'x_token',x_token);
     rlm_core_sv.dlog(k_DEBUG,'x_header_id',x_header_id);
     rlm_core_sv.dlog(k_DEBUG,'x_customer_item_id', x_customer_item_id);
     rlm_core_sv.dlog(k_DEBUG,'oe_msg_pub.count_msg',oe_msg_pub.count_msg);
  END IF;
  --
  -- Get message count and data
  -- Bug 4297984
  fnd_message.set_name ('ONT','OE_VAL_DUP_PO_NUMBER');
  v_PO_msg := fnd_message.get;
  --
  IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG,'v_PO_msg',v_PO_msg);
  END IF;
  --
  IF x_msg_count > 0 THEN
     --{
     FOR I in 1..x_msg_count LOOP
       --
       x_msg := oe_msg_pub.get(p_msg_index => I,
                               p_encoded => 'F');
       --
       IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'Message at index', I);
           rlm_core_sv.dlog(k_DEBUG,'Message Found', substr(x_msg,1,200));
           rlm_core_sv.dlog(k_DEBUG,'get message context');
       END IF;
       --
       IF (substr(x_msg,1,200) <> v_PO_msg) THEN -- Bug 4297984
          --
          oe_msg_pub.Get_msg_context(
                p_msg_index               => I
                ,x_entity_code             => l_entity_code
                ,x_entity_ref              => l_entity_ref
                ,x_entity_id               => l_entity_id
                ,x_header_id               => l_header_id
                ,x_line_id                 => l_line_id
                ,x_order_source_id         => l_order_source_id
                ,x_orig_sys_document_ref   => l_orig_sys_document_ref
                ,x_orig_sys_line_ref       => l_orig_sys_line_ref
                ,x_orig_sys_shipment_ref   => l_orig_sys_shipment_ref
                ,x_change_sequence         => l_change_sequence
                ,x_source_document_type_id => l_source_document_type_id
                ,x_source_document_id      => l_source_document_id
                ,x_source_document_line_id => l_source_document_line_id
                ,x_attribute_code          => l_attribute_code
                ,x_constraint_id           => l_constraint_id
                ,x_process_activity        => l_process_activity
                ,x_notification_flag       => l_notification_flag
                ,x_type                    => l_type
                );
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(k_DEBUG, 'schedule line',
                              l_source_document_line_id);
             rlm_core_sv.dlog(k_DEBUG, 'ProcessOrderAPI Error',
                               substr(x_msg,1,200));
          END IF;
          --
          IF NVL(l_source_document_line_id,FND_API.G_MISS_NUM) <>
                  FND_API.G_MISS_NUM THEN
             BEGIN
                 --
                 SELECT interface_line_id, header_id, order_header_id, industry_attribute2
                 INTO v_interface_line_id, v_schedule_header_id, v_order_header_id, v_request_date
                 FROM rlm_schedule_lines
                 WHERE line_id = l_source_document_line_id;
		 --
  		 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(k_DEBUG,'interface line',v_interface_line_id);
                 END IF;
                 --
             EXCEPTION
                 --
                 WHEN OTHERS THEN
		       --
  		       IF (l_debug <> -1) THEN
                          rlm_core_sv.dlog(k_DEBUG,'Could not get interface line');
                       END IF;
		       --
                  END;
          END IF;
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(k_DEBUG,'l_source_document_id', l_source_document_id);
             rlm_core_sv.dlog(k_DEBUG,'schedule_header_id', v_schedule_header_id);
             rlm_core_sv.dlog(k_DEBUG,'l_header_id', l_header_id);
             rlm_core_sv.dlog(k_DEBUG,'order_header_id', v_order_header_id);
             rlm_core_sv.dlog(k_DEBUG,'x_msg_level', x_msg_level);
             rlm_core_sv.dlog(k_DEBUG,'x_msg_name', x_msg_name);
          END IF;
	  --
          oe_debug_pub.add(substr(x_msg,1,200));
          --
          --
          -- Bug 4129069 : Set the message level depending on the seeded error
          -- type only if Process Order API returned Error Status.
          --
          IF x_msg_name = 'RLM_OE_API_FAILED' THEN
          --
          IF l_type = 'ERROR' THEN
             l_msg_level := x_msg_level;
          ELSE
             l_msg_level := rlm_message_sv.k_info_level;
          END IF;
          --
          ELSE
             l_msg_level := x_msg_level;
          END IF;
          --
          IF (l_debug<> -1) THEN
             rlm_core_sv.dlog(k_DEBUG, 'l_msg_level', l_msg_level);
          END IF;
          --
          rlm_message_sv.app_error(
                   x_ExceptionLevel => l_msg_level,
                   x_MessageName => x_msg_name,
                   x_InterfaceHeaderId => x_header_id,
                   x_InterfaceLineId => v_interface_line_id,
                   x_ScheduleHeaderId => v_schedule_header_id,
                   x_ScheduleLineId => l_source_document_line_id,
                   x_OrderHeaderId => l_header_id,
                   x_OrderLineId => l_line_id,
                   x_Token1 => x_token,
                   x_value1 => substr(x_msg,1,200),
                   x_Token2 => 'CUST_ITEM',
                   x_value2 =>  rlm_core_sv.get_item_number(x_customer_item_id),
                   x_Token3 => 'REQ_DATE',
                   x_value3 => v_request_date);
	  --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(k_DEBUG,'x_msg', substr(x_msg,1,200));
          END IF;
          --
       END IF; -- Bug 4297984
       --
     END LOOP;
     --}
   ELSIF (x_msg_count = 0 AND
         (x_msg_level = 'U' OR x_msg_level = 'E')) THEN
     --{
     IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG, 'Inserting RLM_PROCESS_ORDER_ERROR_E msg');
     END IF;
     --
     rlm_message_sv.app_error(
                    x_ExceptionLevel => rlm_message_sv.k_error_level,
                    x_MessageName => 'RLM_PROCESS_ORDER_ERROR_E',
                    x_InterfaceHeaderId => x_header_id,
                    x_InterfaceLineId => NULL,
                    x_ScheduleHeaderId => NULL,
                    x_ScheduleLineId => NULL,
                    x_OrderHeaderId => NULL,
                    x_OrderLineId => NULL,
                    x_Token1 => 'ERROR',
                    x_value1 => substr(sqlerrm,1,200),
                    x_Token2 => 'CUST_ITEM',
                    x_Value2 => rlm_core_sv.get_item_number(x_customer_item_id)
                    );
     --}
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(k_SDEBUG,'successful');
   END IF;
   --
EXCEPTION
   --
   WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
END InsertOMMessages;

/*===========================================================================

          FUNCTION       CallProcessConstraintAPI

===========================================================================*/

FUNCTION CallProcessConstraintAPI(x_Key_rec IN rlm_rd_sv.t_Key_rec,
                           x_Qty_rec OUT NOCOPY rlm_rd_sv.t_Qty_rec,
                           x_Operation IN VARCHAR2,
                           x_OperationQty IN NUMBER)
RETURN BOOLEAN
IS
  x_msg_count			NUMBER;
  x_msg				VARCHAR2(32000);
  l_return_status		VARCHAR2(1);
  x_msg_data			VARCHAR2(4000);
  x_oe_api_version		NUMBER:=1;
  x_api_service_level		VARCHAR2(30):= OE_GLOBALS.G_CHECK_SECURITY_ONLY;
  e_ProcessConstraint		EXCEPTION;
  l_control_rec			OE_GLOBALS.control_rec_type;
  l_line_rec			oe_order_pub.line_rec_type;
  l_line_tbl			oe_order_pub.Line_Tbl_Type;
  l_header_out_rec		oe_order_pub.Header_Rec_Type;
  l_header_adj_out_tbl		oe_order_pub.Header_Adj_Tbl_Type;
  l_header_val_rec		oe_order_pub.header_val_rec_type;
  l_header_adj_val_tbl		oe_order_pub.header_adj_val_tbl_type;
  l_Header_price_Att_out_tbl    oe_order_pub.Header_Price_Att_Tbl_Type;
  l_Header_Adj_Att_out_tbl      oe_order_pub.Header_Adj_Att_Tbl_Type;
  l_Header_Adj_Assoc_out_tbl    oe_order_pub.Header_Adj_Assoc_Tbl_Type;
  l_Header_Scredit_out_tbl	oe_order_pub.Header_Scredit_Tbl_Type;
  l_header_Scredit_val_tbl	oe_order_pub.header_Scredit_val_Tbl_Type;
  l_line_out_tbl		oe_order_pub.Line_Tbl_Type;
  l_line_val_tbl		oe_order_pub.Line_val_Tbl_Type;
  l_line_adj_val_tbl		oe_order_pub.line_Adj_val_Tbl_Type;
  l_line_adj_out_tbl		oe_order_pub.line_Adj_Tbl_Type;
  l_Line_price_Att_out_tbl      oe_order_pub.Line_price_Att_Tbl_Type;
  l_Line_Adj_Att_out_tbl        oe_order_pub.Line_Adj_Att_Tbl_Type;
  l_Line_Adj_Assoc_out_tbl      oe_order_pub.Line_Adj_Assoc_Tbl_Type;
  l_Line_Scredit_out_tbl	oe_order_pub.Line_Scredit_Tbl_Type;
  l_Line_Scredit_val_tbl	oe_order_pub.Line_Scredit_val_Tbl_Type;
  l_action_request_out_tbl      oe_order_pub.request_tbl_type;
  l_Lot_Serial_tbl		oe_order_pub.Lot_Serial_Tbl_Type;
  l_Lot_Serial_val_tbl		oe_order_pub.Lot_Serial_val_Tbl_Type;
  b_Result			BOOLEAN := FALSE;
  v_DebugMode                   NUMBER;
  x_api_version_number          NUMBER := 1;
  v_interface_line              NUMBER;
  x_msg_name                    FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
  x_token                       FND_NEW_MESSAGES.TYPE%TYPE;
  x_msg_level                   VARCHAR2(10);
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'CallProcessConstraintAPI');
     rlm_core_sv.dlog(k_DEBUG,'x_Operation',x_Operation);
  END IF;
  --
  l_line_tbl(1) := oe_order_pub.g_miss_line_rec;
  RLM_TPA_SV.BuildOELine(l_line_tbl(1),x_Key_rec.req_rec);
  l_line_tbl(1).line_id := x_Key_rec.dem_rec.line_id;
  l_line_tbl(1).operation := x_Operation;
  l_line_tbl(1).ordered_quantity := x_OperationQty;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'l_line_tbl(1).operation',
                            l_line_tbl(1).operation);
     rlm_core_sv.dlog(k_DEBUG,'l_line_tbl(1).line_id',
                            l_line_tbl(1).line_id);
     rlm_core_sv.dlog(k_DEBUG,'l_line_tbl(1).ordered_quantity',
                            l_line_tbl(1).ordered_quantity);
  END IF;
  --
  fnd_profile.get(rlm_core_sv.C_DEBUG_PROFILE, v_DebugMode);
  --
  oe_debug_pub.add('Calling Process_order from DSP');
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'IS OM Debug On:', OE_DEBUG_PUB.G_DEBUG);
     rlm_core_sv.dlog(k_DEBUG,'OM Debug Level:', to_char(OE_DEBUG_PUB.G_DEBUG_LEVEL));
     rlm_core_sv.dlog(k_DEBUG,'G_UI_FLAG',OE_GLOBALS.G_UI_FLAG);
     rlm_core_sv.dlog(k_DEBUG,'ISDebugOn',OE_DEBUG_PUB.ISDebugOn);
     rlm_core_sv.dlog(k_DEBUG,'G_DEBUG_MODE',OE_DEBUG_PUB.G_DEBUG_MODE);
     rlm_core_sv.dlog(k_DEBUG,'G_FILE',OE_DEBUG_PUB.G_FILE);
     rlm_core_sv.dlog(k_DEBUG,'See OE DEBUG FILE for process Constraints in DSP concurrent request log');
  END IF;
  --
  oe_order_grp.Process_order
    (   p_api_version_number          => x_api_version_number
    ,   p_api_service_level           => x_api_service_level
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_line_tbl                    => l_line_tbl
    ,   x_header_rec                  => l_header_out_rec
    ,   x_header_val_rec              => l_header_val_rec
    ,   x_Header_Adj_tbl              => l_Header_Adj_out_tbl
    ,   x_Header_Adj_val_tbl          => l_Header_Adj_val_tbl
    ,   x_Header_price_Att_tbl        => l_Header_price_Att_out_tbl
    ,   x_Header_Adj_Att_tbl          => l_Header_Adj_Att_out_tbl
    ,   x_Header_Adj_Assoc_tbl        => l_Header_Adj_Assoc_out_tbl
    ,   x_Header_Scredit_tbl          => l_Header_Scredit_out_tbl
    ,   x_Header_Scredit_val_tbl      => l_Header_Scredit_val_tbl
    ,   x_line_tbl                    => l_line_out_tbl
    ,   x_line_val_tbl                => l_line_val_tbl
    ,   x_Line_Adj_tbl                => l_Line_Adj_out_tbl
    ,   x_Line_Adj_val_tbl            => l_Line_Adj_val_tbl
    ,   x_Line_price_Att_tbl          => l_Line_price_Att_out_tbl
    ,   x_Line_Adj_Att_tbl            => l_Line_Adj_Att_out_tbl
    ,   x_Line_Adj_Assoc_tbl          => l_Line_Adj_Assoc_out_tbl
    ,   x_Line_Scredit_tbl            => l_Line_Scredit_out_tbl
    ,   x_Line_Scredit_val_tbl	      => l_Line_Scredit_val_tbl
    ,   x_Action_Request_tbl          => l_Action_Request_out_Tbl
    ,   x_lot_serial_tbl              => l_lot_serial_tbl
    ,   x_lot_serial_val_tbl          => l_lot_serial_val_tbl
    );
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'File Name',OE_DEBUG_PUB.G_FILE);
     rlm_core_sv.dlog(k_DEBUG,'l_return_status',l_return_status);
  END IF;
  --
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     --
     b_result := FALSE;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'Process Order Error Count',x_msg_count);
        rlm_core_sv.dlog(k_DEBUG,'Process Order Error',x_msg_data);
        rlm_core_sv.dlog(k_DEBUG,'no of lines in g_oe_line_tbl',g_oe_line_tbl.LAST);
        rlm_core_sv.dpop(k_SDEBUG,' no process constraints found -- returning false');
     END IF;
     --
  END IF;
  --
  RETURN(b_Result);
  --
EXCEPTION
    --
    WHEN FND_API.G_EXC_ERROR THEN
       --
       b_result := TRUE;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG,'Process Order return Status
                        FND_API.G_RET_STS_ERROR');
          rlm_core_sv.dlog(k_DEBUG,'Process Order Error Count',x_msg_count);
          rlm_core_sv.dlog(k_DEBUG,'Process Order Error',x_msg_data);
       END IF;
       --
       --x_Qty_rec.reconcile := l_line_out_Tbl(1).ordered_quantity;
       --x_Qty_rec.available_to_cancel := l_line_out_Tbl(1).ordered_quantity;
       --x_Qty_rec.shipped := l_line_out_Tbl(1).shipped_quantity;
       --
       x_msg_level := rlm_message_sv.k_warn_level;
       x_msg_name := 'RLM_PROC_CONS_FOUND';
       x_Token := 'CONSTRAINT';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG,'header_id',x_Key_rec.req_rec.header_id);
          rlm_core_sv.dlog(k_DEBUG,'line_id',x_Key_rec.req_rec.line_id);
          rlm_core_sv.dlog(k_DEBUG,'schedule_header_id',
                                     x_Key_rec.req_rec.schedule_header_id);
          rlm_core_sv.dlog(k_DEBUG,'schedule_line_id',
                                     x_Key_rec.req_rec.schedule_line_id);
          rlm_core_sv.dlog(k_DEBUG,'dem_rec.header_id', x_Key_rec.dem_rec.header_id);
          rlm_core_sv.dlog(k_DEBUG,'dem_rec.line_id', x_Key_rec.dem_rec.line_id);
       END IF;
       --
       InsertOMMessages(x_Key_rec.req_rec.header_id,x_Key_rec.req_rec.customer_item_id,x_msg_count,
                        x_msg_level, x_token, x_msg_name);
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(k_SDEBUG,'in process Constraint found');
       END IF;
       --
       RETURN(b_Result);
       --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       b_result := TRUE;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG,'Process Order return Status
                                 FND_API.G_RET_STS_UNEXP_ERROR');
          rlm_core_sv.dlog(k_DEBUG,'Process Order Error Count',x_msg_count);
          rlm_core_sv.dlog(k_DEBUG,'Process Order Error',x_msg_data);
          rlm_core_sv.dlog(k_DEBUG,'header_id',x_Key_rec.req_rec.header_id);
          rlm_core_sv.dlog(k_DEBUG,'line_id',x_Key_rec.req_rec.line_id);
          rlm_core_sv.dlog(k_DEBUG,'schedule_header_id',
                                     x_Key_rec.req_rec.schedule_header_id);
          rlm_core_sv.dlog(k_DEBUG,'schedule_line_id',
                                     x_Key_rec.req_rec.schedule_line_id);
          rlm_core_sv.dlog(k_DEBUG,'dem_rec.header_id',
                                     x_Key_rec.dem_rec.header_id);
          rlm_core_sv.dlog(k_DEBUG,'dem_rec.line_id',
                                     x_Key_rec.dem_rec.line_id);
       END IF;
       --
       x_msg_level := rlm_message_sv.k_warn_level;
       x_msg_name := 'RLM_OE_API_ERROR';
       x_Token := 'CONSTRAINT';
       --
       InsertOMMessages(x_Key_rec.req_rec.header_id,x_Key_rec.req_rec.customer_item_id,x_msg_count,
                        x_msg_level,x_token, x_msg_name);
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(k_SDEBUG,'In process Constraint Unexpected error');
       END IF;
       --
       RETURN(b_Result);
       --
    WHEN OTHERS THEN
       --
       l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG,'Process Order return Status', l_return_status);
          rlm_core_sv.dlog(k_DEBUG,'EXCEPTION',SUBSTR(SQLERRM,1,200));
          rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
       END IF;
       --
       raise;

END CallProcessConstraintAPI;

/*===========================================================================

          PROCEDURE    GetIntransitQty

===========================================================================*/
PROCEDURE GetIntransitQty (x_CustomerId 	In  NUMBER,
                           x_ShipToId   	In  NUMBER,
                           x_intmed_ship_to_org_id In NUMBER,--Bugfix 5911991
                           x_ShipFromOrgId   	In  NUMBER,
                           x_InventoryItemId   	In  NUMBER,
			   x_CustomerItemId     In  NUMBER,
                           x_OrderHeaderId    	In  NUMBER,
			   x_BlanketNumber	In  NUMBER,
                           x_OrgId              In NUMBER,
			   x_SchedType		In  VARCHAR2,
                           x_ShipperRecs    	In  WSH_RLM_INTERFACE.t_shipper_rec,
			   x_ShipmentDate	IN  DATE,
  			   x_MatchWithin	IN  RLM_CORE_SV.T_MATCH_REC,
			   x_MatchAcross	IN  RLM_CORE_SV.T_MATCH_REC,
			   x_Match_Rec		IN  WSH_RLM_INTERFACE.t_optional_match_rec,
                           x_header_id     	IN  NUMBER,
                           x_InTransitQty    	OUT NOCOPY NUMBER,
                           x_return_status 	OUT NOCOPY VARCHAR2)
IS

  e_APIExpError   EXCEPTION;
  e_APIUnExpError EXCEPTION;
  v_summary       VARCHAR2(3000);
  v_details       VARCHAR2(3000);
  v_get_msg_count NUMBER;
  -- global_atp
  v_ship_from_org_id NUMBER;
  v_MatchWithin   RLM_CORE_SV.T_MATCH_REC;
  v_MatchAcross   RLM_CORE_SV.T_MATCH_REC;

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(k_SDEBUG,'GetIntransitQty');
      --
      -- Call shipping API
      --
      rlm_core_sv.dlog(k_DEBUG,'x_CustomerId', x_CustomerId);
      rlm_core_sv.dlog(k_DEBUG,'x_ShipToId', x_ShipToId);
      rlm_core_sv.dlog(k_DEBUG,'x_intmed_ship_to_org_id', x_intmed_ship_to_org_id); --Bugfix 5911991
      rlm_core_sv.dlog(k_DEBUG,'x_ShipFromOrgId', x_ShipFromOrgId);
      rlm_core_sv.dlog(k_DEBUG,'x_InventoryItemId', x_InventoryItemId);
      rlm_core_sv.dlog(k_DEBUG,'x_CustomerItemId', x_CustomerItemId);
      rlm_core_sv.dlog(k_DEBUG,'x_OrderHeaderId', x_OrderHeaderId);
      rlm_core_sv.dlog(k_DEBUG,'x_BlanketNumber', x_BlanketNumber);
      rlm_core_sv.dlog(k_DEBUG,'x_return_status', x_return_status);
      rlm_core_sv.dlog(k_DEBUG,'x_ShipmentDate', x_ShipmentDate);
      rlm_core_sv.dlog(k_DEBUG,'x_orgId', x_OrgId);
   END IF;
   --
   --global_atp

   v_MatchWithin := x_MatchWithin;
   v_MatchAcross := x_MatchAcross;

   IF RLM_MANAGE_DEMAND_SV.IsATPItem(x_ShipFromOrgId,
                x_InventoryItemId) THEN
      --
      v_ship_from_org_id := NULL;
      v_MatchWithin.industry_attribute15 := 'N';
      v_MatchAcross.industry_attribute15 := 'N';
      --
   ELSE
      --
      v_ship_from_org_id := x_ShipFromOrgId;
      --
   END IF;
   --

   -- To calculate intransit, do not match on industry_attribute2
   v_MatchWithin.industry_attribute2 := 'N';
   v_MatchAcross.industry_attribute2 := 'N';

   -- To calculate intransit, do not match on request_date
   v_MatchWithin.request_date := 'N';
   v_MatchAcross.request_date := 'N';

   -- To calculate intransit, do not match on schedule_date
   v_MatchWithin.schedule_date := 'N';
   v_MatchAcross.schedule_date := 'N';
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG,'v_MatchWithin.industry_attribute2', v_MatchWithin.industry_attribute2);
      rlm_core_sv.dlog(k_DEBUG,'v_MatchAcross.industry_attribute2', v_MatchAcross.industry_attribute2);
      rlm_core_sv.dlog(k_DEBUG,'v_MatchWithin.industry_attribute15', v_MatchWithin.industry_attribute15);
      rlm_core_sv.dlog(k_DEBUG,'v_MatchAcross.industry_attribute15', v_MatchAcross.industry_attribute15);
      rlm_core_sv.dlog(k_DEBUG,'v_MatchWithin.request_date', v_MatchWithin.request_date);
      rlm_core_sv.dlog(k_DEBUG,'v_MatchAcross.request_date', v_MatchAcross.request_date);
      rlm_core_sv.dlog(k_DEBUG,'v_MatchWithin.schedule_date', v_MatchWithin.schedule_date);
      rlm_core_sv.dlog(k_DEBUG,'v_MatchAcross.schedule_date', v_MatchAcross.schedule_date);
   END IF;
   --
   WSH_RLM_INTERFACE.Get_In_Transit_Qty(
       p_source_code              => 'OE',
       p_customer_id              => x_CustomerId,
       p_ship_to_org_id           => x_ShipToId,
       p_intmed_ship_to_org_id    => x_intmed_ship_to_org_id,--Bugfix 5911991
       p_ship_from_org_id         => v_ship_from_org_id,
       p_inventory_item_id        => x_InventoryItemId,
       p_customer_item_id	  => x_CustomerItemId,
       p_order_header_id          => x_OrderHeaderId,
       p_blanket_number		  => x_BlanketNumber,
       p_org_id                   => x_OrgId,
       p_schedule_type		  => x_SchedType,
       p_shipper_recs             => x_ShipperRecs,
       p_shipment_date            => x_ShipmentDate,
       p_match_within_rule	  => v_MatchWithin,
       p_match_across_rule        => v_MatchAcross,
       p_optional_match_rec	  => x_Match_Rec,
       x_in_transit_qty           => x_InTransitQty,
       x_return_status            => x_return_status);
   --
   IF x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
    --
    RAISE e_APIExpError;
    --
   ELSIF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
    --
    RAISE e_APIUnExpError;
    --
   ELSE
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG,'x_InTransitQty', x_InTransitQty);
      rlm_core_sv.dlog(k_DEBUG,'x_return_status', x_return_status);
    END IF;
    --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(k_SDEBUG);
   END IF;
   --
  EXCEPTION
    --
    WHEN e_APIExpError THEN
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Get_Messages('N',v_summary, v_details, v_get_msg_count);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'v_summary',  v_summary );
         rlm_core_sv.dlog(k_DEBUG,'v_details',  v_details );
         rlm_core_sv.dlog(k_DEBUG,'v_get_msg_count', v_get_msg_count );
      END IF;
      --
      rlm_message_sv.app_error(
                 x_ExceptionLevel => rlm_message_sv.k_error_level,
                 x_MessageName => 'RLM_INTRANSIT_API_FAILED',
                 x_InterfaceHeaderId => x_header_id,
                 x_InterfaceLineId => NULL,
                 x_ScheduleHeaderId =>NULL,
                 x_ScheduleLineId => NULL,
                 x_OrderHeaderId => x_OrderheaderId,
                 x_OrderLineId => NULL,
                 x_Token1 => 'ERROR',
                 x_value1 => substr(v_summary,1,200));
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'x_return_status', x_return_status);
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: GetInstransitQty');
      END IF;
      --
    WHEN e_APIUnExpError THEN
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      WSH_UTIL_CORE.Get_Messages('N',v_summary, v_details, v_get_msg_count);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'v_summary',  v_summary );
         rlm_core_sv.dlog(k_DEBUG,'v_details',  v_details );
         rlm_core_sv.dlog(k_DEBUG,'v_get_msg_count', v_get_msg_count );
      END IF;
      --
      rlm_message_sv.app_error(
                 x_ExceptionLevel => rlm_message_sv.k_error_level,
                 x_MessageName => 'RLM_INTRANSIT_API_FAILED',
                 x_InterfaceHeaderId => x_header_id,
                 x_InterfaceLineId => NULL,
                 x_ScheduleHeaderId =>NULL,
                 x_ScheduleLineId => NULL,
                 x_OrderHeaderId => x_OrderheaderId,
                 x_OrderLineId => NULL,
                 x_Token1 => 'ERROR',
                 x_value1 => substr(v_summary,1,200));
     --
     IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'x_return_status', x_return_status);
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: GetInstransitQty');
      END IF;
      --
    WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
      --
END GetIntransitQty;


/*===========================================================================

          PROCEDURE    CheckShippingConstraints

===========================================================================*/

PROCEDURE CheckShippingConstraints (
                   x_source_code            IN     VARCHAR2,
                   x_changed_attributes     IN     WSH_SHIPPING_CONSTRAINTS_PKG.ChangedAttributeRecType,
                   x_return_status          OUT NOCOPY    VARCHAR2,
                   x_action_allowed         OUT NOCOPY    VARCHAR2,
                   x_action_message         OUT NOCOPY    VARCHAR2,
                   x_ord_qty_allowed        OUT NOCOPY    NUMBER,
                   x_log_level              IN     NUMBER,
                   x_header_id              IN     NUMBER,
                   x_order_header_id        IN     NUMBER)
IS

  e_APIUnExpError EXCEPTION;
  e_APIExpError   EXCEPTION;

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(k_SDEBUG,'CheckShippingConstraints');
      --
      -- Call shipping API
      --
      rlm_core_sv.dlog(k_DEBUG,'x_source_code', x_source_code);
      rlm_core_sv.dlog(k_DEBUG,'x_changed_attributes.source_line_id',x_changed_attributes.source_line_id);
      rlm_core_sv.dlog(k_DEBUG,'x_changed_attributes.action_flag', x_changed_attributes.action_flag);
      rlm_core_sv.dlog(k_DEBUG,'x_log_level', x_log_level);
      rlm_core_sv.dlog(k_DEBUG,'x_header_id', x_header_id);
      rlm_core_sv.dlog(k_DEBUG,'x_order_header_id', x_order_header_id);
   END IF;
   --
   WSH_SHIPPING_CONSTRAINTS_PKG.check_shipping_constraints(
        p_source_code        => x_source_code,
        p_changed_attributes => x_changed_attributes,
        x_return_status      => x_return_status,
        x_action_allowed     => x_action_allowed,
        x_action_message     => x_action_message,
        x_ord_qty_allowed    => x_ord_qty_allowed
        );
   --
   IF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
     --
     RAISE e_APIUnExpError;
     --
   ELSIF x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
     --
     RAISE e_APIExpError;
     --
   ELSE
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'x_return_status', x_return_status);
        rlm_core_sv.dlog(k_DEBUG,'x_action_allowed', x_action_allowed);
        rlm_core_sv.dlog(k_DEBUG,'x_action_message', x_action_message);
        rlm_core_sv.dlog(k_DEBUG,'x_ord_qty_allowed', x_ord_qty_allowed);
     END IF;
     --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(k_SDEBUG);
   END IF;
   --
  EXCEPTION
    --
    WHEN e_APIUnExpError THEN
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      --WSH_UTIL_CORE.Get_Messages('N',v_summary, v_details, v_get_msg_count);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'x_return_status', x_return_status);
         rlm_core_sv.dlog(k_DEBUG,'x_action_allowed', x_action_allowed);
         rlm_core_sv.dlog(k_DEBUG,'x_action_message', x_action_message);
         rlm_core_sv.dlog(k_DEBUG,'x_ord_qty_allowed', x_ord_qty_allowed);
      END IF;
      --
      rlm_message_sv.app_error(
                 x_ExceptionLevel => rlm_message_sv.k_error_level,
                 x_MessageName => 'RLM_WSH_CONSTRAINT_API_FAILED',
                 x_InterfaceHeaderId => x_header_id,
                 x_InterfaceLineId => NULL,
                 x_ScheduleHeaderId =>NULL,
                 x_ScheduleLineId => NULL,
                 x_OrderHeaderId => x_order_header_id,
                 x_OrderLineId => x_changed_attributes.source_line_id,
                 x_Token1 => 'ERROR',
                 x_value1 => SUBSTR(SQLERRM,1,200));
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'x_return_status', x_return_status);
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: CallShippingConstraintsAPI');
      END IF;
      --

    WHEN e_APIExpError THEN
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      --WSH_UTIL_CORE.Get_Messages('N',v_summary, v_details, v_get_msg_count);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'x_return_status', x_return_status);
         rlm_core_sv.dlog(k_DEBUG,'x_action_allowed', x_action_allowed);
         rlm_core_sv.dlog(k_DEBUG,'x_action_message', x_action_message);
         rlm_core_sv.dlog(k_DEBUG,'x_ord_qty_allowed', x_ord_qty_allowed);
      END IF;
      --
      rlm_message_sv.app_error(
                 x_ExceptionLevel => rlm_message_sv.k_error_level,
                 x_MessageName => 'RLM_WSH_CONSTRAINT_API_FAILED',
                 x_InterfaceHeaderId => x_header_id,
                 x_InterfaceLineId => NULL,
                 x_ScheduleHeaderId =>NULL,
                 x_ScheduleLineId => NULL,
                 x_OrderHeaderId => x_order_header_id,
                 x_OrderLineId => x_changed_attributes.source_line_id,
                 x_Token1 => 'ERROR',
                 x_value1 => x_action_message);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'x_return_status', x_return_status);
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: CallShippingConstraintsAPI');
      END IF;
      --

    WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      RAISE;
      --
END CheckShippingConstraints;


/*===========================================================================

          PROCEDURE    SubmitDemandProcessor

===========================================================================*/
FUNCTION SubmitDemandProcessor(p_schedule_purpose_code VARCHAR2,
                               p_from_date   DATE,
                               p_to_date   DATE,
                               p_from_customer_ext   VARCHAR2,
                               p_to_customer_ext   VARCHAR2,
                               p_from_ship_to_ext   VARCHAR2,
                               p_to_ship_to_ext   VARCHAR2,
                               p_run_edi_loader   BOOLEAN) return NUMBER is
x_req_id number;
BEGIN
if (p_run_edi_loader = FALSE) then
  x_req_id :=fnd_request.submit_request ('RLM',
					 'RLMDSP',
					 NULL,
					 NULL,
					 TRUE,
					 p_schedule_purpose_code,
					 p_from_date,
					 p_to_date,
					 p_from_customer_ext,
					 p_to_customer_ext,
					 p_from_ship_to_ext,
					 p_to_ship_to_ext );
  commit;
  return x_req_id;
else
-- Submit EDI Loader
-- Wait for Completion and then submit DSP
null;

end if;

END SubmitDemandProcessor;

/*===========================================================================

          PROCEDURE    BuildTPOELine

===========================================================================*/
PROCEDURE BuildTPOELine(x_oe_line_rec IN OUT NOCOPY oe_order_pub.line_rec_type,
                        x_Op_rec      IN rlm_rd_sv.t_generic_rec)
IS
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'BuildTPOELine');
  END IF;
  --
  x_oe_line_rec.tp_attribute1 := x_Op_rec.tp_attribute1;
  x_oe_line_rec.tp_attribute2 := x_Op_rec.tp_attribute2;
  x_oe_line_rec.tp_attribute3:= x_Op_rec.tp_attribute3;
  x_oe_line_rec.tp_attribute4:= x_Op_rec.tp_attribute4;
  x_oe_line_rec.tp_attribute5:= x_Op_rec.tp_attribute5;
  x_oe_line_rec.tp_attribute6:= x_Op_rec.tp_attribute6;
  x_oe_line_rec.tp_attribute7:= x_Op_rec.tp_attribute7;
  x_oe_line_rec.tp_attribute8:= x_Op_rec.tp_attribute8;
  x_oe_line_rec.tp_attribute9:= x_Op_rec.tp_attribute9;
  x_oe_line_rec.tp_attribute10:= x_Op_rec.tp_attribute10;
  x_oe_line_rec.tp_attribute11:= x_Op_rec.tp_attribute11;
  x_oe_line_rec.tp_attribute12:= x_Op_rec.tp_attribute12;
  x_oe_line_rec.tp_attribute13:= x_Op_rec.tp_attribute13;
  x_oe_line_rec.tp_attribute14:= x_Op_rec.tp_attribute14;
  x_oe_line_rec.tp_attribute15:= x_Op_rec.tp_attribute15;
  x_oe_line_rec.tp_context:= x_Op_rec.tp_attribute_category;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute1',
                                  x_Op_rec.tp_attribute1);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute2',
                                  x_Op_rec.tp_attribute2);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute3',
                                  x_Op_rec.tp_attribute3);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute4',
                                  x_Op_rec.tp_attribute4);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute5',
                                  x_Op_rec.tp_attribute5);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute6',
                                  x_Op_rec.tp_attribute6);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute7',
                                  x_Op_rec.tp_attribute7);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute8',
                                  x_Op_rec.tp_attribute8);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute9',
                                  x_Op_rec.tp_attribute9);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute10',
                                  x_Op_rec.tp_attribute10);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute11',
                                  x_Op_rec.tp_attribute11);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute12',
                                  x_Op_rec.tp_attribute12);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute13',
                                  x_Op_rec.tp_attribute13);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute14',
                                  x_Op_rec.tp_attribute14);
     rlm_core_sv.dlog(k_DEBUG,'tp_attribute15',
                                  x_Op_rec.tp_attribute15);
     rlm_core_sv.dlog(k_DEBUG,'tp_context',
                                  x_Op_rec.tp_attribute_category);
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END BuildTpOELine;

/*===========================================================================

          PROCEDURE    BuildOELine

===========================================================================*/
PROCEDURE BuildOELine(x_oe_line_rec IN OUT NOCOPY oe_order_pub.line_rec_type,
                      x_Op_rec IN rlm_rd_sv.t_generic_rec)
IS
  b_ATP    BOOLEAN;
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'BuildOELine');
  END IF;
  --
  -- Added by JAUTOMO 11/02/00 Bug# 1467525
  -- Added by JAUTOMO 11/08/01 Bug# 2096968

  -- global_atp
  -- Find out NOCOPY if the item is an ATP item or not
  IF x_Op_rec.ship_from_org_id IS NOT NULL
     AND x_Op_rec.inventory_item_id IS NOT NULL THEN

     b_ATP := RLM_MANAGE_DEMAND_SV.IsATPItem(x_Op_rec.ship_from_org_id,
                                             x_Op_rec.inventory_item_id);
  ELSE
     IF RLM_RD_SV.g_ATP = RLM_RD_SV.k_ATP THEN
       b_ATP := TRUE;
     ELSE
       b_ATP := FALSE;
     END IF;
  END IF;

  IF( x_Op_rec.ordered_quantity = 0
      AND x_Op_rec.operation =  OE_GLOBALS.G_OPR_UPDATE) THEN
    --
    x_oe_line_rec.operation         := x_Op_rec.operation;
    x_oe_line_rec.change_reason     := 'EDI CANCELLATION';
    x_oe_line_rec.ordered_quantity  := x_Op_rec.ordered_quantity;
    x_oe_line_rec.header_id         := x_Op_rec.order_header_id;
    x_oe_line_rec.line_id           := x_Op_rec.line_id;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'operation ',x_oe_line_rec.operation);
       rlm_core_sv.dlog(k_DEBUG,'ordered_quantity ',x_oe_line_rec.ordered_quantity);
       rlm_core_sv.dlog(k_DEBUG,'line_id ',x_oe_line_rec.line_id);
    END IF;
    --
  ELSE
    --
    IF  x_Op_rec.operation =  OE_GLOBALS.G_OPR_UPDATE THEN
       --
       x_oe_line_rec.change_reason     := 'EDI CANCELLATION';
       --
    END IF;
    --
      -- To UPDATE ATP item, DSP should pass MISSING ship_from_org_id
      -- and schedule_ship_date; DSP should not pass NULL.

      -- global_atp
    --Bug 3675750 jckwok

    IF NOT b_ATP THEN
        --
        IF x_Op_rec.ship_from_org_id IS NOT NULL THEN
          x_oe_line_rec.ship_from_org_id := x_Op_rec.ship_from_org_id;
        END IF;
        --
        IF x_Op_rec.schedule_date IS NOT NULL THEN
          x_oe_line_rec.schedule_ship_date := x_Op_rec.schedule_date;
        END IF;
        --
    END IF;
    --
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'b_ATP', b_ATP);
       rlm_core_sv.dlog(k_DEBUG,'schedule_date',
                     x_oe_line_rec.schedule_ship_date);
       rlm_core_sv.dlog(k_DEBUG,'ship_from_org_id',
                     x_oe_line_rec.ship_from_org_id);
       rlm_core_sv.dlog(k_DEBUG,'schedule_action_code',
                     x_oe_line_rec.schedule_action_code);
    END IF;
    --
    --
    IF x_Op_rec.agreement_id IS NOT NULL THEN
	x_oe_line_rec.agreement_id:= x_Op_rec.agreement_id;
    END IF;
    --
    IF x_Op_rec.attribute1 IS NOT NULL THEN
	x_oe_line_rec.attribute1 := x_Op_rec.attribute1;
    END IF;
    --
    IF x_Op_rec.attribute2 IS NOT NULL THEN
	x_oe_line_rec.attribute2 := x_Op_rec.attribute2;
    END IF;
    --
    IF x_Op_rec.attribute3 IS NOT NULL THEN
	x_oe_line_rec.attribute3 := x_Op_rec.attribute3;
    END IF;
    --
    IF x_Op_rec.attribute4 IS NOT NULL THEN
	x_oe_line_rec.attribute4 := x_Op_rec.attribute4;
    END IF;
    --
    IF x_Op_rec.attribute5 IS NOT NULL THEN
	x_oe_line_rec.attribute5 := x_Op_rec.attribute5;
    END IF;
    --
    IF x_Op_rec.attribute6 IS NOT NULL THEN
	x_oe_line_rec.attribute6 := x_Op_rec.attribute6;
    END IF;
    --
    IF x_Op_rec.attribute7 IS NOT NULL THEN
	x_oe_line_rec.attribute7 := x_Op_rec.attribute7;
    END IF;
    --
    IF x_Op_rec.attribute8 IS NOT NULL THEN
	x_oe_line_rec.attribute8 := x_Op_rec.attribute8;
    END IF;
    --
    IF x_Op_rec.attribute9 IS NOT NULL THEN
	x_oe_line_rec.attribute9 := x_Op_rec.attribute9;
    END IF;
    --
    IF x_Op_rec.attribute10 IS NOT NULL THEN
	x_oe_line_rec.attribute10:= x_Op_rec.attribute10;
    END IF;
    --
    IF x_Op_rec.attribute11 IS NOT NULL THEN
	x_oe_line_rec.attribute11:= x_Op_rec.attribute11;
    END IF;
    --
    IF x_Op_rec.attribute12 IS NOT NULL THEN
	x_oe_line_rec.attribute12:= x_Op_rec.attribute12;
    END IF;
    --
    IF x_Op_rec.attribute13 IS NOT NULL THEN
	x_oe_line_rec.attribute13:= x_Op_rec.attribute13;
    END IF;
    --
    IF x_Op_rec.attribute14 IS NOT NULL THEN
	x_oe_line_rec.attribute14:= x_Op_rec.attribute14;
    END IF;
    --
    IF x_Op_rec.attribute15 IS NOT NULL THEN
	x_oe_line_rec.attribute15:= x_Op_rec.attribute15;
    END IF;
    --
    IF x_Op_rec.attribute_category IS NOT NULL THEN
	x_oe_line_rec.context:= x_Op_rec.attribute_category;
    END IF;
    --
    IF x_Op_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN --Bugfix 9223338 Added IF Condition
       x_oe_line_rec.created_by        := FND_GLOBAL.USER_ID;
       x_oe_line_rec.creation_date     := SYSDATE;
    END IF;
    x_oe_line_rec.last_updated_by   := FND_GLOBAL.USER_ID;
    x_oe_line_rec.last_update_date  := SYSDATE;
    x_oe_line_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
    IF x_Op_rec.customer_dock_code IS NOT NULL THEN
	x_oe_line_rec.customer_dock_code:= x_Op_rec.customer_dock_code;
    END IF;
    --
    IF x_Op_rec.customer_job IS NOT NULL THEN
	x_oe_line_rec.customer_job      := x_Op_rec.customer_job;
    END IF;
    --
    IF x_Op_rec.cust_production_line IS NOT NULL THEN
	x_oe_line_rec.customer_production_line:= x_Op_rec.cust_production_line;
    END IF;
    --
    IF x_Op_rec.cust_model_serial_number IS NOT NULL THEN
	x_oe_line_rec.cust_model_serial_number:= x_Op_rec.cust_model_serial_number;
    END IF;
    --
    IF x_Op_rec.cust_po_number IS NOT NULL THEN
	x_oe_line_rec.cust_po_number    := x_Op_rec.cust_po_number;
    END IF;
    --
    IF x_Op_rec.delivery_lead_time IS NOT NULL THEN
	x_oe_line_rec.delivery_lead_time:= x_Op_rec.delivery_lead_time;
    END IF;
    --
    x_oe_line_rec.header_id         := x_Op_rec.order_header_id;
    --
    IF x_Op_rec.industry_attribute1 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute1 := x_Op_rec.industry_attribute1;
    END IF;
    --
    IF x_Op_rec.industry_attribute10 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute10:= x_Op_rec.industry_attribute10;
    END IF;
    --
    IF x_Op_rec.industry_attribute11 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute11:= x_Op_rec.industry_attribute11;
    END IF;
    --
    IF x_Op_rec.industry_attribute12 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute12:= x_Op_rec.industry_attribute12;
    END IF;
    --
    IF x_Op_rec.industry_attribute13 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute13:= x_Op_rec.industry_attribute13;
    END IF;
    --
    IF x_Op_rec.industry_attribute14 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute14:= x_Op_rec.industry_attribute14;
    END IF;
    --
    IF x_Op_rec.industry_attribute15 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute15:= x_Op_rec.industry_attribute15;
    END IF;
    --
    IF x_Op_rec.industry_attribute2 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute2 := x_Op_rec.industry_attribute2;
    END IF;
    --
    IF x_Op_rec.industry_attribute3 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute3 := x_Op_rec.industry_attribute3;
    END IF;
    --
    IF x_Op_rec.industry_attribute4 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute4 := x_Op_rec.industry_attribute4;
    END IF;
    --
    IF x_Op_rec.industry_attribute5 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute5 := x_Op_rec.industry_attribute5;
    END IF;
    --
    IF x_Op_rec.industry_attribute6 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute6 := x_Op_rec.industry_attribute6;
    END IF;
    --
    IF x_Op_rec.industry_attribute7 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute7 := x_Op_rec.industry_attribute7;
    END IF;
    --
    IF x_Op_rec.industry_attribute8 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute8 := x_Op_rec.industry_attribute8;
    END IF;
    --
    IF x_Op_rec.industry_attribute9 IS NOT NULL THEN
	x_oe_line_rec.industry_attribute9 := x_Op_rec.industry_attribute9;
    END IF;
    --
    -- RLM industry context can now be passed. Bug 1495522 fixed the issue
    -- of bug 1421573 and 1495573

    x_oe_line_rec.industry_context := NVL(x_Op_rec.industry_context, 'RLM');
    --
    IF x_Op_rec.invoice_to_org_id IS NOT NULL THEN
      x_oe_line_rec.invoice_to_org_id := x_Op_rec.invoice_to_org_id;
    END IF;
    --
    IF x_Op_rec.item_detail_subtype IS NOT NULL THEN
      x_oe_line_rec.demand_bucket_type_code := x_Op_rec.item_detail_subtype;
    END IF;
    --
    IF x_Op_rec.inventory_item_id IS NOT NULL THEN
      x_oe_line_rec.inventory_item_id := x_Op_rec.inventory_item_id;
    END IF;
    --
    IF x_Op_rec.customer_item_id IS NOT NULL THEN
      x_oe_line_rec.ordered_item_id := x_Op_rec.customer_item_id;
    END IF;
    --
    IF x_Op_rec.customer_item_ext IS NOT NULL THEN
      x_oe_line_rec.ordered_item := x_Op_rec.customer_item_ext;
    ELSIF x_Op_rec.supplier_item_ext is not null THEN
      x_oe_line_rec.ordered_item := x_Op_rec.supplier_item_ext;
    END IF;
    --
    --x_oe_line_rec.item_type_code := fnd_api.g_miss_char;
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'customer_item_revision', x_Op_rec.customer_item_revision);
    END IF;
    --
    IF x_Op_rec.customer_item_revision IS NOT NULL THEN
      x_oe_line_rec.item_revision := x_Op_rec.customer_item_revision;
    END IF;
    --
    IF x_Op_rec.line_id IS NOT NULL THEN
      x_oe_line_rec.line_id := x_Op_rec.line_id;
    END IF;
    --
    IF x_Op_rec.ordered_quantity IS NOT NULL THEN
      x_oe_line_rec.ordered_quantity := x_Op_rec.ordered_quantity;
    END IF;
    --
    IF x_Op_rec.request_date IS NOT NULL THEN
      x_oe_line_rec.pricing_date := x_Op_rec.request_date;
      x_oe_line_rec.request_date := x_Op_rec.request_date;
    END IF;
    --
    IF x_Op_rec.price_list_id IS NOT NULL THEN
      x_oe_line_rec.price_list_id := x_Op_rec.price_list_id;
    END IF;
    --
    IF x_Op_rec.authorized_to_ship_flag IS NOT NULL THEN
      x_oe_line_rec.authorized_to_ship_flag := x_Op_rec.authorized_to_ship_flag;
    END IF;
    --
    IF x_Op_rec.cust_production_seq_num IS NOT NULL THEN
      x_oe_line_rec.cust_production_seq_num := x_Op_rec.cust_production_seq_num;
    END IF;
    --
    x_oe_line_rec.program_application_id := FND_GLOBAL.PROG_APPL_ID;
    x_oe_line_rec.program_id             := FND_GLOBAL.CONC_PROGRAM_ID;
    x_oe_line_rec.program_update_date    := SYSDATE;
    --
    IF x_Op_rec.schedule_type IS NOT NULL THEN
      x_oe_line_rec.rla_schedule_type_code := x_Op_rec.schedule_type;
    END IF;
    --
    x_oe_line_rec.request_id := FND_GLOBAL.CONC_REQUEST_ID;
    --
    IF x_Op_rec.customer_id IS NOT NULL THEN
      x_oe_line_rec.sold_to_org_id := x_Op_rec.customer_id;
    END IF;
    --
    IF x_Op_rec.intmed_ship_to_org_id IS NOT NULL THEN
      x_oe_line_rec.intermed_ship_to_org_id := x_Op_rec.intmed_ship_to_org_id;
    END IF;
    --
    IF x_Op_rec.ship_to_org_id IS NOT NULL THEN
      x_oe_line_rec.ship_to_org_id := x_Op_rec.ship_to_org_id;
    END IF;
    --
    x_oe_line_rec.operation:= x_Op_rec.operation;
    --
    --
    IF x_Op_rec.uom_code IS NOT NULL THEN
      x_oe_line_rec.order_quantity_uom := x_Op_rec.uom_code;
    END IF;
    --
    x_oe_line_rec.item_identifier_type:= x_Op_rec.item_identifier_type;
    --
    -- required for the link between OE and rlm lines
    x_oe_line_rec.source_document_type_id:= k_OE_DOCUMENT_TYPE;
    --
    IF x_Op_rec.schedule_line_id IS NOT NULL THEN
      x_oe_line_rec.source_document_line_id := x_Op_rec.schedule_line_id;
    END IF;
    --
    IF x_Op_rec.schedule_header_id IS NOT NULL THEN
      x_oe_line_rec.source_document_id := x_Op_rec.schedule_header_id;
    END IF;
    --
    IF x_Op_rec.cust_po_line_num is NOT NULL THEN
      x_oe_line_rec.customer_line_number := x_Op_rec.cust_po_line_num;
    END IF;
    --
    -- blankets
    --
    IF x_Op_rec.blanket_number is NOT NULL THEN
     x_oe_line_rec.blanket_number := x_Op_rec.blanket_number;
    END IF;
    --
    x_oe_line_rec.org_id := MO_GLOBAL.get_current_org_id;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'created_by',x_oe_line_rec.created_by );            --Bugfix 9223338
       rlm_core_sv.dlog(k_DEBUG,'creation_date',x_oe_line_rec.creation_date);       --Bugfix 9223338
       rlm_core_sv.dlog(k_DEBUG,'last_updated_by',x_oe_line_rec.last_updated_by );  --Bugfix 9223338
       rlm_core_sv.dlog(k_DEBUG,'last_update_date',x_oe_line_rec.last_update_date); --Bugfix 9223338
       rlm_core_sv.dlog(k_DEBUG,'cust_dock_code',x_oe_line_rec.customer_dock_code);
       rlm_core_sv.dlog(k_DEBUG,'Customer job', x_oe_line_rec.customer_job);
       rlm_core_sv.dlog(k_DEBUG,'delivery_lead_time',
                              x_oe_line_rec.delivery_lead_time);
       rlm_core_sv.dlog(k_DEBUG,'ordered_quantity ',
                                  x_oe_line_rec.ordered_quantity);
       rlm_core_sv.dlog(k_DEBUG,'uom_code',
                                  x_Op_rec.uom_code);
       rlm_core_sv.dlog(k_DEBUG,'operation ',x_oe_line_rec.operation);
       rlm_core_sv.dlog(k_DEBUG,'change_reason ',x_oe_line_rec.change_reason);
       rlm_core_sv.dlog(k_DEBUG,'pricing_date',x_oe_line_rec.pricing_date);
       rlm_core_sv.dlog(k_DEBUG,'request_date',x_oe_line_rec.request_date);
       rlm_core_sv.dlog(k_DEBUG,'promise_date',x_oe_line_rec.promise_date);
       rlm_core_sv.dlog(k_DEBUG,'intmed_ship_to_org_id',x_oe_line_rec.intermed_ship_to_org_id);
       rlm_core_sv.dlog(k_DEBUG,'schedule_date',
                     x_oe_line_rec.schedule_ship_date);
       rlm_core_sv.dlog(k_DEBUG,'deliver_to_org_id',
                     x_oe_line_rec.deliver_to_org_id);
       rlm_core_sv.dlog(k_DEBUG,'ship_from_org_id',
                     x_oe_line_rec.ship_from_org_id);
       rlm_core_sv.dlog(k_DEBUG,'ship_to_org_id',
                     x_oe_line_rec.ship_to_org_id);
       rlm_core_sv.dlog(k_DEBUG,'invoice to org id ',
                     x_oe_line_rec.invoice_to_org_id);
       rlm_core_sv.dlog(k_DEBUG,'authorized_to_ship_flag',
                     x_oe_line_rec.authorized_to_ship_flag);
       rlm_core_sv.dlog(k_DEBUG,'Header ID',x_oe_line_rec.header_id);
       rlm_core_sv.dlog(k_DEBUG,'Inventory_item_id',
                     x_oe_line_rec.inventory_item_id);
       rlm_core_sv.dlog(k_DEBUG,'item_identifier_type ',
                     x_oe_line_rec.item_identifier_type);
       rlm_core_sv.dlog(k_DEBUG,'ordered_item_id ',
                     x_oe_line_rec.ordered_item_id);
       rlm_core_sv.dlog(k_DEBUG,'ordered_item',
                     x_oe_line_rec.ordered_item);
       rlm_core_sv.dlog(k_DEBUG,'item_detail_type',
                     x_oe_line_rec.item_type_code);
       rlm_core_sv.dlog(k_DEBUG,'line_id ',
                     x_oe_line_rec.line_id);
       rlm_core_sv.dlog(k_DEBUG,'agreement_id ',
                     x_oe_line_rec.agreement_id);
       rlm_core_sv.dlog(k_DEBUG,'price_list_id ',
                     x_oe_line_rec.price_list_id);
       rlm_core_sv.dlog(k_DEBUG,'sold_to_org_id ',
                     x_oe_line_rec.sold_to_org_id);
       rlm_core_sv.dlog(k_DEBUG,'source_document_line_id ',
                     x_oe_line_rec.source_document_line_id);
       rlm_core_sv.dlog(k_DEBUG,'source_document_id ',
                     x_oe_line_rec.source_document_id);
       rlm_core_sv.dlog(k_DEBUG,'source_document_type_id ',
                     x_oe_line_rec.source_document_type_id);
       rlm_core_sv.dlog(k_DEBUG,'PO Line number ',
		     x_oe_line_rec.customer_line_number);
       rlm_core_sv.dlog(k_DEBUG,'customer_production_line', x_oe_line_rec.customer_production_line);
       rlm_core_sv.dlog(k_DEBUG,'cust_model_serial_number', x_oe_line_rec.cust_model_serial_number);
       rlm_core_sv.dlog(k_DEBUG,'cust_po_number', x_oe_line_rec.cust_po_number);
       rlm_core_sv.dlog(k_DEBUG,'demand_bucket_type_code', x_oe_line_rec.demand_bucket_type_code);
       rlm_core_sv.dlog(k_DEBUG,'cust_production_seq_num', x_oe_line_rec.cust_production_seq_num);
       rlm_core_sv.dlog(k_DEBUG,'item_identifier_type', x_oe_line_rec.item_identifier_type);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute1 ', x_oe_line_rec.industry_attribute1);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute2 ', x_oe_line_rec.industry_attribute2);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute3 ', x_oe_line_rec.industry_attribute3);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute4 ', x_oe_line_rec.industry_attribute4);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute5 ', x_oe_line_rec.industry_attribute5);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute6 ', x_oe_line_rec.industry_attribute6);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute7 ', x_oe_line_rec.industry_attribute7);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute8 ', x_oe_line_rec.industry_attribute8);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute9 ', x_oe_line_rec.industry_attribute9);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute10', x_oe_line_rec.industry_attribute10);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute11', x_oe_line_rec.industry_attribute11);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute12', x_oe_line_rec.industry_attribute12);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute13', x_oe_line_rec.industry_attribute13);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute14', x_oe_line_rec.industry_attribute14);
       rlm_core_sv.dlog(k_DEBUG,'industry_attribute15', x_oe_line_rec.industry_attribute15);
       rlm_core_sv.dlog(k_DEBUG,'industry_context', x_oe_line_rec.industry_context);
       rlm_core_sv.dlog(k_DEBUG,'attribute1 ', x_oe_line_rec.attribute1);
       rlm_core_sv.dlog(k_DEBUG,'attribute2', x_oe_line_rec.attribute2);
       rlm_core_sv.dlog(k_DEBUG,'attribute3 ', x_oe_line_rec.attribute3);
       rlm_core_sv.dlog(k_DEBUG,'attribute4 ', x_oe_line_rec.attribute4);
       rlm_core_sv.dlog(k_DEBUG,'attribute5 ', x_oe_line_rec.attribute5);
       rlm_core_sv.dlog(k_DEBUG,'attribute6', x_oe_line_rec.attribute6);
       rlm_core_sv.dlog(k_DEBUG,'attribute7 ', x_oe_line_rec.attribute7);
       rlm_core_sv.dlog(k_DEBUG,'attribute8 ', x_oe_line_rec.attribute8);
       rlm_core_sv.dlog(k_DEBUG,'attribute9 ', x_oe_line_rec.attribute9);
       rlm_core_sv.dlog(k_DEBUG,'attribute10', x_oe_line_rec.attribute10);
       rlm_core_sv.dlog(k_DEBUG,'attribute11', x_oe_line_rec.attribute11);
       rlm_core_sv.dlog(k_DEBUG,'attribute12', x_oe_line_rec.attribute12);
       rlm_core_sv.dlog(k_DEBUG,'attribute13', x_oe_line_rec.attribute13);
       rlm_core_sv.dlog(k_DEBUG,'attribute14', x_oe_line_rec.attribute14);
       rlm_core_sv.dlog(k_DEBUG,'attribute15', x_oe_line_rec.attribute15);
       rlm_core_sv.dlog(k_DEBUG,'attribute_category',x_oe_line_rec.context);
       rlm_core_sv.dlog(k_DEBUG,'blanket_number',x_oe_line_rec.blanket_number);
       rlm_core_sv.dlog(k_DEBUG,'Org ID', x_oe_line_rec.org_id);
    END IF;
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END BuildOELine;

/*===========================================================================

          PROCEDURE    GetLineStatus

===========================================================================*/
FUNCTION GetLineStatus(x_ScheduleLineId  In NUMBER, x_OrderLineId  In NUMBER)
RETURN VARCHAR2
IS

  v_line_status VARCHAR2(80);
  v_status_code  VARCHAR2(80);
  v_total_count NUMBER;
  v_released_count NUMBER;

BEGIN

-- Required currently for Demand Status Inquiry Report
-- Adding the select statement below to fix bug 1509014.
-- Making the change to reflect the changes OM made for in OEXFLINB.pls for 1172817
   --
   SELECT flow_status_code
   INTO v_status_code
   FROM oe_order_lines_all
   where line_id = x_OrderLineId;
   --
   IF v_status_code <> 'AWAITING_SHIPPING' AND
      v_status_code <> 'PRODUCTION_COMPLETE' AND
      v_status_code <> 'PICKED' AND
      v_status_code <> 'PICKED_PARTIAL' THEN
      --
      SELECT a.meaning
      INTO v_line_status
      FROM oe_lookups a, oe_order_lines_all b
      WHERE a.lookup_type like 'LINE_FLOW_STATUS'
      AND a.lookup_code = b.flow_status_code
      AND b.line_id = x_OrderLineId;
      --
   ELSE
      --
      SELECT sum(decode(released_status, 'Y', 1, 0)), sum(1)
      INTO v_released_count, v_total_count
      FROM wsh_delivery_details
      WHERE source_line_id   = x_OrderLineId
      AND   source_code      = 'OE'
      AND   released_status  <> 'D';

      IF v_released_count = v_total_count THEN
         --
         SELECT meaning
         INTO v_line_status
         FROM fnd_lookup_values lv
         WHERE lookup_type = 'LINE_FLOW_STATUS'
         AND lookup_code = 'PICKED'
         AND LANGUAGE = userenv('LANG')
         AND VIEW_APPLICATION_ID = 660
         AND SECURITY_GROUP_ID =
         fnd_global.Lookup_Security_Group(lv.lookup_type,
                                      lv.view_application_id);
         --
      ELSIF v_released_count < v_total_count and v_released_count <> 0 THEN
         --
         SELECT meaning
         INTO v_line_status
         FROM fnd_lookup_values lv
         WHERE lookup_type = 'LINE_FLOW_STATUS'
         AND lookup_code = 'PICKED_PARTIAL'
         AND LANGUAGE = userenv('LANG')
         AND VIEW_APPLICATION_ID = 660
         AND SECURITY_GROUP_ID =
                fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                 lv.view_application_id);
         --
      ELSE
         --
         SELECT meaning
         INTO v_line_status
         FROM fnd_lookup_values lv
         WHERE lookup_type = 'LINE_FLOW_STATUS'
         AND lookup_code = v_status_code
         AND LANGUAGE = userenv('LANG')
         AND VIEW_APPLICATION_ID = 660
         AND SECURITY_GROUP_ID =
                fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                 lv.view_application_id);
         --
      END IF;
      --
  END IF;
  --
  RETURN v_line_status;
  --
EXCEPTION
   --
   WHEN OTHERS THEN
        --
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dlog(k_DEBUG,'EXCEPTION',SUBSTR(SQLERRM,1,200));
	END IF;
        --
 	raise;

END;

/*===========================================================================

          PROCEDURE    GetLocation

===========================================================================*/

FUNCTION GetLocation(x_OrgId  In NUMBER)
RETURN VARCHAR2
IS

  v_location                   VARCHAR2(80);
BEGIN
-- Required currently for Demand Status Inquiry Report

  IF (x_OrgId IS NOT NULL) THEN
    -- Following query is changed as per TCA obsolescence project.
    select	location
    into	v_location
    from	HZ_CUST_SITE_USES_ALL
    where	site_use_code = 'SHIP_TO'
    and		site_use_id = x_OrgId;

    return v_location;

  ELSE
    return NULL;

  END IF;

END;

/*===========================================================================

          PROCEDURE    GetAddress1

===========================================================================*/

FUNCTION GetAddress1(x_OrgId  In NUMBER)
RETURN VARCHAR2
IS

  v_address1                   VARCHAR2(80);
BEGIN
-- Required currently for Demand Status Inquiry Report
-- x_OrgId is either Ship_To_Org_id / Intrmd_ShipTo_OrgId

  IF (x_OrgId IS NOT NULL) THEN
    --
    -- Following query is changed as per TCA obsolescence project.
	select	loc.address1
	into	v_address1
	from	HZ_CUST_SITE_USES_ALL cust_site,
		HZ_PARTY_SITES PARTY_SITE,
		HZ_LOCATIONS LOC,
		HZ_CUST_ACCT_SITES_ALL		 ACCT_SITE
	where	cust_site.site_use_code = 'SHIP_TO'
	and	cust_site.site_use_id = x_OrgId
	and	cust_site.CUST_ACCT_SITE_ID = acct_site.CUST_ACCT_SITE_ID
	AND	ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
	AND	LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID;
    --
    return v_address1;

  ELSE
    return NULL;

  END IF;

END;

/*===========================================================================

          PROCEDURE    GetTpContext

===========================================================================*/
PROCEDURE GetTPContext( x_Op_rec  IN rlm_rd_sv.t_generic_rec ,
                        x_customer_number OUT NOCOPY VARCHAR2,
                        x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                        x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2,
                        x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                        x_tp_group_code OUT NOCOPY VARCHAR2)
IS
   --
   v_Progress VARCHAR2(3) := '010';

   --
   -- Following cursor is changed as per TCA obsolescence project.
   CURSOR C is
	SELECT	ETG.tp_group_code
	FROM	ece_tp_headers ETH,
		ece_tp_group ETG,
		HZ_CUST_SITE_USES_ALL cust_site,
		HZ_CUST_ACCT_SITES ACCT_SITE
	WHERE	ACCT_SITE.CUST_ACCOUNT_ID = x_Op_rec.customer_id
	AND	cust_site.site_use_id = x_Op_rec.ship_to_org_id
	and	cust_site.CUST_ACCT_SITE_ID = acct_site.CUST_ACCT_SITE_ID
	AND	ETH.tp_header_id = ACCT_SITE.tp_header_id
	AND	ETG.tp_group_id = ETH.tp_group_id
	AND	cust_site.site_use_code = 'SHIP_TO';
   --
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(k_SDEBUG,'GetTPContext');
      rlm_core_sv.dlog(k_DEBUG,'customer_id', x_Op_rec.customer_id);
      rlm_core_sv.dlog(k_DEBUG,'x_Op_rec.ship_to_org_id',
                             x_Op_rec.ship_to_org_id);
      rlm_core_sv.dlog(k_DEBUG,'x_Op_rec.intmed_ship_to_org_id',
                             x_Op_rec.intmed_ship_to_org_id);
      rlm_core_sv.dlog(k_DEBUG,'x_Op_rec.invoice_to_org_id',
                             x_Op_rec.invoice_to_org_id);
   END IF;
   --
   BEGIN
     --
     -- Following query is changed as per TCA obsolescence project.
	SELECT	ACCT_SITE.ece_tp_location_code
	INTO	x_ship_to_ece_locn_code
	FROM	HZ_CUST_ACCT_SITES ACCT_SITE ,
		HZ_CUST_SITE_USES_ALL CUST_SITE
	WHERE	cust_site.site_use_id = x_Op_rec.ship_to_org_id
	AND	cust_site.site_use_code = 'SHIP_TO'
	AND   	CUST_SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID;
     --
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_ship_to_ece_locn_code := NULL;
   END;
   --
   BEGIN
      --
      -- Following query is changed as per TCA obsolescence project.
	SELECT	ACCT_SITE.ece_tp_location_code
	INTO	x_bill_to_ece_locn_code
	FROM	HZ_CUST_ACCT_SITES ACCT_SITE ,
		HZ_CUST_SITE_USES_ALL CUST_SITE
	WHERE	cust_site.site_use_id = x_Op_rec.invoice_to_org_id
	AND	cust_site.site_use_code = 'BILL_TO'
	AND   	CUST_SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID;
      --

   EXCEPTION
      --
      WHEN NO_DATA_FOUND THEN
         x_bill_to_ece_locn_code := NULL;
      WHEN OTHERS THEN
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
         END IF;
         --
         raise;
      --
   END;

   BEGIN
     --
     -- Following query is changed as per TCA obsolescence project.
	SELECT	ACCT_SITE.ece_tp_location_code
	INTO	x_inter_ship_to_ece_locn_code
	FROM	HZ_CUST_ACCT_SITES ACCT_SITE ,
		HZ_CUST_SITE_USES_ALL CUST_SITE
	WHERE	cust_site.site_use_id = x_Op_rec.intmed_ship_to_org_id
	AND	cust_site.site_use_code = 'SHIP_TO'
	AND   	CUST_SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID;
     --
   EXCEPTION
     --
     WHEN NO_DATA_FOUND THEN
            x_inter_ship_to_ece_locn_code := NULL;
     --
   END;
   --
   IF x_Op_rec.customer_id is NOT NULL THEN
      --
      OPEN C;
      FETCH C INTO x_tp_Group_code;
      IF C%NOTFOUND THEN
        raise NO_DATA_FOUND;
      END IF;
      CLOSE C;
      --
      BEGIN
         --
         -- Following query is changed as per TCA obsolescence project.
	 SELECT account_number
	 INTO   x_customer_number
	 FROM   HZ_CUST_ACCOUNTS CUST_ACCT
	 WHERE 	CUST_ACCT.CUST_ACCOUNT_ID = x_Op_rec.Customer_Id;
         --
      EXCEPTION
         --
         WHEN NO_DATA_FOUND THEN
              x_customer_number := NULL;
         WHEN OTHERS THEN
              --
              IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(k_DEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
              END IF;
              --
              raise;
      END;

   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG, 'customer_number', x_customer_number);
      rlm_core_sv.dlog(k_DEBUG,'x_ship_to_ece_locn_code', x_ship_to_ece_locn_code);
      rlm_core_sv.dlog(k_DEBUG,'x_bill_to_ece_locn_code', x_bill_to_ece_locn_code);
      rlm_core_sv.dlog(k_DEBUG,'x_inter_ship_to_ece_locn_code',
                                x_inter_ship_to_ece_locn_code);
      rlm_core_sv.dlog(k_DEBUG,'x_tp_Group_code', x_tp_Group_code);
      rlm_core_sv.dpop(k_SDEBUG);
   END IF;
   --
EXCEPTION
   --
   WHEN NO_DATA_FOUND THEN
      --
      x_customer_number := NULL;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'No data found for' , x_Op_rec.customer_id);
         rlm_core_sv.dpop(k_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      --
      rlm_message_sv.sql_error('rlm_validatedemand_sv.GetTPContext',v_Progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
      --
END GetTPContext;
--
/*===========================================================================

          PROCEDURE    GetIntransitShippedLines

===========================================================================*/
--
PROCEDURE GetIntransitShippedLines (x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                                    x_Group_rec IN rlm_dp_sv.t_Group_rec,
                                    x_optional_match_rec IN  RLM_RD_SV.t_generic_rec,
                                    x_min_horizon_date IN VARCHAR2,
                                    x_intransit_qty IN OUT NOCOPY NUMBER
                                    )
IS

  v_select_clause     VARCHAR2(32000);
  v_where_clause      VARCHAR2(32000);
  v_final_sql         VARCHAR2(32000);
  v_ship_from_org_id  NUMBER;
  l_effective_start_date DATE; --Bugfix 6485729
  l_effective_end_date   DATE; --Bugfix 6485729

  TYPE t_Cursor_ref IS REF CURSOR;
   c_sum            t_Cursor_ref;

  e EXCEPTION;

BEGIN

  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(k_SDEBUG,'GetIntransitShippedLines');
  END IF;

  --ITS should be complete before a WDD/OM line can be considered intransit.
  --OE tables are referenced while considered shipped lines.
  -- Bugfix 5608510 added oe_intefaced_flag check
  v_select_clause :=  'SELECT SUM(NVL(o.shipped_quantity,0))
                       FROM oe_order_lines o';

--Bugfix 6485729 Start
--This condition has been added to reconcile against other BSO's for the past due demands falling under different orders.
 IF x_Group_rec.blanket_number IS NOT NULL THEN

      SELECT effective_start_date, effective_end_date
      INTO l_effective_start_date, l_effective_end_date
      FROM rlm_blanket_rso
      WHERE blanket_number = x_Group_rec.blanket_number
      AND rso_hdr_id = x_Group_rec.order_header_id;

  IF TO_DATE(x_optional_match_rec.industry_attribute2,'RRRR/MM/DD HH24:MI:SS') < trunc(l_effective_start_date) THEN

     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'Reconciling against all the Blanket Release orders');
     END IF;

	 v_where_clause := ' WHERE o.header_id IN'||
	       	           ' (SELECT rbr.rso_hdr_id FROM rlm_blanket_rso rbr,oe_order_headers oh WHERE rbr.blanket_number = '||x_Group_rec.blanket_number||
                       '  AND oh.header_id = rbr.rso_hdr_id AND oh.open_flag = '||'''Y'''||')';

  ELSE
     v_where_clause := ' WHERE o.header_id = :order_header_id' ;
     g_WhereTab(g_WhereTab.COUNT+1) := x_Group_rec.order_header_id;
  END IF;

 ELSE
    v_where_clause := ' WHERE o.header_id = :order_header_id' ;
    g_WhereTab(g_WhereTab.COUNT+1) := x_Group_rec.order_header_id;
 END IF;
--Bugfix 6485729 End

  v_where_clause :=   v_where_clause ||
                   ' AND o.ship_to_org_id = :ship_to_org_id' ||
                   ' AND NVL(o.intmed_ship_to_org_id,'||k_NNULL||') = NVL(:intmed_ship_to_org_id,'||k_NNULL||')'||--Bugfix 5911991
                   ' AND o.ordered_item_id = :customer_item_id ' ||
                   ' AND o.inventory_item_id = :inventory_item_id ' ||
		           ' AND o.source_document_type_id = 5 ' ||
                   ' AND TO_DATE(o.industry_attribute2,''RRRR/MM/DD HH24:MI:SS'')
                     BETWEEN TO_DATE(:sched_horizon_start_date,''RRRR/MM/DD HH24:MI:SS'')
                     AND TO_DATE(:sched_horizon_end_date,''RRRR/MM/DD HH24:MI:SS'') '||
                   ' AND  o.shipped_quantity IS NOT NULL'||
                   ' AND o.ACTUAL_SHIPMENT_DATE IS NOT NULL';

  --Add bind var to table
--  g_WhereTab(g_WhereTab.COUNT+1) := x_Group_rec.order_header_id; --Bugfix 6485729
  g_WhereTab(g_WhereTab.COUNT+1) := x_Group_rec.ship_to_org_id;
  g_WhereTab(g_WhereTab.COUNT+1) := x_Group_rec.intmed_ship_to_org_id; --Bugfix 5911991
  g_WhereTab(g_WhereTab.COUNT+1) := x_Group_rec.customer_item_id;
  g_WhereTab(g_WhereTab.COUNT+1) := x_Group_rec.inventory_item_id;
  g_WhereTab(g_WhereTab.COUNT+1) := x_min_horizon_date;
  g_WhereTab(g_WhereTab.COUNT+1) := TO_CHAR(TRUNC(x_Sched_rec.sched_horizon_end_date)+1, 'RRRR/MM/DD HH24:MI:SS');

 --optional attributes (schedule_date is not considered for intransit calc based on shipped lines)

 IF x_group_rec.match_across_rec.request_date = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND o.request_date = TO_DATE(:request_date,''RRRR/MM/DD HH24:MI:SS'')';
     g_WhereTab(g_WhereTab.COUNT+1) := to_char(x_optional_match_rec.request_date,'RRRR/MM/DD HH24:MI:SS');
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.request_date = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND o.request_date = DECODE(o.rla_schedule_type_code,:schedule_type, TO_DATE(:request_date,''RRRR/MM/DD HH24:MI:SS''), o.request_date)';
      --
      g_WhereTab(g_WhereTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_WhereTab(g_WhereTab.COUNT+1) := to_char(x_optional_match_rec.request_date,'RRRR/MM/DD HH24:MI:SS');
      --
    END IF;
    --
  END IF;
  --

 IF x_group_rec.match_across_rec.cust_production_line = 'Y' THEN
   --
    v_where_clause := v_where_clause ||
     ' AND NVL(o.customer_production_line,'''||k_VNULL||
     ''') = NVL(:cust_production_line,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.cust_production_line;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.cust_production_line = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.customer_production_line,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:cust_production_line,'''||k_VNULL||'''), NVL(o.customer_production_line,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.cust_production_line;
     --
   END IF;
   --
 END IF;

 --
 IF x_group_rec.match_across_rec.customer_dock_code = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.customer_dock_code,'''||k_VNULL||''') = NVL(:customer_dock_code,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.customer_dock_code;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.customer_dock_code = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.customer_dock_code,'''||k_VNULL||''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:customer_dock_code,'''||k_VNULL||'''),NVL(o.customer_dock_code,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.customer_dock_code;

     --
   END IF;
   --
 END IF;

 --
 IF x_group_rec.match_across_rec.cust_po_number = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.cust_po_number,'''||k_VNULL||''') = NVL(:cust_po_number,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.cust_po_number;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.cust_po_number = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.cust_po_number,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:cust_po_number,'''||k_VNULL||'''),NVL(o.cust_po_number,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.cust_po_number;

     --
   END IF;
   --
 END IF;

 --
 IF x_group_rec.match_across_rec.customer_item_revision = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.item_revision,'''||k_VNULL||''') = NVL(:customer_item_revision,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.customer_item_revision;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.customer_item_revision = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.item_revision,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:customer_item_revision,'''||k_VNULL||'''),NVL(o.item_revision,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.customer_item_revision;

     --
   END IF;
   --
 END IF;
 --

 --
 IF x_group_rec.match_across_rec.customer_job = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.customer_job,'''||k_VNULL||''') = NVL(:customer_job,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.customer_job;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.customer_job = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.customer_job,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:customer_job,'''||k_VNULL||'''),NVL(o.customer_job,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.customer_job;

     --
   END IF;
   --
 END IF;
 --


 --
 IF x_group_rec.match_across_rec.cust_model_serial_number = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.cust_model_serial_number,'''||k_VNULL||''') = NVL(:cust_model_serial_number,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.cust_model_serial_number;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.cust_model_serial_number = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.cust_model_serial_number,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:cust_model_serial_number,'''||k_VNULL||'''),NVL(o.cust_model_serial_number,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.cust_model_serial_number;

     --
   END IF;
   --
 END IF;
 --

 --
 IF x_group_rec.match_across_rec.cust_production_seq_num = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.cust_production_seq_num,'''||k_VNULL||''') = NVL(:cust_production_seq_num,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.cust_production_seq_num;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.cust_production_seq_num = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.cust_production_seq_num,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:cust_production_seq_num,'''||k_VNULL||'''),NVL(o.cust_production_seq_num,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.cust_production_seq_num;

     --
   END IF;
   --
 END IF;
 --

 --
 IF x_group_rec.match_across_rec.industry_attribute1 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.industry_attribute1,'''||k_VNULL||''') = NVL(:industry_attribute1,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute1;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.industry_attribute1 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.industry_attribute1,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute1,'''||k_VNULL||'''),NVL(o.industry_attribute1,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute1;

     --
   END IF;
   --
 END IF;
 --
--
 IF x_group_rec.match_across_rec.industry_attribute2 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.industry_attribute2,'''||k_VNULL||''') = NVL(:industry_attribute2,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute2;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.industry_attribute2 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.industry_attribute2,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute2,'''||k_VNULL||'''),NVL(o.industry_attribute2,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute2;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.industry_attribute4 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.industry_attribute4,'''||k_VNULL||''') = NVL(:industry_attribute4,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute4;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.industry_attribute4 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.industry_attribute4,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute4,'''||k_VNULL||'''),NVL(o.industry_attribute4,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute4;

     --
   END IF;
   --
 END IF;
 --

 --
 IF x_group_rec.match_across_rec.industry_attribute5 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.industry_attribute5,'''||k_VNULL||''') = NVL(:industry_attribute5,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute5;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.industry_attribute5 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.industry_attribute5,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute5,'''||k_VNULL||'''),NVL(o.industry_attribute5,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute5;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.industry_attribute6 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.industry_attribute6,'''||k_VNULL||''') = NVL(:industry_attribute6,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute6;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.industry_attribute6 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.industry_attribute6,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute6,'''||k_VNULL||'''),NVL(o.industry_attribute6,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute6;

     --
   END IF;
   --
 END IF;
 --

 --
 IF x_group_rec.match_across_rec.industry_attribute10 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.industry_attribute10,'''||k_VNULL||''') = NVL(:industry_attribute10,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute10;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.industry_attribute10 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.industry_attribute10,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute10,'''||k_VNULL||'''),NVL(o.industry_attribute10,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute10;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.industry_attribute11 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.industry_attribute11,'''||k_VNULL||''') = NVL(:industry_attribute11,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute11;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.industry_attribute11 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.industry_attribute11,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute11,'''||k_VNULL||'''),NVL(o.industry_attribute11,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute11;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.industry_attribute12 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.industry_attribute12,'''||k_VNULL||''') = NVL(:industry_attribute12,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute12;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.industry_attribute12 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.industry_attribute12,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute12,'''||k_VNULL||'''),NVL(o.industry_attribute12,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute12;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.industry_attribute13 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.industry_attribute13,'''||k_VNULL||''') = NVL(:industry_attribute13,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute13;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.industry_attribute13 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.industry_attribute13,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute13,'''||k_VNULL||'''),NVL(o.industry_attribute13,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute13;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.industry_attribute14 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.industry_attribute14,'''||k_VNULL||''') = NVL(:industry_attribute14,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute14;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.industry_attribute14 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.industry_attribute14,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:industry_attribute14,'''||k_VNULL||'''),NVL(o.industry_attribute14,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.industry_attribute14;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute1 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute1,'''||k_VNULL||''') = NVL(:attribute1,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute1;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute1 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute1,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute1,'''||k_VNULL||'''),NVL(o.attribute1,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute1;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute2 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute2,'''||k_VNULL||''') = NVL(:attribute2,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute2;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute2 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute2,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute2,'''||k_VNULL||'''),NVL(o.attribute2,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute2;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute3 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute3,'''||k_VNULL||''') = NVL(:attribute3,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute3;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute3 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute3,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute3,'''||k_VNULL||'''),NVL(o.attribute3,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute3;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute4 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute4,'''||k_VNULL||''') = NVL(:attribute4,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute4;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute4 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute4,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute4,'''||k_VNULL||'''),NVL(o.attribute4,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute4;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute5 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute5,'''||k_VNULL||''') = NVL(:attribute5,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute5;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute5 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute5,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute5,'''||k_VNULL||'''),NVL(o.attribute5,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute5;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute6 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute6,'''||k_VNULL||''') = NVL(:attribute6,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute6;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute6 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute6,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute6,'''||k_VNULL||'''),NVL(o.attribute6,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute6;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute7 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute7,'''||k_VNULL||''') = NVL(:attribute7,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute7;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute7 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute7,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute7,'''||k_VNULL||'''),NVL(o.attribute7,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute7;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute8 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute8,'''||k_VNULL||''') = NVL(:attribute8,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute8;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute8 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute8,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute8,'''||k_VNULL||'''),NVL(o.attribute8,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute8;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute9 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute9,'''||k_VNULL||''') = NVL(:attribute9,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute9;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute9 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute9,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute9,'''||k_VNULL||'''),NVL(o.attribute9,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute9;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute10 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute10,'''||k_VNULL||''') = NVL(:attribute10,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute10;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute10 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute10,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute10,'''||k_VNULL||'''),NVL(o.attribute10,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute10;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute11 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute11,'''||k_VNULL||''') = NVL(:attribute11,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute11;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute11 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute11,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute11,'''||k_VNULL||'''),NVL(o.attribute11,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute11;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute12 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute12,'''||k_VNULL||''') = NVL(:attribute12,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute12;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute12 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute12,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute12,'''||k_VNULL||'''),NVL(o.attribute12,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute12;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute13 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute13,'''||k_VNULL||''') = NVL(:attribute13,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute13;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute13 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute13,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute13,'''||k_VNULL||'''),NVL(o.attribute13,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute13;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute14 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute14,'''||k_VNULL||''') = NVL(:attribute14,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute14;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute14 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute14,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute14,'''||k_VNULL||'''),NVL(o.attribute14,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute14;

     --
   END IF;
   --
 END IF;
 --
 --
 IF x_group_rec.match_across_rec.attribute15 = 'Y' THEN
   --
   v_where_clause := v_where_clause ||
     ' AND NVL(o.attribute15,'''||k_VNULL||''') = NVL(:attribute15,'''||k_VNULL||''')';

   g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute15;
   --
 ELSE
   --
   IF x_group_rec.match_within_rec.attribute15 = 'Y' THEN
     --
     v_where_clause := v_where_clause ||
       ' AND NVL(o.attribute15,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(:attribute15,'''||k_VNULL||'''),NVL(o.attribute15,'''||k_VNULL||'''))';

     g_WhereTab(g_WhereTab.COUNT+1):=x_Sched_rec.schedule_type;
     g_WhereTab(g_WhereTab.COUNT+1):=x_optional_match_rec.attribute15;

     --
   END IF;
   --
 END IF;
 --
 --end optional

   --ATP

   IF RLM_MANAGE_DEMAND_SV.IsATPItem(x_group_rec.ship_from_org_id,
                                     x_group_rec.inventory_item_id) THEN
      --
      v_ship_from_org_id := NULL;
      --
   ELSE
      --
      v_ship_from_org_id := x_group_rec.ship_from_org_id;
      --
   END IF;

  IF v_ship_from_org_id IS NOT NULL THEN
   --
   v_where_clause := v_where_clause ||
      ' AND o.ship_from_org_id = :ship_from_org_id';
   --
   g_WhereTab(g_WhereTab.COUNT+1) := x_Group_rec.ship_from_org_id;
   --
   v_where_clause := v_where_clause ||
      ' AND NVL(o.industry_attribute15,'''||k_VNULL||
      ''') = NVL(:industry_attribute15,'''||k_VNULL|| ''')';

   g_WhereTab(g_WhereTab.COUNT+1) := x_optional_match_rec.industry_attribute15;

   --
  END IF;
  --
  -- blankets
  --
  IF x_Group_rec.blanket_number IS NOT NULL THEN
   v_where_clause := v_where_clause || ' AND o.blanket_number = :blanket_number';
   g_whereTab(g_whereTab.COUNT+1) := x_Group_rec.blanket_number;
   --
  END IF;
  --
  v_final_sql := v_select_clause||v_where_clause;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(k_DEBUG,'Dynamic SQL',v_final_sql);
    rlm_core_sv.dlog(k_DEBUG,'g_wheretab count', g_whereTab.COUNT);
  END IF;
  -- print bind variables
  FOR i in 1..g_whereTab.COUNT
  LOOP
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG,'Value for g_where_tab('||to_char(i)||')', g_whereTab(i));
    END IF;
  END LOOP;
  --
  RLM_CORE_SV.OpenDynamicCursor(c_sum,v_final_sql,g_wheretab);
  FETCH c_sum INTO x_intransit_qty;
  CLOSE c_sum;
  --
  g_wheretab.delete;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(k_DEBUG,'Intransit Qty', x_intransit_qty);
    rlm_core_sv.dpop(k_SDEBUG,'GetIntransitShippedLines');
  END IF;
  --
EXCEPTION
  When others then
    IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(k_SDEBUG,'GetIntransitShippedLines'||substr(sqlerrm,1,200));
    END IF;
    raise;
END GetIntransitShippedLines;

END RLM_EXTINTERFACE_SV;

/
