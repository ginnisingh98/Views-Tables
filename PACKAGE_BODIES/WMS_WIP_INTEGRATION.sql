--------------------------------------------------------
--  DDL for Package Body WMS_WIP_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_WIP_INTEGRATION" AS
/* $Header: WMSWIPIB.pls 120.3.12010000.4 2008/10/10 18:12:38 bvanjaku ship $ */

--  Global constant holding the package name

G_PKG_NAME   CONSTANT VARCHAR2(30) := 'WMS_WIP_Integration';


PROCEDURE Update_MO_Line
  (p_lpn_id 				  IN NUMBER,
   p_wms_process_flag 			  IN NUMBER,
   x_return_status                        OUT   NOCOPY VARCHAR2,
   x_msg_count                            OUT   NOCOPY NUMBER,
   x_msg_data                             OUT   NOCOPY VARCHAR2)

IS
  	 l_return_status		      VARCHAR2(1);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	l_return_status:= FND_API.G_RET_STS_SUCCESS;

	UPDATE mtl_txn_request_lines
	SET wms_process_flag = p_wms_process_flag
	WHERE lpn_id = p_lpn_id;

	x_return_status:=l_return_status;

EXCEPTION

   WHEN no_data_found THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END Update_MO_Line;



PROCEDURE Backflush
  (p_header_id 				  IN NUMBER,
   x_return_status                        OUT   NOCOPY VARCHAR2,
   x_msg_count                            OUT   NOCOPY NUMBER,
   x_msg_data                             OUT   NOCOPY VARCHAR2)

