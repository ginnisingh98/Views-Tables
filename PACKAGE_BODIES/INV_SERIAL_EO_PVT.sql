--------------------------------------------------------
--  DDL for Package Body INV_SERIAL_EO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SERIAL_EO_PVT" as
  /* $Header: INVSNEOB.pls 120.5 2005/08/01 16:56 janetli noship $ */
g_debug      NUMBER  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);


PROCEDURE mydebug( p_msg        IN        VARCHAR2)
IS
BEGIN
       IF (g_debug = 1) THEN
          inv_mobile_helper_functions.tracelog(
                                 p_err_msg => p_msg,
                                 p_module  => 'INV_SERIAL_EO_PVT',
                                 p_level   => 4);

       END IF;
      --    dbms_output.put_line( p_msg );
 END mydebug;

 procedure preprocess_serial(x_return_status out nocopy  VARCHAR2
          , x_msg_count out nocopy  NUMBER
          , x_msg_data out nocopy  VARCHAR2
          , p_inventory_item_id  NUMBER
          , p_organization_id  NUMBER
          , p_lot_number  VARCHAR2
          , p_parent_lot_number  VARCHAR2
          , p_from_serial_number VARCHAR2
          , x_is_new_serial out nocopy VARCHAR2
          , p_revision VARCHAR2
          , p_to_serial_number VARCHAR2
  ) IS
  l_serial_number VARCHAR2(30);
  x_object_id NUMBER;
  BEGIN

     SAVEPOINT inv_new_serial;
     x_return_status  := fnd_api.g_ret_sts_success;
     x_is_new_serial := 'N';

     BEGIN
	 select serial_number
	 into l_serial_number
	 from mtl_serial_numbers
	 where current_organization_id = p_organization_id
	   and inventory_item_id = p_inventory_item_id
	   and serial_number = p_from_serial_number;
	 -- this is an existing serial, nothing to do
	 return;
     EXCEPTION
     	 WHEN NO_DATA_FOUND THEN
     	   x_is_new_serial := 'Y';
     END;

     -- start to create a new serial number
     /*
     inv_serial_number_pub.insert_range_serial(
	     p_api_version   => 1.0
	   , p_validation_level  => fnd_api.g_valid_level_full
	   , p_inventory_item_id  => p_inventory_item_id
	   , p_organization_id    => p_organization_id
	   , p_from_serial_number => p_from_serial_number
	   , p_to_serial_number   => p_to_serial_number
	   , p_initialization_date => null
	   , p_completion_date => null
	   , p_ship_date =>null
	   , p_revision =>null  -- p_revision
	   , p_lot_number =>p_lot_number
	   , p_current_locator_id  =>null
	   , p_subinventory_code =>null
	   , p_trx_src_id   =>null
	   , p_unit_vendor_id =>null
	   , p_vendor_lot_number =>null
	   , p_vendor_serial_number =>null
	   , p_receipt_issue_type =>null
	   , p_txn_src_id =>null
	   , p_txn_src_name =>null
	   , p_txn_src_type_id =>null
	   , p_transaction_id =>null
	   , p_current_status =>1  -- current status, need to verify with osfm
	   , p_parent_item_id  => null
	   , p_parent_serial_number =>null
	   , p_cost_group_id  =>null
	   , p_transaction_action_id =>null
	   , p_transaction_temp_id   =>null
	   , p_status_id             =>1
	   , p_inspection_status     =>null
	   , x_object_id             =>x_object_id
	   , x_return_status         =>x_return_status
	   , x_msg_count             =>x_msg_count
	   , x_msg_data              =>x_msg_data
  );*/

         inv_serial_number_pub.insertserial(
           p_api_version    =>1.0
         , p_validation_level   => fnd_api.g_valid_level_full
         , p_inventory_item_id   =>p_inventory_item_id
         , p_organization_id     =>p_organization_id
         , p_serial_number       =>p_from_serial_number
         , p_current_status      =>1
         , p_group_mark_id       =>null --
         , p_lot_number          =>p_lot_number
         , x_return_status         =>x_return_status
	 , x_msg_count             =>x_msg_count
	 , x_msg_data              =>x_msg_data
         );

       IF g_debug = 1 THEN
	   mydebug('Program insert_range_serial ' || x_return_status);
       END IF;
       IF x_return_status = fnd_api.g_ret_sts_error THEN
	 IF g_debug = 1 THEN
	   mydebug('Program insert_range_serial has failed with a user defined exception');
	 END IF;
	 RAISE g_exc_error;
       ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 IF g_debug = 1 THEN
	   mydebug('Program insert_range_serial has failed with a Unexpected exception');
	 END IF;
	 FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
	 FND_MESSAGE.SET_TOKEN('PROG_NAME','insert_range_serial');
	 fnd_msg_pub.ADD;
	 RAISE g_exc_unexpected_error;
       END IF;

       mydebug('End of the program insert_range_serial. Program has completed successfully ');



     EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	   x_return_status  := fnd_api.g_ret_sts_error;
	   ROLLBACK TO inv_new_serial;
	   fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
	   if( x_msg_count > 1 ) then
	       x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
	   end if;
	   mydebug('In No data found ' || SQLERRM);
	 WHEN g_exc_error THEN
	   x_return_status  := fnd_api.g_ret_sts_error;
	   ROLLBACK TO inv_new_serial;
	   fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
	   if( x_msg_count > 1 ) then
	       x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
	   end if;
	   mydebug('In g_exc_error ' || SQLERRM);
	 WHEN g_exc_unexpected_error THEN
	   x_return_status  := fnd_api.g_ret_sts_unexp_error;
	   ROLLBACK TO inv_new_serial;
	   fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
	   if( x_msg_count > 1 ) then
	       x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
	   end if;
	   mydebug('In g_exc_unexpected_error ' || SQLERRM);
	 WHEN OTHERS THEN
	   x_return_status  := fnd_api.g_ret_sts_unexp_error;
	   ROLLBACK TO inv_new_serial;
	   fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
	   if( x_msg_count > 1 ) then
	       x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
	   end if;
      mydebug('In others ' || SQLERRM);

  END preprocess_serial;

  procedure delete_serial(x_return_status out nocopy  VARCHAR2
            , x_msg_count out nocopy  NUMBER
            , x_msg_data out nocopy  VARCHAR2
            , p_inventory_item_id  NUMBER
            , p_organization_id  NUMBER
            , p_from_serial_number  VARCHAR2
            , p_to_serial_number VARCHAR2
    )
    IS
    BEGIN

        delete from mtl_serial_numbers
        where current_organization_id = p_organization_id
        	and inventory_item_id = p_inventory_item_id
  	and serial_number between p_from_serial_number and p_to_serial_number;

        EXCEPTION
             WHEN OTHERS THEN
  	           x_return_status  := fnd_api.g_ret_sts_unexp_error;
  	           mydebug('In g_exc_unexpected_error ' || SQLERRM);
  END delete_serial;


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


  procedure insert_serial(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_inventory_item_id  NUMBER
    , p_organization_id  NUMBER
    , p_serial_number  VARCHAR2
    , p_initialization_date  DATE
    , p_completion_date  DATE
    , p_ship_date  DATE
    , p_revision  VARCHAR2
    , p_lot_number  VARCHAR2
    , p_current_locator_id  NUMBER
    , p_subinventory_code  VARCHAR2
    , p_trx_src_id  NUMBER
    , p_unit_vendor_id  NUMBER
    , p_vendor_lot_number  VARCHAR2
    , p_vendor_serial_number  VARCHAR2
    , p_receipt_issue_type  NUMBER
    , p_txn_src_id  NUMBER
    , p_txn_src_name  VARCHAR2
    , p_txn_src_type_id  NUMBER
    , p_transaction_id  NUMBER
    , p_current_status  NUMBER
    , p_parent_item_id  NUMBER
    , p_parent_serial_number  VARCHAR2
    , p_cost_group_id  NUMBER
    , p_transaction_action_id  NUMBER
    , p_transaction_temp_id  NUMBER
    , p_status_id  NUMBER
    , x_object_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_organization_type  NUMBER
    , p_owning_org_id  NUMBER
    , p_owning_tp_type  NUMBER
    , p_planning_org_id  NUMBER
    , p_planning_tp_type  NUMBER
    , p_wip_entity_id  NUMBER
    , p_operation_seq_num  NUMBER
    , p_intraoperation_step_type  NUMBER
    , p_attribute_category  VARCHAR2
    , p_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_serial_attribute_category VARCHAR2
    , p_c_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_n_attributes_tbl JTF_NUMBER_TABLE
    , p_d_attributes_tbl JTF_DATE_TABLE
    , p_origination_date  DATE
    , p_territory_code  VARCHAR2
  )

  as
    ddp_attributes_tbl inv_lot_api_pub.char_tbl;
    ddp_c_attributes_tbl inv_lot_api_pub.char_tbl;
    ddp_n_attributes_tbl inv_lot_api_pub.number_tbl;
    ddp_d_attributes_tbl inv_lot_api_pub.date_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    INV_LOT_EO_PVT.rosetta_table_copy_in_p0(ddp_attributes_tbl, p_attributes_tbl);

    INV_LOT_EO_PVT.rosetta_table_copy_in_p0(ddp_c_attributes_tbl, p_c_attributes_tbl);

    INV_LOT_EO_PVT.rosetta_table_copy_in_p1(ddp_n_attributes_tbl, p_n_attributes_tbl);

    INV_LOT_EO_PVT.rosetta_table_copy_in_p2(ddp_d_attributes_tbl, p_d_attributes_tbl);




    -- here's the delegated call to the old PL/SQL routine
    inv_serial_number_pub.insertserial(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_inventory_item_id,
      p_organization_id,
      p_serial_number,
      p_initialization_date,
      p_completion_date,
      p_ship_date,
      p_revision,
      p_lot_number,
      p_current_locator_id,
      p_subinventory_code,
      p_trx_src_id,
      p_unit_vendor_id,
      p_vendor_lot_number,
      p_vendor_serial_number,
      p_receipt_issue_type,
      p_txn_src_id,
      p_txn_src_name,
      p_txn_src_type_id,
      p_transaction_id,
      p_current_status,
      p_parent_item_id,
      p_parent_serial_number,
      p_cost_group_id,
      p_transaction_action_id,
      p_transaction_temp_id,
      p_status_id,
      x_object_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_organization_type,
      p_owning_org_id,
      p_owning_tp_type,
      p_planning_org_id,
      p_planning_tp_type,
      p_wip_entity_id,
      p_operation_seq_num,
      p_intraoperation_step_type);

      -- calling validate_update_serial_att to update attributes
     /* p_attribute_category,
      ddp_attributes_tbl,
      ddp_c_attributes_tbl,
      ddp_n_attributes_tbl,
      ddp_d_attributes_tbl,
      p_origination_date,
      p_territory_code);  */

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_serial(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_inventory_item_id  NUMBER
    , p_organization_id  NUMBER
    , p_serial_number  VARCHAR2
    , p_initialization_date  DATE
    , p_completion_date  DATE
    , p_ship_date  DATE
    , p_revision  VARCHAR2
    , p_lot_number  VARCHAR2
    , p_current_locator_id  NUMBER
    , p_subinventory_code  VARCHAR2
    , p_trx_src_id  NUMBER
    , p_unit_vendor_id  NUMBER
    , p_vendor_lot_number  VARCHAR2
    , p_vendor_serial_number  VARCHAR2
    , p_receipt_issue_type  NUMBER
    , p_txn_src_id  NUMBER
    , p_txn_src_name  VARCHAR2
    , p_txn_src_type_id  NUMBER
    , p_current_status  NUMBER
    , p_parent_item_id  NUMBER
    , p_parent_serial_number  VARCHAR2
    , p_serial_temp_id  NUMBER
    , p_last_status  NUMBER
    , p_status_id  NUMBER
    , x_object_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_organization_type  NUMBER
    , p_owning_org_id  NUMBER
    , p_owning_tp_type  NUMBER
    , p_planning_org_id  NUMBER
    , p_planning_tp_type  NUMBER
    , p_transaction_action_id  NUMBER
    , p_wip_entity_id  NUMBER
    , p_operation_seq_num  NUMBER
    , p_intraoperation_step_type  NUMBER
    , p_line_mark_id  NUMBER
    , p_attribute_category  VARCHAR2
    , p_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_serial_attribute_category VARCHAR2
    , p_c_attributes_tbl JTF_VARCHAR2_TABLE_1000
    , p_n_attributes_tbl JTF_NUMBER_TABLE
    , p_d_attributes_tbl JTF_DATE_TABLE
    , p_origination_date  DATE
    , p_territory_code  VARCHAR2
  )

  as
    ddp_attributes_tbl inv_lot_api_pub.char_tbl;
    ddp_c_attributes_tbl inv_lot_api_pub.char_tbl;
    ddp_n_attributes_tbl inv_lot_api_pub.number_tbl;
    ddp_d_attributes_tbl inv_lot_api_pub.date_tbl;
    ddindx binary_integer; indx binary_integer;

    l_serial_attributes_tbl        inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    l_validation_status     VARCHAR2(1);
  begin

     SAVEPOINT inv_update_serial;
     x_return_status  := fnd_api.g_ret_sts_success;

    -- copy data to the local IN or IN-OUT args, if any


    mydebug('entering update_serial');

    rosetta_table_copy_in_p0(ddp_attributes_tbl, p_attributes_tbl);

    rosetta_table_copy_in_p0(ddp_c_attributes_tbl, p_c_attributes_tbl);

    rosetta_table_copy_in_p1(ddp_n_attributes_tbl, p_n_attributes_tbl);

    rosetta_table_copy_in_p2(ddp_d_attributes_tbl, p_d_attributes_tbl);


    mydebug('calling updateserial');

    -- here's the delegated call to the old PL/SQL routine
    inv_serial_number_pub.updateserial(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_inventory_item_id,
      p_organization_id,
      p_serial_number,
      p_initialization_date,
      p_completion_date,
      p_ship_date,
      p_revision,
      p_lot_number,
      p_current_locator_id,
      p_subinventory_code,
      p_trx_src_id,
      p_unit_vendor_id,
      p_vendor_lot_number,
      p_vendor_serial_number,
      p_receipt_issue_type,
      p_txn_src_id,
      p_txn_src_name,
      p_txn_src_type_id,
      p_current_status,
      p_parent_item_id,
      p_parent_serial_number,
      p_serial_temp_id,
      p_last_status,
      p_status_id,
      x_object_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_organization_type,
      p_owning_org_id,
      p_owning_tp_type,
      p_planning_org_id,
      p_planning_tp_type,
      p_transaction_action_id,
      p_wip_entity_id,
      p_operation_seq_num,
      p_intraoperation_step_type,
      p_line_mark_id);

      mydebug('after calling updateSerial');
      IF x_return_status = fnd_api.g_ret_sts_error THEN
      IF g_debug = 1 THEN
      	   mydebug('Program insert_range_serial has failed with a user defined exception');
      END IF;
      	 RAISE g_exc_error;
             ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      	 IF g_debug = 1 THEN
      	   mydebug('Program insert_range_serial has failed with a Unexpected exception');
      	 END IF;
      	 FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
      	 FND_MESSAGE.SET_TOKEN('PROG_NAME','insert_range_serial');
      	 fnd_msg_pub.ADD;
      	 RAISE g_exc_unexpected_error;
       END IF;

      -- then call the update attribute routine to update the attributes
	--populate attributes table
	l_serial_attributes_tbl(1).column_name   := 'SERIAL_ATTRIBUTE_CATEGORY';
	l_serial_attributes_tbl(1).column_value  := p_serial_attribute_category;
	l_serial_attributes_tbl(2).column_name   := 'ORIGINATION_DATE';
	l_serial_attributes_tbl(2).column_value  := p_origination_date;
	l_serial_attributes_tbl(3).column_name   := 'C_ATTRIBUTE1';
	l_serial_attributes_tbl(3).column_value  := ddp_c_attributes_tbl(1);
	l_serial_attributes_tbl(4).column_name   := 'C_ATTRIBUTE2';
	l_serial_attributes_tbl(4).column_value  := ddp_c_attributes_tbl(2);
	l_serial_attributes_tbl(5).column_name   := 'C_ATTRIBUTE3';
	l_serial_attributes_tbl(5).column_value  := ddp_c_attributes_tbl(3);
	l_serial_attributes_tbl(6).column_name   := 'C_ATTRIBUTE4';
	l_serial_attributes_tbl(6).column_value   := ddp_c_attributes_tbl(4);
	l_serial_attributes_tbl(7).column_name   := 'C_ATTRIBUTE5';
	l_serial_attributes_tbl(7).column_value   := ddp_c_attributes_tbl(5);
	l_serial_attributes_tbl(8).column_name   := 'C_ATTRIBUTE6';
	l_serial_attributes_tbl(8).column_value   := ddp_c_attributes_tbl(6);
	l_serial_attributes_tbl(9).column_name   := 'C_ATTRIBUTE7';
	l_serial_attributes_tbl(9).column_value   := ddp_c_attributes_tbl(7);
	l_serial_attributes_tbl(10).column_name  := 'C_ATTRIBUTE8';
	l_serial_attributes_tbl(10).column_value  := ddp_c_attributes_tbl(8);
	l_serial_attributes_tbl(11).column_name  := 'C_ATTRIBUTE9';
	l_serial_attributes_tbl(11).column_value  := ddp_c_attributes_tbl(9);
	l_serial_attributes_tbl(12).column_name  := 'C_ATTRIBUTE10';
	l_serial_attributes_tbl(12).column_value  := ddp_c_attributes_tbl(10);
	l_serial_attributes_tbl(13).column_name  := 'C_ATTRIBUTE11';
	l_serial_attributes_tbl(13).column_value  := ddp_c_attributes_tbl(11);
	l_serial_attributes_tbl(14).column_name  := 'C_ATTRIBUTE12';
	l_serial_attributes_tbl(14).column_value  := ddp_c_attributes_tbl(12);
	l_serial_attributes_tbl(15).column_name  := 'C_ATTRIBUTE13';
	l_serial_attributes_tbl(15).column_value  := ddp_c_attributes_tbl(13);
	l_serial_attributes_tbl(16).column_name  := 'C_ATTRIBUTE14';
	l_serial_attributes_tbl(16).column_value  := ddp_c_attributes_tbl(14);
	l_serial_attributes_tbl(17).column_name  := 'C_ATTRIBUTE15';
	l_serial_attributes_tbl(17).column_value  := ddp_c_attributes_tbl(15);
	l_serial_attributes_tbl(18).column_name  := 'C_ATTRIBUTE16';
	l_serial_attributes_tbl(18).column_value  := ddp_c_attributes_tbl(16);
	l_serial_attributes_tbl(19).column_name  := 'C_ATTRIBUTE17';
	l_serial_attributes_tbl(19).column_value  := ddp_c_attributes_tbl(17);
	l_serial_attributes_tbl(20).column_name  := 'C_ATTRIBUTE18';
	l_serial_attributes_tbl(20).column_value  := ddp_c_attributes_tbl(18);
	l_serial_attributes_tbl(21).column_name  := 'C_ATTRIBUTE19';
	l_serial_attributes_tbl(21).column_value  := ddp_c_attributes_tbl(19);
	l_serial_attributes_tbl(22).column_name  := 'C_ATTRIBUTE20';
	l_serial_attributes_tbl(22).column_value  := ddp_c_attributes_tbl(20);
	l_serial_attributes_tbl(23).column_name  := 'D_ATTRIBUTE1';
	l_serial_attributes_tbl(23).column_value  := ddp_d_attributes_tbl(1);
	l_serial_attributes_tbl(24).column_name  := 'D_ATTRIBUTE2';
	l_serial_attributes_tbl(24).column_value  := ddp_d_attributes_tbl(2);
	l_serial_attributes_tbl(25).column_name  := 'D_ATTRIBUTE3';
	l_serial_attributes_tbl(25).column_value  := ddp_d_attributes_tbl(3);
	l_serial_attributes_tbl(26).column_name  := 'D_ATTRIBUTE4';
	l_serial_attributes_tbl(26).column_value  := ddp_d_attributes_tbl(4);
	l_serial_attributes_tbl(27).column_name  := 'D_ATTRIBUTE5';
	l_serial_attributes_tbl(27).column_value  := ddp_d_attributes_tbl(5);
	l_serial_attributes_tbl(28).column_name  := 'D_ATTRIBUTE6';
	l_serial_attributes_tbl(28).column_value  := ddp_d_attributes_tbl(6);
	l_serial_attributes_tbl(29).column_name  := 'D_ATTRIBUTE7';
	l_serial_attributes_tbl(29).column_value  := ddp_d_attributes_tbl(7);
	l_serial_attributes_tbl(30).column_name  := 'D_ATTRIBUTE8';
	l_serial_attributes_tbl(30).column_value  := ddp_d_attributes_tbl(8);
	l_serial_attributes_tbl(31).column_name  := 'D_ATTRIBUTE9';
	l_serial_attributes_tbl(31).column_value  := ddp_d_attributes_tbl(9);
	l_serial_attributes_tbl(32).column_name  := 'D_ATTRIBUTE10';
	l_serial_attributes_tbl(32).column_value  := ddp_d_attributes_tbl(10);
	l_serial_attributes_tbl(33).column_name  := 'N_ATTRIBUTE1';
	l_serial_attributes_tbl(33).column_value  := ddp_n_attributes_tbl(1);
	l_serial_attributes_tbl(34).column_name  := 'N_ATTRIBUTE2';
	l_serial_attributes_tbl(34).column_value  := ddp_n_attributes_tbl(2);
	l_serial_attributes_tbl(35).column_name  := 'N_ATTRIBUTE3';
	l_serial_attributes_tbl(35).column_value  := ddp_n_attributes_tbl(3);
	l_serial_attributes_tbl(36).column_name  := 'N_ATTRIBUTE4';
	l_serial_attributes_tbl(36).column_value  := ddp_n_attributes_tbl(4);
	l_serial_attributes_tbl(37).column_name  := 'N_ATTRIBUTE5';
	l_serial_attributes_tbl(37).column_value := ddp_n_attributes_tbl(5);
	l_serial_attributes_tbl(38).column_name  := 'N_ATTRIBUTE6';
	l_serial_attributes_tbl(38).column_value := ddp_n_attributes_tbl(6);
	l_serial_attributes_tbl(39).column_name  := 'N_ATTRIBUTE7';
	l_serial_attributes_tbl(39).column_value := ddp_n_attributes_tbl(7);
	l_serial_attributes_tbl(40).column_name  := 'N_ATTRIBUTE8';
	l_serial_attributes_tbl(40).column_value := ddp_n_attributes_tbl(8);
	l_serial_attributes_tbl(41).column_name  := 'N_ATTRIBUTE9';
	l_serial_attributes_tbl(41).column_value := ddp_n_attributes_tbl(9);
	l_serial_attributes_tbl(42).column_name  := 'N_ATTRIBUTE10';
	l_serial_attributes_tbl(42).column_value := ddp_n_attributes_tbl(10);
	l_serial_attributes_tbl(43).column_name  := 'STATUS_ID';
	l_serial_attributes_tbl(43).column_value := p_status_id;
	l_serial_attributes_tbl(44).column_name  := 'TERRITORY_CODE';
	l_serial_attributes_tbl(44).column_value := p_territory_code;

	mydebug('calling validate_update_serial_att');

	   --validate and update the attributes.
	inv_serial_number_pub.validate_update_serial_att
	(x_return_status     => x_return_status,
	x_msg_count         => x_msg_count,
	x_msg_data          => x_msg_data,
	x_validation_status => l_validation_status,
	p_serial_number     => p_serial_number,
	p_organization_id   => p_organization_id,
	p_inventory_item_id => p_inventory_item_id,
	p_serial_att_tbl    => l_serial_attributes_tbl,
	p_validate_only     => FALSE
	);

	IF (l_validation_status <> 'Y'
	      OR x_return_status <> 'S') THEN
	      --raise error
	      fnd_message.set_name ('INV' , 'INV_FAIL_VALIDATE_SERIAL' );
	      fnd_msg_pub.ADD;

	       RAISE fnd_api.g_exc_error;
        END IF;

        mydebug('After calling validate_update_serial_att');

            -- update the DFF
            mydebug('update_attributes');
            update mtl_serial_numbers
            set attribute1= ddp_attributes_tbl(1)
            ,   attribute2= ddp_attributes_tbl(2)
            ,   attribute3= ddp_attributes_tbl(3)
            ,   attribute4= ddp_attributes_tbl(4)
            ,   attribute5= ddp_attributes_tbl(5)
            ,   attribute6= ddp_attributes_tbl(6)
            ,   attribute7= ddp_attributes_tbl(7)
            ,   attribute8= ddp_attributes_tbl(8)
            ,   attribute9= ddp_attributes_tbl(9)
            ,   attribute10= ddp_attributes_tbl(10)
            ,   attribute11= ddp_attributes_tbl(11)
            ,   attribute12= ddp_attributes_tbl(12)
            ,   attribute13= ddp_attributes_tbl(13)
            ,   attribute14= ddp_attributes_tbl(14)
            ,   attribute15= ddp_attributes_tbl(15)
            ,   attribute_category = p_attribute_category
            WHERE current_organization_id = p_organization_id
              and inventory_item_id = p_inventory_item_id
              and serial_number = p_serial_number;

    -- copy data back from the local variables to OUT or IN-OUT args, if any


     EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	   x_return_status  := fnd_api.g_ret_sts_error;
	   ROLLBACK TO inv_update_serial;
	   fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
	   if( x_msg_count > 1 ) then
	       x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
	   end if;
	   mydebug('In No data found ' || SQLERRM);
	 WHEN g_exc_error THEN
	   x_return_status  := fnd_api.g_ret_sts_error;
	   ROLLBACK TO inv_update_serial;
	   fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
	   if( x_msg_count > 1 ) then
	       x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
	   end if;
	   mydebug('In g_exc_error ' || SQLERRM);
	 WHEN g_exc_unexpected_error THEN
	   x_return_status  := fnd_api.g_ret_sts_unexp_error;
	   ROLLBACK TO inv_update_serial;
	   fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
	   if( x_msg_count > 1 ) then
	       x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
	   end if;
	   mydebug('In g_exc_unexpected_error ' || SQLERRM);
	 WHEN OTHERS THEN
	   x_return_status  := fnd_api.g_ret_sts_unexp_error;
	   ROLLBACK TO inv_update_serial;
	   fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
	   if( x_msg_count > 1 ) then
	       x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
	   end if;
      mydebug('In others ' || SQLERRM);







  end;

end INV_SERIAL_EO_PVT;

/
