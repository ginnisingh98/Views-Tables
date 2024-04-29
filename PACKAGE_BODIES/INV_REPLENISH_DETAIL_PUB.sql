--------------------------------------------------------
--  DDL for Package Body INV_REPLENISH_DETAIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_REPLENISH_DETAIL_PUB" AS
  /* $Header: INVTOTXB.pls 120.11.12010000.6 2010/03/26 10:41:08 kjujjuru ship $ */

  --  Global constant holding the package name

  g_pkg_name  CONSTANT VARCHAR2(30) := 'INV_Replenish_Detail_PUB';
  is_debug             BOOLEAN      := TRUE;
  g_retain_ato_profile VARCHAR2(1)  := fnd_profile.VALUE('WSH_RETAIN_ATO_RESERVATIONS');

  --  Start of Comments
  --  API name    Line_Details_PUB
  --  Type        Public
  --  Function
  --
  --  Pre-reqs
  --
  --  Parameters
  --
  --  Version     Current version = 1.0
  --              Initial version = 1.0
  --
  --  Notes       Obtain parameters from the form
  --              Put the parameters in a record
  --              Call the autodetail API and pass it the record
  --              Receives the quantity detailed, number of rows detailed,
  --                detailed and serial record types
  --              Insert information into MMTT and Serial Numbers Temp
  --              Return the number of detailed rows and quantities, lot
  --                info
  --
  --  End of Comments

  PROCEDURE print_debug(p_message IN VARCHAR2) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      inv_pick_wave_pick_confirm_pub.tracelog(p_message, 'INV_REPLENISH_DETAIL');
    END IF;
  END;


  PROCEDURE line_details_pub(
    p_line_id               IN            NUMBER
  , x_number_of_rows        OUT NOCOPY    NUMBER
  , x_detailed_qty          OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_revision              OUT NOCOPY    VARCHAR2
  , x_locator_id            OUT NOCOPY    NUMBER
  , x_transfer_to_location  OUT NOCOPY    NUMBER
  , x_lot_number            OUT NOCOPY    VARCHAR2
  , x_expiration_date       OUT NOCOPY    DATE
  , x_transaction_temp_id   OUT NOCOPY    NUMBER
  , p_transaction_header_id IN            NUMBER
  , p_transaction_mode      IN            NUMBER
  , p_move_order_type       IN            NUMBER
  , p_serial_flag           IN            VARCHAR2
  , p_plan_tasks            IN            BOOLEAN
  , p_auto_pick_confirm     IN            BOOLEAN
  , p_commit                IN            BOOLEAN DEFAULT FALSE
  ) IS


  x_detailed_qty2 NUMBER;

  BEGIN

-- HW INVCONV - Call the overloaded procedure

  line_details_pub(
    p_line_id               => p_line_id
  , x_number_of_rows        => x_number_of_rows
  , x_detailed_qty          => x_detailed_qty
  , x_detailed_qty2         => x_detailed_qty2
  , x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , x_revision              => x_revision
  , x_locator_id            => x_locator_id
  , x_transfer_to_location  => x_transfer_to_location
  , x_lot_number            => x_lot_number
  , x_expiration_date       => x_expiration_date
  , x_transaction_temp_id   => x_transaction_temp_id
  , p_transaction_header_id => p_transaction_header_id
  , p_transaction_mode      => p_transaction_mode
  , p_move_order_type       => p_move_order_type
  , p_serial_flag           => p_serial_flag
  , p_plan_tasks            => p_plan_tasks
  , p_auto_pick_confirm     => p_auto_pick_confirm
  , p_commit                => p_commit
  ) ;

 END  line_details_pub;




-- HW INVCONV - Overloaded procedure to send back Qty2

  PROCEDURE line_details_pub(
    p_line_id               IN            NUMBER
  , x_number_of_rows        OUT NOCOPY    NUMBER
  , x_detailed_qty          OUT NOCOPY    NUMBER
  , x_detailed_qty2         OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_revision              OUT NOCOPY    VARCHAR2
  , x_locator_id            OUT NOCOPY    NUMBER
  , x_transfer_to_location  OUT NOCOPY    NUMBER
  , x_lot_number            OUT NOCOPY    VARCHAR2
  , x_expiration_date       OUT NOCOPY    DATE
  , x_transaction_temp_id   OUT NOCOPY    NUMBER
  , p_transaction_header_id IN            NUMBER
  , p_transaction_mode      IN            NUMBER
  , p_move_order_type       IN            NUMBER
  , p_serial_flag           IN            VARCHAR2
  , p_plan_tasks            IN            BOOLEAN
  , p_auto_pick_confirm     IN            BOOLEAN
  , p_commit                IN            BOOLEAN DEFAULT FALSE
  ) IS
    l_api_version_number CONSTANT NUMBER                                           := 1.0;
    l_init_msg_list               VARCHAR2(255)                                    := fnd_api.g_true;
    l_api_name           CONSTANT VARCHAR2(30)                                     := 'Line_Details_PUB';
    l_num_of_rows                 NUMBER                                           := 0;
    l_detailed_qty                NUMBER                                           := 0;
-- HW INVCONV
    l_detailed_qty2               NUMBER                                           := 0;
    l_ser_index                   NUMBER;
    l_expiration_date             DATE;
    x_success                     NUMBER;
    l_revision                    VARCHAR2(3);
    l_transfer_to_location        NUMBER;
    l_lot_number                  VARCHAR2(80);
    l_locator_id                  NUMBER;
    l_transaction_temp_id         NUMBER;
    l_transaction_header_id       NUMBER;
    l_subinventory_code           VARCHAR2(30);
    l_transaction_quantity        NUMBER;
    l_primary_quantity            NUMBER;
-- HW INVCONV Added Qty2
    l_transaction_quantity2       NUMBER;
    l_inventory_item_id           NUMBER;
    l_temp_id                     NUMBER;
    l_serial_number               VARCHAR2(30);
    l_mtl_reservation             inv_reservation_global.mtl_reservation_tbl_type;
    l_trolin_tbl                  inv_move_order_pub.trolin_tbl_type;
    l_auto_pick_confirm           NUMBER;
    l_pick_release_status         inv_pick_release_pub.inv_release_status_tbl_type;
    l_return_status               VARCHAR2(1);
    l_grouping_rule_id            NUMBER;
    l_mold_tbl                    inv_mo_line_detail_util.g_mmtt_tbl_type;
    l_mold_tbl_temp               inv_mo_line_detail_util.g_mmtt_tbl_type;
    l_message                     VARCHAR2(2000);
    l_count                       NUMBER;
    l_from_serial_number          VARCHAR2(30);
    l_to_serial_number            VARCHAR2(30);
    l_detail_rec_count            NUMBER;
    l_success                     NUMBER;
    l_auto_pick_flag              VARCHAR2(1);
    l_request_number              VARCHAR2(80);
    l_commit                      VARCHAR2(1);
    l_cnt_lot                     NUMBER;

-- HW INVCONV - Added secondary_transaction
    CURSOR suggestions_csr IS
      SELECT transaction_header_id
           , transaction_temp_id
           , inventory_item_id
           , revision
           , subinventory_code
           , locator_id
           , transaction_quantity
           , primary_quantity
           , secondary_transaction_quantity
           , lot_number
           , lot_expiration_date
           , serial_number
           , transfer_to_location
        FROM mtl_material_transactions_temp
       WHERE move_order_line_id = p_line_id;

    CURSOR serial_number_csr IS
      SELECT fm_serial_number, to_serial_number
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = l_transaction_temp_id;

    CURSOR c_mtrh IS
      SELECT request_number, grouping_rule_id
        FROM mtl_txn_request_headers
       WHERE header_id = l_trolin_tbl(1).header_id;

 --Bug 6696594
 Cursor c_mmtt(p_move_order_line_id NUMBER)
    IS SELECT transaction_temp_id
    FROM mtl_material_transactions_temp
    WHERE move_order_line_id = p_move_order_line_id;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    --Bug 6696594
    l_mmtt            number;
    l_transaction_id	INV_LABEL.transaction_id_rec_type;
    l_label_status VARCHAR2(500);
    v_transaction_id INV_LABEL.transaction_id_rec_type;
    l_honor_case_pick_count NUMBER := 0;
    l_counter     NUMBER := 1;

