--------------------------------------------------------
--  DDL for Package Body INV_LOT_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOT_API_PKG" 
  /* $Header: INVVLTPB.pls 120.4.12010000.2 2008/07/29 13:48:35 ptkumar ship $ */
 AS

--  Global constant holding the package name
    g_pkg_name   CONSTANT VARCHAR2 ( 30 ) := 'INV_LOT_API_PKG';


    PROCEDURE print_debug ( p_err_msg VARCHAR2, p_level NUMBER DEFAULT 1)
     IS
     BEGIN
         IF (g_debug = 1) THEN
            inv_mobile_helper_functions.tracelog (
              p_err_msg => p_err_msg,
             p_module => 'INV_LOT_API_PKG',
             p_level => p_level
          );

         END IF;
     END print_debug;

PROCEDURE Check_Item_Attributes(
    x_return_status          OUT    NOCOPY VARCHAR2
  , x_msg_count              OUT    NOCOPY NUMBER
  , x_msg_data               OUT    NOCOPY VARCHAR2
  , x_lot_cont               OUT    NOCOPY BOOLEAN
  , x_child_lot_cont         OUT    NOCOPY BOOLEAN
  , p_inventory_item_id      IN     NUMBER
  , p_organization_id        IN     NUMBER
  )
IS

  /* Cursor definition to check whether item is a valid and it's lot, child lot controlled */
  CURSOR  c_chk_msi_attr  IS
  SELECT  lot_control_code,
          child_lot_flag
    FROM  mtl_system_items
   WHERE  inventory_item_id =  p_inventory_item_id
     AND  organization_id   =  p_organization_id;

  l_chk_msi_attr_rec    c_chk_msi_attr%ROWTYPE;

BEGIN

    x_return_status  := fnd_api.g_ret_sts_success;

   /******************* START Item  validation ********************/

    /* Check item attributes in Mtl_system_items Table */
    OPEN  c_chk_msi_attr ;
    FETCH c_chk_msi_attr INTO l_chk_msi_attr_rec;

    IF c_chk_msi_attr%NOTFOUND THEN
       CLOSE c_chk_msi_attr;
       IF (g_debug = 1) THEN
          print_debug('Item not found.  Invalid item. Please re-enter.', 9);
       END IF;

       x_lot_cont        := FALSE ;
       x_child_lot_cont  := FALSE ;
       x_return_status  := fnd_api.g_ret_sts_error;

       fnd_message.set_name('INV', 'INV_INVALID_ITEM');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    ELSE
      CLOSE c_chk_msi_attr;

     /* If not lot controlled then error out */
       IF (l_chk_msi_attr_rec.lot_control_code = 1) THEN
          x_lot_cont   := FALSE ;
          IF g_debug = 1 THEN
             print_debug('Check_Item_Attributes. Item is not lot controlled ', 9);
          END IF;
       ELSE
          x_lot_cont   := TRUE ;
          IF g_debug = 1 THEN
             print_debug('Check_Item_Attributes. Item is lot controlled ', 9);
          END IF;
       END IF;  /*  l_chk_msi_attr_rec.lot_control_code = 1 */

       /* If not child lot enabled and p_parent_lot_number IS NOT NULL then error out */
       IF (l_chk_msi_attr_rec.child_lot_flag = 'N' ) THEN
          x_child_lot_cont  := FALSE ;
          IF g_debug = 1 THEN
            print_debug('Check_Item_Attributes. Item is not child lot enabled ', 9);
          END IF;
       ELSE
          x_child_lot_cont   := TRUE ;
          IF g_debug = 1 THEN
            print_debug('Check_Item_Attributes. Item is child lot enabled ', 9);
          END IF;
       END IF; /* l_chk_msi_attr_rec.child_lot_flag = 'N' */


    END IF;

   /******************* End Item validation  ********************/
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In Check_Item_Attributes, No data found ' || SQLERRM, 9);
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In Check_Item_Attributes, g_exc_error ' || SQLERRM, 9);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In Check_Item_Attributes, g_exc_unexpected_error ' || SQLERRM, 9);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In Check_Item_Attributes, Others ' || SQLERRM, 9);

  END Check_Item_Attributes;

  PROCEDURE Populate_Lot_Records (
                      x_return_status           OUT   NOCOPY VARCHAR2
                    , x_msg_count               OUT   NOCOPY NUMBER
                    , x_msg_data                OUT   NOCOPY VARCHAR2
                    , x_child_lot_rec           OUT   NOCOPY MTL_LOT_NUMBERS%ROWTYPE
                    , p_lot_rec                 IN    MTL_LOT_NUMBERS%ROWTYPE
                    , p_copy_lot_attribute_flag IN    VARCHAR2
                    , p_source                  IN    NUMBER
                    , p_api_version             IN    NUMBER
                    , p_init_msg_list           IN    VARCHAR2
                    , p_commit                  IN    VARCHAR2
                   )
  IS

   /* Cursor definition to check if Lot UOM Conversion is needed */
   CURSOR  c_lot_uom_conv(cp_organization_id NUMBER) IS
   SELECT  copy_lot_attribute_flag,
           lot_number_generation
     FROM  mtl_parameters
    WHERE  organization_id = cp_organization_id;

   l_lot_uom_conv   c_lot_uom_conv%ROWTYPE ;

   /* Cursor definition to check lot existence in Mtl_Lot_Numbers Table  */
   CURSOR  c_chk_lot_exists(cp_lot_number mtl_lot_numbers.lot_number%TYPE,cp_inventory_item_id NUMBER, cp_organization_id NUMBER) IS
   SELECT  lot_number
     FROM  mtl_lot_numbers
    WHERE  lot_number        = cp_lot_number AND
           inventory_item_id = cp_inventory_item_id AND
           organization_id   = cp_organization_id ;

   l_chk_lot_rec    c_chk_lot_exists%ROWTYPE;

   CURSOR  c_parent_lot_attr (cp_lot_number  mtl_lot_numbers.lot_number%TYPE) IS
   SELECT  *
     FROM  mtl_lot_numbers
    WHERE  lot_number = cp_lot_number ;

   l_parent_lot_attr c_parent_lot_attr%ROWTYPE ;

   l_copy_lot_attribute_flag    VARCHAR2(1) ;
   l_parent_exists_flag         VARCHAR2(1) ;
   l_return_status              VARCHAR2(1)  ;
   l_msg_data                   VARCHAR2(2000)  ;
   l_msg_count                  NUMBER    ;
   l_api_version                NUMBER;
   l_init_msg_list              VARCHAR2(100);
   l_commit                     VARCHAR2(100);
   l_source                     NUMBER;
   l_child_lot_rec              mtl_lot_numbers%ROWTYPE ;
   l_mtl_gen_obj_no             NUMBER ;

   l_lot_cont               BOOLEAN   ;
   l_child_lot_cont         BOOLEAN   ;
  BEGIN

    SAVEPOINT inv_pop_lot  ;

      l_source                   :=  p_source ;
      l_api_version		 := 1.0;
      l_init_msg_list		 := fnd_api.g_false;
      l_commit			 := fnd_api.g_false;


