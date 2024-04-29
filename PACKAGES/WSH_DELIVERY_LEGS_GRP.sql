--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_LEGS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_LEGS_GRP" AUTHID CURRENT_USER as
/* $Header: WSHDGGPS.pls 120.0.12000000.1 2007/01/16 05:44:45 appldev ship $ */

c_sdebug    CONSTANT NUMBER := wsh_debug_sv.c_level1;
c_debug     CONSTANT NUMBER := wsh_debug_sv.c_level2;

TYPE action_parameters_rectype  IS RECORD(
caller              		VARCHAR2(32000),
action_code			VARCHAR2(32000),
phase				NUMBER,
p_Pick_Up_Location_Id		NUMBER,
p_Ship_Method			VARCHAR2(30),
p_Drop_Off_Location_Id		NUMBER,
p_Carrier_Id			NUMBER,
p_print_bol_from_dleg           Varchar2(1) default null
);

--Pack J: kvenkate: Added result_id_tab to action out rec type

TYPE action_out_rec_type IS RECORD(
valid_id_tab          		WSH_UTIL_CORE.id_tab_type,
selection_issue_flag  		VARCHAR2(1),
x_trip_id			NUMBER,
x_trip_name			VARCHAR2(30),
x_delivery_id			NUMBER,
x_bol_number			VARCHAR2(32000),
result_id_tab                   wsh_util_core.id_tab_type);

TYPE dlvy_leg_tab_type IS TABLE of WSH_DELIVERY_LEGS_PVT.Delivery_Leg_Rec_Type INDEX by BINARY_INTEGER;

PROCEDURE Delivery_Leg_Action(
	p_api_version_number	 	IN 	NUMBER,
	p_init_msg_list			IN	VARCHAR2,
	p_commit                 	IN 	VARCHAR2,
	p_rec_attr_tab			IN	dlvy_leg_tab_type,
	p_action_prms			IN	action_parameters_rectype,
	x_action_out_rec		IN OUT  NOCOPY action_out_rec_type,
	x_return_status  		OUT 	NOCOPY VARCHAR2,
	x_msg_count     		OUT 	NOCOPY NUMBER,
	x_msg_data       		OUT 	NOCOPY VARCHAR2
);


PROCEDURE Update_Delivery_Leg(
p_api_version_number     IN     NUMBER,
p_init_msg_list          IN     VARCHAR2,
p_commit                 IN     VARCHAR2,
p_delivery_leg_tab       IN     WSH_DELIVERY_LEGS_GRP.dlvy_leg_tab_type,
p_in_rec                 IN     WSH_DELIVERY_LEGS_GRP.action_parameters_rectype,
x_out_rec                OUT    NOCOPY WSH_DELIVERY_LEGS_GRP.action_out_rec_type,
x_return_status          OUT    NOCOPY VARCHAR2,
x_msg_count              OUT    NOCOPY NUMBER,
x_msg_data               OUT    NOCOPY VARCHAR2);


END WSH_DELIVERY_LEGS_GRP;

 

/
