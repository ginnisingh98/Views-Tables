--------------------------------------------------------
--  DDL for Package OE_DELAYED_REQUESTS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DELAYED_REQUESTS_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUREQS.pls 120.1.12010000.5 2012/09/14 08:12:58 rahujain ship $ */

-- bug 5738023
TYPE t_list_line_rec is Record
   ( line_id NUMBER);
TYPE Line_ID_List IS TABLE OF t_list_line_rec INDEX BY BINARY_INTEGER;

-- for bug 2372098
Type t_line_rec IS RECORD
  ( header_id NUMBER
    , line_id   NUMBER
    , shipment_number NUMBER
    , line_number NUMBER
    , option_number NUMBER
    , component_number NUMBER
    , service_txn_reason_code VARCHAR2(30)
    , service_txn_comments VARCHAR2(2000)
    , service_duration NUMBER
    , service_period VARCHAR2(3)
    , service_start_date DATE
    , service_end_date DATE
    , service_coterminate_flag VARCHAR2(1)
    , ordered_quantity NUMBER
    );
l_child   t_line_rec;


-- l_child would be used to fetch records from the cursor srv_children
-- in the procedure INSERT_SERVICE_FOR_OPTIONS
-- end bug 2372098

Procedure Validate_LSC_QUOTA_TOTAL
( x_return_status OUT NOCOPY VARCHAR2

, p_line_id       IN  NUMBER);

Procedure Validate_HSC_QUOTA_TOTAL
( x_return_status OUT NOCOPY VARCHAR2

, p_header_id     IN  NUMBER);

Procedure Cascade_Service_Scredit
( x_return_status OUT NOCOPY Varchar2

 ,p_request_rec       IN  OE_ORDER_PUB.request_rec_type);


