--------------------------------------------------------
--  DDL for Package WSH_DELIVERIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERIES_GRP" AUTHID CURRENT_USER as
/* $Header: WSHDEGPS.pls 120.2.12010000.1 2008/07/29 05:59:59 appldev ship $ */

--===================
-- PUBLIC VARS
--===================

-- Bug 6369687: Adding variable to get the action on the delivery
G_ACTION VARCHAR2(30) := NULL;

TYPE Delivery_Pub_Rec_Type IS RECORD (
  DELIVERY_ID                     NUMBER  DEFAULT FND_API.G_MISS_NUM,
  NAME                            VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  DELIVERY_TYPE                   VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  LOADING_SEQUENCE                NUMBER  DEFAULT FND_API.G_MISS_NUM,
  LOADING_ORDER_FLAG              VARCHAR2(2) DEFAULT FND_API.G_MISS_CHAR,
  LOADING_ORDER_DESC              VARCHAR2(20)  DEFAULT FND_API.G_MISS_CHAR,
  INITIAL_PICKUP_DATE             DATE  DEFAULT FND_API.G_MISS_DATE,
  INITIAL_PICKUP_LOCATION_ID      NUMBER  DEFAULT FND_API.G_MISS_NUM,
  INITIAL_PICKUP_LOCATION_CODE    VARCHAR2(20)  DEFAULT FND_API.G_MISS_CHAR,
  ORGANIZATION_ID                 NUMBER  DEFAULT FND_API.G_MISS_NUM,
  ORGANIZATION_CODE               VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  ULTIMATE_DROPOFF_LOCATION_ID    NUMBER  DEFAULT FND_API.G_MISS_NUM,
  ULTIMATE_DROPOFF_LOCATION_CODE  VARCHAR2(20)  DEFAULT FND_API.G_MISS_CHAR,
  ULTIMATE_DROPOFF_DATE           DATE  DEFAULT FND_API.G_MISS_DATE,
  CUSTOMER_ID                     NUMBER  DEFAULT FND_API.G_MISS_NUM,
  CUSTOMER_NUMBER                 VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  INTMED_SHIP_TO_LOCATION_ID      NUMBER  DEFAULT FND_API.G_MISS_NUM,
  INTMED_SHIP_TO_LOCATION_CODE    VARCHAR2(20)  DEFAULT FND_API.G_MISS_CHAR,
  POOLED_SHIP_TO_LOCATION_ID      NUMBER  DEFAULT FND_API.G_MISS_NUM,
  POOLED_SHIP_TO_LOCATION_CODE    VARCHAR2(20)  DEFAULT FND_API.G_MISS_CHAR,
  CARRIER_ID                      NUMBER  DEFAULT FND_API.G_MISS_NUM,
  CARRIER_CODE                    VARCHAR2(25)  DEFAULT FND_API.G_MISS_CHAR,
  SHIP_METHOD_CODE                VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  SHIP_METHOD_NAME                VARCHAR2(80)  DEFAULT FND_API.G_MISS_CHAR,
  FREIGHT_TERMS_CODE              VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  FREIGHT_TERMS_NAME              VARCHAR2(80)  DEFAULT FND_API.G_MISS_CHAR,
  FOB_CODE                        VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  FOB_NAME                        VARCHAR2(80)  DEFAULT FND_API.G_MISS_CHAR,
  FOB_LOCATION_ID                 NUMBER  DEFAULT FND_API.G_MISS_NUM,
  FOB_LOCATION_CODE               VARCHAR2(20)  DEFAULT FND_API.G_MISS_CHAR,
  WAYBILL                         VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  DOCK_CODE                       VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  ACCEPTANCE_FLAG                 VARCHAR2(1) DEFAULT FND_API.G_MISS_CHAR,
  ACCEPTED_BY                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ACCEPTED_DATE                   DATE  DEFAULT FND_API.G_MISS_DATE,
  ACKNOWLEDGED_BY                 VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  CONFIRMED_BY                    VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  CONFIRM_DATE                    DATE  DEFAULT FND_API.G_MISS_DATE,
  ASN_DATE_SENT                   DATE  DEFAULT FND_API.G_MISS_DATE,
  ASN_STATUS_CODE                 VARCHAR2(15)  DEFAULT FND_API.G_MISS_CHAR,
  ASN_SEQ_NUMBER                  NUMBER  DEFAULT FND_API.G_MISS_NUM,
  GROSS_WEIGHT                    NUMBER  DEFAULT FND_API.G_MISS_NUM,
  NET_WEIGHT                      NUMBER  DEFAULT FND_API.G_MISS_NUM,
  WEIGHT_UOM_CODE                 VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  WEIGHT_UOM_DESC                 VARCHAR2(25)  DEFAULT FND_API.G_MISS_CHAR,
  VOLUME                          NUMBER  DEFAULT FND_API.G_MISS_NUM,
  VOLUME_UOM_CODE                 VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  VOLUME_UOM_DESC                 VARCHAR2(25)  DEFAULT FND_API.G_MISS_CHAR,
  ADDITIONAL_SHIPMENT_INFO        VARCHAR2(500) DEFAULT FND_API.G_MISS_CHAR,
  CURRENCY_CODE                   VARCHAR2(15)  DEFAULT FND_API.G_MISS_CHAR,
  CURRENCY_NAME                   VARCHAR2(80)  DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE_CATEGORY              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE1                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE2                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE3                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE4                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE5                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE6                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE7                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE8                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE9                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE10                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE11                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE12                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE13                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE14                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  ATTRIBUTE15                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE_CATEGORY           VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE1                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE2                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE3                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE4                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE5                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE6                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE7                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE8                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE9                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE10                  VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE11                  VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE12                  VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE13                  VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE14                  VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  TP_ATTRIBUTE15                  VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE_CATEGORY       VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE1               VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE2               VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE3               VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE4               VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE5               VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE6               VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE7               VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE8               VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE9               VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE10              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE11              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE12              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE13              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE14              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE15              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE16              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE17              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE18              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE19              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  GLOBAL_ATTRIBUTE20              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  CREATION_DATE                   DATE  DEFAULT FND_API.G_MISS_DATE,
  CREATED_BY                      NUMBER  DEFAULT FND_API.G_MISS_NUM,
  LAST_UPDATE_DATE                DATE  DEFAULT FND_API.G_MISS_DATE,
  LAST_UPDATED_BY                 NUMBER  DEFAULT FND_API.G_MISS_NUM,
  LAST_UPDATE_LOGIN               NUMBER  DEFAULT FND_API.G_MISS_NUM,
  PROGRAM_APPLICATION_ID          NUMBER  DEFAULT FND_API.G_MISS_NUM,
  PROGRAM_ID                      NUMBER  DEFAULT FND_API.G_MISS_NUM,
  PROGRAM_UPDATE_DATE             DATE  DEFAULT FND_API.G_MISS_DATE,
  REQUEST_ID                      NUMBER  DEFAULT FND_API.G_MISS_NUM,
/* Changes done for the shipping data model Bugfix#1918342*/
        COD_AMOUNT                      NUMBER  DEFAULT FND_API.G_MISS_NUM,
        COD_CURRENCY_CODE               VARCHAR2(15) DEFAULT FND_API.G_MISS_CHAR,
        COD_REMIT_TO                    VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
        COD_CHARGE_PAID_BY              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
        PROBLEM_CONTACT_REFERENCE       VARCHAR2(500) DEFAULT FND_API.G_MISS_CHAR,
        PORT_OF_LOADING                 VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
        PORT_OF_DISCHARGE               VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
        FTZ_NUMBER                      VARCHAR2(35)  DEFAULT FND_API.G_MISS_CHAR,
        ROUTED_EXPORT_TXN               VARCHAR2(1) DEFAULT FND_API.G_MISS_CHAR,
        ENTRY_NUMBER                    VARCHAR2(35) DEFAULT FND_API.G_MISS_CHAR,
        ROUTING_INSTRUCTIONS            VARCHAR2(120) DEFAULT FND_API.G_MISS_CHAR,
        IN_BOND_CODE                    VARCHAR2(35) DEFAULT FND_API.G_MISS_CHAR,
        SHIPPING_MARKS                  VARCHAR2(100) DEFAULT FND_API.G_MISS_CHAR,
        SERVICE_LEVEL                   VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
        MODE_OF_TRANSPORT               VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
        ASSIGNED_TO_FTE_TRIPS           VARCHAR2(1)   DEFAULT FND_API.G_MISS_CHAR,
/*BUG 3667348*/
	REASON_OF_TRANSPORT		VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
	DESCRIPTION			VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
--Non Database field added for "Proration of weight from Delivery to delivery lines" Project(Bug#4254552).
	PRORATE_WT_FLAG			VARCHAR2(1)   DEFAULT FND_API.G_MISS_CHAR
  );

-- I Harmonization: rvishnuv ******* Actions ******

TYPE default_parameters_rectype is RECORD(
  autointransit_flag  VARCHAR2(1) ,
  autoclose_flag    VARCHAR2(1) ,
  report_set_id   NUMBER ,
  report_set_name   VARCHAR2(30) ,
  ship_method_name  VARCHAR2(240) ,
  enforce_ship_method     VARCHAR2(1),
  defer_interface_flag  VARCHAR2(1),
  trip_id_tab     wsh_util_core.id_tab_type,
  ac_bol_flag     VARCHAR2(1),
  sc_rule_id      NUMBER,
  sc_rule_name   VARCHAR2(30)
  );

TYPE action_parameters_rectype is RECORD (
  caller      VARCHAR2(50),
  phase     NUMBER,
  action_code   VARCHAR2(30),
  trip_id           NUMBER ,         --|
  trip_name   VARCHAR2(30) ,   --|
  pickup_stop_id    NUMBER ,         --|
  pickup_loc_id   NUMBER ,         --|
  pickup_stop_seq   NUMBER ,         --|
  pickup_loc_code   VARCHAR2(80) ,  --|
  pickup_arr_date   DATE   ,         --|   All these parameters
  pickup_dep_date   DATE   ,         --|   are used for the
        pickup_stop_status      VARCHAR2(2),     --|
  dropoff_stop_id   NUMBER ,         --|   Action
  dropoff_loc_id    NUMBER ,         --|   'UNASSIGN-TRIP'
  dropoff_stop_seq  NUMBER ,         --|
  dropoff_loc_code  VARCHAR2(80) ,  --|
  dropoff_arr_date  DATE   ,         --|
  dropoff_dep_date  DATE ,           --|
        dropoff_stop_status     VARCHAR2(2),     --|
  action_flag   VARCHAR2(1),
  intransit_flag    VARCHAR2(1),
  close_trip_flag   VARCHAR2(1) ,
  stage_del_flag    VARCHAR2(1),
  bill_of_lading_flag VARCHAR2(1),
  mc_bill_of_lading_flag  VARCHAR2(1),
  override_flag   VARCHAR2(1),
  defer_interface_flag  VARCHAR2(1),
  ship_method_code  VARCHAR2(240) ,
  actual_dep_date   DATE     ,
  report_set_id   NUMBER ,
  report_set_name   VARCHAR2(30) ,
  send_945_flag   VARCHAR2(1) ,
  sc_rule_id   NUMBER ,
  sc_rule_name   VARCHAR2(30) ,
  action_type   VARCHAR2(1) ,
  document_type   VARCHAR2(2) ,
  organization_id   NUMBER ,
  reason_of_transport VARCHAR2(30),
  description   VARCHAR2(30),
  maxDelivs	NUMBER, /* Pack J : max number of deliveries that can be grouped into a trip */
  ignore_ineligible_dels VARCHAR2(1),
  event         VARCHAR2(1) ,
  form_flag   VARCHAR2(1) /* Pack J : select carrier when appending limit has been reached */ );

TYPE Delivery_Action_Out_Rec_Type is RECORD (
  packing_slip_number VARCHAR2(50),
  valid_ids_tab           wsh_util_core.id_tab_type,
  result_id_tab           wsh_util_core.id_tab_type,
  selection_issue_flag    VARCHAR2(1),
  num_success_delivs	  NUMBER /* Pack J : number of deliveries that were successfully grouped into trips */
  );
-- I Harmonization: rvishnuv ******* Actions ******

-- I Harmonization: rvishnuv ******* Create/Update ******

TYPE Del_In_Rec_Type is RECORD (
  caller      VARCHAR2(50),
  phase       NUMBER,
  action_code     VARCHAR2(30));

TYPE Del_Out_Rec_Type is RECORD (
  delivery_id   NUMBER,
  name      VARCHAR2(30),
        rowid                   VARCHAR2(4000));

TYPE Del_Out_Tbl_Type IS Table of Del_Out_Rec_Type INDEX BY BINARY_INTEGER;

-- I Harmonization: rvishnuv ******* Create/Update ******



--===================
-- PROCEDURES
--===================

-- I Harmonization: rvishnuv ******* Actions ******
--========================================================================
-- PROCEDURE : Delivery_Action         Must be called only by the Form
--                                     and the Wrapper Group API.
--
-- PARAMETERS: p_api_version           known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--         p_rec_attr_tab          Table of attributes for the delivery entity
--             x_request_id_tab        Table of Request Ids returned by the
--                                     action 'PICK-RELEASE'
--             x_result_id_tab         Table of result ids.
--             x_valid_ids_tab         Table of valid indexes or ids.  If the caller is STF,
--                                     it contains table of valid indexes, else it contains
--                                     table of valid ids.
--             x_selection_issue_flag  It is a form specific out parameter. It set to 'Y', if
--                                     the Validations in phase 1 return a 'warning'.
--             x_defaults_rec          Record of Default Parameters that passed for the actions
--                                     'CONFIRM', 'UNASSIGN-TRIP'.
--             x_delivery_out_rec      Record of output parameters based on the actions.
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified
--             in p_action_prms.action_code on an existing delivery identified
--             by p_rec_attr.delivery_id.
--========================================================================
  PROCEDURE Delivery_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit         IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_action_prms      IN   action_parameters_rectype,
    p_rec_attr_tab       IN   WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type ,
    x_delivery_out_rec       OUT  NOCOPY Delivery_Action_Out_Rec_Type,
    x_defaults_rec       OUT  NOCOPY default_parameters_rectype,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2
  );

