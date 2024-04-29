--------------------------------------------------------
--  DDL for Package Body INV_PICK_WAVE_PICK_CONFIRM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PICK_WAVE_PICK_CONFIRM_PUB" AS
/* $Header: INVPCPWB.pls 120.1.12010000.4 2009/09/15 11:03:27 skommine ship $ */

   debug_mode boolean DEFAULT TRUE;

procedure TraceLog(err_msg IN VARCHAR2, module IN VARCHAR2, p_level IN NUMBER := 9) is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
	-- Call trace methoud from trx util.
   IF (l_debug = 1) THEN
      INV_LOG_UTIL.TRACE(err_msg, module, p_level);
   END IF;
end TraceLog;

PROCEDURE Pick_Confirm
(
    p_api_version_number	    IN  NUMBER
,   p_init_msg_list	 	    IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit			    IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status		    OUT NOCOPY VARCHAR2
,   x_msg_count			    OUT NOCOPY NUMBER
,   x_msg_data			    OUT NOCOPY VARCHAR2
,   p_move_order_type               IN  NUMBER
,   p_transaction_mode		    IN  NUMBER
,   p_trolin_tbl                    IN  INV_Move_Order_PUB.Trolin_Tbl_Type
,   p_mold_tbl			    IN  INV_MO_LINE_DETAIL_UTIL.g_mmtt_tbl_type
,   x_mmtt_tbl      	            IN OUT NOCOPY INV_MO_LINE_DETAIL_UTIL.g_mmtt_tbl_type
,   x_trolin_tbl                    IN OUT NOCOPY INV_Move_Order_PUB.Trolin_Tbl_Type
,   p_transaction_date              IN  DATE DEFAULT NULL
) IS
    l_api_version_number NUMBER := 1.0;
    l_api_name 		 VARCHAR2(80) := 'INV_PICK_WAVE_PICK_CONFIRM_PUB';
    l_move_order_type 	 NUMBER := p_move_order_type;
    l_trolin_tbl	 INV_Move_Order_PUB.Trolin_Tbl_Type := p_trolin_tbl;
    l_trolin_rec 	 INV_Move_Order_PUB.Trolin_Rec_Type;
    l_mold_tbl		 INV_MO_Line_Detail_Util.g_mmtt_Tbl_type := p_mold_tbl;
    l_return_status      VARCHAR2(1);
    l_sum_trx_qty	 NUMBER := 0;
    l_qty_delivered      NUMBER := 0;
    l_qty_detailed       NUMBER := 0;
    l_transaction_header_id NUMBER;
    l_success 		NUMBER;
    lot_success		VARCHAR2(50);
    l_msg_data		VARCHAR2(20000);
    l_msg_count		NUMBER;
    l_no_violation	BOOLEAN;
    p_timeout 		NUMBER := null;
    l_rc_field		NUMBER;
    -- variable related to fnd_synchronous
    l_func varchar2(240);
    l_program VARCHAR2(240);
    l_args VARCHAR2(240);
    rtvl NUMBER;
    resp_appl_id NUMBER;
    resp_id NUMBER;
    l_shipping_attr              WSH_INTERFACE.ChangedAttributeTabType;
    l_source_header_id           NUMBER;
    l_source_line_id             NUMBER;
    l_delivery_detail_id         NUMBER;
    l_quantity_reserved          NUMBER;
    l_message                    VARCHAR2(2000);
    l_released_status VARCHAR2(1);
    l_customer_item_id NUMBER;
    l_subinventory VARCHAR2(20);
    l_locator_id NUMBER;
    l_lot_count NUMBER;
    i NUMBER;
    l_organization_id NUMBER;   -- Added for bug 1992880
    l_open_past_period BOOLEAN; -- Added for bug 1992880
    l_period_id INTEGER; -- Added for bug 1992880
    l_transaction_date DATE := NULL; -- Added for bug 1992880
      l_old_tm_success  BOOLEAN ; --Bug 2997177
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_proc_mode number := NVL(FND_PROFILE.VALUE('AUTO_PICK_CONFIRM_TXN'),1);
BEGIN

      savepoint TO_TRX_LINE_SAVE;
   --  Standard call to check for call compatibility
      IF (l_debug = 1) THEN
         TraceLog('Inside pick_wave_pick_confirm', 'Pick_confirm');
      END IF;
   IF NOT FND_API.Compatible_API_Call
     (   l_api_version_number
	 ,   p_api_version_number
	 ,   l_api_name
	 ,   G_PKG_NAME
	 )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- bug 2307057 Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
   END IF;


   --    if( l_trolin_tbl.count = 0 OR (l_trolin_tbl.count = 0 AND
   -- l_mold_tbl.count = 0)) then
   -- AS:
   -- Commented out the previous line and added the one below.
   -- User should be able to pass either the mol or the mmtt line
   -- Only if both are zero should it error out

   if( l_trolin_tbl.count = 0 AND l_mold_tbl.count = 0) then

      FND_MESSAGE.SET_NAME('INV', 'INV_NO_LINES_TO_PICK_CONFIRM');
      FND_MSG_PUB.add;
      l_return_status := FND_API.G_RET_STS_ERROR;
      raise FND_API.G_EXC_ERROR;
   end if;

   select mtl_material_transactions_s.nextval
     into l_transaction_header_id
     from dual;
      IF (l_debug = 1) THEN
         TraceLog('transaction_header_id = ' || l_transaction_header_id, 'Pick_Confirm');
      END IF;

   if( l_trolin_tbl.count <> 0 ) then
      -- if the table of mol is passed
         IF (l_debug = 1) THEN
            TraceLog('move orderline = ' || l_trolin_tbl.count, 'Pick_Confirm');
         END IF;
      i := l_trolin_tbl.FIRST;
      while i is not null LOOP
	 IF (l_debug = 1) THEN
      	 TraceLog('mo line_id is  = ' || l_trolin_tbl(i).line_id, 'Pick_Confirm');
	 END IF;
	 -- only process the valid move order, fix bug 1540709.
	 IF (l_trolin_tbl(i).return_status <> FND_API.G_RET_STS_UNEXP_ERROR and
	     l_trolin_tbl(i).return_status <> FND_API.G_RET_STS_ERROR) THEN

	    --if( l_trolin_tbl(i) is not null ) then
	    l_trolin_rec := INV_Trolin_Util.Query_Row(l_trolin_tbl(i).line_id);
	    l_trolin_tbl(i) := l_trolin_rec;
	    l_qty_detailed := l_trolin_tbl(i).quantity_detailed;
	    l_qty_delivered := nvl(l_trolin_tbl(i).quantity_delivered, 0);
   	    IF (l_debug = 1) THEN
      	    TraceLog(to_char(i) || ' ' || l_trolin_rec.line_id || ' l_qty_detailed = ' || l_qty_detailed, 'Pick_Confirm');
      	    TraceLog(to_char(i) || ' ' || l_trolin_rec.line_id || ' l_qty_delivered = ' || l_qty_delivered, 'Pick_Confirm');
	    END IF;
	    if( L_qty_detailed = l_qty_delivered OR l_qty_detailed = 0 ) then
	       FND_MESSAGE.SET_NAME('INV', 'INV_PICK_QTY_ERROR');
	       FND_MSG_PUB.ADD;
	       --rollback to TO_TRX_LINE_SAVE;
	       --raise FND_API.G_EXC_ERROR;
	     else
	       l_mold_tbl := INV_MO_LINE_DETAIL_UTIL.Query_Rows( p_line_id => l_trolin_tbl(i).line_id);
   	       IF (l_debug = 1) THEN
      	       TraceLog('mold records = ' || l_mold_tbl.count, 'Pick_Confirm');
	       END IF;
	       --end if;
	       --TraceLog('mold records = ' || l_mold_tbl.count);
	       for j in 1..l_mold_tbl.count LOOP
		  l_mold_tbl(j).transaction_status := 3;
		  l_mold_tbl(j).transaction_mode := p_transaction_mode;
		  l_mold_tbl(j).transaction_header_id := l_transaction_header_id;
		  --l_mold_tbl(j).transaction_source_id := l_trolin_tbl(i).header_id;
		  l_mold_tbl(j).source_line_id := l_trolin_tbl(i).line_id;


		  -- Bug 1992880 : Added check to check the account period ID and it is
		  -- -1 error out or else update the MMTT with this account period ID -
		  -- vipartha


		  IF l_transaction_date IS NULL OR l_transaction_date
		    <> l_mold_tbl(j).transaction_date THEN

                   -- Bug 3380018 while transacting mo via API transaction_date should be user defined.
                     IF p_transaction_date IS NOT NULL THEN
                        TraceLog('p_transaction_date: '||p_transaction_date, 'Pick_confirm');
                        IF p_transaction_date > sysdate THEN
                          TraceLog('Error: Transaction date cannot be a future date', 'Pick_confirm');
                          FND_MESSAGE.SET_NAME('INV', 'INV_INT_TDATEEX');
                          FND_MSG_PUB.add;
                          raise FND_API.G_EXC_ERROR;
                        END IF;
                        l_mold_tbl(j).transaction_date := p_transaction_date;
                     END IF;

		     l_transaction_date := l_mold_tbl(j).transaction_date;
		     l_organization_id := l_mold_tbl(j).organization_id;

		     invttmtx.tdatechk (
					org_id => l_organization_id,
					transaction_date => l_transaction_date,
					period_id => l_period_id,
					open_past_period =>
					l_open_past_period);


		     TraceLog('l_period_id: '||l_period_id, 'Pick_confirm');
		     IF (l_period_id = -1 or l_period_id = 0) THEN
			FND_MESSAGE.SET_NAME('INV', 'INV_NO_OPEN_PERIOD');
			FND_MSG_PUB.add;
			l_return_status := FND_API.G_RET_STS_ERROR;
			raise FND_API.G_EXC_ERROR;
		     END IF;

		  END IF;
		  l_mold_tbl(j).acct_period_id := l_period_id;
		  -- End Bug 1992880;

		  select count(transaction_temp_id)
		    into l_lot_count
		    from mtl_transaction_lots_temp
		    where transaction_temp_id = l_mold_tbl(j).transaction_temp_id;
   		  IF (l_debug = 1) THEN
      		  TraceLog('l_lot_count is before lot_handling ' || l_lot_count, 'Pick_Confirm');
   		  END IF;

		  if( l_lot_count > 0 and l_mold_tbl(j).lot_number is not null ) then
		     l_mold_tbl(j).lot_number := null;
		  end if;
   		  IF (l_debug = 1) THEN
      		  TraceLog('mold pick slip number is ' || l_mold_tbl(j).pick_slip_number, 'Pick_Confirm');
		  END IF;
		  inv_mo_line_detail_util.update_row(l_return_status, l_mold_tbl(j));
   		  IF (l_debug = 1) THEN
      		  TraceLog('after update transaction_status = 3', 'Pick_Confirm');
		  END IF;
		  if( l_return_status = FND_API.G_RET_STS_ERROR ) then
		     fnd_message.set_name('INV', 'INV_COULD_NOT_UPATE_RECORD');
		     fnd_msg_pub.add;
   		     IF (l_debug = 1) THEN
      		     TraceLog('error in update mold', 'Pick_Confirm');
		     END IF;
		     rollback to TO_TRX_LINE_SAVE;
		     raise FND_API.G_EXC_ERROR;
		   elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
		     IF (l_debug = 1) THEN
      		     TraceLog('error in update mold', 'Pick_Confirm');
		     END IF;
		     fnd_message.set_name('INV', 'INV_COULD_NOT_UPATE_RECORD');
		     fnd_msg_pub.add;
		     rollback to TO_TRX_LINE_SAVE;
		     raise FND_API.G_EXC_UNEXPECTED_ERROR;
		  end if;
   		  IF (l_debug = 1) THEN
      		  TraceLog('end of loop of mold, still inside loop', 'Pick Confirm');
		  END IF;
	       end loop; -- mold loop
   	       IF (l_debug = 1) THEN
      	       TraceLog('end of loop of mold', 'Pick Confirm');
   	       END IF;
	       l_trolin_tbl(i).transaction_header_id := l_transaction_header_id;
