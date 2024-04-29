--------------------------------------------------------
--  DDL for Package Body GMD_SPREADSHEET_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SPREADSHEET_UPDATE" AS
/* $Header: GMDSPUPB.pls 120.11 2006/09/19 15:10:12 kmotupal noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMD_SPREADSHEET_UPDATE';

  /*##############################################################
  # NAME
  #	lock_formula_hdr
  # SYNOPSIS
  #	proc   lock_formula_hdr
  # DESCRIPTION
  #      This procedure is used to lock the formula header.
  ###############################################################*/

  PROCEDURE lock_formula_hdr (p_formula_id IN NUMBER, p_last_update_date IN DATE, X_return_status OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_lock_header IS
      SELECT last_update_date
      FROM   fm_form_mst
      WHERE  formula_id = P_formula_id
      FOR UPDATE OF LAST_UPDATE_DATE NOWAIT;
    X_last_update_date  DATE;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;
    OPEN Cur_lock_header;
    FETCH Cur_lock_header INTO X_last_update_date;
    CLOSE Cur_lock_header;
    IF X_last_update_date <> P_last_update_date THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_RECORD_CHANGED');
      FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'FM_FORM_MST');
      FND_MSG_PUB.ADD;
      X_return_status := FND_API.g_ret_sts_error;
    END IF;
  EXCEPTION
    WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
      IF Cur_lock_header%ISOPEN THEN
        CLOSE Cur_lock_header;
      END IF;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_RECORD_LOCK');
      FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'FM_FORM_MST');
      FND_MESSAGE.SET_TOKEN('RECORD', 'FORMULA_ID');
      FND_MESSAGE.SET_TOKEN('KEY', P_formula_id);
      FND_MSG_PUB.ADD;
      X_return_status := FND_API.g_ret_sts_error;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREADSHEET_UPDATE', 'Lock_Formula_Hdr');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END lock_formula_hdr;

  /*##############################################################
  # NAME
  #	lock_formula_dtl
  # SYNOPSIS
  #	proc   lock_formula_dtl
  # DESCRIPTION
  #      This procedure is used to lock the formula details.
  ###############################################################*/

  PROCEDURE lock_formula_dtl (P_formulaline_id IN NUMBER, P_last_update_date IN DATE,
                            X_return_status OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_lock_details IS
      SELECT last_update_date
      FROM   fm_matl_dtl
      WHERE  formulaline_id = P_formulaline_id
      FOR UPDATE OF LAST_UPDATE_DATE NOWAIT;
    X_last_update_date  DATE;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;
    OPEN Cur_lock_details;
    FETCH Cur_lock_details INTO X_last_update_date;
    CLOSE Cur_lock_details;
    IF X_last_update_date <> P_last_update_date THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_RECORD_CHANGED');
      FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'FM_MATL_DTL');
      FND_MSG_PUB.ADD;
      X_return_status := FND_API.g_ret_sts_error;
    END IF;
  EXCEPTION
    WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
      IF Cur_lock_details%ISOPEN THEN
        CLOSE Cur_lock_details;
      END IF;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_RECORD_LOCK');
      FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'FM_MATL_DTL');
      FND_MESSAGE.SET_TOKEN('RECORD', 'FORMULALINE_ID');
      FND_MESSAGE.SET_TOKEN('KEY', P_formulaline_id);
      FND_MSG_PUB.ADD;
      X_return_status := FND_API.g_ret_sts_error;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREADSHEET_UPDATE', 'Lock_Formula_Dtl');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END lock_formula_dtl;

  /*##############################################################
  # NAME
  #	lock_formula_record
  # SYNOPSIS
  #	proc   lock_formula_record
  # DESCRIPTION
  #      This procedure is used to lock the formula.
  ###############################################################*/

  PROCEDURE lock_formula_record (P_formula_id IN NUMBER,X_return_status OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_hdr IS
      SELECT last_update_date
      FROM   gmd_material_header_gtmp
      WHERE  formula_id = P_formula_id;

    CURSOR  Cur_get_dtl IS
      SELECT formulaline_id, last_update_date
       FROM  gmd_material_details_gtmp
       WHERE line_type <> 3
       ORDER BY line_type, line_no;
    l_last_update_date	DATE;
    l_return_status	VARCHAR2(10);
    error_lock		EXCEPTION;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;
    SAVEPOINT lock_formula_record;
    OPEN Cur_get_hdr;
    FETCH Cur_get_hdr INTO  l_last_update_date;
    CLOSE Cur_get_hdr;
    lock_formula_hdr(P_formula_id => P_formula_id
                    ,P_last_update_date => l_last_update_date
                    ,X_return_status => l_return_status);
    IF l_return_status <> x_return_status THEN
      RAISE error_lock;
    END IF;
    FOR l_rec IN Cur_get_dtl LOOP
      IF l_rec.formulaline_id IS NOT NULL THEN
        lock_formula_dtl (P_formulaline_id => l_rec.formulaline_id
                         ,P_last_update_date => l_rec.last_update_date
                         ,X_return_status => l_return_status);
        IF l_return_status <> x_return_status THEN
          RAISE error_lock;
        END IF;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN error_lock THEN
      X_return_status := l_return_status;
      ROLLBACK TO SAVEPOINT lock_formula_record;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREADSHEET_UPDATE', 'Lock_formula_Record');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO SAVEPOINT lock_formula_record;
  END lock_formula_record;

  /*##############################################################
  # NAME
  #	lock_batch_hdr
  # SYNOPSIS
  #	proc   lock_batch_hdr
  # DESCRIPTION
  #      This procedure is used to lock the batch header.
  ###############################################################*/

  PROCEDURE lock_batch_hdr (P_batch_id IN NUMBER, P_last_update_date IN DATE, X_return_status OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_lock_header IS
      SELECT last_update_date
      FROM   gme_batch_header
      WHERE  batch_id = P_batch_id
      FOR UPDATE OF LAST_UPDATE_DATE NOWAIT;
    X_last_update_date  DATE;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;
    OPEN Cur_lock_header;
    FETCH Cur_lock_header INTO X_last_update_date;
    CLOSE Cur_lock_header;
    IF X_last_update_date <> P_last_update_date THEN
      FND_MESSAGE.SET_NAME('GME', 'GME_RECORD_CHANGED');
      FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'GME_BATCH_HEADER');
      FND_MSG_PUB.ADD;
      X_return_status := FND_API.g_ret_sts_error;
    END IF;
  EXCEPTION
    WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
      IF Cur_lock_header%ISOPEN THEN
        CLOSE Cur_lock_header;
      END IF;
      FND_MESSAGE.SET_NAME('GME', 'GME_RECORD_LOCKED');
      FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'GME_BATCH_HEADER');
      FND_MESSAGE.SET_TOKEN('RECORD', 'BATCH_ID');
      FND_MESSAGE.SET_TOKEN('KEY', P_batch_id);
      FND_MSG_PUB.ADD;
      X_return_status := FND_API.g_ret_sts_error;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREADSHEET_UPDATE', 'Lock_Batch_Hdr');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END lock_batch_hdr;

  /*##############################################################
  # NAME
  #	lock_batch_dtl
  # SYNOPSIS
  #	proc   lock_batch_dtl
  # DESCRIPTION
  #      This procedure is used to lock the batch details.
  ###############################################################*/

  PROCEDURE lock_batch_dtl (P_material_detail_id IN NUMBER, P_last_update_date IN DATE,
                            X_return_status OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_lock_details IS
      SELECT last_update_date
      FROM   gme_material_details
      WHERE  material_detail_id = P_material_detail_id
      FOR UPDATE OF LAST_UPDATE_DATE NOWAIT;
    X_last_update_date  DATE;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;
    OPEN Cur_lock_details;
    FETCH Cur_lock_details INTO X_last_update_date;
    CLOSE Cur_lock_details;

    IF X_last_update_date <> P_last_update_date THEN
      FND_MESSAGE.SET_NAME('GME', 'GME_RECORD_CHANGED');
      FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'GME_MATERIAL_DETAILS');
      FND_MSG_PUB.ADD;
      X_return_status := FND_API.g_ret_sts_error;
    END IF;
  EXCEPTION
    WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
      IF Cur_lock_details%ISOPEN THEN
        CLOSE Cur_lock_details;
      END IF;
      FND_MESSAGE.SET_NAME('GME', 'GME_RECORD_LOCKED');
      FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'GME_MATERIAL_DETAILS');
      FND_MESSAGE.SET_TOKEN('RECORD', 'MATERIAL_DETAIL_ID');
      FND_MESSAGE.SET_TOKEN('KEY', P_material_detail_id);
      FND_MSG_PUB.ADD;
      X_return_status := FND_API.g_ret_sts_error;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREADSHEET_UPDATE', 'Lock_Batch_Dtl');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END lock_batch_dtl;

  /*##############################################################
  # NAME
  #	lock_batch_record
  # SYNOPSIS
  #	proc   lock_batch_record
  # DESCRIPTION
  #      This procedure is used to lock the batch.
  ###############################################################*/

  PROCEDURE lock_batch_record (P_batch_id IN NUMBER,
                               X_return_status OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_hdr IS
      SELECT last_update_date
      FROM   gmd_material_header_gtmp
      WHERE  batch_id = P_batch_id;

    CURSOR  Cur_get_dtl IS
      SELECT material_detail_id, last_update_date
       FROM  gmd_material_details_gtmp
       WHERE line_type <> 3
       ORDER BY line_type, line_no;
    l_last_update_date	DATE;
    l_return_status	VARCHAR2(10);
    error_lock		EXCEPTION;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;
    SAVEPOINT lock_batch_record;
    OPEN Cur_get_hdr;
    FETCH Cur_get_hdr INTO  l_last_update_date;
    CLOSE Cur_get_hdr;
    lock_batch_hdr(P_batch_id => P_batch_id
                  ,P_last_update_date => l_last_update_date
                  ,X_return_status => l_return_status);
    IF l_return_status <> x_return_status THEN
      RAISE error_lock;
    END IF;
    FOR l_rec IN Cur_get_dtl LOOP
      IF l_rec.material_detail_id IS NOT NULL THEN
        lock_batch_dtl (P_material_detail_id => l_rec.material_detail_id
                       ,P_last_update_date => l_rec.last_update_date
                       ,X_return_status => l_return_status);
        IF l_return_status <> x_return_status THEN
          RAISE error_lock;
        END IF;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN error_lock THEN
      X_return_status := l_return_status;
      ROLLBACK TO SAVEPOINT lock_batch_record;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREADSHEET_UPDATE', 'Lock_Batch_Record');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO SAVEPOINT lock_batch_record;
  END lock_batch_record;


  /*##############################################################
  # NAME
  #	update_batch
  # SYNOPSIS
  #	proc   update_batch
  # DESCRIPTION
  #      This procedure is used to update the batch.
  # HISTORY
  #      22-AUG-06 Kapil M Bug# 3927768
  #      Changed the IF condition to update lot for the items.
  #      19-SEP-06 Kapil M Bug# 3927768
  #      Modified in deletion, updation and creation go product_pending_lots
  ###############################################################*/

  PROCEDURE update_batch (P_batch_id IN NUMBER, X_return_status OUT NOCOPY VARCHAR2) IS

    CURSOR Cur_get_batch IS
      SELECT *
      FROM   gme_batch_header
      WHERE  batch_id = P_batch_id;

    CURSOR Cur_get_del_material IS
      SELECT material_detail_id
      FROM   gme_material_details e
      WHERE  batch_id = P_batch_id
      AND    line_type <> 1
      AND    NOT EXISTS (SELECT 1
                         FROM   gmd_material_details_gtmp g
                         WHERE  line_type <> 3
                         AND    g.material_detail_id = e.material_detail_id);

    CURSOR Cur_get_material IS
      SELECT *
      FROM   gmd_material_details_gtmp
      WHERE  line_type <> 3
      ORDER BY line_type, line_no;

    CURSOR Cur_get_detail_id(V_material_detail_id NUMBER) IS
      SELECT  1
      FROM    gme_material_details
      WHERE   batch_id = P_batch_id
              AND material_detail_id = V_material_detail_id;

        -- Bug# 3927768 Kapil M
        -- Changed the below three cursors
    CURSOR Cur_get_lablot (V_material_detail_id NUMBER ) IS
      SELECT *
      FROM   gmd_material_details_gtmp
      WHERE  line_type = 3
      AND    material_detail_id = V_material_detail_id;

        -- Bug# 3927768 Kapil M
    CURSOR Cur_get_lab_material (p_lot_id NUMBER) IS
      SELECT quantity
      FROM   gme_pending_product_lots
      WHERE  batch_id = P_batch_id
             AND pending_product_lot_id = p_lot_id;

        -- Bug# 3927768 Kapil M
    CURSOR  Cur_get_del_lines (V_material_detail_id NUMBER) IS
      SELECT material_detail_id, pending_product_lot_id
      FROM   gme_pending_product_lots e
      WHERE  batch_id = P_batch_id
      AND    material_detail_id = V_material_detail_id
      AND    NOT EXISTS (SELECT 1
                         FROM   gmd_material_details_gtmp g
                         WHERE  parent_line_id = V_material_detail_id
                         AND    g.trans_id = e.pending_product_lot_id
                         AND    line_type = 3);

    CURSOR  Cur_get_product_lot (V_material_detail_id NUMBER) IS
      SELECT pending_product_lot_id
      FROM   gme_pending_product_lots
      WHERE  batch_id = P_batch_id
      AND    material_detail_id = V_material_detail_id;

    CURSOR Cur_get_text IS
      SELECT material_detail_id,text_code,orginal_text_code
      FROM   gmd_material_details_gtmp
      WHERE  text_code <> NVL(orginal_text_code,0);

    l_batch_row		GME_BATCH_HEADER%ROWTYPE;
    l_batch_rec		GME_BATCH_HEADER%ROWTYPE;
    l_batch_step        GME_BATCH_STEPS%ROWTYPE;
    l_material_detail	GME_MATERIAL_DETAILS%ROWTYPE;
    P_material		GME_MATERIAL_DETAILS%ROWTYPE;
    X_material		GME_MATERIAL_DETAILS%ROWTYPE;
    l_material_det	GME_MATERIAL_DETAILS%ROWTYPE;
    l_material_out	GME_MATERIAL_DETAILS%ROWTYPE;
    l_material_rec	GME_MATERIAL_DETAILS%ROWTYPE;
    x_def_tran_row	GME_INVENTORY_TXNS_GTMP%ROWTYPE;
    x_material_row	GME_MATERIAL_DETAILS%ROWTYPE;
    l_pending_in_rec    GME_PENDING_PRODUCT_LOTS%ROWTYPE;
    l_pending_out_rec   GME_PENDING_PRODUCT_LOTS%ROWTYPE;
    l_labrec		Cur_get_lablot%ROWTYPE;
    type text_table is table of NUMBER(10) index by binary_integer;
    x_text_tab      text_table;
    x_cnt           NUMBER default 0;

    l_material_count	   NUMBER(5);
    l_resource_count	   NUMBER(5);
    l_msg_index		   NUMBER(5);
    l_default_release_type NUMBER(5);
    l_text_code 	   NUMBER(5);
    l_temp		   NUMBER;
    l_transacted	   VARCHAR2(240);
    l_message_count	   NUMBER;
    l_message_list	   VARCHAR2(2000);

    l_return_status	VARCHAR2(10);

    lock_batch_err	EXCEPTION;
    error_setup		EXCEPTION;
    error_load_batch	EXCEPTION;
    update_alloc_err	EXCEPTION;
    insert_line_err	EXCEPTION;
    update_line_err	EXCEPTION;
    delete_line_err	EXCEPTION;
  BEGIN
    /* Initialize return status */
    X_return_status := FND_API.g_ret_sts_success;
    /* Establish the savepoint */
    SAVEPOINT  update_batch;

    /*Let us first check if their are any changes in the batch */
    lock_batch_record (p_batch_id => p_batch_id
                      ,x_return_status => l_return_status);
    IF l_return_status <> x_return_status THEN
      RAISE lock_batch_err;
    END IF;

    /* Let us load the batch transactions into the temporary table */
    OPEN Cur_get_batch;
    FETCH Cur_get_batch INTO l_batch_row;
    CLOSE Cur_get_batch;

    /*Lets initialize the gme variables */
    gme_common_pvt.set_timestamp;
    IF NOT gme_common_pvt.setup(P_org_id => l_batch_row.organization_id) THEN
      RAISE error_setup;
    END IF; /* IF NOT gme_api_pub.setup_done */

    gmd_api_grp.fetch_parm_values(P_orgn_id       => l_batch_row.organization_id,
                                  P_parm_name     => 'FM$DEFAULT_RELEASE_TYPE',
                                  P_parm_value    => l_default_release_type,
                                  X_return_status => X_return_status);

    /* First let us delete all the lines which existed in the batch */
    /* but was deleted from the spreadsheet                         */
    FOR l_del_matl_rec IN Cur_get_del_material LOOP
      l_material_detail.material_detail_id := l_del_matl_rec.material_detail_id;
      l_material_detail.batch_id := P_batch_id;
      gme_material_detail_pvt.delete_material_line (p_batch_header_rec    => l_batch_row
 						   ,p_material_detail_rec => l_material_detail
                                                   ,p_batch_step_rec      => l_batch_step
                                                   ,x_transacted          => l_transacted
                                                   ,x_return_status       => l_return_status);
      IF x_return_status <> l_return_status THEN
        RAISE delete_line_err;
      END IF;
    END LOOP;

    /*Let us fetch all the material lines for the batch */
    FOR l_matl_rec IN Cur_get_material LOOP
      /*If the line is not an existing record in the batch material_details */
      OPEN Cur_get_detail_id(l_matl_rec.material_detail_id);
      FETCH Cur_get_detail_id INTO l_temp;
      IF(Cur_get_detail_id%NOTFOUND) THEN
        --Bug3680011 is fixed.
        l_material_detail.material_detail_id := NULL;
        /* This implies that this is a new line we need to first insert the material line */
        l_material_detail.batch_id 		:= p_batch_id;
        l_material_detail.line_no		:= l_matl_rec.line_no;
        l_material_detail.line_type		:= l_matl_rec.line_type;
        l_material_detail.inventory_item_id     := l_matl_rec.inventory_item_id;
        l_material_detail.organization_id       := l_matl_rec.organization_id;
        l_material_detail.dtl_um		:= l_matl_rec.detail_uom;
        l_material_detail.revision		:= l_matl_rec.revision;
        l_material_detail.text_code		:= l_matl_rec.text_code;
        l_material_detail.phantom_type		:= 0;
        l_material_detail.scale_type		:= 1;
        l_material_detail.release_type		:= NVL(l_default_release_type,0);
        l_material_detail.alloc_ind		:= 0;
        l_material_detail.scrap_factor		:= 0;
        l_material_detail.actual_qty		:= 0;
        IF (l_batch_row.batch_status = 1) THEN
          l_material_detail.plan_qty := l_matl_rec.qty;
        ELSIF (l_batch_row.batch_status = 2) THEN
          l_material_detail.wip_plan_qty := l_matl_rec.qty;
        END IF;
        gmd_debug.put_line(' Inserting line for batch:'||l_material_detail.batch_id||' Item:'||l_material_detail.inventory_item_id);
        gme_material_detail_pvt.insert_material_line (p_batch_header_rec    => l_batch_row
 						     ,p_material_detail_rec => l_material_detail
                                                     ,p_batch_step_rec      => l_batch_step
                                                     ,p_trans_id            => NULL
                                                     ,x_transacted          => l_transacted
                                                     ,x_return_status       => l_return_status
                                                     ,x_material_detail_rec => l_material_out);
        IF x_return_status <> l_return_status THEN
          gmd_debug.put_line(' Insert material line error: Item:'||l_material_detail.inventory_item_id);
          RAISE insert_line_err;
        ELSE
          l_matl_rec.material_detail_id := l_material_out.material_detail_id;
          UPDATE gmd_material_details_gtmp
          SET material_detail_id = l_matl_rec.material_detail_id,
              parent_line_id = l_matl_rec.material_detail_id
          WHERE parent_line_id = l_matl_rec.parent_line_id;
        END IF;
      ELSE
        P_material.material_detail_id := l_matl_rec.material_detail_id;
        IF (GME_MATERIAL_DETAILS_DBL.FETCH_ROW (P_material, X_material)) THEN
          X_material.dtl_um := l_matl_rec.detail_uom;
          IF (l_batch_row.batch_status = 1) THEN
            X_material.plan_qty := l_matl_rec.qty;
          ELSIF (l_batch_row.batch_status = 2) THEN
            X_material.wip_plan_qty := l_matl_rec.qty;
          END IF;
          gme_material_detail_pvt.update_material_line (p_batch_header_rec    => l_batch_row
 						       ,p_material_detail_rec => X_material
 						       ,p_stored_material_detail_rec => NULL
                                                       ,p_batch_step_rec      => l_batch_step
                                                       ,p_scale_phantom       => fnd_api.g_false
                                                       ,p_trans_id            => NULL
                                                       ,x_transacted          => l_transacted
                                                       ,x_return_status       => l_return_status
                                                       ,x_material_detail_rec => l_material_out);
          IF x_return_status <> l_return_status THEN
            gmd_debug.put_line(' Insert material line error: Material id:'||l_material_detail.material_detail_id);
            RAISE update_line_err;
          END IF;
        END IF;
      END IF; /* IF(Cur_get_detail_id%NOTFOUND) THEN */
      CLOSE Cur_get_detail_id;

      IF (l_batch_row.update_inventory_ind = 'Y') THEN
        update_allocation (P_plant_Id	 	=> l_batch_row.organization_id
                          ,P_batch_id 		=> l_batch_row.batch_id
                          ,P_material_detail_id	=> l_matl_rec.material_detail_id
                          ,P_line_type		=> l_matl_rec.line_type
                          ,X_return_status	=> l_return_status);
        IF l_return_status <> x_return_status THEN
          RAISE update_alloc_err;
        END IF;
      ELSE
        l_batch_rec.batch_id := P_batch_id;
        l_material_rec.material_detail_id := l_matl_rec.material_detail_id;
        FOR l_del_rec IN Cur_get_del_lines (l_matl_rec.material_detail_id) LOOP
        -- Bug# 3927768 Kapil M
        -- Those lots which are not found in gmd_material_details_gtmp should be deleted.
        l_pending_in_rec.pending_product_lot_id := l_del_rec.pending_product_lot_id;

          gme_api_pub.delete_pending_product_lot (p_api_version              => 2.0,
                                                  x_message_count            => l_message_count,
                                                  x_message_list             => l_message_list,
                                                  x_return_status 	     => l_return_status,
                                                  p_batch_header_rec         => l_batch_rec,
                                                  p_org_code 		     => NULL,
                                                  p_material_detail_rec      => l_material_rec,
                                                  p_pending_product_lots_rec => l_pending_in_rec);
           IF x_return_status <> l_return_status THEN
             gmd_debug.put_line(' Insert pending lot error: Material id:'||l_matl_rec.material_detail_id ||
                                'lot_number: '||l_pending_in_rec.lot_number);
             RAISE update_line_err;
           END IF;
        END LOOP;

       /* Let us load the lab lots into the temporary table */
        FOR l_labrec IN Cur_get_lablot (l_matl_rec.material_detail_id)LOOP
        -- Bug# 3927768 Kapil M
        -- Added the item_id condition to update LOTs for specified items only.
        IF (l_labrec.line_type = 3 AND l_labrec.INVENTORY_ITEM_ID = l_matl_rec.inventory_item_id) THEN
          l_batch_rec.batch_id := P_batch_id;
          l_material_rec.material_detail_id := l_matl_rec.material_detail_id;
          l_pending_in_rec.lot_number := l_labrec.lot_number;
          l_pending_in_rec.quantity := l_labrec.qty;
          l_pending_in_rec.secondary_quantity := l_labrec.secondary_qty;
          l_pending_in_rec.created_by := l_labrec.created_by;
          l_pending_in_rec.creation_date := l_labrec.creation_date;
          l_pending_in_rec.last_updated_by := l_labrec.last_updated_by;
          l_pending_in_rec.last_update_date := l_labrec.last_update_date;
         /* Let us check the lab batch lot is already existing if yes update the line */
        -- Bug# 3927768 Kapil M
        -- Records fetched based on the pending_lot_id
         OPEN Cur_get_lab_material(l_labrec.trans_id);
         FETCH Cur_get_lab_material INTO l_temp;
         IF (Cur_get_lab_material%FOUND) THEN
        -- Bug# 3927768 Kapil M
        -- If Quantity in a lot has been changed then, update is performed.
           IF l_labrec.qty <> l_temp THEN
            l_pending_in_rec.pending_product_lot_id := l_labrec.trans_id;
           gme_api_pub.update_pending_product_lot (p_api_version              => 2.0,
                                                   x_message_count            => l_message_count,
                                                   x_message_list             => l_message_list,
                                                   x_return_status 	      => l_return_status,
                                                   p_batch_header_rec         => l_batch_rec,
                                                   p_org_code 		      => NULL,
                                                   p_material_detail_rec      => l_material_rec,
                                                   p_pending_product_lots_rec => l_pending_in_rec,
                                                   x_pending_product_lots_rec => l_pending_out_rec);
              IF x_return_status <> l_return_status THEN
                gmd_debug.put_line(' Insert pending lot error: Material id:'||l_matl_rec.material_detail_id ||
                                     'lot_number: '||l_pending_in_rec.lot_number);
                RAISE update_line_err;
               END IF;
            END IF;
         ELSE
           /* Let us check the lab batch lot is already existing if not insert the new line */
           l_pending_in_rec.pending_product_lot_id := NULL;
           gme_api_pub.create_pending_product_lot (p_api_version              => 2.0,
                                                   x_message_count            => l_message_count,
                                                   x_message_list             => l_message_list,
                                                   x_return_status 	      => l_return_status,
                                                   p_batch_header_rec         => l_batch_rec,
                                                   p_org_code 		      => NULL,
                                                   p_material_detail_rec      => l_material_rec,
                                                   p_pending_product_lots_rec => l_pending_in_rec,
                                                   x_pending_product_lots_rec => l_pending_out_rec);

          IF x_return_status <> l_return_status THEN
            gmd_debug.put_line(' Insert pending lot error: Material id:'||l_matl_rec.material_detail_id ||
                               'lot_number: '||l_pending_in_rec.lot_number);
            RAISE update_line_err;
          END IF;
         END IF;
         CLOSE Cur_get_lab_material;
        END IF;
       END LOOP;/*FOR l_labrec IN Cur_get_lablot*/
      END IF;
    END LOOP; /* FOR l_matl_rec IN Cur_get_material */

    FOR l_rec IN Cur_get_text LOOP
      IF l_rec.material_detail_id IS NOT NULL THEN
        IF l_rec.text_code IS NOT NULL THEN
          l_text_code := GMA_EDITTEXT_PKG.Copy_Text(l_rec.text_code,'FM_TEXT_TBL_TL','GME_TEXT_TABLE_TL');

          UPDATE gme_material_details
          SET    text_code = l_text_code
          WHERE  material_detail_id = l_rec.material_detail_id;
        END IF;
      END IF;
      IF l_rec.orginal_text_code IS NOT NULL AND
         l_rec.text_code <> l_rec.orginal_text_code THEN
        GMA_EDITTEXT_PKG.Delete_Text(l_rec.orginal_text_code,'GME_TEXT_TABLE_TL');
      END IF;
    END LOOP;

    update gmd_material_details_gtmp a
    set last_update_date = (select last_update_date
                            FROM gme_material_details
                            WHERE material_detail_id = a.material_detail_id);
  EXCEPTION
    WHEN error_setup THEN
      ROLLBACK TO SAVEPOINT update_batch;
      X_return_status := FND_API.g_ret_sts_error;
    WHEN error_load_batch OR update_alloc_err OR insert_line_err OR update_line_err
         OR delete_line_err OR lock_batch_err THEN
      ROLLBACK TO SAVEPOINT update_batch;
      X_return_status := l_return_status;
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT update_batch;
      fnd_msg_pub.add_exc_msg (gmd_spreadsheet_update.g_pkg_name, 'Update_Batch');
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END update_batch;

  /*##############################################################
  # NAME
  #	update_allocation
  # SYNOPSIS
  #	proc   update_allocation
  # DESCRIPTION
  #      This procedure is used to update the allocations for the batch.
  ###############################################################*/

  PROCEDURE update_allocation (P_plant_id		IN	NUMBER,
  			       P_batch_id		IN	NUMBER,
                               P_material_detail_id 	IN 	NUMBER,
                               P_line_type		IN	NUMBER,
                               X_return_status OUT NOCOPY VARCHAR2) IS

    CURSOR  Cur_get_del_lines (V_material_detail_id NUMBER) IS
      SELECT *
      FROM   mtl_reservations e
      WHERE  demand_source_header_id = P_batch_id
      AND    demand_source_line_id = V_material_detail_id
      AND    demand_source_type_id = gme_common_pvt.g_txn_source_type
      AND    NOT EXISTS (SELECT 1
                         FROM   gmd_material_details_gtmp g
                         WHERE  parent_line_id = V_material_detail_id
                         AND    line_type = 3
                         AND    g.reservation_id =  e.reservation_id);

    CURSOR  Cur_get_lines (V_material_detail_id NUMBER) IS
      SELECT *
       FROM  gmd_material_details_gtmp
       WHERE parent_line_id = V_material_detail_id
       AND   line_type = 3
       AND   transaction_id IS NULL
       ORDER BY line_no desc;

    CURSOR  Cur_get_line_revision (V_material_detail_id NUMBER) IS
      SELECT revision,inventory_item_id
       FROM  gmd_material_details_gtmp
       WHERE material_detail_id = V_material_detail_id;

    CURSOR  Cur_get_rev_control (V_item_id NUMBER) IS
      SELECT revision_qty_control_code
       FROM  mtl_system_items_b
       WHERE inventory_item_id = V_item_id
             AND organization_id = P_plant_id;

    CURSOR  Cur_get_item_revision (V_item_id NUMBER) IS
      SELECT revision
       FROM  mtl_item_revisions
       WHERE inventory_item_id = V_item_id
             AND organization_id = P_plant_id
       ORDER BY CREATION_DATE DESC;

    CURSOR Cur_get_qty (V_reservation_id NUMBER) IS
      SELECT reservation_quantity
      FROM   mtl_reservations
      WHERE  reservation_id = V_reservation_id;

    CURSOR Cur_req_date IS
      SELECT material_requirement_date
      FROM   gme_material_details
      WHERE  material_detail_id = P_material_detail_id;

    CURSOR Cur_get_new_qty IS
      SELECT qty,transaction_id,lot_number
      FROM   gmd_material_details_gtmp
      WHERE  material_detail_id = P_material_detail_id
      AND    lot_number IS NOT NULL;

    CURSOR Cur_get_old_qty (V_transaction_id NUMBER, V_lot_number VARCHAR2) IS
      SELECT transaction_quantity
      FROM   mtl_transaction_lot_numbers
      WHERE  transaction_id = V_transaction_id
      AND    lot_number = V_lot_number;

    l_material_out	GME_MATERIAL_DETAILS%ROWTYPE;

    l_return_status	VARCHAR2(10);
    l_reservation_qty   NUMBER;
    l_requirement_date  DATE;
    l_trans_qty		NUMBER;
    l_item_id		NUMBER;
    l_revision		VARCHAR2(3);
    l_rev_control	NUMBER;

    update_alloc_err	EXCEPTION;
    insert_alloc_err	EXCEPTION;
    delete_alloc_err	EXCEPTION;
    trans_update	EXCEPTION;

  BEGIN
    /* Initialize return status */
    X_return_status := FND_API.g_ret_sts_success;

    /* Lets check wheter transaction qty is changed for any of the material lines */
    /* if yes raise an error message */
    FOR l_qty IN Cur_get_new_qty LOOP
      OPEN Cur_get_old_qty(l_qty.transaction_id,l_qty.lot_number);
      FETCH Cur_get_old_qty INTO l_trans_qty;
      CLOSE Cur_get_old_qty;
      IF l_qty.qty <> ABS(l_trans_qty) THEN
        RAISE trans_update;
      END IF;
    END LOOP;

    /* First let us delete all the reservations which existed in the batch */
    /* but was deleted from the spreadsheet.                               */
    IF P_line_type <> 1 THEN
      FOR l_del_rec IN Cur_get_del_lines (P_material_detail_id) LOOP
        gmd_debug.put_line(' Material:'||P_material_detail_id||' trans:'||l_del_rec.reservation_id||' reserv qty:'||l_del_rec.reservation_quantity||' Lot:'||l_del_rec.lot_number);
        gme_reservations_pvt.delete_reservation(p_reservation_id => l_del_rec.reservation_id
                                                ,x_return_status => l_return_status);
        IF X_return_status <> l_return_status THEN
          gmd_debug.put_line('Delete allocation error:'||l_del_rec.reservation_id);
          RAISE delete_alloc_err;
        END IF;
      END LOOP;
    END IF;

    /* Then let us update/insert the reservation lines associated with the material line */
    FOR l_rec IN Cur_get_lines (P_material_detail_id) LOOP
      OPEN Cur_req_date;
      FETCH Cur_req_date INTO l_requirement_date;
      CLOSE Cur_req_date;

      --Check if the item is revision control
      OPEN Cur_get_rev_control (P_material_detail_id);
      FETCH Cur_get_rev_control INTO l_rev_control;
      CLOSE Cur_get_rev_control;

      IF (l_rev_control = 2) THEN
        /*Get the item and revision from material detail line*/
        OPEN Cur_get_line_revision (P_material_detail_id);
        FETCH Cur_get_line_revision INTO l_revision,l_item_id;
        CLOSE Cur_get_line_revision;

        /*If revision is not found for that material line then fetch the lastest revision
          from the item revisions table */
        IF (l_revision IS NULL) THEN
          OPEN Cur_get_item_revision (l_item_id);
          FETCH Cur_get_item_revision INTO l_revision;
          CLOSE Cur_get_item_revision;
        END IF;
      ELSE
        l_revision := NULL;
      END IF;

      l_material_out.inventory_item_id         := l_rec.inventory_item_id;
      l_material_out.organization_id 	       := P_plant_id;
      l_material_out.revision    	       := l_revision;
      l_material_out.batch_id                  := P_batch_id;
      l_material_out.material_requirement_date := l_requirement_date;
      l_material_out.material_detail_id        := P_material_detail_id;
      gmd_debug.put_line('Line:'||l_rec.line_no||' Material:'||p_material_detail_id||
                         ' Lot Number:'||l_rec.lot_number||' Qty:'||l_rec.qty||
                         ' Secondary:'||l_rec.secondary_qty);

      /* Let us update the existing reservations */
      IF l_rec.reservation_id IS NOT NULL THEN
        OPEN Cur_get_qty (l_rec.reservation_id);
        FETCH Cur_get_qty INTO l_reservation_qty;
        CLOSE Cur_get_qty;
        IF l_reservation_qty <> l_rec.qty THEN
          gme_reservations_pvt.update_reservation (p_reservation_id => l_rec.reservation_id
                                                  ,p_revision       => l_revision
                                                  ,p_subinventory   => l_rec.subinventory_code
                                                  ,p_locator_id     => l_rec.locator_id
                                                  ,p_lot_number     => l_rec.lot_number
                                                  ,p_new_qty        => l_rec.qty
                                                  ,p_new_sec_qty    => ABS(l_rec.secondary_qty)
                                                  ,p_new_uom        => l_rec.detail_uom
                                                  ,p_new_date       => SYSDATE
                                                  ,x_return_status  => l_return_status);
          IF X_return_status <> l_return_status THEN
            gmd_debug.put_line('Update allocation error:'||l_rec.reservation_id);
            RAISE update_alloc_err;
          END IF;
        END IF;
      ELSE
        /* Let us create the new reservation material line */
        gme_reservations_pvt.create_material_reservation (p_matl_dtl_rec  => l_material_out
                                                         ,p_resv_qty      => l_rec.qty
                                                         ,p_sec_resv_qty  => ABS(l_rec.secondary_qty)
                                                         ,p_resv_um       => l_rec.detail_uom
                                                         ,p_subinventory  => l_rec.subinventory_code
                                                         ,p_locator_id    => l_rec.locator_id
                                                         ,p_lot_number    => l_rec.lot_number
                                                         ,x_return_status => l_return_status);
        IF X_return_status <> l_return_status THEN
          gmd_debug.put_line(' Insert alloc fail'||l_return_status);
          RAISE insert_alloc_err;
        END IF;
      END IF; /* IF l_rec.reservation_id IS NOT NULL THEN */
    END LOOP; /* FOR l_rec IN Cur_get_lines (l_matl_rec.material_detail_id) */

  EXCEPTION
    WHEN update_alloc_err OR insert_alloc_err OR delete_alloc_err THEN
      X_return_status := l_return_status;
    WHEN trans_update THEN
      gmd_api_grp.log_message('GMD_QTY_NO_UPDATE');
      X_return_status := FND_API.g_ret_sts_error;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (gmd_spreadsheet_update.g_pkg_name, 'Update_Allocation');
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END update_allocation;

END GMD_SPREADSHEET_UPDATE;

/
