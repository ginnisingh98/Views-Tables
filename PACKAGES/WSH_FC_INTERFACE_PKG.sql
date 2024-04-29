--------------------------------------------------------
--  DDL for Package WSH_FC_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FC_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHFCIFS.pls 120.2 2006/02/19 20:39:49 somanaam noship $ */

--<TPA_PUBLIC_NAME=WSH_TPA_FREIGHT_COSTS_PKG>
--<TPA_PUBLIC_FILE_NAME=WSHTPFC>

TYPE RelavantInfoRecType IS RECORD (
  delivery_detail_id         NUMBER
, container_id               NUMBER
, delivery_id                NUMBER
, stop_id                    NUMBER
, trip_id                    NUMBER
, inventory_item_id          NUMBER
, requested_quantity         NUMBER
, shipped_quantity           NUMBER
, requested_quantity_uom     VARCHAR2(3)
, net_weight                 NUMBER
, weight_uom_code            VARCHAR2(3)
, volume                     NUMBER
, volume_uom_code            VARCHAR2(3)
);

TYPE RelavantInfoTabType IS TABLE OF RelavantInfoRecType
			INDEX BY BINARY_INTEGER;

TYPE ContainerRelationshipRecType IS RECORD (
  container_id						NUMBER
, parent_container_id			NUMBER
);

TYPE ContainerRelationshipTabType IS TABLE OF ContainerRelationshipRecType
			INDEX BY BINARY_INTEGER;


TYPE CostBreakdownRecType IS RECORD (
  delivery_detail_id    NUMBER
, inventory_item_id     NUMBER
, container_id          NUMBER
, delivery_id           NUMBER
, stop_id               NUMBER
, trip_id               NUMBER
, quantity              NUMBER
, uom                   VARCHAR2(10)
);

TYPE CostBreakdownTabType IS TABLE OF CostBreakdownRecType
			INDEX BY BINARY_INTEGER;

TYPE OMInterfaceCostRecType IS RECORD (
  source_line_id	NUMBER
, freight_cost_type_code VARCHAR2(30)
, freight_cost_id       NUMBER
, amount		NUMBER
, currency_code         VARCHAR2(15)
, source_header_id	NUMBER --HVOP heali
);

TYPE OMInterfaceCostTabType IS TABLE OF OMInterfaceCostRecType
			INDEX BY BINARY_INTEGER;

TYPE ProratedCostRecType IS RECORD (
  delivery_detail_id	NUMBER
, freight_cost_type_code VARCHAR2(30)
, freight_cost_id 	NUMBER
, amount		NUMBER
, currency_code         VARCHAR2(15)
, conversion_type_code  WSH_FREIGHT_COSTS.conversion_type_code%TYPE
, conversion_rate       WSH_FREIGHT_COSTS.conversion_rate%TYPE

);

TYPE ProratedCostTabType IS TABLE OF ProratedCostRecType
			INDEX BY BINARY_INTEGER;

TYPE ProratedChargeRecType IS RECORD (
  delivery_detail_id	     NUMBER
, amount		     NUMBER

);

TYPE ProratedChargeTabType IS TABLE OF ProratedChargeRecType
			INDEX BY BINARY_INTEGER;



PROCEDURE Round_Cost_Amount(
  p_Amount									IN	    NUMBER
, p_Currency_Code							IN     VARCHAR2
, x_Round_Amount						      OUT NOCOPY  NUMBER
, x_return_status                      OUT NOCOPY  VARCHAR2
);

PROCEDURE Source_Line_Level_Cost(
  p_stop_id									IN     NUMBER
, p_prorated_freight_cost           IN     ProratedCostTabType
, x_Final_Cost                      IN OUT NOCOPY  OMInterfaceCostTabType
, x_return_status                      OUT NOCOPY  VARCHAR2
);

PROCEDURE Calculate_Freight_Costs(
  p_stop_id				IN     NUMBER
, x_Freight_costs                      OUT NOCOPY  OMInterfaceCostTabType
, x_return_status                      OUT NOCOPY  VARCHAR2
);

--HVOP heali
PROCEDURE Process_Freight_Costs(
  p_stop_id             IN     NUMBER
, p_start_index		IN	NUMBER
, p_line_id_tbl         IN     OE_WSH_BULK_GRP.T_NUM
, x_freight_costs_all	IN OUT NOCOPY  OMInterfaceCostTabType
, x_freight_costs	IN OUT NOCOPY  OE_Ship_Confirmation_Pub.Ship_Adj_Rec_Type
, x_end_index		OUT NOCOPY NUMBER
, x_return_status	OUT NOCOPY  VARCHAR2
);
--HVOP heali


FUNCTION Prorate_Freight_Charge (
  p_delivery_detail_id                            IN     NUMBER
, p_charge_id                                     IN     NUMBER
) RETURN NUMBER;



-- Name       		Get_Cost_Factor
-- Purpose    		dummy function
--                      Since TPA does not support deleting obsolete APIs,
--                      this function needs to remain in this package
--                      (bug 1948149).
--
-- TPA Selector 	WSH_TPA_SELECTOR_PKG.FreightCostTP
FUNCTION Get_Cost_Factor(
  p_delivery_id   	             IN     NUMBER
, p_container_instance_id  	     IN     NUMBER
, x_return_status                    OUT NOCOPY     VARCHAR2
) RETURN VARCHAR2;
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.FreightCostTP>





END WSH_FC_INTERFACE_PKG;

 

/
