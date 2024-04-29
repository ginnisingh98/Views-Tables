--------------------------------------------------------
--  DDL for Package Body GMIVDX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIVDX" AS
/* $Header: GMIVDXB.pls 120.4 2008/02/28 09:04:34 rlnagara ship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIVDXB.pls                                                           |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIVDX                                                                |
 | TYPE                                                                     |
 |   Private                                                                |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the private API for Process / Discrete Transfer |
 |                                                                          |
 | CONTENTS                                                                 |
 |    Create_discrete_transfer_pvt                                          |
 |    Validate_transfer                                                     |
 |    construct_post_records                                                |
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created    Jalaj Srivastava
 ============================================================================
*/

PROCEDURE log_msg(p_msg_text IN VARCHAR2);

/*  Global variables */
G_PKG_NAME     CONSTANT VARCHAR2(30):='GMIVDX';
G_tmp	       BOOLEAN   := FND_MSG_PUB.Check_Msg_Level(0) ;  -- temp call to initialize the
						              -- msg level threshhold gobal
							      -- variable.
G_debug_level  NUMBER(2) := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
							       -- to decide to log a debug msg.


/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Create_discrete_transfer_pvt                                          |
 |                                                                          |
 | USAGE                                                                    |
 |    Sets up and posts process/discrete transfer                           |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Jalaj Srivastava                                              |
 |                                                                          |
 +==========================================================================+ */
PROCEDURE Create_transfer_pvt
( p_api_version          IN               NUMBER
, p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY       VARCHAR2
, x_msg_count            OUT NOCOPY       NUMBER
, x_msg_data             OUT NOCOPY       VARCHAR2
, p_hdr_rec              IN               hdr_type
, p_line_rec_tbl         IN               line_type_tbl
, p_lot_rec_tbl          IN               lot_type_tbl
, x_hdr_row              OUT NOCOPY       gmi_discrete_transfers%ROWTYPE
, x_line_row_tbl         OUT NOCOPY       line_row_tbl
, x_lot_row_tbl          OUT NOCOPY       lot_row_tbl
, x_transaction_set_id   OUT NOCOPY       mtl_material_transactions.transaction_set_id%TYPE
)
IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'Create_transfer_pvt' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;
  l_hdr_rec            GMIVDX.hdr_type;
  l_line_rec_tbl       GMIVDX.line_type_tbl;
  l_lot_rec_tbl        GMIVDX.lot_type_tbl;

BEGIN

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  l_hdr_rec    		:= p_hdr_rec;
  l_line_rec_tbl  	:= p_line_rec_tbl;
  l_lot_rec_tbl  	:= p_lot_rec_tbl;

  --Validate the transfer
  Validate_transfer
       (
   	  p_api_version        =>  p_api_version
	, p_init_msg_list      =>  FND_API.G_FALSE
        , p_commit             =>  FND_API.G_FALSE
	, p_validation_level   =>  p_validation_level
	, x_return_status      =>  x_return_status
	, x_msg_count          =>  x_msg_count
	, x_msg_data           =>  x_msg_data
	, p_hdr_rec            =>  l_hdr_rec
	, p_line_rec_tbl       =>  l_line_rec_tbl
	, p_lot_rec_tbl        =>  l_lot_rec_tbl
	);

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    log_msg('return code from Validate_transfer. return status is '||x_return_status);
  END IF;

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --if the validation of header, lines and lots is successful then
  --lets construct and post records to gmi_discrete_transfers, gmi_discrete_transfers                 |
  --and gmi_discrete_transfer_lots.                                       |
  --In this call, we will also create lots in OPM and ODM if the lot does not exist.
  --Transaction tables in OPM/ODM and onhand balcnces in OPM/ODM would also be updated.

  construct_post_records
       (
  	  p_api_version          =>  p_api_version
	, p_init_msg_list        =>  FND_API.G_FALSE
	, p_commit               =>  FND_API.G_FALSE
	, p_validation_level     =>  p_validation_level
	, x_return_status        =>  x_return_status
	, x_msg_count            =>  x_msg_count
	, x_msg_data             =>  x_msg_data
	, p_hdr_rec              =>  l_hdr_rec
	, p_line_rec_tbl         =>  l_line_rec_tbl
	, p_lot_rec_tbl          =>  l_lot_rec_tbl
	, x_hdr_row              =>  x_hdr_row
	, x_line_row_tbl         =>  x_line_row_tbl
	, x_lot_row_tbl          =>  x_lot_row_tbl
      );

  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
     x_transaction_set_id := l_hdr_rec.transaction_header_id;
     FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_TXN_POSTED');
     FND_MESSAGE.SET_TOKEN('ORGN_CODE'  ,x_hdr_row.orgn_code);
     FND_MESSAGE.SET_TOKEN('TRANSFER_NO',x_hdr_row.transfer_number);
     FND_MSG_PUB.Add;

     IF FND_API.to_boolean(p_commit) THEN
        COMMIT WORK;
     END IF;
  ELSIF    (x_return_status = FND_API.G_RET_STS_ERROR)       THEN
        RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    --empty the quantity tree cache
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --empty the quantity tree cache
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    --empty the quantity tree cache
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END Create_transfer_pvt;


/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Validate_transfer                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |    Validates process/discrete transfer records.                          |
 |                                                                          |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Jalaj Srivastava                                              |
 |   Supriya Malluru 04-Feb-2004 Bug#4114621  |
 |   Included two cursors cur_item_gl_cls,Cur_gl_cls (which accept opm item_id as the parameter),to   |
 |   populate/clear gl business class and gl product line based on the item.And modified call to  |
 |   gmf_get_mappings.get_account_mappings to send category ids of the two new item attributes  |
 |   GL Business Class and GL Product Line.                                                                |
 +==========================================================================+ */
PROCEDURE Validate_transfer
( p_api_version          IN                      NUMBER
, p_init_msg_list        IN                      VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN                      VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN                      NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY              VARCHAR2
, x_msg_count            OUT NOCOPY              NUMBER
, x_msg_data             OUT NOCOPY              VARCHAR2
, p_hdr_rec              IN  OUT NOCOPY          hdr_type
, p_line_rec_tbl         IN  OUT NOCOPY          line_type_tbl
, p_lot_rec_tbl          IN  OUT NOCOPY          lot_type_tbl
)
IS
  l_api_name                  	CONSTANT VARCHAR2(30)   := 'Validate_transfer' ;
  l_api_version               	CONSTANT NUMBER         := 1.0 ;
  l_return_val                	NUMBER;
  x_ic_item_mst_row           	ic_item_mst%ROWTYPE;
  x_ic_whse_mst_row           	ic_whse_mst%ROWTYPE;
  x_sy_reas_cds_row           	sy_reas_cds%ROWTYPE;
  x_ic_lots_mst_row           	ic_lots_mst%ROWTYPE;
  x_ic_loct_inv_row           	ic_loct_inv%ROWTYPE;
  l_check_qty                 	NUMBER;
  l_org                       	INV_Validate.org;
  l_item                      	INV_Validate.item;
  l_sub                       	INV_Validate.sub;
  l_locator                   	INV_Validate.locator;
  l_odm_lot                   	INV_VALIDATE.lot;
  l_is_revision_control       	BOOLEAN;
  l_is_lot_control 		BOOLEAN;
  l_is_serial_control 		BOOLEAN;
  l_qoh           		NUMBER;
  l_rqoh          		NUMBER;
  l_qr            		NUMBER;
  l_qs          		NUMBER;
  l_att           		NUMBER;
  l_atr           		NUMBER;
  l_count                      	pls_integer;
  l_sqoh           		NUMBER;
  l_srqoh          		NUMBER;
  l_sqr            		NUMBER;
  l_sqs          		NUMBER;
  l_satt           		NUMBER;
  l_satr           		NUMBER;
  l_lot_count                   pls_integer;
  l_lot_rec_count               pls_integer;
  l_concat_segs                 VARCHAR2(4000);
  l_check_flag                  VARCHAR2(1);
  l_odm_txn_type_rec            inv_validate.transaction;
  l_opm_item_primary_uom_code   VARCHAR2(3);
  l_opm_item_secondary_uom_code VARCHAR2(3);

  Cursor Cur_get_assigment_type (Vorgn_code VARCHAR2) is
    SELECT d.assignment_type, o.co_code
    FROM   sy_docs_seq d, sy_orgn_mst o
    WHERE  o.orgn_code   = Vorgn_code
    AND    o.delete_mark = 0
    AND    d.orgn_code   = o.orgn_code
    AND    d.doc_type = 'DXFR'
    AND    d.delete_mark = 0;

  Cursor Cur_get_opm_fiscal_details (Vwhse_code VARCHAR2) IS
    SELECT p.co_code, p.sob_id, w.orgn_code, p.base_currency_code
    FROM   gl_plcy_mst p,
           ic_whse_mst w,
           sy_orgn_mst o
    WHERE  w.whse_code = Vwhse_code
    AND    o.orgn_code = w.orgn_code
    AND    p.co_code   = o.co_code;

  Cursor Cur_get_odm_fiscal_details (Vorganization_id NUMBER) IS
    SELECT  o.organization_code, o.set_of_books_id sob_id
    FROM    org_organization_definitions o,
            hr_all_organization_units h
    WHERE   o.organization_id = Vorganization_id
    AND     h.organization_id = o.organization_id
    AND     sysdate between nvl(h.date_from, sysdate) and nvl(h.date_to,sysdate);


  Cursor Cur_transfer_no_exists (Vtransfer_number VARCHAR2, Vorgn_code VARCHAR2) IS
  SELECT count(1)
  FROM   gmi_discrete_transfers
  WHERE  transfer_number   = Vtransfer_number
  AND    orgn_code         = Vorgn_code;

  /* Jalaj Srivastava Bug 3812701 */
  Cursor Cur_get_uom_code (Vum_code VARCHAR2) IS
  SELECT uom_code
  FROM   sy_uoms_mst
  WHERE  um_code = Vum_code;

  l_get_opm_fiscal_details_row Cur_get_opm_fiscal_details%ROWTYPE;
  l_get_odm_fiscal_details_row Cur_get_odm_fiscal_details%ROWTYPE;