Procedure DFLT_Hscredit_Primary_Srep
( p_header_id     IN  NUMBER
, p_SalesRep_id   IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE update_link_to_line_id
( x_return_status OUT NOCOPY VARCHAR2

 ,p_top_model_line_id  IN  NUMBER
);
PROCEDURE check_duplicate
(P_request_rec 	IN  OE_ORDER_PUB.request_rec_type
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE check_fixed_price
(P_request_rec 	IN  OE_ORDER_PUB.request_rec_type
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE check_percentage
(P_request_rec 	IN  OE_ORDER_PUB.request_rec_type
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE create_config_item
( x_return_status OUT NOCOPY VARCHAR2

, p_top_model_line_id  IN  NUMBER
, p_header_id          IN  NUMBER
);

PROCEDURE ins_included_items
( x_return_status OUT NOCOPY VARCHAR2

, p_line_id            IN  NUMBER
);

PROCEDURE verify_payment
( x_return_status OUT NOCOPY VARCHAR2

, p_header_id          IN  NUMBER
               );

Procedure INSERT_RMA_SCREDIT_ADJUSTMENT
(p_line_id       IN  NUMBER
,x_return_status OUT NOCOPY VARCHAR2

);

Procedure INSERT_RMA_OPTIONS_INCLUDED
(p_line_id       IN  NUMBER
,x_return_status OUT NOCOPY VARCHAR2

);

Procedure INSERT_RMA_LOT_SERIAL
(p_line_id       IN  NUMBER
,x_return_status OUT NOCOPY VARCHAR2

);

/* - Commenting out this procedure as it is not needed in R12
PROCEDURE Tax_Line
(x_return_status OUT NOCOPY VARCHAR2
,p_line_id	   IN   NUMBER
);
*/


PROCEDURE split_hold
(p_entity_code         IN   VARCHAR2
,p_entity_id           IN   NUMBER
,p_split_from_line_id  IN   NUMBER
,x_return_status OUT NOCOPY VARCHAR2

                     );

PROCEDURE Eval_Hold_Source
( x_return_status OUT NOCOPY VARCHAR2

, p_entity_code	 IN   VARCHAR2
, p_entity_id		 IN   NUMBER
, p_hold_entity_code IN   VARCHAR2
--ER#7479609 , p_hold_entity_id	 IN   NUMBER
, p_hold_entity_id	 IN   oe_hold_sources_all.hold_entity_id%TYPE  --ER#7479609
);

PROCEDURE Apply_Hold
( p_validation_level   IN   NUMBER
, x_request_rec        IN OUT NOCOPY OE_Order_PUB.Request_Rec_Type
);

PROCEDURE Release_Hold
(p_validation_level IN   NUMBER
,x_request_rec      IN OUT NOCOPY OE_Order_PUB.Request_Rec_Type
);

PROCEDURE Insert_Set
(P_request_rec 	IN  OE_ORDER_PUB.request_rec_type
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Split_Set
(P_request_rec 	IN  OE_ORDER_PUB.request_rec_type
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Book_Order
( p_validation_level     IN  NUMBER
, p_header_id            IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Get_Ship_Method
(p_entity_code           IN  VARCHAR2
, p_entity_id            IN  NUMBER
, p_action_code          IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Fulfillment_sets
( p_entity_code                IN VARCHAR2
, p_entity_id                  IN VARCHAR2
, p_action_code                IN VARCHAR2
, p_fulfillment_set_name       IN VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
);


PROCEDURE Ship_Confirmation
(p_ship_confirmation_tbl		IN  OE_ORDER_PUB.request_tbl_type
,p_line_id				IN  NUMBER
,p_process_type			IN  VARCHAR2
,p_process_id				IN  VARCHAR2
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Update_Shipping
(p_update_shipping_tbl 		IN  OE_ORDER_PUB.request_tbl_type
,p_line_id				IN  NUMBER
,p_operation			 	IN  VARCHAR2
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE SPLIT_RESERVATIONS
( p_reserved_line_id   IN  NUMBER
, p_ordered_quantity   IN  NUMBER
, p_reserved_quantity  IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2

);

Procedure COMPLETE_CONFIGURATION
( p_top_model_line_id  IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2);


Procedure VALIDATE_CONFIGURATION
( p_top_model_line_id   IN  NUMBER
, p_deleted_options_tbl IN  OE_Order_PUB.request_tbl_type
, p_updated_options_tbl IN  OE_Order_PUB.request_tbl_type
, x_return_status OUT NOCOPY VARCHAR2

);


Procedure MATCH_AND_RESERVE
( p_line_id         IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2);


Procedure Group_Schedule
(p_request_rec     IN   OE_ORDER_PUB.request_rec_type
,x_return_status OUT NOCOPY VARCHAR2);


Procedure DELINK_CONFIG
( p_line_id         IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2);


Procedure Validate_Line_Set
( p_line_set_id     IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE PROCESS_ADJUSTMENTS
( p_adjust_tbl 	IN  OE_ORDER_PUB.request_tbl_type
, x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE INSERT_SERVICE_FOR_OPTIONS
( p_serviced_line_id   IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2);


/* lchen added for bug 1761154*/
PROCEDURE CASCADE_SERVICE_FOR_OPTIONS
( p_option_line_id   IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Apply_Automatic_Attachments
( p_entity_code		IN  VARCHAR2
, p_entity_id			IN  NUMBER
, p_is_user_action		IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Copy_Attachments
( p_entity_code			IN VARCHAR2
, p_from_entity_id			IN NUMBER
, p_to_entity_id			IN NUMBER
, p_manual_attachments_only	IN VARCHAR2 DEFAULT 'N'
, x_return_status OUT NOCOPY VARCHAR2

);

Procedure Schedule_Line
( p_sch_set_tbl     IN  OE_ORDER_PUB.request_tbl_type
, x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Process_Tax
( p_entity_id_tbl   IN  OE_Delayed_Requests_PVT.Entity_Id_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2);

--Included for the Spares Management (Ikon) project mshenoy
PROCEDURE auto_create_internal_req
(p_ord_header_id  IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2);



-- BUG 2013611 BEGIN
Procedure Reverse_Limits
(p_action_code             IN  VARCHAR2
,p_cons_price_request_code IN  VARCHAR2
,p_orig_ordered_qty        IN  NUMBER   DEFAULT NULL
,p_amended_qty             IN  NUMBER   DEFAULT NULL
,p_ret_price_request_code  IN  VARCHAR2 DEFAULT NULL
,p_returned_qty            IN  NUMBER   DEFAULT NULL
,p_line_id                 IN  NUMBER   DEFAULT NULL
,x_return_status OUT NOCOPY VARCHAR2);

-- BUG 2013611 END


Procedure Process_XML_Delayed_Request (p_request_ind      IN NUMBER,
                                       x_return_status    OUT NOCOPY VARCHAR2);


/* 7576948: IR ISO Change Management project Start */
-- This program unit is added for IR ISO Change management
-- project, so as to trigger the new program unit
-- OE_Process_Requisition_Pvt.Update_Internal_Requisition
-- introduced as part of this project, and responsible for
-- calling several Purchasing APIs based on the action
-- performed on the internal sales order header/line.
-- Possible actions can be:
--   Header Level FULL Cancellation
--   Header Level PARTIAL Cancellation (This is currently
--               *NOT* supported on internal requisition)
--   Line Level Cancellation
--   Line Ordered Quantity update
--   Line Schedule Ship/Arrival Date update
--   Line Ordered Quantity and Schedule Ship/Arrival Date update

-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc

Procedure Update_Requisition_Info -- Package Specification
( p_header_id              IN NUMBER
, p_line_id                IN NUMBER
, P_Line_ids               IN VARCHAR2
, P_num_records            IN NUMBER
, P_Requisition_Header_id  IN NUMBER
, P_Requisition_Line_id    IN NUMBER DEFAULT NULL
, P_Quantity_Change        IN NUMBER DEFAULT NULL
, P_Quantity2_Change       IN NUMBER DEFAULT NULL --Bug 14211120
, P_New_Schedule_Ship_Date IN DATE DEFAULT NULL
, P_Cancel_order           IN BOOLEAN
, x_return_status          OUT NOCOPY VARCHAR2
);

/* ============================= */
/* IR ISO Change Management Ends */

/* Start DOO Pre Exploded Kit ER 9339742 */
Procedure Process_Pre_Exploded_Kits
( p_top_model_line_id IN  NUMBER
, p_explosion_date    IN  DATE
, x_return_status     OUT NOCOPY varchar2);
/* End DOO Pre Exploded Kit ER 9339742 */



END;

/
