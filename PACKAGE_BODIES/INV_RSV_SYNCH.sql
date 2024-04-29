--------------------------------------------------------
--  DDL for Package Body INV_RSV_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RSV_SYNCH" AS
/* $Header: INVRSV7B.pls 120.1 2005/06/17 17:28:15 appldev  $ */

-- Global constant holding package name
g_pkg_name constant varchar2(50) := 'INV_RSV_SYNCH';

procedure for_insert (
  p_reservation_id		IN	NUMBER
, x_return_status	        OUT NOCOPY	VARCHAR2
, x_msg_count	        	OUT NOCOPY	NUMBER
, x_msg_data     	        OUT NOCOPY	VARCHAR2 ) is

-- constants
c_api_name		constant varchar(30) := 'for_insert';

l_demand_id_dmd		number;
l_demand_id_rsv		number;
l_demand_source_type_id	number;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin

    x_return_status := fnd_api.g_ret_sts_success ;

    if (inv_rsv_trigger_global.g_from_trigger = FALSE) then
        inv_rsv_trigger_global.g_from_trigger := TRUE;

	/*
        ** Get sequence value for demand_id and parent_demand_id
        */
        select mtl_demand_s.nextval
        into l_demand_id_dmd
        from dual;

        select mtl_demand_s.nextval
        into l_demand_id_rsv
        from dual;

	select demand_source_type_id
	into l_demand_source_type_id
	from mtl_reservations
	where reservation_id = p_reservation_id;

	/* Insert demand into MTL_DEMAND for Non-Orders */

	if (l_demand_source_type_id not in (2,8,12)) then
	 insert into mtl_demand(
   	  DEMAND_ID
 	 ,ORGANIZATION_ID
         ,INVENTORY_ITEM_ID
         ,DEMAND_SOURCE_TYPE
         ,DEMAND_SOURCE_HEADER_ID
         ,DEMAND_SOURCE_LINE
         ,DEMAND_SOURCE_DELIVERY
         ,DEMAND_SOURCE_NAME
         ,UOM_CODE
         ,LINE_ITEM_QUANTITY
         ,PRIMARY_UOM_QUANTITY
         ,LINE_ITEM_RESERVATION_QTY
         ,RESERVATION_QUANTITY
         ,COMPLETED_QUANTITY
         ,REQUIREMENT_DATE
 	 ,RESERVATION_TYPE
 	 ,LAST_UPDATE_DATE
 	 ,LAST_UPDATED_BY
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_LOGIN
 	 ,REQUEST_ID
 	 ,PROGRAM_APPLICATION_ID
 	 ,PROGRAM_ID
 	 ,PROGRAM_UPDATE_DATE
 	 ,PARENT_DEMAND_ID
 	 ,EXTERNAL_SOURCE_CODE
 	 ,EXTERNAL_SOURCE_LINE_ID
 	 ,USER_LINE_NUM
 	 ,USER_DELIVERY
 	 ,SCHEDULE_ID
 	 ,AUTODETAIL_GROUP_ID
 	 ,SUPPLY_SOURCE_TYPE
 	 ,SUPPLY_SOURCE_HEADER_ID
 	 ,SUPPLY_GROUP_ID
 	 ,UPDATED_FLAG
 	 ,REVISION
 	 ,LOT_NUMBER
 	 ,SERIAL_NUMBER
 	 ,SUBINVENTORY
 	 ,LOCATOR_ID
 	 ,COMPONENT_SEQUENCE_ID
 	 ,PARENT_COMPONENT_SEQ_ID
 	 ,RTO_MODEL_SOURCE_LINE
 	 ,RTO_PREVIOUS_QTY
 	 ,CONFIG_STATUS
 	 ,AVAILABLE_TO_MRP
 	 ,AVAILABLE_TO_ATP
 	 ,ESTIMATED_RELEASE_DATE
 	 ,DEMAND_CLASS
 	 ,ROW_STATUS_FLAG
 	 ,ORDER_CHANGE_REPORT_FLAG
 	 ,ATP_LEAD_TIME
 	 ,EXPLOSION_EFFECTIVITY_DATE
         ,BOM_LEVEL
         ,MRP_DATE
         ,MRP_QUANTITY
         ,CUSTOMER_ID
         ,TERRITORY_ID
         ,BILL_TO_SITE_USE_ID
         ,SHIP_TO_SITE_USE_ID
         ,MASTER_RESERVATION_QTY
         ,DESCRIPTION
         ,ATTRIBUTE_CATEGORY
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
 	 ,DEMAND_TYPE
 	 ,DUPLICATED_CONFIG_ITEM_ID
 	 ,DUPLICATED_CONFIG_DEMAND_ID
 	 ,EXPLOSION_GROUP_ID
 	 ,ORDERED_ITEM_ID
 	 ,CONFIG_GROUP_ID
 	 ,OPERATION_SEQ_NUM
         ,N_COLUMN1)
	 select
   	  l_demand_id_dmd
 	 ,a.ORGANIZATION_ID
         ,a.INVENTORY_ITEM_ID
         ,a.DEMAND_SOURCE_TYPE_ID
         ,NVL(a.DEMAND_SOURCE_HEADER_ID,0)
         ,a.DEMAND_SOURCE_LINE_ID
         ,a.DEMAND_SOURCE_DELIVERY
         ,a.DEMAND_SOURCE_NAME
         ,a.RESERVATION_UOM_CODE
         ,a.RESERVATION_QUANTITY
         ,a.PRIMARY_RESERVATION_QUANTITY
         ,a.RESERVATION_QUANTITY
         ,a.PRIMARY_RESERVATION_QUANTITY
         ,0					/* COMPLETED_QUANTITY 	*/
         ,a.REQUIREMENT_DATE
 	 ,1					/* RESERVATION_TYPE   	*/
 	 ,a.LAST_UPDATE_DATE
 	 ,a.LAST_UPDATED_BY
         ,a.CREATION_DATE
         ,a.CREATED_BY
         ,a.LAST_UPDATE_LOGIN
 	 ,a.REQUEST_ID
 	 ,a.PROGRAM_APPLICATION_ID
 	 ,a.PROGRAM_ID
 	 ,a.PROGRAM_UPDATE_DATE
 	 ,NULL					/* PARENT_DEMAND_ID	*/
 	 ,a.EXTERNAL_SOURCE_CODE
 	 ,a.EXTERNAL_SOURCE_LINE_ID
 	 ,NULL					/* USER_LINE_NUM	*/
 	 ,NULL					/* USER_DELIVERY	*/
 	 ,NULL					/* SCHEDULE_ID		*/
 	 ,a.AUTODETAIL_GROUP_ID
 	 ,decode(a.SUPPLY_SOURCE_TYPE_ID,13,NULL,a.SUPPLY_SOURCE_TYPE_ID)
 	 ,a.SUPPLY_SOURCE_HEADER_ID
 	 ,NULL					/* SUPPLY_GROUP_ID 	*/
 	 ,NULL					/* UPDATED_FLAG		*/
 	 ,a.REVISION
 	 ,a.LOT_NUMBER
 	 ,a.SERIAL_NUMBER
 	 ,a.SUBINVENTORY_CODE
 	 ,a.LOCATOR_ID
 	 ,NULL					/* COMPONENT_SEQUENCE_ID   */
 	 ,NULL					/* PARENT_COMPONENT_SEQ_ID */
 	 ,NULL					/* RTO_MODEL_SOURCE_LINE   */
 	 ,NULL					/* RTO_PREVIOUS_QTY	*/
 	 ,NULL					/* CONFIG_STATUS	*/
 	 ,1					/* AVAILABLE_TO_MRP	*/
 	 ,1					/* AVAILABLE_TO_ATP	*/
 	 ,NULL					/* ESTIMATED_RELEASE_DATE  */
 	 ,NULL					/* DEMAND_CLASS		*/
 	 ,1					/* ROW_STATUS_FLAG	*/
 	 ,NULL					/* ORDER_CHANGE_REPORT_FLAG */
 	 ,NULL					/* ATP_LEAD_TIME	*/
 	 ,NULL					/* EXPLOSION_EFFECTIVITY_DATE*/
         ,NULL					/* BOM_LEVEL		*/
         ,NULL					/* MRP_DATE		*/
         ,NULL					/* MRP_QUANTITY		*/
         ,NULL					/* CUSTOMER_ID		*/
         ,NULL					/* TERRITORY_ID		*/
         ,NULL					/* BILL_TO_SITE_USE_ID	*/
         ,NULL					/* SHIP_TO_SITE_USE_ID	*/
         ,NULL					/* MASTER_RESERVATION_QTY */
         ,NULL					/* DESCRIPTION		*/
         ,a.ATTRIBUTE_CATEGORY
         ,a.ATTRIBUTE1
         ,a.ATTRIBUTE2
         ,a.ATTRIBUTE3
         ,a.ATTRIBUTE4
         ,a.ATTRIBUTE5
         ,a.ATTRIBUTE6
         ,a.ATTRIBUTE7
 	 ,a.ATTRIBUTE8
 	 ,a.ATTRIBUTE9
 	 ,a.ATTRIBUTE10
 	 ,a.ATTRIBUTE11
 	 ,a.ATTRIBUTE12
 	 ,a.ATTRIBUTE13
 	 ,a.ATTRIBUTE14
 	 ,a.ATTRIBUTE15
 	 ,NULL			/* DEMAND_TYPE 			*/
 	 ,NULL			/* DUPLICATED_CONFIG_ITEM_ID 	*/
 	 ,NULL			/* DUPLICATED_CONFIG_DEMAND_ID 	*/
 	 ,NULL			/* EXPLOSION_GROUP_ID		*/
 	 ,NULL			/* ORDERED_ITEM_ID		*/
 	 ,NULL			/* CONFIG_GROUP_ID		*/
 	 ,NULL			/* OPERATION_SEQ_NUM		*/
 	 ,p_reservation_id
         from mtl_reservations a
         where a.reservation_id = p_reservation_id;
	end if;

	/* Insert reservation into MTL_DEMAND */
	insert into mtl_demand(
   	 DEMAND_ID
 	,ORGANIZATION_ID
        ,INVENTORY_ITEM_ID
        ,DEMAND_SOURCE_TYPE
        ,DEMAND_SOURCE_HEADER_ID
        ,DEMAND_SOURCE_LINE
        ,DEMAND_SOURCE_DELIVERY
        ,DEMAND_SOURCE_NAME
        ,UOM_CODE
        ,LINE_ITEM_QUANTITY
        ,PRIMARY_UOM_QUANTITY
        ,LINE_ITEM_RESERVATION_QTY
        ,RESERVATION_QUANTITY
        ,COMPLETED_QUANTITY
        ,REQUIREMENT_DATE
 	,RESERVATION_TYPE
 	,LAST_UPDATE_DATE
 	,LAST_UPDATED_BY
        ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_LOGIN
 	,REQUEST_ID
 	,PROGRAM_APPLICATION_ID
 	,PROGRAM_ID
 	,PROGRAM_UPDATE_DATE
 	,PARENT_DEMAND_ID
 	,EXTERNAL_SOURCE_CODE
 	,EXTERNAL_SOURCE_LINE_ID
 	,USER_LINE_NUM
 	,USER_DELIVERY
 	,SCHEDULE_ID
 	,AUTODETAIL_GROUP_ID
 	,SUPPLY_SOURCE_TYPE
 	,SUPPLY_SOURCE_HEADER_ID
 	,SUPPLY_GROUP_ID
 	,UPDATED_FLAG
 	,REVISION
 	,LOT_NUMBER
 	,SERIAL_NUMBER
 	,SUBINVENTORY
 	,LOCATOR_ID
 	,COMPONENT_SEQUENCE_ID
 	,PARENT_COMPONENT_SEQ_ID
 	,RTO_MODEL_SOURCE_LINE
 	,RTO_PREVIOUS_QTY
 	,CONFIG_STATUS
 	,AVAILABLE_TO_MRP
 	,AVAILABLE_TO_ATP
 	,ESTIMATED_RELEASE_DATE
 	,DEMAND_CLASS
 	,ROW_STATUS_FLAG
 	,ORDER_CHANGE_REPORT_FLAG
 	,ATP_LEAD_TIME
 	,EXPLOSION_EFFECTIVITY_DATE
        ,BOM_LEVEL
        ,MRP_DATE
        ,MRP_QUANTITY
        ,CUSTOMER_ID
        ,TERRITORY_ID
        ,BILL_TO_SITE_USE_ID
        ,SHIP_TO_SITE_USE_ID
        ,MASTER_RESERVATION_QTY
        ,DESCRIPTION
        ,ATTRIBUTE_CATEGORY
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
 	,DEMAND_TYPE
 	,DUPLICATED_CONFIG_ITEM_ID
 	,DUPLICATED_CONFIG_DEMAND_ID
 	,EXPLOSION_GROUP_ID
 	,ORDERED_ITEM_ID
 	,CONFIG_GROUP_ID
 	,OPERATION_SEQ_NUM
        ,N_COLUMN1)
	select
   	 l_demand_id_rsv
 	,a.ORGANIZATION_ID
        ,a.INVENTORY_ITEM_ID
        ,a.DEMAND_SOURCE_TYPE_ID
        ,NVL(a.DEMAND_SOURCE_HEADER_ID,0)
        ,a.DEMAND_SOURCE_LINE_ID
        ,a.DEMAND_SOURCE_DELIVERY
        ,a.DEMAND_SOURCE_NAME
        ,a.RESERVATION_UOM_CODE
        ,a.RESERVATION_QUANTITY
        ,a.PRIMARY_RESERVATION_QUANTITY
        ,NULL					/* RESERVATION_QUANTITY */
        ,NULL					/* PRIM_RESERVATION_QUANTITY */
        ,0					/* COMPLETED_QUANTITY 	*/
        ,a.REQUIREMENT_DATE
 	,decode(a.SUPPLY_SOURCE_TYPE_ID,13,2,3)	/* RESERVATION_TYPE   	*/
 	,a.LAST_UPDATE_DATE
 	,a.LAST_UPDATED_BY
        ,a.CREATION_DATE
        ,a.CREATED_BY
        ,a.LAST_UPDATE_LOGIN
 	,a.REQUEST_ID
 	,a.PROGRAM_APPLICATION_ID
 	,a.PROGRAM_ID
 	,a.PROGRAM_UPDATE_DATE
 	,l_demand_id_dmd			/* PARENT_DEMAND_ID	*/
 	,a.EXTERNAL_SOURCE_CODE
 	,a.EXTERNAL_SOURCE_LINE_ID
 	,NULL					/* USER_LINE_NUM	*/
 	,NULL					/* USER_DELIVERY	*/
 	,NULL					/* SCHEDULE_ID		*/
 	,a.AUTODETAIL_GROUP_ID
 	,decode(a.SUPPLY_SOURCE_TYPE_ID,13,NULL,a.SUPPLY_SOURCE_TYPE_ID)
 	,a.SUPPLY_SOURCE_HEADER_ID
 	,NULL					/* SUPPLY_GROUP_ID 	*/
 	,NULL					/* UPDATED_FLAG		*/
 	,a.REVISION
 	,a.LOT_NUMBER
 	,a.SERIAL_NUMBER
 	,a.SUBINVENTORY_CODE
 	,a.LOCATOR_ID
 	,NULL					/* COMPONENT_SEQUENCE_ID   */
 	,NULL					/* PARENT_COMPONENT_SEQ_ID */
 	,NULL					/* RTO_MODEL_SOURCE_LINE   */
 	,NULL					/* RTO_PREVIOUS_QTY	*/
 	,NULL					/* CONFIG_STATUS	*/
 	,1					/* AVAILABLE_TO_MRP	*/
 	,1					/* AVAILABLE_TO_ATP	*/
 	,NULL					/* ESTIMATED_RELEASE_DATE  */
 	,NULL					/* DEMAND_CLASS		*/
 	,1					/* ROW_STATUS_FLAG	*/
 	,NULL					/* ORDER_CHANGE_REPORT_FLAG */
 	,NULL					/* ATP_LEAD_TIME	*/
 	,NULL					/* EXPLOSION_EFFECTIVITY_DATE*/
        ,NULL					/* BOM_LEVEL		*/
        ,NULL					/* MRP_DATE		*/
        ,NULL					/* MRP_QUANTITY		*/
        ,NULL					/* CUSTOMER_ID		*/
        ,NULL					/* TERRITORY_ID		*/
        ,NULL					/* BILL_TO_SITE_USE_ID	*/
        ,NULL					/* SHIP_TO_SITE_USE_ID	*/
        ,NULL					/* MASTER_RESERVATION_QTY */
        ,NULL					/* DESCRIPTION		*/
        ,a.ATTRIBUTE_CATEGORY
        ,a.ATTRIBUTE1
        ,a.ATTRIBUTE2
        ,a.ATTRIBUTE3
        ,a.ATTRIBUTE4
        ,a.ATTRIBUTE5
        ,a.ATTRIBUTE6
        ,a.ATTRIBUTE7
 	,a.ATTRIBUTE8
 	,a.ATTRIBUTE9
 	,a.ATTRIBUTE10
 	,a.ATTRIBUTE11
 	,a.ATTRIBUTE12
 	,a.ATTRIBUTE13
 	,a.ATTRIBUTE14
 	,a.ATTRIBUTE15
 	,NULL			/* DEMAND_TYPE 			*/
 	,NULL			/* DUPLICATED_CONFIG_ITEM_ID 	*/
 	,NULL			/* DUPLICATED_CONFIG_DEMAND_ID 	*/
 	,NULL			/* EXPLOSION_GROUP_ID		*/
 	,NULL			/* ORDERED_ITEM_ID		*/
 	,NULL			/* CONFIG_GROUP_ID		*/
 	,NULL			/* OPERATION_SEQ_NUM		*/
 	,p_reservation_id
        from mtl_reservations a
        where a.reservation_id = p_reservation_id;

        update mtl_reservations
        set n_column1 = l_demand_id_rsv
        where reservation_id = p_reservation_id;

        inv_rsv_trigger_global.g_from_trigger := FALSE;
    end if;

    exception
      when fnd_api.g_exc_error then
     	x_return_status := fnd_api.g_ret_sts_error ;
        inv_rsv_trigger_global.g_from_trigger := FALSE;

      when fnd_api.g_exc_unexpected_error then
    	x_return_status := fnd_api.g_ret_sts_unexp_error ;
        inv_rsv_trigger_global.g_from_trigger := FALSE;

      when others then
     	x_return_status := fnd_api.g_ret_sts_unexp_error ;
        inv_rsv_trigger_global.g_from_trigger := FALSE;

      	if (fnd_msg_pub.check_msg_level
       	    (fnd_msg_pub.g_msg_lvl_unexp_error)) then
	    fnd_msg_pub.add_exc_msg(g_pkg_name, c_api_name);
      	end if;

