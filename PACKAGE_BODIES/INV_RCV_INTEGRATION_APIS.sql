--------------------------------------------------------
--  DDL for Package Body INV_RCV_INTEGRATION_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_INTEGRATION_APIS" AS
  /* $Header: INVRCVIB.pls 120.12.12010000.10 2012/08/23 11:53:53 raminoch ship $*/

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_RCV_INTEGRATION_APIS';

TYPE mol_rec IS RECORD
  (line_id      NUMBER DEFAULT NULL
   ,line_number NUMBER DEFAULT NULL
   ,header_id   NUMBER DEFAULT NULL
   ,quantity    NUMBER DEFAULT NULL
   ,primary_quantity NUMBER DEFAULT NULL
   ,quantity_delivered NUMBER DEFAULT NULL
   ,quantity_detailed NUMBER DEFAULT NULL
   ,uom_code VARCHAR2(3) DEFAULT NULL
   ,inventory_item_id NUMBER DEFAULT NULL
   ,organization_id NUMBER DEFAULT NULL
   ,secondary_uom VARCHAR2(3) DEFAULT NULL
   ,secondary_quantity NUMBER DEFAULT NULL
   ,secondary_quantity_delivered NUMBER DEFAULT NULL --OPM Convergence
   ,secondary_quantity_detailed NUMBER DEFAULT NULL  --OPM Convergence
   ,secondary_required_quantity NUMBER DEFAULT NULL  --OPM Convergence
   ,backorder_delivery_detail_id NUMBER DEFAULT NULL
   ,crossdock_type NUMBER DEFAULT NULL
   );

PROCEDURE print_debug(p_err_msg VARCHAR2, p_level NUMBER) IS
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog(p_err_msg => p_err_msg, p_module => g_pkg_name||'($Revision: 120.12.12010000.10 $)', p_level => p_level);
   END IF;

END print_debug;


 procedure insert_wlpni
  (p_api_version		        IN  	NUMBER
   , p_init_msg_lst		        IN  	VARCHAR2
   , x_return_status              OUT 	NOCOPY	VARCHAR2
   , x_msg_count                  OUT 	NOCOPY	NUMBER
   , x_msg_data                   OUT 	NOCOPY	VARCHAR2
   , p_ORGANIZATION_ID            	IN 	NUMBER
   , p_LPN_ID                		IN	NUMBER
   , p_license_plate_number             IN 	VARCHAR2
   , p_LPN_GROUP_ID                  	IN 	NUMBER
   , p_PARENT_LPN_ID                 	IN 	NUMBER
   , p_PARENT_LICENSE_PLATE_NUMBER      IN 	VARCHAR2
   , p_REQUEST_ID                    	IN 	NUMBER
   , p_INVENTORY_ITEM_ID       	        IN 	NUMBER
   , p_REVISION                      	IN 	VARCHAR2
   , p_LOT_NUMBER                    	IN 	VARCHAR2
   , p_SERIAL_NUMBER                 	IN 	VARCHAR2
   , p_SUBINVENTORY_CODE     	        IN 	VARCHAR2
   , p_LOCATOR_ID                    	IN 	NUMBER
   , p_GROSS_WEIGHT_UOM_CODE            IN 	VARCHAR2
   , p_GROSS_WEIGHT                  	IN 	NUMBER
  , p_CONTENT_VOLUME_UOM_CODE           IN 	VARCHAR2
  , p_CONTENT_VOLUME          	        IN 	NUMBER
  , p_TARE_WEIGHT_UOM_CODE              IN 	VARCHAR2
  , p_TARE_WEIGHT                   	IN 	NUMBER
  , p_STATUS_ID                     	IN 	NUMBER
  , p_SEALED_STATUS                 	IN 	NUMBER
  , p_ATTRIBUTE_CATEGORY    	        IN 	VARCHAR2
  , p_ATTRIBUTE1                    	IN 	VARCHAR2
  , p_ATTRIBUTE2                    	IN 	VARCHAR2
  , p_ATTRIBUTE3                    	IN 	VARCHAR2
  , p_ATTRIBUTE4                    	IN 	VARCHAR2
  , p_ATTRIBUTE5                    	IN 	VARCHAR2
  , p_ATTRIBUTE6                    	IN 	VARCHAR2
  , p_ATTRIBUTE7                    	IN 	VARCHAR2
  , p_ATTRIBUTE8                    	IN 	VARCHAR2
  , p_ATTRIBUTE9                    	IN 	VARCHAR2
  , p_ATTRIBUTE10                   	IN 	VARCHAR2
  , p_ATTRIBUTE11                   	IN 	VARCHAR2
  , p_ATTRIBUTE12                   	IN 	VARCHAR2
  , p_ATTRIBUTE13                   	IN 	VARCHAR2
  , p_ATTRIBUTE14                   	IN 	VARCHAR2
  , p_ATTRIBUTE15                   	IN 	VARCHAR2
  , p_COST_GROUP_ID                 	IN 	NUMBER
  , p_LPN_CONTEXT                   	IN 	NUMBER
  , p_LPN_REUSABILITY             	IN 	NUMBER
  , p_OUTERMOST_LPN_ID        	        IN 	NUMBER
  , p_outermost_lpn                     IN 	VARCHAR2
  , p_HOMOGENEOUS_CONTAINER             IN 	NUMBER
  , p_SOURCE_TYPE_ID                	IN 	NUMBER
  , p_SOURCE_HEADER_ID         	        IN 	NUMBER
  , p_SOURCE_LINE_ID                	IN 	NUMBER
  , p_SOURCE_LINE_DETAIL_ID	        IN 	NUMBER
  , p_SOURCE_NAME                   	IN 	VARCHAR2
   ) IS
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
    x_return_status := g_ret_sts_success;

    IF (p_lpn_id IS NOT NULL OR p_license_plate_number IS NOT NULL) THEN
       inv_rcv_integration_pvt.insert_wlpni
	 (x_return_status                  	=> x_return_status
	  , x_msg_count                      	=> x_msg_count
	  , x_msg_data                       	=> x_msg_data
	  , p_LPN_ID                		=> p_LPN_ID
	  , p_license_plate_number             => p_license_plate_number
	  , p_PARENT_LPN_ID                 	=> p_PARENT_LPN_ID
	  , p_PARENT_LICENSE_PLATE_NUMBER      => p_PARENT_LICENSE_PLATE_NUMBER
	  , p_REQUEST_ID                    	=> p_REQUEST_ID
	  , p_INVENTORY_ITEM_ID       	        => p_INVENTORY_ITEM_ID
	  , p_REVISION                      	=> p_REVISION
	  , p_LOT_NUMBER                    	=> p_LOT_NUMBER
	  , p_SERIAL_NUMBER                 	=> p_SERIAL_NUMBER
	  , p_ORGANIZATION_ID            	=> p_ORGANIZATION_ID
	  , p_SUBINVENTORY_CODE     	        => p_SUBINVENTORY_CODE
	  , p_LOCATOR_ID                    	=> p_LOCATOR_ID
	  , p_GROSS_WEIGHT_UOM_CODE            => p_GROSS_WEIGHT_UOM_CODE
	  , p_GROSS_WEIGHT                  	=> p_GROSS_WEIGHT
	  , p_CONTENT_VOLUME_UOM_CODE           => p_CONTENT_VOLUME_UOM_CODE
	 , p_CONTENT_VOLUME          	        => p_CONTENT_VOLUME
	 , p_TARE_WEIGHT_UOM_CODE              => p_TARE_WEIGHT_UOM_CODE
	 , p_TARE_WEIGHT                   	=> p_TARE_WEIGHT
	 , p_STATUS_ID                     	=> p_STATUS_ID
	 , p_SEALED_STATUS                 	=> p_SEALED_STATUS
	 , p_ATTRIBUTE_CATEGORY    	        => p_ATTRIBUTE_CATEGORY
	 , p_ATTRIBUTE1                    	=> p_ATTRIBUTE1
	 , p_ATTRIBUTE2                    	=> p_ATTRIBUTE2
	 , p_ATTRIBUTE3                    	=> p_ATTRIBUTE3
	 , p_ATTRIBUTE4                    	=> p_ATTRIBUTE4
	 , p_ATTRIBUTE5                    	=> p_ATTRIBUTE5
	 , p_ATTRIBUTE6                    	=> p_ATTRIBUTE6
	 , p_ATTRIBUTE7                    	=> p_ATTRIBUTE7
	 , p_ATTRIBUTE8                    	=> p_ATTRIBUTE8
	 , p_ATTRIBUTE9                    	=> p_ATTRIBUTE9
	 , p_ATTRIBUTE10                   	=> p_ATTRIBUTE10
	 , p_ATTRIBUTE11                   	=> p_ATTRIBUTE11
	 , p_ATTRIBUTE12                   	=> p_ATTRIBUTE12
	 , p_ATTRIBUTE13                   	=> p_ATTRIBUTE13
	 , p_ATTRIBUTE14                   	=> p_ATTRIBUTE14
	 , p_ATTRIBUTE15                   	=> p_ATTRIBUTE15
	 , p_COST_GROUP_ID                 	=> p_COST_GROUP_ID
	 , p_LPN_CONTEXT                   	=> p_LPN_CONTEXT
	 , p_LPN_REUSABILITY             	=> p_LPN_REUSABILITY
	 , p_OUTERMOST_LPN_ID        	        => p_OUTERMOST_LPN_ID
	 --, p_outermost_lpn                     => p_outermost_lpn
	 , p_HOMOGENEOUS_CONTAINER             => p_HOMOGENEOUS_CONTAINER
	 , p_SOURCE_TYPE_ID                	=> p_SOURCE_TYPE_ID
	 , p_SOURCE_HEADER_ID         	        => p_SOURCE_HEADER_ID
	 , p_SOURCE_LINE_ID                	=> p_SOURCE_LINE_ID
	 , p_SOURCE_LINE_DETAIL_ID	        => p_SOURCE_LINE_DETAIL_ID
	 , p_SOURCE_NAME                   	=> p_SOURCE_NAME
	 , p_LPN_GROUP_ID                  	=> p_LPN_GROUP_ID
	 );
     ELSE
       IF (l_debug = 1) THEN
	  print_debug('INSERT_WLPNI - WLPNI not inserted as both LPN and  LPNID are NULL',1);
       END IF;
    END IF;

 END insert_wlpni;


  PROCEDURE insert_mtli (
      p_api_version                IN             NUMBER
    , p_init_msg_lst               IN             VARCHAR2
    , x_return_status              OUT  NOCOPY    VARCHAR2
    , x_msg_count                  OUT  NOCOPY    NUMBER
    , x_msg_data                   OUT  NOCOPY    VARCHAR2
    , p_transaction_interface_id   IN OUT NOCOPY  NUMBER
    , p_lot_number                 IN             VARCHAR2
    , p_transaction_quantity       IN             NUMBER
    , p_primary_quantity           IN             NUMBER
    , p_organization_id            IN             NUMBER
    , p_inventory_item_id          IN             NUMBER
    , p_expiration_date            IN             DATE
    , p_status_id                  IN             NUMBER
    , x_serial_transaction_temp_id OUT  NOCOPY    NUMBER
    , p_product_transaction_id     IN OUT NOCOPY  NUMBER
    , p_product_code               IN             VARCHAR2
    , p_att_exist                  IN             VARCHAR2
    , p_update_mln                 IN             VARCHAR2
    , p_description                IN             VARCHAR2
    , p_vendor_name                IN             VARCHAR2
    , p_supplier_lot_number        IN             VARCHAR2
    , p_origination_date           IN             DATE
    , p_date_code                  IN             VARCHAR2
    , p_grade_code                 IN             VARCHAR2
    , p_change_date                IN             DATE
    , p_maturity_date              IN             DATE
    , p_retest_date                IN             DATE
    , p_age                        IN             NUMBER
    , p_item_size                  IN             NUMBER
    , p_color                      IN             VARCHAR2
    , p_volume                     IN             NUMBER
    , p_volume_uom                 IN             VARCHAR2
    , p_place_of_origin            IN             VARCHAR2
    , p_best_by_date               IN             DATE
    , p_length                     IN             NUMBER
    , p_length_uom                 IN             VARCHAR2
    , p_recycled_content           IN             NUMBER
    , p_thickness                  IN             NUMBER
    , p_thickness_uom              IN             VARCHAR2
    , p_width                      IN             NUMBER
    , p_width_uom                  IN             VARCHAR2
    , p_curl_wrinkle_fold          IN             VARCHAR2
    , p_vendor_id                  IN             NUMBER
    , p_territory_code             IN             VARCHAR2
    , p_lot_attribute_category     IN             VARCHAR2
    , p_c_attribute1               IN             VARCHAR2
    , p_c_attribute2               IN             VARCHAR2
    , p_c_attribute3               IN             VARCHAR2
    , p_c_attribute4               IN             VARCHAR2
    , p_c_attribute5               IN             VARCHAR2
    , p_c_attribute6               IN             VARCHAR2
    , p_c_attribute7               IN             VARCHAR2
    , p_c_attribute8               IN             VARCHAR2
    , p_c_attribute9               IN             VARCHAR2
    , p_c_attribute10              IN             VARCHAR2
    , p_c_attribute11              IN             VARCHAR2
    , p_c_attribute12              IN             VARCHAR2
    , p_c_attribute13              IN             VARCHAR2
    , p_c_attribute14              IN             VARCHAR2
    , p_c_attribute15              IN             VARCHAR2
    , p_c_attribute16              IN             VARCHAR2
    , p_c_attribute17              IN             VARCHAR2
    , p_c_attribute18              IN             VARCHAR2
    , p_c_attribute19              IN             VARCHAR2
    , p_c_attribute20              IN             VARCHAR2
    , p_d_attribute1               IN             DATE
    , p_d_attribute2               IN             DATE
    , p_d_attribute3               IN             DATE
    , p_d_attribute4               IN             DATE
    , p_d_attribute5               IN             DATE
    , p_d_attribute6               IN             DATE
    , p_d_attribute7               IN             DATE
    , p_d_attribute8               IN             DATE
    , p_d_attribute9               IN             DATE
    , p_d_attribute10              IN             DATE
    , p_n_attribute1               IN             NUMBER
    , p_n_attribute2               IN             NUMBER
    , p_n_attribute3               IN             NUMBER
    , p_n_attribute4               IN             NUMBER
    , p_n_attribute5               IN             NUMBER
    , p_n_attribute6               IN             NUMBER
    , p_n_attribute7               IN             NUMBER
    , p_n_attribute8               IN             NUMBER
    , p_n_attribute9               IN             NUMBER
    , p_n_attribute10              IN             NUMBER
    , p_attribute_category         IN             VARCHAR2
    , p_attribute1                 IN             VARCHAR2
    , p_attribute2                 IN             VARCHAR2
    , p_attribute3                 IN             VARCHAR2
    , p_attribute4                 IN             VARCHAR2
    , p_attribute5                 IN             VARCHAR2
    , p_attribute6                 IN             VARCHAR2
    , p_attribute7                 IN             VARCHAR2
    , p_attribute8                 IN             VARCHAR2
    , p_attribute9                 IN             VARCHAR2
    , p_attribute10                IN             VARCHAR2
    , p_attribute11                IN             VARCHAR2
    , p_attribute12                IN             VARCHAR2
    , p_attribute13                IN             VARCHAR2
    , p_attribute14                IN             VARCHAR2
    , p_attribute15                IN             VARCHAR2
    , p_from_org_id                IN             NUMBER
    , p_secondary_quantity         IN             NUMBER  --OPM Convergence
    , p_origination_type           IN             NUMBER--OPM Convergence
    , p_expiration_action_code     IN             VARCHAR2--OPM Convergence
    , p_expiration_action_date     IN             DATE-- OPM Convergence
    , p_hold_date                  IN             DATE--OPM Convergence
    , p_parent_lot_number          IN             VARCHAR2 --OPM Convergence
    , p_reasond_id                 IN             NUMBER --OPM convergence
    ) IS
    CURSOR c_mln_attributes(  v_lot_number        VARCHAR2
                            , v_inventory_item_id NUMBER
                            , v_organization_id   NUMBER) IS
      SELECT lot_number
         , expiration_date
         , description
         , vendor_name
         , supplier_lot_number
         , grade_code
         , origination_date
         , date_code
         , status_id
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
         , LENGTH
         , length_uom
         , recycled_content
         , thickness
         , thickness_uom
         , width
         , width_uom
         , curl_wrinkle_fold
         , vendor_id
         , territory_code
         , lot_attribute_category
         , c_attribute1
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
         , d_attribute1
         , d_attribute2
         , d_attribute3
         , d_attribute4
         , d_attribute5
         , d_attribute6
         , d_attribute7
         , d_attribute8
         , d_attribute9
         , d_attribute10
         , n_attribute1
         , n_attribute2
         , n_attribute3
         , n_attribute4
         , n_attribute5
         , n_attribute6
         , n_attribute7
         , n_attribute8
         , n_attribute9
         , n_attribute10
         , attribute_category
         , attribute1
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
         , origination_type --OPM Convergence
         , availability_type --OPM Convergence
         , expiration_action_code --OPM Convergence
         , expiration_action_date -- OPM Convergence
         , hold_date --OPM Convergence
      FROM  mtl_lot_numbers
      WHERE lot_number        = Ltrim(Rtrim(v_lot_number))
      AND   inventory_item_id = v_inventory_item_id
      AND   organization_id   = v_organization_id;

    --Local Variables
    l_transaction_interface_id    NUMBER; --transaction_interface_id generated
    l_serial_transaction_temp_id  NUMBER; --serial_transaction_temp_id generated
    l_product_transaction_id      NUMBER; --product_transaction_id generated
    l_lot_count                   NUMBER; --MTLI count for given lot and interface_id
    l_lot_exists                  NUMBER;

    l_lot_number          mtl_lot_numbers.lot_number%type := p_lot_number;
    l_expiration_date     mtl_lot_numbers.expiration_date%type := p_expiration_date;
    l_description         mtl_lot_numbers.description%type := p_description;
    l_vendor_name         mtl_lot_numbers.vendor_name%type := p_vendor_name;
    l_supplier_lot_number mtl_lot_numbers.supplier_lot_number%type := p_supplier_lot_number;
    l_grade_code          mtl_lot_numbers.grade_code%type := p_grade_code;
    l_origination_date    mtl_lot_numbers.origination_date%type := p_origination_date;
    l_date_code	        mtl_lot_numbers.date_code%type := p_date_code;
    l_status_id	        mtl_lot_numbers.status_id%type := p_status_id;
    l_change_date         mtl_lot_numbers.change_date%type := p_change_date;
    l_age                 mtl_lot_numbers.age%type := p_age;
    l_retest_date         mtl_lot_numbers.retest_date%type := p_retest_date;
    l_maturity_date       mtl_lot_numbers.maturity_date%type := p_maturity_date;
    l_item_size	        mtl_lot_numbers.item_size%type := p_item_size;
    l_color               mtl_lot_numbers.color%type := p_color;
    l_volume              mtl_lot_numbers.volume%type := p_volume;
    l_volume_uom          mtl_lot_numbers.volume_uom%type := p_volume_uom;
    l_place_of_origin     mtl_lot_numbers.place_of_origin%type := p_place_of_origin;
    l_best_by_date        mtl_lot_numbers.best_by_date%type := p_best_by_date;
    l_length              mtl_lot_numbers.length%type := p_length;
    l_length_uom          mtl_lot_numbers.length_uom%type := p_length_uom;
    l_recycled_content    mtl_lot_numbers.recycled_content%type := p_recycled_content;
    l_thickness           mtl_lot_numbers.thickness%type := p_thickness;
    l_thickness_uom       mtl_lot_numbers.thickness_uom%type := p_thickness_uom;
    l_width               mtl_lot_numbers.width%type := p_width;
    l_width_uom           mtl_lot_numbers.width_uom%type := p_width_uom;
    l_curl_wrinkle_fold   mtl_lot_numbers.curl_wrinkle_fold%type := p_curl_wrinkle_fold;
    l_vendor_id           mtl_lot_numbers.vendor_id%type := p_vendor_id;
    l_territory_code      mtl_lot_numbers.territory_code%type := p_territory_code;
    l_lot_attribute_category  mtl_lot_numbers.lot_attribute_category%TYPE := p_lot_attribute_category;
    l_c_attribute1        mtl_lot_numbers.c_attribute1%type := p_c_attribute1;
    l_c_attribute2        mtl_lot_numbers.c_attribute2%type := p_c_attribute2;
    l_c_attribute3        mtl_lot_numbers.c_attribute3%type := p_c_attribute3;
    l_c_attribute4        mtl_lot_numbers.c_attribute4%type := p_c_attribute4;
    l_c_attribute5        mtl_lot_numbers.c_attribute5%type := p_c_attribute5;
    l_c_attribute6        mtl_lot_numbers.c_attribute6%type := p_c_attribute6;
    l_c_attribute7        mtl_lot_numbers.c_attribute7%type := p_c_attribute7;
    l_c_attribute8        mtl_lot_numbers.c_attribute8%type := p_c_attribute8;
    l_c_attribute9        mtl_lot_numbers.c_attribute9%type := p_c_attribute9;
    l_c_attribute10       mtl_lot_numbers.c_attribute10%type := p_c_attribute10;
    l_c_attribute11       mtl_lot_numbers.c_attribute11%type := p_c_attribute11;
    l_c_attribute12       mtl_lot_numbers.c_attribute12%type := p_c_attribute12;
    l_c_attribute13       mtl_lot_numbers.c_attribute13%type := p_c_attribute13;
    l_c_attribute14       mtl_lot_numbers.c_attribute14%type := p_c_attribute14;
    l_c_attribute15       mtl_lot_numbers.c_attribute15%type := p_c_attribute15;
    l_c_attribute16       mtl_lot_numbers.c_attribute16%type := p_c_attribute16;
    l_c_attribute17       mtl_lot_numbers.c_attribute17%type := p_c_attribute17;
    l_c_attribute18       mtl_lot_numbers.c_attribute18%type := p_c_attribute18;
    l_c_attribute19       mtl_lot_numbers.c_attribute19%type := p_c_attribute19;
    l_c_attribute20       mtl_lot_numbers.c_attribute20%type := p_c_attribute20;
    l_d_attribute1        mtl_lot_numbers.d_attribute1%type := p_d_attribute1;
    l_d_attribute2        mtl_lot_numbers.d_attribute2%type := p_d_attribute2;
    l_d_attribute3        mtl_lot_numbers.d_attribute3%type := p_d_attribute3;
    l_d_attribute4        mtl_lot_numbers.d_attribute4%type := p_d_attribute4;
    l_d_attribute5        mtl_lot_numbers.d_attribute5%type := p_d_attribute5;
    l_d_attribute6        mtl_lot_numbers.d_attribute6%type := p_d_attribute6;
    l_d_attribute7        mtl_lot_numbers.d_attribute7%type := p_d_attribute7;
    l_d_attribute8        mtl_lot_numbers.d_attribute8%type := p_d_attribute8;
    l_d_attribute9        mtl_lot_numbers.d_attribute9%type := p_d_attribute9;
    l_d_attribute10       mtl_lot_numbers.d_attribute10%type := p_d_attribute10;
    l_n_attribute1        mtl_lot_numbers.n_attribute1%type := p_n_attribute1;
    l_n_attribute2        mtl_lot_numbers.n_attribute2%type := p_n_attribute2;
    l_n_attribute3        mtl_lot_numbers.n_attribute3%type := p_n_attribute3;
    l_n_attribute4        mtl_lot_numbers.n_attribute4%type := p_n_attribute4;
    l_n_attribute5        mtl_lot_numbers.n_attribute5%type := p_n_attribute5;
    l_n_attribute6        mtl_lot_numbers.n_attribute6%type := p_n_attribute6;
    l_n_attribute7        mtl_lot_numbers.n_attribute7%type := p_n_attribute7;
    l_n_attribute8        mtl_lot_numbers.n_attribute8%type := p_n_attribute8;
    l_n_attribute9        mtl_lot_numbers.n_attribute9%type := p_n_attribute9;
    l_n_attribute10       mtl_lot_numbers.n_attribute10%type := p_n_attribute10;
    l_attribute_category  mtl_lot_numbers.attribute_category%type := p_attribute_category;
    l_attribute1          mtl_lot_numbers.attribute1%type := p_attribute1;
    l_attribute2          mtl_lot_numbers.attribute2%type := p_attribute2;
    l_attribute3          mtl_lot_numbers.attribute3%type := p_attribute3;
    l_attribute4          mtl_lot_numbers.attribute4%type := p_attribute4;
    l_attribute5          mtl_lot_numbers.attribute5%type := p_attribute5;
    l_attribute6          mtl_lot_numbers.attribute6%type := p_attribute6;
    l_attribute7          mtl_lot_numbers.attribute7%type := p_attribute7;
    l_attribute8          mtl_lot_numbers.attribute8%type := p_attribute8;
    l_attribute9          mtl_lot_numbers.attribute9%type := p_attribute9;
    l_attribute10         mtl_lot_numbers.attribute10%type := p_attribute10;
    l_attribute11         mtl_lot_numbers.attribute11%type := p_attribute11;
    l_attribute12         mtl_lot_numbers.attribute12%type := p_attribute12;
    l_attribute13         mtl_lot_numbers.attribute13%type := p_attribute13;
    l_attribute14         mtl_lot_numbers.attribute14%type := p_attribute14;
    l_attribute15         mtl_lot_numbers.attribute15%type := p_attribute15;
    l_source_code         mtl_transaction_lots_interface.source_code%TYPE;
    l_source_line_id      mtl_transaction_lots_interface.source_line_id%TYPE;
    l_serial_control_code mtl_system_items.serial_number_control_code%TYPE;
    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'insert_mtli';
    l_progress            NUMBER; --Progress Indicator
    l_debug               NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);

    l_att_org_id NUMBER;

--nsinghi bug#5209065 START. Default the variables to input parameters.
    l_origination_type            mtl_lot_numbers.origination_type%TYPE := p_origination_type; --OPM Convergence
    l_availability_type           mtl_lot_numbers.availability_type%TYPE; --OPM Convergence
    l_expiration_action_code       mtl_lot_numbers.expiration_action_code%TYPE := p_expiration_action_code; --OPM Convergence
    l_expiration_action_date       mtl_lot_numbers.expiration_action_date%TYPE := p_expiration_action_date; -- OPM Convergence
    l_hold_date                    mtl_lot_numbers.hold_date%TYPE := p_hold_date; --OPM Convergence
    l_parent_lot_number           mtl_lot_numbers.parent_lot_number%TYPE := p_parent_lot_number; --OPM Convergence
    l_secondary_quantity          NUMBER  := p_secondary_quantity;
