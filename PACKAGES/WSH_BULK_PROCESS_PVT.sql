--------------------------------------------------------
--  DDL for Package WSH_BULK_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_BULK_PROCESS_PVT" AUTHID CURRENT_USER as
/* $Header: WSHBLPRS.pls 120.1.12000000.1 2007/01/16 05:42:09 appldev ship $ */


TYPE additional_line_info_rec_type  IS RECORD (
   Released_status WSH_BULK_TYPES_GRP.char1_nested_tab_TYPE :=
                                  WSH_BULK_TYPES_GRP.char1_nested_tab_TYPE(),
   Source_code   varchar2(30),
   inv_interfaced_flag WSH_BULK_TYPES_GRP.char1_Nested_Tab_Type :=
                                    WSH_BULK_TYPES_GRP.char1_Nested_Tab_Type(),
   attribute_category     WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute1      WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute2      WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute3      WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute4      WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute5      WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute6      WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute7      WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute8      WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute9      WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute10      WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute11      WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute12     WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute13    WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute14      WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   attribute15     WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char150_Nested_Tab_Type(),
   ignore_for_planning  WSH_BULK_TYPES_GRP.char1_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char1_Nested_Tab_Type(),
   earliest_pickup_date  WSH_BULK_TYPES_GRP.date_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.date_Nested_Tab_Type(),
   latest_pickup_date  WSH_BULK_TYPES_GRP.date_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.date_Nested_Tab_Type(),
   earliest_dropoff_date  WSH_BULK_TYPES_GRP.date_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.date_Nested_Tab_Type(),
   latest_dropoff_date  WSH_BULK_TYPES_GRP.date_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.date_Nested_Tab_Type(),
   service_level  WSH_BULK_TYPES_GRP.char30_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char30_Nested_Tab_Type(),
   mode_of_transport  WSH_BULK_TYPES_GRP.char30_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.char30_Nested_Tab_Type(),
   cancelled_quantity2  WSH_BULK_TYPES_GRP.number_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
   cancelled_quantity  WSH_BULK_TYPES_GRP.number_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
   master_container_item_id  WSH_BULK_TYPES_GRP.number_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
   detail_container_item_id  WSH_BULK_TYPES_GRP.number_Nested_Tab_Type :=
                                  WSH_BULK_TYPES_GRP.number_Nested_Tab_Type(),
   latest_pickup_tpdate_excep WSH_BULK_TYPES_GRP.tbl_date,
   latest_dropoff_tpdate_excep WSH_BULK_TYPES_GRP.tbl_date
        );



--========================================================================
-- PROCEDURE : Create_delivery_details
--
-- PARAMETERS: p_action_prms           Additional attributes needed
--	       p_line_rec              Line record
--             x_return_status         return status
-- COMMENT   : This API is called from the wrapper API:
--             WSH_BULK_PROCESS_GRP.Create_update_delivery_details
--             It imports the order lines into Shipping tables
--========================================================================
-- Made the parameter p_action_prms IN OUT
  PROCEDURE Create_delivery_details(
                  p_action_prms      IN OUT NOCOPY
                                WSH_BULK_TYPES_GRP.action_parameters_rectype,
                  p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.Line_rec_type,
                  x_return_status          OUT  NOCOPY VARCHAR2
  );


--========================================================================
-- PROCEDURE : Extend_tables
--
-- PARAMETERS: p_line_rec              Line record
--             p_action_prms           Additional attributes needed
--             x_table_count           Size of each table
--             x_additional_line_info_rec Local record that is extended
--                                     and ready to use to store  additional
--                                     information for line record.
--             x_return_status         return status
-- COMMENT   : This procedure extends all the common table in p_line_rec
--             It also extends the local tables used during the import.
--========================================================================


  PROCEDURE Extend_tables (
           p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
           p_action_prms     IN WSH_BULK_TYPES_GRP.action_parameters_rectype ,
           x_table_count     OUT NOCOPY NUMBER ,
           x_additional_line_info_rec    OUT NOCOPY
                                           additional_line_info_rec_type ,
           x_return_status  OUT NOCOPY VARCHAR2
  );




--========================================================================
-- PROCEDURE : Validate_lines
--
-- PARAMETERS: p_line_rec              Line record
--             p_action_prms           Additional attributes needed
--             x_table_count           Size of each table
--             x_additional_line_info_rec Local record that is extended
--                                     and ready to use to store  additional
--                                     information for line record.
--             x_valid_rec_exist       set to 1, if any record was validated
--                                     successfully
--             x_eligible_rec_exist    set to 1, if any eligible record exists.
--             x_return_status         return status
-- COMMENT   : This procedure goes through the tables in p_line_rec and
--             validates them.  If the validation is successful, a 'Y' will
--             be set in the table p_line_rec.shipping_interfaced_flag
--========================================================================


  PROCEDURE Validate_lines(
           p_line_rec      IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
           P_action_prms   IN OUT NOCOPY
                           WSH_BULK_TYPES_GRP.action_parameters_rectype,
           p_additional_line_info_rec   IN  OUT NOCOPY
                                           additional_line_info_rec_type ,
	   x_valid_rec_exist  OUT NOCOPY NUMBER ,
           x_eligible_rec_exist OUT NOCOPY NUMBER ,
           X_return_status  OUT  NOCOPY VARCHAR2
  );