end for_insert;

procedure for_update (
  p_reservation_id		IN	NUMBER
, x_return_status	        OUT NOCOPY	VARCHAR2
, x_msg_count	        	OUT NOCOPY	NUMBER
, x_msg_data     	        OUT NOCOPY	VARCHAR2 ) is

-- constants
c_api_name		constant varchar(30) := 'for_update';

-- variables
l_demand_source_type_id number;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
    x_return_status := fnd_api.g_ret_sts_success ;

    if (inv_rsv_trigger_global.g_from_trigger = FALSE) then
        inv_rsv_trigger_global.g_from_trigger := TRUE;

	select demand_source_type_id
	into l_demand_source_type_id
	from mtl_reservations
	where reservation_id = p_reservation_id;

	/* Update demand in MTL_DEMAND for Non-Orders */
	if (l_demand_source_type_id not in (2,8,12)) then
	 update mtl_demand a
         set (
 	  a.ORGANIZATION_ID
         ,a.INVENTORY_ITEM_ID
         ,a.DEMAND_SOURCE_TYPE
         ,a.DEMAND_SOURCE_HEADER_ID
         ,a.DEMAND_SOURCE_LINE
         ,a.DEMAND_SOURCE_DELIVERY
         ,a.DEMAND_SOURCE_NAME
         ,a.UOM_CODE
         ,a.LINE_ITEM_QUANTITY
         ,a.PRIMARY_UOM_QUANTITY
         ,a.LINE_ITEM_RESERVATION_QTY
         ,a.RESERVATION_QUANTITY
         ,a.COMPLETED_QUANTITY
         ,a.REQUIREMENT_DATE
 	 ,a.LAST_UPDATE_DATE
 	 ,a.LAST_UPDATED_BY
         ,a.CREATION_DATE
         ,a.CREATED_BY
         ,a.LAST_UPDATE_LOGIN
 	 ,a.REQUEST_ID
 	 ,a.PROGRAM_APPLICATION_ID
 	 ,a.PROGRAM_ID
 	 ,a.PROGRAM_UPDATE_DATE
 	 ,a.EXTERNAL_SOURCE_CODE
 	 ,a.EXTERNAL_SOURCE_LINE_ID
 	 ,a.USER_LINE_NUM
 	 ,a.USER_DELIVERY
 	 ,a.SCHEDULE_ID
 	 ,a.AUTODETAIL_GROUP_ID
 	 ,a.SUPPLY_SOURCE_TYPE
 	 ,a.SUPPLY_SOURCE_HEADER_ID
 	 ,a.SUPPLY_GROUP_ID
 	 ,a.UPDATED_FLAG
 	 ,a.REVISION
 	 ,a.LOT_NUMBER
 	 ,a.SERIAL_NUMBER
 	 ,a.SUBINVENTORY
 	 ,a.LOCATOR_ID
 	 ,a.COMPONENT_SEQUENCE_ID
 	 ,a.PARENT_COMPONENT_SEQ_ID
 	 ,a.RTO_MODEL_SOURCE_LINE
 	 ,a.RTO_PREVIOUS_QTY
 	 ,a.CONFIG_STATUS
 	 ,a.AVAILABLE_TO_MRP
 	 ,a.AVAILABLE_TO_ATP
 	 ,a.ESTIMATED_RELEASE_DATE
 	 ,a.DEMAND_CLASS
 	 ,a.ROW_STATUS_FLAG
 	 ,a.ORDER_CHANGE_REPORT_FLAG
 	 ,a.ATP_LEAD_TIME
 	 ,a.EXPLOSION_EFFECTIVITY_DATE
         ,a.BOM_LEVEL
         ,a.MRP_DATE
         ,a.MRP_QUANTITY
         ,a.CUSTOMER_ID
         ,a.TERRITORY_ID
         ,a.BILL_TO_SITE_USE_ID
         ,a.SHIP_TO_SITE_USE_ID
         ,a.MASTER_RESERVATION_QTY
         ,a.DESCRIPTION
         ,a.ATTRIBUTE_CATEGORY
         ,a.ATTRIBUTE1
         ,a.ATTRIBUTE2
         ,a.ATTRIBUTE3
         ,a.ATTRIBUTE4
         ,a.ATTRIBUTE5
         ,a.ATTRIBUTE6
         ,a.ATTRIBUTE7
 	 ,a.ATTRIBUTE8
 	 ,a.ATTRIBUTE9
 	 ,a.ATTRIBUTE10
 	 ,a.ATTRIBUTE11
 	 ,a.ATTRIBUTE12
 	 ,a.ATTRIBUTE13
 	 ,a.ATTRIBUTE14
 	 ,a.ATTRIBUTE15
 	 ,a.DEMAND_TYPE
 	 ,a.DUPLICATED_CONFIG_ITEM_ID
  	 ,a.DUPLICATED_CONFIG_DEMAND_ID
 	 ,a.EXPLOSION_GROUP_ID
 	 ,a.ORDERED_ITEM_ID
 	 ,a.CONFIG_GROUP_ID
 	 ,a.OPERATION_SEQ_NUM) = (
         select
 	  b.ORGANIZATION_ID
         ,b.INVENTORY_ITEM_ID
         ,b.DEMAND_SOURCE_TYPE_ID
         ,NVL(b.DEMAND_SOURCE_HEADER_ID,0)
         ,b.DEMAND_SOURCE_LINE_ID
         ,b.DEMAND_SOURCE_DELIVERY
         ,b.DEMAND_SOURCE_NAME
         ,b.RESERVATION_UOM_CODE
         ,b.RESERVATION_QUANTITY
         ,b.PRIMARY_RESERVATION_QUANTITY
         ,b.RESERVATION_QUANTITY
         ,b.PRIMARY_RESERVATION_QUANTITY
         ,0					/* COMPLETED_QUANTITY 	*/
         ,b.REQUIREMENT_DATE
 	 ,b.LAST_UPDATE_DATE
 	 ,b.LAST_UPDATED_BY
         ,b.CREATION_DATE
         ,b.CREATED_BY
         ,b.LAST_UPDATE_LOGIN
 	 ,b.REQUEST_ID
 	 ,b.PROGRAM_APPLICATION_ID
 	 ,b.PROGRAM_ID
 	 ,b.PROGRAM_UPDATE_DATE
 	 ,b.EXTERNAL_SOURCE_CODE
 	 ,b.EXTERNAL_SOURCE_LINE_ID
 	 ,NULL					/* USER_LINE_NUM	*/
 	 ,NULL					/* USER_DELIVERY	*/
 	 ,NULL					/* SCHEDULE_ID		*/
 	 ,b.AUTODETAIL_GROUP_ID
 	 ,decode(b.SUPPLY_SOURCE_TYPE_ID,13,NULL,b.SUPPLY_SOURCE_TYPE_ID)
 	 ,b.SUPPLY_SOURCE_HEADER_ID
 	 ,NULL					/* SUPPLY_GROUP_ID 	*/
 	 ,NULL					/* UPDATED_FLAG		*/
 	 ,b.REVISION
 	 ,b.LOT_NUMBER
 	 ,b.SERIAL_NUMBER
 	 ,b.SUBINVENTORY_CODE
 	 ,b.LOCATOR_ID
 	 ,NULL					/* COMPONENT_SEQUENCE_ID   */
 	 ,NULL					/* PARENT_COMPONENT_SEQ_ID */
 	 ,NULL					/* RTO_MODEL_SOURCE_LINE   */
 	 ,NULL					/* RTO_PREVIOUS_QTY	*/
 	 ,NULL					/* CONFIG_STATUS	*/
 	 ,1					/* AVAILABLE_TO_MRP	*/
 	 ,1					/* AVAILABLE_TO_ATP	*/
 	 ,NULL					/* ESTIMATED_RELEASE_DATE  */
 	 ,NULL					/* DEMAND_CLASS		*/
 	 ,1					/* ROW_STATUS_FLAG	*/
 	 ,NULL					/* ORDER_CHANGE_REPORT_FLAG */
 	 ,NULL					/* ATP_LEAD_TIME	*/
 	 ,NULL					/* EXPLOSION_EFFECTIVITY_DATE*/
         ,NULL					/* BOM_LEVEL		*/
         ,NULL					/* MRP_DATE		*/
         ,NULL					/* MRP_QUANTITY		*/
         ,NULL					/* CUSTOMER_ID		*/
         ,NULL					/* TERRITORY_ID		*/
         ,NULL					/* BILL_TO_SITE_USE_ID	*/
         ,NULL					/* SHIP_TO_SITE_USE_ID	*/
         ,NULL					/* MASTER_RESERVATION_QTY */
         ,NULL					/* DESCRIPTION		*/
         ,b.ATTRIBUTE_CATEGORY
         ,b.ATTRIBUTE1
         ,b.ATTRIBUTE2
         ,b.ATTRIBUTE3
         ,b.ATTRIBUTE4
         ,b.ATTRIBUTE5
         ,b.ATTRIBUTE6
         ,b.ATTRIBUTE7
 	 ,b.ATTRIBUTE8
 	 ,b.ATTRIBUTE9
 	 ,b.ATTRIBUTE10
 	 ,b.ATTRIBUTE11
 	 ,b.ATTRIBUTE12
 	 ,b.ATTRIBUTE13
 	 ,b.ATTRIBUTE14
 	 ,b.ATTRIBUTE15
 	 ,NULL			/* DEMAND_TYPE 			*/
 	 ,NULL			/* DUPLICATED_CONFIG_ITEM_ID 	*/
 	 ,NULL			/* DUPLICATED_CONFIG_DEMAND_ID 	*/
 	 ,NULL			/* EXPLOSION_GROUP_ID		*/
 	 ,NULL			/* ORDERED_ITEM_ID		*/
 	 ,NULL			/* CONFIG_GROUP_ID		*/
 	 ,NULL			/* OPERATION_SEQ_NUM		*/
         from mtl_reservations b
         where   b.reservation_id   = p_reservation_id)
	 where a.n_column1        = p_reservation_id
	 and   a.reservation_type = 1
	 and   a.parent_demand_id is null;
	end if;

	/* Update reservation in MTL_DEMAND */
	update mtl_demand a
        set (
 	 a.ORGANIZATION_ID
        ,a.INVENTORY_ITEM_ID
        ,a.DEMAND_SOURCE_TYPE
        ,a.DEMAND_SOURCE_HEADER_ID
        ,a.DEMAND_SOURCE_LINE
        ,a.DEMAND_SOURCE_DELIVERY
        ,a.DEMAND_SOURCE_NAME
        ,a.UOM_CODE
        ,a.LINE_ITEM_QUANTITY
        ,a.PRIMARY_UOM_QUANTITY
        ,a.LINE_ITEM_RESERVATION_QTY
        ,a.RESERVATION_QUANTITY
        ,a.COMPLETED_QUANTITY
        ,a.REQUIREMENT_DATE
 	,a.LAST_UPDATE_DATE
 	,a.LAST_UPDATED_BY
        ,a.CREATION_DATE
        ,a.CREATED_BY
        ,a.LAST_UPDATE_LOGIN
 	,a.REQUEST_ID
 	,a.PROGRAM_APPLICATION_ID
 	,a.PROGRAM_ID
 	,a.PROGRAM_UPDATE_DATE
 	,a.EXTERNAL_SOURCE_CODE
 	,a.EXTERNAL_SOURCE_LINE_ID
 	,a.USER_LINE_NUM
 	,a.USER_DELIVERY
 	,a.SCHEDULE_ID
 	,a.AUTODETAIL_GROUP_ID
 	,a.SUPPLY_SOURCE_TYPE
 	,a.SUPPLY_SOURCE_HEADER_ID
 	,a.SUPPLY_GROUP_ID
 	,a.UPDATED_FLAG
 	,a.REVISION
 	,a.LOT_NUMBER
 	,a.SERIAL_NUMBER
 	,a.SUBINVENTORY
 	,a.LOCATOR_ID
 	,a.COMPONENT_SEQUENCE_ID
 	,a.PARENT_COMPONENT_SEQ_ID
 	,a.RTO_MODEL_SOURCE_LINE
 	,a.RTO_PREVIOUS_QTY
 	,a.CONFIG_STATUS
 	,a.AVAILABLE_TO_MRP
 	,a.AVAILABLE_TO_ATP
 	,a.ESTIMATED_RELEASE_DATE
 	,a.DEMAND_CLASS
 	,a.ROW_STATUS_FLAG
 	,a.ORDER_CHANGE_REPORT_FLAG
 	,a.ATP_LEAD_TIME
 	,a.EXPLOSION_EFFECTIVITY_DATE
        ,a.BOM_LEVEL
        ,a.MRP_DATE
        ,a.MRP_QUANTITY
        ,a.CUSTOMER_ID
        ,a.TERRITORY_ID
        ,a.BILL_TO_SITE_USE_ID
        ,a.SHIP_TO_SITE_USE_ID
        ,a.MASTER_RESERVATION_QTY
        ,a.DESCRIPTION
        ,a.ATTRIBUTE_CATEGORY
        ,a.ATTRIBUTE1
        ,a.ATTRIBUTE2
        ,a.ATTRIBUTE3
        ,a.ATTRIBUTE4
        ,a.ATTRIBUTE5
        ,a.ATTRIBUTE6
        ,a.ATTRIBUTE7
 	,a.ATTRIBUTE8
 	,a.ATTRIBUTE9
 	,a.ATTRIBUTE10
 	,a.ATTRIBUTE11
 	,a.ATTRIBUTE12
 	,a.ATTRIBUTE13
 	,a.ATTRIBUTE14
 	,a.ATTRIBUTE15
 	,a.DEMAND_TYPE
 	,a.DUPLICATED_CONFIG_ITEM_ID
 	,a.DUPLICATED_CONFIG_DEMAND_ID
 	,a.EXPLOSION_GROUP_ID
 	,a.ORDERED_ITEM_ID
 	,a.CONFIG_GROUP_ID
 	,a.OPERATION_SEQ_NUM
        ,a.RESERVATION_TYPE) = (
        select
 	 b.ORGANIZATION_ID
        ,b.INVENTORY_ITEM_ID
        ,b.DEMAND_SOURCE_TYPE_ID
        ,NVL(b.DEMAND_SOURCE_HEADER_ID,0)
        ,b.DEMAND_SOURCE_LINE_ID
        ,b.DEMAND_SOURCE_DELIVERY
        ,b.DEMAND_SOURCE_NAME
        ,b.RESERVATION_UOM_CODE
        ,b.RESERVATION_QUANTITY
        ,b.PRIMARY_RESERVATION_QUANTITY
        ,NULL					/* RESERVATION_QUANTITY */
        ,NULL					/* PRIM_RESERVATION_QUANTITY */
        ,0					/* COMPLETED_QUANTITY 	*/
        ,b.REQUIREMENT_DATE
 	,b.LAST_UPDATE_DATE
 	,b.LAST_UPDATED_BY
        ,b.CREATION_DATE
        ,b.CREATED_BY
        ,b.LAST_UPDATE_LOGIN
 	,b.REQUEST_ID
 	,b.PROGRAM_APPLICATION_ID
 	,b.PROGRAM_ID
 	,b.PROGRAM_UPDATE_DATE
 	,b.EXTERNAL_SOURCE_CODE
 	,b.EXTERNAL_SOURCE_LINE_ID
 	,NULL					/* USER_LINE_NUM	*/
 	,NULL					/* USER_DELIVERY	*/
 	,NULL					/* SCHEDULE_ID		*/
 	,b.AUTODETAIL_GROUP_ID
 	,decode(b.SUPPLY_SOURCE_TYPE_ID,13,NULL,b.SUPPLY_SOURCE_TYPE_ID)
 	,b.SUPPLY_SOURCE_HEADER_ID
 	,NULL					/* SUPPLY_GROUP_ID 	*/
 	,NULL					/* UPDATED_FLAG		*/
 	,b.REVISION
 	,b.LOT_NUMBER
 	,b.SERIAL_NUMBER
 	,b.SUBINVENTORY_CODE
 	,b.LOCATOR_ID
 	,NULL					/* COMPONENT_SEQUENCE_ID   */
 	,NULL					/* PARENT_COMPONENT_SEQ_ID */
 	,NULL					/* RTO_MODEL_SOURCE_LINE   */
 	,NULL					/* RTO_PREVIOUS_QTY	*/
 	,NULL					/* CONFIG_STATUS	*/
 	,1					/* AVAILABLE_TO_MRP	*/
 	,1					/* AVAILABLE_TO_ATP	*/
 	,NULL					/* ESTIMATED_RELEASE_DATE  */
 	,NULL					/* DEMAND_CLASS		*/
 	,1					/* ROW_STATUS_FLAG	*/
 	,NULL					/* ORDER_CHANGE_REPORT_FLAG */
 	,NULL					/* ATP_LEAD_TIME	*/
 	,NULL					/* EXPLOSION_EFFECTIVITY_DATE*/
        ,NULL					/* BOM_LEVEL		*/
        ,NULL					/* MRP_DATE		*/
        ,NULL					/* MRP_QUANTITY		*/
        ,NULL					/* CUSTOMER_ID		*/
        ,NULL					/* TERRITORY_ID		*/
        ,NULL					/* BILL_TO_SITE_USE_ID	*/
        ,NULL					/* SHIP_TO_SITE_USE_ID	*/
        ,NULL					/* MASTER_RESERVATION_QTY */
        ,NULL					/* DESCRIPTION		*/
        ,b.ATTRIBUTE_CATEGORY
        ,b.ATTRIBUTE1
        ,b.ATTRIBUTE2
        ,b.ATTRIBUTE3
        ,b.ATTRIBUTE4
        ,b.ATTRIBUTE5
        ,b.ATTRIBUTE6
        ,b.ATTRIBUTE7
 	,b.ATTRIBUTE8
 	,b.ATTRIBUTE9
 	,b.ATTRIBUTE10
 	,b.ATTRIBUTE11
 	,b.ATTRIBUTE12
 	,b.ATTRIBUTE13
 	,b.ATTRIBUTE14
 	,b.ATTRIBUTE15
 	,NULL					/* DEMAND_TYPE 			*/
 	,NULL					/* DUPLICATED_CONFIG_ITEM_ID 	*/
 	,NULL					/* DUPLICATED_CONFIG_DEMAND_ID 	*/
 	,NULL					/* EXPLOSION_GROUP_ID		*/
 	,NULL					/* ORDERED_ITEM_ID		*/
 	,NULL					/* CONFIG_GROUP_ID		*/
 	,NULL					/* OPERATION_SEQ_NUM		*/
        ,decode(b.SUPPLY_SOURCE_TYPE_ID,13,2,3) /* RESERVATION_TYPE     	*/
        from mtl_reservations b
        where   b.reservation_id   = p_reservation_id)
	where a.n_column1        = p_reservation_id
	and   a.reservation_type in (2,3)
	and   a.parent_demand_id is not null;

        inv_rsv_trigger_global.g_from_trigger := FALSE;
    end if;

    exception
      when fnd_api.g_exc_error then
     	x_return_status := fnd_api.g_ret_sts_error ;
        inv_rsv_trigger_global.g_from_trigger := FALSE;

      when fnd_api.g_exc_unexpected_error then
    	x_return_status := fnd_api.g_ret_sts_unexp_error ;
        inv_rsv_trigger_global.g_from_trigger := FALSE;

      when others then
     	x_return_status := fnd_api.g_ret_sts_unexp_error ;
        inv_rsv_trigger_global.g_from_trigger := FALSE;

      	if (fnd_msg_pub.check_msg_level
       	    (fnd_msg_pub.g_msg_lvl_unexp_error)) then
	    fnd_msg_pub.add_exc_msg(g_pkg_name, c_api_name);
      	end if;