--nsinghi bug#5209065 END.
    /* Bug 13727314 */
    l_lot_status_id         mtl_lot_numbers.status_id%type;
    l_default_status_id number:= NULL;
    l_allow_status_entry VARCHAR2(3)   := NVL(fnd_profile.VALUE('INV_ALLOW_ONHAND_STATUS_ENTRY'), 'N');

  BEGIN

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, 'inv_rcv_integration_apis') THEN
      print_debug('FND_API not compatible inv_rcv_integration_apis.insert_mtli', 4);
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
    END IF;

    --Initialize the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --If the lot number and transaction_interface_id combination already exists
    --then add the specified transaction_quantity and primary_quantity to the
    --current lot interface record.
    IF p_transaction_interface_id IS NOT NULL THEN
      BEGIN
        SELECT 1
             , serial_transaction_temp_id
          INTO l_lot_count
             , x_serial_transaction_temp_id
          FROM mtl_transaction_lots_interface MTLI
          WHERE transaction_interface_id = p_transaction_interface_id
           AND product_transaction_id   = p_product_transaction_id
           AND Ltrim(Rtrim(lot_number)) = Ltrim(Rtrim(p_lot_number))
           AND ROWNUM = 1
           AND EXISTS (
               SELECT 1
                 FROM rcv_transactions_interface RTI
               WHERE  RTI.INTERFACE_TRANSACTION_ID  = MTLI.product_transaction_id
                 AND  RTI.item_id = p_inventory_item_id
                 AND  RTI.to_organization_id   = p_organization_id
                 );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_lot_count  := 0;
        WHEN OTHERS THEN
          l_lot_count  := 0;
          IF (l_debug = 1) THEN
            print_debug('Exception trying to find lot existance', 4);
          END IF;
      END;

      IF (l_debug = 1) THEN
        print_debug('Count of lots records for the intf id: ' || l_lot_count, 4);
      END IF;

      IF l_lot_count = 1 THEN
        UPDATE  mtl_transaction_lots_interface
        SET     transaction_quantity = transaction_quantity + p_transaction_quantity
              , primary_quantity = primary_quantity + p_primary_quantity
              , secondary_transaction_quantity = secondary_transaction_quantity + p_secondary_quantity
        WHERE   transaction_interface_id = p_transaction_interface_id
        AND     Ltrim(Rtrim(lot_number)) = Ltrim(Rtrim(p_lot_number));

        IF (l_debug = 1) THEN
          print_debug('Updated ' || SQL%ROWCOUNT || ' lot record(s)', 4);
        END IF;

        --Since the attributes have already been updated, just do nothing
        RETURN;
      END IF;   --END IF lot_count = 1
    END IF;   --END IF p_transaction_interface_id IS NOT NULL

    --Generate transaction_interface_id if the parameter is NULL
    IF (p_transaction_interface_id IS NULL) THEN
      SELECT  mtl_material_transactions_s.NEXTVAL
      INTO    l_transaction_interface_id
      FROM    sys.dual;
    ELSE
      l_transaction_interface_id := p_transaction_interface_id;
    END IF;

    l_serial_control_code := inv_rcv_cache.get_sn_ctrl_code(p_organization_id,p_inventory_item_id);

    IF l_serial_control_code not in (1,6) THEN -- Bug 9008016
      SELECT  mtl_material_transactions_s.NEXTVAL
      INTO    l_serial_transaction_temp_id
      FROM    sys.DUAL;
    ELSE
      l_serial_transaction_temp_id := NULL;
    END IF;

    --Generate production_transaction_id if the parameter is NULL
    IF (p_product_transaction_id IS NULL) THEN
      SELECT  rcv_transactions_interface_s.NEXTVAL
      INTO    l_product_transaction_id
      FROM    sys.dual;
    ELSE
      l_product_transaction_id := p_product_transaction_id;
    END IF;

    /*  Logic to insert lot attributes.
     *  Check the value of the parameter p_att_exist
     *  If this value is "N" then use the input parameters to insert the attributes
     *  If this value is "Y", then open the cursor passing the lot, item and org
     *  Use the values fetched from the cursor to insert the attributes
     */
    IF (NVL(p_att_exist, 'Y') = 'Y') THEN
       IF p_from_org_id IS NOT NULL THEN
	       l_att_org_id := p_from_org_id;
	    ELSE
	       l_att_org_id := p_organization_id;
       END IF;

      BEGIN
        OPEN  c_mln_attributes(p_lot_number, p_inventory_item_id, l_att_org_id);
        FETCH c_mln_attributes INTO
           l_lot_number
         , l_expiration_date
         , l_description
         , l_vendor_name
         , l_supplier_lot_number
         , l_grade_code
         , l_origination_date
         , l_date_code
         , l_status_id
         , l_change_date
         , l_age
         , l_retest_date
         , l_maturity_date
         , l_item_size
         , l_color
         , l_volume
         , l_volume_uom
         , l_place_of_origin
         , l_best_by_date
         , l_length
         , l_length_uom
         , l_recycled_content
         , l_thickness
         , l_thickness_uom
         , l_width
         , l_width_uom
         , l_curl_wrinkle_fold
         , l_vendor_id
         , l_territory_code
         , l_lot_attribute_category
         , l_c_attribute1
         , l_c_attribute2
         , l_c_attribute3
         , l_c_attribute4
         , l_c_attribute5
         , l_c_attribute6
         , l_c_attribute7
         , l_c_attribute8
         , l_c_attribute9
         , l_c_attribute10
         , l_c_attribute11
         , l_c_attribute12
         , l_c_attribute13
         , l_c_attribute14
         , l_c_attribute15
         , l_c_attribute16
         , l_c_attribute17
         , l_c_attribute18
         , l_c_attribute19
         , l_c_attribute20
         , l_d_attribute1
         , l_d_attribute2
         , l_d_attribute3
         , l_d_attribute4
         , l_d_attribute5
         , l_d_attribute6
         , l_d_attribute7
         , l_d_attribute8
         , l_d_attribute9
         , l_d_attribute10
         , l_n_attribute1
         , l_n_attribute2
         , l_n_attribute3
         , l_n_attribute4
         , l_n_attribute5
         , l_n_attribute6
         , l_n_attribute7
         , l_n_attribute8
         , l_n_attribute9
         , l_n_attribute10
         , l_attribute_category
         , l_attribute1
         , l_attribute2
         , l_attribute3
         , l_attribute4
         , l_attribute5
         , l_attribute6
         , l_attribute7
         , l_attribute8
         , l_attribute9
         , l_attribute10
         , l_attribute11
         , l_attribute12
         , l_attribute13
         , l_attribute14
         , l_attribute15
         , l_origination_type
         , l_availability_type
         , l_expiration_action_code
         , l_expiration_action_date
         , l_hold_date;
        IF c_mln_attributes%ISOPEN THEN
          CLOSE c_mln_attributes;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
        IF c_mln_attributes%ISOPEN THEN
          CLOSE c_mln_attributes;
        END IF;
      END;
    END IF;   --END IF p_att_exist = 'Y'

       /* Bug 13727314 */

       if inv_cache.set_org_rec(p_organization_id) then
        l_default_status_id :=  inv_cache.org_rec.default_status_id;
       end if;

       IF (l_default_status_id is not null AND l_allow_status_entry  = 'Y' AND l_serial_control_code not in (2,5)) THEN
        l_lot_status_id := p_status_id;
       else
        l_lot_status_id := l_status_id;
       END IF;

    INSERT INTO MTL_TRANSACTION_LOTS_INTERFACE (
             transaction_interface_id
           , source_code
           , source_line_id
           , last_update_date
           , last_updated_by
           , creation_date
           , created_by
           , last_update_login
           , lot_number
           , lot_expiration_date
           , transaction_quantity
           , primary_quantity
           , serial_transaction_temp_id
           , description
           , vendor_name
           , supplier_lot_number
           , origination_date
           , date_code
           , grade_code
           , change_date
           , maturity_date
           , status_id
           , retest_date
           , age
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
           , curl_wrinkle_fold
           , lot_attribute_category
           , c_attribute1
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
           , d_attribute1
           , d_attribute2
           , d_attribute3
           , d_attribute4
           , d_attribute5
           , d_attribute6
           , d_attribute7
           , d_attribute8
           , d_attribute9
           , d_attribute10
           , n_attribute1
           , n_attribute2
           , n_attribute3
           , n_attribute4
           , n_attribute5
           , n_attribute6
           , n_attribute7
           , n_attribute8
           , n_attribute9
           , n_attribute10
           , vendor_id
           , territory_code
           , product_transaction_id
           , product_code
/*           , attribute_category
           , attribute1
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
           , attribute15           */
           , origination_type      --OPM Convergence
           , expiration_action_code   --OPM Convergence
           , expiration_action_date   --OPM Convergence
           , hold_date               --OPM Convergence
           , secondary_transaction_quantity --OPM Convergence
           , parent_lot_number --OPM Convergence
           )
    VALUES (
             l_transaction_interface_id
           , l_source_code
           , l_source_line_id
           , SYSDATE
           , FND_GLOBAL.USER_ID
           , SYSDATE
           , FND_GLOBAL.USER_ID
           , FND_GLOBAL.LOGIN_ID
           , Ltrim(Rtrim(p_lot_number))
           , l_expiration_date
           , p_transaction_quantity
           , p_primary_quantity
           , l_serial_transaction_temp_id
           , l_description
           , l_vendor_name
           , l_supplier_lot_number
           , l_origination_date
           , l_date_code
           , l_grade_code
           , l_change_date
           , l_maturity_date
           , l_lot_status_id  --Bug13727314
           , l_retest_date
           , l_age
           , l_item_size
           , l_color
           , l_volume
           , l_volume_uom
           , l_place_of_origin
           , l_best_by_date
           , l_length
           , l_length_uom
           , l_recycled_content
           , l_thickness
           , l_thickness_uom
           , l_width
           , l_width_uom
           , l_curl_wrinkle_fold
           , l_lot_attribute_category
           , l_c_attribute1
           , l_c_attribute2
           , l_c_attribute3
           , l_c_attribute4
           , l_c_attribute5
           , l_c_attribute6
           , l_c_attribute7
           , l_c_attribute8
           , l_c_attribute9
           , l_c_attribute10
           , l_c_attribute11
           , l_c_attribute12
           , l_c_attribute13
           , l_c_attribute14
           , l_c_attribute15
           , l_c_attribute16
           , l_c_attribute17
           , l_c_attribute18
           , l_c_attribute19
           , l_c_attribute20
           , l_d_attribute1
           , l_d_attribute2
           , l_d_attribute3
           , l_d_attribute4
           , l_d_attribute5
           , l_d_attribute6
           , l_d_attribute7
           , l_d_attribute8
           , l_d_attribute9
           , l_d_attribute10
           , l_n_attribute1
           , l_n_attribute2
           , l_n_attribute3
           , l_n_attribute4
           , l_n_attribute5
           , l_n_attribute6
           , l_n_attribute7
           , l_n_attribute8
           , l_n_attribute9
           , l_n_attribute10
           , l_vendor_id
           , l_territory_code
           , l_product_transaction_id
           , p_product_code
/*           , l_attribute_category
           , l_attribute1
           , l_attribute2
           , l_attribute3
           , l_attribute4
           , l_attribute5
           , l_attribute6
           , l_attribute7
           , l_attribute8
           , l_attribute9
           , l_attribute10
           , l_attribute11
           , l_attribute12
           , l_attribute13
           , l_attribute14
           , l_attribute15           */
           , l_origination_type      --OPM Convergence
           , l_expiration_action_code   --OPM Convergence
           , l_expiration_action_date   --OPM Convergence
           , l_hold_date               --OPM Convergence
           , p_secondary_quantity --OPM Convergence
           , l_parent_lot_number --OPM Convergence
            );

    --If the flag p_update_mln is set to 'Y' then update MTL_LOT_NUMBERS
    --with the attributes from the parameters
    IF (NVL(p_update_mln, 'N') = 'Y') THEN
      BEGIN
        SELECT  count(1)
        INTO    l_lot_exists
        FROM    mtl_lot_numbers
        WHERE   lot_number        = Ltrim(Rtrim(p_lot_number))
        AND     inventory_item_id = p_inventory_item_id
        AND     organization_id   = p_organization_id;

        IF l_lot_exists > 0 THEN
          UPDATE  mtl_lot_numbers
          SET  description            = l_description
             , vendor_name            = l_vendor_name
             , supplier_lot_number    = l_supplier_lot_number
             , origination_date       = l_origination_date
             , date_code              = l_date_code
             , grade_code             = l_grade_code
             , change_date            = l_change_date
             , maturity_date          = l_maturity_date
             , retest_date            = l_retest_date
             , age                    = l_age
             , item_size              = l_item_size
             , color                  = l_color
             , volume                 = l_volume
             , volume_uom             = l_volume_uom
             , place_of_origin        = l_place_of_origin
             , best_by_date           = l_best_by_date
             , length                 = l_length
             , length_uom             = l_length_uom
             , recycled_content       = l_recycled_content
             , thickness              = l_thickness
             , thickness_uom          = l_thickness_uom
             , width                  = l_width
             , width_uom              = l_width_uom
             , curl_wrinkle_fold      = l_curl_wrinkle_fold
             , vendor_id              = l_vendor_id
             , territory_code         = l_territory_code
             , lot_attribute_category = l_lot_attribute_category
             , c_attribute1           = l_c_attribute1
             , c_attribute2           = l_c_attribute2
             , c_attribute3           = l_c_attribute3
             , c_attribute4           = l_c_attribute4
             , c_attribute5           = l_c_attribute5
             , c_attribute6           = l_c_attribute6
             , c_attribute7           = l_c_attribute7
             , c_attribute8           = l_c_attribute8
             , c_attribute9           = l_c_attribute9
             , c_attribute10          = l_c_attribute10
             , c_attribute11          = l_c_attribute11
             , c_attribute12          = l_c_attribute12
             , c_attribute13          = l_c_attribute13
             , c_attribute14          = l_c_attribute14
             , c_attribute15          = l_c_attribute15
             , c_attribute16          = l_c_attribute16
             , c_attribute17          = l_c_attribute17
             , c_attribute18          = l_c_attribute18
             , c_attribute19          = l_c_attribute19
             , c_attribute20          = l_c_attribute20
             , d_attribute1           = l_d_attribute1
             , d_attribute2           = l_d_attribute2
             , d_attribute3           = l_d_attribute3
             , d_attribute4           = l_d_attribute4
             , d_attribute5           = l_d_attribute5
             , d_attribute6           = l_d_attribute6
             , d_attribute7           = l_d_attribute7
             , d_attribute8           = l_d_attribute8
             , d_attribute9           = l_d_attribute9
             , d_attribute10          = l_d_attribute10
             , n_attribute1           = l_n_attribute1
             , n_attribute2           = l_n_attribute2
             , n_attribute3           = l_n_attribute3
             , n_attribute4           = l_n_attribute4
             , n_attribute5           = l_n_attribute5
             , n_attribute6           = l_n_attribute6
             , n_attribute7           = l_n_attribute7
             , n_attribute8           = l_n_attribute8
             , n_attribute9           = l_n_attribute9
             , n_attribute10          = l_n_attribute10
             , attribute_category     = l_attribute_category
             , attribute1             = l_attribute1
             , attribute2             = l_attribute2
             , attribute3             = l_attribute3
             , attribute4             = l_attribute4
             , attribute5             = l_attribute5
             , attribute6             = l_attribute6
             , attribute7             = l_attribute7
             , attribute8             = l_attribute8
             , attribute9             = l_attribute9
             , attribute10            = l_attribute10
             , attribute11            = l_attribute11
             , attribute12            = l_attribute12
             , attribute13            = l_attribute13
             , attribute14            = l_attribute14
             , attribute15            = l_attribute15
             , origination_type       = l_origination_type      --OPM Convergence
             , availability_type      = l_availability_type     --OPM Convergence
             , expiration_action_code = l_expiration_action_code--OPM Convergence
             , expiration_action_date = l_expiration_action_date --OPM Convergence
             , hold_date              = l_hold_date                --OPM Convergence
             , parent_lot_number      = l_parent_lot_number      --OPM Convergence
          WHERE lot_number            = Ltrim(Rtrim(p_lot_number))
          AND   inventory_item_id     = p_inventory_item_id
          AND   organization_id       = p_organization_id;
        END IF;   --END If lot exists
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;   --END IF p_update_mln = 'Y'

    --Reassign the generated values
    p_transaction_interface_id := l_transaction_interface_id;
    x_serial_transaction_temp_id := l_serial_transaction_temp_id;
    p_product_transaction_id := l_product_transaction_id;

    IF (l_debug = 1) THEN
      print_debug('p_transaction_interface_id returned: ' || p_transaction_interface_id, 4);
      print_debug('x_serial_transaction_temp_id returned: ' || x_serial_transaction_temp_id, 4);
      print_debug('p_product_transaction_id returned: ' || p_product_transaction_id, 4);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF c_mln_attributes%ISOPEN THEN
        CLOSE c_mln_attributes;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF c_mln_attributes%ISOPEN THEN
        CLOSE c_mln_attributes;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN OTHERS THEN
      IF c_mln_attributes%ISOPEN THEN
        CLOSE c_mln_attributes;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error (
          'INV_RCV_INTEGRATION_APIS.INSERT_MTLI',
          l_progress,
          SQLCODE);
      END IF;
  END insert_mtli;

  /*----------------------------------------------------------------------------
    * PROCEDURE: insert_msni
    * Description:
    *   This procedure inserts a record into MTL_SERIAL_NUMBERS_INTERFACE
    *     Generate transaction_interface_id if the parameter is NULL
    *     Generate product_transaction_id if the parameter is NULL
    *     The insert logic is based on the parameter p_att_exist.
    *     If p_att_exist is "N" Then (attributes are not available in table)
    *       Read the input parameters (including attributes) into a PL/SQL table
    *       Insert one record into MSNI with the from and to serial numbers passed
    *     Else
    *       Loop through each serial number between the from and to serial number
    *       Fetch the attributes into one row of the PL/SQL table and
    *     For each row in the PL/SQL table, insert one MSNI record
    *     End If
    *
    *    @param p_api_version             - Version of the API
    *    @param p_init_msg_lst            - Flag to initialize message list
    *    @param x_return_status
    *      Return status indicating Success (S), Error (E), Unexpected Error (U)
    *    @param x_msg_count
    *      Number of messages in  message list
    *    @param x_msg_data
    *      Stacked messages text
    *    @param p_transaction_interface_id - MTLI.Interface Transaction ID
    *    @param p_fm_serial_number         - From Serial Number
    *    @param p_to_serial_number         - To Serial Number
    *    @param p_organization_id         - Organization ID
    *    @param p_inventory_item_id       - Inventory Item ID
    *    @param p_status_id               - Material Status for the lot
    *    @param p_product_transaction_id  - Product Transaction Id. This parameter
    *           is stamped with the transaction identifier with
    *    @param p_product_code            - Code of the product creating this record
    *    @param p_att_exist               - Flag to indicate if attributes exist
    *    @param p_update_msn              - Flag to update MSN with attributes
    *    @param named attributes          - Named attributes
    *    @param C Attributes              - Character atributes (1 - 20)
    *    @param D Attributes              - Date atributes (1 - 10)
    *    @param N Attributes              - Number atributes (1 - 10)
    *    @param p_attribute_cateogry      - Attribute Category
    *    @param Attribute1-15             - Serial Attributes
    *
    * @ return: NONE
    *---------------------------------------------------------------------------*/

  PROCEDURE insert_msni(
    p_api_version               IN            NUMBER
  , p_init_msg_lst              IN            VARCHAR2
  , x_return_status             OUT    NOCOPY VARCHAR2
  , x_msg_count                 OUT    NOCOPY NUMBER
  , x_msg_data                  OUT    NOCOPY VARCHAR2
  , p_transaction_interface_id  IN OUT NOCOPY NUMBER
  , p_fm_serial_number          IN            VARCHAR2
  , p_to_serial_number          IN            VARCHAR2
  , p_organization_id           IN            NUMBER
  , p_inventory_item_id         IN            NUMBER
  , p_status_id                 IN            NUMBER
  , p_product_transaction_id    IN OUT NOCOPY NUMBER
  , p_product_code              IN            VARCHAR2
  , p_att_exist                 IN            VARCHAR2
  , p_update_msn                IN            VARCHAR2
  , p_vendor_serial_number      IN            VARCHAR2
  , p_vendor_lot_number         IN            VARCHAR2
  , p_parent_serial_number      IN            VARCHAR2
  , p_origination_date          IN            DATE
  , p_territory_code            IN            VARCHAR2
  , p_time_since_new            IN            NUMBER
  , p_cycles_since_new          IN            NUMBER
  , p_time_since_overhaul       IN            NUMBER
  , p_cycles_since_overhaul     IN            NUMBER
  , p_time_since_repair         IN            NUMBER
  , p_cycles_since_repair       IN            NUMBER
  , p_time_since_visit          IN            NUMBER
  , p_cycles_since_visit        IN            NUMBER
  , p_time_since_mark           IN            NUMBER
  , p_cycles_since_mark         IN            NUMBER
  , p_number_of_repairs         IN            NUMBER
  , p_serial_attribute_category IN            VARCHAR2
  , p_c_attribute1              IN            VARCHAR2
  , p_c_attribute2              IN            VARCHAR2
  , p_c_attribute3              IN            VARCHAR2
  , p_c_attribute4              IN            VARCHAR2
  , p_c_attribute5              IN            VARCHAR2
  , p_c_attribute6              IN            VARCHAR2
  , p_c_attribute7              IN            VARCHAR2
  , p_c_attribute8              IN            VARCHAR2
  , p_c_attribute9              IN            VARCHAR2
  , p_c_attribute10             IN            VARCHAR2
  , p_c_attribute11             IN            VARCHAR2
  , p_c_attribute12             IN            VARCHAR2
  , p_c_attribute13             IN            VARCHAR2
  , p_c_attribute14             IN            VARCHAR2
  , p_c_attribute15             IN            VARCHAR2
  , p_c_attribute16             IN            VARCHAR2
  , p_c_attribute17             IN            VARCHAR2
  , p_c_attribute18             IN            VARCHAR2
  , p_c_attribute19             IN            VARCHAR2
  , p_c_attribute20             IN            VARCHAR2
  , p_d_attribute1              IN            DATE
  , p_d_attribute2              IN            DATE
  , p_d_attribute3              IN            DATE
  , p_d_attribute4              IN            DATE
  , p_d_attribute5              IN            DATE
  , p_d_attribute6              IN            DATE
  , p_d_attribute7              IN            DATE
  , p_d_attribute8              IN            DATE
  , p_d_attribute9              IN            DATE
  , p_d_attribute10             IN            DATE
  , p_n_attribute1              IN            NUMBER
  , p_n_attribute2              IN            NUMBER
  , p_n_attribute3              IN            NUMBER
  , p_n_attribute4              IN            NUMBER
  , p_n_attribute5              IN            NUMBER
  , p_n_attribute6              IN            NUMBER
  , p_n_attribute7              IN            NUMBER
  , p_n_attribute8              IN            NUMBER
  , p_n_attribute9              IN            NUMBER
  , p_n_attribute10             IN            NUMBER
  , p_attribute_category        IN            VARCHAR2
  , p_attribute1                IN            VARCHAR2
  , p_attribute2                IN            VARCHAR2
  , p_attribute3                IN            VARCHAR2
  , p_attribute4                IN            VARCHAR2
  , p_attribute5                IN            VARCHAR2
  , p_attribute6                IN            VARCHAR2
  , p_attribute7                IN            VARCHAR2
  , p_attribute8                IN            VARCHAR2
  , p_attribute9                IN            VARCHAR2
  , p_attribute10               IN            VARCHAR2
  , p_attribute11               IN            VARCHAR2
  , p_attribute12               IN            VARCHAR2
  , p_attribute13               IN            VARCHAR2
  , p_attribute14               IN            VARCHAR2
  , p_attribute15               IN            VARCHAR2
  ) IS
    CURSOR c_msn_attributes (   v_serial_number VARCHAR2,
                                v_inventory_item_id NUMBER) IS
      SELECT serial_number   fm_serial_number
           , serial_number   to_serial_number
           , to_number(NULL) transaction_interface_id
           , status_id
           , to_number(NULL) product_transaction_id
           , to_char(NULL)   product_code
           , vendor_serial_number
           , vendor_lot_number
           , parent_serial_number
           , origination_date
           , territory_code
           , time_since_new
           , cycles_since_new
           , time_since_overhaul
           , cycles_since_overhaul
           , time_since_repair
           , cycles_since_repair
           , time_since_visit
           , cycles_since_visit
           , time_since_mark
           , cycles_since_mark
           , number_of_repairs
           , serial_attribute_category
           , c_attribute1
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
           , d_attribute1
           , d_attribute2
           , d_attribute3
           , d_attribute4
           , d_attribute5
           , d_attribute6
           , d_attribute7
           , d_attribute8
           , d_attribute9
           , d_attribute10
           , n_attribute1
           , n_attribute2
           , n_attribute3
           , n_attribute4
           , n_attribute5
           , n_attribute6
           , n_attribute7
           , n_attribute8
           , n_attribute9
           , n_attribute10
           , attribute_category
           , attribute1
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
        FROM mtl_serial_numbers
       WHERE serial_number = v_serial_number
         AND inventory_item_id = v_inventory_item_id;

    TYPE msni_rec_tp IS RECORD (
      fm_serial_number          mtl_serial_numbers.serial_number%TYPE
    , to_serial_number          mtl_serial_numbers.serial_number%TYPE
    , transaction_interface_id  mtl_serial_numbers_interface.transaction_interface_id%TYPE
    , status_id                 mtl_serial_numbers.status_id%TYPE
    , product_transaction_id    mtl_serial_numbers_interface.product_transaction_id%TYPE
    , product_code              mtl_serial_numbers_interface.product_code%TYPE
    , vendor_serial_number      mtl_serial_numbers.vendor_serial_number%TYPE
    , vendor_lot_number         mtl_serial_numbers.vendor_lot_number%TYPE
    , parent_serial_number      mtl_serial_numbers.parent_serial_number%TYPE
    , origination_date          mtl_serial_numbers.origination_date%TYPE
    , territory_code            mtl_serial_numbers.territory_code%TYPE
    , time_since_new            mtl_serial_numbers.time_since_new%TYPE
    , cycles_since_new          mtl_serial_numbers.cycles_since_new%TYPE
    , time_since_overhaul       mtl_serial_numbers.time_since_overhaul%TYPE
    , cycles_since_overhaul     mtl_serial_numbers.cycles_since_overhaul%TYPE
    , time_since_repair         mtl_serial_numbers.time_since_repair%TYPE
    , cycles_since_repair       mtl_serial_numbers.cycles_since_repair%TYPE
    , time_since_visit          mtl_serial_numbers.time_since_visit%TYPE
    , cycles_since_visit        mtl_serial_numbers.cycles_since_visit%TYPE
    , time_since_mark           mtl_serial_numbers.time_since_mark%TYPE
    , cycles_since_mark         mtl_serial_numbers.cycles_since_mark%TYPE
    , number_of_repairs         mtl_serial_numbers.number_of_repairs%TYPE
    , serial_attribute_category mtl_serial_numbers.serial_attribute_category%TYPE
    , c_attribute1              mtl_serial_numbers.c_attribute1%TYPE
    , c_attribute2              mtl_serial_numbers.c_attribute2%TYPE
    , c_attribute3              mtl_serial_numbers.c_attribute3%TYPE
    , c_attribute4              mtl_serial_numbers.c_attribute4%TYPE
    , c_attribute5              mtl_serial_numbers.c_attribute5%TYPE
    , c_attribute6              mtl_serial_numbers.c_attribute6%TYPE
    , c_attribute7              mtl_serial_numbers.c_attribute7%TYPE
    , c_attribute8              mtl_serial_numbers.c_attribute8%TYPE
    , c_attribute9              mtl_serial_numbers.c_attribute9%TYPE
    , c_attribute10             mtl_serial_numbers.c_attribute10%TYPE
    , c_attribute11             mtl_serial_numbers.c_attribute11%TYPE
    , c_attribute12             mtl_serial_numbers.c_attribute12%TYPE
    , c_attribute13             mtl_serial_numbers.c_attribute13%TYPE
    , c_attribute14             mtl_serial_numbers.c_attribute14%TYPE
    , c_attribute15             mtl_serial_numbers.c_attribute15%TYPE
    , c_attribute16             mtl_serial_numbers.c_attribute16%TYPE
    , c_attribute17             mtl_serial_numbers.c_attribute17%TYPE
    , c_attribute18             mtl_serial_numbers.c_attribute18%TYPE
    , c_attribute19             mtl_serial_numbers.c_attribute19%TYPE
    , c_attribute20             mtl_serial_numbers.c_attribute20%TYPE
    , d_attribute1              mtl_serial_numbers.d_attribute1%TYPE
    , d_attribute2              mtl_serial_numbers.d_attribute2%TYPE
    , d_attribute3              mtl_serial_numbers.d_attribute3%TYPE
    , d_attribute4              mtl_serial_numbers.d_attribute4%TYPE
    , d_attribute5              mtl_serial_numbers.d_attribute5%TYPE
    , d_attribute6              mtl_serial_numbers.d_attribute6%TYPE
    , d_attribute7              mtl_serial_numbers.d_attribute7%TYPE
    , d_attribute8              mtl_serial_numbers.d_attribute8%TYPE
    , d_attribute9              mtl_serial_numbers.d_attribute9%TYPE
    , d_attribute10             mtl_serial_numbers.d_attribute10%TYPE
    , n_attribute1              mtl_serial_numbers.n_attribute1%TYPE
    , n_attribute2              mtl_serial_numbers.n_attribute2%TYPE
    , n_attribute3              mtl_serial_numbers.n_attribute3%TYPE
    , n_attribute4              mtl_serial_numbers.n_attribute4%TYPE
    , n_attribute5              mtl_serial_numbers.n_attribute5%TYPE
    , n_attribute6              mtl_serial_numbers.n_attribute6%TYPE
    , n_attribute7              mtl_serial_numbers.n_attribute7%TYPE
    , n_attribute8              mtl_serial_numbers.n_attribute8%TYPE
    , n_attribute9              mtl_serial_numbers.n_attribute9%TYPE
    , n_attribute10             mtl_serial_numbers.n_attribute10%TYPE
    , attribute_category        mtl_serial_numbers_interface.attribute_category%TYPE
    , attribute1                mtl_serial_numbers.attribute1%TYPE
    , attribute2                mtl_serial_numbers.attribute2%TYPE
    , attribute3                mtl_serial_numbers.attribute3%TYPE
    , attribute4                mtl_serial_numbers.attribute4%TYPE
    , attribute5                mtl_serial_numbers.attribute5%TYPE
    , attribute6                mtl_serial_numbers.attribute6%TYPE
    , attribute7                mtl_serial_numbers.attribute7%TYPE
    , attribute8                mtl_serial_numbers.attribute8%TYPE
    , attribute9                mtl_serial_numbers.attribute9%TYPE
    , attribute10               mtl_serial_numbers.attribute10%TYPE
    , attribute11               mtl_serial_numbers.attribute11%TYPE
    , attribute12               mtl_serial_numbers.attribute12%TYPE
    , attribute13               mtl_serial_numbers.attribute13%TYPE
    , attribute14               mtl_serial_numbers.attribute14%TYPE
    , attribute15               mtl_serial_numbers.attribute15%TYPE
    );

    TYPE msni_rec_tbl_tp IS TABLE OF msni_rec_tp
      INDEX BY BINARY_INTEGER;

    --Local Variables
    l_msni_rec_tbl      msni_rec_tbl_tp; --Table to hold each MSNI record inserted
    l_transaction_interface_id  NUMBER; --transaction_interface_id generated
    l_product_transaction_id    NUMBER; --product_transaction_id generated
    l_fm_serial_number  mtl_serial_numbers.serial_number%TYPE := p_fm_serial_number;
    l_to_serial_number  mtl_serial_numbers.serial_number%TYPE := p_to_serial_number;
    l_cur_serial_number mtl_serial_numbers.serial_number%TYPE;
    l_serial_prefix             VARCHAR2(30); --serial number prefix
    l_from_ser_number           NUMBER; --numberic part of from serial number
    l_to_ser_number             NUMBER; --numeric part of to serial number
    l_cur_ser_num               NUMBER; --numeric part of current serial part
    l_ser_num_length            NUMBER; --serial number length
    l_prefix_length             NUMBER; --prefix length
    l_range_numbers             NUMBER; --no. of serial numbers in the range
    l_msni_tbl_count            NUMBER; --Count of records to be inserted
    l_user_id                   NUMBER := fnd_global.user_id;
    l_login_id                  NUMBER := fnd_global.login_id;
    l_source_code               mtl_serial_numbers_interface.source_code%TYPE;
    l_source_line_id            mtl_serial_numbers_interface.source_line_id%TYPE;
    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'insert_mtli';
    l_success                   NUMBER;
    l_progress                  NUMBER; --Progress Indicator
    l_debug                     NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, 'inv_rcv_integration_apis') THEN
      print_debug('FND_API not compatible','inv_rcv_integration_apis.insert_msni');
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
    END IF;

    --Initialize the return status
    x_return_status  := fnd_api.g_ret_sts_success;

    --Generate transaction_interface_id if necessary
    IF (p_transaction_interface_id IS NULL) THEN
      SELECT  mtl_material_transactions_s.NEXTVAL
      INTO    l_transaction_interface_id
      FROM    sys.dual;
    ELSE
      l_transaction_interface_id := p_transaction_interface_id;
    END IF;

    --Generate production_transaction_id if the parameter is NULL
    IF (p_product_transaction_id IS NULL AND p_product_code = 'RCV') THEN
      SELECT  rcv_transactions_interface_s.NEXTVAL
      INTO    l_product_transaction_id
      FROM    sys.dual;
    ELSE
      l_product_transaction_id := p_product_transaction_id;
    END IF;

    /* To insert the attributes, check the value of p_att_exist.
     * If the parameter p_att_exist is 'N' then
     *    Read the input parameters and store them in the table
     *    Create one MSNI record with from and to serial number from parameters
     * Else
     *    Loop through each serial number between from and to serial number
     *    Fetch the attributes into the table for each serial number
     *    Create on MSNI record with from and to serial number as current serial
     */
    IF (NVL(p_att_exist, 'Y') = 'N') THEN
      l_msni_rec_tbl(1).fm_serial_number := p_fm_serial_number;
      l_msni_rec_tbl(1).to_serial_number := p_to_serial_number;
      l_msni_rec_tbl(1).transaction_interface_id := l_transaction_interface_id;
      l_msni_rec_tbl(1).status_id := p_status_id;
      l_msni_rec_tbl(1).product_transaction_id := l_product_transaction_id;
      l_msni_rec_tbl(1).product_code := p_product_code;
      l_msni_rec_tbl(1).vendor_serial_number := p_vendor_serial_number;
      l_msni_rec_tbl(1).vendor_lot_number := p_vendor_lot_number;
      l_msni_rec_tbl(1).parent_serial_number := p_parent_serial_number;
      l_msni_rec_tbl(1).origination_date := p_origination_date;
      l_msni_rec_tbl(1).territory_code := p_territory_code;
      l_msni_rec_tbl(1).time_since_new := p_time_since_new;
      l_msni_rec_tbl(1).cycles_since_new  := p_cycles_since_new;
      l_msni_rec_tbl(1).time_since_overhaul := p_time_since_overhaul;
      l_msni_rec_tbl(1).cycles_since_overhaul := p_cycles_since_overhaul;
      l_msni_rec_tbl(1).time_since_repair := p_time_since_repair;
      l_msni_rec_tbl(1).cycles_since_repair :=p_cycles_since_repair;
      l_msni_rec_tbl(1).time_since_visit := p_time_since_visit;
      l_msni_rec_tbl(1).cycles_since_visit := p_cycles_since_visit;
      l_msni_rec_tbl(1).time_since_mark := p_time_since_mark;
      l_msni_rec_tbl(1).cycles_since_mark := p_cycles_since_mark;
      l_msni_rec_tbl(1).number_of_repairs := p_number_of_repairs;
      l_msni_rec_tbl(1).serial_attribute_category := p_serial_attribute_category;
      l_msni_rec_tbl(1).c_attribute1 := p_c_attribute1;
      l_msni_rec_tbl(1).c_attribute2 := p_c_attribute2;
      l_msni_rec_tbl(1).c_attribute3 := p_c_attribute3;
      l_msni_rec_tbl(1).c_attribute4 := p_c_attribute4;
      l_msni_rec_tbl(1).c_attribute5 := p_c_attribute5;
      l_msni_rec_tbl(1).c_attribute6 := p_c_attribute6;
      l_msni_rec_tbl(1).c_attribute7 := p_c_attribute7;
      l_msni_rec_tbl(1).c_attribute8 := p_c_attribute8;
      l_msni_rec_tbl(1).c_attribute9 := p_c_attribute9;
      l_msni_rec_tbl(1).c_attribute10 := p_c_attribute10;
      l_msni_rec_tbl(1).c_attribute11 := p_c_attribute11;
      l_msni_rec_tbl(1).c_attribute12 := p_c_attribute12;
      l_msni_rec_tbl(1).c_attribute13 := p_c_attribute13;
      l_msni_rec_tbl(1).c_attribute14 := p_c_attribute14;
      l_msni_rec_tbl(1).c_attribute15 := p_c_attribute15;
      l_msni_rec_tbl(1).c_attribute16 := p_c_attribute16;
      l_msni_rec_tbl(1).c_attribute17 := p_c_attribute17;
      l_msni_rec_tbl(1).c_attribute18 := p_c_attribute18;
      l_msni_rec_tbl(1).c_attribute19 := p_c_attribute19;
      l_msni_rec_tbl(1).c_attribute20 := p_c_attribute20;
      l_msni_rec_tbl(1).d_attribute1  := p_d_attribute1;
      l_msni_rec_tbl(1).d_attribute2  := p_d_attribute2;
      l_msni_rec_tbl(1).d_attribute3  := p_d_attribute3;
      l_msni_rec_tbl(1).d_attribute4  := p_d_attribute4;
      l_msni_rec_tbl(1).d_attribute5  := p_d_attribute5;
      l_msni_rec_tbl(1).d_attribute6  := p_d_attribute6;
      l_msni_rec_tbl(1).d_attribute7  := p_d_attribute7;
      l_msni_rec_tbl(1).d_attribute8  := p_d_attribute8;
      l_msni_rec_tbl(1).d_attribute9  := p_d_attribute9;
      l_msni_rec_tbl(1).d_attribute10 := p_d_attribute10;
      l_msni_rec_tbl(1).n_attribute1  := p_n_attribute1;
      l_msni_rec_tbl(1).n_attribute2  := p_n_attribute2;
      l_msni_rec_tbl(1).n_attribute3  := p_n_attribute3;
      l_msni_rec_tbl(1).n_attribute4  := p_n_attribute4;
      l_msni_rec_tbl(1).n_attribute5  := p_n_attribute5;
      l_msni_rec_tbl(1).n_attribute6  := p_n_attribute6;
      l_msni_rec_tbl(1).n_attribute7  := p_n_attribute7;
      l_msni_rec_tbl(1).n_attribute8  := p_n_attribute8;
      l_msni_rec_tbl(1).n_attribute9  := p_n_attribute9;
      l_msni_rec_tbl(1).n_attribute10 := p_n_attribute10;
      l_msni_rec_tbl(1).attribute_category := p_attribute_category;
      l_msni_rec_tbl(1).attribute1    := p_attribute1;
      l_msni_rec_tbl(1).attribute2    := p_attribute2;
      l_msni_rec_tbl(1).attribute3    := p_attribute3;
      l_msni_rec_tbl(1).attribute4    := p_attribute4;
      l_msni_rec_tbl(1).attribute5    := p_attribute5;
      l_msni_rec_tbl(1).attribute6    := p_attribute6;
      l_msni_rec_tbl(1).attribute7    := p_attribute7;
      l_msni_rec_tbl(1).attribute8    := p_attribute8;
      l_msni_rec_tbl(1).attribute9    := p_attribute9;
      l_msni_rec_tbl(1).attribute10   := p_attribute10;
      l_msni_rec_tbl(1).attribute11   := p_attribute11;
      l_msni_rec_tbl(1).attribute12   := p_attribute12;
      l_msni_rec_tbl(1).attribute13   := p_attribute13;
      l_msni_rec_tbl(1).attribute14   := p_attribute14;
      l_msni_rec_tbl(1).attribute15   := p_attribute15;
    ELSE    --fetch the serial info and attributes from MSN
      --Get the numeric part of the from and to serial numbers
      inv_validate.number_from_sequence(l_fm_serial_number, l_serial_prefix, l_from_ser_number);

      inv_validate.number_from_sequence(l_to_serial_number, l_serial_prefix, l_to_ser_number);

      --Get the no. of serials in the range, prefix length and numeric part
      l_range_numbers := l_to_ser_number - l_from_ser_number + 1;
      l_ser_num_length := LENGTH(l_fm_serial_number);
      l_prefix_length := LENGTH(l_serial_prefix);

      IF (l_debug = 1) THEN
        print_debug('No. of serials in the range : ' || l_range_numbers, 4);
        print_debug('Serial Number length: ' || l_ser_num_length, 4);
        print_debug('Prefix length : ' || l_prefix_length, 4);
      END IF;

      --For each serial number in the range, fetch the serial info and create
      --a row in the table which would later be inserted into MSNI
      FOR i IN 1 .. l_range_numbers LOOP
        l_cur_ser_num := l_from_ser_number + i -1;
        l_cur_serial_number := l_serial_prefix ||
            LPAD(l_cur_ser_num, l_ser_num_length - NVL(l_prefix_length,0),  '0');

        IF (l_debug = 1) THEN
          print_debug('current serial number : ' || l_cur_serial_number, 4);
        END IF;

        OPEN c_msn_attributes(l_cur_serial_number, p_inventory_item_id);
        FETCH c_msn_attributes INTO l_msni_rec_tbl(i);
        CLOSE c_msn_attributes;

        --Assign the values for the serial number and ids from the generated values
        l_msni_rec_tbl(i).transaction_interface_id := l_transaction_interface_id;
        l_msni_rec_tbl(i).fm_serial_number := l_cur_serial_number;
        l_msni_rec_tbl(i).to_serial_number := l_cur_serial_number;
        l_msni_rec_tbl(i).product_transaction_id := l_product_transaction_id;
        l_msni_rec_tbl(i).product_code := p_product_code;
      END LOOP;   --END For each serial number in the range
    END IF;   --END IF p_att_exist = 'N'

    --At this stage, we have a PL/SQL table containing one or more rows to be
    --inserted into MTL_SERIAL_NUMBERS_INTERFACE. Loop through the table and
    --insert each record
    l_msni_tbl_count := l_msni_rec_tbl.COUNT;

    IF (l_debug = 1) THEN
      print_debug('Count of records in the table: ' || l_msni_tbl_count, 4);
    END IF;

    IF l_msni_tbl_count <= 0 THEN
      IF (l_debug = 1) THEN
        print_debug('Unexpected error. The table of serials is empty!', 4);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FOR i IN 1 .. l_msni_tbl_count LOOP

      INSERT INTO MTL_SERIAL_NUMBERS_INTERFACE (
           transaction_interface_id
         , source_code
         , source_line_id
         , last_update_date
         , last_updated_by
         , creation_date
         , created_by
         , last_update_login
         , fm_serial_number
         , to_serial_number
         , status_id
         , product_transaction_id
         , product_code
         , vendor_serial_number
         , vendor_lot_number
         , parent_serial_number
         , origination_date
         , territory_code
         , time_since_new
         , cycles_since_new
         , time_since_overhaul
         , cycles_since_overhaul
         , time_since_repair
         , cycles_since_repair
         , time_since_visit
         , cycles_since_visit
         , time_since_mark
         , cycles_since_mark
         , number_of_repairs
         , serial_attribute_category
         , c_attribute1
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
         , d_attribute1
         , d_attribute2
         , d_attribute3
         , d_attribute4
         , d_attribute5
         , d_attribute6
         , d_attribute7
         , d_attribute8
         , d_attribute9
         , d_attribute10
         , n_attribute1
         , n_attribute2
         , n_attribute3
         , n_attribute4
         , n_attribute5
         , n_attribute6
         , n_attribute7
         , n_attribute8
         , n_attribute9
         , n_attribute10
         , attribute_category
         , attribute1
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
         )
      VALUES (
           l_msni_rec_tbl(i).transaction_interface_id
         , l_source_code
         , l_source_line_id
         , SYSDATE
         , l_user_id
         , SYSDATE
         , l_user_id
         , l_login_id
         , l_msni_rec_tbl(i).fm_serial_number
         , l_msni_rec_tbl(i).to_serial_number
         , l_msni_rec_tbl(i).status_id
         , l_msni_rec_tbl(i).product_transaction_id
         , l_msni_rec_tbl(i).product_code
         , l_msni_rec_tbl(i).vendor_serial_number
         , l_msni_rec_tbl(i).vendor_lot_number
         , l_msni_rec_tbl(i).parent_serial_number
         , l_msni_rec_tbl(i).origination_date
         , l_msni_rec_tbl(i).territory_code
         , l_msni_rec_tbl(i).time_since_new
         , l_msni_rec_tbl(i).cycles_since_new
         , l_msni_rec_tbl(i).time_since_overhaul
         , l_msni_rec_tbl(i).cycles_since_overhaul
         , l_msni_rec_tbl(i).time_since_repair
         , l_msni_rec_tbl(i).cycles_since_repair
         , l_msni_rec_tbl(i).time_since_visit
         , l_msni_rec_tbl(i).cycles_since_visit
         , l_msni_rec_tbl(i).time_since_mark
         , l_msni_rec_tbl(i).cycles_since_mark
         , l_msni_rec_tbl(i).number_of_repairs
         , l_msni_rec_tbl(i).serial_attribute_category
         , l_msni_rec_tbl(i).c_attribute1
         , l_msni_rec_tbl(i).c_attribute2
         , l_msni_rec_tbl(i).c_attribute3
         , l_msni_rec_tbl(i).c_attribute4
         , l_msni_rec_tbl(i).c_attribute5
         , l_msni_rec_tbl(i).c_attribute6
         , l_msni_rec_tbl(i).c_attribute7
         , l_msni_rec_tbl(i).c_attribute8
         , l_msni_rec_tbl(i).c_attribute9
         , l_msni_rec_tbl(i).c_attribute10
         , l_msni_rec_tbl(i).c_attribute11
         , l_msni_rec_tbl(i).c_attribute12
         , l_msni_rec_tbl(i).c_attribute13
         , l_msni_rec_tbl(i).c_attribute14
         , l_msni_rec_tbl(i).c_attribute15
         , l_msni_rec_tbl(i).c_attribute16
         , l_msni_rec_tbl(i).c_attribute17
         , l_msni_rec_tbl(i).c_attribute18
         , l_msni_rec_tbl(i).c_attribute19
         , l_msni_rec_tbl(i).c_attribute20
         , l_msni_rec_tbl(i).d_attribute1
         , l_msni_rec_tbl(i).d_attribute2
         , l_msni_rec_tbl(i).d_attribute3
         , l_msni_rec_tbl(i).d_attribute4
         , l_msni_rec_tbl(i).d_attribute5
         , l_msni_rec_tbl(i).d_attribute6
         , l_msni_rec_tbl(i).d_attribute7
         , l_msni_rec_tbl(i).d_attribute8
         , l_msni_rec_tbl(i).d_attribute9
         , l_msni_rec_tbl(i).d_attribute10
         , l_msni_rec_tbl(i).n_attribute1
         , l_msni_rec_tbl(i).n_attribute2
         , l_msni_rec_tbl(i).n_attribute3
         , l_msni_rec_tbl(i).n_attribute4
         , l_msni_rec_tbl(i).n_attribute5
         , l_msni_rec_tbl(i).n_attribute6
         , l_msni_rec_tbl(i).n_attribute7
         , l_msni_rec_tbl(i).n_attribute8
         , l_msni_rec_tbl(i).n_attribute9
         , l_msni_rec_tbl(i).n_attribute10
         , l_msni_rec_tbl(i).attribute_category
         , l_msni_rec_tbl(i).attribute1
         , l_msni_rec_tbl(i).attribute2
         , l_msni_rec_tbl(i).attribute3
         , l_msni_rec_tbl(i).attribute4
         , l_msni_rec_tbl(i).attribute5
         , l_msni_rec_tbl(i).attribute6
         , l_msni_rec_tbl(i).attribute7
         , l_msni_rec_tbl(i).attribute8
         , l_msni_rec_tbl(i).attribute9
         , l_msni_rec_tbl(i).attribute10
         , l_msni_rec_tbl(i).attribute11
         , l_msni_rec_tbl(i).attribute12
         , l_msni_rec_tbl(i).attribute13
         , l_msni_rec_tbl(i).attribute14
         , l_msni_rec_tbl(i).attribute15
        );
      --If the flag p_update_msn is set then update MSN with the attributes
      IF (NVL(p_update_msn, 'N') = 'Y') THEN
        UPDATE  mtl_serial_numbers
        SET  vendor_serial_number       = l_msni_rec_tbl(i).vendor_serial_number
           , vendor_lot_number          = l_msni_rec_tbl(i).vendor_lot_number
           , parent_serial_number       = l_msni_rec_tbl(i).parent_serial_number
           , origination_date           = l_msni_rec_tbl(i).origination_date
           , territory_code             = l_msni_rec_tbl(i).territory_code
           , time_since_new             = l_msni_rec_tbl(i).time_since_new
           , cycles_since_new           = l_msni_rec_tbl(i).cycles_since_new
           , time_since_overhaul        = l_msni_rec_tbl(i).time_since_overhaul
           , cycles_since_overhaul      = l_msni_rec_tbl(i).cycles_since_overhaul
           , time_since_repair          = l_msni_rec_tbl(i).time_since_repair
           , cycles_since_repair        = l_msni_rec_tbl(i).cycles_since_repair
           , time_since_visit           = l_msni_rec_tbl(i).time_since_visit
           , cycles_since_visit         = l_msni_rec_tbl(i).cycles_since_visit
           , time_since_mark            = l_msni_rec_tbl(i).time_since_mark
           , cycles_since_mark          = l_msni_rec_tbl(i).cycles_since_mark
           , number_of_repairs          = l_msni_rec_tbl(i).number_of_repairs
           , serial_attribute_category  = l_msni_rec_tbl(i).serial_attribute_category
           , c_attribute1               = l_msni_rec_tbl(i).c_attribute1
           , c_attribute2               = l_msni_rec_tbl(i).c_attribute2
           , c_attribute3               = l_msni_rec_tbl(i).c_attribute3
           , c_attribute4               = l_msni_rec_tbl(i).c_attribute4
           , c_attribute5               = l_msni_rec_tbl(i).c_attribute5
           , c_attribute6               = l_msni_rec_tbl(i).c_attribute6
           , c_attribute7               = l_msni_rec_tbl(i).c_attribute7
           , c_attribute8               = l_msni_rec_tbl(i).c_attribute8
           , c_attribute9               = l_msni_rec_tbl(i).c_attribute9
           , c_attribute10              = l_msni_rec_tbl(i).c_attribute10
           , c_attribute11              = l_msni_rec_tbl(i).c_attribute11
           , c_attribute12              = l_msni_rec_tbl(i).c_attribute12
           , c_attribute13              = l_msni_rec_tbl(i).c_attribute13
           , c_attribute14              = l_msni_rec_tbl(i).c_attribute14
           , c_attribute15              = l_msni_rec_tbl(i).c_attribute15
           , c_attribute16              = l_msni_rec_tbl(i).c_attribute16
           , c_attribute17              = l_msni_rec_tbl(i).c_attribute17
           , c_attribute18              = l_msni_rec_tbl(i).c_attribute18
           , c_attribute19              = l_msni_rec_tbl(i).c_attribute19
           , c_attribute20              = l_msni_rec_tbl(i).c_attribute20
           , d_attribute1               = l_msni_rec_tbl(i).d_attribute1
           , d_attribute2               = l_msni_rec_tbl(i).d_attribute2
           , d_attribute3               = l_msni_rec_tbl(i).d_attribute3
           , d_attribute4               = l_msni_rec_tbl(i).d_attribute4
           , d_attribute5               = l_msni_rec_tbl(i).d_attribute5
           , d_attribute6               = l_msni_rec_tbl(i).d_attribute6
           , d_attribute7               = l_msni_rec_tbl(i).d_attribute7
           , d_attribute8               = l_msni_rec_tbl(i).d_attribute8
           , d_attribute9               = l_msni_rec_tbl(i).d_attribute9
           , d_attribute10              = l_msni_rec_tbl(i).d_attribute10
           , n_attribute1               = l_msni_rec_tbl(i).n_attribute1
           , n_attribute2               = l_msni_rec_tbl(i).n_attribute2
           , n_attribute3               = l_msni_rec_tbl(i).n_attribute3
           , n_attribute4               = l_msni_rec_tbl(i).n_attribute4
           , n_attribute5               = l_msni_rec_tbl(i).n_attribute5
           , n_attribute6               = l_msni_rec_tbl(i).n_attribute6
           , n_attribute7               = l_msni_rec_tbl(i).n_attribute7
           , n_attribute8               = l_msni_rec_tbl(i).n_attribute8
           , n_attribute9               = l_msni_rec_tbl(i).n_attribute9
           , n_attribute10              = l_msni_rec_tbl(i).n_attribute10
           , attribute_category         = l_msni_rec_tbl(i).attribute_category
           , attribute1                 = l_msni_rec_tbl(i).attribute1
           , attribute2                 = l_msni_rec_tbl(i).attribute2
           , attribute3                 = l_msni_rec_tbl(i).attribute3
           , attribute4                 = l_msni_rec_tbl(i).attribute4
           , attribute5                 = l_msni_rec_tbl(i).attribute5
           , attribute6                 = l_msni_rec_tbl(i).attribute6
           , attribute7                 = l_msni_rec_tbl(i).attribute7
           , attribute8                 = l_msni_rec_tbl(i).attribute8
           , attribute9                 = l_msni_rec_tbl(i).attribute9
           , attribute10                = l_msni_rec_tbl(i).attribute10
           , attribute11                = l_msni_rec_tbl(i).attribute11
           , attribute12                = l_msni_rec_tbl(i).attribute12
           , attribute13                = l_msni_rec_tbl(i).attribute13
           , attribute14                = l_msni_rec_tbl(i).attribute14
           , attribute15                = l_msni_rec_tbl(i).attribute15
        WHERE inventory_item_id = p_inventory_item_id
        AND   serial_number between
                    l_msni_rec_tbl(i).fm_serial_number and
                     l_msni_rec_tbl(i).to_serial_number
        AND   LENGTH(serial_number) = LENGTH(p_fm_serial_number);
      END IF;   --END If p_update_msn = 'Y'
    END LOOP;   --END for each serial record in the table

    --Now mark the serials passed to the API. Set the group_mark_id with
    --the product_transaction_id generated above
    serial_check.inv_mark_serial(
        from_serial_number  =>  p_fm_serial_number
      , to_serial_number    =>  p_to_serial_number
      , item_id             =>  p_inventory_item_id
      , org_id              =>  p_organization_id
      , hdr_id              =>  l_product_transaction_id
      , temp_id             =>  NULL
      , lot_temp_id         =>  NULL
      , success             =>  l_success );

    --Reassign the generated values
    p_transaction_interface_id := l_transaction_interface_id;
    p_product_transaction_id := l_product_transaction_id;

    IF (l_debug = 1) THEN
      print_debug('p_transaction_interface_id returned: ' || p_transaction_interface_id, 4);
      print_debug('p_product_transaction_id returned: ' || p_product_transaction_id, 4);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF c_msn_attributes%ISOPEN THEN
        CLOSE c_msn_attributes;
      END IF;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF c_msn_attributes%ISOPEN THEN
        CLOSE c_msn_attributes;
      END IF;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      IF c_msn_attributes%ISOPEN THEN
        CLOSE c_msn_attributes;
      END IF;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_INTEGRATION_APIS.INSERT_MSNI', l_progress, SQLCODE);
      END IF;
  END insert_msni;

  -- being called from iSP to validate the lot number
  FUNCTION validate_lot_number(
     p_api_version	      IN            NUMBER
   , p_init_msg_lst	      IN            VARCHAR2
   , x_return_status          OUT NOCOPY    VARCHAR2
   , x_msg_count              OUT NOCOPY    NUMBER
   , x_msg_data               OUT NOCOPY    VARCHAR2
   , x_is_new_lot             OUT NOCOPY    VARCHAR2
   , p_validation_mode	      IN            NUMBER
   , p_org_id                 IN            NUMBER
   , p_inventory_item_id      IN            NUMBER
   , p_lot_number     	      IN            VARCHAR2
   , p_expiration_date        IN            DATE
   , p_txn_type	              IN            NUMBER
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
)
  RETURN BOOLEAN IS
   l_lot_exists           VARCHAR2(1) := 'N';
   l_unique_lot           BOOLEAN;
   l_lot_uniqueness       NUMBER;
   no_shelf_life_control  CONSTANT NUMBER := 1;
   item_shelf_life_days   CONSTANT NUMBER := 2;
   user_defined_exp_date  CONSTANT NUMBER := 4;
   l_shelf_life_days      mtl_system_items.shelf_life_days%TYPE;
   l_shelf_life_code      mtl_system_items.shelf_life_code%TYPE;
   l_expiration_date      mtl_lot_numbers.expiration_date%TYPE;
   l_debug                NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    x_return_status := g_ret_sts_success;

   fnd_msg_pub.initialize;

    IF l_debug = 1 THEN
      print_debug('validate_lot_number: Entered with following parameters:', 9);
      print_debug('validate_lot_number: lot_number: ' || p_lot_number, 9);
      print_debug('validate_lot_number: org_id: ' || p_org_id, 9);
      print_debug('validate_lot_number: item_id: ' || p_inventory_item_id, 9);
      print_debug('validate_lot_number: expiration_date: ' || p_expiration_date, 9);
      print_debug('validate_lot_number: validation_mode: ' || p_validation_mode, 9);
      print_debug('validate_lot_number: txn_type: ' || p_txn_type, 9);
      print_debug('validate_lot_number: disable_flag: ' || p_disable_flag, 9);
      print_debug('validate_lot_number: attribute_category: ' ||p_attribute_category, 9);
      print_debug('validate_lot_number: lot_attribute_category: ' ||p_lot_attribute_category, 9);
