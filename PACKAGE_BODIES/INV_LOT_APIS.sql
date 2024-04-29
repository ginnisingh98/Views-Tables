--------------------------------------------------------
--  DDL for Package Body INV_LOT_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOT_APIS" AS
/* $Header: INVLOTAB.pls 120.5.12010000.2 2009/04/10 07:34:04 pbonthu ship $ */


--  Global constant holding the package name
    g_pkg_name   CONSTANT VARCHAR2 ( 30 ) := 'INV_LOT_APIS';


    PROCEDURE print_debug ( p_err_msg VARCHAR2, p_level NUMBER DEFAULT 1)
    IS
    l_debug number := 1;--NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN
        IF (g_debug = 1) THEN
           inv_mobile_helper_functions.tracelog (
             p_err_msg => p_err_msg,
            p_module => 'INV_LOT_APIS',
            p_level => p_level
         );
        --DBMS_OUTPUT.PUT_LINE(p_err_msg);
        END IF;
        --DBMS_OUTPUT.PUT_LINE(p_err_msg);
        END print_debug;

    PROCEDURE EXPIRATION_ACTION_CODE( x_codes OUT NOCOPY t_genref,
                                      p_code  IN VARCHAR2) IS
    BEGIN
       If p_code IS NOT NULL
       THEN
       OPEN x_codes for
       SELECT  action_code, Description
       FROM    mtl_actions
       WHERE   NVL(disable_flag,'N') = 'N'
       AND     action_code like (p_code);
       Else
       OPEN x_codes for
       SELECT  action_code, Description
       FROM    mtl_actions
       WHERE   NVL(disable_flag,'N') = 'N';
       END IF;

     END expiration_action_code;


    PROCEDURE GET_YES_NO( x_option OUT NOCOPY t_genref) IS
    BEGIN
    OPEN x_option for
    SELECT 'YES' FROM DUAL
    UNION
    SELECT 'NO' FROM DUAL;
    END get_yes_no;

    PROCEDURE GET_YES_NO( x_option OUT NOCOPY t_genref
                         , p_option IN VARCHAR2) IS
    BEGIN
    OPEN x_option for
    SELECT 'YES' FROM DUAL WHERE 'YES' LIKE upper(p_option)
    UNION
    SELECT 'NO' FROM DUAL WHERE 'NO' LIKE upper(p_option);
    END get_yes_no;


    PROCEDURE get_grade_codes (   x_grades     OUT NOCOPY t_genref
                                , p_grade_code IN VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN

        IF (l_debug = 1) THEN
           inv_pick_wave_pick_confirm_pub.tracelog ( 'Inside get_grace_codes API' , 'INV_PROCESS_LOT_API');
        END IF;
       If p_grade_code IS NOT NULL THEN
       OPEN x_grades FOR
           SELECT   grade_code
                  , description
           FROM   mtl_grades
           WHERE  grade_code   LIKE (p_grade_code)
           AND    disable_flag <>   'Y';
       ELSE
       OPEN x_grades FOR
           SELECT   grade_code
                  , description
           FROM   mtl_grades
           WHERE  disable_flag <>   'Y';
       End IF;

    END get_grade_codes;

    PROCEDURE get_named_attributes (  x_lot_att             OUT nocopy t_genref   --- get_opm_lot_attributes
                                      , p_inventory_item_id   IN   NUMBER
                                      , p_organization_id     IN   NUMBER
                                      , p_lot_number          IN   VARCHAR2
                                      , p_parent_lot_number   IN   VARCHAR2) IS
   /**
    * A new api has been written to populate the lot attributes given a lot, item and parent lot.
    * The API details can be found in the Create Lot Api TDD. Since there is no direct way to return
    * plsql tables back to the java client, this procedure is meant to act as a wrapper over
    * populate_lot_attributes, which returns the attributes in a plsql table.
    * These attributes are selected from dual and passed back as a ref cursor to the client.
    **/
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN

        IF (l_debug = 1) THEN
           inv_pick_wave_pick_confirm_pub.tracelog ( 'Inside get_opm_lot_attributes API' , 'INV_LOT_APIS');
        END IF;

If nvl(p_parent_lot_number, ' ') = ' ' THEN
        OPEN x_lot_att for
           SELECT
         ---- Added for Bug #3952081 + #4093379
                 nvl(mln.parent_lot_number,'')                          parent_lot_number
               , nvl(mln.grade_code,'')                             grade_code
               , nvl(mln.origination_type,'')                                   origination_type
               , nvl(TO_CHAR(mln.origination_date,'YYYY-MM-DD'),'')             origination_date --YYYY-MM-DD
               , nvl(TO_CHAR(mln.expiration_action_date,'YYYY-MM-DD'),'')       expiration_action_date
               , nvl(mln.expiration_action_code,'')                             expiration_action_code
               , nvl(TO_CHAR(mln.retest_date,'YYYY-MM-DD'),'')                  retest_date
               , nvl(TO_CHAR(mln.hold_date,'YYYY-MM-DD'),'')                    hold_date
               , nvl(TO_CHAR(mln.maturity_date,'YYYY-MM-DD'),'')                maturity_date
               , nvl(mln.supplier_lot_number,'')                                supplier_lot_number
           FROM   mtl_lot_numbers mln
           WHERE  inventory_item_id = p_inventory_item_id
           AND    organization_id   = p_organization_id
           AND    lot_number        = p_lot_number;

ELSE
        OPEN x_lot_att for
           SELECT
         ---- Added for Bug #3952081 + #4093379
                 nvl(mln.parent_lot_number,'')                          parent_lot_number
               , nvl(mln.grade_code,'')                             grade_code
               , nvl(mln.origination_type,'')                                   origination_type
               , nvl(TO_CHAR(mln.origination_date,'YYYY-MM-DD'),'')             origination_date --YYYY-MM-DD
               , nvl(TO_CHAR(mln.expiration_action_date,'YYYY-MM-DD'),'')       expiration_action_date
               , nvl(mln.expiration_action_code,'')                             expiration_action_code
               , nvl(TO_CHAR(mln.retest_date,'YYYY-MM-DD'),'')                  retest_date
               , nvl(TO_CHAR(mln.hold_date,'YYYY-MM-DD'),'')                    hold_date
               , nvl(TO_CHAR(mln.maturity_date,'YYYY-MM-DD'),'')                maturity_date
               , nvl(mln.supplier_lot_number,'')                                supplier_lot_number
           FROM   mtl_lot_numbers mln
           WHERE  inventory_item_id = p_inventory_item_id
           AND    organization_id   = p_organization_id
           AND    lot_number        = p_lot_number
           AND    nvl(parent_lot_number,' ') = nvl(p_parent_lot_number, ' ');

END IF;


    END get_named_attributes;


    PROCEDURE get_opm_item_attributes(  x_item_lot_att              OUT nocopy t_genref
                                      , p_inventory_item_id         IN       NUMBER
                                      , p_organization_id           IN       NUMBER )  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN

        IF (l_debug = 1) THEN
           inv_pick_wave_pick_confirm_pub.tracelog ( 'Inside get_opm_item_attributes API' , 'INV_PROCESS_LOT_API');
        END IF;

        open x_item_lot_att for
        SELECT    tracking_quantity_ind
                , secondary_default_ind
                , secondary_uom_code
                , dual_uom_deviation_high
                , dual_uom_deviation_low
                , grade_control_flag
                , default_grade
                , child_lot_flag
                , retest_interval
                , expiration_action_interval
                , expiration_action_code
                , maturity_days
                , hold_days
                , copy_lot_attribute_flag
        FROM   mtl_system_items
        WHERE  inventory_item_id = p_inventory_item_id
        AND    organization_id   = p_organization_id;

        END get_opm_item_attributes;

PROCEDURE check_reservations(p_inventory_item_id    IN       NUMBER
                            , p_organization_id   IN       NUMBER
                            , p_lot_number        IN       VARCHAR2
                            , p_exists            OUT  NOCOPY VARCHAR2    )
IS

l_dummy  NUMBER := 0;

BEGIN

SELECT 1
INTO   l_dummy
FROM   MTL_RESERVATIONS
WHERE  inventory_item_id  = p_inventory_item_id
AND    organization_id    = p_organization_id
AND    lot_number         = p_lot_number;

p_exists  := 'TRUE';
EXCEPTION WHEN NO_DATA_FOUND THEN
               p_exists :=  'FALSE';
                WHEN TOO_MANY_ROWS THEN
                     p_exists :=  'TRUE';
END;

PROCEDURE validate_grade_code(  p_grade_code                                    IN              VARCHAR
                                  , p_org_id                    IN      NUMBER
                                                                              , p_inventory_item_id         IN      NUMBER
                                                                              , p_grade_control_flag        IN      VARCHAR2
                                , x_return_status                       OUT NOCOPY VARCHAR2
                                , x_msg_count                                   OUT NOCOPY NUMBER
                                , x_msg_data                                      OUT NOCOPY VARCHAR2
                                , x_valid                     OUT NOCOPY VARCHAR2)
IS
IsVALID BOOLEAN := false;
BEGIN
        ISVALID := INV_LOT_ATTR_PUB.validate_grade_code(
p_grade_code
, p_org_id
, p_inventory_item_id
, p_grade_control_flag
, x_return_status
, x_msg_count
, x_msg_data );

IF ISVALID = TRUE THEN
   x_valid := 'TRUE';
ELSE
   x_valid := 'FALSE';
END IF;

END;

PROCEDURE validate_exp_action_code(     p_expiration_action_code                                IN              VARCHAR
                                    , p_org_id                    IN      NUMBER
                                                                                , p_inventory_item_id         IN      NUMBER
                                                                                , p_shelf_life_code           IN      VARCHAR2
                                  , x_return_status                     OUT NOCOPY VARCHAR2
                                  , x_msg_count                                 OUT NOCOPY NUMBER
                                  , x_msg_data                                          OUT NOCOPY VARCHAR2
                                  , x_valid               OUT NOCOPY VARCHAR2)
IS
IsVALID BOOLEAN := false;
BEGIN
        ISVALID := INV_LOT_ATTR_PUB.validate_exp_action_code(
 p_expiration_action_code
, p_org_id
, p_inventory_item_id
, p_shelf_life_code
, x_return_status
, x_msg_count
, x_msg_data );

IF ISVALID = TRUE THEN
   x_valid := 'TRUE';
ELSE
   x_valid := 'FALSE';
END IF;

END;

PROCEDURE validate_exp_action_date(
  p_expiration_action_date              IN              DATE
, p_expiration_date             IN      DATE
, x_return_status                           OUT NOCOPY VARCHAR2
, x_msg_count                                 OUT NOCOPY NUMBER
, x_msg_data                                    OUT NOCOPY VARCHAR2
, x_valid                   OUT NOCOPY VARCHAR2)
IS
IsVALID BOOLEAN := false;
BEGIN
        ISVALID := INV_LOT_ATTR_PUB.validate_exp_action_date(
  p_expiration_action_date
, p_expiration_date
, x_return_status
, x_msg_count
, x_msg_data                                    );
IF ISVALID = TRUE THEN
   x_valid := 'TRUE';
ELSE
   x_valid := 'FALSE';
END IF;

END;

PROCEDURE validate_hold_date(
  p_hold_date                           IN              DATE
, p_origination_date            IN      DATE
, x_return_status                           OUT NOCOPY VARCHAR2
, x_msg_count                               OUT NOCOPY NUMBER
, x_msg_data                                OUT NOCOPY VARCHAR2
, x_valid                                   OUT NOCOPY VARCHAR2)
IS
IsVALID BOOLEAN := false;
BEGIN
        ISVALID := INV_LOT_ATTR_PUB.validate_hold_date(
  p_hold_date
, p_origination_date
, x_return_status
, x_msg_count
, x_msg_data                                );

IF ISVALID = TRUE THEN
   x_valid := 'TRUE';
ELSE
   x_valid := 'FALSE';
END IF;

END;


PROCEDURE validate_retest_date(
  p_retest_date                                 IN              DATE
, p_origination_date            IN      DATE
, x_return_status                           OUT NOCOPY VARCHAR2
, x_msg_count                               OUT NOCOPY NUMBER
, x_msg_data                                OUT NOCOPY VARCHAR2
, x_valid                                   OUT NOCOPY VARCHAR2)
IS
IsVALID BOOLEAN := false;
BEGIN
        ISVALID := INV_LOT_ATTR_PUB.validate_retest_date(
  p_retest_date
, p_origination_date
, x_return_status
, x_msg_count
, x_msg_data );

IF ISVALID = TRUE THEN
   x_valid := 'TRUE';
ELSE
   x_valid := 'FALSE';
END IF;

END;


PROCEDURE validate_maturity_date(
  p_maturity_date                               IN              DATE
, p_origination_date            IN      DATE
, x_return_status                           OUT NOCOPY VARCHAR2
, x_msg_count                               OUT NOCOPY NUMBER
, x_msg_data                                OUT NOCOPY VARCHAR2
, x_valid                                   OUT NOCOPY VARCHAR2)
IS
IsVALID BOOLEAN := false;
BEGIN
ISVALID := INV_LOT_ATTR_PUB.validate_maturity_date(
 p_maturity_date    ,
 p_origination_date ,
 x_return_status    ,
 x_msg_count         ,
 x_msg_data     );
IF ISVALID = TRUE THEN
   x_valid := 'TRUE';
ELSE
   x_valid := 'FALSE';
END IF;

END;


 PROCEDURE  GET_COPY_LOT_ATTR_FLAG(        x_return_status           OUT   NOCOPY VARCHAR2
                   , x_msg_count               OUT   NOCOPY NUMBER
                   , x_msg_data                OUT   NOCOPY VARCHAR2
                   , x_copy_lot_attr_flag      OUT   NOCOPY VARCHAR2
                   , p_organization_id         IN    NUMBER
                   , p_inventory_item_id       IN    NUMBER
                               )
IS
  /* Cursor definition to check if Lot UOM Conversion is needed */
  CURSOR  c_lot_uom_conv (cp_organization_id NUMBER) IS
  SELECT  copy_lot_attribute_flag,
          lot_number_generation
    FROM  mtl_parameters
   WHERE  organization_id = cp_organization_id;

  l_lot_uom_conv c_lot_uom_conv%ROWTYPE ;
  l_copy_lot_attribute_flag Varchar2(10);

 BEGIN
          /* Check needed for  Lot UOM conversion */
      OPEN   c_lot_uom_conv (p_organization_id) ;
      FETCH  c_lot_uom_conv INTO l_lot_uom_conv ;

      IF  c_lot_uom_conv%FOUND THEN
          --       Possible values for mtl_parameters.lot_number_generation are:
          --      1  At organization level
          --   3  User defined
          --      2  At item level

         IF  l_lot_uom_conv.lot_number_generation = 1 THEN
            l_copy_lot_attribute_flag := NVL(l_lot_uom_conv.copy_lot_attribute_flag,'N') ;

         ELSIF  l_lot_uom_conv.lot_number_generation IN (2,3) THEN
            SELECT copy_lot_attribute_flag INTO l_copy_lot_attribute_flag
            FROM mtl_system_items
            WHERE inventory_item_id = p_inventory_item_id
            AND   organization_id   = p_organization_id;
         END IF;
       ELSIF c_lot_uom_conv%FOUND THEN
            SELECT copy_lot_attribute_flag INTO l_copy_lot_attribute_flag
            FROM mtl_system_items
            WHERE inventory_item_id = p_inventory_item_id
            AND   organization_id   = p_organization_id;

      END IF ;
      CLOSE c_lot_uom_conv ;
       x_copy_lot_attr_flag := l_copy_lot_attribute_flag ;

  END ;


 -- Procedure to Set Attributes of new Lot


PROCEDURE get_grade_codes(
    x_grade_codes           OUT    NOCOPY t_genref
     ) IS
BEGIN
        OPEN x_grade_codes FOR
        SELECT
        GRADE_CODE     , DESCRIPTION
        FROM MTL_GRADES;
END;

 PROCEDURE get_parent_lot_attributes (  x_lot_att             OUT nocopy t_genref
                                      , p_inventory_item_id   IN   NUMBER
                                      , p_organization_id     IN   NUMBER
                                      , p_lot_number          IN   VARCHAR2
                                     ) IS
   /**
    * This API populates the lot attributes for a new Lot based on attributes of its parent lot.
    * These attributes are selected from dual and passed back as a ref cursor to the client.
    **/
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN

        IF (l_debug = 1) THEN
           inv_pick_wave_pick_confirm_pub.tracelog ( 'Inside get_opm_lot_attributes API' , 'INV_LOT_APIS');
        END IF;

        OPEN x_lot_att for
           SELECT
                 nvl(mln.grade_code,'')                                         grade_code
               , nvl(mln.origination_type,'')                                   origination_type
               , nvl(TO_CHAR(mln.origination_date,'YYYY-MM-DD'),'')             origination_date --YYYY-MM-DD
               , nvl(mln.expiration_action_code,'')                             expiration_action_code
               , nvl(TO_CHAR(mln.expiration_action_date,'YYYY-MM-DD'),'')       expiration_action_date
               , nvl(TO_CHAR(mln.retest_date,'YYYY-MM-DD'),'')                  retest_date
               , nvl(TO_CHAR(mln.hold_date,'YYYY-MM-DD'),'')                    hold_date
               , nvl(TO_CHAR(mln.maturity_date,'YYYY-MM-DD'),'')                maturity_date
               , nvl(mln.supplier_lot_number,'')                                supplier_lot_number
-- nsinghi bug#5209065 rework. Fetch exp date also, to default it.
               , nvl(TO_CHAR(mln.expiration_date,'YYYY-MM-DD'),'')              expiration_date
           FROM   mtl_lot_numbers mln
           WHERE  inventory_item_id = p_inventory_item_id
           AND    organization_id   = p_organization_id
           AND    lot_number        = p_lot_number;

END get_parent_lot_attributes;

 PROCEDURE Set_Msi_Default_Attr(  x_lot_att           OUT    NOCOPY t_genref
                                 , p_organization_id   IN     NUMBER
                                 , p_inventory_item_id IN     NUMBER
				 , p_lot_number	       IN     VARCHAR2 DEFAULT NULL -- nsinghi bug#5209065 rework. Added this param.
 ) IS

  CURSOR  c_get_dft_attr ( cp_inventory_item_id NUMBER, cp_organization_id NUMBER ) IS
  SELECT  grade_control_flag
          , default_grade
          , shelf_life_code
          , shelf_life_days
          , expiration_action_code
          , expiration_action_interval
          , retest_interval
          , maturity_days
          , hold_days
   FROM   mtl_system_items_b
   WHERE  organization_id   = cp_organization_id
   AND    inventory_item_id = cp_inventory_item_id;

   -- nsinghi bug#5209065 rework START. If existing lot,
   -- fetch the lot attributes and assign those, otherwise default from item.
   CURSOR  c_get_lot_attr ( cp_inventory_item_id NUMBER, cp_organization_id NUMBER, cp_lot_number VARCHAR2 ) IS
   SELECT  grade_code
           , expiration_date
           , expiration_action_code
           , expiration_action_date
	   , origination_date
           , retest_date
           , maturity_date
           , hold_date
    FROM   mtl_lot_numbers
    WHERE  organization_id   = cp_organization_id
    AND    inventory_item_id = cp_inventory_item_id
    AND    lot_number = cp_lot_number;

    l_get_lot_attr_rec c_get_lot_attr%ROWTYPE;
    l_new_lot BOOLEAN;
   -- nsinghi bug#5209065 rework END.

  -- nsinghi bug 5209065 START
  l_mmtt_txn_tbl          INV_CALCULATE_EXP_DATE.MMTT_TAB;
  l_mti_txn_rec           MTL_TRANSACTIONS_INTERFACE%ROWTYPE;
  l_mtli_txn_rec          MTL_TRANSACTION_LOTS_INTERFACE%ROWTYPE;
  l_mmtt_txn_rec          MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE;
  l_mtlt_txn_rec          MTL_TRANSACTION_LOTS_TEMP%ROWTYPE;
  l_lot_expiration_date   DATE;
  -- nsinghi bug 5209065 END

   l_get_dft_attr_rec c_get_dft_attr%ROWTYPE;

  l_return_status          VARCHAR2(1);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(3000);
  x_grade_code            VARCHAR2(150);
  x_exp_action_code       VARCHAR2(50) ;
  x_origination_date      DATE ;
  x_exp_action_date       DATE ;
  x_hold_date             DATE ;
  x_maturity_date         DATE ;
  x_retest_date           DATE ;
  x_expiration_date       DATE ;
BEGIN

 x_grade_code     := '';


   /*Get default information from Mtl_System_Item */
   OPEN  c_get_dft_attr(p_inventory_item_id,p_organization_id);
   FETCH c_get_dft_attr INTO l_get_dft_attr_rec;
   CLOSE c_get_dft_attr;

   /* Grade */
      IF l_get_dft_attr_rec.grade_control_flag = 'Y'  THEN
        x_grade_code := l_get_dft_attr_rec.default_grade;
      END IF;


   /* Origination Date */
      x_origination_date := SYSDATE ;

         /* Expiration Date */
      IF l_get_dft_attr_rec.shelf_life_code = 2 THEN      -- Item shelf life days

         /* nsinghi bug 5209065 START. For Receipt txn, there is no information available for
         MTLI/MTLT record. This is because, when tabbing out of Lot LOV, there is no data related
         to lot transaction. This data only gets built after user navigates through all lot fields.
         Hence only passing the MMTT record to custom lot API. */

         l_mmtt_txn_tbl := inv_calculate_exp_date.get_mmtt_tbl;
         IF l_mmtt_txn_tbl.COUNT > 0 THEN
       l_mmtt_txn_rec := l_mmtt_txn_tbl(0);
            inv_calculate_exp_date.get_lot_expiration_date(
                    p_mtli_lot_rec       => l_mtli_txn_rec
                   ,p_mti_trx_rec              => l_mti_txn_rec
                   ,p_mtlt_lot_rec       => l_mtlt_txn_rec
                   ,p_mmtt_trx_rec          => l_mmtt_txn_rec
                   ,p_table                       => 2
                   ,x_lot_expiration_date => l_lot_expiration_date
                   ,x_return_status      => l_return_status);

            inv_calculate_exp_date.purge_mmtt_tab;
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               IF g_debug = 1 THEN
                  print_debug('Program inv_calculate_exp_date.get_lot_expiration_date has failed with a Unexpected exception', 9);
               END IF;
               FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
               FND_MESSAGE.SET_TOKEN('PROG_NAME','inv_calculate_exp_date.get_lot_expiration_date');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            IF g_debug = 1 THEN
               print_debug('l_lot_expiration_date '||l_lot_expiration_date, 9);
            END IF;
            x_expiration_date := l_lot_expiration_date;
         ELSE
            x_expiration_date := x_origination_date + l_get_dft_attr_rec.shelf_life_days;
         END IF;
      -- nsinghi bug 5209065 END
      END IF;

      /* Retest Date */
       x_retest_date  := x_origination_date + l_get_dft_attr_rec.retest_interval;

       /* Hold Date */
       x_hold_date     := x_origination_date + l_get_dft_attr_rec.hold_days;

      /* Maturity Date */
      x_maturity_date := x_origination_date + l_get_dft_attr_rec.maturity_days;

      /* Shelf Life Code */
      IF NVL (l_get_dft_attr_rec.shelf_life_code, -1)  <> 1 THEN    -- No shelf life control

         /* Expiration Action Date */
           x_exp_action_date := x_expiration_date + l_get_dft_attr_rec.expiration_action_interval ;

         /* Expiration Action Code */
           x_exp_action_code := l_get_dft_attr_rec.expiration_action_code ;

      END IF; /* Shelf Life Code */

      -- nsinghi bug#5209065 rework START.
      l_new_lot := FALSE;
      OPEN  c_get_lot_attr(p_inventory_item_id,p_organization_id,p_lot_number);
      FETCH c_get_lot_attr INTO l_get_lot_attr_rec;
      IF c_get_lot_attr%NOTFOUND THEN
         l_new_lot := TRUE;
      END IF;
      CLOSE c_get_lot_attr;
      IF (NOT l_new_lot) THEN
         IF l_get_lot_attr_rec.grade_code IS NOT NULL THEN
            x_grade_code := l_get_lot_attr_rec.grade_code;
         END IF;

	 IF l_get_lot_attr_rec.expiration_date IS NOT NULL THEN
            x_expiration_date := l_get_lot_attr_rec.expiration_date;
         END IF;

         IF l_get_lot_attr_rec.expiration_action_code IS NOT NULL THEN
            x_exp_action_code := l_get_lot_attr_rec.expiration_action_code;
         END IF;

	 IF l_get_lot_attr_rec.expiration_action_date IS NOT NULL THEN
            x_exp_action_date := l_get_lot_attr_rec.expiration_action_date;
         ELSIF l_get_lot_attr_rec.expiration_date IS NOT NULL
            AND l_get_lot_attr_rec.expiration_action_date IS NULL
            AND l_get_dft_attr_rec.shelf_life_code = 2
         THEN
            x_exp_action_date := l_get_lot_attr_rec.expiration_date +
                l_get_dft_attr_rec.expiration_action_interval ;
         END IF;

         IF l_get_lot_attr_rec.origination_date IS NOT NULL THEN
            x_origination_date := l_get_lot_attr_rec.origination_date;
         END IF;

	 IF l_get_lot_attr_rec.retest_date IS NOT NULL THEN
            x_retest_date := l_get_lot_attr_rec.retest_date;
         END IF;

	 IF l_get_lot_attr_rec.maturity_date IS NOT NULL THEN
            x_maturity_date := l_get_lot_attr_rec.maturity_date;
         END IF;

	 IF l_get_lot_attr_rec.hold_date IS NOT NULL THEN
            x_hold_date := l_get_lot_attr_rec.hold_date;
         END IF;
      END IF;
      -- nsinghi bug#5209065 rework END.

        OPEN x_lot_att FOR
           SELECT
             x_grade_code,
             x_origination_date,
             x_exp_action_date,
             x_exp_action_code,
             x_hold_date,
             x_maturity_date,
             x_retest_date,
             x_expiration_date
       FROM   dual ;



 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     print_debug('In Set_Msi_Default_Attr, No data found ' || SQLERRM, 9);
   WHEN fnd_api.g_exc_error THEN
     print_debug('In Set_Msi_Default_Attr, g_exc_error ' || SQLERRM, 9);
   WHEN fnd_api.g_exc_unexpected_error THEN
     print_debug('In Set_Msi_Default_Attr, g_exc_unexpected_error ' || SQLERRM, 9);
   WHEN OTHERS THEN
     print_debug('In Set_Msi_Default_Attr, Others ' || SQLERRM, 9);

 END Set_Msi_Default_Attr ;

/*Added p_subinventory_code , p_locator_id in below procedure for Onhand status support
  Also passed p_subinventory_code,p_locator_id in
  inv_material_status_grp.is_status_applicable */
 PROCEDURE get_parent_lov(x_lot_num_lov OUT NOCOPY t_genref, p_wms_installed IN VARCHAR2, p_organization_id IN NUMBER, p_txn_type_id IN NUMBER, p_inventory_item_id IN VARCHAR2, p_lot_number IN VARCHAR2, p_project_id IN NUMBER, p_task_id IN NUMBER ,
                          p_subinventory_code IN VARCHAR2,p_locator_id IN NUMBER ) IS
    l_inventory_item_id VARCHAR2(100);
  BEGIN
    IF p_inventory_item_id IS NULL THEN
      l_inventory_item_id  := '%';
    ELSE
      l_inventory_item_id  := p_inventory_item_id;
    END IF;

    IF p_txn_type_id = inv_globals.g_type_inv_lot_split -- Lot Split (82)
                                                        THEN
      OPEN x_lot_num_lov FOR
        SELECT   mln.lot_number lot_number
               , mln.inventory_item_id
               , msik.concatenated_segments concatenated_segments
               , msik.description
               , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
               , mms.status_code status_code
               , mms.status_id
            FROM mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms
           WHERE mms.status_id = msik.default_lot_status_id -- Bug#2267947
             AND msik.default_lot_status_id IS NOT NULL -- Bug#2267947
             AND mln.organization_id = p_organization_id
             AND mln.organization_id = msik.organization_id
             AND mln.inventory_item_id = msik.inventory_item_id
             AND mln.inventory_item_id LIKE l_inventory_item_id
             AND msik.lot_split_enabled = 'Y'
             AND mln.lot_number  = p_lot_number
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled,
                                                              p_organization_id, msik.inventory_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y'
        UNION
        SELECT   mln.lot_number lot_number
               , mln.inventory_item_id
               , msik.concatenated_segments concatenated_segments
               , msik.description
               , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
               , NULL status_code
               , msik.default_lot_status_id -- Bug#2267947
            FROM mtl_lot_numbers mln, mtl_system_items_kfv msik
           WHERE msik.default_lot_status_id IS NULL -- Bug#2267947
             AND mln.organization_id = p_organization_id
             AND mln.organization_id = msik.organization_id
             AND mln.inventory_item_id = msik.inventory_item_id
             AND mln.inventory_item_id LIKE l_inventory_item_id
             AND msik.lot_split_enabled = 'Y'
             AND mln.lot_number = p_lot_number
        UNION
        SELECT   nvl(mln.parent_lot_number,mln.lot_number) lot_number
               , mln.inventory_item_id
               , msik.concatenated_segments concatenated_segments
               , msik.description
               , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
               , mms.status_code status_code
               , mms.status_id
            FROM mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms
           WHERE mms.status_id = msik.default_lot_status_id -- Bug#2267947
             AND msik.default_lot_status_id IS NOT NULL -- Bug#2267947
             AND mln.organization_id = p_organization_id
             AND mln.organization_id = msik.organization_id
             AND mln.inventory_item_id = msik.inventory_item_id
             AND mln.inventory_item_id LIKE l_inventory_item_id
             AND msik.lot_split_enabled = 'Y'
             AND mln.lot_number  = p_lot_number
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled,
                                                              p_organization_id, msik.inventory_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y'
        UNION
        SELECT   nvl(mln.parent_lot_number,mln.lot_number) lot_number
               , mln.inventory_item_id
               , msik.concatenated_segments concatenated_segments
               , msik.description
               , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
               , NULL status_code
               , msik.default_lot_status_id -- Bug#2267947
            FROM mtl_lot_numbers mln, mtl_system_items_kfv msik
           WHERE msik.default_lot_status_id IS NULL -- Bug#2267947
             AND mln.organization_id = p_organization_id
             AND mln.organization_id = msik.organization_id
             AND mln.inventory_item_id = msik.inventory_item_id
             AND mln.inventory_item_id LIKE l_inventory_item_id
             AND msik.lot_split_enabled = 'Y'
             AND mln.lot_number = p_lot_number
        ORDER BY lot_number, concatenated_segments;
    ELSE
      IF p_txn_type_id = inv_globals.g_type_inv_lot_merge -- Lot Merge 83
                                                          THEN
        IF (p_project_id IS NOT NULL) THEN
          OPEN x_lot_num_lov FOR
            SELECT DISTINCT moq.lot_number
                          , moq.inventory_item_id
                          , msik.concatenated_segments concatenated_segments
                          , msik.description
                          , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                          , mms.status_code
                          , mms.status_id
                       FROM mtl_onhand_quantities_detail moq, mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms, mtl_item_locations mil
                      WHERE moq.organization_id = p_organization_id
                        AND moq.lot_number IS NOT NULL
                        AND moq.organization_id = mil.organization_id
                        AND moq.organization_id = mln.organization_id
                        AND moq.organization_id = msik.organization_id
                        AND mil.segment19 = p_project_id
                        AND (mil.segment20 = p_task_id
                             OR (mil.segment20 IS NULL
                                 AND p_task_id IS NULL
                                )
                            )
                        AND mln.lot_number = moq.lot_number
                        AND mms.status_id = msik.default_lot_status_id -- Bug#2267947
                        AND msik.default_lot_status_id IS NOT NULL -- Bug#2267947
                        AND mln.inventory_item_id = msik.inventory_item_id
                        AND mln.inventory_item_id LIKE l_inventory_item_id
                        AND msik.lot_merge_enabled = 'Y'
                        AND mln.lot_number LIKE (p_lot_number)
                        AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled, p_organization_id,
                                                                         msik.inventory_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') =  'Y'
            UNION ALL
            SELECT DISTINCT moq.lot_number
                          , moq.inventory_item_id
                          , msik.concatenated_segments concatenated_segments
                          , msik.description
                          , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                          , NULL status_code
                          , msik.default_lot_status_id -- Bug#2267947
                       FROM mtl_onhand_quantities_detail moq, mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms, mtl_item_locations mil
                      WHERE moq.organization_id = p_organization_id
                        AND moq.lot_number IS NOT NULL
                        AND moq.organization_id = mil.organization_id
                        AND moq.organization_id = mln.organization_id
                        AND moq.organization_id = msik.organization_id
                        AND mil.segment19 = p_project_id
                        AND (mil.segment20 = p_task_id
                             OR (mil.segment20 IS NULL
                                 AND p_task_id IS NULL
                                )
                            )
                        AND mln.lot_number = moq.lot_number
                        AND msik.default_lot_status_id IS NULL -- Bug#2267947
                        AND mln.inventory_item_id = msik.inventory_item_id
                        AND mln.inventory_item_id LIKE l_inventory_item_id
                        AND msik.lot_merge_enabled = 'Y'
                        AND mln.lot_number LIKE (p_lot_number)
                        AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled, p_organization_id,
                                                                         msik.inventory_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') =  'Y'
                   ORDER BY 1, concatenated_segments;
        ELSE
          OPEN x_lot_num_lov FOR
            SELECT   mln.lot_number lot_number
                   , mln.inventory_item_id
                   , msik.concatenated_segments concatenated_segments
                   , msik.description
                   , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                   , mms.status_code
                   , mms.status_id
                FROM mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms
               WHERE mms.status_id = msik.default_lot_status_id -- Bug#2267947
                 AND msik.default_lot_status_id IS NOT NULL -- Bug#2267947
                 AND mln.organization_id = p_organization_id
                 AND mln.organization_id = msik.organization_id
                 AND mln.inventory_item_id = msik.inventory_item_id
                 AND mln.inventory_item_id LIKE l_inventory_item_id
                 AND msik.lot_merge_enabled = 'Y'
                 AND mln.lot_number LIKE (p_lot_number)
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled,
                                                                  p_organization_id, msik.inventory_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y'
            UNION ALL
            SELECT   mln.lot_number lot_number
                   , mln.inventory_item_id
                   , msik.concatenated_segments concatenated_segments
                   , msik.description
                   , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                   , NULL status_code
                   , msik.default_lot_status_id -- Bug#2267947
                FROM mtl_lot_numbers mln, mtl_system_items_kfv msik
               WHERE msik.default_lot_status_id IS NULL -- Bug#2267947
                 AND mln.organization_id = p_organization_id
                 AND mln.organization_id = msik.organization_id
                 AND mln.inventory_item_id = msik.inventory_item_id
                 AND mln.inventory_item_id LIKE l_inventory_item_id
                 AND msik.lot_merge_enabled = 'Y'
                 AND mln.lot_number LIKE (p_lot_number)
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled, p_organization_id, msik.inventory_item_id,
                                                                  p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y'
            ORDER BY lot_number, concatenated_segments;
        END IF;
      ELSE -- for Lot Translate
        OPEN x_lot_num_lov FOR
          SELECT   mln.lot_number lot_number
                 , mln.inventory_item_id
                 , msik.concatenated_segments concatenated_segments
                 , msik.description
                 , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                 , mms.status_code
                 , mms.status_id
              FROM mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms
             WHERE mms.status_id = msik.default_lot_status_id -- Bug#2267947
               AND msik.default_lot_status_id IS NOT NULL -- Bug#2267947
               AND mln.organization_id = p_organization_id
               AND mln.organization_id = msik.organization_id
               AND mln.inventory_item_id = msik.inventory_item_id
               AND msik.lot_control_code = 2
               AND mln.inventory_item_id LIKE l_inventory_item_id
               AND mln.lot_number LIKE (p_lot_number)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled, p_organization_id, msik.inventory_item_id,
                                                                p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y'
          UNION ALL
          SELECT   mln.lot_number LN
                 , mln.inventory_item_id
                 , msik.concatenated_segments cs
                 , msik.description
                 , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                 , NULL status_code
                 , msik.default_lot_status_id -- Bug#2267947
              FROM mtl_lot_numbers mln, mtl_system_items_kfv msik
             WHERE msik.default_lot_status_id IS NULL -- Bug#2267947
               AND mln.organization_id = p_organization_id
               AND mln.organization_id = msik.organization_id
               AND mln.inventory_item_id = msik.inventory_item_id
               AND msik.lot_control_code = 2
               AND mln.inventory_item_id LIKE l_inventory_item_id
               AND mln.lot_number LIKE (p_lot_number)
          ORDER BY lot_number, concatenated_segments;
      END IF;
    END IF;
  END get_parent_lov;
PROCEDURE validate_child_lot (
  p_org_id                      IN  NUMBER
, p_inventory_item_id           IN  NUMBER
, p_parent_lot_number           IN  VARCHAR2
, p_lot_number                  IN  VARCHAR2
, x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2)

IS
 l_api_version     NUMBER ;
 l_init_msg_list   VARCHAR2(50) ;
 l_commit          VARCHAR2 (50) ;
 l_return_status   VARCHAR2 (50) ;
 l_msg_count       NUMBER ;
 l_msg_data        VARCHAR2(3000) ;
BEGIN

    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    l_api_version              := 1.0;
    l_init_msg_list            := fnd_api.g_false;
    l_commit                   := fnd_api.g_false;

    INV_LOT_API_PUB.validate_child_lot (
             x_return_status          =>    l_return_status
           , x_msg_count              =>    l_msg_count
           , x_msg_data               =>    l_msg_data
           , p_api_version            =>    l_api_version
           , p_init_msg_list          =>    l_init_msg_list
           , p_commit                 =>    l_commit
           , p_organization_id        =>    p_org_id
           , p_inventory_item_id      =>    p_inventory_item_id
           , p_parent_lot_number      =>    p_parent_lot_number
           , p_child_lot_number       =>    p_lot_number
          )  ;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
           FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_LOT_API_PUB.VALIDATE_CHILD_LOT');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE fnd_api.g_exc_error;
      END IF;



 EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := FND_API.G_RET_STS_ERROR;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                  p_count => x_msg_count,
                                   p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                   p_count => x_msg_count,
                                    p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                  p_count => x_msg_count,
                                   p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;


    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                  p_count => x_msg_count,
                                   p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;

END validate_child_lot;

PROCEDURE Save_Conversions (         p_org_id   IN  NUMBER,
                                     p_frm_uom  IN  VARCHAR2,
                                     p_to_uom   IN  VARCHAR2,
                                     p_saveConv OUT NOCOPY VARCHAR2)
Is

l_org_id                 NUMBER ;
l_create_lot_uom_conv    NUMBER;
l_from_uom_code          VARCHAR2(10);
l_to_uom_code            VARCHAR2(10);
l_from_unit_of_measure   MTL_UNITS_OF_MEASURE.unit_of_measure_tl%TYPE;
l_from_uom_class         MTL_UNITS_OF_MEASURE.uom_class%TYPE;
l_to_unit_of_measure     MTL_UNITS_OF_MEASURE.unit_of_measure_tl%TYPE;
l_to_uom_class           MTL_UNITS_OF_MEASURE.uom_class%TYPE;
l_display_conversions    VARCHAR2(10) ;

Begin

       l_org_id := p_org_id;
       BEGIN
          SELECT   create_lot_uom_conversion
          INTO     l_create_lot_uom_conv
          FROM     mtl_parameters
          WHERE    organization_id = l_org_id;
       EXCEPTION
          WHEN OTHERS THEN
             l_create_lot_uom_conv := 1;
       END;

       l_display_conversions := '2';
         IF NVL(l_create_lot_uom_conv,1 ) = 2  THEN
                  l_display_conversions := '2';
         END IF;

         IF NVL(l_create_lot_uom_conv,1 ) IN (1,3)  THEN

             l_from_uom_code := p_frm_uom; -- Transaction UOM
             l_to_uom_code   := p_to_uom;  -- Secondary UOM;

          BEGIN
             SELECT   unit_of_measure_tl, uom_class
             INTO     l_from_unit_of_measure, l_from_uom_class
             FROM     MTL_UNITS_OF_MEASURE
             WHERE    UOM_CODE = l_from_uom_Code;
          EXCEPTION
             WHEN OTHERS THEN
                l_from_unit_of_measure := NULL;
                l_from_uom_class := NULL;
          END;

          BEGIN
             SELECT   unit_of_measure_tl, uom_class
             INTO     l_to_unit_of_measure, l_to_uom_class
             FROM     MTL_UNITS_OF_MEASURE
             WHERE    UOM_CODE = l_to_uom_Code;
          EXCEPTION
             WHEN OTHERS THEN
                l_to_unit_of_measure := NULL;
                l_to_uom_class := NULL;
          END;

          IF l_from_uom_class <> l_to_uom_class THEN
                IF NVL(l_create_lot_uom_conv,1 ) = 1 THEN
                      l_display_conversions := '1';
                            ELSIF NVL(l_create_lot_uom_conv,1 ) = 3 THEN
                      l_display_conversions := '3';
                END IF;
          END IF;
      END IF;
p_saveConv :=  l_display_conversions;

End;

 PROCEDURE Save_Lot_UOM_Conv(
  p_inventory_item_id          MTL_LOT_NUMBERS.inventory_item_id%TYPE,
 p_org_id                     NUMBER,
 P_TRANSACTION_QUANTITY           IN NUMBER,
 p_primary_quantity               IN NUMBER   ,
 P_TRANSACTION_UOM                IN VARCHAR2 ,
 p_primary_uom                    IN VARCHAR2 ,
 p_lot_number                 MTL_LOT_NUMBERS.lot_number%TYPE,
 p_expiration_date            MTL_LOT_NUMBERS.expiration_date%TYPE,
 x_return_status              OUT NOCOPY VARCHAR2,
 x_msg_data                   OUT NOCOPY VARCHAR2,
 x_msg_count                  OUT NOCOPY NUMBER,
 P_SUPPLIER_LOT_NUMBER        MTL_LOT_NUMBERS.SUPPLIER_LOT_NUMBER%TYPE,
 p_grade_code                 MTL_LOT_NUMBERS.grade_code%TYPE,
 p_ORIGINATION_DATE           MTL_LOT_NUMBERS.ORIGINATION_DATE%TYPE,
 P_STATUS_ID                  MTL_LOT_NUMBERS.STATUS_ID%TYPE,
 p_RETEST_DATE                MTL_LOT_NUMBERS.RETEST_DATE%TYPE,
 P_MATURITY_DATE              MTL_LOT_NUMBERS.MATURITY_DATE%TYPE,
 P_LOT_ATTRIBUTE_CATEGORY     MTL_LOT_NUMBERS.LOT_ATTRIBUTE_CATEGORY%TYPE,
 P_C_ATTRIBUTE1                 MTL_LOT_NUMBERS.C_ATTRIBUTE1%TYPE,
 P_C_ATTRIBUTE2                 MTL_LOT_NUMBERS.C_ATTRIBUTE2%TYPE,
 P_C_ATTRIBUTE3                 MTL_LOT_NUMBERS.C_ATTRIBUTE3%TYPE,
 P_C_ATTRIBUTE4                 MTL_LOT_NUMBERS.C_ATTRIBUTE4%TYPE,
 P_C_ATTRIBUTE5                 MTL_LOT_NUMBERS.C_ATTRIBUTE5%TYPE,
 P_C_ATTRIBUTE6                 MTL_LOT_NUMBERS.C_ATTRIBUTE6%TYPE,
 P_C_ATTRIBUTE7                 MTL_LOT_NUMBERS.C_ATTRIBUTE7%TYPE,
 P_C_ATTRIBUTE8                 MTL_LOT_NUMBERS.C_ATTRIBUTE8%TYPE,
 P_C_ATTRIBUTE9                 MTL_LOT_NUMBERS.C_ATTRIBUTE9%TYPE,
 P_C_ATTRIBUTE10                 MTL_LOT_NUMBERS.C_ATTRIBUTE10%TYPE,
 P_C_ATTRIBUTE11                 MTL_LOT_NUMBERS.C_ATTRIBUTE11%TYPE,
 P_C_ATTRIBUTE12                 MTL_LOT_NUMBERS.C_ATTRIBUTE12%TYPE,
 P_C_ATTRIBUTE13                 MTL_LOT_NUMBERS.C_ATTRIBUTE13%TYPE,
 P_C_ATTRIBUTE14                 MTL_LOT_NUMBERS.C_ATTRIBUTE14%TYPE,
 P_C_ATTRIBUTE15                 MTL_LOT_NUMBERS.C_ATTRIBUTE15%TYPE,
 P_C_ATTRIBUTE16                 MTL_LOT_NUMBERS.C_ATTRIBUTE16%TYPE,
 P_C_ATTRIBUTE17                 MTL_LOT_NUMBERS.C_ATTRIBUTE17%TYPE,
 P_C_ATTRIBUTE18                 MTL_LOT_NUMBERS.C_ATTRIBUTE18%TYPE,
 P_C_ATTRIBUTE19                 MTL_LOT_NUMBERS.C_ATTRIBUTE19%TYPE,
 P_C_ATTRIBUTE20                 MTL_LOT_NUMBERS.C_ATTRIBUTE20%TYPE,
 P_D_ATTRIBUTE1                 MTL_LOT_NUMBERS.D_ATTRIBUTE1%TYPE,
 P_D_ATTRIBUTE2                 MTL_LOT_NUMBERS.D_ATTRIBUTE2%TYPE,
 P_D_ATTRIBUTE3                 MTL_LOT_NUMBERS.D_ATTRIBUTE3%TYPE,
 P_D_ATTRIBUTE4                 MTL_LOT_NUMBERS.D_ATTRIBUTE4%TYPE,
 P_D_ATTRIBUTE5                 MTL_LOT_NUMBERS.D_ATTRIBUTE5%TYPE,
 P_D_ATTRIBUTE6                 MTL_LOT_NUMBERS.D_ATTRIBUTE6%TYPE,
 P_D_ATTRIBUTE7                 MTL_LOT_NUMBERS.D_ATTRIBUTE7%TYPE,
 P_D_ATTRIBUTE8                 MTL_LOT_NUMBERS.D_ATTRIBUTE8%TYPE,
 P_D_ATTRIBUTE9                 MTL_LOT_NUMBERS.D_ATTRIBUTE9%TYPE,
 P_D_ATTRIBUTE10                 MTL_LOT_NUMBERS.D_ATTRIBUTE10%TYPE,
 P_N_ATTRIBUTE1                 MTL_LOT_NUMBERS.N_ATTRIBUTE1%TYPE,
 P_N_ATTRIBUTE2                 MTL_LOT_NUMBERS.N_ATTRIBUTE2%TYPE,
 P_N_ATTRIBUTE3                 MTL_LOT_NUMBERS.N_ATTRIBUTE3%TYPE,
 P_N_ATTRIBUTE4                 MTL_LOT_NUMBERS.N_ATTRIBUTE4%TYPE,
 P_N_ATTRIBUTE5                 MTL_LOT_NUMBERS.N_ATTRIBUTE5%TYPE,
 P_N_ATTRIBUTE6                 MTL_LOT_NUMBERS.N_ATTRIBUTE6%TYPE,
 P_N_ATTRIBUTE7                 MTL_LOT_NUMBERS.N_ATTRIBUTE7%TYPE,
 P_N_ATTRIBUTE8                 MTL_LOT_NUMBERS.N_ATTRIBUTE8%TYPE,
 P_N_ATTRIBUTE9                 MTL_LOT_NUMBERS.N_ATTRIBUTE9%TYPE,
 P_N_ATTRIBUTE10                MTL_LOT_NUMBERS.N_ATTRIBUTE10%TYPE,
 P_SECONDARY_QUANTITY             IN NUMBER,
 P_SECONDARY_UOM_CODE             IN VARCHAR2 ,
 p_parent_lot_number          MTL_LOT_NUMBERS.parent_lot_number%TYPE,
 P_ORIGINATION_TYPE           MTL_LOT_NUMBERS.ORIGINATION_TYPE%TYPE,
 P_EXPIRATION_ACTION_DATE     MTL_LOT_NUMBERS.EXPIRATION_ACTION_DATE%TYPE,
 P_EXPIRATION_ACTION_CODE     MTL_LOT_NUMBERS.EXPIRATION_ACTION_CODE%TYPE,
 P_HOLD_DATE                  MTL_LOT_NUMBERS.HOLD_DATE%TYPE,
 P_REASON_ID                      IN VARCHAR2 ,
 p_response                       IN VARCHAR2 ,
 P_ATTRIBUTE_CATEGORY         MTL_LOT_NUMBERS.ATTRIBUTE_CATEGORY%TYPE,
 P_ATTRIBUTE1                 MTL_LOT_NUMBERS.ATTRIBUTE1%TYPE,
 P_ATTRIBUTE2                 MTL_LOT_NUMBERS.ATTRIBUTE2%TYPE,
 P_ATTRIBUTE3                 MTL_LOT_NUMBERS.ATTRIBUTE3%TYPE,
 P_ATTRIBUTE4                 MTL_LOT_NUMBERS.ATTRIBUTE4%TYPE,
 P_ATTRIBUTE5                 MTL_LOT_NUMBERS.ATTRIBUTE5%TYPE,
 P_ATTRIBUTE6                 MTL_LOT_NUMBERS.ATTRIBUTE6%TYPE,
 P_ATTRIBUTE7                 MTL_LOT_NUMBERS.ATTRIBUTE7%TYPE,
 P_ATTRIBUTE8                 MTL_LOT_NUMBERS.ATTRIBUTE8%TYPE,
 P_ATTRIBUTE9                 MTL_LOT_NUMBERS.ATTRIBUTE9%TYPE,
 P_ATTRIBUTE10                 MTL_LOT_NUMBERS.ATTRIBUTE10%TYPE,
 P_ATTRIBUTE11                 MTL_LOT_NUMBERS.ATTRIBUTE11%TYPE,
 P_ATTRIBUTE12                 MTL_LOT_NUMBERS.ATTRIBUTE12%TYPE,
 P_ATTRIBUTE13                 MTL_LOT_NUMBERS.ATTRIBUTE13%TYPE,
 P_ATTRIBUTE14                 MTL_LOT_NUMBERS.ATTRIBUTE14%TYPE,
 P_ATTRIBUTE15                 MTL_LOT_NUMBERS.ATTRIBUTE15%TYPE,
 P_ITEM_DUAL_UOM_CONTROL          IN VARCHAR2 , -- hold item's Tracking indicator
 P_copy_pnt_lot_att_flag          IN VARCHAR2 ,
 p_secondary_default_ind          IN VARCHAR2 ,
 p_disable_flag                  IN  MTL_LOT_NUMBERS.DISABLE_FLAG%TYPE DEFAULT NULL,   -- 4239238 Start
 p_territory_code                IN  MTL_LOT_NUMBERS.TERRITORY_CODE%TYPE DEFAULT NULL,
 p_date_code                     IN  MTL_LOT_NUMBERS.DATE_CODE%TYPE DEFAULT NULL,
 p_change_date                   IN  MTL_LOT_NUMBERS.CHANGE_DATE%TYPE DEFAULT NULL,
 p_age                           IN  MTL_LOT_NUMBERS.AGE%TYPE DEFAULT NULL,
 p_item_size                     IN  MTL_LOT_NUMBERS.ITEM_SIZE%TYPE DEFAULT NULL,
 p_color                         IN  MTL_LOT_NUMBERS.COLOR%TYPE DEFAULT NULL,
 p_volume                        IN  MTL_LOT_NUMBERS.VOLUME%TYPE DEFAULT NULL,
 p_volume_uom                    IN  MTL_LOT_NUMBERS.VOLUME_UOM%TYPE DEFAULT NULL,
 p_place_of_origin               IN  MTL_LOT_NUMBERS.PLACE_OF_ORIGIN%TYPE DEFAULT NULL,
 p_best_by_date                  IN  MTL_LOT_NUMBERS.BEST_BY_DATE%TYPE DEFAULT NULL,
 p_length                        IN  MTL_LOT_NUMBERS.LENGTH%TYPE DEFAULT NULL,
 p_length_uom                    IN  MTL_LOT_NUMBERS.LENGTH_UOM%TYPE DEFAULT NULL,
 p_recycled_content              IN  MTL_LOT_NUMBERS.RECYCLED_CONTENT%TYPE DEFAULT NULL,
 p_thickness                     IN  MTL_LOT_NUMBERS.THICKNESS%TYPE DEFAULT NULL,
 p_thickness_uom                 IN  MTL_LOT_NUMBERS.THICKNESS_UOM%TYPE DEFAULT NULL,
 p_width                         IN  MTL_LOT_NUMBERS.WIDTH%TYPE DEFAULT NULL,
 p_width_uom                     IN  MTL_LOT_NUMBERS.WIDTH_UOM%TYPE DEFAULT NULL,
 p_curl_wrinkle_fold             IN  MTL_LOT_NUMBERS.CURL_WRINKLE_FOLD%TYPE DEFAULT NULL,
 p_vendor_name                   IN  MTL_LOT_NUMBERS.VENDOR_NAME%TYPE DEFAULT NULL, -- 4239238 End
 p_source_lot                    IN  VARCHAR2 DEFAULT NULL,  --Bug#5349912
 p_copy_other_conversions        IN  VARCHAR2 DEFAULT 'F'    --Bug#5349912
)
 IS
    l_return_status            VARCHAR2(1)  ;
    l_msg_data                 VARCHAR2(3000)  ;
    l_msg_count                NUMBER    ;
    x_lot_rec                  MTL_LOT_NUMBERS%ROWTYPE;  -- for lot api
    l_in_lot_rec               MTL_LOT_NUMBERS%ROWTYPE;  -- for lot api
    l_lot_uom_conv_rec         mtl_lot_uom_class_conversions%ROWTYPE;  -- for uom conv
    l_qty_update_tbl           MTL_LOT_UOM_CONV_PUB.quantity_update_rec_type; -- for uom conv
    l_api_version              NUMBER;
    l_init_msg_list            VARCHAR2(100);
    l_commit                   VARCHAR2(100);
    l_validation_level         NUMBER;
    l_origin_txn_id            NUMBER;
    l_source                   NUMBER;
    l_create_lot_uom_conv      NUMBER;
    l_org_id                   NUMBER;
    l_from_uom_code            MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
    l_to_uom_code              MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
    l_from_unit_of_measure     MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE_TL%TYPE;
    l_to_unit_of_measure       MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE_TL%TYPE;
    l_from_uom_class           MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE;
    l_to_uom_class             MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE;
    l_conversion_rate          MTL_LOT_UOM_CLASS_CONVERSIONS.CONVERSION_RATE%TYPE;
    x_conversion_rate          MTL_LOT_UOM_CLASS_CONVERSIONS.CONVERSION_RATE%TYPE;
    l_go                       BOOLEAN;
    l_response                 NUMBER;
    l_sequence                 NUMBER;
    l_action_type              VARCHAR2(1);
    l_lot_number               mtl_transaction_lots_temp.lot_number%TYPE := p_lot_number;
    l_check_existing_parent_lot    BOOLEAN;
    l_row_id ROWID;
    l_exists VARCHAR2(10);
    L_LOT_UOM_CONVERSION VARCHAR2(10);
    l_sec_qty Number := 0;
    l_primary_uom MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
    l_primary_quantity NUMBER ;
 l_ITEM_DUAL_UOM_CONTROL    mtl_system_items.tracking_quantity_ind%TYPE      ;
 l_copy_pnt_lot_att_flag   mtl_system_items.copy_lot_attribute_flag%TYPE      ;
 l_secondary_default_ind   mtl_system_items.secondary_default_ind%TYPE      ;
 l_secondary_uom_code      mtl_system_items.secondary_uom_code%TYPE;
  /* Cursor definition to get Item attributes*/
   cursor c_get_item_attr
   IS
     SELECT        primary_uom_code
                  , secondary_uom_code
                      , secondary_default_ind
                                  , copy_lot_attribute_flag
                                  , tracking_quantity_ind
         FROM mtl_system_items
         WHERE organization_id          =  p_org_id
         AND         inventory_item_id  = p_inventory_item_id ;

 l_get_item_attr  c_get_item_attr%ROWTYPE ;

    /* Cursor definition to check if Lot UOM Conversion is needed */
   CURSOR  c_lot_uom_conv  IS
   SELECT  copy_lot_attribute_flag,
           lot_number_generation
     FROM  mtl_parameters
    WHERE  organization_id = p_org_id;

   l_lot_uom_conv   c_lot_uom_conv%ROWTYPE ;

   /* Cursor to check if a lot already exists*/
    CURSOR c_lot_exists IS
    SELECT 1
         FROM mtl_lot_numbers
         WHERE organization_id    = p_org_id
         AND   inventory_item_id  = p_inventory_item_id
         AND   lot_number         = p_lot_number ;

   l_lot_count  NUMBER := 0;

BEGIN
/* Step 1 ...preparing to insert lot in MLN by calling CREATE_INV_LOT
*  This will also take care of copying Parent's UOM Conv record for child lot
*/
    l_primary_uom := NULL; --p_primary_uom ;
    l_primary_quantity := NULL; --p_primary_quantity ;
    l_ITEM_DUAL_UOM_CONTROL   := NULL; --p_item_dual_uom_control ;
    l_copy_pnt_lot_att_flag   := NULL; --p_copy_pnt_lot_att_flag ;
    l_secondary_default_ind   := NULL; --p_secondary_default_ind ;
    l_secondary_uom_code      := NULL;-- p_secondary_uom_code;
-- Spr_Debug('1');
OPEN c_get_item_attr;
FETCH c_get_item_attr INTO l_get_item_attr;
CLOSE c_get_item_attr;

    OPEN c_lot_exists;
    FETCH c_lot_exists INTO l_lot_count;
    CLOSE c_lot_exists;


          l_return_status  := NULL;
          l_msg_data       := NULL;
          l_msg_count      := NULL;
          l_source                                 :=   NULL ;
          l_api_version                            :=   1.0;
          l_init_msg_list                          :=   'T';
          l_commit                                 :=   'F';
          l_validation_level                       :=   100;
          l_in_lot_rec.organization_id             :=   p_org_id  ;
          l_in_lot_rec.inventory_item_id           :=   p_inventory_item_id ;
          l_in_lot_rec.expiration_date             :=   p_expiration_date;
          l_in_lot_rec.grade_code                  :=   p_grade_code ;
          l_in_lot_rec.lot_number                  :=   p_lot_number ;
          l_in_lot_rec.parent_lot_number           :=   p_parent_lot_number;
          l_in_lot_rec.origination_date            :=   p_ORIGINATION_DATE;
          l_in_lot_rec.retest_date                 :=   p_RETEST_DATE ;
          l_in_lot_rec.maturity_date               :=   P_MATURITY_DATE;
          l_in_lot_rec.attribute_category          :=   P_ATTRIBUTE_CATEGORY;
          l_in_lot_rec.origination_type            :=   P_ORIGINATION_TYPE;
          l_in_lot_rec.hold_date                   :=   P_HOLD_DATE;
          l_in_lot_rec.expiration_action_code      :=   P_EXPIRATION_ACTION_CODE;
          l_in_lot_rec.expiration_action_date      :=   P_EXPIRATION_ACTION_DATE;
          l_in_lot_rec.status_id                   :=   P_STATUS_ID;
          l_in_lot_rec.supplier_lot_number         :=   P_SUPPLIER_LOT_NUMBER;
          l_in_lot_rec.LOT_ATTRIBUTE_CATEGORY      :=   P_LOT_ATTRIBUTE_CATEGORY;
          l_in_lot_rec.ATTRIBUTE1:= P_ATTRIBUTE1;
          l_in_lot_rec.ATTRIBUTE2:= P_ATTRIBUTE2;
          l_in_lot_rec.ATTRIBUTE3:= P_ATTRIBUTE3;
          l_in_lot_rec.ATTRIBUTE4:= P_ATTRIBUTE4;
          l_in_lot_rec.ATTRIBUTE5:= P_ATTRIBUTE5;
          l_in_lot_rec.ATTRIBUTE6:= P_ATTRIBUTE6;
          l_in_lot_rec.ATTRIBUTE7:= P_ATTRIBUTE7;
          l_in_lot_rec.ATTRIBUTE8:= P_ATTRIBUTE8;
          l_in_lot_rec.ATTRIBUTE9:= P_ATTRIBUTE9;
          l_in_lot_rec.ATTRIBUTE10:= P_ATTRIBUTE10;
          l_in_lot_rec.ATTRIBUTE11:= P_ATTRIBUTE11;
          l_in_lot_rec.ATTRIBUTE12:= P_ATTRIBUTE12;
          l_in_lot_rec.ATTRIBUTE13:= P_ATTRIBUTE13;
          l_in_lot_rec.ATTRIBUTE14:= P_ATTRIBUTE14;
          l_in_lot_rec.ATTRIBUTE15:= P_ATTRIBUTE15;
          l_in_lot_rec.C_ATTRIBUTE1:= P_C_ATTRIBUTE1;
          l_in_lot_rec.C_ATTRIBUTE2:= P_C_ATTRIBUTE2;
          l_in_lot_rec.C_ATTRIBUTE3:= P_C_ATTRIBUTE3;
          l_in_lot_rec.C_ATTRIBUTE4:= P_C_ATTRIBUTE4;
          l_in_lot_rec.C_ATTRIBUTE5:= P_C_ATTRIBUTE5;
          l_in_lot_rec.C_ATTRIBUTE6:= P_C_ATTRIBUTE6;
          l_in_lot_rec.C_ATTRIBUTE7:= P_C_ATTRIBUTE7;
          l_in_lot_rec.C_ATTRIBUTE8:= P_C_ATTRIBUTE8;
          l_in_lot_rec.C_ATTRIBUTE9:= P_C_ATTRIBUTE9;
          l_in_lot_rec.C_ATTRIBUTE10:= P_C_ATTRIBUTE10;
          l_in_lot_rec.C_ATTRIBUTE11:= P_C_ATTRIBUTE11;
          l_in_lot_rec.C_ATTRIBUTE12:= P_C_ATTRIBUTE12;
          l_in_lot_rec.C_ATTRIBUTE13:= P_C_ATTRIBUTE13;
          l_in_lot_rec.C_ATTRIBUTE14:= P_C_ATTRIBUTE14;
          l_in_lot_rec.C_ATTRIBUTE15:= P_C_ATTRIBUTE15;
          l_in_lot_rec.C_ATTRIBUTE16:= P_C_ATTRIBUTE16;
          l_in_lot_rec.C_ATTRIBUTE17:= P_C_ATTRIBUTE17;
          l_in_lot_rec.C_ATTRIBUTE18:= P_C_ATTRIBUTE18;
          l_in_lot_rec.C_ATTRIBUTE19:= P_C_ATTRIBUTE19;
          l_in_lot_rec.C_ATTRIBUTE20:= P_C_ATTRIBUTE20;
          l_in_lot_rec.D_ATTRIBUTE1:= P_D_ATTRIBUTE1;
          l_in_lot_rec.D_ATTRIBUTE2:= P_D_ATTRIBUTE2;
          l_in_lot_rec.D_ATTRIBUTE3:= P_D_ATTRIBUTE3;
          l_in_lot_rec.D_ATTRIBUTE4:= P_D_ATTRIBUTE4;
          l_in_lot_rec.D_ATTRIBUTE5:= P_D_ATTRIBUTE5;
          l_in_lot_rec.D_ATTRIBUTE6:= P_D_ATTRIBUTE6;
          l_in_lot_rec.D_ATTRIBUTE7:= P_D_ATTRIBUTE7;
          l_in_lot_rec.D_ATTRIBUTE8:= P_D_ATTRIBUTE8;
          l_in_lot_rec.D_ATTRIBUTE9:= P_D_ATTRIBUTE9;
          l_in_lot_rec.D_ATTRIBUTE10:= P_D_ATTRIBUTE10;
          l_in_lot_rec.N_ATTRIBUTE1:= P_N_ATTRIBUTE1;
          l_in_lot_rec.N_ATTRIBUTE2:= P_N_ATTRIBUTE2;
          l_in_lot_rec.N_ATTRIBUTE3:= P_N_ATTRIBUTE3;
          l_in_lot_rec.N_ATTRIBUTE4:= P_N_ATTRIBUTE4;
          l_in_lot_rec.N_ATTRIBUTE5:= P_N_ATTRIBUTE5;
          l_in_lot_rec.N_ATTRIBUTE6:= P_N_ATTRIBUTE6;
          l_in_lot_rec.N_ATTRIBUTE7:= P_N_ATTRIBUTE7;
          l_in_lot_rec.N_ATTRIBUTE8:= P_N_ATTRIBUTE8;
          l_in_lot_rec.N_ATTRIBUTE9:= P_N_ATTRIBUTE9;
          l_in_lot_rec.N_ATTRIBUTE10:= P_N_ATTRIBUTE10;
          l_in_lot_rec.disable_flag                :=   p_disable_flag ;   --- Please Verify if any Page requires It
          l_in_lot_rec.date_code                   :=   p_date_code;
          l_in_lot_rec.change_date                 :=   p_change_date ;
          l_in_lot_rec.age                         :=   p_age ;
          l_in_lot_rec.item_size                   :=   p_item_size ;
          l_in_lot_rec.color                       :=   p_color ;
          l_in_lot_rec.volume                      :=   p_volume ;
          l_in_lot_rec.volume_uom                  :=   p_volume_uom ;
          l_in_lot_rec.place_of_origin             :=   p_place_of_origin ;
          l_in_lot_rec.best_by_date                :=   p_best_by_date ;
          l_in_lot_rec.length                      :=   p_length ;
          l_in_lot_rec.length_uom                  :=   p_length_uom ;
          l_in_lot_rec.recycled_content            :=   p_recycled_content ;
          l_in_lot_rec.thickness                   :=   p_thickness ;
          l_in_lot_rec.thickness_uom               :=   p_thickness_uom ;
          l_in_lot_rec.width                       :=   p_width ;
          l_in_lot_rec.width_uom                   :=   p_width_uom ;
          l_in_lot_rec.territory_code              :=   p_territory_code ;
          l_in_lot_rec.vendor_name                 :=   p_vendor_name ;  -- Please Verify if any Page Requires it

          l_row_id := NULL;
-- Spr_Debug('2 '||          l_in_lot_rec.lot_number  );
-- Spr_Debug('2 .5 '|| l_lot_count ) ;
      IF l_lot_count = 0   THEN
          INV_LOT_API_PUB.Create_Inv_lot(
                x_return_status     =>     l_return_status
              , x_msg_count         =>     l_msg_count
              , x_msg_data          =>     l_msg_data
              , x_lot_rec           =>     x_lot_rec
              , p_lot_rec           =>     l_in_lot_rec
              , p_source            =>     l_source
              , p_api_version       =>     l_api_version
              , p_init_msg_list     =>     l_init_msg_list
              , p_commit            =>     l_commit
              , p_validation_level  =>     l_validation_level
              , p_origin_txn_id     =>     NULL
              , x_row_id            =>     l_row_id
               );
-- Spr_Debug('3: '||l_return_status);

          IF l_return_status <> 'S' THEN
--                               dbms_output.put_line('ERROR');
         FND_MSG_PUB.count_and_get
       (   p_count  => l_msg_count
         , p_data   => l_msg_data
        );
        -- Spr_Debug('3i '||x_msg_data);
          END IF;
      END IF; -- COUNT check
/*
* Step 2..Checking if lot specific UOM conversion are needed or not
*/
-- l_ITEM_DUAL_UOM_CONTROL  IN VARCHAR2   is a new parameter, hold item's Tracking indicator
-- P_TRANSACTION_QUANTITY IN NUMBER
-- P_SECONDARY_QUANTITY   IN NUMBER
          -- checking for lots UOM conversion rate
-- Spr_Debug('4: '||l_ITEM_DUAL_UOM_CONTROL );
-- Spr_Debug('4.2: primary_uom_code UOM '||l_primary_uom  );

  -- Check if item is dual controlled.
  -- if not then return from here, no need to create UOM conversion record.
    IF l_get_item_attr.tracking_quantity_ind <> 'PS' THEN

      x_return_status   := l_return_status ;
      x_msg_count       := l_msg_count ;
      x_msg_data        := l_msg_data ;

      RETURN ;
    END IF ;

     IF l_primary_uom IS NULL  THEN
       l_primary_uom := l_get_item_attr.primary_uom_code ;
     END IF;
     IF l_secondary_uom_code IS NULL THEN
       l_secondary_uom_code := l_get_item_attr.secondary_uom_code;
     END IF;
-- Spr_Debug('4.5: primary_uom_code UOM '||l_primary_uom  );
     IF l_ITEM_DUAL_UOM_CONTROL   IS NULL  THEN
        l_ITEM_DUAL_UOM_CONTROL := l_get_item_attr.tracking_quantity_ind ;
     END IF;

     IF  l_secondary_default_ind IS NULL  THEN
        l_secondary_default_ind :=  l_get_item_attr.secondary_default_ind ;
     END IF;

     IF l_copy_pnt_lot_att_flag  IS NULL  THEN
       l_copy_pnt_lot_att_flag :=  l_get_item_attr.copy_lot_attribute_flag ;
      END IF;
    /* Check needed for  Lot UOM conversion */
-- Spr_Debug('6: ');
     OPEN   c_lot_uom_conv ;
     FETCH  c_lot_uom_conv INTO l_lot_uom_conv ;

      IF  c_lot_uom_conv%FOUND THEN
           --       Possible values for mtl_parameters.lot_number_generation are:
           --   1  At organization level
           --   3  User defined
           --   2  At item level
-- Spr_Debug('7: ');
          IF  l_lot_uom_conv.lot_number_generation = 1 THEN
               l_copy_pnt_lot_att_flag := NVL(l_lot_uom_conv.copy_lot_attribute_flag,'N') ;
          END IF ;
       END IF;
      CLOSE c_lot_uom_conv ;

      IF l_primary_quantity    IS NULL  THEN
        l_primary_quantity := inv_convert.inv_um_convert(
                                                item_id                       => p_inventory_item_id
                                                , ORGANIZATION_ID             => P_ORG_ID
                                                , LOT_NUMBER                  => P_LOT_NUMBER
                                                , PRECISION                   => 5
                                                , from_quantity               => P_TRANSACTION_QUANTITY
                                                , from_unit                   => P_TRANSACTION_UOM
                                                , to_unit                     => l_primary_uom
                                                , from_name                   => NULL
                                                , to_name                     => NULL
                                                );
       END IF;
-- Spr_Debug('7: '||l_primary_quantity);

          IF l_ITEM_DUAL_UOM_CONTROL = 'PS' THEN
            l_conversion_rate := NVL(  NVL(P_TRANSACTION_QUANTITY,1) /  NVL(P_SECONDARY_QUANTITY,1) ,1);
            IF l_conversion_rate <= 0 THEN
                l_conversion_rate := 1;
            END IF;
          END IF;

      IF p_parent_lot_number IS NOT NULL THEN
          --- Check if Parent lot Already Exists
          --Bug#5349912 changed from p_lot_number to p_parent_lot_number in the following query
           BEGIN
           SELECT count('1')
           INTO l_exists
           FROM mtl_lot_numbers
           WHERE inventory_item_id = P_inventory_item_id
           AND organization_id = p_org_id
           AND lot_number = p_parent_lot_number
           AND  ROWNUM = 1;
           EXCEPTION
              WHEN no_data_found THEN
                         l_exists := 0;
           END;
        IF NVL(l_exists,0) > 0 THEN
              l_check_existing_parent_lot := TRUE;
        ELSE
             l_check_existing_parent_lot :=  FALSE;
        END IF;
      ELSE
            l_check_existing_parent_lot :=  FALSE;
      END IF;
-- Spr_Debug('5: ');
     -- calculate l_primary_quantity  if its null
     -- obtain  l_primary_uom from item if its null
/*     IF l_primary_uom IS NULL  THEN
       l_primary_uom := l_get_item_attr.primary_uom_code ;
     END IF;

     IF l_ITEM_DUAL_UOM_CONTROL   IS NULL  THEN
        l_ITEM_DUAL_UOM_CONTROL := l_get_item_attr.tracking_quantity_ind ;
     END IF;

     IF  l_secondary_default_ind IS NULL  THEN
        l_secondary_default_ind :=  l_get_item_attr.secondary_default_ind ;
     END IF;

     IF l_copy_pnt_lot_att_flag  IS NULL  THEN
       l_copy_pnt_lot_att_flag :=  l_get_item_attr.copy_lot_attribute_flag ;
      END IF;
     Check needed for  Lot UOM conversion
-- Spr_Debug('6: ');
     OPEN   c_lot_uom_conv ;
     FETCH  c_lot_uom_conv INTO l_lot_uom_conv ;

      IF  c_lot_uom_conv%FOUND THEN
           --       Possible values for mtl_parameters.lot_number_generation are:
           --   1  At organization level
           --   3  User defined
           --   2  At item level
-- Spr_Debug('7: ');
          IF  l_lot_uom_conv.lot_number_generation = 1 THEN
               l_copy_pnt_lot_att_flag := NVL(l_lot_uom_conv.copy_lot_attribute_flag,'N') ;
          END IF ;
       END IF;
      CLOSE c_lot_uom_conv ;

      IF l_primary_quantity    IS NULL  THEN
        l_primary_quantity := inv_convert.inv_um_convert(
                                                item_id                       => p_inventory_item_id
                                                , ORGANIZATION_ID             => P_ORG_ID
                                                , LOT_NUMBER                  => P_LOT_NUMBER
                                                , PRECISION                   => 5
                                                , from_quantity               => P_TRANSACTION_QUANTITY
                                                , from_unit                   => P_TRANSACTION_UOM
                                                , to_unit                     => l_primary_quantity
                                                , from_name                   => NULL
                                                , to_name                     => NULL
                                                );
       END IF;
*/
-- Spr_Debug('7: '||l_primary_uom);
-- Spr_Debug('7.1: '||l_primary_quantity);
-- Spr_Debug('7.2: '||l_secondary_uom_code);
          -- checking for item's UOM conversion rate

          l_sec_qty := inv_convert.inv_um_convert(
                                                item_id                       => p_inventory_item_id
                                                , ORGANIZATION_ID             => P_ORG_ID
                                                , LOT_NUMBER                  => P_LOT_NUMBER
                                                , PRECISION                   => 5
                                                , from_quantity               => l_primary_quantity
                                                , from_unit                   => l_primary_uom
                                                , to_unit                     => l_secondary_uom_code
                                                , from_name                   => NULL
                                                , to_name                     => NULL
                                                );
-- Spr_Debug('8: '||l_sec_qty);

          IF round(NVL(L_SEC_QTY, 0),5) <> round(NVL(P_SECONDARY_QUANTITY,0),5) -- 1 change to 0 on RHS Onyl if Item and Lot Conversion Rates are Different
          AND    p_parent_lot_number IS NULL      -- No Parent Lot
          OR     l_copy_pnt_lot_att_flag <> 'Y'   -- Donot copy from parent
          OR NOT l_check_existing_parent_lot THEN  --New Parent lot
                 l_org_id := P_ORG_ID;
                 BEGIN
                    SELECT   create_lot_uom_conversion
                    INTO     l_create_lot_uom_conv
                    FROM     mtl_parameters
                    WHERE    organization_id = l_org_id;
                 EXCEPTION
                 WHEN OTHERS THEN
                      l_create_lot_uom_conv := 1;
                 END;
-- Spr_Debug('9: '||l_create_lot_uom_conv);
            -- get UOM classes for trxn uOM and sec uom
                 l_from_uom_code := P_TRANSACTION_UOM;
                 l_to_uom_code   := l_secondary_uom_code ;
                 BEGIN
                    SELECT   unit_of_measure_tl, uom_class
                                      INTO     l_from_unit_of_measure, l_from_uom_class
                                      FROM     MTL_UNITS_OF_MEASURE
                                      WHERE    UOM_CODE = l_from_uom_Code;
-- Spr_Debug('100: ');

                                   EXCEPTION
                                   WHEN OTHERS THEN
-- Spr_Debug('110: ');

                                      l_from_unit_of_measure := NULL;
                                      l_from_uom_class := NULL;
                 END;
-- Spr_Debug('120: ');
                 BEGIN
                    SELECT   unit_of_measure_tl, uom_class
                    INTO     l_to_unit_of_measure, l_to_uom_class
                    FROM     MTL_UNITS_OF_MEASURE
                    WHERE    UOM_CODE = l_to_uom_Code;
-- Spr_Debug('130: ');

                 EXCEPTION
                 WHEN OTHERS THEN
-- Spr_Debug('140: ');

                    l_to_unit_of_measure := NULL;
                    l_to_uom_class := NULL;
                 END;
-- Spr_Debug('145: from '|| l_from_uom_class || ',to  '|| l_to_uom_class );
-- l_secondary_default_ind local variable
-- Spr_Debug('150: '||l_LOT_UOM_CONVERSION||' , CRT UOM CON'||l_create_lot_uom_conv ||' ,ITM DUAL COTR '||l_ITEM_DUAL_UOM_CONTROL);
l_LOT_UOM_CONVERSION := 'FALSE';

                 IF  NVL(l_create_lot_uom_conv,1 ) = 1   -- for 1  1 Means  Yes
                 AND l_ITEM_DUAL_UOM_CONTROL = 'PS'
                 AND l_from_uom_class <> l_to_uom_class THEN
                    L_LOT_UOM_CONVERSION := 'TRUE';
-- Spr_Debug('160: '||l_LOT_UOM_CONVERSION);
                 ELSIF NVL(l_create_lot_uom_conv, 1 ) = 3   --for 3 Means User Defined
                 AND l_ITEM_DUAL_UOM_CONTROL = 'PS'
                 AND l_from_uom_class <> l_to_uom_class THEN
                    IF p_response = 'Y' Then
                       l_response := 1;
                    Else
                       l_response := 2;
                    End IF;

                   -- l_response :=  Decode(p_response,'Y',1,'N',2) ;
-- Spr_Debug('170: '||l_LOT_UOM_CONVERSION);
                    IF l_response = 1 THEN
                      l_LOT_UOM_CONVERSION := 'TRUE';
-- Spr_Debug('180: '||l_LOT_UOM_CONVERSION);
                   ELSE
                     l_LOT_UOM_CONVERSION := 'NO';
-- Spr_Debug('190: '||l_LOT_UOM_CONVERSION);
                    END IF;
                 ELSE  -- for 2                        -- 2 Means No
                    l_LOT_UOM_CONVERSION := 'FALSE';
-- Spr_Debug('200: '||l_LOT_UOM_CONVERSION);
                 END IF;
-- Spr_Debug('210: ');


             /* Bug#5349912 even for the FIXED items, the execution flow is same
                so removing the condition for defaulting */
             --IF l_secondary_default_ind in ('N','D') AND
             IF NVL(l_create_lot_uom_conv, 1 ) IN (1,3) THEN
                IF l_LOT_UOM_CONVERSION  = 'TRUE' THEN
                  l_go := TRUE;
-- Spr_Debug('220: '||l_LOT_UOM_CONVERSION);
                ELSE
                  -- always YES
                  IF NVL(l_create_lot_uom_conv, 1 ) = 1
                  AND l_ITEM_DUAL_UOM_CONTROL = 'PS'
                  AND l_from_uom_class <> l_to_uom_class THEN
                     l_go := TRUE;
-- Spr_Debug('230: '||l_LOT_UOM_CONVERSION);
                  -- user response
                  ELSIF NVL(l_create_lot_uom_conv,1 ) = 3
                  AND l_ITEM_DUAL_UOM_CONTROL = 'PS'
                  AND l_from_uom_class <> l_to_uom_class THEN
                   IF NVL(l_LOT_UOM_CONVERSION,'FALSE') = 'TRUE' THEN
                        l_go := TRUE;
                      -- copy conversion from parent lot,if exists
                     ELSIF p_parent_lot_number IS NOT NULL
                     AND l_copy_pnt_lot_att_flag = 'Y'
                     AND l_check_existing_parent_lot
                     AND NVL(l_conversion_rate,0) <> NVL(x_conversion_rate,0) THEN
                        l_go := TRUE;
                     ELSE
                        IF NVL(l_LOT_UOM_CONVERSION,'FALSE') = 'NO' THEN
                           l_go := FALSE;
-- Spr_Debug('240: '||l_LOT_UOM_CONVERSION);
                        ELSE
                        --based on message response
                          IF p_response = 'Y' Then
                            l_response := 1;
                         Else
                            l_response := 2;
                         End IF;
                        --   l_response := Decode(p_response,'Y',1,'N',2); -- 1 is Yes 2 is No
                           IF l_response = 1 THEN
                              l_go := TRUE;
                           ELSE
                              l_go := FALSE;
                           END IF;
                        END IF;
                     END IF;
                  ELSE
                     l_go := FALSE;
                  END IF;
               END IF;
               IF l_go THEN
-- Spr_Debug('9: '||'In Seid EXPIRATION_ACTION_CODE; l_go');
                  l_lot_uom_conv_rec.conversion_id          :=       NULL;
                  l_lot_uom_conv_rec.lot_number             :=       P_LOT_NUMBER;
                  l_lot_uom_conv_rec.organization_id        :=       P_ORG_ID;
                  l_lot_uom_conv_rec.inventory_item_id      :=       P_INVENTORY_ITEM_ID;
                  l_lot_uom_conv_rec.from_unit_of_measure   :=       l_from_unit_of_measure;
                  l_lot_uom_conv_rec.from_uom_code          :=       l_from_uom_code;
                  l_lot_uom_conv_rec.from_uom_class         :=       l_from_uom_class;
                  l_lot_uom_conv_rec.to_unit_of_measure     :=       l_to_unit_of_measure;
                  l_lot_uom_conv_rec.to_uom_code            :=       l_to_uom_code;
                  l_lot_uom_conv_rec.to_uom_class           :=       l_to_uom_class;
                  l_lot_uom_conv_rec.conversion_rate        :=       l_conversion_rate;
                  l_lot_uom_conv_rec.disable_date           :=       NULL;
                  l_lot_uom_conv_rec.event_spec_disp_id     :=       NULL;
                  l_lot_uom_conv_rec.created_by             :=       FND_GLOBAL.user_id;
                  l_lot_uom_conv_rec.creation_date          :=       SYSDATE;
                  l_lot_uom_conv_rec.last_updated_by        :=       FND_GLOBAL.user_id;
                  l_lot_uom_conv_rec.last_update_date       :=       SYSDATE;
                  l_lot_uom_conv_rec.last_update_login      :=       FND_GLOBAL.login_id;
                  l_lot_uom_conv_rec.request_id             :=       NULL;
                  l_lot_uom_conv_rec.program_application_id :=       NULL;
                  l_lot_uom_conv_rec.program_id             :=       NULL;
                  l_lot_uom_conv_rec.program_update_date    :=       NULL;
                  IF p_parent_lot_number IS NOT NULL
                  AND l_copy_pnt_lot_att_flag = 'Y'
                  AND l_check_existing_parent_lot
                  AND NVL(l_conversion_rate,0) <> NVL(x_conversion_rate,0) THEN
                     l_action_type := 'U';
                  ELSE
                     l_action_type := 'I';
                  END IF;
-- P_REASON_ID input parame
                  /*sunitha ch. bug#5531391  create lot uom conversion only if it is a new lot */
                  IF l_lot_count = 0  THEN
                    MTL_LOT_UOM_CONV_PUB.CREATE_LOT_UOM_CONVERSION
                    (
                    p_api_version             =>          1.0
                    , p_init_msg_list          =>          'T'
                    , p_commit                 =>          'F'
                    , p_validation_level       =>          100
                    , p_action_type            =>          l_action_type
                    , p_update_type_indicator  =>          5
                    , p_reason_id              =>          P_REASON_ID
                    , p_batch_id               =>          0
                    , p_process_data           =>          'Y'
                    , p_lot_uom_conv_rec       =>          l_lot_uom_conv_rec
                    , p_qty_update_tbl         =>          l_qty_update_tbl
                    , x_return_status          =>          l_return_status
                    , x_msg_count              =>          l_msg_count
                    , x_msg_data               =>          l_msg_data
                    , x_sequence               =>          l_sequence
                    );
-- Spr_Debug('10: Create UOM '||l_return_status);
                  IF l_return_status <> 'S' THEN
--                     dbms_output.put_line('ERROR');
                     FND_MSG_PUB.count_and_get
                        (   p_count  => x_msg_count
                           ,p_data  => x_msg_data
                        );
                  END IF;
                END IF;--l_lot_count = 0

                /* Bug#5349912 Begin Added the following code to copy all other lot converisons
                   The below flag will be true only in case of Lot Split. In other cases the default is F */
                IF p_copy_other_conversions = fnd_api.g_true THEN
                    MTL_LOT_UOM_CONV_PVT.copy_lot_uom_conversions (
                     p_from_organization_id     =>   l_lot_uom_conv_rec.organization_id
                   , p_to_organization_id       =>   l_lot_uom_conv_rec.organization_id
                   , p_inventory_item_id        =>   l_lot_uom_conv_rec.inventory_item_id
                   , p_from_lot_number          =>   p_source_lot
                   , p_to_lot_number            =>   l_lot_uom_conv_rec.lot_number
                   , p_user_id                  =>   fnd_global.user_id
                   , p_creation_date            =>   SYSDATE
                   , p_commit                   =>   fnd_api.g_true
                   , x_return_status            =>   l_return_status
                   , x_msg_count                =>   l_msg_count
                   , x_msg_data                 =>   l_msg_data );

                   IF l_return_status <> 'S' THEN
                     FND_MSG_PUB.count_and_get
                         (   p_count  => x_msg_count
                           ,p_data  => x_msg_data
                         );
                   END IF; /* p_copy_other_conversions = fnd_api.g_true */
                END IF;
                --Bug#5349912 End
               END IF;
          END IF;
     END IF;

-- Spr_Debug('RETURNING');
      x_return_status   := NVL(l_return_status,'S');
      x_msg_data        := NVL(l_msg_data,'NO ERROR');
      x_msg_count       := NVL(l_msg_count,0);
-- Spr_Debug('RETURNED '||x_return_status||' '||x_msg_data||' '||x_msg_count);
  END Save_Lot_UOM_Conv;


--Added for bug 7426180 start

PROCEDURE  GET_ORG_COPY_LOTATTR_FLAG(
                     x_return_status           OUT   NOCOPY VARCHAR2
                   , x_msg_count               OUT   NOCOPY NUMBER
                   , x_msg_data                OUT   NOCOPY VARCHAR2
                   , x_copy_lot_attr_flag      OUT   NOCOPY VARCHAR2
                   , p_organization_id         IN    NUMBER
                   , p_inventory_item_id       IN    NUMBER
) IS
l_copy_lot_attribute_flag Varchar2(1):='N';
BEGIN

SELECT  NVL(copy_lot_attribute_flag,'N')  INTO l_copy_lot_attribute_flag
	FROM  mtl_parameters
	WHERE  organization_id = p_organization_id;


IF(l_copy_lot_attribute_flag ='N') THEN

    SELECT  NVL(copy_lot_attribute_flag,'N') INTO l_copy_lot_attribute_flag
	    FROM mtl_system_items
	    WHERE inventory_item_id = p_inventory_item_id
	    AND   organization_id   = p_organization_id;
END IF;

       x_copy_lot_attr_flag := l_copy_lot_attribute_flag ;
       print_debug('GET_ORG_COPY_LOTATTR_FLAG: x_copy_lot_attr_flag '|| x_copy_lot_attr_flag, 9);

EXCEPTION
	WHEN OTHERS THEN
	x_return_status  := fnd_api.G_RET_STS_ERROR;

	fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
	p_count => x_msg_count,
	p_data => x_msg_data);
	IF( x_msg_count > 1 ) THEN
		x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
	END IF;

END GET_ORG_COPY_LOTATTR_FLAG;

--Added for bug 7426180 end



END inv_lot_apis;

/
