--------------------------------------------------------
--  DDL for Package WSH_FREIGHT_COSTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FREIGHT_COSTS_GRP" AUTHID CURRENT_USER as
/* $Header: WSHFCGPS.pls 120.0.12010000.1 2008/07/29 06:04:34 appldev ship $ */

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
, CALCULATION_METHOD            VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR
, UOM                           VARCHAR2(15)	DEFAULT FND_API.G_MISS_CHAR
, QUANTITY                      NUMBER		DEFAULT FND_API.G_MISS_NUM
, TOTAL_AMOUNT                  NUMBER		DEFAULT FND_API.G_MISS_NUM
, CURRENCY_CODE         	VARCHAR2(15)	DEFAULT FND_API.G_MISS_CHAR
, CONVERSION_DATE       	DATE		DEFAULT FND_API.G_MISS_DATE
, CONVERSION_RATE       	NUMBER		DEFAULT FND_API.G_MISS_NUM
, CONVERSION_TYPE_CODE  	VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR
, TRIP_ID               	NUMBER		DEFAULT FND_API.G_MISS_NUM
, TRIP_NAME                     VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR
, STOP_ID               	NUMBER		DEFAULT FND_API.G_MISS_NUM
, STOP_LOCATION_ID             	NUMBER		DEFAULT FND_API.G_MISS_NUM
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
, FREIGHT_CODE 			VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR
, PRICING_LIST_HEADER_ID        NUMBER		DEFAULT FND_API.G_MISS_NUM
, PRICING_LIST_LINE_ID          NUMBER		DEFAULT FND_API.G_MISS_NUM
, APPLIED_TO_CHARGE_ID          NUMBER		DEFAULT FND_API.G_MISS_NUM
, CHARGE_UNIT_VALUE             NUMBER		DEFAULT FND_API.G_MISS_NUM
, CHARGE_SOURCE_CODE            VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR
, LINE_TYPE_CODE                VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR
, ESTIMATED_FLAG                VARCHAR2(1)	DEFAULT FND_API.G_MISS_CHAR
, ACTION_CODE              	VARCHAR2(30)	DEFAULT FND_API.G_MISS_CHAR
, COMMODITY_CATEGORY_ID        	NUMBER   	DEFAULT FND_API.G_MISS_NUM
);

TYPE PubFreightCostTabType IS TABLE OF PubFreightCostRecType INDEX BY BINARY_INTEGER;

PROCEDURE Create_Update_Freight_Costs (
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count              	OUT NOCOPY  NUMBER
, x_msg_data               	OUT NOCOPY  VARCHAR2
, p_pub_freight_costs	IN     WSH_FREIGHT_COSTS_GRP.PubFreightCostRecType
, p_action_code            IN     VARCHAR2
, x_freight_cost_id           OUT NOCOPY  NUMBER
);

PROCEDURE Validate_freight_Cost_type(
  p_freight_cost_type      IN     VARCHAR2
, x_freight_cost_type_id   IN OUT NOCOPY  NUMBER
, x_return_status             OUT NOCOPY  VARCHAR2
);

PROCEDURE Delete_Freight_costs(
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_pub_freight_costs      IN     WSH_FREIGHT_COSTS_GRP.PubFreightCostRecType
);

--Harmonizing Project : heali
TYPE FreightInRecType    IS     RECORD
      (
       caller		VARCHAR2(32767),
       action_code 	VARCHAR2(32767),
       phase		NUMBER
      );

TYPE FreightOutRecType    IS   RECORD
      (
        freight_cost_id            NUMBER,
        rowid			   VARCHAR2(4000)
      );

TYPE freight_rec_tab_type IS TABLE OF WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type INDEX BY BINARY_INTEGER;
TYPE freight_out_tab_type IS TABLE OF FreightOutRecType INDEX BY BINARY_INTEGER;

PROCEDURE Create_Update_Freight_Costs(
p_api_version_number	 IN	NUMBER,
p_init_msg_list          IN 	VARCHAR2,
p_commit               	 IN 	VARCHAR2,
p_freight_info_tab 	 IN 	freight_rec_tab_type,
p_in_rec          	 IN  	freightInRecType,
x_out_tab       	 OUT 	NOCOPY freight_out_tab_type,
x_return_status 	 OUT	NOCOPY VARCHAR2,
x_msg_count   		 OUT 	NOCOPY NUMBER,
x_msg_data       	 OUT	NOCOPY VARCHAR2
);

--Harmonizing Project : heali

END WSH_FREIGHT_COSTS_GRP;

/
