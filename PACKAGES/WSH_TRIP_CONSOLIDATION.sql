--------------------------------------------------------
--  DDL for Package WSH_TRIP_CONSOLIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRIP_CONSOLIDATION" AUTHID CURRENT_USER as
/* $Header: WSHTRCOS.pls 120.0.12010000.2 2009/12/03 13:27:22 anvarshn ship $ */

--
G_PKG_NAME	CONSTANT	VARCHAR2(100) := 'WSH_TRIP_CONSOLIDATION';
--
TYPE t_DelivRec IS RECORD (
	DELIVERY_ID                    		NUMBER,
	ORGANIZATION_ID                	 	NUMBER,
        STATUS_CODE                     	VARCHAR2(2),
        PLANNED_FLAG                    	VARCHAR2(1),
        NAME                            	VARCHAR2(30),
        INITIAL_PICKUP_DATE             	DATE,
        INITIAL_PICKUP_LOCATION_ID      	NUMBER,
        ULTIMATE_DROPOFF_LOCATION_ID    	NUMBER,
        ULTIMATE_DROPOFF_DATE           	DATE,
        CUSTOMER_ID                     	NUMBER,
        INTMED_SHIP_TO_LOCATION_ID      	NUMBER,
        SHIP_METHOD_CODE                	VARCHAR2(30),
        DELIVERY_TYPE                   	VARCHAR2(30),
        CARRIER_ID                     		NUMBER,
        SERVICE_LEVEL                   	VARCHAR2(30),
        MODE_OF_TRANSPORT              		VARCHAR2(30),
	SHIPMENT_DIRECTION			VARCHAR2(30),
	PARTY_ID				NUMBER,
	SHIPPING_CONTROL			VARCHAR2(30),
        IGNORE_FOR_PLANNING                     VARCHAR2(1),
        HASH_VALUE                      	NUMBER
        );
--
TYPE t_HashRec IS RECORD (HashString	VARCHAR2(1000));
--
TYPE t_DelivGrpRec IS RECORD (
	deliv_IDTab	WSH_UTIL_CORE.ID_TAB_TYPE,
	max_delivs	NUMBER);
--
TYPE t_Cursor_ref IS REF CURSOR;

TYPE HashTable IS TABLE OF t_HashRec INDEX BY BINARY_INTEGER;
TYPE DelivTable IS TABLE OF t_DelivRec INDEX BY BINARY_INTEGER;
--
g_HashBase 	NUMBER := 1;
g_HashSize 	NUMBER := POWER(2, 25);
g_BindVarTab	WSH_UTIL_CORE.tbl_varchar;
g_SuccDelivs	NUMBER := 0;
g_Trips		NUMBER := 0;
--
PROCEDURE Create_Consolidated_Trips(
		p_deliv_status		IN VARCHAR2,
		p_pickup_start		IN DATE,
		p_pickup_end		IN DATE,
		p_dropoff_start		IN DATE,
		p_dropoff_end		IN DATE,
                p_client_id             IN NUMBER,  -- Modified R12.1.1 LSP PROJECT
		p_ship_from_org_id	IN NUMBER,
		p_customer_id		IN NUMBER,
		p_ship_to_location	IN VARCHAR2,
		p_ship_method_code	IN VARCHAR2,
		p_grp_ship_method	IN VARCHAR2,
		p_grp_ship_from		IN VARCHAR2,
		p_max_num_deliveries	IN NUMBER DEFAULT 50,
		x_TotDeliveries		OUT NOCOPY NUMBER,
		x_SuccessDeliv		OUT NOCOPY NUMBER,
		x_Trips			OUT NOCOPY NUMBER,
		x_return_status		OUT NOCOPY VARCHAR2
);

PROCEDURE BuildQuery(p_deliv_status		IN VARCHAR2,
		     p_pickup_start		IN DATE,
		     p_pickup_end		IN DATE,
		     p_dropoff_start		IN DATE,
		     p_dropoff_end		IN DATE,
                     p_client_id     IN NUMBER,  -- Modified R12.1.1 LSP PROJECT
		     p_ship_from_org_id		IN NUMBER,
		     p_customer_id		IN NUMBER,
		     p_ship_to_location		IN NUMBER,
		     p_ship_method_code		IN VARCHAR2,
		     x_query			OUT NOCOPY VARCHAR2,
		     x_return_status		OUT NOCOPY VARCHAR2);


PROCEDURE CreateAssignHashValue(p_grp_ship_from	  IN 	VARCHAR2,
            		        p_grp_ship_method IN	VARCHAR2,
			        x_del_rec	  IN OUT NOCOPY  t_DelivRec,
				x_HashTable	  IN OUT NOCOPY HashTable,
			        x_RetSts	  OUT NOCOPY VARCHAR2,
				x_UseDeliv	  OUT NOCOPY VARCHAR2);


FUNCTION FetchDelivery(p_Deliv_ref  IN 		  t_Cursor_ref,
                       x_deliv_rec  IN OUT NOCOPY t_DelivRec)
RETURN BOOLEAN;


PROCEDURE BuildDelivRec(p_DelivRec IN t_DelivRec,
			x_DelivRec IN OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
			x_RetSts   OUT NOCOPY VARCHAR2);



PROCEDURE GroupDelivsIntoTrips( p_DelivGrpRec	IN t_DelivGrpRec,
			 	x_delOutRec	OUT NOCOPY WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type,
			 	x_return_status OUT NOCOPY VARCHAR2);


END WSH_TRIP_CONSOLIDATION;

/