IS
	l_count				NUMBER;
        l_msg_data  			VARCHAR2(5000);
	l_return_status		      	VARCHAR2(1);
	l_next_transaction_temp_id	NUMBER;
	l_next_transaction_header_id	NUMBER;
	l_next_ser_tran_temp_id		NUMBER;
	l_query_result			NUMBER;

	l_source_id			NUMBER;
	l_temp_source_id 		NUMBER;
	l_temp_header_id 		NUMBER;
	l_temp2_header_id 		NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
	l_lot_number			VARCHAR2(80);
     	l_txn_ret 			NUMBER;
	l_fm_serial_number              VARCHAR2(30);


	CURSOR wip_lpn_completions_csr IS
	   SELECT
	     header_id,
	     source_id
	     FROM   	wip_lpn_completions
	     WHERE  	source_id = l_source_id
	     AND    	source_id <> header_id;

	CURSOR wip_lpn_comp_serials_csr IS
	   SELECT
	     header_id,
	     lot_number,
	     fm_serial_number
	     FROM	wip_lpn_completions_serials
	     WHERE	header_id = l_temp_header_id
	     AND	lot_number is not null;

	CURSOR wip_lpn_comp_serials_csr2 IS
	   SELECT fm_serial_number
	     FROM wip_lpn_completions_serials
	     WHERE header_id = l_temp_header_id
	     AND   lot_number IS NULL;

        /* Bug: 2976160 : cursor defined to replace 'Select INTO ' to support
                multiple lots in wip_lpn_completions_lots for the given header_id. */
        CURSOR wip_lpn_comp_lots_csr IS
            SELECT  lot_number
            FROM  wip_lpn_completions_lots
            WHERE header_id = l_temp_header_id;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   l_return_status:= FND_API.G_RET_STS_SUCCESS;
   l_query_result := 0;
   l_txn_ret:=0;

   BEGIN

      SELECT
	1,
	source_id
	INTO
 	l_query_result,
	l_source_id
	FROM   	wip_lpn_completions
	WHERE  	header_id = p_header_id;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 l_query_result := 0;
   END;

   IF l_query_result <> 0 THEN


      --Get value from sequence for next transaction_header_id
      SELECT mtl_material_transactions_s.NEXTVAL
	INTO l_next_transaction_header_id
	FROM dual ;

      IF (l_debug = 1) THEN
         mydebug('Backflush: header_id: ' || l_next_transaction_header_id);
      END IF;

      OPEN wip_lpn_completions_csr;
      LOOP
	 FETCH 	wip_lpn_completions_csr
	   INTO	l_temp_header_id,
	   l_temp_source_id;
	 EXIT when wip_lpn_completions_csr%NOTFOUND;

	-- Insert into mtl_material_transactions_temp

	 --Get value from sequence for next transaction_temp_id
	 SELECT mtl_material_transactions_s.NEXTVAL
	   INTO l_next_transaction_temp_id
	   FROM dual ;

	 IF (l_debug = 1) THEN
   	 mydebug('Backflush: temp_id '||l_next_transaction_temp_id);
	 END IF;

	 INSERT INTO mtl_material_transactions_temp
	   (	transaction_temp_id,
		transaction_header_id,
		source_code,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		program_application_id,
		program_id,
		program_update_date,
		inventory_item_id,
		organization_id,
		primary_quantity,
		transaction_quantity,
		transaction_uom,
		transaction_date,
		transaction_action_id,
		transaction_source_id,
		transaction_source_type_id,
		transaction_type_id,
		transaction_mode,
		acct_period_id,
		subinventory_code,
		locator_id,
		wip_entity_type,
		schedule_id,
		repetitive_line_id,
		operation_seq_num,
		cost_group_id,
		kanban_card_id,
		qa_collection_id,
		lpn_id,
		reason_id,
		lock_flag,
		error_code,
		final_completion_flag,
		end_item_unit_number,
		transaction_status,
		process_flag,
		completion_transaction_id,
                flow_schedule,
                source_line_id,
                wip_supply_type,
		revision,
                source_project_id,
                source_task_id
	)
	(SELECT	l_next_transaction_temp_id,
		l_next_transaction_header_id,
		source_code,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		program_application_id,
		program_id,
		program_update_date,
		inventory_item_id,
		organization_id,
		primary_quantity,
		transaction_quantity,
		transaction_uom,
		transaction_date,
		transaction_action_id,
		transaction_source_id,
		transaction_source_type_id,
		transaction_type_id,
		transaction_mode,
		acct_period_id,
		subinventory_code,
		locator_id,
		wip_entity_type,
		schedule_id,
		repetitive_line_id,
		operation_seq_num,
		cost_group_id,
		kanban_card_id,
		qa_collection_id,
		lpn_id,
		reason_id,
		lock_flag,
		error_code,
		final_completion_flag,
		end_item_unit_number,
		3,
		'Y',
		completion_transaction_id,
                decode(wip_entity_type, 4, 'Y', null),
                source_id,
	        NULL,
	        bom_revision,
                source_project_id,
                source_task_id
	 FROM	wip_lpn_completions
	 WHERE	header_id = l_temp_header_id
	 AND	source_id = l_temp_source_id);

	 IF (l_debug = 1) THEN
   	 mydebug('Backflush: after insert into MMTT' || l_temp_header_id || ' ' || l_temp_source_id);
	 END IF;

	 -- Logic for finding which rows will be inserted
	 -- in the mtl_serial_numbers_temp table

         IF (l_debug = 1) THEN
         mydebug('Backflush: insert into mtl_serial_numbers_temp' );
         END IF;

	 INSERT	INTO	mtl_serial_numbers_temp
	   (	transaction_temp_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		request_id,
			program_application_id,
			program_id,
			program_update_date,
			fm_serial_number,
			to_serial_number,
			serial_prefix,
			parent_serial_number,
			error_code,
--			transaction_quantity,
			serial_attribute_category,
			origination_date,
			C_ATTRIBUTE1,
			C_ATTRIBUTE2,
 			C_ATTRIBUTE3,
 			C_ATTRIBUTE4,
			C_ATTRIBUTE5,
			C_ATTRIBUTE6,
 			C_ATTRIBUTE7,
 			C_ATTRIBUTE8,
			C_ATTRIBUTE9,
			C_ATTRIBUTE10,
 			C_ATTRIBUTE11,
 			C_ATTRIBUTE12,
			C_ATTRIBUTE13,
			C_ATTRIBUTE14,
 			C_ATTRIBUTE15,
 			C_ATTRIBUTE16,
 			C_ATTRIBUTE17,
			C_ATTRIBUTE18,
			C_ATTRIBUTE19,
 			C_ATTRIBUTE20,
 			D_ATTRIBUTE1,
 			D_ATTRIBUTE2,
 			D_ATTRIBUTE3,
 			D_ATTRIBUTE4,
 			D_ATTRIBUTE5,
 			D_ATTRIBUTE6,
 			D_ATTRIBUTE7,
 			D_ATTRIBUTE8,
 			D_ATTRIBUTE9,
 			D_ATTRIBUTE10,
 			N_ATTRIBUTE1,
 			N_ATTRIBUTE2,
 			N_ATTRIBUTE3,
 			N_ATTRIBUTE4,
 			N_ATTRIBUTE5,
 			N_ATTRIBUTE6,
 			N_ATTRIBUTE7,
 			N_ATTRIBUTE8,
 			N_ATTRIBUTE9,
 			N_ATTRIBUTE10,
			territory_code,
			time_since_new,
			cycles_since_new,
			time_since_overhaul,
			cycles_since_overhaul,
			time_since_repair,
			cycles_since_repair,
			time_since_visit,
			cycles_since_visit,
			time_since_mark,
			cycles_since_mark
		)
		(SELECT	l_next_transaction_temp_id,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login,
			request_id,
			program_application_id,
			program_id,
			program_update_date,
			fm_serial_number,
			to_serial_number,
			serial_prefix,
			parent_serial_number,
			error_code,
--			transaction_quantity,
			serial_attribute_category,
			origination_date,
			C_ATTRIBUTE1,
			C_ATTRIBUTE2,
 			C_ATTRIBUTE3,
 			C_ATTRIBUTE4,
			C_ATTRIBUTE5,
			C_ATTRIBUTE6,
 			C_ATTRIBUTE7,
 			C_ATTRIBUTE8,
			C_ATTRIBUTE9,
			C_ATTRIBUTE10,
 			C_ATTRIBUTE11,
 			C_ATTRIBUTE12,
			C_ATTRIBUTE13,
			C_ATTRIBUTE14,
 			C_ATTRIBUTE15,
 			C_ATTRIBUTE16,
 			C_ATTRIBUTE17,
			C_ATTRIBUTE18,
			C_ATTRIBUTE19,
 			C_ATTRIBUTE20,
 			D_ATTRIBUTE1,
 			D_ATTRIBUTE2,
 			D_ATTRIBUTE3,
 			D_ATTRIBUTE4,
 			D_ATTRIBUTE5,
 			D_ATTRIBUTE6,
 			D_ATTRIBUTE7,
 			D_ATTRIBUTE8,
 			D_ATTRIBUTE9,
 			D_ATTRIBUTE10,
 			N_ATTRIBUTE1,
 			N_ATTRIBUTE2,
 			N_ATTRIBUTE3,
 			N_ATTRIBUTE4,
 			N_ATTRIBUTE5,
 			N_ATTRIBUTE6,
 			N_ATTRIBUTE7,
 			N_ATTRIBUTE8,
 			N_ATTRIBUTE9,
 			N_ATTRIBUTE10,
			territory_code,
			time_since_new,
			cycles_since_new,
			time_since_overhaul,
			cycles_since_overhaul,
			time_since_repair,
			cycles_since_repair,
			time_since_visit,
			cycles_since_visit,
			time_since_mark,
			cycles_since_mark
	   FROM	wip_lpn_completions_serials
	   WHERE	header_id = l_temp_header_id
	   AND	lot_number is null);

           IF (l_debug = 1) THEN
           mydebug('Backflush: open wip_lpn_comp_serials_csr2 ' );
           END IF;


	   OPEN wip_lpn_comp_serials_csr2;
	   LOOP
	      FETCH
		wip_lpn_comp_serials_csr2
		INTO
		l_fm_serial_number;
	      EXIT when wip_lpn_comp_serials_csr2%NOTFOUND;

	      IF (l_debug = 1) THEN
   	      mydebug('Backflush: serial item');
   	      mydebug('Backflush: ' || l_temp_header_id || '  ' || l_fm_serial_number);
	      END IF;

	      wms_wip_integration.update_serial
		  (p_header_id	        => l_temp_header_id,
		   p_serial_number      => l_fm_serial_number,
		   x_return_status      => l_return_status,
		   x_msg_count          => x_msg_count,
		   x_msg_data           => x_msg_data);


	   END LOOP;
	   CLOSE wip_lpn_comp_serials_csr2;

	   -- Logic for finding which rows will be inserted
	   -- in the mtl_transaction_lots_temp table

           IF (l_debug = 1) THEN
              mydebug('Backflush: Insert into mtl_transaction_lots_temp ');
           END IF;

	   INSERT INTO mtl_transaction_lots_temp
	     (	transaction_temp_id,
		last_update_date,
		last_updated_by,
		creation_date,
			created_by,
			last_update_login,
			request_id,
			program_application_id,
			program_id,
			program_update_date,
			transaction_quantity,
			primary_quantity,
			lot_number,
			lot_expiration_date,
			error_code,
			lot_attribute_category,
			C_ATTRIBUTE1,
 			C_ATTRIBUTE11,
 			C_ATTRIBUTE10,
			C_ATTRIBUTE9,
			C_ATTRIBUTE8,
			C_ATTRIBUTE7,
			C_ATTRIBUTE6,
			C_ATTRIBUTE5,
			C_ATTRIBUTE4,
			C_ATTRIBUTE3,
			C_ATTRIBUTE2,
			description,
			vendor_id,
			grade_code,
			origination_date,
			date_code,
			change_date,
			age,
			retest_date,
			maturity_date,
			item_size,
			color,
			volume,
			volume_uom,
			place_of_origin,
			best_by_date,
			length,
			length_uom,
			recycled_content,
			thickness,
			thickness_uom,
			width,
			width_uom,
			curl_wrinkle_fold,
 			C_ATTRIBUTE12,
 			C_ATTRIBUTE13,
 			C_ATTRIBUTE14,
 			C_ATTRIBUTE15,
 			C_ATTRIBUTE16,
 			C_ATTRIBUTE17,
 			C_ATTRIBUTE18,
 			C_ATTRIBUTE19,
 			C_ATTRIBUTE20,
	 		D_ATTRIBUTE2,
 			D_ATTRIBUTE3,
	 		D_ATTRIBUTE4,
 			D_ATTRIBUTE5,
 			D_ATTRIBUTE6,
 			D_ATTRIBUTE7,
 			D_ATTRIBUTE8,
 			D_ATTRIBUTE9,
 			D_ATTRIBUTE1,
 			N_ATTRIBUTE1,
 			N_ATTRIBUTE2,
 			N_ATTRIBUTE3,
 			N_ATTRIBUTE4,
 			N_ATTRIBUTE5,
 			N_ATTRIBUTE6,
	 		N_ATTRIBUTE7,
 			N_ATTRIBUTE8,
 			N_ATTRIBUTE9,
 			N_ATTRIBUTE10,
 			vendor_name,
 			supplier_lot_number,
			territory_code
		)
		(SELECT	l_next_transaction_temp_id,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login,
			request_id,
			program_application_id,
			program_id,
			program_update_date,
			transaction_quantity,
			primary_quantity,
			lot_number,
			lot_expiration_date,
			error_code,
			lot_attribute_category,
			C_ATTRIBUTE1,
 			C_ATTRIBUTE11,
 			C_ATTRIBUTE10,
			C_ATTRIBUTE9,
			C_ATTRIBUTE8,
			C_ATTRIBUTE7,
			C_ATTRIBUTE6,
			C_ATTRIBUTE5,
			C_ATTRIBUTE4,
			C_ATTRIBUTE3,
			C_ATTRIBUTE2,
			description,
			vendor_id,
			grade_code,
			origination_date,
			date_code,
			change_date,
			age,
			retest_date,
			maturity_date,
			item_size,
			color,
			volume,
			volume_uom,
			place_of_origin,
			best_by_date,
			length,
			length_uom,
			recycled_content,
			thickness,
			thickness_uom,
			width,
			width_uom,
			curl_wrinkle_fold,
 			C_ATTRIBUTE12,
 			C_ATTRIBUTE13,
 			C_ATTRIBUTE14,
 			C_ATTRIBUTE15,
 			C_ATTRIBUTE16,
 			C_ATTRIBUTE17,
 			C_ATTRIBUTE18,
 			C_ATTRIBUTE19,
 			C_ATTRIBUTE20,
	 		D_ATTRIBUTE2,
 			D_ATTRIBUTE3,
	 		D_ATTRIBUTE4,
 			D_ATTRIBUTE5,
 			D_ATTRIBUTE6,
 			D_ATTRIBUTE7,
 			D_ATTRIBUTE8,
 			D_ATTRIBUTE9,
 			D_ATTRIBUTE1,
 			N_ATTRIBUTE1,
 			N_ATTRIBUTE2,
 			N_ATTRIBUTE3,
 			N_ATTRIBUTE4,
 			N_ATTRIBUTE5,
 			N_ATTRIBUTE6,
	 		N_ATTRIBUTE7,
 			N_ATTRIBUTE8,
 			N_ATTRIBUTE9,
 			N_ATTRIBUTE10,
 			vendor_name,
 			supplier_lot_number,
			territory_code
		FROM 	wip_lpn_completions_lots
		WHERE 	header_id = l_temp_header_id);


                IF (l_debug = 1) THEN
                mydebug('Backflush: Loop thru wip_lpn_comp_lots_rec ');
                END IF;

                /* Bug: 2976160 : replaced Select INTO with cursor loop to call
                   wms_wip_integration.insert_lot for each lot in wip_lpn_completions_lots table,
                   for the given header_id. there can be more than one lot . */
                FOR wip_lpn_comp_lots_rec in wip_lpn_comp_lots_csr
                LOOP
                   IF (l_debug = 1) THEN
                   mydebug('Backflush: Loop wip_lpn_comp_lots_rec : call wms_wip_integration.insert_lot');
                   END IF;
                   wms_wip_integration.insert_lot
                     (p_header_id          => l_temp_header_id,
                      p_lot_number         => wip_lpn_comp_lots_rec.lot_number,
                      x_return_status      => l_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data);

                END LOOP;

                IF (l_debug = 1) THEN
                mydebug('Backflush: Loop thru wip_lpn_comp_serials_csr ');
                END IF;

		OPEN wip_lpn_comp_serials_csr;
		LOOP
		   FETCH
		     wip_lpn_comp_serials_csr
		     INTO
		     l_temp2_header_id,
		     l_lot_number,
		     l_fm_serial_number;
		   EXIT when wip_lpn_comp_serials_csr%NOTFOUND;

		   IF (l_debug = 1) THEN
   		   mydebug('Backflush: lot and serial item');
   		   mydebug('Backflush: ' || l_temp2_header_id || '   ' || l_lot_number || '    ' || l_fm_serial_number);
		   END IF;

		   wms_wip_integration.update_serial
		     (p_header_id	   => l_temp2_header_id,
		      p_serial_number      => l_fm_serial_number,
		      x_return_status      => l_return_status,
		      x_msg_count          => x_msg_count,
		      x_msg_data           => x_msg_data);


		   -- FOR LOT and SERIAL controlled items

		   --Get value from sequence for next serial_transaction_temp_id
		   SELECT mtl_material_transactions_s.NEXTVAL
		     INTO l_next_ser_tran_temp_id
		     FROM dual;

		   --Update MTLT line
		   UPDATE	mtl_transaction_lots_temp
		     SET	serial_transaction_temp_id = l_next_ser_tran_temp_id
		     WHERE	lot_number = l_lot_number
		     AND	lot_number is not null;

		     --Insert into MSNT table
		     INSERT	INTO	mtl_serial_numbers_temp
		       (	transaction_temp_id,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date,
				fm_serial_number,
				to_serial_number,
				serial_prefix,
				parent_serial_number,
				error_code,
	--			transaction_quantity,
				serial_attribute_category,
				origination_date,
				C_ATTRIBUTE1,
				C_ATTRIBUTE2,
 				C_ATTRIBUTE3,
	 			C_ATTRIBUTE4,
				C_ATTRIBUTE5,
				C_ATTRIBUTE6,
 				C_ATTRIBUTE7,
	 			C_ATTRIBUTE8,
				C_ATTRIBUTE9,
				C_ATTRIBUTE10,
 				C_ATTRIBUTE11,
	 			C_ATTRIBUTE12,
				C_ATTRIBUTE13,
				C_ATTRIBUTE14,
 				C_ATTRIBUTE15,
	 			C_ATTRIBUTE16,
 				C_ATTRIBUTE17,
				C_ATTRIBUTE18,
				C_ATTRIBUTE19,
	 			C_ATTRIBUTE20,
 				D_ATTRIBUTE1,
 				D_ATTRIBUTE2,
 				D_ATTRIBUTE3,
	 			D_ATTRIBUTE4,
 				D_ATTRIBUTE5,
 				D_ATTRIBUTE6,
 				D_ATTRIBUTE7,
	 			D_ATTRIBUTE8,
 				D_ATTRIBUTE9,
 				D_ATTRIBUTE10,
	 			N_ATTRIBUTE1,
 				N_ATTRIBUTE2,
 				N_ATTRIBUTE3,
 				N_ATTRIBUTE4,
 				N_ATTRIBUTE5,
	 			N_ATTRIBUTE6,
 				N_ATTRIBUTE7,
 				N_ATTRIBUTE8,
 				N_ATTRIBUTE9,
	 			N_ATTRIBUTE10,
				territory_code,
				time_since_new,
				cycles_since_new,
				time_since_overhaul,
				cycles_since_overhaul,
				time_since_repair,
				cycles_since_repair,
				time_since_visit,
				cycles_since_visit,
				time_since_mark,
				cycles_since_mark
			)
			(SELECT	l_next_ser_tran_temp_id,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date,
				fm_serial_number,
				to_serial_number,
				serial_prefix,
				parent_serial_number,
				error_code,
--				transaction_quantity,
				serial_attribute_category,
				origination_date,
				C_ATTRIBUTE1,
				C_ATTRIBUTE2,
 				C_ATTRIBUTE3,
 				C_ATTRIBUTE4,
				C_ATTRIBUTE5,
				C_ATTRIBUTE6,
 				C_ATTRIBUTE7,
 				C_ATTRIBUTE8,
				C_ATTRIBUTE9,
				C_ATTRIBUTE10,
 				C_ATTRIBUTE11,
 				C_ATTRIBUTE12,
				C_ATTRIBUTE13,
				C_ATTRIBUTE14,
 				C_ATTRIBUTE15,
 				C_ATTRIBUTE16,
	 			C_ATTRIBUTE17,
				C_ATTRIBUTE18,
				C_ATTRIBUTE19,
 				C_ATTRIBUTE20,
	 			D_ATTRIBUTE1,
 				D_ATTRIBUTE2,
 				D_ATTRIBUTE3,
 				D_ATTRIBUTE4,
	 			D_ATTRIBUTE5,
 				D_ATTRIBUTE6,
 				D_ATTRIBUTE7,
 				D_ATTRIBUTE8,
	 			D_ATTRIBUTE9,
 				D_ATTRIBUTE10,
 				N_ATTRIBUTE1,
 				N_ATTRIBUTE2,
	 			N_ATTRIBUTE3,
 				N_ATTRIBUTE4,
 				N_ATTRIBUTE5,
 				N_ATTRIBUTE6,
	 			N_ATTRIBUTE7,
 				N_ATTRIBUTE8,
 				N_ATTRIBUTE9,
 				N_ATTRIBUTE10,
				territory_code,
				time_since_new,
				cycles_since_new,
				time_since_overhaul,
				cycles_since_overhaul,
				time_since_repair,
				cycles_since_repair,
				time_since_visit,
				cycles_since_visit,
				time_since_mark,
				cycles_since_mark
			FROM	wip_lpn_completions_serials
			WHERE	header_id = l_temp2_header_id
			AND	lot_number = l_lot_number);

		END LOOP;
		CLOSE wip_lpn_comp_serials_csr;


	END LOOP;
	CLOSE wip_lpn_completions_csr;

	IF (l_debug = 1) THEN
   	mydebug('Backflush: Before calling transaction manager');
	END IF;

	-- Call the txn processor
        l_txn_ret := inv_lpn_trx_pub.process_lpn_trx
          (p_trx_hdr_id => l_next_transaction_header_id,
           p_commit     => fnd_api.g_false,
           p_proc_mode  => 1,
           x_proc_msg   => l_msg_data
          );

      IF (l_debug = 1) THEN
         mydebug('Backflush: After Calling txn proc ' || l_txn_ret);
      END IF;

      --COMMIT;
      IF l_txn_ret<>0 THEN
	 FND_MESSAGE.SET_NAME('WMS','WMS_TD_TXNMGR_ERROR' );
	 FND_MSG_PUB.ADD;

	 l_return_status:=FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      ELSE

         l_return_status:= FND_API.G_RET_STS_SUCCESS;

      END IF;

  ELSE
	-- No rows found in wip_lpn_completions
      l_return_status:=FND_API.G_RET_STS_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
  END IF;

  x_return_status:=l_return_status;

EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
	(p_count  => x_msg_count
	 , p_data   => x_msg_data
	 );

   WHEN OTHERS THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
	(p_count  => x_msg_count
	 , p_data   => x_msg_data
	 );

END Backflush;


PROCEDURE Capture_serial_atts
  (p_ref_id		IN	NUMBER,
   p_temp_id		IN	NUMBER,
   p_last_update_date	IN	DATE,
   p_last_updated_by	IN	NUMBER,
   p_creation_date	IN	DATE,
   p_created_by		IN	NUMBER,
   p_fm_serial_number	IN	VARCHAR2,
   p_to_serial_number	IN	VARCHAR2,
   p_serial_temp_id	IN	NUMBER,
   p_serial_flag	IN	NUMBER)

IS
	l_serial_temp_id	NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	--Insert into MSNT attributes from WIP tables

		IF p_serial_flag = 2 THEN
			l_serial_temp_id := p_serial_temp_id;
		ELSE
			l_serial_temp_id := p_temp_id;
		END IF;

		INSERT	INTO	mtl_serial_numbers_temp
			(	transaction_temp_id,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date,
				fm_serial_number,
				to_serial_number,
				serial_prefix,
				parent_serial_number,
				error_code,
				serial_attribute_category,
				origination_date,
				C_ATTRIBUTE1,
				C_ATTRIBUTE2,
 				C_ATTRIBUTE3,
	 			C_ATTRIBUTE4,
				C_ATTRIBUTE5,
				C_ATTRIBUTE6,
 				C_ATTRIBUTE7,
	 			C_ATTRIBUTE8,
				C_ATTRIBUTE9,
				C_ATTRIBUTE10,
 				C_ATTRIBUTE11,
	 			C_ATTRIBUTE12,
				C_ATTRIBUTE13,
				C_ATTRIBUTE14,
 				C_ATTRIBUTE15,
	 			C_ATTRIBUTE16,
 				C_ATTRIBUTE17,
				C_ATTRIBUTE18,
				C_ATTRIBUTE19,
	 			C_ATTRIBUTE20,
 				D_ATTRIBUTE1,
 				D_ATTRIBUTE2,
 				D_ATTRIBUTE3,
	 			D_ATTRIBUTE4,
 				D_ATTRIBUTE5,
 				D_ATTRIBUTE6,
 				D_ATTRIBUTE7,
	 			D_ATTRIBUTE8,
 				D_ATTRIBUTE9,
 				D_ATTRIBUTE10,
	 			N_ATTRIBUTE1,
 				N_ATTRIBUTE2,
 				N_ATTRIBUTE3,
 				N_ATTRIBUTE4,
 				N_ATTRIBUTE5,
	 			N_ATTRIBUTE6,
 				N_ATTRIBUTE7,
 				N_ATTRIBUTE8,
 				N_ATTRIBUTE9,
	 			N_ATTRIBUTE10,
				territory_code,
				time_since_new,
				cycles_since_new,
				time_since_overhaul,
				cycles_since_overhaul,
				time_since_repair,
				cycles_since_repair,
				time_since_visit,
				cycles_since_visit,
				time_since_mark,
				cycles_since_mark
			)
			(SELECT	l_serial_temp_id,
				p_last_update_date,
				p_last_updated_by,
				p_creation_date,
				p_created_by,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date,
				p_fm_serial_number,
				p_to_serial_number,
				serial_prefix,
				parent_serial_number,
				error_code,
				serial_attribute_category,
				origination_date,
				C_ATTRIBUTE1,
				C_ATTRIBUTE2,
 				C_ATTRIBUTE3,
 				C_ATTRIBUTE4,
				C_ATTRIBUTE5,
				C_ATTRIBUTE6,
 				C_ATTRIBUTE7,
 				C_ATTRIBUTE8,
				C_ATTRIBUTE9,
				C_ATTRIBUTE10,
 				C_ATTRIBUTE11,
 				C_ATTRIBUTE12,
				C_ATTRIBUTE13,
				C_ATTRIBUTE14,
 				C_ATTRIBUTE15,
 				C_ATTRIBUTE16,
	 			C_ATTRIBUTE17,
				C_ATTRIBUTE18,
				C_ATTRIBUTE19,
 				C_ATTRIBUTE20,
	 			D_ATTRIBUTE1,
 				D_ATTRIBUTE2,
 				D_ATTRIBUTE3,
 				D_ATTRIBUTE4,
	 			D_ATTRIBUTE5,
 				D_ATTRIBUTE6,
 				D_ATTRIBUTE7,
 				D_ATTRIBUTE8,
	 			D_ATTRIBUTE9,
 				D_ATTRIBUTE10,
 				N_ATTRIBUTE1,
 				N_ATTRIBUTE2,
	 			N_ATTRIBUTE3,
 				N_ATTRIBUTE4,
 				N_ATTRIBUTE5,
 				N_ATTRIBUTE6,
	 			N_ATTRIBUTE7,
 				N_ATTRIBUTE8,
 				N_ATTRIBUTE9,
 				N_ATTRIBUTE10,
				territory_code,
				time_since_new,
				cycles_since_new,
				time_since_overhaul,
				cycles_since_overhaul,
				time_since_repair,
				cycles_since_repair,
				time_since_visit,
				cycles_since_visit,
				time_since_mark,
				cycles_since_mark
			FROM	wip_lpn_completions_serials
			WHERE	header_id = p_ref_id
			AND	fm_serial_number = p_fm_serial_number);
END Capture_serial_atts;



PROCEDURE Capture_lot_atts
  (p_ref_id		IN	NUMBER,
   p_temp_id		IN	NUMBER,
   p_lot		IN	VARCHAR2)

IS
	c1		VARCHAR2(150);
	c2		VARCHAR2(150);
	c3		VARCHAR2(150);
	c4		VARCHAR2(150);
	c5		VARCHAR2(150);
	c6		VARCHAR2(150);
	c7		VARCHAR2(150);
	c8		VARCHAR2(150);
	c9		VARCHAR2(150);
	c10		VARCHAR2(150);
	c11		VARCHAR2(150);
	c12		VARCHAR2(150);
	c13		VARCHAR2(150);
	c14		VARCHAR2(150);
	c15		VARCHAR2(150);
	c16		VARCHAR2(150);
	c17		VARCHAR2(150);
	c18		VARCHAR2(150);
	c19		VARCHAR2(150);
	c20		VARCHAR2(150);
	d1		DATE;
	d2		DATE;
	d3		DATE;
	d4		DATE;
	d5		DATE;
	d6		DATE;
	d7		DATE;
	d8		DATE;
	d9		DATE;
	n1		NUMBER;
	n2		NUMBER;
	n3		NUMBER;
	n4		NUMBER;
	n5		NUMBER;
	n6		NUMBER;
	n7		NUMBER;
	n8		NUMBER;
	n9		NUMBER;
	n10		NUMBER;
	n11		NUMBER;
	d10		DATE;
	n12		NUMBER;
	d11		DATE;
	n13		NUMBER;
	n14		NUMBER;
	n15		NUMBER;
	n16		NUMBER;
	n17		NUMBER;
	d12		DATE;
	n18		NUMBER;
	d13		DATE;
	v1		VARCHAR2(240);
	v2		VARCHAR2(240);
	n20		NUMBER;
	v4		VARCHAR2(150);
	d14		DATE;
	v5		VARCHAR2(240);
	v6		VARCHAR2(240);
	n21		NUMBER;
	d15		DATE;
	d16		DATE;
	n22		NUMBER;
	v7		VARCHAR2(150);
	n23		NUMBER;
	v8		VARCHAR2(3);
	v9		VARCHAR2(150);
	d17		DATE;
	d18		DATE;
	n24		NUMBER;
	v10		VARCHAR2(3);
	n25		NUMBER;
	n26		NUMBER;
	v11		VARCHAR2(3);
	n27		NUMBER;
	v12		VARCHAR2(3);
	v13		VARCHAR2(150);
	v14		VARCHAR2(240);
	v15		VARCHAR2(150);
	v16		VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

 	--Update MTLT attributes from WIP tables


		SELECT  C_ATTRIBUTE1,
 			C_ATTRIBUTE2,
 			C_ATTRIBUTE3,
			C_ATTRIBUTE4,
			C_ATTRIBUTE5,
			C_ATTRIBUTE6,
			C_ATTRIBUTE7,
			C_ATTRIBUTE8,
			C_ATTRIBUTE9,
			C_ATTRIBUTE10,
			C_ATTRIBUTE11,
 			C_ATTRIBUTE12,
 			C_ATTRIBUTE13,
 			C_ATTRIBUTE14,
 			C_ATTRIBUTE15,
 			C_ATTRIBUTE16,
 			C_ATTRIBUTE17,
 			C_ATTRIBUTE18,
 			C_ATTRIBUTE19,
 			C_ATTRIBUTE20,
 			D_ATTRIBUTE1,
	 		D_ATTRIBUTE2,
 			D_ATTRIBUTE3,
	 		D_ATTRIBUTE4,
 			D_ATTRIBUTE5,
 			D_ATTRIBUTE6,
 			D_ATTRIBUTE7,
 			D_ATTRIBUTE8,
 			D_ATTRIBUTE9,
 			N_ATTRIBUTE1,
 			N_ATTRIBUTE2,
 			N_ATTRIBUTE3,
 			N_ATTRIBUTE4,
 			N_ATTRIBUTE5,
 			N_ATTRIBUTE6,
	 		N_ATTRIBUTE7,
 			N_ATTRIBUTE8,
 			N_ATTRIBUTE9,
 			N_ATTRIBUTE10,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
 			CREATION_DATE,
			CREATED_BY,
 			LAST_UPDATE_LOGIN,
 			REQUEST_ID ,
 			PROGRAM_APPLICATION_ID ,
 			PROGRAM_ID,
 			PROGRAM_UPDATE_DATE,
 			TRANSACTION_QUANTITY,
			LOT_EXPIRATION_DATE,
 			ERROR_CODE,
 			LOT_ATTRIBUTE_CATEGORY,
 			VENDOR_ID,
 			GRADE_CODE ,
 			ORIGINATION_DATE,
 			DATE_CODE,
 			CHANGE_DATE,
 			AGE,
 			RETEST_DATE,
 			MATURITY_DATE,
 			ITEM_SIZE,
 			COLOR,
 			VOLUME,
 			VOLUME_UOM,
 			PLACE_OF_ORIGIN,
 			BEST_BY_DATE,
	 		LENGTH,
	 		LENGTH_UOM,
 			RECYCLED_CONTENT,
	 		THICKNESS,
	 		THICKNESS_UOM,
 			WIDTH,
 			WIDTH_UOM,
 			CURL_WRINKLE_FOLD,
 			VENDOR_NAME,
 			SUPPLIER_LOT_NUMBER,
 			TERRITORY_CODE

		INTO    c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,
			c17,c18,c19,c20,d1,d2,d3,d4,d5,d6,d7,d8,d9,n1,n2,n3,n4,
			n5,n6,n7,n8,n9,n10,
			d10,n12,d11,n13,n14,n15,n16,n17,d12,n18,d13,
			v1,v2,n20,v4,d14,v5,v6,n21,d15,d16,n22,v7,n23,v8,
			v9,d18,n24,v10,n25,n26,v11,n27,v12,v13,v14,
			v15,v16

		FROM	wip_lpn_completions_lots
		WHERE   header_id = p_ref_id
		AND	lot_number = p_lot;



		UPDATE mtl_transaction_lots_temp
	   	SET 	C_ATTRIBUTE1 = c1,
 			C_ATTRIBUTE2 = c2,
 			C_ATTRIBUTE3 = c3,
			C_ATTRIBUTE4 = c4,
			C_ATTRIBUTE5 = c5,
			C_ATTRIBUTE6 = c6,
			C_ATTRIBUTE7 = c7,
			C_ATTRIBUTE8 = c8,
			C_ATTRIBUTE9 = c9,
			C_ATTRIBUTE10 = c10,
			C_ATTRIBUTE11 = c11,
 			C_ATTRIBUTE12 = c12,
 			C_ATTRIBUTE13 = c13,
 			C_ATTRIBUTE14 = c14,
 			C_ATTRIBUTE15 = c15,
 			C_ATTRIBUTE16 = c16,
 			C_ATTRIBUTE17 = c17,
 			C_ATTRIBUTE18 = c18,
 			C_ATTRIBUTE19 = c19,
 			C_ATTRIBUTE20 = c20,
 			D_ATTRIBUTE1 = d1,
	 		D_ATTRIBUTE2 = d2,
 			D_ATTRIBUTE3 = d3,
	 		D_ATTRIBUTE4 = d4,
 			D_ATTRIBUTE5 = d5,
 			D_ATTRIBUTE6 = d6,
 			D_ATTRIBUTE7 = d7,
 			D_ATTRIBUTE8 = d8,
 			D_ATTRIBUTE9 = d9,
 			N_ATTRIBUTE1 = n1,
 			N_ATTRIBUTE2 = n2,
 			N_ATTRIBUTE3 = n3,
 			N_ATTRIBUTE4 = n4,
 			N_ATTRIBUTE5 = n5,
 			N_ATTRIBUTE6 = n6,
	 		N_ATTRIBUTE7 = n7,
 			N_ATTRIBUTE8 = n8,
 			N_ATTRIBUTE9 = n9,
 			N_ATTRIBUTE10 = n10,
			LAST_UPDATE_DATE = d10,
			LAST_UPDATED_BY=n12,
 			CREATION_DATE=d11,
			CREATED_BY=n13,
 			LAST_UPDATE_LOGIN=n14,
 			REQUEST_ID =n15,
 			PROGRAM_APPLICATION_ID =n16,
 			PROGRAM_ID=n17,
		        PROGRAM_UPDATE_DATE=d12,
		        -- bug 2748242
 			--TRANSACTION_QUANTITY=n18,
			LOT_EXPIRATION_DATE=d13,
 			ERROR_CODE=v1,
 			LOT_ATTRIBUTE_CATEGORY=v2,
 			VENDOR_ID=n20,
 			GRADE_CODE =v4,
 			ORIGINATION_DATE=d14,
 			DATE_CODE=v5,
 			CHANGE_DATE=v6,
 			AGE=n21,
 			RETEST_DATE=d15,
 			MATURITY_DATE=d16,
 			ITEM_SIZE=n22,
 			COLOR=v7,
 			VOLUME=n23,
 			VOLUME_UOM=v8,
 			PLACE_OF_ORIGIN=v9,
 			BEST_BY_DATE=d18,
	 		LENGTH=n24,
	 		LENGTH_UOM=v10,
 			RECYCLED_CONTENT=n25,
	 		THICKNESS=n26,
	 		THICKNESS_UOM=v11,
 			WIDTH=n27,
 			WIDTH_UOM=v12,
 			CURL_WRINKLE_FOLD=v13,
 			VENDOR_NAME=v14,
 			SUPPLIER_LOT_NUMBER=v15,
 			TERRITORY_CODE=v16
	   	WHERE transaction_temp_id=p_temp_id
	   	AND lot_number=p_lot;


