--------------------------------------------------------
--  DDL for Package Body MTL_LOT_UOM_CONV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_LOT_UOM_CONV_PVT" as
/* $Header: INVVLUCB.pls 120.2.12000000.4 2007/08/03 13:17:22 adeshmuk ship $ */
g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
 g_pkg_name   CONSTANT VARCHAR2 (30) := 'MTL_LOT_UOM_CONV_PVT';

/*===========================================================================
--  FUNCTION:
--    validate_update_type
--
--  DESCRIPTION:
--    This function validates the lookup type value provided for INV_UPDATE_TYPE
--    for lot specific uom conversions.
--
--  PARAMETERS:
--    p_update_type         IN  VARCHAR2       - Type value to be validated.
--
--    return                OUT NUMBER         - G_TRUE or G_FALSE
--
--  SYNOPSIS:
--    Validate type against mfg_lookups table.
--
--  HISTORY
--    Joe DiIorio     01-Sept-2004  Created.
--
--=========================================================================== */

FUNCTION validate_update_type (
    p_update_type     IN VARCHAR2)
  return NUMBER

IS

CURSOR c_val_update_type
IS
SELECT 1
FROM mfg_lookups
WHERE lookup_code = p_update_type AND
      lookup_type = 'INV_UPDATE_TYPE';

l_count                    NUMBER := 0;

BEGIN

  /*=========================================
       Validate type.
    =========================================*/

  l_count := 0;
  OPEN c_val_update_type;
  FETCH c_val_update_type INTO l_count;
  IF (c_val_update_type%NOTFOUND) THEN
     CLOSE c_val_update_type;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c_val_update_type;

  return G_TRUE;


