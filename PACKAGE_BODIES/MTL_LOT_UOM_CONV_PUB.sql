--------------------------------------------------------
--  DDL for Package Body MTL_LOT_UOM_CONV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_LOT_UOM_CONV_PUB" AS
/* $Header: INVPLUCB.pls 120.1 2006/09/01 04:05:26 svgonugu noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    INVPLUCB.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    MTL_LOT_UOM_CONV_PUB                                                  |
 | TYPE                                                                     |
 |   Public                                                                 |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    Public layer for Lot Uom Conversion APIs.                             |
 |                                                                          |
 | CONTENTS                                                                 |
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created    Joe DiIorio                                                 |
 |   Updated    Joe DiIorio  - 08/01/2004                                   |
 |              Changed named and parms for lot_uom_conversion to           |
 |              create_lot_uom_conversion.                                  |
 |              Changed call to business_logic to                           |
 |              validate_lot_conversion_rules.                              |
 |   Updated    Joe DiIorio  - 09/16/2004                                   |
 |              Added check for from/to null values.                        |
 |   Updated    Joe DiIorio  - 10/22/2004                                   |
 |              Added x_sequence to capture transaction manager header id.  |
 |   Updated    Joe DiIorio  - 11/12/2004                                   |
 !              removed do check for now. 4005057                           !
 |   Updated    Joe DiIorio  - 12/08/2004                                   |
 !              removed defaults for gscc.  Kept in header.                 !
 ============================================================================
*/

PROCEDURE log_msg(p_msg_text IN VARCHAR2);

/*  Global variables */
G_PKG_NAME     CONSTANT VARCHAR2(30):='MTL_LOT_UOM_CONV_PUB';
G_tmp	       BOOLEAN   := FND_MSG_PUB.Check_Msg_Level(0) ;  -- temp call to initialize the
						              -- msg level threshhold gobal
							      -- variable.
G_debug_level  NUMBER(2) := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
-- to decide to log a debug msg.


/*===========================================================================
--  PROCEDURE
--    create_lot_uom_conversion
--
--  DESCRIPTION:
--    This validates and creates/updates a lot uom conversions.
--
--  PARAMETERS:
--    p_api_version           IN NUMBER    - Standard api parameter
--    p_init_msg_list         IN VARCHAR2  - Standard api parameter
--    p_commit                IN VARCHAR2  - Standard api parameter
--    p_validation_level      IN NUMBER    - Standard api parameter
--    p_action_type           IN VARCHAR2  - I for insert, U for update
--    p_update_type_indicator IN VARCHAR2  - Quantity Change identifier
--                                         0 = Update onhand balances
--                                         1 = Recalculate Batch Primary Quantity
--                                         2 = Recalculate Batch Secondary Quantity
--                                         3 = Recalculate On-Hand Primary Quantity
--                                         4 = Recalculate On-Hand Secondary Quantity
--                                         5 = No Quantity Updates
--    p_reason_id             IN NUMBER    - Surrogate key for Reason Code.
--    p_batch_id              IN NUMBER    - Surrogate key for Batch number.
--    p_process_data          IN VARCHAR2
--    p_lot_uom_conv_rec      IN ROW       - Lot conversion record.
--    p_qty_update_tbl        IN           - Table of quantity changes.
--    x_return_status         OUT VARCHAR2 - 'S'uccess, 'E'rror, 'U'nexpected Error
--    x_msg_count             OUT          - Standard api parameter
--    x_msg_data              OUT          - Standard api parameter.
--    x_sequence              IN OUT       - For transaction processing.
--
--  SYNOPSIS:
--    Create/validate lot uom conversion
--
--  HISTORY
--    Joe DiIorio     01-Sept-2004  Created.
--    Joe DiIorio     14-Sept-2005  Updated for bug#4107431
--
--=========================================================================== */

