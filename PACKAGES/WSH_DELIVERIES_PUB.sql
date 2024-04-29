--------------------------------------------------------
--  DDL for Package WSH_DELIVERIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERIES_PUB" AUTHID CURRENT_USER as
/* $Header: WSHDEPBS.pls 120.0.12010000.2 2009/12/03 15:18:53 gbhargav ship $ */
/*#
 * This is the public interface for the Delivery entity. It allows
 * execution of various Delivery functions, including creation, update
 * of delivery and other actions.
 * @rep:scope public
 * @rep:product WSH
 * @rep:displayname Delivery
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY WSH_DELIVERY
 */

--===================
-- PUBLIC VARS
--===================

TYPE Delivery_Pub_Rec_Type IS RECORD (
	DELIVERY_ID                     NUMBER	DEFAULT FND_API.G_MISS_NUM,
	NAME                            VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	DELIVERY_TYPE                   VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	LOADING_SEQUENCE                NUMBER	DEFAULT FND_API.G_MISS_NUM,
	LOADING_ORDER_FLAG              VARCHAR2(2)	DEFAULT FND_API.G_MISS_CHAR,
	LOADING_ORDER_DESC              VARCHAR2(20)	DEFAULT FND_API.G_MISS_CHAR,
	INITIAL_PICKUP_DATE             DATE	DEFAULT FND_API.G_MISS_DATE,
	INITIAL_PICKUP_LOCATION_ID      NUMBER	DEFAULT FND_API.G_MISS_NUM,
	INITIAL_PICKUP_LOCATION_CODE    VARCHAR2(20)	DEFAULT FND_API.G_MISS_CHAR,
	ORGANIZATION_ID                 NUMBER	DEFAULT FND_API.G_MISS_NUM,
	ORGANIZATION_CODE               VARCHAR2(3)	DEFAULT FND_API.G_MISS_CHAR,
	ULTIMATE_DROPOFF_LOCATION_ID    NUMBER	DEFAULT FND_API.G_MISS_NUM,
	ULTIMATE_DROPOFF_LOCATION_CODE  VARCHAR2(20)	DEFAULT FND_API.G_MISS_CHAR,
	ULTIMATE_DROPOFF_DATE           DATE	DEFAULT FND_API.G_MISS_DATE,
	CUSTOMER_ID                     NUMBER	DEFAULT FND_API.G_MISS_NUM,
	CUSTOMER_NUMBER                 VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	INTMED_SHIP_TO_LOCATION_ID      NUMBER	DEFAULT FND_API.G_MISS_NUM,
	INTMED_SHIP_TO_LOCATION_CODE    VARCHAR2(20)	DEFAULT FND_API.G_MISS_CHAR,
	POOLED_SHIP_TO_LOCATION_ID      NUMBER	DEFAULT FND_API.G_MISS_NUM,
	POOLED_SHIP_TO_LOCATION_CODE    VARCHAR2(20)	DEFAULT FND_API.G_MISS_CHAR,
	CARRIER_ID                      NUMBER	DEFAULT FND_API.G_MISS_NUM,
	CARRIER_CODE                    VARCHAR2(25)	DEFAULT FND_API.G_MISS_CHAR,
	SHIP_METHOD_CODE                VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	SHIP_METHOD_NAME                VARCHAR2(80)	DEFAULT FND_API.G_MISS_CHAR,
	FREIGHT_TERMS_CODE              VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	FREIGHT_TERMS_NAME              VARCHAR2(80)	DEFAULT FND_API.G_MISS_CHAR,
	FOB_CODE                        VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	FOB_NAME                        VARCHAR2(80)	DEFAULT FND_API.G_MISS_CHAR,
	FOB_LOCATION_ID                 NUMBER	DEFAULT FND_API.G_MISS_NUM,
	FOB_LOCATION_CODE               VARCHAR2(20)	DEFAULT FND_API.G_MISS_CHAR,
	WAYBILL                         VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	DOCK_CODE                       VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	ACCEPTANCE_FLAG                 VARCHAR2(1)	DEFAULT FND_API.G_MISS_CHAR,
	ACCEPTED_BY                     VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ACCEPTED_DATE                   DATE	DEFAULT FND_API.G_MISS_DATE,
	ACKNOWLEDGED_BY                 VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	CONFIRMED_BY                    VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	CONFIRM_DATE                    DATE	DEFAULT FND_API.G_MISS_DATE,
	ASN_DATE_SENT                   DATE	DEFAULT FND_API.G_MISS_DATE,
	ASN_STATUS_CODE                 VARCHAR2(15)	DEFAULT FND_API.G_MISS_CHAR,
	ASN_SEQ_NUMBER                  NUMBER	DEFAULT FND_API.G_MISS_NUM,
	GROSS_WEIGHT                    NUMBER	DEFAULT FND_API.G_MISS_NUM,
	NET_WEIGHT                      NUMBER	DEFAULT FND_API.G_MISS_NUM,
	WEIGHT_UOM_CODE                 VARCHAR2(3)	DEFAULT FND_API.G_MISS_CHAR,
	WEIGHT_UOM_DESC                 VARCHAR2(25)	DEFAULT FND_API.G_MISS_CHAR,
	VOLUME                          NUMBER	DEFAULT FND_API.G_MISS_NUM,
	VOLUME_UOM_CODE                 VARCHAR2(3)	DEFAULT FND_API.G_MISS_CHAR,
	VOLUME_UOM_DESC                 VARCHAR2(25)	DEFAULT FND_API.G_MISS_CHAR,
	ADDITIONAL_SHIPMENT_INFO        VARCHAR2(500)	DEFAULT FND_API.G_MISS_CHAR,
	CURRENCY_CODE                   VARCHAR2(15)	DEFAULT FND_API.G_MISS_CHAR,
	CURRENCY_NAME                   VARCHAR2(80)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE_CATEGORY              VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE1                      VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE2                      VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE3                      VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE4                      VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE5                      VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE6                      VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE7                      VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE8                      VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE9                      VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE10                     VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE11                     VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE12                     VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE13                     VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE14                     VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	ATTRIBUTE15                     VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE_CATEGORY           VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE1                   VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE2                   VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE3                   VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE4                   VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE5                   VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE6                   VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE7                   VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE8                   VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE9                   VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE10                  VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE11                  VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE12                  VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE13                  VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE14                  VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	TP_ATTRIBUTE15                  VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE_CATEGORY       VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE1               VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE2               VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE3               VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE4               VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE5               VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE6               VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE7               VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE8               VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE9               VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE10              VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE11              VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE12              VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE13              VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE14              VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE15              VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE16              VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE17              VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE18              VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE19              VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	GLOBAL_ATTRIBUTE20              VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR,
	CREATION_DATE                   DATE	DEFAULT FND_API.G_MISS_DATE,
	CREATED_BY                      NUMBER	DEFAULT FND_API.G_MISS_NUM,
	LAST_UPDATE_DATE                DATE	DEFAULT FND_API.G_MISS_DATE,
	LAST_UPDATED_BY                 NUMBER	DEFAULT FND_API.G_MISS_NUM,
	LAST_UPDATE_LOGIN               NUMBER	DEFAULT FND_API.G_MISS_NUM,
	PROGRAM_APPLICATION_ID          NUMBER	DEFAULT FND_API.G_MISS_NUM,
	PROGRAM_ID                      NUMBER	DEFAULT FND_API.G_MISS_NUM,
	PROGRAM_UPDATE_DATE             DATE	DEFAULT FND_API.G_MISS_DATE,
	REQUEST_ID                      NUMBER	DEFAULT FND_API.G_MISS_NUM,
	NUMBER_OF_LPN                   NUMBER	DEFAULT FND_API.G_MISS_NUM,
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
        AUTO_SC_EXCLUDE_FLAG            VARCHAR2(1)   DEFAULT FND_API.G_MISS_CHAR,
        AUTO_AP_EXCLUDE_FLAG            VARCHAR2(1)   DEFAULT FND_API.G_MISS_CHAR,
/* BUG 3667348*/
	REASON_OF_TRANSPORT		VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
	DESCRIPTION			VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
--Non Database field added for "Proration of weight from Delivery to delivery lines" Project(Bug#4254552).
	PRORATE_WT_FLAG			VARCHAR2(1)   DEFAULT FND_API.G_MISS_CHAR,
        -- LSP PROJECT
        CLIENT_ID                     NUMBER	   DEFAULT FND_API.G_MISS_NUM,
	CLIENT_CODE                   VARCHAR2(10) DEFAULT FND_API.G_MISS_CHAR
        -- LSP PROJECT
	);

--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Create_Update_Delivery         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--		     p_delivery_info         Attributes for the delivery entity
--             p_delivery_name         Delivery name for update
--  	          x_delivery_id - delivery_Id of new delivery,
--             x_name - Name of delivery
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_new_deliveries table with information
--             specified in p_delivery_info
--========================================================================

/*#
 * Create or update a delivery with information specified in p_delivery_info
 * @param p_api_version_number  version number of the API
 * @param p_init_msg_list       messages will be initialized if set as true
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_action_code         action to be performed, could be 'CREATE' or 'UPDATE'
 * @param p_delivery_info       attributes for the delivery entity
 * @param p_delivery_name       delivery name for update
 * @param x_delivery_id         output parameter, delivery ID of new delivery
 * @param x_name                output parameter, delivery name of the new delivery
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Update Delivery
 */
  PROCEDURE Create_Update_Delivery
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_delivery_info	         IN OUT NOCOPY   Delivery_Pub_Rec_Type,
    p_delivery_name          IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    x_delivery_id            OUT NOCOPY   NUMBER,
    x_name                   OUT NOCOPY   VARCHAR2);


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
--		     p_delivery_id           Delivery identifier
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
--             p_sc_rule_id            Ship Confirm rule id
--             p_sc_rule_name          Ship Confirm rule name
--             p_wv_override_flag      Override flag for weight/volume calc
--             x_trip_id               Autocreated trip id
--             x_trip_name             Autocreated trip name
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified in p_action_code
--             on an existing delivery identified by p_delivery_id/p_delivery_name.
--========================================================================
/*#
 * This procedure is used to perform an action specified in p_action_code
 * on an existing delivery identified by p_delivery_id/p_delivery_name.
 * @param p_api_version_number        version number of the API
 * @param p_init_msg_list             messages will be initialized if set as true
 * @param x_return_status             return status of the API
 * @param x_msg_count                 number of messages, if any
 * @param x_msg_data                  message text, if any
 * @param p_action_code               action code, valid values are 'PLAN','UNPLAN','PACK','CONFIRM','RE-OPEN','IN-TRANSIT','CLOSE', 'ASSIGN-TRIP','UNASSIGN-TRIP','AUTOCREATE-TRIP', 'WT-VOL', 'PICK-RELEASE', 'DELETE'
 * @param p_delivery_id               delivery ID of the delivery
 * @param p_delivery_name             delivery name of the delivery
 * @param p_asg_trip_id               trip ID for assignment
 * @param p_asg_trip_name             trip name for assignment
 * @param p_asg_pickup_stop_id        stop ID for pickup assignment
 * @param p_asg_pickup_loc_id         stop location for pickup assignment
 * @param p_asg_pickup_stop_seq       obsolete, stop sequence number for pickup assignment
 * @param p_asg_pickup_loc_code       stop location code for pickup assignment
 * @param p_asg_pickup_arr_date       stop location arrival date for pickup assignment
 * @param p_asg_pickup_dep_date       stop location departure date for pickup assignment
 * @param p_asg_dropoff_stop_id       stop id for dropoff assignment
 * @param p_asg_dropoff_loc_id        stop location for dropoff assignment
 * @param p_asg_dropoff_stop_seq      obsolete, stop sequence number for dropoff assignment
 * @param p_asg_dropoff_loc_code      stop location code for dropoff assignment
 * @param p_asg_dropoff_arr_date      stop location arrival date for dropoff assignment
 * @param p_asg_dropoff_dep_date      stop location departure date for dropoff assignment
 * @param p_sc_action_flag            ship confirm option - 'S', 'B', 'T', 'A', 'C'
 * @param p_sc_intransit_flag         ship confirm set in-transit flag
 * @param p_sc_close_trip_flag        ship confirm close trip flag
 * @param p_sc_create_bol_flag        ship confirm create BOL flag
 * @param p_sc_stage_del_flag         ship confirm create delivery for staged quantity flag
 * @param p_sc_trip_ship_method       ship confirm trip ship method
 * @param p_sc_actual_dep_date        ship confirm actual departure date
 * @param p_sc_report_set_id          ship confirm report set id
 * @param p_sc_report_set_name        ship confirm report set name
 * @param p_sc_defer_interface_flag   ship confirm defer interface flag
 * @param p_sc_send_945_flag          ship confirm flag to trigger outbound shipment advise
 * @param p_sc_rule_id                ship confirm rule ID
 * @param p_sc_rule_name              ship confirm rule name
 * @param p_wv_override_flag          override flag for weight/volume calculation
 * @param x_trip_id                   autocreated trip id
 * @param x_trip_name                 autocreated trip name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delivery Action
 */
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
    p_sc_defer_interface_flag IN   VARCHAR2 DEFAULT 'Y',
    p_sc_send_945_flag       IN   VARCHAR2  DEFAULT NULL,
    p_sc_rule_id             IN   NUMBER DEFAULT NULL,
    p_sc_rule_name           IN   VARCHAR2 DEFAULT NULL,
    p_wv_override_flag       IN   VARCHAR2 DEFAULT 'N',
    x_trip_id                OUT NOCOPY   VARCHAR2,
    x_trip_name              OUT NOCOPY   VARCHAR2);

