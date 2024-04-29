--------------------------------------------------------
--  DDL for Package WSH_FREIGHT_COSTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FREIGHT_COSTS_PUB" AUTHID CURRENT_USER as
/* $Header: WSHFCPBS.pls 120.0 2005/05/26 17:29:25 appldev noship $ */
/*#
 * This is the public interface for freight costs. It has APIs to create,
 * update and delete freight costs for delivery lines, deliveries, trips
 * and to validate freight cost types.
 * @rep:scope public
 * @rep:product WSH
 * @rep:displayname Freight Cost
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY WSH_DELIVERY_LINE
 * @rep:category BUSINESS_ENTITY WSH_DELIVERY
 * @rep:category BUSINESS_ENTITY WSH_TRIP

 */

--===================
-- PROCEDURES
--===================
--========================================================================
-- PROCEDURE : Create_Update_Freight_Costs
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         initialize message stack
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--         		p_freight_cost_rec    	freight cost record
--             p_source_code           source system
--
--
-- COMMENT   : Create or Update freight costs
--             org_organization_definitions. If both values are
--             specified then only Org_Id is used
--========================================================================

TYPE PubFreightCostRecType IS RECORD(
  FREIGHT_COST_ID	   	NUMBER		DEFAULT FND_API.G_MISS_NUM
, FREIGHT_COST_TYPE_ID 		NUMBER		DEFAULT FND_API.G_MISS_NUM
, UNIT_AMOUNT	        	NUMBER		DEFAULT FND_API.G_MISS_NUM
, CURRENCY_CODE         	VARCHAR2(15)	DEFAULT FND_API.G_MISS_CHAR
, CONVERSION_DATE       	DATE		DEFAULT FND_API.G_MISS_DATE
, CONVERSION_RATE       	NUMBER		DEFAULT FND_API.G_MISS_NUM
, CONVERSION_TYPE_CODE  	VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR
, TRIP_ID               	NUMBER		DEFAULT FND_API.G_MISS_NUM
, TRIP_NAME                     VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR
, STOP_ID               	NUMBER 		DEFAULT FND_API.G_MISS_NUM
, STOP_LOCATION_ID              NUMBER		DEFAULT FND_API.G_MISS_NUM
, PLANNED_DEP_DATE              DATE		DEFAULT FND_API.G_MISS_DATE
, DELIVERY_ID           	NUMBER		DEFAULT FND_API.G_MISS_NUM
, DELIVERY_NAME                 VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR
, DELIVERY_LEG_ID       	NUMBER		DEFAULT FND_API.G_MISS_NUM
, DELIVERY_DETAIL_ID    	NUMBER		DEFAULT FND_API.G_MISS_NUM
, ATTRIBUTE_CATEGORY		VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE1			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE2			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE3			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE4			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE5			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE6			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE7			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE8			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE9			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE10			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE11			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE12			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE13		  	VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE14			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, ATTRIBUTE15			VARCHAR2(150)	DEFAULT FND_API.G_MISS_CHAR
, CREATION_DATE			DATE		DEFAULT FND_API.G_MISS_DATE
, CREATED_BY			NUMBER		DEFAULT FND_API.G_MISS_NUM
, LAST_UPDATE_DATE		DATE		DEFAULT FND_API.G_MISS_DATE
, LAST_UPDATED_BY               NUMBER		DEFAULT FND_API.G_MISS_NUM
, LAST_UPDATE_LOGIN		NUMBER		DEFAULT FND_API.G_MISS_NUM
, PROGRAM_APPLICATION_ID	NUMBER		DEFAULT FND_API.G_MISS_NUM
, PROGRAM_ID                    NUMBER		DEFAULT FND_API.G_MISS_NUM
, PROGRAM_UPDATE_DATE           DATE		DEFAULT FND_API.G_MISS_DATE
, REQUEST_ID                    NUMBER		DEFAULT FND_API.G_MISS_NUM
, FREIGHT_COST_TYPE        	VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR
, ACTION_CODE              	VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR
);

TYPE PubFreightCostTabType IS TABLE OF PubFreightCostRecType INDEX BY BINARY_INTEGER;

/*#
 * This procedure is used to create and update freight costs.
 * @param p_api_version_number  version number of the API
 * @param p_init_msg_list       messages will be initialized, if set as true
 * @param p_commit              commits the transaction, if set as true
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_pub_freight_costs   record structure for freight cost attributes to be created/updated
 * @param p_action_code         'CREATE' or 'UPDATE'
 * @param x_freight_cost_id     output freight cost id for the freight cost record created if the action is 'CREATE'
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create/Update Freight Costs
 */
PROCEDURE Create_Update_Freight_Costs (
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count              	OUT NOCOPY  NUMBER
, x_msg_data               	OUT NOCOPY  VARCHAR2
, p_pub_freight_costs	IN     WSH_FREIGHT_COSTS_PUB.PubFreightCostRecType
, p_action_code            IN     VARCHAR2
, x_freight_cost_id           OUT NOCOPY  NUMBER
);

/*#
 * This procedure is used to validate the freight cost type
 * @param p_freight_cost_type    freight cost type to be validated
 * @param x_freight_cost_type_id freight cost type id used for validation if passed in or will be output if freight cost type is passed
 * @param x_return_status        return status of the API
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Validate Freight Cost Type
 */
PROCEDURE Validate_freight_Cost_type(
  p_freight_cost_type      IN     VARCHAR2
, x_freight_cost_type_id   IN OUT NOCOPY  NUMBER
, x_return_status             OUT NOCOPY  VARCHAR2
);

/*#
 * This procedure is used to delete freight costs.
 * @param p_api_version_number  version number of the API
 * @param p_init_msg_list       messages will be initialized, if set as true
 * @param p_commit              commits the transaction, if set as true
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @param p_pub_freight_costs   record structure for freight cost record to be deleted
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Freight Costs
 */
PROCEDURE Delete_Freight_costs(
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_pub_freight_costs      IN     WSH_FREIGHT_COSTS_PUB.PubFreightCostRecType
);

END WSH_FREIGHT_COSTS_PUB;

 

/