PROCEDURE create_lot_uom_conversion
( p_api_version           IN               NUMBER
, p_init_msg_list         IN               VARCHAR2
, p_commit                IN               VARCHAR2
, p_validation_level      IN               NUMBER
, p_action_type           IN               VARCHAR2
, p_update_type_indicator IN               NUMBER DEFAULT 5
, p_reason_id             IN               NUMBER
, p_batch_id              IN               NUMBER
, p_process_data          IN               VARCHAR2
, p_lot_uom_conv_rec      IN OUT NOCOPY    mtl_lot_uom_class_conversions%ROWTYPE
, p_qty_update_tbl        IN OUT NOCOPY    MTL_LOT_UOM_CONV_PUB.quantity_update_rec_type
, x_return_status         OUT NOCOPY       VARCHAR2
, x_msg_count             OUT NOCOPY       NUMBER
, x_msg_data              OUT NOCOPY       VARCHAR2
, x_sequence              IN OUT NOCOPY    NUMBER)


IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'create_lot_uom_conversion';
  l_api_version        CONSTANT NUMBER         := 1.0 ;
  l_conv_seq           MTL_LOT_UOM_CLASS_CONVERSIONS.CONVERSION_ID%TYPE;
  l_aud_seq            MTL_LOT_CONV_AUDIT.CONV_AUDIT_ID%TYPE;

  l_org                INV_VALIDATE.org;
  l_item               INV_VALIDATE.item;
  l_locator            INV_VALIDATE.locator;
  l_lot                INV_VALIDATE.lot;
  l_sub                INV_VALIDATE.sub;
  l_revision           varchar2(10);
  l_ret                NUMBER;
  l_err_msg            VARCHAR2(2000);
  l_reason_id          NUMBER;
  l_update_type_indicator     VARCHAR2(1);

  l_violation          BOOLEAN;
  l_trans_count        NUMBER;

  CURSOR get_uom_code_values (p_uom_code VARCHAR2) IS
  SELECT unit_of_measure, uom_class
  FROM mtl_units_of_measure
  WHERE uom_code = p_uom_code;

  CURSOR get_unit_of_meas_values (p_unit_of_measure VARCHAR2) IS
  SELECT uom_code, uom_class
  FROM mtl_units_of_measure
  WHERE unit_of_measure = p_unit_of_measure;

  CURSOR get_uom_class_values (p_uom_class VARCHAR2) IS
  SELECT unit_of_measure, uom_code
  FROM mtl_units_of_measure
  WHERE uom_class = p_uom_class and base_uom_flag = 'Y';

  l_from_uom_code          mtl_units_of_measure.uom_code%TYPE;
  l_from_unit_of_measure   mtl_units_of_measure.unit_of_measure%TYPE;
  l_from_uom_class         mtl_units_of_measure.uom_class%TYPE;
  l_to_uom_code            mtl_units_of_measure.uom_code%TYPE;
  l_to_unit_of_measure     mtl_units_of_measure.unit_of_measure%TYPE;
  l_to_uom_class           mtl_units_of_measure.uom_class%TYPE;


  l_return_status        VARCHAR2(2);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
  l_tran_seq             NUMBER;

  DO_CHECK_ERROR         EXCEPTION;

/*=======================================
   Joe DiIorio 01/13/2005 BUG#4107431
  =======================================*/


l_from_base_uom_code          MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
l_from_base_unit_of_measure   MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE;
l_to_base_uom_code            MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
l_to_base_unit_of_measure     MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE;


/*======================================
    Cursor to get base values for a
    given uom class.
  ======================================*/

CURSOR get_base_values (l_uom_class VARCHAR2) IS
SELECT unit_of_measure, uom_code
FROM mtl_units_of_measure
WHERE uom_class = l_uom_class and base_uom_flag = 'Y';


l_factor                      NUMBER;


/*======================================
    Cursor to get primary uom code for
    and item.
  ======================================*/

  CURSOR get_item_uom IS
  SELECT primary_uom_code
  FROM mtl_system_items
  WHERE organization_id = p_lot_uom_conv_rec.organization_id
  AND   inventory_item_id = p_lot_uom_conv_rec.inventory_item_id;

l_item_uom_code            MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE%TYPE;


/*======================================
    Cursor to get uom_class for a given
    uom code.
  ======================================*/

  CURSOR get_item_uom_class IS
  SELECT uom_class
  FROM   mtl_units_of_measure
  WHERE  uom_code = l_item_uom_code;