-- I Harmonization: rvishnuv ******* Actions ******

-- I Harmonization: rvishnuv ******* Create/Update ******
--========================================================================
-- PROCEDURE : Create_Update_Delivery  Must be called only by the Form
--                                     and the Wrapper Group API.
--
-- PARAMETERS: p_api_version           known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_in_rec                Record for caller, phase
--                                     and action_code ( CREATE-UPDATE )
--         p_rec_attr_tab          Table of attributes for the delivery entity
--           x_del_out_rec_tab       Table of delivery_id, and name of new deliveries,
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_new_deliveries table with information
--             specified in p_delivery_info
--========================================================================
  PROCEDURE Create_Update_Delivery
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit         IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_in_rec                 IN   del_In_Rec_Type,
    p_rec_attr_tab       IN   WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
    x_del_out_rec_tab        OUT NOCOPY Del_Out_Tbl_Type,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2);
--========================================================================

-- I Harmonization: rvishnuv ******* Create/Update ******

-- The below procedue will be obsoleted after patchset I.

--========================================================================
-- PROCEDURE : Create_Update_Delivery         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--         p_delivery_info         Attributes for the delivery entity
--             p_delivery_name         Delivery name for update
--           x_delivery_id - delivery_Id of new delivery,
--             x_name - Name of delivery
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_new_deliveries table with information
--             specified in p_delivery_info
--========================================================================
  PROCEDURE Create_Update_Delivery
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_delivery_info      IN OUT NOCOPY   Delivery_Pub_Rec_Type,
    p_delivery_name          IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    x_delivery_id            OUT NOCOPY   NUMBER,
    x_name                   OUT NOCOPY   VARCHAR2);