-- obtain program and user info

                 l_trolin_tbl(i).last_update_date := SYSDATE;

                 l_trolin_tbl(i).last_update_login := fnd_global.login_id;

                 if l_trolin_tbl(i).last_update_login = -1 THEN
                        l_trolin_tbl(i).last_update_login :=
				fnd_global.conc_login_id;
                 end if;
                l_trolin_tbl(i).last_updated_by := fnd_global.user_id;
                l_trolin_tbl(i).program_id := fnd_global.conc_program_id;
                l_trolin_tbl(i).program_update_date := SYSDATE;
                l_trolin_tbl(i).request_id := fnd_global.conc_request_id;
                l_trolin_tbl(i).program_application_id :=
				fnd_global.prog_appl_id;

   	       IF (l_debug = 1) THEN
      	       TraceLog('calling update_row of trolin', 'Pick Confirm');
	       END IF;
	       inv_trolin_util.update_row(l_trolin_tbl(i));
   	       IF (l_debug = 1) THEN
      	       TraceLog('after calling update_row of trolin', 'Pick Confirm');
	       END IF;
	    end if;
	 END IF;
	 i := l_trolin_tbl.NEXT(i);
      end loop; -- trolin loop
    else
      -- if only line detail records is passed
      If( l_mold_tbl.count <> 0 ) then
	 for j in 1..l_mold_tbl.count LOOP
	    --if( l_mold_tbl(j) is not null ) then
	    l_trolin_tbl(1) := inv_trolin_util.query_row(p_line_id => l_mold_tbl(j).move_order_line_id);

	    l_qty_detailed := l_trolin_tbl(1).quantity_detailed;
	    l_qtY_delivered := l_trolin_tbl(1).quantity_delivered;
	    if( l_qty_detailed = l_qty_delivered OR l_qty_detailed = 0 ) then
	       FND_MESSAGE.SET_NAME('INV', 'INV_PICK_QTY_ERROR');
	       FND_MSG_PUB.ADD;
	       rollback to TO_TRX_LINE_SAVE;
	       raise FND_API.G_EXC_ERROR;
	    end if;
	    l_mold_tbl(j).transaction_status := 3;
	    l_mold_tbl(j).transaction_mode := p_transaction_mode;
	    l_mold_tbl(j).transaction_header_id := l_transaction_header_id;

	    -- Bug 1992880 : Added check to chekc the account period ID and it is
	    -- -1 error out or else update the MMTT with this account period ID -
	    -- vipartha

	    IF l_transaction_date IS NULL OR l_transaction_date
	      <> l_mold_tbl(j).transaction_date THEN

               -- Bug 3380018 while transacting mo via API transaction_date should be user defined.
               IF p_transaction_date IS NOT NULL THEN
                    TraceLog('p_transaction_date: '||p_transaction_date, 'Pick_confirm');
                    IF p_transaction_date > sysdate THEN
                          TraceLog('Error: Transaction date cannot be a future date', 'Pick_confirm');
                          FND_MESSAGE.SET_NAME('INV', 'INV_INT_TDATEEX');
                          FND_MSG_PUB.add;
                          raise FND_API.G_EXC_ERROR;
                    END IF;
                    l_mold_tbl(j).transaction_date := p_transaction_date;
               END IF;

	       l_transaction_date := l_mold_tbl(j).transaction_date;
	       l_organization_id := l_mold_tbl(j).organization_id;

	       invttmtx.tdatechk (
				  org_id => l_organization_id,
				  transaction_date => l_transaction_date,
				  period_id => l_period_id,
				  open_past_period => l_open_past_period);

               TraceLog('l_period_id: '||l_period_id, 'Pick_confirm');
	       IF (l_period_id = -1 or l_period_id = 0) THEN
		  FND_MESSAGE.SET_NAME('INV', 'INV_NO_OPEN_PERIOD');
		  FND_MSG_PUB.add;
		  l_return_status := FND_API.G_RET_STS_ERROR;
		  raise FND_API.G_EXC_ERROR;
	       END IF;

	    END IF;

	    l_mold_tbl(j).acct_period_id :=  l_period_id;
	    -- End Bug 1992880;

	    inv_mo_line_detail_util.update_row(l_return_status, l_mold_tbl(j));
   	    IF (l_debug = 1) THEN
      	    TraceLog('after update transaction_status = 3', 'Pick_Confirm');
	    END IF;
	    if( l_return_status = FND_API.G_RET_STS_ERROR ) then
   	       IF (l_debug = 1) THEN
      	       TraceLog('error in update mold', 'Pick_Confirm');
	       END IF;
	       fnd_message.set_name('INV', 'INV_COULD_NOT_UPATE_RECORD');
	       fnd_msg_pub.add;
	       rollback to TO_TRX_LINE_SAVE;
	       raise FND_API.G_EXC_ERROR;
	     elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
	       IF (l_debug = 1) THEN
      	       TraceLog('error in update mold', 'Pick_Confirm');
	       END IF;
	       fnd_message.set_name('INV', 'INV_COULD_NOT_UPATE_RECORD');
	       fnd_msg_pub.add;
	       rollback to TO_TRX_LINE_SAVE;
	       raise FND_API.G_EXC_UNEXPECTED_ERROR;
	    end if;
	    l_trolin_tbl(1).transaction_header_id :=
	      l_transaction_header_id;

