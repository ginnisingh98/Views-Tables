--------------------------------------------------------
--  DDL for Package Body GMIVTDX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIVTDX" AS
/* $Header: GMIVTDXB.pls 120.3 2006/09/18 16:02:15 jsrivast noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIVTDXB.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIVTDX                                                               |
 |                                                                          |
 | TYPE                                                                     |
 |   Private                                                                |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the private APIs for Process / Discrete Transfer|
 |    inserting transactions, creating lots in ODM  and updating balances   |
 |    in OPM inventory and Oracle Inventory.                                |
 |                                                                          |
 | Contents                                                                 |
 |    create_txn_update_balances                                            |
 |    create_txn_update_bal_in_opm                                          |
 |    complete_transaction_in_opm                                           |
 |    create_txn_update_bal_in_odm                                          |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jalaj Srivastava                                            |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
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
 |    create_txn_update_balances                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |    Sets up and posts transactions and updates balances in OPM inventory  |
 |    and Oracle Inventory. |                                               |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Jalaj Srivastava                                              |
 |                                                                          |
 +==========================================================================+ */

 PROCEDURE create_txn_update_balances
( p_api_version          	IN               NUMBER
, p_init_msg_list        	IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               	IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     	IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        	OUT NOCOPY       VARCHAR2
, x_msg_count            	OUT NOCOPY       NUMBER
, x_msg_data             	OUT NOCOPY       VARCHAR2
, p_transfer_id              	IN               NUMBER
, p_line_id            	        IN               NUMBER
, x_transaction_header_id 	IN OUT NOCOPY    NUMBER
) IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'create_txn_update_balances' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;
  l_txn_vars_rec       txn_vars_type;
  l_odm_txn_type_rec   inv_validate.transaction;
  l_hdr_row            gmi_discrete_transfers%ROWTYPE;
  l_line_row           gmi_discrete_transfer_lines%ROWTYPE;
  l_lot_row_tbl        GMIVDX.lot_row_tbl;
  l_lot_count          pls_integer  := 0;

  Cursor Cur_get_lot_records(Vtransfer_id NUMBER, Vline_id NUMBER) IS
    SELECT *
    FROM   gmi_discrete_transfer_lots
    WHERE  transfer_id = Vtransfer_id
    AND    line_id     = Vline_id;

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

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    log_msg('Beginning of procedure create_txn_update_balances');
  END IF;

  SELECT *
  INTO   l_hdr_row
  FROM   gmi_discrete_transfers
  WHERE  transfer_id = p_transfer_id;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    log_msg('After selecting header row from database. transfer id is '||to_char(l_hdr_row.transfer_id));
  END IF;

  SELECT *
  INTO   l_line_row
  FROM   gmi_discrete_transfer_lines
  WHERE  transfer_id = p_transfer_id
  AND    line_id     = p_line_id;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    log_msg('After selecting line row from database. line id is '||to_char(l_line_row.line_id));
  END IF;

  --if lots are defined at lot level
  IF (l_line_row.lot_level = 1) THEN
    FOR Cur_get_lot_records_rec IN Cur_get_lot_records (p_transfer_id, p_line_id) LOOP
      l_lot_count := l_lot_count + 1;
      l_lot_row_tbl(l_lot_count) := Cur_get_lot_records_rec;
    END LOOP;
  END IF;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    log_msg('After selecting lot rows from database. no of lots is '||to_char(l_lot_row_tbl.count));
  END IF;

  IF (l_hdr_row.transfer_type = 0 ) THEN
     l_odm_txn_type_rec.transaction_type_id := 42;
     l_txn_vars_rec.opm_qty_line_type	    := -1;
     l_txn_vars_rec.odm_qty_line_type	    := 1;
  ELSIF (l_hdr_row.transfer_type = 1 ) THEN
     l_odm_txn_type_rec.transaction_type_id := 32;
     l_txn_vars_rec.opm_qty_line_type	    := 1;
     l_txn_vars_rec.odm_qty_line_type	    := -1;
  END IF;

  IF (inv_validate.transaction_type (l_odm_txn_type_rec) = inv_validate.F) THEN
     IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	log_msg('Failed call to inv_validate.transaction_type in procedure create_txn_update_balances');
     END IF;
     FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','TRANSACTION'),FALSE);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT item_um,item_um2,
         lot_ctl,lot_indivisible
  INTO   l_txn_vars_rec.opm_item_um, l_txn_vars_rec.opm_item_um2,
         l_txn_vars_rec.lot_control, l_txn_vars_rec.opm_lot_indivisible
  FROM   ic_item_mst_b
  WHERE  item_id = l_line_row.opm_item_id;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    log_msg('before calling create_txn_update_bal_in_opm');
  END IF;

  create_txn_update_bal_in_opm
       (
      	  p_api_version          =>  p_api_version
   	, p_init_msg_list        =>  FND_API.G_FALSE
	, p_commit               =>  FND_API.G_FALSE
	, p_validation_level     =>  p_validation_level
	, x_return_status        =>  x_return_status
	, x_msg_count            =>  x_msg_count
	, x_msg_data             =>  x_msg_data
	, p_hdr_row              =>  l_hdr_row
	, p_line_row             =>  l_line_row
	, p_lot_row_tbl          =>  l_lot_row_tbl
	, p_txn_vars_rec         =>  l_txn_vars_rec
       );

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
     log_msg('After call to procedure create_txn_update_balances_in_opm. return status is '||x_return_status);
  END IF;
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    log_msg('before calling create_txn_update_bal_in_odm');
  END IF;

  create_txn_update_bal_in_odm
       (
      	  p_api_version           =>  p_api_version
   	, p_init_msg_list         =>  FND_API.G_FALSE
	, p_commit                =>  FND_API.G_FALSE
	, p_validation_level      =>  p_validation_level
	, x_return_status         =>  x_return_status
	, x_msg_count             =>  x_msg_count
	, x_msg_data              =>  x_msg_data
	, p_hdr_row               =>  l_hdr_row
	, p_line_row              =>  l_line_row
	, p_lot_row_tbl           =>  l_lot_row_tbl
	, p_txn_vars_rec          =>  l_txn_vars_rec
	, p_odm_txn_type_rec      =>  l_odm_txn_type_rec
	, x_transaction_header_id =>  x_transaction_header_id
       );
  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
     log_msg('After call to procedure create_txn_update_balances_in_odm. return status is '||x_return_status||' transaction header id is '||to_char(x_transaction_header_id));
  END IF;
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END create_txn_update_balances;


