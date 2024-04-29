--------------------------------------------------------
--  DDL for Package Body WMS_REPLENISHMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_REPLENISHMENT_PUB" AS
/* $Header: WMSREPPB.pls 120.11 2008/04/01 01:45:39 satkumar noship $ */


PROCEDURE DYNAMIC_REPLENISHMENT(p_organization_id                   IN NUMBER,
				P_Batch_id                 IN NUMBER,
                                p_Plan_Tasks               IN VARCHAR2,
                                p_Release_Sequence_Rule_Id IN NUMBER,
                                P_repl_level               IN NUMBER DEFAULT 1,
                                x_msg_count                OUT NOCOPY NUMBER,
                                x_return_status            OUT NOCOPY VARCHAR2,
                                x_msg_data                 OUT nocopy VARCHAR2) IS

BEGIN

   wms_replenishment_pvt.DYNAMIC_REPLENISHMENT( p_org_id=>p_organization_id,
						P_Batch_id=>p_batch_id,
						p_Plan_Tasks=>p_plan_tasks,
						p_Release_Sequence_Rule_Id=>p_Release_Sequence_Rule_Id,
						x_msg_count=>x_msg_count,
						x_return_status=>x_return_status,
						x_msg_data=>x_msg_data);

END dynamic_replenishment;


PROCEDURE DYNAMIC_REPLENISHMENT_CP(
				   errbuf                OUT NOCOPY VARCHAR2,
				   retcode               OUT NOCOPY NUMBER,
				   P_Batch_id                 IN NUMBER,
				   p_organization_id          IN NUMBER,
				   p_Plan_Tasks               IN VARCHAR2,
				   p_Release_Sequence_Rule_Id IN NUMBER
				   ) is
x_msg_count number;
x_return_status VARCHAR2(1);
x_msg_data VARCHAR2(100);

begin

   --Calling Dynamic Replenishment
   wms_replenishment_pvt.DYNAMIC_REPLENISHMENT( p_org_id=>p_organization_id,
						P_Batch_id=>p_batch_id,
						p_Plan_Tasks=>p_plan_tasks,
						p_Release_Sequence_Rule_Id=>p_Release_Sequence_Rule_Id,
						x_msg_count=>x_msg_count,
						x_return_status=>x_return_status,
						x_msg_data=>x_msg_data);

   errbuf := x_msg_data;
   IF X_RETURN_status <> fnd_api.g_ret_sts_success THEN
      -- Error
      retcode := 2;
    ELSE -- Success
      retcode := 0;
   END IF;

END Dynamic_Replenishment_CP;


PROCEDURE PUSH_REPLENISHMENT_CP(
				errbuf                OUT NOCOPY VARCHAR2,
				retcode               OUT NOCOPY NUMBER,
				p_organization_id           IN NUMBER,
				p_Item_id                   IN NUMBER,
				p_ABC_assignment_group_id   IN NUMBER, -- For ABC Compile Group
				p_abc_class_id              IN NUMBER, -- For Item Classification
				p_Order_Type_id             IN NUMBER,
				p_customer_class            IN VARCHAR2,
				p_customer_id               IN NUMBER,
				p_Carrier_id                IN NUMBER,
				p_Ship_Method_code          IN VARCHAR2,
				p_Scheduled_Ship_Date_To    IN NUMBER,
				p_Scheduled_Ship_Date_From  IN NUMBER,
				p_Forward_Pick_Sub          IN VARCHAR2,
				p_repl_UOM                  IN VARCHAR2,
				p_Repl_Lot_Size             IN NUMBER,
				p_Min_Order_lines_threshold IN NUMBER,
				p_Min_repl_qty_threshold    IN NUMBER,
				p_max_NUM_items_for_repl    IN NUMBER,
				p_Sort_Criteria             IN NUMBER,
				p_Release_Sequence_Rule_Id  IN NUMBER,
        p_Create_Reservation        IN VARCHAR2,
        p_Auto_Allocate             IN VARCHAR2,
  			p_Plan_Tasks                IN VARCHAR2) IS

     x_msg_count number;
     x_return_status VARCHAR2(1);
     x_msg_data VARCHAR2(100);


BEGIN


   wms_replenishment_pvt.PUSH_REPLENISHMENT(
					    p_repl_level=>1,
					    p_Item_id => p_Item_id,
					    p_organization_id => p_organization_id,
					    p_ABC_assignment_group_id => p_ABC_assignment_group_id,
					    p_abc_class_id => p_abc_class_id,
					    p_Order_Type_id => p_Order_Type_id,
					    p_Carrier_id => p_Carrier_id,
					    p_customer_class => p_customer_class,
					    p_customer_id => p_customer_id,
					    p_Ship_Method_code => p_Ship_Method_code,
					    p_Scheduled_Ship_Date_To => p_Scheduled_Ship_Date_To,
					    p_Scheduled_Ship_Date_From => p_Scheduled_Ship_Date_From,
					    p_Forward_Pick_Sub => p_Forward_Pick_Sub,
					    p_repl_UOM => p_repl_UOM,
					    p_Repl_Lot_Size => p_Repl_Lot_Size,
					    p_Release_Sequence_Rule_Id => p_Release_Sequence_Rule_Id,
					    p_Min_Order_lines_threshold => p_Min_Order_lines_threshold,
					    p_Min_repl_qty_threshold => p_Min_repl_qty_threshold,
					    p_max_NUM_items_for_repl => p_max_NUM_items_for_repl,
					    p_Sort_Criteria => p_Sort_Criteria,
     p_Auto_Allocate =>p_auto_allocate,
     p_Plan_Tasks =>p_Plan_Tasks,
     p_Create_Reservation =>p_Create_Reservation,
     x_return_status => x_return_status,
     x_msg_count => x_msg_count,
     x_msg_data => x_msg_data);


   errbuf := x_msg_data;

 IF X_RETURN_status <> fnd_api.g_ret_sts_success THEN
      -- Error
      retcode := 2;
    ELSE -- Success
      retcode := 0;
   END IF;