--============================================================================
-- PROCEDURE   : Genereate_Documents           PUBLIC
--
-- PARAMETERS  : p_report_set_name             report set name
--               p_organization_code           organization code
--               p_delivery_name               delivery name
--               x_msg_count                   Error Message Count
--               x_msg_data                    Error Message
--               x_return_status               return status
--
-- VERSION     : current version               1.0.1
--               initial version               1.0
--
-- COMMENT     : This Procedure is created for Backward Compatability.
--
-- CREATED  BY : version 1.0.1                 UESHANKA
-- CREATION DT : version 1.0.1                 12/MAR/2003
--
--============================================================================

/*#
 * This procedure is used to perform an action specified in p_action_code
 * on an existing delivery identified by p_delivery_id/p_delivery_name.
 * @param p_report_set_name         report set name
 * @param p_organization_code       organization code
 * @param p_delivery_name           delivery name
 * @param x_msg_count               number of messages, if any
 * @param x_msg_data                message text, if any
 * @param x_return_status           return status of the API
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Documents
 */
  PROCEDURE Generate_Documents
             ( p_report_set_name       IN     VARCHAR2,
               p_organization_code     IN     VARCHAR2,
               p_delivery_name         IN     WSH_UTIL_CORE.Column_Tab_Type,
               x_msg_count             OUT  NOCOPY  NUMBER,
               x_msg_data              OUT  NOCOPY  VARCHAR2,
               x_return_status         OUT  NOCOPY  VARCHAR2
              );

END WSH_DELIVERIES_PUB;

/