end for_update;

procedure for_delete (
  p_reservation_id		IN	NUMBER
, x_return_status	        OUT NOCOPY	VARCHAR2
, x_msg_count	        	OUT NOCOPY	NUMBER
, x_msg_data     	        OUT NOCOPY	VARCHAR2 ) is

-- constants
c_api_name		constant varchar(30) := 'for_delete';

-- variables
l_demand_source_type_id number;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
    x_return_status := fnd_api.g_ret_sts_success ;

    if (inv_rsv_trigger_global.g_from_trigger = FALSE) then
        inv_rsv_trigger_global.g_from_trigger := TRUE;

	select demand_source_type_id
	into l_demand_source_type_id
	from mtl_reservations
	where reservation_id = p_reservation_id;

	/* Delete demand in MTL_DEMAND for Non-Orders */
	if (l_demand_source_type_id not in (2,8,12)) then
	 delete mtl_demand
	 where n_column1 = p_reservation_id
         and   reservation_type = 1
	 and   parent_demand_id is null;
	end if;

	/* Delete reservation in MTL_DEMAND */
	delete mtl_demand
	where n_column1 = p_reservation_id
        and   reservation_type in (2,3)
	and   parent_demand_id is not null;

        inv_rsv_trigger_global.g_from_trigger := FALSE;
    end if;

    exception
      when fnd_api.g_exc_error then
     	x_return_status := fnd_api.g_ret_sts_error ;
        inv_rsv_trigger_global.g_from_trigger := FALSE;

      when fnd_api.g_exc_unexpected_error then
    	x_return_status := fnd_api.g_ret_sts_unexp_error ;
        inv_rsv_trigger_global.g_from_trigger := FALSE;

      when others then
     	x_return_status := fnd_api.g_ret_sts_unexp_error ;
        inv_rsv_trigger_global.g_from_trigger := FALSE;

      	if (fnd_msg_pub.check_msg_level
       	    (fnd_msg_pub.g_msg_lvl_unexp_error)) then
	    fnd_msg_pub.add_exc_msg(g_pkg_name, c_api_name);
      	end if;