BEGIN
	l_trolin_tbl(1)  := inv_trolin_util.query_row(p_line_id);
	OPEN c_mtrh;
	FETCH c_mtrh INTO l_request_number, l_grouping_rule_id;
	CLOSE c_mtrh;

	IF p_move_order_type = inv_globals.g_move_order_pick_wave THEN
		IF l_debug = 1 THEN
			print_debug('Pickwave MO. Calling INV_PICK_RELEASE_PUB.PICK_RELEASE to allocate');
		END IF;

		IF p_auto_pick_confirm IS NOT NULL AND p_auto_pick_confirm = FALSE THEN
			l_auto_pick_flag := 'N';
		ELSE
			BEGIN
				-- The parameter is for whether pick confirm is required or not,
				-- so the auto-pick confirm flag is the opposite of this.
				SELECT DECODE(NVL(mo_pick_confirm_required, 2), 1, 2, 2, 1, 1)
				INTO l_auto_pick_confirm
				FROM mtl_parameters
				WHERE organization_id = l_trolin_tbl(1).organization_id;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				fnd_message.set_name('INV', 'INV_AUTO_PICK_CONFIRM_PARAM');
				fnd_msg_pub.ADD;
				RAISE fnd_api.g_exc_unexpected_error;
			END;

			BEGIN
				SELECT auto_pick_confirm_flag INTO l_auto_pick_flag
				FROM wsh_picking_batches
				WHERE NAME = l_request_number;

				IF (l_auto_pick_flag IS NULL) THEN
					IF (l_auto_pick_confirm = 1) THEN
						l_auto_pick_flag  := 'Y';
					ELSE
						l_auto_pick_flag  := 'N';
					END IF;
				END IF;

			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				fnd_message.set_name('INV', 'INV_AUTO_PICK_CONFIRM_PARAM');
				fnd_msg_pub.ADD;
				RAISE fnd_api.g_exc_unexpected_error;
			END;
		END IF;

		SAVEPOINT inv_before_pick_release;

		IF (l_debug = 1) THEN
			print_debug('Org Level - Pick Confirm Required = ' || TO_CHAR(l_auto_pick_confirm));
			print_debug('Picking Batch - Auto Pick Confirm = ' || l_auto_pick_flag);
		END IF;

		IF (l_auto_pick_flag = 'Y') THEN
			l_commit  := fnd_api.g_true;
		ELSE
			l_commit  := fnd_api.g_false;
		END IF;

		inv_pick_release_pub.pick_release(
		p_api_version                => 1.0
		, p_init_msg_list              => fnd_api.g_false
		, p_commit                     => l_commit
		, x_return_status              => l_return_status
		, x_msg_data                   => x_msg_data
		, x_msg_count                  => x_msg_count
		, p_mo_line_tbl                => l_trolin_tbl
		, p_auto_pick_confirm          => l_auto_pick_confirm
		, p_grouping_rule_id           => l_grouping_rule_id
		, x_pick_release_status        => l_pick_release_status
		-- Bug 5948675 passing the plan_tasks parameter to pick release API
		, p_plan_tasks                 => p_plan_tasks
		);

		IF (l_debug = 1) THEN
			print_debug('l_return_status from inv_pick_release_pub.pick_release is ' || l_return_status);
		END IF;

		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			IF (l_debug = 1) THEN
				print_debug('return error');
			END IF;
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;

		IF (l_debug = 1) THEN
			print_debug(l_pick_release_status.COUNT);
		END IF;

		IF (l_pick_release_status.COUNT > 0) THEN
			l_detail_rec_count  := l_pick_release_status(1).detail_rec_count;
			IF (l_debug = 1) THEN
				print_debug('detail record count is ' || l_detail_rec_count);
			END IF;

			FOR l_index IN 1 .. l_pick_release_status.COUNT LOOP
				IF (l_pick_release_status(l_index).return_status = fnd_api.g_ret_sts_unexp_error) THEN
					l_return_status  := fnd_api.g_ret_sts_unexp_error;
				ELSIF l_pick_release_status(l_index).return_status = fnd_api.g_ret_sts_error THEN
					l_return_status  := fnd_api.g_ret_sts_error;
				ELSE
					IF (l_debug = 1) THEN
						print_debug('return status is ' || l_return_status);
					END IF;
					l_return_status  := fnd_api.g_ret_sts_success;
				END IF;
			END LOOP;
		END IF;

		IF (l_debug = 1) THEN
			print_debug('after raise error');
			print_debug('Number of details' || l_detail_rec_count);
		END IF;

		--No rows allocated
		IF (l_detail_rec_count <= 0 AND l_auto_pick_flag = 'Y') THEN
			fnd_message.set_name('INV', 'INV_DETAILING_FAILED');
			fnd_message.set_token('LINE_NUM', l_trolin_tbl(1).line_number);
			fnd_message.set_token('MO_NUMBER', l_request_number);
			fnd_msg_pub.ADD;
			RAISE fnd_api.g_exc_error;
		END IF;

		/*Bug 1588529*/
		IF (l_detail_rec_count <= 0 AND l_auto_pick_flag = 'N') THEN
			UPDATE mtl_txn_request_lines
			SET line_status = 5
			WHERE line_id = l_trolin_tbl(1).line_id
			AND NOT EXISTS (SELECT 1 FROM mtl_material_transactions_temp /*6120769Added NOT EXISTS condition*/
			WHERE move_order_line_id = l_trolin_tbl(1).line_id
			AND rownum<2 );

                        IF (p_commit) THEN -- Bug8566005: Made the commit conditional
                           COMMIT;
                        END IF;
		END IF;

		IF (l_detail_rec_count > 0 AND l_auto_pick_flag = 'Y') THEN
			COMMIT;
			IF (l_debug = 1) THEN
				print_debug('auto pick confirm');
			END IF;
			l_mold_tbl       := inv_mo_line_detail_util.query_rows(p_line_id => l_trolin_tbl(1).line_id);
			l_mold_tbl_temp  := l_mold_tbl;

			IF (l_mold_tbl.COUNT = 0) THEN
				l_return_status  := fnd_api.g_ret_sts_unexp_error;
				fnd_message.set_name('INV', 'INV_PICK_RELEASE_ERROR');
				fnd_msg_pub.ADD;
				RAISE fnd_api.g_exc_unexpected_error;
			ELSE
				IF (l_debug = 1) THEN
					print_debug('number of mold record is ' || l_mold_tbl.COUNT);
					print_debug('calling pick confirm');
				END IF;

				inv_pick_wave_pick_confirm_pub.pick_confirm(
				p_api_version_number         => 1.0
				, p_init_msg_list              => fnd_api.g_false
				, p_commit                     => fnd_api.g_true
				, x_return_status              => l_return_status
				, x_msg_count                  => x_msg_count
				, x_msg_data                   => x_msg_data
				, p_move_order_type            => p_move_order_type
				, p_transaction_mode           => 1
				, p_trolin_tbl                 => l_trolin_tbl
				, p_mold_tbl                   => l_mold_tbl
				, x_mmtt_tbl                   => l_mold_tbl
				, x_trolin_tbl                 => l_trolin_tbl
				);

				IF (l_debug = 1) THEN
					print_debug('after pick confirm with return status = ' || l_return_status);
					print_debug('l_return_status = ' || l_return_status);
				END IF;

				IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
					l_success  := 0;
					IF (l_debug = 1) THEN
						print_debug('rollback changes');
						print_debug('l_mold_tbl_temp.count = ' || l_mold_tbl_temp.COUNT);
					END IF;

					FOR l_index IN 1 .. l_mold_tbl_temp.COUNT LOOP
						IF (l_debug = 1) THEN
							print_debug('calling delete details');
						END IF;

						-- HW INVCONV - Pass secondary_qty
						inv_replenish_detail_pub.delete_details(
						p_transaction_temp_id        => l_mold_tbl_temp(l_index).transaction_temp_id
						, p_move_order_line_id         => l_mold_tbl_temp(l_index).move_order_line_id
						, p_reservation_id             => l_mold_tbl_temp(l_index).reservation_id
						, p_transaction_quantity       => l_mold_tbl_temp(l_index).transaction_quantity
						, p_transaction_quantity2      => l_mold_tbl_temp(l_index).secondary_transaction_quantity
						, p_primary_trx_qty            => l_mold_tbl_temp(l_index).primary_quantity
						, x_return_status              => l_return_status
						, x_msg_data                   => x_msg_data
						, x_msg_count                  => x_msg_count
						);
						IF (l_debug = 1) THEN
							print_debug('after detele details with return status ' || l_return_status);
						END IF;

						IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
							RAISE fnd_api.g_exc_unexpected_error;
						ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
							RAISE fnd_api.g_exc_error;
						END IF;

						-- HW INVCONV - Update Qty2 fields
						UPDATE mtl_txn_request_lines
						SET quantity_detailed = quantity_detailed - l_mold_tbl_temp(l_index).transaction_quantity
						, quantity_delivered = quantity_delivered - l_mold_tbl_temp(l_index).transaction_quantity
						, secondary_quantity_detailed = decode(secondary_quantity_detailed,FND_API.G_MISS_NUM, NULL, secondary_quantity_detailed - l_mold_tbl_temp(l_index).secondary_transaction_quantity)
						, secondary_quantity_delivered =decode(secondary_quantity_delivered,FND_API.G_MISS_NUM, NULL, secondary_quantity_delivered - l_mold_tbl_temp(l_index).secondary_transaction_quantity)
						WHERE line_id = l_mold_tbl_temp(l_index).move_order_line_id;
					END LOOP;

					UPDATE mtl_txn_request_lines
					SET line_status = 7
					WHERE line_id = p_line_id;

					COMMIT;
				ELSE
					l_success  := 1;
				END IF;

				x_return_status  := l_return_status;

				IF (l_debug = 1) THEN
					print_debug('return status is ' || l_return_status);
				END IF;
			END IF;
			x_return_status  := l_return_status;
		END IF;
	ELSIF p_move_order_type = inv_globals.g_move_order_mfg_pick THEN
		IF l_debug = 1 THEN
			print_debug('Mfg MO. Calling INV_WIP_PICKING_PVT.PICK_RELEASE to allocate');
		END IF;

		-- HW INVCONV - Need to investigate what inv_wip_picking_pvt.pick_release does
		-- since qty2s are being passed from l_trolin_tbl
		inv_wip_picking_pvt.pick_release(
		x_return_status       => x_return_status
		, x_msg_count           => x_msg_count
		, x_msg_data            => x_msg_data
		, p_commit              => fnd_api.g_false
		, p_init_msg_lst        => fnd_api.g_false
		, p_mo_line_tbl         => l_trolin_tbl
		, p_allow_partial_pick  => fnd_api.g_true
		, p_grouping_rule_id    => l_grouping_rule_id
		, p_plan_tasks          => p_plan_tasks
		, p_call_wip_api        => FALSE
		);

		IF x_return_status = fnd_api.g_ret_sts_error THEN
			RAISE fnd_api.g_exc_error;
		ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
	ELSE
		IF l_debug = 1 THEN
			print_debug('Other types of MO. Calling INV_PPENGINE_PVT.CREATE_SUGGESTIONS to allocate');
		END IF;

		inv_ppengine_pvt.create_suggestions(
		p_api_version                => l_api_version_number
		, p_init_msg_list              => l_init_msg_list
		, p_commit                     => fnd_api.g_false
		, p_validation_level           => fnd_api.g_valid_level_full
		, x_return_status              => l_return_status
		, x_msg_count                  => x_msg_count
		, x_msg_data                   => x_msg_data
		, p_transaction_temp_id        => p_line_id
		, p_reservations               => l_mtl_reservation
		, p_suggest_serial             => p_serial_flag
		, p_plan_tasks                 => p_plan_tasks
		);

		IF l_return_status = fnd_api.g_ret_sts_error THEN
			RAISE fnd_api.g_exc_error;
		ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;

		--Start Bug 6696594
		IF INV_CONTROL.G_CURRENT_RELEASE_LEVEL >= 120001 THEN
			--Call label printing API

         FOR v_mmtt in c_mmtt (p_line_id)
		   LOOP
			   IF (l_debug = 1) THEN
				   print_debug('v_mmtt.transaction_temp_id ' || v_mmtt.transaction_temp_id);
   			END IF;

	   		l_transaction_id(l_counter) := v_mmtt.transaction_temp_id;
		   	l_counter := l_counter + 1;
		   END LOOP;

			BEGIN
				l_counter := 1;
				FOR b in l_transaction_id.first..l_transaction_id.last
				LOOP
					/*SELECT wutta. honor_case_pick_flag into honor_case_pick
					FROM mtl_material_transactions_temp mmtt, wms_user_task_type_attributes wutta
					WHERE mmtt.standard_operation_id = wutta.user_task_type_id
					AND mmtt.organization_id = wutta.organization_id
					AND mmtt.transaction_temp_id = l_transaction_id(b);*/

					SELECT count (*) into l_honor_case_pick_count
					FROM mtl_material_transactions_temp mmtt, wms_user_task_type_attributes wutta
					WHERE mmtt.standard_operation_id = wutta.user_task_type_id
					AND mmtt.organization_id = wutta.organization_id
					AND mmtt.transaction_temp_id = l_transaction_id(b)
					AND honor_case_pick_flag = 'Y';


					IF (l_debug = 1) THEN
						print_debug('l_counter' || l_counter);
					END IF;

					IF l_honor_case_pick_count > 0 THEN
						v_transaction_id(l_counter) := l_transaction_id(b);
						l_counter := l_counter + 1;
					END IF;
				END LOOP;

				IF l_counter > 1 THEN
					l_return_status := fnd_api.g_ret_sts_success;

					inv_label.print_label (
						x_return_status      => x_return_status
						, x_msg_count          => x_msg_count
						, x_msg_data           => x_msg_data
						, x_label_status       => l_label_status
						, p_api_version        => 1.0
						, p_print_mode         => 1
						, p_business_flow_code => 42  --Business Flow Pick Release
						, p_transaction_id     => v_transaction_id);

					IF ( l_return_status <> fnd_api.g_ret_sts_success ) THEN
						IF (l_debug = 1) THEN
							print_debug('failed to print labels');
						END IF;
						fnd_message.set_name('WMS', 'WMS_PRINT_LABEL_FAIL');
						fnd_msg_pub.ADD;
					END IF;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				IF (l_debug = 1) THEN
					print_debug('Exception occured while calling print_label');
				END IF;
				fnd_message.set_name('WMS', 'WMS_PRINT_LABEL_FAIL');
				fnd_msg_pub.ADD;
			END;
		END IF;
		--End  Bug 6696594

		IF (inv_install.adv_inv_installed(l_trolin_tbl(1).organization_id) = TRUE) THEN
			IF (l_debug = 1) THEN
				inv_pick_wave_pick_confirm_pub.tracelog('about to call wms_rule_pvt.assignTTs', 'INVTOTXB');
				inv_pick_wave_pick_confirm_pub.tracelog('header_id is ' || l_trolin_tbl(1).header_id, 'INVTOTXB');
			END IF;

			wms_cartnzn_pub.cartonize(
			p_api_version           => 1.0
			, p_init_msg_list         => fnd_api.g_false
			, p_commit                => fnd_api.g_false
			, p_validation_level      => fnd_api.g_valid_level_full
			, x_return_status         => l_return_status
			, x_msg_count             => x_msg_count
			, x_msg_data              => x_msg_data
			, p_out_bound             => 'Y'
			, p_org_id                => l_trolin_tbl(1).organization_id
			, p_move_order_header_id  => l_trolin_tbl(1).header_id
			, p_disable_cartonization => 'Y'
			);

			IF l_return_status = fnd_api.g_ret_sts_error THEN
				IF (l_debug = 1) THEN
					print_debug('Error from  WMS_CARTNZN_PUB.CARTONIZE');
				END IF;

				RAISE fnd_api.g_exc_error;
			ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
				IF (l_debug = 1) THEN
					print_debug('error from  WMS_CARTNZN_PUB.CARTONIZE');
				END IF;

				RAISE fnd_api.g_exc_unexpected_error;
			END IF;
		END IF;
	END IF;

	IF (p_move_order_type <> 3 OR (p_move_order_type = 3 AND l_auto_pick_flag = 'N')) THEN
		l_num_of_rows           := 0;
		--  insert the records INV_AUTODETAIL.detail_row returns
		--    into the mtl_material_transactions_temp table
		--
		-- Added Bug 3633141
		-- Considering the Delivered Quantity for the move order line.
		--
		/*    IF (p_move_order_type <> 3) THEN
			-- HW INVCONV -Added Qty2
			SELECT quantity_delivered, secondary_quantity_delivered
			INTO l_detailed_qty, l_detailed_qty2
			FROM mtl_txn_request_lines
			WHERE line_id = p_line_id;

			IF l_detailed_qty IS NULL THEN
				l_detailed_qty  := 0;
				-- HW INVCONV -Added Qty2
				l_detailed_qty2 := 0;
			END IF;
		END IF; */ --commented against bug : 4155230
		--Bug fix 3633141 ends
		OPEN suggestions_csr;
		LOOP
			-- HW INVCONV - Added secondary_transaction_quantity
			FETCH suggestions_csr INTO l_transaction_header_id
			, l_transaction_temp_id
			, l_inventory_item_id
			, l_revision
			, l_subinventory_code
			, l_locator_id
			, l_transaction_quantity
			, l_primary_quantity
			, l_transaction_quantity2
			, l_lot_number
			, l_expiration_date
			, l_serial_number
			, l_transfer_to_location;
			EXIT WHEN suggestions_csr%NOTFOUND;
			assign_expenditure_org(l_transaction_temp_id);
			OPEN serial_number_csr;

			LOOP
				FETCH serial_number_csr INTO l_from_serial_number, l_to_serial_number;
				EXIT WHEN serial_number_csr%NOTFOUND;
			END LOOP;

			CLOSE serial_number_csr;
			l_num_of_rows   := l_num_of_rows + 1;

			IF (l_debug = 1) THEN
				print_debug('number of rows = from mmtt ' || l_num_of_rows);
			END IF;

			l_detailed_qty  := l_detailed_qty + ABS(l_transaction_quantity);
			-- HW INVCONV - Added Qty2
			l_detailed_qty2  := l_detailed_qty2 + ABS(l_transaction_quantity2);

			IF l_transaction_quantity < 0 THEN
				-- HW INVCONV - Added qty2
				UPDATE mtl_material_transactions_temp
				SET transaction_quantity = ABS(transaction_quantity)
				, primary_quantity = ABS(primary_quantity)
				, secondary_transaction_quantity = ABS(secondary_transaction_quantity)
				WHERE transaction_temp_id = l_transaction_temp_id;
			END IF;
		END LOOP; -- Detail loop

		CLOSE suggestions_csr;
		/*Bug#5140639. Added the below code to update distribution_account_id and
		ship_to_location columns of the table MMTT*/
		IF ( l_trolin_tbl(1).to_account_id IS NOT NULL) THEN
			IF (l_debug = 1) THEN
				print_debug('Updating distribution_account_id and ship_to_location_id in MMTT');
			END IF;

			Update MTL_MATERIAL_TRANSACTIONS_TEMP
			SET distribution_account_id = l_trolin_tbl(1).to_account_id,
			ship_to_location = Nvl(l_trolin_tbl(1).ship_to_location_id, ship_to_location)
			WHERE move_order_line_id = l_trolin_tbl(1).line_id;

			IF (l_debug = 1) THEN
				print_debug('Number of rows updated:'||SQL%ROWCOUNT);
			END IF;
		END IF;


IF (l_debug = 1) THEN
print_debug('after the loop');
END IF;

-- set output variables
IF p_move_order_type <> 3 THEN
BEGIN
SELECT COUNT(*) INTO l_cnt_lot
FROM mtl_transaction_lots_temp
WHERE transaction_temp_id = l_transaction_temp_id;

IF l_cnt_lot = 1 THEN
SELECT lot_number
INTO l_lot_number
FROM mtl_transaction_lots_temp
WHERE transaction_temp_id = l_transaction_temp_id;
END IF;
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
END IF;

x_number_of_rows        := l_num_of_rows;

IF (l_debug = 1) THEN
print_debug('number of rows = ' || l_num_of_rows);
END IF;

x_detailed_qty          := l_detailed_qty;
-- HW INVCONV - Added qty2
x_detailed_qty2          := l_detailed_qty2;
-- rev, fm/to locator can be set as follows because
--   we will use them when there is only one queried record
x_revision              := l_revision;
x_locator_id            := l_locator_id;
x_transfer_to_location  := l_transfer_to_location;
x_lot_number            := l_lot_number;
x_expiration_date       := l_expiration_date;
x_transaction_temp_id   := l_transaction_temp_id;
x_return_status         := fnd_api.g_ret_sts_success;

IF  ( p_commit ) THEN
COMMIT;
END IF;

ELSIF(p_move_order_type = 3 AND l_auto_pick_confirm = 1) THEN
IF (l_success = 1) THEN
x_return_status  := fnd_api.g_ret_sts_success;
ELSE
RAISE fnd_api.g_exc_error;
END IF;
END IF;
EXCEPTION
WHEN fnd_api.g_exc_error THEN
x_return_status  := fnd_api.g_ret_sts_error;
fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
WHEN fnd_api.g_exc_unexpected_error THEN
x_return_status  := fnd_api.g_ret_sts_unexp_error;
fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
WHEN OTHERS THEN
x_return_status  := fnd_api.g_ret_sts_unexp_error;

IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
fnd_msg_pub.add_exc_msg(g_pkg_name, 'Line_Details_PUB');
END IF;

fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END line_details_pub;

  PROCEDURE assign_expenditure_org(p_transaction_temp_id NUMBER) IS
    l_transaction_type_id   NUMBER;
    l_transaction_action_id NUMBER;
    l_install_status        VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_project_related       VARCHAR2(1);
    l_expenditure_type      VARCHAR2(30);
    l_project_id            NUMBER;
    l_task_id               NUMBER;
    l_organization_id       NUMBER;
    l_debug                 NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    SELECT transaction_type_id
         , transaction_action_id
      INTO l_transaction_type_id
         , l_transaction_action_id
      FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = p_transaction_temp_id;



      SELECT DECODE(type_class, 1, 'Y', 'N')
        INTO l_project_related
        FROM mtl_transaction_types
       WHERE transaction_type_id = l_transaction_type_id;

      IF l_project_related = 'Y' THEN
        --copy the project and task info to source_project and source_task info in the MMTT table;
        -- or the corresponding block or pl/sql table that eventually populates into MMTT.

        fnd_profile.get('CSE_PA_EXP_TYPE', l_expenditure_type);

        SELECT organization_id
          INTO l_organization_id
          FROM mtl_material_transactions_temp
         WHERE transaction_temp_id = p_transaction_temp_id;

        IF (l_transaction_action_id = 1) THEN
          --fnd_message.debug('copying project_id and task_id from tolines_blk to mtl_Trx_line');

          SELECT project_id
               , task_id
            INTO l_project_id
               , l_task_id
            FROM mtl_txn_request_lines
           WHERE line_id = (SELECT move_order_line_id
                              FROM mtl_material_transactions_temp
                             WHERE transaction_temp_id = p_transaction_temp_id);
        END IF;

        UPDATE mtl_material_transactions_temp
           SET source_project_id = l_project_id
             , source_task_id = l_task_id
             , pa_expenditure_org_id = l_organization_id
             , expenditure_type = l_expenditure_type
         WHERE transaction_temp_id = p_transaction_temp_id;
      END IF;
  END;

  --------------------------------------------------------------------------
  --  Start of Comments
  --  API name    Delete_Details
  --  Type        Public
  --  Function
  --
  --  Pre-reqs
  --
  --  Parameters
  --
  --  Version     Current version = 1.0
  --              Initial version = 1.0
  --
  --  Notes       Delete from MMTT those with process_flag = N
  --              Delete from Serial Numbers Temp the records related to the deleted
  --                records in MMTT
  --              Return number of MMTT records being deleted
  --
  --  End of Comments

-- HW INVCONV - Pass Qty2
  PROCEDURE delete_details(
     p_transaction_temp_id   IN            NUMBER
  , p_move_order_line_id    IN            NUMBER
  , p_reservation_id        IN            NUMBER
  , p_transaction_quantity  IN            NUMBER
  , p_transaction_quantity2 IN            NUMBER default FND_API.G_MISS_NUM
  , p_primary_trx_qty       IN            NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , p_delete_temp_records   IN            BOOLEAN default TRUE /*Bug#5505709.*/
  ) IS
    l_reservation_id            NUMBER                                          := p_reservation_id;
    l_mtl_reservation_tbl       inv_reservation_global.mtl_reservation_tbl_type;
    l_mtl_reservation_rec       inv_reservation_global.mtl_reservation_rec_type;
    l_mtl_reservation_tbl_count NUMBER                                          := 0;
    l_return_status             VARCHAR2(1);
    l_original_serial_number    inv_reservation_global.serial_number_tbl_type;
    l_to_serial_number          inv_reservation_global.serial_number_tbl_type;
    l_error_code                NUMBER;
    l_count                     NUMBER;
    l_success                   BOOLEAN;
    l_umconvert_trans_quantity  NUMBER                                          := 0;
    l_mmtt_rec                  inv_mo_line_detail_util.g_mmtt_rec;
    l_primary_uom               VARCHAR2(10);
    l_ato_item                  NUMBER                                          := 0;
    l_debug                     NUMBER                                          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    --null;
       --inv_debug.message('l_reservation_id = ' || p_reservation_id);
       --inv_debug.message('l_transaction_temp_id = ' || p_transaction_temp_id);
       --inv_debug.message('l_line_id = ' || p_move_order_line_id);
       --inv_debug.message('l_transaction_quantity = ' || p_transaction_quantity);
    IF l_reservation_id IS NOT NULL THEN
      l_mtl_reservation_rec.reservation_id  := l_reservation_id;
      inv_reservation_pub.query_reservation(
        p_api_version_number         => 1.0
      , x_return_status              => l_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_query_input                => l_mtl_reservation_rec
      , x_mtl_reservation_tbl        => l_mtl_reservation_tbl
      , x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count
      , x_error_code                 => l_error_code
      );

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; --rsv id not null

    IF l_mtl_reservation_tbl_count > 0 THEN
       -- Bug 2621481 If reservations exist check if the item is an
      -- ato item if the profile WSH_RETAIN_ATO_RESERVATIONS = 'Y'

      IF g_retain_ato_profile = 'Y' THEN
       BEGIN
        SELECT 1
             , primary_uom_code
          INTO l_ato_item
             , l_primary_uom
          FROM mtl_system_items
         WHERE replenish_to_order_flag = 'Y'
           AND bom_item_type = 4
           AND inventory_item_id = l_mtl_reservation_tbl(1).inventory_item_id
           AND organization_id = l_mtl_reservation_tbl(1).organization_id;
       EXCEPTION
       WHEN OTHERS THEN
           l_ato_item := 0;
       END;
      END IF;

      IF l_ato_item = 1 THEN
        -- If item is ato item, reduce the detailed quantity by the transaction
        -- quantity and retain the reservation.Convert to primary uom before
        -- reducing detailed quantity.
        l_mmtt_rec                                  := inv_mo_line_detail_util.query_row(p_transaction_temp_id);
        l_umconvert_trans_quantity                  := p_transaction_quantity;

        IF l_mmtt_rec.inventory_item_id IS NOT NULL
           AND l_mmtt_rec.transaction_uom IS NOT NULL THEN
          l_umconvert_trans_quantity  :=
            inv_convert.inv_um_convert(
              item_id                      => l_mmtt_rec.inventory_item_id
            , PRECISION                    => NULL
            , from_quantity                => p_transaction_quantity
            , from_unit                    => l_mmtt_rec.transaction_uom
            , to_unit                      => l_primary_uom
            , from_name                    => NULL
            , to_name                      => NULL
            );
        END IF;

        l_mtl_reservation_rec                       := l_mtl_reservation_tbl(1);
        l_mtl_reservation_tbl(1).detailed_quantity  := NVL(l_mtl_reservation_tbl(1).detailed_quantity, 0) - ABS(l_umconvert_trans_quantity);
        inv_reservation_pub.update_reservation(
          p_api_version_number         => 1.0
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_original_rsv_rec           => l_mtl_reservation_rec
        , p_to_rsv_rec                 => l_mtl_reservation_tbl(1)
        , p_original_serial_number     => l_original_serial_number
        , p_to_serial_number           => l_to_serial_number
        );

        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
        ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSE
        l_mtl_reservation_rec                                  := l_mtl_reservation_tbl(1);
        l_mtl_reservation_tbl(1).detailed_quantity             :=
                                                               NVL(l_mtl_reservation_tbl(1).detailed_quantity, 0)
                                                             - ABS(p_transaction_quantity);
        l_mtl_reservation_tbl(1).reservation_quantity          :=
                                                             NVL(l_mtl_reservation_tbl(1).reservation_quantity, 0)
                                                           - ABS(p_transaction_quantity);
        l_mtl_reservation_tbl(1).primary_reservation_quantity  :=
                                                          NVL(l_mtl_reservation_tbl(1).primary_reservation_quantity, 0)
                                                        - ABS(p_primary_trx_qty);

-- HW INVCONV - Update Qty2s if they are present

        IF ( p_transaction_quantity2 <> FND_API.G_MISS_NUM) THEN