END Capture_lot_atts;



PROCEDURE Update_serial
( p_header_id      IN   NUMBER
, p_serial_number  IN   VARCHAR2
, x_return_status  OUT  NOCOPY VARCHAR2
, x_msg_count      OUT  NOCOPY NUMBER
, x_msg_data       OUT  NOCOPY VARCHAR2
)

IS
    v1    VARCHAR2(30);
    v2    VARCHAR2(30);
    v3    VARCHAR2(30);
    v4    VARCHAR2(150);
    v5    VARCHAR2(30);
    v6    VARCHAR2(150);
    v7    VARCHAR2(150);
    v8    VARCHAR2(150);
    v9    VARCHAR2(150);
    v10   VARCHAR2(150);
    v11   VARCHAR2(150);
    v12   VARCHAR2(150);
    v13   VARCHAR2(150);
    v14   VARCHAR2(150);
    v15   VARCHAR2(150);
    v16   VARCHAR2(150);
    v17   VARCHAR2(150);
    v18   VARCHAR2(150);
    v19   VARCHAR2(150);
    v20   VARCHAR2(150);
    v21   VARCHAR2(150);
    v22   VARCHAR2(150);
    v23   VARCHAR2(150);
    v24   VARCHAR2(150);
    v25   VARCHAR2(30);
    d1    DATE;
    d2    DATE;
    d3    DATE;
    d4    DATE;
    d5    DATE;
    d6    DATE;
    d7    DATE;
    d8    DATE;
    d9    DATE;
    d10   DATE;
    d11   DATE;
    d12   DATE;
    d13   DATE;
    d14   DATE;
    n1    NUMBER;
    n2    NUMBER;
    n3    NUMBER;
    n4    NUMBER;
    n5    NUMBER;
    n6    NUMBER;
    n7    NUMBER;
    n8    NUMBER;
    n9    NUMBER;
    n10   NUMBER;
    n11   NUMBER;
    n12   NUMBER;
    n13   NUMBER;
    n14   NUMBER;
    n15   NUMBER;
    n16   NUMBER;
    n17   NUMBER;
    n18   NUMBER;
    n19   NUMBER;
    n20   NUMBER;
    n21   NUMBER;
    n22   NUMBER;
    n23   NUMBER;
    n24   NUMBER;
    n25   NUMBER;
    n26   NUMBER;
    n27   NUMBER;

    l_item_id        NUMBER;
    l_return_status  VARCHAR2(1);
    l_object_id      NUMBER;

    l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT  inventory_item_id
      INTO  l_item_id
      FROM  wip_lpn_completions
     WHERE  header_id = p_header_id;

    SELECT
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     REQUEST_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     FM_SERIAL_NUMBER,
     PARENT_SERIAL_NUMBER,
     LOT_NUMBER,
     C_ATTRIBUTE1,
     SERIAL_ATTRIBUTE_CATEGORY,
     ORIGINATION_DATE,
     C_ATTRIBUTE2,
     C_ATTRIBUTE3,
     C_ATTRIBUTE4,
     C_ATTRIBUTE5,
     C_ATTRIBUTE6,
     C_ATTRIBUTE7,
     C_ATTRIBUTE8,
     C_ATTRIBUTE9,
     C_ATTRIBUTE10,
     C_ATTRIBUTE11,
     C_ATTRIBUTE12,
     C_ATTRIBUTE13,
     C_ATTRIBUTE14,
     C_ATTRIBUTE15,
     C_ATTRIBUTE16,
     C_ATTRIBUTE17,
     C_ATTRIBUTE18,
     C_ATTRIBUTE19,
     C_ATTRIBUTE20,
     D_ATTRIBUTE1,
     D_ATTRIBUTE2,
     D_ATTRIBUTE3,
     D_ATTRIBUTE4,
     D_ATTRIBUTE5,
     D_ATTRIBUTE6,
     D_ATTRIBUTE7,
     D_ATTRIBUTE8,
     D_ATTRIBUTE9,
     D_ATTRIBUTE10,
     N_ATTRIBUTE1,
     N_ATTRIBUTE2,
     N_ATTRIBUTE3,
     N_ATTRIBUTE4,
     N_ATTRIBUTE5,
     N_ATTRIBUTE6,
     N_ATTRIBUTE7,
     N_ATTRIBUTE8,
     N_ATTRIBUTE9,
     N_ATTRIBUTE10,
     TERRITORY_CODE,
     TIME_SINCE_NEW,
     CYCLES_SINCE_NEW,
     TIME_SINCE_OVERHAUL,
     CYCLES_SINCE_OVERHAUL,
     TIME_SINCE_REPAIR,
     CYCLES_SINCE_REPAIR,
     TIME_SINCE_VISIT,
     CYCLES_SINCE_VISIT,
     TIME_SINCE_MARK,
     CYCLES_SINCE_MARK,
     STATUS_ID

    INTO    d1,n1,d2,n2,n3,n4,n5,n6,d3,v1,v2,v3,v4,v5,d4,
            v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,v21,
            v22,v23,v24,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,
            n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,v25,n17,n18,n19,
            n20,n21,n22,n23,n24,n25,n26,n27

    FROM wip_lpn_completions_serials
    WHERE fm_serial_number = p_serial_number
    AND header_id = p_header_id;

    select gen_object_id
    into l_object_id
    From  mtl_serial_numbers
    where serial_number = p_serial_number
    and inventory_item_id = l_item_id;

    if( l_object_id is null ) then
       select mtl_gen_object_id_s.nextval into l_object_id from dual;
    end if;

    UPDATE mtl_serial_numbers
    SET
     LAST_UPDATE_DATE=d1,
     LAST_UPDATED_BY=n1,
     CREATION_DATE=d2,
     CREATED_BY=n2,
     LAST_UPDATE_LOGIN=n3,
     REQUEST_ID=n4,
     PROGRAM_APPLICATION_ID=n5,
     PROGRAM_ID=n6,
     PROGRAM_UPDATE_DATE=d3,
     PARENT_SERIAL_NUMBER=v2,
     LOT_NUMBER=v3,
     C_ATTRIBUTE1=v4,
     SERIAL_ATTRIBUTE_CATEGORY=v5,
     ORIGINATION_DATE=d4,
     C_ATTRIBUTE2=v6,
     C_ATTRIBUTE3=v7,
     C_ATTRIBUTE4=v8,
     C_ATTRIBUTE5=v9,
     C_ATTRIBUTE6=v10,
     C_ATTRIBUTE7=v11,
     C_ATTRIBUTE8=v12,
     C_ATTRIBUTE9=v13,
     C_ATTRIBUTE10=v14,
     C_ATTRIBUTE11=v15,
     C_ATTRIBUTE12=v16,
     C_ATTRIBUTE13=v17,
     C_ATTRIBUTE14=v18,
     C_ATTRIBUTE15=v19,
     C_ATTRIBUTE16=v20,
     C_ATTRIBUTE17=v21,
     C_ATTRIBUTE18=v22,
     C_ATTRIBUTE19=v23,
     C_ATTRIBUTE20=v24,
     D_ATTRIBUTE1=d5,
     D_ATTRIBUTE2=d6,
     D_ATTRIBUTE3=d7,
     D_ATTRIBUTE4=d8,
     D_ATTRIBUTE5=d9,
     D_ATTRIBUTE6=d10,
     D_ATTRIBUTE7=d11,
     D_ATTRIBUTE8=d12,
     D_ATTRIBUTE9=d13,
     D_ATTRIBUTE10=d14,
     N_ATTRIBUTE1=n7,
     N_ATTRIBUTE2=n8,
     N_ATTRIBUTE3=n9,
     N_ATTRIBUTE4=n10,
     N_ATTRIBUTE5=n11,
     N_ATTRIBUTE6=n12,
     N_ATTRIBUTE7=n13,
     N_ATTRIBUTE8=n14,
     N_ATTRIBUTE9=n15,
     N_ATTRIBUTE10=n16,
     TERRITORY_CODE=v25,
     TIME_SINCE_NEW=n17,
     CYCLES_SINCE_NEW=n18,
     TIME_SINCE_OVERHAUL=n19,
     CYCLES_SINCE_OVERHAUL=n20,
     TIME_SINCE_REPAIR=n21,
     CYCLES_SINCE_REPAIR=n22,
     TIME_SINCE_VISIT=n23,
     CYCLES_SINCE_VISIT=n24,
     TIME_SINCE_MARK=n25,
     CYCLES_SINCE_MARK=n26,
     GEN_OBJECT_ID = l_object_id,
     STATUS_ID     = n27
    WHERE serial_number     = p_serial_number
      AND inventory_item_id = l_item_id;

    x_return_status := l_return_status;