end for_delete;

procedure for_relieve (
  p_reservation_id		IN	NUMBER
, p_primary_relieved_quantity	IN	NUMBER
, x_return_status	        OUT NOCOPY	VARCHAR2
, x_msg_count	        	OUT NOCOPY	NUMBER
, x_msg_data     	        OUT NOCOPY	VARCHAR2 ) is

-- constants
c_api_name		constant varchar(30) := 'for_relieve';

-- variables
l_demand_source_type_id number;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
    --inv_debug.message('tst115', 'in for_relieve');
    --inv_debug.message('tst115', 'p_reservation_id is ' || p_reservation_id);

    x_return_status := fnd_api.g_ret_sts_success ;

    if (inv_rsv_trigger_global.g_from_trigger = FALSE) then
        inv_rsv_trigger_global.g_from_trigger := TRUE;

	    select demand_source_type_id
	    into l_demand_source_type_id
	    from mtl_reservations
	    where reservation_id = p_reservation_id;

	    --inv_debug.message('tst115', 'l_demand_source_type_id is ' || l_demand_source_type_id);

	    /* Update completed_quantity for demand in MTL_DEMAND for Non-Orders */
	    if (l_demand_source_type_id not in (2,8,12)) then
	       begin
	           --inv_debug.message('tst115', 'update mtl_demand for non-orders');
	 	   update mtl_demand
	           set completed_quantity = completed_quantity + p_primary_relieved_quantity
	           where n_column1 = p_reservation_id
                   and   reservation_type = 1
	           and   parent_demand_id is null;
	       exception
			when no_data_found then
				null;
	       end;
            end if;

	    /* Update completed_quantity for reservation in MTL_DEMAND */
	    begin
	           --inv_debug.message('tst115', 'update mtl_demand for orders');
	           update mtl_demand
	           set completed_quantity = completed_quantity + p_primary_relieved_quantity
	           where n_column1 = p_reservation_id
                   and   reservation_type in (2,3)
	           and   parent_demand_id is not null;
	    exception
			when no_data_found then
				null;
	    end;

            inv_rsv_trigger_global.g_from_trigger := FALSE;
    end if;
    --inv_debug.message('tst115', 'return from inv_rsv_synch.for_relieve');
exception
    when fnd_api.g_exc_error then
    	   x_return_status := fnd_api.g_ret_sts_error ;
        inv_rsv_trigger_global.g_from_trigger := FALSE;

    when fnd_api.g_exc_unexpected_error then
    	   x_return_status := fnd_api.g_ret_sts_unexp_error ;
        inv_rsv_trigger_global.g_from_trigger := FALSE;

    when others then
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        inv_rsv_trigger_global.g_from_trigger := FALSE;

        if (fnd_msg_pub.check_msg_level
       	    (fnd_msg_pub.g_msg_lvl_unexp_error)) then
	          fnd_msg_pub.add_exc_msg(g_pkg_name, c_api_name);
        end if;
end for_relieve;

end INV_RSV_SYNCH;

/