/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    create_txn_update_bal_in_opm                                          |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |    Sets up and posts transactions and updates balances in OPM inventory  |
 |    Does a final check to prevent OPM inventory balances from going       |
 |    negative  and calls the OPM inventory engine to post the transaction  |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Jalaj Srivastava                                              |
 |                                                                          |
 +==========================================================================+ */

PROCEDURE create_txn_update_bal_in_opm
( p_api_version            IN               NUMBER
, p_init_msg_list          IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit                 IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level       IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status          OUT NOCOPY       VARCHAR2
, x_msg_count              OUT NOCOPY       NUMBER
, x_msg_data               OUT NOCOPY       VARCHAR2
, p_hdr_row                IN               gmi_discrete_transfers%ROWTYPE
, p_line_row               IN               gmi_discrete_transfer_lines%ROWTYPE
, p_lot_row_tbl            IN               GMIVDX.lot_row_tbl
, p_txn_vars_rec           IN               txn_vars_type
)IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'create_txn_update_bal_in_opm' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;
  l_tran_row           ic_tran_cmp%ROWTYPE;
  l_ic_loct_inv_row    ic_loct_inv%ROWTYPE;
  TYPE tran_rec_tbl    IS TABLE OF GMI_TRANS_ENGINE_PUB.ictran_rec INDEX BY BINARY_INTEGER;
  l_tran_rec_tbl       tran_rec_tbl;