EXCEPTION
    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF (l_debug = 1) THEN
            mydebug('Update_serial: Unexpected error: ' || sqlcode || ' :: ' || sqlerrm);
         END IF;

END Update_serial;


PROCEDURE Insert_lot
( p_header_id		            IN NUMBER,
  p_lot_number                      IN VARCHAR2,
  x_return_status                        OUT   NOCOPY VARCHAR2,
  x_msg_count                            OUT   NOCOPY NUMBER,
  x_msg_data                             OUT   NOCOPY VARCHAR2)

IS

	l_item_id	NUMBER;
	l_org_id	NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
	l_lot_number	VARCHAR2(80);
	l_return_status	VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
	l_msg_count	NUMBER;
	l_msg_data	VARCHAR2(2000);
	l_object_id     NUMBER;
	l_status_rec    inv_material_status_pub.mtl_status_update_rec_type; --bug4073725
        l_status_id  NUMBER;--bug4073725

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

        l_return_status := FND_API.G_RET_STS_SUCCESS;

	l_lot_number := p_lot_number;

	SELECT  inventory_item_id,organization_id
	INTO	l_item_id,l_org_id
	FROM wip_lpn_completions
	WHERE header_id = p_header_id;

	WMS_WIP_Integration.perform_lot_validations
	  (p_item_id       => l_item_id,
	   p_org_id        => l_org_id,
	   p_lot_number    => l_lot_number,
	   x_return_status => l_return_status,
	   x_msg_count     => l_msg_count,
	   x_msg_data      => l_msg_data);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN

		-- Lot number does not exist
	   select mtl_gen_object_id_s.nextval into l_object_id from dual;

		INSERT INTO mtl_lot_numbers
		(INVENTORY_ITEM_ID
	 	 ,ORGANIZATION_ID
		 ,LOT_NUMBER
		 ,LAST_UPDATE_DATE
		 ,LAST_UPDATED_BY
		 ,CREATION_DATE
		 ,CREATED_BY
		 ,LAST_UPDATE_LOGIN
		 ,EXPIRATION_DATE
		 ,REQUEST_ID
		 ,PROGRAM_APPLICATION_ID
		 ,PROGRAM_ID
		 ,PROGRAM_UPDATE_DATE
		 ,DESCRIPTION
		 ,VENDOR_ID
		 ,GRADE_CODE
		 ,ORIGINATION_DATE
		 ,DATE_CODE
		 ,CHANGE_DATE
		 ,AGE
		 ,RETEST_DATE
		 ,MATURITY_DATE
		 ,LOT_ATTRIBUTE_CATEGORY
		 ,ITEM_SIZE
		 ,COLOR
		 ,VOLUME
		 ,VOLUME_UOM
		 ,PLACE_OF_ORIGIN
		 ,BEST_BY_DATE
		 ,LENGTH
		 ,LENGTH_UOM
		 ,RECYCLED_CONTENT
		 ,THICKNESS
		 ,THICKNESS_UOM
		 ,WIDTH
		 ,WIDTH_UOM
		 ,CURL_WRINKLE_FOLD
		 ,C_ATTRIBUTE1
		 ,C_ATTRIBUTE2
		 ,C_ATTRIBUTE3
		 ,C_ATTRIBUTE4
		 ,C_ATTRIBUTE5
		 ,C_ATTRIBUTE6
		 ,C_ATTRIBUTE7
		 ,C_ATTRIBUTE8
		 ,C_ATTRIBUTE9
		 ,C_ATTRIBUTE10
		 ,C_ATTRIBUTE11
		 ,C_ATTRIBUTE12
		 ,C_ATTRIBUTE13
		 ,C_ATTRIBUTE14
		 ,C_ATTRIBUTE15
		 ,C_ATTRIBUTE16
		 ,C_ATTRIBUTE17
		 ,C_ATTRIBUTE18
		 ,C_ATTRIBUTE19
		 ,C_ATTRIBUTE20
		 ,D_ATTRIBUTE1
		 ,D_ATTRIBUTE2
		 ,D_ATTRIBUTE3
		 ,D_ATTRIBUTE4
		 ,D_ATTRIBUTE5
		 ,D_ATTRIBUTE6
		 ,D_ATTRIBUTE7
		 ,D_ATTRIBUTE8
		 ,D_ATTRIBUTE9
		 ,D_ATTRIBUTE10
		 ,N_ATTRIBUTE1
		 ,N_ATTRIBUTE2
		 ,N_ATTRIBUTE3
		 ,N_ATTRIBUTE4
		 ,N_ATTRIBUTE5
		 ,N_ATTRIBUTE6
		 ,N_ATTRIBUTE7
		 ,N_ATTRIBUTE8
		 ,N_ATTRIBUTE10
		 ,VENDOR_NAME
		 ,SUPPLIER_LOT_NUMBER
		 ,N_ATTRIBUTE9
		 ,TERRITORY_CODE
                 ,GEN_OBJECT_ID
		 ,STATUS_ID
		)
		(SELECT
		  l_item_id
	 	 ,l_org_id
		 ,p_lot_number
		 ,LAST_UPDATE_DATE
		 ,LAST_UPDATED_BY
		 ,CREATION_DATE
		 ,CREATED_BY
		 ,LAST_UPDATE_LOGIN
		 ,LOT_EXPIRATION_DATE
		 ,REQUEST_ID
	 	 ,PROGRAM_APPLICATION_ID
	    	 ,PROGRAM_ID
		 ,PROGRAM_UPDATE_DATE
		 ,DESCRIPTION
	 	 ,VENDOR_ID
		 ,GRADE_CODE
		 ,ORIGINATION_DATE
		 ,DATE_CODE
		 ,CHANGE_DATE
	 	 ,AGE
	       	 ,RETEST_DATE
		 ,MATURITY_DATE
		 ,LOT_ATTRIBUTE_CATEGORY
		 ,ITEM_SIZE
		 ,COLOR
		 ,VOLUME
		 ,VOLUME_UOM
		 ,PLACE_OF_ORIGIN
		 ,BEST_BY_DATE
		 ,LENGTH
		 ,LENGTH_UOM
		 ,RECYCLED_CONTENT
		 ,THICKNESS
		 ,THICKNESS_UOM
		 ,WIDTH
		 ,WIDTH_UOM
		 ,CURL_WRINKLE_FOLD
		 ,C_ATTRIBUTE1
		 ,C_ATTRIBUTE2
		 ,C_ATTRIBUTE3
		 ,C_ATTRIBUTE4
		 ,C_ATTRIBUTE5
		 ,C_ATTRIBUTE6
		 ,C_ATTRIBUTE7
		 ,C_ATTRIBUTE8
		 ,C_ATTRIBUTE9
		 ,C_ATTRIBUTE10
		 ,C_ATTRIBUTE11
		 ,C_ATTRIBUTE12
		 ,C_ATTRIBUTE13
		 ,C_ATTRIBUTE14
		 ,C_ATTRIBUTE15
		 ,C_ATTRIBUTE16
		 ,C_ATTRIBUTE17
		 ,C_ATTRIBUTE18
		 ,C_ATTRIBUTE19
		 ,C_ATTRIBUTE20
		 ,D_ATTRIBUTE1
		 ,D_ATTRIBUTE2
		 ,D_ATTRIBUTE3
		 ,D_ATTRIBUTE4
		 ,D_ATTRIBUTE5
		 ,D_ATTRIBUTE6
		 ,D_ATTRIBUTE7
		 ,D_ATTRIBUTE8
		 ,D_ATTRIBUTE9
		 ,D_ATTRIBUTE10
		 ,N_ATTRIBUTE1
		 ,N_ATTRIBUTE2
		 ,N_ATTRIBUTE3
		 ,N_ATTRIBUTE4
		 ,N_ATTRIBUTE5
		 ,N_ATTRIBUTE6
		 ,N_ATTRIBUTE7
		 ,N_ATTRIBUTE8
		 ,N_ATTRIBUTE10
		 ,VENDOR_NAME
		 ,SUPPLIER_LOT_NUMBER
		 ,N_ATTRIBUTE9
		  ,territory_code
		  ,l_object_id
		  ,status_id
		FROM wip_lpn_completions_lots
		WHERE header_id = p_header_id
		AND lot_number = p_lot_number
		);

           	l_return_status := FND_API.G_RET_STS_SUCCESS;
	END IF;
	/* bug4073725 changes start */
	IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        	SELECT status_id
        	INTO l_status_id
        	FROM wip_lpn_completions_lots
    		WHERE header_id = p_header_id
    		AND lot_number = p_lot_number;
	        IF ( l_status_id IS NOT NULL ) THEN
                    l_status_rec.update_method := inv_material_status_pub.g_update_method_auto;
                    l_status_rec.organization_id := l_org_id;
                    l_status_rec.inventory_item_id := l_item_id;
                    l_status_rec.lot_number := p_lot_number;
                    l_status_rec.status_id := l_status_id;
                    l_status_rec.initial_status_flag := 'Y';
                    l_status_rec.from_mobile_apps_flag := 'Y';
                    inv_material_status_pkg.insert_status_history ( l_status_rec);
        	END IF;
        END IF;
	/* bug4073725 changes end */

	x_return_status := l_return_status;

END Insert_lot;


PROCEDURE Perform_lot_validations(
	p_item_id	IN NUMBER,
	p_org_id	IN NUMBER,
	p_lot_number	IN VARCHAR2,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count	OUT   NOCOPY NUMBER,
	x_msg_data	OUT   NOCOPY VARCHAR2)

