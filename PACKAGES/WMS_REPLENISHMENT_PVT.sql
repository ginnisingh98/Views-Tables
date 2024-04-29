--------------------------------------------------------
--  DDL for Package WMS_REPLENISHMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_REPLENISHMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSREPVS.pls 120.6 2008/04/01 01:43:33 satkumar noship $  */

TYPE psrTyp IS RECORD (
       attribute_name   VARCHAR2(30),
       priority      NUMBER,
       sort_order     VARCHAR2(4));

     TYPE psrTabTyp IS TABLE OF psrTyp INDEX BY BINARY_INTEGER;



     TYPE CONSOL_ITEM_REPL_REC IS RECORD
          (
          Organization_id NUMBER,
          Item_id NUMBER,
          Repl_To_Subinventory_code VARCHAR2(10),
          Repl_UOM_code VARCHAR2(3),
          total_demand_qty NUMBER,
          available_onhand_qty NUMBER,
          open_mo_qty NUMBER,
          final_replenishment_qty NUMBER,
          date_required DATE
           );
      --ajith changed the IS TABLE OF CONSOL_ITEM_REPL_CUR to CONSOL_ITEM_REPL_REC
     TYPE CONSOL_ITEM_REPL_TBL IS TABLE OF CONSOL_ITEM_REPL_REC INDEX BY BINARY_INTEGER;

      -- to be used for bulk processing in the code
      TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE uom_tab IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
      TYPE date_tab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
      TYPE char_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
      TYPE char1_tab IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

    -- The following types are used to cache the UOM conversions.  The three keys to this
    -- are the inventory item, from UOM code, and to UOM code.  This will yield the conversion
    -- rate by using a nested PLSQL table structure.
    TYPE to_uom_code_tb IS TABLE OF NUMBER INDEX BY VARCHAR2(3);
    TYPE from_uom_code_tb IS TABLE OF to_uom_code_tb INDEX BY VARCHAR2(3);
    TYPE item_uom_conversion_tb IS TABLE OF from_uom_code_tb INDEX BY BINARY_INTEGER;

    g_item_uom_conversion_tb      item_uom_conversion_tb;

    G_TRACE_ON NUMBER  := NVL(fnd_profile.value('INV_DEBUG_TRACE'),2);


    FUNCTION get_conversion_rate(p_item_id       IN NUMBER,
                                 p_from_uom_code IN VARCHAR2,
                                 p_to_uom_code   IN VARCHAR2) RETURN NUMBER;


    PROCEDURE DYNAMIC_REPLENISHMENT(p_org_id IN NUMBER,
				    P_Batch_id                 IN NUMBER,
				    p_Plan_Tasks               IN VARCHAR2,
				    p_Release_Sequence_Rule_Id IN NUMBER,
				    P_repl_level               IN NUMBER DEFAULT 1,
				    x_msg_count                OUT NOCOPY NUMBER,
				    x_return_status            OUT NOCOPY VARCHAR2,
				    x_msg_data                 OUT NOCOPY VARCHAR2);

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


 PROCEDURE PROCESS_REPLENISHMENT(
				 p_Repl_level           IN NUMBER,
				 p_repl_type            IN NUMBER,
				 p_Repl_Lot_Size        IN NUMBER,
				 P_consol_item_repl_tbl IN OUT NOCOPY CONSOL_ITEM_REPL_TBL, --ajith changed
				 p_Create_Reservation   IN VARCHAR2,
				 p_Auto_Allocate        IN VARCHAR2,
				 p_Plan_Tasks           IN VARCHAR2,
				 x_return_status        OUT NOCOPY VARCHAR2,
				 x_msg_count            OUT NOCOPY NUMBER,
				 x_msg_data             OUT NOCOPY VARCHAR2);




 PROCEDURE CREATE_REPL_MOVE_ORDER(p_Repl_level           IN NUMBER,
				  p_repl_type            IN NUMBER,
				  p_consol_item_repl_tbl IN OUT NOCOPY CONSOL_ITEM_REPL_TBL,
				  p_Create_Reservation   IN VARCHAR2,
				  p_Repl_Lot_Size        IN NUMBER,
				  p_Auto_Allocate        IN VARCHAR2,
				  p_Plan_Tasks           IN VARCHAR2,
				  x_return_status        OUT NOCOPY VARCHAR2,
				  x_msg_count            OUT NOCOPY NUMBER,
				  x_msg_data             OUT NOCOPY VARCHAR2);

 PROCEDURE Get_Source_Sub_Dest_Loc_Info(p_Org_id             IN NUMBER,
                                       p_Item_id             IN NUMBER,
                                       p_Picking_Sub         IN VARCHAR2,
                                       x_source_sub          OUT NOCOPY  VARCHAR2,
				       x_src_pick_uom        OUT NOCOPY  VARCHAR2,
                                       x_MAX_MINMAX_QUANTITY OUT nocopy  NUMBER,
				       x_fixed_lot_multiple  OUT nocopy  NUMBER,
					x_return_status      OUT nocopy VARCHAR2) ;


 PROCEDURE GET_OPEN_MO_QTY(p_Repl_level           IN NUMBER,
			   p_repl_type            IN NUMBER,
			   p_Create_Reservation   IN  VARCHAR2,
			   x_consol_item_repl_tbl IN OUT NOCOPY CONSOL_ITEM_REPL_TBL,
			   x_return_status        OUT NOCOPY VARCHAR2,
			   x_msg_count            OUT NOCOPY NUMBER,
			   x_msg_data             OUT NOCOPY VARCHAR2);


 PROCEDURE GET_AVAILABLE_ONHAND_QTY(p_Repl_level           IN NUMBER,
				    p_repl_type            IN NUMBER,
				    p_Create_Reservation   IN VARCHAR2,
				    x_consol_item_repl_tbl IN OUT NOCOPY CONSOL_ITEM_REPL_TBL,
				    x_return_status        OUT NOCOPY VARCHAR2,
				    x_msg_count            OUT NOCOPY NUMBER,
				    x_msg_data             OUT NOCOPY VARCHAR2);

 FUNCTION get_available_capacity(p_quantity_function    IN NUMBER,
                                 p_organization_id      IN NUMBER,
                                 p_subinventory_code    IN VARCHAR2,
                                 p_locator_id           IN NUMBER,
                                 p_inventory_item_id    IN NUMBER,
                                 p_unit_volume          IN NUMBER,
                                 p_unit_volume_uom_code IN VARCHAR2,
                                 p_unit_weight          IN NUMBER,
                                 p_unit_weight_uom_code IN VARCHAR2,
                                 p_primary_uom          IN VARCHAR2,
                                 p_transaction_uom      IN VARCHAR2,
                                 p_base_uom             IN VARCHAR2,
                                 p_transaction_quantity IN NUMBER)
   RETURN NUMBER;


 PROCEDURE allocate_repl_move_order(
				    p_Quantity_function_id IN NUMBER,
				    x_return_status             OUT NOCOPY VARCHAR2,
				    x_msg_count                 OUT NOCOPY NUMBER,
				    x_msg_data                  OUT nocopy VARCHAR2
				    );


 PROCEDURE CREATE_RSV(p_replenishment_type     IN NUMBER, --  1- Stock Up/Push; 2- Dynamic
                       l_debug                 IN NUMBER,
                       l_organization_id       IN NUMBER,
                       l_inventory_item_id     IN NUMBER,
                       l_demand_type_id        IN NUMBER,
                       l_demand_so_header_id   IN NUMBER,
                       l_demand_line_id        IN NUMBER,
                       l_split_wdd_id          IN NUMBER,
                       l_primary_uom_code      IN VARCHAR2,
                       l_supply_uom_code       IN VARCHAR2,
                       l_atd_qty               IN NUMBER,
                       l_atd_prim_qty          IN NUMBER,
                       l_supply_type_id        IN NUMBER,
                       l_supply_header_id      IN NUMBER,
                       l_supply_line_id        IN NUMBER,
                       l_supply_line_detail_id IN NUMBER,
                       l_supply_expected_time  IN DATE,
                       l_demand_expected_time  IN DATE,
                       l_subinventory_code     IN VARCHAR2  DEFAULT NULL,
                       l_rsv_rec               IN OUT NOCOPY inv_reservation_global.mtl_reservation_rec_type,
                       l_serial_number         IN OUT NOCOPY inv_reservation_global.serial_number_tbl_type,
                       l_to_serial_number      IN OUT NOCOPY inv_reservation_global.serial_number_tbl_type,
                       l_quantity_reserved     IN OUT NOCOPY NUMBER,
                       l_quantity_reserved2    IN OUT NOCOPY NUMBER,
                       l_rsv_id                IN OUT NOCOPY NUMBER,
                       x_return_status         IN OUT NOCOPY VARCHAR2,
                       x_msg_count             IN OUT NOCOPY NUMBER,
                       x_msg_data              IN OUT NOCOPY VARCHAR2);

 PROCEDURE Get_to_Sub_For_Dynamic_Repl(P_Org_id               IN NUMBER,
                                      P_Item_id              IN NUMBER,
                                      P_PRIMARY_DEMAND_QTY   IN NUMBER,
                                      X_TO_SUBINVENTORY_CODE IN OUT NOCOPY VARCHAR2,
                                      X_REPL_UOM_CODE        OUT NOCOPY VARCHAR2);


 PROCEDURE POPULATE_DYNAMIC_REPL_DEMAND(p_repl_level               IN NUMBER,
					p_org_id                   IN NUMBER,
					P_Batch_id                 IN NUMBER,
                                        p_Release_Sequence_Rule_Id IN NUMBER,
                                        x_consol_item_repl_tbl     OUT NOCOPY CONSOL_ITEM_REPL_TBL,
                                        x_return_status            OUT NOCOPY VARCHAR2,
                                        x_msg_count                OUT NOCOPY NUMBER,
                                        x_msg_data                 OUT NOCOPY VARCHAR2);

 PROCEDURE POPULATE_PUSH_REPL_DEMAND(p_repl_level                IN NUMBER,
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
                                     p_Release_Sequence_Rule_Id  IN NUMBER,
                                     p_Min_Order_lines_threshold IN NUMBER,
                                     p_Min_repl_qty_threshold    IN NUMBER,
                                     p_max_NUM_items_for_repl    IN NUMBER,
                                     p_Sort_Criteria             IN NUMBER,
                                     x_consol_item_repl_tbl      OUT NOCOPY CONSOL_ITEM_REPL_TBL,
                                     x_return_status             OUT NOCOPY VARCHAR2,
                                     x_msg_count                 OUT NOCOPY NUMBER,
                                     x_msg_data                  OUT NOCOPY VARCHAR2);

  --ajith changed the procedure name from POPULATE_REPL_DEMAND_NEXT_LEVEL to POPULATE_REPL_DEMAND_NEXT_LEV because only 30 chars allowed.
 /*
 PROCEDURE POPULATE_REPL_DEMAND_NEXT_LEV(P_replenishment_level  IN NUMBER,
                                           x_consol_item_repl_tbl OUT NOCOPY CONSOL_ITEM_REPL_TBL,
                                           x_return_status        OUT NOCOPY VARCHAR2,
                                           x_msg_count            OUT NOCOPY NUMBER,
                                           x_msg_data             OUT NOCOPY VARCHAR2);
 */

   FUNCTION GET_SORT_TRIP_STOP_DATE(P_delivery_detail_id  IN NUMBER,
				    P_TRIP_STOP_DATE_SORT IN VARCHAR2)
   RETURN NUMBER;


 FUNCTION GET_SORT_INVOICE_VALUE(P_SOURCE_HEADER_ID IN NUMBER, P_INVOICE_VALUE_SORT VARCHAR2)
   RETURN NUMBER;


 FUNCTION  Get_Expected_Time(p_demand_type_id in number,
			     p_source_header_id in number,
                             p_source_line_id          in number,
                             p_delivery_line_id in number) RETURN DATE;


 PROCEDURE UPDATE_DELIVERY_DETAIL (
				   p_delivery_detail_id       IN NUMBER,
				   P_PRIMARY_QUANTITY         IN NUMBER,
				   P_SPLIT_DELIVERY_DETAIL_ID IN NUMBER  DEFAULT NULL,
				   p_split_source_line_id          IN NUMBER DEFAULT NULL,
				   x_return_status            OUT    NOCOPY VARCHAR2
				   );


 PROCEDURE ADJUST_ATR_FOR_ITEM  (p_repl_level  IN NUMBER
				 , p_repl_type IN NUMBER
				 , x_consol_item_repl_tbl IN OUT NOCOPY CONSOL_ITEM_REPL_TBL
				 , x_return_status            OUT    NOCOPY VARCHAR2
				 );

--Updates the replenishment_status of single passed delivery_detail_id
-- If p_repl_status = 'R' marks it RR
-- If p_repl_status = 'C' marks it RC
-- If p_repl_status = NULL - Reverts WDD to original status (Ready to release / backorder)
--
PROCEDURE update_wdd_repl_status (p_deliv_detail_id   IN NUMBER
				  , p_repl_status     IN VARCHAR2
				  , p_deliv_qty       IN NUMBER DEFAULT NULL
				  , x_return_status            OUT    NOCOPY VARCHAR2
				  );


PROCEDURE Init_Rules(p_pick_seq_rule_id     IN NUMBER
		     , x_order_id_sort       OUT NOCOPY VARCHAR2
		     , x_INVOICE_VALUE_SORT  OUT NOCOPY VARCHAR2
		     , x_SCHEDULE_DATE_SORT  OUT NOCOPY VARCHAR2
		     , x_trip_stop_date_sort OUT NOCOPY VARCHAR2
		     , x_SHIPMENT_PRI_SORT   OUT NOCOPY VARCHAR2
		     , x_ordered_psr         OUT nocopy  psrTabTyp
		     , x_api_status          OUT NOCOPY VARCHAR2);

END WMS_REPLENISHMENT_PVT;

/
