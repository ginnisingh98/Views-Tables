--------------------------------------------------------
--  DDL for Package WMS_REPLENISHMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_REPLENISHMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSREPPS.pls 120.8 2008/04/01 01:44:45 satkumar noship $ */


PROCEDURE DYNAMIC_REPLENISHMENT_CP(
				   errbuf                OUT NOCOPY VARCHAR2,
				   retcode               OUT NOCOPY NUMBER,
				   P_Batch_id                 IN NUMBER,
				   p_organization_id          IN NUMBER,
				   p_Plan_Tasks               IN VARCHAR2,
				   p_Release_Sequence_Rule_Id IN NUMBER
				   );

PROCEDURE DYNAMIC_REPLENISHMENT(p_organization_id                  IN NUMBER,
				P_Batch_id                 IN NUMBER,
                                p_Plan_Tasks               IN VARCHAR2,
                                p_Release_Sequence_Rule_Id IN NUMBER,
                                P_repl_level               IN NUMBER DEFAULT 1,
                                x_msg_count                OUT NOCOPY NUMBER,
                                x_return_status            OUT NOCOPY VARCHAR2,
                                x_msg_data                 OUT NOCOPY VARCHAR2);


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
  			p_Plan_Tasks                IN VARCHAR2);


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
                               x_msg_data                  OUT NOCOPY VARCHAR2);


PROCEDURE UPDATE_DELIVERY_DETAIL (
				  p_delivery_detail_id IN NUMBER,
				  P_PRIMARY_QUANTITY IN NUMBER,
				  P_SPLIT_DELIVERY_DETAIL_ID IN NUMBER DEFAULT NULL,
				  p_split_source_line_id     IN NUMBER DEFAULT NULL,
				  x_return_status              OUT             NOCOPY VARCHAR2
				  );

PROCEDURE allocate_repl_move_order_cp (	errbuf                OUT NOCOPY VARCHAR2,
					retcode               OUT nocopy NUMBER,
					p_Quantity_function_id IN VARCHAR2);



END wms_replenishment_pub;

/