IS
	l_item_id	NUMBER;
	l_org_id	NUMBER;
	l_count		NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
	l_lot_number	VARCHAR2(80);
	l_lotunique	NUMBER;
	l_lot_control_code	NUMBER;
	l_return_status		VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
	l_shelf_life_code NUMBER;
	l_expiration_date	DATE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

        l_return_status := FND_API.G_RET_STS_SUCCESS;

	l_item_id:=p_item_id;
	l_org_id:=p_org_id;
	l_lot_number:=p_lot_number;

	l_count:=0;

     	BEGIN
        	SELECT lot_control_code, shelf_life_code
          	INTO   l_lot_control_code, l_shelf_life_code
          	FROM   mtl_system_items
         	WHERE  inventory_item_id = l_item_id
        	AND    organization_id = l_org_id;

		IF l_lot_control_code = 1 THEN
	   		fnd_message.set_name('INV','INV_NO_LOT_CONTROL');
	   		fnd_msg_pub.add;
	           	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        	END IF;

     	EXCEPTION
        	WHEN NO_DATA_FOUND THEN
           		fnd_message.set_name('INV','INV_INVALID_ITEM');
           		fnd_msg_pub.add;
	           	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	END;


     	SELECT lot_number_uniqueness
       	INTO l_lotunique
       	FROM mtl_parameters
      	WHERE organization_id = l_org_id;

     	IF l_lotunique = 1 then
        	SELECT count(1)
          	INTO l_count
          	FROM MTL_LOT_NUMBERS
         	WHERE inventory_item_id <> l_item_id
           	AND lot_number = p_lot_number
		AND NOT EXISTS( SELECT NULL
				FROM   mtl_lot_numbers lot
				WHERE  lot.lot_number = p_lot_number
				AND    lot.organization_id = l_org_id
				AND    lot.inventory_item_id = l_item_id);

        	IF l_count > 0 then
           		fnd_message.set_name('INV','INV_INT_LOTUNIQEXP');
           		fnd_msg_pub.add;
	           	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        	END IF;
     	END IF;

     	l_count := 0;


	SELECT COUNT(1)
	INTO l_count
	FROM mtl_lot_numbers
	WHERE inventory_item_id = l_item_id
	AND organization_id = l_org_id
	AND lot_number = p_lot_number;

	-- Lot exists or not
	IF l_count = 1 THEN

	 	fnd_message.set_name('INV','INV_LOT_EXISTS');
	        fnd_msg_pub.add;

		SELECT expiration_date
		INTO l_expiration_date
		FROM mtl_lot_numbers
		WHERE inventory_item_id = l_item_id
		AND organization_id = l_org_id
		AND lot_number = p_lot_number;


        	IF l_shelf_life_code = 4 AND l_expiration_date < SYSDATE THEN
	      		fnd_message.set_name('INV','INV_LOT_EXPREQD');
	      		fnd_msg_pub.add;
              		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		ELSE
			l_return_status := FND_API.G_RET_STS_SUCCESS;
        	END IF;

	ELSE
		l_return_status:=FND_API.G_RET_STS_ERROR;
	END IF;

	x_return_status := l_return_status;

EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

   WHEN OTHERS THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

END Perform_lot_validations;


PROCEDURE post_completion
  (p_item_id            IN  NUMBER,
   p_org_id             IN  NUMBER,
   p_fm_serial_number   IN  VARCHAR2,
   p_to_serial_number   IN  VARCHAR2,
   p_quantity           IN  NUMBER,
   x_return_status	OUT NOCOPY VARCHAR2,
   x_msg_count	        OUT NOCOPY NUMBER,
   x_msg_data	        OUT NOCOPY VARCHAR2
   )
  IS

     l_current_number        NUMBER;
     l_current_serial_number VARCHAR2(30);
     l_prefix                VARCHAR2(30);
     l_quantity              NUMBER;
     l_fm_number             NUMBER;
     l_to_number             NUMBER;
     l_errorcode             NUMBER;
     l_padded_length         NUMBER;
     l_length                NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      mydebug('post_completion: procedure post_completion begins');
   END IF;

   x_return_status :=FND_API.g_ret_sts_success;
   l_quantity := p_quantity;

   /* Call this API to parse the serial numbers into prefixes and numbers */
   IF (NOT MTL_Serial_Check.inv_serial_info
       (p_from_serial_number  =>  p_fm_serial_number,
	p_to_serial_number    =>  p_to_serial_number,
	x_prefix              =>  l_prefix,
	x_quantity            =>  l_quantity,
	x_from_number         =>  l_fm_number,
	x_to_number           =>  l_to_number,
	x_errorcode           =>  l_errorcode)) THEN

      IF (l_debug = 1) THEN
         mydebug('post_completion: Invalid serial number given in range');
      END IF;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SER');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check that in the case of a range of serial numbers, that the
   -- inputted p_quantity equals the amount of items in the serial range.
   IF (p_quantity IS NOT NULL) THEN
      IF (p_quantity <> l_quantity) THEN
	 IF (l_debug = 1) THEN
   	 mydebug('post_completion: Range of serial numbers does not match given qty');
	 END IF;
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_X_QTY');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   l_length := length(p_fm_serial_number);
   l_current_serial_number := p_fm_serial_number;
   l_current_number := l_fm_number;
   LOOP

      IF (l_debug = 1) THEN
         mydebug('post_completion: serial_number: ' || l_current_serial_number);
      END IF;

      UPDATE mtl_serial_numbers
	SET
	group_mark_id = NULL,
	current_status = 5
	WHERE current_organization_id = p_org_id
	AND   inventory_item_id = p_item_id
	AND   serial_number = l_current_serial_number;

      EXIT WHEN l_current_serial_number = p_to_serial_number;

      /* Increment the current serial number */
      l_current_number := l_current_number + 1;
      l_padded_length := l_length - length(l_current_number);
      l_current_serial_number := RPAD(l_prefix, l_padded_length, '0') ||
	l_current_number;
   END LOOP;

   IF (l_debug = 1) THEN
      mydebug('post_completion: procedure post_completion ends');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

   WHEN OTHERS THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

END post_completion;