--      print_debug('validate_lot_number: attributes_tbl: ' ||p_attributes_tbl, 9);
--      print_debug('validate_lot_number: c_attributes_tbl: ' ||p_c_attributes_tbl, 9);
--      print_debug('validate_lot_number: n_attributes_tbl: ' ||p_n_attributes_tbl, 9);
--      print_debug('validate_lot_number: d_attributes_tbl: ' ||p_d_attributes_tbl, 9);
      print_debug('validate_lot_number: grade_code: ' || p_grade_code, 9);
      print_debug('validate_lot_number: origination_date: ' ||p_origination_date, 9);
      print_debug('validate_lot_number: date_code: ' || p_date_code, 9);
      print_debug('validate_lot_number: status_id: ' || p_status_id, 9);
      print_debug('validate_lot_number: change_date: ' || p_change_date, 9);
      print_debug('validate_lot_number: age: ' || p_age, 9);
      print_debug('validate_lot_number: retest_date: ' || p_retest_date, 9);
      print_debug('validate_lot_number: maturity_date: ' ||p_maturity_date, 9);
      print_debug('validate_lot_number: item_size: ' || p_item_size, 9);
      print_debug('validate_lot_number: color: ' || p_color, 9);
      print_debug('validate_lot_number: volume: ' || p_volume, 9);
      print_debug('validate_lot_number: volume_uom: ' || p_volume_uom, 9);
      print_debug('validate_lot_number: place_of_origin: ' ||p_place_of_origin, 9);
      print_debug('validate_lot_number: best_by_date: ' || p_best_by_date, 9);
      print_debug('validate_lot_number: length: ' || p_length, 9);
      print_debug('validate_lot_number: length_uom: ' || p_length_uom, 9);
      print_debug('validate_lot_number: recycled_content: ' ||p_recycled_content, 9);
      print_debug('validate_lot_number: thickness: ' || p_thickness, 9);
      print_debug('validate_lot_number: thickness_uom: ' ||p_thickness_uom, 9);
      print_debug('validate_lot_number: width: ' || p_width, 9);
      print_debug('validate_lot_number: width_uom: ' || p_width_uom, 9);
      print_debug('validate_lot_number: territory_code: ' ||p_territory_code, 9);
      print_debug('validate_lot_number: supplier_lot_number: ' ||p_supplier_lot_number, 9);
      print_debug('validate_lot_number: vendor_name: ' || p_vendor_name, 9);
    END IF;

    --The validations should be called only if the transaction type is Ship
    IF p_txn_type = INV_RCV_INTEGRATION_APIS.G_SHIP THEN
      --First check if the lot exists in the given organization
      BEGIN
        SELECT 'Y'
        INTO   l_lot_exists
        FROM   mtl_lot_numbers
        WHERE  lot_number = LTRIM(RTRIM(p_lot_number))
        AND    inventory_item_id = p_inventory_item_id
        AND    organization_id = p_org_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_lot_exists := 'N';
      END;

      IF (l_debug = 1) THEN
        print_debug('validate_lot_number: Lot Exists: ' || l_lot_exists, 9);
      END IF;

      IF (l_lot_exists = 'Y') THEN
	 x_is_new_lot := 'N';
       ELSE
	 x_is_new_lot := 'Y';
      END IF;

      --then raise an error indicating invalid lot number
      IF (p_validation_mode = INV_RCV_INTEGRATION_APIS.G_EXISTS_ONLY AND
          l_lot_exists = 'N') THEN
        fnd_message.set_name('INV', 'INV_INVALID_LOT');
        fnd_msg_pub.ADD;
        x_return_status := FND_API.g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
        print_debug('err: ' || x_msg_data, 9);
        RETURN FALSE;
      END IF;

      --If the lot number exists for the given item and org combination then:
      --  a) Check for lot number uniqueness within the organization
      --  b) Validate the expiration date based on shelf life code
      IF (p_lot_number IS NOT NULL) THEN
        --If the lot exists, check for lot uniqueness
        l_unique_lot := inv_lot_api_pub.validate_unique_lot(
                p_org_id            =>  p_org_id
              , p_inventory_item_id =>  p_inventory_item_id
              , p_lot_uniqueness    =>  l_lot_uniqueness
              , p_auto_lot_number   =>  p_lot_number);

        --If the lot is not unique then raise an error
        IF NOT l_unique_lot THEN
          fnd_message.set_name('INV', 'INV_LOT_UNIQUE_FAIL');
          fnd_msg_pub.add;
          x_return_status := FND_API.g_ret_sts_error;
          fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
          RETURN FALSE;
        END IF;

        --Validate the expiration date based on shelf life code
        BEGIN
          SELECT shelf_life_days
               , shelf_life_code
            INTO l_shelf_life_days
               , l_shelf_life_code
            FROM mtl_system_items
           WHERE inventory_item_id = p_inventory_item_id
             AND organization_id = p_org_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('INV', 'INV_SHELF_LIFE_ERROR');
            fnd_message.set_token('INV', 'ITEM');
            fnd_msg_pub.ADD;
            IF l_debug = 1 THEN
              print_debug('validate_lot_number: Unable to fetch shelf life code for the inventory item passed', 9);
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
            RETURN FALSE;
        END;

        IF l_debug = 1 THEN
          print_debug('validate_lot_number: item shelf life code ' || l_shelf_life_code, 9);
        END IF;

        IF l_shelf_life_code = item_shelf_life_days THEN
          IF l_debug = 1 THEN
            print_debug('Shelf_life code is of type ITEM_SHELF_LIFE_DAYS', 9);
          END IF;

          SELECT SYSDATE + l_shelf_life_days
          INTO l_expiration_date
          FROM DUAL;

          IF TRUNC(l_expiration_date) <> trunc(p_expiration_date) THEN
            fnd_message.set_name('INV', 'INV_EXP_DATE_NOT_CONSIDER');
            fnd_msg_pub.ADD;
            IF l_debug = 1 THEN
              print_debug('validate_lot_number: Expiration will not be considered for shelf_life code of type ITEM_SHELF_LIFE_DAYS', 9);
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
            RETURN FALSE;
          END IF;
        ELSIF l_shelf_life_code = user_defined_exp_date THEN
          IF l_debug = 1 THEN
            print_debug('validate_lot_number: Shelf_life code is of type USER_DEFINED_EXP_DATE', 9);
          END IF;
          IF p_expiration_date IS NULL THEN
            fnd_message.set_name('INV', 'INV_LOT_EXPREQD');
            fnd_msg_pub.ADD;
            IF l_debug = 1 THEN
              print_debug('validate_lot_number: Lot expiration date is required ', 9);
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
            RETURN FALSE;
          ELSE
            l_expiration_date  := p_expiration_date;
          END IF;
        ELSE
          IF l_debug = 1 THEN
            print_debug('validate_lot_number: Shelf_life code is of type NO_SHELF_LIFE_CONTROL', 9);
          END IF;
        END IF; /* l_shelf_life_code = item_shelf_life_days */
      END IF;   --END IF validations for the lot if it exists

      --If the validation mode is exists_or_create and the the lot does not exist
      IF (p_validation_mode = INV_RCV_INTEGRATION_APIS.G_EXISTS_OR_CREATE AND
          l_lot_exists = 'N') THEN
        --Call the create_inv_lot API to create the lot number
        l_expiration_date := p_expiration_date;
        IF (l_debug = 1) THEN
          print_debug('validate_lot_number: calling inv_lot_api_pub.creat_inv_lot to create the lot', 9);
        END IF;

	inv_lot_api_pub.create_inv_lot(x_return_status => x_return_status
				       , x_msg_count => x_msg_count
				       , x_msg_data => x_msg_data
				       , p_inventory_item_id => p_inventory_item_id
				       , p_organization_id => p_org_id
				       , p_lot_number => p_lot_number
				       , p_expiration_date => l_expiration_date
				       , p_disable_flag => p_disable_flag
				       , p_attribute_category => p_attribute_category
				       , p_lot_attribute_category => p_lot_attribute_category
				       , p_attributes_tbl =>   p_attributes_tbl
				       , p_c_attributes_tbl => p_c_attributes_tbl
				       , p_n_attributes_tbl => p_n_attributes_tbl
				       , p_d_attributes_tbl => p_d_attributes_tbl
				       , p_grade_code => p_grade_code
				       , p_origination_date => p_origination_date
				       , p_date_code => p_date_code
				       , p_status_id => p_status_id
				       , p_change_date => p_change_date
				       , p_age => p_age
	                               , p_retest_date => p_retest_date
	                               , p_maturity_date => p_maturity_date
	                               , p_item_size => p_item_size
	                               , p_color => p_color
	                               , p_volume => p_volume
	                               , p_volume_uom => p_volume_uom
	                               , p_place_of_origin => p_place_of_origin
	                               , p_best_by_date => p_best_by_date
	                               , p_length => p_Length
	                               , p_length_uom => p_length_uom
	                               , p_recycled_content => p_recycled_content
	                               , p_thickness => p_thickness
	                               , p_thickness_uom => p_thickness_uom
	                               , p_width => p_width
	                               , p_width_uom => p_width_uom
	                               , p_territory_code => p_territory_code
	                               , p_supplier_lot_number => p_supplier_lot_number
	                               , p_vendor_name => p_vendor_name
	                               , p_source => inv_lot_api_pub.inv);
        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          IF (l_debug = 1) THEN
            print_debug('validate_lot_number: Error in creating the lot number', 9);
          END IF;
          x_return_status := FND_API.g_ret_sts_error;
          fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
          RETURN FALSE;
        END IF;
      END IF;   --END IF create the lot number
    --This API should be getting called only for a ship transaction from iSP.
    ELSE
      fnd_message.set_name('INV','INV_NOT_IMPLEMENTED');
      fnd_msg_pub.add;
      x_return_status := FND_API.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN FALSE;
    END IF;   --END IF Check the transaction type

    --All the validations have passed successfully, then
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        print_debug('validate_lot_number: Exception occurred in validate_lot_number', 3);
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
          , p_count => x_msg_count
          , p_data => x_msg_data);
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error(
            'INV_RCV_INTEGRATION_APIS.VALIDATE_LOT_NUMBER', SQLCODE, SQLERRM);
      END IF;
      RETURN FALSE;
  END validate_lot_number;

  -- being called from iSP to validate the range of serial numbers
  FUNCTION validate_serial_range(
     p_api_version	     IN  		        NUMBER
   , p_init_msg_lst	     IN  		        VARCHAR2
   , x_return_status     OUT 	NOCOPY	  VARCHAR2
   , x_msg_count         OUT 	NOCOPY	  NUMBER
   , x_msg_data          OUT 	NOCOPY	  VARCHAR2
   , p_validation_mode	 IN		          NUMBER
   , p_org_id            IN       	    NUMBER
   , p_inventory_item_id IN             NUMBER
   , p_quantity	         IN       	    NUMBER
   , p_revision	         IN       	    VARCHAR2
   , p_lot_number	       IN       	    VARCHAR2
   , p_fm_serial_number  IN       	    VARCHAR2
   , p_to_serial_number	 IN OUT	NOCOPY	VARCHAR2
   , p_txn_type	         IN		          NUMBER
   )
  RETURN BOOLEAN IS
    l_debug                     NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_serial_diff               NUMBER := 0;
    l_serial_qty                NUMBER := 0;
    l_serial_prefix             VARCHAR2(30);
    l_cur_serial_number         mtl_serial_numbers.serial_number%TYPE;
    l_from_ser_number           NUMBER;
    l_to_ser_number             NUMBER;
    l_cur_ser_num               NUMBER;
    l_ser_num_length            NUMBER;
    l_prefix_length             NUMBER;
    l_range_numbers             NUMBER;
    l_serial_exists             VARCHAR2(1);
    l_return                    NUMBER;
    --Bug 11708191 Modified the type of the bleow parameter to the msn.serial_number type.
    l_to_serial_number          mtl_serial_numbers.serial_number%TYPE; --Bug 8413853
  BEGIN
    x_return_status := g_ret_sts_success;

   fnd_msg_pub.initialize;


    IF l_debug = 1 THEN
      print_debug('validate_serial_range: Entered with following parameters:', 9);
      print_debug('validate_serial_range: fm_serial_number: ' || p_fm_serial_number, 9);
      print_debug('validate_serial_range: to_serial_number: ' || p_to_serial_number, 9);
      print_debug('validate_serial_range: quantity: ' || p_quantity, 9);
      print_debug('validate_serial_range: org_id: ' || p_org_id, 9);
      print_debug('validate_serial_range: item_id: ' || p_inventory_item_id, 9);
      print_debug('validate_serial_range: revision: ' || p_revision, 9);
      print_debug('validate_serial_range: lot_number: ' || p_lot_number, 9);
      print_debug('validate_serial_range: validation_mode: ' || p_validation_mode, 9);
      print_debug('validate_serial_range: txn_type: ' || p_txn_type, 9);
    END IF;

    --The validations should be called only if the transaction type is Ship
    IF p_txn_type = INV_RCV_INTEGRATION_APIS.G_SHIP THEN
      --If from serial is not given then raise an error
      IF p_fm_serial_number IS NULL THEN
        IF (l_debug = 1) THEN
          print_debug('validate_serial_range: From Serial Number cannot be NULL', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_INLTIS_FROMSER');
        fnd_msg_pub.add;
        x_return_status := FND_API.g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
        RETURN FALSE;
      END IF;

      --If to serial number and quantity both are NULL then raise an error
      IF p_to_serial_number IS NULL AND p_quantity IS NULL THEN
        IF (l_debug = 1) THEN
          print_debug('validate_serial_range: To Serial and quantity both cannot be NULL', 9);
        END IF;
        fnd_message.set_name('INV', 'INV_INLTIS_RANGE');
        fnd_msg_pub.add;
        x_return_status := FND_API.g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
        RETURN FALSE;
      END IF;

      --If to serial number is passed, get the difference between from and to serials
      IF p_to_serial_number IS NOT NULL THEN
        l_serial_diff := inv_serial_number_pub.get_serial_diff(p_fm_serial_number, p_to_serial_number);

        --If there was any problem in the from and serials length, this API would
        --return the difference as -1. If this is so, then return an error
        IF l_serial_diff < 0 THEN
          IF (l_debug = 1) THEN
            print_debug('validate_serial_range: Length of from and to serials do not match', 9);
          END IF;
        -- Bug Fix 4375959
        --  fnd_message.set_name('INV', 'INV_INLTIS_RANGE');
          fnd_msg_pub.add;
          x_return_status := FND_API.g_ret_sts_error;
          fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
          RETURN FALSE;
        END IF;   --End If serial difference is < 0

        --If quantity is > 1 and the serial difference does not match the quantity
        --then raise an error

	-- Code changed to p_quantity > 0, handle a bug regarding validation of
	-- where the quantity is 1. Bug No. 3579958
        IF (p_quantity IS NOT NULL AND p_quantity > 0 AND p_quantity <> l_serial_diff) THEN
          IF (l_debug = 1) THEN
            print_debug('validate_serial_range: Serial quantity does not match transaction quantity', 9);
          END IF;
          fnd_message.set_name('INV', 'INV_SERQTY_NOTMATCH');
          fnd_msg_pub.add;
          x_return_status := FND_API.g_ret_sts_error;
          fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
          RETURN FALSE;
        END IF;
      END IF;   --END IF p_to_serial_number is NOT NULL

      --If the validation mode is exists_only then check for the existence of each
      --serial within the range
      IF p_validation_mode = INV_RCV_INTEGRATION_APIS.G_EXISTS_ONLY THEN
        --If to serial is not given then raise an error
        IF p_to_serial_number IS NULL THEN
          IF (l_debug = 1) THEN
            print_debug('validate_serial_range: To serial number must be specified', 9);
          END IF;
          fnd_message.set_name('INV', 'INV_SERIAL_NOT_ENTERED');
          fnd_msg_pub.add;
          x_return_status := FND_API.g_ret_sts_error;
          fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
          RETURN FALSE;
        END IF;   --END IF p_to_serial_number IS NULL

        --Now check for the existence of all the serials in the range
        inv_validate.number_from_sequence(p_fm_serial_number, l_serial_prefix, l_from_ser_number);
        inv_validate.number_from_sequence(p_to_serial_number, l_serial_prefix, l_to_ser_number);
        --Get the no. of serials in the range, prefix length and numeric part
        l_range_numbers := l_to_ser_number - l_from_ser_number + 1;
        l_ser_num_length := LENGTH(p_fm_serial_number);
        l_prefix_length := LENGTH(l_serial_prefix);

        IF (l_debug = 1) THEN
          print_debug('No. of serials in the range : ' || l_range_numbers, 4);
          print_debug('Serial Number length: ' || l_ser_num_length, 4);
          print_debug('Prefix length : ' || l_prefix_length, 4);
        END IF;

        FOR i IN 1 .. l_range_numbers LOOP
          l_cur_ser_num := l_from_ser_number + i -1;
          l_cur_serial_number := l_serial_prefix ||
              LPAD(l_cur_ser_num, l_ser_num_length - NVL(l_prefix_length,0),  '0');
          BEGIN
            SELECT 'Y'
            INTO   l_serial_exists
            FROM   mtl_serial_numbers
            WHERE  inventory_item_id = p_inventory_item_id
            AND    serial_number = l_cur_serial_number
            AND    current_organization_id = p_org_id
            AND    current_status IN (1,6);
          EXCEPTION
            WHEN OTHERS THEN
              IF (l_debug = 1) THEN
                print_debug('validate_serial_number: could not find the serial number: ' || l_cur_serial_number, 9);
              END IF;
              fnd_message.set_name('INV', 'INV_SER_NOTEXIST');
              fnd_message.set_token('TOKEN', l_cur_serial_number);
              fnd_msg_pub.add;
              x_return_status := FND_API.g_ret_sts_error;
              fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
              RETURN FALSE;
          END;
        END LOOP;   --END For each serial in the range
      END IF;   --END IF g_exists_only

      --If the validation mode is exists_or_create then call the validate_range_serial
      --API that will validate the serial number as well as create one if it does not exist
      IF p_validation_mode = INV_RCV_INTEGRATION_APIS.G_EXISTS_OR_CREATE THEN
        IF (l_debug = 1) THEN
          print_debug('validate_lot_number: calling inv_serial_number_pub.validate_serials to validate/create the serials', 9);
        END IF;
        --Bug 8413853 To Validate the Marked Serials added Parameter p_check_for_grp_mark_id
       IF(p_to_serial_number is not null) THEN
         l_to_serial_number:=p_to_serial_number;
       END IF;
        l_return := inv_serial_number_pub.validate_serials(
                p_org_id         => p_org_id
              , p_item_id        => p_inventory_item_id
              , p_qty            => l_serial_qty
              , p_rev            => p_revision
              , p_lot            => p_lot_number
              , p_start_ser      => p_fm_serial_number
              , p_check_for_grp_mark_id =>'Y'
              , p_trx_src_id     => NULL
              , p_trx_action_id  => NULL
              , x_end_ser        => p_to_serial_number
              , x_proc_msg       => x_msg_data);

        --Set the error message and raise in case of a validation failure
        --Bug 8413853 Since we are caling this from ISP if any serial in the range
 	     --  has marked then we should throw error. So, we are just comparing the
 	     --  passed to serial is equal to returned to serial.
 	     IF(l_to_serial_number<>p_to_serial_number) then
 	         l_return:=1;
 	     End IF;
        IF l_return = 1 THEN
          IF (l_debug = 1) THEN
            print_debug('validate_serial_range: Error returned by validate_serials', 9);
          END IF;
          fnd_message.set_name('INV', 'INVALID_SERIAL_NUMBER');
          fnd_msg_pub.ADD;
          x_return_status := FND_API.g_ret_sts_error;
          fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
          RETURN FALSE;
        END IF;
      END IF;   --END IF g_exists_or_create

      --All the validations have passed return TRUE
      RETURN TRUE;

    --This API should be getting called only for a ship transaction from iSP.
    ELSE
      fnd_message.set_name('INV','INV_NOT_IMPLEMENTED');
      fnd_msg_pub.add;
      x_return_status := FND_API.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      RETURN FALSE;
    END IF;   --END IF Check the transaction type

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        print_debug('validate_serial_range: Exception occurred in validate_serial_range', 3);
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
          , p_count => x_msg_count
          , p_data => x_msg_data);
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error(
            'INV_RCV_INTEGRATION_APIS.VALIDATE_SERIAL_RANGE', SQLCODE, SQLERRM);
      END IF;
      RETURN FALSE;
  END validate_serial_range;

 function validate_lot_serial_info
  (p_api_version	IN  		NUMBER
   , p_init_msg_lst	IN  		VARCHAR2
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_validation_mode	IN		NUMBER
   , p_rti_id           IN       	NUMBER
   ) return BOOLEAN
   IS
      l_exist NUMBER;
      l_org_id NUMBER;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
    x_return_status := g_ret_sts_success;

    -- If not patchsetJ then return from this place.
    IF (inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j)  THEN
      IF (l_debug = 1) THEN
        print_debug('validate_lot_serial_info Return from the API call AS not pset J or below pset J level', 4);
      END IF;
      return TRUE ;
    END IF;

    /** OPM change Bug# 3061052**/
    -- removed the check to error out in case of OPM transaction.

    --call the lot/serial validation procedure

    inv_rcv_integration_pvt.validate_lot_serial_info(P_RTI_ID => P_RTI_ID,
						     X_RETURN_STATUS => X_RETURN_STATUS,
						     X_MSG_COUNT => X_MSG_COUNT,
						     X_MSG_DATA => X_MSG_DATA);

    IF (x_return_status <> g_ret_sts_success) THEN

       /*INVCONV */
       IF (l_debug = 1) THEN
          print_debug('validate_lot_serial_info: private API new debug', 4);
       END IF;
       /*end , INVCONV*/

       x_msg_data := x_msg_data||':'||fnd_message.get_string('INV','INV_LOT_SERIAL_VALIDATION_FAIL');
       fnd_message.set_name('INV','INV_LOT_SERIAL_VALIDATION_FAIL');
       fnd_msg_pub.ADD;
       RETURN FALSE;
    END IF;

    RETURN TRUE;
 EXCEPTION
    WHEN OTHERS THEN
       IF (l_debug = 1) THEN
	  print_debug('validate_lot_serial_info: private API throws exception', 4);
       END IF;
       x_return_status := g_ret_sts_error;
       RETURN FALSE;
 END validate_lot_serial_info;

 function generate_lot_number
  (p_api_version	 IN  		NUMBER
   , p_init_msg_lst	 IN  		VARCHAR2
   , p_commit	         IN		VARCHAR2
   , x_return_status     OUT 	NOCOPY	VARCHAR2
   , x_msg_count         OUT 	NOCOPY	NUMBER
   , x_msg_data          OUT 	NOCOPY	VARCHAR2
   , p_org_id            IN       	NUMBER
   , p_inventory_item_id IN       	NUMBER
   ) return VARCHAR2
   IS
 BEGIN
    x_return_status := g_ret_sts_success;

    x_return_status := g_ret_sts_error;
    fnd_message.set_name('INV','INV_NOT_IMPLEMENTED');
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get
      (  p_count  => x_msg_count
	 , p_data   => x_msg_data
	 );
    RETURN NULL;
 END generate_lot_number;

 procedure generate_serial_numbers
  (p_api_version	 IN  		NUMBER
   , p_init_msg_lst	 IN  		VARCHAR2 DEFAULT g_false
   , p_commit	         IN		VARCHAR2 DEFAULT g_false
   , x_return_status     OUT 	NOCOPY	VARCHAR2
   , x_msg_count         OUT 	NOCOPY	NUMBER
   , x_msg_data          OUT 	NOCOPY	VARCHAR2
   , p_org_id            IN       	NUMBER
   , p_inventory_item_id IN       	NUMBER
   , p_quantity	         IN       	NUMBER
   , p_revision	         IN       	VARCHAR2
   , p_lot_number	 IN       	VARCHAR2
   , x_start_serial	 OUT	NOCOPY	VARCHAR2
   , x_end_serial	 OUT	NOCOPY	VARCHAR2
   ) IS
 BEGIN
    x_return_status := g_ret_sts_success;

    x_return_status := g_ret_sts_error;
    fnd_message.set_name('INV','INV_NOT_IMPLEMENTED');
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get
      (  p_count  => x_msg_count
	 , p_data   => x_msg_data
	 );
 END generate_serial_numbers;

 function validate_lpn
  (p_api_version	IN  		NUMBER
   , p_init_msg_lst	IN  		VARCHAR2 DEFAULT g_false
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_validation_mode	IN		NUMBER DEFAULT G_EXISTS_ONLY
   , p_org_id           IN       	NUMBER
   , p_lpn_id     	IN OUT	NOCOPY	NUMBER
   , p_lpn     		IN       	VARCHAR2
   , p_parent_lpn_id	IN		NUMBER DEFAULT NULL
   ) return BOOLEAN
  IS
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_exists       NUMBER;
   l_lpn_id       NUMBER;
 BEGIN
    x_return_status := g_ret_sts_success;

    fnd_msg_pub.initialize;

    IF  (p_validation_mode = g_exists_only OR p_validation_mode = g_exists_or_create)  THEN
       BEGIN
          select 1, lpn_id
            into l_exists, l_lpn_id
            from wms_license_plate_numbers wlpn
           where wlpn.organization_id = nvl(p_org_id, wlpn.organization_id )
             and wlpn.license_plate_number = p_lpn
             and wlpn.lpn_id = nvl(p_lpn_id, wlpn.lpn_id)
             and ( (p_parent_lpn_id is null ) or ( wlpn.parent_lpn_id = p_parent_lpn_id and p_parent_lpn_id is not null ))
	     and rownum = 1;
	     IF p_lpn_id IS NULL THEN
		p_lpn_id := l_lpn_id;
	     END IF;
	     RETURN TRUE;
       EXCEPTION
	  WHEN no_data_found THEN
	     IF p_validation_mode = g_exists_only THEN
		IF (l_debug = 1) THEN
		   print_debug( 'This is an invalid lpn => ' || ' lpn = '||p_lpn ||' lpn_id= '||p_lpn_id,1 );
		END IF;
		x_return_status := g_ret_sts_error;
		fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
		fnd_msg_pub.ADD;
		fnd_msg_pub.count_and_get
		  (  p_count  => x_msg_count
		   , p_data   => x_msg_data
		  );
		RETURN FALSE;
	      ELSE -- IF p_validation_mode = g_exists_only THEN
		-- Call Container API to create LPN

		-- Bug 5461966: Pass p_api_version as number
		wms_container_pvt.create_lpn(
					     p_api_version           => 1.0,
					     p_init_msg_list         => g_false,
					     p_commit                => g_false,
					     p_validation_level      => fnd_api.g_valid_level_full,
					     x_return_status         => x_return_status,
					     x_msg_count             => x_msg_count,
					     x_msg_data              => x_msg_data,
					     p_lpn                   => p_lpn,
					     p_organization_id       => p_org_id,
  		  			     x_lpn_id                => l_lpn_id );
		if x_return_status <> G_RET_STS_SUCCESS Then
		   x_return_status := g_ret_sts_error;
		   IF (l_debug = 1) THEN
		      print_debug( 'Error creating lpn => '||'lpn = '||p_lpn ||'lpn_id= '||p_lpn_id,1 );
		   END IF;
		   fnd_message.set_name('WMS', 'WMS_LPN_NOTGEN');
		   fnd_msg_pub.ADD;
		   fnd_msg_pub.count_and_get
		     (  p_count  => x_msg_count
			, p_data   => x_msg_data
			);
		   RETURN FALSE;
		End if;
		p_lpn_id := l_lpn_id;
		RETURN TRUE;
	     END IF;-- IF p_validation_mode = g_exists_only THEN

	  WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug( 'This is an invalid lpn => ' || ' lpn = '||p_lpn ||' lpn_id= '||p_lpn_id,1 );
	    END IF;
	    x_return_status := g_ret_sts_error;
	    fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
	    fnd_msg_pub.ADD;
	    fnd_msg_pub.count_and_get
	      (  p_count  => x_msg_count
	       , p_data   => x_msg_data
	      );
	    RETURN FALSE;
       END;
     ELSE
       x_return_status := g_ret_sts_error;
       fnd_message.set_name('INV','INV_NOT_IMPLEMENTED');
       fnd_msg_pub.add;
       fnd_msg_pub.count_and_get
         (  p_count  => x_msg_count
	  , p_data   => x_msg_data
	 );
       RETURN FALSE;
    END IF;
 END validate_lpn;

 function validate_lpn_info
  (p_api_version	IN  		NUMBER DEFAULT 1.0
   , p_init_msg_lst	IN  		VARCHAR2 DEFAULT g_false
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_validation_mode	IN		NUMBER   DEFAULT G_EXISTS_OR_CREATE
   , p_lpn_group_id	IN       	NUMBER
   ) return BOOLEAN
   IS
      l_exist NUMBER;
      l_org_id NUMBER;

      l_api_name VARCHAR2(30) := 'VALIDATE_LPN_INFO';
      l_api_version         CONSTANT NUMBER := 1.0;

      l_progress VARCHAR2(10) := '00';
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
    x_return_status := g_ret_sts_success;

    l_progress := '10';

    IF (l_debug = 1) THEN
       print_debug('Inside VALIDATE_LPN_INFO ... LPN_GROUP_ID:'||p_lpn_group_id,1);
    END IF;

    -- If not patchsetJ then return from this place.
    IF (inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j)  THEN
      IF (l_debug = 1) THEN
        print_debug('VALIDATE_LPN_INFO: Return from the API call As not pset J or below pset J level', 4);
      END IF;
      return TRUE ;
    END IF;

    --l_progress := '20';

    /*INVCONV , 	This currently restricts OPM transaction and calls
      inv_rcv_integration_pvt.validate_lpn_info for validating discrete transactions
      Remove  process specific checks.Remove restriction for OPM transaction.
      Punit Kumar.
    */

    /*
    -- get the org_id and item_id from rti to check if OPM transaction
    BEGIN
       SELECT DISTINCT(to_organization_id)
	 INTO l_org_id
	 FROM rcv_transactions_interface
        WHERE lpn_group_id = p_lpn_group_id;
    EXCEPTION
       WHEN OTHERS THEN
	  NULL;
    END;

    l_progress := '30';

    -- check if this is a OPM transaction. If it is a OPM transaction then
    -- error out. This API should not be called for a OPM transaction.
    IF gml_process_flags.check_process_orgn(l_org_id) = 1 THEN
       x_return_status := g_ret_sts_error;
       fnd_message.set_name('INV','INV_NOT_IMPLEMENTED');
       fnd_msg_pub.add;
       fnd_msg_pub.count_and_get
	 (  p_count  => x_msg_count
	    , p_data   => x_msg_data
	    );
       RETURN FALSE;
    END IF;
   */
       print_debug('Inside VALIDATE_LPN_INFO ... LPN_GROUP_ID:'||p_lpn_group_id,1);
    l_progress := '40';

    IF (l_debug = 1) THEN
       print_debug('INVCONV,Remove  process specific checks.Remove restriction for OPM transaction.'||l_progress, 4);
    END IF;
    /*end , INVCONV */

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
				       l_api_name, 'inv_rcv_integration_apis') THEN
       print_debug('FND_API not compatible inv_rcv_integration_apis.validate_lpn_info', 4);
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_progress := '50';

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
       fnd_msg_pub.initialize;
    END IF;

    l_progress := '60';

    inv_rcv_integration_pvt.validate_lpn_info(p_lpn_group_id => p_lpn_group_id,
					      x_return_status => x_return_status,
					      x_msg_count => x_msg_count,
					      x_msg_data => x_msg_data);

    IF (l_debug = 1) THEN
       print_debug('VALIDATE_LPN_INFO: x_return_status from private api: '||x_return_status,1);
    END IF;

    IF (x_return_status <> g_ret_sts_success) THEN
       l_progress := '70';
       x_msg_data := x_msg_data||':'||fnd_message.get_string('INV','INV_LPN_VALIDATION_FAILED');
       IF (l_debug = 1) THEN
	  print_debug('VALIDATE_LPN_INFO: x_msg_data: '||x_msg_data,1);
       END IF;
       fnd_message.set_name('INV','INV_LPN_VALIDATION_FAILED');
       fnd_msg_pub.ADD;
       RETURN FALSE;
    END IF;

   l_progress := '80';

    RETURN TRUE;
 EXCEPTION
     WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	IF SQLCODE IS NOT NULL THEN
	   inv_mobile_helper_functions.sql_error (
						  'INV_RCV_INTEGRATION_APIS.VALIDATE_LPN_INFO',
						  l_progress,
						  SQLCODE);
	END IF;
	RETURN FALSE;
 END validate_lpn_info;

 procedure generate_lpn
  (p_api_version	IN  		NUMBER
   , p_init_msg_lst	IN  		VARCHAR2
   , p_commit	        IN	    	VARCHAR2
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_lpn_id           OUT 	NOCOPY 	NUMBER
   , p_lpn              OUT     NOCOPY  VARCHAR2
   , p_organization_id	IN       	NUMBER
   ) IS
 BEGIN
    x_return_status := g_ret_sts_success;

    x_return_status := g_ret_sts_error;
    fnd_message.set_name('INV','INV_NOT_IMPLEMENTED');
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get
      (  p_count  => x_msg_count
	 , p_data   => x_msg_data
	 );
 END generate_lpn;


 procedure explode_lpn
  (p_api_version	IN  		NUMBER
   , p_init_msg_lst	IN  		VARCHAR2
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_group_id	        IN       	NUMBER
   , p_request_id	IN       	NUMBER
   ) IS
      l_exist NUMBER;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
    x_return_status := g_ret_sts_success;

    /*
    BEGIN
       SELECT 1
	 INTO l_exist
	 FROM dual
	WHERE exists (SELECT 1
		        FROM rcv_transactions_interface
		       WHERE group_id = p_group_id
		         AND item_id is null
		         AND item_description is null
		         AND (lpn_id is not null
			      OR license_plate_number is not null
			      OR transfer_lpn_id is not null
			      OR transfer_license_plate_number is not null)
		      );
       x_return_status := g_ret_sts_error;
       fnd_message.set_name('INV','INV_NOT_IMPLEMENTED');
       fnd_msg_pub.add;
       fnd_msg_pub.count_and_get
	 (  p_count  => x_msg_count
	    , p_data   => x_msg_data
	    );
    EXCEPTION
       when NO_DATA_FOUND then
	  x_return_status := g_ret_sts_success;
       when OTHERS then
	  x_return_status := g_ret_sts_error;
	  fnd_message.set_name('INV','INV_NOT_IMPLEMENTED');
	  fnd_msg_pub.add;
	  fnd_msg_pub.count_and_get
	    (  p_count  => x_msg_count
	       , p_data   => x_msg_data
	       );
    END;
    */
    -- l_exist := 0;
    -- SELECT 1
    --      into l_exist
    --                     FROM rcv_transactions_interface
    --                    WHERE group_id = p_group_id ;
    --       print_debug('group_id =' || p_group_id, 4);
    --       print_debug('exist =' || l_exist, 4);

    -- If not patchsetJ then return from this place.
    IF (inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j)  THEN
      IF (l_debug = 1) THEN
        print_debug('Explode_lpn Return from the API call AS not pset J or below pset J level', 4);
      END IF;
      return ;
    END IF;

    -- Call the Private API
    inv_rcv_integration_pvt.explode_lpn(p_request_id,p_group_id);

 END explode_lpn;

 /** validates subinventory and locator type called from TM for ROI trxns
  *  Check for rti records for current rti id or group id with wrong transaction type
  *  and subinventory/locator type combinations
  *  if group id is passed then we have to check through a cursor all rtis for
  *  that group id. if rti id is passed , we are sure that it is only one record
  *  in which case we use a select statement directly
  */
 PROCEDURE validate_sub_loc(
    p_api_version     IN            NUMBER
  , p_init_msg_lst    IN            VARCHAR2
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
  , p_group_id        IN            NUMBER
  , p_request_id      IN            NUMBER
  , p_rti_id          IN            NUMBER
  , p_validation_mode IN            NUMBER
  ) IS
    l_exist              NUMBER;
    l_sub                VARCHAR2(10);
    l_locator_id         NUMBER;
    l_trx_type           VARCHAR2(30);
    l_org_id             NUMBER;
    l_sub_type           NUMBER;
    l_lpn_cont_flag      NUMBER;
    l_loc_type           NUMBER;
    l_lpn_id             NUMBER;
    l_lpn_num            VARCHAR2(30);
    l_auto_transact_code VARCHAR2(30);
    l_location_id        NUMBER;

    --BUG 3633752: Break up the c_rti_sub_check cursor.  This is made
    --to improve performance
    CURSOR c_rti_sub_check_grp_intf_id IS
       SELECT subinventory
	 , locator_id
	 , transaction_type
	 , to_organization_id
	 , NVL(auto_transact_code, '@@@') auto_transact_code
	 , transfer_lpn_id
	 , transfer_license_plate_number
	 , location_id
	 FROM   rcv_transactions_interface rti
	 WHERE  GROUP_ID = p_group_id
	 AND    interface_transaction_id = p_rti_id;

    CURSOR c_rti_sub_check_grp_id IS
       SELECT subinventory
	 , locator_id
	 , transaction_type
	 , to_organization_id
	 , NVL(auto_transact_code, '@@@') auto_transact_code
	 , transfer_lpn_id
	 , transfer_license_plate_number
	 , location_id
	 FROM   rcv_transactions_interface rti
	 WHERE  GROUP_ID = p_group_id;

    CURSOR c_rti_sub_check_intf_id IS
       SELECT subinventory
	 , locator_id
	 , transaction_type
	 , to_organization_id
	 , NVL(auto_transact_code, '@@@') auto_transact_code
	 , transfer_lpn_id
	 , transfer_license_plate_number
	 , location_id
	 FROM   rcv_transactions_interface rti
	 WHERE 	 interface_transaction_id = p_rti_id;

    l_debug  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status := g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('VALIDATE_SUB_LOC 10: Entered with values ...', 1);
      print_debug('VALIDATE_SUB_LOC 10: ...RTID  :' || p_rti_id, 1);
      print_debug('VALIDATE_SUB_LOC 10: ...GID   :' || p_group_id, 1);
      print_debug('VALIDATE_SUB_LOC 10: ...REQID :' || p_request_id, 1);
    END IF;

    IF (p_group_id IS NOT NULL) THEN
       IF (p_rti_id IS NOT NULL) THEN
	  OPEN c_rti_sub_check_grp_intf_id;
	ELSE
	  OPEN c_rti_sub_check_grp_id;
       END IF;
     ELSE
       IF (p_rti_id IS NOT NULL) THEN
	  OPEN c_rti_sub_check_intf_id;
	ELSE
	  print_debug('VALIDATE_SUB_LOC 15: RTI and GID cannott both be null', 1);
       END IF;
    END IF;

    LOOP
       IF (p_group_id IS NOT NULL) THEN
	  IF (p_rti_id IS NOT NULL) THEN
	     FETCH c_rti_sub_check_grp_intf_id
	       INTO l_sub, l_locator_id, l_trx_type, l_org_id,
	       l_auto_transact_code, l_lpn_id, l_lpn_num, l_location_id;
	     EXIT WHEN c_rti_sub_check_grp_intf_id%NOTFOUND;
	   ELSE
	     FETCH c_rti_sub_check_grp_id
	       INTO l_sub, l_locator_id, l_trx_type, l_org_id,
	       l_auto_transact_code, l_lpn_id, l_lpn_num, l_location_id;
	     EXIT WHEN c_rti_sub_check_grp_id%NOTFOUND;
	  END IF;
	ELSE
	  IF (p_rti_id IS NOT NULL) THEN
	     FETCH c_rti_sub_check_intf_id
	       INTO l_sub, l_locator_id, l_trx_type, l_org_id,
	       l_auto_transact_code, l_lpn_id, l_lpn_num, l_location_id;
	     EXIT WHEN c_rti_sub_check_intf_id%NOTFOUND;
	   ELSE
	     print_debug('VALIDATE_SUB_LOC 15: RTI and GID cannott both be null', 1);
	  END IF;
       END IF;

       IF l_sub IS NOT NULL THEN
          SELECT NVL(subinventory_type, 1), Nvl(lpn_controlled_flag, 2)
	    INTO   l_sub_type, l_lpn_cont_flag
	    FROM   mtl_secondary_inventories msi
	    WHERE  secondary_inventory_name = l_sub
	    AND    organization_id = l_org_id;

          IF (l_sub_type = 2
              AND(l_trx_type = 'DELIVER'
                  OR l_auto_transact_code = 'DELIVER'))
	    OR(l_sub_type = 1
	       AND(l_trx_type IN
		   ('RECEIVE','ACCEPT','REJECT','TRANSFER','RETURN TO RECEIVING')
		   AND l_auto_transact_code <> 'DELIVER')) THEN
	     x_return_status := g_ret_sts_error;

	     IF (l_debug = 1) THEN
		print_debug('VALIDATE_SUB_LOC 60: Invalid Subinventory Type for the transaction:' || l_sub_type || ':' || l_trx_type, 1);
	     END IF;

	     fnd_message.set_name('INV', 'INV_INVALID_SUBINV');
	     fnd_msg_pub.ADD;
	     fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
	     RETURN;
          END IF; --IF (l_sub_type = 2

	  IF (l_lpn_cont_flag = 2
	      AND (l_lpn_id IS NOT NULL
		   OR l_lpn_num IS NOT NULL)
	      AND (l_trx_type IN
		   ('RECEIVE','ACCEPT','REJECT','TRANSFER','DELIVER','RETURN TO RECEIVING'))) THEN
	     x_return_status := g_ret_sts_error;

	     IF (l_debug = 1) THEN
		print_debug('VALIDATE_SUB_LOC 70: Invalid LPN Controlled Flag for the transaction:' || l_lpn_cont_flag || ':' || l_lpn_id || ':' || l_lpn_num, 1);
	     END IF;

	     fnd_message.set_name('INV', 'INV_INVALID_SUBINV');
	     fnd_msg_pub.ADD;
	     fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
	     RETURN;
	  END IF; --IF (l_lpn_cont_flag = 2
       END IF; --IF l_sub IS NOT NULL THEN

       IF l_locator_id IS NOT NULL THEN
          SELECT NVL(l_loc_type, -1)
	    INTO   l_loc_type
	    FROM   mtl_item_locations mil
	    WHERE  inventory_location_id = l_locator_id
	    AND    organization_id = l_org_id;

          IF (l_loc_type = 3 AND
	      (
	       l_trx_type IN('RECEIVE','TRANSFER','ACCEPT',
			     'REJECT','RETURN TO RECEIVING')
	       AND l_auto_transact_code <> 'DELIVER'
	       )
	      )
	    OR(l_loc_type IN(6, 7)
	       AND(l_trx_type = 'DELIVER'
		   OR l_auto_transact_code = 'DELIVER')) THEN
	     x_return_status := g_ret_sts_error;

	     IF (l_debug = 1) THEN
		print_debug('VALIDATE_SUB_LOC 80: Invalid Locator Type for the transaction:' || l_loc_type || ':' || l_trx_type, 1);
	     END IF;
	     fnd_message.set_name('INV', 'INV_INT_LOCCODE');
	     fnd_msg_pub.ADD;
	     fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
	     RETURN;
          END IF;
       END IF; --IF l_locator_id IS NOT NULL THEN

       IF l_sub IS NULL AND l_location_id IS NOT NULL THEN
	  BEGIN
	     IF (l_lpn_id is NOT NULL) THEN
		--BUG 3633752: Break up the query below.  This is made
		--to improve performance
		SELECT 1
		  INTO l_exist
		  FROM dual
		  WHERE exists (SELECT '1'
				FROM rcv_supply rs, wms_license_plate_numbers wlpn
				WHERE wlpn.lpn_id = l_lpn_id
				AND wlpn.lpn_id = rs.lpn_id
				AND rs.location_id <> l_location_id);
	      ELSE
		SELECT 1
		  INTO l_exist
		  FROM dual
		  WHERE exists (SELECT '1'
				FROM rcv_supply rs, wms_license_plate_numbers wlpn
				WHERE wlpn.license_plate_number = l_lpn_num
				AND wlpn.lpn_id = rs.lpn_id
				AND rs.location_id <> l_location_id);
	     END IF;

	     --error
	     IF (l_debug = 1) THEN
		print_debug('VALIDATE_SUB_LOC 90: Invalid Location for the transaction:' || l_location_id || ':' || l_trx_type, 1);
	     END IF;
	     fnd_message.set_name('INV', 'INV_INVALID_LOCATION');
	     fnd_msg_pub.ADD;
	     fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
	     RETURN;
	  EXCEPTION
	     WHEN no_data_found THEN
		IF (l_debug = 1) THEN
		   print_debug('VALIDATE_SUB_LOC 100: Valid Location for the transaction:' || l_location_id || ':' || l_trx_type, 1);
		END IF;
		x_return_status := g_ret_sts_success;
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   print_debug('VALIDATE_SUB_LOC 110: Invalid Location for the transaction:' || l_location_id || ':' || l_trx_type, 1);
		END IF;
		fnd_message.set_name('INV', 'INV_INVALID_LOCATION');
		fnd_msg_pub.ADD;
		fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
		RETURN;
	  END ;
       END IF; --IF (l_sub IS NULL AND l_location_id IS NOT NULL THEN
    END LOOP;

    IF (c_rti_sub_check_grp_intf_id%isopen) THEN
       CLOSE c_rti_sub_check_grp_intf_id;
    END IF;

    IF (c_rti_sub_check_grp_id%isopen) THEN
       CLOSE c_rti_sub_check_grp_id;
    END IF;

    IF (c_rti_sub_check_intf_id%isopen) THEN
       CLOSE c_rti_sub_check_grp_id;
    END IF;

    --    END IF;
    IF (l_debug = 1) THEN
       print_debug('VALIDATE_SUB_LOC 120: Exitting Successfully...', 4);
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
	IF (l_debug = 1) THEN
	   print_debug('VALIDATE_SUB_LOC: Expected exception occured...', 4);
	END IF;

	IF (c_rti_sub_check_grp_intf_id%isopen) THEN
	   CLOSE c_rti_sub_check_grp_intf_id;
	END IF;

	IF (c_rti_sub_check_grp_id%isopen) THEN
	   CLOSE c_rti_sub_check_grp_id;
	END IF;

	IF (c_rti_sub_check_intf_id%isopen) THEN
	   CLOSE c_rti_sub_check_grp_id;
	END IF;
 END validate_sub_loc;


 function split_lot_serial
  (p_api_version	IN  		NUMBER DEFAULT 1.0
   , p_init_msg_lst	IN  		VARCHAR2 DEFAULT g_false
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_new_rti_info	IN		inv_rcv_integration_apis.child_rec_tb_tp
   ) return BOOLEAN
   IS
      l_exist NUMBER;
      l_rti_id NUMBER;

      l_api_name VARCHAR2(30) := 'SPLIT_LOT_SERIAL';
      l_api_version         CONSTANT NUMBER := 1.0;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
    x_return_status := g_ret_sts_success;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
				       l_api_name, 'inv_rcv_integration_apis') THEN
       IF (l_debug = 1) THEN
	  print_debug('FND_API not compatible inv_rcv_integration_apis.split_lot_serial', 4);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
       fnd_msg_pub.initialize;
    END IF;

    inv_rcv_integration_pvt.split_lot_serial(p_rti_tb => p_new_rti_info,
					     x_return_status => x_return_status,
					     x_msg_count => x_msg_count,
					     x_msg_data => x_msg_data);
    IF (x_return_status <> g_ret_sts_success) THEN
       IF (l_debug = 1) THEN
	  print_debug('inv_rcv_intergration_pvt.split_lot_serial returned error',4);
       END IF;
       RETURN FALSE;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('inv_rcv_integration_pvt.split_lot_serial returned success',4);
    END IF;

    RETURN TRUE;
 END split_lot_serial;

 function process_transaction
  (p_api_version	IN  		NUMBER
   , p_init_msg_lst	IN  		VARCHAR2
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_rti_id           IN       	NUMBER
   ) return BOOLEAN
   IS
      l_org_id NUMBER;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
    x_return_status := g_ret_sts_success;

    IF (l_debug = 1) THEN
       print_debug ('Inside Process Transaction ...',1);
    END IF;

    /* INVCONV, This Procedure is currentlyt being called only by a discrete organization.
       Now on it shall be called for Process organization too
       It restricts the OPM transaction (through org_id) This needs to be removed.
       Punit Kumar*/

    /*
    -- get the org_id and item_id from rti to check if OPM transaction

    BEGIN
       SELECT to_organization_id
	 INTO l_org_id
	 FROM rcv_transactions_interface
        WHERE interface_transaction_id = p_rti_id;
    EXCEPTION
       WHEN OTHERS THEN
	  NULL;
    END;

    -- check if this is a OPM transaction. If it is a OPM transaction then
    -- error out. This API should not be called for a OPM transaction.
    IF gml_process_flags.check_process_orgn(l_org_id) = 1 THEN
       x_return_status := g_ret_sts_error;
       fnd_message.set_name('INV','INV_NOT_IMPLEMENTED');
       fnd_msg_pub.add;
       fnd_msg_pub.count_and_get
	 (  p_count  => x_msg_count
	    , p_data   => x_msg_data
	    );
       RETURN FALSE;
    END IF;
   */
   /*end , INVCONV */

    -- If not patchsetJ then return from this place.
    IF (inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j)  THEN
      IF (l_debug = 1) THEN
        print_debug('process_txn: Return from the API call AS  not pset J or below pset J level', 4);
      END IF;
      return TRUE ;
    END IF;

    /*INVCONV*/
    IF (l_debug = 1) THEN
       print_debug('process_transaction restricts the OPM transaction (through org_id) This needs to be removed.', 4);
    END IF;
    /*end , INVCONV */
    --call the process_txn to process the receiving transaction

    inv_rcv_integration_pvt.process_txn(p_txn_id => p_rti_id,
					x_return_status => x_return_status,
					x_msg_count => x_msg_count,
					x_msg_data => x_msg_data
					);
    IF (x_return_status <> g_ret_sts_success) THEN
       x_msg_data := x_msg_data||':'||fnd_message.get_string('INV','INV_FAILED');
       fnd_message.set_name('INV','INV_TRANSACTION_FAILED');
       fnd_msg_pub.ADD;
       RETURN FALSE;
    END IF;

    RETURN TRUE;
 EXCEPTION
    WHEN OTHERS THEN
       IF (l_debug = 1) THEN
	  print_debug('process_txn: private API throws exception', 4);
       END IF;
       x_return_status := g_ret_sts_error;
       RETURN FALSE;
 END process_transaction;

 function complete_lpn_group
  (p_api_version	  IN  		NUMBER
   , p_init_msg_lst	  IN  		VARCHAR2
   , x_return_status      OUT 	NOCOPY	VARCHAR2
   , x_msg_count          OUT 	NOCOPY	NUMBER
   , x_msg_data           OUT 	NOCOPY	VARCHAR2
   , p_lpn_group_id       IN       	NUMBER
   , p_group_id        	  IN       	NUMBER
   , p_shipment_header_id IN		NUMBER
   ) return BOOLEAN
   IS

      CURSOR c_txn_types IS
	 SELECT DISTINCT DECODE (rt.transaction_type,'ACCEPT','INSPECT',
				 'REJECT','INSPECT',
				 'DELIVER', DECODE (mp.wms_enabled_flag,'Y','PUTAWAY','DELIVER'),
				 transaction_type) transaction_type
	   FROM rcv_transactions rt,
	   mtl_parameters mp
	   WHERE rt.group_id = p_group_id
	   AND rt.organization_id = mp.organization_id;

      CURSOR c_pregen_cursor IS
	 SELECT DISTINCT rt.transfer_lpn_id
	   , rt.organization_id
	   FROM rcv_transactions rt
	   ,    mtl_parameters mp
	   ,    mtl_system_items_kfv msi
	   ,    rcv_supply rs
	   WHERE mp.wms_enabled_flag = 'Y'
	   AND mp.organization_id = rt.organization_id
	   AND rt.transaction_type IN ('RECEIVE','ACCEPT','REJECT')
	   AND rs.rcv_transaction_id = rt.transaction_id
	   AND rs.supply_type_code = 'RECEIVING'
	   AND rs.item_id = msi.inventory_item_id
	   AND msi.organization_id = rt.organization_id
	   AND rt.group_id = p_group_id
	   AND rt.lpn_group_id = p_lpn_group_id
	   AND ((msi.lot_control_code = 2
		AND exists (SELECT 1
			    FROM rcv_lots_supply rsl
			    WHERE rsl.transaction_id = rs.rcv_transaction_id)
		 )
		OR
		(msi.lot_control_code = 1))
	   AND ((msi.serial_number_control_code IN (2,5)
		 AND exists (SELECT 1
			     FROM rcv_serials_supply rss
			     WHERE rss.transaction_id = rs.rcv_transaction_id)
		 )
		OR
		(msi.serial_number_control_code IN (1, 6)))
		ORDER BY rt.transfer_lpn_id;

      l_label_status  VARCHAR2(500);
      l_bus_flow_code NUMBER;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_progress VARCHAR2(10) := '00';
      l_cd_count  NUMBER;--bug 6412992, 6907475;

 BEGIN
    x_return_status := g_ret_sts_success;

    l_progress := '10';

    IF (l_debug = 1) THEN
       print_debug('COMPLETE_LPN_GROUP - Entered...',1);
       print_debug('COMPLETE_LPN_GROUP - SHIPMENT_HEADER_ID:'||p_shipment_header_id,1);
       print_debug('COMPLETE_LPN_GROUP - LPN_GROUP_ID:'||p_lpn_group_id,1);
       print_debug('COMPLETE_LPN_GROUP - GROUP_ID:'||p_group_id,1);
    END IF;

    l_progress := '20';

    -- If not patchsetJ then return from this place.
    IF (inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j)  THEN
      IF (l_debug = 1) THEN
        print_debug('Complete_lpn_group: Return from the API call AS not pset J or below pset J level', 4);
      END IF;
      return TRUE ;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('COMPLETE_LPN_GROUP - Calling label print api...',1);
    END IF;

    IF (p_shipment_header_id IS NOT NULL) THEN
       inv_label.print_label_wrap(x_return_status => x_return_status
				  , x_msg_count => x_msg_count
				  , x_msg_data => x_msg_data
				  , x_label_status => l_label_status
				  , p_business_flow_code => inv_label.WMS_BF_IMPORT_ASN
				  , p_transaction_id => p_shipment_header_id
				  , p_transaction_identifier => inv_label.TRX_ID_RSH);

     ELSIF (p_group_id IS NOT NULL AND p_lpn_group_id IS NULL) THEN
       FOR l_txn_types IN C_TXN_TYPES
	 LOOP
	    IF l_txn_types.transaction_type = 'RECEIVE' THEN
	       L_BUS_FLOW_CODE := inv_label.WMS_BF_RECEIPT;
	     ELSIF l_txn_types.transaction_type = 'INSPECT' THEN
	       L_BUS_FLOW_CODE := inv_label.WMS_BF_INSPECTION;
	     ELSIF l_txn_types.transaction_type = 'DELIVER' THEN
	       L_BUS_FLOW_CODE := inv_label.WMS_BF_DELIVERY;
	     ELSIF l_txn_types.transaction_type = 'PUTAWAY' THEN
	       L_BUS_FLOW_CODE := inv_label.WMS_BF_PUTAWAY_DROP;
	    END IF;


       IF  l_txn_types.transaction_type <> 'PUTAWAY' THEN --BUG 6412992
	    --CALL LABEL PRINTING API WITH L_BUS_FLOW_CODE
          inv_label.print_label_wrap(x_return_status => x_return_status
                      , x_msg_count => x_msg_count
                      , x_msg_data => x_msg_data
                      , x_label_status => l_label_status
                      , p_business_flow_code => l_bus_flow_code
                      , p_transaction_id => p_group_id
                      , p_transaction_identifier => inv_label.trx_id_rt);
       ELSE--bug 6412992
         BEGIN
         --bug 6907475 added the condition to check for context of rt's transfer lpn_id to stop putaway label
         --for sales order cross dock
          SELECT 1 into l_cd_count
           FROM rcv_transactions rt
           WHERE rt.group_id= p_group_id
           AND (rt.wip_entity_id IS NOT NULL
           OR(rt.transfer_lpn_id IS NOT NULL AND EXISTS
              (SELECT 1 FROM wms_license_plate_numbers wlpn
              WHERE wlpn.lpn_id = rt.transfer_lpn_id
              AND wlpn.lpn_context = 11)))
           AND ROWNUM =1;
           IF (l_debug = 1) THEN
           print_debug('Line is cross docked so no need to call for put away business flow',1);
           END IF;
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
           inv_label.print_label_wrap(x_return_status => x_return_status
                      , x_msg_count => x_msg_count
                      , x_msg_data => x_msg_data
                      , x_label_status => l_label_status
                      , p_business_flow_code => l_bus_flow_code
                      , p_transaction_id => p_group_id
                      , p_transaction_identifier => inv_label.trx_id_rt);
            END;
          END IF; --bug 6412992 end


     END LOOP;
    END IF;

    IF (p_lpn_group_id IS NOT NULL ) THEN
       FOR l_pregen_rec IN c_pregen_cursor LOOP
	  IF (l_debug = 1) THEN
	     print_debug('COMPLETE_LPN_GROUP - Before calling start_pregenerate_program:'||l_progress,1);
	     l_progress := '30';
	  END IF;

	  wms_putaway_suggestions.start_pregenerate_program
	    (p_org_id => l_pregen_rec.organization_id,
	     p_lpn_id => l_pregen_rec.transfer_lpn_id,
	     x_return_status => x_return_status,
	     x_msg_count => x_msg_count,
	     x_msg_data => x_msg_data);

	  IF (l_debug = 1) THEN
	     print_debug('COMPLETE_LPN_GROUP - After calling start_pregenerate_program:'||x_return_status||':'||l_progress,1);
	     l_progress := '40';
	  END IF;

	  IF (x_return_status <> 'S') THEN
	     x_return_status := 'S';
	  END IF;

       END LOOP;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('COMPLETE_LPN_GROUP - Done calling label print api...',1);
       print_debug('COMPLETE_LPN_GROUP - Return Status:'||x_return_status,1);
    END IF;
	--14408061
    IF p_lpn_group_id IS NOT NULL AND inv_rcv_integration_pvt.g_lpn_tbl.COUNT>0 THEN
    IF (l_debug = 1) THEN
       print_debug('Deleting the LPN plsql table...g_lpn_tbl ',1);
    END IF;
	  inv_rcv_integration_pvt.g_lpn_tbl.DELETE();
	END IF;
	--14408061
    RETURN TRUE;
 END complete_lpn_group;


 PROCEDURE split_mmtt
   (x_orig_mol_rec          IN OUT nocopy mol_rec,
    x_new_mol_rec           IN OUT nocopy mol_rec,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_prim_qty_to_splt      IN  NUMBER,
    p_qty_to_splt           IN  NUMBER,
    p_prim_uom_code         IN  VARCHAR2,
    -- OPM Convergence
    p_sec_qty_to_splt      IN  NUMBER,
    p_sec_uom_code         IN  VARCHAR2,
    p_updt_putaway_temp_tbl IN  VARCHAR2,
    p_txn_header_id         IN  NUMBER,
    p_txn_temp_id           IN  NUMBER,
    p_remaining_mmtt_splt  IN  VARCHAR2,
    p_operation_type        IN VARCHAR2)
   IS
      CURSOR mmtt_cur IS
	 SELECT transaction_header_id
	   ,transaction_temp_id
	   ,source_code
	   ,source_line_id
	   ,transaction_mode
	   ,lock_flag
	   ,last_update_date
	   ,last_updated_by
	   ,creation_date
	   ,created_by
	   ,last_update_login
	   ,request_id
	   ,program_application_id
	   ,program_id
	   ,program_update_date
	   ,inventory_item_id
	   ,revision
	   ,organization_id
	   ,subinventory_code
	   ,locator_id
	   ,transaction_quantity
	   ,primary_quantity
	   ,transaction_uom
      ,transaction_cost
	   ,transaction_type_id
	   ,transaction_action_id
	   ,transaction_source_type_id
	   ,transaction_source_id
	   ,transaction_source_name
	   ,transaction_date
	   ,acct_period_id
	   ,distribution_account_id
	   ,transaction_reference
	   ,requisition_line_id
	   ,requisition_distribution_id
	   ,reason_id
	   ,Ltrim(Rtrim(lot_number)) lot_number
	   ,lot_expiration_date
	   ,serial_number
	   ,receiving_document
	   ,demand_id
	   ,rcv_transaction_id
	   ,move_transaction_id
	   ,completion_transaction_id
	   ,wip_entity_type
	   ,schedule_id
	   ,repetitive_line_id
	   ,employee_code
	   ,primary_switch
	   ,schedule_update_code
	   ,setup_teardown_code
	   ,item_ordering
	   ,negative_req_flag
	   ,operation_seq_num
	   ,picking_line_id
	   ,trx_source_line_id
	   ,trx_source_delivery_id
	   ,physical_adjustment_id
	   ,cycle_count_id
	   ,rma_line_id
	   ,customer_ship_id
	   ,currency_code
	   ,currency_conversion_rate
	   ,currency_conversion_type
	   ,currency_conversion_date
	   ,ussgl_transaction_code
	   ,vendor_lot_number
	   ,encumbrance_account
	   ,encumbrance_amount
	   ,ship_to_location
	   ,shipment_number
	   ,transfer_cost
	   ,transportation_cost
	   ,transportation_account
	   ,freight_code
	   ,containers
	   ,waybill_airbill
	   ,expected_arrival_date
	   ,transfer_subinventory
	   ,transfer_organization
	   ,transfer_to_location
	   ,new_average_cost
	   ,value_change
	   ,percentage_change
	   ,material_allocation_temp_id
	   ,demand_source_header_id
	   ,demand_source_line
	   ,demand_source_delivery
	   ,item_segments
	   ,item_description
	   ,item_trx_enabled_flag
	   ,item_location_control_code
	   ,item_restrict_subinv_code
	   ,item_restrict_locators_code
	   ,item_revision_qty_control_code
	   ,item_primary_uom_code
	   ,item_uom_class
	   ,item_shelf_life_code
	   ,item_shelf_life_days
	   ,item_lot_control_code
	   ,item_serial_control_code
	   ,item_inventory_asset_flag
	   ,allowed_units_lookup_code
	   ,department_id
	   ,department_code
	   ,wip_supply_type
	   ,supply_subinventory
	   ,supply_locator_id
	   ,valid_subinventory_flag
	   ,valid_locator_flag
	   ,locator_segments
	   ,current_locator_control_code
	   ,number_of_lots_entered
	   ,wip_commit_flag
	   ,next_lot_number
	   ,lot_alpha_prefix
	   ,next_serial_number
	   ,serial_alpha_prefix
	   ,shippable_flag
	   ,posting_flag
	   ,required_flag
	   ,process_flag
	   ,error_code
	   ,error_explanation
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
	   ,movement_id
	   ,reservation_quantity
	   ,shipped_quantity
	   ,transaction_line_number
	   ,task_id
	   ,to_task_id
	   ,source_task_id
	   ,project_id
	   ,source_project_id
	   ,pa_expenditure_org_id
	   ,to_project_id
	   ,expenditure_type
	   ,final_completion_flag
	   ,transfer_percentage
	   ,transaction_sequence_id
	   ,material_account
	   ,material_overhead_account
	   ,resource_account
	   ,outside_processing_account
	   ,overhead_account
	   ,flow_schedule
	   ,cost_group_id
	   ,demand_class
	   ,qa_collection_id
	   ,kanban_card_id
	   ,overcompletion_transaction_qty
	   ,overcompletion_primary_qty
	   ,overcompletion_transaction_id
	   ,end_item_unit_number
	   ,scheduled_payback_date
	   ,line_type_code
	   ,parent_transaction_temp_id
	   ,put_away_strategy_id
	   ,put_away_rule_id
	   ,pick_strategy_id
	   ,pick_rule_id
	   ,move_order_line_id
	   ,task_group_id
	   ,pick_slip_number
	   ,reservation_id
	   ,common_bom_seq_id
	   ,common_routing_seq_id
	   ,org_cost_group_id
	   ,cost_type_id
	   ,transaction_status
	   ,standard_operation_id
	   ,task_priority
	   ,wms_task_type
	   ,parent_line_id
	   ,transfer_cost_group_id
	   ,lpn_id
	   ,transfer_lpn_id
	   ,wms_task_status
	   ,content_lpn_id
	   ,container_item_id
	   ,cartonization_id
	   ,pick_slip_date
	   ,rebuild_item_id
	   ,rebuild_serial_number
	   ,rebuild_activity_id
	   ,rebuild_job_name
	   ,organization_type
	   ,transfer_organization_type
	   ,owning_organization_id
	   ,owning_tp_type
	   ,xfr_owning_organization_id
	   ,transfer_owning_tp_type
	   ,planning_organization_id
	   ,planning_tp_type
	   ,xfr_planning_organization_id
	   ,transfer_planning_tp_type
	   ,secondary_uom_code
	   ,secondary_transaction_quantity
	   ,allocated_lpn_id
	   ,schedule_number
	   ,scheduled_flag
	   ,class_code
	   ,schedule_group
	   ,build_sequence
	   ,bom_revision
	   ,routing_revision
	   ,bom_revision_date
	   ,routing_revision_date
	   ,alternate_bom_designator
	   ,alternate_routing_designator
	   ,transaction_batch_id
	   ,transaction_batch_seq
	   ,operation_plan_id
	   ,move_order_header_id
	   ,serial_allocated_flag
	   FROM mtl_material_transactions_temp
	   WHERE
	   -- For call from putaway: p_operation_type will be null
	   -- For call from item load putaway, type will be 'LOAD' or 'DROP'
	   (((p_operation_type IS NULL OR p_operation_type IN ('LOAD','DROP'))
	     AND p_remaining_mmtt_splt = 'N'
	     AND Nvl(transaction_header_id, -2) <> Nvl(p_txn_header_id, -1))
	    OR
	    -- For call from putaway when it is splitting the remaining header id
	    (p_operation_type IS NULL
	     AND p_remaining_mmtt_splt = 'Y'
	     AND transaction_header_id = p_txn_header_id)
	    OR
	    -- For call from deliver
	    (p_operation_type = 'DELIVER'
	     AND transaction_temp_id = p_txn_temp_id))
	   AND move_order_line_id = x_orig_mol_rec.line_id
	   AND ((transaction_source_type_id = 1 AND
		 transaction_action_id = 27) OR
		( transaction_source_type_id = 7 AND
		  transaction_action_id = 12) OR
		( transaction_source_type_id = 12 AND
		  transaction_action_id = 27) OR
		( transaction_source_type_id = 4 AND
		  transaction_action_id = 2) OR
		( transaction_source_type_id = 5 AND
		  transaction_action_id IN (27,31)  ) OR
		( transaction_source_type_id = 4 AND
		  transaction_action_id = 27)OR
                ( transaction_source_type_id = 13  AND
                  transaction_action_id = 12) ) --bugfix 5263798
		order by transaction_temp_id asc; --bugfix 6189438

      l_orig_mmtt_rec mmtt_cur%ROWTYPE;
      l_new_mmtt_rec mmtt_cur%ROWTYPE;
      l_prim_qty_to_splt NUMBER := p_prim_qty_to_splt;
      l_qty_to_splt      NUMBER := p_qty_to_splt;
      -- OPM Convergence
      l_sec_qty_to_splt NUMBER := NVL(p_sec_qty_to_splt, 0);

      l_new_mmtt_id      NUMBER;
      l_mmtts_to_split  wms_atf_runtime_pub_apis.task_id_table_type;
      l_lot_control_code NUMBER;
      l_serial_control_code NUMBER;
      l_new_txn_tb inv_rcv_common_apis.trans_rec_tb_tp;
      l_temp NUMBER;
      l_sysdate DATE := Sysdate;
      l_debug NUMBER := Nvl(fnd_profile.value('INV_DEBUG_TRACE'), 0);
      l_progress VARCHAR2(10) := '0';
      l_error_code NUMBER;
      l_inspection_flag NUMBER;
      l_load_flag  NUMBER;
      l_drop_flag NUMBER;
      l_load_prim_quantity NUMBER;
      l_inspect_prim_quantity NUMBER;
      l_drop_prim_quantity NUMBER;


      l_skip_iteration VARCHAR2(1) := 'N';
 BEGIN
    IF (l_debug = 1) THEN
       print_debug('SPLIT_MMTT Modified: Entering...', 4);     --bug 6189438
       print_debug('     p_prim_qty_to_splt => '||p_prim_qty_to_splt,4);
       print_debug('     p_qty_to_splt      => '||p_qty_to_splt,4);
       print_debug('     p_prim_uom_code    => '||p_prim_uom_code,4);
       -- OPM Convergence
       print_debug('     p_sec_qty_to_splt      => '||p_sec_qty_to_splt,4);
       print_debug('     p_sec_uom_code    => '||p_sec_uom_code,4);
       print_debug('     p_updt_putaway_temp_tbl =>'||p_updt_putaway_temp_tbl,4);
       print_debug('     p_txn_header_id    => '||p_txn_header_id,4);
       print_debug('     p_remaining_mmtt_splt => '||p_remaining_mmtt_splt,4);
    END IF;

    x_return_status := g_ret_sts_success;

    l_progress := '10';

    OPEN mmtt_cur;

    l_progress := '20';

    l_skip_iteration := 'N';
    LOOP
       l_skip_iteration := 'N';
       l_progress := '30';
       FETCH mmtt_cur INTO l_orig_mmtt_rec;
       l_progress := '40';
       IF (p_remaining_mmtt_splt = 'Y') THEN
	  IF (mmtt_cur%notfound) THEN
	     IF (l_debug = 1) THEN
		print_debug('SPLIT_MMTT: No remaining MMTT with header_id '
			    || p_txn_header_id || ' found MOL',4);
	     END IF;
	     fnd_message.set_name('WMS','WMS_TASK_NO_ELIGIBLE_TASKS');
	     fnd_msg_pub.add;
	     RAISE fnd_api.g_exc_error;
	  END IF;
	ELSE
	  IF (mmtt_cur%notfound) THEN
	     IF (l_debug = 1) THEN
		print_debug('SPLIT_MMTT - No MMTT have been found for MOL:'
			    ||x_orig_mol_rec.line_id,4);
	     END IF;

	     -- Update original MOL
	     x_orig_mol_rec.primary_quantity := x_orig_mol_rec.primary_quantity - l_prim_qty_to_splt;
	     x_orig_mol_rec.quantity := x_orig_mol_rec.quantity - l_qty_to_splt;
        x_orig_mol_rec.secondary_quantity := NVL(x_orig_mol_rec.secondary_quantity,0) - l_sec_qty_to_splt;


	     -- Update new MOL
	     x_new_mol_rec.primary_quantity := x_new_mol_rec.primary_quantity + l_prim_qty_to_splt;
	     x_new_mol_rec.quantity := x_new_mol_rec.quantity + l_qty_to_splt;
	     x_new_mol_rec.secondary_quantity := NVL(x_new_mol_rec.secondary_quantity,0) + l_sec_qty_to_splt;

	     IF (l_debug = 1) THEN
		print_debug('SPLIT_MMTT - Progress:'||l_progress||
			    ' Successfully assigned non-detailed quantity',
			    4);
	     END IF;
	     EXIT;
	  END IF; --IF (mmtt_cur%notfound)
       END IF; --(p_remaining_mmtt_splt = 'Y')

       l_progress := '70';

       -- If the operation is LOAD or DROP, then need to filter MMTT
       IF (p_operation_type IN ('LOAD', 'DROP')) THEN
	  wms_atf_runtime_pub_apis.validate_operation
	    (x_return_status    =>   x_return_status
	     ,x_msg_data         =>   x_msg_data
	     ,x_msg_count        =>   x_msg_count
	     ,x_error_code       =>   l_error_code
	     ,x_inspection_flag  =>   l_inspection_flag
	     ,x_load_flag        =>   l_load_flag
	     ,x_drop_flag        =>   l_drop_flag
	     ,x_load_prim_quantity => l_load_prim_quantity
	     ,x_drop_prim_quantity => l_drop_prim_quantity
	     ,x_inspect_prim_quantity => l_inspect_prim_quantity
	     ,p_source_task_id   =>   l_orig_mmtt_rec.transaction_temp_id
	     ,p_move_order_line_id => NULL
	     ,p_inventory_item_id =>  NULL
	     ,p_lpn_id           =>   NULL
	     ,p_activity_type_id =>   1 -- INBOUND
	     ,p_organization_id  =>   l_orig_mmtt_rec.organization_id);
	  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	     IF (l_debug = 1) THEN
		print_debug('SPLIT_MMTT: validate_operation failed',4);
	     END IF;
	     RAISE fnd_api.g_exc_error;
	  END IF;

	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MMTT: Values returned from call to validate_operation',4);
	     print_debug('  x_inspection_flag: =======> ' || l_inspection_flag,4);
	     print_debug('  x_load_flag: =============> ' || l_load_flag,4);
	     print_debug('  x_drop_flag: =============> ' || l_drop_flag,4);
	     print_debug('  x_load_prim_quantity: ====> ' || l_load_prim_quantity,4);
	     print_debug('  x_drop_prim_quantity: ====> ' || l_drop_prim_quantity,4);
	     print_debug('  x_inspect_prim_quantity: => ' || l_inspect_prim_quantity,4);
	  END IF;

	  IF (p_operation_type = 'LOAD') THEN
	     IF (l_load_flag <> 3) THEN
		IF (l_debug = 1) THEN
		   print_debug('SPLIT_MMTT: MMTT Not fully loaded, next iteration...',4);
		END IF;
		fnd_message.set_name('WMS', 'WMS_TASK_NOT_FULLY_LOADED');
		fnd_msg_pub.ADD;
		l_skip_iteration := 'Y';
	     END IF;
	   ELSE -- p_peration_type = 'DROP'
	     IF (l_drop_flag <> 3) THEN
		IF (l_debug = 1) THEN
		   print_debug('SPLIT_MMTT: MMTT Not fully dropped, next iteration...',4);
		END IF;
		fnd_message.set_name('WMS', 'WMS_TASK_NOT_FULLY_DROPPED');
		fnd_msg_pub.ADD;
		l_skip_iteration := 'Y';
	     END IF;
	  END IF;
       END IF; --IF (p_operation_type IN ('LOAD', 'DROP'))

       IF (l_skip_iteration <> 'Y') THEN
       -- MMTT Exists
       -- If the MMTT has more than enough to split, than split this MMTT into the new MOL
       IF (l_orig_mmtt_rec.primary_quantity > l_prim_qty_to_splt) THEN

	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MMTT: splitting MMTT'||
			 l_orig_mmtt_rec.transaction_temp_id||
			 ' with QTY:' || l_orig_mmtt_rec.primary_quantity||
			 ' into QTY:' || l_prim_qty_to_splt ||
			 ' with SEC QTY:' || l_orig_mmtt_rec.secondary_transaction_quantity||
			 ' into SEC QTY:' || l_sec_qty_to_splt ||
			 '... More than enough',4);
	  END IF;

	  l_progress := '80';

	  --create a new MMTT record, set the new quantity, insert into MMTT table
	  l_new_mmtt_rec := l_orig_mmtt_rec;
	  l_new_mmtt_rec.move_order_line_id := x_new_mol_rec.line_id;
	  l_new_mmtt_rec.primary_quantity := l_prim_qty_to_splt;
     -- OPMCOnvergence
     l_new_mmtt_rec.secondary_transaction_quantity := l_sec_qty_to_splt;

	  --Must use mmtt quantity and primary quantity for conversion
	  IF (l_orig_mmtt_rec.transaction_uom = x_orig_mol_rec.uom_code) THEN
	     l_temp := l_qty_to_splt;
	   ELSE
	     l_temp := inv_rcv_cache.convert_qty
	                  (p_inventory_item_id   => x_orig_mol_rec.inventory_item_id
			   ,p_from_qty           => l_prim_qty_to_splt
			   ,p_from_uom_code      => p_prim_uom_code
			   ,p_to_uom_code        => l_orig_mmtt_rec.transaction_uom
			   );
	  END IF;

	  l_progress := '90';

	  l_new_mmtt_rec.transaction_quantity := l_temp;

          BEGIN
	     INSERT INTO mtl_material_transactions_temp
	       ( transaction_header_id
		 ,transaction_temp_id
		 ,source_code
		 ,source_line_id
		 ,transaction_mode
		 ,lock_flag
		 ,last_update_date
		 ,last_updated_by
		 ,creation_date
		 ,created_by
		 ,last_update_login
		 ,request_id
		 ,program_application_id
		 ,program_id
		 ,program_update_date
		 ,inventory_item_id
		 ,revision
		 ,organization_id
		 ,subinventory_code
		 ,locator_id
		 ,transaction_quantity
		 ,primary_quantity
		 ,transaction_uom
		 ,transaction_cost
		 ,transaction_type_id
		 ,transaction_action_id
		 ,transaction_source_type_id
		 ,transaction_source_id
		 ,transaction_source_name
		 ,transaction_date
		 ,acct_period_id
		 ,distribution_account_id
		 ,transaction_reference
		 ,requisition_line_id
		 ,requisition_distribution_id
		 ,reason_id
		 ,lot_number
		 ,lot_expiration_date
		 ,serial_number
		 ,receiving_document
		 ,demand_id
		 ,rcv_transaction_id
		 ,move_transaction_id
		 ,completion_transaction_id
		 ,wip_entity_type
	       ,schedule_id
	       ,repetitive_line_id
	       ,employee_code
	       ,primary_switch
	       ,schedule_update_code
	       ,setup_teardown_code
	       ,item_ordering
	       ,negative_req_flag
	       ,operation_seq_num
	       ,picking_line_id
	       ,trx_source_line_id
	       ,trx_source_delivery_id
	       ,physical_adjustment_id
	       ,cycle_count_id
	       ,rma_line_id
	       ,customer_ship_id
	       ,currency_code
	       ,currency_conversion_rate
	       ,currency_conversion_type
	       ,currency_conversion_date
	       ,ussgl_transaction_code
	       ,vendor_lot_number
	       ,encumbrance_account
	       ,encumbrance_amount
	       ,ship_to_location
	       ,shipment_number
	       ,transfer_cost
	       ,transportation_cost
	       ,transportation_account
	       ,freight_code
	       ,containers
	       ,waybill_airbill
	       ,expected_arrival_date
	       ,transfer_subinventory
	       ,transfer_organization
	       ,transfer_to_location
	       ,new_average_cost
	       ,value_change
	       ,percentage_change
	       ,material_allocation_temp_id
	       ,demand_source_header_id
	       ,demand_source_line
	       ,demand_source_delivery
	       ,item_segments
	       ,item_description
	       ,item_trx_enabled_flag
	       ,item_location_control_code
	       ,item_restrict_subinv_code
	       ,item_restrict_locators_code
	       ,item_revision_qty_control_code
	       ,item_primary_uom_code
	       ,item_uom_class
	       ,item_shelf_life_code
	       ,item_shelf_life_days
	       ,item_lot_control_code
	       ,item_serial_control_code
	       ,item_inventory_asset_flag
	       ,allowed_units_lookup_code
	       ,department_id
	       ,department_code
	       ,wip_supply_type
	       ,supply_subinventory
	       ,supply_locator_id
	       ,valid_subinventory_flag
	       ,valid_locator_flag
	       ,locator_segments
	       ,current_locator_control_code
	       ,number_of_lots_entered
	       ,wip_commit_flag
	       ,next_lot_number
	       ,lot_alpha_prefix
	       ,next_serial_number
	       ,serial_alpha_prefix
	       ,shippable_flag
	       ,posting_flag
	       ,required_flag
	       ,process_flag
	       ,error_code
	       ,error_explanation
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
	       ,movement_id
	       ,reservation_quantity
	       ,shipped_quantity
	       ,transaction_line_number
	       ,task_id
	       ,to_task_id
	       ,source_task_id
	       ,project_id
	       ,source_project_id
	       ,pa_expenditure_org_id
	       ,to_project_id
	       ,expenditure_type
	       ,final_completion_flag
	       ,transfer_percentage
	       ,transaction_sequence_id
	       ,material_account
	       ,material_overhead_account
	       ,resource_account
	       ,outside_processing_account
	       ,overhead_account
	       ,flow_schedule
	       ,cost_group_id
	       ,demand_class
	       ,qa_collection_id
	       ,kanban_card_id
	       ,overcompletion_transaction_qty
	       ,overcompletion_primary_qty
	       ,overcompletion_transaction_id
	       ,end_item_unit_number
	       ,scheduled_payback_date
	       ,line_type_code
	       ,parent_transaction_temp_id
	       ,put_away_strategy_id
	       ,put_away_rule_id
	       ,pick_strategy_id
	       ,pick_rule_id
	       ,move_order_line_id
	       ,task_group_id
	       ,pick_slip_number
	       ,reservation_id
	       ,common_bom_seq_id
	       ,common_routing_seq_id
	       ,org_cost_group_id
	       ,cost_type_id
	       ,transaction_status
	       ,standard_operation_id
	       ,task_priority
	       ,wms_task_type
	       ,parent_line_id
	       ,transfer_cost_group_id
	       ,lpn_id
	       ,transfer_lpn_id
	       ,wms_task_status
	       ,content_lpn_id
	       ,container_item_id
	       ,cartonization_id
	       ,pick_slip_date
	       ,rebuild_item_id
	       ,rebuild_serial_number
	       ,rebuild_activity_id
	       ,rebuild_job_name
	       ,organization_type
	       ,transfer_organization_type
	       ,owning_organization_id
	       ,owning_tp_type
	       ,xfr_owning_organization_id
	       ,transfer_owning_tp_type
	       ,planning_organization_id
	       ,planning_tp_type
	       ,xfr_planning_organization_id
	       ,transfer_planning_tp_type
	       ,secondary_uom_code
	       ,secondary_transaction_quantity
	       ,allocated_lpn_id
	       ,schedule_number
	       ,scheduled_flag
	       ,class_code
	       ,schedule_group
	       ,build_sequence
	       ,bom_revision
	       ,routing_revision
	       ,bom_revision_date
	       ,routing_revision_date
	       ,alternate_bom_designator
	       ,alternate_routing_designator
	       ,transaction_batch_id
	       ,transaction_batch_seq
	       ,operation_plan_id
	       ,move_order_header_id
	       ,serial_allocated_flag )
	       VALUES
	       ( mtl_material_transactions_s.NEXTVAL  --use different header
		 ,mtl_material_transactions_s.NEXTVAL
		 ,l_new_mmtt_rec.SOURCE_CODE
		 ,l_new_mmtt_rec.SOURCE_LINE_ID
		 ,l_new_mmtt_rec.TRANSACTION_MODE
		 ,l_new_mmtt_rec.LOCK_FLAG
		 ,l_sysdate
		 ,l_new_mmtt_rec.LAST_UPDATED_BY
		 ,l_sysdate
		 ,l_new_mmtt_rec.CREATED_BY
		 ,l_new_mmtt_rec.LAST_UPDATE_LOGIN
		 ,l_new_mmtt_rec.REQUEST_ID
		 ,l_new_mmtt_rec.PROGRAM_APPLICATION_ID
		 ,l_new_mmtt_rec.PROGRAM_ID
		 ,l_new_mmtt_rec.PROGRAM_UPDATE_DATE
		 ,l_new_mmtt_rec.INVENTORY_ITEM_ID
		 ,l_new_mmtt_rec.REVISION
		 ,l_new_mmtt_rec.ORGANIZATION_ID
		 ,l_new_mmtt_rec.SUBINVENTORY_CODE
		 ,l_new_mmtt_rec.LOCATOR_ID
		 ,l_new_mmtt_rec.TRANSACTION_QUANTITY
		 ,l_new_mmtt_rec.PRIMARY_QUANTITY
		 ,l_new_mmtt_rec.TRANSACTION_UOM
		 ,l_new_mmtt_rec.TRANSACTION_COST
		 ,l_new_mmtt_rec.TRANSACTION_TYPE_ID
		 ,l_new_mmtt_rec.TRANSACTION_ACTION_ID
		 ,l_new_mmtt_rec.TRANSACTION_SOURCE_TYPE_ID
		 ,l_new_mmtt_rec.TRANSACTION_SOURCE_ID
		 ,l_new_mmtt_rec.TRANSACTION_SOURCE_NAME
	       ,l_new_mmtt_rec.TRANSACTION_DATE
	       ,l_new_mmtt_rec.ACCT_PERIOD_ID
	       ,l_new_mmtt_rec.DISTRIBUTION_ACCOUNT_ID
	       ,l_new_mmtt_rec.TRANSACTION_REFERENCE
	       ,l_new_mmtt_rec.REQUISITION_LINE_ID
	       ,l_new_mmtt_rec.REQUISITION_DISTRIBUTION_ID
	       ,l_new_mmtt_rec.REASON_ID
	       ,Ltrim(Rtrim(l_new_mmtt_rec.lot_number))
	       ,l_new_mmtt_rec.LOT_EXPIRATION_DATE
	       ,l_new_mmtt_rec.SERIAL_NUMBER
	       ,l_new_mmtt_rec.RECEIVING_DOCUMENT
	       ,l_new_mmtt_rec.DEMAND_ID
	       ,l_new_mmtt_rec.RCV_TRANSACTION_ID
	       ,l_new_mmtt_rec.MOVE_TRANSACTION_ID
	       ,l_new_mmtt_rec.COMPLETION_TRANSACTION_ID
	       ,l_new_mmtt_rec.WIP_ENTITY_TYPE
	       ,l_new_mmtt_rec.SCHEDULE_ID
	       ,l_new_mmtt_rec.REPETITIVE_LINE_ID
	       ,l_new_mmtt_rec.employee_code
	       ,l_new_mmtt_rec.PRIMARY_SWITCH
	       ,l_new_mmtt_rec.SCHEDULE_UPDATE_CODE
	       ,l_new_mmtt_rec.SETUP_TEARDOWN_CODE
	       ,l_new_mmtt_rec.ITEM_ORDERING
	       ,l_new_mmtt_rec.NEGATIVE_REQ_FLAG
	       ,l_new_mmtt_rec.OPERATION_SEQ_NUM
	       ,l_new_mmtt_rec.PICKING_LINE_ID
	       ,l_new_mmtt_rec.TRX_SOURCE_LINE_ID
	       ,l_new_mmtt_rec.TRX_SOURCE_DELIVERY_ID
	       ,l_new_mmtt_rec.PHYSICAL_ADJUSTMENT_ID
	       ,l_new_mmtt_rec.CYCLE_COUNT_ID
	       ,l_new_mmtt_rec.RMA_LINE_ID
	       ,l_new_mmtt_rec.CUSTOMER_SHIP_ID
	       ,l_new_mmtt_rec.CURRENCY_CODE
	       ,l_new_mmtt_rec.CURRENCY_CONVERSION_RATE
	       ,l_new_mmtt_rec.CURRENCY_CONVERSION_TYPE
	       ,l_new_mmtt_rec.CURRENCY_CONVERSION_DATE
	       ,l_new_mmtt_rec.USSGL_TRANSACTION_CODE
	       ,l_new_mmtt_rec.VENDOR_LOT_NUMBER
	       ,l_new_mmtt_rec.ENCUMBRANCE_ACCOUNT
	       ,l_new_mmtt_rec.ENCUMBRANCE_AMOUNT
	       ,l_new_mmtt_rec.SHIP_TO_LOCATION
	       ,l_new_mmtt_rec.SHIPMENT_NUMBER
	       ,l_new_mmtt_rec.TRANSFER_COST
	       ,l_new_mmtt_rec.TRANSPORTATION_COST
	       ,l_new_mmtt_rec.TRANSPORTATION_ACCOUNT
	       ,l_new_mmtt_rec.FREIGHT_CODE
	       ,l_new_mmtt_rec.CONTAINERS
	       ,l_new_mmtt_rec.WAYBILL_AIRBILL
	       ,l_new_mmtt_rec.EXPECTED_ARRIVAL_DATE
	       ,l_new_mmtt_rec.TRANSFER_SUBINVENTORY
	       ,l_new_mmtt_rec.TRANSFER_ORGANIZATION
	       ,l_new_mmtt_rec.TRANSFER_TO_LOCATION
	       ,l_new_mmtt_rec.NEW_AVERAGE_COST
	       ,l_new_mmtt_rec.VALUE_CHANGE
	       ,l_new_mmtt_rec.PERCENTAGE_CHANGE
	       ,l_new_mmtt_rec.MATERIAL_ALLOCATION_TEMP_ID
	       ,l_new_mmtt_rec.DEMAND_SOURCE_HEADER_ID
	       ,l_new_mmtt_rec.DEMAND_SOURCE_LINE
	       ,l_new_mmtt_rec.DEMAND_SOURCE_DELIVERY
	       ,l_new_mmtt_rec.ITEM_SEGMENTS
	       ,l_new_mmtt_rec.ITEM_DESCRIPTION
	       ,l_new_mmtt_rec.ITEM_TRX_ENABLED_FLAG
	       ,l_new_mmtt_rec.ITEM_LOCATION_CONTROL_CODE
	       ,l_new_mmtt_rec.ITEM_RESTRICT_SUBINV_CODE
	       ,l_new_mmtt_rec.ITEM_RESTRICT_LOCATORS_CODE
	       ,l_new_mmtt_rec.ITEM_REVISION_QTY_CONTROL_CODE
	       ,l_new_mmtt_rec.ITEM_PRIMARY_UOM_CODE
	       ,l_new_mmtt_rec.ITEM_UOM_CLASS
	       ,l_new_mmtt_rec.ITEM_SHELF_LIFE_CODE
	       ,l_new_mmtt_rec.ITEM_SHELF_LIFE_DAYS
	       ,l_new_mmtt_rec.ITEM_LOT_CONTROL_CODE
	       ,l_new_mmtt_rec.ITEM_SERIAL_CONTROL_CODE
	       ,l_new_mmtt_rec.ITEM_INVENTORY_ASSET_FLAG
	       ,l_new_mmtt_rec.ALLOWED_UNITS_LOOKUP_CODE
	       ,l_new_mmtt_rec.DEPARTMENT_ID
	       ,l_new_mmtt_rec.DEPARTMENT_CODE
	       ,l_new_mmtt_rec.WIP_SUPPLY_TYPE
	       ,l_new_mmtt_rec.SUPPLY_SUBINVENTORY
	       ,l_new_mmtt_rec.SUPPLY_LOCATOR_ID
	       ,l_new_mmtt_rec.VALID_SUBINVENTORY_FLAG
	       ,l_new_mmtt_rec.VALID_LOCATOR_FLAG
	       ,l_new_mmtt_rec.LOCATOR_SEGMENTS
	       ,l_new_mmtt_rec.CURRENT_LOCATOR_CONTROL_CODE
	       ,l_new_mmtt_rec.NUMBER_OF_LOTS_ENTERED
	       ,l_new_mmtt_rec.WIP_COMMIT_FLAG
	       ,l_new_mmtt_rec.NEXT_LOT_NUMBER
	       ,l_new_mmtt_rec.LOT_ALPHA_PREFIX
	       ,l_new_mmtt_rec.NEXT_SERIAL_NUMBER
	       ,l_new_mmtt_rec.SERIAL_ALPHA_PREFIX
	       ,l_new_mmtt_rec.SHIPPABLE_FLAG
	       ,l_new_mmtt_rec.POSTING_FLAG
	       ,l_new_mmtt_rec.REQUIRED_FLAG
	       ,l_new_mmtt_rec.PROCESS_FLAG
	       ,l_new_mmtt_rec.ERROR_CODE
	       ,l_new_mmtt_rec.ERROR_EXPLANATION
	       ,l_new_mmtt_rec.ATTRIBUTE_CATEGORY
	       ,l_new_mmtt_rec.ATTRIBUTE1
	       ,l_new_mmtt_rec.ATTRIBUTE2
	       ,l_new_mmtt_rec.ATTRIBUTE3
	       ,l_new_mmtt_rec.ATTRIBUTE4
	       ,l_new_mmtt_rec.ATTRIBUTE5
	       ,l_new_mmtt_rec.ATTRIBUTE6
	       ,l_new_mmtt_rec.ATTRIBUTE7
	       ,l_new_mmtt_rec.ATTRIBUTE8
	       ,l_new_mmtt_rec.ATTRIBUTE9
	       ,l_new_mmtt_rec.ATTRIBUTE10
	       ,l_new_mmtt_rec.ATTRIBUTE11
	       ,l_new_mmtt_rec.ATTRIBUTE12
	       ,l_new_mmtt_rec.ATTRIBUTE13
	       ,l_new_mmtt_rec.ATTRIBUTE14
	       ,l_new_mmtt_rec.ATTRIBUTE15
	       ,l_new_mmtt_rec.MOVEMENT_ID
	       ,l_new_mmtt_rec.RESERVATION_QUANTITY
	       ,l_new_mmtt_rec.SHIPPED_QUANTITY
	       ,l_new_mmtt_rec.TRANSACTION_LINE_NUMBER
	       ,l_new_mmtt_rec.TASK_ID
	       ,l_new_mmtt_rec.TO_TASK_ID
	       ,l_new_mmtt_rec.SOURCE_TASK_ID
	       ,l_new_mmtt_rec.PROJECT_ID
	       ,l_new_mmtt_rec.SOURCE_PROJECT_ID
	       ,l_new_mmtt_rec.PA_EXPENDITURE_ORG_ID
	       ,l_new_mmtt_rec.TO_PROJECT_ID
	       ,l_new_mmtt_rec.EXPENDITURE_TYPE
	       ,l_new_mmtt_rec.FINAL_COMPLETION_FLAG
	       ,l_new_mmtt_rec.TRANSFER_PERCENTAGE
	       ,l_new_mmtt_rec.TRANSACTION_SEQUENCE_ID
	       ,l_new_mmtt_rec.MATERIAL_ACCOUNT
	       ,l_new_mmtt_rec.MATERIAL_OVERHEAD_ACCOUNT
	       ,l_new_mmtt_rec.RESOURCE_ACCOUNT
	       ,l_new_mmtt_rec.OUTSIDE_PROCESSING_ACCOUNT
	       ,l_new_mmtt_rec.OVERHEAD_ACCOUNT
	       ,l_new_mmtt_rec.FLOW_SCHEDULE
	       ,l_new_mmtt_rec.COST_GROUP_ID
	       ,l_new_mmtt_rec.DEMAND_CLASS
	       ,l_new_mmtt_rec.QA_COLLECTION_ID
	       ,l_new_mmtt_rec.KANBAN_CARD_ID
	       ,l_new_mmtt_rec.OVERCOMPLETION_TRANSACTION_QTY
	       ,l_new_mmtt_rec.OVERCOMPLETION_PRIMARY_QTY
	       ,l_new_mmtt_rec.OVERCOMPLETION_TRANSACTION_ID
	       ,l_new_mmtt_rec.END_ITEM_UNIT_NUMBER
	       ,l_new_mmtt_rec.SCHEDULED_PAYBACK_DATE
	       ,l_new_mmtt_rec.LINE_TYPE_CODE
	       ,l_new_mmtt_rec.PARENT_TRANSACTION_TEMP_ID
	       ,l_new_mmtt_rec.PUT_AWAY_STRATEGY_ID
	       ,l_new_mmtt_rec.PUT_AWAY_RULE_ID
	       ,l_new_mmtt_rec.PICK_STRATEGY_ID
	       ,l_new_mmtt_rec.PICK_RULE_ID
	       ,l_new_mmtt_rec.MOVE_ORDER_LINE_ID
	       ,l_new_mmtt_rec.TASK_GROUP_ID
	       ,l_new_mmtt_rec.PICK_SLIP_NUMBER
	       ,l_new_mmtt_rec.RESERVATION_ID
	       ,l_new_mmtt_rec.COMMON_BOM_SEQ_ID
	       ,l_new_mmtt_rec.COMMON_ROUTING_SEQ_ID
	       ,l_new_mmtt_rec.ORG_COST_GROUP_ID
	       ,l_new_mmtt_rec.COST_TYPE_ID
	       ,l_new_mmtt_rec.TRANSACTION_STATUS
	       ,l_new_mmtt_rec.STANDARD_OPERATION_ID
	       ,l_new_mmtt_rec.TASK_PRIORITY
	       ,l_new_mmtt_rec.WMS_TASK_TYPE
	       ,l_new_mmtt_rec.PARENT_LINE_ID
	       ,l_new_mmtt_rec.TRANSFER_COST_GROUP_ID
	       ,l_new_mmtt_rec.LPN_ID
	       ,l_new_mmtt_rec.TRANSFER_LPN_ID
	       ,l_new_mmtt_rec.WMS_TASK_STATUS
	       ,l_new_mmtt_rec.CONTENT_LPN_ID
	       ,l_new_mmtt_rec.CONTAINER_ITEM_ID
	       ,l_new_mmtt_rec.CARTONIZATION_ID
	       ,l_new_mmtt_rec.PICK_SLIP_DATE
	       ,l_new_mmtt_rec.REBUILD_ITEM_ID
	       ,l_new_mmtt_rec.REBUILD_SERIAL_NUMBER
	       ,l_new_mmtt_rec.REBUILD_ACTIVITY_ID
	       ,l_new_mmtt_rec.REBUILD_JOB_NAME
	       ,l_new_mmtt_rec.ORGANIZATION_TYPE
	       ,l_new_mmtt_rec.TRANSFER_ORGANIZATION_TYPE
	       ,l_new_mmtt_rec.OWNING_ORGANIZATION_ID
	       ,l_new_mmtt_rec.OWNING_TP_TYPE
	       ,l_new_mmtt_rec.XFR_OWNING_ORGANIZATION_ID
	       ,l_new_mmtt_rec.TRANSFER_OWNING_TP_TYPE
	       ,l_new_mmtt_rec.PLANNING_ORGANIZATION_ID
	       ,l_new_mmtt_rec.PLANNING_TP_TYPE
	       ,l_new_mmtt_rec.XFR_PLANNING_ORGANIZATION_ID
	       ,l_new_mmtt_rec.TRANSFER_PLANNING_TP_TYPE
	       ,l_new_mmtt_rec.SECONDARY_UOM_CODE
	       ,l_new_mmtt_rec.SECONDARY_TRANSACTION_QUANTITY
	       ,l_new_mmtt_rec.ALLOCATED_LPN_ID
	       ,l_new_mmtt_rec.SCHEDULE_NUMBER
	       ,l_new_mmtt_rec.SCHEDULED_FLAG
	       ,l_new_mmtt_rec.CLASS_CODE
	       ,l_new_mmtt_rec.SCHEDULE_GROUP
	       ,l_new_mmtt_rec.BUILD_SEQUENCE
	       ,l_new_mmtt_rec.BOM_REVISION
	       ,l_new_mmtt_rec.ROUTING_REVISION
	       ,l_new_mmtt_rec.BOM_REVISION_DATE
	       ,l_new_mmtt_rec.ROUTING_REVISION_DATE
	       ,l_new_mmtt_rec.ALTERNATE_BOM_DESIGNATOR
	       ,l_new_mmtt_rec.ALTERNATE_ROUTING_DESIGNATOR
	       ,l_new_mmtt_rec.TRANSACTION_BATCH_ID
	       ,l_new_mmtt_rec.TRANSACTION_BATCH_SEQ
	       ,l_new_mmtt_rec.operation_plan_id
	       ,l_new_mmtt_rec.move_order_header_id
	       ,l_new_mmtt_rec.serial_allocated_flag)
	       returning transaction_temp_id INTO l_new_mmtt_id;
	  EXCEPTION
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   print_debug('SPLIT_MMTT: Error inserting mmtt', 4);
		END IF;
		RAISE fnd_api.g_exc_error;
	  END;

	  l_progress := '100';

	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MMTT: MMTT successfully inserted: ' || l_new_mmtt_id,4);
	  END IF;

	  /* Update original mmtt */
	  l_orig_mmtt_rec.primary_quantity := l_orig_mmtt_rec.primary_quantity - l_prim_qty_to_splt;
	  l_orig_mmtt_rec.transaction_quantity := l_orig_mmtt_rec.transaction_quantity - l_temp;
     l_orig_mmtt_rec.secondary_transaction_quantity := l_orig_mmtt_rec.secondary_transaction_quantity - l_sec_qty_to_splt;

   	  BEGIN
	     UPDATE
	       mtl_material_transactions_temp
	       SET
	       primary_quantity = l_orig_mmtt_rec.primary_quantity
	       ,transaction_quantity = l_orig_mmtt_rec.transaction_quantity
          , secondary_transaction_quantity = decode (l_orig_mmtt_rec.secondary_uom_code, NULL, NULL, l_orig_mmtt_rec.secondary_transaction_quantity)
	       WHERE
	       transaction_temp_id = l_orig_mmtt_rec.transaction_temp_id;
	  EXCEPTION
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   print_debug('SPLIT_MMTT: Error updating original MMTT', 4);
		END IF;
		RAISE fnd_api.g_exc_error;
	  END;

	  l_progress := '110';
	  -- Update putaway_temp_table if necessary
	  IF (p_updt_putaway_temp_tbl = fnd_api.g_true) THEN
    	     BEGIN
		UPDATE
		  wms_putaway_group_tasks_gtmp
		  SET
		  primary_quantity = l_orig_mmtt_rec.primary_quantity
		  ,transaction_quantity = Decode(primary_quantity,
						 transaction_quantity,
						 l_orig_mmtt_rec.transaction_quantity,
						 inv_rcv_cache.convert_qty
						    (x_orig_mol_rec.inventory_item_id
						     ,l_orig_mmtt_rec.primary_quantity
						     ,p_prim_uom_code
						     ,l_orig_mmtt_rec.transaction_uom
						     ,NULL
						     ))
        ,secondary_quantity = decode (l_orig_mmtt_rec.secondary_uom_code, NULL, NULL, l_orig_mmtt_rec.secondary_transaction_quantity)
		  WHERE
		  row_type = 'All Task'
		  AND move_order_line_id = x_orig_mol_rec.line_id
		  AND transaction_temp_id = l_orig_mmtt_rec.transaction_temp_id;
	     EXCEPTION
		WHEN OTHERS THEN
		   IF (l_debug = 1) THEN
		      print_debug('SPLIT_MMTT: Error updating putaway temp table',
				  4);
		   END IF;
		   RAISE fnd_api.g_exc_error;
	     END;
	  END IF;

	  l_progress := '120';
	  -- Split parent MMTT, operation instance, operation plan
	  l_mmtts_to_split(1) := l_new_mmtt_id;
	  wms_atf_runtime_pub_apis.split_operation_instance
	    (p_source_task_id => l_orig_mmtt_rec.transaction_temp_id,
	     p_new_task_id_table => l_mmtts_to_split,
	     p_activity_type_id  => 1, -- INBOUND
	     x_return_status => x_return_status,
	     x_msg_count => x_msg_count,
	     x_error_code => l_error_code,
	     x_msg_data => x_msg_data);
	  IF (x_return_status <> g_ret_sts_success) THEN
	     IF (l_debug = 1) THEN
		print_debug('SPLIT_MMTT: Error in split_operation_instance',4);
	     END IF;
	     fnd_message.set_name('WMS','WMS_TASK_SPLIT_FAIL');
	     fnd_msg_pub.add;
	     RAISE fnd_api.g_exc_error;
	  END IF;
	  l_progress := '130';

	  /* Retrieve lot/serial control code call break to split */
	  /* MTLT/MSLT */
	  BEGIN
	     l_lot_control_code := inv_rcv_cache.get_lot_control_code(x_orig_mol_rec.organization_id,
								    x_orig_mol_rec.inventory_item_id);
	     l_serial_control_code := 1;
	  EXCEPTION
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   print_debug('No entry exists for inventory_item_id:'
			       || x_orig_mol_rec.inventory_item_id ||
			       ' organization:' ||
			       x_orig_mol_rec.organization_id, 4);
		END IF;
		RAISE fnd_api.g_exc_error;
	  END;
	  l_progress := '140';

	  l_new_txn_tb(1).transaction_id := l_new_mmtt_id;
	  l_new_txn_tb(1).primary_quantity := l_new_mmtt_rec.primary_quantity;

	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MMTT - Progress:'||l_progress||' Calling break to break lot serial',4);
	     print_debug('   p_lot_control_code => ' ||
			 l_lot_control_code,4);
	     print_debug('   p_serial_control_code => '||
			 l_serial_control_code,4);
	  END IF;

	  BEGIN
	     inv_rcv_common_apis.break
	       ( p_original_tid => l_orig_mmtt_rec.transaction_temp_id
		 ,p_new_transactions_tb => l_new_txn_tb
		 ,p_lot_control_code => l_lot_control_code
		 ,p_serial_control_code => l_serial_control_code);
	  EXCEPTION
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   print_debug('SPLIT_MMTT: Error breaking lot serial', 4);
		END IF;
		RAISE fnd_api.g_exc_error;
	  END;

	  l_progress := '150';

	  IF (p_remaining_mmtt_splt = 'N') THEN
	     -- only update qty in the first loop
	     -- Update new MOL with the increased quantity
	     x_new_mol_rec.primary_quantity := x_new_mol_rec.primary_quantity + l_prim_qty_to_splt;
	     x_new_mol_rec.quantity := x_new_mol_rec.quantity + l_qty_to_splt;
        x_new_mol_rec.secondary_quantity := x_new_mol_rec.secondary_quantity + l_sec_qty_to_splt;

	     -- Update old MOL with the reduced quantity
	     x_orig_mol_rec.primary_quantity := x_orig_mol_rec.primary_quantity - l_prim_qty_to_splt;
	     x_orig_mol_rec.quantity := x_orig_mol_rec.quantity - l_qty_to_splt;
        x_orig_mol_rec.secondary_quantity := x_orig_mol_rec.secondary_quantity - l_sec_qty_to_splt;
	  END IF; -- IF (p_remaining_mmtt_splt = 'N') THEN
	  x_orig_mol_rec.quantity_detailed := x_orig_mol_rec.quantity_detailed - l_qty_to_splt;
     x_orig_mol_rec.secondary_quantity_detailed := x_orig_mol_rec.secondary_quantity_detailed - l_sec_qty_to_splt;

	  x_new_mol_rec.quantity_detailed := x_new_mol_rec.quantity_detailed + l_qty_to_splt;
     x_new_mol_rec.secondary_quantity_detailed := x_new_mol_rec.secondary_quantity_detailed + l_sec_qty_to_splt;

	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MMTT: MMTT Split completed sucessfully', 4);
	  END IF;
	  l_progress := '160';

	  EXIT;
	ELSIF (l_orig_mmtt_rec.primary_quantity = l_prim_qty_to_splt) THEN
	  /* If the MMTT has the exact amount to be split, then simply update the original mmtt mol pointer */

	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MMTT: splitting MMTT:'||
			 l_orig_mmtt_rec.transaction_temp_id||
			 ' with QTY:' ||
			 l_orig_mmtt_rec.primary_quantity||
			 ' into QTY:' || l_prim_qty_to_splt ||
			 ' with SEC QTY:' ||
			 l_orig_mmtt_rec.secondary_transaction_quantity||
			 ' into SEC QTY:' || l_sec_qty_to_splt ||
			 '... Exact amount',4);
	  END IF;

	  l_progress := '170';
	  BEGIN
	     UPDATE  mtl_material_transactions_temp
	       SET     move_order_line_id = x_new_mol_rec.line_id
	       WHERE   transaction_temp_id = l_orig_mmtt_rec.transaction_temp_id;
	  EXCEPTION
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   print_debug('SPLIT_MMTT: Error updating mmtt with id '
			       || l_orig_mmtt_rec.transaction_temp_id, 4);
		END IF;
		RAISE fnd_api.g_exc_error;
	  END;
	  l_progress := '180';

	  -- Update MOL of putaway_temp_table if necessary
	  IF (p_updt_putaway_temp_tbl = fnd_api.g_true) THEN
  	     BEGIN
		UPDATE
		  wms_putaway_group_tasks_gtmp
		  SET move_order_line_id = x_new_mol_rec.line_id
		  WHERE transaction_temp_id = l_orig_mmtt_rec.transaction_temp_id
		  AND move_order_line_id = x_orig_mol_rec.line_id
		  AND row_type = 'All Task';
	     EXCEPTION
		WHEN OTHERS THEN
		   IF (l_debug = 1) THEN
		      print_debug('Error updating[[[ putaway temp table',
				  4);
		   END IF;
		   RAISE fnd_api.g_exc_error;
	     END;
	  END IF;
	  l_progress := '190';

	  IF (p_remaining_mmtt_splt = 'N') THEN
	     -- Don't update qty in second loop, since it is updated during
	     -- the first one
	     -- Update new MOL with the increased quantity
	     x_new_mol_rec.primary_quantity := x_new_mol_rec.primary_quantity + l_prim_qty_to_splt;
	     x_new_mol_rec.quantity := x_new_mol_rec.quantity + l_qty_to_splt;
        x_new_mol_rec.secondary_quantity := x_new_mol_rec.secondary_quantity + l_sec_qty_to_splt;

	     -- Update original MOL with the reduced quantity
	     x_orig_mol_rec.primary_quantity := x_orig_mol_rec.primary_quantity - l_prim_qty_to_splt;
	     x_orig_mol_rec.quantity := x_orig_mol_rec.quantity - l_qty_to_splt;
        x_orig_mol_rec.secondary_quantity := x_orig_mol_rec.secondary_quantity - l_sec_qty_to_splt;
	  END IF;
	  x_orig_mol_rec.quantity_detailed :=  x_orig_mol_rec.quantity_detailed - l_qty_to_splt;
     x_orig_mol_rec.secondary_quantity_detailed :=  x_orig_mol_rec.secondary_quantity_detailed - l_sec_qty_to_splt;

	  x_new_mol_rec.quantity_detailed := x_new_mol_rec.quantity_detailed + l_qty_to_splt;
     x_new_mol_rec.secondary_quantity_detailed := x_new_mol_rec.secondary_quantity_detailed + l_sec_qty_to_splt;


	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MMTT - Progress:'|| l_progress ||
			 ' Successfully update MMTT to new MOL', 4);
	  END IF;
	  l_progress := '200';

	  EXIT;

	ELSE -- l_orig_mmtt_rec.primary_quantity < l_prim_qty_to_splt
	     --If the MMTT does not have enough to be split, then associate the MMTT with the new MOL, *
	     --then reduce split quantity so it will continue in the next iteration

	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MMTT: Splitting MMTT:'||
			 l_orig_mmtt_rec.transaction_temp_id||
			 ' with QTY:' ||
			 l_orig_mmtt_rec.primary_quantity||
			 ' into QTY:' || l_prim_qty_to_splt ||
			 ' with QTY:' ||
			 l_orig_mmtt_rec.secondary_transaction_quantity||
			 ' into QTY:' || l_sec_qty_to_splt ||
			 '... Not enough',4);
	  END IF;

	  l_progress := '210';
	  -- Make sure that these values are not less than zero
	  IF (x_orig_mol_rec.quantity_delivered < 0) THEN
	     x_orig_mol_rec.quantity_delivered := 0;
	  END IF;

	  IF (x_orig_mol_rec.quantity_detailed < 0) THEN
	     x_orig_mol_rec.quantity_detailed := 0;
	  END IF;

	  IF (x_orig_mol_rec.secondary_quantity_delivered < 0) THEN
	     x_orig_mol_rec.secondary_quantity_delivered := 0;
	  END IF;

	  IF (x_orig_mol_rec.secondary_quantity_detailed < 0) THEN
	     x_orig_mol_rec.secondary_quantity_detailed := 0;
	  END IF;

	  l_progress := '220';

 	  BEGIN
	     UPDATE mtl_material_transactions_temp
	       SET    move_order_line_id = x_new_mol_rec.line_id
	       WHERE  transaction_temp_id =
	       l_orig_mmtt_rec.transaction_temp_id;
	  EXCEPTION
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   print_debug('SPLIT_MMTT: Error updating MMTT with id:'
			       || l_orig_mmtt_rec.transaction_temp_id, 4);
		END IF;
		RAISE fnd_api.g_exc_error;
	  END;

	  l_progress := '230';

	  -- Delete from putawau_temp_table if necessary
	  IF (p_updt_putaway_temp_tbl = fnd_api.g_true) THEN
  	     BEGIN
		UPDATE
		  wms_putaway_group_tasks_gtmp
		  SET
		  move_order_line_id = x_new_mol_rec.line_id
		  WHERE transaction_temp_id = l_orig_mmtt_rec.transaction_temp_id
		  AND move_order_line_id = x_orig_mol_rec.line_id
		  AND row_type = 'All Task';
	     EXCEPTION
		WHEN OTHERS THEN
		   IF (l_debug = 1) THEN
		      print_debug('Error updating putaway temp table',
				  4);
		   END IF;
		   RAISE fnd_api.g_exc_error;
	     END;
	  END IF;
	  l_progress := '240';

	  IF (l_orig_mmtt_rec.transaction_uom <> x_orig_mol_rec.uom_code) THEN
	     l_temp := inv_rcv_cache.convert_qty
	                  (p_inventory_item_id   => x_orig_mol_rec.inventory_item_id
			   ,p_from_qty           => l_orig_mmtt_rec.transaction_quantity
			   ,p_from_uom_code      => l_orig_mmtt_rec.transaction_uom
			   ,p_to_uom_code        => x_orig_mol_rec.uom_code
			   );
	   ELSE
	     l_temp := l_orig_mmtt_rec.transaction_quantity;
	  END IF;

	  l_progress := '250';

	  IF (p_remaining_mmtt_splt = 'N') THEN
	     -- don't update qty, since it is updated in first loop
	     -- Update new MOL with the increased quantity
	     x_new_mol_rec.primary_quantity := x_new_mol_rec.primary_quantity + l_orig_mmtt_rec.primary_quantity;
	     x_new_mol_rec.quantity := x_new_mol_rec.quantity + l_temp;
        x_new_mol_rec.secondary_quantity := x_new_mol_rec.secondary_quantity + l_orig_mmtt_rec.secondary_transaction_quantity;

	     -- Update original MOL with the reduced quantity
	     x_orig_mol_rec.primary_quantity := x_orig_mol_rec.primary_quantity - l_orig_mmtt_rec.primary_quantity;
	     x_orig_mol_rec.quantity := x_orig_mol_rec.quantity - l_temp;
        x_orig_mol_rec.secondary_quantity := x_orig_mol_rec.secondary_quantity - l_orig_mmtt_rec.secondary_transaction_quantity;
	  END IF;

	  x_new_mol_rec.quantity_detailed := x_new_mol_rec.quantity_detailed + l_temp;
     x_new_mol_rec.secondary_quantity_detailed := x_new_mol_rec.secondary_quantity_detailed + l_orig_mmtt_rec.secondary_transaction_quantity;

	  x_orig_mol_rec.quantity_detailed := x_orig_mol_rec.quantity_detailed - l_temp;
	  x_orig_mol_rec.secondary_quantity_detailed := x_orig_mol_rec.secondary_quantity_detailed - l_orig_mmtt_rec.secondary_transaction_quantity;

	  -- Update p_mo_splt_tb and l_qty_to_splt so that
	  -- the new qty will be looked at in the next iteration
	  l_prim_qty_to_splt := l_prim_qty_to_splt-l_orig_mmtt_rec.primary_quantity;
	  l_qty_to_splt := l_qty_to_splt - l_temp;
     l_sec_qty_to_splt := l_sec_qty_to_splt-l_orig_mmtt_rec.secondary_transaction_quantity;

	  l_progress := '260';
	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MMTT: Need to look at next MMTT', 4);
	     print_debug('SPLIT_MMTT - MOL:'||x_orig_mol_rec.line_id ||
			 ' QTY:'||x_orig_mol_rec.quantity||
			 ' PRIM_QTY:'||x_orig_mol_rec.quantity ||
			 ' QTY_DTD:'||x_orig_mol_rec.quantity_detailed||
			 ' QTY_DLVD:'||x_orig_mol_rec.quantity_delivered||
			 ' SEC QTY:'||x_orig_mol_rec.secondary_quantity||
          ' SEC QTY_DTD:'||x_orig_mol_rec.secondary_quantity_detailed||
			 ' SEC QTY_DLVD:'||x_orig_mol_rec.secondary_quantity_delivered,4
			 );
	     print_debug('SPLIT_MMTT - MOL:'||x_new_mol_rec.line_id ||
			 ' QTY:'||x_new_mol_rec.quantity||
			 ' PRIM_QTY:'||x_new_mol_rec.quantity ||
			 ' QTY_DTD:'||x_new_mol_rec.quantity_detailed||
			 ' QTY_DLVD:'||x_orig_mol_rec.quantity_delivered||
			 ' SEC QTY:'||x_new_mol_rec.secondary_quantity ||
			 ' SEC QTY_DTD:'||x_new_mol_rec.secondary_quantity_detailed||
			 ' SEC QTY_DLVD:'||x_orig_mol_rec.secondary_quantity_delivered,4
			 );
	  END IF;
       END IF;  --IF (l_orig_mmtt_rec.primary_quantity > l_prim_qty_to_splt)
	ELSE
	  IF (l_debug = 1) THEN
	     print_debug('Skipping this MMTT:'||l_orig_mmtt_rec.transaction_temp_id,4);
	  END IF;
       END IF; --IF (l_skip_iteration <> 'Y') THEN

    END LOOP;

    IF (mmtt_cur%isopen) THEN
       CLOSE mmtt_cur;
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
       IF (l_debug = 1) THEN
	  print_debug('SPLIT_MMTT: Exception occurred after progress = ' ||
		      l_progress || ' SQLCODE = ' || SQLCODE,4);
       END IF;
       IF (mmtt_cur%isopen) THEN
	  CLOSE mmtt_cur;
       END IF;
       x_return_status := g_ret_sts_unexp_err;
       fnd_msg_pub.count_and_get
	 (  p_count  => x_msg_count
	    ,p_data  => x_msg_data );
 END split_mmtt;


 PROCEDURE split_mo
   (p_orig_mol_id    IN NUMBER,
    p_mo_splt_tb     IN OUT nocopy mo_in_tb_tp,
    p_updt_putaway_temp_tbl IN VARCHAR2 DEFAULT fnd_api.g_false,
    p_txn_header_id  IN NUMBER DEFAULT NULL,
    p_operation_type IN VARCHAR2 DEFAULT NULL,
    x_return_status  OUT   NOCOPY VARCHAR2,
    x_msg_count      OUT   NOCOPY NUMBER,
    x_msg_data       OUT   NOCOPY VARCHAR2
    )
   IS

      l_orig_mol_rec mol_rec;
      l_new_mol_rec mol_rec;
      l_total_to_split NUMBER;
      l_line_num NUMBER;
      l_prim_uom_code VARCHAR2(3);
      -- OPMCOnvergence
      l_sec_uom_code VARCHAR2(3);
      l_qty_to_splt number_tb_type;
      -- OPMCovergence
      l_sec_qty_to_splt number_tb_type;
      l_remaining_prim_qty NUMBER;
      l_remaining_qty NUMBER;
      -- OPMCovergence
      l_remaining_sec_qty NUMBER;
      l_debug NUMBER := Nvl(fnd_profile.value('INV_DEBUG_TRACE'), 0);
      l_progress VARCHAR2(10) := '00';

      l_SECONDARY_QUANTITY  NUMBER; --OPM Convergence
      l_SECONDARY_QUANTITY_DELIVERED NUMBER; --OPM Convergence
      l_SECONDARY_QUANTITY_DETAILED  number;--OPM Convergence
      l_SECONDARY_REQUIRED_QUANTITY number;--OPM Convergence

      l_new_wdd_id NUMBER; --R12: XDOCK EXE
      l_new_reservation_id NUMBER;--R12: XDOCK EXE
      l_doc_type NUMBER;
      l_rsv_query_rec     inv_reservation_global.mtl_reservation_rec_type; --R12: XDOCK EXE
      l_rsv_results_tbl   inv_reservation_global.mtl_reservation_tbl_type;
      l_rsv_update_rec    inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_results_count NUMBER;
      l_dummy_serial      inv_reservation_global.serial_number_tbl_type;
      l_error_code        NUMBER;

 BEGIN
    SAVEPOINT split_mo_pub;

    x_return_status := g_ret_sts_success;

    l_progress := '10';

    IF (l_debug = 1) THEN
       print_debug('SPLIT_MO - Entering ...',4);
    END IF;

    /* Retrieve MOL with the given line_id */
    BEGIN
    SELECT
	 line_id
	 ,header_id
	 ,quantity
	 ,primary_quantity
	 ,Nvl(quantity_delivered,0)
	 ,Nvl(quantity_detailed,0)
	 ,uom_code
	 ,inventory_item_id
	 ,organization_id
      , SECONDARY_UOM_CODE         --OPM Convergence
      , NVL(SECONDARY_QUANTITY,0)   --OPM Convergence
      , NVL(SECONDARY_QUANTITY_DELIVERED,0) --OPM Convergence
      , NVL(SECONDARY_QUANTITY_DETAILED,0)  --OPM Convergence
      , NVL(SECONDARY_REQUIRED_QUANTITY,0) --OPM Convergence
      , backorder_delivery_detail_id --R12: XDOCK EXE
      , crossdock_type --R12: XDOCK EXE
      INTO
	 l_orig_mol_rec.line_id
	 ,l_orig_mol_rec.header_id
	 ,l_orig_mol_rec.quantity
	 ,l_orig_mol_rec.primary_quantity
	 ,l_orig_mol_rec.quantity_delivered
	 ,l_orig_mol_rec.quantity_detailed
	 ,l_orig_mol_rec.uom_code
	 ,l_orig_mol_rec.inventory_item_id
	 ,l_orig_mol_rec.organization_id
      ,l_orig_mol_rec.SECONDARY_UOM    --OPM Convergence
      ,l_orig_mol_rec.SECONDARY_QUANTITY   --OPM Convergence
      ,l_orig_mol_rec.SECONDARY_QUANTITY_DELIVERED --OPM Convergence
      ,l_orig_mol_rec.SECONDARY_QUANTITY_DETAILED  --OPM Convergence
      ,l_orig_mol_rec.SECONDARY_REQUIRED_QUANTITY --OPM Convergence
      ,l_orig_mol_rec.backorder_delivery_detail_id
      ,l_orig_mol_rec.crossdock_type
    FROM
      mtl_txn_request_lines
    WHERE
      line_id = p_orig_mol_id;

      EXCEPTION
       WHEN OTHERS THEN
	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MO: Unable to find original MOL!',4);
	     print_debug('SPLIT_MO: SQLCODE = ' || SQLCODE, 4);
	  END IF;
    END;

    -- Original MOL shouldn't have quantity <= 0
    IF (l_orig_mol_rec.primary_quantity <= 0) THEN
       IF (l_debug = 1) THEN
	 print_debug('SPLIT_MO ERROR: Original quantity is <= 0', 4);
       END IF;
       fnd_message.set_name('INV', 'INV_INVALID_QTY');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    l_progress := '20';

    -- Needs the primary_uom_code for quantities conversion
    l_prim_uom_code := inv_rcv_cache.get_primary_uom_code(l_orig_mol_rec.organization_id,
							  l_orig_mol_rec.inventory_item_id);

    l_sec_uom_code := l_orig_mol_rec.secondary_uom;

    l_progress := '25';

    -- Validate that there are enough to be split
    -- l_total_to_split will be in l_orig_mol_rec.uom_code
    l_total_to_split := 0;

    FOR l_indx IN 1 .. p_mo_splt_tb.COUNT LOOP
       -- Make sure that p_mo_splt_tb contains valid entries
       IF (p_mo_splt_tb(l_indx).prim_qty <= 0) THEN
	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MO - ERROR: Quantity to split is <= 0', 4);
	  END IF;
	  fnd_message.set_name('INV', 'INV_INVALID_QTY');
	  fnd_msg_pub.ADD;
	  RAISE fnd_api.g_exc_error;
     END IF;

       -- convert prim quantities to transaction uom in mol first
       IF (l_orig_mol_rec.uom_code = l_prim_uom_code) THEN
	  l_qty_to_splt(l_indx) := p_mo_splt_tb(l_indx).prim_qty;
	ELSE

	  l_qty_to_splt(l_indx) := inv_rcv_cache.convert_qty
	                              (p_inventory_item_id   => l_orig_mol_rec.inventory_item_id
				       ,p_from_qty           => p_mo_splt_tb(l_indx).prim_qty
				       ,p_from_uom_code      => l_prim_uom_code
				       ,p_to_uom_code        => l_orig_mol_rec.uom_code
				       );
       END IF;
    l_sec_qty_to_splt(l_indx) := p_mo_splt_tb(l_indx).sec_qty;
       l_total_to_split := l_total_to_split + l_qty_to_splt(l_indx);
   END LOOP;

    l_progress := '30';

    IF (l_debug = 1) THEN
      print_debug('SPLIT_MO: Original MOL state:', 4);
      print_debug('SPLIT_MO: MOL:'||l_orig_mol_rec.line_id ||
		  ' QTY:'||l_orig_mol_rec.quantity||
		  ' PRIM_QTY:'||l_orig_mol_rec.quantity ||
		  ' QTY_DTD:'||l_orig_mol_rec.quantity_detailed||
		  ' QTY_DLVD:'||l_orig_mol_rec.quantity_delivered,4
		  );
      print_debug('SPLIT_MO: MOL:'||l_orig_mol_rec.line_id ||
		  ' SEC_QTY:'||l_orig_mol_rec.secondary_quantity||
        ' SEC_QTY_DTD:'||l_orig_mol_rec.secondary_quantity_detailed||
		  ' SEC_QTY_DLVD:'||l_orig_mol_rec.secondary_quantity_delivered,4
		  );
    END IF;


    IF((l_orig_mol_rec.quantity-l_orig_mol_rec.quantity_delivered) < l_total_to_split) THEN
       /* not enough to be split */
       IF (l_debug = 1) THEN
	  print_debug('SPLIT_MO - ERROR: Original QTY only '||l_orig_mol_rec.quantity
		     || ', not enough to split ' || l_total_to_split, 4);
       END IF;
       fnd_message.set_name('INV', 'INV_INSUFFICIENT_QTY');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    l_progress := '40';

    -- Get max line num, which is used to create unique line_num
    SELECT MAX(line_number)
      INTO l_line_num
      FROM mtl_txn_request_lines
      WHERE header_id = l_orig_mol_rec.header_id;

    l_progress := '50';

    IF (l_debug = 1) THEN
      print_debug('SPLIT_MO: Original MOL state:', 4);
      print_debug('SPLIT_MO: MOL:'||l_orig_mol_rec.line_id ||
		  ' QTY:'||l_orig_mol_rec.quantity||
		  ' PRIM_QTY:'||l_orig_mol_rec.quantity ||
		  ' QTY_DTD:'||l_orig_mol_rec.quantity_detailed||
		  ' QTY_DLVD:'||l_orig_mol_rec.quantity_delivered,4
		  );
      print_debug('SPLIT_MO: MOL:'||l_orig_mol_rec.line_id ||
		  ' SEC_QTY:'||l_orig_mol_rec.secondary_quantity||
        ' SEC_QTY_DTD:'||l_orig_mol_rec.secondary_quantity_detailed||
		  ' SEC_QTY_DLVD:'||l_orig_mol_rec.secondary_quantity_delivered,4
		  );
    END IF;

    l_progress := '53';

    -- Loop through the requested quantity table and split one-by-one
    FOR l_indx IN 1 .. p_mo_splt_tb.COUNT LOOP

       IF (l_indx = p_mo_splt_tb.COUNT AND ( l_qty_to_splt(l_indx) = l_orig_mol_rec.quantity-l_orig_mol_rec.quantity_delivered) )
	 THEN
	  -- If the last entry matched the orig mol quantity
	  -- then simply assoc the last one with the original mol
	  -- No need to create a new MOL
	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MO: Last Qty to split matched exactly the orig mol qty',4);
	  END IF;
	  p_mo_splt_tb(l_indx).line_id := p_orig_mol_id;
	ELSE

	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MO: Creating new MOL for quantity ' ||
			 p_mo_splt_tb(l_indx).prim_qty||' Sec Qty '||NVL(p_mo_splt_tb(l_indx).sec_qty,NULL),4);
	  END IF;

	  /* Create a  MOL record, with most of its fields copied from the */
	  /* original MOL */
	  l_progress := '55';

	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MO - Copy MOL', 4);
	  END IF;

	  --Initializate these fields
	  l_new_mol_rec.header_id := l_orig_mol_rec.header_id;
	  l_new_mol_rec.quantity := 0;
	  l_new_mol_rec.primary_quantity := 0;
	  l_new_mol_rec.quantity_delivered := 0;
	  l_new_mol_rec.quantity_detailed := 0;
	  l_new_mol_rec.uom_code := l_orig_mol_rec.uom_code;
	  l_new_mol_rec.inventory_item_id := l_orig_mol_rec.inventory_item_id;
	  l_new_mol_rec.organization_id := l_orig_mol_rec.organization_id;
	  l_new_mol_rec.line_number := l_line_num + l_indx;
	  l_new_mol_rec.backorder_delivery_detail_id := l_orig_mol_rec.backorder_delivery_detail_id; --Bug 5948720

     --OPM Convergence
     l_new_mol_rec.secondary_quantity := 0;
	  l_new_mol_rec.secondary_quantity_delivered := 0;
	  l_new_mol_rec.secondary_quantity_detailed := 0;


	  BEGIN
	     SELECT MTL_TXN_REQUEST_LINES_S.NEXTVAL
	       INTO l_new_mol_rec.line_id
	       FROM dual;

	     INSERT INTO mtl_txn_request_lines
	       (
		LINE_ID
		,HEADER_ID
		,LINE_NUMBER
		,ORGANIZATION_ID
		,INVENTORY_ITEM_ID
		,REVISION
		,FROM_SUBINVENTORY_ID
		,FROM_SUBINVENTORY_CODE
		,FROM_LOCATOR_ID
		,TO_SUBINVENTORY_CODE
		,TO_SUBINVENTORY_ID
		,TO_LOCATOR_ID
		,TO_ACCOUNT_ID
		,SHIP_TO_LOCATION_ID
		,LOT_NUMBER
		,SERIAL_NUMBER_START
		,SERIAL_NUMBER_END
		,UOM_CODE
		,QUANTITY
		,QUANTITY_DELIVERED
		,QUANTITY_DETAILED
		,DATE_REQUIRED
		,REASON_ID
		,REFERENCE
		,REFERENCE_TYPE_CODE
		,REFERENCE_ID
		,REFERENCE_DETAIL_ID
		,ASSIGNMENT_ID
		,PROJECT_ID
		,TASK_ID
		,TRANSACTION_HEADER_ID
		,LINE_STATUS
		,STATUS_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,LAST_UPDATE_DATE
		,CREATED_BY
		,CREATION_DATE
		,REQUEST_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_ID
		,PROGRAM_UPDATE_DATE
		,ATTRIBUTE1
		,ATTRIBUTE2
		,ATTRIBUTE3
		,ATTRIBUTE4
		,ATTRIBUTE5
		,ATTRIBUTE6
		,ATTRIBUTE7
		,ATTRIBUTE8
		,ATTRIBUTE9
		,ATTRIBUTE10
		,ATTRIBUTE11
		,ATTRIBUTE12
		,ATTRIBUTE13
		,ATTRIBUTE14
		,ATTRIBUTE15
		,ATTRIBUTE_CATEGORY
		,TXN_SOURCE_ID
	       ,TXN_SOURCE_LINE_ID
	       ,TXN_SOURCE_LINE_DETAIL_ID
	       ,TRANSACTION_TYPE_ID
	       ,TRANSACTION_SOURCE_TYPE_ID
	       ,PRIMARY_QUANTITY
	       ,TO_ORGANIZATION_ID
	       ,PUT_AWAY_STRATEGY_ID
	       ,PICK_STRATEGY_ID
	       ,UNIT_NUMBER
	       ,FROM_COST_GROUP_ID
	       ,TO_COST_GROUP_ID
	       ,LPN_ID
	       ,TO_LPN_ID
	       ,INSPECTION_STATUS
	       ,PICK_METHODOLOGY_ID
	       ,CONTAINER_ITEM_ID
	       ,CARTON_GROUPING_ID
	       ,BACKORDER_DELIVERY_DETAIL_ID
	       ,WMS_PROCESS_FLAG
	       ,PICK_SLIP_NUMBER
	       ,PICK_SLIP_DATE
	       ,SHIP_SET_ID
	       ,SHIP_MODEL_ID
	       ,MODEL_QUANTITY
	       ,CROSSDOCK_TYPE
	       ,REQUIRED_QUANTITY
          ,SECONDARY_QUANTITY --OPM Convergence
          ,SECONDARY_QUANTITY_DELIVERED --OPM Convergence
		    ,SECONDARY_QUANTITY_DETAILED --OPM Convergence
               ,WIP_ENTITY_ID --Bug 5934992
	       ,OPERATION_SEQ_NUM --Bug 5948720
	       ,WIP_SUPPLY_TYPE --Bug 5948720
	       )
	       SELECT
	        l_new_mol_rec.line_id --LINE_ID
		,HEADER_ID
		,l_new_mol_rec.line_number --LINE_NUMBER
		,ORGANIZATION_ID
		,INVENTORY_ITEM_ID
		,REVISION
		,FROM_SUBINVENTORY_ID
		,FROM_SUBINVENTORY_CODE
		,FROM_LOCATOR_ID
		,TO_SUBINVENTORY_CODE
		,TO_SUBINVENTORY_ID
		,TO_LOCATOR_ID
		,TO_ACCOUNT_ID
		,SHIP_TO_LOCATION_ID
		,LOT_NUMBER
		,SERIAL_NUMBER_START
		,SERIAL_NUMBER_END
		,UOM_CODE
		,0 --QUANTITY
		,0 --QUANTITY_DELIVERED
		,0 --QUANTITY_DETAILED
		,DATE_REQUIRED
		,REASON_ID
		,REFERENCE
		,REFERENCE_TYPE_CODE
		,REFERENCE_ID
		,REFERENCE_DETAIL_ID
		,ASSIGNMENT_ID
		,PROJECT_ID
		,TASK_ID
		,TRANSACTION_HEADER_ID
		,LINE_STATUS
		,STATUS_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,Sysdate --LAST_UPDATE_DATE
		,CREATED_BY
		,Sysdate --CREATION_DATE
		,REQUEST_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_ID
		,PROGRAM_UPDATE_DATE
		,ATTRIBUTE1
		,ATTRIBUTE2
		,ATTRIBUTE3
		,ATTRIBUTE4
		,ATTRIBUTE5
		,ATTRIBUTE6
		,ATTRIBUTE7
		,ATTRIBUTE8
		,ATTRIBUTE9
		,ATTRIBUTE10
		,ATTRIBUTE11
		,ATTRIBUTE12
		,ATTRIBUTE13
		,ATTRIBUTE14
		,ATTRIBUTE15
		,ATTRIBUTE_CATEGORY
		,TXN_SOURCE_ID
	       ,TXN_SOURCE_LINE_ID
	       ,TXN_SOURCE_LINE_DETAIL_ID
	       ,TRANSACTION_TYPE_ID
	       ,TRANSACTION_SOURCE_TYPE_ID
	       ,0 --PRIMARY_QUANTITY
	       ,TO_ORGANIZATION_ID
	       ,PUT_AWAY_STRATEGY_ID
	       ,PICK_STRATEGY_ID
	       ,UNIT_NUMBER
	       ,FROM_COST_GROUP_ID
	       ,TO_COST_GROUP_ID
	       ,LPN_ID
	       ,TO_LPN_ID
	       ,INSPECTION_STATUS
	       ,PICK_METHODOLOGY_ID
	       ,CONTAINER_ITEM_ID
	       ,CARTON_GROUPING_ID
	       ,BACKORDER_DELIVERY_DETAIL_ID
	       ,WMS_PROCESS_FLAG
	       ,PICK_SLIP_NUMBER
	       ,PICK_SLIP_DATE
	       ,SHIP_SET_ID
	       ,SHIP_MODEL_ID
	       ,MODEL_QUANTITY
	       ,CROSSDOCK_TYPE
	       ,REQUIRED_QUANTITY
          ,0--SECONDARY_QUANTITY --OPM Convergence
          ,0--SECONDARY_QUANTITY_DELIVERED --OPM Convergence
		    ,0--SECONDARY_QUANTITY_DETAILED --OPM Convergence
               ,WIP_ENTITY_ID --Bug 5934992
	       ,OPERATION_SEQ_NUM --Bug 5948720
	       ,WIP_SUPPLY_TYPE --Bug 5948720
	       FROM mtl_txn_request_lines
	       WHERE line_id = l_orig_mol_rec.line_id;
	  EXCEPTION
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   print_debug('SPLIT_MO: Error copying move order lines', 4);
		   print_debug('SPLIT_MO: SQLCODE = ' || SQLCODE, 4);
		END IF;
		fnd_message.set_name('WMS','WMS_MO_CREATE_FAIL');
		fnd_msg_pub.add;
		RAISE fnd_api.g_exc_error;
	  END;

	  l_progress := '60';
	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MO - MOL sucessfully created with line_id = '||
			 l_new_mol_rec.line_id || ' , ROWCOUNT = ' ||
			 SQL%ROWCOUNT,4);
	  END IF;

	  l_progress := '62';

	  split_mmtt(x_orig_mol_rec   => l_orig_mol_rec
		     ,x_new_mol_rec   => l_new_mol_rec
		     ,x_return_status => x_return_status
		     ,x_msg_count     => x_msg_count
		     ,x_msg_data      => x_msg_data
		     ,p_prim_qty_to_splt => p_mo_splt_tb(l_indx).prim_qty
		     ,p_qty_to_splt   => l_qty_to_splt(l_indx)
           ,p_prim_uom_code => l_prim_uom_code
            -- OPM COnvergence
		     ,p_sec_qty_to_splt  => l_sec_qty_to_splt(l_indx)
           ,p_sec_uom_code => l_sec_uom_code
		     ,p_updt_putaway_temp_tbl => p_updt_putaway_temp_tbl
		     ,p_txn_header_id => p_txn_header_id
		     ,p_txn_temp_id   => p_txn_header_id
		     ,p_remaining_mmtt_splt => 'N'
		     ,p_operation_type => p_operation_type);
	  IF (x_return_status <> g_ret_sts_success) THEN
	     IF (l_debug = 1) THEN
		print_debug('SPLIT_MO: Error in split_mmtt',4);
	     END IF;
	     RAISE fnd_api.g_exc_error;
	  END IF;

	  l_progress := '64';

	  IF (l_orig_mol_rec.quantity_detailed > l_orig_mol_rec.quantity) THEN
	     IF (p_txn_header_id IS NULL) THEN
		IF (l_debug = 1) THEN
		   print_debug('SPLIT_MO: Not possible',4);
		END IF;
		RAISE fnd_api.g_exc_error;
	      ELSE -- p_txn_header_id is not null
		l_remaining_qty := l_orig_mol_rec.quantity_detailed - l_orig_mol_rec.quantity;
		IF (l_prim_uom_code <> l_orig_mol_rec.uom_code) THEN
		   l_remaining_prim_qty := inv_rcv_cache.convert_qty
		                             (p_inventory_item_id   => l_orig_mol_rec.inventory_item_id
					      ,p_from_qty           => l_remaining_qty
					      ,p_from_uom_code      => l_orig_mol_rec.uom_code
					      ,p_to_uom_code        => l_prim_uom_code
					      );
		 ELSE
		   l_remaining_prim_qty := l_remaining_qty;
		END IF; --IF (l_prim_uom_code <> l_orig_mol_rec.uom_code)
         l_remaining_sec_qty := l_orig_mol_rec.secondary_quantity_detailed - l_orig_mol_rec.secondary_quantity;

		split_mmtt(x_orig_mol_rec   => l_orig_mol_rec
			   ,x_new_mol_rec   => l_new_mol_rec
			   ,x_return_status => x_return_status
			   ,x_msg_count     => x_msg_count
			   ,x_msg_data      => x_msg_data
			   ,p_prim_qty_to_splt => l_remaining_prim_qty
			   ,p_qty_to_splt   => l_remaining_qty
			   ,p_prim_uom_code => l_prim_uom_code
             -- OPMConvergence
			   ,p_sec_qty_to_splt   => l_remaining_sec_qty
			   ,p_sec_uom_code => l_sec_uom_code
			   ,p_updt_putaway_temp_tbl => p_updt_putaway_temp_tbl
			   ,p_txn_header_id => p_txn_header_id
			   ,p_txn_temp_id   => p_txn_header_id
			   ,p_remaining_mmtt_splt => 'Y'
			   ,p_operation_type => p_operation_type);
		IF (x_return_status <> g_ret_sts_success) THEN
		   IF (l_debug = 1) THEN
		      print_debug('SPLIT_MO: Error in split_mmtt',4);
		   END IF;
		   RAISE fnd_api.g_exc_error;
		END IF;
	     END IF;
	  END IF; --  IF (l_orig_mol_rec.quantity_detailed > l_orig_mol_rec.quantity)

	  l_progress := '66';

	  --R12: XDOCK EXE
	  IF l_orig_mol_rec.backorder_delivery_detail_id  IS NOT NULL AND l_orig_mol_rec.crossdock_type = 1 THEN

	     IF (l_debug = 1) THEN
		print_debug('Calling inv_rcv_reservation_util.split_wdd',4);
	     END IF;

	     inv_rcv_reservation_util.split_wdd
	       (x_return_status    => x_return_status
		,x_msg_count       => x_msg_count
		,x_msg_data        => x_msg_data
		,x_new_wdd_id      => l_new_wdd_id
		,p_wdd_id          => l_orig_mol_rec.backorder_delivery_detail_id
		,p_new_mol_id      => l_new_mol_rec.line_id
		,p_qty_to_splt     => l_new_mol_rec.primary_quantity);

	     IF (l_debug = 1) THEN
		print_debug('Returned from inv_rcv_reservation_util.split_wdd',4);
		print_debug('x_return_status =>'||x_return_status,4);
	     END IF;

	     IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
		IF (l_debug = 1) THEN
		   print_debug('x_msg_data:   '||x_msg_data,4);
		   print_debug('x_msg_count:  '||x_msg_count,4);
		   print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,4);
		   print_debug('Raising Exception!!!',4);
		END IF;
		l_progress := '@@@';
		RAISE fnd_api.g_exc_unexpected_error;
	     END IF;

	     l_new_mol_rec.backorder_delivery_detail_id  := l_new_wdd_id;

             BEGIN
		SELECT  Nvl(source_document_type_id, -1)
		  INTO  l_doc_type
		  FROM  wsh_delivery_details
		  WHERE delivery_detail_id = l_orig_mol_rec.backorder_delivery_detail_id;
	     EXCEPTION
		WHEN OTHERS THEN
		   IF (l_debug = 1) THEN
		      print_debug('Error retrieving doc type for SO',4);
		   END IF;
		   RAISE fnd_api.g_exc_unexpected_error;
	     END;

	     IF l_doc_type = 10 THEN
		l_rsv_query_rec.demand_source_type_id := inv_reservation_global.g_source_type_internal_ord;
	      ELSE
		l_rsv_query_rec.demand_source_type_id := inv_reservation_global.g_source_type_oe;
	     END if;

	     l_rsv_query_rec.demand_source_line_detail := l_orig_mol_rec.backorder_delivery_detail_id;

	     IF (l_debug = 1) THEN
		print_debug('Calling inv_reservation_pub.query_reservation',4);
	     END IF;

	     inv_reservation_pub.query_reservation
	       (p_api_version_number          => 1.0
		, x_return_status             => x_return_status
		, x_msg_count                 => x_msg_count
		, x_msg_data                  => x_msg_data
		, p_query_input               => l_rsv_query_rec
		, p_lock_records              => fnd_api.g_true --???
		, p_sort_by_req_date          => inv_reservation_global.g_query_demand_ship_date_desc--There's shoudl be just 1 row
		, x_mtl_reservation_tbl       => l_rsv_results_tbl
		, x_mtl_reservation_tbl_count => l_rsv_results_count
		, x_error_code                => l_error_code
		);

	     IF (l_debug = 1) THEN
		print_debug('Returned from inv_reservation_pub.query_reservation',4);
		print_debug('x_return_status: '||x_return_status,4);
	     END IF;

	     IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
		IF (l_debug = 1) THEN
		   print_debug('x_error_code: '||l_error_code,4);
		   print_debug('x_msg_data:   '||x_msg_data,4);
		   print_debug('x_msg_count:  '||x_msg_count,4);
		   print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,4);
		   print_debug('Raising Exception!!!',4);
		END IF;
		l_progress := '@@@';
		RAISE fnd_api.g_exc_unexpected_error;
	     END IF;

	     l_rsv_update_rec := l_rsv_results_tbl(1);
	     l_rsv_update_rec.demand_source_line_detail     := l_new_wdd_id;
	     l_rsv_update_rec.primary_reservation_quantity  := l_new_mol_rec.primary_quantity;
	     l_rsv_update_rec.reservation_quantity :=
	       inv_rcv_cache.convert_qty
	          (p_inventory_item_id   => l_new_mol_rec.inventory_item_id
		   ,p_from_qty           => l_new_mol_rec.primary_quantity
		   ,p_from_uom_code      => l_rsv_results_tbl(1).primary_uom_code
		   ,p_to_uom_code        => l_rsv_results_tbl(1).reservation_uom_code
		   );

	     IF (l_debug = 1) THEN
		print_debug('Calling inv_reservation_pub.transfer_reservation',4);
	     END IF;

	     inv_reservation_pub.transfer_reservation
	       (p_api_version_number         => 1.0
		,x_return_status              => x_return_status
		,x_msg_count                  => x_msg_count
		,x_msg_data                   => x_msg_data
		,p_original_rsv_rec           => l_rsv_results_tbl(1)
		,p_to_rsv_rec                 => l_rsv_update_rec
		,p_original_serial_number     => l_dummy_serial
		,p_to_serial_number           => l_dummy_serial
		,p_validation_flag            => fnd_api.g_false --??
		,x_to_reservation_id          => l_new_reservation_id);

	     IF (l_debug = 1) THEN
		print_debug('Returned from inv_reservation_pub.transfer_reservation',4);
		print_debug('x_return_status =>'||x_return_status,4);
		print_debug('x_to_reservation_id =>'||l_new_reservation_id,4);
	     END IF;

	     IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
		IF (l_debug = 1) THEN
		   print_debug('x_msg_data:  '||x_msg_data,4);
		   print_debug('x_msg_count: '||x_msg_count,4);
		   print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,4);
		   print_debug('Raising Exception!!!',4);
		END IF;
		l_progress := '@@@';
		RAISE fnd_api.g_exc_unexpected_error;
	     END IF;

	  END IF;--IF l_orig_mol_rec.backorder_delivery_detail_id  IS NOT NULL
	  --R12: XDOCK EXE END

	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MO - Update new MOL:'
			 ||l_new_mol_rec.line_id||'  with quantity = ' ||
			 l_new_mol_rec.quantity || ' qty_dlvd = ' ||
			 l_new_mol_rec.quantity_delivered || ' qty_dtld = ' ||
			 l_new_mol_rec.quantity_detailed, 4);

	     print_debug('with sec quantity = ' ||
			 l_new_mol_rec.secondary_quantity || ' sec_qty_dlvd = ' ||
			 l_new_mol_rec.secondary_quantity_delivered || ' sec_qty_dtld = ' ||
			 l_new_mol_rec.secondary_quantity_detailed, 4);
	  END IF;

          BEGIN
             IF (l_orig_mol_rec.SECONDARY_UOM IS NOT NULL) THEN
         	     UPDATE
         	       mtl_txn_request_lines
         	       SET
         	       primary_quantity = l_new_mol_rec.primary_quantity
         	       ,quantity = l_new_mol_rec.quantity
         	       ,quantity_delivered = l_new_mol_rec.quantity_delivered
         	       ,quantity_detailed = l_new_mol_rec.quantity_detailed
                    -- OPM COnvergence
         	       ,secondary_quantity = l_new_mol_rec.secondary_quantity
         	       ,secondary_quantity_delivered = l_new_mol_rec.secondary_quantity_delivered
         	       ,secondary_quantity_detailed = l_new_mol_rec.secondary_quantity_detailed
         	       ,last_update_date = Sysdate
		       ,backorder_delivery_detail_id = l_new_mol_rec.backorder_delivery_detail_id
         	       WHERE
         	       line_id = l_new_mol_rec.line_id;
             ELSE
         	     UPDATE
         	       mtl_txn_request_lines
         	       SET
         	       primary_quantity = l_new_mol_rec.primary_quantity
         	       ,quantity = l_new_mol_rec.quantity
         	       ,quantity_delivered = l_new_mol_rec.quantity_delivered
         	       ,quantity_detailed = l_new_mol_rec.quantity_detailed
		       ,last_update_date = Sysdate
		       ,backorder_delivery_detail_id = l_new_mol_rec.backorder_delivery_detail_id
         	       WHERE
         	       line_id = l_new_mol_rec.line_id;


             END IF;

	  EXCEPTION
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   print_debug('SPLIT_MO: Error update new mol record',
			       4);
		END IF;
		RAISE fnd_api.g_exc_error;
	  END;

	  l_progress := '190';

	  -- Update the p_mo_splt_tb with the new MOL line_id
	  p_mo_splt_tb(l_indx).line_id := l_new_mol_rec.line_id;
	  p_mo_splt_tb(l_indx).wdd_id :=  l_new_mol_rec.backorder_delivery_detail_id;
	  p_mo_splt_tb(l_indx).reservation_id :=  l_new_reservation_id;

	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MO: Final MOL State in this iteration:',4);
	      print_debug('SPLIT_MO ORIG: MOL:'||l_orig_mol_rec.line_id ||
			  ' QTY:'||l_orig_mol_rec.quantity||
			  ' PRIM_QTY:'||l_orig_mol_rec.quantity ||
			  ' QTY_DTD:'||l_orig_mol_rec.quantity_detailed||
			  ' QTY_DLVD:'||l_orig_mol_rec.quantity_delivered||
			  ' SEC_QTY:'||l_orig_mol_rec.secondary_quantity||
           ' SEC_QTY_DTD:'||l_orig_mol_rec.secondary_quantity_detailed||
			  ' SEC_QTY_DLVD:'||l_orig_mol_rec.secondary_quantity_delivered,4
			  );

	      print_debug('SPLIT_MO NEW: MOL:'||l_new_mol_rec.line_id ||
			  ' QTY:'||l_new_mol_rec.quantity||
			  ' PRIM_QTY:'||l_new_mol_rec.quantity ||
			  ' QTY_DTD:'||l_new_mol_rec.quantity_detailed||
			  ' QTY_DLVD:'||l_orig_mol_rec.quantity_delivered||
			  ' SEC_QTY:'||l_new_mol_rec.secondary_quantity ||
			  ' SEC_QTY_DTD:'||l_new_mol_rec.secondary_quantity_detailed||
			  ' SEC_QTY_DLVD:'||l_orig_mol_rec.secondary_quantity_delivered,4
			  );
	  END IF;
       END IF; --(l_indx = p_mo_splt_tb.COUNT AND ( l_qty_to_splt(l_indx) = l_orig_mol_rec.quantity-l_orig_mol_rec.quantity_delivered) )
    END LOOP;


    -- At the end, needs to update original MOL
    -- Make sure that these values are not less than zero
    IF (l_orig_mol_rec.quantity_delivered < 0) THEN
       l_orig_mol_rec.quantity_delivered := 0;
    END IF;

    IF (l_orig_mol_rec.quantity_detailed < 0) THEN
       l_orig_mol_rec.quantity_detailed := 0;
    END IF;

    IF (l_orig_mol_rec.secondary_quantity_delivered < 0) THEN
       l_orig_mol_rec.secondary_quantity_delivered := 0;
    END IF;

    IF (l_orig_mol_rec.secondary_quantity_detailed < 0) THEN
       l_orig_mol_rec.secondary_quantity_detailed := 0;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('SPLIT_MO - Update original MOL:'
		   ||l_orig_mol_rec.line_id ||' with quantity = ' ||
		   l_orig_mol_rec.quantity || ' qty_dlvd = ' ||
		   l_orig_mol_rec.quantity_delivered || ' qty_dtld = ' ||
		   l_orig_mol_rec.quantity_detailed||' with sec quantity = ' ||
		   l_orig_mol_rec.secondary_quantity || ' sec_qty_dlvd = ' ||
		   l_orig_mol_rec.secondary_quantity_delivered || ' sec_qty_dtld = ' ||
		   l_orig_mol_rec.secondary_quantity_detailed,4);
    END IF;

    l_progress := '200';
    BEGIN
      IF (l_orig_mol_rec.SECONDARY_UOM IS NOT NULL) THEN
           UPDATE
             mtl_txn_request_lines
             SET
             primary_quantity = l_orig_mol_rec.primary_quantity
             ,quantity = l_orig_mol_rec.quantity
             ,quantity_delivered = l_orig_mol_rec.quantity_delivered
             ,quantity_detailed = l_orig_mol_rec.quantity_detailed
              -- OPM COnvergence
             ,secondary_quantity = l_orig_mol_rec.secondary_quantity
             ,secondary_quantity_delivered = l_orig_mol_rec.secondary_quantity_delivered
             ,secondary_quantity_detailed = l_orig_mol_rec.secondary_quantity_detailed
             ,last_update_date = Sysdate
             WHERE
             line_id = l_orig_mol_rec.line_id;
       ELSE
           UPDATE
             mtl_txn_request_lines
             SET
             primary_quantity = l_orig_mol_rec.primary_quantity
             ,quantity = l_orig_mol_rec.quantity
             ,quantity_delivered = l_orig_mol_rec.quantity_delivered
             ,quantity_detailed = l_orig_mol_rec.quantity_detailed
             ,last_update_date = Sysdate
             WHERE
             line_id = l_orig_mol_rec.line_id;
       END IF;
    EXCEPTION
       WHEN OTHERS THEN
	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MO ERROR: error update original MOL',4);
	  END IF;
	  RAISE fnd_api.g_exc_error;
    END;

    l_progress := '210';
    IF (l_debug = 1) THEN
      print_debug('SPLIT_MO - Quitting split_mo', 4);
   END IF;

 EXCEPTION
    WHEN OTHERS THEN
       IF (l_debug  = 1) THEN
	  print_debug('SPLIT_MO: Exception occured after l_progress = ' ||
		      l_progress || ' SQLCODE = ' || SQLCODE, 4);
       END IF;

       x_return_status := g_ret_sts_unexp_err;

       fnd_msg_pub.count_and_get
	 (  p_count  => x_msg_count
	    ,p_data  => x_msg_data );
       ROLLBACK TO split_mo_pub;
 END split_mo;