-- No need to use NVL similar to Qty1
          l_mtl_reservation_tbl(1).secondary_detailed_quantity             :=
                                                               l_mtl_reservation_tbl(1).secondary_detailed_quantity
                                                             - ABS(p_transaction_quantity2);
          l_mtl_reservation_tbl(1).secondary_reservation_quantity          :=
                                                             l_mtl_reservation_tbl(1).secondary_reservation_quantity
                                                           - ABS(p_transaction_quantity2);
        END IF;

        inv_reservation_pub.update_reservation(
          p_api_version_number         => 1.0
        , x_return_status              => l_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_original_rsv_rec           => l_mtl_reservation_rec
        , p_to_rsv_rec                 => l_mtl_reservation_tbl(1)
        , p_original_serial_number     => l_original_serial_number
        , p_to_serial_number           => l_to_serial_number
        );

        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
        ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF; -- ato item check
    END IF; --reservation count >0

    /*inv_reservation_pub.query_reservation(
        p_api_version_number => 1.0,
        x_return_status      => l_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_query_input        => l_mtl_reservation_rec,
        x_mtl_reservation_tbl => l_mtl_reservation_tbl,
        x_mtl_reservation_tbl_count => l_mtl_reservation_tbl_count,
        x_error_code        => l_error_code);

    ---inv_debug.message('reservation_quantity = ' || l_mtl_reservation_tbl(1).reservation_quantity);
    --inv_debug.message('detailed_quantity = ' || l_mtl_reservation_tbl(1).detailed_quantity);
    --inv_debug.message('primary_reservation_quantity = ' || l_mtl_reservation_Tbl(1).primary_reservation_quantity);
    */
    /*Bug#5505709. Put the code that deletes rows from MMTT/MSNT/MTLT inside the IF condition. This is
      because, if this procedure is called from the 'Transact Move Order Line Allocations' form when the user
      presses the DELETE button, deletion of these rows is already handled.*/
    IF (p_delete_temp_records) THEN
      CLEAR_RECORD(p_transaction_temp_id, l_success);

      IF (NOT l_success) THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      inv_mo_line_detail_util.delete_row(  x_return_status => l_return_status
                                         , p_line_id => p_move_order_line_id
                                         , p_line_detail_id => p_transaction_temp_id);

    /* select count(1) into l_count
    from mtl_material_transactions_temp
    where move_order_line_id = p_move_order_line_id;

    --inv_debug.message('count = ' || l_count);
    */
      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; --p_delete_temp_records

    COMMIT;
    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Line_Details_PUB');
      END IF;
  END delete_details;

  ---------------------------------------------------
  PROCEDURE clear_block_cancel(p_trx_header_id IN NUMBER, p_success IN OUT NOCOPY BOOLEAN) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    p_success  := TRUE;

    -- Delete predefined serial numbers
    DELETE      mtl_serial_numbers
          WHERE group_mark_id = p_trx_header_id
            AND current_status = 6;

    -- Unmark serial numbers
    UPDATE mtl_serial_numbers
       SET group_mark_id = NULL
         , line_mark_id = NULL
         , lot_line_mark_id = NULL
     WHERE group_mark_id = p_trx_header_id;

    -- Delete lot and serial records from temp tables
    DELETE      mtl_serial_numbers_temp
          WHERE group_header_id = p_trx_header_id;

    DELETE      mtl_transaction_lots_temp
          WHERE group_header_id = p_trx_header_id;

    DELETE      mtl_material_transactions_temp
          WHERE transaction_header_id = p_trx_header_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      p_success  := FALSE;
  END clear_block_cancel;

  ---------------------------------------------------
  PROCEDURE CLEAR_RECORD(p_trx_tmp_id NUMBER, p_success IN OUT NOCOPY BOOLEAN) IS
    l_serial_temp_id        NUMBER;
    l_lot_count             NUMBER;
    l_serial_count          NUMBER;
    l_header_id             NUMBER       := -1;
    unmarked_value          NUMBER       := -1;

    CURSOR lot_temp_csr(trx_temp_id NUMBER) IS
      SELECT serial_transaction_temp_id
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = trx_temp_id;

    CURSOR serial_temp_csr(trx_temp_id NUMBER) IS
      SELECT fm_serial_number
           , to_serial_number
           , group_header_id
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = trx_temp_id;

    l_fm_serial_number      VARCHAR2(30);
    l_to_serial_number      VARCHAR2(30);
    l_transaction_header_id NUMBER;
    l_debug                 NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  BEGIN
    --inv_debug.message('ssia', 'in clear record');
    p_success  := TRUE;

    SELECT COUNT(*)
      INTO l_lot_count
      FROM mtl_transaction_lots_temp
     WHERE transaction_temp_id = p_trx_tmp_id;

    --inv_debug.message('ssia', 'after lot_count = ' || l_lot_count);
    --inv_debug.message('ssia', 'p_trx_tmp_id is ' || p_trx_tmp_id);

    print_debug('txn temp id: ' || p_trx_tmp_id);
    print_debug('lot count: ' || l_lot_count);

    SELECT transaction_header_id
      INTO l_transaction_header_id
      FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = p_trx_tmp_id;

    --inv_debug.message('ssia', 'l_transaction_header_id is '||l_transaction_header_id);
    IF (l_lot_count > 0) THEN
      OPEN lot_temp_csr(p_trx_tmp_id);

      LOOP
        FETCH lot_temp_csr INTO l_serial_temp_id;
        EXIT WHEN lot_temp_csr%NOTFOUND;

        SELECT COUNT(*)
          INTO l_serial_count
          FROM mtl_serial_numbers_temp
         WHERE transaction_temp_id = l_serial_temp_id;

        IF (l_serial_count > 0) THEN
          OPEN serial_temp_csr(l_serial_temp_id);

          LOOP
            FETCH serial_temp_csr INTO l_fm_serial_number, l_to_serial_number, l_header_id;
            EXIT WHEN serial_temp_csr%NOTFOUND;

            /* Bug #2798218
             * While allocating serials, the group_mark_id column in mtl_serial_numbers is always
             * populated with the value of MMTT.transaction_temp_id (for a serial controlled item)
             * or MTLT.serial_transaction_temp_id (for a lot and serial controlled item), whether
             * the serials are allocated by the system or the manually by the user in the serial entry block
             * While unmarking the serials, always use transaction_temp_id or serial_transaction_temp_id
             * and do not use mmtt.transaction_header_id in the WHERE clause of the UPDATE statement
             */
            UPDATE mtl_serial_numbers
               SET line_mark_id = unmarked_value
                 , group_mark_id = unmarked_value
                 , lot_line_mark_id = unmarked_value
             WHERE (group_mark_id = l_serial_temp_id OR  group_mark_id = l_header_id) --Bug#6009436.
               AND serial_number >= NVL(l_fm_serial_number, serial_number)
               AND serial_number <= NVL(l_to_serial_number, NVL(l_fm_serial_number, serial_number))
               AND LENGTH(serial_number) = LENGTH(NVL(l_fm_serial_number, serial_number));
          END LOOP;
        END IF;

        DELETE      mtl_serial_numbers_temp
              WHERE transaction_temp_id = l_serial_temp_id;
      END LOOP;

      CLOSE lot_temp_csr;

      DELETE      mtl_transaction_lots_temp
            WHERE transaction_temp_id = p_trx_tmp_id;
    ELSE
      --inv_debug.message('ssia', 'lot_count = ' || l_lot_count);
      SELECT COUNT(*)
        INTO l_serial_count
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = p_trx_tmp_id;

      print_debug('serial count: ' || l_serial_count);

      --inv_debug.message('ssia', 'serial_count = ' || l_serial_count);

      IF (l_serial_count > 0) THEN
        OPEN serial_temp_csr(p_trx_tmp_id);

        --inv_debug.message('ssia', 'inside serial');
        LOOP
          --inv_debug.message('ssia', 'inside loop');
          FETCH serial_temp_csr INTO l_fm_serial_number, l_to_serial_number, l_header_id;
          EXIT WHEN serial_temp_csr%NOTFOUND;

          --inv_debug.message('ssia', 'l_header_id is ' || l_header_id);
          --inv_debug.message('ssia', 'update mtl_serial_number');
          UPDATE mtl_serial_numbers
             SET line_mark_id = unmarked_value
               , group_mark_id = unmarked_value
               , lot_line_mark_id = unmarked_value
           WHERE ( group_mark_id = p_trx_tmp_id OR group_mark_id = l_header_id ) --Bug#6009436
             AND serial_number >= NVL(l_fm_serial_number, serial_number)
             AND serial_number <= NVL(l_to_serial_number, NVL(l_fm_serial_number, serial_number))
             AND LENGTH(serial_number) = LENGTH(NVL(l_fm_serial_number, serial_number));
        END LOOP;

        CLOSE serial_temp_csr;
      END IF;

      DELETE      mtl_serial_numbers_temp
            WHERE transaction_temp_id = p_trx_tmp_id;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      p_success  := FALSE;
  END CLEAR_RECORD;

  PROCEDURE split_line_details(
    p_transaction_temp_id  IN            NUMBER
  , p_missing_quantity     IN            NUMBER
  , p_detailed_quantity    IN            NUMBER
  , p_transaction_quantity IN            NUMBER
  , x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  ) IS
    l_transaction_temp_id NUMBER                             := p_transaction_temp_id;
    l_mmtt_rec            inv_mo_line_detail_util.g_mmtt_rec;
    l_next_id             NUMBER;
    l_return_status       VARCHAR2(1);
    l_count               NUMBER;
    l_primary_quantity    NUMBER;
    l_primary_uom         VARCHAR2(10);
    l_debug               NUMBER                             := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    SELECT mtl_material_transactions_s.NEXTVAL
      INTO l_next_id
      FROM DUAL;

    l_mmtt_rec                        := inv_mo_line_detail_util.query_row(l_transaction_temp_id);
    --inv_debug.message('l_next_id ' || l_next_id);
    l_mmtt_rec.transaction_temp_id    := l_next_id;
    l_mmtt_rec.transaction_quantity   := p_detailed_quantity - p_transaction_quantity - p_missing_quantity;

    IF l_mmtt_rec.inventory_item_id IS NOT NULL
       AND l_mmtt_rec.transaction_uom IS NOT NULL THEN
      SELECT primary_uom_code
        INTO l_primary_uom
        FROM mtl_system_items
       WHERE organization_id = l_mmtt_rec.organization_id
         AND inventory_item_id = l_mmtt_rec.inventory_item_id;

      l_primary_quantity           :=
        inv_convert.inv_um_convert(
          item_id                      => l_mmtt_rec.inventory_item_id
        , PRECISION                    => NULL
        , from_quantity                => l_mmtt_rec.transaction_quantity
        , from_unit                    => l_mmtt_rec.transaction_uom
        , to_unit                      => l_primary_uom
        , from_name                    => NULL
        , to_name                      => NULL
        );
      l_mmtt_rec.primary_quantity  := l_primary_quantity;
    END IF;

    l_mmtt_rec.transaction_status     := 2;
    l_mmtt_rec.transaction_header_id  := NULL;
    inv_mo_line_detail_util.insert_row(x_return_status => l_return_status, p_mo_line_detail_rec => l_mmtt_rec);

    --inv_debug.message('after insert row '|| l_return_status );
    SELECT COUNT(*)
      INTO l_count
      FROM mtl_material_transactions_temp
     WHERE move_order_line_id = l_mmtt_rec.move_order_line_id;

    --inv_debug.message(' total record = ' || l_count ||' for move order line id ' || l_mmtt_rec.move_order_line_id);
    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_message.set_name('INV', 'SPLIT_LINE_DETAIL_ERROR');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('INV', 'SPLIT_LINE_DETAIL_ERROR');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Split_Line_Details');
      END IF;
  END;

  PROCEDURE auto_pick_confirm(
    p_line_id         IN            NUMBER
  , p_move_order_type IN            NUMBER
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
  ) IS
    l_line_id            NUMBER                                  := p_line_id;
    l_return_status      VARCHAR2(1);
    l_grouping_rule_id   NUMBER;
    l_mold_tbl           inv_mo_line_detail_util.g_mmtt_tbl_type;
    l_message            VARCHAR2(2000);
    l_count              NUMBER;
    l_from_serial_number VARCHAR2(30);
    l_to_serial_number   VARCHAR2(30);
    l_trolin_tbl         inv_move_order_pub.trolin_tbl_type;
    l_debug              NUMBER                                  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    --inv_debug.message('auto pick confirm');
    --inv_debug.message('get trolin');
    l_trolin_tbl     := inv_trolin_util.query_rows(p_line_id => l_line_id);
    --inv_debug.message('get mold');
    l_mold_tbl       := inv_mo_line_detail_util.query_rows(p_line_id => l_line_id);
    --inv_debug.message('number of mold record is ' || l_mold_tbl.count);
    inv_pick_wave_pick_confirm_pub.pick_confirm(
      p_api_version_number         => 1.0
    , p_init_msg_list              => fnd_api.g_false
    , p_commit                     => fnd_api.g_true
    , x_return_status              => l_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_move_order_type            => p_move_order_type
    , p_transaction_mode           => 1
    , p_trolin_tbl                 => l_trolin_tbl
    , p_mold_tbl                   => l_mold_tbl
    , x_mmtt_tbl                   => l_mold_tbl
    , x_trolin_tbl                 => l_trolin_tbl
    );

    --inv_debug.message('l_return_status = ' || l_return_status);
    IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --null;
    x_return_status  := l_return_status;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_message.set_name('INV', 'AUTO_PICK_CONFIRM_ERROR');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('INV', 'AUTO_PICK_CONFIRM_ERROR');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'AUTO_PICK_CONFIRM');
      END IF;
  END;

  PROCEDURE reserve_unconfirm_qty(
    p_reservation_id   IN            NUMBER
  , p_missing_quantity IN            NUMBER
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  ) IS
    l_reservation_id   NUMBER      := p_reservation_id;
    l_return_status    VARCHAR2(1);
    l_missing_quantity NUMBER      := p_missing_quantity;
    l_debug            NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- call the reserve unconfirmed quantity
    inv_pick_release_pub.reserve_unconfirmed_quantity(
      p_api_version                => 1.0
    , x_return_status              => l_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_missing_quantity           => l_missing_quantity
    , p_reservation_id             => l_reservation_id
    );

    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    x_return_status  := l_return_status;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'AUTO_PICK_CONFIRM');
      END IF;
  END;

  PROCEDURE changed_from_subinventory(
    p_reservation_id      IN            NUMBER
  , p_transaction_temp_id IN            NUMBER
  , p_old_subinventory    IN            VARCHAR2
  , p_new_subinventory    IN            VARCHAR2
  , p_new_locator_id      IN            NUMBER
  , x_to_reservation_id   OUT NOCOPY    NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  ) IS
    l_mtl_reservation_tbl       inv_reservation_global.mtl_reservation_tbl_type;
    l_mtl_reservation_rec       inv_reservation_global.mtl_reservation_rec_type;
    l_mtl_reservation_tbl_count NUMBER;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_error_code                NUMBER;
    l_mmtt_rec                  inv_mo_line_detail_util.g_mmtt_rec;
    l_mmtt_count                NUMBER;
    l_reservation_id            NUMBER                                          := p_reservation_id;
    l_original_serial_number    inv_reservation_global.serial_number_tbl_type;
    l_to_serial_number          inv_reservation_global.serial_number_tbl_type;
    l_reservable_type           NUMBER;

    CURSOR lot_csr(l_transaction_temp_id NUMBER) IS
      SELECT lot_number
           , primary_quantity
           , transaction_quantity
           , serial_transaction_temp_id
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = l_transaction_temp_id;

    CURSOR serial_csr(l_transaction_id NUMBER, l_lot_control_code NUMBER, l_serial_trx_id NUMBER) IS
      SELECT serial_number
        FROM mtl_unit_transactions
       WHERE transaction_id = DECODE(l_lot_control_code, 1, l_transaction_id, l_serial_trx_id);

    l_lot_count                 NUMBER;
    l_lot_control_code          NUMBER;
    l_serial_control_code       NUMBER;
    l_serial_trx_id             NUMBER;
    l_transaction_temp_id       NUMBER                                          := p_transaction_temp_id;
    l_lot_number                VARCHAR2(80);
    l_lot_primary_quantity      NUMBER;
    l_lot_transaction_quantity  NUMBER;
    l_debug                     NUMBER                                          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    --inv_Debug.message('ssia', 'Inside changed_from_subinventory');
    l_mmtt_rec  := inv_mo_line_detail_util.query_row(p_transaction_temp_id);

    --inv_Debug.message('ssia', 'transaction_temp_id is ' || p_transaction_temp_id);

    SELECT reservable_type
      INTO l_reservable_type
      FROM mtl_secondary_inventories
     WHERE organization_id = l_mmtt_rec.organization_id
       AND secondary_inventory_name = p_new_subinventory;

    --inv_Debug.message('ssia', 'l_reservable_type is  ' || l_reservable_Type);
    IF (p_reservation_id IS NOT NULL
        OR p_reservation_id > 0) THEN
      l_mtl_reservation_rec.reservation_id  := l_mmtt_rec.reservation_id;
      inv_reservation_pub.query_reservation(
        p_api_version_number         => 1.0
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_query_input                => l_mtl_reservation_rec
      , x_mtl_reservation_tbl        => l_mtl_reservation_tbl
      , x_mtl_reservation_tbl_count  => l_mtl_reservation_tbl_count
      , x_error_code                 => l_error_code
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_mtl_reservation_rec                 := l_mtl_reservation_tbl(1);

      IF (l_debug = 1) THEN
        print_debug('lot number in the original reservation is ' || l_mtl_reservation_rec.lot_number);
      END IF;

      IF (l_mtl_reservation_rec.subinventory_code IS NOT NULL) THEN
        IF (l_reservable_type = 2) THEN
          IF (l_debug = 1) THEN
            print_debug('not reservable staging subinventory, delete org wide reservation');
          END IF;

          l_mtl_reservation_rec                               := l_mtl_reservation_tbl(1);
          l_mtl_reservation_rec.reservation_quantity          :=
                                                       NVL(l_mtl_reservation_rec.reservation_quantity, 0)
                                                     - ABS(l_mmtt_rec.transaction_quantity);
          l_mtl_reservation_rec.primary_reservation_quantity  :=
                                                   NVL(l_mtl_reservation_rec.primary_reservation_quantity, 0)
                                                 - ABS(l_mmtt_rec.primary_quantity);

          IF (l_debug = 1) THEN
            print_debug('reservation quantity is ' || l_mtl_reservation_rec.reservation_quantity);
          END IF;

          inv_reservation_pub.update_reservation(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
          , p_to_rsv_rec                 => l_mtl_reservation_rec
          , p_original_serial_number     => l_original_serial_number
          , p_to_serial_number           => l_to_serial_number
          , p_validation_flag            => fnd_api.g_true
          );

          IF (l_debug = 1) THEN
            print_debug('after update reservation return status is ' || l_return_status);
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            print_debug('reservable staging subinventory, transfer reservation to staging');
          END IF;

          SELECT COUNT(transaction_temp_id)
            INTO l_lot_count
            FROM mtl_transaction_lots_temp
           WHERE transaction_temp_id = l_mmtt_rec.transaction_temp_id;

          IF (l_lot_count > 0) THEN
            l_transaction_temp_id  := l_mmtt_rec.transaction_temp_id;
            OPEN lot_csr(l_transaction_temp_id);

            LOOP
              FETCH lot_csr INTO l_lot_number, l_lot_primary_quantity, l_lot_transaction_quantity, l_serial_trx_id;
              EXIT WHEN lot_csr%NOTFOUND;

              IF (l_debug = 1) THEN
                print_debug('lot number is ' || l_mtl_reservation_rec.lot_number);
              END IF;

              l_mtl_reservation_rec.reservation_id                := NULL;
              l_mtl_reservation_rec.requirement_date              := SYSDATE;
              l_mtl_reservation_rec.primary_reservation_quantity  := l_lot_primary_quantity;
              l_mtl_reservation_rec.reservation_quantity          := l_lot_transaction_quantity;
              l_mtl_reservation_rec.subinventory_code             := p_new_subinventory;
              l_mtl_reservation_rec.locator_id                    := p_new_locator_id;
              l_mtl_reservation_rec.ship_ready_flag               := 1;
              l_mtl_reservation_rec.lot_number                    := l_lot_number;
              l_mtl_reservation_rec.revision                      := l_mmtt_rec.revision;
              inv_reservation_pub.transfer_reservation(
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => l_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
              , p_to_rsv_rec                 => l_mtl_reservation_rec
              , p_original_serial_number     => l_to_serial_number
              , p_to_serial_number           => l_to_serial_number
              , x_to_reservation_id          => x_to_reservation_id
              );

              IF (l_debug = 1) THEN
                print_debug('new reservation id is ' || l_reservation_id);
                print_debug('after create new  reservation');
                print_debug('l_return_status is ' || l_return_status);
              END IF;

              /*for l_count in 1..x_msg_count loop
              l_message := fnd_msg_pub.get(l_count,'T');
              l_message := replace(l_message,chr(0),' ');
              IF (l_debug = 1) THEN
                 print_debug(l_message);
              END IF;
               end loop; */
              IF l_return_status = fnd_api.g_ret_sts_error THEN
                IF (l_debug = 1) THEN
                  print_debug('return from transfer_reservation with error E');
                END IF;

                RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (l_debug = 1) THEN
                  print_debug('return from transfer_reservation with error U');
                END IF;

                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            END LOOP;

            IF (l_debug = 1) THEN
              print_debug('after end loop');
            END IF;

            CLOSE lot_csr;
          ELSE
            IF (l_debug = 1) THEN
              print_debug('no lot records');
            END IF;

            l_mtl_reservation_rec.reservation_id                := NULL;
            l_mtl_reservation_rec.requirement_date              := SYSDATE;
            l_mtl_reservation_rec.primary_reservation_quantity  := ABS(l_mmtt_rec.primary_quantity);
            l_mtl_reservation_rec.reservation_quantity          := ABS(l_mmtt_rec.transaction_quantity);
            l_mtl_reservation_rec.subinventory_code             := p_new_subinventory;
            l_mtl_reservation_rec.locator_id                    := p_new_locator_id;
            l_mtl_reservation_rec.ship_ready_flag               := 1;
            l_mtl_reservation_rec.revision                      := l_mmtt_rec.revision;
            --print_debug('lot number is ' || l_mtl_reservation_rec.lot_number);
            inv_reservation_pub.transfer_reservation(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_original_rsv_rec           => l_mtl_reservation_tbl(1)
            , p_to_rsv_rec                 => l_mtl_reservation_rec
            , p_original_serial_number     => l_to_serial_number
            , p_to_serial_number           => l_to_serial_number
            , x_to_reservation_id          => x_to_reservation_id
            );

            IF (l_debug = 1) THEN
              print_debug('new reservation id is ' || l_reservation_id);
              print_debug('after create new  reservation');
              print_debug('l_return_status is ' || l_return_status);
            END IF;

            /*for l_count in 1..x_msg_count loop
                 l_message := fnd_msg_pub.get(l_count,'T');
                 l_message := replace(l_message,chr(0),' ');
                 IF (l_debug = 1) THEN
                    print_debug(l_message);
                 END IF;
            end loop; */
            IF l_return_status = fnd_api.g_ret_sts_error THEN
              IF (l_debug = 1) THEN
                print_debug('return from transfer_reservation with error E');
              END IF;

              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              IF (l_debug = 1) THEN
                print_debug('return from transfer_reservation with error U');
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (l_debug = 1) THEN
              print_debug('still inside if no lot records');
            END IF;
          END IF; -- lot or not lot control
        END IF; -- reservable or not
      END IF; -- if reservation exists
    END IF;
  END;

  --Check_Shipping_Tolerances
  --
  -- This API checks to make sure that transacting the current allocation
  -- does not exceed shipping tolerances.
  -- This procedure should only be called for Pick Wave move orders
  -- p_line_id : the move order line id.
  -- p_quantity: the quantity to be transacted
  -- x_allowed: 'Y' if txn is allowed, 'N' otherwise
  -- x_max_quantity: the maximum quantity that can be pick confirmed
  --     without exceeding shipping tolerances

  PROCEDURE check_shipping_tolerances(
    x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , x_allowed       OUT NOCOPY    VARCHAR2
  , x_max_quantity  OUT NOCOPY    NUMBER
  , p_line_id       IN            NUMBER
  , p_quantity      IN            NUMBER
  ) IS
    l_allowed             VARCHAR2(1);
    l_max_quantity2       NUMBER;
    l_avail_req_qty2      NUMBER;
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_api_name   CONSTANT VARCHAR2(30)      := 'Check_Shipping_Tolerances';
    l_txn_source_line_id  NUMBER;
    l_max_quantity        NUMBER;
    l_avail_req_qty       NUMBER;
    l_mo_quantity         NUMBER;
    l_quantity_delivered  NUMBER;
    l_organization_id     NUMBER;
    l_inventory_item_id   NUMBER;
    l_allocation_quantity NUMBER;
    l_line_set_id         NUMBER;

    TYPE number_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    l_quantity_table      number_table_type;

    CURSOR c_txn_source IS
      SELECT txn_source_line_id, inventory_item_id
        FROM mtl_txn_request_lines
       WHERE line_id = p_line_id;

    CURSOR c_source_line IS
      SELECT source_line_id, inventory_item_id
        FROM wsh_delivery_details
       WHERE move_order_line_id = p_line_id;

    CURSOR c_mtrl_line_set IS
      SELECT quantity
        FROM mtl_txn_request_lines
       WHERE inventory_item_id = l_inventory_item_id
         AND line_status <> 5
         AND txn_source_line_id IN(SELECT line_id
                                     FROM oe_order_lines_all
                                    WHERE line_set_id = l_line_set_id)
         FOR UPDATE OF quantity NOWAIT;

    CURSOR c_mtrl_line IS
      SELECT quantity
        FROM mtl_txn_request_lines
       WHERE inventory_item_id = l_inventory_item_id
         AND organization_id = l_organization_id	--bug 7012974 performance issue in TMO
         AND line_status <> 5
         AND txn_source_line_id = l_txn_source_line_id
         FOR UPDATE OF quantity NOWAIT;

    record_locked         EXCEPTION;
    PRAGMA EXCEPTION_INIT(record_locked, -54);
    l_debug               NUMBER            := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_return_status  := fnd_api.g_ret_sts_success;

    BEGIN
      SELECT organization_id
        INTO l_organization_id
        FROM mtl_txn_request_lines
       WHERE line_id = p_line_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    -- If overpicking is not turned on then the maximum quanitity that is
    -- allowed is the move order quantity
    IF (NVL(fnd_profile.VALUE('WSH_OVERPICK_ENABLED'), 'N') <> 'Y') THEN
        IF (l_debug = 1) THEN
          print_debug('OVPK | Overpicking is not turned on');
        END IF;

      SELECT NVL(required_quantity, quantity), NVL(quantity_delivered, 0)
        INTO l_mo_quantity, l_quantity_delivered
        FROM mtl_txn_request_lines
       WHERE line_id = p_line_id;

      l_max_quantity   := l_mo_quantity - l_quantity_delivered;

      IF (l_debug = 1) THEN
        print_debug('OVPK | p_quantity:' || p_quantity || ' max_quantity:' || l_max_quantity);
      END IF;

      IF p_quantity > l_max_quantity THEN
        l_allowed  := 'N';
      ELSE
        l_allowed  := 'Y';
      END IF;

      x_max_quantity   := l_max_quantity;
      x_allowed        := l_allowed;
      x_return_status  := l_return_status;

      IF (l_debug = 1) THEN
        print_debug('OVPK | x_max_quantity:' || x_max_quantity || ' x_allowed:' || x_allowed || ' x_return_status: ' || l_return_status);
      END IF;

      RETURN;
    END IF;

    -- If overpicking is allowed...
    -- By default, allow the transaction.
    l_allowed        := 'Y';
    l_max_quantity   := 1e125;
    -- get sales order line id from the move order line
    OPEN c_txn_source;
    FETCH c_txn_source INTO l_txn_source_line_id, l_inventory_item_id;

    IF c_txn_source%NOTFOUND THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    CLOSE c_txn_source;

    -- If for some reason the txn_source_line_id on the move order line is
    -- not yet populated, get the order line directly from the delivery
    -- details
    IF l_txn_source_line_id IS NULL THEN
      OPEN c_source_line;
      FETCH c_source_line INTO l_txn_source_line_id, l_inventory_item_id;

      IF c_txn_source%NOTFOUND THEN
        l_txn_source_line_id  := NULL;
      END IF;
    END IF;

    IF l_txn_source_line_id IS NOT NULL THEN

--Bug# 3348005

        BEGIN
          FOR mtrl_line IN c_mtrl_line LOOP
            NULL;
          END LOOP;
        EXCEPTION
          WHEN record_locked THEN
            fnd_message.set_name('INV', 'INV_MO_LOCKED_SO');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
        END;

        SELECT NVL(SUM(ABS(transaction_quantity)), 0)
          INTO l_allocation_quantity
          FROM mtl_material_transactions_temp
         WHERE move_order_line_id <> p_line_id
           AND inventory_item_id = l_inventory_item_id
           AND transaction_action_id = 28
           AND trx_source_line_id = l_txn_source_line_id;

      l_allocation_quantity  := l_allocation_quantity + p_quantity;
      wsh_details_validations.check_quantity_to_pick(
        p_order_line_id              => l_txn_source_line_id
      , p_quantity_to_pick           => l_allocation_quantity
      , x_allowed_flag               => l_allowed
      , x_max_quantity_allowed       => l_max_quantity
      , x_return_status              => l_return_status
      , x_avail_req_quantity         => l_avail_req_qty
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    x_max_quantity   := l_max_quantity;
    x_allowed        := l_allowed;
    x_return_status  := l_return_status;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_allowed        := 'N';
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_allowed        := 'N';
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      x_allowed        := 'N';

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
  END check_shipping_tolerances;

  -- OVPK
  -- Get_Overpick_Qty
  --
  -- This API will take 2 input parameters
  -- 1. p_transaction_temp_id
  -- 2. p_overpicked_qty
  -- This API will return
  -- 1. x_ovpk_allowed
  -- 2. x_max_qty_allowed
  -- x_ovpk_allowed will be 0 if overpicking is not allowed
  -- x_ovpk_allowed will be 1 if overpicking is allowed
  -- x_max_qty_allowed will return the max qty that can be picked for that task

  -- For Manufacturing Component Pick - Move Order type 5,
  --     Replenishment                - Move Order type 2,
  --     Requisition                  - Move Order type 1
  -- where there is no tolerance set on the quantity that can be picked,
  -- this procedure will return x_max_qty_allowed as -1

  PROCEDURE get_overpick_qty(
    p_transaction_temp_id IN            NUMBER
  , p_overpicked_qty      IN            NUMBER
  , x_ovpk_allowed        OUT NOCOPY    NUMBER
  , x_max_qty_allowed     OUT NOCOPY    NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  ) IS
    l_org_id               NUMBER;
    l_move_order_type      NUMBER;
    l_transaction_temp_id  NUMBER         := p_transaction_temp_id;
    l_trx_source_line_id   NUMBER;
    l_all_alloc            NUMBER;
    l_other_alloc          NUMBER;
    l_this_alloc           NUMBER;
    l_temp                 VARCHAR2(1);
    l_new_qty              NUMBER;
    --Check_Shipping_Tolerances
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_mo_line_id           NUMBER;
    --l_ordered_quantity  NUMBER := -1;

    --Shipping
    l_allowed_flag         VARCHAR2(20);
    l_max_quantity_allowed NUMBER;
    l_avail_req_quantity   NUMBER;
    l_return_status        VARCHAR2(1);
    --For DB log
    l_debug                NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    --Resolve org_id and move_order_type from the passed transaction_temp_id
    SELECT mmtt.organization_id
         , mtrh.move_order_type
      INTO l_org_id
         , l_move_order_type
      FROM mtl_txn_request_headers mtrh, mtl_txn_request_lines mtrl, mtl_material_transactions_temp mmtt
     WHERE mmtt.move_order_line_id = mtrl.line_id
       AND mtrl.header_id = mtrh.header_id
       AND mmtt.transaction_temp_id = p_transaction_temp_id;

    IF (l_debug = 1) THEN
      print_debug('OVPK: Entered get_overpick_qty with the following params');
      --print_debug('OVPK: p_org_id = ' || p_org_id);
      --print_debug('OVPK: p_move_order_type = ' || p_move_order_type);
      print_debug('OVPK: p_transaction_temp_id = ' || p_transaction_temp_id);
      print_debug('OVPK: p_overpicked_qty      = ' || p_overpicked_qty);
      print_debug('OVPK: Org_id                = ' || l_org_id);
      print_debug('OVPK: Move Order Type       = ' || l_move_order_type);
    END IF;

    -- For a Replenishment (MO Type 2) / Requisition (MO Type 1)
    -- lookup the flag OVPK_TRANSFER_ORDERS_ENABLED in mtl_parameters

    IF (l_move_order_type IN
        (inv_globals.g_move_order_replenishment, inv_globals.g_move_order_requisition)
        ) THEN
      SELECT OVPK_TRANSFER_ORDERS_ENABLED
        INTO l_temp
        FROM mtl_parameters
       WHERE organization_id = l_org_id;

      IF (NVL(l_temp, 'Y') = 'Y') THEN
        x_ovpk_allowed  := 1; --Overpicking is allowed
      ELSE
        x_ovpk_allowed  := 0; --Overpicking is not allowed
      END IF;

      x_max_qty_allowed  := -1;

      IF (l_debug = 1) THEN
        print_debug('OVPK: In MTL_PARAMETERS OVPK_TRANSFER_ORDERS_ENABLED = ' || l_temp);
        print_debug('OVPK: x_ovpk_allowed = ' || x_ovpk_allowed);
        print_debug('OVPK: x_max_qty_allowed  = ' || x_max_qty_allowed);
        print_debug('OVPK: Returning from get_overpick_qty');
      END IF;

      RETURN;
    END IF;

    -- For a Manufacturing Component Pick(WIP) MO
    -- lookup the flag WIP_OVERPICK_ENABLED in mtl_parameters
    -- MO Type 5
    IF (l_move_order_type = inv_globals.g_move_order_mfg_pick) THEN
      SELECT wip_overpick_enabled
        INTO l_temp
        FROM mtl_parameters
       WHERE organization_id = l_org_id;

      IF (NVL(l_temp, 'N') = 'Y') THEN
        x_ovpk_allowed  := 1; --Overpicking is allowed
      ELSE
        x_ovpk_allowed  := 0; --Overpicking is not allowed
      END IF;

      x_max_qty_allowed  := -1;

      IF (l_debug = 1) THEN
        print_debug('OVPK: In MTL_PARAMETERS wip_overpick_enabled = ' || l_temp);
        print_debug('OVPK: x_ovpk_allowed = ' || x_ovpk_allowed);
        print_debug('OVPK: x_max_qty_allowed  = ' || x_max_qty_allowed);
        print_debug('OVPK: Returning from get_overpick_qty');
      END IF;

      RETURN;
    END IF;

    -- For a Pick Wave MO lookup the profile WSH_OVERPICKING_ENABLED
    -- MO Type 3

    IF (l_debug = 1) THEN
      print_debug('OVPK: fnd_profile WSH_OVERPICK_ENABLED = ' || fnd_profile.VALUE('WSH_OVERPICK_ENABLED'));
    END IF;

    IF (l_move_order_type = inv_globals.g_move_order_pick_wave
        AND NVL(fnd_profile.VALUE('WSH_OVERPICK_ENABLED'), 'N') = 'Y') THEN
      -- OVPK is allowed
      x_ovpk_allowed     := 1;

      -- Query the TRX_SOURCE_LINE_ID from MMTT for the given transaction_temp_id
      -- Get the transaction_quantity for the given transaction_temp_id
      SELECT trx_source_line_id
           , transaction_quantity
           , move_order_line_id
        INTO l_trx_source_line_id
           , l_this_alloc
           , l_mo_line_id
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = l_transaction_temp_id;

      IF (l_debug = 1) THEN
        print_debug('OVPK: l_trx_source_line_id = ' || l_trx_source_line_id);
        print_debug('OVPK: l_this_alloc = ' || l_this_alloc);
        print_debug('OVPK: l_mo_line_id = ' || l_mo_line_id);
      END IF;

      -- Get the sum of all allocations for that trx_source_line_id
      SELECT SUM(transaction_quantity)
        INTO l_all_alloc
        FROM mtl_material_transactions_temp
       WHERE trx_source_line_id = l_trx_source_line_id;

      -- The difference will be l_other_alloc
      l_other_alloc      := l_all_alloc - l_this_alloc;

      -- l_this_alloc is the suggested quantity
      -- To this, add p_overpicked_qty to get l_new_qty
      l_new_qty          := l_this_alloc + p_overpicked_qty;

      IF (l_debug = 1) THEN
        print_debug('OVPK: l_all_alloc   = ' || l_all_alloc);
        print_debug('OVPK: l_other_alloc = l_all_alloc - l_this_alloc = ' || l_other_alloc);
        print_debug('OVPK: Calling inv_replenish_detail_pub.check_shipping_tolerances');
        print_debug('OVPK: With the following params');
        print_debug('OVPK: l_mo_line_id = ' || l_mo_line_id);
        print_debug('OVPK: p_new_qty   = ' || l_new_qty);
      END IF;

      -- Call the shipping API to get l_max_quantity_allowed for this particular SO Line
      IF l_trx_source_line_id IS NOT NULL THEN
        inv_replenish_detail_pub.check_shipping_tolerances(
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , x_allowed                    => l_allowed_flag
        , x_max_quantity               => l_max_quantity_allowed
        , p_line_id                    => l_mo_line_id
        , p_quantity                   => l_new_qty
        );

        IF (l_debug = 1) THEN
          print_debug('OVPK: Returned from check_shipping_tolerances');
          print_debug('OVPK: x_return_status = ' || l_return_status);
          print_debug('OVPK: x_max_quantity = ' || l_max_quantity_allowed);
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

      /*
      --If the new qty is greater than l_max_quantity_allowed then overpicking is not allowed
      IF (l_new_qty > l_max_quantity_allowed) THEN
         x_ovpk_allowed := 0;
      ELSE
         x_ovpk_allowed := 1;
      END IF;
      */

      -- Calculate the max pick qty allowed for that task
      -- ie
      x_max_qty_allowed  := l_max_quantity_allowed - l_other_alloc;

      IF (l_debug = 1) THEN
        print_debug('OVPK: x_ovpk_allowed  = ' || x_ovpk_allowed);
        print_debug('OVPK: The max quantity that can be allowed for this MMTT record is');
        print_debug('OVPK: Qty allowed by shipping API - other allocations = ' || x_max_qty_allowed);
      END IF;

      RETURN;
    ELSE
      x_ovpk_allowed     := 0;
      x_max_qty_allowed  := -1;

      IF (l_debug = 1) THEN
        print_debug('OVPK: x_ovpk_allowed  = ' || x_ovpk_allowed);
        print_debug('OVPK: The max quantity that can be allowed for this MMTT record is');
        print_debug('OVPK: Qty allowed by shipping API - other allocations = ' || x_max_qty_allowed);
      END IF;

      RETURN;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Get_Overpick_Qty');
      END IF;
  END get_overpick_qty;

  -- OVPK
  -- Check_Overpick
  --
  -- This API will take 9 input parameters
  --   1. p_transaction_temp_id
  --   2. p_overpicked_qty
  --   3. p_item_id
  --   4. p_rev
  --   5. p_lot_num
  --   6. p_lot_exp_date
  --   7. p_sub
  --   8. p_locator_id
  --   9. p_lpn_id
  -- The procedure check_overpick will be called from the client java file
  -- This API check_overpick will in turn call Get_Overpick_Qty to find
  --    a) Is overpicking allowed for given Org, MO type and transaction_temp_id ?
  --    b) What is the max quantity that can be overpicked ?
  -- It will then log the appropriate error message if the user encounters such a state,
  -- such as 'Overpicking not allowed' or 'Insufficient stock' or 'Shipping Tolerance exceeded'
  -- Otherwise it will update QUANTITY_DETAILED in MTRL (if it is not a bulk picked task)
  -- and return control to the calling routine, with x_check_overpick_passed set to 'Y'
  -- thereby allowing him to overpick.
  -- This OUT param will return 1 for error INV_OVERPICK_NOT_ALLOWED
  --                            2 for error INV_LACK_MTRL_TO_OVERPICK
  --                            3 for error INV_OVERSHIP_TOLERANCE

  PROCEDURE check_overpick(
    p_transaction_temp_id   IN            NUMBER
  , p_overpicked_qty        IN            NUMBER
  , p_item_id               IN            NUMBER
  , p_rev                   IN            VARCHAR2
  , p_lot_num               IN            VARCHAR2
  , p_lot_exp_date          IN            DATE
  , p_sub                   IN            VARCHAR2
  , p_locator_id            IN            NUMBER
  , p_lpn_id                IN            NUMBER
  , x_check_overpick_passed OUT NOCOPY    VARCHAR
  , x_ovpk_error_code       OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  ) IS
    l_org_id            NUMBER;
    l_temp              NUMBER;
    l_op_plan_id        NUMBER;
    l_is_wms_enabled    BOOLEAN        := FALSE;
    l_ovpk_allowed      NUMBER;
    l_max_qty_allowed   NUMBER;
    l_this_alloc        NUMBER;
    l_mo_line_id        NUMBER;
    -- For calling query_quantities
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_ser_code          NUMBER;
    l_lot_code          NUMBER;
    l_rev_code          NUMBER;
    l_is_rev_controlled BOOLEAN        := FALSE;
    l_is_lot_controlled BOOLEAN        := FALSE;
    l_is_ser_controlled BOOLEAN        := FALSE;
    x_qoh               NUMBER;
    x_att               NUMBER;
    l_rqoh              NUMBER;
    l_qr                NUMBER;
    l_qs                NUMBER;
    l_atr               NUMBER;
    l_alloc_lpn_id      mtl_material_transactions_temp.allocated_lpn_id%TYPE;
    --l_txn_qty           NUMBER;
    --For DB log
    l_debug             NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status          := fnd_api.g_ret_sts_success;
    x_check_overpick_passed  := 'N';

    --l_txn_qty := p_overpicked_qty;
    --Resolve org_id,transaction_quantity, move_order_line_id
    --from the transaction_temp_id
    SELECT organization_id
         , transaction_quantity
         , move_order_line_id
         , allocated_lpn_id
      INTO l_org_id
         , l_this_alloc
         , l_mo_line_id
         , l_alloc_lpn_id
      FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = p_transaction_temp_id;

    IF (l_debug = 1) THEN
      print_debug('OVPK: Entered check_overpick with the following params');
      print_debug('OVPK: p_transaction_temp_id = ' || p_transaction_temp_id);
      print_debug('OVPK: l_org_id = ' || l_org_id);
      print_debug('OVPK: p_item_id = ' || p_item_id);
      print_debug('OVPK: p_overpicked_qty = ' || p_overpicked_qty);
      print_debug('OVPK: p_rev ' || p_rev);
      print_debug('OVPK: p_lot_num ' || p_lot_num);
      print_debug('OVPK: p_sub ' || p_sub);
      print_debug('OVPK: p_locator_id ' || p_locator_id);
      print_debug('OVPK: l_this_alloc = ' || l_this_alloc);
      print_debug('OVPK: p_lpn_id ' || p_lpn_id);
      print_debug('OVPK: l_mo_line_id = ' || l_mo_line_id);
      print_debug('OVPK: l_org_id = ' || l_org_id);
      print_debug('OVPK: l_alloc_lpn_id ' || l_alloc_lpn_id);
   END IF;

    -- For a WMS Org, for a Bulk pick task this API will never get called
    IF inv_install.adv_inv_installed(l_org_id) THEN
      l_is_wms_enabled  := TRUE;

      IF (l_debug = 1) THEN
        print_debug('OVPK: This org is WMS enabled');
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('OVPK: Calling get_overpick_qty with the following params');
      print_debug('OVPK: p_transaction_temp_id = ' || p_transaction_temp_id);
      print_debug('OVPK: p_overpicked_qty      = ' || p_overpicked_qty);
    END IF;

    --Call INV_Replenish_Detail_Pub.Get_Overpick_Qty
    --to find out if overpicking is allowed
    --and if allowed,to what extent
    inv_replenish_detail_pub.get_overpick_qty(
      p_transaction_temp_id        => p_transaction_temp_id
    , p_overpicked_qty             => p_overpicked_qty
    , x_ovpk_allowed               => l_ovpk_allowed
    , x_max_qty_allowed            => l_max_qty_allowed
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    );

    IF (l_debug = 1) THEN
      print_debug('OVPK: get_overpick_qty returned the following');
      print_debug('OVPK: x_return_status   = ' || x_return_status);
      print_debug('OVPK: l_ovpk_allowed    = ' || l_ovpk_allowed);
      print_debug('OVPK: l_max_qty_allowed = ' || l_max_qty_allowed);
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Overpicked quantity is passed as one of the params to this procedure
    --so no need of any code here to determine overpicked quantity

    --Is overpicking allowed i.e. Is x_ovpk_allowed = 1 ?
    IF l_ovpk_allowed = 1 THEN
      --Find out if the item is lot/serial controlled in tht chosen org
      -- comment out
      /*SELECT serial_number_control_code
           , lot_control_code
           , revision_qty_control_code
        INTO l_ser_code
           , l_lot_code
           , l_rev_code
        FROM mtl_system_items
       WHERE inventory_item_id = p_item_id
         AND organization_id = l_org_id;

      IF (l_ser_code <> 1) THEN
        l_is_ser_controlled  := TRUE;
      END IF;

      IF (l_lot_code <> 1) THEN
        l_is_lot_controlled  := TRUE;
      END IF;

      IF (l_rev_code <> 1) THEN
        l_is_rev_controlled  := TRUE;
      END IF;

      --In the same Sub/Loc/Lot/LPN find out   tempQty
      --Call inv_quantity_tree_pub.query_quantities and get att
      IF (l_debug = 1) THEN
        print_debug('OVPK: Calling query_quantities');
      END IF;

      inv_quantity_tree_pub.query_quantities(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => 'F'
      , x_return_status              => x_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_organization_id            => l_org_id
      , p_inventory_item_id          => p_item_id
      , p_tree_mode                  => 1
      , p_is_revision_control        => l_is_rev_controlled
      , p_is_lot_control             => l_is_lot_controlled
      , p_is_serial_control          => l_is_ser_controlled
      , p_demand_source_type_id      => NULL
      , p_revision                   => p_rev
      , p_lot_number                 => p_lot_num
      , p_lot_expiration_date        => p_lot_exp_date
      , p_subinventory_code          => p_sub
      , p_locator_id                 => p_locator_id
      , p_onhand_source              => 3
      , p_lpn_id                     => p_lpn_id
      , x_qoh                        => x_qoh
      , x_rqoh                       => l_rqoh
      , x_qr                         => l_qr
      , x_qs                         => l_qs
      , x_att                        => x_att
      , x_atr                        => l_atr
      );

      IF (l_debug = 1) THEN
        print_debug('OVPK: Returned from query_quantities');
        print_debug('OVPK: x_return_status = ' || x_return_status);
        print_debug('OVPK: x_att = ' || x_att);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Bug 3361293 There are 3 cases for a user to pick
      1. Allocations are for loose quantity or LPN- User is trying to pick
         from an unallocated LPN.
      2. Allocations are for LPN - User is trying to pick loose quantity
      3. User is picking from the allocations only (loose or packed).

      IF
      picking from an unallocated lpn, when allocations are for another lpn
      OR picking loose when allocation is from an lpn
      OR picking from an lpn when allocations are from loose
      THEN
      compare x_att against picked qty
      ELSE
      compare x_att with the over_picked_quantity to proceed further
      END IF
      -- end of bug 3361293

      IF ( (l_alloc_lpn_id IS NOT NULL AND p_lpn_id IS NOT NULL
            AND l_alloc_lpn_id <> p_lpn_id)
           OR (l_alloc_lpn_id IS NOT NULL AND p_lpn_id IS NULL)
           OR (l_alloc_lpn_id IS NULL AND p_lpn_id IS NOT NULL))
      THEN
         IF (l_debug = 1) THEN
            print_debug('OVPK: User is not picking from the allocations');
         END IF;
           l_txn_qty := l_this_alloc + p_overpicked_qty;
      ELSE
         IF l_debug =1 THEN
         print_debug('OVPK: User is picking from the allocations');
         END IF;
         l_txn_qty := p_overpicked_qty;
      END IF;

      IF l_debug =1 THEN
         print_debug('OVPK: l_txn_qty ' || l_txn_qty);
      END IF;*/

      -- 10/12/04 comment out the if condition and else part
      -- the att check does not cover all the cases.  remove the att part from this API
      -- and only do tolerance check.  Leave the att check to Java
      --IF (x_att >= l_txn_qty) THEN
        IF (l_max_qty_allowed <> -1
            AND (l_this_alloc + p_overpicked_qty) > l_max_qty_allowed) THEN
          -- Show ERROR : pickedQty is not within overship tolerance level
          IF (l_debug = 1) THEN
            print_debug('OVPK: pickedQty is not within overship tolerance level');
            print_debug('OVPK: Erroring out');
          END IF;

          fnd_message.set_name('INV', 'INV_OVERSHIP_TOLERANCE');
          x_ovpk_error_code := 3;
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          --Allow the user to overpick
          x_check_overpick_passed  := 'Y';

          --Bug #4762505
          --Commenting out the update statement below as it was causing the
          --quantity_detailed in MOL to be wrongly updated with the current MMTT qty
          --Updates to MOL quantity_detailed should be done after updating MMTT.
          --Update QUANTITY_DETAILED in MTRL
          /*  UPDATE mtl_txn_request_lines
               SET quantity_detailed = l_this_alloc + p_overpicked_qty
             WHERE line_id = l_mo_line_id;
           */

            IF (l_debug = 1) THEN
              print_debug('OVPK: x_check_overpick_passed = ' || x_check_overpick_passed);
              print_debug('OVPK: For MO line_id = ' || l_mo_line_id);
              print_debug('OVPK: Updated quantity_detailed column in MTRL to ' || l_this_alloc || '+' || p_overpicked_qty);
              print_debug('OVPK: Returning from check_overpick');
            END IF;
          RETURN;
        END IF;
      --ELSE
        --ERROR : Not enough material to pick in Sub/Loc/Lot/LPN
        /*IF l_debug = 1 THEN
          print_debug('OVPK: Not enough material to pick in Sub/Loc/Lot/LPN');
          print_debug('OVPK: Erroring out');
        END IF;

        fnd_message.set_name('INV', 'INV_LACK_MTRL_TO_OVERPICK');
        x_ovpk_error_code := 2;
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;*/
      --END IF;
    ELSE
      --ERROR Overpicking is not allowed in this org and for this Move Order type
      IF l_debug = 1 THEN
        print_debug('OVPK: Overpicking is not allowed in this org and for this Move Order type');
        print_debug('OVPK: Erroring out');
      END IF;

      fnd_message.set_name('INV', 'INV_OVERPICK_NOT_ALLOWED');
      x_ovpk_error_code := 1;
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Check_Overpick');
      END IF;
  END check_overpick;



    -- OVPK
  -- Check_Overpick(Overloaded procedure )
  --
  -- This API will take 10 input parameters
  --   1. p_transaction_temp_id
  --   2. p_overpicked_qty
  --   3. p_item_id
  --   4. p_rev
  --   5. p_lot_num
  --   6. p_lot_exp_date
  --   7. p_sub
  --   8. p_locator_id
  --   9. p_lpn_id
  --   10 p_att
  -- The procedure check_overpick will be called from the client java file
  -- This API check_overpick will in turn call Get_Overpick_Qty to find
  --    a) Is overpicking allowed for given Org, MO type and transaction_temp_id ?
  --    b) What is the max quantity that can be overpicked ?
  -- It will then log the appropriate error message if the user encounters such a state,
  -- such as 'Overpicking not allowed' or 'Insufficient stock' or 'Shipping Tolerance exceeded'
  -- Otherwise it will update QUANTITY_DETAILED in MTRL (if it is not a bulk picked task)
  -- and return control to the calling routine, with x_check_overpick_passed set to 'Y'
  -- thereby allowing him to overpick.
  -- This OUT param will return 1 for error INV_OVERPICK_NOT_ALLOWED
  --                            2 for error INV_LACK_MTRL_TO_OVERPICK
  --                            3 for error INV_OVERSHIP_TOLERANCE

  PROCEDURE check_overpick(
    p_transaction_temp_id   IN            NUMBER
  , p_overpicked_qty        IN            NUMBER
  , p_item_id               IN            NUMBER
  , p_rev                   IN            VARCHAR2
  , p_lot_num               IN            VARCHAR2
  , p_lot_exp_date          IN            DATE
  , p_sub                   IN            VARCHAR2
  , p_locator_id            IN            NUMBER
  , p_lpn_id                IN            NUMBER
  , p_att                   IN            NUMBER
  , x_check_overpick_passed OUT NOCOPY    VARCHAR
  , x_ovpk_error_code       OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  ) IS
    l_org_id            NUMBER;
    l_temp              NUMBER;
    l_op_plan_id        NUMBER;
    l_is_wms_enabled    BOOLEAN        := FALSE;
    l_ovpk_allowed      NUMBER;
    l_max_qty_allowed   NUMBER;
    l_this_alloc        NUMBER;
    l_mo_line_id        NUMBER;
    -- For calling query_quantities
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_ser_code          NUMBER;
    l_lot_code          NUMBER;
    l_rev_code          NUMBER;
    l_is_rev_controlled BOOLEAN        := FALSE;
    l_is_lot_controlled BOOLEAN        := FALSE;
    l_is_ser_controlled BOOLEAN        := FALSE;
    --l_rev                 VARCHAR2(3)    := p_rev;
    --l_lot_num             VARCHAR2(30)   := p_lot_num;
    --l_lot_exp_date        DATE           := p_lot_exp_date;
    --l_sub                 VARCHAR2(10)   := p_sub;
    --l_locator_id          NUMBER         := p_locator_id;
    --l_lpn_id              NUMBER         := p_lpn_id;
    x_qoh               NUMBER;
    x_att               NUMBER;
    l_rqoh              NUMBER;
    l_qr                NUMBER;
    l_qs                NUMBER;
    l_atr               NUMBER;
    --For DB log
    l_debug             NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status          := fnd_api.g_ret_sts_success;
    x_check_overpick_passed  := 'N';

    --Resolve org_id,transaction_quantity, move_order_line_id
    --from the transaction_temp_id
    SELECT organization_id
         , transaction_quantity
         , move_order_line_id
      INTO l_org_id
         , l_this_alloc
         , l_mo_line_id
      FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = p_transaction_temp_id;


    IF (l_debug = 1) THEN
      print_debug('OVPK: Entered check_overpick with the following params');
      print_debug('OVPK: p_transaction_temp_id = ' || p_transaction_temp_id);
      print_debug('OVPK: l_org_id = ' || l_org_id);
      print_debug('OVPK: p_item_id = ' || p_item_id);
      print_debug('OVPK: p_overpicked_qty = ' || p_overpicked_qty);
      print_debug('OVPK: p_rev ' || p_rev);
      print_debug('OVPK: p_lot_num ' || p_lot_num);
      print_debug('OVPK: p_sub ' || p_sub);
      print_debug('OVPK: p_locator_id ' || p_locator_id);
      print_debug('OVPK: l_this_alloc = ' || l_this_alloc);
      print_debug('OVPK: p_lpn_id ' || p_lpn_id);
      print_debug('OVPK: l_mo_line_id = ' || l_mo_line_id);
      print_debug('OVPK: p_att = ' || p_att);
    END IF;

    -- For a WMS Org, this API should never get called for a Bulk Task
    IF inv_install.adv_inv_installed(l_org_id) THEN
      l_is_wms_enabled  := TRUE;

      IF (l_debug = 1) THEN
        print_debug('OVPK: This org is WMS enabled');
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('OVPK: Calling get_overpick_qty with the following params');
      print_debug('OVPK: p_transaction_temp_id = ' || p_transaction_temp_id);
      print_debug('OVPK: p_overpicked_qty      = ' || p_overpicked_qty);
    END IF;

    --Call INV_Replenish_Detail_Pub.Get_Overpick_Qty
    --to find out if overpicking is allowed
    --and if allowed,to what extent
    inv_replenish_detail_pub.get_overpick_qty(
      p_transaction_temp_id        => p_transaction_temp_id
    , p_overpicked_qty             => p_overpicked_qty
    , x_ovpk_allowed               => l_ovpk_allowed
    , x_max_qty_allowed            => l_max_qty_allowed
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    );

    IF (l_debug = 1) THEN
      print_debug('OVPK: get_overpick_qty returned the following');
      print_debug('OVPK: x_return_status   = ' || x_return_status);
      print_debug('OVPK: l_ovpk_allowed    = ' || l_ovpk_allowed);
      print_debug('OVPK: l_max_qty_allowed = ' || l_max_qty_allowed);
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Overpicked quantity is passed as one of the params to this procedure
    --so no need of any code here to determine overpicked quantity

    --Is overpicking allowed i.e. Is x_ovpk_allowed = 1 ?
    IF l_ovpk_allowed = 1 THEN
      --Find out if the item is lot/serial controlled in tht chosen org
      SELECT serial_number_control_code
           , lot_control_code
           , revision_qty_control_code
        INTO l_ser_code
           , l_lot_code
           , l_rev_code
        FROM mtl_system_items
       WHERE inventory_item_id = p_item_id
         AND organization_id = l_org_id;

      IF (l_ser_code <> 1) THEN
        l_is_ser_controlled  := TRUE;
      END IF;

      IF (l_lot_code <> 1) THEN
        l_is_lot_controlled  := TRUE;
      END IF;

      IF (l_rev_code <> 1) THEN
        l_is_rev_controlled  := TRUE;
      END IF;

    /*  --In the same Sub/Loc/Lot/LPN find out   tempQty
      --Call inv_quantity_tree_pub.query_quantities and get att
      IF (l_debug = 1) THEN
        print_debug('OVPK: Calling query_quantities');
      END IF;

      inv_quantity_tree_pub.query_quantities(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => 'F'
      , x_return_status              => x_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_organization_id            => l_org_id
      , p_inventory_item_id          => p_item_id
      , p_tree_mode                  => 1
      , p_is_revision_control        => l_is_rev_controlled
      , p_is_lot_control             => l_is_lot_controlled
      , p_is_serial_control          => l_is_ser_controlled
      , p_demand_source_type_id      => NULL
      , p_revision                   => p_rev
      , p_lot_number                 => p_lot_num
      , p_lot_expiration_date        => p_lot_exp_date
      , p_subinventory_code          => p_sub
      , p_locator_id                 => p_locator_id
      , p_onhand_source              => 3
      , p_lpn_id                     => p_lpn_id
      , x_qoh                        => x_qoh
      , x_rqoh                       => l_rqoh
      , x_qr                         => l_qr
      , x_qs                         => l_qs
      , x_att                        => x_att
      , x_atr                        => l_atr
      );
      */

      x_att:= p_att;

      IF (l_debug = 1) THEN
        print_debug('OVPK: Returned from query_quantities');
        print_debug('OVPK: x_return_status = ' || x_return_status);
        print_debug('OVPK: x_att = ' || x_att);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (x_att >= p_overpicked_qty) THEN
        IF (l_max_qty_allowed <> -1
            AND (l_this_alloc + p_overpicked_qty) > l_max_qty_allowed) THEN
          -- Show ERROR : pickedQty is not within overship tolerance level
          IF (l_debug = 1) THEN
            print_debug('OVPK: pickedQty is not within overship tolerance level');
            print_debug('OVPK: Erroring out');
          END IF;

          fnd_message.set_name('INV', 'INV_OVERSHIP_TOLERANCE');
          x_ovpk_error_code := 3;
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          --Allow the user to overpick
          x_check_overpick_passed  := 'Y';

          --Bug #4762505
          --Commenting out the update statement below as it was causing the
          --quantity_detailed in MOL to be wrongly updated with the current MMTT qty
          --Updates to MOL quantity_detailed should be done after updating MMTT.
          --Update QUANTITY_DETAILED in MTRL
          /*  UPDATE mtl_txn_request_lines
               SET quantity_detailed = l_this_alloc + p_overpicked_qty
             WHERE line_id = l_mo_line_id;
           */

            IF (l_debug = 1) THEN
              print_debug('OVPK: x_check_overpick_passed = ' || x_check_overpick_passed);
              print_debug('OVPK: For MO line_id = ' || l_mo_line_id);
              print_debug('OVPK: Updated quantity_detailed column in MTRL to ' || l_this_alloc || '+' || p_overpicked_qty);
              print_debug('OVPK: Returning from check_overpick');
            END IF;
          RETURN;
        END IF;
      ELSE
        --ERROR : Not enough material to pick in Sub/Loc/Lot/LPN
        IF l_debug = 1 THEN
          print_debug('OVPK: Not enough material to pick in Sub/Loc/Lot/LPN');
          print_debug('OVPK: Erroring out');
        END IF;

        fnd_message.set_name('INV', 'INV_LACK_MTRL_TO_OVERPICK');
        x_ovpk_error_code := 2;
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      --ERROR Overpicking is not allowed in this org and for this Move Order type
      IF l_debug = 1 THEN
        print_debug('OVPK: Overpicking is not allowed in this org and for this Move Order type');
        print_debug('OVPK: Erroring out');
      END IF;

      fnd_message.set_name('INV', 'INV_OVERPICK_NOT_ALLOWED');
      x_ovpk_error_code := 1;
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Check_Overpick');
      END IF;
  END check_overpick;




  -- OVPK - APL
  -- This API is similar to get_overpick_qty
  -- But this API will also do the MTLT level check for overpicking
  -- which is not there in get_overpick_qty
  -- The additional IN parameter needed here is p_lot_num
  PROCEDURE get_overpick_qty_lot(
    p_transaction_temp_id IN            NUMBER
  , p_overpicked_qty      IN            NUMBER
  , p_lot_num             IN            VARCHAR2
  , x_ovpk_allowed        OUT NOCOPY    NUMBER
  , x_max_qty_allowed     OUT NOCOPY    NUMBER
  , x_other_mtlt          OUT NOCOPY    NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  ) IS
    l_org_id               NUMBER;
    l_move_order_type      NUMBER;
    l_transaction_temp_id  NUMBER         := p_transaction_temp_id;
    l_trx_source_line_id   NUMBER;
    l_all_alloc            NUMBER;
    l_other_alloc          NUMBER;
    l_lot_num              VARCHAR2(30)   := p_lot_num;
    l_all_mtlt             NUMBER;
    l_this_mtlt            NUMBER;
    l_other_mtlt           NUMBER;
    l_this_alloc           NUMBER;
    l_temp                 VARCHAR2(1);
    l_new_qty              NUMBER;
    --Check_Shipping_Tolerances
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_mo_line_id           NUMBER;
    --l_ordered_quantity  NUMBER := -1;

    --Shipping
    l_allowed_flag         VARCHAR2(20);
    l_max_quantity_allowed NUMBER;
    l_avail_req_quantity   NUMBER;
    l_return_status        VARCHAR2(1);
    --For DB log
    l_debug                NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    --Resolve org_id and move_order_type from the passed transaction_temp_id
    SELECT mmtt.organization_id
         , mtrh.move_order_type
      INTO l_org_id
         , l_move_order_type
      FROM mtl_txn_request_headers mtrh, mtl_txn_request_lines mtrl, mtl_material_transactions_temp mmtt
     WHERE mmtt.move_order_line_id = mtrl.line_id
       AND mtrl.header_id = mtrh.header_id
       AND mmtt.transaction_temp_id = p_transaction_temp_id;

    IF (l_debug = 1) THEN
      print_debug('OVPK: Entered get_overpick_qty with the following params');
      --print_debug('OVPK: p_org_id = ' || p_org_id);
      --print_debug('OVPK: p_move_order_type = ' || p_move_order_type);
      print_debug('OVPK: p_transaction_temp_id = ' || p_transaction_temp_id);
      print_debug('OVPK: p_overpicked_qty      = ' || p_overpicked_qty);
      print_debug('OVPK: p_lot_num             = ' || p_lot_num);
      print_debug('OVPK: Org_id                = ' || l_org_id);
      print_debug('OVPK: Move Order Type       = ' || l_move_order_type);
    END IF;

    -- For a Replenishment (MO Type 2) / Requisition (MO Type 1)
    -- lookup the flag OVPK_TRANSFER_ORDERS_ENABLED in mtl_parameters

    IF (l_move_order_type IN
        (inv_globals.g_move_order_replenishment, inv_globals.g_move_order_requisition)
        ) THEN
      SELECT OVPK_TRANSFER_ORDERS_ENABLED
        INTO l_temp
        FROM mtl_parameters
       WHERE organization_id = l_org_id;

      IF (NVL(l_temp, 'Y') = 'Y') THEN
        x_ovpk_allowed  := 1; --Overpicking is allowed
      ELSE
        x_ovpk_allowed  := 0; --Overpicking is not allowed
      END IF;

      x_max_qty_allowed  := -1;

      IF (l_debug = 1) THEN
        print_debug('OVPK: In MTL_PARAMETERS OVPK_TRANSFER_ORDERS_ENABLED = ' || l_temp);
        print_debug('OVPK: x_ovpk_allowed = ' || x_ovpk_allowed);
        print_debug('OVPK: x_max_qty_allowed  = ' || x_max_qty_allowed);
        print_debug('OVPK: Returning from get_overpick_qty');
      END IF;

      RETURN;
    END IF;

    -- For a Manufacturing Component Pick(WIP) MO
    -- lookup the flag WIP_OVERPICK_ENABLED in mtl_parameters
    -- MO Type 5
    IF (l_move_order_type = inv_globals.g_move_order_mfg_pick) THEN
      SELECT wip_overpick_enabled
        INTO l_temp
        FROM mtl_parameters
       WHERE organization_id = l_org_id;

      IF (NVL(l_temp, 'N') = 'Y') THEN
        x_ovpk_allowed  := 1; --Overpicking is allowed
      ELSE
        x_ovpk_allowed  := 0; --Overpicking is not allowed
      END IF;

      x_max_qty_allowed  := -1;

      IF (l_debug = 1) THEN
        print_debug('OVPK: In MTL_PARAMETERS wip_overpick_enabled = ' || l_temp);
        print_debug('OVPK: x_ovpk_allowed = ' || x_ovpk_allowed);
        print_debug('OVPK: x_max_qty_allowed  = ' || x_max_qty_allowed);
        print_debug('OVPK: Returning from get_overpick_qty');
      END IF;

      RETURN;
    END IF;

    -- For a Pick Wave MO lookup the profile WSH_OVERPICKING_ENABLED
    -- MO Type 3

    IF (l_debug = 1) THEN
      print_debug('OVPK: fnd_profile WSH_OVERPICK_ENABLED = ' || fnd_profile.VALUE('WSH_OVERPICK_ENABLED'));
    END IF;

    IF (l_move_order_type = inv_globals.g_move_order_pick_wave
        AND NVL(fnd_profile.VALUE('WSH_OVERPICK_ENABLED'), 'N') = 'Y') THEN
      -- OVPK is allowed
      x_ovpk_allowed     := 1;

      -- Query the TRX_SOURCE_LINE_ID from MMTT for the given transaction_temp_id
      -- Get the transaction_quantity for the given transaction_temp_id
      SELECT trx_source_line_id
           , transaction_quantity
           , move_order_line_id
        INTO l_trx_source_line_id
           , l_this_alloc
           , l_mo_line_id
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = l_transaction_temp_id;

      IF (l_debug = 1) THEN
        print_debug('OVPK: l_trx_source_line_id = ' || l_trx_source_line_id);
        print_debug('OVPK: l_this_alloc = ' || l_this_alloc);
        print_debug('OVPK: l_mo_line_id = ' || l_mo_line_id);
      END IF;

      -- Get the sum of all allocations for that trx_source_line_id
      SELECT SUM(transaction_quantity)
        INTO l_all_alloc
        FROM mtl_material_transactions_temp
       WHERE trx_source_line_id = l_trx_source_line_id;

      -- The difference will be l_other_alloc
      l_other_alloc      := l_all_alloc - l_this_alloc;

      -- l_this_alloc is the suggested quantity
      -- To this, add p_overpicked_qty to get l_new_qty
      l_new_qty          := l_this_alloc + p_overpicked_qty;

      IF (l_debug = 1) THEN
        print_debug('OVPK: l_all_alloc   = ' || l_all_alloc);
        print_debug('OVPK: l_other_alloc = l_all_alloc - l_this_alloc = ' || l_other_alloc);
        print_debug('OVPK: Calling inv_replenish_detail_pub.check_shipping_tolerances');
        print_debug('OVPK: With the following params');
        print_debug('OVPK: l_mo_line_id = ' || l_mo_line_id);
        print_debug('OVPK: p_new_qty   = ' || l_new_qty);
      END IF;

      -- Call the shipping API to get l_max_quantity_allowed for this particular SO Line
      IF l_trx_source_line_id IS NOT NULL THEN
        inv_replenish_detail_pub.check_shipping_tolerances(
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , x_allowed                    => l_allowed_flag
        , x_max_quantity               => l_max_quantity_allowed
        , p_line_id                    => l_mo_line_id
        , p_quantity                   => l_new_qty
        );

        IF (l_debug = 1) THEN
          print_debug('OVPK: Returned from check_shipping_tolerances');
          print_debug('OVPK: x_return_status = ' || l_return_status);
          print_debug('OVPK: x_max_quantity = ' || l_max_quantity_allowed);
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

      /*
      --If the new qty is greater than l_max_quantity_allowed then overpicking is not allowed
      IF (l_new_qty > l_max_quantity_allowed) THEN
         x_ovpk_allowed := 0;
      ELSE
         x_ovpk_allowed := 1;
      END IF;
      */

      -- Calculate the max pick qty allowed for that task
      -- ie
      x_max_qty_allowed  := l_max_quantity_allowed - l_other_alloc;

      -- For lot item deduct the other MTLT's
      IF (l_lot_num IS NOT NULL) THEN
         IF l_debug = 1 THEN
            print_debug('OVPK: l_lot_num  = ' || l_lot_num);
         END IF;
         -- Get sum of txn qty of all mtlt's for this mmtt
         SELECT nvl(SUM(transaction_quantity),0)
           INTO l_all_mtlt
           FROM mtl_transaction_lots_temp
          WHERE transaction_temp_id = l_transaction_temp_id;

        --/* Bug 9448490 Lot Substitution Project */ start
         BEGIN
         -- Get this mtlt
            SELECT nvl(SUM(transaction_quantity),0)
              INTO l_this_mtlt
              FROM mtl_transaction_lots_temp
             WHERE transaction_temp_id = l_transaction_temp_id
               AND lot_number = l_lot_num;
    	   EXCEPTION
         WHEN OTHERS THEN
	       null;
	       END;

         --/* Bug 9448490 Lot Substitution Project */ end


         l_other_mtlt := l_all_mtlt - l_this_mtlt;

         IF l_debug = 1 THEN
            print_debug('OVPK: l_all_mtlt   = ' || l_all_mtlt);
            print_debug('OVPK: l_this_mtlt  = ' || l_this_mtlt);
            print_debug('OVPK: l_other_mtlt = ' || l_other_mtlt);
         END IF;

         x_max_qty_allowed := x_max_qty_allowed - l_other_mtlt;
         x_other_mtlt := l_other_mtlt;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('OVPK: x_ovpk_allowed  = ' || x_ovpk_allowed);
        print_debug('OVPK: The max quantity that can be allowed for this MMTT record is');
        print_debug('OVPK: Qty allowed by shipping API - other allocations - other MTLT''s = ' || x_max_qty_allowed);
      END IF;

      RETURN;
    ELSE
      x_ovpk_allowed     := 0;
      x_max_qty_allowed  := -1;

      IF (l_debug = 1) THEN
        print_debug('OVPK: x_ovpk_allowed  = ' || x_ovpk_allowed);
        print_debug('OVPK: The max quantity that can be allowed for this MMTT record is');
        print_debug('OVPK: Qty allowed by shipping API - other allocations = ' || x_max_qty_allowed);
      END IF;

      RETURN;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Get_Overpick_Qty');
      END IF;
  END get_overpick_qty_lot;

