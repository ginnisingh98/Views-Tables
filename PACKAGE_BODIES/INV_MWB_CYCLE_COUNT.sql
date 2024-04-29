--------------------------------------------------------
--  DDL for Package Body INV_MWB_CYCLE_COUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MWB_CYCLE_COUNT" AS
/* $Header: INVMWBCB.pls 120.1 2005/06/18 01:07:07 appldev  $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_MWB_CYCLE_COUNT';

procedure create_cc_details (
			X_return_status	 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
			x_msg_count            OUT NOCOPY /* file.sql.39 change */   	NUMBER,
			x_msg_data	 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
			p_organization_id 		NUMBER,
			p_cycle_count_header_id		NUMBER,
			p_abc_class_id			NUMBER,
			p_schedule_date			DATE,
			p_inventory_item_id		NUMBER,
			p_revision			VARCHAR2,
			p_subinventory_code		VARCHAR2,
			p_locator_id			NUMBER,
			p_lot_number			VARCHAR2,
			p_serial_number			VARCHAR2,
			p_userid			VARCHAR2
			    ) is

      l_cycle_count_schedule_id NUMBER;
      l_rowid1			VARCHAR2(42);
      l_rowid2			VARCHAR2(42);
      l_creation_date		DATE   := sysdate;
      l_created_by		NUMBER := to_number(p_userid);
      l_last_updated_by		NUMBER := to_number(p_userid);
      l_last_update_date	DATE   := sysdate;
      l_cc_items_ct		NUMBER;
      l_subs_ct			NUMBER;

BEGIN
-- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     SAVEPOINT MWB_CREATE_CC;

     select count(*)
     into l_cc_items_ct
     from mtl_cycle_count_items
     where inventory_item_id = p_inventory_item_id
     and cycle_count_header_id = p_cycle_count_header_id
     and abc_class_id = p_abc_class_id;

     select count(*)
     into l_subs_ct
     from mtl_cc_subinventories
     where  cycle_count_header_id = p_cycle_count_header_id
     and subinventory = p_subinventory_code;

     select mtl_cc_schedule_requests_s.nextval
     into l_cycle_count_schedule_id
     from dual;

IF l_subs_ct = 0 then
  insert into mtl_cc_subinventories
     (  cycle_count_header_id 	,
	subinventory		,
	last_update_date	,
	last_updated_by		,
	creation_date		,
	created_by
     )
  values
     (  p_Cycle_Count_Header_Id	,
	p_subinventory_code	,
	l_last_update_date	,
	l_last_updated_by       ,
	l_creation_date		,
	l_created_by
     );
END IF;

IF l_cc_items_ct = 0 then
  MTL_CYCLE_COUNT_ITEMS_PKG.Insert_Row(
      X_Rowid                		=>  l_RowId2,
      X_Cycle_Count_Header_Id		=>  p_cycle_count_header_id,
      X_Inventory_Item_Id    		=>  p_Inventory_Item_Id,
      X_Last_Update_Date     		=>  l_last_update_date,
      X_Last_Updated_By      		=>  l_last_updated_by,
      X_Creation_Date        		=>  l_creation_date,
      X_Created_By           		=>  l_created_by,
      X_Last_Update_Login    		=>  NULL,
      X_Abc_Class_Id         		=>  p_Abc_Class_Id,
      X_Item_Last_Schedule_Date		=>  NULL,
      X_Schedule_Order       		=>  NULL,
      X_Approval_Tolerance_Positive	=>  NULL,
      X_Approval_Tolerance_Negative	=>  NULL,
      X_Control_Group_Flag   		=>  2
				   );
end if;

  insert into mtl_cc_schedule_requests (
	cycle_count_schedule_id 	,
	last_update_date		,
	last_updated_by			,
	creation_date			,
	created_by			,
	cycle_count_header_id		,
	request_source_type		,
	schedule_date			,
        schedule_status			,
	subinventory			,
	inventory_item_id		,
	revision			,
	lot_number			,
	serial_number			,
	locator_id			)
values  (
	l_cycle_count_schedule_id,
	l_last_update_date	 ,
	l_last_updated_by	 ,
	l_creation_date		 ,
	l_created_by		 ,
	p_cycle_count_header_id  ,
	2			 ,
	p_schedule_date		 ,
	1			 ,
	p_subinventory_code	 ,
	p_inventory_item_id      ,
	p_revision		 ,
	p_lot_number		 ,
	p_serial_number		 ,
	p_locator_id
	);

 EXCEPTION

 WHEN fnd_api.g_exc_error THEN

      x_return_status := fnd_api.g_ret_sts_error;
      ROLLBACK TO mwb_create_cc;
      fnd_msg_pub.count_and_get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
         );
WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      ROLLBACK TO mwb_create_cc;
       fnd_msg_pub.count_and_get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
          );
WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO mwb_create_cc;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'mwb_create_cc_details'
              );
        END IF;
     fnd_msg_pub.count_and_get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
          );

END create_cc_details;


procedure commit_data is
begin
 commit;
end commit_data;
END INV_MWB_CYCLE_COUNT;

/