END push_replenishment_cp;



PROCEDURE PUSH_REPLENISHMENT(P_repl_level                IN NUMBER DEFAULT 1,
			     p_Item_id                   IN NUMBER,
			     p_organization_id           IN NUMBER,
			     p_ABC_assignment_group_id   IN NUMBER, -- For ABC Compile Group
			     p_abc_class_id              IN NUMBER, -- For Item Classification
			     p_Order_Type_id             IN NUMBER,
			     p_Carrier_id                IN NUMBER,
			     p_customer_class            IN VARCHAR2,
			     p_customer_id               IN NUMBER,
			     p_Ship_Method_code          IN VARCHAR2,
			     p_Scheduled_Ship_Date_To    IN NUMBER,
			     p_Scheduled_Ship_Date_From  IN NUMBER,
			     p_Forward_Pick_Sub          IN VARCHAR2,
			     p_repl_UOM                  IN VARCHAR2,
			     p_Repl_Lot_Size             IN NUMBER,
			     p_Min_Order_lines_threshold IN NUMBER,
			     p_Min_repl_qty_threshold    IN NUMBER,
			     p_max_NUM_items_for_repl    IN NUMBER,
			     p_Sort_Criteria             IN NUMBER,
			     p_Auto_Allocate             IN VARCHAR2,
  p_Plan_Tasks                IN VARCHAR2,
  p_Release_Sequence_Rule_Id  IN NUMBER,
  p_Create_Reservation        IN VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY
   VARCHAR2) IS


 BEGIN

    wms_replenishment_pvt.PUSH_REPLENISHMENT(
					    p_repl_level=>1,
					    p_Item_id => p_Item_id,
					    p_organization_id => p_organization_id,
					    p_ABC_assignment_group_id => p_ABC_assignment_group_id,
					    p_abc_class_id => p_abc_class_id,
					    p_Order_Type_id => p_Order_Type_id,
					    p_Carrier_id => p_Carrier_id,
					    p_customer_class => p_customer_class,
					    p_customer_id => p_customer_id,
					    p_Ship_Method_code => p_Ship_Method_code,
					    p_Scheduled_Ship_Date_To => p_Scheduled_Ship_Date_To,
					    p_Scheduled_Ship_Date_From => p_Scheduled_Ship_Date_From,
					    p_Forward_Pick_Sub => p_Forward_Pick_Sub,
					    p_repl_UOM => p_repl_UOM,
					    p_Repl_Lot_Size => p_Repl_Lot_Size,
					    p_Release_Sequence_Rule_Id => p_Release_Sequence_Rule_Id,
					    p_Min_Order_lines_threshold => p_Min_Order_lines_threshold,
					    p_Min_repl_qty_threshold => p_Min_repl_qty_threshold,
					    p_max_NUM_items_for_repl => p_max_NUM_items_for_repl,
					    p_Sort_Criteria => p_Sort_Criteria,
     p_Auto_Allocate =>p_Auto_Allocate,
     p_Plan_Tasks =>p_Plan_Tasks,
     p_Create_Reservation =>p_Create_Reservation,
     x_return_status => x_return_status,
     x_msg_count => x_msg_count,
     x_msg_data => x_msg_data);

 END push_replenishment;

 PROCEDURE UPDATE_DELIVERY_DETAIL (
				   p_delivery_detail_id IN NUMBER,
				   P_PRIMARY_QUANTITY IN NUMBER,
				   P_SPLIT_DELIVERY_DETAIL_ID IN NUMBER DEFAULT NULL,
				   p_split_source_line_id     IN NUMBER DEFAULT NULL,
				   x_return_status              OUT             NOCOPY VARCHAR2
				   ) IS

 BEGIN



    wms_replenishment_pvt.UPDATE_DELIVERY_DETAIL (
						  p_delivery_detail_id =>p_delivery_detail_id ,
						  P_PRIMARY_QUANTITY   =>P_PRIMARY_QUANTITY ,
						  P_SPLIT_DELIVERY_DETAIL_ID =>P_SPLIT_DELIVERY_DETAIL_ID ,
						  p_split_source_line_id  => p_split_source_line_id,
						  x_return_status         =>x_return_status
						  );



 END update_delivery_detail;


 PROCEDURE allocate_repl_move_order_cp (errbuf                OUT NOCOPY VARCHAR2,
					retcode               OUT nocopy NUMBER,
					p_Quantity_function_id IN VARCHAR2)
   IS

      x_msg_count number;
      x_return_status VARCHAR2(1);
      x_msg_data VARCHAR2(100);
      L_quantity_function_id VARCHAR2(10);

 BEGIN
    --Code added to bug 6885177
    if p_Quantity_function_id = 'NULL' THEN

       L_Quantity_function_id := NULL;
     ELSE
        L_Quantity_function_id := p_Quantity_function_id ;

    end if;
    -- code ended for Bug 6885177

    wms_replenishment_pvt.allocate_repl_move_order
      (
       p_Quantity_function_id => L_quantity_function_id,
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data);

    errbuf := x_msg_data;
    IF X_RETURN_status <> fnd_api.g_ret_sts_success THEN
       -- Error
       retcode := 2;
     ELSE -- Success
       retcode := 0;
    END IF;

 END allocate_repl_move_order_cp;


 END wms_replenishment_pub;

/