PROCEDURE check_overpick_lot(
    p_transaction_temp_id   IN            NUMBER
  , p_overpicked_qty        IN            NUMBER
  , p_item_id               IN            NUMBER
  , p_rev                   IN            VARCHAR2
  , p_lot_num               IN            VARCHAR2
  , p_lot_exp_date          IN            DATE
  , p_sub                   IN            VARCHAR2
  , p_locator_id            IN            NUMBER
  , p_lpn_id                IN            NUMBER
  , x_check_overpick_passed OUT NOCOPY    VARCHAR
  , x_ovpk_error_code       OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  ) IS
    l_org_id            NUMBER;
    l_temp              NUMBER;
    l_op_plan_id        NUMBER;
    l_is_wms_enabled    BOOLEAN        := FALSE;
    l_ovpk_allowed      NUMBER;
    l_max_qty_allowed   NUMBER;
    l_this_alloc        NUMBER;
    l_mo_line_id        NUMBER;
    l_other_mtlt        NUMBER := 0;
    -- For calling query_quantities
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_ser_code          NUMBER;
    l_lot_code          NUMBER;
    l_rev_code          NUMBER;
    l_is_rev_controlled BOOLEAN        := FALSE;
    l_is_lot_controlled BOOLEAN        := FALSE;
    l_is_ser_controlled BOOLEAN        := FALSE;
    x_qoh               NUMBER;
    x_att               NUMBER;
    l_rqoh              NUMBER;
    l_qr                NUMBER;
    l_qs                NUMBER;
    l_atr               NUMBER;
    --For DB log
    l_debug             NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status          := fnd_api.g_ret_sts_success;
    x_check_overpick_passed  := 'N';

    --Resolve org_id,transaction_quantity, move_order_line_id
    --from the transaction_temp_id
    SELECT organization_id
         , transaction_quantity
         , move_order_line_id
      INTO l_org_id
         , l_this_alloc
         , l_mo_line_id
      FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = p_transaction_temp_id;

    IF (l_debug = 1) THEN
      print_debug('OVPK: Entered check_overpick with the following params');
      --print_debug('OVPK: p_move_order_type = ' || p_move_order_type);
      print_debug('OVPK: p_transaction_temp_id = ' || p_transaction_temp_id);
      print_debug('OVPK: l_org_id = ' || l_org_id);
      print_debug('OVPK: p_item_id = ' || p_item_id);
      print_debug('OVPK: p_overpicked_qty = ' || p_overpicked_qty);
      print_debug('OVPK: l_this_alloc = ' || l_this_alloc);
      print_debug('OVPK: l_mo_line_id = ' || l_mo_line_id);
    END IF;

    -- For a WMS Org, find if the task is a bulk pick task
    IF inv_install.adv_inv_installed(l_org_id) THEN
      l_is_wms_enabled  := TRUE;

      IF (l_debug = 1) THEN
        print_debug('OVPK: This org is WMS enabled');
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('OVPK: Calling get_overpick_qty with the following params');
      --print_debug('OVPK: p_org_id = ' || p_org_id);
      --print_debug('OVPK: p_move_order_type = ' || p_move_order_type);
      print_debug('OVPK: p_transaction_temp_id = ' || p_transaction_temp_id);
      print_debug('OVPK: p_overpicked_qty      = ' || p_overpicked_qty);
      print_debug('OVPK: p_lot_num             = ' || p_lot_num);
    END IF;

    --Call INV_Replenish_Detail_Pub.Get_Overpick_Qty_Lot
    --to find out if overpicking is allowed
    --and if allowed,to what extent
    inv_replenish_detail_pub.get_overpick_qty_lot(
      p_transaction_temp_id        => p_transaction_temp_id
    , p_overpicked_qty             => p_overpicked_qty
    , p_lot_num                    => p_lot_num
    , x_ovpk_allowed               => l_ovpk_allowed
    , x_max_qty_allowed            => l_max_qty_allowed
    , x_other_mtlt                 => l_other_mtlt
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    );

    IF (l_debug = 1) THEN
      print_debug('OVPK: get_overpick_qty returned the following');
      print_debug('OVPK: x_return_status   = ' || x_return_status);
      print_debug('OVPK: l_ovpk_allowed    = ' || l_ovpk_allowed);
      print_debug('OVPK: l_max_qty_allowed = ' || l_max_qty_allowed);
      print_debug('OVPK: x_other_mtlt      = ' || l_other_mtlt);
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Overpicked quantity is passed as one of the params to this procedure
    --so no need of any code here to determine overpicked quantity

    --Is overpicking allowed i.e. Is x_ovpk_allowed = 1 ?
    IF l_ovpk_allowed = 1 THEN
      --Find out if the item is lot/serial controlled in tht chosen org
     /* SELECT serial_number_control_code
           , lot_control_code
           , revision_qty_control_code
        INTO l_ser_code
           , l_lot_code
           , l_rev_code
        FROM mtl_system_items
       WHERE inventory_item_id = p_item_id
         AND organization_id = l_org_id;

      IF (l_ser_code <> 1) THEN
        l_is_ser_controlled  := TRUE;
      END IF;

      IF (l_lot_code <> 1) THEN
        l_is_lot_controlled  := TRUE;
      END IF;

      IF (l_rev_code <> 1) THEN
        l_is_rev_controlled  := TRUE;
      END IF;

      --In the same Sub/Loc/Lot/LPN find out   tempQty
      --Call inv_quantity_tree_pub.query_quantities and get att
      IF (l_debug = 1) THEN
        print_debug('OVPK: Calling query_quantities');
      END IF;

      inv_quantity_tree_pub.query_quantities(
        p_api_version_number         => 1.0
      , p_init_msg_lst               => 'F'
      , x_return_status              => x_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_organization_id            => l_org_id
      , p_inventory_item_id          => p_item_id
      , p_tree_mode                  => 1
      , p_is_revision_control        => l_is_rev_controlled
      , p_is_lot_control             => l_is_lot_controlled
      , p_is_serial_control          => l_is_ser_controlled
      , p_demand_source_type_id      => NULL
      , p_revision                   => p_rev
      , p_lot_number                 => p_lot_num
      , p_lot_expiration_date        => p_lot_exp_date
      , p_subinventory_code          => p_sub
      , p_locator_id                 => p_locator_id
      , p_onhand_source              => 3
      , p_lpn_id                     => p_lpn_id
      , x_qoh                        => x_qoh
      , x_rqoh                       => l_rqoh
      , x_qr                         => l_qr
      , x_qs                         => l_qs
      , x_att                        => x_att
      , x_atr                        => l_atr
      );

      IF (l_debug = 1) THEN
        print_debug('OVPK: Returned from query_quantities');
        print_debug('OVPK: x_return_status = ' || x_return_status);
        print_debug('OVPK: x_att = ' || x_att);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;*/

      --comment out the if condition and else part since system do att check already
      --IF (x_att >= p_overpicked_qty) THEN
        IF (l_max_qty_allowed <> -1
            AND (l_this_alloc + p_overpicked_qty - l_other_mtlt) > l_max_qty_allowed) THEN
          -- Show ERROR : pickedQty is not within overship tolerance level
          IF (l_debug = 1) THEN
            print_debug('OVPK: pickedQty is not within overship tolerance level');
            print_debug('OVPK: Erroring out');
          END IF;

          fnd_message.set_name('INV', 'INV_OVERSHIP_TOLERANCE');
          x_ovpk_error_code := 3;
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          --Allow the user to overpick
          x_check_overpick_passed  := 'Y';

          --Bug #4762505
          --Commenting out the update statement below as it was causing the
          --quantity_detailed in MOL to be wrongly updated with the current MMTT qty
          --Updates to MOL quantity_detailed should be done after updating MMTT.
          --Update QUANTITY_DETAILED in MTRL
          /*  UPDATE mtl_txn_request_lines
               SET quantity_detailed = l_this_alloc + p_overpicked_qty
             WHERE line_id = l_mo_line_id;
           */

            IF (l_debug = 1) THEN
              print_debug('OVPK: x_check_overpick_passed = ' || x_check_overpick_passed);
              print_debug('OVPK: For MO line_id = ' || l_mo_line_id);
              print_debug('OVPK: Updated quantity_detailed column in MTRL to ' || l_this_alloc || '+' || p_overpicked_qty);
              print_debug('OVPK: Returning from check_overpick');
            END IF;
          RETURN;
        END IF;
      /*ELSE
        --ERROR : Not enough material to pick in Sub/Loc/Lot/LPN
        IF l_debug = 1 THEN
          print_debug('OVPK: Not enough material to pick in Sub/Loc/Lot/LPN');
          print_debug('OVPK: Erroring out');
        END IF;

        fnd_message.set_name('INV', 'INV_LACK_MTRL_TO_OVERPICK');
        x_ovpk_error_code := 2;
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;*/
    ELSE
      --ERROR Overpicking is not allowed in this org and for this Move Order type
      IF l_debug = 1 THEN
        print_debug('OVPK: Overpicking is not allowed in this org and for this Move Order type');
        print_debug('OVPK: Erroring out');
      END IF;

      fnd_message.set_name('INV', 'INV_OVERPICK_NOT_ALLOWED');
      x_ovpk_error_code := 1;
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Check_Overpick');
      END IF;
  END check_overpick_lot;

---------------------------------------------------
END inv_replenish_detail_pub;

/