/******************* START Item  validation ********************/

   l_lot_cont        := FALSE ;
   l_child_lot_cont  := FALSE ;

   check_item_attributes
       (
              x_return_status          =>  l_return_status
            , x_msg_count              =>  l_msg_count
            , x_msg_data               =>  l_msg_data
            , x_lot_cont               =>  l_lot_cont
            , x_child_lot_cont         =>  l_child_lot_cont
            , p_inventory_item_id      =>  p_lot_rec.inventory_item_id
            , p_organization_id        =>  p_lot_rec.organization_id
         )   ;

     IF g_debug = 1 THEN
         print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes return ' || l_return_status, 9);
     END IF;

     IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF g_debug = 1 THEN
            print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes has failed with error', 9);
        END IF;
        FND_MESSAGE.SET_NAME('INV', 'INV_PROGRAM_ERROR') ;
        FND_MESSAGE.SET_TOKEN('PROG_NAME','Inv_lot_api_pkg.Check_Item_Attributes');
        FND_MSG_PUB.ADD;
        RAISE fnd_api.g_exc_error;
     END IF;

     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         IF g_debug = 1 THEN
            print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes has failed with a Unexpected exception', 9);
         END IF;
         FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
         FND_MESSAGE.SET_TOKEN('PROG_NAME','Inv_lot_api_pkg.Check_Item_Attributes');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     IF (l_lot_cont = FALSE) THEN
        IF g_debug = 1 THEN
           print_debug(' Item is not lot controlled ', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_NO_LOT_CONTROL');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
     END IF ;

     IF (l_child_lot_cont = FALSE AND p_lot_rec.parent_lot_number IS NOT NULL) THEN

        IF g_debug = 1 THEN
           print_debug(' Item is not Child lot controlled ', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_ITEM_CLOT_DISABLE_EXP');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
     END IF ;
   /******************* End Item validation  ********************/


    /* Verify p_copy_lot_attribute_flag and populate l_copy_lot_attribute_flag */

    IF p_copy_lot_attribute_flag  IS NULL THEN
       --  Based on the value of Mtl_parameters.lot_number_generation retrieve the copy_lot_attribute_flag either
       --  from Mtl_System_Items or from Mtl_Parameters and set l_copy_lot_attribute_flag.

       /* Check needed for  Lot UOM conversion */
       OPEN   c_lot_uom_conv (p_lot_rec.organization_id) ;
       FETCH  c_lot_uom_conv INTO l_lot_uom_conv ;

       IF  c_lot_uom_conv%FOUND THEN
           --       Possible values for mtl_parameters.lot_number_generation are:
           --  	1  At organization level
           --   3  User defined
           --  	2  At item level

          IF  l_lot_uom_conv.lot_number_generation = 1 THEN
             l_copy_lot_attribute_flag := NVL(l_lot_uom_conv.copy_lot_attribute_flag,'N') ;
          ELSIF  l_lot_uom_conv.lot_number_generation IN (2,3) THEN
             SELECT copy_lot_attribute_flag INTO l_copy_lot_attribute_flag
             FROM mtl_system_items
             WHERE inventory_item_id = p_lot_rec.inventory_item_id
             AND   organization_id   = p_lot_rec.organization_id;
          END IF;

       END IF ;
       CLOSE c_lot_uom_conv ;

    ELSE
       l_copy_lot_attribute_flag := p_copy_lot_attribute_flag ;
    END IF;


        l_parent_exists_flag := NULL ;
        --	Check for existence of p_lot_rec.parent_lot_number in Mtl_Lot_Numbers and set p_parent_exists_flag.
        OPEN   c_chk_lot_exists(p_lot_rec.parent_lot_number,p_lot_rec.INVENTORY_ITEM_ID,p_lot_rec.ORGANIZATION_ID);
        FETCH  c_chk_lot_exists INTO l_chk_lot_rec;

        IF c_chk_lot_exists%FOUND THEN
           /* Parent lot exists in Mtl_Lot_Numbers Table. */
           l_parent_exists_flag := 'Y' ;

        ELSIF c_chk_lot_exists%NOTFOUND AND p_lot_rec.parent_lot_number IS NOT NULL THEN
           /* Parent lot DOES NOT exist in Mtl_Lot_Numbers Table. */
           l_parent_exists_flag := 'N' ;
        END IF;
        CLOSE c_chk_lot_exists;

        x_child_lot_rec                          :=    p_lot_rec  ;

        IF l_copy_lot_attribute_flag = 'Y' AND l_parent_exists_flag = 'Y' THEN
            OPEN  c_parent_lot_attr(p_lot_rec.parent_lot_number) ;
            FETCH c_parent_lot_attr  INTO l_parent_lot_attr ;

            IF c_parent_lot_attr%FOUND THEN

               -- Bug 4115021- For OPM inventory convergence added sampling event id to mtl_lot_numbers table.
               x_child_lot_rec.sampling_event_id        :=  NVL ( x_child_lot_rec.sampling_event_id       , l_parent_lot_attr.sampling_event_id      ) ;
               x_child_lot_rec.grade_code               :=  NVL ( x_child_lot_rec.grade_code              , l_parent_lot_attr.grade_code             ) ;
               x_child_lot_rec.origination_type         :=  NVL ( x_child_lot_rec.origination_type        , l_parent_lot_attr.origination_type       ) ;
               x_child_lot_rec.origination_date         :=  NVL ( x_child_lot_rec.origination_date        , l_parent_lot_attr.origination_date       ) ;
               x_child_lot_rec.expiration_date          :=  NVL ( x_child_lot_rec.expiration_date         , l_parent_lot_attr.expiration_date        ) ;
               x_child_lot_rec.retest_date              :=  NVL ( x_child_lot_rec.retest_date             , l_parent_lot_attr.retest_date            ) ;
               x_child_lot_rec.expiration_action_date   :=  NVL ( x_child_lot_rec.expiration_action_date  , l_parent_lot_attr.expiration_action_date ) ;
               x_child_lot_rec.expiration_action_code   :=  NVL ( x_child_lot_rec.expiration_action_code  , l_parent_lot_attr.expiration_action_code ) ;
               x_child_lot_rec.hold_date                :=  NVL ( x_child_lot_rec.hold_date               , l_parent_lot_attr.hold_date              ) ;
               x_child_lot_rec.maturity_date            :=  NVL ( x_child_lot_rec.maturity_date           , l_parent_lot_attr.maturity_date          ) ;
               x_child_lot_rec.disable_flag             :=  NVL ( x_child_lot_rec.disable_flag            , l_parent_lot_attr.disable_flag           ) ;
               x_child_lot_rec.attribute_category       :=  NVL ( x_child_lot_rec.attribute_category      , l_parent_lot_attr.attribute_category     ) ;
               x_child_lot_rec.lot_attribute_category   :=  NVL ( x_child_lot_rec.lot_attribute_category  , l_parent_lot_attr.lot_attribute_category ) ;
               x_child_lot_rec.date_code                :=  NVL ( x_child_lot_rec.date_code               , l_parent_lot_attr.date_code              ) ;
               x_child_lot_rec.status_id                :=  NVL ( x_child_lot_rec.status_id               , l_parent_lot_attr.status_id              ) ;
               x_child_lot_rec.change_date              :=  NVL ( x_child_lot_rec.change_date             , l_parent_lot_attr.change_date            ) ;
               x_child_lot_rec.age                      :=  NVL ( x_child_lot_rec.age                     , l_parent_lot_attr.age                    ) ;
               x_child_lot_rec.retest_date              :=  NVL ( x_child_lot_rec.retest_date             , l_parent_lot_attr.retest_date            ) ;
               x_child_lot_rec.maturity_date            :=  NVL ( x_child_lot_rec.maturity_date           , l_parent_lot_attr.maturity_date          ) ;
               x_child_lot_rec.item_size                :=  NVL ( x_child_lot_rec.item_size               , l_parent_lot_attr.item_size              ) ;
               x_child_lot_rec.color                    :=  NVL ( x_child_lot_rec.color                   , l_parent_lot_attr.color                  ) ;
               x_child_lot_rec.volume                   :=  NVL ( x_child_lot_rec.volume                  , l_parent_lot_attr.volume                 ) ;
               x_child_lot_rec.volume_uom               :=  NVL ( x_child_lot_rec.volume_uom              , l_parent_lot_attr.volume_uom             ) ;
               x_child_lot_rec.place_of_origin          :=  NVL ( x_child_lot_rec.place_of_origin         , l_parent_lot_attr.place_of_origin        ) ;
               x_child_lot_rec.best_by_date             :=  NVL ( x_child_lot_rec.best_by_date            , l_parent_lot_attr.best_by_date           ) ;
               x_child_lot_rec.length                   :=  NVL ( x_child_lot_rec.length                  , l_parent_lot_attr.length                 ) ;
               x_child_lot_rec.length_uom               :=  NVL ( x_child_lot_rec.length_uom              , l_parent_lot_attr.length_uom             ) ;
               x_child_lot_rec.recycled_content         :=  NVL ( x_child_lot_rec.recycled_content        , l_parent_lot_attr.recycled_content       ) ;
               x_child_lot_rec.thickness                :=  NVL ( x_child_lot_rec.thickness               , l_parent_lot_attr.thickness              ) ;
               x_child_lot_rec.thickness_uom            :=  NVL ( x_child_lot_rec.thickness_uom           , l_parent_lot_attr.thickness_uom          ) ;
               x_child_lot_rec.width                    :=  NVL ( x_child_lot_rec.width                   , l_parent_lot_attr.width                  ) ;
               x_child_lot_rec.width_uom                :=  NVL ( x_child_lot_rec.width_uom               , l_parent_lot_attr.width_uom              ) ;
               x_child_lot_rec.territory_code           :=  NVL ( x_child_lot_rec.territory_code          , l_parent_lot_attr.territory_code         ) ;
               x_child_lot_rec.supplier_lot_number      :=  NVL ( x_child_lot_rec.supplier_lot_number     , l_parent_lot_attr.supplier_lot_number    ) ;
               x_child_lot_rec.vendor_name              :=  NVL ( x_child_lot_rec.vendor_name             , l_parent_lot_attr.vendor_name            ) ;
               x_child_lot_rec.lot_attribute_category   :=  NVL ( x_child_lot_rec.lot_attribute_category  , l_parent_lot_attr.lot_attribute_category ) ;
               x_child_lot_rec.attribute_category       :=  NVL ( x_child_lot_rec.attribute_category      , l_parent_lot_attr.attribute_category     ) ;
               x_child_lot_rec.attribute1               :=  NVL ( x_child_lot_rec.attribute1              , l_parent_lot_attr.attribute1             ) ;
               x_child_lot_rec.attribute2               :=  NVL ( x_child_lot_rec.attribute2              , l_parent_lot_attr.attribute2             ) ;
               x_child_lot_rec.attribute3               :=  NVL ( x_child_lot_rec.attribute3              , l_parent_lot_attr.attribute3             ) ;
               x_child_lot_rec.attribute4               :=  NVL ( x_child_lot_rec.attribute4              , l_parent_lot_attr.attribute4             ) ;
               x_child_lot_rec.attribute5               :=  NVL ( x_child_lot_rec.attribute5              , l_parent_lot_attr.attribute5             ) ;
               x_child_lot_rec.attribute6               :=  NVL ( x_child_lot_rec.attribute6              , l_parent_lot_attr.attribute6             ) ;
               x_child_lot_rec.attribute7               :=  NVL ( x_child_lot_rec.attribute7              , l_parent_lot_attr.attribute7             ) ;
               x_child_lot_rec.attribute8               :=  NVL ( x_child_lot_rec.attribute8              , l_parent_lot_attr.attribute8             ) ;
               x_child_lot_rec.attribute9               :=  NVL ( x_child_lot_rec.attribute9              , l_parent_lot_attr.attribute9             ) ;
               x_child_lot_rec.attribute10              :=  NVL ( x_child_lot_rec.attribute10             , l_parent_lot_attr.attribute10            ) ;
               x_child_lot_rec.attribute11              :=  NVL ( x_child_lot_rec.attribute11             , l_parent_lot_attr.attribute11            ) ;
               x_child_lot_rec.attribute12              :=  NVL ( x_child_lot_rec.attribute12             , l_parent_lot_attr.attribute12            ) ;
               x_child_lot_rec.attribute13              :=  NVL ( x_child_lot_rec.attribute13             , l_parent_lot_attr.attribute13            ) ;
               x_child_lot_rec.attribute14              :=  NVL ( x_child_lot_rec.attribute14             , l_parent_lot_attr.attribute14            ) ;
               x_child_lot_rec.attribute15              :=  NVL ( x_child_lot_rec.attribute15             , l_parent_lot_attr.attribute15            ) ;
               x_child_lot_rec.c_attribute1             :=  NVL ( x_child_lot_rec.c_attribute1            , l_parent_lot_attr.c_attribute1           ) ;
               x_child_lot_rec.c_attribute2             :=  NVL ( x_child_lot_rec.c_attribute2            , l_parent_lot_attr.c_attribute2           ) ;
               x_child_lot_rec.c_attribute3             :=  NVL ( x_child_lot_rec.c_attribute3            , l_parent_lot_attr.c_attribute3           ) ;
               x_child_lot_rec.c_attribute4             :=  NVL ( x_child_lot_rec.c_attribute4            , l_parent_lot_attr.c_attribute4           ) ;
               x_child_lot_rec.c_attribute5             :=  NVL ( x_child_lot_rec.c_attribute5            , l_parent_lot_attr.c_attribute5           ) ;
               x_child_lot_rec.c_attribute6             :=  NVL ( x_child_lot_rec.c_attribute6            , l_parent_lot_attr.c_attribute6           ) ;
               x_child_lot_rec.c_attribute7             :=  NVL ( x_child_lot_rec.c_attribute7            , l_parent_lot_attr.c_attribute7           ) ;
               x_child_lot_rec.c_attribute8             :=  NVL ( x_child_lot_rec.c_attribute8            , l_parent_lot_attr.c_attribute8           ) ;
               x_child_lot_rec.c_attribute9             :=  NVL ( x_child_lot_rec.c_attribute9            , l_parent_lot_attr.c_attribute9           ) ;
               x_child_lot_rec.c_attribute10            :=  NVL ( x_child_lot_rec.c_attribute10           , l_parent_lot_attr.c_attribute10          ) ;
               x_child_lot_rec.c_attribute11            :=  NVL ( x_child_lot_rec.c_attribute11           , l_parent_lot_attr.c_attribute11          ) ;
               x_child_lot_rec.c_attribute12            :=  NVL ( x_child_lot_rec.c_attribute12           , l_parent_lot_attr.c_attribute12          ) ;
               x_child_lot_rec.c_attribute13            :=  NVL ( x_child_lot_rec.c_attribute13           , l_parent_lot_attr.c_attribute13          ) ;
               x_child_lot_rec.c_attribute14            :=  NVL ( x_child_lot_rec.c_attribute14           , l_parent_lot_attr.c_attribute14          ) ;
               x_child_lot_rec.c_attribute15            :=  NVL ( x_child_lot_rec.c_attribute15           , l_parent_lot_attr.c_attribute15          ) ;
               x_child_lot_rec.c_attribute16            :=  NVL ( x_child_lot_rec.c_attribute16           , l_parent_lot_attr.c_attribute16          ) ;
               x_child_lot_rec.c_attribute17            :=  NVL ( x_child_lot_rec.c_attribute17           , l_parent_lot_attr.c_attribute17          ) ;
               x_child_lot_rec.c_attribute18            :=  NVL ( x_child_lot_rec.c_attribute18           , l_parent_lot_attr.c_attribute18          ) ;
               x_child_lot_rec.c_attribute19            :=  NVL ( x_child_lot_rec.c_attribute19           , l_parent_lot_attr.c_attribute19          ) ;
               x_child_lot_rec.c_attribute20            :=  NVL ( x_child_lot_rec.c_attribute20           , l_parent_lot_attr.c_attribute20          ) ;
               x_child_lot_rec.d_attribute1             :=  NVL ( x_child_lot_rec.d_attribute1            , l_parent_lot_attr.d_attribute1           ) ;
               x_child_lot_rec.d_attribute2             :=  NVL ( x_child_lot_rec.d_attribute2            , l_parent_lot_attr.d_attribute2           ) ;
               x_child_lot_rec.d_attribute3             :=  NVL ( x_child_lot_rec.d_attribute3            , l_parent_lot_attr.d_attribute3           ) ;
               x_child_lot_rec.d_attribute4             :=  NVL ( x_child_lot_rec.d_attribute4            , l_parent_lot_attr.d_attribute4           ) ;
               x_child_lot_rec.d_attribute5             :=  NVL ( x_child_lot_rec.d_attribute5            , l_parent_lot_attr.d_attribute5           ) ;
               x_child_lot_rec.d_attribute6             :=  NVL ( x_child_lot_rec.d_attribute6            , l_parent_lot_attr.d_attribute6           ) ;
               x_child_lot_rec.d_attribute7             :=  NVL ( x_child_lot_rec.d_attribute7            , l_parent_lot_attr.d_attribute7           ) ;
               x_child_lot_rec.d_attribute8             :=  NVL ( x_child_lot_rec.d_attribute8            , l_parent_lot_attr.d_attribute8           ) ;
               x_child_lot_rec.d_attribute9             :=  NVL ( x_child_lot_rec.d_attribute9            , l_parent_lot_attr.d_attribute9           ) ;
               x_child_lot_rec.d_attribute10            :=  NVL ( x_child_lot_rec.d_attribute10           , l_parent_lot_attr.d_attribute10          ) ;
               x_child_lot_rec.n_attribute1             :=  NVL ( x_child_lot_rec.n_attribute1            , l_parent_lot_attr.n_attribute1           ) ;
               x_child_lot_rec.n_attribute2             :=  NVL ( x_child_lot_rec.n_attribute2            , l_parent_lot_attr.n_attribute2           ) ;
               x_child_lot_rec.n_attribute3             :=  NVL ( x_child_lot_rec.n_attribute3            , l_parent_lot_attr.n_attribute3           ) ;
               x_child_lot_rec.n_attribute4             :=  NVL ( x_child_lot_rec.n_attribute4            , l_parent_lot_attr.n_attribute4           ) ;
               x_child_lot_rec.n_attribute5             :=  NVL ( x_child_lot_rec.n_attribute5            , l_parent_lot_attr.n_attribute5           ) ;
               x_child_lot_rec.n_attribute6             :=  NVL ( x_child_lot_rec.n_attribute6            , l_parent_lot_attr.n_attribute6           ) ;
               x_child_lot_rec.n_attribute7             :=  NVL ( x_child_lot_rec.n_attribute7            , l_parent_lot_attr.n_attribute7           ) ;
               x_child_lot_rec.n_attribute8             :=  NVL ( x_child_lot_rec.n_attribute8            , l_parent_lot_attr.n_attribute8           ) ;
               x_child_lot_rec.n_attribute9             :=  NVL ( x_child_lot_rec.n_attribute9            , l_parent_lot_attr.n_attribute9           ) ;
               x_child_lot_rec.n_attribute10            :=  NVL ( x_child_lot_rec.n_attribute10           , l_parent_lot_attr.n_attribute10          ) ;
               /*Bug#5523811 defaulting the values for fields curl_wrnkl_fold, description and vendor_id
                 from the parent lot*/
               x_child_lot_rec.curl_wrinkle_fold        :=  NVL ( x_child_lot_rec.curl_wrinkle_fold       , l_parent_lot_attr.curl_wrinkle_fold          ) ;
               x_child_lot_rec.description              :=  NVL ( x_child_lot_rec.description             , l_parent_lot_attr.description          ) ;
               x_child_lot_rec.vendor_id                :=  NVL ( x_child_lot_rec.vendor_id               , l_parent_lot_attr.vendor_id          ) ;
            END IF ;
            CLOSE c_parent_lot_attr ;

         ELSE

         /* Default Missing Attributes from Item Master by calling Set_Msi_Default_Attr API */
           Inv_Lot_Api_Pkg.Set_Msi_Default_Attr(
                         p_lot_rec             =>   x_child_lot_rec
                       , x_return_status       =>   l_return_status
                       , x_msg_count           =>   l_msg_count
                       , x_msg_data            =>   l_msg_data
                       ) ;

                        IF g_debug = 1 THEN
                           print_debug('Program Inv_Lot_Api_Pkg.Set_Msi_Default_Attr return ' || l_return_status, 9);
                        END IF;
                        IF l_return_status = fnd_api.g_ret_sts_error THEN
                           IF g_debug = 1 THEN
                              print_debug('Program Inv_Lot_Api_Pkg.Set_Msi_Default_Attr has failed with a user defined exception', 9);
                           END IF;
                           RAISE fnd_api.g_exc_error;
                        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                           IF g_debug = 1 THEN
                               print_debug('Program Inv_Lot_Api_Pkg.Set_Msi_Default_Attr has failed with a Unexpected exception', 9);
                           END IF;
                           FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                           FND_MESSAGE.SET_TOKEN('PROG_NAME','Inv_Lot_Api_Pkg.Set_Msi_Default_Attr');
                           FND_MSG_PUB.ADD;
                           RAISE fnd_api.g_exc_unexpected_error;
                        END IF;


         END IF ;

         /* Validate naming convention for the child lot by calling Inv_lot_api_pub.VALIDATE_CHILD_LOT API */
         IF (x_child_lot_rec.parent_lot_number IS NOT NULL) THEN
            Inv_lot_api_pub.Validate_Child_Lot (
                            p_api_version         =>   l_api_version
                          , p_init_msg_list       =>   l_init_msg_list
                          , p_commit              =>   l_commit
                          , p_validation_level    =>   FND_API.G_VALID_LEVEL_FULL
                          , p_organization_id     =>   x_child_lot_rec.organization_id
                          , p_inventory_item_id   =>   x_child_lot_rec.inventory_item_id
                          , p_parent_lot_number   =>   x_child_lot_rec.parent_lot_number
                          , p_child_lot_number    =>   x_child_lot_rec.lot_number
                          , x_return_status       =>   l_return_status
			   /* Bug#5197732 passed the variables and types */
                          , x_msg_count           =>   l_msg_count
                          , x_msg_data            =>   l_msg_data
                          /*, x_msg_count           =>   l_msg_data
                          , x_msg_data            =>   l_msg_count  */
                          ) ;

                  IF g_debug = 1 THEN
                     print_debug('Program Inv_lot_api_pub.VALIDATE_CHILD_LOT return ' || l_return_status, 9);
                  END IF;
                  IF l_return_status = fnd_api.g_ret_sts_error THEN
                     IF g_debug = 1 THEN
                        print_debug('Program Inv_lot_api_pub.VALIDATE_CHILD_LOT has failed with a user defined exception', 9);
                     END IF;
                     RAISE fnd_api.g_exc_error;
                  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                     IF g_debug = 1 THEN
                         print_debug('Program Inv_lot_api_pub.VALIDATE_CHILD_LOT has failed with a Unexpected exception', 9);
                     END IF;
                     FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                     FND_MESSAGE.SET_TOKEN('PROG_NAME','Inv_lot_api_pub.VALIDATE_CHILD_LOT');
                     FND_MSG_PUB.ADD;
                     RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
           END IF ; --parent lot check
         /* Validate parent lot record x_parent_lot_rec by calling VALIDATE_LOT_ATTRIBUTES API */
         INV_LOT_API_PKG.Validate_Lot_Attributes (
                            x_lot_rec        => x_child_lot_rec
                          , p_source         => l_source
                          , x_return_status  => l_return_status
                          , x_msg_data       => l_msg_data
                          , x_msg_count      => l_msg_count
                           ) ;
                 IF g_debug = 1 THEN
                    print_debug('Program INV_LOT_API_PKG.VALIDATE_LOT_ATTRIBUTES return ' || l_return_status, 9);
                 END IF;
                 IF l_return_status = fnd_api.g_ret_sts_error THEN
                    IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_API_PKG.VALIDATE_LOT_ATTRIBUTES has failed with a user defined exception', 9);
                    END IF;
                    RAISE fnd_api.g_exc_error;
                 ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                    IF g_debug = 1 THEN
                        print_debug('Program INV_LOT_API_PKG.VALIDATE_LOT_ATTRIBUTES has failed with a Unexpected exception', 9);
                    END IF;
                    FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                    FND_MESSAGE.SET_TOKEN('PROG_NAME','INV_LOT_API_PKG.VALIDATE_LOT_ATTRIBUTES');
                    FND_MSG_PUB.ADD;
                    RAISE fnd_api.g_exc_unexpected_error;
                 END IF;


        print_debug('Program  INV_LOT_API_PKG.Populate_Lot_Records Ends ' , 9);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO inv_pop_lot ;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In No data found Populate_Lot_Records ' || SQLERRM, 9);
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO inv_pop_lot ;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In g_exc_error Populate_Lot_Records ' || SQLERRM, 9);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO inv_pop_lot ;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In g_exc_unexpected_error Populate_Lot_Records ' || SQLERRM, 9);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO inv_pop_lot ;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In others Populate_Lot_Records ' || SQLERRM, 9);

  END Populate_Lot_Records;




  PROCEDURE Set_Msi_Default_Attr (
                    p_lot_rec           IN OUT NOCOPY mtl_lot_numbers%ROWTYPE
                  , x_return_status     OUT    NOCOPY VARCHAR2
                  , x_msg_count         OUT    NOCOPY NUMBER
                  , x_msg_data          OUT    NOCOPY VARCHAR2
  )
  IS

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
	   , origination_type
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
    CURSOR cur_get_mti_rec (c_mti_hdr_id NUMBER) IS
       SELECT * FROM mtl_transactions_interface
       WHERE transaction_interface_id = c_mti_hdr_id;

    CURSOR cur_get_mtli_rec (c_mtli_hdr_id ROWID) IS
       SELECT * FROM mtl_transaction_lots_interface
       WHERE ROWID = c_mtli_hdr_id;

    CURSOR cur_get_mmtt_rec (c_mmtt_hdr_id NUMBER) IS
       SELECT * FROM mtl_material_transactions_temp
       WHERE transaction_header_id = c_mmtt_hdr_id;

    CURSOR cur_get_mtlt_rec (c_mtlt_hdr_id ROWID) IS
       SELECT * FROM mtl_transaction_lots_temp
       WHERE ROWID = c_mtlt_hdr_id;

    l_mti_txn_id            NUMBER;
    l_mmtt_txn_id           NUMBER;
    l_mtli_txn_id           ROWID;
    l_mtlt_txn_id           ROWID;
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
   l_lot_cont               BOOLEAN   ;
   l_child_lot_cont         BOOLEAN   ;

  BEGIN

  /******************* START Item  validation ********************/

   l_lot_cont        := FALSE ;
   l_child_lot_cont  := FALSE ;

   check_item_attributes
       (
              x_return_status          =>  l_return_status
            , x_msg_count              =>  l_msg_count
            , x_msg_data               =>  l_msg_data
            , x_lot_cont               =>  l_lot_cont
            , x_child_lot_cont         =>  l_child_lot_cont
            , p_inventory_item_id      =>  p_lot_rec.inventory_item_id
            , p_organization_id        =>  p_lot_rec.organization_id
         )   ;

     IF g_debug = 1 THEN
         print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes return ' || l_return_status, 9);
     END IF;

     IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF g_debug = 1 THEN
            print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes has failed with error', 9);
        END IF;
        FND_MESSAGE.SET_NAME('INV', 'INV_PROGRAM_ERROR') ;
        FND_MESSAGE.SET_TOKEN('PROG_NAME','Inv_lot_api_pkg.Check_Item_Attributes');
        FND_MSG_PUB.ADD;
        RAISE fnd_api.g_exc_error;
     END IF;

     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         IF g_debug = 1 THEN
            print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes has failed with a Unexpected exception', 9);
         END IF;
         FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
         FND_MESSAGE.SET_TOKEN('PROG_NAME','Inv_lot_api_pkg.Check_Item_Attributes');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     IF (l_lot_cont = FALSE) THEN
        IF g_debug = 1 THEN
           print_debug(' Item is not lot controlled ', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_NO_LOT_CONTROL');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
     END IF ;

     IF (l_child_lot_cont = FALSE AND p_lot_rec.parent_lot_number IS NOT NULL) THEN

        IF g_debug = 1 THEN
           print_debug(' Item is not Child lot controlled ', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_ITEM_CLOT_DISABLE_EXP');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
     END IF ;

  /******************* End Item validation  ********************/

    -- nsinghi bug#5209065 rework START.
    l_new_lot := FALSE;
    OPEN  c_get_lot_attr(p_lot_rec.inventory_item_id,p_lot_rec.organization_id, p_lot_rec.lot_number);
    FETCH c_get_lot_attr INTO l_get_lot_attr_rec;
    IF c_get_lot_attr%NOTFOUND THEN
       l_new_lot := TRUE;
    END IF;
    CLOSE c_get_lot_attr;
    IF (NOT l_new_lot) THEN
       IF l_get_lot_attr_rec.grade_code IS NOT NULL AND p_lot_rec.grade_code IS NULL THEN
          p_lot_rec.grade_code := l_get_lot_attr_rec.grade_code;
       END IF;
       IF l_get_lot_attr_rec.expiration_date IS NOT NULL AND p_lot_rec.expiration_date IS NULL THEN
          p_lot_rec.expiration_date := l_get_lot_attr_rec.expiration_date;
       END IF;
       IF l_get_lot_attr_rec.expiration_action_code IS NOT NULL AND p_lot_rec.expiration_action_code IS NULL THEN
          p_lot_rec.expiration_action_code := l_get_lot_attr_rec.expiration_action_code;
       END IF;
       IF l_get_lot_attr_rec.expiration_action_date IS NOT NULL AND p_lot_rec.expiration_action_date IS NULL THEN
          p_lot_rec.expiration_action_date := l_get_lot_attr_rec.expiration_action_date;
       END IF;
       IF l_get_lot_attr_rec.origination_date IS NOT NULL AND p_lot_rec.origination_date IS NULL THEN
          p_lot_rec.origination_date := l_get_lot_attr_rec.origination_date;
       END IF;
       IF l_get_lot_attr_rec.origination_type IS NOT NULL AND p_lot_rec.origination_type IS NULL THEN
          p_lot_rec.origination_type := l_get_lot_attr_rec.origination_type;
       END IF;
       IF l_get_lot_attr_rec.retest_date IS NOT NULL AND p_lot_rec.retest_date IS NULL THEN
          p_lot_rec.retest_date := l_get_lot_attr_rec.retest_date;
       END IF;
       IF l_get_lot_attr_rec.maturity_date IS NOT NULL AND p_lot_rec.maturity_date IS NULL THEN
          p_lot_rec.maturity_date := l_get_lot_attr_rec.maturity_date;
       END IF;
       IF l_get_lot_attr_rec.hold_date IS NOT NULL AND p_lot_rec.hold_date IS NULL THEN
          p_lot_rec.hold_date := l_get_lot_attr_rec.hold_date;
       END IF;
    END IF;
    -- nsinghi bug#5209065 rework END.

    /*Get default information from Mtl_System_Item */
    OPEN  c_get_dft_attr(p_lot_rec.inventory_item_id,p_lot_rec.organization_id);
    FETCH c_get_dft_attr INTO l_get_dft_attr_rec;
    CLOSE c_get_dft_attr;

     /* Grade */
       IF l_get_dft_attr_rec.grade_control_flag = 'Y' AND p_lot_rec.grade_code IS NULL THEN
          p_lot_rec.grade_code := l_get_dft_attr_rec.default_grade;
       END IF;
    /* Origination Type */
      IF p_lot_rec.origination_type IS NULL THEN
         p_lot_rec.origination_type := 6;               -- Origination Type OTHER = 6
      END IF;

    /* Origination Date */
       IF p_lot_rec.origination_date IS NOT NULL THEN

          /* Expiration Date */
          IF p_lot_rec.expiration_date IS NULL AND l_get_dft_attr_rec.shelf_life_code = 2 THEN      -- Item shelf life days
          -- nsinghi bug 5209065 START. This API defaults the expiration date. If MMTT or MTI table has data
	  -- and header id is set, we call the custom lot expiration API to get expiration date.
              l_mti_txn_id := inv_calculate_exp_date.get_txn_id (p_table => 1);
              l_mtli_txn_id := inv_calculate_exp_date.get_lot_txn_id (p_table => 1);

              l_mmtt_txn_id := inv_calculate_exp_date.get_txn_id (p_table => 2);
              l_mtlt_txn_id := inv_calculate_exp_date.get_lot_txn_id (p_table => 2);

              IF l_mti_txn_id <> -1 AND l_mtli_txn_id <> '-1' THEN

                 OPEN cur_get_mti_rec (l_mti_txn_id);
                 FETCH cur_get_mti_rec INTO l_mti_txn_rec;
                 CLOSE cur_get_mti_rec;

                 OPEN cur_get_mtli_rec (l_mtli_txn_id);
                 FETCH cur_get_mtli_rec INTO l_mtli_txn_rec;
                 CLOSE cur_get_mtli_rec;

                 inv_calculate_exp_date.reset_header_id;

                 inv_calculate_exp_date.get_lot_expiration_date(
                         p_mtli_lot_rec       => l_mtli_txn_rec
                        ,p_mti_trx_rec	       => l_mti_txn_rec
                        ,p_mtlt_lot_rec       => l_mtlt_txn_rec
                        ,p_mmtt_trx_rec	    => l_mmtt_txn_rec
                        ,p_table		          => 1
                        ,x_lot_expiration_date => l_lot_expiration_date
                        ,x_return_status      => l_return_status);

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
                    print_debug('l_lot_expiration_date (1) '||l_lot_expiration_date, 9);
                 END IF;
                 p_lot_rec.expiration_date := l_lot_expiration_date;

              ELSIF l_mmtt_txn_id <> -1 AND l_mtlt_txn_id <> '-1' THEN

                 OPEN cur_get_mmtt_rec (l_mmtt_txn_id);
                 FETCH cur_get_mmtt_rec INTO l_mmtt_txn_rec;
                 CLOSE cur_get_mmtt_rec;

                 OPEN cur_get_mtlt_rec (l_mtlt_txn_id);
                 FETCH cur_get_mtlt_rec INTO l_mtlt_txn_rec;
                 CLOSE cur_get_mtlt_rec;

                 inv_calculate_exp_date.get_lot_expiration_date(
                         p_mtli_lot_rec       => l_mtli_txn_rec
                        ,p_mti_trx_rec	       => l_mti_txn_rec
                        ,p_mtlt_lot_rec       => l_mtlt_txn_rec
                        ,p_mmtt_trx_rec	    => l_mmtt_txn_rec
                        ,p_table		          => 2
                        ,x_lot_expiration_date => l_lot_expiration_date
                        ,x_return_status      => l_return_status);

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
                    print_debug('l_lot_expiration_date (2) '||l_lot_expiration_date, 9);
                 END IF;
                 p_lot_rec.expiration_date := l_lot_expiration_date;

              ELSE
                 p_lot_rec.expiration_date := p_lot_rec.origination_date + l_get_dft_attr_rec.shelf_life_days;
              END IF;
          -- nsinghi bug 5209065 END
          END IF;

          /* Retest Date */
          IF p_lot_rec.retest_date IS NULL THEN
             p_lot_rec.retest_date := p_lot_rec.origination_date + l_get_dft_attr_rec.retest_interval;
          END IF;

          /* Shelf Life Code */
          IF NVL (l_get_dft_attr_rec.shelf_life_code, -1)  <> 1 THEN    -- No shelf life control

             /* Expiration Action Date */
              IF p_lot_rec.expiration_action_date IS NULL THEN
                 p_lot_rec.expiration_action_date := p_lot_rec.expiration_date + l_get_dft_attr_rec.expiration_action_interval ;
              END IF;

             /* Expiration Action Code */
              IF p_lot_rec.expiration_action_code IS NULL THEN
                 p_lot_rec.expiration_action_code := l_get_dft_attr_rec.expiration_action_code ;
              END IF;

          END IF; /* Shelf Life Code */

          /* Hold Date */
          IF p_lot_rec.hold_date IS NULL THEN
             p_lot_rec.hold_date := p_lot_rec.origination_date + l_get_dft_attr_rec.hold_days;
          END IF;

          /* Maturity Date */
          IF p_lot_rec.maturity_date IS NULL THEN
             p_lot_rec.maturity_date := p_lot_rec.origination_date + l_get_dft_attr_rec.maturity_days;
          END IF;

       END IF ;     /* Origination Date */

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In Set_Msi_Default_Attr, No data found ' || SQLERRM, 9);
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In Set_Msi_Default_Attr, g_exc_error ' || SQLERRM, 9);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In Set_Msi_Default_Attr, g_exc_unexpected_error ' || SQLERRM, 9);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In Set_Msi_Default_Attr, Others ' || SQLERRM, 9);

  END Set_Msi_Default_Attr ;


  PROCEDURE Validate_Lot_Attributes(
                    x_return_status           OUT    NOCOPY VARCHAR2
                  , x_msg_count               OUT    NOCOPY NUMBER
                  , x_msg_data                OUT    NOCOPY VARCHAR2
                  , x_lot_rec                 IN OUT NOCOPY Mtl_Lot_Numbers%ROWTYPE
                  , p_source                  IN     NUMBER
    )  IS

   /* Shelf life code constants */
   no_shelf_life_control CONSTANT NUMBER                                     := 1;
   item_shelf_life_days  CONSTANT NUMBER                                     := 2;
   user_defined_exp_date CONSTANT NUMBER                                     := 4;
   l_mtl_gen_obj_no        NUMBER ;

   /*Program variables declaration */
   l_lot_control_code             mtl_system_items_b.lot_control_code%TYPE;
   l_chk_lot_uniqueness           BOOLEAN;
   l_shelf_life_days              mtl_system_items.shelf_life_days%TYPE;
   l_shelf_life_code              mtl_system_items.shelf_life_code%TYPE;
   l_expiration_date              mtl_lot_numbers.expiration_date%TYPE;
   l_wms_installed                VARCHAR2(5);
   l_lot_number_uniqueness        NUMBER;
   l_return_status                VARCHAR2(1);
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2(3000);
   l_status                       NUMBER;
   l_lot_attribute_category       mtl_lot_numbers.lot_attribute_category%TYPE;
   l_inv_attributes_tbl           inv_lot_api_pub.char_tbl;
   l_c_attributes_tbl             inv_lot_api_pub.char_tbl;
   l_n_attributes_tbl             inv_lot_api_pub.number_tbl;
   l_d_attributes_tbl             inv_lot_api_pub.date_tbl;

   /* Index variables for looping through the input tables*/
   l_attr_index                   NUMBER;
   l_c_attr_index                 NUMBER;
   l_n_attr_index                 NUMBER;
   l_d_attr_index                 NUMBER;

   p_attributes_tbl               inv_lot_api_pub.char_tbl ;
   p_c_attributes_tbl             inv_lot_api_pub.char_tbl ;
   p_n_attributes_tbl             inv_lot_api_pub.number_tbl ;
   p_d_attributes_tbl             inv_lot_api_pub.date_tbl ;

   p_inventory_item_id     	  mtl_lot_numbers.inventory_item_id%TYPE  ;
   p_organization_id       	  mtl_lot_numbers.organization_id%TYPE ;
   p_lot_number            	  mtl_lot_numbers.lot_number%TYPE ;
   p_expiration_date       	  mtl_lot_numbers.expiration_date%TYPE ;
   p_disable_flag          	  mtl_lot_numbers.disable_flag%TYPE ;
   p_attribute_category    	  mtl_lot_numbers.attribute_category%TYPE ;
   p_lot_attribute_category	  mtl_lot_numbers.lot_attribute_category%TYPE ;
   p_grade_code            	  mtl_lot_numbers.grade_code%TYPE ;
   p_origination_date      	  mtl_lot_numbers.origination_date%TYPE ;
   p_date_code             	  mtl_lot_numbers.date_code%TYPE ;
   p_status_id             	  mtl_lot_numbers.status_id%TYPE ;
   p_change_date           	  mtl_lot_numbers.change_date%TYPE ;
   p_age                   	  mtl_lot_numbers.age%TYPE ;
   p_retest_date           	  mtl_lot_numbers.retest_date%TYPE ;
   p_maturity_date         	  mtl_lot_numbers.maturity_date%TYPE ;
   p_item_size             	  mtl_lot_numbers.item_size%TYPE ;
   p_color                 	  mtl_lot_numbers.color%TYPE ;
   p_volume                	  mtl_lot_numbers.volume%TYPE ;
   p_volume_uom            	  mtl_lot_numbers.volume_uom%TYPE ;
   p_place_of_origin       	  mtl_lot_numbers.place_of_origin%TYPE ;
   p_best_by_date          	  mtl_lot_numbers.best_by_date%TYPE ;
   p_length                	  mtl_lot_numbers.length%TYPE ;
   p_length_uom            	  mtl_lot_numbers.length_uom%TYPE ;
   p_recycled_content      	  mtl_lot_numbers.recycled_content%TYPE ;
   p_thickness             	  mtl_lot_numbers.thickness%TYPE ;
   p_thickness_uom         	  mtl_lot_numbers.thickness_uom%TYPE ;
   p_width                 	  mtl_lot_numbers.width%TYPE ;
   p_width_uom             	  mtl_lot_numbers.width_uom%TYPE ;
   p_territory_code        	  mtl_lot_numbers.territory_code%TYPE ;
   p_supplier_lot_number   	  mtl_lot_numbers.supplier_lot_number%TYPE ;
   p_vendor_name           	  mtl_lot_numbers.vendor_name%TYPE ;
   p_parent_lot_number		  mtl_lot_numbers.parent_lot_number%TYPE ;
   p_origination_type		  mtl_lot_numbers.origination_type%TYPE ;
   p_expiration_action_code	  mtl_lot_numbers.expiration_action_code%TYPE ;
   p_expiration_action_date	  mtl_lot_numbers.expiration_action_date%TYPE ;
   p_hold_date			  mtl_lot_numbers.hold_date%TYPE ;

   l_lot_cont               BOOLEAN   ;
   l_child_lot_cont         BOOLEAN   ;
   l_lot_status_flag        VARCHAR2(1) ;
   l_def_lot_status         NUMBER ;

  BEGIN
    SAVEPOINT inv_val_lot;
    x_return_status  := fnd_api.g_ret_sts_success;

    p_inventory_item_id     	     :=     x_lot_rec.inventory_item_id  ;
    p_organization_id       	     :=     x_lot_rec.organization_id ;
    p_lot_number            	     :=     x_lot_rec.lot_number ;
    p_parent_lot_number		     :=     x_lot_rec.parent_lot_number ;
    p_grade_code            	     :=     x_lot_rec.grade_code ;
    p_expiration_date       	     :=     x_lot_rec.expiration_date ;
    p_origination_type		     :=     x_lot_rec.origination_type ;
    p_origination_date      	     :=     x_lot_rec.origination_date ;
    p_expiration_action_code	     :=     x_lot_rec.expiration_action_code ;
    p_expiration_action_date	     :=     x_lot_rec.expiration_action_date ;
    p_hold_date			     :=     x_lot_rec.hold_date ;
    p_retest_date           	     :=     x_lot_rec.retest_date ;
    p_maturity_date         	     :=     x_lot_rec.maturity_date ;
    p_disable_flag          	     :=     x_lot_rec.disable_flag ;
    p_attribute_category    	     :=     x_lot_rec.attribute_category ;
    p_lot_attribute_category	     :=     x_lot_rec.lot_attribute_category ;
    p_date_code             	     :=     x_lot_rec.date_code ;
    p_status_id             	     :=     x_lot_rec.status_id ;
    p_change_date           	     :=     x_lot_rec.change_date ;
    p_age                   	     :=     x_lot_rec.age ;
    p_item_size             	     :=     x_lot_rec.item_size ;
    p_color                 	     :=     x_lot_rec.color ;
    p_volume                	     :=     x_lot_rec.volume ;
    p_volume_uom            	     :=     x_lot_rec.volume_uom ;
    p_place_of_origin       	     :=     x_lot_rec.place_of_origin ;
    p_best_by_date          	     :=     x_lot_rec.best_by_date ;
    p_length                	     :=     x_lot_rec.length ;
    p_length_uom            	     :=     x_lot_rec.length_uom ;
    p_recycled_content      	     :=     x_lot_rec.recycled_content ;
    p_thickness             	     :=     x_lot_rec.thickness ;
    p_thickness_uom         	     :=     x_lot_rec.thickness_uom ;
    p_width                 	     :=     x_lot_rec.width ;
    p_width_uom             	     :=     x_lot_rec.width_uom ;
    p_territory_code        	     :=     x_lot_rec.territory_code ;
    p_supplier_lot_number   	     :=     x_lot_rec.supplier_lot_number ;
    p_vendor_name           	     :=     x_lot_rec.vendor_name ;
    p_attributes_tbl(1)              :=     x_lot_rec.attribute1     ;
    p_attributes_tbl(2)              :=     x_lot_rec.attribute2     ;
    p_attributes_tbl(3)              :=     x_lot_rec.attribute3     ;
    p_attributes_tbl(4)              :=     x_lot_rec.attribute4     ;
    p_attributes_tbl(5)              :=     x_lot_rec.attribute5     ;
    p_attributes_tbl(6)              :=     x_lot_rec.attribute6     ;
    p_attributes_tbl(7)              :=     x_lot_rec.attribute7     ;
    p_attributes_tbl(8)              :=     x_lot_rec.attribute8     ;
    p_attributes_tbl(9)              :=     x_lot_rec.attribute9     ;
    p_attributes_tbl(10)             :=     x_lot_rec.attribute10    ;
    p_attributes_tbl(11)             :=     x_lot_rec.attribute11    ;
    p_attributes_tbl(12)             :=     x_lot_rec.attribute12    ;
    p_attributes_tbl(13)             :=     x_lot_rec.attribute13    ;
    p_attributes_tbl(14)             :=     x_lot_rec.attribute14    ;
    p_attributes_tbl(15)             :=     x_lot_rec.attribute15    ;
    p_c_attributes_tbl(1)            :=     x_lot_rec.c_attribute1   ;
    p_c_attributes_tbl(2)            :=     x_lot_rec.c_attribute2   ;
    p_c_attributes_tbl(3)            :=     x_lot_rec.c_attribute3   ;
    p_c_attributes_tbl(4)            :=     x_lot_rec.c_attribute4   ;
    p_c_attributes_tbl(5)            :=     x_lot_rec.c_attribute5   ;
    p_c_attributes_tbl(6)            :=     x_lot_rec.c_attribute6   ;
    p_c_attributes_tbl(7)            :=     x_lot_rec.c_attribute7   ;
    p_c_attributes_tbl(8)            :=     x_lot_rec.c_attribute8   ;
    p_c_attributes_tbl(9)            :=     x_lot_rec.c_attribute9   ;
    p_c_attributes_tbl(10)           :=     x_lot_rec.c_attribute10  ;
    p_c_attributes_tbl(11)           :=     x_lot_rec.c_attribute11  ;
    p_c_attributes_tbl(12)           :=     x_lot_rec.c_attribute12  ;
    p_c_attributes_tbl(13)           :=     x_lot_rec.c_attribute13  ;
    p_c_attributes_tbl(14)           :=     x_lot_rec.c_attribute14  ;
    p_c_attributes_tbl(15)           :=     x_lot_rec.c_attribute15  ;
    p_c_attributes_tbl(16)           :=     x_lot_rec.c_attribute16  ;
    p_c_attributes_tbl(17)           :=     x_lot_rec.c_attribute17  ;
    p_c_attributes_tbl(18)           :=     x_lot_rec.c_attribute18  ;
    p_c_attributes_tbl(19)           :=     x_lot_rec.c_attribute19  ;
    p_c_attributes_tbl(20)           :=     x_lot_rec.c_attribute20  ;
    p_n_attributes_tbl(1)            :=     x_lot_rec.n_attribute1   ;
    p_n_attributes_tbl(2)            :=     x_lot_rec.n_attribute2   ;
    p_n_attributes_tbl(3)            :=     x_lot_rec.n_attribute3   ;
    p_n_attributes_tbl(4)            :=     x_lot_rec.n_attribute4   ;
    p_n_attributes_tbl(5)            :=     x_lot_rec.n_attribute5   ;
    p_n_attributes_tbl(6)            :=     x_lot_rec.n_attribute6   ;
    p_n_attributes_tbl(7)            :=     x_lot_rec.n_attribute7   ;
    p_n_attributes_tbl(8)            :=     x_lot_rec.n_attribute8   ;
    p_n_attributes_tbl(9)            :=     x_lot_rec.n_attribute9   ;
    p_n_attributes_tbl(10)           :=     x_lot_rec.n_attribute10  ;
    p_d_attributes_tbl(1)            :=     x_lot_rec.d_attribute1   ;
    p_d_attributes_tbl(2)            :=     x_lot_rec.d_attribute2   ;
    p_d_attributes_tbl(3)            :=     x_lot_rec.d_attribute3   ;
    p_d_attributes_tbl(4)            :=     x_lot_rec.d_attribute4   ;
    p_d_attributes_tbl(5)            :=     x_lot_rec.d_attribute5   ;
    p_d_attributes_tbl(6)            :=     x_lot_rec.d_attribute6   ;
    p_d_attributes_tbl(7)            :=     x_lot_rec.d_attribute7   ;
    p_d_attributes_tbl(8)            :=     x_lot_rec.d_attribute8   ;
    p_d_attributes_tbl(9)            :=     x_lot_rec.d_attribute9   ;
    p_d_attributes_tbl(10)           :=     x_lot_rec.d_attribute10  ;

    -- Populate the set of local variables as mentioned in the previous point.

    IF g_debug = 1 THEN
      print_debug(p_err_msg=>'Start Validate_Lot_Attributes', p_level=>9);
      print_debug(p_err_msg => 'The value of the input parametsrs are :', p_level => 9);
      print_debug(p_err_msg => 'The value of the INVENTORY_ITEM_ID : ' || p_inventory_item_id, p_level => 9);
      print_debug(p_err_msg => 'The value of ORGANIZATION_ID :' || p_organization_id, p_level => 9);
      print_debug(p_err_msg => 'The value of  LOT_NUMBER :' || p_lot_number, p_level => 9);
      print_debug(p_err_msg => 'The value of the EXPIRATION_DATE :' || p_expiration_date, p_level => 9);
      print_debug(p_err_msg => 'The value of the DISABLE_FLAG :' || p_disable_flag, p_level => 9);
      print_debug(p_err_msg => 'The value of the ATTRIBUTE_CATEGORY :' || p_attribute_category, p_level => 9);
      print_debug(p_err_msg => 'The value of the LOT_ATTRIBUTE_CATEGORY :' || p_lot_attribute_category, p_level => 9);
      print_debug(p_err_msg => 'The value of the GRADE_CODE :' || p_grade_code, p_level => 9);
      print_debug(p_err_msg => 'The value of the ORIGINATION_DATE :' || p_origination_date, p_level => 9);
      print_debug(p_err_msg => 'The value of the ORIGINATION_TYPE :' || p_origination_type, p_level => 9);
      print_debug(p_err_msg => 'The value of the DATE_CODE :' || p_date_code, p_level => 9);
      print_debug(p_err_msg => 'The value of the STATUS_ID :' || p_status_id, p_level => 9);
      print_debug(p_err_msg => 'The value of the CHANGE_DATE :' || p_change_date, p_level => 9);
      print_debug(p_err_msg => 'The value of the AGE :' || p_age, p_level => 9);
      print_debug(p_err_msg => 'The value of the RETEST_DATE :' || p_retest_date, p_level => 9);
      print_debug(p_err_msg => 'The value of the MATURITY_DATE :' || p_maturity_date, p_level => 9);
      print_debug(p_err_msg => 'The value of the ITEM_SIZE :' || p_item_size, p_level => 9);
      print_debug(p_err_msg => 'The value of COLOR :' || p_color, p_level => 9);
      print_debug(p_err_msg => 'The value of VOLUME :' || p_volume, p_level => 9);
      print_debug(p_err_msg => 'The value of VOLUME_UOM :' || p_volume_uom, p_level => 9);
      print_debug(p_err_msg => 'The value of PLACE_OF_ORIGIN :' || p_place_of_origin, p_level => 9);
      print_debug(p_err_msg => 'The value of BEST_BY_DATE :' || p_best_by_date, p_level => 9);
      print_debug(p_err_msg => 'The value of LENGTH :' || p_length, p_level => 9);
      print_debug(p_err_msg => 'The value of LENGTH_UOM:' || p_length_uom, p_level => 9);
      print_debug(p_err_msg => 'The value of RECYCLED_CONTENT :' || p_recycled_content, p_level => 9);
      print_debug(p_err_msg => 'The value of THICKNESS :' || p_thickness, p_level => 9);
      print_debug(p_err_msg => 'The value of THICKNESS_UOM :' || p_thickness_uom, p_level => 9);
      print_debug(p_err_msg => 'The value of WIDTH  :' || p_width, p_level => 9);
      print_debug(p_err_msg => 'The value of WIDTH_UOM :' || p_width_uom, p_level => 9);
      print_debug(p_err_msg => 'The value of Territory Code :' || p_territory_code, p_level => 9);
      print_debug(p_err_msg => 'The value of VENDOR_NAME :' || p_vendor_name, p_level => 9);
      print_debug(p_err_msg => 'The value of SUPPLIER_LOT_NUMBER :' || p_supplier_lot_number, p_level => 9);
      print_debug(p_err_msg => 'The value of P_SOURCE :' || p_source, p_level => 9);
    END IF;


/******************* START Item  validation ********************/

   l_lot_cont        := FALSE ;
   l_child_lot_cont  := FALSE ;

   check_item_attributes
       (
              x_return_status          =>  l_return_status
            , x_msg_count              =>  l_msg_count
            , x_msg_data               =>  l_msg_data
            , x_lot_cont               =>  l_lot_cont
            , x_child_lot_cont         =>  l_child_lot_cont
            , p_inventory_item_id      =>  p_inventory_item_id
            , p_organization_id        =>  p_organization_id
         )   ;

     IF g_debug = 1 THEN
         print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes return ' || l_return_status, 9);
     END IF;

     IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF g_debug = 1 THEN
            print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes has failed with error', 9);
        END IF;
        FND_MESSAGE.SET_NAME('INV', 'INV_PROGRAM_ERROR') ;
        FND_MESSAGE.SET_TOKEN('PROG_NAME','Inv_lot_api_pkg.Check_Item_Attributes');
        FND_MSG_PUB.ADD;
        RAISE fnd_api.g_exc_error;
     END IF;

     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         IF g_debug = 1 THEN
            print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes has failed with a Unexpected exception', 9);
         END IF;
         FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
         FND_MESSAGE.SET_TOKEN('PROG_NAME','Inv_lot_api_pkg.Check_Item_Attributes');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     IF (l_lot_cont = FALSE) THEN
        IF g_debug = 1 THEN
           print_debug(' Item is not lot controlled ', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_NO_LOT_CONTROL');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
     END IF ;

     IF (l_child_lot_cont = FALSE AND p_parent_lot_number IS NOT NULL) THEN

        IF g_debug = 1 THEN
           print_debug(' Item is not Child lot controlled ', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_ITEM_CLOT_DISABLE_EXP');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
     END IF ;
   /******************* End Item validation  ********************/


      l_expiration_date  := p_expiration_date ;

    /*We should not be validating for expiration date for isfm as Lot is not created*/
    IF p_source NOT IN(osfm_form_no_validate, osfm_open_interface, osfm_form_validate) THEN
       /* Check for the shelf life code for the inventory item passed.One message to be added  */
       BEGIN
          SELECT   shelf_life_days
                  , shelf_life_code
            INTO  l_shelf_life_days
                  , l_shelf_life_code
            FROM  mtl_system_items
           WHERE  inventory_item_id = p_inventory_item_id
             AND  organization_id   = p_organization_id;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             fnd_message.set_name('INV', 'INV_SHELF_LIFE_ERROR');
             fnd_message.set_token('INV', 'ITEM');
             fnd_msg_pub.ADD;

             IF g_debug = 1 THEN
                print_debug('Unable to fetch shelf life code for the inventory item passed', 9);
             END IF;

            RAISE NO_DATA_FOUND;
       END;

       IF g_debug = 1 THEN
          print_debug('shelf life obtained successfully ', 9);
       END IF;

       /* We have to derive the  EXPIRATION_DATE based on the items shelf life code.
          Shelf life code can have the following values
          1 -No control
          2- Shelf Life Days
          4-User Defined.
          Two MESSAGE TO BE ADDED
       */

       IF l_shelf_life_code = item_shelf_life_days THEN
          IF g_debug = 1 THEN
             print_debug('Shelf_life code is of type ITEM_SHELF_LIFE_DAYS', 9);
          END IF;

          SELECT SYSDATE + l_shelf_life_days
             INTO l_expiration_date
             FROM DUAL;

          IF TRUNC(l_expiration_date) <> trunc(p_expiration_date) THEN
             fnd_message.set_name('INV', 'INV_EXP_DATE_NOT_CONSIDER');
             fnd_msg_pub.ADD;
             IF g_debug = 1 THEN
                print_debug('Expiration will not be considered for shelf_life code of type ITEM_SHELF_LIFE_DAYS', 9);
             END IF;
             RAISE  fnd_api.g_exc_error;
          END IF;


       ELSIF l_shelf_life_code = user_defined_exp_date THEN
          IF g_debug = 1 THEN
             print_debug('Shelf_life code is of type USER_DEFINED_EXP_DATE', 9);
          END IF;

          IF p_expiration_date IS NULL THEN
             fnd_message.set_name('INV', 'INV_LOT_EXPREQD');
             fnd_msg_pub.ADD;

             IF g_debug = 1 THEN
                print_debug('The value of expiration date is required ', 9);
             END IF;
             RAISE fnd_api.g_exc_error;

          ELSE
             l_expiration_date  := p_expiration_date;
          END IF;


         ELSE
            IF g_debug = 1 THEN
             print_debug('Shelf_life code is of type NO_SHELF_LIFE_CONTROL', 9);
          END IF;

          fnd_message.set_name('INV', 'INV_EXP_DATE_NOT_CONSIDER');
          fnd_msg_pub.ADD;
       END IF; /* l_shelf_life_code = item_shelf_life_days */
    END IF;  /*p_source NOT IN(OSFM_FORM,OSFM_OPEN_INTERFACE)*/


    IF G_WMS_INSTALLED IS NULL THEN
       IF (inv_install.adv_inv_installed(NULL) = TRUE) THEN
          G_wms_installed  := 'TRUE';
       ELSE
	  G_WMS_INSTALLED := 'FALSE';
       END IF;
    END IF;

    l_wms_installed := G_WMS_INSTALLED;

    IF l_wms_installed = 'TRUE' THEN
       INV_LOT_SEL_ATTR.GET_CONTEXT_CODE(l_lot_attribute_category, p_organization_id, p_inventory_item_id, 'Lot Attributes');


       IF p_lot_attribute_category IS NOT NULL AND
	 (nvl(l_lot_attribute_category, p_lot_attribute_category) <> p_lot_attribute_category) THEN
          FND_MESSAGE.SET_NAME('INV','INV_WRONG_CONTEXT');
          FND_MSG_PUB.ADD;
          RAISE  fnd_api.g_exc_error;
       END IF;
    END IF ;

    BEGIN
        SELECT  lot_status_enabled , default_lot_status_id
          INTO  l_lot_status_flag  , l_def_lot_status
          FROM  mtl_system_items
         WHERE  organization_id   =  p_organization_id
           AND  inventory_item_id =  p_inventory_item_id ;

        IF p_status_id IS NOT NULL THEN
           l_status        := p_status_id;
        ELSE
           IF l_lot_status_flag = 'Y' THEN
              l_status      :=   l_def_lot_status ;
           ELSE
              l_status     := NULL;
           END IF ;
        END IF;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       IF g_debug = 1 THEN
           print_debug('Unable to fetch status code for the inventory item passed', 9);
        END IF;
        RAISE NO_DATA_FOUND;
    END ;

    IF g_debug = 1 THEN
        print_debug('Calling validate_lot_Attr_in_param', 9);
    END IF;


    /* If the call is from a valid source as osfm form, no need to validate the data*/
    INV_LOT_API_PUB.VALIDATE_LOT_ATTR_IN_PARAM(
      x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_inventory_item_id          => p_inventory_item_id
    , p_organization_id            => p_organization_id
    , p_lot_number                 => p_lot_number
    , p_attribute_category         => p_attribute_category
    , p_lot_attribute_category     => nvl(l_lot_attribute_category, p_lot_attribute_category)
    , p_attributes_tbl             => p_attributes_tbl
    , p_c_attributes_tbl           => p_c_attributes_tbl
    , p_n_attributes_tbl           => p_n_attributes_tbl
    , p_d_attributes_tbl           => p_d_attributes_tbl
    , p_wms_is_installed           => l_wms_installed
    , p_source                     => p_source
    , p_disable_flag               => p_disable_flag
    , p_grade_code                 => p_grade_code
    , p_origination_date           => p_origination_date
    , p_date_code                  => p_date_code
    , p_change_date                => p_change_date
    , p_age                        => p_age
    , p_retest_date                => p_retest_date
    , p_maturity_date              => p_maturity_date
    , p_item_size                  => p_item_size
    , p_color                      => p_color
    , p_volume                     => p_volume
    , p_volume_uom                 => p_volume_uom
    , p_place_of_origin            => p_place_of_origin
    , p_best_by_date               => p_best_by_date
    , p_length                     => p_length
    , p_length_uom                 => p_length_uom
    , p_recycled_content           => p_recycled_content
    , p_thickness                  => p_thickness
    , p_thickness_uom              => p_thickness_uom
    , p_width                      => p_width
    , p_width_uom                  => p_width_uom
    , p_territory_code             => p_territory_code
    , p_supplier_lot_number        => p_supplier_lot_number
    , p_vendor_name                => p_vendor_name
    );


    IF g_debug = 1 THEN
        print_debug('Program VALIDATE_LOT_ATTR_IN_PARAM return ' || l_return_status, 9);
    END IF;
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      IF g_debug = 1 THEN
        print_debug('Program VALIDATE_LOT_ATTR_IN_PARAM has failed with a user defined exception', 9);
      END IF;
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      IF g_debug = 1 THEN
        print_debug('Program VALIDATE_LOT_ATTR_IN_PARAM has failed with a Unexpected exception', 9);
      END IF;
      FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
      FND_MESSAGE.SET_TOKEN('PROG_NAME','VALIDATE_LOT_ATTR_IN_PARAM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    Validate_Additional_Attr(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_inventory_item_id          => p_inventory_item_id
      , p_organization_id            => p_organization_id
      , p_lot_number                 => p_lot_number
      , p_retest_date                => p_retest_date
      , p_maturity_date              => p_maturity_date
      , p_source                     => p_source
      , p_grade_code                 => p_grade_code
      , p_origination_date           => p_origination_date
      , p_parent_lot_number          => p_parent_lot_number
      , p_origination_type           => p_origination_type
      , p_expiration_action_code     => p_expiration_action_code
      , p_expiration_action_date     => p_expiration_action_date
      , p_expiration_date            => p_expiration_date
      , p_hold_date	             => p_hold_date
    );

    IF g_debug = 1 THEN
        print_debug('Program VALIDATE_ADDITIONAL_ATTR return ' || l_return_status, 9);
    END IF;
    IF l_return_status = fnd_api.g_ret_sts_error THEN
      IF g_debug = 1 THEN
        print_debug('Program VALIDATE_ADDITIONAL_ATTR has failed with a user defined exception', 9);
      END IF;
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      IF g_debug = 1 THEN
        print_debug('Program VALIDATE_ADDITIONAL_ATTR has failed with a Unexpected exception', 9);
      END IF;
      FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
      FND_MESSAGE.SET_TOKEN('PROG_NAME','VALIDATE_ADDITIONAL_ATTR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    /* Fetch data from the input tabels and fill the appropriate records*/
    IF p_attributes_tbl.COUNT > 0 THEN
      l_inv_attributes_tbl  := p_attributes_tbl;
    END IF;

    IF p_c_attributes_tbl.COUNT > 0 THEN
      l_c_attributes_tbl  := p_c_attributes_tbl;
    END IF;

    IF p_n_attributes_tbl.COUNT > 0 THEN
      l_n_attributes_tbl  := p_n_attributes_tbl;
    END IF;

    IF p_d_attributes_tbl.COUNT > 0 THEN
      l_d_attributes_tbl  := p_d_attributes_tbl;
    END IF;

    FOR l_attr_index IN 1 .. 15 LOOP
      IF NOT l_inv_attributes_tbl.EXISTS(l_attr_index) THEN
        l_inv_attributes_tbl(l_attr_index)  := NULL;
      END IF;
    END LOOP;

    FOR l_c_attr_index IN 1 .. 20 LOOP
      IF NOT l_c_attributes_tbl.EXISTS(l_c_attr_index) THEN
        l_c_attributes_tbl(l_c_attr_index)  := NULL;
      END IF;
    END LOOP;

    FOR l_n_attr_index IN 1 .. 10 LOOP
      IF NOT l_n_attributes_tbl.EXISTS(l_n_attr_index) THEN
        l_n_attributes_tbl(l_n_attr_index)  := NULL;
      END IF;
    END LOOP;

    FOR l_d_attr_index IN 1 .. 10 LOOP
      IF NOT l_d_attributes_tbl.EXISTS(l_d_attr_index) THEN
        l_d_attributes_tbl(l_d_attr_index)  := NULL;
      END IF;
    END LOOP;


    IF( g_debug = 1 ) THEN
	print_debug('Populate OUT lot record parameter', 9);
    END IF;

  --  SELECT MTL_GEN_OBJECT_ID_S.NEXTVAL INTO l_mtl_gen_obj_no FROM dual;

    -- Replace the INSERT INTO mtl_lot_numbers statement with population of OUT lot record parameter.

    x_lot_rec.inventory_item_id             :=    p_inventory_item_id;
    x_lot_rec.organization_id               :=    p_organization_id;
    x_lot_rec.lot_number                    :=    p_lot_number;
    x_lot_rec.expiration_date               :=    l_expiration_date;
    x_lot_rec.disable_flag                  :=    p_disable_flag;
    x_lot_rec.attribute_category            :=    p_attribute_category;
    x_lot_rec.lot_attribute_category        :=    nvl(L_lot_attribute_category, p_lot_attribute_category);
    x_lot_rec.attribute1                    :=    l_inv_attributes_tbl(1);
    x_lot_rec.attribute2                    :=    l_inv_attributes_tbl(2);
    x_lot_rec.attribute3                    :=    l_inv_attributes_tbl(3);
    x_lot_rec.attribute4                    :=    l_inv_attributes_tbl(4);
    x_lot_rec.attribute5                    :=    l_inv_attributes_tbl(5);
    x_lot_rec.attribute6                    :=    l_inv_attributes_tbl(6);
    x_lot_rec.attribute7                    :=    l_inv_attributes_tbl(7);
    x_lot_rec.attribute8                    :=    l_inv_attributes_tbl(8);
    x_lot_rec.attribute9                    :=    l_inv_attributes_tbl(9);
    x_lot_rec.attribute10                   :=    l_inv_attributes_tbl(10);
    x_lot_rec.attribute11                   :=    l_inv_attributes_tbl(11);
    x_lot_rec.attribute12                   :=    l_inv_attributes_tbl(12);
    x_lot_rec.attribute13                   :=    l_inv_attributes_tbl(13);
    x_lot_rec.attribute14                   :=    l_inv_attributes_tbl(14);
    x_lot_rec.attribute15                   :=    l_inv_attributes_tbl(15);
    x_lot_rec.c_attribute1                  :=    l_c_attributes_tbl(1);
    x_lot_rec.c_attribute2                  :=    l_c_attributes_tbl(2);
    x_lot_rec.c_attribute3                  :=    l_c_attributes_tbl(3);
    x_lot_rec.c_attribute4                  :=    l_c_attributes_tbl(4);
    x_lot_rec.c_attribute5                  :=    l_c_attributes_tbl(5);
    x_lot_rec.c_attribute6                  :=    l_c_attributes_tbl(6);
    x_lot_rec.c_attribute7                  :=    l_c_attributes_tbl(7);
    x_lot_rec.c_attribute8                  :=    l_c_attributes_tbl(8);
    x_lot_rec.c_attribute9                  :=    l_c_attributes_tbl(9);
    x_lot_rec.c_attribute10                 :=    l_c_attributes_tbl(10);
    x_lot_rec.c_attribute11                 :=    l_c_attributes_tbl(11);
    x_lot_rec.c_attribute12                 :=    l_c_attributes_tbl(12);
    x_lot_rec.c_attribute13                 :=    l_c_attributes_tbl(13);
    x_lot_rec.c_attribute14                 :=    l_c_attributes_tbl(14);
    x_lot_rec.c_attribute15                 :=    l_c_attributes_tbl(15);
    x_lot_rec.c_attribute16                 :=    l_c_attributes_tbl(16);
    x_lot_rec.c_attribute17                 :=    l_c_attributes_tbl(17);
    x_lot_rec.c_attribute18                 :=    l_c_attributes_tbl(18);
    x_lot_rec.c_attribute19                 :=    l_c_attributes_tbl(19);
    x_lot_rec.c_attribute20                 :=    l_c_attributes_tbl(20);
    x_lot_rec.n_attribute1                  :=    l_n_attributes_tbl(1);
    x_lot_rec.n_attribute2                  :=    l_n_attributes_tbl(2);
    x_lot_rec.n_attribute3                  :=    l_n_attributes_tbl(3);
    x_lot_rec.n_attribute4                  :=    l_n_attributes_tbl(4);
    x_lot_rec.n_attribute5                  :=    l_n_attributes_tbl(5);
    x_lot_rec.n_attribute6                  :=    l_n_attributes_tbl(6);
    x_lot_rec.n_attribute7                  :=    l_n_attributes_tbl(7);
    x_lot_rec.n_attribute8                  :=    l_n_attributes_tbl(8);
    x_lot_rec.n_attribute9                  :=    l_n_attributes_tbl(9);
    x_lot_rec.n_attribute10                 :=    l_n_attributes_tbl(10);
    x_lot_rec.d_attribute1                  :=    l_d_attributes_tbl(1);
    x_lot_rec.d_attribute2                  :=    l_d_attributes_tbl(2);
    x_lot_rec.d_attribute3                  :=    l_d_attributes_tbl(3);
    x_lot_rec.d_attribute4                  :=    l_d_attributes_tbl(4);
    x_lot_rec.d_attribute5                  :=    l_d_attributes_tbl(5);
    x_lot_rec.d_attribute6                  :=    l_d_attributes_tbl(6);
    x_lot_rec.d_attribute7                  :=    l_d_attributes_tbl(7);
    x_lot_rec.d_attribute8                  :=    l_d_attributes_tbl(8);
    x_lot_rec.d_attribute9                  :=    l_d_attributes_tbl(9);
    x_lot_rec.d_attribute10                 :=    l_d_attributes_tbl(10);
    x_lot_rec.grade_code                    :=    p_grade_code;
    x_lot_rec.origination_date              :=    p_origination_date;
    x_lot_rec.date_code                     :=    p_date_code;
    x_lot_rec.status_id                     :=    l_status;
    x_lot_rec.change_date                   :=    p_change_date;
    x_lot_rec.age                           :=    p_age;
    x_lot_rec.retest_date                   :=    p_retest_date;
    x_lot_rec.maturity_date                 :=    p_maturity_date;
    x_lot_rec.item_size                     :=    p_item_size;
    x_lot_rec.color                         :=    p_color;
    x_lot_rec.volume                        :=    p_volume;
    x_lot_rec.volume_uom                    :=    p_volume_uom;
    x_lot_rec.place_of_origin               :=    p_place_of_origin;
    x_lot_rec.best_by_date                  :=    p_best_by_date;
    x_lot_rec.LENGTH                        :=    p_length;
    x_lot_rec.length_uom                    :=    p_length_uom;
    x_lot_rec.recycled_content              :=    p_recycled_content;
    x_lot_rec.thickness                     :=    p_thickness;
    x_lot_rec.thickness_uom                 :=    p_thickness_uom;
    x_lot_rec.width                         :=    p_width;
    x_lot_rec.width_uom                     :=    p_width_uom;
    x_lot_rec.territory_code                :=    p_territory_code;
    x_lot_rec.supplier_lot_number           :=    p_supplier_lot_number;
    x_lot_rec.vendor_name                   :=    p_vendor_name;
    x_lot_rec.creation_date                 :=    SYSDATE;
    x_lot_rec.created_by                    :=    fnd_global.user_id;
    x_lot_rec.last_update_date              :=    SYSDATE;
    x_lot_rec.last_updated_by               :=    fnd_global.user_id;
    x_lot_rec.parent_lot_number             :=    p_parent_lot_number;
    x_lot_rec.origination_type              :=    p_origination_type;
    x_lot_rec.expiration_action_code        :=    p_expiration_action_code;
    x_lot_rec.expiration_action_date        :=    p_expiration_action_date;
    x_lot_rec.hold_date                     :=    p_hold_date;

    print_debug('End of the program Validate_Lot_Attributes. Program has completed successfully ', 9);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO inv_val_lot ;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In No data found Validate_Lot_Attributes ' || SQLERRM, 9);
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO inv_val_lot ;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In g_exc_error Validate_Lot_Attributes ' || SQLERRM, 9);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO inv_val_lot ;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In g_exc_unexpected_error Validate_Lot_Attributes ' || SQLERRM, 9);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO inv_val_lot ;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In others Validate_Lot_Attributes ' || SQLERRM, 9);

  END Validate_Lot_Attributes ;


  PROCEDURE Validate_Additional_Attr(
       x_return_status          OUT    NOCOPY VARCHAR2
     , x_msg_count              OUT    NOCOPY NUMBER
     , x_msg_data               OUT    NOCOPY VARCHAR2
     , p_inventory_item_id      IN     NUMBER
     , p_organization_id        IN     NUMBER
     , p_lot_number             IN     VARCHAR2
     , p_source                 IN     NUMBER
     , p_grade_code             IN     VARCHAR2
     , p_retest_date            IN     DATE
     , p_maturity_date          IN     DATE
     , p_parent_lot_number      IN     VARCHAR2
     , p_origination_date       IN     DATE
     , p_origination_type       IN     NUMBER
     , p_expiration_action_code IN     VARCHAR2
     , p_expiration_action_date IN     DATE
     , p_expiration_date        IN     DATE
     , p_hold_date	        IN     DATE
     )  IS

  /* Parent lot validation logic  */
   CURSOR  c_get_lot_record IS
   SELECT  *
     FROM  mtl_lot_numbers
    WHERE  lot_number        = p_lot_number
      AND  inventory_item_id = p_inventory_item_id
      AND  organization_id   = p_organization_id;

  l_lot_record    c_get_lot_record%ROWTYPE;

   CURSOR  c_get_item_info IS
   SELECT  *
     FROM  mtl_system_items
    WHERE  organization_id   = p_organization_id
      AND  inventory_item_id = p_inventory_item_id ;

  l_item_info    c_get_item_info%ROWTYPE;


  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(3000);
  l_api_version          NUMBER;
  l_init_msg_list        VARCHAR2(100);
  l_commit               VARCHAR2(100);
  res                    BOOLEAN  ;

  l_lot_cont               BOOLEAN   ;
  l_child_lot_cont         BOOLEAN   ;

  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    SAVEPOINT val_lot_attr_information;

    l_api_version              := 1.0;
    l_init_msg_list            := fnd_api.g_false;
    l_commit                   := fnd_api.g_false;

 /******************* START Item  validation ********************/

   l_lot_cont        := FALSE ;
   l_child_lot_cont  := FALSE ;

   check_item_attributes
        (
              x_return_status          =>  l_return_status
            , x_msg_count              =>  l_msg_count
            , x_msg_data               =>  l_msg_data
            , x_lot_cont               =>  l_lot_cont
            , x_child_lot_cont         =>  l_child_lot_cont
            , p_inventory_item_id      =>  p_inventory_item_id
            , p_organization_id        =>  p_organization_id
          )   ;

       IF g_debug = 1 THEN
           print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes return ' || l_return_status, 9);
       END IF;

       IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF g_debug = 1 THEN
              print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes has failed with error', 9);
          END IF;
          FND_MESSAGE.SET_NAME('INV', 'INV_PROGRAM_ERROR') ;
          FND_MESSAGE.SET_TOKEN('PROG_NAME','Inv_lot_api_pkg.Check_Item_Attributes');
          FND_MSG_PUB.ADD;
          RAISE fnd_api.g_exc_error;
       END IF;

       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
           IF g_debug = 1 THEN
              print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes has failed with a Unexpected exception', 9);
           END IF;
           FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
           FND_MESSAGE.SET_TOKEN('PROG_NAME','Inv_lot_api_pkg.Check_Item_Attributes');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_unexpected_error;
       END IF;

     IF (l_lot_cont = FALSE) THEN
        IF g_debug = 1 THEN
           print_debug(' Item is not lot controlled ', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_NO_LOT_CONTROL');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
     END IF ;

     IF (l_child_lot_cont = FALSE AND p_parent_lot_number IS NOT NULL) THEN

        IF g_debug = 1 THEN
           print_debug(' Item is not Child lot controlled ', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_ITEM_CLOT_DISABLE_EXP');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
     END IF ;
   /******************* End Item validation  ********************/

    /******************* START Parent lot validation logic ********************/
    /* Get Lot Information*/
    OPEN c_get_lot_record ;
    FETCH c_get_lot_record INTO l_lot_record;

    /* Check Lot */
    IF c_get_lot_record%NOTFOUND THEN
    /* New child Lot*/
      CLOSE c_get_lot_record;
      /* Check Child Lot Naming convention */
       IF (p_parent_lot_number IS NOT NULL) THEN
           Inv_lot_api_pub.validate_child_lot (
                 x_return_status          =>    l_return_status
               , x_msg_count              =>    l_msg_count
               , x_msg_data               =>    l_msg_data
               , p_api_version            =>    l_api_version
               , p_init_msg_list          =>    l_init_msg_list
               , p_commit                 =>    l_commit
               , p_organization_id        =>    p_organization_id
               , p_inventory_item_id      =>    p_inventory_item_id
               , p_parent_lot_number      =>    p_parent_lot_number
               , p_child_lot_number       =>    p_lot_number
              )  ;

              IF g_debug = 1 THEN
                  print_debug('Program Inv_lot_api_pub.VALIDATE_CHILD_LOT return ' || l_return_status, 9);
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  IF g_debug = 1 THEN
                     print_debug('Program Inv_lot_api_pub.VALIDATE_CHILD_LOT has failed with a Unexpected exception', 9);
                  END IF;
                  FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                  FND_MESSAGE.SET_TOKEN('PROG_NAME','Inv_lot_api_pub.VALIDATE_CHILD_LOT');
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                 IF g_debug = 1 THEN
                    print_debug('Invalid child lot Naming convention', 9);
                 END IF;

                 fnd_message.set_name('INV', 'INV_INVALID_CHILD_LOT_EXP') ;
                 fnd_msg_pub.ADD;
                 RAISE fnd_api.g_exc_error;
              END IF;
         END IF ;  -- parent_lot check
    ELSE
      CLOSE c_get_lot_record;
      /* Check Parent Lot, then default the correct Parent Lot */
      IF l_lot_record.parent_lot_number IS NOT NULL THEN
         IF l_lot_record.parent_lot_number <> p_parent_lot_number THEN
            IF g_debug = 1 THEN
              print_debug('Invalid relationship between parent and child lots', 9);
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_PARENT_LOT_EXP') ;
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
    END IF;  /* Check Lot */
    /******************* END Parent lot validation logic ********************/


    /******************* START Origination Type validation logic ********************/

         res := FALSE ;
         res :=  Inv_Lot_Attr_Pub.validate_origination_type (
                          p_origination_type	=>  p_origination_type
                        , x_return_status 	=>  l_return_status
                        , x_msg_count 		=>  l_msg_count
                        , x_msg_data 		=>  l_msg_data
                        ) ;

                IF res = FALSE THEN
                    IF g_debug = 1 THEN
                       print_debug('Invalid Origination Type value '|| p_origination_type, 9);
                    END IF;
                    RAISE fnd_api.g_exc_error;
                END IF;
                IF g_debug = 1 THEN
                    print_debug('Program Inv_Lot_Attr_Pub.validate_origination_type ' || l_return_status, 9);
                END IF;
                IF l_return_status = fnd_api.g_ret_sts_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_origination_type has failed with a user defined exception', 9);
                   END IF;
                   RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_origination_type   has failed with a Unexpected exception', 9);
                   END IF;
                   FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROG_NAME','INV_LOT_ATTR_PUB. ');
                   FND_MSG_PUB.ADD;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;



    /******************* END Origination Type validation logic ********************/

    /******************* START Grade Code validation logic ********************/

         res := FALSE ;
         res :=  Inv_Lot_Attr_Pub.validate_grade_code(
                          p_grade_code  	=>  p_grade_code
                        , p_org_id              =>  p_organization_id
  			, p_inventory_item_id   =>  p_inventory_item_id
  			, p_grade_control_flag  =>  NULL
                        , x_return_status 	=>  l_return_status
                        , x_msg_count 		=>  l_msg_count
                        , x_msg_data 		=>  l_msg_data
                        );

                IF res = FALSE THEN
                    IF g_debug = 1 THEN
                       print_debug('Invalid Grade Code value '|| p_grade_code, 9);
                    END IF;
                    RAISE fnd_api.g_exc_error;
                END IF;
                IF g_debug = 1 THEN
                    print_debug('Program Inv_Lot_Attr_Pub.validate_grade_code ' || l_return_status, 9);
                END IF;
                IF l_return_status = fnd_api.g_ret_sts_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_grade_code has failed with a user defined exception', 9);
                   END IF;
                   RAISE g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_grade_code   has failed with a Unexpected exception', 9);
                   END IF;
                   FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROG_NAME','INV_LOT_ATTR_PUB. ');
                   FND_MSG_PUB.ADD;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;


    /******************* END Grade Code validation logic ********************/

    /******************* START Expiration Action Code validation logic ********************/

         res := FALSE ;
         res :=  Inv_Lot_Attr_Pub.validate_exp_action_code(
                         p_expiration_action_code =>  p_expiration_action_code
                       , p_org_id                 =>  p_organization_id
                       , p_inventory_item_id      =>  p_inventory_item_id
  		       , p_shelf_life_code        =>  NULL
                       , x_return_status 	  =>  l_return_status
                       , x_msg_count 		  =>  l_msg_count
                       , x_msg_data 		  =>  l_msg_data
                       ) ;

                IF res = FALSE THEN
                    IF g_debug = 1 THEN
                       print_debug('Invalid Expiration Action Code value '|| p_expiration_action_code, 9);
                    END IF;
                    RAISE fnd_api.g_exc_error;
                END IF;
                IF g_debug = 1 THEN
                    print_debug('Program Inv_Lot_Attr_Pub.validate_exp_action_code ' || l_return_status, 9);
                END IF;
                IF l_return_status = fnd_api.g_ret_sts_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_exp_action_code has failed with a user defined exception', 9);
                   END IF;
                   RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_exp_action_code   has failed with a Unexpected exception', 9);
                   END IF;
                   FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROG_NAME','INV_LOT_ATTR_PUB. ');
                   FND_MSG_PUB.ADD;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;



    /******************* END Expiration Action Code validation logic ********************/

    /******************* START Expiration Action Date validation logic ********************/

     OPEN  c_get_item_info ;
     FETCH  c_get_item_info INTO l_item_info;

      IF c_get_item_info%FOUND THEN
         res := FALSE ;

         IF l_item_info.expiration_action_interval IS NOT NULL
             AND l_item_info.expiration_action_interval > 0 THEN

             res := Inv_Lot_Attr_Pub. validate_exp_action_date(
                          p_expiration_action_date  =>  p_expiration_action_date
                        , p_expiration_date         =>  p_expiration_date
                        , x_return_status 	    =>  l_return_status
                        , x_msg_count 		    =>  l_msg_count
                        , x_msg_data 		    =>  l_msg_data
                        ) ;

                IF res = FALSE THEN
                    IF g_debug = 1 THEN
                       print_debug('Invalid Expiration Action Date value '|| p_expiration_action_date, 9);
                    END IF;
                    RAISE fnd_api.g_exc_error;
                END IF;
                IF g_debug = 1 THEN
                    print_debug('Program Inv_Lot_Attr_Pub.validate_exp_action_date ' || l_return_status, 9);
                END IF;
                IF l_return_status = fnd_api.g_ret_sts_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_exp_action_date has failed with a user defined exception', 9);
                   END IF;
                   RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_exp_action_date   has failed with a Unexpected exception', 9);
                   END IF;
                   FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROG_NAME','INV_LOT_ATTR_PUB. ');
                   FND_MSG_PUB.ADD;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;
         END IF ; -- Check for positive expiration action interval
      END IF ;  -- Cursor If
      CLOSE c_get_item_info;

    /******************* END Expiration Action Date validation logic ********************/

/******************* START Perform Date validation logic ********************/
IF (p_origination_date IS NOT NULL) THEN

    /******************* START Retest Date validation logic ********************/

         res := FALSE ;
         res :=  Inv_Lot_Attr_Pub.validate_retest_date(
                          p_retest_date 	=>  p_retest_date
                        , p_origination_date    =>  p_origination_date
                        , x_return_status 	=>  l_return_status
                        , x_msg_count 		=>  l_msg_count
                        , x_msg_data 		=>  l_msg_data
                        );

                IF res = FALSE THEN
                    IF g_debug = 1 THEN
                       print_debug('Invalid Retest Date value '|| p_retest_date, 9);
                    END IF;
                    RAISE fnd_api.g_exc_error;
                END IF;
                IF g_debug = 1 THEN
                    print_debug('Program Inv_Lot_Attr_Pub.validate_retest_date ' || l_return_status, 9);
                END IF;
                IF l_return_status = fnd_api.g_ret_sts_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_retest_date has failed with a user defined exception', 9);
                   END IF;
                   RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_retest_date   has failed with a Unexpected exception', 9);
                   END IF;
                   FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROG_NAME','INV_LOT_ATTR_PUB. ');
                   FND_MSG_PUB.ADD;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;



    /******************* END Retest Date validation logic ********************/

    /******************* START Maturity Date validation logic ********************/

         res := FALSE ;
         res :=  Inv_Lot_Attr_Pub.validate_maturity_date(
                          p_maturity_date	=>  p_maturity_date
                        , p_origination_date    =>  p_origination_date
                        , x_return_status 	=>  l_return_status
                        , x_msg_count 		=>  l_msg_count
                        , x_msg_data 		=>  l_msg_data
                        );

                IF res = FALSE THEN
                    IF g_debug = 1 THEN
                       print_debug('Invalid Maturity Date value '|| p_maturity_date, 9);
                    END IF;
                    RAISE fnd_api.g_exc_error;
                END IF;
                IF g_debug = 1 THEN
                    print_debug('Program Inv_Lot_Attr_Pub.validate_maturity_date ' || l_return_status, 9);
                END IF;
                IF l_return_status = fnd_api.g_ret_sts_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_maturity_date has failed with a user defined exception', 9);
                   END IF;
                   RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_maturity_date has failed with a Unexpected exception', 9);
                   END IF;
                   FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROG_NAME','INV_LOT_ATTR_PUB. ');
                   FND_MSG_PUB.ADD;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;



    /******************* END Maturity Date validation logic ********************/

    /******************* START Hold Date validation logic ********************/

         res := FALSE ;
         res :=  Inv_Lot_Attr_Pub.validate_hold_date(
                          p_hold_date		=>  p_hold_date
                        , p_origination_date    =>  p_origination_date
                        , x_return_status 	=>  l_return_status
                        , x_msg_count 		=>  l_msg_count
                        , x_msg_data 		=>  l_msg_data
                        ) ;

                IF res = FALSE THEN
                    IF g_debug = 1 THEN
                       print_debug('Invalid Hold Date value '|| p_hold_date, 9);
                    END IF;
                    RAISE fnd_api.g_exc_error;
                END IF;
                IF g_debug = 1 THEN
                    print_debug('Program Inv_Lot_Attr_Pub.validate_hold_date ' || l_return_status, 9);
                END IF;
                IF l_return_status = fnd_api.g_ret_sts_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_hold_date has failed with a user defined exception', 9);
                   END IF;
                   RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_ATTR_PUB.validate_hold_date has failed with a Unexpected exception', 9);
                   END IF;
                       FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                       FND_MESSAGE.SET_TOKEN('PROG_NAME','INV_LOT_ATTR_PUB. ');
                       FND_MSG_PUB.ADD;
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;


    /******************* END Hold Date validation logic ********************/
 END IF;
 /******************* END Perform Date validation logic ********************/

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO val_lot_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In No data found Validate_Additional_Attr ' || SQLERRM, 9);
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO val_lot_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In g_exc_error Validate_Additional_Attr ' || SQLERRM, 9);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO val_lot_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In g_exc_unexpected_error Validate_Additional_Attr ' || SQLERRM, 9);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO val_lot_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In others Validate_Additional_Attr ' || SQLERRM, 9);

  END Validate_Additional_Attr;



  PROCEDURE Delete_Lot(
    x_return_status          OUT    NOCOPY VARCHAR2
  , x_msg_count              OUT    NOCOPY NUMBER
  , x_msg_data               OUT    NOCOPY VARCHAR2
  , p_inventory_item_id     IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_lot_number             IN     VARCHAR2

   ) IS

   CURSOR  c_lot_rec  IS
   SELECT  *
     FROM  mtl_lot_numbers
    WHERE  inventory_item_id = p_inventory_item_id
      AND  organization_id   = p_organization_id
      AND  lot_number        = p_lot_number ;

  l_lot_rec         c_lot_rec%ROWTYPE ;

   CURSOR  c_gen_rec(cp_gen_obj_id  NUMBER)  IS
   SELECT  *
     FROM  mtl_object_genealogy
    WHERE  object_id = cp_gen_obj_id ;

  l_gen_rec         c_gen_rec%ROWTYPE ;
  l_gen_obj_id      NUMBER ;

   CURSOR  c_uom_conv_rec IS
   SELECT  *
     FROM  mtl_lot_uom_class_conversions
    WHERE  lot_number = p_lot_number ;

  l_uom_conv_rec         c_uom_conv_rec%ROWTYPE ;

   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(3000);
   l_lot_cont               BOOLEAN   ;
   l_child_lot_cont         BOOLEAN   ;

 BEGIN

   SAVEPOINT inv_delete_lot ;
    x_return_status  := fnd_api.g_ret_sts_success;

     /*Basic Validations - Start*/
    IF p_organization_id IS NULL THEN
       IF g_debug = 1 THEN
            print_debug('Value for mandatory field organization id cannot be null.', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_NULL_ORG_EXP') ;
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END IF ;

    IF p_inventory_item_id IS NULL THEN
       IF g_debug = 1 THEN
            print_debug('Value for mandatory field inventory item id cannot be null.', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_INVALID_ITEM') ;
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END IF ;

    IF p_lot_number IS NULL THEN
       IF g_debug = 1 THEN
          print_debug('Value for mandatory field Lot Number cannot be null', 9);
       END IF;
       fnd_message.set_name('INV', 'INV_NULL_CLOT_EXP');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;
     /*Basic Validations - End*/

/******************* START Item  validation ********************/

   l_lot_cont        := FALSE ;
   l_child_lot_cont  := FALSE ;

   check_item_attributes
       (
              x_return_status          =>  l_return_status
            , x_msg_count              =>  l_msg_count
            , x_msg_data               =>  l_msg_data
            , x_lot_cont               =>  l_lot_cont
            , x_child_lot_cont         =>  l_child_lot_cont
            , p_inventory_item_id      =>  p_inventory_item_id
            , p_organization_id        =>  p_organization_id
         )   ;

     IF g_debug = 1 THEN
         print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes return ' || l_return_status, 9);
     END IF;

     IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF g_debug = 1 THEN
            print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes has failed with error', 9);
        END IF;
        FND_MESSAGE.SET_NAME('INV', 'INV_PROGRAM_ERROR') ;
        FND_MESSAGE.SET_TOKEN('PROG_NAME','Inv_lot_api_pkg.Check_Item_Attributes');
        FND_MSG_PUB.ADD;
        RAISE fnd_api.g_exc_error;
     END IF;

     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         IF g_debug = 1 THEN
            print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes has failed with a Unexpected exception', 9);
         END IF;
         FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
         FND_MESSAGE.SET_TOKEN('PROG_NAME','Inv_lot_api_pkg.Check_Item_Attributes');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     IF (l_lot_cont = FALSE) THEN
        IF g_debug = 1 THEN
           print_debug(' Item is not lot controlled ', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_NO_LOT_CONTROL');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE g_exc_error;
     END IF ;

   /******************* End Item validation  ********************/


    OPEN c_lot_rec  ;
    FETCH c_lot_rec INTO l_lot_rec ;

     IF  c_lot_rec%FOUND THEN

       l_gen_obj_id    := l_lot_rec.gen_object_id ;

       DELETE  FROM mtl_lot_numbers
        WHERE  inventory_item_id = p_inventory_item_id
          AND  organization_id   = p_organization_id
          AND  lot_number        = p_lot_number ;

        CLOSE  c_lot_rec ;

     ELSE
        CLOSE  c_lot_rec ;
        RAISE  NO_DATA_FOUND ;
     END IF;

     IF g_debug = 1 THEN
        print_debug('Delete_Lot. After deleting Lot Record', 9);
     END IF;

     OPEN  c_gen_rec (l_gen_obj_id) ;
    FETCH  c_gen_rec INTO l_gen_rec ;

     IF  c_gen_rec%FOUND THEN
        DELETE  FROM mtl_object_genealogy
         WHERE  object_id = l_gen_obj_id ;
     END IF;
     CLOSE c_gen_rec ;

     IF g_debug = 1 THEN
         print_debug('Delete_Lot. After deleting Geneology Record', 9);
     END IF;

    OPEN c_uom_conv_rec ;
    FETCH c_uom_conv_rec INTO l_uom_conv_rec ;

     IF c_uom_conv_rec%FOUND THEN
        DELETE  FROM mtl_lot_uom_class_conversions
         WHERE  lot_number = p_lot_number ;
     END IF;

     CLOSE c_uom_conv_rec ;
     IF g_debug = 1 THEN
         print_debug('Delete_Lot. After deleting UOM Conversion Record', 9);
     END IF;

     IF g_debug = 1 THEN
         print_debug('End of the program Delete_Lot. Program has completed successfully ', 9);
     END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO inv_delete_lot;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In Delete_Lot, No data found ' || SQLERRM, 9);
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO inv_delete_lot;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In Delete_Lot, g_exc_error ' || SQLERRM, 9);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO inv_delete_lot;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In Delete_Lot, g_exc_unexpected_error ' || SQLERRM, 9);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO inv_delete_lot;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In Delete_Lot, Others ' || SQLERRM, 9);

 END Delete_Lot;

 /** INVCONV ANTHIYAG 04-Nov-2004 Start **/

  FUNCTION Check_Existing_Lot_Db
  (
   p_org_id              IN   NUMBER
  ,p_inventory_item_id   IN   NUMBER
  ,p_lot_number          IN   VARCHAR2
  ) RETURN BOOLEAN
  IS
     PRAGMA AUTONOMOUS_TRANSACTION;
     l_exists NUMBER := 0;
  BEGIN
    IF p_org_id IS NOT NULL THEN
      BEGIN
        SELECT  count('1')
        INTO    l_exists
        FROM    mtl_lot_numbers
        WHERE   inventory_item_id = p_inventory_item_id
        AND     organization_id = p_org_id
        AND     lot_number = p_lot_number
        AND     ROWNUM = 1;
      EXCEPTION
        WHEN no_data_found THEN
          l_exists := 0;
      END;
      IF NVL(l_exists,0) = 0 THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
    ELSE
      RETURN FALSE;
    END IF;
  END CHECK_EXISTING_LOT_DB;

/** INVCONV ANTHIYAG 04-Nov-2004 End **/

 END INV_LOT_API_PKG ;

/