l_item_uom_class           MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE;


l_from_rate                NUMBER;


/*=======================================
   Joe DiIorio 01/13/2005 BUG#4107431
  =======================================*/

BEGIN


  l_tran_seq := x_sequence;

  SAVEPOINT LOT_UOM_CONVERSION;

  l_update_type_indicator := p_update_type_indicator;
  /*================================
     Initialize Message List Logic
    ================================*/
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  /*==================================================
     Standard call to check for call compatibility.
   *==================================================*/
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  /*===============================
       Validate Action Type
    ==============================*/

  IF (p_action_type <> 'I' AND p_action_type <> 'U') THEN
      FND_MESSAGE.SET_NAME('INV','INV_LOTC_ACTIONTYPE_INVALID');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_update_type_indicator := p_update_type_indicator;
  IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL) THEN
     /*===============================
          Validate Organization
       ==============================*/
     l_org.organization_id := p_lot_uom_conv_rec.organization_id;
     l_ret := INV_VALIDATE.organization(l_org);
     IF (l_ret = INV_VALIDATE.F) THEN
         FND_MESSAGE.SET_NAME('INV','INV_LOTC_ORG_INVALID');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     /*===============================
          Validate Item
       ==============================*/
     l_item.inventory_item_id := p_lot_uom_conv_rec.inventory_item_id;
     l_item.organization_id := p_lot_uom_conv_rec.organization_id;

     l_ret := INV_VALIDATE.inventory_item(l_item, l_org);
     IF (l_ret = INV_VALIDATE.F) THEN
         FND_MESSAGE.SET_NAME('INV','INV_LOTC_ITEM_INVALID');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     /*===============================
          Validate Lot
       ==============================*/
     l_lot.inventory_item_id := p_lot_uom_conv_rec.inventory_item_id;
     l_lot.organization_id := p_lot_uom_conv_rec.organization_id;
     l_lot.lot_number := p_lot_uom_conv_rec.lot_number;
     l_ret := INV_VALIDATE.lot_number(l_lot, l_org, l_item);
     IF (l_ret = INV_VALIDATE.F) THEN
         FND_MESSAGE.SET_NAME('INV','INV_LOTC_LOT_INVALID');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


     /*===============================
       Fill in missing uom values.
       ==============================*/

   l_from_uom_code := p_lot_uom_conv_rec.from_uom_code;
   l_from_unit_of_measure := p_lot_uom_conv_rec.from_unit_of_measure;
   l_from_uom_class := p_lot_uom_conv_rec.from_uom_class;
   l_to_uom_code := p_lot_uom_conv_rec.to_uom_code;
   l_to_unit_of_measure := p_lot_uom_conv_rec.to_unit_of_measure;
   l_to_uom_class := p_lot_uom_conv_rec.to_uom_class;

   IF ( l_from_uom_code IS NULL AND
        l_from_unit_of_measure IS NULL AND
        l_from_uom_class IS NULL ) THEN
     FND_MESSAGE.SET_NAME('INV','INV_LOTC_SOURCE_UOM_REQD');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF ( l_to_uom_code IS NULL AND
        l_to_unit_of_measure IS NULL AND
        l_to_uom_class IS NULL) THEN
     FND_MESSAGE.SET_NAME('INV','INV_LOTC_TARGET_UOM_REQD');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;



   IF ( l_from_uom_code IS NULL OR
        l_from_unit_of_measure IS NULL OR
        l_from_uom_class IS NULL ) THEN

     IF ( l_from_uom_code IS NOT NULL) THEN
        OPEN get_uom_code_values(l_from_uom_code);
        FETCH get_uom_code_values INTO l_from_unit_of_measure,l_from_uom_class;
        IF (get_uom_code_values%NOTFOUND) THEN
           CLOSE get_uom_code_values;
           FND_MESSAGE.SET_NAME('INV','INV_GET_UOM_ERR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE get_uom_code_values;

     ELSIF ( l_from_unit_of_measure IS NOT NULL) THEN
        OPEN get_unit_of_meas_values(l_from_unit_of_measure);
        FETCH get_unit_of_meas_values INTO l_from_uom_code,l_from_uom_class;
        IF (get_unit_of_meas_values%NOTFOUND) THEN
           CLOSE get_unit_of_meas_values;
           FND_MESSAGE.SET_NAME('INV','INV_GET_UNITOFMEASURE_ERR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE get_unit_of_meas_values;

     ELSIF ( l_from_uom_class IS NOT NULL) THEN
        OPEN get_uom_class_values(l_from_uom_class);
        FETCH get_uom_class_values INTO l_from_unit_of_measure,l_from_uom_code;
        IF (get_uom_class_values%NOTFOUND) THEN
           CLOSE get_uom_class_values;
           FND_MESSAGE.SET_NAME('INV','INV_GET_UOM_CLASS_ERR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE get_uom_class_values;

     END IF; /* Which value if not NULL */

   END IF; /* If missing at least one of the FROM values */

   IF ( l_to_uom_code IS NULL OR
        l_to_unit_of_measure IS NULL OR
        l_to_uom_class IS NULL) THEN

     IF ( l_to_uom_code IS NOT NULL) THEN
        OPEN get_uom_code_values(l_to_uom_code);
        FETCH get_uom_code_values INTO l_to_unit_of_measure,l_to_uom_class;
        IF (get_uom_code_values%NOTFOUND) THEN
           CLOSE get_uom_code_values;
           FND_MESSAGE.SET_NAME('INV','INV_GET_UOM_ERR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE get_uom_code_values;

     ELSIF ( l_to_unit_of_measure IS NOT NULL) THEN
        OPEN get_unit_of_meas_values(l_to_unit_of_measure);
        FETCH get_unit_of_meas_values INTO l_to_uom_code,l_to_uom_class;
        IF (get_unit_of_meas_values%NOTFOUND) THEN
           CLOSE get_unit_of_meas_values;
           FND_MESSAGE.SET_NAME('INV','INV_GET_UNITOFMEASURE_ERR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE get_unit_of_meas_values;

     ELSIF ( l_to_uom_class IS NOT NULL) THEN
        OPEN get_uom_class_values(l_to_uom_class);
        FETCH get_uom_class_values INTO l_to_unit_of_measure,l_to_uom_code;
        IF (get_uom_class_values%NOTFOUND) THEN
           CLOSE get_uom_class_values;
           FND_MESSAGE.SET_NAME('INV','INV_GET_UOM_CLASS_ERR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE get_uom_class_values;

     END IF; /* Which value if not NULL */

   END IF; /* If missing at least one of the TO values */



  /*======================================
     Start of 41074312 changes.
    ======================================*/

  /*==========================================
     Make sure the From uom class is the same
     as the items base uom class.  First get
     the item uom code and then get the
     codes class.
    ==========================================*/

   OPEN get_item_uom;
   FETCH get_item_uom INTO l_item_uom_code;
   IF (get_item_uom%NOTFOUND) THEN
       FND_MESSAGE.SET_NAME('INV','INV_ITEMUOM');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE get_item_uom;

  /*==========================================
     Get base class for the item's uom.
    ==========================================*/

   OPEN get_item_uom_class;
   FETCH get_item_uom_class INTO l_item_uom_class;
   IF (get_item_uom_class%NOTFOUND) THEN
       FND_MESSAGE.SET_NAME('INV','INV_ITEMUOM_CLASS');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE get_item_uom_class;

  /*==========================================
     Check if from uom class matches items
     uom class.
    ==========================================*/


   IF (l_item_uom_class <> l_from_uom_class) THEN
       FND_MESSAGE.SET_NAME('INV','INV_CLASSMISMATCH');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


  /*==========================================
     Get base values for the Input From class.
    ==========================================*/

   OPEN get_base_values(l_from_uom_class);
   FETCH get_base_values INTO l_from_base_unit_of_measure, l_from_base_uom_code;
   IF (get_base_values%NOTFOUND) THEN
       FND_MESSAGE.SET_NAME('INV','INV_FROMBASE_ERROR');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE get_base_values;


  /*==========================================
     If base uom code is what was entered it
     is ok.  Otherwise convert to the base.
    ==========================================*/

   IF (l_from_base_uom_code <> l_from_uom_code) THEN

      l_from_rate := inv_convert.INV_UM_CONVERT(
           ITEM_ID          => p_lot_uom_conv_rec.inventory_item_id,
           LOT_NUMBER       => p_lot_uom_conv_rec.lot_number,
           ORGANIZATION_ID  => p_lot_uom_conv_rec.organization_id,
           PRECISION        => 38,
           FROM_QUANTITY    => p_lot_uom_conv_rec.conversion_rate,
           FROM_UNIT        => l_from_uom_code,
           TO_UNIT          => l_from_base_uom_code,
           FROM_NAME        => l_from_unit_of_measure,
           TO_NAME          => l_from_base_unit_of_measure
           );



       IF (l_ret = -99999) THEN
           FND_MESSAGE.SET_NAME('INV','INV_FROMBASE_CONV_ERROR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSE
          p_lot_uom_conv_rec.conversion_rate := l_from_rate;
          l_from_uom_code := l_from_base_uom_code;
          l_from_unit_of_measure := l_from_base_unit_of_measure;
       END IF;
   END IF;

  /*==========================================
     Get base value for To Uom class.
    ==========================================*/


   OPEN get_base_values(l_to_uom_class);
   FETCH get_base_values INTO l_to_base_unit_of_measure, l_to_base_uom_code;
   IF (get_base_values%NOTFOUND) THEN
       FND_MESSAGE.SET_NAME('INV','INV_TOBASE_ERROR');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE get_base_values;


  /*==========================================
     If base uom code is what was entered it
     is ok.  Otherwise convert to the base.
    ==========================================*/


   IF (l_to_base_uom_code <> l_to_uom_code) THEN


      l_factor := inv_convert.INV_UM_CONVERT(
           ITEM_ID          => p_lot_uom_conv_rec.inventory_item_id,
           LOT_NUMBER       => p_lot_uom_conv_rec.lot_number,
           ORGANIZATION_ID  => p_lot_uom_conv_rec.organization_id,
           PRECISION        => 38,
           FROM_QUANTITY    => 1,
           FROM_UNIT        => l_to_uom_code,
           TO_UNIT          => l_to_base_uom_code,
           FROM_NAME        => l_to_unit_of_measure,
           TO_NAME          => l_to_base_unit_of_measure
           );

       IF (l_ret = -99999) THEN
          FND_MESSAGE.SET_NAME('INV','INV_TOBASE_CONV_ERROR');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSE
          p_lot_uom_conv_rec.conversion_rate :=  p_lot_uom_conv_rec.conversion_rate/l_factor;
          l_to_uom_code :=  l_to_base_uom_code;
          l_to_unit_of_measure :=  l_to_base_unit_of_measure;
       END IF;
   END IF;



  /*==================================
        End BUG#4107431.
    ==================================*/


   p_lot_uom_conv_rec.from_uom_code := l_from_uom_code;
   p_lot_uom_conv_rec.from_unit_of_measure := l_from_unit_of_measure;
   p_lot_uom_conv_rec.from_uom_class := l_from_uom_class;

   p_lot_uom_conv_rec.to_uom_code := l_to_uom_code;
   p_lot_uom_conv_rec.to_unit_of_measure := l_to_unit_of_measure;
   p_lot_uom_conv_rec.to_uom_class := l_to_uom_class;



     /*===============================
          Validate Conversion Rate
       -- it is changed and is numeric
       -- and is greater than zero.
       ==============================*/
     IF (p_lot_uom_conv_rec.conversion_rate <= 0 OR
         p_lot_uom_conv_rec.conversion_rate IS NULL) THEN
         FND_MESSAGE.SET_NAME('INV','INV_LOTC_CONVRATE_INVALID');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     /*===============================
          Validate Disable Date
       Check for proper format.
       ==============================*/
     IF (p_lot_uom_conv_rec.disable_date IS NOT NULL) THEN
        --- check for formatting.
        -- check for disable date passed and update types
        -- should be suppressed.
        NULL;
     END IF;


     /*===============================
       Validate Event Spec.
       check qc tables.
       ==============================*/

     /*===============================
       Validate Reason Code.
       ==============================*/

     l_ret := G_TRUE;
     IF (p_reason_id IS NOT NULL) THEN
        l_reason_id := p_reason_id;
        l_ret := INV_VALIDATE.reason(l_reason_id);
        IF (l_ret = INV_VALIDATE.F) THEN
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;


     /*===============================
       Validate Update Type Indicator
       check against lookup table.
       ==============================*/

     l_ret := mtl_lot_uom_conv_pvt.validate_update_type(
                    l_update_type_indicator);
     IF (l_ret = G_FALSE) THEN
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     /*===============================
       Validate WHO.
       Must figure out how to do this.
       Check fnd_user. if value entered
       else get default, if none exists
       then error.  populate last on U
       both create and upd on I.
       ==============================*/
  END IF;  -- end validation level


  /*=============================================
     Call Business Rules
    ===========================================*/

   l_tran_seq := x_sequence;

   l_ret := MTL_LOT_UOM_CONV_PVT.validate_lot_conversion_rules
   ( p_organization_id => p_lot_uom_conv_rec.organization_id
   , p_inventory_item_id => p_lot_uom_conv_rec.inventory_item_id
   , p_lot_number => p_lot_uom_conv_rec.lot_number
   , p_from_uom_code  => p_lot_uom_conv_rec.from_uom_code
   , p_to_uom_code  => p_lot_uom_conv_rec.to_uom_code
   , p_quantity_updates => l_update_type_indicator
   , p_update_type => p_action_type
   , p_header_id => l_tran_seq
   );



   IF (l_ret = 0) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  /*================================================
     Only update database if process_data flag set.
    ================================================*/


  IF (p_process_data = 'Y') THEN
     /*=============================================
        Insert Row to mtl_lot_uom_class_conversions.
        Perform all database updates.
       ===========================================*/

      l_tran_seq := x_sequence;

      MTL_LOT_UOM_CONV_PVT.process_conversion_data
      ( p_action_type => p_action_type
      , p_update_type_indicator => l_update_type_indicator
      , p_reason_id => p_reason_id
      , p_batch_id => p_batch_id
      , p_lot_uom_conv_rec => p_lot_uom_conv_rec
      , p_qty_update_tbl => p_qty_update_tbl
      , x_return_status  => l_return_status
      , x_msg_count      => l_msg_count
      , x_msg_data       => l_msg_data
      , x_sequence       => l_tran_seq
      );

     x_sequence := l_tran_seq;

     --Bug#5453231 changed x_return_status to l_return_status
     IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


     FND_MSG_PUB.Count_AND_GET
         (p_count => x_msg_count, p_data  => x_msg_data);

  END IF;    -- process data check



  /*===============================
      Process Transactions
    ===============================*/

  l_tran_seq := x_sequence;


  IF (x_sequence IS NOT NULL) THEN
     l_ret := INV_TXN_MANAGER_PUB.PROCESS_TRANSACTIONS(
      p_api_version => 1.0,
      p_init_msg_list => FND_API.G_TRUE,
      p_commit => FND_API.G_FALSE,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      x_trans_count => l_trans_count,
      p_table => 2,
      p_header_id => l_tran_seq);

-- old code 1 returned  IF (l_ret = G_FALSE) THEN
-- g_false = 0 inconsistent behaviour between l_ret and l_return_status

     IF (l_ret <> 0) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
     COMMIT;
  END IF;

EXCEPTION

  WHEN DO_CHECK_ERROR THEN
    ROLLBACK TO SAVEPOINT LOT_UOM_CONVERSION;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO SAVEPOINT LOT_UOM_CONVERSION;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO SAVEPOINT LOT_UOM_CONVERSION;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO SAVEPOINT LOT_UOM_CONVERSION;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END create_lot_uom_conversion;


PROCEDURE log_msg(p_msg_text IN VARCHAR2) IS
BEGIN

    FND_MESSAGE.SET_NAME('GMI','GMI_DEBUG_API');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;

END log_msg ;

END MTL_LOT_UOM_CONV_PUB;

/
