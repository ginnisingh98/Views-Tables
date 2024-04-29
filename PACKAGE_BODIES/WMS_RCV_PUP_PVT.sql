--------------------------------------------------------
--  DDL for Package Body WMS_RCV_PUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RCV_PUP_PVT" AS
/* $Header: WMSRCVPB.pls 120.7.12010000.2 2009/06/22 08:01:36 abasheer ship $*/

g_pkg_name CONSTANT VARCHAR2(30) := 'WMS_RCV_PUP_PVT';

PROCEDURE print_debug(p_err_msg VARCHAR2,
                      p_level 	NUMBER default 4)
  IS
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
	(p_err_msg 	=> p_err_msg,
	 p_module 	=> g_pkg_name||'($Revision: 120.7.12010000.2 $)',
	 p_level 	=> p_level);
   END IF;

END print_debug;

FUNCTION insert_lot_serial(p_transaction_temp_id IN NUMBER
			   ,p_organization_id IN NUMBER
			   ,p_item_id IN NUMBER
			   ,x_return_status OUT nocopy VARCHAR2
			   ,x_msg_count OUT nocopy NUMBER
			   ,x_msg_data OUT nocopy VARCHAR2)
  RETURN NUMBER IS

     l_group_id               NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_number             VARCHAR2(80);
     l_transaction_quantity   NUMBER;
     l_primary_quantity       NUMBER;
     l_serial_txn_tmp_id      NUMBER;
     l_intf_id                NUMBER := NULL;
     l_transaction_temp_id    NUMBER;
     l_new_ser_txn_id         NUMBER;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     l_lot_expiration_date    DATE;
     l_lot_status_id              NUMBER;
     l_lot_description             VARCHAR2(256);
     l_lot_vendor_name             VARCHAR2(240);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_supplier_lot_number     VARCHAR2(80);
     l_lot_origination_date     DATE;
     l_lot_date_code     VARCHAR2(150);
     l_lot_grade_code     VARCHAR2(150);
     l_lot_change_date     DATE;
     l_lot_maturity_date     DATE;
     l_lot_retest_date     DATE;
     l_lot_age     NUMBER;
     l_lot_item_size     NUMBER;
     l_lot_color     VARCHAR2(150);
     l_lot_volume     NUMBER;
     l_lot_volume_uom     VARCHAR2(3);
     l_lot_place_of_origin     VARCHAR2(150);
     l_lot_best_by_date     DATE;
     l_lot_length     NUMBER;
     l_lot_length_uom     VARCHAR2(3);
     l_lot_recycled_content     NUMBER;
     l_lot_thickness     NUMBER;
     l_lot_thickness_uom     VARCHAR2(3);
     l_lot_width     NUMBER;
     l_lot_width_uom     VARCHAR2(3);
     l_lot_curl_wrinkle_fold     VARCHAR2(150);
     l_lot_vendor_id     NUMBER;
     l_lot_territory_code     VARCHAR2(30);
     l_lot_lot_attribute_category     VARCHAR2(30);
     l_lot_c_attribute1     VARCHAR2(150);
     l_lot_c_attribute2     VARCHAR2(150);
     l_lot_c_attribute3     VARCHAR2(150);
     l_lot_c_attribute4     VARCHAR2(150);
     l_lot_c_attribute5     VARCHAR2(150);
     l_lot_c_attribute6     VARCHAR2(150);
     l_lot_c_attribute7     VARCHAR2(150);
     l_lot_c_attribute8     VARCHAR2(150);
     l_lot_c_attribute9     VARCHAR2(150);
     l_lot_c_attribute10     VARCHAR2(150);
     l_lot_c_attribute11     VARCHAR2(150);
     l_lot_c_attribute12     VARCHAR2(150);
     l_lot_c_attribute13     VARCHAR2(150);
     l_lot_c_attribute14     VARCHAR2(150);
     l_lot_c_attribute15     VARCHAR2(150);
     l_lot_c_attribute16     VARCHAR2(150);
     l_lot_c_attribute17     VARCHAR2(150);
     l_lot_c_attribute18     VARCHAR2(150);
     l_lot_c_attribute19     VARCHAR2(150);
     l_lot_c_attribute20     VARCHAR2(150);
     l_lot_d_attribute1     DATE;
     l_lot_d_attribute2     DATE;
     l_lot_d_attribute3     DATE;
     l_lot_d_attribute4     DATE;
     l_lot_d_attribute5     DATE;
     l_lot_d_attribute6     DATE;
     l_lot_d_attribute7     DATE;
     l_lot_d_attribute8     DATE;
     l_lot_d_attribute9     DATE;
     l_lot_d_attribute10     DATE;
     l_lot_n_attribute1     NUMBER;
     l_lot_n_attribute2     NUMBER;
     l_lot_n_attribute3     NUMBER;
     l_lot_n_attribute4     NUMBER;
     l_lot_n_attribute5     NUMBER;
     l_lot_n_attribute6     NUMBER;
     l_lot_n_attribute7     NUMBER;
     l_lot_n_attribute8     NUMBER;
     l_lot_n_attribute9     NUMBER;
     l_lot_n_attribute10     NUMBER;
     l_lot_attribute_category     VARCHAR2(30);
     l_lot_attribute1     VARCHAR2(150);
     l_lot_attribute2     VARCHAR2(150);
     l_lot_attribute3     VARCHAR2(150);
     l_lot_attribute4     VARCHAR2(150);
     l_lot_attribute5     VARCHAR2(150);
     l_lot_attribute6     VARCHAR2(150);
     l_lot_attribute7     VARCHAR2(150);
     l_lot_attribute8     VARCHAR2(150);
     l_lot_attribute9     VARCHAR2(150);
     l_lot_attribute10     VARCHAR2(150);
     l_lot_attribute11     VARCHAR2(150);
     l_lot_attribute12     VARCHAR2(150);
     l_lot_attribute13     VARCHAR2(150);
     l_lot_attribute14     VARCHAR2(150);
     l_lot_attribute15     VARCHAR2(150);

     CURSOR msnt_recs(l_txn_tmp_id NUMBER) IS
	SELECT
	  fm_serial_number
	  ,to_serial_number
	  ,transaction_temp_id
	  ,vendor_serial_number
	  ,vendor_lot_number
	  ,parent_serial_number
	  ,origination_date
	  ,territory_code
	  ,time_since_new
	  ,cycles_since_new
	  ,time_since_overhaul
	  ,cycles_since_overhaul
	  ,time_since_repair
	  ,cycles_since_repair
	  ,time_since_visit
	  ,cycles_since_visit
	  ,time_since_mark
	  ,cycles_since_mark
	  ,number_of_repairs
	  ,serial_attribute_category
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
	  FROM
	  mtl_serial_numbers_temp
	  WHERE
	  transaction_temp_id = l_txn_tmp_id;