--========================================================================
-- PROCEDURE : bulk_insert_details
--
-- PARAMETERS: p_line_rec              Line record
--             p_action_prms           Additional attributes needed
--             p_additional_line_info_rec Local record that is extended
--                                     and ready to use to store  additional
--                                     information for line record.
--             x_return_status         return status
-- COMMENT   : This procedure will bulk insert the records into tables
--              wsh_delivery_details and wsh_delivery_assignments_v
--========================================================================


  PROCEDURE bulk_insert_details (
           P_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
	   p_index     IN NUMBER,
           p_action_prms     IN  WSH_BULK_TYPES_GRP.action_parameters_rectype,
           p_additional_line_info_rec   IN  additional_line_info_rec_type ,
           X_return_status  OUT  NOCOPY VARCHAR2
  );




--========================================================================
-- PROCEDURE : Set_message
-- PARAMETERS: p_line_rec              Line record
--             p_index                 index for the line record
--             p_caller                caller OM, PO, OKE
--             p_first_call            pass 'T' to this API for the first time
--                                     this API is called.
--             X_stack_size_start      this will return the fnd message
--                                     stack size, if a 'T' is passed to
--                                     the parameter p_first_call
--             x_return_status         return status
-- COMMENT   : This API should be called twice, once at the begin of
--             the validation and once at the end.  If the caller is OM
--             this API will calculate the number of the messages that have
--             been added to the fnd_message stack and put this number into
--             table p_line_rec.error_message_count.
--             If the caller is not OM, then if any errors should be logged
--             for a certain line, this API would put one message at the begin
--             saying which line, header number is being processed and once
--             all the messages for this line has been put on the stack,
--             another message indicates that the validation has finished for
--             the line, header number.
--
--========================================================================


  PROCEDURE Set_message(
           p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.Line_rec_type,
           p_index            IN NUMBER,
           p_caller           IN VARCHAR2,
           P_first_call       IN VARCHAR2,
           X_stack_size_start IN OUT NOCOPY NUMBER,
           X_return_status    OUT NOCOPY VARCHAR2
  );

-- Added for Inbound Logistics
--========================================================================
-- PROCEDURE : validate_mandatory_info
--
-- PARAMETERS:  p_line_rec      IN  OUT OE_WSH_BULK_GRP.line_rec_type,
--		p_index 	IN 	NUMBER
--		x_return_status         return status
--
-- COMMENT   : This API checks for the validity of mandatory fields like
--              1.ordered_quantity
--		2.order_quantity_uom
--		3.organization_id
--		4.po_shipment_line_id
--              5.header_id
--		6.line_id
--		7.source_header_number
--		8.source_line_number
--              9.po_shipment_line_number
--		10.source_header_type_id
--		11.source_blanket_reference_id
--		12.source_blanket_reference_num
--		13.source_line_type_code
--
--========================================================================
PROCEDURE  validate_mandatory_info(
     p_line_rec      IN  OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
     p_index 	     IN	 NUMBER,
    x_return_status OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : get_opm_quantity
--
-- PARAMETERS:  p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
--		p_index     IN  NUMBER,
--	        x_return_status OUT NOCOPY VARCHAR2
--
-- COMMENT   :
--========================================================================
/* HW OPMCONV. No need to use this routine
PROCEDURE get_opm_quantity(
                  p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
                  p_index    IN NUMBER,
 		  x_return_status OUT NOCOPY VARCHAR2);
*/--========================================================================
-- PROCEDURE : calc_service_mode
--
-- PARAMETERS: p_line_rec
--             p_cache_tbl             used to store the cache info
--             p_cache_ext_tbl         used to store the cache info
--             p_index                 current index for tables in
--                                     p_additional_line_info_rec
--             p_additional_line_info_rec
--             x_return_status         return status
-- COMMENT   : The service_level and mode_of_transport is calculated and
--             populated to the p_additional_line_info_rec.mode_of_transport
--             and p_additional_line_info_rec.service_level tables.
--             The index of these tables are cached, so that the for the same
--             ship_method_code these information is reused.
--========================================================================
  PROCEDURE calc_service_mode(
                        p_line_rec      IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
                       p_cache_tbl      IN OUT NOCOPY
                                              wsh_util_core.char500_tab_type,
                       p_cache_ext_tbl  IN OUT NOCOPY
                                               wsh_util_core.char500_tab_type,
                       p_index          IN NUMBER,
                       p_additional_line_info_rec IN OUT NOCOPY
                                                  additional_line_info_rec_type,                       x_return_status   OUT NOCOPY VARCHAR2);

END WSH_BULK_PROCESS_PVT;

 

/