CURSOR cur_item_gl_cls (p_item_id NUMBER) IS
       SELECT iim.gl_class
       FROM   ic_item_mst_b iim, ic_gled_cls igc
       WHERE  iim.item_id = p_item_id
       AND    iim.gl_class = igc.icgl_class;

     CURSOR Cur_gl_cls (p_item ic_item_mst.item_id%TYPE) IS
 	SELECT  gic.item_id, gcs.opm_class, gic.category_id, kfv.CONCATENATED_SEGMENTS,
 		mcv.description
 	  FROM mtl_categories_vl mcv, mtl_categories_b_kfv kfv, gmi_category_sets gcs, gmi_item_categories gic
 	 WHERE gcs.category_set_id IS NOT NULL
 	   AND gic.item_id = p_item
 	   AND gcs.opm_class IN ('GL_BUSINESS_CLASS', 'GL_PRODUCT_LINE')
 	   AND gcs.category_set_id = gic.category_set_id
 	   AND kfv.category_id = gic.category_id
 	   AND mcv.category_id = gic.category_id
 	 ORDER BY gic.item_id, gcs.opm_class ;

       v_business_class_found	BOOLEAN := FALSE;
       v_product_line_found	BOOLEAN := FALSE;
       gl_business_class_cat_id  gmi_item_categories.category_id%TYPE := NULL;
       gl_product_line_cat_id  gmi_item_categories.category_id%TYPE := NULL;
       item_gl_class ic_item_mst.gl_class%TYPE;
 --End  Supriya Malluru Bug#4114621

