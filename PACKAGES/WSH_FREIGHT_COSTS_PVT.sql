--------------------------------------------------------
--  DDL for Package WSH_FREIGHT_COSTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FREIGHT_COSTS_PVT" AUTHID CURRENT_USER AS
/* $Header: WSHFCTHS.pls 120.1 2007/01/05 23:00:12 schennal noship $ */
-- set tabstop=3 to read in correct alignment
--
-- Package type declarations
--
TYPE Freight_Cost_Rec_Type IS RECORD (
  FREIGHT_COST_ID           NUMBER
, FREIGHT_COST_TYPE_ID        NUMBER
, UNIT_AMOUNT                 NUMBER
/* H Integration: datamodel changes wrudge (15->30) */
, CALCULATION_METHOD              VARCHAR2(30)
, UOM                         VARCHAR2(15)
, QUANTITY                    NUMBER
, TOTAL_AMOUNT                NUMBER
, CURRENCY_CODE               VARCHAR2(15)
, CONVERSION_DATE             DATE
, CONVERSION_RATE             NUMBER
, CONVERSION_TYPE_CODE        VARCHAR2(30)
, TRIP_ID                     NUMBER
, STOP_ID                     NUMBER
, DELIVERY_ID                 NUMBER
, DELIVERY_LEG_ID             NUMBER
, DELIVERY_DETAIL_ID          NUMBER
, ATTRIBUTE_CATEGORY          VARCHAR2(150)
, ATTRIBUTE1              VARCHAR2(150)
, ATTRIBUTE2              VARCHAR2(150)
, ATTRIBUTE3              VARCHAR2(150)
, ATTRIBUTE4              VARCHAR2(150)
, ATTRIBUTE5              VARCHAR2(150)
, ATTRIBUTE6              VARCHAR2(150)
, ATTRIBUTE7              VARCHAR2(150)
, ATTRIBUTE8              VARCHAR2(150)
, ATTRIBUTE9              VARCHAR2(150)
, ATTRIBUTE10             VARCHAR2(150)
, ATTRIBUTE11             VARCHAR2(150)
, ATTRIBUTE12             VARCHAR2(150)
, ATTRIBUTE13               VARCHAR2(150)
, ATTRIBUTE14             VARCHAR2(150)
, ATTRIBUTE15             VARCHAR2(150)
, CREATION_DATE           DATE
, CREATED_BY              NUMBER
, LAST_UPDATE_DATE          DATE
, LAST_UPDATED_BY                NUMBER
, LAST_UPDATE_LOGIN         NUMBER
, PROGRAM_APPLICATION_ID      NUMBER
, PROGRAM_ID                     NUMBER
, PROGRAM_UPDATE_DATE            DATE
, REQUEST_ID                     NUMBER
/* H Integration: datamodel changes wrudge */
, PRICING_LIST_HEADER_ID  NUMBER
, PRICING_LIST_LINE_ID    NUMBER
, APPLIED_TO_CHARGE_ID    NUMBER
, CHARGE_UNIT_VALUE   NUMBER
, CHARGE_SOURCE_CODE    VARCHAR2(30)
, LINE_TYPE_CODE    VARCHAR2(30)
, ESTIMATED_FLAG    VARCHAR2(1)
/* Harmonizing project I: heali */
, FREIGHT_CODE                  VARCHAR2(30)
, TRIP_NAME                     VARCHAR2(30)
, DELIVERY_NAME                 VARCHAR2(30)
, FREIGHT_COST_TYPE             VARCHAR2(30)
, STOP_LOCATION_ID              NUMBER
, PLANNED_DEP_DATE              DATE
, COMMODITY_CATEGORY_ID         NUMBER
/* R12 new attributes */
, BILLABLE_QUANTITY             NUMBER
, BILLABLE_UOM                  VARCHAR2(15)
, BILLABLE_BASIS                VARCHAR2(30)
);

--
-- Procedure:    Create_Freight_Cost
--
PROCEDURE Create_Freight_Cost(
  p_freight_cost_info                       IN     Freight_Cost_Rec_Type
, x_rowid                                      OUT NOCOPY  VARCHAR2
, x_freight_cost_id                            OUT NOCOPY  NUMBER
, x_return_status                              OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Freight_Cost(
  p_rowid                                   IN     VARCHAR2
, p_freight_cost_info                       IN     Freight_Cost_Rec_Type
, x_return_status                              OUT NOCOPY  VARCHAR2
);

PROCEDURE Lock_Freight_Cost(
  p_rowid                                   IN     VARCHAR2
, p_freight_cost_info                       IN     Freight_Cost_Rec_Type
);

PROCEDURE Delete_Freight_Cost(
  p_rowid                                   IN     VARCHAR2
, p_freight_cost_id                         IN     NUMBER
, x_return_status                              OUT NOCOPY  VARCHAR2
);


PROCEDURE Split_Freight_Cost(
  p_from_freight_cost_id                    IN     NUMBER
, x_new_freight_cost_id                     OUT NOCOPY     NUMBER
, p_new_delivery_detail_id              IN    NUMBER
, p_requested_quantity                  IN    NUMBER
, p_split_requested_quantity              IN    NUMBER
, x_return_status                           OUT NOCOPY  VARCHAR2
);


--This procedure needs to be removed as this is no longer used - post I.
--Waiting for STF changes before removing this.
--Replaced by another procedure with same name
PROCEDURE Get_Total_Freight_Cost(
  p_entity_level    IN VARCHAR2,
  p_entity_id       IN NUMBER,
  p_currency_code   IN VARCHAR2,
  x_total_amount    OUT NOCOPY NUMBER,
  x_return_status   OUT NOCOPY VARCHAR2);

PROCEDURE Get_Total_Freight_Cost(
  p_entity_level    IN VARCHAR2,
  p_entity_id       IN NUMBER,
  p_currency_code   IN VARCHAR2,
  x_detail_amount    OUT  NOCOPY NUMBER ,
  x_lpn_amount    OUT  NOCOPY NUMBER ,
  x_main_lpn_amount    OUT  NOCOPY NUMBER,
  x_delivery_amount    OUT  NOCOPY NUMBER ,
  x_stop_amount    OUT  NOCOPY NUMBER ,
  x_trip_amount    OUT  NOCOPY NUMBER ,
  x_return_status   OUT  NOCOPY VARCHAR2);

PROCEDURE Get_Summary_Freight_Cost(
  p_entity_level       IN  VARCHAR2,
  p_entity_id          IN  NUMBER,
  p_currency_code      IN  VARCHAR2,
  x_total_amount       OUT NOCOPY NUMBER,
  x_reprice_required   OUT NOCOPY VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2);



PROCEDURE Convert_Amount (
  p_from_currency     IN VARCHAR2,
  p_to_currency       IN VARCHAR2,
  p_conversion_date   IN DATE,
  p_conversion_rate   IN NUMBER,
  p_conversion_type   IN VARCHAR2,
  p_amount            IN NUMBER,
  x_converted_amount  OUT NOCOPY NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2);

PROCEDURE Remove_FTE_Freight_Costs(
   p_delivery_details_tab IN WSH_UTIL_CORE.Id_Tab_Type,
   x_return_status        OUT NOCOPY  VARCHAR2 );

PROCEDURE Get_Trip_Manual_Freight_Cost(
  p_trip_id         IN NUMBER,
  p_currency_code   IN VARCHAR2,
  x_trip_amount     OUT NOCOPY  NUMBER,
  x_return_status   OUT  NOCOPY VARCHAR2);

END WSH_FREIGHT_COSTS_PVT;

/