-- obtain program and user info

                 l_trolin_tbl(1).last_update_date := SYSDATE;

                 l_trolin_tbl(1).last_update_login := fnd_global.login_id;

                 if l_trolin_tbl(1).last_update_login = -1 THEN
                        l_trolin_tbl(1).last_update_login :=
				fnd_global.conc_login_id;
                 end if;
                l_trolin_tbl(1).last_updated_by := fnd_global.user_id;
                l_trolin_tbl(1).program_id := fnd_global.conc_program_id;
                l_trolin_tbl(1).program_update_date := SYSDATE;
                l_trolin_tbl(1).request_id := fnd_global.conc_request_id;
                l_trolin_tbl(1).program_application_id :=
				fnd_global.prog_appl_id;
	    inv_trolin_util.update_row(l_trolin_tbl(1));
	    --end if;
	 end loop;
      end if;
   end if;

   --bug 8841933  added secondary_qty
   UPDATE mtl_material_transactions_temp mmtt
     SET mmtt.transaction_quantity = -1 * ABS(Round(mmtt.transaction_quantity,5)),
         mmtt.primary_quantity = -1 * ABS(Round(mmtt.primary_quantity,5)),
         mmtt.secondary_transaction_quantity = -1 * ABS(mmtt.secondary_transaction_quantity)
     WHERE mmtt.transaction_header_id = l_transaction_header_id
     AND mmtt.transaction_action_id in (1, 2, 3, 21, 28, 29, 32, 34);

   IF (l_debug = 1) THEN
      TraceLog('after update sign', 'Pick_Confirm');
   END IF;

   -- copy lots form mmtt to lots_temp table
   lot_success := 'FULL_LOT_PROCESSING' ;
   INVTTMTX.lot_handling(l_transaction_header_id, lot_success );
      IF (l_debug = 1) THEN
         TraceLog('after lot handling', 'Pick_Confirm');
      END IF;

   IF ( lot_success = '-1' ) THEN
         IF (l_debug = 1) THEN
            TraceLog('lot success= -1', 'Pick_Confirm');
         END IF;
      rollback to TO_TRX_LINE_SAVE;
      FND_Message.Set_Name('INV','INV_ORPHAN_CLEANUP_ERROR');
      FND_MSG_PUB.add;
      raise FND_API.G_EXC_ERROR;
    ELSIF ( lot_success = '-2' ) THEN
         IF (l_debug = 1) THEN
            TraceLog('lot success= -2', 'Pick_Confirm');
         END IF;
      rollback to TO_TRX_LINE_SAVE;
      FND_Message.Set_Name('INV', 'INV_LOTNULL_ERROR');
      FND_MSG_PUB.add;
      raise FND_API.G_EXC_ERROR;
    ELSIF ( lot_success = '-3' ) THEN
         IF (l_debug = 1) THEN
            TraceLog('lot success= -3', 'Pick_Confirm');
         END IF;
      rollback to TO_TRX_LINE_SAVE;
      FND_Message.Set_Name('INV', 'INV_LOTCOPY_ERROR');
      FND_MSG_PUB.add;
      raise FND_API.G_EXC_ERROR;
    ELSIF ( lot_success = '-4' ) THEN
         IF (l_debug = 1) THEN
            TraceLog('lot success= -4', 'Pick_Confirm');
         END IF;
      rollback to TO_TRX_LINE_SAVE;
      FND_Message.Set_Name('INV', 'INV_DYNAMIC_SERIAL_ERROR');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
   END IF;

   /* Bug 1620487 - Performance
   We no longer need to call do_check, since we lock the quantity
     Tree during pick release.  This was causing a huge performance hit.
     INV_Quantity_Tree_Pub.Do_Check
     (
     p_api_version_number => 1.0,
     p_init_msg_lst => FND_API.G_FALSE,
     x_return_status => l_return_status,
     x_msg_count	=> l_msg_count,
     x_msg_data	=> l_msg_data,
     x_no_violation	=> l_no_violation
     );

        IF (l_debug = 1) THEN
           TraceLog('after quantity_tree.do_check', 'Pick_Confirm');
        END IF;
     if( l_return_status = FND_API.G_RET_STS_ERROR ) then
     rollback to TO_TRX_LINE_SAVE;
     raise FND_API.G_EXC_ERROR;
     elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
     rollback to TO_TRX_LINE_SAVE;
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
     */
  IF (P_MOVE_ORDER_TYPE <> 5  OR P_MOVE_ORDER_TYPE is null) then
   -- Calling new Java transaction manager instread of pro C version
      IF (l_debug = 1) THEN
         TraceLog('Transaction Mode = '||l_proc_mode, 'Pick_Confirm', 1);
      END IF;
   l_success := INV_LPN_TRX_PUB.PROCESS_LPN_TRX( p_trx_hdr_id	=> l_transaction_header_id,
			    			 x_proc_msg	=> l_msg_data,
			    		         p_proc_mode    => l_proc_mode);
   if( l_success <> 0 ) THEN
      IF (l_debug = 1) THEN
         IF (l_debug = 1) THEN
            TraceLog('not success', 'Pick_Confirm', 1);
            TraceLog('error from inv_trx_mgr.process_trx_batch' || l_msg_data, 'Pick_Confirm', 1);
         END IF;
      END IF;
      rollback to TO_TRX_LINE_SAVE;
      /*if( l_rc_field = 1) then
      IF (l_debug = 1) THEN
         IF (l_debug = 1) THEN
            TraceLog('l_rc_field = ' || l_rc_field);
         END IF;
      END IF;
		FND_MESSAGE.SET_NAME('INV', 'INV_TM_TIME_OUT');
		FND_MSG_PUB.ADD;
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	        elsif l_rc_field = 2 then
		IF (l_debug = 1) THEN
   		IF (l_debug = 1) THEN
      		TraceLog('l_rc_field = ' || l_rc_field);
   		END IF;
		END IF;
		FND_MESSAGE.SET_NAME('INV', 'INV_TM_MGR_NOT_AVAIL');
		FND_MSG_PUB.ADD;
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		raise fnd_api.G_EXC_UNEXPECTED_ERROR;
	        elsif l_rc_field <> 0 then
		IF (l_debug = 1) THEN
   		IF (l_debug = 1) THEN
      		TraceLog('l_rc_field = ' || l_rc_field);
   		END IF;
		END IF;
		raise fnd_api.G_EXC_UNEXPECTED_ERROR;
        end if; */
      raise fnd_api.G_EXC_UNEXPECTED_ERROR;
	else
      IF (l_debug = 1) THEN
         IF (l_debug = 1) THEN
            TraceLog('Success from inv_trx_mgr.process_trx_batch', 'Pick_Confirm');
         END IF;
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   end if;
   ELSE
    l_program := 'INXTPU';
    l_func := l_program;
    l_args := l_program || ' ' || 'TRANS_HEADER_ID='|| to_char(l_transaction_header_id);
    p_timeout := 500;
    commit;  --Bug2621098

    l_old_tm_success := inv_tm_launch
    (
     program  => l_program,
     args     => l_args,
     timeout  => p_timeout,
     rtval => l_rc_field);
    if( not l_old_tm_success ) THEN
        TraceLog('not success', 'Pick_Confirm');
        TraceLog('error from inv_tm', 'Pick_Confirm');
        TraceLog('Error from INV_TM launch', 'Pick_Confirm');
        --rollback to TO_TRX_LINE_SAVE;
        /*if( l_rc_field = 1) then
           TraceLog('l_rc_field = ' || l_rc_field);
        FND_MESSAGE.SET_NAME('INV', 'INV_TM_TIME_OUT');
           FND_MSG_PUB.ADD;
           l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        elsif l_rc_field = 2 then
           TraceLog('l_rc_field = ' || l_rc_field);
           FND_MESSAGE.SET_NAME('INV', 'INV_TM_MGR_NOT_AVAIL');
           FND_MSG_PUB.ADD;
           l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           raise fnd_api.G_EXC_UNEXPECTED_ERROR;
        elsif l_rc_field <> 0 then
           TraceLog('l_rc_field = ' || l_rc_field);
           raise fnd_api.G_EXC_UNEXPECTED_ERROR;
        end if;*/
        raise fnd_api.G_EXC_UNEXPECTED_ERROR;
   else
        TraceLog('Success from Old INVTM', 'Pick_Confirm');
        x_return_status := FND_API.G_RET_STS_SUCCESS;
   end if;
  END IF; --Call Old tm for WIP Picking records

   --  Insert_Row.Clear_Orphan_Lots_Serials(l_transaction_header_id,-999);
   Begin
      DELETE FROM mtl_transaction_lots_temp
	WHERE group_header_id = l_transaction_header_id
	AND transaction_temp_id NOT IN
	( SELECT mmtt.transaction_temp_id
	  FROM mtl_material_transactions_temp mmtt
	  WHERE mmtt.transaction_header_id = l_transaction_header_id
	  AND mmtt.transaction_temp_id IS NOT NULL);

	  DELETE FROM mtl_serial_numbers_temp
	    WHERE group_header_id = l_transaction_header_id
	    AND transaction_temp_id NOT IN
	    ( SELECT mmtt.transaction_temp_id
	      FROM mtl_material_transactions_temp mmtt
	      WHERE mmtt.transaction_header_id = l_transaction_header_id
	      AND mmtt.transaction_temp_id IS NOT NULL)
		AND transaction_temp_id NOT IN
		( SELECT mtlt.serial_transaction_temp_id
		  FROM mtl_transaction_lots_temp mtlt
		  WHERE mtlt.group_header_id = l_transaction_header_id
		  AND mtlt.serial_transaction_temp_id IS NOT NULL);

		  -- Bug 5879916
                  /*
                  DELETE FROM mtl_serial_numbers
		   WHERE current_status = 6
		     AND group_mark_id = -1
                     AND inventory_item_id in (select inventory_item_id
                              FROM mtl_material_transactions_temp
                              WHERE transaction_header_id = l_transaction_header_id)
                     AND current_organization_id in (select organization_id
                              FROM mtl_material_transactions_temp
                              WHERE transaction_header_id = l_transaction_header_id);
                  */

                  DELETE /*+ INDEX(MSN MTL_SERIAL_NUMBERS_N2) */
                  FROM mtl_serial_numbers MSN
                  WHERE MSN.current_status = 6
                  AND MSN.group_mark_id = -1
                  AND (MSN.INVENTORY_ITEM_ID,MSN.CURRENT_ORGANIZATION_ID) IN
                            (SELECT INVENTORY_ITEM_ID,ORGANIZATION_ID
	                     FROM MTL_MATERIAL_TRANSACTIONS_TEMP
                             WHERE TRANSACTION_HEADER_ID = l_transaction_header_id);

                  -- End of change for Bug 5879916



