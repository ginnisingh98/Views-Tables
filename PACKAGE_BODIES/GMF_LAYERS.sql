--------------------------------------------------------
--  DDL for Package Body GMF_LAYERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_LAYERS" AS
/*  $Header: GMFLAYRB.pls 120.1.12010000.7 2010/04/05 19:58:18 rpatangy ship $ */

g_pkg_name VARCHAR2(30) := 'GMF_LAYERS';
g_debug    VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');

/*
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMFLAYR.pls                                                           |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMF_LAYERS                                                            |
 |                                                                          |
 | DESCRIPTION                                                              |
 |                                                                          |
 | CONTENTS                                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |      06-OCT-06 Venkat Chukkapalli BUG#5586577.                           |
 |      If doc type is not PROD set return status to SUCCESS to return      |
 |      without an error in procedures: Create_Incoming_Layers,             |
 |      Create_Outgoing_Layers and Create_Resource_Layers.		    |
 |									    |
 |	10-MAR-09 Hari Luthra BUG#8299247				    |
 |	If the yield or consumption is not in lots then avoid NO_DATA_FOUND |
 |									    |
 +==========================================================================+
*/

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Create_Incoming_Layers                                                |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Create_Incoming_Layers                                                |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|                                                                          |
--+==========================================================================+
*/
PROCEDURE Create_Incoming_Layers
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_tran_rec      IN          GMF_LAYERS.trans_rec_type,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2) IS

l_layer_id		NUMBER;
l_layer_rec		gmf_incoming_material_layers%ROWTYPE;
l_doc_qty		NUMBER;
l_doc_um		VARCHAR2(4);
l_req_count		PLS_INTEGER;

l_api_name	VARCHAR2(30) := 'Create_Incoming_Layers';

BEGIN
  	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Entering api ' || g_pkg_name || '.' || l_api_name);
	  gme_debug.put_line ('processing batch: ' || p_tran_rec.transaction_source_id || ' item/org/lot/txnId/reverseId: ' ||
	    p_tran_rec.inventory_item_id ||'/'|| p_tran_rec.organization_id || '/' ||
	    p_tran_rec.lot_number ||'/'|| p_tran_rec.transaction_id ||'/'|| p_tran_rec.reverse_id ||
	    ' line_type: ' || p_tran_rec.line_type);
	  gme_debug.put_line ('pri Qty: ' || p_tran_rec.primary_quantity || ' ' || p_tran_rec.primary_uom ||
	    ' doc qty: ' || p_tran_rec.doc_qty || ' ' || p_tran_rec.doc_uom);
	END IF;

	-- Possible validations
	-- Verify that the there is no other record with this trans_id
	-- Validate that this is valid trans_id
	-- Validate that it is for doc_type PROD and line_type -1 and 2
	-- Insert the data into the layers table
	IF (p_tran_rec.transaction_source_type_id <> 5) THEN
		-- Bug 5586577. Return with Success.
		-- x_return_status := FND_API.G_RET_STS_ERROR ;
		x_return_status := FND_API.G_RET_STS_SUCCESS ;
		--dbms_output.put_line ('Only PROD document allowed for incoming layers');
		-- FND_MESSAGE.SET_NAME('GMF', 'GMF_NON_PROD_TRANS');
		-- FND_MSG_PUB.Add;
		RETURN;
	END IF;

	IF (p_tran_rec.line_type <> 1 ) THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		--dbms_output.put_line ('Only Products allowed for incoming layers');
		FND_MESSAGE.SET_NAME('GMF', 'GMF_NON_PRODUCT_TRANS');
		FND_MSG_PUB.Add;
		RETURN;
	END IF;

	-- If the doc_qty is not passed for the reversed layer, get it from the original layer
	l_doc_qty := p_tran_rec.doc_qty;
	l_doc_um := p_tran_rec.doc_uom;

	IF (p_tran_rec.reverse_id IS NOT NULL and p_tran_rec.doc_qty IS NULL) THEN
	BEGIN
	        /* PK Bug 8219507 removed mtln */
		SELECT -l.layer_doc_qty, l.layer_doc_um
		INTO l_doc_qty, l_doc_um
		FROM gmf_incoming_material_layers l, mtl_material_transactions mmt
		--	mtl_transaction_lot_numbers mtln
		WHERE
			mmt.transaction_id = p_tran_rec.reverse_id AND
                --        mtln.transaction_id (+) = p_tran_rec.reverse_id AND
		--	mtln.lot_number (+) = p_tran_rec.lot_number AND
			l.mmt_transaction_id = mmt.transaction_id ; -- AND
	--		l.lot_number(+) = mtln.lot_number ;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_return_status := FND_API.G_RET_STS_ERROR ;
			--dbms_output.put_line ('Could not find the reversed layer');
			FND_MESSAGE.SET_NAME('GMF', 'GMF_NO_REVERSED_LAYER');
			FND_MSG_PUB.Add;
			RETURN;
	END;
	END IF;

	IF (l_doc_qty IS NULL ) THEN
		IF g_debug <= gme_debug.g_log_procedure THEN
		  gme_debug.put_line ('No doc quantity specified for the layer');
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MESSAGE.SET_NAME('GMF', 'GMF_NO_DOC_QTY_FOR_LAYER');
		FND_MSG_PUB.Add;
		RETURN;
	END IF;



	-- Create the incoming layer
	SELECT gmf_layer_id_s.nextval INTO l_layer_id FROM DUAL;

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('creating incoming layer: ' || l_layer_id);
	END IF;

	INSERT INTO gmf_incoming_material_layers(
		layer_id,
		mmt_transaction_id,
		mmt_organization_id,
		lot_number,
		layer_doc_qty,
		layer_doc_um,
		layer_date,
		pseudo_layer_id,
		final_cost_ind,
		gl_posted_ind,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		accounted_flag)
	VALUES(
		l_layer_id,
		p_tran_rec.transaction_id,
		p_tran_rec.organization_id,
		p_tran_rec.lot_number,
		l_doc_qty,
		l_doc_um,
		p_tran_rec.transaction_date,
		NULL,
		0,
		0,
		p_tran_rec.created_by,
		sysdate,
		p_tran_rec.last_updated_by,
		sysdate,
		p_tran_rec.last_update_login,
		'N');


	l_layer_rec.layer_id := l_layer_id;
	l_layer_rec.mmt_transaction_id := p_tran_rec.transaction_id;
	l_layer_rec.layer_doc_qty := l_doc_qty;
	l_layer_rec.layer_doc_um := l_doc_um;
	l_layer_rec.layer_date := p_tran_rec.transaction_date;
	l_layer_rec.final_cost_ind := 0;
	l_layer_rec.gl_posted_ind := 0;

	-- If the batch is completed directly, we may not have the requirements.
	-- In such case, make the call to create the requirements.

	l_req_count := 0;
	SELECT count(*)
	INTO l_req_count
	FROM gmf_batch_requirements
	WHERE batch_id = p_tran_rec.transaction_source_id
	AND delete_mark = 0;

	IF l_req_count = 0 THEN
		IF g_debug <= gme_debug.g_log_statement THEN
		  gme_debug.put_line ('creating batch requirements before creating VIB details');
		END IF;
		-- Create the requirements
		GMF_VIB.Create_Batch_Requirements(
			1.0,
			FND_API.G_FALSE,
			p_tran_rec.transaction_source_id,
			x_return_status,
			x_msg_count,
			x_msg_data);
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			-- requirement creation failed.
			RETURN;
		END IF;
	END IF;

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('now calling Create_VIB_Details');
	END IF;

	-- Now generate the VIB details for this product transaction.
	GMF_VIB.Create_VIB_Details (
		p_api_version,
		p_init_msg_list,
		p_tran_rec,
		l_layer_rec,
		x_return_status,
		x_msg_count,
		x_msg_data);

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('done creating vib details. status/msg: ' || x_return_status ||'/'|| x_msg_data);
	END IF;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	  	gme_debug.put_line ('Exiting api (thru when others) ' || g_pkg_name || '.' || l_api_name);
		FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
		FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
		FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END;


/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Create_Outgoing_Layers                                                |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Create_Outgoing_Layers                                                |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY								     |
--|	10-MAR-09 Hari Luthra BUG#8299247				     |
--|	If the yield or consumption is not in lots then avoid NO_DATA_FOUND  |
--|                                                                          |
--+==========================================================================+
*/
PROCEDURE Create_Outgoing_Layers
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_tran_rec      IN          GMF_LAYERS.TRANS_REC_TYPE,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2) IS

/* PK Bug 8219507 removed mtln */

  CURSOR c_null_vib_rows IS
  SELECT v.rowid, v.*, mmt.organization_id, l.layer_date
  FROM gmf_batch_vib_details v,
	gmf_batch_requirements r,
	gmf_incoming_material_layers l,
	mtl_material_transactions mmt
--        mtl_transaction_lot_numbers mtln
  WHERE
	r.batch_id = p_tran_rec.transaction_source_id AND
	r.ing_material_detail_id = p_tran_rec.trx_source_line_id AND
	r.delete_mark = 0 AND
	v.requirement_id = r.requirement_id AND
	v.consume_layer_id is NULL AND
	v.finalize_ind = 0 AND
	l.layer_id = v.prod_layer_id AND
	l.final_cost_ind = 0 AND
	l.mmt_transaction_id = mmt.transaction_id	AND
--	mtln.transaction_id(+) = l.mmt_transaction_id	AND
--        mtln.lot_number(+)     = l.lot_number AND
	-- mmt.source_line_id = -99 AND
	mmt.opm_costed_flag IS NOT NULL AND
	not exists (select 'x' from gme_transaction_pairs tp
			where transaction_id1 = mmt.transaction_id and tp.pair_type = 1)
  ORDER by v.prod_layer_id DESC;


  l_layer_id		NUMBER;
  l_remaining_ib_doc_qty	NUMBER;
  l_rev_consume_ib_doc_qty	NUMBER;
  l_consume_ib_doc_qty	NUMBER;
  l_consume_ib_pri_qty	NUMBER;
  l_doc_qty		NUMBER;
  l_doc_um		VARCHAR2(4);
  l_delete_mark		NUMBER;
  l_period_count		PLS_INTEGER;
  l_rowid			ROWID;

  e_invalid_consumption	EXCEPTION;

  l_api_name	VARCHAR2(30) := 'Create_Outgoing_Layers';

BEGIN
  	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Entering api ' || g_pkg_name || '.' || l_api_name);
	  gme_debug.put_line ('processing batch: ' || p_tran_rec.transaction_source_id || ' item/org/lot/txnId/reverseId: ' ||
	    p_tran_rec.inventory_item_id ||'/'|| p_tran_rec.organization_id || '/' ||
	    p_tran_rec.lot_number ||'/'|| p_tran_rec.transaction_id ||'/'|| p_tran_rec.reverse_id ||
	    ' line_type: ' || p_tran_rec.line_type);
	  gme_debug.put_line ('pri Qty: ' || p_tran_rec.primary_quantity || ' ' || p_tran_rec.primary_uom ||
	    ' doc qty: ' || p_tran_rec.doc_qty || ' ' || p_tran_rec.doc_uom);
	END IF;

	-- Possible validations
	-- Verify that the there is no other record with this trans_id
	-- Validate that this is valid trans_id
	-- Validate that it is for doc_type PROD and line_type -1 and 2
	-- Insert the data into the layers table
	IF (p_tran_rec.transaction_source_type_id <> 5) THEN
		-- Bug 5586577. Return with Success.
		-- x_return_status := FND_API.G_RET_STS_ERROR ;
		x_return_status := FND_API.G_RET_STS_SUCCESS ;
		--dbms_output.put_line ('Only PROD document allowed for outgoing layers');
		-- FND_MESSAGE.SET_NAME('GMF', 'GMF_NON_PROD_TRANS');
		-- FND_MSG_PUB.Add;
		RETURN;
	END IF;
	IF (p_tran_rec.line_type <> -1 and p_tran_rec.line_type <> 2) THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
	  	gme_debug.put_line ('Error-GMF: Only Ingredients and By-Products allowed for outgoing layers');
		FND_MESSAGE.SET_NAME('GMF', 'GMF_NON_ING_TRANS');
		FND_MSG_PUB.Add;
		RETURN;
	END IF;

	-- If the doc_qty is not passed for the reversed layer, get it from the original layer
	l_doc_qty := p_tran_rec.doc_qty;
	l_doc_um := p_tran_rec.doc_uom;

	IF (p_tran_rec.reverse_id IS NOT NULL and p_tran_rec.doc_qty IS NULL) THEN
		BEGIN
                        /* PK Bug 8219507 removed mtln */
			SELECT -l.layer_doc_qty, l.layer_doc_um
			INTO l_doc_qty, l_doc_um
			FROM gmf_outgoing_material_layers l, mtl_material_transactions mmt