BEGIN

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  SAVEPOINT create_transaction_in_opm;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  --we need to construct the record for inserting transactions in OPM.
  --{
  IF (p_line_row.lot_level = 0) THEN --lots at line level

     l_tran_rec_tbl(1).trans_qty        := (p_line_row.opm_primary_quantity) * (p_txn_vars_rec.opm_qty_line_type);
     l_tran_rec_tbl(1).line_detail_id   := NULL;
     l_tran_rec_tbl(1).lot_id           := p_line_row.opm_lot_id;
     l_tran_rec_tbl(1).qc_grade         := p_line_row.opm_grade;
     l_tran_rec_tbl(1).lot_status       := p_line_row.opm_lot_status;
     l_tran_rec_tbl(1).trans_qty2       := (p_line_row.quantity2) * (p_txn_vars_rec.opm_qty_line_type);
     l_tran_rec_tbl(1).text_code        := p_line_row.text_code;

  ELSIF (p_line_row.lot_level = 1) THEN --lots at lots level
    --there could be multiple lot records.
    FOR i in 1..p_lot_row_tbl.count LOOP --{
      l_tran_rec_tbl(i).trans_qty        := (p_lot_row_tbl(i).opm_primary_quantity) * (p_txn_vars_rec.opm_qty_line_type);
      l_tran_rec_tbl(i).line_detail_id   := p_lot_row_tbl(i).line_detail_id;
      l_tran_rec_tbl(i).lot_id           := p_lot_row_tbl(i).opm_lot_id;
      l_tran_rec_tbl(i).qc_grade         := p_lot_row_tbl(i).opm_grade;
      l_tran_rec_tbl(i).lot_status       := p_lot_row_tbl(i).opm_lot_status;
      l_tran_rec_tbl(i).trans_qty2       := (p_lot_row_tbl(i).quantity2) * (p_txn_vars_rec.opm_qty_line_type);
      l_tran_rec_tbl(i).text_code        := p_lot_row_tbl(i).text_code;

    END LOOP;--}

  END IF;--}

  FOR i IN 1..l_tran_rec_tbl.count LOOP --{
    l_tran_rec_tbl(i).co_code	       := p_hdr_row.co_code;
    l_tran_rec_tbl(i).line_type        := p_txn_vars_rec.opm_qty_line_type;
    l_tran_rec_tbl(i).trans_um         := p_txn_vars_rec.opm_item_um;
    l_tran_rec_tbl(i).trans_um2        := p_txn_vars_rec.opm_item_um2;  /* UM2 only for OPM */
    l_tran_rec_tbl(i).orgn_code        := p_hdr_row.orgn_code;
    l_tran_rec_tbl(i).doc_type         := 'DXFR';
    l_tran_rec_tbl(i).doc_id           := p_hdr_row.transfer_id;
    l_tran_rec_tbl(i).trans_date       := p_hdr_row.trans_date;
    l_tran_rec_tbl(i).doc_line         := p_line_row.line_no;
    l_tran_rec_tbl(i).line_id          := p_line_row.line_id;
    l_tran_rec_tbl(i).item_id          := p_line_row.opm_item_id;
    l_tran_rec_tbl(i).whse_code        := p_line_row.opm_whse_code;
    l_tran_rec_tbl(i).location         := p_line_row.opm_location;
    l_tran_rec_tbl(i).reason_code      := p_line_row.opm_reason_code;
    l_tran_rec_tbl(i).non_inv          := 0;
    l_tran_rec_tbl(i).user_id          := FND_GLOBAL.USER_ID;
    l_tran_rec_tbl(i).trans_stat       := NULL;
    l_tran_rec_tbl(i).staged_ind       := NULL;
    l_tran_rec_tbl(i).event_id         := NULL;
    l_tran_rec_tbl(i).create_lot_index := NULL;

    /* *******************************************************************************************
     Before posting the transaction we again want to validate whether there is enough onhand
     for the transaction. this is only when transfer type is 0 (Process to discrete).
    ******************************************************************************************* */
    --{
    IF (l_tran_rec_tbl(i).line_type = -1) THEN
      --transfer is from process to discrete
      l_ic_loct_inv_row.whse_code  := l_tran_rec_tbl(i).whse_code;
      l_ic_loct_inv_row.location   := l_tran_rec_tbl(i).location;
      l_ic_loct_inv_row.item_id    := l_tran_rec_tbl(i).item_id;
      l_ic_loct_inv_row.lot_id     := l_tran_rec_tbl(i).lot_id;

      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
        log_msg('validation for quantity being transferrred from OPM such that OPM inventory is not driven negative before posting the transaction.');
      END IF;
      --{
      IF GMIVDBL.ic_loct_inv_select(l_ic_loct_inv_row, l_ic_loct_inv_row) THEN

        IF (     (p_txn_vars_rec.opm_lot_indivisible = 1)
             AND (l_ic_loct_inv_row.loct_onhand <> abs(l_tran_rec_tbl(i).trans_qty))
           ) THEN
           FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_INDIVISIBLE_LOT');
           FND_MESSAGE.SET_TOKEN('LINE_NO',to_char(l_tran_rec_tbl(i).doc_line));
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_CANNOT_GET_ONHAND');
        FND_MESSAGE.SET_TOKEN('LINE_NO',to_char(l_tran_rec_tbl(i).doc_line));
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;--}

    END IF;--}

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
      log_msg('Before calling GMI_TRANS_ENGINE_PVT.create_completed_transaction for lot id '||to_char(l_tran_rec_tbl(i).lot_id));
    END IF;
    --lets call the GMI engine to post completed transaction
    GMI_TRANS_ENGINE_PVT.create_completed_transaction
     (
     	p_api_version      => 1.0
      , p_init_msg_list    => FND_API.G_FALSE
      , p_commit           => FND_API.G_FALSE
      , p_validation_level => FND_API.G_VALID_LEVEL_FULL
      , x_return_status    => x_return_status
      , x_msg_count        => x_msg_count
      , x_msg_data         => x_msg_data
      , p_tran_rec         => l_tran_rec_tbl(i)
      , x_tran_row         => l_tran_row
     );

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
      log_msg('After the call to GMI_TRANS_ENGINE_PVT.create_completed_transaction. return status is '||x_return_status);
    END IF;
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END LOOP;--}

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    log_msg('Posted '||to_char(l_tran_rec_tbl.count)||' completed transactions to OPM');
  END IF;

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK to create_transaction_in_opm;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK to create_transaction_in_opm;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK to create_transaction_in_opm;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END create_txn_update_bal_in_opm;