PROCEDURE get_wip_job_info
  (p_temp_id            IN  NUMBER,
   p_wip_entity_type    IN  NUMBER,
   x_job                OUT NOCOPY VARCHAR2,
   x_line               OUT NOCOPY VARCHAR2,
   x_dept               OUT NOCOPY VARCHAR2,
   x_operation_seq_num  OUT NOCOPY NUMBER,
   x_start_date         OUT NOCOPY DATE,
   x_schedule           OUT NOCOPY VARCHAR2,
   x_assembly           OUT NOCOPY VARCHAR2,
   x_return_status	OUT NOCOPY VARCHAR2,
   x_msg_count	        OUT NOCOPY NUMBER,
   x_msg_data	        OUT NOCOPY VARCHAR2
   )
  IS


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      mydebug('get_wip_job_info: get_wip_job_info begins');
   END IF;
   x_return_status :=FND_API.g_ret_sts_success;

   IF p_wip_entity_type IN (1,5,6) THEN --Included 6 also for eAM-WMS Enhancement (Bug# 4093921)

      -- Discrete job or lot based job

	SELECT
	we.wip_entity_name,
	wl.line_code,
	bd.department_code,
	wro.operation_seq_num

	INTO
	x_job,
	x_line,
	x_dept,
	x_operation_seq_num

	FROM
	wip_entities                    we,
	wip_lines                       wl,
	bom_departments                 bd,
	wip_requirement_operations      wro,
	wip_discrete_jobs               wdj,
        mtl_txn_request_lines           mtrl,
	mtl_material_transactions_temp  mmtt
	WHERE we.wip_entity_id         = wdj.wip_entity_id
	  AND we.organization_id       = wdj.organization_id
	  AND wl.line_id           (+) = wdj.line_id
	  AND wl.organization_id   (+) = wdj.organization_id
	  AND bd.department_id     (+) = wro.department_id
	  AND wro.wip_entity_id        = wdj.wip_entity_id
	  AND wro.organization_id      = wdj.organization_id
	  AND wro.operation_seq_num    = mtrl.txn_source_line_id
          AND wro.inventory_item_id    = mtrl.inventory_item_id
	  AND wdj.wip_entity_id        = mtrl.txn_source_id
	  AND wdj.organization_id      = mtrl.organization_id
	  AND mtrl.line_id             = mmtt.move_order_line_id
	  AND mmtt.transaction_temp_id = p_temp_id;

    ELSIF p_wip_entity_type = 2 THEN

      -- Repetitive schedule


      SELECT
	wl.line_code,
	bd.department_code,
	wro.operation_seq_num,
	msik.concatenated_segments,
	wrs.first_unit_start_date

	INTO
	x_line,
	x_dept,
	x_operation_seq_num,
	x_assembly,
	x_start_date

	FROM
	wip_lines                       wl,
	bom_departments                 bd,
	wip_requirement_operations      wro,
	wip_repetitive_schedules        wrs,
	mtl_txn_request_lines           mtrl,
	mtl_material_transactions_temp  mmtt,
	mtl_system_items_kfv            msik,
	wip_entities                    we
	WHERE msik.inventory_item_id   = we.primary_item_id
	AND msik.organization_id       = we.organization_id
	AND we.wip_entity_id           = wrs.wip_entity_id
	AND we.organization_id         = wrs.organization_id
	AND wl.line_id                 = wrs.line_id
	AND wl.organization_id         = wrs.organization_id
	AND bd.department_id       (+) = wro.department_id
	AND wro.wip_entity_id          = wrs.wip_entity_id
	AND wro.repetitive_schedule_id = wrs.repetitive_schedule_id
	AND wro.organization_id        = wrs.organization_id
	AND wro.operation_seq_num      = mtrl.txn_source_line_id
        AND wro.inventory_item_id      = mtrl.inventory_item_id
	AND wrs.wip_entity_id          = mtrl.txn_source_id
	AND wrs.repetitive_schedule_id = mtrl.reference_id
	AND wrs.organization_id        = mtrl.organization_id
	AND mtrl.line_id               = mmtt.move_order_line_id
	AND mmtt.transaction_temp_id   = p_temp_id;


    ELSIF p_wip_entity_type = 4 THEN

      -- Flow schedule

      SELECT
	we.wip_entity_name,
	wl.line_code,
	bd.department_code,
	mtrl.txn_source_line_id

	INTO
	x_schedule,
	x_line,
	x_dept,
	x_operation_seq_num

	FROM
	wip_entities                    we,
	wip_lines                       wl,
	bom_departments                 bd,
	bom_operation_sequences         bos,
	bom_operational_routings        bor,
	wip_flow_schedules              wfs,
	mtl_txn_request_lines           mtrl,
	mtl_material_transactions_temp  mmtt
	WHERE we.wip_entity_id       = wfs.wip_entity_id
	AND we.organization_id       = wfs.organization_id
	AND wl.line_id               = wfs.line_id
	AND wl.organization_id       = wfs.organization_id
	AND bd.department_id         = bos.department_id
	AND bos.routing_sequence_id  = bor.routing_sequence_id
	AND bos.operation_type       = 1
	AND bos.effectivity_date    >= sysdate
	AND ( wfs.alternate_routing_designator = bor.alternate_routing_designator
	     OR (wfs.alternate_routing_designator IS NULL
		 AND bor.alternate_routing_designator IS NULL) )
	AND bor.assembly_item_id     = wfs.primary_item_id
	AND bor.organization_id      = wfs.organization_id
	AND wfs.wip_entity_id        = mtrl.txn_source_id
	AND wfs.organization_id      = mtrl.organization_id
	AND mtrl.line_id             = mmtt.move_order_line_id
	AND mmtt.transaction_temp_id = p_temp_id;

   END IF;

   IF (l_debug = 1) THEN
      mydebug('get_wip_job_info: x_job: ' || x_job);
      mydebug('get_wip_job_info: x_line: ' || x_line);
      mydebug('get_wip_job_info: x_dept: ' || x_dept);
      mydebug('get_wip_job_info: x_operation_seq_num: ' || x_operation_seq_num);
      mydebug('get_wip_job_info: x_start_date: ' || x_start_date);
      mydebug('get_wip_job_info: x_schedule: ' || x_schedule);
      mydebug('get_wip_job_info: x_assembly: ' || x_assembly);
   END IF;

   IF (l_debug = 1) THEN
      mydebug('get_wip_job_info: Get_wip_job_info ends');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

   WHEN OTHERS THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

END get_wip_job_info;



PROCEDURE get_wip_info_for_putaway
  (p_temp_id            IN  NUMBER,
   x_wip_entity_type    OUT NOCOPY NUMBER,
   x_job                OUT NOCOPY VARCHAR2,
   x_line               OUT NOCOPY VARCHAR2,
   x_dept               OUT NOCOPY VARCHAR2,
   x_operation_seq_num  OUT NOCOPY NUMBER,
   x_start_date         OUT NOCOPY DATE,
   x_schedule           OUT NOCOPY VARCHAR2,
   x_assembly           OUT NOCOPY VARCHAR2,
   x_wip_entity_id      OUT NOCOPY NUMBER,
   x_return_status	OUT NOCOPY VARCHAR2,
   x_msg_count	        OUT NOCOPY NUMBER,
   x_msg_data	        OUT NOCOPY VARCHAR2
   )

  IS

     l_wip_entity_type NUMBER;
     l_org_id          NUMBER;
     l_wip_entity_id   NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      mydebug('get_wip_info_for_putaway: get_wip_info_for_putaway begins');
   END IF;
   x_return_status :=FND_API.g_ret_sts_success;

   x_wip_entity_type    :=NULL;
   x_job                :=NULL;
   x_line               :=NULL;
   x_dept               :=NULL;
   x_operation_seq_num  :=NULL;
   x_start_date         :=NULL;
   x_schedule           :=NULL;
   x_assembly           :=NULL;
   x_wip_entity_id      :=NULL;




   SELECT  demand_source_header_id, organization_id
     INTO  l_wip_entity_id, l_org_id
     FROM  mtl_material_transactions_temp
     WHERE transaction_temp_id = p_temp_id;

    x_wip_entity_id := l_wip_entity_id;

      SELECT  entity_type
     INTO  l_wip_entity_type
     FROM  wip_entities
     WHERE organization_id = l_org_id
     AND   wip_entity_id = l_wip_entity_id;


   x_wip_entity_type := l_wip_entity_type;

   IF l_wip_entity_type = 1 OR l_wip_entity_type = 5 THEN

      -- Discrete job or lot based job

	SELECT
	we.wip_entity_name,
	wl.line_code,
	bd.department_code,
	wro.operation_seq_num

	INTO
	x_job,
	x_line,
	x_dept,
	x_operation_seq_num

	FROM
	wip_entities                    we,
	wip_lines                       wl,
	bom_departments                 bd,
	wip_requirement_operations      wro,
	wip_discrete_jobs               wdj,
	mtl_material_transactions_temp  mmtt
	WHERE we.wip_entity_id         = wdj.wip_entity_id
	  AND we.organization_id       = wdj.organization_id
	  AND wl.line_id           (+) = wdj.line_id
	  AND wl.organization_id   (+) = wdj.organization_id
	  AND bd.department_id     (+) = wro.department_id
	  AND wro.wip_entity_id        = wdj.wip_entity_id
	  AND wro.organization_id      = wdj.organization_id
	  AND wro.operation_seq_num    = mmtt.operation_seq_num
          AND wro.inventory_item_id    = mmtt.inventory_item_id
	  AND wdj.wip_entity_id        = mmtt.demand_source_header_id
	  AND wdj.organization_id      = mmtt.organization_id
	  AND mmtt.transaction_temp_id = p_temp_id;

    ELSIF l_wip_entity_type = 2 THEN

      -- Repetitive schedule


      SELECT
	wl.line_code,
	bd.department_code,
	wro.operation_seq_num,
	msik.concatenated_segments,
	wrs.first_unit_start_date

	INTO
	x_line,
	x_dept,
	x_operation_seq_num,
	x_assembly,
	x_start_date

	FROM
	wip_lines                       wl,
	bom_departments                 bd,
	wip_requirement_operations      wro,
	wip_repetitive_schedules        wrs,
	mtl_material_transactions_temp  mmtt,
	mtl_system_items_kfv            msik,
	wip_entities                    we
	WHERE msik.inventory_item_id   = we.primary_item_id
	AND msik.organization_id       = we.organization_id
	AND we.wip_entity_id           = wrs.wip_entity_id
	AND we.organization_id         = wrs.organization_id
	AND wl.line_id                 = wrs.line_id
	AND wl.organization_id         = wrs.organization_id
	AND bd.department_id       (+) = wro.department_id
	AND wro.repetitive_schedule_id = wrs.repetitive_schedule_id
	AND wro.wip_entity_id          = wrs.wip_entity_id
	AND wro.organization_id        = wrs.organization_id
	AND wro.operation_seq_num      = mmtt.operation_seq_num
        AND wro.inventory_item_id      = mmtt.inventory_item_id
	AND wrs.repetitive_schedule_id = mmtt.repetitive_line_id
	AND wrs.wip_entity_id          = mmtt.demand_source_header_id
	AND wrs.organization_id        = mmtt.organization_id
	AND mmtt.transaction_temp_id   = p_temp_id;


    ELSIF l_wip_entity_type = 4 THEN

      -- Flow schedule

      SELECT
	we.wip_entity_name,
	wl.line_code,
	bd.department_code,
	mmtt.operation_seq_num

	INTO
	x_schedule,
	x_line,
	x_dept,
	x_operation_seq_num

	FROM
	wip_entities                    we,
	wip_lines                       wl,
	bom_departments                 bd,
	bom_operation_sequences         bos,
	bom_operational_routings        bor,
	wip_flow_schedules              wfs,
	mtl_material_transactions_temp  mmtt
	WHERE we.wip_entity_id       = wfs.wip_entity_id
	AND we.organization_id       = wfs.organization_id
	AND wl.line_id               = wfs.line_id
	AND wl.organization_id       = wfs.organization_id
	AND bd.department_id         = bos.department_id
	AND bos.routing_sequence_id  = bor.routing_sequence_id
	AND bos.operation_type       = 1
	AND bos.effectivity_date    >= sysdate
	AND ( wfs.alternate_routing_designator = bor.alternate_routing_designator
	      OR (wfs.alternate_routing_designator IS NULL
		  AND bor.alternate_routing_designator IS NULL) )
	AND bor.assembly_item_id     = wfs.primary_item_id
	AND bor.organization_id      = wfs.organization_id
	AND wfs.wip_entity_id        = mmtt.demand_source_header_id
        AND wfs.organization_id      = mmtt.organization_id
	AND mmtt.transaction_temp_id = p_temp_id;

   END IF;

   IF (l_debug = 1) THEN
      mydebug('get_wip_info_for_putaway: x_wip_entity_type: ' || x_wip_entity_type);
      mydebug('get_wip_info_for_putaway: x_job: ' || x_job);
      mydebug('get_wip_info_for_putaway: x_line: ' || x_line);
      mydebug('get_wip_info_for_putaway: x_dept: ' || x_dept);
      mydebug('get_wip_info_for_putaway: x_operation_seq_num: ' || x_operation_seq_num);
      mydebug('get_wip_info_for_putaway: x_start_date: ' || x_start_date);
      mydebug('get_wip_info_for_putaway: x_schedule: ' || x_schedule);
      mydebug('get_wip_info_for_putaway: x_assembly: ' || x_assembly);
   END IF;

   IF (l_debug = 1) THEN
      mydebug('get_wip_info_for_putaway: Get_wip_info_for_putaway ends');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF (l_debug = 1) THEN
         mydebug('get_wip_info_for_putaway: unexpected error: ' || Sqlerrm);
      END IF;
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         mydebug('get_wip_info_for_putaway: unexpected error: ' || Sqlerrm);
      END IF;
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

END get_wip_info_for_putaway;



PROCEDURE unallocate_material
  (p_wip_entity_id          IN NUMBER,
   p_operation_seq_num      IN NUMBER,
   p_inventory_item_id      IN NUMBER,
   p_repetitive_schedule_id IN NUMBER := NULL,
   p_primary_quantity       IN NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_data              OUT  NOCOPY VARCHAR2
   )

  IS
     l_return_status VARCHAR2(1);
     l_msg_data      VARCHAR2(2500);
     l_msg_count     NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   l_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_debug = 1) THEN
      mydebug('wip_picking_pub.unallocate_material ends');
   END IF;
    wip_picking_pub.unallocate_material
     (p_wip_entity_id         => p_wip_entity_id,
      p_operation_seq_num     => p_operation_seq_num,
      p_inventory_item_id     => p_inventory_item_id,
      p_repetitive_schedule_id=> p_repetitive_schedule_id,
      p_primary_quantity      => p_primary_quantity,
      x_return_status         => l_return_status,
      x_msg_data              => l_msg_data);

  IF (l_debug = 1) THEN
     mydebug('unallocate_material ends');
  END IF;
  x_return_status := l_return_status;
  x_msg_data := l_msg_data;

EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => l_msg_count
           , p_data   => l_msg_data
	   );

   WHEN OTHERS THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
          );


END unallocate_material;

PROCEDURE transfer_Reservation
  (
    P_HEADER_ID            IN NUMBER,
    P_SUBINVENTORY_CODE    IN VARCHAR2,
    P_LOCATOR_ID           IN NUMBER,
    X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
    X_MSG_COUNT            OUT NOCOPY NUMBER,
    X_ERR_MSG              OUT NOCOPY VARCHAR2,
    p_temp_id              IN  NUMBER)
  IS

     CURSOR mtlt_csr IS
	SELECT mtlt.lot_number, mtlt.primary_quantity
	  FROM
	  mtl_material_transactions_temp mmtt,
	  mtl_transaction_lots_temp mtlt
	  WHERE mmtt.transaction_temp_id = p_temp_id
	  AND   mmtt.transaction_temp_id = mtlt.transaction_temp_id;

     l_lot_control_code NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_number       VARCHAR2(80);
     l_lpn_id           NUMBER;
     l_xfr_lpn_id       NUMBER;
     l_content_lpn_id   NUMBER;
     l_lot_primary_qty  NUMBER;
     l_primary_qty      NUMBER;
     l_lpn_controlled_flag NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      mydebug('transfer_Reservation: transfer_Reservation API begins');
   END IF;

   SELECT
     msi.lot_control_code,
     mmtt.primary_quantity,
     mmtt.transfer_lpn_id,
     mmtt.content_lpn_id,
     msin.LPN_CONTROLLED_FLAG
     INTO
     l_lot_control_code,
     l_primary_qty,
     l_xfr_lpn_id,
     l_content_lpn_id,
     l_lpn_controlled_flag
     FROM
     mtl_system_items msi,
     mtl_material_transactions_temp mmtt,
     mtl_secondary_inventories msin
     WHERE mmtt.transaction_temp_id = p_temp_id
     AND   mmtt.organization_id     = msi.organization_id
     AND   mmtt.inventory_item_id   = msi.inventory_item_id
     AND   mmtt.organization_id     = msin.organization_id
     AND   mmtt.subinventory_code   = msin.SECONDARY_INVENTORY_NAME;

   IF l_content_lpn_id IS NOT NULL THEN

      l_lpn_id := l_content_lpn_id;

    ELSIF l_xfr_lpn_id IS NOT NULL THEN

      l_lpn_id := l_xfr_lpn_id;

    ELSE

      l_lpn_id := NULL;

   END IF;

   IF l_lpn_controlled_flag = 2 THEN --NON LPN CONTROLLED SUBINVENTORY
     l_lpn_id := NULL;
   END IF;


   IF l_lot_control_code > 1 THEN

      IF (l_debug = 1) THEN
         mydebug('transfer_Reservation: Lot controlled item');
      END IF;

      OPEN mtlt_csr;
      LOOP
	 FETCH mtlt_csr INTO l_lot_number, l_lot_primary_qty;
	   EXIT WHEN mtlt_csr%notfound;

	 wma_inv_wrappers.transferReservation
	   (P_HEADER_ID           =>  p_header_id,
	    P_SUBINVENTORY_CODE   =>  p_subinventory_code,
	    P_LOCATOR_ID          =>  p_locator_id,
	    p_primary_quantity    =>  l_lot_primary_qty,
	    p_lpn_id              =>  l_lpn_id,
	    p_lot_number          =>  l_lot_number,
	    X_RETURN_STATUS       =>  x_return_status,
	    X_MSG_COUNT           =>  x_msg_count,
	    X_ERR_MSG             =>  x_err_msg);

      END LOOP;
      CLOSE mtlt_csr;

    ELSE
      IF (l_debug = 1) THEN
         mydebug('transfer_Reservation: Not a lot controlled item');
      END IF;

      wma_inv_wrappers.transferReservation
	(P_HEADER_ID           =>  p_header_id,
	 P_SUBINVENTORY_CODE   =>  p_subinventory_code,
	 P_LOCATOR_ID          =>  p_locator_id,
	 p_primary_quantity    =>  l_primary_qty,
	 p_lpn_id              =>  l_lpn_id,
	 p_lot_number          =>  null,
	 X_RETURN_STATUS       =>  x_return_status,
	 X_MSG_COUNT           =>  x_msg_count,
	 X_ERR_MSG             =>  x_err_msg);

   END IF;

   IF (l_debug = 1) THEN
      mydebug('transfer_Reservation: transfer_Reservation API complete');
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_err_msg
	   );

      IF (l_debug = 1) THEN
         mydebug('transfer_reservation: G_EXC_UNEXPECTED_ERROR ' || sqlerrm);
      END IF;

   WHEN OTHERS THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_err_msg
          );
      IF (l_debug = 1) THEN
         mydebug('transfer_reservation: Other errors ' || sqlerrm);
      END IF;