--				mtl_transaction_lot_numbers mtln
			WHERE
				mmt.transaction_id = p_tran_rec.reverse_id AND
        	        --        mtln.transaction_id (+) = p_tran_rec.reverse_id AND
			--	mtln.lot_number (+) = p_tran_rec.lot_number AND
				l.mmt_transaction_id = mmt.transaction_id; -- AND
			--	l.lot_number(+) = mtln.lot_number ;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_return_status := FND_API.G_RET_STS_ERROR ;
				--dbms_output.put_line ('Could not find the reversed layer');
				FND_MESSAGE.SET_NAME('GMF', 'GMF_NO_REVERSED_LAYER');
				FND_MSG_PUB.Add;
				RETURN;
		END;
	END IF;

	IF (l_doc_qty IS NULL ) THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		IF g_debug <= gme_debug.g_log_procedure THEN
		  gme_debug.put_line ('No doc quantity specified for the layer');
		END IF;
		FND_MESSAGE.SET_NAME('GMF', 'GMF_NO_DOC_QTY_FOR_LAYER');
		FND_MSG_PUB.Add;
		RETURN;
	END IF;

	SELECT gmf_layer_id_s.nextval INTO l_layer_id FROM DUAL;
	l_remaining_ib_doc_qty := l_doc_qty;

	-- Store ingredient consumption as positive quantities
	-- IF (p_tran_rec.line_type = -1) THEN
	--	l_remaining_ib_doc_qty := -l_remaining_ib_doc_qty;
	-- END IF;

	-- If this a reversed layer, do not comsume from it.
	l_delete_mark := 0;
	IF (p_tran_rec.reverse_id IS NOT NULL) THEN
		-- If the reverse transaction is alrady used in
		-- VIB details, get the quantity used in VIB details.
		-- We need to leave that much qty to reverse those VIB details later.

		IF g_debug <= gme_debug.g_log_statement THEN
		  gme_debug.put_line ('Reversal. get the quantity used in VIB details, if any.');
		END IF;

		BEGIN

		/* HALUTHRA : Bug 8299247. Chaging l.lot_number = p_tran_rec.lot_number to
		nvl(l.lot_number,'X')=nvl(p_tran_rec.lot_number,'X') */

            SELECT -sum(nvl(consume_ib_doc_qty,0)), l.ROWID
			INTO l_rev_consume_ib_doc_qty, l_rowid
			FROM   gmf_outgoing_material_layers l,
				gmf_batch_vib_details v
			WHERE l.mmt_transaction_id =  p_tran_rec.reverse_id and
				nvl(l.lot_number,'X')= nvl(p_tran_rec.lot_number,'X') and
				l.layer_id = v.consume_layer_id (+)
			GROUP BY l.ROWID;

			IF g_debug <= gme_debug.g_log_statement THEN
			  gme_debug.put_line ('Reversal. quantity already used in VIB details is: ' ||
			    l_rev_consume_ib_doc_qty);
			END IF;

			l_remaining_ib_doc_qty := l_rev_consume_ib_doc_qty;
			IF l_rev_consume_ib_doc_qty = 0 THEN
				l_delete_mark := 1;
			END IF;

			UPDATE gmf_outgoing_material_layers
			SET remaining_ib_doc_qty = 0,
				delete_mark = l_delete_mark
			WHERE
				ROWID = l_rowid;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
		END;
	END IF;

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('l_remaining_ib_doc_qty: ' || l_remaining_ib_doc_qty);
	END IF;

	IF l_remaining_ib_doc_qty > 0 THEN
		-- If ingredients were consumed after the product was yielded, there are
		-- VIB details pointing to the NULL consumption layers. If possible,
		-- Update them to consume from this layer. This is done only if the product
		-- Layer is not posted to subledgerand the cost is not frozen.

		IF g_debug <= gme_debug.g_log_statement THEN
		  gme_debug.put_line ('getting null consumption layers from VIB details, if any');
		END IF;

		FOR n IN c_null_vib_rows LOOP

			IF g_debug <= gme_debug.g_log_statement THEN
			  gme_debug.put_line ('found null consumption layers. prodLayer/ConsLayer/lineType: ' ||
			  	n.prod_layer_id||'/'||n.consume_layer_id||'/'||n.line_type);
			END IF;

			BEGIN
			  IF l_remaining_ib_doc_qty = 0 THEN
			  	RAISE e_invalid_consumption;
			  END IF;


			  SELECT COUNT(*)
			  INTO l_period_count
			    FROM gmf_organization_definitions god,
			         gmf_period_statuses gps,
			         gmf_fiscal_policies gfp,
			         cm_mthd_mst mthd
			   WHERE god.organization_id = n.organization_id
			     AND gfp.legal_entity_id = god.legal_entity_id
			     AND mthd.cost_type_id = gfp.cost_type_id
			     AND mthd.cost_type = 1 -- Actual costing method
			     AND mthd.prodcalc_type = 1 -- PMAC product cost
			     AND gps.legal_entity_id = gfp.legal_entity_id
			     AND gps.cost_type_id = gfp.cost_type_id
			     AND n.layer_date BETWEEN gps.start_date AND gps.end_date
			     AND p_tran_rec.transaction_date BETWEEN gps.start_date AND gps.end_date;

			  IF l_period_count = 0 THEN
			  	RAISE e_invalid_consumption;
			  END IF;

			  -- If ingredient qty is more then what is needed.
			  IF n.consume_ib_doc_qty <= l_remaining_ib_doc_qty THEN

				IF g_debug <= gme_debug.g_log_statement THEN
				  gme_debug.put_line ('If ingredient qty is more then what is needed.');
				END IF;

			  	UPDATE gmf_batch_vib_details
			  	SET consume_layer_id = l_layer_id,
			  		consume_layer_date = p_tran_rec.transaction_date
			  	WHERE ROWID = n.rowid;

			  	l_remaining_ib_doc_qty := l_remaining_ib_doc_qty - n.consume_ib_doc_qty;
			  ELSE
			  	-- If ingredient qty is less then what is needed.
			  	-- Split the row into 2.
			  	-- Create another row with NULL layer for remaining quantity
			  	-- First convert the consume quantity to primary UM.

				IF g_debug <= gme_debug.g_log_statement THEN
				  gme_debug.put_line ('If ingredient qty is less then what is needed...split the row into 2');
				END IF;

			  	l_consume_ib_doc_qty := n.consume_ib_doc_qty - l_remaining_ib_doc_qty;

			  	l_consume_ib_pri_qty :=
			  		INV_CONVERT.INV_UM_CONVERT(
			  		    ITEM_ID       => p_tran_rec.inventory_item_id
			  		  , PRECISION     => 5
			  		  , ORGANIZATION_ID => p_tran_rec.organization_id
			  		  , LOT_NUMBER     => p_tran_rec.lot_number
			  		  , FROM_QUANTITY => l_consume_ib_doc_qty
			  		  , FROM_UNIT     => l_doc_um
			  		  , TO_UNIT       => p_tran_rec.primary_uom
			  		  , FROM_NAME     => NULL
			  		  , TO_NAME       => NULL
			  		);

			  	INSERT INTO gmf_batch_vib_details(
			  		prod_layer_id,
			  		prod_layer_pri_qty,
			  		consume_layer_id,
			  		consume_layer_date,
			  		line_type,
			  		requirement_id,
			  		finalize_ind,
			  		consume_ib_doc_qty,
			  		consume_ib_pri_qty,
			  		created_by,
			  		creation_date,
			  		last_updated_by,
			  		last_update_date,
			  		last_update_login)
			  	VALUES(
			  		n.prod_layer_id,
			  		n.prod_layer_pri_qty,
			  		NULL,
			  		n.consume_layer_date,
			  		p_tran_rec.line_type, -- ???? inserting NULL
			  		n.requirement_id,
			  		0,
			  		l_consume_ib_doc_qty,
			  		l_consume_ib_pri_qty,
			  		p_tran_rec.created_by,
			  		sysdate,
			  		p_tran_rec.last_updated_by,
			  		sysdate,
			  		p_tran_rec.last_update_login);

			  	-- Consume the current ingredient quantity
			  	l_consume_ib_pri_qty :=
			  		INV_CONVERT.INV_UM_CONVERT(
			  		    ITEM_ID       => p_tran_rec.inventory_item_id
			  		  , PRECISION     => 5
			  		  , ORGANIZATION_ID => p_tran_rec.organization_id
			  		  , LOT_NUMBER     => p_tran_rec.lot_number
			  		  , FROM_QUANTITY => l_remaining_ib_doc_qty
			  		  , FROM_UNIT     => l_doc_um
			  		  , TO_UNIT       => p_tran_rec.primary_uom
			  		  , FROM_NAME     => NULL
			  		  , TO_NAME       => NULL
			  		);

			  	UPDATE gmf_batch_vib_details
			  	SET consume_layer_id = l_layer_id,
			  		consume_ib_doc_qty = l_remaining_ib_doc_qty,
			  		consume_ib_pri_qty = l_consume_ib_pri_qty,
			  		consume_layer_date = p_tran_rec.transaction_date
			  	WHERE ROWID = n.rowid;

			  	l_remaining_ib_doc_qty := 0;
			  END IF;
		EXCEPTION
			WHEN e_invalid_consumption THEN
				NULL; -- Skip to the next row
		END;
		END LOOP;

		IF g_debug <= gme_debug.g_log_statement THEN
		  gme_debug.put_line ('done processing consumption layers from VIB details');
		END IF;

	END IF;

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('creating new outgoing layers...');
	END IF;

	INSERT INTO gmf_outgoing_material_layers(
		layer_id,
		mmt_transaction_id,
		mmt_organization_id,
		lot_number,
		layer_doc_qty,
		layer_doc_um,
		remaining_ib_doc_qty,
		delete_mark,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login)
	VALUES(
		l_layer_id,
		p_tran_rec.transaction_id,
		p_tran_rec.organization_id,
		p_tran_rec.lot_number,
		l_doc_qty,
		l_doc_um,
		l_remaining_ib_doc_qty,
		l_delete_mark,
		p_tran_rec.created_by,
		sysdate,
		p_tran_rec.last_updated_by,
		sysdate,
		p_tran_rec.last_update_login);

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line (sql%ROWCOUNT || ' rows inserted');
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;


	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
		FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
		FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END;

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Create_Resource_Layers                                                |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Create_Resource_Layers                                                |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY								     |
--|	10-Mar-09 HARI LUTHRA BUG 8299247				     |
--|	To avoid null return , including nvl and outer join in a query       |
--|                                                                          |
--+==========================================================================+
*/
PROCEDURE Create_Resource_Layers
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_rsrc_rec      IN          gme_resource_txns%ROWTYPE,
  p_doc_qty       IN          NUMBER,
  p_doc_um        IN          VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2) IS

  CURSOR c_null_vib_rows IS
  SELECT v.rowid, v.*, t.organization_id, l.layer_date
  FROM gmf_batch_vib_details v,
	gmf_batch_requirements r,
        gmf_incoming_material_layers l,
        mtl_material_transactions t
  WHERE
	r.batch_id = p_rsrc_rec.doc_id AND
	r.batchstep_resource_id = p_rsrc_rec.line_id AND
	r.delete_mark = 0 AND
	v.requirement_id = r.requirement_id AND
	v.consume_layer_id is NULL AND
        l.layer_id = v.prod_layer_id AND
        l.final_cost_ind = 0 AND
        l.mmt_transaction_id = t.transaction_id AND