PROCEDURE split_mo
  (p_orig_mol_id    IN NUMBER,
   p_mo_splt_tb     IN OUT NOCOPY mo_in_tb_tp,
   x_return_status  OUT   NOCOPY VARCHAR2,
   x_msg_count      OUT   NOCOPY NUMBER,
   x_msg_data       OUT   NOCOPY VARCHAR2
   )
  IS
     l_txn_header_id NUMBER;
     l_operation_type VARCHAR2(15);
     l_updt_putaway_temp_tbl VARCHAR2(5);
 BEGIN
    x_return_status := g_ret_sts_success;
    inv_rcv_integration_apis.split_mo
      (p_orig_mol_id => p_orig_mol_id
       , p_mo_splt_tb => p_mo_splt_tb
       , p_updt_putaway_temp_tbl => l_updt_putaway_temp_tbl
       , p_txn_header_id => l_txn_header_id
       , p_operation_type => l_operation_type
       , x_return_status => x_return_status
       , x_msg_count => x_msg_count
       , x_msg_data => x_msg_data);

 END split_mo;


 PROCEDURE split_mmtt
   (p_orig_mmtt_id      NUMBER
    ,p_prim_qty_to_splt NUMBER
    ,p_prim_uom_code    VARCHAR2
    ,x_new_mmtt_id      OUT nocopy NUMBER
    ,x_return_status    OUT NOCOPY VARCHAR2
    ,x_msg_count        OUT NOCOPY NUMBER
    ,x_msg_data         OUT NOCOPY VARCHAR2
    ) IS
       CURSOR  mmtt_cur IS
	  SELECT transaction_header_id
	    ,transaction_temp_id
	    ,source_code
	    ,source_line_id
	    ,transaction_mode
	    ,lock_flag
	    ,last_update_date
	    ,last_updated_by
	    ,creation_date
	    ,created_by
	    ,last_update_login
	    ,request_id
	    ,program_application_id
	    ,program_id
	    ,program_update_date
	    ,inventory_item_id
	    ,revision
	    ,organization_id
	    ,subinventory_code
	    ,locator_id
	    ,transaction_quantity
	    ,primary_quantity
	    ,transaction_uom
	    ,transaction_cost
	    ,transaction_type_id
	    ,transaction_action_id
	    ,transaction_source_type_id
	    ,transaction_source_id
	    ,transaction_source_name
	    ,transaction_date
	    ,acct_period_id
	    ,distribution_account_id
	    ,transaction_reference
	    ,requisition_line_id
	    ,requisition_distribution_id
	    ,reason_id
	    ,Ltrim(Rtrim(lot_number)) lot_number
	    ,lot_expiration_date
	    ,serial_number
	    ,receiving_document
	    ,demand_id
	    ,rcv_transaction_id
	    ,move_transaction_id
	    ,completion_transaction_id
	    ,wip_entity_type
	    ,schedule_id
	    ,repetitive_line_id
	    ,employee_code
	    ,primary_switch
	    ,schedule_update_code
	    ,setup_teardown_code
	    ,item_ordering
	    ,negative_req_flag
	    ,operation_seq_num
	    ,picking_line_id
	    ,trx_source_line_id
	    ,trx_source_delivery_id
	    ,physical_adjustment_id
	    ,cycle_count_id
	    ,rma_line_id
	    ,customer_ship_id
	    ,currency_code
	    ,currency_conversion_rate
	    ,currency_conversion_type
	    ,currency_conversion_date
	    ,ussgl_transaction_code
	    ,vendor_lot_number
	    ,encumbrance_account
	    ,encumbrance_amount
	    ,ship_to_location
	    ,shipment_number
	    ,transfer_cost
	    ,transportation_cost
	    ,transportation_account
	    ,freight_code
	    ,containers
	    ,waybill_airbill
	    ,expected_arrival_date
	    ,transfer_subinventory
	    ,transfer_organization
	    ,transfer_to_location
	    ,new_average_cost
	    ,value_change
	    ,percentage_change
	    ,material_allocation_temp_id
	    ,demand_source_header_id
	    ,demand_source_line
	    ,demand_source_delivery
	    ,item_segments
	    ,item_description
	    ,item_trx_enabled_flag
	    ,item_location_control_code
	    ,item_restrict_subinv_code
	    ,item_restrict_locators_code
	    ,item_revision_qty_control_code
	    ,item_primary_uom_code
	    ,item_uom_class
	    ,item_shelf_life_code
	    ,item_shelf_life_days
	    ,item_lot_control_code
	    ,item_serial_control_code
	    ,item_inventory_asset_flag
	    ,allowed_units_lookup_code
	    ,department_id
	    ,department_code
	    ,wip_supply_type
	    ,supply_subinventory
	    ,supply_locator_id
	    ,valid_subinventory_flag
	    ,valid_locator_flag
	    ,locator_segments
	    ,current_locator_control_code
	    ,number_of_lots_entered
	    ,wip_commit_flag
	    ,next_lot_number
	    ,lot_alpha_prefix
	    ,next_serial_number
	    ,serial_alpha_prefix
	    ,shippable_flag
	    ,posting_flag
	    ,required_flag
	    ,process_flag
	    ,error_code
	    ,error_explanation
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
	    ,movement_id
	    ,reservation_quantity
	    ,shipped_quantity
	    ,transaction_line_number
	    ,task_id
	    ,to_task_id
	    ,source_task_id
	    ,project_id
	    ,source_project_id
	    ,pa_expenditure_org_id
	    ,to_project_id
	    ,expenditure_type
	    ,final_completion_flag
	    ,transfer_percentage
	    ,transaction_sequence_id
	    ,material_account
	    ,material_overhead_account
	    ,resource_account
	    ,outside_processing_account
	    ,overhead_account
	    ,flow_schedule
	    ,cost_group_id
	    ,demand_class
	    ,qa_collection_id
	    ,kanban_card_id
	    ,overcompletion_transaction_qty
	    ,overcompletion_primary_qty
	    ,overcompletion_transaction_id
	    ,end_item_unit_number
	    ,scheduled_payback_date
	    ,line_type_code
	    ,parent_transaction_temp_id
	    ,put_away_strategy_id
	    ,put_away_rule_id
	    ,pick_strategy_id
	    ,pick_rule_id
	    ,move_order_line_id
	    ,task_group_id
	    ,pick_slip_number
	    ,reservation_id
	    ,common_bom_seq_id
	    ,common_routing_seq_id
	    ,org_cost_group_id
	    ,cost_type_id
	    ,transaction_status
	    ,standard_operation_id
	    ,task_priority
	    ,wms_task_type
	    ,parent_line_id
	    ,transfer_cost_group_id
	    ,lpn_id
	    ,transfer_lpn_id
	    ,wms_task_status
	    ,content_lpn_id
	    ,container_item_id
	    ,cartonization_id
	    ,pick_slip_date
	    ,rebuild_item_id
	    ,rebuild_serial_number
	    ,rebuild_activity_id
	    ,rebuild_job_name
	    ,organization_type
	    ,transfer_organization_type
	    ,owning_organization_id
	    ,owning_tp_type
	    ,xfr_owning_organization_id
	    ,transfer_owning_tp_type
	    ,planning_organization_id
	    ,planning_tp_type
	    ,xfr_planning_organization_id
	    ,transfer_planning_tp_type
	    ,secondary_uom_code
	    ,secondary_transaction_quantity
	    ,allocated_lpn_id
	    ,schedule_number
	    ,scheduled_flag
	    ,class_code
	    ,schedule_group
	    ,build_sequence
	    ,bom_revision
	    ,routing_revision
	    ,bom_revision_date
	    ,routing_revision_date
	    ,alternate_bom_designator
	    ,alternate_routing_designator
	    ,transaction_batch_id
	    ,transaction_batch_seq
	    ,operation_plan_id
	    ,move_order_header_id
	    ,serial_allocated_flag
	    FROM mtl_material_transactions_temp
	    WHERE transaction_temp_id = p_orig_mmtt_id;

       l_mmtt_rec mmtt_cur%ROWTYPE;
       l_new_mmtt_id NUMBER;
       l_mmtts_to_split  wms_atf_runtime_pub_apis.task_id_table_type;
       l_sysdate DATE := Sysdate;

       l_error_code NUMBER;
       l_debug    NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
       l_progress VARCHAR2(10) := '10';

 BEGIN

    x_return_status := g_ret_sts_success;

    IF (l_debug = 1) THEN
       print_debug('SPLIT_MMTT: Entering...', 4);
       print_debug('     p_orig_mmtt_id     => '||p_orig_mmtt_id,4);
       print_debug('     p_prim_qty_to_splt => '||p_prim_qty_to_splt,4);
       print_debug('     p_prim_uom_code    => '||p_prim_uom_code,4);
    END IF;

    OPEN mmtt_cur;
    FETCH mmtt_cur INTO l_mmtt_rec;
    CLOSE mmtt_cur;

    IF (Nvl(l_mmtt_rec.primary_quantity,0) < p_prim_qty_to_splt) THEN
       print_debug(' ORIG MMTT QYT > P_PRIM_QTY_SPLT!!',1);
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_mmtt_rec.primary_quantity := p_prim_qty_to_splt;

    IF (l_mmtt_rec.transaction_uom <> p_prim_uom_code) THEN
       l_mmtt_rec.transaction_quantity := inv_rcv_cache.convert_qty
	                                     (p_inventory_item_id   => l_mmtt_rec.inventory_item_id
					      ,p_from_qty           => p_prim_qty_to_splt
					      ,p_from_uom_code      => p_prim_uom_code
					      ,p_to_uom_code        => l_mmtt_rec.transaction_uom
					      );
     ELSE
       l_mmtt_rec.transaction_quantity := p_prim_qty_to_splt;
    END IF;

    BEGIN
       INSERT INTO mtl_material_transactions_temp
	 ( transaction_header_id
	   ,transaction_temp_id
	   ,source_code
	   ,source_line_id
	   ,transaction_mode
	   ,lock_flag
	   ,last_update_date
	   ,last_updated_by
	   ,creation_date
	   ,created_by
	   ,last_update_login
	   ,request_id
	   ,program_application_id
	   ,program_id
	   ,program_update_date
	   ,inventory_item_id
	   ,revision
	   ,organization_id
	   ,subinventory_code
	   ,locator_id
	   ,transaction_quantity
	   ,primary_quantity
	   ,transaction_uom
	   ,transaction_cost
	   ,transaction_type_id
	   ,transaction_action_id
	   ,transaction_source_type_id
	   ,transaction_source_id
	   ,transaction_source_name
	   ,transaction_date
	   ,acct_period_id
	   ,distribution_account_id
	   ,transaction_reference
	   ,requisition_line_id
	   ,requisition_distribution_id
	   ,reason_id
	   ,lot_number
	   ,lot_expiration_date
	   ,serial_number
	   ,receiving_document
	   ,demand_id
	   ,rcv_transaction_id
	   ,move_transaction_id
	 ,completion_transaction_id
	 ,wip_entity_type
	 ,schedule_id
	 ,repetitive_line_id
	 ,employee_code
	 ,primary_switch
	 ,schedule_update_code
	 ,setup_teardown_code
	 ,item_ordering
	 ,negative_req_flag
	 ,operation_seq_num
	 ,picking_line_id
	 ,trx_source_line_id
	 ,trx_source_delivery_id
	 ,physical_adjustment_id
	 ,cycle_count_id
	 ,rma_line_id
	 ,customer_ship_id
	 ,currency_code
	 ,currency_conversion_rate
	 ,currency_conversion_type
	 ,currency_conversion_date
	 ,ussgl_transaction_code
	 ,vendor_lot_number
	 ,encumbrance_account
	 ,encumbrance_amount
	 ,ship_to_location
	 ,shipment_number
	 ,transfer_cost
	 ,transportation_cost
	 ,transportation_account
	 ,freight_code
	 ,containers
	 ,waybill_airbill
	 ,expected_arrival_date
	 ,transfer_subinventory
	 ,transfer_organization
	 ,transfer_to_location
	 ,new_average_cost
	 ,value_change
	 ,percentage_change
	 ,material_allocation_temp_id
	 ,demand_source_header_id
	 ,demand_source_line
	 ,demand_source_delivery
	 ,item_segments
	 ,item_description
	 ,item_trx_enabled_flag
	 ,item_location_control_code
	 ,item_restrict_subinv_code
	 ,item_restrict_locators_code
	 ,item_revision_qty_control_code
	 ,item_primary_uom_code
	 ,item_uom_class
	 ,item_shelf_life_code
	 ,item_shelf_life_days
	 ,item_lot_control_code
	 ,item_serial_control_code
	 ,item_inventory_asset_flag
	 ,allowed_units_lookup_code
	 ,department_id
	 ,department_code
	 ,wip_supply_type
	 ,supply_subinventory
	 ,supply_locator_id
	 ,valid_subinventory_flag
	 ,valid_locator_flag
	 ,locator_segments
	 ,current_locator_control_code
	 ,number_of_lots_entered
	 ,wip_commit_flag
	 ,next_lot_number
	 ,lot_alpha_prefix
	 ,next_serial_number
	 ,serial_alpha_prefix
	 ,shippable_flag
	 ,posting_flag
	 ,required_flag
	 ,process_flag
	 ,error_code
	 ,error_explanation
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
	 ,movement_id
	 ,reservation_quantity
	 ,shipped_quantity
	 ,transaction_line_number
	 ,task_id
	 ,to_task_id
	 ,source_task_id
	 ,project_id
	 ,source_project_id
	 ,pa_expenditure_org_id
	 ,to_project_id
	 ,expenditure_type
	 ,final_completion_flag
	 ,transfer_percentage
	 ,transaction_sequence_id
	 ,material_account
	 ,material_overhead_account
	 ,resource_account
	 ,outside_processing_account
	 ,overhead_account
	 ,flow_schedule
	 ,cost_group_id
	 ,demand_class
	 ,qa_collection_id
	 ,kanban_card_id
	 ,overcompletion_transaction_qty
	 ,overcompletion_primary_qty
	 ,overcompletion_transaction_id
	 ,end_item_unit_number
	 ,scheduled_payback_date
	 ,line_type_code
	 ,parent_transaction_temp_id
	 ,put_away_strategy_id
	 ,put_away_rule_id
	 ,pick_strategy_id
	 ,pick_rule_id
	 ,move_order_line_id
	 ,task_group_id
	 ,pick_slip_number
	 ,reservation_id
	 ,common_bom_seq_id
	 ,common_routing_seq_id
	 ,org_cost_group_id
	 ,cost_type_id
	 ,transaction_status
	 ,standard_operation_id
	 ,task_priority
	 ,wms_task_type
	 ,parent_line_id
	 ,transfer_cost_group_id
	 ,lpn_id
	 ,transfer_lpn_id
	 ,wms_task_status
	 ,content_lpn_id
	 ,container_item_id
	 ,cartonization_id
	 ,pick_slip_date
	 ,rebuild_item_id
	 ,rebuild_serial_number
	 ,rebuild_activity_id
	 ,rebuild_job_name
	 ,organization_type
	 ,transfer_organization_type
	 ,owning_organization_id
	 ,owning_tp_type
	 ,xfr_owning_organization_id
	 ,transfer_owning_tp_type
	 ,planning_organization_id
	 ,planning_tp_type
	 ,xfr_planning_organization_id
	 ,transfer_planning_tp_type
	 ,secondary_uom_code
	 ,secondary_transaction_quantity
	 ,allocated_lpn_id
	 ,schedule_number
	 ,scheduled_flag
	 ,class_code
	 ,schedule_group
	 ,build_sequence
	 ,bom_revision
	 ,routing_revision
	 ,bom_revision_date
	 ,routing_revision_date
	 ,alternate_bom_designator
	 ,alternate_routing_designator
	 ,transaction_batch_id
	 ,transaction_batch_seq
	 ,operation_plan_id
	 ,move_order_header_id
	 ,serial_allocated_flag )
	 VALUES
	 ( mtl_material_transactions_s.NEXTVAL  --use different header
	   ,mtl_material_transactions_s.NEXTVAL
	   ,l_mmtt_rec.SOURCE_CODE
	   ,l_mmtt_rec.SOURCE_LINE_ID
	   ,l_mmtt_rec.TRANSACTION_MODE
	   ,l_mmtt_rec.LOCK_FLAG
	   ,l_sysdate
	   ,l_mmtt_rec.LAST_UPDATED_BY
	   ,l_sysdate
	   ,l_mmtt_rec.CREATED_BY
	   ,l_mmtt_rec.LAST_UPDATE_LOGIN
	   ,l_mmtt_rec.REQUEST_ID
	   ,l_mmtt_rec.PROGRAM_APPLICATION_ID
	   ,l_mmtt_rec.PROGRAM_ID
	   ,l_mmtt_rec.PROGRAM_UPDATE_DATE
	   ,l_mmtt_rec.INVENTORY_ITEM_ID
	   ,l_mmtt_rec.REVISION
	   ,l_mmtt_rec.ORGANIZATION_ID
	   ,l_mmtt_rec.SUBINVENTORY_CODE
	   ,l_mmtt_rec.LOCATOR_ID
	   ,l_mmtt_rec.TRANSACTION_QUANTITY
	   ,l_mmtt_rec.PRIMARY_QUANTITY
	   ,l_mmtt_rec.TRANSACTION_UOM
	   ,l_mmtt_rec.TRANSACTION_COST
	   ,l_mmtt_rec.TRANSACTION_TYPE_ID
	   ,l_mmtt_rec.TRANSACTION_ACTION_ID
	   ,l_mmtt_rec.TRANSACTION_SOURCE_TYPE_ID
	   ,l_mmtt_rec.TRANSACTION_SOURCE_ID
	 ,l_mmtt_rec.TRANSACTION_SOURCE_NAME
	 ,l_mmtt_rec.TRANSACTION_DATE
	 ,l_mmtt_rec.ACCT_PERIOD_ID
	 ,l_mmtt_rec.DISTRIBUTION_ACCOUNT_ID
	 ,l_mmtt_rec.TRANSACTION_REFERENCE
	 ,l_mmtt_rec.REQUISITION_LINE_ID
	 ,l_mmtt_rec.REQUISITION_DISTRIBUTION_ID
	 ,l_mmtt_rec.REASON_ID
	 ,Ltrim(Rtrim(l_mmtt_rec.lot_number))
	 ,l_mmtt_rec.LOT_EXPIRATION_DATE
	 ,l_mmtt_rec.SERIAL_NUMBER
	 ,l_mmtt_rec.RECEIVING_DOCUMENT
	 ,l_mmtt_rec.DEMAND_ID
	 ,l_mmtt_rec.RCV_TRANSACTION_ID
	 ,l_mmtt_rec.MOVE_TRANSACTION_ID
	 ,l_mmtt_rec.COMPLETION_TRANSACTION_ID
	 ,l_mmtt_rec.WIP_ENTITY_TYPE
	 ,l_mmtt_rec.SCHEDULE_ID
	 ,l_mmtt_rec.REPETITIVE_LINE_ID
	 ,l_mmtt_rec.employee_code
	 ,l_mmtt_rec.PRIMARY_SWITCH
	 ,l_mmtt_rec.SCHEDULE_UPDATE_CODE
	 ,l_mmtt_rec.SETUP_TEARDOWN_CODE
	 ,l_mmtt_rec.ITEM_ORDERING
	 ,l_mmtt_rec.NEGATIVE_REQ_FLAG
	 ,l_mmtt_rec.OPERATION_SEQ_NUM
	 ,l_mmtt_rec.PICKING_LINE_ID
	 ,l_mmtt_rec.TRX_SOURCE_LINE_ID
	 ,l_mmtt_rec.TRX_SOURCE_DELIVERY_ID
	 ,l_mmtt_rec.PHYSICAL_ADJUSTMENT_ID
	 ,l_mmtt_rec.CYCLE_COUNT_ID
	 ,l_mmtt_rec.RMA_LINE_ID
	 ,l_mmtt_rec.CUSTOMER_SHIP_ID
	 ,l_mmtt_rec.CURRENCY_CODE
	 ,l_mmtt_rec.CURRENCY_CONVERSION_RATE
	 ,l_mmtt_rec.CURRENCY_CONVERSION_TYPE
	 ,l_mmtt_rec.CURRENCY_CONVERSION_DATE
	 ,l_mmtt_rec.USSGL_TRANSACTION_CODE
	 ,l_mmtt_rec.VENDOR_LOT_NUMBER
	 ,l_mmtt_rec.ENCUMBRANCE_ACCOUNT
	 ,l_mmtt_rec.ENCUMBRANCE_AMOUNT
	 ,l_mmtt_rec.SHIP_TO_LOCATION
	 ,l_mmtt_rec.SHIPMENT_NUMBER
	 ,l_mmtt_rec.TRANSFER_COST
	 ,l_mmtt_rec.TRANSPORTATION_COST
	 ,l_mmtt_rec.TRANSPORTATION_ACCOUNT
	 ,l_mmtt_rec.FREIGHT_CODE
	 ,l_mmtt_rec.CONTAINERS
	 ,l_mmtt_rec.WAYBILL_AIRBILL
	 ,l_mmtt_rec.EXPECTED_ARRIVAL_DATE
	 ,l_mmtt_rec.TRANSFER_SUBINVENTORY
	 ,l_mmtt_rec.TRANSFER_ORGANIZATION
	 ,l_mmtt_rec.TRANSFER_TO_LOCATION
	 ,l_mmtt_rec.NEW_AVERAGE_COST
	 ,l_mmtt_rec.VALUE_CHANGE
	 ,l_mmtt_rec.PERCENTAGE_CHANGE
	 ,l_mmtt_rec.MATERIAL_ALLOCATION_TEMP_ID
	 ,l_mmtt_rec.DEMAND_SOURCE_HEADER_ID
	 ,l_mmtt_rec.DEMAND_SOURCE_LINE
	 ,l_mmtt_rec.DEMAND_SOURCE_DELIVERY
	 ,l_mmtt_rec.ITEM_SEGMENTS
	 ,l_mmtt_rec.ITEM_DESCRIPTION
	 ,l_mmtt_rec.ITEM_TRX_ENABLED_FLAG
	 ,l_mmtt_rec.ITEM_LOCATION_CONTROL_CODE
	 ,l_mmtt_rec.ITEM_RESTRICT_SUBINV_CODE
	 ,l_mmtt_rec.ITEM_RESTRICT_LOCATORS_CODE
	 ,l_mmtt_rec.ITEM_REVISION_QTY_CONTROL_CODE
	 ,l_mmtt_rec.ITEM_PRIMARY_UOM_CODE
	 ,l_mmtt_rec.ITEM_UOM_CLASS
	 ,l_mmtt_rec.ITEM_SHELF_LIFE_CODE
	 ,l_mmtt_rec.ITEM_SHELF_LIFE_DAYS
	 ,l_mmtt_rec.ITEM_LOT_CONTROL_CODE
	 ,l_mmtt_rec.ITEM_SERIAL_CONTROL_CODE
	 ,l_mmtt_rec.ITEM_INVENTORY_ASSET_FLAG
	 ,l_mmtt_rec.ALLOWED_UNITS_LOOKUP_CODE
	 ,l_mmtt_rec.DEPARTMENT_ID
	 ,l_mmtt_rec.DEPARTMENT_CODE
	 ,l_mmtt_rec.WIP_SUPPLY_TYPE
	 ,l_mmtt_rec.SUPPLY_SUBINVENTORY
	 ,l_mmtt_rec.SUPPLY_LOCATOR_ID
	 ,l_mmtt_rec.VALID_SUBINVENTORY_FLAG
	 ,l_mmtt_rec.VALID_LOCATOR_FLAG
	 ,l_mmtt_rec.LOCATOR_SEGMENTS
	 ,l_mmtt_rec.CURRENT_LOCATOR_CONTROL_CODE
	 ,l_mmtt_rec.NUMBER_OF_LOTS_ENTERED
	 ,l_mmtt_rec.WIP_COMMIT_FLAG
	 ,l_mmtt_rec.NEXT_LOT_NUMBER
	 ,l_mmtt_rec.LOT_ALPHA_PREFIX
	 ,l_mmtt_rec.NEXT_SERIAL_NUMBER
	 ,l_mmtt_rec.SERIAL_ALPHA_PREFIX
	 ,l_mmtt_rec.SHIPPABLE_FLAG
	 ,l_mmtt_rec.POSTING_FLAG
	 ,l_mmtt_rec.REQUIRED_FLAG
	 ,l_mmtt_rec.PROCESS_FLAG
	 ,l_mmtt_rec.ERROR_CODE
	 ,l_mmtt_rec.ERROR_EXPLANATION
	 ,l_mmtt_rec.ATTRIBUTE_CATEGORY
	 ,l_mmtt_rec.ATTRIBUTE1
	 ,l_mmtt_rec.ATTRIBUTE2
	 ,l_mmtt_rec.ATTRIBUTE3
	 ,l_mmtt_rec.ATTRIBUTE4
	 ,l_mmtt_rec.ATTRIBUTE5
	 ,l_mmtt_rec.ATTRIBUTE6
	 ,l_mmtt_rec.ATTRIBUTE7
	 ,l_mmtt_rec.ATTRIBUTE8
	 ,l_mmtt_rec.ATTRIBUTE9
	 ,l_mmtt_rec.ATTRIBUTE10
	 ,l_mmtt_rec.ATTRIBUTE11
	 ,l_mmtt_rec.ATTRIBUTE12
	 ,l_mmtt_rec.ATTRIBUTE13
	 ,l_mmtt_rec.ATTRIBUTE14
	 ,l_mmtt_rec.ATTRIBUTE15
	 ,l_mmtt_rec.MOVEMENT_ID
	 ,l_mmtt_rec.RESERVATION_QUANTITY
	 ,l_mmtt_rec.SHIPPED_QUANTITY
	 ,l_mmtt_rec.TRANSACTION_LINE_NUMBER
	 ,l_mmtt_rec.TASK_ID
	 ,l_mmtt_rec.TO_TASK_ID
	 ,l_mmtt_rec.SOURCE_TASK_ID
	 ,l_mmtt_rec.PROJECT_ID
	 ,l_mmtt_rec.SOURCE_PROJECT_ID
	 ,l_mmtt_rec.PA_EXPENDITURE_ORG_ID
	 ,l_mmtt_rec.TO_PROJECT_ID
	 ,l_mmtt_rec.EXPENDITURE_TYPE
	 ,l_mmtt_rec.FINAL_COMPLETION_FLAG
	 ,l_mmtt_rec.TRANSFER_PERCENTAGE
	 ,l_mmtt_rec.TRANSACTION_SEQUENCE_ID
	 ,l_mmtt_rec.MATERIAL_ACCOUNT
	 ,l_mmtt_rec.MATERIAL_OVERHEAD_ACCOUNT
	 ,l_mmtt_rec.RESOURCE_ACCOUNT
	 ,l_mmtt_rec.OUTSIDE_PROCESSING_ACCOUNT
	 ,l_mmtt_rec.OVERHEAD_ACCOUNT
	 ,l_mmtt_rec.FLOW_SCHEDULE
	 ,l_mmtt_rec.COST_GROUP_ID
	 ,l_mmtt_rec.DEMAND_CLASS
	 ,l_mmtt_rec.QA_COLLECTION_ID
	 ,l_mmtt_rec.KANBAN_CARD_ID
	 ,l_mmtt_rec.OVERCOMPLETION_TRANSACTION_QTY
	 ,l_mmtt_rec.OVERCOMPLETION_PRIMARY_QTY
	 ,l_mmtt_rec.OVERCOMPLETION_TRANSACTION_ID
	 ,l_mmtt_rec.END_ITEM_UNIT_NUMBER
	 ,l_mmtt_rec.SCHEDULED_PAYBACK_DATE
	 ,l_mmtt_rec.LINE_TYPE_CODE
	 ,l_mmtt_rec.PARENT_TRANSACTION_TEMP_ID
	 ,l_mmtt_rec.PUT_AWAY_STRATEGY_ID
	 ,l_mmtt_rec.PUT_AWAY_RULE_ID
	 ,l_mmtt_rec.PICK_STRATEGY_ID
	 ,l_mmtt_rec.PICK_RULE_ID
	 ,l_mmtt_rec.MOVE_ORDER_LINE_ID
	 ,l_mmtt_rec.TASK_GROUP_ID
	 ,l_mmtt_rec.PICK_SLIP_NUMBER
	 ,l_mmtt_rec.RESERVATION_ID
	 ,l_mmtt_rec.COMMON_BOM_SEQ_ID
	 ,l_mmtt_rec.COMMON_ROUTING_SEQ_ID
	 ,l_mmtt_rec.ORG_COST_GROUP_ID
	 ,l_mmtt_rec.COST_TYPE_ID
	 ,l_mmtt_rec.TRANSACTION_STATUS
	 ,l_mmtt_rec.STANDARD_OPERATION_ID
	 ,l_mmtt_rec.TASK_PRIORITY
	 ,l_mmtt_rec.WMS_TASK_TYPE
	 ,l_mmtt_rec.PARENT_LINE_ID
	 ,l_mmtt_rec.TRANSFER_COST_GROUP_ID
	 ,l_mmtt_rec.LPN_ID
	 ,l_mmtt_rec.TRANSFER_LPN_ID
	 ,l_mmtt_rec.WMS_TASK_STATUS
	 ,l_mmtt_rec.CONTENT_LPN_ID
	 ,l_mmtt_rec.CONTAINER_ITEM_ID
	 ,l_mmtt_rec.CARTONIZATION_ID
	 ,l_mmtt_rec.PICK_SLIP_DATE
	 ,l_mmtt_rec.REBUILD_ITEM_ID
	 ,l_mmtt_rec.REBUILD_SERIAL_NUMBER
	 ,l_mmtt_rec.REBUILD_ACTIVITY_ID
	 ,l_mmtt_rec.REBUILD_JOB_NAME
	 ,l_mmtt_rec.ORGANIZATION_TYPE
	 ,l_mmtt_rec.TRANSFER_ORGANIZATION_TYPE
	 ,l_mmtt_rec.OWNING_ORGANIZATION_ID
	 ,l_mmtt_rec.OWNING_TP_TYPE
	 ,l_mmtt_rec.XFR_OWNING_ORGANIZATION_ID
	 ,l_mmtt_rec.TRANSFER_OWNING_TP_TYPE
	 ,l_mmtt_rec.PLANNING_ORGANIZATION_ID
	 ,l_mmtt_rec.PLANNING_TP_TYPE
	 ,l_mmtt_rec.XFR_PLANNING_ORGANIZATION_ID
	 ,l_mmtt_rec.TRANSFER_PLANNING_TP_TYPE
	 ,l_mmtt_rec.SECONDARY_UOM_CODE
	 ,l_mmtt_rec.SECONDARY_TRANSACTION_QUANTITY
	 ,l_mmtt_rec.ALLOCATED_LPN_ID
	 ,l_mmtt_rec.SCHEDULE_NUMBER
	 ,l_mmtt_rec.SCHEDULED_FLAG
	 ,l_mmtt_rec.CLASS_CODE
	 ,l_mmtt_rec.SCHEDULE_GROUP
	 ,l_mmtt_rec.BUILD_SEQUENCE
	 ,l_mmtt_rec.BOM_REVISION
	 ,l_mmtt_rec.ROUTING_REVISION
	 ,l_mmtt_rec.BOM_REVISION_DATE
	 ,l_mmtt_rec.ROUTING_REVISION_DATE
	 ,l_mmtt_rec.ALTERNATE_BOM_DESIGNATOR
	 ,l_mmtt_rec.ALTERNATE_ROUTING_DESIGNATOR
	 ,l_mmtt_rec.TRANSACTION_BATCH_ID
	 ,l_mmtt_rec.TRANSACTION_BATCH_SEQ
	 ,l_mmtt_rec.operation_plan_id
	 ,l_mmtt_rec.move_order_header_id
	 ,l_mmtt_rec.serial_allocated_flag)
	 returning transaction_temp_id INTO l_new_mmtt_id;
    EXCEPTION
       WHEN OTHERS THEN
	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MMTT: Error while inserting new MMTT!', 4);
	     print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,11);
	  END IF;
	  RAISE fnd_api.g_exc_unexpected_error;
    END;

    x_new_mmtt_id := l_new_mmtt_id;

    BEGIN
       UPDATE mtl_material_transactions_temp
	 SET  transaction_quantity = transaction_quantity - l_mmtt_rec.transaction_quantity
	 ,    primary_quantity = primary_quantity - l_mmtt_rec.primary_quantity
	 WHERE transaction_temp_id = p_orig_mmtt_id;
    EXCEPTION
       WHEN OTHERS THEN
	  IF (l_debug = 1) THEN
	     print_debug('SPLIT_MMTT: Error while updating original MMTT!', 4);
	     print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,11);
	  END IF;
	  RAISE fnd_api.g_exc_unexpected_error;
    END ;

    -- Split parent MMTT, operation instance, operation plan
    l_mmtts_to_split(1) := l_new_mmtt_id;
    wms_atf_runtime_pub_apis.split_operation_instance
      (p_source_task_id => p_orig_mmtt_id,
       p_new_task_id_table => l_mmtts_to_split,
       p_activity_type_id  => 1, -- INBOUND
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_error_code => l_error_code,
       x_msg_data => x_msg_data);
    IF (x_return_status <> g_ret_sts_success) THEN
       IF (l_debug = 1) THEN
	  print_debug('SPLIT_MMTT: Error in split_operation_instance',4);
       END IF;
       fnd_message.set_name('WMS','WMS_TASK_SPLIT_FAIL');
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_error;
    END IF;

    IF l_debug = 1 THEN
       print_debug(' x_new_mmtt_id    => '||x_new_mmtt_id,4);
       print_debug(' Exitting SPLIT_MMTT',4);
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
       IF (l_debug = 1) THEN
	  print_debug('SPLIT_MMTT: Exception occurred after progress = ' ||
		      l_progress || ' SQLCODE = ' || SQLCODE,4);
       END IF;
       IF (mmtt_cur%isopen) THEN
	  CLOSE mmtt_cur;
       END IF;
       x_return_status := g_ret_sts_unexp_err;
       fnd_msg_pub.count_and_get
	 (  p_count  => x_msg_count
	    ,p_data  => x_msg_data );
 END split_mmtt;
END inv_rcv_integration_apis;

/