/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    create_txn_update_bal_in_odm                                          |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |    Sets up and posts transactions and updates balances in OPM inventory  |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Jalaj Srivastava                                              |
 |                                                                          |
 +==========================================================================+ */

PROCEDURE create_txn_update_bal_in_odm
( p_api_version            IN               NUMBER
, p_init_msg_list          IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit                 IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level       IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status          OUT NOCOPY       VARCHAR2
, x_msg_count              OUT NOCOPY       NUMBER
, x_msg_data               OUT NOCOPY       VARCHAR2
, p_hdr_row                IN               gmi_discrete_transfers%ROWTYPE
, p_line_row               IN               gmi_discrete_transfer_lines%ROWTYPE
, p_lot_row_tbl            IN               GMIVDX.lot_row_tbl
, p_txn_vars_rec           IN               txn_vars_type
, p_odm_txn_type_rec       IN               inv_validate.transaction
, x_transaction_header_id  IN OUT NOCOPY    NUMBER
) IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'create_txn_update_bal_in_odm' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;
  l_mmtt_row           mtl_material_transactions_temp%ROWTYPE;
  TYPE mtlt_row_tbl    IS TABLE OF mtl_transaction_lots_temp%ROWTYPE INDEX BY BINARY_INTEGER;
  l_mtlt_row_tbl       mtlt_row_tbl;
  l_count              pls_integer;

  /* Jalaj Srivastava Bug 3812701 */
  l_odm_quantity_uom_code mtl_units_of_measure.uom_code%TYPE;
  Cursor Cur_get_uom_code (Vum_code VARCHAR2) IS
  SELECT uom_code
  FROM   sy_uoms_mst
  WHERE  um_code = Vum_code;