-- 	t.source_line_id = -99 AND   commented out for Bug 8472152
        t.opm_costed_flag IS NOT NULL
  -- ORDER by v.consume_layer_id;
  ORDER by v.prod_layer_id desc;

l_layer_id		NUMBER;
l_remaining_ib_doc_qty	NUMBER;
l_rev_consume_ib_doc_qty	NUMBER;
l_consume_ib_doc_qty	NUMBER;
l_consume_ib_pri_qty	NUMBER;
l_delete_mark		NUMBER;
l_period_count		PLS_INTEGER;
l_rowid			ROWID;

e_invalid_consumption	EXCEPTION;

l_api_name		VARCHAR2(40) := 'Create_Resource_Layers';

BEGIN
  	x_return_status := FND_API.G_RET_STS_SUCCESS ;


	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Entering api ' || g_pkg_name || '.' || l_api_name);
	  gme_debug.put_line ('processing batch: ' || p_rsrc_rec.doc_id || ' lineID: ' || p_rsrc_rec.line_id ||
	    ' rsrc/org/txnId/reverseId: ' || p_rsrc_rec.resources ||'/'|| p_rsrc_rec.organization_id || '/' ||
	      p_rsrc_rec.poc_trans_id ||'/'|| p_rsrc_rec.reverse_id);
	  gme_debug.put_line ('transQty: ' || p_rsrc_rec.resource_usage || ' ' || p_rsrc_rec.trans_qty_um ||
	    ' doc qty: ' || p_doc_qty || ' ' || p_doc_um);
	END IF;

	-- Possible validations
	-- Verify that the there is no other record with this trans_id
	-- Validate that this is valid trans_id
	-- Validate that it is for doc_type PROD and line_type 0
	-- Insert the data into the layers table
	IF (p_rsrc_rec.doc_type <> 'PROD') THEN
		-- Bug 5586577. Return with Success.
		-- x_return_status := FND_API.G_RET_STS_ERROR ;
		x_return_status := FND_API.G_RET_STS_SUCCESS ;
		--dbms_output.put_line ('Only PROD document allowed for outgoing layers');
		-- FND_MESSAGE.SET_NAME('GMF', 'GMF_NON_PROD_TRANS');
		-- FND_MSG_PUB.Add;
		RETURN;
	END IF;

	SELECT gmf_layer_id_s.nextval INTO l_layer_id FROM DUAL;
	l_remaining_ib_doc_qty := p_doc_qty;

	-- If this a reversed layer, do not comsume from it.
	l_delete_mark := 0;
	IF (p_rsrc_rec.reverse_id IS NOT NULL) THEN
		-- If the reverse transaction is alrady used in
		-- VIB details, get the quantity used in VIB details.
		-- We need to leave that much qty to reverse those VIB details later.
		BEGIN


			/*HALUTHRA BUG 8299247  Adding NVL for the nvl(-sum(consume_ib_doc_qty),0) and outer join for l.layer_id = v.consume_layer_id(+) */

			SELECT -sum(nvl(consume_ib_doc_qty,0)), l.ROWID
			INTO l_rev_consume_ib_doc_qty, l_rowid
			FROM   gmf_resource_layers l,
				gmf_batch_vib_details v
			WHERE l.poc_trans_id =  p_rsrc_rec.reverse_id and
				l.layer_id = v.consume_layer_id(+)
			GROUP BY l.ROWID;

			l_remaining_ib_doc_qty := l_rev_consume_ib_doc_qty;

			IF l_rev_consume_ib_doc_qty = 0 THEN
				l_delete_mark := 1;
			END IF;

			UPDATE gmf_resource_layers
			SET remaining_ib_doc_qty = 0,
				delete_mark = l_delete_mark
			WHERE
				ROWID = l_rowid;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
		END;
	END IF;

	-- ABS will handle reversal layers
	IF l_remaining_ib_doc_qty > 0 THEN
		-- If resource were consumed after the product was yielded, there are
		-- VIB details pointing to the NULL consumption layers. If possible,
		-- Update them to consume from this layer.
		FOR n IN c_null_vib_rows LOOP
		BEGIN
			IF l_remaining_ib_doc_qty = 0 THEN
				RAISE e_invalid_consumption;
			END IF;

        -- PK Bug 8472152 Commented next statement. Null vib records from past period should be updated as well

           /*		SELECT COUNT(*)
			INTO l_period_count
			  FROM gmf_organization_definitions god,
			       gmf_period_statuses gps,
			       gmf_fiscal_policies gfp,
			       cm_mthd_mst mthd
			 WHERE god.organization_id = n.organization_id
			   AND gfp.legal_entity_id = god.legal_entity_id
			   AND mthd.cost_type_id = gfp.cost_type_id
			   AND mthd.cost_type = 1 -- Actual costing method
			   AND mthd.prodcalc_type = 1 -- PMAC product cost
			   AND gps.legal_entity_id = gfp.legal_entity_id
			   AND gps.cost_type_id = gfp.cost_type_id
			   AND n.layer_date BETWEEN gps.start_date AND gps.end_date
			   AND p_rsrc_rec.trans_date BETWEEN gps.start_date AND gps.end_date;

			IF l_period_count = 0 THEN
				RAISE e_invalid_consumption;
			END IF;    */

			-- If resource usage is more then what is needed.
			IF n.consume_ib_doc_qty <= l_remaining_ib_doc_qty THEN

				UPDATE gmf_batch_vib_details
				SET consume_layer_id = l_layer_id
				WHERE ROWID = n.rowid;

				l_remaining_ib_doc_qty := l_remaining_ib_doc_qty - n.consume_ib_doc_qty;
			ELSE
				-- If resource usage is less then what is needed.
				-- Split the row into 2.
				-- Create another row with NULL layer for remaining quantity
				-- Create another row with NULL layer for remaining quantity
				-- First convert the consume quantity to primary UM.

				l_consume_ib_doc_qty := n.consume_ib_doc_qty - l_remaining_ib_doc_qty;

				l_consume_ib_pri_qty :=
					INV_CONVERT.INV_UM_CONVERT(
					    ITEM_ID       => 0
					  , PRECISION     => 5
					  , ORGANIZATION_ID => n.organization_id
					  , LOT_NUMBER     => NULL
					  , FROM_QUANTITY => l_consume_ib_doc_qty
					  , FROM_UNIT     => p_doc_um
					  , TO_UNIT       => p_rsrc_rec.trans_qty_um
					  , FROM_NAME     => NULL
					  , TO_NAME       => NULL
					);


				INSERT INTO gmf_batch_vib_details(
					prod_layer_id,
					prod_layer_pri_qty,
					consume_layer_id,
					consume_layer_date,
					line_type,
					requirement_id,
					finalize_ind,
					consume_ib_doc_qty,
					consume_ib_pri_qty,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date,
					last_update_login)
				VALUES(
					n.prod_layer_id,
					n.prod_layer_pri_qty,
					NULL,
					n.consume_layer_date,
					p_rsrc_rec.line_type, -- ???? inserting NULL
					n.requirement_id,
					0,
					l_consume_ib_doc_qty,
					l_consume_ib_pri_qty,
					p_rsrc_rec.created_by,
					sysdate,
					p_rsrc_rec.last_updated_by,
					sysdate,
					p_rsrc_rec.last_update_login);

				-- Consume the current ingredient quantity
				l_consume_ib_pri_qty :=
					INV_CONVERT.INV_UM_CONVERT(
					    ITEM_ID       => 0
					  , PRECISION     => 5
					  , ORGANIZATION_ID => n.organization_id
					  , LOT_NUMBER     => NULL
					  , FROM_QUANTITY => l_remaining_ib_doc_qty
					  , FROM_UNIT     => p_doc_um
					  , TO_UNIT       => p_rsrc_rec.trans_qty_um
					  , FROM_NAME     => NULL
					  , TO_NAME       => NULL
					);


				UPDATE gmf_batch_vib_details
				SET consume_layer_id = l_layer_id,
					consume_ib_pri_qty = l_consume_ib_pri_qty,
					consume_ib_doc_qty = l_remaining_ib_doc_qty
				WHERE ROWID = n.rowid;

				l_remaining_ib_doc_qty := 0;
			END IF;
		EXCEPTION
			WHEN e_invalid_consumption THEN
				NULL; -- Skip to the next row
		END;
		END LOOP;
	END IF;

	INSERT INTO gmf_resource_layers(
		layer_id,
		poc_trans_id,
		layer_doc_qty,
		layer_doc_um,
		remaining_ib_doc_qty,
		delete_mark,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login)
	VALUES(
		l_layer_id,
		p_rsrc_rec.poc_trans_id,
		p_doc_qty,
		p_doc_um,
		l_remaining_ib_doc_qty,
		l_delete_mark,
		p_rsrc_rec.created_by,
		sysdate,
		p_rsrc_rec.last_updated_by,
		sysdate,
		p_rsrc_rec.last_update_login);

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
		FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
		FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;
END;