--========================================================================

-- The below procedue will be obsoleted after patchset I.
--========================================================================
-- PROCEDURE : Delivery_Action         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_code           Delivery action code. Valid action codes are
--                                     'PLAN','UNPLAN',
--                                     'PACK','CONFIRM','RE-OPEN','IN-TRANSIT','CLOSE'
--                                     'ASSIGN-TRIP','UNASSIGN-TRIP','AUTOCREATE-TRIP'
--                                     'WT-VOL',
--                                     'PICK-RELEASE',
--                                     'DELETE'
--         p_delivery_id           Delivery identifier
--             p_delivery_name         Delivery name
--             p_asg_trip_id           Trip identifier for assignment
--             p_asg_trip_name         Trip name for assignment
--             p_asg_pickup_stop_id    Stop id for pickup assignment
--             p_asg_pickup_loc_id     Stop location for pickup assignment
--             p_asg_pickup_loc_code   Stop location code for pickup assignment
--             p_asg_pickup_arr_date   Stop location arrival date for pickup assignment
--             p_asg_pickup_dep_date   Stop location departure date for pickup assignment
--             p_asg_dropoff_stop_id   Stop id for dropoff assignment
--             p_asg_dropoff_loc_id    Stop location for dropoff assignment
--             p_asg_dropoff_loc_code  Stop location code for dropoff assignment
--             p_asg_dropoff_arr_date  Stop location arrival date for dropoff assignment
--             p_asg_dropoff_dep_date  Stop location departure date for dropoff assignment
--             p_sc_action_flag        Ship Confirm option - 'S', 'B', 'T', 'A', 'C'
--             p_sc_intransit_flag     Ship Confirm set in-transit flag
--             p_sc_close_trip_flag    Ship Confirm close trip flag
--             p_sc_create_bol_flag    Ship Confirm create BOL flag
--             p_sc_stage_del_flag     Ship Confirm create delivery for stage qnt flag
--             p_sc_trip_ship_method   Ship Confirm trip ship method
--             p_sc_actual_dep_date    Ship Confirm actual departure date
--             p_sc_report_set_id      Ship Confirm report set id
--             p_sc_report_set_name    Ship Confirm report set name
--             p_wv_override_flag      Override flag for weight/volume calc
--             x_trip_id               Autocreated trip id
--             x_trip_name             Autocreated trip name
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified in p_action_code
--             on an existing delivery identified by p_delivery_id/p_delivery_name.
--========================================================================

  PROCEDURE Delivery_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_delivery_id            IN   NUMBER DEFAULT NULL,
    p_delivery_name          IN   VARCHAR2 DEFAULT NULL,
    p_asg_trip_id            IN   NUMBER DEFAULT NULL,
    p_asg_trip_name          IN   VARCHAR2 DEFAULT NULL,
    p_asg_pickup_stop_id     IN   NUMBER DEFAULT NULL,
    p_asg_pickup_loc_id      IN   NUMBER DEFAULT NULL,
    p_asg_pickup_stop_seq    IN   NUMBER DEFAULT NULL,/*h integration anxsharm*/
    p_asg_pickup_loc_code    IN   VARCHAR2 DEFAULT NULL,
    p_asg_pickup_arr_date    IN   DATE   DEFAULT NULL,
    p_asg_pickup_dep_date    IN   DATE   DEFAULT NULL,
    p_asg_dropoff_stop_id    IN   NUMBER DEFAULT NULL,
    p_asg_dropoff_loc_id     IN   NUMBER DEFAULT NULL,
    p_asg_dropoff_stop_seq   IN   NUMBER DEFAULT NULL,/*h integration anxsharm*/
    p_asg_dropoff_loc_code   IN   VARCHAR2 DEFAULT NULL,
    p_asg_dropoff_arr_date   IN   DATE   DEFAULT NULL,
    p_asg_dropoff_dep_date   IN   DATE   DEFAULT NULL,
    p_sc_action_flag         IN   VARCHAR2 DEFAULT 'S',
    p_sc_intransit_flag      IN   VARCHAR2 DEFAULT 'N',
    p_sc_close_trip_flag     IN   VARCHAR2 DEFAULT 'N',
    p_sc_create_bol_flag     IN   VARCHAR2 DEFAULT 'N',
    p_sc_stage_del_flag      IN   VARCHAR2 DEFAULT 'Y',
    p_sc_trip_ship_method    IN   VARCHAR2 DEFAULT NULL,
    p_sc_actual_dep_date     IN   DATE     DEFAULT NULL,
    p_sc_report_set_id       IN   NUMBER DEFAULT NULL,
    p_sc_report_set_name     IN   VARCHAR2 DEFAULT NULL,
    p_sc_defer_interface_flag     IN   VARCHAR2 DEFAULT 'Y',
    p_sc_send_945_flag       IN   VARCHAR2 DEFAULT NULL,
    p_wv_override_flag       IN   VARCHAR2 DEFAULT 'N',
    x_trip_rows              OUT  NOCOPY WSH_UTIL_CORE.id_tab_type );

    --========================================================================
-- PROCEDURE : Get_Delivery_Status    PUBLIC
--
-- PARAMETERS:
--     p_api_version_number  known api version error number
--     p_init_msg_list       FND_API.G_TRUE to reset list
--     p_entity_type         either DELIVERY/DELIVERY DETAIL/LPN
--     p_entity_id           either delivery_id/delivery_detail_id/lpn_id
--     x_status_code         Status of delivery for the entity_type and
--                           entity id passed
--     x_return_status       return status
--     x_msg_count           number of messages in the list
--     x_msg_data            text of messages
--========================================================================
-- API added for bug 4632726
  PROCEDURE Get_Delivery_Status
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_entity_type            IN   VARCHAR2,
    p_entity_id              IN   NUMBER,
    x_status_code            OUT NOCOPY   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2 );


END WSH_DELIVERIES_GRP;

/