BEGIN

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  SAVEPOINT create_transaction_in_odm;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  --we need to construct the record for inserting transactions in ODM.
  --then we need to insert into mtl_material_transactions_temp table.
  --this is done for each line.

  --this procedure is called line by line.

  IF (x_transaction_header_id IS NULL) THEN
     -- get the transaction_header_id
     SELECT mtl_material_transactions_s.NEXTVAL
     INTO   x_transaction_header_id
     FROM DUAL;
  END IF;

  -- get the transaction_temp_id
  SELECT mtl_material_transactions_s.NEXTVAL
  INTO   l_mmtt_row.transaction_temp_id
  FROM DUAL;

  --we need to construct/insert a record in mmtt

  l_mmtt_row.transaction_header_id	:= x_transaction_header_id;
  l_mmtt_row.transaction_mode		:= 1; /* Online */
  l_mmtt_row.lock_flag			:= 'N';
  l_mmtt_row.inventory_item_id		:= p_line_row.odm_item_id;
  l_mmtt_row.organization_id		:= p_line_row.odm_inv_organization_id;
  l_mmtt_row.subinventory_code		:= p_line_row.odm_subinventory;
  l_mmtt_row.locator_id		        := p_line_row.odm_locator_id;
  l_mmtt_row.transaction_quantity	:= round(((p_line_row.quantity) * (p_txn_vars_rec.odm_qty_line_type)),5);
  l_mmtt_row.primary_quantity		:= (p_line_row.odm_primary_quantity) * (p_txn_vars_rec.odm_qty_line_type);
  l_mmtt_row.secondary_transaction_quantity := (p_line_row.quantity2) * (p_txn_vars_rec.odm_qty_line_type);

  /* Jalaj Srivastava Bug 3182701 */
  /* Get uom_code for this um from sy_uoms_mst */

      OPEN  Cur_get_uom_code(p_line_row.quantity_um);
      FETCH Cur_get_uom_code INTO l_odm_quantity_uom_code;
      CLOSE Cur_get_uom_code;

  l_mmtt_row.transaction_uom		:= l_odm_quantity_uom_code;

  --Get item's secondary uom code in ODM
  SELECT secondary_uom_code
  INTO   l_mmtt_row.secondary_uom_code
  FROM   mtl_system_items_b
  WHERE  inventory_item_id = l_mmtt_row.inventory_item_id
  AND    organization_id   = l_mmtt_row.organization_id;

  l_mmtt_row.transaction_type_id	:= p_odm_txn_type_rec.transaction_type_id;
  l_mmtt_row.transaction_action_id	:= p_odm_txn_type_rec.transaction_action_id;
  l_mmtt_row.transaction_source_type_id	:= p_odm_txn_type_rec.transaction_source_type_id;

  IF (p_hdr_row.transfer_type = 0) THEN
    FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_FROM_SOURCE_NAME');
    l_mmtt_row.Transaction_source_name	:= fnd_message.get;
  ELSIF (p_hdr_row.transfer_type = 1) THEN
    FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_TO_SOURCE_NAME');
    l_mmtt_row.transaction_source_name	:= fnd_message.get;
  END IF;

  l_mmtt_row.transaction_line_number	:= p_line_row.line_no;
  l_mmtt_row.transaction_date		:= p_hdr_row.trans_date;
  l_mmtt_row.acct_period_id		:= p_line_row.odm_period_id;
  l_mmtt_row.distribution_account_id	:= p_line_row.odm_charge_account_id;
  l_mmtt_row.transaction_reference	:= 'OPM'||' - '||'DXFR'||' - '||p_hdr_row.orgn_code||' - '||p_hdr_row.transfer_number||' - '||to_char(p_line_row.line_no);
  l_mmtt_row.posting_flag		:= 'Y';
  l_mmtt_row.process_flag		:= 'Y';
  l_mmtt_row.final_completion_flag      := 'N';
  l_mmtt_row.reason_id		        := p_line_row.odm_reason_id;
  l_mmtt_row.transaction_cost 		:= round((p_line_row.odm_unit_cost * (l_mmtt_row.TRANSACTION_QUANTITY/l_mmtt_row.PRIMARY_QUANTITY)),6);
  l_mmtt_row.revision			:= p_line_row.odm_item_revision;
  l_mmtt_row.last_update_date		:= SYSDATE;
  l_mmtt_row.last_updated_by		:= FND_GLOBAL.USER_ID;
  l_mmtt_row.creation_date		:= SYSDATE;
  l_mmtt_row.created_by		        := FND_GLOBAL.USER_ID;
  l_mmtt_row.last_update_login	        := FND_GLOBAL.LOGIN_ID;

  l_mmtt_row.source_code		:= 'OPM-DXFR-MIGRATION';
  l_mmtt_row.source_line_id		:= p_line_row.line_id;
  l_mmtt_row.transaction_source_id	:= p_hdr_row.transfer_id;

  -- insert data into mtl_material_transactions_temp table
  INSERT INTO mtl_material_transactions_temp
      (
	TRANSACTION_HEADER_ID,
	TRANSACTION_TEMP_ID,
	TRANSACTION_MODE,
	LOCK_FLAG,
	INVENTORY_ITEM_ID,
	REVISION,
	ORGANIZATION_ID,
	SUBINVENTORY_CODE,
	LOCATOR_ID,
	TRANSACTION_QUANTITY,
	PRIMARY_QUANTITY,
	SECONDARY_TRANSACTION_QUANTITY,
	TRANSACTION_UOM,
	SECONDARY_UOM_CODE,
	TRANSACTION_TYPE_ID,
	TRANSACTION_ACTION_ID,
	TRANSACTION_SOURCE_TYPE_ID,
	TRANSACTION_SOURCE_NAME,
	TRANSACTION_DATE,
	ACCT_PERIOD_ID,
	DISTRIBUTION_ACCOUNT_ID,
	TRANSACTION_REFERENCE,
	POSTING_FLAG,
	PROCESS_FLAG,
	FINAL_COMPLETION_FLAG,
	TRANSACTION_LINE_NUMBER,
	REASON_ID,
        TRANSACTION_COST,
        SOURCE_CODE,
        SOURCE_LINE_ID,
        TRANSACTION_SOURCE_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
      )
  VALUES
      (
	l_mmtt_row.transaction_header_id,
	l_mmtt_row.transaction_temp_id,
	l_mmtt_row.transaction_mode,
	l_mmtt_row.lock_flag,
	l_mmtt_row.inventory_item_id,
	l_mmtt_row.revision,
	l_mmtt_row.organization_id,
	l_mmtt_row.subinventory_code,
	l_mmtt_row.locator_id,
	l_mmtt_row.transaction_quantity,
	l_mmtt_row.primary_quantity,
	l_mmtt_row.secondary_transaction_quantity,
	l_mmtt_row.transaction_uom,
	l_mmtt_row.secondary_uom_code,
	l_mmtt_row.transaction_type_id,
	l_mmtt_row.transaction_action_id,
	l_mmtt_row.transaction_source_type_id,
	l_mmtt_row.transaction_source_name,
	l_mmtt_row.transaction_date,
	l_mmtt_row.acct_period_id,
	l_mmtt_row.distribution_account_id,
	l_mmtt_row.transaction_reference,
	l_mmtt_row.posting_flag,
	l_mmtt_row.process_flag,
	l_mmtt_row.final_completion_flag,
	l_mmtt_row.transaction_line_number,
	l_mmtt_row.reason_id,
        l_mmtt_row.transaction_cost,
        l_mmtt_row.source_code,
        l_mmtt_row.source_line_id,
        l_mmtt_row.transaction_source_id,
	l_mmtt_row.creation_date,
	l_mmtt_row.created_by,
	l_mmtt_row.last_update_date,
	l_mmtt_row.last_updated_by,
	l_mmtt_row.last_update_login
      );
  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	log_msg('Inserted 1 record in mtl_material_transactions_temp');
  END IF;

  --lets see if we have records to be inserted in mtl_transaction_lots_temp
  --line could have multiple lots
  --{
  IF (p_txn_vars_rec.lot_control = 1) THEN --if item is lot controlled

     --{
     IF (p_line_row.lot_level = 0) THEN --lot at line level
       l_mtlt_row_tbl(1).transaction_quantity	:= round(((p_line_row.quantity)  * (p_txn_vars_rec.odm_qty_line_type)),5);
       l_mtlt_row_tbl(1).primary_quantity	:= (p_line_row.odm_primary_quantity) * (p_txn_vars_rec.odm_qty_line_type);
       l_mtlt_row_tbl(1).lot_number		:= p_line_row.odm_lot_number;
       l_mtlt_row_tbl(1).lot_expiration_date	:= p_line_row.odm_lot_expiration_date;
       IF (p_line_row.quantity2 IS NOT NULL) THEN
         l_mtlt_row_tbl(1).secondary_quantity	:= p_line_row.quantity2  * (p_txn_vars_rec.odm_qty_line_type);
       END IF;

     ELSIF (p_line_row.lot_level = 1) THEN --lots at lot level
       --there could be multiple lot records
       FOR i in 1..p_lot_row_tbl.count LOOP --{
         l_mtlt_row_tbl(i).transaction_quantity	:= round(((p_lot_row_tbl(i).quantity) * (p_txn_vars_rec.odm_qty_line_type)),5);
         l_mtlt_row_tbl(i).primary_quantity	:= (p_lot_row_tbl(i).odm_primary_quantity) * (p_txn_vars_rec.odm_qty_line_type);
         l_mtlt_row_tbl(i).lot_number		:= p_lot_row_tbl(i).odm_lot_number;
         l_mtlt_row_tbl(i).lot_expiration_date	:= p_lot_row_tbl(i).odm_lot_expiration_date;
         IF (p_lot_row_tbl(i).quantity2 IS NOT NULL) THEN
           l_mtlt_row_tbl(i).secondary_quantity := (p_lot_row_tbl(i).quantity2) * (p_txn_vars_rec.odm_qty_line_type);
         END IF;

       END LOOP;--}

     END IF;--}


     FOR i IN 1..l_mtlt_row_tbl.count LOOP --{

       l_mtlt_row_tbl(i).transaction_temp_id	:= l_mmtt_row.transaction_temp_id;
       l_mtlt_row_tbl(i).group_header_id	:= x_transaction_header_id;
       l_mtlt_row_tbl(i).creation_date		:= SYSDATE;
       l_mtlt_row_tbl(i).created_by		:= FND_GLOBAL.USER_ID;
       l_mtlt_row_tbl(i).last_update_date	:= SYSDATE;
       l_mtlt_row_tbl(i).last_updated_by	:= FND_GLOBAL.USER_ID;
       l_mtlt_row_tbl(i).last_update_login    	:= FND_GLOBAL.LOGIN_ID;

       /* Jalaj Srivastava Bug 5401804
          When OPM balances are migrated to Oracle Inventory,
          process lots are first created in discrete lot master due
          to which lot attribute info is lost in migartion transaction.
          Populate lot attributes information from lot master
          for lot transactions */
       INSERT INTO MTL_TRANSACTION_LOTS_TEMP
         (
	   transaction_temp_id
	  ,group_header_id
	  ,transaction_quantity
	  ,primary_quantity
	  ,secondary_quantity
	  ,lot_number
	  ,creation_date
	  ,created_by
	  ,last_update_date
	  ,last_updated_by
	  ,last_update_login
          ,lot_expiration_date
          ,status_id
          ,lot_attribute_category
          ,attribute_category
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,c_attribute1
          ,c_attribute2
          ,c_attribute3
          ,c_attribute4
          ,c_attribute5
          ,c_attribute6
          ,c_attribute7
          ,c_attribute8
          ,c_attribute9
          ,c_attribute10
          ,c_attribute11
          ,c_attribute12
          ,c_attribute13
          ,c_attribute14
          ,c_attribute15
          ,c_attribute16
          ,c_attribute17
          ,c_attribute18
          ,c_attribute19
          ,c_attribute20
          ,n_attribute1
          ,n_attribute2
          ,n_attribute3
          ,n_attribute4
          ,n_attribute5
          ,n_attribute6
          ,n_attribute7
          ,n_attribute8
          ,n_attribute9
          ,n_attribute10
          ,d_attribute1
          ,d_attribute2
          ,d_attribute3
          ,d_attribute4
          ,d_attribute5
          ,d_attribute6
          ,d_attribute7
          ,d_attribute8
          ,d_attribute9
          ,d_attribute10
          ,grade_code
          ,origination_date
          ,date_code
          ,change_date
          ,age
          ,retest_date
          ,maturity_date
          ,item_size
          ,color
          ,volume
          ,volume_uom
          ,place_of_origin
          ,best_by_date
          ,length
          ,length_uom
          ,recycled_content
          ,thickness
          ,thickness_uom
          ,width
          ,width_uom
          ,territory_code
          ,supplier_lot_number
          ,vendor_name
          ,parent_lot_number
          ,origination_type
          ,expiration_action_code
          ,expiration_action_date
          ,hold_date
          ,reason_id
         )
       SELECT
          l_mtlt_row_tbl(i).transaction_temp_id
	 ,l_mtlt_row_tbl(i).group_header_id
	 ,l_mtlt_row_tbl(i).transaction_quantity
	 ,l_mtlt_row_tbl(i).primary_quantity
	 ,l_mtlt_row_tbl(i).secondary_quantity
	 ,l_mtlt_row_tbl(i).lot_number
	 ,l_mtlt_row_tbl(i).creation_date
	 ,l_mtlt_row_tbl(i).created_by
	 ,l_mtlt_row_tbl(i).last_update_date
	 ,l_mtlt_row_tbl(i).last_updated_by
	 ,l_mtlt_row_tbl(i).last_update_login
         ,mln.expiration_date
         ,mln.status_id
         ,mln.lot_attribute_category
         ,mln.attribute_category
         ,mln.attribute1
         ,mln.attribute2
         ,mln.attribute3
         ,mln.attribute4
         ,mln.attribute5
         ,mln.attribute6
         ,mln.attribute7
         ,mln.attribute8
         ,mln.attribute9
         ,mln.attribute10
         ,mln.attribute11
         ,mln.attribute12
         ,mln.attribute13
         ,mln.attribute14
         ,mln.attribute15
         ,mln.c_attribute1
         ,mln.c_attribute2
         ,mln.c_attribute3
         ,mln.c_attribute4
         ,mln.c_attribute5
         ,mln.c_attribute6
         ,mln.c_attribute7
         ,mln.c_attribute8
         ,mln.c_attribute9
         ,mln.c_attribute10
         ,mln.c_attribute11
         ,mln.c_attribute12
         ,mln.c_attribute13
         ,mln.c_attribute14
         ,mln.c_attribute15
         ,mln.c_attribute16
         ,mln.c_attribute17
         ,mln.c_attribute18
         ,mln.c_attribute19
         ,mln.c_attribute20
         ,mln.n_attribute1
         ,mln.n_attribute2
         ,mln.n_attribute3
         ,mln.n_attribute4
         ,mln.n_attribute5
         ,mln.n_attribute6
         ,mln.n_attribute7
         ,mln.n_attribute8
         ,mln.n_attribute9
         ,mln.n_attribute10
         ,mln.d_attribute1
         ,mln.d_attribute2
         ,mln.d_attribute3
         ,mln.d_attribute4
         ,mln.d_attribute5
         ,mln.d_attribute6
         ,mln.d_attribute7
         ,mln.d_attribute8
         ,mln.d_attribute9
         ,mln.d_attribute10
         ,mln.grade_code
         ,mln.origination_date
         ,mln.date_code
         ,mln.change_date
         ,mln.age
         ,mln.retest_date
         ,mln.maturity_date
         ,mln.item_size
         ,mln.color
         ,mln.volume
         ,mln.volume_uom
         ,mln.place_of_origin
         ,mln.best_by_date
         ,mln.length
         ,mln.length_uom
         ,mln.recycled_content
         ,mln.thickness
         ,mln.thickness_uom
         ,mln.width
         ,mln.width_uom
         ,mln.territory_code
         ,mln.supplier_lot_number
         ,mln.vendor_name
         ,mln.parent_lot_number
         ,mln.origination_type
         ,mln.expiration_action_code
         ,mln.expiration_action_date
         ,mln.hold_date
         ,l_mmtt_row.reason_id
       FROM
         mtl_lot_numbers mln
       WHERE
             mln.inventory_item_id = l_mmtt_row.inventory_item_id
         and mln.organization_id   = l_mmtt_row.organization_id
         and mln.lot_number        = l_mtlt_row_tbl(i).lot_number;

     END LOOP;

     IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
   	log_msg('Inserted '||to_char(l_mtlt_row_tbl.count)||' lot records for the line in mtl_transactions_lots_temp');
     END IF;

  END IF;--}

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK to create_transaction_in_odm;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK to create_transaction_in_odm;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK to create_transaction_in_odm;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_DXFR_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
      FND_MSG_PUB.Add;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END create_txn_update_bal_in_odm;


PROCEDURE log_msg(p_msg_text IN VARCHAR2) IS
BEGIN

    FND_MESSAGE.SET_NAME('GMI','GMI_DEBUG_API');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;

END log_msg ;

END GMIVTDX;

/