-- Begin Additions for relayering concurrent request.
/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    log_message                                                           |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    log_message                                                           |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Parag Kanetkar Bug 8523022 30-OCT-2009 Added Prodedure                |
--+==========================================================================+
*/

  PROCEDURE log_message (
        p_table_name       IN   VARCHAR2,
        p_procedure_name   IN   VARCHAR2,
        p_parameters       IN   VARCHAR2,
        p_message          IN   VARCHAR2,
        p_error_type       IN   VARCHAR2
        ) IS
        PRAGMA autonomous_transaction;
     g_date_format       VARCHAR2(100) := 'YYYY-MM-DD HH24:MI:SS';
  BEGIN
        INSERT INTO gme_temp_exceptions (
                table_name,
                procedure_name,
                parameters,
                message,
                error_type,
                script_date
        ) VALUES (
                p_table_name,
                p_procedure_name,
                p_parameters,
                TO_CHAR (SYSDATE, g_date_format) || ':  ' || p_message,
                p_error_type,
                SYSDATE);
        COMMIT;
  EXCEPTION
        WHEN OTHERS THEN
                -- fnd_file.put_line(fnd_file.log, 'SQLERRM = '||SQLERRM);
                RAISE;
  END log_message;

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Delete_old_layers                                                     |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Delete_old_layers                                                     |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Parag Kanetkar Bug 8523022 30-OCT-2009 Added Prodedure                |
--+==========================================================================+
*/

  PROCEDURE Delete_old_layers (p_batch_id IN NUMBER) IS
    err_num            NUMBER;
    err_msg            VARCHAR2(100);

  BEGIN

    DELETE
    FROM gmf_layer_cost_details c
    WHERE
         c.layer_id IN
        (SELECT il.layer_id
        FROM gme_batch_header h, mtl_material_transactions t, gmf_incoming_material_layers il
        WHERE h.batch_id = p_batch_id
        AND    h.batch_id = t.transaction_source_id
        AND    t.transaction_source_type_id = 5
        AND    il.mmt_transaction_id           = t.transaction_id
        AND    il.mmt_organization_id          = t.organization_id
        );

    DELETE
    FROM gmf_incoming_material_layers il
    WHERE il.PSEUDO_LAYER_ID IS NOT NULL
    AND EXISTS
        (SELECT 1
        FROM gme_batch_header h, mtl_material_transactions t,
        gmf_incoming_material_layers im
        WHERE h.batch_id = p_batch_id
        AND    h.batch_id = t.transaction_source_id
        AND    t.transaction_source_type_id = 5
        AND    im.mmt_transaction_id           = t.transaction_id
        AND    im.mmt_organization_id          = t.organization_id
        AND    im.layer_id = il.PSEUDO_LAYER_ID
        );

    DELETE
    FROM gmf_incoming_material_layers il
    WHERE (il.mmt_organization_id, il.mmt_transaction_id) IN
        (SELECT distinct t.organization_id, t.transaction_id
        FROM gme_batch_header h, mtl_material_transactions t
        WHERE h.batch_id = p_batch_id
        AND    h.batch_id = t.transaction_source_id
        AND    t.transaction_source_type_id = 5
        );

    DELETE
    FROM gmf_outgoing_material_layers ol
    WHERE (ol.mmt_organization_id, ol.mmt_transaction_id) IN
        (SELECT distinct t.organization_id, t.transaction_id
        FROM gme_batch_header h, mtl_material_transactions t
        WHERE h.batch_id = p_batch_id
        AND    h.batch_id = t.transaction_source_id
        AND    t.transaction_source_type_id = 5
        );

    DELETE
    FROM gmf_resource_layers il
    WHERE il.poc_trans_id IN
        (SELECT t.poc_trans_id
        FROM gme_batch_header h, gme_resource_txns t
        WHERE h.batch_id = p_batch_id
        AND    h.batch_id = t.doc_id
        AND    t.doc_type = 'PROD'
        );

    DELETE
    FROM gmf_batch_vib_details bvd
    WHERE bvd.requirement_id IN
        (SELECT br.requirement_id
        FROM gmf_batch_requirements br, gme_batch_header h
        WHERE h.batch_id = p_batch_id
        AND   h.batch_id = br.batch_id
        );

    DELETE
    FROM gmf_batch_requirements br
    WHERE br.batch_id   IN
        (SELECT batch_id
        FROM gme_batch_header
        WHERE batch_id = p_batch_id
        )           ;

  EXCEPTION
        WHEN OTHERS THEN
         err_num := SQLCODE;
         err_msg := SUBSTRB(SQLERRM, 1, 100);
                GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'Delete_old_layers',
                p_parameters => err_num,
                p_message => 'Error deleting Old layer data for batch_id  = '||p_batch_id||' '||err_msg,
                p_error_type => 'I');
        fnd_file.put_line(fnd_file.log, to_char(SQLCODE)||': '||err_msg);
        fnd_file.put_line(fnd_file.log, 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
        fnd_file.put_line(fnd_file.log, '  Error Deleting Old layer data. ');
        fnd_file.put_line(fnd_file.log, 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
        RAISE;

  END Delete_old_layers;

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Delete_period_layers                                                  |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Delete_period_layers                                                  |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Parag Kanetkar Bug 8523022 30-OCT-2009 Added Prodedure                |
--+==========================================================================+
*/

  PROCEDURE Delete_period_layers (p_batch_id IN NUMBER, p_period_id IN NUMBER) IS
    err_num            NUMBER;
    err_msg            VARCHAR2(100);
    l_count            NUMBER;
    l_start_date       DATE;
    l_end_date         DATE;
    e_baddata          EXCEPTION;

    CURSOR cur_incoming_layers IS
      select count(*)
      FROM gme_batch_header h, mtl_material_transactions t, gmf_incoming_material_layers il
        WHERE h.batch_id = p_batch_id
          AND h.batch_id = t.transaction_source_id
          AND t.transaction_source_type_id = 5
          AND il.mmt_transaction_id           = t.transaction_id
          AND il.mmt_organization_id          = t.organization_id;

    -- Cusror selects prior period consumptions for yield in current period
    CURSOR CUR_VIB_DETAILS IS
     SELECT CONSUME_LAYER_ID, CONSUME_IB_DOC_QTY, CONSUME_IB_PRI_QTY, LINE_TYPE
       FROM gmf_batch_vib_details bvd
      WHERE bvd.CONSUME_LAYER_DATE < l_start_date
        AND bvd.prod_layer_id IN
            (SELECT il.layer_id
               FROM gme_batch_header h, mtl_material_transactions t, gmf_incoming_material_layers il
              WHERE h.batch_id = p_batch_id
                AND h.batch_id = t.transaction_source_id
                AND t.transaction_source_type_id = 5
                AND il.mmt_transaction_id           = t.transaction_id
                AND il.mmt_organization_id          = t.organization_id
                AND il.layer_date >= l_start_date
            );

      vib CUR_VIB_DETAILS%ROWTYPE;

  BEGIN

    select start_date, end_date INTO l_start_date, l_end_date
      from gmf_period_statuses
     where period_id = p_period_id;


    DELETE
    FROM gmf_layer_cost_details c
    WHERE  c.layer_id IN
        (SELECT il.layer_id
        FROM gme_batch_header h, mtl_material_transactions t, gmf_incoming_material_layers il
        WHERE h.batch_id = p_batch_id
          AND h.batch_id = t.transaction_source_id
          AND t.transaction_source_type_id = 5
          AND il.mmt_transaction_id           = t.transaction_id
          AND il.mmt_organization_id          = t.organization_id
          AND t.transaction_date >= l_start_date
        );

-- Add code to addback quantities to old layers here.
/* Pseudo code
Select all VIB details to be deleted. Vib details has these columns of interest.
PROD_LAYER_ID (These will be deleted.) CONSUME_LAYER_ID ( Quantity needs to be added to this layer)
CONSUME_LAYER_DATE ( Add quantity if CONSUME_LAYER_DATE is in a past period.
That is CONSUME_LAYER_DATE < (select start_date from gmf_period_statuses where period_id = p_period_id)
CONSUME_IB_DOC_QTY, CONSUME_IB_PRI_QTY.
Quanity CONSUME_IB_DOC_QTY needs to be added to REMAINING_IB_DOC_QTY of gmf_outgoing_material_layers or gmf_resource_layers.
Note that CONSUME_LAYER_ID could either belong to gmf_outgoing_material_layers or gmf_resource_layers.
LINE_TYPE will decide whether it is outgoing layer or resource layer.

 */
    FOR vib IN CUR_VIB_DETAILS LOOP

      IF vib.LINE_TYPE IN (-1, 2) THEN

        Update gmf_outgoing_material_layers
           set REMAINING_IB_DOC_QTY = REMAINING_IB_DOC_QTY + vib.CONSUME_IB_DOC_QTY
         where layer_id = vib.CONSUME_LAYER_ID;

      ELSIF   vib.LINE_TYPE = 0 THEN

        Update gmf_resource_layers
           set REMAINING_IB_DOC_QTY = REMAINING_IB_DOC_QTY + vib.CONSUME_IB_DOC_QTY
         where layer_id = vib.CONSUME_LAYER_ID;

      ELSE

        fnd_file.put_line(fnd_file.log, 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
        fnd_file.put_line(fnd_file.log, '  ERROR in ELSE condition deleting period layers. ');
        fnd_file.put_line(fnd_file.log, 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
        RAISE e_baddata;

      END IF;

    END LOOP;


-- Code to add quantities from VIB details ends here
    DELETE
    FROM gmf_batch_vib_details bvd
    WHERE bvd.prod_layer_id IN
        (SELECT il.layer_id
        FROM gme_batch_header h, mtl_material_transactions t, gmf_incoming_material_layers il
        WHERE h.batch_id = p_batch_id
          AND h.batch_id = t.transaction_source_id
          AND t.transaction_source_type_id = 5
          AND il.mmt_transaction_id           = t.transaction_id
          AND il.mmt_organization_id          = t.organization_id
          AND il.layer_date >= l_start_date
        );

    DELETE
    FROM gmf_outgoing_material_layers ol
    WHERE (ol.mmt_organization_id, ol.mmt_transaction_id) IN
        (SELECT distinct t.organization_id, t.transaction_id
        FROM gme_batch_header h, mtl_material_transactions t
        WHERE h.batch_id = p_batch_id
        AND   h.batch_id = t.transaction_source_id
        AND   t.transaction_source_type_id = 5
        AND   t.transaction_date >= l_start_date
        );

    DELETE
    FROM gmf_resource_layers il
    WHERE il.poc_trans_id IN
        (SELECT t.poc_trans_id
        FROM gme_batch_header h, gme_resource_txns t
        WHERE h.batch_id = p_batch_id
        AND    h.batch_id = t.doc_id
        AND    t.doc_type = 'PROD'
        AND   t.trans_date >= l_start_date
        );

    DELETE
    FROM gmf_incoming_material_layers il
    WHERE  il.layer_id IN
       (SELECT il1.layer_id
        FROM gme_batch_header h, mtl_material_transactions t, gmf_incoming_material_layers il1
        WHERE h.batch_id = p_batch_id
          AND h.batch_id = t.transaction_source_id
          AND t.transaction_source_type_id = 5
          AND il1.mmt_transaction_id           = t.transaction_id
          AND il1.mmt_organization_id          = t.organization_id
          AND il1.layer_date >= l_start_date
        );


    -- delete conditionally if no prior incoming layer exists.Or delete requirements if running for first period?

    OPEN cur_incoming_layers;
    FETCH cur_incoming_layers into l_count;
    Close cur_incoming_layers;

    IF (l_count = 0) THEN

      DELETE
        FROM gmf_batch_requirements br
       WHERE br.batch_id   IN
            (SELECT batch_id
               FROM gme_batch_header
              WHERE batch_id = p_batch_id
            );

    END IF;

  EXCEPTION
        WHEN OTHERS THEN
         err_num := SQLCODE;
         err_msg := SUBSTRB(SQLERRM, 1, 100);
                GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'Delete_period_layers',
                p_parameters => err_num,
                p_message => 'Error deleting Old layer data for batch_id  = '||p_batch_id||' Period id '||p_period_id||
                ' '||err_msg,p_error_type => 'I');
        fnd_file.put_line(fnd_file.log, to_char(SQLCODE)||': '||err_msg);
        fnd_file.put_line(fnd_file.log, 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
        fnd_file.put_line(fnd_file.log, '  Error Deleting Old layer data,  Please ROLLBACK. ');
        fnd_file.put_line(fnd_file.log, 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
        RAISE;

  END Delete_period_layers;

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Recreate_outgoing_layers                                              |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Recreate_outgoing_layers                                              |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Parag Kanetkar Bug 8523022 30-OCT-2009 Added Prodedure                |
--+==========================================================================+
*/

  PROCEDURE Recreate_outgoing_layers(p_batch_id IN NUMBER, p_period_id IN NUMBER) IS

    err_num            NUMBER;
    err_msg            VARCHAR2(100);
    g_mig_date  DATE := SYSDATE;
    g_date_format       VARCHAR2(100) := 'YYYY-MM-DD HH24:MI:SS';
    l_start_date        DATE ;
    l_end_date          DATE;
    l_batch_id      NUMBER := p_batch_id;
    l_period_id     NUMBER := p_period_id;

        CURSOR c_mig_trans IS
           select *
           from
         (
         SELECT mmt.rowid r_id, mmt.transaction_id as trans_id, mmt.transaction_date as trans_date,
                md.line_type as line_type, md.dtl_um as doc_um, 'M' as type, mmt.primary_quantity as trans_qty,
                tp.transaction_id2 as reverse_id
           from mtl_material_transactions mmt,
                gme_transaction_pairs tp,
                gme_material_details md,
                gme_batch_header b
        where md.batch_id = b.batch_id
          and b.batch_id  = l_batch_id
          and mmt.transaction_source_type_id = 5
          and mmt.transaction_source_id      = b.batch_id
          and mmt.trx_source_line_id         = md.material_detail_id
          and mmt.inventory_item_id          = md.inventory_item_id
          and mmt.organization_id            = md.organization_id
          and md.line_type                   IN (-1, 2)
          and tp.transaction_id1(+)          = mmt.transaction_id
          AND mmt.transaction_date >= l_start_date
          AND mmt.transaction_date <= l_end_date
          and tp.pair_type(+)                = 1
        )
        ORDER BY trans_date, line_type,
                   DECODE (line_type,
                   1, DECODE ((  ABS (DECODE (trans_qty, 0, 1, trans_qty))
                             / DECODE (trans_qty, 0, 1, trans_qty)
                            ),
                            1, trans_id,
                            DECODE (reverse_id,
                                    NULL, trans_id,
                                    reverse_id + .5
                                   )
                           ),
                   trans_id
                   );


        mt      mtl_material_transactions%ROWTYPE;
        rt      gme_resource_txns%ROWTYPE;
        l_lot_number VARCHAR2(100);

        x_return_status VARCHAR2(10);
        x_msg_count     NUMBER;
        i               NUMBER;
        x_msg_data      VARCHAR2(1000);
        l_count         PLS_INTEGER;
        l_il_count      PLS_INTEGER := 0;
        l_rl_count      PLS_INTEGER := 0;
        l_ol_count      PLS_INTEGER := 0;
        l_doc_qty       NUMBER;
        e_uom_conv_failure      EXCEPTION;

        l_trans_rec  GMF_LAYERS.TRANS_REC_TYPE;
  BEGIN
        select start_date, end_date INTO l_start_date, l_end_date
          from gmf_period_statuses
         where period_id = p_period_id;

        GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'None',
                p_parameters => 'None',
                p_message => 'Started the migration Recreate_outgoing_layers for the batch',
                p_error_type => 'I');

        GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'None',
                p_parameters => 'None',
                p_message => 'Profile GMF_USE_VIB_FOR_ACOST = '||FND_PROFILE.VALUE ('GMF_USE_VIB_FOR_ACOST'),
                p_error_type => 'I');

        GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'None',
                p_parameters => 'None',
                p_message => 'Profile GMF_USE_ITEM_STEP_DEPENDENCIES = '||FND_PROFILE.VALUE ('GMF_USE_ITEM_STEP_DEPENDENCIES'),
                p_error_type => 'I');


        FOR t IN c_mig_trans LOOP
        BEGIN

                x_msg_count := 0;
                x_return_status := 0;

                fnd_msg_pub.initialize;

                  FOR trans_rec in
                  (
                        SELECT
                                  mmt.transaction_id
                                , mmt.transaction_source_type_id
                                , mmt.transaction_action_id
                                , mmt.transaction_type_id
                                , mmt.inventory_item_id
                                , mmt.organization_id
                                , mtln.lot_number
                                , mmt.transaction_date
                                , nvl(mtln.primary_quantity, mmt.primary_quantity) as primary_quantity /* Doc Qty */
                                , msi.primary_uom_code
                                , mmt.transaction_source_id -- batch_id
                                , mmt.trx_source_line_id    -- line_id
                                , mmt.last_updated_by
                                , mmt.created_by
                                , mmt.last_update_login
                        FROM mtl_material_transactions mmt, mtl_transaction_lot_numbers mtln, mtl_system_items_b msi
                        WHERE
                                mmt.ROWID = t.r_id
                        AND     mtln.transaction_id (+) = mmt.transaction_id
                        AND     msi.inventory_item_id   = mmt.inventory_item_id
                        AND     msi.organization_id     = mmt.organization_id
                  )
                  LOOP

                        l_trans_rec.transaction_id              := trans_rec.transaction_id;
                        l_trans_rec.transaction_source_type_id  := trans_rec.transaction_source_type_id;
                        l_trans_rec.transaction_action_id       := trans_rec.transaction_action_id;
                        l_trans_rec.transaction_type_id         := trans_rec.transaction_type_id;
                        l_trans_rec.inventory_item_id           := trans_rec.inventory_item_id;
                        l_trans_rec.organization_id             := trans_rec.organization_id;
                        l_trans_rec.lot_number                  := trans_rec.lot_number;
                        l_trans_rec.transaction_date            := trans_rec.transaction_date;
                        l_trans_rec.primary_quantity            := trans_rec.primary_quantity;
                        l_trans_rec.primary_uom                 := trans_rec.primary_uom_code;
                        l_trans_rec.doc_uom                     := t.doc_um;
                        l_trans_rec.transaction_source_id       := trans_rec.transaction_source_id;
                        l_trans_rec.trx_source_line_id          := trans_rec.trx_source_line_id;
                        l_trans_rec.reverse_id                  := t.reverse_id;
                        l_trans_rec.line_type                   := t.line_type;
                        l_trans_rec.last_updated_by             := trans_rec.last_updated_by;
                        l_trans_rec.created_by                  := trans_rec.created_by;
                        l_trans_rec.last_update_login           := trans_rec.last_update_login;

                                SELECT count(*)
                                INTO l_count
                                FROM gmf_outgoing_material_layers
                                WHERE
                                        mmt_transaction_id = trans_rec.transaction_id
                                AND     ((lot_number is not null and lot_number = trans_rec.lot_number)
                                         OR
                                         (lot_number is null))
                                ;


                        IF l_count = 0 THEN
                                -- Convert transaction qty in the document UOM

                                BEGIN


                                l_trans_rec.doc_qty :=
                                        INV_CONVERT.INV_UM_CONVERT(
                                            ITEM_ID         => trans_rec.inventory_item_id
                                          , PRECISION       => 5
                                          , ORGANIZATION_ID => trans_rec.organization_id
                                          , LOT_NUMBER      => trans_rec.lot_number
                                          , FROM_QUANTITY   => trans_rec.primary_quantity
                                          , FROM_UNIT       => trans_rec.primary_uom_code
                                          , TO_UNIT         => t.doc_um
                                          , FROM_NAME       => NULL
                                          , TO_NAME         => NULL
                                        );

                                EXCEPTION
                                        WHEN OTHERS THEN
                                                -- fnd_file.put_line ('Error in UOM conversion');
                                                -- fnd_file.put_line ('From UOM = '||mt.trans_um||', To UOM = '||t.doc_um);
                                                GMF_LAYERS.log_message (
                                                        p_table_name => 'GMF_BATCH_VIB_DETAILS',
                                                        p_procedure_name => 'None',
                                                        p_parameters => 'Trans ID = '||to_char(trans_rec.transaction_id)||
                                                                        ' From UOM = '||trans_rec.primary_uom_code||', To UOM = '||t.doc_um,
                                                        p_message => 'UOM Conversion error',
                                                        p_error_type => 'E');
                                                RAISE e_uom_conv_failure;
                                END;

                                        IF t.line_type = -1 THEN
                                                l_trans_rec.doc_qty := -l_trans_rec.doc_qty;
                                        END IF;

                                        gmf_layers.Create_outgoing_Layers
                                        ( p_api_version   => 1.0,
                                          p_init_msg_list => FND_API.G_FALSE,
                                          p_tran_rec      => l_trans_rec,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data);

                                        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                                --
                                                -- fnd_file.put_line ('Error creating outgoing layer : '||to_char (mt.trans_id));
                                                GMF_LAYERS.log_message (
                                                        p_table_name => 'GMF_BATCH_VIB_DETAILS',
                                                        p_procedure_name => 'None',
                                                        p_parameters => 'Trans ID = '||to_char(trans_rec.transaction_id),
                                                        p_message => 'Error creating outgoing layer',
                                                        p_error_type => 'E');
                                                FOR i IN 1..fnd_msg_pub.count_msg
                                                LOOP
                                                        GMF_LAYERS.log_message (
                                                                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                                                                p_procedure_name => 'None',
                                                                p_parameters => 'Trans ID = '||to_char(trans_rec.transaction_id),
                                                                p_message => fnd_msg_pub.get_detail (i, NULL),
                                                                p_error_type => 'E');
                                                END LOOP;
                                        ELSE
                                                l_ol_count := l_ol_count + 1;
                                        END IF;
                        END IF;
                  END LOOP;
        EXCEPTION
                WHEN e_uom_conv_failure THEN
                        NULL;
        END;
        END LOOP;


        GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'None',
                p_parameters => 'Incoming Layers = '||to_char(l_il_count)||
                                ', Outgoing Layers = '||to_char(l_ol_count)||
                                ', Resource Layers = '||to_char(l_rl_count),
                p_message => 'Completed the migration to Recreate_outgoing_layers for the batch',
                p_error_type => 'I');



  END Recreate_outgoing_layers;

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Recreate_resource_layers                                              |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Recreate_resource_layers                                              |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Parag Kanetkar Bug 8523022 30-OCT-2009 Added Prodedure                |
--+==========================================================================+
*/

  PROCEDURE Recreate_resource_layers(p_batch_id IN NUMBER, p_period_id IN NUMBER) IS

    err_num            NUMBER;
    err_msg            VARCHAR2(100);
    g_mig_date  DATE := SYSDATE;
    g_date_format       VARCHAR2(100) := 'YYYY-MM-DD HH24:MI:SS';
    l_start_date        DATE ;
    l_end_date          DATE;
    l_batch_id      NUMBER := p_batch_id;  -- Replace this batch-id with proper batch-id.

        CURSOR c_mig_trans IS
         select *
           from
         ( SELECT rt.rowid r_id, rt.poc_trans_id as trans_id, rt.trans_date, rt.line_type as line_type, rt.trans_qty_um as doc_um, 'R' as type,
                  rt.resource_usage as trans_qty, rt.reverse_id
             FROM gme_resource_txns rt, gme_batch_header b
            WHERE rt.doc_type = 'PROD'
              AND rt.doc_id = b.batch_id
              AND rt.completed_ind = 1
              AND rt.delete_mark = 0
              AND rt.doc_id = l_batch_id
              AND rt.trans_date >= l_start_date
              AND rt.trans_date <= l_end_date
         )
        ORDER BY trans_date, line_type,
                   DECODE (line_type,
                   1, DECODE ((  ABS (DECODE (trans_qty, 0, 1, trans_qty))
                             / DECODE (trans_qty, 0, 1, trans_qty)
                            ),
                            1, trans_id,
                            DECODE (reverse_id,
                                    NULL, trans_id,
                                    reverse_id + .5
                                   )
                           ),
                   trans_id
                   );

        mt      mtl_material_transactions%ROWTYPE;
        rt      gme_resource_txns%ROWTYPE;
        l_lot_number VARCHAR2(100);

        x_return_status VARCHAR2(10);
        x_msg_count     NUMBER;
        i               NUMBER;
        x_msg_data      VARCHAR2(1000);
        l_count         PLS_INTEGER;
        l_il_count      PLS_INTEGER := 0;
        l_rl_count      PLS_INTEGER := 0;
        l_ol_count      PLS_INTEGER := 0;
        l_doc_qty       NUMBER;
        e_uom_conv_failure      EXCEPTION;

        l_trans_rec  GMF_LAYERS.TRANS_REC_TYPE;
  BEGIN

        select start_date, end_date INTO l_start_date, l_end_date
          from gmf_period_statuses
         where period_id = p_period_id;

        GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'None',
                p_parameters => 'None',
                p_message => 'Started the migration to Recreate_resource_layers for the batch',
                p_error_type => 'I');

        GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'None',
                p_parameters => 'None',
                p_message => 'Profile GMF_USE_VIB_FOR_ACOST = '||FND_PROFILE.VALUE ('GMF_USE_VIB_FOR_ACOST'),
                p_error_type => 'I');

        GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'None',
                p_parameters => 'None',
                p_message => 'Profile GMF_USE_ITEM_STEP_DEPENDENCIES = '||FND_PROFILE.VALUE ('GMF_USE_ITEM_STEP_DEPENDENCIES'),
                p_error_type => 'I');


        FOR t IN c_mig_trans LOOP
        BEGIN

                x_msg_count := 0;
                x_return_status := 0;

                fnd_msg_pub.initialize;

                        SELECT * INTO rt
                        FROM gme_resource_txns
                        WHERE
                                ROWID = t.r_id;

                        SELECT count(*)
                        INTO l_count
                        FROM gmf_resource_layers
                        WHERE
                                poc_trans_id = rt.poc_trans_id;

                        IF l_count = 0 THEN
                                GMF_LAYERS.Create_Resource_Layers(
                                        1.0,
                                        FND_API.G_FALSE,
                                        rt,
                                        rt.resource_usage,
                                        rt.trans_qty_um,
                                        x_return_status,
                                        x_msg_count,
                                        x_msg_data);

                                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                        -- fnd_file.put_line ('Error creating resource layer : '||to_char (rt.poc_trans_id));
                                        GMF_LAYERS.log_message (
                                                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                                                p_procedure_name => 'None',
                                                p_parameters => 'POC Trans ID = '||to_char(rt.poc_trans_id),
                                                p_message => 'Error creating resource layer',
                                                p_error_type => 'E');
                                        FOR i IN 1..fnd_msg_pub.count_msg LOOP
                                                GMF_LAYERS.log_message (
                                                        p_table_name => 'GMF_BATCH_VIB_DETAILS',
                                                        p_procedure_name => 'None',
                                                        p_parameters => 'POC Trans ID = '||to_char(rt.poc_trans_id),
                                                        p_message => fnd_msg_pub.get_detail (i, NULL),
                                                        p_error_type => 'E');
                                        END LOOP;
                                ELSE
                                        l_rl_count := l_rl_count + 1;
                                END IF;
                        END IF;

        EXCEPTION
                WHEN e_uom_conv_failure THEN
                        NULL;
        END;
        END LOOP;

        GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'None',
                p_parameters => 'Incoming Layers = '||to_char(l_il_count)||
                                ', Outgoing Layers = '||to_char(l_ol_count)||
                                ', Resource Layers = '||to_char(l_rl_count),
                p_message => 'Completed the migration to Recreate_resource_layers for the batch',
                p_error_type => 'I');

  END Recreate_resource_layers;

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Recreate_incoming_layers                                              |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Recreate_incoming_layers                                              |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Parag Kanetkar Bug 8523022 30-OCT-2009 Added Prodedure                |
--+==========================================================================+
*/

  PROCEDURE Recreate_incoming_layers(p_batch_id IN NUMBER, p_period_id IN NUMBER) IS
    err_num            NUMBER;
    err_msg            VARCHAR2(100);
    g_mig_date  DATE := SYSDATE;
    g_date_format       VARCHAR2(100) := 'YYYY-MM-DD HH24:MI:SS';
    l_start_date        DATE ;
    l_end_date          DATE ;
    l_batch_id      NUMBER := p_batch_id;  -- Replace this batch-id with proper batch-id.

        CURSOR c_mig_trans IS
           select *
           from
         (
         SELECT mmt.rowid r_id, mmt.transaction_id as trans_id, mmt.transaction_date as trans_date,
                md.line_type as line_type, md.dtl_um as doc_um, 'M' as type, mmt.primary_quantity as trans_qty,
                tp.transaction_id2 as reverse_id
           from mtl_material_transactions mmt,
                gme_transaction_pairs tp,
                gme_material_details md,
                gme_batch_header b
        where md.batch_id = b.batch_id
          and b.batch_id  = l_batch_id
          and mmt.transaction_source_type_id = 5
          and mmt.transaction_source_id      = b.batch_id
          and mmt.trx_source_line_id         = md.material_detail_id
          and mmt.inventory_item_id          = md.inventory_item_id
          and mmt.organization_id            = md.organization_id
          and md.line_type                   = 1
          and tp.transaction_id1(+)          = mmt.transaction_id
          AND mmt.transaction_date >= l_start_date
          AND mmt.transaction_date <= l_end_date
          and tp.pair_type(+)                = 1
        )
        ORDER BY trans_date, line_type,
                   DECODE (line_type,
                   1, DECODE ((  ABS (DECODE (trans_qty, 0, 1, trans_qty))
                             / DECODE (trans_qty, 0, 1, trans_qty)
                            ),
                            1, trans_id,
                            DECODE (reverse_id,
                                    NULL, trans_id,
                                    reverse_id + .5
                                   )
                           ),
                   trans_id
                   );



        mt      mtl_material_transactions%ROWTYPE;
        rt      gme_resource_txns%ROWTYPE;
        l_lot_number VARCHAR2(100);

        x_return_status VARCHAR2(10);
        x_msg_count     NUMBER;
        i               NUMBER;
        x_msg_data      VARCHAR2(1000);
        l_count         PLS_INTEGER;
        l_il_count      PLS_INTEGER := 0;
        l_rl_count      PLS_INTEGER := 0;
        l_ol_count      PLS_INTEGER := 0;
        l_doc_qty       NUMBER;
        e_uom_conv_failure      EXCEPTION;

        l_trans_rec  GMF_LAYERS.TRANS_REC_TYPE;
  BEGIN

        select start_date, end_date INTO l_start_date, l_end_date
          from gmf_period_statuses
         where period_id = p_period_id;

        GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'None',
                p_parameters => 'None',
                p_message => 'Started the migration to Recreate_incoming_layers for the batch',
                p_error_type => 'I');

        GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'None',
                p_parameters => 'None',
                p_message => 'Profile GMF_USE_VIB_FOR_ACOST = '||FND_PROFILE.VALUE ('GMF_USE_VIB_FOR_ACOST'),
                p_error_type => 'I');

        GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'None',
                p_parameters => 'None',
                p_message => 'Profile GMF_USE_ITEM_STEP_DEPENDENCIES = '||FND_PROFILE.VALUE ('GMF_USE_ITEM_STEP_DEPENDENCIES'),
                p_error_type => 'I');


        FOR t IN c_mig_trans LOOP
        BEGIN

                x_msg_count := 0;
                x_return_status := 0;

                fnd_msg_pub.initialize;

                  FOR trans_rec in
                  (
                        SELECT
                                  mmt.transaction_id
                                , mmt.transaction_source_type_id
                                , mmt.transaction_action_id
                                , mmt.transaction_type_id
                                , mmt.inventory_item_id
                                , mmt.organization_id
                                , mtln.lot_number
                                , mmt.transaction_date
                                , nvl(mtln.primary_quantity, mmt.primary_quantity) as primary_quantity /* Doc Qty */
                                , msi.primary_uom_code
                                , mmt.transaction_source_id -- batch_id
                                , mmt.trx_source_line_id    -- line_id
                                , mmt.last_updated_by
                                , mmt.created_by
                                , mmt.last_update_login
                        FROM mtl_material_transactions mmt, mtl_transaction_lot_numbers mtln, mtl_system_items_b msi
                        WHERE
                                mmt.ROWID = t.r_id
                        AND     mtln.transaction_id (+) = mmt.transaction_id
                        AND     msi.inventory_item_id   = mmt.inventory_item_id
                        AND     msi.organization_id     = mmt.organization_id
                  )
                  LOOP

                        l_trans_rec.transaction_id              := trans_rec.transaction_id;
                        l_trans_rec.transaction_source_type_id  := trans_rec.transaction_source_type_id;
                        l_trans_rec.transaction_action_id       := trans_rec.transaction_action_id;
                        l_trans_rec.transaction_type_id         := trans_rec.transaction_type_id;
                        l_trans_rec.inventory_item_id           := trans_rec.inventory_item_id;
                        l_trans_rec.organization_id             := trans_rec.organization_id;
                        l_trans_rec.lot_number                  := trans_rec.lot_number;
                        l_trans_rec.transaction_date            := trans_rec.transaction_date;
                        l_trans_rec.primary_quantity            := trans_rec.primary_quantity;
                        l_trans_rec.primary_uom                 := trans_rec.primary_uom_code;
                        l_trans_rec.doc_uom                     := t.doc_um;
                        l_trans_rec.transaction_source_id       := trans_rec.transaction_source_id;
                        l_trans_rec.trx_source_line_id          := trans_rec.trx_source_line_id;
                        l_trans_rec.reverse_id                  := t.reverse_id;
                        l_trans_rec.line_type                   := t.line_type;
                        l_trans_rec.last_updated_by             := trans_rec.last_updated_by;
                        l_trans_rec.created_by                  := trans_rec.created_by;
                        l_trans_rec.last_update_login           := trans_rec.last_update_login;

                        IF t.line_type = 1 THEN
                                SELECT count(*)
                                INTO l_count
                                FROM gmf_incoming_material_layers
                                WHERE
                                        mmt_transaction_id = trans_rec.transaction_id
                                AND     ((lot_number is not null and lot_number = trans_rec.lot_number)
                                         OR
                                         (lot_number is null))
                                ;
                        ELSE
                                SELECT count(*)
                                INTO l_count
                                FROM gmf_outgoing_material_layers
                                WHERE
                                        mmt_transaction_id = trans_rec.transaction_id
                                AND     ((lot_number is not null and lot_number = trans_rec.lot_number)
                                         OR
                                         (lot_number is null))
                                ;
                        END IF;


                        IF l_count = 0 THEN
                                -- Convert transaction qty in the document UOM

                                BEGIN

                                l_trans_rec.doc_qty :=
                                        INV_CONVERT.INV_UM_CONVERT(
                                            ITEM_ID         => trans_rec.inventory_item_id
                                          , PRECISION       => 5
                                          , ORGANIZATION_ID => trans_rec.organization_id
                                          , LOT_NUMBER      => trans_rec.lot_number
                                          , FROM_QUANTITY   => trans_rec.primary_quantity
                                          , FROM_UNIT       => trans_rec.primary_uom_code
                                          , TO_UNIT         => t.doc_um
                                          , FROM_NAME       => NULL
                                          , TO_NAME         => NULL
                                        );

                                EXCEPTION
                                        WHEN OTHERS THEN
                                                -- fnd_file.put_line ('Error in UOM conversion');
                                                -- fnd_file.put_line ('From UOM = '||mt.trans_um||', To UOM = '||t.doc_um);
                                                GMF_LAYERS.log_message (
                                                        p_table_name => 'GMF_BATCH_VIB_DETAILS',
                                                        p_procedure_name => 'None',
                                                        p_parameters => 'Trans ID = '||to_char(trans_rec.transaction_id)||
                                                                        ' From UOM = '||trans_rec.primary_uom_code||', To UOM = '||t.doc_um,
                                                        p_message => 'UOM Conversion error',
                                                        p_error_type => 'E');
                                                RAISE e_uom_conv_failure;
                                END;

                                        gmf_layers.Create_Incoming_Layers
                                        ( p_api_version   => 1.0,
                                          p_init_msg_list => FND_API.G_FALSE,
                                          p_tran_rec      => l_trans_rec,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data
                                        );

                                        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                                -- fnd_file.put_line ('Error creating incoming layer : '||to_char (mt.trans_id));
                                                GMF_LAYERS.log_message (
                                                        p_table_name => 'GMF_BATCH_VIB_DETAILS',
                                                        p_procedure_name => 'None',
                                                        p_parameters => 'Trans ID = '||to_char(trans_rec.transaction_id),
                                                        p_message => 'Error creating incoming layer',
                                                        p_error_type => 'E');
                                                FOR i IN 1..fnd_msg_pub.count_msg LOOP
                                                        GMF_LAYERS.log_message (
                                                                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                                                                p_procedure_name => 'None',
                                                                p_parameters => 'Trans ID = '||to_char(trans_rec.transaction_id),
                                                                p_message => fnd_msg_pub.get_detail (i, NULL),
                                                                p_error_type => 'E');
                                                END LOOP;
                                        ELSE
                                                l_il_count := l_il_count + 1;
                                        END IF;
                        END IF;
                  END LOOP;
        EXCEPTION
                WHEN e_uom_conv_failure THEN
                        NULL;
        END;
        END LOOP;

        GMF_LAYERS.log_message (
                p_table_name => 'GMF_BATCH_VIB_DETAILS',
                p_procedure_name => 'None',
                p_parameters => 'Incoming Layers = '||to_char(l_il_count)||
                                ', Outgoing Layers = '||to_char(l_ol_count)||
                                ', Resource Layers = '||to_char(l_rl_count),
                p_message => 'Completed the migration to Recreate_incoming_layers for the batch',
                p_error_type => 'I');

  END Recreate_incoming_layers;

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Finalize_batch                                                        |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Finalize_batch                                                        |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Parag Kanetkar Bug 8523022 30-OCT-2009 Added Prodedure                |
--+==========================================================================+
*/

  PROCEDURE Finalize_batch (p_batch_id IN NUMBER, p_period_id IN NUMBER) IS

    l_batch_id      NUMBER := p_batch_id;  -- Replace this batch-id with proper batch-id.
    x_return_status VARCHAR2(10);
    x_msg_count     NUMBER;
    i               NUMBER;
    x_msg_data      VARCHAR2(1000);
    l_start_date        DATE ;
    l_end_date          DATE ;

    CURSOR c_mig_closed_batches IS
       SELECT batch_id
       FROM gme_batch_header b
      WHERE b.batch_status      = 4
        AND b.batch_id  = l_batch_id
        AND b.batch_close_date >= l_start_date
        AND b.batch_close_date <= l_end_date;
  BEGIN

        select start_date, end_date INTO l_start_date, l_end_date
          from gmf_period_statuses
         where period_id = p_period_id;

      FOR cls IN c_mig_closed_batches LOOP
        BEGIN
                x_msg_count := 0;
                x_return_status := 0;

                GMF_VIB.Finalize_VIB_Details(
                                1.0,
                                FND_API.G_FALSE,
                                cls.batch_id,
                                x_return_status,
                                x_msg_count,
                                x_msg_data);

                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        GMF_LAYERS.log_message (
                                        p_table_name => 'GMF_BATCH_VIB_DETAILS',
                                        p_procedure_name => 'None',
                                        p_parameters => 'Batch ID = '||to_char(cls.batch_id),
                                        p_message => 'Error creating finalization layers',
                                        p_error_type => 'E');

                FOR i IN 1..fnd_msg_pub.count_msg LOOP
                        GMF_LAYERS.log_message (
                                        p_table_name => 'GMF_BATCH_VIB_DETAILS',
                                        p_procedure_name => 'None',
                                                        p_parameters => 'Batch ID = '||to_char(cls.batch_id),
                                                        p_message => fnd_msg_pub.get_detail (i, NULL),
                                                        p_error_type => 'E');
                END LOOP;
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        NULL;
        END;
     END LOOP;
                        GMF_LAYERS.log_message (
                                        p_table_name => 'GMF_BATCH_VIB_DETAILS',
                                        p_procedure_name => 'None',
                                        p_parameters => 'Batch ID = '||to_char(p_batch_id),
                                        p_message => 'Layer Finalization completed',
                                        p_error_type => 'E');

  END Finalize_batch;

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Relayer                                                               |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Relayer                                                               |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Parag Kanetkar Bug 8523022 30-OCT-2009 Added Prodedure                |
--+==========================================================================+
*/

  PROCEDURE Relayer( errbuf             OUT NOCOPY VARCHAR2,
                       retcode            OUT NOCOPY VARCHAR2,
                       p_legal_entity_id  IN NUMBER,
                       p_calendar_code    IN  VARCHAR2,
                       p_period_code      IN  VARCHAR2,
                       p_cost_type_id     IN  NUMBER,
                       p_org_id           IN  NUMBER DEFAULT NULL,
                       p_batch_id         IN  NUMBER DEFAULT NULL) IS

    l_legal_entity_id NUMBER       :=  p_legal_entity_id;
    l_period          varchar2(10) :=  p_period_code;
    l_calendar        varchar2(10) :=  p_calendar_code;
    l_cost_type       NUMBER       :=  p_cost_type_id;
    l_org_id          NUMBER       :=  p_org_id;
    l_batch_id        NUMBER       :=  p_batch_id;
    l_periodid        Number;
    l_batchstatus     NUMBER;
    l_startdate       DATE;
    l_enddate         DATE;
    l_count           NUMBER;
    l_type            NUMBER;
    l_posted_cnt      NUMBER;
    l_ret_status      BOOLEAN;

    TYPE batch_rec_type IS RECORD
    ( batch_id          NUMBER
    , batch_no          VARCHAR2(32)
    , batch_status      NUMBER
    , actual_start_date DATE
    , batch_close_date  DATE
    );

    TYPE batch_cursor_type IS REF CURSOR RETURN batch_rec_type;

    rec batch_rec_type;
    cur_batches batch_cursor_type;

    /* Bug 9417673 - GMF_LAYERS PACKAGE FAILS WITH ORA-1722 */
    CURSOR cur_get_periodid IS
                SELECT gps.period_id,
                       gps.start_date,
                       gps.end_date
                  FROM  gmf_period_statuses gps
                  WHERE gps.cost_type_id   = l_cost_type
                    AND gps.calendar_code   = l_calendar
                    AND gps.period_code     = l_period
                    AND gps.legal_entity_id = l_legal_entity_id;

    CURSOR Cur_cost_type IS
                SELECT cmm.cost_type
                  FROM gmf_fiscal_policies gfp, cm_mthd_mst cmm
                 WHERE gfp.cost_type_id = cmm.cost_type_id
                   AND gfp.legal_entity_id = l_legal_entity_id
                   AND cmm.cost_type <> 6
                 UNION
                SELECT cmm2.cost_type
                  FROM gmf_fiscal_policies gfp, cm_mthd_mst cmm1,cm_mthd_mst cmm2
                 WHERE gfp.cost_type_id = cmm1.cost_type_id
                   AND gfp.legal_entity_id = l_legal_entity_id
                   AND cmm1.cost_type = 6
                   AND cmm1.default_lot_cost_type_id = cmm2.cost_type_id;

    CURSOR Cur_OPM_costed IS
      select Count(*) from mtl_material_transactions
      where transaction_date >= l_startdate
        and transaction_date <= l_enddate
        and opm_costed_flag IS NULL
        and organization_id IN (SELECT organization_id
                   FROM gmf_organization_definitions
                  WHERE legal_entity_id = l_legal_entity_id);



  BEGIN

    fnd_file.put_line(fnd_file.log, ' ========================================================' );
    fnd_file.put_line(fnd_file.log, ' Starting Migration of layer data at '|| to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, 'Request Parameters le id '||l_legal_entity_id||' Cost Calendar '||l_calendar||' Period '||
                                    l_period||' CostTypId ' ||l_cost_type||' Batch Org id '||l_org_id||' Batch id'||l_batch_id);
    fnd_file.put_line(fnd_file.log, ' ========================================================' );

    OPEN cur_get_periodid;
    FETCH cur_get_periodid INTO l_periodid, l_startdate, l_enddate;
    CLOSE cur_get_periodid;

     fnd_file.put_line(fnd_file.log, 'Period ID  '||l_periodid||' Period Start Date '||to_char(l_startdate,'DD-MON-YYYY HH24:MI:SS')
                       ||' Period End Date '||to_char(l_enddate,'DD-MON-YYYY HH24:MI:SS'));

    IF l_periodid IS NULL THEN
      fnd_file.put_line(fnd_file.log, 'Period not found ');
      fnd_file.put_line
         (fnd_file.log,'Can not Continue. Returning without migrating data' );

      l_ret_status := fnd_concurrent.set_completion_status('ERROR','Error Period Not Found.');
      RETURN;
    END IF;

    /* write period validation logic here. If period passed in is already accounted then do nothing
       and return

       Validation logic
       If for legal entity, and calendar , period passed in if
       a) fiscal policy cost method is actual costing OR
          fiscal policy cost method is lot actual costing with alternate cost method of actual costing

       AND

       b) if any mmt record for organizations belonging to le for date range of entire period has OPM costed flag as
          NULL

       If a) AND b) is TRUE do nothing and Return.

       */

    -- Period Validation Logic Begins here
    OPEN Cur_cost_type;
    FETCH Cur_cost_type INTO l_type;
    CLOSE Cur_cost_type;

    fnd_file.put_line
         (fnd_file.log,'Fiscal policy Cost Type (Alternate for Lot Costing) Actual=1 Standard=0 Is '||l_type );

    IF (l_type = 1) THEN

      OPEN  Cur_OPM_costed;
      FETCH Cur_OPM_costed INTO l_posted_cnt;
      CLOSE Cur_OPM_costed;

      fnd_file.put_line
         (fnd_file.log,'Posted Transaction Count '||l_posted_cnt );

      IF l_posted_cnt > 0 THEN

        fnd_file.put_line
         (fnd_file.log,'Cost type Or Default Lot cost type is Actual Costing and '||l_posted_cnt||' Transactions are already posted.' );
        fnd_file.put_line
         (fnd_file.log,'Can not Continue. Returning without migrating data' );

        l_ret_status := fnd_concurrent.set_completion_status('ERROR','Errors found during processing.'||
			' Please check the log file for details.');

        RETURN;

      END IF;

    END IF;


    /* Now handle cases Based on parameters passed.
      a) If l_batch_id is not null then Open batch cursor for just batch_id and period passed in.
      b) If l_org_id is passed in and l_batch_id is NULL then Open batch cursor for all batches in org
         for the period.
      c) If l_org_id is NULL then Open batch cursor for all orgs of that legal entity for period.

    */

      IF l_batch_id IS NOT NULL THEN

        fnd_file.put_line(fnd_file.log, 'Opening batch_id cursor case 1 for batch_id '||l_batch_id);

        OPEN cur_batches FOR
          SELECT batch_id, batch_no, batch_status , asd, batch_close_date
            FROM (
                   SELECT h.batch_id, h.batch_no, h.batch_status , h.actual_start_date asd,
                          h.batch_close_date, h.organization_id
                     FROM gme_batch_header h,
                          mtl_material_transactions t
                    WHERE h.batch_status in (2,3,4)  -- B9441550
                       AND h.actual_start_date <= l_enddate
                       AND h.batch_id = t.transaction_source_id
                       AND t.transaction_source_type_id = 5
                       AND t.transaction_date >=  l_startdate
                       AND t.transaction_date <=  l_enddate
                   UNION
                   SELECT h.batch_id, h.batch_no, h.batch_status , h.actual_start_date asd,
                          h.batch_close_date, h.organization_id
                     FROM gme_batch_header h,
                          gme_resource_txns r
                    WHERE h.batch_status in (2,3,4)  -- B9441550
                      AND h.actual_start_date <= l_enddate
                      AND h.batch_id = r.doc_id
                      AND r.trans_date >=  l_startdate
                      AND r.trans_date <=  l_enddate
                      AND r.completed_ind = 1
                      AND r.delete_mark = 0
                   UNION
                   SELECT h.batch_id, h.batch_no, h.batch_status , h.actual_start_date asd,
                          h.batch_close_date, h.organization_id
                    FROM gme_batch_header h
                   WHERE h.batch_status = 4
                     AND h.actual_start_date <= l_enddate
                     AND h.batch_close_date >=  l_startdate
                     AND h.batch_close_date <=  l_enddate
                   UNION             -- B9441550
                   SELECT h.batch_id, h.batch_no, h.batch_status , h.plan_start_date asd,
                          h.batch_close_date, h.organization_id
                    FROM gme_batch_header h
                   WHERE h.batch_status = -1
                     AND h.batch_id = l_batch_id
                 ) batches
          WHERE batches.batch_id = l_batch_id
            AND batches.organization_id = l_org_id
            AND batches.organization_id IN
                (SELECT organization_id
                   FROM gmf_organization_definitions
                  WHERE legal_entity_id = l_legal_entity_id);


      ELSIF (l_batch_id IS NULL  AND  l_org_id IS NOT NULL) THEN

        fnd_file.put_line(fnd_file.log, 'Opening org_id cursor case 2 for org_id '||l_org_id);

        OPEN cur_batches FOR
          SELECT batch_id, batch_no, batch_status , asd, batch_close_date
            FROM (
                   SELECT h.batch_id, h.batch_no, h.batch_status , h.actual_start_date asd,
                          h.batch_close_date, h.organization_id
                     FROM gme_batch_header h,
                          mtl_material_transactions t
                    WHERE h.batch_status in (2,3,4)  -- B9441550
                       AND h.actual_start_date <= l_enddate
                       AND h.batch_id = t.transaction_source_id
                       AND t.transaction_source_type_id = 5
                       AND t.transaction_date >=  l_startdate
                       AND t.transaction_date <=  l_enddate
                   UNION
                   SELECT h.batch_id, h.batch_no, h.batch_status , h.actual_start_date asd,
                          h.batch_close_date, h.organization_id
                     FROM gme_batch_header h,
                          gme_resource_txns r
                    WHERE h.batch_status in (2,3,4)  -- B9441550
                      AND h.actual_start_date <= l_enddate
                      AND h.batch_id = r.doc_id
                      AND r.trans_date >=  l_startdate
                      AND r.trans_date <=  l_enddate
                      AND r.completed_ind = 1
                      AND r.delete_mark = 0
                   UNION
                   SELECT h.batch_id, h.batch_no, h.batch_status , h.actual_start_date asd,
                          h.batch_close_date, h.organization_id
                    FROM gme_batch_header h
                   WHERE h.batch_status = 4
                     AND h.actual_start_date <= l_enddate
                     AND h.batch_close_date >=  l_startdate
                     AND h.batch_close_date <=  l_enddate
                   UNION             -- B9441550
                   SELECT h.batch_id, h.batch_no, h.batch_status , h.plan_start_date asd,
                          h.batch_close_date, h.organization_id
                    FROM gme_batch_header h
                   WHERE h.batch_status = -1
                     AND h.organization_id = l_org_id
                     AND h.plan_start_date <= l_enddate
                     AND h.plan_start_date >=  l_startdate
                 ) batches
          WHERE batches.organization_id = l_org_id
            AND batches.organization_id IN
                (SELECT organization_id
                   FROM gmf_organization_definitions
                  WHERE legal_entity_id = l_legal_entity_id);

      ELSIF (l_batch_id IS NULL AND l_org_id IS NULL) THEN

        fnd_file.put_line(fnd_file.log, 'Opening period cursor case 3 for start date '||to_char(l_startdate,'DD-MON-RRRR HH24:MI:SS')||' end date '||
               to_char(l_enddate,'DD-MON-RRRR HH24:MI:SS'));

        OPEN cur_batches FOR
          SELECT batch_id, batch_no, batch_status , asd, batch_close_date
            FROM (
                   SELECT h.batch_id, h.batch_no, h.batch_status , h.actual_start_date asd,
                          h.batch_close_date, h.organization_id
                     FROM gme_batch_header h,
                          mtl_material_transactions t
                    WHERE h.batch_status in (2,3,4)  -- B9441550
                       AND h.actual_start_date <= l_enddate
                       AND h.batch_id = t.transaction_source_id
                       AND t.transaction_source_type_id = 5
                       AND t.transaction_date >=  l_startdate
                       AND t.transaction_date <=  l_enddate
                   UNION
                   SELECT h.batch_id, h.batch_no, h.batch_status , h.actual_start_date asd,
                          h.batch_close_date, h.organization_id
                     FROM gme_batch_header h,
                          gme_resource_txns r
                    WHERE h.batch_status in (2,3,4)  -- B9441550
                      AND h.actual_start_date <= l_enddate
                      AND h.batch_id = r.doc_id
                      AND r.trans_date >=  l_startdate
                      AND r.trans_date <=  l_enddate
                      AND r.completed_ind = 1
                      AND r.delete_mark = 0
                   UNION
                   SELECT h.batch_id, h.batch_no, h.batch_status , h.actual_start_date asd,
                          h.batch_close_date, h.organization_id
                    FROM gme_batch_header h
                   WHERE h.batch_status = 4
                     AND h.actual_start_date <= l_enddate
                     AND h.batch_close_date >=  l_startdate
                     AND h.batch_close_date <=  l_enddate
                   UNION             -- B9441550
                   SELECT h.batch_id, h.batch_no, h.batch_status , h.plan_start_date asd,
                          h.batch_close_date, h.organization_id
                    FROM gme_batch_header h
                   WHERE h.batch_status = -1
                     AND h.plan_start_date <= l_enddate
                     AND h.plan_start_date >= l_startdate
                 ) batches
          WHERE batches.organization_id IN
                (SELECT organization_id
                   FROM gmf_organization_definitions
                  WHERE legal_entity_id = l_legal_entity_id);

      END IF;


      FETCH cur_batches INTO rec;
      WHILE cur_batches%FOUND LOOP


      fnd_file.put_line(fnd_file.log, 'In Loop Migrating layer data for Batch Number  '||rec.batch_no);

      IF ((rec.actual_start_date >= l_startdate) AND (rec.actual_start_date <= l_enddate)) THEN

        fnd_file.put_line(fnd_file.log, '  Deleting Old layers for Batch_id   '|| rec.batch_id||' Batch No '||rec.batch_no);
        GMF_LAYERS.Delete_old_layers(rec.batch_id);

      ELSE

        fnd_file.put_line(fnd_file.log, '  Deleting Period layers for Batch_id   '|| rec.batch_id||' Batch No '||rec.batch_no||' Period id '||l_periodid);
        GMF_LAYERS.Delete_period_layers(rec.batch_id, l_periodid);

      END IF;

      fnd_file.put_line(fnd_file.log, '  END Deleting Old layers for Batch_id   '|| rec.batch_id||' Batch No '||rec.batch_no||' Period id '||l_periodid);
      -- Moved Declaration to top
      fnd_file.put_line(fnd_file.log, '  Rebuilding outgoing layers data for Batch_id   '|| rec.batch_id||' Period id '||l_periodid);

      GMF_LAYERS.Recreate_outgoing_layers(rec.batch_id,l_periodid);

      fnd_file.put_line(fnd_file.log, '  Rebuilding Resource data for Batch_id   '|| rec.batch_id||' Period id '||l_periodid);

      GMF_LAYERS.Recreate_resource_layers(rec.batch_id,l_periodid);

      fnd_file.put_line(fnd_file.log, '  Rebuilding incoming layers data for Batch_id   '|| rec.batch_id||' Period id '||l_periodid);

      GMF_LAYERS.Recreate_incoming_layers(rec.batch_id,l_periodid);

      -- Or call if r=batch close date i in period being passed?
      IF ((rec.batch_status = 4) AND (rec.batch_close_date >= l_startdate) AND (rec.batch_close_date <= l_enddate)) THEN

        fnd_file.put_line(fnd_file.log, '  Finalizing layers data for Close Batch_id   '|| rec.batch_id);

        GMF_LAYERS.Finalize_batch (rec.batch_id,l_periodid);

      END IF;

      fnd_file.put_line(fnd_file.log, '  After rebuild record count for Batch_id   '|| rec.batch_id||' Batch No '||rec.batch_no);

      SELECT count(*) INTO l_count
      FROM gmf_incoming_material_layers il
      WHERE il.PSEUDO_LAYER_ID IS NOT NULL
      AND EXISTS
	(SELECT 1
	FROM gme_batch_header h, mtl_material_transactions t,
	gmf_incoming_material_layers im
	WHERE h.batch_id = rec.batch_id
	AND    h.batch_id = t.transaction_source_id
	AND    t.transaction_source_type_id = 5
	AND    im.mmt_transaction_id           = t.transaction_id
        AND    im.mmt_organization_id          = t.organization_id
	AND    im.layer_id = il.PSEUDO_LAYER_ID
	);
      fnd_file.put_line(fnd_file.log, '  Psuedo Incoming layers count =  '|| l_count);
      SELECT count(*) INTO l_count
      FROM gmf_incoming_material_layers il
      WHERE (il.mmt_organization_id, il.mmt_transaction_id) IN
  	(SELECT DISTINCT t.organization_id, t.transaction_id
	FROM gme_batch_header h, mtl_material_transactions t
	WHERE h.batch_id = rec.batch_id
	AND    h.batch_id = t.transaction_source_id
	AND    t.transaction_source_type_id = 5
	);
      fnd_file.put_line(fnd_file.log, '  Incoming layers count =  '|| l_count);
      SELECT count(*) INTO l_count
      FROM gmf_outgoing_material_layers ol
      WHERE (ol.mmt_organization_id, ol.mmt_transaction_id) IN
	(SELECT DISTINCT t.organization_id, t.transaction_id
	FROM gme_batch_header h, mtl_material_transactions t
	WHERE h.batch_id = rec.batch_id
	AND    h.batch_id = t.transaction_source_id
	AND    t.transaction_source_type_id = 5
	);
      fnd_file.put_line(fnd_file.log, '  Outgoing layers count =  '|| l_count);
      SELECT count(*) INTO l_count
      FROM gmf_batch_vib_details bvd
      WHERE bvd.requirement_id IN
	(SELECT br.requirement_id
	FROM gmf_batch_requirements br, gme_batch_header h
	WHERE h.batch_id = rec.batch_id
	AND   h.batch_id = br.batch_id
	);
      fnd_file.put_line(fnd_file.log, '  Batch Vib details count =  '|| l_count);
      SELECT count(*) INTO l_count
      FROM gmf_batch_requirements br
      WHERE br.batch_id   IN
	(SELECT batch_id
	FROM gme_batch_header
	WHERE batch_id = rec.batch_id
	);
      fnd_file.put_line(fnd_file.log, '  Batch requirements count =  '|| l_count);
      fnd_file.put_line(fnd_file.log, 'END rebuilding layers for  Batch No =  '|| rec.batch_no);
      COMMIT;
      FETCH cur_batches INTO rec;

    END LOOP;

    fnd_file.put_line
      (fnd_file.log,'Layer Migration finished at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

    l_ret_status := fnd_concurrent.set_completion_status('NORMAL','Process completed successfully.');


  EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log, ' *****************************************************' );
    fnd_file.put_line(fnd_file.log, ' Error Running script for Batch_id   '|| rec.batch_id);
    fnd_file.put_line(fnd_file.log, ' Please check table gme_temp_exceptions for details' );
    fnd_file.put_line(fnd_file.log, ' *****************************************************' );
    fnd_file.put_line(fnd_file.log,'ERROR: '||substr(sqlerrm,1,100) || ' While Remigrating layer data.');
    l_ret_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm || ' While Remigrating layer data.' );

    ROLLBACK;


  END Relayer;

-- END Additions for relayering concurrent request.

END GMF_LAYERS;

/