END transfer_reservation;


PROCEDURE mydebug(msg in varchar2)
  IS
     l_msg VARCHAR2(5100);
     l_ts VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
--   select to_char(sysdate,'MM/DD/YYYY HH:MM:SS') INTO l_ts from dual;
--   l_msg:=l_ts||'  '||msg;

   l_msg := msg;

   inv_mobile_helper_functions.tracelog
     (p_err_msg => l_msg,
      p_module => 'WMSWIPIB',
      p_level => 4);
   --dbms_output.put_line('WMS_WIP_Integration' || l_msg);

   null;
END;

PROCEDURE update_mmtt_for_wip
( p_transaction_temp_id     IN  NUMBER
, p_wip_entity_id           IN  NUMBER
, p_operation_seq_num       IN  NUMBER
, p_repetitive_schedule_id  IN  NUMBER
, p_transaction_type_id     IN  NUMBER
) IS

    l_organization_id     NUMBER;
    l_entity_type         NUMBER;
    l_repetitive_line_id  NUMBER;
    l_department_id       NUMBER;
    l_department_code     bom_departments.department_code%TYPE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_project_id         NUMBER := NULL ;  --Bug6604904
    l_task_id            NUMBER := NULL ;  --Bug6604904

BEGIN

    IF (l_debug = 1) THEN
       mydebug ('update_mmtt_for_wip: '  ||
             'p_transaction_temp_id=' || to_char(p_transaction_temp_id) ||
             ', p_wip_entity_id='     || to_char(p_wip_entity_id)       ||
             ', p_operation_seq_num=' || to_char(p_operation_seq_num)
            );
    END IF;

    IF p_transaction_type_id IS NULL  OR
      (p_transaction_type_id <> INV_Globals.G_TYPE_XFER_ORDER_WIP_ISSUE  AND
       p_transaction_type_id <> INV_Globals.G_TYPE_XFER_ORDER_REPL_SUBXFR)  THEN
        IF (l_debug = 1) THEN
           mydebug ('update_mmtt_for_wip:'||'Invalid transaction type: ' || to_char(p_transaction_type_id));
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BEGIN
      /* Bug6604904. Modified query to get project and task info from MTRL */
        SELECT mmtt.organization_id, mtrl.project_id , mtrl.task_id
          INTO l_organization_id , l_project_id, l_task_id
          FROM mtl_material_transactions_temp mmtt, mtl_txn_request_lines mtrl
         WHERE mmtt.transaction_temp_id = p_transaction_temp_id
          AND mmtt.move_order_line_id = mtrl.line_id ;
    EXCEPTION
        WHEN OTHERS THEN
            IF (l_debug = 1) THEN
               mydebug ('update_mmtt_for_wip:'||'Could not determine Org ID for passed in temp ID: ' || to_char(p_transaction_temp_id));
            END IF;
            RAISE;
    END;

    -- entity type
    BEGIN
        SELECT entity_type
          INTO l_entity_type
          FROM wip_entities
         WHERE wip_entity_id   = p_wip_entity_id
           AND organization_id = l_organization_id;
    EXCEPTION
        WHEN OTHERS THEN
            IF (l_debug = 1) THEN
               mydebug ('update_mmtt_for_wip:'||'Could not determine WIP entity type for passed in entity ID: ' || to_char(p_wip_entity_id));
            END IF;
            RAISE;
    END;



    IF p_transaction_type_id = INV_Globals.G_TYPE_XFER_ORDER_WIP_ISSUE
    THEN

        IF l_entity_type = 2 THEN
            IF p_repetitive_schedule_id IS NULL THEN
                IF (l_debug = 1) THEN
                   mydebug ('update_mmtt_for_wip:'||
                         'Parameter p_repetitive_schedule_id cannot be null for entity type 2.');
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSE
                BEGIN
                    SELECT line_id
                      INTO l_repetitive_line_id
                      FROM wip_repetitive_schedules
                     WHERE wip_entity_id          = p_wip_entity_id
                       AND repetitive_schedule_id = p_repetitive_schedule_id
                       AND organization_id        = l_organization_id;
                EXCEPTION
                    WHEN OTHERS THEN
                        IF (l_debug = 1) THEN
                           mydebug ('update_mmtt_for_wip:'||'Unable to determine rep line ID for rep sch ID ' || to_char(p_repetitive_schedule_id));
                        END IF;
                        RAISE;
                END;
            END IF;
        END IF;

        -- dept ID, code
        BEGIN
            IF l_entity_type  IN (1,5) THEN
                SELECT wo.department_id
                     , bd.department_code
                  INTO l_department_id
                     , l_department_code
                  FROM bom_departments  bd
                     , wip_operations   wo
                 WHERE bd.department_id     = wo.department_id
                   AND wo.wip_entity_id     = p_wip_entity_id
                   AND wo.organization_id   = l_organization_id
                   AND wo.operation_seq_num = p_operation_seq_num;
            ELSIF l_entity_type = 2  THEN
                SELECT wo.department_id
                     , bd.department_code
                  INTO l_department_id
                     , l_department_code
                  FROM bom_departments  bd
                     , wip_operations   wo
                 WHERE bd.department_id          = wo.department_id
                   AND wo.wip_entity_id          = p_wip_entity_id
                   AND wo.organization_id        = l_organization_id
                   AND wo.operation_seq_num      = p_operation_seq_num
                   AND wo.repetitive_schedule_id = p_repetitive_schedule_id;
            ELSIF l_entity_type = 4  THEN
                SELECT bos.department_id
                     , bd.department_code
                  INTO l_department_id
                     , l_department_code
                  FROM bom_departments                 bd
                     , bom_operation_sequences         bos
                     , bom_operational_routings        bor
                     , wip_flow_schedules              wfs
                 WHERE bd.department_id         = bos.department_id
                   AND bos.routing_sequence_id  = bor.routing_sequence_id
                   AND bos.operation_type       = 1
                   AND bos.effectivity_date    >= sysdate
                   AND (bor.alternate_routing_designator = wfs.alternate_routing_designator
                        OR (wfs.alternate_routing_designator IS NULL
                            AND bor.alternate_routing_designator IS NULL)
                       )
                   AND bor.assembly_item_id     = wfs.primary_item_id
                   AND bor.organization_id      = wfs.organization_id
                   AND wfs.wip_entity_id        = p_wip_entity_id
                   AND wfs.organization_id      = l_organization_id;
            ELSE
                IF (l_debug = 1) THEN
                   mydebug ('update_mmtt_for_wip:'||'Invalid entity type: ' || to_char(l_entity_type));
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Bug 2023916:
                -- No entry in wip operations for discrete/rep job (routing does not exist)
                IF (l_debug = 1) THEN
                   mydebug ('update_mmtt_for_wip:'||'No data for dept ID/code (entity type ' || l_entity_type || ')');
                END IF;
                l_department_id := NULL;
                l_department_code := NULL;
            WHEN OTHERS THEN
                IF (l_debug = 1) THEN
                   mydebug ('update_mmtt_for_wip:'||'Unable to determine department ID and department code.');
                END IF;
                RAISE;
        END;
    END IF; -- end if txn type is wip issue

    IF p_transaction_type_id = INV_Globals.G_TYPE_XFER_ORDER_WIP_ISSUE
    THEN
        UPDATE mtl_material_transactions_temp
           SET transaction_source_id      = p_wip_entity_id
             , trx_source_line_id         = p_operation_seq_num
             , demand_source_header_id    = p_wip_entity_id
             , demand_source_line         = p_operation_seq_num
             , transaction_source_type_id = INV_Globals.G_SourceType_WIP
             , transaction_type_id        = p_transaction_type_id
             , transaction_action_id      = INV_Globals.G_Action_Issue
             , wip_entity_type            = l_entity_type
             , repetitive_line_id         = l_repetitive_line_id
             , operation_seq_num          = p_operation_seq_num
             , department_id              = l_department_id
             , department_code            = l_department_code
             , lock_flag                  = 'N'
             , primary_switch             = 1
             , wip_supply_type            = 1
             , negative_req_flag          = sign(transaction_quantity)
             , required_flag              = '1'
             , process_flag               = 'Y' -- Forward Port for bug 5188464
             , flow_schedule              = NULL
	     , project_id                 = l_project_id   -- Bug6604904
	     , task_id                    = l_task_id      -- Bug6604904
             ,source_project_id           = l_project_id --bug 6688561
	     ,source_task_id              = l_task_id --bug 6688561
	     , transaction_date                  = SYSDATE --Bug 7305385
         WHERE transaction_temp_id = p_transaction_temp_id;
        IF (l_debug = 1) THEN
           mydebug ('update_mmtt_for_wip:'||'Done updating mmtt rec ' || p_transaction_temp_id || ' for WIP Issue.');
        END IF;

    ELSIF p_transaction_type_id = INV_Globals.G_TYPE_XFER_ORDER_REPL_SUBXFR  THEN
        --
        -- Bug 2057540: explicitly set WIP_SUPPLY_TYPE to null
        --
        UPDATE mtl_material_transactions_temp
           SET transaction_source_id      = p_wip_entity_id
             , trx_source_line_id         = p_operation_seq_num
             , demand_source_header_id    = p_wip_entity_id
             , demand_source_line         = p_operation_seq_num
             , transaction_source_type_id = INV_Globals.G_SourceType_Inventory
             , transaction_type_id        = p_transaction_type_id
             , transaction_action_id      = INV_Globals.G_Action_Subxfr
             , wip_entity_type            = l_entity_type
             , wip_supply_type            = NULL
         WHERE transaction_temp_id = p_transaction_temp_id;
         IF (l_debug = 1) THEN
            mydebug ('update_mmtt_for_wip:'||'Done updating mmtt record ' || p_transaction_temp_id ||
                  ' for backflush sub transfer.');
         END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF (l_debug = 1) THEN
           mydebug ('Error in update_mmtt_for_wip: ' || sqlcode || ',  '||sqlerrm);
        END IF;
        RAISE;
END update_mmtt_for_wip;


-- Bug 2747945 : Added business flow code to the call to the wip processor.
PROCEDURE wip_processor
  (p_txn_hdr_id     IN  NUMBER,
   p_business_flow_code IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2)
  IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_errorMsg VARCHAR2(100);
BEGIN

   IF (l_debug = 1) THEN
      mydebug('wip_processor: Begins');
      mydebug('Txn Header ID : '|| p_txn_hdr_id );
      mydebug('business flow code : '|| p_business_flow_code);
   END IF;

   wip_mtlTempProc_grp.processtemp(p_initMsgList  => FND_API.g_true,
                                   p_processInv   => FND_API.g_true, --whether call inventory TM OR not
				   p_txnHdrID     => p_txn_hdr_id,
				   p_mtlTxnBusinessFlowCode => p_business_flow_code,
				   x_returnStatus => x_return_status,
				   x_errorMsg     => l_errorMsg);

   IF (l_debug = 1) THEN
      mydebug('wip_processor: Ends');
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.ADD;
      IF (l_debug = 1) THEN
         mydebug('wip_processor: Error: ' || sqlerrm);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_error;

      FND_MSG_PUB.ADD;
      IF (l_debug = 1) THEN
         mydebug('wip_processor: Other Error: ' || sqlerrm);
      END IF;

END wip_processor;


END WMS_WIP_Integration ;

/
