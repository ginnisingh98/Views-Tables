--------------------------------------------------------
--  DDL for Package WSH_EXCEPTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_EXCEPTIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: WSHXCPBS.pls 120.0 2005/05/26 17:59:26 appldev noship $ */
/*#
 * This package provides the APIs to create Exceptions for delivery lines, deliveries, trips
 * and to perform various actions on Exceptions.
 * @rep:scope public
 * @rep:product WSH
 * @rep:displayname Exceptions
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY  WSH_DELIVERY_LINE
 * @rep:category BUSINESS_ENTITY  WSH_DELIVERY
 * @rep:category BUSINESS_ENTITY  WSH_TRIP
 */

TYPE XC_REC_TYPE IS RECORD
     (exception_id	NUMBER,
     exception_name	VARCHAR2(30),
     status		VARCHAR2(30)
     );

TYPE XC_ACTION_REC_TYPE IS RECORD
        (
        -- The following fields are used for Logging exceptions
        request_id           NUMBER,           -- Also used for Purge
        batch_id             NUMBER,
        exception_id         NUMBER,
        exception_name       VARCHAR2(30),     -- Also used for Purge, Change_Status
        logging_entity       VARCHAR2(30),     -- Also used for Purge, Change_Status
        logging_entity_id    NUMBER,           -- Also used for Change_Status
        manually_logged      VARCHAR2(1),
        message              VARCHAR2(2000),
        logged_at_location_code       VARCHAR2(50),  -- Also used for Purge
        exception_location_code       VARCHAR2(50),  -- Also used for Purge
        severity             VARCHAR2(10),           -- Also used for Purge
        delivery_name        VARCHAR2(30),           -- Also used for Purge
        trip_name            VARCHAR2(30),
        stop_location_id     NUMBER,
        delivery_detail_id   NUMBER,
        container_name       VARCHAR2(50),
        org_id               NUMBER,
        inventory_item_id    NUMBER,
-- HW OPMCONV. Need to expand length of lot_number to 80
        lot_number           VARCHAR2(80),
-- HW OPMCONV. No need for sublot anymore
--      sublot_number        VARCHAR2(32),
        revision             VARCHAR2(3),
        serial_number        VARCHAR2(30),
        unit_of_measure      VARCHAR2(5),
        quantity             NUMBER,
        unit_of_measure2     VARCHAR2(3),
        quantity2            NUMBER,
        subinventory         VARCHAR2(10),
        locator_id           NUMBER,
        error_message        VARCHAR2(500),
        attribute_category   VARCHAR2(150),
        attribute1           VARCHAR2(150),
        attribute2           VARCHAR2(150),
        attribute3           VARCHAR2(150),
        attribute4           VARCHAR2(150),
        attribute5           VARCHAR2(150),
        attribute6           VARCHAR2(150),
        attribute7           VARCHAR2(150),
        attribute8           VARCHAR2(150),
        attribute9           VARCHAR2(150),
        attribute10          VARCHAR2(150),
        attribute11          VARCHAR2(150),
        attribute12          VARCHAR2(150),
        attribute13          VARCHAR2(150),
        attribute14          VARCHAR2(150),
        attribute15          VARCHAR2(150),
        departure_date       DATE,             -- Also used for Purge
        arrival_date         DATE,             -- Also used for Purge

        -- These fields are used for the Purge action.
        exception_type       VARCHAR2(25),
        status               VARCHAR2(30),
        departure_date_to    DATE,
        arrival_date_to      DATE,
        creation_date        DATE,
        creation_date_to     DATE,
        data_older_no_of_days    NUMBER,

        -- This field is used for Change_Status action.
        new_status           VARCHAR2(30),

        caller          VARCHAR2(100),
        phase           NUMBER
        );

TYPE XC_TAB_TYPE IS TABLE OF XC_REC_TYPE INDEX BY BINARY_INTEGER;

------------------------------------------------------------------------------
-- Procedure:	Get_Exceptions
--
-- Parameters:  1) p_logging_entity_id - entity id for a particular entity name
--              2) p_logging_entity_name - can be 'TRIP', 'STOP', 'DELIVERY',
--                                       'DETAIL', or 'CONTAINER'
--              3) x_exceptions_tab - list of exceptions
--
-- Description: This procedure takes in a logging entity id and logging entity
--              name and create an exception table.
------------------------------------------------------------------------------
/*#
 * This procedure takes in a logging entity id and logging entity
 * name and create an exception table.
 * @param p_api_version           Version number of the API
 * @param p_init_msg_list         Messages will be initialized, if set as true
 * @param x_return_status         Return Status of the API
 * @param x_msg_count             Number of Messages, if any
 * @param x_msg_data              Message Text, if any
 * @param p_logging_entity_id     ID of Logging Entity
 * @param p_logging_entity_name   Name of Logging Entity
 * @param x_exceptions_tab        Exceptions Table
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Exceptions
 */

PROCEDURE Get_Exceptions (
        -- Standard parameters
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,

        -- program specific parameters
        p_logging_entity_id	IN 	NUMBER,
	p_logging_entity_name	IN	VARCHAR2,

        -- program specific out parameters
        x_exceptions_tab	OUT NOCOPY 	WSH_EXCEPTIONS_PUB.XC_TAB_TYPE
	);


------------------------------------------------------------------------------
-- Procedure:   Exception_Action
--
-- Parameters:
--
-- Description:  This procedure calls the corresponding procedures to Log,
--               Purge and Change_Status of the exceptions based on the action
--               code it receives through the parameter p_action.
------------------------------------------------------------------------------
/*#
 * This procedure calls the corresponding procedures to Log,
 * Purge and Change_Status of the exceptions based on the action
 * code it receives through the parameter p_action.
 * @param p_api_version           Version number of the API
 * @param p_init_msg_list         Messages will be initialized, if set as true
 * @param p_validation_level      Level of Validation
 * @param p_commit                commits the transaction, if set as true
 * @param x_msg_count             Number of Messages, if any
 * @param x_msg_data              Message Text, if any
 * @param x_return_status         Return Status of the API
 * @param p_exception_rec         Exception Record
 * @param p_action                Action Code
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Exception Actions
 */

PROCEDURE Exception_Action (
	p_api_version	        IN	NUMBER,
	p_init_msg_list		IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_validation_level      IN      NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_commit                IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,
        x_return_status         OUT NOCOPY      VARCHAR2,

	p_exception_rec         IN OUT  NOCOPY WSH_EXCEPTIONS_PUB.XC_ACTION_REC_TYPE,
        p_action                IN              VARCHAR2
	);

END WSH_EXCEPTIONS_PUB;

 

/
