--------------------------------------------------------
--  DDL for Package Body INV_LOT_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOT_API_PUB" AS
/* $Header: INVPLOTB.pls 120.17.12010000.32 2011/11/11 13:06:13 kbavadek ship $ */

--  Global constant holding the package name
    g_pkg_name   CONSTANT VARCHAR2 ( 30 ) := 'INV_LOT_API_PUB';


    /*****************************************************************************
                           Bug - 2181558 Additions Starts
      1. Added a new 'type' called 'non_wms_lot_att_rec_type' to store the values
         of Non WMS Attributes
      2. Added a new 'procedure' called get_lot_att_from_source() to get the
         WMS and Non WMS Lot Attributes from the Source Lot if the transaction
         is an Intransit Transaction
    *****************************************************************************/
    TYPE non_wms_lot_att_rec_type IS RECORD
    (
        attribute_category           mtl_lot_numbers.attribute_category%TYPE,
        attribute1                    mtl_lot_numbers.attribute1%TYPE,
        attribute2                    mtl_lot_numbers.attribute2%TYPE,
        attribute3                    mtl_lot_numbers.attribute3%TYPE,
        attribute4                    mtl_lot_numbers.attribute4%TYPE,
        attribute5                    mtl_lot_numbers.attribute5%TYPE,
        attribute6                    mtl_lot_numbers.attribute6%TYPE,
        attribute7                    mtl_lot_numbers.attribute7%TYPE,
        attribute8                    mtl_lot_numbers.attribute8%TYPE,
        attribute9                    mtl_lot_numbers.attribute9%TYPE,
        attribute10                   mtl_lot_numbers.attribute10%TYPE,
        attribute11                   mtl_lot_numbers.attribute11%TYPE,
        attribute12                   mtl_lot_numbers.attribute12%TYPE,
        attribute13                   mtl_lot_numbers.attribute13%TYPE,
        attribute14                   mtl_lot_numbers.attribute14%TYPE,
        attribute15                   mtl_lot_numbers.attribute15%TYPE
    );

    PROCEDURE get_lot_att_from_source (
        x_return_status                OUT      NOCOPY VARCHAR2,
        x_count                        OUT      NOCOPY NUMBER,
        x_source_wms_lot_att_tbl       OUT      NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type,
        x_source_non_wms_lot_att_rec   OUT      NOCOPY non_wms_lot_att_rec_type,
        p_from_organization_id         IN       NUMBER,
        p_inventory_item_id            IN       NUMBER,
        p_lot_number                   IN       VARCHAR2,
        p_count                        IN       NUMBER,
        p_source_wms_lot_att_tbl       IN       inv_lot_sel_attr.lot_sel_attributes_tbl_type
     );

    /**********************      Bug - 2181558 Additions Ends     ************************/


    PROCEDURE print_debug ( p_err_msg VARCHAR2, p_level NUMBER DEFAULT 1)
    IS
    --l_debug number := 1;--NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN
        IF (g_debug = 1) THEN
           inv_mobile_helper_functions.tracelog (
             p_err_msg => p_err_msg,
            p_module => 'INV_LOT_API_PUB',
            p_level => p_level
         );
        --DBMS_OUTPUT.PUT_LINE(p_err_msg);
        END IF;
        --DBMS_OUTPUT.PUT_LINE(p_err_msg);
    END print_debug;

    PROCEDURE set_firstscan ( p_firstscan BOOLEAN )
    IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN
        g_firstscan := p_firstscan;
    END;

/* Bug 8198497 - Added this procedure to validate and update lot status correctly */
  PROCEDURE validate_lot_status(
    p_api_version         IN            NUMBER
  , p_init_msg_list       IN            VARCHAR2
  , p_organization_id     IN            NUMBER
  , p_inventory_item_id   IN            NUMBER
  , p_lot_number          IN            VARCHAR2
  , p_status_id           IN            NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR
  )
  IS
      l_old_status_id     NUMBER;
      l_ret_status        BOOLEAN;
      l_lot_status_enabled           mtl_system_items.lot_status_enabled%TYPE; /* Bug8647949 */
  BEGIN

      print_debug('Entered validate_lot_status ', 9);
      print_debug('validate_lot_status: Organization Id: '||p_organization_id, 9);
      print_debug('validate_lot_status: Inventory Item Id: ' || p_inventory_item_id, 9);
      print_debug('validate_lot_status: Lot Number: ' || p_lot_number, 9);
      print_debug('validate_lot_status: Status Id ' || p_status_id, 9);

/* Bug8647949 - Fetching lot_status_enabled code of Item and Calling validate_lot_status
       only when lot_status_enabled is 'Y' */
    Select nvl(lot_status_enabled,'N')
       into l_lot_status_enabled
       from mtl_system_items
       where organization_id= p_organization_id
       and inventory_item_id= p_inventory_item_id;

    IF(l_lot_status_enabled= 'Y' and (p_status_id <> g_miss_num or p_status_id is not null)) then
     -- Get old status id
      select status_id
      into l_old_status_id
      from mtl_lot_numbers
      where organization_id = p_organization_id
      and inventory_item_id = p_inventory_item_id
      and lot_number = p_lot_number;

      print_debug('validate_lot_status: Old Status Id ' || l_old_status_id, 9);

      -- if no data found then no update

      -- if lot exists then call validate_mtstatus
      l_ret_status   :=  INV_MATERIAL_STATUS_PKG.validate_mtstatus(
                                    p_old_status_id        => l_old_status_id
                                   ,p_new_status_id        => p_status_id
                                   ,p_subinventory_code    => NULL
				   ,p_locator_id           => NULL
                                   ,p_organization_id      => p_organization_id
                                   ,p_inventory_item_id    => p_inventory_item_id
                                   ,P_lot_number           => p_lot_number) ;


      if (l_ret_status) then
         print_debug('validate_lot_status: Returned true from validate_mtstatus ', 9);
      else
         print_debug('validate_lot_status: Returned false from validate_mtstatus ', 9);
	 x_return_status := fnd_api.g_ret_sts_error;
	 x_msg_data := fnd_message.GET_STRING('INV', 'INV_STATUS_UPD_RESV_FAIL');
	 x_msg_count := 1;
	 return;
      end if;

      -- if returned true then call inv_material_status_grp.update_status
      IF (l_ret_status) then

           print_debug('validate_lot_status: Before calling inv_material_status_grp.update_status', 9);

           INV_MATERIAL_STATUS_GRP.update_status
             (    p_api_version
                , p_init_msg_list
                , x_return_status
                , x_msg_count
                , x_msg_data
                , 2
                , p_status_id
                , p_organization_id
                , p_inventory_item_id
                , NULL
                , NULL
                , p_lot_number
                , NULL
                , NULL
                , 'O'
                , NULL
             ) ;

             print_debug('validate_lot_status: Return status from inv_material_status_grp.update_status: '||x_return_status, 9);
        END IF;
    ELSIF (l_lot_status_enabled = 'N' ) then
         x_return_status := fnd_api.g_ret_sts_success;
         x_msg_data := fnd_message.GET_STRING('INV', 'INV_NOT_VALID');
	 x_msg_count := 1;
    END IF;
    /* End of Fix for Bug8647949 */

  EXCEPTION
    WHEN OTHERS THEN
       x_return_status  := g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
       end if;
       print_debug('validate_lot_status: In others ' || SQLERRM, 9);
  END validate_lot_status;

    PROCEDURE populateattributescolumn
    IS
        l_column_idx   BINARY_INTEGER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN
        g_lot_attributes_tbl ( 1 ).column_name := 'VENDOR_ID';
        g_lot_attributes_tbl ( 1 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 2 ).column_name := 'GRADE_CODE';
        g_lot_attributes_tbl ( 2 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 3 ).column_name := 'ORIGINATION_DATE';
        g_lot_attributes_tbl ( 3 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 4 ).column_name := 'DATE_CODE';
        g_lot_attributes_tbl ( 4 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 5 ).column_name := 'STATUS_ID';
        g_lot_attributes_tbl ( 5 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 6 ).column_name := 'CHANGE_DATE';
        g_lot_attributes_tbl ( 6 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 7 ).column_name := 'AGE';
        g_lot_attributes_tbl ( 7 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 8 ).column_name := 'RETEST_DATE';
        g_lot_attributes_tbl ( 8 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 9 ).column_name := 'MATURITY_DATE';
        g_lot_attributes_tbl ( 9 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 10 ).column_name := 'LOT_ATTRIBUTE_CATEGORY';
        g_lot_attributes_tbl ( 10 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 11 ).column_name := 'ITEM_SIZE';
        g_lot_attributes_tbl ( 11 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 12 ).column_name := 'COLOR';
        g_lot_attributes_tbl ( 12 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 13 ).column_name := 'VOLUME';
        g_lot_attributes_tbl ( 13 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 14 ).column_name := 'VOLUME_UOM';
        g_lot_attributes_tbl ( 14 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 15 ).column_name := 'PLACE_OF_ORIGIN';
        g_lot_attributes_tbl ( 15 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 16 ).column_name := 'BEST_BY_DATE';
        g_lot_attributes_tbl ( 16 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 17 ).column_name := 'LENGTH';
        g_lot_attributes_tbl ( 17 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 18 ).column_name := 'LENGTH_UOM';
        g_lot_attributes_tbl ( 18 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 19 ).column_name := 'RECYCLED_CONTENT';
        g_lot_attributes_tbl ( 19 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 20 ).column_name := 'THICKNESS';
        g_lot_attributes_tbl ( 20 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 21 ).column_name := 'THICKNESS_UOM';
        g_lot_attributes_tbl ( 21 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 22 ).column_name := 'WIDTH';
        g_lot_attributes_tbl ( 22 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 23 ).column_name := 'WIDTH_UOM';
        g_lot_attributes_tbl ( 23 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 24 ).column_name := 'CURL_WRINKLE_FOLD';
        g_lot_attributes_tbl ( 24 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 25 ).column_name := 'C_ATTRIBUTE1';
        g_lot_attributes_tbl ( 25 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 26 ).column_name := 'C_ATTRIBUTE2';
        g_lot_attributes_tbl ( 26 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 27 ).column_name := 'C_ATTRIBUTE3';
        g_lot_attributes_tbl ( 27 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 28 ).column_name := 'C_ATTRIBUTE4';
        g_lot_attributes_tbl ( 28 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 29 ).column_name := 'C_ATTRIBUTE5';
        g_lot_attributes_tbl ( 29 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 30 ).column_name := 'C_ATTRIBUTE6';
        g_lot_attributes_tbl ( 30 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 31 ).column_name := 'C_ATTRIBUTE7';
        g_lot_attributes_tbl ( 31 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 32 ).column_name := 'C_ATTRIBUTE8';
        g_lot_attributes_tbl ( 32 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 33 ).column_name := 'C_ATTRIBUTE9';
        g_lot_attributes_tbl ( 33 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 34 ).column_name := 'C_ATTRIBUTE10';
        g_lot_attributes_tbl ( 34 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 35 ).column_name := 'C_ATTRIBUTE11';
        g_lot_attributes_tbl ( 35 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 36 ).column_name := 'C_ATTRIBUTE12';
        g_lot_attributes_tbl ( 36 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 37 ).column_name := 'C_ATTRIBUTE13';
        g_lot_attributes_tbl ( 37 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 38 ).column_name := 'C_ATTRIBUTE14';
        g_lot_attributes_tbl ( 38 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 39 ).column_name := 'C_ATTRIBUTE15';
        g_lot_attributes_tbl ( 39 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 40 ).column_name := 'C_ATTRIBUTE16';
        g_lot_attributes_tbl ( 40 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 41 ).column_name := 'C_ATTRIBUTE17';
        g_lot_attributes_tbl ( 41 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 42 ).column_name := 'C_ATTRIBUTE18';
        g_lot_attributes_tbl ( 42 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 43 ).column_name := 'C_ATTRIBUTE19';
        g_lot_attributes_tbl ( 43 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 44 ).column_name := 'C_ATTRIBUTE20';
        g_lot_attributes_tbl ( 44 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 45 ).column_name := 'D_ATTRIBUTE1';
        g_lot_attributes_tbl ( 45 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 46 ).column_name := 'D_ATTRIBUTE2';
        g_lot_attributes_tbl ( 46 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 47 ).column_name := 'D_ATTRIBUTE3';
        g_lot_attributes_tbl ( 47 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 48 ).column_name := 'D_ATTRIBUTE4';
        g_lot_attributes_tbl ( 48 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 49 ).column_name := 'D_ATTRIBUTE5';
        g_lot_attributes_tbl ( 49 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 50 ).column_name := 'D_ATTRIBUTE6';
        g_lot_attributes_tbl ( 50 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 51 ).column_name := 'D_ATTRIBUTE7';
        g_lot_attributes_tbl ( 51 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 52 ).column_name := 'D_ATTRIBUTE8';
        g_lot_attributes_tbl ( 52 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 53 ).column_name := 'D_ATTRIBUTE9';
        g_lot_attributes_tbl ( 53 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 54 ).column_name := 'D_ATTRIBUTE10';
        g_lot_attributes_tbl ( 54 ).column_type := 'DATE';
        g_lot_attributes_tbl ( 55 ).column_name := 'N_ATTRIBUTE1';
        g_lot_attributes_tbl ( 55 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 56 ).column_name := 'N_ATTRIBUTE2';
        g_lot_attributes_tbl ( 56 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 57 ).column_name := 'N_ATTRIBUTE3';
        g_lot_attributes_tbl ( 57 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 58 ).column_name := 'N_ATTRIBUTE4';
        g_lot_attributes_tbl ( 58 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 59 ).column_name := 'N_ATTRIBUTE5';
        g_lot_attributes_tbl ( 59 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 60 ).column_name := 'N_ATTRIBUTE6';
        g_lot_attributes_tbl ( 60 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 61 ).column_name := 'N_ATTRIBUTE7';
        g_lot_attributes_tbl ( 61 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 62 ).column_name := 'N_ATTRIBUTE8';
        g_lot_attributes_tbl ( 62 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 63 ).column_name := 'N_ATTRIBUTE10';
        g_lot_attributes_tbl ( 63 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 64 ).column_name := 'SUPPLIER_LOT_NUMBER';
        g_lot_attributes_tbl ( 64 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 65 ).column_name := 'N_ATTRIBUTE9';
        g_lot_attributes_tbl ( 65 ).column_type := 'NUMBER';
        g_lot_attributes_tbl ( 66 ).column_name := 'TERRITORY_CODE';
        g_lot_attributes_tbl ( 66 ).column_type := 'VARCHAR2';
        -- Added 05/16/2001
        g_lot_attributes_tbl ( 67 ).column_name := 'VENDOR_NAME';
        g_lot_attributes_tbl ( 67 ).column_type := 'VARCHAR2';
        g_lot_attributes_tbl ( 68 ).column_name := 'DESCRIPTION';
        g_lot_attributes_tbl ( 68 ).column_type := 'VARCHAR2';
    END;

    PROCEDURE insertlot (
        p_api_version                IN       NUMBER,
        p_init_msg_list              IN       VARCHAR2 := fnd_api.g_false,
        p_commit                     IN       VARCHAR2 := fnd_api.g_false,
        p_validation_level           IN       NUMBER
                := fnd_api.g_valid_level_full,
        p_inventory_item_id          IN       NUMBER,
        p_organization_id            IN       NUMBER,
        p_lot_number                 IN       VARCHAR2,
        p_expiration_date            IN OUT   NOCOPY DATE,
        p_transaction_temp_id        IN       NUMBER DEFAULT NULL,
        p_transaction_action_id      IN       NUMBER DEFAULT NULL,
        p_transfer_organization_id   IN       NUMBER DEFAULT NULL,
        x_object_id                  OUT      NOCOPY NUMBER,
        x_return_status              OUT      NOCOPY VARCHAR2,
        x_msg_count                  OUT      NOCOPY NUMBER,
        x_msg_data                   OUT      NOCOPY VARCHAR2,
		p_parent_lot_number          IN       VARCHAR2 DEFAULT NULL    --bug 10176719 - inserting parent lot number
     )
    IS
        l_api_version         CONSTANT NUMBER                                             := 1.0;
        l_api_name            CONSTANT VARCHAR2 ( 30 )                                    := 'insertLot';
        l_lot_control_code             NUMBER;
        l_lotunique                    NUMBER;
        l_lotcount                     NUMBER;
        l_userid                       NUMBER;
        l_loginid                      NUMBER;
        l_shelf_life_code              NUMBER;
        l_shelf_life_days              NUMBER;
        l_attributes_default           inv_lot_sel_attr.lot_sel_attributes_tbl_type;
        l_attributes_default_count     NUMBER;
        l_attributes_in                inv_lot_sel_attr.lot_sel_attributes_tbl_type;
        l_column_idx                   BINARY_INTEGER;
        l_return_status                VARCHAR2 ( 1 );
        l_msg_data                     VARCHAR2 ( 2000 );
        l_msg_count                    NUMBER;
        l_input_idx                    BINARY_INTEGER;

        -- Bug# 1520495
        l_lot_status_enabled           VARCHAR2 ( 1 );
        l_default_lot_status_id        NUMBER                                 := NULL;
        l_serial_status_enabled        VARCHAR2 ( 1 );
        l_default_serial_status_id     NUMBER;
        l_status_rec                   inv_material_status_pub.mtl_status_update_rec_type;

        -- Bug 2181558 Variable Declaration Starts
        l_att_after_source_copy        inv_lot_sel_attr.lot_sel_attributes_tbl_type;
        l_source_non_wms_lot_att_rec   non_wms_lot_att_rec_type;
        l_num_wms_lot_att_copied       NUMBER;
        -- Bug 2181558 Variable Declaration Ends
        l_dest_status_enabled VARCHAR2(1);  --Added bug4066234

        CURSOR lot_temp_csr ( p_lot_number VARCHAR2, p_trx_temp_id NUMBER )
        IS
            SELECT TO_CHAR ( vendor_id ),
                   grade_code,
                   fnd_date.date_to_canonical ( origination_date ),
                   date_code,
                   TO_CHAR ( status_id ),
                   fnd_date.date_to_canonical ( change_date ),
                   TO_NUMBER ( age ),
                   fnd_date.date_to_canonical ( retest_date ),
                   fnd_date.date_to_canonical ( maturity_date ),
                   lot_attribute_category,
                   TO_CHAR ( item_size ),
                   color,
                   TO_CHAR ( volume ),
                   volume_uom,
                   place_of_origin,
                   fnd_date.date_to_canonical ( best_by_date ),
                   TO_CHAR ( LENGTH ),
                   length_uom,
                   TO_CHAR ( recycled_content ),
                   TO_CHAR ( thickness ),
                   thickness_uom,
                   TO_CHAR ( width ),
                   width_uom,
                   curl_wrinkle_fold,
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
                   fnd_date.date_to_canonical ( d_attribute1 ),
                   fnd_date.date_to_canonical ( d_attribute2 ),
                   fnd_date.date_to_canonical ( d_attribute3 ),
                   fnd_date.date_to_canonical ( d_attribute4 ),
                   fnd_date.date_to_canonical ( d_attribute5 ),
                   fnd_date.date_to_canonical ( d_attribute6 ),
                   fnd_date.date_to_canonical ( d_attribute7 ),
                   fnd_date.date_to_canonical ( d_attribute8 ),
                   fnd_date.date_to_canonical ( d_attribute9 ),
                   fnd_date.date_to_canonical ( d_attribute10 ),
                   TO_CHAR ( n_attribute1 ),
                   TO_CHAR ( n_attribute2 ),
                   TO_CHAR ( n_attribute3 ),
                   TO_CHAR ( n_attribute4 ),
                   TO_CHAR ( n_attribute5 ),
                   TO_CHAR ( n_attribute6 ),
                   TO_CHAR ( n_attribute7 ),
                   TO_CHAR ( n_attribute8 ),
                   TO_CHAR ( n_attribute10 ),
                   supplier_lot_number,
                   TO_CHAR ( n_attribute9 ),
                   territory_code,
                   vendor_name,
                   description
              FROM mtl_transaction_lots_temp
             WHERE lot_number = p_lot_number
               AND transaction_temp_id = p_trx_temp_id;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN
        IF (l_debug = 1) THEN
           inv_pick_wave_pick_confirm_pub.tracelog ( 'Inside InsertLot API' , 'INV_LOT_API_PUB');
        END IF;
        -- Standard Start of API savepoint
        SAVEPOINT apiinsertlot_apipub;

        -- Standard call to check for call compatibility.
        IF NOT fnd_api.compatible_api_call ( l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF fnd_api.to_boolean ( p_init_msg_list ) THEN
            fnd_msg_pub.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

        -- API body
        IF (     g_firstscan = TRUE AND p_transaction_action_id = 3) THEN
            x_return_status := fnd_api.g_ret_sts_success;
        ELSE
            BEGIN
                SELECT lot_control_code
                  INTO l_lot_control_code
                  FROM mtl_system_items
                 WHERE inventory_item_id = p_inventory_item_id
                   AND organization_id = p_organization_id;

                IF ( l_lot_control_code = 1 )
                THEN
                    fnd_message.set_name ('INV' , 'INV_NO_LOT_CONTROL' );
                    fnd_msg_pub.ADD;
                    x_return_status := fnd_api.g_ret_sts_error;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    IF (l_debug = 1) THEN
                       inv_pick_wave_pick_confirm_pub.tracelog ( 'Exception in LOT_CONTROL_CODE' , 'INV_LOT_API_PUB');
                    END IF;
                    fnd_message.set_name ('INV' , 'INV_INVALID_ITEM' );
                    fnd_msg_pub.ADD;
                    x_return_status := fnd_api.g_ret_sts_error;
                    RAISE fnd_api.g_exc_unexpected_error;
            END;

            SELECT lot_number_uniqueness
              INTO l_lotunique
              FROM mtl_parameters
             WHERE organization_id = p_organization_id;

            SELECT lot_status_enabled  --Added select for bug4066234
            INTO l_dest_status_enabled
            FROM mtl_system_items
            WHERE
            inventory_item_id=p_inventory_item_id and
            organization_id=p_organization_id;

            IF ( l_lotunique = 1 ) THEN
                SELECT COUNT ( 1 )
                  INTO l_lotcount
                  FROM mtl_lot_numbers
                 WHERE inventory_item_id <> p_inventory_item_id
                   AND lot_number = p_lot_number
                   AND NOT EXISTS (  SELECT NULL
                                      FROM mtl_lot_numbers lot
                                     WHERE lot.lot_number = p_lot_number
                                       AND lot.organization_id = p_organization_id
                                       AND lot.inventory_item_id = p_inventory_item_id );

                IF ( l_lotcount > 0 ) THEN
                    fnd_message.set_name ('INV' , 'INV_INT_LOTUNIQEXP' );
                    fnd_msg_pub.ADD;
                    x_return_status := fnd_api.g_ret_sts_error;
                    RAISE fnd_api.g_exc_unexpected_error;
                    IF (l_debug = 1) THEN
                       inv_pick_wave_pick_confirm_pub.tracelog ( 'Exception in MTL_LOT_NUMBER' , 'INV_LOT_API_PUB');
                    END IF;
                END IF;
            END IF;

            l_lotcount := 0;

            SELECT COUNT ( 1 )
              INTO l_lotcount
              FROM mtl_lot_numbers
             WHERE inventory_item_id = p_inventory_item_id
               AND organization_id = p_organization_id
               AND lot_number = p_lot_number;

            IF ( l_lotcount = 0 ) THEN
                l_userid := fnd_global.user_id;
                l_loginid := fnd_global.login_id;

                IF ( p_expiration_date IS NULL ) THEN
                    SELECT shelf_life_code,
                           shelf_life_days
                      INTO l_shelf_life_code,
                           l_shelf_life_days
                      FROM mtl_system_items
                     WHERE inventory_item_id = p_inventory_item_id
                       AND organization_id = p_organization_id;

                    IF ( l_shelf_life_code = 2 ) THEN
                        SELECT SYSDATE + l_shelf_life_days
                          INTO p_expiration_date
                          FROM DUAL;
                    ELSIF ( l_shelf_life_code = 4 ) THEN
                        fnd_message.set_name ('INV' , 'INV_LOT_EXPREQD' );
                        fnd_msg_pub.ADD;
                        x_return_status := fnd_api.g_ret_sts_error;
                        RAISE fnd_api.g_exc_unexpected_error;
                    END IF;
                END IF;

                IF (l_debug = 1) THEN
                   inv_pick_wave_pick_confirm_pub.tracelog ( 'Before calling populateattributesColumn' , 'INV_LOT_API_PUB');
                END IF;

                SELECT mtl_gen_object_id_s.NEXTVAL
                  INTO x_object_id
                  FROM DUAL;

                populateattributescolumn ( );
                IF (l_debug = 1) THEN
                   inv_pick_wave_pick_confirm_pub.tracelog ( 'After calling populateattributesColumn' , 'INV_LOT_API_PUB');
                END IF;

                IF ( p_transaction_temp_id IS NOT NULL ) THEN
                    IF (l_debug = 1) THEN
                       inv_pick_wave_pick_confirm_pub.tracelog ( 'p_transaction_temp_id' || p_transaction_temp_id, 'INV_LOT_API_PUB');
                    END IF;
                    OPEN lot_temp_csr ( p_lot_number, p_transaction_temp_id );

                    LOOP
                        FETCH lot_temp_csr INTO g_lot_attributes_tbl ( 1 ).column_value,
                                                g_lot_attributes_tbl ( 2 ).column_value,
                                                g_lot_attributes_tbl ( 3 ).column_value,
                                                g_lot_attributes_tbl ( 4 ).column_value,
                                                g_lot_attributes_tbl ( 5 ).column_value,
                                                g_lot_attributes_tbl ( 6 ).column_value,
                                                g_lot_attributes_tbl ( 7 ).column_value,
                                                g_lot_attributes_tbl ( 8 ).column_value,
                                                g_lot_attributes_tbl ( 9 ).column_value,
                                                g_lot_attributes_tbl ( 10 ).column_value,
                                                g_lot_attributes_tbl ( 11 ).column_value,
                                                g_lot_attributes_tbl ( 12 ).column_value,
                                                g_lot_attributes_tbl ( 13 ).column_value,
                                                g_lot_attributes_tbl ( 14 ).column_value,
                                                g_lot_attributes_tbl ( 15 ).column_value,
                                                g_lot_attributes_tbl ( 16 ).column_value,
                                                g_lot_attributes_tbl ( 17 ).column_value,
                                                g_lot_attributes_tbl ( 18 ).column_value,
                                                g_lot_attributes_tbl ( 19 ).column_value,
                                                g_lot_attributes_tbl ( 20 ).column_value,
                                                g_lot_attributes_tbl ( 21 ).column_value,
                                                g_lot_attributes_tbl ( 22 ).column_value,
                                                g_lot_attributes_tbl ( 23 ).column_value,
                                                g_lot_attributes_tbl ( 24 ).column_value,
                                                g_lot_attributes_tbl ( 25 ).column_value,
                                                g_lot_attributes_tbl ( 26 ).column_value,
                                                g_lot_attributes_tbl ( 27 ).column_value,
                                                g_lot_attributes_tbl ( 28 ).column_value,
                                                g_lot_attributes_tbl ( 29 ).column_value,
                                                g_lot_attributes_tbl ( 30 ).column_value,
                                                g_lot_attributes_tbl ( 31 ).column_value,
                                                g_lot_attributes_tbl ( 32 ).column_value,
                                                g_lot_attributes_tbl ( 33 ).column_value,
                                                g_lot_attributes_tbl ( 34 ).column_value,
                                                g_lot_attributes_tbl ( 35 ).column_value,
                                                g_lot_attributes_tbl ( 36 ).column_value,
                                                g_lot_attributes_tbl ( 37 ).column_value,
                                                g_lot_attributes_tbl ( 38 ).column_value,
                                                g_lot_attributes_tbl ( 39 ).column_value,
                                                g_lot_attributes_tbl ( 40 ).column_value,
                                                g_lot_attributes_tbl ( 41 ).column_value,
                                                g_lot_attributes_tbl ( 42 ).column_value,
                                                g_lot_attributes_tbl ( 43 ).column_value,
                                                g_lot_attributes_tbl ( 44 ).column_value,
                                                g_lot_attributes_tbl ( 45 ).column_value,
                                                g_lot_attributes_tbl ( 46 ).column_value,
                                                g_lot_attributes_tbl ( 47 ).column_value,
                                                g_lot_attributes_tbl ( 48 ).column_value,
                                                g_lot_attributes_tbl ( 49 ).column_value,
                                                g_lot_attributes_tbl ( 50 ).column_value,
                                                g_lot_attributes_tbl ( 51 ).column_value,
                                                g_lot_attributes_tbl ( 52 ).column_value,
                                                g_lot_attributes_tbl ( 53 ).column_value,
                                                g_lot_attributes_tbl ( 54 ).column_value,
                                                g_lot_attributes_tbl ( 55 ).column_value,
                                                g_lot_attributes_tbl ( 56 ).column_value,
                                                g_lot_attributes_tbl ( 57 ).column_value,
                                                g_lot_attributes_tbl ( 58 ).column_value,
                                                g_lot_attributes_tbl ( 59 ).column_value,
                                                g_lot_attributes_tbl ( 60 ).column_value,
                                                g_lot_attributes_tbl ( 61 ).column_value,
                                                g_lot_attributes_tbl ( 62 ).column_value,
                                                g_lot_attributes_tbl ( 63 ).column_value,
                                                g_lot_attributes_tbl ( 64 ).column_value,
                                                g_lot_attributes_tbl ( 65 ).column_value,
                                                g_lot_attributes_tbl ( 66 ).column_value,
                                                g_lot_attributes_tbl ( 67 ).column_value,
                                                g_lot_attributes_tbl ( 68 ).column_value;
                        EXIT WHEN lot_temp_csr%NOTFOUND;
                    END LOOP;

                    CLOSE lot_temp_csr;
                    l_input_idx := 0;

                    FOR x IN 1 .. 68
                    LOOP
                        IF ( g_lot_attributes_tbl ( x ).column_value IS NOT NULL ) THEN
                            l_input_idx := l_input_idx + 1;
                            l_attributes_in ( l_input_idx ).column_name := g_lot_attributes_tbl ( x ).column_name;
                            l_attributes_in ( l_input_idx ).column_value := g_lot_attributes_tbl ( x ).column_value;
                            l_attributes_in ( l_input_idx ).column_type := g_lot_attributes_tbl ( x ).column_type;
                        END IF;
                    END LOOP;
                END IF;

                IF (( p_transaction_action_id IS NOT NULL AND p_transaction_action_id = 3 AND g_firstscan = FALSE)
          OR (  p_transaction_action_id is not null AND p_transaction_action_id = 12 )) THEN
                    IF (l_debug = 1) THEN
                       inv_pick_wave_pick_confirm_pub.tracelog ( 'Before Insert action_id=3' , 'INV_LOT_API_PUB');
                    END IF;
               BEGIN
               select count(*)
          into l_lotcount
          From mtl_lot_numbers
               where organization_id = p_transfer_organization_id
          and inventory_item_id = p_inventory_item_id
          and lot_number = p_lot_number;

          if( l_lotcount > 0 ) then
                             INSERT INTO mtl_lot_numbers
                                (
                                inventory_item_id,
                                organization_id,
                                lot_number,
                                last_update_date,
                                last_updated_by,
                                creation_date,
                                created_by,
                                last_update_login,
                                expiration_date,
                                disable_flag,
                                attribute_category,
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
                                request_id,
                                program_application_id,
                                program_id,
                                program_update_date,
                                gen_object_id,
                                description,
                                vendor_id,
                                grade_code,
                                origination_date,
                                date_code,
                                status_id,
                                change_date,
                                age,
                                retest_date,
                                maturity_date,
                                lot_attribute_category,
                                item_size,
                                color,
                                volume,
                                volume_uom,
                                place_of_origin,
                                best_by_date,
                                LENGTH,
                                length_uom,
                                recycled_content,
                                thickness,
                                thickness_uom,
                                width,
                                width_uom,
                                curl_wrinkle_fold,
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
                                supplier_lot_number,
                                n_attribute10,
                                territory_code,
                                vendor_name,
								parent_lot_number   -- bug 10176719 - inserting parent lot number
                                 )
                           SELECT inventory_item_id,
                               p_organization_id,
                               p_lot_number,
                               SYSDATE,
                               l_userid,
                               creation_date,
                               created_by,
                               last_update_login,
                               expiration_date,
                               disable_flag,
                               attribute_category,
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
                               request_id,
                               program_application_id,
                               program_id,
                               program_update_date,
                               x_object_id,
                               description,
                               vendor_id,
                               grade_code,
                               origination_date,
                               date_code,
                               decode(l_dest_status_enabled,'Y',status_id,1), --Added bug4066234,
                               change_date,
                               age,
                               retest_date,
                               maturity_date,
                               lot_attribute_category,
                               item_size,
                               color,
                               volume,
                               volume_uom,
                               place_of_origin,
                               best_by_date,
                               LENGTH,
                               length_uom,
                               recycled_content,
                               thickness,
                               thickness_uom,
                               width,
                               width_uom,
                               curl_wrinkle_fold,
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
                               supplier_lot_number,
                               n_attribute10,
                               territory_code,
                               vendor_name,
							   p_parent_lot_number   -- bug 10176719 - inserting parent lot number
                          FROM mtl_lot_numbers
                         WHERE organization_id = p_transfer_organization_id
                           AND inventory_item_id = p_inventory_item_id
                           AND lot_number = p_lot_number
                           AND NOT EXISTS (  SELECT NULL
                                              FROM mtl_lot_numbers lot
                                             WHERE lot.lot_number = p_lot_number
                                               AND lot.organization_id = p_organization_id
                                               AND lot.inventory_item_id = p_inventory_item_id );
             else
                             INSERT INTO mtl_lot_numbers
                                (
                                inventory_item_id,
                                organization_id,
                                lot_number,
                                last_update_date,
                                last_updated_by,
                                creation_date,
                                created_by,
                                last_update_login,
                                expiration_date,
                                request_id,
                                program_application_id,
                                program_id,
                                program_update_date,
                                gen_object_id,
                                description,
                                vendor_id,
                                grade_code,
                                origination_date,
                                date_code,
                                status_id,
                                change_date,
                                age,
                                retest_date,
                                maturity_date,
                                lot_attribute_category,
                                item_size,
                                color,
                                volume,
                                volume_uom,
                                place_of_origin,
                                best_by_date,
                                LENGTH,
                                length_uom,
                                recycled_content,
                                thickness,
                                thickness_uom,
                                width,
                                width_uom,
                                curl_wrinkle_fold,
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
                                supplier_lot_number,
                                n_attribute10,
                                territory_code,
                                vendor_name,
								parent_lot_number   -- bug 10176719 - inserting parent lot number
                                 )
                           SELECT mmtt.inventory_item_id,
                               p_organization_id,
                               p_lot_number,
                               SYSDATE,
                               l_userid,
                               mtlt.creation_date,
                               mtlt.created_by,
                               mtlt.last_update_login,
                               mtlt.lot_expiration_date,
                               mtlt.request_id,
                               mtlt.program_application_id,
                               mtlt.program_id,
                               mtlt.program_update_date,
                               x_object_id,
                               mtlt.description,
                               mtlt.vendor_id,
                               mtlt.grade_code,
                               mtlt.origination_date,
                               mtlt.date_code,
                               decode(l_dest_status_enabled,'Y',mtlt.status_id,1),  --Added bug4066234,
                               mtlt.change_date,
                               mtlt.age,
                               mtlt.retest_date,
                               mtlt.maturity_date,
                               mtlt.lot_attribute_category,
                               mtlt.item_size,
                               mtlt.color,
                               mtlt.volume,
                               mtlt.volume_uom,
                               mtlt.place_of_origin,
                               mtlt.best_by_date,
                               mtlt.LENGTH,
                               mtlt.length_uom,
                               mtlt.recycled_content,
                               mtlt.thickness,
                               mtlt.thickness_uom,
                               mtlt.width,
                               mtlt.width_uom,
                               mtlt.curl_wrinkle_fold,
                               mtlt.c_attribute1,
                               mtlt.c_attribute2,
                               mtlt.c_attribute3,
                               mtlt.c_attribute4,
                               mtlt.c_attribute5,
                               mtlt.c_attribute6,
                               mtlt.c_attribute7,
                               mtlt.c_attribute8,
                               mtlt.c_attribute9,
                               mtlt.c_attribute10,
                               mtlt.c_attribute11,
                               mtlt.c_attribute12,
                               mtlt.c_attribute13,
                               mtlt.c_attribute14,
                               mtlt.c_attribute15,
                               mtlt.c_attribute16,
                               mtlt.c_attribute17,
                               mtlt.c_attribute18,
                               mtlt.c_attribute19,
                               mtlt.c_attribute20,
                               mtlt.d_attribute1,
                               mtlt.d_attribute2,
                               mtlt.d_attribute3,
                               mtlt.d_attribute4,
                               mtlt.d_attribute5,
                               mtlt.d_attribute6,
                               mtlt.d_attribute7,
                               mtlt.d_attribute8,
                               mtlt.d_attribute9,
                               mtlt.d_attribute10,
                               mtlt.n_attribute1,
                               mtlt.n_attribute2,
                               mtlt.n_attribute3,
                               mtlt.n_attribute4,
                               mtlt.n_attribute5,
                               mtlt.n_attribute6,
                               mtlt.n_attribute7,
                               mtlt.n_attribute8,
                               mtlt.n_attribute9,
                               mtlt.supplier_lot_number,
                               mtlt.n_attribute10,
                               mtlt.territory_code,
                               mtlt.vendor_name,
							   p_parent_lot_number   -- bug 10176719 - inserting parent_lot_number
                          FROM mtl_transaction_lots_temp mtlt, mtl_material_transactions_temp mmtt
                         WHERE mtlt.transaction_temp_id = p_transaction_temp_id
                           AND mtlt.lot_number = p_lot_number
            AND mtlt.transaction_temp_id = mmtt.transaction_temp_id
                           AND NOT EXISTS (  SELECT NULL
                                              FROM mtl_lot_numbers lot
                                             WHERE lot.lot_number = p_lot_number
                                               AND lot.organization_id = p_organization_id
                                               AND lot.inventory_item_id = p_inventory_item_id );

           end if;
      EXCEPTION
           when no_data_found THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 IF (l_debug = 1) THEN
                    inv_log_util.trace('SQL : ' || substr(sqlerrm, 1, 200), 'INV_LOT_API_PUB','9');
               inv_log_util.trace('Error in insertLot : ', 'INV_LOT_API_PUB','9');
                 END IF;
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
           when others then
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 IF (l_debug = 1) THEN
                    inv_log_util.trace('SQL : ' || substr(sqlerrm, 1, 200), 'INV_LOT_API_PUB','9');
               inv_log_util.trace('Error in insertLot : ', 'INV_LOT_API_PUB','9');
                 END IF;
         raise FND_API.G_EXC_UNEXPECTED_ERROR;

      end;

                    -- to prepare to insert the status to status history table for the initial status
                    -- bug 1870120
                    SELECT status_id
                      INTO l_default_lot_status_id
                      FROM mtl_lot_numbers
                     WHERE lot_number = p_lot_number
                       AND organization_id = p_organization_id
                       AND inventory_item_id = p_inventory_item_id;

                    IF (l_debug = 1) THEN
                       inv_pick_wave_pick_confirm_pub.tracelog ( 'After Insert action_id=3' , 'INV_LOT_API_PUB');
                    END IF;
                ELSE -- if transaction_action_id is not 3
                    /* ---------------------------------------------------------
                     * call inv_lot_sel_attr.get_default to get the default value
                     * of the lot attributes
                     * ---------------------------------------------------------*/
                    IF ( inv_install.adv_inv_installed ( NULL ) = TRUE ) THEN

                       IF (l_debug = 1) THEN
                          inv_pick_wave_pick_confirm_pub.tracelog ( 'Before calling get_default' , 'INV_LOT_API_PUB');
                       END IF;
                        inv_lot_sel_attr.get_default (
                             x_attributes_default => l_attributes_default,
                            x_attributes_default_count => l_attributes_default_count,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            p_table_name => 'MTL_LOT_NUMBERS',
                            p_attributes_name => 'Lot Attributes',
                            p_inventory_item_id => p_inventory_item_id,
                            p_organization_id => p_organization_id,
                            p_lot_serial_number => p_lot_number,
                            p_attributes => l_attributes_in
                         );
                        IF (l_debug = 1) THEN
                           inv_pick_wave_pick_confirm_pub.tracelog ( 'After get_default' , 'INV_LOT_API_PUB');
                        END IF;

                        IF ( l_return_status <> fnd_api.g_ret_sts_success ) THEN
                            IF (l_debug = 1) THEN
                               inv_pick_wave_pick_confirm_pub.tracelog ( 'exception of get_default' , 'INV_LOT_API_PUB');
                            END IF;
                            x_return_status := l_return_status;
                            RAISE fnd_api.g_exc_unexpected_error;
                        END IF;

                        /********************************************************************
                                           Bug 2181558 - Code Starts
                              To Copy the Lot Attributes from the Start Lot to this Lot
                                 if this is a intransit transfer transaction
                                 Check for Transfer Organization ID being not null will
                              suffice the fact that it is called only for Intrasit Receipt.
                        ********************************************************************/
                        l_source_non_wms_lot_att_rec.attribute_category := NULL;
                        l_source_non_wms_lot_att_rec.attribute1         := NULL;
                        l_source_non_wms_lot_att_rec.attribute2         := NULL;
                        l_source_non_wms_lot_att_rec.attribute3         := NULL;
                        l_source_non_wms_lot_att_rec.attribute4         := NULL;
                        l_source_non_wms_lot_att_rec.attribute5         := NULL;
                        l_source_non_wms_lot_att_rec.attribute6         := NULL;
                        l_source_non_wms_lot_att_rec.attribute7         := NULL;
                        l_source_non_wms_lot_att_rec.attribute8         := NULL;
                        l_source_non_wms_lot_att_rec.attribute9         := NULL;
                        l_source_non_wms_lot_att_rec.attribute10        := NULL;
                        l_source_non_wms_lot_att_rec.attribute11        := NULL;
                        l_source_non_wms_lot_att_rec.attribute12        := NULL;
                        l_source_non_wms_lot_att_rec.attribute13        := NULL;
                        l_source_non_wms_lot_att_rec.attribute14        := NULL;
                        l_source_non_wms_lot_att_rec.attribute15        := NULL;

                        IF p_transfer_organization_id IS NOT NULL THEN
                            IF (l_debug = 1) THEN
                               inv_pick_wave_pick_confirm_pub.tracelog ( 'Before calling get_lot_att_from_source' , 'INV_LOT_API_PUB');
                            END IF;

                            get_lot_att_from_source
                            (
                                x_return_status              => l_return_status,
                                x_count                      => l_num_wms_lot_att_copied,
                                x_source_wms_lot_att_tbl     => l_att_after_source_copy,
                                x_source_non_wms_lot_att_rec => l_source_non_wms_lot_att_rec,
                                p_from_organization_id       => p_transfer_organization_id,
                                p_inventory_item_id          => p_inventory_item_id,
                                p_lot_number                 => p_lot_number,
                                p_count                      => l_attributes_default_count,
                                p_source_wms_lot_att_tbl     => l_attributes_default
                             );

                            IF ( l_return_status <> fnd_api.g_ret_sts_success ) THEN
                                x_return_status := l_return_status;
                                RAISE fnd_api.g_exc_unexpected_error;
                            END IF;

                            l_attributes_default       := l_att_after_source_copy;
                            l_attributes_default_count := l_num_wms_lot_att_copied;

                            IF (l_debug = 1) THEN
                               inv_pick_wave_pick_confirm_pub.tracelog ( 'After calling get_lot_att_from_source' , 'INV_LOT_API_PUB');
                            END IF;
                        END IF;

                        /* Bug 2181558 - Code Ends */

                        IF ( l_attributes_default_count > 0 )
                        THEN
                            FOR i IN 1 .. l_attributes_default_count LOOP
                                FOR j IN 1 .. g_lot_attributes_tbl.COUNT LOOP
                                    IF (UPPER(l_attributes_default(i).column_name) = UPPER(g_lot_attributes_tbl(j).column_name)) THEN
                                       g_lot_attributes_tbl ( j ).column_value := l_attributes_default ( i ).column_value;
                                    END IF;

                                    EXIT WHEN (UPPER(l_attributes_default(i).column_name) =
                                                   UPPER(g_lot_attributes_tbl(j).column_name));
                                END LOOP;
                            END LOOP;
                        END IF;
                    END IF;


                  /***********************************************************************
                  * Comments related to Bug 1520495 fix:
                  * g_lot_attributes_tbl(5) points to 'STATUS_ID' information. But ,
                  * 'STATUS_ID' is not part of descriptive flex field columns yet
                  * for DFF 'Lot Attributes'. So the above code can never find default
                  * value for 'STATUS_ID' in DFF segment definition. Like 'VENDOR_ID',
                  * 'STATUS_ID' could be added to DFF columns in future.
                  * Nevertheless, to fix the bug 1520495, we need to have an application
                  * logic to get the default value for 'STATUS_ID'. This can be got
                  * by using API INV_MATERIAL_STATUS_GRP.get_lot_serial_status_control()
                  * and assigning OUT parameter 'default_lot_status_id' to
                  * g_lot_attributes_tbl(5).COLUMN_VALUE if OUT parameter
                  * 'lot_status_enabled' is 'Y'.
                  ***********************************************************************/
                    IF (l_debug = 1) THEN
                       inv_pick_wave_pick_confirm_pub.tracelog ( 'before calling get_lot_Serial_status_control' , 'INV_LOT_API_PUB');
                    END IF;
                    inv_material_status_grp.get_lot_serial_status_control (
                         p_organization_id => p_organization_id,
                        p_inventory_item_id => p_inventory_item_id,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data,
                        x_lot_status_enabled => l_lot_status_enabled,
                        x_default_lot_status_id => l_default_lot_status_id,
                        x_serial_status_enabled => l_serial_status_enabled,
                        x_default_serial_status_id => l_default_serial_status_id
                     );
                    IF (l_debug = 1) THEN
                       inv_pick_wave_pick_confirm_pub.tracelog ( 'After get_lot_Serial_status_control' , 'INV_LOT_API_PUB');
                    END IF;

                    IF ( l_return_status <> fnd_api.g_ret_sts_success ) THEN
                        x_return_status := l_return_status;
                        RAISE fnd_api.g_exc_unexpected_error;
                    END IF;

                    IF ( NVL ( l_lot_status_enabled, 'Y' ) = 'Y' ) THEN
                        -- For consistency, fill after converting to 'char'
                        g_lot_attributes_tbl ( 5 ).column_value := TO_CHAR ( l_default_lot_status_id );
                    END IF;

                    --print_debug('before get_context_code 20', 4);

                    /** Populate Lot Attribute Category info. **/
                    inv_lot_sel_attr.get_context_code
                    (
                        g_lot_attributes_tbl ( 10 ).column_value,
                        p_organization_id,
                        p_inventory_item_id,
                        'Lot Attributes'
                     );
                    IF (l_debug = 1) THEN
                       inv_pick_wave_pick_confirm_pub.tracelog ( 'before inserting into mtl_lot_numbers' , 'INV_LOT_API_PUB');
                    END IF;

                    --print_debug('after get_context_code 30', 4);

                    INSERT INTO mtl_lot_numbers
                                (
                                inventory_item_id,
                                organization_id,
                                lot_number,
                                last_update_date,
                                last_updated_by,
                                creation_date,
                                created_by,
                                last_update_login,
                                expiration_date,
                                disable_flag,
                                attribute_category,
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
                                request_id,
                                program_application_id,
                                program_id,
                                program_update_date,
                                gen_object_id,
                                description,
                                vendor_id,
                                grade_code,
                                origination_date,
                                date_code,
                                status_id,
                                change_date,
                                age,
                                retest_date,
                                maturity_date,
                                lot_attribute_category,
                                item_size,
                                color,
                                volume,
                                volume_uom,
                                place_of_origin,
                                best_by_date,
                                LENGTH,
                                length_uom,
                                recycled_content,
                                thickness,
                                thickness_uom,
                                width,
                                width_uom,
                                curl_wrinkle_fold,
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
                                n_attribute10,
                                supplier_lot_number,
                                n_attribute9,
                                territory_code,
                                vendor_name,
								parent_lot_number     -- bug 10176719 - inserting parent lot number
                                 )
                         VALUES (
                                p_inventory_item_id,
                                p_organization_id,
                                p_lot_number,
                                SYSDATE,
                                l_userid,
                                SYSDATE,
                                l_userid,
                                l_loginid,
                                p_expiration_date,
                                NULL,
                                l_source_non_wms_lot_att_rec.attribute_category,
                                l_source_non_wms_lot_att_rec.attribute1,
                                l_source_non_wms_lot_att_rec.attribute2,
                                l_source_non_wms_lot_att_rec.attribute3,
                                l_source_non_wms_lot_att_rec.attribute4,
                                l_source_non_wms_lot_att_rec.attribute5,
                                l_source_non_wms_lot_att_rec.attribute6,
                                l_source_non_wms_lot_att_rec.attribute7,
                                l_source_non_wms_lot_att_rec.attribute8,
                                l_source_non_wms_lot_att_rec.attribute9,
                                l_source_non_wms_lot_att_rec.attribute10,
                                l_source_non_wms_lot_att_rec.attribute11,
                                l_source_non_wms_lot_att_rec.attribute12,
                                l_source_non_wms_lot_att_rec.attribute13,
                                l_source_non_wms_lot_att_rec.attribute14,
                                l_source_non_wms_lot_att_rec.attribute15,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                x_object_id,
                                g_lot_attributes_tbl(68).column_value,
                                TO_NUMBER(g_lot_attributes_tbl(1).column_value),
                                g_lot_attributes_tbl(2).column_value,
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(3).column_value),
                                g_lot_attributes_tbl(4).column_value,
                                decode(l_dest_status_enabled,'Y',TO_NUMBER(g_lot_attributes_tbl(5).column_value),1),  --Added bug 4066234
                                fnd_date.canonical_to_date (g_lot_attributes_tbl(6).column_value),
                                TO_NUMBER(g_lot_attributes_tbl(7).column_value),
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(8).column_value),
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(9).column_value),
                                g_lot_attributes_tbl(10).column_value,
                                TO_NUMBER(g_lot_attributes_tbl(11).column_value),
                                g_lot_attributes_tbl(12).column_value,
                                TO_NUMBER(g_lot_attributes_tbl(13).column_value),
                                g_lot_attributes_tbl(14).column_value,
                                g_lot_attributes_tbl(15).column_value,
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(16).column_value),
                                TO_NUMBER(g_lot_attributes_tbl(17).column_value),
                                g_lot_attributes_tbl(18).column_value,
                                TO_NUMBER(g_lot_attributes_tbl(19).column_value),
                                TO_NUMBER(g_lot_attributes_tbl(20).column_value),
                                g_lot_attributes_tbl(21).column_value,
                                TO_NUMBER(g_lot_attributes_tbl(22).column_value),
                                g_lot_attributes_tbl(23).column_value,
                                g_lot_attributes_tbl(24).column_value,
                                g_lot_attributes_tbl(25).column_value,
                                g_lot_attributes_tbl(26).column_value,
                                g_lot_attributes_tbl(27).column_value,
                                g_lot_attributes_tbl(28).column_value,
                                g_lot_attributes_tbl(29).column_value,
                                g_lot_attributes_tbl(30).column_value,
                                g_lot_attributes_tbl(31).column_value,
                                g_lot_attributes_tbl(32).column_value,
                                g_lot_attributes_tbl(33).column_value,
                                g_lot_attributes_tbl(34).column_value,
                                g_lot_attributes_tbl(35).column_value,
                                g_lot_attributes_tbl(36).column_value,
                                g_lot_attributes_tbl(37).column_value,
                                g_lot_attributes_tbl(38).column_value,
                                g_lot_attributes_tbl(39).column_value,
                                g_lot_attributes_tbl(40).column_value,
                                g_lot_attributes_tbl(41).column_value,
                                g_lot_attributes_tbl(42).column_value,
                                g_lot_attributes_tbl(43).column_value,
                                g_lot_attributes_tbl(44).column_value,
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(45).column_value),
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(46).column_value),
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(47).column_value),
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(48).column_value),
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(49).column_value),
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(50).column_value),
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(51).column_value),
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(52).column_value),
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(53).column_value),
                                fnd_date.canonical_to_date(g_lot_attributes_tbl(54).column_value),
                                TO_NUMBER(g_lot_attributes_tbl(55).column_value),
                                TO_NUMBER(g_lot_attributes_tbl(56).column_value),
                                TO_NUMBER(g_lot_attributes_tbl(57).column_value),
                                TO_NUMBER(g_lot_attributes_tbl(58).column_value),
                                TO_NUMBER(g_lot_attributes_tbl(59).column_value),
                                TO_NUMBER(g_lot_attributes_tbl(60).column_value),
                                TO_NUMBER(g_lot_attributes_tbl(61).column_value),
                                TO_NUMBER(g_lot_attributes_tbl(62).column_value),
                                TO_NUMBER(g_lot_attributes_tbl(63).column_value),
                                g_lot_attributes_tbl(64).column_value,
                                TO_NUMBER(g_lot_attributes_tbl(65).column_value),
                                g_lot_attributes_tbl(66).column_value,
                                g_lot_attributes_tbl(67).column_value,
								p_parent_lot_number   -- bug 10176719 - inserting parent lot number
                                 );

                    IF (l_debug = 1) THEN
                       inv_pick_wave_pick_confirm_pub.tracelog ( 'After inserting the lot' , 'INV_LOT_API_PUB');
                    END IF;

                END IF;

                -- insert into status update history table, bug 1870120
                IF ( l_default_lot_status_id IS NOT NULL AND l_dest_status_enabled = 'Y' ) THEN -- bug #4201246
                    l_status_rec.update_method := inv_material_status_pub.g_update_method_auto;
                    l_status_rec.organization_id := p_organization_id;
                    l_status_rec.inventory_item_id := p_inventory_item_id;
                    l_status_rec.lot_number := p_lot_number;
                    l_status_rec.status_id := l_default_lot_status_id;
                    l_status_rec.initial_status_flag := 'Y';
                    inv_material_status_pkg.insert_status_history ( l_status_rec);
                    IF (l_debug = 1) THEN
                       inv_pick_wave_pick_confirm_pub.tracelog ( 'after calling insert_status_history' , 'INV_LOT_API_PUB');
                    END IF;
                END IF;

                x_return_status := fnd_api.g_ret_sts_success;
            ELSE
                IF (l_debug = 1) THEN
                   inv_pick_wave_pick_confirm_pub.tracelog ( 'INV_LOT_EXISTS' , 'INV_LOT_API_PUB');
                END IF;
                fnd_message.set_name ('INV' , 'INV_LOT_EXISTS' );
                fnd_msg_pub.ADD;
                --l_return_status := FND_API.G_RET_STS_SUCCESS;
                x_return_status := fnd_api.g_ret_sts_success;
            END IF;

       IF (l_lotcount > 0 AND p_expiration_date IS NOT NULL) THEN

                l_userid := fnd_global.user_id;

                --Lot exists, but now the user has entered the lot expiration date
      IF (l_debug = 1) THEN
                  inv_pick_wave_pick_confirm_pub.tracelog ('Update the expiration date', 'INV_LOT_API_PUB');
      END IF;

                UPDATE mtl_lot_numbers
                SET    expiration_date = p_expiration_date,
                       last_update_date = SYSDATE,
                       last_updated_by = l_userid
                WHERE  inventory_item_id = p_inventory_item_id
                AND    organization_id = p_organization_id
                AND    lot_number = p_lot_number
                AND    expiration_date IS NULL ;

            END IF;
        END IF;

        -- End of API body.
        -- Standard check of p_commit.
        IF (l_debug = 1) THEN
           inv_pick_wave_pick_confirm_pub.tracelog ( 'Inserted the Lot ' || p_lot_number, 'INV_LOT_API_PUB');
        END IF;

        IF fnd_api.to_boolean ( p_commit ) THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        fnd_msg_pub.count_and_get ( p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    --x_return_status := l_return_status;

    --print_debug('end insertlot', 4);

    EXCEPTION
        WHEN OTHERS THEN
            IF (l_debug = 1) THEN
               inv_pick_wave_pick_confirm_pub.tracelog ( 'Inside the exception ' || p_lot_number, 'INV_LOT_API_PUB');
            END IF;
            --print_debug('insertlot other exception', 4);

            ROLLBACK TO apiinsertlot_apipub;

            IF fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg ('INV_LOT_API_PUB' , 'insertLot' );
            END IF;

            x_return_status := fnd_api.g_ret_sts_unexp_error;
    END insertlot;

    PROCEDURE inserttrxlot (
        p_api_version                  IN       NUMBER,
        p_init_msg_list                IN       VARCHAR2 := fnd_api.g_false,
        p_commit                       IN       VARCHAR2 := fnd_api.g_false,
        p_validation_level             IN       NUMBER
                := fnd_api.g_valid_level_full,
        p_primary_quantity             IN       NUMBER DEFAULT NULL,
        p_transaction_id               IN       NUMBER,
        p_inventory_item_id            IN       NUMBER,
        p_organization_id              IN       NUMBER,
        p_transaction_date             IN       DATE,
        p_transaction_source_id        IN       NUMBER,
        p_transaction_source_name      IN       VARCHAR2,
        p_transaction_source_type_id   IN       NUMBER,
        p_transaction_temp_id          IN       NUMBER,
        p_transaction_action_id        IN       NUMBER,
        p_serial_transaction_id        IN       NUMBER,
        p_lot_number                   IN       VARCHAR2,
        x_return_status                OUT      NOCOPY VARCHAR2,
        x_msg_count                    OUT      NOCOPY NUMBER,
        x_msg_data                     OUT      NOCOPY VARCHAR2
     )
    IS
        l_attributes_default         inv_lot_sel_attr.lot_sel_attributes_tbl_type;
        l_attributes_default_count   NUMBER;
        l_attributes_in              inv_lot_sel_attr.lot_sel_attributes_tbl_type;
        l_column_idx                 BINARY_INTEGER;
        l_return_status              VARCHAR2 ( 1 );
        l_msg_data                   VARCHAR2 ( 2000 );
        l_msg_count                  NUMBER;
        l_input_idx                  BINARY_INTEGER;
        l_userid                     NUMBER;
        l_loginid                    NUMBER;
        l_api_version       CONSTANT NUMBER                                       := 1.0;
        l_api_name          CONSTANT VARCHAR2 ( 30 )                              := 'insertTrxLot';
        l_mmtt_pri_quantity          NUMBER                                      := 0;
        l_transaction_quantity       NUMBER;
        l_primary_quantity           NUMBER;

        CURSOR lot_temp_csr ( p_lot_number VARCHAR2, p_trx_temp_id NUMBER )
        IS
            SELECT TO_CHAR ( vendor_id ),
                   grade_code,
                   fnd_date.date_to_canonical ( origination_date ),
                   date_code,
                   TO_CHAR ( status_id ),
                   fnd_date.date_to_canonical ( change_date ),
                   TO_NUMBER ( age ),
                   fnd_date.date_to_canonical ( retest_date ),
                   fnd_date.date_to_canonical ( maturity_date ),
                   lot_attribute_category,
                   TO_CHAR ( item_size ),
                   color,
                   TO_CHAR ( volume ),
                   volume_uom,
                   place_of_origin,
                   fnd_date.date_to_canonical ( best_by_date ),
                   TO_CHAR ( LENGTH ),
                   length_uom,
                   TO_CHAR ( recycled_content ),
                   TO_CHAR ( thickness ),
                   thickness_uom,
                   TO_CHAR ( width ),
                   width_uom,
                   curl_wrinkle_fold,
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
                   fnd_date.date_to_canonical ( d_attribute1 ),
                   fnd_date.date_to_canonical ( d_attribute2 ),
                   fnd_date.date_to_canonical ( d_attribute3 ),
                   fnd_date.date_to_canonical ( d_attribute4 ),
                   fnd_date.date_to_canonical ( d_attribute5 ),
                   fnd_date.date_to_canonical ( d_attribute6 ),
                   fnd_date.date_to_canonical ( d_attribute7 ),
                   fnd_date.date_to_canonical ( d_attribute8 ),
                   fnd_date.date_to_canonical ( d_attribute9 ),
                   fnd_date.date_to_canonical ( d_attribute10 ),
                   TO_CHAR ( n_attribute1 ),
                   TO_CHAR ( n_attribute2 ),
                   TO_CHAR ( n_attribute3 ),
                   TO_CHAR ( n_attribute4 ),
                   TO_CHAR ( n_attribute5 ),
                   TO_CHAR ( n_attribute6 ),
                   TO_CHAR ( n_attribute7 ),
                   TO_CHAR ( n_attribute8 ),
                   TO_CHAR ( n_attribute10 ),
                   supplier_lot_number,
                   TO_CHAR ( n_attribute9 ),
                   territory_code,
                   vendor_name
              FROM mtl_transaction_lots_temp
             WHERE lot_number = p_lot_number
               AND transaction_temp_id = p_trx_temp_id;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT apiinsertlot_apipub;

        -- Standard call to check for call compatibility.
        IF NOT fnd_api.compatible_api_call (
                    l_api_version,
                   p_api_version,
                   l_api_name,
                   g_pkg_name
                )
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF fnd_api.to_boolean ( p_init_msg_list )
        THEN
            fnd_msg_pub.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;
        -- API body

        if( l_debug = 1 ) then
           print_debug('Calling populateattributescolumn()', 10);
           print_debug('p_transaction_temp_id is ' || p_transaction_temp_id, 10);
           print_debug('p_transaction_action_id is ' || p_transaction_action_id, 10);
           if( g_firstScan = false ) then
                print_debug('g_firstscan is false', 10);
           else
                print_debug('g_firstscan is true', 10);
           end if;
        end if;

        populateattributescolumn ( );
        l_userid := fnd_global.user_id;
        l_loginid := fnd_global.login_id;
        l_mmtt_pri_quantity := 0;

        IF ( p_primary_quantity IS NOT NULL )
        THEN
            IF p_primary_quantity < 0
            THEN
                l_mmtt_pri_quantity := 1;
            ELSE
                l_mmtt_pri_quantity := 0;
            END IF;
        ELSE
            l_mmtt_pri_quantity := 0;
        END IF;

        IF ( p_transaction_temp_id IS NOT NULL )
        THEN
            OPEN lot_temp_csr ( p_lot_number, p_transaction_temp_id );

            LOOP
                FETCH lot_temp_csr INTO g_lot_attributes_tbl ( 1 ).column_value,
                                        g_lot_attributes_tbl ( 2 ).column_value,
                                        g_lot_attributes_tbl ( 3 ).column_value,
                                        g_lot_attributes_tbl ( 4 ).column_value,
                                        g_lot_attributes_tbl ( 5 ).column_value,
                                        g_lot_attributes_tbl ( 6 ).column_value,
                                        g_lot_attributes_tbl ( 7 ).column_value,
                                        g_lot_attributes_tbl ( 8 ).column_value,
                                        g_lot_attributes_tbl ( 9 ).column_value,
                                        g_lot_attributes_tbl ( 10 ).column_value,
                                        g_lot_attributes_tbl ( 11 ).column_value,
                                        g_lot_attributes_tbl ( 12 ).column_value,
                                        g_lot_attributes_tbl ( 13 ).column_value,
                                        g_lot_attributes_tbl ( 14 ).column_value,
                                        g_lot_attributes_tbl ( 15 ).column_value,
                                        g_lot_attributes_tbl ( 16 ).column_value,
                                        g_lot_attributes_tbl ( 17 ).column_value,
                                        g_lot_attributes_tbl ( 18 ).column_value,
                                        g_lot_attributes_tbl ( 19 ).column_value,
                                        g_lot_attributes_tbl ( 20 ).column_value,
                                        g_lot_attributes_tbl ( 21 ).column_value,
                                        g_lot_attributes_tbl ( 22 ).column_value,
                                        g_lot_attributes_tbl ( 23 ).column_value,
                                        g_lot_attributes_tbl ( 24 ).column_value,
                                        g_lot_attributes_tbl ( 25 ).column_value,
                                        g_lot_attributes_tbl ( 26 ).column_value,
                                        g_lot_attributes_tbl ( 27 ).column_value,
                                        g_lot_attributes_tbl ( 28 ).column_value,
                                        g_lot_attributes_tbl ( 29 ).column_value,
                                        g_lot_attributes_tbl ( 30 ).column_value,
                                        g_lot_attributes_tbl ( 31 ).column_value,
                                        g_lot_attributes_tbl ( 32 ).column_value,
                                        g_lot_attributes_tbl ( 33 ).column_value,
                                        g_lot_attributes_tbl ( 34 ).column_value,
                                        g_lot_attributes_tbl ( 35 ).column_value,
                                        g_lot_attributes_tbl ( 36 ).column_value,
                                        g_lot_attributes_tbl ( 37 ).column_value,
                                        g_lot_attributes_tbl ( 38 ).column_value,
                                        g_lot_attributes_tbl ( 39 ).column_value,
                                        g_lot_attributes_tbl ( 40 ).column_value,
                                        g_lot_attributes_tbl ( 41 ).column_value,
                                        g_lot_attributes_tbl ( 42 ).column_value,
                                        g_lot_attributes_tbl ( 43 ).column_value,
                                        g_lot_attributes_tbl ( 44 ).column_value,
                                        g_lot_attributes_tbl ( 45 ).column_value,
                                        g_lot_attributes_tbl ( 46 ).column_value,
                                        g_lot_attributes_tbl ( 47 ).column_value,
                                        g_lot_attributes_tbl ( 48 ).column_value,
                                        g_lot_attributes_tbl ( 49 ).column_value,
                                        g_lot_attributes_tbl ( 50 ).column_value,
                                        g_lot_attributes_tbl ( 51 ).column_value,
                                        g_lot_attributes_tbl ( 52 ).column_value,
                                        g_lot_attributes_tbl ( 53 ).column_value,
                                        g_lot_attributes_tbl ( 54 ).column_value,
                                        g_lot_attributes_tbl ( 55 ).column_value,
                                        g_lot_attributes_tbl ( 56 ).column_value,
                                        g_lot_attributes_tbl ( 57 ).column_value,
                                        g_lot_attributes_tbl ( 58 ).column_value,
                                        g_lot_attributes_tbl ( 59 ).column_value,
                                        g_lot_attributes_tbl ( 60 ).column_value,
                                        g_lot_attributes_tbl ( 61 ).column_value,
                                        g_lot_attributes_tbl ( 62 ).column_value,
                                        g_lot_attributes_tbl ( 63 ).column_value,
                                        g_lot_attributes_tbl ( 64 ).column_value,
                                        g_lot_attributes_tbl ( 65 ).column_value,
                                        g_lot_attributes_tbl ( 66 ).column_value,
                                        g_lot_attributes_tbl ( 67 ).column_value;
                EXIT WHEN lot_temp_csr%NOTFOUND;
            END LOOP;

            CLOSE lot_temp_csr;
            l_input_idx := 0;

            FOR x IN 1 .. 67
            LOOP
                IF ( g_lot_attributes_tbl ( x ).column_value IS NOT NULL )
                THEN
                    l_input_idx := l_input_idx + 1;
                    l_attributes_in ( l_input_idx ).column_name :=
                                       g_lot_attributes_tbl ( x ).column_name;
                    l_attributes_in ( l_input_idx ).column_value :=
                                      g_lot_attributes_tbl ( x ).column_value;
                    l_attributes_in ( l_input_idx ).column_type :=
                                       g_lot_attributes_tbl ( x ).column_type;
                END IF;
            END LOOP;
        END IF;

        IF ( p_transaction_action_id IS NOT NULL AND p_transaction_action_id = 3 ) THEN

-- Changes for bug 2221892 for same lot being provided as
-- multiple lots with different quantities for inter-org
-- transfer transactions
/*            SELECT transaction_quantity,
                   primary_quantity
              INTO l_transaction_quantity,
                   l_primary_quantity
              FROM mtl_transaction_lots_temp
             WHERE transaction_temp_id = p_transaction_temp_id
               AND lot_number = p_lot_number;
*/

            INSERT INTO mtl_transaction_lot_numbers
                        (
                        transaction_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        inventory_item_id,
                        organization_id,
                        transaction_date,
                        transaction_source_id,
                        transaction_source_type_id,
                        transaction_source_name,
                        transaction_quantity,
                        primary_quantity,
                        lot_number,
                        serial_transaction_id,
                        description,
                        supplier_lot_number,
                        origination_date,
                        date_code,
                        grade_code,
                        change_date,
                        maturity_date,
                        status_id,
                        retest_date,
                        age,
                        item_size,
                        color,
                        volume,
                        volume_uom,
                        place_of_origin,
                        best_by_date,
                        LENGTH,
                        length_uom,
                        width,
                        width_uom,
                        recycled_content,
                        thickness,
                        thickness_uom,
                        curl_wrinkle_fold,
                        lot_attribute_category,
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
                        n_attribute10,
                        vendor_id,
                        territory_code,
                        vendor_name,
              product_code,
              product_transaction_id
                         )
                SELECT p_transaction_id,
                       SYSDATE,
                       l_userid,
                       MLN.creation_date,
                       MLN.created_by,
                       MLN.last_update_login,
                       p_inventory_item_id,
                       p_organization_id,
                       p_transaction_date,
                       p_transaction_source_id,
                       p_transaction_source_type_id,
                       p_transaction_source_name,
                       ROUND ( ABS ( MTLT.transaction_quantity ), 5 ),
                       ROUND ( ABS ( MTLT.primary_quantity ), 5 ),
                       MLN.lot_number,
                       p_serial_transaction_id,
                       MLN.description,
                       MLN.supplier_lot_number,
                       MLN.origination_date,
                       MLN.date_code,
                       MLN.grade_code,
                       MLN.change_date,
                       MLN.maturity_date,
                       MLN.status_id,
                       MLN.retest_date,
                       MLN.age,
                       MLN.item_size,
                       MLN.color,
                       MLN.volume,
                       MLN.volume_uom,
                       MLN.place_of_origin,
                       MLN.best_by_date,
                       MLN.LENGTH,
                       MLN.length_uom,
                       MLN.width,
                       MLN.width_uom,
                       MLN.recycled_content,
                       MLN.thickness,
                       MLN.thickness_uom,
                       MLN.curl_wrinkle_fold,
                       MLN.lot_attribute_category,
                       MLN.c_attribute1,
                       MLN.c_attribute2,
                       MLN.c_attribute3,
                       MLN.c_attribute4,
                       MLN.c_attribute5,
                       MLN.c_attribute6,
                       MLN.c_attribute7,
                       MLN.c_attribute8,
                       MLN.c_attribute9,
                       MLN.c_attribute10,
                       MLN.c_attribute11,
                       MLN.c_attribute12,
                       MLN.c_attribute13,
                       MLN.c_attribute14,
                       MLN.c_attribute15,
                       MLN.c_attribute16,
                       MLN.c_attribute17,
                       MLN.c_attribute18,
                       MLN.c_attribute19,
                       MLN.c_attribute20,
                       MLN.d_attribute1,
                       MLN.d_attribute2,
                       MLN.d_attribute3,
                       MLN.d_attribute4,
                       MLN.d_attribute5,
                       MLN.d_attribute6,
                       MLN.d_attribute7,
                       MLN.d_attribute8,
                       MLN.d_attribute9,
                       MLN.d_attribute10,
                       MLN.n_attribute1,
                       MLN.n_attribute2,
                       MLN.n_attribute3,
                       MLN.n_attribute4,
                       MLN.n_attribute5,
                       MLN.n_attribute6,
                       MLN.n_attribute7,
                       MLN.n_attribute8,
                       MLN.n_attribute9,
                       MLN.n_attribute10,
                       MLN.vendor_id,
                       MLN.territory_code,
                       MLN.vendor_name,
             mtlt.product_code,
             mtlt.product_transaction_id
                  FROM mtl_lot_numbers MLN,
                       mtl_transaction_lots_temp MTLT
                 WHERE MLN.organization_id = p_organization_id
                   AND MLN.inventory_item_id = p_inventory_item_id
                   AND MLN.lot_number = p_lot_number
                   AND MTLT.lot_number = MLN.lot_number
                   AND MTLT.transaction_temp_id = p_transaction_temp_id
--                   AND MTLT.LOT_NUMBER = p_lot_number
                   and not exists (
                           select  null
                           from    mtl_transaction_lot_numbers mtln
                           where   mtln.lot_number = p_lot_number
                           and     mtln.primary_quantity = round(abs(MTLT.PRIMARY_QUANTITY),5)
                           and     mtln.inventory_item_id = p_inventory_item_id
                           and     mtln.organization_id   = p_organization_id
                           and     mtln.transaction_date  = p_transaction_date
                           and     nvl(mtln.transaction_source_id,-1)  = nvl(p_transaction_source_id,-1)
                           and     nvl(mtln.transaction_source_type_id,-1) = nvl(p_transaction_source_type_id,-1)
                           and     nvl(mtln.transaction_source_name,'$$$') = nvl(p_transaction_source_name,'$$$')
                           and     mtln.transaction_id = p_transaction_id
                                  );

--                   AND ROWNUM < 2;

/*
            and not exists
                (select NULL
                 from MTL_LOT_NUMBERS LOT
                where LOT.lot_number = p_lot_number
                  and LOT.organization_id  = p_organization_id
                  and LOT.inventory_item_id = p_inventory_item_id);
*/
        ELSE
            /* ---------------------------------------------------------
             * call inv_lot_sel_attr.get_default to get the default value
             * of the lot attributes
             * ---------------------------------------------------------*/
            IF ( inv_install.adv_inv_installed ( NULL ) = TRUE )
            THEN
                inv_lot_sel_attr.get_default (
                     x_attributes_default => l_attributes_default,
                    x_attributes_default_count => l_attributes_default_count,
                    x_return_status => l_return_status,
                    x_msg_count => l_msg_count,
                    x_msg_data => l_msg_data,
                    p_table_name => 'MTL_LOT_NUMBERS',
                    p_attributes_name => 'Lot Attributes',
                    p_inventory_item_id => p_inventory_item_id,
                    p_organization_id => p_organization_id,
                    p_lot_serial_number => p_lot_number,
                    p_attributes => l_attributes_in
                 );

                IF ( l_return_status <> fnd_api.g_ret_sts_success )
                THEN
                    x_return_status := l_return_status;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF ( l_attributes_default_count > 0 )
                THEN
                    FOR i IN 1 .. l_attributes_default_count
                    LOOP
                        FOR j IN 1 .. g_lot_attributes_tbl.COUNT
                        LOOP
                            IF ( UPPER (
                                     l_attributes_default ( i ).column_name
                                 ) = UPPER (
                                          g_lot_attributes_tbl ( j ).column_name
                                      )
                                )
                            THEN
                                g_lot_attributes_tbl ( j ).column_value :=
                                      l_attributes_default ( i ).column_value;
                            END IF;

                            EXIT WHEN ( UPPER (
                                            l_attributes_default ( i ).column_name
                                        ) =
                                           UPPER (
                                                g_lot_attributes_tbl ( j ).column_name
                                            )
                                       );
                        END LOOP;
                    END LOOP;
                END IF;
            END IF;

            /** Populate Lot Attribute Category info. **/
            inv_lot_sel_attr.get_context_code (
                 g_lot_attributes_tbl ( 10 ).column_value,
                p_organization_id,
                p_inventory_item_id,
                'Lot Attributes'
             );

            INSERT INTO mtl_transaction_lot_numbers
                        (
                        transaction_id,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        inventory_item_id,
                        organization_id,
                        transaction_date,
                        transaction_source_id,
                        transaction_source_type_id,
                        transaction_source_name,
                        transaction_quantity,
                        primary_quantity,
                        lot_number,
                        serial_transaction_id,
                        description,
                        vendor_id,
                        grade_code,
                        origination_date,
                        date_code,
                        status_id,
                        change_date,
                        age,
                        retest_date,
                        maturity_date,
                        lot_attribute_category,
                        item_size,
                        color,
                        volume,
                        volume_uom,
                        place_of_origin,
                        best_by_date,
                        LENGTH,
                        length_uom,
                        recycled_content,
                        thickness,
                        thickness_uom,
                        width,
                        width_uom,
                        curl_wrinkle_fold,
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
                        n_attribute10,
                        supplier_lot_number,
                        n_attribute9,
                        territory_code,
                        vendor_name,
                   product_code,
                   product_transaction_id
                         )
                SELECT p_transaction_id,
                       SYSDATE,
                       l_userid,
                       SYSDATE,
                       l_userid,
                       l_loginid,
                       p_inventory_item_id,
                       p_organization_id,
                       p_transaction_date,
                       p_transaction_source_id,
                       p_transaction_source_type_id,
                       p_transaction_source_name,
                       DECODE (
                            l_mmtt_pri_quantity,
                           1, ROUND (
                                   ( ABS ( transaction_quantity ) * -1 ),
                                  5
                               ),
                           ROUND ( ABS ( transaction_quantity ), 5 )
                        ),
                       DECODE (
                            l_mmtt_pri_quantity,
                           1, ROUND ( ( ABS ( primary_quantity ) * -1 ), 5 ),
                           ROUND ( ABS ( primary_quantity ), 5 )
                        ),
                       p_lot_number,
                       p_serial_transaction_id,
                       description,
                       TO_NUMBER ( g_lot_attributes_tbl ( 1 ).column_value ),
                       g_lot_attributes_tbl ( 2 ).column_value,
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 3 ).column_value
                        ),
                       g_lot_attributes_tbl ( 4 ).column_value,
                       TO_NUMBER ( g_lot_attributes_tbl ( 5 ).column_value ),
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 6 ).column_value
                        ),
                       TO_NUMBER ( g_lot_attributes_tbl ( 7 ).column_value ),
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 8 ).column_value
                        ),
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 9 ).column_value
                        ),
                       g_lot_attributes_tbl ( 10 ).column_value,
                       TO_NUMBER ( g_lot_attributes_tbl ( 11 ).column_value ),
                       g_lot_attributes_tbl ( 12 ).column_value,
                       TO_NUMBER ( g_lot_attributes_tbl ( 13 ).column_value ),
                       g_lot_attributes_tbl ( 14 ).column_value,
                       g_lot_attributes_tbl ( 15 ).column_value,
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 16 ).column_value
                        ),
                       TO_NUMBER ( g_lot_attributes_tbl ( 17 ).column_value ),
                       g_lot_attributes_tbl ( 18 ).column_value,
                       TO_NUMBER ( g_lot_attributes_tbl ( 19 ).column_value ),
                       TO_NUMBER ( g_lot_attributes_tbl ( 20 ).column_value ),
                       g_lot_attributes_tbl ( 21 ).column_value,
                       TO_NUMBER ( g_lot_attributes_tbl ( 22 ).column_value ),
                       g_lot_attributes_tbl ( 23 ).column_value,
                       g_lot_attributes_tbl ( 24 ).column_value,
                       g_lot_attributes_tbl ( 25 ).column_value,
                       g_lot_attributes_tbl ( 26 ).column_value,
                       g_lot_attributes_tbl ( 27 ).column_value,
                       g_lot_attributes_tbl ( 28 ).column_value,
                       g_lot_attributes_tbl ( 29 ).column_value,
                       g_lot_attributes_tbl ( 30 ).column_value,
                       g_lot_attributes_tbl ( 31 ).column_value,
                       g_lot_attributes_tbl ( 32 ).column_value,
                       g_lot_attributes_tbl ( 33 ).column_value,
                       g_lot_attributes_tbl ( 34 ).column_value,
                       g_lot_attributes_tbl ( 35 ).column_value,
                       g_lot_attributes_tbl ( 36 ).column_value,
                       g_lot_attributes_tbl ( 37 ).column_value,
                       g_lot_attributes_tbl ( 38 ).column_value,
                       g_lot_attributes_tbl ( 39 ).column_value,
                       g_lot_attributes_tbl ( 40 ).column_value,
                       g_lot_attributes_tbl ( 41 ).column_value,
                       g_lot_attributes_tbl ( 42 ).column_value,
                       g_lot_attributes_tbl ( 43 ).column_value,
                       g_lot_attributes_tbl ( 44 ).column_value,
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 45 ).column_value
                        ),
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 46 ).column_value
                        ),
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 47 ).column_value
                        ),
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 48 ).column_value
                        ),
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 49 ).column_value
                        ),
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 50 ).column_value
                        ),
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 51 ).column_value
                        ),
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 52 ).column_value
                        ),
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 53 ).column_value
                        ),
                       fnd_date.canonical_to_date (
                            g_lot_attributes_tbl ( 54 ).column_value
                        ),
                       TO_NUMBER ( g_lot_attributes_tbl ( 55 ).column_value ),
                       TO_NUMBER ( g_lot_attributes_tbl ( 56 ).column_value ),
                       TO_NUMBER ( g_lot_attributes_tbl ( 57 ).column_value ),
                       TO_NUMBER ( g_lot_attributes_tbl ( 58 ).column_value ),
                       TO_NUMBER ( g_lot_attributes_tbl ( 59 ).column_value ),
                       TO_NUMBER ( g_lot_attributes_tbl ( 60 ).column_value ),
                       TO_NUMBER ( g_lot_attributes_tbl ( 61 ).column_value ),
                       TO_NUMBER ( g_lot_attributes_tbl ( 62 ).column_value ),
                       TO_NUMBER ( g_lot_attributes_tbl ( 63 ).column_value ),
                       g_lot_attributes_tbl ( 64 ).column_value,
                       TO_NUMBER ( g_lot_attributes_tbl ( 65 ).column_value ),
                       g_lot_attributes_tbl ( 66 ).column_value,
                       g_lot_attributes_tbl ( 67 ).column_value,
                  mtlt.product_code,
                  mtlt.product_transaction_id
                  FROM mtl_transaction_lots_temp mtlt
                 WHERE transaction_temp_id = p_transaction_temp_id
                   AND lot_number = p_lot_number
                   --  Hack for bug 2130268
                   --  What if any transaction has the same lot 'p_lot_number' twice !!
                   --  The insert statement then inserts two records instead of one,
                   --  hence the following 'not exists' clause
                   AND NOT EXISTS (
                                SELECT NULL
                                 FROM mtl_transaction_lot_numbers mtln
                                WHERE mtln.lot_number = p_lot_number
                                  AND mtln.primary_quantity =
                                          DECODE (
                                               l_mmtt_pri_quantity,
                                              1, ROUND (
                                                      (   ABS (
                                                              mtlt.primary_quantity
                                                          )
                                                       * -1
                                                      ),
                                                     5
                                                  ),
                                              ROUND (
                                                   ABS (
                                                       mtlt.primary_quantity
                                                   ),
                                                  5
                                               )
                                           )
                                  AND mtln.inventory_item_id =
                                                           p_inventory_item_id
                                  AND mtln.organization_id = p_organization_id
                                  AND mtln.transaction_date =
                                                            p_transaction_date
                                  AND NVL ( mtln.transaction_source_id, -1 ) =
                                            NVL ( p_transaction_source_id, -1 )
                                  AND NVL (
                                           mtln.transaction_source_type_id,
                                          -1
                                       ) = NVL (
                                                p_transaction_source_type_id,
                                               -1
                                            )
                                  AND NVL (
                                           mtln.transaction_source_name,
                                          '$$$'
                                       ) = NVL (
                                                p_transaction_source_name,
                                               '$$$'
                                            )
                                  AND mtln.transaction_id = p_transaction_id );

            --  Hack for bug 2130268
            x_return_status := fnd_api.g_ret_sts_success;
        END IF;

        IF ( fnd_api.to_boolean ( p_commit ) )
        THEN
            COMMIT;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        fnd_msg_pub.count_and_get (
             p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
         );
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO apiinsertlot_apipub;

            IF fnd_msg_pub.check_msg_level (
                    fnd_msg_pub.g_msg_lvl_unexp_error
                )
            THEN
                fnd_msg_pub.add_exc_msg ('INV_LOT_API_PUB' , 'insertLot' );
            END IF;

            x_return_status := fnd_api.g_ret_sts_unexp_error;
    END inserttrxlot;

    FUNCTION validate_unique_lot (
        p_org_id              IN   NUMBER,
        p_inventory_item_id   IN   NUMBER,
        p_lot_uniqueness      IN   NUMBER,
        p_auto_lot_number     IN   VARCHAR2
     )
        RETURN BOOLEAN
    IS
        l_lot_number          NUMBER          := 0;
        l_lot_uniqueness      NUMBER          := p_lot_uniqueness;
        l_count               NUMBER          := 0;
        l_api_name   CONSTANT VARCHAR2 ( 50 )
                    := 'INV_LOT_API_PUB.validate_unique_lot';

        CURSOR mln_cur_2
        IS
            SELECT lot_number
              FROM mtl_lot_numbers
             WHERE lot_number = p_auto_lot_number
               AND inventory_item_id <> p_inventory_item_id;

        CURSOR mtln_cur_2
        IS
            SELECT lot_number
              FROM mtl_transaction_lot_numbers
             WHERE lot_number = p_auto_lot_number
               AND inventory_item_id <> p_inventory_item_id;

        CURSOR mtlt_cur_2
        IS
            SELECT lot.lot_number
              FROM mtl_transaction_lots_temp lot,
                   mtl_material_transactions_temp mmtt
             WHERE lot.transaction_temp_id = mmtt.transaction_temp_id
               AND lot.lot_number = p_auto_lot_number
               AND mmtt.inventory_item_id <> p_inventory_item_id;

        CURSOR mmtt_cur_2
        IS
            SELECT lot_number
              FROM mtl_material_transactions_temp lot
             WHERE lot_number = p_auto_lot_number
               AND inventory_item_id <> p_inventory_item_id;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN
        IF l_lot_uniqueness IS NULL
        THEN
            BEGIN
                SELECT lot_number_uniqueness
                  INTO l_lot_uniqueness
                  FROM mtl_parameters
                 WHERE organization_id = p_org_id;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    RAISE fnd_api.g_exc_error;
            END;
        END IF;

        IF ( l_lot_uniqueness = 1 ) -- Item level control
        THEN
            BEGIN
                FOR mln_rec IN mln_cur_2
                LOOP
                    l_count := 1;
                    EXIT;
                END LOOP;

                IF ( l_count > 0 )
                THEN
                    RETURN FALSE;
                ELSE
                    l_count := 0;
                END IF;

                FOR mtln_rec IN mtln_cur_2
                LOOP
                    l_count := 1;
                    EXIT;
                END LOOP;

                IF ( l_count > 0 )
                THEN
                    RETURN FALSE;
                ELSE
                    l_count := 0;
                END IF;

                FOR mtlt_rec IN mtlt_cur_2
                LOOP
                    l_count := 1;
                    EXIT;
                END LOOP;

                IF ( l_count > 0 )
                THEN
                    RETURN FALSE;
                ELSE
                    l_count := 0;
                END IF;

                FOR mtlt_rec IN mtlt_cur_2
                LOOP
                    l_count := 1;
                    EXIT;
                END LOOP;

                IF ( l_count > 0 )
                THEN
                    RETURN FALSE;
                END IF;
            END;
        END IF;

        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF fnd_msg_pub.check_msg_level (
                    fnd_msg_pub.g_msg_lvl_unexp_error
                )
            THEN
                fnd_msg_pub.add_exc_msg ( g_pkg_name, l_api_name );
            END IF;

            RETURN FALSE;
    END validate_unique_lot;

    PROCEDURE update_msi (
        p_org_id              IN       NUMBER,
        p_inventory_item_id   IN       NUMBER,
        p_new_suffix          IN       VARCHAR2,
        p_lot_uniqueness      IN       NUMBER DEFAULT NULL,
        p_lot_generation      IN       NUMBER DEFAULT NULL,
        x_return_status       OUT      NOCOPY VARCHAR2,
        p_lot_prefix          IN       VARCHAR2  -- Bug# 7298723
     )
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    l_debug number        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_update_count number := 0; -- Bug# 7298723

    /* Added for bug 8428348 */
    l_return_status     VARCHAR2(1)     := NULL;
    l_got_lock          BOOLEAN         := FALSE;
    /* End of changes for bug 8428348 */

    BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      IF (l_debug =1 ) THEN
        print_debug('before updating msi '||p_lot_prefix,9);
      END IF;

    /* Added for bug 8428348 */
    l_got_lock:= inv_lot_sel_attr.lock_lot_records(p_org_id
                                                     , p_inventory_item_id
                                                     , p_lot_uniqueness
                                                     , p_lot_generation
                                                     , p_lot_prefix
                                                     , l_return_status);

    IF NOT (l_got_lock) THEN
        IF l_return_status  <> 'S' THEN
            x_return_status  := fnd_api.g_ret_sts_error;
        END IF;
        ROLLBACK;
    ELSE  /*  not (l_got_lock) */
        print_debug('Got lock on lot items ', 9);
     /* end of changes for bug 8428348 */
        if( p_lot_generation = 2 AND p_lot_uniqueness = 1 ) THEN
            UPDATE mtl_system_items_b
            SET start_auto_lot_number = p_new_suffix
            -- Bug# 7298723
            -- WHERE organization_id = p_org_id
            WHERE auto_lot_alpha_prefix = p_lot_prefix
            AND   lot_control_code = 2;
            -- End of Bug# 7298723
            --AND inventory_item_id = p_inventory_item_id;
            l_update_count := SQL%ROWCOUNT; -- Bug# 7298723

        elsif( p_lot_generation = 2 and p_lot_uniqueness <> 1 ) THEN
            UPDATE mtl_system_items
            SET start_auto_lot_number = p_new_suffix
            WHERE organization_id = p_org_id
            AND inventory_item_id = p_inventory_item_id;

            l_update_count := SQL%ROWCOUNT; -- Bug# 7298723

        end if;
        -- Bug 2700722.. commit the transaction after confirming that records exist
        --   else, return an error status
        -- COMMIT;

        IF l_update_count > 0 THEN -- Bug# 7298723
            IF (l_debug =1 ) THEN
              print_debug('commiting',9);
            END IF;

            COMMIT;

        ELSE
            ROLLBACK;
            IF (l_debug =1 ) THEN
              print_debug('not found',9);
            END IF;
            fnd_message.set_name ('INV' , 'INV_LOT_AUTOGEN_FAILED' );            -- Bug# 7298723
            -- fnd_message.set_token ('ENTITY1' , 'Item with last lot number' ); -- Bug# 7298723
            fnd_msg_pub.ADD;
            x_return_status := fnd_api.g_ret_sts_error;
            --AND inventory_item_id     = p_inventory_item_id;
        END IF;
    END IF; /* if not (l_got_lock) */
    END;

/*=============================================================
   Autonomous function to insert to mtl_child_lot_numbers.
   Added by Joe DiIorio for OPM Convergence.  05/18/2004
  =============================================================*/


FUNCTION ins_mtl_child_lot_num (
        p_org_id                       IN       NUMBER,
        p_inventory_item_id            IN       NUMBER,
        p_parent_lot_number            IN       VARCHAR2,
        p_last_child_lot_seq           IN       NUMBER
     )
        RETURN NUMBER
IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_userid                               FND_USER.USER_ID%TYPE;
l_loginid                              NUMBER;

BEGIN

    l_userid := fnd_global.user_id;
    l_loginid := fnd_global.login_id;

    INSERT into mtl_child_lot_numbers
              (organization_id, inventory_item_id,
               parent_lot_number, last_child_lot_number_seq,
               creation_date, created_by, last_update_date,
               last_updated_by, last_update_login)
    VALUES (p_org_id, p_inventory_item_id, p_parent_lot_number,
             p_last_child_lot_seq, SYSDATE, l_userid,
             SYSDATE, l_userid, l_loginid);

    COMMIT;
    RETURN SQLCODE;

END ins_mtl_child_lot_num;


/*=============================================================
   Autonomous function to update to mtl_child_lot_numbers.
   Added by Joe DiIorio for OPM Convergence.  05/18/2004
  =============================================================*/

FUNCTION upd_mtl_child_lot_num (
        p_org_id                       IN       NUMBER,
        p_inventory_item_id            IN       NUMBER,
        p_parent_lot_number            IN       VARCHAR2,
        p_last_child_lot_seq           IN       NUMBER
     )
        RETURN NUMBER
IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_userid                               FND_USER.USER_ID%TYPE;
l_loginid                              NUMBER;

BEGIN

    l_userid := fnd_global.user_id;
    l_loginid := fnd_global.login_id;
    UPDATE mtl_child_lot_numbers
    SET last_child_lot_number_seq = p_last_child_lot_seq,
        last_updated_by = l_userid,
        last_update_date = SYSDATE,
        last_update_login = l_loginid
    WHERE organization_id = p_org_id
    AND   inventory_item_id = p_inventory_item_id
    AND   parent_lot_number = p_parent_lot_number;

    COMMIT;
    RETURN SQLCODE;

END upd_mtl_child_lot_num;



--
-- Fix for Bug#12925054
-- Added new parameters p_transaction_source_id and p_transaction_source_line_id

    FUNCTION auto_gen_lot (
        p_org_id                       IN       NUMBER,
        p_inventory_item_id            IN       NUMBER,
        p_lot_generation               IN       NUMBER := NULL,
        p_lot_uniqueness               IN       NUMBER := NULL,
        p_lot_prefix                   IN       VARCHAR2 := NULL,
        p_zero_pad                     IN       NUMBER := NULL,
        p_lot_length                   IN       NUMBER := NULL,
        p_transaction_date             IN       DATE := NULL,
        p_revision                     IN       VARCHAR2 := NULL,
        p_subinventory_code            IN       VARCHAR2 := NULL,
        p_locator_id                   IN       NUMBER := NULL,
        p_transaction_type_id          IN       NUMBER := NULL,
        p_transaction_action_id        IN       NUMBER := NULL,
        p_transaction_source_type_id   IN       NUMBER := NULL,
        p_lot_number                   IN       VARCHAR2 := NULL,
        p_api_version                  IN       NUMBER,
        p_init_msg_list                IN       VARCHAR2 := fnd_api.g_false,
        p_commit                       IN       VARCHAR2 := fnd_api.g_false,
        p_validation_level             IN       NUMBER
                := fnd_api.g_valid_level_full,
        p_parent_lot_number            IN       VARCHAR2,
        x_return_status                OUT      NOCOPY VARCHAR2,
        x_msg_count                    OUT      NOCOPY NUMBER,
        x_msg_data                     OUT      NOCOPY VARCHAR2,
        p_transaction_source_id        IN       NUMBER := NULL,   /* 13368816 */
        p_transaction_source_line_id   IN       NUMBER := NULL    /* 13368816 */
     )
        RETURN VARCHAR2
    IS
        /* Mrana : - New version of auto lot gen that calls the user_defined lot_number
                     generation routine */
        lot_generation           NUMBER          := p_lot_generation;
        lot_uniqueness           NUMBER          := p_lot_uniqueness;
        lot_prefix               VARCHAR2 ( 80 ) := p_lot_prefix;
        zero_pad                 NUMBER          := p_zero_pad;
        lot_length               NUMBER          := p_lot_length;
        l_lot_prefix             VARCHAR2 ( 80 );
        l_lot_prefix_length      NUMBER;
        l_new_suffix             VARCHAR2 ( 80 );
        l_lot_suffix             VARCHAR2 ( 80 );
        l_lot_suffix_length      NUMBER;
        l_found                  BOOLEAN;
        l_lot_control_code       NUMBER;
        auto_lot_number          VARCHAR2 ( 80 ) := NULL;
        l_unique_lot             BOOLEAN         := FALSE;
        l_lotcount               NUMBER;
        l_api_version   CONSTANT NUMBER          := 1.0;
        l_api_name      CONSTANT VARCHAR2 ( 50 ) := 'INV_LOT_API_PUB.auto_gen_lot';
        l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
        -- The following 2 variables are added as a part of bug fix for: Bug #3330855
        v_org_code               VARCHAR2 ( 3 );
        v_item_name              VARCHAR2 ( 80 );

/*======================================
   OPM Convergence
  Added cursors to check for existence
  of parent lot in temp or permanent
  table.
  Removed check for existing parent lot.
CURSOR mtlt_cur_1 IS
SELECT lot.lot_number
FROM   mtl_transaction_lots_temp lot,
       mtl_material_transactions_temp mmtt
WHERE  lot.transaction_temp_id = mmtt.transaction_temp_id
   AND lot.lot_number = p_parent_lot_number
   AND inventory_item_id = p_inventory_item_id;


CURSOR get_mtl_lot IS
SELECT lot_number
FROM   mtl_lot_numbers
WHERE  lot_number = p_parent_lot_number
   AND organization_id = p_org_id
   AND inventory_item_id = p_inventory_item_id;

x_lot_number                 MTL_LOT_NUMBERS.LOT_NUMBER%TYPE := NULL;
===========================================*/

/*=============================================
   Following variable controls looping until a
   valid child lot is found.
  =============================================*/
l_unique_child_lot           BOOLEAN         := FALSE;

/*====================================
   OPM Convergence
   Added cursor to get Item Master setup.
   Variables following this cursor are
   used to receive the values from the
   cursor.
  ======================================*/
CURSOR get_item_data IS
SELECT child_lot_flag, parent_child_generation_flag,
       child_lot_prefix, child_lot_starting_number
FROM   mtl_system_items_b     -- NSRIVAST, Changed the name to MTL_SYSTEM_ITEMS_B as per review comments by Shelly
WHERE  organization_id = p_org_id
AND    inventory_item_id = p_inventory_item_id;

x_child_lot_flag             MTL_SYSTEM_ITEMS.CHILD_LOT_FLAG%TYPE;
x_item_parent_child_gen_flag MTL_SYSTEM_ITEMS.PARENT_CHILD_GENERATION_FLAG%TYPE;
x_item_child_lot_prefix      MTL_SYSTEM_ITEMS.CHILD_LOT_PREFIX%TYPE;
x_child_lot_starting_number  MTL_SYSTEM_ITEMS.CHILD_LOT_STARTING_NUMBER%TYPE;


/*====================================
   OPM Convergence
  Added cursor to get child mtl parms.
  Variables that follow the cursor are
  used to accept the data returned
  from the cursor.
  ====================================*/
CURSOR get_child_parms IS
SELECT lot_number_generation,
       parent_child_generation_flag,
       child_lot_zero_padding_flag,
       child_lot_alpha_prefix, NVL(child_lot_number_length,80)
FROM   mtl_parameters
WHERE  organization_id = p_org_id;

x_parent_child_generation_flag MTL_PARAMETERS.PARENT_CHILD_GENERATION_FLAG%TYPE;
x_child_lot_zero_padding_flag  MTL_PARAMETERS.CHILD_LOT_ZERO_PADDING_FLAG%TYPE;
x_child_lot_alpha_prefix       MTL_PARAMETERS.CHILD_LOT_ALPHA_PREFIX%TYPE;
x_child_lot_number_length      MTL_PARAMETERS.CHILD_LOT_NUMBER_LENGTH%TYPE;
x_lot_number_generation        MTL_PARAMETERS.LOT_NUMBER_GENERATION%TYPE;

/*======================================
  x_pad_value is the number of
  characters to be padded in the child
  lot suffix.
  ====================================*/

x_pad_value                    NUMBER;

/*======================================
  x_parent_lot_number is a placeholder to
  pass null in this value when recalling
  the generation routine.
  x_parent_call is the lot returned from
  the recall.
  ====================================*/

x_parent_lot_number            MTL_LOT_NUMBERS.LOT_NUMBER%TYPE;
x_parent_call                  MTL_LOT_NUMBERS.LOT_NUMBER%TYPE;

/*========================================
  interim_child_lot_number is the generated
  child lot that is a candidate to be
  passed back.  Becomes passed back if
  it does not exist already.
  interim prefix is child lot prefix
  concatenated with parent lot.
  ======================================*/


/*=======================================
   BUG#4145437 - increased interim size.
  =======================================*/
interim_child_lot_number         VARCHAR2(300);
x_interim_child_prefix           VARCHAR2(200);

/*========================================
  Cursor to check if candidate child lot
  exists already.  Variable l_sublotcount
  is used with this cursor.
  ======================================*/

CURSOR check_lot_exists IS
SELECT count( 1 )
FROM   mtl_lot_numbers
WHERE  inventory_item_id = p_inventory_item_id
AND    organization_id = p_org_id
AND    lot_number = interim_child_lot_number;

l_sublotcount                   NUMBER;

/*====================================
  l_ret is used in calls to functions
  to insert/update child lot table.
  ====================================*/
l_ret                           NUMBER;

/*====================================
  Cursor to get next child number.
  x_last_child_seq is used with this
  cursor.
  ====================================*/

CURSOR get_next_child  IS
SELECT last_child_lot_number_seq
FROM   mtl_child_lot_numbers
WHERE  inventory_item_id = p_inventory_item_id
AND    organization_id = p_org_id
AND    parent_lot_number = p_parent_lot_number;

x_last_child_seq               NUMBER;

/*====================================
  x_last_child_seq_pad holds the
  padded format of x_last_child_seq.
  ====================================*/

x_last_child_seq_pad           VARCHAR2(80);



    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT apiauto_gen_lot_apipub;
        IF (l_debug = 1) THEN
        print_debug('in auto_gen_lot',9);
        END IF;
        -- Standard call to check for call compatibility.

        IF NOT fnd_api.compatible_api_call (
                    l_api_version,
                   p_api_version,
                   l_api_name,
                   g_pkg_name
                )
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF fnd_api.to_boolean ( p_init_msg_list )
        THEN
            fnd_msg_pub.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

        -- API body

        /*================================================
           Joe DiIorio 05/17/2004 OPM Convergence.
           Added logic upfront to deal with parent_lot.
           Standard lot generation will bypass this
           and proceed as usual.  Entry of parent lot
           means you want to generate a child lot.
          ==============================================*/
        IF (p_parent_lot_number IS NOT NULL) THEN
            /*===========================================
               Check if child_lot_split is allowed and
               retrieve all item master parms.
              ===========================================*/
            OPEN get_item_data;
            FETCH get_item_data INTO
                x_child_lot_flag, x_item_parent_child_gen_flag,
                x_item_child_lot_prefix, x_child_lot_starting_number;
              IF (get_item_data%NOTFOUND) THEN
                 CLOSE get_item_data;
                 fnd_message.set_name ('INV' , 'INV_CL_GET_ITEM_ERR' );
                 fnd_msg_pub.ADD;
                 RAISE fnd_api.g_exc_error;
              END IF;
            CLOSE get_item_data;
            /*===========================================
               Is child_lot split allowed?
              ===========================================*/
            IF (nvl(x_child_lot_flag,'N') = 'N') THEN
                 fnd_message.set_name ('INV' , 'INV_CL_CHILD_LOT_DISABLED');
                 fnd_msg_pub.ADD;
                 RAISE fnd_api.g_exc_error;
            END IF;
            /*===========================================
               Get the Child lot generation parameters.
              ===========================================*/
            OPEN get_child_parms;
            FETCH get_child_parms INTO
                   x_lot_number_generation,
                   x_parent_child_generation_flag,
                   x_child_lot_zero_padding_flag,
                   x_child_lot_alpha_prefix, x_child_lot_number_length;
            IF (get_child_parms%NOTFOUND) THEN
                 CLOSE get_child_parms;
                 fnd_message.set_name ('INV' , 'INV_CL_GET_PARM_ERR');
                 fnd_msg_pub.ADD;
                 RAISE fnd_api.g_exc_error;
            END IF;
            CLOSE get_child_parms;


            /*===========================================
               Loop until we have a valid unique lot.
              ===========================================*/
            WHILE NOT ( l_unique_child_lot = TRUE )
            LOOP
            /*===========================================
               Parent Lot Logic First Check User Defined.
               Added parent lot number to call parameters.
              ===========================================*/
              IF (x_lot_number_generation = 3) THEN
                 interim_child_lot_number :=
                    user_pkg_lot.generate_lot_number (
                        p_org_id,
                        p_inventory_item_id,
                        p_transaction_date,
                        p_revision,
                        p_subinventory_code,
                        p_locator_id,
                        p_transaction_type_id,
                        p_transaction_action_id,
                        p_transaction_source_type_id,
                        p_transaction_source_id,        /* 12925054 */
                        p_transaction_source_line_id,   /* 12925054 */
                        p_lot_number,
                        p_parent_lot_number,
                        x_return_status
                     );

                 IF ( x_return_status = fnd_api.g_ret_sts_error )
                 THEN
                     RAISE fnd_api.g_exc_error;
                 END IF;

                 IF ( x_return_status = fnd_api.g_ret_sts_unexp_error )
                 THEN
                     RAISE fnd_api.g_exc_unexpected_error;
                 END IF;
                 /*===========================================
                    If child lot generated by user routine then
                    return it,  Otherwise if null then return
                   ===========================================*/
                 IF (interim_child_lot_number IS NULL) THEN
                    fnd_message.set_name ('INV' , 'INV_CL_USER_PGM_ERR');
                    fnd_msg_pub.ADD;
                    RAISE fnd_api.g_exc_error;
                 END IF;
                 /*=================================
                      BUG#4145437
                   =================================*/
                 IF (lengthb(interim_child_lot_number) > 80) THEN
                     fnd_message.set_name ('INV' , 'INV_CL_MAX_FLD_LENGTH' );
                     fnd_msg_pub.ADD;
                     RAISE fnd_api.g_exc_error;
                 END IF;

              ELSIF (x_lot_number_generation = 1) THEN
                    /*====================================
                         Organization Level Generation
                      ===================================*/
                    IF (x_parent_child_generation_flag = 'C') THEN
                        OPEN get_next_child;
                        FETCH get_next_child INTO x_last_child_seq;
                        IF get_next_child%NOTFOUND THEN
                           CLOSE get_next_child;
                           x_last_child_seq := 1;
                           /*=======================================
                              Insert mtl_child_lot_numbers record.
                             =======================================*/
                           l_ret := ins_mtl_child_lot_num(p_org_id,
                                         p_inventory_item_id,
                                         p_parent_lot_number,
                                         x_last_child_seq);
                           IF (l_ret <> 0 ) THEN
                              fnd_message.set_name ('INV','INV_CL_INS_CHILD_ERR');
                              fnd_msg_pub.ADD;
                              RAISE fnd_api.g_exc_error;
                           END IF;
                        ELSE
                           CLOSE get_next_child;
                           x_last_child_seq := x_last_child_seq + 1;
                           /*=======================================
                              Update mtl_child_lot_numbers record.
                             =======================================*/
                           l_ret := upd_mtl_child_lot_num(p_org_id,
                                         p_inventory_item_id,
                                         p_parent_lot_number,
                                         x_last_child_seq);
                           IF (l_ret <> 0 ) THEN
                              fnd_message.set_name ('INV','INV_CL_UPD_CHILD_ERR');
                              fnd_msg_pub.ADD;
                              RAISE fnd_api.g_exc_error;
                           END IF;
                        END IF;
                           /*===============================
                              Append Parent to alpha prefix.
                             ===============================*/
                        x_interim_child_prefix :=
                           p_parent_lot_number||x_child_lot_alpha_prefix;


                        IF ( (lengthb(x_interim_child_prefix)
                              + lengthb(x_last_child_seq)) > 80 ) THEN
                              fnd_message.set_name ('INV' , 'INV_CL_MAX_FLD_LENGTH' );
                              fnd_msg_pub.ADD;
                              RAISE fnd_api.g_exc_error;
                        END IF;
                        IF ( (lengthb(x_interim_child_prefix)
                              + lengthb(x_last_child_seq)) >
                               x_child_lot_number_length ) THEN
                              fnd_message.set_name ('INV' , 'INV_CL_MAX_CHLD_ERR' );
                              fnd_msg_pub.ADD;
                              RAISE fnd_api.g_exc_error;
                        END IF;

                        IF (x_child_lot_zero_padding_flag = 'Y') THEN
                           x_pad_value :=
                           x_child_lot_number_length -
                                 length(x_interim_child_prefix);
                              x_last_child_seq_pad :=
                               LPAD (x_last_child_seq,x_pad_value,'0');
                              interim_child_lot_number :=
                              x_interim_child_prefix||x_last_child_seq_pad;
                        ELSE
                           interim_child_lot_number :=
                           x_interim_child_prefix||x_last_child_seq;
                        END IF;
                    ELSE
                        /*=========================================
                          Recall this api with parent lot = NULL;
                         *=========================================*/
                        x_parent_lot_number := NULL;
                        x_parent_call := inv_lot_api_pub.auto_gen_lot (
                            p_org_id,
                            p_inventory_item_id,
                            p_lot_generation,
                            p_lot_uniqueness,
                            p_lot_prefix,
                            p_zero_pad,
                            p_lot_length,
                            p_transaction_date,
                            p_revision,
                            p_subinventory_code,
                            p_locator_id,
                            p_transaction_type_id ,
                            p_transaction_action_id,
                            p_transaction_source_type_id,
                            p_lot_number,
                            p_api_version,
                            p_init_msg_list,
                            p_commit,
                            p_validation_level,
                            x_parent_lot_number,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_transaction_source_id,          /* 13368816 */
                            p_transaction_source_line_id      /* 13368816 */
                         );
                        RETURN (x_parent_call);
                    END IF;


                 ELSE
                    /*====================================
                         Item Level Generation
                      ===================================*/
                    IF (x_item_parent_child_gen_flag = 'C') THEN
                        OPEN get_next_child;
                        FETCH get_next_child INTO x_last_child_seq;
                        IF get_next_child%NOTFOUND THEN
                           CLOSE get_next_child;
                           x_last_child_seq := x_child_lot_starting_number;
                           /*=======================================
                              Insert mtl_child_lot_numbers record.
                             =======================================*/
                           l_ret := ins_mtl_child_lot_num(p_org_id,
                                         p_inventory_item_id,
                                         p_parent_lot_number,
                                         x_last_child_seq);
                           IF (l_ret <> 0 ) THEN
                              fnd_message.set_name ('INV','INV_CL_INS_CHILD_ERR');
                              fnd_msg_pub.ADD;
                              RAISE fnd_api.g_exc_error;
                           END IF;
                        ELSE
                           CLOSE get_next_child;
                           x_last_child_seq := x_last_child_seq + 1;
                           /*=======================================
                              Update mtl_child_lot_numbers record.
                             =======================================*/
                           l_ret := upd_mtl_child_lot_num(p_org_id,
                                         p_inventory_item_id,
                                         p_parent_lot_number,
                                         x_last_child_seq);
                           IF (l_ret <> 0 ) THEN
                              fnd_message.set_name ('INV','INV_CL_UPD_CHILD_ERR');
                              fnd_msg_pub.ADD;
                              RAISE fnd_api.g_exc_error;
                           END IF;
                        END IF;
                           /*===============================
                              Append Parent to alpha prefix.
                             ===============================*/
                        x_interim_child_prefix :=
                           p_parent_lot_number||x_item_child_lot_prefix;
                        IF ( (lengthb(x_interim_child_prefix)
                              + lengthb(x_last_child_seq)) > 80 ) THEN
                              fnd_message.set_name ('INV' , 'INV_CL_MAX_FLD_ERR' );
                              fnd_msg_pub.ADD;
                              RAISE fnd_api.g_exc_error;
                        END IF;
                        --temp joe what is length for item child?
                        interim_child_lot_number :=
                           x_interim_child_prefix||x_last_child_seq;
                    ELSE
                        /*=========================================
                          Recall this api with parent lot = NULL;
                         *=========================================*/
                        x_parent_lot_number := NULL;
                        x_parent_call := inv_lot_api_pub.auto_gen_lot (
                           p_org_id,
                            p_inventory_item_id,
                            p_lot_generation,
                            p_lot_uniqueness,
                            p_lot_prefix,
                            p_zero_pad,
                            p_lot_length,
                            p_transaction_date,
                            p_revision,
                            p_subinventory_code,
                            p_locator_id,
                            p_transaction_type_id,
                            p_transaction_action_id,
                            p_transaction_source_type_id,
                            p_lot_number,
                            p_api_version,
                            p_init_msg_list,
                            p_commit,
                            p_validation_level,
                            x_parent_lot_number,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_transaction_source_id,       /* 13368816 */
                            p_transaction_source_line_id   /* 13368816 */
                         );
                        RETURN x_parent_call;
                    END IF;
                 END IF;  -- end of generation checks.
                 /*======================================
                    Check if generated child lot exists.
                    IF unique, then stop.
                   ======================================*/
                 OPEN check_lot_exists;
                 FETCH check_lot_exists INTO l_sublotcount;
                 CLOSE check_lot_exists;

                 IF ( l_sublotcount = 0 )
                 THEN
                     l_unique_child_lot := TRUE;
                 ELSE
                     l_unique_child_lot := FALSE;
                 END IF;
            END LOOP;
            RETURN (interim_child_lot_number);

        END IF;  -- parent_lot_number is null.


        /* call the procedure (USER_GENERATE_LOT_NUMBER) to allow the users to
           have custom defined lot numbers instead of using the lot numbers
           generated by Inventory) . If this procedure is not coded by the users
           then it will return a NULL lot number, x_return_status =
           FND_API.G_RET_STS_SUCCESS */
        /* Fixed bug 2075044 -- added the while loop to generate the lot number.
           Check if the generated lot is existed in the mtl_lot_number, then generate
           a new lot again. */

        WHILE NOT ( l_unique_lot = TRUE ) LOOP

            /* Added for bug 7669676 , auto_lot_number is nulled out to generate the next valid lo */
                auto_lot_number := NULL ;
            /* End of changes for 7669676 */
              /*=======================================
               OPM Convergence Added parent lot no.
              =====================================*/
            /*===========================
                  BUG#4089972
              ===========================*/
            /*===========================================
               Get the Child lot generation parameters.
              ===========================================*/
            OPEN get_child_parms;
            FETCH get_child_parms INTO
                   x_lot_number_generation,
                   x_parent_child_generation_flag,
                   x_child_lot_zero_padding_flag,
                   x_child_lot_alpha_prefix, x_child_lot_number_length;
            IF (get_child_parms%NOTFOUND) THEN
                 CLOSE get_child_parms;
                 fnd_message.set_name ('INV' , 'INV_CL_GET_PARM_ERR');
                 fnd_msg_pub.ADD;
                 RAISE fnd_api.g_exc_error;
            END IF;
            CLOSE get_child_parms;
            IF (x_lot_number_generation = 3) THEN
            auto_lot_number :=
                    user_pkg_lot.generate_lot_number (
                         p_org_id,
                        p_inventory_item_id,
                        p_transaction_date,
                        p_revision,
                        p_subinventory_code,
                        p_locator_id,
                        p_transaction_type_id,
                        p_transaction_action_id,
                        p_transaction_source_type_id,
                        p_transaction_source_id,        /* 12925054 */
                        p_transaction_source_line_id,   /* 12925054 */
                        p_lot_number,
                        p_parent_lot_number,
                        x_return_status
                     );

            IF ( x_return_status = fnd_api.g_ret_sts_error ) THEN
                RAISE fnd_api.g_exc_error;
            END IF;

            IF ( x_return_status = fnd_api.g_ret_sts_unexp_error ) THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            END IF;    -- gen is 3
            /* If i/p parameter p_lot_generation or p_lot_uniqueness are null that means we do
               not know at what level the lot number control is therefore Retrieve the following
               information for the input organization_id */

            IF (    lot_generation IS NULL OR lot_uniqueness IS NULL) THEN
                BEGIN
                    /*=================================
                      OPM Default 80 in length not 30.
                      =================================*/
                    SELECT lot_number_generation,
                           lot_number_uniqueness,
                           NVL ( lot_number_zero_padding, 2 ),
                           NVL ( lot_number_length, 80 ),
                           auto_lot_alpha_prefix
                      INTO lot_generation,
                           lot_uniqueness,
                           zero_pad,
                           lot_length,
                           lot_prefix
                      FROM mtl_parameters
                     WHERE organization_id = p_org_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        fnd_message.set_name ('INV' , 'INV_FIELD_INVALID' );
                        fnd_message.set_token ('ENTITY1' , 'p_org_id' );
                        fnd_msg_pub.ADD;
                        RAISE fnd_api.g_exc_error;
                END;
            END IF;

            /* If the lot number (auto_lot_number) returned by user_defined_procedure is null
                then we should proceed with the generation of lot number as defined in Oracle
               inventory */

            IF ( auto_lot_number IS NULL ) THEN
                IF ( lot_generation = 2 ) THEN -- item-level
          BEGIN
                 IF (l_debug = 1) THEN
               print_debug('lot generation is at item level', 9);
                 END IF;

                        SELECT lot_control_code
                          INTO l_lot_control_code
                          FROM mtl_system_items
                         WHERE organization_id = p_org_id
                           AND inventory_item_id = p_inventory_item_id;

                        IF ( l_lot_control_code = 1 ) THEN
                            fnd_message.set_name ( 'INV' , 'INV_NO_LOT_CONTROL');
                            fnd_msg_pub.ADD;
                            RAISE fnd_api.g_exc_error;
                        END IF;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            fnd_message.set_name ('INV' , 'INV_INVALID_ITEM' );
                            fnd_msg_pub.ADD;
                            RAISE fnd_api.g_exc_error;
                    END;

                    BEGIN
                        -- get prefix and default lot number
                        SELECT auto_lot_alpha_prefix,
                               start_auto_lot_number
                          INTO l_lot_prefix,
                               l_lot_suffix
                          FROM mtl_system_items
                         WHERE organization_id = p_org_id
                           AND inventory_item_id = p_inventory_item_id;
                        IF (l_debug = 1) THEN
                            print_debug('lot prefix and start number is ' || l_lot_prefix || ' & ' ||l_lot_suffix,9);
                        END IF;
                        IF ( l_lot_suffix IS NOT NULL ) THEN
                           IF (l_debug = 1) THEN
                               print_debug('lot suffix is not null',9);
                           END IF;
                            -- find lengths
                            l_lot_prefix_length := NVL ( LENGTHB ( l_lot_prefix ), 0 );
                            l_lot_suffix_length := NVL ( LENGTHB ( l_lot_suffix ), 0 );
                            IF (l_debug = 1) THEN
                               print_debug('lot prefixlength and suffix length is ' || l_lot_prefix_length || ' & ' ||l_lot_suffix_length,9);
                               print_debug('lot length is ' || nvl(lot_length,80),9);   -- INVCONV
                            END IF;
                            -- generate only if total length lot less than or equal to lot_length
                            IF ( l_lot_prefix_length + l_lot_suffix_length <= nvl(lot_length,80)) THEN  -- INVCONV
                               IF (l_debug  = 1) THEN
                                   print_debug('l_lot_prefix_length + l_lot_suffix_length <= nvl(lot_length,80)',9);   -- INVCONV
                               END IF;
                                -- create lot number
                               auto_lot_number := l_lot_prefix || l_lot_suffix;

                                -- left pad with zero if lot number begins with zero
                                IF ( SUBSTR ( l_lot_suffix, 1, 1 ) = '0' ) THEN
                                    -- increment and left pad with zeros
                                    l_new_suffix := LPAD ( TO_CHAR ( TO_NUMBER ( l_lot_suffix ) + 1), l_lot_suffix_length, '0');
                                ELSE
                                    -- increment lot number
                                    l_new_suffix := TO_CHAR ( TO_NUMBER ( l_lot_suffix ) + 1);
                                END IF;

                                -- set new lot number
                                -- OPM changed to 80.
                                IF ( LENGTHB ( l_new_suffix ) <= 80 ) THEN
                                   IF (l_debug = 1) THEN
                                        print_debug('setting new lot number..calling update_msi with params' ||
               p_org_id || ' ' || p_inventory_item_id || ' ' || l_new_suffix,9);
                                   END IF;

                                   update_msi (
                                        p_org_id,
                                        p_inventory_item_id,
                                        l_new_suffix,
                                        lot_uniqueness,
                                        lot_generation,
                                        x_return_status,
                                        l_lot_prefix  -- Bug# 7298723
                                   );
                                   IF x_return_status = fnd_api.g_ret_sts_error THEN
                                       IF (l_debug = 1) THEN
                                          print_debug('it is an error ',9);
                                       END IF;
                                       RAISE fnd_api.g_exc_error;
                                   END IF;
                                END IF;
                            ELSE --  lot length exceeds 80
                               fnd_message.set_name ( 'INV' , 'INV_SERIAL_LOT_TOO_LONG');
                fnd_message.set_token( 'LENGTH', nvl(lot_length, 80));    -- INVCONV
                                fnd_msg_pub.ADD;
                                RAISE fnd_api.g_exc_error;
                            END IF;
                        ELSE --  l_lot_suffix is NULL
                            fnd_message.set_name ( 'INV' , 'INV_FIELD_INVALID');

                            -- Following query added as a part of the bug fix for Bug # 3330855
                               SELECT ORGANIZATION_CODE, CONCATENATED_SEGMENTS
                               INTO v_org_code, v_item_name
                               FROM MTL_PARAMETERS ORG, MTL_SYSTEM_ITEMS_KFV ITEM
                               WHERE ORG.ORGANIZATION_ID = p_org_id
                               AND INVENTORY_ITEM_ID = p_inventory_item_id
                               AND ITEM.ORGANIZATION_ID = p_org_id;

                            fnd_message.set_token ( 'ENTITY1' , 'Lot Suffix for Org: ' || v_org_code || ' and Item: ' || v_item_name);
                            fnd_msg_pub.ADD;
                            RAISE fnd_api.g_exc_error;
                        END IF;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           IF (l_debug=1) THEN
                               print_debug('no data found',9);
                           END IF;
                            fnd_message.set_name ('INV' , 'INV_INVALID_ITEM' );
                            fnd_message.set_token ( 'ENTITY1' , 'p_org_id, p_inventory_item_id');
                            fnd_msg_pub.ADD;
                            RAISE fnd_api.g_exc_error;
                    END;
                ELSIF ( lot_generation = 1 ) THEN -- org-level
          BEGIN
            IF (l_debug =1 ) THEN
                print_debug('lot generation is at org level ',9);
            END IF;
                        -- set lot prefix
                        l_lot_prefix := lot_prefix;

                        -- get next org level lot number
                        SELECT TO_CHAR ( mtl_lot_numeric_suffix_s.NEXTVAL )
                          INTO l_lot_suffix
                          FROM sys.DUAL;
                        IF (l_debug =1 ) THEN
                           print_debug('lot prefix is ' || l_lot_prefix || 'suffix is ' || l_lot_suffix,9);
                        END IF;
                        -- find lengths
                        l_lot_prefix_length := NVL ( LENGTHB ( l_lot_prefix ), 0 );
                        l_lot_suffix_length := NVL ( LENGTHB ( l_lot_suffix ), 0 );
                        IF (l_debug =1 ) THEN
                            print_debug('lot prefix length is ' || l_lot_prefix_length || ' suffix length is ' || l_lot_suffix_length,9);
                        END IF;
                        -- generate only if total lot length less than or equal to lot_length
                        IF ( l_lot_prefix_length + l_lot_suffix_length <= lot_length) THEN
                            IF (l_debug =1 ) THEN
                                print_debug('sum < lot length',9);
                            END IF;
                            IF ( zero_pad = 1 ) THEN -- YES = 1 AND 2 = NO
                                auto_lot_number := lot_prefix || LPAD ( l_lot_suffix, lot_length - l_lot_prefix_length, '0');
                            ELSE
                                auto_lot_number := l_lot_prefix || l_lot_suffix;
                            END IF;
                        ELSE --  lot length exceeds 80
                            fnd_message.set_name ( 'INV' , 'INV_SERIAL_LOT_TOO_LONG');
                            fnd_message.set_token( 'LENGTH', nvl(lot_length, 80));    -- INVCONV
                            fnd_msg_pub.ADD;
                            RAISE fnd_api.g_exc_error;
                        END IF;
                    END;
                END IF;
            END IF;


           --RETURN (auto_lot_number);
/*
   IF inv_lot_api_pub.validate_unique_lot
                         ( p_org_id,
                           p_inventory_item_id,
                           lot_uniqueness,
                           auto_lot_number)
   THEN
      RETURN (auto_lot_number);
   ELSE
      fnd_message.set_name('INV', 'INV_LOT_NUMBER_EXISTS');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error ;
   END IF;
*/

            /* Check if the generated lot is already existed in the mtl_lot_number,
               set the l_unique_lot = FALSE and go back to the while loop to generate
               a new lot, otherwise l_unique_lot = TRUE and return the lot number */
--Bug 3750324 Validating the uniqueness of lot through existing api for checking validation so that the unique lot is
--            generated at first go on the form
/*            SELECT COUNT ( 1 )
              INTO l_lotcount
              FROM mtl_lot_numbers
             WHERE
               inventory_item_id = p_inventory_item_id AND
          organization_id = p_org_id AND
               lot_number = auto_lot_number;

            IF ( l_lotcount = 0 )
            THEN
                l_unique_lot := TRUE;
            ELSE
                l_unique_lot := FALSE;
            END IF; */
               l_unique_lot :=
                     inv_lot_api_pub.validate_unique_lot(
                         p_org_id
                       , p_inventory_item_id
                       , p_lot_uniqueness
                       , auto_lot_number
                       );
--Bug 3750324 Ends
        END LOOP;
         IF (l_debug =1 ) THEN
         print_debug('returning lot number ' || auto_lot_number,9);
         END IF;
        RETURN ( auto_lot_number );
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK TO apiauto_gen_lot_apipub;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get (
                 p_encoded => fnd_api.g_false,
                p_count => x_msg_count,
                p_data => x_msg_data
             );
            --Bugfix 3940851 {
            if( x_msg_count > 1 ) then
               x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
            end if;
            --Bugfix 3940851 }
            RETURN ( NULL );
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO apiauto_gen_lot_apipub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (
                 p_encoded => fnd_api.g_false,
                p_count => x_msg_count,
                p_data => x_msg_data
             );
            --Bugfix 3940851 {
            if( x_msg_count > 1 ) then
               x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
            end if;
            --Bugfix 3940851 }
            RETURN ( NULL );
        WHEN OTHERS THEN
            ROLLBACK TO apiauto_gen_lot_apipub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

            IF fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg ( g_pkg_name, l_api_name );
            END IF;

            fnd_msg_pub.count_and_get (
                 p_encoded => fnd_api.g_false,
                p_count => x_msg_count,
                p_data => x_msg_data
             );
            --Bugfix 3940851 {
            if( x_msg_count > 1 ) then
               x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
            end if;
            --Bugfix 3940851 }
            RETURN ( NULL );
    END auto_gen_lot;


/* Created a wrapper around validate_unique_lot to be able to call it thru Mobile apps  */
    PROCEDURE validate_unique_lot (
        p_org_id              IN       NUMBER,
        p_inventory_item_id   IN       NUMBER,
        p_lot_uniqueness      IN       NUMBER,
        p_auto_lot_number     IN       VARCHAR2,
        p_check_same_item     IN       VARCHAR2,
        x_is_unique           OUT      NOCOPY VARCHAR2
     )
    IS
        l_lot_number          NUMBER          := 0;
        l_lot_uniqueness      NUMBER          := p_lot_uniqueness;
        l_count               NUMBER          := 0;
        l_api_name   CONSTANT VARCHAR2 ( 50 )
                    := 'INV_LOT_API_PUB.validate_unique_lot';

        CURSOR mln_cur_1
        IS
            SELECT lot_number
              FROM mtl_lot_numbers
             WHERE lot_number = p_auto_lot_number
               AND inventory_item_id = p_inventory_item_id;

        CURSOR mtln_cur_1
        IS
            SELECT lot_number
              FROM mtl_transaction_lot_numbers
             WHERE lot_number = p_auto_lot_number
               AND inventory_item_id = p_inventory_item_id;

        CURSOR mtlt_cur_1
        IS
            SELECT lot.lot_number
              FROM mtl_transaction_lots_temp lot,
                   mtl_material_transactions_temp mmtt
             WHERE lot.transaction_temp_id = mmtt.transaction_temp_id
               AND lot.lot_number = p_auto_lot_number
               AND mmtt.inventory_item_id = p_inventory_item_id;

        CURSOR mmtt_cur_1
        IS
            SELECT lot_number
              FROM mtl_material_transactions_temp lot
             WHERE lot_number = p_auto_lot_number
               AND inventory_item_id = p_inventory_item_id;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN
        IF l_lot_uniqueness IS NULL
        THEN
            BEGIN
                SELECT lot_number_uniqueness
                  INTO l_lot_uniqueness
                  FROM mtl_parameters
                 WHERE organization_id = p_org_id;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    RAISE fnd_api.g_exc_error;
            END;
        END IF;

        IF ( l_lot_uniqueness = 1 ) -- Item level control
        THEN
            IF      ( validate_unique_lot (
                          p_org_id,
                         p_inventory_item_id,
                         l_lot_uniqueness,
                         p_auto_lot_number
                      )
                     )
                AND p_check_same_item = 'Y'
            THEN
                BEGIN
                    x_is_unique := 'true';

                    FOR mln_rec IN mln_cur_1
                    LOOP
                        l_count := 1;
                        EXIT;
                    END LOOP;

                    IF ( l_count > 0 )
                    THEN
                        x_is_unique := 'false';
                    ELSE
                        l_count := 0;
                    END IF;

                    FOR mtln_rec IN mtln_cur_1
                    LOOP
                        l_count := 1;
                        EXIT;
                    END LOOP;

                    IF ( l_count > 0 )
                    THEN
                        x_is_unique := 'false';
                    ELSE
                        l_count := 0;
                    END IF;

                    FOR mtlt_rec IN mtlt_cur_1
                    LOOP
                        l_count := 1;
                        EXIT;
                    END LOOP;

                    IF ( l_count > 0 )
                    THEN
                        x_is_unique := 'false';
                    ELSE
                        l_count := 0;
                    END IF;

                    FOR mtlt_rec IN mtlt_cur_1
                    LOOP
                        l_count := 1;
                        EXIT;
                    END LOOP;

                    IF ( l_count > 0 )
                    THEN
                        x_is_unique := 'false';
                    END IF;
                END;
            ELSE
                x_is_unique := 'false';
            END IF;
        ELSE
            x_is_unique := 'true';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF fnd_msg_pub.check_msg_level (
                    fnd_msg_pub.g_msg_lvl_unexp_error
                )
            THEN
                fnd_msg_pub.add_exc_msg ( g_pkg_name, l_api_name );
            END IF;

            x_is_unique := 'false';
    END validate_unique_lot;


    /***************************************************************************************
                                       Bug - 2181558
      Procedure to copy the WMS and Non WMS Lot Attributes from the Source Lot to this Lot
    ***************************************************************************************/
    PROCEDURE get_lot_att_from_source (
        x_return_status                OUT      NOCOPY VARCHAR2,
        x_count                        OUT      NOCOPY NUMBER,
        x_source_wms_lot_att_tbl       OUT      NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type,
        x_source_non_wms_lot_att_rec   OUT      NOCOPY non_wms_lot_att_rec_type,
        p_from_organization_id         IN       NUMBER,
        p_inventory_item_id            IN       NUMBER,
        p_lot_number                   IN       VARCHAR2,
        p_count                        IN       NUMBER,
        p_source_wms_lot_att_tbl       IN       inv_lot_sel_attr.lot_sel_attributes_tbl_type
     )
    IS
       temp_tbl inv_lot_sel_attr.lot_sel_attributes_tbl_type;
       v_found  BOOLEAN := FALSE;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN
        IF (l_debug = 1) THEN
           print_debug ('Getting the WMS and NON WMS LOT Attributes From the Source LOT',4);
        END IF;

        SELECT TO_CHAR ( vendor_id ),
               grade_code,
               fnd_date.date_to_canonical ( origination_date ),
               date_code,
               TO_CHAR ( status_id ),
               fnd_date.date_to_canonical ( change_date ),
               TO_NUMBER ( age ),
               fnd_date.date_to_canonical ( retest_date ),
               fnd_date.date_to_canonical ( maturity_date ),
               lot_attribute_category,
               TO_CHAR ( item_size ),
               color,
               TO_CHAR ( volume ),
               volume_uom,
               place_of_origin,
               fnd_date.date_to_canonical ( best_by_date ),
               TO_CHAR ( LENGTH ),
               length_uom,
               TO_CHAR ( recycled_content ),
               TO_CHAR ( thickness ),
               thickness_uom,
               TO_CHAR ( width ),
               width_uom,
               curl_wrinkle_fold,
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
               fnd_date.date_to_canonical ( d_attribute1 ),
               fnd_date.date_to_canonical ( d_attribute2 ),
               fnd_date.date_to_canonical ( d_attribute3 ),
               fnd_date.date_to_canonical ( d_attribute4 ),
               fnd_date.date_to_canonical ( d_attribute5 ),
               fnd_date.date_to_canonical ( d_attribute6 ),
               fnd_date.date_to_canonical ( d_attribute7 ),
               fnd_date.date_to_canonical ( d_attribute8 ),
               fnd_date.date_to_canonical ( d_attribute9 ),
               fnd_date.date_to_canonical ( d_attribute10 ),
               TO_CHAR ( n_attribute1 ),
               TO_CHAR ( n_attribute2 ),
               TO_CHAR ( n_attribute3 ),
               TO_CHAR ( n_attribute4 ),
               TO_CHAR ( n_attribute5 ),
               TO_CHAR ( n_attribute6 ),
               TO_CHAR ( n_attribute7 ),
               TO_CHAR ( n_attribute8 ),
               TO_CHAR ( n_attribute10 ),
               supplier_lot_number,
               TO_CHAR ( n_attribute9 ),
               territory_code,
               vendor_name,
               description,
               attribute_category,
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
               attribute15
          INTO temp_tbl ( 1 ).column_value,
               temp_tbl ( 2 ).column_value,
               temp_tbl ( 3 ).column_value,
               temp_tbl ( 4 ).column_value,
               temp_tbl ( 5 ).column_value,
               temp_tbl ( 6 ).column_value,
               temp_tbl ( 7 ).column_value,
               temp_tbl ( 8 ).column_value,
               temp_tbl ( 9 ).column_value,
               temp_tbl ( 10 ).column_value,
               temp_tbl ( 11 ).column_value,
               temp_tbl ( 12 ).column_value,
               temp_tbl ( 13 ).column_value,
               temp_tbl ( 14 ).column_value,
               temp_tbl ( 15 ).column_value,
               temp_tbl ( 16 ).column_value,
               temp_tbl ( 17 ).column_value,
               temp_tbl ( 18 ).column_value,
               temp_tbl ( 19 ).column_value,
               temp_tbl ( 20 ).column_value,
               temp_tbl ( 21 ).column_value,
               temp_tbl ( 22 ).column_value,
               temp_tbl ( 23 ).column_value,
               temp_tbl ( 24 ).column_value,
               temp_tbl ( 25 ).column_value,
               temp_tbl ( 26 ).column_value,
               temp_tbl ( 27 ).column_value,
               temp_tbl ( 28 ).column_value,
               temp_tbl ( 29 ).column_value,
               temp_tbl ( 30 ).column_value,
               temp_tbl ( 31 ).column_value,
               temp_tbl ( 32 ).column_value,
               temp_tbl ( 33 ).column_value,
               temp_tbl ( 34 ).column_value,
               temp_tbl ( 35 ).column_value,
               temp_tbl ( 36 ).column_value,
               temp_tbl ( 37 ).column_value,
               temp_tbl ( 38 ).column_value,
               temp_tbl ( 39 ).column_value,
               temp_tbl ( 40 ).column_value,
               temp_tbl ( 41 ).column_value,
               temp_tbl ( 42 ).column_value,
               temp_tbl ( 43 ).column_value,
               temp_tbl ( 44 ).column_value,
               temp_tbl ( 45 ).column_value,
               temp_tbl ( 46 ).column_value,
               temp_tbl ( 47 ).column_value,
               temp_tbl ( 48 ).column_value,
               temp_tbl ( 49 ).column_value,
               temp_tbl ( 50 ).column_value,
               temp_tbl ( 51 ).column_value,
               temp_tbl ( 52 ).column_value,
               temp_tbl ( 53 ).column_value,
               temp_tbl ( 54 ).column_value,
               temp_tbl ( 55 ).column_value,
               temp_tbl ( 56 ).column_value,
               temp_tbl ( 57 ).column_value,
               temp_tbl ( 58 ).column_value,
               temp_tbl ( 59 ).column_value,
               temp_tbl ( 60 ).column_value,
               temp_tbl ( 61 ).column_value,
               temp_tbl ( 62 ).column_value,
               temp_tbl ( 63 ).column_value,
               temp_tbl ( 64 ).column_value,
               temp_tbl ( 65 ).column_value,
               temp_tbl ( 66 ).column_value,
               temp_tbl ( 67 ).column_value,
               temp_tbl ( 68 ).column_value,
               x_source_non_wms_lot_att_rec.attribute_category,
               x_source_non_wms_lot_att_rec.attribute1,
               x_source_non_wms_lot_att_rec.attribute2,
               x_source_non_wms_lot_att_rec.attribute3,
               x_source_non_wms_lot_att_rec.attribute4,
               x_source_non_wms_lot_att_rec.attribute5,
               x_source_non_wms_lot_att_rec.attribute6,
               x_source_non_wms_lot_att_rec.attribute7,
               x_source_non_wms_lot_att_rec.attribute8,
               x_source_non_wms_lot_att_rec.attribute9,
               x_source_non_wms_lot_att_rec.attribute10,
               x_source_non_wms_lot_att_rec.attribute11,
               x_source_non_wms_lot_att_rec.attribute12,
               x_source_non_wms_lot_att_rec.attribute13,
               x_source_non_wms_lot_att_rec.attribute14,
               x_source_non_wms_lot_att_rec.attribute15
          FROM mtl_lot_numbers
         WHERE organization_id = p_from_organization_id
           AND inventory_item_id = p_inventory_item_id
           AND lot_number = p_lot_number;

        x_count := p_count;
        x_source_wms_lot_att_tbl := p_source_wms_lot_att_tbl;

        FOR x IN 1..68 LOOP
           v_found := FALSE;
           FOR y IN 1..p_count LOOP
              IF ( upper(temp_tbl(y).column_name) = upper(p_source_wms_lot_att_tbl(y).column_name)) THEN
                 v_found := TRUE;
              END IF;
           END LOOP;

           IF(v_found = FALSE) THEN
              IF temp_tbl(x).column_value IS NOT NULL THEN
                 x_count := x_count + 1;
                 x_source_wms_lot_att_tbl(x_count).column_name  := g_lot_attributes_tbl(x).column_name;
                 x_source_wms_lot_att_tbl(x_count).column_type  := g_lot_attributes_tbl(x).column_type;
                 x_source_wms_lot_att_tbl(x_count).column_value := temp_tbl(x).column_value;
              END IF;
           END IF;
        END LOOP;
    EXCEPTION
       WHEN no_data_found THEN
          IF (l_debug = 1) THEN
             print_debug('The selected lot_number, organization, item combination doesnt exist in MLN',4);
          END IF;
          x_count := p_count;
          x_source_wms_lot_att_tbl := p_source_wms_lot_att_tbl;
        WHEN OTHERS
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            IF (l_debug = 1) THEN
               print_debug ('Exitting populatelotattributes - other exception:' || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' ),1);
            END IF;
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg (g_pkg_name,'get_lot_att_from_source');
            END IF;
    END get_lot_att_from_source;


 -----------------------------------------------------------J Develop--------------------------------

PROCEDURE validate_lot_attr_info(
    x_return_status          OUT    NOCOPY VARCHAR2
  , x_msg_count              OUT    NOCOPY NUMBER
  , x_msg_data               OUT    NOCOPY VARCHAR2
  , p_wms_is_installed       IN     VARCHAR2
  , p_attribute_category     IN     VARCHAR2
  , p_lot_attribute_category IN     VARCHAR2
  , p_inventory_item_id      IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_attributes_tbl         IN     inv_lot_api_pub.char_tbl
  , p_c_attributes_tbl       IN     inv_lot_api_pub.char_tbl
  , p_n_attributes_tbl       IN     inv_lot_api_pub.number_tbl
  , p_d_attributes_tbl       IN     inv_lot_api_pub.date_tbl
  , p_disable_flag           IN     NUMBER
  , p_grade_code             IN     VARCHAR2
  , p_origination_date       IN     DATE
  , p_date_code              IN     VARCHAR2
  , p_change_date            IN     DATE
  , p_age                    IN     NUMBER
  , p_retest_date            IN     DATE
  , p_maturity_date          IN     DATE
  , p_item_size              IN     NUMBER
  , p_color                  IN     VARCHAR2
  , p_volume                 IN     NUMBER
  , p_volume_uom             IN     VARCHAR2
  , p_place_of_origin        IN     VARCHAR2
  , p_best_by_date           IN     DATE
  , p_length                 IN     NUMBER
  , p_length_uom             IN     VARCHAR2
  , p_recycled_content       IN     NUMBER
  , p_thickness              IN     NUMBER
  , p_thickness_uom          IN     VARCHAR2
  , p_width                  IN     NUMBER
  , p_width_uom              IN     VARCHAR2
  , p_territory_code         IN     VARCHAR2
  , p_supplier_lot_number    IN     VARCHAR2
  , p_vendor_name            IN     VARCHAR2
  ) IS
    TYPE seg_name IS TABLE OF VARCHAR2(1000)
      INDEX BY BINARY_INTEGER;

    l_context          VARCHAR2(1000);
    l_context_r        fnd_dflex.context_r;
    l_contexts_dr      fnd_dflex.contexts_dr;
    l_dflex_r          fnd_dflex.dflex_r;
    l_segments_dr      fnd_dflex.segments_dr;
    l_enabled_seg_name seg_name;
    l_wms_all_segs_tbl seg_name;
    l_nsegments        BINARY_INTEGER;
    l_global_context   BINARY_INTEGER;
    v_index            NUMBER                := 1;
    v_index1           NUMBER                := 1;
    l_chk_flag         NUMBER                := 0;
    l_char_count       NUMBER;
    l_num_count        NUMBER;
    l_date_count       NUMBER;
    l_wms_attr_chk     NUMBER                := 1;
    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(1000);
    /*Return status definition
    G_RET_STS_SUCCESS       CONSTANT VARCHAR2(1) :='S';
    G_RET_STS_ERROR         CONSTANT VARCHAR2(1) :='E';
    G_RET_STS_UNEXP_ERROR   CONSTANT VARCHAR2(1) :='U'; */


    /*Exception definitions
    G_EXC_ERROR             EXCEPTION;
    G_EXC_UNEXPECTED_ERROR  EXCEPTION;*/

    /* Variables used for Validate_desccols procedure */
    error_segment      VARCHAR2(30);
    errors_received    EXCEPTION;
    error_msg          VARCHAR2(5000);
    s                  NUMBER;
    e                  NUMBER;
    --g_debug          NUMBER := 1 ;--NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),0);
    l_null_char_val    VARCHAR2(1000);
    l_null_num_val     NUMBER;
    l_null_date_val    DATE;
    l_global_nsegments NUMBER := 0;
  BEGIN
    x_return_status  := g_ret_sts_success;
    SAVEPOINT get_lot_attr_information;

    /* Populate the flex field record */
    --IF p_attribute_category IS NOT NULL THEN
       --AND p_attributes_tbl.COUNT > 0 THEN
      l_dflex_r.application_id  := 401;
      l_dflex_r.flexfield_name  := 'MTL_LOT_NUMBERS';
      /* Get all contexts */
      fnd_dflex.get_contexts(flexfield => l_dflex_r, contexts => l_contexts_dr);

      IF g_debug = 1 THEN
        print_debug('Found contexts for the Flexfield MTL_LOT_NUMBERS', 9);
      END IF;

      /* From the l_contexts_dr, get the position of the global context */
      l_global_context          := l_contexts_dr.global_context;

      IF g_debug = 1 THEN
        print_debug('Found the position of the global context  ', 9);
      END IF;

      /* Using the position get the segments in the global context which are enabled */
      l_context                 := l_contexts_dr.context_code(l_global_context);

      /* Prepare the context_r type for getting the segments associated with the global context */
      l_context_r.flexfield     := l_dflex_r;
      l_context_r.context_code  := l_context;
      fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);

      IF g_debug = 1 THEN
        print_debug('After successfully getting all the enabled segmenst for the Global Context ', 9);
      END IF;

      /* read through the segments */
      l_nsegments               := l_segments_dr.nsegments;
      l_global_nsegments := l_segments_dr.nsegments;
      IF g_debug = 1 THEN
        print_debug('The number of enabled segments for the Global Context are ' || l_nsegments, 9);
      END IF;

      FOR i IN 1 .. l_nsegments LOOP
   print_debug('v_index is ' || v_index, 9);
   print_debug('application_column_name is ' || l_segments_dr.application_column_name(i), 9);

        l_enabled_seg_name(v_index)  := l_segments_dr.application_column_name(i);

        IF g_debug = 1 THEN
          print_debug('The segment is ' || l_segments_dr.segment_name(i), 9);
        END IF;

   print_debug(p_attributes_tbl.count, 9);

        IF l_segments_dr.is_required(i) THEN
          IF NOT p_attributes_tbl.EXISTS(SUBSTR(l_segments_dr.application_column_name(i)
                  , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9)) THEN
            fnd_message.set_name('INV', 'INV_REQ_SEG_MISS');
            fnd_message.set_token('SEGMENT', l_segments_dr.segment_name(i));
            fnd_msg_pub.ADD;

            IF g_debug = 1 THEN
              print_debug('Req segment is not populated', 9);
            END IF;

            RAISE g_exc_error;
          END IF;
        ELSE
          IF g_debug = 1 THEN
            print_debug('This segment is not required', 9);
          END IF;
        END IF;

        IF p_attributes_tbl.EXISTS(SUBSTR(l_segments_dr.application_column_name(i)
             , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9)) THEN
          fnd_flex_descval.set_column_value(
            l_segments_dr.application_column_name(i)
          , p_attributes_tbl(SUBSTR(l_segments_dr.application_column_name(i)
              , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9))
          );
        ELSE
          fnd_flex_descval.set_column_value(l_segments_dr.application_column_name(i), l_null_char_val);
        END IF;

        --fnd_flex_descval.set_column_value(l_segments_dr.application_column_name(i),p_attributes_tbl(SUBSTR(l_segments_dr.application_column_name(i),INSTR(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)));
        v_index                      := v_index + 1;
      END LOOP;

      IF l_enabled_seg_name.COUNT > 0 THEN
        FOR i IN l_enabled_seg_name.FIRST .. l_enabled_seg_name.LAST LOOP
          IF g_debug = 1 THEN
            print_debug('The enabled segment : ' || l_enabled_seg_name(i), 9);
          END IF;
        END LOOP;
      END IF;

      /* Initialise the l_context_value to null */
      l_context                 := NULL;
      l_nsegments               := 0;

      /*Get the context for the item passed */
      IF p_attribute_category IS NOT NULL THEN
        l_context                 := p_attribute_category;
        /* Set flex context for validation of the value set */
        fnd_flex_descval.set_context_value(l_context);

        IF g_debug = 1 THEN
          print_debug('The value of INV context is ' || l_context, 9);
        END IF;

        /* Prepare the context_r type */
        l_context_r.flexfield     := l_dflex_r;
        l_context_r.context_code  := l_context;
        fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);
        /* read through the segments */
        l_nsegments               := l_segments_dr.nsegments;
        IF g_debug = 1 THEN
          print_debug('No of segments enabled for context ' || l_context || ' are ' || l_nsegments, 9);
        END IF;

   print_Debug('v_index is ' || v_index, 9);
        FOR i IN 1 .. l_nsegments LOOP
          l_enabled_seg_name(v_index)  := l_segments_dr.application_column_name(i);

          print_debug('The segment is ' || l_segments_dr.segment_name(i), 9);

          IF l_segments_dr.is_required(i) THEN
            IF NOT p_attributes_tbl.EXISTS(SUBSTR(l_segments_dr.application_column_name(i)
                    , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9)) THEN
              fnd_message.set_name('INV', 'INV_REQ_SEG_MISS');
              fnd_message.set_token('SEGMENT', l_segments_dr.segment_name(i));
              fnd_msg_pub.ADD;
              RAISE g_exc_error;

              IF g_debug = 1 THEN
                print_debug('Req segment is not populated', 9);
              END IF;
            END IF;
          END IF;

          IF p_attributes_tbl.EXISTS(SUBSTR(l_segments_dr.application_column_name(i)
               , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9)) THEN
            fnd_flex_descval.set_column_value(
              l_segments_dr.application_column_name(i)
            , p_attributes_tbl(SUBSTR(l_segments_dr.application_column_name(i)
                , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9))
            );
          ELSE
            fnd_flex_descval.set_column_value(l_segments_dr.application_column_name(i), l_null_char_val);
          END IF;

          v_index                      := v_index + 1;
        END LOOP;

        --IF l_enabled_seg_name.count = P_ATTRIBUTES_TBL.count THEN
        /*v_index1                  := p_attributes_tbl.FIRST;

   print_debug('l_enabled_seg_name.count is ' || l_enabled_seg_name.COUNT, 9);
        WHILE v_index1 <= p_attributes_tbl.LAST LOOP
          IF g_debug = 1 THEN
            print_debug('The value of segment is ' || v_index1, 9);
          END IF;

          FOR i IN 1 .. l_enabled_seg_name.COUNT LOOP
            IF l_enabled_seg_name(i) = 'ATTRIBUTE' || v_index1 THEN
              print_debug('The value of segmentS have matched '||l_enabled_seg_name(i), 9);
              l_chk_flag  := 1;
              EXIT;
            END IF;
          END LOOP;

          IF l_chk_flag = 0 AND p_attributes_tbl(v_index1) IS NOT NULL THEN
            fnd_message.set_name('INV', 'INV_WRONG_SEG_POPULATE');
            fnd_message.set_token('SEGMENT', 'ATTRIBUTE' || v_index1);
            fnd_message.set_token('CONTEXT', l_context);
            fnd_msg_pub.ADD;
            --dbms_output.put_line('Error out. Correct segmenst are not populated ');
            RAISE g_exc_error;
          END IF;

          v_index1    := p_attributes_tbl.NEXT(v_index1);
          l_chk_flag  := 0;
        END LOOP;*/
    END IF;
        /*Make a call to  FND_FLEX_DESCVAL.validate_desccols */
    IF (l_global_nsegments > 0 AND p_attribute_Category IS NULL ) THEN
        l_context                 := l_contexts_dr.context_code(l_global_context);
        fnd_flex_descval.set_context_value(l_context);
    end if;
    IF( l_global_nsegments > 0 OR p_attribute_category IS NOT NULL ) then
        IF fnd_flex_descval.validate_desccols(appl_short_name => 'INV', desc_flex_name => 'MTL_LOT_NUMBERS', values_or_ids => 'I'
           , validation_date              => SYSDATE) THEN
          IF g_debug = 1 THEN
            print_debug('Value set validation successful', 9);
          END IF;
        ELSE
          IF g_debug = 1 THEN
            error_segment  := fnd_flex_descval.error_segment;
            print_debug('Value set validation failed for segment ' || error_segment, 9);
            RAISE errors_received;
          END IF;
        END IF;
    END IF;  /*If P attribute category is not null */
    --END IF;   /* p_attribute_category IS NOT NULL */

    /*Check If WMS is installed */
    IF p_wms_is_installed = 'TRUE' THEN
      wms_lot_attr_validate(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_inventory_item_id          => p_inventory_item_id
      , p_organization_id            => p_organization_id
      , p_disable_flag               => p_disable_flag
      , p_lot_attribute_category     => p_lot_attribute_category
      , p_c_attributes_tbl           => p_c_attributes_tbl
      , p_n_attributes_tbl           => p_n_attributes_tbl
      , p_d_attributes_tbl           => p_d_attributes_tbl
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

      IF l_return_status = g_ret_sts_error THEN
        IF g_debug = 1 THEN
          print_debug('Program WMS_LOT_ATTR_VALIDATE has failed with a user defined exception', 9);
          print_debug('l_msg_data is ' || l_msg_data, 9);
        END IF;
        RAISE g_exc_error;
      ELSIF l_return_status = g_ret_sts_unexp_error THEN
        IF g_debug = 1 THEN
          print_debug('Program WMS_LOT_ATTR_VALIDATE has failed with a Unexpected exception', 9);
        END IF;
        FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
        FND_MESSAGE.SET_TOKEN('PROG_NAME','WMS_LOT_ATTR_VALIDATE');
        fnd_msg_pub.ADD;
        RAISE g_exc_unexpected_error;
      END IF;
    END IF;  /* If wms_is installed */
  EXCEPTION
    WHEN errors_received THEN
      x_return_status  := g_ret_sts_error;
      error_msg        := fnd_flex_descval.error_message;
      s                := 1;
      e                := 200;

      --print_debug('Here are the error messages: ',9);
      WHILE e < 5001
       AND SUBSTR(error_msg, s, e) IS NOT NULL LOOP
        fnd_message.set_name('INV', 'INV_FND_GENERIC_MSG');
        fnd_message.set_token('MSG', SUBSTR(error_msg, s, e));
        fnd_msg_pub.ADD;
        print_debug(SUBSTR(error_msg, s, e), 9);
        s  := s + 200;
        e  := e + 200;
      END LOOP;

      ROLLBACK TO get_lot_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN g_exc_error THEN
      x_return_status  := g_ret_sts_error;
      ROLLBACK TO get_lot_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN g_exc_unexpected_error THEN
      x_return_status  := g_ret_sts_unexp_error;
      ROLLBACK TO get_lot_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := g_ret_sts_unexp_error;
      ROLLBACK TO get_lot_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      print_debug('Error ' || SQLERRM, 9);
  END validate_lot_attr_info;


  PROCEDURE validate_lot_attr_in_param(
    x_return_status          OUT NOCOPY    VARCHAR2
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , p_inventory_item_id      IN            NUMBER
  , p_organization_id        IN            NUMBER
  , p_lot_number             IN            VARCHAR2
  , p_attribute_category     IN            VARCHAR2
  , p_lot_attribute_category IN            VARCHAR2
  , p_attributes_tbl         IN            inv_lot_api_pub.char_tbl
  , p_c_attributes_tbl       IN            inv_lot_api_pub.char_tbl
  , p_n_attributes_tbl       IN            inv_lot_api_pub.number_tbl
  , p_d_attributes_tbl       IN            inv_lot_api_pub.date_tbl
  , p_wms_is_installed       IN            VARCHAR2
  , p_source                 IN            NUMBER
  , p_disable_flag           IN            NUMBER
  , p_grade_code             IN            VARCHAR2
  , p_origination_date       IN            DATE
  , p_date_code              IN            VARCHAR2
  , p_change_date            IN            DATE
  , p_age                    IN            NUMBER
  , p_retest_date            IN            DATE
  , p_maturity_date          IN            DATE
  , p_item_size              IN            NUMBER
  , p_color                  IN            VARCHAR2
  , p_volume                 IN            NUMBER
  , p_volume_uom             IN            VARCHAR2
  , p_place_of_origin        IN            VARCHAR2
  , p_best_by_date           IN            DATE
  , p_length                 IN            NUMBER
  , p_length_uom             IN            VARCHAR2
  , p_recycled_content       IN            NUMBER
  , p_thickness              IN            NUMBER
  , p_thickness_uom          IN            VARCHAR2
  , p_width                  IN            NUMBER
  , p_width_uom              IN            VARCHAR2
  , p_territory_code         IN            VARCHAR2
  , p_supplier_lot_number    IN            VARCHAR2
  , p_vendor_name            IN            VARCHAR2
  ) IS
    /*Program variables declaration */
    l_lot_control_code      mtl_system_items_b.lot_control_code%TYPE;
    l_chk_lot_uniqueness    BOOLEAN;
    l_wms_installed         VARCHAR2(5);
    l_lot_number_uniqueness NUMBER;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(3000);
    l_status                NUMBER;
  BEGIN
    x_return_status       := g_ret_sts_success;
    SAVEPOINT val_lot_attr;

    BEGIN
      SELECT lot_control_code
        INTO l_lot_control_code
        FROM mtl_system_items
       WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = p_organization_id;

      /* If not lot controlled , then error out */
      IF (l_lot_control_code = 1) THEN
        IF g_debug = 1 THEN
          print_debug('Item is not lot controlled ', 9);
        END IF;

        fnd_message.set_name('INV', 'INV_NO_LOT_CONTROL');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_error;
        RAISE g_exc_error;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (g_debug = 1) THEN
          print_debug('Exception in LOT_CONTROL_CODE', 9);
        END IF;

        fnd_message.set_name('INV', 'INV_INVALID_ITEM');
        fnd_msg_pub.ADD;
        RAISE g_exc_error;
    END;

    IF g_debug = 1 THEN
      print_debug('Item is lot controlled ', 9);
    END IF;

    /* Get the Lot number uniqueness from mtl_parameters for the passed org_id
        oNE MESSAGE TO BE ADDED
    */
    BEGIN
      SELECT lot_number_uniqueness
        INTO l_lot_number_uniqueness
        FROM mtl_parameters
       WHERE organization_id = p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (g_debug = 1) THEN
          print_debug('Lot Number Uniqueness is not defined ', 9);
        END IF;

        fnd_message.set_name('INV', 'INV_NO_UNIQUENESS_DEFN');
        /* Lot Number Uniqueness is not defined*/
        fnd_msg_pub.ADD;
        RAISE NO_DATA_FOUND;
    END;

    /* Call the function to check the Lot Uniqueness */
    l_chk_lot_uniqueness  :=
      inv_lot_api_pub.validate_unique_lot(
        p_org_id                     => p_organization_id
      , p_inventory_item_id          => p_inventory_item_id
      , p_lot_uniqueness             => l_lot_number_uniqueness
      , p_auto_lot_number            => p_lot_number
      );

    IF NOT l_chk_lot_uniqueness THEN
      fnd_message.set_name('INV', 'INV_LOT_UNIQUENESS');
      fnd_msg_pub.ADD;

      IF g_debug = 1 THEN
        print_debug('Lot Number Uniqueness check failed ', 9);
      END IF;

      RAISE g_exc_error;
    END IF;

    IF g_debug = 1 THEN
      print_debug('Lot Number Uniqueness check passed successfully ', 9);
    END IF;

    l_wms_installed := p_wms_is_installed;

    /*If  WMS is installed then accept both the inventory attributes and
      WMS attributes. If WMS is not installed then accept only Inventory
      attributes
    */
    --IF l_wms_installed = 'TRUE' THEN
      IF g_debug = 1 THEN
        print_debug('WMS installed is   ' || l_wms_installed, 9);
   print_debug('p_attributes_tbl.count = ' || p_attributes_tbl.count, 9);
      END IF;

      /* Check if the Attribute_Category has been populated */

      /*IF p_attribute_category IS NULL THEN
   for i in 1..p_attributes_tbl.count LOOP
      if p_attributes_tbl(i) IS NOT NULL THEN
              fnd_message.set_name('INV', 'INV_NO_ATTRIBUTE_CATEGORY');
              fnd_msg_pub.ADD;

              IF g_debug = 1 THEN
                 print_debug('Attribute Category value is null', 9);
              END IF;

              RAISE g_exc_error;
     end if;
   end loop;
      END IF;*/

      /* Find out if the Inventory attributes are populated*/
      IF p_attributes_tbl.COUNT > 0 THEN
        IF g_debug = 1 THEN
          print_debug('The Inventory attributes are populated ', 9);
        END IF;
      END IF;

      IF p_source NOT IN(osfm_form_no_validate) THEN
        validate_lot_attr_info(
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_wms_is_installed           => l_wms_installed
        , p_attribute_category         => p_attribute_category
        , p_lot_attribute_category     => p_lot_attribute_category
        , p_inventory_item_id          => p_inventory_item_id
        , p_organization_id            => p_organization_id
        , p_attributes_tbl             => p_attributes_tbl
        , p_c_attributes_tbl           => p_c_attributes_tbl
        , p_n_attributes_tbl           => p_n_attributes_tbl
        , p_d_attributes_tbl           => p_d_attributes_tbl
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

        IF l_return_status = g_ret_sts_error THEN
          IF g_debug = 1 THEN
            print_debug('Program get_lot_attr_info has failed with a user defined exception', 9);
          END IF;
          RAISE g_exc_error;
        ELSIF l_return_status = g_ret_sts_unexp_error THEN
          IF g_debug = 1 THEN
            print_debug('Program get_lot_attr_info has failed with a Unexpected exception', 9);
          END IF;
          FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
          FND_MESSAGE.SET_TOKEN('PROG_NAME','get_lot_attr_info');
          fnd_msg_pub.ADD;
          RAISE g_exc_unexpected_error;
        END IF;
      END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := g_ret_sts_error;
      ROLLBACK TO val_lot_attr;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      print_debug('In No data found -val_lot_attr ' || SQLERRM, 9);
    WHEN g_exc_error THEN
      x_return_status  := g_ret_sts_error;
      ROLLBACK TO val_lot_attr;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      print_debug('In g_exc_error -val_lot_attr' || SQLERRM, 9);
    WHEN g_exc_unexpected_error THEN
      x_return_status  := g_ret_sts_unexp_error;
      ROLLBACK TO val_lot_attr;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      print_debug('In g_exc_unexpected_error val_lot_attr' || SQLERRM, 9);
    WHEN OTHERS THEN
      x_return_status  := g_ret_sts_unexp_error;
      ROLLBACK TO val_lot_attr;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      print_debug('In others val_lot_attr' || SQLERRM, 9);
  END validate_lot_attr_in_param;

-- nsinghi 5209065 START. Created new overloaded procedure.
  PROCEDURE update_inv_lot(
            x_return_status         OUT    NOCOPY VARCHAR2
          , x_msg_count             OUT    NOCOPY NUMBER
          , x_msg_data              OUT    NOCOPY VARCHAR2
          , x_lot_rec               OUT    NOCOPY MTL_LOT_NUMBERS%ROWTYPE
          , p_lot_rec               IN     MTL_LOT_NUMBERS%ROWTYPE
          , p_source                IN     NUMBER
          , p_api_version           IN     NUMBER
          , p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
          , p_commit                IN     VARCHAR2 := fnd_api.g_false
          )
          IS
     CURSOR inv_attributes_cur IS
      SELECT attribute1
           , attribute2
           , attribute3
           , attribute4
           , attribute5
           , attribute6
           , attribute7
           , attribute8
           , attribute9
           , attribute10
           , attribute11
           , attribute12
           , attribute13
           , attribute14
           , attribute15
        FROM mtl_lot_numbers
       WHERE inventory_item_id = p_lot_rec.inventory_item_id
         AND organization_id = p_lot_rec.organization_id
         AND lot_number = p_lot_rec.lot_number;

    CURSOR c_attributes_cur IS
      SELECT c_attribute1
           , c_attribute2
           , c_attribute3
           , c_attribute4
           , c_attribute5
           , c_attribute6
           , c_attribute7
           , c_attribute8
           , c_attribute9
           , c_attribute10
           , c_attribute11
           , c_attribute12
           , c_attribute13
           , c_attribute14
           , c_attribute15
           , c_attribute16
           , c_attribute17
           , c_attribute18
           , c_attribute19
           , c_attribute20
        FROM mtl_lot_numbers
       WHERE inventory_item_id = p_lot_rec.inventory_item_id
         AND organization_id = p_lot_rec.organization_id
         AND lot_number = p_lot_rec.lot_number;

    CURSOR n_attributes_cur IS
      SELECT n_attribute1
           , n_attribute2
           , n_attribute3
           , n_attribute4
           , n_attribute5
           , n_attribute6
           , n_attribute7
           , n_attribute8
           , n_attribute9
           , n_attribute10
        FROM mtl_lot_numbers
       WHERE inventory_item_id = p_lot_rec.inventory_item_id
         AND organization_id = p_lot_rec.organization_id
         AND lot_number = p_lot_rec.lot_number;

    CURSOR d_attributes_cur IS
      SELECT d_attribute1
           , d_attribute2
           , d_attribute3
           , d_attribute4
           , d_attribute5
           , d_attribute6
           , d_attribute7
           , d_attribute8
           , d_attribute9
           , d_attribute10
        FROM mtl_lot_numbers
       WHERE inventory_item_id = p_lot_rec.inventory_item_id
         AND organization_id = p_lot_rec.organization_id
         AND lot_number = p_lot_rec.lot_number;

    CURSOR attr_category_cur IS
      SELECT attribute_category
           , lot_attribute_category
        FROM mtl_lot_numbers
       WHERE inventory_item_id = p_lot_rec.inventory_item_id
         AND organization_id = p_lot_rec.organization_id
         AND lot_number = p_lot_rec.lot_number;

    CURSOR wms_named_attr IS
       SELECT grade_code
       , DISABLE_FLAG
       , origination_date
       , date_code
       , change_date
       , age
       , retest_date
       , maturity_date
       , item_size
       , color
       , volume
       , volume_uom
       , place_of_origin
       , best_by_date
       , length
       , length_uom
       , recycled_content
       , thickness
       , thickness_uom
       , width
       , width_uom
       , territory_code
       , supplier_lot_number
       , VENDOR_NAME
       FROM MTL_LOT_NUMBERS
       WHERE inventory_item_id = p_lot_rec.inventory_item_id
         AND organization_id = p_lot_rec.organization_id
         AND lot_number = p_lot_rec.lot_number;

    l_wms_named_attributes         INV_LOT_API_PUB.wms_named_attributes;
    l_wms_named_attr               wms_named_attr%ROWTYPE;
    l_attr_category_cur            attr_category_cur%ROWTYPE;
    l_c_attributes_cur             c_attributes_cur%ROWTYPE;
    l_n_attributes_cur             n_attributes_cur%ROWTYPE;
    l_d_attributes_cur             d_attributes_cur%ROWTYPE;
    l_inv_attributes_cur           inv_attributes_cur%ROWTYPE;
    l_inv_attributes_tbl           inv_lot_api_pub.char_tbl;
    l_c_attributes_tbl             inv_lot_api_pub.char_tbl;
    l_n_attributes_tbl             inv_lot_api_pub.number_tbl;
    l_d_attributes_tbl             inv_lot_api_pub.date_tbl;
    /* Index variables for looping through the input tables*/
    l_attr_index                   NUMBER;
    l_c_attr_index                 NUMBER;
    l_n_attr_index                 NUMBER;
    l_d_attr_index                 NUMBER;
    l_return_status                VARCHAR2(1);
    l_msg_data                     VARCHAR2(2000);
    l_msg_count                    NUMBER;
    l_wms_installed                VARCHAR2(5);
    l_chk                          NUMBER;
    l_context                      VARCHAR2(1000);
    l_global_context               BINARY_INTEGER;
    l_context_r                    fnd_dflex.context_r;
    l_contexts_dr                  fnd_dflex.contexts_dr;
    l_dflex_r                      fnd_dflex.dflex_r;
    l_segments_dr                  fnd_dflex.segments_dr;
    inv_global_index               NUMBER;
    inv_context_index              NUMBER;
    wms_global_index               NUMBER;
    wms_context_index              NUMBER;
    l_res_inv_attributes_tbl       inv_lot_api_pub.char_tbl;
    l_res_c_attributes_tbl         inv_lot_api_pub.char_tbl;
    l_res_n_attributes_tbl         inv_lot_api_pub.number_tbl;
    l_res_d_attributes_tbl         inv_lot_api_pub.date_tbl;
    /* Shelf life code constants */
    no_shelf_life_control CONSTANT NUMBER                                  := 1;
    item_shelf_life_days  CONSTANT NUMBER                                  := 2;
    user_defined_exp_date CONSTANT NUMBER                                  := 4;
    l_shelf_life_days              mtl_system_items.shelf_life_days%TYPE;
    l_shelf_life_code              mtl_system_items.shelf_life_code%TYPE;
    l_expiration_date              mtl_lot_numbers.expiration_date%TYPE;
    l_global_nsegments        NUMBER := 0;

  BEGIN
    x_return_status           := g_ret_sts_success;
    SAVEPOINT upd_lot_attr;

    IF g_debug = 1 THEN
      print_debug(p_err_msg => 'Update Lot Attr: The value of the input parametsrs are :', p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of the INVENTORY_ITEM_ID : ' || p_lot_rec.inventory_item_id, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of ORGANIZATION_ID :' || p_lot_rec.organization_id, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of LOT_NUMBER :' || p_lot_rec.lot_number, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of PARENT LOT_NUMBER :' || p_lot_rec.parent_lot_number, p_level => 9);

      print_debug(p_err_msg => 'Update Lot Attr: The value of the EXPIRATION_DATE :' || p_lot_rec.expiration_date, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of the DISABLE_FLAG :' || p_lot_rec.disable_flag, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of the ATTRIBUTE_CATEGORY :' || p_lot_rec.attribute_category, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of the LOT_ATTRIBUTE_CATEGORY :' || p_lot_rec.lot_attribute_category, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of the GRADE_CODE :' || p_lot_rec.grade_code, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of the ORIGINATION_DATE :' || p_lot_rec.origination_date, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of the DATE_CODE :' || p_lot_rec.date_code, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of the STATUS_ID :' || p_lot_rec.status_id, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of the CHANGE_DATE :' || p_lot_rec.change_date, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of the AGE :' || p_lot_rec.age, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of the RETEST_DATE :' || p_lot_rec.retest_date, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of the MATURITY_DATE :' || p_lot_rec.maturity_date, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of the ITEM_SIZE :' || p_lot_rec.item_size, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of COLOR :' || p_lot_rec.color, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of VOLUME :' || p_lot_rec.volume, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of VOLUME_UOM :' || p_lot_rec.volume_uom, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of PLACE_OF_ORIGIN :' || p_lot_rec.place_of_origin, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of BEST_BY_DATE :' || p_lot_rec.best_by_date, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of LENGTH :' || p_lot_rec.length, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of LENGTH_UOM:' || p_lot_rec.length_uom, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of RECYCLED_CONTENT :' || p_lot_rec.recycled_content, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of THICKNESS :' || p_lot_rec.thickness, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of THICKNESS_UOM :' || p_lot_rec.thickness_uom, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of WIDTH  :' || p_lot_rec.width, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of WIDTH_UOM :' || p_lot_rec.width_uom, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of Territory Code :' || p_lot_rec.territory_code, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of VENDOR_NAME :' || p_lot_rec.vendor_name, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of SUPPLIER_LOT_NUMBER :' || p_lot_rec.supplier_lot_number, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of SUPPLIER_LOT_NUMBER :' || p_lot_rec.supplier_lot_number, p_level => 9);
      print_debug(p_err_msg => 'Update Lot Attr: The value of P_SOURCE :' || p_source, p_level => 9);
    END IF;

    /* Check if this combination is valid */
    BEGIN
      SELECT 1
        INTO l_chk
        FROM mtl_lot_numbers
       WHERE inventory_item_id = p_lot_rec.inventory_item_id
         AND organization_id = p_lot_rec.organization_id
         AND lot_number = p_lot_rec.lot_number;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF g_debug = 1 THEN
          print_debug('Upd Lot Attr : Conmbination of Lot number,Item and Org does not exists', 9);
        END IF;

        fnd_message.set_name('INV', 'INV_LOT_NOT_EXISTS');
   fnd_msg_pub.add;
        --fnd_message.set_token('LOT',p_lot_rec.lot_number);
        RAISE g_exc_error;
    END;

    BEGIN
      SELECT shelf_life_days
           , shelf_life_code
        INTO l_shelf_life_days
           , l_shelf_life_code
        FROM mtl_system_items
       WHERE inventory_item_id = p_lot_rec.inventory_item_id
         AND organization_id = p_lot_rec.organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    /*Start of changes for bug  4888300 */
    IF ( l_shelf_life_code IN (item_shelf_life_days ,user_defined_exp_date)
         AND p_lot_rec.expiration_date IS NOT NULL ) THEN
      IF g_debug = 1 THEN
        print_debug('Shelf_life code is of type USER_DEFINED_EXP_DATE OR ITEM_SHELF_LIFE_DAYS', 9);
      END IF;

      IF p_lot_rec.expiration_date <> g_miss_date THEN
        l_expiration_date  := p_lot_rec.expiration_date;
      ELSE
        l_expiration_date  := NULL;
      END IF;
    /*End of changes for bug  4888300 */

   ELSE
      l_expiration_date  := NULL;    --4888300
      IF g_debug = 1 THEN
        print_debug('Shelf_life code is of type NO_SHELF_LIFE_CONTROL', 9);
      END IF;
   END IF;

     --END IF; /* IF NOT in (OSFM_FORM.OSFM_OPEN_INTERFACE)*/   --4888300

    OPEN attr_category_cur;
    FETCH attr_category_cur INTO l_attr_category_cur;
    CLOSE attr_category_cur;

    IF g_debug = 1 THEN
      print_debug('Upd Lot Attr: After gteting the attribte category', 9);
    END IF;

    OPEN inv_attributes_cur;
    FETCH inv_attributes_cur INTO l_inv_attributes_cur;
    CLOSE inv_attributes_cur;
    l_inv_attributes_tbl(1)   := l_inv_attributes_cur.attribute1;
    l_inv_attributes_tbl(2)   := l_inv_attributes_cur.attribute2;
    l_inv_attributes_tbl(3)   := l_inv_attributes_cur.attribute3;
    l_inv_attributes_tbl(4)   := l_inv_attributes_cur.attribute4;
    l_inv_attributes_tbl(5)   := l_inv_attributes_cur.attribute5;
    l_inv_attributes_tbl(6)   := l_inv_attributes_cur.attribute6;
    l_inv_attributes_tbl(7)   := l_inv_attributes_cur.attribute7;
    l_inv_attributes_tbl(8)   := l_inv_attributes_cur.attribute8;
    l_inv_attributes_tbl(9)   := l_inv_attributes_cur.attribute9;
    l_inv_attributes_tbl(10)  := l_inv_attributes_cur.attribute10;
    l_inv_attributes_tbl(11)  := l_inv_attributes_cur.attribute11;
    l_inv_attributes_tbl(12)  := l_inv_attributes_cur.attribute12;
    l_inv_attributes_tbl(13)  := l_inv_attributes_cur.attribute13;
    l_inv_attributes_tbl(14)  := l_inv_attributes_cur.attribute14;
    l_inv_attributes_tbl(15)  := l_inv_attributes_cur.attribute15;

    /* **************************New additions ************************************ */
    /*Get the Contexts for the flex definition and check if any of the columns are required.
      If it is required, populate the value in a new table l_res_inv_attributes_tbl with
      the l_inv_attributes_tbl. This is done INV attributes  and wms attributes
      Following will be pseudo code
        1. Get the Global context from INV attributes
        2. Check if any of the segment is required(mandatory)
        3. If required populate the value in l_res_inv_attributes_tbl
           which is obtained from l_inv_attributes_tbl table
        4. Set the context to INV  context and fetch the segments for this context
        5. Loop through the segments and find out if any of the segments are
           required (mandatory)
        6. If so populate the value at the corresponding index with the value obtained
           from l_inv_attributes_tbl table
        7. Now at this point of time we have l_res_inv_attributes_tbl has only those
           segments whose value are required(mandatory)
        8. Loop through the input table p_attributes_tbl and populate the
           corresponding values in the l_res_inv_attributes_tbl
        9. Set the flex field defn to Lot Attributes
       10. Get the global context for WMS attributes
       11. check if the applicaton column name is C_attribute,D_attribute or N_Attribute
       12. Check if the corresponding column is required or not. If req, populate the new
            table l_res_c_attributes_tbl, or  l_res_d_attributes_tbl or l_res_n_attributes_tbl
       13. Set the context to  Lot Attribute Category
       14. Fetch all the segments for the context
       15. Check if the corresponding column is required or not. If req, populate the new
            table l_res_c_attributes_tbl, or  l_res_d_attributes_tbl or l_res_n_attributes_tbl
       16. Loop through the input tables p_c_attributes,p_d_attributes and p_n_attributes
           and populate the corresponding value in l_res_c_attributes_tbl,
           l_res_d_attributes_tbl,l_res_n_attributes_tbl
     */
    IF p_source NOT IN(osfm_form_no_validate) THEN
       IF g_debug = 1 THEN
           print_debug(p_err_msg => 'Source is Not From OSFM_FORM  So validating  the  Inventory Attributes  .....  ' , p_level => 9);
       END IF;
      --IF l_attr_category_cur.attribute_category IS NOT NULL THEN
        -- AND p_attributes_tbl.COUNT > 0 THEN
        /* Populate the flex field record */
        l_dflex_r.application_id  := 401;
        l_dflex_r.flexfield_name  := 'MTL_LOT_NUMBERS';
        /* Get all contexts */
        fnd_dflex.get_contexts(flexfield => l_dflex_r, contexts => l_contexts_dr);
        /* From the l_contexts_dr, get the position of the global context */
        l_global_context          := l_contexts_dr.global_context;
        l_context                 := l_contexts_dr.context_code(l_global_context);
        /* Prepare the context_r type for getting the segments associated with the global context */
        l_context_r.flexfield     := l_dflex_r;
        l_context_r.context_code  := l_context;
        /*Get the segments for the context */
        fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);

        /*Loop through the Segments table to see if any segments are required */
        --inv_global_index :=l_segments_dr.first;
        l_global_nsegments := l_segments_dr.nsegments;

        FOR inv_global_index IN 1 .. l_segments_dr.nsegments LOOP
          IF l_segments_dr.is_required(inv_global_index) THEN
            l_res_inv_attributes_tbl(
              SUBSTR(
                l_segments_dr.application_column_name(inv_global_index)
              , INSTR(l_segments_dr.application_column_name(inv_global_index), 'ATTRIBUTE') + 9
              )
            )                                                                                                                                                                          :=
              l_inv_attributes_tbl(
                SUBSTR(
                  l_segments_dr.application_column_name(inv_global_index)
                , INSTR(l_segments_dr.application_column_name(inv_global_index), 'ATTRIBUTE') + 9
                )
              );
          END IF;
        --inv_global_index :=l_segments_dr.next(inv_global_index);
        END LOOP;
    IF g_debug = 1 THEN
           print_debug(p_err_msg => 'Successfully validated INV global segments   .....  ' , p_level => 9);
       END IF;


        /* Prepare the context_r type for getting the segments associated with the
           attribute_category */
       if( nvl(p_lot_rec.attribute_category, l_attr_category_cur.attribute_Category) IS NOT NULL ) THEN

           l_context_r.flexfield     := l_dflex_r;
           l_context_r.context_code  := nvl(p_lot_rec.attribute_category, l_attr_category_cur.attribute_category);
           /*Get the segments for the context */
           fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);
           /*Loop through the Segments table to see if any segments are required */
           inv_context_index         := NULL;

           --inv_context_index :=l_segments_dr.first;
           FOR inv_context_index IN 1 .. l_segments_dr.nsegments LOOP
             IF l_segments_dr.is_required(inv_context_index) THEN
               l_res_inv_attributes_tbl(
                 SUBSTR(
                   l_segments_dr.application_column_name(inv_context_index)
                 , INSTR(l_segments_dr.application_column_name(inv_context_index), 'ATTRIBUTE') + 9
                 )
               )                                                                                                                                                                            :=
                 l_inv_attributes_tbl(
                   SUBSTR(
                     l_segments_dr.application_column_name(inv_context_index)
                   , INSTR(l_segments_dr.application_column_name(inv_context_index), 'ATTRIBUTE') + 9
                   )
                 );
             END IF;
           END LOOP;
      IF g_debug = 1 THEN
              print_debug(p_err_msg => 'Successfully validated INV input  Context  segments   .....  ' , p_level => 9);
           END IF;
        END IF;  /*IF l_attr_category_cur.attribute_category IS NOT NULL */

    END IF;  /*P_SOURCE NOT IN (OSFM_FORM)*/

    IF (p_lot_rec.attribute1 = g_miss_char) THEN
       l_res_inv_attributes_tbl(1)  := NULL;
       l_inv_attributes_tbl(1)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(1)  := p_lot_rec.attribute1;
       l_inv_attributes_tbl(1)      := p_lot_rec.attribute1;
    END IF;
    IF (p_lot_rec.attribute2 = g_miss_char) THEN
       l_res_inv_attributes_tbl(2)  := NULL;
       l_inv_attributes_tbl(2)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(2)  := p_lot_rec.attribute2;
       l_inv_attributes_tbl(2)      := p_lot_rec.attribute2;
    END IF;
    IF (p_lot_rec.attribute3 = g_miss_char) THEN
       l_res_inv_attributes_tbl(3)  := NULL;
       l_inv_attributes_tbl(3)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(3)  := p_lot_rec.attribute3;
       l_inv_attributes_tbl(3)      := p_lot_rec.attribute3;
    END IF;
    IF (p_lot_rec.attribute4 = g_miss_char) THEN
       l_res_inv_attributes_tbl(4)  := NULL;
       l_inv_attributes_tbl(4)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(4)  := p_lot_rec.attribute4;
       l_inv_attributes_tbl(4)      := p_lot_rec.attribute4;
    END IF;
    IF (p_lot_rec.attribute5 = g_miss_char) THEN
       l_res_inv_attributes_tbl(5)  := NULL;
       l_inv_attributes_tbl(5)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(5)  := p_lot_rec.attribute5;
       l_inv_attributes_tbl(5)      := p_lot_rec.attribute5;
    END IF;
    IF (p_lot_rec.attribute6 = g_miss_char) THEN
       l_res_inv_attributes_tbl(6)  := NULL;
       l_inv_attributes_tbl(6)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(6)  := p_lot_rec.attribute6;
       l_inv_attributes_tbl(6)      := p_lot_rec.attribute6;
    END IF;
    IF (p_lot_rec.attribute7 = g_miss_char) THEN
       l_res_inv_attributes_tbl(7)  := NULL;
       l_inv_attributes_tbl(7)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(7)  := p_lot_rec.attribute7;
       l_inv_attributes_tbl(7)      := p_lot_rec.attribute7;
    END IF;
    IF (p_lot_rec.attribute8 = g_miss_char) THEN
       l_res_inv_attributes_tbl(8)  := NULL;
       l_inv_attributes_tbl(8)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(8)  := p_lot_rec.attribute8;
       l_inv_attributes_tbl(8)      := p_lot_rec.attribute8;
    END IF;
    IF (p_lot_rec.attribute9 = g_miss_char) THEN
       l_res_inv_attributes_tbl(9)  := NULL;
       l_inv_attributes_tbl(9)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(9)  := p_lot_rec.attribute9;
       l_inv_attributes_tbl(9)      := p_lot_rec.attribute9;
    END IF;
    IF (p_lot_rec.attribute10 = g_miss_char) THEN
       l_res_inv_attributes_tbl(10)  := NULL;
       l_inv_attributes_tbl(10)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(10)  := p_lot_rec.attribute10;
       l_inv_attributes_tbl(10)      := p_lot_rec.attribute10;
    END IF;
    IF (p_lot_rec.attribute11 = g_miss_char) THEN
       l_res_inv_attributes_tbl(11)  := NULL;
       l_inv_attributes_tbl(11)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(11)  := p_lot_rec.attribute11;
       l_inv_attributes_tbl(11)      := p_lot_rec.attribute11;
    END IF;
    IF (p_lot_rec.attribute12 = g_miss_char) THEN
       l_res_inv_attributes_tbl(12)  := NULL;
       l_inv_attributes_tbl(12)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(12)  := p_lot_rec.attribute12;
       l_inv_attributes_tbl(12)      := p_lot_rec.attribute12;
    END IF;
    IF (p_lot_rec.attribute13 = g_miss_char) THEN
       l_res_inv_attributes_tbl(13)  := NULL;
       l_inv_attributes_tbl(13)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(13)  := p_lot_rec.attribute13;
       l_inv_attributes_tbl(13)      := p_lot_rec.attribute13;
    END IF;
    IF (p_lot_rec.attribute14 = g_miss_char) THEN
       l_res_inv_attributes_tbl(14)  := NULL;
       l_inv_attributes_tbl(14)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(14)  := p_lot_rec.attribute14;
       l_inv_attributes_tbl(14)      := p_lot_rec.attribute14;
    END IF;
    IF (p_lot_rec.attribute15 = g_miss_char) THEN
       l_res_inv_attributes_tbl(15)  := NULL;
       l_inv_attributes_tbl(15)      := g_miss_char;
    ELSE
       l_res_inv_attributes_tbl(15)  := p_lot_rec.attribute15;
       l_inv_attributes_tbl(15)      := p_lot_rec.attribute15;
    END IF;


    IF g_debug = 1 THEN
      print_debug('Upd Lot Attr: After preparing the table INV_Attributes', 9);
    END IF;

    IF G_WMS_INSTALLED is NULL  then
       IF (inv_install.adv_inv_installed(NULL) = TRUE) THEN
      G_WMS_INSTALLED := 'TRUE';
        ELSE
      G_WMS_INSTALLED := 'FALSE';
   end if;
    end if;
    l_wms_installed := G_WMS_INSTALLED;

    if g_debug = 1 then
   print_debug('Upd Lot Attr: l_wms_installed is ' || l_wms_installed, 9);
   print_debug('Upd Lot Attr: lot_attribute_category ' || p_lot_rec.lot_attribute_category, 9);
    end if;

    IF l_wms_installed = 'TRUE' then
      IF g_debug = 1 THEN
        print_debug('Upd Lot Attr: WMS is installed ', 9);
      END IF;

      IF p_lot_rec.lot_attribute_category IS NULL THEN
        inv_lot_sel_attr.get_context_code(l_context, p_lot_rec.organization_id, p_lot_rec.inventory_item_id, 'Lot Attributes');
      ELSE
        l_context  := p_lot_rec.lot_attribute_category;
      END IF;

      OPEN c_attributes_cur;
      FETCH c_attributes_cur INTO l_c_attributes_cur;
      CLOSE c_attributes_cur;
      OPEN n_attributes_cur;
      FETCH n_attributes_cur INTO l_n_attributes_cur;
      CLOSE n_attributes_cur;
      OPEN d_attributes_cur;
      FETCH d_attributes_cur INTO l_d_attributes_cur;
      CLOSE d_attributes_cur;
      OPEN wms_named_attr;
      FETCH wms_named_attr INTO l_wms_named_attr;
      CLOSE wms_named_attr;
      /*Populate the PL/SQL tables with the values obtained from the cursor*/
      l_c_attributes_tbl(1)   := l_c_attributes_cur.c_attribute1;
      l_c_attributes_tbl(2)   := l_c_attributes_cur.c_attribute2;
      l_c_attributes_tbl(3)   := l_c_attributes_cur.c_attribute3;
      l_c_attributes_tbl(4)   := l_c_attributes_cur.c_attribute4;
      l_c_attributes_tbl(5)   := l_c_attributes_cur.c_attribute5;
      l_c_attributes_tbl(6)   := l_c_attributes_cur.c_attribute6;
      l_c_attributes_tbl(7)   := l_c_attributes_cur.c_attribute7;
      l_c_attributes_tbl(8)   := l_c_attributes_cur.c_attribute8;
      l_c_attributes_tbl(9)   := l_c_attributes_cur.c_attribute9;
      l_c_attributes_tbl(10)  := l_c_attributes_cur.c_attribute10;
      l_c_attributes_tbl(11)  := l_c_attributes_cur.c_attribute11;
      l_c_attributes_tbl(12)  := l_c_attributes_cur.c_attribute12;
      l_c_attributes_tbl(13)  := l_c_attributes_cur.c_attribute13;
      l_c_attributes_tbl(14)  := l_c_attributes_cur.c_attribute14;
      l_c_attributes_tbl(15)  := l_c_attributes_cur.c_attribute15;
      l_c_attributes_tbl(16)  := l_c_attributes_cur.c_attribute16;
      l_c_attributes_tbl(17)  := l_c_attributes_cur.c_attribute17;
      l_c_attributes_tbl(18)  := l_c_attributes_cur.c_attribute18;
      l_c_attributes_tbl(19)  := l_c_attributes_cur.c_attribute19;
      l_c_attributes_tbl(20)  := l_c_attributes_cur.c_attribute20;
      l_n_attributes_tbl(1)   := l_n_attributes_cur.n_attribute1;
      l_n_attributes_tbl(2)   := l_n_attributes_cur.n_attribute2;
      l_n_attributes_tbl(3)   := l_n_attributes_cur.n_attribute3;
      l_n_attributes_tbl(4)   := l_n_attributes_cur.n_attribute4;
      l_n_attributes_tbl(5)   := l_n_attributes_cur.n_attribute5;
      l_n_attributes_tbl(6)   := l_n_attributes_cur.n_attribute6;
      l_n_attributes_tbl(7)   := l_n_attributes_cur.n_attribute7;
      l_n_attributes_tbl(8)   := l_n_attributes_cur.n_attribute8;
      l_n_attributes_tbl(9)   := l_n_attributes_cur.n_attribute9;
      l_n_attributes_tbl(10)  := l_n_attributes_cur.n_attribute10;
      l_d_attributes_tbl(1)   := l_d_attributes_cur.d_attribute1;
      l_d_attributes_tbl(2)   := l_d_attributes_cur.d_attribute2;
      l_d_attributes_tbl(3)   := l_d_attributes_cur.d_attribute3;
      l_d_attributes_tbl(4)   := l_d_attributes_cur.d_attribute4;
      l_d_attributes_tbl(5)   := l_d_attributes_cur.d_attribute5;
      l_d_attributes_tbl(6)   := l_d_attributes_cur.d_attribute6;
      l_d_attributes_tbl(7)   := l_d_attributes_cur.d_attribute7;
      l_d_attributes_tbl(8)   := l_d_attributes_cur.d_attribute8;
      l_d_attributes_tbl(9)   := l_d_attributes_cur.d_attribute9;
      l_d_attributes_tbl(10)  := l_d_attributes_cur.d_attribute10;

      l_wms_named_attributes.grade_code          := p_lot_rec.grade_code;
      l_wms_named_attributes.DISABLE_FLAG        := p_lot_rec.disable_flag;
      l_wms_named_attributes.origination_date    := p_lot_rec.origination_date;
      l_wms_named_attributes.date_code           := p_lot_rec.date_code;
      l_wms_named_attributes.change_date         := p_lot_rec.change_date;
      l_wms_named_attributes.age                 := p_lot_rec.age;
      l_wms_named_attributes.retest_date         := p_lot_rec.retest_date;
      l_wms_named_attributes.maturity_date       := p_lot_rec.maturity_date;
      l_wms_named_attributes.item_size           := p_lot_rec.item_size;
      l_wms_named_attributes.color               := p_lot_rec.color;
      l_wms_named_attributes.volume              := p_lot_rec.volume;
      l_wms_named_attributes.volume_uom          := p_lot_rec.volume_uom;
      l_wms_named_attributes.place_of_origin     := p_lot_rec.place_of_origin;
      l_wms_named_attributes.best_by_date        := p_lot_rec.best_by_date;
      l_wms_named_attributes.length              := p_lot_rec.length;
      l_wms_named_attributes.length_uom          := p_lot_rec.length_uom;
      l_wms_named_attributes.recycled_content    := p_lot_rec.recycled_content;
      l_wms_named_attributes.thickness           := p_lot_rec.thickness;
      l_wms_named_attributes.thickness_uom       := p_lot_rec.thickness_uom;
      l_wms_named_attributes.width               := p_lot_rec.width;
      l_wms_named_attributes.width_uom           := p_lot_rec.width_uom;
      l_wms_named_attributes.territory_code      := p_lot_rec.territory_code;
      l_wms_named_attributes.supplier_lot_number := p_lot_rec.supplier_lot_number;
      l_wms_named_attributes.VENDOR_NAME         := p_lot_rec.vendor_name;

      IF g_debug = 1 THEN
        print_debug('Upd Lot Attr: After getting attributes from the table MLN ' , 9);
      END IF;

      IF p_source NOT IN(osfm_form_no_validate) THEN
           IF g_debug = 1 THEN
           print_debug('Validating the Global Segments for WMS context ....' , 9);
      END IF;
        IF l_context IS NOT NULL  THEN
          /* Populate the flex field record */

          l_dflex_r.application_id  := 401;
          l_dflex_r.flexfield_name  := 'Lot Attributes';

          /* Get all contexts */

          fnd_dflex.get_contexts(flexfield => l_dflex_r, contexts => l_contexts_dr);
          l_context                 := NULL;
          l_global_context          := NULL;

          /* From the l_contexts_dr, get the position of the global context */

          l_global_context          := l_contexts_dr.global_context;
          l_context                 := l_contexts_dr.context_code(l_global_context);

          /* Prepare the context_r type for getting the segments associated with the global context */

          l_context_r.flexfield     := l_dflex_r;
          l_context_r.context_code  := l_context;

          /*Get the segments for the context */

          fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);

          /*Loop through the Segments table to see if any segments are required */

          --wms_global_index :=l_segments_dr.first;
          FOR wms_global_index IN 1 .. l_segments_dr.nsegments LOOP
            IF l_segments_dr.is_required(wms_global_index) THEN
              --print_debug('Segment '|| l_segments_dr.application_column_name(wms_global_index)||'is required',9);
              IF SUBSTR(l_segments_dr.application_column_name(wms_global_index), INSTR(l_segments_dr.application_column_name(wms_global_index),'ATTRIBUTE')-2, 2) = 'C_' THEN
                l_res_c_attributes_tbl(
                  SUBSTR(
                    l_segments_dr.application_column_name(wms_global_index)
                  , INSTR(l_segments_dr.application_column_name(wms_global_index), 'ATTRIBUTE') + 9
                  )
                )                                                                                                                                                                        :=
                  l_c_attributes_tbl(
                    SUBSTR(
                      l_segments_dr.application_column_name(wms_global_index)
                    , INSTR(l_segments_dr.application_column_name(wms_global_index), 'ATTRIBUTE') + 9
                    )
                  );
              --print_debug('upd Lot  Attr tHE VALUE ENTERED IS '|| l_c_attributes_tbl(SUBSTR(l_segments_dr.application_column_name(wms_global_index), INSTR(l_segments_dr.application_column_name(wms_global_index), 'ATTRIBUTE') + 9)), 9);
              ELSIF SUBSTR(l_segments_dr.application_column_name(wms_global_index), INSTR(l_segments_dr.application_column_name(wms_global_index),'ATTRIBUTE')-2, 2) = 'N_' THEN
                l_res_n_attributes_tbl(
                  SUBSTR(
                    l_segments_dr.application_column_name(wms_global_index)
                  , INSTR(l_segments_dr.application_column_name(wms_global_index), 'ATTRIBUTE') + 9
                  )
                )                                                                                                                                                                        :=
                  l_n_attributes_tbl(
                    SUBSTR(
                      l_segments_dr.application_column_name(wms_global_index)
                    , INSTR(l_segments_dr.application_column_name(wms_global_index), 'ATTRIBUTE') + 9
                    )
                  );
              ELSIF SUBSTR(l_segments_dr.application_column_name(wms_global_index), INSTR(l_segments_dr.application_column_name(wms_global_index),'ATTRIBUTE')-2, 2) = 'D_' THEN
                l_res_d_attributes_tbl(
                  SUBSTR(
                    l_segments_dr.application_column_name(wms_global_index)
                  , INSTR(l_segments_dr.application_column_name(wms_global_index), 'ATTRIBUTE') + 9
                  )
                )                                                                                                                                                                        :=
                  l_d_attributes_tbl(
                    SUBSTR(
                      l_segments_dr.application_column_name(wms_global_index)
                    , INSTR(l_segments_dr.application_column_name(wms_global_index), 'ATTRIBUTE') + 9
                    )
                  );
              ELSIF l_segments_dr.application_column_name(wms_global_index) = 'GRADE_CODE' THEN
                 l_wms_named_attributes.grade_code := NVL(l_wms_named_attributes.grade_code,l_wms_named_attr.GRADE_CODE);
              ELSIF l_segments_dr.application_column_name(wms_global_index) = 'DISABLE_FLAG' THEN
                 l_wms_named_attributes.DISABLE_FLAG        := NVL(l_wms_named_attributes.DISABLE_FLAG,l_wms_named_attr.DISABLE_FLAG);
              ELSIF l_segments_dr.application_column_name(wms_global_index) = 'ORIGINATION_DATE' THEN
                 l_wms_named_attributes.origination_date := NVL(l_wms_named_attributes.origination_date,L_WMS_NAMED_ATTR.origination_date);
              ELSIF  l_segments_dr.application_column_name(wms_global_index) = 'DATE_CODE' THEN
                 l_wms_named_attributes.date_code   := NVL(l_wms_named_attributes.date_code,l_wms_named_attr.DATE_CODE);
              ELSIF l_segments_dr.application_column_name(wms_global_index) = 'CHANGE_DATE' THEN
                 l_wms_named_attributes.change_date := NVL(l_wms_named_attributes.change_date,l_wms_named_attr.CHANGE_DATE);
              ELSIF l_segments_dr.application_column_name(wms_global_index) = 'AGE' THEN
                 l_wms_named_attributes.age := NVL(l_wms_named_attributes.age,l_wms_named_attr.AGE);
              ELSIF l_segments_dr.application_column_name(wms_global_index) = 'RETEST_DATE' THEN
                 l_wms_named_attributes.retest_date :=NVL(l_wms_named_attributes.retest_date ,l_wms_named_attr.retest_date);
              ELSIF l_segments_dr.application_column_name(wms_global_index) = 'MATURITY_DATE' THEN
                 l_wms_named_attributes.maturity_date := NVL(l_wms_named_attributes.maturity_date,l_wms_named_attr.MATURITY_DATE) ;
              ELSIF l_segments_dr.application_column_name(wms_global_index) = 'ITEM_SIZE' THEN
                 l_wms_named_attributes.item_size := NVL(l_wms_named_attributes.item_size,l_wms_named_attr.ITEM_SIZE);
              ELSIF l_segments_dr.application_column_name(wms_global_index) = 'COLOR' THEN
                 l_wms_named_attributes.color := nvl(l_wms_named_attributes.color,l_wms_named_attr.COLOR);
              ELSIF  l_segments_dr.application_column_name(wms_global_index) = 'VOLUME' THEN
                 l_wms_named_attributes.volume := NVL(l_wms_named_attributes.volume,l_wms_named_attr.VOLUME);
              ELSIF  l_segments_dr.application_column_name(wms_global_index) = 'VOLUME_UOM' THEN
                 l_wms_named_attributes.volume_uom := NVL(l_wms_named_attributes.volume_uom,l_wms_named_attr.VOLUME_UOM);
              ELSIF  l_segments_dr.application_column_name(wms_global_index) = 'PLACE_OF_ORIGIN' THEN
                 l_wms_named_attributes.place_of_origin := nvl(l_wms_named_attributes.place_of_origin,l_wms_named_attr.PLACE_OF_ORIGIN);
              ELSIF  l_segments_dr.application_column_name(wms_global_index) = 'BEST_BY_DATE' THEN
                 l_wms_named_attributes.best_by_date := NVL(l_wms_named_attributes.best_by_date,l_wms_named_attr.BEST_BY_DATE);
              ELSIF  l_segments_dr.application_column_name(wms_global_index) = 'LENGTH' THEN
                 l_wms_named_attributes.length := nvl(l_wms_named_attributes.length,l_wms_named_attr.LENGTH);
              ELSIF  l_segments_dr.application_column_name(wms_global_index) = 'RECYCLED_CONTENT' THEN
                 l_wms_named_attributes.recycled_content := NVL(l_wms_named_attributes.recycled_content,l_wms_named_attr.RECYCLED_CONTENT);
              ELSIF  l_segments_dr.application_column_name(wms_global_index) = 'THICKNESS' THEN
                 l_wms_named_attributes.thickness := NVL(l_wms_named_attributes.thickness,l_wms_named_attr.THICKNESS);
              ELSIF  l_segments_dr.application_column_name(wms_global_index) = 'THICKNESS_UOM' THEN
                 l_wms_named_attributes.thickness_uom := NVL(l_wms_named_attributes.thickness_uom,l_wms_named_attr.THICKNESS_UOM);
              ELSIF  l_segments_dr.application_column_name(wms_global_index) = 'WIDTH' THEN
                 l_wms_named_attributes.width := NVL(l_wms_named_attributes.width,l_wms_named_attr.WIDTH);
              ELSIF  l_segments_dr.application_column_name(wms_global_index) = 'WIDTH_UOM' THEN
                 l_wms_named_attributes.width_uom := NVL(l_wms_named_attributes.width_uom,l_wms_named_attr.WIDTH_UOM);
              ELSIF l_segments_dr.application_column_name(wms_global_index) = 'TERRITORY_CODE' THEN
                 l_wms_named_attributes.territory_code := NVL(l_wms_named_attributes.territory_code,l_wms_named_attr.TERRITORY_CODE);
              ELSIF l_segments_dr.application_column_name(wms_global_index) = 'SUPPLIER_LOT_NUMBER' THEN
                 l_wms_named_attributes.supplier_lot_number := NVL(l_wms_named_attributes.supplier_lot_number,l_wms_named_attr.SUPPLIER_LOT_NUMBER);
              ELSIF  l_segments_dr.application_column_name(wms_global_index) = 'VENDOR_NAME' THEN
                 l_wms_named_attributes.VENDOR_NAME := NVL(l_wms_named_attributes.VENDOR_NAME,l_wms_named_attr.VENDOR_NAME);
              END IF; /*SUBSTR(l_segments_dr.application_column_name(wms_global_index), 1, 1) = 'C' */
            END IF; /*l_segments_dr.is_required(wms_global_index) */
          --wms_global_index :=l_segments_dr.next(wms_global_index);
          END LOOP;
       IF g_debug = 1 THEN
           print_debug('Successfully Validated the Global Segments for WMS DFF  ....' , 9);
      END IF;

          l_context                 := NULL;

          IF p_lot_rec.lot_attribute_category IS NULL THEN
            inv_lot_sel_attr.get_context_code(l_context, p_lot_rec.organization_id, p_lot_rec.inventory_item_id, 'Lot Attributes');
          ELSE
            l_context  := p_lot_rec.lot_attribute_category;
          END IF;

          /* Prepare the context_r type for getting the segments associated with the global context */
          l_context_r.flexfield     := l_dflex_r;
          l_context_r.context_code  := l_context;
          /*Get the segments for the context */
          fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);
          /*Loop through the Segments table to see if any segments are required */
          --wms_context_index :=l_segments_dr.first;
          print_debug('Before looping for wms context', 9);

          FOR wms_context_index IN 1 .. l_segments_dr.nsegments LOOP
            IF l_segments_dr.is_required(wms_context_index) THEN
              print_debug('Segment ' || l_segments_dr.application_column_name(wms_context_index) || ' is required', 9);

              IF SUBSTR(l_segments_dr.application_column_name(wms_context_index), INSTR(l_segments_dr.application_column_name(wms_context_index),'ATTRIBUTE')-2, 2) = 'C_' THEN
                l_res_c_attributes_tbl(
                  SUBSTR(
                    l_segments_dr.application_column_name(wms_context_index)
                  , INSTR(l_segments_dr.application_column_name(wms_context_index), 'ATTRIBUTE') + 9
                  )
                )                                                                                                                                                                          :=
                  l_c_attributes_tbl(
                    SUBSTR(
                      l_segments_dr.application_column_name(wms_context_index)
                    , INSTR(l_segments_dr.application_column_name(wms_context_index), 'ATTRIBUTE') + 9
                    )
                  );
              ELSIF SUBSTR(l_segments_dr.application_column_name(wms_context_index), INSTR(l_segments_dr.application_column_name(wms_context_index),'ATTRIBUTE')-2, 2) = 'N_' THEN
                l_res_n_attributes_tbl(
                  SUBSTR(
                    l_segments_dr.application_column_name(wms_context_index)
                  , INSTR(l_segments_dr.application_column_name(wms_context_index), 'ATTRIBUTE') + 9
                  )
                )                                                                                                                                                                          :=
                  l_n_attributes_tbl(
                    SUBSTR(
                      l_segments_dr.application_column_name(wms_context_index)
                    , INSTR(l_segments_dr.application_column_name(wms_context_index), 'ATTRIBUTE') + 9
                    )
                  );
              ELSIF SUBSTR(l_segments_dr.application_column_name(wms_context_index), INSTR(l_segments_dr.application_column_name(wms_context_index),'ATTRIBUTE')-2, 2) = 'D_' THEN
                l_res_d_attributes_tbl(
                  SUBSTR(
                    l_segments_dr.application_column_name(wms_context_index)
                  , INSTR(l_segments_dr.application_column_name(wms_context_index), 'ATTRIBUTE') + 9
                  )
                )                                                                                                                                                                          :=
                  l_d_attributes_tbl(
                    SUBSTR(
                      l_segments_dr.application_column_name(wms_context_index)
                    , INSTR(l_segments_dr.application_column_name(wms_context_index), 'ATTRIBUTE') + 9
                    )
                  );
              ELSIF l_segments_dr.application_column_name(wms_context_index) = 'GRADE_CODE' THEN
                 l_wms_named_attributes.grade_code := NVL(l_wms_named_attributes.grade_code,l_wms_named_attr.GRADE_CODE);
              ELSIF l_segments_dr.application_column_name(wms_context_index) = 'DISABLE_FLAG' THEN
                 l_wms_named_attributes.DISABLE_FLAG        := NVL(l_wms_named_attributes.DISABLE_FLAG,l_wms_named_attr.DISABLE_FLAG);
              ELSIF l_segments_dr.application_column_name(wms_context_index) = 'ORIGINATION_DATE' THEN
                 l_wms_named_attributes.origination_date := NVL(l_wms_named_attributes.origination_date,L_WMS_NAMED_ATTR.origination_date);
              ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'DATE_CODE' THEN
                 l_wms_named_attributes.date_code   := NVL(l_wms_named_attributes.date_code,l_wms_named_attr.DATE_CODE);
              ELSIF l_segments_dr.application_column_name(wms_context_index) = 'CHANGE_DATE' THEN
                 l_wms_named_attributes.change_date := NVL(l_wms_named_attributes.change_date,l_wms_named_attr.CHANGE_DATE);
              ELSIF l_segments_dr.application_column_name(wms_context_index) = 'AGE' THEN
                 l_wms_named_attributes.age := NVL(l_wms_named_attributes.age,l_wms_named_attr.AGE);
              ELSIF l_segments_dr.application_column_name(wms_context_index) = 'RETEST_DATE' THEN
                 l_wms_named_attributes.retest_date :=NVL(l_wms_named_attributes.retest_date ,l_wms_named_attr.retest_date);
              ELSIF l_segments_dr.application_column_name(wms_context_index) = 'MATURITY_DATE' THEN
                 l_wms_named_attributes.maturity_date := NVL(l_wms_named_attributes.maturity_date,l_wms_named_attr.MATURITY_DATE);
              ELSIF l_segments_dr.application_column_name(wms_context_index) = 'ITEM_SIZE' THEN
                 l_wms_named_attributes.item_size := NVL(l_wms_named_attributes.item_size,l_wms_named_attr.ITEM_SIZE);
              ELSIF l_segments_dr.application_column_name(wms_context_index) = 'COLOR' THEN
                 l_wms_named_attributes.color := nvl(l_wms_named_attributes.color,l_wms_named_attr.COLOR);
              ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'VOLUME' THEN
                 l_wms_named_attributes.volume := NVL(l_wms_named_attributes.volume,l_wms_named_attr.VOLUME);
              ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'VOLUME_UOM' THEN
                 l_wms_named_attributes.volume_uom := NVL(l_wms_named_attributes.volume_uom,l_wms_named_attr.VOLUME_UOM);
              ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'PLACE_OF_ORIGIN' THEN
                 l_wms_named_attributes.place_of_origin := nvl(l_wms_named_attributes.place_of_origin,l_wms_named_attr.PLACE_OF_ORIGIN);
                 IF G_DEBUG =1 THEN
                    PRINT_DEBUG('After assigninig Place of origin',9);
                 END IF;
              ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'BEST_BY_DATE' THEN
                 l_wms_named_attributes.best_by_date := NVL(l_wms_named_attributes.best_by_date,l_wms_named_attr.BEST_BY_DATE);
              ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'LENGTH' THEN
                 l_wms_named_attributes.length := nvl(l_wms_named_attributes.length,l_wms_named_attr.LENGTH);
              ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'RECYCLED_CONTENT' THEN
                 l_wms_named_attributes.recycled_content := NVL(l_wms_named_attributes.recycled_content,l_wms_named_attr.RECYCLED_CONTENT);
              ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'THICKNESS' THEN
                 l_wms_named_attributes.thickness := NVL(l_wms_named_attributes.thickness,l_wms_named_attr.THICKNESS);
              ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'THICKNESS_UOM' THEN
                 l_wms_named_attributes.thickness_uom := NVL(l_wms_named_attributes.thickness_uom,l_wms_named_attr.THICKNESS_UOM);
              ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'WIDTH' THEN
                 l_wms_named_attributes.width := NVL(l_wms_named_attributes.width,l_wms_named_attr.WIDTH);
              ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'WIDTH_UOM' THEN
                 l_wms_named_attributes.width_uom := NVL(l_wms_named_attributes.width_uom,l_wms_named_attr.WIDTH_UOM);
              ELSIF l_segments_dr.application_column_name(wms_context_index) = 'TERRITORY_CODE' THEN
                 IF G_DEBUG =1 THEN
                    PRINT_DEBUG('After  Territory code '||l_wms_named_attributes.territory_code,9);
                    PRINT_DEBUG('l_wms_named_attr Territory code '||l_wms_named_attr.TERRITORY_CODE,9);
                 END IF;
                 l_wms_named_attributes.territory_code := NVL(l_wms_named_attributes.territory_code,l_wms_named_attr.TERRITORY_CODE);
              ELSIF l_segments_dr.application_column_name(wms_context_index) = 'SUPPLIER_LOT_NUMBER' THEN
                 l_wms_named_attributes.supplier_lot_number := NVL(l_wms_named_attributes.supplier_lot_number,l_wms_named_attr.SUPPLIER_LOT_NUMBER);
              ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'VENDOR_NAME' THEN
                 l_wms_named_attributes.VENDOR_NAME := NVL(l_wms_named_attributes.VENDOR_NAME,l_wms_named_attr.VENDOR_NAME);
              END IF; /*SUBSTR(l_segments_dr.application_column_name(wms_context_index), 1, 1) = 'C' */
            END IF;
          --wms_context_index :=l_segments_dr.next(wms_context_index);
          END LOOP;
        END IF;  /*l_context IS NOT NULL  */
    IF g_debug = 1 THEN
           print_debug('Successfully Validated the  Segments for passed  WMS context ....' , 9);
      END IF;
      END IF;  /* P_SOURCE NOT IN (OSFM_FORM) */

      IF g_debug = 1 THEN
           print_debug('Preparing input Table for validation ....' , 9);
      END IF;

      IF (p_lot_rec.c_attribute1 = g_miss_char) THEN
         l_res_c_attributes_tbl(1)  := NULL;
         l_c_attributes_tbl(1)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(1)  := p_lot_rec.c_attribute1;
         l_c_attributes_tbl(1)      := p_lot_rec.c_attribute1;
      END IF;
      IF (p_lot_rec.c_attribute2 = g_miss_char) THEN
         l_res_c_attributes_tbl(2)  := NULL;
         l_c_attributes_tbl(2)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(2)  := p_lot_rec.c_attribute2;
         l_c_attributes_tbl(2)      := p_lot_rec.c_attribute2;
      END IF;
      IF (p_lot_rec.c_attribute3 = g_miss_char) THEN
         l_res_c_attributes_tbl(3)  := NULL;
         l_c_attributes_tbl(3)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(3)  := p_lot_rec.c_attribute3;
         l_c_attributes_tbl(3)      := p_lot_rec.c_attribute3;
      END IF;
      IF (p_lot_rec.c_attribute4 = g_miss_char) THEN
         l_res_c_attributes_tbl(4)  := NULL;
         l_c_attributes_tbl(4)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(4)  := p_lot_rec.c_attribute4;
         l_c_attributes_tbl(4)      := p_lot_rec.c_attribute4;
      END IF;
      IF (p_lot_rec.c_attribute5 = g_miss_char) THEN
         l_res_c_attributes_tbl(5)  := NULL;
         l_c_attributes_tbl(5)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(5)  := p_lot_rec.c_attribute5;
         l_c_attributes_tbl(5)      := p_lot_rec.c_attribute5;
      END IF;
      IF (p_lot_rec.c_attribute6 = g_miss_char) THEN
         l_res_c_attributes_tbl(6)  := NULL;
         l_c_attributes_tbl(6)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(6)  := p_lot_rec.c_attribute6;
         l_c_attributes_tbl(6)      := p_lot_rec.c_attribute6;
      END IF;
      IF (p_lot_rec.c_attribute7 = g_miss_char) THEN
         l_res_c_attributes_tbl(7)  := NULL;
         l_c_attributes_tbl(7)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(7)  := p_lot_rec.c_attribute7;
         l_c_attributes_tbl(7)      := p_lot_rec.c_attribute7;
      END IF;
      IF (p_lot_rec.c_attribute8 = g_miss_char) THEN
         l_res_c_attributes_tbl(8)  := NULL;
         l_c_attributes_tbl(8)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(8)  := p_lot_rec.c_attribute8;
         l_c_attributes_tbl(8)      := p_lot_rec.c_attribute8;
      END IF;
      IF (p_lot_rec.c_attribute9 = g_miss_char) THEN
         l_res_c_attributes_tbl(9)  := NULL;
         l_c_attributes_tbl(9)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(9)  := p_lot_rec.c_attribute9;
         l_c_attributes_tbl(9)      := p_lot_rec.c_attribute9;
      END IF;
      IF (p_lot_rec.c_attribute10 = g_miss_char) THEN
         l_res_c_attributes_tbl(10)  := NULL;
         l_c_attributes_tbl(10)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(10)  := p_lot_rec.c_attribute10;
         l_c_attributes_tbl(10)      := p_lot_rec.c_attribute10;
      END IF;
      IF (p_lot_rec.c_attribute11 = g_miss_char) THEN
         l_res_c_attributes_tbl(11)  := NULL;
         l_c_attributes_tbl(11)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(11)  := p_lot_rec.c_attribute11;
         l_c_attributes_tbl(11)      := p_lot_rec.c_attribute11;
      END IF;
      IF (p_lot_rec.c_attribute12 = g_miss_char) THEN
         l_res_c_attributes_tbl(12)  := NULL;
         l_c_attributes_tbl(12)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(12)  := p_lot_rec.c_attribute12;
         l_c_attributes_tbl(12)      := p_lot_rec.c_attribute12;
      END IF;
      IF (p_lot_rec.c_attribute13 = g_miss_char) THEN
         l_res_c_attributes_tbl(13)  := NULL;
         l_c_attributes_tbl(13)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(13)  := p_lot_rec.c_attribute13;
         l_c_attributes_tbl(13)      := p_lot_rec.c_attribute13;
      END IF;
      IF (p_lot_rec.c_attribute14 = g_miss_char) THEN
         l_res_c_attributes_tbl(14)  := NULL;
         l_c_attributes_tbl(14)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(14)  := p_lot_rec.c_attribute14;
         l_c_attributes_tbl(14)      := p_lot_rec.c_attribute14;
      END IF;
      IF (p_lot_rec.c_attribute15 = g_miss_char) THEN
         l_res_c_attributes_tbl(15)  := NULL;
         l_c_attributes_tbl(15)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(15)  := p_lot_rec.c_attribute15;
         l_c_attributes_tbl(15)      := p_lot_rec.c_attribute15;
      END IF;
      IF (p_lot_rec.c_attribute16 = g_miss_char) THEN
         l_res_c_attributes_tbl(16)  := NULL;
         l_c_attributes_tbl(16)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(16)  := p_lot_rec.c_attribute16;
         l_c_attributes_tbl(16)      := p_lot_rec.c_attribute16;
      END IF;
      IF (p_lot_rec.c_attribute17 = g_miss_char) THEN
         l_res_c_attributes_tbl(17)  := NULL;
         l_c_attributes_tbl(17)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(17)  := p_lot_rec.c_attribute17;
         l_c_attributes_tbl(17)      := p_lot_rec.c_attribute17;
      END IF;
      IF (p_lot_rec.c_attribute18 = g_miss_char) THEN
         l_res_c_attributes_tbl(18)  := NULL;
         l_c_attributes_tbl(18)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(18)  := p_lot_rec.c_attribute18;
         l_c_attributes_tbl(18)      := p_lot_rec.c_attribute18;
      END IF;
      IF (p_lot_rec.c_attribute19 = g_miss_char) THEN
         l_res_c_attributes_tbl(19)  := NULL;
         l_c_attributes_tbl(19)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(19)  := p_lot_rec.c_attribute19;
         l_c_attributes_tbl(19)      := p_lot_rec.c_attribute19;
      END IF;
      IF (p_lot_rec.c_attribute20 = g_miss_char) THEN
         l_res_c_attributes_tbl(20)  := NULL;
         l_c_attributes_tbl(20)      := g_miss_char;
      ELSE
         l_res_c_attributes_tbl(20)  := p_lot_rec.c_attribute20;
         l_c_attributes_tbl(20)      := p_lot_rec.c_attribute20;
      END IF;

      IF g_debug = 1 THEN
        print_debug('Upd Lot Attr: After preparing the C_ATTRIBUTES table ', 9);
      END IF;

      IF (p_lot_rec.n_attribute1 = g_miss_num) THEN
         l_res_n_attributes_tbl(1)  := NULL;
         l_n_attributes_tbl(1)      := g_miss_num;
      ELSE
         l_res_n_attributes_tbl(1)  := p_lot_rec.n_attribute1;
         l_n_attributes_tbl(1)      := p_lot_rec.n_attribute1;
      END IF;
      IF (p_lot_rec.n_attribute2 = g_miss_num) THEN
         l_res_n_attributes_tbl(2)  := NULL;
         l_n_attributes_tbl(2)      := g_miss_num;
      ELSE
         l_res_n_attributes_tbl(2)  := p_lot_rec.n_attribute2;
         l_n_attributes_tbl(2)      := p_lot_rec.n_attribute2;
      END IF;
      IF (p_lot_rec.n_attribute3 = g_miss_num) THEN
         l_res_n_attributes_tbl(3)  := NULL;
         l_n_attributes_tbl(3)      := g_miss_num;
      ELSE
         l_res_n_attributes_tbl(3)  := p_lot_rec.n_attribute3;
         l_n_attributes_tbl(3)      := p_lot_rec.n_attribute3;
      END IF;
      IF (p_lot_rec.n_attribute4 = g_miss_num) THEN
         l_res_n_attributes_tbl(4)  := NULL;
         l_n_attributes_tbl(4)      := g_miss_num;
      ELSE
         l_res_n_attributes_tbl(4)  := p_lot_rec.n_attribute4;
         l_n_attributes_tbl(4)      := p_lot_rec.n_attribute4;
      END IF;
      IF (p_lot_rec.n_attribute5 = g_miss_num) THEN
         l_res_n_attributes_tbl(5)  := NULL;
         l_n_attributes_tbl(5)      := g_miss_num;
      ELSE
         l_res_n_attributes_tbl(5)  := p_lot_rec.n_attribute5;
         l_n_attributes_tbl(5)      := p_lot_rec.n_attribute5;
      END IF;
      IF (p_lot_rec.n_attribute6 = g_miss_num) THEN
         l_res_n_attributes_tbl(6)  := NULL;
         l_n_attributes_tbl(6)      := g_miss_num;
      ELSE
         l_res_n_attributes_tbl(6)  := p_lot_rec.n_attribute6;
         l_n_attributes_tbl(6)      := p_lot_rec.n_attribute6;
      END IF;
      IF (p_lot_rec.n_attribute7 = g_miss_num) THEN
         l_res_n_attributes_tbl(7)  := NULL;
         l_n_attributes_tbl(7)      := g_miss_num;
      ELSE
         l_res_n_attributes_tbl(7)  := p_lot_rec.n_attribute7;
         l_n_attributes_tbl(7)      := p_lot_rec.n_attribute7;
      END IF;
      IF (p_lot_rec.n_attribute8 = g_miss_num) THEN
         l_res_n_attributes_tbl(8)  := NULL;
         l_n_attributes_tbl(8)      := g_miss_num;
      ELSE
         l_res_n_attributes_tbl(8)  := p_lot_rec.n_attribute8;
         l_n_attributes_tbl(8)      := p_lot_rec.n_attribute8;
      END IF;
      IF (p_lot_rec.n_attribute9 = g_miss_num) THEN
         l_res_n_attributes_tbl(9)  := NULL;
         l_n_attributes_tbl(9)      := g_miss_num;
      ELSE
         l_res_n_attributes_tbl(9)  := p_lot_rec.n_attribute9;
         l_n_attributes_tbl(9)      := p_lot_rec.n_attribute9;
      END IF;
      IF (p_lot_rec.n_attribute10 = g_miss_num) THEN
         l_res_n_attributes_tbl(10)  := NULL;
         l_n_attributes_tbl(10)      := g_miss_num;
      ELSE
         l_res_n_attributes_tbl(10)  := p_lot_rec.n_attribute10;
         l_n_attributes_tbl(10)      := p_lot_rec.n_attribute10;
      END IF;

      IF g_debug = 1 THEN
        print_debug('Upd Lot Attr: After preparing the N_ATTRIBUTES table ', 9);
      END IF;

      IF (p_lot_rec.d_attribute1 = g_miss_date) THEN
         l_res_d_attributes_tbl(1)  := NULL;
         l_d_attributes_tbl(1)      := g_miss_date;
      ELSE
         l_res_d_attributes_tbl(1)  := p_lot_rec.d_attribute1;
         l_d_attributes_tbl(1)      := p_lot_rec.d_attribute1;
      END IF;
      IF (p_lot_rec.d_attribute2 = g_miss_date) THEN
         l_res_d_attributes_tbl(2)  := NULL;
         l_d_attributes_tbl(2)      := g_miss_date;
      ELSE
         l_res_d_attributes_tbl(2)  := p_lot_rec.d_attribute2;
         l_d_attributes_tbl(2)      := p_lot_rec.d_attribute2;
      END IF;
      IF (p_lot_rec.d_attribute3 = g_miss_date) THEN
         l_res_d_attributes_tbl(3)  := NULL;
         l_d_attributes_tbl(3)      := g_miss_date;
      ELSE
         l_res_d_attributes_tbl(3)  := p_lot_rec.d_attribute3;
         l_d_attributes_tbl(3)      := p_lot_rec.d_attribute3;
      END IF;
      IF (p_lot_rec.d_attribute4 = g_miss_date) THEN
         l_res_d_attributes_tbl(4)  := NULL;
         l_d_attributes_tbl(4)      := g_miss_date;
      ELSE
         l_res_d_attributes_tbl(4)  := p_lot_rec.d_attribute4;
         l_d_attributes_tbl(4)      := p_lot_rec.d_attribute4;
      END IF;
      IF (p_lot_rec.d_attribute5 = g_miss_date) THEN
         l_res_d_attributes_tbl(5)  := NULL;
         l_d_attributes_tbl(5)      := g_miss_date;
      ELSE
         l_res_d_attributes_tbl(5)  := p_lot_rec.d_attribute5;
         l_d_attributes_tbl(5)      := p_lot_rec.d_attribute5;
      END IF;
      IF (p_lot_rec.d_attribute6 = g_miss_date) THEN
         l_res_d_attributes_tbl(6)  := NULL;
         l_d_attributes_tbl(6)      := g_miss_date;
      ELSE
         l_res_d_attributes_tbl(6)  := p_lot_rec.d_attribute6;
         l_d_attributes_tbl(6)      := p_lot_rec.d_attribute6;
      END IF;
      IF (p_lot_rec.d_attribute7 = g_miss_date) THEN
         l_res_d_attributes_tbl(7)  := NULL;
         l_d_attributes_tbl(7)      := g_miss_date;
      ELSE
         l_res_d_attributes_tbl(7)  := p_lot_rec.d_attribute7;
         l_d_attributes_tbl(7)      := p_lot_rec.d_attribute7;
      END IF;
      IF (p_lot_rec.d_attribute8 = g_miss_date) THEN
         l_res_d_attributes_tbl(8)  := NULL;
         l_d_attributes_tbl(8)      := g_miss_date;
      ELSE
         l_res_d_attributes_tbl(8)  := p_lot_rec.d_attribute8;
         l_d_attributes_tbl(8)      := p_lot_rec.d_attribute8;
      END IF;
      IF (p_lot_rec.d_attribute9 = g_miss_date) THEN
         l_res_d_attributes_tbl(9)  := NULL;
         l_d_attributes_tbl(9)      := g_miss_date;
      ELSE
         l_res_d_attributes_tbl(9)  := p_lot_rec.d_attribute9;
         l_d_attributes_tbl(9)      := p_lot_rec.d_attribute9;
      END IF;
      IF (p_lot_rec.d_attribute10 = g_miss_date) THEN
         l_res_d_attributes_tbl(10)  := NULL;
         l_d_attributes_tbl(10)      := g_miss_date;
      ELSE
         l_res_d_attributes_tbl(10)  := p_lot_rec.d_attribute10;
         l_d_attributes_tbl(10)      := p_lot_rec.d_attribute10;
      END IF;

      IF g_debug = 1 THEN
        print_debug('Upd Lot Attr: After preparing the D_ATTRIBUTES table ', 9);
      END IF;
    END IF;  /* end if for Wms is installed */

    IF g_debug = 1 THEN
           print_debug(' Before the call to The procedure  validate_lot_attr_in_param ....' , 9);
    END IF;

    validate_lot_attr_in_param(
      x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_inventory_item_id          => p_lot_rec.inventory_item_id
    , p_organization_id            => p_lot_rec.organization_id
    , p_lot_number                 => p_lot_rec.lot_number
    , p_attribute_category         => p_lot_rec.attribute_category
    , p_lot_attribute_category     => p_lot_rec.lot_attribute_category
    , p_attributes_tbl             => l_res_inv_attributes_tbl
    , p_c_attributes_tbl           => l_res_c_attributes_tbl
    , p_n_attributes_tbl           => l_res_n_attributes_tbl
    , p_d_attributes_tbl           => l_res_d_attributes_tbl
    , p_wms_is_installed           => l_wms_installed
    , p_source                     => p_source
    , p_disable_flag               => l_wms_named_attributes.disable_flag
    , p_grade_code                 => l_wms_named_attributes.grade_code
    , p_origination_date           => l_wms_named_attributes.origination_date
    , p_date_code                  => l_wms_named_attributes.date_code
    , p_change_date                => l_wms_named_attributes.change_date
    , p_age                        => l_wms_named_attributes.age
    , p_retest_date                => l_wms_named_attributes.retest_date
    , p_maturity_date              => l_wms_named_attributes.maturity_date
    , p_item_size                  => l_wms_named_attributes.item_size
    , p_color                      => l_wms_named_attributes.color
    , p_volume                     => l_wms_named_attributes.volume
    , p_volume_uom                 => l_wms_named_attributes.volume_uom
    , p_place_of_origin            => l_wms_named_attributes.place_of_origin
    , p_best_by_date               => l_wms_named_attributes.best_by_date
    , p_length                     => l_wms_named_attributes.length
    , p_length_uom                 => l_wms_named_attributes.length_uom
    , p_recycled_content           => l_wms_named_attributes.recycled_content
    , p_thickness                  => l_wms_named_attributes.thickness
    , p_thickness_uom              => l_wms_named_attributes.thickness_uom
    , p_width                      => l_wms_named_attributes.width
    , p_width_uom                  => l_wms_named_attributes.width_uom
    , p_territory_code             => l_wms_named_attributes.territory_code
    , p_supplier_lot_number        => l_wms_named_attributes.supplier_lot_number
    , p_vendor_name                => l_wms_named_attributes.vendor_name
    );

    IF l_return_status = g_ret_sts_error THEN
      IF g_debug = 1 THEN
        print_debug('Update Lot Attr: Program validate_lot_attr_in_param has failed with a user defined exception', 9);
      END IF;

      RAISE g_exc_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      IF g_debug = 1 THEN
        print_debug('Update Lot Attr: Program validate_lot_attr_in_param has failed with a Unexpected exception', 9);
      END IF;

      RAISE g_exc_unexpected_error;
    END IF;

    IF g_debug = 1 THEN
      print_debug('Upd Lot Attr: Call to validate_lot_attr_in_param is success ', 9);
    END IF;
    IF g_debug = 1 THEN
         print_debug('Updating  MTL_LOT_NUMBERS table  ....' , 9);
    END IF;
    inv_log_util.trace('l_expiration_date is:'||l_expiration_date, 'INV_LOT_API_PUB','9');  --For bug 4888300

--Fixed for bug#7529468
--added two column in update statement
--LAST_UPDATE_DATE and  LAST_UPDATED_BY
--Fix for bug#7930079
--In decode function for date columns - NULL is changed as to_date(NULL)
    IF l_wms_installed = 'TRUE' THEN
      UPDATE mtl_lot_numbers
         SET expiration_date =
               DECODE(l_expiration_date, NULL, expiration_date, l_expiration_date )
           , disable_flag =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.disable_flag, g_miss_char, NULL, NULL, disable_flag, p_lot_rec.disable_flag)
               , DECODE(p_lot_rec.disable_flag, g_miss_char, disable_flag, NULL, NULL, p_lot_rec.disable_flag)
               )
           , attribute_category =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.attribute_category, g_miss_char, NULL, NULL, attribute_category, p_lot_rec.attribute_category)
               , DECODE(p_lot_rec.attribute_category, g_miss_char, attribute_category, NULL, NULL, p_lot_rec.attribute_category)
               )
           , lot_attribute_category =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.lot_attribute_category, g_miss_char, NULL, NULL, lot_attribute_category, p_lot_rec.lot_attribute_category)
               , DECODE(p_lot_rec.lot_attribute_category, g_miss_char, lot_attribute_category, NULL, NULL, p_lot_rec.lot_attribute_category)
               )
           , grade_code =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.grade_code, g_miss_char, NULL, NULL, grade_code, p_lot_rec.grade_code)
               , DECODE(p_lot_rec.grade_code, g_miss_char, grade_code, NULL, NULL, p_lot_rec.grade_code)
               )
           , origination_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.origination_date, g_miss_date,To_Date(NULL), NULL, origination_date, p_lot_rec.origination_date)
               , DECODE(p_lot_rec.origination_date, g_miss_date, origination_date, NULL, To_Date(NULL), p_lot_rec.origination_date)
               )
           , date_code =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.date_code, g_miss_char, NULL, NULL, date_code, p_lot_rec.date_code)
               , DECODE(p_lot_rec.date_code, g_miss_char, date_code, NULL, NULL, p_lot_rec.date_code)
               )
	   /* Bug 8198497- Removed the code as we are updating the status by calling validate_lot_status */
           , change_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.change_date, g_miss_date, To_Date(NULL), NULL, change_date, p_lot_rec.change_date)
               , DECODE(p_lot_rec.change_date, g_miss_date, change_date, NULL, To_Date(NULL), p_lot_rec.change_date)
               )
           , age = DECODE(
                    p_source
                  , 2, DECODE(p_lot_rec.age, g_miss_num, NULL, NULL, age, p_lot_rec.age)
                  , DECODE(p_lot_rec.age, g_miss_num, age, NULL, NULL, p_lot_rec.age)
                  )
           , retest_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.retest_date, g_miss_date, To_Date(NULL), NULL, retest_date, p_lot_rec.retest_date)
               , DECODE(p_lot_rec.retest_date, g_miss_date, retest_date, NULL, To_Date(NULL), p_lot_rec.retest_date)
               )
           , maturity_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.maturity_date, g_miss_date, To_Date(NULL), NULL, maturity_date, p_lot_rec.maturity_date)
               , DECODE(p_lot_rec.maturity_date, g_miss_date, maturity_date, NULL, To_Date(NULL), p_lot_rec.maturity_date)
               )
           , item_size =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.item_size, g_miss_num, NULL, NULL, item_size, p_lot_rec.item_size)
               , DECODE(p_lot_rec.item_size, g_miss_num, item_size, NULL, NULL, p_lot_rec.item_size)
               )
           , color =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.color, g_miss_char, NULL, NULL, color, p_lot_rec.color)
               , DECODE(p_lot_rec.color, g_miss_char, color, NULL, NULL, p_lot_rec.color)
               )
           , volume =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.volume, g_miss_num, NULL, NULL, volume, p_lot_rec.volume)
               , DECODE(p_lot_rec.volume, g_miss_num, volume, NULL, NULL, p_lot_rec.volume)
               )
           , volume_uom =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.volume_uom, g_miss_char, NULL, NULL, volume_uom, p_lot_rec.volume_uom)
               , DECODE(p_lot_rec.volume_uom, g_miss_char, volume_uom, NULL, NULL, p_lot_rec.volume_uom)
               )
           , place_of_origin =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.place_of_origin, g_miss_char, NULL, NULL, place_of_origin, p_lot_rec.place_of_origin)
               , DECODE(p_lot_rec.place_of_origin, g_miss_char, place_of_origin, NULL, place_of_origin, p_lot_rec.place_of_origin)
               )
           , best_by_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.best_by_date, g_miss_date, To_Date(NULL), NULL, best_by_date, p_lot_rec.best_by_date)
               , DECODE(p_lot_rec.best_by_date, g_miss_date, best_by_date, NULL, To_Date(NULL), p_lot_rec.best_by_date)
               )
           , LENGTH =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.length, g_miss_num, NULL, NULL, LENGTH, p_lot_rec.length)
               , DECODE(p_lot_rec.length, g_miss_num, LENGTH, NULL, NULL, p_lot_rec.length)
               )
           , length_uom =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.length_uom, g_miss_char, NULL, NULL, length_uom, p_lot_rec.length_uom)
               , DECODE(p_lot_rec.length_uom, g_miss_char, length_uom, NULL, NULL, p_lot_rec.length_uom)
               )
           , recycled_content =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.recycled_content, g_miss_num, NULL, NULL, recycled_content, p_lot_rec.recycled_content)
               , DECODE(p_lot_rec.recycled_content, g_miss_num, recycled_content, NULL, NULL, p_lot_rec.recycled_content)
               )
           , thickness =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.thickness, g_miss_num, NULL, NULL, thickness, p_lot_rec.thickness)
               , DECODE(p_lot_rec.thickness, g_miss_num, thickness, NULL, NULL, p_lot_rec.thickness)
               )
           , thickness_uom =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.thickness_uom, g_miss_char, NULL, NULL, thickness_uom, p_lot_rec.thickness_uom)
               , DECODE(p_lot_rec.thickness_uom, g_miss_char, thickness_uom, NULL, NULL, p_lot_rec.thickness_uom)
               )
           , width =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.width, g_miss_num, NULL, NULL, width, p_lot_rec.width)
               , DECODE(p_lot_rec.width, g_miss_num, width, NULL, NULL, p_lot_rec.width)
               )
           , width_uom =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.width_uom, g_miss_char, NULL, NULL, width_uom, p_lot_rec.width_uom)
               , DECODE(p_lot_rec.width_uom, g_miss_char, width_uom, NULL, NULL, p_lot_rec.width_uom)
               )
           , territory_code =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.territory_code, g_miss_char, NULL, NULL, territory_code, p_lot_rec.territory_code)
               , DECODE(p_lot_rec.territory_code, g_miss_char, territory_code, NULL, NULL, p_lot_rec.territory_code)
               )
           , supplier_lot_number =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.supplier_lot_number, g_miss_char, NULL, NULL, supplier_lot_number, p_lot_rec.supplier_lot_number)
               , DECODE(p_lot_rec.supplier_lot_number, g_miss_char, supplier_lot_number, NULL, NULL, p_lot_rec.supplier_lot_number)
               )
           , vendor_name =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.vendor_name, g_miss_char, NULL, NULL, vendor_name, p_lot_rec.vendor_name)
               , DECODE(p_lot_rec.vendor_name, g_miss_char, vendor_name, NULL, NULL, p_lot_rec.vendor_name)
               )
           -- Bug 6983527 - Parent lot number should never be updated.
           /*Bug 8311729 Uncommenting the below code as we should be able to
update the mistakenly entered parent lot information */
	   -- nsinghi bug#5209065. Update new lot attributes
           , parent_lot_number =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.parent_lot_number, g_miss_char, NULL, NULL, parent_lot_number, p_lot_rec.parent_lot_number)
               , DECODE(p_lot_rec.parent_lot_number, g_miss_char, parent_lot_number, NULL, NULL, p_lot_rec.parent_lot_number)
               )
           , origination_type =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.origination_type, g_miss_num, NULL, NULL, origination_type, p_lot_rec.origination_type)
               , DECODE(p_lot_rec.origination_type, g_miss_num, origination_type, NULL, NULL, p_lot_rec.origination_type)
               )
           , availability_type =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.availability_type, g_miss_num, NULL, NULL, availability_type, p_lot_rec.availability_type)
               , DECODE(p_lot_rec.availability_type, g_miss_num, availability_type, NULL, NULL, p_lot_rec.availability_type)
               )
           , expiration_action_code =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.expiration_action_code, g_miss_char, NULL, NULL, expiration_action_code, p_lot_rec.expiration_action_code)
               , DECODE(p_lot_rec.expiration_action_code, g_miss_char, expiration_action_code, NULL, NULL, p_lot_rec.expiration_action_code)
               )
           , expiration_action_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.expiration_action_date, g_miss_date, To_Date(NULL), NULL, expiration_action_date, p_lot_rec.expiration_action_date)
               , DECODE(p_lot_rec.expiration_action_date, g_miss_date, expiration_action_date, NULL, To_Date(NULL), p_lot_rec.expiration_action_date)
               )
           , hold_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.hold_date, g_miss_date, To_Date(NULL), NULL, hold_date, p_lot_rec.hold_date)
               , DECODE(p_lot_rec.hold_date, g_miss_date, hold_date, NULL, To_Date(NULL), p_lot_rec.hold_date)
               )
           , inventory_atp_code =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.inventory_atp_code, g_miss_num, NULL, NULL, inventory_atp_code, p_lot_rec.inventory_atp_code)
               , DECODE(p_lot_rec.inventory_atp_code, g_miss_num, inventory_atp_code, NULL, NULL, p_lot_rec.inventory_atp_code)
               )
           , reservable_type =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.reservable_type, g_miss_num, NULL, NULL, reservable_type, p_lot_rec.reservable_type)
               , DECODE(p_lot_rec.reservable_type, g_miss_num, reservable_type, NULL, NULL, p_lot_rec.reservable_type)
               )
           , sampling_event_id =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.sampling_event_id, g_miss_num, NULL, NULL, sampling_event_id, p_lot_rec.sampling_event_id)
               , DECODE(p_lot_rec.sampling_event_id, g_miss_num, sampling_event_id, NULL, NULL, p_lot_rec.sampling_event_id)
               )
	   -- nsinghi bug#5209065. End.
           , attribute1 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(1), g_miss_char, NULL, NULL, attribute1, l_inv_attributes_tbl(1))
               , DECODE(l_inv_attributes_tbl(1), g_miss_char, attribute1, NULL, NULL, l_inv_attributes_tbl(1))
               )
           , attribute2 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(2), g_miss_char, NULL, NULL, attribute2, l_inv_attributes_tbl(2))
               , DECODE(l_inv_attributes_tbl(2), g_miss_char, attribute2, NULL, NULL, l_inv_attributes_tbl(2))
               )
           , attribute3 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(3), g_miss_char, NULL, NULL, attribute3, l_inv_attributes_tbl(3))
               , DECODE(l_inv_attributes_tbl(3), g_miss_char, attribute3, NULL, NULL, l_inv_attributes_tbl(3))
               )
           , attribute4 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(4), g_miss_char, NULL, NULL, attribute4, l_inv_attributes_tbl(4))
               , DECODE(l_inv_attributes_tbl(4), g_miss_char, attribute4, NULL, NULL, l_inv_attributes_tbl(4))
               )
           , attribute5 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(5), g_miss_char, NULL, NULL, attribute5, l_inv_attributes_tbl(5))
               , DECODE(l_inv_attributes_tbl(5), g_miss_char, attribute5, NULL, NULL, l_inv_attributes_tbl(5))
               )
           , attribute6 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(6), g_miss_char, NULL, NULL, attribute6, l_inv_attributes_tbl(6))
               , DECODE(l_inv_attributes_tbl(6), g_miss_char, attribute6, NULL, NULL, l_inv_attributes_tbl(6))
               )
           , attribute7 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(7), g_miss_char, NULL, NULL, attribute7, l_inv_attributes_tbl(7))
               , DECODE(l_inv_attributes_tbl(7), g_miss_char, attribute7, NULL, NULL, l_inv_attributes_tbl(7))
               )
           , attribute8 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(8), g_miss_char, NULL, NULL, attribute8, l_inv_attributes_tbl(8))
               , DECODE(l_inv_attributes_tbl(8), g_miss_char, attribute8, NULL, NULL, l_inv_attributes_tbl(8))
               )
           , attribute9 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(9), g_miss_char, NULL, NULL, attribute9, l_inv_attributes_tbl(9))
               , DECODE(l_inv_attributes_tbl(9), g_miss_char, attribute9, NULL, NULL, l_inv_attributes_tbl(9))
               )
           , attribute10 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(10), g_miss_char, NULL, NULL, attribute10, l_inv_attributes_tbl(10))
               , DECODE(l_inv_attributes_tbl(10), g_miss_char, attribute10, NULL, NULL, l_inv_attributes_tbl(10))
               )
           , attribute11 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(11), g_miss_char, NULL, NULL, attribute11, l_inv_attributes_tbl(11))
               , DECODE(l_inv_attributes_tbl(11), g_miss_char, attribute11, NULL, NULL, l_inv_attributes_tbl(11))
               )
           , attribute12 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(12), g_miss_char, NULL, NULL, attribute12, l_inv_attributes_tbl(12))
               , DECODE(l_inv_attributes_tbl(12), g_miss_char, attribute12, NULL, NULL, l_inv_attributes_tbl(12))
               )
           , attribute13 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(13), g_miss_char, NULL, NULL, attribute13, l_inv_attributes_tbl(13))
               , DECODE(l_inv_attributes_tbl(13), g_miss_char, attribute13, NULL, NULL, l_inv_attributes_tbl(13))
               )
           , attribute14 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(14), g_miss_char, NULL, NULL, attribute14, l_inv_attributes_tbl(14))
               , DECODE(l_inv_attributes_tbl(14), g_miss_char, attribute14, NULL, NULL, l_inv_attributes_tbl(14))
               )
           , attribute15 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(15), g_miss_char, NULL, NULL, attribute15, l_inv_attributes_tbl(15))
               , DECODE(l_inv_attributes_tbl(15), g_miss_char, attribute15, NULL, NULL, l_inv_attributes_tbl(15))
               )
           , c_attribute1 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(1), g_miss_char, NULL, NULL, c_attribute1, l_c_attributes_tbl(1))
               , DECODE(l_c_attributes_tbl(1), g_miss_char, c_attribute1, NULL, NULL, l_c_attributes_tbl(1))
               )
           , c_attribute2 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(2), g_miss_char, NULL, NULL, c_attribute2, l_c_attributes_tbl(2))
               , DECODE(l_c_attributes_tbl(2), g_miss_char, c_attribute2, NULL, NULL, l_c_attributes_tbl(2))
               )
           , c_attribute3 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(3), g_miss_char, NULL, NULL, c_attribute3, l_c_attributes_tbl(3))
               , DECODE(l_c_attributes_tbl(3), g_miss_char, c_attribute3, NULL, NULL, l_c_attributes_tbl(3))
               )
           , c_attribute4 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(4), g_miss_char, NULL, NULL, c_attribute4, l_c_attributes_tbl(4))
               , DECODE(l_c_attributes_tbl(4), g_miss_char, c_attribute4, NULL, NULL, l_c_attributes_tbl(4))
               )
           , c_attribute5 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(5), g_miss_char, NULL, NULL, c_attribute5, l_c_attributes_tbl(5))
               , DECODE(l_c_attributes_tbl(5), g_miss_char, c_attribute5, NULL, NULL, l_c_attributes_tbl(5))
               )
           , c_attribute6 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(6), g_miss_char, NULL, NULL, c_attribute6, l_c_attributes_tbl(6))
               , DECODE(l_c_attributes_tbl(6), g_miss_char, c_attribute6, NULL, NULL, l_c_attributes_tbl(6))
               )
           , c_attribute7 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(7), g_miss_char, NULL, NULL, c_attribute7, l_c_attributes_tbl(7))
               , DECODE(l_c_attributes_tbl(7), g_miss_char, c_attribute7, NULL, NULL, l_c_attributes_tbl(7))
               )
           , c_attribute8 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(8), g_miss_char, NULL, NULL, c_attribute8, l_c_attributes_tbl(8))
               , DECODE(l_c_attributes_tbl(8), g_miss_char, c_attribute8, NULL, NULL, l_c_attributes_tbl(8))
               )
           , c_attribute9 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(9), g_miss_char, NULL, NULL, c_attribute9, l_c_attributes_tbl(9))
               , DECODE(l_c_attributes_tbl(9), g_miss_char, c_attribute9, NULL, NULL, l_c_attributes_tbl(9))
               )
           , c_attribute10 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(10), g_miss_char, NULL, NULL, c_attribute10, l_c_attributes_tbl(10))
               , DECODE(l_c_attributes_tbl(10), g_miss_char, c_attribute10, NULL, NULL, l_c_attributes_tbl(10))
               )
           , c_attribute11 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(11), g_miss_char, NULL, NULL, c_attribute11, l_c_attributes_tbl(11))
               , DECODE(l_c_attributes_tbl(11), g_miss_char, c_attribute11, NULL, NULL, l_c_attributes_tbl(11))
               )
           , c_attribute12 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(12), g_miss_char, NULL, NULL, c_attribute12, l_c_attributes_tbl(12))
               , DECODE(l_c_attributes_tbl(12), g_miss_char, c_attribute12, NULL, NULL, l_c_attributes_tbl(12))
               )
           , c_attribute13 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(13), g_miss_char, NULL, NULL, c_attribute13, l_c_attributes_tbl(13))
               , DECODE(l_c_attributes_tbl(13), g_miss_char, c_attribute13, NULL, NULL, l_c_attributes_tbl(13))
               )
           , c_attribute14 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(14), g_miss_char, NULL, NULL, c_attribute14, l_c_attributes_tbl(14))
               , DECODE(l_c_attributes_tbl(14), g_miss_char, c_attribute14, NULL, NULL, l_c_attributes_tbl(14))
               )
           , c_attribute15 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(15), g_miss_char, NULL, NULL, c_attribute15, l_c_attributes_tbl(15))
               , DECODE(l_c_attributes_tbl(15), g_miss_char, c_attribute15, NULL, NULL, l_c_attributes_tbl(15))
               )
           , c_attribute16 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(16), g_miss_char, NULL, NULL, c_attribute16, l_c_attributes_tbl(16))
               , DECODE(l_c_attributes_tbl(16), g_miss_char, c_attribute16, NULL, NULL, l_c_attributes_tbl(16))
               )
           , c_attribute17 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(17), g_miss_char, NULL, NULL, c_attribute17, l_c_attributes_tbl(17))
               , DECODE(l_c_attributes_tbl(17), g_miss_char, c_attribute17, NULL, NULL, l_c_attributes_tbl(17))
               )
           , c_attribute18 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(18), g_miss_char, NULL, NULL, c_attribute18, l_c_attributes_tbl(18))
               , DECODE(l_c_attributes_tbl(18), g_miss_char, c_attribute18, NULL, NULL, l_c_attributes_tbl(18))
               )
           , c_attribute19 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(19), g_miss_char, NULL, NULL, c_attribute19, l_c_attributes_tbl(19))
               , DECODE(l_c_attributes_tbl(19), g_miss_char, c_attribute19, NULL, NULL, l_c_attributes_tbl(19))
               )
           , c_attribute20 =
               DECODE(
                 p_source
               , 2, DECODE(l_c_attributes_tbl(20), g_miss_char, NULL, NULL, c_attribute20, l_c_attributes_tbl(20))
               , DECODE(l_c_attributes_tbl(20), g_miss_char, c_attribute20, NULL, NULL, l_c_attributes_tbl(20))
               )
           , n_attribute1 =
               DECODE(
                 p_source
               , 2, DECODE(l_n_attributes_tbl(1), g_miss_num, NULL, NULL, n_attribute1, l_n_attributes_tbl(1))
               , DECODE(l_n_attributes_tbl(1), g_miss_num, n_attribute1, NULL, NULL, l_n_attributes_tbl(1))
               )
           , n_attribute2 =
               DECODE(
                 p_source
               , 2, DECODE(l_n_attributes_tbl(2), g_miss_num, NULL, NULL, n_attribute2, l_n_attributes_tbl(2))
               , DECODE(l_n_attributes_tbl(2), g_miss_num, n_attribute2, NULL, NULL, l_n_attributes_tbl(2))
               )
           , n_attribute3 =
               DECODE(
                 p_source
               , 2, DECODE(l_n_attributes_tbl(3), g_miss_num, NULL, NULL, n_attribute3, l_n_attributes_tbl(3))
               , DECODE(l_n_attributes_tbl(3), g_miss_num, n_attribute3, NULL, NULL, l_n_attributes_tbl(3))
               )
           , n_attribute4 =
               DECODE(
                 p_source
               , 2, DECODE(l_n_attributes_tbl(4), g_miss_num, NULL, NULL, n_attribute4, l_n_attributes_tbl(4))
               , DECODE(l_n_attributes_tbl(4), g_miss_num, n_attribute4, NULL, NULL, l_n_attributes_tbl(4))
               )
           , n_attribute5 =
               DECODE(
                 p_source
               , 2, DECODE(l_n_attributes_tbl(5), g_miss_num, NULL, NULL, n_attribute5, l_n_attributes_tbl(5))
               , DECODE(l_n_attributes_tbl(5), g_miss_num, n_attribute5, NULL, NULL, l_n_attributes_tbl(5))
               )
           , n_attribute6 =
               DECODE(
                 p_source
               , 2, DECODE(l_n_attributes_tbl(6), g_miss_num, NULL, NULL, n_attribute6, l_n_attributes_tbl(6))
               , DECODE(l_n_attributes_tbl(6), g_miss_num, n_attribute6, NULL, NULL, l_n_attributes_tbl(6))
               )
           , n_attribute7 =
               DECODE(
                 p_source
               , 2, DECODE(l_n_attributes_tbl(7), g_miss_num, NULL, NULL, n_attribute7, l_n_attributes_tbl(7))
               , DECODE(l_n_attributes_tbl(7), g_miss_num, n_attribute7, NULL, NULL, l_n_attributes_tbl(7))
               )
           , n_attribute8 =
               DECODE(
                 p_source
               , 2, DECODE(l_n_attributes_tbl(8), g_miss_num, NULL, NULL, n_attribute8, l_n_attributes_tbl(8))
               , DECODE(l_n_attributes_tbl(8), g_miss_num, n_attribute8, NULL, NULL, l_n_attributes_tbl(8))
               )
           , n_attribute9 =
               DECODE(
                 p_source
               , 2, DECODE(l_n_attributes_tbl(9), g_miss_num, NULL, NULL, n_attribute9, l_n_attributes_tbl(9))
               , DECODE(l_n_attributes_tbl(9), g_miss_num, n_attribute9, NULL, NULL, l_n_attributes_tbl(9))
               )
           , n_attribute10 =
               DECODE(
                 p_source
               , 2, DECODE(l_n_attributes_tbl(10), g_miss_num, NULL, NULL, n_attribute10, l_n_attributes_tbl(10))
               , DECODE(l_n_attributes_tbl(10), g_miss_num, n_attribute10, NULL, NULL, l_n_attributes_tbl(10))
               )
           , d_attribute1 =
               DECODE(
                 p_source
               , 2, DECODE(l_d_attributes_tbl(1), g_miss_date, NULL, NULL, d_attribute1, l_d_attributes_tbl(1))
               , DECODE(l_d_attributes_tbl(1), g_miss_date, d_attribute1, NULL, NULL, l_d_attributes_tbl(1))
               )
           , d_attribute2 =
               DECODE(
                 p_source
               , 2, DECODE(l_d_attributes_tbl(2), g_miss_date, NULL, NULL, d_attribute2, l_d_attributes_tbl(2))
               , DECODE(l_d_attributes_tbl(2), g_miss_date, d_attribute2, NULL, NULL, l_d_attributes_tbl(2))
               )
           , d_attribute3 =
               DECODE(
                 p_source
               , 2, DECODE(l_d_attributes_tbl(3), g_miss_date, NULL, NULL, d_attribute3, l_d_attributes_tbl(3))
               , DECODE(l_d_attributes_tbl(3), g_miss_date, d_attribute3, NULL, NULL, l_d_attributes_tbl(3))
               )
           , d_attribute4 =
               DECODE(
                 p_source
               , 2, DECODE(l_d_attributes_tbl(4), g_miss_date, NULL, NULL, d_attribute4, l_d_attributes_tbl(4))
               , DECODE(l_d_attributes_tbl(4), g_miss_date, d_attribute4, NULL, NULL, l_d_attributes_tbl(4))
               )
           , d_attribute5 =
               DECODE(
                 p_source
               , 2, DECODE(l_d_attributes_tbl(5), g_miss_date, NULL, NULL, d_attribute5, l_d_attributes_tbl(5))
               , DECODE(l_d_attributes_tbl(5), g_miss_date, d_attribute5, NULL, NULL, l_d_attributes_tbl(5))
               )
           , d_attribute6 =
               DECODE(
                 p_source
               , 2, DECODE(l_d_attributes_tbl(6), g_miss_date, NULL, NULL, d_attribute6, l_d_attributes_tbl(6))
               , DECODE(l_d_attributes_tbl(6), g_miss_date, d_attribute6, NULL, NULL, l_d_attributes_tbl(6))
               )
           , d_attribute7 =
               DECODE(
                 p_source
               , 2, DECODE(l_d_attributes_tbl(7), g_miss_date, NULL, NULL, d_attribute7, l_d_attributes_tbl(7))
               , DECODE(l_d_attributes_tbl(7), g_miss_date, d_attribute7, NULL, NULL, l_d_attributes_tbl(7))
               )
           , d_attribute8 =
               DECODE(
                 p_source
               , 2, DECODE(l_d_attributes_tbl(8), g_miss_date, NULL, NULL, d_attribute8, l_d_attributes_tbl(8))
               , DECODE(l_d_attributes_tbl(8), g_miss_date, d_attribute8, NULL, NULL, l_d_attributes_tbl(8))
               )
           , d_attribute9 =
               DECODE(
                 p_source
               , 2, DECODE(l_d_attributes_tbl(9), g_miss_date, NULL, NULL, d_attribute9, l_d_attributes_tbl(9))
               , DECODE(l_d_attributes_tbl(9), g_miss_date, d_attribute9, NULL, NULL, l_d_attributes_tbl(9))
               )
           , d_attribute10 =
               DECODE(
                 p_source
               , 2, DECODE(l_d_attributes_tbl(10), g_miss_date, NULL, NULL, d_attribute10, l_d_attributes_tbl(10))
               , DECODE(l_d_attributes_tbl(10), g_miss_date, d_attribute10, NULL, NULL, l_d_attributes_tbl(10))
               )
           ,LAST_UPDATE_DATE = sysdate
           ,LAST_UPDATED_BY  = fnd_global.user_id
       WHERE inventory_item_id = p_lot_rec.inventory_item_id
         AND organization_id = p_lot_rec.organization_id
         AND lot_number = p_lot_rec.lot_number;
    ELSE
      UPDATE mtl_lot_numbers
         SET expiration_date =
               DECODE(l_expiration_date, NULL, expiration_date, l_expiration_date )
           , disable_flag =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.disable_flag, g_miss_char, NULL, NULL, disable_flag, p_lot_rec.disable_flag)
               , DECODE(p_lot_rec.disable_flag, g_miss_char, disable_flag, NULL, NULL, p_lot_rec.disable_flag)
               )
           , attribute_category =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.attribute_category, g_miss_char, NULL, NULL, attribute_category, p_lot_rec.attribute_category)
               , DECODE(p_lot_rec.attribute_category, g_miss_char, attribute_category, NULL, NULL, p_lot_rec.attribute_category)
               )
           , lot_attribute_category =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.lot_attribute_category, g_miss_char, NULL, NULL, lot_attribute_category, p_lot_rec.lot_attribute_category)
               , DECODE(p_lot_rec.lot_attribute_category, g_miss_char, lot_attribute_category, NULL, NULL, p_lot_rec.lot_attribute_category)
               )
           , grade_code =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.grade_code, g_miss_char, NULL, NULL, grade_code, p_lot_rec.grade_code)
               , DECODE(p_lot_rec.grade_code, g_miss_char, grade_code, NULL, NULL, p_lot_rec.grade_code)
               )
           , origination_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.origination_date, g_miss_date, To_Date(NULL), NULL, origination_date, p_lot_rec.origination_date)
               , DECODE(p_lot_rec.origination_date, g_miss_date, origination_date, NULL, To_Date(NULL), p_lot_rec.origination_date)
               )
           , date_code =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.date_code, g_miss_char, NULL, NULL, date_code, p_lot_rec.date_code)
               , DECODE(p_lot_rec.date_code, g_miss_char, date_code, NULL, NULL, p_lot_rec.date_code)
               )
	   /* Bug 8198497 - Removed the code as we are updating the status by calling validate_lot_status */
           , change_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.change_date, g_miss_date, To_Date(NULL), NULL, change_date, p_lot_rec.change_date)
               , DECODE(p_lot_rec.change_date, g_miss_date, change_date, NULL, To_Date(NULL), p_lot_rec.change_date)
               )
           , age = DECODE(
                    p_source
                  , 2, DECODE(p_lot_rec.age, g_miss_num, NULL, NULL, age, p_lot_rec.age)
                  , DECODE(p_lot_rec.age, g_miss_num, age, NULL, NULL, p_lot_rec.age)
                  )
           , retest_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.retest_date, g_miss_date, To_Date(NULL), NULL, retest_date, p_lot_rec.retest_date)
               , DECODE(p_lot_rec.retest_date, g_miss_date, retest_date, NULL, To_Date(NULL), p_lot_rec.retest_date)
               )
           , maturity_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.maturity_date, g_miss_date, To_Date(NULL), NULL, maturity_date, p_lot_rec.maturity_date)
               , DECODE(p_lot_rec.maturity_date, g_miss_date, maturity_date, NULL, To_Date(NULL), p_lot_rec.maturity_date)
               )
           , item_size =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.item_size, g_miss_num, NULL, NULL, item_size, p_lot_rec.item_size)
               , DECODE(p_lot_rec.item_size, g_miss_num, item_size, NULL, NULL, p_lot_rec.item_size)
               )
           , color =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.color, g_miss_char, NULL, NULL, color, p_lot_rec.color)
               , DECODE(p_lot_rec.color, g_miss_char, color, NULL, NULL, p_lot_rec.color)
               )
           , volume =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.volume, g_miss_num, NULL, NULL, volume, p_lot_rec.volume)
               , DECODE(p_lot_rec.volume, g_miss_num, volume, NULL, NULL, p_lot_rec.volume)
               )
           , volume_uom =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.volume_uom, g_miss_char, NULL, NULL, volume_uom, p_lot_rec.volume_uom)
               , DECODE(p_lot_rec.volume_uom, g_miss_char, volume_uom, NULL, NULL, p_lot_rec.volume_uom)
               )
           , place_of_origin =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.place_of_origin, g_miss_char, NULL, NULL, place_of_origin, p_lot_rec.place_of_origin)
               , DECODE(p_lot_rec.place_of_origin, g_miss_char, place_of_origin, NULL, place_of_origin, p_lot_rec.place_of_origin)
               )
           , best_by_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.best_by_date, g_miss_date, To_Date(NULL), NULL, best_by_date, p_lot_rec.best_by_date)
               , DECODE(p_lot_rec.best_by_date, g_miss_date, best_by_date, NULL, To_Date(NULL), p_lot_rec.best_by_date)
               )
           , LENGTH =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.length, g_miss_num, NULL, NULL, LENGTH, p_lot_rec.length)
               , DECODE(p_lot_rec.length, g_miss_num, LENGTH, NULL, NULL, p_lot_rec.length)
               )
           , length_uom =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.length_uom, g_miss_char, NULL, NULL, length_uom, p_lot_rec.length_uom)
               , DECODE(p_lot_rec.length_uom, g_miss_char, length_uom, NULL, NULL, p_lot_rec.length_uom)
               )
           , recycled_content =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.recycled_content, g_miss_num, NULL, NULL, recycled_content, p_lot_rec.recycled_content)
               , DECODE(p_lot_rec.recycled_content, g_miss_num, recycled_content, NULL, NULL, p_lot_rec.recycled_content)
               )
           , thickness =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.thickness, g_miss_num, NULL, NULL, thickness, p_lot_rec.thickness)
               , DECODE(p_lot_rec.thickness, g_miss_num, thickness, NULL, NULL, p_lot_rec.thickness)
               )
           , thickness_uom =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.thickness_uom, g_miss_char, NULL, NULL, thickness_uom, p_lot_rec.thickness_uom)
               , DECODE(p_lot_rec.thickness_uom, g_miss_char, thickness_uom, NULL, NULL, p_lot_rec.thickness_uom)
               )
           , width =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.width, g_miss_num, NULL, NULL, width, p_lot_rec.width)
               , DECODE(p_lot_rec.width, g_miss_num, width, NULL, NULL, p_lot_rec.width)
               )
           , width_uom =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.width_uom, g_miss_char, NULL, NULL, width_uom, p_lot_rec.width_uom)
               , DECODE(p_lot_rec.width_uom, g_miss_char, width_uom, NULL, NULL, p_lot_rec.width_uom)
               )
           , territory_code =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.territory_code, g_miss_char, NULL, NULL, territory_code, p_lot_rec.territory_code)
               , DECODE(p_lot_rec.territory_code, g_miss_char, territory_code, NULL, NULL, p_lot_rec.territory_code)
               )
           , supplier_lot_number =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.supplier_lot_number, g_miss_char, NULL, NULL, supplier_lot_number, p_lot_rec.supplier_lot_number)
               , DECODE(p_lot_rec.supplier_lot_number, g_miss_char, supplier_lot_number, NULL, NULL, p_lot_rec.supplier_lot_number)
               )
           -- Bug 6983527 - Parent lot number should never be updated.
           /*Bug 8311729 Uncommenting the below code as we should be able to
update the mistakenly entered parent lot information */
	   -- nsinghi bug#5209065. Update new lot attributes
           , parent_lot_number =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.parent_lot_number, g_miss_char, NULL, NULL, parent_lot_number, p_lot_rec.parent_lot_number)
               , DECODE(p_lot_rec.parent_lot_number, g_miss_char, parent_lot_number, NULL, NULL, p_lot_rec.parent_lot_number)
               )
           , origination_type =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.origination_type, g_miss_num, NULL, NULL, origination_type, p_lot_rec.origination_type)
               , DECODE(p_lot_rec.origination_type, g_miss_num, origination_type, NULL, NULL, p_lot_rec.origination_type)
               )
           , availability_type =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.availability_type, g_miss_num, NULL, NULL, availability_type, p_lot_rec.availability_type)
               , DECODE(p_lot_rec.availability_type, g_miss_num, availability_type, NULL, NULL, p_lot_rec.availability_type)
               )
           , expiration_action_code =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.expiration_action_code, g_miss_char, NULL, NULL, expiration_action_code, p_lot_rec.expiration_action_code)
               , DECODE(p_lot_rec.expiration_action_code, g_miss_char, expiration_action_code, NULL, NULL, p_lot_rec.expiration_action_code)
               )
           , expiration_action_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.expiration_action_date, g_miss_date, To_Date(NULL), NULL, expiration_action_date, p_lot_rec.expiration_action_date)
               , DECODE(p_lot_rec.expiration_action_date, g_miss_date, expiration_action_date, NULL, To_Date(NULL), p_lot_rec.expiration_action_date)
               )
           , hold_date =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.hold_date, g_miss_date, To_Date(NULL), NULL, hold_date, p_lot_rec.hold_date)
               , DECODE(p_lot_rec.hold_date, g_miss_date, hold_date, NULL, To_Date(NULL), p_lot_rec.hold_date)
               )
           , inventory_atp_code =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.inventory_atp_code, g_miss_num, NULL, NULL, inventory_atp_code, p_lot_rec.inventory_atp_code)
               , DECODE(p_lot_rec.inventory_atp_code, g_miss_num, inventory_atp_code, NULL, NULL, p_lot_rec.inventory_atp_code)
               )
           , reservable_type =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.reservable_type, g_miss_num, NULL, NULL, reservable_type, p_lot_rec.reservable_type)
               , DECODE(p_lot_rec.reservable_type, g_miss_num, reservable_type, NULL, NULL, p_lot_rec.reservable_type)
               )
           , sampling_event_id =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.sampling_event_id, g_miss_num, NULL, NULL, sampling_event_id, p_lot_rec.sampling_event_id)
               , DECODE(p_lot_rec.sampling_event_id, g_miss_num, sampling_event_id, NULL, NULL, p_lot_rec.sampling_event_id)
               )
	   -- nsinghi bug#5209065. End.
           , vendor_name =
               DECODE(
                 p_source
               , 2, DECODE(p_lot_rec.vendor_name, g_miss_char, NULL, NULL, vendor_name, p_lot_rec.vendor_name)
               , DECODE(p_lot_rec.vendor_name, g_miss_char, vendor_name, NULL, NULL, p_lot_rec.vendor_name)
               )
           , attribute1 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(1), g_miss_char, NULL, NULL, attribute1, l_inv_attributes_tbl(1))
               , DECODE(l_inv_attributes_tbl(1), g_miss_char, attribute1, NULL, NULL, l_inv_attributes_tbl(1))
               )
           , attribute2 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(2), g_miss_char, NULL, NULL, attribute2, l_inv_attributes_tbl(2))
               , DECODE(l_inv_attributes_tbl(2), g_miss_char, attribute2, NULL, NULL, l_inv_attributes_tbl(2))
               )
           , attribute3 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(3), g_miss_char, NULL, NULL, attribute3, l_inv_attributes_tbl(3))
               , DECODE(l_inv_attributes_tbl(3), g_miss_char, attribute3, NULL, NULL, l_inv_attributes_tbl(3))
               )
           , attribute4 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(4), g_miss_char, NULL, NULL, attribute4, l_inv_attributes_tbl(4))
               , DECODE(l_inv_attributes_tbl(4), g_miss_char, attribute4, NULL, NULL, l_inv_attributes_tbl(4))
               )
           , attribute5 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(5), g_miss_char, NULL, NULL, attribute5, l_inv_attributes_tbl(5))
               , DECODE(l_inv_attributes_tbl(5), g_miss_char, attribute5, NULL, NULL, l_inv_attributes_tbl(5))
               )
           , attribute6 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(6), g_miss_char, NULL, NULL, attribute6, l_inv_attributes_tbl(6))
               , DECODE(l_inv_attributes_tbl(6), g_miss_char, attribute6, NULL, NULL, l_inv_attributes_tbl(6))
               )
           , attribute7 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(7), g_miss_char, NULL, NULL, attribute7, l_inv_attributes_tbl(7))
               , DECODE(l_inv_attributes_tbl(7), g_miss_char, attribute7, NULL, NULL, l_inv_attributes_tbl(7))
               )
           , attribute8 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(8), g_miss_char, NULL, NULL, attribute8, l_inv_attributes_tbl(8))
               , DECODE(l_inv_attributes_tbl(8), g_miss_char, attribute8, NULL, NULL, l_inv_attributes_tbl(8))
               )
           , attribute9 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(9), g_miss_char, NULL, NULL, attribute9, l_inv_attributes_tbl(9))
               , DECODE(l_inv_attributes_tbl(9), g_miss_char, attribute9, NULL, NULL, l_inv_attributes_tbl(9))
               )
           , attribute10 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(10), g_miss_char, NULL, NULL, attribute10, l_inv_attributes_tbl(10))
               , DECODE(l_inv_attributes_tbl(10), g_miss_char, attribute10, NULL, NULL, l_inv_attributes_tbl(10))
               )
           , attribute11 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(11), g_miss_char, NULL, NULL, attribute11, l_inv_attributes_tbl(11))
               , DECODE(l_inv_attributes_tbl(11), g_miss_char, attribute11, NULL, NULL, l_inv_attributes_tbl(11))
               )
           , attribute12 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(12), g_miss_char, NULL, NULL, attribute12, l_inv_attributes_tbl(12))
               , DECODE(l_inv_attributes_tbl(12), g_miss_char, attribute12, NULL, NULL, l_inv_attributes_tbl(12))
               )
           , attribute13 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(13), g_miss_char, NULL, NULL, attribute13, l_inv_attributes_tbl(13))
               , DECODE(l_inv_attributes_tbl(13), g_miss_char, attribute13, NULL, NULL, l_inv_attributes_tbl(13))
               )
           , attribute14 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(14), g_miss_char, NULL, NULL, attribute14, l_inv_attributes_tbl(14))
               , DECODE(l_inv_attributes_tbl(14), g_miss_char, attribute14, NULL, NULL, l_inv_attributes_tbl(14))
               )
           , attribute15 =
               DECODE(
                 p_source
               , 2, DECODE(l_inv_attributes_tbl(15), g_miss_char, NULL, NULL, attribute15, l_inv_attributes_tbl(15))
               , DECODE(l_inv_attributes_tbl(15), g_miss_char, attribute15, NULL, NULL, l_inv_attributes_tbl(15))
               )
            /*, c_attribute1 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(1), g_miss_char, NULL, NULL, c_attribute1, l_c_attributes_tbl(1))
       ,DECODE(l_c_attributes_tbl(1), g_miss_char, c_attribute1, NULL, null, l_c_attributes_tbl(1)))
            , c_attribute2 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(2), g_miss_char, NULL, NULL, c_attribute2, l_c_attributes_tbl(2))
       ,DECODE(l_c_attributes_tbl(2), g_miss_char, c_attribute2, NULL, null, l_c_attributes_tbl(2)))
            , c_attribute3 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(3), g_miss_char, NULL, NULL, c_attribute3, l_c_attributes_tbl(3))
       ,DECODE(l_c_attributes_tbl(3), g_miss_char, c_attribute3, NULL, null, l_c_attributes_tbl(3)))
            , c_attribute4 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(4), g_miss_char, NULL, NULL, c_attribute4, l_c_attributes_tbl(4))
       ,DECODE(l_c_attributes_tbl(4), g_miss_char, c_attribute4, NULL, null, l_c_attributes_tbl(4)))
            , c_attribute5 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(5), g_miss_char, NULL, NULL, c_attribute5, l_c_attributes_tbl(5))
       ,DECODE(l_c_attributes_tbl(5), g_miss_char, c_attribute5, NULL, null, l_c_attributes_tbl(5)))
            , c_attribute6 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(6), g_miss_char, NULL, NULL, c_attribute6, l_c_attributes_tbl(6))
       ,DECODE(l_c_attributes_tbl(6), g_miss_char, c_attribute6, NULL, null, l_c_attributes_tbl(6)))
            , c_attribute7 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(7), g_miss_char, NULL, NULL, c_attribute7, l_c_attributes_tbl(7))
       ,DECODE(l_c_attributes_tbl(7), g_miss_char, c_attribute7, NULL, null, l_c_attributes_tbl(7)))
            , c_attribute8 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(8), g_miss_char, NULL, NULL, c_attribute8, l_c_attributes_tbl(8))
       ,DECODE(l_c_attributes_tbl(8), g_miss_char, c_attribute8, NULL, null, l_c_attributes_tbl(8)))
            , c_attribute9 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(9), g_miss_char, NULL, NULL, c_attribute9, l_c_attributes_tbl(9))
       ,DECODE(l_c_attributes_tbl(9), g_miss_char, c_attribute9, NULL, null, l_c_attributes_tbl(9)))
            , c_attribute10 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(10), g_miss_char, NULL, NULL, c_attribute10, l_c_attributes_tbl(10))
       ,DECODE(l_c_attributes_tbl(10), g_miss_char, c_attribute10, NULL, null, l_c_attributes_tbl(10)))
            , c_attribute11 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(11), g_miss_char, NULL, NULL, c_attribute11, l_c_attributes_tbl(11))
       ,DECODE(l_c_attributes_tbl(11), g_miss_char, c_attribute11, NULL, null, l_c_attributes_tbl(11)))
            , c_attribute12 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(12), g_miss_char, NULL, NULL, c_attribute12, l_c_attributes_tbl(12))
       ,DECODE(l_c_attributes_tbl(12), g_miss_char, c_attribute12, NULL, null, l_c_attributes_tbl(12)))
            , c_attribute13 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(13), g_miss_char, NULL, NULL, c_attribute13, l_c_attributes_tbl(13))
       ,DECODE(l_c_attributes_tbl(13), g_miss_char, c_attribute13, NULL, null, l_c_attributes_tbl(13)))
            , c_attribute14 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(14), g_miss_char, NULL, NULL, c_attribute14, l_c_attributes_tbl(14))
       ,DECODE(l_c_attributes_tbl(14), g_miss_char, c_attribute14, NULL, null, l_c_attributes_tbl(14)))
            , c_attribute15 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(15), g_miss_char, NULL, NULL, c_attribute15, l_c_attributes_tbl(15))
       ,DECODE(l_c_attributes_tbl(15), g_miss_char, c_attribute15, NULL, null, l_c_attributes_tbl(15)))
            , c_attribute16 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(16), g_miss_char, NULL, NULL, c_attribute16, l_c_attributes_tbl(16))
       ,DECODE(l_c_attributes_tbl(16), g_miss_char, c_attribute16, NULL, null, l_c_attributes_tbl(16)))
            , c_attribute17 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(17), g_miss_char, NULL, NULL, c_attribute17, l_c_attributes_tbl(17))
       ,DECODE(l_c_attributes_tbl(17), g_miss_char, c_attribute17, NULL, null, l_c_attributes_tbl(17)))
            , c_attribute18 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(18), g_miss_char, NULL, NULL, c_attribute18, l_c_attributes_tbl(18))
       ,DECODE(l_c_attributes_tbl(18), g_miss_char, c_attribute18, NULL, null, l_c_attributes_tbl(18)))
            , c_attribute19 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(19), g_miss_char, NULL, NULL, c_attribute19, l_c_attributes_tbl(19))
       ,DECODE(l_c_attributes_tbl(19), g_miss_char, c_attribute19, NULL, null, l_c_attributes_tbl(19)))
            , c_attribute20 = decode(p_source, 2,
       DECODE(l_c_attributes_tbl(20), g_miss_char, NULL, NULL, c_attribute20, l_c_attributes_tbl(20))
       ,DECODE(l_c_attributes_tbl(20), g_miss_char, c_attribute20, NULL, null, l_c_attributes_tbl(20)))
            , n_attribute1 = decode(p_source, 2,
       DECODE(l_n_attributes_tbl(1), g_miss_num, NULL, NULL, n_attribute1, l_n_attributes_tbl(1))
       , DECODE(l_n_attributes_tbl(1), g_miss_num, N_attribute1, NULL, null, l_n_attributes_tbl(1)))
            , n_attribute2 = decode(p_source, 2,
       DECODE(l_n_attributes_tbl(2), g_miss_num, NULL, NULL, n_attribute2, l_n_attributes_tbl(2))
       , DECODE(l_n_attributes_tbl(2), g_miss_num, N_attribute2, NULL, null, l_n_attributes_tbl(2)))
            , n_attribute3 = decode(p_source, 2,
       DECODE(l_n_attributes_tbl(3), g_miss_num, NULL, NULL, n_attribute3, l_n_attributes_tbl(3))
       , DECODE(l_n_attributes_tbl(3), g_miss_num, N_attribute3, NULL, null, l_n_attributes_tbl(3)))
            , n_attribute4 = decode(p_source, 2,
       DECODE(l_n_attributes_tbl(4), g_miss_num, NULL, NULL, n_attribute4, l_n_attributes_tbl(4))
       , DECODE(l_n_attributes_tbl(4), g_miss_num, N_attribute4, NULL, null, l_n_attributes_tbl(4)))
            , n_attribute5 = decode(p_source, 2,
       DECODE(l_n_attributes_tbl(5), g_miss_num, NULL, NULL, n_attribute5, l_n_attributes_tbl(5))
       , DECODE(l_n_attributes_tbl(5), g_miss_num, N_attribute5, NULL, null, l_n_attributes_tbl(5)))
            , n_attribute6 = decode(p_source, 2,
       DECODE(l_n_attributes_tbl(6), g_miss_num, NULL, NULL, n_attribute6, l_n_attributes_tbl(6))
       , DECODE(l_n_attributes_tbl(6), g_miss_num, N_attribute6, NULL, null, l_n_attributes_tbl(6)))
            , n_attribute7 = decode(p_source, 2,
       DECODE(l_n_attributes_tbl(7), g_miss_num, NULL, NULL, n_attribute7, l_n_attributes_tbl(7))
       , DECODE(l_n_attributes_tbl(7), g_miss_num, N_attribute7, NULL, null, l_n_attributes_tbl(7)))
            , n_attribute8 = decode(p_source, 2,
       DECODE(l_n_attributes_tbl(8), g_miss_num, NULL, NULL, n_attribute8, l_n_attributes_tbl(8))
       , DECODE(l_n_attributes_tbl(8), g_miss_num, N_attribute8, NULL, null, l_n_attributes_tbl(8)))
            , n_attribute9 = decode(p_source, 2,
       DECODE(l_n_attributes_tbl(9), g_miss_num, NULL, NULL, n_attribute9, l_n_attributes_tbl(9))
       ,DECODE(l_n_attributes_tbl(9), g_miss_num, N_attribute9, NULL, null, l_n_attributes_tbl(9)))
            , n_attribute10 = decode(p_source, 2,
       DECODE(l_n_attributes_tbl(10), g_miss_num, NULL, NULL, n_attribute10, l_n_attributes_tbl(10))
       ,DECODE(l_n_attributes_tbl(10), g_miss_num, n_attribute10, NULL, null, l_n_attributes_tbl(10)))
            , d_attribute1 = decode(p_source, 2,
       DECODE(l_d_attributes_tbl(1), g_miss_date, NULL, NULL, d_attribute1, l_d_attributes_tbl(1))
       , DECODE(l_d_attributes_tbl(1), g_miss_date, d_attribute1, NULL, null, l_d_attributes_tbl(1)))
            , d_attribute2 = decode(p_source, 2,
       DECODE(l_d_attributes_tbl(2), g_miss_date, NULL, NULL, d_attribute2, l_d_attributes_tbl(2))
       , DECODE(l_d_attributes_tbl(2), g_miss_date, d_attribute2, NULL, null, l_d_attributes_tbl(2)))
            , d_attribute3 = decode(p_source, 2,
       DECODE(l_d_attributes_tbl(3), g_miss_date, NULL, NULL, d_attribute3, l_d_attributes_tbl(3))
       , DECODE(l_d_attributes_tbl(3), g_miss_date, d_attribute3, NULL, null, l_d_attributes_tbl(3)))
            , d_attribute4 = decode(p_source, 2,
       DECODE(l_d_attributes_tbl(4), g_miss_date, NULL, NULL, d_attribute4, l_d_attributes_tbl(4))
       , DECODE(l_d_attributes_tbl(4), g_miss_date, d_attribute4, NULL, null, l_d_attributes_tbl(4)))
            , d_attribute5 = decode(p_source, 2,
       DECODE(l_d_attributes_tbl(5), g_miss_date, NULL, NULL, d_attribute5, l_d_attributes_tbl(5))
       , DECODE(l_d_attributes_tbl(5), g_miss_date, d_attribute5, NULL, null, l_d_attributes_tbl(5)))
            , d_attribute6 = decode(p_source, 2,
       DECODE(l_d_attributes_tbl(6), g_miss_date, NULL, NULL, d_attribute6, l_d_attributes_tbl(6))
       ,DECODE(l_d_attributes_tbl(6), g_miss_date, d_attribute6, NULL, null, l_d_attributes_tbl(6)))
            , d_attribute7 = decode(p_source, 2,
       DECODE(l_d_attributes_tbl(7), g_miss_date, NULL, NULL, d_attribute7, l_d_attributes_tbl(7))
       , DECODE(l_d_attributes_tbl(7), g_miss_date, d_attribute7, NULL, null, l_d_attributes_tbl(7)))
            , d_attribute8 = decode(p_source, 2,
       DECODE(l_d_attributes_tbl(8), g_miss_date, NULL, NULL, d_attribute8, l_d_attributes_tbl(8))
       , DECODE(l_d_attributes_tbl(8), g_miss_date, d_attribute8, NULL, null, l_d_attributes_tbl(8)))
            , d_attribute9 = decode(p_source, 2,
       DECODE(l_d_attributes_tbl(9), g_miss_date, NULL, NULL, d_attribute9, l_d_attributes_tbl(9))
       , DECODE(l_d_attributes_tbl(9), g_miss_date, d_attribute9, NULL, null, l_d_attributes_tbl(9)))
            , d_attribute10 = decode(p_source, 2,
       DECODE(l_d_attributes_tbl(10), g_miss_date, NULL, NULL, d_attribute10, l_d_attributes_tbl(10))
       ,DECODE(l_d_attributes_tbl(10), g_miss_date, d_attribute10, NULL, null, l_d_attributes_tbl(10)))*/
       ,LAST_UPDATE_DATE = sysdate
       ,LAST_UPDATED_BY  = fnd_global.user_id
      WHERE  inventory_item_id = p_lot_rec.inventory_item_id
         AND organization_id = p_lot_rec.organization_id
         AND lot_number = p_lot_rec.lot_number;
    END IF;


    IF SQL%FOUND THEN
      IF g_debug = 1 THEN
        print_debug('Upd Lot Attr:Update successfully completed', 9);
      END IF;
    END IF;

    /* Bug 8198497: Calling the API to validate status of the lot and update it */
    validate_lot_status(
             p_api_version
           , p_init_msg_list
           , p_lot_rec.organization_id
           , p_lot_rec.inventory_item_id
           , p_lot_rec.lot_number
           , p_lot_rec.status_id
           , x_return_status
           , x_msg_count
           , x_msg_data
           );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := g_ret_sts_error;
      ROLLBACK TO upd_lot_attr;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('Upd Lort Attr: In No data found ' || SQLERRM, 9);
    WHEN g_exc_error THEN
      x_return_status  := g_ret_sts_error;
      ROLLBACK TO upd_lot_attr;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('Upd Lot  Attr: In g_exc_error ' || SQLERRM, 9);
    WHEN g_exc_unexpected_error THEN
      x_return_status  := g_ret_sts_unexp_error;
      ROLLBACK TO upd_lot_attr;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if ( x_msg_count > 1 ) then
           x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In g_exc_unexpected_error ' || SQLERRM, 9);
    WHEN OTHERS THEN
      x_return_status  := g_ret_sts_unexp_error;
      ROLLBACK TO upd_lot_attr;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('Upd Lot Attr: In others ' || SQLERRM, 9);
  END update_inv_lot;

-- nsinghi bug#5209065. Created Overloaded procedure, which takes in lot rec as input parameter. This will help updating the new lot attributes added in R12.
  PROCEDURE update_inv_lot(
    x_return_status          OUT NOCOPY    VARCHAR2
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , p_inventory_item_id      IN            NUMBER
  , p_organization_id        IN            NUMBER
  , p_lot_number             IN            VARCHAR2
  , p_expiration_date        IN            DATE
  , p_disable_flag           IN            NUMBER
  , p_attribute_category     IN            VARCHAR2
  , p_lot_attribute_category IN            VARCHAR2
  , p_attributes_tbl         IN            inv_lot_api_pub.char_tbl
  , p_c_attributes_tbl       IN            inv_lot_api_pub.char_tbl
  , p_n_attributes_tbl       IN            inv_lot_api_pub.number_tbl
  , p_d_attributes_tbl       IN            inv_lot_api_pub.date_tbl
  , p_grade_code             IN            VARCHAR2
  , p_origination_date       IN            DATE
  , p_date_code              IN            VARCHAR2
  , p_status_id              IN            NUMBER
  , p_change_date            IN            DATE
  , p_age                    IN            NUMBER
  , p_retest_date            IN            DATE
  , p_maturity_date          IN            DATE
  , p_item_size              IN            NUMBER
  , p_color                  IN            VARCHAR2
  , p_volume                 IN            NUMBER
  , p_volume_uom             IN            VARCHAR2
  , p_place_of_origin        IN            VARCHAR2
  , p_best_by_date           IN            DATE
  , p_length                 IN            NUMBER
  , p_length_uom             IN            VARCHAR2
  , p_recycled_content       IN            NUMBER
  , p_thickness              IN            NUMBER
  , p_thickness_uom          IN            VARCHAR2
  , p_width                  IN            NUMBER
  , p_width_uom              IN            VARCHAR2
  , p_territory_code         IN            VARCHAR2
  , p_supplier_lot_number    IN            VARCHAR2
  , p_vendor_name            IN            VARCHAR2
  , p_source                 IN            NUMBER
  ) IS
   l_in_lot_rec            MTL_LOT_NUMBERS%ROWTYPE;
   x_lot_rec                       MTL_LOT_NUMBERS%ROWTYPE;
   l_api_version        NUMBER;
   l_init_msg_list         VARCHAR2(100);
   l_commit          VARCHAR2(100);
   l_origin_txn_id         NUMBER;
   l_return_status                 VARCHAR2(1)  ;
   l_msg_data                      VARCHAR2(3000)  ;
   l_msg_count                     NUMBER    ;

   BEGIN
     SAVEPOINT upd_lot_attr;
     x_return_status  := fnd_api.g_ret_sts_success;

     /* Populating the variables and calling the new overloaded API  */

     l_in_lot_rec.inventory_item_id             :=   p_inventory_item_id;
     l_in_lot_rec.organization_id               :=   p_organization_id;
     l_in_lot_rec.lot_number                    :=   p_lot_number;
     l_in_lot_rec.parent_lot_number             :=   NULL;
     l_in_lot_rec.expiration_date               :=   p_expiration_date;
     l_in_lot_rec.disable_flag                  :=   p_disable_flag;
     l_in_lot_rec.attribute_category            :=   p_attribute_category;
     l_in_lot_rec.lot_attribute_category        :=   p_lot_attribute_category;
     l_in_lot_rec.grade_code                    :=   p_grade_code;
     l_in_lot_rec.origination_date              :=   p_origination_date;
     l_in_lot_rec.date_code                     :=   p_date_code;
     l_in_lot_rec.status_id                     :=   p_status_id;
     l_in_lot_rec.change_date                   :=   p_change_date;
     l_in_lot_rec.age                           :=   p_age;
     l_in_lot_rec.retest_date                   :=   p_retest_date;
     l_in_lot_rec.maturity_date                 :=   p_maturity_date;
     l_in_lot_rec.item_size                     :=   p_item_size;
     l_in_lot_rec.color                         :=   p_color;
     l_in_lot_rec.volume                        :=   p_volume;
     l_in_lot_rec.volume_uom                    :=   p_volume_uom;
     l_in_lot_rec.place_of_origin               :=   p_place_of_origin;
     l_in_lot_rec.best_by_date                  :=   p_best_by_date;
     l_in_lot_rec.length                        :=   p_length;
     l_in_lot_rec.length_uom                    :=   p_length_uom;
     l_in_lot_rec.recycled_content              :=   p_recycled_content;
     l_in_lot_rec.thickness                     :=   p_thickness;
     l_in_lot_rec.thickness_uom                 :=   p_thickness_uom;
     l_in_lot_rec.width                         :=   p_width;
     l_in_lot_rec.width_uom                     :=   p_width_uom;
     l_in_lot_rec.territory_code                :=   p_territory_code;
     l_in_lot_rec.supplier_lot_number           :=   p_supplier_lot_number;
     l_in_lot_rec.vendor_name                   :=   p_vendor_name;
     l_in_lot_rec.last_update_date		:=   SYSDATE ;
     l_in_lot_rec.last_updated_by		:=   FND_GLOBAL.USER_ID;
     l_in_lot_rec.last_update_login             :=   FND_GLOBAL.LOGIN_ID;
     --BUG 4748451: if the p%tbl are not initialized, then a no_date_found
     --exception would be thrown if accessed.  So add clause to check for this
     IF (p_attributes_tbl.exists(1)) THEN
       l_in_lot_rec.attribute1                    :=   p_attributes_tbl(1);
     END IF;
     IF (p_attributes_tbl.exists(2)) THEN
       l_in_lot_rec.attribute2                    :=   p_attributes_tbl(2);
     END IF;
     IF (p_attributes_tbl.exists(3)) THEN
       l_in_lot_rec.attribute3                    :=   p_attributes_tbl(3);
     END IF;
     IF (p_attributes_tbl.exists(4)) THEN
       l_in_lot_rec.attribute4                    :=   p_attributes_tbl(4);
     END IF;
     IF (p_attributes_tbl.exists(5)) THEN
       l_in_lot_rec.attribute5                    :=   p_attributes_tbl(5);
     END IF;
     IF (p_attributes_tbl.exists(6)) THEN
       l_in_lot_rec.attribute6                    :=   p_attributes_tbl(6);
     END IF;
     IF (p_attributes_tbl.exists(7)) THEN
       l_in_lot_rec.attribute7                    :=   p_attributes_tbl(7);
     END IF;
     IF (p_attributes_tbl.exists(8)) THEN
       l_in_lot_rec.attribute8                    :=   p_attributes_tbl(8);
     END IF;
     IF (p_attributes_tbl.exists(9)) THEN
       l_in_lot_rec.attribute9                    :=   p_attributes_tbl(9);
     END IF;
     IF (p_attributes_tbl.exists(10)) THEN
       l_in_lot_rec.attribute10                   :=   p_attributes_tbl(10);
     END IF;
     IF (p_attributes_tbl.exists(11)) THEN
       l_in_lot_rec.attribute11                   :=   p_attributes_tbl(11);
     END IF;
     IF (p_attributes_tbl.exists(12)) THEN
       l_in_lot_rec.attribute12                   :=   p_attributes_tbl(12);
     END IF;
     IF (p_attributes_tbl.exists(13)) THEN
       l_in_lot_rec.attribute13                   :=   p_attributes_tbl(13);
     END IF;
     IF (p_attributes_tbl.exists(14)) THEN
       l_in_lot_rec.attribute14                   :=   p_attributes_tbl(14);
     END IF;
     IF (p_attributes_tbl.exists(15)) THEN
       l_in_lot_rec.attribute15                   :=   p_attributes_tbl(15);
     END IF;
     IF (p_c_attributes_tbl.exists(1)) THEN
       l_in_lot_rec.c_attribute1                  :=   p_c_attributes_tbl(1);
     END IF;
     IF (p_c_attributes_tbl.exists(2)) THEN
       l_in_lot_rec.c_attribute2                  :=   p_c_attributes_tbl(2);
     END IF;
     IF (p_c_attributes_tbl.exists(3)) THEN
       l_in_lot_rec.c_attribute3                  :=   p_c_attributes_tbl(3);
     END IF;
     IF (p_c_attributes_tbl.exists(4)) THEN
       l_in_lot_rec.c_attribute4                  :=   p_c_attributes_tbl(4);
     END IF;
     IF (p_c_attributes_tbl.exists(5)) THEN
       l_in_lot_rec.c_attribute5                  :=   p_c_attributes_tbl(5);
     END IF;
     IF (p_c_attributes_tbl.exists(6)) THEN
       l_in_lot_rec.c_attribute6                  :=   p_c_attributes_tbl(6);
     END IF;
     IF (p_c_attributes_tbl.exists(7)) THEN
       l_in_lot_rec.c_attribute7                  :=   p_c_attributes_tbl(7);
     END IF;
     IF (p_c_attributes_tbl.exists(8)) THEN
       l_in_lot_rec.c_attribute8                  :=   p_c_attributes_tbl(8);
     END IF;
     IF (p_c_attributes_tbl.exists(9)) THEN
       l_in_lot_rec.c_attribute9                  :=   p_c_attributes_tbl(9);
     END IF;
     IF (p_c_attributes_tbl.exists(10)) THEN
       l_in_lot_rec.c_attribute10                 :=   p_c_attributes_tbl(10);
     END IF;
     IF (p_c_attributes_tbl.exists(11)) THEN
       l_in_lot_rec.c_attribute11                 :=   p_c_attributes_tbl(11);
     END IF;
     IF (p_c_attributes_tbl.exists(12)) THEN
       l_in_lot_rec.c_attribute12                 :=   p_c_attributes_tbl(12);
     END IF;
     IF (p_c_attributes_tbl.exists(13)) THEN
       l_in_lot_rec.c_attribute13                 :=   p_c_attributes_tbl(13);
     END IF;
     IF (p_c_attributes_tbl.exists(14)) THEN
       l_in_lot_rec.c_attribute14                 :=   p_c_attributes_tbl(14);
     END IF;
     IF (p_c_attributes_tbl.exists(15)) THEN
       l_in_lot_rec.c_attribute15                 :=   p_c_attributes_tbl(15);
     END IF;
     IF (p_c_attributes_tbl.exists(16)) THEN
       l_in_lot_rec.c_attribute16                 :=   p_c_attributes_tbl(16);
     END IF;
     IF (p_c_attributes_tbl.exists(17)) THEN
       l_in_lot_rec.c_attribute17                 :=   p_c_attributes_tbl(17);
     END IF;
     IF (p_c_attributes_tbl.exists(18)) THEN
       l_in_lot_rec.c_attribute18                 :=   p_c_attributes_tbl(18);
     END IF;
     IF (p_c_attributes_tbl.exists(19)) THEN
       l_in_lot_rec.c_attribute19                 :=   p_c_attributes_tbl(19);
     END IF;
     IF (p_c_attributes_tbl.exists(20)) THEN
       l_in_lot_rec.c_attribute20                 :=   p_c_attributes_tbl(20);
     END IF;
     IF (p_n_attributes_tbl.exists(1)) THEN
       l_in_lot_rec.n_attribute1                  :=   p_n_attributes_tbl(1);
     END IF;
     IF (p_n_attributes_tbl.exists(2)) THEN
       l_in_lot_rec.n_attribute2                  :=   p_n_attributes_tbl(2);
     END IF;
     IF (p_n_attributes_tbl.exists(3)) THEN
       l_in_lot_rec.n_attribute3                  :=   p_n_attributes_tbl(3);
     END IF;
     IF (p_n_attributes_tbl.exists(4)) THEN
       l_in_lot_rec.n_attribute4                  :=   p_n_attributes_tbl(4);
     END IF;
     IF (p_n_attributes_tbl.exists(5)) THEN
       l_in_lot_rec.n_attribute5                  :=   p_n_attributes_tbl(5);
     END IF;
     IF (p_n_attributes_tbl.exists(6)) THEN
       l_in_lot_rec.n_attribute6                  :=   p_n_attributes_tbl(6);
     END IF;
     IF (p_n_attributes_tbl.exists(7)) THEN
       l_in_lot_rec.n_attribute7                  :=   p_n_attributes_tbl(7);
     END IF;
     IF (p_n_attributes_tbl.exists(8)) THEN
       l_in_lot_rec.n_attribute8                  :=   p_n_attributes_tbl(8);
     END IF;
     IF (p_n_attributes_tbl.exists(9)) THEN
       l_in_lot_rec.n_attribute9                  :=   p_n_attributes_tbl(9);
     END IF;
     IF (p_n_attributes_tbl.exists(10)) THEN
       l_in_lot_rec.n_attribute10                 :=   p_n_attributes_tbl(10);
     END IF;
     IF (p_d_attributes_tbl.exists(1)) THEN
       l_in_lot_rec.d_attribute1                  :=   p_d_attributes_tbl(1);
     END IF;
     IF (p_d_attributes_tbl.exists(2)) THEN
       l_in_lot_rec.d_attribute2                  :=   p_d_attributes_tbl(2);
     END IF;
     IF (p_d_attributes_tbl.exists(3)) THEN
       l_in_lot_rec.d_attribute3                  :=   p_d_attributes_tbl(3);
     END IF;
     IF (p_d_attributes_tbl.exists(4)) THEN
       l_in_lot_rec.d_attribute4                  :=   p_d_attributes_tbl(4);
     END IF;
     IF (p_d_attributes_tbl.exists(5)) THEN
       l_in_lot_rec.d_attribute5                  :=   p_d_attributes_tbl(5);
     END IF;
     IF (p_d_attributes_tbl.exists(6)) THEN
       l_in_lot_rec.d_attribute6                  :=   p_d_attributes_tbl(6);
     END IF;
     IF (p_d_attributes_tbl.exists(7)) THEN
       l_in_lot_rec.d_attribute7                  :=   p_d_attributes_tbl(7);
     END IF;
     IF (p_d_attributes_tbl.exists(8)) THEN
       l_in_lot_rec.d_attribute8                  :=   p_d_attributes_tbl(8);
     END IF;
     IF (p_d_attributes_tbl.exists(9)) THEN
       l_in_lot_rec.d_attribute9                  :=   p_d_attributes_tbl(9);
     END IF;
     IF (p_d_attributes_tbl.exists(10)) THEN
       l_in_lot_rec.d_attribute10                 :=   p_d_attributes_tbl(10);
     END IF;
     --END BUG 4748451
     l_api_version                              :=   1.0;
     l_init_msg_list                            :=   fnd_api.g_false;
     l_commit                                   :=   fnd_api.g_false;
     l_origin_txn_id                            :=   NULL;

     /* Calling the overloaded procedure */
      Update_Inv_lot(
            x_return_status     =>     l_return_status
          , x_msg_count         =>     l_msg_count
          , x_msg_data          =>     l_msg_data
          , x_lot_rec		=>     x_lot_rec
          , p_lot_rec           =>     l_in_lot_rec
          , p_source            =>     p_source
          , p_api_version       =>     l_api_version
          , p_init_msg_list     =>     l_init_msg_list
          , p_commit            =>     l_commit
           );

      IF g_debug = 1 THEN
          print_debug('Program Update_Inv_lot return ' || l_return_status, 9);
      END IF;
      IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF g_debug = 1 THEN
          print_debug('Program Update_Inv_lot has failed with a user defined exception', 9);
        END IF;
        RAISE g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF g_debug = 1 THEN
          print_debug('Program Update_Inv_lot has failed with a Unexpected exception', 9);
        END IF;
        FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
        FND_MESSAGE.SET_TOKEN('PROG_NAME','Update_Inv_lot');
        fnd_msg_pub.ADD;
        RAISE g_exc_unexpected_error;
      END IF;

    print_debug('End of the program Update_Inv_lot. Program has completed successfully ', 9);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := g_ret_sts_error;
      ROLLBACK TO upd_lot_attr;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('Upd Lot Attr: In No data found ' || SQLERRM, 9);
    WHEN g_exc_error THEN
      x_return_status  := g_ret_sts_error;
      ROLLBACK TO upd_lot_attr;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('Upd Lot  Attr: In g_exc_error ' || SQLERRM, 9);
    WHEN g_exc_unexpected_error THEN
      x_return_status  := g_ret_sts_unexp_error;
      ROLLBACK TO upd_lot_attr;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if ( x_msg_count > 1 ) then
           x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In g_exc_unexpected_error ' || SQLERRM, 9);
    WHEN OTHERS THEN
      x_return_status  := g_ret_sts_unexp_error;
      ROLLBACK TO upd_lot_attr;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('Upd Lot Attr: In others ' || SQLERRM, 9);

  END update_inv_lot;
-- nsinghi END. Created new overloaded procedure.

  PROCEDURE wms_lot_attr_validate(
    x_return_status          OUT    NOCOPY VARCHAR2
  , x_msg_count              OUT    NOCOPY NUMBER
  , x_msg_data               OUT    NOCOPY VARCHAR2
  , p_inventory_item_id      IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_disable_flag           IN     NUMBER
  , p_lot_attribute_category IN     VARCHAR2
  , p_c_attributes_tbl       IN     inv_lot_api_pub.char_tbl
  , p_n_attributes_tbl       IN     inv_lot_api_pub.number_tbl
  , p_d_attributes_tbl       IN     inv_lot_api_pub.date_tbl
  , p_grade_code             IN     VARCHAR2
  , p_origination_date       IN     DATE
  , p_date_code              IN     VARCHAR2
  , p_change_date            IN     DATE
  , p_age                    IN     NUMBER
  , p_retest_date            IN     DATE
  , p_maturity_date          IN     DATE
  , p_item_size              IN     NUMBER
  , p_color                  IN     VARCHAR2
  , p_volume                 IN     NUMBER
  , p_volume_uom             IN     VARCHAR2
  , p_place_of_origin        IN     VARCHAR2
  , p_best_by_date           IN     DATE
  , p_length                 IN     NUMBER
  , p_length_uom             IN     VARCHAR2
  , p_recycled_content       IN     NUMBER
  , p_thickness              IN     NUMBER
  , p_thickness_uom          IN     VARCHAR2
  , p_width                  IN     NUMBER
  , p_width_uom              IN     VARCHAR2
  , p_territory_code         IN     VARCHAR2
  , p_supplier_lot_number    IN     VARCHAR2
  , p_vendor_name            IN     VARCHAR2
  ) IS
    TYPE seg_name IS TABLE OF VARCHAR2(1000)
      INDEX BY BINARY_INTEGER;

    lot_dff               inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_attributes_default  inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_attributes_default_count NUMBER;
    l_c_attr_index        NUMBER;
    l_n_attr_index        NUMBER;
    l_d_attr_index        NUMBER;
    l_context             VARCHAR2(1000);
    l_context_r           fnd_dflex.context_r;
    l_contexts_dr         fnd_dflex.contexts_dr;
    l_dflex_r             fnd_dflex.dflex_r;
    l_segments_dr         fnd_dflex.segments_dr;
    l_enabled_seg_name    seg_name;
    l_wms_all_segs_tbl    seg_name;
    l_nsegments           BINARY_INTEGER;
    l_global_context      BINARY_INTEGER;
    l_global_nsegments    BINARY_INTEGER;
    l_value_not_null_flag NUMBER                                       := NULL;
    v_index               NUMBER                                       := 1;
    l_seg_exists          NUMBER;
    error_segment         VARCHAR2(30);
    errors_received       EXCEPTION;
    error_msg             VARCHAR2(5000);
    s                     NUMBER;
    e                     NUMBER;
    l_required_flag       boolean;
    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_enabled_attributes NUMBER;
    l_context_enabled     BOOLEAN := false;
  BEGIN
    x_return_status           := inv_lot_api_pub.g_ret_sts_success;
    SAVEPOINT wms_lot_dff_validate;

    IF g_debug = 1 THEN
      print_debug('In the beginning of the program lot_dff_validate', 9);
    END IF;

    lot_dff(1).column_name    := 'DISABLE_FLAG';
    lot_dff(1).column_type    := 'NUMBER';
    IF p_disable_flag =G_MISS_NUM THEN
       lot_dff(1).column_value   := NULL;
    ELSE
       lot_dff(1).column_value   := p_disable_flag;
    END IF;

    lot_dff(2).column_name    := 'GRADE_CODE';
    lot_dff(2).column_type    := 'VARCHAR2';
    IF  P_GRADE_CODE =G_MISS_CHAR THEN
       lot_dff(2).column_value   := NULL;
    ELSE
       lot_dff(2).column_value   := p_grade_code;
    END IF;

    lot_dff(3).column_name    := 'ORIGINATION_DATE';
    lot_dff(3).column_type    := 'DATE';
    IF P_ORIGINATION_DATE =G_MISS_DATE THEN
       lot_dff(3).column_value   := NULL;
    ELSE
       lot_dff(3).column_value   := fnd_date.date_to_canonical(p_origination_date);
    END IF;

    lot_dff(4).column_name    := 'DATE_CODE';
    lot_dff(4).column_type    := 'VARCHAR2';
    IF  p_date_code = G_MISS_CHAR THEN
       lot_dff(4).column_value   := NULL;
    ELSE
       lot_dff(4).column_value   := p_date_code;
    END IF;

    lot_dff(5).column_name    := 'CHANGE_DATE';
    lot_dff(5).column_type    := 'DATE';
    IF p_change_date= G_MISS_DATE THEN
       lot_dff(5).column_value   := NULL;
    ELSE
       lot_dff(5).column_value   := fnd_date.date_to_canonical(p_change_date);
    END IF;

    lot_dff(6).column_name    := 'ORIGINATION_DATE';
    lot_dff(6).column_type    := 'DATE';
    IF p_origination_date=G_MISS_DATE THEN
       lot_dff(6).column_value   := NULL;
    ELSE
       lot_dff(6).column_value   := fnd_date.date_to_canonical(p_origination_date);
    END IF;

    lot_dff(6).column_name    := 'AGE';
    lot_dff(6).column_type    := 'NUMBER';
    IF p_age =G_MISS_NUM THEN
       lot_dff(6).column_value   := NULL;
    ELSE
       lot_dff(6).column_value   := p_age;
    END IF;

    lot_dff(7).column_name    := 'RETEST_DATE';
    lot_dff(7).column_type    := 'DATE';
    IF p_retest_date=G_MISS_DATE THEN
       lot_dff(7).column_value   := NULL;
    ELSE
       lot_dff(7).column_value   := fnd_date.date_to_canonical(p_retest_date);
    END IF;

    lot_dff(8).column_name    := 'MATURITY_DATE';
    lot_dff(8).column_type    := 'DATE';
    IF p_maturity_date= G_MISS_DATE THEN
       lot_dff(8).column_value   := NULL;
    ELSE
       lot_dff(8).column_value   := fnd_date.date_to_canonical(p_maturity_date);
    END IF;

    lot_dff(9).column_name    := 'ITEM_SIZE';
    lot_dff(9).column_type    := 'NUMBER';
    IF p_item_size=G_MISS_NUM THEN
       lot_dff(9).column_value   := NULL;
    ELSE
       lot_dff(9).column_value   := p_item_size;
    END IF;

    lot_dff(10).column_name   := 'COLOR';
    lot_dff(10).column_type   := 'VARCHAR2';
    IF p_color=G_MISS_CHAR THEN
       lot_dff(10).column_value  := NULL;
    ELSE
       lot_dff(10).column_value  := p_color;
    END IF;

    lot_dff(11).column_name   := 'VOLUME';
    lot_dff(11).column_type   := 'NUMBER';
    IF p_volume = G_MISS_NUM THEN
       lot_dff(11).column_value  := NULL;
    ELSE
       lot_dff(11).column_value  := p_volume;
    END IF;

    lot_dff(12).column_name   := 'VOLUME_UOM';
    lot_dff(12).column_type   := 'VARCHAR2';
    IF p_volume_uom = G_MISS_CHAR THEN
       lot_dff(12).column_value  := NULL;
    ELSE
       lot_dff(12).column_value  := p_volume_uom;
    END IF;

    lot_dff(13).column_name   := 'PLACE_OF_ORIGIN';
    lot_dff(13).column_type   := 'VARCHAR2';
    IF p_place_of_origin=G_MISS_CHAR THEN
       lot_dff(13).column_value  := NULL;
    ELSE
       lot_dff(13).column_value  := p_place_of_origin;
    END IF;

    lot_dff(14).column_name   := 'BEST_BY_DATE';
    lot_dff(14).column_type   := 'DATE';
    IF p_best_by_date= G_MISS_DATE THEN
       lot_dff(14).column_value  := NULL;
     ELSE
       --BUG 3784406: Call date_to_canonical, instead of canonical_to_date
       lot_dff(14).column_value  := fnd_date.date_to_canonical(p_best_by_date);
    END IF;

    lot_dff(15).column_name   := 'LENGTH';
    lot_dff(15).column_type   := 'NUMBER';
    IF p_length=G_MISS_NUM THEN
       lot_dff(15).column_value  := NULL;
    ELSE
       lot_dff(15).column_value  := p_length;
    END IF;

    lot_dff(16).column_name   := 'LENGTH_UOM';
    lot_dff(16).column_type   := 'VARCHAR2';
    IF p_length_uom=G_MISS_CHAR THEN
       lot_dff(16).column_value  := NULL;
    ELSE
       lot_dff(16).column_value  := p_length_uom;
    END IF;

    lot_dff(17).column_name   := 'RECYCLED_CONTENT';
    lot_dff(17).column_type   := 'NUMBER';
    IF p_recycled_content=G_MISS_NUM THEN
       lot_dff(17).column_value  := NULL;
    ELSE
       lot_dff(17).column_value  := p_recycled_content;
    END IF;

    lot_dff(18).column_name   := 'THICKNESS';
    lot_dff(18).column_type   := 'NUMBER';
    IF  p_thickness= G_MISS_NUM THEN
       lot_dff(18).column_value  := NULL;
    ELSE
       lot_dff(18).column_value  := p_thickness;
    END IF;

    lot_dff(19).column_name   := 'THICKNESS_UOM';
    lot_dff(19).column_type   := 'VARCHAR2';
    IF p_thickness_uom=G_MISS_CHAR THEN
       lot_dff(19).column_value  := NULL;
    ELSE
       lot_dff(19).column_value  := p_thickness_uom;
    END IF;

    lot_dff(20).column_name   := 'WIDTH';
    lot_dff(20).column_type   := 'NUMBER';
    IF  p_width =g_miss_num THEN
       lot_dff(20).column_value  := NULL;
    ELSE
       lot_dff(20).column_value  := p_width;
    END IF;

    lot_dff(21).column_name   := 'WIDTH_UOM';
    lot_dff(21).column_type   := 'NUMBER';
    IF p_width_uom=g_miss_char THEN
       lot_dff(21).column_value  := NULL;
    ELSE
       lot_dff(21).column_value  := p_width_uom;
    END IF;

    lot_dff(22).column_name   := 'TERRITORY_CODE';
    lot_dff(22).column_type   := 'VARCHAR2';
    IF  p_territory_code= g_miss_char THEN
       lot_dff(22).column_value  := NULL;
    ELSE
       lot_dff(22).column_value  := p_territory_code;
    END IF;

    lot_dff(23).column_name   := 'SUPPLIER_LOT_NUMBER';
    lot_dff(23).column_type   := 'VARCHAR2';
    IF  p_supplier_lot_number = g_miss_char THEN
       lot_dff(23).column_value  := NULL;
    ELSE
       lot_dff(23).column_value  := p_supplier_lot_number;
    END IF;

    lot_dff(24).column_name   := 'C_ATTRIBUTE1';
    lot_dff(24).column_type   := 'VARCHAR2';
    lot_dff(24).column_value  := NULL;
    lot_dff(25).column_name   := 'C_ATTRIBUTE2';
    lot_dff(25).column_type   := 'VARCHAR2';
    lot_dff(25).column_value  := NULL;
    lot_dff(26).column_name   := 'C_ATTRIBUTE3';
    lot_dff(26).column_type   := 'VARCHAR2';
    lot_dff(26).column_value  := NULL;
    lot_dff(27).column_name   := 'C_ATTRIBUTE4';
    lot_dff(27).column_type   := 'VARCHAR2';
    lot_dff(27).column_value  := NULL;
    lot_dff(28).column_name   := 'C_ATTRIBUTE5';
    lot_dff(28).column_type   := 'VARCHAR2';
    lot_dff(28).column_value  := NULL;
    lot_dff(29).column_name   := 'C_ATTRIBUTE6';
    lot_dff(29).column_type   := 'VARCHAR2';
    lot_dff(29).column_value  := NULL;
    lot_dff(30).column_name   := 'C_ATTRIBUTE7';
    lot_dff(30).column_type   := 'VARCHAR2';
    lot_dff(30).column_value  := NULL;
    lot_dff(31).column_name   := 'C_ATTRIBUTE8';
    lot_dff(31).column_type   := 'VARCHAR2';
    lot_dff(31).column_value  := NULL;
    lot_dff(32).column_name   := 'C_ATTRIBUTE9';
    lot_dff(32).column_type   := 'VARCHAR2';
    lot_dff(32).column_value  := NULL;
    lot_dff(33).column_name   := 'C_ATTRIBUTE10';
    lot_dff(33).column_type   := 'VARCHAR2';
    lot_dff(33).column_value  := NULL;
    lot_dff(34).column_name   := 'C_ATTRIBUTE11';
    lot_dff(34).column_type   := 'VARCHAR2';
    lot_dff(34).column_value  := NULL;
    lot_dff(35).column_name   := 'C_ATTRIBUTE12';
    lot_dff(35).column_type   := 'VARCHAR2';
    lot_dff(35).column_value  := NULL;
    lot_dff(36).column_name   := 'C_ATTRIBUTE13';
    lot_dff(36).column_type   := 'VARCHAR2';
    lot_dff(36).column_value  := NULL;
    lot_dff(37).column_name   := 'C_ATTRIBUTE14';
    lot_dff(37).column_type   := 'VARCHAR2';
    lot_dff(37).column_value  := NULL;
    lot_dff(38).column_name   := 'C_ATTRIBUTE15';
    lot_dff(38).column_type   := 'VARCHAR2';
    lot_dff(38).column_value  := NULL;
    lot_dff(39).column_name   := 'C_ATTRIBUTE16';
    lot_dff(39).column_type   := 'VARCHAR2';
    lot_dff(39).column_value  := NULL;
    lot_dff(40).column_name   := 'C_ATTRIBUTE17';
    lot_dff(40).column_type   := 'VARCHAR2';
    lot_dff(40).column_value  := NULL;
    lot_dff(41).column_name   := 'C_ATTRIBUTE18';
    lot_dff(41).column_type   := 'VARCHAR2';
    lot_dff(41).column_value  := NULL;
    lot_dff(42).column_name   := 'C_ATTRIBUTE19';
    lot_dff(42).column_type   := 'VARCHAR2';
    lot_dff(42).column_value  := NULL;
    lot_dff(43).column_name   := 'C_ATTRIBUTE20';
    lot_dff(43).column_type   := 'VARCHAR2';
    lot_dff(43).column_value  := NULL;
    lot_dff(44).column_name   := 'N_ATTRIBUTE1';
    lot_dff(44).column_type   := 'NUMBER';
    lot_dff(44).column_value  := NULL;
    lot_dff(45).column_name   := 'N_ATTRIBUTE2';
    lot_dff(45).column_type   := 'NUMBER';
    lot_dff(45).column_value  := NULL;
    lot_dff(46).column_name   := 'N_ATTRIBUTE3';
    lot_dff(46).column_type   := 'NUMBER';
    lot_dff(46).column_value  := NULL;
    lot_dff(47).column_name   := 'N_ATTRIBUTE4';
    lot_dff(47).column_type   := 'NUMBER';
    lot_dff(47).column_value  := NULL;
    lot_dff(48).column_name   := 'N_ATTRIBUTE5';
    lot_dff(48).column_type   := 'NUMBER';
    lot_dff(48).column_value  := NULL;
    lot_dff(49).column_name   := 'N_ATTRIBUTE6';
    lot_dff(49).column_type   := 'NUMBER';
    lot_dff(49).column_value  := NULL;
    lot_dff(50).column_name   := 'N_ATTRIBUTE7';
    lot_dff(50).column_type   := 'NUMBER';
    lot_dff(50).column_value  := NULL;
    lot_dff(51).column_name   := 'N_ATTRIBUTE8';
    lot_dff(51).column_type   := 'NUMBER';
    lot_dff(51).column_value  := NULL;
    lot_dff(52).column_name   := 'N_ATTRIBUTE9';
    lot_dff(52).column_type   := 'NUMBER';
    lot_dff(52).column_value  := NULL;
    lot_dff(53).column_name   := 'N_ATTRIBUTE10';
    lot_dff(53).column_type   := 'NUMBER';
    lot_dff(53).column_value  := NULL;
    lot_dff(54).column_name   := 'D_ATTRIBUTE1';
    lot_dff(54).column_type   := 'DATE';
    lot_dff(54).column_value  := NULL;
    lot_dff(55).column_name   := 'D_ATTRIBUTE2';
    lot_dff(55).column_type   := 'DATE';
    lot_dff(55).column_value  := NULL;
    lot_dff(56).column_name   := 'D_ATTRIBUTE3';
    lot_dff(56).column_type   := 'DATE';
    lot_dff(56).column_value  := NULL;
    lot_dff(57).column_name   := 'D_ATTRIBUTE4';
    lot_dff(57).column_type   := 'DATE';
    lot_dff(57).column_value  := NULL;
    lot_dff(58).column_name   := 'D_ATTRIBUTE5';
    lot_dff(58).column_type   := 'DATE';
    lot_dff(58).column_value  := NULL;
    lot_dff(59).column_name   := 'D_ATTRIBUTE6';
    lot_dff(59).column_type   := 'DATE';
    lot_dff(59).column_value  := NULL;
    lot_dff(60).column_name   := 'D_ATTRIBUTE7';
    lot_dff(60).column_type   := 'DATE';
    lot_dff(60).column_value  := NULL;
    lot_dff(61).column_name   := 'D_ATTRIBUTE8';
    lot_dff(61).column_type   := 'DATE';
    lot_dff(61).column_value  := NULL;
    lot_dff(62).column_name   := 'D_ATTRIBUTE9';
    lot_dff(62).column_type   := 'DATE';
    lot_dff(62).column_value  := NULL;
    lot_dff(63).column_name   := 'D_ATTRIBUTE10';
    lot_dff(63).column_type   := 'DATE';
    lot_dff(63).column_value  := NULL;
    /* Loop through the C_ATTRIBUTES_TBL  and populate the values. This starts
       from index 24 till 43. Find the index in the input table where data is
       populated. Add the index value to the starting index of the table
       lot_dff to get the column for which data is populated
     */
    l_c_attr_index            := p_c_attributes_tbl.FIRST;

    WHILE l_c_attr_index <= p_c_attributes_tbl.LAST LOOP
      lot_dff(23 + l_c_attr_index).column_value  := p_c_attributes_tbl(l_c_attr_index);
      l_c_attr_index                             := p_c_attributes_tbl.NEXT(l_c_attr_index);
    END LOOP;

    IF g_debug = 1 THEN
      print_debug('After populating the lot_dff table with C_ATTRIBUTES', 9);
    END IF;

    /* Loop through the N_ATTRIBUTES_TBL  and populate the values. This starts
      from index 44 till 53. Find the index in the input table where data is
      populated. Add the index value to the starting index of the table
      lot_dff to get the column for which data is populated
    */
    l_n_attr_index            := p_n_attributes_tbl.FIRST;

    WHILE l_n_attr_index <= p_n_attributes_tbl.LAST LOOP
      lot_dff(43 + l_n_attr_index).column_value  := p_n_attributes_tbl(l_n_attr_index);
      l_n_attr_index                             := p_n_attributes_tbl.NEXT(l_n_attr_index);
    END LOOP;

    IF g_debug = 1 THEN
      print_debug('After populating the lot_dff table with N_ATTRIBUTES', 9);
    END IF;

    /* Loop through the D_ATTRIBUTES_TBL  and populate the values. This starts
      from index 54 till 63. Find the index in the input table where data is
      populated. Add the index value to the starting index of the table
      lot_dff to get the column for which data is populated
     */
    l_d_attr_index            := p_d_attributes_tbl.FIRST;

    WHILE l_d_attr_index <= p_d_attributes_tbl.LAST LOOP
       IF p_d_attributes_tbl(l_d_attr_index) IS NOT NULL THEN
     -- BUG 3784406: Call fnd_date.date_to_canonical
     IF g_debug = 1 THEN
        print_debug('Date before casting into DD:MM:YYYY format'||To_char(p_d_attributes_tbl(l_d_attr_index),'DD:MM:YYYY'), 9);
     END IF;
     lot_dff(53 + l_d_attr_index).column_value  := fnd_date.date_to_canonical(p_d_attributes_tbl(l_d_attr_index));
     IF g_debug = 1 THEN
        print_debug('Date after casting in canonical format ' || lot_dff(53 + l_d_attr_index).column_value,9);
     END IF;
   ELSE
     lot_dff(53 + l_d_attr_index).column_value  := NULL;
       END IF;

       l_d_attr_index                             := p_d_attributes_tbl.NEXT(l_d_attr_index);
    END LOOP;

    IF g_debug = 1 THEN
      print_debug('After populating the lot_dff table with D_ATTRIBUTES', 9);
    END IF;

    l_enabled_attributes := INV_LOT_SEL_ATTR.is_enabled(
   p_flex_name => 'Lot Attributes'
   , p_organization_id => p_organization_id
   , p_inventory_item_id => p_inventory_item_id);

    IF g_debug = 1 THEN
   print_Debug('l_enabled_attributes = ' || l_enabled_attributes, 9);
    end if;
    /*
     * Get the default lot attribute values if any
     */
    inv_lot_sel_attr.get_default (
            x_attributes_default => l_attributes_default,
            x_attributes_default_count => l_attributes_default_count,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data,
            p_table_name => 'MTL_LOT_NUMBERS',
            p_attributes_name => 'Lot Attributes',
            p_inventory_item_id => p_inventory_item_id,
            p_organization_id => p_organization_id,
            p_lot_serial_number => null,
            p_attributes => lot_dff
    );

    IF ( l_return_status <> fnd_api.g_ret_sts_success ) THEN
         x_return_status := l_return_status;
         RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF ( l_attributes_default_count > 0 ) THEN
        FOR i IN 1 .. l_attributes_default_count LOOP
            FOR j IN 1 .. lot_dff.COUNT LOOP
                IF (UPPER(l_attributes_default(i).column_name) = UPPER(lot_dff(j).column_name)) THEN
                   lot_dff(j).column_value := l_attributes_default(i).column_value;
                END IF;

                EXIT WHEN (UPPER(l_attributes_default(i).column_name) =
                               UPPER(lot_dff(j).column_name));
            END LOOP;
        END LOOP;
    END IF;

    l_dflex_r.application_id  := 401;
    l_dflex_r.flexfield_name  := 'Lot Attributes';

    IF g_debug = 1 THEN
      print_debug('WMS is installed ', 9);
    END IF;



    /* Get all contexts */
    fnd_dflex.get_contexts(flexfield => l_dflex_r, contexts => l_contexts_dr);

    /* From the l_contexts_dr, get the position of the global context */
    IF g_debug = 1 THEN
      print_debug('Found contexts for the Flexfield Lot Attributes ', 9);
    END IF;

    l_global_context          := l_contexts_dr.global_context;
    /* Using the position get the segments in the global context which are enabled */
    l_context                 := l_contexts_dr.context_code(l_global_context);

    IF g_debug = 1 THEN
      print_debug('In WMS -Global COntext is  ' || l_context, 9);
    END IF;

    /* Prepare the context_r type for getting the segments associated with the global context */
    l_context_r.flexfield     := l_dflex_r;
    l_context_r.context_code  := l_context;
    fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);
    /* read through the segments */
    l_global_nsegments               := l_segments_dr.nsegments;

    IF g_debug = 1 THEN
      print_debug('WMs Installed .The number of segments enabled for Global context are ' || l_nsegments, 9);
    END IF;

    FOR i IN 1 .. l_global_nsegments LOOP
      l_enabled_seg_name(v_index)  := l_segments_dr.application_column_name(i);
      l_value_not_null_flag        := NULL;

      FOR j IN 1 .. lot_dff.COUNT LOOP
        IF UPPER(lot_dff(j).column_name) = UPPER(l_segments_dr.application_column_name(i)) THEN
          IF g_debug = 1 THEN
            print_debug('The segment is ' || UPPER(l_segments_dr.application_column_name(i)), 9);
            print_debug('The column name is ' || lot_dff(j).column_name, 9);
            print_debug('The column value is ' || NVL(lot_dff(j).column_value, NULL), 9);
            print_debug('The column type is ' || NVL(lot_dff(j).column_type, NULL), 9);
          END IF;

          IF lot_dff(j).column_type = 'VARCHAR2' THEN
            fnd_flex_descval.set_column_value(lot_dff(j).column_name, lot_dff(j).column_value);
          ELSIF lot_dff(j).column_type = 'NUMBER' THEN
            fnd_flex_descval.set_column_value(lot_dff(j).column_name, TO_NUMBER(lot_dff(j).column_value));
          ELSIF lot_dff(j).column_type = 'DATE' THEN
            fnd_flex_descval.set_column_value(lot_dff(j).column_name, fnd_date.canonical_to_date(lot_dff(j).column_value));
          END IF;

          IF lot_dff(j).column_value IS NOT NULL THEN
            l_value_not_null_flag  := 1;

            IF g_debug = 1 THEN
              print_debug('Value is not null ', 9);
            END IF;
          ELSE
            l_value_not_null_flag  := 0;

            IF g_debug = 1 THEN
              print_debug('Value is null ', 9);
            END IF;
          END IF;

          EXIT;
        END IF;
      END LOOP;

      IF l_segments_dr.is_required(i)
         AND NVL(l_value_not_null_flag, 0) = 0 THEN
   l_required_flag := true;
        IF g_debug = 1 THEN
          print_debug('The value is required and value is null ' || l_segments_dr.application_column_name(i), 9);
        END IF;

        fnd_message.set_name('INV', 'INV_REQ_SEG_MISS');
        fnd_message.set_token('SEGMENT', l_segments_dr.segment_name(i));
        fnd_msg_pub.ADD;
        RAISE g_exc_error;
      END IF;

      v_index                      := v_index + 1;
    END LOOP;

    /* Initialise the l_context_value to null */
    l_context                 := NULL;

    /*Check if the Lot Attribute Category is passed or not. If not passed
      Get the context for the item passed
    */
    if g_debug = 1 then
   print_debug('p_lot_attribute_category = ' || p_lot_attribute_category, 9);
    end if;
    IF  p_lot_attribute_category IS NOT NULL THEN
   print_debug('setting l_context = ' || p_lot_attribute_category, 9);
      l_context  := p_lot_attribute_category;
    ELSE
      /*Get the context for the item passed */
      inv_lot_sel_attr.get_context_code(l_context, p_organization_id, p_inventory_item_id, 'Lot Attributes');
    END IF;

    IF l_context IS NULL AND l_required_flag = TRUE  THEN
      fnd_message.set_name('WMS', 'WMS_NO_CONTEXT');
      fnd_msg_pub.ADD;
      RAISE g_exc_error;
    END IF;

    IF g_debug = 1 THEN
      print_debug('Context is ' || l_context, 9);
    END IF;

    FOR i in 1..l_contexts_dr.ncontexts LOOP
   if( l_contexts_dr.is_enabled(i) AND  l_context IS NOT NULL AND
      UPPER(l_contexts_dr.context_code(i)) = UPPER(l_context))  THEN
       l_context_enabled := TRUE;
            /* Set flex context for validation of the value set */
            fnd_flex_descval.set_context_value(l_context);
             /* Prepare the context_r type */
            l_context_r.flexfield     := l_dflex_r;
            l_context_r.context_code  := l_context;
            fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);
            /* read through the segments */
            l_nsegments               := 0;
            l_nsegments               := l_segments_dr.nsegments;
            FOR i IN 1 .. l_nsegments LOOP
                l_enabled_seg_name(v_index)  := l_segments_dr.application_column_name(i);
                l_value_not_null_flag        := NULL;

                FOR j IN 1 .. lot_dff.COUNT LOOP
                   IF UPPER(lot_dff(j).column_name) = UPPER(l_segments_dr.application_column_name(i)) THEN
                      IF g_debug = 1 THEN
                         print_debug('The segment is ' || UPPER(l_segments_dr.application_column_name(i)), 9);
                      END IF;

                      IF lot_dff(j).column_type = 'VARCHAR2' THEN
                         fnd_flex_descval.set_column_value(lot_dff(j).column_name, lot_dff(j).column_value);
                  ELSIF lot_dff(j).column_type = 'NUMBER' THEN
                         fnd_flex_descval.set_column_value(lot_dff(j).column_name, TO_NUMBER(lot_dff(j).column_value));
                  ELSIF lot_dff(j).column_type = 'DATE' THEN
                        fnd_flex_descval.set_column_value(lot_dff(j).column_name,
            fnd_date.canonical_to_date(lot_dff(j).column_value));
                  END IF;

                      IF lot_dff(j).column_value IS NOT NULL THEN
                        l_value_not_null_flag  := 1;
                        print_debug('Value is not null', 9);
                  ELSE
                        l_value_not_null_flag  := 0;
                        print_debug('Value is null', 9);
                  END IF;
                  EXIT;
                    END IF;
               END LOOP;

              IF l_segments_dr.is_required(i) AND NVL(l_value_not_null_flag, 0) = 0 THEN
                  IF g_debug = 1 THEN
                     print_debug('Segment is required and value is null', 9);
                  END IF;

                  fnd_message.set_name('INV', 'INV_REQ_SEG_MISS');
                  fnd_message.set_token('SEGMENT', l_segments_dr.segment_name(i));
                  fnd_msg_pub.ADD;
                  RAISE g_exc_error;
              END IF;
              v_index                      := v_index + 1;
          END LOOP;
       END IF;
    END LOOP;
    IF l_context IS NOT NULL AND l_context_enabled = TRUE AND l_global_nsegments > 0 then
       IF fnd_flex_descval.validate_desccols(appl_short_name => 'INV', desc_flex_name => 'Lot Attributes', values_or_ids => 'I'
           , validation_date              => SYSDATE) THEN
          IF g_debug = 1 THEN
             print_debug('Value set validation successful', 9);
             print_debug('Program LOT_DFF_VALIDATE has completed succcessfuly', 9);
          END IF;
       ELSE
          IF g_debug = 1 THEN
             error_segment  := fnd_flex_descval.error_segment;
             print_debug('Value set validation failed for segment ' || error_segment, 9);
             RAISE errors_received;
          END IF;
       END IF;
    end if;
  EXCEPTION
    WHEN g_exc_error THEN
      print_debug('Validation error', 9);
      x_return_status  := inv_lot_api_pub.g_ret_sts_error;
      ROLLBACK TO wms_lot_dff_validate;

      IF g_debug = 1 THEN
        print_debug('Program LOT_DFF_VALIDATE has completed with validation errors', 9);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN errors_received THEN
      x_return_status  := inv_lot_api_pub.g_ret_sts_error;

      IF g_debug = 1 THEN
        print_debug('Program LOT_DFF_VALIDATE has completed with errors_received', 9);
      END IF;

      error_msg        := fnd_flex_descval.error_message;
      s                := 1;
      e                := 200;

      --print_debug('Here are the error messages: ',9);
      WHILE e < 5001
       AND SUBSTR(error_msg, s, e) IS NOT NULL LOOP
        fnd_message.set_name('INV', 'INV_FND_GENERIC_MSG');
        fnd_message.set_token('MSG', SUBSTR(error_msg, s, e));
        fnd_msg_pub.ADD;
        print_debug(SUBSTR(error_msg, s, e), 9);
        s  := s + 200;
        e  := e + 200;
      END LOOP;

      ROLLBACK TO wms_lot_dff_validate;
    WHEN OTHERS THEN
      x_return_status  := inv_lot_api_pub.g_ret_sts_unexp_error;
      ROLLBACK TO wms_lot_dff_validate;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF g_debug = 1 THEN
        print_debug('Program LOT_DFF_VALIDATE has completed with errors. In when others ', 9);
        print_debug('Error ' || SQLERRM, 9);
      END IF;
  END wms_lot_attr_validate;


    ---------------------------------------------------------End Of J Develop--------------------------------
  PROCEDURE set_wms_installed_flag (
   p_wms_installed_flag IN VARCHAR2)
  IS
  BEGIN
        G_WMS_INSTALLED := p_wms_installed_flag;
  END set_wms_installed_flag;



/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    validate_child_lot                                                    |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Joe DiIorio      05/20/2004                                   |
 |                                                                          |
 +==========================================================================+ */


PROCEDURE validate_child_lot
( p_api_version          IN               NUMBER
, p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_organization_id      IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, p_parent_lot_number    IN  VARCHAR2
, p_child_lot_number     IN  VARCHAR2
, x_return_status        OUT NOCOPY       VARCHAR2
, x_msg_count            OUT NOCOPY       NUMBER
, x_msg_data             OUT NOCOPY       VARCHAR2
)
IS


l_api_name               CONSTANT VARCHAR2(30) := 'validate_child_lot';
l_api_version            CONSTANT NUMBER := 1.0;
G_PKG_NAME               CONSTANT VARCHAR2(30) := 'INV_CHILD_LOT_GRP';

/*====================================
   Cursor to get Item Master setup.
  ======================================*/

CURSOR get_item_data IS
SELECT child_lot_flag, parent_child_generation_flag,
       child_lot_prefix, child_lot_validation_flag,
       child_lot_starting_number
FROM   mtl_system_items_b    -- NSRIVAST, Changed the name to MTL_SYSTEM_ITEMS_B as per review comments by Shelly
WHERE  organization_id = p_organization_id
AND    inventory_item_id = p_inventory_item_id;

l_item_child_lot_flag        MTL_SYSTEM_ITEMS.CHILD_LOT_FLAG%TYPE;
l_item_parent_child_gen_flag MTL_SYSTEM_ITEMS.PARENT_CHILD_GENERATION_FLAG%TYPE;
l_item_child_lot_prefix      MTL_SYSTEM_ITEMS.CHILD_LOT_PREFIX%TYPE;
l_item_child_lot_validation  MTL_SYSTEM_ITEMS.CHILD_LOT_VALIDATION_FLAG%TYPE;
l_item_child_lot_startno     MTL_SYSTEM_ITEMS.CHILD_LOT_STARTING_NUMBER%TYPE;
L_ITEM_LOT_LENGTH            CONSTANT NUMBER := 80;


/*====================================
  Cursor to get child mtl parms.
  ====================================*/

CURSOR get_child_parms IS
SELECT lot_number_generation,
       parent_child_generation_flag,
       child_lot_alpha_prefix, child_lot_number_length,
       child_lot_validation_flag, child_lot_zero_padding_flag
FROM   mtl_parameters
WHERE  organization_id = p_organization_id;

l_prm_lot_number_generation   MTL_PARAMETERS.lot_number_generation%TYPE;
l_prm_parent_child_gen_flag   MTL_PARAMETERS.parent_child_generation_flag%TYPE;
l_prm_child_lot_alpha_prefix    MTL_PARAMETERS.child_lot_alpha_prefix%TYPE;
l_prm_child_lot_number_length   MTL_PARAMETERS.child_lot_number_length%TYPE;
l_prm_child_lot_val_flag        MTL_PARAMETERS.child_lot_validation_flag%TYPE;
l_prm_zero_padding_flag         MTL_PARAMETERS.child_lot_zero_padding_flag%TYPE;

l_common_child_gen_flag       MTL_PARAMETERS.parent_child_generation_flag%TYPE;
l_parent_length                 NUMBER;
l_child_prefix_length           NUMBER;
l_child_prefix                  VARCHAR2(30);
l_final_start                   NUMBER;
l_final_length                  NUMBER;
l_final_suffix                  VARCHAR2(80);
l_final_suffix_numeric          NUMBER;
l_child_lot_length              NUMBER;
/*=========================================================
   For overall length if Item controlled lot generation
  it is = 80.  For Org control it is what is specified.
  If not specified, the value is 80.
  =========================================================*/
l_overall_length                NUMBER;

l_num_error EXCEPTION;
PRAGMA EXCEPTION_INIT(l_num_error,-06502);




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
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  /*==========================================
       Get Item Information
    ========================================*/
  OPEN get_item_data;
  FETCH get_item_data INTO
      l_item_child_lot_flag, l_item_parent_child_gen_flag,
      l_item_child_lot_prefix, l_item_child_lot_validation,
      l_item_child_lot_startno;
  IF (get_item_data%NOTFOUND) THEN
     CLOSE get_item_data;
     fnd_message.set_name ('INV' , 'INV_CL_ITEM_ERR');
     fnd_msg_pub.ADD;
     RAISE fnd_api.g_exc_error;
  END IF;
  CLOSE get_item_data;

  /*==========================================
      If Item not autosplit enabled stop.
    ========================================*/
  IF (nvl(l_item_child_lot_flag,'N') = 'N') THEN
       fnd_message.set_name ('INV' , 'INV_CL_CHILD_LOT_DISABLED');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
  END IF;

  /*==========================================
       Get mtl_parameters information.
    ========================================*/

  OPEN get_child_parms;
  FETCH get_child_parms INTO
    l_prm_lot_number_generation, l_prm_parent_child_gen_flag,
    l_prm_child_lot_alpha_prefix,
    l_prm_child_lot_number_length, l_prm_child_lot_val_flag,
    l_prm_zero_padding_flag;
  IF (get_child_parms%NOTFOUND) THEN
     CLOSE get_child_parms;
     fnd_message.set_name ('INV' , 'INV_CL_GET_PARM_ERR');
     fnd_msg_pub.ADD;
     RAISE fnd_api.g_exc_error;
  END IF;
  CLOSE get_child_parms;

  /*==========================================
      If User Level Generation no check is
     required.  Just return.
    ========================================*/

  IF (l_prm_lot_number_generation = 3) THEN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     RETURN;
  END IF;

  /*==========================================
      If Validation is off, just return.
    Values for prm_lot_number_generation.
    1 = org, 2 = item, 3 = user.
    ========================================*/

  IF (l_prm_lot_number_generation = 1) THEN
     l_common_child_gen_flag := l_prm_parent_child_gen_flag;
     IF (nvl(l_prm_child_lot_val_flag,'N') = 'N') THEN
        RETURN;
     END IF;
  ELSE -- must be Item control
     l_common_child_gen_flag := l_item_parent_child_gen_flag;
     IF (nvl(l_item_child_lot_validation,'N') = 'N') THEN
        RETURN;
     END IF;
  END IF;


  /*==========================================
       Validate the Child Lot.
     Get the setup data for validation.
    ========================================*/

   l_parent_length := NVL(LENGTHB(p_parent_lot_number),0);

   IF (l_prm_lot_number_generation = 1) THEN      --org
      l_child_prefix_length := NVL(LENGTHB(l_prm_child_lot_alpha_prefix),0);
      l_child_prefix := l_prm_child_lot_alpha_prefix;
      l_overall_length := NVL(l_prm_child_lot_number_length,80);
   ELSE --item
      l_child_prefix_length := NVL(LENGTHB(l_item_child_lot_prefix),0);
      l_child_prefix := l_item_child_lot_prefix;
      l_overall_length := L_ITEM_LOT_LENGTH;
   END IF;


  /*==========================================
     Check if Parent Lot is prefix to
     Child Lot when Lot+Child generation
     is in effect.
    ========================================*/

   IF (l_common_child_gen_flag = 'C') THEN
      /*===================================================
         Prefix of child lot must match parent lot number.
        ===================================================*/
      IF (p_parent_lot_number = SUBSTRB(p_child_lot_number,1,l_parent_length)) THEN
          /*===================================================
             After the prefix the next characters must match
             the child lot prefix.
            ===================================================*/
         IF (NVL(l_child_prefix,'ZZZZ') = NVL(SUBSTRB(p_child_lot_number, l_parent_length + 1, l_child_prefix_length),'ZZZZ')) THEN
            NULL;
         ELSE
            fnd_message.set_name ('INV' , 'INV_CL_SUFFIX_MISMATCH');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
          fnd_message.set_name ('INV' , 'INV_CL_PREFIX_MISMATCH');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END IF;
   ELSE
      /*=======================================
         For Lot/Lot validation just return.
        =======================================*/
      RETURN;
   END IF;

  /*============================================
     Now check if remaining suffix is numeric.
    ============================================*/


  l_final_start := l_parent_length + NVL(l_child_prefix_length,0) + 1;
  l_final_length := 80 - l_final_start - 1;

  l_final_suffix :=
     SUBSTRB(p_child_lot_number, l_final_start);

  IF (l_final_suffix IS NULL) THEN
     fnd_message.set_name ('INV' , 'INV_CL_SUFFIX_NONUMERIC');
     fnd_msg_pub.ADD;
     RAISE fnd_api.g_exc_error;
  END IF;

  /*============================================
     Exception will trap the following command
     if suffix is not numeric.
    ============================================*/

  l_final_suffix_numeric := TO_NUMBER(l_final_suffix);

  /*===============================================
     Check if padded correctly.  If padding is
     on must verify that total length of suffix
     is correct.  Only done at org level control.
     If Item level check if starting number is
     above suffix number,
    ===============================================*/

  l_child_lot_length := NVL(LENGTHB(p_child_lot_number),0);

  IF (l_prm_lot_number_generation = 1) THEN      --org
     IF (l_prm_zero_padding_flag = 'Y') THEN
         IF (l_overall_length <> l_child_lot_length) THEN
            fnd_message.set_name ('INV' , 'INV_CL_PAD_ERROR');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
     END IF;
  ELSE -- Item
     IF (NVL(l_item_child_lot_startno,0) > l_final_suffix_numeric) THEN
         fnd_message.set_name ('INV' , 'INV_CL_STARTING_SUFFIX_ERR');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
     END IF;
  END IF;

  /*============================================
     Check if total length is correct.
     Item generation child lots can be up to 80
     in length.  For org generated lots the
     length indicated is used. Otherwise use 80.
    ============================================*/

  IF (l_child_lot_length > l_overall_length ) THEN
     fnd_message.set_name ('INV' , 'INV_CL_OVERALL_LENGTH');
     fnd_msg_pub.ADD;
     RAISE fnd_api.g_exc_error;
  END IF;
  RETURN;

EXCEPTION

  WHEN l_num_error  THEN
     fnd_message.set_name ('INV' , 'INV_CL_SUFFIX_NONUMERIC');
     fnd_msg_pub.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
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
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END validate_child_lot;


FUNCTION validate_lot_indivisible
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_transaction_type_id  IN  NUMBER
, p_organization_id      IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, p_revision             IN  VARCHAR2
, p_subinventory_code    IN  VARCHAR2
, p_locator_id           IN  NUMBER
, p_lot_number           IN  VARCHAR2
, p_primary_quantity     IN  NUMBER
, p_qoh                  IN  NUMBER DEFAULT NULL
, p_atr                  IN  NUMBER DEFAULT NULL
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS
    l_primary_quantity  number;
    l_secondary_quantity number; /* Bug#11729772 */
    l_return            boolean;
    CREATE_TREE_ERROR  EXCEPTION;
    QUERY_TREE_ERROR   EXCEPTION;
BEGIN
 /* Fix for Bug#11729772. Added p_secondary_quantity and x_secondary_quantity
       parameters in following call
    */
    l_return := validate_lot_indivisible
                                        ( p_api_version          =>         p_api_version
                                        , p_init_msg_list        =>         p_init_msg_list
                                        , p_commit               =>         p_commit
                                        , p_validation_level     =>         p_validation_level
                                        , p_transaction_type_id  =>         p_transaction_type_id
                                        , p_organization_id      =>         p_organization_id
                                        , p_inventory_item_id    =>         p_inventory_item_id
                                        , p_revision             =>         p_revision
                                        , p_subinventory_code    =>         p_subinventory_code
                                        , p_locator_id           =>         p_locator_id
                                        , p_lot_number           =>         p_lot_number
                                        , p_primary_quantity     =>         p_primary_quantity
                                        , p_secondary_quantity   =>        l_secondary_quantity
                                        , p_qoh                  =>         p_qoh
                                        , p_atr                  =>         p_atr
                                        , x_primary_quantity     =>         l_primary_quantity
					, x_secondary_quantity   =>        l_secondary_quantity
                                        , x_return_status        =>         x_return_status
                                        , x_msg_count            =>         x_msg_count
                                        , x_msg_data             =>         x_msg_data
                                        );
 RETURN l_return;

EXCEPTION

WHEN CREATE_TREE_ERROR THEN
    print_debug(' CREATE_TREE error...');
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
    RETURN FALSE;

WHEN QUERY_TREE_ERROR THEN
    print_debug(' QUERY_TREE error...');
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
    RETURN FALSE;

WHEN FND_API.G_EXC_ERROR THEN
    print_debug(' EXCP error...');
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
    RETURN FALSE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    print_debug(' UNEXCP error...');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
    RETURN FALSE;

WHEN OTHERS THEN
    print_debug(' OTHERS error...'||SQLERRM);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
    RETURN FALSE;

END validate_lot_indivisible;


/*+==========================================================================+
 | PROCEDURE NAME                                                           |
 |    validate_lot_indivisible                                              |
 | This function validates, from the IN parameters,                         |
 | whether a lot transaction can be added into the inventory                |
 | regarding the lot definition.                                            |
 |                                                                          |
 | IN PARAMETERS                                                            |
 | - the transaction details (trx_type, item, org, lot, rev)                |
 | - the primary quantity of the transaction                                |
 | - IF qoh and atr are passed, THEN quantity tree is bypassed.             |
 | - IF qoh and atr are NULL, THEN quantity tree is called (recommanded)    |
 |                                                                          |
 | RETURNS                                                                  |
 |    TRUE if the lot transaction is valid                                  |
 |    FALSE if the lot transaction is NOT valid because of lot indivisible  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  Olivier Daboval  17-Jun-2004                                  |
 |   Bug 4122106 : using p_primary_quantity as an ABS value in the tests    |
 |                                                                          |
 +==========================================================================+ */
FUNCTION validate_lot_indivisible
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_transaction_type_id  IN  NUMBER
, p_organization_id      IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, p_revision             IN  VARCHAR2
, p_subinventory_code    IN  VARCHAR2
, p_locator_id           IN  NUMBER
, p_lot_number           IN  VARCHAR2
, p_lpn_id               IN  NUMBER DEFAULT NULL /*Bug#10113239*/
, p_primary_quantity     IN  NUMBER
, p_secondary_quantity   IN  NUMBER DEFAULT NULL  /* Fix for Bug#11729772 */
, p_qoh                  IN  NUMBER DEFAULT NULL
, p_atr                  IN  NUMBER DEFAULT NULL
, x_primary_quantity     OUT NOCOPY NUMBER
, x_secondary_quantity   OUT NOCOPY NUMBER        /* Fix for Bug#11729772 */
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS


l_api_name               CONSTANT VARCHAR2(30) := 'validate_lot_indivisible';
l_api_version            CONSTANT NUMBER := 1.0;
G_PKG_NAME               CONSTANT VARCHAR2(30) := 'INV_LOT_API_PUB';

l_return                     BOOLEAN;
l_lot_divisible              VARCHAR2(1);
l_lot_control_code           pls_integer;
l_transaction_action_id      NUMBER;
l_transaction_source_type_id NUMBER;

l_return_status       VARCHAR2(2);
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(2000);
l_tree_mode           NUMBER;
l_is_revision_control BOOLEAN;
l_is_lot_control      BOOLEAN;
l_is_serial_control   BOOLEAN;
l_grade_code          VARCHAR2(150) := NULL;
l_check_qties         BOOLEAN;
l_lot_no              VARCHAR2(150) := NULL;

CREATE_TREE_ERROR  EXCEPTION;
QUERY_TREE_ERROR   EXCEPTION;
l_tree_id   INTEGER;
l_qoh       NUMBER;
l_rqoh      NUMBER;
l_qr        NUMBER;
l_qs        NUMBER;
l_att       NUMBER;
l_atr       NUMBER;
l_atr_plus  NUMBER;
l_sqoh      NUMBER;
l_srqoh     NUMBER;
l_sqr       NUMBER;
l_sqs       NUMBER;
l_satt      NUMBER;
l_satr      NUMBER;
ll_qoh       NUMBER;
ll_rqoh      NUMBER;
ll_qr        NUMBER;
ll_qs        NUMBER;
ll_att       NUMBER;
ll_atr       NUMBER;
ll_atr_plus  NUMBER;
ll_sqoh      NUMBER;
ll_srqoh     NUMBER;
ll_sqr       NUMBER;
ll_sqs       NUMBER;
ll_satt      NUMBER;
ll_satr      NUMBER;
l_revision_qty_control_code NUMBER ;   --Bug 12716806
l_revision   mtl_material_transactions.revision%type;    --Bug 12716806

/*====================================
   Get item details:
  - lot_divisible_flag = Y(divisible), N(indivisible), NULL(divisible)
  - lot_control_code   = 1(notLotControlled), 2(lotControlled)
  - revision_qty_control_code = 1(notRevControlled), 2(revControlled)
  ======================================*/
/* Fix for Bug#11729772. Added tracking quantity_ind in following cursor */
CURSOR get_item_details( org_id IN NUMBER
                       , item_id IN NUMBER) IS
SELECT  NVL( lot_divisible_flag, 'Y')
       ,lot_control_code
       ,tracking_quantity_ind
FROM mtl_system_items_b  -- NSRIVAST, Changed the name to MTL_SYSTEM_ITEMS_B as per review comments by Shelly
WHERE organization_id = org_id
AND inventory_item_id = item_id;

l_tracking_quantity_ind VARCHAR2(5);
/*====================================
   Get transaction action from transaction type:
  ======================================*/
CURSOR get_transaction_details( trx_type_id IN NUMBER) IS
SELECT transaction_action_id
, transaction_source_type_id
FROM mtl_transaction_types
WHERE transaction_type_id = trx_type_id;

/*====================================
   Get new lot information:
  ======================================*/
/* Jalaj Srivastava Bug 4634410
   This cursor is no longer used */
/*
CURSOR get_new_lot_details( org_id  IN NUMBER
                          , item_id IN NUMBER
                          , lot_no  IN VARCHAR2) IS
SELECT lot_number
FROM mtl_lot_numbers
WHERE lot_number = lot_no
AND inventory_item_id = item_id
AND organization_id = org_id; */

/*Bug#9717803 any issue transaction other than the misc issue */
CURSOR cur_any_consumptions IS
SELECT 1
FROM mtl_transaction_lot_numbers mtln, mtl_material_transactions mmt
WHERE mtln.organization_id = p_organization_id
AND mtln.inventory_item_id = p_inventory_item_id
AND mtln.lot_number = p_lot_number
AND mtln.transaction_id = mmt.transaction_id
AND (mmt.transaction_action_id = 1 and mmt.transaction_type_id not in (1));
l_exists NUMBER;
BEGIN

print_debug('Entering validate_lot_indivisible. transaction_type_id='||p_transaction_type_id||', prim_qty='||p_primary_quantity||'.');
print_debug(' ... org='||p_organization_id||', item='||p_inventory_item_id||', rev='||p_revision||', sub='||p_subinventory_code||', loct='||p_locator_id);
print_debug(' ... lot='||p_lot_number||', p_qoh='||p_qoh||', p_atr='||p_atr);

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*==========================================
    Get item details:
    ========================================*/
  OPEN get_item_details( p_organization_id, p_inventory_item_id);
  FETCH get_item_details
   INTO l_lot_divisible,l_lot_control_code,l_tracking_quantity_ind ; /* Fix for Bug#11729772 */
  IF (get_item_details%NOTFOUND)
  THEN
    CLOSE get_item_details;
    FND_MESSAGE.SET_NAME('INV','ITEM_NOT_FOUND');
    FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', p_organization_id);
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inventory_item_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_item_details;

  /* Jalaj Srivastava Bug 4634410
     We should always validate
     because same indivisible lot could be created
     in 2 lines in diff sub/loc.
     commented new lot logic below*/
    /*==========================================
      Get new lot details:
      ========================================*/
    /*
    OPEN get_new_lot_details(p_organization_id, p_inventory_item_id, p_lot_number);
    FETCH get_new_lot_details
     INTO l_lot_no;

    IF (get_new_lot_details%NOTFOUND)
    THEN
      -- The lot is a NEW lot.... The trx is always valid.
      print_debug(' the lot is NEW. trx valid always.');
      l_new_lot := TRUE;
    ELSE
      print_debug(' the lot is NOT NEW. More check to follow.');
      l_new_lot := FALSE;
    END IF;
    CLOSE get_new_lot_details;
    */

  IF (l_lot_control_code = 2 AND l_lot_divisible = 'N' AND p_lot_number IS NOT NULL)
  THEN
    print_debug(' the lot is NOT divisible... Return can be false.');
    /*==========================================
      Get transaction details:
      ========================================*/
    OPEN get_transaction_details(p_transaction_type_id);
    FETCH get_transaction_details
     INTO l_transaction_action_id
        , l_transaction_source_type_id;
    IF (get_transaction_details%NOTFOUND)
    THEN
      CLOSE get_transaction_details;
      FND_MESSAGE.SET_NAME('INV','TRX_TYPE_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE_ID', p_transaction_type_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_transaction_details;

print_debug('... transaction_type_id='||p_transaction_type_id||', trx_action='||l_transaction_action_id||', trx_source_type='||l_transaction_source_type_id);

    /*==========================================
      If check quantities is needed, then calls Quantity Tree:
      ========================================*/
    IF (p_qoh IS NULL or p_atr IS NULL)
    THEN
       l_check_qties := TRUE;
    END IF;

    IF (l_check_qties = TRUE)
    THEN
       print_debug('Checking the quantities');
      /*==========================================
        Set local variables from given parameters
        ========================================*/
      -- I think that p_transaction_type_id is NEVER NULL !!!!.
      IF (p_transaction_type_id IS NOT NULL)
      THEN
         -- Transaction mode
         l_tree_mode := 2;
      ELSE
         --Reservation mode
         l_tree_mode := 1;
      END IF;

      IF (p_revision IS NOT NULL)
      THEN
         l_is_revision_control := TRUE;
      ELSE
         l_is_revision_control := FALSE;
      END IF;

      IF (p_lot_number IS NOT NULL)
      THEN
         l_is_lot_control := TRUE;
      ELSE
         l_is_lot_control := FALSE;
      END IF;

      l_is_serial_control := FALSE;

      /**Begin Bug 12716806 */
       l_revision :=  p_revision;
       IF (p_transaction_type_id = 36 AND p_revision IS NOT NULL) THEN

         SELECT  Nvl(revision_qty_control_code,1)
         INTO    l_revision_qty_control_code
         FROM    mtl_system_items
         WHERE  inventory_item_id =  p_inventory_item_id
         AND  organization_id   =  p_organization_id;

         print_debug('In going into RTV get item revision  revision_qty_control_code: '
                   || l_revision_qty_control_code
                   || ', p_revision : '  ||  p_revision);

         IF l_revision_qty_control_code = 1 THEN
            l_is_revision_control := FALSE;
            l_revision := NULL;
         END IF ;

       END IF;

        /**End Bug 12716806 */

      /*==========================================
         Call Quantity Tree for checking whether
         it is possible to generate a transation for this lot.
        ========================================*/
        /* Jalaj Srivastava Bug 4634410
           commenting code below.
           we will call INV_QUANTITY_TREE_PUB to query quantities */
      /*
      print_debug('Calling  INV_QUANTITY_TREE_GRP.CREATE_TREE api');
      INV_QUANTITY_TREE_GRP.CREATE_TREE
          ( p_api_version_number         =>   p_api_version
          , p_init_msg_lst               =>   p_init_msg_list
          , x_return_status              =>   l_return_status
          , x_msg_count                  =>   l_msg_count
          , x_msg_data                   =>   l_msg_data
          , p_organization_id            =>   p_organization_id
          , p_inventory_item_id          =>   p_inventory_item_id
          , p_tree_mode                  =>   l_tree_mode
          , p_is_revision_control        =>   l_is_revision_control
          , p_is_lot_control             =>   l_is_lot_control
          , p_is_serial_control          =>   l_is_serial_control
          , p_grade_code                 =>   l_grade_code
          , p_demand_source_type_id      =>   13
          , p_demand_source_header_id    => -1
          , p_demand_source_line_id      => -1
          , p_demand_source_name         => -1
          , p_lot_expiration_date        =>   sysdate
          , p_onhand_source              =>   3
          , x_tree_id                    =>   l_tree_id);

      print_debug('return status  INV_QUANTITY_TREE_GRP.CREATE_TREE api'||l_return_status);
--       NSRIVAST, using  <> as per GSCC compliance
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
         print_debug('Returning error from INV_QUANTITY_TREE_GRP.CREATE_TREE');
         RAISE CREATE_TREE_ERROR;
      END IF;
      */
      print_debug('Calling  INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES api');
      INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES
          ( p_api_version_number         =>   p_api_version
          , p_init_msg_lst               =>   p_init_msg_list
          , x_return_status              =>   l_return_status
          , x_msg_count                  =>   l_msg_count
          , x_msg_data                   =>   l_msg_data
          , p_tree_mode                  =>   l_tree_mode
          , p_organization_id            =>   p_organization_id
          , p_inventory_item_id          =>   p_inventory_item_id
          , p_is_revision_control        =>   l_is_revision_control
          , p_is_lot_control             =>   l_is_lot_control
          , p_is_serial_control          =>   l_is_serial_control
          , p_grade_code                 =>   l_grade_code
          , p_revision                   =>   l_revision  --p_revision  Bug 12716806
          , p_lot_number                 =>   p_lot_number
          , p_subinventory_code          =>   NULL -- p_subinventory_code  Bug# 4233182 pass null instead of p_subinventory_code
          , p_locator_id                 =>   NULL -- p_locator_id Bug# 4233182 pass null instead of p_locator_id
          , x_qoh                        =>   l_qoh
          , x_rqoh                       =>   l_rqoh
          , x_qr                         =>   l_qr
          , x_qs                         =>   l_qs
          , x_att                        =>   l_att
          , x_atr                        =>   l_atr
          , x_sqoh                       =>   l_sqoh
          , x_srqoh                      =>   l_srqoh
          , x_sqr                        =>   l_sqr
          , x_sqs                        =>   l_sqs
          , x_satt                       =>   l_satt
          , x_satr                       =>   l_satr
         );

      print_debug('Return Status   INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES api'||l_return_status);
      print_debug(' onhand='||l_qoh||' l_atr --> '||l_atr);
      --Returning quantity to calling procedure
      x_primary_quantity := l_qoh;
    /* Start fix for Bug 11729772 */
      --
      x_secondary_quantity := NULL;
      IF (l_tracking_quantity_ind = 'PS') THEN
         x_secondary_quantity := l_sqoh;
      END IF;

--      NSRIVAST, using <> as per GSCC compliance
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
         print_debug('Returning error from INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
         RAISE QUERY_TREE_ERROR;
      END IF;

    ELSE
       -- the quantities are passed as parameters
       l_qoh := p_qoh;
       l_atr := p_atr;
    END IF;  -- l_check_qties

     print_debug(' l_qoh -->'||l_qoh||' l_atr --> '||l_atr);
    /*==========================================
      Compare values of transaction_source and transaction_action
      and then decide whether the new transaction is allowed

      ========================================*/
    -- action 1 = issue
    -- action 2 = subinv transfer
    -- action 3 = direct org transfer
    -- action 28 = staging transfer
    -- action 32 = assembly return
    -- action 34 = negative component return
    -- transaction_type_id = 32 (Misc Issue), always return VALID TRX if enough onhand.
    -- l_transaction_action_id  50,51,52 PACK,UNPACK,SPLIT. --Bug 4218736
    IF ( l_transaction_action_id IN ( 2, 3, 32, 34, 28)
     OR (l_transaction_action_id = 1 AND p_transaction_type_id NOT IN ( 1, 32) ) )
     OR (l_transaction_action_id IN ( 50,51,52) )
     OR (p_transaction_type_id=21 AND l_transaction_action_id=21 AND l_transaction_source_type_id=13 ) --Bug#10205679
    THEN
       print_debug('within case 1 : Must issue the full onhand qty');
       -- bug 4122106 : added ABS in the test.
       IF (ABS(p_primary_quantity) <> l_qoh
                OR (p_secondary_quantity IS NOT NULL AND ABS(p_secondary_quantity) <> l_sqoh)) /* Fix for Bug#11729772 */
       THEN
--          print_debug('INV_LOT_INDIV_QTY_ISSUE_CASE_1');
            print_debug('INV_LOT_INDIVISIBLE_VIOLATION');
          --l_error_exp := FND_MESSAGE.GET;
          FND_MESSAGE.SET_NAME('INV','INV_LOT_INDIVISIBLE_VIOLATION'); -- bug 4121709
--          FND_MESSAGE.SET_TOKEN('QOH',l_qoh);
          FND_MSG_PUB.ADD;
          --l_error_code := FND_MESSAGE.GET;
          /* Update MTI table with error code/explanation */
          --errupdate(p_rowid);
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

--    IF ( p_transaction_type_id = 32 )
--    THEN
--       print_debug('within case 1.1 : Misc Issue. Can issue less than onhand qty');
--       IF (p_primary_quantity > l_qoh )
--       THEN
--          print_debug('INV_LOT_INDIV_QTY_ISSUE_CASE_1.1');
--          --l_error_exp := FND_MESSAGE.GET;
--          FND_MESSAGE.SET_NAME('INV','INV_LOT_INDIV_QTY_ISSUE_CASE_1.1');
--          FND_MSG_PUB.ADD;
--          --l_error_code := FND_MESSAGE.GET;
--          /* Update MTI table with error code/explanation */
--          --errupdate(p_rowid);
--          RAISE FND_API.G_EXC_ERROR;
--       END IF;
--    END IF;

    -- action 27 = Receipt into store
    /*Bug#5465377 added transaction action id 41 for lot merge so that
      it checks for lot indivisibility for lot merge also. */
      --bug 4648937 kbanddyo...included id 31 in the if condition below to restrict user from doing a WIP completion for lot indivisible item into diff subinv/loc
    IF (l_transaction_action_id IN (27,41,31) )
    THEN
       /* Bug 9903477 Following IF condition added so that fix for bug 9717803 is restricted only to WIP txns */
       IF l_transaction_action_id = 31 THEN
          /* Bug#9717803 Check if there are any consumption transactions before yielding */
          OPEN  cur_any_consumptions;
          FETCH cur_any_consumptions INTO l_exists;
          CLOSE cur_any_consumptions;

          IF l_exists = 1 THEN
             FND_MESSAGE.SET_NAME('INV','INV_LOT_INDIVISIBLE_VIOLATION');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

      -- test if some inventory exist at lowest level
      -- if some inventory ALREADY exists for that sub/loct/lot, then that's fine. trx accepted
      -- IF ( l_atr = 0 )
      -- BUG 4146697 -- Changed the check to compare Onhand > 0.
      IF ( l_qoh > 0 )
      THEN
       -- No inventory for sub/loct/lot, then, need to search somewhere-else :
       -- Going to see whether, for that lot the qty is the same at node=lot
       print_debug('within case 2 prim_qty='||p_primary_quantity||', atr='||l_atr);

       INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES
          ( p_api_version_number         =>   p_api_version
          , p_init_msg_lst               =>   p_init_msg_list
          , x_return_status              =>   l_return_status
          , x_msg_count                  =>   l_msg_count
          , x_msg_data                   =>   l_msg_data
          , p_tree_mode                  =>   l_tree_mode
          , p_organization_id            =>   p_organization_id
          , p_inventory_item_id          =>   p_inventory_item_id
          , p_is_revision_control        =>   l_is_revision_control
          , p_is_lot_control             =>   l_is_lot_control
          , p_is_serial_control          =>   l_is_serial_control
          , p_grade_code                 =>   l_grade_code
          , p_revision                   =>   p_revision
          , p_lot_number                 =>   p_lot_number
          , p_subinventory_code          =>   p_subinventory_code -- NULL Bug# 4233182 removed null and passed p_subinventory_code
          , p_locator_id                 =>   p_locator_id -- NULL Bug# 4233182 removed null and passed p_locator_id
          , p_lpn_id                     =>   p_lpn_id  /*Bug#10113239*/
          , x_qoh                        =>   ll_qoh
          , x_rqoh                       =>   ll_rqoh
          , x_qr                         =>   ll_qr
          , x_qs                         =>   ll_qs
          , x_att                        =>   ll_att
          , x_atr                        =>   ll_atr_plus
          , x_sqoh                       =>   ll_sqoh
          , x_srqoh                      =>   ll_srqoh
          , x_sqr                        =>   ll_sqr
          , x_sqs                        =>   ll_sqs
          , x_satt                       =>   ll_satt
          , x_satr                       =>   ll_satr
         );

       -- returning primary quantity to calling procedure
       x_primary_quantity := l_qoh;

--      NSRIVAST, using <> as per GSCC compliance
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
       THEN
         print_debug('Returning error from INV_QUANTITY_TREE_GRP.QUERY_TREE');
         RAISE QUERY_TREE_ERROR;
       END IF;

       print_debug('within case A prim_qty='||p_primary_quantity||', atr='||l_atr||', ll_atr_Plus='||ll_atr_plus);

        -- Check Qties at Lot level
       -- IF ( ll_atr_plus > 0 )
       -- Bug 4146697 - Modified Condition.
       --IF ( ll_atr_plus <> l_atr ) -- This means that Inventory was found in a
            -- a different location.
       IF ( ll_qoh <> l_qoh ) --Bug#5469430
       THEN
          print_debug('INV_LOT_INDIV_QTY_RCPT_CASE_2');
          --l_error_exp := FND_MESSAGE.GET;
          FND_MESSAGE.SET_NAME('INV','INV_LOT_INDIV_QTY_RCPT_CASE_2');
          FND_MSG_PUB.ADD;
          --l_error_expp := FND_MESSAGE.GET;
          /* Update MTI table with error code/explanation */
          --errupdate(p_rowid);
          RAISE FND_API.G_EXC_ERROR;
       END IF;   -- ( ll_atr = 0 )
      -- bug 4042255 : added forgotten ELSE clause :
       -- Bug 4146697 - Removed ELSE condition below.
        -- ELSE
        -- print_debug('within case 3 Some Qty already available to reserve. prim_qty='||p_primary_quantity||', atr='||l_atr);
        -- FND_MESSAGE.SET_NAME('INV','INV_LOT_INDIV_QTY_RCPT_CASE_3');
        -- FND_MSG_PUB.ADD;

        -- RAISE FND_API.G_EXC_ERROR;
      END IF;   -- ( l_atr = 0 )

      IF ( l_qr > 0 )
      THEN
       print_debug('within case 3 Some Qty already reserved. prim_qty='||p_primary_quantity||', qr='||l_qr);

          print_debug('INV_LOT_INDIV_QTY_RCPT_CASE_3');
          --l_error_exp := FND_MESSAGE.GET;
          FND_MESSAGE.SET_NAME('INV','INV_LOT_INDIV_QTY_RCPT_CASE_3');
          FND_MSG_PUB.ADD;
          --l_error_expp := FND_MESSAGE.GET;
          /* Update MTI table with error code/explanation */
          --errupdate(p_rowid);
          RAISE FND_API.G_EXC_ERROR;
      END IF;   -- ( l_qr > 0 )
    END IF;   -- l_transaction_action_id IN (27)
    l_return := TRUE;

    -- action 12 = Intransit Receipt
    -- action 30 = WIP Scrap Transaction
    -- action 31 = Assembly Completion
    -- Before IF (l_transaction_action_id IN ( 12, 27, 30, 31) )
    IF (l_transaction_action_id IN ( 12, 30, 31) )
    THEN
       -- print_debug('within case 4 prim_qty='||p_primary_quantity||', atr='||l_atr);
       print_debug('within case 4 prim_qty= '||p_primary_quantity||', l_qr= ' || l_qr);
       -- bug 4122106 : added ABS in the test.
       -- IF (ABS(p_primary_quantity) <> l_atr )
      -- fabdi bug 4486488 changes
      IF ( l_qr > 0 )
       THEN
         -- print_debug('INV_LOT_INDIV_QTY_RCPT_CASE_4');
        print_debug('INV_LOT_INDIV_QTY_RCPT_CASE_3');
          --l_error_exp := FND_MESSAGE.GET;
         -- FND_MESSAGE.SET_NAME('INV','INV_LOT_INDIV_QTY_RCPT_CASE_4');
         ---FND_MESSAGE.SET_TOKEN('ATR',l_atr);
         -- FND_MSG_PUB.ADD;
          FND_MESSAGE.SET_NAME('INV','INV_LOT_INDIV_QTY_RCPT_CASE_3');
          FND_MSG_PUB.ADD;
          --l_error_expp := FND_MESSAGE.GET;
          /* Update MTI table with error code/explanation */
          --errupdate(p_rowid);
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    l_return := TRUE;
  ELSE
    print_debug(' the lot is either divisible or new... Return TRUE.');
    l_return := TRUE;
  END IF;   -- lot_divisible

  RETURN l_return;

EXCEPTION

WHEN CREATE_TREE_ERROR THEN
    print_debug(' CREATE_TREE error...');
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
    RETURN FALSE;

WHEN QUERY_TREE_ERROR THEN
    print_debug(' QUERY_TREE error...');
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
    RETURN FALSE;

WHEN FND_API.G_EXC_ERROR THEN
    print_debug(' EXCP error...');
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
    RETURN FALSE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    print_debug(' UNEXCP error...');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
    RETURN FALSE;

WHEN OTHERS THEN
    print_debug(' OTHERS error...'||SQLERRM);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
    RETURN FALSE;

END validate_lot_indivisible;



  PROCEDURE create_inv_lot(
    x_return_status          OUT    NOCOPY VARCHAR2
  , x_msg_count              OUT    NOCOPY NUMBER
  , x_msg_data               OUT    NOCOPY VARCHAR2
  , p_inventory_item_id      IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_lot_number             IN     VARCHAR2
  , p_expiration_date        IN     DATE
  , p_disable_flag           IN     NUMBER
  , p_attribute_category     IN     VARCHAR2
  , p_lot_attribute_category IN     VARCHAR2
  , p_attributes_tbl         IN     inv_lot_api_pub.char_tbl
  , p_c_attributes_tbl       IN     inv_lot_api_pub.char_tbl
  , p_n_attributes_tbl       IN     inv_lot_api_pub.number_tbl
  , p_d_attributes_tbl       IN     inv_lot_api_pub.date_tbl
  , p_grade_code             IN     VARCHAR2
  , p_origination_date       IN     DATE
  , p_date_code              IN     VARCHAR2
  , p_status_id              IN     NUMBER
  , p_change_date            IN     DATE
  , p_age                    IN     NUMBER
  , p_retest_date            IN     DATE
  , p_maturity_date          IN     DATE
  , p_item_size              IN     NUMBER
  , p_color                  IN     VARCHAR2
  , p_volume                 IN     NUMBER
  , p_volume_uom             IN     VARCHAR2
  , p_place_of_origin        IN     VARCHAR2
  , p_best_by_date           IN     DATE
  , p_length                 IN     NUMBER
  , p_length_uom             IN     VARCHAR2
  , p_recycled_content       IN     NUMBER
  , p_thickness              IN     NUMBER
  , p_thickness_uom          IN     VARCHAR2
  , p_width                  IN     NUMBER
  , p_width_uom              IN     VARCHAR2
  , p_territory_code         IN     VARCHAR2
  , p_supplier_lot_number    IN     VARCHAR2
  , p_vendor_name            IN     VARCHAR2
  , p_source                 IN     NUMBER
  , p_init_msg_list          IN     VARCHAR2 DEFAULT fnd_api.g_false --bug 7513308
  ) IS


   /* Defined new variables for overloaded API call */

   l_in_lot_rec            MTL_LOT_NUMBERS%ROWTYPE;
   l_out_lot_rec        MTL_LOT_NUMBERS%ROWTYPE;
   x_lot_rec                       MTL_LOT_NUMBERS%ROWTYPE;
   l_api_version        NUMBER;
   l_init_msg_list         VARCHAR2(100);
   l_commit          VARCHAR2(100);
   l_validation_level         NUMBER;
   l_origin_txn_id         NUMBER;
   l_source                        NUMBER;
   l_return_status                 VARCHAR2(1)  ;
   l_msg_data                      VARCHAR2(3000)  ;
   l_msg_count                     NUMBER    ;
   l_row_id                        ROWID  ;
  BEGIN
     SAVEPOINT inv_lot;
     x_return_status  := fnd_api.g_ret_sts_success;

     /* Populating the variables and calling the new overloaded API  */

     l_in_lot_rec.inventory_item_id             :=   p_inventory_item_id;
     l_in_lot_rec.organization_id               :=   p_organization_id;
     l_in_lot_rec.lot_number                    :=   p_lot_number;
     l_in_lot_rec.parent_lot_number             :=   NULL;
     l_in_lot_rec.expiration_date               :=   p_expiration_date;
     l_in_lot_rec.disable_flag                  :=   p_disable_flag;
     l_in_lot_rec.attribute_category            :=   p_attribute_category;
     l_in_lot_rec.lot_attribute_category        :=   p_lot_attribute_category;
     l_in_lot_rec.grade_code                    :=   p_grade_code;
     l_in_lot_rec.origination_date              :=   p_origination_date;
     l_in_lot_rec.date_code                     :=   p_date_code;
     l_in_lot_rec.status_id                     :=   p_status_id;
     l_in_lot_rec.change_date                   :=   p_change_date;
     l_in_lot_rec.age                           :=   p_age;
     l_in_lot_rec.retest_date                   :=   p_retest_date;
     l_in_lot_rec.maturity_date                 :=   p_maturity_date;
     l_in_lot_rec.item_size                     :=   p_item_size;
     l_in_lot_rec.color                         :=   p_color;
     l_in_lot_rec.volume                        :=   p_volume;
     l_in_lot_rec.volume_uom                    :=   p_volume_uom;
     l_in_lot_rec.place_of_origin               :=   p_place_of_origin;
     l_in_lot_rec.best_by_date                  :=   p_best_by_date;
     l_in_lot_rec.length                        :=   p_length;
     l_in_lot_rec.length_uom                    :=   p_length_uom;
     l_in_lot_rec.recycled_content              :=   p_recycled_content;
     l_in_lot_rec.thickness                     :=   p_thickness;
     l_in_lot_rec.thickness_uom                 :=   p_thickness_uom;
     l_in_lot_rec.width                         :=   p_width;
     l_in_lot_rec.width_uom                     :=   p_width_uom;
     l_in_lot_rec.territory_code                :=   p_territory_code;
     l_in_lot_rec.supplier_lot_number           :=   p_supplier_lot_number;
     l_in_lot_rec.vendor_name                   :=   p_vendor_name;
     l_in_lot_rec.creation_date             :=   SYSDATE;
     l_in_lot_rec.last_update_date          :=   SYSDATE ;
     l_in_lot_rec.created_by             :=   FND_GLOBAL.USER_ID;
     l_in_lot_rec.last_updated_by           :=   FND_GLOBAL.USER_ID;
     l_in_lot_rec.last_update_login             :=   FND_GLOBAL.LOGIN_ID;
     --BUG 4748451: if the p%tbl are not initialized, then a no_date_found
     --exception would be thrown if accessed.  So add clause to check for this
     IF (p_attributes_tbl.exists(1)) THEN
       l_in_lot_rec.attribute1                    :=   p_attributes_tbl(1);
     END IF;
     IF (p_attributes_tbl.exists(2)) THEN
       l_in_lot_rec.attribute2                    :=   p_attributes_tbl(2);
     END IF;
     IF (p_attributes_tbl.exists(3)) THEN
       l_in_lot_rec.attribute3                    :=   p_attributes_tbl(3);
     END IF;
     IF (p_attributes_tbl.exists(4)) THEN
       l_in_lot_rec.attribute4                    :=   p_attributes_tbl(4);
     END IF;
     IF (p_attributes_tbl.exists(5)) THEN
       l_in_lot_rec.attribute5                    :=   p_attributes_tbl(5);
     END IF;
     IF (p_attributes_tbl.exists(6)) THEN
       l_in_lot_rec.attribute6                    :=   p_attributes_tbl(6);
     END IF;
     IF (p_attributes_tbl.exists(7)) THEN
       l_in_lot_rec.attribute7                    :=   p_attributes_tbl(7);
     END IF;
     IF (p_attributes_tbl.exists(8)) THEN
       l_in_lot_rec.attribute8                    :=   p_attributes_tbl(8);
     END IF;
     IF (p_attributes_tbl.exists(9)) THEN
       l_in_lot_rec.attribute9                    :=   p_attributes_tbl(9);
     END IF;
     IF (p_attributes_tbl.exists(10)) THEN
       l_in_lot_rec.attribute10                   :=   p_attributes_tbl(10);
     END IF;
     IF (p_attributes_tbl.exists(11)) THEN
       l_in_lot_rec.attribute11                   :=   p_attributes_tbl(11);
     END IF;
     IF (p_attributes_tbl.exists(12)) THEN
       l_in_lot_rec.attribute12                   :=   p_attributes_tbl(12);
     END IF;
     IF (p_attributes_tbl.exists(13)) THEN
       l_in_lot_rec.attribute13                   :=   p_attributes_tbl(13);
     END IF;
     IF (p_attributes_tbl.exists(14)) THEN
       l_in_lot_rec.attribute14                   :=   p_attributes_tbl(14);
     END IF;
     IF (p_attributes_tbl.exists(15)) THEN
       l_in_lot_rec.attribute15                   :=   p_attributes_tbl(15);
     END IF;
     IF (p_c_attributes_tbl.exists(1)) THEN
       l_in_lot_rec.c_attribute1                  :=   p_c_attributes_tbl(1);
     END IF;
     IF (p_c_attributes_tbl.exists(2)) THEN
       l_in_lot_rec.c_attribute2                  :=   p_c_attributes_tbl(2);
     END IF;
     IF (p_c_attributes_tbl.exists(3)) THEN
       l_in_lot_rec.c_attribute3                  :=   p_c_attributes_tbl(3);
     END IF;
     IF (p_c_attributes_tbl.exists(4)) THEN
       l_in_lot_rec.c_attribute4                  :=   p_c_attributes_tbl(4);
     END IF;
     IF (p_c_attributes_tbl.exists(5)) THEN
       l_in_lot_rec.c_attribute5                  :=   p_c_attributes_tbl(5);
     END IF;
     IF (p_c_attributes_tbl.exists(6)) THEN
       l_in_lot_rec.c_attribute6                  :=   p_c_attributes_tbl(6);
     END IF;
     IF (p_c_attributes_tbl.exists(7)) THEN
       l_in_lot_rec.c_attribute7                  :=   p_c_attributes_tbl(7);
     END IF;
     IF (p_c_attributes_tbl.exists(8)) THEN
       l_in_lot_rec.c_attribute8                  :=   p_c_attributes_tbl(8);
     END IF;
     IF (p_c_attributes_tbl.exists(9)) THEN
       l_in_lot_rec.c_attribute9                  :=   p_c_attributes_tbl(9);
     END IF;
     IF (p_c_attributes_tbl.exists(10)) THEN
       l_in_lot_rec.c_attribute10                 :=   p_c_attributes_tbl(10);
     END IF;
     IF (p_c_attributes_tbl.exists(11)) THEN
       l_in_lot_rec.c_attribute11                 :=   p_c_attributes_tbl(11);
     END IF;
     IF (p_c_attributes_tbl.exists(12)) THEN
       l_in_lot_rec.c_attribute12                 :=   p_c_attributes_tbl(12);
     END IF;
     IF (p_c_attributes_tbl.exists(13)) THEN
       l_in_lot_rec.c_attribute13                 :=   p_c_attributes_tbl(13);
     END IF;
     IF (p_c_attributes_tbl.exists(14)) THEN
       l_in_lot_rec.c_attribute14                 :=   p_c_attributes_tbl(14);
     END IF;
     IF (p_c_attributes_tbl.exists(15)) THEN
       l_in_lot_rec.c_attribute15                 :=   p_c_attributes_tbl(15);
     END IF;
     IF (p_c_attributes_tbl.exists(16)) THEN
       l_in_lot_rec.c_attribute16                 :=   p_c_attributes_tbl(16);
     END IF;
     IF (p_c_attributes_tbl.exists(17)) THEN
       l_in_lot_rec.c_attribute17                 :=   p_c_attributes_tbl(17);
     END IF;
     IF (p_c_attributes_tbl.exists(18)) THEN
       l_in_lot_rec.c_attribute18                 :=   p_c_attributes_tbl(18);
     END IF;
     IF (p_c_attributes_tbl.exists(19)) THEN
       l_in_lot_rec.c_attribute19                 :=   p_c_attributes_tbl(19);
     END IF;
     IF (p_c_attributes_tbl.exists(20)) THEN
       l_in_lot_rec.c_attribute20                 :=   p_c_attributes_tbl(20);
     END IF;
     IF (p_n_attributes_tbl.exists(1)) THEN
       l_in_lot_rec.n_attribute1                  :=   p_n_attributes_tbl(1);
     END IF;
     IF (p_n_attributes_tbl.exists(2)) THEN
       l_in_lot_rec.n_attribute2                  :=   p_n_attributes_tbl(2);
     END IF;
     IF (p_n_attributes_tbl.exists(3)) THEN
       l_in_lot_rec.n_attribute3                  :=   p_n_attributes_tbl(3);
     END IF;
     IF (p_n_attributes_tbl.exists(4)) THEN
       l_in_lot_rec.n_attribute4                  :=   p_n_attributes_tbl(4);
     END IF;
     IF (p_n_attributes_tbl.exists(5)) THEN
       l_in_lot_rec.n_attribute5                  :=   p_n_attributes_tbl(5);
     END IF;
     IF (p_n_attributes_tbl.exists(6)) THEN
       l_in_lot_rec.n_attribute6                  :=   p_n_attributes_tbl(6);
     END IF;
     IF (p_n_attributes_tbl.exists(7)) THEN
       l_in_lot_rec.n_attribute7                  :=   p_n_attributes_tbl(7);
     END IF;
     IF (p_n_attributes_tbl.exists(8)) THEN
       l_in_lot_rec.n_attribute8                  :=   p_n_attributes_tbl(8);
     END IF;
     IF (p_n_attributes_tbl.exists(9)) THEN
       l_in_lot_rec.n_attribute9                  :=   p_n_attributes_tbl(9);
     END IF;
     IF (p_n_attributes_tbl.exists(10)) THEN
       l_in_lot_rec.n_attribute10                 :=   p_n_attributes_tbl(10);
     END IF;
     IF (p_d_attributes_tbl.exists(1)) THEN
       l_in_lot_rec.d_attribute1                  :=   p_d_attributes_tbl(1);
     END IF;
     IF (p_d_attributes_tbl.exists(2)) THEN
       l_in_lot_rec.d_attribute2                  :=   p_d_attributes_tbl(2);
     END IF;
     IF (p_d_attributes_tbl.exists(3)) THEN
       l_in_lot_rec.d_attribute3                  :=   p_d_attributes_tbl(3);
     END IF;
     IF (p_d_attributes_tbl.exists(4)) THEN
       l_in_lot_rec.d_attribute4                  :=   p_d_attributes_tbl(4);
     END IF;
     IF (p_d_attributes_tbl.exists(5)) THEN
       l_in_lot_rec.d_attribute5                  :=   p_d_attributes_tbl(5);
     END IF;
     IF (p_d_attributes_tbl.exists(6)) THEN
       l_in_lot_rec.d_attribute6                  :=   p_d_attributes_tbl(6);
     END IF;
     IF (p_d_attributes_tbl.exists(7)) THEN
       l_in_lot_rec.d_attribute7                  :=   p_d_attributes_tbl(7);
     END IF;
     IF (p_d_attributes_tbl.exists(8)) THEN
       l_in_lot_rec.d_attribute8                  :=   p_d_attributes_tbl(8);
     END IF;
     IF (p_d_attributes_tbl.exists(9)) THEN
       l_in_lot_rec.d_attribute9                  :=   p_d_attributes_tbl(9);
     END IF;
     IF (p_d_attributes_tbl.exists(10)) THEN
       l_in_lot_rec.d_attribute10                 :=   p_d_attributes_tbl(10);
     END IF;
     --END BUG 4748451

     -- Bug 7513308
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
     END IF;

     l_source                                   :=   p_source;
     l_api_version                              :=   1.0;
     l_init_msg_list                            :=   p_init_msg_list; --fnd_api.g_false; bug 7513308
     l_commit                                   :=   fnd_api.g_false;
     l_validation_level                         :=   fnd_api.g_valid_level_full;
     l_origin_txn_id                            :=   NULL;



     /* Calling the overloaded procedure */
      Create_Inv_lot(
            x_return_status     =>     l_return_status
          , x_msg_count         =>     l_msg_count
          , x_msg_data          =>     l_msg_data
          , x_row_id            =>     l_row_id
          , x_lot_rec           =>     x_lot_rec
          , p_lot_rec           =>     l_in_lot_rec
          , p_source            =>     p_source
          , p_api_version       =>     l_api_version
          , p_init_msg_list     =>     l_init_msg_list
          , p_commit            =>     l_commit
          , p_validation_level  =>     l_validation_level
          , p_origin_txn_id     =>     l_origin_txn_id
           );

          IF g_debug = 1 THEN
              print_debug('Program Create_Inv_lot return ' || l_return_status, 9);
          END IF;
          IF l_return_status = fnd_api.g_ret_sts_error THEN
            IF g_debug = 1 THEN
              print_debug('Program Create_Inv_lot has failed with a user defined exception', 9);
            END IF;
            RAISE g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF g_debug = 1 THEN
              print_debug('Program Create_Inv_lot has failed with a Unexpected exception', 9);
            END IF;
            FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
            FND_MESSAGE.SET_TOKEN('PROG_NAME','Create_Inv_lot');
            fnd_msg_pub.ADD;
            RAISE g_exc_unexpected_error;
          END IF;

    print_debug('End of the program create_inv_lot. Program has completed successfully ', 9);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO inv_lot;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In No data found ' || SQLERRM, 9);
    WHEN g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO inv_lot;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In g_exc_error ' || SQLERRM, 9);
    WHEN g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO inv_lot;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In g_exc_unexpected_error ' || SQLERRM, 9);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO inv_lot;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In others ' || SQLERRM, 9);
  END create_inv_lot;



  /* Overloaded Create_Inv_lot procedure */
   PROCEDURE Create_Inv_lot(
            x_return_status         OUT    NOCOPY VARCHAR2
          , x_msg_count             OUT    NOCOPY NUMBER
          , x_msg_data              OUT    NOCOPY VARCHAR2
          , x_row_id                OUT    NOCOPY ROWID
          , x_lot_rec               OUT    NOCOPY MTL_LOT_NUMBERS%ROWTYPE
          , p_lot_rec               IN     MTL_LOT_NUMBERS%ROWTYPE
          , p_source                IN     NUMBER
          , p_api_version           IN     NUMBER
          , p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
          , p_commit                IN     VARCHAR2 := fnd_api.g_false
          , p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
          , p_origin_txn_id         IN     NUMBER
          )
          IS

     /* Cursor definition to check whether item is a valid item and it's lot controlled */
     CURSOR  c_chk_msi_attr(cp_inventory_item_id NUMBER, cp_organization_id NUMBER) IS
     SELECT  lot_control_code,
             child_lot_flag,
             copy_lot_attribute_flag,
             shelf_life_code,
             grade_control_flag
       FROM  mtl_system_items_b  -- NSRIVAST, Changed the name to MTL_SYSTEM_ITEMS_B as per review comments by Shelly
      WHERE  inventory_item_id = cp_inventory_item_id
        AND  organization_id   = cp_organization_id;

   l_chk_msi_attr_rec    c_chk_msi_attr%ROWTYPE;

     /* Cursor definition to check lot existence in Mtl_Lot_Numbers Table */
     CURSOR  c_chk_lot_exists(cp_lot_number  MTL_LOT_NUMBERS.lot_number%TYPE,cp_inventory_item_id NUMBER, cp_organization_id NUMBER) IS
     SELECT  lot_number
       FROM  mtl_lot_numbers
      WHERE  lot_number        = cp_lot_number AND
             inventory_item_id = cp_inventory_item_id AND
             organization_id   = cp_organization_id;

   l_chk_lot_rec    c_chk_lot_exists%ROWTYPE;

     /* Cursor definition to check if Lot UOM Conversion is needed */
     CURSOR  c_lot_uom_conv(cp_organization_id NUMBER) IS
     SELECT  copy_lot_attribute_flag,
             lot_number_generation
       FROM  mtl_parameters
      WHERE  organization_id = cp_organization_id;

   l_lot_uom_conv               c_lot_uom_conv%ROWTYPE ;

   /* Cursor definition to get gen_object_id for a lot */
     CURSOR  c_get_obj_id(cp_lot_number  MTL_LOT_NUMBERS.lot_number%TYPE,cp_inventory_item_id NUMBER, cp_organization_id NUMBER) IS
     SELECT  gen_object_id, ROWID
       FROM  mtl_lot_numbers
      WHERE  lot_number        = cp_lot_number AND
             inventory_item_id = cp_inventory_item_id AND
             organization_id   = cp_organization_id;

    l_get_obj_id_rec    c_get_obj_id%ROWTYPE;


   l_parent_lot_rec             MTL_LOT_NUMBERS%ROWTYPE ;
   l_child_lot_rec              MTL_LOT_NUMBERS%ROWTYPE ;
   x_parent_lot_rec             MTL_LOT_NUMBERS%ROWTYPE ;
   x_child_lot_rec              MTL_LOT_NUMBERS%ROWTYPE ;

   l_chd_gen_obj_id            NUMBER;
   l_prt_gen_obj_id            NUMBER;

   l_parent_exists_flag         VARCHAR2(1) ;   -- NSRIVAST
   l_copy_lot_attribute_flag    VARCHAR2(1) ;
   l_return_status              VARCHAR2(1)  ;
   l_msg_data                   VARCHAR2(3000)  ;
   l_msg_count                  NUMBER    ;
   l_api_version          NUMBER;
   l_init_msg_list           VARCHAR2(100);
   l_commit            VARCHAR2(100);
   l_source                     NUMBER;
   l_row_id                     ROWID ;
  BEGIN

    SAVEPOINT inv_lot_1;

     -- Bug 7686319
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
     END IF;

    x_return_status  := g_ret_sts_success;

    /* BASIC CHECKS , start */
    IF p_lot_rec.organization_id IS NULL THEN
       IF g_debug = 1 THEN
            print_debug('Value for mandatory field organization id cannot be null.', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_NULL_ORG_EXP') ;
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END IF ;


    /* Check item existence in Mtl_system_items Table */
    OPEN  c_chk_msi_attr(p_lot_rec.inventory_item_id,p_lot_rec.organization_id);
    FETCH c_chk_msi_attr INTO l_chk_msi_attr_rec;

    IF c_chk_msi_attr%NOTFOUND THEN
     CLOSE c_chk_msi_attr;
        IF (g_debug = 1) THEN
          print_debug('Item not found.  Invalid item. Please re-enter.', 9);
        END IF;

        fnd_message.set_name('INV', 'INV_INVALID_ITEM');
        fnd_msg_pub.ADD;
        RAISE g_exc_error;
    ELSE
     CLOSE c_chk_msi_attr;

       l_copy_lot_attribute_flag :=  l_chk_msi_attr_rec.copy_lot_attribute_flag ;

       /* If not lot controlled then error out */
       IF (l_chk_msi_attr_rec.lot_control_code = 1) THEN
          IF g_debug = 1 THEN
             print_debug('Item is not lot controlled ', 9);
          END IF;

          fnd_message.set_name('INV', 'INV_NO_LOT_CONTROL');
          fnd_msg_pub.ADD;
          x_return_status  := fnd_api.g_ret_sts_error;
          RAISE g_exc_error;
       END IF;  /*  l_chk_msi_attr_rec.lot_control_code = 1 */

       /* If not child lot enabled and p_lot_rec.parent_lot_number IS NOT NULL then error out */
       IF (l_chk_msi_attr_rec.child_lot_flag = 'N' AND p_lot_rec.parent_lot_number IS NOT NULL) THEN
          IF g_debug = 1 THEN
            print_debug('Item is not child lot enabled ', 9);
          END IF;

          fnd_message.set_name('INV', 'INV_ITEM_CLOT_DISABLE_EXP');
          fnd_msg_pub.ADD;
          x_return_status  := fnd_api.g_ret_sts_error;
          RAISE g_exc_error;
       END IF; /* l_chk_msi_attr_rec.child_lot_flag = 'N' */

        /* Check for User-defined expiration date */
       IF  p_lot_rec.expiration_date IS NULL AND
           l_chk_msi_attr_rec.shelf_life_code = 4 THEN      -- User-defined expiration date
           IF g_debug = 1 THEN
              print_debug('User defined expiration date cannot be null', 9);
           END IF;

           fnd_message.set_name('INV', 'INV_NULL_EXPIRATION_DATE_EXP') ;
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
       END IF;

       /* Check whether item is grade controlled */
       IF  p_lot_rec.grade_code IS NOT NULL AND
           l_chk_msi_attr_rec.grade_control_flag = 'N' THEN
           IF g_debug = 1 THEN
              print_debug('Item is not grade controlled.', 9);
           END IF;

           fnd_message.set_name('INV', 'INV_ITEM_NOT_GRADE_CTRL_EXP');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
       END IF;

    END IF; /* c_chk_msi_attr*/

    /* Check for existence of Lot in Mtl_Lot_Numbers Table */
    IF  p_lot_rec.lot_number IS NULL THEN
        IF g_debug = 1 THEN
           print_debug('Value for mandatory field Lot Number cannot be null', 9);
        END IF;

        fnd_message.set_name('INV', 'INV_NULL_CLOT_EXP');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    ELSE
       /* Check child lot existence in Mtl_Lot_Numbers Table */
       OPEN  c_chk_lot_exists(p_lot_rec.lot_number,p_lot_rec.inventory_item_id,p_lot_rec.organization_id);
       FETCH c_chk_lot_exists INTO l_chk_lot_rec;

       IF c_chk_lot_exists%FOUND THEN
          /* Child lot exists in Mtl_Lot_Numbers Table. */
          IF g_debug = 1 THEN
             print_debug('Child lot already exists in the system.', 9);
          END IF;

          -- Child lot already exists in the system: LOT_NUMBER
          fnd_message.set_name('INV', 'INV_CLOT_EXISTS_EXP');
          fnd_message.set_token('LOT_NUMBER', to_char(p_lot_rec.lot_number));
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
       END IF;
          /* Child lot DOES NOT exist in Mtl_Lot_Numbers Table. */
         CLOSE c_chk_lot_exists;
    END IF;

    /* Check for same parent and child lot names */
     IF  p_lot_rec.lot_number IS NOT NULL AND p_lot_rec.parent_lot_number IS NOT NULL THEN
         IF p_lot_rec.lot_number = p_lot_rec.parent_lot_number THEN
           /*Both the parent and child lots have same name*/
             IF g_debug = 1 THEN
                print_debug('Parent lot number and child lot number can not be same.', 9);
             END IF;
             fnd_message.set_name('INV', 'INV_SAME_LOT_NAMES_EXP');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
         END IF ;
     END IF ;

    /* Check for existence of Parent Lot in Mtl_Lot_Numbers Table */
        l_parent_exists_flag := NULL;

    OPEN c_chk_lot_exists(p_lot_rec.parent_lot_number,p_lot_rec.inventory_item_id,p_lot_rec.organization_id);
    FETCH c_chk_lot_exists INTO l_chk_lot_rec;

    IF c_chk_lot_exists%FOUND THEN
       /* Parent lot exists in Mtl_Lot_Numbers Table. */
        l_parent_exists_flag := 'Y';

    ELSIF c_chk_lot_exists%NOTFOUND AND p_lot_rec.parent_lot_number IS NOT NULL THEN
       /* Parent lot DOES NOT exist in Mtl_Lot_Numbers Table. */
        l_parent_exists_flag := 'N';
    END IF;
    CLOSE c_chk_lot_exists;

    /* BASIC CHECKS , End */

    IF p_validation_level  = FND_API.G_VALID_LEVEL_FULL THEN

      --      Call Populate_Lot_Records API.
      --      Populate_Lot_Records API returns following OUT parameters:
      --       x_parent_lot_rec,
      --       x_lot_rec
      l_source                   :=  p_source ;
      l_api_version      := 1.0;
      l_init_msg_list       := p_init_msg_list; --fnd_api.g_false; Bug# 7686319
      l_commit        := fnd_api.g_false;

      Inv_Lot_Api_Pkg.Populate_Lot_Records (
                   p_lot_rec  =>  p_lot_rec
                 , p_copy_lot_attribute_flag  => l_copy_lot_attribute_flag
                 , p_source                   =>  l_source
                 , p_api_version              =>  l_api_version
                 , p_init_msg_list            =>  l_init_msg_list
                 , p_commit                   =>  l_commit
                 , x_child_lot_rec            =>  x_child_lot_rec
                 , x_return_status            =>  l_return_status
                 , x_msg_count                =>  l_msg_count
                 , x_msg_data                 =>  l_msg_data
                             );

                IF g_debug = 1 THEN
                   print_debug('Program INV_LOT_API_PKG.POPULATE_LOT_RECORDS return ' || x_return_status, 9);
                END IF;
                IF l_return_status = g_ret_sts_error THEN
                   IF g_debug = 1 THEN
                      print_debug('Program INV_LOT_API_PKG.POPULATE_LOT_RECORDS has failed with a user defined exception', 9);
                   END IF;
                   RAISE g_exc_error;
                ELSIF l_return_status = g_ret_sts_unexp_error THEN
                   IF g_debug = 1 THEN
                       print_debug('Program INV_LOT_API_PKG.POPULATE_LOT_RECORDS has failed with a Unexpected exception', 9);
                   END IF;
                   FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROG_NAME','INV_LOT_API_PKG.POPULATE_LOT_RECORDS');
                   FND_MSG_PUB.ADD;
                   RAISE g_exc_unexpected_error;
                END IF;

       --   Populate local variable l_child_lot_rec with the values from x_child_lot_rec.
             l_child_lot_rec        :=    x_child_lot_rec;

    END IF;  /* p_validation_level  = G_VALID_LEVEL_FULL */


    IF p_validation_level  = FND_API.G_VALID_LEVEL_NONE  THEN
        -- Populate local variable l_child_lot_rec with proper attribute's values that are passed as input parameter to this API.
         l_child_lot_rec              :=    p_lot_rec  ;

    END IF;  /* p_validation_level  = G_VALID_LEVEL_NONE */


    --   Call mtl_lot_numbers_pkg.insert_row API passing the attribute's
    --  values populated in local variable l_child_lot_rec.

    -- OPM Inventory Convergence - added column sampling_event_id to mtl_lot_number
    -- Bug #4115021
    /*Bug#5523811 passing values from l_child_lot_rec instead of NULL for fields
      curl_wrnkl_fold, description and vendor_id */
         Mtl_Lot_Numbers_Pkg.Insert_Row(
                x_inventory_item_id      =>     l_child_lot_rec.inventory_item_id
              , x_organization_id        =>     l_child_lot_rec.organization_id
              , x_lot_number             =>     l_child_lot_rec.lot_number
              , x_parent_lot_number      =>     l_child_lot_rec.parent_lot_number
              , x_supplier_lot_number    =>     l_child_lot_rec.supplier_lot_number
              , x_grade_code             =>     l_child_lot_rec.grade_code
              , x_origination_date       =>     l_child_lot_rec.origination_date
              , x_date_code              =>     l_child_lot_rec.date_code
              , x_status_id              =>     l_child_lot_rec.status_id
              , x_change_date            =>     l_child_lot_rec.change_date
              , x_age                    =>     l_child_lot_rec.age
              , x_retest_date            =>     l_child_lot_rec.retest_date
              , x_maturity_date          =>     l_child_lot_rec.maturity_date
              , x_lot_attribute_category =>     l_child_lot_rec.lot_attribute_category
              , x_item_size              =>     l_child_lot_rec.item_size
              , x_color                  =>     l_child_lot_rec.color
              , x_volume                 =>     l_child_lot_rec.volume
              , x_volume_uom             =>     l_child_lot_rec.volume_uom
              , x_place_of_origin        =>     l_child_lot_rec.place_of_origin
              , x_best_by_date           =>     l_child_lot_rec.best_by_date
              , x_length                 =>     l_child_lot_rec.length
              , x_length_uom             =>     l_child_lot_rec.length_uom
              , x_recycled_content       =>     l_child_lot_rec.recycled_content
              , x_thickness              =>     l_child_lot_rec.thickness
              , x_thickness_uom          =>     l_child_lot_rec.thickness_uom
              , x_width                  =>     l_child_lot_rec.width
              , x_width_uom              =>     l_child_lot_rec.width_uom
              , x_territory_code         =>     l_child_lot_rec.territory_code
              , x_expiration_date        =>     l_child_lot_rec.expiration_date
              , x_disable_flag           =>     l_child_lot_rec.disable_flag
              , x_attribute_category     =>     l_child_lot_rec.attribute_category
              , x_origination_type       =>     l_child_lot_rec.origination_type
              , x_expiration_action_date =>     l_child_lot_rec.expiration_action_date
              , x_expiration_action_code =>     l_child_lot_rec.expiration_action_code
              , x_hold_date              =>     l_child_lot_rec.hold_date
              , x_last_update_date       =>     SYSDATE
              , x_last_updated_by        =>     FND_GLOBAL.USER_ID
              , x_creation_date          =>     SYSDATE
              , x_created_by             =>     FND_GLOBAL.USER_ID
              , x_last_update_login      =>     FND_GLOBAL.LOGIN_ID
              , x_attribute1             =>     l_child_lot_rec.attribute1
              , x_attribute2             =>     l_child_lot_rec.attribute2
              , x_attribute3             =>     l_child_lot_rec.attribute3
              , x_attribute4             =>     l_child_lot_rec.attribute4
              , x_attribute5             =>     l_child_lot_rec.attribute5
              , x_attribute6             =>     l_child_lot_rec.attribute6
              , x_attribute7             =>     l_child_lot_rec.attribute7
              , x_attribute8             =>     l_child_lot_rec.attribute8
              , x_attribute9             =>     l_child_lot_rec.attribute9
              , x_attribute10            =>     l_child_lot_rec.attribute10
              , x_attribute11            =>     l_child_lot_rec.attribute11
              , x_attribute12            =>     l_child_lot_rec.attribute12
              , x_attribute13            =>     l_child_lot_rec.attribute13
              , x_attribute14            =>     l_child_lot_rec.attribute14
              , x_attribute15            =>     l_child_lot_rec.attribute15
              , x_c_attribute1           =>     l_child_lot_rec.c_attribute1
              , x_c_attribute2           =>     l_child_lot_rec.c_attribute2
              , x_c_attribute3           =>     l_child_lot_rec.c_attribute3
              , x_c_attribute4           =>     l_child_lot_rec.c_attribute4
              , x_c_attribute5           =>     l_child_lot_rec.c_attribute5
              , x_c_attribute6           =>     l_child_lot_rec.c_attribute6
              , x_c_attribute7           =>     l_child_lot_rec.c_attribute7
              , x_c_attribute8           =>     l_child_lot_rec.c_attribute8
              , x_c_attribute9           =>     l_child_lot_rec.c_attribute9
              , x_c_attribute10          =>     l_child_lot_rec.c_attribute10
              , x_c_attribute11          =>     l_child_lot_rec.c_attribute11
              , x_c_attribute12          =>     l_child_lot_rec.c_attribute12
              , x_c_attribute13          =>     l_child_lot_rec.c_attribute13
              , x_c_attribute14          =>     l_child_lot_rec.c_attribute14
              , x_c_attribute15          =>     l_child_lot_rec.c_attribute15
              , x_c_attribute16          =>     l_child_lot_rec.c_attribute16
              , x_c_attribute17          =>     l_child_lot_rec.c_attribute17
              , x_c_attribute18          =>     l_child_lot_rec.c_attribute18
              , x_c_attribute19          =>     l_child_lot_rec.c_attribute19
              , x_c_attribute20          =>     l_child_lot_rec.c_attribute20
              , x_d_attribute1           =>     l_child_lot_rec.d_attribute1
              , x_d_attribute2           =>     l_child_lot_rec.d_attribute2
              , x_d_attribute3           =>     l_child_lot_rec.d_attribute3
              , x_d_attribute4           =>     l_child_lot_rec.d_attribute4
              , x_d_attribute5           =>     l_child_lot_rec.d_attribute5
              , x_d_attribute6           =>     l_child_lot_rec.d_attribute6
              , x_d_attribute7           =>     l_child_lot_rec.d_attribute7
              , x_d_attribute8           =>     l_child_lot_rec.d_attribute8
              , x_d_attribute9           =>     l_child_lot_rec.d_attribute9
              , x_d_attribute10          =>     l_child_lot_rec.d_attribute10
              , x_n_attribute1           =>     l_child_lot_rec.n_attribute1
              , x_n_attribute2           =>     l_child_lot_rec.n_attribute2
              , x_n_attribute3           =>     l_child_lot_rec.n_attribute3
              , x_n_attribute4           =>     l_child_lot_rec.n_attribute4
              , x_n_attribute5           =>     l_child_lot_rec.n_attribute5
              , x_n_attribute6           =>     l_child_lot_rec.n_attribute6
              , x_n_attribute7           =>     l_child_lot_rec.n_attribute7
              , x_n_attribute8           =>     l_child_lot_rec.n_attribute8
              , x_n_attribute9           =>     l_child_lot_rec.n_attribute9
              , x_n_attribute10          =>     l_child_lot_rec.n_attribute10
              , x_request_id             =>     NULL
              , x_program_application_id =>     NULL
              , x_program_id             =>     NULL
              , x_program_update_date    =>     NULL
              , x_curl_wrinkle_fold      =>     l_child_lot_rec.curl_wrinkle_fold
              , x_description            =>     l_child_lot_rec.description
              , x_vendor_id              =>     l_child_lot_rec.vendor_id
              , x_sampling_event_id      =>     l_child_lot_rec.sampling_event_id
              );

    /*.Check needed for  Lot UOM conversion */
    OPEN c_lot_uom_conv (p_lot_rec.organization_id) ;
    FETCH  c_lot_uom_conv INTO l_lot_uom_conv ;

    IF  c_lot_uom_conv%FOUND THEN
      CLOSE c_lot_uom_conv ;

         --     Possible values for mtl_parameters.lot_number_generation are:
         --     1 At organization level
         --     3 User defined
         --     2 At item level

      IF  l_lot_uom_conv.lot_number_generation = 1 THEN
         l_copy_lot_attribute_flag := NVL(l_lot_uom_conv.copy_lot_attribute_flag,'N') ;
      ELSIF  l_lot_uom_conv.lot_number_generation IN (2,3) THEN
         l_copy_lot_attribute_flag :=  NVL(l_chk_msi_attr_rec.copy_lot_attribute_flag,'N') ;
      END IF;

    ELSE
      CLOSE c_lot_uom_conv ;
    END IF ;


    /*   Check to see if Copy Lot UOM Conversions is required.
        Call MTL_LOT_UOM_CONV_PVT.COPY_LOT_UOM_CONVERSIONS  */

      IF l_copy_lot_attribute_flag = 'Y' AND l_parent_exists_flag = 'Y'  THEN
        Mtl_Lot_Uom_Conv_Pvt.Copy_Lot_Uom_Conversions (
                  p_from_organization_id     =>   p_lot_rec.organization_id
                , p_to_organization_id       =>   p_lot_rec.organization_id
                , p_inventory_item_id        =>   p_lot_rec.inventory_item_id
                , p_from_lot_number          =>   p_lot_rec.parent_lot_number
                , p_to_lot_number            =>   p_lot_rec.lot_number
                , p_user_id                  =>   fnd_global.user_id
                , p_creation_date            =>   SYSDATE
                , p_commit                   =>   p_commit
                , x_return_status            =>   l_return_status
                , x_msg_count                =>   l_msg_count
                , x_msg_data                 =>   l_msg_data
                )  ;

       IF g_debug = 1 THEN
          print_debug('Program MTL_LOT_UOM_CONV_PVT.COPY_LOT_UOM return ' || l_return_status, 9);
       END IF;
       IF l_return_status = g_ret_sts_error THEN
          IF g_debug = 1 THEN
             print_debug('Program MTL_LOT_UOM_CONV_PVT.COPY_LOT_UOM has failed with a user defined exception', 9);
          END IF;
          RAISE g_exc_error;
       ELSIF l_return_status = g_ret_sts_unexp_error THEN
          IF g_debug = 1 THEN
              print_debug('Program MTL_LOT_UOM_CONV_PVT.COPY_LOT_UOM has failed with a Unexpected exception', 9);
          END IF;
          FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
          FND_MESSAGE.SET_TOKEN('PROG_NAME','MTL_LOT_UOM_CONV_PVT.COPY_LOT_UOM');
          FND_MSG_PUB.ADD;
          RAISE g_exc_unexpected_error;
       END IF;

    END IF;  /* Call MTL_LOT_UOM_CONV_PVT.COPY_LOT_UOM_CONVERSIONS */


     OPEN c_get_obj_id (p_lot_rec.lot_number,p_lot_rec.inventory_item_id,p_lot_rec.organization_id);
     FETCH c_get_obj_id INTO l_get_obj_id_rec;
     IF c_get_obj_id%NOTFOUND THEN
        CLOSE c_get_obj_id;
        RAISE NO_DATA_FOUND ;
     END IF;
     CLOSE c_get_obj_id;

     l_row_id                    := l_get_obj_id_rec.ROWID  ;
     x_row_id                    := l_row_id ;

    /* Populate the Our parameter, x_lot_rec */
     x_lot_rec :=  l_child_lot_rec ;
     x_lot_rec.gen_object_id     := l_get_obj_id_rec.gen_object_id ;

    print_debug('End of the program create_inv_lot. Program has completed successfully ', 9);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status  := g_ret_sts_error;
      ROLLBACK TO inv_lot_1;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In No data found Create_Inv_Lot ' || SQLERRM, 9);
    WHEN g_exc_error THEN
      x_return_status  := g_ret_sts_error;
      ROLLBACK TO inv_lot_1;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In g_exc_error Create_Inv_Lot ' || SQLERRM, 9);
    WHEN g_exc_unexpected_error THEN
      x_return_status  := g_ret_sts_unexp_error;
      ROLLBACK TO inv_lot_1;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In g_exc_unexpected_error Create_Inv_Lot ' || SQLERRM, 9);
    WHEN OTHERS THEN
      x_return_status  := g_ret_sts_unexp_error;
      ROLLBACK TO inv_lot_1;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      if( x_msg_count > 1 ) then
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      end if;
      print_debug('In others Create_Inv_Lot ' || SQLERRM, 9);

  END Create_Inv_lot;

/* HVERDDIN ADDED OLD routine back, this will call new version, Start */

-- Fix for Bug#12925054
-- Added new parameters p_transaction_source_id and p_transaction_source_line_id

    FUNCTION auto_gen_lot (
        p_org_id                       IN       NUMBER,
        p_inventory_item_id            IN       NUMBER,
        p_lot_generation               IN       NUMBER := NULL,
        p_lot_uniqueness               IN       NUMBER := NULL,
        p_lot_prefix                   IN       VARCHAR2 := NULL,
        p_zero_pad                     IN       NUMBER := NULL,
        p_lot_length                   IN       NUMBER := NULL,
        p_transaction_date             IN       DATE := NULL,
        p_revision                     IN       VARCHAR2 := NULL,
        p_subinventory_code            IN       VARCHAR2 := NULL,
        p_locator_id                   IN       NUMBER := NULL,
        p_transaction_type_id          IN       NUMBER := NULL,
        p_transaction_action_id        IN       NUMBER := NULL,
        p_transaction_source_type_id   IN       NUMBER := NULL,
        p_lot_number                   IN       VARCHAR2 := NULL,
        p_api_version                  IN       NUMBER,
        p_init_msg_list                IN       VARCHAR2 := fnd_api.g_false,
        p_commit                       IN       VARCHAR2 := fnd_api.g_false,
        p_validation_level             IN       NUMBER
                := fnd_api.g_valid_level_full,
        x_return_status                OUT      NOCOPY VARCHAR2,
        x_msg_count                    OUT      NOCOPY NUMBER,
        x_msg_data                     OUT      NOCOPY VARCHAR2,
        p_transaction_source_id        IN       NUMBER := NULL,
        p_transaction_source_line_id   IN       NUMBER := NULL
     )
        RETURN VARCHAR2
    IS
        l_unique_lot             BOOLEAN         := FALSE;
        l_lotcount               NUMBER;
        l_api_version   CONSTANT NUMBER          := 1.0;
        l_api_name      CONSTANT VARCHAR2 ( 50 ) := 'INV_LOT_API_PUB.auto_gen_lot';
        l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
        v_org_code               VARCHAR2 ( 3 );
        v_item_name              VARCHAR2 ( 40 );
        x_parent_lot_number            MTL_LOT_NUMBERS.LOT_NUMBER%TYPE := NULL;
        x_parent_call                  MTL_LOT_NUMBERS.LOT_NUMBER%TYPE;

    BEGIN
       x_parent_call := inv_lot_api_pub.auto_gen_lot (
                        p_org_id,
                        p_inventory_item_id,
                        p_lot_generation,
                        p_lot_uniqueness,
                        p_lot_prefix,
                        p_zero_pad,
                        p_lot_length,
                        p_transaction_date,
                        p_revision,
                        p_subinventory_code,
                        p_locator_id,
                        p_transaction_type_id,
                        p_transaction_action_id,
                        p_transaction_source_type_id,
                        p_lot_number,
                        p_api_version,
                        p_init_msg_list,
                        p_commit,
                        p_validation_level,
                        x_parent_lot_number,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        p_transaction_source_id,       /* 13368816 */
                        p_transaction_source_line_id   /* 13368816 */
                         );
     RETURN x_parent_call;


    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK TO apiauto_gen_lot_apipub;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get (
                 p_encoded => fnd_api.g_false,
                p_count => x_msg_count,
                p_data => x_msg_data
             );
            RETURN ( NULL );
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO apiauto_gen_lot_apipub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (
                 p_encoded => fnd_api.g_false,
                p_count => x_msg_count,
                p_data => x_msg_data
             );
            RETURN ( NULL );
        WHEN OTHERS THEN
            ROLLBACK TO apiauto_gen_lot_apipub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

            IF fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg ( g_pkg_name, l_api_name );
            END IF;

            fnd_msg_pub.count_and_get (
                 p_encoded => fnd_api.g_false,
                p_count => x_msg_count,
                p_data => x_msg_data
             );
            RETURN ( NULL );
    END auto_gen_lot;

/* INVCONV , HVERDDIN ADDED AUTO_GEN_LOT Wrapper for MSCA , End*/




/*INVCONV , Punit Kumar  */

  /*####################################################################################
  #
  #  PROCEDURE :  CHECK_LOT_INDIVISIBILITY
  #
  #
  #  DESCRIPTION  : This is a wrapper procedure to call lot indivisible api
  #                 and shall be called by INV TM.
  #                 it also encorporates an enhancement to handle multiple deliveries
  #                 to INV for a lot indiv item.
  #
  #
  # MODIFICATION HISTORY
  # 07-FEB-2005  Punit Kumar  Created
  #
  ######################################################################################*/

   PROCEDURE CHECK_LOT_INDIVISIBILITY (  p_api_version          IN  NUMBER     DEFAULT 1.0
                                       ,p_init_msg_list        IN  VARCHAR2   DEFAULT FND_API.G_FALSE
                                       ,p_commit               IN  VARCHAR2   DEFAULT FND_API.G_FALSE
                                       ,p_validation_level     IN  NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL
                                       ,p_rti_id               IN  NUMBER
                                       ,p_transaction_type_id  IN  NUMBER
                                       ,p_lot_number           IN  VARCHAR2
                                       ,p_lot_quantity         IN  NUMBER
                                       ,p_revision             IN  VARCHAR2
                                       ,p_qoh                  IN  NUMBER     DEFAULT NULL
                                       ,p_atr                  IN  NUMBER     DEFAULT NULL
                                       ,x_return_status        OUT NOCOPY     VARCHAR2
                                       ,x_msg_count            OUT NOCOPY     NUMBER
                                       ,x_msg_data             OUT NOCOPY     VARCHAR2
                                      )
      IS

      l_api_name               VARCHAR2(30) := 'CHECK_LOT_INDIVISIBILITY'               ;
      l_api_version            CONSTANT NUMBER := 1.0                                  ;
      l_return_status          VARCHAR2(1)                                             ;
      l_msg_data               VARCHAR2(3000)                                          ;
      l_msg_count              NUMBER                                                  ;
      l_progress               VARCHAR2(3) := '000'                                    ;

      l_parent_trx_id          NUMBER                                                  ;
      l_pmy_rcv_qty            NUMBER                                                  ;
      l_lot_qty                NUMBER                                                  ;
      l_pmy_unit_of_meas       VARCHAR2(100)                                           ;
      l_to_organization_id     NUMBER                                                  ;
      l_subinventory_code      VARCHAR2(100)                                           ;
      l_locator_id             NUMBER                                                  ;
      l_item_id                NUMBER                                                  ;
      l_trx_unit_of_measure    VARCHAR2(100)                                           ;



      CURSOR Cr_rti_values(l_rti_id NUMBER) IS
          SELECT  TO_ORGANIZATION_ID
                 ,SUBINVENTORY
                 ,locator_id
                 ,item_id
                 ,PARENT_TRANSACTION_ID
                 ,UNIT_OF_MEASURE
            FROM RCV_TRANSACTIONS_INTERFACE
            WHERE INTERFACE_TRANSACTION_ID = l_rti_id;


      CURSOR Cr_rt_values(l_rt_id NUMBER) IS
         SELECT primary_quantity , primary_unit_of_measure
            FROM rcv_transactions
            WHERE transaction_id = l_rt_id ;



   BEGIN

       -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
                                       l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       'inv_lot_api_pub'
                                       ) THEN
       IF (g_debug = 1) THEN
          print_debug('FND_API not compatible INV_LOT_API_PUB.CHECK_LOT_INDIVISIBILITY: '||l_progress, 1);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_progress := '001';

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
       fnd_msg_pub.initialize;
    END IF;

    --Initialize the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := '002';

    /*Calling the lot indivisible function only for the following
    1) Deliver to Inventory (PO Receipt) --- for PO or RMA or Internal Req
    2) Return to Vendor (from INV)
    3) Return to Receiving (from INV)
    4) Return to Customer (from INV)---RMA

    Since the current procedure is executed only for INV related trx ,
    as its being called from INV TM, so we need not code for restricting
    RCV location related trx.
    Hence restrict for the above 4 types of trx only */

    IF p_transaction_type_id IN (18,15,61,36,37) THEN

       ----fetching values from RTI
       OPEN Cr_rti_values(p_rti_id);
       FETCH Cr_rti_values
          INTO  l_to_organization_id
               ,l_subinventory_code
               ,l_locator_id
               ,l_item_id
               ,l_parent_trx_id
               ,l_trx_unit_of_measure;
       CLOSE Cr_rti_values;

       l_progress := '003';

       IF g_debug = 1 THEN
          print_debug('l_to_organization_id '|| l_to_organization_id , 1);
          print_debug('l_subinventory_code  '||l_subinventory_code , 1);
          print_debug('l_locator_id '|| l_locator_id, 1);
          print_debug('l_item_id  '|| l_item_id , 1);
          print_debug('l_parent_trx_id  '|| l_parent_trx_id, 1);
          print_debug('l_trx_unit_of_measure  '|| l_trx_unit_of_measure, 1);
          print_debug('Before calling INV_LOT_API_PUB.validate_lot_indivisible ',1);
       END IF;

       l_progress := '004';

       ---call the indiv function
       IF NOT (INV_LOT_API_PUB.validate_lot_indivisible(
                                                         p_api_version            =>1.0
                                                        ,p_init_msg_list          =>FND_API.G_FALSE
                                                        ,p_commit                 =>FND_API.G_FALSE
                                                        ,p_validation_level       =>FND_API.G_VALID_LEVEL_FULL
                                                        ,p_transaction_type_id    =>p_transaction_type_id
                                                        ,p_organization_id        =>l_to_organization_id
                                                        ,p_inventory_item_id      =>l_item_id
                                                        ,p_revision               =>p_revision
                                                        ,p_subinventory_code      =>l_subinventory_code
                                                        ,p_locator_id             =>l_locator_id
                                                        ,p_lot_number             =>p_lot_number
                                                        ,p_primary_quantity       =>p_lot_quantity------------the primary quantity of the transaction
                                                        ,p_qoh                    =>p_qoh
                                                        ,p_atr                    =>p_atr
                                                        ,x_return_status          =>l_return_status
                                                        ,x_msg_count              =>l_msg_count
                                                        ,x_msg_data               =>l_msg_data
                                                        ))THEN

          IF g_debug = 1 THEN
             print_debug('Program INV_LOT_API_PUB.validate_lot_indivisible return FALSE ' || l_return_status || 'and '|| l_progress, 9);
          END IF;

          l_progress := '005';

          ---If lot indiv fails fro a Return trx...
          IF ((l_return_status <> FND_API.G_RET_STS_SUCCESS) AND p_transaction_type_id IN (36,37)) THEN

             /*---logic to explain the values of p_transaction_type_id
             IF (transaction_type IN ('RETURN TO RECEIVING','RETURN TO VENDOR','RETURN TO CUSTOMER')) THEN
                IF (source_document_code = 'PO') THEN
                   p_transaction_type_id := 36;
                ELSIF (source_document_code = 'RMA') THEN
                   p_transaction_type_id := 37;
                END IF;
             END IF;
             */

             l_progress := '006';

             IF l_parent_trx_id IS NULL THEN
                IF g_debug = 1 THEN
                   print_debug('parent txn id cannot be null for a Return trx:'|| l_progress, 1);
                END IF;
                RAISE g_exc_unexpected_error;
             END IF;

             ------------------Get previously received primary quantity for the Lot.
              OPEN Cr_rt_values(l_parent_trx_id) ;
              FETCH Cr_rt_values
                 INTO l_pmy_rcv_qty,l_pmy_unit_of_meas;
              CLOSE Cr_rt_values;

              l_progress := '007';

              --getting lot trx qty in local var.
              l_lot_qty :=p_lot_quantity ;

             ---If trx uom and previously received uom are diff
             IF l_pmy_unit_of_meas <> l_trx_unit_of_measure THEN

                l_progress := '008';

                /* Convert transaction qty in p_transaction_unit_of_measure to l_pmy_unit_of_meas */

                l_lot_qty := INV_CONVERT.inv_um_convert(
                                                         item_id            => l_item_id                       ,
                                                         lot_number         => p_lot_number                    ,
                                                         organization_id    => l_to_organization_id            ,
                                                         precision          => 5                               ,
                                                         from_quantity      => l_lot_qty                  ,
                                                         from_unit          => NULL                            ,
                                                         to_unit            => NULL                            ,
                                                         from_name          => l_trx_unit_of_measure           ,
                                                         to_name            => l_pmy_unit_of_meas
                                                         );
                l_progress := '009';

                IF l_lot_qty = -99999  THEN
                   IF g_debug = 1 THEN
                      print_debug('INV_CONVERT.inv_um_convert has failed '|| l_progress, 1);
                   END IF;

                   FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
                   FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_CONVERT.inv_um_convert');
                   fnd_msg_pub.ADD;
                   RAISE g_exc_unexpected_error;
                END IF;

             END IF; -----------IF l_pmy_unit_of_meas <> p_transaction_unit_of_measure

             /* If the trx quantity = total received quantity for that parent deliver trx
                then even though lot indivisibily fails , we shall allow the "Return" trx
             */

             ---if the return qty is equal to full delivered qty in parent trx
             IF l_lot_qty = l_pmy_rcv_qty  THEN

                l_progress := '010';

                --overriding the false return status of lot indiv api
                l_return_status := FND_API.G_RET_STS_SUCCESS  ;

                IF g_debug = 1 THEN
                   print_debug('l_return_status'|| l_return_status, 9);
                   print_debug('set return status of validate_lot_indivisible to true'|| l_progress, 9);
                END IF;
             END IF; ----------IF (l_lot_qty = l_pmy_rcv_qty

          END IF;  -------- IF ((l_return_status <>......  AND p_transaction_type_id IN.......

          l_progress := '011';

          IF l_return_status = fnd_api.g_ret_sts_error THEN
             IF g_debug = 1 THEN
                print_debug('Program INV_LOT_API_PUB.validate_lot_indivisible has failed with a user defined exception '|| l_progress, 9);
             END IF;

             FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
             FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_LOT_API_PUB.validate_lot_indivisible');
             fnd_msg_pub.ADD;
             RAISE g_exc_error;

          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
             l_progress := '012' ;

             IF g_debug = 1 THEN
                print_debug('Program INV_LOT_API_PUB.validate_lot_indivisible has failed with a Unexpected exception' || l_progress, 9);
             END IF;

             FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
             FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_LOT_API_PUB.validate_lot_indivisible');
             fnd_msg_pub.ADD;
             RAISE g_exc_unexpected_error;
          END IF;------------IF l_return_status = fnd_api.g_ret_sts_error THEN


       END IF;--------IF NOT (INV_LOT_API_PUB.validate_lot_indivisible(

       l_progress := '013';

       IF g_debug = 1 THEN
          print_debug('Program INV_LOT_API_PUB.validate_lot_indivisible return TRUE: ' || l_return_status || 'and '|| l_progress, 9);
          print_debug('Exitting inv_lot_api_pub.check_lot_indivisibility :'|| l_progress, 9);
       END IF;

    ELSE  ----------IF p_transaction_type_id IN

       IF g_debug = 1 THEN
          print_debug('p_transaction_type_id:'|| p_transaction_type_id, 9);
          print_debug('lot indivisiblitity is not being checked for this trx type:'|| l_progress, 9);
       END IF;

    END IF; ----------IF p_transaction_type_id IN



   EXCEPTION

      WHEN NO_DATA_FOUND THEN
         x_return_status  := fnd_api.g_ret_sts_error;

         fnd_msg_pub.count_and_get(
                                   p_encoded => fnd_api.g_false ,
                                   p_count => x_msg_count       ,
                                   p_data => x_msg_data
                                   );
         IF( x_msg_count > 1 ) THEN
            x_msg_data := fnd_msg_pub.get(
                                          x_msg_count     ,
                                          FND_API.G_FALSE
                                          );
         END IF ;


         IF g_debug = 1 THEN
            print_debug('Exitting CHECK_LOT_INDIVISIBILITY - No data found error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
            -----print_stacked_messages;
         END IF;

      WHEN g_exc_error THEN

         x_return_status  := fnd_api.g_ret_sts_error;

         fnd_msg_pub.count_and_get(
                                   p_encoded => fnd_api.g_false ,
                                   p_count => x_msg_count       ,
                                   p_data => x_msg_data
                                   );

         IF( x_msg_count > 1 ) THEN
            x_msg_data := fnd_msg_pub.get(
                                          x_msg_count     ,
                                          FND_API.G_FALSE
                                          );
         END IF;

         IF g_debug = 1 THEN
            print_debug('Exitting CHECK_LOT_INDIVISIBILITY - g_exc_error error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
            -----print_stacked_messages;
         END IF;


      WHEN g_exc_unexpected_error THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;

         fnd_msg_pub.count_and_get(
                                   p_encoded => fnd_api.g_false ,
                                   p_count => x_msg_count       ,
                                   p_data => x_msg_data
                                   );
         IF( x_msg_count > 1 ) THEN
            x_msg_data := fnd_msg_pub.get(
                                          x_msg_count        ,
                                          FND_API.G_FALSE
                                          );
         END IF ;

         IF g_debug = 1 THEN
            print_debug('Exitting CHECK_LOT_INDIVISIBILITY - g_exc_unexpected_error error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
            --------print_stacked_messages;
         END IF;

      WHEN OTHERS THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
                                   p_encoded => fnd_api.g_false ,
                                   p_count => x_msg_count       ,
                                   p_data => x_msg_data
                                   );
         IF( x_msg_count > 1 ) THEN
            x_msg_data := fnd_msg_pub.get(
                                          x_msg_count        ,
                                          FND_API.G_FALSE);
         END IF;

         IF g_debug = 1 THEN
            print_debug('Exitting CHECK_LOT_INDIVISIBILITY - In others error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
            --------print_stacked_messages;
         END IF;



   END CHECK_LOT_INDIVISIBILITY;



/*end , INVCONV , Punit Kumar*/
-----------------------------------------------------------------------
-- Name : validate_quantities
-- Desc : This procedure is used to validate transaction quantity2
--        if primary quantity/uom is not passed then they will be
--        calculated and returned'
--        if primary quantity is passed in, it will not be validated
-- I/P Params :
--     All the relevant transaction details :
--        - organization id
--        - item_id
--        - lot, revision, subinventory
--        - transaction quantities
-- O/P Params :
--     x_rerturn_status.
-- RETURN VALUE :
--   TRUE : IF the transaction is valid regarding Quantity2 and lot indivisible
--   FALSE : IF the transaction is NOT valid regarding Quantity2 and lot indivisible
--
-----------------------------------------------------------------------
FUNCTION validate_quantities(
  p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
, p_transaction_type_id  IN  NUMBER
, p_organization_id      IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, p_revision             IN  VARCHAR2
, p_subinventory_code    IN  VARCHAR2
, p_locator_id           IN  NUMBER
, p_lot_number           IN  VARCHAR2
, p_transaction_quantity IN OUT  NOCOPY NUMBER
, p_transaction_uom_code IN  VARCHAR2
, p_primary_quantity     IN OUT NOCOPY NUMBER
, p_primary_uom_code  OUT NOCOPY VARCHAR2
, p_secondary_quantity   IN OUT NOCOPY NUMBER
, p_secondary_uom_code   IN OUT NOCOPY VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
l_api_name              CONSTANT VARCHAR2(30) := 'validate_quantities';
l_api_version           CONSTANT NUMBER := 1.0;
l_lot_divisible_flag    VARCHAR2(1);
l_tracking_quantity_ind VARCHAR2(30);
l_secondary_default_ind VARCHAR2(30);
l_secondary_uom_code    VARCHAR2(3);
l_secondary_qty         NUMBER;
l_transaction_quantity  NUMBER;
l_primary_quantity   NUMBER;
l_are_qties_valid       NUMBER;
l_error_message         VARCHAR2(500);
l_lot_indiv_trx_valid   BOOLEAN;
l_msg       VARCHAR2(2000);
l_msg_index_out   NUMBER;
l_debug                 NUMBER;

CURSOR get_item_details( org_id IN NUMBER
                       , item_id IN NUMBER) IS
SELECT lot_divisible_flag
, tracking_quantity_ind
, secondary_default_ind
, secondary_uom_code
, primary_uom_code
FROM mtl_system_items
WHERE organization_id = org_id
AND inventory_item_id = item_id;

BEGIN

IF (l_debug is null) THEN
  l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
END IF;

IF (l_debug = 1) THEN
  inv_log_util.trace('validate_quantities: Start ', g_pkg_name, 9);
END IF;

IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
END IF;

-- Standard call to check for call compatibility.
IF NOT FND_API.COMPATIBLE_API_CALL( l_api_version
                                  , p_api_version
                                  , l_api_name
                                  , G_PKG_NAME)
THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

/* =======================================================================
  Init variables
 =======================================================================  */
x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN get_item_details( p_organization_id
                     , p_inventory_item_id);
FETCH get_item_details
 INTO l_lot_divisible_flag
    , l_tracking_quantity_ind
    , l_secondary_default_ind
    , l_secondary_uom_code
    , p_primary_uom_code;

IF (get_item_details%NOTFOUND)
THEN
    CLOSE get_item_details;
    FND_MESSAGE.SET_NAME('INV','ITEM_NOT_FOUND');
    FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', p_organization_id);
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inventory_item_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE get_item_details;

--{
IF (l_tracking_quantity_ind = 'P') THEN
  IF (p_secondary_quantity IS NOT NULL) THEN
     FND_MESSAGE.SET_NAME('INV','INV_SECONDARY_QTY_NOT_REQUIRED');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_secondary_uom_code IS NOT NULL) THEN
     FND_MESSAGE.SET_NAME('INV','INV_SECONDARY_UOM_NOT_REQUIRED');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

ELSIF (l_tracking_quantity_ind = 'PS') THEN
   -- the item is DUOM controlled
   /** UOM Validation **/
      /** UOM Validation **/
   IF (p_secondary_uom_code <> l_secondary_uom_code) THEN
     FND_MESSAGE.SET_NAME('INV','INV_INCORRECT_SECONDARY_UOM');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Set the default UOM2 if missing or incorrect:
   IF (p_secondary_uom_code IS NULL) THEN
     p_secondary_uom_code := l_secondary_uom_code;
   END IF;

   /** Quantity  Validation **/
   IF ((p_transaction_quantity IS NULL AND p_secondary_quantity IS NULL) OR
       (l_secondary_default_ind = 'N' AND (p_transaction_quantity IS NULL
      OR p_secondary_quantity IS NULL))) THEN
      IF (l_debug = 1) THEN
   inv_log_util.trace('validate_quantities: Missing both quantities or one qty for no default item ..', g_pkg_name, 9);
      END IF;
      FND_MESSAGE.SET_NAME('INV','INV_INT_QTYCODE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --{
   IF (p_secondary_quantity IS NULL) THEN
     -- Set the Qty2 from Qty1 if missing:
     l_secondary_qty := INV_CONVERT.INV_UM_CONVERT
               ( item_id         => p_inventory_item_id
               , lot_number      => p_lot_number
               , organization_id => p_organization_id
               , precision       => 5
               , from_quantity   => p_transaction_quantity
               , from_unit       => p_transaction_uom_code
               , to_unit         => p_secondary_uom_code
               , from_name       => NULL
               , to_name         => NULL);

     IF (l_secondary_qty = -99999) THEN
       IF (l_debug = 1) THEN
    inv_log_util.trace('validate_quantities: INV_CONVERT.INV_UM_CONVERT error ', g_pkg_name, 9);
       END IF;
       FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     p_secondary_quantity := l_secondary_qty;
     IF (l_debug = 1) THEN
       inv_log_util.trace('validate_quantities: new secondary qty is: '|| l_secondary_qty , g_pkg_name, 9);
     END IF;
   ELSIF (p_transaction_quantity IS NULL) THEN
     -- Set the Qty1 from Qty2 if missing:
     l_transaction_quantity := INV_CONVERT.INV_UM_CONVERT
               ( item_id         => p_inventory_item_id
               , lot_number      => p_lot_number
               , organization_id       => p_organization_id
               , precision       => 5
               , from_quantity   => p_secondary_quantity
               , from_unit       => p_secondary_uom_code
               , to_unit         => p_transaction_uom_code
               , from_name       => NULL
               , to_name         => NULL);

     IF (l_transaction_quantity = -99999) THEN
       IF (l_debug = 1) THEN
    inv_log_util.trace('validate_quantities:  INV_CONVERT.INV_UM_CONVERT ERROR ', g_pkg_name, 9);
       END IF;
       FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     p_transaction_quantity := l_transaction_quantity;
     IF (l_debug = 1) THEN
       inv_log_util.trace('validate_quantities: new transaction qty is: '|| l_transaction_quantity , g_pkg_name, 9);
     END IF;
   ELSIF (p_transaction_quantity IS NOT NULL AND p_secondary_quantity IS NOT NULL) THEN
     IF (l_debug = 1) THEN
   inv_log_util.trace('validate_quantities: calling INV_CONVERT.WITHIN_DEVIATION', g_pkg_name, 9);
     END IF;
     -- Validate the quantitioes within deviation :
     l_are_qties_valid := INV_CONVERT.within_deviation(
           p_organization_id => p_organization_id
         , p_inventory_item_id  => p_inventory_item_id
         , p_lot_number         => p_lot_number
         , p_precision          => 5
         , p_quantity           => ABS(p_transaction_quantity)
         , p_uom_code1          => p_transaction_uom_code
         , p_quantity2          => ABS(p_secondary_quantity)
         , p_uom_code2           => p_secondary_uom_code);

     IF (l_are_qties_valid = 0) THEN
       IF (l_debug = 1) THEN
         inv_log_util.trace('validate_quantities: INV_CONVERT.within_deviation (ERROR)'  , g_pkg_name, 9);
    inv_log_util.trace('p_transaction_quantity: ' || p_transaction_quantity ||
                       ' p_transaction_uom_code:  ' || p_transaction_uom_code, g_pkg_name, 9);
         inv_log_util.trace(' p_secondary_quantity: ' || p_secondary_quantity ||
                       ' p_secondary_uom_code: ' || p_secondary_uom_code, g_pkg_name, 9);
         inv_log_util.trace(' p_lot_number: ' || p_lot_number || ' p_inventory_item_id: '||
                                p_inventory_item_id  || ' p_organization_id: ' || p_organization_id, g_pkg_name, 9);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_debug = 1) THEN
      inv_log_util.trace('validate_quantities: INV_CONVERT.within_deviation (PASS)' , g_pkg_name, 9);
    END IF;
   END IF;--}
END IF;--}   -- l_tracking_quantity_ind != 'P'
-- Set the prim Qty from transaction Qty if missing:
--{
IF (p_primary_quantity IS NULL) THEN
  l_primary_quantity := INV_CONVERT.INV_UM_CONVERT
               ( item_id         => p_inventory_item_id
               , lot_number      => p_lot_number
               , organization_id => p_organization_id
               , precision       => 5
               , from_quantity   => p_transaction_quantity
               , from_unit       => p_transaction_uom_code
               , to_unit         => p_primary_uom_code
               , from_name       => NULL
               , to_name         => NULL);

 IF (l_primary_quantity = -99999) THEN
   IF (l_debug = 1) THEN
     inv_log_util.trace('validate_quantities: INV_CONVERT.INV_UM_CONVERT error ', g_pkg_name, 9);
   END IF;
   FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
   FND_MSG_PUB.ADD;
   RAISE FND_API.G_EXC_ERROR;
 END IF;
 p_primary_quantity := l_primary_quantity;
 IF (l_debug = 1) THEN
  inv_log_util.trace('validate_quantities: new primary qty is: '|| l_primary_quantity , g_pkg_name, 9);
 END IF;
END IF;--}   --  primary_quantity check

-- Lot Indivisible Validation:
--{
IF (l_lot_divisible_flag = 'N')  THEN
  l_lot_indiv_trx_valid := INV_LOT_API_PUB.VALIDATE_LOT_INDIVISIBLE
            ( p_api_version          => p_api_version
            , p_init_msg_list        => p_init_msg_list
            , p_transaction_type_id  => p_transaction_type_id
            , p_organization_id      => p_organization_id
            , p_inventory_item_id    => p_inventory_item_id
            , p_revision             => p_revision
            , p_subinventory_code    => p_subinventory_code
            , p_locator_id           => p_locator_id
            , p_lot_number           => p_lot_number
            , p_primary_quantity     => p_primary_quantity
            , p_qoh                  => NULL
            , p_atr                  => NULL
            , x_return_status        => x_return_status
            , x_msg_count            => x_msg_count
            , x_msg_data             => x_msg_data);


 IF (NOT l_lot_indiv_trx_valid) THEN
   -- the transaction is not valid regarding lot indivisible:
   IF (l_debug = 1) THEN
      inv_log_util.trace('validate_quantities: INV_LOT_API_PUB.VALIDATE_LOT_INDIVISIBLE (ERROR)', g_pkg_name, 9);
   END IF;
   RAISE FND_API.G_EXC_ERROR;
 END IF;
 IF (l_debug = 1) THEN
   inv_log_util.trace('validate_quantities: INV_LOT_API_PUB.VALIDATE_LOT_INDIVISIBLE (PASS) ', g_pkg_name, 9);
 END IF;

END IF;--}    -- l_lot_divisible_flag = 'N'

IF (l_debug = 1) THEN
  inv_log_util.trace('validate_quantities: End .... ', g_pkg_name, 9);
END IF;

RETURN TRUE;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (l_debug = 1) THEN
      inv_log_util.trace('validate_quantities: FND_API.G_EXC_ERROR ', g_pkg_name, 9);
    END IF;
    FND_MSG_PUB.Count_AND_GET (p_count => x_msg_count, p_data  => x_msg_data);
    RETURN FALSE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (l_debug = 1) THEN
      inv_log_util.trace('validate_quantities:when unexp sqlcode= '||sqlcode||' sqlerrm= '||substr(sqlerrm,1,240), g_pkg_name, 9);
    END IF;
    FND_MSG_PUB.Count_AND_GET (p_count => x_msg_count, p_data  => x_msg_data);
    RETURN FALSE;

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (l_debug = 1) THEN
      inv_log_util.trace('validate_quantities:when others sqlcode= '||sqlcode||' sqlerrm= '||substr(sqlerrm,1,240), g_pkg_name, 9);
    END IF;
    FND_MSG_PUB.Count_AND_GET (p_count => x_msg_count, p_data  => x_msg_data);
    RETURN FALSE;

END validate_quantities;

--This procedure checks whether lot specific conversion exist in source org or not
--If lot specific conversion exist then it will create the lot specific conversion
-- in desitnation org
--BUG#10202198

PROCEDURE lot_UOM_conv_OrgTxf (
  p_organization_id      IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, p_xfr_organization_id    IN  NUMBER
, p_lot_number           IN  VARCHAR2
, p_transaction_temp_id  IN   NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2)   IS

l_object_id NUMBER;
l_transaction_action_id NUMBER;
l_create_lot_uom_conversion   NUMBER;
l_value NUMBER;
l_debug NUMBER ;
l_expiration_date DATE;

CURSOR c_check_exists(p_org_id number) IS
SELECT 1
FROM   mtl_lot_uom_class_conversions
WHERE  organization_id = p_org_id
AND    lot_number = p_lot_number
AND    inventory_item_id = p_inventory_item_id ;

CURSOR check_lot_exists (p_org_id NUMBER )IS
SELECT LOT_NUMBER, EXPIRATION_DATE FROM MTL_LOT_NUMBERS
WHERE   ORGANIZATION_ID =p_org_id
  AND   INVENTORY_ITEM_ID = p_inventory_item_id
  AND   LOT_NUMBER =p_lot_number;

  l_lot_rec check_lot_exists%rowtype;

 BEGIN
 IF (l_debug = 1) THEN
 inv_log_util.trace('lot_UOM_conv_OrgTxf: inside proc ', g_pkg_name, 10);
 inv_log_util.trace('lot_UOM_conv_OrgTxf: p_organization_id '||p_organization_id, g_pkg_name, 10);
 inv_log_util.trace('lot_UOM_conv_OrgTxf: p_inventory_item_id '||p_inventory_item_id, g_pkg_name, 10) ;
 inv_log_util.trace('lot_UOM_conv_OrgTxf: p_xfr_organization_id '||p_xfr_organization_id, g_pkg_name, 10)  ;
 inv_log_util.trace('lot_UOM_conv_OrgTxf: p_lot_number '||p_lot_number, g_pkg_name, 10)   ;
 inv_log_util.trace('lot_UOM_conv_OrgTxf: p_transaction_temp_id '||p_transaction_temp_id, g_pkg_name, 10)   ;
 END IF ;


 begin
 select transaction_action_id INTO l_transaction_action_id
    FROM  MTL_MATERIAL_TRANSACTIONS_TEMP
 WHERE transaction_temp_id=p_transaction_temp_id;
 EXCEPTION
  WHEN No_Data_Found  THEN
       l_transaction_action_id:=NULL;
  END  ;

 begin
SELECT   create_lot_uom_conversion  INTO l_create_lot_uom_conversion
  FROM     mtl_parameters
  WHERE    organization_id =p_xfr_organization_id ;
       EXCEPTION
  WHEN No_Data_Found  THEN
       l_create_lot_uom_conversion:=NULL;
  END;
  IF (l_debug = 1) THEN
  inv_log_util.trace('lot_UOM_conv_OrgTxf: create_lot_uom_conversion '||l_create_lot_uom_conversion, g_pkg_name, 10);
  END IF ;
 IF (l_create_lot_uom_conversion =1 OR l_create_lot_uom_conversion=3) THEN
   IF (l_debug = 1) THEN
    inv_log_util.trace('lot_UOM_conv_OrgTxf: first IF', g_pkg_name, 10);
   END IF ;
    OPEN   c_check_exists(p_xfr_organization_id);
    FETCH  c_check_exists into l_value;
    IF  c_check_exists%FOUND THEN

    IF (l_debug = 1) THEN
    inv_log_util.trace('lot_UOM_conv_OrgTxf: cursor c_check_exists found', g_pkg_name, 10);
    END IF ;

      OPEN  check_lot_exists(p_organization_id);
      FETCH  check_lot_exists INTO  l_lot_rec;
    IF (l_debug = 1) THEN
      inv_log_util.trace('lot_UOM_conv_OrgTxf: checking check_lot_exists ', g_pkg_name, 10);
    END IF ;
      IF check_lot_exists%FOUND THEN
         CLOSE   c_check_exists;
      IF (l_debug = 1) THEN
         inv_log_util.trace('lot_UOM_conv_OrgTxf: cursor check_lot_exists found', g_pkg_name, 10);
      END IF;
         OPEN   c_check_exists(p_organization_id);
         FETCH  c_check_exists into l_value;
         IF  c_check_exists%NOTFOUND  THEN
         IF (l_debug = 1) THEN
             inv_log_util.trace('lot_UOM_conv_OrgTxf: 1', g_pkg_name, 10);
         END IF;
             create_lot_UOM_conv_orgtxf(
               p_organization_id      => p_organization_id
             , p_inventory_item_id    => p_inventory_item_id
             , p_xfr_organization_id  => p_xfr_organization_id
             , p_lot_number           => p_lot_number
             , x_return_status        => x_return_status
             , x_msg_count            => x_msg_count
             , x_msg_data             => x_msg_data);

         END IF;
      CLOSE check_lot_exists;
      ELSIF check_lot_exists%NOTFOUND THEN
      IF (l_debug = 1) THEN
      inv_log_util.trace('lot_UOM_conv_OrgTxf: in else', g_pkg_name, 10);
      END IF;

       begin
          SELECT  EXPIRATION_DATE INTO l_expiration_date FROM MTL_LOT_NUMBERS
            WHERE   ORGANIZATION_ID =p_xfr_organization_id
             AND   INVENTORY_ITEM_ID = p_inventory_item_id
             AND   LOT_NUMBER =p_lot_number;
       EXCEPTION
          WHEN No_Data_Found  THEN
               l_expiration_date:=NULL;
       END;
       IF (l_debug = 1) THEN
          inv_log_util.trace('lot_UOM_conv_OrgTxf: 2', g_pkg_name, 10);
       END IF;
                  inv_lot_api_pub.insertlot(
                  p_api_version                  => 1.0
                , p_init_msg_list                => fnd_api.g_false
                , p_commit                       => fnd_api.g_false
                , p_validation_level             => fnd_api.g_valid_level_full
                , p_inventory_item_id            => p_inventory_item_id
                , p_organization_id              => p_organization_id
                , p_lot_number                   => p_lot_number
                , p_expiration_date              => l_expiration_date
                , p_transaction_temp_id          => p_transaction_temp_id
                , p_transaction_action_id        => l_transaction_action_id
                , p_transfer_organization_id     => p_xfr_organization_id
                , x_object_id                    => l_transaction_action_id
                , x_return_status                => x_return_status
                , x_msg_count                    => x_msg_count
                , x_msg_data                     => x_msg_data
                );
     IF x_return_status <> FND_API.g_ret_sts_success THEN
    	       IF (l_debug = 1) THEN
       	       inv_log_util.trace('Lot insertion failed. ',g_pkg_name, 10);
    	       END IF;
   	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF (l_debug = 1) THEN
      inv_log_util.trace('lot_UOM_conv_OrgTxf: 3', g_pkg_name, 10);
      END IF;
      create_lot_UOM_conv_orgtxf(
            p_organization_id      => p_organization_id
          , p_inventory_item_id    => p_inventory_item_id
          , p_xfr_organization_id  => p_xfr_organization_id
          , p_lot_number           => p_lot_number
          , x_return_status        => x_return_status
          , x_msg_count            => x_msg_count
          , x_msg_data             => x_msg_data);
      CLOSE check_lot_exists;
      END IF;
     END IF;
    END IF;
    IF (l_debug = 1) THEN
    inv_log_util.trace('lot_UOM_conv_OrgTxf: end', g_pkg_name, 10);
    END IF;
    CLOSE  c_check_exists;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (l_debug = 1) THEN
      inv_log_util.trace('lot_UOM_conv_OrgTxf: FND_API.G_EXC_ERROR ', g_pkg_name, 10);
    END IF;
    FND_MSG_PUB.Count_AND_GET (p_count => x_msg_count, p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (l_debug = 1) THEN
      inv_log_util.trace('lot_UOM_conv_OrgTxf:when unexp sqlcode= '||sqlcode||' sqlerrm= '||substr(sqlerrm,1,240), g_pkg_name, 10);
    END IF;
    FND_MSG_PUB.Count_AND_GET (p_count => x_msg_count, p_data  => x_msg_data);

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (l_debug = 1) THEN
      inv_log_util.trace('lot_UOM_conv_OrgTxf:when others sqlcode= '||sqlcode||' sqlerrm= '||substr(sqlerrm,1,240), g_pkg_name, 10);
    END IF;
    FND_MSG_PUB.Count_AND_GET (p_count => x_msg_count, p_data  => x_msg_data);
END lot_UOM_conv_OrgTxf;

--this procedure inserts data in MTL_LOT_UOM_CLASS_CONVERSIONS table
--Bug#10202198

PROCEDURE create_lot_UOM_conv_orgtxf (
                 p_organization_id      IN  NUMBER
               , p_inventory_item_id    IN  NUMBER
               , p_xfr_organization_id    IN  NUMBER
               , p_lot_number           IN  VARCHAR2
               , x_return_status        OUT NOCOPY VARCHAR2
               , x_msg_count            OUT NOCOPY NUMBER
               , x_msg_data             OUT NOCOPY VARCHAR2)   IS

l_conv_seq  NUMBER;
l_debug NUMBER;

CURSOR GET_CONV_SEQ
IS
SELECT MTL_CONVERSION_ID_S.NEXTVAL
FROM FND_DUAL;

BEGIN
IF (l_debug = 1) THEN
inv_log_util.trace('create_lot_UOM_conv_orgtxf: start ', g_pkg_name, 10);
END IF;
    OPEN GET_CONV_SEQ;
     FETCH GET_CONV_SEQ INTO l_conv_seq;
     CLOSE GET_CONV_SEQ;

 INSERT INTO MTL_LOT_UOM_CLASS_CONVERSIONS(
      CONVERSION_ID,
      LOT_NUMBER,
      ORGANIZATION_ID,
      INVENTORY_ITEM_ID,
      FROM_UNIT_OF_MEASURE,
      FROM_UOM_CODE,
      FROM_UOM_CLASS,
      TO_UNIT_OF_MEASURE,
      TO_UOM_CODE,
      TO_UOM_CLASS,
      CONVERSION_RATE,
      DISABLE_DATE,
      EVENT_SPEC_DISP_ID,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE
      )
     SELECT
       l_conv_seq
,      LOT_NUMBER
,      p_organization_id
,      INVENTORY_ITEM_ID
,      FROM_UNIT_OF_MEASURE
,      FROM_UOM_CODE
,      FROM_UOM_CLASS
,      TO_UNIT_OF_MEASURE
,      TO_UOM_CODE
,      TO_UOM_CLASS
,      CONVERSION_RATE
,      DISABLE_DATE
,      EVENT_SPEC_DISP_ID
,      CREATED_BY
,      CREATION_DATE
,      LAST_UPDATED_BY
,      LAST_UPDATE_DATE
,      LAST_UPDATE_LOGIN
,      REQUEST_ID
,      PROGRAM_APPLICATION_ID
,      PROGRAM_ID
,      PROGRAM_UPDATE_DATE
FROM MTL_LOT_UOM_CLASS_CONVERSIONS
where      LOT_NUMBER=p_lot_number
and       ORGANIZATION_ID=p_xfr_organization_id
and       INVENTORY_ITEM_ID=p_inventory_item_id   ;

x_return_status := FND_API.G_RET_STS_SUCCESS;
IF (l_debug = 1) THEN
inv_log_util.trace('create_lot_UOM_conv_orgtxf: end ', g_pkg_name, 10);
END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (l_debug = 1) THEN
      inv_log_util.trace('create_lot_UOM_conv_orgtxf: FND_API.G_EXC_ERROR ', g_pkg_name, 10);
    END IF;
    FND_MSG_PUB.Count_AND_GET (p_count => x_msg_count, p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (l_debug = 1) THEN
      inv_log_util.trace('create_lot_UOM_conv_orgtxf:when unexp sqlcode= '||sqlcode||' sqlerrm= '||substr(sqlerrm,1,240), g_pkg_name, 10);
    END IF;
    FND_MSG_PUB.Count_AND_GET (p_count => x_msg_count, p_data  => x_msg_data);

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (l_debug = 1) THEN
      inv_log_util.trace('create_lot_UOM_conv_orgtxf:when others sqlcode= '||sqlcode||' sqlerrm= '||substr(sqlerrm,1,240), g_pkg_name, 10);
    END IF;
    FND_MSG_PUB.Count_AND_GET (p_count => x_msg_count, p_data  => x_msg_data);


END create_lot_UOM_conv_orgtxf;

END inv_lot_api_pub;



/