EXCEPTION

  WHEN NO_DATA_FOUND THEN
     FND_MESSAGE.SET_NAME('INV','INV_LOTC_UPDATETYPE_INVALID');
     FND_MSG_PUB.Add;
     RETURN G_FALSE;

  WHEN OTHERS THEN
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('INV','INV_LOTC_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
      FND_MSG_PUB.Add;
    END IF;
    RETURN G_FALSE;

END VALIDATE_UPDATE_TYPE;



/*===========================================================================
--  FUNCTION:
--    validate_lot_conversion_rules
--
--  DESCRIPTION:
--    This function validates the business rules related to lot specific uom
--    conversions.
--
--  PARAMETERS:
--    p_organization_id   IN  NUMBER   - organization surrogate id
--    p_inventory_item_id IN  NUMBER   - item surrogate id
--    p_lot_number        IN  VARCHAR2 - lot number
--    p_from_uom_code     IN  VARCHAR2 - from uom code
--    p_to_uom_code       IN  VARCHAR2 - to uom code
--    p_quantity_updates  IN  VARCHAR2 - indicates if quantity change made 'T' or not 'F'.
--    p_update_type       IN  VARCHAR2 - indicates type of quantity update
--                                       0 = update onhand balances
--                                       1 = recalculate batch primary quantity
--                                       2 = recalculate batch secondary quantity
--                                       3 = recalculate onhand primary quantity
--                                       4 = recalculate onhand secondary quantity
--                                       5 = no quantity updates
--    p_header_id         IN  NUMBER   - Header id of in-progress transaction.
--
--  SYNOPSIS:
--    Validate business rules.
--
--  HISTORY
--    Joe DiIorio     01-Sept-2004  Created.
--
--=========================================================================== */

FUNCTION  validate_lot_conversion_rules
( p_organization_id      IN              NUMBER
, p_inventory_item_id    IN              NUMBER
, p_lot_number           IN              VARCHAR2
, p_from_uom_code        IN              VARCHAR2
, p_to_uom_code          IN              VARCHAR2
, p_quantity_updates     IN              NUMBER
, p_update_type          IN              VARCHAR2
, p_header_id            IN              NUMBER    DEFAULT NULL
)
  return NUMBER

IS


CURSOR get_uom_class (p_uom_code VARCHAR2) IS
SELECT uom_class
FROM   mtl_units_of_measure
WHERE  uom_code = p_uom_code;

l_from_class        MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE;
l_to_class          MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE;
l_ret               NUMBER;
l_revision          NUMBER;

l_header_id         NUMBER := NULL;

BEGIN

  /*============================================
     Call to get cache values if item is not
     already cached.
    ==========================================*/

  IF NOT (INV_CACHE.set_item_rec(p_organization_id, p_inventory_item_id)) THEN
      RETURN G_FALSE;
  END IF;

  /*============================================
     Compare From/To UOM.  Cannot be the same.
    ============================================*/

  IF (p_from_uom_code = p_to_uom_code) THEN
     FND_MESSAGE.SET_NAME('INV','INV_LOTC_CROSS_UOM_ERROR');
     FND_MSG_PUB.ADD;
     RETURN G_FALSE;
  END IF;

  /*============================================
     Compare From/To Class.  Cannot be the same.
     Get both classes
    ============================================*/

   OPEN get_uom_class (p_from_uom_code);
   FETCH get_uom_class INTO l_from_class;
   IF (get_uom_class%NOTFOUND) THEN
      CLOSE get_uom_class;
      FND_MESSAGE.SET_NAME('INV','INV_FROM_CLASS_ERR');
      FND_MSG_PUB.ADD;
      RETURN G_FALSE;
   END IF;
   CLOSE get_uom_class;

   OPEN get_uom_class (p_to_uom_code);
   FETCH get_uom_class INTO l_to_class;
   IF (get_uom_class%NOTFOUND) THEN
      CLOSE get_uom_class;
      FND_MESSAGE.SET_NAME('INV','INV_TO_CLASS_ERR');
      FND_MSG_PUB.ADD;
      RETURN G_FALSE;
   END IF;
   CLOSE get_uom_class;


   IF (l_from_class = l_to_class) THEN
      FND_MESSAGE.SET_NAME('INV','INV_CLASS_EQUAL_ERR');
      FND_MSG_PUB.ADD;
      RETURN G_FALSE;
   END IF;

  /*========================================
     Check if Item is serially controlled.
    ========================================*/

  IF (INV_CACHE.item_rec.serial_number_control_code <> 1) THEN
     FND_MESSAGE.SET_NAME('INV','INV_LOT_SERIAL_SUPPORT');
     FND_MSG_PUB.ADD;
     RETURN G_FALSE;
  END IF;

  /*========================================
     Check if Item is lot controlled.
     (1 no control 2 full)
    ========================================*/

  IF (INV_CACHE.item_rec.lot_control_code <> 2) THEN
     FND_MESSAGE.SET_NAME('INV','INV_NOTLOTCTL');
     FND_MSG_PUB.ADD;
     RETURN G_FALSE;
  END IF;

  /*========================================
     Check if onhand availability problem.
    ========================================*/

  l_revision := INV_CACHE.item_rec.revision_qty_control_code;


  l_header_id := p_header_id;

  l_ret := validate_onhand_equals_avail(
      p_organization_id,
      p_inventory_item_id,
      p_lot_number,
      l_header_id);

  IF (l_ret = G_FALSE) THEN
      RETURN G_FALSE;
  END IF;

  RETURN G_TRUE;


EXCEPTION

  WHEN OTHERS THEN
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('INV','INV_LOTC_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
    ELSE
      FND_MESSAGE.SET_NAME('INV','INV_BUSRULES_GENERIC_ERR');
    END IF;
    FND_MSG_PUB.ADD;
    RETURN G_FALSE;


END validate_lot_conversion_rules;

/*===========================================================================
--  PROCEDURE
--    process_conversion_data
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to insert or update a lot specific uom
--    conversion.  It will create the audit records and create adjustment
--    transactions if necessary.
--
--  PARAMETERS:
--    p_action_type           IN  VARCHAR2 - I for insert, U for update.
--    p_update_type_indicator IN  NUMBER   - indicates type of quantity update
--                                            0 = update onhand balances
--                                            1 = recalculate batch primary quantity
--                                            2 = recalculate batch secondary quantity
--                                            3 = recalculate onhand primary quantity
--                                            4 = recalculate onhand secondary quantity
--                                            5 = no quantity updates
--    p_reason_id             IN  NUMBER   - Id for Reason Code.
--    p_batch_id              IN  NUMBER   - Id for Batch Number
--    p_lot_uom_conv_rec      IN           - row containing lot conversion record data.
--    p_qty_update_tbl        IN           - table containing onhand balance update data.
--    x_msg_count             OUT NUMBER   - Message count
--    x_msg_data              OUT VARCHAR2  - If an error, send back the approriate message.
--    x_return_status         OUT VARCHAR2  - 'S'uccess, 'E'rror, 'U'nexpected Error
--    x_sequence              OUT VARCHAR2  - Header id from tm manager.
--
--  SYNOPSIS:
--    Create/update lot specific uom conversion and the supporting audit data.
--
--  HISTORY
--    Joe DiIorio     01-Sept-2004  Created.
--    SivakumarG      25-May-2006   Bug#5228919
--      Code added to insert lot attributes in mtlt, so that Lot transactions will show lot attributes
--      when we do Lot UOM conversion.
--    Archana Mundhe  27-Mar-2007   Bug 5533886
--      Added code to update batch transactions when update type is recalculate batch primary or secondary.
--=============================================================================================== */

PROCEDURE process_conversion_data
( p_action_type          IN              VARCHAR2
, p_update_type_indicator IN             NUMBER DEFAULT 5
, p_reason_id            IN              NUMBER
, p_batch_id             IN              NUMBER
, p_lot_uom_conv_rec     IN OUT NOCOPY   mtl_lot_uom_class_conversions%ROWTYPE
, p_qty_update_tbl       IN OUT NOCOPY   mtl_lot_uom_conv_pub.quantity_update_rec_type
, x_return_status        OUT NOCOPY      VARCHAR2
, x_msg_count            OUT NOCOPY      NUMBER
, x_msg_data             OUT NOCOPY      VARCHAR2
, x_sequence             OUT NOCOPY      NUMBER
)

IS

GENERIC_ERROR                  EXCEPTION;
INSERT_ERROR                   EXCEPTION;
OPEN_PERIOD_ERROR              EXCEPTION;

-- Bug 5533886
-- Added below 3 exceptions.
BATCH_UPDATE_ERROR             EXCEPTION;
BATCH_SAVE_ERROR               EXCEPTION;
UM_CONVERT_ERROR               EXCEPTION;

l_old_conversion_rate          NUMBER;
l_update_type varchar2(20);


CURSOR get_old_conv_Rate IS
 SELECT conversion_rate, conversion_id
 FROM   mtl_lot_uom_class_conversions
 WHERE  organization_id = p_lot_uom_conv_rec.organization_id AND
        inventory_item_id = p_lot_uom_conv_rec.inventory_item_id AND
        lot_number = p_lot_uom_conv_rec.lot_number AND
        from_uom_code = p_lot_uom_conv_rec.from_uom_code AND
        to_uom_code = p_lot_uom_conv_rec.to_uom_code;
l_conv_id         NUMBER;
CURSOR GET_AUDIT_SEQ IS
SELECT MTL_CONV_AUDIT_ID_S.NEXTVAL
FROM FND_DUAL;

l_audit_seq              NUMBER;


CURSOR GET_AUD_DET_SEQ
IS
SELECT MTL_CONV_AUDIT_DETAIL_ID_S.NEXTVAL
FROM FND_DUAL;

l_aud_det_seq              NUMBER;


l_ind                      NUMBER;

CURSOR GET_TEMP_SEQ
IS
SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
FROM FND_DUAL;

l_temp_seq                 NUMBER;
l_head_seq                 NUMBER := NULL;
l_transaction_type_id      NUMBER;
l_transaction_action_id    NUMBER;
l_period_id                NUMBER;
l_open_past_period         BOOLEAN;
 l_api_name   CONSTANT VARCHAR2 (30)            := 'process_conversion_data';
CONV_GET_ERR               EXCEPTION;

CURSOR get_uom_codes IS
SELECT primary_uom_code, secondary_uom_code
FROM MTL_SYSTEM_ITEMS
WHERE
organization_id = p_lot_uom_conv_rec.organization_id AND
inventory_item_id = p_lot_uom_conv_rec.inventory_item_id;

l_primary_uom             MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE%TYPE;
l_secondary_uom           MTL_SYSTEM_ITEMS.SECONDARY_UOM_CODE%TYPE;

/* Bug#5228919 added the following cursor to get the lot attributes
   from mtl_lot_numbers table */
CURSOR c_get_attr IS
 SELECT mln.*
 FROM   mtl_lot_numbers mln
 WHERE organization_id = p_lot_uom_conv_rec.organization_id
   AND inventory_item_id = p_lot_uom_conv_rec.inventory_item_id
   AND lot_number = p_lot_uom_conv_rec.lot_number;

l_lot_rec      mtl_lot_numbers%ROWTYPE;

-- Bug 5533886
Cursor get_batch_transactions IS
SELECT *
FROM   mtl_material_transactions mmt
WHERE  transaction_source_id = p_batch_id
AND    transaction_source_type_id = 5 -- gme_common_pvt.g_txn_source_type
AND    NOT EXISTS ( SELECT transaction_id1
                    FROM   gme_transaction_pairs
                    WHERE  transaction_id1 = mmt.transaction_id
                    AND    pair_type = 1) --gme_common_pvt.g_pairs_reversal_type
AND    inventory_item_id = p_lot_uom_conv_rec.inventory_item_id
AND    organization_id   = p_lot_uom_conv_rec.organization_id
AND    EXISTS (select 1
	                 From mtl_transaction_lot_numbers
	                 Where transaction_id = mmt.transaction_id
	                 And   lot_number    = p_lot_uom_conv_rec.lot_number);


Cursor get_lot_transactions (v_transaction_id NUMBER) IS
SELECT *
FROM    mtl_transaction_lot_numbers
WHERE transaction_id = v_transaction_id
AND lot_number = p_lot_uom_conv_rec.lot_number;

x_batch_txns mtl_material_transactions%ROWTYPE;
x_lot_txns   mtl_transaction_lot_numbers%ROWTYPE;
l_lot_transactions_tbl GME_COMMON_PVT.mtl_trans_lots_num_tbl;
i                         NUMBER;
j                         NUMBER;
txn_ind                   NUMBER;
new_ind                   NUMBER;
p_found                   NUMBER;
x_calc_qty                NUMBER;
x_calc_qty2               NUMBER;
x_trans_qty               NUMBER;
x_trans_qty2              NUMBER;
l_return_status           VARCHAR2(10);
l_primary_quantity        NUMBER;
l_batch_updated           NUMBER := 0;
l_secondary_quantity      NUMBER;
l_old_primary_quantity    NUMBER;
l_old_secondary_quantity  NUMBER;
l_batch_txn_qty           NUMBER;
l_transaction_uom_class   MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  SAVEPOINT PROCESS_CONVERSION_DATA;

  /*==================================================
     Insert or update mtl_lot_uom_class_conversions.
    ==================================================*/

  IF (p_action_type = 'I') THEN
    l_old_conversion_rate := NULL;
    mtl_lot_uom_conv_pkg.insert_row(
    p_lot_uom_conv_rec.conversion_id,
    p_lot_uom_conv_rec.lot_number,
    p_lot_uom_conv_rec.organization_id,
    p_lot_uom_conv_rec.inventory_item_id,
    p_lot_uom_conv_rec.from_unit_of_measure,
    p_lot_uom_conv_rec.from_uom_code,
    p_lot_uom_conv_rec.from_uom_class,
    p_lot_uom_conv_rec.to_unit_of_measure,
    p_lot_uom_conv_rec.to_uom_code,
    p_lot_uom_conv_rec.to_uom_class,
    p_lot_uom_conv_rec.conversion_rate,
    p_lot_uom_conv_rec.disable_date,
    p_lot_uom_conv_rec.event_spec_disp_id,
    p_lot_uom_conv_rec.created_by,
    p_lot_uom_conv_rec.creation_date,
    p_lot_uom_conv_rec.last_updated_by,
    p_lot_uom_conv_rec.last_update_date,
    p_lot_uom_conv_rec.last_update_login,
    p_lot_uom_conv_rec.request_id,
    p_lot_uom_conv_rec.program_application_id,
    p_lot_uom_conv_rec.program_id,
    p_lot_uom_conv_rec.program_update_date,
    x_return_status,
    x_msg_count,
    x_msg_data
    );
  ELSE

    /*===============================================
       Get existing conversion rate before updating.
      ===============================================*/

    OPEN get_old_conv_rate;
    FETCH get_old_conv_rate INTO l_old_conversion_rate, l_conv_id;
    IF (get_old_conv_rate%NOTFOUND) THEN
       CLOSE get_old_conv_rate;
       RAISE CONV_GET_ERR;
    END IF;
    CLOSE get_old_conv_rate;

    IF (p_lot_uom_conv_rec.conversion_id IS NULL) THEN
       p_lot_uom_conv_rec.conversion_id := l_conv_id;
    END IF;

    mtl_lot_uom_conv_pkg.update_row(
    p_lot_uom_conv_rec.conversion_id,
    p_lot_uom_conv_rec.lot_number,
    p_lot_uom_conv_rec.organization_id,
    p_lot_uom_conv_rec.inventory_item_id,
    p_lot_uom_conv_rec.from_unit_of_measure,
    p_lot_uom_conv_rec.from_uom_code,
    p_lot_uom_conv_rec.from_uom_class,
    p_lot_uom_conv_rec.to_unit_of_measure,
    p_lot_uom_conv_rec.to_uom_code,
    p_lot_uom_conv_rec.to_uom_class,
    p_lot_uom_conv_rec.conversion_rate,
    p_lot_uom_conv_rec.disable_date,
    p_lot_uom_conv_rec.event_spec_disp_id,
    p_lot_uom_conv_rec.last_updated_by,
    p_lot_uom_conv_rec.last_update_date,
    p_lot_uom_conv_rec.last_update_login,
    p_lot_uom_conv_rec.request_id,
    p_lot_uom_conv_rec.program_application_id,
    p_lot_uom_conv_rec.program_id,
    p_lot_uom_conv_rec.program_update_date,
    x_return_status,
    x_msg_count,
    x_msg_data
    );
  END IF;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE INSERT_ERROR;
  END IF;


-- Bug 5533886
-- Recalculate batch primary/secondary logic.
OPEN get_uom_codes;
FETCH get_uom_codes INTO l_primary_uom, l_secondary_uom;
CLOSE get_uom_codes;

gme_common_pvt.g_move_to_temp := fnd_api.g_false;

gme_common_pvt.g_setup_done := gme_common_pvt.setup (p_lot_uom_conv_rec.organization_id);
gme_common_pvt.set_who;


-- Bug 5533886
IF (p_update_type_indicator IN ('1','2')) THEN
   OPEN get_batch_transactions;
   LOOP

   FETCH get_batch_transactions INTO x_batch_txns;
   EXIT WHEN GET_BATCH_TRANSACTIONS%NOTFOUND;
      txn_ind := 1;


   OPEN get_lot_transactions(x_batch_txns.transaction_id);
   FETCH get_lot_transactions BULK COLLECT INTO l_lot_transactions_tbl;
   CLOSE get_lot_transactions;

   SELECT uom_class
   INTO l_transaction_uom_class
   FROM mtl_units_of_measure_vl
   WHERE uom_code = x_batch_txns.transaction_uom;

      i:=1;
      l_batch_txn_qty := 0;
      FOR i in 1..l_lot_transactions_tbl.count
      LOOP
            IF (p_update_type_indicator = 1) THEN
                l_old_primary_quantity := l_lot_transactions_tbl(i).primary_quantity;

                IF ( l_transaction_uom_class = p_lot_uom_conv_rec.from_uom_class) THEN
                   x_trans_qty := inv_convert.inv_um_convert(
                                     item_id    => p_lot_uom_conv_rec.inventory_item_id,
                                     lot_number => p_lot_uom_conv_rec.lot_number,
                                     organization_id => p_lot_uom_conv_rec.organization_id,
                                     precision => 5,
                                     from_quantity => l_lot_transactions_tbl(i).secondary_transaction_quantity,
                                     from_unit => x_batch_txns.secondary_uom_code,
                                     to_unit => x_batch_txns.transaction_uom,
	                             from_name => NULL,
                                     to_name => NULL
                                     );

                    IF x_trans_qty = -99999 THEN
                        RAISE UM_CONVERT_ERROR;
                    END IF;
                    l_lot_transactions_tbl(i).transaction_quantity := x_trans_qty;

                 END IF;
                    x_calc_qty := inv_convert.inv_um_convert(
                                     item_id    => p_lot_uom_conv_rec.inventory_item_id,
                                     lot_number => p_lot_uom_conv_rec.lot_number,
                                     organization_id => p_lot_uom_conv_rec.organization_id,
                                     precision => 5,
                                     from_quantity => l_lot_transactions_tbl(i).secondary_transaction_quantity,
                                     from_unit => x_batch_txns.secondary_uom_code,
                                     to_unit => l_primary_uom,
	                             from_name => NULL,
                                     to_name => NULL
                                     );
                    IF x_calc_qty = -99999 THEN
                        RAISE UM_CONVERT_ERROR;
                    END IF;
                   l_lot_transactions_tbl(i).primary_quantity := x_calc_qty;
                   p_found := 0;

                  FOR j in 1..p_qty_update_tbl.count
                   LOOP
                       IF (p_qty_update_tbl(j).subinventory_code = x_batch_txns.subinventory_code AND
nvl(p_qty_update_tbl(j).locator_id,-1) = nvl(x_batch_txns.locator_id,nvl(p_qty_update_tbl(j).locator_id,-1)) ) THEN

                -- Bug 6317236
                -- Commenting this code as the logic is now moved to the form.

		/* p_qty_update_tbl(j).transaction_primary_qty := p_qty_update_tbl(j).transaction_primary_qty -
		(l_lot_transactions_tbl(i).primary_quantity - l_old_primary_quantity) ;
                */
                           p_found := 1;
                       END IF;
                   END LOOP;

                   IF p_found = 0 THEN
                          new_ind := p_qty_update_tbl.count + 1;
                          p_qty_update_tbl(new_ind).organization_id := p_lot_uom_conv_rec.organization_id;
                          p_qty_update_tbl(new_ind).subinventory_code := x_batch_txns.subinventory_code;
 			  p_qty_update_tbl(new_ind).locator_id := nvl(x_batch_txns.locator_id,p_qty_update_tbl(j).locator_id);
 			  p_qty_update_tbl(new_ind).old_primary_qty := 0;
 			  p_qty_update_tbl(new_ind).old_secondary_qty := 0;
 			  p_qty_update_tbl(new_ind).new_primary_qty := -1 *  l_lot_transactions_tbl(i).primary_quantity ;
  			  p_qty_update_tbl(new_ind).transaction_primary_qty := -1 *
  			                           l_lot_transactions_tbl(i).primary_quantity;
                          p_qty_update_tbl(new_ind).transaction_update_flag := 1;

                   END IF;

             ELSIF (p_update_type_indicator = 2) THEN
                 l_old_secondary_quantity := l_lot_transactions_tbl(i).secondary_transaction_quantity;
                IF (l_transaction_uom_class = p_lot_uom_conv_rec.to_uom_class) THEN
                   x_trans_qty2 := inv_convert.inv_um_convert(
                                     item_id => p_lot_uom_conv_rec.inventory_item_id,
                                     lot_number => p_lot_uom_conv_rec.lot_number,
                                     organization_id => p_lot_uom_conv_rec.organization_id,
                                     precision => 5,
                                     from_quantity => l_lot_transactions_tbl(i).primary_quantity,
                                     from_unit => l_primary_uom,
                                     to_unit => x_batch_txns.transaction_uom,
                                     from_name => NULL,
                                     to_name => NULL
                               );

                   IF x_trans_qty2 = -99999 THEN
                        RAISE UM_CONVERT_ERROR;
                    END IF;
                   l_lot_transactions_tbl(i).transaction_quantity := x_trans_qty2;
                END IF; -- transaction_uom = primary_uom
                   x_calc_qty2 := inv_convert.inv_um_convert(
                                     item_id    => p_lot_uom_conv_rec.inventory_item_id,
                                     lot_number => p_lot_uom_conv_rec.lot_number,
                                     organization_id => p_lot_uom_conv_rec.organization_id,
                                     precision => 5,
                                     from_quantity => l_lot_transactions_tbl(i).primary_quantity,
                                     from_unit => l_primary_uom,
                                     to_unit => x_batch_txns.secondary_uom_code,
	                             from_name => NULL,
                                     to_name => NULL
                                     );
                   IF x_calc_qty2 = -99999 THEN
                        RAISE UM_CONVERT_ERROR;
                    END IF;
                   l_lot_transactions_tbl(i).secondary_transaction_quantity := x_calc_qty2;
                   p_found := 0;
                   FOR j in 1..p_qty_update_tbl.count
                   LOOP
                       IF (p_qty_update_tbl(j).subinventory_code = x_batch_txns.subinventory_code AND
nvl(p_qty_update_tbl(j).locator_id,-1) = nvl(x_batch_txns.locator_id,nvl(p_qty_update_tbl(j).locator_id,-1)) ) THEN

		-- Bug 6317236
                -- Commenting this code as the logic is now moved to the form.

		/* p_qty_update_tbl(j).transaction_secondary_qty := p_qty_update_tbl(j).transaction_secondary_qty -
		(l_lot_transactions_tbl(i).secondary_transaction_quantity - l_old_secondary_quantity) ;
                */
                           p_found := 1;
                       END IF;
                   END LOOP;
                   IF p_found = 0 THEN
                          new_ind := p_qty_update_tbl.count + 1;
                          p_qty_update_tbl(new_ind).organization_id := p_lot_uom_conv_rec.organization_id;
                          p_qty_update_tbl(new_ind).subinventory_code := x_batch_txns.subinventory_code;
 			  p_qty_update_tbl(new_ind).locator_id := x_batch_txns.locator_id;
 			  p_qty_update_tbl(new_ind).old_primary_qty := 0;
 			  p_qty_update_tbl(new_ind).old_secondary_qty := 0;
 			  p_qty_update_tbl(new_ind).new_secondary_qty := -1 *
 			                   l_lot_transactions_tbl(i).secondary_transaction_quantity ;
  			  p_qty_update_tbl(new_ind).transaction_secondary_qty := -1 *
                                                                   l_lot_transactions_tbl(i).secondary_transaction_quantity;                           p_qty_update_tbl(new_ind).transaction_update_flag := 1;
                   END IF;
           END IF;
        l_batch_txn_qty := l_batch_txn_qty + l_lot_transactions_tbl(i).transaction_quantity;

       END LOOP; -- l_lot_transactions_tbl

       x_batch_txns.transaction_quantity := l_batch_txn_qty;
       gme_transactions_pvt.update_material_txn
              (p_mmt_rec         => x_batch_txns
              ,p_mmln_tbl        => l_lot_transactions_tbl
              ,x_return_status   => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
             RAISE BATCH_UPDATE_ERROR;
          END IF;

       l_batch_updated := 1;
     END LOOP; -- Batch transactions
  CLOSE get_batch_transactions;

END IF; -- p_update_type_indicator in 1,2

  /*==================================================
     Insert Audit Record.
    tempy check on conversion date.
    tempy - event spec disp id.
    ==================================================*/

  OPEN GET_AUDIT_SEQ;
  FETCH GET_AUDIT_SEQ INTO l_audit_seq;
  CLOSE GET_AUDIT_SEQ;

  p_lot_uom_conv_rec.created_by := p_lot_uom_conv_rec.last_updated_by;
  p_lot_uom_conv_rec.creation_date := p_lot_uom_conv_rec.last_update_date;

  mtl_lot_conv_audit_pkg.insert_row (
  l_audit_seq,
  p_lot_uom_conv_rec.conversion_id,
  SYSDATE,
  p_update_type_indicator,
  p_batch_id,
  p_reason_id,
  l_old_conversion_rate,
  p_lot_uom_conv_rec.conversion_rate,
  p_lot_uom_conv_rec.event_spec_disp_id,
  p_lot_uom_conv_rec.created_by,
  p_lot_uom_conv_rec.creation_date,
  p_lot_uom_conv_rec.last_updated_by,
  p_lot_uom_conv_rec.last_update_date,
  p_lot_uom_conv_rec.last_update_login,
  x_return_status,
  x_msg_count,
  x_msg_data);


  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE INSERT_ERROR;
  END IF;

-- SCHANDRU INVERES START
IF(g_eres_enabled = 'Y') THEN
   IF (p_action_type = 'I') then
 	l_update_type := 'LOT-CONV-INSERT';
   ELSE
	L_UPDATE_TYPE := 'LOT-CONV-UPDATE';
   END IF;
 Insert into MTL_UOM_CONVERSIONS_ERES_GTMP (
    CONVERSION_TYPE,
    INVENTORY_ITEM_ID,
    FROM_UOM_CODE,
    FROM_UOM_CLASS,
    TO_UOM_CODE,
    TO_UOM_CLASS,
    LOT_NUMBER,
    CONVERSION_ID,
    CONV_AUDIT_ID)
  VALUES
    (L_UPDATE_TYPE,
     p_lot_uom_conv_rec.inventory_item_id,
     p_lot_uom_conv_rec.from_uom_code,
     p_lot_uom_conv_rec.from_uom_class,
     p_lot_uom_conv_rec.to_uom_code,
     p_lot_uom_conv_rec.to_uom_class,
     p_lot_uom_conv_rec.lot_number,
     p_lot_uom_conv_rec.conversion_id,
     l_audit_seq);
END IF;

--SCHANDRU INVERES END


  /*======
=======================================
     Loop through detail records.
     Insert transaction if necessary and insert
     audit detail record.
    =============================================*/



  l_ind := 1;
  LOOP

     IF (p_qty_update_tbl.EXISTS(l_ind)) THEN

        IF (p_qty_update_tbl(l_ind).transaction_update_flag = '1') THEN
           IF (p_qty_update_tbl(l_ind).transaction_primary_qty = 0 AND
            NVL(p_qty_update_tbl(l_ind).transaction_secondary_qty,0) = 0) THEN
               GOTO BYPASS;
           END IF;

             IF (l_head_seq IS NULL) THEN
                OPEN GET_TEMP_SEQ;
                FETCH GET_TEMP_SEQ into l_head_seq;
                IF (GET_TEMP_SEQ%NOTFOUND) THEN
                  CLOSE GET_TEMP_SEQ;
                  RAISE GENERIC_ERROR;
                END IF;
                CLOSE GET_TEMP_SEQ;
                x_sequence := l_head_seq;
           END IF;

         /*===========================================
             Check for open period and get period id.
           ===========================================*/

        INVTTMTX.TDATECHK(
          org_id => p_lot_uom_conv_rec.organization_id,
          transaction_date => SYSDATE,
          period_id => l_period_id,
          open_past_period => l_open_past_period);

        IF (l_period_id = 0) THEN
              RAISE OPEN_PERIOD_ERROR;

        ELSIF (l_period_id = -1) THEN
              RAISE GENERIC_ERROR;
        END IF;

       /*===========================
            Set Tranaction Type ID
         ===========================*/

       IF (p_qty_update_tbl(l_ind).transaction_primary_qty = 0) THEN
          IF (p_qty_update_tbl(l_ind).transaction_secondary_qty >= 0) THEN
              /*====================
                    BUG#4320911
                ====================*/
              l_transaction_type_id := 1004;
              l_transaction_action_id := 27;
          ELSE
              l_transaction_type_id := 97;
              l_transaction_action_id := 1;
          END IF;
       ELSIF (p_qty_update_tbl(l_ind).transaction_primary_qty >= 0) THEN
              l_transaction_type_id := 1004;
              l_transaction_action_id := 27;
           ELSE   -- negative
              l_transaction_type_id := 97;
              l_transaction_action_id := 1;
           END IF;

        /*===========================================
             Get primary and secondary uom code.
          ===========================================*/

       OPEN get_uom_codes;
       FETCH get_uom_codes INTO l_primary_uom, l_secondary_uom;
       CLOSE get_uom_codes;

       -- tempy add error handling.



              OPEN GET_TEMP_SEQ;
              FETCH GET_TEMP_SEQ into l_temp_seq;
              IF (GET_TEMP_SEQ%NOTFOUND) THEN
                 CLOSE GET_TEMP_SEQ;
                 RAISE GENERIC_ERROR;
              END IF;
              CLOSE GET_TEMP_SEQ;


           /*=============================
               Insert to Temp Table.
             =============================*/

           INSERT INTO MTL_MATERIAL_TRANSACTIONS_TEMP (
             transaction_header_id,
             transaction_temp_id,
             transaction_type_id,
             transaction_action_id,
             transaction_source_type_id,
             acct_period_id,
             organization_id,
             inventory_item_id,
             primary_quantity,
             transaction_quantity,
             transaction_uom,
             secondary_transaction_quantity,
             secondary_uom_code,
             transaction_date,
             process_flag,
             lock_flag,
             revision,
             lot_number,
             subinventory_code,
             locator_id,
             lpn_id,
             last_update_date,
             last_updated_by,
             created_by,
             creation_date)
           VALUES (
             l_head_seq,
             l_temp_seq,
             l_transaction_type_id,
             l_transaction_action_id,
             13,
             l_period_id,
             p_lot_uom_conv_rec.organization_id,
             p_lot_uom_conv_rec.inventory_item_id,
             p_qty_update_tbl(l_ind).transaction_primary_qty,
             p_qty_update_tbl(l_ind).transaction_primary_qty,
             l_primary_uom,
             p_qty_update_tbl(l_ind).transaction_secondary_qty,
             l_secondary_uom,
             SYSDATE,
             'Y',
             2,
             p_qty_update_tbl(l_ind).revision,
             p_lot_uom_conv_rec.lot_number,
             p_qty_update_tbl(l_ind).subinventory_code,
             p_qty_update_tbl(l_ind).locator_id,
             p_qty_update_tbl(l_ind).lpn_id,
             SYSDATE,
             p_lot_uom_conv_rec.last_updated_by,
             p_lot_uom_conv_rec.last_updated_by,
             SYSDATE
           );


           /*=============================
               Insert to Lot Temp Table.
             =============================*/
	   --Bug#5228919
           OPEN c_get_attr;
	   FETCH c_get_attr INTO l_lot_rec;
	   CLOSE c_get_attr;

           INSERT INTO MTL_TRANSACTION_LOTS_TEMP (
             transaction_temp_id,
             lot_number,
             primary_quantity,
             transaction_quantity,
             secondary_quantity,
             secondary_unit_of_measure,
             last_update_date,
             last_updated_by,
             created_by,
             creation_date,
	     --Bug#5228919 Begin
	     reason_id,
             grade_code,
	     maturity_date,
             origination_date,
             retest_date,
             supplier_lot_number,
             attribute_category,
             lot_attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             c_attribute1,
             c_attribute2,
             c_attribute3,
             c_attribute4,
             c_attribute5,
             c_attribute6,
             c_attribute7,
             c_attribute8,
             c_attribute9,
             c_attribute10,
             c_attribute11,
             c_attribute12,
             c_attribute13,
             c_attribute14,
             c_attribute15,
             c_attribute16,
             c_attribute17,
             c_attribute18,
             c_attribute19,
             c_attribute20,
             d_attribute1,
             d_attribute2,
             d_attribute3,
             d_attribute4,
             d_attribute5,
             d_attribute6,
             d_attribute7,
             d_attribute8,
             d_attribute9,
             d_attribute10,
             n_attribute1,
             n_attribute2,
             n_attribute3,
             n_attribute4,
             n_attribute5,
             n_attribute6,
             n_attribute7,
             n_attribute8,
             n_attribute9,
             n_attribute10 )  --Bug#5228919 End
           VALUES (
             l_temp_seq,
             p_lot_uom_conv_rec.lot_number,
             ABS(p_qty_update_tbl(l_ind).transaction_primary_qty),
             ABS(p_qty_update_tbl(l_ind).transaction_primary_qty),
             ABS(p_qty_update_tbl(l_ind).transaction_secondary_qty),
             l_secondary_uom,
             SYSDATE,
             p_lot_uom_conv_rec.last_updated_by,
             p_lot_uom_conv_rec.last_updated_by,
             SYSDATE,
	     --Bug#5228919 Begin
	     p_reason_id,
             l_lot_rec.grade_code,
             l_lot_rec.maturity_date,
             l_lot_rec.origination_date,
             l_lot_rec.retest_date,
             l_lot_rec.supplier_lot_number,
	     l_lot_rec.attribute_category,
	     l_lot_rec.lot_attribute_category,
	     l_lot_rec.attribute1,
	     l_lot_rec.attribute2,
	     l_lot_rec.attribute3,
	     l_lot_rec.attribute4,
	     l_lot_rec.attribute5,
	     l_lot_rec.attribute6,
	     l_lot_rec.attribute7,
	     l_lot_rec.attribute8,
	     l_lot_rec.attribute9,
	     l_lot_rec.attribute10,
	     l_lot_rec.attribute11,
	     l_lot_rec.attribute12,
	     l_lot_rec.attribute13,
	     l_lot_rec.attribute14,
	     l_lot_rec.attribute15,
	     l_lot_rec.c_attribute1,
	     l_lot_rec.c_attribute2,
	     l_lot_rec.c_attribute3,
	     l_lot_rec.c_attribute4,
	     l_lot_rec.c_attribute5,
	     l_lot_rec.c_attribute6,
	     l_lot_rec.c_attribute7,
	     l_lot_rec.c_attribute8,
	     l_lot_rec.c_attribute9,
	     l_lot_rec.c_attribute10,
	     l_lot_rec.c_attribute11,
	     l_lot_rec.c_attribute12,
	     l_lot_rec.c_attribute13,
	     l_lot_rec.c_attribute14,
	     l_lot_rec.c_attribute15,
	     l_lot_rec.c_attribute16,
	     l_lot_rec.c_attribute17,
	     l_lot_rec.c_attribute18,
	     l_lot_rec.c_attribute19,
	     l_lot_rec.c_attribute20,
	     l_lot_rec.d_attribute1,
	     l_lot_rec.d_attribute2,
	     l_lot_rec.d_attribute3,
	     l_lot_rec.d_attribute4,
	     l_lot_rec.d_attribute5,
	     l_lot_rec.d_attribute6,
	     l_lot_rec.d_attribute7,
	     l_lot_rec.d_attribute8,
	     l_lot_rec.d_attribute9,
	     l_lot_rec.d_attribute10,
	     l_lot_rec.n_attribute1,
	     l_lot_rec.n_attribute2,
	     l_lot_rec.n_attribute3,
	     l_lot_rec.n_attribute4,
	     l_lot_rec.n_attribute5,
	     l_lot_rec.n_attribute6,
	     l_lot_rec.n_attribute7,
	     l_lot_rec.n_attribute8,
	     l_lot_rec.n_attribute9,
	     l_lot_rec.n_attribute10
             --Bug#5228919 End
            );

        END IF;  -- endif for transaction needed


        /*======================================
            Insert a audit detail record whether
            there was a transaction or not.
          ======================================*/

<<BYPASS>>
        OPEN GET_AUD_DET_SEQ;
        FETCH GET_AUD_DET_SEQ INTO l_aud_det_seq;
        IF (GET_AUD_DET_SEQ%NOTFOUND) then
           CLOSE GET_AUD_DET_SEQ;
           RAISE GENERIC_ERROR;
        END IF;
        CLOSE GET_AUD_DET_SEQ;

     MTL_LOT_CONV_AUD_DET_PKG.INSERT_ROW(
      X_CONV_AUDIT_DETAIL_ID => l_aud_det_seq,
      X_CONV_AUDIT_ID => l_audit_seq,
      X_REVISION  => p_qty_update_tbl(l_ind).revision,
      X_ORGANIZATION_ID  => p_qty_update_tbl(l_ind).organization_id,
      X_SUBINVENTORY_CODE => p_qty_update_tbl(l_ind).subinventory_code,
      X_LPN_ID => p_qty_update_tbl(l_ind).lpn_id,
      X_LOCATOR_ID => p_qty_update_tbl(l_ind).locator_id,
      X_OLD_PRIMARY_QTY => p_qty_update_tbl(l_ind).old_primary_qty,
      X_OLD_SECONDARY_QTY => p_qty_update_tbl(l_ind).old_secondary_qty,
      X_NEW_PRIMARY_QTY => p_qty_update_tbl(l_ind).new_primary_qty,
      X_NEW_SECONDARY_QTY => p_qty_update_tbl(l_ind).new_secondary_qty,
      X_TRANSACTION_PRIMARY_QTY => p_qty_update_tbl(l_ind).transaction_primary_qty,
      X_TRANSACTION_SECONDARY_QTY => p_qty_update_tbl(l_ind).transaction_secondary_qty,
      X_TRANSACTION_UPDATE_FLAG => p_qty_update_tbl(l_ind).transaction_update_flag,
      X_CREATED_BY => p_lot_uom_conv_rec.created_by,
      X_CREATION_DATE => p_lot_uom_conv_rec.creation_date,
      X_LAST_UPDATED_BY => p_lot_uom_conv_rec.last_updated_by,
      X_LAST_UPDATE_DATE => p_lot_uom_conv_rec.last_update_date,
      X_LAST_UPDATE_LOGIN => p_lot_uom_conv_rec.last_update_login,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data);
         l_ind := l_ind + 1;
     ELSE
         EXIT;
     END IF;  -- rec dont exist


  END LOOP;

  -- Bug 5533886
  -- Call save batch api to save the updated material transactions.
  gme_api_pub.save_batch    (
                          X_return_status   => l_return_status,
                          p_header_id => gme_common_pvt.get_txn_header_id,
                          p_table => 1,
                          p_commit => 'F',
                          p_clear_qty_cache => 'T');

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE BATCH_SAVE_ERROR;
  END IF;


EXCEPTION

  WHEN GENERIC_ERROR THEN
     ROLLBACK;
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN CONV_GET_ERR THEN
     ROLLBACK;
     FND_MESSAGE.SET_NAME('INV','INV_LOTC_SQL_ERROR');
     FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
     FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  WHEN INSERT_ERROR THEN
     ROLLBACK;
     FND_MESSAGE.SET_NAME('INV','INV_LOTC_SQL_ERROR');
     FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
     FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  WHEN OPEN_PERIOD_ERROR THEN
     ROLLBACK;
     FND_MESSAGE.SET_NAME('INV','INV_NO_OPEN_PERIOD');
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_ERROR;

 -- Bug 5533886
 -- Added next 3 exceptions.
 WHEN UM_CONVERT_ERROR THEN
      FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
      fnd_msg_pub.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN BATCH_UPDATE_ERROR THEN
     x_return_status := l_return_status;

 WHEN BATCH_SAVE_ERROR THEN
     x_return_status := l_return_status;

  WHEN OTHERS THEN

    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('INV','INV_LOTC_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
    ELSE
      FND_MESSAGE.SET_NAME('INV','INV_BUSRULES_GENERIC_ERR');
    END IF;
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    ROLLBACK;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('INV','INV_LOTC_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
    ELSE
      FND_MESSAGE.SET_NAME('INV','INV_BUSRULES_GENERIC_ERR');
    END IF;
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END process_conversion_data;


/*===========================================================================
--  PROCEDURE
--    copy_lot_uom_conversions
--
--  DESCRIPTION:
--    This PL/SQL procedure will copy lot uom conversions from one lot to
--    another.
--
--  PARAMETERS:
--    p_inventory_item_id    IN  NUMBER    - Item id.
--    p_from_organization_id IN  NUMBER    - Id of org to be copied from.
--    p_from_lot_number      IN  VARCHAR2  - lot number to be copied from.
--    p_to_organization_id   IN  NUMBER    - Id of org to be copied to.
--    p_to_lot_number        IN  VARCHAR2  - lot number to copy conversions to.
--    p_user_id              IN  NUMBER    - userid to use on the created records.
--    p_creation_date        IN  DATE      - create date to use on the created records.
--    p_commit               IN  VARCHAR2  - Commit flag
--    x_msg_count            OUT NUMBER    - Message count
--    x_msg_data             OUT VARCHAR2  - If an error, send back the approriate message.
--    x_return_status        OUT VARCHAR2  - 'S'uccess, 'E'rror, 'U'nexpected Error
--
--  SYNOPSIS:
--    Copy lot uom conversions from one lot to another.
--
--  HISTORY
--    Joe DiIorio     01-Sept-2004  Created.
--
--=========================================================================== */

PROCEDURE copy_lot_uom_conversions
( p_inventory_item_id   IN NUMBER,
  p_from_organization_id IN NUMBER,
  p_from_lot_number     IN VARCHAR2,
  p_to_organization_id   IN NUMBER,
  p_to_lot_number       IN VARCHAR2,
  p_user_id             IN NUMBER,
  p_creation_date       IN DATE,
  p_commit              IN VARCHAR2,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2
)


IS

NO_CONVERSIONS_FOUND        EXCEPTION;
CONVERSION_INSERT_ERROR     EXCEPTION;

/*======================================
    Cursor to Retrieve Conversions to
    be Copied.
  ======================================*/

CURSOR c_get_conversions IS
SELECT *
FROM   mtl_lot_uom_class_conversions
WHERE  nvl(disable_date, trunc(sysdate)+1) > trunc(sysdate)
AND    organization_id = p_from_organization_id
AND    lot_number = p_from_lot_number
AND    inventory_item_id = p_inventory_item_id;

l_lot_uom_conv_rec      mtl_lot_uom_class_conversions%ROWTYPE;

/*======================================
    Cursor to Retrieve Reason_id.
--tempy do not use until this is loaded
-- do we need to load?
-- and translation issue is worked out.
  ======================================*/

CURSOR c_get_reason_id IS
SELECT reason_id
FROM   mtl_transaction_reasons
WHERE  reason_name = 'Copy Lot Conversions';

l_reason_id            NUMBER;
l_return_status        VARCHAR2(240);
l_error_message        VARCHAR2(2000);
l_msg_count            NUMBER;
l_qty_update_tbl       mtl_lot_uom_conv_pub.quantity_update_rec_type;

/*=========================================
    Cursor to check if conversion exists.
  =========================================*/

CURSOR c_check_exists IS
SELECT 1
FROM   mtl_lot_uom_class_conversions
WHERE  organization_id = p_to_organization_id
AND    lot_number = p_to_lot_number
AND    inventory_item_id = p_inventory_item_id
AND    from_uom_code = l_lot_uom_conv_rec.from_uom_code
AND    to_uom_code = l_lot_uom_conv_rec.to_uom_code;

l_exists_cnt              NUMBER;
l_seq                     NUMBER;
l_creation_date           DATE;
l_user_id                 NUMBER;

BEGIN

  IF (p_user_id IS NULL) THEN
    l_user_id := FND_GLOBAL.USER_ID;
  END IF;
  IF (p_creation_date IS NULL) THEN
    l_creation_date := SYSDATE;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN c_get_conversions;
  FETCH c_get_conversions INTO l_lot_uom_conv_rec;
  IF (c_get_conversions%NOTFOUND) THEN
     CLOSE c_get_conversions;
     RETURN;
  ELSE
     SAVEPOINT COPY_CONVERSION;
     WHILE c_get_conversions%FOUND LOOP
        /*============================================
           Insert Reason Logic here.  tempy
          ============================================*/

        l_lot_uom_conv_rec.lot_number := p_to_lot_number;
        l_lot_uom_conv_rec.organization_id := p_to_organization_id;
        /*============================================
           If user id passed in use it for the who
           columns.  Otherwise use existing who info.
          ============================================*/
        IF (p_user_id IS NOT NULL) THEN
           l_lot_uom_conv_rec.created_by := p_user_id;
           l_lot_uom_conv_rec.last_updated_by := p_user_id;
        ELSE
           l_lot_uom_conv_rec.created_by := l_user_id;
           l_lot_uom_conv_rec.last_updated_by := l_user_id;
        END IF;
        IF (p_creation_date IS NULL) THEN
         l_lot_uom_conv_rec.creation_date := l_creation_date;
         l_lot_uom_conv_rec.last_update_date := l_lot_uom_conv_rec.creation_date;
        ELSE
         l_lot_uom_conv_rec.creation_date := p_creation_date;
         l_lot_uom_conv_rec.last_update_date := p_creation_date;
        END IF;

        /*==============================================
           Null out the conversion id.
          ==============================================*/
        l_lot_uom_conv_rec.conversion_id  := NULL;
        /*==============================================
           Insert the new conversion and audit record.
           if conversion does not exist already.
          ==============================================*/
        l_exists_cnt := 0;
        OPEN c_check_exists;
        FETCH c_check_exists INTO l_exists_cnt;
        CLOSE c_check_exists;
        IF (l_exists_cnt = 0) THEN
           process_conversion_data(
                'I',5,l_reason_id,NULL,l_lot_uom_conv_rec,
                l_qty_update_tbl,l_return_status,l_msg_count,l_error_message,l_seq);
           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              CLOSE c_get_conversions;
              RAISE CONVERSION_INSERT_ERROR;
           END IF;
        END IF;
        FETCH c_get_conversions INTO l_lot_uom_conv_rec;

     END LOOP;


  END IF;  -- conversion cursor

  CLOSE c_get_conversions;

  /*=============================
     Issue commit if required.
    ============================*/
  IF (p_commit = FND_API.G_TRUE) THEN
     COMMIT;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

  WHEN NO_CONVERSIONS_FOUND THEN
     FND_MESSAGE.SET_NAME('INV','INV_LOTC_NO_CONV_FOUND');
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN CONVERSION_INSERT_ERROR THEN
     ROLLBACK TO COPY_CONVERSION;
     FND_MESSAGE.SET_NAME('INV','INV_LOTC_CONV_INSERT_ERROR');
     FND_MSG_PUB.Add;
     IF (SQLCODE IS NOT NULL) THEN
       FND_MESSAGE.SET_NAME('INV','INV_LOTC_SQL_ERROR');
       FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
       FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
       FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    ROLLBACK TO COPY_CONVERSION;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('INV','INV_LOTC_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
    ELSE
      FND_MESSAGE.SET_NAME('INV','INV_BUSRULES_GENERIC_ERR');
    END IF;
    FND_MSG_PUB.Add;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	END copy_lot_uom_conversions;


	/*===========================================================================
	--  FUNCTION:
	--    validate_onhand_equals_avail
	--
	--  DESCRIPTION:
	--    This function validates that no changes have been made to the quantity tree.
	--    Checks if any reservations exist.
	--
	--  PARAMETERS:
	--    p_organization_id     IN NUMBER     - organization id
	--    p_inventory_item_id   IN NUMBER     - item id
	--    p_lot_number          IN VARCHAR2   - lot number
	--    p_header_id           IN NUMBER     - header id of current transaction
	--    return                OUT   NUMBER  - G_TRUE or G_FALSE
	--
	--  SYNOPSIS:
	--    Check reservations.
	--
	--  HISTORY
	--    Joe DiIorio     01-Sept-2004  Created.
	--
	--=========================================================================== */


	FUNCTION validate_onhand_equals_avail (
	    p_organization_id      IN NUMBER,
	    p_inventory_item_id    IN NUMBER,
	    p_lot_number           IN VARCHAR2,
	    p_header_id            IN NUMBER)
	  return NUMBER    IS

	/*============================================
	   Cursor to check against interface table.
	  ============================================*/

	CURSOR c_check_mti IS
	SELECT 1
	FROM mtl_transactions_interface
	WHERE source_lot_number = p_lot_number
	AND   inventory_item_id = p_inventory_item_id
	AND   organization_id = p_organization_id
	AND   transaction_type_id NOT IN (95,1004);

              /*========================
                    BUG#4320911
                 Type from 96 to 1004.
                ========================*/
	CURSOR c_check_mti_head IS
	SELECT 1
	FROM mtl_transactions_interface
	WHERE source_lot_number = p_lot_number
	AND   inventory_item_id = p_inventory_item_id
	AND   organization_id = p_organization_id
	AND   transaction_type_id NOT IN (95,1004)
	AND   transaction_header_id <> p_header_id;


	/*============================================
	   Cursor to check against temp transaction
	   table.
	  ============================================*/

	CURSOR c_check_mmtt IS
	SELECT 1
	FROM mtl_material_transactions_temp
	WHERE lot_number = p_lot_number
	AND   inventory_item_id = p_inventory_item_id
	AND   organization_id = p_organization_id;

	CURSOR c_check_mmtt_head IS
	SELECT 1
	FROM mtl_material_transactions_temp
	WHERE lot_number = p_lot_number
	AND   inventory_item_id = p_inventory_item_id
	AND   organization_id = p_organization_id
	AND   transaction_header_id <> p_header_id
        AND   process_flag <> 'E';

	l_count                     NUMBER := 0;

	EXISTING_RESERVATIONS       EXCEPTION;


	BEGIN

	  /*============================================
	     Cursor to check against interface table.
	    ============================================*/

          IF (p_header_id IS NULL) THEN
     	     OPEN c_check_mti;
	     FETCH c_check_mti INTO l_count;
	     CLOSE c_check_mti;
	     IF (l_count > 0) THEN
	        RAISE EXISTING_RESERVATIONS;
	     END IF;
          ELSE
     	     OPEN c_check_mti_head;
	     FETCH c_check_mti_head INTO l_count;
	     CLOSE c_check_mti_head;
	     IF (l_count > 0) THEN
	        RAISE EXISTING_RESERVATIONS;
	     END IF;
          END IF;

	/*============================================
	   Cursor to check against temp transaction
	   table.
	  ============================================*/

          IF (p_header_id IS NULL) THEN
             OPEN c_check_mmtt;
             FETCH c_check_mmtt INTO l_count;
             CLOSE c_check_mmtt;
             IF (l_count > 0) THEN
                RAISE EXISTING_RESERVATIONS;
             END IF;
          ELSE
             OPEN c_check_mmtt_head;
             FETCH c_check_mmtt_head INTO l_count;
             CLOSE c_check_mmtt_head;
             IF (l_count > 0) THEN
                RAISE EXISTING_RESERVATIONS;
             END IF;
          END IF;


  RETURN G_TRUE;


EXCEPTION

  WHEN EXISTING_RESERVATIONS THEN
     FND_MESSAGE.SET_NAME('INV','INV_LOT_RESERVATIONS_EXIST');
     FND_MSG_PUB.Add;
     RETURN G_FALSE;


  WHEN OTHERS THEN
     RETURN G_FALSE;

END validate_onhand_equals_avail;


END;

/