BEGIN

   IF (l_debug = 1) THEN
      print_debug('INSERT_LOT_SERIAL: Entering...');
   END IF;

   x_return_status := g_ret_sts_success;

   /* Get MTLT associated with the temp MMTT */
   BEGIN
      SELECT
	lot_number
	,transaction_quantity
	,primary_quantity
	,serial_transaction_temp_id
	, lot_expiration_date
	, status_id
	, description
	, vendor_name
	, supplier_lot_number
	, origination_date
	, date_code
	, grade_code
	, change_date
	, maturity_date
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
       INTO
	l_lot_number
	,l_transaction_quantity
	,l_primary_quantity
	,l_serial_txn_tmp_id
	,l_lot_expiration_date
	,l_lot_status_id
	,l_lot_description
	,l_lot_vendor_name
	,l_lot_supplier_lot_number
	,l_lot_origination_date
	,l_lot_date_code
	,l_lot_grade_code
	,l_lot_change_date
	,l_lot_maturity_date
	,l_lot_retest_date
	,l_lot_age
	,l_lot_item_size
	,l_lot_color
	,l_lot_volume
	,l_lot_volume_uom
	,l_lot_place_of_origin
	,l_lot_best_by_date
	,l_lot_length
	,l_lot_length_uom
	,l_lot_recycled_content
	,l_lot_thickness
	,l_lot_thickness_uom
	,l_lot_width
	,l_lot_width_uom
	,l_lot_curl_wrinkle_fold
	,l_lot_vendor_id
	,l_lot_territory_code
	,l_lot_lot_attribute_category
	,l_lot_c_attribute1
	,l_lot_c_attribute2
	,l_lot_c_attribute3
	,l_lot_c_attribute4
	,l_lot_c_attribute5
	,l_lot_c_attribute6
	,l_lot_c_attribute7
	,l_lot_c_attribute8
	,l_lot_c_attribute9
	,l_lot_c_attribute10
	,l_lot_c_attribute11
	,l_lot_c_attribute12
	,l_lot_c_attribute13
	,l_lot_c_attribute14
	,l_lot_c_attribute15
	,l_lot_c_attribute16
	,l_lot_c_attribute17
	,l_lot_c_attribute18
	,l_lot_c_attribute19
	,l_lot_c_attribute20
	,l_lot_d_attribute1
	,l_lot_d_attribute2
	,l_lot_d_attribute3
	,l_lot_d_attribute4
	,l_lot_d_attribute5
	,l_lot_d_attribute6
	,l_lot_d_attribute7
	,l_lot_d_attribute8
	,l_lot_d_attribute9
	,l_lot_d_attribute10
	,l_lot_n_attribute1
	,l_lot_n_attribute2
	,l_lot_n_attribute3
	,l_lot_n_attribute4
	,l_lot_n_attribute5
	,l_lot_n_attribute6
	,l_lot_n_attribute7
	,l_lot_n_attribute8
	,l_lot_n_attribute9
	,l_lot_n_attribute10
	,l_lot_attribute_category
	,l_lot_attribute1
	,l_lot_attribute2
	,l_lot_attribute3
	,l_lot_attribute4
	,l_lot_attribute5
	,l_lot_attribute6
	,l_lot_attribute7
	,l_lot_attribute8
	,l_lot_attribute9
	,l_lot_attribute10
	,l_lot_attribute11
	,l_lot_attribute12
	,l_lot_attribute13
	,l_lot_attribute14
	,l_lot_attribute15
	FROM
	mtl_transaction_lots_temp
	WHERE
	transaction_temp_id = p_transaction_temp_id;
   EXCEPTION
      WHEN no_data_found THEN
	 l_lot_number := NULL;
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('INSERT_LOT_SERIAL: ERROR - More than 1 row of MTLT associated with MMTT');
	 END IF;
	 RAISE fnd_api.g_exc_error;
   END;

    l_transaction_temp_id := p_transaction_temp_id;

   IF (l_lot_number IS NOT NULL) THEN

      IF (l_debug = 1) THEN
	 print_debug('INSERT_LOT_SERIAL: MTLT exists. ID:'||l_lot_number);
      END IF;

      /* Create a dummy RT ID */
      SELECT rcv_transactions_interface_s.NEXTVAL
	INTO l_intf_id
	FROM dual;

      inv_rcv_integration_apis.insert_mtli
	(p_api_version               =>   1.0
	 ,x_return_status            =>   x_return_status
	 ,x_msg_count                =>   x_msg_count
	 ,x_msg_data                 =>   x_msg_data
	 ,p_att_exist                =>   'N'
	 ,p_transaction_interface_id =>   l_transaction_temp_id
	 ,p_lot_number               =>   l_lot_number
	 ,p_transaction_quantity     =>   l_transaction_quantity
	 ,p_primary_quantity         =>   l_primary_quantity
	 ,p_organization_id          =>   p_organization_id
	 ,p_inventory_item_id        =>   p_item_id  -- from tmp mmtt
	 ,p_expiration_date          =>   l_lot_expiration_date
	 ,p_status_id                =>   l_lot_status_id
	 ,x_serial_transaction_temp_id => l_new_ser_txn_id
	 ,p_product_transaction_id   =>   l_intf_id
	 ,p_product_code             =>   'RCV'
	 ,p_description              =>  l_lot_description
	 ,p_vendor_name                =>  l_lot_vendor_name
	 ,p_supplier_lot_number        =>  l_lot_supplier_lot_number
	 ,p_origination_date           =>  l_lot_origination_date
	 ,p_date_code                  =>  l_lot_date_code
	 ,p_grade_code                 =>  l_lot_grade_code
	 ,p_change_date                =>  l_lot_change_date
	,p_maturity_date              =>  l_lot_maturity_date
	,p_retest_date                =>  l_lot_retest_date
	,p_age                        =>  l_lot_age
	,p_item_size                  =>  l_lot_item_size
	,p_color                      =>  l_lot_color
	,p_volume                     =>  l_lot_volume
	,p_volume_uom                 =>  l_lot_volume_uom
	,p_place_of_origin            =>  l_lot_place_of_origin
	,p_best_by_date               =>  l_lot_best_by_date
	,p_length                     =>  l_lot_length
	,p_length_uom                 =>  l_lot_length_uom
	,p_recycled_content           =>  l_lot_recycled_content
	,p_thickness                  =>  l_lot_thickness
	,p_thickness_uom              =>  l_lot_thickness_uom
	,p_width                      =>  l_lot_width
	,p_width_uom                  =>  l_lot_width_uom
	,p_curl_wrinkle_fold          =>  l_lot_curl_wrinkle_fold
	,p_vendor_id                  =>  l_lot_vendor_id
	,p_territory_code             =>  l_lot_territory_code
	,p_lot_attribute_category     =>  l_lot_lot_attribute_category
	,p_c_attribute1               =>  l_lot_c_attribute1
	,p_c_attribute2               =>  l_lot_c_attribute2
	,p_c_attribute3               =>  l_lot_c_attribute3
	,p_c_attribute4               =>  l_lot_c_attribute4
	,p_c_attribute5               =>  l_lot_c_attribute5
	,p_c_attribute6               =>  l_lot_c_attribute6
	,p_c_attribute7               =>  l_lot_c_attribute7
	,p_c_attribute8               =>  l_lot_c_attribute8
	,p_c_attribute9               =>  l_lot_c_attribute9
	,p_c_attribute10              =>  l_lot_c_attribute10
	,p_c_attribute11              =>  l_lot_c_attribute11
	,p_c_attribute12              =>  l_lot_c_attribute12
	,p_c_attribute13              =>  l_lot_c_attribute13
	,p_c_attribute14              =>  l_lot_c_attribute14
	,p_c_attribute15              =>  l_lot_c_attribute15
	,p_c_attribute16              =>  l_lot_c_attribute16
	,p_c_attribute17              =>  l_lot_c_attribute17
	,p_c_attribute18              =>  l_lot_c_attribute18
	,p_c_attribute19              =>  l_lot_c_attribute19
	,p_c_attribute20              =>  l_lot_c_attribute20
	,p_d_attribute1               =>  l_lot_d_attribute1
	,p_d_attribute2               =>  l_lot_d_attribute2
	,p_d_attribute3               =>  l_lot_d_attribute3
	,p_d_attribute4               =>  l_lot_d_attribute4
	,p_d_attribute5               =>  l_lot_d_attribute5
	,p_d_attribute6               =>  l_lot_d_attribute6
	,p_d_attribute7               =>  l_lot_d_attribute7
	,p_d_attribute8               =>  l_lot_d_attribute8
	,p_d_attribute9               =>  l_lot_d_attribute9
	,p_d_attribute10              =>  l_lot_d_attribute10
	,p_n_attribute1               =>  l_lot_n_attribute1
	,p_n_attribute2               =>  l_lot_n_attribute2
	,p_n_attribute3               =>  l_lot_n_attribute3
	,p_n_attribute4               =>  l_lot_n_attribute4
	,p_n_attribute5               =>  l_lot_n_attribute5
	,p_n_attribute6               =>  l_lot_n_attribute6
	,p_n_attribute7               =>  l_lot_n_attribute7
	,p_n_attribute8               =>  l_lot_n_attribute8
	,p_n_attribute9               =>  l_lot_n_attribute9
	,p_n_attribute10              =>  l_lot_n_attribute10
	,p_attribute_category         =>  l_lot_attribute_category
	,p_attribute1                 =>  l_lot_attribute1
	,p_attribute2                 =>  l_lot_attribute2
	,p_attribute3                 =>  l_lot_attribute3
	,p_attribute4                 =>  l_lot_attribute4
	,p_attribute5                 =>  l_lot_attribute5
	,p_attribute6                 =>  l_lot_attribute6
	,p_attribute7                 =>  l_lot_attribute7
	,p_attribute8                 =>  l_lot_attribute8
	,p_attribute9                 =>  l_lot_attribute9
	,p_attribute10                =>  l_lot_attribute10
	,p_attribute11                =>  l_lot_attribute11
	,p_attribute12                =>  l_lot_attribute12
	,p_attribute13                =>  l_lot_attribute13
	,p_attribute14                =>  l_lot_attribute14
	,p_attribute15                => l_lot_attribute15
	);
      IF (x_return_status <> g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('INSERT_LOT_SERIAL: ERROR - insert_mtli Fail');
	 END IF;
	 FND_MESSAGE.SET_NAME('INV','INV_CANNOT_INSERT');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;

      /* Check if there are msnt associated with this mtlt */
      IF (l_serial_txn_tmp_id IS NOT NULL) THEN

	 IF (l_debug = 1) THEN
	    print_debug('INSERT_LOT_SERIAL: MSNI Exists');
	 END IF;

	 FOR l_msnt_rec IN msnt_recs(l_serial_txn_tmp_id) LOOP
	    inv_rcv_integration_apis.insert_msni
	      (p_api_version               => 1.0
	       ,x_return_status            => x_return_status
	       ,x_msg_count                => x_msg_count
	       ,x_msg_data                 => x_msg_data
	       ,p_att_exist                => 'N'
	       ,p_transaction_interface_id => l_new_ser_txn_id
	       ,p_fm_serial_number         => l_msnt_rec.fm_serial_number
	       ,p_to_serial_number         => l_msnt_rec.to_serial_number
	       ,p_organization_id          => p_organization_id
	       ,p_inventory_item_id        => p_item_id -- from tmp mmtt
	       ,p_status_id                => 0 --l_msnt_rec.status_id
	       ,p_product_transaction_id   => l_intf_id
	       ,p_product_code             => 'RCV'
	       ,p_vendor_serial_number     => l_msnt_rec.vendor_serial_number
	       ,p_vendor_lot_number        => l_msnt_rec.vendor_lot_number
	       ,p_parent_serial_number     => l_msnt_rec.parent_serial_number
	       ,p_origination_date         => l_msnt_rec.origination_date
	       ,p_territory_code	   => l_msnt_rec.territory_code
	      ,p_time_since_new            => l_msnt_rec.time_since_new
	      ,p_cycles_since_new          => l_msnt_rec.cycles_since_new
	      ,p_time_since_overhaul       => l_msnt_rec.time_since_overhaul
	      ,p_cycles_since_overhaul     => l_msnt_rec.cycles_since_overhaul
	      ,p_time_since_repair         => l_msnt_rec.time_since_repair
	      ,p_cycles_since_repair       => l_msnt_rec.cycles_since_repair
	      ,p_time_since_visit          => l_msnt_rec.time_since_visit
	      ,p_cycles_since_visit        => l_msnt_rec.cycles_since_visit
	      ,p_time_since_mark           => l_msnt_rec.time_since_mark
	      ,p_cycles_since_mark         => l_msnt_rec.cycles_since_mark
	      ,p_number_of_repairs         => l_msnt_rec.number_of_repairs
	      ,p_serial_attribute_category  => l_msnt_rec.serial_attribute_category
	      ,p_c_attribute1              => l_msnt_rec.c_attribute1
	      ,p_c_attribute2              => l_msnt_rec.c_attribute2
	      ,p_c_attribute3              => l_msnt_rec.c_attribute3
	      ,p_c_attribute4              => l_msnt_rec.c_attribute4
	      ,p_c_attribute5              => l_msnt_rec.c_attribute5
	      ,p_c_attribute6              => l_msnt_rec.c_attribute6
	      ,p_c_attribute7              => l_msnt_rec.c_attribute7
	      ,p_c_attribute8              => l_msnt_rec.c_attribute8
	      ,p_c_attribute9              => l_msnt_rec.c_attribute9
	      ,p_c_attribute10             => l_msnt_rec.c_attribute10
	      ,p_c_attribute11             => l_msnt_rec.c_attribute11
	      ,p_c_attribute12             => l_msnt_rec.c_attribute12
	      ,p_c_attribute13             => l_msnt_rec.c_attribute13
	      ,p_c_attribute14             => l_msnt_rec.c_attribute14
	      ,p_c_attribute15             => l_msnt_rec.c_attribute15
	      ,p_c_attribute16             => l_msnt_rec.c_attribute16
	      ,p_c_attribute17             => l_msnt_rec.c_attribute17
	      ,p_c_attribute18             => l_msnt_rec.c_attribute18
	      ,p_c_attribute19             => l_msnt_rec.c_attribute19
	      ,p_c_attribute20             => l_msnt_rec.c_attribute20
	      ,p_d_attribute1              => l_msnt_rec.d_attribute1
	      ,p_d_attribute2              => l_msnt_rec.d_attribute2
	      ,p_d_attribute3              => l_msnt_rec.d_attribute3
	      ,p_d_attribute4              => l_msnt_rec.d_attribute4
	      ,p_d_attribute5              => l_msnt_rec.d_attribute5
	      ,p_d_attribute6              => l_msnt_rec.d_attribute6
	      ,p_d_attribute7              => l_msnt_rec.d_attribute7
	      ,p_d_attribute8              => l_msnt_rec.d_attribute8
	      ,p_d_attribute9              => l_msnt_rec.d_attribute9
	      ,p_d_attribute10             => l_msnt_rec.d_attribute10
	      ,p_n_attribute1              => l_msnt_rec.n_attribute1
	      ,p_n_attribute2              => l_msnt_rec.n_attribute2
	      ,p_n_attribute3              => l_msnt_rec.n_attribute3
	      ,p_n_attribute4              => l_msnt_rec.n_attribute4
	      ,p_n_attribute5              => l_msnt_rec.n_attribute5
	      ,p_n_attribute6              => l_msnt_rec.n_attribute6
	      ,p_n_attribute7              => l_msnt_rec.n_attribute7
	      ,p_n_attribute8              => l_msnt_rec.n_attribute8
	      ,p_n_attribute9              => l_msnt_rec.n_attribute9
	      ,p_n_attribute10             => l_msnt_rec.n_attribute10
	      );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('INSERT_LOT_SERIAL: ERROR- insert_msni Fail');
		  RAISE fnd_api.g_exc_error;
	       END IF;
	    END IF;
	 END LOOP;
      END IF;
    ELSE
      -- Check if there are msnt associated with the mmtt
      -- Either lot/serial or lot?
      IF (l_debug = 1) THEN
	 print_debug('INSERT_LOT_SERIAL: No MTLT exists. Check MSNT');
      END IF;

      FOR l_msnt_rec IN msnt_recs(p_transaction_temp_id) LOOP

	 IF (l_intf_id IS NULL) THEN
	    /* Create a dummy RT ID */
	    SELECT rcv_transactions_interface_s.NEXTVAL
	      INTO l_intf_id
	      FROM dual;
	 END IF;

	 inv_rcv_integration_apis.insert_msni
	   (p_api_version               => 1.0
	    ,x_return_status            => x_return_status
	    ,x_msg_count                => x_msg_count
	    ,x_msg_data                 => x_msg_data
	    ,p_att_exist                => 'N'
	    ,p_transaction_interface_id => l_msnt_rec.transaction_temp_id
	    ,p_fm_serial_number         => l_msnt_rec.fm_serial_number
	    ,p_to_serial_number         => l_msnt_rec.to_serial_number
	    ,p_organization_id          => p_organization_id
	    ,p_inventory_item_id        => p_item_id -- from tmp mmtt
	    ,p_status_id                => 0 --l_msnt_rec.status_id
	    ,p_product_transaction_id   => l_intf_id
	    ,p_product_code             => 'RCV'
	    ,p_vendor_serial_number     => l_msnt_rec.vendor_serial_number
	    ,p_vendor_lot_number        => l_msnt_rec.vendor_lot_number
	    ,p_parent_serial_number     => l_msnt_rec.parent_serial_number
	    ,p_origination_date         => l_msnt_rec.origination_date
	    ,p_territory_code	   => l_msnt_rec.territory_code
	    ,p_time_since_new            => l_msnt_rec.time_since_new
	   ,p_cycles_since_new          => l_msnt_rec.cycles_since_new
	   ,p_time_since_overhaul       => l_msnt_rec.time_since_overhaul
	   ,p_cycles_since_overhaul     => l_msnt_rec.cycles_since_overhaul
	   ,p_time_since_repair         => l_msnt_rec.time_since_repair
	   ,p_cycles_since_repair       => l_msnt_rec.cycles_since_repair
	   ,p_time_since_visit          => l_msnt_rec.time_since_visit
	   ,p_cycles_since_visit        => l_msnt_rec.cycles_since_visit
	   ,p_time_since_mark           => l_msnt_rec.time_since_mark
	   ,p_cycles_since_mark         => l_msnt_rec.cycles_since_mark
	   ,p_number_of_repairs         => l_msnt_rec.number_of_repairs
	   ,p_serial_attribute_category  => l_msnt_rec.serial_attribute_category
	   ,p_c_attribute1              => l_msnt_rec.c_attribute1
	   ,p_c_attribute2              => l_msnt_rec.c_attribute2
	   ,p_c_attribute3              => l_msnt_rec.c_attribute3
	   ,p_c_attribute4              => l_msnt_rec.c_attribute4
	   ,p_c_attribute5              => l_msnt_rec.c_attribute5
	   ,p_c_attribute6              => l_msnt_rec.c_attribute6
	   ,p_c_attribute7              => l_msnt_rec.c_attribute7
	   ,p_c_attribute8              => l_msnt_rec.c_attribute8
	   ,p_c_attribute9              => l_msnt_rec.c_attribute9
	   ,p_c_attribute10             => l_msnt_rec.c_attribute10
	   ,p_c_attribute11             => l_msnt_rec.c_attribute11
	   ,p_c_attribute12             => l_msnt_rec.c_attribute12
	   ,p_c_attribute13             => l_msnt_rec.c_attribute13
	   ,p_c_attribute14             => l_msnt_rec.c_attribute14
	   ,p_c_attribute15             => l_msnt_rec.c_attribute15
	   ,p_c_attribute16             => l_msnt_rec.c_attribute16
	   ,p_c_attribute17             => l_msnt_rec.c_attribute17
	   ,p_c_attribute18             => l_msnt_rec.c_attribute18
	   ,p_c_attribute19             => l_msnt_rec.c_attribute19
	   ,p_c_attribute20             => l_msnt_rec.c_attribute20
	   ,p_d_attribute1              => l_msnt_rec.d_attribute1
	   ,p_d_attribute2              => l_msnt_rec.d_attribute2
	   ,p_d_attribute3              => l_msnt_rec.d_attribute3
	   ,p_d_attribute4              => l_msnt_rec.d_attribute4
	   ,p_d_attribute5              => l_msnt_rec.d_attribute5
	   ,p_d_attribute6              => l_msnt_rec.d_attribute6
	   ,p_d_attribute7              => l_msnt_rec.d_attribute7
	   ,p_d_attribute8              => l_msnt_rec.d_attribute8
	   ,p_d_attribute9              => l_msnt_rec.d_attribute9
	   ,p_d_attribute10             => l_msnt_rec.d_attribute10
	   ,p_n_attribute1              => l_msnt_rec.n_attribute1
	   ,p_n_attribute2              => l_msnt_rec.n_attribute2
	   ,p_n_attribute3              => l_msnt_rec.n_attribute3
	   ,p_n_attribute4              => l_msnt_rec.n_attribute4
	   ,p_n_attribute5              => l_msnt_rec.n_attribute5
	   ,p_n_attribute6              => l_msnt_rec.n_attribute6
	   ,p_n_attribute7              => l_msnt_rec.n_attribute7
	   ,p_n_attribute8              => l_msnt_rec.n_attribute8
	   ,p_n_attribute9              => l_msnt_rec.n_attribute9
	   ,p_n_attribute10             => l_msnt_rec.n_attribute10
	   );

	 IF (x_return_status <> g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('INSERT_LOT_SERIAL: ERROR - insert_msni Fail');
	    END IF;
	    FND_MESSAGE.SET_NAME('INV','INV_CANNOT_INSERT');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;
	 END IF;

      END LOOP;

   END IF;
   RETURN l_intf_id;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get
       (  p_count  => x_msg_count
	  ,p_data  => x_msg_data );
     IF (l_debug = 1) THEN
	print_debug('INSERT_LOT_SERIAL: Exception occured');
     END IF;
  WHEN OTHERS THEN
     x_return_status:=g_ret_sts_unexp_err;
     fnd_msg_pub.count_and_get
       (  p_count  => x_msg_count
	  ,p_data  => x_msg_data );
     IF (l_debug = 1) THEN
	print_debug('INSERT_LOT_SERIAL: Exception occured');
     END IF;
END insert_lot_serial;

PROCEDURE abort_mmtts(p_move_order_line_id IN NUMBER DEFAULT NULL
		      ,p_lpn_id            IN NUMBER DEFAULT NULL
		      ,p_organization_id   IN NUMBER
		      ,x_return_status OUT nocopy VARCHAR2
		      ,x_msg_count OUT nocopy NUMBER
		      ,x_msg_data OUT nocopy VARCHAR2)
  IS
     l_txn_tmp_id_tb number_tb_type;
     l_error_code VARCHAR2(1);
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN

   IF (l_debug = 1) THEN
      print_debug('ABORT_MMTTS: Entering...');
   END IF;

   x_return_status := g_ret_sts_success;

   IF (p_move_order_line_id IS NOT NULL) THEN

      IF (l_debug = 1) THEN
	 print_debug('ABORT_MMTTS: Move order line ID passed');
      END IF;

      BEGIN
      -- Bug 5231114: Added the condition on transaction_source_type_id and
      -- transaction_action_id for the following combinations:13/12 and 4/27

	 SELECT
	   transaction_temp_id
	 BULK COLLECT INTO
	   l_txn_tmp_id_tb
	 FROM
	   mtl_material_transactions_temp
	 WHERE
	   ( move_order_line_id = p_move_order_line_id AND
	     ( ( transaction_source_type_id = 1 AND
		 transaction_action_id = 27) OR
	       ( transaction_source_type_id = 7 AND
		 transaction_action_id = 12) OR
	       ( transaction_source_type_id = 12 AND
		 transaction_action_id = 27) OR
	       ( transaction_source_type_id = 13 AND
		 transaction_action_id = 12) OR
	       ( transaction_source_type_id = 4 AND
	         transaction_action_id = 27)));
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('ABORT_MMTTS: Unexpected Exception Raised in Bulk Select');
	    END IF;
	    RAISE fnd_api.g_exc_error;
      END;
    ELSIF (p_lpn_id IS NOT NULL) THEN

      IF (l_debug = 1) THEN
	 print_debug('ABORT_MMTTS: Lpn_id passed');
      END IF;

      BEGIN
	 --Bug# 3281512
	 --This query is modified for performance fix
	 -- Bug 5231114: Added the condition on transaction_source_type_id and
         -- transaction_action_id for the following combinations:13/12 and 4/27
	 SELECT
	   mmtt.transaction_temp_id
	 BULK COLLECT INTO
	   l_txn_tmp_id_tb
	 FROM
	   mtl_material_transactions_temp mmtt,
	   mtl_txn_request_lines mtrl
	 WHERE
	   ( ( mmtt.transaction_source_type_id = 1 AND
	       mmtt.transaction_action_id = 27) OR
	     ( mmtt.transaction_source_type_id = 7 AND
	       mmtt.transaction_action_id = 12) OR
	     ( mmtt.transaction_source_type_id = 12 AND
	       mmtt.transaction_action_id = 27) OR
             ( mmtt.transaction_source_type_id = 13 AND
	       mmtt.transaction_action_id = 12) OR
	     ( mmtt.transaction_source_type_id = 4 AND
	       mmtt.transaction_action_id = 27) ) AND
	   mmtt.move_order_line_id = mtrl.line_id AND
	   mmtt.organization_id = p_organization_id AND
	   mtrl.organization_id = p_organization_id AND
	   mtrl.lpn_id IN (SELECT wlpn.lpn_id
			    FROM wms_license_plate_numbers wlpn
			    START WITH wlpn.lpn_id = p_lpn_id
			    CONNECT BY wlpn.parent_lpn_id = PRIOR wlpn.lpn_id ) ;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1 ) THEN
	       print_debug('ABORT_MMTTS: Unexpected Exception Raised in Bulk Select');
	    END IF;
	    RAISE fnd_api.g_exc_error;
      END;
   END IF;

      print_debug('ABORT_MMTTS: count is:'|| l_txn_tmp_id_tb.COUNT);

   -- Abort all mmtts retrieved
   FOR l_index IN 1 .. l_txn_tmp_id_tb.COUNT LOOP
      -- Abort or cancel?

      IF (l_debug = 1) THEN
	 print_debug('ABORT_MMTTS: Calling cancel_op_plan_instance on MMTT:'
		     || l_txn_tmp_id_tb(l_index));
      END IF;

      wms_atf_runtime_pub_apis.cancel_operation_plan
	( p_source_task_id => l_txn_tmp_id_tb(l_index)
	  ,p_activity_type_id   => 1 -- INBOUND
	  ,x_return_status => x_return_status
	  ,x_msg_data      => x_msg_data
	  ,x_msg_count     => x_msg_count
	  ,x_error_code    => l_error_code
	  );
      IF (x_return_status <> g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('ABORT_MMTTS: ERROR -  cancel_op_plan_instance fail with error code ' || l_error_code);
	 END IF;
	 RAISE fnd_api.g_exc_error;
      END IF;

   END LOOP;

   IF (l_debug = 1) THEN
      print_debug('ABORT_MMTTS: Quitting...');
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get
       (  p_count  => x_msg_count
	  ,p_data  => x_msg_data );
     IF (l_debug = 1) THEN
	print_debug('ABORT_MMTTS: Exception occured');
     END IF;

   WHEN OTHERS THEN
     x_return_status:=g_ret_sts_unexp_err;
     fnd_msg_pub.count_and_get
       (  p_count  => x_msg_count
	  ,p_data  => x_msg_data );
     IF (l_debug = 1) THEN
	print_debug('ABORT_MMTTS: Exception occured');
     END IF;
END abort_mmtts;

PROCEDURE pack_unpack_split
  (p_transaction_temp_id IN NUMBER DEFAULT NULL
   ,p_header_id           IN NUMBER DEFAULT NULL
   ,x_return_status       OUT NOCOPY VARCHAR2
   ,x_msg_count           OUT NOCOPY NUMBER
   ,x_msg_data            OUT NOCOPY VARCHAR2
   )
  IS
     l_mo_lines_tb inv_rcv_integration_apis.mo_in_tb_tp;
BEGIN
   pack_unpack_split
     (p_transaction_temp_id => p_transaction_temp_id
      ,p_header_id          => p_header_id
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data
      ,x_mo_lines_tb        => l_mo_lines_tb
      );
END pack_unpack_split;

PROCEDURE pack_unpack_split
  (p_transaction_temp_id IN NUMBER DEFAULT NULL
   ,p_header_id           IN NUMBER DEFAULT NULL
   ,p_call_rcv_tm         IN  VARCHAR2 DEFAULT fnd_api.g_true
   ,p_txn_mode_code       IN  VARCHAR2 DEFAULT g_default_txn_mode
   ,x_return_status       OUT NOCOPY VARCHAR2
   ,x_msg_count           OUT NOCOPY NUMBER
   ,x_msg_data            OUT NOCOPY VARCHAR2
   ,x_mo_lines_tb         OUT nocopy inv_rcv_integration_apis.mo_in_tb_tp
   )
  IS
     CURSOR mol_cur(l_line_id NUMBER) IS
       SELECT
	 line_id
	 ,txn_source_id
       ,reference_id
       ,reference
	,reference_type_code
       ,revision
	 ,lot_number
	 ,inspection_status
       FROM mtl_txn_request_lines
       WHERE line_id = l_line_id;

     --BUG 3634192: Break up the tmp_mmtt_cur cursor into 2.  This
     --is made for performance reasons
     CURSOR tmp_mmtt_cur_by_hdr_id (l_header_id NUMBER) IS
	SELECT
	  mmtt.transaction_temp_id transaction_temp_id,
	  mmtt.organization_id organization_id,
          mmtt.transfer_organization transfer_organization,
          mmtt.inventory_item_id inventory_item_id,
	  mmtt.lpn_id lpn_id,
	  mmtt.content_lpn_id content_lpn_id,
          mmtt.transfer_lpn_id transfer_lpn_id,
          mmtt.subinventory_code subinventory_code,
	  mmtt.transfer_subinventory transfer_subinventory,
	  mmtt.locator_id locator_id,
	  mmtt.transfer_to_location transfer_to_location,
	  mmtt.move_order_line_id move_order_line_id,
	  mmtt.transaction_quantity transaction_quantity,
	  mmtt.primary_quantity primary_quantity,
	  mmtt.transaction_uom transaction_uom,
	  decode(mmtt.inventory_item_id
		 ,-1
		 ,Decode(mmtt.lpn_id
			 ,NULL
			 ,Decode(mmtt.content_lpn_id
				 ,NULL
				 ,'UNKNOWN'
			       ,Decode(mmtt.transfer_lpn_id
				       ,NULL
				       ,'LPN_MOVE'
				       ,'LPN_PACK'))
			 ,Decode(mmtt.content_lpn_id
				 ,NULL
				 ,'UNKNOWN'
				 ,Decode(mmtt.transfer_lpn_id
					 ,NULL
					 ,'LPN_UNPACK'
					 ,'LPN_SPLIT')))
		 ,Decode(mmtt.lpn_id
			 ,NULL
			 ,Decode(mmtt.content_lpn_id
				 ,NULL
				 ,Decode(mmtt.transfer_lpn_id
					 ,NULL
					 ,'UNKNOWN'
					 ,'ITEM_PACK')
				 ,'UNKNOWN')
			 ,Decode(mmtt.content_lpn_id
				 ,NULL
				 ,Decode(mmtt.transfer_lpn_id
					 ,NULL
					 ,'ITEM_UNPACK'
					 ,'ITEM_SPLIT')
				 ,'UNKNOWN'))) txn_type,
	  Decode(mmtt.subinventory_code
		 ,mmtt.transfer_subinventory
		 ,Decode(Nvl(mmtt.locator_id, -1)
			 ,Nvl(mmtt.transfer_to_location, -1)
			 ,0
			 ,1)
		 ,1) sub_loc_changed,
	  msi.lot_control_code lot_control_code,
	  msi.serial_number_control_code serial_control_code,
	  msi.primary_uom_code primary_uom_code,
          -- OPM Convergance
          mmtt.secondary_uom_code secondary_uom_code,
          mmtt.secondary_transaction_quantity secondary_transaction_quantity
          -- OPM Convergance
	FROM
	  mtl_material_transactions_temp mmtt,
	  mtl_system_items msi
	WHERE
	  l_header_id = mmtt.transaction_header_id  AND
	  mmtt.inventory_item_id =  msi.inventory_item_id (+) AND
	  mmtt.organization_id   =  msi.organization_id (+);

     CURSOR tmp_mmtt_cur_by_txn_id(l_txn_id NUMBER) IS
	SELECT
	  mmtt.transaction_temp_id transaction_temp_id,
	  mmtt.organization_id organization_id,
          mmtt.transfer_organization transfer_organization,
          mmtt.inventory_item_id inventory_item_id,
	  mmtt.lpn_id lpn_id,
	  mmtt.content_lpn_id content_lpn_id,
          mmtt.transfer_lpn_id transfer_lpn_id,
          mmtt.subinventory_code subinventory_code,
	  mmtt.transfer_subinventory transfer_subinventory,
	  mmtt.locator_id locator_id,
	  mmtt.transfer_to_location transfer_to_location,
	  mmtt.move_order_line_id move_order_line_id,
	  mmtt.transaction_quantity transaction_quantity,
	  mmtt.primary_quantity primary_quantity,
	  mmtt.transaction_uom transaction_uom,
	  decode(mmtt.inventory_item_id
		 ,-1
		 ,Decode(mmtt.lpn_id
			 ,NULL
			 ,Decode(mmtt.content_lpn_id
				 ,NULL
				 ,'UNKNOWN'
			       ,Decode(mmtt.transfer_lpn_id
				       ,NULL
				       ,'LPN_MOVE'
				       ,'LPN_PACK'))
			 ,Decode(mmtt.content_lpn_id
				 ,NULL
				 ,'UNKNOWN'
				 ,Decode(mmtt.transfer_lpn_id
					 ,NULL
					 ,'LPN_UNPACK'
					 ,'LPN_SPLIT')))
		 ,Decode(mmtt.lpn_id
			 ,NULL
			 ,Decode(mmtt.content_lpn_id
				 ,NULL
				 ,Decode(mmtt.transfer_lpn_id
					 ,NULL
					 ,'UNKNOWN'
					 ,'ITEM_PACK')
				 ,'UNKNOWN')
			 ,Decode(mmtt.content_lpn_id
				 ,NULL
				 ,Decode(mmtt.transfer_lpn_id
					 ,NULL
					 ,'ITEM_UNPACK'
					 ,'ITEM_SPLIT')
				 ,'UNKNOWN'))) txn_type,
	  Decode(mmtt.subinventory_code
		 ,mmtt.transfer_subinventory
		 ,Decode(Nvl(mmtt.locator_id, -1)
			 ,Nvl(mmtt.transfer_to_location, -1)
			 ,0
			 ,1)
		 ,1) sub_loc_changed,
	  msi.lot_control_code lot_control_code,
	  msi.serial_number_control_code serial_control_code,
	 msi.primary_uom_code primary_uom_code,
          -- OPM Convergance
          mmtt.secondary_uom_code secondary_uom_code,
          mmtt.secondary_transaction_quantity secondary_transaction_quantity
          -- OPM Convergance
	FROM
	  mtl_material_transactions_temp mmtt,
	  mtl_system_items msi
	WHERE
	  l_txn_id = mmtt.transaction_temp_id AND
	  mmtt.inventory_item_id =  msi.inventory_item_id (+) AND
	  mmtt.organization_id   =  msi.organization_id (+);

     l_tmp_mmtt_rec tmp_mmtt_cur_by_hdr_id%ROWTYPE;

     l_group_id NUMBER := NULL;
     l_mol_rec mol_cur%ROWTYPE;
     l_old_intf_id NUMBER := NULL;
     l_new_intf_id NUMBER := NULL;
     l_mo_splt_tb inv_rcv_integration_apis.mo_in_tb_tp;
     l_out_mo_splt_tb inv_rcv_integration_apis.mo_in_tb_tp;
     l_rti_tb inv_rcv_integration_apis.child_rec_tb_tp;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_progress VARCHAR2(10) := '0.0';
     l_call_rm BOOLEAN := FALSE;
     l_txn_mode_code VARCHAR2(25);
     l_first_time NUMBER := 0;
     l_xfer_lpn_loaded NUMBER := 0;
     l_uom_to_insert VARCHAR2(3);
     l_qty_to_insert NUMBER;

     TYPE number_tb_tp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     l_mmtt_ids number_tb_tp;
     l_mmtts_count NUMBER := 0;

--    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
--    x_msg_count NUMBER;
--     x_msg_data VARCHAR2(2400);

BEGIN

   SAVEPOINT pack_unpack_split_pub;

   IF (l_debug = 1) THEN
      print_debug('PACK_UNPACK_SPLIT: Entering...');
      print_debug('                   p_transaction_temp_id => '||p_transaction_temp_id);
      print_debug('                   p_header_id           => '||p_header_id);
      print_debug('                   p_call_rcv_tm         => '||p_call_rcv_tm);
   END IF;

   x_return_status := g_ret_sts_success;

   IF (p_transaction_temp_id IS NOT NULL) THEN
      OPEN tmp_mmtt_cur_by_txn_id(p_transaction_temp_id);
    ELSIF (p_header_id IS NOT NULL) THEN
      OPEN tmp_mmtt_cur_by_hdr_id(p_header_id);
    ELSE
      l_progress := '0.0.1';
      print_debug('PACK_UNPACK_SPLIT: Invalid parameter passed to API!');
      RAISE fnd_api.g_exc_error;
   END IF;

   LOOP
      IF (p_transaction_temp_id IS NOT NULL) THEN
	 FETCH tmp_mmtt_cur_by_txn_id INTO l_tmp_mmtt_rec;
	 EXIT WHEN tmp_mmtt_cur_by_txn_id%notfound;
       ELSE
	 FETCH tmp_mmtt_cur_by_hdr_id INTO l_tmp_mmtt_rec;
	 EXIT WHEN tmp_mmtt_cur_by_hdr_id%notfound;
      END IF;

      l_progress := '0.1';
      IF (l_debug = 1) THEN
	 print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Temp MMTT FETCHED');
	 print_debug('  l_tmp_mmtt_rec.transaction_temp_id: '||l_tmp_mmtt_rec.transaction_temp_id);
	 print_debug('  l_tmp_mmtt_rec.organization_id    : '||l_tmp_mmtt_rec.organization_id);
	 print_debug('  l_tmp_mmtt_rec.transfer_organization_id:: '||l_tmp_mmtt_rec.transfer_organization);
	 print_debug('  l_tmp_mmtt_rec.inventory_item_id  : '||l_tmp_mmtt_rec.inventory_item_id);
	 print_debug('  l_tmp_mmtt_rec.lpn_id             : '||l_tmp_mmtt_rec.lpn_id);
	 print_debug('  l_tmp_mmtt_rec.content_lpn_id     : '||l_tmp_mmtt_rec.content_lpn_id);
	 print_debug('  l_tmp_mmtt_rec.transfer_lpn_id    : '||l_tmp_mmtt_rec.transfer_lpn_id);
	 print_debug('  l_tmp_mmtt_rec.subinventory_code  : '||l_tmp_mmtt_rec.subinventory_code);
	 print_debug('  l_tmp_mmtt_rec.transfer_subinventory : '||l_tmp_mmtt_rec.transfer_subinventory);
	 print_debug('  l_tmp_mmtt_rec.locator_id         : '||l_tmp_mmtt_rec.locator_id);
	 print_debug('  l_tmp_mmtt_rec.transfer_to_loc_id : '||l_tmp_mmtt_rec.transfer_to_location);
	 print_debug('  l_tmp_mmtt_rec.move_order_line_id : '||l_tmp_mmtt_rec.move_order_line_id);
	 print_debug('  l_tmp_mmtt_rec.transaction_quantity: '||l_tmp_mmtt_rec.transaction_quantity);
	 print_debug('  l_tmp_mmtt_rec.primary_quantity   : '||l_tmp_mmtt_rec.primary_quantity);
	 print_debug('  l_tmp_mmtt_rec.txn_type           : '||l_tmp_mmtt_rec.txn_type);
	 print_debug('  l_tmp_mmtt_rec.sub_loc_changed    : '||l_tmp_mmtt_rec.sub_loc_changed);
         -- OPM Convergance
         print_debug('  l_tmp_mmtt_rec.secondary_transaction_quantity: '||l_tmp_mmtt_rec.secondary_transaction_quantity);
         print_debug('  l_tmp_mmtt_rec.secondary_uom_code: '||l_tmp_mmtt_rec.secondary_uom_code);
         -- OPM Convergance
      END IF;

      -- Initialize loop variables
      l_mo_splt_tb.DELETE;

      -- Set up array for bulk delete later after the loop
      l_mmtts_count := l_mmtts_count + 1;
      l_mmtt_ids(l_mmtts_count) := l_tmp_mmtt_rec.transaction_temp_id;

      l_progress := '0.2';

      IF (l_tmp_mmtt_rec.txn_type = 'LPN_MOVE') THEN
	 l_progress := '1.0';
	 IF (l_debug = 1) THEN
	    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') LPN MOVE');
	 END IF;

	 IF (l_tmp_mmtt_rec.sub_loc_changed = 1) THEN
	    l_progress := '1.1.0';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Sub/Loc changed');
	    END IF;

	    abort_mmtts(p_lpn_id => l_tmp_mmtt_rec.content_lpn_id
			,p_organization_id          => l_tmp_mmtt_rec.organization_id
			,x_return_status            => x_return_status
			,x_msg_count                => x_msg_count
			,x_msg_data                 => x_msg_data
			);
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: abort_mmtts failed');
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS','WMS_TASK_DELETE_ERROR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;
	    l_progress := '1.1.1';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') MMTTs successfully aborted');
	    END IF;

	    IF (l_first_time <> 1) THEN
	       l_first_time := 1;
	    END IF;

	    l_group_id :=
	      wms_putaway_utils.insert_rti
	         (p_from_org => l_tmp_mmtt_rec.organization_id
		  ,p_lpn_id => l_tmp_mmtt_rec.content_lpn_id
		  ,p_to_org => l_tmp_mmtt_rec.organization_id
		  ,p_to_sub => l_tmp_mmtt_rec.transfer_subinventory
		  ,p_to_loc => l_tmp_mmtt_rec.transfer_to_location
		  ,p_xfer_lpn_id  => l_tmp_mmtt_rec.content_lpn_id
		  ,p_first_time   => l_first_time
		  ,p_mobile_txn   => 'Y'
		  ,p_txn_mode_code => p_txn_mode_code
		  ,x_return_status =>  x_return_status
		  ,x_msg_count     =>  x_msg_count
		  ,x_msg_data      =>  x_msg_data
		  );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - insert_rti Fail');
	       END IF;
	       FND_MESSAGE.SET_NAME('INV','INV_CANNOT_INSERT');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '1.1.2';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') RTI inserted');
	       print_debug('  Calling insert_wlpni(');
	       print_debug('  p_organization_id => '||l_tmp_mmtt_rec.organization_id);
	       print_debug('  p_lpn_id          => '||l_tmp_mmtt_rec.content_lpn_id);
	       print_debug('  p_license_plate_number => ');
	       print_debug('  p_lpn_group_id    => '|| l_group_id ||')');
	    END IF;

	    inv_rcv_integration_apis.insert_wlpni
	      (p_api_version    =>  1.0
	       ,x_return_status =>  x_return_status
	       ,x_msg_count     =>  x_msg_count
	       ,x_msg_data      =>  x_msg_data
	       ,p_organization_id => l_tmp_mmtt_rec.organization_id
	       ,p_lpn_id          => l_tmp_mmtt_rec.content_lpn_id
	       ,p_license_plate_number =>  NULL
	       ,p_lpn_group_id    =>   l_group_id
	       ,p_parent_lpn_id   =>   NULL
	       );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - insert_wlpni Fail');
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '1.1.3';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') WLPNI successfully inserted');
	    END IF;

	    -- Signal call to TM
	    l_call_rm := TRUE;
	  ELSE
	    l_progress := '1.2.0';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: LPN Move and No location changed.' ||
			   ' No action required, return success');
	    END IF;
	    RETURN;
	 END IF;
       ELSIF (l_tmp_mmtt_rec.txn_type = 'LPN_PACK') THEN
	 l_progress := '2.0';
	 IF (l_debug = 1) THEN
	    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') LPN PACK');
	 END IF;

	 IF (l_tmp_mmtt_rec.sub_loc_changed = 1) THEN
	    l_progress := '2.1.0';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Sub/Loc changed');
	    END IF;

	    abort_mmtts
	      (p_lpn_id => l_tmp_mmtt_rec.content_lpn_id
	       ,p_organization_id           =>   l_tmp_mmtt_rec.organization_id
	       ,x_return_status            =>   x_return_status
	       ,x_msg_count                =>   x_msg_count
	       ,x_msg_data                 =>   x_msg_data
	       );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - Abort MMTTs Fail');
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS','WMS_TASK_DELETE_ERROR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '2.1.1';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') MMTTs aborted sucessfully');
	    END IF;

	    IF (l_first_time <> 1) THEN
	       l_first_time := 1;
	    END IF;
	    l_group_id :=
	      wms_putaway_utils.insert_rti
	        (p_from_org  => l_tmp_mmtt_rec.organization_id
		 ,p_lpn_id   => l_tmp_mmtt_rec.content_lpn_id
		 ,p_to_org   => l_tmp_mmtt_rec.organization_id
		 ,p_to_sub   => l_tmp_mmtt_rec.transfer_subinventory
		 ,p_to_loc   => l_tmp_mmtt_rec.transfer_to_location
		 ,p_xfer_lpn_id  => l_tmp_mmtt_rec.content_lpn_id
		 ,p_first_time   => l_first_time
		 ,p_mobile_txn   => 'Y'
		 ,p_txn_mode_code => p_txn_mode_code
		 ,x_return_status =>  x_return_status
		 ,x_msg_count     =>  x_msg_count
		 ,x_msg_data      =>  x_msg_data
		 );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('ERROR: insert_rti Fail');
	       END IF;
	       FND_MESSAGE.SET_NAME('INV','INV_CANNOT_INSERT');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '2.1.2';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: Calling insert_wlpni');
	       print_debug('      (p_organization_id => '||l_tmp_mmtt_rec.organization_id);
	       print_debug('       p_lpn_id          => '||l_tmp_mmtt_rec.content_lpn_id);
	       print_debug('       p_license_plate_number => ' );
	       print_debug('       p_lpn_group_id    => ' || l_group_id);
	       print_debug('       p_parent_lpn_id   => ' || l_tmp_mmtt_rec.transfer_lpn_id);
	    END IF;

	    inv_rcv_integration_apis.insert_wlpni
	      (p_api_version    =>  1.0
	       ,x_return_status =>  x_return_status
	       ,x_msg_count     =>  x_msg_count
	       ,x_msg_data      =>  x_msg_data
	       ,p_organization_id => l_tmp_mmtt_rec.organization_id
	       ,p_lpn_id          => l_tmp_mmtt_rec.content_lpn_id
	       ,p_license_plate_number =>  NULL
	       ,p_lpn_group_id    =>   l_group_id
	       ,p_parent_lpn_id   =>   l_tmp_mmtt_rec.transfer_lpn_id
	       );

	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - Insert WLPN Fail');
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '2.1.3';

	    -- Set flag to call to TM
	    l_call_rm := TRUE;

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') WLPNI inserted successfully');
	    END IF;

	  ELSE
	    l_progress := '2.2.0';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') NO Sub/Loc changed');
	       print_debug('    Calling packunpack_container(');
	       print_debug('      p_content_lpn_id    => '||l_tmp_mmtt_rec.content_lpn_id);
	       print_debug('      p_lpn_id            => '||l_tmp_mmtt_rec.transfer_lpn_id);
	       print_debug('      p_operation         => '||1);
	       print_debug('      p_organization_id   => '||l_tmp_mmtt_rec.organization_id);
	    END IF;

	    -- Modify LPN Status
	    wms_container_pvt.modify_lpn_wrapper
	      ( p_api_version    =>  1.0
		,x_return_status =>  x_return_status
		,x_msg_count     =>  x_msg_count
		,x_msg_data      =>  x_msg_data
		,p_lpn_id        =>  l_tmp_mmtt_rec.transfer_lpn_id
		,p_subinventory =>	l_tmp_mmtt_rec.transfer_subinventory
		,p_locator_id    =>  l_tmp_mmtt_rec.transfer_to_location
		,p_lpn_context   =>  3 --RCV
		);
	    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: modify_lpn failed');
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    wms_container_pvt.packunpack_container
	      (p_api_version       =>   1.0
	       ,p_content_lpn_id    =>   l_tmp_mmtt_rec.content_lpn_id
	       ,p_lpn_id           =>   l_tmp_mmtt_rec.transfer_lpn_id
	       ,p_operation        =>   1 /* Pack */
	       ,p_organization_id  =>   l_tmp_mmtt_rec.organization_id
	       ,x_return_status    =>   x_return_status
	       ,x_msg_count        =>   x_msg_count
	       ,x_msg_data         =>   x_msg_data
	       );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - packunpack_container Fail');
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS','WMS_CONT_PACK_UPDATE_ERR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;


	    l_progress := '2.2.1';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') packunpack_container successful');
	    END IF;

	 END IF;
       ELSIF (l_tmp_mmtt_rec.txn_type = 'LPN_UNPACK') THEN
	 l_progress := '3.0';
	 IF (l_debug = 1) THEN
	    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') LPN UNPACK');
	 END IF;

	 IF (l_tmp_mmtt_rec.sub_loc_changed = 1) THEN
	    l_progress := '3.1.0';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Sub/Loc changed');
	    END IF;

	    abort_mmtts
	      (p_lpn_id => l_tmp_mmtt_rec.content_lpn_id
	       ,p_organization_id          =>   l_tmp_mmtt_rec.organization_id
	       ,x_return_status            =>   x_return_status
	       ,x_msg_count                =>   x_msg_count
	       ,x_msg_data                 =>   x_msg_data
	       );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - abort_mmtts Fail');
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS','WMS_TASK_DELETE_ERROR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '3.1.1';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') MMTTs aborted successfully');
	    END IF;

	    IF (l_first_time <> 1) THEN
	       l_first_time := 1;
	    END IF;
	    l_group_id :=
	      wms_putaway_utils.insert_rti
	         (p_from_org => l_tmp_mmtt_rec.organization_id
		  ,p_lpn_id => l_tmp_mmtt_rec.content_lpn_id
		  ,p_to_org   => l_tmp_mmtt_rec.organization_id
		  ,p_to_sub => l_tmp_mmtt_rec.transfer_subinventory
		  ,p_to_loc => l_tmp_mmtt_rec.transfer_to_location
		  ,p_xfer_lpn_id  => l_tmp_mmtt_rec.content_lpn_id
		  ,p_first_time   => l_first_time
		  ,p_mobile_txn   => 'Y'
		  ,p_txn_mode_code => p_txn_mode_code
		  ,x_return_status =>  x_return_status
		  ,x_msg_count     =>  x_msg_count
		  ,x_msg_data      =>  x_msg_data
		  );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('ERROR: insert_rti Fail');
	       END IF;
	       FND_MESSAGE.SET_NAME('INV','INV_CANNOT_INSERT');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '3.1.2';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') RTI inserted successfully');
	    END IF;

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: Calling insert_wlpni');
	       print_debug('      (p_organization_id => '||l_tmp_mmtt_rec.organization_id);
	       print_debug('       p_lpn_id          => '||l_tmp_mmtt_rec.content_lpn_id);
	       print_debug('       p_license_plate_number => ' );
	       print_debug('       p_lpn_group_id    => ' || l_group_id);
	       print_debug('       p_parent_lpn_id   =>   )' );
	    END IF;

	    inv_rcv_integration_apis.insert_wlpni
	      (p_api_version    =>  1.0
	       ,x_return_status =>  x_return_status
	       ,x_msg_count     =>  x_msg_count
	       ,x_msg_data      =>  x_msg_data
	       ,p_organization_id => l_tmp_mmtt_rec.organization_id
	       ,p_lpn_id          => l_tmp_mmtt_rec.content_lpn_id
	       ,p_license_plate_number =>  NULL
	       ,p_lpn_group_id    =>   l_group_id
	       ,p_parent_lpn_id   =>   NULL
	       );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - insert_wlpni Fail');
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '3.1.3';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') WLPNI inserted successfully');
	    END IF;

	    -- Set flag to call to TM
	    l_call_rm := TRUE;
	  ELSE
	    l_progress := '3.2.0';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') No Sub/Loc changed');
	       print_debug('    Calling packunpack_container(');
	       print_debug('      p_content_lpn_id    => '||l_tmp_mmtt_rec.content_lpn_id);
	       print_debug('      p_lpn_id            => '||l_tmp_mmtt_rec.lpn_id);
	       print_debug('      p_operation         => '||2);
	       print_debug('      p_organization_id   => '||l_tmp_mmtt_rec.organization_id);
	    END IF;

	    wms_container_pvt.packunpack_container
	      (p_api_version       =>   1.0
	       ,p_content_lpn_id    =>   l_tmp_mmtt_rec.content_lpn_id
	       ,p_lpn_id           =>   l_tmp_mmtt_rec.lpn_id
	       ,p_operation        =>   2 /* Unpack */
	       ,p_organization_id  =>   l_tmp_mmtt_rec.organization_id
	       ,x_return_status    =>   x_return_status
	       ,x_msg_count        =>   x_msg_count
	       ,x_msg_data         =>   x_msg_data
	       );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: packunpack_container Fail');
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS','WMS_CONT_UNPACK_UPDATE_ERR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '3.2.1';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') packunpack_container sucessful');
	    END IF;

	 END IF;
       ELSIF (l_tmp_mmtt_rec.txn_type = 'LPN_SPLIT') THEN
	 l_progress := '4.0';
	 IF (l_debug = 1) THEN
	    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') LPN SPLIT');
	 END IF;

	 IF (l_tmp_mmtt_rec.sub_loc_changed = 1) THEN
	    l_progress := '4.1.0';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Sub/Loc changed');
	    END IF;

	    abort_mmtts(p_lpn_id => l_tmp_mmtt_rec.content_lpn_id
			,p_organization_id          =>   l_tmp_mmtt_rec.organization_id
			,x_return_status            =>   x_return_status
			,x_msg_count                =>   x_msg_count
			,x_msg_data                 =>   x_msg_data
			);
	    IF (x_return_status <> g_ret_sts_success) THEN
	       print_debug('PACK_UNPACK_SPLIT: ERROR - abort_mmtts Fail');
	       FND_MESSAGE.SET_NAME('WMS','WMS_TASK_DELETE_ERROR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '4.1.1';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') MMTTs aborted successfully');
	    END IF;

	    IF (l_first_time <> 1) THEN
	       l_first_time := 1;
	    END IF;
	    l_group_id :=
	      wms_putaway_utils.insert_rti
	         (p_from_org => l_tmp_mmtt_rec.organization_id
		  ,p_lpn_id => l_tmp_mmtt_rec.content_lpn_id
		  ,p_to_org   => l_tmp_mmtt_rec.organization_id
		  ,p_to_sub => l_tmp_mmtt_rec.transfer_subinventory
		  ,p_to_loc => l_tmp_mmtt_rec.transfer_to_location
		  ,p_xfer_lpn_id  => l_tmp_mmtt_rec.content_lpn_id
		  ,p_first_time   => l_first_time
		  ,p_mobile_txn   => 'Y'
		  ,p_txn_mode_code => p_txn_mode_code
		  ,x_return_status =>  x_return_status
		  ,x_msg_count     =>  x_msg_count
		  ,x_msg_data      =>  x_msg_data
		  );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1 ) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - insert_rti FAIL');
	       END IF;
	       FND_MESSAGE.SET_NAME('INV','INV_CANNOT_INSERT');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '4.1.2';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
			   ') RTIs inserted successfully');
	    END IF;

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: Calling insert_wlpni');
	       print_debug('      (p_organization_id => '||l_tmp_mmtt_rec.organization_id);
	       print_debug('       p_lpn_id          => '||l_tmp_mmtt_rec.content_lpn_id);
	       print_debug('       p_license_plate_number => ' );
	       print_debug('       p_lpn_group_id    => ' || l_group_id);
	       print_debug('       p_parent_lpn_id   => ' || l_tmp_mmtt_rec.transfer_lpn_id);
	    END IF;

	    inv_rcv_integration_apis.insert_wlpni
	      (p_api_version    =>  1.0
	       ,x_return_status =>  x_return_status
	       ,x_msg_count     =>  x_msg_count
	       ,x_msg_data      =>  x_msg_data
	       ,p_organization_id => l_tmp_mmtt_rec.organization_id
	       ,p_lpn_id          => l_tmp_mmtt_rec.content_lpn_id
	       ,p_license_plate_number =>  NULL
	       ,p_lpn_group_id    =>   l_group_id
	       ,p_parent_lpn_id   =>   l_tmp_mmtt_rec.transfer_lpn_id
	       );

	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - insert_wlpni FAIL');
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '4.1.3';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') WLPNIs inserted successfully');
	    END IF;

	    -- Set flag to call to TM
	    l_call_rm := TRUE;
	  ELSE
	    l_progress := '4.2.0';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') NO Sub/Loc changed');
	       print_debug('    Calling packunpack_container(');
	       print_debug('      p_content_lpn_id    => '||l_tmp_mmtt_rec.content_lpn_id);
	       print_debug('      p_lpn_id            => '||l_tmp_mmtt_rec.lpn_id);
	       print_debug('      p_operation         => '||2);
	       print_debug('      p_organization_id   => '||l_tmp_mmtt_rec.organization_id);
	    END IF;

	    wms_container_pvt.packunpack_container
	      (p_api_version       =>   1.0
	       ,p_content_lpn_id    =>   l_tmp_mmtt_rec.content_lpn_id
	       ,p_lpn_id           =>   l_tmp_mmtt_rec.lpn_id
	       ,p_operation        =>   2 /* Unpack */
	       ,p_organization_id  =>   l_tmp_mmtt_rec.organization_id
	       ,x_return_status    =>   x_return_status
	       ,x_msg_count        =>   x_msg_count
	       ,x_msg_data         =>   x_msg_data
	       );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - packunpack_container Fail');
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS','WMS_CONT_UNPACK_UPDATE_ERR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '4.2.1';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') packunpack_container UNPACK succesful');
	       print_debug('    Calling packunpack_container(');
	       print_debug('      p_content_lpn_id    => '||l_tmp_mmtt_rec.content_lpn_id);
	       print_debug('      p_lpn_id            => '||l_tmp_mmtt_rec.transfer_lpn_id);
	       print_debug('      p_operation         => '||1);
	       print_debug('      p_organization_id   => '||l_tmp_mmtt_rec.organization_id);
	    END IF;

	    -- Modify LPN Status
	    wms_container_pvt.modify_lpn_wrapper
	      ( p_api_version    =>  1.0
		,x_return_status =>  x_return_status
		,x_msg_count     =>  x_msg_count
		,x_msg_data      =>  x_msg_data
		,p_lpn_id        =>  l_tmp_mmtt_rec.transfer_lpn_id
		,p_subinventory  =>  l_tmp_mmtt_rec.transfer_subinventory
		,p_locator_id    =>  l_tmp_mmtt_rec.transfer_to_location
		,p_lpn_context   =>  3 --RCV
		);
	    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: modify_lpn failed');
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    wms_container_pvt.packunpack_container
	      (p_api_version       =>   '1.0' --??
	       ,p_content_lpn_id    =>   l_tmp_mmtt_rec.content_lpn_id
	       ,p_lpn_id           =>   l_tmp_mmtt_rec.transfer_lpn_id
	       ,p_operation        =>   1 /* pack */
	       ,p_organization_id  =>   l_tmp_mmtt_rec.organization_id
	       ,x_return_status    =>   x_return_status
	       ,x_msg_count        =>   x_msg_count
	       ,x_msg_data         =>   x_msg_data
	       );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR: packunpack_container Fail', 9);
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS','WMS_CONT_PACK_UPDATE_ERR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '2.2.1';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') packunpack_container successful');
	    END IF;



	 END IF;
       ELSIF (l_tmp_mmtt_rec.txn_type = 'ITEM_PACK') THEN
	 l_progress := '5.0';
	 IF (l_debug = 1) THEN
	    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Item Pack');
	 END IF;

	 abort_mmtts(p_move_order_line_id=>l_tmp_mmtt_rec.move_order_line_id
		     ,p_organization_id  =>   l_tmp_mmtt_rec.organization_id
		     ,x_return_status            =>   x_return_status
		     ,x_msg_count                =>   x_msg_count
		     ,x_msg_data                 =>   x_msg_data
		     );
	 IF (x_return_status <> g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ERROR: abort_mmtts FAIL', 9);
	    END IF;
	    FND_MESSAGE.SET_NAME('WMS','WMS_TASK_DELETE_ERROR');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 l_mo_splt_tb(1).prim_qty := l_tmp_mmtt_rec.primary_quantity;

	 IF (l_debug = 1) THEN
	    print_debug('PACK_UNPACK_SPLIT: MMTTs aborted');
	    print_debug('PACK_UNPACK_SPLIT: Calling split_mo(');
	    print_debug('   p_orig_mol_id            => ' || l_tmp_mmtt_rec.move_order_line_id);
	    print_debug('   p_mo_splt_tb(1).prim_qty => ' || l_mo_splt_tb(1).prim_qty);
	 END IF;

	 inv_rcv_integration_apis.split_mo
	   (p_orig_mol_id    => l_tmp_mmtt_rec.move_order_line_id
	    ,p_mo_splt_tb     => l_mo_splt_tb
	    ,x_return_status => x_return_status
	    ,x_msg_count     => x_msg_count
	    ,x_msg_data      => x_msg_data
	    );
	 IF (x_return_status <> g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ERROR - split_mo FAIL', 9);
	    END IF;
	    fnd_message.set_name('INV', 'INV_SPLIT_MO_ERR');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 IF (l_tmp_mmtt_rec.move_order_line_id <> l_mo_splt_tb(1).line_id) THEN
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: Unmarking wms_process_flag FOR line: '
			   ||l_tmp_mmtt_rec.move_order_line_id);
	    END IF;

	    --Update the MOL with unused qty to 1, because the TM will only
	    --update wms_process_flag for the marked lines and not all
	    --lines in a LPN as done in 11.5.10
	    UPDATE mtl_txn_request_lines
	      SET  wms_process_flag = 1
	      WHERE line_id = l_tmp_mmtt_rec.move_order_line_id;
	 END IF;

	 l_progress := '5.1';
	 IF (l_debug = 1) THEN
	    print_debug('PACK_UNPACK_SPLIT: Calling insert_lot_serial(');
	    print_debug('     p_transaction_temp_id => '||l_tmp_mmtt_rec.transaction_temp_id);
	    print_debug('     p_organization_id     => '||l_tmp_mmtt_rec.organization_id);
	    print_debug('     p_item_id             => '||l_tmp_mmtt_rec.inventory_item_id);
	 END IF;

	 l_old_intf_id :=
	   insert_lot_serial
	   (p_transaction_temp_id   => l_tmp_mmtt_rec.transaction_temp_id
	    ,p_organization_id      => l_tmp_mmtt_rec.organization_id
	    ,p_item_id              => l_tmp_mmtt_rec.inventory_item_id
	    ,x_return_status        => x_return_status
	    ,x_msg_count            => x_msg_count
	    ,x_msg_data             => x_msg_data
	    );

	 IF (x_return_status <> g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ERROR: insert_lot_serial FAIL',
			   9);
	    END IF;
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 l_progress := '5.2';

	 IF (l_debug = 1) THEN
	    print_debug('PACK_UNPACK_SPLIT: insert_lot_serial returns successfully WITH interface id = ' || l_old_intf_id);
	 END IF;

	 /* Retrieve MOL */

	 OPEN mol_cur(l_mo_splt_tb(1).line_id);
	 FETCH mol_cur INTO l_mol_rec;
	 CLOSE mol_cur;

	 l_progress := '5.3';

	 IF (l_debug = 1) THEN
	    print_debug('PACK_UNPACK_SPLIT: Calling Match_transfer_rcvtxn_rec(');
	    print_debug('     p_organization_id     => '||l_tmp_mmtt_rec.organization_id);
	    print_debug('     p_parent_txn_id       => '||l_mol_rec.txn_source_id);
	    print_debug('     p_reference_id        => '||l_mol_rec.reference_id);
	    print_debug('     p_reference           => '||l_mol_rec.reference);
	    print_debug('     p_reference_type_code => '||l_mol_rec.reference_type_code);
	    print_debug('     p_item_id             => '||l_tmp_mmtt_rec.inventory_item_id);
	    print_debug('     p_revision            => '||l_mol_rec.revision);
	    print_debug('     p_subinventory_code   => '||l_tmp_mmtt_rec.transfer_subinventory);
	    print_debug('     p_locator_id          => '||l_tmp_mmtt_rec.transfer_to_location);
	    print_debug('     p_transfer_quantity   => '||l_tmp_mmtt_rec.transaction_quantity);
	    print_debug('     p_transfer_uom_code   => '||l_tmp_mmtt_rec.transaction_uom);
	    print_debug('     p_lot_control_code    => '||l_tmp_mmtt_rec.lot_control_code);
	    print_debug('     p_serial_control_code => '||l_tmp_mmtt_rec.serial_control_code);
	    print_debug('     p_original_rti_id     => '||l_old_intf_id);
	    print_debug('     p_original_temp_id    => ');
	    print_debug('     p_lot_number          => '||l_mol_rec.lot_number);
	    print_debug('     p_lpn_id              => '||l_tmp_mmtt_rec.lpn_id);
	    print_debug('     p_transfer_lpn_id     => '||l_tmp_mmtt_rec.transfer_lpn_id);
	    print_debug('     p_inspection_status   => '||l_mol_rec.inspection_status);

            -- OPM Covergance
            print_debug(' p_sec_transfer_quantity   => '||l_tmp_mmtt_rec.secondary_transaction_quantity);
	    print_debug(' p_sec_transfer_uom_code   => '||l_tmp_mmtt_rec.secondary_uom_code);
            -- OPM Covergance
	    print_debug(' p_inspection_status       => '||l_mol_rec.inspection_status);
	    print_debug(' p_from_sub                => '||l_tmp_mmtt_rec.subinventory_code);
	    print_debug(' p_from_loc                => '||l_tmp_mmtt_rec.locator_id);
	 END IF;

	 inv_rcv_std_transfer_apis.Match_transfer_rcvtxn_rec
	   ( x_return_status         =>  x_return_status
	     ,x_msg_count            =>  x_msg_count
	     ,x_msg_data             =>  x_msg_data
	     ,p_organization_id      =>  l_tmp_mmtt_rec.organization_id
	     ,p_parent_txn_id       =>  l_mol_rec.txn_source_id
	     ,p_reference_id        =>  l_mol_rec.reference_id
	     ,p_reference           =>  l_mol_rec.reference
	     ,p_reference_type_code =>  l_mol_rec.reference_type_code
	     ,p_item_id             =>  l_tmp_mmtt_rec.inventory_item_id
	     ,p_revision            =>  l_mol_rec.revision  --??
	     ,p_subinventory_code   =>  l_tmp_mmtt_rec.transfer_subinventory
	     ,p_locator_id          =>  l_tmp_mmtt_rec.transfer_to_location
	     ,p_transfer_quantity   =>  l_tmp_mmtt_rec.transaction_quantity
	     ,p_transfer_uom_code   =>  l_tmp_mmtt_rec.transaction_uom
	     ,p_lot_control_code    =>  l_tmp_mmtt_rec.lot_control_code
	     ,p_serial_control_code =>  l_tmp_mmtt_rec.serial_control_code
	     ,p_original_rti_id     =>  l_old_intf_id
	   ,p_original_temp_id    =>  NULL
	   ,p_lot_number          =>  l_mol_rec.lot_number
	   ,p_lpn_id              =>  l_tmp_mmtt_rec.lpn_id
	   ,p_transfer_lpn_id     =>  l_tmp_mmtt_rec.transfer_lpn_id
           -- OPM Convergance
           ,p_sec_transfer_quantity => l_tmp_mmtt_rec.secondary_transaction_quantity
           ,p_sec_transfer_uom_code => l_tmp_mmtt_rec.secondary_uom_code
	   ,p_primary_uom_code      => l_tmp_mmtt_rec.primary_uom_code
           -- OPM Convergance
	   ,p_inspection_status     => l_mol_rec.inspection_status
	   ,p_from_sub              => l_tmp_mmtt_rec.subinventory_code
	   ,p_from_loc              => l_tmp_mmtt_rec.locator_id
	   );
	 IF (x_return_status <> g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ERROR - Match_transfer_rcvtxn_rec FAIL', 9);
	    END IF;
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 l_progress := '5.4';

	 -- Set flag to call to TM
	 l_call_rm := TRUE;

       ELSIF (l_tmp_mmtt_rec.txn_type = 'ITEM_UNPACK') THEN
	 l_progress := '6.0';
	 IF (l_debug = 1) THEN
	    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Item Unpack');
	 END IF;

	 IF (l_tmp_mmtt_rec.sub_loc_changed = 1) THEN
	    l_progress := '6.1.0';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Sub/Loc changed');
	    END IF;

	    l_mo_splt_tb(1).prim_qty := l_tmp_mmtt_rec.primary_quantity;

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: Calling split_mo(');
	       print_debug('   p_orig_mol_id            => ' || l_tmp_mmtt_rec.move_order_line_id);
	       print_debug('   p_mo_splt_tb(1).prim_qty => ' || l_mo_splt_tb(1).prim_qty);
	    END IF;

	    inv_rcv_integration_apis.split_mo
	      (p_orig_mol_id    => l_tmp_mmtt_rec.move_order_line_id
	       ,p_mo_splt_tb     => l_mo_splt_tb
	       ,x_return_status => x_return_status
	       ,x_msg_count     => x_msg_count
	       ,x_msg_data      => x_msg_data
	       );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - split_mo FAIL', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_SPLIT_MO_ERR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    IF (l_tmp_mmtt_rec.move_order_line_id <> l_mo_splt_tb(1).line_id) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: Unmarking wms_process_flag FOR line: '
			      ||l_tmp_mmtt_rec.move_order_line_id);
	       END IF;

	       --Update the MOL with unused qty to 1, because the TM will only
	       --update wms_process_flag for the marked lines and not all
	       --lines in a LPN as done in 11.5.10
	       UPDATE mtl_txn_request_lines
		 SET  wms_process_flag = 1
		WHERE line_id = l_tmp_mmtt_rec.move_order_line_id;
	    END IF;

	    l_progress := '6.1.1';

	    FOR i IN 1 .. l_mo_splt_tb.COUNT LOOP
	       l_out_mo_splt_tb(l_out_mo_splt_tb.COUNT+i).line_id
		 := l_mo_splt_tb(i).line_id;
	    END LOOP;

	    l_progress := '6.1.2';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Calling abort_mmtts');
	    END IF;

	    abort_mmtts(p_move_order_line_id =>     l_mo_splt_tb(1).line_id
			,p_organization_id  =>   l_tmp_mmtt_rec.organization_id
			,x_return_status            =>   x_return_status
			,x_msg_count                =>   x_msg_count
			,x_msg_data                 =>   x_msg_data
			);
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - abort_mmtts FAIL', 9);
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS','WMS_TASK_DELETE_ERROR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '6.1.3';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Calling insert_lot_serial');
	       print_debug('     p_transaction_temp_id => '||l_tmp_mmtt_rec.transaction_temp_id);
	       print_debug('     p_organization_id     => '||l_tmp_mmtt_rec.organization_id);
	       print_debug('     p_item_id             => '||l_tmp_mmtt_rec.inventory_item_id);
	    END IF;

	    l_old_intf_id :=
	      insert_lot_serial (p_transaction_temp_id => l_tmp_mmtt_rec.transaction_temp_id
				 ,p_organization_id    => l_tmp_mmtt_rec.organization_id
				 ,p_item_id => l_tmp_mmtt_rec.inventory_item_id
				 ,x_return_status => x_return_status
				 ,x_msg_count     => x_msg_count
				 ,x_msg_data      => x_msg_data
				 );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - insert_lot_serial FAIL', 9);
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '6.1.4';

	    OPEN mol_cur(l_tmp_mmtt_rec.move_order_line_id);
	    FETCH mol_cur INTO l_mol_rec;
	    CLOSE mol_cur;

	    l_progress := '6.1.5';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: Calling Match_transfer_rcvtxn_rec(');
	       print_debug('     p_organization_id     => '||l_tmp_mmtt_rec.organization_id);
	       print_debug('     p_parent_txn_id       => '||l_mol_rec.txn_source_id);
	       print_debug('     p_reference_id        => '||l_mol_rec.reference_id);
	       print_debug('     p_reference           => '||l_mol_rec.reference);
	       print_debug('     p_reference_type_code => '||l_mol_rec.reference_type_code);
	       print_debug('     p_item_id             => '||l_tmp_mmtt_rec.inventory_item_id);
	       print_debug('     p_revision            => '||l_mol_rec.revision);
	       print_debug('     p_subinventory_code   => '||l_tmp_mmtt_rec.transfer_subinventory);
	       print_debug('     p_locator_id          => '||l_tmp_mmtt_rec.transfer_to_location);
	       print_debug('     p_transfer_quantity   => '||l_tmp_mmtt_rec.transaction_quantity);
	       print_debug('     p_transfer_uom_code   => '||l_tmp_mmtt_rec.transaction_uom);
	       print_debug('     p_lot_control_code    => '||l_tmp_mmtt_rec.lot_control_code);
	       print_debug('     p_serial_control_code => '||l_tmp_mmtt_rec.serial_control_code);
	       print_debug('     p_original_rti_id     => '||l_old_intf_id);
	       print_debug('     p_original_temp_id    => ');
	       print_debug('     p_lot_number          => '||l_mol_rec.lot_number);
	       print_debug('     p_lpn_id              => '||l_tmp_mmtt_rec.lpn_id);
	       print_debug('     p_transfer_lpn_id     => ');
	       print_debug('     p_inspection_status   => '||l_mol_rec.inspection_status);

               -- OPM Convergance
               print_debug('     p_sec_transfer_quantity   => '||l_tmp_mmtt_rec.secondary_transaction_quantity);
	       print_debug('     p_sec_transfer_uom_code   => '||l_tmp_mmtt_rec.secondary_uom_code);
               -- OPM Convergance
	       print_debug(' p_inspection_status       => '||l_mol_rec.inspection_status);
	       print_debug(' p_from_sub                => '||l_tmp_mmtt_rec.subinventory_code);
	       print_debug(' p_from_loc                => '||l_tmp_mmtt_rec.locator_id);
	    END IF;

	    inv_rcv_std_transfer_apis.Match_transfer_rcvtxn_rec
	      ( x_return_status         =>  x_return_status
		,x_msg_count            =>  x_msg_count
		,x_msg_data             =>  x_msg_data
		,p_organization_id      =>  l_tmp_mmtt_rec.organization_id
		,p_parent_txn_id       =>  l_mol_rec.txn_source_id
		,p_reference_id        =>  l_mol_rec.reference_id
		,p_reference           =>  l_mol_rec.reference
		,p_reference_type_code =>  l_mol_rec.reference_type_code
		,p_item_id             =>  l_tmp_mmtt_rec.inventory_item_id
		,p_revision            =>  l_mol_rec.revision  --??
		,p_subinventory_code   =>  l_tmp_mmtt_rec.transfer_subinventory
		,p_locator_id          =>  l_tmp_mmtt_rec.transfer_to_location
		,p_transfer_quantity   =>  l_tmp_mmtt_rec.transaction_quantity
		,p_transfer_uom_code   =>  l_tmp_mmtt_rec.transaction_uom
		,p_lot_control_code    =>  l_tmp_mmtt_rec.lot_control_code
		,p_serial_control_code =>  l_tmp_mmtt_rec.serial_control_code
		,p_original_rti_id     =>  l_old_intf_id
		,p_original_temp_id    =>  NULL
		,p_lot_number          =>  l_mol_rec.lot_number
	      ,p_lpn_id              =>  l_tmp_mmtt_rec.lpn_id
	      ,p_transfer_lpn_id     =>  NULL
                -- OPM Convergance
                ,p_sec_transfer_quantity => l_tmp_mmtt_rec.secondary_transaction_quantity
                ,p_sec_transfer_uom_code  => l_tmp_mmtt_rec.secondary_uom_code
                -- OPM Convergance
	      ,p_primary_uom_code      => l_tmp_mmtt_rec.primary_uom_code
	      ,p_inspection_status     => l_mol_rec.inspection_status
	      ,p_from_sub              => l_tmp_mmtt_rec.subinventory_code
	      ,p_from_loc              => l_tmp_mmtt_rec.locator_id
	      );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('ERROR: Match_transfer_rcvtxn_rec FAIL', 9);
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    -- Set flag to call to TM
	    l_call_rm := TRUE;

	    l_progress := '6.1.6';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Xfer api sucessfully returns');
	    END IF;
	  ELSE -- no sub/loc changed
	    l_progress := '6.2.0';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
			   ') No Sub/Loc changed');
	    END IF;

	    l_mo_splt_tb(1).prim_qty := l_tmp_mmtt_rec.primary_quantity;

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: Calling split_mo(');
	       print_debug('   p_orig_mol_id            => ' || l_tmp_mmtt_rec.move_order_line_id);
	       print_debug('   p_mo_splt_tb(1).prim_qty => ' || l_mo_splt_tb(1).prim_qty);
	    END IF;

	    inv_rcv_integration_apis.split_mo
	      (p_orig_mol_id    => l_tmp_mmtt_rec.move_order_line_id
	       ,p_mo_splt_tb    => l_mo_splt_tb
	       ,x_return_status => x_return_status
	       ,x_msg_count     => x_msg_count
	       ,x_msg_data      => x_msg_data
	       );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - split_mo FAIL', 9);
	       END IF;
	       fnd_message.set_name('INV', 'INV_SPLIT_MO_ERR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    IF (l_tmp_mmtt_rec.move_order_line_id <> l_mo_splt_tb(1).line_id) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: Unmarking wms_process_flag FOR line: '
			      ||l_tmp_mmtt_rec.move_order_line_id);
	       END IF;

	       --Update the MOL with unused qty to 1, because the TM will only
	       --update wms_process_flag for the marked lines and not all
	       --lines in a LPN as done in 11.5.10
	       UPDATE mtl_txn_request_lines
		 SET  wms_process_flag = 1
		WHERE line_id = l_tmp_mmtt_rec.move_order_line_id;
	    END IF;

	    l_progress := '6.2.1';

	    FOR i IN 1 .. l_mo_splt_tb.COUNT LOOP
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: split_mo created MOL: '
			      ||l_mo_splt_tb(i).line_id);
	       END IF;
	       l_out_mo_splt_tb(l_out_mo_splt_tb.COUNT+i).line_id
		 := l_mo_splt_tb(i).line_id;
	    END LOOP;

	    l_progress := '6.2.2';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Calling abort_mmtts');
	    END IF;

	    --Even when there is no sub/loc changed, we need to abort
	    --the operation plan because they are LPN based.
	    abort_mmtts(p_move_order_line_id =>     l_mo_splt_tb(1).line_id
			,p_organization_id  =>   l_tmp_mmtt_rec.organization_id
			,x_return_status            =>   x_return_status
			,x_msg_count                =>   x_msg_count
			,x_msg_data                 =>   x_msg_data
			);
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - abort_mmtts FAIL', 9);
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS','WMS_TASK_DELETE_ERROR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '6.2.2.5';


	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') split_mo sucessfully returns.  Calling insert_lot_serial');
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Calling insert_lot_serial');
	       print_debug('     p_transaction_temp_id => '||l_tmp_mmtt_rec.transaction_temp_id);
	       print_debug('     p_organization_id     => '||l_tmp_mmtt_rec.organization_id);
	       print_debug('     p_item_id             => '||l_tmp_mmtt_rec.inventory_item_id);

	    END IF;

	    l_old_intf_id :=
	      insert_lot_serial (p_transaction_temp_id   => l_tmp_mmtt_rec.transaction_temp_id
				 ,p_organization_id => l_tmp_mmtt_rec.organization_id
				 ,p_item_id              => l_tmp_mmtt_rec.inventory_item_id
				 ,x_return_status        => x_return_status
				 ,x_msg_count            => x_msg_count
				 ,x_msg_data             => x_msg_data
				 );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('ERROR: insert_lot_serial FAIL', 9);
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '6.2.3';

	    OPEN mol_cur(l_tmp_mmtt_rec.move_order_line_id);
	    FETCH mol_cur INTO l_mol_rec;
	    CLOSE mol_cur;

	    l_progress := '6.2.4';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') insert_lot_serail sucessfully returns.  Starts TO LOOP mmtts');
	    END IF;

	    -- Look at each new mmtt, and insert rti for each of them
	    -- Bug 5231114: Added the condition on transaction_source_type_id and
            -- transaction_action_id for the following combinations:13/12 and 4/27
	    FOR l_mmtt_rec IN
	      ( SELECT
		transaction_temp_id
		,transaction_quantity
		,primary_quantity
		,transaction_uom
                ,secondary_transaction_quantity
                ,secondary_uom_code
		FROM
		mtl_material_transactions_temp
		WHERE
		( move_order_line_id = l_mo_splt_tb(1).line_id AND
		  ( ( transaction_source_type_id = 1 AND
		      transaction_action_id = 27) OR
		    ( transaction_source_type_id = 7 AND
		      transaction_action_id = 12) OR
		    ( transaction_source_type_id = 12 AND
		      transaction_action_id = 27) OR
    	            ( transaction_source_type_id = 13 AND
   		      transaction_action_id = 12) OR
	            ( transaction_source_type_id = 4 AND
 	              transaction_action_id = 27))) )
	      LOOP
		 -- keep track of remaining quantity
		 l_progress := '6.2.5';

		 IF (l_debug = 1) THEN
		    print_debug('PACK_UNPACK_SPLIT: Looking at:');
		    print_debug('  l_mmtt_rec.transaction_temp_id  => ' || l_mmtt_rec.transaction_temp_id);
		    print_debug('  l_mmtt_rec.transaction_quantity => ' || l_mmtt_rec.transaction_quantity);
		    print_debug('  l_mmtt_rec.primary_quantity     => ' || l_mmtt_rec.primary_quantity);
		    print_debug('  l_mmtt_rec.transaction_uom      => ' || l_mmtt_rec.primary_quantity);
		 END IF;

		 l_tmp_mmtt_rec.primary_quantity :=
		   l_tmp_mmtt_rec.primary_quantity -
		   l_mmtt_rec.primary_quantity;

		 l_progress := '6.2.6';

		 /* Create a dummy RT ID */
		 SELECT rcv_transactions_interface_s.NEXTVAL
		   INTO l_new_intf_id
		   FROM dual;

		 l_progress := '6.2.7';

		 /* Split lot serial */
		 l_rti_tb.DELETE;

		 l_rti_tb(1).orig_interface_trx_id := l_old_intf_id;
		 l_rti_tb(1).new_interface_trx_id  := l_new_intf_id;
		 l_rti_tb(1).quantity              := l_mmtt_rec.transaction_quantity;
		 l_rti_tb(1).to_organization_id    := l_tmp_mmtt_rec.organization_id;
		 l_rti_tb(1).item_id               := l_tmp_mmtt_rec.inventory_item_id;
		 l_rti_tb(1).uom_code              := l_tmp_mmtt_rec.transaction_uom;
		 IF (l_debug = 1) THEN
		    print_debug('PACK_UNPACK_SPLIT: Calling split_lot_serial(');
		    print_debug('   p_rti_tb(1).orig_interface_trx_id => '
				|| l_old_intf_id);
		    print_debug('   p_rti_tb(1).new_interface_trx_id => '
				|| l_new_intf_id);
		    print_debug('   p_rti_tb(1).quantity => '
				|| l_mmtt_rec.transaction_quantity);
		 END IF;

		 IF (l_tmp_mmtt_rec.primary_quantity > 0) THEN
		    l_rti_tb(2).orig_interface_trx_id := l_old_intf_id;
		    l_rti_tb(2).new_interface_trx_id  := l_old_intf_id;

		    IF (l_tmp_mmtt_rec.primary_uom_code <> l_mmtt_rec.transaction_uom) THEN
		       l_rti_tb(2).quantity := inv_rcv_cache.convert_qty
			                          (l_tmp_mmtt_rec.inventory_item_id
						   ,l_tmp_mmtt_rec.primary_quantity
						   ,l_tmp_mmtt_rec.primary_uom_code
						   ,l_mmtt_rec.transaction_uom);
		     ELSE
		       l_rti_tb(2).quantity := l_tmp_mmtt_rec.primary_quantity;
		    END IF;

		    l_rti_tb(2).to_organization_id    := l_tmp_mmtt_rec.organization_id;
		    l_rti_tb(2).item_id               := l_tmp_mmtt_rec.inventory_item_id;
		    l_rti_tb(2).uom_code              := l_tmp_mmtt_rec.transaction_uom;
		 END IF;

		 inv_rcv_integration_pvt.split_lot_serial
		   (p_rti_tb         => l_rti_tb
		    ,x_return_status => x_return_status
		    ,x_msg_count     => x_msg_count
		    ,x_msg_data      => x_msg_data
		    );
		 IF (x_return_status <> g_ret_sts_success) THEN
		    IF (l_debug = 1) THEN
		       print_debug('ERROR: split_lot_serial FAIL', 9);
		    END IF;
		    RAISE fnd_api.g_exc_error;
		 END IF;

		 l_progress := '6.2.8';

		 IF (l_debug = 1) THEN
		    print_debug('PACK_UNPACK_SPLIT: Calling Match_transfer_rcvtxn_rec(');
		    print_debug('     p_organization_id     => '||l_tmp_mmtt_rec.organization_id);
		    print_debug('     p_parent_txn_id       => '||l_mol_rec.txn_source_id);
		    print_debug('     p_reference_id        => '||l_mol_rec.reference_id);
		    print_debug('     p_reference           => '||l_mol_rec.reference);
		    print_debug('     p_reference_type_code => '||l_mol_rec.reference_type_code);
		    print_debug('     p_item_id             => '||l_tmp_mmtt_rec.inventory_item_id);
		    print_debug('     p_revision            => '||l_mol_rec.revision);
		    print_debug('     p_subinventory_code   => '||l_tmp_mmtt_rec.transfer_subinventory);
		    print_debug('     p_locator_id          => '||l_tmp_mmtt_rec.transfer_to_location);
		    print_debug('     p_transfer_quantity   => '||l_tmp_mmtt_rec.transaction_quantity);
		    print_debug('     p_transfer_uom_code   => '||l_tmp_mmtt_rec.transaction_uom);
		    print_debug('     p_lot_control_code    => '||l_tmp_mmtt_rec.lot_control_code);
		    print_debug('     p_serial_control_code => '||l_tmp_mmtt_rec.serial_control_code);
		    print_debug('     p_original_rti_id     => '||l_new_intf_id);
		    print_debug('     p_original_temp_id    => '||l_mmtt_rec.transaction_temp_id);
		    print_debug('     p_lot_number          => '||l_mol_rec.lot_number);
		    print_debug('     p_lpn_id              => '||l_tmp_mmtt_rec.lpn_id);
		    print_debug('     p_transfer_lpn_id     =>   )');
		    print_debug('     p_inspection_status   => '||l_mol_rec.inspection_status);
                    -- OPM Convergance
                    print_debug('     p_sec_transfer_quantity   => '||l_tmp_mmtt_rec.secondary_transaction_quantity);
		    print_debug('     p_sec_transfer_uom_code   => '||l_tmp_mmtt_rec.secondary_uom_code);
                    -- OPM Convergance
		 END IF;

		 /* Call transfer API with the new RT ID */
		 inv_rcv_std_transfer_apis.Match_transfer_rcvtxn_rec
		   ( x_return_status         =>  x_return_status
		     ,x_msg_count            =>  x_msg_count
		     ,x_msg_data             =>  x_msg_data
		     ,p_organization_id      =>  l_tmp_mmtt_rec.organization_id
		     ,p_parent_txn_id       =>  l_mol_rec.txn_source_id
		     ,p_reference_id        =>  l_mol_rec.reference_id
		     ,p_reference           =>  l_mol_rec.reference
		     ,p_reference_type_code =>  l_mol_rec.reference_type_code
		     ,p_item_id             =>  l_tmp_mmtt_rec.inventory_item_id
		     ,p_revision            =>  l_mol_rec.revision
		     ,p_subinventory_code   =>  l_tmp_mmtt_rec.transfer_subinventory
		     ,p_locator_id          =>  l_tmp_mmtt_rec.transfer_to_location
		     ,p_transfer_quantity   =>  l_mmtt_rec.transaction_quantity
		     ,p_transfer_uom_code   =>  l_mmtt_rec.transaction_uom
		     ,p_lot_control_code    =>  l_tmp_mmtt_rec.lot_control_code
		     ,p_serial_control_code =>  l_tmp_mmtt_rec.serial_control_code
		     ,p_original_rti_id     =>  l_new_intf_id
		   ,p_original_temp_id    =>  l_mmtt_rec.transaction_temp_id
		   ,p_lot_number          =>  l_mol_rec.lot_number
		   ,p_lpn_id              =>  l_tmp_mmtt_rec.lpn_id
		   ,p_transfer_lpn_id     =>  NULL
                   -- OPM Convergance
                     ,p_sec_transfer_quantity => l_mmtt_rec.secondary_transaction_quantity
                     ,p_sec_transfer_uom_code => l_mmtt_rec.secondary_uom_code
                   -- OPM Convergance
		   ,p_primary_uom_code    =>   l_tmp_mmtt_rec.primary_uom_code
		   ,p_inspection_status     => l_mol_rec.inspection_status
		   );
		 IF (x_return_status <> g_ret_sts_success) THEN
		    IF (l_debug = 1) THEN
		       print_debug('PACK_UNPACK_SPLIT : ERROR - Match_transfer_rcvtxn_rec FAIL',
				   9);
		    END IF;
		    RAISE fnd_api.g_exc_error;
		 END IF;

		 l_progress := '6.2.9';

		 IF (l_debug = 1) THEN
		    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
				') xfer api returns sucessfully');
		 END IF;

	      END LOOP;

	      l_progress := '6.2.10';
	      IF (l_debug = 1) THEN
		 print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Loop exited.  Looking at remaining quantities');
	      END IF;

	      IF (l_tmp_mmtt_rec.primary_quantity > 0) THEN
		 -- Call transfer API for the remaining qty (not detailed)
		 -- with the old RT ID
		 l_progress := '6.2.11';
		 IF (l_debug = 1) THEN
		    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
				') There are remaining quantities.  Calling xfer api');
		 END IF;

		 IF (l_debug = 1) THEN
		    print_debug('PACK_UNPACK_SPLIT: Calling Match_transfer_rcvtxn_rec(');
		    print_debug('     p_organization_id     => '||l_tmp_mmtt_rec.organization_id);
		    print_debug('     p_parent_txn_id       => '||l_mol_rec.txn_source_id);
		    print_debug('     p_reference_id        => '||l_mol_rec.reference_id);
		    print_debug('     p_reference           => '||l_mol_rec.reference);
		    print_debug('     p_reference_type_code => '||l_mol_rec.reference_type_code);
		    print_debug('     p_item_id             => '||l_tmp_mmtt_rec.inventory_item_id);
		    print_debug('     p_revision            => '||l_mol_rec.revision);
		    print_debug('     p_subinventory_code   => '||l_tmp_mmtt_rec.transfer_subinventory);
		    print_debug('     p_locator_id          => '||l_tmp_mmtt_rec.transfer_to_location);
		    print_debug('     p_transfer_quantity   => '||l_tmp_mmtt_rec.transaction_quantity);
		    print_debug('     p_transfer_uom_code   => '||l_tmp_mmtt_rec.transaction_uom);
		    print_debug('     p_lot_control_code    => '||l_tmp_mmtt_rec.lot_control_code);
		    print_debug('     p_serial_control_code => '||l_tmp_mmtt_rec.serial_control_code);
		    print_debug('     p_original_rti_id     => '||l_new_intf_id);
		    print_debug('     p_original_temp_id    => ');
		    print_debug('     p_lot_number          => '||l_mol_rec.lot_number);
		    print_debug('     p_lpn_id              => '||l_tmp_mmtt_rec.lpn_id);
		    print_debug('     p_transfer_lpn_id     =>   )');
		    print_debug('     p_inspection_status   => '||l_mol_rec.inspection_status);

                    -- OPM Convergance
                    print_debug('     p_sec_transfer_quantity   => '||l_tmp_mmtt_rec.secondary_transaction_quantity);
		    print_debug('     p_sec_transfer_uom_code   => '||l_tmp_mmtt_rec.secondary_uom_code);
                    -- OPM Convergance
		 END IF;
		 inv_rcv_std_transfer_apis.Match_transfer_rcvtxn_rec
		   ( x_return_status         =>  x_return_status
		     ,x_msg_count            =>  x_msg_count
		     ,x_msg_data             =>  x_msg_data
		     ,p_organization_id      =>  l_tmp_mmtt_rec.organization_id
		     ,p_parent_txn_id       =>  l_mol_rec.txn_source_id
		     ,p_reference_id        =>  l_mol_rec.reference_id
		     ,p_reference           =>  l_mol_rec.reference
		     ,p_reference_type_code =>  l_mol_rec.reference_type_code
		     ,p_item_id             =>  l_tmp_mmtt_rec.inventory_item_id
		     ,p_revision            =>  l_mol_rec.revision
		     ,p_subinventory_code   =>  l_tmp_mmtt_rec.transfer_subinventory
		     ,p_locator_id          =>  l_tmp_mmtt_rec.transfer_to_location
		     ,p_transfer_quantity   =>  l_tmp_mmtt_rec.transaction_quantity
		     ,p_transfer_uom_code   =>  l_tmp_mmtt_rec.transaction_uom
		     ,p_lot_control_code    =>  l_tmp_mmtt_rec.lot_control_code
		     ,p_serial_control_code =>  l_tmp_mmtt_rec.serial_control_code
		     ,p_original_rti_id     =>  l_old_intf_id
		   ,p_original_temp_id    =>  NULL
		   ,p_lot_number          =>  l_mol_rec.lot_number
		   ,p_lpn_id              =>  l_tmp_mmtt_rec.lpn_id
		   ,p_transfer_lpn_id     =>  NULL
                     -- OPM Convergance
                     ,p_sec_transfer_quantity => l_tmp_mmtt_rec.secondary_transaction_quantity
                     ,p_sec_transfer_uom_code => l_tmp_mmtt_rec.secondary_uom_code
                     -- OPM Convergance
		   ,p_primary_uom_code      => l_tmp_mmtt_rec.primary_uom_code
		   ,p_inspection_status     => l_mol_rec.inspection_status
		   );
		 IF (x_return_status <> g_ret_sts_success) THEN
		    IF (l_debug = 1) THEN
		       print_debug('PACK_UNPACK_SPLIT: ERROR - Match_transfer_rcvtxn_rec FAIL',
				   9);
		    END IF;
		    RAISE fnd_api.g_exc_error;
		 END IF;

	      END IF; -- End remaining qty check

	      l_progress := '6.2.12';

	      -- Set flag to call to TM
	      l_call_rm := TRUE;

	      IF (l_debug = 1) THEN
		 print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') xfer api sucessfully returns');
	      END IF;
	 END IF;
       ELSIF (l_tmp_mmtt_rec.txn_type = 'ITEM_SPLIT') THEN
	 l_progress := '7.0';

	 IF (l_debug = 1) THEN
	    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Item Split');
	 END IF;

	 BEGIN
	    SELECT 1
	      INTO l_xfer_lpn_loaded
	      FROM dual
	      WHERE EXISTS (SELECT /*+ INDEX (wdt, WMS_DISPATCHED_TASKS_U2) */ 'LOADED'  --Bug#8555935 Changed index WMS_DISPATCHED_TASKS_N2 to WMS_DISPATCHED_TASKS_U2
			    FROM  mtl_material_transactions_temp mmtt,
			    wms_dispatched_tasks wdt
			    WHERE mmtt.organization_id = l_tmp_mmtt_rec.organization_id
			    AND mmtt.transaction_temp_id = wdt.transaction_temp_id
			    AND wdt.organization_id = l_tmp_mmtt_rec.organization_id
			    AND wdt.task_type = 2
			    AND wdt.status = 4
			    AND mmtt.lpn_id IN (SELECT lpn_id
						FROM wms_license_plate_numbers
						START WITH lpn_id = l_tmp_mmtt_rec.transfer_lpn_id
						CONNECT BY PRIOR lpn_id = parent_lpn_id
						)
			    );
	 EXCEPTION
	    WHEN OTHERS THEN
	       l_xfer_lpn_loaded := 0;
	 END;

	 IF (l_debug = 1) THEN
	    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Item Split. ');
	    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') LOADED? ' ||
			l_xfer_lpn_loaded);
	 END IF;

	 -- Only need to abort the MMTT if the transfer LPN is not
	 -- loaded. Since if it is loaded, then it means that it
	 -- is being moved around. This is made for Item Load scenarios.
	 -- As for the packing workbench, the transfer LPN should never
	 -- be loaded. So it should always abort the MMTTs
	 -- So, the conclusion is, if the LPN is loaded, then treat it
	 -- as having no sub/loc changed
	 IF (l_tmp_mmtt_rec.sub_loc_changed = 1 AND l_xfer_lpn_loaded = 0) THEN
	    l_progress := '7.1.0';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') Sub/Loc changed');
	    END IF;

	    l_mo_splt_tb(1).prim_qty := l_tmp_mmtt_rec.primary_quantity;

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: Calling split_mo(');
	       print_debug('   p_orig_mol_id            => ' || l_tmp_mmtt_rec.move_order_line_id);
	       print_debug('   p_mo_splt_tb(1).prim_qty => ' || l_mo_splt_tb(1).prim_qty);
	    END IF;

	    inv_rcv_integration_apis.split_mo
	      (p_orig_mol_id    => l_tmp_mmtt_rec.move_order_line_id
	       ,p_mo_splt_tb     => l_mo_splt_tb
	       ,x_return_status => x_return_status
	       ,x_msg_count     => x_msg_count
	       ,x_msg_data      => x_msg_data
	       );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - split_mo FAIL');
	       END IF;
	       fnd_message.set_name('INV', 'INV_SPLIT_MO_ERR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    IF (l_tmp_mmtt_rec.move_order_line_id <> l_mo_splt_tb(1).line_id) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: Unmarking wms_process_flag FOR line: '
			      ||l_tmp_mmtt_rec.move_order_line_id);
	       END IF;

	       --Update the MOL with unused qty to 1, because the TM will only
	       --update wms_process_flag for the marked lines and not all
	       --lines in a LPN as done in 11.5.10
	       UPDATE mtl_txn_request_lines
		 SET  wms_process_flag = 1
		WHERE line_id = l_tmp_mmtt_rec.move_order_line_id;
	    END IF;

	    l_progress := '7.1.1';

	    FOR i IN 1 .. l_mo_splt_tb.COUNT LOOP
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: split_mo created mo:'||l_mo_splt_tb(i).line_id);
	       END IF;
	       l_out_mo_splt_tb(l_out_mo_splt_tb.COUNT+i).line_id
		 := l_mo_splt_tb(i).line_id;
	    END LOOP;

	    l_progress := '7.1.2';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') split_mo returns sucessfully.  Calling abort_mmtts');
	    END IF;


	    abort_mmtts(p_move_order_line_id => l_mo_splt_tb(1).line_id
			,p_organization_id  =>   l_tmp_mmtt_rec.organization_id
			,x_return_status            =>   x_return_status
			,x_msg_count                =>   x_msg_count
			,x_msg_data                 =>   x_msg_data
			);
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - abort_mmtts FAIL');
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS','WMS_TASK_DELETE_ERROR');
	       fnd_msg_pub.ADD;
		  RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '7.1.3';

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') abort_mmtts returns sucessfully.  Calling insert_lot_serial');
	    END IF;

	    l_old_intf_id :=
	      insert_lot_serial (p_transaction_temp_id   => l_tmp_mmtt_rec.transaction_temp_id
				 ,p_organization_id      => l_tmp_mmtt_rec.organization_id
				 ,p_item_id              => l_tmp_mmtt_rec.inventory_item_id
				 ,x_return_status        => x_return_status
				 ,x_msg_count            => x_msg_count
				 ,x_msg_data             => x_msg_data
				 );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - insert_lot_serial FAIL', 9);
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '7.1.4';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||') insert_lot_serial returns sucessfully.');
	    END IF;

	    /* Retrieve MOL */

	    OPEN mol_cur(l_tmp_mmtt_rec.move_order_line_id);
	    FETCH mol_cur INTO l_mol_rec;
	    CLOSE mol_cur;

	    l_progress := '7.1.5';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
			   ') MOL_CUR fetched sucessfully.  Calling xfer api');
	    END IF;

	    inv_rcv_std_transfer_apis.Match_transfer_rcvtxn_rec
	      (x_return_status         =>  x_return_status
	       ,x_msg_count            =>  x_msg_count
	       ,x_msg_data             =>  x_msg_data
	       ,p_organization_id     =>  l_tmp_mmtt_rec.organization_id
	       ,p_parent_txn_id       =>  l_mol_rec.txn_source_id
	       ,p_reference_id        =>  l_mol_rec.reference_id
	       ,p_reference           =>  l_mol_rec.reference
	       ,p_reference_type_code =>  l_mol_rec.reference_type_code
	       ,p_item_id             =>  l_tmp_mmtt_rec.inventory_item_id
	       ,p_revision            =>  l_mol_rec.revision
	       ,p_subinventory_code   =>  l_tmp_mmtt_rec.transfer_subinventory
	       ,p_locator_id          =>  l_tmp_mmtt_rec.transfer_to_location
	       ,p_transfer_quantity   =>  l_tmp_mmtt_rec.transaction_quantity
	       ,p_transfer_uom_code   =>  l_tmp_mmtt_rec.transaction_uom
	       ,p_lot_control_code    =>  l_tmp_mmtt_rec.lot_control_code
	       ,p_serial_control_code =>  l_tmp_mmtt_rec.serial_control_code
	       ,p_original_rti_id     =>  l_old_intf_id
	      ,p_original_temp_id    =>  NULL
	      ,p_lot_number          =>  l_mol_rec.lot_number
	      ,p_lpn_id              =>  l_tmp_mmtt_rec.lpn_id
	      ,p_transfer_lpn_id     =>  l_tmp_mmtt_rec.transfer_lpn_id
               -- OPM Convergance
               ,p_sec_transfer_quantity => l_tmp_mmtt_rec.secondary_transaction_quantity
               ,p_sec_transfer_uom_code => l_tmp_mmtt_rec.secondary_uom_code
               -- OPM Convergance
	      ,p_primary_uom_code      => l_tmp_mmtt_rec.primary_uom_code
	      ,p_inspection_status     => l_mol_rec.inspection_status
	      );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - Match_transfer_rcvtxn_rec FAIL');
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '7.1.6';

	    -- Set flag to call to TM
	    l_call_rm := TRUE;

	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
			   ') xfer_api returns sucessfully.  ');
	    END IF;

	  ELSE  -- no sub/loc changed or LPN is loaded
	    l_progress := '7.2.0';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
			   ') Sub/Loc not changed OR LPN IS LOADED');
	    END IF;

	    l_mo_splt_tb(1).prim_qty := l_tmp_mmtt_rec.primary_quantity;

	    l_progress := '7.2.1';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
			   ') Calling split_mo');
	    END IF;

	    inv_rcv_integration_apis.split_mo
	      (p_orig_mol_id    => l_tmp_mmtt_rec.move_order_line_id
	       ,p_mo_splt_tb    => l_mo_splt_tb
	       ,x_return_status => x_return_status
	       ,x_msg_count     => x_msg_count
	       ,x_msg_data      => x_msg_data
	       );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - split_mo FAIL');
	       END IF;
	       fnd_message.set_name('INV', 'INV_SPLIT_MO_ERR');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    IF (l_tmp_mmtt_rec.move_order_line_id <> l_mo_splt_tb(1).line_id) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: Unmarking wms_process_flag FOR line: '
			      ||l_tmp_mmtt_rec.move_order_line_id);
	       END IF;

	       --Update the MOL with unused qty to 1, because the TM will only
	       --update wms_process_flag for the marked lines and not all
	       --lines in a LPN as done in 11.5.10
	       UPDATE mtl_txn_request_lines
		 SET  wms_process_flag = 1
		WHERE line_id = l_tmp_mmtt_rec.move_order_line_id;
	    END IF;

	    l_progress := '7.2.2';
	    FOR i IN 1 .. l_mo_splt_tb.COUNT LOOP
	       l_out_mo_splt_tb(l_out_mo_splt_tb.COUNT+i).line_id
		 := l_mo_splt_tb(i).line_id;
	    END LOOP;

	    l_progress := '7.2.3';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
			   ') Calling insert_lot_serial');
	    END IF;

	    l_old_intf_id :=
	      insert_lot_serial (p_transaction_temp_id   => l_tmp_mmtt_rec.transaction_temp_id
				 ,p_organization_id      => l_tmp_mmtt_rec.organization_id
				 ,p_item_id              => l_tmp_mmtt_rec.inventory_item_id
				 ,x_return_status        => x_return_status
				 ,x_msg_count            => x_msg_count
				 ,x_msg_data             => x_msg_data
				 );
	    IF (x_return_status <> g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('PACK_UNPACK_SPLIT: ERROR - insert_lot_serail FAIL');
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    l_progress := '7.2.4';
	    OPEN mol_cur(l_tmp_mmtt_rec.move_order_line_id);
	    FETCH mol_cur INTO l_mol_rec;
	    CLOSE mol_cur;

	    l_progress := '7.2.5';
	    IF (l_debug = 1) THEN
	       print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
			   ') Start to loop mmtt' );
	       print_debug(' line_id = ' || l_mol_rec.line_id);
	       print_debug(' reference_id = ' ||l_mol_rec.reference_id);
	       print_debug(' reference = '||l_mol_rec.reference);
	       print_debug(' reference_type_code  = '||l_mol_rec.reference_type_code);

	    END IF;


	    -- Look at each new mmtt, and insert rti for each of them
	    -- Bug 5231114: Added the condition on transaction_source_type_id and
            -- transaction_action_id for the following combinations:13/12 and 4/27
	    FOR l_mmtt_rec IN
	      ( SELECT
		transaction_temp_id
		,primary_quantity
		,transaction_quantity
		,transaction_uom
                ,secondary_transaction_quantity
                ,secondary_uom_code
		FROM
		mtl_material_transactions_temp
		WHERE
		( move_order_line_id = l_mo_splt_tb(1).line_id AND
		  ( ( transaction_source_type_id = 1 AND
		      transaction_action_id = 27) OR
		    ( transaction_source_type_id = 7 AND
		      transaction_action_id = 12) OR
		    ( transaction_source_type_id = 12 AND
		      transaction_action_id = 27) OR
		    ( transaction_source_type_id = 13 AND
		      transaction_action_id = 12) OR
	            ( transaction_source_type_id = 4 AND
	              transaction_action_id = 27))) )
	      LOOP
		 l_progress := '7.2.6';
		 IF (l_debug = 1) THEN
		    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
				') Looking at MMTT:'
				||l_mmtt_rec.transaction_temp_id);
		    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
				') l_tmp_mmtt_rec.primary_quantity: '||
				l_tmp_mmtt_rec.primary_quantity);
		    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
				') l_mmtt_rec.primary_quantity: '||
				l_mmtt_rec.primary_quantity);
		 END IF;

		 -- keep track of remaining quantity
		 l_tmp_mmtt_rec.primary_quantity :=
		   l_tmp_mmtt_rec.primary_quantity -
		   l_mmtt_rec.primary_quantity;


		 /* Create a dummy RT ID */
		 SELECT rcv_transactions_interface_s.NEXTVAL
		   INTO l_new_intf_id
		   FROM dual;
		 l_progress := '7.2.7';

		 /* Split lot serial */
		 l_rti_tb.DELETE;

		 l_rti_tb(1).orig_interface_trx_id := l_old_intf_id;
		 l_rti_tb(1).new_interface_trx_id  := l_new_intf_id;
		 IF (l_tmp_mmtt_rec.transaction_uom <> l_mmtt_rec.transaction_uom) THEN
		    l_rti_tb(1).quantity := inv_rcv_cache.convert_qty
		                               (p_inventory_item_id => l_tmp_mmtt_rec.inventory_item_id
						,p_from_qty         => l_mmtt_rec.transaction_quantity
						,p_from_uom_code    => l_mmtt_rec.transaction_uom
						,p_to_uom_code      => l_tmp_mmtt_rec.transaction_uom);
		  ELSE
		    l_rti_tb(1).quantity := l_mmtt_rec.transaction_quantity;
		 END IF;

		 l_rti_tb(1).to_organization_id    := l_tmp_mmtt_rec.organization_id;
		 l_rti_tb(1).item_id               := l_tmp_mmtt_rec.inventory_item_id;
		 l_rti_tb(1).uom_code              := l_tmp_mmtt_rec.transaction_uom;

		 IF (l_tmp_mmtt_rec.primary_quantity > 0) THEN
		    l_rti_tb(2).orig_interface_trx_id := l_old_intf_id;
		    l_rti_tb(2).new_interface_trx_id  := l_old_intf_id;
		    l_rti_tb(2).quantity              := l_tmp_mmtt_rec.transaction_quantity;
		    l_rti_tb(2).to_organization_id    := l_tmp_mmtt_rec.organization_id;
		    l_rti_tb(2).item_id               := l_tmp_mmtt_rec.inventory_item_id;
		    l_rti_tb(2).uom_code              := l_tmp_mmtt_rec.transaction_uom;
		 END IF;

		 inv_rcv_integration_pvt.split_lot_serial
		   (p_rti_tb         => l_rti_tb
		    ,x_return_status => x_return_status
		    ,x_msg_count     => x_msg_count
		    ,x_msg_data      => x_msg_data
		    );
		 IF (x_return_status <> g_ret_sts_success) THEN
		    IF (l_debug = 1) THEN
		       print_debug('PACK_UNPACK_SPLIT: ERROR - split_lot_serial FAIL', 9);
		    END IF;
		    RAISE fnd_api.g_exc_error;
		 END IF;
		 l_progress := '7.2.8';

		 IF l_mmtt_rec.transaction_uom <> l_tmp_mmtt_rec.transaction_uom THEN
		    l_qty_to_insert := inv_rcv_cache.convert_qty
		                          (p_inventory_item_id => l_tmp_mmtt_rec.inventory_item_id
					   ,p_from_qty         => l_mmtt_rec.transaction_quantity
					   ,p_from_uom_code    => l_mmtt_rec.transaction_uom
					   ,p_to_uom_code      => l_tmp_mmtt_rec.transaction_uom);
		    l_uom_to_insert := l_tmp_mmtt_rec.transaction_uom ;
		  ELSE
		    l_uom_to_insert := l_mmtt_rec.transaction_uom;
		    l_qty_to_insert := l_mmtt_rec.transaction_quantity;
		 END IF;

		 IF (l_debug = 1) THEN
		    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
				') split_lot_serial returns sucessfully. calling xfer api');
		 END IF;

		 /* Call transfer API with the new RT ID */
		 inv_rcv_std_transfer_apis.Match_transfer_rcvtxn_rec
		   ( x_return_status         =>  x_return_status
		     ,x_msg_count            =>  x_msg_count
		     ,x_msg_data             =>  x_msg_data
		     ,p_organization_id      =>  l_tmp_mmtt_rec.organization_id
		     ,p_parent_txn_id       =>  l_mol_rec.txn_source_id
		     ,p_reference_id        =>  l_mol_rec.reference_id
		     ,p_reference           =>  l_mol_rec.reference
		     ,p_reference_type_code =>  l_mol_rec.reference_type_code
		     ,p_item_id             =>  l_tmp_mmtt_rec.inventory_item_id
		     ,p_revision            =>  l_mol_rec.revision
		     ,p_subinventory_code   =>  l_tmp_mmtt_rec.transfer_subinventory
		     ,p_locator_id          =>  l_tmp_mmtt_rec.transfer_to_location
		     ,p_transfer_quantity   =>  l_qty_to_insert
		     ,p_transfer_uom_code   =>  l_uom_to_insert
		     ,p_lot_control_code    =>  l_tmp_mmtt_rec.lot_control_code
		     ,p_serial_control_code =>  l_tmp_mmtt_rec.serial_control_code
		     ,p_original_rti_id     =>  l_new_intf_id
		   ,p_original_temp_id    =>  l_mmtt_rec.transaction_temp_id
		   ,p_lot_number          =>  l_mol_rec.lot_number
		   ,p_lpn_id              =>  l_tmp_mmtt_rec.lpn_id
		   ,p_transfer_lpn_id     =>  l_tmp_mmtt_rec.transfer_lpn_id
                     -- OPM Convergance
                     ,p_sec_transfer_quantity => l_mmtt_rec.secondary_transaction_quantity
                     ,p_sec_transfer_uom_code => l_mmtt_rec.secondary_uom_code
                     -- OPM Convergance
		   ,p_primary_uom_code      => l_tmp_mmtt_rec.primary_uom_code
		   ,p_inspection_status     => l_mol_rec.inspection_status
		   );
		 IF (x_return_status <> g_ret_sts_success) THEN
		    IF (l_debug = 1) THEN
		       print_debug('PACK_UNPACK_SPLIT: ERROR - Match_transfer_rcvtxn_rec FAIL',
				   9);
		    END IF;
		    RAISE fnd_api.g_exc_error;
		 END IF;
		 l_progress := '7.2.8';

	      END LOOP;

	      l_progress := '7.2.9';
	      IF (l_debug = 1) THEN
		 print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
			     ') Loop exited.  Looking at remaining quantities');
	      END IF;

	      IF (l_tmp_mmtt_rec.primary_quantity > 0) THEN
		 -- Call transfer API for the remaining qty (not detailed)
		 -- with the old RT ID */
		 l_progress := '7.2.10';
		 IF (l_debug = 1) THEN
		    print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
				') There are remaining quantities.  Calling xfer api');
		 END IF;

		 inv_rcv_std_transfer_apis.Match_transfer_rcvtxn_rec
		   ( x_return_status         =>  x_return_status
		     ,x_msg_count            =>  x_msg_count
		     ,x_msg_data             =>  x_msg_data
		     ,p_organization_id      =>  l_tmp_mmtt_rec.organization_id
		     ,p_parent_txn_id       =>  l_mol_rec.txn_source_id
		     ,p_reference_id        =>  l_mol_rec.reference_id
		     ,p_reference           =>  l_mol_rec.reference
		     ,p_reference_type_code =>  l_mol_rec.reference_type_code
		     ,p_item_id             =>  l_tmp_mmtt_rec.inventory_item_id
		     ,p_revision            =>  l_mol_rec.revision
		     ,p_subinventory_code   =>  l_tmp_mmtt_rec.transfer_subinventory
		     ,p_locator_id          =>  l_tmp_mmtt_rec.transfer_to_location
		     ,p_transfer_quantity   =>  l_tmp_mmtt_rec.transaction_quantity
		     ,p_transfer_uom_code   =>  l_tmp_mmtt_rec.transaction_uom
		     ,p_lot_control_code    =>  l_tmp_mmtt_rec.lot_control_code
		     ,p_serial_control_code =>  l_tmp_mmtt_rec.serial_control_code
		     ,p_original_rti_id     =>  l_old_intf_id
		   ,p_original_temp_id    =>  NULL
		   ,p_lot_number          =>  l_mol_rec.lot_number   --??
		   ,p_lpn_id              =>  l_tmp_mmtt_rec.lpn_id       --??
		   ,p_transfer_lpn_id     =>  l_tmp_mmtt_rec.transfer_lpn_id
                     -- OPM Convergance
                     ,p_sec_transfer_quantity => l_tmp_mmtt_rec.secondary_transaction_quantity
                     ,p_sec_transfer_uom_code => l_tmp_mmtt_rec.secondary_uom_code
                     -- OPM Convergance
		   ,p_primary_uom_code      => l_tmp_mmtt_rec.primary_uom_code
		   ,p_inspection_status     => l_mol_rec.inspection_status
		   );
		 IF (x_return_status <> g_ret_sts_success) THEN
		    IF (l_debug = 1) THEN
		       print_debug('PAC_UNPACK_SPLIT: ERROR - 1 Match_transfer_rcvtxn_rec FAIL');
		    END IF;
		    RAISE fnd_api.g_exc_error;
		 END IF;
	      END IF;

	      l_progress := '7.2.11';
	      -- Set flag to call to TM
	      l_call_rm := TRUE;

	      IF (l_debug = 1) THEN
		 print_debug('PACK_UNPACK_SPLIT: ('||l_progress||
			     ') xfer_api sucessfully returns');
	      END IF;
	 END IF; -- End sub/loc test
       ELSE
	 fnd_message.set_name('INV', 'INV_INVALID_TXN_TYPE');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;  -- End txn_type test


   END LOOP; -- End tmp_mmtt_cur loop

   IF tmp_mmtt_cur_by_hdr_id%isopen THEN
      CLOSE tmp_mmtt_cur_by_hdr_id;
   END IF;

   IF tmp_mmtt_cur_by_txn_id%isopen THEN
      CLOSE tmp_mmtt_cur_by_txn_id;
   END IF;

   -- Delete temp MMTTs
   IF (l_debug = 1) THEN
      print_debug('Deleting temp MMTTs');
   END IF;

   BEGIN
      forall i IN 1 .. l_mmtts_count
	DELETE FROM mtl_serial_numbers_temp
	WHERE transaction_temp_id = l_mmtt_ids(i)
	OR transaction_temp_id IN
	(SELECT mtlt.serial_transaction_temp_id
	 FROM mtl_transaction_lots_temp mtlt
	 WHERE mtlt.transaction_temp_id = l_mmtt_ids(i));
      IF (l_debug = 1) THEN
	 print_debug('# OF MSNT DELETED: ' || SQL%rowcount);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Error deleting temp MSNTs');
	 END IF;
	 RAISE fnd_api.g_exc_error;
   END;

   BEGIN
      forall i IN 1 .. l_mmtts_count
      DELETE FROM mtl_transaction_lots_temp
	WHERE transaction_temp_id = l_mmtt_ids(i);
      IF (l_debug = 1) THEN
	 print_debug('# OF MTLT DELETED: ' || SQL%rowcount);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Error deleting temp MTLTs');
	 END IF;
	    RAISE fnd_api.g_exc_error;
   END;

   BEGIN
      forall i IN 1 .. l_mmtts_count
	DELETE FROM mtl_material_transactions_temp
	WHERE transaction_temp_id = l_mmtt_ids(i);
      IF (l_debug = 1) THEN
	 print_debug('# OF MMTT DELETED: ' || SQL%rowcount);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug =1 )THEN
	    print_debug('Error deleting temp MMTTs');
	 END IF;
	 RAISE fnd_api.g_exc_error;
   END;

   COMMIT; --Need to commit the delete

   IF (l_call_rm = TRUE AND p_call_rcv_tm = fnd_api.g_true) THEN
      IF (l_debug = 1) THEN
	 print_debug('Calling Receiving TM');
      END IF;

      l_txn_mode_code := inv_rcv_common_apis.g_po_startup_value.transaction_mode;

      inv_rcv_common_apis.g_po_startup_value.transaction_mode
	:=  p_txn_mode_code;

      -- Need to pass in group ID?
      inv_rcv_mobile_process_txn.rcv_process_receive_txn
	(x_return_status    =>  x_return_status
	 ,x_msg_data        =>  x_msg_data
	 );
      IF (x_return_status <> g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('PACK_UNPACK_SPLIT: Error - Rcv TM Failed');
	 END IF;

	 inv_rcv_common_apis.g_po_startup_value.transaction_mode
	   := l_txn_mode_code;
	 fnd_message.set_name('WMS', 'WMS_TD_TXNMGR_ERROR');
	 fnd_msg_pub.ADD;
	 x_return_status := g_ret_sts_unexp_err ;
	 fnd_msg_pub.count_and_get
	   (   p_count                       => x_msg_count
	       ,   p_data                        => x_msg_data
	       );
	 RETURN;
      END IF;

      inv_rcv_common_apis.g_po_startup_value.transaction_mode
	:= l_txn_mode_code;
      -- Need to clear in exception handling too?
      inv_rcv_common_apis.rcv_clear_global;
   END IF;

   x_mo_lines_tb := l_out_mo_splt_tb;

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
      IF (l_debug = 1) THEN
	 print_debug('PACK_UNPACK_SPLIT: Unexpected Exception occured after progress: '
		     || l_progress);
      END IF;

      IF tmp_mmtt_cur_by_hdr_id%isopen THEN
	 CLOSE tmp_mmtt_cur_by_hdr_id;
      END IF;

      IF tmp_mmtt_cur_by_txn_id%isopen THEN
	 CLOSE tmp_mmtt_cur_by_txn_id;
      END IF;

      x_return_status := g_ret_sts_unexp_err ;
      fnd_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
      ROLLBACK TO pack_unpack_split_pub;
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('PACK_UNPACK_SPLIT: Other Exception occured after progress: '
		     || l_progress|| SQLERRM );
      END IF;

      IF tmp_mmtt_cur_by_hdr_id%isopen THEN
	 CLOSE tmp_mmtt_cur_by_hdr_id;
      END IF;

      IF tmp_mmtt_cur_by_txn_id%isopen THEN
	 CLOSE tmp_mmtt_cur_by_txn_id;
      END IF;

      x_return_status := g_ret_sts_unexp_err;
      fnd_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
      ROLLBACK TO pack_unpack_split_pub;
END pack_unpack_split;


END wms_rcv_pup_pvt;


/
