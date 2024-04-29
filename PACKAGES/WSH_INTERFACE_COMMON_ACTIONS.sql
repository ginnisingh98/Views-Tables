--------------------------------------------------------
--  DDL for Package WSH_INTERFACE_COMMON_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INTERFACE_COMMON_ACTIONS" AUTHID CURRENT_USER as
/* $Header: WSHINCAS.pls 120.0.12010000.2 2010/02/26 07:06:25 sankarun ship $ */


C_SDEBUG              CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL1;
C_DEBUG               CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL2;

--===================
-- PUBLIC VARS
--===================

-- Global variables and tables
G_Update_Attributes_Tab        WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
G_Packing_Detail_Tab            WSH_INTERFACE_COMMON_ACTIONS.PackingDetailTabType;
G_SERIAL_RANGE_TAB              WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType;

TYPE PackingDetailRecType IS RECORD(
	delivery_detail_id		NUMBER,
        -- TPW - Distributed changes
        src_container_flag              VARCHAR2(1),
	parent_delivery_detail_id	NUMBER);

TYPE  PackingDetailTabType IS TABLE of PackingDetailRecType
	INDEX BY BINARY_INTEGER;

--===================
-- PROCEDURES
--===================

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Update_Interface_Assignments
   PARAMETERS : p_parent_delivery_detail_id
		p_parent_detail_interface_id
		x_return_status - return status of API
  DESCRIPTION :

------------------------------------------------------------------------------
*/


PROCEDURE Update_Contnr_Int_Assignments(
	p_parent_delivery_detail_id 	IN NUMBER,
	p_parent_detail_interface_id  	IN NUMBER,
	x_return_status 		OUT NOCOPY  VARCHAR2);

PROCEDURE process_interfaced_del_details(
	p_delivery_interface_id		IN NUMBER,
	p_delivery_id			IN NUMBER	DEFAULT NULL,
	p_new_delivery_id		IN NUMBER	DEFAULT NULL,
	p_action_code			IN VARCHAR2,
	x_return_status 		OUT NOCOPY  VARCHAR2);

PROCEDURE process_interfaced_deliveries(
	p_delivery_interface_id		IN NUMBER,
	p_action_code			IN VARCHAR2,
	x_dlvy_id			OUT NOCOPY  NUMBER,
	x_return_status			OUT NOCOPY  VARCHAR2);

PROCEDURE Process_Splits(
	p_delivery_interface_id	IN NUMBER,
	p_delivery_id		IN NUMBER,
	x_return_status		OUT NOCOPY  VARCHAR2);

PROCEDURE Pack_Lines(
	x_return_status	OUT NOCOPY  VARCHAR2);

PROCEDURE Process_Non_Splits(
	p_delivery_interface_id	IN NUMBER,
	p_delivery_id		IN NUMBER,
	p_new_delivery_id	IN NUMBER,
	p_action_code		IN VARCHAR2,
	x_return_status		OUT NOCOPY  VARCHAR2);

PROCEDURE Process_Cancel(
		p_delivery_id	IN NUMBER,
		x_return_status	OUT NOCOPY  VARCHAR2);

PROCEDURE Delivery_Interface_Wrapper(
	p_delivery_interface_id		IN NUMBER,
	p_action_code			IN VARCHAR2,
	x_delivery_id			IN OUT NOCOPY  NUMBER,
	x_return_status			OUT NOCOPY  VARCHAR2);

PROCEDURE process_int_freight_costs(
	p_delivery_interface_id		IN NUMBER DEFAULT NULL,
	p_del_detail_interface_id	IN NUMBER DEFAULT NULL,
        -- TPW - Distributed changes
	p_delivery_detail_id            IN NUMBER DEFAULT NULL,
	p_stop_interface_id		IN NUMBER DEFAULT NULL,
	p_trip_interface_id		IN NUMBER DEFAULT NULL,
	x_return_status			OUT NOCOPY  VARCHAR2);

PROCEDURE Create_Update_Trip_For_dlvy(
	p_delivery_id	IN NUMBER,
	x_pickup_stop_id OUT NOCOPY  NUMBER,
	x_dropoff_stop_id OUT NOCOPY  NUMBER,
	x_trip_id	OUT NOCOPY  NUMBER,
	x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE Int_Trip_Stop_Info(
	p_delivery_interface_id		IN NUMBER,
	p_act_dep_date		IN 	DATE,
	p_dep_seal_code		IN	VARCHAR2,
	p_act_arr_date		IN 	DATE,
	p_trip_vehicle_num	IN 	VARCHAR2,
	p_trip_veh_num_pfx	IN	VARCHAR2,
	p_trip_route_id		IN	NUMBER,
	p_trip_routing_ins	IN	VARCHAR2,
--Bug 3458160
        p_operator              IN      VARCHAR2,
	x_return_status		OUT NOCOPY  	VARCHAR2);

PROCEDURE Lock_Delivery_And_Details(
	p_delivery_id	IN NUMBER,
	x_return_status OUT NOCOPY  VARCHAR2);


END WSH_INTERFACE_COMMON_ACTIONS;

/
