--------------------------------------------------------
--  DDL for Package Body INV_LOT_EO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOT_EO_PVT" as
  /* $Header: INVLTEOB.pls 120.4 2006/09/15 23:52:48 janetli noship $ */
  g_debug      NUMBER  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);


  PROCEDURE mydebug( p_msg        IN        VARCHAR2)
  IS
  BEGIN
     IF (g_debug = 1) THEN
        inv_mobile_helper_functions.tracelog(
                               p_err_msg => p_msg,
                               p_module  => 'INV_LOT_EO_PVT',
                               p_level   => 4);

     END IF;
    --    dbms_output.put_line( p_msg );
  END mydebug;

  procedure preprocess_lot(x_return_status out nocopy  VARCHAR2
        , x_msg_count out nocopy  NUMBER
        , x_msg_data out nocopy  VARCHAR2
        , p_inventory_item_id  NUMBER
        , p_organization_id  NUMBER
        , p_lot_number  VARCHAR2
        , p_parent_lot_number  VARCHAR2
        , p_reference_inventory_item_id NUMBER
        , p_reference_lot_number VARCHAR2    -- OSFM need this to inherite the attributes
        , p_source  NUMBER
        , x_is_new_lot out nocopy VARCHAR2
    ) IS
            l_in_lot_rec	           MTL_LOT_NUMBERS%ROWTYPE;
	    l_out_lot_rec		   MTL_LOT_NUMBERS%ROWTYPE;
	    x_lot_rec                       MTL_LOT_NUMBERS%ROWTYPE;
	    l_api_version		   NUMBER;
	    l_init_msg_list		   VARCHAR2(100);
	    l_commit			   VARCHAR2(100);
	    l_validation_level		   NUMBER;
	    l_origin_txn_id		   NUMBER;
	    l_source                        NUMBER;
	    l_return_status                 VARCHAR2(1)  ;
	    l_msg_data                      VARCHAR2(3000)  ;
	    l_msg_count                     NUMBER    ;
           l_row_id                        ROWID  ;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
           l_lot_number                     VARCHAR2(80);

           l_user_context                   VARCHAR2(30);
           l_mapping_context                    VARCHAR2(30);

    BEGIN
             SAVEPOINT inv_new_lot;
	     x_return_status  := fnd_api.g_ret_sts_success;
	     x_is_new_lot := 'N';

	     BEGIN
	         select lot_number
	         into l_lot_number
	         from mtl_lot_numbers
	         where organization_id = p_organization_id
	           and inventory_item_id = p_inventory_item_id
	           and lot_number = p_lot_number;
	         -- this is an existing lot, nothing to do
	         return;

	     EXCEPTION
	         WHEN NO_DATA_FOUND THEN
	           x_is_new_lot := 'Y';
	     END;


	     /* Populating the variables and calling the new overloaded API  */

	     l_in_lot_rec.inventory_item_id             :=   p_inventory_item_id;
	     l_in_lot_rec.organization_id               :=   p_organization_id;
	     l_in_lot_rec.lot_number                    :=   p_lot_number;
             l_in_lot_rec.parent_lot_number             :=   p_parent_lot_number;
             l_source                                   :=   p_source;
	     l_api_version                              :=   1.0;
	     l_init_msg_list                            :=   fnd_api.g_false;
	     l_commit                                   :=   fnd_api.g_false;
	     -- l_validation_level                         :=   fnd_api.g_valid_level_full;
	     l_validation_level                         :=   fnd_api.g_valid_level_none; -- for testing

             l_origin_txn_id                            :=   NULL;

             -- copy the lot attributes from the reference lot to the current lot
             -- osfm's requirements

             -- get the lot context mapping defination
             inv_lot_sel_attr.get_context_code
                       (
                            l_mapping_context,
                            p_organization_id,
                            p_inventory_item_id,
                            'Lot Attributes'
                        );
             mydebug('defined context mapping:'||l_mapping_context);


             if p_reference_lot_number is not null and p_reference_inventory_item_id is not null then
                 mydebug('copy the attributes from lot '||p_reference_lot_number);
                 BEGIN
                  -- get the lot attribute context
                 SELECT lot_attribute_category
                 INTO l_user_context
                 FROM mtl_lot_numbers
                 WHERE organization_id = p_organization_id
                   AND inventory_item_id = p_reference_inventory_item_id
                   AND lot_number = p_reference_lot_number;
                 mydebug('reference lot context:'||l_user_context);

                 if (l_user_context is null or
                     (l_user_context is not null and
                         (l_mapping_context is null or l_user_context= l_mapping_context))) THEN

                     SELECT vendor_id ,
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
		           INTO
	                        l_in_lot_rec.vendor_id ,
		                l_in_lot_rec.grade_code,
		                l_in_lot_rec.origination_date,
		                l_in_lot_rec.date_code,
		                l_in_lot_rec.status_id,
		                l_in_lot_rec.change_date,
		                l_in_lot_rec.age,
		                l_in_lot_rec.retest_date,
		                l_in_lot_rec.maturity_date,
		                l_in_lot_rec.lot_attribute_category,
		                l_in_lot_rec.item_size,
		                l_in_lot_rec.color,
		                l_in_lot_rec.volume,
		                l_in_lot_rec.volume_uom,
		                l_in_lot_rec.place_of_origin,
		                l_in_lot_rec.best_by_date,
		                l_in_lot_rec.LENGTH,
		                l_in_lot_rec.length_uom,
		                l_in_lot_rec.recycled_content,
		                l_in_lot_rec.thickness,
		                l_in_lot_rec.thickness_uom,
		                l_in_lot_rec.width,
		                l_in_lot_rec.width_uom,
		                l_in_lot_rec.curl_wrinkle_fold,
		                l_in_lot_rec.c_attribute1,
		                l_in_lot_rec.c_attribute2,
		                l_in_lot_rec.c_attribute3,
		                l_in_lot_rec.c_attribute4,
		                l_in_lot_rec.c_attribute5,
		                l_in_lot_rec.c_attribute6,
		                l_in_lot_rec.c_attribute7,
		                l_in_lot_rec.c_attribute8,
		                l_in_lot_rec.c_attribute9,
		                l_in_lot_rec.c_attribute10,
		                l_in_lot_rec.c_attribute11,
		                l_in_lot_rec.c_attribute12,
		                l_in_lot_rec.c_attribute13,
		                l_in_lot_rec.c_attribute14,
		                l_in_lot_rec.c_attribute15,
		                l_in_lot_rec.c_attribute16,
		                l_in_lot_rec.c_attribute17,
		                l_in_lot_rec.c_attribute18,
		                l_in_lot_rec.c_attribute19,
		                l_in_lot_rec.c_attribute20,
		                l_in_lot_rec.d_attribute1,
		                l_in_lot_rec.d_attribute2,
		                l_in_lot_rec.d_attribute3,
		                l_in_lot_rec.d_attribute4,
		                l_in_lot_rec.d_attribute5,
		                l_in_lot_rec.d_attribute6,
		                l_in_lot_rec.d_attribute7,
		                l_in_lot_rec.d_attribute8,
		                l_in_lot_rec.d_attribute9,
		                l_in_lot_rec.d_attribute10,
		                l_in_lot_rec.n_attribute1,
		                l_in_lot_rec.n_attribute2,
		                l_in_lot_rec.n_attribute3,
		                l_in_lot_rec.n_attribute4,
		                l_in_lot_rec.n_attribute5,
		                l_in_lot_rec.n_attribute6,
		                l_in_lot_rec.n_attribute7,
		                l_in_lot_rec.n_attribute8,
		                l_in_lot_rec.n_attribute10,
		                l_in_lot_rec.supplier_lot_number,
		                l_in_lot_rec.n_attribute9,
		                l_in_lot_rec.territory_code,
		                l_in_lot_rec.vendor_name,
		                l_in_lot_rec.description,
		                l_in_lot_rec.attribute_category,
		                l_in_lot_rec.attribute1,
		                l_in_lot_rec.attribute2,
		                l_in_lot_rec.attribute3,
		                l_in_lot_rec.attribute4,
		                l_in_lot_rec.attribute5,
		                l_in_lot_rec.attribute6,
		                l_in_lot_rec.attribute7,
		                l_in_lot_rec.attribute8,
		                l_in_lot_rec.attribute9,
		                l_in_lot_rec.attribute10,
		                l_in_lot_rec.attribute11,
		                l_in_lot_rec.attribute12,
		                l_in_lot_rec.attribute13,
		                l_in_lot_rec.attribute14,
		                l_in_lot_rec.attribute15
		           FROM mtl_lot_numbers
		          WHERE organization_id = p_organization_id
		            AND inventory_item_id = p_reference_inventory_item_id
		            AND lot_number = p_reference_lot_number;
                           ELSE /*  (l_user_context is not null and
                                     (l_mapping_context is not null and l_user_context<> l_mapping_context))   */
                               SELECT vendor_id ,
                                grade_code,
                                origination_date,
                                date_code,
                                status_id,
                                change_date,
                                age,
                                retest_date,
                                maturity_date,
                                supplier_lot_number,
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
                                INTO
                                l_in_lot_rec.vendor_id ,
                                l_in_lot_rec.grade_code,
                                l_in_lot_rec.origination_date,
                                l_in_lot_rec.date_code,
                                l_in_lot_rec.status_id,
                                l_in_lot_rec.change_date,
                                l_in_lot_rec.age,
                                l_in_lot_rec.retest_date,
                                l_in_lot_rec.maturity_date,
                                l_in_lot_rec.supplier_lot_number,
                                l_in_lot_rec.territory_code,
                                l_in_lot_rec.vendor_name,
                                l_in_lot_rec.description,
                                l_in_lot_rec.attribute_category,
                                l_in_lot_rec.attribute1,
                                l_in_lot_rec.attribute2,
                                l_in_lot_rec.attribute3,
                                l_in_lot_rec.attribute4,
                                l_in_lot_rec.attribute5,
                                l_in_lot_rec.attribute6,
                                l_in_lot_rec.attribute7,
                                l_in_lot_rec.attribute8,
                                l_in_lot_rec.attribute9,
                                l_in_lot_rec.attribute10,
                                l_in_lot_rec.attribute11,
                                l_in_lot_rec.attribute12,
                                l_in_lot_rec.attribute13,
                                l_in_lot_rec.attribute14,
                                l_in_lot_rec.attribute15
                           FROM mtl_lot_numbers
                          WHERE organization_id = p_organization_id
                            AND inventory_item_id = p_reference_inventory_item_id
                            AND lot_number = p_reference_lot_number;

                            -- default the context to the defined context mapping
                            l_in_lot_rec.lot_attribute_category := l_mapping_context;

                           END IF;
		       EXCEPTION
		       WHEN NO_DATA_FOUND THEN
		           mydebug('the reference lot ' || p_reference_lot_number ||'do not exist');
		       END;
                   else
                       /** Populate Lot Attribute Category info. **/
                       l_in_lot_rec.lot_attribute_category := l_mapping_context;
                   end if;

                  /* Calling the overloaded procedure */
	           inv_lot_api_pub.Create_Inv_lot(
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
	                   mydebug('Program Create_Inv_lot return ' || l_return_status);
	               END IF;
	               IF l_return_status = fnd_api.g_ret_sts_error THEN
	                 IF g_debug = 1 THEN
	                   mydebug('Program Create_Inv_lot has failed with a user defined exception');
	                 END IF;
	                 RAISE g_exc_error;
	               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	                 IF g_debug = 1 THEN
	                   mydebug('Program Create_Inv_lot has failed with a Unexpected exception');
	                 END IF;
	                 FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
	                 FND_MESSAGE.SET_TOKEN('PROG_NAME','Create_Inv_lot');
	                 fnd_msg_pub.ADD;
	                 RAISE g_exc_unexpected_error;
	               END IF;

	         mydebug('End of the program create_inv_lot. Program has completed successfully ');


	       EXCEPTION
	         WHEN NO_DATA_FOUND THEN
	           x_return_status  := fnd_api.g_ret_sts_error;
	           ROLLBACK TO inv_new_lot;
	           fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
	           if( x_msg_count > 1 ) then
	               x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
	           end if;
	           mydebug('In No data found ' || SQLERRM);
	         WHEN g_exc_error THEN
	           x_return_status  := fnd_api.g_ret_sts_error;
	           ROLLBACK TO inv_new_lot;
	           fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
	           if( x_msg_count > 1 ) then
	               x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
	           end if;
	           mydebug('In g_exc_error ' || SQLERRM);
	         WHEN g_exc_unexpected_error THEN
	           x_return_status  := fnd_api.g_ret_sts_unexp_error;
	           ROLLBACK TO inv_new_lot;
	           fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
	           if( x_msg_count > 1 ) then
	               x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
	           end if;
	           mydebug('In g_exc_unexpected_error ' || SQLERRM);
	         WHEN OTHERS THEN
	           x_return_status  := fnd_api.g_ret_sts_unexp_error;
	           ROLLBACK TO inv_new_lot;
	           fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
	           if( x_msg_count > 1 ) then
	               x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
	           end if;
      mydebug('In others ' || SQLERRM);

    END preprocess_lot;

    procedure delete_lot(x_return_status out nocopy  VARCHAR2
          , x_msg_count out nocopy  NUMBER
          , x_msg_data out nocopy  VARCHAR2
          , p_inventory_item_id  NUMBER
          , p_organization_id  NUMBER
          , p_lot_number  VARCHAR2
  )
  IS
  BEGIN

      delete from mtl_lot_numbers
      where organization_id = p_organization_id
      	and inventory_item_id = p_inventory_item_id
	and lot_number = p_lot_number;
      EXCEPTION
           WHEN OTHERS THEN
	           x_return_status  := fnd_api.g_ret_sts_unexp_error;
	           mydebug('In g_exc_unexpected_error ' || SQLERRM);
  END delete_lot;



  procedure rosetta_table_copy_in_p0(t out nocopy inv_lot_api_pub.char_tbl, a0 JTF_VARCHAR2_TABLE_1000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t inv_lot_api_pub.char_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_1000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_1000();
  else
      a0 := JTF_VARCHAR2_TABLE_1000();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p1(t out nocopy inv_lot_api_pub.number_tbl, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t inv_lot_api_pub.number_tbl, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t out nocopy inv_lot_api_pub.date_tbl, a0 JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t inv_lot_api_pub.date_tbl, a0 out nocopy JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_inv_lot(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_inventory_item_id  NUMBER
    , p_organization_id  NUMBER
    , p_lot_number  VARCHAR2
    , p_expiration_date  DATE
    , p_disable_flag  NUMBER
    , p_attribute_category  VARCHAR2
    , p_lot_attribute_category  VARCHAR2
    , p_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_c_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_n_attributes_tbl JTF_NUMBER_TABLE
    , p_d_attributes_tbl JTF_DATE_TABLE
    , p_grade_code  VARCHAR2
    , p_origination_date  DATE
    , p_date_code  VARCHAR2
    , p_status_id  NUMBER
    , p_change_date  DATE
    , p_age  NUMBER
    , p_retest_date  DATE
    , p_maturity_date  DATE
    , p_item_size  NUMBER
    , p_color  VARCHAR2
    , p_volume  NUMBER
    , p_volume_uom  VARCHAR2
    , p_place_of_origin  VARCHAR2
    , p_best_by_date  DATE
    , p_length  NUMBER
    , p_length_uom  VARCHAR2
    , p_recycled_content  NUMBER
    , p_thickness  NUMBER
    , p_thickness_uom  VARCHAR2
    , p_width  NUMBER
    , p_width_uom  VARCHAR2
    , p_territory_code  VARCHAR2
    , p_supplier_lot_number  VARCHAR2
    , p_vendor_name  VARCHAR2
    , p_source  NUMBER
  )

  as
    ddp_attributes_tbl inv_lot_api_pub.char_tbl;
    ddp_c_attributes_tbl inv_lot_api_pub.char_tbl;
    ddp_n_attributes_tbl inv_lot_api_pub.number_tbl;
    ddp_d_attributes_tbl inv_lot_api_pub.date_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    rosetta_table_copy_in_p0(ddp_attributes_tbl, p_attributes_tbl);

    rosetta_table_copy_in_p0(ddp_c_attributes_tbl, p_c_attributes_tbl);

    rosetta_table_copy_in_p1(ddp_n_attributes_tbl, p_n_attributes_tbl);

    rosetta_table_copy_in_p2(ddp_d_attributes_tbl, p_d_attributes_tbl);


























    -- here's the delegated call to the old PL/SQL routine
    inv_lot_api_pub.create_inv_lot(x_return_status,
      x_msg_count,
      x_msg_data,
      p_inventory_item_id,
      p_organization_id,
      p_lot_number,
      p_expiration_date,
      p_disable_flag,
      p_attribute_category,
      p_lot_attribute_category,
      ddp_attributes_tbl,
      ddp_c_attributes_tbl,
      ddp_n_attributes_tbl,
      ddp_d_attributes_tbl,
      p_grade_code,
      p_origination_date,
      p_date_code,
      p_status_id,
      p_change_date,
      p_age,
      p_retest_date,
      p_maturity_date,
      p_item_size,
      p_color,
      p_volume,
      p_volume_uom,
      p_place_of_origin,
      p_best_by_date,
      p_length,
      p_length_uom,
      p_recycled_content,
      p_thickness,
      p_thickness_uom,
      p_width,
      p_width_uom,
      p_territory_code,
      p_supplier_lot_number,
      p_vendor_name,
      p_source);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






































  end;

  procedure update_inv_lot(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_inventory_item_id  NUMBER
    , p_organization_id  NUMBER
    , p_lot_number  VARCHAR2
    , p_expiration_date  DATE
    , p_disable_flag  NUMBER
    , p_attribute_category  VARCHAR2
    , p_lot_attribute_category  VARCHAR2
    , p_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_c_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_n_attributes_tbl JTF_NUMBER_TABLE
    , p_d_attributes_tbl JTF_DATE_TABLE
    , p_grade_code  VARCHAR2
    , p_origination_date  DATE
    , p_date_code  VARCHAR2
    , p_status_id  NUMBER
    , p_change_date  DATE
    , p_age  NUMBER
    , p_retest_date  DATE
    , p_maturity_date  DATE
    , p_item_size  NUMBER
    , p_color  VARCHAR2
    , p_volume  NUMBER
    , p_volume_uom  VARCHAR2
    , p_place_of_origin  VARCHAR2
    , p_best_by_date  DATE
    , p_length  NUMBER
    , p_length_uom  VARCHAR2
    , p_recycled_content  NUMBER
    , p_thickness  NUMBER
    , p_thickness_uom  VARCHAR2
    , p_width  NUMBER
    , p_width_uom  VARCHAR2
    , p_territory_code  VARCHAR2
    , p_supplier_lot_number  VARCHAR2
    , p_vendor_name  VARCHAR2
    , p_source  NUMBER
  )

  as
    ddp_attributes_tbl inv_lot_api_pub.char_tbl;
    ddp_c_attributes_tbl inv_lot_api_pub.char_tbl;
    ddp_n_attributes_tbl inv_lot_api_pub.number_tbl;
    ddp_d_attributes_tbl inv_lot_api_pub.date_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    rosetta_table_copy_in_p0(ddp_attributes_tbl, p_attributes_tbl);

    rosetta_table_copy_in_p0(ddp_c_attributes_tbl, p_c_attributes_tbl);

    rosetta_table_copy_in_p1(ddp_n_attributes_tbl, p_n_attributes_tbl);

    rosetta_table_copy_in_p2(ddp_d_attributes_tbl, p_d_attributes_tbl);


























    -- here's the delegated call to the old PL/SQL routine
    mydebug('calling inv_lot_api_pub.update_inv_lot with:');
    mydebug('p_expiration_date '||p_expiration_date);
    mydebug('p_source '|| p_source);
    inv_lot_api_pub.update_inv_lot(x_return_status,
      x_msg_count,
      x_msg_data,
      p_inventory_item_id,
      p_organization_id,
      p_lot_number,
      p_expiration_date,
      p_disable_flag,
      p_attribute_category,
      p_lot_attribute_category,
      ddp_attributes_tbl,
      ddp_c_attributes_tbl,
      ddp_n_attributes_tbl,
      ddp_d_attributes_tbl,
      p_grade_code,
      p_origination_date,
      p_date_code,
      p_status_id,
      p_change_date,
      p_age,
      p_retest_date,
      p_maturity_date,
      p_item_size,
      p_color,
      p_volume,
      p_volume_uom,
      p_place_of_origin,
      p_best_by_date,
      p_length,
      p_length_uom,
      p_recycled_content,
      p_thickness,
      p_thickness_uom,
      p_width,
      p_width_uom,
      p_territory_code,
      p_supplier_lot_number,
      p_vendor_name,
      p_source);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






































  end;

end  INV_LOT_EO_PVT;

/