BEGIN

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  SAVEPOINT validate_transfer;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

    --this call will set up the profiles needed by the create lot engine
    --and transaction engine in OPM.
  IF (NOT GMIGUTL.SETUP(FND_GLOBAL.USER_NAME)) THEN
       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
          log_msg('Failed call to GMIGUTL.SETUP');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  INV_TRANS_DATE_OPTION := FND_PROFILE.Value('TRANSACTION_DATE');
  IF (INV_TRANS_DATE_OPTION IS NULL) THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_CONSTANT');
    FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','TRANSACTION_DATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --check for the WMS installation in FND_PRODUCT_INSTALLATION
  --this is used for checking material status for subinventory and locators.
  IF (inv_install.adv_inv_installed(NULL)) THEN
	WMS_INSTALLED := 'TRUE';
  ELSE
	WMS_INSTALLED := 'FALSE';
  END IF;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	log_msg('Begin validation of header record');
  END IF;

  -- Validate the orgn_code.
  IF NOT GMA_VALID_GRP.Validate_orgn_code(p_hdr_rec.orgn_code) THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ORGN_CODE');
      FND_MESSAGE.SET_TOKEN('ORGN_CODE',p_hdr_rec.orgn_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN  Cur_get_assigment_type(p_hdr_rec.orgn_code);
  FETCH Cur_get_assigment_type INTO p_hdr_rec.assignment_type, p_hdr_rec.co_code;
  IF (Cur_get_assigment_type%NOTFOUND) THEN
    CLOSE Cur_get_assigment_type;
    FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_NO_DCMNT_NMBRNG');
    FND_MESSAGE.SET_TOKEN('ORGN_CODE',p_hdr_rec.orgn_code);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE Cur_get_assigment_type;

  --For manual doc numbering, transfer no needs to be specified.
  IF (p_hdr_rec.assignment_type = 1) THEN
     IF (p_hdr_rec.transfer_number IS NULL) THEN
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_DXFR_NULL_TRANSFER_NO');
        FND_MESSAGE.SET_TOKEN('ORGN_CODE',p_hdr_rec.orgn_code);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
     ELSIF (p_hdr_rec.transfer_number IS NOT NULL) THEN
        --check if the transfer no doesnt exist already
        OPEN   Cur_transfer_no_exists(p_hdr_rec.transfer_number,p_hdr_rec.orgn_code) ;
        FETCH  Cur_transfer_no_exists INTO l_count;
        CLOSE  Cur_transfer_no_exists;
        IF (l_count > 0) THEN
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	    log_msg('Manual document numbering. This transfer no is in use already');
          END IF;
          FND_MESSAGE.SET_NAME ('GMI', 'GMI_DXFR_TRANSFER_NO_INVALID');
          FND_MESSAGE.SET_TOKEN('ORGN_CODE',p_hdr_rec.orgn_code);
          FND_MESSAGE.SET_TOKEN('TRANSFER_NO',p_hdr_rec.transfer_number);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;
  END IF;

  --validate the transfer type
  IF (p_hdr_rec.transfer_type NOT IN (0,1)) THEN
    FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_INVALID_TRANSFER_TYPE');
    FND_MESSAGE.SET_TOKEN('TRANSFER_TYPE',p_hdr_rec.transfer_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Validate the transaction type in ODM.
  --If transfer is Process to Discrete then the transaction type for ODM is MISC Receipt (42)
  --If transfer is Discrete to Process then the transaction type for ODM is MISC Issue   (32)
  IF (p_hdr_rec.transfer_type = 0 ) THEN
     l_odm_txn_type_rec.transaction_type_id := 42;
  ELSIF (p_hdr_rec.transfer_type = 1 ) THEN
     l_odm_txn_type_rec.transaction_type_id := 32;
  END IF;

  IF (inv_validate.transaction_type (l_odm_txn_type_rec) = inv_validate.F) THEN
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	log_msg('Failed call to inv_validate.transaction_type.');
     END IF;
     FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','TRANSACTION'),FALSE);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	log_msg('End validation of header record');
  END IF;


  /* ****start of validation for line level ***** */

  /*  All transaction types need an item. Make sure we have  */
  /*  one which can be used  */
  IF (p_line_rec_tbl.count = 0) THEN
    FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_NO_LINES');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR i in 1..p_line_rec_tbl.count LOOP --{
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	log_msg('Begin validation of Line record '||to_char(p_line_rec_tbl(i).line_no));
    END IF;

    BEGIN
      --line no should be unique for this transfer.
      FOR z in 1..p_line_rec_tbl.count LOOP --{
      	 IF (z <> i) AND (p_line_rec_tbl(z).line_no = p_line_rec_tbl(i).line_no) THEN
            FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SAME_LINE_NO');
            FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;

            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	       log_msg('Line number '||to_char(p_line_rec_tbl(i).line_no)||' present in more than one line');
            END IF;

         END IF;
      END LOOP;--}

      --check the odm inventory organization first for validity as we need it for
      --validating item in ODM.
      l_org.organization_id := p_line_rec_tbl(i).odm_inv_organization_id;

      IF (INV_Validate.Organization(l_org) = inv_validate.F) THEN
         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	   log_msg('failed call to INV_Validate.Organization');
         END IF;
         FND_MESSAGE.SET_NAME('INV','INV_INT_ORGCODE');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      /*  All lines need an item. Make sure we have  one which can be used  */
      x_ic_item_mst_row.item_no := NULL;
      x_ic_item_mst_row.item_id := p_line_rec_tbl(i).opm_item_id;
      IF ( GMIVDBL.ic_item_mst_select(x_ic_item_mst_row, x_ic_item_mst_row) ) THEN
         IF (x_ic_item_mst_row.noninv_ind = 1) THEN
                 FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ITEM_NO');
                 FND_MESSAGE.SET_TOKEN('ITEM_NO',x_ic_item_mst_row.item_no);
                 FND_MSG_PUB.Add;
                 RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSE
         FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_OPM_ITEM_ID_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ITEM_ID',p_line_rec_tbl(i).opm_item_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      p_line_rec_tbl(i).opm_item_no := x_ic_item_mst_row.item_no;

      IF (x_ic_item_mst_row.lot_ctl = 0) THEN
         p_line_rec_tbl(i).lot_control := 0;
      ELSIF (x_ic_item_mst_row.lot_ctl = 1) THEN
         p_line_rec_tbl(i).lot_control := 1;
      END IF;

      --Validate the item in ODM
      l_item.inventory_item_id := p_line_rec_tbl(i).odm_item_id;
      IF (inv_validate.Inventory_Item (l_item, l_org) = inv_validate.F) THEN
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	  log_msg('failed call to inv_validate.Inventory_Item');
        END IF;
        FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_ITEM');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (   (nvl(l_item.INVENTORY_ITEM_FLAG,'N') ='N')
          OR (nvl(l_item.MTL_TRANSACTIONS_ENABLED_FLAG,'N') = 'N')
          OR (nvl(l_item.SERIAL_NUMBER_CONTROL_CODE,1) <> 1)
         ) THEN
         FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_ITEM');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_item.revision_qty_control_code = 1) THEN
         p_line_rec_tbl(i).odm_item_revision := NULL;
      ELSIF (l_item.revision_qty_control_code = 2) THEN
         --Validate the item revision in ODM
         IF (p_line_rec_tbl(i).odm_item_revision IS NULL) THEN
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	     log_msg('For revision controlled item revision is null');
           END IF;
           FND_MESSAGE.SET_NAME('INV', 'INV_INT_REVCODE');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (inv_validate.revision (p_line_rec_tbl(i).odm_item_revision, l_org, l_item) = inv_validate.F) THEN
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	     log_msg('failed call to inv_validate.revision');
           END IF;
           FND_MESSAGE.SET_NAME('INV', 'INV_INT_REVCODE');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         SELECT count(1)
         INTO   l_count
         FROM   mtl_item_revisions
         WHERE  inventory_item_id = l_item.inventory_item_id
         AND    organization_id   = l_org.organization_id
         AND    revision          = p_line_rec_tbl(i).odm_item_revision
         AND    implementation_date IS NOT NULL;

         IF (l_count = 0) THEN
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	     log_msg('For revision controlled item revision implementation date is null');
           END IF;
           FND_MESSAGE.SET_NAME('INV', 'INV_INT_REVCODE');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;

      --We should be dealing with the same item in OPM/ODM
      IF (l_item.segment1 <> x_ic_item_mst_row.item_no) THEN
         FND_MESSAGE.SET_NAME ('GMI','GMI_DXFR_DIFF_ITEM');
         FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      /* **************************************************************
         Item should be either lot controlled both in opm/discrete or not
         lot controlled both in opm/discrete.
         ************************************************************** */
      IF (l_item.lot_control_code <> x_ic_item_mst_row.lot_ctl + 1) THEN
         FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_DIFF_LOT_CONTROL');
         FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Get uom_code for OPM item's primary UOM
      OPEN  Cur_get_uom_code(x_ic_item_mst_row.item_um);
      FETCH Cur_get_uom_code INTO l_opm_item_primary_uom_code;
      CLOSE Cur_get_uom_code;

      IF (l_item.primary_uom_code <> l_opm_item_primary_uom_code) THEN
         FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_DIFF_PRIM_UOM');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Get uom_code for OPM item's secondary UOM
      IF (x_ic_item_mst_row.item_um2 IS NOT NULL) THEN
        OPEN  Cur_get_uom_code(x_ic_item_mst_row.item_um2);
        FETCH Cur_get_uom_code INTO l_opm_item_secondary_uom_code;
        CLOSE Cur_get_uom_code;
      END IF;

      IF ( nvl(l_item.secondary_uom_code,' ') <> nvl(l_opm_item_secondary_uom_code,' ') ) THEN
         FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_DIFF_SEC_UOM');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      --lets see if the OPM warehouse is valid
      x_ic_whse_mst_row.whse_code := p_line_rec_tbl(i).opm_whse_code;
      IF ( GMIVDBL.ic_whse_mst_select(x_ic_whse_mst_row, x_ic_whse_mst_row) ) THEN
        NULL;
      ELSE
         FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_WHSE_CODE_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('WHSE_CODE',p_line_rec_tbl(i).opm_whse_code);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      --lets validate the ODM subinventory
      --when transfer is process to discrete then the FROM subinventory is the default
      --subinventory for the OPM warehouse which is a Inventory Org.
      --in this case the subinventory name is same as the whse code in OPM.
     --when transfer is discrete to process then the TO subinventory is the default
      --subinventory for the OPM warehouse which is a Inventory Org.
      --in this case the subinventory name is same as the whse code in OPM

      --we would not validate the subinventory for the process org.
      --We will only validate for ODM.


      --subinventory would be validated differently depending on whether
      --item is restricted subinventory controlled, profile INV:EXPENSE_TO_ASSET_TRANSFER.
      --and transaction type.
      --p_acct_txn is 1 when transaction_action_id is 1 (Misc Issue)
      --0 when any other transaction_action_id (27 for Misc receipt)

      l_sub.secondary_inventory_name := p_line_rec_tbl(i).odm_subinventory;
      IF (INV_VALIDATE.From_Subinventory
      		       (  p_sub       => l_sub
                         ,p_org       => l_org
                         ,p_item      => l_item
                         ,p_acct_txn  => p_hdr_rec.transfer_type
                       ) = inv_validate.F
         ) THEN
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	      log_msg('failed call to INV_Validate.from_subinventory');
           END IF;
           FND_MESSAGE.SET_NAME('INV','INV_INVALID_SUBINV');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
      END IF;

      --need to call overloaded INV_Validate.validatelocator depending on whether the
      --item is restricted locator controlled
      l_locator.inventory_location_id := p_line_rec_tbl(i).odm_locator_id;
      --{
      IF (     (l_org.stock_locator_control_code   = 1)
           OR  (     (l_org.stock_locator_control_code = 4)
                 AND (l_sub.locator_type = 1)
               )
           OR  (     (l_org.stock_locator_control_code = 4)
                 AND (l_sub.locator_type           = 5)
                 AND (l_item.location_control_code = 1)
               )
         ) THEN
           IF (p_line_rec_tbl(i).odm_locator_id IS NOT NULL) THEN
             IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                  log_msg('ODM locator id is not required as org/sub/item combination is non location controlled');
             END IF;
             FND_MESSAGE.SET_NAME('INV','INV_INT_LOCCODE');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	   END IF;
      ELSE
         IF (p_line_rec_tbl(i).odm_locator_id IS NULL) THEN
             IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                  log_msg('ODM locator id is required as org/sub/item combination is location controlled');
             END IF;
             FND_MESSAGE.SET_NAME('INV','INV_INT_LOCCODE');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	 END IF;


      END IF;--}


      --Get opm warehouse company and sob
      OPEN Cur_get_opm_fiscal_details(p_line_rec_tbl(i).opm_whse_code);
      FETCH Cur_get_opm_fiscal_details INTO l_get_opm_fiscal_details_row;
      IF (Cur_get_opm_fiscal_details%NOTFOUND) THEN
        CLOSE Cur_get_opm_fiscal_details;
        FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_OPM_NO_FISCAL_POLICY');
        FND_MESSAGE.SET_TOKEN('WHSE_CODE',p_line_rec_tbl(i).opm_whse_code);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE Cur_get_opm_fiscal_details;

      --Get ODM sob
      OPEN  Cur_get_odm_fiscal_details(p_line_rec_tbl(i).odm_inv_organization_id);
      FETCH Cur_get_odm_fiscal_details INTO l_get_odm_fiscal_details_row;
      IF (Cur_get_odm_fiscal_details%NOTFOUND) THEN
        CLOSE Cur_get_odm_fiscal_details;
        FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_ODM_NO_FISCAL_POLICY');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE Cur_get_odm_fiscal_details;

      --sets of books should be same for inventory organization and opm warehouse
      IF (l_get_opm_fiscal_details_row.sob_id <> l_get_odm_fiscal_details_row.sob_id) THEN
        FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_DIFF_SOB');
        FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Lets validate the transaction date in OPM
      l_return_val := GMICCAL.trans_date_validate
                      (  p_hdr_rec.trans_date
                       , p_hdr_rec.orgn_code
                       , p_line_rec_tbl(i).opm_whse_code
                      );
      IF (l_return_val <> 0) THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_TXN_POST_CLOSED');
        FND_MESSAGE.SET_TOKEN('WAREH', p_line_rec_tbl(i).opm_whse_code);
        FND_MESSAGE.SET_TOKEN('DATE', p_hdr_rec.trans_date);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (p_hdr_rec.trans_date > SYSDATE) THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_CANNOT_POST_FUTURE');
        FND_MESSAGE.SET_TOKEN('ITEM_NO'   , x_ic_item_mst_row.item_no);
        FND_MESSAGE.SET_TOKEN('TRANS_DATE', p_hdr_rec.trans_date);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --lets us validate the transaction date for discrete
      -- Check if past date is allowed...
     IF ((INV_TRANS_DATE_OPTION = 3) OR (INV_TRANS_DATE_OPTION = 4)) THEN
        INV_OPEN_PAST_PERIOD := TRUE;
     ELSE
        INV_OPEN_PAST_PERIOD := FALSE;
     END IF;
     -- Validate that the inventory period is open
     invttmtx.tdatechk (p_line_rec_tbl(i).odm_inv_organization_id,
                        trunc(p_hdr_rec.trans_date),
                        p_line_rec_tbl(i).odm_period_id,
                        INV_OPEN_PAST_PERIOD
                       );

     IF (p_line_rec_tbl(i).odm_period_id = 0) THEN
        FND_MESSAGE.SET_NAME('INV','INV_NO_OPEN_PERIOD');
	FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
     ELSIF (p_line_rec_tbl(i).odm_period_id = -1) THEN
        FND_MESSAGE.SET_NAME('INV', 'INV_RETRIEVE_PERIOD');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (INV_TRANS_DATE_OPTION = 3) THEN
        IF ( NOT INV_OPEN_PAST_PERIOD) THEN
            FND_MESSAGE.SET_NAME('INV','INV_NO_PAST_PERIOD');
            FND_MESSAGE.SET_TOKEN('ENTITY',p_hdr_rec.trans_date,TRUE);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
     ELSIF (INV_TRANS_DATE_OPTION = 4) THEN
        IF ( NOT INV_OPEN_PAST_PERIOD) THEN
            FND_MESSAGE.SET_NAME('INV','INV_NO_PAST_PERIOD');
            FND_MESSAGE.SET_TOKEN('ENTITY',p_hdr_rec.trans_date,TRUE);
            FND_MSG_PUB.Add;
        END IF;
     END IF;

     --validate the reason code for the transfer
     x_sy_reas_cds_row.reason_code := p_line_rec_tbl(i).opm_reason_code;
     IF GMIVDBL.sy_reas_cds_select(x_sy_reas_cds_row, x_sy_reas_cds_row) THEN
       IF (x_sy_reas_cds_row.reason_type = 1 AND p_hdr_rec.transfer_type = 0) THEN
        FND_MESSAGE.SET_NAME('GMI','IC_REASONTYPEINCREASE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_sy_reas_cds_row.reason_type = 2 AND p_hdr_rec.transfer_type = 1) THEN
        FND_MESSAGE.SET_NAME('GMI','IC_REASONTYPEDECREASE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_REASON_CODE');
      FND_MESSAGE.SET_TOKEN('REASON_CODE',p_line_rec_tbl(i).opm_reason_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Validate the discrete reason id
    --Entering the discrete reason id is optional.
    IF (p_line_rec_tbl(i).odm_reason_id IS NOT NULL) THEN
      IF (INV_Validate.Reason(p_line_rec_tbl(i).odm_reason_id) = inv_validate.F) THEN
         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
           log_msg('failed call to INV_Validate.Reason');
         END IF;
         FND_MESSAGE.SET_NAME('INV','INV_INT_REACODE');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    --For transfers the quantity should be positive
    IF (p_line_rec_tbl(i).quantity IS NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_NULL_QTY');
      FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (p_line_rec_tbl(i).quantity < 0) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_QTY_NOT_NEG');
      FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (p_line_rec_tbl(i).quantity = 0) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_ZERO_QTY');
      FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --lets validate the UOM  .
    --UOM should be same for lines and associated lot records
    /* Jalaj Srivastava Bug 3812701 */
    IF (      (p_line_rec_tbl(i).quantity_um <> x_ic_item_mst_row.item_um)
         AND  (NOT GMA_VALID_GRP.Validate_um(p_line_rec_tbl(i).quantity_um))
       ) THEN

        FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_UOM');
        FND_MESSAGE.SET_TOKEN('ITEM_NO',x_ic_item_mst_row.item_no);
        FND_MESSAGE.SET_TOKEN('UOM',p_line_rec_tbl(i).quantity_um);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* Jalaj Srivastava Bug 3812701 */
    /* Get uom_code for this um from sy_uoms_mst */

      OPEN  Cur_get_uom_code(p_line_rec_tbl(i).quantity_um);
      FETCH Cur_get_uom_code INTO p_line_rec_tbl(i).odm_quantity_uom_code;
      CLOSE Cur_get_uom_code;

    /* Jalaj Srivastava Bug 3812701 */
    /* Validate odm_quantity_uom_code in discrete */
    IF (inv_validate.uom(p_line_rec_tbl(i).odm_quantity_uom_code,l_org,l_item) = inv_validate.F) THEN
         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
           log_msg('failed call to inv_validate.uom');
         END IF;
         FND_MESSAGE.SET_NAME('INV','INV-NO ITEM UOM');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Lets Validate the locations in OPM
    IF  (   (x_ic_whse_mst_row.loct_ctl = 0)
         OR (x_ic_item_mst_row.loct_ctl = 0)
        ) THEN
           IF (nvl(p_line_rec_tbl(i).opm_location,GMIGUTL.IC$DEFAULT_LOCT) <> GMIGUTL.IC$DEFAULT_LOCT) THEN
             IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	        log_msg('Failed while validating OPM location. Item and/or warehouse are not location controlled');
             END IF;
             FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOCATION');
             FND_MESSAGE.SET_TOKEN('ITEM_NO',x_ic_item_mst_row.item_no);
             FND_MESSAGE.SET_TOKEN('LOCATION',p_line_rec_tbl(i).opm_location);
             FND_MESSAGE.SET_TOKEN('WHSE_CODE',p_line_rec_tbl(i).opm_whse_code);
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
           END IF;
           p_line_rec_tbl(i).opm_location := GMIGUTL.IC$DEFAULT_LOCT;
    ELSIF (    (x_ic_whse_mst_row.loct_ctl = 1)
           AND (x_ic_item_mst_row.loct_ctl = 1)
          ) THEN
          SELECT count(1) INTO l_count
          FROM   ic_loct_mst
          WHERE  whse_code = p_line_rec_tbl(i).opm_whse_code
          AND    location  = p_line_rec_tbl(i).opm_location
          AND    location  <> GMIGUTL.IC$DEFAULT_LOCT;

          IF (l_count = 0) THEN
             IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	        log_msg('Failed while validating OPM location. Item and warehouse are validated location controlled');
             END IF;
             FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOCATION');
             FND_MESSAGE.SET_TOKEN('ITEM_NO',x_ic_item_mst_row.item_no);
             FND_MESSAGE.SET_TOKEN('LOCATION',p_line_rec_tbl(i).opm_location);
             FND_MESSAGE.SET_TOKEN('WHSE_CODE',p_line_rec_tbl(i).opm_whse_code);
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
    ELSIF (    (x_ic_whse_mst_row.loct_ctl = 2)
           OR  (x_ic_item_mst_row.loct_ctl = 2)
          ) THEN
          SELECT count(1) INTO l_count
          FROM   ic_loct_inv
          WHERE  whse_code   = p_line_rec_tbl(i).opm_whse_code
          AND    location    = p_line_rec_tbl(i).opm_location
          AND    location    <> GMIGUTL.IC$DEFAULT_LOCT;

          --we could have non validated locations in OPM when transfer is from discrete to process.
          IF (l_count = 0) AND (p_hdr_rec.transfer_type = 0) THEN
             IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	        log_msg('Failed while validating OPM location. Item and/or warehouse are non validated location controlled');
             END IF;
             FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOCATION');
             FND_MESSAGE.SET_TOKEN('ITEM_NO',x_ic_item_mst_row.item_no);
             FND_MESSAGE.SET_TOKEN('LOCATION',p_line_rec_tbl(i).opm_location);
             FND_MESSAGE.SET_TOKEN('WHSE_CODE',p_line_rec_tbl(i).opm_whse_code);
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

    END IF;

    --lets validate the unit cost if entered by the user.
    IF (p_line_rec_tbl(i).odm_unit_cost IS NOT NULL) THEN
       IF (    (l_org.primary_cost_method   NOT IN ('2', '5', '6') )
            OR (l_item.inventory_asset_flag   <>    'Y')
            OR (l_sub.asset_inventory         <>     1)
          ) THEN
              FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_COST_SHOULD_BE_NULL');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    --Quantity at line level should be the same as the sum of quantities
    --at the lot levels.
    l_check_qty := 0;
    l_lot_count := 0;
    FOR k in 1..p_lot_rec_tbl.count LOOP
       IF (p_lot_rec_tbl(k).line_no = p_line_rec_tbl(i).line_no) THEN
         --If lot is specified at line level then it cannot be specified at lot level.
         --for non lot controlled items default lot could be specified only at the line level.
         IF (x_ic_item_mst_row.lot_ctl = 0) THEN
           FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_LOT_RECORD_NOT_NEEDED');
           FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF  (      (p_line_rec_tbl(i).opm_lot_id      IS NOT NULL)
                OR   (p_line_rec_tbl(i).odm_lot_number IS NOT NULL)
              ) THEN
              FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_INVALID_LOT_RECORDS');
              FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_check_qty := l_check_qty + p_lot_rec_tbl(k).quantity;
         l_lot_count := l_lot_count + 1;

       END IF;

    END LOOP;
    IF (l_lot_count > 0) THEN
       p_line_rec_tbl(i).lot_level := 1;
       IF (p_line_rec_tbl(i).quantity <> l_check_qty) THEN
            FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_LINE_LOT_QTY_DIFF');
            FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSIF (l_lot_count = 0) THEN
       p_line_rec_tbl(i).lot_level := 0;
       -- we will also assign a default lot_type record so that validations for lot can take place
       l_lot_rec_count := p_lot_rec_tbl.count + 1;
       p_lot_rec_tbl(l_lot_rec_count).line_no        := p_line_rec_tbl(i).line_no;
       p_lot_rec_tbl(l_lot_rec_count).opm_lot_id     := p_line_rec_tbl(i).opm_lot_id;
       p_lot_rec_tbl(l_lot_rec_count).odm_lot_number := p_line_rec_tbl(i).odm_lot_number;
       p_lot_rec_tbl(l_lot_rec_count).quantity       := p_line_rec_tbl(i).quantity;
       p_lot_rec_tbl(l_lot_rec_count).quantity2      := p_line_rec_tbl(i).quantity2;
    END IF;

    IF (x_ic_item_mst_row.dualum_ind > 0) THEN
      p_line_rec_tbl(i).quantity2 := 0;
    ELSIF (x_ic_item_mst_row.dualum_ind = 0) THEN
      p_line_rec_tbl(i).quantity2 := NULL;
    END IF;

    --lets start validating the lots and the quantities
    --{
      --We need to capture this as ODM may change the transaction qty at lot level
      --to conform to rules defined in MTL.
      FOR j in 1..p_lot_rec_tbl.count LOOP
        BEGIN
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	        log_msg('Begin validation of lot. lot record no '||to_char(j));
          END IF;
          IF (p_lot_rec_tbl(j).line_no = p_line_rec_tbl(i).line_no) THEN --{

            IF (p_lot_rec_tbl(j).quantity < 0) THEN
              FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_LOT_QTY_NOT_NEG');
              FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
              FND_MESSAGE.SET_TOKEN('LOT_ID',p_lot_rec_tbl(j).opm_lot_id);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            ELSIF (p_lot_rec_tbl(j).quantity = 0) THEN
              FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_LOT_ZERO_QTY');
              FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
              FND_MESSAGE.SET_TOKEN('LOT_ID',p_lot_rec_tbl(j).opm_lot_id);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            --transfer is from process to discrete
            --{
            IF (p_hdr_rec.transfer_type = 0) THEN
              IF (x_ic_item_mst_row.lot_ctl = 0) THEN
                 IF (p_lot_rec_tbl(j).opm_lot_id <> 0) THEN
                    FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_OPM_LOT_IS_NOT_DEFAULT');
                    FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
                    FND_MESSAGE.SET_TOKEN('ITEM_NO',x_ic_item_mst_row.item_no);
                    FND_MSG_PUB.Add;
                    RAISE FND_API.G_EXC_ERROR;

                 END IF;

              ELSIF (x_ic_item_mst_row.lot_ctl = 1) THEN
                 IF (p_lot_rec_tbl(j).opm_lot_id = 0) THEN
                    FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_OPM_LOT_IS_DEFAULT');
                    FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
                    FND_MESSAGE.SET_TOKEN('ITEM_NO',x_ic_item_mst_row.item_no);
                    FND_MSG_PUB.Add;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
               	 IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
     	          log_msg('Start validating OPM lot when transfer type is 0');
                 END IF;

                 BEGIN
                   SELECT * INTO x_ic_lots_mst_row
                   FROM   ic_lots_mst
                   WHERE  item_id = p_line_rec_tbl(i).opm_item_id
                   AND    lot_id  = p_lot_rec_tbl(j).opm_lot_id;

                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_LOT_NOT_FOUND');
                     FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
                     FND_MESSAGE.SET_TOKEN('LOT_ID',p_lot_rec_tbl(j).opm_lot_id);
                     FND_MSG_PUB.Add;
                     RAISE FND_API.G_EXC_ERROR;

                 END;

              END IF;


              p_lot_rec_tbl(j).opm_lot_no    		:= x_ic_lots_mst_row.lot_no;
              p_lot_rec_tbl(j).opm_sublot_no 		:= x_ic_lots_mst_row.sublot_no;
              p_lot_rec_tbl(j).opm_lot_expiration_date 	:= x_ic_lots_mst_row.expire_date;
              p_lot_rec_tbl(j).opm_grade                := x_ic_lots_mst_row.qc_grade;

              --now lets check whether there is inventory to transfer from OPM to ODM
              x_ic_loct_inv_row.whse_code  := p_line_rec_tbl(i).opm_whse_code;
              x_ic_loct_inv_row.location   := p_line_rec_tbl(i).opm_location;
              x_ic_loct_inv_row.item_id    := p_line_rec_tbl(i).opm_item_id;
              x_ic_loct_inv_row.lot_id     := p_lot_rec_tbl(j).opm_lot_id;



              --{
              IF GMIVDBL.ic_loct_inv_select(x_ic_loct_inv_row, x_ic_loct_inv_row) THEN
                --store quantities in opm item UOM and ODM item UOM

                p_lot_rec_tbl(j).opm_lot_status      := x_ic_loct_inv_row.lot_status;
                l_return_val := GMICUOM.uom_conversion
                                      (
                                       x_ic_item_mst_row.item_id,
                                       nvl(x_ic_lots_mst_row.lot_id,0),
                                       p_lot_rec_tbl(j).quantity,
                                       p_line_rec_tbl(i).quantity_um,
                                       x_ic_item_mst_row.item_um,
                                       0
                                       );
                IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         	     log_msg('After calling GMICUOM.uom_conversion to get opm_primary_quantity when transfer type is 0. return val is '||l_return_val);
                END IF;
                IF(l_return_val >= 0) THEN
                   p_lot_rec_tbl(j).opm_primary_quantity  := l_return_val;
                END IF;

                IF (l_return_val < 0) THEN
                  IF (l_return_val = -1) THEN
                    FND_MESSAGE.set_name('GMI', 'IC_UOMCV_PACKAGE_ERR');
                  ELSIF (l_return_val = -3) THEN
                    FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURUMTYPE_ERR');
                  ELSIF (l_return_val = -4) THEN
                    FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NEWUMTYPE_ERR');
                  ELSIF (l_return_val = -5) THEN
                    FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
                    FND_MESSAGE.set_token('FROMUOM',p_line_rec_tbl(i).quantity_um);
                    FND_MESSAGE.set_token('TOUOM',x_ic_item_mst_row.item_um);
                  ELSIF (l_return_val = -6) THEN
                    FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUMTYPE_ERR');
                  ELSIF (l_return_val = -7) THEN
                    FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURFACTOR_ERR');
                  ELSIF (l_return_val = -10) THEN
                    FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
                    FND_MESSAGE.set_token('FROMUOM',p_line_rec_tbl(i).quantity_um);
                    FND_MESSAGE.set_token('TOUOM',x_ic_item_mst_row.item_um);
                  ELSIF (l_return_val = -11) THEN
                    FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NOITEMID_ERR');
                  ELSIF (l_return_val < -11) THEN
                    FND_MESSAGE.set_name('GMI', 'IC_UOMCV_FATAL_ERR');
                  END IF;
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (     (x_ic_item_mst_row.lot_indivisible = 1)
                     AND (x_ic_loct_inv_row.loct_onhand <> p_lot_rec_tbl(j).opm_primary_quantity)
                   ) THEN
                     FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_INDIVISIBLE_LOT');
                     FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
                     FND_MESSAGE.SET_TOKEN('LOT_ID',p_lot_rec_tbl(j).opm_lot_id);
                     FND_MSG_PUB.Add;
                     RAISE FND_API.G_EXC_ERROR;
                END IF;
              ELSE
                   FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_CANNOT_GET_ONHAND');
                   FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
                   FND_MESSAGE.SET_TOKEN('LOT_ID',p_lot_rec_tbl(j).opm_lot_id);
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
              END IF;--}

              --lets check the deviation between OPM primary and secondary if secondary is passed
              --if it is not passed we calculate the secondary qty.
              IF (x_ic_item_mst_row.dualum_ind > 0) THEN
                IF (x_ic_loct_inv_row.loct_onhand = p_lot_rec_tbl(j).opm_primary_quantity) THEN
                    p_lot_rec_tbl(j).quantity2 := x_ic_loct_inv_row.loct_onhand2;
                ELSE
                  IF (p_lot_rec_tbl(j).quantity2 IS NULL) THEN

                    IF (x_ic_item_mst_row.dualum_ind = 3) THEN
                       FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_NULL_QTY2');
                       FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
                       FND_MESSAGE.SET_TOKEN('ITEM_NO',x_ic_item_mst_row.item_no);
                       FND_MSG_PUB.Add;
                       RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    l_return_val := GMICUOM.uom_conversion
                                      (
                                       x_ic_item_mst_row.item_id,
                                       nvl(x_ic_lots_mst_row.lot_id,0),
                                       p_lot_rec_tbl(j).quantity,
                                       p_line_rec_tbl(i).quantity_um,
                                       x_ic_item_mst_row.item_um2,
                                       0
                                       );
                    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         	      log_msg('After calling GMICUOM.uom_conversion to get quantity2 when transfer type is 0. return val is '||l_return_val);
                    END IF;

                    IF(l_return_val >= 0) THEN
                      p_lot_rec_tbl(j).quantity2  := l_return_val;
                    END IF;

                    IF (l_return_val < 0) THEN
                      IF (l_return_val = -1) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_PACKAGE_ERR');
                      ELSIF (l_return_val = -3) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURUMTYPE_ERR');
                      ELSIF (l_return_val = -4) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NEWUMTYPE_ERR');
                      ELSIF (l_return_val = -5) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
                        FND_MESSAGE.set_token('FROMUOM',p_line_rec_tbl(i).quantity_um);
                        FND_MESSAGE.set_token('TOUOM',x_ic_item_mst_row.item_um2);
                      ELSIF (l_return_val = -6) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUMTYPE_ERR');
                      ELSIF (l_return_val = -7) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURFACTOR_ERR');
                      ELSIF (l_return_val = -10) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
                        FND_MESSAGE.set_token('FROMUOM',p_line_rec_tbl(i).quantity_um);
                        FND_MESSAGE.set_token('TOUOM',x_ic_item_mst_row.item_um2);
                      ELSIF (l_return_val = -11) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NOITEMID_ERR');
                      ELSIF (l_return_val < -11) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_FATAL_ERR');
                      END IF;
                      FND_MSG_PUB.ADD;
                      RAISE FND_API.G_EXC_ERROR;
                    END IF;
                  END IF;
                END IF;
              ELSIF (x_ic_item_mst_row.dualum_ind = 0) THEN
                p_lot_rec_tbl(j).quantity2 := NULL;
              END IF;

              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         	 log_msg('Transfer type is 0. checking if the OPM lot already exists in discrete');
              END IF;

	      --Lets see if the OPM lot already exists in discrete
	      --lets get the ODM lot
	      --{
              IF (x_ic_item_mst_row.lot_ctl = 1) THEN

                l_odm_lot.lot_number  := p_lot_rec_tbl(j).odm_lot_number;

                --{
                IF (INV_Validate.lot_number (p_lot		=> l_odm_lot,
                                             p_org		=> l_org,
                                             p_item             => l_item
                                            ) = inv_validate.F) THEN


                    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                      log_msg('ODM lot does not previously exist when transfer type is 0');
                    END IF;

                    IF (l_item.shelf_life_code = 1) THEN
                      p_lot_rec_tbl(j).odm_lot_expiration_date := NULL;
                    ELSE
                      p_lot_rec_tbl(j).odm_lot_expiration_date := p_lot_rec_tbl(j).opm_lot_expiration_date;
                    END IF;
              END IF;--}

              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         	 log_msg('Transfer type is 0. End of check whether the OPM lot already exists in discrete');
              END IF;

              --OPM is migrating all lot specific conversions to discrete as is
              --we can assume that discrete qtys are same as opm qtys
              p_lot_rec_tbl(j).odm_primary_quantity := p_lot_rec_tbl(j).opm_primary_quantity;

              --ODM primary quantity validations
              -- if item has indivisible flag set, then make sure that quantity is integer in
              -- primary UOM

              IF (      ( l_item.indivisible_flag = 'Y' )
                   AND  ( Round(p_lot_rec_tbl(j).odm_primary_quantity,(38-1)) <> TRUNC(p_lot_rec_tbl(j).odm_primary_quantity))
                 ) then
                FND_MESSAGE.SET_NAME('INV', 'DIVISIBILITY_VIOLATION');
                FND_MSG_PUB.Add;
	        RAISE FND_API.G_EXC_ERROR ;
              END IF;

              END IF;--}
            --transfer is from discrete to process
            ELSIF (p_hdr_rec.transfer_type = 1) THEN
              --lets validate the ODM Lot number
              --{
              IF (l_item.lot_control_code = 1) THEN
                 IF (p_lot_rec_tbl(j).odm_lot_number IS NOT NULL) THEN
                    FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_ODM_LOT_IS_NOT_NULL');
                    FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
                    FND_MESSAGE.SET_TOKEN('ITEM_NO',x_ic_item_mst_row.item_no);
                    FND_MSG_PUB.Add;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

              END IF;--}

              l_odm_lot.lot_number := p_lot_rec_tbl(j).odm_lot_number;
              --{
              IF (l_item.lot_control_code = 2) THEN

                 IF (p_lot_rec_tbl(j).odm_lot_number IS NULL) THEN
                    FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_ODM_LOT_IS_NULL');
                    FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
                    FND_MESSAGE.SET_TOKEN('ITEM_NO',x_ic_item_mst_row.item_no);
                    FND_MSG_PUB.Add;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

              END IF;--}

              --Lets see if the ODM lot already exists in OPM
              IF (x_ic_item_mst_row.lot_ctl = 1) THEN

                   --get the opm lot row
                   SELECT *
                   INTO   x_ic_lots_mst_row
                   FROM   ic_lots_mst
                   WHERE  ITEM_ID        = x_ic_item_mst_row.item_id
                   AND    lot_id         = p_lot_rec_tbl(j).opm_lot_id;


                   p_lot_rec_tbl(j).opm_lot_no    		:= x_ic_lots_mst_row.lot_no;
                   p_lot_rec_tbl(j).opm_sublot_no 		:= x_ic_lots_mst_row.sublot_no;
                   p_lot_rec_tbl(j).opm_grade			:= x_ic_lots_mst_row.qc_grade;
                   p_lot_rec_tbl(j).opm_lot_expiration_date	:= x_ic_lots_mst_row.expire_date;

                   --We need this get the lot_status of the OPM lot.
                   x_ic_loct_inv_row.whse_code  := p_line_rec_tbl(i).opm_whse_code;
                   x_ic_loct_inv_row.location   := p_line_rec_tbl(i).opm_location;
                   x_ic_loct_inv_row.item_id    := p_line_rec_tbl(i).opm_item_id;
                   x_ic_loct_inv_row.lot_id     := p_lot_rec_tbl(j).opm_lot_id;

                   IF GMIVDBL.ic_loct_inv_select(x_ic_loct_inv_row, x_ic_loct_inv_row) THEN
                     p_lot_rec_tbl(j).opm_lot_status      := x_ic_loct_inv_row.lot_status;
                   ELSE
                     IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         	       log_msg('Failed call to GMIVDBL.ic_loct_inv_select when transfer type is 1. Not an error.');
                     END IF;
                   END IF;

              END IF;

              --Now lets calcualte the primary qty for OPM.
              --we needed the lot id before that since if the lot existed
              --conversion could have been lot specific.

              l_return_val := GMICUOM.uom_conversion
                                      (
                                       x_ic_item_mst_row.item_id,
                                       nvl(p_lot_rec_tbl(j).opm_lot_id,0),
                                       p_lot_rec_tbl(j).quantity,
                                       p_line_rec_tbl(i).quantity_um,
                                       x_ic_item_mst_row.item_um,
                                       0
                                       );

              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         	log_msg('After calling GMICUOM.uom_conversion to get opm_primary_quantity when transfer type is 1. return val is '||l_return_val);
              END IF;

              IF(l_return_val >= 0) THEN
                p_lot_rec_tbl(j).opm_primary_quantity  := l_return_val;
              END IF;

              IF (l_return_val < 0) THEN
                IF (l_return_val = -1) THEN
                  FND_MESSAGE.set_name('GMI', 'IC_UOMCV_PACKAGE_ERR');
                ELSIF (l_return_val = -3) THEN
                  FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURUMTYPE_ERR');
                ELSIF (l_return_val = -4) THEN
                  FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NEWUMTYPE_ERR');
                ELSIF (l_return_val = -5) THEN
                  FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
                  FND_MESSAGE.set_token('FROMUOM',p_line_rec_tbl(i).quantity_um);
                  FND_MESSAGE.set_token('TOUOM',x_ic_item_mst_row.item_um);
                ELSIF (l_return_val = -6) THEN
                  FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUMTYPE_ERR');
                ELSIF (l_return_val = -7) THEN
                  FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURFACTOR_ERR');
                ELSIF (l_return_val = -10) THEN
                  FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
                  FND_MESSAGE.set_token('FROMUOM',p_line_rec_tbl(i).quantity_um);
                  FND_MESSAGE.set_token('TOUOM',x_ic_item_mst_row.item_um);
                ELSIF (l_return_val = -11) THEN
                  FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NOITEMID_ERR');
                ELSIF (l_return_val < -11) THEN
                  FND_MESSAGE.set_name('GMI', 'IC_UOMCV_FATAL_ERR');
                END IF;
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              IF (x_ic_item_mst_row.dualum_ind > 0) THEN
                  IF (p_lot_rec_tbl(j).quantity2 IS NULL) THEN

                    IF (x_ic_item_mst_row.dualum_ind = 3) THEN
                       FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_NULL_QTY2');
                       FND_MESSAGE.SET_TOKEN('LINE_NO',p_line_rec_tbl(i).line_no);
                       FND_MESSAGE.SET_TOKEN('ITEM_NO',x_ic_item_mst_row.item_no);
                       FND_MSG_PUB.Add;
                       RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    l_return_val := GMICUOM.uom_conversion
                                      (
                                       x_ic_item_mst_row.item_id,
                                       nvl(p_lot_rec_tbl(j).opm_lot_id,0),
                                       p_lot_rec_tbl(j).quantity,
                                       p_line_rec_tbl(i).quantity_um,
                                       x_ic_item_mst_row.item_um2,
                                       0
                                       );

                    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         	      log_msg('After calling GMICUOM.uom_conversion to get quantity2 when transfer type is 1. return val is '||l_return_val);
                    END IF;

                    IF(l_return_val >= 0) THEN
                      p_lot_rec_tbl(j).quantity2  := l_return_val;
                    END IF;

                    IF (l_return_val < 0) THEN
                      IF (l_return_val = -1) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_PACKAGE_ERR');
                      ELSIF (l_return_val = -3) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURUMTYPE_ERR');
                      ELSIF (l_return_val = -4) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NEWUMTYPE_ERR');
                      ELSIF (l_return_val = -5) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
                        FND_MESSAGE.set_token('FROMUOM',p_line_rec_tbl(i).quantity_um);
                        FND_MESSAGE.set_token('TOUOM',x_ic_item_mst_row.item_um2);
                      ELSIF (l_return_val = -6) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUMTYPE_ERR');
                      ELSIF (l_return_val = -7) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURFACTOR_ERR');
                      ELSIF (l_return_val = -10) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
                        FND_MESSAGE.set_token('FROMUOM',p_line_rec_tbl(i).quantity_um);
                        FND_MESSAGE.set_token('TOUOM',x_ic_item_mst_row.item_um2);
                      ELSIF (l_return_val = -11) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NOITEMID_ERR');
                      ELSIF (l_return_val < -11) THEN
                        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_FATAL_ERR');
                      END IF;
                      FND_MSG_PUB.ADD;
                      RAISE FND_API.G_EXC_ERROR;
                    END IF;

                  END IF;
              ELSIF (x_ic_item_mst_row.dualum_ind = 0) THEN
                p_lot_rec_tbl(j).quantity2 := NULL;
              END IF;
            END IF;--}
            p_lot_rec_tbl(j).odm_primary_quantity := p_lot_rec_tbl(j).opm_primary_quantity;
            --add the quantities at lot to get quantities at the line level
            p_line_rec_tbl(i).odm_primary_quantity := nvl(p_line_rec_tbl(i).odm_primary_quantity,0) + p_lot_rec_tbl(j).odm_primary_quantity;
            p_line_rec_tbl(i).opm_primary_quantity := nvl(p_line_rec_tbl(i).opm_primary_quantity,0) + p_lot_rec_tbl(j).opm_primary_quantity;

            IF (x_ic_item_mst_row.dualum_ind > 0) THEN
              p_line_rec_tbl(i).quantity2 := p_line_rec_tbl(i).quantity2 + p_lot_rec_tbl(j).quantity2;
            END IF;

            IF (p_line_rec_tbl(i).lot_control = 0) THEN
               p_lot_rec_tbl(j).opm_lot_id              := 0;
               p_lot_rec_tbl(j).opm_lot_status          := NULL;
               p_lot_rec_tbl(j).opm_grade               := NULL;
               p_lot_rec_tbl(j).odm_lot_number          := NULL;
               p_lot_rec_tbl(j).odm_lot_expiration_date := NULL;
               p_lot_rec_tbl(j).opm_lot_expiration_date := NULL;
            END IF;

          END IF ;
          --}
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	        log_msg('Ending validation of lot.lot record no '||to_char(j));
          END IF;

        END;
      END LOOP; --This for lot belonging to the line.

      /* if the line has the lot information then we will assign line level attributes from
         the lot record */

         IF (p_line_rec_tbl(i).lot_level = 0) THEN
             --this means a default lot record was created for this line
             p_line_rec_tbl(i).opm_lot_no		:= p_lot_rec_tbl(l_lot_rec_count).opm_lot_no;
             p_line_rec_tbl(i).opm_sublot_no		:= p_lot_rec_tbl(l_lot_rec_count).opm_sublot_no;
             p_line_rec_tbl(i).odm_lot_number          	:= p_lot_rec_tbl(l_lot_rec_count).odm_lot_number;
             p_line_rec_tbl(i).opm_lot_expiration_date 	:= p_lot_rec_tbl(l_lot_rec_count).opm_lot_expiration_date;
             p_line_rec_tbl(i).odm_lot_expiration_date 	:= p_lot_rec_tbl(l_lot_rec_count).odm_lot_expiration_date;
             p_line_rec_tbl(i).opm_lot_id              	:= p_lot_rec_tbl(l_lot_rec_count).opm_lot_id;
             p_line_rec_tbl(i).opm_lot_status          	:= p_lot_rec_tbl(l_lot_rec_count).opm_lot_status;
             p_line_rec_tbl(i).opm_grade              	:= p_lot_rec_tbl(l_lot_rec_count).opm_grade;

             --we dont need the dummy lot record anymore.
             p_lot_rec_tbl.DELETE(l_lot_rec_count);
         END IF;
    --}
    --OK line has been validated and lots belonging to the lines have been validated
    --lets get the charge accounts.

 --Begin Supriya Malluru Bug#4114621
  IF (p_line_rec_tbl(i).opm_item_no IS NOT NULL) THEN
         item_gl_class := x_ic_item_mst_row.gl_class;
           OPEN cur_item_gl_cls(p_line_rec_tbl(i).opm_item_id);
           FETCH cur_item_gl_cls
           INTO  item_gl_class;

         IF cur_item_gl_cls%NOTFOUND THEN
             item_gl_class := NULL;
           END IF;

           -- Populate GL Business Class and GL Product Line for the Item entered.
   	FOR x in Cur_gl_cls(p_line_rec_tbl(i).opm_item_id)
   	LOOP
   	  IF x.opm_class = 'GL_BUSINESS_CLASS' THEN
               v_business_class_found := TRUE;
   	    IF x.category_id IS NULL THEN
   	     gl_business_class_cat_id := '';
   	    ELSE
   	      IF (gl_business_class_cat_id IS NULL) OR
   		 (gl_business_class_cat_id <> x.category_id) THEN
   		gl_business_class_cat_id := x.category_id;
   	      END IF;
   	    END IF;
   	  END IF;
             IF x.opm_class = 'GL_PRODUCT_LINE' THEN
               v_product_line_found := TRUE;
               IF x.category_id IS NULL THEN
                 gl_product_line_cat_id := '';
               ELSE
                 IF (gl_product_line_cat_id IS NULL) OR
                    (gl_product_line_cat_id <> x.category_id) THEN
                   gl_product_line_cat_id := x.category_id;
                 END IF;
               END IF;
             END IF;
   	END LOOP;

        IF (NOT v_business_class_found) THEN
          	  gl_business_class_cat_id := NULL;
           END IF;

           IF (NOT v_product_line_found) THEN
             gl_product_line_cat_id := NULL;
           END IF;

       END IF;
--End Supriya Malluru Bug#4114621

    gmf_get_mappings.get_account_mappings
         ( v_co_code                    => l_get_opm_fiscal_details_row.co_code
          ,v_orgn_code                  => l_get_opm_fiscal_details_row.orgn_code
          ,v_whse_code                  => p_line_rec_tbl(i).opm_whse_code
          ,v_item_id                    => p_line_rec_tbl(i).opm_item_id
          ,v_reason_code                => p_line_rec_tbl(i).opm_reason_code
          ,v_sub_event_type             => 31010 /* IADJ */
          ,v_acct_ttl_type              => 6000  /* IVA */
          ,v_source                     => 7 /* IC */
          ,v_vendor_id                  => NULL
          ,v_cust_id                    => NULL
          ,v_icgl_class                 => x_ic_item_mst_row.gl_class
          ,v_vendgl_class               => NULL
          ,v_custgl_class               => NULL
          ,v_currency_code              => l_get_opm_fiscal_details_row.base_currency_code
          ,v_routing_id                 => NULL
          ,v_charge_id                  => NULL
          ,v_taxauth_id                 => NULL
          ,v_aqui_cost_id               => NULL
          ,v_resources                  => NULL
          ,v_cost_cmpntcls_id           => NULL
          ,v_cost_analysis_code         => NULL
          ,v_order_type                 => NULL
          ,v_acct_id                    => p_line_rec_tbl(i).opm_charge_acct_id
          ,v_acctg_unit_id              => p_line_rec_tbl(i).opm_charge_au_id
          ,v_business_class_cat_id      => gl_business_class_cat_id       --Bug#4114621
          ,v_product_line_cat_id        => gl_product_line_cat_id   	         --Bug#4114621
         );

       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
          log_msg('After call to gmf_get_mappings.get_account_mappings ');
       END IF;
       --now lets get the ccid (same as ODM charge acct id)
       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
          log_msg('Before call to gmf_validate_account.get_accu_acct_ids ');
       END IF;

       --get ccid which is the same as odm_charge_account_id
       gmf_validate_account.validate_segments
               (
                p_co_code               => l_get_opm_fiscal_details_row.co_code,
                p_acctg_unit_id         => p_line_rec_tbl(i).opm_charge_au_id,
                p_acct_id               => p_line_rec_tbl(i).opm_charge_acct_id,
                p_acctg_unit_no         => NULL,
                p_acct_no               => NULL,
                p_create_combination    => 'Y',
                x_ccid                  => p_line_rec_tbl(i).odm_charge_account_id,
                x_concat_seg            => l_concat_segs,
                x_status                => x_return_status,
                x_errmsg                => x_msg_data
               );

       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
          log_msg('After call to gmf_validate_account.validate_segments. return status is ' ||x_return_status);
       END IF;

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.SET_NAME ('GMI','GMI_SET_STRING');
            FND_MESSAGE.SET_TOKEN('STRING', substrb(x_msg_data,1,240));
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

    END;
  END LOOP; -- this for the lines.
  --}

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK to validate_transfer;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK to validate_transfer;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK to validate_transfer;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (SQLCODE IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
        FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
        FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
    END IF;

    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);


END Validate_transfer;

/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    construct_post_records                                           |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |    constructs and posts process/discrete transfer    records to          |
 |    tables gmi_discrete_transfers, gmi_discrete_transfers                 |
 |    and gmi_discrete_transfer_lots.                                       |
 |    It will also create lots in OPM and ODM if the lot does not exist.    |
 |    It would created transactions and update balances in OPM inventory    |
 |    and Oracle Inventory                                                  |
 |                                                                          |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Jalaj Srivastava                                              |
 |  RLNAGARA Material Status Migration ME - Updating Status in MOQD         |
 |                                                                          |
 +==========================================================================+ */

PROCEDURE construct_post_records
( p_api_version          IN              NUMBER
, p_init_msg_list        IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN              NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY      VARCHAR2
, x_msg_count            OUT NOCOPY      NUMBER
, x_msg_data             OUT NOCOPY      VARCHAR2
, p_hdr_rec              IN OUT NOCOPY   hdr_type
, p_line_rec_tbl         IN OUT NOCOPY   line_type_tbl
, p_lot_rec_tbl          IN OUT NOCOPY   lot_type_tbl
, x_hdr_row              OUT NOCOPY      gmi_discrete_transfers%ROWTYPE
, x_line_row_tbl         OUT NOCOPY      line_row_tbl
, x_lot_row_tbl          OUT NOCOPY      lot_row_tbl
) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'construct_post_records' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;
  l_no_violation       BOOLEAN;
  l_return_val         NUMBER;

  --rlnagara 2 Material Status Migration ME
  l_lot_ctl NUMBER;
  l_lot_sts VARCHAR2(10);

BEGIN

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  SAVEPOINT create_transfer;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  --lets prepare the header record.
  IF (p_hdr_rec.assignment_type = 2) THEN
    --automatic numbering
    p_hdr_rec.transfer_number    := GMIVDBX.Get_doc_no
    				       (
					  x_return_status        =>  x_return_status
					, x_msg_count            =>  x_msg_count
					, x_msg_data             =>  x_msg_data
					, p_doc_type             =>  'DXFR'
					, p_orgn_code            =>  p_hdr_rec.orgn_code
                                       );

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
      log_msg('After calling GMIVDBX.Get_doc_no.return status is '||x_return_status);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  IF (NVL(p_hdr_rec.transfer_number, ' ') = ' ') THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_DOC_NO');
    FND_MESSAGE.SET_TOKEN('DOC_TYPE','DXFR');
    FND_MESSAGE.SET_TOKEN('ORGN_CODE',p_hdr_rec.orgn_code);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --lets insert the header record.

  GMIVDBX.header_insert
      (
	  p_api_version          =>  p_api_version
	, p_init_msg_list        =>  FND_API.G_FALSE
	, p_commit               =>  FND_API.G_FALSE
	, p_validation_level     =>  p_validation_level
	, x_return_status        =>  x_return_status
	, x_msg_count            =>  x_msg_count
	, x_msg_data             =>  x_msg_data
	, p_hdr_rec              =>  p_hdr_rec
	, x_hdr_row              =>  x_hdr_row
      );

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	log_msg('After calling GMIVDBX.header_insert.return status is '||x_return_status);
  END IF;

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --now we will insert the lines and the lots.
  FOR i in 1..p_line_rec_tbl.count LOOP --{
    BEGIN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	log_msg('Constructing record for posting line no '||to_char(i));
      END IF;
      --lot could be sepcified at the lot level or the line level.
      --we are ready to insert records in gmi_discrete_transfer_lines
      GMIVDBX.line_insert
              (
	  	  p_api_version          =>  p_api_version
		, p_init_msg_list        =>  FND_API.G_FALSE
		, p_commit               =>  FND_API.G_FALSE
		, p_validation_level     =>  p_validation_level
		, x_return_status        =>  x_return_status
		, x_msg_count            =>  x_msg_count
		, x_msg_data             =>  x_msg_data
                , p_hdr_row              =>  x_hdr_row
                , p_line_rec             =>  p_line_rec_tbl(i)
                , x_line_row             =>  x_line_row_tbl(i)
               );

      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	 log_msg('After call to procedure GMIVDBX.line_insert return status is '||x_return_status);
      END IF;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --{
      IF (p_line_rec_tbl(i).lot_level = 1) THEN
         --start processing lots.
        FOR j in 1..p_lot_rec_tbl.count LOOP --{
          --{
          IF (p_lot_rec_tbl(j).line_no = p_line_rec_tbl(i).line_no) THEN

            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	       log_msg('Constructing record for posting line no '||to_char(i)||' and lot record '||to_char(j));
            END IF;

            --OK lets insert records in gmi_transfer_lots.
            GMIVDBX.lot_insert
               (
  	  	  p_api_version          =>  p_api_version
		, p_init_msg_list        =>  FND_API.G_FALSE
		, p_commit               =>  FND_API.G_FALSE
		, p_validation_level     =>  p_validation_level
		, x_return_status        =>  x_return_status
		, x_msg_count            =>  x_msg_count
		, x_msg_data             =>  x_msg_data
                , p_line_row             =>  x_line_row_tbl(i)
                , p_lot_rec              =>  p_lot_rec_tbl(j)
                , x_lot_row              =>  x_lot_row_tbl(j)
               );

      	    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	      log_msg('After call to procedure GMIVDBX.lot_insert return status is '||x_return_status);
            END IF;
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

          END IF;--}

        END LOOP;--} --LOOP for lots with lot specified at the lot level.

      END IF; --}

      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	log_msg('Calling GMIVTDX.create_txn_update_balances for posting line no '||to_char(i));
      END IF;

      --below procedure is called once for each line
      --we get the header, line and lots rows from the database based on the ids passed
      --it returns x_transaction_header_id which needs to be stored
      --for subsequent lines
      GMIVTDX.create_txn_update_balances
       (
  	  p_api_version           =>  p_api_version
	, p_init_msg_list         =>  FND_API.G_FALSE
	, p_commit                =>  FND_API.G_FALSE
	, p_validation_level      =>  p_validation_level
	, x_return_status         =>  x_return_status
	, x_msg_count             =>  x_msg_count
	, x_msg_data              =>  x_msg_data
	, p_transfer_id           =>  x_hdr_row.transfer_id
        , p_line_id            	  =>  x_line_row_tbl(i).line_id
        , x_transaction_header_id =>  p_hdr_rec.transaction_header_id
	);
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
     		log_msg('After call to procedure GMIVTDX.create_txn_update_balances.return status is '||x_return_status);
            END IF;
  	    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     		RAISE FND_API.G_EXC_ERROR;
  	    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  	    END IF;
    END;--Line block

  END LOOP;--} --LOOP for line

  -- we need to call ODM transaction manager to process rows in mmtt and mmlt.
  -- all the records have been inserted in mmtt and mmlt
  l_return_val := INV_LPN_TRX_PUB.PROCESS_LPN_TRX
      		      (
      	 		 p_trx_hdr_id		=> p_hdr_rec.transaction_header_id
  			,p_commit               => fnd_api.g_false
       	 		,x_proc_msg             => x_msg_data
        		,p_proc_mode            => 1 /* Online Processing */
        		,p_process_trx          => fnd_api.g_true
        		,p_atomic               => fnd_api.g_true
        		,p_business_flow_code   => NULL
                      );
  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    log_msg('After call to procedure INV_LPN_TRX_PUB.PROCESS_LPN_TRX .return val is '||l_return_val);
  END IF;

  IF (l_return_val <> 0) THEN
    FND_MESSAGE.SET_NAME ('GMI','GMI_SET_STRING');
    FND_MESSAGE.SET_TOKEN('STRING', substrb(x_msg_data,1,240));
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --everything is good. set costed flag to yes in mmt
  update mtl_material_transactions
  set    costed_flag     = 'Y',
         opm_costed_flag = 'Y'
  where  transaction_set_id = p_hdr_rec.transaction_header_id;


  --rlnagara 2 Material Status Migration ME start - Added the below code to update the status in MOQD
  select lot_control_code, lot_status_enabled
  into l_lot_ctl, l_lot_sts
  from mtl_system_items_b
  where inventory_item_id = (select inventory_item_id from mtl_material_transactions where transaction_set_id = p_hdr_rec.transaction_header_id)
  and organization_id = (select organization_id from mtl_material_transactions where transaction_set_id = p_hdr_rec.transaction_header_id);

  IF l_lot_ctl = 2 and l_lot_sts = 'Y' THEN
    update mtl_onhand_quantities_detail
    set status_id = (select status_id from mtl_material_statuses
                     where status_code = (select opm_lot_status from gmi_discrete_transfer_lots
                                          where  transfer_id = (select transaction_source_id from mtl_material_transactions
    					                        where transaction_set_id = p_hdr_rec.transaction_header_id)) )
    where create_transaction_id = (select transaction_id from mtl_material_transactions
                                   where transaction_set_id = p_hdr_rec.transaction_header_id) ;
  END IF;
  --rlnagara 2 Material Status Migration ME end.


  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    log_msg('After update to mmt.costed_flag');
  END IF;


  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK to create_transfer;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK to create_transfer;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK to create_transfer;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END construct_post_records;

PROCEDURE log_msg(p_msg_text IN VARCHAR2) IS
BEGIN

    FND_MESSAGE.SET_NAME('GMI','GMI_DEBUG_API');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;

END log_msg ;

END GMIVDX;

/