--2101601


   EXCEPTION
      WHEN OTHERS then
	 --       TraceLog('error in cleanup orphan lot serial');
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 rollback to TO_TRX_LINE_SAVE;
	 FND_MESSAGE.SET_NAME('INV', 'INV_ORPHAN_CLEANUP_ERROR');
	 FND_MSG_PUB.ADD;
   END;
   if( p_commit = FND_API.G_TRUE ) then
      commit;
   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --  Get message count and data
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data =>
				 x_msg_data);
      ROLLBACK TO TO_TRX_LINE_SAVE; /* Bug 7014473 */
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data =>
				 x_msg_data);
      ROLLBACK TO TO_TRX_LINE_SAVE; /* Bug 7014473 */
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        TraceLog('Exception when others', 'Pick_Confirm');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
	ROLLBACK TO TO_TRX_LINE_SAVE; /* Bug 7014473 */

END Pick_Confirm;

FUNCTION INV_TM_Launch( program in varchar2,
			args in varchar2 default NULL,
			put1 in varchar2 default NULL,
			put2 in varchar2 default NULL,
			put3 in varchar2 default NULL,
			put4 in varchar2 default NULL,
			put5 in varchar2 default NULL,
			get1 in varchar2 default NULL,
			get2 in varchar2 default NULL,
			get3 in varchar2 default NULL,
			get4 in varchar2 default NULL,
			get5 in varchar2 default NULL,
			timeout in number default NULL,
			rtval out NOCOPY NUMBER) return BOOLEAN is

			   outcome VARCHAR(80);
			   msg VARCHAR(255);
			   rtvl NUMBER;
			   args1 VARCHAR(240);
     args2 VARCHAR(240);
     args3 VARCHAR(240);
     args4 VARCHAR(240);
     args5 VARCHAR(240);
     args6 VARCHAR(240);
     args7 VARCHAR(240);
     args8 VARCHAR(240);
     args9 VARCHAR(240);
     args10 VARCHAR(240);
     args11 VARCHAR(240);
     args12 VARCHAR(240);
     args13 VARCHAR(240);
     args14 VARCHAR(240);
     args15 VARCHAR(240);
     args16 VARCHAR(240);
     args17 VARCHAR(240);
     args18 VARCHAR(240);
     args19 VARCHAR(240);
     args20 VARCHAR(240);
     prod VARCHAR(240);
     func VARCHAR(240);
     m_message VARCHAR2(2000);
     p_userid  NUMBER;
     p_respid  NUMBER;
     p_applid  NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- load values for field gets;
   args12 := null;
   args13 := null;
   args14 := null;
   args15 := null;
   args14 := null;
   args15 := null;
   args16 := null;

   prod := 'INV';
   func := program;
   rtvl := fnd_transaction.synchronous
     (
      NVL(timeout,500),outcome, msg, prod,func, args,
      put1, put2, put3, put4, put5,
      get1, get2, get3, get4, get5,
      args12,  args13,  args14,  args15,  args16,
      chr(0), '', '', '');

      IF (l_debug = 1) THEN
         TraceLog('fnd_transaction.synchrous return: outcome is ' ||NVL(outcome,'NULL') || ' and rtvl is ' ||To_char(rtvl), 'Inv_TM_Launch');
   END IF;
   -- handle problems

   --rc_field := rtvl;
   IF rtvl = 1 THEN
      IF (l_debug = 1) THEN
         IF (l_debug = 1) THEN
            TraceLog('INV_TM_TIMEOUT', 'INV_TM_LAUNCH');
         END IF;
      END IF;
      fnd_message.set_name('INV', 'INV_TM_TIME_OUT');
      fnd_msg_pub.add;
      RETURN (FALSE);
    ELSIF  rtvl = 2 THEN
      IF (l_debug = 1) THEN
         IF (l_debug = 1) THEN
            TraceLog('INV_TM_MGR_NOT_AVAIL', 'INV_TM_LAUNCH');
         END IF;
      END IF;
      fnd_message.set_name('INV', 'INV_TM_MGR_NOT_AVAIL');
      fnd_msg_pub.add;
      RETURN (FALSE);
    ELSIF rtvl = 3 THEN
      IF (l_debug = 1) THEN
         IF (l_debug = 1) THEN
            TraceLog('CONC-DG-Inactive No Manager', 'INV_TM_LAUNCH');
         END IF;
      END IF;
      fnd_message.set_name('FND','CONC-DG-Inactive No Manager');
      fnd_msg_pub.add;
      RETURN(FALSE);
    ELSIF  rtvl = 0 THEN
      -- get info back from server and handle problems
      rtvl := fnd_transaction.get_values
        (args1, args2, args3, args4, args5,
         args6, args7, args8, args9, args10, args11,
         args12, args13, args14, args15,
         args16, args17, args18, args19, args20);
   END IF;

   IF (args1 IS NOT NULL) THEN
      --inv_debug.message(args1);
      FND_MSG_PUB.Add_Exc_Msg(
			      p_pkg_name => 'INV_Pick_Confirm_PUB',
			      p_procedure_name => 'INV_TM_LAUNCH',
			      p_error_text => args1);
   END IF;
   IF (args2 IS NOT NULL) THEN
      --inv_debug.message(args2);
      FND_MSG_PUB.Add_Exc_Msg(
			      p_pkg_name => 'INV_Pick_Confirm_PUB',
			      p_procedure_name => 'INV_TM_LAUNCH',
			      p_error_text => args2);
   END IF;
   IF (args3 IS NOT NULL) THEN
      FND_MSG_PUB.Add_Exc_Msg(
			      p_pkg_name => 'INV_Pick_Confirm_PUB',
			      p_procedure_name => 'INV_TM_LAUNCH',
			      p_error_text => args3);
      --inv_debug.message(args3);
   END IF;
   IF (args4 IS NOT NULL) THEN
      FND_MSG_PUB.Add_Exc_Msg(
			      p_pkg_name => 'INV_Pick_Confirm_PUB',
			      p_procedure_name => 'INV_TM_LAUNCH',
			      p_error_text => args4);
      --inv_debug.message(args4);
   END IF;
   IF (args5 IS NOT NULL) THEN
      FND_MSG_PUB.Add_Exc_Msg(
			      p_pkg_name => 'INV_Pick_Confirm_PUB',
			      p_procedure_name => 'INV_TM_LAUNCH',
			      p_error_text => args5);
      --inv_debug.message(args5);
   END IF;
   IF (args6 IS NOT NULL) THEN
      --inv_debug.message(args6);
      FND_MSG_PUB.Add_Exc_Msg(
			      p_pkg_name => 'INV_Pick_Confirm_PUB',
			      p_procedure_name => 'INV_TM_LAUNCH',
			      p_error_text => args6);
   END IF;
   IF (args7 IS NOT NULL) THEN
      FND_MSG_PUB.Add_Exc_Msg(
			      p_pkg_name => 'INV_Pick_Confirm_PUB',
			      p_procedure_name => 'INV_TM_LAUNCH',
			      p_error_text => args7);
      --inv_debug.message(args7);
   END IF;
   IF (args8 IS NOT NULL) THEN
      FND_MSG_PUB.Add_Exc_Msg(
			      p_pkg_name => 'INV_Pick_Confirm_PUB',
			      p_procedure_name => 'INV_TM_LAUNCH',
			      p_error_text => args8);
      --inV_debug.message(args8);
   END IF;
   IF (args9 IS NOT NULL) THEN
      FND_MSG_PUB.Add_Exc_Msg(
			      p_pkg_name => 'INV_Pick_Confirm_PUB',
			      p_procedure_name => 'INV_TM_LAUNCH',
			      p_error_text => args9);
      --inv_debug.message(args9);
   END IF;
   IF (args10 IS NOT NULL) THEN
      FND_MSG_PUB.Add_Exc_Msg(
			      p_pkg_name => 'INV_Pick_Confirm_PUB',
			      p_procedure_name => 'INV_TM_LAUNCH',
			      p_error_text => args10);
      --inv_debug.message(args10);
   END IF;

   -- Kick back status
   IF (outcome = 'SUCCESS' and rtvl = 0 ) THEN
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
   END IF;
EXCEPTION
   When others then
      IF (l_debug = 1) THEN
         IF (l_debug = 1) THEN
            TraceLog('exception ...', 'INV_TM_LAUNCH');
         END IF;
      END IF;
      FND_MSG_PUB.Add_Exc_Msg(
			      p_pkg_name => 'INV_Pick_Confirm_PUB',
			      p_procedure_name => 'INV_TM_LAUNCH');
      return (false);
END INV_TM_LAUNCH;



END INV_Pick_Wave_Pick_Confirm_PUB;

/
